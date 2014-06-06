package baidu.local
{	
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.external.ExternalInterface;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	
	import baidu.lib.serialization.JSON;


	public class UploadBase64{
		private var _errorCode:int = 0;
		private var _errorMessage:String = '';
		private var _responeData:Object = null; //上传
		private var _callBack:String = ''; //上传
		public function UploadBase64(uploadURL:String, base64:String, callBack:String) {
			_callBack = callBack;
			var loader:URLLoader = new URLLoader();
			configureListeners(loader);
			var urlRequest:URLRequest = new URLRequest(uploadURL);
			urlRequest.method = URLRequestMethod.POST;
			
			var variables:URLVariables = new URLVariables();
			variables.filetype = 'base64';
			variables.file = base64;
			urlRequest.data = variables;
			
			try {
				loader.load(urlRequest);
			} catch (error:Error) {
				trace("Unable to load requested document.");
			}
		}
		
		private function configureListeners(dispatcher:IEventDispatcher):void {
			dispatcher.addEventListener(Event.COMPLETE, completeHandler);
			dispatcher.addEventListener(Event.OPEN, openHandler);
			dispatcher.addEventListener(ProgressEvent.PROGRESS, progressHandler);
			dispatcher.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
			dispatcher.addEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler);
			dispatcher.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
		}
		
		private function completeHandler(event:Event):void {
			var loader:URLLoader = URLLoader(event.target);
			_responeData = baidu.lib.serialization.JSON.decode(loader.data);
			_doCallBack(0, '');
		}
		
		private function openHandler(event:Event):void {
		}
		
		private function progressHandler(event:ProgressEvent):void {
		}
		
		private function securityErrorHandler(event:SecurityErrorEvent):void {
			_doCallBack(1, '上传失败:securityError');
		}
		
		private function httpStatusHandler(event:HTTPStatusEvent):void {
		}
		
		private function ioErrorHandler(event:IOErrorEvent):void {
			_doCallBack(1, '上传失败:ioError');
		}
		/**
		 * 向js抛出事件
		 * */
		private function _doCallBack(errorCode:int, errorMessage:String):void{
			ExternalInterface.call(_callBack, {
				errorCode: errorCode
				,errorMessage: errorMessage
				,response: _responeData
			});
		}
	}
}
