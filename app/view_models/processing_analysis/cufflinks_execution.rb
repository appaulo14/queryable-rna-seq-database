module Processing_Analysis
    class Tophat_Execution < Processing_Analysis::Execution
    
        #Attributes taken from http://tophat.cbcb.umd.edu/manual.html for Tophat 2.0.5
        attr_accessor 
            #Identifier for rails
            :sample_id,
            #Arugments
            
           
    
        def initialize(attributes = {})
            #Load in any values from the form
            super(attributes)
        end
    end
end
