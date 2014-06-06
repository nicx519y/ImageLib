package baidu.lib.debug {
	
	/**
	 *  日志内容输出器接口，所有日志输出器需实现此接口
	 *  @author xiaokun
	 */
	public interface IWriter {
		
		/**
		 *  输出内容
		 *  @param	o		<*>要输出的内容
		 *  @param	type	<String>日志类型
		 */
		function write(o:*, type:String):void;
	}
	
}