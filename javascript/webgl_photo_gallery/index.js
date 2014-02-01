function init(){
    var R = 1000;
    for(var i = 0; i < 10; i++){
        for(var j = 0; j < 10; j++){
            var x = Math.cos(j/10*Math.PI*2)*R;
            var z = Math.sin(j/10*Math.PI*2)*R;
            var y = i*150;
            $("#image_div img:nth-child("+(i*10+j).toString()+")").css("-webkit-transform", "translateX("+x+"px) "+"translateY("+y+"px) "+"translateZ("+z+"px)");
            console.log("#image_div img:nth-child("+(i+j).toString()+")");
        }
    }
}


function submit(){
    $.ajax({
        type : 'GET',
        url : 'http://www.flickr.com/services/rest/',
        data : {
            format : 'json',
            method : 'flickr.photos.search', // 必須 :: 実行メソッド名
            api_key : '7320548afe4e4ec5dd13617d53666227', // 必須 :: API Key
            tags : $("#keyword").val(), // 任意 :: タグで検索
            per_page : '100' // 任意 :: 1回あたりの取得件数
        },
        dataType : 'jsonp',
        jsonp : 'jsoncallback' // Flickrの場合はjsoncallback
    }).done(function(data){
            images = [];
            var loadCnt = 0;
            $.each(data.photos.photo, function(i, item){
                    var itemFarm = item.farm;
                    var itemServer = item.server;
                    var itemID = item.id;
                    var itemSecret = item.secret;
                    var itemTitle = item.title;
                    var itemLink = 'http://www.flickr.com/photos/cbn_akey/' + itemID + '/'
                    var itemPath = 'http://farm' + itemFarm + '.static.flickr.com/' + itemServer + '/' + itemID + '_' + itemSecret + '_m.jpg'
                    var flickrSrc = '<img src="' + itemPath + '" alt="' + itemTitle + '" width="200" height="200">';
                    var htmlSrc = '<li><a href="' + itemLink + '" target="_blank">' + flickrSrc + '</a></li>'
                    $("#image_div").append(flickrSrc);
                }
            )
            init();
        }
    )
}