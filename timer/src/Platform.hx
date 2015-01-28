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

class Platform extends Sprite
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

        m_bmpPause = new Bitmap( Assets.getBitmapData( "assets/images/top.png", false ) );
        addChild( m_bmpPause );

        var font:Font = Assets.getFont("assets/fonts/dd.otf");

        var textFormat:TextFormat = new TextFormat();
        textFormat.font = font.fontName;
        textFormat.size = 70;
        textFormat.letterSpacing = 3;
        textFormat.color = 0xFFFFFFFF;
        textFormat.align = TextFormatAlign.LEFT;

        m_textUp = new TextField();
        m_textUp.embedFonts = true;
        m_textUp.selectable = false;
        m_textUp.defaultTextFormat = textFormat;
        m_textUp.width = SCREEN_WIDTH;
        addChild(m_textUp);
        m_textUp.text = "00:00:00";
        m_textUp.x = 30;
        m_textUp.y = 0.25 * SCREEN_HEIGHT - m_textUp.textHeight / 2;

        m_textDown = new TextField();
        m_textDown.embedFonts = true;
        m_textDown.selectable = false;
        m_textDown.defaultTextFormat = textFormat;
        m_textDown.width = SCREEN_WIDTH;
        addChild(m_textDown);
        m_textDown.text = "00:00:00";
        m_textDown.x = 30;
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
        drawBox(m_padTop, 0, 0, 320, 285, 0x00FFFF, alphaPad);
        m_padTop.x = 0;
        m_padTop.y = -55;
        addChild(m_padTop);
        m_padTop.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDownPads);

        m_padDown = new Sprite();
        drawBox(m_padDown, 0, 0, 320, 285, 0xFF00FF, alphaPad);
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

        resetTimers();
    }

    public function onMouseDownPads(event:MouseEvent):Void
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
                setTimerText( m_timerDown, m_textDown );

            case ST_TOP_ACTIVE:
                m_timerUp -= timeDelta;
                setTimerText( m_timerUp, m_textUp );
        }
    }

    private function resize(event:Event):Void
    {
        var sx:Float = current.stage.stageWidth / SCREEN_WIDTH;
        var sy:Float = current.stage.stageHeight / SCREEN_HEIGHT;
        if (sx > sy)
        {
            this.scaleX = this.scaleY = sy;
            this.x = (current.stage.stageWidth - sy * SCREEN_WIDTH) / 2;
        }
        else
        {
            this.scaleX = this.scaleY = sx;
        }
    }

    public static function drawBox(canvas:Sprite,
                                   iniX:Int,
                                   iniY:Int,
                                   width:Int,
                                   height:Int,
                                   colorBody:Int,
                                   alphaBody:Float = 1.0,
                                   borderSize:Float = 0,
                                   colorBorder:Int = 0,
                                   borderAlpha:Float = 0):Void
    {
        canvas.graphics.lineStyle(borderSize, colorBorder, borderAlpha);
        canvas.graphics.beginFill(colorBody, alphaBody);
        canvas.graphics.moveTo(iniX, iniY);
        canvas.graphics.lineTo(iniX, iniY + height);
        canvas.graphics.lineTo(iniX + width, iniY + height);
        canvas.graphics.lineTo(iniX + width, iniY);
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
        var time:Int = 300000 * ( m_initTimer + 1 );
        m_timerDown = m_timerUp = time;
        setTimerText( time, m_textUp );
        setTimerText( time, m_textDown );
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
        current.addChild(new Platform());
    }

    private static inline var ST_START:Int = 0;
    private static inline var ST_PAUSED:Int = 1;
    private static inline var ST_TOP_ACTIVE:Int = 2;
    private static inline var ST_DOWN_ACTIVE:Int = 3;

    private var m_soundTouch:Sound;
    private var m_soundClick:Sound;

    private var m_bmpPause:Bitmap;

    private var m_padTop:Sprite;
    private var m_padDown:Sprite;
    private var m_padPause:Sprite;
    private var m_padRestart:Sprite;
    private var m_padNext:Sprite;

    private var m_textUp:TextField;
    private var m_textDown:TextField;

    private var m_timerUp:Int;
    private var m_timerDown:Int;
    private var m_initTimer:Int;
    private var m_systemTime:Float;

    private var m_state:Int;
    private var m_oldState:Int;
}
