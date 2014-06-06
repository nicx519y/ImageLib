/***
 * @desc	阈值滤镜
 * @param	{ImageData}		input		输入数据
 * @param	{ImageData}		output		输出数据
 * @param	{Number}		n			阈值0-255
 */
package com.imagelib.filters
{
	import com.imagelib.filters.MatrixFilter;
	import com.imagelib.filters.IFilter;
	
	public class ThresholdFilter extends MatrixFilter implements IFilter
	{
		public function ThresholdFilter(n:int)
		{
			var _n:int = Math.min(255, Math.max(0, n));
			_matrix = [
				0.3086*256,0.6094*256,0.0820*256,0,-256*_n,
				0.3086*256,0.6094*256,0.0820*256,0,-256*_n,
				0.3086*256,0.6094*256,0.0820*256,0,-256*_n,
				0, 0, 0, 1, 0
			];
		}
	}
}