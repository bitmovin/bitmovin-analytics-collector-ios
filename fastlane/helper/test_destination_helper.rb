# This file contains helper code to find test destinations

class TestDestinationHelper
  def self.find_destination(destination:, platform:, version:, is_for_simulator:)
    if destination.nil?
      name = nil
    else
      test_destination = destination
      .split(",")
      .collect { |v| v.split("=") }
      .to_h
      .transform_keys(&:to_sym)

      name = test_destination[:name]
      version = test_destination[:OS]
      platform = test_destination[:platform].delete_suffix(' Simulator')
      is_for_simulator = test_destination[:platform].include?("Simulator")
    end

    device = self.find_test_device(
      name: name,
      platform: platform,
      version: version,
      is_for_simulator: is_for_simulator
    )

    return nil if device.nil?

    device_name, os_version, device_id = device.values_at(:name, :os_version, :id)

    destination_string = self.build_destination(id: device_id)

    sdk = TestDestinationHelper.sdk_name(
      platform: platform,
      is_for_simulator: is_for_simulator
    )

    {
      destination: destination_string,
      device_name: device_name,
      os_version: os_version,
      platform: platform,
      is_for_simulator: is_for_simulator,
      sdk: sdk,
      device_id: device_id
    }
  end

  private

  def self.find_test_device(name:, platform:, version:, is_for_simulator:)
    device_info_pattern = /^(.*) \(([\d\.]+)\) \((.*)\)$/

    devices = %x{xcrun xctrace list devices}
      .lines
      .reject { |line| line.strip.empty? || line.include?('==') }
      .select { |line|
        is_for_simulator ? line.downcase.include?('simulator') : !line.downcase.include?('simulator')
      }
      .reject { |line| line.include?('Watch') }
      .select { |line| line =~ device_info_pattern }

    if name.nil?
      ios_keywords = ["iPhone"]
      tvos_keywords = ["TV"]
      allow_keywords = platform == "iOS" ? ios_keywords : tvos_keywords
      deny_keywords = platform == "iOS" ? tvos_keywords : ios_keywords
      devices_for_version = devices
        .select { |line|
          version_search_token_suffix = version.include?('.') ? '' : '.'
          line.include?("(#{version}#{version_search_token_suffix}")
        }

      preferred_devices = devices_for_version
        .select { |line|
          allow_keywords.any? { |keyword| line.downcase.include?(keyword.downcase) }
        } || devices_for_version

      preferred_devices = preferred_devices
        .select { |line|
          deny_keywords.none? { |keyword| line.downcase.include?(keyword.downcase) }
        }

      device = preferred_devices.first || devices_for_version.first
    else
      device = devices.find { |line| line.include?(name) }
    end

    return nil if device.nil?

    device_info = device.match(device_info_pattern)

    device_name = device_info[1].delete_suffix(' Simulator')
    device_os_version = device_info[2]
    device_id = device_info[3]

    {
      name: device_name,
      os_version: device_os_version,
      id: device_id
    }
  end

  def self.sdk_name(platform:, is_for_simulator:)
    "#{platform.include?("iOS") ? "iphone" : "appletv"}#{is_for_simulator ? "simulator" : "os"}"
  end

  def self.build_destination(id:)
    "id=#{id}"
  end
end
