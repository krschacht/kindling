ActionController::Routing::Routes.draw do |map|
  map.resources :forums
  map.resources :topics
  map.resources :posts
end
