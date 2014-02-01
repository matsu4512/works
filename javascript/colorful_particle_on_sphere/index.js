var gl;
var canvas;

var mMatrix, vMatrix, pMatrix, mvpMatrix, iMatrix, tmpMatrix;
var attLocation = [];
var attStride = [];
var uniLocation = [];
var l_attLocation = [];
var l_attStride = [];
var l_uniLocation = [];

var pPos;
var pCol;
var pTextureCoord;
var lPos;
var lCol;

var particles = [];
var position = [];
var color = [];
var textureCoord = [];

var l_position = [];
var l_color = [];

var texture;

var pre_frame;

var prg, l_prg;

var width = 512, height = 512;
var rotX = 0, rotY= 0, tRotX = 0, tRotY = 0;


var stats = new Stats();
var mouseX=0, mouseY=0;

function setup(){
    window.document.onmousemove = function(e){
        mouseX = e.pageX;
        mouseY = e.pageY;
    }

    setStats();

    canvas = document.getElementById("canvas");
    canvas.width = width = document.documentElement.clientWidth;
    canvas.height = height = document.documentElement.clientHeight;
    gl = createGLContext(canvas);

    var vertexShader = loadShaderFromDOM("vs");
    var fragmentShader = loadShaderFromDOM("fs");
    prg = createProgram(vertexShader, fragmentShader);

    var l_vertexShader = loadShaderFromDOM("vs2");
    var l_fragmentShader = loadShaderFromDOM("fs2");
    l_prg = createProgram(l_vertexShader, l_fragmentShader);

    attLocation[0] = gl.getAttribLocation(prg, 'position');
    attLocation[1] = gl.getAttribLocation(prg, 'color');
    attLocation[2] = gl.getAttribLocation(prg, 'textureCoord');
    l_attLocation[0] = gl.getAttribLocation(l_prg, 'position');
    l_attLocation[1] = gl.getAttribLocation(l_prg, 'color');

    attStride[0] = 3;
    attStride[1] = 4;
    attStride[2] = 2;
    l_attStride[0] = 3;
    l_attStride[1] = 4;

    uniLocation[0]  = gl.getUniformLocation(prg, 'mvpMatrix');
    uniLocation[1]  = gl.getUniformLocation(prg, 'texture');
    l_uniLocation[0]  = gl.getUniformLocation(l_prg, 'mvpMatrix');

    mMatrix   = mat4.identity(mat4.create());
    vMatrix   = mat4.identity(mat4.create());
    pMatrix   = mat4.identity(mat4.create());
    mvpMatrix = mat4.identity(mat4.create());
    iMatrix = mat4.identity(mat4.create());
    tmpMatrix = mat4.identity(mat4.create());

    gl.depthFunc(gl.LEQUAL);
    gl.enable(gl.BLEND);
    gl.blendFunc(gl.SRC_ALPHA, gl.ONE);

    for(var i = 0; i < 50; i++){
        var size = Math.random()*0.5+0.5;
        position.push(
            -size,  size,  0.0,
             size,  size,  0.0,
            -size, -size,  0.0,
             size, -size,  0.0
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
        particles[i].lat = 180*Math.random()-90;
        particles[i].lon = 360*Math.random();
        particles[i].velocity = [Math.random()-0.5, Math.random()-0.5, 0];
        particles[i].size = Math.random()*35*2+10*2;
    }
/*
    position.push(
        -1.0,  -1.0,  0.0,
        1.0,  -1.0,  0.0,
        -1.0, 1.0,  0.0,
        1.0, 1.0,  0.0
    );

    color.push(
        1.0, 1.0, 1.0, 1.0,
        1.0, 1.0, 1.0, 1.0,
        1.0, 1.0, 1.0, 1.0,
        1.0, 1.0, 1.0, 1.0
    );

    textureCoord.push(
        0.0, 0.0,
        1.0, 0.0,
        0.0, 1.0,
        1.0, 1.0
    );
*/
    pPos = createBuffer(position);
    pCol = createBuffer(color);
    pTextureCoord = createBuffer(textureCoord);
    setAttribute([pPos, pCol, pTextureCoord], attLocation, attStride);

    createTexture();

    gl.activeTexture(gl.TEXTURE0);
    gl.bindTexture(gl.TEXTURE_2D, texture);
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR);
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR);
    onEnterFrame();
}

