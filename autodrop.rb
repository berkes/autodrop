# autodrop.rb
require 'rubygems'
require 'sinatra'
require 'haml'
#require 'rdropbox'

require 'configuration'

get '/' do
  haml :index
end

get '/style.css' do
  sass :style
end

