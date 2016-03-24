
package;

import sys.io.File;
import haxe.ds.StringMap;
#if macro
import Macros;
import sys.io.File;
import sys.io.FileOutput;
#end

class Dummy
{
    public function new()
    {
        Macros.log( "Dummy" );
        m_dummyData = new DummyData();
        init();
    }

    public function init()
    {
        var strXml:String = File.getContent( "config.xml" );
        var xml:Xml = Xml.parse( strXml ).firstElement();

        for ( node in xml.elements() )
        {
            for ( data in node.elements() )
            {
                if ( data.nodeName == "index" )
                {
                    m_dummyData.number = Std.parseInt( data.firstChild().nodeValue );
                }
                if ( data.nodeName == "clip" )
                {
                    m_dummyData.string = data.firstChild().nodeValue;
                }
            }
        }
        buildJob();
        xml = null;
        strXml = null;
    }

    public function buildJob()
    {
#if macro
        trace( m_dummyData.number );
        trace( m_dummyData.string );

        var logFile:FileOutput = File.write( "log.txt", false );
        logFile.writeString( "BUILD: " + Date.now() + "\n" );
        logFile.writeString( " number: " + m_dummyData.number + "\n" );
        logFile.writeString( " string: " + m_dummyData.string + "\n" );
        logFile.close();
#end
    }

    private var m_dummyData:DummyData;
}
