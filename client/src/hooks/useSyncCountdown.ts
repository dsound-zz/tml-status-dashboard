import { useEffect, useState } from 'react'
import { useQueryClient } from '@tanstack/react-query'

const INTERVAL_MS = 2 * 60 * 1000

export function useSyncCountdown(): string {
  const queryClient = useQueryClient()
  const [remaining, setRemaining] = useState(INTERVAL_MS)

  useEffect(() => {
    const getRemaining = () => {
      const state = queryClient.getQueryState(['states'])
      if (!state?.dataUpdatedAt) return INTERVAL_MS
      const elapsed = Date.now() - state.dataUpdatedAt
      return Math.max(0, INTERVAL_MS - elapsed)
    }

    setRemaining(getRemaining())
    const ticker = setInterval(() => setRemaining(getRemaining()), 1000)
    return () => clearInterval(ticker)
  }, [queryClient])

  const secs = Math.ceil(remaining / 1000)
  const m = Math.floor(secs / 60)
  const s = secs % 60
  return `${m}:${s.toString().padStart(2, '0')}`
}
