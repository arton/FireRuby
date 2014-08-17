# coding: utf-8

require 'fiddle'
require 'json'

def init_fireruby(caller, setter)
  caller_ptr = Fiddle::Pointer.new(caller)
  $jsfun = Fiddle::Function.new(caller_ptr, [Fiddle::TYPE_VOIDP, Fiddle::TYPE_VOIDP], Fiddle::TYPE_VOIDP)
  setter_ptr = Fiddle::Pointer.new(setter)
  $jssetter = Fiddle::Function.new(setter_ptr, [Fiddle::TYPE_VOIDP, Fiddle::TYPE_VOIDP], Fiddle::TYPE_VOID)
end

def eval_expression(str)
  begin
    eval(str).to_s
  rescue
    "error: #{$!.to_s}"
  end
end

class DOM
  def initialize(id)
    @id = id
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
