package org.bytearray.gif.events
{	
	import flash.events.Event;
	import flash.display.BitmapData;
	
	public class FrameEvent extends Event	
	{
		public var frame:BitmapData;
	
		public static const FRAME_RENDERED:String = "rendered";
		
		public function FrameEvent ( pType:String, pFrame:BitmapData )		
		{
			super ( pType, false, false );
			
			frame = pFrame;	
		}
	}
}