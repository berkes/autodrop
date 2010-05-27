# autodrop.rb
require 'rubygems'
require 'sinatra'
require 'haml'
require 'dropbox'

require 'configuration'
require 'dropboxcontroller'

get '/' do
  drop = DropboxController.new(options)
  @galleries = drop.dirs
  haml :index
end

get '/gallery/:path' do
  @images = drop.images(params[:path])
  haml :gallery
end

get '/gallery/:path/:file' do
  @image = AutodropImage.new("#{options.directory}/#{params[:path]}/#{params[:file]}")
  haml :image
end

get '/style.css' do
  sass :style
end

