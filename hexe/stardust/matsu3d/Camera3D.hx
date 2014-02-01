package matsu3d;

/**
 * ...
 * @author matsu4512
 */
class Camera3D
{
	//public var x(get,set):Float;
    //public var y(get,set):Float;
    //public var z(get,set):Float;
	
	//視点
	public var eye:Vector3D;
	//注視点
	public var center:Vector3D;
	//上の方向
	public var up:Vector3D;
	
	public function new(x:Float=0, y:Float=0, z:Float=0)
	{
		eye = new Vector3D(x, y, z);
		center = new Vector3D(0, 0, 0);
		up = new Vector3D(0, 1, 0);
	}
	
	//注視点の変更
	public function lookAt(x:Float, y:Float, z:Float):Void{
		center.x = x;
		center.y = y;
		center.z = z;
	}
	
	//ビューイング変換をする行列を求める
	public function getViewingTransformMatrix():Matrix3D{
		//注視点からカメラ位置へと延びる線をZ軸とする。
		var n:Vector3D = center.sub(eye);
		n.normalize();
		
		//Z軸とupは直交しているので外積を求めることでX軸が得られる。
		var u:Vector3D = up.cross(n);
		u.normalize();
		
		//さらにX軸とZ軸の外積からY軸を求める。
		var v:Vector3D = n.cross(u);
		v.normalize();
		
		var d:Vector3D = new Vector3D(-eye.dot(u), -eye.dot(v), -eye.dot(n));
		var M:Matrix3D = new Matrix3D(
			[
				u.x, u.y, u.z, d.x,
				v.x, v.y, v.z, d.y,
				n.x, n.y, n.z, d.z,
				0,   0,   0,   1
			]
		);
		return M;
	}
	
	public function set_x(value:Float):Void { eye.x = value; }
	public function get_x():Float{ return eye.x; }
	public function set_y(value:Float):Void { eye.y = value; }
	public function get_y():Float{ return eye.y; }
	public function set_z(value:Float):Void { eye.z = value; }
	public function get_z():Float{ return eye.z; }	
}