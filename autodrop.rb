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
  drop = DropboxController.new(options)
  @images = drop.images(params[:path])
  p @images
  haml :gallery
end

get '/gallery/:path/:file' do
  set :base_url, "#{request.env['rack.url_scheme']}://#{request.env['HTTP_HOST']}"
  drop = DropboxController.new(options)
  @image = drop.image(params[:path], params[:file], options)
  haml :image
end

get '/style.css' do
  sass :style
end

