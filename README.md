# Lights

Home Assistant configuration as code for smart lighting control.

## Overview

This repo manages lighting automations for a room with three Zigbee lights (hanging, kallax, bedside) controlled via Zigbee2MQTT. Lights automatically switch between modes based on time of day, and can be manually controlled with physical remotes.

## Lighting Modes

| Mode | Time | Brightness | Color Temp |
|------|------|------------|------------|
| **Work** | Weekdays 9am-5pm | 100% | Cool (5000K) |
| **Relax** | 8-9am, 5-10pm | ~85% | Warm (3100K) |
| **Wind Down** | 10pm-8am | ~40% | Very warm (2700K) |

## Features

- **Time-based automation**: Modes switch automatically based on schedule
- **Physical remotes**: On/off and arrow buttons to cycle through modes
- **Wake-up light**: Gradual 5-minute sunrise synced with phone alarm
- **Phone alarm sync**: Reads next alarm from Android device

## Setup

### Requirements

- Home Assistant with SSH access
- Zigbee2MQTT addon
- Long-lived access token

### Configuration

Create a `.env` file:

```bash
HA_HOST=homeassistant.local
SSH_USER=root
HA_API_TOKEN=your_long_lived_token
```

### Deploy

```bash
./deploy.sh
```

This will:
1. Upload config files via SCP
2. Validate the configuration
3. Reload automations, scenes, and scripts

## File Structure

```
config/
├── automations.yaml    # All automations
├── configuration.yaml  # Main HA config
├── scenes.yaml         # Lighting scenes (work, relax, wind down, off)
├── scripts.yaml        # Custom scripts
├── secrets.yaml        # Sensitive values
└── zigbee2mqtt/        # Zigbee2MQTT config
```
