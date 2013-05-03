require 'open3'

###
# Utility class containing useful functions for interacting with the system.
class SystemUtil
  # Runs the specified command_string on the system, returning any output and 
  # raising an exception if the command failed.
  # Non-fatal errors are written to the logger.
  def self.backticks!(command_string)
    stdout, stderr, status = Open3.capture3(command_string)
    # Throw an exception if the command failed
    if not status.success?
      raise StandardError, stderr
    end
    # Log any non-fatal errors if they exist
    if not stderr.blank?
      Rails.logger.warn "#{stderr}"
    end
    # Return the result
    return stdout
  end
  
  # Runs the specified command_string on the system, returning true if the 
  # command was successful or raising an exception if the command failed. 
  # Non-fatal errors are written to the logger.
  def self.system!(command_string)
    stdout, stderr, status = Open3.capture3(command_string)
    # Throw an exception if the command failed
    if not status.success?
      raise StandardError, stderr
    end
    # Log any non-fatal errors if they exist
    if not stderr.blank?
      Rails.logger.warn "#{stderr}"
    end
    # Return the result
    return true
  end
end
