var gl;
var canvas;

var mMatrix, vMatrix, pMatrix, mvpMatrix, iMatrix, tmpMatrix;
var attLocation = [];
var attStride = [];
var uniLocation = [];

var pPos;
var pCol;
var pTextureCoord;

var particles = [];
var position = [];
var color = [];
var textureCoord = [];

var texture = [];

var prg;

var width, height;

var time = [0,0,0,0,0,0], pre_time = [0,0,0,0,0,0];
var time_particle = [0,10,20,30,40,50];

var stats = new Stats();

function setup(){

    setStats();

    canvas = document.getElementById("canvas");
    canvas.width = width = $(document).width();
    canvas.height = height = $(document).height();
    gl = createGLContext(canvas);

    var vertexShader = loadShaderFromDOM("vs");
    var fragmentShader = loadShaderFromDOM("fs");
    prg = createProgram(vertexShader, fragmentShader);

    attLocation[0] = gl.getAttribLocation(prg, 'position');
    attLocation[1] = gl.getAttribLocation(prg, 'color');
    attLocation[2] = gl.getAttribLocation(prg, 'textureCoord');

    attStride[0] = 3;
    attStride[1] = 4;
    attStride[2] = 2;

    uniLocation[0]  = gl.getUniformLocation(prg, 'mvpMatrix');
    uniLocation[1]  = gl.getUniformLocation(prg, 'texture');
    uniLocation[2]  = gl.getUniformLocation(prg, 'alpha');

    mMatrix   = mat4.identity(mat4.create());
    vMatrix   = mat4.identity(mat4.create());
    pMatrix   = mat4.identity(mat4.create());
    mvpMatrix = mat4.identity(mat4.create());
    iMatrix = mat4.identity(mat4.create());
    tmpMatrix = mat4.identity(mat4.create());

    gl.depthFunc(gl.LEQUAL);
    gl.enable(gl.BLEND);
    gl.blendFunc(gl.SRC_ALPHA, gl.ONE);

    for(var i = 0; i < 60; i++){
        position.push(
            -1.0,  1.0,  0.0,
            1.0,  1.0,  0.0,
            -1.0, -1.0,  0.0,
            1.0, -1.0,  0.0
        );

        var r = Math.random(), g = Math.random(), b = Math.random(), a =1;
        color.push(
            r, g, b, a,
            r, g, b, a,
            r, g, b, a,
            r, g, b, a
        );

        textureCoord.push(
            0.0, 0.0,
            1.0, 0.0,
            0.0, 1.0,
            1.0, 1.0
        );

        particles[i] = {};
        particles[i].translate = [0, 0, 0];
        particles[i].tmpPos = [0, 0, 0];
        particles[i].lat = 180*Math.random()-90;
        particles[i].lon = 360*Math.random();
        particles[i].tmpLat = 0;
        particles[i].tmpLon = 0;
        particles[i].fn = 0;
        particles[i].velocity = [Math.random()-0.5, Math.random()-0.5, 0];
        particles[i].size = Math.random()*35*2+10*2;
        particles[i].status = 0;
        particles[i].time_position = 0;
    }

    for(var i = 0; i < 6; i++){
        var j = 0;
        while(particles[time[i]+10*j].status != 0){
            j++;
        }
        var p = particles[time[i]+10*j];
        p.status = 2;
        p.time_position = i;
        time_particle[i] = time[i]+10*j;
    }

    pPos = createBuffer(position);
    pCol = createBuffer(color);
    pTextureCoord = createBuffer(textureCoord);
    setAttribute([pPos, pCol, pTextureCoord], attLocation, attStride);

    createTexture();

    for(var i = 0; i < 10; i++){
        gl.activeTexture(gl.TEXTURE0+i);
        gl.bindTexture(gl.TEXTURE_2D, texture[i]);
        gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR);
        gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR);
    }
    onEnterFrame();
}

