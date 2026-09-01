# Cosmic Overhaul — Player Guide

Welcome to **Cosmic Overhaul**!

Avorion is an incredible game, but managing a massive late-game fleet can feel like a second job. Cosmic Overhaul was built to reduce the friction of fleet management, expand the usefulness of your captains, and make the galaxy's economy more rewarding to interact with.

This guide walks through the core features so you know exactly what tools are at your disposal. For exact numbers and mechanic-by-mechanic detail, see `WIKI.md`.

---

## 📑 Contents

1. [Managing Your Empire](#1-managing-your-empire)
2. [Your Captains Matter](#-2-your-captains-matter-captain-synergies)
3. [Quality of Life & Logistics](#-3-quality-of-life--logistics)
4. [Diplomacy & The Underworld](#-4-diplomacy--the-underworld)
5. [Building Your Empire](#5-building-your-empire)
6. [Playing Alongside the Rest of the Cosmic Series](#-6-playing-alongside-the-rest-of-the-cosmic-series)

---

## 1. Managing Your Empire

As your fleet grows, keeping track of everything becomes difficult. Cosmic Overhaul adds several new UI panels to help you command your empire from anywhere.

* **The Command Center:** Open your Player Window (default `P`) and look for the **Command Center** tab. This is your fleet operations dashboard: see what operation every ship is running, where they are, their ETA, and remotely recall them without opening the Galaxy Map. The **Attention Needed** strip at the top instantly tells you how many ships are idle, about to finish, or recalled — click any of them to jump straight to that filter. It also tracks a running **Fleet Income** total from all your background trading, mining, and salvaging, so you can see exactly how much your empire is earning without digging through chat history.
* **Fleet Ship Status UI:** Monitor your entire fleet's health, shield, and operational status from a single, clean window without digging through nested menus. The ship lists show each ship's current hull durability right next to its name (color-coded so a damaged ship jumps out at you), and a ship critically low on hull will pulse on your HUD overlay instead of just sitting there in flat red.
* **Factory Overview:** Also in your Player Window, this tab lists every factory you own, including its exact sector location. It shows your profits, expenses, and a Status column that tells you at a glance whether a factory is running smoothly or stalled (and why), plus a Totals line summarizing your combined income, expenses, and profit across all of them. *(Older factories built before installing the mod register themselves automatically.)*
* **Universal Bulletin Board:** You no longer need to dock at every station in a sector to find a good mission. The Bulletin Board tab lets you view, sort by reward or difficulty, and accept missions from *any* station in your current sector.
* **The Wreckages Tab:** Open Sector Strategy Mode (default `F9`) and you'll find a new **Wreckages** tab. It sorts every piece of scrap in the sector by size and distance, making post-battle salvage a breeze.
* **War Zone Blockades:** If you're running Cosmic War alongside Cosmic Overhaul, stations in active war zones will reject all player docking requests to buy or sell goods, and background AI trader traffic is suspended until the siege is resolved.

### Galaxy Map Hotkeys

Navigating the Galaxy Map is now much faster:

* **`[T]` (Teleport):** Select one of your ships on the map and press `T` to instantly jump into its captain's chair.
* **`[Shift + C]` (Center):** Instantly snaps the map camera back to your Home Sector (or your Alliance's Home Sector if you're flying an alliance ship).

---

## 🎖️ 2. Your Captains Matter (Captain Synergies)

In Cosmic Overhaul, a captain's class has a massive impact on the galaxy around you, both while they're running background missions *and* while you're actively flying their ship.

### Active Piloting Synergies

When *you* are sitting in a ship commanded by one of these captains, you gain global passive bonuses just by flying it:

* **Merchant:** A 15% discount on all purchases and a 15% bonus payout on all sales at commercial stations (Trading Posts, Factories, Resource Depots, etc.).
* **Smuggler:** A 15% discount on unbranding stolen goods, and a 15% bonus payout when selling illegal goods at the Smuggler's Market.
* **Scavenger:** In the **Wreckages** tab in Strategy Mode, a Scavenger captain bypasses generic names like "Husk" or "Derelict" and reveals the *exact original identity* of the destroyed ship, helping you pinpoint the most valuable targets in a massive graveyard.

### Elite Captains (Level 3)

Get a captain to Level 3 and they unlock a sector-wide passive that stays active for as long as they're flying your ship:

* **Commodore:** Every friendly ship in the sector — not just yours — gets a shield and fire-rate boost.
* **Smuggler:** Your ship becomes completely invisible to cargo scans and contraband inspections, and quietly helps ease the local faction's economic troubles the longer you idle nearby.
* **Miner:** A solid bonus to yields from rich asteroids while you're mining.
* **Scavenger:** A major salvage yield boost while cleaning up wreckage inside an active Cosmic War siege zone.

### Smarter Background Missions

When sending ships on background map operations, your captains are much more capable:

* **Class Synergies:** Specialized captains assigned to their matching jobs will travel much further, complete operations up to **25% faster**, and suffer significantly fewer ambushes.
* **Better Salvage:** Captains running salvage operations now have a chance to find **Exotic** and **Legendary** items.
* **Immersive Scouting:** Scout operations generate rich, narrative-driven captain's logs. If your scouts are working while you're offline, they'll instantly reveal all their progress the moment you log back in.
* **Trade Missions:** Trade commands are much more flexible. Use "Immediate Delivery" for a quick payout, or run "Charity" missions to boost faction relations instead of chasing credits.

---

## ✨ 3. Quality of Life & Logistics

We've heavily modernized how you interact with your cargo holds, inventories, and ship building.

* **Color-Coded Cargo Transfers:** The Cargo Transfer window now features a search bar, alphabetical sorting, and color-coded cargo bars (red for illegal/stolen, yellow for dangerous).
* **Smart Transfers:** If you try to transfer 5,000 Iron to a ship that only has room for 2,000, the transfer no longer fails outright — it fills the receiving ship to the brim and leaves the rest behind.
* **Transfer Stacking:** Hold `Right Mouse Button (RMB)` while clicking "Transfer All" and the game will only transfer items the receiving ship *already has* in its hold — perfect for topping off supply ships.
* **The Trash Manager:** Mark unwanted inventory items as "Trash" without deleting them, then mass-sell them to merchants without risking your favorite gear. As of v5.3.0 this runs the newly overhauled Trash Manager Revamped.
* **Shop Restock Button & Cleaner Shops:** We cleaned up the massive, cluttered lists at Equipment Docks. To compensate, you can manually restock station shops with a built-in button (free uses at first, then a fair cooldown) to roll for the gear you actually want.
* **Resource Display HUD:** A configurable widget on your screen tracks credits, resources, cargo space, and inventory slots in real-time. It automatically switches to your Alliance vault when you hop into an alliance ship.
* **Subsystem Removal:** Permanently remove installed subsystems at Repair Docks, Shipyards, Military Outposts, Research Stations, and Scrapyards.
* **Repair Fleet in Sector:** Repair Docks have a new "Repair Fleet" button. One click repairs your entire private and Alliance fleet in the sector, deducting from your Alliance vault (if you have privileges) or falling back to your personal wallet for your private ships.
* **Relaxing Scrapyards:** The stressful time limits and friction at Scrapyards have been completely removed. Take your time and salvage in peace.
* **Scaling Subsystems:** Transporters and Trading Systems get massive range boosts (up to 10x) based on rarity. Transporters get even more range the more physical transporter blocks you build into your ship.
* **Persistence Resource Regeneration:** Stripped asteroid fields slowly regenerate ores over real-time, even while you're offline, instead of only on sector load. If the sector's owning faction falls into Severe Famine, this recovery pauses until the economy stabilizes.
* **Emergency Replenishment Anomalies:** A completely barren sector may trigger an emergency event that spawns new fields. This has a 5% chance to also uncover a permanent Precursor Wreck or Spatial Rift, and in populated sectors it broadcasts a galactic news alert.

---

## 🤝 4. Diplomacy & The Underworld

Whether you're making friends or making enemies, your actions have real weight.

* **Rewarding Friendships:** Positive actions with factions now build your reputation faster, making diplomacy feel more responsive.
* **Dynamic Reputation Decay:** Factions won't hold grudges — or alliances — forever. Ignore a faction long enough and your relationship will slowly drift back toward neutral. Allies forget, but Hostiles also forgive.
* **Alliance Mirroring:** Your personal reputation changes mirror directly to your Alliance, so your individual actions carry real diplomatic weight for your entire group. Small accidental hits (a stray shot, say) are heavily softened before they reach your Alliance's standing, so one mistake won't tank the whole group — but deliberately antagonizing a heavily fortified enemy faction from a Cosmic War campaign will hit your Alliance's reputation extra hard.
* **Immersive NPC Fleets:** The galaxy feels much more authentic. NPC ships now have realistic names that scale with their actual size and job — military fleets run from nimble *Interceptors* up to massive *Dreadnoughts* and *Leviathans*, while industrial fleets range from small *Light Prospectors* up to colossal *Planet Crackers*.
* **Unique Loot:** Enemies and merchants in the same sector no longer drop identical "cloned" items, so loot stays varied and exciting.
* **Lucrative Piracy & Boarding:** Destroying civilian freighters and transports now drops significantly more illegal cargo (scaling up to 250,000 credits based on the sector's wealth). Successfully **boarding** a ship also yields random System Upgrades from its bridge.
* **The Smuggler's Market:** The Black Market pays a real premium for illegal and dangerous goods, and these stations are now noticeably more likely to spawn in hidden mass-sectors off the grid. Unbranding costs have been rebalanced so the "steal → clean → sell" loop is a viable way to fund your empire.
  * **Dynamic Inventory:** Smugglers Markets scale their illegal goods inventory to match the current wealth of the local faction.
  * **The Fence System:** Your market automatically unbrands stolen goods from its own cargo hold in the background, no visit required.
  * **Syndicate Heat:** Passive unbranding isn't risk-free. It builds up heat, and once it caps out, it triggers a Sector Lockdown featuring both a Pirate raid and a local Faction Military strike on your market — though a real-time cooldown means you'll never get hit with back-to-back raids.
  * **Rift Tech Fencing:** If you're playing with the Into the Rift DLC content, classified Rift Research Data and Subclass Subsystems fence for a massive 150%–250% markup at the Smuggler's Market — though the local faction will notice and your reputation with them will take a temporary hit.
* **Deep Space Stashes:** Hidden stashes out in the galaxy now drop significantly better rewards as you progress into the late game, with massive credit multipliers (up to 10x) and much higher-tier upgrade drops.
* **Starving Your Enemies:** Destroying an enemy faction's resource sectors can push them into Severe Famine. Ships built by a starving faction come out noticeably weaker — softer shields, slower engines — making them a far easier target for a follow-up invasion.

---

## 5. Building Your Empire

Your passive empire is now much smarter and more integrated.

* **Profitable Stations:** Service stations you build (Casinos, Repair Docks, Travel Hubs, Resource Depots) now actually generate passive income. As NPC civilian traffic "uses" your stations, they periodically pay you taxes and credits, and sometimes drop off subsystems or turrets.
* **Warzone Disruption:** If you use the *Cosmic War* mod, be careful — civilian traffic actively avoids highly contested warzones. Stations in a hostile area will see their passive income dry up until the sector is secured.
* **War Profiteering:** On the flip side, if you're the one *supplying* a warzone rather than passively sitting near one, deliveries into a high-heat War Zone pay out an enormous income bonus — and stations deep toward the galactic core earn even more on top of that. High risk, high reward.
* **Smarter Economies:** Station shuttles scale much better into the late game, and NPC trade flow logic feels much more alive.
* **Gate Travel Priority:** When issuing chained travel orders on the Galaxy Map, your ships now prioritize Gate networks and Wormholes instead of slowly hyperspace-jumping across the galaxy.
* **Restored Automation:** Classic 1.0 map commands (Mine, Refine, Salvage, and Loop) are back. Queue multiple orders (e.g. Jump → Mine → Jump → Refine) by holding `SHIFT`, then use the **Loop** command to repeat the sequence indefinitely.

---

## 🔗 6. Playing Alongside the Rest of the Cosmic Series

Cosmic Overhaul only *requires* `Cosmic Vault` to run — but it's built to recognize the rest of the Cosmic Series automatically. Install `Cosmic War`, `Cosmic Chronicles`, and/or `Cosmic Ascendancy` alongside it and these extra mechanics switch on with no setup needed:

* **Dynamic Trade Pricing:** Send a merchant to trade with a faction suffering a Famine and they can bring back up to 2.5x more profit.
* **Weather-Affected Commands:** Your Travel and Scout operations respect Cosmic Vault's dynamic weather. An Ion Storm or Nebula delays operations by 50%, unless piloted by an Explorer or Navigator.
* **Siege Blockade Halts (Cosmic War):** If a sector turns into an active War Zone and the defenders are badly outgunned, factory production halts completely until the siege is lifted.
* **Blockade Runner Governors (Cosmic War):** Smuggler Governors bypass factory blockades entirely during active sieges — handy for wartime profiteering.
* **Siege Salvage Yield (Cosmic War):** A Scavenger captain flying inside a Contested Siege Zone gets a major bonus to Salvage Yield while cleaning up wreckage.
* **Scout Anomalies (Cosmic Chronicles):** Explorer captains charting empty sectors leave cryptic notes hinting at Cosmic Chronicles story events.
* **Famine Relief Charity (Cosmic Chronicles):** Background Charity Missions to starving factions grant a large reputation bonus.
* **Ascendancy Trade Fear (Cosmic Ascendancy):** Non-smuggler merchant trade flights take noticeably longer if the target faction is at war with The Eclipse. Smugglers bypass this entirely.
* **Ascendant Neural Implants (Cosmic Ascendancy):** Equip the legendary Ascendant Neural Implant subsystem, transforming your ship into a biomechanical dreadnought.
* **Privateer Subsidies:** Merchant Governors cut crew and captain hiring costs in half while you're enlisted as a Mercenary for the station's faction.
* **CCM Keybind Interoperability:** The Bulletin Board and Resource Display panels support your own custom hotkeys through Cosmic Vault's Cosmic Configuration Menu.
* **Deep Economy Warfare:** Famine and prosperity generated in Overhaul feed directly into the shared Cosmic Vault economy, which can push starving factions to declare war on wealthy neighbors just to survive.
* **In-Game Codex:** Everything above — plus the full technical detail from `WIKI.md` — is also readable in-game through the **Cosmic Codex**, so you never have to tab out to look something up.

---

Enjoy your time in Cosmic Overhaul!
