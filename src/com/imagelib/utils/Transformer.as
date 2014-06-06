package com.imagelib.utils
{
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	public class Transformer
	{
		public function Transformer()
		{
			
		}
		/***
		 * @desc	以图片中心点改变角度、大小后，获取matrix
		 * @param	srcRect		{Rectangle}		原图的位置和宽度和高度
		 * @param	angle		{Number}		旋转的角度
		 * @param	scaleX		{Number}		横向大小比
		 * @param	scaleY		{Number}		纵向大小比
		 * @param	flipH		{Boolean}		是否水平翻转
		 * @param	flipV		{Boolean}		是否垂直翻转
		 * @return	{Matrix}					计算后的matrix
		 */
		public static function getCenterPointTransformMatrix(
			srcRect:Rectangle, angle:Number=0, 
			scaleX:Number=1, scaleY:Number=1,
			flipH:Boolean=false, flipV:Boolean=false
		):Matrix
		{
			var matrix:Matrix = new Matrix();
			
			angle %= 360;
			if(Math.abs(angle) > 180){
				angle = - (angle / Math.abs(angle)) * (360 - Math.abs(angle));
			}
			trace(flipH, flipV);
			matrix.translate(- srcRect.width / 2, - srcRect.height / 2);
			flipH && matrix.scale(-1, 1);
			flipV && matrix.scale(1, -1);
			matrix.scale(scaleX, scaleY);
			matrix.rotate(angleToRadian(angle));
			matrix.translate(srcRect.width / 2, srcRect.height / 2);
			matrix.translate(srcRect.x, srcRect.y);
			
			return matrix;
		}
		/***
		 * @desc 角度转弧度
		 */
		public static function angleToRadian(angle:Number):Number
		{
			return angle * Math.PI / 180;
		}
		/***
		 * @desc 弧度转角度
		 */
		public static function radianToAngle(radian:Number):Number
		{
			return 180 / Math.PI * radian;
		}
	}
}