function updateTime(){
    pre_time[0] = time[0];
    pre_time[1] = time[1];
    pre_time[2] = time[2];
    pre_time[3] = time[3];
    pre_time[4] = time[4];
    pre_time[5] = time[5];

    var date = new Date();
    var h = date.getHours();
    var m = date.getMinutes();
    var s = date.getSeconds();
    if(h.length == 1) time[0]  = 0;
    else time[0] = Math.floor(h/10);
    time[1] = h%10;
    time[2] = Math.floor(m/10);
    time[3] = m%10;
    time[4] = Math.floor(s/10);
    time[5] = s%10;

    for(var i = 0; i < 6; i++){
        if(time[i] == pre_time[i]) continue;
        particles[time_particle[i]].status = 3;
        particles[time_particle[i]].fn = 0;
        var j = 0;
        while(particles[time[i]+10*j].status != 0){
            j++;
        }
        var p = particles[time[i]+10*j];
        p.status = 1;
        p.tmpPos[0] = p.translate[0];
        p.tmpPos[1] = p.translate[1];
        p.tmpPos[2] = p.translate[2];
        p.tmpLat = p.lat;
        p.tmpLon = p.lon;
        p.fn = 0;
        p.time_position = i;
        time_particle[i] = time[i]+10*j;
    }
}

function tween(origin, target, current_frame, goal_frame){
    var diff = target-origin;
    var result = origin+diff*current_frame/goal_frame;
    return result;
}

function backIn(origin, target, current_frame, goal_frame){
    var diff = target - origin;
    return diff * (current_frame /= goal_frame) * current_frame * ((1.70158 + 1) * current_frame - 1.70158) + origin;
}

function backOut(origin, target, current_frame, goal_frame){
    var diff = target - origin;
    return diff * ((current_frame = current_frame / goal_frame - 1) * current_frame * ((1.70158 + 1) * current_frame + 1.70158) + 1) + origin;
}


