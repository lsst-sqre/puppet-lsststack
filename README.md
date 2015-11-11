Puppet lsststack Module
=========================

[![Build Status](https://travis-ci.org/lsst-sqre/puppet-lsststack.png)](https://travis-ci.org/lsst-sqre/puppet-lsststack)

#### Table of Contents

1. [Overview](#overview)
2. [Description](#description)
3. [Usage](#usage)
    * [Examples](#examples)
    * [Classes](#classes)
        * [`lsststack`](#lsststack)
    * [Defines](#defines)
        * [`lsststack::lsstsw`](#lsststacklsstsw)
        * [`lsststack::newinstall`](#lsststacknewinstall)
    * [Hiera](#hiera)
4. [Limitations](#limitations)
    * [Tested Platforms](#tested-platforms)
5. [Versioning](#versioning)
6. [Support](#support)
7. [Contributing](#contributing)
8. [Testing](#testing)
9. [See Also](#see-also)


Overview
--------

Creates and manages the build environment for the "LSST Stack"


Description
-----------

This is a puppet module for basic creation and management of the dependencies
and tools needed to build the "LSST Stack".


Usage
-----

### Examples

#### Installing stack dependencies

```puppet
include ::lsststack
```

```puppet
class { 'lsststack':
  install_dependencies => true,
}
```

#### Installing lsstsw under the test account

```puppet
lsststack::lsstsw { 'test': }
```

#### Installing a fork/branch of lsstsw for testing

```puppet
lsststack::lsstsw { 'test':
  lsstsw_repo   => 'https://github.com/jhoblitt/lsstsw.git',
  lsstsw_branch => 'feature/eups-1.5.9',
}
```

### Classes

#### `lsststack`

```puppet
# defaults
class { 'lsststack':
  install_dependencies => true,
  install_convenience  => false,
}
```

##### `install_dependencies`

`Boolean` Defaults to `true`

If `true`, build dependency packages will be installed.

##### `install_convenience`

`Boolean` Defaults to `false`

If `true`, build "convenience" packages, which are not system packages required
to build lsst software products but are convenient to have present, will be
installed.

### Defines

#### `lsststack::lsstsw`

Note that this type requires that the `lsststack` class be declared in the
manifest.

```puppet
# defaults
lsststack::lsstsw { 'lsstsw':
  user              => $title,
  group             => $title,
  manage_user       => true,
  manage_group      => true,
  lsstsw_repo       => 'https://github.com/lsst/lsstsw.git',
  lsstsw_branch     => 'master',
  lsstsw_ensure     => 'present',
  buildbot_repo     => 'https://github.com/lsst-sqre/buildbot-scripts.git',
  buildbot_branch   => 'master',
  buildbot_ensure   => 'present',
  lsst_build_repo   => 'https://github.com/lsst/lsst_build.git',
  lsst_build_branch => 'master',
  lsst_build_ensure => 'present',
  debug             => false,
}
```

##### `user`

`String` Defaults to resource title

The system user account to use.

##### `group`

`String` Defaults to resource title

The system user group to use.

##### `manage_user`

`Boolean` Defaults to `true`

If `true`, a `User` resource is declared for `$user`. If `false`, a `User` resource must be externally declared in the manifest.

##### `manage_group`

`Boolean` Defaults to `true`

If `true`, a `Group` resource is declared for `$group`. If `false`, a `Group`
resource must be externally declared in the manifest.

##### `lsstsw_repo`

`String` Defaults to 'https://github.com/lsst/lsstsw.git'

The URL to retrive the `lsst/lsstsw` repo from.

##### `lsstsw_branch`

`String` Defaults to 'master'

The git ref to checkout.

##### `lsstsw_ensure`

`String` Defaults to 'present'

Possible values are 'present' and 'latest'.

##### `buildbot_repo`

`String` Defaults to 'https://github.com/lsst-sqre/buildbot-scripts.git'

The URL to retrive the `lsst-sqre/buildbot-scripts` repo from.

##### `buildbot_branch`

`String` Defaults to 'master'

The git ref to checkout.

##### `buildbot_ensure`

`String` Defaults to 'present'

Possible values are 'present' and 'latest'.

##### `lsst_build_repo`

`String` Defaults to 'https://github.com/lsst/lsst_build.git'

The URL to retrive the `lsst/lsst_build` repo from.

##### `lsst_build_branch`

`String` Defaults to 'master'

The git ref to checkout.

##### `lsst_build_ensure`

`String` Defaults to 'present'

Possible values are 'present' and 'latest'.

##### `debug`

`Boolean` Defaults to `false`

This parameter is only useful for development and should not be considered
part of the public API of this type.

#### `lsststack::newinstall`

Note that this type requires that the `lsststack` class be declared in the
manifest.

```puppet
# defaults
lsststack::newinstall { 'lsstsw':
  user         => $title,
  group        => $title,
  manage_user  => true,
  manage_group => true,
  stack_path   => undef,
  source       => 'https://sw.lsstcorp.org/eupspkg/newinstall.sh',
  debug        => false,
}
```

##### `user`

`String` Defaults to resource title

The system user account to use.

##### `group`

`String` Defaults to resource title

The system user group to use.

##### `manage_user`

`Boolean` Defaults to `true`

If `true`, a `User` resource is declared for `$user`. If `false`, a `User` resource must be externally declared in the manifest.

##### `manage_group`

`Boolean` Defaults to `true`

If `true`, a `Group` resource is declared for `$group`. If `false`, a `Group`
resource must be externally declared in the manifest.

##### `stack_path`

`String` Defaults to `undef`

When this parameter is `undef`, the "stack" prefix path is constructed as
`/home/<user>/stack`.

##### `source`

`String` Defaults to 'https://sw.lsstcorp.org/eupspkg/newinstall.sh'

The URL to retrive the `newinstall.sh` script from.

##### `debug`

`Boolean` Defaults to `false`

This parameter is only useful for development and should not be considered
part of the public API of this type.

#### `hiera`

##### `lsststack::lsstsw`

Responds to the following hiera values:

    ---
    lsststack::lsstsw::lsstsw_repo: a
    lsststack::lsstsw::lsstsw_branch: b
    lsststack::lsstsw::lsstsw_ensure: latest
    lsststack::lsstsw::buildbot_repo: c
    lsststack::lsstsw::buildbot_branch: d
    lsststack::lsstsw::buildbot_ensure: latest
    lsststack::lsstsw::lsst_build_repo: e
    lsststack::lsstsw::lsst_build_branch: f
    lsststack::lsstsw::lsst_build_ensure: latest

#### `lsststack::newinstall`

Responds to the following hiera values:

    ---
    lsststack::newinstall::source: https://raw.githubusercontent.com/lsst/lsst/master/scripts/newinstall.sh


Limitations
-----------

### Tested Platforms

* el6
* el7
* Fedora 21
* Ubuntu 12.04
* Ubuntu 14.04


Versioning
----------

This module is versioned according to the [Semantic Versioning
2.0.0](http://semver.org/spec/v2.0.0.html) specification.


Support
-------

Please log tickets and issues at
[github](https://github.com/jhoblitt/puppet-lsststack/issues)


Contributing
------------

1. Fork it on github
2. Make a local clone of your fork
3. Create a topic branch.  Eg, `feature/mousetrap`
4. Make/commit changes
    * Commit messages should be in [imperative tense](http://git-scm.com/book/ch5-2.html)
    * Check that linter warnings or errors are not introduced - `bundle exec rake lint`
    * Check that `Rspec-puppet` unit tests are not broken and coverage is added for new
      features - `bundle exec rake spec`
    * Documentation of API/features is updated as appropriate in the README
    * If present, `beaker` acceptance tests should be run and potentially
      updated - `bundle exec rake beaker`
5. When the feature is complete, rebase / squash the branch history as
   necessary to remove "fix typo", "oops", "whitespace" and other trivial commits
6. Push the topic branch to github
7. Open a Pull Request (PR) from the *topic branch* onto parent repo's `master` branch

Testing
-------

Assuming that you are using `bundler`.

### Running unit tests

The default rake target will run both `puppet-lint` and the unit tests.

```sh
bundle exec rake
```

### Running acceptance tests

This module uses `beaker` for acceptance/integration testing.

```sh
BEAKER_set=centos-7.0 bundle exec rake beaker
```

Where `BEAKER_set` is name of a file (excluding the `.yml` extensions) under the path `spec/acceptance/nodesets/`.  Eg.

```sh
$ ls -1 spec/acceptance/nodesets/
centos-6.6.yml
centos-7.0.yml
default.yml
fedora-21.yml
ubuntu-12.04.yml
ubuntu-14.04.yml
```

See Also
--------

* [dm.lsst.org](http://dm.lsst.org)
