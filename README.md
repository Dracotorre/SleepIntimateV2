# SleepIntimate

Name: Sleep Intimate
Author: DracoTorre
Source: https://www.nexusmods.com/fallout4/mods/35637
Homepage: https://www.dracotorre.com/mods/sleepintimate/

Description

=======================

an immersive sleep and romance mod for Fallout 4 

The goal of Sleep Intimate is to change game-play for more immersive, role-playing experience with sleep and romance. Watch your character sleep, interrupt sleep to continue later, and risk interruption by storms. The normal romantic companion bonus is now considered like a snuggle-bonus, but to get more intimate use intimacy skills. Successful persuasion results in pre-bed animated scene earning a new bonus. Intimate scenes are silly dances plus your imagination and may be disabled if just looking for a new sleep experience.

How to sleep: activate 'Rest' for immersive rest or 'Sleep' for normal game sleep.

Create holotape [Settings] Sleep Intimate at chem station to adjust preferences. MCM includes basic preferences only.

Sort dialogue overhauls after SleepIntimate.esp.

For a full list of features and instructions, see the webpage: https://www.dracotorre.com/mods/sleepintimate/

=======================
Credits and tools used
======================
Leito for sharing “Enhanced Vanilla Bodies” (EVB) and “FO4 Animations by Leito”

ousnius for “Material Editor” tool
Niftools NifSkope
zilav et al for FO4Edit
steve40 and Flipdeezy for holotape naming pattern - wanted to be consistent
Creation Kit

=======================
Permissions
=======================
See the Nexus page 'permissions and credits' section for details.

No part of this mod, including patches for this mod, may be used for commercial, monetizing, or donation-taking projects. As per Leito’s permissions, Leito’s content (includes body files found within main archive) not allowed on Bethesda.net, or to be used for donation-taking projects or commercial mods or projects. Instead of distributing file, please refer others to https://www.nexusmods.com/fallout4/mods/35637/.

You may create and distribute patches, including language patch, by requiring original plugin. Patches should not circumvent restrictions, alter preferences player expects, or introduce content that would not comply with Bethesda.net rules for distribution on Bethesda.net, or any other non-age-restricted site.


==========================
Changes 2.06
==========================
* animation SavageCabbage desk/table doggy-style adjusted away as it was too close on some tables

Changes 2.05
==========================
* AAF now uses morphs which requires additional files and LooksMenu (no EVB male nude-suit, EVB Best-Fit setting not used)
* changed EVB Best-Fit to default off, if have all 3 body meshes then may use EVB Best-Fit (All), else if only 1 body then choose (Basic)
* removed Dogmeat scenes and quest
* removed EVB male assets, removed nude-suit armors supporting Unique Followers


Changes 2.02
==========================
* added missing embrace animation files

Changes 2.00
==========================
* XOXO: no longer supports "Atomic Lust" (or any pack) since hug and kiss now included
* XOXO: BA2 file same assets as XB1 - no super-mutant body replacer, no EVB bodies, no Unique Player/Follower content, fewer and alternate scripts
* R-X: BA2 added male body textures for EVB for players without custom male body (loose files replace, or sort other body plugin below SleepIntimate.esp)

* Grand Harbor Hotel only bed has corpse on it, so now states that bed is occupied and after intimacy ignores tired go-to-sleep
* intimate scene height adjustment for SavageCabbage bed animations positioned on sleeping bag / mattress
* intimate Seat Scene id 754 position adjustment - too close on Memory Lounge chair animation clipping backside
* intimate "SavageCabbage" bed scenes adjusted for sleeping bag height adjustment to reduce clipping sleeping bag
* intimate scene Danse in power armor - added female solo scene from SavageCabbage pack on double-bed
* updater reviews custom extra-parts list to remove duplicate armors of new lists
* intimacy Danse in power armor skips STD chance check (we can imagine Danse removes his PA, but let's pretend he's had only one lover)

---mod support---
* SnapBeds - added missed pre-war double left-half to intimate bed list
* added patch for "Dating Magnolia" - loose script, DialogueGoodneightbor.pex, should overwrite file from "Dating Magnolia" and sort SleepIntimate_LNDatingPatch.esp after LNDating



Changes 1.98 (not released)
==========================
---new features---
* Seat Scenes: Relax sit considers undress preference to remove backpack, hat, outer-armors, jacket and redress on get up from chair
** embrace at seat provides Intimate Embrace perk +16 Sex Appeal and +1 Luck for limited time (8 hours) - may be stacked with Intimate Rested perk
** embrace at seat fail sets fail-time, but not fail-count, which reduces chance for next bed intimacy if within 3 hours
** embrace at seat or bed: player backpack set down near feet (optional with new setting)
* added Intimate Lover Ring - equip to limit lover with Intimate True Love quest to help locate lover
** Lover Ring companion seated or using workstation available (normal companions seated considered busy)
** ring uses ring body slot, but also includes alternate "Sh" ring using shield (59) slot for outfit compatibility
* Intimate Exhibitionist perk reward: put on a show for dozen or more NPCs - +2 Charisma, +1 Luck
* Intimate Active Day perk reward: 5 intimate encounters in same calendar day - +2 Endurance

