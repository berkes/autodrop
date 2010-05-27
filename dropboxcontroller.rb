class DropboxController
  # Pull sinatra config options into here.
  def initialize(options)
    @options = options
  end

  # returns a list of directories in the "containing dir" as set in config. possibly an empty list.
  # or returns nil if an error occurred (e.g. dir is not found)
  def dirs
    valid_dirs = []
    session = Dropbox::Session.deserialize(@options.session)
    # do not continue if authorisation is false.
    return nil unless session.authorized?

    # For each directory in that dir
    dir = session.directory('/')
    dir.ls.each do |d|
      # is this dir valid? then add to a list of dirs
      # else, continue, without adding to the list of dirs
      valid_dirs << d.path.sub( /^\//, '') if d.directory?
    end

    # return the list of dirs, even if it is an empty list.
    return valid_dirs
  end

  # returns a list of images in the given dir: possibly an empty list.
  # or returns nil if an error occurred (e.g. dir is not found)
  def images(dir)
    valid_images = []
    # do not continue if authorisation is false.
    #return nil unless dropbox_session.authorized?

    # set dir to absolute: include the containing dir to the path.
    path = "#{container}/#{dir}"
    # if dir is a valid dir
    if (dir_is_valid?(dir))
      # then connect to dropbox
      # and fetch the metadata for the dir
      # For each file in that dir
      Dir.glob("#{path}/*.{jpg,png,gif}", File::FNM_CASEFOLD).each do |file|
        # is the file valid?
        img = AutodropImage.new(file)
          # if so, then fetch the metadata for this file
          # and add this file and its metadata to the list of images.
          valid_images << img
          p img
        # if not, continue, without adding to the list of images.
      end
    else
      # else return false
      return nil
    end
    # return the list of images, even if it is an empty list.
    return valid_images
  end

  private

  # determines the thumbnail for the dir: looks for tumb.*, if that is an image, else for the latest added image.
  def thumb_for_dir(dir)
    # if the dir contains an image thumb.* return that as thumb
    # else
      # loop trough all images in this dir
      # and return the last added one.
  end
end

# Contains an autodrop image object
# @TODO: fetch and parse exif and png comments and info
class AutodropImage
  attr_reader :filepath, :filename, :dirname

  def initialize(filepath)
    @filepath = filepath
    @dirname = File.dirname(filepath)
    @basename = File.basename(filepath)
  end

  # parse name, to human readable name
  def title
    #Flip off the part after the last dot, including that dot: find the filename without extensions
    fragments = @basename.split('.')
    fragments.pop
    title = fragments.join('.')

    return title.gsub(/[_+]/, ' ').capitalize
  end

  def src
    "/#{@filepath}"
  end

  def permalink
    path = without_container
    p path
    "/gallery/#{path}/#{@basename}"
  end

  # see if an image exists, in the correct place, is an image, and not a special reserved thumb image.
  def valid?(file)
    # is it a valid pattern (i.e. does not contain funny characters)?
    # all characters are valid, except for the /, directory limiter., files cannot start with a dot (hidden files)
    # does the file exist?
    # is the file an image?
    # is the file not the special, reserved thumb.*? (see thumb_for_dir)
    return true
  end

  private
  def without_container
    fragments = @dirname.split('/')
    p fragments.shift
    title = fragments.join('/')
  end
end

