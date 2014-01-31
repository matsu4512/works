/*
ゲーム説明
シューティングゲーム
３色の敵が出てきます
それぞれ同じ色の弾にしか当たりません。
さらに3色の壁も出現し同じ色の弾を跳ね返します。

アイテム
赤: 発射弾のパワーアップ
緑 HP回復
青: スコアup

操作
移動:↑→←↓
決定:Enter or Space
弾を撃つ: 
赤:z.
緑:x.
青:c

バグがあってたまに挙動がおかしくなります

*/
package
{
    import flash.display.*;
    import flash.events.*;
    import flash.text.*;
    import flash.ui.*;
    
    public class Main extends Sprite
    {
        private var game:Game;
        private var  status:Status;
        private var tf:TextField;
        
        private const GW:Number = 365, GH:Number = 465;
        
        public function Main()
        {
            var size:Number = Math.min(stage.stageWidth, stage.stageHeight)/465;
            scaleX = scaleY = size;
            stage.frameRate = 60;
            status = new Status(465-GW, 465);
            game = new Game(GW, 465, status);
            
            graphics.beginFill(0);
            graphics.drawRect(0,0,465,465);
            graphics.endFill();
            
            tf = new TextField();
            tf.autoSize = TextFieldAutoSize.LEFT;
            tf.defaultTextFormat = new TextFormat(null, 30);
            tf.text = "Click Start\n\n\nshot:z,x,c\nmove:←→↑↓\nOK:Enter, Space";
            tf.textColor = 0xFFFFFF;
            tf.x = 465/2-tf.width/2;
            tf.y = 465/2-tf.height/2;
            tf.mouseEnabled = false;
            addChild(tf);
            
            status.x = GW;
            stage.addEventListener(MouseEvent.CLICK, onClick);
        }
        
        private function onClick(e:MouseEvent):void{
            removeChild(tf);
            addChild(game);
            addChild(status);
            status.x = GW;
            
            var sp:Sprite = new Sprite();
            sp.graphics.beginFill(0);
            sp.graphics.drawRect(-100,0,100,465);
            sp.graphics.endFill();
            sp.graphics.lineStyle(2,0xFFFFFF);
            sp.graphics.moveTo(0,0);
            sp.graphics.lineTo(0,465);
            addChild(sp);
            
            graphics.clear();
            
            stage.removeEventListener(MouseEvent.CLICK, onClick);
            stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
            stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
        }
        
        private function onKeyUp(e:KeyboardEvent):void{
            if(e.keyCode == Keyboard.UP){
                KeyManager.up = false;
            }
            else if(e.keyCode == Keyboard.DOWN){
                KeyManager.down = false;
            }
            else if(e.keyCode == Keyboard.RIGHT){
                KeyManager.right = false;
            }
            else if(e.keyCode == Keyboard.LEFT){
                KeyManager.left = false;
            }
            else if(e.keyCode == Keyboard.Z){
                KeyManager.red = false;
            }
            else if(e.keyCode == Keyboard.X){
                KeyManager.greed = false;
            }
            else if(e.keyCode == Keyboard.C){
                KeyManager.blue = false;
            }
        }
        
        private function onKeyDown(e:KeyboardEvent):void{
            if(e.keyCode == Keyboard.UP){
                KeyManager.up = true;
            }
            else if(e.keyCode == Keyboard.DOWN){
                KeyManager.down = true;
            }
            else if(e.keyCode == Keyboard.RIGHT){
                KeyManager.right = true;
            }
            else if(e.keyCode == Keyboard.LEFT){
                KeyManager.left = true;
            }
            else if(e.keyCode == Keyboard.Z){
                KeyManager.red = true;
            }
            else if(e.keyCode == Keyboard.X){
                KeyManager.greed = true;
            }
            else if(e.keyCode == Keyboard.C){
                KeyManager.blue = true;
            }
        }
    }
}
import flash.display.*;
import flash.events.*;
import flash.filters.*;
import flash.geom.*;
import flash.net.*;
import flash.text.*;
import flash.ui.*;

import org.libspark.betweenas3.*;
import org.libspark.betweenas3.BetweenAS3;
import org.libspark.betweenas3.easing.Sine;
import org.libspark.betweenas3.tweens.ITween;

class DifSelect extends Sprite
{
    public var select:int;
    public var normal:TextField;
    public var hard:TextField;
    public var stg:Stage;
    
    public function DifSelect(stg:Stage, W:Number, H:Number)
    {
        super();
        this.stg = stg;
        select = 0;
        graphics.beginFill(0);
        graphics.drawRect(0,0,W,H);
        graphics.endFill();
        
        var title:TextField = Func.createTf(0,0,30, "Select Difficulty");
        title.y = 100;
        title.x = W/2-title.width/2;
        addChild(title);
        normal = Func.createTf(0,0,20,"NORMAL");
        normal.x = W/2-100-normal.width/2;
        normal.y = H/2;
        normal.border = true;
        normal.borderColor = 0xFFFFFF;
        addChild(normal);
        
        hard = Func.createTf(0,0,20,"HARD");
        hard.x = W/2+100-hard.width/2;
        hard.y = H/2;
        hard.borderColor = 0xFFFFFF;
        addChild(hard);
        visible = false;
        
    }
    
    public function onKeyDown(e:KeyboardEvent):void{
        if(e.keyCode == Keyboard.RIGHT){
            if(select == 0){
                normal.border = false;
                hard.border = true;
                select = 1;
            }
        }
        else if(e.keyCode == Keyboard.LEFT){
            if(select == 1){
                normal.border = true;
                hard.border = false;
                select = 0;
            }
        }
        else if(e.keyCode == Keyboard.ENTER || e.keyCode == Keyboard.SPACE){
            dispatchEvent(new Event(Event.SELECT));
        }
    }
    
    public function show():void{
        visible = true;
        stg.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
    }
    
    public function hide():void{
        visible = false;
        stg.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
    }
}



class Func
{
    //テキストフィールド
    public static function createTf(x:Number, y:Number, fontSize:int, text:String=""):TextField{
        var tf:TextField = new TextField();
        tf.defaultTextFormat = new TextFormat(null, fontSize);
        tf.autoSize = TextFieldAutoSize.LEFT;
        tf.textColor = 0xFFFFFF;
        tf.text = text;
        tf.x = x;
        tf.y = y;
        return tf;
    }
    
    //衝突判定
    public static function checkCollision(rect1:Rectangle, rect2:Rectangle):Boolean{
        return rect1.intersects(rect2);
    }
    
    //線分の交差判定
    public static function segmentIntersection(ax:Number, ay:Number, bx:Number, by:Number, cx:Number, cy:Number, dx:Number, dy:Number):Boolean{
        if(((ax - bx) * (cy - ay) + (ay - by) * (ax - cx)) * ((ax - bx) * (dy - ay) + (ay - by) * (ax - dx)) < 0 && 
            ((cx - dx) * (ay - cy) + (cy - dy) * (cx - ax)) * ((cx - dx) * (by - cy) + (cy - dy) * (cx - bx)) < 0) return true;
        return false;
    }
    
    //壁との衝突判定 trueならばvを更新
    public static function checkWallCollision(b:Bullet, wall:Wall):Boolean{
        if(segmentIntersection(wall.x1, wall.y1, wall.x2, wall.y2, b.x, b.y, b.x+b.vx, b.y+b.vy)){
            // 角度、サイン、コサインの取得
            var angle:Number = wall.theta;
            var cos:Number = Math.cos(angle);
            var sin:Number = Math.sin(angle);
            
            // 線を基準にしたボールの位置の取得
            var x1:Number = b.x - wall.x;
            var y1:Number = b.y - wall.y;
            
            // 座標の回転
            var y2:Number = cos * y1 - sin * x1;
            
            // 速度の回転
            var vy1:Number = cos * b.vy - sin * b.vx;
            
            // 座標の回転
            var x2:Number = cos * x1 + sin * y1;
            
            // 速度の回転
            var vx1:Number = cos * b.vx + sin * b.vy;
            
            vy1 *= -1;
            
            //すべてを回転させ元に戻す
            x1 = cos * x2 - sin * y2;
            y1 = cos * y2 + sin * x2;
            b.vx = cos * vx1 - sin * vy1;
            b.vy = cos * vy1 + sin * vx1;
            b.x = wall.x + x1;
            b.y = wall.y + y1;
            b.setSpeedByXY(b.vx, b.vy);
            return true;
        }
        return false;
    }
}



class Game extends Sprite
{
    public var W:Number, H:Number;
    public var status:Status;
    
    public var myShip:MyShip;
    public var bulletList:Vector.<Bullet>;
    public var enemyList:Vector.<BaseEnemy>;
    public var wallList:Vector.<Wall>;
    public var itemList:Vector.<Item>;
    public var particleList:Vector.<Particle>;
    
    public var test:Wall;
    public var test2:LineEnemyA;
    
    public var stageList:Vector.<BaseStage>;
    public var time:int;
    
    public var score:int;
    public var scoreItem:int;
    
    public var gameOverTf:TextField;
    public var highScoreTf:TextField;
    public var pushTf:TextField;
    
    public var highScore:int;
    
    public var selectSp:DifSelect;
    
    public function Game(W:Number, H:Number, status:Status)
    {
        super();
        
        this.W = W;
        this.H = H;
        this.status = status;
        
        enemyList = new Vector.<BaseEnemy>();
        bulletList = new Vector.<Bullet>();
        wallList = new Vector.<Wall>();
        itemList = new Vector.<Item>();
        stageList = new Vector.<BaseStage>();
        particleList = new Vector.<Particle>();
        time = 0;
        score = 0;
        scoreItem = 0;
        status.setLife(3);
        status.setPower(0);
        status.setScore(0);
        
        graphics.beginFill(0x0);
        graphics.drawRect(0,0,W,H);
        graphics.endFill();
        
        gameOverTf = Func.createTf(0,0,30,"Game Over");
        addChild(gameOverTf);
        gameOverTf.x = W/2-gameOverTf.width/2;
        gameOverTf.y = H/2-gameOverTf.height/2;
        gameOverTf.visible = false;
        
        highScoreTf = Func.createTf(0,0,30,"High Score!!");
        addChild(highScoreTf);
        highScoreTf.x = W/2-highScoreTf.width/2;
        highScoreTf.y = H/2-highScoreTf.height/2+75;
        highScoreTf.visible = false;
        
        pushTf = Func.createTf(0,0,20,"Restart: push enter");
        addChild(pushTf);
        pushTf.x = W/2-pushTf.width/2;
        pushTf.y = H/2-pushTf.height/2+100;
        pushTf.visible = false;
        
        var shObj:SharedObject = SharedObject.getLocal("ReflecShooting");
        if(shObj.data.highScore == undefined){
            shObj.data.highScore = 0;
        }
        shObj.close();
        status.setHighScore(shObj.data.highScore);
        highScore = shObj.data.highScore;
        
        if(stage == null) addEventListener(Event.ADDED_TO_STAGE, init);
        else init();
    }
    
    private function init(e:Event=null):void{
        removeEventListener(Event.ADDED_TO_STAGE, init);
        
        selectSp = new DifSelect(stage, W, H);
        addChild(selectSp);
        selectSp.show();
        
        selectSp.addEventListener(Event.SELECT, start);
    }
    
    public function start(e:Event=null):void{
        selectSp.hide();
        selectSp.removeEventListener(Event.SELECT, start);
        
        if(selectSp.select == 0)
            stageList.push(new Stage1(this, 0));
        else
            stageList.push(new Stage2(this, 0));
        myShip = new MyShip(this);
        myShip.x = W/2;
        myShip.y = H-50;
        addChild(myShip);
        addEventListener(Event.ENTER_FRAME, onEnterFrame);
    }
    
    private function restart():void{
        stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
        
        enemyList = new Vector.<BaseEnemy>();
        bulletList = new Vector.<Bullet>();
        wallList = new Vector.<Wall>();
        itemList = new Vector.<Item>();
        stageList = new Vector.<BaseStage>();
        particleList = new Vector.<Particle>();
        time = 0;
        score = 0;
        scoreItem = 0;
        status.setLife(3);
        status.setPower(0);
        status.setScore(0);
        status.setScorePlus(0);
        
        pushTf.visible = highScoreTf.visible = gameOverTf.visible = false;
        status.setHighScore(highScore);
        
        selectSp.show();
        selectSp.addEventListener(Event.SELECT, start);
    }
    
    private function reset(gameOver:Boolean = true):void{
        gameOverTf.visible = true;
        pushTf.visible = true;
        if(gameOver){
            gameOverTf.text = "Game Over";
        }
        else{
            gameOverTf.text = "Score:" + score*myShip.hp + "\n Bonus:x"+myShip.hp;
            score *= myShip.hp;
        }
        
        if(score > highScore){
            highScoreTf.visible = true;
            highScore = score;
            var shObj:SharedObject = SharedObject.getLocal("ReflecShooting");
            shObj.data.highScore = highScore;
            shObj.close();
        }
        
        
        for(var i:int = 0; i < enemyList.length; i++){
            enemyList[i].remove();
        }
        
        for(i = 0; i < itemList.length; i++){
            itemList[i].remove();
        }
        
        for(i = 0; i < bulletList.length; i++){
            bulletList[i].remove();
        }
        
        for(i = 0; i < wallList.length; i++){
            wallList[i].remove();
        }
        
        for(i = 0; i < particleList.length; i++){
            removeChild(particleList[i]);
        }
        
        for(i = 0; i < numChildren; ){
            var obj:Sprite = getChildAt(i) as Sprite;
            if(obj is MyShip || obj is BaseEnemy || obj is Item || obj is Wall || obj is Particle || obj is Bullet){
                removeChild(obj);
            }
            else i++;
        }
        
        stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
    }
    
    private function onKeyDown(e:KeyboardEvent):void{
        if(e.keyCode == Keyboard.ENTER || e.keyCode == Keyboard.SPACE){
            restart();
        }
    }
    
    private function onEnterFrame(e:Event):void{
        if(myShip.hp <= 0){
            removeEventListener(Event.ENTER_FRAME, onEnterFrame);
            reset();
            return;
        }
        myShip.update();
        enemyUpdate();
        wallUpdate();
        updateBullet();
        updateItem();
        updateParticle();
        stageUpdate();
    }
    
    private function stageUpdate():void{
        if(stageList[0].phase.length > 0){
            while(stageList[0].phase.length > 0 && (stageList[0].phase[0].time == time || stageList[0].phase[0].time == -1 && enemyList.length==0)){
                var phase:Phase = stageList[0].phase.shift();
                var Cls:Class = phase.cls;
                var param:Object = phase.param;
                new Cls(this, param);
                time = 0;
            }
        }
        else if(enemyList.length == 0 && itemList.length == 0 && wallList.length == 0 && bulletList.length == 0 && particleList.length == 0){
            removeEventListener(Event.ENTER_FRAME, onEnterFrame);
            removeChild(myShip);
            reset(false);
            return;
        }
        time++;
    }
    
    private function updateItem():void{
        var i:int = itemList.length;
        while(i--){
            var it:Item = itemList[i];
            it.update();
            if(Func.checkCollision(myShip.rect, it.rect)){
                if(it.type == Item.LIFE){
                    myShip.hp+=it.value;
                    status.setLife(myShip.hp);
                }
                else if(it.type == Item.POWER){
                    myShip.power += it.value;
                    status.setPower(myShip.power);
                }
                else{
                    scoreItem+=it.value;
                    status.setScorePlus(scoreItem);
                }
                it.effect();
                itemList.splice(i,1);
            }
            else if(it.y < -50 || it.y > H+50){
                removeChild(it);
                itemList.splice(i,1);
            }
        }
    }
    
    private function wallUpdate():void{
        var i:int = wallList.length;
        while(i--){
            var w:Wall = wallList[i];
            w.update();
            if(w.dead) wallList.splice(i,1);
        }
    }
    
    private function enemyUpdate():void{
        var i:int = enemyList.length;
        while(i--){
            var e:BaseEnemy = enemyList[i];
            e.update();
            var j:int = bulletList.length;
            if(e.dead){
                enemyList.splice(i,1);
            }
        }
    }
    
    private function updateParticle():void{
        var i:int = particleList.length;
        while(i--){
            var p:Particle = particleList[i];
            p.update();
            if(p.x < -10 || p.x > W+10 || p.y > H+10){
                particleList.splice(i, 1);
                removeChild(p);
            }
        }
    }
    
    private function updateBullet():void{
        var i:int = bulletList.length;
        while(i--){
            var b:Bullet = bulletList[i];
            b.update();
            //はみ出ていないか
            if(b.x < -10 || W+10 < b.x){
                b.dead = true;
                bulletList.splice(i,1);
                b.remove();
                continue;
            }
            else if(b.y < -10 || H+10 < b.y){
                b.dead = true;
                bulletList.splice(i,1);
                b.remove();
                continue;
            }
            
            //壁との判定
            var j:int = wallList.length;
            while(j--){
                var w:Wall = wallList[j];
                if((b.color == w.color) && Func.checkWallCollision(b, w)) w.talpha = 1.5;
            }
            
            //自機との判定
            if(!b.isTargetEmeny && !myShip.dead && myShip.muteki == 0){
                if(Func.checkCollision(b.rect, myShip.rect)){
                    myShip.damage();
                    myShip.power -= 10;
                    if(myShip.power < 0) myShip.power = 0;
                    scoreItem/=2;
                    status.setPower(myShip.power);
                    status.setScorePlus(scoreItem);
                    status.setLife(myShip.hp);
                    b.dead = true;
                    bulletList.splice(i,1);
                    b.remove();
                }
            }
            //敵機との判定
            if(!b.dead && b.isTargetEmeny){
                j = enemyList.length;
                while(j--){
                    var e:BaseEnemy = enemyList[j];
                    if(!e.dead && (e.color == b.color || b.color == 0 || e.color == 0) && Func.checkCollision(b.rect, e.rect)){
                        b.dead = true;
                        bulletList.splice(i,1);
                        b.remove();
                        e.damage();
                        if(e.dead){
                            var a:int;
                            if(selectSp.select == 0) a = 1;
                            else a = 10;
                            score += e.score*(1+scoreItem/10)*a;
                            status.setScore(score);
                        }
                        break;
                    }
                }
            }
        }
    }
}

class KeyManager
{
    public static var up:Boolean=false;
    public static var down:Boolean=false;
    public static var left:Boolean=false;
    public static var right:Boolean=false;
    public static var red:Boolean=false;
    public static var greed:Boolean=false;
    public static var blue:Boolean=false;
}




class MyShip extends Sprite
{
    //コンディション
    public var hp:int;
    public var speed:Number;
    //        public var color:int;
    public var shotCnt:int;
    public var dead:Boolean;
    public var power:int;
    public var muteki:int;
    
    public var subInterval:int;
    public var subCnt:int;
    
    public var white:Boolean;
    //衝突
    public var rect:Rectangle;
    
    //外部参照
    public var main:Game;
    public var bulletList:Vector.<Bullet>;
    
    public var W:Number, H:Number;
    
    public function MyShip(main:Game)
    {
        hp = 3;
        speed = 3;
        shotCnt = 0;
        power = 0;
        this.main = main;
        this.bulletList = main.bulletList;
        this.dead = false;
        
        subInterval = 0;
        subCnt = 0;
        white = false;
        W = main.W;
        H = main.H;
        muteki = 0;
        draw();
        
        rect = new Rectangle(x-width/4, y-height/4, width/2, height/2);
    }
    
    public function draw():void{
        graphics.clear();
        graphics.lineStyle(2, 0xFFFFFF);
        graphics.moveTo(0,-10);
        graphics.lineTo(10,0);
        graphics.lineTo(0,10);
        graphics.lineTo(-10,0);
        graphics.lineTo(0,-10);
        filters = [new GlowFilter(0xFFFF00, 1.0, 4, 4, 2, 2)];
    }
    
    public function shot(color:int):void{
        //            if(white) color = 0;
        shotCnt = 0;
        var b:Bullet = new Bullet(main, true, color);
        b.setPosition(x, y-10);
        b.setSpeedByXY(0, -5);
        bulletList.push(b);
        main.addChild(b);
        
        if(subInterval > 0){
            subCnt++;
            if(subInterval <= subCnt){
                var f:Boolean = false;
                for(var i:int = 0; i < main.enemyList.length; i++){
                    if(!main.enemyList[i].dead && main.enemyList[i].color == color){
                        b = new TrackingBullet(main, true, color, main.enemyList[i]);
                        f = true;
                    }
                }
                if(!f)    b = new TrackingBullet(main, true, color);
                subCnt = 0;
                b.setPosition(x, y-10);
                b.setSpeedByTheta(5, -Math.PI/2+Math.PI/10);
                bulletList.push(b);
                main.addChild(b);
                
                f = false;
                for(i = main.enemyList.length-1; i >= 0; i--){
                    if(!main.enemyList[i].dead && main.enemyList[i].color == color){
                        b = new TrackingBullet(main, true, color, main.enemyList[i]);
                        f = true;
                    }
                }
                if(!f)    b = new TrackingBullet(main, true, color);
                b.setPosition(x, y-10);
                b.setSpeedByTheta(5, -Math.PI/2-Math.PI/10);
                bulletList.push(b);
                main.addChild(b);
            }
        }
    }
    
    public function damage():void{
        hp--;
        muteki = 60;
        if(hp <= 0){
            dead = true;
            remove();
        }
    }
    
    public function move():void{
        if(KeyManager.up) y -= speed;
        if(KeyManager.down) y += speed;
        if(KeyManager.left) x -= speed;
        if(KeyManager.right) x += speed;
        if(x+width/2 > W) x = W-width/2;
        else if(x < width/2) x = width/2;
        if(y+height/2 > H) y = H-height/2;
        else if(y < height/2) y = height/2;
        rect.x = x-width/4;
        rect.y = y-height/4;
    }
    
    public function remove():void{
        parent.removeChild(this);
    }
    
    public function update():void{
        if(dead) return;
        move();
        
        if(muteki > 0){
            if(int(muteki/10)%2==0) visible = false;
            else visible = true;
            muteki--;
        }else visible = true;
        if(shotCnt > 6){
            if(KeyManager.red) shot(1);
            else if(KeyManager.greed) shot(2);
            else if(KeyManager.blue) shot(3);
        }
        shotCnt++;
        
        if(power >= 50){
            subInterval = 2;
            white = false;
        }
        else if(power >= 40){
            subInterval = 4;
            white = false;
        }
        else if(power >= 30){
            subInterval = 6;
            white = false;
        }
        else if(power >= 20){
            subInterval = 8;
            white = false;
        }
        else if(power >= 10){
            subInterval = 10;
            white = false;
        }
        else if(power >= 1){
            subInterval = 20;
            white = false;
        }
        else subInterval = 0;
    }
}


class Particle extends Sprite
{
    public var vx:Number;
    public var vy:Number;
    public var n:int;
    
    public function Particle(x:Number, y:Number, vx:Number, vy:Number, color:uint, r:Number=3)
    {
        this.x=x;
        this.y=y;
        this.vx=vx;
        this.vy=vy;
        n = 0;
        graphics.beginFill(0xFFFFFF);
        graphics.moveTo(0, -r);
        graphics.lineTo(r,0);
        graphics.lineTo(0,r);
        graphics.lineTo(-r,0);
        graphics.endFill();
        filters = [new GlowFilter(color, 1, 8, 8, 3, 4)];
    }
    
    public function update():void
    {
        x+=vx;
        y+=vy;
        vy+=0.4;
        n++;
        if(n%8) alpha = 0.3;
        else alpha=1;;
    }
}


