# Autodrop

A (very) simple webapp on [Sintara](http://www.sinatrarb.com/) with rbdropbox to render an imagegallery with images from dropbox.
With only two configuration-options, and no admin, or login, it is extremely simple and opinionated. We keep it that. If you need features that are not in this gallery, you probably want other gallery management software.

It runs [my own gallery](http://gallery.webschuur.com)

[Autodrop](http://www.autodrop.nl/), bytheway, is very lekker.

## Eat some

1. Upload images to a special folder in dropbox.
1. Organize foto's by placing them in directories. Each directory is a gallery.
1. Move, rename, delete or publish new ones, by organising them on your desktop (dropbox).
1. That's it, no tags, no descriptions, no databases, no conversion tools, no large storage servers, nothing.

## Installation
* Find and install all required gems: sinatra, haml, dropbox. If you want to change CSS, you need SASS.
* Create configuration.rb from configuration.rb.example. Change some options in configuration.rb if you want to personalise the site.
* Run dropbox authentication _autodrop\_session\_creator.rb_, copy the serialised auth key to configuration.rb.
* Optionally change the haml and sass in views/ to change the style.

## Usage

* add directories: each directory becomes a gallery
* optionally add a file thumb.jpg (or thumb.png/gif etc) to have that show up as thumbnail for the gallery.
* add other images to the directory: as many as you want.


## Tips and Gotcha's

* underscores (_) in file and directorynames will be replaced with spaces in output.
* pluses in files give trouble with the API, don't use them. Files with pluses will be ignored.
* To hide a directory, start a directory with a dot, on unix (linux, mac) these are hidden directories.

## @TODO and known bugs

* Clean up!
* Next and previous links on full image view.
* Prettier design :).
* Implement RSS.
* Implement pagination.
* Implement EXIF reading for comments, author and so forth.
* Implement download raw version (full file streamed from dropbox).
* Implement disqus for commenting images.
* Images are presented as gackground with CSS. weird sizes will be tiled.
* Imagenames are not rendered nice as titles.
* Thumbs.jpg are not picked up.
* Better synching and local-purging of old files.

## Not @TODO

Items that will not be implemented (unless you fork and add it there, off course!).

* recursive directories. This adds such an amount of new problems (how deep? how to present mixed img/subdirs?) that it leads us far from KISS. If you need recursive galleries, you probably need a complexer gallery manager.
* tagging. Unless we can think of a way to manage this trough dropbox. E.g. in the TODO: EXIF parsing.

## author(s), Credits

* Thanks to all the shoulders I can stand on: Sinatra, HAML, SASS, Ruby, Phusion
* CSS and some of the HTML from [FuckFlickr](http://fffff.at/fuckflickr/) but that is -cough-PHP-cough-.
* Bèr -berkes- Kessels - webschuur.com - ber curlythingy webschuur com

