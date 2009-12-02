# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def show_fb_session_data
    facebooker_session = @facebook_session.clone
    facebooker_session.instance_variable_set("@secret_key",'xxxxxxxxxxxxxxxxxxx')
    facebooker_session.to_yaml
  end
end
