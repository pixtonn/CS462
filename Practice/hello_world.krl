ruleset hello_world {
  meta {
    name "Hello World"
    description <<A first ruleset for the Quickstart>>
    author "Phil Windley"
    shares hello, users, __testing, tester
  }
   
  global {
    hello = function(obj) {
      msg = "Hello " + obj;
      msg
    }
    tester = function() {
      ent: this
    }
    users = function() {
      ent:name
    }
    clear_name = { "_0": { "name": { "first": "GlaDOS", "last": "" } } }
    name = function(id){
      all_users = users();
      nameObj = all_users{[id,"name"]}
                    || { "first": "HAL", "last": "9000" };
      first = nameObj{"first"};
      last = nameObj{"last"};
      first + " " + last
    }
  }
   
  rule hello_world {
    select when echo hello
    pre{
      id = event:attrs{"id"} || "_0"
      name = name(id)
      visits = ent:name{[id,"visits"]}.defaultsTo(0)
    }
    send_directive("say", {"something":"Hello " + name})
    fired {
      ent:name{[id,"visits"]} := visits + 1
    }
  }

  rule clear_names {
    select when echo clear
    always {
      ent:name := clear_name
    }
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
  /*
  rule hello_monkey_ternary {
    select when echo monkey
    pre{
      name = (event:attr("name")==null) => "Monkey" | event:attr("name")
    }
    send_directive("say", {"something": <<Hello #{name}>>})
  }
  */

  rule store_name {
    select when echo name
    pre{
      passed_id = event:attrs{"id"}.klog("our passed in id: ")
      passed_first_name = event:attrs{"first_name"}.klog("our passed in first_name: ")
      passed_last_name = event:attrs{"last_name"}.klog("our passed in last_name: ")
    }
    send_directive("store_name", {
      "id" : passed_id,
      "first_name" : passed_first_name,
      "last_name" : passed_last_name
    })
    always{
      ent:name := ent:name.defaultsTo(clear_name, "initialization was needed");
      ent:name := ent:name.put([passed_id,"name","first"], passed_first_name)
                          .put([passed_id,"name","last"], passed_last_name)
    }
  }


   
}