Rails.application.routes.draw do

  root 'splash#splash'

  match ':controller(/:action.:format)', controller: /api\/v1\/[^\/]+/, via: [:get, :post, :options]

  get 'splash/modal' => 'splash#modal'

  get 'course/modal' => 'courses#modal'

  get 'verify' => 'splash#verify'

  get 'nitza' => 'scores#generate'

  resources :courses

  resources :professors

  resources :scores

  resources :groups

  resources :users

  resources :splash

  resources :sessions

  resources :dashboard

end