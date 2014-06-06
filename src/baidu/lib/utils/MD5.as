﻿package baidu.lib.utils {
	
	import flash.utils.ByteArray;
	
	/**
	* MD5加密类（注:从Adobe as3corelib 库引入并修改）
	* @author Adobe
	*/
	public class MD5 {
		
		/**
		 * 用MD5算法加密字符串
		 * @param	s			<String>源字符串
		 * @return				<String>加密过的字符串
		 */
		public static function encrypt( s:String ):String {
			var a:int = 1732584193;
			var b:int = -271733879;
			var c:int = -1732584194;
			var d:int = 271733878;
			
			var aa:int;
			var bb:int;
			var cc:int;
			var dd:int;
			
			var ba:ByteArray = new ByteArray();
            ba.writeUTFBytes(s);
			var x:Array = createBlocks( ba );
			var len:int = x.length;
			
			for ( var i:int = 0; i < len; i += 16) {
				aa = a;
				bb = b;
				cc = c;
				dd = d;				
				
				a = ff( a, b, c, d, x[i+ 0],  7, -680876936 ); 	
				d = ff( d, a, b, c, x[i+ 1], 12, -389564586 );	
				c = ff( c, d, a, b, x[i+ 2], 17, 606105819 ); 	
				b = ff( b, c, d, a, x[i+ 3], 22, -1044525330 );	
				a = ff( a, b, c, d, x[i+ 4],  7, -176418897 ); 	
				d = ff( d, a, b, c, x[i+ 5], 12, 1200080426 ); 	
				c = ff( c, d, a, b, x[i+ 6], 17, -1473231341 );	
				b = ff( b, c, d, a, x[i+ 7], 22, -45705983 ); 	
				a = ff( a, b, c, d, x[i+ 8],  7, 1770035416 ); 	
				d = ff( d, a, b, c, x[i+ 9], 12, -1958414417 );	
				c = ff( c, d, a, b, x[i+10], 17, -42063 ); 		
				b = ff( b, c, d, a, x[i+11], 22, -1990404162 );	
				a = ff( a, b, c, d, x[i+12],  7, 1804603682 ); 	
				d = ff( d, a, b, c, x[i+13], 12, -40341101 ); 	
				c = ff( c, d, a, b, x[i+14], 17, -1502002290 );	
				b = ff( b, c, d, a, x[i+15], 22, 1236535329 ); 	
				
				a = gg( a, b, c, d, x[i+ 1],  5, -165796510 ); 	
				d = gg( d, a, b, c, x[i+ 6],  9, -1069501632 );	
				c = gg( c, d, a, b, x[i+11], 14, 643717713 ); 	
				b = gg( b, c, d, a, x[i+ 0], 20, -373897302 ); 	
				a = gg( a, b, c, d, x[i+ 5],  5, -701558691 ); 	
				d = gg( d, a, b, c, x[i+10],  9, 38016083 ); 	
				c = gg( c, d, a, b, x[i+15], 14, -660478335 ); 	
				b = gg( b, c, d, a, x[i+ 4], 20, -405537848 ); 	
				a = gg( a, b, c, d, x[i+ 9],  5, 568446438 ); 	
				d = gg( d, a, b, c, x[i+14],  9, -1019803690 );	
				c = gg( c, d, a, b, x[i+ 3], 14, -187363961 ); 	
				b = gg( b, c, d, a, x[i+ 8], 20, 1163531501 ); 	
				a = gg( a, b, c, d, x[i+13],  5, -1444681467 );	
				d = gg( d, a, b, c, x[i+ 2],  9, -51403784 ); 	
				c = gg( c, d, a, b, x[i+ 7], 14, 1735328473 ); 	
				b = gg( b, c, d, a, x[i+12], 20, -1926607734 );	
				
				a = hh( a, b, c, d, x[i+ 5],  4, -378558 ); 	
				d = hh( d, a, b, c, x[i+ 8], 11, -2022574463 );	
				c = hh( c, d, a, b, x[i+11], 16, 1839030562 ); 	
				b = hh( b, c, d, a, x[i+14], 23, -35309556 ); 	
				a = hh( a, b, c, d, x[i+ 1],  4, -1530992060 );	
				d = hh( d, a, b, c, x[i+ 4], 11, 1272893353 ); 	
				c = hh( c, d, a, b, x[i+ 7], 16, -155497632 ); 	
				b = hh( b, c, d, a, x[i+10], 23, -1094730640 );	
				a = hh( a, b, c, d, x[i+13],  4, 681279174 ); 	
				d = hh( d, a, b, c, x[i+ 0], 11, -358537222 ); 	
				c = hh( c, d, a, b, x[i+ 3], 16, -722521979 ); 	
				b = hh( b, c, d, a, x[i+ 6], 23, 76029189 ); 	
				a = hh( a, b, c, d, x[i+ 9],  4, -640364487 ); 	
				d = hh( d, a, b, c, x[i+12], 11, -421815835 ); 	
				c = hh( c, d, a, b, x[i+15], 16, 530742520 ); 	
				b = hh( b, c, d, a, x[i+ 2], 23, -995338651 ); 	
				
				a = ii( a, b, c, d, x[i+ 0],  6, -198630844 ); 	
				d = ii( d, a, b, c, x[i+ 7], 10, 1126891415 ); 	
				c = ii( c, d, a, b, x[i+14], 15, -1416354905 );	
				b = ii( b, c, d, a, x[i+ 5], 21, -57434055 ); 	
				a = ii( a, b, c, d, x[i+12],  6, 1700485571 ); 	
				d = ii( d, a, b, c, x[i+ 3], 10, -1894986606 );	
				c = ii( c, d, a, b, x[i+10], 15, -1051523 ); 	
				b = ii( b, c, d, a, x[i+ 1], 21, -2054922799 );	
				a = ii( a, b, c, d, x[i+ 8],  6, 1873313359 ); 	
				d = ii( d, a, b, c, x[i+15], 10, -30611744 ); 	
				c = ii( c, d, a, b, x[i+ 6], 15, -1560198380 );	
				b = ii( b, c, d, a, x[i+13], 21, 1309151649 ); 	
				a = ii( a, b, c, d, x[i+ 4],  6, -145523070 ); 	
				d = ii( d, a, b, c, x[i+11], 10, -1120210379 );	
				c = ii( c, d, a, b, x[i+ 2], 15, 718787259 ); 	
				b = ii( b, c, d, a, x[i+ 9], 21, -343485551 ); 	

				a += aa;
				b += bb;
				c += cc;
				d += dd;
			}

			return IntUtil.toHex( a ) + IntUtil.toHex( b ) + IntUtil.toHex( c ) + IntUtil.toHex( d );
		}
		
		private static function f( x:int, y:int, z:int ):int {
			return ( x & y ) | ( (~x) & z );
		}
		
		private static function g( x:int, y:int, z:int ):int {
			return ( x & z ) | ( y & (~z) );
		}
		
		private static function h( x:int, y:int, z:int ):int {
			return x ^ y ^ z;
		}
		
		private static function i( x:int, y:int, z:int ):int {
			return y ^ ( x | (~z) );
		}
		
		private static function transform( func:Function, a:int, b:int, c:int, d:int, x:int, s:int, t:int):int {
			var tmp:int = a + int( func( b, c, d ) ) + x + t;
			return IntUtil.rol( tmp, s ) +  b;
		}
		
		private static function ff ( a:int, b:int, c:int, d:int, x:int, s:int, t:int ):int {
			return transform( f, a, b, c, d, x, s, t );
		}
		
		private static function gg ( a:int, b:int, c:int, d:int, x:int, s:int, t:int ):int {
			return transform( g, a, b, c, d, x, s, t );
		}
		
		private static function hh ( a:int, b:int, c:int, d:int, x:int, s:int, t:int ):int {
			return transform( h, a, b, c, d, x, s, t );
		}
		
		private static function ii ( a:int, b:int, c:int, d:int, x:int, s:int, t:int ):int {
			return transform( i, a, b, c, d, x, s, t );
		}
		
		private static function createBlocks( s:ByteArray ):Array {
			var blocks:Array = new Array();
			var len:int = s.length * 8;
			var mask:int = 0xFF; 
			for( var i:int = 0; i < len; i += 8 ) {
				blocks[ i >> 5 ] |= ( s[ i / 8 ] & mask ) << ( i % 32 );
			}
			
			blocks[ len >> 5 ] |= 0x80 << ( len % 32 );
			blocks[ ( ( ( len + 64 ) >>> 9 ) << 4 ) + 14 ] = len;
			return blocks;
		}
		
	}
	
}