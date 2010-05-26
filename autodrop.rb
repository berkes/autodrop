# autodrop.rb
require 'rubygems'
require 'sinatra'
require 'haml'
#require 'rdropbox'

require 'configuration'
require 'dropbox'

drop = DropboxController.new

get '/' do
  @galleries = drop.dirs(options.directory)
  haml :index
end

get '/gallery/:path' do
  @images = drop.images(params[:path], options.directory)
  haml :gallery
end

get '/gallery/:path/:file' do
  haml :image
end

get '/style.css' do
  sass :style
end

