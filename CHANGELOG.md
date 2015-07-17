###0.6.2

* Fix compatibility with Puppet 2.7 ([jenkins101](https://github.com/jenkins101))
* Partial revert of changes introduced in v0.6.1 (Puppet 4.x)

###0.6.1

* Fix compatibility with Puppet 4.0 ([jhoblitt](https://github.com/jhoblitt))
* Housekeeping for Travis CI ([jhoblitt](https://github.com/jhoblitt))
* Support Fedora 22

###0.6.0

* Added spec tests, see documentation for guidelines
* Minor bugfixes

###0.5.1

Fix compatibility with future parser in Puppet 3.7.4 ([PUP-3615](https://tickets.puppetlabs.com/browse/PUP-3615))

###0.5.0

* Add custom schedules via the `yum_autoupdate::schedule` defined type
* Drop support for Fedora 17 and 18
* Compatible with future parser

###0.4.1

* Improve code quality, doc and metadata
* Support Fedora 21

###0.4.0

* `update_cmd` can now be defined ([ksaio](https://github.com/ksaio)!)
* Deletion of the default hourly schedule on RHEL 7/Fedora 19+
* Make Puppet Doc compliant with RDoc markup language
* Refactoring

###0.3.2

* Remove `email_from` feature from CentOS 5, since it is not supported
* Updated documentation

###0.3.1

* Adjust default `debug_level` depending on the platform
* `debug_level` is enforced to `-1` when `notify_email` is set to `false`
* Updated documentation
* Removed unused `download_only` parameter (leftover)

###0.3.0

* Class parameter changes. See documentation for usage
  * New class parameter `notify_email` (boolean) to disable email notifications in a more consistent way
  * `debug_level` parameter now accepts value `-1` to also suppress deltarpm messages 
* Fixed permissions on module content, causing module upgrade to complain about changed files
    * NOTE: use the `--force` option to upgrade to this release
* Updated documentation

###0.2.0

* Added support for Fedora 15+

###0.1.1

* Move package exclusion logic from ERB templates to Puppet STL
* Added To Do documentation section
* Added this changelog
 
###0.1.0

First forge release
