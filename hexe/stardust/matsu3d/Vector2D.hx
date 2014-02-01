package matsu3d;

/**
 * ...
 * @author matsu4512
 */
class Vector2D
{
	public var x:Float;
	public var y:Float;
	
	public function new(x:Float, y:Float) 
	{
		this.x = x;
		this.y = y;
	}
	
	public function clone() {
		return new Vector2D(x, y);
	}
	
}