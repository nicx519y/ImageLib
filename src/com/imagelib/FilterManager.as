package com.imagelib
{
	import com.imagelib.filterEvent.FilterEvent;
	import com.imagelib.filters.FiltersCollection;
	
	import flash.display.BitmapData;
	import flash.events.EventDispatcher;

	public class FilterManager extends EventDispatcher
	{
		public static const STATE_FREE:int = 0;
		public static const STATE_RUNNING:int = 1;
		private static var _instance:FilterManager;
		private static var _stack:Array=[];
		private static var _state:int = STATE_FREE;
		public function FilterManager()
		{
			if(_instance && _instance is FilterManager){
				throw new Error('FilterManager only supports a single instance!');
			}
		}
		public static function get instance():FilterManager
		{
			(!_instance) && (_instance = new FilterManager);
			return _instance;
		}
		public function processor(bitmapData:BitmapData, filters:Array):void
		{
			_stack.push({
				'src' : bitmapData,
				'filters' : filters
			});
			(_state == STATE_FREE) && _processorRun();
		}
		private function _processorRun():void
		{
			if(_stack.length <= 0){
				_state = STATE_FREE;
				this.dispatchEvent(new FilterEvent(FilterEvent.PROCESS_ALL_COMPLETE));
			}else{
				_state = STATE_RUNNING;
				var obj:Object = _stack.shift();
				var collection:FiltersCollection = new FiltersCollection;
				collection.addEventListener(FilterEvent.PROCESS_COMPLETE, _processComplete);
				collection.addEventListener(FilterEvent.PROCESS_ERROR, _processError);
				collection.content = obj.filters;
				collection.processor(obj.src);
			}
		}
		private function _processComplete(evt:FilterEvent):void
		{
			var target:FiltersCollection = evt.target as FiltersCollection;
			target.removeEventListener(FilterEvent.PROCESS_COMPLETE, _processComplete);
			target.removeEventListener(FilterEvent.PROCESS_ERROR, _processError);
			target.dispose();
			this.dispatchEvent(new FilterEvent(FilterEvent.PROCESS_COMPLETE, evt.bitmapData));
			
			_processorRun();
		}
		private function _processError(evt:FilterEvent):void
		{
			var target:FiltersCollection = evt.target as FiltersCollection;
			target.removeEventListener(FilterEvent.PROCESS_COMPLETE, _processComplete);
			target.removeEventListener(FilterEvent.PROCESS_ERROR, _processError);
			target.dispose();
			this.dispatchEvent(new FilterEvent(FilterEvent.PROCESS_ERROR, evt.bitmapData));
			
			_processorRun();
		}
	}
}