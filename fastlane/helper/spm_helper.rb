# This file contains helper lane to execute SPM commands

class SpmHelper
  def self.calculate_checksum(binary_path)
    %x[swift package compute-checksum #{binary_path}].to_s.strip
  end

  def self.update_package_swift(package_manifest_template_path:, package_version:, target:, checksum:)
    # Update Package.swift with URL and checksum
    package_swift_contents = File.read(package_manifest_template_path)
      .gsub(/url: "https:\/\/cdn.bitmovin.com\/player\/ios_tvos\/.*\/#{target}.zip"/, %{url: "https://cdn.bitmovin.com/player/ios_tvos/#{package_version}/#{target}.zip"})
      .gsub(/checksum: "#{target}-.*"/, %{checksum: "#{checksum}"})
    File.write("Package.swift", package_swift_contents)
  end
end
