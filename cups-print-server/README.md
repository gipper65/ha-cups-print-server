# CUPS Print Server Add-on for Home Assistant (v1.1.0)

This add-on installs CUPS (Common Unix Printing System) in Home Assistant with a REST API for easy printing from automations.

## What's New in v1.1.0

- **REST API**: Print directly via HTTP POST (no docker exec needed!)
- Persistent configuration across restarts
- Simple integration with Home Assistant automations

## Installation

1. Copy this entire folder to `/addons/cups-print-server/` on your Home Assistant system
2. Go to **Settings > Add-ons > Add-on Store**
3. Click the three dots menu (top right) > **Check for updates**
4. You should see "CUPS Print Server" appear as a local add-on
5. Click on it and install

## Configuration

### Options

- **admin_password**: Password for the CUPS web interface (default: "admin")

## Usage

### Setting Up Your Printer

1. After starting the add-on, go to `http://homeassistant.local:631`
2. Click "Administration" > "Add Printer"
3. Login with username `cupsdmin` and your configured password
4. Follow the wizard to add your Epson 3850

### Printing from Home Assistant (NEW - v1.1.0)

Use the REST API - much simpler than docker commands!

#### Add to configuration.yaml:

```yaml
rest_command:
  print_test_page:
    url: http://homeassistant.local:5000/print
    method: POST
    content_type: 'application/json'
    payload: '{"printer": "EPSON", "file": "/config/www/ptm.pdf"}'
```

#### Create automation:

```yaml
automation:
  - alias: "Weekly Printer Test"
    trigger:
      - platform: time
        at: "09:00:00"
    condition:
      - condition: time
        weekday:
          - mon
    action:
      - service: rest_command.print_test_page
```

### API Endpoints

**Print a file:**
```bash
POST http://homeassistant.local:5000/print
Content-Type: application/json

{
  "printer": "EPSON",
  "file": "/config/www/ptm.pdf"
}
```

**Health check:**
```bash
GET http://homeassistant.local:5000/health
```

### Finding Your Printer Name

After adding your printer in CUPS, you can find its exact name by:
1. Going to http://homeassistant.local:631
2. Click "Printers"
3. Use the name shown (e.g., "EPSON", "Epson_3850")

## Troubleshooting

### Print command fails
- Verify printer name in CUPS web interface
- Ensure PDF file exists at `/config/www/filename.pdf`
- Check add-on logs for errors

### Can't access print service
- Make sure add-on is running
- Try `http://YOUR_HA_IP:5000/health`
- Check that port 5000 is not blocked

## Technical Details

- **CUPS Version**: Latest from Debian Bookworm
- **Included Drivers**: ESC/P-R (Epson), Gutenprint
- **REST API**: Flask on port 5000
- **Web Interface**: Port 631
- **Persistent Storage**: `/addon_configs/local_cups-print-server/`
