package baidu.local
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.external.ExternalInterface;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.net.FileReference;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	
	import baidu.lib.images.BMPDecoder;
	import baidu.lib.images.ExifParser;
	import baidu.lib.images.FileValidate;
	import baidu.lib.images.JPEG;
	
	/**
	 * 图片标准化，包括对图片的压缩和编码。最终返回一张压缩并编码后的jpg图片的byteArray或者源文件的byteArray(无压缩时)。
	 * 由于是异步编码，因此每此使用本类的方法时都应该新开一个实例
	 */
	public class PicStandardizer extends EventDispatcher
	{
		private var _maxWidth : Number = 3000;			
		private var _maxHeight : Number = 3000;	
		private var _maxByteSize:uint;
		private var _data:ByteArray;
		private var _rawData:ByteArray;
		private var temp_height:int = 0;
		private var temp_width:int = 0;
		private var compressStartTime:Number = 0;
		public var compressTime:Number = 0;
		private var timer:Timer;
		private var _bitmapData:BitmapData;
		
		/**
		 * 获取标准化以后的data
		 * */
		public function get dataBeenStandaized() : ByteArray{
			return _data;
		}
		
		public function get rawData() : ByteArray{
			return _rawData;
		}
		
		/**
		 * 构造函数 
		 * @param {int} [maxArea=1000] 图片将缩小到此尺寸内
		 * @param {int} [maxByteSize=1024*1024] 图片压缩后的最大字节数
		 * */
		public function PicStandardizer(maxWidth:int = 1000, maxHeight:int = 1000, maxByteSize:int = 1024 * 1024){
			timer = new Timer(1000);
			_maxWidth = maxWidth;
			_maxHeight = maxHeight;
			_maxByteSize = maxByteSize;
		}
		
		public function standardize(file: FileReference):void{
			if(FileValidate.isBMP(file.data)){//BMP
				standardizeBMP(file.data);
			}else{
				standardizeCommon(file.data);
			}
		}
		
		
		/**
		 * 标准化BMP图片 
		 * @param {*} byte 图片的ByteArray or BitmapData
		 * */
		public function standardizeBMP(byte:*) : void{
			StaticLib.consoleB('BMP压缩');
			var decoder:BMPDecoder = new BMPDecoder();
			var _bmpBitmapData:BitmapData;
			
			if(byte is ByteArray){
				
				/**
				 * 首先解码BMP图片为BitmapData
				 * */
				try{
					_bmpBitmapData = decoder.decode(byte);
				}
				catch (err:Error){ //bmp解码失败
					_error();
				}
			}else if(byte is BitmapData){
				_bmpBitmapData = byte;
			}else{
				_error();
				return;
			}
			/**
			 * 然后进行压缩高度宽度。
			 */
			if(_bmpBitmapData.width > _maxWidth || _bmpBitmapData.height > _maxHeight){
				var aspectRatio:Number = _bmpBitmapData.width / _bmpBitmapData.height; //宽高比
				var maxAspectRatio:Number = _maxWidth / _maxHeight; //压缩宽高比
				StaticLib.consoleB('超出限制,宽高比：'+aspectRatio);
				var matric:Matrix = new Matrix(); //缩放矩阵
				var scale:*;
				if(aspectRatio > maxAspectRatio){ //原比例 > 压缩比例
					_bitmapData = new BitmapData(_maxWidth, Math.round(_maxWidth / aspectRatio), true, 0x00000000);
					scale = _maxWidth / _bmpBitmapData.width;
				}else{ //高度大于宽度
					_bitmapData = new BitmapData(Math.round(_maxHeight * aspectRatio), _maxHeight, true, 0x00000000);
					scale = _maxHeight / _bmpBitmapData.height;
				}
				matric.scale(scale, scale);
				_bitmapData.draw(_bmpBitmapData, matric, null, null, null, true); //一定要平滑				
			}else{
				StaticLib.consoleB('没有超出限制');
				_bitmapData = _bmpBitmapData;
			}
			/**
			 * 最后进行编码。
			 */
			_jpgEncode();
			_rawData = _data;
		}
		
		/**
		 * 标准化jpg/png/gif图片
		 * @param {ByteArray} byte 图片的ByteArray
		 * */		
		public function standardizeCommon(byte:ByteArray) : void
		{
			_rawData = byte;
			var loader:* = new Loader(); //使用loader来改变图片大小
			StaticLib.consoleB('standardize');
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, _errorHandler);
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, _handleLoadComplete);
			loader.loadBytes(byte);
		}
		
		private function _handleLoadComplete(event:Event) : void
		{
			var loader:Loader = event.target.loader as Loader;
			(loader.content as Bitmap).smoothing = true;
			var aspectRatio:Number = loader.content.width / loader.content.height; //宽高比
			var maxAspectRatio:Number = _maxWidth / _maxHeight; //压缩宽高比
			if(loader.content.width > _maxWidth || loader.content.height > _maxHeight){
				if(aspectRatio > maxAspectRatio){
					loader.content.width = _maxWidth;
					loader.content.height = _maxWidth / aspectRatio;
				}else{
					loader.content.width = _maxHeight * aspectRatio;
					loader.content.height = _maxHeight;
				}
			}
			/**
			 * 首先检测exif信息
			 * */
			var _exifParser:ExifParser = new ExifParser();
			var _image:* = new JPEG(_rawData);
			var headers:Array;
			_image.extractHeaders();
			headers = _image.getHeaders('exif');
			_exifParser.init(headers[0]);
			var exifMsg:Object = _exifParser.TIFF();
			var degree:int = 0; //默认没有旋转
			StaticLib.consoleB('TIFF:');
			StaticLib.consoleB(exifMsg);
			if(exifMsg && exifMsg.Orientation){ //得到exif旋转信息
				switch (exifMsg.Orientation) {
					case 1:
						degree =  0;
						break;
					case 3:
						degree = 180;
						break;
					case 6:
						degree = 90;
						break;
					case 8:
						degree = 270;
						break;
				}
			}
			/**
			 * 需要旋转
			 * */
			if(degree == 90 || degree == 180 || degree == 270){
				var matrix:Matrix = new Matrix();
				matrix.rotate(degree * Math.PI / 180);
				if(degree == 90 || degree == 270){
					_bitmapData = new BitmapData(loader.content.height, loader.content.width, true);
					if(degree == 90){
						matrix.translate(loader.content.height, 0);
					}else{
						matrix.translate(0, loader.content.width);
					}
				}else if(degree == 180){
					_bitmapData = new BitmapData(loader.content.width, loader.content.height, true);
					matrix.translate(loader.content.width, loader.content.height);
				}
				StaticLib.consoleB('旋转角度：'+degree);
				StaticLib.consoleB('旋转fudu：'+(degree * Math.PI / 180));
				_bitmapData.draw(loader, matrix);
				//执行编码
				_jpgEncode();
			/** 不需要旋转 */
			}else{
				/** jpg/png/gif文件如果文件大小和尺寸都没有超过限制则直接上传 */
				if (loader.content.width <= _maxWidth && loader.content.height <= _maxHeight && _rawData.length <= _maxByteSize){
					StaticLib.consoleB('没有压缩和编码，直接上传');
					_data = _rawData;
					dispatchEvent(new Event(Event.COMPLETE));
				}else{
					_bitmapData = new BitmapData(loader.content.width, loader.content.height, true);
					_bitmapData.draw(loader);
					//执行编码
					_jpgEncode();
				}
			}
		}
		
		/**
		 * 压缩完成 进行异步jpg编码   
		 * */
		private function _jpgEncode():void{
			try{ //11.3+ 使用原生压缩
				_data = _bitmapData.encode(new Rectangle(0,0,_bitmapData.width, _bitmapData.height), new flash.display.JPEGEncoderOptions(), _data);
				dispatchEvent(new Event(Event.COMPLETE));
			}catch(err:Error){
				var jpgEncoder:JPGEncoderIMP = new JPGEncoderIMP(80);
				jpgEncoder.addEventListener(Event.COMPLETE, _handleEncodeComplete);
				jpgEncoder.addEventListener(ProgressEvent.PROGRESS, _handleEncodeProgress);
				jpgEncoder.encodeAsync(_bitmapData);
			}
		}
		
		/**
		 * 编码完成
		 * */
		private function _handleEncodeComplete(evt:Event) : void{
			_bitmapData.dispose();
			StaticLib.consoleB('编码完成');
			_data = ((evt.target) as JPGEncoderIMP).ba;
			dispatchEvent(new Event(Event.COMPLETE));
			return;
		}
		
		/**
		 * 编码进度
		 * */
		private function _handleEncodeProgress(evt:ProgressEvent) : void{
			dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS, false, false, evt.bytesLoaded, evt.bytesTotal));
			//StaticLib.consoleB(,'当前进度:'+(evt.bytesLoaded/evt.bytesTotal));
			return;
		}
		
		/**
		 * 错误捕获
		 * */
		private function _errorHandler(evt:Event):void{
			StaticLib.consoleB('错误捕获:');
			_error();
		}
		
		/**
		 * 错误抛出
		 * */
		private function _error():void {
			StaticLib.consoleB('错误抛出:');
			dispatchEvent(new Event(ErrorEvent.ERROR));
		}
	}
}