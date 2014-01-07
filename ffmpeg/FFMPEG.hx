package ffmpeg;

import haxe.io.Bytes;
import flash.utils.ByteArray;
import flash.media.Sound;
import sys.FileSystem;
import sys.io.File;

class FFMPEG {
	public static function getVersion():String {
		return hx_ffmpeg_get_version();
	}

	static var hx_ffmpeg_get_version = cpp.Lib.load("openfl-ffmpeg", "hx_ffmpeg_get_version", 0);
	
}