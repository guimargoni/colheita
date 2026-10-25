# Technical Architecture

## 1. Chosen stack

### Client
- Godot 4.x stable
- GDScript
- 2D pixel-art renderer
- Responsive UI supporting mouse/keyboard and touch

### Backend
- Supabase
  - Postgres for authoritative persistent state
  - Auth for identity
  - Edge Functions for authenticated commands/integrations
  - Postgres functions/transactions for data-intensive atomic mutations
  - Storage for user-generated/support assets if needed
  - Realtime selectively for friend/activity updates, not as a dependency for basic farming

### Delivery
- GitHub repository
- GitHub Actions for tests/build validation
- Steam for PC candidate launch
- Android candidate launch in parallel/after PC usability is proven
- iOS later in the same codebase

## 2. Why Godot + GDScript
The project is primarily 2D, UI-heavy, timer/data-driven and cross-platform.

GDScript minimizes tooling friction and preserves the broadest Godot export options. Platform integrations should be isolated behind adapters.

## 3. Architecture principle: async-social, server-authoritative economy
This is not a realtime MMO.

Most player interactions are asynchronous:
- crop timers;
- animal timers;
- production queues;
- visits;
- theft/help;
- orders;
- activity feed.

That means we can get robust online behavior without running an expensive dedicated game server for every player.

The server is authoritative for anything valuable:
- currencies;
- inventory;
- XP/levels;
- plot ownership/state;
- crop timestamps;
- harvest quantities;
- purchases;
- item grants;
- theft;
- pet defense;
- quest rewards;
- event progress.

## 4. Client layers

### Presentation
Scenes, UI widgets, animation and sound.

### View models/controllers
Translate domain state into screen state and user intents.

### Domain
Pure or mostly-pure logic for:
- timer display;
- local prediction;
- content definitions;
- selection rules;
- formatting;
- non-authoritative previews.

### Services
- AuthService
- FarmService
- InventoryService
- SocialService
- EconomyService
- ContentService
- NotificationService
- AnalyticsService

### Network/API
One gateway encapsulates HTTP/auth/retry/version handling.

## 5. Suggested Godot structure

```
game/
  project.godot
  autoload/
  scenes/
    boot/
    farm/
    social/
    shop/
    inventory/
    profile/
    settings/
  scripts/
    domain/
    services/
    api/
    ui/
    utils/
  data/
    crops/
    animals/
    items/
    levels/
    quests/
  assets/
    art/
    audio/
    fonts/
  tests/
backend/
  supabase/
    migrations/
    functions/
    seed/
docs/
tools/
```

## 6. Content data
Content should have stable IDs and versioned schemas.

Examples:
`crop.carrot`
`animal.cow`
`guardian.dog_brown`
`theme.spring`
`deco.fence_wood_01`

Balance data can initially live in version-controlled JSON/Resources and later be mirrored/published to backend content tables for live operations.

## 7. Core database model — first pass

### Identity/social
- profiles
- friendships
- follows/block list
- player_settings

### Farm
- farms
- farm_plots
- farm_objects
- land_unlocks
- farm_themes

### Economy
- wallets
- inventory_stacks
- inventory_instances
- economy_ledger

### Timed production
- crop_cycles
- animal_instances
- animal_cycles
- production_buildings
- production_jobs

### Social interaction
- farm_visits
- social_actions
- theft_attempts
- guardian_events
- activity_feed

### Progress
- player_progress
- achievements
- player_achievements
- quests
- player_quests
- collections

### Live ops
- events
- event_progress
- offers
- inbox_rewards

## 8. Economy ledger
Every meaningful currency mutation should be auditable.

Ledger row:
- transaction id;
- player id;
- currency;
- amount delta;
- balance after;
- reason code;
- source entity;
- command/request id;
- timestamp.

This is essential for debugging, support and anti-cheat.

## 9. Command pattern
Client sends intents, not final results.

Bad:
`POST /harvest { coins: 9000, xp: 300 }`

