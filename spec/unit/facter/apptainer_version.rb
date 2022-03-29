require 'spec_helper'

describe 'apptainer_version fact' do
  before :each do
    Facter.clear
    allow(Facter.fact(:kernel)).to receive(:value).and_return('Linux')
  end

  it 'returns 1.0.1' do
    allow(Facter::Util::Resolution).to receive(:which).with('apptainer').and_return('/usr/bin/apptainer')
    allow(Facter::Util::Resolution).to receive(:exec).with('apptainer version').and_return("1.0.1\n")
    expect(Facter.fact(:apptainer_version).value).to eq('1.0.1')
  end

  it 'handles package not installed' do
    allow(Facter::Util::Resolution).to receive(:which).with('apptainer').and_return(nil)
    expect(Facter.fact(:apptainer_version).value).to be_nil
  end
end
