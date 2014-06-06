package baidu.lib.debug
{
    import flash.net.LocalConnection;
    
	/**
	 * 强制flashplayer进行垃圾回收
	 * 
	 * <p>
	 * 仅用于测试使用。
	 * </p>
	 * 
	 * @author laan
	 * @createTime 2010.03
	 * 
	 */	
	public class GC
	{
		/**
		 * 触发垃圾回收 
		 * 
		 */		
		public static function run():void {
			try {
				new LocalConnection().connect('lcname');
				new LocalConnection().connect('lcname');
			} catch (e:Error) {
				
			}
		}
	}
}