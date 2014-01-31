package
{
    import flash.display.*;
    import flash.events.Event;
    import flash.geom.Point;
    
    import org.libspark.betweenas3.BetweenAS3;
    import org.libspark.betweenas3.tweens.ITween;
    
    [SWF(width="465", height="465")]
    public class Main extends Sprite
    {
        private var vertexList:Array = [
            [-25, -50,  25, -50,  25,  50, -25,  50, -25, -50, -25,  50,  25,  50],  //0
            [  0, -50,   0,  50,   0, -50,   0,  50,   0, -50,   0,  50,   0, -50],  //1
            [-25, -50,  25, -50,  25,   0, -25,   0, -25,  50,  25,  50, -25,  50],  //2
            [-25,  50,  25,  50,  25,   0, -25,   0,  25,   0,  25, -50, -25, -50],  //3
            [-25, -50, -25,   0,  25,   0,  25, -50,  25,  50,  25,   0, -25,   0],  //4
            [ 25, -50, -25, -50, -25,   0,  25,   0,  25,  50, -25,  50,  25,  50],  //5
            [-25, -50, -25,  50,  25,  50,  25,   0, -25,   0,  25,   0,  25,  50],  //6
            [-25, -50,  25, -50,  25,  50,  25, -50, -25, -50,  25, -50,  25,  50],  //7
            [-25,   0,  25,   0,  25, -50, -25, -50, -25,  50,  25,  50,  25, -50],  //8
            [ 25,   0, -25,   0, -25, -50,  25, -50,  25,  50, -25,  50,  25,  50],  //9
        ];
        
        private var pointList:Array = [], timeList:Array = [0,0,0,0,0,0], spList:Array = [];
        
        public function Main()
        {
            for(var i:int = 0; i < 6; i++) spList[i] = addChild(new Sprite);
            spList[0].x = 52; spList[1].x = 112;    spList[2].x = 202;
            spList[3].x = 262; spList[4].x = 352; spList[5].x = 412;
            spList[0].y = spList[1].y = spList[2].y = spList[3].y = spList[4].y = spList[5].y = 200;
            
            for(i = 0; i < 6; i++){
                pointList[i] = [];
                for(var j:int = 0; j < 7; j++){
                    var p:Point = new Point(vertexList[0][j*2], vertexList[0][j*2+1]);
                    pointList[i][j] = p;
                }
            }
            addEventListener(Event.ENTER_FRAME, onEnterFrame);
        }
        
        private function onEnterFrame(e:Event):void{
            var ary:Array = getTime();
            for(var i:int = 0; i < 6; i++)
                if(timeList[i] != ary[i]){
                    timeList[i] = ary[i];
                    move(timeList[i], i);
                }
            
            for(i = 0; i < 6; i++){
                var sp:Sprite = spList[i];
                sp.graphics.clear();
                sp.graphics.lineStyle(3,0);
                sp.graphics.moveTo(pointList[i][0].x, pointList[i][0].y);
                for(var j:int = 1; j < 7; j++) sp.graphics.lineTo(pointList[i][j].x, pointList[i][j].y);
            }
        }
        
        private function getTime():Array{
            var date:Date = new Date();
            return [int(date.hours/10), date.hours%10, int(date.minutes/10), date.minutes%10, int(date.seconds/10), date.seconds%10];
        }
        
        private function move(n:int, s:int):void{
            var ary:Array = [];
            for(var i:int = 0; i < 7; i++) ary.push(BetweenAS3.to(pointList[s][i], {x:vertexList[n][2*i], y:vertexList[n][2*i+1]}, 0.8));
            BetweenAS3.parallelTweens(ary).play();
        }
    }
}