package baidu.lib.utils {
	
	/**
	* 日期工具类
	* @author xiaokun
	*/
	public class DateUtil {
		
		/**
		 * 一天的毫秒数
		 */
		public static const DAY:Number = 24 * 60 * 60 * 1000;
		
		/**
		 * 计算指定月份有多少天
		 * @param	year		<Number>指定的年份
		 * @param	month		<Number>指定的月份，0-11
		 * @return				<int>指定月份拥有的天数
		 */
		public static function getDaysNumOfMonth(year:Number, month:Number):int {
			var firstDateOfM:Date = new Date(year, month, 1);
			var firstDateOfNextM:Date;
			if (month < 11) {
				firstDateOfNextM = new Date(year, month + 1, 1);
			} else {
				firstDateOfNextM = new Date(year + 1, 0, 1);
			}
			return (firstDateOfNextM.valueOf() - firstDateOfM.valueOf()) / DAY;
		}
		
		/**
		 * 计算指定年份有多少天
		 * @param	year		<Number>指定的年份
		 * @return				<int>指定年份拥有的天数
		 */
		public static function getDaysNumOfYear(year:Number):int {
			var firstDateOfY:Date = new Date(year, 0, 1);
			var firstDateOfNextY:Date = new Date(year + 1, 0, 1);
			return (firstDateOfNextY.valueOf() - firstDateOfY.valueOf()) / DAY;
		}

		/**
		 * 计算两个日期之间间隔多少天
		 * @param	date1		<Date>日期一
		 * @param	date2		<Date>日期二
		 * @return				<Number>间隔的天数，可能为小数，也可能为负数
		 */
		public static function getDaysNumBetweenDates(date1:Date, date2:Date):Number {
			return (date1.valueOf() - date2.valueOf()) / DAY;
		}
		
		/**
		 * 判断两个日期是否在一个星期
		 * @param	date1		<Date>日期一
		 * @param	date2		<Date>日期二
		 * @param	sundayFirst	<Date>是否把周末当成一周的第一天，默认值是false
		 * @return				<Boolean>是否在同一个星期
		 */
		public static function isOnSameWeek(date1:Date, date2:Date, sundayFirst:Boolean = false):Boolean {
			var d1Value:Number = date1.valueOf();
			var d2Value:Number = date2.valueOf();
			if (Math.abs(d1Value - d2Value) >= 7 * DAY) {		//跨度大于1周，直接返回false
				return false;
			} else {
				var day1:int = date1.day;
				var day2:int = date2.day;
				if (day1 == day2) {										//星期数相同
					if (Math.abs(d1Value - d2Value) < DAY) {			//同一天
						return true;
					} else {
						return false;
					}
				} else {
					if (!sundayFirst) {				//如果周末不是一个星期的第一天，那么将0改为7，即把周末算最后一天
						if (day1 == 0) {
							day1 = 7;
						}
						if (day2 == 0) {
							day2 = 7;
						}
					}
					if ((d1Value < d2Value == day1 < day2)) {		//小的日期星期数也小，大的日期星期数也大
						return true;
					} else {
						return false;
					}
				}
			}
		}
		
	}
	
}