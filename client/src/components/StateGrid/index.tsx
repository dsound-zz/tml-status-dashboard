import { useState } from 'react'
import { Box, Chip, Grid, Stack, Typography } from '@mui/material'
import type { StateRecord, StatusValue } from '../../types'
import { sortByStatus, STATUS_COLOR, STATUS_LABEL } from '../../lib/statusHelpers'
import { StateCard } from '../StateCard'

type FilterValue = 'all' | StatusValue

interface Props {
  states: StateRecord[]
  onSelect: (state: StateRecord) => void
}

const FILTERS: { value: FilterValue; label: string }[] = [
  { value: 'all', label: 'All' },
  { value: 'down', label: 'Outage' },
  { value: 'planned_outage', label: 'Planned' },
  { value: 'up', label: 'Operational' },
]

export function StateGrid({ states, onSelect }: Props) {
  const [filter, setFilter] = useState<FilterValue>('all')

  const filtered = states
    .filter((s) => filter === 'all' || s.status === filter)
    .sort(sortByStatus)

  return (
    <Box>
      <Stack direction="row" spacing={1} useFlexGap sx={{ flexWrap: 'wrap', mb: 3 }}>
        {FILTERS.map(({ value, label }) => {
          const isActive = filter === value
          const count =
            value === 'all' ? states.length : states.filter((s) => s.status === value).length
          const statusColor = value === 'all' ? undefined : STATUS_COLOR[value as StatusValue]
          const _label = value !== 'all' ? STATUS_LABEL[value as StatusValue] : label

          return (
            <Chip
              key={value}
              label={`${_label} ${count}`}
              onClick={() => setFilter(value)}
              variant={isActive ? 'filled' : 'outlined'}
              sx={
                isActive && statusColor
                  ? { backgroundColor: `${statusColor}22`, borderColor: statusColor, color: statusColor }
                  : isActive
                    ? {}
                    : { borderColor: 'divider' }
              }
            />
          )
        })}
      </Stack>

      {filtered.length === 0 ? (
        <Typography color="text.secondary" sx={{ textAlign: 'center', py: 8 }}>
          No states match this filter.
        </Typography>
      ) : (
        <Grid container spacing={2}>
          {filtered.map((state) => (
            <Grid key={state.id} size={{ xs: 12, sm: 6, md: 4, lg: 3, xl: 2 }}>
              <StateCard state={state} onClick={onSelect} />
            </Grid>
          ))}
        </Grid>
      )}
    </Box>
  )
}
