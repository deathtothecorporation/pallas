#!/usr/bin/env bash

KILL=1
START=1

usage ()
{
  echo "Usage: ./recog -d demo_name [ --no-kill | --no-start ]
  will:
    1. create a .ships/demo_name ship (destroying the dir first if it exists)
    2. boot a machine here (presuming sire/demo_name.sire exists!)
    3. start the machine

  --no-kill will not destroy the dir if it exists
  --no-start will not start the machine, boot only
  "
  exit 2
}

plunder=$(stack path --local-install-root)/bin/plunder

PARSED_ARGUMENTS=$(
    getopt -a -n alphabet \
        -o d: \
        --long demosrc:,no-kill,no-start,help \
        -- "$@"
)

VALID_ARGUMENTS=$?
if [ "$VALID_ARGUMENTS" != "0" ]; then
  usage
fi

eval set -- "$PARSED_ARGUMENTS"
while :
do
  case "$1" in
    -d | --demosrc)        DEMOSRC="$2"             ; shift 2 ;;
    --no-kill)             KILL=0                   ; shift   ;;
    --no-start)            START=0                  ; shift   ;;

    # Don't "error" on help.
    --help) usage ;;

    # -- means the end of the arguments; drop this, and break out of the while loop
    --) shift; break ;;

    # If invalid options were passed, then getopt should have reported an error,
    # which we checked as VALID_ARGUMENTS when getopt was called...
    *) echo "Unexpected option: $1 - this should not happen."
       usage ;;
  esac
done

if [ "${KILL}" -eq "1" ]; then
  echo "removing .ships/$DEMOSRC..."
  rm -rf ".ships/$DEMOSRC"
  echo "creating .ships/$DEMOSRC..."
  mkdir -p ".ships/$DEMOSRC"
else
  echo "just creating $DEMOSRC"
  mkdir -p ".ships/$DEMOSRC"
fi

$plunder boot ".ships/$DEMOSRC" "sire/$DEMOSRC.sire"

if [ "${START}" -eq "1" ]; then
  echo "starting..."
  $plunder start ".ships/$DEMOSRC"
else
  echo "not starting, booted only!"
fi
