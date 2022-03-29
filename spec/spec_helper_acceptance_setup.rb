RSpec.configure do |c|
  c.before :suite do
    on hosts, puppet('module', 'install', 'saz-rsyslog', '--version', '5.0.0')
    on hosts, puppet('module', 'install', 'treydock-singularity', '--version', '5.5.0')
  end
end
