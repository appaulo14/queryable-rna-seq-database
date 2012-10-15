module Processing_Analysis
    class Cuffcompare_Execution < Processing_Analysis::Execution
    
        #Attributes taken from theeeeeee "Usage" output displayed when 
        #       running cuffcompare with no arguments or options
        attr_accessor :sample_id, #Identifies this unique sample, not a cuffcompare argument 
            #Arugments
            :input_gtfs,
            #Options
            :r, :r_gtf, :R, :M, :N, :s, :d, :p, :C, :G
           
    
        def initialize(attributes = {})
            #Load in any values from the form
            super(attributes)
        end
    end
end
