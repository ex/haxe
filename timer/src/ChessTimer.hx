/* ========================================================================== */
/*   Platform.hx                                                              */
/*   Copyright (c) 2015 Laurens Rodriguez Oscanoa.                            */
/* -------------------------------------------------------------------------- */
/*   This code is licensed under the MIT license:                             */
/*   http://www.opensource.org/licenses/mit-license.php                       */
/* -------------------------------------------------------------------------- */

import openfl.Assets;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Sprite;
import openfl.display.StageAlign;
import openfl.display.StageScaleMode;
import openfl.geom.Rectangle;
import openfl.geom.Point;
import openfl.Lib.current;
import openfl.Lib.getTimer;
import openfl.media.Sound;
import openfl.media.SoundChannel;
import openfl.media.SoundTransform;
import openfl.text.Font;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.text.TextFormatAlign;

class ChessTimer extends Sprite
{
    private static inline var SCREEN_WIDTH:Int = 320;
    private static inline var SCREEN_HEIGHT:Int = 480;

    private static inline var SOUND_VOLUME:Float = 0.4;

    //--------------------------------------------------------------------------
    public function new()
    {
        super();
        init();
#if ( android || ios || blackberry )
        resize( null );
#end
    }

    // Initializes platform.
    public function init():Void
    {
        current.stage.align = StageAlign.TOP_LEFT;
        current.stage.scaleMode = StageScaleMode.NO_SCALE;

        m_state = ST_START;
        m_initTimer = 1;

        // Load background and add it to scene
        addChild( new Bitmap( Assets.getBitmapData( "assets/images/back.png", false ) ) );

        m_canvasProgress = new Sprite();
        addChild( m_canvasProgress );

        m_bmpPause = new Bitmap( Assets.getBitmapData( "assets/images/top.png", false ) );
        addChild( m_bmpPause );

        var font:Font = Assets.getFont("assets/fonts/dd.otf");

        var textFormat:TextFormat = new TextFormat();
        textFormat.font = font.fontName;
        textFormat.size = 60;
        textFormat.letterSpacing = 3;
        textFormat.color = 0xFFFFFF;
        textFormat.align = TextFormatAlign.LEFT;

        var top:Sprite = new Sprite();
        top.rotation = 180;
        addChild( top );
        m_textUp = new TextField();
        m_textUp.embedFonts = true;
        m_textUp.selectable = false;
        m_textUp.defaultTextFormat = textFormat;
        m_textUp.width = SCREEN_WIDTH;
        top.addChild(m_textUp);
        m_textUp.text = "00:00:00";
        m_textUp.x = -( SCREEN_WIDTH + m_textUp.textWidth ) / 2;
        m_textUp.y = -( 0.25 * SCREEN_HEIGHT + m_textUp.textHeight / 2 );

        m_textDown = new TextField();
        m_textDown.embedFonts = true;
        m_textDown.selectable = false;
        m_textDown.defaultTextFormat = textFormat;
        m_textDown.width = SCREEN_WIDTH;
        addChild(m_textDown);
        m_textDown.text = "00:00:00";
        m_textDown.x = ( SCREEN_WIDTH - m_textDown.textWidth ) / 2;
        m_textDown.y = 0.75 * SCREEN_HEIGHT - m_textUp.textHeight / 2;

        // Registering events
        current.stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
        current.stage.addEventListener(Event.RESIZE, resize);

        // Load sound effects
        m_soundTouch = Assets.getSound("fx_touch");
        m_soundClick = Assets.getSound("fx_click");

        // Add control pads
        var alphaPad:Float = 0;
        m_padTop = new Sprite();
        drawBox(m_padTop, 0, 0, 320, 300, 0x00FFFF, alphaPad);
        m_padTop.x = 0;
        m_padTop.y = -70;
        addChild(m_padTop);
        m_padTop.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDownPads);

