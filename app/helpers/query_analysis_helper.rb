module QueryAnalysisHelper
  def ascending_sort_arrow
    return image_tag('ascending_sort_arrow.png', :class => 'sort_arrow')
  end
  
  def descending_sort_arrow
    return image_tag('descending_sort_arrow.png', :class => 'sort_arrow')
  end
  
  def neutral_sort_arrow
    return image_tag('neutral_sort_arrow.png', :class => 'sort_arrow')
  end
end
