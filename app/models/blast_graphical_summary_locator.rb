# == Schema Information
#
# Table name: blast_graphical_summary_locators
#
#  basename              :string(255)      not null, primary key
#  html_output_file_path :text             not null
#  dataset_id            :integer          not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#

class BlastGraphicalSummaryLocator < ActiveRecord::Base
  attr_accessible :basename, :dataset, :html_output_file_path
  self.primary_key = :basename
  
  belongs_to :dataset
end
