import { useState } from 'react'
import {
  Alert,
  Box,
  Button,
  Chip,
  CircularProgress,
  Divider,
  Stack,
  Tooltip,
  Typography,
} from '@mui/material'
import SyncIcon from '@mui/icons-material/Sync'
import FiberManualRecordIcon from '@mui/icons-material/FiberManualRecord'
import type { StateRecord } from '../../types'
import { useStates } from '../../hooks/useStates'
import { useSyncCountdown } from '../../hooks/useSyncCountdown'
import { STATUS_COLOR } from '../../lib/statusHelpers'
import { StateGrid } from '../StateGrid'
import { OutageModal } from '../OutageModal'

export function Dashboard() {
  const { data: states, isLoading, isError, refetch, isFetching } = useStates()
  const countdown = useSyncCountdown()
  const [selected, setSelected] = useState<StateRecord | null>(null)

  const upCount = states?.filter((s) => s.status === 'up').length ?? 0
  const plannedCount = states?.filter((s) => s.status === 'planned_outage').length ?? 0
  const downCount = states?.filter((s) => s.status === 'down').length ?? 0

  async function triggerSimulate() {
    await fetch('/api/v1/simulate', { method: 'POST' })
    setTimeout(() => { void refetch() }, 600)
  }

  return (
    <Box sx={{ minHeight: '100vh', backgroundColor: 'background.default', p: { xs: 2, md: 4 } }}>
      {/* Header */}
      <Box sx={{ mb: 4 }}>
        <Stack
          direction="row"
          sx={{ justifyContent: 'space-between', alignItems: 'flex-start', flexWrap: 'wrap', gap: 2 }}
        >
          <Box>
            <Stack direction="row" spacing={1.5} sx={{ alignItems: 'center', mb: 0.5 }}>
              <FiberManualRecordIcon
                sx={{
                  color:
                    downCount > 0
                      ? STATUS_COLOR.down
                      : plannedCount > 0
                        ? STATUS_COLOR.planned_outage
                        : STATUS_COLOR.up,
                  fontSize: 14,
                  animation: 'live-pulse 1.5s ease-in-out infinite',
                  '@keyframes live-pulse': {
                    '0%, 100%': { opacity: 1 },
                    '50%': { opacity: 0.3 },
                  },
                }}
              />
              <Typography variant="overline" color="text.secondary" sx={{ letterSpacing: 2 }}>
                Live
              </Typography>
            </Stack>
            <Typography variant="h4" sx={{ fontWeight: 800, letterSpacing: -0.5 }}>
              State MVR Status Dashboard
            </Typography>
            <Typography variant="body2" color="text.secondary" sx={{ mt: 0.5 }}>
              Driving record data feed connectivity across all 50 states
            </Typography>
          </Box>

          <Stack direction="row" spacing={1} sx={{ alignItems: 'center' }}>
            <Tooltip title="Trigger simulator now (demo)">
              <Button
                size="small"
                variant="outlined"
                startIcon={<SyncIcon />}
                onClick={() => { void triggerSimulate() }}
                sx={{ borderColor: 'divider', color: 'text.secondary' }}
              >
                Simulate
              </Button>
            </Tooltip>
            <Chip
              label={isFetching ? 'Syncing…' : `Next sync ${countdown}`}
              size="small"
              icon={
                isFetching ? (
                  <CircularProgress size={12} sx={{ color: 'inherit !important' }} />
                ) : (
                  <SyncIcon sx={{ fontSize: '14px !important' }} />
                )
              }
              sx={{ borderColor: 'divider' }}
              variant="outlined"
            />
          </Stack>
        </Stack>

        <Divider sx={{ mt: 3, mb: 3 }} />

        {/* Summary bar */}
        <Stack direction="row" spacing={3} useFlexGap sx={{ flexWrap: 'wrap' }}>
          <SummaryItem count={upCount} label="Operational" color={STATUS_COLOR.up} />
          <SummaryItem count={plannedCount} label="Planned Outage" color={STATUS_COLOR.planned_outage} />
          <SummaryItem count={downCount} label="Outage" color={STATUS_COLOR.down} />
        </Stack>
      </Box>

      {/* Body */}
      {isLoading && (
        <Box sx={{ display: 'flex', justifyContent: 'center', py: 10 }}>
          <CircularProgress />
        </Box>
      )}

      {isError && (
        <Alert severity="error" sx={{ mb: 3 }}>
          Failed to load state data. Make sure the Rails server is running on port 3000.
        </Alert>
      )}

      {states && (
        <StateGrid states={states} onSelect={setSelected} />
      )}

      <OutageModal state={selected} onClose={() => setSelected(null)} />
    </Box>
  )
}

interface SummaryItemProps {
  count: number
  label: string
  color: string
}

function SummaryItem({ count, label, color }: SummaryItemProps) {
  return (
    <Stack direction="row" spacing={1.5} sx={{ alignItems: 'center' }}>
      <Typography variant="h4" sx={{ color, lineHeight: 1, fontWeight: 800 }}>
        {count}
      </Typography>
      <Typography variant="body2" color="text.secondary">
        {label}
      </Typography>
    </Stack>
  )
}
