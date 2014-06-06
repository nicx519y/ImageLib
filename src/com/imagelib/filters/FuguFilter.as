package com.imagelib.filters
{
	import flash.display.BitmapData;
	import com.imagelib.filters.MatrixFilter;

	public class FuguFilter extends MatrixFilter implements IFilter
	{
		public function FuguFilter()
		{
			_matrix = [
				1,		0,		0,	0,	0,
				0,	0.959,		0,	0,	0,
				0,		0, 0.8039,	0,	0,
				0,		0,		0,	1,	0
			];
		}
	}
}