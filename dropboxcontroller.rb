class DropboxController
  # Pull sinatra config options into here.
  def initialize(options)
    @options = options
  end

  # returns a list of directories in the "containing dir" as set in config. possibly an empty list.
  # or returns nil if an error occurred (e.g. dir is not found)
  def dirs
    galleries = []
    root_dir = AutodropGallery.new('/', @options)

    # For each directory in that dir
    root_dir.directory.ls.each do |d|
      # is this dir valid? then add to a list of dirs
      # else, continue, without adding to the list of dirs
      gallery = AutodropGallery.new(d.path, @options) if d.directory?

      galleries << gallery
    end

    # return the list of dirs, even if it is an empty list.
    return galleries
  end

  # returns a list of images in the given dir: possibly an empty list.
  # or returns nil if an error occurred (e.g. dir is not found)
  def images(gallery)
    valid_images = []

    session = Dropbox::Session.deserialize(@options.session)
    # do not continue if authorisation is false.
    return nil unless session.authorized?

    # fetch the metadata for the dir
    dir = session.directory("/#{gallery}")

    # is it a dir?
    if list = dir.ls
      # For each file in that dir
      list.each do |file|
        img = AutodropImage.new(file, gallery, @options)
        # if so, then fetch the metadata for this file
        # and add this file and its metadata to the list of images.
        valid_images << img if img.valid?
        # if not, continue, without adding to the list of images.
      end
    else
      # else return false
      return nil
    end
    # return the list of images, even if it is an empty list.
    return valid_images
  end

  def image(gallery, filename)
    session = Dropbox::Session.deserialize(@options.session)
    # do not continue if authorisation is false.
    return nil unless session.authorized?

    img = session.entry("/#{gallery}/#{filename}").metadata
    img = AutodropImage.new(img, gallery, @options)

    if img.valid?
      return img
    else
      return nil
    end
  end

  def mirror_file(path, file, size = 'm')
    img = AutodropImage.new(file, path, @options)
    img.mirror_file size
  end
end

# Contains an autodrop image object
# @TODO: fetch and parse exif and png comments and info
class AutodropImage
  attr_reader :file, :gallery

  def initialize(file, gallery, options={})
    @file = file
    @gallery = gallery
    @options = options
  end

  # parse name, to human readable name
  def title
    #Flip off the part after the last dot, including that dot: find the filename without extensions
    fragments = basename.split('.')
    fragments.pop
    title = fragments.join('.')

    return title.gsub(/[_+]/, ' ').capitalize
  end

  def src(size = 'm')
    "#{@options.base_url}/image/#{size}#{@file.path}"
  end

  def path
    @file.path
  end

  def permalink
    "/gallery/#{@gallery}/#{basename}"
  end

  # see if an image exists, in the correct place, is an image, and not a special reserved thumb image.
  def valid?
    # is it a valid pattern (i.e. does not contain funny characters)? @TODO
    # all characters are valid, except for the /, directory limiter., files cannot start with a dot (hidden files)
    # is the file a web-savvy image?
    valid_types = ['image/jpeg', 'image/png', 'image/gif']
    return false unless valid_types.include? @file.mime_type
    # does the file have thumbnails?
    return false unless @file.thumb_exists
    # is the file not the special, reserved thumb.*? (see thumb_for_dir)
    # @TODO: return false if basename.match /^thumb\.[A-z]*$/
    return true
  end

  def dirname
    base = @file.path.split('/').shift
    base.join('/')
  end

  def basename
    @file.path.split('/').pop
  end

  # If local file do not exist, mirror it from dropbox, and return local filename
  # Else just return the local filename
  def mirror_file(size)
    # only allow whitelisted sizes.
    return nil unless ['m', 'l'].include? size

    require 'ftools'

    #TODO DRY
    session = Dropbox::Session.deserialize(@options.session)
    # do not continue if authorisation is false.
    return nil unless session.authorized?

    basedir = "#{@options.cache_dir}/#{gallery}/#{size}"
    File.makedirs(basedir) unless File.exists?(basedir)
    filepath = "#{basedir}/#{@file}"
    drop_path = "#{@gallery}/#{@file}"
    if not File.exists? filepath
      body = session.thumbnails(drop_path, size)
      File.open(filepath, 'w') {|f| f.write(body) }
    end

    return filepath
  end
end

class AutodropGallery
  attr_reader :gallery
  def initialize(gallery, options)
    @gallery = gallery
    @options = options

    @session = Dropbox::Session.deserialize(@options.session)
    # do not continue if authorisation is false.
    # @TODO raise error, not return nil /# return nil unless session.authorized?
  end

  def directory
    @session.directory(@gallery)
  end

  # parse name, to human readable name
  # @TODO: DRY!
  def title
    return @gallery.gsub(/[_+]/, ' ').capitalize
  end

  def thumb(size = 'm')
    thumb = mirror_thumbnail
    return thumb
  end

  def path
    File.join('gallery', @gallery)
  end

  private
  def mirror_thumbnail
    imgs =[]
    # connect to remote, open dir, list entries
    entries = @session.directory(@gallery).ls.sort{|a, b| a.modified <=> b.modified }
    entries.each do |entry|
      if not entry.is_dir #is marked on dropbox as file
        if entry.thumb_exists #only TRUE when it is a file and omits many none-images
          # is that a valid image?
          img = AutodropImage.new(entry, @gallery, @options)
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

