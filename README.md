#yum_autoupdate
[![Build Status](https://travis-ci.org/antoineco/aco-yum_autoupdate.svg?branch=master)](https://travis-ci.org/antoineco/aco-yum_autoupdate)

####Table of Contents

1. [Overview - What is the yum_autoupdate module?](#overview)
2. [Module Description - What does the module do?](#module-description)
3. [Setup - The basics of getting started with yum_autoupdate](#setup)
  * [A couple of examples](#a-couple-of-examples)
4. [Usage - The classes and defined types available for configuration](#usage)
  * [Classes and Defined Types](#classes-and-defined-types)
    * [Class: yum_autoupdate](#class-yum_autoupdate)
    * [Define: yum_autoupdate::schedule](#define-yum_autoupdateschedule)
    * [Common parameters](#common-parameters)
5. [To Do - List of features to be implemented](#to-do)
6. [Testing - How to run the included spec tests](#testing)
7. [Contributors](#contributors)

##Overview

The yum_autoupdate module allows you to configure automatic updates on all [RHEL variants](http://en.wikipedia.org/wiki/List_of_Linux_distributions#RHEL-based) including Fedora.

##Module description

The yum-cron service enables scheduled system updates on RHEL-based systems. This module allows you to install and configure this service without the need to fiddle manually with configuration files, which may vary from one major version to the other on most RHEL-based distributions.

##Setup

yum_autoupdate will affect the following parts of your system:

* yum-cron package and service
* yum cron configuration file(s)
* yum-cron script on older distributions

Including the main class is enough to get started. It will enable automatic updates check via a cron.daily task and apply all available updates whenever possible. Summary emails are sent to the local root user.

```puppet
include ::yum_autoupdate
```

####A couple of examples

Disable emails and just download updates, do not apply

```puppet
class { '::yum_autoupdate':
  notify_email => false,
  action       => 'download'
}
```

Suppress debug output completely, but keep logging possible errors

```puppet
class { '::yum_autoupdate':
  …
  debug_level => -1,
  error_level => 3
}
```

Send emails to a different receiver (local root account by default) and from a specific sender address 

```puppet
class { '::yum_autoupdate':
  …
  email_to   => 'admin@example.com',
  email_from => 'sysupdates@example.com'
}
```

Let crond send emails instead of mailx

```puppet
class { '::yum_autoupdate':
  …
  email_to => ''
}
```

Disable random delay

```puppet
class { '::yum_autoupdate':
  …
  randomwait => 0
}
```

Exclude specific packages

```puppet
class { '::yum_autoupdate':
  …
  exclude => ['httpd','puppet*']
}
```

Replace all default schedules by custom ones

```puppet
class { '::yum_autoupdate':
  default_schedule => false
}
yum_autoupdate::schedule { 'weekly update':
  action  => 'apply',
  special => 'weekly',
  …
}
yum_autoupdate::schedule { 'daily download':
  action  => 'download',
  hour    => '23',
  minute  => '30',
  weekday => '*'
  …
}
```

##Usage

####Class: `yum_autoupdate`

Primary class and entry point of the module.

**Parameters within `yum_autoupdate`:**

#####`service_ensure`
Whether the service should be running. Valid values are `stopped` and `running`. Defaults to `running`

#####`service_enable`
Whether to enable the yum-cron service. Boolean value. Defaults to `true`

#####`default_schedule`
Wheteher to enable the default daily schedule. If yes, configure it using the class parameters. Boolean value. Defaults to `true`

#####`keep_default_hourly`
Wheteher to keep the default hourly check. Boolean value. Defaults to `false`

See also [Common parameters](#common-parameters)

####Define: `yum_autoupdate::schedule`

Create a yum-cron schedule

**Parameters within `yum_autoupdate::schedule`:**

#####`user`, `hour`, `minute`, `month`, `monthday`, `weekday`, `special`
Please read [Puppet cron type](https://docs.puppetlabs.com/references/latest/type.html#cron)

See also [Common parameters](#common-parameters)

####Common parameters

Parameters common to both `yum_autoupdate` and `yum_autoupdate::schedule`

#####`action`
Mode in which yum-cron should perform. Valid values are `check`, `download` and `apply`. Defaults to `apply`

#####`exclude`
Array of packages to exclude from automatic update. Defaults to `[]`

#####`notify_email`
Enable email notifications. Boolean value. Defaults to `true`  
It is recommended to also adjust debug/error levels accordingly (see below) 

#####`email_to`
Recipient email address for update notifications. Defaults to `root` (local user)  
An empty string forces the output to stdio, so emails will be sent by crond

#####`email_from`
Sender email address for update notifications. No effect when `email_to` is empty. Defaults to `root` (local user)  
*Note:* not supported on CentOS 5

#####`debug_level`
YUM debug level. Valid values are numbers between `-1` and `10`. `-1` to disable. Default depends on the platform  
Enforced to `-1` when `notify_email` is `false`  
*Notes:*
* `-1` is necessary to also suppress messages from deltarpm, since `0` doesn't
* Always outputs to stdio on modern platforms, can apparently not be changed

#####`error_level`
YUM error level. Valid values are numbers between `0` and `10`. `0` to disable. Defaults to `0`  
*Note:* always outputs to stdio on modern platforms, can apparently not be changed

#####`update_cmd`
What updates to install, based on RedHat erratas. Valid values are:
* `default` (all available updates)
* `security` (only packages with a security errata)
* `security-severity:Critical` (only packages with a Critical security errata)
* `minimal` (only upgrade to latest bugfix or security errata, ignore enhancements)
* `minimal-security` (only upgrade to latest security errata, ignore bugfixes and enhancements)
* `minimal-security-severity:Critical` (only upgrade to latest Critical security errata, ignore bugfixes and enhancements)

Defaults to `default`

*Note:* only supported on RHEL 7 and Fedora

#####`randomwait`

Maximum amount of time in minutes YUM randomly waits before running. Valid values are numbers between `0` and `1440`. `0` to disable. Defaults to `60`

##To Do

* Add support for passing arbitrary parameters to YUM

##Testing

The only prerequisite is to have the [Bundler](http://bundler.io/) gem installed:

```shell
$ gem install bundler
```

Install gem dependencies using Bundler (related documentation page [here](http://bundler.io/bundle_install.html)):

```shell
$ bundle install
```

When your environment is set up, run the spec tests inside the module directory using:

```shell
$ bundle exec rake spec
```

Check the [puppetlabs_spec_helper](https://github.com/puppetlabs/puppetlabs_spec_helper) GitHub repository for more information.

##Contributors

* [Kim Stig Andersen](https://github.com/ksaio)
* [Joshua Hoblitt](https://github.com/jhoblitt)
* [Daniel Forsberg](https://github.com/jenkins101)

Features request and contributions are always welcome!
