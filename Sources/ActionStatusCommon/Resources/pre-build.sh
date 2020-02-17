# Update main build number
cd "$SOURCE_ROOT"
swift run --package-path "$ACTION_STATUS_TOOLS_PATH" rt update-build --config "$ACTION_STATUS_COMMON_SOURCE_PATH/BuildNumber.xcconfig" > /tmp/prebuild.log
