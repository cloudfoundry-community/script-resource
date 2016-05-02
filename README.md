Script Resource
===============

Provide a script for tasks that doesn't rely on external git repo

The separation of the pipeline definition from the scripts it relies on can
cause problems.  By putting the scripts directly in the pipeline, the
following benefits can be realized:

* Keeps the CI DRY.  If you have multiple repositories that use the same
  pipeline, you don't have to put the script in all those repositories.

* When testing branches that already exist, the script doesn't have to be
  there already.

* When updating the script, you don't have to push a change to the product
  repository, so you avoid creating a new build when the product itself hasn't
  changed.

* Keeps the workflow all in one place.  You don't have to search through
  multiple locations to see what a pipeline does.


Source Configuration
--------------------

-	`shell`: *Required.* This will be used as the shebang line
-	`filename`: *Required.* This will be the file created by the script
  resource.
- `body`: *Required.* The body of the script.

Behavior
--------

### `CHECK`: Check if script has changes (due to pipeline update)

This will return the signature of the script (sha1sum of shebang line and
body).  It will change when a new pipeline is uploaded (set) that contains
changes to the script.

### `IN`: Provide the script

Writes the script to the destination directory using the given filename, and
makes it executable.
