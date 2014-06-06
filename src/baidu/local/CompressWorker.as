package baidu.local
{
	import flash.display.Sprite;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.net.FileReference;
	import flash.system.MessageChannel;
	import flash.system.Worker;
	import flash.utils.ByteArray;
	
	public class CompressWorker extends Sprite
	{	
		private const COMPRESS_AREA_SIZE : Number = 1600;
		private var _rotationAngle : Number = 0;				//以弧度为单位的旋转角度
		private var _encodePercent : Number = 0; //编码百分比
		private var _maxSize : Number;						//大小限制
		private var _maxWidth : Number;				//最终图片的最大尺寸
		private var _maxHeight : Number;				//最终图片的最大尺寸
		//创建到worker的MessageChannel通信对象
		private var mainToBack:MessageChannel;
		
		//创建来自worker的MessageChannel通信对象并添加监听.
		private var backToMain:MessageChannel ;
		private var _file:FileReference;
		private var _compressing:Boolean = false;//是否正在压缩
		private var _picStandardizer:PicStandardizer;
		public function CompressWorker()
		{
			//获取当前worker线程的引用(自身)
			var worker:Worker = Worker.current;
			
			//监听mainToBack的SHARPEN事件
			mainToBack = worker.getSharedProperty("mainToBack") as MessageChannel;
			mainToBack.addEventListener(Event.CHANNEL_MESSAGE, onMainToBack);
			//使用backToMain抛出SHARPEN_COMPLETE命令
			backToMain = worker.getSharedProperty("backToMain") as MessageChannel;
			
			_maxSize = worker.getSharedProperty("maxSize") as Number;
			
			_maxWidth = worker.getSharedProperty("maxWidth") as Number;
			
			_maxHeight = worker.getSharedProperty("maxHeight") as Number;
			
			//从共享属性缓存池里获取位图数据。
			_file = worker.getSharedProperty("file") as FileReference;
			
		}
		
		/**
		 * 收到压缩请求后立即开始压缩
		 * */
		protected function onMainToBack(event:Event):void {
			try{
				backToMain.send({type: "log", value: 'i receiveeeeeeeeeee:'});
				if(mainToBack.messageAvailable && !_compressing){
					//获取消息类型
					_compressing = true;
					
					backToMain.send({type: "log", value: 'i receive:'});
					beginCompress();
				}
			}catch(myError:Error){
				backToMain.send({type: "error", value: myError.message});
			}
		}
		private function beginCompress():void{
			_picStandardizer = new PicStandardizer(_maxWidth, _maxHeight, _maxSize);
			_picStandardizer.addEventListener(Event.COMPLETE, _picStandardizerComplete);
			_picStandardizer.addEventListener(ProgressEvent.PROGRESS, updateProgress);
			_picStandardizer.addEventListener(ErrorEvent.ERROR, errorHandler); //错误
			_picStandardizer.standardize(_file);
		}
		
		private function updateProgress(event : ProgressEvent) : void {
			_encodePercent = event.bytesLoaded / event.bytesTotal;
			backToMain.send({type: "encodePercent", value: _encodePercent});
		}
		
		/**
		 * 编码完成
		 * */
		private function _picStandardizerComplete(evt:Event) : void{
			var _data:ByteArray = _picStandardizer.dataBeenStandaized;
			backToMain.send({type: "complete", value: _data});
		}
		
		/**
		 * 错误处理
		 * */
		private function errorHandler(evt:* = null) : void {
			backToMain.send({type: "error", value: evt && evt.message});
		}
	}
}

