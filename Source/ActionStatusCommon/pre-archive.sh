# update main build number
cd "$PROJECT_DIR/.."
swift run --package-path "Tools" rt update-build --config ActionStatus/Configs/BuildNumber.xcconfig> /tmp/prearchive.log
