module ApplicationHelper
    
    def logo
        logo = image_tag("ksu/powercat-glowing-android.jpg", 
                :alt => "RNA-Seq Analysis pipeline", :class => "logo")
    end
    
    def help_tip(id)
      return  image_tag('question_mark.png', :id=> id, 
                                              :alt => "Help tip for #{id}" ) 
    end
end
