package com.imagelib.mouse
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	import flash.ui.MouseCursorData;

	public class CustomMouse
	{
		public static const CURSOR_NESW:String = 'nesw';
		public static const CURSOR_NWSE:String = 'nwse';
		public static const CURSOR_ROTATE_NW:String = 'rotate_nw';
		public static const CURSOR_ROTATE_SW:String = 'rotate_sw';
		public static const CURSOR_ROTATE_SE:String = 'rotate_se';
		public static const CURSOR_ROTATE_NE:String = 'rotate_ne';
		
		
		[Embed(source="../../../../images/cursor_nesw.png")]
		private static var CursorNeswImg:Class;
		
		[Embed(source="../../../../images/cursor_nwse.png")]
		private static var CursorNwseImg:Class;
		
		[Embed(source="../../../../images/cursor_rotate_NW.png")]
		private static var CursorRotateNWImg:Class;
		
		[Embed(source="../../../../images/cursor_rotate_NE.png")]
		private static var CursorRotateNEImg:Class;
		
		[Embed(source="../../../../images/cursor_rotate_SE.png")]
		private static var CursorRotateSEImg:Class;
		
		[Embed(source="../../../../images/cursor_rotate_SW.png")]
		private static var CursorRotateSWImg:Class;
		
		
		private static var _registeredCursor:Vector.<String>;
		
		public function CustomMouse()
		{
		}
		public static function registerCursors(cursors:Array):void
		{
			if(!_registeredCursor) _registeredCursor = new Vector.<String>;
			
			var i:int = 0,
				len:int = cursors.length;
			while(i < len){
				var key:String = cursors[i];
				
				i ++;
				
				if(_registeredCursor.indexOf(key) >= 0){
					continue;
				}
				
				switch(key){
					case CURSOR_NESW:
						_createMouseCursorData(key, new CursorNeswImg as Bitmap);
						break;
					case CURSOR_NWSE:
						_createMouseCursorData(key, new CursorNwseImg as Bitmap);
						break;
					case CURSOR_ROTATE_NW:
						_createMouseCursorData(key, new CursorRotateNWImg as Bitmap);
						break;
					case CURSOR_ROTATE_SW:
						_createMouseCursorData(key, new CursorRotateSWImg as Bitmap);
						break;
					case CURSOR_ROTATE_SE:
						_createMouseCursorData(key, new CursorRotateSEImg as Bitmap);
						break;
					case CURSOR_ROTATE_NE:
						_createMouseCursorData(key, new CursorRotateNEImg as Bitmap);
						break;
				}
				
				_registeredCursor.push(key);
				
			}
		}
		public static function showCursor(name:String):void
		{
			Mouse.cursor = name;
		}
		public static function showDefault():void
		{
			Mouse.cursor = MouseCursor.AUTO;
		}
		private static function _createMouseCursorData(key:String, source:Bitmap):void
		{
			
			var mcd:MouseCursorData = new MouseCursorData(),
				data:Vector.<BitmapData> = new Vector.<BitmapData>;
			
			data.push(source.bitmapData.clone());
			mcd.data = data;
			mcd.hotSpot = new Point(15, 15);
			
			Mouse.registerCursor(key, mcd);
		}
	}
}





