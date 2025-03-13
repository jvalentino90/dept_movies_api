Rails.application.routes.draw do
  namespace :dept do
    namespace :v1 do
      get 'movies', to: 'movies#index'
      get 'movies/:id/trailers', to: 'movies#trailers'
    end
  end
end