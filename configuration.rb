configure :development do
  set :title, 'berkes` pictures'
  set :cache_dir, 'photos'

  #You can get a serialised session by running authenticate.rb (@TODO)
  set :session, '---
- t6cwpu5xvnz4g7w
- te9am1crwb8thiy
- true
- 9g55mvnqycbkswc
- pkbexjkmdirzyur'
end

configure :production do
  set :dbname, 'productiondb'
end

