require 'open3'

class SystemUtil
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
