package ;

import createjs.easeljs.Stage;
import createjs.easeljs.Ticker;
import createjs.preloadjs.PreloadJS;
import createjs.soundjs.HTMLAudioPlugin;
import createjs.soundjs.Sound;
import createjs.soundjs.SoundInstance;
import createjs.soundjs.SoundJS;
import js.Lib;
import js.Browser;

/**
 * ...
 * @author matsu4512
 */

class Main 
{
	
	private var stage:Stage;
	private var context:Dynamic;
	
	private var W:Float = 465;
	private var H:Float = 465;
	
	public static function main():Void
	{
		new Main();
	}
 
	public function new()
	{
		Browser.window.onload = prepareSound;
	}
	
	private function prepareSound():Void {
		Sound.addEventListener("fileload", );
	}
 
	private function initHandler():Void
	{
		Ticker.useRAF = true;
		Ticker.setFPS(60);
		Ticker.addListener(tickHandler);

		stage = new Stage(cast Browser.document.getElementById("canvas"));
		stage.autoClear = false;
		context = stage.canvas.getContext("2d");
	}
 
	private function tickHandler():Void
	{
		context.globalCompositeOperation = "source-over";
		context.setTransform(1, 0, 0, 1, 0, 0);
		context.fillStyle = "rgba(0, 0, 0, 0.25)";
		context.fillRect(0, 0, W, H);
		context.globalCompositeOperation = "lighter";

		stage.update();
	}
}
