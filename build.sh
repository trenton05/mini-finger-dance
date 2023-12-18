#!/bin/bash

function processApk() {
    echo "Extracting $NAME"
    export NAME=$1
    rm -fR $NAME $NAME*.apk
    mkdir $NAME
    unzip -d $NAME ./original/$NAME.apk

    echo "Processing $NAME"
    node $NAME.js

    echo "Zipping $NAME"
    cd $NAME
    zip -0 -r ../$NAME-unaligned.apk *
    cd ..
    zipalign -p 4 $NAME-unaligned.apk $NAME.apk
    echo "Signing $NAME"
    apksigner sign --ks platform.keystore --ks-pass pass:schmuck --ks-key-alias platform $NAME.apk
}

if [ ! -f "./original/mfd.xapk" ]; then
    echo "./original/mfd.xapk not found, download it here https://m.apkpure.com/mini-finger-dance/com.yxjh.antigravitydance and place in ./original/mfd.xapk"
    exit 1
fi

BUILD_TOOLS=`ls -d $ANDROID_HOME/build-tools/* | sort -r | head -1`
if [ ! -f "$BUILD_TOOLS/apksigner" ]; then
    echo "Build tools apksigner not found in ANDROID_HOME/build-tools: $ANDROID_HOME"
    exit 1
fi
export PATH=$PATH:$BUILD_TOOLS

echo "Extracting XAPK"
cd original
rm -f *.apk *.png *.json
unzip mfd.xapk
cd ..

processApk config.arm64_v8a
processApk base_assets
processApk com.yxjh.antigravitydance
