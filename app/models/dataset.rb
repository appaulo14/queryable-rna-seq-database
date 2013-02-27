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
  
  belongs_to :user
  has_many :genes
  has_many :transcripts
  has_many :samples
  
  
end
