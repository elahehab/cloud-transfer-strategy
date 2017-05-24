﻿package  {
	import flash.display.MovieClip;
	import flash.net.URLLoader;
	import flash.events.Event;
	import flash.net.URLRequest;
	import flash.utils.setInterval;
	import flash.utils.clearInterval;
	import flash.utils.setTimeout;
	
	public class PlayerViewer extends MovieClip {

		private var fileLoader:URLLoader = new URLLoader();
		private var pointIdx:int = 0;
		private var intervalId:int;
		private var dataLength:int;
		private var dataArr:Array;
		private var levIdx:int = 0;
		private var levInfoArr:Array = new Array();

		public function PlayerViewer() {
			fileLoader.addEventListener(Event.COMPLETE, onLoaded);
			fileLoader.load(new URLRequest("in.txt"));
		}
		
		function onLoaded(e:Event) {
			var lines:Array = fileLoader.data.split(/\n/);
			
			for(var i:int = 0; i < lines.length; i++) {
				var levInfo = JSON.parse(lines[i]);
				if(levInfo.lev >= 15) {
					levInfoArr.push(levInfo);
				}
			}
			playLevInf();
		}
		
		function playLevInf():void {
			removeChildren();
			pointIdx = 0;
			trace("level number: " + levInfoArr[levIdx].lev + " TrueFalseSeq: " + levInfoArr[levIdx].trueFalseSeq);
			dataArr = levInfoArr[levIdx].allData;
			dataArr = smoothEyeData(dataArr);
			dataLength = dataArr.length;
			if(dataLength > 0)
				intervalId = setInterval(showNextPoint, 40);
			else {
				levIdx++;
				playLevInf();
			}
		}
		
		function showNextPoint():void {
			var point:DataPoint = new DataPoint(this.dataArr[pointIdx]);
			var levInfo:Object = this.levInfoArr[levIdx];
			
			
			if(point == null) {
				trace("point is null");
			}
			var eye_x:Number = point.eye_x;
			var eye_y:Number = point.eye_y;
			
			var rainyDims:Array = point.rainyAbrDim;
			var normalDims:Array = point.normalAbrDim;
			showPoint(eye_x, eye_y, rainyDims, normalDims, levInfo.correctRainy, levInfo.wrongNormal);
		}
		
		function showPoint(eye_x:Number, eye_y:Number, rainyDims:Array, normalDims:Array, correctRainy:Array, wrongNormal:Array):void {
			removeChildren();
			var eyeSym:EyeSym = new EyeSym();
			eyeSym.x = eye_x * 800; eyeSym.y = eye_y*600;
			addChild(eyeSym);
			var centerX:int = 0; var centerY:int = 0; var count:int = 0;
			for(var i:int = 0; i < rainyDims.length; i++) {
				var rainy:AbrRainy = new AbrRainy(null, -1);
				rainy.x = rainyDims[i].abr_x; rainy.y = rainyDims[i].abr_y;
				centerX += rainy.x; centerY += rainy.y; count++;
				if(correctRainy.indexOf(rainyDims[i].id) < 0) {
					rainy.gotoAndStop(rainy.totalFrames - 1);
				}
				addChild(rainy);
			}
			
			for(i = 0; i < normalDims.length; i++) {
				var normal:AbrNormal = new AbrNormal(null, -1);
				normal.x = normalDims[i].abr_x; normal.y = normalDims[i].abr_y;
				
				if(wrongNormal.indexOf(normalDims[i].id) >= 0) {
					normal.gotoAndStop(2);
				}
				/*if(normalDims[i].id == 0 || normalDims[i].id == 4) {
					normal.gotoAndStop(3);
				}*/
				addChild(normal);
			}
			
			centerX /= count; centerY /= count;
			var plusSign:PlusSign = new PlusSign(); plusSign.x = centerX; plusSign.y = centerY;
			plusSign.scaleX = 0.8; plusSign.scaleY = 0.8;
			addChild(plusSign);
			
			pointIdx = pointIdx + 1;
			if(pointIdx >= dataLength) {
				clearInterval(intervalId);
				levIdx++;
				if(levIdx < levInfoArr.length)
					setTimeout(playLevInf, 2000);
			}
		}
		
		private function smoothEyeData(inputArr:Array):Array {
			var smoothLen:int = 5;
			var newArr:Array = new Array();
			for(var i:int = 0 ; i < inputArr.length; i++) {
				var st:int = (smoothLen - 1)/2;
				var eyex_n:Number = 0;
				var eyey_n:Number = 0;
				var cnt:int = 0;
				for(var j:int = -st; j <= st; j++) {
					if(i + j >= 0 && i + j < inputArr.length) {
						eyex_n += inputArr[i+j].eye_x;
						eyey_n += inputArr[i+j].eye_y;
						cnt += 1;
					}
				}
				eyex_n = eyex_n / cnt;
				eyey_n = eyey_n / cnt;
				var dp:DataPoint = new DataPoint(inputArr[i]);
				dp.eye_x = eyex_n;
				dp.eye_y = eyey_n;
				newArr.push(dp);
			}
			return newArr;
		}

	}
	
}
