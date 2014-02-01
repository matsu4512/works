package matsu3d;

/**
 * ...
 * @author matsu4512
 */
class Vector3D
{
	public var x:Float;
	public var y:Float;
	public var z:Float;
	
	public function new(x:Float=0.0, y:Float=0.0, z:Float=0.0) 
	{
		this.x = x;
		this.y = y;
		this.z = z;
	}
	
	public function clone():Vector3D {
		return new Vector3D(x, y, z);
	}
	
    public function distance(v:Vector3D):Float {
		return Math.sqrt((x-v.x)*(x-v.x)+(y-v.y)*(y-v.y)+(z-v.z)*(z-v.z));
    }
        
	public function sub(v:Vector3D):Vector3D{
        return new Vector3D(x-v.x, y-v.y, z-v.z);
    }

	public function add(v:Vector3D):Vector3D{
		return new Vector3D(x+v.x, y+v.y, z+v.z);
    }
        
    public function dot(v:Vector3D):Float{
		return x*v.x + y*v.y + z*v.z;
    }

	public function cross(v:Vector3D):Vector3D{
        return new Vector3D(y*v.z - z*v.y, z*v.x - x*v.z, x*v.y - y*v.x);
    }
        
    public function normalize():Void{
		var d:Float = norm();
		x /= d;
		y /= d;
		z /= d;
	}
        
    public function norm():Float{
        return Math.sqrt(x*x+y*y+z*z);
	}

    public function getPerspective(f:Float):Vector2D{
		return new Vector2D(f / (z + f) * x, f / (z + f) * y);
	}
}
