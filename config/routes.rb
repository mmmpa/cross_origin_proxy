Rails.application.routes.draw do
  match '*path' => 'all#all', via: :all
  match '/' => 'all#all', via: :all
end
