# == Description
#
# Represents a set of data from one run of 
# Use Case 1: Upload Data to the Database. All data associated with an upload 
# operation is directly or indirectly associated with a dataset. Deleting a 
# dataset for an upload operation will also delete all other records from that 
# upload operation because cascading deletions are set for them.
#
#
# == Schema Information
#
# Table name: datasets
#
#  id                      :integer          not null, primary key
#  name                    :string(255)      not null
#  program_used            :string(255)      not null
#  has_transcript_diff_exp :boolean          not null
#  has_transcript_isoforms :boolean          not null
#  has_gene_diff_exp       :boolean          not null
#  finished_uploading      :boolean          not null
#  go_terms_status         :string(255)      not null
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
                  :has_gene_diff_exp,
                  :finished_uploading,
                  :go_terms_status,
                  :program_used
  
  #validates :id, :presence => true
  validates :name, :presence => true
#   validates :has_transcript_diff_exp, 
#       :allow_nil => false,
  validate :has_transcript_diff_exp_is_boolean
#   validates :has_transcript_isoforms, 
#       :allow_nil => false
  validate :has_transcript_isoforms_is_boolean
#   validates :has_gene_diff_exp, 
#       :allow_nil => false,
  validate :has_gene_diff_exp_is_boolean
  validates :user, :presence => true
  validates :blast_db_location, :presence => true
  validate :blast_db_location_pathname_is_valid
  validate :when_last_queried_is_valid_datetime_or_nil
  validates :program_used, 
      :allow_nil => false,
      :inclusion => ['trinity_with_edger', 'cuffdiff', 'generic_fasta_file']
  validates :go_terms_status, :inclusion => [
            'not-applicable','not-started','in-progress','found']
  belongs_to :user
  has_many :transcripts, :dependent => :destroy
  has_many :genes, :dependent => :destroy
  has_many :samples, :dependent => :destroy
  
  private
  def blast_db_location_pathname_is_valid
    begin
      Pathname.new(self.blast_db_location)
    rescue TypeError, ArgumentError
      errors[:blast_db_location] << 'must be a valid pathname'
    end
  end
  
  def has_transcript_diff_exp_is_boolean
    if (self.has_transcript_diff_exp != true and 
        self.has_transcript_diff_exp != false)
      errors[:has_transcript_diff_exp] << 'must be boolean'
    end
  end
  
  def has_transcript_isoforms_is_boolean
    if (self.has_transcript_isoforms != true and 
        self.has_transcript_isoforms != false)
      errors[:has_transcript_isoforms] << 'must be boolean'
    end
  end
  
  def has_gene_diff_exp_is_boolean
    if (self.has_gene_diff_exp != true and 
        self.has_gene_diff_exp != false)
      errors[:has_gene_diff_exp] << 'must be boolean'
    end
  end
  
  def when_last_queried_is_valid_datetime_or_nil
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
