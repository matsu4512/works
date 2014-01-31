package
{
    import com.bit101.components.Label;
    import com.bit101.components.Style;
    
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    import flash.ui.Keyboard;
    import org.si.sion.SiONDriver;
    
    [SWF(width=465, height=465, frameRate=60)]
    public class Main extends Sprite
    {
        private var driver:SiONDriver = new SiONDriver();
        private var soundController:SoundController = new SoundController(driver);
        
        private var MusicObj:Array = [
            {title:"きらきら星",
                mml:"t100 o6 v8 l8 ccggaag4 ffeeddc4 ggffeed4 ggffeed4 ccggaag4 ffeeddc4",
                note:"rrbbrrgrrbbrrgrbrbrbgrbrbrbgrrbbrrgrrbbrrg",
                Lv:1
            },
            {title:"かえるの合唱",
                mml:"t75 o6 v8 l8 cdefedcr efgagfer l4 cccc l16 ccddeeff l8 edc4 t100 cdefedcr efgagfer l4 cccc l16 ccddeeff l8 edc4",
                note:"rrrrbbbbbbbrrrggggrrbbrrbbrbgrrbbrrbbbrrbbrggggrbrbrbrbggg",
                Lv:2},
            {title:"おもちゃの兵隊の行進",
                mml:"t150 l8 v8 o8 g ggeefr4g ggd-d-dr4g gg-fedc>ba"+
                "l4 o7 g<g>g<g8g8 eggr8g8 fggr8g8 egba"+
                "l8 o8 gg-fed4rg e4g4g4rg d4g4g4ra a4a4<d4d4"+
                "l4 o8 g>g16a16-a16b16-b8g8a8g8 ege8gg8 fgf8gg8 egba"+
                "l4 o7 g8g8-f8e8dr8g8 eggr8g8 faa<c erdr"+
                "l4 o8 c8>g16a16-a16b16-b8<c",
                note:"grrbbggrrbbggrbrbrbrbgggrbbrbbgrbgrbgrbbbbbrrggbbggrrbbggrbrbrbrbgggrbgggrbrrbbrrrrrggrrggbbrbgrbrbrbg",
                Lv:3},
            {title:"カノン",
                mml:"t100 l8 o7 v8 reg<cr>dgb rcear>b<eg r>a<cfr>g<ce r>a<cfr>b<dg"+
                "l2 o8 ed c>b ag ab"+
                "l4 o8 ecd>b <c>abg afge afgb"+
                "l8 o8 c>b<c>c>b<gde c<c>bab<eg fedfedc>b agfedfed"+
                "l8 o7 cdefgdgf eagfgfed c>a<ab<c>bag fedagag"+
                "v6 l16 o8 g8efg8efg>gab<cdef e8cde8>efgagfgefg f8agf8ededcdefga f8aga8b<c>gab<cdefg"+
                "l8 o8 e>>eg<c<d>>>b<dg <<c>>cea<b>gb<e a>a<cfg>eg<c a<d>b<d"+
                "l8 o7 ceg<cec4",
                note:"rrrbbbgggrrrbbbgggrrrbbbrbgrbgrbrgbrgbrgbrgbrrbbrrrrbbbbggggrrbbggrbrbrbgbgrgrgrbrgrbrgrbbgbrbgbrgrgbgrgbrbrbrgrrrbbrrggrrbbgbbbrrbbggrrbbrgggrbrbrbrbrbgrrrgbgbgbgbgbrrrrbbbbggggrrrrbbbbggggrrbbrbgrbg",
                Lv:4
            },
            {title:"エリーゼのために",
                mml:"t55 o6 v8 l24 <ed+ ed+e>b<dc >a12rcea b12reg+b <c12r>e<ed+"+
                "ed+e>b<dc >a12rcea b12re<c>b a12rb<cd e8>g<fe d8>f<ed"+
                "c8>e<dc >b12re<er re<err>d+ e12rd+ed+ ed+e>b<dc >a12rcea"+
                "b12reg+b <c12r>e<ed+ ed+e>b<dc >a12rcea b12re<c>b a12rb<cd"+
                "e8>g<fe d8>f<ed c8>e<dc >bre<er re<err>d+ e12rd+ed+"+
                "ed+e>b<dc >arcea b12reg+b <cr>e<ed+ ed+e>b<dc >a12rcea"+
                "b12re<c>b a8",
                note:"rbrbrbgggrrbbrrbbrbrbrbrgggrrrrbbbbrgbgbgrgrgrgbgbgrrbbggrbrbrbrgggrrggbbggrgrgbgbgrbggggrbrbrggbbggrrggbbggrbbggrrgbgrgbgrgbrrrbbbbrrrrbbbbgggbbbgrrrg",
                Lv:5
            },
            {title:"トルコ行進曲",
                mml:"t120 v8 o6 l16 bag+a <c8r8dc>b<c e8r8fed+e bag+abag+a <c4>a8<c8> b8a8g8a8"+
                "o6 l8 <baga bagf+ e4ef gga16g16f16e16 d4ef"+
                "o6 l16 <g8g8agfe d4c8d8 e8e8fedc >b4<c8d8 e8e8fedc >b4bag+a"+
                "o6 l16 <c8r8dc>b<c e8r8fed+e bag+abag+a <c4>a8b8 <c8>b8a8g+8 a8e8f8d8"+
                "o6 l8 <c4>bb a4<ab <c+4>ab <c+>bag+ f+g+ab g+eab"+
                "o6 l8 <<c+4>ab <c+>bag+ f+bg+e a4l16<c+dc+>b abag+f+ag+f+"+
                "o6 l16 <e+f+g+e+c+d+ec+ f+e+f+g+ag+ab <c+>b+<c+>b+<c+dc+>b abag+f+ag+f+ ef+g+ec+d+ec+"+
                "l16 o6 <d+ef+d+>b+<c+d+>b+ <c+4edc+>b ab<c+def+g+a ag+f+eedc+>b ab<c+def+g+a"+
                "l8 o6 <a+bl16edc+>b ab<c+def+g+a ag+f+eedc+>b <c+e>a<c+>b<d>g+b a4<<c+dc+>b abag+f+ag+f+"+
                "l16 o6 <e+f+g+e+c+d+e+c f+e+f+g+ag+ab <c+>b+<c+>b+<c+>b+<c+>a+ <dc+dc+dc+dc+ dc+>bag+abg+"+
                "l16 o6 <ab<c+>f+e+f+g+e+ f+4"+
                "l4 o6 <<c+r c+r l16dc+>b<c+dc+>b<c+ l2d c+ l8>bbbb a4.<c+8 >a4.<e8 >a4.<c+8 l8>a<c+>a<e >l4aa a2;"+
                
                "t60 rrr t120 v6 l8 o5 rr g<ddd >g<ddd >g<d>g<d >g<ddd >c<ddd"+
                "o5 d<ccc >d<c>>a<a d4r4 >b<bd<d>f4r4"+
                "o5 >b<bd<d >f4r4 >g<g>b<b d4r4 >g<g>b<b d4r4"+
                "o5 g<ddd >g<ddd >g<d>g<d >e<b+b+b+ >d<c>ca >b<gca"+
                "o5 ggf+f+ g4r4 gggg gggg ccc+c+ dddd"+
                "o5 gggg gggg ccd+d+ >g4r4 <ebbb"+
                "o5 l8 f+b+b+b+ e+b+b+b+ d+b+b+b+ e+b+b+b+ f+b+b+b+"+
                "o5 l8 f+<e+e+e+ d4r4 >g<ddd >a<d>f+<d >f+<ddd"+
                "o5 l8 d<ccc >g<ddd >a<d>f+<d >ge+cd >g<grr eb+b+b+"+
                "o5 l8 f+b+b+b+ e+b+b+b+ >b+<b+b+b+ >a<aaa >a<aaa"+
                "o5 l8 >b<g>b<a g4"+
                "o5 l8 gggg gggg gggg cccc gggg dddd gggg gggg gggg gggg >g4<g4 g2",
                note:"rbrbrbrbrbrbrbgrgbgrgbgrrbbrrbbggrrgbbggbbrbrbrbbggbrbrb"+
                "rrggbrbrbrrggrbrbrbrbrgrbrbgrbrbgrgbgrgbgrrggbbggrrgrbgrrgbbgrgbgrgbgrbbgrrggbbrrbbg"+
                "rbrbrbrbrbrbrbrbgbgbgbgbgbgbgbgbrgrgrgrgrgrgrgrgrbrbrbrbrbrbg"+
                "grgrgbgbgrgrgbgbgrgrgbgbgrgrbr"+
                "rgrgrbrbrgrgrbrbrgrgrbrbrgrgb"+
                "brbrbgbgbrbrbgbgbrbrbgbgbrbr"+
                "brbrbrbrbrbrbrbrgrgrgbgbgrgrgbgbr"+
                "ggrbrbrbrbggrrbbggrgbgrbrbrgg",
                Lv:6
            },
        ];
        
        
        private var musicListViewer:MusicListViewer;
        private var musicList:Vector.<MusicData> = new Vector.<MusicData>();
        private var data:Vector.<Note>;
        private var musicSimulator:MusicSimulator;
        private var pre:Number=0;
        private var clickLabel:Label;
        //0:曲選択, 1:曲プレイ, 2:リザルト, 3:リザルト待機
        public static var gameMode:int = 0;
        
        public function Main()
        {
            Style.embedFonts = false;
            Style.fontSize = 25;
            clickLabel = new Label(this, 0, 0, "Click Start");
            clickLabel.textField.textColor = 0xFFFFFF;
            clickLabel.x = stage.stageWidth/2-clickLabel.width/2;
            clickLabel.y = stage.stageHeight/2-clickLabel.height/2;
            
            for(var i:int = 0; i < MusicObj.length; i++){
                musicList.push(new MusicData(MusicObj[i], driver));
            }
            
            musicSimulator = new MusicSimulator(soundController);
            graphics.beginFill(0);
            graphics.drawRect(0,0,465,465);
            graphics.endFill();
            musicSimulator.x = 465/2;
            musicSimulator.y = 465/2;
            addChild(musicSimulator);
            stage.addEventListener(MouseEvent.CLICK, start);
            stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
            
            //            driver.play(driver.compile(MusicObj[5].mml));
        }
        
        private function start(event:MouseEvent):void{
            stage.removeEventListener(MouseEvent.CLICK, start);
            
            musicListViewer = new MusicListViewer(musicList);
            addChild(musicListViewer);
            
            musicListViewer.x = stage.stageWidth/2;
            musicListViewer.y = stage.stageHeight/2;
            
            removeChild(clickLabel);
            addEventListener(Event.ENTER_FRAME, onEnterFrame);
        }
        
        private function gameStart():void{
            soundController.play();
        }
        
        private function onKeyDown(event:KeyboardEvent):void{
            switch(event.keyCode){
                case Keyboard.SPACE:
                case Keyboard.DOWN:
                    if(gameMode == 0){
                        var data:MusicData = musicListViewer.select();
                        if(data == null) return;
                        musicListViewer.fadeOut();
                        musicSimulator.play(data);
                        gameStart();
//                        gameMode = 1;
                        pre = new Date().getTime();
                    }
                    else if(gameMode == 1)musicSimulator.judge(2);
                    else if(gameMode == 3){
                        gameMode = 4;
                        musicListViewer.updateLabel();
                    }
                    break;
                case 70:
                case Keyboard.LEFT:
                    if(gameMode == 0)musicListViewer.back();
                    else if(gameMode == 1)musicSimulator.judge(0);
                    break;
                case 74:
                case Keyboard.RIGHT:
                    if(gameMode == 0)musicListViewer.next();
                    else if(gameMode == 1)musicSimulator.judge(1);
                    break;
            }
        }
        
        private function onEnterFrame(e:Event):void{
            var now:Number = new Date().getTime();
            if(gameMode == 1){
                var delta:Number = now - pre;
                if(pre == 0) delta = 0;
                musicSimulator.update(delta);
            }
            else if(gameMode == 4){
                gameMode = 0;
                musicSimulator.resultView.fadeOutAll();
                musicListViewer.fadeIn();
            }
            pre = now;
            musicSimulator.updateGroove();
        }
    }
}

