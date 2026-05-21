import { Box, Chip } from '@mui/material'
import type { StatusValue } from '../../types'
import { STATUS_COLOR, STATUS_LABEL } from '../../lib/statusHelpers'

interface Props {
  status: StatusValue
  size?: 'small' | 'medium'
}

export function StatusBadge({ status, size = 'small' }: Props) {
  const color = STATUS_COLOR[status]
  const dotSize = size === 'small' ? 10 : 14

  return (
    <Chip
      size={size}
      label={STATUS_LABEL[status]}
      icon={
        <Box
          component="span"
          sx={{
            width: dotSize,
            height: dotSize,
            borderRadius: '50%',
            backgroundColor: color,
            display: 'inline-block',
            flexShrink: 0,
            animation: `${status}-pulse 2s ease-in-out infinite`,
            '@keyframes up-pulse': {
              '0%, 100%': { opacity: 1, transform: 'scale(1)' },
              '50%': { opacity: 0.6, transform: 'scale(0.85)' },
            },
            '@keyframes planned_outage-pulse': {
              '0%, 100%': { opacity: 1 },
              '50%': { opacity: 0.4 },
            },
            '@keyframes down-pulse': {
              '0%, 100%': { opacity: 1, transform: 'scale(1)' },
              '30%': { opacity: 0.3, transform: 'scale(0.7)' },
              '60%': { opacity: 1, transform: 'scale(1.15)' },
            },
          }}
        />
      }
      sx={{
        borderColor: color,
        color: color,
        border: '1px solid',
        backgroundColor: `${color}14`,
        fontWeight: 600,
        '& .MuiChip-icon': { ml: '6px' },
      }}
      variant="outlined"
    />
  )
}
