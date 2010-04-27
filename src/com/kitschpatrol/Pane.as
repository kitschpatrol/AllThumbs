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
		
		
		public function Pane(_window:Window, _x:int, _y:int, _xPos:BigInteger, _yPos:BigInteger) {
			super();
			window = _window;
			x = _x;
			y = _y;
			xPos = _xPos;
			yPos = _yPos;
			
			xPosMax = xPos.add(window.xDelta.multiply(BigInteger.nbv(window.xCount)));
			yPosMax = yPos.add(window.yDelta.multiply(BigInteger.nbv(window.yCount)));
			
			bitmapData = new BitmapData(window.paneWidth, window.paneHeight, false, 0x222222);
			
			copyRect = new Rectangle(0, 0, window.xRes, window.yRes);
			pixelBytes = new ByteArray();
			
			cellPoints = new Array();
			loadIndex = 0;
			
			xIndex = 0;
			yIndex = 0;
			cellsPerFrame = 3;
			yPosScratch = yPos.clone();
			xPosScratch = xPos.clone();

			this.addEventListener(Event.ENTER_FRAME, lazyLoadLoop);
		}
		
		
		private function generateCell(xCell:int, yCell:int, xNumber:BigInteger):void {
			pixelBytes.length = window.pixelByteCount;
			
			// figure out the value
			xBytes = xNumber.toPixels();
			yBytes = yPos.add(window.yDelta.multiply(BigInteger.nbv(yCell))).toPixels();
			
			xBytes.position = 0;
			yBytes.position = 0;
			xOffset = window.xByteEnd - xBytes.bytesAvailable;
			yOffset = window.yByteEnd - yBytes.bytesAvailable;
			
			pixelBytes.position = xOffset;
			pixelBytes.writeBytes(xBytes);
			pixelBytes.position = yOffset;
			pixelBytes.writeBytes(yBytes);
			
			// copy over the pixels
			pixelBytes.position = 0;
			copyRect.x = xCell * window.cellWidth;
			copyRect.y = yCell * window.cellWidth;
			this.bitmapData.setPixels(copyRect, pixelBytes);
			
			pixelBytes.clear();
		}
		
		private function lazyLoadLoop(e:Event):void {
			cellsThisFrame = 0;

			// doing the bigint math out here means we can do it 5 times less
			// TODO move the byte conversion here too....
			while(cellsThisFrame < cellsPerFrame) {
				generateCell(xIndex, yIndex, xPosScratch);			
				
				//trace("X: " + xIndex + " Y: " + yIndex);
				
				yIndex++;
				yPosScratch.add(window.yDelta);
				
				if(yIndex >= window.yCount) {
					yIndex = 0;
					yPosScratch = yPos; // reset ypos
					xIndex++;
					xPosScratch = xPosScratch.add(window.xDelta);
				}
				
				if(xIndex >= window.xCount) {
					this.removeEventListener(Event.ENTER_FRAME, lazyLoadLoop);
				}
				
				cellsThisFrame++;
			}
		}
		

		
	}
}