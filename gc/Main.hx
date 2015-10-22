
package;

import sys.io.File;

class Main
{
    public static inline var USE_XML:Bool = true;

	public static function main():Void
    {
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
            if ( k % 1000 == 0 )
            {
                trace( "k: " + k );
            }
        }
        while ( true ) { };
	}
}

class Dummy
{
    public function new()
    {
        m_data = new Array<DummyData>();

        if ( !Main.USE_XML )
        {
            for ( k in 1 ... 15 )
            {
                m_data.push( new DummyData() );
            }
        }
    }

    public function init()
    {
        var strXml:String = File.getContent( "config.xml" );
        var xml:Xml = Xml.parse( strXml ).firstElement();

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
            m_data.push( dummyData );
        }

        xml = null;
        strXml = null;
    }

    private var m_data:Array<DummyData>;
}

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
