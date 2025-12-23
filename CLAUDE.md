# CLAUDE.md

This file provides guidance to Claude Code when working on this project.

## Project Overview

Home Assistant Infrastructure as Code for smart lighting. Config files are edited locally and deployed to the HA instance via the deploy script.

## Key Commands

```bash
# Deploy changes to Home Assistant
./deploy.sh
```

The deploy script requires a `.env` file with `HA_HOST`, `SSH_USER`, and `HA_API_TOKEN`.

## Architecture

- **Lighting modes**: work, relax, wind down (defined in `input_select.states`)
- **State machine**: `input_boolean.on_off` controls whether lights are on, `input_select.states` controls which scene is active
- **Main automation**: The `on` automation (id `1734424773862`) listens to both inputs and applies the correct scene

## File Locations

| File | Purpose |
|------|---------|
| `config/automations.yaml` | All automations (button handlers, time triggers, state changes) |
| `config/scenes.yaml` | Scene definitions with brightness and color temp for each light |
| `config/configuration.yaml` | Main HA config, includes other YAML files |
| `config/.storage/input_select` | Defines available states (work, relax, wind down) |
| `config/.storage/input_boolean` | Defines on/off toggle |

## Device IDs

Two MQTT remotes trigger button automations:
- `830765b3feb95abfc62c10ab7e9a701d`
- `4241fcfa80c0c8098fbc91d54a28ee53`

Lights:
- `light.hanging`
- `light.kallax`
- `light.bedside`
- `light.all` (group)

## Common Tasks

### Adding a new lighting mode

1. Add the option to `config/.storage/input_select` in the `states` item
2. Create a new scene in `config/scenes.yaml`
3. Add a condition branch in the `on` automation (`config/automations.yaml`, id `1734424773862`)
4. Run `./deploy.sh`

### Adding a new button action

1. Find the subtype for the button action (check Zigbee2MQTT device page)
2. Add a new automation in `config/automations.yaml` with triggers for both remote device IDs
3. Run `./deploy.sh`

## Testing

After deploying, verify changes in Home Assistant:
- Developer Tools > States: Check `input_select.states` and `input_boolean.on_off`
- Developer Tools > Services: Manually trigger automations
- Settings > Automations: Verify automations loaded correctly
