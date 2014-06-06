/***
 * @desc	对比度滤镜
 * @param	{ImageData}		input		输入数据
 * @param	{ImageData}		output		输出数据
 * @param	{Number}		r			红色对比度 -100 - 100
 * @param	{Number}		g			绿色对比度 -100 - 100
 * @param	{Number}		b			蓝色对比度 -100 - 100
 */
package com.imagelib.filters
{
	import com.imagelib.filters.MatrixFilter;
	import com.imagelib.filters.IFilter;
	
	public class ContrastFilter extends MatrixFilter implements IFilter
	{
		public function ContrastFilter(r:int, g:int, b:int)
		{
			var rn:Number = (r + 100) / 100;
			var gn:Number = (g + 100) / 100;
			var bn:Number = (b + 100) / 100;
			_matrix = [
				rn,0,0,0,128*(1-rn),
				0,gn,0,0,128*(1-gn),
				0,0,bn,0,128*(1-bn),
				0,0,0,1,0
			];
		}
	}
}