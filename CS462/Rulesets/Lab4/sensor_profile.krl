ruleset sensor_profile {
  meta {
      provides
        get_profile
      shares
        get_profile
  }

  global {
      get_profile = function() {
          ent:profile.isnull() => {"threshold":99} | ent:profile
      }
  }

  rule update_profile {
      select when sensor profile_updated
      pre {
          ev = {
          "location" : event:attrs{"location"},
          "name" : event:attrs{"name"},
          "threshold" : event:attrs{"threshold"}.isnull() => 75 | event:attrs{"threshold"},
          "notify_number" : event:attrs{"notify_number"}.isnull() => "+11111111111" | event:attrs{"notify_number"}
          }.klog("New profile ")
      }
      noop()
      always {
          ent:profile := ev
      }
  }

  rule erase_profile {
      select when sensor clear_profile
      noop()
      always {
          clear ent:profile
      }
  }

}