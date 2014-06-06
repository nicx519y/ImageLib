package baidu.lib.debug {
	
	import flash.display.Sprite;
	import flash.display.Graphics;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFieldType;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.KeyboardEvent;
	
	import baidu.lib.utils.StringTemplate;

	/**
	 *  一个可移动可折叠的文本框日志输出器<br/>
	 *	可以用快捷键Ctrl+L控制显示/隐藏
	 *  @author xiaokun
	 */
	public class TextBoxWriter extends Sprite implements IWriter {
		
		/**
		 *	拖动条高度
		 */
		private const HEIGHT_BAR:Number = 25;
		
		/**
		 *	默认宽度
		 */
		private const WIDTH_DEFAULT:Number = 400;
		
		/**
		 *	默认高度
		 */
		private const HEIGHT_DEFAULT:Number = 300;
		
		/**
		 *	能显示的最大日志数量，增加这个限制是防止打印太多，导致程序运行很慢
		 */
		private const MAX_LOGS_NUM:uint = 2000;

		/**
		 *	一个缩进对应的字符串
		 */
		private const TAB:String = "    ";

		/**
		 *	格式化输出时，错误信息类型标识的颜色
		 */
		private const COLOR_TYPE_ERROR:String = "#FF0000";

		/**
		 *	格式化输出时，普通信息类型标识的颜色
		 */
		private const COLOR_TYPE_INFO:String = "#408000";

		/**
		 *	格式化输出时，key/value中key的颜色
		 */
		private const COLOR_KEY:String = "#ff6600";

		/**
		 *	格式化输出时，value数据类型的颜色
		 */
		private const COLOR_DATA_TYPE:String = "#336699";
		
		/**
		 *	滚动条的最小高度
		 */
		private const MIN_HEIGHT_SCROLL_BAR:Number = 50;

		/**
		 *	当前宽度
		 */
		private var _width:Number = WIDTH_DEFAULT;
		
		/**
		 *	当前高度
		 */
		private var _height:Number = HEIGHT_DEFAULT;
		
		/**
		 *	当前是否始终置顶
		 */
		private var _alwaysOnTop:Boolean = true;
		
		/**
		 *	拖动条
		 */
		private var _bar:Sprite;
		
		/**
		 *	清除按钮
		 */
		private var _clearBtn:Sprite;
		
		/**
		 *	显示内容的文本框
		 */
		private var _textField:TextField;
		
		/**
		 *  存储正在显示的所有日志信息
		 */
		private var _logStrAry:Array;
		
		/**
		 *	当前是否正在拖动，用于在拖动条鼠标释放的时候判断如何操作
		 */
		private var _isDragging:Boolean = false;
		
		/**
		 *	拖动开始时鼠标在舞台的位置
		 */
		private var _mouseStartPoint:Point;
		
		/**
		 *	拖动开始时本对象的位置
		 */
		private var _mouseStartLoc:Point;
		
		/**
		 *	滚动条
		 *	这里写一个简单的而不用UI库立的滚动容器是为了避免导入其它类和其它皮肤
		 */
		private var _scrollBar:Sprite;
		
		/**
		 *	滚动条滚动一个像素对应的滚动对象移动的像素值
		 */
		private var _scrollUnit:Number;
		
		/**
		 *	拖动开始时滚动条的Y值
		 */
		private var _mouseStartScrollBarY:Number;
		
		/**
		 *	当前是否被展开
		 */
		private var _expanded:Boolean = true;
		
		/**
		 *	构造函数
		 */
		public function TextBoxWriter() {
			init();
		}

		/**
		 *  @private
		 */
		override public function get width():Number {
			return _width;
		}
		
		/**
		 *  @private
		 */
		override public function set width(value:Number):void {
			if (_width == value) return;
			_width = value;
			doResize();
		}
		
		/**
		 *  @private
		 */
		override public function get height():Number {
			return _height;
		}
		
		/**
		 *  @private
		 */
		override public function set height(value:Number):void {
			if (_height == value) return;
			_height = value;
			doResize();
		}
		
		/**
		 *  获取/设置是否始终置顶
		 */
		public function get alwaysOnTop():Boolean {
			return _alwaysOnTop;
		}
		
		public function set alwaysOnTop(value:Boolean):void {
			if (_alwaysOnTop == value) return;
			_alwaysOnTop = value;
			if (_alwaysOnTop) {
				this.addEventListener(Event.ENTER_FRAME, checkOnTop);
			}else {
				try {
					this.removeEventListener(Event.ENTER_FRAME, checkOnTop);
				} catch (e:Error) {
					//trace(e);
				}
			}
		}
		
		/**
		 *  输出内容
		 *  @param	o		<*>要输出的内容
		 *  @param	type	<String>日志类型
		 */
		public function write(o:*, type:String):void {
			var typeColor:String;
			switch (type) {
				case Logger.TYPE_INFO :
					typeColor = COLOR_TYPE_INFO;
					break;
				case Logger.TYPE_ERROR :
					typeColor = COLOR_TYPE_ERROR;
					break;
			}
			var headStr:String = StringTemplate.output("<font color='${0}'>${1}| </font>", typeColor, type);
			var logStr:String = headStr + obj2Str(o);
			
			_logStrAry.push(logStr);
			if (_logStrAry.length > MAX_LOGS_NUM) {
				_logStrAry.shift();
			}
			
			var isAtEnd:Boolean = _textField.scrollV == _textField.maxScrollV;
			_textField.htmlText = _logStrAry.join("\n");
			
			//在用户选择文本后再塞内容会导致字体失效，所以这里重置字体
			var tf:TextFormat = new TextFormat();
			tf.font = "Verdana";
			_textField.setTextFormat(tf);
			
			//如果刚才的滚动位置在底部的话，则保持滚动到底部
			if (isAtEnd) {
				_textField.scrollV = _textField.maxScrollV;
			}
			
			refreshScrollBar();
		}

		/**
		 *  清除内容
		 */
		public function clear():void {
			_logStrAry.length = 0;
			_textField.htmlText = "";
			
			refreshScrollBar();
		}

		/**
		 *  将任意对象打印成字符串(html格式)
		 *  @param	o			<*>要打印的对象
		 *  @param	tabNum		<uint>打印信息的前置缩进个数，用于递归调用
		 *  @return				<String>打印出的字符串
		 */
	  	private function obj2Str(o:*, tabNum:uint = 0):String {
			var str:String = "";
			var tabPrefix:String = getTab(tabNum);
			switch(typeof(o)) {
				case "object":
					var subNum:Number = 0;
					for (var i in o) {
						var template:String;
						template = "${0}\"<font color='" + COLOR_KEY + "'>${1}</font>\": ${2}\n";
						str += StringTemplate.output(template, tabPrefix, i, obj2Str(o[i], tabNum+1));
						subNum++;
					}
					//针对某些对象做特殊处理，例如 new String("test") 生成的对象
					if (subNum == 0) {
						str = String(o);
					}else {	
						var typeStart:String, typeEnd:String;
						typeStart = "<font color='" + COLOR_DATA_TYPE + "'>[object</font>";
						typeEnd = "<font color='" + COLOR_DATA_TYPE + "'>]</font>";
						str = StringTemplate.output(
							"${0}${1}${2}\n${3}${4}${5}", 
							"\n", tabPrefix, typeStart, str, tabPrefix, typeEnd
						);
					}
					break;
				case "function":
					str = "<font color='" + COLOR_DATA_TYPE + "'>[function]</font>";
					break;
				default:
					str = String(o);
			}
			return str;
		}

		/**
		 *	根据缩进数量获得对应的缩进字符串
		 *	@param	tabNum		<int>缩进个数
		 *	@return 			<String>缩进字符串
		 */
		private function getTab(tabNum:int):String {
			var str:String = "";
			for (var i:int = 0; i < tabNum; i++) {
				str += TAB;
			}
			return str;
		}
		
		/**
		 *	初始化
		 */
		private function init():void {
			//创建拖动条
			_bar = new Sprite();
			addChild(_bar);
			var gp:Graphics = _bar.graphics;
			gp.beginFill(0x444444, 0.8);
			gp.drawRect(0, 0, _width, HEIGHT_BAR);
			gp.endFill();
			_bar.buttonMode = true;
			_bar.addEventListener(MouseEvent.MOUSE_DOWN, doBarMouseDown);
			
			//创建清除按钮
			_clearBtn = new Sprite();
			addChild(_clearBtn);
			var label:TextField = new TextField();
			_clearBtn.addChild(label);
			label.autoSize = "left";
			label.selectable = false;
			label.mouseEnabled = false;
			var tfLabel:TextFormat = new TextFormat();
			tfLabel.font = "Verdana";
			tfLabel.size = 14;
			tfLabel.color = 0xffffff;
			label.defaultTextFormat = tfLabel;
			label.text = "Clear";
			_clearBtn.y = (HEIGHT_BAR - _clearBtn.height) / 2;
			_clearBtn.buttonMode = true;
			_clearBtn.addEventListener(MouseEvent.CLICK, doClearBtnClick);
			
			//创建文本框
			_textField = new TextField();
			addChild(_textField);
			_textField.y = HEIGHT_BAR;
			var tf:TextFormat = new TextFormat();
			tf.size = 12;
			tf.font = "Verdana";
			_textField.defaultTextFormat = tf;
			_textField.addEventListener(Event.SCROLL, doTextFieldScroll);
			
			//创建滚动条
			_scrollBar = new Sprite();
			addChild(_scrollBar);
			_scrollBar.buttonMode = true;
			var gpBar:Graphics = _scrollBar.graphics;
			gpBar.beginFill(0x999999, 0.8);
			gpBar.drawRect(0, 0, 20, 20);
			gpBar.endFill();
			_scrollBar.y = HEIGHT_BAR;
			_scrollBar.addEventListener(MouseEvent.MOUSE_DOWN, doScrollBarMouseDown);
			
			doResize();
			this.alwaysOnTop = _alwaysOnTop;
			_logStrAry = [];
			
			//在添加到舞台时绑定快捷键
			this.addEventListener(Event.ADDED_TO_STAGE, 
				function(evt:Event):void {
					stage.addEventListener(KeyboardEvent.KEY_DOWN, doKeyDown);
				}
			);
		}
		
		/**
		 *	根据文本框内容刷新滚动条是否显示以及高度位置
		 */
		private function refreshScrollBar():void {
			var maxScrollV:Number = _textField.maxScrollV - 1;
			if (maxScrollV <= 0) {
				_scrollBar.visible = false;
			} else {	
				_scrollBar.height = Math.max(MIN_HEIGHT_SCROLL_BAR, 
											(1 - (maxScrollV / _textField.numLines)) * (_height - HEIGHT_BAR));
				_scrollUnit = maxScrollV / (_height - HEIGHT_BAR - _scrollBar.height);
				_scrollBar.y = (_textField.scrollV - 1) / _scrollUnit + HEIGHT_BAR;
				_scrollBar.visible = _expanded;
			}
		}
		
		/**
		 *	展开显示日志内容
		 */
		private function expand():void {
			_textField.visible = true;
			if (_textField.maxScrollV <= 1) {
				_scrollBar.visible = false;
			} else {
				_scrollBar.visible = true;
			}
				
			_expanded = true;
			
			refreshBackAndBorder();
		}
		
		/**
		 *	收起日志内容的显示，只显示拖动条
		 */
		private function collapse():void {
			_scrollBar.visible = _textField.visible = false;
			
			_expanded = false;
			
			refreshBackAndBorder();
		}
		
		/**
		 *	改变大小时改变成员的显示
		 */
		private function doResize():void {
			refreshBackAndBorder();
			
			_bar.width = _width;
			_textField.width = _width - 20;
			_textField.height = _height - HEIGHT_BAR - 1;
			_clearBtn.x = _width - _clearBtn.width - 10;
			_scrollBar.x = _width - _scrollBar.width;
		}
		
		/**
		 *	根据展开与否和宽高来绘制背景和边框
		 */
		private function refreshBackAndBorder():void {
			graphics.clear();
			graphics.lineStyle(1, 0x444444, 0.6);
			graphics.beginFill(0xFFFFFF, 0.9);
			if (_expanded) {
				graphics.drawRect(0, 0, _width, _height);
			} else {
				graphics.drawRect(0, 0, _width, HEIGHT_BAR);
			}
			graphics.endFill();
		}
		
		/**
		 *	监测当前是否置顶，如果不是，则置顶
		 */
		private function checkOnTop(evt:Event):void {
			if (parent) {
				parent.setChildIndex(this, parent.numChildren - 1);
			}
		}
		
		/**
		 *	拖动条鼠标按下事件侦听函数
		 */
		private function doBarMouseDown(evt:MouseEvent):void {
			_isDragging = false;
			_mouseStartPoint = new Point(stage.mouseX, stage.mouseY);
			_mouseStartLoc = new Point(x, y);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, doBarMouseMove);
			stage.addEventListener(MouseEvent.MOUSE_UP, doBarMouseUp);
		}
		
		/**
		 *	拖动条鼠标按下后，stage鼠标移动事件侦听函数
		 */
		private function doBarMouseMove(evt:MouseEvent):void {
			_isDragging = true;
			x = _mouseStartLoc.x + stage.mouseX - _mouseStartPoint.x;
 			y = _mouseStartLoc.y + stage.mouseY - _mouseStartPoint.y;
			evt.updateAfterEvent();
		}
		
		/**
		 *	拖动条鼠标按下后，stage鼠标释放事件侦听函数
		 */
		private function doBarMouseUp(evt:MouseEvent):void {
			if (!_isDragging) {
				if (_expanded) {
					collapse();
				} else {
					expand();
				}
			}
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, doBarMouseMove);
			stage.removeEventListener(MouseEvent.MOUSE_UP, doBarMouseUp);
		}
		
		/**
		 *	清除按钮点击事件侦听函数，清除内容
		 */
		private function doClearBtnClick(evt:MouseEvent):void {
			clear();
		}
		
		/**
		 *	键盘事件侦听函数，在按ctrl+l时切换显示与否
		 */
		private function doKeyDown(evt:KeyboardEvent):void {
			if ((evt.keyCode == 76) && evt.ctrlKey) {
				visible = !visible;
			}
		}
		
		/**
		 *	滚动条鼠标按下事件侦听函数
		 */
		private function doScrollBarMouseDown(evt:MouseEvent):void {
			_mouseStartPoint = new Point(stage.mouseX, stage.mouseY);
			_mouseStartScrollBarY = _scrollBar.y;
			stage.addEventListener(MouseEvent.MOUSE_MOVE, doScrollBarMouseMove);
			stage.addEventListener(MouseEvent.MOUSE_UP, doScrollBarMouseUp);
		}
		
		/**
		 *	滚动条鼠标按下后，stage鼠标移动事件侦听函数
		 */
		private function doScrollBarMouseMove(evt:MouseEvent):void {
			var newY:Number = _mouseStartScrollBarY + stage.mouseY - _mouseStartPoint.y;
			newY = Math.max(newY, HEIGHT_BAR);
			newY = Math.min(newY, _height - _scrollBar.height);
			_scrollBar.y = newY;
			_textField.scrollV = Math.round((_scrollBar.y - HEIGHT_BAR) * _scrollUnit) + 1;
		}
		
		/**
		 *	滚动条鼠标按下后，stage鼠标释放事件侦听函数
		 */
		private function doScrollBarMouseUp(evt:MouseEvent):void {
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, doScrollBarMouseMove);
			stage.removeEventListener(MouseEvent.MOUSE_UP, doScrollBarMouseUp);
		}
		
		/**
		 *	文本框滚动事件侦听器
		 */
		private function doTextFieldScroll(evt:Event):void {
			_scrollBar.y = (_textField.scrollV - 1) / _scrollUnit + HEIGHT_BAR;
		}
	}
	
}