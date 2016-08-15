pushd "$(dirname "$0")" > /dev/null
SCRIPT_DIR=$(pwd -L)
popd > /dev/null

echo "publish repo YTXModule"
pod repo push baidao-ios-ytx-pod-specs YTXModule.podspec --verbose

ret=$?

exit $ret