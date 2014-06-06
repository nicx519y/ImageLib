package baidu.lib.utils {
	
	/**
	* 日期格式化工具类
	* @author xiaokun
	*/
	public class DateFormatter {
		
		/**
		 * 将日期对象按指定格式进行格式化
		 * 
		 * @param	date			<Date>要进行格式化的日期对象
		 * @param	formatStr		<String>指定的格式<br>
		 * 								YMDhms分别代表年月日时分秒					
		 * @return					<String>格式化过的日期字符串
		 * @example					DateFormatter.format(new Date(2008, 9, 1), "YY-MM-DD");返回"08-10-01"
		 */
		public static function format(date:Date, formatStr:String):String {
			var str:String;
			str = formatStr.replace(/([YMDhms])\1*/g, function():String {
				var matchStr:String = arguments[0] as String;
				var replaceStr:String;
				switch(matchStr.charAt()) {
					case 'Y':
						replaceStr = getIntStrAtLength(date.getFullYear(), matchStr.length);
						break;
					case 'M':
						replaceStr = getIntStrAtLength(date.getMonth() + 1, matchStr.length);
						break;
					case 'D':
						replaceStr = getIntStrAtLength(date.getDate(), matchStr.length);
						break;
					case 'h':
						replaceStr = getIntStrAtLength(date.getHours(), matchStr.length);
						break;
					case 'm':
						replaceStr = getIntStrAtLength(date.getMinutes(), matchStr.length);
						break;
					case 's':
						replaceStr = getIntStrAtLength(date.getSeconds(), matchStr.length);
						break;
				}
				return replaceStr;
			});
			return str;
		}
		
		/**
		 * 将日期字符串按指定格式解析成日期对象
		 * 
		 * @param	str				<String>要解析的日期字符串
		 * @param	formatStr		<String>指定的格式<br>
		 * 								YMDhms分别代表年月日时分秒					
		 * @return					<Date>解析出来的日期对象
		 * @example					DateFormatter.parse("2008.02.21 23:10", "YYYY.MM.DD hh:mm");
		 */
		public static function parse(str:String, formatStr:String):Date {
			//escape目的是为了将所有非英文字符转换为英文，否则用正则匹配的时候会出现index不对的现象
			str = escape(str);
			formatStr = escape(formatStr);
			
			var date:Date = new Date(0);
			formatStr.replace(/([YMDhms])\1*/g, function():String {
				var matchStr:String = arguments[0] as String;
				var index:uint = arguments[2];
				var value:int = parseInt(str.substr(index, matchStr.length));
				switch(matchStr.charAt()) {
					case 'Y':
						date.fullYear = value;
						break;
					case 'M':
						date.month = value - 1;
						break;
					case 'D':
						date.date = value;
						break;
					case 'h':
						date.hours = value;
						break;
					case 'm':
						date.minutes = value;
						break;
					case 's':
						date.seconds = value;
						break;
				}
				return "";
			});
			return date;
		}
		
		private static function getIntStrAtLength(value:uint, length:uint):String {
			var str:String = value.toString();
			if (length > 1) {
				if (str.length > length) {
					str = str.substr( -length);
				} else {
					while (str.length < length) {
						str = "0" + str;
					}
				}
			}
			return str;
		}		
	}	
}