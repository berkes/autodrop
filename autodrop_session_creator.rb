# File to generate a copy-pastable sessionstring. For use in configuration.rb

require 'rubygems'
require 'dropbox'

puts "Welcome to Autodrop. Here you create a new authorised session string.
      * visit http://dropbox.com/developers to apply for a key.
      * After that, add an app at https://www.dropbox.com/developers/apps.
      * This new app will have a consumer key+secret. Those are needed."

puts "your consumer key: "
key = gets.chomp
puts "your consumer secret: "
secret = gets.chomp
puts "attempt to authorize #{key} #{secret} combination"
session = Dropbox::Session.new(key, secret)

puts "Visit #{session.authorize_url} to log in to Dropbox. Hit enter when you have done this."
gets

session.authorize

root_dir = File.dirname(__FILE__)
conf_file = File.join(root_dir, 'configuration.rb')
conf_file = File.expand_path(conf_file)
puts "Copy paste the key below into #{conf_file}. (Including the ---): \n"

puts session.serialize

