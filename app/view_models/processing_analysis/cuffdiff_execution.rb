module Processing_Analysis
    class Cuffdiff_Execution < Processing_Analysis::Execution
    
        #Attributes taken from http://cufflinks.cbcb.umd.edu/manual.html for cufflinks 2.0.2
        attr_accessor 
            #Identifier for rails
            :sample_id,
            
           
    
        def initialize(attributes = {})
            #Load in any values from the form
            super(attributes)
        end
    end
end
