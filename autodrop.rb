# autodrop.rb
require 'rubygems'
require 'sinatra'
require 'haml'
require 'dropbox'

require 'configuration'
require 'dropboxcontroller'

get '/' do
  set :base_url, "#{request.env['rack.url_scheme']}://#{request.env['HTTP_HOST']}"
  drop = DropboxController.new(options)
  @galleries = drop.dirs
  haml :index
end

get '/gallery/:path' do
  set :base_url, "#{request.env['rack.url_scheme']}://#{request.env['HTTP_HOST']}"
  drop = DropboxController.new(options)
  @gallery = drop.images(params[:path])
  @title = @gallery.title
  @path = @gallery.path
  haml :gallery
end

get '/gallery/:path/:file' do
  set :base_url, "#{request.env['rack.url_scheme']}://#{request.env['HTTP_HOST']}"
  drop = DropboxController.new(options)
  @image = drop.image(params[:path], params[:file])
  haml :image
end

get '/image/:size/:path/:file' do
  set :base_url, "#{request.env['rack.url_scheme']}://#{request.env['HTTP_HOST']}"
  drop = DropboxController.new(options)
  thumb_path = drop.mirror_file(params[:path], params[:file], params[:size])

  send_file(thumb_path)
end

