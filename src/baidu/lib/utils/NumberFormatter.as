package baidu.lib.utils {
	
	/**
	* 数字格式化工具类
	* @author xiaokun
	*/
	public class NumberFormatter {
		
		/**
		 * 将数字按照指定格式进行格式化
		 * @param	num				<Number>要格式化的数字
		 * @param	formatStr		<String>指定的格式<br>
		 * 								I代表整数部分,可以通过逗号的位置来设定逗号分隔的位数
		 *                              D代表小数部分，可以通过D的重复次数指定小数部分的显示位数
		 * @return					<String>格式化过的字符串
		 * @example					NumberFormatter.format(10000/3, "I,III.DD%"); 返回"3,333.33%"
		 */
		public static function format(num:Number, formatStr:String):String {
			var str:String;
			var numStr:String = num.toString();
			var tempAry:Array = numStr.split('.');
			var intStr:String = tempAry[0];
			var decStr:String = (tempAry.length > 1)?tempAry[1]:"";
			str = formatStr.replace(/I+,*I*/g, function():String {
                var matchStr:String = arguments[0] as String;
                var replaceStr:String;
                var commaIndex:int = matchStr.lastIndexOf(",");
                if (commaIndex >= 0 && commaIndex != intStr.length - 1) {
                    var splitPos:int = matchStr.length - 1 - commaIndex;
                    var parts:Array = [];
                    while (intStr.length > splitPos) {
                        parts.push(intStr.substr(-splitPos));
                        intStr = intStr.substring(0, intStr.length - splitPos);
                    }
                    parts.push(intStr);
                    parts.reverse();
                    if (parts[0] == "-") {
                        parts.shift();
                        replaceStr = "-" + parts.join(",");
                    } else {
                        replaceStr = parts.join(",");
                    }
                } else {
                    replaceStr = intStr;
                }
                return replaceStr;
            });
			str = str.replace(/D+/g, function():String {
				var matchStr:String = arguments[0] as String;
				var replaceStr:String = decStr;
				if (replaceStr.length > matchStr.length) {
					replaceStr = replaceStr.substr(0, matchStr.length);
				} else {
					while (replaceStr.length < matchStr.length) {
						replaceStr += "0";
					}
				}
				return replaceStr;
			});
			return str;
		}
		
	}
	
}