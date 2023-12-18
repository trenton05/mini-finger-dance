#!/bin/bash

function processApk() {
    export NAME=$1
    rm -fR $NAME
    mkdir $NAME
    unzip -d $NAME ./original/$NAME.apk

    node $NAME.js

    cd $NAME
    zip -r ../$NAME-unaligned.apk *
    cd ..
    zipalign -p 4 $NAME-unaligned.apk $NAME.apk
    apksigner sign --ks platform.keystore --ks-pass schmuck $NAME.apk --ks-key-alias platform
    adb install $NAME.apk
}

if [ ! -f "./original/mfd.xapk" ]; then
    echo "./original/mfd.xapk not found, download it here https://m.apkpure.com/mini-finger-dance/com.yxjh.antigravitydance and place in ./original/mfd.xapk"
    exit 1
fi

BUILD_TOOLS=`ls -d $ANDROID_HOME/build-tools/* | sort -r | head -1`
export BUILD_TOOLS_PATH=$ANDROID_HOME/build-tools/$BUILD_TOOLS
if [ ! -f "$BUILD_TOOLS_PATH/apksigner" ]; then
    echo "Build tools apksigner not found in ANDROID_HOME/build-tools: $ANDROID_HOME"
    exit 1
fi
export PATH=$PATH:$BUILD_TOOLS_PATH

cd original
rm -f *.apk
unzip mfd.xapk
cd ..

processApk com.yxjh.antigravitydance
processApk base_assets
processApk config.arm64_v8a
