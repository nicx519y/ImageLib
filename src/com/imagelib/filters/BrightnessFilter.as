package com.imagelib.filters
{
	import com.imagelib.filters.MatrixFilter;
	import com.imagelib.filters.IFilter;
	
	public class BrightnessFilter extends MatrixFilter implements IFilter
	{
		public function BrightnessFilter(brightness:int)
		{
			_matrix = [
				1, 0, 0, 0, brightness,
				0, 1, 0, 0, brightness,
				0, 0, 1, 0, brightness,
				0, 0, 0, 1, 0
			];
		}
	}
}