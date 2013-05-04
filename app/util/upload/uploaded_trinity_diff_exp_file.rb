###
# Represents an uploaded Trinity differential expression file
class UploadedTrinityDiffExpFile  
  ###
  # parameters::
  # * <b>uploaded_file:</b> The uploaded file to provide a wrapper for
  def initialize(uploaded_file)
    @uploaded_file = uploaded_file
    #Skip the header line
    @uploaded_file.tempfile.readline
  end
  
  ###
  # Whether the eof marker has been reached for the file
  def eof?
    return @uploaded_file.tempfile.eof?
  end
  
  ###
  # Get the next TrinityDiffExpLine, or nil if the file line could not be 
  # parsed into a TrinityDiffExpLine.
  def get_next_line
    line = @uploaded_file.tempfile.readline.strip
    return nil if line.blank?
    (item, logConc, log_fold_change, p_value, fdr) = line.split(/\s+/)
    return TrinityDiffExpLine.new(item,log_fold_change,p_value, fdr)
  end
end

###
# Represents a single line of an uploaded Trinity differential expression file
class TrinityDiffExpLine < Struct.new :item, :log_fold_change, :p_value, :fdr
end