import com.bit101.components.*;
import flash.display.*;
import flash.filters.*;
import flash.geom.*;
import flash.net.*;
import flash.text.*;
import org.libspark.betweenas3.*;
import org.libspark.betweenas3.tweens.*;
import org.si.sion.*;
import org.si.sion.events.*;
import org.si.sion.utils.*;


class GlowCircle extends Sprite
{
    private var r:GlowFilter = new GlowFilter(0xFF0000, 1, 16, 16, 4, 2);
    private var g:GlowFilter = new GlowFilter(0xFF00, 1, 16, 16, 4, 2);
    private var b:GlowFilter = new GlowFilter(0xFF, 1, 16, 16, 4, 2);
    private var d:GlowFilter = new GlowFilter(0x4b0082, 1, 16,16, 4, 2);
    private var circle:Sprite = new Sprite();
    private var tween:ITween, tween2:ITween;
    public function GlowCircle(r:int){
        graphics.lineStyle(3, 0xFFFFFF);
        graphics.drawCircle(0,0,10);
        circle.graphics.lineStyle(3,0xFFFFFF);
        circle.graphics.drawCircle(0,0,10);
        addChild(circle);
        visible = false;
        var t1:ITween = BetweenAS3.to(this, {alpha:1}, 0.1);
        var t2:ITween = BetweenAS3.to(this, {alpha:0}, 0.1);
        var t3:ITween = BetweenAS3.to(this, {scaleX:2, scaleY:2, alpha:0}, 0.2);
        tween = BetweenAS3.serial(t1, t2);
        tween.onComplete = onComp;
        t3.onComplete = onComp;
        tween2 = t3;
    }
    
