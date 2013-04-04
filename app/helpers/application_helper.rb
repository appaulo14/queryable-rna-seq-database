module ApplicationHelper
    
    def logo
        logo = image_tag("ksu/powercat-glowing-android.jpg", 
                :alt => "RNA-Seq Analysis pipeline", :class => "logo")
    end
    
    #TODO: Delete after replacing everywhere
    def help_tip(id)
      return  image_tag('question_mark.png', :id=> id, 
                                              :alt => "Help tip for #{id}" ) 
    end
    
    def help_tip2(id, position)
      return render :partial => 'shared/help_tip', 
                     :locals => {:id => id, :position => position}
    end
    
    def more_info_link(url)
      return link_to('More Info',url, :target => '_blank')
    end
    
    def more_info_link_to_wiki(path)
      return link_to('More Information', "https://github.com/fatPerlHacker/" +
                                    "queryable-rna-seq-database/wiki/#{path}")
    end
end
