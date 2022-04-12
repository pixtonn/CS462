ruleset temperature_store {
  meta {
    provides
      temperatures,
      threshold_violations,
      inrange_temperatures
    shares
      temperatures,
      threshold_violations,
      inrange_temperatures
  }

  global {
    temperature_threshold = 99
    temperatures = function() {
      ent:temperatures
    }
    threshold_violations = function() {
      ent:violations
    }
    inrange_temperatures = function() {
      ent:temperatures.filter(function(temp) {
        temp{"temp"}.klog("TEMPERATURE: ") < temperature_threshold
      })
    }
  }

  rule collect_temperatures {
    select when wovyn new_temperature_reading
    pre {
      entity = {
        "temp": event:attrs{"temperature"},
        "time": event:attrs{"timestamp"}
      }
    }
    noop()
    always {
      ent:temperatures := ent:temperatures.defaultsTo([]).append(entity)
    }
  }

  rule collect_threshold_violations {
    select when wovyn threshold_violation
    pre {
      entity ={
        "temp": event:attrs{"temperature"},
        "time": event:attrs{"timestamp"}
      }.klog("Violation collected ")
    }
    noop()
    always {
      ent:violations := ent:violations.defaultsTo([]).append(entity)
    }
  }

  rule clear_temperatures {
    select when sensor reading_reset
    noop()
    always {
      clear ent:violations
      clear ent:temperatures
    }
  }
  
}