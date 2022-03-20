#!usr/bin/env node

scan_rc_path="$HOME/.scanrc"

thiscommand=`basename $0`

declare -A options=( ["help"]="h" ["set-device"]="d" ["view"]="v" ["force-rescan"]="f" )

set -e

if [ $# -eq 0 ]
then
  echo "Usage: $thiscommand (options) [path/device]"
  echo ""
  echo "-h, --help               View help (this message)"
  echo ""
  echo "-d, --set-device         Sets the active device, stored in .scanrc as $SCAN_DEVICE"
  echo ""
  echo "-v, --view               View the generated PDF after creation"
  echo "-f, --force-rescan       Scan for devices and use the first airscan device found"
  echo ""
  exit 1
fi

option_args=()

shorts=${options[@]}
longs=${!options[@]}

contains () {
  local arr="$1"
  local search="$2"

  echo "$arr, $search"
  printf '%s\n' "${arr[@]}" | grep -F -x "$search"
}

is_option () {
  local search="$1"

  contains "${options[*]}" "$search" || contains "${!options[*]}" "$search"
}

for arg in ${@:1}; do
  trimmed=$(echo "$arg" | sed 's/-//g')
  if is_option $trimmed; then
    echo "We made it $trimmed"
    option_args+=$trimmed
  fi
done

has_option () {
  short=${options["$1"]}
  long=$1
  for arg in ${option_args[@]}; do
    if [[ $arg == *"$short"* ]] || [[ $arg == *"$long"* ]]; then
      return 0
    fi
  done
  return 1 
}

set_device () {
  echo "SCAN_DEVICE=\"$1\"" > ${scan_rc_path=}
}

source_vars () {
  if test -f ${scan_rc_path=}; then
    source ${scan_rc_path=}
    export $(cut -d= -f1 ${scan_rc_path=})
  fi
}

if has_option "help"; then
  ! $thiscommand
  exit 0;
fi

last_var=${@: -1}
echo $(has_option "set-device")
if has_option "set-device"; then
  device=$last_var

  if [[ $# -eq 1 ]]; then
    echo "No device specified when using -d flag"
    echo ""
    exit 1
  fi
  echo "Setting device to $device"
  echo ""
  set_device "$device"
  source_vars
  exit 0
fi 

path=$last_var

source_vars
if [[ -z $SCAN_DEVICE ]] || has_option "force-scan"; then
  [[ -z $SCAN_DEVICE ]] && \
    msg="Default scanning device not specified. Setting first airscan result as default" || \
    msg="Setting first airscan result using force scan option"
  echo "$msg"
  echo ""

  echo "Searching for scanners..."
  echo ""
  saned

  devices=$(scanimage -f %d%n)

  echo "Found devices:"
  echo ""
  echo "$devices"
  echo ""

  device=$(echo "$devices" | grep airscan)
  echo "Using airscan device: $device"
  echo ""
  set_device "$device"
  source_vars
fi

echo "Scanning to file $path with device $SCAN_DEVICE"
echo ""
scanimage -d "$SCAN_DEVICE" --mode Color --resolution 300 --format pdf -o $path

if has_option "view"; then
  qpdfview $path &
  echo "Showing PDF"
  echo ""
fi

echo "Done"
echo ""

