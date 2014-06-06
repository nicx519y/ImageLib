package com.imagelib.filters
{
	import com.imagelib.filterEvent.FilterEvent;
	import com.imagelib.filters.CustomFilter;
	import com.imagelib.filters.IFilter;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.Shader;
	import flash.display.ShaderJob;
	import flash.events.Event;
	import flash.events.ShaderEvent;
	import flash.external.ExternalInterface;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;

	public class CustomBlend extends CustomFilter implements IFilter
	{
		//透明度
		[Embed(source="../../../pixelBender/pbj/alpha.pbj", mimeType="application/octet-stream")]
		private static var alphaShader:Class;
		//加
		[Embed(source="../../../pixelBender/pbj/add.pbj", mimeType="application/octet-stream")]
		private static var addShader:Class;
		//颜色加深
		[Embed(source="../../../pixelBender/pbj/colorBurn.pbj", mimeType="application/octet-stream")]
		private static var colorBurnShader:Class;
		//颜色减淡
		[Embed(source="../../../pixelBender/pbj/colorDodge.pbj", mimeType="application/octet-stream")]
		private static var colorDodgeShader:Class;
		//变暗
		[Embed(source="../../../pixelBender/pbj/darken.pbj", mimeType="application/octet-stream")]
		private static var darkenShader:Class;
		//差值
		[Embed(source="../../../pixelBender/pbj/difference.pbj", mimeType="application/octet-stream")]
		private static var differenceShader:Class;
		//排除
		[Embed(source="../../../pixelBender/pbj/exclusion.pbj", mimeType="application/octet-stream")]
		private static var exclusionShader:Class;
		//强光
		[Embed(source="../../../pixelBender/pbj/hardLight.pbj", mimeType="application/octet-stream")]
		private static var hardLightShader:Class;
		//实点混合
		[Embed(source="../../../pixelBender/pbj/hardMix.pbj", mimeType="application/octet-stream")]
		private static var hardMixShader:Class;
		//变亮
		[Embed(source="../../../pixelBender/pbj/lighten.pbj", mimeType="application/octet-stream")]
		private static var lightenShader:Class;
		//线性加深
		[Embed(source="../../../pixelBender/pbj/linearBurn.pbj", mimeType="application/octet-stream")]
		private static var linearBurnShader:Class;
		//线性减淡
		[Embed(source="../../../pixelBender/pbj/linearDodge.pbj", mimeType="application/octet-stream")]
		private static var linearDodgeShader:Class;
		//线性光
		[Embed(source="../../../pixelBender/pbj/linearLight.pbj", mimeType="application/octet-stream")]
		private static var linearLightShader:Class;
		//正片叠底
		[Embed(source="../../../pixelBender/pbj/multiply.pbj", mimeType="application/octet-stream")]
		private static var multiplyShader:Class;
		//普通
		[Embed(source="../../../pixelBender/pbj/multiply.pbj", mimeType="application/octet-stream")]
		private static var normalShader:Class;
		//叠加
		[Embed(source="../../../pixelBender/pbj/overlay.pbj", mimeType="application/octet-stream")]
		private static var overlayShader:Class;
		//点光
		[Embed(source="../../../pixelBender/pbj/pinLight.pbj", mimeType="application/octet-stream")]
		private static var pinLightShader:Class;
		//滤色
		[Embed(source="../../../pixelBender/pbj/screen.pbj", mimeType="application/octet-stream")]
		private static var screenShader:Class;
		//柔光
		[Embed(source="../../../pixelBender/pbj/softLight.pbj", mimeType="application/octet-stream")]
		private static var softLightShader:Class;
		//亮光
		[Embed(source="../../../pixelBender/pbj/vividLight.pbj", mimeType="application/octet-stream")]
		private static var vividLightShader:Class;
		
		protected var _source:Bitmap;
		protected var _type:String;
		protected var _alpha:Number;
		protected var _matrix:Matrix;
		protected var _rect:*;
		
		private var _shaders:Object = {
			'alpha' : alphaShader,
			'add' : addShader,
			'colorBurn' : colorBurnShader,
			'colorDodge' : colorDodgeShader,
			'darken' : darkenShader,
			'difference' : differenceShader,
			'exclusion' : exclusionShader,
			'hardLight' : hardLightShader,
			'hardMix' : hardMixShader,
			'lighten' : lightenShader,
			'linearBurn' : linearBurnShader,
			'linearDodge' : linearDodgeShader,
			'linearLight' : linearLightShader,
			'multiply' : multiplyShader,
			'normal' : normalShader,
			'overlay' : overlayShader,
			'pinLight' : pinLightShader,
			'screen' : screenShader,
			'softLight' : softLightShader,
			'vividLight' : vividLightShader
		};
		
		public function CustomBlend(type:String, alpha:Number=1, sourceRectOrMode:*=null)
		{
			_rect = sourceRectOrMode;
			_alpha = alpha;
			_type = type;
		}
		public function set foregroundSource(source:Bitmap):void
		{
			_source = source;
		}
		override public function processor(bitd:BitmapData):void
		{	
			//计算matrix
			_matrix = _getSourceMatrix(bitd);
			try{
				if(_type in _shaders){
					var ShaderClass:Class = _shaders[_type];
					var shader:Shader = new Shader(new ShaderClass);
					var sourceWidth:Number = _matrix.a * _source.width;
					var sourceHeight:Number = _matrix.d * _source.height;
					
					var sourceBitmapData:BitmapData = new BitmapData(sourceWidth, sourceHeight, true, 0);
					sourceBitmapData.draw(_source, _matrix, null, null, null, true);
					
					with(shader.data){
						foreground.input = sourceBitmapData;
						background.input = bitd;
						pos.value = [_matrix.tx, _matrix.ty];
						rect.value = [0, 0, sourceWidth, sourceHeight];
						alpha.value = [_alpha];
					}
					var shaderJob:ShaderJob = new ShaderJob(shader, bitd, sourceWidth, sourceHeight);
					shaderJob.addEventListener(ShaderEvent.COMPLETE, _shaderCompleteHandler);
					shaderJob.start(false);
				}else if(_type.toUpperCase() in BlendMode){
					bitd.draw(_source, _matrix, new ColorTransform(1, 1, 1, _alpha), _type, null, true);
					this.dispatchEvent(new FilterEvent(FilterEvent.PROCESS_COMPLETE));
				}else{
					this.dispatchEvent(new FilterEvent(FilterEvent.PROCESS_ERROR));
				}
			}catch(e:*){
				this.dispatchEvent(new FilterEvent(FilterEvent.PROCESS_ERROR));
			}
		}
		private function _getSourceMatrix(bitd:BitmapData):Matrix
		{
			var width:Number, height:Number,
			x:Number, y:Number;
			
			if(!_rect || _rect == 'auto'){
				width = bitd.width;
				height = bitd.height;
				x = 0;
				y = 0;
			}else if(_rect is Rectangle){
				width = _rect.width;
				height = _rect.height;
				x = _rect.x;
				y = _rect.y;
			}else if(_rect == 'outside'){
				if(bitd.width / bitd.height > _source.width / _source.height){
					width = bitd.width;
					height = width / (_source.width / _source.height);
					x = 0;
					y = 0;
				}else{
					height = bitd.height;
					width = height * (_source.width / _source.height);
					x = 0;
					y = 0;
				}
			}else if(_rect == 'inside'){
				if(bitd.width / bitd.height < _source.width / _source.height){
					width = bitd.width;
					height = width / (_source.width / _source.height);
					x = 0;
					y = 0;
				}else{
					height = bitd.height;
					width = height * (_source.width / _source.height);
					x = 0;
					y = 0;
				}
			}
			return new Matrix(width / _source.width, 0, 0, height / _source.height, x, y);
		}
		private function _shaderCompleteHandler(evt:Event):void
		{
			(evt.target as ShaderJob).removeEventListener(ShaderEvent.COMPLETE, _shaderCompleteHandler);
			this.dispatchEvent(new FilterEvent(FilterEvent.PROCESS_COMPLETE));
		}
	}
}