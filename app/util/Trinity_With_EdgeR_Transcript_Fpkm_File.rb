class Trinity_With_EdgeR_Transcript_Fpkm_File < File
  def readline()
    #call base method and then parse
  end
end

class Trinity_With_EdgeR_Transcript_Fpkm_File_Line
  attr_reader :transcript_name, :fpkm #etc
end
