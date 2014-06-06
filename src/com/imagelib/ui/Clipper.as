package com.imagelib.ui
{
	import com.imagelib.mouse.CustomMouse;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	import flash.ui.MouseCursorData;
	
	public class Clipper extends Sprite
	{
		private var _iconPath:String;
		
		private var _container:Sprite = new Sprite(); //裁剪UI容器
		private var _mask:Sprite = new Sprite(); //遮罩
		private var _currentRect:Rectangle = new Rectangle(); //当前裁剪框的rect
		private var _clipRect:Rectangle; //需要裁剪的rect
		private var _parent:*; //父容器
		
		private var _minWidth:int; //裁剪框宽度
		private var _minHeight:int; //裁剪框高度
		private var _resizeAble:Boolean; //裁剪框是否可以缩放
		private var _limitZoom:Boolean; //是否等比缩放
		
		private var _resizeNW:Sprite; //西北方向缩放按钮
		private var _resizeNE:Sprite; //东北方向缩放按钮
		private var _resizeSW:Sprite; //西南方向缩放按钮
		private var _resizeSE:Sprite; //东南方向缩放按钮
		
		private var _submitBtn:Sprite = new Sprite();
		private var _cancelBtn:Sprite = new Sprite();
		
		private var _cursorMove:Sprite = new Sprite(); //移动光标
		private var _cursorNESW:Sprite = new Sprite(); //东北、西南方向光标
		private var _cursorNWSE:Sprite = new Sprite(); //东南、西北方向光标
		private var _currentCursor:Sprite = new Sprite(); //当前光标
		
		private var _resizeStartRect:Rectangle = new Rectangle(); //缩放初始时容器的X坐标
		private var _resizeStartMouseX:int; //缩放初始时鼠标的X坐标
		private var _resizeStartMouseY:int; //缩放初始时鼠标的Y坐标
		
		private var _resizeActive:Boolean = false; //是否正在缩放中
		private var _resizeTarget:Sprite; //拖动元素
		
		[Embed(source="../../../../images/cancel.png")]
		private var CancelImg:Class;
		
		[Embed(source="../../../../images/submit.png")]
		private var SubmitImg:Class;
		
		public function Clipper(
			parent:*, minWidth:int = 100, 
			minHeight:int = 100, 
			clipRect:Rectangle = null, 
			resizeAble:Boolean = true, 
			limitZoom:Boolean = false, 
			showButton:Boolean = true,
			iconPath:String='../images/'		//UI图标文件路径
		){
			_iconPath = iconPath;
			_parent = parent;
			_minWidth = minWidth; 
			_minHeight = minHeight; //裁剪框高度
			_resizeAble = resizeAble; //是否支持改变大小
			_limitZoom = limitZoom; //是否限制宽高比
			_buildUI();
			_bindEvent();
			_setStyle();  
			_container.visible = false;
			_mask.visible = false;
			if(clipRect){
				initClipRect(clipRect);
			}
			if(!showButton){
				_submitBtn.visible = false;
				_cancelBtn.visible = false;
			}
			parent.addChild(_mask);
			_container.name="container";
			parent.addChild(_container);
			
			/**
			 * 注册鼠标样式
			 */
			CustomMouse.registerCursors([
				CustomMouse.CURSOR_NESW,
				CustomMouse.CURSOR_NWSE
			]);
			
			
		}
		
		/**
		 * 初始化裁剪区域、剪裁框
		 * */
		public function initClipRect(clipRect:Rectangle):void{
			_clipRect = new Rectangle(
				Math.floor(clipRect.x),
				Math.floor(clipRect.y),
				Math.ceil(clipRect.width),
				Math.ceil(clipRect.height)
			);
			_mask.x = _clipRect.x;
			_mask.y = _clipRect.y;
			if(_limitZoom){
				var tempW:int = _minWidth;
				var tempH:int = _minHeight;
				var aspectRation:Number = _minWidth / _minHeight;
				if(aspectRation > _clipRect.width / _clipRect.height){
					tempW = Math.max(_clipRect.width * 1/2, _minWidth);
					tempH = tempW / aspectRation;
				}else{
					tempH = Math.max(_clipRect.height * 1/2, _minHeight);
					tempW = tempH * aspectRation;
				}
				with(_currentRect){
					x = _clipRect.x + (_clipRect.width - tempW) / 2;
					y = _clipRect.y + (_clipRect.height - tempH) / 2;
					width = tempW;
					height = tempH;
				}
			}else{
				with(_currentRect){
					x = Math.round(_clipRect.x + _clipRect.width * 1/4);
					y = Math.round(_clipRect.y + _clipRect.height * 1/4);
					width = Math.round(_clipRect.width * 1/2);
					height = Math.round(_clipRect.height * 1/2);
				}
			}
			_render();			
		}
		
		/**
		 * 获取裁剪结果
		 * */
		public function getClipRect():Rectangle{
			//ExternalInterface.call('console.log', 'w:' + _currentRect.width + ', h:' + _currentRect.height);
			return new Rectangle(
				_currentRect.x - _clipRect.x,
				_currentRect.y - _clipRect.y,
				_currentRect.width,
				_currentRect.height
			);
		}
		
		public function begin():void{
			_container.visible = true;
			_mask.visible = true;
		}
		
		public function end():void{
			_container.visible = false;
			_mask.visible = false;
		}
		
		/**
		 * 设置样式、大小
		 * */
		private function _setStyle():void{
			with(_container.graphics){
				lineStyle(1, 0xffffff, 0.3);
			}
		}
		
		
		
		private function _buildUI():void{
			_resizeNW = new Sprite();
			_resizeNW.name = 'resizeNW';
			_resizeNW.graphics.lineStyle(1, 0xffffff);
			_resizeNW.graphics.beginFill(0x00ff00, 0.5);
			_resizeNW.graphics.drawCircle(5, 5, 5);
			_container.addChild(_resizeNW);
			
			_resizeNE = new Sprite();
			_resizeNE.name = 'resizeNE';
			_resizeNE.graphics.lineStyle(1, 0xffffff);
			_resizeNE.graphics.beginFill(0x00ff00, 0.5);
			_resizeNE.graphics.drawCircle(5, 5, 5);
			_container.addChild(_resizeNE);
			
			_resizeSW = new Sprite();
			_resizeSW.name = 'resizeSW';
			_resizeSW.graphics.lineStyle(1, 0xffffff);
			_resizeSW.graphics.beginFill(0x00ff00, 0.5);
			_resizeSW.graphics.drawCircle(5, 5, 5);
			_container.addChild(_resizeSW);
			
			_resizeSE = new Sprite();
			_resizeSE.name = 'resizeSE';
			_resizeSE.graphics.lineStyle(1, 0xffffff);
			_resizeSE.graphics.beginFill(0x00ff00, 0.5);
			_resizeSE.graphics.drawCircle(5, 5, 5);
			_container.addChild(_resizeSE);
			
			if(!_resizeAble){
				_resizeNW.visible = false;
				_resizeNE.visible = false;
				_resizeSW.visible = false;
				_resizeSE.visible = false;
			}
			
			var submitImg:Bitmap = new SubmitImg;
			submitImg.x = -7;
			submitImg.y = -6;
			_submitBtn.addChild(submitImg);
			
			_setButtonStyle(_submitBtn, false);			
			_container.addChild(_submitBtn);
			
			var cancelImg:Bitmap = new CancelImg;
			cancelImg.x = -5;
			cancelImg.y = -6;
			_cancelBtn.addChild(cancelImg);
			
			_setButtonStyle(_cancelBtn, false);		
			_container.addChild(_cancelBtn);
		}
		
		
		private function _bindEvent():void{
			_parent.stage.addEventListener(MouseEvent.MOUSE_MOVE, _parentMoveHandler);
			_parent.stage.addEventListener(MouseEvent.MOUSE_UP, _parentClickHandler);
			_parent.stage.addEventListener(MouseEvent.CLICK, _parentClickHandler);
			_container.addEventListener(MouseEvent.MOUSE_MOVE, _containerMoveHandler);
			_container.addEventListener(MouseEvent.ROLL_OUT, _containerOutHandler);
			
			
			_resizeNW.addEventListener(MouseEvent.MOUSE_DOWN, _initResize);
			_resizeNE.addEventListener(MouseEvent.MOUSE_DOWN, _initResize);
			_resizeSW.addEventListener(MouseEvent.MOUSE_DOWN, _initResize);
			_resizeSE.addEventListener(MouseEvent.MOUSE_DOWN, _initResize);
			_container.addEventListener(MouseEvent.MOUSE_DOWN, _initResize);
			
			_submitBtn.addEventListener(MouseEvent.CLICK, _submitClip);
			_cancelBtn.addEventListener(MouseEvent.CLICK, _cancelClip);
			
			_submitBtn.addEventListener(MouseEvent.ROLL_OVER, _buttonToggle);
			_cancelBtn.addEventListener(MouseEvent.ROLL_OVER, _buttonToggle);
			_submitBtn.addEventListener(MouseEvent.ROLL_OUT, _buttonToggle);
			_cancelBtn.addEventListener(MouseEvent.ROLL_OUT, _buttonToggle);
		}
		
		
		
		/**
		 * 渲染裁剪框
		 * */
		private function _render():void{
			var x:int = _currentRect.x;
			var y:int = _currentRect.y;
			var w:int = _currentRect.width;
			var h:int = _currentRect.height;
			
			_container.x = x;
			_container.y = y;
			
			_resizeNW.x = - 5;
			_resizeNW.y = - 5;
			
			_resizeNE.x = w - 5;
			_resizeNE.y = - 5;
			
			_resizeSW.x = - 5;
			_resizeSW.y = h - 5;
			
			_resizeSE.x = w - 5;
			_resizeSE.y = h - 5;
			
			
			with(_mask.graphics){
				clear();
				beginFill(0xffffff, 0.5);
				drawRect(0, 0, _clipRect.width, y - _clipRect.y);
				drawRect(0, y - _clipRect.y + h, _clipRect.width, _clipRect.height - (y  - _clipRect.y) - h);
				drawRect(0, y - _clipRect.y, x - _clipRect.x, h);
				drawRect(x + w - _clipRect.x, y - _clipRect.y, (_clipRect.x + _clipRect.width) - (x + w), h);
				endFill();
			}
			with(_container.graphics){
				clear();
				_setStyle();
				beginFill(0xffffff, 0);
				drawRect(0, 0, w, h);
				//第一条竖线
				moveTo(w * 1/3, 0);
				lineTo(w * 1/3, h);
				
				//第二条竖线
				moveTo(w * 2/3, 0);
				lineTo(w * 2/3, h);
				
				//第一条横线
				moveTo(0, h * 1/3);
				lineTo(w, h * 1/3);
				
				//第二条横线
				moveTo(0, h * 2/3);
				lineTo(w, h * 2/3);	
				endFill();
			}
			
			_submitBtn.x = w / 2 - 20;
			_cancelBtn.x = w / 2 + 15;
			if(_currentRect.y + _currentRect.height < _clipRect.y + _clipRect.height - 30){
				_submitBtn.y = h + 20;
				_cancelBtn.y = h + 20;
			}else{
				_submitBtn.y = h - 15;
				_cancelBtn.y = h - 15;
			}
			
		}
		
		/**
		 * 初始化缩放
		 * */
		private function _initResize(evt:MouseEvent):void{
			//_container.startDrag();
			_resizeTarget = evt.target as Sprite;
			if(_resizeTarget && (_submitBtn.contains(_resizeTarget) || _cancelBtn.contains(_resizeTarget))){
				return;
			}
			evt.stopPropagation();
			
			_resizeActive = true;
			
			_resizeStartRect.x = _currentRect.x;
			_resizeStartRect.y = _currentRect.y;
			_resizeStartRect.width = _currentRect.width;
			_resizeStartRect.height = _currentRect.height;
			_resizeStartMouseX = evt.stageX; //缩放初始时鼠标的X坐标
			_resizeStartMouseY = evt.stageY; //缩放初始时鼠标的Y坐标
		}
		
		private function _containerMoveHandler(evt:MouseEvent):void{
			if(_resizeActive){
				return;
			}
			var target:Sprite = evt.target as Sprite;
			if(target){
				switch(target){
					case _resizeNW:
					case _resizeSE:
						CustomMouse.showCursor(CustomMouse.CURSOR_NWSE);
						break;
					case _resizeNE:
					case _resizeSW:
						CustomMouse.showCursor(CustomMouse.CURSOR_NESW);
						break;
					default:
						if(target && _submitBtn.contains(target) || _cancelBtn.contains(target)){
							Mouse.cursor = MouseCursor.BUTTON;
							break;
						}else{
							Mouse.cursor = MouseCursor.HAND;
						}
						
				}
			}
		}
		private function _containerOutHandler(evt:MouseEvent):void{
			if(_resizeActive){
				return;
			}
			Mouse.cursor = MouseCursor.AUTO;
		}
		
		/**
		 * 鼠标移动事件
		 * */
		private function _parentMoveHandler(evt:MouseEvent):void{
			
			if(!_resizeActive){
				return;
			}
			
			var changeX:int = evt.stageX - _resizeStartMouseX; //鼠标x变化量
			var changeY:int = evt.stageY - _resizeStartMouseY; //鼠标Y变化量
			var vectorX:int;		//鼠标X轴每移动1像数，left应移动的像数值
			var vectorY:int; 		//鼠标Y轴每移动1像数，top应移动的像数值
			var vectorWidth:int; 	//鼠标X轴每移动1像数，width应移动的像数值
			var vectorHeight:int; 	//鼠标Y轴每移动1像数，height应移动的像数值
			var aspectRatio:Number = _minWidth /_minHeight;
			
			
			/**
			 * 设置裁剪容器的坐标和裁剪区域
			 * */
			switch(_resizeTarget){
				case _resizeNW:
					vectorX = 1;
					vectorY = 1;
					vectorWidth = -1;
					vectorHeight = -1;
					break;
				case _resizeNE:
					vectorX = 0;
					vectorY = 1;
					vectorWidth = 1;
					vectorHeight = -1;
					break;
				case _resizeSW:
					vectorX = 1;
					vectorY = 0;
					vectorWidth = -1;
					vectorHeight = 1;
					break;
				case _resizeSE:
					vectorX = 0;
					vectorY = 0;
					vectorWidth = 1;
					vectorHeight = 1;
					break;
				default:
					vectorX = 1;
					vectorY = 1;
					vectorWidth = 0;
					vectorHeight = 0;
			}
			var targetRect:Rectangle = new Rectangle(
				_resizeStartRect.x + changeX * vectorX, 
				_resizeStartRect.y + changeY * vectorY, 
				_resizeStartRect.width + changeX * vectorWidth, 
				_resizeStartRect.height + changeY * vectorHeight);
			if(_limitZoom){
				targetRect.y += (targetRect.height - targetRect.width / (_minWidth /_minHeight)) * vectorY;
				targetRect.height = targetRect.width / aspectRatio;
			}
			
			//宽度过小
			if(targetRect.width < _minWidth){
				//ExternalInterface.call('console.log', '宽度过小', targetRect, _minWidth);
				targetRect.x -= (_minWidth - targetRect.width) * vectorX;
				targetRect.width = _minWidth;
			}
			//高度过小
			if(targetRect.height < _minHeight){
				//ExternalInterface.call('console.log', '跨界2', targetRect);
				targetRect.y -= (_minHeight - targetRect.height) * vectorY;
				targetRect.height = _minHeight;
			}
			//左跨界
			if(targetRect.x < _clipRect.x){
				
				targetRect.width -= (targetRect.x - _clipRect.x) * vectorWidth;
				targetRect.x = _clipRect.x;
				if(_limitZoom){
					targetRect.y -= Math.round(targetRect.width / aspectRatio - targetRect.height) * vectorY;
					targetRect.height = Math.round(targetRect.width / aspectRatio);
				}
				//ExternalInterface.call('console.log', '跨界3', targetRect, aspectRatio);
			}
			//上跨界
			if(targetRect.y < _clipRect.y){
				//ExternalInterface.call('console.log', '跨界4', targetRect);
				targetRect.height -= (targetRect.y - _clipRect.y) * vectorHeight;
				targetRect.y = _clipRect.y;
				if(_limitZoom){
					targetRect.x -= Math.round(targetRect.height * aspectRatio - targetRect.width) * vectorX;
					targetRect.width = Math.round(targetRect.height * aspectRatio);
				}
			}
			//右跨界
			if(targetRect.x + targetRect.width > _clipRect.x + _clipRect.width){
				//ExternalInterface.call('console.log', '跨界5', targetRect);
				targetRect.width -= (targetRect.x + targetRect.width - _clipRect.x - _clipRect.width) * vectorWidth;
				targetRect.x = _clipRect.x + _clipRect.width - targetRect.width;
				if(_limitZoom){
					targetRect.y -= Math.round(targetRect.width / aspectRatio - targetRect.height) * vectorY;
					targetRect.height = Math.round(targetRect.width / aspectRatio);
				}
			}
			//下跨界
			if(targetRect.y + targetRect.height > _clipRect.y + _clipRect.height){
				//ExternalInterface.call('console.log', '跨界6', targetRect);
				targetRect.height -= (targetRect.y + targetRect.height - _clipRect.y - _clipRect.height) * vectorHeight;
				targetRect.y = _clipRect.y + _clipRect.height - targetRect.height;
				if(_limitZoom){
					targetRect.x -= Math.round(targetRect.height * aspectRatio - targetRect.width) * vectorX;
					targetRect.width = Math.round(targetRect.height * aspectRatio);
				}
			}
			_currentRect = targetRect;
			_render();			
		}
		/**
		 * 鼠标up事件
		 * */
		private function _parentClickHandler(evt:MouseEvent):void{
			if(_resizeActive){
				_resizeActive = false;
				_cursorEnd(evt); //模拟鼠标完毕
				evt.preventDefault();
				evt.stopImmediatePropagation();
			}
		}
		
		/**
		 * 裁剪完毕
		 * */
		private function _submitClip(evt:MouseEvent):void{
			end();
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		/**
		 * 取消
		 * */
		private function _cancelClip(evt:MouseEvent):void{
			end();
		}
		
		private function _buttonToggle(evt:MouseEvent):void{
			_setButtonStyle(evt.target as Sprite, evt.type == MouseEvent.ROLL_OVER);
		}
		
		private function _setButtonStyle(target:Sprite, isOver:Boolean):void{
			
			var color:int = isOver ? 0xffffff : 0xd7d5d5;
			//ExternalInterface.call('console.log', '渲染', isOver);
			target.graphics.beginFill(color);
			target.graphics.drawCircle(0, 0, 13);
			target.graphics.endFill();
		}
		
		/**
		 * 模拟鼠标开始
		 * */
		private function _cursorStart(evt:MouseEvent):void{
			if(_resizeActive){
				return;
			}
			_currentCursor.visible = false;
			
			//ExternalInterface.call('console.log', 'evt.target.name', evt.target.name);
			switch(evt.target.name){
				case 'resizeNW':
					_currentCursor = _cursorNWSE;
					//_resizeNW.addChild(_currentCursor);
					_resizeTarget = _resizeNW;
					break;
				case 'resizeNE':
					_currentCursor = _cursorNESW;
					_resizeTarget = _resizeNE;
					break;
				case 'resizeSW':
					_currentCursor = _cursorNESW;
					_resizeTarget = _resizeSW;
					break;
				case 'resizeSE':
					_currentCursor = _cursorNWSE;
					_resizeTarget = _resizeSE;
					break;
				case 'container':
					_currentCursor = _cursorMove;
					_resizeTarget = _container;
					break;
			}
			//ExternalInterface.call('console.log', '_cursorStarttt', evt.target.name);
			_currentCursor.visible = true;
			_currentCursor.mouseEnabled = false;
			_resizeTarget.mouseChildren = false;
		}
		
		/**
		 * 模拟鼠标借宿
		 * */
		private function _cursorEnd(evt:MouseEvent):void{
			if(_resizeActive){
				return;
			}
			if(_resizeTarget){
				_resizeTarget.mouseEnabled = true;
				_resizeTarget.mouseChildren = true;
			}
			Mouse.show();
			_currentCursor.visible = false;
		}
		
		//根据图片url得到loader
		private function _imageLoader(url:String, x:int = 0, y:int = 0):Loader{
			var loader:Loader = new Loader();
			var request:URLRequest = new URLRequest(url);
			loader.load(request);
			loader.x = x;
			loader.y = y;
			return loader;
		}
		
	}
}