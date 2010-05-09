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
	import flash.events.ActivityEvent;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.media.Camera;
	import flash.media.Video;
	import flash.utils.ByteArray;
	import flash.utils.getTimer;
	
	// note modifications to big integer
	[SWF(width="1360", height="768", backgroundColor="0x444444", frameRate="40")]	
	
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
		
		
		public function AllThumbs() {
			// Build the window
			window = new Window(0, 0, 1360, 768);
			addChild(window);
			window.setScale(1, 1);
			
			
			// what is faster, 2x the operations on half the bits?
			// or 1x the operations on twice the bits
			
//			var full:BigInteger = new BigInteger("3742053650892133432367999773538322459225928823527575869347258443714776254479140165467924450143929014376701328043796892084250680644651644268919891406030558009514559848402392186697349032657288467726728117428485865736692545611669179323917560467904459270003565249200768855069969069462910188335948939853235385655600614050799627402904169955617680686939217306230732743306013312855692685442723231659949822010462888578091073832552856131420378840703853686445535243055462767679945780563431553986820134725467051353840270015201262955847832589866641019681571016376279703475133297517542073557917754709550486937454822846451632280550418910946262563991699255138480187856382366661603621981981643212128456085078015", 10);
//			var half:BigInteger = new BigInteger("61172327492847069472032393719205726809135813743440799050195397570919697796091958321786863938157971792315844506873509046544459008355036150650333616890210625686064472971480622053109783197015954399612052812141827922088117778074833698589048132156300022844899841969874763871624802603515651998113045708569927237462546233168834543264678118409417047146495",10);
//			var delta:BigInteger = new BigInteger("12234465498569413894406478743841145361827162748688159810039079514183939559218391664357372787631594358463168901374701809308891801671007230130066723378042125137212894594296124410621956639403190879922410562428365584417623555614966739717809626431260004568979968393974952774324960520703130399622609141713985447492509246633766908652935623681883409429299", 10).divide(BigInteger.nbv(1000));
//			
//			var start:int = getTimer();
//			for (var i:int = 0; i < 200; i++) {
//				full = full.add(delta);
//				full.toPixels();
//			}
//			trace("Full: " + (getTimer() - start));
//			
//			start = getTimer();			
//			for (var j:int = 0; j < 400; j++) {
//				half = half.add(delta);
//				half.toPixels();
//			}			
//			trace("Half: " + (getTimer() - start));			
			
			
			
//			// the crosshairs
//			var crosshairs:Shape = new Shape();
//			crosshairs.graphics.lineStyle(4, 0xff0000, 0.3);
//			crosshairs.graphics.drawRect(0, 0, window.CELL_WIDTH * 1.2, window.CELL_HEIGHT * 1.2);
//			crosshairs.x = window.windowCenter().x - crosshairs.width / 2;
//			crosshairs.y = window.windowCenter().y - crosshairs.height / 2;
//			addChild(crosshairs);
//			
//			// the slider
//			deltaSlider = new HUISlider(this, 12, 740, "Delta", onDeltaSlide);
//			deltaSlider.minimum = 1;
//			deltaSlider.width = 346 * 2;
//			deltaSlider.maximum = 346;
//			thresholdValue = 0;
//		
//			// The Label
//			textLabel = new Label(this, 12, 605, "Possibility #:");
//			
//			
//			// the text
//			locationText = new Text(this, 12, 625, "0");
//			locationText.width = 600;
//			locationText.height = 60;
//			
//			// the text submit button
//			submitTextButton = new PushButton(this, 12, 690, "GO", onSubmitText);
//			
//			// the camera submit button
//			submitCameraButton = new PushButton(this, 900, 680, "GO", onSubmitCamera);
//			submitCameraButton.width = 48;
//			
//			window.addEventListener(Window.SELECTION_CHANGE, onSelectionChange);
//			
//			// the camera slider
//			thresholdSlider = new VSlider(this, 880, 625, onThresholdSlide);
//			thresholdSlider.minimum = 0;
//			thresholdSlider.maximum = 0xffffff;
//			thresholdSlider.height = 75;
//			
//			// The camera
//			camera = Camera.getCamera();
//			camera.setMode(64, 48, 30);
//			video = new Video(64, 48);
//			video.attachCamera(camera);
//			video.addEventListener(Event.ENTER_FRAME, onCameraUpdate);
//
//			cameraRect = new Rectangle(0, 0, 48, 48);
//			cameraBitmap = new Bitmap(new BitmapData(48, 48, false, 0));
//			processedCameraBitmap = new Bitmap(new BitmapData(48, 48, false, 0xffffff));
//			processedCameraBitmap.x = 900;
//			processedCameraBitmap.y = 625;
//			addChild(processedCameraBitmap);

			
			
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
		
		

	}	
}