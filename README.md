# dex_postal

Lightweight postal code display for QBCore/QBox — shows player's current postal, lets players create GPS markers, move or hide the HUD, and persist settings.

Preview: https://youtu.be/eRq9mthnIAc

---

## Features

- Shows a small, styled postal HUD that updates live.
- Create GPS waypoints to postal codes with `/postal <postal>`.
- Move the HUD anywhere on the screen with `/movepostal` (position saved to player data).
- Hide/show the HUD per-player; hidden state is persisted with a KVP so it survives restarts.
- Day/night background transitions for readability.

## Requirements

- `OX_LIB`

## Installation

1. Drop the `dex_postal` folder into your server `resources` directory.
2. Add this to your server config (e.g. `server.cfg`):

```
ensure dex_postal
```

3. (Optional) Import the SQL in `INSTALL/dexpostal.sql` if you want to use the included DB schema.
4. Edit `postalcodes.json` to add or adjust postal codes for your map.

## Configuration

- Edit `postalcodes.json` to add postal code definitions for your map/locations.
- Frontend UI lives in the `html/` folder — you can customize `style.css` and `script.js` to change appearance or behaviour.

## Commands

- `/movepostal` — Enter move mode to position the postal HUD; position is saved to the player's TX license in the DB.
- `/postal <postalcode>` — Create a GPS marker to the specified postal code.
- `/hidepostal` — Toggle hiding the postal HUD for the current player. Hidden state is saved using a KVP.

Note: If you restart the resource while a player is online the HUD may disappear in some cases; running `/hidepostal` twice will restore it.

## Exports (API)

You can show or hide the postal HUD from other resources:

```lua
exports['dex_postal']:Show()
exports['dex_postal']:Hide()
```

These respect the player's saved KVP state.

## Troubleshooting

- HUD not showing after restart: try `/hidepostal` twice while in-game.
- Postal codes not found: confirm your `postalcodes.json` entries match the values you pass to `/postal`.

## Customization

- Styling: edit `html/style.css`.
- Behaviour: edit `html/script.js` and server/client Lua as needed.
- Notifications: swap to your preferred notify implementation if you don't use the included one.

## Files of Interest

- `client.lua` — client-side logic and HUD handling.
- `server.lua` — server-side commands and DB interactions.
- `postalcodes.json` — add or edit postal entries for your map.
- `html/` — UI files (`index.html`, `script.js`, `style.css`).
- `INSTALL/dexpostal.sql` — optional SQL for DB schema.

## License & Credits

This resource is fully open source — modify the CSS, notifications, or default positions as you like. Created by DexterKray.

If you'd like, I can also tidy up the UI, update the exports docs in-code, or create a small config file for easier server-side configuration. Want me to commit this change?