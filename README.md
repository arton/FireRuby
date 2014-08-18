FireRuby
========

Firefox js-ctypes application that hosts programming language ruby

# DOM reference

## DOM.window

 XUL window object.

### instance methods

**addEventListener(name, &block)**
register specified event listener
*name* : name of the event
*block*

### DOM.window specialized methods

**set_timeout(msec, &block)**
invoke block after msec.
*msec*
*block*

**set_interval(msec, &block)**
repeat block after msec
*msec*
*block*
*return* : timer id to stop this timer instance

**clear_interval(timer_id)**
clear previously called set_interval
*timer_id* : timer id returned by previously called set_interval

example)
```
count = 0
key = DOM.window.set_interval(3000) do
  count += 1
  if count > 3
    DOM.window.alert('done')
    DOM.window.clear_interval(key)
  else
    DOM.window.alert('hell')
  end
end
p key
```