configure :development do
  set :title, 'Bèr Kessels` pictures'
  set :directory, 'Photos'
end

configure :production do
  set :dbname, 'productiondb'
end

