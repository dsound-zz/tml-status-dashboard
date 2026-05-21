export type StatusValue = 'up' | 'planned_outage' | 'down'

export interface StateRecord {
  id: number
  name: string
  abbreviation: string
  department_name: string
  contact_name: string
  contact_email: string
  contact_phone: string
  api_type: string
  api_version: string
  data_format: string
  auth_method: string
  protocol_notes: string
  status: StatusValue
  planned_outage_start: string | null
  planned_outage_end: string | null
  outage_reason: string | null
  response_time_ms: number
  uptime_30d: number
  last_checked_at: string
}
