# Functions for outputting various types of messages to the user.
module Output

  def self.put_success(text)
    $stdout.puts "\e[0;32m" + text + "\e[0m"
  end

  def self.put_error(text)
    $stderr.puts "\e[0;31m" + text + "\e[0m"
  end

  def self.put_info(text)
    $stdout.puts "\e[0m" + text + "\e[0m"
  end
end
