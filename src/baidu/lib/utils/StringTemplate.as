package baidu.lib.utils {
	
	/**
	* 字符串模板工具类
	* @author xiaokun, yaowei
	*/
	public class StringTemplate {
		
		/**
		 * 根据模板和模板变量输出字符串
		 * @param	template		<String>指定的模板，变量标识形式为${winner}或者${1}，数字型的从0开始
		 * @param	...args			指定的模板变量，可以多个
		 * @return					<String>格式化过后的输出字符串
		 * @example  StringTemplate.output("${0} is better than ${1}!", "Mac OS X Leopard", "Windows Vista");<br/>
		 *			StringTemplate.output("${a} is better than ${b}!", {a:"Mac OS X Leopard", b:"Windows Vista"});
		 */
		public static function output(template:String, ...args):String {
			if (template == null) {
				return "";
			}
			if (args.length < 1) {
				return template;
			}
			var result:String = template.replace(/\${(\w+)}/g, function():String {
				var key:String = arguments[1];
				var numKey:Number = Number(key);
				var value:String = "";
				if (isNaN(numKey)) {
					if (args[0][key] != null) {
						value = args[0][key].toString();
					}
				} else {
					var arg:* = args[numKey];
					if (arg != null) {
						value = arg.toString();
					}
				}
				return value;
			});
			return result;
		}
		
	}
	
}