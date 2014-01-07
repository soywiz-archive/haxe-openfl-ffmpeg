package ffmpeg;

import flash.media.SoundChannel;
import flash.events.Event;
import flash.events.EventDispatcher;
import haxe.Timer;
import flash.display.PixelSnapping;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.SampleDataEvent;
import flash.utils.Endian;
import sys.io.FileOutput;
import haxe.io.Output;
import haxe.io.BytesData;
import haxe.Log;
import flash.display.BitmapData;
import haxe.io.Bytes;
import flash.utils.ByteArray;
import flash.media.Sound;
import sys.FileSystem;
import sys.io.File;
import cpp.Lib;

class FFMPEG
{
	public function new()
	{
	}

	public static function getVersion():String
	{
		return hx_ffmpeg_get_version();
	}

	public var width(default, null):Int;
	public var height(default, null):Int;
	public var bitmapData(default, null):BitmapData;
	private var buffer:ByteArray;
	private var sound:Sound;
	private var soundChannel:SoundChannel;
	//private var _tempOutput:FileOutput;
	private var soundBuffer:ConsumerProducerBuffer<Float>;
	private var completed:Bool;
	private var onComplete:Void -> Void;
	private var onFrame:Void -> Void;

	public function openAndPlay(fileName:String, onComplete:Void -> Void = null, onFrame:Void -> Void = null):Void
	{
		if (bitmapData != null) dispose();

		hx_ffmpeg_open_file(fileName);
		this.completed = false;
		this.width = hx_ffmpeg_get_width();
		this.height = hx_ffmpeg_get_height();
		this.bitmapData = new BitmapData(width, height, true, 0x00000000);
		this.buffer = new ByteArray(width * height * 4);
		this.sound = new Sound();
		this.soundBuffer = new ConsumerProducerBuffer<Float>();
		this.onComplete = onComplete;
		this.onFrame = onFrame;

		this.sound.addEventListener(SampleDataEvent.SAMPLE_DATA, generateSound);
		this.soundChannel = this.sound.play();

		var timer = new Timer(1000 / 30);
		timer.run = function() {
			decode_frame();
			if (onFrame != null)
			{
				onFrame();
			}

			if (completed && onComplete != null)
			{
				onComplete();
			}

			if (completed) {
				timer.stop();
				dispose();
			}
		};
	}

	private function dispose():Void
	{
		hx_ffmpeg_close_file();
		this.bitmapData = null;
		this.buffer = null;
		if (this.soundChannel != null)
		{
			this.soundChannel.stop();
			this.soundChannel = null;
		}
	}

	public function stop()
	{
		completed = true;
	}

	private function generateSound(event:SampleDataEvent)
	{
		var bufferSize = 8192 * 2 * 4;

		if (soundBuffer.available == 0 && completed) return;

		while (event.data.length < bufferSize)
		{
			event.data.writeFloat((soundBuffer.available > 0) ? soundBuffer.read() : 0);
		}
	}

	public function decode_frame():FFMPEG
	{
		buffer.position = 0;
		this.completed = hx_ffmpeg_decode_frame(buffer.getData(), emit_sound) != 0;
		bitmapData.lock();
		bitmapData.setPixels(bitmapData.rect, buffer);
		bitmapData.unlock();

		return this;
	}

	static private function getByteArrayFromBytesData(bytesData:BytesData):ByteArray
	{
		var byteArray:ByteArray = new ByteArray();
		byteArray.endian = Endian.LITTLE_ENDIAN;
		for (n in 0 ... bytesData.length) byteArray.writeByte(cast bytesData[n]);
		byteArray.position = 0;
		return byteArray;
	}

	private function emit_sound(channel:BytesData)
	{
		var channelByteArray = getByteArrayFromBytesData(channel);
		while (channelByteArray.bytesAvailable > 0)
		{
			soundBuffer.write(channelByteArray.readFloat());
		}
		//Log.trace('${channel.length}');
	}

	/*
	private function emit_sound(channels:Array<BytesData>)
	{
		var nsamples = Std.int(channels[0].length / 2);

		var channelLByteArray = getByteArrayFromBytesData(channels[0]);
		var channelRByteArray = getByteArrayFromBytesData(channels[1]);

		for (n in 0 ... nsamples)
		{
			var l = channelLByteArray.readShort() / 32767;
			var r = channelRByteArray.readShort() / 32767;
			soundBuffer.write(l);
			soundBuffer.write(r);
		}
	}
	*/

	private static var hx_ffmpeg_get_version = Lib.load("openfl-ffmpeg", "hx_ffmpeg_get_version", 0);
	private static var hx_ffmpeg_open_file = Lib.load("openfl-ffmpeg", "hx_ffmpeg_open_file", 1);
	private static var hx_ffmpeg_get_width = Lib.load("openfl-ffmpeg", "hx_ffmpeg_get_width", 0);
	private static var hx_ffmpeg_get_height = Lib.load("openfl-ffmpeg", "hx_ffmpeg_get_height", 0);
	private static var hx_ffmpeg_decode_frame = Lib.load("openfl-ffmpeg", "hx_ffmpeg_decode_frame", 2);
	private static var hx_ffmpeg_close_file = Lib.load("openfl-ffmpeg", "hx_ffmpeg_close_file", 0);
}

class ConsumerProducerBuffer<T>
{
	private var data:Array<T>;
	public var available(get, never):Int;
	private var readPosition:Int = 0;

	public function new()
	{
		data = [];
	}

	private function get_available():Int
	{
		return data.length - readPosition;
	}

	public function read():T
	{
		if (readPosition >= 0x4000) {
			this.data = this.data.slice(0x4000);
			this.readPosition -= 0x4000;
		}
		//Array.slice
		return this.data[readPosition++];
	}

	public function write(value:T):Void
	{
		this.data.push(value);
	}
}