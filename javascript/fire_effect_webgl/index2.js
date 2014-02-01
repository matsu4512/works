var gl;
var canvas;

var mMatrix, vMatrix, pMatrix, mvpMatrix, iMatrix, tmpMatrix;
var attLocation = [];
var attStride = [];
var uniLocation = [];

var particles = [];
var position = [];
var color = [];
var texture;

var active=[], pool=[];

var stats = new Stats();

function setup(){
    setStats();

    canvas = document.getElementById("canvas");
    canvas.width = 465;
    canvas.height = 465;
    gl = createGLContext(canvas);

    var vertexShader = loadShaderFromDOM("vs");
    var fragmentShader = loadShaderFromDOM("fs");
    var prg = createProgram(vertexShader, fragmentShader);

    attLocation[0] = gl.getAttribLocation(prg, 'position');
    attLocation[1] = gl.getAttribLocation(prg, 'color');

    attStride[0] = 3;
    attStride[1] = 4;

    uniLocation[0]  = gl.getUniformLocation(prg, 'mvpMatrix');
    uniLocation[1]  = gl.getUniformLocation(prg, 'texture');
    uniLocation[2]  = gl.getUniformLocation(prg, 'size');

    mMatrix   = mat4.identity(mat4.create());
    vMatrix   = mat4.identity(mat4.create());
    pMatrix   = mat4.identity(mat4.create());
    mvpMatrix = mat4.identity(mat4.create());
    iMatrix = mat4.identity(mat4.create());
    tmpMatrix = mat4.identity(mat4.create());

    gl.depthFunc(gl.LEQUAL);
    gl.enable(gl.BLEND);
    gl.blendFunc(gl.SRC_ALPHA, gl.ONE);

    for(var i = 0; i < 1000; i++){
        position.push(2*Math.random()-1, 2*Math.random()-1, 2*Math.random()-1);
        color.push(Math.random()*0.5+0.5, Math.random()*0.5, Math.random()*0.5, 1);
        pool[i] = i;

        particles[i] = {};
        particles[i].translate = [0, 0, 0];
        particles[i].velocity = [0, 0, 0];
        particles[i].size = Math.random()*35*2+10*2;
    }
    var pPos = createBuffer(position);
    var pCol = createBuffer(color);
    setAttribute([pPos, pCol], attLocation, attStride);

    createTexture();

    onEnterFrame();
}

function onEnterFrame(){
    gl.clearColor(0.0, 0.0, 0.0, 1.0);
    gl.clearDepth(1.0);
    gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);

    gl.activeTexture(gl.TEXTURE0);
    gl.bindTexture(gl.TEXTURE_2D, texture);

    gl.uniform1i(uniLocation[1], 0);

    var camPosition = [0, 0, 600];
    mat4.lookAt(camPosition, [0, 0, 0], [0, 1, 0], vMatrix);
    mat4.perspective(45, canvas.width / canvas.height, 0.1, 1000, pMatrix);
    mat4.multiply(pMatrix, vMatrix, mvpMatrix);

    for(var i = 0; i < 15; i++){
        var index = pool.pop();
        active.push(index);
        particles[index].translate = [0, 0, 0];
        particles[index].velocity = [Math.random()*15-7.5, Math.random()*10-7, Math.random()*15-7.5];
        particles[index].size = Math.random()*35*2+10*2;
    }

    var i = active.length;
    while(i--){
        var index = active[i];
        var particle = particles[index];
        particle.translate[0] += particle.velocity[0];
        particle.translate[1] += particle.velocity[1];
        particle.translate[2] += particle.velocity[2];
        particle.velocity[0] += -(position[index*3]+particle.translate[0])/(particle.size);
        particle.velocity[1] += 0.4;
        particle.velocity[2] += -(position[index*3+2]+particle.translate[2])/(particle.size);
        particle.size -= 1.3;

        if(particle.size < 0){
            active.splice(i,1);
            pool.push(index);
            continue;
        }

        mat4.translate(iMatrix, particle.translate, mMatrix);
        mat4.multiply(mvpMatrix, mMatrix, tmpMatrix);
        gl.uniform1f(uniLocation[2], particle.size);
        gl.uniformMatrix4fv(uniLocation[0], false, tmpMatrix);
        gl.drawArrays(gl.POINTS, index, 1);
    }

    gl.flush();
    stats.update();
    setTimeout(onEnterFrame, 16);
}

function createTexture(){
    var ctx = document.getElementById('img_canvas').getContext('2d');
    ctx.beginPath();
    var edgecolor1 = "rgba(255,255,255,1)";
    var edgecolor2 = "rgba(255,255,255,0)";
    var gradblur = ctx.createRadialGradient(64, 64, 0, 64, 64, 64);
    gradblur.addColorStop(0,edgecolor1);
    gradblur.addColorStop(1,edgecolor2);
    ctx.fillStyle = gradblur;
    ctx.arc(64, 64, 64, 0, Math.PI*2, false);
    ctx.fill();
    var data = ctx.getImageData(0, 0, 128, 128).data;

    var tex = gl.createTexture();
    gl.bindTexture(gl.TEXTURE_2D, tex);

    var pixels = new Uint8Array(128*128*4);
    for(var i = 0; i < 128*128*4; i++){
        pixels[i] = data[i];
    }
    ctx.clearRect(0,0,128,128);
    gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, 128, 128, 0, gl.RGBA, gl.UNSIGNED_BYTE, pixels);
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