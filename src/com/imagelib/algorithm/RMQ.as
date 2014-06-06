package com.imagelib.algorithm
{
	public class RMQ
	{
		public static const TYPE_MINIMUN:uint = 0;
		public static const TYPE_MAXIMUN:uint = 1;
		
		private var _mindp:Vector.<*>;
		private var _maxdp:Vector.<*>;
		
		public function RMQ(mod:*)
		{
			if(!mod || !mod.length) return;
			makerRMQ(mod);
		}
		private function makerRMQ(mod:*):void
		{
			_mindp = new Vector.<*>();
			_maxdp = new Vector.<*>();
			var n:uint = mod.length, 
				i:uint = 0,
				j:uint = mod.length - 1;
			
			for(i = 0; i < n; i ++){
				_mindp[i] = new Vector.<*>();
				_maxdp[i] = new Vector.<*>();
				_mindp[i][0] = mod[i];
				_maxdp[i][0] = mod[i];
			}
			for(j = 1; (1 << j) <= n; j ++){
				for(i = 0; i + (1 << j) - 1 < n; i ++){
					_mindp[i][j] = Math.min(_mindp[i][j - 1], _mindp[i + (1 << (j - 1))][j - 1]);
					_maxdp[i][j] = Math.max(_maxdp[i][j - 1], _maxdp[i + (1 << (j - 1))][j - 1]);
				}
			}
		}
		/***
		 * @desc	查询 区间 [s-v] 中 最小/最大 元素
		 */
		public function query(s:uint, v:uint, type:uint=TYPE_MINIMUN):*
		{
			var k:uint = Math.floor(Math.log((v-s+1)*1.0)/Math.log(2.0));
			if(type == TYPE_MINIMUN){
				return Math.min(_mindp[s][k],_mindp[v-(1<<k)+1][k]);  
			}else if(type == TYPE_MAXIMUN){
				return Math.max(_maxdp[s][k],_maxdp[v-(1<<k)+1][k]); 
			}
		}
	}
}


