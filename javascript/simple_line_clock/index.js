var canvas = document.getElementById("canvas");
var ctx=canvas.getContext("2d");

var W=465;
var H=465;

var vertexList = new Array(
  new Array(-25, -50,  25, -50,  25,  50, -25,  50, -25, -50, -25,  50,  25,  50),  //0
  new Array(  0, -50,   0,  50,   0, -50,   0,  50,   0, -50,   0,  50,   0, -50),  //1
  new Array(-25, -50,  25, -50,  25,   0, -25,   0, -25,  50,  25,  50, -25,  50),  //2
  new Array(-25,  50,  25,  50,  25,   0, -25,   0,  25,   0,  25, -50, -25, -50),  //3
  new Array(-25, -50, -25,   0,  25,   0,  25, -50,  25,  50,  25,   0, -25,   0),  //4
  new Array( 25, -50, -25, -50, -25,   0,  25,   0,  25,  50, -25,  50,  25,  50),  //5
  new Array(-25, -50, -25,  50,  25,  50,  25,   0, -25,   0,  25,   0,  25,  50),  //6
  new Array(-25, -50,  25, -50,  25,  50,  25, -50, -25, -50,  25, -50,  25,  50),  //7
  new Array(-25,   0,  25,   0,  25, -50, -25, -50, -25,  50,  25,  50,  25, -50),  //8
  new Array( 25,   0, -25,   0, -25, -50,  25, -50,  25,  50, -25,  50,  25,  50)   //9
);

var pointList = new Array(), toPointList = new Array(), dList = new Array, cntList = new Array(), timeList = new Array(0,0,0,0,0,0);
var initPosList = new Array(52, 200, 112, 200, 202, 200, 262, 200, 352, 200, 412, 200);

function init(){     
  for(var i = 0; i < 6; i++){
    pointList[i] = new Array();
    toPointList[i] = new Array();
    dList[i] = new Array();
    cntList[i] = new Array();
    for(var j = 0; j < 7; j++){
      var p = new Point(vertexList[0][j*2], vertexList[0][j*2+1]);
      pointList[i][j] = p;
      toPointList[i][j] = new Point(vertexList[0][j*2], vertexList[0][j*2+1]);
      dList[i][j] = new Point(0,0);
      cntList[i][j] = 20;
    }
  }
  setInterval(draw,33);
}

function draw(){
  ctx.fillStyle = "rgba(255, 255, 255, 1)";
  ctx.fillRect(0, 0, W, H);
  
  var ary = getTime();
  for(var i = 0; i < 6; i++){
    if(timeList[i] != ary[i]){
      timeList[i] = ary[i];
      move(timeList[i], i);
    }
  }
  for(i = 0; i < 6; i++){
    ctx.lineWidth = 3;
    ctx.beginPath();
    for(var j = 0; j < 7; j++){
      if(j == 0)ctx.moveTo(pointList[i][0].x+initPosList[i*2], pointList[i][0].y+initPosList[i*2+1]);
      else ctx.lineTo(pointList[i][j].x+initPosList[i*2], pointList[i][j].y+initPosList[i*2+1]);
      if(cntList[i][j] < 20){
        pointList[i][j].x += dList[i][j].x;
        pointList[i][j].y += dList[i][j].y;
        cntList[i][j]++;
      }
    }
    ctx.stroke();
  }
}

function getTime(){
  var date = new Date();
  return new Array(Math.floor(date.getHours()/10), date.getHours()%10, Math.floor(date.getMinutes()/10), date.getMinutes()%10, Math.floor(date.getSeconds()/10), date.getSeconds()%10);
}
    
function move(n, s){
  var ary = new Array();
  for(var i = 0; i < 7; i++){
    toPointList[s][i] = new Point(vertexList[n][2*i], vertexList[n][2*i+1]);
    var dx = toPointList[s][i].x-pointList[s][i].x;
    var dy = toPointList[s][i].y-pointList[s][i].y;
    dList[s][i] = new Point(dx/20.0, dy/20.0);
    cntList[s][i] = 0;
  }
}
  
var Point = function(x,y){
  this.x = x;
  this.y = y;
};
