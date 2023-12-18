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

BUILD_TOOLS=`ls -d $ANDROID_HOME/build-tools/* | sort -r | head -1`
if [ ! -f "$BUILD_TOOLS/apksigner" ]; then
    echo "Build tools apksigner not found in ANDROID_HOME/build-tools: $ANDROID_HOME"
    exit 1
fi
export PATH=$PATH:$BUILD_TOOLS

mkdir -p ./original
if [ ! -f "./original/mfd.xapk" ]; then
    curl -o ./original/mfd.xapk 'https://d-03.winudf.com/b/XAPK/Y29tLnl4amguYW50aWdyYXZpdHlkYW5jZV8xMTc1Xzg0Njg3ZDVm?_fn=TWluaSBGaW5nZXIgRGFuY2VfMS4xLjdfQXBrcHVyZS54YXBr&_p=Y29tLnl4amguYW50aWdyYXZpdHlkYW5jZQ%3D%3D&download_id=1966400415650400&is_hot=false&k=eb6306d960f9442baa647c7057c36bc46581fb02'
    if [ $? != 0 ]; then
        echo "./original/mfd.xapk not found, download it here https://m.apkpure.com/mini-finger-dance/com.yxjh.antigravitydance and place in ./original/mfd.xapk"
        exit 1
    fi
fi

echo "Extracting XAPK"
cd original
rm -f *.apk *.png *.json
unzip mfd.xapk
cd ..

processApk config.arm64_v8a
processApk base_assets
processApk com.yxjh.antigravitydance

./install.sh
