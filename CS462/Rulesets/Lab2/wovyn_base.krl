ruleset wovyn_base {
  meta {
    use module twilio_api alias twilio
          with 
            account_sid = meta:rulesetConfig{"account_sid"}
            auth_token =  meta:rulesetConfig{"auth_token"}
  }

  global {
    temperature_threshold = 99
    _from = "+17754061835"
    _to = "+14703939210"
  }

  rule process_heartbeat {
    select when wovyn heartbeat
    pre {
      generic = event:attrs{"genericThing"}
      temp_list = generic.get(["data", "temperature"])
    }
    if not generic.isnull() then
    send_directive("say", {
      "message": "Wovyn running",
      "heartbeat_temps": temp_list
    })
    fired {
      raise wovyn event "new_temperature_reading"
        attributes {
          "temperature": temp_list.map(function (a) {
            a.get("temperatureF")
          }).reduce(function (a, b) {
            a + b
          }) / temp_list.length(),
          "timestamp": time:now()
        }
    }
  }

  rule find_high_temps {
    select when wovyn new_temperature_reading
    pre {
      temp = event:attrs{"temperature"}
      time = event:attrs{"timestamp"}
      message = (temp > temperature_threshold) => "Threshold violated!" | "Threshold NOT violated!"
    }
    send_directive("say", {
      "message": message,
      "max temp": temp,
      "threshold": temperature_threshold
    })
    always {
      raise wovyn event "threshold_violation"
        attributes {
          "temperature": temp,
          "timestamp": time
        } if temp > temperature_threshold
    }
  }

  rule threshold_notification {
    select when wovyn threshold_violation
    pre {
      temp = event:attrs{"temperature"}
      time = event:attrs{"timestamp"}
      message = "Temperature threshold violated. Temperature: " + temp + " at " + time
    }
    twilio:send_sms(_to,
                    _from,
                    message
    )
  }

}