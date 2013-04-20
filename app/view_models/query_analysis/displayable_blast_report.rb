require 'bio'

class DisplayableBlastReport < Bio::Blast::Report
  def initialize(data, parser = nil)
    super
    #Loop through hsps, replacing them with displayable hsps
    @reports.each do |report|
      report.iterations.each do |iteration|
        iteration.hits.each do |hit|
          hit.hsps = displayable_hsps
        end
      end
    end
  end
end

class DisplayableHSP < Bio::Blast::Report::Hsp
  attr_accessor :display_parts
  
  def initialize()
    super
    initialize_display_parts()
  end
  
  def initialize_display_parts()
  end
end

class HSPDisplayPart
  attr_accessor :tooltip
end
