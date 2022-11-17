# frozen_string_literal: true

RSpec.configure do |c|
  c.before :suite do
    on hosts, puppet('module', 'install', 'saz-rsyslog', '--version', '5.0.0')
  end
end

def default_install_method
  return 'source' if fact('os.name') == 'Debian' && fact('os.release.major') == '10'

  'package'
end
