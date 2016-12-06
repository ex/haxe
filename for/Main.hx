
@:build(FTW.build())

class Main {
	static function main() {
		@for( { var i = 0, j = -5; } , i < 5 && j < 0, { i++; j++; } ) {
            if ( i + j  == -1 ) continue;
			trace( 'Step $i, $j' );
		}
		@for( var i = 0, i < 10, i++ ) {
            if ( i % 2 == 0) continue;
			trace('Step $i');
            if ( i == 7 ) break;
		}
        for ( i in 0 ... 10 )
        {
            trace( optional( i ) );
            trace( noOptional( i ) );
            trace( inlineOptional( i ) );
        }
	}

    private static function optional( x:Int = 0 ):Int
    {
        return 2 * x;
    }

    private static inline function inlineOptional( x:Int = 0 ):Int
    {
        return 2 * x;
    }

    private static function noOptional( x:Int ):Int
    {
        return 2 * x;
    }
}
