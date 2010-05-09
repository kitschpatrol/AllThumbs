package com.kitschpatrol {

	import com.hurlant.crypto.symmetric.NullPad;
	import com.hurlant.math.BigInteger;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	import flash.utils.getTimer;
	
	public class Pane extends Bitmap	{		
		static public var DONE_RENDERING:String = "done rendering"; // fires when the "center" cell changes		
		
		public var xPos:BigInteger;
		public var yPos:BigInteger;
		public var xPosMax:BigInteger; // the right most value
		public var yPosMax:BigInteger; // the bottom most value, yPos + height, kind of
		public var yPosScratch:BigInteger;	
		public var xPosScratch:BigInteger;	
		private var cellPoints:Array;
		private var window:Window;
		private var xBytes:ByteArray;
		private var yBytes:ByteArray;
		private var pixelBytes:ByteArray;
		private var copyRect:Rectangle;
		private var loadIndex:int;
		private var xOffset:int;
		private var yOffset:int;
		private var xIndex:int;
		private var yIndex:int;
		private var cellsPerFrame:int;
		private var cellsThisFrame:int;
		
		// sort render queue based on distance
		public var distance:Number = Number.MAX_VALUE; // start as far away as possible so it won't get sorted to the front
		
		public var isRendered:Boolean = false;
		
		
		// performance timers
		private var paneStart:int;
		private var cellStart:int;
		
		
		public function Pane(_window:Window, _x:int, _y:int, _xPos:BigInteger, _yPos:BigInteger) {
			super();
			
	
			
			window = _window;
			x = _x;
			y = _y;
			xPos = _xPos;
			yPos = _yPos;
			
			xPosMax = xPos.add(window.xDelta.multiply(BigInteger.nbv(window.PANE_X_COUNT)));
			yPosMax = yPos.add(window.yDelta.multiply(BigInteger.nbv(window.PANE_Y_COUNT)));
			
			bitmapData = new BitmapData(window.PANE_WIDTH, window.PANE_HEIGHT, false, 0x222222);
			
			copyRect = new Rectangle(0, 0, window.X_RES, window.Y_RES);
			pixelBytes = new ByteArray();
			
			cellPoints = new Array();
			loadIndex = 0;
			
			xIndex = 0;
			yIndex = 0;
			cellsPerFrame = 6 * 6; // higher for timing purposes
			//cellsPerFrame = window.xCount * window.yCount;
			yPosScratch = yPos.clone();
			xPosScratch = xPos.clone();
		}
		
		public function renderCells():void {
			// start timer for whole pane
			paneStart = getTimer();
			this.addEventListener(Event.ENTER_FRAME, lazyLoadLoop);			
		}
		
		
		private function generateCell(xCell:int, yCell:int, xNumber:BigInteger):void {
			pixelBytes.length = window.PIXEL_BYTE_COUNT;
			
			// figure out the value
			xBytes = xNumber.toPixels();
			yBytes = yPos.add(window.yDelta.multiply(BigInteger.nbv(yCell))).toPixels(); // faster to add and just munge two bigints per cell... YES IT WILL BE because of the copy
			
			xBytes.position = 0;
			yBytes.position = 0;
			xOffset = window.X_BYTE_END - xBytes.bytesAvailable;
			yOffset = window.Y_BYTE_END - yBytes.bytesAvailable;
			
			pixelBytes.position = xOffset;
			pixelBytes.writeBytes(xBytes);
			pixelBytes.position = yOffset;
			pixelBytes.writeBytes(yBytes);
			
			// copy over the pixels
			pixelBytes.position = 0;
			copyRect.x = xCell * window.CELL_WIDTH;
			copyRect.y = yCell * window.CELL_WIDTH;
			this.bitmapData.setPixels(copyRect, pixelBytes);
			
			pixelBytes.clear();
		}
		
		private function lazyLoadLoop(e:Event):void {
			cellsThisFrame = 0;
			
			// doing the bigint math out here means we can do it 5 times less
			// TODO move the byte conversion here too and just paste around the half images using copy?
			while(cellsThisFrame < cellsPerFrame) {
				generateCell(xIndex, yIndex, xPosScratch);			
				
				//trace("X: " + xIndex + " Y: " + yIndex);
				
				yIndex++;
				yPosScratch.add(window.yDelta);
				
				if(yIndex >= window.PANE_Y_COUNT) {
					yIndex = 0;
					yPosScratch = yPos; // reset ypos
					xIndex++;
					xPosScratch = xPosScratch.add(window.xDelta);
				}
				
				if(xIndex >= window.PANE_X_COUNT) {
					this.removeEventListener(Event.ENTER_FRAME, lazyLoadLoop);
					// stop timer for whole pane
					trace("Pane Rendered in: " + (getTimer() - paneStart));
					isRendered = true; // flag ourselves
					this.dispatchEvent(new Event(Pane.DONE_RENDERING)); // announce ourselves
				}
				
				cellsThisFrame++;
			}
			

			
			
		}
		

		
	}
}