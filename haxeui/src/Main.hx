
import haxe.ui.toolkit.core.Macros;
import haxe.ui.toolkit.core.Toolkit;
import haxe.ui.toolkit.core.Root;
import haxe.ui.toolkit.controls.Button;
import haxe.ui.toolkit.events.UIEvent;
import openfl.Lib;

class Main
{
    public static function main()
    {
        ////Macros.addStyleSheet( "assets/styles/gradient/gradient.css" );

        Toolkit.init();

        Toolkit.openFullscreen( function( root:Root ) {
            m_button = new Button();
            m_button.text = "Click me!";
            m_button.onClick = Main.onClickButton;
            root.addChild( m_button );
        });
    }

    private static function onClickButton( event:UIEvent ):Void
    {
        var x:Float = Lib.current.stage.stageWidth * Math.random() - m_button.width;
        m_button.x = ( x > 0 ) ? x : 0;
        var y:Float = Lib.current.stage.stageHeight * Math.random() - m_button.height;
        m_button.y = ( y > 0 ) ? y : 0;
    }

    private static var m_button:Button;
}
