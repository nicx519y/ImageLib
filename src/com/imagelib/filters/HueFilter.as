/***
 * @desc	色相滤镜
 * @param	{ImageData}		input			输入数据
 * @param	{ImageData}		output			输出数据
 * @param	{number}		hue				色相偏移 默认0	-180 - 180
 * @param	{String}		channel			通道		默认'rgb'	可选'r','g','b','rg','rb','gb','rgb'
 */
package com.imagelib.filters
{
	import com.imagelib.filters.MatrixFilter;
	import com.imagelib.filters.IFilter;
	
	public class HueFilter extends MatrixFilter implements IFilter
	{
		public function HueFilter(r:Number=0, g:Number=0, b:Number=0)
		{
			_matrix = [];
			var hue:Number = Math.max(-180, Math.min(180, hue)),
				pr1:Number = Math.cos(r * Math.PI / 180),
				pr2:Number = Math.sin(r * Math.PI / 180),
				pg1:Number = Math.cos(g * Math.PI / 180),
				pg2:Number = Math.sin(g * Math.PI / 180),
				pb1:Number = Math.cos(b * Math.PI / 180),
				pb2:Number = Math.sin(b * Math.PI / 180),
				p4:Number = 0.213,
				p5:Number = 0.715,
				p6:Number = 0.072,
				arr0:Array, arr1:Array, arr2:Array;
			
			
			if(r != 0){
				arr0 = [p4+pr1*(1-p4)+pr2*(0-p4),		p5+pr1*(0-p5)+pr2*(0-p5),	p6+pr1*(0-p6)+pr2*(1-p6),	0,	0];
			}else
				arr0 = [1, 0, 0, 0, 0];
			
			if(g != 0)
				arr1 = [p4+pg1*(0-p4)+pg2*0.143,		p5+pg1*(1-p5)+pg2*0.14,	p6+pg1*(0-p6)+pg2*-0.283, 0, 0];
			else
				arr1 = [0, 1, 0, 0, 0];
			
			if(b != 0)
				arr2 = [p4+pb1*(0-p4)+pb2*(0-(1-p4)),	p5+pb1*(0-p5)+pb2*p5,		p6+pb1*(1-p6)+pb2*p6, 	0,	0];
			else
				arr2 = [0, 0, 1, 0, 0];
			
			_matrix = arr0.concat(arr1, arr2, [0, 0, 0, 1, 0]);
		}
	}
}