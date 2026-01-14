# CUPS Add-on Installation Instructions

## Step 1: Transfer Files to Home Assistant

You need to copy the entire cups-addon folder to your Home Assistant `/addons/` directory.

### Method A: Using Samba Share (Easiest)
1. Enable the Samba add-on in Home Assistant if not already enabled
2. Connect to your Home Assistant via network share (\\homeassistant.local)
3. Navigate to the `addons` folder
4. Copy the entire `cups-print-server` folder here

### Method B: Using SSH/SCP
```bash
# From your local machine with the files
scp -r cups-addon root@homeassistant.local:/addons/cups-print-server
```

### Method C: Using Terminal Add-on
1. Install and start the Terminal add-on
2. Create the directory: `mkdir -p /addons/cups-print-server`
3. Use the built-in file editor to create each file manually

## Step 2: Load the Add-on

1. Go to **Settings > Add-ons > Add-on Store**
2. Click the **three dots menu** in the top-right corner
3. Select **Check for updates**
4. Scroll down to **Local add-ons** section
5. You should see **CUPS Print Server** appear
6. Click on it

## Step 3: Configure and Start

1. Go to the **Configuration** tab
2. Set your desired admin password
3. Click **Save**
4. Go to the **Info** tab
5. Click **Start**
6. Enable **Start on boot** if desired

## Step 4: Add Your Printer

1. Open a browser and go to `http://homeassistant.local:631`
2. Click **Administration** > **Add Printer**
3. Login when prompted:
   - Username: `cupsdmin`
   - Password: (what you set in configuration)
4. Select your Epson 3850 from the list
5. Follow the wizard to complete setup
6. Print a test page to verify

## Step 5: Configure Home Assistant to Print

Add to your `configuration.yaml`:

```yaml
shell_command:
  print_test_page: 'docker exec addon_local_cups-print-server lp -d YOUR_PRINTER_NAME /config/www/test_page.pdf'
```

Replace `YOUR_PRINTER_NAME` with the exact name from CUPS (step 4).

Create an automation:

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
      - service: shell_command.print_test_page
```

## Troubleshooting

### Add-on doesn't appear
- Make sure files are in `/addons/cups-print-server/` (not `/addons/cups-addon/`)
- Check file permissions
- Restart Home Assistant

### Can't connect to CUPS web interface
- Make sure add-on is running
- Check add-on logs for errors
- Try `http://YOUR_HA_IP:631` instead

### Printer not found
- Verify printer is on the same network
- Check if printer supports network printing
- Try adding by IP address in CUPS

### Print command fails
- Verify container name: `docker ps | grep cups`
- Check printer name: visit CUPS web interface
- Ensure PDF file exists at specified path
