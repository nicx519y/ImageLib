package com.imagelib.filters
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.external.ExternalInterface;
	import com.imagelib.filterEvent.FilterEvent;
	
	import com.imagelib.filters.IFilter;
	
	public class BlendMaskFilter extends CustomBlend implements IFilter
	{
		private var _maskURL:String;
		private var _maskLoader:Loader;
		private var _maskIsLoaded:Boolean;
		public function BlendMaskFilter(maskURL:String, type:String, alpha:Number=1, sourceRect:*=null)
		{
			_maskURL = maskURL;
			super(type, alpha, sourceRect);
			_getMaskSource();
		}
		private function _getMaskSource():void
		{
			_maskLoader = new Loader();
			_maskLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, _maskLoaded);
			_maskLoader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, _maskLoadError);
			_maskLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, _maskLoadError);
			
			
			_maskLoader.load(new URLRequest(_maskURL));
		}
		private function _maskLoaded(evt:*):void
		{
			_maskIsLoaded = true;
			
			_maskLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, _maskLoaded);
			_maskLoader.contentLoaderInfo.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, _maskLoadError);
			_maskLoader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, _maskLoadError);
			
			this.foregroundSource = _maskLoader.content as Bitmap;
			
			this.dispatchEvent(new FilterEvent(FilterEvent.FILTER_COMPLETE));
		}
		private function _maskLoadError(evt:*):void
		{
			_maskLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, _maskLoaded);
			_maskLoader.contentLoaderInfo.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, _maskLoadError);
			_maskLoader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, _maskLoadError);
			
			this.dispatchEvent(new FilterEvent(FilterEvent.FILTER_ERROR));
		}
		override public function processor(bitmapData:BitmapData):void
		{
			var superPorcessor:Function = super.processor;
			if(_maskIsLoaded){
				superPorcessor(bitmapData);
			}else{
				this.addEventListener(FilterEvent.FILTER_COMPLETE, function(evt:FilterEvent):void{
					evt.target.removeEventListener(FilterEvent.FILTER_COMPLETE, arguments.callee);
					superPorcessor(bitmapData);
				});
				this.addEventListener(FilterEvent.FILTER_ERROR, function(evt:FilterEvent):void{
					evt.target.dispatchEvent(FilterEvent.PROCESS_ERROR);
					evt.target.removeEventListener(FilterEvent.FILTER_ERROR, arguments.callee);
				});
			}
		}
	}
}