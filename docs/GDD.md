# Game Design Document — ColheitaFeliz (Codename)

G1.4 addendum (delivery closed 2026-10-26, ADR-018): prioritize historically
inventoried mechanics before modern systems, with original code/art. G1.3 was
functionally accepted. G1.4 adds common-coin/level/sequential plot unlocks in an
isolated local scene/save. Four initial plus four purchasable plots are a DEV
sample, not historical/final counts. Purchases require explicit confirmation;
when no productive resources remain, preserve enough coins for a starting seed.
Rules and costs are provisional in `data/farming/g14/land.json`. Prior gates and
XP rules stay intact. See `G14_TECHNICAL_REPORT.md` and imported historical audit.
G1.4 experience, final art/audio, physical mobile and online security remain
pending. No G1.5/G2, premium, social or animal production is authorized.

G1.3 addendum (2026-10-24, ADR-017): after functional G1.1/G1.2 acceptance,
the director authorizes a local development economy only. Independent scene/save:
buy seeds → plant/care → harvest to inventory/XP → deliberately sell → reinvest.
Prices, harvest XP, thresholds and existing-crop unlocks are editable provisional
data (`data/farming/g13/economy.json`). No XP for spending; no automatic sale in
the game. Local coin ledger/receipts persist atomically with inventory/progression.
No payments, premium, ads, expansion, animal production or social play. Previous
stop boundaries remain historical; this brief authorizes G1.3 only. Art/audio,
physical device and online security approval remain separate and pending.
See `G13_TECHNICAL_REPORT.md` and `G13_BALANCE.md`; await human G1.3 experience review.

Status: living document  

G1.2 addendum (2026-10-24, ADR-015): director validated G1.1 and authorizes care
only. Optional water benefit, bounded recoverable weed/pest delays, local fertilizer
stock/limits and contextual growth information. No crop death or yield destruction
for absence. Schemas/parameters are development hypotheses; Love/social/purchases
remain disabled. Details in `G12_TECHNICAL_REPORT.md` and `G12_BALANCE.md`.
Version: 0.1 — foundation

G1.1 development addendum, 2026-10-24 (ADR-014): director authorizes a local-only
development farming slice with three crops, timestamp growth, seed/product stock,
minimal harvest and persistence. This is not production offline authority or
permission for definitive economy/social/care. Provisional values and known art
debts: `G11_CONTENT_AND_ART.md`; boundaries: `G11_ARCHITECTURE.md`. Future online
rules below stay authoritative on the server. No coins/XP or monetization grants.

## 1. High concept
A modern social farming game built around the simple pleasure of planting and decorating, plus the mischievous social loop that made classic social farm games memorable: visiting friends, helping them, meddling with crops, attempting to steal a small portion of ripe produce, and defending your own farm with pets.

The game should be easy to understand in under two minutes, but support months or years of collection, customization, social rivalry and seasonal content.

## 2. Player fantasy
“I own a farm that feels uniquely mine. It keeps living while I am away. I come back to satisfying progress, new things to collect, and stories created by what my friends did while I was gone.”

## 3. Core pillars
### Grow
Plant, care for, harvest, sell and reinvest.

### Express
Decorate the farm, change scenery/theme, collect animals, buildings, pets and cosmetics.

### Visit
Enter friends’ farms, inspect their progress, help them or create harmless trouble.

### Protect
Use pets and farm defenses to deter theft/mischief.

### Progress
Gain XP, unlock land, crops, animals, production systems, cosmetics and prestige.

### Return
Real-world timers create anticipation. Notifications and activity history provide reasons to return without punishing players harshly.

## 4. Primary game loop
1. Choose crop/production.
2. Spend coins/resources.
3. Plant/place/feed.
4. Wait in real time while growth/production advances.
5. Perform optional care actions.
6. Harvest/collect.
7. Sell, fulfill orders or use ingredients elsewhere.
8. Earn coins/XP/collections.
9. Unlock new land/content.
10. Visit friends while waiting.
11. Reinvest and customize.

## 5. Farm plot system
Each plot has a state machine:
- locked;
- empty;
- prepared;
- planted;
- growing;
- needs-water;
- nuisance/pest;
- mature;
- harvested/cleared.

