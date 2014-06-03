
import haxe.macro.Expr;
import haxe.macro.Context;

class FTW {
	public static function build() {
		return haxe.macro.Context.getBuildFields().map(transformField);
	}

	static function transformField(field:Field) {
		switch (field.kind) {
			case FFun(f): transformExpr(f.expr);
			default:
		}
		return field;
	}

	static function transformExpr(expr:Expr) switch (expr) {
		case macro @for($init , $cond , $incr) $block:
			transformExpr(block);
			expr.expr = makeLoop(init, cond, incr, block).expr;
		default:
			haxe.macro.ExprTools.iter(expr, transformExpr);
	}

	static function makeLoop(init:Expr, cond:Expr, incr:Expr, block:Expr) {
		var outer:Array<Expr> = [], inner:Array<Expr> = [];
		// adds expression(s) into given list (block):
		function unroll(o:Expr, to:Array<Expr>) {
			switch (o.expr) {
			case EBlock(m): for (v in m) to.push(v);
			default: to.push(o);
			}
		}
		// inner (inside the for-loop) block:
		inner.push(macro var _ = true);
		inner.push({
			expr: ExprDef.EWhile(macro _ = false, block, false),
			pos: block.pos
		});
		inner.push(macro if (_) break);
		unroll(incr, inner);
		// outer (outside the for-loop) block:
		unroll(init, outer);
		outer.push({
			expr: ExprDef.EWhile(cond, {
				expr: ExprDef.EBlock(inner),
				pos: block.pos
			}, true),
			pos: block.pos
		});
		//
		return {
			expr: ExprDef.EBlock(outer),
			pos: init.pos
		};
	}
}
