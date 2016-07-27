Rails.application.routes.draw do
  get '*path' => 'all#all'
  post '*path' => 'all#all'
  put '*path' => 'all#all'
  patch '*path' => 'all#all'
  delete '*path' => 'all#all'
  match '*path' => 'all#all', via: :options

  get '/' => 'all#all'

  get '/test' => 'all#test'
end
