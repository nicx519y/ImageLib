package baidu.lib.utils {
	
	/**
	* @private
	* 整数工具类，供MD5使用（注:从Adobe as3corelib 库引入并修改）
	* @author Adobe
	*/
	public class IntUtil {
		private static var _hexChars:String = "0123456789abcdef";
		
		public static function rol ( x:int, n:int ):int {
			return ( x << n ) | ( x >>> ( 32 - n ) );
		}
		
		public static function ror ( x:int, n:int ):uint {
			var nn:int = 32 - n;
			return ( x << nn ) | ( x >>> ( 32 - nn ) );
		}
		
		public static function toHex( n:int, bigEndian:Boolean = false ):String {
			var s:String = "";
			
			if ( bigEndian ) {
				for ( var i:int = 0; i < 4; i++ ) {
					s += _hexChars.charAt( ( n >> ( ( 3 - i ) * 8 + 4 ) ) & 0xF ) 
						+ _hexChars.charAt( ( n >> ( ( 3 - i ) * 8 ) ) & 0xF );
				}
			} else {
				for ( var x:int = 0; x < 4; x++ ) {
					s += _hexChars.charAt( ( n >> ( x * 8 + 4 ) ) & 0xF )
						+ _hexChars.charAt( ( n >> ( x * 8 ) ) & 0xF );
				}
			}
			
			return s;
		}
		
	}
	
}