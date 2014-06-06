package baidu.lib.images
{
    import flash.errors.*;
    import flash.utils.*;

    public class ExifInjector extends Object
    {
        private static const JPG_DISTINCTION:uint = 65496;
        private static const EXIF_HEAD:uint = 65505;
        private static const MARKER_SEGMENT_LENGTH:uint = 65536;

        public function ExifInjector()
        {
            return;
        }// end function

        public static function inject(param1:ByteArray, param2:ByteArray) : ByteArray
        {
            if (param1 == null)
            {
                return param2;
            }
            var _loc_3:* = new ByteArray();
            var _loc_4:* = new ByteArray();
            _loc_3.writeBytes(param2, 2, param2.length - 2);
            _loc_4.writeBytes(param2, 0, 2);
            _loc_4.writeBytes(param1, 0, param1.length);
            _loc_4.writeBytes(_loc_3, 0, _loc_3.length);
            return _loc_4;
        }// end function

        public static function extract(param1:ByteArray) : ByteArray
        {
            var temp:ByteArray;
            var result:ByteArray;
            var exifDataLength:uint;
            var rawJPGbyte:* = param1;
            if (!isJPG(rawJPGbyte))
            {
                return null;
            }
            var exifFinded:Boolean;
            if (rawJPGbyte.length > MARKER_SEGMENT_LENGTH)
            {
                temp = new ByteArray();
                temp.endian = Endian.BIG_ENDIAN;
                temp.writeBytes(rawJPGbyte, 0, MARKER_SEGMENT_LENGTH);
            }
            else
            {
                temp = rawJPGbyte;
            }
            temp.position = 0;
            while (temp.bytesAvailable >= 2)
            {
                
                if (temp.readUnsignedShort() == EXIF_HEAD)
                {
                    exifFinded;
                    break;
                }
            }
            if (exifFinded)
            {
                try
                {
                    exifDataLength = temp.readUnsignedShort();
                    result = new ByteArray();
                    result.endian = Endian.BIG_ENDIAN;
                    temp.readBytes(result, 4, exifDataLength - 2);
                    result.position = 0;
                    result.writeShort(EXIF_HEAD);
                    result.position = 2;
                    result.writeShort(exifDataLength);
                }
                catch (err:EOFError)
                {
                    return null;
                }
            }
            return result;
        }// end function

        private static function isJPG(param1:ByteArray) : Boolean
        {
            param1.endian = Endian.BIG_ENDIAN;
            param1.position = 0;
            if (param1.readUnsignedShort() == JPG_DISTINCTION)
            {
                return true;
            }
            trace("not jpg file");
            return false;
        }// end function

    }
}
