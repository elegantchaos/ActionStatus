# update main build number
cd "$SOURCE_ROOT"
export SDKROOT=macosx
swift run --package-path "$ACTION_STATUS_TOOLS_PATH" rt update-build --config "$ACTION_STATUS_COMMON_RESOURCE_PATH/BuildNumber.xcconfig" > /tmp/prebuild.log 2>&1
