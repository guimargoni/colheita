# Farm Progression: Production and Unlocks

Status: creative-direction working proposal.

## Design intent
Not a literal replica of the original Orkut game. Preserve the strengths of compact farming, social presence, meaningful individual plots, timed production, care and discovery, and expand them with modern systems. Desktop and touch devices have equal first-class UX consideration.

## Unlock ladder (illustrative, not final levels)
1. Seeds/plots/harvest, first land unlock.
2. Chicken coop: feed chicken, collect eggs on timed cycles, capacity/storage, playful animations.
3. Apiary: place beehive, bees animate, harvest honey, optional flowers nearby offer small bounded synergy.
4. Cow pasture: feed/care, milk production.
5. Sheep enclosure: wool production.
6. Processing: wheat into flour; eggs/flour into bakery recipes; milk into cheese; honey into seasonal recipes.
7. Advanced collection/mastery, rare visual variants, seasonal limited production.

## Production animal framework
Each producer has:
- unlock rule, purchase/build cost, capacity, upkeep/feed needs;
- server-based production timer and output stock cap;
- visual idle, active, ready and harvest feedback;
- optional care/health morale system with forgiveness;
- item definitions and downstream recipe uses;
- interactions with quests, achievements, social help and events.

## Chicken design sketch
Coop can hold a limited number of chickens; feed starts/maintains an egg cycle; player collects eggs when ready. Eggs can be sold, consumed for orders or processing. Introduce clearly with short tutorial.

## Honey design sketch
Beehives produce honey over longer cycles. Nearby decorative/functional flowers can contribute an understandable, capped bonus, never mandatory pay-only. Bees visibly fly; ripe honey has an appealing collection animation. Seasonal flowers/honey variants provide cosmetic/collection depth.

## Balance guardrails
- Timers designed for daily routines, not constant alarms.
- Producers must not obsolete crops.
- Each production branch offers trade-offs and distinct rewards, not just a strictly superior money machine.
- Manage resource sinks so neither currency nor inventory inflates unboundedly.
- Care should be rewarding but avoid punishing players who miss a day.
- Balance data is editable/versioned and testable.
- Free players can obtain essential production animals and recipes.

## UX and art
Compact, curated farm composition; high visual significance of each plot and producer; visibly different maturity/ready states; responsive interaction for both desktop and mobile; optional batch collect once unlocked. Avoid hundreds of tiny plots or microtargets.

## Confirmation gate
G0.3 should test an oblique/isometric-like presentation against the actual licensed asset base before finalizing tile projection. Product gameplay requirements should not be compromised by an incompatible free asset pack.
