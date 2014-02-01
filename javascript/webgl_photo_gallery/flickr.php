<?php
require('db2.php');
connect_db();

$api_key = "7320548afe4e4ec5dd13617d53666227";
$key_ary = array("green", "cyan", "blue", "purple", "violet", "nature", "fruit", "color");
$cnt = 0;

for($i = 0; $i < 8; $i++){
	for($j = 1; $j < 10; $j++){
		$keyword = $key_ary[$i];
		$page = $j;
		$per_page = 500;
		
		$url = "http://api.flickr.com/services/rest/?+method=flickr.photos.search&api_key=$api_key&tags=$keyword&per_page=$per_page&page=$page&license=4&extras=owner_name";
		if($result = file_get_contents($url)){
			echo "keyword:$key_ary[$i], page:$j\n";
		}
		else{
			echo "file_get_contents error\n";
			exit(1);
		}
		$xml = simplexml_load_string($result);
		foreach($xml->photos->photo as $photo){
			$attr = $photo->attributes();
			$id = $attr->id;
			$owner = $attr->owner;
			$server = $attr->server;
			$farm = $attr->farm;
			$secret = $attr->secret;
			$title = $attr->title;
			$owner_name = $attr->ownername;
			$image_url = "http://farm".$farm.".static.flickr.com/".$server."/".$id."_".$secret.".jpg";
			if($data = file_get_contents($image_url)){
			}
			else{
				echo "file_get_contentsエラー:$cnt\n";
				continue;
			}
			$original_path = "images2/original/$cnt.jpg";
			$thumb_path = "images2/thumb/$cnt.jpg";
			$page_url = "http://www.flickr.com/photos/$owner/$id";
			file_put_contents($original_path, $data);
			if(!resize_jpg_image($original_path, $thumb_path, 50, 50)){
				echo "jpegエラー:$cnt\n";
			}
			$hsv = extract_color($thumb_path);
			
			mysql_query("INSERT INTO master VALUES(null, '$id', '$page_url', '$image_url', '$thumb_path', '$owner_name', '$title', $hsv[0], $hsv[1], $hsv[2], $hsv[3]);");
			
			$cnt++;
		}
	}
}
close_db();

function resize_jpg_image($path, $save_path, $new_width, $new_height){
	$image = imagecreatefromjpeg($path);
	//画像サイズの取得
	$size_info = getimagesize($path);
	preg_match_all("/[0-9]+/i", $size_info[3], $match);
	$width = $match[0][0];
	$height = $match[0][1];
	//リサイズ処理
	if($img = ImageCreateFromJPEG($path)){
	}
	
	else{
		return false;
	}
	
	if($new_img = ImageCreateTrueColor($new_width, $new_height)){
	}
	else{
		return false;
	}
	
	if(!ImageCopyResampled($new_img,$img,0,0,0,0,$new_width,$new_height,$width,$height)){
		return false;
	}
	//保存
	if(ImageJPEG($new_img, $save_path, 70)){
	}
	else{
		return false;
	}
	
	return true;
}

/**
	入力: 画像
	出力: 全ピクセル値の平均のHSV形式と分散の抽出
*/
function extract_color($file_name){
	$image = imagecreatefromjpeg($file_name);
	//画像サイズの取得
	$size_info = getimagesize($file_name);
	preg_match_all("/[0-9]+/i", $size_info[3], $match);
	$width = $match[0][0];
	$height = $match[0][1];
	
	//ピクセル値の平均を計算する
	$ave_r = $ave_g = $ave_b = 0;
	$var_r = $var_g = $var_b = 0;
	for($y = 0; $y < $height; $y++){
		for($x = 0; $x < $width; $x++){
			$rgb = imagecolorat($image, $x, $y);
			$ave_r += ($rgb>>16) & 0xFF;
			$ave_g += ($rgb>> 8) & 0xFF;
			$ave_b += ($rgb)     & 0xFF;
			$var_r += (($rgb>>16) & 0xFF) * (($rgb>>16) & 0xFF);
			$var_g += (($rgb>>8)  & 0xFF) * (($rgb>>8)  & 0xFF);
			$var_b += (($rgb)     & 0xFF) * (($rgb)     & 0xFF);
		}
	}
	$ave_r /= $width*$height;
	$ave_g /= $width*$height;
	$ave_b /= $width*$height;
	$var_r /= $height*$width;
	$var_g /= $height*$width;
	$var_b /= $height*$width;
	$var_r -= $ave_r*$ave_r;
	$var_g -= $ave_g*$ave_g;
	$var_b -= $ave_b*$ave_b;
	
	//HSV色空間に変換
	$hsv = rgb2hsv(array((int)$ave_r, (int)$ave_g, (int)$ave_b));
	$hsv[3] = round(($var_r+$var_g+$var_b)/3);
	return $hsv;
}

/**
	入力:RGB
	出力:HSV
*/
function rgb2hsv($arr){
	$h = $s = $v = 0;
 
	$max = max($arr);
	$min = min($arr);
 
	if ($max == $min) {
		$h = 0;
	} else if ($max == $arr[0]) {
		$h = 60 * ($arr[1] - $arr[2]) / ($max - $min) + 0;
	} else if ($max == $arr[1]) {
		$h = (60 * ($arr[2] - $arr[0]) / ($max - $min)) + 120;
	} else {
		$h = (60 * ($arr[0] - $arr[1]) / ($max - $min)) + 240;
	}
 
	while ($h < 0) {
		$h += 360;
	}
 
	if ($max == 0) {
		$s = 0;
	} else {
		$s = ($max - $min) / $max * 255;
	}
 
	$v = $max;
 
	return array($h,$s,$v);
}

?>