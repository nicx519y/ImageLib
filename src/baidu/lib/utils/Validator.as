package baidu.lib.utils {
	
	/**
	* 字符串验证类
	* @author xiaokun
	*/
	public class Validator {
		
		/**
		 * 验证源字符串是不是一个email地址
		 * @param	str			<String>源字符串
		 * @return				<Boolean>源字串是否为email地址
		 */
		public static function isEmail(str:String):Boolean {
			var reg:RegExp = /^([a-zA-Z0-9_\.\-\+])+\@(([a-zA-Z0-9\-])+\.)+([a-zA-Z0-9]{2,4})+$/;
			var result:Array = str.match(reg);
			if(result && result.length > 0 && result[0] == str){
				return true;
			}else {
				return false;
			}
		}
	}
	
}