# autodrop.rb
require 'rubygems'
require 'sinatra'
require 'haml'
#require 'rdropbox'

require 'configuration'

get '/' do
  haml :index
end

get '/gallery/:path' do
  haml :gallery
end

get '/gallery/:path/:file' do
  haml :image
end

get '/style.css' do
  sass :style
end

