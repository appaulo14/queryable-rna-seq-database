class BlastGraphicalSummaryLocator < ActiveRecord::Base
  attr_accessible :basename, :dataset, :html_output_file_path
  self.primary_key = :basename
  
  belongs_to :dataset
end
