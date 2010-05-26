class DropboxController
  # returns a list of directories in the "containing dir" as set in config. possibly an empty list.
  # or returns nil if an error occurred (e.g. dir is not found)
  def dirs
    # do not continue if authorisation is false.
    return nil unless dropbox_session.authorized?

    # fetch the containing dir from local settings
    # if dir is a valid dir
    # For each directory in that dir
      # is this dir valid?
        # then add to a list of dirs
      # else, continue, without adding to the list of dirs

    # return the list of dirs, even if it is an empty list.
  end

  # returns a list of images in the given dir: possibly an empty list.
  # or returns nil if an error occurred (e.g. dir is not found)
  def images (dir)
    # do not continue if authorisation is false.
    return nil unless dropbox_session.authorized?

    # fetch the containing dir from local settings
    # set dir to absolute: include the containing dir to the path.
    # if dir is a valid dir
      # then connect to dropbox
      # and fetch the metadata for the dir
      # For each file in that dir
        # is the file valid?
          # if so, then fetch the metadata for this file
          # and add this file and its metadata to the list of images.
        # if not, continue, without adding to the list of images.
    # else return nil

    # return the list of images, even if it is an empty list.
  end

  private
  # see if a directory, exists, in the right place and is readable.
  def dir_is_valid? (dir)
    # is it a valid pattern (i.e. does not contain funny characters)?
    # does the dir exist?
    # is the dir public?
  end

  # see if an image exists, in the correct place, is an image, and not a special reserved thumb image.
  def file_is_valid? (file)
    # is it a valid pattern (i.e. does not contain funny characters)?
    # does the file exist?
    # is the file an image?
    # is the file not the special, reserved thumb.*? (see thumb_for_dir)
  end

  # determines the thumbnail for the dir: looks for tumb.*, if that is an image, else for the latest added image.
  def thumb_for_dir (dir)
    # if the dir contains an image thumb.* return that as thumb
    # else
      # loop trough all images in this dir
      # and return the last added one.
end

