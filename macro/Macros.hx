
package;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.ExprTools;

#if !macro @:build(Macros.build()) #end
class Macros
{
    macro static inline public function log( e ):Expr
    {
#if macro
        if ( onBuild )
        {
            trace( new haxe.macro.Printer().printExpr( e ) );
        }
#end
        return macro { };
    }

    macro static public function build():Array<Field>
    {
        onBuild = true;
        Macros.log( "BUILD START" );
        var dummy:Dummy = new Dummy();
        Macros.log( "BUILD END" );
        onBuild = false;
        return null;
    }

    static private var onBuild:Bool = false;
}
