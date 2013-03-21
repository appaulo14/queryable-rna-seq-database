class UploadedTrinityDiffExpFile
  def initialize(uploaded_file)
    @uploaded_file = uploaded_file
    sample_names_regex = /\A(.+)_vs_(.+).result.txt\z/
    @samples_names = 
      @uploaded_file.original_filename.match(sample_names_regex).captures
  end

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
      sample_fpkm = SampleFpkm.new(:fpkm)
      sample_fpkm.sample_name = sample_names[i]
      sample_fpkm.fpkm = fpkms[i]
      sample_fpkms << sample_fpkm
    end
    return TrinityFpkmLine.new(:item => item, :sample_fpkms => sample_fpkms)
  end
end
