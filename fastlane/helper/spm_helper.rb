# This file contains helper lane to execute SPM commands

class SpmHelper
  def self.calculate_checksum(binary_path)
    %x[swift package compute-checksum #{binary_path}].to_s.strip
  end

  def self.update_package_swift(package_manifest_template_path:, package_version:, checksum:)
    # Update Package.swift with URL and checksum
    package_swift_contents = File.read(package_manifest_template_path)
      .gsub(/url: "https:\/\/cdn.bitmovin.com\/player\/ios_tvos\/.*\/BitmovinPlayer.zip"/, %{url: "https://cdn.bitmovin.com/player/ios_tvos/#{package_version}/BitmovinPlayer.zip"})
      .gsub(/checksum: ".*"/, %{checksum: "#{checksum}"})
    File.write("Package.swift", package_swift_contents)
  end

  def self.update_readme(package_version:)
    # Update README.md with new version
    readme_contents = File.read("README.md")
      .gsub(/.exact\("\d+\.\d+\.\d+.*"\)/, %{.exact("#{package_version}")})
      .gsub(/https:\/\/cdn.bitmovin.com\/player\/ios_tvos\/.*\/BitmovinPlayer.zip/, %{https://cdn.bitmovin.com/player/ios_tvos/#{package_version}/BitmovinPlayer.zip})
      .gsub(/pod 'BitmovinPlayer', '.*'/, %{pod 'BitmovinPlayer', '#{package_version}'})
    File.write("README.md", readme_contents)
  end
end
