/***
 * @desc	饱和度滤镜
 * @param	{ImageData}		input		输入数据
 * @param	{ImageData}		output		输出数据
 * @param	{Number}		r			红色饱和度
 * @param	{Number}		g			绿色饱和度
 * @param	{Number}		b			蓝色饱和度
 * 取值范围 -100 - 100
 */
package com.imagelib.filters
{
	import com.imagelib.filters.MatrixFilter;
	import com.imagelib.filters.IFilter;
	
	public class SaturationFilter extends MatrixFilter implements IFilter
	{
		public function SaturationFilter(r:Number, g:Number, b:Number)
		{
			var rn:Number = (r / 100 + 1);
			var gn:Number = (g / 100 + 1);
			var bn:Number = (b / 100 + 1);
			
			_matrix = [
				0.3086*(1-rn)+rn,	0.6094*(1-rn),	0.0820*(1-rn),		0,	0,
				0.3086*(1-gn),	0.6094*(1-gn)+gn,	0.0820*(1-gn),		0,	0,
				0.3086*(1-bn),	0.6094*(1-bn),	0.0820*(1-bn)+bn,		0,	0,
				0,				0,				0,					1,	0
			];
		}
	}
}