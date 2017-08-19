﻿package  {
	
	import flash.display.MovieClip;
	import flash.text.TextField;
	import flash.events.MouseEvent;
	import flash.text.TextFormat;
	import fl.text.TLFTextField;
	import flash.text.AntiAliasType;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileStream;
	import flash.filesystem.FileMode;
	
	public class ins extends MovieClip {
		
		private var onStartFunction:Function;
		private var emailTF:TextField = new TextField();
		private var fileName:String;
		
		public function ins(_onStartFunction:Function) {
			
			this.onStartFunction = _onStartFunction;

			addChild(emailTF);
			emailTF.height = 30;
			emailTF.width = 200;
			emailTF.y = 115;
			emailTF.x = -150;
			emailTF.type = "input";
			emailTF.border = true;
			emailTF.borderColor = 0xFFFFFF;
			emailTF.multiline = true;
			emailTF.restrict = "a-zA-Z0-9@._";
			emailTF.addEventListener(Event.CHANGE, onEmailTFChanged);
			
			var emailtxt:TLFTextField = new TLFTextField();
			emailtxt.text = "پست الکترونیکی ";
			emailtxt.embedFonts = false;
			emailtxt.selectable = false;
			emailtxt.mouseEnabled = false;
			emailtxt.antiAliasType = AntiAliasType.ADVANCED;
			emailtxt.width = 200;
			
			var format:TextFormat = new TextFormat();
			format.font = "B Homa";
			format.bold = true;
			format.color = 0xFFFFFF;
			format.size = 19;
			emailtxt.x = emailTF.x + emailTF.width + 10;
			emailtxt.y = emailTF.y - 5;
			
			var txtFormat:TextFormat = new TextFormat();
			txtFormat.font = "B Homa";
			txtFormat.bold = true;
			txtFormat.color = 0xFFFFFF;
			txtFormat.size = 12;
			
			emailtxt.defaultTextFormat = format;
			emailtxt.setTextFormat(format);
			emailTF.defaultTextFormat = txtFormat;
			emailTF.setTextFormat(txtFormat);
			
			addChild(emailtxt);
			
			var bt:startBt = new startBt();
			bt.x=0;
			bt.y = 185;
			addChild(bt);
			bt.addEventListener(MouseEvent.CLICK,clickMouse);
		}
		
		private function onEmailTFChanged(e:Event):void {
			if(emailTF.text != "") {
				emailTF.borderColor = 0xFFFFFF;
			}
		}
		
		private function clickMouse(e:MouseEvent):void
		{
			if(emailTF.text == "" || !isValidEmail(emailTF.text)) {
				emailTF.borderColor = 0xFF0000;
				return;
			}
			
			this.fileName = emailTF.text + "-" + getCurrDateAndTime();
			trace("file name: " + fileName);
			var filePath:String = "CloudOutput\\" + this.fileName + ".txt";
			
			var file:File = File.desktopDirectory.resolvePath(filePath);
			var stream:FileStream = new FileStream();
			trace(filePath);
			stream.open(file, FileMode.APPEND);
			stream.close();
			
			onStartFunction();
		}
		
		private function isValidEmail(email:String):Boolean {
			var emailExpression:RegExp = /([a-z0-9._-]+?)@([a-z0-9.-]+)\.([a-z]{2,4})/;
			return emailExpression.test(email);
		}
		
		public function getEmail():String {
			return this.fileName;
		}
		
		private function getCurrDateAndTime():String {
			var dateObj:Date = new Date();
			var year:String = String(dateObj.getFullYear());
			var month:String = String(dateObj.getMonth() + 1);
			if (month.length == 1) {
				month = "0"+month;
			}
			var date:String = String(dateObj.getDate());
			if (date.length == 1) {
				date = "0"+date;
			}
			var res:String = year + "-" + month + "-" +date;
			res += "-" + dateObj.hours + "-" + dateObj.minutes + "-" + dateObj.seconds;
			return res;
		}
	}
	
}
