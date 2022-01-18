ruleset hello_world {
  meta {
    name "Hello World"
    description <<
A first ruleset for the Quickstart
>>
    author "Phil Windley"
    shares hello, __testing
  }
   
  global {
    hello = function(obj) {
      msg = "Hello " + obj;
      msg
    }
  }
   
  rule hello_world {
    select when echo hello
    send_directive("say", {"something": "Hello World"})
  }

  /*
  rule hello_monkey {
    select when echo monkey
    pre{
      name = (event:attr("name") || "Monkey").klog("name given: ")
    }
    send_directive("say", {"something": <<Hello #{name}>>})
  }
  */

  rule hello_monkey_ternary {
    select when echo monkey
    pre{
      name = (event:attr("name")==null) => "Monkey" | event:attr("name")
    }
    send_directive("say", {"something": <<Hello #{name}>>})
  }


   
}