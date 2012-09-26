module Blast_Query
class Blastn_Query < Blast_Query::Base
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