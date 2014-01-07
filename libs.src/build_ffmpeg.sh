#http://www.ffmpeg.org/platform.html#Microsoft-Visual-C_002b_002b-or-Intel-C_002b_002b-Compiler-for-Windows

#http://stackoverflow.com/questions/8403229/ffmpeg-api-compiling-with-specific-formats
#https://vec.io/posts/how-to-build-ffmpeg-with-android-ndk
#https://github.com/chelyaev/ffmpeg-tutorial/blob/master/tutorial05.c

FLAGS=""

#FLAGS="$FLAGS --toolchain=msvc --enable-cross-compile"

FLAGS="$FLAGS --toolchain=msvc"

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

pushd ffmpeg
./configure $FLAGS && make
popd
cp -f ffmpeg/libavcodec/libavcodec.a ../libs/Windows/libavcodec.a
cp -f ffmpeg/libavdevice/libavdevice.a ../libs/Windows/libavdevice.a
cp -f ffmpeg/libavfilter/libavfilter.a ../libs/Windows/libavfilter.a
cp -f ffmpeg/libavformat/libavformat.a ../libs/Windows/libavformat.a
cp -f ffmpeg/libavutil/libavutil.a ../libs/Windows/libavutil.a
cp -f ffmpeg/libswresample/libswresample.a ../libs/Windows/libswresample.a
cp -f ffmpeg/libswscale/libswscale.a ../libs/Windows/libswscale.a
