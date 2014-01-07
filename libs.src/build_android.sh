export ANDROID_NDK=/C/Development/Android NDK
export TOOLCHAIN=/tmp/ffmpeg
export SYSROOT=$TOOLCHAIN/sysroot/
$ANDROID_NDK/build/tools/make-standalone-toolchain.sh --platform=android-14 --install-dir=$TOOLCHAIN