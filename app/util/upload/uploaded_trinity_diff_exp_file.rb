###
# Represents an uploaded Trinity differential expression file
class UploadedTrinityDiffExpFile  
  ###
  # parameters::
  # * <b>uploaded_file:</b> The uploaded file to provide a wrapper for
  def initialize(uploaded_file)
    @uploaded_file = uploaded_file
    #Skip the header line
    @uploaded_file.tempfile.readline()
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
class TrinityDiffExpLine
  ###
  # parameters::
  # * <b>#item:</b> the Gene or Transcript name for the line of the 
  #   differential expression file
  # * <b>#log_fold_change:</b> the log fold change for the line of the 
  #   differential expression file
  # * <b>#p_value:</b> the p-value for the line of the differential 
  #   expression file
  # * <b>#fdr:</b> the fdr for the line of the differential expression file
  def initialize(item,log_fold_change,p_value, fdr)
    @item = item
    @log_fold_change = log_fold_change
    @p_value = p_value
    @fdr = fdr
  end

  # The Gene or Transcript name for the line of the differential expression file
  attr_accessor :item
  # The log fold change for the line of the differential expression file
  attr_accessor :log_fold_change
  # The p-value for the line of the differential expression file
  attr_accessor :p_value
  # The fdr for the line of the differential expression file
  attr_accessor :fdr
end