    public function glow2(color:String):void{
        if(color == "r") filters = [r];
        if(color == "g") filters = [g];
        if(color == "b") filters = [b];
        alpha = 1;
        visible = true;
        tween2.play();
    }
    
    public function glow(color:String):void{
        if(color == "r") filters = [r];
        else if(color == "g") filters = [g];
        else if(color == "b") filters = [b];
        else filters = [d];
        alpha = 0;
        visible = true;
        tween.play();
    }
    
    private function onComp():void{
        scaleX = scaleY = 1;
        visible = false;
    }
}


class MusicData
{
    private static const noteObj:Object = {"c":0, "d":2, "e":4, "f":5, "g":7, "a":9, "b":11};
    public var title:String, Lv:int, data:Vector.<Note>, mml:String;
    public var sionData:SiONData;
    public function MusicData(obj:Object, driver:SiONDriver)
    {
        this.title = obj.title;
        this.Lv = obj.Lv;
        this.mml = obj.mml;
        this.data = parser(obj.mml, obj.note);
        this.sionData = driver.compile("%t 0,1,0 t60 v0 aaa "+mml);
    }
    
    //mmlを単音に分けるパーサー
    private function parser(mml:String, notes:String):Vector.<Note>{
        var result:Vector.<Note> = new Vector.<Note>();
        
        var t:int=100, o:int=6, v:int=8, l:int=4, w:String, note:Note, c:int=0;
        for(var i:int = 0; i < mml.length; i++){
            switch(mml.charAt(i)){
                case ";":
                    i = mml.length;
                    break;
                //テンポ
                case "t":
                    t = getNum(mml, i+1);
                    break;
                //オクターブ
                case "o":
                    o = getNum(mml, i+1);
                    break;
                //ボリューム
                case "v":
                    v = getNum(mml, i+1);
                    break;
                //分
                case "l":
                    l = getNum(mml, i+1);
                    break;
                //休符
                case "r":
                    note = new Note("R",0);
                    w = getTerm(mml, i);
                    note.n = getB(w, 1);
                    if(w.length == 1){
                        w+=l.toString();
                        note.n = l;
                    }
                    note.t = t;
                    result.push(note);
                    break;
                //音符
                case "a":
                case "b":
                case "c":
                case "d":
                case "e":
                case "f":
                case "g":
                    note = new Note(notes.charAt(c),0);
                    c++;
                    w = getTerm(mml, i);
                    note.n = getB(w, 1);
                    if(w.length == 1){
                        w+=l.toString();
                        note.n = l;
                    }
                    note.v = v;
                    note.t = t;
                    note.note = int(noteObj[w.charAt(0)])+12*o;
                    result.push(note);
                    break;
                //オクターブ下げ
                case ">":
                    o--;
                    break;
                //オクターブ上げ
                case "<":
                    o++;
                    break;
                //タイ
                case "&":
                    break;
                default:
            }
        }
        
        return result;
    }
    
