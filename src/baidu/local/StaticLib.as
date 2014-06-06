package baidu.local
{
	import flash.external.ExternalInterface;
	public class StaticLib
	{
		public static var callback:Object = {
			
		}; //回调
		public static var myInterface:Object = {
			
		} ; //接口
		public function StaticLib()
		{
		}
		public static function console(type:String, msg:*):void
		{
			//ExternalInterface.call('console.log', msg);
		}
		public static function workerconsole(type:String, msg:*):void
		{
			//ExternalInterface.call('console.log', msg);
		}
		public static function consoleA(type:String, msg:*):void
		{
			//ExternalInterface.call('console.log', msg);
		}
		public static function consoleB(msg:*):void
		{
			//ExternalInterface.call('console.log', msg);
		}
	}
}