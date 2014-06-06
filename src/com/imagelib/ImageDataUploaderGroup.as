package com.imagelib
{
	import com.imagelib.ImageDataUploader;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	

	public class ImageDataUploaderGroup extends EventDispatcher
	{
		public static const STATUS_NORMAL:int = 0;
		public static const STATUS_RUNNING:int = 1;
		public static const EVENT_ALL_COMPLETE:String = 'all_complete';
		public static const EVENT_ALL_SUCCESS:String = 'all_success';
		
		private var _status:int = STATUS_NORMAL;
		private var _uploaderlist:Array;
		private var _errorNum:int;
		private var _responseObj:Object;
		
		public function ImageDataUploaderGroup()
		{
			_uploaderlist = [];
			_responseObj = {};
		}
		public function addUploader(
			fileName:String,						//文件名 
			imageData:*,	 						//文件数据
			upUrl:String, 							//上传URL
			maxSize:Number = 3, 					//最大容量
			maxWidth:Number = 3000, 				//最大宽度
			maxHeight:Number = 3000					//最大高度
		):void
		{
			if(_status == STATUS_RUNNING) return;
			
			var uploader:ImageDataUploader = new ImageDataUploader(fileName, imageData, upUrl, maxSize, maxWidth, maxHeight);
			uploader.addEventListener(ImageDataUploader.UPLOAD_COMPLETE, _uploadCompleteHandler);
			uploader.addEventListener(ImageDataUploader.ERROR, _uploadErrorHandler);
			
			_uploaderlist.push(uploader);
		}
		public function removeAllUploaders():void
		{
			if(_status == STATUS_NORMAL) return;
			
			while(_uploaderlist.length > 0){
				removeUploader(_uploaderlist[0] as ImageDataUploader);
			}
			_status = STATUS_NORMAL;
		}
		public function removeUploader(uploader:ImageDataUploader):void
		{
			uploader.removeEventListener(ImageDataUploader.UPLOAD_COMPLETE, _uploadCompleteHandler);
			uploader.removeEventListener(ImageDataUploader.ERROR, _uploadErrorHandler);
			
			var idx:int = _uploaderlist.indexOf(uploader);
			if(idx >= 0){
				_uploaderlist.splice(idx, 1);
			}
		}
		public function startUpload():void
		{
			if(_status == STATUS_RUNNING || _uploaderlist.length <= 0) return;
			_status = STATUS_RUNNING; 
			_errorNum = 0;
			_responseObj = {};
			
			for(var i:int = 0, len:int = _uploaderlist.length; i < len; i ++){
				(_uploaderlist[i] as ImageDataUploader).startUpload();
			}				
		}
		public function get errorNum():int
		{
			return _errorNum;
		}
		public function get response():Object
		{
			return _responseObj;
		}
		private function _uploadCompleteHandler(evt:Event):void
		{
			var uploader:ImageDataUploader = evt.target as ImageDataUploader;
			
			_responseObj[uploader.fileName] = uploader.response;
			
			removeUploader(uploader);
			_dispatchEvent();
		}
		private function _uploadErrorHandler(evt:Event):void
		{
			var uploader:ImageDataUploader = evt.target as ImageDataUploader;
			removeUploader(uploader);
			_errorNum ++;
			_dispatchEvent();
		}
		private function _dispatchEvent():void
		{
			if(_uploaderlist.length > 0) return;
			removeAllUploaders();
			this.dispatchEvent(new Event(EVENT_ALL_COMPLETE));
			
			if(_errorNum == 0)
				this.dispatchEvent(new Event(EVENT_ALL_SUCCESS));
		}
	}
}






