# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def tag_cloud(tags, tag_counts, classes)
    return if tags.empty?
    
    max_count = tag_counts.sort.last
    
    index = 0;
    tags.each do |tag|
      level= ((tag_counts[index] / max_count) * (classes.size - 1)).round
      yield tag, classes[level]
      index = index + 1;
    end
  end
  
  def is_admin?
    logged_in? && current_user.role == 'Administrator'
  end
end
