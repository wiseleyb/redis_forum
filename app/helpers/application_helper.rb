# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def user_display(u)
    "#{u.name} T:#{u.topic_count} P:#{u.post_count}"
  end

end
