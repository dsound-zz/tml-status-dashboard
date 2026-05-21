class StateBlueprint < Blueprinter::Base
  identifier :id

  fields :name, :abbreviation, :department_name,
         :contact_name, :contact_email, :contact_phone,
         :api_type, :api_version, :data_format, :auth_method, :protocol_notes

  field(:status)           { |state| state.state_status&.status }
  field(:planned_outage_start) { |state| state.state_status&.planned_outage_start&.iso8601 }
  field(:planned_outage_end)   { |state| state.state_status&.planned_outage_end&.iso8601 }
  field(:outage_reason)    { |state| state.state_status&.outage_reason }
  field(:response_time_ms) { |state| state.state_status&.response_time_ms }
  field(:uptime_30d)       { |state| state.state_status&.uptime_30d&.to_f }
  field(:last_checked_at)  { |state| state.state_status&.last_checked_at&.iso8601 }
end
