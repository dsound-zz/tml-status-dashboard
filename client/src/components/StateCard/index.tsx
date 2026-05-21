import { Box, Card, CardActionArea, Chip, Stack, Tooltip, Typography } from '@mui/material'
import SpeedIcon from '@mui/icons-material/Speed'
import type { StateRecord } from '../../types'
import { StatusBadge } from '../StatusBadge'
import { formatLastChecked, formatResponseTime, STATUS_COLOR } from '../../lib/statusHelpers'

interface Props {
  state: StateRecord
  onClick: (state: StateRecord) => void
}

export function StateCard({ state, onClick }: Props) {
  const accentColor = STATUS_COLOR[state.status]

  return (
    <Card
      elevation={0}
      sx={{
        border: '1px solid',
        borderColor: 'divider',
        borderTopColor: accentColor,
        borderTopWidth: 3,
        backgroundColor: 'background.paper',
        transition: 'border-color 0.3s ease, box-shadow 0.2s ease',
        '&:hover': {
          boxShadow: `0 0 0 1px ${accentColor}44`,
          borderColor: `${accentColor}66`,
          borderTopColor: accentColor,
        },
      }}
    >
      <CardActionArea onClick={() => onClick(state)} sx={{ p: 2 }}>
        <Stack
          direction="row"
          sx={{ justifyContent: 'space-between', alignItems: 'flex-start', mb: 1 }}
        >
          <Box>
            <Typography variant="h6" sx={{ fontWeight: 700, lineHeight: 1.2 }}>
              {state.abbreviation}
            </Typography>
            <Typography variant="caption" color="text.secondary">
              {state.name}
            </Typography>
          </Box>
          <StatusBadge status={state.status} />
        </Stack>

        <Typography
          variant="caption"
          color="text.secondary"
          sx={{
            display: '-webkit-box',
            WebkitLineClamp: 1,
            WebkitBoxOrient: 'vertical',
            overflow: 'hidden',
            mb: 1.5,
          }}
        >
          {state.department_name}
        </Typography>

        <Stack direction="row" spacing={0.5} useFlexGap sx={{ flexWrap: 'wrap', mb: 1.5 }}>
          <Chip label={state.api_type} size="small" sx={{ fontSize: 10 }} />
          <Chip label={state.data_format} size="small" sx={{ fontSize: 10 }} />
        </Stack>

        <Stack direction="row" sx={{ justifyContent: 'space-between', alignItems: 'center' }}>
          <Tooltip title="Response time">
            <Stack direction="row" spacing={0.5} sx={{ alignItems: 'center' }}>
              <SpeedIcon sx={{ fontSize: 14, color: 'text.secondary' }} />
              <Typography variant="caption" color="text.secondary">
                {formatResponseTime(state.response_time_ms)}
              </Typography>
            </Stack>
          </Tooltip>
          <Typography variant="caption" color="text.disabled">
            {formatLastChecked(state.last_checked_at)}
          </Typography>
        </Stack>
      </CardActionArea>
    </Card>
  )
}
