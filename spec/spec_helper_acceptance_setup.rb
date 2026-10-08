# frozen_string_literal: true

RSpec.configure do |c|
  c.before :suite do
    install_puppet_module_via_pmt_on(hosts, 'puppet-rsyslog', '7.1.0')
  end
end

def default_install_method
  return 'source' if fact('os.name') == 'Debian' && fact('os.release.major') == '10'

  'package'
end
