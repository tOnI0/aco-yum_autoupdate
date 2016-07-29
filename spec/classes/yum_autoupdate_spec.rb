require 'spec_helper'

describe 'yum_autoupdate' do
  let :facts do
    {
      :osfamily                  => 'RedHat',
      :operatingsystemmajrelease => '7',
      :operatingsystem           => 'RedHat'
    }
  end
  describe 'general assumptions' do
    it { is_expected.to contain_class('yum_autoupdate') }
    it { is_expected.to contain_class('yum_autoupdate::params') }
    it do
      is_expected.to contain_package('yum-cron').with({
        'ensure' => 'present'
      })
    end
    it do
      is_expected.to contain_service('yum-cron').with({
        'ensure' => 'running',
        'enable' => true
      }).that_requires('Package[yum-cron]')
    end
  end
  describe 'with default daily schedule, without default hourly schedule' do
    context 'on RedHat 5' do
      let :facts do
        super().merge({
          :operatingsystemmajrelease => '5'
        })
      end
      it do
        is_expected.to contain_file('yum-cron default config').with({
          'ensure'  => 'present',
          'path'    => '/etc/sysconfig/yum-cron',
          'mode'    => '0644',
          'require' => 'Package[yum-cron]',
          'owner'   => 'root',
          'group'   => 'root'
        })
      end
      it do
        is_expected.to contain_file('yum-cron default schedule').with({
          'ensure'  => 'present',
          'path'    => '/etc/cron.daily/yum.cron',
          'mode'    => '0755',
          'require' => 'Package[yum-cron]',
          'owner'   => 'root',
          'group'   => 'root',
          'content' => /^\#\!\/bin\/sh$/
        })
      end
      ['/etc/yum/yum-cron-hourly.conf', '/etc/cron.hourly/0yum-hourly.cron'].each do |hourly_files|
        it { is_expected.not_to contain_file(hourly_files) }
      end
    end
    context 'on RedHat 6' do
      let :facts do
        super().merge({
          :operatingsystemmajrelease => '6'
        })
      end
      it do
        is_expected.to contain_file('yum-cron default config').with({
          'ensure'  => 'present',
          'path'    => '/etc/sysconfig/yum-cron',
          'mode'    => '0644',
          'require' => 'Package[yum-cron]',
          'owner'   => 'root',
          'group'   => 'root'
        })
      end
      it do
        is_expected.to contain_file('yum-cron default schedule').with({
          'ensure'  => 'present',
          'path'    => '/etc/cron.daily/0yum.cron',
          'mode'    => '0755',
          'require' => 'Package[yum-cron]',
          'owner'   => 'root',
          'group'   => 'root',
          'content' => /^\#\!\/bin\/bash$/
        })
      end
      ['/etc/yum/yum-cron-hourly.conf', '/etc/cron.hourly/0yum-hourly.cron'].each do |hourly_files|
        it { is_expected.not_to contain_file(hourly_files) }
      end
    end
    context 'on RedHat 7' do
      let(:facts) { super() }
      it do
        is_expected.to contain_file('yum-cron default config').with({
          'ensure'  => 'present',
          'path'    => '/etc/yum/yum-cron.conf',
          'mode'    => '0644',
          'require' => 'Package[yum-cron]',
          'owner'   => 'root',
          'group'   => 'root'
        })
      end
      it do
        is_expected.to contain_file('yum-cron default schedule').with({
          'ensure'  => 'present',
          'path'    => '/etc/cron.daily/0yum-daily.cron',
          'mode'    => '0755',
          'require' => 'Package[yum-cron]',
          'owner'   => 'root',
          'group'   => 'root',
          'content' => /^exec.*yum-cron\.conf$/
        })
      end
      ['/etc/yum/yum-cron-hourly.conf', '/etc/cron.hourly/0yum-hourly.cron'].each do |hourly_files|
        it do
          is_expected.to contain_file(hourly_files).with_ensure('absent')
        end
      end
    end
    context 'on Fedora' do
      let :facts do
        super().merge({
          :operatingsystemmajrelease => '21',
          :operatingsystem           => 'Fedora'
        })
      end
      it do
        is_expected.to contain_file('yum-cron default config').with({
          'ensure'  => 'present',
          'path'    => '/etc/yum/yum-cron.conf',
          'mode'    => '0644',
          'require' => 'Package[yum-cron]',
          'owner'   => 'root',
          'group'   => 'root'
        })
      end
      it do
        is_expected.to contain_file('yum-cron default schedule').with({
          'ensure'  => 'present',
          'path'    => '/etc/cron.daily/0yum-daily.cron',
          'mode'    => '0755',
          'require' => 'Package[yum-cron]',
          'owner'   => 'root',
          'group'   => 'root',
          'content' => /^exec.*yum-cron\.conf$/
        })
      end
      ['/etc/yum/yum-cron-hourly.conf', '/etc/cron.hourly/0yum-hourly.cron'].each do |hourly_files|
        it do
          is_expected.to contain_file(hourly_files).with_ensure('absent')
        end
      end
    end
  end
  describe 'without default daily schedule, with default hourly schedule' do
    let :params do
      {
        'default_schedule'    => false,
        'keep_default_hourly' => true
      }
    end
    context 'on RedHat 5' do
      let :facts do
        super().merge({
          :operatingsystemmajrelease => '5'
        })
      end
      ['yum-cron default config', 'yum-cron default schedule'].each do |daily_files|
        it { is_expected.to contain_file(daily_files).with_ensure('absent') }
      end
      ['/etc/yum/yum-cron-hourly.conf', '/etc/cron.hourly/0yum-hourly.cron'].each do |hourly_files|
        it { is_expected.not_to contain_file(hourly_files) }
      end
    end
    context 'on RedHat 6' do
      let :facts do
        super().merge({
          :operatingsystemmajrelease => '6'
        })
      end
      ['yum-cron default config', 'yum-cron default schedule'].each do |daily_files|
        it { is_expected.to contain_file(daily_files).with_ensure('absent') }
      end
      ['/etc/yum/yum-cron-hourly.conf', '/etc/cron.hourly/0yum-hourly.cron'].each do |hourly_files|
        it { is_expected.not_to contain_file(hourly_files) }
      end
    end
    context 'on RedHat 7' do
      let(:facts) { super() }
      ['yum-cron default config', 'yum-cron default schedule'].each do |daily_files|
        it { is_expected.to contain_file(daily_files).with_ensure('absent') }
      end
      ['/etc/yum/yum-cron-hourly.conf', '/etc/cron.hourly/0yum-hourly.cron'].each do |hourly_files|
        it do
          is_expected.not_to contain_file(hourly_files)
        end
      end
    end
    context 'on Fedora' do
      let :facts do
        super().merge({
          :operatingsystemmajrelease => '21',
          :operatingsystem           => 'Fedora'
        })
      end
      ['yum-cron default config', 'yum-cron default schedule'].each do |daily_files|
        it { is_expected.to contain_file(daily_files).with_ensure('absent') }
      end
      ['/etc/yum/yum-cron-hourly.conf', '/etc/cron.hourly/0yum-hourly.cron'].each do |hourly_files|
        it do
          is_expected.not_to contain_file(hourly_files)
        end
      end
    end
  end
  describe 'configuration file' do
    describe 'with default parameters' do
      context 'on RedHat 5' do
        let :facts do
          super().merge({
            :operatingsystemmajrelease => '5'
          })
        end
        it 'expect valid content' do
          is_expected.to contain_file('yum-cron default config').with_content("# ******************\n# Managed by Puppet\n# ******************\n\nYUM_PARAMETER=\nCHECK_ONLY=no\nDOWNLOAD_ONLY=no\nERROR_LEVEL=0\nDEBUG_LEVEL=1\nMAILTO=root\nRANDOMWAIT=\"60\"\n")
        end
      end
      context 'on RedHat 6' do
        let :facts do
          super().merge({
            :operatingsystemmajrelease => '6'
          })
        end
        it 'expect valid content' do
          is_expected.to contain_file('yum-cron default config').with_content("# ******************\n# Managed by Puppet\n# ******************\n\nYUM_PARAMETER=\nCHECK_ONLY=no\nDOWNLOAD_ONLY=no\nCHECK_FIRST=no\nERROR_LEVEL=0\nDEBUG_LEVEL=1\nMAILTO=root\n#SYSTEMNAME=\"\"\nRANDOMWAIT=60\n#DAYS_OF_WEEK=\"0123456\" \nCLEANDAY=\"0\"\nSERVICE_WAITS=yes\nSERVICE_WAIT_TIME=300\n\n## extra options from the aco-yum_autoupdate Puppet module\nMAILFROM=root\n")
        end
      end
      context 'on new generation' do
        it 'expect valid content' do
          is_expected.to contain_file('yum-cron default config').with_content("# ******************\n# Managed by Puppet\n# ******************\n\n[commands]\nupdate_cmd = default\nupdate_messages = yes\ndownload_updates = yes\napply_updates = yes\nrandom_sleep = 60\n\n[emitters]\nsystem_name = None\nemit_via = email\noutput_width = 80\n\n[email]\nemail_from = root\nemail_to = root\nemail_host = localhost\n\n[groups]\ngroup_list = None\ngroup_package_types = mandatory, default\n\n[base]\ndebuglevel = -1\nerrorlevel = 0\nskip_broken = True\nmdpolicy = group:main\n# assumeyes = True\n")
        end
      end
    end
    describe 'with all parameters overriden' do
      let :params do
        {
          'action'       => 'check',
          'exclude'      => ['httpd','kernel'],
          'notify_email' => false,
          'email_to'     => 'admin@example.com',
          'email_from'   => 'updates@localhost',
          'debug_level'  => 4,
          'error_level'  => 2,
          'update_cmd'   => 'security',
          'randomwait'   => 120
        }
      end
      context 'on RedHat 5' do
        let :facts do
          super().merge({
            :operatingsystemmajrelease => '5'
          })
        end
        it 'expect valid content' do
          is_expected.to contain_file('yum-cron default config').with_content("# ******************\n# Managed by Puppet\n# ******************\n\nYUM_PARAMETER=--exclude=httpd\\ --exclude=kernel\nCHECK_ONLY=yes\nDOWNLOAD_ONLY=no\nERROR_LEVEL=2\nDEBUG_LEVEL=-1\nMAILTO=admin@example.com\nRANDOMWAIT=\"120\"\n")
        end
      end
      context 'on RedHat 6' do
        let :facts do
          super().merge({
            :operatingsystemmajrelease => '6'
          })
        end
        it 'expect valid content' do
          is_expected.to contain_file('yum-cron default config').with_content("# ******************\n# Managed by Puppet\n# ******************\n\nYUM_PARAMETER=--exclude=httpd\\ --exclude=kernel\nCHECK_ONLY=yes\nDOWNLOAD_ONLY=no\nCHECK_FIRST=no\nERROR_LEVEL=2\nDEBUG_LEVEL=-1\nMAILTO=admin@example.com\n#SYSTEMNAME=\"\"\nRANDOMWAIT=120\n#DAYS_OF_WEEK=\"0123456\" \nCLEANDAY=\"0\"\nSERVICE_WAITS=yes\nSERVICE_WAIT_TIME=300\n\n## extra options from the aco-yum_autoupdate Puppet module\nMAILFROM=updates@localhost\n")
        end
      end
      context 'on new generation' do
        it 'expect valid content' do
          is_expected.to contain_file('yum-cron default config').with_content("# ******************\n# Managed by Puppet\n# ******************\n\n[commands]\nupdate_cmd = security\nupdate_messages = no\ndownload_updates = no\napply_updates = no\nrandom_sleep = 120\n\n[emitters]\nsystem_name = None\nemit_via = email\noutput_width = 80\n\n[email]\nemail_from = updates@localhost\nemail_to = admin@example.com\nemail_host = localhost\n\n[groups]\ngroup_list = None\ngroup_package_types = mandatory, default\n\n[base]\ndebuglevel = -1\nerrorlevel = 2\nskip_broken = True\nmdpolicy = group:main\n# assumeyes = True\nexclude=httpd kernel\n")
        end
      end
    end
  end
  describe 'parameters validation' do
    context 'action is incorrect' do
      let(:params) {{ :action => 'foo' }}
      it 'expect to fail regexp validation' do
        is_expected.to raise_error(Puppet::Error, /\$action must be either/)
      end
    end
    context 'exclude is not an array' do
      let(:params) {{ :exclude => 'httpd' }}
      it 'expect to fail array validation' do
        is_expected.to raise_error(Puppet::Error, /\"httpd\" is not an Array/)
      end
    end
    context 'notify_email is not a boolean' do
      let(:params) {{ :notify_email => 'yes' }}
      it 'expect to fail boolean validation' do
        is_expected.to raise_error(Puppet::Error, /\"yes\" is not a boolean/)
      end
    end
    context 'email_to is not a string' do
      let(:params) {{ :email_to => ['admin@example.com'] }}
      it 'expect to fail string validation' do
        is_expected.to raise_error(Puppet::Error, /\[\"admin@example.com\"\] is not a string/)
      end
    end
    context 'email_to is not a string' do
      let(:params) {{ :email_to => ['admin@example.com'] }}
      it 'expect to fail string validation' do
        is_expected.to raise_error(Puppet::Error, /\[\"admin@example.com\"\] is not a string/)
      end
    end
    context 'debug_level is out of bounds' do
      let(:params) {{ :debug_level => 42 }}
      it 'expect to fail range validation' do
        is_expected.to raise_error(Puppet::Error, /\$debug_level must be a number between -1 and 10/)
      end
    end
    context 'update_cmd is incorrect' do
      let(:params) {{ :update_cmd => 'foo' }}
      it 'expect to fail regexp validation' do
        is_expected.to raise_error(Puppet::Error, /\$update_cmd must be either/)
      end
    end
  end
end
