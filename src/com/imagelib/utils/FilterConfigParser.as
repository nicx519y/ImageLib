package com.imagelib.utils
{
	import com.imagelib.filters.BlendMaskFilter;
	import com.imagelib.filters.BrightnessFilter;
	import com.imagelib.filters.ContrastFilter;
	import com.imagelib.filters.CurveFilter;
	import com.imagelib.filters.CustomFilter;
	import com.imagelib.filters.FiltersCollection;
	import com.imagelib.filters.FuguFilter;
	import com.imagelib.filters.HueFilter;
	import com.imagelib.filters.SaturationFilter;
	import com.imagelib.filters.SharpenFilter;
	import com.imagelib.filters.ThresholdFilter;
	
	import flash.external.ExternalInterface;
	import flash.filters.BlurFilter;
	import flash.geom.Rectangle;

	public class FilterConfigParser
	{
		public function FilterConfigParser()
		{
		}
		public static function parse(config:Object):Array
		{
			var name:String = config.name,
				filesData:Object = config.filesData,
				step:Array = config.filterStep,
				result:Array = [];
			
			for(var i:int = 0, len:int = step.length; i < len; i ++){
				result.push(_getFilter(step[i], filesData));
			}
			
			return result;
		}
		public static function toFiltersCollection(config:Object):FiltersCollection
		{
			var result:FiltersCollection = new FiltersCollection();
			result.content = parse(config);
			return result;
		}
		private static function _getFilter(filterConfig:Object, filesData:Object):*
		{
			
			var filter:*;
			var type:String = filterConfig.worker;
			var sourceName:String = filterConfig['data'];
			
			if(sourceName)
				var source:String = filesData[sourceName]['url'];
			
			var options:Object = filterConfig.options;
			
			switch(type){
				case 'curve':
					filter = new CurveFilter(source);
					break;
				case 'blend':
					filter = new BlendMaskFilter(source, options.mode, options.opacity||1, options.scaleMode);
					break;
				case 'saturation':
					filter = new SaturationFilter(options.r||0, options.g||0, options.b||0);
					break;
				case 'hue':
					filter = new HueFilter(options.r||0, options.g||0, options.b||0);
					break;
				case 'brightness':
					filter = new BrightnessFilter(options.brightness||0);
					break;
				case 'contrast':
					filter = new ContrastFilter(options.r||0, options.g||0, options.b||0);
					break;
				case 'threshold':
					filter = new ThresholdFilter(options.n||0);
					break;
				case 'sharpen':
					filter = new SharpenFilter(options.depth||0);
					break;
				case 'blur':
					filter = new BlurFilter(options.blurX||0, options.blurY||0, options.quality||1);
					break;
				case 'fugu':
					filter = new FuguFilter();
					break;
			}
			
			
			
			return filter;
		}
	}
}