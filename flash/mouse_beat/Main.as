package
{
    import flash.display.*;
    import flash.events.*;
    import flash.text.*;
    import flash.utils.*;
    
    import org.si.sion.*;
    import org.si.sion.effector.*;
    import org.si.sion.utils.*;
    
    import net.wonderfl.score.basic.*;
    import com.bit101.components.*;
    
    [SWF(width=465, height=465, frameRate=60)]
    public class Main extends Sprite
    {
        private var label:TextField;
        public static var driver:SiONDriver;
        private var mml:String = "ccggaag4 ffeeddc4 ggffeed4 ggffeed4 ccggaag4 ffeeddc4";
        private var ary:Array=[];
        private var tmp:Array=[700,600,500,400,300],mmlTmp:Array=[50,70,100,130,150];
        private var counter:int, stageId:int=0;
        private var id:int;
        private var dataList:Vector.<Vector.<SiONData>>;
        public var score:int, scoreLabel:TextField;
        private var preX:Number=0, preY:Number=0, preXX:Number=0, preYY:Number=0;
        private var bubbleList:Vector.<Bubble>;
        private var voices:SiONPresetVoice;
        
        public function Main()
        {
            driver = new SiONDriver();
            voices = new SiONPresetVoice();
            driver.effector.initialize();
            driver.effector.connect(0, new SiEffectStereoDelay());
            driver.effector.connect(1, new SiEffectStereoDelay());
            driver.effector.connect(2, new SiEffectStereoDelay());
            driver.effector.connect(3, new SiEffectStereoDelay());
            driver.effector.connect(4, new SiEffectStereoDelay());
            driver.setVoice(0, voices["valsound.bell2"]);
            driver.setVoice(1, voices["valsound.bell3"]);
            driver.setVoice(2, voices["valsound.bell16"]);
            driver.setVoice(3, voices["valsound.bell15"]);
            driver.setVoice(4, voices["valsound.bell4"]);
            label = new TextField();
            label.mouseEnabled = false;
            label.autoSize = TextFieldAutoSize.LEFT;
            label.htmlText = "<font size=\"50\" color=\"#ffa500\">Click Start!!</font>";
            label.x = 465/2-label.width/2;
            label.y = 465/2-label.height/2;
            addChild(label);
            createAry();
            
            score = 0;
            scoreLabel = new TextField();
            scoreLabel.autoSize = TextFieldAutoSize.LEFT;
            scoreLabel.htmlText = "<font size=\"30\" color=\"#ffa500\">0";
            scoreLabel.x = 350;
            scoreLabel.y = 400;
            scoreLabel.mouseEnabled = false;
            
            stage.addEventListener(MouseEvent.CLICK, onClick);
            
            bubbleList = new Vector.<Bubble>();
            for(var i:int = 0; i < 5; i++){
                var b:Bubble = new Bubble(Math.random()*400+32, 480, 0, -Math.random()-1, Math.random()*10+5);
                addChild(b);
                bubbleList.push(b);
            }
            addChild(scoreLabel);
            
            addEventListener(Event.ENTER_FRAME, onEnterFrame);
        }
        
        private function onEnterFrame(e:Event):void{
            var i:int = bubbleList.length;
            while(i--){
                var b:Bubble = bubbleList[i];
                b.update();
                if(b.y < -30){
                    b.x = Math.random()*400+32;
                    b.y = 480;
                    b.vx = 0;
                    b.vy = -Math.random()-1;
                    b.radius = Math.random()*10+5;
                    b.draw();
                }
            }
        }
        
        public function addScore(value:int):void{
            score += value;
            scoreLabel.htmlText = "<font size=\"30\" color=\"#ffa500\">" + score.toString();
        }
        
        private function createAry():void{
            var str:String = "";
            for(var i:int = 0; i < mml.length; i++){
                if(97 <= mml.charCodeAt(i) &&  mml.charCodeAt(i) <= 103 || mml.charAt(i) == " "){
                    ary.push(str);
                    str = "";
                }
                str += mml.charAt(i);
            }
            ary.push(str);
        }
        
        private function onClick(e:MouseEvent):void{
            removeChild(label);
            dataList = new Vector.<Vector.<SiONData>>();
            for(var i:int = 0; i < mmlTmp.length; i++){
                dataList[i] = new Vector.<SiONData>();
                for(var j:int = 0; j < ary.length; j++){
                    if(ary[j]==" " || ary[j] == "") dataList[i][j] = null;
                    else{
                        dataList[i][j] = driver.compile("t"+ mmlTmp[i].toString() + " l8 %6@" + i.toString() + ary[j]);
                    }
                }
            }
            stage.removeEventListener(MouseEvent.CLICK, onClick);
            start();
        }
        
        
        private function start():void{
            counter = 0;
            id = setInterval(createMarker, tmp[stageId]);
        }
        
        private function createMarker():void{
            if(counter >= dataList[stageId].length){
                clearInterval(id);
                stageId++;
                if(stageId < tmp.length)
                    start();
                else{
                    setTimeout(ranking, 3000);
                    return;
                }
            }
            if(dataList[stageId][counter] != null){
                while(1){
                    var xx:Number = Math.random()*365+50;
                    var yy:Number = Math.random()*365+50;
                    if((Math.abs(preX-xx) > 100 || Math.abs(preY-yy) > 100) && (Math.abs(preXX-xx) > 100 || Math.abs(preYY-yy) > 100)) break;
                }
                var m:Marker = new Marker(dataList[stageId][counter], this);
                if(counter%2==0){
                    preX = m.x = xx;
                    preY = m.y = yy;
                }
                else{
                    preXX = m.x = xx;
                    preYY = m.y = yy;
                }
                
                addChild(m);
                m.play();
            }
            counter++;
        }
        private var _tfStatus:TextField;
        private var _form:BasicScoreForm;
        
        private function ranking():void
        {
            Style.fontSize=8;
            _form = new BasicScoreForm(this, (465-BasicScoreForm.WIDTH)/2, (465-BasicScoreForm.HEIGHT)/2, score, 'SAVE SCORE', showRanking);
        }
        
        private function showRanking($didSavedScore:Boolean):void {
            _tfStatus = new TextField;
            _tfStatus.text = 'saved score : ' + $didSavedScore;
            addChild(_tfStatus);
            // removes form
            removeChild(_form);
            
            var ranking:BasicScoreRecordViewer = new BasicScoreRecordViewer(this, (465-BasicScoreRecordViewer.WIDTH)/2,(465-BasicScoreRecordViewer.HEIGHT)/2,'RANKING', 99, true);
        }
    }
}
import flash.display.*;
import flash.events.*;
import flash.text.*;
import org.libspark.betweenas3.*;
import org.libspark.betweenas3.easing.*;
import org.libspark.betweenas3.tweens.*;
import org.si.sion.*;