function onEnterFrame(){
    updateTime();

    gl.clearColor(0.0, 0.0, 0.0, 1.0);
    gl.clearDepth(1.0);
    gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);

    gl.useProgram(prg);
    setAttribute([pPos, pCol, pTextureCoord], attLocation, attStride);

    var camPosition = [0, 0, 0];
    var radian = Math.PI/180;
    camPosition[0] = 0;
    camPosition[1] = 0;
    camPosition[2] = 10;

    mat4.lookAt(camPosition, [0, 0, 0], [0, 1, 0], vMatrix);

    mat4.perspective(45, canvas.width / canvas.height, 0.1, 1000, pMatrix);
    mat4.multiply(pMatrix, vMatrix, mvpMatrix);

    var i = particles.length;
    while(i--){
        gl.uniform1i(uniLocation[1], i%10);
        var particle = particles[i];

        particle.lat += particle.velocity[0];
        particle.lon += particle.velocity[1];
        if(particle.lat > 180) particle.lat -= 360;
        if(particle.lat < -180) particle.lat += 360;
        if(particle.lon > 180) particle.lon -= 360;
        if(particle.lon < -180) particle.lon += 360;

        particle.translate[0] = 3*Math.cos(particle.lat * radian) * Math.sin(particle.lon * radian);
        particle.translate[1] = 3*Math.sin(particle.lat * radian);
        particle.translate[2] = 3*Math.cos(particle.lat * radian) * Math.cos(particle.lon * radian);
        if(particle.status == 0){
            mat4.translate(iMatrix, particle.translate, mMatrix);
            mat4.rotate(mMatrix, particle.lon/180*Math.PI, [0,1,0], mMatrix);
            mat4.rotate(mMatrix, -particle.lat/180*Math.PI, [1,0,0], mMatrix);
         //   mat4.scale(mMatrix, [0.5,0.5,0.5], mMatrix);
            mat4.multiply(mvpMatrix, mMatrix, tmpMatrix);
            gl.uniform1f(uniLocation[2], 1.1-Math.abs(particle.translate[2]/3));
        }
        else if(particle.status == 1){
            particle.fn++;
            var x = backOut(particle.tmpPos[0], -1.85+0.7*particle.time_position+Math.floor(particle.time_position*0.5)*0.2, particle.fn, 20)
            var y = backOut(particle.tmpPos[1], 0, particle.fn, 20);
            var z = backOut(particle.tmpPos[2], 0, particle.fn, 20);
            var rx = backOut(particle.tmpLat, 0, particle.fn, 20);
            var ry = backOut(particle.tmpLon, 0, particle.fn, 20);
            mat4.translate(iMatrix, [x, y, z], mMatrix);
            mat4.rotate(mMatrix, ry/180*Math.PI, [0,1,0], mMatrix);
            mat4.rotate(mMatrix, -rx/180*Math.PI, [1,0,0], mMatrix);
            mat4.multiply(mvpMatrix, mMatrix, tmpMatrix);
            if(particle.fn == 20) particle.status = 2;
            gl.uniform1f(uniLocation[2], 1.1-z/3);
        }
        else if(particle.status == 2){
            mat4.translate(iMatrix, [-1.85+0.7*particle.time_position+Math.floor(particle.time_position*0.5)*0.2, 0, 0], mMatrix);
            mat4.multiply(mvpMatrix, mMatrix, tmpMatrix);
            gl.uniform1f(uniLocation[2], 1.0);
        }
        else if(particle.status == 3){
            particle.fn++;
            var x = backIn(-1.85+0.7*particle.time_position+Math.floor(particle.time_position*0.5)*0.2, particle.translate[0], particle.fn, 20)
            var y = backIn(0, particle.translate[1], particle.fn, 20);
            var z = backIn(0, particle.translate[2], particle.fn, 20);
            var rx = backIn(0, particle.lat, particle.fn, 20);
            var ry = backIn(0, particle.lon, particle.fn, 20);
            mat4.translate(iMatrix, [x, y, z], mMatrix);
            mat4.rotate(mMatrix, ry/180*Math.PI, [0,1,0], mMatrix);
            mat4.rotate(mMatrix, -rx/180*Math.PI, [1,0,0], mMatrix);
            mat4.multiply(mvpMatrix, mMatrix, tmpMatrix);
            if(particle.fn == 20) particle.status = 0;
            gl.uniform1f(uniLocation[2], 1.1-Math.abs(z/3));
        }
        gl.uniformMatrix4fv(uniLocation[0], false, tmpMatrix);
        gl.drawArrays(gl.TRIANGLE_STRIP, 4*i, 4);
    }

    l_position = [];
    l_color = [];
    for(var i = 0; i < particles.length; i++){
        for(var j = 0; j < i; j++){
            var p1 = particles[i].translate, p2 = particles[j].translate;
            var d = (p1[0]-p2[0])*(p1[0]-p2[0]) + (p1[1]-p2[1])*(p1[1]-p2[1]) + (p1[2]-p2[2])*(p1[2]-p2[2]);
            if(d < 10){
                l_position.push(
                    p1[0],  p1[1],  p1[2],
                    p2[0],  p2[1],  p2[2]
                );
                l_color.push(
                    color[i*16], color[i*16+1], color[i*16+2], 1-d/10,
                    color[j*16], color[j*16+1], color[j*16+2], 1-d/10
                );
            }
        }
    }

    gl.flush();
    stats.update();
    setTimeout(onEnterFrame, 30);
}

