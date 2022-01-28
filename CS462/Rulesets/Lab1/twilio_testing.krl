ruleset twilio_testing {
  meta {
      use module twilio_api alias twilio
          with 
            account_sid = meta:rulesetConfig{"account_sid"}
            auth_token =  meta:rulesetConfig{"auth_token"}
  }

  global {}

  rule test_send {
    select when test send_sms
    twilio:send_sms(event:attrs{"to"},
                    event:attrs{"from"},
                    event:attrs{"message"}
    )
  }

  rule test_get {
    select when test messages
    pre{
        messages = twilio:messages( event:attrs{"to"},
                                    event:attrs{"from"},
                                    event:attrs{"pageSize"}.klog("For some reason required")
        )
    }
    send_directive("messages", {"messages": messages})
  }
}