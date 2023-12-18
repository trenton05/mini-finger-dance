#!/bin/bash

echo "Installing $NAME"
adb install-multiple -r -d com.yxjh.antigravitydance.apk config.arm64_v8a.apk base_assets.apk