class Marker extends Sprite{
    private var count:int;
    private var spList:Vector.<Sprite>;
    private var labelSp:Sprite;
    private var label:TextField;
    private var data:SiONData;
    private var sp:MouseBeat;
    private var t:ITween=null;
    public function Marker(data:SiONData, sp:MouseBeat){
        this.data = data; this.sp = sp;
        
        graphics.lineStyle(15, 0xffa500);
        graphics.beginFill(0,0);
        graphics.drawCircle(0,0,60);
        graphics.endFill();
        graphics.lineStyle(4, 0xFFFFFF);
        graphics.drawCircle(0,0,59);
        
        spList = new Vector.<Sprite>();
        for(var i:int = 0; i < 60; i++){
            var rect:Sprite = new Sprite();
            if(i >= 30) rect.graphics.beginFill(0xff4500);
            else rect.graphics.beginFill(0xffa500);
            rect.graphics.drawRect(-7.5, -2.0, 15, 4);
            rect.graphics.endFill();
            var angle:Number = 2*Math.PI/30*i-Math.PI/2;
            rect.x = Math.cos(angle)*45;
            rect.y = Math.sin(angle)*45;
            addChild(rect);
            rect.visible = false;
            rect.rotation = 12*i-90;
            spList.push(rect);
        }
        scaleX = scaleY = 0;
        
        label = new TextField();
        label = new TextField();
        label.autoSize = TextFieldAutoSize.LEFT;
        label.htmlText = "<font size=\"30\" color=\"#ffa500\">Push</font>";
        label.x = -label.width/2;
        label.y = -label.height/2;
        labelSp = new Sprite();
        labelSp.addChild(label);
        labelSp.scaleX = labelSp.scaleY = 0;
        addChild(labelSp);
        buttonMode = true;
        mouseChildren = false;
        addEventListener(MouseEvent.CLICK, onClick);
    }
    