class Status extends Sprite
{
    private var W:Number, H:Number;
    public var highScoreTf:TextField;
    public var scoreTf:TextField;
    public var scorePlusTf:TextField;
    public var lifeTf:TextField;
    public var powerTf:TextField;
    
    public function Status(W:Number, H:Number)
    {
        super();
        
        this.W = W;
        this.H = H;
        
        highScoreTf = Func.createTf(10, 15, 15, "High Score:\n");
        scoreTf = Func.createTf(10, 70, 20, "Score:\n100000");
        scorePlusTf = Func.createTf(10, 120, 20, "x1.0");
        lifeTf = Func.createTf(10, 180, 20, "Life:\n3");
        powerTf = Func.createTf(10, 240, 20, "Power:\n0");
        addChild(highScoreTf);
        addChild(scoreTf);
        addChild(scorePlusTf);
        addChild(lifeTf);
        addChild(powerTf);
        if(stage == null) addEventListener(Event.ADDED_TO_STAGE, init);
        else init();
    }
    
    private function init(e:Event=null):void{
        graphics.lineStyle(3, 0xFFFFFF);
        graphics.beginFill(0x0);
        graphics.drawRect(0,0,W,H);
        graphics.endFill();
    }
    
    public function setHighScore(n:int):void{
        highScoreTf.text = "High Score:\n" + n.toString();
    }
    
    public function setScore(n:int):void{
        scoreTf.text = "Score:\n"+n.toString();
    }
    
    public function setPower(n:int):void{
        powerTf.text = "Power:\n"+n.toString();
    }
    
    public function setLife(n:int):void{
        lifeTf.text = "Life:\n"+n.toString();
    }
    
    public function setScorePlus(n:int):void{
        scorePlusTf.text = "x"+Number(1+n/10).toString();
    }
}


class Bullet extends Sprite
{
    //コンディション
    public var speed:Number;
    public var theta:Number;
    public var vx:Number;
    public var vy:Number;
    public var color:int;
    public var dead:Boolean;
    
    //自機が放った弾かどうか
    public var isTargetEmeny:Boolean;
    
    //衝突
    public var rect:Rectangle;
    
    //外部参照
    public var main:Game;
    
    public var W:Number, H:Number;
    
    public function Bullet(main:Game, isTargetEnemy:Boolean=true, color:int=0)
    {
        W = main.W;
        H = main.H;
        
        this.isTargetEmeny = isTargetEnemy;
        this.main = main;
        this.color = color;
        speed = vx = vy = theta = 0;
        dead = false;
        
        draw();
        rect = new Rectangle(x-width/2, y-height/2, width, height);
    }
    
    public function setSpeedByTheta(speed:Number, theta:Number):void{
        this.speed = speed;
        this.theta = theta;
        rotation = theta/Math.PI*180+90;
        vx = speed*Math.cos(theta);
        vy = speed*Math.sin(theta);
    }
    
    public function setSpeedByXY(vx:Number, vy:Number):void{
        this.vx = vx;
        this.vy = vy;
        speed = Math.sqrt(vx*vx+vy*vy);
        theta = Math.atan2(vy, vx);
        rotation = theta/Math.PI*180+90;
    }
    
    public function setPosition(x:Number, y:Number):void{
        this.x = x;
        this.y = y;
        rect.x = x-width/2;
        rect.y = y-height/2
    }
    
    public function setColor(color:int):void{
        this.color = color;
        draw();
    }
    
    public function draw():void{
        if(isTargetEmeny){
            graphics.clear();
            graphics.beginFill(0xFFFFFF);
            graphics.moveTo(-1, -7);
            graphics.lineTo(1,-7);
            graphics.lineTo(1,7);
            graphics.lineTo(-1,7);
            graphics.lineTo(-1,-7);
        }
        else{
            graphics.clear();
            graphics.beginFill(0xFFFFFF);
            graphics.moveTo(0, -6);
            graphics.lineTo(3,6);
            graphics.lineTo(-3,6);
            graphics.lineTo(0,-6);
        }
        var c:uint;
        if(color == 0) c = 0xFFFFFF;
        else if(color == 1) c = 0xFF0000;
        else if(color == 2) c = 0xFF00;
        else c = 0xFF;
        filters = [new GlowFilter(c, 1.0, 4, 4, 2, 1)];
    }
    
    public function move():void{
        x += vx;
        y += vy;
        rect.x = x-width/2;
        rect.y = y-height/2;
    }
    
    public function update():void{
        //            if(dead) remove();
        move();
    }
    
    public function remove():void{
        parent.removeChild(this);
        if(0 < x && x < W && 0 < y && y < H){
            var c:uint;
            if(color == 0) color = 0xFFFFFF;
            else if(color == 1) c = 0xFF0000;
            else if(color == 2) c = 0xFF00;
            else if(color == 3) c = 0xFF;
            for(var i:int = 0; i < 2; i++){
                var p:Particle = new Particle(x, y, Math.random()*10-5, Math.random()*10-5, c);
                main.particleList.push(p);
                main.addChild(p);
            }
        }
    }
}


class BallBullet extends Bullet
{
    public var radius:Number;
    
    public function BallBullet(main:Game, isTargetEnemy:Boolean, color:int, radius:Number)
    {
        this.radius = radius;
        super(main, isTargetEnemy, color);
        rect = new Rectangle(x-width/2, y-height/2, width, height);
    }
    
    override public function draw():void{
        graphics.clear();
        graphics.beginFill(0xFFFFFF);
        graphics.drawCircle(0,0,radius);
        
        var c:uint;
        if(color == 0) c = 0xFFFFFF;
        else if(color == 1) c = 0xFF0000;
        else if(color == 2) c = 0xFF00;
        else c = 0xFF;
        filters = [new GlowFilter(c, 1.0, 8, 8, 2, 1)];
    }
}



class GravityBullet extends Bullet
{
    public var gravity:Number;
    public function GravityBullet(main:Game, isTargetEnemy:Boolean, color:int, gravity:Number)
    {
        super(main, isTargetEnemy, color);
        this.gravity = gravity;
    }
    
    override public function move():void{
        x += vx;
        y += vy;
        vy += gravity;
        var theta:Number = Math.atan2(vy, vx);
        rotation = theta/Math.PI*180+90;
        rect.x = x-width/2;
        rect.y = y-height/2;
    }
}



class TrackingBullet extends Bullet
{
    public var target:BaseEnemy;
    public function TrackingBullet(main:Game, isTargetEnemy:Boolean, color:int, target:BaseEnemy=null)
    {
        super(main, isTargetEnemy, color);
        this.target = target;
    }
    
    override public function draw():void{
        super.draw();
        var sp:Sprite = new Sprite();
        sp.graphics.beginFill(0xFFFFFF);
        sp.graphics.drawCircle(0,0,2);
        sp.graphics.endFill();
        var c:uint;
        if(color == 0) c = 0xFFFFFF;
        else if(color == 1) c = 0xFF0000;
        else if(color == 2) c = 0xFF00;
        else c = 0xFF;
        sp.filters = [new GlowFilter(c, 1.0, 4, 4, 2, 1)];
        addChild(sp);
        sp.y = 7;
    }
    
    override public function remove():void{
        super.remove();
        //            if(0 < x && x < W && 0 < y && y < H){
        //                var c:uint;
        //                if(color == 0) color = 0xFFFFFF;
        //                else if(color == 1) c = 0xFF0000;
        //                else if(color == 2) c = 0xFF00;
        //                else if(color == 3) c = 0xFF;
        //                var sp:Sprite = new Sprite();
        //                sp.graphics.lineStyle(1,0xFFFFFF);
        //                sp.graphics.drawCircle(0,0,3);
        //                sp.graphics.endFill();
        //                sp.filters = [new GlowFilter(c,1.0,4,4)];
        //                var t:ITween = BetweenAS3.to(sp, {scaleX:3, scaleY:3, alpha:0}, 0.3);
        //                main.addChild(sp);
        //                sp.x = x+vx*2;
        //                sp.y = y+vy*2;
        //                t.onComplete = onComp;
        //                t.onCompleteParams = [sp];
        //                t.play();
        //            }
    }
    
    private function onComp(sp:Sprite):void{
        main.removeChild(sp);
    }
    
    override public function move():void{
        if(target == null || target.dead) super.move();
        else {
            var dx:Number = target.x-x, dy:Number = target.y-y;
            var t:Number = Math.atan2(dy, dx);
            var dt:Number = t-theta;
            var tt:Number = dt*0.1;
            if(tt > 0.1) tt = 0.1;
            else if(tt < -0.1) tt = -0.1;
            setSpeedByTheta(speed, theta+tt);
            if(theta > Math.PI) theta -= 2*Math.PI;
            else if(theta < -Math.PI) theta += 2*Math.PI;
            x += vx;
            y += vy;
        }
        rect.x = x-width/2;
        rect.y = y-height/2;
    }
}



class BaseEnemy extends Sprite
{
    public var hp:int;
    public var color:int;
    public var size:Number;
    public var rect:Rectangle;
    public var interval:int;
    public var shotCnt:int;
    public var shot_speed:Number;
    public var shot_angle:Number;
    public var dead:Boolean;
    public var itemValue:int;
    public var itemType:int;
    public var score:int;
    
    public var main:Game;
    public var bulletList:Vector.<Bullet>;
    
    public var W:Number, H:Number;
    
    public function BaseEnemy(main:Game, param:Object)
    {
        super();
        this.main = main;
        W = main.W;
        H = main.H;
        this.size = param.size;
        this.hp = param.hp;
        this.color = param.color;
        this.interval = param.interval;
        this.shot_angle = param.shot_angle;
        this.shot_speed = param.shot_speed;
        this.x = param.x;
        this.y = param.y;
        this.itemValue = param.itemValue;
        this.itemType = param.itemType;
        this.score = param.score;
        
        this.bulletList = main.bulletList;
        this.dead = false;
        
        main.enemyList.push(this);
        main.addChild(this);
        shotCnt = 0;
        draw();
        
        rect = new Rectangle(x-(width+4)/2, y-(height+4)/2, width+4, height+4);
    }
    
    public function draw():void{
    }
    
    public function effect():void{
        var t:ITween = BetweenAS3.to(this, {scaleX:3, scaleY:3, alpha:0}, 0.2);
        t.onComplete = remove;
        t.play();
    }
    
    public function remove():void{
        parent.removeChild(this);
        item();
    }
    
    public function setPosition(x:Number, y:Number):void{
        this.x = x;
        this.y = y;
        rect.x = x-(width+4)/2;
        rect.y = y-(height+4)/2;
    }
    
    public function setInterval(interval:Number):void{
        this.interval = interval;
    }
    
    public function setShot(speed:Number, angle:Number):void{
        this.shot_speed = speed;
        this.shot_angle = angle;
    }
    
    public function shot(color:int):void{
        //            var bullet:Bullet = new Bullet(main, true, color);
        //            bullet.setPosition(x, y-10);
        //            bullet.setSpeedByXY(0, -5);
        //            bulletList.push(bullet);
        //            main.addChild(bullet);
    }
    
    public function damage():void{
        hp--;
        if(hp <= 0){
            dead = true;
            effect();
        }
    }
    
    public function move():void{
        rect.x = x-width/2;
        rect.y = y-height/2
    }
    
    public function update():void{
        move();
        shotCnt++;
        if(interval <= shotCnt){
            shotCnt = 0;
            if(y < H-H/3)shot(color);
        }
    }
    
    public function item():void{
        if(itemValue > 0)
            new Item(main, {x:x, y:y, type:itemType, size:width/4, vy:Math.random()*2+1, value:itemValue});
    }
}

import flash.display.Sprite;
import flash.filters.GlowFilter;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;

import org.libspark.betweenas3.BetweenAS3;
import org.libspark.betweenas3.tweens.ITween;

class BaseBoss extends BaseEnemy
{
    public var maxHp:int;
    public var hpSp:Sprite;
    public var tf:TextField;
    
    public function BaseBoss(main:Game, param:Object)
    {
        super(main, param);
        maxHp = param.hp;
        
        tf = new TextField();
        tf.autoSize = TextFieldAutoSize.LEFT;
        tf.defaultTextFormat = new TextFormat(null, 15);
        tf.textColor = 0xFFFFFF;
        tf.text = "BOSS:";
        main.addChild(tf);
        tf.x = 150;
        tf.y = 5;
        
        hpSp = new Sprite();
        hpSp.graphics.beginFill(0xFF0000);
        hpSp.graphics.drawRect(0,0,150,10);
        hpSp.graphics.endFill();
        main.addChild(hpSp);
        hpSp.x = 200;
        hpSp.y = 10;
        main.addChild(hpSp);
        
        tf.alpha = hpSp.alpha = 0;
        
        tfSpFadeIn();
    }
    
    public function tfSpFadeIn():void{
        var t1:ITween = BetweenAS3.to(tf, {alpha:1}, 0.5);
        var t2:ITween = BetweenAS3.to(hpSp, {alpha:1}, 0.5);
        BetweenAS3.parallel(t1, t2).play()
    }
    
    override public function effect():void{
        super.effect();
        var t:ITween = BetweenAS3.to(tf, {alpha:0}, 0.2);
        t.play();
    }
    
    override public function remove():void{
        main.removeChild(tf);
        main.removeChild(hpSp);
        super.remove();
    }
    
    public function changeColor(color:int):void{
        var t:ITween = BetweenAS3.to(this, {scaleX:1.5, scaleY:1.5, alpha:0.5}, 0.3);
        t.onComplete = changeComp;
        t.onCompleteParams = [color];
        t.play();
    }
    
    public function changeComp(color:int):void{
        this.color = color;
        var c:uint;
        if(color == 1) c = 0xFF0000;
        else if(color == 2) c = 0xFF00;
        else c = 0xFF;
        filters = [new GlowFilter(c, 1, 4, 4, 2)];
        var t:ITween = BetweenAS3.to(this, {scaleX:1.0, scaleY:1.0, alpha:1.0}, 0.3);
        t.play();
    }
    
    override public function update():void{
        super.update();
        hpSp.scaleX += (hp/maxHp-hpSp.scaleX)/8;
    }
}


class LineBoss extends BaseBoss
{
    public var tween:ITween;
    public function LineBoss(main:Game, param:Object)
    {
        super(main, param);
        setMoveTrajectory(param.fromX, param.fromY, param.toX, param.toY, param.time);
        start();
    }
    
    override public function effect():void{
        tween.stop();
        super.effect();
    }
    
    //(fromX, fromY)から(toX, toY)へtimeミリ秒かけて移動する
    public function setMoveTrajectory(fromX:Number, fromY:Number, toX:Number, toY:Number, time:Number):void{
        setPosition(fromX, fromY);
        tween = BetweenAS3.to(this, {x:toX, y:toY}, time);
        tween.onComplete = onComp;
    }
    
    public function onComp():void{
        if(x < -width || W+width < x || y < -height || H+height < y) dead = true;
    }
    
    //移動開始
    public function start():void{
        tween.play();
    }
    
    override public function update():void{
        super.update();
    }
}


class Boss01 extends LineBoss
{
    public var n:int;
    public var angle_range:Number;
    public var angle_speed:Number;
    public var colorInterval:int;
    
    public function Boss01(main:Game, param:Object)
    {
        super(main, param);
        this.n = param.n;
        this.angle_range = param.angle_range;
        this.angle_speed = param.angle_speed;
        this.color = 1;
        colorInterval = 0;
        n++;
        draw();
    }
    
    override public function draw():void{
        graphics.clear();
        graphics.lineStyle(2, 0xFFFFFF);
        graphics.drawCircle(0,0,size);
        var c:uint;
        if(color == 0) c = 0xFFFFFF;
        else if(color == 1) c = 0xFF0000;
        else if(color == 2) c = 0xFF00;
        else c = 0xFF;
        filters = [new GlowFilter(c, 1.0, 4, 4, 2, 1)];
    }
    
    override public function shot(color:int):void{
        shot_angle += angle_speed;
        var N:int = n;
        
        if(hp/maxHp < 0.5) N *= 1.5;
        
        for(var i:int = 0; i < N-1; i++){
            var b:Bullet = new Bullet(main, false, i%3+1);
            b.setPosition(x, y);
            var angle:Number = shot_angle+angle_range*(i/(N-1)-0.5);
            b.setSpeedByTheta(shot_speed, angle);
            bulletList.push(b);
            main.addChild(b);
        }
    }
    
    override public function update():void{
        super.update();
        if(colorInterval == 450){
            colorInterval = 0;
            color++;
            if(color > 3) color = 1;
            changeColor(color);
        }
        colorInterval++;
    }
}



class Boss02 extends LineBoss
{
    public var n:int;
    public var angle_range:Number;
    public var angle_speed:Number;
    public var colorInterval:int;
    public var nextInterval:int;
    
    public function Boss02(main:Game, param:Object)
    {
        super(main, param);
        this.n = param.n;
        this.angle_range = param.angle_range;
        this.angle_speed = param.angle_speed;
        this.color = 1;
        n++;
        nextInterval = interval/1.5;
        colorInterval = 0;
        draw();
    }
    
    override public function draw():void{
        graphics.clear();
        graphics.lineStyle(2, 0xFFFFFF);
        graphics.drawCircle(0,0,size);
        var c:uint;
        if(color == 0) c = 0xFFFFFF;
        else if(color == 1) c = 0xFF0000;
        else if(color == 2) c = 0xFF00;
        else c = 0xFF;
        filters = [new GlowFilter(c, 1.0, 4, 4, 2, 1)];
    }
    
    override public function shot(color:int):void{
        shot_angle += angle_speed;
        var N:int = n;
        
        if(hp/maxHp < 0.5) interval = nextInterval;
        
        
        for(var i:int = 0; i < N-1; i++){
            var b:Bullet = new Bullet(main, false, i%3+1);
            b.setPosition(x, y);
            var angle:Number = shot_angle+angle_range*(i/(N-1)-0.5);
            b.setSpeedByTheta(shot_speed, angle);
            bulletList.push(b);
            main.addChild(b);
        }
    }
    
    override public function update():void{
        super.update();
        if(colorInterval == 450){
            colorInterval = 0;
            color++;
            if(color > 3) color = 1;
            changeColor(color);
        }
        colorInterval++;
    }
}




class Boss03 extends LineBoss
{
    public var n:int;
    public var angle_range:Number;
    public var angle_speed:Number;
    public var colorInterval:int;
    public var gravity:Number;
    public var f:Boolean;
    public var moveTween:ITween;
    
    public function Boss03(main:Game, param:Object)
    {
        super(main, param);
        this.n = param.n;
        this.angle_range = param.angle_range;
        this.angle_speed = param.angle_speed;
        this.gravity = param.gravity;
        this.color = 1;
        colorInterval = 0;
        n++;
        f = false;
        draw();
    }
    
    override public function draw():void{
        graphics.clear();
        graphics.lineStyle(2, 0xFFFFFF);
        graphics.drawCircle(0,0,size);
        var c:uint;
        if(color == 0) c = 0xFFFFFF;
        else if(color == 1) c = 0xFF0000;
        else if(color == 2) c = 0xFF00;
        else c = 0xFF;
        filters = [new GlowFilter(c, 1.0, 4, 4, 2, 1)];
    }
    
    override public function shot(color:int):void{
        shot_angle += angle_speed;
        var N:int = n;
        
        for(var i:int = 0; i < N-1; i++){
            var c:int;
            if(hp/maxHp < 0.3) color = i%3+1;
            else color = this.color;
            var b:Bullet = new GravityBullet(main, false, color, gravity);
            
            b.setPosition(x, y);
            var angle:Number = shot_angle+angle_range*(i/(N-1)-0.5);
            b.setSpeedByTheta(shot_speed, angle);
            bulletList.push(b);
            main.addChild(b);
        }
    }
    
    override public function remove():void{
        super.remove();
        moveTween.stop();
        moveTween = null;
    }
    
    public function tween1():void{
        moveTween = BetweenAS3.to(this, {x:50}, 4, Sine.easeInOut);
        moveTween.onComplete = tween2;
        moveTween.play();
    }
    
    public function tween2():void{
        var t:ITween = BetweenAS3.serial(BetweenAS3.to(this, {x:W-50}, 8, Sine.easeInOut), BetweenAS3.to(this, {x:50}, 8, Sine.easeInOut));
        moveTween = BetweenAS3.repeat(t, 100);
        moveTween.play();
    }
    
    override public function update():void{
        if(f == false && !tween.isPlaying){
            f = true;
            tween1();
        }
        
        super.update();
        if(colorInterval == 450){
            colorInterval = 0;
            color++;
            if(color > 3) color = 1;
            changeColor(color);
        }
        colorInterval++;
    }
}



class Boss04 extends LineBoss
{
    public var n:int;
    public var angle_range:Number;
    public var angle_speed:Number;
    public var colorInterval:int;
    public var nextInterval:int;
    
    public var a:Number, b:int;
    
    public function Boss04(main:Game, param:Object)
    {
        super(main, param);
        this.n = param.n;
        this.angle_range = param.angle_range;
        this.a = param.angle_speed;
        this.b = interval;
        angle_speed = a;
        this.color = 1;
        n++;
        nextInterval = interval/1.5;
        colorInterval = 0;
        draw();
    }
    
    override public function draw():void{
        graphics.clear();
        graphics.lineStyle(2, 0xFFFFFF);
        graphics.drawCircle(0,0,size);
        var c:uint;
        if(color == 0) c = 0xFFFFFF;
        else if(color == 1) c = 0xFF0000;
        else if(color == 2) c = 0xFF00;
        else c = 0xFF;
        filters = [new GlowFilter(c, 1.0, 4, 4, 2, 1)];
    }
    
    override public function shot(color:int):void{
        shot_angle += angle_speed;
        var N:int = n;
        
        if(hp/maxHp < 0.5) N = 1.5*n;
        
        if(color == 1){
            for(var i:int = 0; i < N-1; i++){
                var b:Bullet = new Bullet(main, false, color);
                b.setPosition(x, y);
                var angle:Number = shot_angle+angle_range*(i/(N-1)-0.5);
                b.setSpeedByTheta(shot_speed, angle);
                bulletList.push(b);
                main.addChild(b);
            }
        }
        else if(color == 2){
            for(i = 0; i < N-1; i++){
                b = new GravityBullet(main, false, color, 0.1);
                b.setPosition(x, y);
                angle = shot_angle+angle_range*(i/(N-1)-0.5);
                b.setSpeedByTheta(shot_speed/1.5, angle);
                bulletList.push(b);
                main.addChild(b);
            }
        }
        else{
            if(main.selectSp.select == 1){
                for(i = 0; i < 2; i++){
                    b = new GravityBullet(main, false, color, 0.1);
                    b.setPosition(x, y);
                    angle = shot_angle+Math.PI*2*(i/(3-1)-0.5);
                    b.setSpeedByTheta(shot_speed/1.5, angle);
                    bulletList.push(b);
                    main.addChild(b);
                }
            }
            else{
                b = new GravityBullet(main, false, color, 0.1);
                b.setPosition(x, y);
                angle = shot_angle;
                b.setSpeedByTheta(shot_speed/1.5, angle);
                bulletList.push(b);
                main.addChild(b);
            }
        }
    }
    
    override public function update():void{
        super.update();
        if(colorInterval == 300){
            colorInterval = 0;
            color++;
            if(color > 3) color = 1;
            changeColor(color);
            if(color == 3){
                angle_speed = a*2;
                interval = b/5;
            }
            else{
                interval = b;
                angle_speed = a;
            }
        }
        colorInterval++;
    }
}


class Boss05 extends LineBoss
{
    public var n:int;
    public var colorInterval:int;
    
