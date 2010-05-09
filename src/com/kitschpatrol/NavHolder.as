package com.kitschpatrol
{
	import flash.display.Sprite;

	import flash.text.AntiAliasType;
	import flash.text.Font;
	import flash.text.FontStyle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
		
	
	public class NavHolder extends Sprite
	{
		private var panes:Array = [];
		
		
		
		public function NavHolder() {
			super();
			
			this.graphics.beginFill(0x4a525a, .8);
			this.graphics.drawRoundRectComplex(0, 25, 400, 150, 0, 5, 5, 5);
			this.graphics.endFill();
			
		}
		
		public function addPane(navPane:NavPane):void {
			// add the tab
			
			panes.push(navPane);
			
			addChild(navPane);
			
			drawTabs();
			
		}
		
		private function drawTabs():void {
			for(var i:int = 0; i < panes.length; i++) {
				trace(panes[i].tabTitle);
				this.graphics.beginFill(0x4a525a, .8);
				this.graphics.drawRoundRectComplex(0, 0, 75, 25, 5, 5, 0, 0);
				this.graphics.endFill();
				
				var tabTextField:TextField = new TextField();
				var format:TextFormat = new TextFormat();
				format.size = 14;
				format.align = TextFormatAlign.LEFT;
				
				 format.font = "Helvetica";
				 format.bold = true;
				 format.color = 0xffffff;
				 
				 tabTextField.type = TextFieldType.DYNAMIC;
				 tabTextField.text = panes[i].tabTitle;
				 tabTextField.setTextFormat(format);
				 tabTextField.selectable = false;
				 tabTextField.mouseEnabled = false;
				 
				 //textField.x = textField.width / -2;
				 
				 tabTextField.x = 10 + i * 80;
				 tabTextField.y = 4;
				 
				 addChild(tabTextField);				 
				 
			}
		}
	}
}