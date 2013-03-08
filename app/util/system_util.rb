class System_Util
  def backticks!(command_string)
    stdout, stderr, status = Open3.capture3(command_string)
     if stderr.blank?
       return stdout
     else
       raise StandardError, stderr
     end
  end
  
  def system!(command_string)
     stdout, stderr, status = Open3.capture3(command_string)
     if stderr.blank?
       return true
     else
       raise StandardError, stderr
     end
  end
end
