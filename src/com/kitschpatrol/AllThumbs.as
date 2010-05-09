package com.kitschpatrol {
	import com.bit101.components.HUISlider;
	import com.bit101.components.Label;
	import com.bit101.components.PushButton;
	import com.bit101.components.Text;
	import com.bit101.components.VSlider;
	import com.hurlant.crypto.symmetric.NullPad;
	import com.hurlant.math.BigInteger;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.StageDisplayState;
	import flash.display.StageQuality;
	import flash.display.StageScaleMode;
	import flash.events.ActivityEvent;
	import flash.events.ContextMenuEvent;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.media.Camera;
	import flash.media.Video;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	import flash.utils.ByteArray;
	import flash.utils.getTimer;
	
	import flashx.textLayout.tlf_internal;
	
	// note modifications to big integer
	[SWF(width="1360", height="768", backgroundColor="0x4a525a", frameRate="40")]	
	
	public class AllThumbs extends Sprite	{

		// navigation window
		private var window:Window;
		private var deltaSlider:HUISlider;
		private var locationText:Text;
		private var submitTextButton:PushButton;
		private var submitCameraButton:PushButton;
		private var textLabel:Label;
		private var thresholdSlider:VSlider;
		
		private var video:Video;
		private var camera:Camera;
		private var cameraBitmap:Bitmap;
		private var processedCameraBitmap:Bitmap;
		private var cameraRect:Rectangle;
		private var cameraBytes:ByteArray;
		private var cameraPixelStringX:String;
		private var cameraPixelStringY:String;
		private var thresholdValue:Number;
		
		// New navigation
		private var viewHolder:NavHolder;
		private var navHolder:NavHolder;
		
		
		public function AllThumbs() {
			toggleFullScreen();
			
			// Build the window
			window = new Window(0, 0, 1360, 768);
			addChild(window);
			
			
			// Build the gui
			
			// The view panel
			viewHolder = new NavHolder(480, 180);
			viewHolder.x = 23;
			viewHolder.y = 550;
			addChild(viewHolder);
			
			var viewControls:NavPane = new NavPane("View");
			
			// the delta slider
			deltaSlider = new HUISlider(viewControls, 10, 40, "Delta", onDeltaSlide);
			deltaSlider.minimum = 1;
			deltaSlider.width = 340;
			deltaSlider.maximum = 346;
			deltaSlider.labelPrecision = 0;
			deltaSlider.height = 20;

			// the zoom slider
			var zoomSlider:HUISlider = new HUISlider(viewControls, 10, 80, "Zoom", onZoomSlide); 
			zoomSlider.minimum = 1;
			zoomSlider.width = 340;
			zoomSlider.maximum = 5;
			zoomSlider.tick = .1;
			
			// the mini map
			var mapLabel:Label = new Label(viewHolder, 340, 40, "Map");
			var miniMap:MiniMap = new MiniMap(120, 120, window);
			miniMap.x = 340;
			miniMap.y = 60;
			viewHolder.addChild(miniMap);
			
			viewHolder.addPane(viewControls);
			
			// The Navigation Panel
			navHolder = new NavHolder(480, 180);
			navHolder.x = 1360 - 527;
			navHolder.y = 550;
			addChild(navHolder);
			
			// the camera tab
			var cameraPane:NavPane = new NavPane("Camera");
			
				
			// the camera slider
			thresholdValue = 0;
			thresholdSlider = new VSlider(cameraPane, 20, 40, onThresholdSlide);
			thresholdSlider.minimum = 0;
			thresholdSlider.maximum = 0xffffff;
			thresholdSlider.height = 120;
			
			// The camera
			camera = Camera.getCamera();
			camera.setMode(64, 48, 30);
			video = new Video(64, 48);
			video.attachCamera(camera);
			video.addEventListener(Event.ENTER_FRAME, onCameraUpdate);
			
			cameraRect = new Rectangle(0, 0, 48, 48);
			cameraBitmap = new Bitmap(new BitmapData(48, 48, false, 0));
			processedCameraBitmap = new Bitmap(new BitmapData(48, 48, false, 0xffffff));
			processedCameraBitmap.x = 50;
			processedCameraBitmap.y = 40;
			processedCameraBitmap.scaleX = 2.5;
			processedCameraBitmap.scaleY = 2.5;
			cameraPane.addChild(processedCameraBitmap);
			
			// the camera submit button
			submitCameraButton = new PushButton(cameraPane, 50, 170, "GO", onSubmitCamera);
			submitCameraButton._label._tf.textColor = 0x0;
			submitCameraButton.width = 120;
			
			navHolder.addPane(cameraPane);
			
			// Text Pane
			var textPane:NavPane = new NavPane("Location");
			textLabel = new Label(textPane, 10, 30, "Possibility #:");			
			
			locationText = new Text(textPane, 10, 50, "0");
			locationText.width = 460;
			locationText.height = 120;
			
			// the text submit button
			submitTextButton = new PushButton(textPane, 10, 175, "GO", onSubmitText);
			submitTextButton._label._tf.textColor = 0x0;			
			
			window.addEventListener(Window.SELECTION_CHANGE, onSelectionChange);			
			
			navHolder.addPane(textPane);
			

			
			// set up a full screen option in the context menu
			var myContextMenu:ContextMenu = new ContextMenu();
			var item:ContextMenuItem = new ContextMenuItem("Toggle Full Screen");
			myContextMenu.customItems.push(item);
			item.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, onFullScreenContextMenuSelect);
			contextMenu = myContextMenu;

			// set up the stage
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.quality = StageQuality.HIGH;
			
			
			
			
//			// the crosshairs
//			var crosshairs:Shape = new Shape();
//			crosshairs.graphics.lineStyle(4, 0xff0000, 0.3);
//			crosshairs.graphics.drawRect(0, 0, window.CELL_WIDTH * 1.2, window.CELL_HEIGHT * 1.2);
//			crosshairs.x = window.windowCenter().x - crosshairs.width / 2;
//			crosshairs.y = window.windowCenter().y - crosshairs.height / 2;
//			addChild(crosshairs);

			
			
		}
		
		private function onZoomSlide(e:Event):void {
			window.setScale(e.target.value, e.target.value);
		}
		
		private function onCameraUpdate(e:Event):void {
			cameraBitmap.bitmapData.draw(video);
			var pt:Point = new Point(0, 0);
			
			
			var color:uint = 0xff0000;
			var maskColor:uint = 0xffffff;
			processedCameraBitmap.bitmapData = new BitmapData(48, 48, false, 0xffffff);
			processedCameraBitmap.bitmapData.threshold(cameraBitmap.bitmapData, cameraRect, pt, "<", thresholdValue, color, maskColor, false);
			
		}
		
		private function onThresholdSlide(e:Event):void {
			thresholdValue = thresholdSlider.value;
		}
		
		private function onSubmitCamera(e:Event):void {
			
			cameraPixelStringX = "";
			cameraPixelStringY = "";
			cameraBytes = processedCameraBitmap.bitmapData.getPixels(cameraRect);
			cameraBytes.position = 0;
			var totalBytes:int = cameraBytes.bytesAvailable; 
			
			while(cameraBytes.bytesAvailable > (totalBytes / 2)) {
				if(cameraBytes.readUnsignedInt() == 0) {
					cameraPixelStringX += "0";
				}
				else {
					cameraPixelStringX += "1";
				}
			}
			
			// finish it off
			while(cameraBytes.bytesAvailable) {
				if(cameraBytes.readUnsignedInt() == 0) {
					cameraPixelStringY += "0";
				}
				else {
					cameraPixelStringY += "1";
				}
			}			
			
			
			window.centerOn(new BigInteger(cameraPixelStringX, 2), new BigInteger(cameraPixelStringY, 2));
			
		}
		
		private function onSubmitText(e:Event):void {
			
			trace("text submit");
			
			// center on the new location
			var target:BigInteger = new BigInteger(locationText.text, 10);
			var targetString:String = Utilities.zeroPad(target.toString(2), window.X_RES * window.Y_RES);
			var xString:String = (targetString.substr(0, targetString.length / 2));
			var yString:String = (targetString.substr(targetString.length / 2, targetString.length -1));
			
			trace(new BigInteger(xString, 2).toString(10));
			trace(new BigInteger(yString, 2).toString(10));
			
			window.centerOn(new BigInteger(xString, 2), new BigInteger(yString, 2));
	
		}
		
		private function onSelectionChange(e:Event):void {
			trace("change");
			locationText.text = window.getSelectedIndex().toString(10);
			

			
		}
		
		private var fiveSteps:BigInteger = new BigInteger("12234465498569413894406478743841145361827162748688159810039079514183939559218391664357372787631594358463168901374701809308891801671007230130066723378042125137212894594296124410621956639403190879922410562428365584417623555614966739717809626431260004568979968393974952774324960520703130399622609141713985447492509246633766908652935623681883409429299", 10);
		private var lastDelataSlideValue:int = 1;
		
		
		
		
		public function onDeltaSlide(e:Event):void {
			
			if(lastDelataSlideValue != deltaSlider.value) {
			trace("New Delta: " + deltaSlider.value.toString());
			
			// special case for the end
			if(deltaSlider.value == 346) {
				trace("five steps");
				window.setDelta(fiveSteps);
			}
			else if(deltaSlider.value == 1) {
				window.setDelta(BigInteger.ONE);
			}
			else {
				window.setDelta(BigInteger.TEN.pow(deltaSlider.value));
			}
			
			}
			
			lastDelataSlideValue = deltaSlider.value;
			//window.setDelta(fiveSteps);
		}
		
		
		
		
		
		private function onFullScreenContextMenuSelect(e:Event):void {
			toggleFullScreen();
		}
		
		private function toggleFullScreen():void {
			if (stage.displayState == StageDisplayState.NORMAL) {
				stage.displayState = StageDisplayState.FULL_SCREEN;
			}
			else {
				stage.displayState = StageDisplayState.NORMAL;
			}
		}


	}	
}