# MOBA Bots v48 — Notas de Atualização

Melhorias feitas para deixar os bots no nível de um jogo de verdade.
Arquivos alterados: `lib/moba_bot_ai.lua`, `lib/moba_ai_core.lua`, `lib/moba_config.lua`,
`creaturescripts/scripts/moba_combat.lua`, `moba_bot_death.lua`, `moba_nexus_death.lua`
+ 4 novos scripts de globalevent.

---

## 1. Bugs críticos corrigidos

| Bug | O que era | O que virou |
|---|---|---|
| `SPELL_CD_GLOBAL = 1,0` | Typo no config (virava `1` + entrada `0` na tabela) | `1.0` |
| Dano dobrado de minions/torres | `executeAttack` aplicava `addHealth(-dmg)` **e** `doTargetCombatHealth(-dmg)` | Aplica **uma vez** (via combat, que dispara o evento de dano). Valores de dano compensados no `MINIONS_CONFIG` |
| Bots nunca reagiam a dano | `onBotHealthChange` nunca era chamado (o XML mapeia `MobaHealthChange` → `moba_combat.lua`), então `isUnderAttack()` era sempre `false` | `moba_combat.lua` agora chama `MOBA_BOTS.handleBotDamage` (fuga/recall/torre funcionam de verdade) |
| Funções inexistentes | `onTowerDestroyed`, `syncTowerState`, `TowerState`, `getTeamPlayers`, `initPlayerStats` eram chamadas mas não existiam → erro de runtime no placar/torres | Todas implementadas |
| Mana infinita | Magias custavam mana no config mas nada gastava/regenerava; poções de mana nunca eram usadas | Sistema de mana completo (gasto, regen, poções, mana no level up) |
| Debuff "faz de conta" | `utori vis` só mostrava efeito visual | Lentidão **real** (`MOBA_BOTS.applySlow`) — reduz speed com `changeSpeed` + timer, restaura no fim; em players usa condição de paralisia |
| Buff de velocidade inútil | `utito tempo` dava `bonusSpeed` só no dado interno | Aplica `changeSpeed` real no creature e reverte ao expirar |
| Wave nunca spawnava | `globalevents.xml` referenciava `moba_waves.lua` mas o arquivo não existia | Criado `moba_waves.lua` (+ `moba_base.lua`, `moba_skull_keeper.lua`, `moba_scoreboard_update.lua`) |

## 2. Classes e magias

**Knight (tanque)**
- `exeta res` (lvl 12): **taunt** — provoca inimigos próximos a atacá-lo (novo tipo de magia)
- `exori gran mas` (lvl 35, ult): AOE 160-240
- Stats: HP 720, atk 40, atkSpeed 1.4

**Paladin (atirador)**
- `exura san` (lvl 10): auto-heal
- `utani hur` (lvl 15): haste
- `exevo gran mas san` (lvl 35, ult): AOE santo 140-220
- `utito tempo san` agora aumenta o **range efetivo** (+2)

**Sorcerer (mago)**
- `utani tempo hur` (lvl 14): haste
- `exori gran vis` (lvl 22): nuke de energia 95-140
- `exevo gran mas vis` agora é a ult (marcada `ultimate = true`)
- `utori vis` agora lentidão real de 25%

**Druid (suporte)**
- `utani tempo hur` (lvl 14): haste
- `exevo gran mas tera` (lvl 35, ult): AOE de terra 135-215
- Prioridade de cura reorganizada (heal_ally > heal_self > heal_area)

**Sistema de magia geral**
- Magias de área (`absolute`/`wave`) **só são lançadas se houver inimigo na área** (não desperdiçam mana)
- Mana é gasta de verdade e checada antes de conjurar
- Dano de magia registra o golpe fatal (`FatalKillers`) e o dano nos bots (eles reagem)
- `canCastSpell` respeita level, cooldown, cooldown global e mana

## 3. Comportamento e prioridades

- **Seleção de alvo por pontuação** no combate principal (herói focado > last hit > minion > torre), em vez de prioridade fixa
- **Focus fire coordenado**: quando um bot ataca um herói, o time inteiro recebe o alvo (`TeamFocus` broadcast) — lutas de equipe bem mais intensas
- **Orb-walking**: ranged atacam em movimento, afastam após o hit e se reposicionam
- **Push/freeze de lane**: wave aliada maior → empurra; senão segura posição atrás da frontline fazendo last hit
- **Recuo inteligente**: foge para trás da torre aliada / da wave em vez de só andar pelos waypoints
- **Torres com aggro**: a torre lembra quem a atacou por último e prioriza esse alvo (dive/retirada fazem sentido)
- **Defesa de torre**: bots defendem também contra **herói** sitiando a torre (não só contra minions)
- **Agressividade aprendida** afeta `all-in` e `engage`

## 4. Auto-aprendizado (novo)

`MOBA_BOTS.Learning` (persistido em `data/moba_learning.json`):
- Registra o resultado de cada partida por **classe** (winrate, V/D)
- Classes com winrate baixo recebem **buff leve** (dano/HP); classes dominantes recebem nerf
- **Rubber band**: o time perdedor ganha mais ouro/xp em kills (até 1.4x)
- Ver histórico: `MOBA_BOTS.learningStatus()`
- Desligar: `MOBA_BOTS.Learning.enabled = false`

## 5. Comandos de debug

- `MOBA_BOTS.debugBot(id)` — agora mostra mana e ajustes de aprendizado
- `MOBA_BOTS.learningStatus()` — winrates e ajustes por classe
- `MOBA_BOTS.debugAllBots()`, `MOBA_BOTS.debugEnvironment(id)`, `MOBA_BOTS.setDebug(true)`

## 6. Como sintonizar (equilíbrio)

Tudo é configurável em `MOBA_BOTS.CONFIG`:
- `ATTACK_CD` (velocidade global) e `atkSpeed` por classe
- `HP_*`, `USE_HP_POT_THRESHOLD`, `USE_MANA_POT_THRESHOLD`
- `ALL_IN_CHANCE`, `ALL_IN_ENEMY_HP_THRESHOLD`
- `HERO_KILL_GOLD`, `MINION_GOLD`, `TOWER_KILL_GOLD`
- Danos das magias: edite `MOBA_BOTS.CLASSES[<classe>].spells`
- Danos de minions/torres: `MOBA.MINIONS_CONFIG` e o `config` em `MOBA.startMatch`
