Mailstat::Application.routes.draw do
  devise_for :users
  resources :mailboxes
  match "/dashboard" => "static#dashboard"
  root to: "static#home"
end
