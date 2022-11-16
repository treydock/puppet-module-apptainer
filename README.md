# puppet-module-apptainer

[![Puppet Forge](http://img.shields.io/puppetforge/v/treydock/apptainer.svg)](https://forge.puppetlabs.com/treydock/apptainer)
[![CI Status](https://github.com/treydock/puppet-module-apptainer/workflows/CI/badge.svg?branch=master)](https://github.com/treydock/puppet-module-apptainer/actions?query=workflow%3ACI)

#### Table of Contents

1. [Overview](#overview)
2. [Usage - Configuration options](#usage)
3. [Reference - Parameter and detailed reference to all options](#reference)

## Overview

This module manages the apptainer installation and configuration of apptainer.conf.

RedHat and Debian (except Debian 10) based systems will by default install from apptainer package

Debian 10 will by default install from source

## Usage

### apptainer

Install and configure apptainer.

```puppet
include apptainer
```

For both package and source installs, it's best to define the desired version.
This Puppet module supports both upgrades and downgrades of Apptainer.

```yaml
apptainer::version: '1.0.1'
```

The following Hiera example of building from source (default for Debian based systems) with several additional options passed.

```yaml
golang::version: '1.19.2'
apptainer::version: '1.0.1'
apptainer::install_method: source
apptainer::build_flags:
  without-suid: true
  mandir: /some/other/path
apptainer::build_env:
  GOPATH=/some/other/path
apptainer::prefix: /opt/apptainer
apptainer::sysconfdir: /opt/apptainer/etc
apptainer::localstatedir: /opt/apptainer/var
```

Compile and install a Apptainer plugin from the Apptainer source:

```yaml
apptainer::plugins:
  github.com/apptainer/apptainer/log-plugin:
    source_dir: examples/plugins/log-plugin
```

If replacing Singularity with Apptainer, it's possible to have this module cleanup Singularity to avoid conflicts:

```yaml
apptainer::remove_singularity: true
```

Enabling Singularity removal will result in the following actions:

* Remove /etc/singularity

## Reference

[http://treydock.github.io/puppet-module-apptainer/](http://treydock.github.io/puppet-module-apptainer/)

