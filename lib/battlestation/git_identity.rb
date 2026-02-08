# frozen_string_literal: true

module Battlestation
  # Validates and writes the per-machine Git identity file.
  # The write action lets us validate early and write later.
  class GitIdentity
    # Deferred write for the identity file. Use after the rest of setup succeeds.
    class WriteAction
      def initialize(path, should_write, git_email)
        @path = path
        @should_write = should_write
        @git_email = git_email
      end

      # Writes the identity file only when it is missing.
      # The email is expected to be validated before creating the action.
      def write_if_needed
        return unless @should_write
        File.write(@path, <<~GITCONFIG)
          [user]
            email = #{@git_email}
        GITCONFIG
      end
    end

    # @param path [String] path to the per-machine identity file.
    def initialize(path = File.expand_path('~/.gitconfig-identity'))
      @path = path
    end

    # Validates that an email is present when the identity file is missing, and
    # returns a write action to run later in the setup flow.
    # @param git_email [String, nil]
    # @return [WriteAction]
    def validate_and_plan_write(git_email)
      git_email = sanitize_email(git_email)
      identity_file_exists = File.exist?(@path)
      if !identity_file_exists && !git_email
        raise 'Valid email is required. Run: ./bin/battlestation setup --git-email you@example.com'
      end

      WriteAction.new(@path, !identity_file_exists, git_email)
    end

    def sanitize_email(git_email)
      return nil if git_email.nil?

      sanitized = git_email.strip
      sanitized.empty? ? nil : sanitized
    end
  end
end
