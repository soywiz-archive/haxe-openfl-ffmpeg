#https://vec.io/posts/how-to-build-ffmpeg-with-android-ndk

#export ANDROID_NDK=/C/Development/android-ndk-r9c
export ANDROID_NDK=/C/Development/android-ndk-r6
export TOOLCHAIN=/tmp/ffmpeg
export SYSROOT=$TOOLCHAIN/sysroot/
$ANDROID_NDK/build/tools/make-standalone-toolchain.sh --platform=android-5 --toolchain=arm-linux-androideabi-4.4.3 --install-dir=$TOOLCHAIN

export PATH=$TOOLCHAIN/bin:$PATH
export CC=arm-linux-androideabi-gcc
export LD=arm-linux-androideabi-ld
export AR=arm-linux-androideabi-ar

CFLAGS="-O3 -Wall -mthumb -pipe -fpic -fasm \
  -finline-limit=300 -ffast-math \
  -fstrict-aliasing \
  -fmodulo-sched -fmodulo-sched-allow-regmoves \
  -Wno-psabi -Wa,--noexecstack \
  -D__ARM_ARCH_5__ -D__ARM_ARCH_5E__ -D__ARM_ARCH_5T__ -D__ARM_ARCH_5TE__ \
  -DANDROID -DNDEBUG"
  
EXTRA_CFLAGS="-march=armv7-a -mfpu=neon -mfloat-abi=softfp -mvectorize-with-neon-quad"
EXTRA_LDFLAGS="-Wl,--fix-cortex-a8"
#EXTRA_CFLAGS=""
#EXTRA_LDFLAGS=""

#FFMPEG_FLAGS="--prefix=/tmp/ffmpeg/build \
#  --target-os=linux \
#  --arch=arm \
#  --enable-cross-compile \
#  --cross-prefix=arm-linux-androideabi- \
#  --enable-shared \
#  --disable-symver \
#  --disable-doc \
#  --disable-ffplay \
#  --disable-ffmpeg \
#  --disable-ffprobe \
#  --disable-ffserver \
#  --disable-avdevice \
#  --disable-avfilter \
#  --disable-encoders  \
#  --disable-muxers \
#  --disable-filters \
#  --disable-devices \
#  --disable-everything \
#  --enable-protocols  \
#  --enable-parsers \
#  --enable-demuxers \
#  --disable-demuxer=sbg \
#  --enable-decoders \
#  --enable-bsfs \
#  --enable-network \
#  --enable-swscale  \
#  --enable-asm \
#  --enable-version3"

FLAGS=""

FLAGS="$FLAGS --prefix=/tmp/ffmpeg/build"
FLAGS="$FLAGS --target-os=linux"
FLAGS="$FLAGS --arch=arm"
FLAGS="$FLAGS --enable-cross-compile"
FLAGS="$FLAGS --cross-prefix=arm-linux-androideabi-"

#FLAGS="$FLAGS --enable-shared"

FLAGS="$FLAGS --disable-everything"
#FLAGS="$FLAGS --disable-encoders"
#FLAGS="$FLAGS --disable-protocols"
#FLAGS="$FLAGS --disable-filters"

FLAGS="$FLAGS --enable-protocol=file"
FLAGS="$FLAGS --enable-decoder=mpeg1video"
FLAGS="$FLAGS --enable-decoder=mpeg2video"
FLAGS="$FLAGS --enable-decoder=mp1"
FLAGS="$FLAGS --enable-decoder=mp2"
FLAGS="$FLAGS --enable-decoder=mp3"
FLAGS="$FLAGS --enable-decoder=indeo5"
FLAGS="$FLAGS --enable-decoder=pcm_s16le"
FLAGS="$FLAGS --enable-decoder=h264"
FLAGS="$FLAGS --enable-decoder=vp8"
FLAGS="$FLAGS --enable-decoder=vp9"
FLAGS="$FLAGS --enable-decoder=vorbis"

FLAGS="$FLAGS --enable-parser=mpegaudio"
FLAGS="$FLAGS --enable-parser=mpegvideo"
FLAGS="$FLAGS --enable-parser=mpeg4video"
FLAGS="$FLAGS --enable-parser=aac"
FLAGS="$FLAGS --enable-parser=h264"
FLAGS="$FLAGS --enable-parser=vp8"

FLAGS="$FLAGS --enable-demuxer=mpegvideo"
FLAGS="$FLAGS --enable-demuxer=mpegps"
FLAGS="$FLAGS --enable-demuxer=mpegts"
FLAGS="$FLAGS --enable-demuxer=mp3"
FLAGS="$FLAGS --enable-demuxer=avi"
FLAGS="$FLAGS --enable-demuxer=ogg"
FLAGS="$FLAGS --enable-demuxer=matroska"

FLAGS="$FLAGS --enable-filter=aresample"

#FLAGS="$FLAGS --enable-asm"


pushd ffmpeg
./configure $FLAGS --extra-cflags="$CFLAGS $EXTRA_CFLAGS" --extra-ldflags="$EXTRA_LDFLAGS"
#make clean
make -j1
popd
cp -f ffmpeg/libavcodec/libavcodec.a ../libs/Android/libavcodec.a
cp -f ffmpeg/libavdevice/libavdevice.a ../libs/Android/libavdevice.a
cp -f ffmpeg/libavfilter/libavfilter.a ../libs/Android/libavfilter.a
cp -f ffmpeg/libavformat/libavformat.a ../libs/Android/libavformat.a
cp -f ffmpeg/libavutil/libavutil.a ../libs/Android/libavutil.a
cp -f ffmpeg/libswresample/libswresample.a ../libs/Android/libswresample.a
cp -f ffmpeg/libswscale/libswscale.a ../libs/Android/libswscale.a
