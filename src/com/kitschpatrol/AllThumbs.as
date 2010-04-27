package com.kitschpatrol {
	import flash.display.Sprite;
	import com.hurlant.math.BigInteger;
		
	[SWF(width="1024", height="768", backgroundColor="0x444444", frameRate="40")]	
	
	public class AllThumbs extends Sprite	{

		// navigation window
		private var window:Window;
		
		public function AllThumbs() {
			// Build the window
			window = new Window(0, 0, 1024, 600);
			this.addChild(window);
		}
		
		
		
		
		
	}
	
	
	
}