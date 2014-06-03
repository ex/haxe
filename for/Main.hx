
@:build(FTW.build())

class Main {
	static function main() {
		//@for( { var i = 0, j = -5; } , i < 5 && j < 0, { i++; j++; } ) {
			//trace('Step $i, $j');
		//}
		@for( var i = 0, i < 10, i++ ) {
            if ( i % 2 == 0) continue;
			trace('Step $i');
            if ( i == 7 ) break;
		}

	}
}
