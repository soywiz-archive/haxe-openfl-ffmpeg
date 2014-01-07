#ifndef IPHONE
#define IMPLEMENT_API
#endif

#ifndef STATIC_LINK
#define IMPLEMENT_API
#endif

#include <hx/CFFI.h>

#define DEFINE_FUNC(COUNT, NAME, ...) value NAME(__VA_ARGS__); DEFINE_PRIM(NAME, COUNT); value NAME(__VA_ARGS__)
#define DEFINE_FUNC_0(NAME) DEFINE_FUNC(0, NAME)
#define DEFINE_FUNC_1(NAME, PARAM1) DEFINE_FUNC(1, NAME, value PARAM1)
#define DEFINE_FUNC_2(NAME, PARAM1, PARAM2) DEFINE_FUNC(2, NAME, value PARAM1, value PARAM2)
#define DEFINE_FUNC_3(NAME, PARAM1, PARAM2, PARAM3) DEFINE_FUNC(3, NAME, value PARAM1, value PARAM2, value PARAM3)
#define DEFINE_FUNC_4(NAME, PARAM1, PARAM2, PARAM3, PARAM4) DEFINE_FUNC(4, NAME, value PARAM1, value PARAM2, value PARAM3, value PARAM4)
#define DEFINE_FUNC_5(NAME, PARAM1, PARAM2, PARAM3, PARAM4, PARAM5) DEFINE_FUNC(5, NAME, value PARAM1, value PARAM2, value PARAM3, value PARAM4, value PARAM5)


extern "C" {
	#include <libavcodec/avcodec.h>
	#include <libavformat/avformat.h>
	#include <libswscale/swscale.h>
}

#include <stdio.h>

static int initialized = 0;

void __check_init() 
{
	if (!initialized)
	{
		initialized = 1;
		av_register_all();
	}
}

typedef struct {
	AVFormatContext *pFormatCtx;
	AVCodecContext  *pCodecCtx;
	AVCodec         *pCodec;
	AVDictionary    *optionsDict;
	AVFrame         *pFrame;
	AVFrame         *pFrameRGB;
	uint8_t         *buffer;
	int videoStream;
	
	struct SwsContext      *sws_ctx;
	int numBytes;
} FfmpegContext;

FfmpegContext ffmpeg_context = {0};

#define   USED_PIX_FMT   AV_PIX_FMT_ARGB

int __ffmpeg_open_file(FfmpegContext *context, const char *name)
{
	if (avformat_open_input(&context->pFormatCtx, name, NULL, NULL)!=0) return -1; // Couldn't open file
	
	if(avformat_find_stream_info(context->pFormatCtx, NULL)<0) return -2; // Couldn't find stream information

	av_dump_format(context->pFormatCtx, 0, name, 0);
	
	context->videoStream=-1;
	for(int i=0; i<context->pFormatCtx->nb_streams; i++)
	{
		if(context->pFormatCtx->streams[i]->codec->codec_type==AVMEDIA_TYPE_VIDEO) {
			context->videoStream=i;
			break;
		}
	}
	
	if(context->videoStream==-1) return -1; // Didn't find a video stream
	
	context->pCodecCtx=context->pFormatCtx->streams[context->videoStream]->codec;
	
	context->pCodec=avcodec_find_decoder(context->pCodecCtx->codec_id);
	if(context->pCodec==NULL) {
		return -3; // Codec not found
	}
	
	if(avcodec_open2(context->pCodecCtx, context->pCodec, &context->optionsDict)<0) return -4; // Could not open codec
	
	// Allocate video frame
	context->pFrame=avcodec_alloc_frame();

	// Allocate an AVFrame structure
	context->pFrameRGB=avcodec_alloc_frame();
	if(context->pFrameRGB==NULL) return -1;
	
	// Determine required buffer size and allocate buffer
	context->numBytes=avpicture_get_size(USED_PIX_FMT, context->pCodecCtx->width, context->pCodecCtx->height);
	context->buffer=(uint8_t *)av_malloc(context->numBytes*sizeof(uint8_t));

	context->sws_ctx = sws_getContext(context->pCodecCtx->width, context->pCodecCtx->height, context->pCodecCtx->pix_fmt, context->pCodecCtx->width, context->pCodecCtx->height, USED_PIX_FMT, SWS_BILINEAR, NULL, NULL, NULL);

	// Assign appropriate parts of buffer to image planes in pFrameRGB
	// Note that pFrameRGB is an AVFrame, but AVFrame is a superset
	// of AVPicture
	avpicture_fill((AVPicture *)context->pFrameRGB, context->buffer, USED_PIX_FMT, context->pCodecCtx->width, context->pCodecCtx->height);

	return 0;
}

