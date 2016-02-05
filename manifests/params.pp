# == Class: yum_autoupdate::params
#
class yum_autoupdate::params {
  case $::osfamily {
    'RedHat' : {
      case $::operatingsystem {
        'Fedora' : {
          if $::operatingsystemmajrelease >= '19' {
            $default_config_path = '/etc/yum/yum-cron.conf'
            $default_schedule_path = '/etc/cron.daily/0yum-daily.cron'
            $conf_tpl = 'rhel7.erb'
            $schedule_tpl = 'rhel7.erb'
            $debug_level = -1
          }
          else {
            fail("Unsupported OS version ${::operatingsystemmajrelease}")
          }
        }
        # all other RHEL-based OS
        default  : {
          case $::operatingsystemmajrelease {
            '7'     : {
              $default_config_path = '/etc/yum/yum-cron.conf'
              $default_schedule_path = '/etc/cron.daily/0yum-daily.cron'
              $debug_level = -1
            }
            '6'     : {
              $default_config_path = '/etc/sysconfig/yum-cron'
              $default_schedule_path = '/etc/cron.daily/0yum.cron'
              $debug_level = 1
            }
            '5'     : {
              $default_config_path = '/etc/sysconfig/yum-cron'
              $default_schedule_path = '/etc/cron.daily/yum.cron'
              $debug_level = 1
            }
            default : {
              fail("Unsupported OS version ${::operatingsystemmajrelease}")
            }
          }
          $conf_tpl = "rhel${::operatingsystemmajrelease}.erb"
          $schedule_tpl = "rhel${::operatingsystemmajrelease}.erb"
        }
      }
    }
    default  : {
      fail("Unsupported OS family ${::osfamily}")
    }
  }
}
