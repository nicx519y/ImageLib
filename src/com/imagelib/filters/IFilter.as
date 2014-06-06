package com.imagelib.filters
{
	import flash.display.BitmapData;
	public interface IFilter
	{
		function processor(bitmapData:BitmapData):void
	}
}