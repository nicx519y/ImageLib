/***
 * @class	上传图片数据，支持BitmapData和ByteArray，可设置最大容量，最大尺寸，上传前会自动进行压缩处理
 */
package com.imagelib
{
	import flash.display.BitmapData;
	import flash.display.JPEGEncoderOptions;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.external.ExternalInterface;
	import flash.geom.Rectangle;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.utils.ByteArray;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;
	import flash.utils.setTimeout;
	
	import baidu.lib.images.FileValidate;
	import baidu.lib.serialization.JSON;
	import baidu.local.PicStandardizer;
	import baidu.local.StaticLib;
	import baidu.local.UploadPostHelper;
	
	public class ImageDataUploader extends EventDispatcher
	{
		private var _fileName:String;							//文件名
		private var _uploadURL : String;						//上传url
		private var _requestVariables : Object;					//上传的参数
		
		private var _intervalID : int;							//这个是用于使用urlloader上传的时候模拟进度的
		private var _percent : Number = 0; //上传百分比
		private var _simulationMaxPercent : int = 0; //模拟百分比时可以达到的最大百分比，压缩的时候模拟百分比最大定为30，编码可以正常拿到百分比。上传从50开始模拟到90
		private var _simulationPercentIncremental : int = 0; //模拟百分比时每次的增量
		private var _compressedPersend : int = 0; //压缩完成后的进度
		private var _fileURLLoader : URLLoader;					//上传
		private var _fileData:*;
		private var _response:Object;
		public var errorCode:int;
		public var errorMessage:String;
		public var responeData:Object = null; //上传成功后返回的数据
		
		private var _maxSize:Number;	
		private var _maxWidth : Number;			
		private var _maxHeight : Number;	
		
		//文件状态
		private var _uploadStatus : String = 'item_upload_normal';		
		public static const STATE_UPLOAD_NORMAL : String = "item_upload_normal";						//还未上传未压缩
		public static const STATE_UPLOAD_COMPRESSING : String = "item_upload_compressing";			//正在压缩
		public static const STATE_UPLOAD_WAITING : String = "item_upload_waiting";					//压缩完毕，等待上传
		public static const STATE_UPLOAD_UPLOADING : String = "item_upload_uploading";				//正在上传
		public static const STATE_UPLOAD_COMPLETE : String = "item_upload_complete";	//完成上传，成功
		public static const STATE_UPLOAD_FAIL : String = "item_upload_fail";		//完成上传，失败
		
		//事件
		public static const ERROR : String = "item_event_error";			//上传，发生错误
		public static const UPLOAD_COMPLETE : String = "item_event_upload_complete";		//上传完成
		public static const COMPRESS_COMPLETE : String = "item_event_compress_complete";		//压缩完成
		
		private var _picStandardizer:PicStandardizer;
		
		//错误
		public static const ERROR_FILE_SIZE_OVERFLOW:Object = {
			no: 1,
			msg: '文件大小超出限制'
		};
		public static const ERROR_NETWORK_ERROR:Object = {
			no: 2,
			msg: '网络错误'
		};
		
		public function ImageDataUploader(
			fileName:String,						//文件名 
			imageData:*,	 						//文件数据
			upUrl:String, 							//上传URL
			maxSize:Number = 3, 					//最大容量
			maxWidth:Number = 3000, 				//最大宽度
			maxHeight:Number = 3000					//最大高度
		)
		{
			_fileName = fileName;
			
			/*if(imageData is BitmapData){
				var data:BitmapData = (imageData as BitmapData);
				_fileData = data.encode(new Rectangle(0, 0, data.width, data.height), new JPEGEncoderOptions());
			}else if(imageData is ByteArray){
				_fileData = imageData;
			}*/
			_fileData = imageData;
			
			_maxSize = maxSize * 1024 * 1024;
			_maxWidth = maxWidth;
			_maxHeight = maxHeight;
			_fileURLLoader = new URLLoader();
			_bindEvent();
			_uploadURL = upUrl;
		}
		public function get uploadStatus():String{
			return _uploadStatus;
		}
		public function get percent():int{
			return _percent;
		}
		public function get response():Object{
			return _response;
		}
		public function get fileName():String
		{
			return _fileName;
		}
		
		/**
		 * 设置上传参数
		 * value 上传参数对象
		 * 
		 */
		public function set requestVariables(value : Object) : void {
			if (value) {
				_requestVariables = value;
			}
		}
		
		public function startUpload():void
		{
			_compress();
		}
		
		/**
		 * 压缩文件
		 * TODO:使用worker时，如果最终编码后的大小比maxSize大则再压缩的时候没有再次使用worker。但是这种几率比较小
		 * 
		 */	
		private function _compress():void{
			
			if(!_fileData || !((_fileData is ByteArray) || (_fileData is BitmapData))) return;
			_uploadStatus = STATE_UPLOAD_COMPRESSING; //设置压缩
			if(_fileData is ByteArray && !FileValidate.isImage(_fileData)){ //文件格式错误
				errorHandler('', ERROR_NETWORK_ERROR.no, ERROR_NETWORK_ERROR.msg);
				return;
			}
			_percent = 1; //进度开始
			
			_commonCompress();
			
		}
		
		/**
		 * 绑定各种事件
		 * 
		 */
		private function _bindEvent() : void {
			_fileURLLoader.addEventListener(Event.COMPLETE, urlUploadCompleteDataHandler); //上传成功
			_fileURLLoader.addEventListener(IOErrorEvent.IO_ERROR, _uploadError); //上传失败
			_fileURLLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, _uploadError); //上传失败
		}
		
		private function _unbindEvent():void
		{
			_fileURLLoader.removeEventListener(Event.COMPLETE, urlUploadCompleteDataHandler); //上传成功
			_fileURLLoader.removeEventListener(IOErrorEvent.IO_ERROR, _uploadError); //上传失败
			_fileURLLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, _uploadError); //上传失败
		}
		
		/**/
		
		private function _commonCompress():void{
			_picStandardizer = new PicStandardizer(_maxWidth, _maxHeight, _maxSize);
			_picStandardizer.addEventListener(Event.COMPLETE, _picStandardizerComplete);
			_picStandardizer.addEventListener(ProgressEvent.PROGRESS, updateProgress);
			_picStandardizer.addEventListener(ErrorEvent.ERROR, errorHandler); //错误
			_picStandardizer.standardizeBMP(_fileData);
		}
		
		private function _picStandardizerComplete(evt:Event) : void{
			_picStandardizer.removeEventListener(Event.COMPLETE, _picStandardizerComplete);
			_picStandardizer.removeEventListener(ProgressEvent.PROGRESS, updateProgress);
			_picStandardizer.removeEventListener(ErrorEvent.ERROR, errorHandler); //错误
			var _data:ByteArray = _picStandardizer.dataBeenStandaized;
			_initUpload(_data); //上传了
			_upload();
		}
		
		private function updateProgress(event : ProgressEvent) : void {
			_percent = 1 + 99 * event.bytesLoaded / event.bytesTotal;
		}
		
		/**
		 * 编码+压缩完成,设置压缩后的byte，更新状态 准备上传
		 * 
		 */	
		private function _initUpload(data:ByteArray):void{
			_fileData = data;
			if(_fileData.length > _maxSize){ //超出最大限制
				errorHandler('', ERROR_FILE_SIZE_OVERFLOW.no, ERROR_FILE_SIZE_OVERFLOW.msg);
				return;
			}
			_uploadStatus = STATE_UPLOAD_WAITING; //压缩完成
			StaticLib.consoleB('压缩编码都完成了'+(new Date()).toLocaleString());
			_setCompressedStatus();
		}
		
		//执行上传
		private function _upload():void{
			var date:Date = new Date();
			StaticLib.consoleB('准备开始上传文件'+date.toLocaleString());
			if(_uploadStatus != STATE_UPLOAD_WAITING){ //不是等待上传（压缩完成）的状态
				return;
			}
			_uploadStatus = STATE_UPLOAD_UPLOADING; //正在上传
			
			//构造数据对象
			var variables:URLVariables = new URLVariables();
			
			for (var pro:String in _requestVariables) {
				variables[pro] = _requestVariables[pro];
			}
			
			var urlRequest : URLRequest = new URLRequest(_uploadURL);
			
			//模拟上传进度
			clearInterval(_intervalID);
			_simulationMaxPercent = 95;
			_simulationPercentIncremental = 5;			
			_intervalID = setInterval(progressHandlerURLLoader, 500);
			
			urlRequest.method = URLRequestMethod.POST;
			urlRequest.data = UploadPostHelper.getPostData(_fileName, _fileData, "file", variables);
			urlRequest.requestHeaders.push(new URLRequestHeader('Cache-Control', 'no-cache'));
			urlRequest.requestHeaders.push(new URLRequestHeader('Content-Type', 'multipart/form-data; boundary=' + UploadPostHelper.getBoundary()));
			_fileURLLoader.dataFormat = URLLoaderDataFormat.BINARY;
			
			StaticLib.consoleB('开始上传文件'+date.toLocaleString());
			
			_fileURLLoader.load(urlRequest);
		}
		
		/**
		 * 使用urllloader模拟进度
		 */
		private function progressHandlerURLLoader() : void {
			StaticLib.console('console.log', '当前进度：'+_percent+'最大'+_simulationMaxPercent+'增量'+_simulationPercentIncremental);	
			if (_uploadStatus != STATE_UPLOAD_NORMAL && _uploadStatus != STATE_UPLOAD_WAITING) {
				if (_percent < _simulationMaxPercent) {
					if (!_percent || isNaN(_percent) || _percent < 0) {
						_percent = 0;
					}
					_percent += _simulationPercentIncremental;
					
				}else {
					clearInterval(_intervalID);
				}
			}
		}
		
		/**
		 * 上传事件：上传完成，拿到服务端返回数据
		 */
		private function urlUploadCompleteDataHandler(evt : Event = null) : void {
			_unbindEvent();
			clearInterval(_intervalID);
			var resultString : String = evt.target.data;
			StaticLib.consoleB('上传完成，数据位'+evt.target.data);
			try {
				_response = baidu.lib.serialization.JSON.decode(resultString);
				_uploadStatus = STATE_UPLOAD_COMPLETE;
				_setCompleteStatus();
			}catch (err:Error) {
				_response = resultString;
				errorHandler(evt, ERROR_NETWORK_ERROR.no, ERROR_NETWORK_ERROR.msg);
			}
		}
		
		/**
		 * 上传失败
		 * */
		private function _uploadError(evt:* = null):void{
			
			_unbindEvent();
			clearInterval(_intervalID);
			_setCompleteStatus();
			errorHandler(evt, ERROR_NETWORK_ERROR.no, ERROR_NETWORK_ERROR.msg);
		}
		
		/**
		 * 失败处理
		 */
		private function errorHandler(evt:* = null, code = '', message = '') : void {
			
			clearInterval(_intervalID);
			_setCompleteStatus();
			errorCode = code;
			errorMessage = message;
			_uploadStatus = STATE_UPLOAD_FAIL;
			StaticLib.console('console.log', 'error'+errorCode+errorMessage);
			dispatchEvent(new Event(ERROR, false, false));
		}
		
		/**
		 * 设置压缩完成状态
		 * 
		 * */
		private function _setCompressedStatus():void{
			dispatchEvent(new Event(COMPRESS_COMPLETE, false, false));
		}
		
		/**
		 * 设置上传完成状态
		 * 
		 * */
		private function _setCompleteStatus():void{
			_percent = 100;
			dispatchEvent(new Event(UPLOAD_COMPLETE, false, false));
		}
		
		/**
		 * 重置文件
		 * 
		 * */
		public function reset():void{
			errorCode = 0;
			errorMessage = null;
			responeData = null;
			_percent = 0;			
		}
		public function dispose():void
		{
			_unbindEvent();
			reset();
		}
	}
}