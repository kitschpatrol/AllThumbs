package com.kitschpatrol
{
	import com.hurlant.math.BigInteger;
	
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	
	public class Window extends Sprite {
		
		public var xStart:BigInteger;
		public var yStart:BigInteger;
		public var xDelta:BigInteger;
		public var yDelta:BigInteger;
		public var xMax:BigInteger;
		public var yMax:BigInteger;
		public var xTemp:BigInteger;
		public var yTemp:BigInteger;		
		
		public var bitDepth:int;
		
		public var xRes:int; // pixel width
		public var yRes:int; // pixel height
		public var cellWidth:int; // each picture, with padding
		public var cellHeight:int; // each picture, with padding
		public var xCount:int; // cells per pane
		public var yCount:int; // cells per pane
		public var paneWidth:int; // a pane of cells
		public var paneHeight:int; // a pane of cells
		public var padding:int; // pixels between cells
		private var xOffset:int; // mouse offset
		private var yOffset:int; // mouse offset
		private var panes:Array; // list of panes
		private var tempPane:Pane; // a pane to munge
		private var lastMouseX:int;
		private var lastMouseY:int;
		private var xOverdraw:int; // how much to draw outside the window
		private var yOverdraw:int; // how much to draw outside the window
		private var maxWidth:int; // max window width
		private var maxHeight:int; // max window height
		public var xPixelCount:int;
		public var yPixelCount:int;
		public var xPixelBytes:int;
		public var yPixelBytes:int;
		
		
		public var xByteEnd:int; // end of the bytes for the pane
		public var yByteEnd:int;
		
		private var windowMask:Shape;
		
		
		public function Window(_x:int, _y:int, _width:int, _height:int) {
			super();
			this.x = _x;
			this.y = _y;
			
			maxWidth = _width;
			maxHeight = _height;

			this.graphics.beginFill(0);
			this.graphics.drawRect(0, 0, _width, _height);
			this.graphics.endFill();
			
			// simulation settings
			xRes = 48;
			yRes = 48;
			bitDepth = 2;
			xStart = BigInteger.nbv(0);
			yStart = BigInteger.nbv(0);
			xDelta = new BigInteger("12234465498569413894406478743841145361827162748688159810039079514183939559218391664357372787631594358463168901374701809308891801671007230130066723378042125137212894594296124410621956639403190879922410562428365584417623555614966739717809626431260004568979968393974952774324960520703130399622609141713985447492509246633766908652935623681883409429299", 10);
			yDelta = new BigInteger("12234465498569413894406478743841145361827162748688159810039079514183939559218391664357372787631594358463168901374701809308891801671007230130066723378042125137212894594296124410621956639403190879922410562428365584417623555614966739717809626431260004568979968393974952774324960520703130399622609141713985447492509246633766908652935623681883409429299", 10);
			xMax = BigInteger.nbv(bitDepth).pow(xRes * yRes);
			yMax = xMax.clone();
			
			xPixelCount = xRes * yRes / 2;
			yPixelCount = xPixelCount;
			xPixelBytes = xPixelCount / 8;
			yPixelBytes = yPixelCount / 8;
			
			// house keeping
			padding = 1;
			cellWidth = xRes + padding;
			cellHeight = yRes + padding;
			xCount = 6;
			yCount = 6;
			paneWidth = cellWidth * xCount;
			paneHeight = cellHeight * yCount;
			xOverdraw = paneWidth * 2;
			yOverdraw = paneWidth * 2;
			xByteEnd = xRes * (xRes / 2) * 4;
			yByteEnd = xRes * xRes * 4;
			
			
			xOffset = 0;
			yOffset = 0;
			
			panes = new Array();
			
			fillView();
			manageView();
			
			// apply mask
			windowMask = new Shape();
			windowMask.graphics.beginFill(0);
			windowMask.graphics.drawRect(0, 0, _width, _height);
			windowMask.graphics.endFill();
			this.mask = windowMask;
			
			
			this.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		}
		
		
		private function onMouseMove(e:MouseEvent):void {
			if(e.buttonDown) {
				movePanes(e.stageX - lastMouseX, e.stageY - lastMouseY)
			}
			
			lastMouseX = e.stageX;
			lastMouseY = e.stageY;			
		}		
		
		private function paneExists(xTest:int, yTest:int):Boolean {
			for (var i:int = 0; i < panes.length; i++) {
				if ((panes[i].x == xTest) && (panes[i].y == yTest)) {
					return true;
				}
			}
			return false;
		}
		
		// true if the pane is in view. TODO could be more conservative with this?
		private function inView(xTest:int, yTest:int):Boolean {
			if((xTest > xOffset - xOverdraw)
				&& (xTest < maxWidth + xOffset + xOverdraw)
				&& (yTest > yOffset - yOverdraw)
				&& (yTest < maxHeight + yOffset + yOverdraw)) {
				return true;
			}
			return false;
		}
		
		// TODO roll this into fillView()?
		// adds and removes children as appropriate
		private function manageView():void {
			for (var i:int = 0; i < panes.length; i++) {
				tempPane = panes[i];
				if (!inView(tempPane.x, tempPane.y) && this.contains(tempPane)) {
					// remove it
					this.removeChild(tempPane);
				}
				else if(inView(tempPane.x, tempPane.y) && !this.contains(tempPane)) {
					// add it
					this.addChild(tempPane);
				}
			}
		}
				
		// adds new panes to the visible area
		private function fillView():void {
			for (var i:int = xOffset - xOverdraw; i < maxWidth + xOffset + xOverdraw; i += paneWidth) {
				for (var j:int = yOffset - yOverdraw; j < maxHeight + yOffset + yOverdraw; j += paneHeight) {
					// add panes as necessarry
					if (!paneExists(i, j)) {
						
						//make the first one the seed pane
						if(panes.length == 0) {
							trace("seeding");
							xTemp = xStart.clone();
							yTemp = yStart.clone();
							// TODO, make the most recent pane the seed pane, perpetually
							// just pass around a reference
						}
						else {
							// figure out distance from the start value, multiply it out by delta
							xTemp = xStart.add(xDelta.multiply(BigInteger.nbv(((i - panes[0].x) / paneWidth) * xCount)));
							yTemp = yStart.add(yDelta.multiply(BigInteger.nbv(((j - panes[0].y) / paneHeight) * yCount)));
							
							// check the bounds, don't draw past them
							if (xTemp.compareTo(BigInteger.ZERO) == -1) continue;
							if (yTemp.compareTo(BigInteger.ZERO) == -1) continue;
							if (xTemp.compareTo(xMax) == 1) continue;
							if (yTemp.compareTo(yMax) == 1) continue;
							
						}						
						
						tempPane = new Pane(this, i, j, xTemp, yTemp);
						panes.push(tempPane);
					}
				}
			}
		}
		
		private function movePanes(deltaX:int, deltaY:int):void {
			// track the offset
			xOffset += deltaX;
			yOffset += deltaY;
			xOffset %= paneWidth;
			yOffset %= paneHeight;
			
			for(var i:int = 0; i < panes.length; i++) {
				panes[i].x += deltaX;
				panes[i].y += deltaY;
			}
			
			// rebuild the visible area
			fillView();
			manageView();

		}
		
		public function setDelta(newDelta:BigInteger):void {
			// reset, remove all children
			while(this.numChildren > 0) {
				this.removeChildAt(0);
			}
			
			// trash the panes
			panes = new Array();
			
			// update the delta
			xDelta = newDelta;
			yDelta = newDelta;
			
			// back to zero
			xStart = BigInteger.nbv(0);
			yStart = BigInteger.nbv(0);			
			
			// rebuild the view
			fillView();
			manageView();
			
		}
		
		
		
	}
}