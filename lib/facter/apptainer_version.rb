# frozen_string_literal: true

# apptainer_version.rb

Facter.add(:apptainer_version) do
  confine kernel: 'Linux'

  setcode do
    version = nil
    if Facter::Util::Resolution.which('apptainer')
      version = Facter::Util::Resolution.exec('apptainer version')
      version&.strip!
    end
    version
  end
end
