package selua;
#if linc_luajit
import llua.Lua;
import llua.LuaL;
import llua.State;
import llua.Convert;
import cpp.Pointer;

using StringTools;

class SELua{
	public var state:State;
	public var code:String = "";
	public var cache:Map<String,Dynamic> = [];
	public var variables:SELuaVaris;
	public var helpers:SELuaHelperMethods;
	public static var currentInstance:SELua;

	public function new(?str:String = "",?doExec:Bool = true){
		code = str;
		state = LuaL.newstate();
		LuaL.openlibs(state);
		Lua.init_callbacks(state);
		variables = new SELuaVaris(this);
		helpers = new SELuaHelperMethods(this);
		if(!doExec) return;
		currentInstance = this;
		exec();
	}
	public function exec(?code:String = ""){
		if(code == "")code = this.code;
		// Lua.getglobal(state, 'dostring');
		// Lua.pushstring(state, code);
		// trace(returnStack());
		// var exitCode:Dynamic = LuaL.dostring(state, code);
		// var status:Int = LuaL.loadstring(state, code);
		// if(status != 0){
		// 	var e = fromLuaError(status);
		// 	trace(e);
		// 	throw e;
		// 	return;
		// }
		var status:Int = LuaL.dostring(state, code);
		if(status != 0){
			trace(status);
			var e = fromLuaError(status);
			trace(e);
			throw e;
			return;
		}
		trace('Parsed lua script without issues!');
	}


	/* I didn't steal these from psych, naaaaahhh*/


	function typeToString(type:Int):String {
		switch(type) {
			case Lua.LUA_TBOOLEAN: return "boolean";
			case Lua.LUA_TNUMBER: return "number";
			case Lua.LUA_TSTRING: return "string";
			case Lua.LUA_TTABLE: return "table";
			case Lua.LUA_TFUNCTION: return "function";
		}
		if (type <= Lua.LUA_TNIL) return "nil";
		return "unknown";
	}

	public function set(variable:String, data:Dynamic,?map:Bool = false) {
		return variables.set(variable,data,map);
	}

	public function call(func:String,args:Array<Dynamic>) {
		return variables.call(func,args);
	}
	public function get(variable:String):Dynamic {
		return variables.get(variable);
	}
	public function getBool(variable:String):Bool {
		return variables.getBool(variable);
	}
	public function returnStack(limit:Int = 9){
		var _arr:Array<Dynamic> = [];
		var param:Dynamic = null;
		var i = 0;
		param = Lua.tostring(state,i--);
		while(param != null && i > -limit){
			_arr.push(Lua.tostring(state, i));
			param = Lua.tostring(state,i--);
		}
		i = 0;
		param = Lua.tostring(state,i++);
		while(param != null  && i < limit){
			_arr.push(Lua.tostring(state, i));
			param = Lua.tostring(state,i++);
		}
		return _arr;
	}

	public function fromLuaError(Stat:Dynamic){
		var v:String = 'Status code:$Stat';
		try{

			if(Stat == "" || Stat == null || Stat is Int){
				var _v = "Stack:\n";
				var _arr = returnStack(); 
				_v+='${_arr}\n';
				Lua.pop(state, 1);
					switch(Stat) {
						case Lua.LUA_YIELD: v+= '\nYIELD';
						case Lua.LUA_ERRSYNTAX: v += "\nSyntax Error";
						case Lua.LUA_ERRRUN: v += "\nRuntime Error";
						case Lua.LUA_ERRMEM: v += "\nMemory Allocation Error";
						case Lua.LUA_ERRERR: v += "\nCritical Error";
					}
					
				if (_v != null && _v != "") {v += "\n" + _v.trim();}
			}else{
				v += '\n' + Std.string(Stat);
			}
			stop();
		}catch(e){
			v += 'Unable to grab error! ${e.message}';
		}
		return v;
	}

	public function stop() {
		if(state == null) return;

		Lua.close(state);
		state = null;
	}
}

