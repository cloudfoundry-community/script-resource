#!/bin/bash

set -e

source $(dirname $0)/helpers.sh

it_reports_error_without_script_in_get() {

  local shell="/bin/bash"
  local name="test_script.sh"
  local failed_output=$TMPDIR/failed-output
  local dest=$TMPDIR/destination
  mkdir -p $dest

  if test_get shell $shell filename $name $dest 2> $failed_output
  then
    echo "Expected check without script to fail"
    return 1
  fi

  if ! grep "invalid payload (missing body):" $failed_output > /dev/null 2>&1
  then
    echo "Expected 'invalid payload (missing body):' message on failure, got:"
    cat $failed_output
    return 1
  fi
}

it_reports_error_without_filename() {

  local shell="/bin/bash"
  local script="$(dirname $0)/sample-script.sh"
  local failed_output=$TMPDIR/failed-output
  local dest=$TMPDIR/destination
  mkdir -p $dest

  if test_get shell $shell script $script $dest 2> $failed_output
  then
    echo "Expected check without filename to fail"
    return 1
  fi

  if ! grep "invalid payload (missing filename):" $failed_output > /dev/null 2>&1
  then
    echo "Expected 'invalid payload (missing filename):' message on failure. got:"
    cat $failed_output
    return 1
  fi
}

it_computes_the_the_ref_correctly() {

  local shell="/bin/bash"
  local name="test_script.sh"
  local script="$(dirname $0)/sample-script.sh"
  local dest=$TMPDIR/destination
  mkdir -p $dest

  echo >&2 "Script: $script"

  ref="$(cat <<SCRIPT | tee /tmp/out-test | sha1sum | cut -f1 -d' '
#!/bin/bash
$(cat $script)
SCRIPT
)"
  echo "Expect ref to be '${ref}'"
  test_get shell $shell filename $name script $script $dest| jq -e "
    .version == {ref: $(echo $ref | jq -R .)}
  "
}

it_defaults_to_bash_for_shell() {

  local shell="/bin/bash"
  local name="test_script.sh"
  local script="$(dirname $0)/sample-script.sh"
  local dest=$TMPDIR/destination
  mkdir -p $dest

  echo >&2 "Script: $script"

  ref="$(cat <<SCRIPT | tee /tmp/out-test | sha1sum | cut -f1 -d' '
#!/bin/bash
$(cat $script)
SCRIPT
)"
  echo "Expect ref to be '${ref}'"
  test_get filename $name script $script $dest | jq -e "
    .version == {ref: $(echo $ref | jq -R .)}
  "
}

it_creates_the_executable_script_in_the_destination() {

  local shell="/bin/bash"
  local name="test_script.sh"
  local script="$(dirname $0)/sample-script.sh"
  local dest=$TMPDIR/destination
  mkdir -p $dest

  ref="$(cat <<SCRIPT | tee /tmp/out-test | sha1sum | cut -f1 -d' '
#!/bin/bash
$(cat $script)
SCRIPT
)"
  echo "Expect ref to be '${ref}'"
  test_get filename $name script $script $dest | jq -e "
    .metadata == [
      {
        name: $(echo filename | jq -R .),
        value: $(echo $name | jq -R .)
      }
    ]

  "

  if [ ! -f "$dest/$name" ] ; then
    echo >&2 "$dest/$name does not exist!"
    exit 1
  fi

  if [ ! -x "$dest/$name" ] ; then
    echo >&2 "$dest/$name is not executable!"
    exit 1
  fi

  file_sha1sum="$(cat $dest/$name | sha1sum | cut -f1 -d' ')"
  if [ "$file_sha1sum" != "$ref" ] ; then
    echo >&2 "Expecting sha1sum: $ref\n      got sha1sum: $file_sha1sum"
    exit 1
  fi
}


echo "TESTING 'GET'..."

run it_reports_error_without_script_in_get
run it_reports_error_without_filename
run it_computes_the_the_ref_correctly
run it_defaults_to_bash_for_shell
run it_creates_the_executable_script_in_the_destination
#