    private function getTerm(s:String, start:int):String{
        var result:String = s.charAt(start);
        for(var i:int = start+1; i < s.length; i++){
            if(s.charAt(i) == "+" || s.charAt(i) == "-") continue;
            
            if(isNumber(s.charAt(i)) || s.charAt(i) == ".") result += s.charAt(i);
            else break;
        }
        return result;
    }
    
    private function getB(s:String, start:int):Number{
        var num:String = "", result:Number;
        for(var i:int = start; i < s.length; i++){
            if(isNumber(s.charAt(i))) num += s.charAt(i);
            else break;
        }
        result = int(num);
        if(s.charAt(i) == ".") result /= 1.5;
        return result;
    }
    
    private function getNum(s:String, start:int):int{
        var result:String = "";
        for(var i:int = start; i < s.length; i++){
            if(isNumber(s.charAt(i))) result += s.charAt(i);
            else break;
        }
        return int(result);
    }
    
    private function isNumber(str:String):Boolean{
        for(var i:int = 0; i < str.length; i++){
            if(str.charCodeAt(i) < 48 || 58 <= str.charCodeAt(i))
                return false;
        }
        return true;
    }
    
    private function isAlpha(str:String):Boolean{
        str = str.toLowerCase();
        for(var i:int = 0; i < str.length; i++){
            if(str.charCodeAt(i) < 97 || 122 < str.charCodeAt(i))
                return false;
        }
        return true;
    }
}



class MusicListViewer extends Sprite
{
    private var spList:Vector.<Sprite> = new Vector.<Sprite>();
    private var hiscoreList:Vector.<int> = new Vector.<int>();
    private var titleList:Vector.<String> = new Vector.<String>();
    private var clearList:Vector.<int> = new Vector.<int>();
    private var clearLabelList:Vector.<Label> = new Vector.<Label>();
    private var scoreLabelList:Vector.<Label> = new Vector.<Label>();
    
    private var musicList:Vector.<MusicData>;
    private var position:int = 0;
    public var isMoving:Boolean = false;
    private var right:Sprite = new Sprite(), left:Sprite = new Sprite();
    public function MusicListViewer(list:Vector.<MusicData>)
    {
        this.musicList = list;
        var l:Label = new Label(this, 0, 0, "Music Select");
        l.x = -l.width/2;
        l.y = -150;
        l.textField.textColor = 0xFFFFFF;
        
        right.graphics.beginFill(0xFFFFFF);
        right.graphics.moveTo(0, -20);
        right.graphics.lineTo(20, 0);
        right.graphics.lineTo(0, 20);
        right.graphics.lineTo(0, -20);
        addChild(right);
        right.x = 150;
        
        left.graphics.beginFill(0xFFFFFF);
        left.graphics.moveTo(0, -20);
        left.graphics.lineTo(-20, 0);
        left.graphics.lineTo(0, 20);
        left.graphics.lineTo(0, -20);
        addChild(left);
        left.x = -150;
        
        for(var i:int = 0; i < list.length; i++){
            var sp:Sprite = new Sprite();
            var tlabel:Label = new Label(sp, 0, 0, list[i].title);
            var llabel:Label = new Label(sp, 0, 0, "Lv."+list[i].Lv.toString());
            titleList.push(list[i].title);
            tlabel.textField.textColor = llabel.textField.textColor = 0xFFFFFF;
            tlabel.x = -tlabel.width/2;
            tlabel.y = -tlabel.height-10;
            llabel.x = -llabel.width/2;
            spList.push(sp);
            
            var shareObj:Object = SharedObjectController.getMusicData(list[i].title);
            clearList.push(shareObj.clear);
            hiscoreList.push(shareObj.score);
            
            var clearLabel:Label;
            if(clearList[i] == -1) clearLabel = new Label(sp, 0, 50, "No Play");
            else if(clearList[i] == 0) clearLabel = new Label(sp, 0, 50, "Failed");
            else clearLabel = new Label(sp, 0, 50, "Cleared");
            clearLabel.textField.textColor = 0xFFFFFF;
            clearLabel.x = -clearLabel.width/2;
            
            var scoreLabel:Label = new Label(sp, 0, 80, "High Score: " + hiscoreList[i].toString());
            scoreLabel.x = -scoreLabel.width/2;
            scoreLabel.textField.textColor = 0xFFFFFF;
            
            clearLabelList.push(clearLabel);
            scoreLabelList.push(scoreLabel);
        }
        
        addChild(spList[0]);
    }
    
    public function updateLabel():void{
        var obj:Object = SharedObjectController.getMusicData(titleList[position]);
        if(obj.clear == -1) clearLabelList[position].textField.text = "No Play";
        else if(obj.clear == 0) clearLabelList[position].textField.text = "Failed";
        else if(obj.clear == 1) clearLabelList[position].textField.text = "Cleared";
        scoreLabelList[position].textField.text = "High Score: " + (obj.score as int).toString();
        clearLabelList[position].x = -clearLabelList[position].textField.width/2;
        scoreLabelList[position].x = -scoreLabelList[position].textField.width/2;
    }
    
