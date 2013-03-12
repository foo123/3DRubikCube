package rubikcube
{
	import flash.events.Event;
	
	public class RubikEvent extends Event
	{
		public static const FACE_CLICK:String = "RubikFaceClick";
		public static const CUBELET_CLICK:String = "RubikCubeletClick";
		public static const FACE_DOUBLE_CLICK:String = "RubikFaceDoubleClick";
		public static const CUBELET_DOUBLE_CLICK:String = "RubikCubeletDoubleClick";
		public static const FACE_OVER:String = "RubikFaceOver";
		public static const CUBELET_OVER:String = "RubikCubeletOver";
		public static const FACE_OUT:String = "RubikFaceOut";
		public static const CUBELET_OUT:String = "RubikCubeletOut";
		public static const FACE_PRESS:String = "RubikFacePress";
		public static const CUBELET_PRESS:String = "RubikCubeletPress";
		public static const FACE_RELEASE:String = "RubikFaceRelease";
		public static const CUBELET_RELEASE:String = "RubikCubeletRelease";
		public static const ROTATION_COMPLETE="RubikRotationComplete";
		public static const MOUSE_MOVE="RubikMouseMove";
		
		public var targetid:int = -1;
		public var seenas:Object = null;
		public var original:Object = null;
		
		public function RubikEvent(type:String, targetidd:int=-1, originalobj:Object=null, seenasobj:Object=null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.targetid = targetidd;
			this.seenas = seenasobj;
			this.original = originalobj;
		}
		
		override public function toString():String
		{
			return "Type : "+type+", Target Index: "+target;
		}
	} // end class
} // end package