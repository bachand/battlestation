# Functions for outputting various types of messages to the user.
# Reserve STDOUT for system output.
module Output

  def self.put_success(text)
    $stderr.puts "\e[0;32m" + text + "\e[0m"
  end

  def self.put_error(text)
    $stderr.puts "\e[0;31m" + text + "\e[0m"
  end

  def self.put_info(text)
    $stderr.puts "\e[0m" + text + "\e[0m"
  end

  def self.put_debug(text)
    $stderr.puts text
  end
end
