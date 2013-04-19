require 'bio'

class DisplayableBlastReport < Bio::Blast::Report
  def initialize(data, parser = nil)
    super
    
    
  end
end

class DisplayableHSP < Bio::Blast::Report::Hsp
  attr_accessor :display_parts
  
  def initialize()
    super
  end
end

class HSPDisplayPart
  attr_accessor :tooltip
end
