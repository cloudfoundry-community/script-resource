#!/bin/bash

set -e

source $(dirname $0)/helpers.sh

it_reports_error_without_script() {

  local shell="/bin/bash"
  local name="test_script.sh"
  local failed_output=$TMPDIR/failed-output

  if test_check shell $shell filename $name 2> $failed_output
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

  if test_check shell $shell script $script 2> $failed_output
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

  ref="$(cat <<SCRIPT | tee /tmp/out-test | sha1sum | cut -f1 -d' '
#!/bin/bash
$(cat $script)
SCRIPT
)"
  echo "Expect ref to be '${ref}'"
  test_check shell $shell filename $name script $script | jq -e "
    . == [{ref: $(echo $ref | jq -R .)}]
  "
}

it_defaults_to_bash_for_shell() {

  local shell="/bin/bash"
  local name="test_script.sh"
  local script="$(dirname $0)/sample-script.sh"

  ref="$(cat <<SCRIPT | tee /tmp/out-test | sha1sum | cut -f1 -d' '
#!/bin/bash
$(cat $script)
SCRIPT
)"
  echo "Expect ref to be '${ref}'"
  test_check filename $name script $script | jq -e "
    . == [{ref: $(echo $ref | jq -R .)}]
  "
}

run it_reports_error_without_script
run it_reports_error_without_filename
run it_computes_the_the_ref_correctly
run it_defaults_to_bash_for_shell