function createTexture(){
    var img_canvas = document.getElementById('img_canvas');
    img_canvas.width = 128;
    img_canvas.height = 128;
    var ctx = img_canvas.getContext('2d');

    ctx.fillStyle = "white";
    ctx.font = "80px 'ＭＳ ゴシック'";
    ctx.textAlign = "center";
    ctx.textBaseline = "middle";

    for(var i = 0; i < 10; i++){
        ctx.fillStyle = "black";
        ctx.fillRect(0,0,128,128);
        //塗りつぶしのテキストを、座標(20, 75)の位置に最大幅200で描画する
        ctx.fillStyle = "white";
        ctx.fillText(i.toString(), 64, 64);

        var data = ctx.getImageData(0, 0, 128, 128).data;

        var tex = gl.createTexture();
        gl.bindTexture(gl.TEXTURE_2D, tex);

        var pixels = new Uint8Array(128*128*4);
        for(var j = 0; j < 128*128*4; j++){
            pixels[j] = data[j];
        }
        ctx.clearRect(0,0,128,128);
        gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, 128, 128, 0, gl.RGBA, gl.UNSIGNED_BYTE, pixels);
        gl.generateMipmap(gl.TEXTURE_2D);
        gl.bindTexture(gl.TEXTURE_2D, null);
        texture[i] = tex;
    }
    $("#img_canvas").remove();
}

function createGLContext(canvas){
    var names = ["webgl", "experimental-webgl"];
    var context = null;
    for(var i = 0; i < names.length; i++){
        try{
            context = canvas.getContext(names[i]);
        } catch (e){}
        if(context){
            break;
        }
    }

    if(context){
        context.viewportWidth = canvas.width;
        context.viewportHeight = canvas.height;
    }
    else{
        alert("Faild to create WebGL context!");
    }
    return context;
}

function loadShaderFromDOM(id){
    var shaderScript = document.getElementById(id);

    if(!shaderScript){
        return null;
    }

    var shaderSource = "";
    var currentChild = shaderScript.firstChild;
    while(currentChild){
        if(currentChild.nodeType == 3){
            shaderSource += currentChild.textContent;
        }
        currentChild = currentChild.nextSibling;
    }

    var shader;
    if(shaderScript.type == "x-shader/x-fragment"){
        shader = gl.createShader(gl.FRAGMENT_SHADER);
    } else if(shaderScript.type == "x-shader/x-vertex"){
        shader = gl.createShader(gl.VERTEX_SHADER);
    } else{
        return null;
    }

    gl.shaderSource(shader, shaderSource);
    gl.compileShader(shader);

    if(!gl.getShaderParameter(shader, gl.COMPILE_STATUS)){
        alert("Error compiling shader", gl.getShaderInfoLog(shader));
        gl.deleteShader(shader);
        return null;
    }
    return shader;
}

function createProgram(vs, fs){
    var program = gl.createProgram();

    gl.attachShader(program, vs);
    gl.attachShader(program, fs);

    gl.linkProgram(program);

    if(gl.getProgramParameter(program, gl.LINK_STATUS)){
        gl.useProgram(program);
        return program;
    }else{
        alert(gl.getProgramInfoLog(program));
    }
}

function createBuffer(data){
    var buffer = gl.createBuffer();
    gl.bindBuffer(gl.ARRAY_BUFFER, buffer);
    var arr = new Float32Array(data);
    gl.bufferData(gl.ARRAY_BUFFER, arr, gl.STATIC_DRAW);
    gl.bindBuffer(gl.ARRAY_BUFFER, null);
    return buffer;
}

function createIndexBuffer(data){
    var buffer = gl.createBuffer();
    gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, buffer);
    gl.bufferData(gl.ELEMENT_ARRAY_BUFFER, new Int16Array(data), gl.STATIC_DRAW);
    gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, null);
    return buffer;
}

function setAttribute(buffers, attL, attS){
    for(var i in buffers){
        gl.bindBuffer(gl.ARRAY_BUFFER, buffers[i]);
        gl.enableVertexAttribArray(attL[i]);
        gl.vertexAttribPointer(attL[i], attS[i], gl.FLOAT, false, 0, 0);
    }
}

function setStats(){
    stats.domElement.style.position = 'absolute';
    stats.domElement.style.left = '0px';
    stats.domElement.style.top = '0px';

    document.body.appendChild(stats.domElement);
}