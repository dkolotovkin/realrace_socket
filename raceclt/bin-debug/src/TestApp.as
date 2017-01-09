package {
  import flash.display.Sprite;

  import flash.text.*;
  import flash.events.*;

  import vk.APIConnection;
  import vk.events.*;
  import vk.ui.VKButton;

  /**
   * @author Andrew Rogozov
   */
  public class TestApp extends Sprite {
  	private var tf: TextField;
  	
    public function TestApp() {
    	if (stage) init();
    	else addEventListener(Event.ADDED_TO_STAGE, init);
    }
	private function fetchUserInfo(data: Object): void {
		// Example of fetching info from API request
		tf.appendText("\n// -- API request result:\n");
		for (var key: String in data[0]) {
    	  tf.appendText(key + "=" + data[0][key] + "\n");
    	}
	}
	private function onApiRequestFail(data: Object): void {
		// Example of fetching fail from API request
		tf.appendText("Error: "+data.error_msg+"\n");
	}
	private function wallPostSuccess(data: Object): void {
		tf.appendText("Success wall.post post_id: "+data.post_id.toString()+"\n");
	}
	private function wallPostFail(data: Object): void {
		tf.appendText("Fail wall.post error_msg: "+data.error_msg+"\n");
	}
    private function init(e: Event = null): void {
    	if (e) {
    		removeEventListener(e.type, init);
    	}
    	tf = new TextField();
    	tf.x = 10;
    	tf.y = 50;
    	tf.width = 587;
    	tf.height = 349;
    	
    	tf.border = true;
    	tf.borderColor = 0xDAE2E8;
    	tf.background = true;
    	tf.backgroundColor = 0xFFFFFF;
    	tf.embedFonts = false;
    	var format:TextFormat = new TextFormat();
		format.font = "Tahoma";
		format.color = 0x000000;
		format.size = 11;
		tf.defaultTextFormat = format;
    	addChild(tf);
    	tf.appendText("Application initialized\n");
		
		var flashVars: Object = stage.loaderInfo.parameters as Object;
		if (flashVars.api_id) {
			tf.appendText("\n// -- Your code for local testing:\n");
			tf.appendText("flashVars['api_id'] = " + flashVars['api_id'] + ";\n");
			tf.appendText("flashVars['viewer_id'] = " + flashVars['viewer_id'] + ";\n");
			tf.appendText("flashVars['sid'] = \"" + flashVars['sid'] + "\";\n");
			tf.appendText("flashVars['secret'] = \"" + flashVars['secret'] + "\";\n");
			tf.appendText("// -- //\n\n");
		}
		
		// -- For local testing enter you test-code here:
			
		// -- //
		
		if (!flashVars.api_id) tf.appendText("\n[!] Launch application on VK to get your test-code for local testing\n\n");
		
    	var VK: APIConnection = new APIConnection(flashVars);
		
		// Example of API request
		VK.api('getProfiles', { uids: flashVars['viewer_id'] }, fetchUserInfo, onApiRequestFail);
		
		VK.addEventListener('onConnectionInit', function(): void{
    	  tf.appendText("Connection initialized\n");
    	});
    	VK.addEventListener('onWindowBlur', function(): void{
    	  tf.appendText("Window blur\n");
    	});
    	VK.addEventListener('onWindowFocus', function(): void{
    	  tf.appendText("Window focus\n");
    	});
    	VK.addEventListener('onApplicationAdded', function(): void{
    	  tf.appendText("Application added\n");
    	});
    	VK.addEventListener('onBalanceChanged', function(e:CustomEvent): void{
    	  tf.appendText("Balance changed: "+e.params[0]+"\n");
    	});
    	VK.addEventListener('onSettingsChanged', function(e:CustomEvent): void{
    	  tf.appendText("Settings changed: "+e.params[0]+"\n");
    	});
		VK.addEventListener('onMerchantPaymentFail', function(e:CustomEvent): void{
    	  tf.appendText("Payment fail: "+e.params[0]+"\n");
    	});
		VK.addEventListener('onMerchantPaymentSuccess', function(e:CustomEvent): void{
    	  var msg: String = "Successfull payment.";
    	  if (e.params[0]) {
    	    msg += " Order ID: " + e.params[0];
    	  }
    	  tf.appendText(msg + "\n");
    	});
    	VK.addEventListener('onMerchantPaymentCancel', function(): void{
    	  tf.appendText("Payment cancelled\n");
    	});
		
		var btn: VKButton = new VKButton('Settings');
    	btn.x = 15;
    	btn.y = 15;
    	addChild(btn);
    	
    	var btn1: VKButton = new VKButton('Wall post');
    	btn1.x = btn.x + btn.width + 12;
    	btn1.y = btn.y;
    	addChild(btn1);
    	
    	var btn2: VKButton = new VKButton('Install application');
    	btn2.x = btn1.x + btn1.width + 12;
    	btn2.y = btn1.y;
    	addChild(btn2);
    	
    	var btn3: VKButton = new VKButton('Add votes');
    	btn3.x = btn2.x + btn2.width + 12;
    	btn3.y = btn2.y;
    	addChild(btn3);
      
    	var btn4: VKButton = new VKButton('Payment box');
    	btn4.x = btn3.x + btn3.width + 12;
    	btn4.y = btn3.y;
    	addChild(btn4);
    	
    	btn.addEventListener(MouseEvent.CLICK, function(e: Event):void{
    		VK.callMethod("showSettingsBox", 2048);
    	});
    	btn1.addEventListener(MouseEvent.CLICK, function(e: Event):void{
    		VK.api('wall.post', { message: 'some text' }, wallPostSuccess, wallPostFail);
    	});
    	btn2.addEventListener(MouseEvent.CLICK, function(e: Event):void{
    		VK.callMethod("showInstallBox");
    	});
    	btn3.addEventListener(MouseEvent.CLICK, function(e: Event):void{
    		VK.callMethod("showPaymentBox", 0);
    	});
		btn4.addEventListener(MouseEvent.CLICK, function(e: Event):void{
    		VK.callMethod("showMerchantPaymentBox", {
			  test_mode: 1,
			  merchant_id: 11345,
			  item_id_1: 'my_id_1',
			  item_name_1: 'Personal Jet',
			  item_description_1: 'This personal jet is the best way to fly far away.',
			  item_price_1: '0.99',
			  item_currency_1: 643,
			  item_quantity_1: 1,
			  item_photo_url_1: 'http://vk.com/images/gifts/96/149.png',
			  item_digital_1: 1 
			});
    	});
    	
    }
  }
}
