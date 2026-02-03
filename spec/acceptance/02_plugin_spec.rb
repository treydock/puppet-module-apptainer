# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'apptainer::plugin' do
  context 'when installs log plugin' do
    it 'runs successfully' do
      setup_pp = <<-SETUP_PP
      class { 'rsyslog::config':
        global_config => {
          'workDirectory' => { 'value' => '/var/lib/rsyslog' },
        },
        modules => {
          'imuxsock' => { 'priority' => 5 },
          'imklog' => { 'priority' => 6 },
          'imjournal' => {
            'priority' => 7,
            'config' => { 'StateFile' => 'imjournal.state' },
          },
        },
        actions => {
          'any' => {
            'type' => 'omfile',
            'facility' => 'default',
            'config' => {
              'file' => '/var/log/messages',
              'fileCreateMode' => '0644',
              'fileOwner' => 'root',
              'fileGroup' => 'root',
            }
          }
        }
      }
      SETUP_PP
      pp = <<-PUPPET_PP
      class { 'golang':
        version => '1.24.11',
      }
      class { 'apptainer':
        version        => '1.4.4',
        install_method => 'source',
        # Avoid /etc/localtime which may not exist in minimal Docker environments
        bind_paths     => ['/etc/hosts'],
      }
      apptainer::plugin { 'example.com/log-plugin':
        source_dir => 'examples/plugins/log-plugin',
      }
      PUPPET_PP

      apply_manifest(setup_pp, catch_failures: true)
      apply_manifest(setup_pp, catch_failures: true)
      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    describe command('apptainer pull /tmp/lolcow.sif docker://sylabsio/lolcow ; apptainer run /tmp/lolcow.sif ; sleep 5') do
      its(:exit_status) { is_expected.to eq(0) }
    end

    describe command('grep -R apptainer /var/log/') do
      its(:stdout) { is_expected.to include('lolcow') }
    end
  end

  context 'when reinstalls log plugin during upgrade' do
    it 'runs successfully' do
      setup_pp = <<-SETUP_PP
      class { 'rsyslog::config':
        global_config => {
          'workDirectory' => { 'value' => '/var/lib/rsyslog' },
        },
        modules => {
          'imuxsock' => { 'priority' => 5 },
          'imklog' => { 'priority' => 6 },
          'imjournal' => {
            'priority' => 7,
            'config' => { 'StateFile' => 'imjournal.state' },
          },
        },
        actions => {
          'any' => {
            'type' => 'omfile',
            'facility' => 'default',
            'config' => {
              'file' => '/var/log/messages',
              'fileCreateMode' => '0644',
              'fileOwner' => 'root',
              'fileGroup' => 'root',
            }
          }
        }
      }
      SETUP_PP
      pp = <<-PUPPET_PP
      class { 'golang':
        version => '1.24.12',
      }
      class { 'apptainer':
        version        => '1.4.5',
        install_method => 'source',
        # Avoid /etc/localtime which may not exist in minimal Docker environments
        bind_paths     => ['/etc/hosts'],
      }
      apptainer::plugin { 'example.com/log-plugin':
        source_dir => 'examples/plugins/log-plugin',
      }
      PUPPET_PP

      on hosts, 'find /var/log -type f -exec rm -f {} \;'
      on hosts, 'systemctl restart rsyslog'
      apply_manifest(setup_pp, catch_failures: true)
      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    describe command('apptainer pull /tmp/lolcow.sif docker://sylabsio/lolcow ; apptainer run /tmp/lolcow.sif ; sleep 5') do
      its(:exit_status) { is_expected.to eq(0) }
    end

    describe command('grep -R apptainer /var/log/') do
      its(:stdout) { is_expected.to include('lolcow') }
    end
  end
end
