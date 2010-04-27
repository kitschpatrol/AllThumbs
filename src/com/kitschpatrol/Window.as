package com.kitschpatrol
{
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	
	public class Window extends Sprite {
		
		private var xRes:int;
		private var yRes:int;
		private var cellWidth:int;
		private var cellHeight:int;
		public var paneWidth:int;
		public var paneHeight:int;
		public var padding:int;
		private var xOffset:int;
		private var yOffset:int;
		private var panes:Array;
		private var tempPane:Pane;
		private var lastMouseX:int;
		private var lastMouseY:int;
		private var xOverdraw:int;
		private var yOverdraw:int;
		private var maxWidth:int;
		private var maxHeight:int;
		
		private var windowMask:Shape;

		
		public function Window(_x:int, _y:int, _width:int, _height:int) {
			super();
			this.x = _x;
			this.y = _y;
			
			maxWidth = _width;
			maxHeight = _height;

			
			this.graphics.beginFill(0xff0000);
			this.graphics.drawRect(0, 0, _width, _height);
			this.graphics.endFill();
			
			xRes = 48;
			yRes = 48;
			padding = 0;
			cellWidth = xRes + padding;
			cellHeight = yRes + padding;
			paneWidth = cellWidth * 6;
			paneHeight = cellHeight * 6;
			xOverdraw = paneWidth * 2;
			yOverdraw = paneWidth * 2;
			
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
			this.addChild(windowMask);
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
						tempPane = new Pane(this, i, j);
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
		
	}
}