---prompts and preference settings---
* new setting: Backpack Menu - Place on Ground - Bed and Chair (default), Bed, Disabled
* added prompt for 2nd-lover to join sex scene with chance adjustment for increased difficulty
* Intimacy Setting Go-to-Bed after intimacy (Immersive Rest only): Tired-only or Prompt/Disabled -- formerly a test setting, fade-end-scene

---changes---
* Sex Appeal: added player-level bonus for experiencing life, for every 2 levels +1 Sex Appeal until max +24 at level 48
* Sex Appeal: addiction correction - was subracting too much for 1 addiction
* Sex Appeal: sexy clothes (Red Dress, Agatha's, Tuxedo) improves in addition to item's Charisma bonus at a value less than sleep clothes
* intimacy beginner bonus: instead of bonus 8 hours after first fail, grants larger bonus immediately until first success
* intimacy prompt hours-since warning adjusts limit depending on Sex Appeal score - low score 7-hour reminder and high score 3-hour reminder
* intimacy check under hour since fail: no intimacy and remind player it's too soon
* intimacy chance now includes same-day count to make each same-day attempt more difficult - based on Endurance
* intimacy chance adjusted for Extra NPCs - improved by a few percent
* intimacy location score for finished Tour quest increased
* Undress Situational now considers rainy and stormy weather
* updated Quick Undress storage for smoother operation and handle updated undress system
* replaced Leito solo-scene for Danse in power armor with "Atomic Lust" solo (540, 541); default still dance for Danse
* Dogmeat wait-scene change: if Doghouse nearby will go there instead of wait at spot
* changed title of Rest/Sleep Settings to 'Rest and Undress Settings'
* embrace: reduced duration by 10 seconds for hug-only (hug-and-kiss remains at 30 seconds)
* outfit container: as backup check, restricts adding Pip-Boy to prevent player losing
* changed backpack placement to static so the dog cannot kick it around, and placed-at-once instead of drop-and-move
* rebuild AAF-play script for AAF API 78 beta
* EVB-Best-fit preference now available if any animation pack installed 
* several intimate prompts edited to change "Persuade" to "Attempt" (a few still "persuade" for variety) to avoid giving player impression all about persuasion
* restricted Dogmeat scenes from starting - if quest started may continue - due to issues with animating Dogmeat
* holotape correction: when Immersive Rest disabled, hide Companion Go-to-Bed and Rest Recovery preference settings
* Quick Sleep undress for bed winter rule changed to match Immersive Rest winter rule
* bed ownership - after choose only-my-side mark to stop bugging player for companion belonging to settlement
* performance tuning for companion undress and pre-prompt data gathering

---fixes---
* fix: on sleep, companion already sleeping will undress for bed (restored old feature affected by recent changes)--expected: companion to get up and back in bed
* fix: Danse in power armor check to consider gender preference and romance level (was always selecting power armor follower if no other follower present)
* fix: Rest quick-sleep Intimate Bed - check storage first for sleep outfit before player inventory
* fix: companion hat and necklace on swap and also player necklace on swap (order of operations fail--mistakenly cleared item)
* corrected for preference EVB-Best-Fit disabled replacing male-player body before AAF scene and restricting scene selection
* holotape mistakenly hid preference Twin/Double-Bed Owned for Test Mode

---mod support---
* recognizes combat armor from "We Are The Minutemen" 
* recognizes DX "Banshee" outfit as armor-all exception to avoid stripping off for outdoor camping sleep Situational-Undress preference

design notes:
   - for Relax activation on chair added function, IsFurnitureActuallyInUse(ObjectiveReference *), since in busy settlements many chairs may be flagged as in-use for settler approaching chair which becomes annoying. It checks if an actor is on (very close) to chair. This happens with bed on sleep-stop when game fails to move romantic companion to bed, so now use this function there as well. 


Changes 1.81 (not released)
==========================
---new features---
* updated standard animation controller - plays animations intended for AAF without AAF - may clone character depending on stand-in-place scene or furniture scene
* added hug and kiss paired animation idles created by TheRealRufgt from "Atomic Lust" available at chairs or bed
* hug-and-kiss before bed: if both player and companion character have sleep clothes, will change into sleep clothes else remove hats or jackets
* added Seat Scenes: seat (chair/sofa/stool) activation 'Relax' for hugs (mininum 35% chance) or dance and 'Relax+' identifies chairs with supported sex animations
* added chair option for Strong - if supported animations, pick-spot else female dance
* intimate scenes spectators: nearby companions or guards may approach and spectate (clap, headshake)
* intimate scenes at Diamond City (outdoors), Goodneighbor (outdoors), Vault 81 considered a crime - notification warns if caught and guards may attack (optiional - may disable crime violence)
* added 3-character scene support to intimate scene picker and player
* added FMM-animations from "SavageCabbages" pack and FMF-animation from "Atomic Lust" pack

---prompts/notifications and preference settings---
* added 'Exhibitionist!' notification for getting intimate near crowd
* new Intimacy Settings in holotape: Torture Device Scenes (hidden without mods)
* new Intimacy Settings Seated Scenes in holotape and MCM: enabled, enabled-hugs, enabled-sex, and disabled

---changes---
* updated undress system to support cloning character and future features
* updated undress system when player gets naked to block armors from auto-re-equip (such as Neiro's outfits that rescale armors on un-equip)
* companion affinity reactions limited to once per hour to reduce like/hate spamming for frequent intimacy
* added "Atomic Lust" 2.4.3a chair handjob scene
* Dogmeat scene: after 20 training sessions may get intimate with another companion nearby
* Dogmeat Scene: added player character voice reaction to Dogmeat quit early
* Dogmeat Scene: added animations from SavageCabbages pack
* hugs and kisses (AAF), clothed updated: no-fade; remove hats, gloves, coats; let characters walk
* Second Lover setting to include another nearby lover for sleep (was partially done since 1.50) or intimate scenes with supported animations
* removed chance to use nearby chair or sofa (on bed activation) since now can use chair or sofa directly
* after-intimacy go-to-bed: besides naked, now if in sleep clothing go straight to bed (based on scene positioning and not-AAF)
* increased maximum Sex Appeal with increased rate over 100 exp (number of scenes)
* Quick Sleep (Immersive Rest disabled): at sleep-stop if romanced companion fails to move into bed then player character put in bed

---fixes---
* after redress custom Pip-boy (Holoboy) refuse to replace regular Pip-boy -- fixed and updater corrects stuck condition
* custom Equipment lists (backpack, masks, parts, sleep clothes,...) now ignores Pip-boy equip - updater removes any existing Pip-boy from custom lists
* intimate scene now sets furniture flag to prevent NPCs from using it
* added hit-interruption to cancel intimate scene
* updated bed decoration placement to reduce bounce
* fix for companion undress for bed issues (no sleep outfit) after switching companions (incomplete data reset on switch)
* fix for partial missing notifications during location changes and Vault 111 disabled beds since v1.60
* scene position adjustments for double-bed - was too close to edge
* repeat scene check correction and optimized
* correction for playing mismatched female side of Leito's cowgirl-2 (was playing cowgirl-1)
* female-only intimate flag for TheKite's and Neiro's "The Handmaiden" outfit so a male may equip without crazy things happening if marked intimate-outfit for female
* non-infatuated/flirting companion select - double-check affinity value (romance-bug-reversed)
* correction for chance calculation after switch partners

---mod support---
* furniture recognized from mods: TortureDevices, Homemaker, cc-NukaCollector, cc-NeoSky, cc-bhouse
* added "ZaZOut4" animation pack - activate 'Get Intimate' on pillory to attempt intimate role-play
* recognizes "Hitchhiker's Robe" by al9984 as sleep clothes - re-scan gear
* recognizes "SED7 Body Piercing Conversion" by Bluto Blutarsky as jewelry in slot58 or slot55
* recognizes Holoboy "Holographic Pip-Boy 8000" by turetu as Pip-boy to prevent accidental add to custom lists or to re-equip on Scene Cancel

Notes:
   - updating from previous versions on first undress character will remove all gear to update undress system--this includes items not normally removed
   - Pick-a-Spot setting no longer needed - in prompt choose 'Pick a Scene' then 'Stand / Pick Spot'
   - after selected preference for chair sex (Relax+) and want hugs, toggle preference to 'Relax Hugs-only'
   - pillory and chair activation require active companion --- this means Healther Casdin only available with another companion following
   - torture devices (pillory) chance penalty bigger for persuading a character to enter contraption compared to player entering (5% difference)
   - chance at chair for sex may be lower than in same area bed due to lack of ownership bonus, but higher for hugs/dances
   - followers want to use chairs! --may say 'occupied' meaning NPC on the way--sneak forces followers to stop
   - default AAC standing scenes play using orbit-view, and furniture scenes play using a look-view
   - if in orbit-view the scene shakes too much, see Test Menu to force look-view
   - Dogmeat animation known issue: Dogmeat may perform packaged wait idles breaking the scene animation
   - Dogmeat scenes still restricted to custom player (not AAF)

Supported furniture Relax+ activation with "SavageCabbages" pack:
   - desks, pool table (activate chair first), small/medium tables (activate chair first)
   - kitchen chairs including Workshop DLC, stools, sofas, arm chair, bench, park bench, diner bench, steel bench
   - hydro-pillory from "TortureDevices"
   - make sure setting enabled for sex--'Seat Scene (Enabled-Sex)'--which only available if animation pack found
   - only seats or desks supported by animations will have Relax+ activator


Changes 1.63 (not released)
==========================
---changes---
* decreased chance for nearby child and jealous lover (about 8% overall)
* message fast-time-resume now adheres to notifications setting
---fixes---
* fix for necklace and choker fail to recognize until next armor equip
* fix for companion change into sleep clothes fail to remove gloves and extended body slot items
* AAF scenes male player correction: erection straight changed to up for animations set for up
---mod support---
* added "Atomic Lust" 2.4.2a cowgirl-double-bed, cowgirl-vault-bed, cowboy(MM), atomic rocket 69(MM)

Changes 1.62 (2019 March 22)
==========================
* alternate start mods: fixed holotape missing the 'Start Sleep Intimate' selection
* removed two-female scene added in 1.61
* added male-male scene that was left out of scene picker rewrite in 1.50
* increased after-intimacy chance penalty by 20%, because my character was getting lucky one-after another too frequently (fair to offset increased bonuses).


Changes 1.61 (2019 March 18)
==========================
* intimate solo-scene for Danse -- without X_Anims just a dance
* intimate scene added for two females without strap-on using double-bed or two nearby beds - requires X_Anims
* increased delay for companion-busy warnings to make easier to read
* fixed backpack compensation for case Intimate Bed on Immersive Rest changing into stored sleep clothing
* check Extra NPC for affinity value when companion following -- was only checking affinity for nearby (not following)
* Immersive Rest if over-encumbered will not start fast-time to avoid kick-out interuption timing causing stuck screen effect
* fix for companion's intimate outfit removed for scene


Changes 1.60 (2019 March 16)
==========================
1.602
* "Atomic Lust" scissors now positioned on bed (instead of beneath)
* updated scene picker to help reduce same scene repeating on next round -- companion dislike check failed to account for last scene repeat
* updated AAF player with busy keyword check and gender override where appropriate -- removes gender override keyword on stop
* small adjustments to intimate chance with creatures -- Strong may need more balancing
* updated MCM intro page with more accurate information and added mention of intimate bed with storage
1.601
* Ada as human (see Ada2Human mod) available for intimacy with Extra NPCs enabled and after completing 'Restoring Order' quest
* fixed case choosing Extra NPCs for intimacy when not set in preferences due to companion showing as infatuated
* if faithful and cancel from intimate prompt for wrong companion, now restores faithful count
* disable then enable Intimate Scenes will now replace checkmarks on Intimate Tour Quest like toggle enable quest itself does
* updated intimate prompts (Message) for single-lover, same-lover, friend, infatuated/charmed, and lover so companion's name displays (name on button may not display)
* Heather Casdin and Wastelander Barb if sitting/sleeping will no longer replace main companion for intimate prompt 
* bed-ownership: if owned twin-bed occupied by other companion, show warn instead of replace
1.600
* Companion Affinity for intimacy or bed sharing: for each nearby, awake romanced companion hates flirting also hates player getting intimate with another lover (may be disabled)
* affinity for Strong intimacy: several companions hate this - Cait, Curie, Danse, Hancock, MacCready, Piper, Preston
* affinity for Dogmeat/self-love scene romance companion hates: Danse, MacCready, Piper
* affinity for Dogmeat/self-love scene companion likes: Cait, Hancock (same as like naked player)
* other nearby lover hates flirting decreases intimacy chance
* updated intimate location score and prompt bed-own for ownership-claim owned by another lover
* double-beds: if other side occupied then skip intimate prompt - straight to sleep or warn
* correction for failing to remove companion from intimate-faction after scene when skip sleep leading to mixed behavior after switching companions
* temporary dog bed for scene not going away fixed (sometimes 2 were created)
* new intimate setting companion Gender Preference (male, female, both, faithful)
* made Nick Valentine available for intimacy playing XOXO mode (hugs, kisses, dances)
* recognizes accessories and coat from "CROSS Children of Atom" by Neiro
* recognizes "Unlimited Companion Framework" (EFF) to unlock nearby companions not following
* fixed holotape 'Scan mods for new gear' feature broken in v1.50 update


1.58  (not released)
==========================
* added Intimate Bed with storage: automatically store sleep clothes on bed exit and equips on Rest; bed decor may come from bed storage
* increased Sex Appeal bonuses for wearing intimate outfit, dressed in sleep clothes, and naked
* increased chance bonus for party drugs
* added Danse intimate scene preferences
* increased beginner intimate bonus
* added small intimacy chance bonus for Curie, because it fits her story and dialogue -- for fairness also added bonus for a male: Danse since must get far into main quest for romance
* on activate Rest if player naked for intimacy - remove clothing for dance/hug to ensure flagged as naked due to change in 1.56 on prompt after scene
* grammar correction for bed-own reassign message (DTSleep_OwnBedDoubleReassignMessage)
* added SnapBeds other half to double-bed list for bed-ownership checks
* companion sleepwear - fixed case put on red or white bathrobe then takes back off
* correction for removal of Heather Casdin mod to avoid clearing NWS Barb if also active
* added check for intimate faction on correct alias concerning bed-ownership and intimate scenes which with multiple followers may have resulted in wrong companion
* bed-ownership: now companion must belong to settlement to be assigned else twin/side set to private-open for any companion
* bed-ownership: companion unassigned from other beds before assigned to twin/side bed
* bed-ownership check correction for nearest twin/side must be reasonably level with target bed (no bunk-beds)
* bed-ownership: if player owns bed and settler owns twin, silently un-assign settler
* bed-ownership: added warning for case when player alone and settler in bed
* added message to remove bed assignment for case when current companion does not live at settlement
* adjusted intimate-since recent warning from 3 to 4 hours

Companion assigned to twin/side bed will be automatically un-assigned from all existing beds which in Workshop mode the game just allows multiple assignments. Assigning companion via menu now limited to companion living at settlement, because on workshop refresh assignment to non-settler may get replaced by player-ownership (hidden). 


Changes 1.56 (2019 Feb 16)
==========================
* "Sleep Together Anywhere" sleeping bag - health recovery, Immersive Rest fast-time, and Survival recovery working again
* fixed on Rest sleeping companion kicked out of bed or not undressing - error introduced in 1.55
* Immersive Rest Survival fatigue - correction for double-adjusting clock reset too short on interrupted sleep
* Rest health recovery increased to 1/2 max recovered in 6-hour sleep with no recovery in 1st hour
* Rest Dogmeat go-to-bed: checks if dog on player or companion bed to avoid sleeping on top of character
* after intimate scene: if dressed for scene (hug, dance) prompt for bed
* Test Mode feature Twin/Double-bed Owned: when with companion warn if double-bed or vault twin-beds (side-by-side green vault beds) assigned to another, or claim ownership - options - disabled, warn-only, or warn-and-claim

For this version, the bed ownership check requires Test Mode enabled. In MCM find the setting under TEST features section. Enable Test Mode in the holotape General Settings Menu. The game revealed some interesting cases, and I have had a chance to review how this feature might conflict with other mods ownership features. For explanation on how it works see the web at https://www.dracotorre.com/mods/sleepintimate/sleepbeds/#ownership



Changes 1.55 (2019 Feb 08)
==========================
* re-organized holotape menus: General Settings, Sleep Settings, Intimacy Settings
* mod "Sleep Together Anywhere" now supports intimate scenes - use 'Intimate' activator
* SnapBeds double-bed: both sides now available for companion (only 'right half' marked as big-bed for intimate scene picker)
* Immersive Rest (fast-time): reduced wait until time-scale change by 20 seconds to 56 seconds real-time
* Immersive Rest (faster-wait-time) added - works similar to Wait and increases Hours Waited stat accordingly
* Immersive Rest fast/faster: added filter effect to denote time passing quicker - may be disabled
* Immersive Rest: lover bonus restricted to lover's bed nearby (300)
* Immersive Rest Survival/HC: HC deprivation timer reset on sleep finish based on hours rested for proper timing of becomming tired
* Immersive Rest Survival/HC: start sleep checks fatigue to prevent incapacitated-level forcing exit bed
* Dogmeat go-to-bed: if no dog-sleep nearby, Dogmeat will lay down at foot of sleeping bag or current location
* backpack placement for sleeping bag or ground mattress now near head
* corrected day-of-week for January and February
* companion go-to-bed: correction for nearest bed occupied or settler-owned which resulted in companion standing doing nothing
* companion go-to-bed: fixed empty message companion's "bed unavailable" for nearest beds occupied (attached message to quest)
* bed-ownership bonus fixed for Covenent and Automotron Lair workhops
* undress: companion sometimes failed to redress all armors--extended undress timer and delayed auto-save until redress finished
* undress: increased default timer to fetch armor list and updated settings in holotape
* for extra safety when in Workshop mode the 'Rest' and 'Quick Dress' activations disabled until exit Workshop
* reset dance positions to place female on bed like in 1.40
* fixed case just entered bed and radiation damage interrupt -- now wait until sleep started before chance to interrupt
* removed non-rented owned ground beds providing intimate bonus (Far Harbor Nucleus)
* added Cryopod to no-rest list - prevents showing beside 'access memory'
* added missed child bed (ground_kid) to child-bed list (already on no-intimate list)
* fixed prompt: days-since display without experience instead of beginner prompt
* AAF Leito XML: removed female-female (FF) section
* messages added: DTSleep_NapCompBedClaimedMsg, DTSleep_OwnBedDoubelReqMessage, DTSleep_OwnBedTwinReqMessage, DTSleep_OwnbedOwnedWarnMessage, DTSleep_RestPoorInterruptedMsg
* messages corrected: DTSleep_ExitBedTipMessage (replace 'Sleep' with 'Awaken'), DTSleep_CustomCamTipMessage (brief)
* help text updated: MCM, DTSleep_OptionHelpMan, DTSleep_OptionHelpSettings


Changes 1.52 (2019 Jan 08)
==========================
* Immersive Rest 3+ hours: romanced companion speaks wake
* Immersive Rest for private/owned/settlement bed now up to 7 hours if uninterrupted and allow setting manual exit at 6+ hours for full recover
* Immersive Rest with lover 7+ hours grants Intimate Rest bonus (+1 End, +20 Sex Appeal) for 20 hours - interrupted sleep removes
* AAF "Atomic Lust" - fixed generated ID from 1.50
* scene picker: fixed error (1.50) for empty pick and mistake severely limiting scenes for same-gender females and incorrectly limiting doggy-style for male player
* scene picker: changed random dance check with too few scenes for situation to skip random check if player has big animation pack (Leito) or more than 2 packs
* companion go-to-bed: ignore companion in power armor (was forcing out) assumed on guard duty by player
* undress situational: changed owned bed to always undress to match settlement bed
* correction for companion go-to-bed setting switching from after-intimate-only to always
* messages added: DTSleep_LoversEmbraceMessage


Changes 1.50 (2019 Jan 06)
==========================
* exit bed "Awaken" text activation (DTSleep_PlayerSleepBedPerk)
* recognize beds from "Settlements Supplies Expanded"
* SavageCabages customized to allow some bed animations on sleeping bag, ground mattress 
* fixed red,white bathrobes not always equip on companion (added to armor-all exceptions)
* increased intimate quest reward bonus
* if companion Power Armor glitch prevents adult scene (AAF) then displays reminder (DTSleep_PersuadeBusyWarnPAFlagMsg) and quick-dance without fade
* after bed increased delay of re-enable bed activation to prevent activation when still redressing - also added flag to undress system
* fixed scene-cancel (Pip-Boy menu) feature
* fixed dance for no second actor (like Strong) by skip positioning
* fixed missed backpack clean-up after undress reset and a no-undress intimate-no-sleep
* after exit fail (activate wrong furniture) and sneak to reset now includes companion-wake so companion doesn't become stuck in bed
* after exit bed and sneak to reset now resets camera to normal
* added XOXO mode
* FOMod installer added to choose AAF XML files for animation packs
------------------AAF--------------
* added AAF Test Mode reminder tip (DTSleep_AAFGUIEquipReminderMessage) 


Changes 1.47 (not released - GitHub sources 1.47 not working correctly)
=======================
* improved companion intimate scene preferences (hate/like) with support for multiple hate/like regardless of animation pack
* changed scene picker to gather all available scenes from all animation packs then chooses at random (old way randomly picked pack first)
* intimate chance - voyeurs: nearby lovers no longer included in prompt count and now count same as sleeping for nearby-NPC-penalty total
* 2nd lover go-to-bed (clothed)
* SnapBeds added to double-bed-specific list to support animations requiring double-bed, and added missing pre-war bed to intimate bonus
* intimate-gift-removed and lucky-dog notifications display again ('bug' introduced in v1.25 to prevent move-controls swinging view after prompt)
* added after-intimacy sleepy prompt (DTSleep_AfterIntimateRestPromptMsg) as alternate for not-tired prompt since always prompts after intimacy
------------------AAF-------------
* added AAF play for "SavageCabbages Animation pack" and included 2 female-female scenes (lap dance and twerk)
* for AAF scenes optional set No-Fade to observe error reports
* AAF improved scene end timing -- player checks animation start for proper ID and status--cancels on AAF and sends event one done
* added AAF error message for disabled setting (DTSleep_ErrorAAFMessage)
* adjusted AAF scene player (DTSleep_PlayAAFSceneScript) for more generalized stage sequences defined id/time/armor per stage
* added optional support for Settlement Menu Manager (SMM) - if detected switches to SMM workshop menu control
* added Test Mode scene ID display (DTSleep_TestModeIDMessage) for... testing

Changes 1.45 (not released)
=======================
* Immersive Rest: prompt for Rest after intimate scene --situational if not sleepy and setting prompt enabled (DTSleep_AfterIntimateRestPromptMsg)
* scene picker updated with more variety and correction to not include Strong in "Atomic Lust" scenes
* companion go-to-bed now considers if owned bed nearby
* setting fix: Leito Best Fit shows in holotape when disabled
* pre-adult-scene male player arousal
* added start tip reminder message: if 'Rest' not shown on bed (DTSleep_TipNoRestShowMessage)
* added intimate scene wait-to-finish notice (DTSleep_WaitOnSceneFinishMessage)
* added version upgrade message for when mod disabled (DTSleep_VersionOffMessage)
----------------AAF------------------
* overhauled AAF scene setup and player to support variable-length, multi-stage-branching sequences
* fixed AAF scene-end clean-up
* added AAF play for FO4_AnimationsByLeito v2 - requires optional AAF XMLs (installer) - dog not included
* "Atomic Lust" scenes now require XML (installer option)
* "Atomic Lust" scenes now include variable-length spanking only with companions whom prefer spanking
* AAF scenes - hide HUD


Changes 1.42 (2018 Dec 24)
==========================
* AAF: will not undress all for AAF scenes - AAF re-dress gets in the way of undress system
* will no longer remove all clothing for dance scenes (like XB1)
* changed upgrade to display count of new gear found if any (was hidden)
* mod Femshepping's Cliff-side Home recognized as private location

Changes 1.41 (2018 Dec 23)
==========================
* updated to reconcile Leito's v2 (disables Leito's animations if present) and restore X_Anims patch
* if player character is without main body outfit then will not change into sleep clothes for bed
* SnapBeds double-bed added to big-bed list for bed positioning

Best to keep Leito's 1.4 and avoid switching to v2 mid-game! 
Leito's v2 not currently supported and if installed will disable Leito's animations unless using new X_Anims patch v1.41.

Changes 1.40 (2018 Dec 18)
==========================
* intimate persuasion holiday bonus - added holiday prompts (holday bonus varies and some with additional same-lover bonus)
* intimate persuasion added owned-bed prompt
* intimate bed bonus fixed
* new warning message: bed at unsafe height
* "SnapBeds" correction: double-bed intimate bonus switched to player's side ("right-half") 
* tweaked intimacy chance favorably - Sex Appeal experience table, faithful and monogomy bonus, settlement score, companion-owned bed, time-since score
* romance bug handled: companion considered same as 'flirting' - acquire more likes or resolve bug to re-establish romance
* Immersive Rest continued under 1 hour no longer gives disease
* Curie now available before romanced like other companions
* new setting: AAF scenes enable/disable
* AAF pre-scene adjustment results in quicker scene starts
* companion bed-finder: now ignores settler-owned beds
* Goodneighbor date AAF scene support
* sleep mode message changed to help tip
* added help tip messages - persuasion, immersive rest interruption, and how to exit bed
* Crazy Gun fix for stand positioning
* companion undress: fixed case of failed armor removal
* recognize "Thirty-Yard Bunker (Eli_Bunker) as private location
* recognize "RRTV Goodneigbhor Condo" as private location

Changes 1.32 (2018 Dec 06)
==========================
* Advanced Animation Framework (AAF) intimate scenes - includes animations from "Atomic Lust" if installed
* "Tales of the Commonwealth" - locations recognized for intimacy chance
* companion go-to-bed after intimacy fixed for setting after-intimacy-only
* companion bed-finder - much improved success rate for base-game unoccopied beds (custom beds if close enough)
* companion selector - fixed busy companion of higher rank replacing lower rank companion
* if controls stuck after bed - sneak to reset - updated for more cases
* bunk beds available for companion go-to-bed
* intimate prompt Display Chance no longer displays unknown flag (-200) replaced with real score (may still be guessed score for other cases)

AAF beta - needs peformance optimizing and power armor glitch detection (waits for repeated attempts to exit)

* if Sleep Intimate detects power armor bug/glitch, companion restricted to other (non-AAF) scenes
* if AAF setup takes too long first fades in to watch and then cancels after a minute
* Leito scenes only use Sleep Intimate scene player - AAF poorly suited for variable duration, mult-stage-branching sequences
* characters may intially be out of view - turn camera


Changes 1.30 (2018 Dec 04)
==========================
* new setting Sort Holotape top/bottom
* Dogmeat go-to-bed for Immersive Rest, companion go-to-bed enabled - any nearby dog house or dog-sleep marker
* added bathrobe colors: red, white
* starting new game - replaced silent startup with delayed startup after exiting Vault 111
* Undress Check: now available start game before day-1 ends
* Purple Bathrobe: corrected ground model color to purple (was pink)
* fix when mod disabled incorrectly re-enable Rest activator such as when re-enter and leave Vault 111
* renamed settings 'Partner go to bed' to 'Companion go to bed' and 'Partner Busy Reminder' to 'Companion Busy Reminder'
* Crazy Gun animations timer fixed

=======================
Changes 1.28
=======================
* new setting Sort Holotape top/bottom
* Dogmeat go-to-bed for Immersive Rest, companion go-to-bed enabled - any nearby dog house or dog-sleep marker
* added bathrobe colors: red, white
* starting new game - replaced silent startup with delayed startup after exiting Vault 111
* Undress Check: now available start game before day-1 ends
* Purple Bathrobe: corrected ground model color to purple (was pink)
* fix when mod disabled incorrectly re-enable Rest activator such as when re-enter and leave Vault 111
* renamed settings 'Partner go to bed' to 'Companion go to bed' and 'Partner Busy Reminder' to 'Companion Busy Reminder'


Changes 1.26
=======================
* bed activator: expanded race restriction to player-human-animations (keyword AnimArchetypePlayer)
* detect Vulpine race to avoid undress tail and limit intimate animations
* undress double-checks strap-on item
* companion can't-find-bed message canceled if player character exits bed soon
* X_Anims patch recognized for continued game, but no longer supported for new game - use original FO4_AnimationsByLeito

Changes 1.25
=======================
* added support for gender-swapped charisma perks (Black Widow / Lady Killer) - first perk obtained determines target gender for bonus
* mark mask: fixed multiple equip detection issue - stops at first equip
* strap-on for scenes: fixed scene fail on condition no recognized armor mods present
* fixed Strong nude armors, added Supermutant meshes and textures to X_Anims patch as loose files
* Extra NPCs: solved incorrectly picked when non-follower setting and Extras disabled due to 'infatuated' flag
* missing Dogmeat animations from early release - verifies animations ready on load game
* Settings Menu 'Return' button - removed Test Mode disable
* fixed error forcing Dogmeat into intimate alias for intimate companion name quest - checks if Dogmeat to skip
* changed "Bed Unavailable for Intimacy" message to only display when notifications or partner-busy settings enabled
* intimate prompt: adjusted player controls to prevent looking around just before and after prompt and completely prevent movement during scene setup


Changes 1.24
=======================
* Magnolia date: fixed stuck-at-talk after intimate scene - bug introduced in v1.20
* added Problems-Solutions Help guide to holotape and MCM
* Intimate female-female: no longer requires strap-on: will dance if no supported female-female animations found
* companion bed-finder: added minor workaround for game-engine bug** and if fail displays alternate message ("rather stay awake")
* companion bed-finder: increased search radius by 30% for larger homes
* auto-save: now includes if Save-Or-Sleep setting disabled, changed 3+ to 2+ hours, and added option after 5+ hours as default for new players
* Immersive Rest: added may-continue sleep message on interrupted rest
* Immersive Rest: fixed invalid health update following full sleep when getting in-and-out bed before 1 hour
* MCM wording changes and dropped Test Mode toggle (use holotape instead), and added pages with basic info on main page
* Intimate Scene: minor setup adjustments and slightly longer fade-out - restored re-position for disabled Immersive Rest
* DLCWorkshop03 green vault bed now provides intimate chance bonus like double-bed
* intimate prompt voyuer estimate corrected--reduced by one
* intimate persuasion chance: sleeping NPC penalty reduced by 1 per NPC, weather adjustments--summer +3% and winter +4% (reduced penalty)
* added Nuka-World sweets to sweet gifts list

**game-engine bug: basically reports several beds, but cannot tell which is which. Tech-talk: sometimes ObjectReference.FindAllReferences* returns multiple copies of same object--one copy for each actual object count. My workaround detects the situation and then tries Game.FindClosest* which may find the same bed again. Since also searching closest from companion may improve chance, but all three methods may find same player's bed and still fail. Noted in DTSleep_CommonF.

Changes 1.21
=======================
* Intimate Destinations quest toggle back on now restores checkmarks
* minor fix for upgrade to 1.20 ensure if without Far Harbor set quest correctly

Changes 1.20
=======================
* increased intimate chance bonus for beginner (no success count)
* intimate destinations quest - fixed missing Far Harbor locations
* strap-on item for companion auto-equip fail - set equip status to force off sleep nude-ring
* new Pick-Spot intimate prompt feature - preference set in Settings Menu, Prompt for Intimacy (Pick Spot), notification tips added
* Intimate Destinations Quest: reset total count if disabled
* auto-save: increased time-since-last check to avoid double-save after resume rest
* added intimate scene demo for new player to test - see Test Menu
* moved "SnapBeds" plugin out of manual-only mod-search into regular on-load category where it belongs
* intimate scenes player character movement reduced when possible to help avoid stuck-black-load screen
* renamed end-scene-fade preference in Test Menu to Scene End Positioning - will now fade
* terminal settings - sorted partner-busy options together
* pick-a-spot test option removed from Test Menu
* MCM - added remaining basic preference settings--still require holotape for advanced features

How to pick a spot after success: position character with clear floor directly in front and behind before countdown ends.


Changes 1.17
=======================
* intimate scene positioning improved
* pick-a-spot test feature - enable in MCM at bottom to reveal extra prompt, 'Persuade and Pick Spot'

Changes 1.16
=======================
* correction for bed-unavailable-for-intimacy notice in v1.15 notice preventing sleep
* correction for Pip-Pad visible introduced in v1.13 - if visible reload or move pad

Changes 1.15
=======================
* MCM: basic preference settings
* "Player Comments" (PCHT): auto-disables before bed and re-enables after - recommend manual toggle for better safety
* added notice bed unavailable for intimacy
* added notice companion in Power Armor - was part of "combative" notice
* limited auto-save to no sooner than 3 game-hours
* fix for missing companion name in prompt (forced alias)
* Custom Camera 3rd-person start: sometimes became stuck so force 1st-person and back to 3rd
* intimate scene setup - removed unecessary player character restrain

Changes 1.14b
=======================
* adjusted Goodneighbor romance to skip fade-out-and-in and removed place-in-bed
* fixed logic error preventing activation

Changes 1.13
=======================
* Intimate Scene End - Scene Cancel now skips fade-out - if still get stuck black load screen - try cancel scene
* Intimate Scene End - Immersive Rest now faster with go straight to bed (formerly moved character standing then to bed)
* Intimate Scene End - improved cancel scene clean-up - bed decoration removal
* Intimate Scene End optional no-fade-out - see Test Menu to disable fade-out and auto-rest
* SnapBeds twinbeds improve intimate location score (suggestion by maximluppov), companion will find "left half" only, child beds no-intimate, bunkbeds marked no-rest zone
* fixed Undress Check removing Pip-Boy and changed bed activation label to Undress Check
* fixed Overcoat / Jacket menu (CK munched)
* fixed companion name missing on notice
* playerhouse pre-war bed improves intimate location score
* optional auto-save on bed-exit Immersive Rest sleep 3+ hours (suggestion by yuser)
* added strap-on 'toy' reminder notice if missing between ladies
* fixed Pip-Pad removal in slots 56 and 57
* added to Test Menu: banner displays if at Intimate Location spot
* detects In-Game Third-Person Control (ITPCC) and disables custom camera
* removed what-chance from menu -- too slow and available on bed
* add setting pref: bed decor enable/disable

Changes 1.10
=======================
* fixed Sleep Clothes Menu mark/unmark, bug introduced in 1.04
* companion goes to bed Immersive Rest only with options for always or after-intimate-only
* companion-busy warning now with more info: sit/use, combat, in-scene, incompatible situation
* companion-busy sit-flag checked if actually walking to overturn busy
* fix for super-slow redress--threaded backpack cleanup
* companion sleep winter outdoor - remove outer armors if no jacket
* synthGen2 limited to romanced and non-Curie-synths if adult content disabled to support Nick Valentine romance mod
* disabled Rest in Vault 111
* added extra mod-disabled checks
* for using sleep menu - added interrupted notice for mod support (base-game interuptions are obvious)
* adjusted busy-bed check - should be fewer fake-occupied beds
* improved intimate-end-scene clean-up - (let me know if getting infinite load-screen)
* Player Comments Head Tracking - added reminders to disable before activate Rest or Quick Dress
* dropped Dogmeat Scene knows-name requirement
* custom equipment: added failed to add notice
* custom strap-on: fixed clear/unmark
* custom Extra: fixed add updated worn gear
* added companion name to persuasion prompts
* integrated support for "Wastlander Barb" unique follower


Changes 1.07
=======================
* fix for incorrect display of persuade tutorial when intimacy disabled or lover sleeping
* removed "too excited to rest" (happy face) restriction
* added optional partner-is-busy reminder - Settings Menu -> Partner Busy Reminder
* tutorial reminder for adult female-female intimate gear requirement

Changes 1.06
=======================
* added compatibility for "Sleep or Save" - see Settings holotape to toggle Rest/Save bed activate
* added tutorial before first persuade intimacy attempt
* added persuasion fail voice ("Damnit!" "Hmmm...") and notification for first 2 fails
* detects AFT to consider more followers


Initial release version: 1.04