        m_padDown = new Sprite();
        drawBox(m_padDown, 0, 0, 320, 300, 0xFF00FF, alphaPad);
        m_padDown.x = 0;
        m_padDown.y = 250;
        addChild(m_padDown);
        m_padDown.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDownPads);

        m_padRestart = new Sprite();
        drawBox(m_padRestart, 0, 0, 56, 56, 0xFFFF00, alphaPad);
        m_padRestart.x = 48;
        m_padRestart.y = 212;
        addChild(m_padRestart);
        m_padRestart.addEventListener(MouseEvent.CLICK, onMouseDownPads);

        m_padPause = new Sprite();
        drawBox(m_padPause, 0, 0, 56, 56, 0xFFFF00, alphaPad);
        m_padPause.x = 132;
        m_padPause.y = 212;
        addChild(m_padPause);
        m_padPause.addEventListener(MouseEvent.CLICK, onMouseDownPads);

        m_padNext = new Sprite();
        drawBox(m_padNext, 0, 0, 56, 56, 0xFFFF00, alphaPad);
        m_padNext.x = 216;
        m_padNext.y = 212;
        addChild(m_padNext);
        m_padNext.addEventListener(MouseEvent.CLICK, onMouseDownPads);

        m_progressUp = new ProgressBar( top, m_textUp.x, m_textUp.y + 70, m_textUp.x + m_textUp.textWidth, 10, 0xFF7777, 0x770000 );
        m_progressDown = new ProgressBar( m_canvasProgress, m_textDown.x, m_textDown.y + 70, m_textDown.x + m_textDown.textWidth, 10, 0x7777FF, 0x000077 );

        resetTimers();

        var dummies:Array<Dummy> = new Array<Dummy>();
        for ( k in 1 ... 200000 )
        {
            dummies.push( new Dummy() );
            if ( k % 1000 == 0 )
            {
                trace( "k: " + k );
            }
        }
    }

    public function onMouseDownPads( event:MouseEvent ):Void
    {
        if ( event.target == m_padTop )
        {
            if ( m_state == ST_TOP_ACTIVE )
            {
                m_state = ST_DOWN_ACTIVE;
                m_soundTouch.play( 0, 0, new SoundTransform( SOUND_VOLUME ) );
            }
        }
        else if ( event.target == m_padDown )
        {
            if ( m_state == ST_DOWN_ACTIVE )
            {
                m_state = ST_TOP_ACTIVE;
                m_soundTouch.play( 0, 0, new SoundTransform( SOUND_VOLUME ) );
            }
        }
        else if ( event.target == m_padPause )
        {
            if ( m_state == ST_START )
            {
                onStart();
            }
            else
            {
                onPaused();
            }
        }
        else if ( event.target == m_padRestart )
        {
            if ( m_state == ST_PAUSED )
            {
                onRestart();
            }

        }
        else if ( event.target == m_padNext )
        {
            if ( m_state == ST_START )
            {
                m_initTimer = ( m_initTimer + 1 ) % 3;
                resetTimers();
                m_soundClick.play( 0, 0, new SoundTransform( SOUND_VOLUME ) );
            }
        }
    }

    // Called every frame
    public function onEnterFrame( event:Event ):Void
    {
        var currentTime:Float = getTimer();
        var timeDelta:Int = Std.int( currentTime - m_systemTime );
        m_systemTime = currentTime;

        switch ( m_state )
        {
            case ST_DOWN_ACTIVE:
                m_timerDown -= timeDelta;
                if ( m_timerDown <= 0 )
                {
                    m_timerDown = 0;
                    m_state = ST_END;
                }
                setTimerText( m_timerDown, m_textDown );
                m_progressDown.set( m_timerDown / m_time );

            case ST_TOP_ACTIVE:
                m_timerUp -= timeDelta;
                if ( m_timerUp <= 0 )
                {
                    m_timerUp = 0;
                    m_state = ST_END;
                }
                setTimerText( m_timerUp, m_textUp );
                m_progressUp.set( m_timerUp / m_time );
        }
    }

    private function resize( event:Event ):Void
    {
        var sx:Float = current.stage.stageWidth / SCREEN_WIDTH;
        var sy:Float = current.stage.stageHeight / SCREEN_HEIGHT;

        if ( sx > sy )
        {
            this.scaleX = this.scaleY = sy;
            this.x = ( current.stage.stageWidth - sy * SCREEN_WIDTH ) / 2;
        }
        else
        {
            this.scaleX = this.scaleY = sx;
            this.y = ( current.stage.stageHeight - sx * SCREEN_HEIGHT ) / 2;
        }
    }

    public static function drawBox( canvas:Sprite,
                                    iniX:Float, iniY:Float,
                                    width:Float, height:Float,
                                    colorBody:Int,
                                    alphaBody:Float = 1.0,
                                    borderSize:Float = 0,
                                    colorBorder:Int = 0,
                                    borderAlpha:Float = 0 ):Void
    {
        canvas.graphics.lineStyle( borderSize, colorBorder, borderAlpha );
        canvas.graphics.beginFill( colorBody, alphaBody );
        canvas.graphics.moveTo( iniX, iniY );
        canvas.graphics.lineTo( iniX, iniY + height );
        canvas.graphics.lineTo( iniX + width, iniY + height );
        canvas.graphics.lineTo( iniX + width, iniY );
        canvas.graphics.endFill();
    }

    private function setTimerText( time:Int, text:TextField ):Void
    {
        var ms:Int = Std.int( ( time % 1000 ) / 10 );
        var mm:Int = Std.int( time / 60000 );
        var ss:Int = Std.int( ( time % 60000 ) / 1000 );
        text.text = formatDigits( mm ) + ":" + formatDigits( ss ) + ":" + formatDigits( ms );
    }

    private inline function formatDigits( digits:Int ):String
    {
        return ( digits > 9 ) ? Std.string( digits ) : "0" + digits;
    }

    private function resetTimers():Void
    {
        m_time = 300000 * ( m_initTimer + 1 );
        m_timerDown = m_timerUp = m_time;
        setTimerText( m_time, m_textUp );
        setTimerText( m_time, m_textDown );

        m_progressUp.set( 1 );
        m_progressDown.set( 1 );
    }

    public function onStart():Void
    {
        m_state = ST_DOWN_ACTIVE;
        m_soundClick.play( 0, 0, new SoundTransform( SOUND_VOLUME ) );
        m_bmpPause.visible = false;
    }

    private function onRestart():Void
    {
        resetTimers();
        m_state = ST_START;
    }

    private function onPaused():Void
    {
        if ( m_state != ST_PAUSED )
        {
            m_oldState = m_state;
            m_state = ST_PAUSED;
            m_bmpPause.visible = true;
        }
        else
        {
            m_state = m_oldState;
            m_bmpPause.visible = false;
        }
        m_soundClick.play( 0, 0, new SoundTransform( SOUND_VOLUME ) );
    }

    // Entry point
    public static function main():Void
    {
#if (flash9 || flash10)
        haxe.Log.trace = function(v,?pos) { untyped __global__["trace"](pos.className+"#"+pos.methodName+"("+pos.lineNumber+"):",v); }
#elseif flash
        haxe.Log.trace = function(v,?pos) { flash.Lib.trace(pos.className+"#"+pos.methodName+"("+pos.lineNumber+"): "+v); }
#end
        current.addChild( new ChessTimer() );
    }

    private static inline var ST_START:Int = 0;
    private static inline var ST_PAUSED:Int = 1;
    private static inline var ST_TOP_ACTIVE:Int = 2;
    private static inline var ST_DOWN_ACTIVE:Int = 3;
    private static inline var ST_END:Int = 4;

    private var m_soundTouch:Sound;
    private var m_soundClick:Sound;

    private var m_bmpPause:Bitmap;
    private var m_canvasProgress:Sprite;

    private var m_padTop:Sprite;
    private var m_padDown:Sprite;
    private var m_padPause:Sprite;
    private var m_padRestart:Sprite;
    private var m_padNext:Sprite;

    private var m_textUp:TextField;
    private var m_textDown:TextField;

    private var m_time:Int;
    private var m_timerUp:Int;
    private var m_timerDown:Int;
    private var m_initTimer:Int;
    private var m_systemTime:Float;

    private var m_state:Int;
    private var m_oldState:Int;

    private var m_progressUp:ProgressBar;
    private var m_progressDown:ProgressBar;
}

