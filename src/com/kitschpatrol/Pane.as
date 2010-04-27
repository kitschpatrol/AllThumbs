package com.kitschpatrol {
	
	
	import com.hurlant.math.BigInteger;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	
	public class Pane extends Bitmap	{
		
		public var xPos:BigInteger;
		public var yPos:BigInteger;
		public var xPosScratch:BigInteger;
		public var yPosScratch:BigInteger;		
		private var cellPoints:Array;
		private var window:Window;
		private var bitmapScratch:BitmapData;
		private var xString:String;
		private var yString:String;
		private var copyRect:Rectangle;
		private var loadIndex:int;
		
		
		public function Pane(_window:Window, _x:int, _y:int, _xPos:BigInteger, _yPos:BigInteger) {
			super();
			window = _window;
			x = _x;
			y = _y;
			xPos = _xPos;
			yPos = _yPos;			
			bitmapData = new BitmapData(window.paneWidth, window.paneHeight, false, Utilities.randRange(0x000000, 0xffffff));
			bitmapScratch = new BitmapData(window.xRes, window.yRes, false, 0);
			copyRect = new Rectangle(0, 0, window.xRes, window.yRes);
			
			cellPoints = new Array();
			loadIndex = 0;
			
			
			
			for (var i:int = 0; i < window.xCount; i++) {
				for (var j:int = 0; j < window.xCount; j++) {
					cellPoints.push(new Point(i, j));
				}
			}
			
			this.addEventListener(Event.ENTER_FRAME, lazyLoadLoop);
		}
		
		// TODO much faster to go in order and just add?
		private function generateCell(point:Point):void {
			// figure out the value
			//xString = Utilities.zeroPad(xPos.add(window.xDelta.multiply(BigInteger.nbv(point.x))).toString(2), window.xPixelCount);
			//yString = Utilities.zeroPad(yPos.add(window.yDelta.multiply(BigInteger.nbv(point.y))).toString(2), window.yPixelCount);
			
			// fill the bitmap
//			bitmapScratch.lock();
//			var charIndex:int = 0;
//			for (var j:int = 0; j < window.xPixelCount; j++) {
//				for (var k:int = 0; k < window.xPixelCount / 2; k++) {
//					//if (xString.charAt(charIndex) == '1') bitmapScratch.setPixel(j, k, 0xffffff);
//					//if (yString.charAt(charIndex) == '1') bitmapScratch.setPixel(j, k + window.yRes / 2, 0xffffff);
//					charIndex++;
//				}
//			}
//			bitmapScratch.unlock();
//			
			// copy it into the pane
			var destPoint:Point = new Point(point.x * window.cellWidth, point.y * window.cellHeight);
			this.bitmapData.copyPixels(bitmapScratch, copyRect, destPoint);
		}
		
		private function lazyLoadLoop(e:Event):void {
			generateCell(cellPoints[loadIndex++]);
			
			if(loadIndex >= cellPoints.length) {
				this.removeEventListener(Event.ENTER_FRAME, lazyLoadLoop);
			}
		}
		
		private function generateCells():void {
			for (var i:int = 0; i < cellPoints.length; i++) {
				generateCell(cellPoints[i]);
			}
		}
		
	}
}