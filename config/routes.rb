Rails.application.routes.draw do
  post 'webhook', to: 'application#webhook'
end
