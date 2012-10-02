module ApplicationHelper
    
    def logo
        logo = image_tag("powercat-glowing-android.jpg", :alt => "RNA-Seq Analysis pipeline", :class => "logo")
    end
    def busy_indicator
        busy_indicator = image_tag("rna.gif", :alt => "RNA-Seq Analysis pipeline", :class => "busy_indicator")
    end
end
