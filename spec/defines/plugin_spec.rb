# frozen_string_literal: true

require 'spec_helper'

describe 'apptainer::plugin' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) do
        os_facts
      end

      let :title do
        'example.com/log-plugin'
      end

      let(:version) { '1.1.3' }

      let :params do
        { source_dir: 'examples/plugins/log-plugin' }
      end

      let(:pre_condition) { "class { 'apptainer': install_method => 'source' }" }

      it { is_expected.not_to contain_exec('apptainer-plugin-uninstall-for-upgrade-example.com/log-plugin') }

      it do
        is_expected.to contain_exec('apptainer-plugin-compile-example.com/log-plugin').with(
          path: '/usr/bin:/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin',
          environment: ['HOME=/root'],
          command: 'apptainer plugin compile examples/plugins/log-plugin',
          cwd: "/opt/apptainer-#{version}",
          creates: "/opt/apptainer-#{version}/examples/plugins/log-plugin/log-plugin.sif",
          require: 'Class[Apptainer::Install::Source]',
        )
      end

      it do
        is_expected.to contain_exec('apptainer-plugin-recompile-example.com/log-plugin').with(
          path: '/usr/bin:/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin',
          environment: ['HOME=/root'],
          command: 'apptainer plugin compile examples/plugins/log-plugin',
          cwd: "/opt/apptainer-#{version}",
          onlyif: "test -f /opt/apptainer-#{version}/examples/plugins/log-plugin/log-plugin.sif",
          refreshonly: 'true',
          require: 'Class[Apptainer::Install::Source]',
          notify: 'Exec[apptainer-plugin-reinstall-example.com/log-plugin]',
        )
      end

      it do
        is_expected.to contain_exec('apptainer-plugin-install-example.com/log-plugin').with(
          path: '/usr/bin:/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin',
          command: "apptainer plugin install /opt/apptainer-#{version}/examples/plugins/log-plugin/log-plugin.sif",
          unless: "apptainer plugin list | grep 'example.com/log-plugin'",
          require: 'Exec[apptainer-plugin-compile-example.com/log-plugin]',
        )
      end

      it do
        is_expected.to contain_exec('apptainer-plugin-reinstall-example.com/log-plugin').with(
          path: '/usr/bin:/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin',
          command: "apptainer plugin install /opt/apptainer-#{version}/examples/plugins/log-plugin/log-plugin.sif",
          onlyif: "apptainer plugin list | grep 'example.com/log-plugin'",
          refreshonly: 'true',
          subscribe: 'Exec[apptainer-plugin-compile-example.com/log-plugin]',
        )
      end

      it do
        is_expected.to contain_exec('apptainer-plugin-enable-example.com/log-plugin').with(
          path: '/usr/bin:/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin',
          command: 'apptainer plugin enable example.com/log-plugin',
          unless: "apptainer plugin list | grep 'example.com/log-plugin' | grep yes",
          require: [
            'Exec[apptainer-plugin-install-example.com/log-plugin]',
            'Exec[apptainer-plugin-reinstall-example.com/log-plugin]'
          ],
        )
      end

      context 'when upgrading apptainer' do
        let(:facts) { os_facts.merge(apptainer_version: '1.0.1') }
        let(:pre_condition) { "class { 'apptainer': version => '1.0.2', install_method => 'source' }" }

        it do
          is_expected.to contain_exec('apptainer-plugin-uninstall-for-upgrade-example.com/log-plugin').with(
            path: '/usr/bin:/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin',
            command: 'apptainer plugin uninstall example.com/log-plugin',
            onlyif: "apptainer plugin list | grep 'example.com/log-plugin'",
            before: 'Class[Apptainer::Install::Source]',
          )
        end
      end

      context 'when ensure => absent' do
        let(:params) { { ensure: 'absent' } }

        it do
          is_expected.to contain_exec('apptainer-plugin-uninstall-example.com/log-plugin').with(
            path: '/usr/bin:/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin',
            command: 'apptainer plugin uninstall example.com/log-plugin',
            onlyif: "apptainer plugin list | grep 'example.com/log-plugin'",
          )
        end
      end
    end
  end
end
