package com.imagelib.filters
{
	import flash.display.BitmapData;
	import flash.filters.ColorMatrixFilter;
	import flash.filters.ConvolutionFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import com.imagelib.filterEvent.FilterEvent;
	
	import com.imagelib.filters.CustomFilter;
	import com.imagelib.filters.IFilter;

	public class MatrixFilter extends CustomFilter implements IFilter
	{
		protected var _matrix:Array=[];
		protected var _matrixOptions:Object={};
		protected var _type:String = 'Color'; //or 'Convolution'
		public function MatrixFilter()
		{
			
		}
		override public function processor(bitmapData:BitmapData):void
		{
			var filter:*;
			if(_type == 'Color') filter = new ColorMatrixFilter(_matrix);
			else if(_type == 'Convolution') filter = new ConvolutionFilter(0, 0, _matrix, _matrixOptions.divisor);
			
			try{
				bitmapData.applyFilter(bitmapData, new Rectangle(0, 0, bitmapData.width, bitmapData.height), new Point(0, 0), filter);
				this.dispatchEvent(new FilterEvent(FilterEvent.PROCESS_COMPLETE));
			}catch(e:*){
				this.dispatchEvent(new FilterEvent(FilterEvent.PROCESS_ERROR));
			}
		}
	}
}