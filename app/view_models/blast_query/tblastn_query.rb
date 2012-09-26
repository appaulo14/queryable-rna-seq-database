module Blast_Query
class Tblastn_Query < Blast_Query::Base
    attr_accessor :database_genetic_codes
    
    def initialize(attributes = {})
        #Load in any values from the form
        attributes.each do |name, value|
            send("#{name}=", value)
        end
        if (self.e_value.nil?)
            self.e_value = 10.0
        end
    end
end
end