    private function onClick(e:MouseEvent):void{
        removeEventListener(Event.ENTER_FRAME, onEnterFrame);
        mouseEnabled = false;
        MouseBeat.driver.play(data);
        t.stop();
        t = BetweenAS3.to(this, {scaleX:1.5, scaleY:1.5, alpha:0}, 0.5);
        
        var ti:int = Math.abs(30 - count);
        if(ti <= 2){    
            createBall(10);
            label.htmlText = "<font size=\"30\" color=\"#ffa500\">Cool</font>";
            sp.addScore(1000);
        }
        else if(ti <= 5){
            createBall(5);
            label.htmlText = "<font size=\"30\" color=\"#ffa500\">Great</font>";
            sp.addScore(500);
        }
        else if(ti <= 10){
            createBall(3);
            label.htmlText = "<font size=\"30\" color=\"#ffa500\">Good</font>";
            sp.addScore(100);
        }
        else label.htmlText = "<font size=\"30\" color=\"#ffa500\">Bad</font>";
        
        t.onComplete = remove;
        t.play();
    }
    
    private function createBall(n:int):void{
        for(var i:int = 0; i < n; i++){
            sp.addChild(new Ball(x, y, Math.random()*10-5, -Math.random()*5, Math.random()*10, sp));
        }
    }
    
    public function play():void{
        count = 0;
        t = BetweenAS3.to(this, {scaleX:1, scaleY:1}, 0.5, Sine.easeIn);
        t.onComplete = function():void{addEventListener(Event.ENTER_FRAME, onEnterFrame);};
        t.play();
    }
    
    private function onEnterFrame(e:Event):void{
        if(count < 60)spList[count].visible = true;
        count++;
        if(count <= 30) labelSp.scaleX = labelSp.scaleY = count/30;
        if(count == 32){
            t = BetweenAS3.to(this, {alpha:0}, 0.5, Sine.easeOut);
            t.onComplete = remove;
            t.play();
        }
    }
    
    private function remove():void{
        sp.removeChild(this);
        removeEventListener(Event.ENTER_FRAME, onEnterFrame);
    }
}

class Ball extends Sprite{
    private var vx:Number, vy:Number, radius:Number, sp:Sprite;
    public function Ball(x:Number, y:Number, vx:Number, vy:Number, radius:Number, sp:Sprite):void{
        this.x = x; this.y = y; this.vx = vx; this.vy = vy; this.radius = radius; this.sp = sp;
        graphics.beginFill(0xffa500);
        graphics.drawCircle(0,0,radius);
        graphics.endFill();
        graphics.lineStyle(2, 0xFFFFFF);
        graphics.drawCircle(0,0,radius*0.7);
        scaleX = scaleY = 0;
        addEventListener(Event.ENTER_FRAME, onEnterFrame);
        
        BetweenAS3.to(this, {scaleX:1, scaleY:1}, 0.5).play()
        var t:ITween = BetweenAS3.to(this, {alpha:0}, 1);
        t.onComplete = remove;
        t.play();
    }
    
    private function remove():void{
        removeEventListener(Event.ENTER_FRAME, onEnterFrame);
        sp.removeChild(this);
    }
    
    private function onEnterFrame(e:Event):void{
        x += vx;
        y += vy;
        vy += 0.3;
    }
}

class Bubble extends Sprite{
    public var vx:Number, vy:Number, radius:Number;
    public function Bubble(x:Number, y:Number, vx:Number, vy:Number, radius:Number){
        this.x = x; this.y = y; this.vx = vx; this.vy = vy; this.radius = radius;
        draw();
    }
    
    public function draw():void{
        graphics.clear();
        graphics.beginFill(0xFFa500);
        graphics.drawCircle(0,0,radius);
        graphics.endFill();
        graphics.lineStyle(2,0xFFFFFF);
        graphics.drawCircle(0,0,radius*0.7);
        alpha = 0;
    }
    
    public function update():void{
        x += vx;
        y += vy;
        vx += Math.random()*0.5-0.25;
        if(vx > 1) vx = 1;
        else if(vx < -1) vx = -1;
        if(alpha < 0.7)alpha += 0.01;
    }
}