package baidu.lib.images
{
	import flash.utils.ByteArray;

	public class FileValidate
	{
		public function FileValidate()
		{
		}
		
		public static function isImage(byteArr:ByteArray) : Boolean
		{
			return isBMP(byteArr) || isGIF(byteArr) || isJPG(byteArr) || isPNG(byteArr);
		}
		
		/**
		 * 验证是否为JPG文件
		 * */
		public static function isJPG(byteArr:ByteArray) : Boolean
		{
			byteArr.position = 0;
			if (byteArr.readUnsignedShort() == 65496)
			{
				return true;
			}
			return false;
		}
		
		/**
		 * 验证是否为GIF文件
		 * */
		public static function isGIF(byteArr:ByteArray) : Boolean
		{
			byteArr.position = 0;
			var _loc_2:* = byteArr.readUTFBytes(3);
			if (_loc_2 == "GIF")
			{
				return true;
			}
			return false;
		}
		
		/**
		 * 验证是否为BMP文件
		 * */
		public static function isBMP(byteArr:ByteArray) : Boolean
		{
			byteArr.position = 0;
			var _loc_2:* = byteArr.readUTFBytes(2);
			if (_loc_2 == "BM")
			{
				return true;
			}
			return false;
		}
		
		/**
		 * 验证是否为PNG文件
		 * */
		public static function isPNG(byteArr:ByteArray) : Boolean
		{
			byteArr.position = 1;
			var _loc_2:* = byteArr.readUTFBytes(3);
			if (_loc_2 == "PNG")
			{
				return true;
			}
			return false;
		}
	}
}