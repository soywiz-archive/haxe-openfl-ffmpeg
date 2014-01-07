#http://www.ffmpeg.org/platform.html#Microsoft-Visual-C_002b_002b-or-Intel-C_002b_002b-Compiler-for-Windows

#http://stackoverflow.com/questions/8403229/ffmpeg-api-compiling-with-specific-formats
#https://vec.io/posts/how-to-build-ffmpeg-with-android-ndk
#https://github.com/chelyaev/ffmpeg-tutorial/blob/master/tutorial05.c

FLAGS=""
#FLAGS="$FLAGS --toolchain=msvc --enable-cross-compile"
FLAGS="$FLAGS --toolchain=msvc"
#FLAGS="$FLAGS --enable-shared"
FLAGS="$FLAGS --disable-everything"
FLAGS="$FLAGS --enable-protocol=file"
FLAGS="$FLAGS --enable-decoder=mpeg1video"
FLAGS="$FLAGS --enable-decoder=mpeg2video"
FLAGS="$FLAGS --enable-decoder=mp1"
FLAGS="$FLAGS --enable-decoder=mp2"
FLAGS="$FLAGS --enable-decoder=mp3"
FLAGS="$FLAGS --enable-parser=mpegaudio"
FLAGS="$FLAGS --enable-parser=mpegvideo"
FLAGS="$FLAGS --enable-demuxer=mpegvideo"
FLAGS="$FLAGS --enable-demuxer=mpegps"
FLAGS="$FLAGS --enable-demuxer=mpegts"
FLAGS="$FLAGS --enable-demuxer=mp3"
FLAGS="$FLAGS --enable-filter=aresample"

pushd ffmpeg
./configure $FLAGS && make
popd