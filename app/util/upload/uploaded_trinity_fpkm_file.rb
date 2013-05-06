###
# Represents an uploaded Trinity fpkm file
class UploadedTrinityFpkmFile
  ###
  # parameters::
  # * <b>uploaded_file:</b> The uploaded file to provide a wrapper for
  def initialize(uploaded_file)
    @uploaded_file = uploaded_file
    @sample_names = @uploaded_file.tempfile.readline.strip.split(/\s+/)
  end

  ###
  # Whether the eof marker has been reached for the file
  def eof?
    return @uploaded_file.tempfile.eof?
  end
  
  ###
  # Get the next TrinityFpkmLine, or nil if the file line could not be 
  # parsed into a TrinityFpkmLine.
  def get_next_line
    line = @uploaded_file.tempfile.readline
    cells = line.split(/\s+/)
    item = cells[0]
    fpkms = cells[1..-1]
    #Validations
    if item.nil? or fpkms.empty?
      return nil
    end
    sample_fpkms = []
    (0..fpkms.count-1).each do |i|
      sample_fpkm = SampleFpkm.new()
      sample_fpkm.sample_name = @sample_names[i]
      sample_fpkm.fpkm = fpkms[i]
      sample_fpkms << sample_fpkm
    end
    return TrinityFpkmLine.new(item,sample_fpkms)
  end
end

###
# Represents a single line of an uploaded Trinity fpkm file
class TrinityFpkmLine
  # The Gene or Transcript name for the line of the fpkm file
  attr_accessor :item
  # The SampleFpkm object(s) for the line of the fpkm file
  attr_accessor :sample_fpkms
end

###
# An fpkm value paired with the name of the sample it belongs to
class SampleFpkm
  # The same name
  attr_accessor :sample_name
  # The fpkm
  attr_accessor :fpkm
end
