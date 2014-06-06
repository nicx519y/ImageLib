package baidu.lib.debug {
	
	/**
	 *  日志类，用于将日志内容传递给指定的内容输出器
	 *  @author xiaokun
	 */
	public class Logger {
		
		/**
		 *	错误日志类型
		 */
		public static const TYPE_ERROR:String = "Error";
		
		/**
		 *	普通信息日志类型
		 */
		public static const TYPE_INFO:String = "Info";
		
		/**
		 *	当前是否可用
		 */
		private static var _enabled:Boolean = true;
		
		/**
		 *	当前所有的内容输出器
		 */
		private static var _writers:Array = [];
		
		/**
		 *	添加一个日志输出器
		 *	@param	writer		<IWriter>要添加的日志输出器
		 */
		public static function addWriter(writer:IWriter):void {
			if (_writers.indexOf(writer) == -1) {
				_writers.push(writer);
			}
		}
		
		/**
		 *	删除指定的日志输出器
		 *	@param	writer		<IWriter>要删除的日志输出器
		 */
		public static function removeWriter(writer:IWriter):void {
			var index:int = _writers.indexOf(writer);
			if (index >= 0) {
				_writers.splice(index, 1);
			}
		}
		
		/**
		 *	删除所有的日志输出器
		 */
		public static function removeAllWriters():void {
			_writers = [];
		}
		
		/**
		 *  获取/设置是否可用
		 */
		public static function get enabled():Boolean {
			return _enabled;
		}
		
		public static function set enabled(value:Boolean):void {
			_enabled = value;
		}

		/**
		 *  打印错误日志
		 *  @param	o			错误信息对象
		 *	
		 */
		public static function err(o:*):void {
			log(o, TYPE_ERROR);
		}

		/**
		 *  打印日志
		 *  @param	o			<*>要打印的对象
		 *  @param	type		<String>日志类型
		 */
		public static function log(o:*, type:String = TYPE_INFO):void {
			if (!_enabled) return;
			if (_writers.length == 0) {
				throw new Error("No writer has been set.");
			}
			for each (var writer:IWriter in _writers) {
				writer.write(o, type);
			}
		}
	}
	
}