class AutodropIndex
  # Pull sinatra config options into here.
  def initialize(options, session=nil)
    @options = options

    if session and session.authorized?
      @session = session
    else
      @session = Dropbox::Session.deserialize(@options.session)
      @session.enable_memoization if options.memoization
    end
  end

  # returns a list of directories in the "containing dir" as set in config. possibly an empty list.
  # or returns nil if an error occurred (e.g. dir is not found)
  def build_galleries
    galleries = []
    root_dir = AutodropGallery.new('/', @options, @session)

    # For each directory in that dir
    root_dir.directory.ls.each do |d|
      # is this dir valid? then add to a list of dirs
      # else, continue, without adding to the list of dirs
      gallery = AutodropGallery.new(d.path, @options, @session) if d.directory?
      gallery.build_gallery
      galleries << gallery if gallery.valid?
    end

    # return the list of dirs, even if it is an empty list.
    return galleries
  end

  #hackish quick solution to boost performance. Will be dealt with in future rewrite.
  def galleries
    galleries = []
    Dir.glob("#{@options.cache_dir}/*").each do |path| 
      name = path.split('/').last
      puts name
      gallery = {}
      gallery[:title] = name.gsub(/[_]/, ' ').capitalize
      puts (gallery[:path] = "gallery/#{name}")
      thumb = Dir.glob("#{path}/*/thumb.*").first
      thumb = Dir.glob("#{path}/*/*.*").first unless thumb # else take the first image.
      thumb = thumb.split('/').last
      puts (gallery[:thumb] = "image/m/#{name}/#{thumb}")
      galleries << gallery
    end
    galleries
  end
end

# Contains an autodrop image object
# @TODO: fetch and parse exif and png comments and info
class AutodropImage
  require 'ftools'

  attr_reader :filename, :gallery, :path, :src
  def initialize(filename, gallery, options={}, session=nil)
    @filename = basename filename
    @gallery = gallery
    @options = options

    @path = File.join(@gallery, @filename)
    if session and session.authorized?
      @session = session
    else
      @session = Dropbox::Session.deserialize(@options.session)
      @session.enable_memoization if options.memoization
    end
    @entry = @session.entry(@path)
  end

  # parse name, to human readable name
  def title
    #Flip off the part after the last dot, including that dot: find the filename without extensions
    fragments = @filename.split('.')
    fragments.pop
    title = fragments.join('.')

    return title.gsub(/[_]/, ' ').capitalize
  end

  def src(size = 'm')
    "#{base_url}/image/#{size}/#{@path}"
  end

  def permalink
    "/gallery/#{@path}"
  end

  # see if an image exists, in the correct place, is an image, and not a special reserved thumb image.
  def valid?
    # is it a valid pattern (i.e. does not contain funny characters)? @TODO
    # all characters are valid, except for the /, directory limiter., files cannot start with a dot (hidden files)
    # is the file a web-savvy image?
    valid_types = ['image/jpeg', 'image/png', 'image/gif']
    return false unless valid_types.include? @entry.metadata.mime_type
    # does the file have thumbnails?
    return false unless @entry.metadata.thumb_exists
    # is the file not the special, reserved thumb.*? (see thumb_for_dir)
    # @TODO: return false if basename.match /^thumb\.[A-z]*$/
    return true
  end

  # If local file do not exist, mirror it from dropbox, and return local filename
  # Else just return the local filename
  def mirror_file(size)
    # only allow whitelisted sizes.
    return nil unless ['m', 'l'].include? size

    basedir = "#{@options.cache_dir}/#{gallery}/#{size}"
    File.makedirs(basedir) unless File.exists?(basedir)
    filepath = "#{basedir}/#{@filename}"
    drop_path = "#{@gallery}/#{@filename}"
    if not File.exists? filepath
      body = @session.thumbnail(drop_path, size)
      File.open(filepath, 'w') {|f| f.write(body) }
    end

    return filepath
  end

  private
  def basename(filename)
    if filename.include?('/')
      return filename.split('/').pop
    else
      return filename
    end
  end

end

class AutodropGallery
  attr_reader :gallery, :entry
  def initialize(gallery, options, session=nil)
    @gallery = gallery
    @options = options

    if session and session.authorized?
      @session = session
    else
      @session = Dropbox::Session.deserialize(@options.session)
      @session.enable_memoization if options.memoization
    end
  end
  
  def build_gallery
    images.each do |image|
      image.mirror_file('m')
    end
  end
  
  def directory
    @session.directory(@gallery)
  end

  def images
    valid_images =[]
    @session.directory(@gallery).ls.each do |file|
      img = AutodropImage.new(file.path, gallery, @options, @session)
      # if so, then fetch the metadata for this file
      # and add this file and its metadata to the list of images.
      valid_images << img if img.valid?
      # if not, continue, without adding to the list of images.
    end
    return valid_images
  end

  # parse name, to human readable name
  def title
    return @gallery.gsub(/[_]+/, ' ').capitalize
  end

  def thumb(size = 'm')
    thumb = find_thumbnail
    return thumb
  end

  def path
    File.join('gallery', @gallery)
  end

  def valid?
   #ignore hidden directories
   return nil if /^\.|[\+]/.match @gallery
   #does the directory hold any files?
   entries = @session.directory(@gallery).ls
   return nil if entries.size <= 0
   #is at least one of those files a valid image?
   entries.each do |entry|
     img = AutodropImage.new(entry.path, @gallery, @options)
     return true if img.valid?
   end

   return nil
  end

  private
  def find_thumbnail
    imgs =[]
    # connect to remote, open dir, list entries
    entries = @session.directory(@gallery).ls.sort{|a, b| a.modified <=> b.modified }
    entries.each do |entry|
      if not entry.is_dir #is marked on dropbox as file
        if entry.thumb_exists #only TRUE when it is a file and omits many none-images
          # is that a valid image?
          img = AutodropImage.new(entry.path, @gallery, @options, @session)
          if img.valid?
            # is there a file with name thumb.*
            if /thumb\.[A-z]$/.match entry.path
              return img.src
            else # take the last added image (in time) from that dir
              imgs << img
            end #thumb.jpg or not thumb.jpg
          end #valid image
        end #file has thumb
      end #is_file
    end #each

    return imgs.last.src if imgs.size > 0
  end
end

