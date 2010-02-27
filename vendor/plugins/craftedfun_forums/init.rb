# Incorporate our helpers at plugin startup
config.to_prepare do
  [MiniAppHelper, TopicsHelper, ForumsHelper, PostsHelper].each do |helper_module|
    ApplicationController.helper(helper_module)
  end
end


