# This file contains helper lane to work within the project directory

class DirectoryHelper
  @@project_root = nil

  def self.project_root
    return @@project_root unless @@project_root.nil?

    current_folder = Dir.pwd
    @@project_root = current_folder.slice(0..current_folder.index('/fastlane'))
  end
end
