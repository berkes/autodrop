# autodrop.rb
require 'rubygems'
require 'sinatra'
require 'haml'
#require 'rdropbox'

require 'configuration'

get '/' do
  @hello = "World"
  @at_title = options.title
  haml :index
end

get '/style.css' do
  sass :style
end

