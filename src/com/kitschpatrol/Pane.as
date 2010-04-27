package com.kitschpatrol {
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	
	public class Pane extends Bitmap	{
		
		public function Pane(_window:Window, _x:int, _y:int) {
			super();
			this.bitmapData = new BitmapData(_window.paneWidth, _window.paneHeight, false, Utilities.randRange(0x000000, 0xffffff));
			this.x = _x;
			this.y = _y;
			trace("added pane");
			
			
		}
	}
}