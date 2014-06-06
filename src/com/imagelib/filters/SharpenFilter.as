package com.imagelib.filters
{	
	import com.imagelib.filters.MatrixFilter;
	public class SharpenFilter extends MatrixFilter implements IFilter
	{
		public function SharpenFilter(depth:int=0)
		{
			var d:int = depth;
			_type = 'Convolution';
			_matrix = [
				0, 	-d, 	0,
				-d,	4*d+1,	-d,
				0,	-d,		0
			];
			_matrixOptions.divisor = 1;
		}
	}
}