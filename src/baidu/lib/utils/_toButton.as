package baidu.lib.utils
{
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	
	/**
	 * 将mc转换为buttom状态使用
	 * 
	 * <p>
	 * mc状态帧顺序依次如下：normal,mouseOver,mouseDown,禁用状态,selected-mornal,selected-mouseOver,selected-mouseDown,selected-禁用状态
	 * </p>
	 * 
	 * @author laan
	 * @createTime 2010.08
	 * 
	 * @param mc				目标mc
	 * @param buttomMode		是否使用手型
	 * 
	 */
	public function _toButton(mc:MovieClip, buttomMode:Boolean = false):void {
		if (!mc) return;
		
		//非常重要
		mc.mouseChildren = false;
		
		mc.addEventListener(MouseEvent.ROLL_OUT, function(event:MouseEvent):void {
														if (mc.enabled) mc.gotoAndStop(mc.selected ? 5 : 1);
													});
		mc.addEventListener(MouseEvent.ROLL_OVER, function(event:MouseEvent):void {
														if (mc.enabled) mc.gotoAndStop(mc.selected ? 6 : 2);
													});
		mc.addEventListener(MouseEvent.MOUSE_DOWN, function(event:MouseEvent):void {
														if (mc.enabled) {
															mc.gotoAndStop(mc.selected ? 7 : 3);
														}
													});
		mc.addEventListener(MouseEvent.MOUSE_UP, function(event:MouseEvent):void {
														if (mc.enabled) mc.gotoAndStop(mc.selected ? 5 : 1);
													});
		
		//是否使用手型
		if (buttomMode) mc.buttonMode = true;
		
		mc.selected = false;
		
		mc.setEnabled = function(value:Boolean):void {
							if (mc.enabled == value) return;
							
							mc.enabled = value;
							mc.mouseEnabled = value;
							//mc.mouseChildren = value;
							
							if (!value) {
								mc.gotoAndStop(4);
							} else {
								mc.gotoAndStop(mc.selected ? 5 : 1);
							}
						}
		
		mc.setSelected = function(value:Boolean):void {
							mc.selected = value;
							mc.gotoAndStop(mc.selected ? 5 : 1);
						}
		
		mc.gotoAndStop(1);
	}
}