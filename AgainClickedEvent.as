package  {
	import flash.events.Event;
	
	public class AgainClickedEvent extends Event {

		public static const AGAIN_CLICKED:String = "AgainClickedEvent";

		public function AgainClickedEvent(type:String=AGAIN_CLICKED, bubbles:Boolean=true, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
		}
		
		public override function clone():Event
		{
			return new AgainClickedEvent(type,bubbles, cancelable);
		}

	}
	
}
