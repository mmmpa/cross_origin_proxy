Rails.application.routes.draw do
  get '/clear' => 'all#clear'
  match '*path' => 'all#all', via: :all
end
