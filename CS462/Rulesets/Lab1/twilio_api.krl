ruleset twilio_api {
  meta {
    configure using account_sid = ""
                    auth_token = ""
    provides send_sms, messages
  }
  
  global {
    base_url = <<https://api.twilio.com/2010-04-01/Accounts/#{account_sid}/>>
    authentication = {"username":account_sid,"password":auth_token}

    send_sms = defaction(to, from, body) {
      http:post(base_url + "Messages.json", auth=authentication, form = {
        "From" : from,
        "Body" : body,
        "To" : to
      }.klog("FORM: "))
      setting(response)

      return response.klog("RESPONSE: ")
    }
    
    messages = function(to, from, pages){
      tester = 1.klog("USED FOR TESTING: ")
      s = {}.put("To", to => to | null).put("From", from => from | null)
      response = http:get(base_url + "Messages.json", auth=authentication, qs = s)
      
      return response{"content"}.decode(){"messages"}
    }
    
  }
}