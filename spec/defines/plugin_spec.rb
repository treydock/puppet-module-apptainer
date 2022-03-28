require 'spec_helper'

describe 'apptainer::plugin' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      let :title do
        'github.com/apptainer/apptainer/log-plugin'
      end

      let :params do
        { source_dir: 'examples/plugins/log-plugin' }
      end

      let(:pre_condition) { "class { 'apptainer': install_method => 'source' }" }

      it do
        is_expected.to contain_exec('apptainer-plugin-compile-github.com/apptainer/apptainer/log-plugin').with(
          path: '/usr/bin:/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin',
          environment: ['HOME=/root'],
          command: 'apptainer plugin compile examples/plugins/log-plugin',
          cwd: '/opt/apptainer-1.0.1',
          creates: '/opt/apptainer-1.0.1/examples/plugins/log-plugin/log-plugin.sif',
          require: 'Class[Apptainer::Install::Source]',
        )
      end

      it do
        is_expected.to contain_exec('apptainer-plugin-recompile-github.com/apptainer/apptainer/log-plugin').with(
          path: '/usr/bin:/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin',
          environment: ['HOME=/root'],
          command: 'apptainer plugin compile examples/plugins/log-plugin',
          cwd: '/opt/apptainer-1.0.1',
          onlyif: 'test -f /opt/apptainer-1.0.1/examples/plugins/log-plugin/log-plugin.sif',
          refreshonly: 'true',
          require: 'Class[Apptainer::Install::Source]',
          notify: 'Exec[apptainer-plugin-reinstall-github.com/apptainer/apptainer/log-plugin]',
        )
      end

      it do
        is_expected.to contain_exec('apptainer-plugin-install-github.com/apptainer/apptainer/log-plugin').with(
          path: '/usr/bin:/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin',
          command: 'apptainer plugin install /opt/apptainer-1.0.1/examples/plugins/log-plugin/log-plugin.sif',
          unless: "apptainer plugin list | grep 'github.com/apptainer/apptainer/log-plugin'",
          require: 'Exec[apptainer-plugin-compile-github.com/apptainer/apptainer/log-plugin]',
        )
      end

      it do
        is_expected.to contain_exec('apptainer-plugin-reinstall-github.com/apptainer/apptainer/log-plugin').with(
          path: '/usr/bin:/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin',
          command: 'apptainer plugin install /opt/apptainer-1.0.1/examples/plugins/log-plugin/log-plugin.sif',
          onlyif: "apptainer plugin list | grep 'github.com/apptainer/apptainer/log-plugin'",
          refreshonly: 'true',
          subscribe: 'Exec[apptainer-plugin-compile-github.com/apptainer/apptainer/log-plugin]',
        )
      end

      it do
        is_expected.to contain_exec('apptainer-plugin-enable-github.com/apptainer/apptainer/log-plugin').with(
          path: '/usr/bin:/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin',
          command: 'apptainer plugin enable github.com/apptainer/apptainer/log-plugin',
          unless: "apptainer plugin list | grep 'github.com/apptainer/apptainer/log-plugin' | grep yes",
          require: [
            'Exec[apptainer-plugin-install-github.com/apptainer/apptainer/log-plugin]',
            'Exec[apptainer-plugin-reinstall-github.com/apptainer/apptainer/log-plugin]',
          ],
        )
      end

      context 'when ensure => absent' do
        let(:params) { { ensure: 'absent' } }

        it do
          is_expected.to contain_exec('apptainer-plugin-uninstall-github.com/apptainer/apptainer/log-plugin').with(
            path: '/usr/bin:/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin',
            command: 'apptainer plugin uninstall github.com/apptainer/apptainer/log-plugin',
            onlyif: "apptainer plugin list | grep 'github.com/apptainer/apptainer/log-plugin'",
          )
        end
      end
    end
  end
end
