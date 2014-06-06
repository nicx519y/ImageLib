package com.imagelib
{
	import com.imagelib.utils.Transformer;
	
	import flash.display.BitmapData;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	
	import org.bytearray.gif.decoder.GIFDecoder;
	import org.bytearray.gif.encoder.GIFEncoder;
	
	public class ImageMerger
	{
		public function ImageMerger()
		{
			
		}
		public static function GIFMerge(
			bgSource:BitmapData,		//底图数据 
			gifSource:ByteArray, 		//gif流
			srcRect:Rectangle,			//gif原图的位置和大小
			scaleX:Number=1,			//横向大小比
			scaleY:Number=1,			//纵向大小比
			angle:Number=0, 			//旋转角度
			alpha:Number=1,				//不透明度
			isFlipH:Boolean=false,		//水平翻转
			isFlipV:Boolean=false		//垂直翻转
		):ByteArray
		{
			var decoder:GIFDecoder = new GIFDecoder(),
				encoder:GIFEncoder = new GIFEncoder(),
				frameCount:int,
				size:Rectangle = decoder.getFrameSize(),
				drawMatrix:Matrix = Transformer.getCenterPointTransformMatrix(srcRect, angle, scaleX, scaleY, isFlipH, isFlipV),
				colorTrans:ColorTransform = new ColorTransform(1, 1, 1, alpha);
			
			decoder.read(gifSource);
			frameCount = decoder.getFrameCount();
			
			encoder.start();
			encoder.setDelay(decoder.getDelay(0));
			
			for(var i:int = 0; i < frameCount; i ++){
				var frame:BitmapData = decoder.getFrame(i);
				var bgSrc:BitmapData = new BitmapData(bgSource.width, bgSource.height);
				
				bgSrc.copyPixels(bgSource, new Rectangle(0, 0, bgSource.width, bgSource.height), new Point(0, 0));
				bgSrc.draw(frame, drawMatrix, colorTrans, null, null, true);
				
				encoder.addFrame(bgSrc);
			}
			
			if(encoder.finish()){
				return encoder.stream;
			}else{
				return null;
			}
		}
		public static function merge(
			bgSource:BitmapData, 
			source:BitmapData,
			srcRect:Rectangle, 
			scaleX:Number=1, 
			scaleY:Number=1, 
			angle:Number=0, 
			alpha:Number=1,
			isFlipH:Boolean=false,
			isFlipV:Boolean=false
		):BitmapData
		{
			var bgSrc:BitmapData = new BitmapData(bgSource.width, bgSource.height),
				drawMatrix:Matrix = Transformer.getCenterPointTransformMatrix(srcRect, angle, scaleX, scaleY, isFlipH, isFlipV),
				colorTrans:ColorTransform = new ColorTransform(1, 1, 1, alpha);
			
			bgSrc.copyPixels(bgSource, new Rectangle(0, 0, bgSource.width, bgSource.height), new Point(0, 0));
			bgSrc.draw(source, drawMatrix, colorTrans, null, null, true);
			
			return bgSrc;
		}
	}
}