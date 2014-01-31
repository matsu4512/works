/*
    Math & Physics DesignのTakakkeiを参考にしました。
*/
package{
    import flash.display.Sprite;
    import flash.events.Event;
    
    [SWF(width=465, height=465, frameRate=30)]
    public class Main extends Sprite{
        private var ballList:Vector.<Ball> = new Vector.<Ball>;
        private var N:int = 20;
        
        public function Main(){
            for(var i:int = 0; i < N; i++){
                var ball:Ball = new Ball(30, Math.random()*20+40, Math.random()*0xFFFFFF, Math.random()*10-5, Math.random()*10-5);
                ball.x = Math.random()*465;
                ball.y = Math.random()*465;
                addChild(ball);
                ballList.push(ball);
            }
            addEventListener(Event.ENTER_FRAME, onEnterFrame);
        }
        
        private function onEnterFrame(event:Event):void{
            for(var i:int = 0; i < N; i++){
                var ball:Ball = ballList[i];
                ball.update();
                if(ball.x > 465+70) ball.x = -70;
                else if(ball.x < -70) ball.x = 465+70;
                if(ball.y > 465+70) ball.y = -70;
                else if(ball.y < -70) ball.y = 465+70;
            }
        }
    }
}

import flash.display.Sprite;
import flash.filters.DropShadowFilter;
import flash.geom.Point;

class Ball extends Sprite{
    //動く頂点
    private var vertexList:Vector.<Vertex> = new Vector.<Vertex>;
    //元の形状
    private var pointList:Vector.<Point> = new Vector.<Point>;
    //頂点数, 半径, 色
    private var vertex:int, radius: Number, color:uint;
    private var preMouseX:Number, preMouseY:Number;
    private var vx:Number, vy:Number;
    private const D:Number = 200;
    
    public function Ball(vertexNum:int, radius:Number, color:uint, vx:Number, vy:Number){
        this.vertex = vertexNum; this.radius = radius;     this.color = color;    this.vx = vx; this.vy = vy;
        
        for(var i:Number = 0; i < vertex; ++i){
            pointList.push(new Point(0, 0));
            vertexList.push(new Vertex(0, 0));
        }
        filters = [new DropShadowFilter(30, 45, 0x000000, 0.5, 50, 50)];
        shape();
    }
    
    private function shape():void{
        for(var i:Number = 0; i < pointList.length; ++i){
            var k:Number = pointList.length/vertex;
            var num:Number = Math.abs(k/2 - i % k);
            var h:Number = radius*Math.cos(Math.PI*2/vertex/2);
            var r: Number = h/Math.cos((Math.PI*2/vertex/2)*(num/(k/2)));
            pointList[i].x = r*Math.sin(i/pointList.length*Math.PI*2);
            pointList[i].y = -r*Math.cos(i/pointList.length*Math.PI*2);
        }
    }
    
    private function draw(v:Vector.<Vertex>, c: uint):void{
        graphics.clear();
        if(v.length >= 3){
            graphics.moveTo((v[v.length-1].x+v[0].x)/2, (v[v.length-1].y+v[0].y)/2);
            graphics.beginFill(c);
            for(var i:Number = 0; i < v.length; ++i)
                graphics.curveTo(v[i % v.length].x, v[i % v.length].y, (v[i % v.length].x+v[(i+1) % v.length].x)/2, (v[i % v.length].y+v[(i+1) % v.length].y)/2);
            graphics.endFill();
        }  
    }
    
    public function update():void{
        for(var i:Number = 0; i < vertexList.length; ++i){
            vertexList[i].update();
            vertexList[i].setAccel((pointList[i].x - vertexList[i].x)*10, (pointList[i].y - vertexList[i].y)*10);
            var dist:Number = Point.distance(new Point(mouseX, mouseY), vertexList[i]);
            if(dist < D){
                var par:Number = (D-dist)/D;
                vertexList[i].setAccel((mouseX - preMouseX)*par*50, (mouseY - preMouseY)*par*50);
            }
        }
        preMouseX = mouseX;
        preMouseY = mouseY;
        draw(vertexList, color);
        
        x += vx;
        y += vy;
    }
}

class Vertex extends Point{
    private var vx:Number, vy:Number, ax:Number, ay:Number;
    private const friction:Number = 0.95;
    private var preTime:Number;
    
    public function Vertex(xx: Number=0, yy: Number=0){
        x = xx; y = yy;
        vx = vy = ax = ay = 0;
        preTime = new Date().getTime();
    }
    
    public function update():void{
        var nowTime:Number = new Date().getTime();
        var t:Number = (nowTime - preTime)/1000;
        x += vx*t + 0.5*ax*t*t;
        y += vy*t + 0.5*ay*t*t;
        vx += ax*t;
        vy += ay*t;
        vx *= friction;
        vy *= friction;
        ax = ay = 0;
        preTime = nowTime;
    }
    
    public function setAccel(aax:Number=0, aay:Number=0):void{
        ax += aax;
        ay += aay;
    }
}