class SELuaVaris{
	var parent:SELua;
	public var strToPointer:haxe.ds.WeakMap<String,Dynamic> = new haxe.ds.WeakMap<String,Dynamic>();
	public var pointerToStr:haxe.ds.WeakMap<Dynamic,String> = new haxe.ds.WeakMap<Dynamic,String>();
	inline public static var pointerID:String = "Pointer to ";
	public function new(selua:SELua){
		parent = selua;
	}
	public static function objectToMap(obj:Dynamic):Map<String,Dynamic> {
		var map = new Map<String,Dynamic>();
		for(field in Reflect.fields(obj)){
			map.set(field,Reflect.getProperty(obj,field));
		}
		try{
			for(field in Type.getInstanceFields(Type.getClass(obj))){
				map.set(field,Reflect.getProperty(obj,field));
			}
		}catch(e){}
		return map;
	}
	public function objectToPtr(ptr:Dynamic,?name:String = "",?retPointer:Bool = false ):Dynamic {
		if(pointerToStr.get(ptr) == null){
			var id = name + Std.string(flixel.FlxG.random.int(0,1000000000)); // This is shit but whatever
			if(strToPointer.get(id) != null){
				while(strToPointer.get(id) != null){
					id = name + Std.string(flixel.FlxG.random.int(0,1000000000));
				}
			}
			strToPointer.set(id,ptr);
			pointerToStr.set(ptr,id);
		}
		return (retPointer ? pointerID : "") + pointerToStr.get(ptr);
	}
	public function ptrToObject(ID:String):Dynamic {
		if(ID == null || ID == "" || ID.substring(0,pointerID.length) != pointerID){
			throw('INVALID ID: ${ID}');
			return null;
		}
		return strToPointer.get(ID.substring(pointerID.length));
	}
	inline function setGlobal(vari){
		if(vari != "FUNCTIONVAR") Lua.setglobal(parent.state,vari);
	}
	public function set(variable:String, data:Dynamic,?map:Bool = false):Bool {
		if(parent.state == null) return false;
		var _dataTypeOf = Type.typeof(data);
		if(!map && variable != "FUNCTIONVAR" && Reflect.isFunction(data)){
			Lua_helper.add_callback(parent.state,variable,data);
			return true;
		}
		if(Convert.toLua(parent.state, data) && variable != "FUNCTIONVAR"){
			setGlobal(variable);
			return true;
		}
		if(map){
			if(Convert.toLua(parent.state, objectToMap(data)) && variable != "FUNCTIONVAR"){
				setGlobal(variable);
				return true;
			}

			return false;
		}
		var ptr = objectToPtr(data,true);
		if(ptr != null && Convert.toLua(parent.state, ptr) && variable != "FUNCTIONVAR"){
			setGlobal(variable);
			return true;
		}
		return false;

	}

	function typeToString(type:Int):String {
		switch(type) {
			case Lua.LUA_TBOOLEAN: return "boolean";
			case Lua.LUA_TNUMBER: return "number";
			case Lua.LUA_TSTRING: return "string";
			case Lua.LUA_TTABLE: return "table";
			case Lua.LUA_TFUNCTION: return "function";
		}
		if (type <= Lua.LUA_TNIL) return "nil";
		return "unknown";
	}

