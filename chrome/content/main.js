Components.utils.import("resource://gre/modules/ctypes.jsm");

var lib;
var script;
var mainrb;
(function() {
    var cmdLine = window.arguments[0];
    cmdLine = cmdLine.QueryInterface(Components.interfaces.nsICommandLine);
    var rubylib = cmdLine.handleFlagWithParam('rubylib', false);
    lib = ctypes.open(rubylib);
    mainrb = cmdLine.handleFlagWithParam('main', null);
    script = cmdLine.handleFlagWithParam('script', null);
})();
var ID = ctypes.uintptr_t;
var VALUE = ctypes.PointerType(ctypes.uintptr_t);
var VALUE_ARRAY = ctypes.ArrayType(VALUE);
var rb_intern = lib.declare("rb_intern", ctypes.default_abi, ID, ctypes.char.ptr);
var rb_eval_string = lib.declare("rb_eval_string", ctypes.default_abi, VALUE, ctypes.char.ptr);
var rb_const_get = lib.declare("rb_const_get", ctypes.default_abi, VALUE, VALUE, ID);
var rb_string_value_cstr = lib.declare("rb_string_value_cstr", ctypes.default_abi, ctypes.char.ptr, VALUE.ptr);
var rb_str_new_cstr = lib.declare("rb_str_new_cstr", ctypes.default_abi, VALUE, ctypes.char.ptr);
var rb_require = lib.declare("rb_require", ctypes.default_abi, VALUE, ctypes.char.ptr);
var rb_funcall = lib.declare("rb_funcallv", ctypes.default_abi, VALUE, VALUE, ID, ctypes.int, VALUE_ARRAY);
var rb_ull2inum = lib.declare("rb_ull2inum", ctypes.default_abi, VALUE, ctypes.uint64_t);
lib.declare("ruby_init", ctypes.default_abi, ctypes.void_t)();
(function() {
    var chararray = ctypes.ArrayType(ctypes.char.ptr);
    var ruby_options = lib.declare("ruby_options", ctypes.default_abi, ctypes.void_t, ctypes.int, chararray);
    var args = chararray(3);
    args[0].value = ctypes.char.array()('dummy');
    args[1].value = ctypes.char.array()('-e');
    args[2].value = ctypes.char.array()(';');
    ruby_options(3, args);
})();
rb_require(mainrb);
var obj_class = rb_eval_string("Object");
var nil_object = rb_eval_string("nil");
var no_args = VALUE_ARRAY(0);

window.addEventListener('load', function() {
    var vs = rb_eval_string('"#{RUBY_VERSION}p#{RUBY_PATCHLEVEL} [#{RUBY_PLATFORM}]"');
    document.getElementById('ruby_version').innerHTML = rb_string_value_cstr(vs.address()).readString();
    if (script) {
        rb_require(script);
    }
});

function callRuby() {
    var arg = VALUE_ARRAY(1);
    arg[0] = rb_str_new_cstr(document.getElementById('scrtext').value);
    var vs = rb_funcall(obj_class, rb_intern('eval_expression'), 1, arg)
    document.getElementById('dispa').innerHTML = rb_string_value_cstr(vs.address()).readString();
}

var firedEvents = {}

function getElement(id) {
    var elem_id = id.readString();
    if (elem_id === 'window') {
        return window;
    } else if (elem_id === 'document') {
        return document;
    } else if (elem_id.indexOf('frevent:') == 0) {
        return firedEvents['ev' + elem_id.substring(8)];
    }
    return document.getElementById(elem_id);
}

function propSetter(id, args) {
    var elem = getElement(id);
    var argv = JSON.parse(args.readString());
    elem[argv.name] = argv.args[0];
}

function methodCaller(id, args) {
    var elem = getElement(id);
    var argv = JSON.parse(args.readString());
    var fun = elem[argv.name];
    var ret;
    if (typeof fun === 'function') {
        ret = fun.apply(elem, argv.args);
    } else if (fun) {
        ret = fun;
    }
    if (typeof ret === 'undefined') {
        ret = 'undefined';
    } else if (ret == null) {
        ret = 'nil';
    } else {
        ret = ret.toString();
    }
    return ctypes.char.array()(ret);
}

function registerEvent(id, args) {
    var elem = getElement(id);
    var argv = JSON.parse(args.readString())
    elem['cb' + argv.key] = function(e) {
        firedEvents['ev' + argv.key] = e;
        var args = VALUE_ARRAY(1);
        args[0].value = rb_str_new_cstr(argv.key);
        rb_funcall(obj_class, rb_intern('notify_event'), 1, args);
        firedEvents['ev' + argv.key] = null;
    };
    elem.addEventListener(argv.name, elem['cb' + argv.key]);
}

function removeEvent(id, args) {
    var elem = getElement(id);
    var argv = JSON.parse(args.readString())
    elem.removeEventListener(argv.name, elem['cb' + argv.key]);
}

var funcPtrType = ctypes.FunctionType(ctypes.default_abi, ctypes.char.ptr, [ctypes.char.ptr, ctypes.char.ptr]).ptr;
var methodcaller = funcPtrType(methodCaller);
var procPtrType = ctypes.FunctionType(ctypes.default_abi, ctypes.void_t, [ctypes.char.ptr, ctypes.char.ptr]).ptr;
var propsetter = procPtrType(propSetter);
var regevent = procPtrType(registerEvent);
var removeevent = procPtrType(removeEvent);
(function() {
    var args = VALUE_ARRAY(4);
    args[0].value = rb_ull2inum(ctypes.cast(methodcaller, ctypes.uint64_t));
    args[1].value = rb_ull2inum(ctypes.cast(propsetter, ctypes.uint64_t));
    args[2].value = rb_ull2inum(ctypes.cast(regevent, ctypes.uint64_t));
    args[3].value = rb_ull2inum(ctypes.cast(removeevent, ctypes.uint64_t));
    rb_funcall(obj_class, rb_intern('init_fireruby'), args.length, args);
})();

window.addEventListener('close', function () {
    lib.close();
});