package com.kitschpatrol {
	import com.bit101.components.HUISlider;
	import com.bit101.components.PushButton;
	import com.bit101.components.Text;
	import com.hurlant.math.BigInteger;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.ActivityEvent;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.media.Camera;
	import flash.media.Video;
	import flash.utils.ByteArray;
	import flash.utils.getTimer;
	
	// note modifications to big integer
	[SWF(width="1024", height="768", backgroundColor="0x444444", frameRate="40")]	
	
	public class AllThumbs extends Sprite	{

		// navigation window
		private var window:Window;
		private var deltaSlider:HUISlider;
		private var locationText:Text;
		private var submitTextButton:PushButton;
		private var submitCameraButton:PushButton;
		
		private var video:Video;
		private var camera:Camera;
		private var cameraBitmap:Bitmap;
		private var processedCameraBitmap:Bitmap;
		private var cameraRect:Rectangle;
		private var cameraBytes:ByteArray;
		private var cameraPixelStringX:String;
		private var cameraPixelStringY:String;
		
		public function AllThumbs() {
			// Build the window
			window = new Window(0, 0, 1024, 600);
			addChild(window);
			
			// the crosshairs
			var crosshairs:Shape = new Shape();
			crosshairs.graphics.lineStyle(4, 0xff0000, 0.5);
			crosshairs.graphics.drawRect(0, 0, window.cellWidth * 1.2, window.cellHeight * 1.2);
			crosshairs.x = window.windowCenter().x - crosshairs.width / 2;
			crosshairs.y = window.windowCenter().y - crosshairs.height / 2;
			addChild(crosshairs);
			
			// the slider
			deltaSlider = new HUISlider(this, 100, 740,"Delta", onDeltaSlide);
			deltaSlider.minimum = 1;
			deltaSlider.maximum = Number.MAX_VALUE;
			
			// the text
			locationText = new Text(this, 12, 650, "0");
			locationText.width = 1000;
			locationText.height = 40;
			
			// the text submit button
			submitTextButton = new PushButton(this, 12, 700, "GO", onSubmitText);
			
			// the camera submit button
			submitCameraButton = new PushButton(this, 800, 700, "GO", onSubmitCamera);
			
			
			window.addEventListener(Window.SELECTION_CHANGE, onSelectionChange);
			
			// The camera
			camera = Camera.getCamera();
			camera.setMode(64, 48, 30);
			video = new Video(64, 48);
			video.attachCamera(camera);
			video.addEventListener(Event.ENTER_FRAME, onCameraUpdate);

			cameraRect = new Rectangle(0, 0, 48, 48);
			cameraBitmap = new Bitmap(new BitmapData(48, 48, false, 0));
			processedCameraBitmap = new Bitmap(new BitmapData(48, 48, false, 0xffffff));
			processedCameraBitmap.x = 500;
			addChild(processedCameraBitmap);
			
			
		}
		
		private function onCameraUpdate(e:Event):void {
			cameraBitmap.bitmapData.draw(video);
			var pt:Point = new Point(0, 0);
			
			var threshold:uint =  (0x666666 / 2); 
			var color:uint = 0xff0000;
			var maskColor:uint = 0xffffff;
			processedCameraBitmap.bitmapData = new BitmapData(48, 48, false, 0xffffff);
			processedCameraBitmap.bitmapData.threshold(cameraBitmap.bitmapData, cameraRect, pt, "<", threshold, color, maskColor, false);
			
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
			var targetString:String = Utilities.zeroPad(target.toString(2), window.xRes * window.yRes);
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
		
		public function onDeltaSlide(e:Event):void {
			trace(deltaSlider.value.toString());
			window.setDelta(new BigInteger(deltaSlider.value.toString(), 10).multiply(new BigInteger("340282366920939581727705773432875169785", 10)));
		}
		
		

	}	
}