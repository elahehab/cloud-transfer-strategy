package  {
	import flash.filesystem.File;
	import flash.filesystem.FileStream;
	import flash.filesystem.FileMode;
	
	public class BestOutputSaver {
		
		private var currPartLevInfos:Array = new Array();
		private var bestLevInfos:Array = new Array();
		private var m_ctrl:ctrl;
		
		public function BestOutputSaver(_m_ctrl:ctrl) {
			this.m_ctrl = _m_ctrl;
		}
		
		public function addLevInfoToArr(levInfo:levelInfo):void {
			currPartLevInfos.push(levInfo);
			trace("num of lev infos: " + currPartLevInfos.length);
		}
		
		private function writeLevInfosToFile(levInfos:Array):void {
			for(var i:int = 0; i < levInfos.length; i++) {
				var levInfo:levelInfo = levInfos[i];
				var dataStr:String = JSON.stringify(levInfo);
				var file:File = File.desktopDirectory.resolvePath("CloudOutput\\" + m_ctrl.getUserEmailAddr() + ".txt");
				var stream:FileStream = new FileStream();
				stream.open(file, FileMode.APPEND);
				stream.writeUTFBytes(dataStr + "\n");
				stream.close();
			}
		}
		
		public function saveLevInfo():void {
			writeLevInfosToFile(this.currPartLevInfos);
		}
		
		public function compareCurrAndBest():void {
			if(bestLevInfos.length == 0) {
				bestLevInfos = currPartLevInfos;
			} else {
				if(calculatePartScore(currPartLevInfos) > calculatePartScore(bestLevInfos)) {
					bestLevInfos = currPartLevInfos;
				}
			}
			currPartLevInfos = new Array();
		}
		
		public function finishPart():void {
			if(bestLevInfos.length == 0) {
				bestLevInfos = currPartLevInfos;
			}
			this.bestLevInfos = new Array();
			this.currPartLevInfos = new Array();
		}
		
		private function calculatePartScore(arr:Array):Number {
			var arr:Array = getArrTrueAndFalseAnsNum(arr);
			var totalTrueAns:int = arr[0];
			var totalFalseAns:int = arr[1];
			return totalTrueAns/(totalFalseAns + totalTrueAns);
		}
		
		private function getArrTrueAndFalseAnsNum(arr:Array):Array {
			var totalTrueAns:int = 0;
			var totalFalseAns:int = 0;
			for(var i:int = 0; i < arr.length; i++) {
				var levInf:levelInfo = levelInfo(arr[i]);
				if(levInf.falseAnsNum == 0) {
					totalTrueAns++;
				} else {
					totalFalseAns++;
				}
			}
			var arr:Array = new Array();
			arr.push(totalTrueAns);
			arr.push(totalFalseAns);
			return arr;
		}
		
		public function getBestPartTrueAndFalseAnsNum():Array {
			return getArrTrueAndFalseAnsNum(bestLevInfos);
		}
		
		public function getBestPartScore():int {
			var score:int = 0;
			for(var i:int = 0; i < bestLevInfos.length; i++) {
				var levInf:levelInfo = levelInfo(bestLevInfos[i]);
				if(levInf.falseAnsNum == 0) {
					score += levInf.numRainyAbr*10;
				}
			}
			return score;
		}

	}
	
}
