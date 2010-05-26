# autodrop.rb
require 'rubygems'
require 'sinatra'
require 'haml'

get '/' do
  @hello = "World"
  haml :index
end

get '/style.css' do
  sass :style
end

