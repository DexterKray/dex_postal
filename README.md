# dex_postal

<img width="162" height="69" alt="image" src="https://github.com/user-attachments/assets/4dba23b9-1558-4f75-9ae7-0c71aa39558e" />

Dependencies

- OX_LIB
- QBCore

Drag and drop into your resources folder

add your maps postal codes into the postalcodes.json

ensure dex_postal

PREVIEW : https://youtu.be/eRq9mthnIAc

<img width="906" height="25" alt="image" src="https://github.com/user-attachments/assets/2506cb05-3262-483c-a60a-91431641e50e" />

--

Fully open source can change notify's / CSS styling / default position to where you would like. 

Background transitions with game time, so postal is easier to see at night. 

Restarting the postal live while loaded in as a player the postal will disapear as the postal is loaded on the QBCore:OnPlayerLoaded event, just do /hidepostal twice and it will reappear. 

Commands:

/movepostal - allows users to move their postal location anywhere on their screen and its position is saved to the database with thier tx licence.

/postal <postalcode> create a gps marker to specified postal number

/hidepostal - Hides the postal for a player if they choose, uses a KVP to save the state to the players cache, so it persists over restarts 

1.3.0 - Postal Hide and Show Exports

Show the postal if hidden (checks KVP state so if a player the postal hidden its not shown again when this is closed)
exports['dex_postal]:Show() 

Hide the postal if not hidden (again check KVP for the state of the postal)
exports['dex_postal]:Hide() 