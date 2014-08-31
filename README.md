FireRuby
========

Firefox js-ctypes application that hosts programming language ruby

# DOM class reference

## DOM.window

 XUL window object.

## DOM.document

 XUL document object.

### constructor

**initialize(id)**

create specified element proxy

* *id* element id

### instance methods

**addEventListener(name, &block)**

register specified event listener.

Unlike ordinal DOM specification, only one listener can be added to the same element.

* *name* : name of the event
* *block*

sample)
```ruby
DOM.new('ruby_version').addEventListener('click') do |event|
  puts("x:#{event.clientX}, y:#{event.clientY}")
end
```

> alias: add_event_listener

**removeEventListener(name)**

unregister specified event listener

* *name* : name of the event

> alias: remove_event_listener

### DOM.window specialized methods

**set_timeout(msec, &block)**

invoke block after msec.

* *msec*
* *block*

**set_interval(msec, &block)**

repeat block after msec

* *msec*
* *block*
* *return* : timer id to stop this timer instance

**clear_interval(timer_id)**

clear previously called set_interval

* *timer_id* : timer id returned by previously called set_interval

example)
```ruby
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