    public function Boss05(main:Game, param:Object)
    {
        super(main, param);
        this.n = param.n;
        this.color = 1;
        colorInterval = 0;
        n++;
        draw();
    }
    
    override public function draw():void{
        graphics.clear();
        graphics.lineStyle(2, 0xFFFFFF);
        graphics.drawCircle(0,0,size);
        var c:uint;
        if(color == 0) c = 0xFFFFFF;
        else if(color == 1) c = 0xFF0000;
        else if(color == 2) c = 0xFF00;
        else c = 0xFF;
        filters = [new GlowFilter(c, 1.0, 4, 4, 2, 1)];
    }
    
    override public function shot(color:int):void{
        var b:Bullet = new Bullet(main, false, 1);
        b.setPosition(x, y);
        b.setSpeedByTheta(shot_speed, -Math.PI/2);
        bulletList.push(b);
        main.addChild(b);
        
        b = new Bullet(main, false, 2);
        b.setPosition(x, y);
        b.setSpeedByTheta(shot_speed, Math.PI);
        bulletList.push(b);
        main.addChild(b);
        
        b = new Bullet(main, false, 3);
        b.setPosition(x, y);
        b.setSpeedByTheta(shot_speed, 0);
        bulletList.push(b);
        main.addChild(b);
    }
    
    override public function update():void{
        super.update();
        if(colorInterval == 450){
            colorInterval = 0;
            color++;
            if(color > 3) color = 1;
            changeColor(color);
        }
        colorInterval++;
    }
}



class Boss06 extends LineBoss
{
    public var n:int;
    public var colorInterval:int;
    
    public function Boss06(main:Game, param:Object)
    {
        super(main, param);
        this.n = param.n;
        this.color = 1;
        colorInterval = 0;
        n++;
        draw();
        shot_angle = 0;
    }
    
    override public function draw():void{
        graphics.clear();
        graphics.lineStyle(2, 0xFFFFFF);
        graphics.drawCircle(0,0,size);
        var c:uint;
        if(color == 0) c = 0xFFFFFF;
        else if(color == 1) c = 0xFF0000;
        else if(color == 2) c = 0xFF00;
        else c = 0xFF;
        filters = [new GlowFilter(c, 1.0, 4, 4, 2, 1)];
    }
    
    override public function shot(color:int):void{
        var m:int;
        if(1 || hp/maxHp > 0.5) m=Math.random()*2;
        else m = 0;
        if(m == 0){
            m = Math.random()*10;
            //通常
            if(m < 4) new LineEnemyA(main, {fromX:x, fromY:y, toX:Math.random()*(W-50)+25, toY:Math.random()*H/2+50, time:1, hp:1, color:color, size:7, interval:60, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100});
                //自機狙い
            else if(m < 7) new LineEnemyB(main, {fromX:x, fromY:y, toX:Math.random()*(W-50)+25, toY:Math.random()*H/2+50, time:1, hp:1, color:color, size:7, interval:60, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100});
                //n-way
            else if(m < 9) new LineEnemyC(main, {fromX:x, fromY:y, toX:Math.random()*(W-50)+25, toY:Math.random()*H/2+50, time:1, hp:1, color:color, size:7, interval:60, shot_speed:4, shot_angle:Math.PI/2, n:Math.random()*4+2, angle_range:Math.PI*2, angle_speed:Math.random(), itemValue:1, itemType:1, score:100});
                //重力
            else new LineEnemyG(main, {fromX:x, fromY:y, toX:Math.random()*(W-50)+25, toY:Math.random()*H/2+50, time:1, hp:1, color:color, size:7, interval:60, shot_speed:2, shot_angle:Math.PI/2, n:Math.random()*4+2, angle_range:Math.PI*2, angle_speed:Math.random(), gravity:0.1, itemValue:1, itemType:1, score:100});
        }
        var b:Bullet = new Bullet(main, false, color);
        b.setPosition(x, y);
        var angle:Number = shot_angle;
        if(main.selectSp.select == 1) angle = Math.atan2(main.myShip.y-y, main.myShip.x-x);
        shot_angle += 0.5;
        b.setSpeedByTheta(shot_speed, angle);
        bulletList.push(b);
        main.addChild(b);
    }
    
    override public function update():void{
        super.update();
        if(colorInterval == 450){
            colorInterval = 0;
            color++;
            if(color > 3) color = 1;
            changeColor(color);
        }
        colorInterval++;
    }
}



class Boss07 extends LineBoss
{
    public var n:int;
    public var angle_range:Number;
    public var angle_speed:Number;
    public var colorInterval:int;
    
    public function Boss07(main:Game, param:Object)
    {
        super(main, param);
        this.n = param.n;
        this.angle_range = param.angle_range;
        this.angle_speed = param.angle_speed;
        this.color = 1;
        colorInterval = 0;
        n++;
        draw();
    }
    
    override public function draw():void{
        graphics.clear();
        graphics.lineStyle(2, 0xFFFFFF);
        graphics.drawCircle(0,0,size);
        var c:uint;
        if(color == 0) c = 0xFFFFFF;
        else if(color == 1) c = 0xFF0000;
        else if(color == 2) c = 0xFF00;
        else c = 0xFF;
        filters = [new GlowFilter(c, 1.0, 4, 4, 2, 1)];
    }
    
    override public function shot(color:int):void{
        shot_angle += angle_speed;
        var N:int;
        
        if(main.selectSp.select == 1){
            if(hp/maxHp < 0.2) N = 10;
            else if(hp/maxHp < 0.4) N = 8;
            else if(hp/maxHp < 0.6) N = 7;
            else if(hp/maxHp < 0.8) N = 5;
            else N = 4;
        }
        else{
            if(hp/maxHp < 0.2) N = 7;
            else if(hp/maxHp < 0.4) N = 6;
            else if(hp/maxHp < 0.5) N = 5;
            else if(hp/maxHp < 0.6) N = 4;
            else if(hp/maxHp < 0.8) N = 3;
            else N = 2;
        }
        for(var i:int = 0; i < N-1; i++){
            var b:Bullet = new Bullet(main, false, (color+i-1)%3+1);
            b.setPosition(x, y);
            var angle:Number = shot_angle+angle_range*(i/(N-1)-0.5);
            b.setSpeedByTheta(shot_speed, angle);
            bulletList.push(b);
            main.addChild(b);
        }
    }
    
    override public function update():void{
        super.update();
        if(colorInterval == 450){
            colorInterval = 0;
            color++;
            if(color > 3) color = 1;
            changeColor(color);
        }
        colorInterval++;
    }
}






class LineEnemy extends BaseEnemy
{
    private var tween:ITween=null;
    
    public function LineEnemy(main:Game, param:Object)
    {
        super(main, param);
        setMoveTrajectory(param.fromX, param.fromY, param.toX, param.toY, param.time);
        start();
    }
    
    override public function draw():void{
        graphics.clear();
        graphics.lineStyle(2, 0xFFFFFF);
        graphics.moveTo(0,-size);
        graphics.lineTo(size,0);
        graphics.lineTo(0,size);
        graphics.lineTo(-size,0);
        graphics.lineTo(0,-size);
        var c:uint;
        if(color == 0) c = 0xFFFFFF;
        else if(color == 1) c = 0xFF0000;
        else if(color == 2) c = 0xFF00;
        else c = 0xFF;
        filters = [new GlowFilter(c, 1.0, 4, 4, 2, 1)];
    }
    
    override public function effect():void{
        if(tween!=null)tween.stop();
        super.effect();
    }
    
    //(fromX, fromY)から(toX, toY)へtimeミリ秒かけて移動する
    public function setMoveTrajectory(fromX:Number, fromY:Number, toX:Number, toY:Number, time:Number):void{
        setPosition(fromX, fromY);
        tween = BetweenAS3.to(this, {x:toX, y:toY}, time);
        tween.onComplete = onComp;
    }
    
    public function onComp():void{
        if(x < -width || W+width < x || y < -height || H+height < y) dead = true;
    }
    
    //移動開始
    public function start():void{
        if(tween != null)tween.play();
    }
    
    override public function update():void{
        super.update();
    }
}

/**
 * 動き: 直線
 * 弾:前方に1つの直線弾,
 * param:
 *   fromX   : 始点x座標,
 *   fromY   : 始点y座標,
 *   toX     : 終点x座標,
 *   toY     : 終点y座標,
 *   time    : 移動に要する時間,
 *      hp      : 体力,
 *   color   : 色,
 *   size    : 大きさ,
 *   interval:弾を撃つ間隔,
 *   shot_speed   :弾のスピード,
 *   shot_angle   :弾の発射角度,
 **/
class LineEnemyA extends LineEnemy
{
    public function LineEnemyA(main:Game, param:Object)
    {
        super(main, param);
    }
    
    override public function shot(color:int):void{
        var b:Bullet = new Bullet(main, false, color);
        b.setPosition(x, y);
        b.setSpeedByTheta(shot_speed, shot_angle);
        bulletList.push(b);
        main.addChild(b);
    }
}

//自機狙い
class LineEnemyB extends LineEnemy
{
    public function LineEnemyB(main:Game, param:Object)
    {
        super(main, param);
    }
    
    override public function shot(color:int):void{
        var b:Bullet = new Bullet(main, false, color);
        b.setPosition(x, y);
        var angle:Number = Math.atan2(main.myShip.y-y, main.myShip.x-x);
        b.setSpeedByTheta(shot_speed, angle);
        bulletList.push(b);
        main.addChild(b);
    }
}

//nway弾
class LineEnemyC extends LineEnemy
{
    public var n:int;
    public var angle_range:Number;
    public var angle_speed:Number;
    
    public function LineEnemyC(main:Game, param:Object)
    {
        super(main, param);
        this.n = param.n;
        this.angle_range = param.angle_range;
        this.angle_speed = param.angle_speed;
    }
    
    override public function shot(color:int):void{
        shot_angle += angle_speed;
        if(n > 0){
            for(var i:int = 0; i < n; i++){
                var b:Bullet = new Bullet(main, false, color);
                b.setPosition(x, y);
                var angle:Number = shot_angle+angle_range*(i/(n-1)-0.5);
                b.setSpeedByTheta(shot_speed, angle);
                bulletList.push(b);
                main.addChild(b);
            }
        }
        else{
            b = new Bullet(main, false, color);
            b.setPosition(x, y);
            b.setSpeedByTheta(shot_speed, shot_angle);
            bulletList.push(b);
            main.addChild(b);
        }
    }
}

//nway自機狙い
class LineEnemyD extends LineEnemyC
{
    public function LineEnemyD(main:Game, param:Object)
    {
        super(main, param);
    }
    
    override public function shot(color:int):void{
        shot_angle += angle_speed;
        var angle_ship:Number = Math.atan2(main.myShip.y-y, main.myShip.x-x);
        if(n > 0){
            for(var i:int = 0; i < n; i++){
                var b:Bullet = new Bullet(main, false, color);
                b.setPosition(x, y);
                var angle:Number = angle_ship+angle_range*(i/(n-1)-0.5);
                b.setSpeedByTheta(shot_speed, angle);
                bulletList.push(b);
                main.addChild(b);
            }
        }
        else{
            b = new Bullet(main, false, color);
            b.setPosition(x, y);
            b.setSpeedByTheta(shot_speed, angle_ship);
            bulletList.push(b);
            main.addChild(b);
        }
    }
}


class LineEnemyE extends LineEnemyC
{
    public var bulletSize:Number;
    public function LineEnemyE(main:Game, param:Object)
    {
        super(main, param);
        this.bulletSize = param.bulletSize;
    }
    
    override public function shot(color:int):void{
        shot_angle += angle_speed;
        if(n > 0){
            for(var i:int = 0; i < n; i++){
                var b:BallBullet = new BallBullet(main, false, color, bulletSize);
                b.setPosition(x, y);
                var angle:Number = shot_angle+angle_range*(i/(n-1)-0.5);
                b.setSpeedByTheta(shot_speed, angle);
                bulletList.push(b);
                main.addChild(b);
            }
        }
        else{
            b = new BallBullet(main, false, color, bulletSize);
            b.setPosition(x, y);
            b.setSpeedByTheta(shot_speed, shot_angle);
            bulletList.push(b);
            main.addChild(b);
        }
    }
}

//直線弾
class LineEnemyF extends LineEnemyC
{
    //一度に発射する弾数
    public var shot_num:int;
    public var line_shot_cnt:int;
    public function LineEnemyF(main:Game, param:Object)
    {
        super(main, param);
        this.shot_num = param.shot_num*5;
        line_shot_cnt = 0;
    }
    
    override public function update():void{
        move();
        if(interval == shotCnt){
            if(line_shot_cnt%5==0) shot(color);
            line_shot_cnt++;
            if(line_shot_cnt == shot_num){
                shot_num = 0;
                shotCnt = 0;
            }
        }else shotCnt++;
    }
}


//重力弾を打つ敵
class LineEnemyG extends LineEnemyC
{
    public var gravity:Number;
    public function LineEnemyG(main:Game, param:Object)
    {
        super(main, param);
        this.gravity = param.gravity;
    }
    
    override public function shot(color:int):void{
        shot_angle += angle_speed;
        if(n > 0){
            for(var i:int = 0; i < n; i++){
                var b:GravityBullet = new GravityBullet(main, false, color, gravity);
                b.setPosition(x, y);
                var angle:Number = shot_angle+angle_range*(i/(n-1)-0.5);
                b.setSpeedByTheta(shot_speed, angle);
                bulletList.push(b);
                main.addChild(b);
            }
        }
        else{
            b = new GravityBullet(main, false, color, gravity);
            b.setPosition(x, y);
            b.setSpeedByTheta(shot_speed, shot_angle);
            bulletList.push(b);
            main.addChild(b);
        }
    }
}


class LineEnemyH extends LineEnemy
{
    public var n:int;
    public function LineEnemyH(main:Game, param:Object)
    {
        super(main, param);
        this.n = param.n;
    }
    
    override public function shot(color:int):void{
        for(var i:int = 0; i < n; i++){
            var b:Bullet = new Bullet(main, false, color);
            b.setPosition(x, y);
            var angle:Number = Math.PI*2*Math.random();
            b.setSpeedByTheta(2+Math.random()*3, angle);
            bulletList.push(b);
            main.addChild(b);
        }
    }
}







class Item extends Sprite
{
    public static const POWER:int = 0;
    public static const SCORE:int = 1;
    public static const LIFE:int = 2;
    
    public var W:Number, H:Number;
    public var type:int;
    public var size:int;
    public var vy:Number;
    public var value:int;
    public var main:Game;
    public var rect:Rectangle;
    
    public function Item(main:Game, param:Object)
    {
        super();
        this.main = main;
        W = main.W;
        H = main.H;
        
        x = param.x;
        y = param.y;
        type = param.type;
        size = param.size;
        vy = param.vy;
        value = param.value;
        
        main.addChild(this);
        main.itemList.push(this);
        
        draw();
        rect = new Rectangle(x-width/2-5, y-height/2-5, width+10, height+10);
    }
    
    public function draw():void{
        var c:uint;
        if(type == POWER) c = 0xFF0000;
        else if(type == LIFE) c = 0xFF00;
        else c = 0xFF;
        graphics.clear();
        graphics.lineStyle(2, 0xFFFFFF);
        graphics.drawRect(-size/2, -size/2, size, size); 
        filters = [new GlowFilter(c, 1, 8, 8, 2, 1)];
    }
    
    public function effect():void{
        var t:ITween = BetweenAS3.to(this, {alpha:0, scaleX:2, scaleY:2}, 0.2);
        t.onComplete = remove;
        t.play();
    }
    
    public function remove():void{
        parent.removeChild(this);
    }
    
    public function update():void{
        y += vy;
        rect.y = y-height/2-5;
    }
}



/**
 * 固定壁
 * x:
 * y: 位置
 * color: 壁の色
 * w: 壁の大きさ
 * angle: 角度
 * vr: 壁の角速度
 */
class Wall extends Sprite
{
    private var main:Game;
    private var W:Number, H:Number;
    public var x1:Number, x2:Number, y1:Number, y2:Number;
    public var w:int; 
    public var theta:Number;
    public var color:int;
    public var rect:Rectangle;
    public var vr:Number;
    public var talpha:Number;
    public var dead:Boolean;
    
    public function Wall(main:Game, param:Object)
    {
        super();
        this.main = main;
        W = main.W;
        H = main.H;
        
        this.color = param.color;
        this.w = param.w;
        this.x = param.x;
        this.y = param.y;
        this.vr = param.vr;
        this.theta = param.angle;
        
        this.alpha = 0.7;
        this.talpha = 0.5;
        
        main.addChild(this);
        main.wallList.push(this);
        
        rect = new Rectangle(-w/2, -1, w, 3);
        dead = false;
        
        this.scaleX = this.scaleY = 0;
        fadeIn();
        
        draw();
        
        updateEdgePos();
    }
    
    public function remove():void{
        dead = true;
        parent.removeChild(this);
    }
    
    public function fadeIn():void{
        var tween:ITween = BetweenAS3.to(this, {scaleX:1, scaleY:1}, 1.0);
        tween.play();
    }
    
    public function fadeOut():void{
        var tween:ITween = BetweenAS3.to(this, {alpha:0, scaleX:0, scaleY:0}, 1.0);
        tween.onComplete = remove;
        tween.play();
    }
    
    public function changeColor(color:int):void{
        this.color = color;
        var c:uint;
        if(color == 0) c = 0xFFFFFF;
        else if(color == 1) c = 0xFF0000;
        else if(color == 2) c = 0xFF00;
        else c = 0xFF;
        filters = [new GlowFilter(c, 1.0, 4, 4, 2, 1)];
    }
    
    public function setAngle(theta:Number):void{
        this.theta = theta;
        rotation = theta/Math.PI*180;
        updateEdgePos();
    }
    
    
    public function updateEdgePos():void{
        x1 = -w/2*Math.cos(theta)+x;
        x2 = w/2*Math.cos(theta)+x;
        y1 = -w/2*Math.sin(theta)+y;
        y2 = w/2*Math.sin(theta)+y;
    }
    
    public function setPosition(x:Number, y:Number):void{
        this.x = x;
        this.y = y;
        updateEdgePos();
    }
    
    public function draw():void{
        graphics.clear();
        graphics.lineStyle(3, 0xFFFFFF);
        graphics.moveTo(-w/2, 0);
        graphics.lineTo(w/2, 0);
        
        var c:uint;
        if(color == 0) c = 0xFFFFFF;
        else if(color == 1) c = 0xFF0000;
        else if(color == 2) c = 0xFF00;
        else c = 0xFF;
        filters = [new GlowFilter(c, 1.0, 4, 4, 2, 1)];
    }
    
    public function update():void{
        alpha += (talpha-alpha)/8;
        setAngle(theta+vr);
        talpha -= 0.03;
        if(talpha < 0.7) talpha = 0.7;
    }
}

/**
 * 直線に繰り返し動く壁
 * x,y:初期位置
 * X, Y: 繰り返す頂点配列
 * T: 何秒かけて移動するか配列
 * color: 壁の色
 * w: 壁の大きさ
 * angle: 角度
 * vr: 壁の角速度
 */
class LineRepeatResizeWall extends Wall
{
    public var X:Vector.<Number>, Y:Vector.<Number>, T:Vector.<Number>;
    public var end:Boolean;
    public function LineRepeatResizeWall(main:Game, param:Object)
    {
        super(main, param);
        
        this.X = Vector.<Number>(param.X);
        this.Y = Vector.<Number>(param.Y);
        this.T = Vector.<Number>(param.T);
        
        end = false;
        tween(0);
    }
    
    public function tween(i:int):void{
        if(end) return;
        if(i >= X.length) i = 0;
        var t:ITween = BetweenAS3.to(this, {x:X[i], y:Y[i]}, T[i], Sine.easeInOut);
        t.onComplete = tween;
        t.onCompleteParams = [i+1];
        t.play();
    }
    
    override public function remove():void{
        super.remove();
        end = true;
    }
}




/**
 * 直線に繰り返し動く壁
 * x,y:初期位置
 * X, Y: 繰り返す頂点配列
 * T: 何秒かけて移動するか配列
 * color: 壁の色
 * w: 壁の大きさ
 * angle: 角度
 * vr: 壁の角速度
 */
class LineRepeatWall extends Wall
{
    public var X:Vector.<Number>, Y:Vector.<Number>, T:Vector.<Number>;
    public var tween:ITween;
    public function LineRepeatWall(main:Game, param:Object)
    {
        super(main, param);
        
        this.X = Vector.<Number>(param.X);
        this.Y = Vector.<Number>(param.Y);
        this.T = Vector.<Number>(param.T);
        
        var ary:Array = [];
        for(var i:int = 0; i < X.length; i++){
            var xx:Number, yy:Number;
            if(i == 0){
                xx = x;
                yy = y;
            }
            else{
                xx = X[i-1];
                yy = Y[i-1];
            }
            var t:ITween = BetweenAS3.tween(this, {x:X[i], y:Y[i]}, {x:xx, y:yy}, T[i], Sine.easeInOut);
            ary.push(t);
        }
        tween = BetweenAS3.repeat(BetweenAS3.serialTweens(ary), 100);
        tween.play();
    }
    
    override public function remove():void{
        tween.stop();
        super.remove();
    }
}


/**
 * 直線に動く壁
 * x, y: 始点
 * toX, toY: 終点
 * time: 何秒かけて移動するか
 * color: 壁の色
 * w: 壁の大きさ
 * angle: 角度
 * vr: 壁の角速度
 */
class LineWall extends Wall
{
    public var toX:Number, toY:Number;
    public var time:Number;
    
    public function LineWall(main:Game, param:Object)
    {
        super(main, param);
        this.toX = param.toX;
        this.toY = param.toY;
        this.time = param.time;
        
        var t:ITween = BetweenAS3.to(this, {x:toX, y:toY}, time);
        t.play();
    }
}





/**
 * 
 * type: 命令の種類
 * index: ターゲットなる壁のindex
 * color: 色を変える場合の色
 */
class WallCommand
{
    public static const CHANGE_COLOR:int = 0;
    public static const DELETE:int = 1;
    
    public function WallCommand(main:Game, param:Object)
    {
        var wallList:Vector.<Wall> = main.wallList;
        var type:int = param.type;
        var i:int = param.index;
        
        if(type == CHANGE_COLOR){
            wallList[i].changeColor(param.color);
        }
        else if(type == DELETE){
            wallList[i].fadeOut();
        }
    }
}



class BaseStage extends EventDispatcher
{
    public var id:int;
    public var W:Number, H:Number;
    
    public var phase:Vector.<Phase>;
    
    public function BaseStage(main:Game, id:int)
    {
        W = main.W;
        H = main.H;
        this.id = id;
        setData();
    }
    
    public function setData():void{
        
    }
}

class Phase
{
    //クラス
    public var cls:Class;
    //パラメータ
    public var param:Object;
    //前のオブジェクトの発生から何frameで発生するか
    public var time:int;
    
    public function Phase(cls:Class, param:Object, time:int)
    {
        this.cls = cls;
        this.param = param;
        this.time = time;
    }
}

class Stage1 extends BaseStage
{
    public function Stage1(main:Game, id:int)
    {
        super(main, id);
    }
    /*
    fromX   : 始点x座標,
    *   fromY   : 始点y座標,
    *   toX     : 終点x座標,
    *   toY     : 終点y座標,
    *   time    : 移動に要する時間,
    *      hp      : 体力,
    *   color   : 色,
    *   size    : 大きさ,
    *   interval:弾を撃つ間隔,
    *   speed   :弾のスピード,
    *   angle   :弾の発射角度,
    */
    
    /*
    * x:
    * y: 位置
    * color: 壁の色
    * w: 壁の大きさ
    * angle: 角度
    * vr: 壁の角速度
    */
    
