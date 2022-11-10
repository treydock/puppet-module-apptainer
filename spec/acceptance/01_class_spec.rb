# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'apptainer class:' do
  context 'with install os package', if: fact('os.family') == 'RedHat' do
    it 'runs successfully' do
      pp = <<-PUPPET_PP
      class { 'apptainer':
        version        => 'installed',
        install_method => 'os',
        install_setuid => true,
        # Avoid /etc/localtime which may not exist in minimal Docker environments
        bind_paths     => ['/etc/hosts'],
      }
      PUPPET_PP

      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    describe file('/etc/apptainer/apptainer.conf') do
      it { is_expected.to be_file }
      it { is_expected.to be_mode 644 }
      it { is_expected.to be_owned_by 'root' }
      it { is_expected.to be_grouped_into 'root' }
    end

    describe package(['apptainer', 'apptainer-suid']) do
      it { is_expected.to be_installed }
    end

    describe command('apptainer exec docker://alpine cat /etc/alpine-release') do
      its(:exit_status) { is_expected.to eq(0) }
      its(:stdout) { is_expected.to match %r{[0-9]+.[0-9]+.[0-9]+} }
    end
  end

  context 'with remove os package', if: fact('os.family') == 'RedHat' do
    it 'runs successfully' do
      pp = <<-PUPPET_PP
        package{['apptainer-suid', 'apptainer']:
          ensure => 'absent',
        }
        Package['apptainer-suid'] -> Package['apptainer']
      PUPPET_PP

      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    describe package(['apptainer', 'apptainer-suid']) do
      it { is_expected.not_to be_installed }
    end
  end

  context 'with singularity' do
    it 'runs successfully' do
      pp = <<-EO_SINGULARITY
      class { 'singularity':
        # Avoid /etc/localtime which may not exist in minimal Docker environments
        bind_paths => ['/etc/hosts'],
      }
      EO_SINGULARITY

      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end
  end

  context 'with default parameters', if: fact('os.family') == 'RedHat' do
    let(:version) { '1.1.0' }

    it 'runs successfully' do
      pp = <<-PUPPET_PP
      class { 'apptainer':
        version    => '#{version}',
        remove_singularity => true,
        # Avoid /etc/localtime which may not exist in minimal Docker environments
        bind_paths => ['/etc/hosts'],
      }
      PUPPET_PP

      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    describe file('/etc/apptainer/apptainer.conf') do
      it { is_expected.to be_file }
      it { is_expected.to be_mode 644 }
      it { is_expected.to be_owned_by 'root' }
      it { is_expected.to be_grouped_into 'root' }
    end

    describe command('apptainer version') do
      its(:stdout) { is_expected.to include(version) }
    end

    describe command('apptainer exec docker://alpine cat /etc/alpine-release') do
      its(:exit_status) { is_expected.to eq(0) }
      its(:stdout) { is_expected.to match %r{[0-9]+.[0-9]+.[0-9]+} }
    end
  end

  context 'when upgrades package install', if: fact('os.family') == 'RedHat' do
    let(:version) { '1.1.3' }

    it 'runs successfully' do
      pp = <<-PUPPET_PP
      class { 'apptainer':
        version    => '#{version}',
        # Avoid /etc/localtime which may not exist in minimal Docker environments
        bind_paths => ['/etc/hosts'],
      }
      PUPPET_PP

      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    describe file('/etc/apptainer/apptainer.conf') do
      it { is_expected.to be_file }
      it { is_expected.to be_mode 644 }
      it { is_expected.to be_owned_by 'root' }
      it { is_expected.to be_grouped_into 'root' }
    end

    describe command('apptainer version') do
      its(:stdout) { is_expected.to include(version) }
    end

    describe command('apptainer exec docker://alpine cat /etc/alpine-release') do
      its(:exit_status) { is_expected.to eq(0) }
      its(:stdout) { is_expected.to match %r{[0-9]+.[0-9]+.[0-9]+} }
    end
  end

  context 'when downgrade package install', if: fact('os.family') == 'RedHat' do
    let(:version) { '1.1.0' }

    it 'runs successfully' do
      pp = <<-PUPPET_PP
      class { 'apptainer':
        version    => '#{version}',
        # Avoid /etc/localtime which may not exist in minimal Docker environments
        bind_paths => ['/etc/hosts'],
      }
      PUPPET_PP

      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    describe file('/etc/apptainer/apptainer.conf') do
      it { is_expected.to be_file }
      it { is_expected.to be_mode 644 }
      it { is_expected.to be_owned_by 'root' }
      it { is_expected.to be_grouped_into 'root' }
    end

    describe command('apptainer version') do
      its(:stdout) { is_expected.to include(version) }
    end

    describe command('apptainer exec docker://alpine cat /etc/alpine-release') do
      its(:exit_status) { is_expected.to eq(0) }
      its(:stdout) { is_expected.to match %r{[0-9]+.[0-9]+.[0-9]+} }
    end
  end

  context 'when source install' do
    let(:version) { '1.1.0' }

    it 'runs successfully' do
      pp = <<-PUPPET_PP
      class { 'apptainer':
        version         => '#{version}',
        install_method  => 'source',
        remove_singularity => true,
        # Avoid /etc/localtime which may not exist in minimal Docker environments
        bind_paths      => ['/etc/hosts'],
      }
      PUPPET_PP

      if fact('os.family') == 'RedHat'
        on hosts, 'puppet resource package apptainer ensure=absent'
      end
      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    describe file('/etc/apptainer/apptainer.conf') do
      it { is_expected.to be_file }
      it { is_expected.to be_mode 644 }
      it { is_expected.to be_owned_by 'root' }
      it { is_expected.to be_grouped_into 'root' }
    end

    describe command('apptainer version') do
      its(:stdout) { is_expected.to include(version) }
    end

    describe command('apptainer exec docker://alpine cat /etc/alpine-release') do
      its(:exit_status) { is_expected.to eq(0) }
      its(:stdout) { is_expected.to match %r{[0-9]+.[0-9]+.[0-9]+} }
    end
  end

  context 'when upgrade' do
    let(:version) { '1.1.3' }

    it 'runs successfully' do
      pp = <<-PUPPET_PP
      class { 'apptainer':
        version         => '#{version}',
        install_method  => 'source',
        # Avoid /etc/localtime which may not exist in minimal Docker environments
        bind_paths      => ['/etc/hosts'],
      }
      PUPPET_PP

      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    describe file('/etc/apptainer/apptainer.conf') do
      it { is_expected.to be_file }
      it { is_expected.to be_mode 644 }
      it { is_expected.to be_owned_by 'root' }
      it { is_expected.to be_grouped_into 'root' }
    end

    describe command('apptainer version') do
      its(:stdout) { is_expected.to include(version) }
    end

    describe command('apptainer exec docker://alpine cat /etc/alpine-release') do
      its(:exit_status) { is_expected.to eq(0) }
      its(:stdout) { is_expected.to match %r{[0-9]+.[0-9]+.[0-9]+} }
    end
  end

  context 'when downgrade' do
    let(:version) { '1.1.0' }

    it 'runs successfully' do
      pp = <<-PUPPET_PP
      class { 'apptainer':
        version         => '#{version}',
        install_method  => 'source',
        # Avoid /etc/localtime which may not exist in minimal Docker environments
        bind_paths      => ['/etc/hosts'],
      }
      PUPPET_PP

      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    describe file('/etc/apptainer/apptainer.conf') do
      it { is_expected.to be_file }
      it { is_expected.to be_mode 644 }
      it { is_expected.to be_owned_by 'root' }
      it { is_expected.to be_grouped_into 'root' }
    end

    describe command('apptainer version') do
      its(:stdout) { is_expected.to include(version) }
    end
  end
end
