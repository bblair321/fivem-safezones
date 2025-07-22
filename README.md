# FiveM Safezone Mod

## Overview

This resource allows server owners to create persistent safezones where players cannot attack or be attacked. Safezones are managed with admin commands and are saved across server restarts.

---

## Installation

1. **Copy the Resource:**

   - Place the entire `fivem-safezone` folder into your server's `resources` directory.

2. **Add to server.cfg:**

   - Add the following line to your `server.cfg`:
     ```
     ensure fivem-safezone
     ```

3. **Grant Admin Permissions:**
   - To allow certain players or groups to use safezone admin commands, grant the `safezone.admin` ace permission. For example, to allow all admins:
     ```
     add_ace group.admin safezone.admin allow
     ```
   - You can also assign this permission to specific identifiers or groups as needed.

---

## Usage

### Admin Commands

- `/addsafezone [radius]`  
  Adds a safezone at your current location. The radius is optional (default: 50.0 meters).
- `/removesafezone`  
  Removes the nearest safezone to your current location (within its radius + 10 meters).
- `/listsafezones`  
  Lists all current safezones with their coordinates and radii.
- `/reloadsafezones`  
  Reloads safezones from the `safezones.json` file (useful if you edit the file manually).

### Player Experience

- Players entering a safezone will see a green marker and receive a notification.
- Combat is disabled and players are invincible while inside a safezone.
- Leaving a safezone restores normal gameplay.

---

## Persistence

- All safezones are saved in `safezones.json` in the resource folder.
- Zones are automatically loaded on server/resource start.

---

## Troubleshooting

- **Safezones not saving/loading?**
  - Ensure the server has write permissions to the `safezones.json` file.
  - Use `/reloadsafezones` to manually reload from file.
- **Admin commands not working?**
  - Make sure your account or group has the `safezone.admin` ace permission.
- **No notifications or markers?**
  - Ensure the `chat` resource is running (required for notifications).

---

## Customization

- You can edit the code to change marker color, notification messages, or add more features as needed.

---

## Credits

Created by bblair321. Feel free to modify and make a pull request if you want!
