
package;

import sys.io.File;
import haxe.ds.StringMap;
import Macros;

class DummyData
{
    public var number:Int;
    public var string:String;

    public function new()
    {
        Macros.log( "DummyData" );
        number = Std.int( 1000000 * Math.random() );
        string = "DEADBABE";
    }
}