Good:
`POST /farm/harvest { plot_id: "..." }`

Server:
1. authenticates caller;
2. loads plot/crop/content rule;
3. compares authoritative server time;
4. verifies ownership and state;
5. computes yield;
6. applies social theft/care modifiers;
7. grants inventory/XP atomically;
8. clears/updates plot;
9. writes ledger/activity;
10. returns authoritative result.

## 10. Idempotency
Every mutation command should carry/request an idempotency key.

If a mobile client retries due to connection loss, harvesting/purchases/rewards must not duplicate.

## 11. Time
Never trust device clock for rewards.

Store:
- planted_at;
- ready_at;
- last_collected_at;
- production_started_at;
- production_ready_at;
- pet_fed_until;
- cooldown_until.

Client can render countdowns locally after syncing server time offset.

## 12. Theft resolution
Theft must execute inside a transaction.

Server checks:
- crop is mature and stealable;
- owner/visitor are different;
- relationship/block rules;
- visitor cooldown;
- crop remaining protected amount;
- daily farm theft cap;
- guardian state;
- random roll generated server-side if randomness is used.

The output logs both visitor and owner-facing events.

## 13. Security
- RLS enabled on exposed tables.
- Economy tables not directly writable by ordinary clients.
- Service secrets never shipped in game.
- Edge Functions validate authenticated identity.
- Rate-limit abuse-prone commands.
- Server validates every item/content id.
- Server checks numeric bounds.
- Maintain block/report system before broad public launch.
- No open text chat in MVP.

## 14. Offline behavior
The game is online-first because social/economy integrity is central.

Allow graceful temporary offline UX:
- cached farm display;
- cached catalog;
- decoration planning if safely reconcilable;
- clear “reconnect to commit” state.

Do not permit offline authoritative harvesting/purchasing/theft.

## 15. Save model
Server state is the canonical save.

Local storage contains:
- auth/session token through platform-safe storage;
- graphics/audio/control settings;
- cached content;
- transient UI preferences;
- last-known farm snapshot.

## 16. Platform abstraction
Adapters:
- IPlatformAuth
- IPlatformAchievements
- IPlatformCloud
- IPlatformNotifications
- IPlatformPayments
- IPlatformFriends

Implement no platform SDK directly in farm domain code.

## 17. Analytics
Track product questions, not vanity noise.

Examples:
- tutorial_step_completed;
- crop_planted;
- crop_harvested;
- crop_wither/care state if applicable;
- land_unlocked;
- friend_visited;
- help_given;
- theft_attempted;
- theft_succeeded;
- guardian_triggered;
- decoration_placed;
- session_return_reason;
- store_viewed/purchase_completed.

## 18. Testing
### Unit
- crop readiness math;
- yield math;
- XP thresholds;
- price calculations;
- theft caps;
- guardian rules.

### Backend integration
- double-harvest prevented;
- duplicate request idempotency;
- unauthorized mutation denied;
- simultaneous theft/owner harvest consistency;
- economy ledger conservation.

### Game smoke
Automated boot + core scene load where feasible.

### Human creative QA
Every milestone ships with a checklist the creative director can execute without reading code.

## 19. CI
On pull request:
- formatting/lint where available;
- GDScript static checks;
- unit tests;
- database migration validation;
- backend tests;
- asset metadata validation;
- forbidden-secret scan.

## 20. Environments
- local;
- dev/shared;
- staging;
- production.

Never test economy changes directly in production.

## 21. Scalability
Start simple.

Postgres is appropriate for asynchronous farm state and transactional economy. Optimize only after profiling:
- indexes on owner/player/state timestamps;
- materialized/derived friend feed where needed;
- pagination everywhere;
- event/archive policies;
- scheduled jobs only when state cannot be computed lazily.

Prefer computing elapsed timer state on access instead of updating every crop every second.

## 22. Key architectural rule
A million growing crops must not mean a million ticking server jobs.

Store timestamps and derive state when queried or acted upon.
