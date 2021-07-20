Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  # root to: 'api/v1/login#spotify_request'
  post '/', to: "api/v1/users#create"
  namespace :api do
    namespace :v1 do
      get '/login', to: "login#spotify_request"
      get '/auth', to: "login#show"
      get '/user', to: "users#create"
    end
  end
end