function onEnterFrame(){
    tRotX += (height/2-mouseY)/30;
    tRotY += (width/2-mouseX)/30;
    rotX += (tRotX-rotX)/8;
    rotY += (tRotY-rotY)/8;
/*    if(tRotX < -90) tRotX = -90;
    else if(tRotX > 90) tRotX = 90;
    if(rotX < -90) rotX = -90;
    else if(rotX > 90) rotX = 90;
  */
    gl.clearColor(0.0, 0.0, 0.0, 1.0);
    gl.clearDepth(1.0);
    gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);

    gl.useProgram(prg);
    setAttribute([pPos, pCol, pTextureCoord], attLocation, attStride);

    gl.uniform1i(uniLocation[1], 0);

    var camPosition = [0, 0, 0];
    var radian = Math.PI/180;
    camPosition[0] = 0;//10*Math.cos(rotX * radian) * Math.sin(rotY * radian);
    camPosition[1] = 0;//10*Math.sin(rotX * radian);
    camPosition[2] = 10;//10*Math.cos(rotX * radian) * Math.cos(rotY * radian);

    mat4.lookAt(camPosition, [0, 0, 0], [0, 1, 0], vMatrix);

    mat4.perspective(45, canvas.width / canvas.height, 0.1, 1000, pMatrix);
    mat4.multiply(pMatrix, vMatrix, mvpMatrix);

    var i = particles.length;
    while(i--){
        var particle = particles[i];

        particle.lat += particle.velocity[0];
        particle.lon += particle.velocity[1];

        particle.translate[0] = 3*Math.cos(particle.lat * radian) * Math.sin(particle.lon * radian);
        particle.translate[1] = 3*Math.sin(particle.lat * radian);
        particle.translate[2] = 3*Math.cos(particle.lat * radian) * Math.cos(particle.lon * radian);

        mat4.rotate(iMatrix, rotX/180*Math.PI, [1,0,0], mMatrix);
        mat4.rotate(mMatrix, rotY/180*Math.PI, [0,1,0], mMatrix);
        mat4.translate(mMatrix, particle.translate, mMatrix);
        mat4.rotate(mMatrix, particle.lon/180*Math.PI, [0,1,0], mMatrix);
        mat4.rotate(mMatrix, -particle.lat/180*Math.PI, [1,0,0], mMatrix);
        mat4.multiply(mvpMatrix, mMatrix, tmpMatrix);
        gl.uniformMatrix4fv(uniLocation[0], false, tmpMatrix);
        gl.drawArrays(gl.TRIANGLE_STRIP, 4*i, 4);
    }
/*
    gl.bindTexture(gl.TEXTURE_2D, pre_frame);
    gl.uniform1f(uniLocation[2], 0.9);
    gl.uniformMatrix4fv(uniLocation[0], false, iMatrix);
    gl.drawArrays(gl.TRIANGLE_STRIP, 4*particles.length, 4);
*/
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
    gl.useProgram(l_prg);
    lPos = createBuffer(l_position);
    lCol = createBuffer(l_color);
    setAttribute([lPos, lCol], l_attLocation, l_attStride);
    var n = l_position.length/6;

    mat4.rotate(iMatrix, rotX/180*Math.PI, [1,0,0], mMatrix);
    mat4.rotate(mMatrix, rotY/180*Math.PI, [0,1,0], mMatrix);
    mat4.multiply(mvpMatrix, mMatrix, mvpMatrix);
    gl.uniformMatrix4fv(l_uniLocation[0], false, mvpMatrix);
    for(var i = 0; i < n; i++){
        gl.lineWidth(10.0);
        gl.drawArrays(gl.LINES, i*2, 2);
    }

/*
    gl.bindTexture(gl.TEXTURE_2D, pre_frame);
    gl.copyTexImage2D( gl.TEXTURE_2D, 0, gl.RGBA, 0, 0, 512, 512, 0 );
*/
    gl.flush();
    stats.update();
    setTimeout(onEnterFrame, 30);
}

function createTexture(){
    pre_frame = gl.createTexture()
    gl.bindTexture(gl.TEXTURE_2D, pre_frame);
    gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, 512, 512, 0, gl.RGBA, gl.UNSIGNED_BYTE, new Uint8Array(512*512*4));
    gl.generateMipmap(gl.TEXTURE_2D);

    var img_canvas = document.getElementById('img_canvas');
    img_canvas.width = 256;
    img_canvas.height = 256;
    var ctx = img_canvas.getContext('2d');
    ctx.beginPath();

    var gradblur = ctx.createRadialGradient(128, 128, 0, 128, 128, 128);
    gradblur.addColorStop(0,"rgba(0,0,0,0)");
    gradblur.addColorStop(0.4,"rgba(0,0,0,0)");
    gradblur.addColorStop(0.65,"rgba(255,255,255,0.9)");
    gradblur.addColorStop(0.65,"rgba(255,255,255,1)");
    gradblur.addColorStop(0.75,"rgba(255,255,255,1)");
    gradblur.addColorStop(0.75,"rgba(255,255,255,0.9)");
    gradblur.addColorStop(1,"rgba(0,0,0,0)");
    ctx.fillStyle = gradblur;
    ctx.arc(128, 128, 128, 0, Math.PI*2, false);
    ctx.fill();
    var data = ctx.getImageData(0, 0, 256, 256).data;

    var tex = gl.createTexture();
    gl.bindTexture(gl.TEXTURE_2D, tex);

    var pixels = new Uint8Array(256*256*4);
    for(var i = 0; i < 256*256*4; i++){
        pixels[i] = data[i];
    }
    ctx.clearRect(0,0,256,256);
    gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, 256, 256, 0, gl.RGBA, gl.UNSIGNED_BYTE, pixels);
    gl.generateMipmap(gl.TEXTURE_2D);
    gl.bindTexture(gl.TEXTURE_2D, null);
    texture = tex;
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