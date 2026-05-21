import {
  Drawer,
  Box,
  Typography,
  Chip,
  Divider,
  IconButton,
  Stack,
} from '@mui/material'
import CloseIcon from '@mui/icons-material/Close'
import WarningAmberIcon from '@mui/icons-material/WarningAmber'
import type { StateRecord } from '../../types'
import { StatusBadge } from '../StatusBadge'
import { formatOutageWindow } from '../../lib/statusHelpers'

interface Props {
  state: StateRecord | null
  onClose: () => void
}

export function OutageModal({ state, onClose }: Props) {
  if (!state) return null

  const isPlanned = state.status === 'planned_outage'

  return (
    <Drawer anchor="right" open={!!state} onClose={onClose}>
      <Box sx={{ width: 420, p: 3, height: '100%', display: 'flex', flexDirection: 'column' }}>
        <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', mb: 2 }}>
          <Box>
            <Typography variant="h5" sx={{ fontWeight: 700 }}>
              {state.name}
            </Typography>
            <Typography variant="body2" color="text.secondary" sx={{ mt: 0.5 }}>
              {state.abbreviation}
            </Typography>
          </Box>
          <IconButton onClick={onClose} size="small">
            <CloseIcon />
          </IconButton>
        </Box>

        <StatusBadge status={state.status} size="medium" />

        <Divider sx={{ my: 2 }} />

        {(isPlanned || state.status === 'down') && (
          <Box
            sx={{
              p: 2,
              borderRadius: 2,
              backgroundColor: isPlanned ? 'rgba(255,152,0,0.08)' : 'rgba(244,67,54,0.08)',
              border: `1px solid ${isPlanned ? '#ff9800' : '#f44336'}33`,
              mb: 2,
            }}
          >
            <Stack direction="row" spacing={1} sx={{ alignItems: 'center', mb: 1 }}>
              <WarningAmberIcon sx={{ color: isPlanned ? '#ff9800' : '#f44336', fontSize: 20 }} />
              <Typography
                variant="subtitle2"
                sx={{ fontWeight: 700, color: isPlanned ? '#ff9800' : '#f44336' }}
              >
                {isPlanned ? 'Planned Maintenance' : 'Unplanned Outage'}
              </Typography>
            </Stack>
            {isPlanned && state.planned_outage_start && state.planned_outage_end && (
              <Typography variant="body2" color="text.secondary" sx={{ mb: 1 }}>
                {formatOutageWindow(state.planned_outage_start, state.planned_outage_end)}
              </Typography>
            )}
            {state.outage_reason && (
              <Typography variant="body2">{state.outage_reason}</Typography>
            )}
            {state.status === 'down' && !state.outage_reason && (
              <Typography variant="body2" color="text.secondary">
                Cause under investigation. No ETA available.
              </Typography>
            )}
          </Box>
        )}

        <Typography variant="subtitle1" sx={{ fontWeight: 700, mb: 1 }}>
          Department
        </Typography>
        <Typography variant="body2" color="text.secondary" sx={{ mb: 0.5 }}>
          {state.department_name}
        </Typography>
        <Typography variant="body2">{state.contact_name}</Typography>
        <Typography variant="body2" color="text.secondary">
          {state.contact_email}
        </Typography>
        <Typography variant="body2" color="text.secondary" sx={{ mb: 2 }}>
          {state.contact_phone}
        </Typography>

        <Divider sx={{ mb: 2 }} />

        <Typography variant="subtitle1" sx={{ fontWeight: 700, mb: 1 }}>
          Integration Details
        </Typography>
        <Stack direction="row" spacing={1} useFlexGap sx={{ flexWrap: 'wrap', mb: 2 }}>
          <Chip label={state.api_type} size="small" variant="outlined" />
          <Chip label={state.api_version} size="small" variant="outlined" />
          <Chip label={state.data_format} size="small" variant="outlined" />
          <Chip label={state.auth_method} size="small" variant="outlined" />
        </Stack>

        <Typography variant="subtitle2" sx={{ fontWeight: 700, mb: 0.5, color: 'text.secondary' }}>
          Protocol Notes
        </Typography>
        <Typography variant="body2" color="text.secondary" sx={{ lineHeight: 1.7, flex: 1 }}>
          {state.protocol_notes}
        </Typography>

        <Divider sx={{ my: 2 }} />

        <Stack direction="row" sx={{ justifyContent: 'space-between' }}>
          <Box>
            <Typography variant="caption" color="text.secondary">
              30-day uptime
            </Typography>
            <Typography variant="body2" sx={{ fontWeight: 600 }}>
              {state.uptime_30d.toFixed(2)}%
            </Typography>
          </Box>
          <Box sx={{ textAlign: 'right' }}>
            <Typography variant="caption" color="text.secondary">
              Response time
            </Typography>
            <Typography variant="body2" sx={{ fontWeight: 600 }}>
              {state.response_time_ms}ms
            </Typography>
          </Box>
        </Stack>
      </Box>
    </Drawer>
  )
}