    public function next():void{
        if(isMoving) return;
        isMoving = true;
        right.alpha = 0.5;
        var i:int = (position+1)%spList.length;
        addChild(spList[i]);
        spList[i].alpha = 0;
        spList[i].x = -200;
        var t:ITween = BetweenAS3.parallel(
            BetweenAS3.to(spList[position], {x:200, alpha:0}, 0.5),
            BetweenAS3.to(spList[i], {x:0, alpha:1}, 0.5));
        t.onCompleteParams = [spList[position]];
        t.onComplete = function(sp:Sprite):void{
            isMoving = false;
            right.alpha = 1;
            removeChild(sp);
        };
        t.play();
        position = i;
    }
    
    public function back():void{
        if(isMoving) return;
        isMoving = true;
        left.alpha = 0.5;
        var i:int = position-1;
        if(i < 0) i = spList.length-1;
        addChild(spList[i]);
        spList[i].alpha = 0;
        spList[i].x = 200;
        var t:ITween = BetweenAS3.parallel(
            BetweenAS3.to(spList[position], {x:-200, alpha:0}, 0.5),
            BetweenAS3.to(spList[i], {x:0, alpha:1}, 0.5));
        t.onCompleteParams = [spList[position]];
        t.onComplete = function(sp:Sprite):void{
            isMoving = false;
            left.alpha = 1;
            removeChild(sp);
        };
        t.play();
        position = i;
    }
    
    public function select():MusicData{
        if(isMoving) return null;
        return musicList[position];
    }
    
    public function fadeOut():void{
        var t:ITween = BetweenAS3.to(this, {alpha:0}, 1);
        t.onComplete = function():void{
            visible = false;
        };
        t.play();
    }
    
    public function fadeIn():void{
        visible = true;
        var t:ITween = BetweenAS3.to(this, {alpha:1}, 0.5);
        t.play();
    }
}