	public function call(func:String, args:Array<Dynamic>) {
		if(parent.state == null) return;

		Lua.getglobal(parent.state, func);
		var type:Int = Lua.type(parent.state, -1);

		if (type != Lua.LUA_TFUNCTION) {
			if (type <= Lua.LUA_TNIL) return;
			Lua.pop(parent.state, 1);
			throw("" + func + ": attempt to call a " + typeToString(type) + " value");
			return;
		}
		var count = 0;
		for (arg in args)
			if(Convert.toLua(parent.state, arg)) count++; else{
				try{
					var ptr = objectToPtr(arg,true);
					Convert.toLua(parent.state, ptr);
					count++;
				}catch(e){}
			}
		SELua.currentInstance = this.parent;
		var status:Int = Lua.pcall(parent.state, count, 0, 0);

		if (status != Lua.LUA_OK) throw parent.fromLuaError(status);
		

	}
	public function get(variable:String):Dynamic {
		if(parent.state == null) return null;
		var result:String = null;
		Lua.getglobal(parent.state, variable);
		var returned = Convert.fromLua(parent.state, -1);
		if(returned is String){
			var retStr:String = cast (returned,String);
			if(retStr.substring(0,pointerID.length) == pointerID){
				var ptr = strToPointer.get(retStr.substring(pointerID.length));
				if(ptr == null) return returned;
				returned = ptr.ref;
			}
		}
		if(returned != null){
			Lua.pop(parent.state, 1);
		}

		return returned;
	}
	public function getBool(variable:String):Bool {
		if(parent.state == null) return false;
		var result:String = null;
		Lua.getglobal(parent.state, variable);
		result = Std.string(Convert.fromLua(parent.state, -1));
		if(result != null){
			Lua.pop(parent.state, 1);
		}

		return (result == 'true');
	}
}

class SELuaHelperMethods{
	var parent:SELua;
	public function new(par:SELua){
		parent = par;
		parent.set('getField',getField);
		parent.set('getFields',getFields);
		parent.set('getFieldsTbl',getFieldsTbl);
		parent.set('setField',setField);
		parent.set('toLuaTbl',toLuaTbl);
		parent.set('getClass',getClass);
		parent.set('getType',getType);
		parent.set('printObject', printObject);
		parent.set('trace',function(e) trace(e));
	}
	public function getField(ID:String,vari:String):Dynamic{
		var obj = parent.variables.ptrToObject(ID);
		if(obj == null) return null;
		return Reflect.getProperty(obj,vari);
	}
	public function runMethod(ID:String,vari:String,args:Array<Dynamic>):Dynamic{
		var obj = parent.variables.ptrToObject(ID);
		if(obj == null) return null;
		if(args == null) args = [];
		var func = Reflect.field(obj,vari);
		if(func == null){
			throw('$vari is not a valid method from $ID');
			return null;
		}
		return Reflect.callMethod(obj,func,args);
	}
	public function printObject(ID:String){
		var obj = parent.variables.ptrToObject(ID);
		trace(obj);
	}
	public function getFields(ID:String,vari:String,list:Array<Dynamic>):Array<Dynamic>{
		if(list == null){
			return [];
		}
		var obj = parent.variables.ptrToObject(ID);
		if(obj == null) return null;
		for(index => name in list){
			list[index] = Reflect.getProperty(obj,cast name);
		}
		trace(list);
		return list;
	}
	public function setField(ID:String,vari:String,value:Dynamic):Void{
		var obj = parent.variables.ptrToObject(ID);
		if(obj == null) return;
		Reflect.setProperty(obj,vari,value);
	}
	public function toLuaTbl(ID:String):Map<String,Dynamic>{
		var obj = parent.variables.ptrToObject(ID);
		if(obj == null) return null;
		return SELuaVaris.objectToMap(obj);
	}
	public function getClass(Name:String):Dynamic{
		var ass = Type.resolveClass(Name);
		if(ass == null) return null;
		return parent.variables.objectToPtr(ass,true);
	}
	public function getType(Name:String):Dynamic{
		var ass = Type.resolveClass(Name);
		if(ass == null) return null;
		return parent.variables.objectToPtr(ass,true);
	}
	public function getFieldsTbl(ID:String,vari:String,list:Array<String>):Map<String,Dynamic>{
		if(list == null){
			return [];
		}
		var obj = parent.variables.ptrToObject(ID);
		if(obj == null) return null;
		var map = new Map<String,Dynamic>();
		for(index => name in list){
			map[name] = Reflect.getProperty(obj,name);
		}
		return map;
	}
}
#else

class SELua{}
#end