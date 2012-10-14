module Processing_Analysis
    class Execution #< ActiveRecord::Base
#          has_no_table   #See activerecord-tableless gem
        include ActiveModel::Validations
        include ActiveModel::Conversion
        extend ActiveModel::Naming
        
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
 
