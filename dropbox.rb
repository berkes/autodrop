class DropboxController
  # returns a list of directories in the "containing dir" as set in config. possibly an empty list.
  # or returns nil if an error occurred (e.g. dir is not found)
  def dirs(container)
    valid_dirs = []
    # do not continue if authorisation is false.
    #return nil unless dropbox_session.authorized?

    # if dir is a valid dir
    if dir_is_valid?(container, container)
    # For each directory in that dir
      Dir.foreach(container) do |d|
        # is this dir valid? then add to a list of dirs
        # else, continue, without adding to the list of dirs
        valid_dirs << d if dir_is_valid?(d, container)
      end
    end
    # return the list of dirs, even if it is an empty list.
    return valid_dirs
  end

  # returns a list of images in the given dir: possibly an empty list.
  # or returns nil if an error occurred (e.g. dir is not found)
  def images(dir, container)
    valid_images = []
    # do not continue if authorisation is false.
    #return nil unless dropbox_session.authorized?

    # set dir to absolute: include the containing dir to the path.
    path = "#{container}/#{dir}"
    # if dir is a valid dir
    if (dir_is_valid?(dir, container))
      # then connect to dropbox
      # and fetch the metadata for the dir
      # For each file in that dir
      Dir.glob("#{path}/*.{JPG,png,gif}").each do |img|
        # is the file valid?
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
  # see if an absolute directory, exists, in the right place and is readable.
  def dir_is_valid?(dir, container)
    valid = false
    # is it a valid pattern (i.e. does not contain funny characters)?
    # valid characters are: space, -, _, . A-z and 0-9, must start with alphanumeric
    if /\A[A-z0-9]+[A-z0-9 -_.]*\Z/.match(dir)
      valid = true
    else
      return false
    end

    # does the dir exist and is it a dir?
    if (dir == container)
      path = dir
    else
      path = "#{container}/#{dir}"
    end

    if Dir.new(path)
      valid = true
    else
      return false
    end

    # is the dir public?
      #@TODO not yet implemented

    return valid
  end

  # see if an image exists, in the correct place, is an image, and not a special reserved thumb image.
  def file_is_valid?(file)
    # is it a valid pattern (i.e. does not contain funny characters)?
    # all characters are valid, except for the /, directory limiter., files cannot start with a dot (hidden files)
    # does the file exist?
    # is the file an image?
    # is the file not the special, reserved thumb.*? (see thumb_for_dir)

    return true
  end

  # determines the thumbnail for the dir: looks for tumb.*, if that is an image, else for the latest added image.
  def thumb_for_dir(dir)
    # if the dir contains an image thumb.* return that as thumb
    # else
      # loop trough all images in this dir
      # and return the last added one.
  end
end