Growth is computed from authoritative timestamps rather than a continuously running client timer.

Plots should visually evolve through multiple crop growth stages.

## 6. Crops
Each crop definition includes:
- id;
- display name;
- seed price;
- base growth time;
- growth stages;
- sell value;
- XP;
- unlock level;
- care profile;
- rarity;
- seasonal availability;
- theft rules;
- tags;
- art references;
- sound/VFX hooks.

Early crops are fast to establish rhythm. Later crops create planning decisions with longer timers and better margins.

## 7. Care and nuisances
Classic-inspired actions:
- watering;
- removing weeds;
- removing pests;
- fertilizing;
- optional friend-help actions;
- friend-inflicted nuisance with caps and safeguards.

Neglect should reduce efficiency/reward modestly, not permanently destroy expensive progression.

## 8. Harvest and theft
A mature crop can be harvested by its owner.

Visitors may attempt to steal a deliberately limited fraction of eligible mature produce. The system must prevent griefing:
- protected minimum remains for owner;
- per-visitor limits;
- per-farm/day limits;
- cooldowns;
- no theft from tutorial/new players;
- high-value special items may be protected;
- visible activity log;
- reputation/social consequences;
- defensive pet interactions.

Stealing should create stories, not rage quits.

## 9. Pets / farm guardians
Pets are both collectible companions and social-defense mechanics.

Guardian state:
- pet owned;
- pet placed/assigned;
- hunger/energy or care state;
- defense capability;
- cooldown;
- cosmetic skin;
- bond level.

When a visitor attempts theft, the server resolves whether the guardian reacts. A successful defense can:
- block some/all stolen amount;
- trigger a humorous bite/chase animation;
- reward the owner with a small bounty or reputation;
- log the incident.

Pets must never become a hard paywall for basic protection.

## 10. Friends and visits
Players can:
- add/follow friends;
- see friends with harvest-ready indicators;
- visit farms;
- like/react;
- water/help;
- remove pests;
- leave a small nuisance if rules allow;
- attempt theft;
- view activity;
- send limited gifts;
- compare selected milestones.

Visits are asynchronous snapshots backed by authoritative server state.

## 11. Land expansion
Farm starts compact.

New areas unlock through combinations of:
- level;
- coins;
- achievement stars;
- quests;
- long-term progression.

Expansion must feel substantial: more plots, new visual zones, production buildings or decoration space.

## 12. Animals
Two broad groups:

### Production animals
Examples: chicken, cow, sheep, bee, duck.
They require feed/care and produce collectable goods on timers.

### Growth/collection animals
Animals that mature, generate periodic value, collection progress or cosmetic prestige.

Animal systems should be data-driven like crops.

## 13. Buildings and processing — modern expansion
A new system beyond the original inspiration:
- mill;
- bakery;
- dairy;
- preserve kitchen;
- loom;
- workshop.

These convert raw farm goods into higher-value products and create deeper planning without replacing the simplicity of farming.

Processing queues are intentionally small to avoid spreadsheet fatigue.

## 14. Orders / market board — modern expansion
NPC/community orders request farm goods.

Benefits:
- alternate use for harvested goods;
- directed goals;
- rotating reasons to plant different crops;
- XP/reputation/cosmetic token rewards.

Order difficulty scales with account progression.

## 15. Neighborhoods / clubs — post-MVP
Small social groups can:
- contribute to cooperative goals;
- unlock community decorations;
- compete in friendly seasonal boards;
- visit a shared visual space.

Do not build this before the core friend-visit loop proves fun.

## 16. Farm customization
Customization categories:
- ground/scenery themes;
- farmhouse skins;
- fences;
- paths;
- water features;
- trees/flowers;
- animated decorations;
- pet houses;
- seasonal sets;
- prestige trophies.

The farm layout should support placement, movement, rotation where art permits, and storage.

## 17. Scenario/theme skins
Whole-farm themes are high-value progression/cosmetic rewards.

Examples:
- classic countryside;
- spring blossom;
- tropical;
- autumn harvest;
- winter lights;
- enchanted farm;
- Japanese garden;
- Brazilian countryside;
- lunar/festival themes.

