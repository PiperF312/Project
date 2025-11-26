README.txt
===========

READ THIS FIRST before editing the config.ini file
--------------------------------------------------

This file explains exactly what you can and cannot change in the config.ini file.
Follow the instructions carefully to avoid breaking the bot.

---

CONFIG.INI TEMPLATE
-------------------

[settings]
channel_id = 123252722022345678   # <-- Put your Discord channel ID here
token = YOUR_BOT_TOKEN_HERE       # <-- Put your bot token here
max_ids_per_account = 1           # <-- DO NOT TOUCH

[staff]
# Format:
# USER_ID = Staff Type | ID=STAFF-XXX | Status=STATUS_OPTION | Rank=YOUR_CUSTOM_RANK
# - USER_ID: Discord user ID of the staff member
# - Staff Type: Either 'Discord Staff' or 'Game Staff'
# - ID=STAFF-XXX: Unique staff ID you assign (e.g., STAFF-001)
# - Status: One of the following (case-insensitive):
#     - Active               → Green embed
#     - Suspended            → Red embed
#     - Under Investigation  → Gold embed
# - Rank: Any custom rank you want to assign

# Example entries:
# IDs go here ↓
1111232222222222222 = Discord Staff | ID=STAFF-001 | Status=Active | Rank=Moderator
1222222222222133133 = Game Staff    | ID=STAFF-002 | Status=Suspended | Rank=Officer
1350000000000000000 = Discord Staff | ID=STAFF-003 | Status=Under Investigation | Rank=Helper

---

NOTES
-----
- Only edit the values marked with instructions.
- Do NOT change 'max_ids_per_account'.
- You can add as many staff entries as needed under [staff].
- Each staff member will receive a DM and a message will be posted in the specified channel.
