# == Define: yum_autoupdate::schedule
#
# Creates yum-cron custom schedules
#
# === Parameters:
#
# [*action*]
#   mode in which yum-cron should perform (valid: 'check', 'download', 'apply')
# [*exclude*]
#   packages to exclude from automatic update (array)
# [*yum_params*]
#   any extra yum cmdline parameters like --disablerepo= (only supported on RHEL 5 & 6)
# [*notify_email*]
#   enable email notifications (boolean)
# [*email_to*]
#   recipient email address for update notifications. No effect when $notify is false
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
# [*user*]
#   the user who owns the cron job
# [*hour*]
#   the hour at which to run the cron job
# [*minute*]
#   the minute at which to run the cron job
# [*month*]
#   the month of the year on which to run the cron job
# [*monthday*]
#   the day of the month on which to run the cron job
# [*weekday*]
#   the weekday on which to run the cron job
# [*special*]
#   a special value (valid: ‘reboot’, ‘annually’, 'monthly', 'weekly', 'daily', 'hourly')
#
# === Actions:
#
# * Create yum-cron schedule
#
# === Requires:
#
# * yum_autoupdate class
#
# === Sample Usage:
#
#  ::yum_autoupdate::schedule { 'hourly':
#    action       => 'check',
#    notify_email => false,
#    special      => 'hourly'
#  }
#
define yum_autoupdate::schedule (
  $action       = 'apply',
  $exclude      = [],
  $yum_params   = '',
  $notify_email = true,
  $email_to     = 'root',
  $email_from   = 'root',
  $debug_level  = $yum_autoupdate::params::debug_level,
  $error_level  = 0,
  $update_cmd   = 'default',
  $randomwait   = 60,
  #cron attributes,
  $user         = root,
  $hour         = undef,
  $minute       = undef,
  $monthday     = undef,
  $month        = undef,
  $weekday      = undef,
  $special      = undef) {
  # The base class must be included first
  if !defined(Class['yum_autoupdate']) {
    fail('You must include the yum_autoupdate base class before using any yum_autoupdate defined resources')
  }

  # parameters validation
  validate_re($action, '^(check|download|apply)$', '$action must be either \'check\', \'download\' or \'apply\'')
  validate_array($exclude)
  validate_bool($notify_email)
  validate_string($email_to, $email_from, $update_cmd, $yum_params)
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
  
  # remove potential spaces from name
  $name_real = delete($name, ' ')

  if $::operatingsystem != 'Fedora' and $::operatingsystemmajrelease < '7' {
    $exclude_real = join(prefix($exclude, '--exclude='), '\ ')
  } else {
    $exclude_real = join($exclude, ' ')
  }
  
  # create a more suitable location for our scripts
  if !defined(File['/etc/yum/schedules']) {
    file { '/etc/yum/schedules': ensure => directory }
  }

  # config file
  $config_path = "${yum_autoupdate::params::default_config_path}_${name_real}"
  file { "yum-cron ${name} config":
    ensure  => present,
    path    => $config_path,
    content => template("${module_name}/conf/${yum_autoupdate::params::conf_tpl}"),
    mode    => '0644'
  }

  # schedule
  file { "yum-cron ${name} schedule":
    ensure  => present,
    path    => "/etc/yum/schedules/yum-cron_${name_real}",
    content => template("${module_name}/schedule/${yum_autoupdate::params::schedule_tpl}"),
    mode    => '0755'
  } ->
  cron { "yum-cron ${name} schedule":
    ensure   => present,
    command  => "/etc/yum/schedules/yum-cron_${name_real}",
    user     => $user,
    hour     => $hour,
    minute   => $minute,
    month    => $month,
    monthday => $monthday,
    weekday  => $weekday,
    special  => $special
  }
}
