package matsu3d;

/**
 * ...
 * @author matsu4512
 */
class Matrix3D
{
	public var n11:Float;
	public var n12:Float;
	public var n13:Float;
	public var n14:Float;
	public var n21:Float;
	public var n22:Float;
	public var n23:Float;
	public var n24:Float;
	public var n31:Float;
	public var n32:Float;
	public var n33:Float;
	public var n34:Float;
	public var n41:Float;
	public var n42:Float;
	public var n43:Float;
	public var n44:Float;
	
	public function new(array:Array<Float>=null){
		reset(array);
	}
	
	public function reset(array:Array<Float>=null):Void{
		if(array == null || array.length != 16){
			n11 = n22 = n33 = n44 = 1;
			n12 = n13 = n14 = n21 = n23 = n24 = n31 = n32 = n34 = n41 = n42 = n43 = 0;
		}
		else{
			n11 = array[0]; n12 = array[1]; n13 = array[2]; n14 = array[3];
			n21 = array[4]; n22 = array[5]; n23 = array[6]; n24 = array[7];
			n31 = array[8]; n32 = array[9]; n33 = array[10]; n34 = array[11];
			n41 = array[12]; n42 = array[13]; n43 = array[14]; n44 = array[15];
		}
	}
	
	public function multiplyMatrix(A:Matrix3D):Matrix3D {
		return new Matrix3D([
			n11 * A.n11 + n12 * A.n21 + n13 * A.n31 + n14 * A.n41,
			n11 * A.n12 + n12 * A.n22 + n13 * A.n32 + n14 * A.n42,
			n11 * A.n13 + n12 * A.n23 + n13 * A.n33 + n14 * A.n43,
			n11 * A.n14 + n12 * A.n24 + n13 * A.n34 + n14 * A.n44,
			n21 * A.n11 + n22 * A.n21 + n23 * A.n31 + n24 * A.n41,
			n21 * A.n12 + n22 * A.n22 + n23 * A.n32 + n24 * A.n42,
			n21 * A.n13 + n22 * A.n23 + n23 * A.n33 + n24 * A.n43,
			n21 * A.n14 + n22 * A.n24 + n23 * A.n34 + n24 * A.n44,
			n31 * A.n11 + n32 * A.n21 + n33 * A.n31 + n34 * A.n41,
			n31 * A.n12 + n32 * A.n22 + n33 * A.n32 + n34 * A.n42,
			n31 * A.n13 + n32 * A.n23 + n33 * A.n33 + n34 * A.n43,
			n31 * A.n14 + n32 * A.n24 + n33 * A.n34 + n34 * A.n44,
			n41 * A.n11 + n42 * A.n21 + n43 * A.n31 + n44 * A.n41,
			n41 * A.n12 + n42 * A.n22 + n43 * A.n32 + n44 * A.n42,
			n41 * A.n13 + n42 * A.n23 + n43 * A.n33 + n44 * A.n43,
			n41 * A.n14 + n42 * A.n24 + n43 * A.n34 + n44 * A.n44
		]);
	}
	
	public function clone():Matrix3D {
		return new Matrix3D([
			n11, n12, n13, n14,
			n21, n22, n23, n24,
			n31, n32, n33, n34,
			n41, n42, n43, n44
		]);
	}

	public function multiplyVector(v:Vector3D):Vector3D{
		return new Vector3D(
			v.x*n11 + v.y*n12 + v.z*n13 + n14,
			v.x*n21 + v.y*n22 + v.z*n23 + n24,
			v.x*n31 + v.y*n32 + v.z*n33 + n34
		);
	}
	
	public function rotateX(rad:Float):Matrix3D {
		var m:Matrix3D = new Matrix3D(
			[
				1,             0,             0, 0,
				0, Math.cos(rad), -Math.sin(rad), 0,
				0, Math.sin(rad), Math.cos(rad), 0,
				0,             0,             0, 1
			]
		);
		return m.multiplyMatrix(this);
	}
	
	public function rotateY(rad:Float):Matrix3D{
		var m:Matrix3D = new Matrix3D(
			[
				 Math.cos(rad), 0, Math.sin(rad), 0,
				 0,             1,             0, 0,
				 -Math.sin(rad), 0, Math.cos(rad), 0,
				 0,             0,             0, 1
			]
		);
		return m.multiplyMatrix(this);
	}

	public function rotateZ(rad:Float):Matrix3D{
		var m:Matrix3D = new Matrix3D(
			[
				 Math.cos(rad), -Math.sin(rad), 0, 0,
				 Math.sin(rad), Math.cos(rad), 0, 0,
				 0,             0,             1, 0,
				 0,             0,             0, 1
			]
		);
		return m.multiplyMatrix(this);
	}
	
	public function translation(tx:Float, ty:Float, tz:Float):Matrix3D{
		var m:Matrix3D = new Matrix3D(
			[
				 1,  0,  0,  tx,
				 0,  1,  0,  ty,
				 0,  0,  1,  tz,
				 0,  0,  0,  1
			]
		);
		return m.multiplyMatrix(this);
	}
	
	public function scaling(sx:Float, sy:Float, sz:Float):Matrix3D{
		var m:Matrix3D = new Matrix3D(
			[
				sx,  0,  0,  0,
				0,  sy,  0,  0,
				0,  0,  sz,  0,
				0,  0,  0,  1
			]
		);
		return m.multiplyMatrix(this);
	}
}