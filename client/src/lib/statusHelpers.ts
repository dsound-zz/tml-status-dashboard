import type { StatusValue } from '../types'

export const STATUS_COLOR: Record<StatusValue, string> = {
  up: '#4caf50',
  planned_outage: '#ff9800',
  down: '#f44336',
}

export const STATUS_LABEL: Record<StatusValue, string> = {
  up: 'Operational',
  planned_outage: 'Planned Outage',
  down: 'Outage',
}

export const STATUS_SORT_ORDER: Record<StatusValue, number> = {
  down: 0,
  planned_outage: 1,
  up: 2,
}

export function sortByStatus(a: { status: StatusValue }, b: { status: StatusValue }): number {
  return STATUS_SORT_ORDER[a.status] - STATUS_SORT_ORDER[b.status]
}

export function formatResponseTime(ms: number): string {
  if (ms >= 1000) return `${(ms / 1000).toFixed(1)}s`
  return `${ms}ms`
}

export function formatLastChecked(isoString: string): string {
  const diffMs = Date.now() - new Date(isoString).getTime()
  const diffSec = Math.floor(diffMs / 1000)
  if (diffSec < 60) return `${diffSec}s ago`
  const diffMin = Math.floor(diffSec / 60)
  if (diffMin < 60) return `${diffMin}m ago`
  return `${Math.floor(diffMin / 60)}h ago`
}

export function formatOutageWindow(start: string, end: string): string {
  const fmt = (iso: string) =>
    new Date(iso).toLocaleString('en-US', {
      month: 'short',
      day: 'numeric',
      hour: '2-digit',
      minute: '2-digit',
      timeZoneName: 'short',
    })
  return `${fmt(start)} – ${fmt(end)}`
}
