var canvas;
var ctx;
var mouseX = 232, mouseY = 232;

var balls = [];

function mouse(e){
    mouseX = e.clientX;
    mouseY = e.clientY;
}

function init(){
    document.getElementById("canvas").addEventListener("mousemove", mouse);
    canvas = document.getElementById("canvas");
    ctx=canvas.getContext("2d");
    draw();
}

function draw(){
    //塗りつぶし
    ctx.globalCompositeOperation = "source-over";
    ctx.fillStyle = "rgb(0, 0, 0)";
    ctx.fillRect(0, 0, 500, 500);

    //色の加算設定
    ctx.globalCompositeOperation = "lighter";

    for(var i = 0; i < 10; i++){
        var ball = {};
        ball.x = mouseX;
        ball.y = mouseY;
        ball.vx = Math.random()*10-5;
        ball.vy = Math.random()*10-7;
        ball.size = Math.random()*35+10;
        ball.r = Math.floor(Math.random()*128+127);
        ball.g = Math.floor(0.5*Math.random()*255);
        ball.b = Math.floor(0.5*Math.random()*255);
        ball.cx = mouseX;
        balls.push(ball);
    }

    i = balls.length;
    while(i--){
        ball = balls[i];
        ball.x += ball.vx;
        ball.y += ball.vy;
        ball.vy -= 0.4;
        ball.vx += (ball.cx-ball.x)/ball.size/2;
        ball.size -= 1.3;

        if(ball.size < 1){
            balls.splice(i,1);
            continue;
        }

        ctx.beginPath();
        var edgecolor1 = "rgba(" + ball.r + "," + ball.g + "," + ball.b + ","+(ball.size/20)+")";
        var edgecolor2 = "rgba(" + ball.r + "," + ball.g + "," + ball.b + ",0)";
        var gradblur = ctx.createRadialGradient(ball.x, ball.y, 0, ball.x, ball.y, ball.size);
        gradblur.addColorStop(0,edgecolor1);
        gradblur.addColorStop(1,edgecolor2);
        ctx.fillStyle = gradblur;
        ctx.arc(ball.x, ball.y, ball.size, 0, Math.PI*2, false);
        ctx.fill();
    }

    setTimeout(draw, 30);
}