void __fmpeg_close_file(FfmpegContext *context)
{
	// Free the RGB image
	av_free(context->buffer);
	av_free(context->pFrameRGB);

	// Free the YUV frame
	av_free(context->pFrame);

	// Close the codec
	avcodec_close(context->pCodecCtx);

	// Close the video file
	avformat_close_input(&context->pFormatCtx);
}

void __fmpeg_copy_frame_to_pointer(AVFrame *pFrame, int width, int height, char *output_ptr, int output_len)
{
	char *current_output_ptr = output_ptr;
	for (int y = 0; y < height; y++)
	{
		int copyCount = width * 4;
		memcpy(current_output_ptr, pFrame->data[0]+y*pFrame->linesize[0], copyCount);
		current_output_ptr += copyCount;
	}
}

void __fmpeg_decode_frame(FfmpegContext *context, char *output_ptr, int output_len)
{
	AVPacket        packet;
	int frameFinished;
  while(av_read_frame(context->pFormatCtx, &packet)>=0) {
    // Is this a packet from the video stream?
    if(packet.stream_index==context->videoStream) {
      // Decode video frame
      avcodec_decode_video2(context->pCodecCtx, context->pFrame, &frameFinished, 
                           &packet);
      
      // Did we get a video frame?
      if(frameFinished) {
        // Convert the image from its native format to RGB
        sws_scale
        (
            context->sws_ctx,
            (uint8_t const * const *)context->pFrame->data,
            context->pFrame->linesize,
            0,
            context->pCodecCtx->height,
            context->pFrameRGB->data,
            context->pFrameRGB->linesize
        );
        
		av_free_packet(&packet);
		__fmpeg_copy_frame_to_pointer(context->pFrameRGB, context->pCodecCtx->width, context->pCodecCtx->height, output_ptr, output_len);
		return;
      }
    } else {
		av_free_packet(&packet);
	}
    
  }
}

DEFINE_FUNC_0(hx_ffmpeg_get_version)
{
	__check_init();
	return alloc_string("2.1.1");
}


DEFINE_FUNC_0(hx_ffmpeg_open_file)
{
	__check_init();
	__ffmpeg_open_file(&ffmpeg_context, "c:/temp/test.mpg");
	return alloc_null();
}

DEFINE_FUNC_0(hx_ffmpeg_get_width)
{
	__check_init();
	return alloc_int(ffmpeg_context.pCodecCtx->width);
}

DEFINE_FUNC_0(hx_ffmpeg_get_height)
{
	__check_init();
	return alloc_int(ffmpeg_context.pCodecCtx->height);
}

DEFINE_FUNC_1(hx_ffmpeg_decode_frame, data_buffer_value)
{
	__check_init();
	
	if (!val_is_buffer(data_buffer_value)) {
		val_throw(alloc_string("Expected to be a buffer"));
		return alloc_null();
	}
	
	buffer data_buffer = val_to_buffer(data_buffer_value);
	char *data_buffer_ptr = buffer_data(data_buffer);
	int data_buffer_len = buffer_size(data_buffer);
	
	__fmpeg_decode_frame(&ffmpeg_context, data_buffer_ptr, data_buffer_len);
	
	return alloc_null();
}

DEFINE_FUNC_0(hx_ffmpeg_close_file)
{
	__check_init();
	__fmpeg_close_file(&ffmpeg_context);
	return alloc_null();
}
