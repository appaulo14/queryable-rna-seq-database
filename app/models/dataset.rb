# == Schema Information
#
# Table name: datasets
#
#  id                      :integer          not null, primary key
#  name                    :string(255)      not null
#  has_transcript_diff_exp :boolean          not null
#  has_transcript_isoforms :boolean          not null
#  has_gene_diff_exp       :boolean          not null
#  blast_db_location       :string(255)      not null
#  user_id                 :integer          not null
#  when_last_queried       :datetime
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#

class Dataset < ActiveRecord::Base
  attr_accessible :user, 
                  :name, 
                  :blast_db_location, 
                  :has_transcript_diff_exp,
                  :has_transcript_isoforms,
                  :has_gene_diff_exp
  
  #validates :id, :presence => true
  validates :name, :presence => true
  validates :has_transcript_diff_exp, 
      :allow_nil => false,
      :inclusion => {:in => [true, false]}
  validates :has_transcript_isoforms, 
      :allow_nil => false,
      :inclusion => {:in => [true, false]}
  validates :has_gene_diff_exp, 
      :allow_nil => false,
      :inclusion => {:in => [true, false]}
  validates :user, :presence => true
  validates :blast_db_location, :presence => true
  validate :blast_db_location_pathname_is_valid
  validate :when_last_queried_is_valid_datetime
  
  belongs_to :user
  has_many :genes
  has_many :transcripts
  has_many :samples
  
  private
  def blast_db_location_pathname_is_valid
    begin
      Pathname.new(self.blast_db_location)
    rescue TypeError, ArgumentError
      errors[:blast_db_location] << 'must be a valid pathname'
    end
  end
  
  def when_last_queried_is_valid_datetime
    #We want to allow nils
    return if self.when_last_queried.nil?
    #See if when_last_queried is parseable to a datetime
    begin
      DateTime.parse(self.when_last_queried.to_s)
    rescue TypeError, ArgumentError     
      errors[:when_last_queried] << 'must be a valid datetime'
    end
  end
end
