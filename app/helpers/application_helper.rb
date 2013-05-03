# Contains helpers used within all the controllers 
module ApplicationHelper
    
    # Displays the site logo
    def logo
        logo = image_tag("ksu/powercat-glowing-android.jpg", 
                :alt => "RNA-Seq Analysis pipeline", :class => "logo")
    end
    
    # Displays an indicator that querying is currently in-progress
    def querying_indicator
      return image_tag("querying-indicator.gif", 
                :alt => "querying indicator", :id => :querying_indicator)
    end
    
    # Diplays for the page the help tip with the specified id 
    def help_tip(id, position = :right)
      @controller = request.filtered_parameters['controller']
      @action     = request.filtered_parameters['action']
      return render :partial => 'shared/help_tip', 
                     :locals => {:id => id, :position => position}
    end
    
    # Displays a link with the text 'More Info' to the specified URL
    def more_info_link(url)
      return link_to('More Info', url, :target => '_blank')
    end
end
