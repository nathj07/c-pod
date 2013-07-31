GEMREPO
=======
This directory contains custom RubyGems. The actual building is done elsewhere (either in a project or the 'gembuild' directory)
 
INSTALLING 
----------
After dropping a .gem file in the 'gems' subdirectory you need to rebuild the
indexes by running the following command from this directory:

    gem generate_index -d .

The following script can be used instead:

    /data/repo/bin/rebuild_indexes 

GOTCHAS
-------
Make sure that you can write the quick directory as
otherwise this completes OK, but you won't be able to install
your new gems! If in doubt then erase all the index stuff and rebuild.
