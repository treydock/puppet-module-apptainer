require 'spec_helper_acceptance'

describe 'apptainer class:' do
  context 'add singularity' do
    it 'runs successfully' do
      pp = <<-EOS
      class { 'singularity':
        # Avoid /etc/localtime which may not exist in minimal Docker environments
        bind_paths => ['/etc/hosts'],
      }
      EOS

      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end
  end

  context 'default parameters', if: fact('os.family') == 'RedHat' do
    let(:version) { '1.0.0' }

    it 'runs successfully' do
      pp = <<-EOS
      class { 'apptainer':
        version    => '#{version}',
        remove_singularity => true,
        # Avoid /etc/localtime which may not exist in minimal Docker environments
        bind_paths => ['/etc/hosts'],
      }
      EOS

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

  context 'upgrades package install', if: fact('os.family') == 'RedHat' do
    let(:version) { '1.0.1' }

    it 'runs successfully' do
      pp = <<-EOS
      class { 'apptainer':
        version    => '#{version}',
        # Avoid /etc/localtime which may not exist in minimal Docker environments
        bind_paths => ['/etc/hosts'],
      }
      EOS

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

  context 'downgrade package install', if: fact('os.family') == 'RedHat' do
    let(:version) { '1.0.0' }

    it 'runs successfully' do
      pp = <<-EOS
      class { 'apptainer':
        version    => '#{version}',
        # Avoid /etc/localtime which may not exist in minimal Docker environments
        bind_paths => ['/etc/hosts'],
      }
      EOS

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

  context 'source install' do
    let(:version) { '1.0.0' }

    it 'runs successfully' do
      pp = <<-EOS
      class { 'apptainer':
        version         => '#{version}',
        install_method  => 'source',
        remove_singularity => true,
        # Avoid /etc/localtime which may not exist in minimal Docker environments
        bind_paths      => ['/etc/hosts'],
      }
      EOS

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

  context 'upgrade' do
    let(:version) { '1.0.1' }

    it 'runs successfully' do
      pp = <<-EOS
      class { 'apptainer':
        version         => '#{version}',
        install_method  => 'source',
        # Avoid /etc/localtime which may not exist in minimal Docker environments
        bind_paths      => ['/etc/hosts'],
      }
      EOS

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

  context 'downgrade' do
    let(:version) { '1.0.0' }

    it 'runs successfully' do
      pp = <<-EOS
      class { 'apptainer':
        version         => '#{version}',
        install_method  => 'source',
        # Avoid /etc/localtime which may not exist in minimal Docker environments
        bind_paths      => ['/etc/hosts'],
      }
      EOS

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
