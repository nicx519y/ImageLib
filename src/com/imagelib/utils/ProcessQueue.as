package com.imagelib.utils
{
	import flash.utils.setTimeout;
	import flash.external.ExternalInterface;
	public class ProcessQueue
	{
		public static const STATE_FREE:int = 0;
		public static const STATE_STANDBY:int = 1;
		public static const STATE_WORKING:int = 2;
		
		private var _queue:Array;
		private var _internal:int;//执行间隔
		private var _processor:Function;
		private var _state:int = STATE_FREE;
		
		
		public function ProcessQueue(processor:Function, inter:int = 100)
		{
			_processor = processor;
			_queue = [];
			_internal = inter;
		}
		public function add(item:Object):void
		{
			_queue.push(item);
			continuePorcess();
		}
		public function get isBusy():Boolean
		{
			return (_state == STATE_STANDBY || _state == STATE_WORKING);
		}
		public function continuePorcess():void
		{
			switch(_state){
				case STATE_WORKING:
					_state = STATE_STANDBY;
					setTimeout(_processStart, _internal);
					break;
				case STATE_FREE:
					_processStart();
					break;
			}
		}
		private function _processStart():void
		{
			ExternalInterface.call('console.log', _queue.length);
			if(_queue.length == 0){
				_state = STATE_FREE;
			}
			if(_queue.length > 0){
				_state = STATE_WORKING;
				_processor(_queue.shift());
				continuePorcess();
			}
		}
	}
}