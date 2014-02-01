var gl;
var canvas;
var vMatrix, pMatrix, mvpMatrix;
var attLocation = [], attStride = [], uniLocation = [];
var pPos, pCol, pTextureCoord;
var particles = [];

var texture;
var prg;
var currentFrameBuffer, preFrameBuffer;

var PSIZE = 128;
var SIZE = 128;
var N = SIZE*SIZE, PN = PSIZE*PSIZE;
var pixels = new Uint8Array(N*4);

var offsetX1, offsetY1, offsetX2, offsetY2, offsetX3, offsetY3;
var offsetVX1, offsetVY1, offsetVX2, offsetVY2, offsetVX3, offsetVY3;
var colorTransform = [0.9, 0.95, 0.99, 0.83];

var stats = new Stats();

function setup(){
    setStats();
    canvas = document.getElementById("canvas");
    canvas.width = $(document).width();
    canvas.height = $(document).height();
    $(canvas).click(function(){
        colorTransform[0] = Math.random()*0.2+0.8;
        colorTransform[1] = Math.random()*0.2+0.8;
        colorTransform[2] = Math.random()*0.2+0.8;
        gl.uniform4fv(uniLocation[4], colorTransform);
        initialize();
    });

    gl = createGLContext(canvas);

    var vertexShader = loadShaderFromDOM("vs");
    var fragmentShader = loadShaderFromDOM("fs");
    prg = createProgram(vertexShader, fragmentShader);
    gl.useProgram(prg);

    attLocation[0] = gl.getAttribLocation(prg, 'position');
    attLocation[1] = gl.getAttribLocation(prg, 'color');
    attLocation[2] = gl.getAttribLocation(prg, 'textureCoord');

    attStride[0] = 3;
    attStride[1] = 4;
    attStride[2] = 2;

    uniLocation[0]  = gl.getUniformLocation(prg, 'mvpMatrix');
    uniLocation[1]  = gl.getUniformLocation(prg, 'texture');
    uniLocation[2]  = gl.getUniformLocation(prg, 'size');
    uniLocation[3]  = gl.getUniformLocation(prg, 'type');
    uniLocation[4]  = gl.getUniformLocation(prg, 'colorTransform');

    gl.uniform1i(uniLocation[1], 0);
    gl.uniform1f(uniLocation[2], SIZE);
    gl.uniform4fv(uniLocation[4], colorTransform);

    vMatrix   = mat4.identity(mat4.create());
    pMatrix   = mat4.identity(mat4.create());
    mvpMatrix = mat4.identity(mat4.create());
    mat4.lookAt([0, 0, 0.5], [0, 0, 0], [0, 1, 0], vMatrix);
    mat4.ortho(-1.0, 1.0, 1.0, -1.0, 0.1, 1, pMatrix);
    mat4.multiply(pMatrix, vMatrix, mvpMatrix);

    gl.depthFunc(gl.LEQUAL);
    gl.enable(gl.BLEND);
    gl.blendFunc(gl.SRC_ALPHA, gl.ONE);

    var position = [], color = [], textureCoord = [];
    position.push(
        -1.0, 1.0, 0.0,
         1.0, 1.0, 0.0,
        -1.0,-1.0, 0.0,
         1.0,-1.0, 0.0
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

    initialize();

    pPos = createBuffer(position);
    pCol = createBuffer(color);
    pTextureCoord = createBuffer(textureCoord);
    setAttribute([pPos, pCol, pTextureCoord], attLocation, attStride);

    createTexture();
    gl.activeTexture(gl.TEXTURE0);
    currentFrameBuffer = create_framebuffer(SIZE, SIZE);
    preFrameBuffer = create_framebuffer(SIZE, SIZE);

    onEnterFrame();
}

function initialize(){
    for(var i = 0; i < PSIZE; i++){
        for(var j = 0; j < PSIZE; j++){
            particles[i*PSIZE+j] = {x:j*SIZE/PSIZE, y:i*SIZE/PSIZE, vx:0, vy:0, ax:0, ay:0};
        }
    }
    offsetX1= SIZE*Math.random();
    offsetY1 = SIZE*Math.random();
    offsetX2= SIZE*Math.random();
    offsetY2 = SIZE*Math.random();
    offsetX3= SIZE*Math.random();
    offsetY3 = SIZE*Math.random();
    offsetVX1 = Math.random();
    offsetVY1 = Math.random();
    offsetVX2 = Math.random();
    offsetVY2 = Math.random();
    offsetVX3 = Math.random();
    offsetVY3 = Math.random();
}

function onEnterFrame(){
    for(var i = 0; i < 4*N; i++){
        pixels[i] = 0;
    }

    for(var i = 0; i < 50; i++){
        var p = particles[~~Math.random()*PN];
        p.x = Math.random()*SIZE;
        p.y = Math.random()*SIZE;
        p.vx = p.vy = p.ax = p.ay = 0;
    }

    for(var i = 0; i < PN; i++){
        var p = particles[i];
        var index = (~~p.y * SIZE + ~~p.x) * 4;
        var index1 = ~~(p.y+offsetY1)%SIZE*SIZE + ~~(p.x+offsetX1)%SIZE;
        var index2 = ~~(p.y+offsetY2)%SIZE*SIZE + ~~(p.x+offsetX2)%SIZE;
        var index3 = ~~(p.y+offsetY3)%SIZE*SIZE + ~~(p.x+offsetX3)%SIZE;
        pixels[index] = pixels[index+1] = pixels[index+2] = pixels[index+3] = 255;
        p.ax = (X1[index1]+X2[index2]+X3[index3]-45)*0.003;
        p.ay = (Y1[index1]+Y2[index2]+Y3[index3]-45)*0.003;
        p.x += p.vx;
        p.y += p.vy;
        p.vx += p.ax;
        p.vy += p.ay;
        if(p.x < 0) p.x = SIZE+p.x;
        else if(p.x >= SIZE) p.x = p.x-SIZE;
        if(p.y < 0) p.y = SIZE+p.y;
        else if(p.y >= SIZE) p.y = p.y-SIZE;
        p.vx *= 0.95;
        p.vy *= 0.95;
    }
    offsetX1 += offsetVX1;
    offsetY1 += offsetVY1;
    offsetX2 += offsetVX2;
    offsetY2 += offsetVY2;
    offsetX3 += offsetVX3;
    offsetY3 += offsetVY3;

    // {{{ フレームバッファに保存
    gl.bindFramebuffer(gl.FRAMEBUFFER, currentFrameBuffer.f);
    gl.clearColor(0.0, 0.0, 0.0, 1.0);
    gl.clearDepth(1.0);
    gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);
    //前のフレームを薄くして描画(青成分は強めに残す)
    gl.bindTexture(gl.TEXTURE_2D, preFrameBuffer.t);
    gl.uniform1i(uniLocation[3], 1);
    gl.drawArrays(gl.TRIANGLE_STRIP, 0, 4);

    //現在のフレームで計算されたパーティクルを描画(真っ白)
    gl.bindTexture(gl.TEXTURE_2D, texture);
    gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, SIZE, SIZE, 0, gl.RGBA, gl.UNSIGNED_BYTE, pixels);
    gl.uniform1i(uniLocation[3], 0);
    gl.uniformMatrix4fv(uniLocation[0], false, mvpMatrix);
    gl.drawArrays(gl.TRIANGLE_STRIP, 0, 4);
    gl.bindFramebuffer(gl.FRAMEBUFFER, null);
    // }}}

    //さらにBlurをかける
    gl.bindFramebuffer(gl.FRAMEBUFFER, preFrameBuffer.f);
    gl.clearColor(0.0, 0.0, 0.0, 1.0);
    gl.clearDepth(1.0);
    gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);
    gl.bindTexture(gl.TEXTURE_2D, currentFrameBuffer.t);
    gl.drawArrays(gl.TRIANGLE_STRIP, 0, 4);
    gl.bindFramebuffer(gl.FRAMEBUFFER, null);

    //画面に描画
    gl.bindTexture(gl.TEXTURE_2D, preFrameBuffer.t);
    gl.uniform1i(uniLocation[3], 2);
    gl.drawArrays(gl.TRIANGLE_STRIP, 0, 4);

    stats.update();
    requestAnimationFrame(onEnterFrame);
}

