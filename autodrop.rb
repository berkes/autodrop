# autodrop.rb
require 'rubygems'
require 'sinatra'
require 'haml'
require 'dropbox'

require 'configuration'
require 'dropboxcontroller'

get '/' do
  drop = AutodropIndex.new(options)
  @galleries = drop.galleries
  haml :index
end

get '/gallery/:path' do
  @gallery = AutodropGallery.new(params[:path], options)

  return status 404 unless @gallery.valid?

  @title = @gallery.title
  @path = @gallery.path
  haml :gallery
end

get '/gallery/:path/:file' do
  session = Dropbox::Session.deserialize(options.session)
  # do not continue if authorisation is false.
  return status 404 unless session.authorized?

  @image = AutodropImage.new(params[:file], params[:path], options)

  return status 404 unless @image.valid?

  haml :image
end

get '/image/:size/:path/:file' do
  image = AutodropImage.new(params[:file], params[:path], options)

  return status 404 unless image.valid?

  thumb_path = image.mirror_file params[:size]

  send_file(thumb_path)
end

helpers do
  def base_url
    @base_url ||= "#{request.env['rack.url_scheme']}://#{request.env['HTTP_HOST']}"
  end
end

