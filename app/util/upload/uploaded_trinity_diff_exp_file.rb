class UploadedTrinityDiffExpFile
  
  attr_accessor :sample_names
  
  def initialize(uploaded_file)
    @uploaded_file = uploaded_file
    sample_names_regex = /\A(.+)_vs_(.+)[.]results[.]txt/
    @sample_names = 
      @uploaded_file.original_filename.match(sample_names_regex).captures
    #Skip the header line
    @uploaded_file.tempfile.readline
  end

  def eof?
    return @uploaded_file.tempfile.eof?
  end
  
  def get_next_line
    line = @uploaded_file.tempfile.readline.strip
    return nil if line.blank?
    (item, logConc, log_fold_change, p_value, fdr) = line.split(/\s+/)
    return TrinityDiffExpLine.new(item,log_fold_change,p_value, fdr)
  end
end

class TrinityDiffExpLine < Struct.new :item, :log_fold_change, :p_value, :fdr
end