class MusicSimulator extends Sprite
    {
        //キー音なし用
        private var key:Boolean = true;
        private var startTime:int;
        
        //枠円
        private var circleLane:Sprite = new Sprite();
        //半径
        private const R:int = 200, T:int=2000;
        //判定円
        private var judgeCircle:Sprite = new Sprite();
        private var glowCircle:GlowCircle;
        private var sc:SoundController;
        private var notesR:Vector.<Note>, notesG:Vector.<Note>, notesB:Vector.<Note>;
        private var musicData:MusicData;
        private const colorAry:Array = [16711680,16712704,16713728,16715008,16716032,16717056,16718080,16719360,16720384,16721408,16722432,16723712,16724736,16725760,16727040,16728064,16729088,16730112,16731392,16732416,16733440,16734464,16735744,16736768,16737792,16738816,16740096,16741120,16742144,16743168,16744448,16745472,16746496,16747520,16748800,16749824,16750848,16751872,16753152,16754176,16755200,16756224,16757504,16758528,16759552,16760576,16761856,16762880,16763904,16764928,16766208,16767232,16768256,16769280,16770560,16771584,16772608,16773632,16774912,16775936,16776960,16514816,16187136,15924992,15662848,15400704,15073024,14810880,14548736,14286592,13958912,13696768,13434624,13172480,12844800,12582656,12320512,12058368,11796224,11468544,11206400,10944256,10682112,10354432,10092288,9830144,9568000,9240320,8978176,8716032,8453888,8126208,7864064,7601920,7339776,7012096,6749952,6487808,6225664,5897984,5635840,5373696,5111552,4783872,4521728,4259584,3997440,3669760,3407616,3145472,2883328,2555648,2293504,2031360,1769216,1441536,1179392,917248,655104,327424,65280,65284,65288,65293,65297,65301,65306,65310,65314,65318,65322,65327,65331,65335,65340,65344,65348,65352,65356,65361,65365,65369,65374,65378,65382,65386,65390,65395,65399,65403,65408,65412,65416,65420,65425,65429,65433,65437,65442,65446,65450,65454,65459,65463,65467,65471,65475,65480,65484,65488,65493,65497,65501,65505,65509,65514,65518,65522,65527,65531,65535,64511,63487,62207,61183,60159,58879,57855,56831,55807,54783,53503,52479,51455,50175,49151,48127,47103,46079,44799,43775,42751,41727,40447,39423,38399,37375,36095,35071,34047,33023,31743,30719,29695,28415,27391,26367,25343,24319,23039,22015,20991,19711,18687,17663,16639,15615,14335,13311,12287,11007,9983,8959,7935,6911,5631,4607,3583,2303,1279,255,262399,524543,852223,1114367,1376511,1638655,1966335,2228479,2490623,2818303,3080447,3342591,3604735,3932415,4194559,4456703,4718847,4980991,5308671,5570815,5832959,6095103,6422783,6684927,6947071,7274751,7536895,7799039,8061183,8388863,8651007,8913151,9175295,9437439,9765119,10027263,10289407,10617087,10879231,11141375,11403519,11731199,11993343,12255487,12517631,12779775,13107455,13369599,13631743,13893887,14221567,14483711,14745855,15073535,15335679,15597823,15859967,16187647,16449791,16711935,16711931,16711927,16711922,16711918,16711914,16711910,16711905,16711901,16711897,16711892,16711888,16711884,16711880,16711875,16711871,16711867,16711863,16711859,16711854,16711850,16711846,16711842,16711837,16711833,16711829,16711824,16711820,16711816,16711812,16711808,16711803,16711799,16711795,16711791,16711786,16711782,16711778,16711773,16711769,16711765,16711761,16711756,16711752,16711748,16711744,16711740,16711735,16711731,16711727,16711723,16711718,16711714,16711710,16711705,16711701,16711697,16711693,16711688,16711684];
        private var score:int, perfect:int, great:int, good:int, bad:int;
        //ゲージ
        private var grooveCircle:Sprite = new Sprite(), currentColor:int;
        public var resultView:ResultView, totalNotes:int;
        private var combo:int, maxCombo:int;
        
        private var pushTime:Number, timeList:Vector.<Number>, cnt:int=0, f:Boolean = true, delay:Number=0;
        
        public function MusicSimulator(sc:SoundController){
            this.sc = sc;
            
            glowCircle = new GlowCircle(10);
            addChild(glowCircle);
            glowCircle.y = R;
            
            circleLane.graphics.lineStyle(2, 0xFFFFFF, 0.2);
            circleLane.graphics.drawCircle(0, 0, R);
            addChild(circleLane);
            
            judgeCircle.graphics.lineStyle(3, 0xFFFFFF);
            judgeCircle.graphics.drawCircle(0,0,10);
            addChild(judgeCircle);
            addChild(grooveCircle);
            judgeCircle.x = 0;
            judgeCircle.y = R;
            
            currentColor = 0;
            updateGroove();
            
            resultView = new ResultView();
            addChild(resultView);
            
            sc.driver.addEventListener(SiONTrackEvent.NOTE_ON_FRAME, onNoteOn);
        }
        
        
        private function onNoteOn(e:SiONTrackEvent):void{
//            trace(cnt)
            if(cnt == 0) CircularBeat.gameMode = 1;
            if(cnt >= 3) delay = startTime-timeList[cnt-3];
            cnt++;
        }
        
        
        //初期化
        public function initialize():void{
            notesR = new Vector.<Note>();
            notesB = new Vector.<Note>();
            notesG = new Vector.<Note>();
            perfect = great = good = bad = score = combo = maxCombo = 0;
            addScore(0);
            resetCombo();
            timeList = new Vector.<Number>();
            startTime = 0;
            delay = 0;
            cnt = 0;
            f = true;
        }
        
        //円の色変化
        public function updateGroove():void{
            currentColor++;
            if(currentColor >= 720) currentColor = 0;
            var c:int = int(currentColor/2)
            grooveCircle.graphics.clear();
            var m:Matrix = new Matrix();
            m.createGradientBox(450, 450, 0, -225, -225);
            grooveCircle.graphics.beginGradientFill(GradientType.RADIAL, [colorAry[c], colorAry[c]], [0.5, 0], [0, 255], m);
            grooveCircle.graphics.drawCircle(0,0,450);
            grooveCircle.graphics.endFill();
        }
        
        //ゲームスタート
        public function play(music:MusicData):void{
            initialize();
            resultView.play(music.title);
            
            if(key){
                startTime = 0;
            }
            musicData = music;
            var next:int = 3000;
            var data:Vector.<Note> = music.data;
            totalNotes = 0;
            
            for(var i:int = 0; i < data.length; i++){
                var note:Note = data[i];
                note.x = 0;
                note.y = -R;
                note.time = next;
                if(key && note.type != "R")timeList.push(note.time);
                note.num = i;
                note.alpha = 0;
                note.scaleX = note.scaleY = 1;
                note.display = false;
                next +=　(60*1000/note.t)*(4/note.n);
                totalNotes++;
                if(note.type == "r") notesR.push(note);
                else if(note.type == "b") notesB.push(note);
                else if(note.type == "g"){
                    var note2:Note = new Note("g2", note.n);
                    note2.x = note.x;
                    note2.y = note.y;
                    note2.time = note.time;
                    notesG.push(note);
                    notesG.push(note2);
                }
                else if(note.type == "R"){
                    totalNotes--;
                }
            }
            
            sc.driver.play(musicData.sionData);
        }
        
        //スコア加算
        private function addScore(v:int):void{
            score += v;
            if(score < 0) score = 0;
            resultView.updateScore(score);
        }
        
        //コンボ加算
        private function addCombo():void{
            combo++;
            if(maxCombo < combo) maxCombo = combo;
            resultView.updateCombo(combo);
        }
        
        //コンボリセット
        private function resetCombo():void{
            combo = 0;
            resultView.updateCombo(combo);
        }
        
        //ノートの更新
        private function updateNotes(list:Vector.<Note>, delta:Number):void{
            var i:int = list.length;
            while(i--){
                var note:Note = list[i];
                note.time -= delta;
                if(note.time <= T){
                    if(!note.display){
                        if(delay >= 100){
                            note.time += delay-100;
                        }
//                        note.time+=delay;
//                        trace(delay)
                        note.display = true;
                        addChild(note);
                        note.draw();
                    }
                    
                    note.update(Math.PI-Math.PI*note.time/T, R);
                    if(note.time <= -200){
                        if(note.type != "g2"){
                            bad++;
                            addScore(-30);
                            resultView.judge("Bad", "");
                            resetCombo();
                        }
                        removeChild(note);
                        list.splice(i, 1);
                    }
                }
            }
        }
        
        //シミュレーターの更新
        public function update(delta:Number):void{
            if(CircularBeat.gameMode == 1){
//                if(key){
//                    startTime += delta;
//                    if(startTime >= 2750 && f){
//                        sc.driver.play(musicData.sionData);
//                        f = false;
//                    }
//                }
                
                updateNotes(notesR, delta);
                updateNotes(notesG, delta);
                updateNotes(notesB, delta);
                if(notesR.length == 0 && notesG.length == 0 && notesB.length == 0){
                    CircularBeat.gameMode = 2;
                    resultView.result(score, 100*totalNotes, perfect, great, good, bad);
                }
            }
        }
        
        //判定
        public function judge2(list:Vector.<Note>):void{
            var ok:Boolean = false;
            for(var i:int = 0; i < list.length; i++){
                if(Math.abs(list[i].time) <= 150){
                    if(!key){
                        if(list[i].type.charAt(0) == "r"){
                            sc.playData(list[i].t, list[i].note, list[i].n);
                        }
                        else if(list[i].type.charAt(0) == "b"){
                            sc.playData(list[i].t, list[i].note, list[i].n);
                        }
                        else if(list[i].type.charAt(0) == "g"){
                            sc.playData(list[i].t, list[i].note, list[i].n);
                        }
                    }
                    
                    if(Math.abs(list[i].time) <= 40){ 
                        perfect++;
                        glowCircle.glow2(list[i].type.charAt(0));
                        resultView.judge("Perfect", list[i].type.charAt(0));
                        addScore(100);
                        addCombo();
                    }
                    else if(list[i].time <= 80){
                        great++;
                        glowCircle.glow(list[i].type.charAt(0));
                        resultView.judge("Great", list[i].type.charAt(0));
                        addScore(50);
                        addCombo();
                    }
                    else{
                        good++;
                        resultView.judge("Good", list[i].type.charAt(0));
                        addScore(10);
                        addCombo();
                    }
                    list[i].remove();
                    if(list[i].type.charAt(0) == "g"){
                        list[i+1].remove();
                        list.splice(i, 2);
                    }
                    else list.splice(i, 1);
                    ok = true;
                    break;
                }
            }
            if(!ok){
                bad++;
                resultView.judge("Bad", "");
                addScore(-30);
                resetCombo();
                glowCircle.glow("d");
            }
        }
        
        public function judge(type:int):void{
//            trace("push", new Date().getTime())
            if(type == 0) judge2(notesR);
            else if(type == 1) judge2(notesB);
            else if(type == 2) judge2(notesG);
        }
    }



class Note extends Sprite
{
    public var f:Boolean = false;
    public var n:Number, type:String, time:int, t:int, note:int, v:int;
    public var data:SiONData;
    public var pos:Number;
    public var display:Boolean = false, num:int;
    public function Note(type:String, n:int):void{
        this.n = n;
        this.type = type;
        this.pos = 0;
    }
    
    public function draw():void{
        var c:uint;
        if(type == "b") c = 0xFF;
        else if(type == "r")c = 0xFF0000;
        else c = 0xFF00;
        this.filters = [new BlurFilter(2,2,1), new GlowFilter(c, 1, 4, 4, 2, 4)];
        graphics.lineStyle(3,0xFFFFFF);
        graphics.drawCircle(0,0,8);
        graphics.endFill();
        alpha = 0;
    }
    
    public function remove():void{
        var t:ITween = BetweenAS3.to(this, {alpha:0, scaleX:2, scaleY:2}, 0.1);
        t.onComplete = onComp;
        t.play();
    }
    
    private function onComp():void{
        parent.removeChild(this);
    }
    
    public function update(pos:Number, r:Number):void{
        this.pos = pos;
        x = Math.cos(pos-Math.PI/2)*r;
        y = Math.sin(pos-Math.PI/2)*r;
        if(time >= 1800 && time <= 2000) alpha = 1-(time-1800)/200;
        if(time < 0) alpha = (200 + time)/200;
        if(type == "r" || type == "g2") x *= -1;
    }
}




class ResultView extends Sprite
{
    private var title:String, score:int, rate:Number, clear:Boolean;
    private var titleLabel:Label, scoreLabel:Label, resultLabel:Label, perfectLabel:Label, greatLabel:Label, goodLabel:Label, badLabel:Label, scoreLabel2:Label, scoreRateLabel:Label, clearLabel:Label, comboLabel:Label, maxComboLabel:Label, highScoreLabel:Label;
    private var playingSp:Sprite=new Sprite(), resultSp:Sprite=new Sprite();
    private var bf:GlowFilter = new GlowFilter(0xFF, 1, 4, 4, 2, 2), gf:GlowFilter = new GlowFilter(0xFF00, 1, 4, 4, 2, 2), rf:GlowFilter = new GlowFilter(0xFF0000, 1, 4, 4, 2, 2);
    public function ResultView()
    {
        addChild(playingSp);
        addChild(resultSp);
        playingSp.visible = false;
        resultSp.visible = false;
        scoreLabel = createLabel(playingSp, "Score: 0", -65, 0);
        titleLabel = createLabel(playingSp, "Title: ", -100, -50);
        comboLabel = createLabel(playingSp, "Combo", -100, 50);
        comboLabel.visible = false;
        resultLabel = createLabel(resultSp, "Result", 0, -150);
        resultLabel.x = -resultLabel.width/2;
        perfectLabel = createLabel(resultSp, "Perfect: ", -100, -100);
        greatLabel = createLabel(resultSp, "Great: ", -100, -70);
        goodLabel = createLabel(resultSp, "Good: ", -100, -40);
        badLabel = createLabel(resultSp, "Bad: ", -100, -10);
        scoreLabel2 = createLabel(resultSp, "Score:", -100, 20);
        scoreRateLabel = createLabel(resultSp, "Score Rate:", -100, 50);
        clearLabel = createLabel(resultSp, "Stage Clear!!", -100, 100);
        clearLabel.textField.defaultTextFormat = new TextFormat(null, 30);
    }
    
    private function createLabel(sp:Sprite, str:String, x:int, y:int):Label{
        var label:Label = new Label(sp, x, y, str);
        label.textField.textColor = 0xFFFFFF;
        return label;
    }
    
    public function play(title:String):void{
        this.title = title;
        titleLabel.textField.text = "Title: "+title;
        titleLabel.x = -titleLabel.textField.width/2;
        fadeIn(playingSp);
    }
    
    public function result(score:int, maxScore:int, perfect:int, great:int, good:int, bad:int):void{
        this.score = score;
        perfectLabel.text = "Perfect: " + perfect.toString();
        greatLabel.text =   "Great: " + great.toString();
        goodLabel.text =    "Good: " + good.toString();
        badLabel.text =     "Bad: " + bad.toString();
        scoreLabel2.text = "Score: " + score.toString() + "/" + maxScore.toString();
        this.rate = score/maxScore;
        if(rate < 0.7) clear = false;
        else clear = true;
        if(rate < 0) rate = 0;
        scoreRateLabel.text = "Rate: " + (rate*100).toFixed(1) + "%";
        clearLabel.alpha = 0;
        clearLabel.x = -200;
        if(score/maxScore >= 0.7) clearLabel.text = "Stage Clear!!";
        else clearLabel.text = "Stage Failed...";
        var t:ITween = BetweenAS3.delay(BetweenAS3.to(clearLabel, {x:-clearLabel.width/2, alpha:1}, 0.5), 2.5);
        t.onComplete = resultComp;
        BetweenAS3.parallel(getTween(perfectLabel, 0.5), getTween(greatLabel, 0.7), getTween(goodLabel, 0.9), getTween(badLabel, 1.1), getTween(scoreLabel2, 1.3), getTween(scoreRateLabel, 1.5), t).play();
        
        if((rate*100) >= 70)
            SharedObjectController.saveMusicData(title, 1, score);
        else SharedObjectController.saveMusicData(title, 0, score);
        
        fadeOut(playingSp);
        fadeIn(resultSp);
    }
    
    private function resultComp():void{
        CircularBeat.gameMode = 3;
    }
    
    private function getTween(label:Label, delay:Number):ITween{
        label.alpha = 0;
        label.x = -200;
        return BetweenAS3.delay(BetweenAS3.to(label, {alpha:1, x:-100}, 0.5), delay);
    }
    
    public function updateScore(score:int):void{
        scoreLabel.text = "Score: "+score.toString();
    }
    
    public function updateCombo(combo:int):void{
        if(combo > 1){
            comboLabel.visible = true;
            comboLabel.text = combo.toString() + " Combo";
            comboLabel.x = -comboLabel.width/2;
        }
        else comboLabel.visible = false;
    }
    
    private function fadeIn(sp:Sprite):void{
        sp.alpha = 0;
        sp.visible = true;
        BetweenAS3.to(sp, {alpha:1}, 1).play();
    }
    
    private function fadeOut(sp:Sprite):void{
        var t:ITween = BetweenAS3.to(sp, {alpha:0}, 1);
        t.play();
    }
    
    public function fadeOutAll():void{
        fadeOut(playingSp);
        fadeOut(resultSp);
    }
    
    public function judge(string:String, color:String):void{
        var sp:Sprite = new Sprite();
        var tf:TextField = new TextField();
        if(color == "r") tf.filters = [rf];
        else if(color == "b") tf.filters = [bf];
        else if(color == "g") tf.filters = [gf];
        sp.addChild(tf);
        tf.autoSize = TextFieldAutoSize.LEFT;
        tf.defaultTextFormat = new TextFormat(null, 24);
        tf.textColor = 0xFFFFFF;
        tf.text = string;
        tf.x = -tf.textWidth/2;
        tf.y = -tf.textHeight/2;
        sp.alpha = 0;
        sp.scaleX = sp.scaleY = 0.5;
        addChild(sp);
        sp.y = 150;
        var t:ITween = BetweenAS3.to(sp, {alpha:0.8, scaleX:1, scaleY:1}, 0.2);
        t.onComplete = function(tf:TextField):void{removeChild(sp);};
        t.onCompleteParams = [tf];
        t.play();
    }
}


class SharedObjectController
{
    public static function getMusicData(name:String):Object{
        var shareObj:SharedObject = SharedObject.getLocal("CircularBeat");
        if(shareObj.data.musicData == undefined){
            shareObj.data.musicData = {};
            shareObj.data.musicData[name] = {clear:-1, score:0};
        }
        else if(shareObj.data.musicData[name] == undefined){
            shareObj.data.musicData[name] = {clear:-1, score:0};
        }
        return shareObj.data.musicData[name];
    }
    
    public static function saveMusicData(name:String, clear:int, score:int):Boolean{
        var shareObj:SharedObject = SharedObject.getLocal("CircularBeat");
        var res:Boolean = shareObj.data.musicData[name].score < score;
        shareObj.data.musicData[name].clear = Math.max(shareObj.data.musicData[name].clear, clear);
        shareObj.data.musicData[name].score = Math.max(shareObj.data.musicData[name].score, score);
        return res;
    }
}


class SoundController
{
    public var driver:SiONDriver;
    private var voices:SiONPresetVoice = new SiONPresetVoice(), voice:SiONVoice;
    private var data:SiONData;
    public function SoundController(driver:SiONDriver){
        this.driver = driver;
        voice = voices["valsound.piano8"];
    }
    
    public function play():void{
        if(!driver.isPlaying)driver.play();
    }
    
    public function playData(t:int, note:int, n:int, delay:Number=0):void{
        driver.bpm = t;
        var nn:Number = 16/n;
        driver.noteOn(note, voice, nn, delay, 0);
    }
}