//-------------------------------------------------------------------------------
class ProgressBar
{

    public function new( canvas:Sprite, x0:Float, y0:Float, x1:Float, height:Float, color:Int, backColor:Int )
    {
        m_canvas = canvas;
        m_color = color;
        m_backColor = backColor;
        m_x = x0;
        m_y = y0;
        m_width = x1 - x0;
        m_height = height + 6;
    }

    public function set( percent:Float )
    {
        ChessTimer.drawBox( m_canvas, m_x - 3, m_y - 3, m_width + 6, m_height + 6, m_color );
        //if ( percent < 1 )
        {
            ChessTimer.drawBox( m_canvas, m_x + percent * m_width, m_y, ( 1 - percent ) * m_width, m_height, m_backColor );
        }
    }

    public function free()
    {
        m_canvas = null;
    }

    private var m_x:Float;
    private var m_y:Float;
    private var m_width:Float;
    private var m_height:Float;
    private var m_canvas:Sprite;
    private var m_color:Int;
    private var m_backColor:Int;
}

//-------------------------------------------------------------------------------
class Dummy
{
    public function new()
    {
        var strXml:String = Assets.getText( "assets/xml/config.xml" );
        var xml:Xml = Xml.parse( strXml ).firstElement();

        m_data = new Array<DummyData>();
        for ( node in xml.elements() )
        {
            var param1:String = null;
            var param2:String = null;
            for ( data in node.elements() )
            {
                if ( data.nodeName == "a" )
                {
                    param1 = data.firstChild().nodeValue;
                }
                if ( data.nodeName == "s" )
                {
                    param2 = data.firstChild().nodeValue;
                }
            }
            m_data.push( new DummyData( param1, param2 ) );
        }
    }

    private var m_data:Array<DummyData>;
}

class DummyData
{
    public var number:Int;
    public var string:String;

    public function new( param1:String, param2:String )
    {
        number = Std.parseInt( param1 );
        string = param2;
        //trace( number + ": " + string );
    }
}
