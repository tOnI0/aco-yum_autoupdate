# == Class: yum_autoupdate
#
# This module installs yum-cron on Enterprise Linux systems and configures unattended system updates
#
# === Parameters:
#
# [*service_ensure*]
#   whether the service should be running (valid: 'stopped', 'running')
# [*service_enable*]
#   enable service (boolean)
# [*default_schedule*]
#   wheter to enable and configure the default daily schedule (boolean)
# [*keep_default_hourly*]
#   wheter to keep the default hourly schedule (boolean)
# [*action*]
#   mode in which yum-cron should perform (valid: 'check', 'download', 'apply')
# [*exclude*]
#   packages to exclude from automatic update (array)
# [*notify_email*]
#   enable email notifications (boolean)
# [*email_to*]
#   recipient email address for update notifications. No effect when $notify_email is false
# [*email_from*]
#   sender email address for update notifications. No effect when $email_to is empty
# [*debug_level*]
#   YUM debug level (valid: 0-10 or -1). -1 to disable debug output completely
# [*error_level*]
#   YUM error level (valid: 0-10). 0 to disable error output completely
# [*randomwait*]
#   maximum amount of time in minutes YUM randomly waits before running (valid: 0-1440). 0 to disable
# [*update_cmd*]
#   what kind of update to use (valid: default, security, security-severity:Critical, minimal, minimal-security,
#   minimal-security-severity:Critical)
#
# === Actions:
#
# * Install yum-cron
# * Configure automatic updates and email notifications
#
# === Requires:
#
# - puppetlabs/stdlib module
#
# === Sample Usage:
#
#  class { '::yum_autoupdate':
#    action  => 'apply',
#    email   => 'user@example.com',
#    exclude => ['kernel']
#  }
#
class yum_autoupdate (
  $service_ensure      = 'running',
  $service_enable      = true,
  $default_schedule    = true,
  $keep_default_hourly = false,
  $action              = 'apply',
  $exclude             = [],
  $notify_email        = true,
  $email_to            = 'root',
  $email_from          = 'root',
  $debug_level         = $yum_autoupdate::params::debug_level,
  $error_level         = 0,
  $skip_broken         = 'True',
  $update_cmd          = 'default',
  $randomwait          = 60) inherits yum_autoupdate::params {
  # parameters validation
  validate_re($service_ensure, '^(stopped|running)$', '$service_ensure must be either \'stopped\', or \'running\'')
  validate_bool($service_enable, $notify_email, $default_schedule, $keep_default_hourly, $skip_broken)
  validate_re($action, '^(check|download|apply)$', '$action must be either \'check\', \'download\' or \'apply\'')
  validate_array($exclude)
  validate_string($email_to, $email_from, $update_cmd)
  if ($debug_level < -1) or ($debug_level > 10) { fail('$debug_level must be a number between -1 and 10') }
  if ($error_level < 0) or ($error_level > 10) { fail('$error_level must be a number between 0 and 10') }
  validate_re($update_cmd, '^(default|security|security-severity:Critical|minimal|minimal-security|minimal-security-severity:Critical)$', '$update_cmd must be either \'default\', \'security\', \'security-severity:Critical\', \'minimal\', \'minimal-security\' or \'minimal-security-severity:Critical\'')
  if ($randomwait < 0) or ($randomwait > 1440) { fail('$randomwait must be a number between 0 and 1440') }

  # set real debug level
  if $notify_email == false {
    $debug_level_real = -1
  } else {
    $debug_level_real = $debug_level
  }

  if $::operatingsystem != 'Fedora' and $::operatingsystemmajrelease < '7' {
    $exclude_real = join(prefix($exclude, '--exclude='), '\ ')
  } else {
    $exclude_real = join($exclude, ' ')
  }

  # package installation and service configuration
  package { 'yum-cron': ensure => present } ->
  service { 'yum-cron':
    ensure => $service_ensure,
    enable => $service_enable
  }

  # don't attempt any file replacement before the package is installed
  File {
    require => Package['yum-cron'],
    owner   => 'root',
    group   => 'root'
  }

  # config file
  $config_path = $yum_autoupdate::params::default_config_path
  if $default_schedule {
    file { 'yum-cron default config':
      ensure  => present,
      path    => $yum_autoupdate::params::default_config_path,
      content => template("${module_name}/conf/${yum_autoupdate::params::conf_tpl}"),
      mode    => '0644'
    }
  } else {
    file { 'yum-cron default config':
      ensure => absent,
      path   => $yum_autoupdate::params::default_config_path
    }
  }

  # default daily schedule
  if $default_schedule {
    file { 'yum-cron default schedule':
      ensure  => present,
      path    => $yum_autoupdate::params::default_schedule_path,
      content => template("${module_name}/schedule/${yum_autoupdate::params::schedule_tpl}"),
      mode    => '0755'
    }
  } else {
    file { 'yum-cron default schedule':
      ensure => absent,
      path   => $yum_autoupdate::params::default_schedule_path
    }
  }

  # clear default hourly schedule on recent OSes
  # it can be recreated and customized using a 'schedule' resource
  if $::operatingsystem == 'Fedora' or ($::operatingsystem != 'Fedora' and $::operatingsystemmajrelease >= '7') {
    if ! $keep_default_hourly {
      file { ['/etc/yum/yum-cron-hourly.conf', '/etc/cron.hourly/0yum-hourly.cron']: ensure => absent }
    }
  }
}
