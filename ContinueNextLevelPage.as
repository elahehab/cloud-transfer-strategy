package  {
	
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import fl.text.TLFTextField;
	import flash.text.AntiAliasType;
	import flashx.textLayout.formats.Direction;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	
	public class ContinueNextLevelPage extends MovieClip {
		

		public function ContinueNextLevelPage(score:int, partNum:int, frame:int = 1) {
			gotoAndStop(frame);
			var againBt:AgainBt = new AgainBt();
			if(frame == 1) {
				var continueBtn:ContinueBtn = new ContinueBtn();
				continueBtn.x = 450;
				continueBtn.y = 529;
				addChild(continueBtn);
				
				againBt.x = 271; againBt.y = 531;
				addChild(againBt);
				againBt.addEventListener(MouseEvent.CLICK, onAgainClicked);
				
				var txt:TLFTextField = getTlfTxt(score.toString() + "%");
				txt.x = 171; txt.y = 327; txt.width = 100; txt.height = 58;
				addChild(txt);
				
				var warn:WarningMsg = new WarningMsg();
				warn.x = 23; warn.y = 363;
				if(checkQuorum(score, partNum)) {
					warn.gotoAndStop(2);
				} else {
					warn.gotoAndStop(1);
				}
				
				if(partNum == 7) {
					warn.gotoAndStop(3);
				}
				addChild(warn);
				
			} else if(frame == 2) {
				var stBt:startBt = new startBt();
				stBt.x = 391; stBt.y = 350;
				addChild(stBt);
				stBt.addEventListener(MouseEvent.CLICK, onStartClicked);
				
				againBt.x = 265; againBt.y = 350;
				addChild(againBt);
				againBt.addEventListener(MouseEvent.CLICK, onAgainClicked);
			}
		}
		
		public function onStartClicked(e:MouseEvent):void {
			dispatchEvent(new ContinueClickedEvent());
		}
		
		public function onAgainClicked(e:MouseEvent):void {
			dispatchEvent(new AgainClickedEvent());
		}
		
		private function getTlfTxt(txt:String):TLFTextField {
			var tf:TLFTextField = new TLFTextField();
			tf.text = txt;
			tf.antiAliasType = AntiAliasType.ADVANCED;
			tf.selectable = false;
			tf.mouseEnabled = false;
			tf.direction = Direction.RTL;
			
			var tformat:TextFormat = new TextFormat("bhoma");
			tformat.size = 25;
			tformat.color = 0x00FF00;
			tformat.align = TextFormatAlign.CENTER;
			
			//Font.registerFont(BHoma);
			tf.defaultTextFormat = tformat;
			tf.setTextFormat(tformat);
			tf.embedFonts = true;
			return tf;
		}
		
		private function checkQuorum(score:int, partNum:int):Boolean {
			if((partNum == 3 && score >= 80) || (partNum == 4 && score >= 60) || (partNum == 5 && score >= 50) ||
			   (partNum == 6 && score >= 50)) {
				return true;
			} else {
				return false;
			}
		}
	}
	
}
