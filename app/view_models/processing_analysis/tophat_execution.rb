module Processing_Analysis
    class Tophat_Execution #< ActiveRecord::Base
#          has_no_table   #See activerecord-tableless gem
        include ActiveModel::Validations
        include ActiveModel::Conversion
        extend ActiveModel::Naming
         
        # column :name, :string
    
        attr_accessor :ebwt_base, :reads_file, :read_mismatches, 
            :read_gap_length, :read_edit_dist, :read_realign_edit_dist,
            :bowtie1, #colorspace issues?
            :mate_inner_distance, :mate_std_dev, :min_anchor_length,
            :splice_mismatches, :min_intron_length, :max_intron_length,
            :max_insertion_length, :max_deletion_length #Add the rest
        
        validates :field1, :presence => true
        validates :field2, :presence => true
        validates :field3, :presence => true
        
        #has_many :tophat_executions, :dependent => :destroy
        #accepts_nested_attributes_for :tophat_executions
    
        def initialize(attributes = {})
            #Load in any values from the form
            attributes.each do |name, value|
                send("#{name}=", value)
            end
            if (self.field1.nil?)
                self.field1 = "field1_#{self.id}"
            end
            if (self.field2.nil?)
                self.field2 = "field2_#{self.id}"
            end
            if (self.field3.nil?)
                self.field3 = "field3_#{self.id}"
            end
        end
        
        def persisted?
            return false
        end
    end
end
