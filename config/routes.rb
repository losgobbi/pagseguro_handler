Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  match '/purchases', to: 'purchases#new', :via => [:post]
  match '/notifications', to: 'notifications#create', :via => [:post]
end
