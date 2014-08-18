# coding: utf-8

require 'fiddle'
require 'json'

def init_fireruby(caller, setter, registerevent, removeevent)
  caller_ptr = Fiddle::Pointer.new(caller)
  $jsfun = Fiddle::Function.new(caller_ptr, [Fiddle::TYPE_VOIDP, Fiddle::TYPE_VOIDP], Fiddle::TYPE_VOIDP)
  setter_ptr = Fiddle::Pointer.new(setter)
  $jssetter = Fiddle::Function.new(setter_ptr, [Fiddle::TYPE_VOIDP, Fiddle::TYPE_VOIDP], Fiddle::TYPE_VOID)
  reg_ptr = Fiddle::Pointer.new(registerevent)
  $jsregevent = Fiddle::Function.new(reg_ptr, [Fiddle::TYPE_VOIDP, Fiddle::TYPE_VOIDP], Fiddle::TYPE_VOID)
  rmv_ptr = Fiddle::Pointer.new(removeevent)
  $jsrmvevent = Fiddle::Function.new(rmv_ptr, [Fiddle::TYPE_VOIDP, Fiddle::TYPE_VOIDP], Fiddle::TYPE_VOID)
end

def eval_expression(str)
  begin
    eval(str).to_s
  rescue
    "error: #{$!.to_s}"
  end
end

$dom_events = {}

def notify_event(e)
  blk = $dom_events[e]
  if blk
    if blk.arity == 1
      blk.call(DOM.new("frevent:#{e}"))
    else
      blk.call()
    end
  end
end

class DOM
  def initialize(id)
    @id = id
  end
  def addEventListener(name, &block) 
    key = "#{@id}#{name}"
    $dom_events[key] = block
    $jsregevent.call(@id, JSON({'name' => name, 'key' => key }))
  end
  def removeEventListener(name, &block)
    # remove any block at this time
    key = "#{@id}#{name}"
    $dom_events.delete(key)
    $jsrmvevent.call(@id, JSON({'name' => name, 'key' => key }))
  end
  def method_missing(name, *args)
    begin
      param = {}
      param['args'] = args
      if name.to_s[-1, 1] == '='
        param['name'] = name.to_s[0...-1]
        v = $jssetter.call(@id, JSON(param))
      else
        param['name'] = name.to_s
        v = $jsfun.call(@id, JSON(param))
      end
      return v.to_s
    rescue
      return 'error:' + $!.to_s
    end
  end
end

$timer_events = {}
def timer_callback(key, cb)
  blk = $timer_events[key]
  if blk
    blk.call()
    if cb == 'setTimeout'
      $timer_events.delete(key)
    end
  end
end

class Window < DOM
  def initialize(id)
    super(id)
  end
  def set_timeout(msec, &blk)
    timer_func('setTimeout', msec, blk)
  end
  def set_interval(msec, &blk)
    timer_func('setInterval', msec, blk)
  end
  def clear_interval(id)
    if id =~ /\A([^:]+):(.*)\Z/
      $timer_events.delete($2)
      $jsfun.call('window', JSON({'name' => 'clearInterval', 'args' => [ $1 ] }))
    end
    ''
  end
  private
  def timer_func(funname, msec, blk)
    key = Random.rand.to_s
    $timer_events[key] = blk
    fun =<<EOFUNC
var args = VALUE_ARRAY(2);
args[0].value = rb_str_new_cstr('#{key}');
args[1].value = rb_str_new_cstr('#{funname}');
rb_funcall(obj_class, rb_intern('timer_callback'), 2, args);
EOFUNC
    $jsfun.call('window', JSON({'name' => funname,
                                'args' => [ fun, msec ]})).to_s + ':' + key
  end
end

class DOM
  @@document = DOM.new('document')
  @@window = Window.new('window')
  def self.document()
    @@document
  end
  def self.window()
    @@window
  end
end

