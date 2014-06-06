package com.imagelib.filters
{
	import com.imagelib.filterEvent.FilterEvent;
	import com.imagelib.filters.CustomFilter;
	import com.imagelib.filters.IFilter;
	
	import flash.display.BitmapData;
	import flash.display.Shader;
	import flash.display.ShaderJob;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.ShaderEvent;
	import flash.external.ExternalInterface;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	import flash.utils.Endian;

	public class CurveFilter extends CustomFilter implements IFilter
	{
		[Embed(source="../../../pixelBender/pbj/paletteMap.pbj", mimeType="application/octet-stream")]
		private static var customPaletteMap:Class;
		
		private var _curvePath:String;
		private var _isReady:Boolean = false;
		private var _shader:Shader;
		private var _shaderObj:ShaderJob;
		
		public function CurveFilter(curvePath:String)
		{
			_curvePath = curvePath;
			_requestCurve();
		}
		private function _requestCurve():void
		{
			var _loader:URLLoader = new URLLoader();
			_loader.dataFormat = URLLoaderDataFormat.BINARY;
			_loader.addEventListener(Event.COMPLETE, _requestCurveComplete);
			_loader.addEventListener(IOErrorEvent.IO_ERROR, _requestCurveError);
			_loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, _requestCurveError);
			_loader.load(new URLRequest(_curvePath));
		}
		private function _requestCurveComplete(evt:Event):void
		{
			try{
				_parseCurve(evt.target.data as ByteArray);
				_isReady = true;
				this.dispatchEvent(new FilterEvent(FilterEvent.FILTER_COMPLETE));
			}catch(e:*){
				this.dispatchEvent(new FilterEvent(FilterEvent.FILTER_ERROR));
			}
		}
		private function _requestCurveError(evt:*):void
		{
			this.dispatchEvent(new FilterEvent(FilterEvent.FILTER_ERROR));
		}
		
		
		private function _parseCurve(data:ByteArray):void
		{	
			var _redArr:ByteArray = new ByteArray(),
				_blueArr:ByteArray = new ByteArray(),
				_greenArr:ByteArray = new ByteArray(),
				_allArr:ByteArray = new ByteArray();
			_redArr.endian = _blueArr.endian = _greenArr.endian = _allArr.endian = Endian.LITTLE_ENDIAN;
			
			for(var i:int = 0; i < 256; i ++){
				_redArr.writeFloat(i / 255);
				_blueArr.writeFloat(i / 255);
				_greenArr.writeFloat(i / 255);
				_allArr.writeFloat(i / 255);
			}
			
			_redArr.position = _blueArr.position = _greenArr.position = _allArr.position = data.position = 0;
			
			var j:int = 0;
			
			while(data.position < data.length - 1){
				var num:Number = data.readUnsignedByte() / 255;
				
				if(j < 256){
					_allArr.writeFloat(num);
				}else if(j < 512){
					_redArr.writeFloat(num);
				}else if(j < 768){
					_greenArr.writeFloat(num);
				}else if(j < 1024){
					_blueArr.writeFloat(num);
				}
				
				j ++;
			}
			
			_redArr.position = _blueArr.position = _greenArr.position = _allArr.position = data.position = 0;
			
			_shader = new Shader(new customPaletteMap);
			
			with(_shader.data){
				
				redmap.width = _redArr.length >> 2;
				redmap.height = 1;
				redmap.input = _redArr;
				
				greenmap.width = _greenArr.length >> 2;
				greenmap.height = 1;
				greenmap.input = _greenArr;
				
				bluemap.width = _blueArr.length >> 2;
				bluemap.height = 1;
				bluemap.input = _blueArr;
				
				allmap.width = _allArr.length >> 2;
				allmap.height = 1;
				allmap.input = _allArr;
			}
			
			_shaderObj = new ShaderJob();
			_shaderObj.addEventListener(ShaderEvent.COMPLETE, _shaderCompleteHandler);
		}
		
		
		private function _imageProcess(bitmapData:BitmapData):void
		{
			
			
			with(_shader.data)
			{
				src.width = bitmapData.width;
				src.height = bitmapData.height;
				src.input = bitmapData;
			}
			
			_shaderObj.shader = _shader;
			_shaderObj.target = bitmapData;
			_shaderObj.width = bitmapData.width;
			_shaderObj.height = bitmapData.height;
			
			try{	
				_shaderObj.start();
				//this.dispatchEvent(new FilterEvent(FilterEvent.PROCESS_COMPLETE));
			}catch(e:*){
				this.dispatchEvent(new FilterEvent(FilterEvent.PROCESS_ERROR));
			}
		}
		private function _shaderCompleteHandler(evt:ShaderEvent):void
		{
			_shader.data = null;
			_shader = null;
			_shaderObj.cancel();
			_shaderObj = null;
			this.dispatchEvent(new FilterEvent(FilterEvent.PROCESS_COMPLETE));
		}
		override public function processor(bitmapData:BitmapData):void
		{
			if(_isReady){
				_imageProcess(bitmapData);
			}else{
				this.addEventListener(FilterEvent.FILTER_COMPLETE, function(evt:FilterEvent):void
				{
					evt.target.removeEventListener(FilterEvent.FILTER_COMPLETE, arguments.callee);
					_imageProcess(bitmapData);
				});
			}
		}
	}
}