function createTexture(){
    var tex = gl.createTexture();
    gl.bindTexture(gl.TEXTURE_2D, tex);
    gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, SIZE, SIZE, 0, gl.RGBA, gl.UNSIGNED_BYTE, null);
    gl.generateMipmap(gl.TEXTURE_2D);
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR);
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR);
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

function create_framebuffer(width, height){
    var frameBuffer = gl.createFramebuffer();
    gl.bindFramebuffer(gl.FRAMEBUFFER, frameBuffer);
    var fTexture = gl.createTexture();
    gl.bindTexture(gl.TEXTURE_2D, fTexture);
    gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, width, height, 0, gl.RGBA, gl.UNSIGNED_BYTE, null);
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.NEAREST);
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.NEAREST);
    gl.framebufferTexture2D(gl.FRAMEBUFFER, gl.COLOR_ATTACHMENT0, gl.TEXTURE_2D, fTexture, 0);
    gl.bindTexture(gl.TEXTURE_2D, null);
    gl.bindFramebuffer(gl.FRAMEBUFFER, null);
    return {f : frameBuffer, t : fTexture};
}

function setStats(){
    stats.domElement.style.position = 'absolute';
    stats.domElement.style.left = '0px';
    stats.domElement.style.top = '0px';

    document.body.appendChild(stats.domElement);
}