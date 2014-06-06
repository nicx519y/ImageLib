package baidu.lib.utils {
	
	/**
	 * 对象工具类
	 * @author xiaokun, yaowei
	 */
	public class ObjectUtil {
		
		/**
		 * 深度拷贝一个对象
		 * @param	object			要进行拷贝的对象
		 * @return					拷贝出的对象
		 */
		public static function clone(object:*):* {
			var result:*;
			switch (typeof(object)) {
				case "object":
					if (object is Array) {
						result = new Array();
						for each (var o:* in object) {
							result.push(clone(o));
						}
					} else {
						result = new Object();
						for (var i:* in object) {
							result[i] = clone(object[i]);
						}
					}
					break;
				default:
					result = object;
					break;
			}
			return result;
		}
		
		/**
		 * 将多个对象合并成一个新对象<br/>
		 * 注：只合并一层。如果一个属性，在多个对象中有定义，后面的对象会覆盖前面的对象。
		 * @param	...objects		要合并的对象序列
		 * @return					<Object>合并出的新对象
		 */
		public static function mergeObjects(...objects:Array):Object {
			var result:Object = new Object();
			for each (var obj:Object in objects) {
				for (var i:* in obj) {
					result[i] = obj[i];
				}
			}
			return result;
		}
		
		/**
		 * 从多个对象中取出一个属性(以第一次出现的为准)
		 * @param	key				要取出的属性值
		 * @param	...objects		要查找的对象序列
		 * @return					查找出的属性值
		 */
		public static function getAttrFromObjects(key:*, ...objects:Array):* {
			var result:* = null;
			for each (var obj:Object in objects) {
				if (obj[key] != null){
					result = obj[key];
					break;
				}
			}
			return result;
		}
	}
}
