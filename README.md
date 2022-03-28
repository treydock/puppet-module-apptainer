# puppet-module-apptainer

[![Puppet Forge](http://img.shields.io/puppetforge/v/treydock/apptainer.svg)](https://forge.puppetlabs.com/treydock/apptainer)
[![CI Status](https://github.com/treydock/puppet-module-apptainer/workflows/CI/badge.svg?branch=master)](https://github.com/treydock/puppet-module-apptainer/actions?query=workflow%3ACI)

#### Table of Contents

1. [Overview](#overview)
2. [Usage - Configuration options](#usage)
3. [Reference - Parameter and detailed reference to all options](#reference)

## Overview

This module manages the apptainer installation and configuration of apptainer.conf.

RedHat based systems will by default install from apptainer package

Debian based systems will by default install from source

## Usage

### apptainer

Install and configure apptainer.

```puppet
include apptainer
```

The following Hiera example of building from source (default for Debian based systems) with several additional options passed.

```yaml
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

## Reference

[http://treydock.github.io/puppet-module-apptainer/](http://treydock.github.io/puppet-module-apptainer/)

