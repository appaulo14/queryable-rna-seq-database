module Processing_Analysis
    class Execution_Group #< ActiveRecord::Base
#          has_no_table   #See activerecord-tableless gem
        include ActiveModel::Validations
        include ActiveModel::Conversion
        extend ActiveModel::Naming
         
        # column :name, :string
    
        attr_accessor :name, :executions
        
        #has_many :tophat_executions, :dependent => :destroy
        #accepts_nested_attributes_for :tophat_executions
    
        def initialize(attributes = {})
            #Load in any values from the form
            attributes.each do |name, value|
                send("#{name}=", value)
            end
        end
        
        def persisted?
            return false
        end
    end
end
