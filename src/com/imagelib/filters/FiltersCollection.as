package com.imagelib.filters
{
	import com.imagelib.filterEvent.FilterEvent;
	import com.imagelib.filters.CustomFilter;
	import com.imagelib.utils.ProcessQueue;
	
	import flash.display.BitmapData;
	import flash.events.EventDispatcher;
	import flash.external.ExternalInterface;

	public class FiltersCollection extends EventDispatcher
	{
		private var _content:Array=[];
		private var _position:int = 0;
		private var _status:int = 0;
		private var _bitmapData:BitmapData;
		public function FiltersCollection()
		{
			
		}
		public function processor(bitmapData:BitmapData):void
		{
			if(_status == 0){
				_bitmapData = bitmapData;
				_bitmapData.lock();
				_status = 1;
				_startProcess();
			}
		}
		
		public function get bitmapData():BitmapData
		{
			return _bitmapData;
		}
		
		public function set content(con:Array):void
		{
			_content = con;
		}
		public function dispose():void
		{
			_content.length = 0;
			_content = null;
			_position = 0;
			_bitmapData = null;
		}
		private function _startProcess():void
		{
			if(_position < _content.length && _content[_position] && (_content[_position] is CustomFilter)){
				
				var filter:CustomFilter = _content[_position] as CustomFilter;
				filter.addEventListener(FilterEvent.PROCESS_COMPLETE, _imageProcessComplete);
				filter.addEventListener(FilterEvent.PROCESS_ERROR, _imageProcessError);
				filter.processor(_bitmapData);
			}else{
				_imageProcessError();
			}
		}
		private function _imageProcessComplete(evt:FilterEvent):void
		{
			
			var filter:CustomFilter = evt.target as CustomFilter;
			filter.removeEventListener(FilterEvent.PROCESS_COMPLETE, _imageProcessComplete);
			filter.removeEventListener(FilterEvent.PROCESS_ERROR, _imageProcessError);
			
			if(_position < _content.length - 1){
				_position ++;
				_startProcess();
			}else{
				_position = 0;
				_status = 0;
				_bitmapData.unlock();
				this.dispatchEvent(new FilterEvent(FilterEvent.PROCESS_COMPLETE, _bitmapData));
			}
		}
		private function _imageProcessError(evt:FilterEvent = null):void
		{
			if(evt){
				var filter:CustomFilter = evt.target as CustomFilter;
				filter.removeEventListener(FilterEvent.PROCESS_COMPLETE, _imageProcessComplete);
				filter.removeEventListener(FilterEvent.PROCESS_ERROR, _imageProcessError);
			}
			
			_position = 0;
			_status = 0;
			_bitmapData.unlock();
			this.dispatchEvent(new FilterEvent(FilterEvent.PROCESS_ERROR, _bitmapData));
		}
	}
}