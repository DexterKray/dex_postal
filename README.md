# dex_postal

Dependencies

- OX_LIB
- QBCore

Drag and drop into your resources folder

add your maps postal codes into the postalcodes.json

ensure dex_postal

PREVIEW : https://youtu.be/eRq9mthnIAc

--

Fully open source can change notify's / CSS styling / default position to where you would like. 

Background transitions with game time, so postal is easier to see at night. 

Restarting the postal live while loaded in as a player the postal will disapear as the postal is loaded on the QBCore:OnPlayerLoaded event, just do /hidepostal twice and it will reappear. 

Commands:

/movepostal - allows users to move their postal location anywhere on their screen and its position is saved to the database with thier tx licence.

/postal <postalcode> create a gps marker to specified postal number

/hidepostal - Hides the postal for a player if they choose, uses a KVP to save the state to the players cache, so it persists over restarts 
