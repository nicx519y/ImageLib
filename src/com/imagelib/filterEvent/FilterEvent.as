package com.imagelib.filterEvent
{
	import flash.display.BitmapData;
	import flash.events.Event;

	public class FilterEvent extends Event
	{
		public static const PROCESS_ALL_COMPLETE:String = 'process_all_complete';	//全部处理完毕
		public static const PROCESS_COMPLETE:String = 'process_complete';	//处理完毕
		public static const PROCESS_ERROR:String = 'process_error';			//处理错误
		public static const FILTER_ERROR:String = 'filter_error';			//滤镜错误
		public static const FILTER_COMPLETE:String = 'filter_complete';		//滤镜准备完毕
		public static const FILTER_READY:String = 'ready';
		
		private var _bitmapData:BitmapData;
		public function FilterEvent(type:String, bitmapData:BitmapData=null)
		{
			_bitmapData = bitmapData;
			super(type, false, false);
		}
		public function get bitmapData():BitmapData
		{
			return _bitmapData;
		}
	}
}