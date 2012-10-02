module Processing_Analysis
    class Tophat_Execution #< ActiveRecord::Base
        #has_no_table
        #column :name, :string
        include ActiveModel::Validations
        include ActiveModel::Conversion
        extend ActiveModel::Naming
        
        attr_accessor :name,:index
        #belongs_to :execution_group
    end
    
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