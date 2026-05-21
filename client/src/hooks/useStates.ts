import { useQuery } from '@tanstack/react-query'
import type { StateRecord } from '../types'

async function fetchStates(): Promise<StateRecord[]> {
  const res = await fetch('/api/v1/states')
  if (!res.ok) throw new Error(`HTTP ${res.status}`)
  return res.json() as Promise<StateRecord[]>
}

export function useStates() {
  return useQuery<StateRecord[], Error>({
    queryKey: ['states'],
    queryFn: fetchStates,
    refetchInterval: 2 * 60 * 1000,
    staleTime: 90 * 1000,
  })
}
