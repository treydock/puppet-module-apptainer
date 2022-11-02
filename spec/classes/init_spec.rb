# frozen_string_literal: true

require 'spec_helper'

describe 'apptainer' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts.merge(concat_basedir: '/dne')
      end

      it { is_expected.to compile.with_all_deps }

      it { is_expected.to create_class('apptainer') }

      describe 'apptainer::install::package', if: facts[:os]['family'] == 'RedHat' do
        it { is_expected.to contain_class('apptainer::install::package').that_comes_before('Class[apptainer::config]') }
        it { is_expected.not_to contain_class('apptainer::install::source') }
        it { is_expected.to contain_exec('install-apptainer') }
        it { is_expected.not_to contain_exec('install-apptainer-suid') }

        context 'with install_setuid => true' do
          let(:params) do
            {
              install_setuid: true
            }
          end

          it { is_expected.to contain_exec('install-apptainer-suid') }
        end
      end

      describe 'apptainer::install::os', if: facts[:os]['family'] == 'RedHat' do
        let(:params) do
          {
            'install_method' => 'os',
            'version' => '3.14'
          }
        end

        it { is_expected.to contain_class('apptainer::install::os').that_comes_before('Class[apptainer::config]') }
        it { is_expected.not_to contain_class('apptainer::install::source') }
        it { is_expected.not_to contain_class('apptainer::install::package') }
        it { is_expected.to contain_package('apptainer').with_ensure('3.14') }
        it { is_expected.to contain_package('apptainer-suid').with_ensure('absent') }

        describe 'with install_setuid true' do
          let(:params) do
            super().merge(install_setuid: true)
          end

          it { is_expected.to contain_package('apptainer').with_ensure('3.14') }
          it { is_expected.to contain_package('apptainer-suid').with_ensure('3.14') }
        end
      end

      describe 'apptainer::install::source', if: facts[:os]['family'] == 'Debian' do
        it { is_expected.not_to contain_class('apptainer::install::package') }
        it { is_expected.to contain_class('apptainer::install::source').that_comes_before('Class[apptainer::config]') }

        it do
          verify_contents(catalogue, 'apptainer-mconfig', [
                            './mconfig --prefix=/usr --localstatedir=/var --sysconfdir=/etc'
                          ])
        end

        context 'with install_setuid => true' do
          let(:params) do
            {
              install_setuid: true
            }
          end

          it do
            verify_contents(catalogue, 'apptainer-mconfig', [
                              './mconfig --prefix=/usr --localstatedir=/var --sysconfdir=/etc --with-suid'
                            ])
          end
        end

        context 'with build flags provided' do
          let(:params) do
            {
              build_flags: {
                'without-suid' => true,
                'prefix' => '/opt/apptainer'
              }
            }
          end

          it do
            verify_contents(catalogue, 'apptainer-mconfig', [
                              './mconfig --prefix=/opt/apptainer --localstatedir=/var --sysconfdir=/etc --without-suid'
                            ])
          end
        end
      end

      describe 'apptainer::config' do
        it { is_expected.to contain_class('apptainer::config') }

        it do
          is_expected.to contain_file('apptainer.conf').with(ensure: 'file',
                                                             path: '/etc/apptainer/apptainer.conf',
                                                             owner: 'root',
                                                             group: 'root',
                                                             mode: '0644')
        end

        it 'has default apptainer.conf contents' do
          verify_exact_contents(catalogue, 'apptainer.conf', [
                                  'allow setuid = yes',
                                  'max loop devices = 256',
                                  'allow pid ns = yes',
                                  'config passwd = yes',
                                  'config group = yes',
                                  'config resolv_conf = yes',
                                  'mount proc = yes',
                                  'mount sys = yes',
                                  'mount dev = yes',
                                  'mount devpts = yes',
                                  'mount home = yes',
                                  'mount tmp = yes',
                                  'mount hostfs = no',
                                  'bind path = /etc/localtime',
                                  'bind path = /etc/hosts',
                                  'user bind control = yes',
                                  'enable fusemount = yes',
                                  'enable overlay = try',
                                  'enable underlay = yes',
                                  'mount slave = yes',
                                  'sessiondir max size = 16',
                                  'allow container sif = yes',
                                  'allow container encrypted = yes',
                                  'allow container squashfs = yes',
                                  'allow container extfs = yes',
                                  'allow container dir = yes',
                                  'always use nv = no',
                                  'use nvidia-container-cli = no',
                                  'always use rocm = no',
                                  'root default capabilities = full',
                                  'memory fs type = tmpfs',
                                  'mksquashfs procs = 0',
                                  'shared loop devices = no',
                                  'download concurrency = 3',
                                  'download part size = 5242880',
                                  'download buffer size = 32768',
                                  'systemd cgroups = yes'
                                ])
        end

        it { is_expected.not_to contain_file('/etc/subuid') }
        it { is_expected.not_to contain_file('/etc/subgid') }

        context 'with namespace_users defined' do
          let(:params) do
            {
              namespace_users: ['foo', 'bar']
            }
          end

          it do
            is_expected.to contain_file('/etc/subuid').with(ensure: 'file',
                                                            owner: 'root',
                                                            group: 'root',
                                                            mode: '0644')
          end

          it 'has /etc/setuid contents' do
            verify_exact_contents(catalogue, '/etc/subuid', [
                                    'foo:65537:65536',
                                    'bar:131074:65536'
                                  ])
          end

          it do
            is_expected.to contain_file('/etc/subgid').with(ensure: 'file',
                                                            owner: 'root',
                                                            group: 'root',
                                                            mode: '0644')
          end

          it 'has /etc/setgid contents' do
            verify_exact_contents(catalogue, '/etc/subgid', [
                                    'foo:65537:65536',
                                    'bar:131074:65536'
                                  ])
          end
        end
      end
    end
  end
end
