# This file contains helper lane to execute Bash commands with given SSH key added to the agent

class SshHelper
  def self.execute_using_ssh(key_path:, command:)
    if key_path.to_s.strip.empty?
      UI.error "Error: parameter `key_path` is empty!"
      exit(1)
    end

    if command.to_s.strip.empty?
      UI.error "Error: parameter `command` is empty!"
      exit(1)
    end

    if File.exists?(key_path)
      %x[ssh-agent sh -c "chmod 0600 #{key_path}; ssh-add #{key_path}; #{command}"]
    else
      %x[#{command}]
    end
  end

  def self.ensure_ssh_key(key_path:, ssh_key:)
    unless File.exists?(key_path)
      unless ssh_key.to_s.strip.empty?
        File.write(key_path, "-----BEGIN OPENSSH PRIVATE KEY-----\n")
        File.write(key_path, ssh_key, mode: "a")
        File.write(key_path, "\n-----END OPENSSH PRIVATE KEY-----\n", mode: "a")
      end
    end
  end
end
