configure :development do
  set :title, 'berkes` pictures'
  set :cache_dir, 'photos'

  #You can get a serialised session by running authenticate.rb (@TODO)
  set :session, '---
- 7rwsnb6d5s2w6o1
- aesfhfq4l5d87ct
- true
- 7zwb9eoh4rva1r4
- rpqo56luhrmdmhn'
end

configure :production do
  set :dbname, 'productiondb'
end

