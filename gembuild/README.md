# Building Custom Gems
There are two use cases for this directory:
* to package a GEM that has been written, and
* to package a binary version of a GEM that someone else wrote

## Building or Rebuilding a Custom GEM
Simpy change into the directory containing the gem and issue the command

    gem build <gemname>.gemspec

This will create the `.gem` file in the same directory.

## Packaging a binary version of a GEM that someone else wrote
First install the GEM on the platform you wish to package by doing:

    gem install <gemname>

Then change to the installed GEM directory. You can determine this by using the command:

    gem contents <gemname>

Now find the .gemspec file and make the following changes:

* Add a line `platform = Gem::Platform::CURRENT`
* Change the `files` array to include the entire lib directory (which is where the binary components are stored)
* Comment out the line `extensions=` to prevent the extensions being rebuilt.

Then issue the command `gem build <gemname>`. This will create a binary gem in the current directory which you can then `pushpkg` to the server.
