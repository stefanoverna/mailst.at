Mailstat::Application.routes.draw do
  devise_for :users
  root to: "static#home"
end
