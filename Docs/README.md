# Docs

## Import API spec

The import should be a list of items, where each item is separated by `---`. The import should be valid `yaml`.

### Type

The item type. Can only be `RAID_ASSIGNMENTS`.

### Encounter

The encounter ID.

See https://wowpedia.fandom.com/wiki/DungeonEncounterID.

### Triggers

Assignment triggers. Can be of types `UNIT_HEALTH`, `SPELL_CAST`, `SPELL_AURA`, `RAID_BOSS_EMOTE`, `ENCOUNTER_START` or `FOJJI_NUMEN_TIMER`.

#### UNIT_HEALTH

```yaml
triggers:
- type: UNIT_HEALTH
  unit: boss1
  percentage: 20
```

#### SPELL_AURA

```yaml
triggers:
- type: SPELL_AURA
  spell_id: 12345
```

#### SPELL_CAST

```yaml
triggers:
- type: SPELL_CAST
  spell_id: 12345
```

#### RAID_BOSS_EMOTE

```yaml
triggers:
- type: RAID_BOSS_EMOTE
  text: "The air crackles with energy!"
```

#### ENCOUNTER_START

```yaml
triggers:
- type: ENCOUNTER_START
```

#### FOJJI_NUMEN_TIMER

```yaml
triggers:
- type: FOJJI_NUMEN_TIMER
  key: HALFUS_PROTOBREATH
```

### Untriggers

Same as triggers. This field is optional and really only useful if you created triggers with a delay, and you want to cancel those triggers.

### Countdown and Delay

For most triggers, `countdown` and `delay` fields can also be set. The `countdown` value controls the countdown timer in the raid assignments popup. `delay` controls how long a raid notifications will be delayed for after triggering.

Both countdown and delay sort of serve a similar purpose and it's mostly a matter of if you want to show the window with a countdown timer or just delay it. Countdown makes sense for small values while delay makes sense for longer timer periods.

### Assignments

The list of assignments for this trigger. Can only be of type `SPELL`.

Assignments is priority list and not a sequence. This means that the addon will always suggest the top assignment value in the list where all spells are ready.

### Example Import

```yaml
type: RAID_ASSIGNMENTS
encounter: 1024
trigger: { type: UNIT_HEALTH, unit: boss1, percentage: 35 }
metadata: { name: "Boss 25%" }
strategy: { type: CHAIN }
assignments:
- [{ type: SPELL, player: Anticipâte, spell_id: 31821 }]
- [{ type: SPELL, player: Kondec, spell_id: 62618 }]
- [{ type: SPELL, player: Venmir, spell_id: 98008 }]
---
type: RAID_ASSIGNMENTS
encounter: 1027
trigger: { type: SPELL_CAST, spell_id: 91849 }
metadata: { name: "Grip of Death" }
strategy: { type: BEST_MATCH }
assignments:
- [{ type: SPELL, player: Riphyrra, spell_id: 77764 }]
- [{ type: SPELL, player: Jamón, spell_id: 77764 }]
- [{ type: SPELL, player: Clutex, spell_id: 77764 }]
- [{ type: SPELL, player: Crawlern, spell_id: 77764 }]
---
type: RAID_ASSIGNMENTS
encounter: 1022
trigger: { type: FOJJI_NUMEN_TIMER, key: ATRAMEDES_SEARING_FLAME, duration: 7 }
metadata: { name: Flames }
strategy: { type: BEST_MATCH }
assignments: 
- [{ type: SPELL, player: Sîf, spell_id: 97462 }, { type: SPELL, player: Anticipâte, spell_id: 31821 }]
- [{ type: SPELL, player: Solfernus, spell_id: 51052 }, { type: SPELL, player: Kondec, spell_id: 62618 }]
---
type: RAID_ASSIGNMENTS
encounter: 1026
trigger: { type: RAID_BOSS_EMOTE, text: "The air crackles with electricity!", countdown: 5, duration: 10 }
metadata: { name: "Crackle" }
strategy: { type: BEST_MATCH }
assignments:
- [{ type: SPELL, player: Anticipâte, spell_id: 31821 }, { type: SPELL, player: Kondec, spell_id: 62618 }]
- [{ type: SPELL, player: Managobrr, spell_id: 64843 }, { type: SPELL, player: Venmir, spell_id: 98008 }]
```
