
package;

import sys.io.File;
import haxe.Timer;
import haxe.ds.HashMap;

class Main
{
    public static inline var USE_XML:Bool = false;

	public static function main():Void
    {
#if HXCPP_TELEMETRY
        m_hxt = new hxtelemetry.HxTelemetry();
#end
        var t0 = stamp();
        var dummies:Array<Dummy> = new Array<Dummy>();
        var dummy:Dummy = null;

        for ( k in 1 ... 400000 )
        {
            dummy = new Dummy();
            if ( USE_XML )
            {
                dummy.init();
            }
            dummies.push( dummy );
            if ( k % 10000 == 0 )
            {
                updateTelemetry();
                trace( "k: " + k );
            }
        }
        var ms:Float = Math.round( (stamp() - t0) * 1000000.0 ) / 1000.0;
        updateTelemetry();
        trace( "\nTIMING: " + ms );

        for ( k in 1 ... 100000000 ) { }


        updateTelemetry();
        trace( "\nDELETING");
        dummies = null;
        updateTelemetry();

        for ( k in 1 ... 100000000 ) { }
#if cpp
        trace( "\nCOMPACTING");
        cpp.vm.Gc.compact();
        updateTelemetry();
#end
        while ( true ) { }
	}

    private static inline function stamp():Float
    {
#if cpp
        return untyped __global__.__time_stamp();
#else
        return 0;
#end
    }

	private static function updateTelemetry():Void
    {
#if HXCPP_TELEMETRY
        m_hxt.advance_frame();
#end
    }

#if HXCPP_TELEMETRY
    private static var m_hxt:hxtelemetry.HxTelemetry;
#end
}

@:unreflective
class Dummy
{
    public function new()
    {
        m_data = new Map<Int, DummyData>();

        if ( !Main.USE_XML )
        {
            var dummyData:DummyData = null;
            for ( k in 1 ... 15 )
            {
                dummyData = new DummyData();
                m_data.set( 2 * k, dummyData );
                m_counter += ( m_counter % 2 == 0 ) ? dummyData.number : -dummyData.number;
            }
        }
    }

    public function init()
    {
        var strXml:String = File.getContent( "config.xml" );
        var xml:Xml = Xml.parse( strXml ).firstElement();
        var k = 1;

        for ( node in xml.elements() )
        {
            var dummyData:DummyData = new DummyData();

            for ( data in node.elements() )
            {
                if ( data.nodeName == "a" )
                {
                    dummyData.number = Std.parseInt( data.firstChild().nodeValue );
                }
                if ( data.nodeName == "s" )
                {
                    dummyData.string = data.firstChild().nodeValue;
                }
            }
            m_data.set( 2 *k, dummyData );
        }

        xml = null;
        strXml = null;
    }

    private var m_data:Map<Int, DummyData>;
    private static var m_counter:Int;
}

@:unreflective
class DummyData
{
    public var number:Int;
    public var string:String;

    public function new()
    {
        number = Std.int( 1000000 * Math.random() );
        string = "DEADBABE";
    }
}
