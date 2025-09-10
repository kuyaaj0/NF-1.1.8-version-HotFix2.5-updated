package backend.state.loadingState;

import luahscript.exprs.LuaExpr;
import luahscript.LuaTools;
import luahscript.exprs.LuaConst;

class LuaExtraTools {
	public static function getValue(e:LuaExpr):Dynamic {
		if (e == null) return null;
		return switch(e.expr) {
			case EParent(e):
				getValue(e);
			case EConst(c):
				switch(c) {
					case CString(ah, _): ah;
					case CInt(i): i;
					case CFloat(f): f;
					case CTripleDot: null;
				};
			case _:
				null;
		}
	}

	public static function searchCallback(e:LuaExpr, ?func:LuaExpr->Array<LuaExpr>->Void) {
		if (e == null) return;
		switch(e.expr) {
			case EConst(_), EIdent(_):
			case EBreak, EContinue, EIgnore:
			case EParent(e):
				searchCallback(e, func);
			case EField(e, _):
				searchCallback(e, func);
			case ELocal(e):
				searchCallback(e, func);
			case EBinop(_, e1, e2):
				searchCallback(e1, func);
				searchCallback(e2, func);
			case EPrefix(_, e):
				searchCallback(e, func);
			case ECall(e, params):
				if(func != null) {
					LuaTools.recursion(e, function(e:LuaExpr) {
						func(e, params);
					});
				}
				searchCallback(e, func);
				for(p in params) searchCallback(p, func);
			case ETd(ae):
				for(e in ae) searchCallback(e, func);
			case EAnd(ae):
				for(e in ae) searchCallback(e, func);
			case EIf(cond, body, eis, eel):
				searchCallback(cond, func);
				searchCallback(body, func);
				if(eis != null) for(e in eis) {
					searchCallback(e.cond, func);
					searchCallback(e.body, func);
				}
				if(eel != null) searchCallback(eel, func);
			case ERepeat(body, cond):
				searchCallback(body, func);
				searchCallback(cond, func);
			case EWhile(cond, e):
				searchCallback(cond, func);
				searchCallback(e, func);
			case EForNum(_, body, start, end, step):
				searchCallback(body, func);
				searchCallback(start, func);
				searchCallback(end, func);
				if(step != null) searchCallback(step, func);
			case EForGen(body, iterator, _):
				searchCallback(iterator, func);
				searchCallback(body, func);
			case EFunction(_, e):
				searchCallback(e, func);
			case EReturn(e):
				searchCallback(e, func);
			case EArray(e, index):
				searchCallback(e, func);
				searchCallback(index, func);
			case ETable(fl):
				for(fi in fl) {
					if(fi.key != null) searchCallback(fi.key, func);
					searchCallback(fi.v, func);
				}
		}
	}
}