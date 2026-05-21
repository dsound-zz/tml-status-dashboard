class StateStatusBlueprint < Blueprinter::Base
  fields :status, :planned_outage_start, :planned_outage_end,
         :outage_reason, :response_time_ms, :uptime_30d, :last_checked_at
end
