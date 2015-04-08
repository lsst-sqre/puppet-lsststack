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

```puppet
include ::lsststack
```

```puppet
class { 'lsststack':
  install_dependencies => true,
}
```

### Classes

#### `lsststack`

```puppet
# defaults
class { 'lsststack':
  install_dependencies => true,
}
```

##### `install_dependencies`

`Boolean` Defaults to `true`

If `true`, build dependency packages will be installed.

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
