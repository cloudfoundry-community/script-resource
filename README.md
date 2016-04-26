Slack notification sending resource
===================================

Provide a script for tasks that doesn't rely on external git repo

The separation of the pipeline definition from the scripts it relies on 


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

Send message to Slack, with the configured parameters.

#### Parameters

Required:




