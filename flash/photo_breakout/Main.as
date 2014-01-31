/*
Timeが0になるとゲームオーバーです。
コンボを続ければTimeが増えていきます。
Stageを進めていくとTimeの減りが激しくなる。
Lvを上げると貫通弾は狙いやすくなるが弾が速くなる。
ボールを落とすとTimeが減る＋Timeの減り方が激しくなる。
*/
package
{
    import com.bit101.components.*;
    import flash.display.*;
    import flash.events.*;
    import flash.geom.*;
    import org.libspark.betweenas3.*;
    import net.wonderfl.score.basic.*;
    import flash.text.*;
    import flash.system.*;
    
    
    [SWF(width=465, height=465, backgroundColor=0, frameRate=60)]
    public class Main extends Sprite
    {
        private var W:int = 465, H:int = 465;
        private var state:State, select:SelectDisplay, colSp:Sprite, game:Game;
        public function Main()
        {
            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.align = StageAlign.TOP_LEFT;
            graphics.beginFill(0x0);
            graphics.drawRect(0,0,W,H);
            graphics.endFill();
            
            Security.loadPolicyFile("http://farm1.static.flickr.com/crossdomain.xml");
            Security.loadPolicyFile("http://farm2.static.flickr.com/crossdomain.xml");
            Security.loadPolicyFile("http://farm3.static.flickr.com/crossdomain.xml");
            Security.loadPolicyFile("http://farm4.static.flickr.com/crossdomain.xml");
            Security.loadPolicyFile("http://farm5.static.flickr.com/crossdomain.xml");
            Security.loadPolicyFile("http://farm6.static.flickr.com/crossdomain.xml");
            Security.loadPolicyFile("http://farm7.static.flickr.com/crossdomain.xml");
            Security.loadPolicyFile("http://farm8.static.flickr.com/crossdomain.xml");
            state = new State(this, W-150);
            state.addEventListener("GameOver", onGameOver);
            select = new SelectDisplay(this);
            select.addEventListener("GameStart", onGameStart);
            select.loadImage();
        }
        
        private function onGameStart(e:Event):void{
            removeChild(select);
            var r:int = 6+select.stageN/2, c:int=5+Math.ceil(select.stageN/2);
            game = new Game(state, select.selectImg, r, c, select.stageN);
            addChild(game);
            game.addEventListener("GameEnd", onGameEnd);
        }
        
        private function onGameEnd(e:Event):void{
            game.removeEventListener("GameEnd", onGameEnd);
            select.show();
        }
        
        private function onGameOver(e:Event):void{
            BetweenAS3.to(game, {alpha:0.3}).play();
            Style.fontSize = 20;
            var label:Label = new Label(this, 0, 0, "Game Over");
            label.x = 315/2-label.width/2;
            label.y = 50;
            label.textField.textColor = 0xFFFFFF;
            game.gameOver();
            ranking();
        }
        
        private var _tfStatus:TextField;
        private var _form:BasicScoreForm;
        
        private function ranking():void
        {
            Style.fontSize=8;
            _form = new BasicScoreForm(this, (465-BasicScoreForm.WIDTH)/2, (465-BasicScoreForm.HEIGHT)/2, state.exp, 'SAVE SCORE', showRanking);
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
import flash.system.LoaderContext;
import com.adobe.images.*;
import com.bit101.components.*;

import flash.display.*;
import flash.events.*;
import flash.filters.*;
import flash.geom.*;
import flash.net.*;
import flash.text.*;
import flash.ui.Keyboard;
import flash.utils.*;

import jp.progression.commands.*;
import jp.progression.commands.lists.*;
import jp.progression.events.*;

import org.libspark.betweenas3.*;
import org.libspark.betweenas3.core.easing.*;
import org.libspark.betweenas3.easing.*;
import org.libspark.betweenas3.tweens.*;

class State extends Sprite{
    public var levelLabel:Label, timeLabel:Label, scoreLabel:Label, expLabel:Label, maxLabel:Label;
    public var level:int, nextLevel:Number, exp:Number, time:int=60, timer:Timer, max_combo:int, minus:int=1;
    
    public function State(sp:Sprite, x:int):void{
        this.x = x; level = 1; nextLevel = 100;     exp = 0; max_combo = 0;
        sp.addChild(this);
        var m:Matrix = new Matrix();
        m.createGradientBox(150,465, 0, 0, 0);
        graphics.beginGradientFill(GradientType.LINEAR, [0xFFFFFF, 0, 0, 0xFFFFFF], [1,1,1,1], [0,50,205,255], m);
        graphics.drawRect(0,0,150, 465);
        graphics.endFill();
        Style.fontSize = 18;
        levelLabel = new Label(this, 35, 40, "Lv.1");
        timeLabel = new Label(this, 35, 300, "Time:\n60");
        
        Style.fontSize = 13;
        expLabel = new Label(this, 35, 80, "Score:\n0");
        maxLabel = new Label(this, 35, 160, "Max Combo:\n0");
        
        timer = new Timer(1000);
        timer.addEventListener(TimerEvent.TIMER, onTimer);
    }
    
    private function onTimer(e:TimerEvent):void{
        time-=minus;
        if(time <= 0){
            timer.stop();
            dispatchEvent(new Event("GameOver"));
            time = 0;
        }
        timeLabel.text = "Time:\n" + time.toString();
    }
    
    public function addTime(value:int):void{
        time += value;
        timeLabel.text = "Time:\n" + time;
    }
    
    public function addExp(value:int):void{
        exp += value;
        expLabel.text = "Score:\n" + exp.toString();
    }
    
    public function levelUp():void{
        level++;
        nextLevel = nextLevel+(level-1)*100;
        levelLabel.text = "Lv." + level.toString();
        if(nextLevel<=exp) levelUp();
    }
    
    public function updateMax(value:int):void{
        if(value > max_combo){ 
            max_combo = value;
            maxLabel.text = "Max Combo:\n" + max_combo;
        }
    }
}

class Button extends Sprite{
    private var W:int, H:int;
    private var rapSp:Sprite;
    public function Button(sp:Sprite, x:int, y:int, width:int, height:int, text:String, handler:Function=null){
        this.x = x; this.y = y; this.W = width; this.H = height;
        sp.addChild(this);
        this.buttonMode = true;
        var m:Matrix = new Matrix;
        m.createGradientBox(width, height, Math.PI/2);
        graphics.beginGradientFill(GradientType.LINEAR, [0xff, 0x8b], [1,1], [0,255], m);
        graphics.drawRoundRect(0,0,width, height, 5, 5);
        graphics.endFill();
        
        var txt:TextField = new TextField();
        txt.background = false;
        txt.autoSize = TextFieldAutoSize.LEFT;
        txt.text = text;
        addChild(txt);
        txt.x = width/2-txt.width/2;
        txt.y = height/2-txt.height/2;
        txt.textColor = 0xa9a9a9;
        txt.mouseEnabled = false;
        
        rapSp = new Sprite();
        addChild(rapSp);
        
        addEventListener(MouseEvent.MOUSE_OVER, onMOver);
        addEventListener(MouseEvent.MOUSE_OUT, clear);
        addEventListener(MouseEvent.MOUSE_DOWN, onMDown);
        addEventListener(MouseEvent.MOUSE_UP, clear);
        if(handler!=null)addEventListener(MouseEvent.CLICK, handler);
    }
    
    private function onMOver(e:MouseEvent):void{
        rapSp.graphics.clear();
        rapSp.graphics.beginFill(0xFFFFFF, 0.2);
        rapSp.graphics.drawRoundRect(0,0,W, H, 5, 5);
        rapSp.graphics.endFill();
    }
    
    private function clear(e:MouseEvent):void{
        rapSp.graphics.clear();
    }
    
    private function onMDown(e:MouseEvent):void{
        rapSp.graphics.clear();
        rapSp.graphics.beginFill(0x0, 0.2);
        rapSp.graphics.drawRoundRect(0,0,W, H, 5, 5);
        rapSp.graphics.endFill();
    }
}

class SelectDisplay extends Sprite{
    private var stageTxt:Label, l1:Label, l2:Label, loadingL:Label;
    private var loader:ImageLoader;
    private var displayImages:Vector.<Image>;
    private var nextBtn:Button, prevBtn:Button, searchBtn:Button, searchTxt:Text;
    private var currentPage:int=0, maxPage:int=0;
    private var btn:Boolean = false, loading:Boolean = false;
    private const W:int=315, H:int=465;
    private var sp:Sprite;
    
    public var stageN:int, tag:String="kamakura", selectImg:Bitmap;
    
    public function SelectDisplay(sp:Sprite){
        this.sp = sp;
        sp.addChild(this);
        stageN = 1;
        Style.fontSize = 25;
        stageTxt = new Label(this, 0, 0, "Stage 1");
        stageTxt.x = W/2-stageTxt.width/2;
        stageTxt.y = 10;
        Style.fontSize = 20;
        l1 = new Label(this, 0, 0, "Select a Photo");
        l1.x = W/2-l1.width/2;
        l1.y = 45;
        l1.textField.textColor = stageTxt.textField.textColor = 0xFFFFFF;
        
        nextBtn = new Button(this, 245, 420, 45, 20, "next", nextPage);
        prevBtn = new Button(this, 185, 420, 45, 20, "back", prevPage);
        searchBtn = new Button(this, 100, 420, 50, 20, "search", search);
        Style.fontSize = 8;
        searchTxt = new Text(this, 10, 420, "kamakura");
        searchTxt.textField.height = 14;
        searchTxt.textField.multiline = false;
        searchTxt.addEventListener(KeyboardEvent.KEY_DOWN, function(e:KeyboardEvent):void{ 
            if(e.keyCode == Keyboard.ENTER)    search(); 
        });
        searchTxt.width = 80;
        searchTxt.height = 20;
    }
    
    private function search(e:MouseEvent=null):void{
        if(loading) return;
        loading = true;
        tag = searchTxt.text;
        var tweens:Array = [];
        for(var i:int = 0; i < displayImages.length; i++){
            tweens.push(BetweenAS3.to(displayImages[i], {scaleX:0, scaleY:0, alpha:0}));
        }
        var t:ITween = BetweenAS3.parallelTweens(tweens);
        t.onComplete = function():void{
            for(var i:int = 0; i < displayImages.length; i++){ 
                removeChild(displayImages[i]);
                displayImages[i] = null;
            }
            loadImage();
        };
        t.play();
    }
    
    //次のページへ
    private function nextPage(e:MouseEvent):void{
        if(!btn||currentPage+1>maxPage)return;
        btn=false;
        currentPage++;
        changeImage();
    }
    
    //前のページへ
    private function prevPage(e:MouseEvent):void{
        if(!btn||currentPage-1<0)return;
        btn=false;
        currentPage--;
        changeImage();
    }
    
    //画像の読み込み
    public function loadImage():void{
        btn = false;
        Style.fontSize = 18;
        loadingL = new Label(this, 0, 0, "Now Loading...");
        loadingL.x = W/2-loadingL.width/2;
        loadingL.y = H/2-loadingL.height/2;
        addEventListener(Event.ENTER_FRAME, onEnterFrame);
        loader = new ImageLoader();
        loader.addEventListener(Event.COMPLETE, onComplete);
        loader.load(tag);
    }
    
    //画像の読み込み完了
    private function onComplete(e:Event):void{
        Style.fontSize = 18;
        loadingL.text = "Complete!!";
        loadingL.alpha = 1;
        loadingL.textField.textColor = 0xFFFFFF;
        removeEventListener(Event.ENTER_FRAME, onEnterFrame);
        currentPage = 0;
        maxPage = (loader.imageList.length-1)/9;
        var t:ITween = BetweenAS3.to(loadingL, {alpha:0}, 1);
        t.onCompleteParams = [loadingL];
        t.onComplete = function(l:Label):void{
            removeChild(l);
            displayImages = getDispImg(currentPage);
            displayImage();
        };
        t.play();
    }
    
    //指定されたページに表示すべきSpriteの取得
    private function getDispImg(p:int):Vector.<Image>{
        var start:int = 9*p, end:int = Math.min(start+9, loader.imageList.length);
        var images:Vector.<Image> = new Vector.<Image>();
        for(var i:int = start; i < end; i++){
            var img:Image = loader.imageList[i];
            img.x = 50+100*((i-start)%3);
            img.y = 160+100*int((i-start)/3);
            images.push(img);
        }
        return images;
    }
    
    //displayImagesに入っているSpriteを表示
    private function displayImage():void{
        var command:SerialList = new SerialList(null);
        for(var i:int = 0; i < displayImages.length; i++){
            var sp:Image = displayImages[i];
            addChild(sp);
            sp.scaleX = sp.scaleY = 0;
            command.addCommand(new Func(tween, [sp, {scaleX:1, scaleY:1}]), new Wait(0.15));
        }
        command.addEventListener(ExecuteEvent.EXECUTE_COMPLETE, displayComp);
        command.execute();
    }
    
    //ページの入れ替えに伴う画像の入れ替え動作
    private function changeImage():void{
        var command:SerialList = new SerialList(null);
        for(var i:int = 0; i < displayImages.length; i++){
            command.addCommand(new Func(tween, [displayImages[i], {scaleX:0, scaleY:0}, true]), new Wait(0.15));
            displayImages[i].removeEvent();
        }
        displayImages = getDispImg(currentPage);
        var command2:SerialList = new SerialList(null, new Wait(0.5), new Func(displayImage));
        command2.execute();
        command.execute();
    }
    
    //表示完了
    private function displayComp(e:ExecuteEvent):void{
        loading = false;
        btn = true;
        e.target.removeEventListener(ExecuteEvent.EXECUTE_COMPLETE, displayComp);
        for(var i:int = 0; i < displayImages.length; i++){
            var img:Image = displayImages[i];
            img.handler = onClick;
            img.addEvent();
        }
    }
    
    private function tween(target:Sprite, obj:Object, del:Boolean=false):void{
        var t:ITween;
        if(del){
            t = BetweenAS3.to(target, obj, 0.5, Back.easeIn);
            t.onCompleteParams = [target];
            t.onComplete = function(sp:Sprite):void{removeChild(sp);}
        }
        else
            t = BetweenAS3.to(target, obj, 0.5, Back.easeOut);
        t.play();
    }
    
    private function hideImage():void{
        var tweens:Array = [];
        for(var i:int = 0; i < displayImages.length; i++){
            var t:ITween = BetweenAS3.to(displayImages[i], {scaleX:0, scaleY:0, alpha:0}, 0.5, Sine.easeOut);
            tweens.push(t);
        }
        t = BetweenAS3.parallelTweens(tweens);
        t.onComplete = function():void{
            for(var i:int = 0; i < displayImages.length; i++){
                displayImages[i].removeEvent();
                removeChild(displayImages[i]);
            }
        };
        t.play();
    }
    
    private function showImage():void{
        var tweens:Array = [];
        for(var i:int = 0; i < displayImages.length; i++){
            addChild(displayImages[i]);
            var t:ITween = BetweenAS3.to(displayImages[i], {scaleX:1, scaleY:1, alpha:1}, 0.5, Sine.easeOut);
            tweens.push(t);
        }
        t = BetweenAS3.parallelTweens(tweens);
        t.onComplete = function():void{
            for(var i:int = 0; i < displayImages.length; i++){
                displayImages[i].addEvent();
            }
        };
        t.play();
    }
    
    private function onClick(e:MouseEvent):void{
        mouseChildren = false;
        var sp:Sprite = this;
        var command:SerialList = new SerialList(null, new Func(hideImage), new Wait(0.5), new Func(function(img:Image):void{
            loadingL.alpha = 1;
            loadingL.text = "Now Loading...";
            addChild(loadingL);
            addEventListener(Event.ENTER_FRAME, onEnterFrame);
            
            var func:Function = function(e:Event):void{
                img.removeEventListener(Event.COMPLETE, func);
                selectImg = img.img;
                removeEventListener(Event.ENTER_FRAME, onEnterFrame);
                loadingL.alpha = 1;
                loadingL.text = "Complete!!";
                loadingL.alpha = 1;
                loadingL.textField.textColor = 0xFFFFFF;
                var t:ITween = BetweenAS3.to(sp, {alpha:0}, 1);
                t.onCompleteParams = [loadingL];
                t.onComplete = function(l:Label):void{
                    removeChild(l);
                    dispatchEvent(new Event("GameStart"));
                };
                t.play();
            };
            
            img.addEventListener(Event.COMPLETE, func);
            img.loadImage();
        }, [e.target]));
        command.execute();
    }
    
    public function show():void{
        stageN++;
        stageTxt.text = "Stage " + stageN.toString();
        sp.addChild(this);
        BetweenAS3.to(this, {alpha:1}).play();
        showImage();
        mouseChildren = true;
    }
    
    private function onEnterFrame(e:Event):void{
        if(loadingL.alpha==1)loadingL.alpha = 0.5;
        else loadingL.alpha = 1;
    }
}

class Game extends Sprite{
    private const W:int=315, H:int=465;
    private var blockList:Vector.<Block>, ball:Ball, bar:Bar;
    private var bmp:Bitmap;
    private var label:Label, comboLabel:Label;
    private var state:State;
    private var combo:int=0;
    private var stageN:int;
    private var bnum:int;
    public var particleList:Vector.<Particle>;
    
    public function Game(state:State, bmp:Bitmap, row:int, col:int, stageN:int){
        this.bmp = bmp;
        this.alpha = 0;
        this.state = state;
        this.stageN = stageN;
        bnum = row*col;
        particleList = new Vector.<Particle>();
        createBlocks(row, col);
        Style.fontSize = 20;
        label = new Label(this, 0, 0, "Click Start!");
        label.x = W/2-label.width/2;
        label.y = 300;
        comboLabel = new Label(this, 0, 0, "0 Combo!!");
        comboLabel.x = W/2-comboLabel.width/2;
        comboLabel.y = 300;
        comboLabel.alpha = 0;
        bar = new Bar();
        bar.set_red(state.level);
        bar.x = W/2;
        bar.y = 420;
        bar.toX = mouseX;
        addChild(bar);
        var t:ITween = BetweenAS3.to(this, {alpha:1});
        t.onComplete = showComplete;
        t.play();
    }
    
    private function createBlocks(r:int, c:int):void{
        blockList = new Vector.<Block>();
        var w:int = bmp.width/c, h:int = bmp.height/r, bw:int=315/c, bh:int=230/r;
        for(var i:int = 0; i < r; i++){
            for(var j:int = 0; j < c; j++){
                var bmpd:BitmapData = new BitmapData(w, h, false, 0);
                var rect:Rectangle = new Rectangle(j*w, i*h, w, h);
                bmpd.copyPixels(bmp.bitmapData, rect, new Point());
                var block:Block = new Block(bmpd, bw, bh);
                block.x = j*bw;
                block.y = i*bh;
                addChild(block);
                blockList.push(block);
            }
        }
    }
    
    private function showComplete():void{
        stage.addEventListener(MouseEvent.CLICK, startGame);
    }
    
    private function startGame(e:MouseEvent):void{
        stage.removeEventListener(MouseEvent.CLICK, startGame);
        removeChild(label);
        var speed:Number = 6+state.level/10;
        ball = new Ball(W/2, 380 , speed);
        addChild(ball);
        addEventListener(Event.ENTER_FRAME, onEnterFrame);
        state.timer.delay = 1000/(stageN/10+1);
        state.timer.start();
    }
    
    private function gameClear():void{
        state.timer.stop();
        Style.fontSize = 20;
        var label:Label = new Label(this, 0, 0, "Clear!!");
        label.textField.textColor = 0xFFFFFF;
        label.x = W/2-label.width/2;
        label.y = H/2-label.height/2;
        label.alpha = 0;
        var sp:Sprite = new Sprite();
        var over_w:int = Math.max(bmp.width-300, 0), over_h:int = Math.max(bmp.height-300, 0);
        var rscale:Number = 1;
        if(over_w > 0 || over_h > 0) rscale = Math.min(300/(300+over_w), 300/(300+over_h));
        sp.addChild(bmp);
        bmp.x = -bmp.width/2;
        bmp.y = -bmp.height/2;
        addChild(sp);
        sp.x = W/2;
        sp.y = H/2;
        sp.alpha = sp.scaleX = sp.scaleY = 0;
        var saveBtn:Button = new Button(this, 85, 400, 80, 20, "download", save), nextBtn:Button = new Button(this, 185, 400, 45, 20, "next", endGame);
        nextBtn.alpha = saveBtn.alpha = 0;
        
        var t1:ITween = BetweenAS3.parallel(BetweenAS3.to(label, {alpha:1}, 1), BetweenAS3.to(ball, {alpha:0}), BetweenAS3.to(bar, {alpha:0}));
        var t2:ITween = BetweenAS3.parallel(BetweenAS3.to(label, {y:50}), BetweenAS3.to(sp, {scaleX:rscale, scaleY:rscale, alpha:1}), BetweenAS3.to(saveBtn, {alpha:1}), BetweenAS3.to(nextBtn, {alpha:1}));
        var command:SerialList = new SerialList(null, new Func(t1.play), new Wait(1), new Func(t2.play), new Wait(1));
        
        command.onComplete = function():void{
            removeChild(ball);
            removeChild(bar);
        };
        command.execute();
    }
    
    private function save(e:MouseEvent):void{
        var ba:ByteArray=PNGEncoder.encode(bmp.bitmapData);
        var fr:FileReference = new FileReference();
        fr.addEventListener(Event.COMPLETE, saveComplete);
        fr.save(ba, "image.png");
    }
    
    private function saveComplete(e:Event):void{
        mouseChildren = true;
    }
    
    private function endGame(e:MouseEvent):void{
        mouseChildren = false;
        var t:ITween = BetweenAS3.to(this, {alpha:0});
        t.onComplete = destroy;
        t.play();
    }
    
    private function destroy():void{
        dispatchEvent(new Event("GameEnd"));
        parent.removeChild(this);
    }
    
    private function restart():void{
        state.timer.stop();
        state.addTime(int(-state.time/2));
        state.minus++;
        removeChild(ball);
        ball = null;
        comboLabel.alpha = 0;
        combo=0;
        addChild(label);
        showComplete();
    }
    
    public function gameOver():void{
        removeEventListener(Event.ENTER_FRAME, onEnterFrame);
    }
    
    private function onEnterFrame(e:Event):void{
        if(ball.y>H && blockList.length != 0){ 
            removeEventListener(Event.ENTER_FRAME, onEnterFrame);
            restart();
            return;
        }
        if(blockList.length == 0){
            state.timer.stop();
            if(particleList.length==0){
                removeEventListener(Event.ENTER_FRAME, onEnterFrame);
                gameClear();
            }
        }
        ball.update();
        bar.toX = mouseX;
        bar.update();
        
        if (bar.hitTestObject(ball))
        {
            if ((bar.y - bar.h / 2) <= (ball.y + ball.radius))
            {
                ball.vy*=-1;
                ball.y-=bar.h / 2 + ball.radius;
                var radian:Number=Math.atan2(ball.y - bar.y, ball.x - bar.x);
                
                var point:Point=new Point(ball.vx, ball.vy);
                ball.vx=Math.cos(radian) * point.length;
                ball.vy=Math.sin(radian) * point.length;
                
                if(bar.red_s+bar.x <= ball.x && ball.x <= bar.red_e+bar.x){
                    if(ball.mode == 0)
                        ball.changeMode(1);
                }
                else ball.changeMode(0);
            }
            if(ball.mode==0)combo=0;
        }
        
        if(combo < 2){
            comboLabel.alpha = 0;
        }
        else{
            comboLabel.alpha = 1;
            comboLabel.text = combo.toString() + " Combo!!";
        }
        
        var i:int = blockList.length;
        while(i--){
            var block:Block = blockList[i];
            if (block.hitTestObject(ball))
            {
                combo++;
                state.updateMax(combo);
                state.addExp(combo);
                if(state.nextLevel <= state.exp){ 
                    state.levelUp();
                    bar.set_red(state.level);
                }
                if(ball.mode==0){
                    if ((ball.y - ball.radius) <= block.y || (block.y+ block.h) <= (ball.y + ball.radius))
                    {
                        ball.vy*=-1;
                        ball.y+=ball.vy;
                    }
                    else if ((ball.x + ball.radius) >= block.x || (block.x + block.w) >= (ball.x - ball.radius))
                    {
                        ball.vx*=-1;
                        ball.x+=ball.vx;
                    }
                }
                blockList.splice(i,1);
                block.destroy();
                if(combo%3==0){
                    Style.fontSize = 10;
                    var label:Label = new Label(this, block.x, block.y, "time+"+(combo/3).toString());
                    label.textField.textColor = 0xFFFFFF;
                    var tween:ITween = BetweenAS3.to(label, {y:block.y-50, alpha:0});
                    tween.onComplete = function(l:Label):void{removeChild(l);};
                    tween.onCompleteParams = [label];
                    tween.play();
                    state.addTime(combo/3);
                }
            }
        }
        if(blockList.length <= bnum*0.075 && blockList.length < 10){
            i = blockList.length;
            while(i--){
                blockList[i].destroy();
                blockList.splice(i,1);
            }
        }
        i = particleList.length;
        while(i--){
            var p:Particle = particleList[i];
            p.update();
            if(p.alpha <= 0){
                particleList.splice(i,1);
                removeChild(p);
            }
        }
        
    }
}

class Bar extends Sprite{
    public const w:int=100, h:int=20;
    public var toX:int, red_s:int, red_e:int;
    public function Bar(){
        var matrix:Matrix=new Matrix();
        matrix.createGradientBox(w, h, 5);
        graphics.beginGradientFill("linear", [0x0000FF, 0x00FFFF], [1.0, 1.0], [0, 255], matrix);
        graphics.drawRect(-w / 2, -h / 2, w, h);
        graphics.endFill();
    }
    
    public function update():void
    {
        x+=(toX - x) / 8;
        if (x + w / 2 > 315)
            x=315 - w / 2;
        else if (x - w / 2 < 0)
            x=w / 2;
    }
    
    public function set_red(level:int):void{
        level += 10;
        var rw:int = level-1;
        red_s = -Math.floor(level/2); red_e = Math.ceil(level/2);
        var matrix:Matrix=new Matrix();
        matrix.createGradientBox(rw, h, 5);
        graphics.beginGradientFill("linear", [0xFF0000, 0xFFFF00], [1.0, 1.0], [0, 255], matrix);
        graphics.drawRect(red_s, -h / 2, rw, h);
        graphics.endFill();
    }
}

class Ball extends Sprite{
    public var radius:int, vx:Number, vy:Number,speed:Number, mode:int=0;
    private const W:int=315, H:int=465;
    public function Ball(x:int, y:int, speed:Number){
        this.x = x; this.y = y; radius=5; this.speed = speed;
        var r:Number = -(Math.random()*Math.PI*2/3+Math.PI/6);
        vx = Math.cos(r)*speed;
        vy = Math.sin(r)*speed;
        graphics.beginFill(0xFFFFFF);
        graphics.drawCircle(0,0,5);
        graphics.endFill();
        filters = [new GlowFilter(0xFF0000)];
    }
    
    public function changeMode(mode:int):void{
        this.mode = mode;
        var length:Number = Math.sqrt(vx*vx+vy*vy);
        var rate:Number;
        if(mode==1){
            filters = [new GlowFilter(0xFFFFFF, 1, 16, 16)];
            graphics.beginFill(0xFF0000);
            rate = speed*1.5/length;
        }
        else{
            filters = [new GlowFilter(0xFF0000)];
            graphics.beginFill(0xFFFFFF);
            rate = speed/length;
        }
        vx *= rate;
        vy *= rate;
        graphics.drawCircle(0,0,5);
        graphics.endFill();
    }
    
    public function update():void{
        x += vx;
        y += vy;
        if(x <= 0){
            x = 0;
            vx *= -1;
        }
        else if(x >= W){
            x = W;
            vx *= -1;
        }
        if(y <= 0){
            y = 0;
            vy *= -1;
        }
    }
}

class Block extends Sprite{
    public var w:int, h:int, bmpd:BitmapData;
    public function Block(bmpd:BitmapData, w:int, h:int){
        this.w = w; this.h = h; this.bmpd = bmpd;
        var bmp:Bitmap = new Bitmap(bmpd);
        bmp.width = w-1; bmp.height = h-1;
        addChild(bmp);
    }
    
    public function destroy():void{
        var dw:int = bmpd.rect.width/3, dh:int = bmpd.rect.height/3, pw:int = w/3, ph:int = h/3;
        for(var i:int = 0; i < 3; i++){
            for(var j:int = 0; j < 3; j++){
                var pbmpd:BitmapData = new BitmapData(dw, dh, false, 0);
                var rect:Rectangle = new Rectangle(j*dw, i*dh, dw, dh);
                pbmpd.copyPixels(bmpd, rect, new Point());
                var p:Particle = new Particle(x+pw*j, y+ph*i, Math.random()*8-4, -Math.random()*5, pw, ph, pbmpd);
                parent.addChild(p);
                (parent as Game).particleList.push(p);
            }
        }
        parent.removeChild(this);
    }
}

class Particle extends Sprite{
    public var w:int, h:int;
    private var vx:Number, vy:Number;
    public function Particle(x:int, y:int, vx:Number, vy:Number, w:int, h:int, bmpd:BitmapData):void{
        this.x = x; this.y = y; this.vx = vx; this.vy = vy; this.w = w; this.h = h;
        var bmp:Bitmap = new Bitmap(bmpd);
        bmp.width = w; bmp.height = h;
        addChild(bmp);
    }
    
    public function update():void{
        x += vx;
        y += vy;
        scaleX -= 0.01;
        scaleY -= 0.01;
        alpha -= 0.01;
        vy += 0.1;
    }
}

class Image extends Sprite{
    public var url:String, img:Bitmap, handler:Function, tween:ITween=null;
    public function Image(bmp:Bitmap, url:String){
        this.url = url; handler = null; img=null;
        addChild(bmp);
        bmp.width = 80;
        bmp.height = 80;
        bmp.x = -bmp.width/2;
        bmp.y = -bmp.height/2;
        filters = [new GlowFilter(0xFFFFFF, 1, 0, 0)];
        buttonMode = true;
    }
    
    public function addEvent():void{
        addEventListener(MouseEvent.MOUSE_OVER, onMOver);
        addEventListener(MouseEvent.MOUSE_OUT, onMOut);
        if(handler!=null)addEventListener(MouseEvent.CLICK, handler);
    }
    
    public function removeEvent():void{
        removeEventListener(MouseEvent.MOUSE_OVER, onMOver);
        removeEventListener(MouseEvent.MOUSE_OUT, onMOut);
        if(handler!=null)removeEventListener(MouseEvent.CLICK, handler);
    }
    
    private function onMOver(e:MouseEvent):void{
        if(tween != null) tween.stop();
        tween = BetweenAS3.to(this, {scaleX:1.2, scaleY:1.2, _glowFilter:{blurX:8, blurY:8}}, 0.2, Sine.easeOut);
        tween.play();
    }
    
    private function onMOut(e:MouseEvent):void{
        if(tween != null) tween.stop();
        tween = BetweenAS3.to(this, {scaleX:1, scaleY:1, _glowFilter:{blurX:0, blurY:0}}, 0.3, Sine.easeIn);
        tween.play();
    }
    
    public function loadImage():void{
        var loader:Loader = new Loader();
        loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);
        loader.load(new URLRequest(url));
    }
    
    private function onComplete(e:Event):void{
        img = e.target.content as Bitmap;
        dispatchEvent(new Event(Event.COMPLETE));
    }
}

class ImageLoader extends EventDispatcher{
    private var feed:String = "http://api.flickr.com/services/feeds/photos_public.gne?format=rss_200&tags=";
    private var media:Namespace = new Namespace("http://search.yahoo.com/mrss/");
    private var count:int = 0;
    private var $images:Array, $urls:Array;
    
    public var imageList:Vector.<Image> = new Vector.<Image>;
    
    public function ImageLoader(){}
    
    public function load(tag:String):void{
        var ldr:URLLoader = new URLLoader;
        ldr.addEventListener(Event.COMPLETE, function _load(e:Event):void {
            ldr.removeEventListener(Event.COMPLETE, _load);
            $images = XML(ldr.data)..media::thumbnail.@url.toXMLString().split('\n');
            $urls = XML(ldr.data)..media::content.@url.toXMLString().split('\n');
            imageLoad();
        });
        ldr.load(new URLRequest(feed+tag));
    }
    
    private function imageLoad():void{
        for(var i:int = 0; i < $images.length; i++){
            var loader:Loader = new Loader();
            loader.name = i.toString();
            loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);
            loader.load(new URLRequest($images[i]), new LoaderContext(true));
        }
    }
    
    private function onComplete(e:Event):void{
        imageList.push(new Image(e.target.content as Bitmap, $urls[int(e.target.loader.name)]));
        count++;
        if($images.length == count) dispatchEvent(new Event(Event.COMPLETE));
    }
}