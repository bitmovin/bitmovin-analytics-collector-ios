# This file contains helper lane to execute Git commands

class GitHelper
  def self.clone(repo_url:, ssh_key_path:, destination_path:)
    SshHelper.execute_using_ssh(
      key_path: ssh_key_path,
      # TODO remove branch once we have a stable release
      command: "git clone --branch feature/precompiled-binaries #{repo_url} #{destination_path}"
    )
  end

  def self.config_user(name:, email:)
    %x[git config user.name '#{name}' && git config user.email #{email}]
  end

  def self.add_files(files)
    files_joined = files.join(' ')
    %x[git add #{files_joined}]
  end

  def self.commit(message)
    %x[git commit -m '#{message}']
  end

  def self.tag(tag:, message:)
    %x[git tag -a #{tag} -m '#{message}']
  end

  def self.push(ssh_key_path)
    SshHelper.execute_using_ssh(
      key_path: ssh_key_path,
      command: "git push"
    )
  end

  def self.push_tags(ssh_key_path)
    SshHelper.execute_using_ssh(
      key_path: ssh_key_path,
      command: "git push --tags"
    )
  end

  def self.get_all_stable_tags(major_version)
    %x[git --no-pager tag | egrep '^#{major_version}\\.\\d+\\.\\d+$'].to_s.split.to_a
  end
end
