package com.kitschpatrol
{

	
	import com.hurlant.math.BigInteger;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	
	public class MiniMap extends Sprite
	{
		
		private var window:Window;
		private var map:Bitmap;
		
		public function MiniMap(_w:int, _h:int, _window:Window)
		{
			super();
			window = _window;
			map = new Bitmap(new BitmapData(_w, _h, false, 0xff0000));
			
			var xStep:BigInteger = window.X_MAX.divide(BigInteger.nbv(map.bitmapData.width));
			var yStep:BigInteger = window.Y_MAX.divide(BigInteger.nbv(map.bitmapData.height));
			var xValue:BigInteger = BigInteger.ZERO;
			var yValue:BigInteger = BigInteger.ZERO;
			var xOffset:int = 0;
			var yOffset:int = 0;		
			var totalPixelCount:int = window.X_RES * window.Y_RES;
			var pixelString:String;
			var totalOneCount:int = 0;
			var pixelColor:uint = 0;
			var xOneCount:int = 0;
			
			var pix: int = 0;
			
			map.bitmapData.lock();
			for(var i:int = 0; i < map.bitmapData.width; i++) {
				
				xOneCount = xValue.getOneCount();
				
				
				for(var j:int = 0; j < map.bitmapData.height; j++) {
					// map to that point...
					// store the coordinates in a table to speed lookup?
					
					// count the ones (white pixels)
					// ratio of white to black determines grayness, order is not important
					totalOneCount = yValue.getOneCount() + xOneCount;
					//trace(totalOneCount);
					pixelColor = Utilities.map(totalOneCount, 0, totalPixelCount, 0, 255);
					
					map.bitmapData.setPixel(i, j, Utilities.rgbToHex(pixelColor, pixelColor, pixelColor));
										
					yValue = yValue.add(yStep);
				}
				
				yValue = BigInteger.ZERO;
				xValue = xValue.add(xStep);
			}
			map.bitmapData.unlock();	
			
			addChild(map);
			
			window.addEventListener(Window.SELECTION_CHANGE, onSelectionChange);
			
			drawCoordinates(window.selectedX, window.selectedY);
			
		}
		
		// when responding to others
		private function onSelectionChange(e:Event):void {
			// update ourselves
			drawCoordinates(window.selectedX, window.selectedY);
		}
		
		private function drawCoordinates(xPos:BigInteger, yPos:BigInteger):void {
			
			// map the global coordiantes to local
			var localX:int = BigInteger.bigMap(xPos, BigInteger.ZERO, window.X_MAX, BigInteger.ZERO, BigInteger.nbv(map.bitmapData.width)).intValue();
			var localY:int = BigInteger.bigMap(yPos, BigInteger.ZERO, window.Y_MAX, BigInteger.ZERO, BigInteger.nbv(map.bitmapData.height)).intValue();
			
			trace(localX + " : " + localY);
			
			
			
		}
		
	}
}