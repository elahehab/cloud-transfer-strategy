package 
{

	import flash.display.MovieClip;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.events.Event;
	import flash.net.URLRequest;
	import flash.display.Loader;
	import flash.net.FileReference;
	import flash.net.URLVariables;
	import flash.net.URLRequestMethod;
	import flash.net.URLLoader;
	import flash.events.ProgressEvent;
	import flash.media.SoundChannel;
	import flash.display.StageDisplayState;
	import flash.utils.setTimeout;

	public class ctrl extends MovieClip
	{
		var score:int = 0;
		var difficality:int = 0;
		var currentLevel:level = null;
		var timer:Timer = new Timer(500);
		var sb:*;
		var numSeqFault:int = 0;
		var bg:backG;
		var countChangeGradian:Number = 10;
		var maxGradian:Number = 120;

		var firstNumRainyCloud:int = 16;
		var firstNumNormalCloud:int = 1;
		var firstSpeed:int = 6;
		var firstDecrisingAcc:int = 40;

		var soundFalseAns:SoundFalseAns=new SoundFalseAns();
		var soundTrueAns:SoundTrueAns=new SoundTrueAns();
		var soundStartGame:SoundStartGame=new SoundStartGame();
		var soundMouseOver:SoundMouseOver=new SoundMouseOver();

		var musicAbr1:MusicAbr1=new MusicAbr1();
		var musicAbr2:MusicAbr2=new MusicAbr2();


		var soundChannelTempo120:SoundChannel = new SoundChannel();
		var soundChannelTempo140:SoundChannel = new SoundChannel();
		var soundChannelTempo160:SoundChannel = new SoundChannel();

		var lastLevel:int = 0;
		var sessionNumber:int = 0;
		var user_id:int = 0;
		var task_id:int = 0;
		var host:String;

		var numTry:int = 0;
		var numAllTrue:int = 0;
		var numAllFault:int = 0;

		var myLoader:Loader = new Loader();
		var m_count:int = 0;

		var outputText:String = new String();
		var time:int = 0;
		var distribution:int = 1;/* 1-fullScreen 2-UpLEft 3-UpRight 4-DownLeft 5-DownRight
									6-UP 7-Down 8-Right 9-Left*/
		var userEmailAddr:String;
		var m_ins:ins;

		const MAX_NUM_TRY:int = 20;

		var endLevel:int = 10;
		
		var sinTable:Array = [37];
		var cosTable:Array = [37];
		
		var timeIsOut:Boolean = false;
		var levels:Array = null;
		var continuePage:ContinueNextLevelPage;
		
		var showMode:Boolean = false;
		var partNum:int = 1; //1: pre-test, n: n rainy clouds
		
		var outputSaver:BestOutputSaver;

		public function ctrl()
		{
			//this.scaleX = 1.5;
			if(showMode) {
				startClicked();
				return;
			}
			outputSaver = new BestOutputSaver(this);
			m_ins = new ins(startClicked);
			m_ins.x = 400;
			m_ins.y = 270;
			addChild(m_ins);
			
			for(var i:int=0;i<37;i++)
			{
				sinTable[i]=Math.sin(i * 10 * Math.PI / 180);
			}
			for(i=0;i<37;i++)
			{
				cosTable[i]=Math.cos(i * 10 * Math.PI / 180);
			}
			
		}
		
		public function sinApprox(degree:Number):Number
		{
			while(degree > 360)degree-=360;
			while(degree < 0)degree+=360;
			
			var index : int = (int(degree))/10;
			return sinTable[index];
		}
		public function cosApprox(degree:Number):Number
		{
			while(degree > 360)degree-=360;
			while(degree < 0)degree+=360;
			var index : int = (int(degree))/10;
			return cosTable[index];
		}
		
		public function loop(e:Event):void
		{
			m_count++;
		}

		public function startClicked():void
		{
			if(!this.showMode)
				userEmailAddr = m_ins.getEmail();
				
			soundStartGame.play();
			var inputString:String = "0";
			addEventListener(Event.ENTER_FRAME,loop);

			var aa:int = 01;
			if (aa==0)
			{
				inputString = root.loaderInfo.parameters["maxGradian"];
				maxGradian = Number(inputString);

				inputString = root.loaderInfo.parameters["changeGradianTime"];
				countChangeGradian = Number(inputString);

				inputString = root.loaderInfo.parameters["numRainyCloud"];
				firstNumRainyCloud = Number(inputString);

				inputString = root.loaderInfo.parameters["numNormalCloud"];
				firstNumNormalCloud = Number(inputString);

				inputString = root.loaderInfo.parameters["primarySpeed"];
				firstSpeed = Number(inputString);

				inputString = root.loaderInfo.parameters["acceleration"];
				firstDecrisingAcc = Number(inputString);
			}
			else
			{
				maxGradian = 20;
				countChangeGradian = 40;
				firstNumRainyCloud = 1;
				firstNumNormalCloud = 5;
				firstSpeed = 6;
				firstDecrisingAcc = 40;
			}

			bg = new backG();
			addChild(bg);
			var gtitle:GameTitle = new GameTitle();
			gtitle.x = -330;
			gtitle.y = -295;
			bg.addChild(gtitle);

			var url:URLRequest = new URLRequest("Bar.swf");
			myLoader.load(url);
			myLoader.contentLoaderInfo.addEventListener(Event.COMPLETE,externalSWFLoaded);
			myLoader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, onProgressHandler);

		}
		
		function onProgressHandler(event:ProgressEvent):void
		{
			var dataAmountLoaded:Number = event.bytesLoaded / event.bytesTotal * 100;
		}


		public function externalSWFLoaded(e:Event):void
		{
			var assetClass:Class = myLoader.contentLoaderInfo.applicationDomain.getDefinition("SideBar") as Class;
			sb= new assetClass();

			addChild(sb);
			sb.x = 400;
			sb.y = 300;
			sb.difficulty.visible = false;
			sb.scoreBar._setScore(0);
			sb.scoreBar._setMainLevel(1,100);
			sb.time.visible = false;
			
			if(showMode) {
				addChild(new PlayerViewer());
			} else {
				createNewLevel();
			}
		}
		
		public function createNewLevel():void
		{
			if(currentLevel != null && this.contains(currentLevel)) {
				removeChild(currentLevel);
			}
				
			bg.gotoAndStop(1);
			timer.stop();
			
			if(levels == null) {
				levels = new Array();
			
				if(partNum == 1) {
					levels.push([10, 1, generateRandomNum(10, 14),this, 20, 20, 10, 0 ,distribution]);
					//levels.push([10, 1, generateRandomNum(10, 14),this, 20, 20, 10, 0, distribution]);
					//levels.push([10, 2, generateRandomNum(10, 14),this, 30, 10, 10, 0, distribution]);
					//levels.push([10, 2, generateRandomNum(10, 15),this, 12, 10, 10, 0, distribution]);
				} else {
					for(var i = 0; i < 3; i++) {
						levels.push([generateRandomNum(12, 15), partNum, generateRandomNum(12, 15), this, 20, 10, 10, 0, distribution]);
					}
				}
			}
			currentLevel = new level(levels[difficality][0], levels[difficality][1], levels[difficality][2], 
									 levels[difficality][3], levels[difficality][4], levels[difficality][5], 
									 levels[difficality][6], levels[difficality][7], levels[difficality][8]);
			addChild(currentLevel);
			currentLevel.startLevel();
			sb.scoreBar._setMainLevel(difficality+1,levels.length);
		}

		public function finishLevel():void
		{
			difficality += 1;
			if (difficality == levels.length)
			{
				if(this.partNum == 1) {
					continuePage = new ContinueNextLevelPage(0, 2);
					
				} else {
					outputSaver.compareCurrAndBest();
					var tf:Array = outputSaver.getPartTrueAndFalseAnsNum();
					var score:Number = tf[0]/(tf[0] + tf[1]) * 100;
					continuePage = new ContinueNextLevelPage(score, 1);
				}
				addChild(continuePage);
				addEventListener(AgainClickedEvent.AGAIN_CLICKED, onAgainClicked);
				addEventListener(ContinueClickedEvent.CONTINUE_CLICKED, onContinueClicked);
			} else {
				setTimeout(createNewLevel, 1000);
			}
		}
		
		private function onContinueClicked(e:ContinueClickedEvent):void {
			removeEventListener(ContinueClickedEvent.CONTINUE_CLICKED, onContinueClicked);
			removeChild(continuePage);
			
			if(this.partNum == 1) {
				this.partNum = 3;
				this.score = 0;
				this.numAllFault = 0;
				this.numAllTrue = 0;
			} else if(this.partNum < 7) {

				var trueFalseNum:Array = outputSaver.getPartTrueAndFalseAnsNum();
				var numPartTrue:int = trueFalseNum[0];
				var numPartFault:int = trueFalseNum[1];
				
				trace("numPartTrue: " + numPartTrue + " numPartFault: " + numPartFault);
				
				this.numAllFault += numPartFault;
				this.numAllTrue += numPartTrue;
				
				this.sb.scoreBar._incScore(outputSaver.getBestPartScore());
				outputSaver.finishPart();
				
				var partCorrectPercent:Number = numPartTrue / (numPartFault + numPartTrue);
				if(this.partNum == 3 && partCorrectPercent < 0.8) {
					onContinueClickedFinish(e);
					return
				} else if(this.partNum == 4 && partCorrectPercent < 0.6) {
					onContinueClickedFinish(e);
					return;
				} else if((this.partNum == 5 || this.partNum == 6 || this.partNum == 7) && partCorrectPercent < 0.5) {
					onContinueClickedFinish(e);
					return;
				} else {
					this.partNum++;
				}
			}  else {
				onContinueClickedFinish(e);
				return;
			}
			this.levels = null;
			this.difficality = 0;
			trace("numAllTrue: " + this.numAllTrue + " numAllFault: " + this.numAllFault);
			createNewLevel();
		}
		
		private function onAgainClicked(e:AgainClickedEvent):void {
			removeEventListener(AgainClickedEvent.AGAIN_CLICKED, onAgainClicked);
			removeChild(continuePage);
			this.levels = null;
			this.difficality = 0;
			this.score = 0;
			createNewLevel();
		}
		
		private function onContinueClickedFinish(e:ContinueClickedEvent):void {
			sb.scoreBar._finishCounting();
			var assetClass:Class = myLoader.contentLoaderInfo.applicationDomain.getDefinition("finishPage") as Class;
			var finishP:* = new assetClass(sb.scoreBar._getScore(), numAllTrue / (numAllTrue + numAllFault) * 100, host);

			addChild(finishP);
		}

		public function getUserEmailAddr():String
		{
			return this.userEmailAddr;
		}
		
		private function generateRandomNum(st:int, end:int):int {
			return Math.floor(Math.random()*(end - st + 1)) + st;
		}
		
		public function addLevInfoToArr(levInfo:levelInfo):void {
			if(partNum != 1)
				outputSaver.addLevInfoToArr(levInfo);
		}
	}
}