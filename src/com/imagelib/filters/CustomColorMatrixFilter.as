package com.imagelib.filters
{
	import com.imagelib.filterEvent.FilterEvent;
	
	import flash.display.BitmapData;
	import flash.display.Shader;
	import flash.display.ShaderJob;
	import flash.events.ShaderEvent;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	import flash.external.ExternalInterface;
	public class CustomColorMatrixFilter extends CustomFilter implements IFilter
	{
		[Embed(source="../../../pixelBender/pbj/colorMatrix.pbj", mimeType="application/octet-stream")]
		private static var colorMatrixShader:Class;
		protected var _shader:Shader;
		protected var _shaderJob:ShaderJob;
		
		public function CustomColorMatrixFilter(matrix:Array)
		{
			var _matrix:ByteArray = new ByteArray();
			_matrix.endian = Endian.LITTLE_ENDIAN;
			for(var i:int = 0, len:int = matrix.length; i < len; i ++){
				_matrix.writeFloat(matrix[i]);
			}
			_matrix.position = 0;
			_shader = new Shader(new colorMatrixShader);
			with(_shader.data){
				mat.width = _matrix.length >> 2;
				mat.height = 1;
				mat.input = _matrix;
			}
			_shaderJob = new ShaderJob();
			_shaderJob.addEventListener(ShaderEvent.COMPLETE, shaderJobComplete);
		}
		override public function processor(bitmapData:BitmapData):void
		{
			with(_shader.data){
				src.width = bitmapData.width;
				src.height = bitmapData.height;
				src.input = bitmapData;
			}
			_shaderJob.shader = _shader;
			_shaderJob.target = bitmapData;
			_shaderJob.width = bitmapData.width;
			_shaderJob.height = bitmapData.height;
			_shaderJob.start(true);
			this.dispatchEvent(new FilterEvent(FilterEvent.PROCESS_COMPLETE));
		}
		private function shaderJobComplete(evt:ShaderEvent):void
		{
			this.dispatchEvent(new FilterEvent(FilterEvent.PROCESS_COMPLETE));
		}
		
	}
}