#!/bin/sh

set -e

if [ ! -f ./prepare_dev.sh ]; then
  echo "Not in a monorepo workspace."
  exit 1
fi

echo "Copying vim config from $VIM_LOCAL_CONFIG_DIR_PATH."
cp -rf "$VIM_LOCAL_CONFIG_DIR_PATH" ./.vim || echo "Done (already copied)"

echo "Copying cypress secrets from $CYPRESS_SECRETS_PATH."
cp "$CYPRESS_SECRETS_PATH" ./apps/server/ || echo "Done (already copied)"

# Only run this in project root
./prepare_dev.sh >/dev/null 2>&1 &
pid="$!"
echo ""
echo "Starting ./prepare_dev.sh in the background."
echo "pid: $pid"
echo ""

exit_code=0
wait $pid || exit_code="$?"

if [ $exit_code -gt 0 ]; then
  echo ""
  echo "Dang!"
  echo "Setup completed with errors."
  exit $exit_code
fi

echo ""
echo "Setup complete."
