module ApplicationHelper
    
    def logo
        logo = image_tag("ksu/powercat-glowing-android.jpg", 
                :alt => "RNA-Seq Analysis pipeline", :class => "logo")
    end
    
    def help_tip(id)
      return  image_tag('question_mark.png', :id=> id, 
                                              :alt => "Help tip for #{id}" ) 
    end
    
    def more_info_link(url)
      return link_to('More Information',url, :target => '_blank')
    end
end
