# Live Operations and Seasonal Event System

## Core promise
The farm is a living service: evolving content, rotating goals, friendly surprises, and seasonal celebrations without exhausting players or requiring constant client updates.

## Cadence hypothesis
- Weekly: small rotating objectives and cosmetic shop assortment.
- Monthly: one themed event or event chapter.
- Quarterly: more substantial update/new decorative set or system extension.
- Annual: returning seasonal events with fresh twists.
Cadence must adjust to production capacity and actual player data.

## Event definition (data-driven)
event_id, schema_version, starts_at, ends_at, eligibility, objectives, reward_track, currencies, crop_variants, visual_theme, audio_cues, shop_offers, claim_deadline, localization, safety_fallback.

Backend enforces windows/eligibility/claims/limits. Remote config switches events on/off. Client supports generic event screens and already-downloaded art; entirely new assets may require app updates.

## Example: Haunted Harvest
All eligible accounts get 1 cursed pumpkin seed once, idempotently.
- Multiple growth stages.
- Mature pumpkin has blinking glowing face and ambient sparkles.
- Harvest yields special seasonal tokens and optional cosmetic collection progress.
- Friendly seasonal missions grant spooky fences, scarecrows, pet costume and seasonal farm ambience.
- Owners retain protected yields under theft rules.
- Players who miss the event can later access equivalent gameplay capability; cosmetic reruns and archive rotation are transparent.

## Design rules
- Events are rewarding but optional.
- Meaningful free track.
- Purchases never buy exclusive gameplay dominance.
- No deliberately punitive resets.
- Duplicate claim and replay protections.
- Event rewards/claims handled transactionally.
- Reproducible audit trail for grants.
- Server timestamps define opening/closing.
- Event content is tested on staging before live activation.

## Content workflow
Brief -> design spec -> balance sheet -> asset checklist -> implementation/config -> QA sandbox -> accessibility/performance review -> staging -> launch -> telemetry -> postmortem.

## Data-driven tuning
Versioned remote config can adjust:
- crop duration;
- price and reward parameters;
- event token earn rates;
- caps and cooldowns;
- unlock thresholds;
- distribution weights.
Any live balance changes must preserve player trust, avoid stealth nerfs, and have rollback plans.

## Live Ops dashboard
Daily active users, return retention D1/D7/D30, session duration, crash rate, first session completion, event participation, objective completion, free-track completion, event token balance, economy inflation, purchase conversion, purchase refunds, suspicious grants, player complaints.

## Event UX
Farm visibly reflects active theme; optional event modal after a meaningful moment, never popup spam. One-tap event hub; clear schedule and reward explanation; distinct sounds and animation for rare rewards, without excessive fanfare.
