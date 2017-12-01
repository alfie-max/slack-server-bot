Rails.application.routes.draw do
  root 'slack#install'
  get :slack_oauth, to: 'slack#oauth', as: :slack_oauth
end