Themes change ground palette, borders, ambient props, sky/background and potentially music/ambient audio without altering gameplay balance.

## 18. Economy
Currencies at launch:
- Coins: standard gameplay currency.
- Premium currency: cosmetic/convenience oriented.
- Event tokens: temporary seasonal currency where needed.

Core rules:
- every currency has defined sources and sinks;
- no premium-only crop advantage that destabilizes economy;
- speedups may exist but should not make non-paying players socially irrelevant;
- cosmetics, themes, storage convenience and optional pass content are preferred monetization surfaces.

## 19. Progression
XP sources:
- harvesting;
- animal collection;
- orders;
- first-time collection;
- helping friends;
- quests;
- achievements.

Unlocks should arrive frequently early and gradually stretch later.

## 20. Collections and mastery — modern expansion
Every crop, animal and crafted product has mastery tiers.

Mastery can unlock:
- decorative variants;
- profile badges;
- small QoL bonuses;
- alternate crop visuals;
- encyclopedia completion.

This creates long-term goals without infinite raw power creep.

## 21. Quests
Three layers:
- onboarding quests;
- daily/weekly objectives;
- long-form achievement chains.

Quests should encourage varied play rather than demand tedious repetition.

## 22. Seasonal events
Seasonal content can include:
- limited crop;
- themed animal;
- decorations;
- community meter;
- event orders;
- story vignettes;
- cosmetic rewards.

Avoid FOMO-heavy designs that make a missed week permanently harmful.

## 23. Activity feed
The farm keeps a readable history:
- who watered;
- who removed pests;
- who stole;
- who was stopped by a guardian;
- who sent a gift;
- major milestones.

This is a key social storytelling surface.

## 24. Reputation / social karma — modernized replacement for crude popularity loss
Helpful actions raise goodwill.
Aggressive/mischief actions may temporarily lower goodwill.

Reputation affects light social signals, achievements and cosmetics, not core power.

## 25. Onboarding
First session target:
- plant first crop in <60 seconds;
- first harvest in ~2–3 minutes;
- first level-up in same session;
- first land/unlock preview;
- first simulated or real social visit;
- explain “your farm keeps growing while you are away.”

## 26. Session design
Short session: 2–5 minutes.
Normal session: 10–20 minutes.
Long decorating/planning session: 30+ minutes.

There must always be something useful to do while long crops grow, but never a requirement to remain online.

## 27. UX principles
- one-tap/two-click common actions;
- batch actions unlock later as QoL;
- clear timer/status on hover/tap;
- no tiny hit targets;
- no modal spam;
- readable economy consequences before confirmation;
- undo for decoration placement where possible;
- satisfying harvest feedback.

## 28. Art direction
Pixel art with modern polish:
- coherent tile scale;
- strong silhouettes;
- warm, vivid palette;
- readable crop stages;
- restrained particle effects;
- subtle idle animation everywhere;
- clear separation between interactable and decorative items.

Purchased/free asset packs are ingredients, not automatic final art. Mismatched styles should be recolored/redrawn/replaced.

## 29. Audio
Layers:
- calm adaptive farm music;
- soft ambience;
- strong tactile SFX for plant/water/harvest/coin/level-up;
- pet reactions;
- subtle UI sounds.

Audio should make repeated actions pleasurable.

## 30. Initial content target for first public beta
Indicative, subject to balancing:
- 24+ crops;
- 8+ production animals;
- 4+ guardian pets;
- 6+ processing buildings;
- 120+ decorations;
- 4 farm themes;
- 30+ levels with meaningful unlocks;
- 60+ achievements;
- daily/weekly quest pool;
- friend visits and complete social activity log.

## 31. Explicitly out of scope for MVP
- synchronous co-op farming;
- open chat;
- trading economy between players;
- player marketplace;
- PvP combat;
- guild wars;
- complex character walking simulation.

## 32. Success criteria
The project is succeeding when:
- planting/harvesting is satisfying even with no rewards;
- testers naturally decorate without being told;
- testers return because a crop/animal/event is ready;
- social logs produce playful reactions;
- theft feels funny/risky, not unfair;
- new players understand the loop without external instructions;
- the codebase allows new crops/items/events mostly through content data rather than bespoke code.
