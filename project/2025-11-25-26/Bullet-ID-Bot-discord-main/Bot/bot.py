import discord
import asyncio
import configparser
import os

intents = discord.Intents.default()
intents.members = True
client = discord.Client(intents=intents)

# Portable path: always points to BulletID/config/config.ini
project_root = os.path.dirname(os.path.dirname(__file__))  # BulletID/
CONFIG_FILE = os.path.join(project_root, "config", "config.ini")

staff_cache = {}

def load_config():
    config = configparser.ConfigParser()
    config.read(CONFIG_FILE)
    return config

def parse_staff_entry(entry: str):
    parts = [p.strip() for p in entry.split("|")]
    data = {}
    for part in parts:
        if "=" in part:
            key, val = part.split("=", 1)
            data[key.strip().lower()] = val.strip()
        else:
            data.setdefault("type", part)
    return data

def status_color(status: str):
    status = status.lower()
    if status == "active":
        return discord.Color.green()
    elif status == "suspended":
        return discord.Color.red()
    elif status == "under investigation":
        return discord.Color.gold()
    else:
        return discord.Color.blue()

async def clear_dm(user: discord.User):
    if user.dm_channel is None:
        await user.create_dm()
    async for msg in user.dm_channel.history(limit=None):
        if msg.author == client.user:
            await msg.delete()

async def send_staff_embed_with_countdown(user, staff_id, channel, data, delay=10):
    if user.id in staff_cache:
        old = staff_cache[user.id]
        try:
            if old.get("channel_msg"):
                old_msg = await channel.fetch_message(old["channel_msg"])
                await old_msg.delete()
        except Exception:
            pass
        try:
            if old.get("dm_msg") and user.dm_channel:
                old_dm = await user.dm_channel.fetch_message(old["dm_msg"])
                await old_dm.delete()
        except Exception:
            pass

    final_embed = discord.Embed(
        title=f"{data.get('type','Staff')} Assignment",
        description=(
            f"{user.mention},\n\n"
            f"ID: **{data.get('id', staff_id)}**\n"
            f"Status: **{data.get('status','Unknown')}**\n"
            f"Rank: **{data.get('rank','Unspecified')}**"
        ),
        color=status_color(data.get("status",""))
    )
    final_embed.set_footer(text="Staff Automation System")
    msg = await channel.send(embed=final_embed)

    try:
        await clear_dm(user)
        embed = discord.Embed(
            title="Updating Staff Assignment",
            description=f"{user.mention}, your ID is being refreshed.\nPlease wait {delay} seconds...",
            color=discord.Color.orange()
        )
        dm_msg = await user.send(embed=embed)

        for i in range(delay, 0, -1):
            await asyncio.sleep(1)
            embed.description = f"{user.mention}, your ID is being refreshed.\nPlease wait {i} seconds..."
            await dm_msg.edit(embed=embed)

        await dm_msg.edit(embed=final_embed)
    except discord.Forbidden:
        dm_msg = None
        print(f"Could not DM {user.name}")

    staff_cache[user.id] = {"channel_msg": msg.id, "dm_msg": dm_msg.id if dm_msg else None}

async def monitor_config():
    await client.wait_until_ready()
    last_config = None
    while not client.is_closed():
        try:
            config = load_config()
            delay = int(config["settings"].get("update_delay", 0))

            if last_config is None:
                channel_id = int(config["settings"]["channel_id"])
                channel = client.get_channel(channel_id)
                if channel:
                    async for msg in channel.history(limit=None):
                        if msg.author == client.user:
                            await msg.delete()
                    for user_id, entry in config["staff"].items():
                        data = parse_staff_entry(entry)
                        staff_id = data.get("id", entry)
                        user = await client.fetch_user(int(user_id))
                        await send_staff_embed_with_countdown(user, staff_id, channel, data, delay)
                last_config = config

            elif config.items("staff") != last_config.items("staff"):
                channel_id = int(config["settings"]["channel_id"])
                channel = client.get_channel(channel_id)
                if not channel:
                    print("Channel not found or bot lacks permission.")
                    await asyncio.sleep(5)
                    continue

                for user_id, entry in config["staff"].items():
                    old_entry = dict(last_config["staff"]).get(user_id)
                    if old_entry != entry:
                        data = parse_staff_entry(entry)
                        staff_id = data.get("id", entry)
                        user = await client.fetch_user(int(user_id))
                        await send_staff_embed_with_countdown(user, staff_id, channel, data, delay)

                last_config = config

            await asyncio.sleep(5)
        except Exception as e:
            print(f"Error monitoring config: {e}")
            await asyncio.sleep(5)

@client.event
async def on_ready():
    print(f"Bot logged in as {client.user}")
    client.loop.create_task(monitor_config())

if __name__ == "__main__":
    config = load_config()
    TOKEN = config["settings"]["token"]
    client.run(TOKEN)
