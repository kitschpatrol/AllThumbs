package com.kitschpatrol {
	import com.bit101.components.HUISlider;
	import com.hurlant.math.BigInteger;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	import flash.utils.getTimer;
	
	// note modifications to big integer
	[SWF(width="1024", height="768", backgroundColor="0x444444", frameRate="40")]	
	
	public class AllThumbs extends Sprite	{

		// navigation window
		private var window:Window;
		private var deltaSlider:HUISlider;
		
		public function AllThumbs() {
			// Build the window
			window = new Window(0, 0, 1024, 600);
			addChild(window);
			
			deltaSlider = new HUISlider(this, 100, 700,"Delta", onDeltaSlide);
			deltaSlider.minimum = 1;
			deltaSlider.maximum = Number.MAX_VALUE;
		}
		
		public function onDeltaSlide(e:Event):void {
			trace(deltaSlider.value.toString());
			window.setDelta(new BigInteger(deltaSlider.value.toString(), 10).multiply(new BigInteger("340282366920939581727705773432875169785", 10)));
		}
		
		

	}	
}