
import haxe.macro.Context;

class Main
{
	static function main()
    {
        var v1 = new Vector2D( 1, 2 );
        v1.add( new Vector2D( 3, 4 ) );
        trace( v1 );
	}
}

//------------------------------------------------------------------------------
class Vector2D
{
    public var x:Float;
    public var y:Float;

    public inline function new( x:Float = 0, y:Float = 0 )
    {
        this.x = x;
        this.y = y;
        //m_noPool = false; // <- Uncomment this on 3.3.0
    }

    public inline function add( a:Vector2D ):Void
    {
        Debug.assert( a.m_noPool, "not using pool" );
        x += a.x;
        y += a.y;
    }

    public inline function get_noPool():Bool
    {
        return m_noPool;
    }

    public function toString():String
    {
        return "[x:" + x + " y:" + y + "] noPool:" + m_noPool;
    }

    private var m_noPool:Bool;
}

//------------------------------------------------------------------------------
class Debug
{
    macro public inline static function assert( condition, #if macro message = null #else message = "" #end )
    {
        var cpos = Context.currentPos();
        var posExpr = Context.makeExpr( cpos, cpos );

        return macro
        {
            if ( !( $condition ) )
            {
                untyped trace( "\n[ASSERT]"
                        + ( ( $posExpr.fileName ).split( "/" ).pop() ) + ( ":" )
                        + ( $posExpr.lineNumber ) + ( ": " ) + ( $message ) );

            }
        }
    }
}