    override public function setData():void{
        phase = Vector.<Phase>(
            [
                //Stage1
                new Phase(Text, {x:W/2, y:H/2, fontSize:50, text:"Stage1", time:120}, 30),    
                
                new Phase(LineRepeatWall, {x:30, y:100, X:[30,30], Y:[H-100,100], T:[5,5], w:150, color:1, angle:Math.PI/2, vr:0}, 30),
                new Phase(LineRepeatWall, {x:W-30, y:H-100, X:[W-30,W-30], Y:[100,H-100], T:[5,5], w:150, color:2, angle:Math.PI/2, vr:0}, 0),
                new Phase(LineRepeatWall, {x:50, y:H-30, X:[W-50, 50], Y:[H-30, H-30], T:[5,5], w:150, color:3, angle:0, vr:0}, 0),
                
                //通常敵 1
                new Phase(LineEnemyA, {fromX:W/2,     fromY:-50, toX:W/2,     toY:500, time:5, hp:1, color:1, size:7, interval:60, shot_speed:5, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 60),
                new Phase(LineEnemyA, {fromX:W/2-100, fromY:-50, toX:W/2-100, toY:500, time:5, hp:1, color:1, size:7, interval:60, shot_speed:5, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 60),
                new Phase(LineEnemyA, {fromX:W/2+100, fromY:-50, toX:W/2+100, toY:500, time:5, hp:1, color:1, size:7, interval:60, shot_speed:5, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 60),
                new Phase(LineEnemyA, {fromX:W/2-50,  fromY:-50, toX:W/2-50,  toY:500, time:5, hp:1, color:1, size:7, interval:60, shot_speed:5, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 60),
                new Phase(LineEnemyA, {fromX:W/2+50,  fromY:-50, toX:W/2+50,  toY:500, time:5, hp:1, color:1, size:7, interval:60, shot_speed:5, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 60),
                
                new Phase(LineEnemyB, {fromX:W/2-100, fromY:-50, toX:W/2-100, toY:500, time:5, hp:1, color:2, size:7, interval:60, shot_speed:5, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 120),
                new Phase(LineEnemyB, {fromX:W/2-50,  fromY:-50, toX:W/2-50,  toY:500, time:5, hp:1, color:2, size:7, interval:60, shot_speed:5, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 60),
                new Phase(LineEnemyB, {fromX:W/2,     fromY:-50, toX:W/2,     toY:500, time:5, hp:1, color:2, size:7, interval:60, shot_speed:5, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 60),
                new Phase(LineEnemyB, {fromX:W/2+50,  fromY:-50, toX:W/2+50,  toY:500, time:5, hp:1, color:2, size:7, interval:60, shot_speed:5, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 60),
                new Phase(LineEnemyB, {fromX:W/2+100, fromY:-50, toX:W/2+100, toY:500, time:5, hp:1, color:2, size:7, interval:60, shot_speed:5, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 60),
                
                new Phase(LineEnemyC, {fromX:W/2+100, fromY:-50, toX:W/2+100, toY:500, time:5, hp:1, color:3, size:7, interval:90, shot_speed:4, shot_angle:Math.PI/2, n:2, angle_range:Math.PI/2, angle_speed:0, itemValue:1, itemType:0, score:100}, 120),
                new Phase(LineEnemyC, {fromX:W/2-100, fromY:-50, toX:W/2-100, toY:500, time:5, hp:1, color:3, size:7, interval:90, shot_speed:4, shot_angle:Math.PI/2, n:2, angle_range:Math.PI/2, angle_speed:0, itemValue:1, itemType:1, score:100}, 60),
                new Phase(LineEnemyC, {fromX:W/2-50,  fromY:-50, toX:W/2-50,  toY:500, time:5, hp:1, color:3, size:7, interval:90, shot_speed:4, shot_angle:Math.PI/2, n:2, angle_range:Math.PI/2, angle_speed:0, itemValue:1, itemType:0, score:100}, 60),
                new Phase(LineEnemyC, {fromX:W/2+50,  fromY:-50, toX:W/2+50,  toY:500, time:5, hp:1, color:3, size:7, interval:90, shot_speed:4, shot_angle:Math.PI/2, n:2, angle_range:Math.PI/2, angle_speed:0, itemValue:1, itemType:1, score:100}, 60),
                new Phase(LineEnemyC, {fromX:W/2,     fromY:-50, toX:W/2,     toY:500, time:5, hp:1, color:3, size:7, interval:90, shot_speed:4, shot_angle:Math.PI/2, n:2, angle_range:Math.PI/2, angle_speed:0, itemValue:1, itemType:0, score:100}, 60),
                
                //中ボス
                new Phase(LineEnemyD, {fromX:W/2-100, fromY:-50, toX:W/2-100, toY:150, time:2, hp:10, color:1, size:15, interval:80, shot_speed:4, shot_angle:Math.PI/2, n:3, angle_range:Math.PI/2, angle_speed:0, itemValue:5, itemType:0, score:500}, -1),
                new Phase(LineEnemyD, {fromX:W/2+100, fromY:-50, toX:W/2+100, toY:150, time:2, hp:10, color:2, size:15, interval:80, shot_speed:4, shot_angle:Math.PI/2, n:3, angle_range:Math.PI/2, angle_speed:0, itemValue:1, itemType:2, score:500}, -1),
                new Phase(LineEnemyD, {fromX:W/2,     fromY:-50, toX:W/2,     toY:150, time:2, hp:10, color:3, size:15, interval:80, shot_speed:4, shot_angle:Math.PI/2, n:3, angle_range:Math.PI/2, angle_speed:0, itemValue:5, itemType:1, score:500}, -1),
                
                //通常敵2
                new Phase(LineEnemyA, {fromX:-50, fromY:100, toX:W+50, toY:100, time:5, hp:1, color:1, size:7, interval:60, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, -1),
                new Phase(LineEnemyB, {fromX:-50, fromY:100, toX:W+50, toY:100, time:5, hp:1, color:1, size:7, interval:60, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 30),
                new Phase(LineEnemyA, {fromX:-50, fromY:100, toX:W+50, toY:100, time:5, hp:1, color:1, size:7, interval:60, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 30),
                new Phase(LineEnemyB, {fromX:-50, fromY:100, toX:W+50, toY:100, time:5, hp:1, color:1, size:7, interval:60, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 30),
                new Phase(LineEnemyA, {fromX:-50, fromY:100, toX:W+50, toY:100, time:5, hp:1, color:1, size:7, interval:60, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 30),
                new Phase(LineEnemyB, {fromX:-50, fromY:100, toX:W+50, toY:100, time:5, hp:1, color:1, size:7, interval:60, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 30),
                
                new Phase(LineEnemyA, {fromX:W+50, fromY:50, toX:-50, toY:50, time:5, hp:1, color:2, size:7, interval:60, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 90),
                new Phase(LineEnemyB, {fromX:W+50, fromY:50, toX:-50, toY:50, time:5, hp:1, color:2, size:7, interval:60, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 30),
                new Phase(LineEnemyA, {fromX:W+50, fromY:50, toX:-50, toY:50, time:5, hp:1, color:2, size:7, interval:60, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 30),
                new Phase(LineEnemyB, {fromX:W+50, fromY:50, toX:-50, toY:50, time:5, hp:1, color:2, size:7, interval:60, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 30),
                new Phase(LineEnemyA, {fromX:W+50, fromY:50, toX:-50, toY:50, time:5, hp:1, color:2, size:7, interval:60, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 30),
                new Phase(LineEnemyB, {fromX:W+50, fromY:50, toX:-50, toY:50, time:5, hp:1, color:2, size:7, interval:60, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 30),
                
                new Phase(LineEnemyA, {fromX:-50, fromY:100, toX:W+50, toY:100, time:5, hp:1, color:3, size:7, interval:90, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 90),
                new Phase(LineEnemyB, {fromX:-50, fromY:100, toX:W+50, toY:100, time:5, hp:1, color:3, size:7, interval:90, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 30),
                new Phase(LineEnemyA, {fromX:-50, fromY:100, toX:W+50, toY:100, time:5, hp:1, color:3, size:7, interval:90, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 30),
                new Phase(LineEnemyB, {fromX:-50, fromY:100, toX:W+50, toY:100, time:5, hp:1, color:3, size:7, interval:90, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 30),
                new Phase(LineEnemyA, {fromX:-50, fromY:100, toX:W+50, toY:100, time:5, hp:1, color:3, size:7, interval:90, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 30),
                new Phase(LineEnemyB, {fromX:-50, fromY:100, toX:W+50, toY:100, time:5, hp:1, color:3, size:7, interval:90, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 30),
                
                new Phase(LineEnemyA, {fromX:W+50, fromY:50, toX:-50, toY:50, time:5, hp:1, color:1, size:7, interval:90, shot_speed:4, shot_angle:Math.PI/2, itemValue:2, itemType:0, score:100}, 90),
                new Phase(LineEnemyB, {fromX:W+50, fromY:50, toX:-50, toY:50, time:5, hp:1, color:1, size:7, interval:90, shot_speed:4, shot_angle:Math.PI/2, itemValue:2, itemType:1, score:100}, 30),
                new Phase(LineEnemyA, {fromX:W+50, fromY:50, toX:-50, toY:50, time:5, hp:1, color:2, size:7, interval:90, shot_speed:4, shot_angle:Math.PI/2, itemValue:2, itemType:0, score:100}, 30),
                new Phase(LineEnemyB, {fromX:W+50, fromY:50, toX:-50, toY:50, time:5, hp:1, color:2, size:7, interval:90, shot_speed:4, shot_angle:Math.PI/2, itemValue:2, itemType:1, score:100}, 30),
                new Phase(LineEnemyA, {fromX:W+50, fromY:50, toX:-50, toY:50, time:5, hp:1, color:3, size:7, interval:90, shot_speed:4, shot_angle:Math.PI/2, itemValue:2, itemType:0, score:100}, 30),
                new Phase(LineEnemyB, {fromX:W+50, fromY:50, toX:-50, toY:50, time:5, hp:1, color:3, size:7, interval:90, shot_speed:4, shot_angle:Math.PI/2, itemValue:2, itemType:1, score:100}, 30),
                
                //ボス
                new Phase(Text, {x:W/2, y:H/2, fontSize:50, text:"Boss", time:120}, -1),    
                new Phase(Boss01, {fromX:W/2, fromY:-50, toX:W/2, toY:H/2-100, time:3, hp:80, color:0, size:15, interval:60, shot_speed:4, shot_angle:Math.PI/2, n:9, angle_range:Math.PI*2, angle_speed:Math.PI/10, itemValue:2, itemType:2, score:3000}, 30),
                
                new Phase(WallCommand, {type:WallCommand.DELETE, index:0}, -1),
                new Phase(WallCommand, {type:WallCommand.DELETE, index:1}, -1),
                new Phase(WallCommand, {type:WallCommand.DELETE, index:2}, -1),
                
                
                //Stage2
                new Phase(Text, {x:W/2, y:H/2, fontSize:50, text:"Stage2", time:120}, 30),
                new Phase(LineRepeatWall, {x:50, y:H/2, X:[W-50,50], Y:[H/2, H/2], T:[5,5], w:100, color:1, angle:Math.PI/2, vr:0.01}, 120),
                
                //通常敵1
                //赤
                new Phase(LineEnemyA, {fromX:W/2+150, fromY:-50, toX:W/2+150, toY:500, time:5, hp:1, color:1, size:7, interval:60, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 60),
                new Phase(LineEnemyB, {fromX:W/2+100, fromY:-50, toX:W/2+100, toY:500, time:5, hp:1, color:1, size:7, interval:60, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 30),
                new Phase(LineEnemyA, {fromX:W/2+50,  fromY:-50, toX:W/2+50,  toY:500, time:5, hp:1, color:1, size:7, interval:60, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 30),
                new Phase(LineEnemyB, {fromX:W/2,     fromY:-50, toX:W/2,     toY:500, time:5, hp:1, color:1, size:7, interval:60, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 30),
                new Phase(LineEnemyA, {fromX:W/2-50,  fromY:-50, toX:W/2-50,  toY:500, time:5, hp:1, color:1, size:7, interval:60, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 30),
                new Phase(LineEnemyB, {fromX:W/2-100, fromY:-50, toX:W/2-100, toY:500, time:5, hp:1, color:1, size:7, interval:60, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 30),
                new Phase(LineEnemyA, {fromX:W/2-150, fromY:-50, toX:W/2-150, toY:500, time:5, hp:1, color:1, size:7, interval:60, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 30),
                
                new Phase(LineEnemyA, {fromX:-50, fromY:100, toX:W+100, toY:100, time:5, hp:1, color:1, size:7, interval:60, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 60),
                new Phase(LineEnemyA, {fromX:-50, fromY:100, toX:W+100, toY:100, time:5, hp:1, color:1, size:7, interval:60, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 60),
                new Phase(LineEnemyA, {fromX:-50, fromY:100, toX:W+100, toY:100, time:5, hp:1, color:1, size:7, interval:60, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 60),
                new Phase(LineEnemyB, {fromX:W+50,     fromY:50, toX:-50,     toY:50, time:5, hp:1, color:1, size:7, interval:60, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 60),
                new Phase(LineEnemyB, {fromX:W+50,     fromY:50, toX:-50,     toY:50, time:5, hp:1, color:1, size:7, interval:60, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 60),
                new Phase(LineEnemyB, {fromX:W+50,     fromY:50, toX:-50,     toY:50, time:5, hp:1, color:1, size:7, interval:60, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 60),
                
                //緑
                new Phase(WallCommand, {type:WallCommand.CHANGE_COLOR, index:0, color:2}, -1),
                new Phase(LineEnemyB, {fromX:W/2+150, fromY:-50, toX:W/2+150, toY:500, time:8, hp:1, color:2, size:7, interval:80, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 60),
                new Phase(LineEnemyB, {fromX:W/2+100, fromY:-50, toX:W/2+100, toY:500, time:8, hp:1, color:2, size:7, interval:80, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 0),
                new Phase(LineEnemyB, {fromX:W/2+50,  fromY:-50, toX:W/2+50,  toY:500, time:8, hp:1, color:2, size:7, interval:80, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 0),
                new Phase(LineEnemyB, {fromX:W/2,     fromY:-50, toX:W/2,     toY:500, time:8, hp:1, color:2, size:7, interval:60, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 0),
                new Phase(LineEnemyB, {fromX:W/2-50,  fromY:-50, toX:W/2-50,  toY:500, time:8, hp:1, color:2, size:7, interval:80, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 0),
                new Phase(LineEnemyB, {fromX:W/2-100, fromY:-50, toX:W/2-100, toY:500, time:8, hp:1, color:2, size:7, interval:80, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 0),
                new Phase(LineEnemyB, {fromX:W/2-150, fromY:-50, toX:W/2-150, toY:500, time:8, hp:1, color:2, size:7, interval:80, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 0),
                
                new Phase(LineEnemyB, {fromX:-50, fromY:50,  toX:W+50, toY:50,  time:5, hp:1, color:2, size:7, interval:80, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 180),
                new Phase(LineEnemyB, {fromX:-50, fromY:90,  toX:W+50, toY:90,  time:5, hp:1, color:2, size:7, interval:70, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 0),
                new Phase(LineEnemyB, {fromX:-50, fromY:130, toX:W+50, toY:130, time:5, hp:1, color:2, size:7, interval:80, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 0),
                new Phase(LineEnemyB, {fromX:-50, fromY:170, toX:W+50, toY:170, time:5, hp:1, color:2, size:7, interval:70, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 0),
                
                new Phase(LineEnemyB, {fromX:W+50, fromY:70,  toX:-50, toY:70,  time:5, hp:1, color:2, size:7, interval:80, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 120),
                new Phase(LineEnemyB, {fromX:W+50, fromY:110, toX:-50, toY:110, time:5, hp:1, color:2, size:7, interval:70, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 0),
                new Phase(LineEnemyB, {fromX:W+50, fromY:150, toX:-50, toY:150, time:5, hp:1, color:2, size:7, interval:80, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 0),
                new Phase(LineEnemyB, {fromX:W+50, fromY:190, toX:-50, toY:190, time:5, hp:1, color:2, size:7, interval:70, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 0),
                
                //青
                new Phase(WallCommand, {type:WallCommand.CHANGE_COLOR, index:0, color:3}, -1),
                new Phase(LineEnemyA, {fromX:-50, fromY:50,  toX:W+50, toY:50,  time:5, hp:1, color:3, size:7, interval:60, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 60),
                new Phase(LineEnemyA, {fromX:W+50, fromY:70,  toX:-50, toY:70,  time:5, hp:1, color:3, size:7, interval:60, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 30),
                new Phase(LineEnemyA, {fromX:-50, fromY:90,  toX:W+50, toY:90,  time:5, hp:1, color:3, size:7, interval:60, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 30),
                new Phase(LineEnemyA, {fromX:W+50, fromY:110, toX:-50, toY:110, time:5, hp:1, color:3, size:7, interval:60, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 30),
                new Phase(LineEnemyA, {fromX:-50, fromY:130, toX:W+50, toY:130, time:5, hp:1, color:3, size:7, interval:60, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 30),
                new Phase(LineEnemyA, {fromX:W+50, fromY:150, toX:-50, toY:150, time:5, hp:1, color:3, size:7, interval:60, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 30),
                
                new Phase(LineEnemyB, {fromX:W/2+150, fromY:-50, toX:W/2+150, toY:500, time:8, hp:1, color:3, size:7, interval:80, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 120),
                new Phase(LineEnemyA, {fromX:W/2+100, fromY:-50, toX:W/2+100, toY:500, time:8, hp:1, color:3, size:7, interval:80, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 0),
                new Phase(LineEnemyB, {fromX:W/2+50,  fromY:-50, toX:W/2+50,  toY:500, time:8, hp:1, color:3, size:7, interval:80, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 0),
                new Phase(LineEnemyA, {fromX:W/2,     fromY:-50, toX:W/2,     toY:500, time:8, hp:1, color:3, size:7, interval:60, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 0),
                new Phase(LineEnemyB, {fromX:W/2-50,  fromY:-50, toX:W/2-50,  toY:500, time:8, hp:1, color:3, size:7, interval:80, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 0),
                new Phase(LineEnemyA, {fromX:W/2-100, fromY:-50, toX:W/2-100, toY:500, time:8, hp:1, color:3, size:7, interval:80, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 0),
                new Phase(LineEnemyB, {fromX:W/2-150, fromY:-50, toX:W/2-150, toY:500, time:8, hp:1, color:3, size:7, interval:80, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 0),
                
                //中ボス
                new Phase(Wall, {x:W/2+100, y:100, w:100, color:1, angle:Math.PI/2, vr:0.01}, -1),
                new Phase(Wall, {x:W/2-100, y:100, w:100, color:2, angle:Math.PI/2, vr:0.01}, -1),
                new Phase(LineEnemyD, {fromX:W/2-100, fromY:-50, toX:W/2-100, toY:150, time:2, hp:10, color:2, size:15, interval:60, shot_speed:3, shot_angle:Math.PI/2, n:5, angle_range:Math.PI*2, angle_speed:0.2, itemValue:1, itemType:2, score:500}, 120),
                new Phase(LineEnemyC, {fromX:W/2+100, fromY:-50, toX:W/2+100, toY:150, time:2, hp:10, color:1, size:15, interval:30,  shot_speed:3, shot_angle:Math.PI/2, n:5, angle_range:Math.PI*2, angle_speed:0.3, itemValue:5, itemType:0, score:500}, 0),
                new Phase(LineEnemyD, {fromX:W/2,     fromY:-50, toX:W/2,     toY:150, time:2, hp:10, color:3, size:15, interval:60,  shot_speed:3, shot_angle:Math.PI/2, n:5, angle_range:Math.PI*2, angle_speed:0.4, itemValue:5, itemType:1, score:500}, 0),
                
                //赤
                new Phase(LineEnemyA, {fromX:W/2+150, fromY:-50, toX:W/2+150, toY:500, time:5, hp:1, color:1, size:7, interval:60, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, -1),
                new Phase(LineEnemyB, {fromX:W/2+100, fromY:-50, toX:W/2+100, toY:500, time:5, hp:1, color:1, size:7, interval:60, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 30),
                new Phase(LineEnemyA, {fromX:W/2+50,  fromY:-50, toX:W/2+50,  toY:500, time:5, hp:1, color:1, size:7, interval:60, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 30),
                new Phase(LineEnemyB, {fromX:W/2,     fromY:-50, toX:W/2,     toY:500, time:5, hp:1, color:1, size:7, interval:60, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 30),
                new Phase(LineEnemyA, {fromX:W/2-50,  fromY:-50, toX:W/2-50,  toY:500, time:5, hp:1, color:1, size:7, interval:60, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 30),
                new Phase(LineEnemyB, {fromX:W/2-100, fromY:-50, toX:W/2-100, toY:500, time:5, hp:1, color:1, size:7, interval:60, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 30),
                new Phase(LineEnemyA, {fromX:W/2-150, fromY:-50, toX:W/2-150, toY:500, time:5, hp:1, color:1, size:7, interval:60, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 30),
                
                new Phase(LineEnemyA, {fromX:-50, fromY:100, toX:W+50, toY:100, time:5, hp:1, color:1, size:7, interval:60, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 60),
                new Phase(LineEnemyA, {fromX:-50, fromY:100, toX:W+50, toY:100, time:5, hp:1, color:1, size:7, interval:60, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 60),
                new Phase(LineEnemyA, {fromX:-50, fromY:100, toX:W+50, toY:100, time:5, hp:1, color:1, size:7, interval:60, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 60),
                new Phase(LineEnemyB, {fromX:W+50,     fromY:50, toX:-50,     toY:50, time:5, hp:1, color:1, size:7, interval:60, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 60),
                new Phase(LineEnemyB, {fromX:W+50,     fromY:50, toX:-50,     toY:50, time:5, hp:1, color:1, size:7, interval:60, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 60),
                new Phase(LineEnemyB, {fromX:W+50,     fromY:50, toX:-50,     toY:50, time:5, hp:1, color:1, size:7, interval:60, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 60),
                
                //緑
                new Phase(LineEnemyB, {fromX:W/2+150, fromY:-50, toX:W/2+150, toY:500, time:8, hp:1, color:2, size:7, interval:80, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 60),
                new Phase(LineEnemyB, {fromX:W/2+100, fromY:-50, toX:W/2+100, toY:500, time:8, hp:1, color:2, size:7, interval:80, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 0),
                new Phase(LineEnemyB, {fromX:W/2+50,  fromY:-50, toX:W/2+50,  toY:500, time:8, hp:1, color:2, size:7, interval:80, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 0),
                new Phase(LineEnemyB, {fromX:W/2,     fromY:-50, toX:W/2,     toY:500, time:8, hp:1, color:2, size:7, interval:60, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 0),
                new Phase(LineEnemyB, {fromX:W/2-50,  fromY:-50, toX:W/2-50,  toY:500, time:8, hp:1, color:2, size:7, interval:80, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 0),
                new Phase(LineEnemyB, {fromX:W/2-100, fromY:-50, toX:W/2-100, toY:500, time:8, hp:1, color:2, size:7, interval:80, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 0),
                new Phase(LineEnemyB, {fromX:W/2-150, fromY:-50, toX:W/2-150, toY:500, time:8, hp:1, color:2, size:7, interval:80, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 0),
                
                new Phase(LineEnemyB, {fromX:-50, fromY:50,  toX:W+50, toY:50,  time:5, hp:1, color:2, size:7, interval:80, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 180),
                new Phase(LineEnemyB, {fromX:-50, fromY:90,  toX:W+50, toY:90,  time:5, hp:1, color:2, size:7, interval:70, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 0),
                new Phase(LineEnemyB, {fromX:-50, fromY:130, toX:W+50, toY:130, time:5, hp:1, color:2, size:7, interval:80, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 0),
                new Phase(LineEnemyB, {fromX:-50, fromY:170, toX:W+50, toY:170, time:5, hp:1, color:2, size:7, interval:70, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 0),
                
                new Phase(LineEnemyB, {fromX:W+50, fromY:70,  toX:-50, toY:70,  time:5, hp:1, color:2, size:7, interval:80, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 120),
                new Phase(LineEnemyB, {fromX:W+50, fromY:110, toX:-50, toY:110, time:5, hp:1, color:2, size:7, interval:70, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 0),
                new Phase(LineEnemyB, {fromX:W+50, fromY:150, toX:-50, toY:150, time:5, hp:1, color:2, size:7, interval:80, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 0),
                new Phase(LineEnemyB, {fromX:W+50, fromY:190, toX:-50, toY:190, time:5, hp:1, color:2, size:7, interval:70, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 0),
                
                //青
                new Phase(LineEnemyA, {fromX:-50, fromY:50,  toX:W+50, toY:50,  time:5, hp:1, color:3, size:7, interval:60, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 60),
                new Phase(LineEnemyA, {fromX:W+50, fromY:70,  toX:-50, toY:70,  time:5, hp:1, color:3, size:7, interval:60, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 30),
                new Phase(LineEnemyA, {fromX:-50, fromY:90,  toX:W+50, toY:90,  time:5, hp:1, color:3, size:7, interval:60, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 30),
                new Phase(LineEnemyA, {fromX:W+50, fromY:110, toX:-50, toY:110, time:5, hp:1, color:3, size:7, interval:60, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 30),
                new Phase(LineEnemyA, {fromX:-50, fromY:130, toX:W+50, toY:130, time:5, hp:1, color:3, size:7, interval:60, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 30),
                new Phase(LineEnemyA, {fromX:W+50, fromY:150, toX:-50, toY:150, time:5, hp:1, color:3, size:7, interval:60, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 30),
                
                new Phase(LineEnemyB, {fromX:W/2+150, fromY:-50, toX:W/2+150, toY:500, time:8, hp:1, color:3, size:7, interval:80, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 120),
                new Phase(LineEnemyA, {fromX:W/2+100, fromY:-50, toX:W/2+100, toY:500, time:8, hp:1, color:3, size:7, interval:80, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 0),
                new Phase(LineEnemyB, {fromX:W/2+50,  fromY:-50, toX:W/2+50,  toY:500, time:8, hp:1, color:3, size:7, interval:80, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 0),
                new Phase(LineEnemyA, {fromX:W/2,     fromY:-50, toX:W/2,     toY:500, time:8, hp:1, color:3, size:7, interval:60, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 0),
                new Phase(LineEnemyB, {fromX:W/2-50,  fromY:-50, toX:W/2-50,  toY:500, time:8, hp:1, color:3, size:7, interval:80, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 0),
                new Phase(LineEnemyA, {fromX:W/2-100, fromY:-50, toX:W/2-100, toY:500, time:8, hp:1, color:3, size:7, interval:80, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 0),
                new Phase(LineEnemyB, {fromX:W/2-150, fromY:-50, toX:W/2-150, toY:500, time:8, hp:1, color:3, size:7, interval:80, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 0),
                
                //ボス
                new Phase(Text, {x:W/2, y:H/2, fontSize:50, text:"Boss", time:120}, -1),    
                new Phase(Boss02, {fromX:W/2, fromY:-50, toX:W/2, toY:H/2-100, time:3, hp:120, color:0, size:15, interval:20, shot_speed:4, shot_angle:Math.PI/2, n:3, angle_range:Math.PI*2, angle_speed:0.1, itemValue:2, itemType:2, score:5000}, 30),
                
                new Phase(WallCommand, {type:WallCommand.DELETE, index:0}, -1),
                new Phase(WallCommand, {type:WallCommand.DELETE, index:1}, -1),
                new Phase(WallCommand, {type:WallCommand.DELETE, index:2}, -1),
                
                //Stage3
                new Phase(Text, {x:W/2, y:H/2, fontSize:50, text:"Stage3", time:120}, 30),
                
                new Phase(Wall, {x:W/2+100, y:H/2, w:100, color:1, angle:0, vr:0.01}, 60),
                new Phase(Wall, {x:W/2, y:H/2, w:100, color:2, angle:Math.PI*2/3, vr:0.01}, 0),
                new Phase(Wall, {x:W/2-100, y:H/2, w:100, color:3, angle:Math.PI*4/3, vr:0.01}, 0),
                
                //通常敵1
                new Phase(LineEnemyC, {fromX:W/2+100, fromY:-50, toX:W/2+100, toY:500, time:5, hp:1, color:2, size:7, interval:90, shot_speed:4, shot_angle:Math.PI/2, n:3, angle_range:Math.PI/2, angle_speed:0, itemValue:1, itemType:0, score:100}, 120),
                new Phase(LineEnemyC, {fromX:W/2-100, fromY:-50, toX:W/2-100, toY:500, time:5, hp:1, color:2, size:7, interval:90, shot_speed:4, shot_angle:Math.PI/2, n:3, angle_range:Math.PI/2, angle_speed:0, itemValue:1, itemType:1, score:100}, 60),
                new Phase(LineEnemyC, {fromX:W/2-50,  fromY:-50, toX:W/2-50,  toY:500, time:5, hp:1, color:2, size:7, interval:90, shot_speed:4, shot_angle:Math.PI/2, n:3, angle_range:Math.PI/2, angle_speed:0, itemValue:1, itemType:0, score:100}, 60),
                new Phase(LineEnemyC, {fromX:W/2+50,  fromY:-50, toX:W/2+50,  toY:500, time:5, hp:1, color:2, size:7, interval:90, shot_speed:4, shot_angle:Math.PI/2, n:3, angle_range:Math.PI/2, angle_speed:0, itemValue:1, itemType:1, score:100}, 60),
                new Phase(LineEnemyC, {fromX:W/2,     fromY:-50, toX:W/2,     toY:500, time:5, hp:1, color:2, size:7, interval:90, shot_speed:4, shot_angle:Math.PI/2, n:3, angle_range:Math.PI/2, angle_speed:0, itemValue:1, itemType:0, score:100}, 60),
                
                new Phase(LineEnemyC, {fromX:W/2+100, fromY:-50, toX:W/2+100, toY:500, time:5, hp:1, color:1, size:7, interval:90, shot_speed:4, shot_angle:Math.PI/2, n:5, angle_range:Math.PI*2, angle_speed:0.1, itemValue:1, itemType:1, score:100}, 120),
                new Phase(LineEnemyC, {fromX:W/2-100, fromY:-50, toX:W/2-100, toY:500, time:5, hp:1, color:1, size:7, interval:90, shot_speed:4, shot_angle:Math.PI/2, n:5, angle_range:Math.PI*2, angle_speed:0.2, itemValue:1, itemType:0, score:100}, 60),
                new Phase(LineEnemyC, {fromX:W/2-50,  fromY:-50, toX:W/2-50,  toY:500, time:5, hp:1, color:1, size:7, interval:90, shot_speed:4, shot_angle:Math.PI/2, n:5, angle_range:Math.PI*2, angle_speed:0.3, itemValue:1, itemType:1, score:100}, 60),
                new Phase(LineEnemyC, {fromX:W/2+50,  fromY:-50, toX:W/2+50,  toY:500, time:5, hp:1, color:1, size:7, interval:90, shot_speed:4, shot_angle:Math.PI/2, n:5, angle_range:Math.PI*2, angle_speed:0.4, itemValue:1, itemType:0, score:100}, 60),
                new Phase(LineEnemyC, {fromX:W/2,     fromY:-50, toX:W/2,     toY:500, time:5, hp:1, color:1, size:7, interval:90, shot_speed:4, shot_angle:Math.PI/2, n:5, angle_range:Math.PI*2, angle_speed:0.5, itemValue:1, itemType:1, score:100}, 60),
                
                new Phase(LineEnemyC, {fromX:W/2+100, fromY:-50, toX:W/2+100, toY:500, time:5, hp:1, color:3, size:7, interval:90, shot_speed:4, shot_angle:Math.PI/2, n:5, angle_range:Math.PI/2, angle_speed:0, itemValue:1, itemType:1, score:100}, 120),
                new Phase(LineEnemyC, {fromX:W/2-100, fromY:-50, toX:W/2-100, toY:500, time:5, hp:1, color:3, size:7, interval:90, shot_speed:4, shot_angle:Math.PI/2, n:5, angle_range:Math.PI/2, angle_speed:0, itemValue:1, itemType:0, score:100}, 60),
                new Phase(LineEnemyC, {fromX:W/2-50,  fromY:-50, toX:W/2-50,  toY:500, time:5, hp:1, color:3, size:7, interval:90, shot_speed:4, shot_angle:Math.PI/2, n:5, angle_range:Math.PI/2, angle_speed:0, itemValue:1, itemType:1, score:100}, 60),
                new Phase(LineEnemyC, {fromX:W/2+50,  fromY:-50, toX:W/2+50,  toY:500, time:5, hp:1, color:3, size:7, interval:90, shot_speed:4, shot_angle:Math.PI/2, n:5, angle_range:Math.PI/2, angle_speed:0, itemValue:1, itemType:0, score:100}, 60),
                new Phase(LineEnemyC, {fromX:W/2,     fromY:-50, toX:W/2,     toY:500, time:5, hp:1, color:3, size:7, interval:90, shot_speed:4, shot_angle:Math.PI/2, n:5, angle_range:Math.PI/2, angle_speed:0, itemValue:1, itemType:1, score:100}, 60),
                
                //中ボス
                new Phase(LineEnemyA, {fromX:W/2-100, fromY:-50,  toX:W/2-100, toY:80,  time:3, hp:30, color:1, size:15, interval:10, shot_speed:4, shot_angle:0.65, itemValue:5, itemType:0, score:1000}, -1),
                new Phase(LineEnemyA, {fromX:W/2+100, fromY:-50,  toX:W/2+100, toY:80,  time:3, hp:30, color:3, size:15, interval:10, shot_speed:4, shot_angle: 2.5, itemValue:5, itemType:1, score:1000}, 0),
                new Phase(LineEnemyC, {fromX:W/2+100, fromY:-50, toX:W/2+100, toY:80, time:3, hp:30, color:2, size:15, interval:15, shot_speed:4, shot_angle:Math.PI/2, n:8, angle_range:2*Math.PI, angle_speed:0.2, itemValue:1, itemType:2, score:1000}, -1),
                new Phase(LineEnemyD, {fromX:W/2-100, fromY:-50, toX:W/2-100, toY:80, time:3, hp:30, color:2, size:15, interval:15, shot_speed:4, shot_angle:Math.PI/2, n:8, angle_range:2*Math.PI, angle_speed:0, itemValue:1, itemType:2, score:1000}, 0),
                
                //通常敵2
                new Phase(LineEnemyA, {fromX:-50, fromY:100, toX:W+50, toY:100, time:5, hp:1, color:1, size:7, interval:60, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, -1),
                new Phase(LineEnemyB, {fromX:-50, fromY:100, toX:W+50, toY:100, time:5, hp:1, color:1, size:7, interval:60, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 30),
                new Phase(LineEnemyA, {fromX:-50, fromY:100, toX:W+50, toY:100, time:5, hp:1, color:1, size:7, interval:60, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 30),
                new Phase(LineEnemyB, {fromX:-50, fromY:100, toX:W+50, toY:100, time:5, hp:1, color:2, size:7, interval:60, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 30),
                new Phase(LineEnemyA, {fromX:-50, fromY:100, toX:W+50, toY:100, time:5, hp:1, color:2, size:7, interval:60, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 30),
                new Phase(LineEnemyB, {fromX:-50, fromY:100, toX:W+50, toY:100, time:5, hp:1, color:2, size:7, interval:60, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 30),
                
                new Phase(LineEnemyA, {fromX:W+50, fromY:50, toX:-50, toY:50, time:5, hp:1, color:3, size:7, interval:60, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 90),
                new Phase(LineEnemyB, {fromX:W+50, fromY:50, toX:-50, toY:50, time:5, hp:1, color:3, size:7, interval:60, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 30),
                new Phase(LineEnemyA, {fromX:W+50, fromY:50, toX:-50, toY:50, time:5, hp:1, color:3, size:7, interval:60, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 30),
                new Phase(LineEnemyB, {fromX:W+50, fromY:50, toX:-50, toY:50, time:5, hp:1, color:1, size:7, interval:60, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 30),
                new Phase(LineEnemyA, {fromX:W+50, fromY:50, toX:-50, toY:50, time:5, hp:1, color:1, size:7, interval:60, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 30),
                new Phase(LineEnemyB, {fromX:W+50, fromY:50, toX:-50, toY:50, time:5, hp:1, color:1, size:7, interval:60, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 30),
                
                new Phase(LineEnemyA, {fromX:-50, fromY:100, toX:W+50, toY:100, time:5, hp:1, color:2, size:7, interval:90, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 90),
                new Phase(LineEnemyB, {fromX:-50, fromY:100, toX:W+50, toY:100, time:5, hp:1, color:2, size:7, interval:90, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 30),
                new Phase(LineEnemyA, {fromX:-50, fromY:100, toX:W+50, toY:100, time:5, hp:1, color:2, size:7, interval:90, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 30),
                new Phase(LineEnemyB, {fromX:-50, fromY:100, toX:W+50, toY:100, time:5, hp:1, color:3, size:7, interval:90, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 30),
                new Phase(LineEnemyA, {fromX:-50, fromY:100, toX:W+50, toY:100, time:5, hp:1, color:3, size:7, interval:90, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 30),
                new Phase(LineEnemyB, {fromX:-50, fromY:100, toX:W+50, toY:100, time:5, hp:1, color:3, size:7, interval:90, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 30),
                
                new Phase(LineEnemyA, {fromX:W+50, fromY:50, toX:-50, toY:50, time:5, hp:1, color:1, size:7, interval:90, shot_speed:4, shot_angle:Math.PI/2, itemValue:2, itemType:0, score:100}, 90),
                new Phase(LineEnemyB, {fromX:W+50, fromY:50, toX:-50, toY:50, time:5, hp:1, color:2, size:7, interval:90, shot_speed:4, shot_angle:Math.PI/2, itemValue:2, itemType:1, score:100}, 30),
                new Phase(LineEnemyA, {fromX:W+50, fromY:50, toX:-50, toY:50, time:5, hp:1, color:3, size:7, interval:90, shot_speed:4, shot_angle:Math.PI/2, itemValue:2, itemType:0, score:100}, 30),
                new Phase(LineEnemyB, {fromX:W+50, fromY:50, toX:-50, toY:50, time:5, hp:1, color:1, size:7, interval:90, shot_speed:4, shot_angle:Math.PI/2, itemValue:2, itemType:1, score:100}, 30),
                new Phase(LineEnemyA, {fromX:W+50, fromY:50, toX:-50, toY:50, time:5, hp:1, color:2, size:7, interval:90, shot_speed:4, shot_angle:Math.PI/2, itemValue:2, itemType:0, score:100}, 30),
                new Phase(LineEnemyB, {fromX:W+50, fromY:50, toX:-50, toY:50, time:5, hp:1, color:3, size:7, interval:90, shot_speed:4, shot_angle:Math.PI/2, itemValue:2, itemType:1, score:100}, 30),
                
                //ボス
                new Phase(Text, {x:W/2, y:H/2, fontSize:50, text:"Boss", time:120}, -1),
                new Phase(Boss03, {fromX:W/2, fromY:-50, toX:W/2, toY:100, time:3, hp:80, color:0, size:15, interval:80, shot_speed:2, shot_angle:Math.PI/2, n:6, angle_range:Math.PI*2, angle_speed:Math.PI/10, gravity:0.1, itemValue:2, itemType:2, score:10000}, 30),
                
                new Phase(WallCommand, {type:WallCommand.DELETE, index:0}, -1),
                new Phase(WallCommand, {type:WallCommand.DELETE, index:1}, -1),
                new Phase(WallCommand, {type:WallCommand.DELETE, index:2}, -1),
                
                //Stage4
                new Phase(Text, {x:W/2, y:H/2, fontSize:50, text:"Stage4", time:120}, 30),
                
                new Phase(LineRepeatWall, {x:50, y:50,     X:[W-50,W-50,50,50], Y:[50,H-50,H-50,50], T:[5,5,5,5], w:100, color:1, angle:Math.PI/2, vr:0.01}, 120),
                new Phase(LineRepeatWall, {x:W-50, y:H-50, X:[50,50,W-50,W-50], Y:[H-50,50,50,H-50], T:[5,5,5,5], w:100, color:3, angle:Math.PI/2, vr:0.01}, 0),
                new Phase(LineRepeatWall, {x:W-50, y:H/2, X:[50,W-50], Y:[H/2,H/2], T:[5,5], w:100, color:2, angle:Math.PI/2, vr:0.01}, 0),
                
                new Phase(LineEnemyA, {fromX:W/10*1, fromY:-50, toX:W/10*1, toY:500, time:5, hp:1, color:1, size:7, interval:60, shot_speed:5, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 60),
                new Phase(LineEnemyA, {fromX:W/10*2, fromY:-50, toX:W/10*2, toY:500, time:5, hp:1, color:1, size:7, interval:60, shot_speed:5, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 15),
                new Phase(LineEnemyA, {fromX:W/10*3, fromY:-50, toX:W/10*3, toY:500, time:5, hp:1, color:1, size:7, interval:60, shot_speed:5, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 15),
                new Phase(LineEnemyA, {fromX:W/10*4, fromY:-50, toX:W/10*4, toY:500, time:5, hp:1, color:1, size:7, interval:60, shot_speed:5, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 15),
                new Phase(LineEnemyA, {fromX:W/10*5, fromY:-50, toX:W/10*5, toY:500, time:5, hp:1, color:1, size:7, interval:60, shot_speed:5, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 15),
                new Phase(LineEnemyA, {fromX:W/10*6, fromY:-50, toX:W/10*6, toY:500, time:5, hp:1, color:1, size:7, interval:60, shot_speed:5, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 15),
                new Phase(LineEnemyA, {fromX:W/10*7, fromY:-50, toX:W/10*7, toY:500, time:5, hp:1, color:1, size:7, interval:60, shot_speed:5, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 15),
                new Phase(LineEnemyA, {fromX:W/10*8, fromY:-50, toX:W/10*8, toY:500, time:5, hp:1, color:1, size:7, interval:60, shot_speed:5, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 15),
                new Phase(LineEnemyA, {fromX:W/10*9, fromY:-50, toX:W/10*9, toY:500, time:5, hp:1, color:1, size:7, interval:60, shot_speed:5, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 15),
                
                new Phase(LineEnemyA, {fromX:W/10*1, fromY:-50, toX:W/10*1, toY:500, time:5, hp:1, color:2, size:7, interval:50, shot_speed:5, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 20),
                new Phase(LineEnemyA, {fromX:W/10*2, fromY:-50, toX:W/10*2, toY:500, time:5, hp:1, color:2, size:7, interval:50, shot_speed:5, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 15),
                new Phase(LineEnemyA, {fromX:W/10*3, fromY:-50, toX:W/10*3, toY:500, time:5, hp:1, color:2, size:7, interval:50, shot_speed:5, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 15),
                new Phase(LineEnemyA, {fromX:W/10*4, fromY:-50, toX:W/10*4, toY:500, time:5, hp:1, color:2, size:7, interval:50, shot_speed:5, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 15),
                new Phase(LineEnemyA, {fromX:W/10*5, fromY:-50, toX:W/10*5, toY:500, time:5, hp:1, color:2, size:7, interval:50, shot_speed:5, shot_angle:Math.PI/2, itemValue:1, itemType:2, score:100}, 15),
                new Phase(LineEnemyA, {fromX:W/10*6, fromY:-50, toX:W/10*6, toY:500, time:5, hp:1, color:2, size:7, interval:50, shot_speed:5, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 15),
                new Phase(LineEnemyA, {fromX:W/10*7, fromY:-50, toX:W/10*7, toY:500, time:5, hp:1, color:2, size:7, interval:50, shot_speed:5, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 15),
                new Phase(LineEnemyA, {fromX:W/10*8, fromY:-50, toX:W/10*8, toY:500, time:5, hp:1, color:2, size:7, interval:50, shot_speed:5, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 15),
                new Phase(LineEnemyA, {fromX:W/10*9, fromY:-50, toX:W/10*9, toY:500, time:5, hp:1, color:2, size:7, interval:50, shot_speed:5, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 15),
                
                new Phase(LineEnemyA, {fromX:W/10*1, fromY:-50, toX:W/10*1, toY:500, time:5, hp:1, color:3, size:7, interval:40, shot_speed:5, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 20),
                new Phase(LineEnemyA, {fromX:W/10*2, fromY:-50, toX:W/10*2, toY:500, time:5, hp:1, color:3, size:7, interval:40, shot_speed:5, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 15),
                new Phase(LineEnemyA, {fromX:W/10*3, fromY:-50, toX:W/10*3, toY:500, time:5, hp:1, color:3, size:7, interval:40, shot_speed:5, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 15),
                new Phase(LineEnemyA, {fromX:W/10*4, fromY:-50, toX:W/10*4, toY:500, time:5, hp:1, color:3, size:7, interval:40, shot_speed:5, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 15),
                new Phase(LineEnemyA, {fromX:W/10*5, fromY:-50, toX:W/10*5, toY:500, time:5, hp:1, color:3, size:7, interval:40, shot_speed:5, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 15),
                new Phase(LineEnemyA, {fromX:W/10*6, fromY:-50, toX:W/10*6, toY:500, time:5, hp:1, color:3, size:7, interval:40, shot_speed:5, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 15),
                new Phase(LineEnemyA, {fromX:W/10*7, fromY:-50, toX:W/10*7, toY:500, time:5, hp:1, color:3, size:7, interval:40, shot_speed:5, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 15),
                new Phase(LineEnemyA, {fromX:W/10*8, fromY:-50, toX:W/10*8, toY:500, time:5, hp:1, color:3, size:7, interval:40, shot_speed:5, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 15),
                new Phase(LineEnemyA, {fromX:W/10*9, fromY:-50, toX:W/10*9, toY:500, time:5, hp:1, color:3, size:7, interval:40, shot_speed:5, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 15),
                
                //中ボス
                new Phase(LineEnemyC, {fromX:W/2, fromY:-50, toX:W/2, toY:100, time:3, hp:50, color:1, size:15, interval:5, shot_speed:5, shot_angle:Math.PI/2, n:2, angle_range:0, angle_speed:0.5, itemValue:5, itemType:0, score:3000}, -1),
                new Phase(LineEnemyC, {fromX:W/2-100, fromY:-50, toX:W/2-100, toY:100, time:3, hp:30, color:2, size:15, interval:5, shot_speed:5, shot_angle:Math.PI/2, n:2, angle_range:Math.PI*2, angle_speed:0.5, itemValue:1, itemType:2, score:3000}, -1),
                new Phase(LineEnemyC, {fromX:W/2+100, fromY:-50, toX:W/2+100, toY:100, time:3, hp:30, color:2, size:15, interval:5, shot_speed:5, shot_angle:Math.PI/2, n:2, angle_range:Math.PI*2, angle_speed:0.5, itemValue:1, itemType:2, score:3000}, 0),
                new Phase(LineEnemyC, {fromX:W/2, fromY:-50, toX:W/2, toY:100, time:3, hp:80, color:1, size:15, interval:5, shot_speed:5, shot_angle:Math.PI/2, n:4, angle_range:2*Math.PI, angle_speed:0.2, itemValue:5, itemType:1, score:5000}, -1),
                
                //ボス
                new Phase(Text, {x:W/2, y:H/2, fontSize:50, text:"Boss", time:120}, -1),
                new Phase(Boss04, {fromX:W/2, fromY:-50, toX:W/2, toY:H/2-100, time:3, hp:120, color:0, size:15, interval:45, shot_speed:4, shot_angle:Math.PI/2, n:6, angle_range:Math.PI*2, angle_speed:0.1, itemValue:2, itemType:2, score:5000}, 30),
                
                new Phase(WallCommand, {type:WallCommand.DELETE, index:0}, -1),
                new Phase(WallCommand, {type:WallCommand.DELETE, index:1}, -1),
                new Phase(WallCommand, {type:WallCommand.DELETE, index:2}, -1),
                
                new Phase(Text, {x:W/2, y:H/2, fontSize:50, text:"Final Stage", time:120}, 30),
                new Phase(Wall, {x:W/2+1, y:100, w:100, color:1, angle:0, vr:0.01}, 120),
                new Phase(Wall, {x:W/2-100, y:H/2+5, w:100, color:2, angle:0, vr:0.015}, 0),
                new Phase(Wall, {x:W/2+100, y:H/2-5, w:100, color:3, angle:0, vr:0.02}, 0),
                new Phase(Text, {x:W/2, y:H/2, fontSize:50, text:"Boss", time:120}, 0),
                
                //ボス1
                new Phase(Boss05, {fromX:W/2, fromY:-50, toX:W/2, toY:H/2, time:3, hp:100, color:0, size:15, interval:10, shot_speed:4, itemValue:2, itemType:2, score:10000}, 120),
                
                //ボス2
                new Phase(Boss06, {fromX:W/2, fromY:-50, toX:W/2, toY:H/2, time:3, hp:150, color:0, size:15, interval:60, shot_speed:4, itemValue:2, itemType:2, score:10000}, -1),
                
                new Phase(WallCommand, {type:WallCommand.DELETE, index:0}, -1),
                new Phase(WallCommand, {type:WallCommand.DELETE, index:1}, -1),
                new Phase(WallCommand, {type:WallCommand.DELETE, index:2}, -1),
                
                //ラスボス
                new Phase(Wall, {x:60, y:H/4, w:100, color:1, angle:0, vr:0.01}, 120),
                new Phase(Wall, {x:60, y:H/4*2, w:100, color:2, angle:0, vr:-0.02}, 0),
                new Phase(Wall, {x:60, y:H/4*3, w:100, color:3, angle:0, vr:0.03}, 0),
                new Phase(Wall, {x:W-60, y:H/4, w:100, color:2, angle:0, vr:-0.015}, 0),
                new Phase(Wall, {x:W-60, y:H/4*2, w:100, color:3, angle:0, vr:-0.04}, 0),
                new Phase(Wall, {x:W-60, y:H/4*3, w:100, color:1, angle:0, vr:-0.02}, 0),
                
                new Phase(Boss07, {fromX:W/2, fromY:-50, toX:W/2, toY:H/2-100, time:3, hp:200, color:0, size:15, interval:8, shot_speed:4, shot_angle:Math.PI/2, angle_range:Math.PI*2, angle_speed:0.1534, itemValue:2, itemType:2, score:30000}, 30),
                
                new Phase(WallCommand, {type:WallCommand.DELETE, index:0}, -1),
                new Phase(WallCommand, {type:WallCommand.DELETE, index:1}, -1),
                new Phase(WallCommand, {type:WallCommand.DELETE, index:2}, -1),
                new Phase(WallCommand, {type:WallCommand.DELETE, index:3}, -1),
                new Phase(WallCommand, {type:WallCommand.DELETE, index:4}, -1),
                new Phase(WallCommand, {type:WallCommand.DELETE, index:5}, -1),
                
                new Phase(Text, {x:W/2, y:H/2, fontSize:50, text:"Clear", time:60}, -1),
            ]
        );
    }
}

class Stage2 extends BaseStage
{
    public function Stage2(main:Game, id:int)
    {
        super(main, id);
    }
    /*
    fromX   : 始点x座標,
    *   fromY   : 始点y座標,
    *   toX     : 終点x座標,
    *   toY     : 終点y座標,
    *   time    : 移動に要する時間,
    *      hp      : 体力,
    *   color   : 色,
    *   size    : 大きさ,
    *   interval:弾を撃つ間隔,
    *   speed   :弾のスピード,
    *   angle   :弾の発射角度,
    */
    
    /*
    * x:
    * y: 位置
    * color: 壁の色
    * w: 壁の大きさ
    * angle: 角度
    * vr: 壁の角速度
    */
    
    override public function setData():void{
        phase = Vector.<Phase>(
            [
                //Stage1
                new Phase(Text, {x:W/2, y:H/2, fontSize:50, text:"Stage1", time:120}, 30),    
                
                new Phase(LineRepeatWall, {x:30, y:100, X:[30,30], Y:[H-100,100], T:[5,5], w:150, color:1, angle:Math.PI/2, vr:0}, 30),
                new Phase(LineRepeatWall, {x:W-30, y:H-100, X:[W-30,W-30], Y:[100,H-100], T:[5,5], w:150, color:2, angle:Math.PI/2, vr:0}, 0),
                new Phase(LineRepeatWall, {x:50, y:H-30, X:[W-50, 50], Y:[H-30, H-30], T:[5,5], w:150, color:3, angle:0, vr:0}, 0),
                
                //通常敵 1
                new Phase(LineEnemyA, {fromX:W/2,     fromY:-50, toX:W/2,     toY:500, time:5, hp:1, color:1, size:7, interval:60, shot_speed:5, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 60),
                new Phase(LineEnemyB, {fromX:W/2-100, fromY:-50, toX:W/2-100, toY:500, time:5, hp:1, color:1, size:7, interval:60, shot_speed:5, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 60),
                new Phase(LineEnemyA, {fromX:W/2+100, fromY:-50, toX:W/2+100, toY:500, time:5, hp:1, color:1, size:7, interval:60, shot_speed:5, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 60),
                new Phase(LineEnemyB, {fromX:W/2-50,  fromY:-50, toX:W/2-50,  toY:500, time:5, hp:1, color:1, size:7, interval:60, shot_speed:5, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 60),
                new Phase(LineEnemyA, {fromX:W/2+50,  fromY:-50, toX:W/2+50,  toY:500, time:5, hp:1, color:1, size:7, interval:60, shot_speed:5, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 60),
                
                new Phase(LineEnemyB, {fromX:W/2-100, fromY:-50, toX:W/2-100, toY:500, time:5, hp:1, color:2, size:7, interval:60, shot_speed:5, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 120),
                new Phase(LineEnemyA, {fromX:W/2-50,  fromY:-50, toX:W/2-50,  toY:500, time:5, hp:1, color:2, size:7, interval:60, shot_speed:5, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 60),
                new Phase(LineEnemyB, {fromX:W/2,     fromY:-50, toX:W/2,     toY:500, time:5, hp:1, color:2, size:7, interval:60, shot_speed:5, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 60),
                new Phase(LineEnemyA, {fromX:W/2+50,  fromY:-50, toX:W/2+50,  toY:500, time:5, hp:1, color:2, size:7, interval:60, shot_speed:5, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 60),
                new Phase(LineEnemyB, {fromX:W/2+100, fromY:-50, toX:W/2+100, toY:500, time:5, hp:1, color:2, size:7, interval:60, shot_speed:5, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 60),
                
                new Phase(LineEnemyC, {fromX:W/2+100, fromY:-50, toX:W/2+100, toY:500, time:5, hp:1, color:3, size:7, interval:90, shot_speed:4, shot_angle:Math.PI/2, n:3, angle_range:Math.PI/2, angle_speed:0, itemValue:1, itemType:0, score:100}, 120),
                new Phase(LineEnemyC, {fromX:W/2-100, fromY:-50, toX:W/2-100, toY:500, time:5, hp:1, color:3, size:7, interval:90, shot_speed:4, shot_angle:Math.PI/2, n:3, angle_range:Math.PI/2, angle_speed:0, itemValue:1, itemType:1, score:100}, 60),
                new Phase(LineEnemyC, {fromX:W/2-50,  fromY:-50, toX:W/2-50,  toY:500, time:5, hp:1, color:3, size:7, interval:90, shot_speed:4, shot_angle:Math.PI/2, n:3, angle_range:Math.PI/2, angle_speed:0, itemValue:1, itemType:0, score:100}, 60),
                new Phase(LineEnemyC, {fromX:W/2+50,  fromY:-50, toX:W/2+50,  toY:500, time:5, hp:1, color:3, size:7, interval:90, shot_speed:4, shot_angle:Math.PI/2, n:3, angle_range:Math.PI/2, angle_speed:0, itemValue:1, itemType:1, score:100}, 60),
                new Phase(LineEnemyC, {fromX:W/2,     fromY:-50, toX:W/2,     toY:500, time:5, hp:1, color:3, size:7, interval:90, shot_speed:4, shot_angle:Math.PI/2, n:3, angle_range:Math.PI/2, angle_speed:0, itemValue:1, itemType:0, score:100}, 60),
                
                new Phase(LineEnemyA, {fromX:W/2,     fromY:-50, toX:W/2,     toY:500, time:5, hp:1, color:1, size:7, interval:60, shot_speed:5, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 120),
                new Phase(LineEnemyB, {fromX:W/2-100, fromY:-50, toX:W/2-100, toY:500, time:5, hp:1, color:1, size:7, interval:60, shot_speed:5, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 40),
                new Phase(LineEnemyA, {fromX:W/2+100, fromY:-50, toX:W/2+100, toY:500, time:5, hp:1, color:1, size:7, interval:60, shot_speed:5, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 40),
                new Phase(LineEnemyB, {fromX:W/2-50,  fromY:-50, toX:W/2-50,  toY:500, time:5, hp:1, color:1, size:7, interval:60, shot_speed:5, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 40),
                new Phase(LineEnemyA, {fromX:W/2+50,  fromY:-50, toX:W/2+50,  toY:500, time:5, hp:1, color:1, size:7, interval:60, shot_speed:5, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 40),
                
                new Phase(LineEnemyB, {fromX:W/2-100, fromY:-50, toX:W/2-100, toY:500, time:5, hp:1, color:2, size:7, interval:60, shot_speed:5, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 60),
                new Phase(LineEnemyA, {fromX:W/2-50,  fromY:-50, toX:W/2-50,  toY:500, time:5, hp:1, color:2, size:7, interval:60, shot_speed:5, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 40),
                new Phase(LineEnemyB, {fromX:W/2,     fromY:-50, toX:W/2,     toY:500, time:5, hp:1, color:2, size:7, interval:60, shot_speed:5, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 40),
                new Phase(LineEnemyA, {fromX:W/2+50,  fromY:-50, toX:W/2+50,  toY:500, time:5, hp:1, color:2, size:7, interval:60, shot_speed:5, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 40),
                new Phase(LineEnemyB, {fromX:W/2+100, fromY:-50, toX:W/2+100, toY:500, time:5, hp:1, color:2, size:7, interval:60, shot_speed:5, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 40),
                
                new Phase(LineEnemyC, {fromX:W/2+100, fromY:-50, toX:W/2+100, toY:500, time:5, hp:1, color:3, size:7, interval:90, shot_speed:4, shot_angle:Math.PI/2, n:3, angle_range:Math.PI/2, angle_speed:0, itemValue:1, itemType:0, score:100}, 60),
                new Phase(LineEnemyC, {fromX:W/2-100, fromY:-50, toX:W/2-100, toY:500, time:5, hp:1, color:3, size:7, interval:90, shot_speed:4, shot_angle:Math.PI/2, n:3, angle_range:Math.PI/2, angle_speed:0, itemValue:1, itemType:1, score:100}, 40),
                new Phase(LineEnemyC, {fromX:W/2-50,  fromY:-50, toX:W/2-50,  toY:500, time:5, hp:1, color:3, size:7, interval:90, shot_speed:4, shot_angle:Math.PI/2, n:5, angle_range:Math.PI/2, angle_speed:0, itemValue:1, itemType:0, score:100}, 40),
                new Phase(LineEnemyC, {fromX:W/2+50,  fromY:-50, toX:W/2+50,  toY:500, time:5, hp:1, color:3, size:7, interval:90, shot_speed:4, shot_angle:Math.PI/2, n:3, angle_range:Math.PI/2, angle_speed:0, itemValue:1, itemType:1, score:100}, 40),
                new Phase(LineEnemyC, {fromX:W/2,     fromY:-50, toX:W/2,     toY:500, time:5, hp:1, color:3, size:7, interval:90, shot_speed:4, shot_angle:Math.PI/2, n:3, angle_range:Math.PI/2, angle_speed:0, itemValue:1, itemType:0, score:100}, 40),
                
                
                //中ボス
                new Phase(LineEnemyD, {fromX:W/2-100, fromY:-50, toX:W/2-100, toY:150, time:2, hp:20, color:1, size:15, interval:80, shot_speed:4, shot_angle:Math.PI/2, n:5, angle_range:Math.PI/2, angle_speed:0, itemValue:5, itemType:0, score:500}, -1),
                new Phase(LineEnemyD, {fromX:W/2+100, fromY:-50, toX:W/2+100, toY:150, time:2, hp:20, color:2, size:15, interval:80, shot_speed:4, shot_angle:Math.PI/2, n:5, angle_range:Math.PI/2, angle_speed:0, itemValue:1, itemType:2, score:500}, -1),
                new Phase(LineEnemyD, {fromX:W/2,     fromY:-50, toX:W/2,     toY:150, time:2, hp:20, color:3, size:15, interval:60, shot_speed:4, shot_angle:Math.PI/2, n:5, angle_range:Math.PI/2, angle_speed:0, itemValue:5, itemType:1, score:500}, -1),
                
                //通常敵2
                new Phase(LineEnemyA, {fromX:-50, fromY:100, toX:W+50, toY:100, time:5, hp:1, color:1, size:7, interval:40, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, -1),
                new Phase(LineEnemyB, {fromX:-50, fromY:100, toX:W+50, toY:100, time:5, hp:1, color:1, size:7, interval:40, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 30),
                new Phase(LineEnemyA, {fromX:-50, fromY:100, toX:W+50, toY:100, time:5, hp:1, color:1, size:7, interval:40, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 30),
                new Phase(LineEnemyB, {fromX:-50, fromY:100, toX:W+50, toY:100, time:5, hp:1, color:1, size:7, interval:40, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 30),
                new Phase(LineEnemyA, {fromX:-50, fromY:100, toX:W+50, toY:100, time:5, hp:1, color:1, size:7, interval:40, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 30),
                new Phase(LineEnemyB, {fromX:-50, fromY:100, toX:W+50, toY:100, time:5, hp:1, color:1, size:7, interval:40, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 30),
                new Phase(LineEnemyA, {fromX:-50, fromY:100, toX:W+50, toY:100, time:5, hp:1, color:1, size:7, interval:40, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 30),
                new Phase(LineEnemyB, {fromX:-50, fromY:100, toX:W+50, toY:100, time:5, hp:1, color:1, size:7, interval:40, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 30),
                
                new Phase(LineEnemyA, {fromX:W+50, fromY:50, toX:-50, toY:50, time:5, hp:1, color:2, size:7, interval:40, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 90),
                new Phase(LineEnemyB, {fromX:W+50, fromY:50, toX:-50, toY:50, time:5, hp:1, color:2, size:7, interval:40, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 30),
                new Phase(LineEnemyA, {fromX:W+50, fromY:50, toX:-50, toY:50, time:5, hp:1, color:2, size:7, interval:40, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 30),
                new Phase(LineEnemyB, {fromX:W+50, fromY:50, toX:-50, toY:50, time:5, hp:1, color:2, size:7, interval:40, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 30),
                new Phase(LineEnemyA, {fromX:W+50, fromY:50, toX:-50, toY:50, time:5, hp:1, color:2, size:7, interval:40, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 30),
                new Phase(LineEnemyB, {fromX:W+50, fromY:50, toX:-50, toY:50, time:5, hp:1, color:2, size:7, interval:40, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 30),
                new Phase(LineEnemyA, {fromX:W+50, fromY:50, toX:-50, toY:50, time:5, hp:1, color:2, size:7, interval:40, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 30),
                new Phase(LineEnemyB, {fromX:W+50, fromY:50, toX:-50, toY:50, time:5, hp:1, color:2, size:7, interval:40, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 30),
                
                new Phase(LineEnemyA, {fromX:-50, fromY:100, toX:W+50, toY:100, time:5, hp:1, color:3, size:7, interval:70, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 90),
                new Phase(LineEnemyB, {fromX:-50, fromY:100, toX:W+50, toY:100, time:5, hp:1, color:3, size:7, interval:60, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 30),
                new Phase(LineEnemyA, {fromX:-50, fromY:100, toX:W+50, toY:100, time:5, hp:1, color:3, size:7, interval:70, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 30),
                new Phase(LineEnemyB, {fromX:-50, fromY:100, toX:W+50, toY:100, time:5, hp:1, color:3, size:7, interval:60, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 30),
                new Phase(LineEnemyA, {fromX:-50, fromY:100, toX:W+50, toY:100, time:5, hp:1, color:3, size:7, interval:60, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 30),
                new Phase(LineEnemyB, {fromX:-50, fromY:100, toX:W+50, toY:100, time:5, hp:1, color:3, size:7, interval:70, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 30),
                new Phase(LineEnemyA, {fromX:-50, fromY:100, toX:W+50, toY:100, time:5, hp:1, color:3, size:7, interval:60, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 30),
                new Phase(LineEnemyB, {fromX:-50, fromY:100, toX:W+50, toY:100, time:5, hp:1, color:3, size:7, interval:70, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 30),
                
                new Phase(LineEnemyA, {fromX:W+50, fromY:50, toX:-50, toY:50, time:5, hp:1, color:1, size:7, interval:70, shot_speed:4, shot_angle:Math.PI/2, itemValue:2, itemType:0, score:100}, 90),
                new Phase(LineEnemyB, {fromX:W+50, fromY:50, toX:-50, toY:50, time:5, hp:1, color:1, size:7, interval:60, shot_speed:4, shot_angle:Math.PI/2, itemValue:2, itemType:1, score:100}, 30),
                new Phase(LineEnemyA, {fromX:W+50, fromY:50, toX:-50, toY:50, time:5, hp:1, color:2, size:7, interval:70, shot_speed:4, shot_angle:Math.PI/2, itemValue:2, itemType:0, score:100}, 30),
                new Phase(LineEnemyB, {fromX:W+50, fromY:50, toX:-50, toY:50, time:5, hp:1, color:2, size:7, interval:60, shot_speed:4, shot_angle:Math.PI/2, itemValue:2, itemType:1, score:100}, 30),
                new Phase(LineEnemyA, {fromX:W+50, fromY:50, toX:-50, toY:50, time:5, hp:1, color:3, size:7, interval:70, shot_speed:4, shot_angle:Math.PI/2, itemValue:2, itemType:0, score:100}, 30),
                new Phase(LineEnemyB, {fromX:W+50, fromY:50, toX:-50, toY:50, time:5, hp:1, color:3, size:7, interval:60, shot_speed:4, shot_angle:Math.PI/2, itemValue:2, itemType:1, score:100}, 30),
                new Phase(LineEnemyA, {fromX:W+50, fromY:50, toX:-50, toY:50, time:5, hp:1, color:1, size:7, interval:70, shot_speed:4, shot_angle:Math.PI/2, itemValue:2, itemType:0, score:100}, 30),
                new Phase(LineEnemyB, {fromX:W+50, fromY:50, toX:-50, toY:50, time:5, hp:1, color:1, size:7, interval:60, shot_speed:4, shot_angle:Math.PI/2, itemValue:2, itemType:1, score:100}, 30),
                
                //ボス
                new Phase(Text, {x:W/2, y:H/2, fontSize:50, text:"Boss", time:120}, -1),    
                new Phase(Boss01, {fromX:W/2, fromY:-50, toX:W/2, toY:H/2-100, time:3, hp:120, color:0, size:15, interval:30, shot_speed:4, shot_angle:Math.PI/2, n:12, angle_range:Math.PI*2, angle_speed:Math.PI/10, itemValue:2, itemType:2, score:3000}, 30),
                
                new Phase(WallCommand, {type:WallCommand.DELETE, index:0}, -1),
                new Phase(WallCommand, {type:WallCommand.DELETE, index:1}, -1),
                new Phase(WallCommand, {type:WallCommand.DELETE, index:2}, -1),
                
                
                //Stage2
                new Phase(Text, {x:W/2, y:H/2, fontSize:50, text:"Stage2", time:120}, 30),
                new Phase(LineRepeatWall, {x:50, y:H/2, X:[W-50,50], Y:[H/2, H/2], T:[5,5], w:100, color:1, angle:Math.PI/2, vr:0.01}, 120),
                
                //通常敵1
                //赤
                new Phase(LineEnemyA, {fromX:W/2+150, fromY:-50, toX:W/2+150, toY:500, time:5, hp:1, color:1, size:7, interval:40, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 60),
                new Phase(LineEnemyB, {fromX:W/2+100, fromY:-50, toX:W/2+100, toY:500, time:5, hp:1, color:1, size:7, interval:40, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 30),
                new Phase(LineEnemyA, {fromX:W/2+50,  fromY:-50, toX:W/2+50,  toY:500, time:5, hp:1, color:1, size:7, interval:40, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 30),
                new Phase(LineEnemyB, {fromX:W/2,     fromY:-50, toX:W/2,     toY:500, time:5, hp:1, color:1, size:7, interval:40, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 30),
                new Phase(LineEnemyA, {fromX:W/2-50,  fromY:-50, toX:W/2-50,  toY:500, time:5, hp:1, color:1, size:7, interval:40, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 30),
                new Phase(LineEnemyB, {fromX:W/2-100, fromY:-50, toX:W/2-100, toY:500, time:5, hp:1, color:1, size:7, interval:40, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 30),
                new Phase(LineEnemyA, {fromX:W/2-150, fromY:-50, toX:W/2-150, toY:500, time:5, hp:1, color:1, size:7, interval:40, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 30),
                
                new Phase(LineEnemyA, {fromX:-50, fromY:100, toX:W+100, toY:100, time:5, hp:1, color:1, size:7, interval:60, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 60),
                new Phase(LineEnemyA, {fromX:-50, fromY:100, toX:W+100, toY:100, time:5, hp:1, color:1, size:7, interval:60, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 60),
                new Phase(LineEnemyC, {fromX:-50, fromY:100, toX:W+100, toY:100, time:5, hp:1, color:3, size:7, interval:90, shot_speed:4, shot_angle:Math.PI/2, n:3, angle_range:Math.PI/2, angle_speed:0, itemValue:1, itemType:0, score:100}, 60),
                new Phase(LineEnemyC, {fromX:W+0, fromY:50, toX:-50, toY:50, time:5, hp:1, color:3, size:7, interval:90, shot_speed:4, shot_angle:Math.PI/2, n:3, angle_range:Math.PI/2, angle_speed:0, itemValue:1, itemType:0, score:100}, 60),
                new Phase(LineEnemyB, {fromX:W+50,     fromY:50, toX:-50,     toY:50, time:5, hp:1, color:1, size:7, interval:60, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 60),
                new Phase(LineEnemyB, {fromX:W+50,     fromY:50, toX:-50,     toY:50, time:5, hp:1, color:1, size:7, interval:60, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 60),
                
                //緑
                new Phase(WallCommand, {type:WallCommand.CHANGE_COLOR, index:0, color:2}, -1),
                new Phase(LineEnemyB, {fromX:W/2+150, fromY:-50, toX:W/2+150, toY:500, time:8, hp:1, color:2, size:7, interval:80, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 60),
                new Phase(LineEnemyA, {fromX:W/2+100, fromY:-50, toX:W/2+100, toY:500, time:8, hp:1, color:2, size:7, interval:80, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 0),
                new Phase(LineEnemyB, {fromX:W/2+50,  fromY:-50, toX:W/2+50,  toY:500, time:8, hp:1, color:2, size:7, interval:80, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 0),
                new Phase(LineEnemyA, {fromX:W/2,     fromY:-50, toX:W/2,     toY:500, time:8, hp:1, color:2, size:7, interval:60, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 0),
                new Phase(LineEnemyB, {fromX:W/2-50,  fromY:-50, toX:W/2-50,  toY:500, time:8, hp:1, color:2, size:7, interval:80, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 0),
                new Phase(LineEnemyA, {fromX:W/2-100, fromY:-50, toX:W/2-100, toY:500, time:8, hp:1, color:2, size:7, interval:80, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 0),
                new Phase(LineEnemyB, {fromX:W/2-150, fromY:-50, toX:W/2-150, toY:500, time:8, hp:1, color:2, size:7, interval:80, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 0),
                
                new Phase(LineEnemyB, {fromX:-50, fromY:50,  toX:W+50, toY:50,  time:5, hp:1, color:2, size:7, interval:80, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 180),
                new Phase(LineEnemyA, {fromX:-50, fromY:90,  toX:W+50, toY:90,  time:5, hp:1, color:2, size:7, interval:70, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 0),
                new Phase(LineEnemyB, {fromX:-50, fromY:130, toX:W+50, toY:130, time:5, hp:1, color:2, size:7, interval:80, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 0),
                new Phase(LineEnemyA, {fromX:-50, fromY:170, toX:W+50, toY:170, time:5, hp:1, color:2, size:7, interval:70, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 0),
                
                new Phase(LineEnemyA, {fromX:W+50, fromY:70,  toX:-50, toY:70,  time:5, hp:1, color:2, size:7, interval:80, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 120),
                new Phase(LineEnemyB, {fromX:W+50, fromY:110, toX:-50, toY:110, time:5, hp:1, color:2, size:7, interval:70, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 0),
                new Phase(LineEnemyA, {fromX:W+50, fromY:150, toX:-50, toY:150, time:5, hp:1, color:2, size:7, interval:80, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 0),
                new Phase(LineEnemyB, {fromX:W+50, fromY:190, toX:-50, toY:190, time:5, hp:1, color:2, size:7, interval:70, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 0),
                
                //青
                new Phase(WallCommand, {type:WallCommand.CHANGE_COLOR, index:0, color:3}, -1),
                new Phase(LineEnemyA, {fromX:-50, fromY:50,  toX:W+50, toY:50,  time:5, hp:1, color:3, size:7, interval:40, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 60),
                new Phase(LineEnemyA, {fromX:W+50, fromY:70,  toX:-50, toY:70,  time:5, hp:1, color:3, size:7, interval:40, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 30),
                new Phase(LineEnemyA, {fromX:-50, fromY:90,  toX:W+50, toY:90,  time:5, hp:1, color:3, size:7, interval:40, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 30),
                new Phase(LineEnemyA, {fromX:W+50, fromY:110, toX:-50, toY:110, time:5, hp:1, color:3, size:7, interval:40, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 30),
                new Phase(LineEnemyA, {fromX:-50, fromY:130, toX:W+50, toY:130, time:5, hp:1, color:3, size:7, interval:40, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 30),
                new Phase(LineEnemyA, {fromX:W+50, fromY:150, toX:-50, toY:150, time:5, hp:1, color:3, size:7, interval:40, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 30),
                
                new Phase(LineEnemyB, {fromX:W/2+150, fromY:-50, toX:W/2+150, toY:500, time:8, hp:1, color:3, size:7, interval:60, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 120),
                new Phase(LineEnemyA, {fromX:W/2+100, fromY:-50, toX:W/2+100, toY:500, time:8, hp:1, color:3, size:7, interval:60, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 0),
                new Phase(LineEnemyB, {fromX:W/2+50,  fromY:-50, toX:W/2+50,  toY:500, time:8, hp:1, color:3, size:7, interval:60, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 0),
                new Phase(LineEnemyA, {fromX:W/2,     fromY:-50, toX:W/2,     toY:500, time:8, hp:1, color:3, size:7, interval:60, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 0),
                new Phase(LineEnemyB, {fromX:W/2-50,  fromY:-50, toX:W/2-50,  toY:500, time:8, hp:1, color:3, size:7, interval:60, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 0),
                new Phase(LineEnemyA, {fromX:W/2-100, fromY:-50, toX:W/2-100, toY:500, time:8, hp:1, color:3, size:7, interval:60, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 0),
                new Phase(LineEnemyB, {fromX:W/2-150, fromY:-50, toX:W/2-150, toY:500, time:8, hp:1, color:3, size:7, interval:60, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 0),
                
                new Phase(LineEnemyA, {fromX:W/2+150, fromY:-50, toX:W/2+150, toY:500, time:5, hp:1, color:1, size:7, interval:40, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 120),
                new Phase(LineEnemyB, {fromX:W/2+100, fromY:-50, toX:W/2+100, toY:500, time:5, hp:1, color:2, size:7, interval:40, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 30),
                new Phase(LineEnemyA, {fromX:W/2+50,  fromY:-50, toX:W/2+50,  toY:500, time:5, hp:1, color:3, size:7, interval:40, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 30),
                new Phase(LineEnemyB, {fromX:W/2,     fromY:-50, toX:W/2,     toY:500, time:5, hp:1, color:1, size:7, interval:40, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 30),
                new Phase(LineEnemyA, {fromX:W/2-50,  fromY:-50, toX:W/2-50,  toY:500, time:5, hp:1, color:2, size:7, interval:40, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 30),
                new Phase(LineEnemyB, {fromX:W/2-100, fromY:-50, toX:W/2-100, toY:500, time:5, hp:1, color:3, size:7, interval:40, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 30),
                new Phase(LineEnemyA, {fromX:W/2-150, fromY:-50, toX:W/2-150, toY:500, time:5, hp:1, color:1, size:7, interval:40, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 30),
                
                
                //中ボス
                new Phase(Wall, {x:W/2+100, y:100, w:100, color:1, angle:Math.PI/2, vr:0.01}, -1),
                new Phase(Wall, {x:W/2-100, y:100, w:100, color:2, angle:Math.PI/2, vr:0.01}, -1),
                new Phase(LineEnemyD, {fromX:W/2-100, fromY:-50, toX:W/2-100, toY:150, time:2, hp:15, color:2, size:15, interval:60, shot_speed:3, shot_angle:Math.PI/2, n:12, angle_range:Math.PI*2, angle_speed:0.2, itemValue:1, itemType:2, score:500}, 120),
                new Phase(LineEnemyC, {fromX:W/2+100, fromY:-50, toX:W/2+100, toY:150, time:2, hp:15, color:1, size:15, interval:30,  shot_speed:3, shot_angle:Math.PI/2, n:12, angle_range:Math.PI*2, angle_speed:0.3, itemValue:5, itemType:0, score:500}, 0),
                new Phase(LineEnemyD, {fromX:W/2,     fromY:-50, toX:W/2,     toY:150, time:2, hp:15, color:3, size:15, interval:60,  shot_speed:3, shot_angle:Math.PI/2, n:12, angle_range:Math.PI*2, angle_speed:0.4, itemValue:5, itemType:1, score:500}, 0),
                
                //赤
                new Phase(LineEnemyA, {fromX:W/2+150, fromY:-50, toX:W/2+150, toY:500, time:5, hp:1, color:1, size:7, interval:40, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, -1),
                new Phase(LineEnemyB, {fromX:W/2+100, fromY:-50, toX:W/2+100, toY:500, time:5, hp:1, color:1, size:7, interval:40, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 30),
                new Phase(LineEnemyA, {fromX:W/2+50,  fromY:-50, toX:W/2+50,  toY:500, time:5, hp:1, color:1, size:7, interval:40, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 30),
                new Phase(LineEnemyB, {fromX:W/2,     fromY:-50, toX:W/2,     toY:500, time:5, hp:1, color:1, size:7, interval:40, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 30),
                new Phase(LineEnemyA, {fromX:W/2-50,  fromY:-50, toX:W/2-50,  toY:500, time:5, hp:1, color:1, size:7, interval:40, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 30),
                new Phase(LineEnemyB, {fromX:W/2-100, fromY:-50, toX:W/2-100, toY:500, time:5, hp:1, color:1, size:7, interval:40, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 30),
                new Phase(LineEnemyA, {fromX:W/2-150, fromY:-50, toX:W/2-150, toY:500, time:5, hp:1, color:1, size:7, interval:40, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 30),
                
                new Phase(LineEnemyA, {fromX:-50, fromY:100, toX:W+50, toY:100, time:5, hp:1, color:1, size:7, interval:60, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 60),
                new Phase(LineEnemyA, {fromX:-50, fromY:100, toX:W+50, toY:100, time:5, hp:1, color:1, size:7, interval:60, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 60),
                new Phase(LineEnemyA, {fromX:-50, fromY:100, toX:W+50, toY:100, time:5, hp:1, color:1, size:7, interval:60, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 60),
                new Phase(LineEnemyB, {fromX:W+50,     fromY:50, toX:-50,     toY:50, time:5, hp:1, color:1, size:7, interval:60, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 60),
                new Phase(LineEnemyB, {fromX:W+50,     fromY:50, toX:-50,     toY:50, time:5, hp:1, color:1, size:7, interval:60, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 60),
                new Phase(LineEnemyB, {fromX:W+50,     fromY:50, toX:-50,     toY:50, time:5, hp:1, color:1, size:7, interval:60, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 60),
                
                new Phase(LineEnemyA, {fromX:-50, fromY:100, toX:W+50, toY:100, time:5, hp:1, color:2, size:7, interval:60, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 60),
                new Phase(LineEnemyA, {fromX:-50, fromY:100, toX:W+50, toY:100, time:5, hp:1, color:2, size:7, interval:60, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 60),
                new Phase(LineEnemyA, {fromX:-50, fromY:100, toX:W+50, toY:100, time:5, hp:1, color:2, size:7, interval:60, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 60),
                new Phase(LineEnemyB, {fromX:W+50,     fromY:50, toX:-50,     toY:50, time:5, hp:1, color:3, size:7, interval:60, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 60),
                new Phase(LineEnemyB, {fromX:W+50,     fromY:50, toX:-50,     toY:50, time:5, hp:1, color:3, size:7, interval:60, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 60),
                new Phase(LineEnemyB, {fromX:W+50,     fromY:50, toX:-50,     toY:50, time:5, hp:1, color:3, size:7, interval:60, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 60),
                
                //緑
                new Phase(LineEnemyD, {fromX:W/2+150, fromY:-50, toX:W/2+150, toY:500, time:8, hp:1, color:2, size:7, interval:60,  shot_speed:4, shot_angle:Math.PI/2, n:3, angle_range:Math.PI/2, angle_speed:0.4, itemValue:1, itemType:1, score:500}, 60),
                new Phase(LineEnemyB, {fromX:W/2+100, fromY:-50, toX:W/2+100, toY:500, time:8, hp:1, color:2, size:7, interval:60, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 0),
                new Phase(LineEnemyB, {fromX:W/2+50,  fromY:-50, toX:W/2+50,  toY:500, time:8, hp:1, color:2, size:7, interval:60, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 0),
                new Phase(LineEnemyD, {fromX:W/2, fromY:-50, toX:W/2, toY:500, time:8, hp:1, color:2, size:7, interval:60,  shot_speed:4, shot_angle:Math.PI/2, n:3, angle_range:Math.PI/2, angle_speed:0.4, itemValue:1, itemType:1, score:100}, 0),
                new Phase(LineEnemyB, {fromX:W/2-50,  fromY:-50, toX:W/2-50,  toY:500, time:8, hp:1, color:2, size:7, interval:60, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 0),
                new Phase(LineEnemyB, {fromX:W/2-100, fromY:-50, toX:W/2-100, toY:500, time:8, hp:1, color:2, size:7, interval:60, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 0),
                new Phase(LineEnemyD, {fromX:W/2-150, fromY:-50, toX:W/2-150, toY:500, time:8, hp:1, color:2, size:7, interval:60,  shot_speed:4, shot_angle:Math.PI/2, n:3, angle_range:Math.PI/2, angle_speed:0.4, itemValue:1, itemType:1, score:100}, 0),
                
                new Phase(LineEnemyB, {fromX:-50, fromY:50,  toX:W+50, toY:50,  time:5, hp:1, color:2, size:7, interval:60, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 180),
                new Phase(LineEnemyB, {fromX:-50, fromY:90,  toX:W+50, toY:90,  time:5, hp:1, color:2, size:7, interval:50, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 0),
                new Phase(LineEnemyB, {fromX:-50, fromY:130, toX:W+50, toY:130, time:5, hp:1, color:2, size:7, interval:60, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 0),
                new Phase(LineEnemyB, {fromX:-50, fromY:170, toX:W+50, toY:170, time:5, hp:1, color:2, size:7, interval:50, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 0),
                
                new Phase(LineEnemyB, {fromX:W+50, fromY:70,  toX:-50, toY:70,  time:5, hp:1, color:2, size:7, interval:60, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 120),
                new Phase(LineEnemyB, {fromX:W+50, fromY:110, toX:-50, toY:110, time:5, hp:1, color:2, size:7, interval:50, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 0),
                new Phase(LineEnemyB, {fromX:W+50, fromY:150, toX:-50, toY:150, time:5, hp:1, color:2, size:7, interval:60, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 0),
                new Phase(LineEnemyB, {fromX:W+50, fromY:190, toX:-50, toY:190, time:5, hp:1, color:2, size:7, interval:50, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 0),
                
                new Phase(LineEnemyB, {fromX:-50, fromY:50,  toX:W+50, toY:50,  time:5, hp:1, color:1, size:7, interval:60, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 180),
                new Phase(LineEnemyB, {fromX:-50, fromY:90,  toX:W+50, toY:90,  time:5, hp:1, color:1, size:7, interval:50, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 0),
                new Phase(LineEnemyB, {fromX:-50, fromY:130, toX:W+50, toY:130, time:5, hp:1, color:1, size:7, interval:60, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 0),
                new Phase(LineEnemyB, {fromX:-50, fromY:170, toX:W+50, toY:170, time:5, hp:1, color:1, size:7, interval:50, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 0),
                
                new Phase(LineEnemyB, {fromX:W+50, fromY:70,  toX:-50, toY:70,  time:5, hp:1, color:3, size:7, interval:60, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 120),
                new Phase(LineEnemyB, {fromX:W+50, fromY:110, toX:-50, toY:110, time:5, hp:1, color:3, size:7, interval:50, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 0),
                new Phase(LineEnemyB, {fromX:W+50, fromY:150, toX:-50, toY:150, time:5, hp:1, color:3, size:7, interval:60, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 0),
                new Phase(LineEnemyB, {fromX:W+50, fromY:190, toX:-50, toY:190, time:5, hp:1, color:3, size:7, interval:50, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 0),
                
                
                //青
                new Phase(LineEnemyA, {fromX:-50, fromY:50,  toX:W+50, toY:50,  time:5, hp:1, color:3, size:7, interval:60, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 60),
                new Phase(LineEnemyA, {fromX:W+50, fromY:70,  toX:-50, toY:70,  time:5, hp:1, color:3, size:7, interval:60, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 30),
                new Phase(LineEnemyB, {fromX:-50, fromY:90,  toX:W+50, toY:90,  time:5, hp:1, color:3, size:7, interval:60, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 30),
                new Phase(LineEnemyB, {fromX:W+50, fromY:110, toX:-50, toY:110, time:5, hp:1, color:3, size:7, interval:60, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 30),
                new Phase(LineEnemyA, {fromX:-50, fromY:130, toX:W+50, toY:130, time:5, hp:1, color:3, size:7, interval:60, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 30),
                new Phase(LineEnemyA, {fromX:W+50, fromY:150, toX:-50, toY:150, time:5, hp:1, color:3, size:7, interval:60, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 30),
                
                new Phase(LineEnemyB, {fromX:W/2+150, fromY:-50, toX:W/2+150, toY:500, time:8, hp:1, color:3, size:7, interval:80, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 120),
                new Phase(LineEnemyA, {fromX:W/2+100, fromY:-50, toX:W/2+100, toY:500, time:8, hp:1, color:3, size:7, interval:80, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 0),
                new Phase(LineEnemyB, {fromX:W/2+50,  fromY:-50, toX:W/2+50,  toY:500, time:8, hp:1, color:3, size:7, interval:80, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 0),
                new Phase(LineEnemyA, {fromX:W/2,     fromY:-50, toX:W/2,     toY:500, time:8, hp:1, color:3, size:7, interval:60, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 0),
                new Phase(LineEnemyB, {fromX:W/2-50,  fromY:-50, toX:W/2-50,  toY:500, time:8, hp:1, color:3, size:7, interval:80, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 0),
                new Phase(LineEnemyA, {fromX:W/2-100, fromY:-50, toX:W/2-100, toY:500, time:8, hp:1, color:3, size:7, interval:80, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 0),
                new Phase(LineEnemyB, {fromX:W/2-150, fromY:-50, toX:W/2-150, toY:500, time:8, hp:1, color:3, size:7, interval:80, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 0),
                
                new Phase(LineEnemyB, {fromX:-50, fromY:90,  toX:W+50, toY:90,  time:5, hp:1, color:1, size:7, interval:50, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 0),
                new Phase(LineEnemyB, {fromX:-50, fromY:130, toX:W+50, toY:130, time:5, hp:1, color:2, size:7, interval:60, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 0),
                new Phase(LineEnemyB, {fromX:-50, fromY:170, toX:W+50, toY:170, time:5, hp:1, color:3, size:7, interval:50, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 0),
                
                new Phase(LineEnemyB, {fromX:W+50, fromY:70,  toX:-50, toY:70,  time:5, hp:1, color:1, size:7, interval:60, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 120),
                new Phase(LineEnemyB, {fromX:W+50, fromY:110, toX:-50, toY:110, time:5, hp:1, color:2, size:7, interval:50, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:2, score:100}, 0),
                new Phase(LineEnemyB, {fromX:W+50, fromY:150, toX:-50, toY:150, time:5, hp:1, color:3, size:7, interval:60, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 0),
                
                
                //ボス
                new Phase(Text, {x:W/2, y:H/2, fontSize:50, text:"Boss", time:120}, -1),    
                new Phase(Boss02, {fromX:W/2, fromY:-50, toX:W/2, toY:H/2-100, time:3, hp:120, color:0, size:15, interval:20, shot_speed:4, shot_angle:Math.PI/2, n:10, angle_range:Math.PI*2, angle_speed:0.1, itemValue:2, itemType:2, score:5000}, 30),
                
                new Phase(WallCommand, {type:WallCommand.DELETE, index:0}, -1),
                new Phase(WallCommand, {type:WallCommand.DELETE, index:1}, -1),
                new Phase(WallCommand, {type:WallCommand.DELETE, index:2}, -1),
                
                //Stage3
                new Phase(Text, {x:W/2, y:H/2, fontSize:50, text:"Stage3", time:120}, 30),
                
                new Phase(Wall, {x:W/2+100, y:H/2, w:100, color:1, angle:0, vr:0.01}, 60),
                new Phase(Wall, {x:W/2, y:H/2, w:100, color:2, angle:Math.PI*2/3, vr:0.01}, 0),
                new Phase(Wall, {x:W/2-100, y:H/2, w:100, color:3, angle:Math.PI*4/3, vr:0.01}, 0),
                
                //通常敵1
                new Phase(LineEnemyC, {fromX:W/2+100, fromY:-50, toX:W/2+100, toY:500, time:5, hp:1, color:2, size:7, interval:90, shot_speed:4, shot_angle:Math.PI/2, n:3, angle_range:Math.PI/2, angle_speed:0, itemValue:1, itemType:0, score:100}, 120),
                new Phase(LineEnemyD, {fromX:W/2-100, fromY:-50, toX:W/2-100, toY:500, time:5, hp:1, color:2, size:7, interval:90, shot_speed:4, shot_angle:Math.PI/2, n:3, angle_range:Math.PI/2, angle_speed:0, itemValue:1, itemType:1, score:100}, 60),
                new Phase(LineEnemyC, {fromX:W/2-50,  fromY:-50, toX:W/2-50,  toY:500, time:5, hp:1, color:2, size:7, interval:90, shot_speed:4, shot_angle:Math.PI/2, n:3, angle_range:Math.PI/2, angle_speed:0, itemValue:1, itemType:0, score:100}, 60),
                new Phase(LineEnemyD, {fromX:W/2+50,  fromY:-50, toX:W/2+50,  toY:500, time:5, hp:1, color:2, size:7, interval:90, shot_speed:4, shot_angle:Math.PI/2, n:3, angle_range:Math.PI/2, angle_speed:0, itemValue:1, itemType:1, score:100}, 60),
                new Phase(LineEnemyC, {fromX:W/2,     fromY:-50, toX:W/2,     toY:500, time:5, hp:1, color:2, size:7, interval:90, shot_speed:4, shot_angle:Math.PI/2, n:3, angle_range:Math.PI/2, angle_speed:0, itemValue:1, itemType:0, score:100}, 60),
                
                new Phase(LineEnemyD, {fromX:W/2+100, fromY:-50, toX:W/2+100, toY:500, time:5, hp:1, color:1, size:7, interval:90, shot_speed:4, shot_angle:Math.PI/2, n:5, angle_range:Math.PI*2, angle_speed:0.1, itemValue:1, itemType:1, score:100}, 120),
                new Phase(LineEnemyC, {fromX:W/2-100, fromY:-50, toX:W/2-100, toY:500, time:5, hp:1, color:1, size:7, interval:90, shot_speed:4, shot_angle:Math.PI/2, n:5, angle_range:Math.PI*2, angle_speed:0.2, itemValue:1, itemType:0, score:100}, 60),
                new Phase(LineEnemyD, {fromX:W/2-50,  fromY:-50, toX:W/2-50,  toY:500, time:5, hp:1, color:1, size:7, interval:90, shot_speed:4, shot_angle:Math.PI/2, n:5, angle_range:Math.PI*2, angle_speed:0.3, itemValue:1, itemType:1, score:100}, 60),
                new Phase(LineEnemyC, {fromX:W/2+50,  fromY:-50, toX:W/2+50,  toY:500, time:5, hp:1, color:1, size:7, interval:90, shot_speed:4, shot_angle:Math.PI/2, n:5, angle_range:Math.PI*2, angle_speed:0.4, itemValue:1, itemType:0, score:100}, 60),
                new Phase(LineEnemyD, {fromX:W/2,     fromY:-50, toX:W/2,     toY:500, time:5, hp:1, color:1, size:7, interval:90, shot_speed:4, shot_angle:Math.PI/2, n:5, angle_range:Math.PI*2, angle_speed:0.5, itemValue:1, itemType:1, score:100}, 60),
                
                new Phase(LineEnemyC, {fromX:W/2+100, fromY:-50, toX:W/2+100, toY:500, time:5, hp:1, color:3, size:7, interval:90, shot_speed:4, shot_angle:Math.PI/2, n:5, angle_range:Math.PI/2, angle_speed:0, itemValue:1, itemType:1, score:100}, 120),
                new Phase(LineEnemyD, {fromX:W/2-100, fromY:-50, toX:W/2-100, toY:500, time:5, hp:1, color:3, size:7, interval:90, shot_speed:4, shot_angle:Math.PI/2, n:5, angle_range:Math.PI/2, angle_speed:0, itemValue:1, itemType:0, score:100}, 60),
                new Phase(LineEnemyC, {fromX:W/2-50,  fromY:-50, toX:W/2-50,  toY:500, time:5, hp:1, color:3, size:7, interval:90, shot_speed:4, shot_angle:Math.PI/2, n:5, angle_range:Math.PI/2, angle_speed:0, itemValue:1, itemType:1, score:100}, 60),
                new Phase(LineEnemyD, {fromX:W/2+50,  fromY:-50, toX:W/2+50,  toY:500, time:5, hp:1, color:3, size:7, interval:90, shot_speed:4, shot_angle:Math.PI/2, n:5, angle_range:Math.PI/2, angle_speed:0, itemValue:1, itemType:0, score:100}, 60),
                new Phase(LineEnemyC, {fromX:W/2,     fromY:-50, toX:W/2,     toY:500, time:5, hp:1, color:3, size:7, interval:90, shot_speed:4, shot_angle:Math.PI/2, n:5, angle_range:Math.PI/2, angle_speed:0, itemValue:1, itemType:1, score:100}, 60),
                
                new Phase(LineEnemyB, {fromX:-50, fromY:90,  toX:W+50, toY:90,  time:5, hp:1, color:1, size:7, interval:50, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 0),
                new Phase(LineEnemyB, {fromX:-50, fromY:130, toX:W+50, toY:130, time:5, hp:1, color:1, size:7, interval:60, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 0),
                new Phase(LineEnemyB, {fromX:-50, fromY:170, toX:W+50, toY:170, time:5, hp:1, color:1, size:7, interval:50, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 0),
                
                new Phase(LineEnemyA, {fromX:W+50, fromY:70,  toX:-50, toY:70,  time:5, hp:1, color:2, size:7, interval:60, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 120),
                new Phase(LineEnemyA, {fromX:W+50, fromY:110, toX:-50, toY:110, time:5, hp:1, color:2, size:7, interval:50, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:2, score:100}, 0),
                new Phase(LineEnemyA, {fromX:W+50, fromY:150, toX:-50, toY:150, time:5, hp:1, color:2, size:7, interval:60, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 0),
                
                new Phase(LineEnemyB, {fromX:-50, fromY:90,  toX:W+50, toY:90,  time:5, hp:1, color:3, size:7, interval:50, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 0),
                new Phase(LineEnemyB, {fromX:-50, fromY:130, toX:W+50, toY:130, time:5, hp:1, color:3, size:7, interval:60, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 0),
                new Phase(LineEnemyB, {fromX:-50, fromY:170, toX:W+50, toY:170, time:5, hp:1, color:3, size:7, interval:50, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 0),
                
                
                //                    中ボス
                new Phase(LineEnemyA, {fromX:W/2-100, fromY:-50,  toX:W/2-100, toY:80,  time:3, hp:30, color:1, size:15, interval:10, shot_speed:4, shot_angle:0.65, itemValue:5, itemType:0, score:1000}, -1),
                new Phase(LineEnemyA, {fromX:W/2+100, fromY:-50,  toX:W/2+100, toY:80,  time:3, hp:30, color:3, size:15, interval:10, shot_speed:4, shot_angle: 2.5, itemValue:5, itemType:1, score:1000}, 0),
                new Phase(LineEnemyC, {fromX:W/2+100, fromY:-50, toX:W/2+100, toY:80, time:3, hp:30, color:2, size:15, interval:15, shot_speed:4, shot_angle:Math.PI/2, n:8, angle_range:2*Math.PI, angle_speed:0.2, itemValue:1, itemType:2, score:1000}, -1),
                new Phase(LineEnemyD, {fromX:W/2-100, fromY:-50, toX:W/2-100, toY:80, time:3, hp:30, color:2, size:15, interval:15, shot_speed:4, shot_angle:Math.PI/2, n:8, angle_range:2*Math.PI, angle_speed:0, itemValue:1, itemType:2, score:1000}, 0),
                
                //通常敵2
                new Phase(LineEnemyA, {fromX:-50, fromY:100, toX:W+50, toY:100, time:5, hp:1, color:1, size:7, interval:40, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, -1),
                new Phase(LineEnemyB, {fromX:-50, fromY:100, toX:W+50, toY:100, time:5, hp:1, color:1, size:7, interval:40, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 30),
                new Phase(LineEnemyA, {fromX:-50, fromY:100, toX:W+50, toY:100, time:5, hp:1, color:1, size:7, interval:40, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 30),
                new Phase(LineEnemyB, {fromX:-50, fromY:100, toX:W+50, toY:100, time:5, hp:1, color:2, size:7, interval:40, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 30),
                new Phase(LineEnemyA, {fromX:-50, fromY:100, toX:W+50, toY:100, time:5, hp:1, color:2, size:7, interval:40, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 30),
                new Phase(LineEnemyB, {fromX:-50, fromY:100, toX:W+50, toY:100, time:5, hp:1, color:2, size:7, interval:40, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 30),
                
                new Phase(LineEnemyA, {fromX:W+50, fromY:50, toX:-50, toY:50, time:5, hp:1, color:3, size:7, interval:40, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 90),
                new Phase(LineEnemyB, {fromX:W+50, fromY:50, toX:-50, toY:50, time:5, hp:1, color:3, size:7, interval:40, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 30),
                new Phase(LineEnemyA, {fromX:W+50, fromY:50, toX:-50, toY:50, time:5, hp:1, color:3, size:7, interval:40, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 30),
                new Phase(LineEnemyB, {fromX:W+50, fromY:50, toX:-50, toY:50, time:5, hp:1, color:1, size:7, interval:40, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 30),
                new Phase(LineEnemyA, {fromX:W+50, fromY:50, toX:-50, toY:50, time:5, hp:1, color:1, size:7, interval:40, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 30),
                new Phase(LineEnemyB, {fromX:W+50, fromY:50, toX:-50, toY:50, time:5, hp:1, color:1, size:7, interval:40, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 30),
                
                new Phase(LineEnemyA, {fromX:-50, fromY:100, toX:W+50, toY:100, time:5, hp:1, color:2, size:7, interval:70, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 90),
                new Phase(LineEnemyB, {fromX:-50, fromY:100, toX:W+50, toY:100, time:5, hp:1, color:2, size:7, interval:70, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 30),
                new Phase(LineEnemyA, {fromX:-50, fromY:100, toX:W+50, toY:100, time:5, hp:1, color:2, size:7, interval:70, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 30),
                new Phase(LineEnemyB, {fromX:-50, fromY:100, toX:W+50, toY:100, time:5, hp:1, color:3, size:7, interval:70, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 30),
                new Phase(LineEnemyA, {fromX:-50, fromY:100, toX:W+50, toY:100, time:5, hp:1, color:3, size:7, interval:70, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 30),
                new Phase(LineEnemyB, {fromX:-50, fromY:100, toX:W+50, toY:100, time:5, hp:1, color:3, size:7, interval:70, shot_speed:4, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 30),
                
                new Phase(LineEnemyA, {fromX:W+50, fromY:50, toX:-50, toY:50, time:5, hp:1, color:1, size:7, interval:70, shot_speed:4, shot_angle:Math.PI/2, itemValue:2, itemType:0, score:100}, 90),
                new Phase(LineEnemyB, {fromX:W+50, fromY:50, toX:-50, toY:50, time:5, hp:1, color:2, size:7, interval:70, shot_speed:4, shot_angle:Math.PI/2, itemValue:2, itemType:1, score:100}, 30),
                new Phase(LineEnemyA, {fromX:W+50, fromY:50, toX:-50, toY:50, time:5, hp:1, color:3, size:7, interval:70, shot_speed:4, shot_angle:Math.PI/2, itemValue:2, itemType:0, score:100}, 30),
                new Phase(LineEnemyB, {fromX:W+50, fromY:50, toX:-50, toY:50, time:5, hp:1, color:1, size:7, interval:70, shot_speed:4, shot_angle:Math.PI/2, itemValue:2, itemType:1, score:100}, 30),
                new Phase(LineEnemyA, {fromX:W+50, fromY:50, toX:-50, toY:50, time:5, hp:1, color:2, size:7, interval:70, shot_speed:4, shot_angle:Math.PI/2, itemValue:2, itemType:0, score:100}, 30),
                new Phase(LineEnemyB, {fromX:W+50, fromY:50, toX:-50, toY:50, time:5, hp:1, color:3, size:7, interval:70, shot_speed:4, shot_angle:Math.PI/2, itemValue:2, itemType:1, score:100}, 30),
                
                new Phase(LineEnemyA, {fromX:W/2,     fromY:-50, toX:W/2,     toY:500, time:5, hp:1, color:1, size:7, interval:60, shot_speed:5, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 120),
                new Phase(LineEnemyB, {fromX:W/2-100, fromY:-50, toX:W/2-100, toY:500, time:5, hp:1, color:3, size:7, interval:60, shot_speed:5, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 0),
                new Phase(LineEnemyA, {fromX:W/2+100, fromY:-50, toX:W/2+100, toY:500, time:5, hp:1, color:2, size:7, interval:60, shot_speed:5, shot_angle:Math.PI/2, itemValue:1, itemType:2, score:100}, 0),
                new Phase(LineEnemyB, {fromX:W/2-50,  fromY:-50, toX:W/2-50,  toY:500, time:5, hp:1, color:3, size:7, interval:60, shot_speed:5, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 0),
                new Phase(LineEnemyA, {fromX:W/2+50,  fromY:-50, toX:W/2+50,  toY:500, time:5, hp:1, color:1, size:7, interval:60, shot_speed:5, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 0),
                
                
                //ボス
                new Phase(Text, {x:W/2, y:H/2, fontSize:50, text:"Boss", time:120}, -1),
                new Phase(Boss03, {fromX:W/2, fromY:-50, toX:W/2, toY:100, time:3, hp:120, color:0, size:15, interval:60, shot_speed:2, shot_angle:Math.PI/2, n:10, angle_range:Math.PI*2, angle_speed:Math.PI/10, gravity:0.1, itemValue:2, itemType:2, score:10000}, 30),
                
                new Phase(WallCommand, {type:WallCommand.DELETE, index:0}, -1),
                new Phase(WallCommand, {type:WallCommand.DELETE, index:1}, -1),
                new Phase(WallCommand, {type:WallCommand.DELETE, index:2}, -1),
                
                //Stage4
                new Phase(Text, {x:W/2, y:H/2, fontSize:50, text:"Stage4", time:120}, 30),
                
                new Phase(LineRepeatWall, {x:50, y:50,     X:[W-50,W-50,50,50], Y:[50,H-50,H-50,50], T:[5,5,5,5], w:100, color:1, angle:Math.PI/2, vr:0.01}, 120),
                new Phase(LineRepeatWall, {x:W-50, y:H-50, X:[50,50,W-50,W-50], Y:[H-50,50,50,H-50], T:[5,5,5,5], w:100, color:3, angle:Math.PI/2, vr:0.01}, 0),
                new Phase(LineRepeatWall, {x:W-50, y:H/2, X:[50,W-50], Y:[H/2,H/2], T:[5,5], w:100, color:2, angle:Math.PI/2, vr:0.01}, 0),
                
                new Phase(LineEnemyA, {fromX:W/10*1, fromY:-50, toX:W/10*1, toY:500, time:5, hp:1, color:1, size:7, interval:60, shot_speed:5, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 60),
                new Phase(LineEnemyB, {fromX:W/10*2, fromY:-50, toX:W/10*2, toY:500, time:5, hp:1, color:1, size:7, interval:60, shot_speed:5, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 15),
                new Phase(LineEnemyA, {fromX:W/10*3, fromY:-50, toX:W/10*3, toY:500, time:5, hp:1, color:1, size:7, interval:60, shot_speed:5, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 15),
                new Phase(LineEnemyB, {fromX:W/10*4, fromY:-50, toX:W/10*4, toY:500, time:5, hp:1, color:1, size:7, interval:60, shot_speed:5, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 15),
                new Phase(LineEnemyA, {fromX:W/10*5, fromY:-50, toX:W/10*5, toY:500, time:5, hp:1, color:1, size:7, interval:60, shot_speed:5, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 15),
                new Phase(LineEnemyB, {fromX:W/10*6, fromY:-50, toX:W/10*6, toY:500, time:5, hp:1, color:1, size:7, interval:60, shot_speed:5, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 15),
                new Phase(LineEnemyA, {fromX:W/10*7, fromY:-50, toX:W/10*7, toY:500, time:5, hp:1, color:1, size:7, interval:60, shot_speed:5, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 15),
                new Phase(LineEnemyB, {fromX:W/10*8, fromY:-50, toX:W/10*8, toY:500, time:5, hp:1, color:1, size:7, interval:60, shot_speed:5, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 15),
                new Phase(LineEnemyA, {fromX:W/10*9, fromY:-50, toX:W/10*9, toY:500, time:5, hp:1, color:1, size:7, interval:60, shot_speed:5, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 15),
                
                new Phase(LineEnemyA, {fromX:W/10*1, fromY:-50, toX:W/10*1, toY:500, time:5, hp:1, color:2, size:7, interval:50, shot_speed:5, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 20),
                new Phase(LineEnemyB, {fromX:W/10*2, fromY:-50, toX:W/10*2, toY:500, time:5, hp:1, color:2, size:7, interval:50, shot_speed:5, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 15),
                new Phase(LineEnemyA, {fromX:W/10*3, fromY:-50, toX:W/10*3, toY:500, time:5, hp:1, color:2, size:7, interval:50, shot_speed:5, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 15),
                new Phase(LineEnemyB, {fromX:W/10*4, fromY:-50, toX:W/10*4, toY:500, time:5, hp:1, color:2, size:7, interval:50, shot_speed:5, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 15),
                new Phase(LineEnemyA, {fromX:W/10*5, fromY:-50, toX:W/10*5, toY:500, time:5, hp:1, color:2, size:7, interval:50, shot_speed:5, shot_angle:Math.PI/2, itemValue:1, itemType:2, score:100}, 15),
                new Phase(LineEnemyB, {fromX:W/10*6, fromY:-50, toX:W/10*6, toY:500, time:5, hp:1, color:2, size:7, interval:50, shot_speed:5, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 15),
                new Phase(LineEnemyA, {fromX:W/10*7, fromY:-50, toX:W/10*7, toY:500, time:5, hp:1, color:2, size:7, interval:50, shot_speed:5, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 15),
                new Phase(LineEnemyB, {fromX:W/10*8, fromY:-50, toX:W/10*8, toY:500, time:5, hp:1, color:2, size:7, interval:50, shot_speed:5, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 15),
                new Phase(LineEnemyA, {fromX:W/10*9, fromY:-50, toX:W/10*9, toY:500, time:5, hp:1, color:2, size:7, interval:50, shot_speed:5, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 15),
                
                new Phase(LineEnemyA, {fromX:W/10*1, fromY:-50, toX:W/10*1, toY:500, time:5, hp:1, color:3, size:7, interval:40, shot_speed:5, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 20),
                new Phase(LineEnemyB, {fromX:W/10*2, fromY:-50, toX:W/10*2, toY:500, time:5, hp:1, color:3, size:7, interval:40, shot_speed:5, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 15),
                new Phase(LineEnemyA, {fromX:W/10*3, fromY:-50, toX:W/10*3, toY:500, time:5, hp:1, color:3, size:7, interval:40, shot_speed:5, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 15),
                new Phase(LineEnemyB, {fromX:W/10*4, fromY:-50, toX:W/10*4, toY:500, time:5, hp:1, color:3, size:7, interval:40, shot_speed:5, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 15),
                new Phase(LineEnemyA, {fromX:W/10*5, fromY:-50, toX:W/10*5, toY:500, time:5, hp:1, color:3, size:7, interval:40, shot_speed:5, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 15),
                new Phase(LineEnemyB, {fromX:W/10*6, fromY:-50, toX:W/10*6, toY:500, time:5, hp:1, color:3, size:7, interval:40, shot_speed:5, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 15),
                new Phase(LineEnemyA, {fromX:W/10*7, fromY:-50, toX:W/10*7, toY:500, time:5, hp:1, color:3, size:7, interval:40, shot_speed:5, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 15),
                new Phase(LineEnemyB, {fromX:W/10*8, fromY:-50, toX:W/10*8, toY:500, time:5, hp:1, color:3, size:7, interval:40, shot_speed:5, shot_angle:Math.PI/2, itemValue:1, itemType:0, score:100}, 15),
                new Phase(LineEnemyA, {fromX:W/10*9, fromY:-50, toX:W/10*9, toY:500, time:5, hp:1, color:3, size:7, interval:40, shot_speed:5, shot_angle:Math.PI/2, itemValue:1, itemType:1, score:100}, 15),
                
                //中ボス
                new Phase(LineEnemyC, {fromX:W/2, fromY:-50, toX:W/2, toY:100, time:3, hp:50, color:1, size:15, interval:1, shot_speed:5, shot_angle:Math.PI/2, n:4, angle_range:0, angle_speed:0.5, itemValue:5, itemType:0, score:3000}, -1),
                new Phase(LineEnemyC, {fromX:W/2-100, fromY:-50, toX:W/2-100, toY:100, time:3, hp:30, color:2, size:15, interval:5, shot_speed:5, shot_angle:Math.PI/2, n:4, angle_range:Math.PI*2, angle_speed:0.5, itemValue:1, itemType:2, score:3000}, -1),
                new Phase(LineEnemyC, {fromX:W/2+100, fromY:-50, toX:W/2+100, toY:100, time:3, hp:30, color:2, size:15, interval:5, shot_speed:5, shot_angle:Math.PI/2, n:4, angle_range:Math.PI*2, angle_speed:0.5, itemValue:1, itemType:2, score:3000}, 0),
                new Phase(LineEnemyH, {fromX:W/2, fromY:-50, toX:W/2, toY:100, time:3, hp:80, color:1, size:15, interval:5, shot_speed:5, shot_angle:Math.PI/2, n:8, itemValue:5, itemType:1, score:5000}, -1),
                
                //ボス
                new Phase(Text, {x:W/2, y:H/2, fontSize:50, text:"Boss", time:120}, -1),
                new Phase(Boss04, {fromX:W/2, fromY:-50, toX:W/2, toY:H/2-100, time:3, hp:140, color:0, size:15, interval:30, shot_speed:4, shot_angle:Math.PI/2, n:10, angle_range:Math.PI*2, angle_speed:0.1, itemValue:2, itemType:2, score:5000}, 30),
                
                new Phase(WallCommand, {type:WallCommand.DELETE, index:0}, -1),
                new Phase(WallCommand, {type:WallCommand.DELETE, index:1}, -1),
                new Phase(WallCommand, {type:WallCommand.DELETE, index:2}, -1),
                
                new Phase(Text, {x:W/2, y:H/2, fontSize:50, text:"Final Stage", time:120}, 30),
                new Phase(Wall, {x:W/2+1, y:100, w:100, color:1, angle:0, vr:0.01}, 120),
                new Phase(Wall, {x:W/2-100, y:H/2+5, w:100, color:2, angle:0, vr:0.015}, 0),
                new Phase(Wall, {x:W/2+100, y:H/2-5, w:100, color:3, angle:0, vr:0.02}, 0),
                new Phase(Text, {x:W/2, y:H/2, fontSize:50, text:"Boss", time:120}, 0),
                
                //ボス1
                new Phase(Boss05, {fromX:W/2, fromY:-50, toX:W/2, toY:H/2, time:3, hp:150, color:0, size:15, interval:8, shot_speed:4, itemValue:2, itemType:2, score:10000}, 120),
                
                //ボス2
                new Phase(Boss06, {fromX:W/2, fromY:-50, toX:W/2, toY:H/2, time:3, hp:200, color:0, size:15, interval:40, shot_speed:4, itemValue:2, itemType:2, score:10000}, -1),
                
                new Phase(WallCommand, {type:WallCommand.DELETE, index:0}, -1),
                new Phase(WallCommand, {type:WallCommand.DELETE, index:1}, -1),
                new Phase(WallCommand, {type:WallCommand.DELETE, index:2}, -1),
                
                //ラスボス
                new Phase(Wall, {x:60, y:H/4, w:100, color:1, angle:0, vr:0.01}, 120),
                new Phase(Wall, {x:60, y:H/4*2, w:100, color:2, angle:0, vr:-0.02}, 0),
                new Phase(Wall, {x:60, y:H/4*3, w:100, color:3, angle:0, vr:0.03}, 0),
                new Phase(Wall, {x:W-60, y:H/4, w:100, color:2, angle:0, vr:-0.015}, 0),
                new Phase(Wall, {x:W-60, y:H/4*2, w:100, color:3, angle:0, vr:-0.04}, 0),
                new Phase(Wall, {x:W-60, y:H/4*3, w:100, color:1, angle:0, vr:-0.02}, 0),
                
                new Phase(Boss07, {fromX:W/2, fromY:-50, toX:W/2, toY:H/2-100, time:3, hp:250, color:0, size:15, interval:5, shot_speed:4, shot_angle:Math.PI/2, angle_range:Math.PI*2, angle_speed:0.1534, itemValue:2, itemType:2, score:30000}, 30),
                
                new Phase(WallCommand, {type:WallCommand.DELETE, index:0}, -1),
                new Phase(WallCommand, {type:WallCommand.DELETE, index:1}, -1),
                new Phase(WallCommand, {type:WallCommand.DELETE, index:2}, -1),
                new Phase(WallCommand, {type:WallCommand.DELETE, index:3}, -1),
                new Phase(WallCommand, {type:WallCommand.DELETE, index:4}, -1),
                new Phase(WallCommand, {type:WallCommand.DELETE, index:5}, -1),
                
                new Phase(Text, {x:W/2, y:H/2, fontSize:50, text:"Clear", time:60}, -1),
            ]
        );
    }
}

/**
 * x,y: 位置
 * fontSize: フォントサイズ 
 * text: 表示する文字列
 * time: 何秒間表示するか
 */
class Text extends Sprite
{
    public var main:Game;
    public var frame:int;
    public var time:int;
    public function Text(main:Game, param:Object)
    {
        super();
        x = param.x;
        y = param.y;
        var tf:TextField = new TextField();
        tf.defaultTextFormat = new TextFormat(null, param.fontSize);
        tf.autoSize = TextFieldAutoSize.LEFT;
        tf.text = param.text;
        tf.textColor = 0xFFFFFF;
        tf.x = -tf.width/2;
        tf.y = -tf.height/2;
        addChild(tf);
        scaleX = scaleY = alpha = 0;
        
        main.addChild(this);
        this.main = main;
        
        var t:ITween = BetweenAS3.to(this, {alpha:1, scaleX:1, scaleY:1}, 0.5);
        t.play();
        
        time = param.time;
        frame = 0;
        
        addEventListener(Event.ENTER_FRAME, onEnterFrame);
    }
    
    public function onEnterFrame(e:Event):void{
        if(time <= frame){
            removeEventListener(Event.ENTER_FRAME, onEnterFrame);
            fadeOut();
        }
        frame++;
    }
    
    public function fadeOut():void{
        var t:ITween = BetweenAS3.to(this, {alpha:0, scaleX:0, scaleY:0}, 0.5);
        t.onComplete = remove;
        t.play();
    }
    
    public function remove():void{
        main.removeChild(this);
    }
}