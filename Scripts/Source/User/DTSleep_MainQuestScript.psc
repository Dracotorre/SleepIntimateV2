Scriptname DTSleep_MainQuestScript extends Quest
{ Main quest reacts to bed or seat activation via DTSleep_PlayerSleepBedPerk }


; ********************* 
; DTSleep_MainQuestScript main quest controller for Sleep Intimate version 2, v3
; by DracoTorre
; www.dracotorre.com/mods/sleepintimate/
; https://github.com/Dracotorre/SleepIntimateV2
;
; This quest never stops -- responds on player bed or seat activation event added by Perk
;
; 
; Adds animations on bed with undress/dress and lover intimacy using additional bed activation set in a Perk, DTSleep_PlayerSleepBedPerk.
;  The perk adds a new activated control so that player may choose normal sleep or our "Rest" sleep. We catch this perk control in an OnEntry event.
;
; Allows outfit-swap using Outfit container; player undress put in container and dress from container contents. Uses same Perk.
;
; Only one furniture override perk on player at a time. This quest handles responses from holotape and MCM to toggle perks of other mods, 
;    NNES and SaveOrSleep, to allow working together. Others such mods (like PlaceAnywhere) with their own toggle assumed controled by player.
;
; ----------------------------------------------------------------------------------------------------------------------
; **** mod authors interested in making compatibility patch  - see the website for details
;
;    basics: player may choose two styles of sleep:
;       - Quick Sleep (global DTSleep_SettingNapOnly <= 0): normal game sleep events then OnPlayerSleepStop places characters in bed if unocuppied
;       - Immersive Rest (global DTSleep_SettingNapOnly >= 1): fake-sleep with character placed in bed with optional recovery for Survival
;			** player allowed to exit bed early and continue sleep within 2 hours
;
;    basics: how player character exits bed:
;		- activate 'Akwaken' via Perk activator override 
;		- activate a different furniture ('sleep walking') -- this MainQuest cancels sleep status after player sneaks or changes location
;       - Immersive Rest sleep-timer ends 
;		- rest interruption (DTSleep_HealthRecoverQuestScript)
;
;       No matter how player exits bed for Immersive Rest, DTSleep_HealthRecoverQuestScript.RestCompleteEvent is sent
;
; 	If your mod depends on OnPlayerSleepStart or OnPlayerSleepStop events other than for animating, advise players to choose Quick Sleep.
;	To find out when Immersive Rest ends, listen for DTSleep_HealthRecoverQuestScript.RestCompleteEvent.
;   To find when Immersive Rest begins (after 1st game-hour), listen to DTSleep_HealthRecoverQuestScript.RestStartedEvent.
;
;
; No API, but you may use Game.GetFormFromFile (and store the Form for performance) to check on data or listen for events.
;
;
; -----------------------------------------------------------------------------------------------------------------------
; MainQuest uses other quests and scripts:
;
; DTSleep_Conditionals				- stores data mostly to keep track of DLCs and other supported mods installed
; DTSleep_CommonF					- global collection of common functions
; DTSleep_IntimateUndressQuest 		- undress/dress player and companions so characters may keep wearing jewelry or custom underwear
; DTSleep_EncounterQuest 			- special in-bed encounters such as addictions, teddy bear cuddle, or gifts in bed--based on inventory
; DTSleep_IntimateAnimQuest 		- controls animated sequences including pre-bedtime intimate love scenes or hugs/kisses/love at seats
; DTSleep_SceneData 				- data for scenes and keeps track of consecutive scenes for faithfullness
; DTSleep_MainQSceneScript 			- low-cam controller and keeps track of third/first-person
; DTSleep_OutfitContainerScript		- mod furniture to swap outfits activated through Perk-added activator
; DTSleep_HealthRecoverQuestScript 	- controls Immersive Rest recovery and reports if player is sleepy or not
; DTSleep_IntimateTourQuestScript 	- destinations quest
; DTSleep_DogTrainQuestScript 		- training dog with sex (adult only and no longer used in version 2)
; DT_PotionHandleQuestScript		- safely add effects to player without triggering game-freeze bug (VATS)
; DT_RandomQuestScript				- Random numbers using card-shuffle, because game's random generator found to be too deterministic
; DTSleep_BedOwnQuestScript			- helps player claim or change ownership to fend off settlers, or just keep track of companion ownership
; DTSleep_IntimateAffinityQuest 	- affinity reactions by companions based on normal game likes/hates
; DTSleep_CompIntimateQuest			- to get lover name; packages for wait and Dogmeat wait during scene
; DTSleep_CompSleepQuest			- to get lover name; packages to send to bed including Dogmeat
; DTSleep_SpectatorQuestScript 		- (version 2) nearby companions or guards may spectate intimate scene
;
; 
; note: normal game lover companion will be placed into bed which blocks player character being placed in bed (Immersive Rest disabled).
;       if player desires, instruct companion to sleep in another bed -- which blocks pre-bedtime love scene
;       I chose to block companion joining animated sequences if sit or sleep to prevent pulling NPC away from workshop activity,
;       and to allow player more choice--if have multiple lovers, instruct one to sit or sleep and preferred lover to stand.
;       A Companion currently working settlement job tends to have problems with animated scenes unless first updating package
;       and perform LooseIdleStop---which takes extra time.
;
; General design behavior:
; - second "Rest" activation unavailable (controlled by perk) for in combat, sneaking, wearing power armor
; - sleep interrupted - no in-bed animation for quick save
; - sleep < 4 hours - stay dressed for nap; may remove outer armor
; - sleep >= 4 hours - undress if indoors or settlement--see lists for safe locations to get naked
; - pre-bed lover scenes generally just hugs/kisses, and require other mods--Leito's or Crazy animations--for sex scenes
; - chance for intimate scenes allow role-playing / game value--factors include charisma, illness, time since last scene, location
; - some beds cannot perform in-bed animation on player so performs normal sleep--tracked by list: DTSleep_BedPlacedNoRestList
; -----------------------------------------
;
;  ObjectReference.IsFurnitureInUse note: set to true once NPC begins to walk towards it so may not actually be in use yet
;		- double-check using function, IsFurnitureActuallyInUse
;
;  Actor notes:
;
; actor's sleep state, which is one of the following (game actually binary sleep/not):
; 0 - Not sleeping
; 2 - Not sleeping, wants to sleep	- game does not use
; 3 - Sleeping
; 4 - Sleeping, wants to wake		- game does not use 
;
;int Function GetSleepState() native
;
;  sitting (or using workstation) is also binary (wants-to-sit never set), so determine if actually sitting by watching movement
;
; power-armor glitch determination: first check keyword is false then check IsInPowerArmor -- see function, IsCompanionPowerArmorGlitched
; WornHasKeyword(isPowerArmorFrame) 
;
;
; ************************************************


; *********************************************
;  ****         Structure  ******
;

Struct IntimateBedFoundSet
	ObjectReference BedFoundRef
	bool BugDetected	
EndStruct

Struct IntimateCompanionSet
	Actor CompanionActor
	int RelationRank
	bool RequiresNudeSuit  ; set if mod companion has never-nude body
	bool PowerArmorFlag
	int Gender
	bool HasLoverRing
	int RaceIntimateCompatible
EndStruct

Struct IntimateChancePair
	int SexAppeal
	int Chance
EndStruct

Struct IntimateLocationHourSet
	int Chance						; reported chance: if -200 then failed check
	int ChanceReal					; actual chance calculated by skills
	int LocChanceType
	int LocAdj
	int HolidayBonus
	int HolidayType
	int NearActors
	int NpcAdj
	int HourAdj
	int WeatherAdj
	string LocTypeName
	Location LocChecked
	float CheckTime
	bool BedOwned
	int MidSleepBonusChance			; v2.33
EndStruct

Struct IntimateWeatherScoreSet
	int wClass
	int Score
EndStruct

; ********************************************
; *****           Properties      *********
;
Group A_MyScriptsQuests
; for DTSleep_PlayerAliasScript
ReferenceAlias property SleepPlayerAlias auto
DTSleep_Conditionals property DTSConditionals auto
; our added bed activator
Perk property DTSleep_PlayerSleepBedPerk auto
; sleep encounters: start it at bedtime and it will end after leaving bed       
Quest property DTSleep_EncounterQuestP auto
Quest property DTSleep_IntimateUndressQuestP auto
Quest property DTSleep_IntimateAnimQuestP auto
Quest property DTSleep_IntimateAffinityQuest auto
Quest property DTSleep_IntimateTourQuestP auto
Quest property DTSleep_TimeDayQuestP auto
Quest property DTSleep_HealthRecoverQuestP auto
Quest property DT_PotionHandleQuestP auto const
Quest property DT_RandomQuestP auto
Quest property DTSleep_CompSleepQuest auto
Quest property DTSleep_CompIntimateQuest auto
Quest property DTSleep_BedOwnQuestP auto
Quest property DTSleep_SpectatorQuestP auto
Quest property DTSleep_TrueLoveQuestP auto const
Faction property DTSleep_IntimateFaction auto const
ReferenceAlias property DTSleep_CompBedRestAlias auto
ReferenceAlias property DTSleep_CompBedSecondRefAlias auto const
ReferenceAlias property DTSleep_CompDogBedRefAlias auto const
ReferenceAlias property DTSleep_CompSleepAlias auto const
ReferenceAlias property DTSleep_CompSecondSleepAlias auto const
ReferenceAlias property DTSleep_DogSleepAlias auto const
ReferenceAlias property DTSleep_CompBedSexRefAlias auto
ReferenceAlias property DTSleep_CompIntimateAlias auto const
ReferenceAlias property DTSleep_DogIntimateRestAlias auto const				; Dogmeat
ReferenceAlias property DTSleep_DogBedIntimateAlias auto const				; doghouse
ReferenceAlias property DTSleep_OtherFurnitureRefAlias auto const
ReferenceAlias property DTSleep_CompIntimateLover2Alias auto const
ReferenceAlias property DTSleep_TrueLoveAlias auto const
DTSleep_MainQSceneScript property MainQSceneScriptP auto
DTSleep_DressData property DressData auto const			; used by IntimateUndress -- not truly needed here
DTSleep_SceneData property SceneData auto const
EndGroup

Group B_Globals_Main
GlobalVariable property HC_Rule_DiseaseEffects auto const
GlobalVariable Property PlayerHasActiveCompanion const auto
GlobalVariable Property PlayerHasActiveDogmeatCompanion const auto
GlobalVariable property PlayerKnowsDogmeatName const auto
GlobalVariable property DTSleep_AdultContentOn auto
GlobalVariable property DTSleep_VR auto								; are we using VR-mode?  set to 2+  v3.0
{ 3=VR-game, 2=VR-mode, 1=VR-game-disabled, 0=disabled }
GlobalVariable property DTSleep_IsSYSCWActive auto
GlobalVariable property DTSleep_IsCrazyRugsActive auto const
GlobalVariable property DTSleep_IsLeitoActive auto const			; may be negitive if mixed old-and-new leito
{ allow EVB-Best-fit, Dog scenes, and marks SIX-patch >= 3 }
GlobalVariable property DTSleep_PlayerUsingBed auto Mandatory
{ mark on bed activation and use as cancel check and if bed already activated }
GlobalVariable property DTSleep_PlayerUndressed auto Mandatory
GlobalVariable property DTSleep_IntimateTime auto
{ last game-time intimate scene }
GlobalVariable property DTSleep_IntimateDogTime auto
GlobalVariable property DTSleep_WasPlayerThirdPerson auto
GlobalVariable property DTSleep_IntimateEXP auto
GlobalVariable property DTSleep_IntimateDogEXP auto
GlobalVariable property DTSleep_IntimateStrongExp auto const
GlobalVariable property DTSleep_MagnoliaScene auto
GlobalVariable property DTSleep_CaptureBackpackEnable auto
GlobalVariable property DTSleep_CaptureSleepwearEnable auto
GlobalVariable property DTSleep_CaptureIntimateApparelEnable auto
GlobalVariable property DTSleep_CaptureJacketEnable auto
GlobalVariable property DTSleep_CaptureMaskEnable auto
GlobalVariable property DTSleep_CaptureStrapOnEnable auto
GlobalVariable property DTSleep_CaptureExtraPartsEnable auto
GlobalVariable property DTSleep_Version auto const
GlobalVariable property DTSleep_IntimateLocCount auto const
GlobalVariable property DTSleep_RestCount auto const
GlobalVariable property DTSleep_HRLastSleepTime auto const
GlobalVariable property DTSleep_SettingLover2 auto const
{ include 2nd lover in scenes }
GlobalVariable property DTSleep_SexStyleLevel auto
GlobalVariable property DTSleep_EmbraceLevel auto						; v3.01
GlobalVariable property DTSleep_SexStyleFemHasTail auto					; v3.02
GlobalVariable property DTSleep_AdultOutfitOn auto
GlobalVariable property DTSleep_PlayerEquipSleepGloveCount auto			; added v2.48
GlobalVariable property DTSleep_SceneViewPrefCount auto					; added v2.70
GlobalVariable property DTSleep_SIDIgnoreOK auto						; added v2.73
GlobalVariable property DTSleep_CaptureShoeEnable auto					; v2.80
GlobalVariable property DTSleep_CaptureStockingsEnable auto				; v2.80
GlobalVariable property DTSleep_RomDanceEnable auto						; v3.0
GlobalVariable property DTSleep_SceneFFMissionEnable Auto				; v3.0
EndGroup

Group BC_Globals_Settings
GlobalVariable property DTSleep_SettingUndress auto Const Mandatory
{setting to disable = 0 / situational = 1 / always = 2 undressing in bed }
GlobalVariable property DTSleep_SettingIntimate auto Const Mandatory
{ setting to get intimate with lover: 1 = enabled, 2 = enabled Extra NPCs, 3 = enabled-force-XOXO, 4 = Extra NPCs-force-XOXO }
GlobalVariable property DTSleep_DebugMode auto const
GlobalVariable property DTSleep_SettingCancelScene auto const
GlobalVariable property DTSleep_SettingModActive auto
GlobalVariable property DTSleep_SettingModMCMCtl auto const
GlobalVariable property DTSleep_SettingDogRestrain auto const
GlobalVariable property DTSleep_SettingTestMode auto const
GlobalVariable property DTSleep_SettingUndressPipboy auto const
GlobalVariable property DTSleep_SettingShowIntimateCheck auto const
GlobalVariable property DTSleep_SettingNotifications auto const
GlobalVariable property DTSleep_SettingPrefSYSC auto const
GlobalVariable property DTSleep_SettingNapOnly auto const
GlobalVariable property DTSleep_SettingNapRecover auto const
GlobalVariable property DTSleep_SettingNapExit auto const
GlobalVariable property DTSleep_SettingTourEnabled auto
GlobalVariable property DTSleep_IsSoSActive auto
GlobalVariable property DTSleep_IsNNESActive auto						; added v2.90
GlobalVariable property DTSleep_SettingWarnLoverBusy auto
GlobalVariable property DTSleep_SettingNapComp auto
GlobalVariable property DTSleep_SettingSave auto const
GlobalVariable property DTSleep_SettingCamera2 auto
GlobalVariable property DTSleep_SettingBedDecor auto const
GlobalVariable property DTSleep_SceneTestMode auto const
GlobalVariable property DTSleep_SettingFadeEndScene auto
GlobalVariable property DTSleep_SettingSortHolotape auto const
GlobalVariable property DTSleep_SettingAAF auto
GlobalVariable property DTSleep_SettingGenderPref auto const
{ Male, Female, Both, Faithful }
GlobalVariable property DTSleep_SettingPickPos auto const
GlobalVariable property DTSleep_SettingChairsEnabled auto
GlobalVariable property DTSleep_SettingSynthHuman auto
{ set to 1 to force Valentine or other Gen-2 synths to be like Gen-3 human body }
GlobalVariable property DTSleep_SettingMenuStyle auto
GlobalVariable property DTSleep_SettingChemCraft auto
GlobalVariable property DTSleep_SettingProps auto const					; v2.40
GlobalVariable property DTSleep_SettingRadCheck auto const				; v2.48.1
GlobalVariable property DTSleep_SettingScaleActorKiss auto const		; v2.64 - to reset to default
GlobalVariable property DTSleep_SettingUndressShoes auto const			; v2.80
{ 0=always, 1 = bed-only, 2=never }
GlobalVariable property DTSleep_SettingUndressStockings auto const		; v2.80	
{ 0=always, 1 = bed-only, 2=never }
GlobalVariable property DTSleep_SettingSwapRoles auto const				; v2.82 - usually same gender swap positions
EndGroup

Group C_GameData
Actor property PlayerRef auto const Mandatory
Actor property CurieRef auto const
Actor property CompanionDeaconRef auto const
Actor property CompanionX6Ref auto const
Actor property StrongCompanionRef auto const
Actor property CompanionMacCreadyRef auto const
Actor property CompanionDanseRef auto const
Actor property CompanionCaitRef auto const
Actor property CompanionHancockRef auto const
Actor property CompanionPiperRef auto const
Perk property CompStrongPerk auto const
Perk property CompDeaconPerk auto const
Perk property CompX6Perk auto const
Perk property LoneWanderer01 auto const
ActorValue property CharismaAV auto const
ActorValue property LuckAV auto const
ActorValue property AddictionCountAV auto const
ActorValue property HC_SleepEffectAV auto const
ActorValue property RadResistExposureAV auto const
ActorValue property CA_AffinityAV auto const
Furniture property DogmeatLay01Marker auto const
Location property DiamondCityPlayerHouseLocation auto Const
Location property Vault111Loc auto const
MagicEffect property abReduceEnduranceME auto const
MagicEffect property HC_Disease_Fatigue_Effect auto const
MagicEffect property HC_Disease_Infection_DamagePlayer_Effect auto const
MagicEffect property HC_Disease_NeedMoreFood_Effect auto const
MagicEffect property HC_Herbal_Antimicrobial_Effect auto const
Potion property DTSleep_DiseaseEffect_Infection auto const
MagicEffect property SlowTimeJet auto const
Quest property MQ101 auto const 				; main quest intro
Quest property MQ102 auto const 				; main quest leaving vault
Keyword property ArmorTypePower auto const Mandatory 	; test for both keyword and InArmor just in case
;Keyword Property isPowerArmorFrame Auto const
;Keyword property DamageTypeRadiationKY auto const
Keyword property AlcoholEffectKY auto const
Keyword property WorkshopItemKeyword auto const Mandatory
Keyword property LocTypeWorkshopSettlementKY auto const
Keyword property AnimFurnFloorBedAnims auto const Mandatory
Keyword property pAnimFaceArchetypeHappy auto const Mandatory
Keyword property ActorTypeChildKY auto const
Keyword property ActorTypeDogmeatKY auto const
Keyword property PlayerLockResultSubtype auto const
Keyword property PlayerHackFailSubtype auto const
Keyword property HC_Obj_SleepingBagKY auto const
Keyword property CAT_Event_SleepTogetherWakeKY auto const
Keyword property FurnitureClassRelaxationKY auto const
Keyword property FurnitureTypePowerArmorKY auto const

Keyword property DTSleep_OutfitContainerKY auto const
Keyword property DTSleep_LoverRingKY auto const
ActorValue property WorkshopPlayerOwned auto Const
ReferenceAlias property SleepCompanionAlias auto const 
ReferenceAlias property CompanionAlias auto const
ReferenceAlias property DogmeatCompanionAlias auto const
MiscObject property TeddyBear auto const
FormList property DTSleep_BedList auto const Mandatory
FormList property DTSleep_BedIntimateList auto const
{ modded beds for intimacy chance - compare base form so not for placed references }
FormList property DTSleep_CrimeLocationList auto const
FormList property DTSleep_CrimeLocationIntList auto const
FormList property DTSleep_UndressLocationList auto const Mandatory
FormList property DTSleep_TownLocationList auto const
{ towns, settlements, and other fortified locations for intimacy check }
FormList property DTSleep_IntimateTourLocList auto const
{ romantic destinations }
FormList property DTSleep_IntimateTourIndoorOnlyLocList auto const
{ romantic spot must be indoors }
FormList property SettlementLocationList auto const
{ do we need this? }
FormList property DTSleep_PrivateLocationList auto const
FormList property DTSleep_BedNoIntimateList auto const
FormList property DTSleep_BedsLimitedSpaceLst auto const
FormList property DTSleep_BedChildList auto const
FormList property DTSleep_BedsBigDoubleList auto const
FormList property DTSleep_BedPlacedNoRestList auto const
{ bad beds placed in cells listed below }
FormList property DTSleep_BedCellNoRestList auto const
{ cells that have bad beds listed above }
FormList property DTSleep_BadSheltersList auto const
{ placed beds can't animate rest due to obstructions etc }
FormList property DTSleep_BadShelterLocationList auto const
FormList property DTSleep_IntimacyChanceMEList auto const
{ magic effects granting better chance - keep list very short }
FormList property DTSleep_ActorKYList auto const
FormList property DTSleep_DogSleepKWList auto const
FormList property DTSleep_CompanionRomanceList auto const
{ companions known to use affinity and may be romanced - helps validate for romance bug }
FormList property DTSleep_PilloryList auto const
FormList property DTSleep_TortureDList auto const
FormList property DTSleep_FlagpoleList auto const
FormList property DTSleep_IntimatePropList auto const
FormList property DTSleep_IntimateStoveList auto const 		; added v2.84
FormList property DTSleep_IntimatePatioTableList auto const	; added v2.88
{ deprecated }
FormList property DTSleep_IntimatePatioTwoTableList auto const	; v3.0 correction for 2.90
FormList property DTSleep_IntimateTablesAllList auto const
FormList property DTSleep_NotHumanList auto const			; added 2.62
Spell property DTSleep_LoverBonusSpell auto const
Spell property DTSleep_MutantAllySpell auto const			; added v2.35
Spell property DTSleep_RemoveMutantAllySpell auto const		;
Keyword property DTSleep_MutantBlessKeyword auto const		; -- not needed for now;
Keyword property ActorTypeSuperMutant auto const			; added v2.35
Keyword property ActorTypeSuperMutantBehemothKY auto const	; added v2.40
Keyword property ActorTypeRobotKY auto const				; added v2.40
Faction property DTSleep_MutantAllyFaction auto const		; for bonus or removal on condition
Perk property DTSleep_LoversBonusPerk auto const
Perk property DTSleep_LoversCoffinPerk auto const
Perk property DTSleep_LoverDogBonusPerk auto const
Perk property DTSleep_LoverStrongBonusPerk auto const
Perk property DTSleep_LoversTourBonusPerk auto const
Perk property DTSleep_LoversEmbracePerk auto const
Perk property DTSleep_LoversEmbraceHugPerk auto const
Perk property DTSleep_ExhibitionPerk auto const
Perk property DTSleep_BusyDayPerk auto const
Perk property DTSleep_LoversSexyPerk auto const
Holotape property DTSleep_OptionsHolotape auto const
Holotape property DTSleep_OptionsHolotape2 auto const
Armor property DTSleep_ArmorLoverRing auto const

;ReferenceAlias property SleepCompanionBedAlias Auto
RefCollectionAlias property ActiveCompanionCollectionAlias auto const
Race property HumanRace auto const Mandatory
Race property GhoulRace auto const
Race property SynthGen2RaceValentine auto const
Race property HandyRace auto const							; added v2.40
Perk property LadyKiller03 auto const
Perk property BlackWidow03 auto const
Perk property LadyKiller01 auto const
Perk property BlackWidow01 auto const
EndGroup

Group D_Messages_Basic
Message property pPowerArmorNoActivate auto const Mandatory
Message property DTSleep_StartedMessage auto const Mandatory
Message property DTSleep_StartedExplicitMessage auto const
Message property DTSleep_StartedSafeMessage auto const
Message property DTSleep_StartedVRMessage auto const							; do not use
Message property DTSleep_StartedVR2Message auto const                           ; v3.01
Message property DTSleep_ShutdownMsg auto const
Message property DTSleep_ShutdownConfirmMsg auto const
Message property DTSleep_ConfirmRestoreDefMsg auto const
;Message property DTSleep_StartedNapMessage auto const Mandatory
Message property DTSleep_SaveMessage auto const
Message property DTSleep_SeeYouSleepModFoundMessage auto const Mandatory
Message property DTSleep_BadBedIntimateMessage auto const
Message property DTSleep_BadBedHeightMessage auto const
Message property DTSleep_BedBusyMessage auto const Mandatory
Message property DTSleep_CustomCamTipMessage auto const
Message property DTSleep_NoRestMessage1 auto const Mandatory
Message property DTSleep_NoRestMessage2 auto const Mandatory
Message property DTSleep_NoRestMessage3 auto const Mandatory
Message property DTSleep_NoRestBedHighMsg auto const
Message property DTSleep_NoRestBedChildMsg auto const
Message property DTSleep_NoRestRadDamMsg auto const Mandatory
;Message property DTSleep_NoRestBedOwnedMsg auto const Mandatory
Message property DTSleep_IntimacySuccessMsg auto const
Message property DTSleep_IntimacySuccessAMsg auto const
Message property DTSleep_IntimacySuccessSameLoveMsg auto const
Message property DTSleep_ModScanUpdateMsg auto const
Message property DTSleep_CompanionNotFoundMsg auto const
Message property DTSleep_UndressCheckStartMsg auto const
Message property DTSleep_FriskyForLocationMessage auto const
Message property DTSleep_FriskyFeelingMessage auto const
Message property DTSleep_FriskyNeedMessage auto const
Message property DTSleep_ExhibitionMessage auto const
Message property DTSleep_LuckyMessage auto const
Message property DTSleep_LuckyDogMessage auto const
Message property DTSleep_RadInterruptSleepMsg auto const
Message property DTSleep_RestPoorInterruptedMsg auto const
Message property DTSleep_SleepImmersiveTipMsg auto const
Message property DTSleep_SleepImmersiveTip2Msg auto const
Message property DTSleep_SleepQuickTipMsg auto const
Message property DTSleep_SleepInterruptedMsg auto const
Message property DTSleep_SleepInterruptedSleepStopMsg auto const
{ normal sleep-menu sleep canceled or interrupted }
Message property DTSleep_SleepCancledSleepStopMsg auto const
{ as in on load game to avoid placing in bed }
Message property DTSleep_OversleepMsg auto const
Message property DTSleep_LoverBonusMsg auto const
Message property DTSleep_LoverBonusDogMsg auto const
Message property DTSleep_LoverBonusStrongMsg auto const
Message property DTSleep_SceneDoggyUnsafeMsg auto const
{ name unknown or other dog }
Message property DTSleep_SceneDogMUnsafeMsg auto const
{ Dogmeat name known }
Message property DTSleep_ModSoSDisabledMsg auto const
Message property DTSleep_ModSoSEnabledMsg auto const
Message property DTSleep_ModSoSActiveMessage auto const
Message property DTSleep_ModNNESDisableMsg auto const					; added v2.90
Message property DTSleep_ModNNESEnableMsg auto const					; added v2.90
Message property DTSleep_ModPlayerCommentOnMsg auto const
Message property DTSleep_ModPlayerCommentOffMsg auto const
Message property DTSleep_ModPlayerCommentRemindMsg auto const
Message property DTSleep_PersuadeFailMessage auto const
Message property DTSleep_PersuadeFailLocMessage auto const
Message property DTSleep_PersuadeFailOftenMessage auto const
Message property DTSleep_PersuadeReadyTutorMsg auto const
Message property DTSleep_PersuasionSuccessTipMsg auto const
Message property DTSleep_PersuadeBusyTutorMsg auto const
Message property DTSleep_PersuadeBusyTutorXFFMsg auto const
Message property DTSleep_PersuadeBusyWarnMsg auto const
Message property DTSleep_PersuadeBusyWarnNoticeMsg auto const
Message property DTSleep_BadCompanionMsg auto const
Message property DTSleep_NapCompBedBusyMsg auto const
Message property DTSleep_NapCompBedClaimedMsg auto const
Message property DTSleep_NapCompNoBedMsg auto const
Message property DTSleep_NapCompBedBugMsg auto const
Message property DTSleep_PersuadeBusyWarnNoCompMsg auto const
Message property DTSleep_PersuadeBusyWarnCombatMsg auto const
Message property DTSleep_PersuadeBusyWarnInCompMsg auto const
Message property DTSleep_PersuadeBusyWarnSceneMsg auto const
Message property DTSleep_PersuadeBusyWarnSitMsg auto const
Message property DTSleep_PersuadeBusyWarnNoToyMsg auto const
Message property DTSleep_PersuadeBusyWarnPAMsg auto const
Message property DTSleep_PersuadeBusyWarnPAFlagMsg auto const
Message property DTSleep_NoPAFlagMessage auto const
Message property DTSleep_CountMessage auto const
Message property DTSleep_PickPositionMsg auto const
Message property DTSleep_PickPositionViewMsg auto const
Message property DTSleep_PickPositionStepBackMsg auto const
Message property DTSleep_PickPositionViewShowerMsg auto const
Message property DTSleep_NapContinueMsg auto const
Message property DTSleep_AAFSceneSlowMessage auto const
Message property DTSleep_AAFSceneLockedMessage auto const
Message property DTSleep_ExitBedTipMsg auto const
Message property DTSleep_TipNoRestShowMessage auto const
Message property DTSleep_WaitOnSceneFinishMsg auto const
Message property DTSleep_AfterIntimateRestPromptMsg auto const
Message property DTSleep_AfterIntimateRestNotSleepyPromptMsg auto const
Message property DTSleep_ErrorAAFMessage auto const
Message property DTSleep_LoversEmbraceMsg auto const
Message property DTSleep_LoversEmbraceCoffinMsg auto const
Message property DTSleep_LoversEmbraceHugMsg auto const
Message property DTSleep_PersuadePilloryNoneMsg auto const
Message property DTSleep_PilloryBusyMessage auto const
Message property DTSleep_PAStationPANearMessage auto const
Message property DTSleep_UndressInitMessage auto const
Message property DTSleep_IntimateScenePickMessage auto const
Message property DTSleep_IntimateScenePickFFMessage auto const		; FF scene picker v3.0
Message property DTSleep_IntimateScenePickMMMessage auto const		; MM scene picker v3.0
Message property DTSleep_AAFDisableMessage auto const
Message property DTSleep_PersuadeSoonMessage auto const
Message property DTSleep_BusyDayMessage auto const
Message property DTSleep_IntimacyTwinBedInUseMsg auto const
Message property DTSleep_IntimateDisabledMsg auto const
Message property DTSleep_LoversSexyMsg auto const
Message property DTSleep_StrongBuildBedTipMsg auto const
Message property DTSleep_PickPositionViewKitchenCtrMsg auto const     ; v2.40
Message property DTSleep_PickPositionViewRailingMsg auto const		; v2.70
Message property DTSleep_ToggleRedressOnMsg auto const				; v2.60
Message property DTSleep_ToggleRedressOffMsg auto const				; v2.60
Message property DTSleep_PrefSceneCloneOffAddMsg auto const			; v2.70
Message property DTSleep_PrefSceneCloneOnAddMsg auto const			; v2.70
Message property DTSleep_SceneCancelReplayMsg auto const			; v2.70
Message property DTSleep_SceneCancelReplayPAMsg auto const			; v2.70
Message property DTSleep_PrefSceneIgnoreMsg auto const				; v2.73  player may add scene to ignore list
Message property DTSleep_PersuadePAFlagHelpMsg auto const			; v2.75 ask player to adjust AAF setting
Message property DTSleep_PatchKissFixMessage auto const				; v2.84 patch
EndGroup

Group E_PromptsHuman
Message property DTSleep_IntimateCheckIntroMsg auto const
Message property DTSleep_IntimateCheckIntroPoorMsg auto const
Message property DTSleep_IntimateCheckIntroRiskyMsg auto const
Message property DTSleep_IntimateCheckMsg auto const
{ for romantic companion }
Message property DTSleep_IntimateCheckHrsMsg auto const
Message property DTSleep_IntimateCheckLoverPerfectMsg auto const
Message property DTSleep_IntimateCheckLoverPerfectHrsMsg auto const
Message property DTSleep_IntimateCheckLoverPoorMsg auto const
Message property DTSleep_IntimateCheckLoverRiskyMsg auto const
Message property DTSleep_IntimateInfatCheckMsg auto const
{ for infatuated or less }
Message property DTSleep_IntimateCheckInfatHrsMsg auto const
Message property DTSleep_IntimateInfatCheckPerfectMsg auto const
Message property DTSleep_IntimateCheckInfatPerfectHrsMsg auto const
Message property DTSleep_IntimateInfatCheckPoorMsg auto const
Message property DTSleep_IntimateInfatCheckRiskyMsg auto const
Message property DTSleep_IntimateCheckRecentMsg auto const
Message property DTSleep_IntimateCheckFailsMsg auto const
Message property DTSleep_IntimateCheckAddictMsg auto const
Message property DTSleep_IntimateCheckShowChanceMsg auto const
Message property DTSleep_IntimatecheckHolidayMsg auto const
Message property DTSleep_IntimateCheckHolidayChristmasMsg auto const
Message property DTSleep_IntimateCheckHolidayGWDMsg auto const
Message property DTSleep_IntimateCheckHolidayHallowMsg auto const
Message property DTSleep_IntimateCheckHolidayIndpMsg auto const
Message property DTSleep_IntimateCheckHolidayMrPebMsg auto const
Message property DTSleep_IntimateCheckHolidayNWMsg auto const
Message property DTSleep_IntimateCheckHolidayPatrickMsg auto const
Message property DTSleep_IntimateCheckHolidayRobCoMsg auto const
Message property DTSleep_IntimateCheckHolidayTeaDayMsg auto const
Message property DTSleep_IntimateCheckHolidayValMsg auto const
Message property DTSleep_IntimateCheckFriendMsg auto const
Message property DTSleep_IntimateCheckFriendHrsMsg auto const
Message property DTSleep_IntimateCheckFriendPerfectMsg auto const
Message property DTSleep_IntimateCheckFriendPoorMsg auto const
Message property DTSleep_IntimateCheckFriendRiskyMsg auto const
Message property DTSleep_IntimateCheckOwnedBedMsg auto const
Message property DTSleep_IntimateCheckOwnedHrsBedMsg auto const
Message property DTSleep_IntimateCheckSingleLoverMsg auto const
Message property DTSleep_IntimateCheckSingleLoverPerfectMsg auto const
Message property DTSleep_IntimateCheckSingleLoverPoorMsg auto const
Message property DTSleep_IntimateCheckSingleLoverRiskyMsg auto const
Message property DTSleep_IntimateCheckSameLoverMsg auto const
Message property DTSleep_IntimateCheckSameLoverPerfectMsg auto const
Message property DTSleep_IntimateCheckSameLoverPoorMsg auto const
Message property DTSleep_IntimateCheckSameLoverRiskyMsg auto const
Message property DTSleep_IntimateCheckDangerMsg auto const
Message property DTSleep_IntimateCheckWarnNearbyMsg auto const
Message property DTSleep_IntimateCheckWarnUnsureMsg auto const
Message property DTSleep_IntimateCheckWarnNoChanceMsg auto const
Message property DTSleep_IntimateCheckCrimeMsg auto const
Message property DTSleep_ChairCheckBeginMsg auto const
Message property DTSleep_ChairCheckCrimeMsg auto const
Message property DTSleep_FurnUseCheckCrimeMsg auto const
Message property DTSleep_ChairCheckMsg auto const
Message property DTSleep_ChairCheckNoCompMessage auto const
Message property DTSleep_ChairCheckRecentMsg auto const
Message property DTSleep_ChairCheckNPCMsg auto const
Message property DTSleep_ChairCheckShowChanceMsg auto const
Message property DTSleep_DeskCheckBeginMsg auto const
Message property DTSleep_DeskCheckMsg auto const
Message property DTSleep_DeskCheckRecentMsg auto const
Message property DTSleep_DeskCheckNPCMsg auto const
Message property DTSleep_DeskCheckShowChanceMsg auto const
Message property DTSleep_PASCheckBeginMsg auto const
Message property DTSleep_PASCheckMsg auto const
Message property DTSleep_PASCheckRecentMsg auto const
Message property DTSleep_PASCheckNPCMsg auto const
Message property DTSleep_PASCheckShowChanceMsg auto const
Message property DTSleep_PilloryCheckBeginMsg auto const
Message property DTSleep_PilloryCheckMsg auto const
Message property DTSleep_PilloryCheckRecentMsg auto const
Message property DTSleep_PilloryCheckNPCMsg auto const
Message property DTSleep_PilloryCheckShowChanceMsg auto const
Message property DTSleep_IntimateCheckHugsMsg auto const
Message property DTSleep_IntimateCheckHugNoSitMsg auto const		; added v2.24
Message property DTSleep_IntimateCheckHugsLastHugMsg auto const
Message property DTSleep_IntimateCheckHugsRecentMsg auto const
Message property DTSleep_IntimateCheckHugsChanceMsg auto const
Message property DTSleep_IntimateCheckSecondLovMsg auto const
Message property DTSleep_IntimateCheckSecondOtherMsg auto const	; added v2.35
Message property DTSleep_IntimateCheckMidSleepMsg auto const		; added v2.35
Message property DTSleep_IntimateCheckMidSleepHrsMsg auto const
Message property DTSleep_PersuadeSoonPromptMsg auto const
Message property DTSleep_SleepImmersiveRatePromptMsg auto const 	; v2.35 first-time ask for rate
EndGroup

Group E_Messages_Creature
Message property DTSleep_ChairCheckDogBonusMsg auto const
Message property DTSleep_ChairCheckDogNoBonusMsg auto const
Message property DTSleep_ChairCheckDogRecentMsg auto const
Message property DTSleep_ChairCheckDogNPCMsg auto const
Message property DTSleep_ChairCheckDogTrainedMsg auto const
Message property DTSleep_IntimacySuccessStrongPrefMsg auto const
Message property DTSleep_IntimacySuccessStrongOnlyMsg auto const
Message property DTSleep_IntimacySuccessStrongAMsg auto const
Message property DTSleep_IntimacySuccessStrongBMsg auto const
Message property DTSleep_IntimacySuccessDogPrefMsg auto const
Message property DTSleep_IntimacySuccessDogOnlyMsg auto const
Message property DTSleep_IntimacySuccessDogAMsg auto const
Message property DTSleep_IntimacySuccessDogBMsg auto const
Message property DTSleep_IntimacySuccessDogTrainedMsg auto const
Message property DTSleep_IntimateStrongCheckMsg auto const
{ for Strong companion }
Message property DTSleep_IntimateStrongCheckBonusMsg auto const
{ for Strong companion with treats }
Message property DTSleep_IntimateStrongCheckBonusPerfectMsg auto const
Message property DTSleep_IntimateStrongCheckBonusPoorMsg auto const
Message property DTSleep_IntimateStrongCheckBonusRiskyMsg auto const
Message property DTSleep_IntimateCheckStrongNearbyMsg auto const
Message property DTSleep_IntimateCheckStrongNearbyMaxMsg auto const
Message property DTSleep_IntimateStrongCheckPerfectMsg auto const
Message property DTSleep_IntimateStrongCheckPoorMsg auto const
Message property DTSleep_IntimateStrongCheckRiskyMsg auto const
Message property DTSleep_IntimateStrongIntroMsg auto const
Message property DTSleep_IntimateStrongIntroPoorMsg auto const
Message property DTSleep_IntimateStrongIntroRiskyMsg auto const
Message property DTSleep_IntimateCheckStrongHLGoodMsg auto const
Message property DTSleep_IntimateCheckStrongHLPoorMsg auto const
Message property DTSleep_IntimateCheckStrongHLRiskyMsg auto const
Message property DTSleep_IntimateDogmeatCheckMsg auto const
Message property DTSleep_IntimateCheckDogmeatNearbyMsg auto const
Message property DTSleep_IntimateCheckDogmeatNearbyMaxMsg auto const
Message property DTSleep_IntimateDogmeatCheckTrainedMsg auto const
Message property DTSleep_IntimateDogmeatCheckTrainedPerfectMsg auto const
Message property DTSleep_IntimateDogmeatCheckTrainedPoorMsg auto const
Message property DTSleep_IntimateDogmeatCheckTrainedRiskyMsg auto const
Message property DTSleep_IntimateDogmeatCheckTrainedBonusMsg auto const
Message property DTSleep_IntimateDogmeatCheckTrainedBonusPerfectMsg auto const
Message property DTSleep_IntimateDogmeatCheckTrainedBonusPoorMsg auto const
Message property DTSleep_IntimateDogmeatCheckTrainedBonusRiskyMsg auto const
Message property DTSleep_IntimateDogmeatCheckBonusMsg auto const
Message property DTSleep_IntimateDogmeatCheckBonusPerfectMsg auto const
Message property DTSleep_IntimateDogmeatCheckBonusPoorMsg auto const
Message property DTSleep_IntimateDogmeatCheckBonusRiskyMsg auto const
Message property DTSleep_IntimateDogmeatBeginMsg auto const
Message property DTSleep_IntimateCheckRecentDogMsg auto const
Message property DTSleep_IntimateCheckRecentDogHourMsg auto const
Message property DTSleep_IntimateCheckRecentDogFailMsg auto const
EndGroup

Group F_NPC_IntimacyBonus
FormList property DTSleep_BoozeTreatsList auto const
FormList property DTSleep_CandyTreatsList auto const
FormList property DTSleep_DogTreatsList auto const
FormList property DTSleep_DogSuperTreatsList auto const
FormList property DTSleep_MutantTreatsList auto const
FormList property DTSleep_MutfruitList auto const
FormList property DTSleep_SynthTreatList auto const
Message property DTSleep_IntimateCheckBribeMutfruitMsg auto const
Message property DTSleep_IntimateCheckBribeMutfruitPoorMsg auto const
Message property DTSleep_IntimateCheckBribeMutfruitRiskyMsg auto const
Message property DTSleep_IntimateCheckBribeBoozeMsg auto const
Message property DTSleep_IntimateCheckBribeBoozePoorMsg auto const
Message property DTSleep_IntimateCheckBribeBoozeRiskyMsg auto const
Message property DTSleep_IntimateCheckBribeCandyMsg auto const
Message property DTSleep_IntimateCheckBribeCandyPoorMsg auto const
Message property DTSleep_IntimateCheckBribeCandyRiskyMsg auto const
Message property DTSleep_IntimateCheckBribeSynthTreatMsg auto const
Message property DTSleep_IntimateCheckBribeSynthTreatPoorMsg auto const
Message property DTSleep_IntimateCheckBribeSynthTreatRiskyMsg auto const
EndGroup


;Group V_FX
;ImageSpaceModifier property DTSleep_FadeDownISM auto
;ImageSpaceModifier property HoldAtBlackImod auto const
;ImageSpaceModifier property FadefromBlackImod auto const
;EndGroup

; hidden properties
Actor property IntimateCompanionRef auto hidden							; current lover
Actor property IntimateCompanionSecRef auto hidden						; current 2nd lover for bed or scene
ObjectReference property SleepBedInUseRef auto hidden      				; bed actually sleeping in
ObjectReference property SleepBedCompanionUseRef auto hidden
ObjectReference property SleepBedRegistered auto hidden					; bed registered to sleep to check if switched beds
ObjectReference property SleepBedTwin auto hidden						; neareast bed to check in case player activates it instead of own bed
ObjectReference property SleepBedDogPlacedRef auto hidden				; for Dogmeat to sleep on when no doghouse around
bool property IsUndressReady auto hidden
bool property SleepBedUsesBlock = false auto hidden						; to remember to re-block (mods like Campsite use this)
bool property SleepBedUsesSpecialAnims = false auto hidden				; bed has its own activate animations
bool property SleepBedIsPillowBed = false auto hidden
int property PropActivatorLock = 0 auto hidden							; used by prop activators to check lock to prevent double-tap
float property LastRadDamTime auto hidden								; check if unsafe to use bed
float property LastGameSaveTime auto hidden								; to limit saving too often
int property IntimateCheckFailCount auto hidden							; fail attempts not including self/dog-play
float property IntimateCheckLastFailTime auto hidden					; when last fail in game-time
float property IntimateCheckLastDogFailTime auto hidden					; when last fail in game-time
IntimateLocationHourSet property IntimateCheckAreaScore auto hidden		; hold to reduce re-check frequency if recently activated bed in same area
int property IntimacySceneCount auto hidden
int property IntimacyTestCount auto hidden
int property PipboyMenuCloseType auto hidden
bool property DogmeatSetWait = false auto hidden						; if Dogmeat has been told to wait
int property MessageOnWakeID = -1 auto hidden							; record message id to display on next wake
int property MessageOnRestID = -1 auto hidden							; for next rest
int property MessageOnRestTipID = -1 auto hidden
float property NoticeFriskyLastShown = 1.0 auto hidden					; not used -- intended for arousal feature
int property SleepBedNapHourCount = 0 auto hidden						; for resume Rest
int property SleepIntimateSceneAffinityOnSleepID auto hidden
int property SleepLoverBonusOnSleepID = -1 auto hidden
int property PersuadeTutorialShown auto hidden							; limit tutorial messages
int property PersuadeTutorialFailShown = 0 auto hidden
int property PersuadeTutorialSuccessShown = 0 auto hidden
int property PersuadeTutorialXFFShown auto hidden
int property TipSleepModeDisplayCount auto hidden
int property TipSleepModePromptVal = 0 auto hidden
int property TipBuildStrongBedDisplayCount = 0 auto hidden
float property IntimateSucPrevTime auto hidden
int property TotalBusyDayCount auto hidden
int property TotalExhibitionCount auto hidden


; ********************************************
; *****           variables      ***********
;
int TestVersion = -2 const		; should not be positive for normal release
string myScriptName = "[DTSleep_MainQuest]" const
int InitTimerID = 10 const
int SaveOnSleepTimerID = 11 const
int PlayerBedTimeTimerID = 13 const
int ExitBedHandleTimerID = 14 const
int FadeInTimerID = 15 const
int CheckCustomArmorsTimerID = 16 const
int BedEncounterTimerID = 17 const
int RadiationDamageTimerID = 19 const
int DogmeatSetWaitTimerID = 21 const
int ExitSeatHandleTimerID = 22 const			; v3.03
int LoverBonusAddTimerID = 45 const
int LoverAffinityCheckTimerID = 46 const
int LoverPerkGameTimerID = 101 const
int LoverDogPerkGameTimerID = 102 const
int LoverStrongPerkGameTimerID = 103 const
int SleepNapRecGameTimerID = 104 const
int SleepNapLimitGameTimerID = 105 const
int SleepNapFatGameTimerID = 106 const
int TipSleepModeTimerID = 110 const
int MsgOnRestTimerID = 111 const
int CustomCameraTipTimerID = 112 const
int IntroRestNotShowTipTimerID = 113 const
int AnimationErrorAAFTimerID = 114 const
int IntimateRestedPerkTimerID = 115 const
int IntimateRestedAddTimerID = 116 const
int DisableSleepDogPlacedTimerID = 117 const
int PlayerSleepPerkTimerID = 118 const
int UndressedInitTipTimerID = 119 const
int AAFDisabledMsgTimerID = 120 const
int IntimateEmbracePerkTimerID = 121 const
int IntimateEmbraceAddTimerID = 122 const
int IntimateExhibitionGameTimerID = 123 const
int IntimateBusyDayGameTimerID = 124 const
int IntimateSexyAddTimerID = 125 const
int IntimateSexyPerkTimerID = 126 const
int IntimateRestedCoffAddTimerID = 127 const
int PlayerPrefSceneViewPickTimerID = 128 const					; for player pick preference scene view type v2.70
int IntimateSceneCancelRetryTimerID = 129 const					; for unable to play scene v2.73
int IntimateSceneCancelRetryPATimerID = 130 const				; ...
int PlayerPrefSceneIgnorePickTimerID = 131 const				; for player pick ignore scene
int PlayerUndressID = 201 const
int CompanionUndressID = 202 const
int CompanionRedressID = 203 const
int DanceID = 204 const
int PlayerUndressSleepID = 205 const
int CompanionGlitchTestID = 206 const
int CreatureTypeDog = 2 const
int CreatureTypeStrong = 1 const
int CreatureTypeSynth = 3 const
int CreatureTypeSynthNude = 4 const
int CreatureTypeBehemoth = 5 const
int CreatureTypeHandy = 6 const
int IntimateDogTrainEXPLimit = 32 const
int IntimateDogTrainHourLimit = 21 const
int IntimateBribeNaked = 299 const
int IntimateBribeTypeMutfruit = 301 const
int IntimateBribeTypeBooze = 302 const
int IntimateBribeTypeMeat = 304 const
int IntimateBribeTypeDogTreat = 305 const
int IntimateBribeTypeCandy = 306 const
int IntimateBribeSynthTreat = 307 const
int IntimateLocChancePerfectScore = 31 const
int IntimateLocChanceGoodScore = 15 const
int IntimateLocChancePoorScore = -5 const
int LocActorChanceSettled = 10 const
int LocActorChanceOwned = 12 const
int LocActorChanceTownNice = 22 const
int LocActorChanceTown = 20 const
int LocActorChanceHugs = 19 const
int LocActorChanceWild = 0 const
int LocActorChanceInterior = 8 const
int OnWakeMsgStartTour = 100 const
int OnWakeMsgStartDogTrain = 102 const
int OnWakeMsgDiseaseInfectionSTD = 103 const
int OnRestMsgCompBedBusy = 401 const
int OnRestMsgCompBedNotFound = 402 const
int OnRestMsgCompBedBuggy = 403 const
int OnRestMsgCompBedClaimed = 406 const
int OnRestMsgTipFailPersuadeID = 404 const
int OnRestMsgTipSuccessPersuadeID = 405 const


InputEnableLayer SleepInputLayer
int processingDogmeatWait
bool FadeIsFadedOut = false
float IntimateLastEmbraceTime
float IntimateLastTime
int IntimacySMCount
int IntimacyDogCount
int IntimacyDayCount
;float PfTime = 0.10
int MyNextSceneOnSameFurnitureIsFreeSID = -1
bool MyMenuCheckBusy
int MyPAGlitchMessageCount								; v2.75 limit messages
int MyPAGlitchTipCount									; and limit tip



; ********************************************
; *****           events          *********
;
Event OnQuestInit()
	
	float gameTime = Utility.GetCurrentGameTime()
	DTSleep_SettingModActive.SetValue(0.1)  ; prepare to init
	
	(SleepPlayerAlias as DTSleep_PlayerAliasScript).CheckF4SEMCM()
	
	CheckVRMode()
	
	DTSleep_IntimateUndressQuestP.Start()  ; start now and always run
	IntimacyDogCount = 0
	IntimacySMCount = 0
	IntimacySceneCount = 0
	IntimacyDayCount = 0
	TotalBusyDayCount = 0
	TotalExhibitionCount = 0
	MyMenuCheckBusy = false
	MyPAGlitchMessageCount = 0
	MyPAGlitchTipCount = 0
	
	SetModDefaultSettingsForGame()
	
	if (gameTime > 2.1)
		; started mid-game so set last intimate time to yesterday
		; marks mod start time to delay granting bonus for 0-EXP-no-intimate until day-limit reached
		gameTime -= 1.0
		
		IntimateLastEmbraceTime = gameTime - 1.01
		IntimateLastEmbraceScoreTime = gameTime - 1.0
		IntimateLastTime = gameTime - 1.0
		IntimateSucPrevTime = gameTime - 1.0
		DTSleep_IntimateTime.SetValue(gameTime)
		DTSleep_IntimateDogTime.SetValue(gameTime)
	else
		IntimateLastEmbraceTime = gameTime
		IntimateLastEmbraceScoreTime = gameTime
		IntimateLastTime = gameTime
		IntimateSucPrevTime = gameTime - 0.01
	endIf
	
	(SleepPlayerAlias as DTSleep_PlayerAliasScript).UpdateSleepWear()
	; compatibility check happens in InitSleepQuest
	
	; let game finish showing other notifications before showing our welcome message
	
	StartTimer(4.5, InitTimerID) 
EndEvent

Event OnTimer(int aiTimerID)	

	if (aiTimerID == InitTimerID)
	
		if (MQ101.IsRunning() && !MQ101.IsCompleted())
			; intro -- wait until later
			; let wait for MQ102 stage event
			RegisterforRemoteEvent(MQ102, "OnStageSet")
			DTDebug(" intro MQ101 running - wait to init", 1)

		elseIf (MQ102.IsRunning() && MQ102.GetStageDone(10) == false)
			; let wait for stage event
			RegisterforRemoteEvent(MQ102, "OnStageSet")
			DTDebug(" still in vault 111 intro - wait to init", 1)
		else
			InitSleepQuest()
		endIf
	elseIf (aiTimerID == AnimationErrorAAFTimerID)
		DisplayErrorAAF()
		
	elseIf (aiTimerID == CustomCameraTipTimerID)
		DisplayTipCamera()
		
	elseIf (aiTimerID == IntroRestNotShowTipTimerID)
		DisplayTipRestNoShow()
		
	elseIf (aiTimerID == TipSleepModeTimerID)
		DisplayTipSleepMode()
		
	elseIf (aiTimerID == MsgOnRestTimerID)
		CheckMessageOnRest()
		
	elseIf (aiTimerID == PlayerSleepPerkTimerID)
		PlayerSleepPerkAdd()    ; restore activate
		
	elseIf (aiTimerID == BedEncounterTimerID)
		SetPlayerSleepEncounter(SleepBedInUseRef, IntimateCompanionRef, IntimateCompanionRef)
		
	elseIf (aiTimerID == RadiationDamageTimerID)
		RegisterForRadiationDamageEvent(PlayerRef)
		
	elseIf (aiTimerID == FadeInTimerID)
		FadeInFast(false)
	
	elseIf (aiTimerID == IntimateRestedAddTimerID)
		LoverBonusRested(true, true)
	elseIf (aiTimerID == IntimateRestedCoffAddTimerID)
		LoverBonusRestedCoffin(true, true)
	elseIf (aiTimerID == IntimateEmbraceAddTimerID)
		LoverBonusEmbrace(true, true)
	elseIf (aiTimerID == IntimateSexyAddTimerID)
		LoverSexyBonus(true, true)
		
	elseIf (aiTimerID == LoverBonusAddTimerID)
		CheckLoverBonusAdd()
		
	elseIf (aiTimerID == LoverAffinityCheckTimerID)
		CheckCompanionIntimateAffinity()
		
	elseIf (aiTimerID == ExitBedHandleTimerID)
		HandleExitBed()
	elseIf (aiTimerID == ExitSeatHandleTimerID)
		HandleExitSeat()
		
	elseIf (aiTimerID == DogmeatSetWaitTimerID)
		SetDogmeatWait()
		
	elseIf aiTimerID == CheckCustomArmorsTimerID
		CheckCustomGear()
		
	elseIf (aiTimerID == DisableSleepDogPlacedTimerID)
		if (SleepBedDogPlacedRef != None)
			DTSleep_CommonF.DisableAndDeleteObjectRef(SleepBedDogPlacedRef, false, true)
			SleepBedDogPlacedRef = None
		endIf
		
	elseIf (aiTimerID == AAFDisabledMsgTimerID)
		DTSleep_AAFDisableMessage.Show()
		
	elseIf (aiTimerID == SaveOnSleepTimerID)
	
		; not used
	elseIf (aiTimerID == UndressedInitTipTimerID)
		
		if (DTSleep_SettingNotifications.GetValue() > 0.0)
			DTSleep_UndressInitMessage.Show()
		endIf
		
	elseIf (aiTimerID == PlayerPrefSceneViewPickTimerID)
		; v2.70
		ShowSceneViewPreferencePicker()
	elseIf (aiTimerID == IntimateSceneCancelRetryPATimerID)
		; v2.73
		DTSleep_SceneCancelReplayPAMsg.Show()
	elseIf (aiTimerID == IntimateSceneCancelRetryTimerID)
		; v2.73
		DTSleep_SceneCancelReplayMsg.Show()
	elseIf (aiTimerID == PlayerPrefSceneIgnorePickTimerID)
		; v2.73
		ShowSceneIgnorePreferencePicker()
	endIf
EndEvent

Event OnTimerGameTime(int aiTimerID)

	if (aiTimerID == LoverPerkGameTimerID)
		
		LoverBonus(false)
	elseIf (aiTimerID == LoverDogPerkGameTimerID)
		LoverBonusDog(false)
	elseIf (aiTimerID == LoverStrongPerkGameTimerID)
		LoverBonusStrong(false)
	elseIf (aiTimerID == IntimateRestedPerkTimerID)
		LoverBonusRested(false)
	elseIf (aiTimerID == IntimateEmbracePerkTimerID || aiTimerID == IntimateSexyPerkTimerID)
		LoverBonusEmbrace(false)
	elseIf (aiTimerID == SleepNapLimitGameTimerID)
		PlayerSleepAwake(true)
	elseIf (aiTimerID == IntimateExhibitionGameTimerID)
		if (PlayerRef.HasPerk(DTSleep_ExhibitionPerk))
			PlayerRef.RemovePerk(DTSleep_ExhibitionPerk)
		endIf
	elseIf (aiTimerID == IntimateBusyDayGameTimerID)
		if (PlayerRef.HasPerk(DTSleep_BusyDayPerk))
			PlayerRef.RemovePerk(DTSleep_BusyDayPerk)
		endIf
	endIf
EndEvent

;
;	This runs immediately so don't assume Perk fragment is finished 
;   Sleep registration will (eventually) cancel when game PlayerSleepQuest stops.
;
Event Perk.OnEntryRun(Perk DTSleep_PlayerSleepBedPerk, int Fragment_Entry_01, ObjectReference akTarget, Actor akOwner)

	DTDebug(" Perk OnEntryRun ID " + Fragment_Entry_01 + " on " + akTarget, 1)
	
	
	if (LastRadDamTime <= 0.0)
		; init radiation check for CanPlayerPerformRest or CanPlayerRestRadDam
		; register here first time to start process - register again by timer or long period to avoid spam
		RegisterForRadiationDamageEvent(PlayerRef)
		Utility.Wait(0.05)
	endIf

	if (Fragment_Entry_01 == 0)
		; container
		
		if (akTarget.HasKeyword(DTSleep_OutfitContainerKY))
			if (akOwner == PlayerRef && DTSleep_PlayerUsingBed.GetValue() <= 0.5)
				; only player intended, but be safe
				
				if (DTSleep_PlayerUsingBed.GetValue() == 0.50)
					ResetAll()
					Utility.Wait(0.1)
				endIf
				
				HandlePlayerActivateOutfitContainer(akTarget)
			endIf
		endIf
		
	elseIf (akOwner != PlayerRef)
		; only player intended, but let's be safe
		Debug.Trace(myScriptName + " -- Perk OnEntry -- not player!!")
		
		return
	elseIf (Fragment_Entry_01 == 19)
		; locker door
		HandlePlayerActivateFurniture(akTarget, 106)
		
	elseIf (Fragment_Entry_01 == 16)
		; workbenches - armor or weapon  --- v2.70
		HandlePlayerActivateFurniture(akTarget, 5)
		
	elseIf (Fragment_Entry_01 == 15)
		; jail door - lock taken care of by perk
		if (akTarget.GetAngleX() > 20.0 || akTarget.GetAngleX() < -20.0 || akTarget.GetAngleY() > 20.0)
			DTDebug("jail door angles: " + akTarget.GetAngleX() + ", " + akTarget.GetAngleY(), 2)
			PlayerRef.SayCustom(PlayerHackFailSubtype)
		else
			HandlePlayerActivateFurniture(akTarget, 105)
		endIf
	elseIf (Fragment_Entry_01 == 14)
		; picnic table
		; v2.41 removed rad-dam check
		HandlePlayerActivateFurniture(akTarget, 104)
	
	elseIf (Fragment_Entry_01 == 13 || Fragment_Entry_01 == 18)		; 18 for Leito-only limited chairs player naked  v2.73
		; chair/stool/sofa naked Relax++
		; v2.41 removed rad-dam check
		HandlePlayerActivateFurniture(akTarget, 2, true)
		
	elseIf (Fragment_Entry_01 == 12)
		; sedan
		HandlePlayerActivateFurniture(akTarget, 102)
		
	elseIf (Fragment_Entry_01 == 11)
		; PA station
		; v2.41 removed rad-dam check
		HandlePlayerActivateFurniture(akTarget, 4)
		
	elseIf (Fragment_Entry_01 == 10)
		; desk
		; v2.41 removed rad-dam check
		HandlePlayerActivateFurniture(akTarget, 3)
		
	elseIf (Fragment_Entry_01 == 9)
		; chairs - no sex Relax - allow hugs with radiation damage
		HandlePlayerActivateFurniture(akTarget, -5)
		
	elseIf (Fragment_Entry_01 == 8)
		; Torture Device - pillory
		; v2.41 removed rad-dam check
		HandlePlayerActivateFurniture(akTarget, 1)
		
	elseIf (Fragment_Entry_01 == 7 || Fragment_Entry_01 == 17)	; 17,18 for Leito-only limited chairs v2.73
		; v2.77 fix to include 18 for naked
		; chairs Relax+
		; v2.41 removed rad-dam check
		HandlePlayerActivateFurniture(akTarget, 2)

		
	elseIf (Fragment_Entry_01 == 6)
		; pillory activate - ZaZ
		; v2.41 removed rad-dam check
		HandlePlayerActivateFurniture(akTarget, 1)
		
		
	elseIf (Fragment_Entry_01 == 5 && DTSleep_PlayerUsingBed.GetValue() >= 1.0)
		; Awaken activate
		
		if (SleepBedInUseRef != None)
			
			SleepBedInUseRef.Activate(PlayerRef)
		else
			DTDebug("Awaken activate and player using bed, but no bed -- reset all", 1)
			ResetAll()
		endIf
		
	else
		; ID 1 is normal bed Rest activate, ID 2 is naked (no slot 33), ID 3 is 'Intimate' activation on special bed
		; ID 4 is undress check
		bool isNaked = false
		bool isSpecialAnimBed = false
		SleepBedIsPillowBed = false
		
		if (Fragment_Entry_01 == 2)
			isNaked = true
		elseIf (Fragment_Entry_01 == 3)
			; this bed has its own activate animations (Sleep Anywhere camp bedroll)
			isSpecialAnimBed = true
		endIf
		
		if (Fragment_Entry_01 != 3 && (DTSConditionals as DTSleep_Conditionals).IsHZSHomebuilderActive >= 1 && akTarget != None)
			Form baseForm = akTarget.GetBaseObject()
			
			if (baseForm != None && (SleepPlayerAlias as DTSleep_PlayerAliasScript).DTSleep_BedPillowBedList.HasForm(baseForm))
				SleepBedIsPillowBed = true
			endIf
		endIf
		
		ValidatePerks()
		
		PipboyMenuCloseType = -1
		
		int checkVal = DTSleep_CaptureExtraPartsEnable.GetValueInt()
		
		; v2.48.1 - rad-check before bed
		bool doRadCheck = true
		float radResist = PlayerRef.GetValue(RadResistExposureAV)
		int radLimVal = DTSleep_SettingRadCheck.GetValueInt()
		float radLimit = 20.0
		if (radLimVal == 2)
			radLimit = 40.0
		elseIf (radLimVal == 3)
			radLimit = 60.0
		elseIf (radLimVal >= 4)
			radLimit = 100.0
		endIf
		
		if (radResist >= radLimit)
			doRadCheck = false
			DTDebug("CanPlayerPerformRest disable Rad-Check for radResist = " + radResist + " and limit = " + radLimit, 1)
		elseIf (radLimVal <= 1)
			doRadCheck = false
			DTDebug("CanPlayerPerformRest disable Rad-Check for setting", 1)
		endIf
		
		if (checkVal <= 0 && IsUnsafeToRestBed(akTarget))
		
			DTDebug(" no rest (sleep instead) bed placed: " + akTarget, 1)
			akTarget.Activate(PlayerRef)
			
		elseIf (checkVal > 0 || CanPlayerPerformRest(akTarget, doRadCheck))
		
			; player can't active double-bed if NPC in marker 0 or 1
			if (checkVal > 0)
				HandlePlayerActivateBed(akTarget, isNaked, isSpecialAnimBed)
				
			elseIf (!isSpecialAnimBed && akTarget.IsFurnitureInUse(false) && DTSleep_SettingNapOnly.GetValue() <= 0.0)
				; check if romantic companion
				Actor actorInBed = GetCompanionInLoveUsingBed(akTarget)
				if (actorInBed)
					DTDebug("  Activate normal Sleep with companion for bed, " + akTarget, 2)

					akTarget.Activate(PlayerRef)
				else
					DTSleep_BedBusyMessage.Show()
				endIf
				
			elseIf (isSpecialAnimBed && (!akTarget.IsFurnitureMarkerInUse(0, false) || !akTarget.IsFurnitureMarkerInUse(1, false)))
				HandlePlayerActivateBed(akTarget, isNaked, true)
				
			elseIf (!akTarget.IsFurnitureInUse(false))
				HandlePlayerActivateBed(akTarget, isNaked, isSpecialAnimBed)
			else
				DTSleep_BedBusyMessage.Show()
			endIf 
		endIf
	endIf
	if (SirTime != 2.290 && DTSleep_SceneTestMode.GetValueInt() != 0)
		float days = Utility.GetCurrentGameTime() - SirTime
		if (days > 28.5)
			DTSleep_SceneTestMode.SetValue(0.0)
		endIf
	endIf
EndEvent

; health recover interrupted
;
Event DTSleep_HealthRecoverQuestScript.RestInterruptionEvent(DTSleep_HealthRecoverQuestScript akSender, Var[] akArgs)
	Utility.Wait(0.08)
	DTDebug(" Got RestInterruptionEvent ", 2)
	
	UnregisterForCustomEvent((DTSleep_HealthRecoverQuestP as DTSleep_HealthRecoverQuestScript), "RestInterruptionEvent")
	
	int interupteType = akArgs[0] as int
	
	if (interupteType == 0)
		; full sleep reached - set done or warnings
		
		if (DTSleep_SettingNapExit.GetValue() >= 1.0)
			DTDebug(" full-sleep interrupt - done", 2)
			
			CancelTimerGameTime(SleepNapLimitGameTimerID)
			
			if (DTSleep_PlayerUsingBed.GetValue() >= 1.0 && SleepBedInUseRef != None)
				
				PlayerSleepAwake(true)
			endIf
		else
			Utility.Wait(0.4)
			if (DTSleep_PlayerUsingBed.GetValue() >= 1.0 && SleepBedInUseRef != None)
				RegisterForCustomEvent((DTSleep_HealthRecoverQuestP as DTSleep_HealthRecoverQuestScript), "RestInterruptionEvent")
				
				; always show notice even if disabled
				DTSleep_OversleepMsg.Show((DTSleep_HealthRecoverQuestP as DTSleep_HealthRecoverQuestScript).HourCount)
				
			endIf
		endIf
		
	elseIf (DTSleep_PlayerUsingBed.GetValue() >= 1.0 && SleepBedInUseRef != None)
		; incomplete rest - set cancel
		
		if ((DTSleep_HealthRecoverQuestP as DTSleep_HealthRecoverQuestScript).HourCount >= 1)
			LoverBonusRested(false)			; remove rested bonus
		endIf
		CancelTimerGameTime(SleepNapLimitGameTimerID)
		PlayerSleepAwake(false)
		if (interupteType == 2 && DTSleep_SettingNotifications.GetValue() > 0.0)
			Utility.Wait(1.0)
			DTSleep_RestPoorInterruptedMsg.Show()
		endIf
	endIf
	
EndEvent

; Intimate Anim done
;
Event DTSleep_IntimateAnimQuestScript.IntimateSequenceDoneEvent(DTSleep_IntimateAnimQuestScript akSender, Var[] akArgs)

	DTDebug(" Got IntimateSequenceDoneEvent ", 2)
	
	if (akArgs.Length >= 6)
	
		int doneStep = akArgs[4] as int
		int sceneID = -1
		if (akArgs.Length >= 7)
			sceneID = akArgs[6] as int
		endIf
		
		if (doneStep == 0)
			DTDebug("prepare to finish...", 2)
			EnablePlayerControlsSleep()
			
			return
		elseIf (doneStep < 0)
			; error starting scene
			DTDebug("error starting scene -- check and report if too many", 2)
			HandleIntimateAnimStartError(doneStep)
		else
			DisablePlayerControlsSleep(2)	; v2.40 no-move, no-look... was 3: move, no activate
		endIf
		
		UnregisterForCustomEvent((DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript), "IntimateSequenceDoneEvent")
		if ((DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SleepBedRef != None)
			; v2.28 fix -- was only unregister from beds down below in args
			UnregisterForRemoteEvent((DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SleepBedRef, "OnActivate")
		endIf
		
		; check to flag if player can add this scene to ignore list 
		if (sceneID > 0 && CanPlayerCustomIgnoreScene(sceneID))
			DTSleep_SIDIgnoreOK.SetValueInt(sceneID)
		else
			DTSleep_SIDIgnoreOK.SetValueInt(-1)
		endIf
	
		Actor mainActor = akArgs[0] as Actor
		ObjectReference bedRef = akArgs[2] as ObjectReference
		bool placeInBedRequested = akArgs[5] as bool
		self.SleepLoverBonusOnSleepID = 1
		bool undressStopped = false
		bool bedActivated = false
		bool redressSlowly = false
		bool activateBedOK = true				; if set false remember to stop undress
		bool sleepTime = (DTSleep_HealthRecoverQuestP as DTSleep_HealthRecoverQuestScript).SleepyPlayer
		bool nakedPlayer = (DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).IsUndressAll
		bool hasAAFBeenDisabled = false
		if ((DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).MSceneChangedAAFSetting == 0)
			hasAAFBeenDisabled = true
		endIf
		bool sceneWasCanceledbyPlayer = false	; v2.70 to keep track for showing Test-mode prompt
		
		if (DTSleep_PlayerUndressed.GetValueInt() <= 0)
			undressStopped = true
		endIf
		
		if (DTSleep_SpectatorQuestP.IsRunning())
			if ((DTSleep_SpectatorQuestP as DTSleep_SpectatorQuestScript).StopAll())
				; crime Committed  - Specator Quest handles message after timer
				DTDebug(" IntimateSequenceDoneEvent -- crime committed ", 1)
				if (SceneData.Interrupted <= 0)
					SceneData.Interrupted = 1
				endIf
			endIf
		endIf
		
		
		if (mainActor != None && mainActor == PlayerRef)
		
			bool needEnableControls = true
			bool fadedOut = false
			
			if (IntimateCompanionRef != None)
			
				DTDebug(" IntimateSequenceDoneEvent -- Set follower follow ", 2)
				
				IntimateCompanionRef.SetRestrained(false)
				IntimateCompanionRef.FollowerFollow()
				IntimateCompanionRef.EvaluatePackage(true)
				
				; swap roles back for next time?
				if (IntimateCompanionRef == SceneData.SecondMaleRole || IntimateCompanionRef == SceneData.SecondFemaleRole)
					DTDebug(" swapping roles back ", 2)
					SceneData.SameGender = true
					if (SceneData.MaleRole == PlayerRef)
						SceneData.FemaleRole = IntimateCompanionRef
					else
						SceneData.MaleRole = IntimateCompanionRef
						SceneData.MaleRoleGender = (DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).GetGenderForActor(IntimateCompanionRef)
					endIf
					
					SceneData.SecondFemaleRole = None
					SceneData.SecondMaleRole = None
				endIf
				
				if (IntimateCompanionRef == StrongCompanionRef)
					self.SleepLoverBonusOnSleepID = 3
					SceneData.IsCreatureType = CreatureTypeStrong
					Utility.Wait(0.1)
					IntimateCompanionRef = None
				elseIf (SceneData.IsCreatureType == CreatureTypeBehemoth)
					RestoreSceneData()
					IntimateCompanionRef = None
					if (SceneData.Interrupted <= 0)	; no go-to-bed
						SceneData.Interrupted = 1
					endIf
					
				elseIf (SceneData.IsCreatureType == CreatureTypeHandy)
					self.SleepLoverBonusOnSleepID = -2	; no bonus for robots
					RestoreSceneData()
					IntimateCompanionRef = None
					
				elseIf ((DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SceneIDIsSolo(sceneID))
					; no bonus for solo
					self.SleepLoverBonusOnSleepID = -2
				
				;elseIf (PlayerHasActiveDogmeatCompanion.GetValue() >= 1.0 && DogmeatCompanionAlias != None)
				;	Actor dogRef = DogmeatCompanionAlias.GetActorReference()
				;	
				;	if (dogRef != None && dogRef == IntimateCompanionRef)
				;		self.SleepLoverBonusOnSleepID = 2
				;		Utility.Wait(0.1)
				;		IntimateCompanionRef = None
				;	endIf
				endIf
				
			elseIf ((DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SceneIDIsSolo(sceneID))
				; no bonus for solo
				self.SleepLoverBonusOnSleepID = -2
				if (SceneData.BackupCurrentLoverScenCount > 0 && SceneData.CurrentLoverScenCount == 0 && SceneData.BackupMaleRole != None)
					RestoreSceneData()
				endIf
			else
				Debug.Trace(myScriptName + " on intimate done, but no IntimateCompanionRef!!!")
				self.SleepLoverBonusOnSleepID = -1
			endIf
			
			if (bedRef == None)
				if (sceneID < 100 || (sceneID >= 739 && sceneID <= 741) || sceneID == 780)
					; no bonus for hugs at chairs or sexy dance -- v2.83 added 780 -- or diner-booth embrace
					self.SleepLoverBonusOnSleepID = -2
					if (sceneID == 741 || sceneID < 90)
						; do we need to restore SceneData?
						if (SceneData.BackupCurrentLoverScenCount > 0 && SceneData.CurrentLoverScenCount == 0 && SceneData.BackupMaleRole != None)
							RestoreSceneData()
						endIf
					endIf
				endIf
			endIf
			
			
			bool doFadeIn = false
			bool inBed = (DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).PlaceInBedOnFinish
			
			
			
			;; ******************************** clear IntimateCompanionRef and quest *****************
			WakeStopIntimQuest(true)
			; ---------------------------------------------
			
			if (DTSleep_SettingDogRestrain.GetValue() >= 0.0 && DogmeatCompanionAlias != None)
				
				SetDogmeatFollow()
			endIf

			if ((DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).FadeEnable)
			
				; stop now if using sleep menu or no bed
				; we're fade-out to black right now so fade-in to view sleep menu unless going straight to bed
				
				fadedOut = true
				int intimatePrompt = DTSleep_SettingShowIntimateCheck.GetValueInt()
				
				
				if (bedRef != None && SceneData.AnimationSet != 8 && SceneData.Interrupted <= 0)
					
					if (SceneData.ToyFromContainer)
						; put back
						SceneData.ToyFromContainer = false
						if (bedRef.HasKeyword(DTSleep_OutfitContainerKY) && SceneData.ToyArmor != None)
							SceneData.MaleRole.RemoveItem(SceneData.ToyArmor, 1, true, bedRef)
						endIf
					endIf
				
					; v2.70.1 - added !inBed just in case
					; v2.74 -- include PlayAAFEnabled condition
					if (!inBed && SceneData.AnimationSet >= 5 && SceneData.AnimationSet < 12 && (IsAAFReady() || hasAAFBeenDisabled) && (DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).PlayAAFEnabled)
						; AAF scene end - do not go directly to bed! - use prompt if set
						DTDebug(" redress on end AAF scene...", 1)
						redressSlowly = true
						doFadeIn = true
						Utility.Wait(1.50)
						SetUndressStop(redressSlowly)
						undressStopped = true
						if (hasAAFBeenDisabled)
							StartTimer(2.0, AAFDisabledMsgTimerID)
						endIf
						
					elseIf (!SleepBedUsesSpecialAnims && DTSleep_SettingNapOnly.GetValue() <= 0.0 && !inBed)
						SetUndressStop(redressSlowly)
						undressStopped = true
						Utility.Wait(0.54)
						
						doFadeIn = true	; fade-in to get bed view and sleep menu
					else
						DTDebug(" nap only OR in bed -- undress SetStopOnExit", 2)
						Utility.Wait(0.24) ; ensure done with character
						
						if (intimatePrompt > 0 && !inBed && !placeInBedRequested)
							; not in bed (for some reason) so fade-in for prompt unless requested
							; interruptions handled later
							doFadeIn = true 
							
						endIf
						
						; do not fade-in until bed unless...
						; make sure okay to switch to bed--even if not in bed--so we know ready to move if not there yet
						if ((DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).SetStopOnBedExit() == false)
							DTDebug(" set undress SetStopOnBedExit failed  (UndressQuest no bed)... stopping undress", 1)
							; fails if undress quest didn't have a bed - so get dressed now
							
							SetUndressStop(redressSlowly)
							undressStopped = true
							Utility.Wait(1.0)
							
							doFadeIn = true
							
						elseIf ((DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).PlayerIsAroused)
						
							(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).CheckRemoveAllNudeSuits(PlayerRef)
						endIf
						
						if (SleepBedUsesSpecialAnims)
							doFadeIn = true
						endIf
					endIf
				else
					; no bed or interrupted scene
					undressStopped = true
					SetUndressStop(redressSlowly)
					if (redressSlowly)
						WaitForRedressAfterScene(2)
					endIf
					
					doFadeIn = true
					
				endIf
				
				if (doFadeIn)
				
					fadedOut = false
					
					DTDebug("IntimateSequenceDoneEvent -- Fade-in...", 2)
					
					FadeInFast(false)
					
					if ((DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).HoldToBlackIsSetOn)
						; stop now to release fade
						(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).StopAll(true)
					endIf
					
					if (redressSlowly)
						if (needEnableControls)
							EnablePlayerControlsSleep()
							Utility.Wait(0.05)
						endIf
						DisablePlayerControlsSleep(3) ; move and look only - shows notifications
						
						WaitForRedressAfterScene(7)
						
						EnablePlayerControlsSleep()
						needEnableControls = false
					endIf
					
					Utility.Wait(0.1)
					
					MainQSceneScriptP.GoSceneViewDone(true)
					Utility.Wait(0.4)
					
				endIf
				
				
			elseIf (DTSleep_SettingNapOnly.GetValue() <= 0.0 || SceneData.AnimationSet >= 5)
				; no fade enabled
				SetUndressStop(false)
				undressStopped = true
				fadedOut = false
				Utility.Wait(1.75)
			endIf
			
			if (bedRef != None)
			
				DTDebug("have a Bed, should we prompt for exit? -- Interrupted? " + SceneData.Interrupted, 2)
				
				if (SceneData.Interrupted <= 0 && SceneData.AnimationSet != 8)
				
					if (fadedOut)
						; need to ensure game-fade before stopping IntimateAnimQuest
						FadeOutFast(true)
						Utility.Wait(0.2)
					else
						; enable controls before activate bed
						EnablePlayerControlsSleep()
						needEnableControls = false
					endIf
					
					if (inBed)
						SleepBedInUseRef = bedRef
						DTSleep_PlayerUsingBed.SetValue(2.0)
					endIf
					
					; prompt for rest? (normal sleep menu is a prompt so only for immersive rest and not already in bed)
					; note: SleepBedUsesSpecialAnims not needed here any longer since before intimacy we set moveToBed = false
					;
					if (DTSleep_SettingNapOnly.GetValue() > 0.0 || SleepBedUsesSpecialAnims || !nakedPlayer)
					
						if (!inBed && !fadedOut && activateBedOK && DTSleep_SettingShowIntimateCheck.GetValueInt() > 0)
							
							int restCheck = 0
							
							; recheck
							if (!sleepTime && Game.GetDifficulty() >= 6 && PlayerRef.GetValue(HC_SleepEffectAV) >= 2.0)
								sleepTime = true
							endIf
							
							if (DTSleep_SettingNotifications.GetValueInt() >= 1 && OkayToSleepLocationBed(bedRef))
								if (sleepTime)
									restCheck = DTSleep_AfterIntimateRestNotSleepyPromptMsg.Show()
								else
									restCheck = DTSleep_AfterIntimateRestPromptMsg.Show()
								endIf
							else
								restCheck = 1
							endIf

							if (restCheck >= 1)
								DisablePlayerControlsSleep(2)
								
								activateBedOK = false
								if (!undressStopped)
									SetUndressStop(true)
									undressStopped = true
								endIf
								
								EnablePlayerControlsSleep()
							endIf
						endIf
					endIf
					
					if (activateBedOK && !SleepBedUsesSpecialAnims && DTSleep_SettingNapOnly.GetValue() > 0.0)
						
						; do nothing
						
					elseIf ((DTSConditionals as DTSleep_Conditionals).IsPlayerCommentsActive)
						ModPlayerCommentsEnable()
					endIf
					
					if (SleepBedUsesSpecialAnims)
						doFadeIn = true
					endIf
					
					if (activateBedOK)
						bedActivated = true
						
						DTDebug(" scene-done - ActivatePlayerSleep moveToBed?: " + !inBed, 2)
						
						ActivatePlayerSleepForBed(bedRef, SleepBedUsesSpecialAnims, !undressStopped, fadedOut, !inBed, true)
						
					endIf
				else
					
					DTDebug(" skip bed activate, interrupted? " + SceneData.Interrupted, 2)
					activateBedOK = false
					if (!undressStopped)
						SetUndressStop(redressSlowly)
					endIf
					
					if (redressSlowly)
						Utility.Wait(1.0)
					endIf
					
					; added v1.11
					fadedOut = false
					if ((DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).FadeEnable)
						FadeInFast(!redressSlowly)
					endIf
					
					WaitForRedressAfterScene()
					
					MainQSceneScriptP.GoSceneViewDone(true)
					
				endIf
			elseIf (SleepBedInUseRef != None)
				UnregisterForRemoteEvent(SleepBedInUseRef, "OnActivate")
			endIf
			
			if (SceneData.Interrupted == 50)
				; allow next free -v2.73
				MyNextSceneOnSameFurnitureIsFreeSID = (DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).DTSleep_IntimateIdleID.GetValueInt()
				if (MyNextSceneOnSameFurnitureIsFreeSID == 739)
					; lap dance no free redo
					MyNextSceneOnSameFurnitureIsFreeSID = -3
				endIf	
				DTSleep_AAFSceneSlowMessage.Show()

			elseIf (SceneData.Interrupted == 10)
				; allow next free -v2.73
				MyNextSceneOnSameFurnitureIsFreeSID = (DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).DTSleep_IntimateIdleID.GetValueInt()
				if (MyNextSceneOnSameFurnitureIsFreeSID == 739)
					; lap dance no free redo
					MyNextSceneOnSameFurnitureIsFreeSID = -3
				endIf	
				DTSleep_AAFSceneLockedMessage.Show()
				DTSleep_SettingAAF.SetValueInt(0)
				
			elseIf (SceneData.Interrupted == 7)								
				; player canceled v2.70
				; next scene on same furniture will auto-pass
				MyNextSceneOnSameFurnitureIsFreeSID = (DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).DTSleep_IntimateIdleID.GetValueInt()
				if (MyNextSceneOnSameFurnitureIsFreeSID == 739)
					; lap dance no free redo, but can modify view
					MyNextSceneOnSameFurnitureIsFreeSID = -3
				endIf	
				if (MyNextSceneOnSameFurnitureIsFreeSID >= 740 && MyNextSceneOnSameFurnitureIsFreeSID <= 741)
					; no scene view changes --- dance pole always free, dance not included
					MyNextSceneOnSameFurnitureIsFreeSID = -1
				elseIf (MyNextSceneOnSameFurnitureIsFreeSID < 100 && MyNextSceneOnSameFurnitureIsFreeSID != -3)
					; embrace and dances -- not expected to happen
					MyNextSceneOnSameFurnitureIsFreeSID = -1
					
				elseIf (CanPlayerCustomizeSceneView())					
					; allow to change Scene View preference 
					
					StartTimer(1.67, PlayerPrefSceneViewPickTimerID)
					
				elseIf (IntimacyTestCount < 3 && MyNextSceneOnSameFurnitureIsFreeSID >= 100 && DTSleep_SettingNotifications.GetValue() >= 1.0)
					DTSleep_SceneCancelReplayMsg.Show()
				endIf
			endIf
			
			(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).StopAll(false)
			
			if (!fadedOut && needEnableControls)
				EnablePlayerControlsSleep()
			endIf
			
			if (!bedActivated)
				if ((DTSConditionals as DTSleep_Conditionals).IsPlayerCommentsActive)
					ModPlayerCommentsEnable()
				endIf
				
				; happy notice - which otherwise displays in bed
				if (self.SleepLoverBonusOnSleepID > 0)
					StartTimer(5.5, LoverBonusAddTimerID)
				endIf
				
				if (self.MessageOnRestID > 0 || MyPAGlitchTipCount == 1)				; v2.75 include glitchTip
					CheckMessageOnRest()
				elseIf (self.MessageOnWakeID > 0)
					CheckMessages((SleepPlayerAlias as DTSleep_PlayerAliasScript).CurrentLocation)
				endIf
			endIf
			
		else
			Debug.Trace(myScriptName + " NO Actor!! ")
			FadeInFast(false)
			MainQSceneScriptP.GoSceneViewDone(true)
			EnablePlayerControlsSleep()
	
		endIf
	else
		Debug.Trace(myScriptName + " wrong arg count: " + akArgs.Length)
	endIf
EndEvent

; only register with player
Event OnRadiationDamage(ObjectReference akTarget, bool abIngested)	
	if (!abIngested)
		LastRadDamTime = Utility.GetCurrentGameTime()
		
		; chance to interrupt sleep
		if (DTSleep_PlayerUsingBed.GetValue() >= 1.0 && SleepBedInUseRef != None && DTSleep_HealthRecoverQuestP.IsRunning())
			; beware of player just entered bed - bad to knock out straight away
			; v1.55 - check if sleep started
			;
			if ((DTSleep_HealthRecoverQuestP as DTSleep_HealthRecoverQuestScript).SleepStarted)
				if (DTSleep_SettingRadCheck.GetValueInt() >= 1)
					int chanceLim = 12
					float radResist = PlayerRef.GetValue(RadResistExposureAV)
					if (radResist >= 60.0)				; v2.48.1 - added 60
						chanceLim = 3
					elseIf (radResist >= 32.0)
						chanceLim = 6		
					elseIf (radResist >= 16.0)
						chanceLim = 9		
					endIf
					
					if (Utility.RandomInt(1, 50) < chanceLim)
						
						SleepBedInUseRef.Activate(PlayerRef)
						
						if (DTSleep_SettingNotifications.GetValue() > 0.0)
							Utility.Wait(1.0)
							DTSleep_RadInterruptSleepMsg.Show()
						endIf
					endIf
				endIf
			endIf
		endIf
	endIf
	; wait to re-register as damage lasts a few seconds (catch event immediately) 
	;  and we check based on time since
	StartTimer(12.0, RadiationDamageTimerID)
EndEvent

Event ObjectReference.OnActivate(ObjectReference akSender, ObjectReference akActionRef)
	Utility.Wait(0.02)
	
	if (akActionRef != PlayerRef)
	
		DTDebug(" this furniture " + akSender + " activated by " + akActionRef, 2)
		UnregisterForRemoteEvent(akSender, "OnActivate")			; v2.28 always unregister now
		
		if (DTSleep_PlayerUsingBed.GetValue() >= 1.0 && SleepBedInUseRef != None && SleepBedInUseRef == akSender)
			; get out of bed!!
			DTDebug(" forcing player out of bed on activation by " + akActionRef, 2)
			SleepBedInUseRef.Activate(PlayerRef)
			
		elseIf ((DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SceneIsPlaying)
			
			; is same furniture? v2.28
			if (akSender == (DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SleepBedRef)
				(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).CancelScene()
			endIf
		endIf
		
	elseIf (SleepBedInUseRef != None && akSender != SleepBedInUseRef)
		DTDebug(" player activate nearby bed", 1)
		; player activated nearby bed we registered to -- does not fire OnExit event for sleep bed
		UnregisterForRemoteEvent(SleepBedInUseRef, "OnExitfurniture")
		UnregisterForRemoteEvent(SleepBedInUseRef, "OnActivate")

		if (SleepBedTwin != None)
			UnregisterForRemoteEvent(SleepBedTwin, "OnActivate")
			SleepBedTwin = None
		endIf
		
		(DTSleep_EncounterQuestP as DTSleep_EncounterQuest).StopAll()
		SetUndressStop(false)

		HandleOnExitFurniture(SleepBedInUseRef)
		
	elseIf (akActionRef == PlayerRef && SleepBedInUseRef != None)
		UnregisterForRemoteEvent(SleepBedInUseRef, "OnActivate")
		
	endIf
EndEvent

Event ObjectReference.OnExitFurniture(ObjectReference akSender, ObjectReference akActionRef)
	; if player activates nearby bed instead of this one, player exits without this event
	
	UnregisterForRemoteEvent(akSender, "OnExitfurniture")
	UnregisterForRemoteEvent(akSender, "OnActivate")
	if (SleepBedTwin != None)
		UnregisterForRemoteEvent(SleepBedTwin, "OnActivate")
		SleepBedTwin = None
	endIf
		
	; normal for bed exit
	if ((DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).UndressedForType >= 5)
		; equip system had initialized
		StartTimer(6.5, UndressedInitTipTimerID)
	endIf

	HandleOnExitFurniture(akSender)
EndEvent

; Pip-boy close
;
Event OnMenuOpenCloseEvent(string asMenuName, bool abOpening)
	if (asMenuName == "WorkshopMenu")

		if (abOpening)
			PlayerSleepPerkRemove()
			
			if (DTSleep_SettingModActive.GetValue() >= 1.0 && TipBuildStrongBedDisplayCount <= 0 && DTSleep_IntimateStrongExp.GetValueInt() >= 1)
				if (DTSleep_AdultContentOn.GetValue() >= 2.0 && (DTSConditionals as DTSleep_Conditionals).IsSavageCabbageActive)
					Utility.Wait(1.5)
					if ((DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).GetGenderForActor(PlayerRef) == 1)
						DisplayTipBuildStrongBed()
					endIf
				endIf
			endIf
			
		else
			PlayerSleepPerkAdd()
		endIf
		
    elseIf (asMenuName== "PipboyMenu" && !abOpening)
		
		DTDebug(" Pip-boy close event", 2)
		
		UnregisterForMenuOpenCloseEvent("PipboyMenu")
		
		if (PipboyMenuCloseType == PlayerUndressID)
			PipboyMenuCloseType = -2
			
			GoSetUndressPlayerNaked()
			
		elseIf (PipboyMenuCloseType == CompanionUndressID)
		
			GoSetUndressCompanionForSleep()
			
		elseIf (PipboyMenuCloseType == CompanionRedressID)
		
			RedressCompanion()
		
		elseIf (PipboyMenuCloseType == CompanionGlitchTestID)
		
			IsCompanionPowerArmorGlitchedDisplayNearby()
			
		elseIf (PipboyMenuCloseType == DanceID)
		
			Utility.Wait(0.2)

			IntimateCompanionSet companionSet = GetCompanionNearbyHighestRelationRank(false)
			Actor compActorRef = None
			if (companionSet != None && companionSet.CompanionActor != None)
				compActorRef = companionSet.CompanionActor
			endIf
			
			bool compRomance = false					; for romantic dance or regular   v3.0 
			
			if (companionSet.HasLoverRing || companionSet.RelationRank >= 4)
				compRomance = true
				
				SetUndressAndFadeForIntimateScene(compActorRef, None, 3, true, lowCam = false)
			endIf
			
			
			if ((DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).PlayActionDancing(compRomance))

				RegisterForCustomEvent((DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript), "IntimateSequenceDoneEvent")
			endIf
		endIf	
	endIf
EndEvent

; SleepQuest event (base game) - start sleep
Event OnPlayerSleepStart(float afSleepStartTime, float afDesiredSleepEndTime, ObjectReference akBed)
	SleepBedInUseRef = None

	if (akBed.IsFurnitureMarkerInUse(0) && akBed.IsFurnitureMarkerInUse(1))
		DTDebug("  OnSleepStart--bed in use, so ignore", 2)
		
		return
	EndIf
	if (PlayerRef.GetAnimationVariableBool("IsFirstPerson"))
		;DTSleep_WasPlayerThirdPerson.SetValue(-1.0)
	else
		;DTSleep_WasPlayerThirdPerson.SetValue(1.0)
		Game.ForceFirstPerson()
		PlayerRef.SetAnimationVariableBool("IsFirstPerson", true)
	endIf
	
	float desiredSleepTime = DTSleep_CommonF.GetGameTimeHoursDifference(afSleepStartTime, afDesiredSleepEndTime)
	
	HandlePlayerSleepStart(desiredSleepTime, akBed)

	return
EndEvent

;
; SleepQuest event - remember other quests (including mods) checking Stop event.
;   - PlayerSleepScript.OnPlayerSleepStop checks well-rested
;   - another event auto-save game which we don't want to interrupt or hide
;
Event OnPlayerSleepStop(bool abInterrupted, ObjectReference akBed)
	Utility.Wait(0.2)
	UnregisterForPlayerSleep()

	if (akBed != None)
		UnregisterForRemoteEvent(akBed, "OnActivate")
	endIf
	
	; check enabled and 3D since some mods take bed away (which breaks some base-game features)
	;  - bed may be taken away after this causing issue
	;  v2.28 - disallow MorningSex mod
	if (!abInterrupted && !(DTSConditionals as DTSleep_Conditionals).IsMorningSexActive && !PlayerRef.IsInCombat())
	
		Location currentLoc = (SleepPlayerAlias as DTSleep_PlayerAliasScript).CurrentLocation
		bool observeWinter = true
		if (akBed != None)
			if (akBed.IsOwnedBy(PlayerRef))
				observeWinter = false
			elseIf (currentLoc != None && currentLoc.HasKeyword(LocTypeWorkshopSettlementKY))
				if (IsObjBelongPlayerWorkshop(akBed) > 0)
					; this check takes time so only check if location has KY
					observeWinter = true
				endIf
			endIf
		endIf

		HandlePlayerSleepStop(akBed, observeWinter)
		
	else
		; done using bed
		if (abInterrupted)
			DTDebug(" OnSleepStop interrupted...", 2)
			DTSleep_SleepInterruptedSleepStopMsg.Show()
			
		;elseIf (akBed == None || !akBed.IsEnabled() || !akbed.Is3DLoaded())
			; v2.13; v2.28 - skip this report
		;	DTDebug(" OnSleepStop no bed!", 1)
		endIf
		
		DTSleep_PlayerUsingBed.SetValue(0.0)
		if (DTSleep_PlayerUndressed.GetValue() > 0.0)
			SetUndressStop(false)
		endIf
		
		; happy notice - which otherwise displays in bed
		if (self.SleepLoverBonusOnSleepID > 0)
			StartTimer(5.5, LoverBonusAddTimerID)
		endIf
		
	endIf 
EndEvent

Event Quest.OnStageSet(Quest akSender, int auiStageID, int auiItemID)
	if (akSender == MQ102 && auiStageID >= 10)
		if (DTSleep_SettingModActive.GetValue() < 2.0)
			DTDebug("MQ102 stage set - delay start 12 seconds", 1)
			; give player a few seconds before initializing
			StartTimer(12.0, InitTimerID)
		endIf
	endIf
EndEvent


; **********************************************
; *** intended external functions for holotape
;

Function CaptureBackpackEquipToMark()
	
	DTSleep_CaptureBackpackEnable.SetValue(Utility.GetCurrentGameTime())
endFunction

Function CaptureBackpackUnmarkCurrent()
	
	Armor bpItem = (DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).UndressPlayerPackOrPouch(true)
	if (bpItem != None)
		DTSleep_CaptureBackpackEnable.SetValue(Utility.GetCurrentGameTime())
		Utility.WaitMenuMode(0.3)
		PlayerRef.EquipItem(bpItem, false, true)
	endIf
endFunction


Function CaptureIntimateApparelEquipToMark()
	
	
	Actor myCompanion = None
	if (CompanionAlias)
		myCompanion = CompanionAlias.GetActorReference()
	elseIf ((DTSConditionals as DTSleep_Conditionals).IsHeatherCompanionActive)
		Actor heatherActor = GetHeatherActor()
		if (heatherActor.GetDistance(PlayerRef) < 1000)
			myCompanion = heatherActor
		endIf
	endIf
	
	if (myCompanion != None)
		
		(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).SetMonitorCompanionEquip(myCompanion)
	endIf
	
	DTSleep_CaptureIntimateApparelEnable.SetValue(Utility.GetCurrentGameTime())
endFunction

; v2.48
Function CaptureIntimateApparelSetGlovesIncluded()
	if (DressData.PlayerEquippedIntimateAttireItem != None)
		(SleepPlayerAlias as DTSleep_PlayerAliasScript).DTSleep_SleepAttireHandsList.AddForm(DressData.PlayerEquippedIntimateAttireItem)
		
		DTSleep_PlayerEquipSleepGloveCount.SetValueInt(1)
	endIf

endFunction

; v2.48
Function CaptureIntimateApparelSetGlovesNone()

	if (DressData.PlayerEquippedIntimateAttireItem != None && DTSleep_PlayerEquipSleepGloveCount.GetValue() > 0.0)
		(SleepPlayerAlias as DTSleep_PlayerAliasScript).DTSleep_SleepAttireHandsList.RemoveAddedForm(DressData.PlayerEquippedIntimateAttireItem)
		
		Utility.WaitMenuMode(0.1)
		if ((SleepPlayerAlias as DTSleep_PlayerAliasScript).DTSleep_SleepAttireHandsList.HasForm(DressData.PlayerEquippedIntimateAttireItem) == false)
			DTSleep_PlayerEquipSleepGloveCount.SetValueInt(0)
		endIf
	endIf

endFunction

Function CaptureIntimateApparelUnmarkCurrent()

	Armor item = (DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).UndressPlayerIntimateItem(true)
	if (item != None)
		DTSleep_CaptureIntimateApparelEnable.SetValue(Utility.GetCurrentGameTime())
		Utility.WaitMenuMode(0.3)
		PlayerRef.EquipItem(item, false, true)
	endIf
endFunction

; v2.48
Function CaptureSleepApparelSetGlovesIncluded()
	if (DressData.PlayerEquippedSleepwearItem != None)
		(SleepPlayerAlias as DTSleep_PlayerAliasScript).DTSleep_SleepAttireHandsList.AddForm(DressData.PlayerEquippedSleepwearItem)
		DTSleep_PlayerEquipSleepGloveCount.SetValueInt(1)
	endIf

endFunction

; v2.48
Function CaptureSleepApparelSetGlovesNone()

	if (DressData.PlayerEquippedSleepwearItem != None)
		(SleepPlayerAlias as DTSleep_PlayerAliasScript).DTSleep_SleepAttireHandsList.RemoveAddedForm(DressData.PlayerEquippedSleepwearItem)
		Utility.WaitMenuMode(0.1)
		if ((SleepPlayerAlias as DTSleep_PlayerAliasScript).DTSleep_SleepAttireHandsList.HasForm(DressData.PlayerEquippedSleepwearItem) == false)
			DTSleep_PlayerEquipSleepGloveCount.SetValueInt(0)
		endIf
	endIf

endFunction

Function CaptureJacketEquipToMark()
	
	DTSleep_CaptureJacketEnable.SetValue(Utility.GetCurrentGameTime())
endFunction

Function CaptureJacketUnmarkCurrent()
	
	Armor bpItem = (DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).UndressPlayerJacket(true)
	if (bpItem != None)
		DTSleep_CaptureJacketEnable.SetValue(Utility.GetCurrentGameTime())
		Utility.WaitMenuMode(0.3)
		PlayerRef.EquipItem(bpItem, false, true)
	endIf
endFunction

Function CaptureMaskEquipToMark()
	
	DTSleep_CaptureMaskEnable.SetValue(Utility.GetCurrentGameTime())
endFunction

Function CaptureMaskUnmarkCurrent()
	
	Armor bpItem = (DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).UndressPlayerMask(true)
	if (bpItem != None)
		DTSleep_CaptureMaskEnable.SetValue(Utility.GetCurrentGameTime())
		Utility.WaitMenuMode(0.3)
		PlayerRef.EquipItem(bpItem, false, true)
	endIf
endFunction

; v2.80 ---------------------------------
Function CaptureShoesEquipToMark()

	DTSleep_CaptureShoeEnable.SetValue(Utility.GetCurrentGameTime())
endFunction

Function CaptureShoeUnmarkCurrent()
	Armor bpItem = (DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).UndressPlayerShoes(true)
	if (bpItem != None)
		DTSleep_CaptureShoeEnable.SetValue(Utility.GetCurrentGameTime())
		Utility.WaitMenuMode(0.3)
		PlayerRef.EquipItem(bpItem, false, true)
	endIf
endFunction

Function CaptureStockingsEquipToMark()
	DTSleep_CaptureStockingsEnable.SetValue(Utility.GetCurrentGameTime())
endFunction

Function CaptureStockingsUnmarkCurrent()
	Armor bpItem = (DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).UndressPlayerStockings(true)
	if (bpItem != None)
		DTSleep_CapturestockingsEnable.SetValue(Utility.GetCurrentGameTime())
		Utility.WaitMenuMode(0.3)
		PlayerRef.EquipItem(bpItem, false, true)
	endIf
endFunction

; ----------------------------

Function CaptureStrapOnItemEquipToMark()
	
	DTSleep_CaptureStrapOnEnable.SetValue(Utility.GetCurrentGameTime())
endFunction

Function CaptureStrapOnUnmarkCurrent()
	Armor item = (DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).UndressPlayerStrapOn(true)
	if (item != None)
		DTSleep_CaptureStrapOnEnable.SetValue(Utility.GetCurrentGameTime())
		Utility.WaitMenuMode(0.3)
		PlayerRef.EquipItem(item, false, true)
	endIf
endFunction

Function CaptureSleepwearEquipToMark()
	
	Actor myCompanion = None
	if (CompanionAlias)
		myCompanion = CompanionAlias.GetActorReference()
	elseIf ((DTSConditionals as DTSleep_Conditionals).IsHeatherCompanionActive)
		Actor heatherActor = GetHeatherActor()
		if (heatherActor.GetDistance(PlayerRef) < 1000)
			myCompanion = heatherActor
		endIf
	endIf
	
	if (myCompanion)

		(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).SetMonitorCompanionEquip(myCompanion)
	endIf
	
	DTSleep_CaptureSleepwearEnable.SetValue(Utility.GetCurrentGameTime())
endFunction

Function CaptureSleepwearUnmarkCurrent()
	
	Armor sleepItem = (DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).UndressPlayerSleepwear(true)
	
	if (sleepItem)
		DTSleep_CaptureSleepwearEnable.SetValue(Utility.GetCurrentGameTime())
		Utility.WaitMenuMode(0.3)
		PlayerRef.EquipItem(sleepItem, false, true)
	endIf
endFunction

Function CheckCompanionDress()
	
	if ((DTSConditionals as DTSleep_Conditionals).IsAAFActive && ActiveCompanionCollectionAlias != None) 
	
		int count = ActiveCompanionCollectionAlias.GetCount()
		int idx = 0
		DTDebug("checking nude suits - ActiveCompanion Count: " + count, 2)
		
		while (idx < count)
	
			Actor activeComp = ActiveCompanionCollectionAlias.GetAt(idx) as Actor
			
			if (activeComp == StrongCompanionRef || SceneData.IsCreatureType == CreatureTypeBehemoth)
				;DTDebug("skipping " + activeComp, 2)
			elseIf (activeComp && !activeComp.IsDead() && !activeComp.IsUnconscious())
				
					
				(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).CheckRemoveAllNudeSuits(activeComp, false)
			endIf
			
			idx += 1
		endWhile
	endIf
		
	
endFunction

; ************************************************

Function CheckLocation(Location oldLoc, Location newLoc)

	float modActiveVal = DTSleep_SettingModActive.GetValue()
	
	if (modActiveVal >= 2.0)			; v1.62 - 2 means initialized
		CheckMessages(oldLoc)
		
		if (newLoc == Vault111Loc)
			PlayerSleepPerkRemove()

		elseIf (oldLoc != None && oldLoc == Vault111Loc)
			PlayerSleepPerkAdd()
		elseIf (!PlayerRef.HasPerk(DTSleep_PlayerSleepBedPerk))
			if (DTSleep_DebugMode.GetValueInt() > 0)
				Debug.Trace(myScriptName + " missing Sleep Perk!! - added back")
			endIf
			PlayerSleepPerkAdd()
		endIf
	else
		Debug.Trace(myScriptName + " Check Loc - mod disabled")
		return
	endIf
	
	; not implemented
	if (DTSleep_SettingTestMode.GetValue() >= 2.0 && DTSleep_IntimateEXP.GetValue() > 4.0 && DTSleep_SettingIntimate.GetValue() > 0.0 && DTSleep_SettingNotifications.GetValue() > 0.0)
	
		;Frisky notices
		
		Utility.Wait(2.5)
		float gameTime = Utility.GetCurrentGameTime()
		
		float hoursSinceNoticeShown = DTSleep_CommonF.GetGameTimeHoursDifference(gameTime, NoticeFriskyLastShown)
		float daysSinceLastIntimate = gameTime - IntimateLastTime
		
		if (hoursSinceNoticeShown > 8.0 && daysSinceLastIntimate > 0.9)
			
			int friskyScore = PlayerFriskyScore(gameTime)
			
			DTDebug("friskyScore " + friskyScore + "; daysSince: " + daysSinceLastIntimate + "; HourOfDay: " + DTSleep_CommonF.GetGameTimeCurrentHourOfDayFromCurrentTime(gameTime), 1)
			
			if (friskyScore >= 25)
				
				int sexySpotScore = LocationScoreByFriskyScore(friskyScore, newLoc)
				
				bool companionIsInLove = false
				
				if (CompanionAlias != None)
					CompanionActorScript aCompanion = CompanionAlias.GetActorReference() as CompanionActorScript
					
					if (aCompanion && aCompanion.IsRomantic())
					
						companionIsInLove = true
					endIf
				endIf
				
				Utility.Wait(3.0)
			
				if (sexySpotScore > 10 && (companionIsInLove || DTSleep_PrivateLocationList.HasForm(newLoc)))
				
					DTSleep_FriskyForLocationMessage.Show()
					NoticeFriskyLastShown = gameTime
					
				elseIf (sexySpotScore > 0 && friskyScore >= 25 && friskyScore <= 60)
				
					DTSleep_FriskyFeelingMessage.Show()
					NoticeFriskyLastShown = gameTime
					
				elseIf (sexySpotScore > 0 && friskyScore > 60)
				
					DTSleep_FriskyNeedMessage.Show()
					NoticeFriskyLastShown = gameTime
				endIf
			endIf
		endIf
	endif
	
endFunction

Function CheckCompanionIntimateAffinity()

	if (self.SleepIntimateSceneAffinityOnSleepID > 0)
		Actor comp1 = None
		Actor comp2 = None
		
		if (SceneData.MaleRole != None && SceneData.MaleRole != PlayerRef)
			comp1 = SceneData.MaleRole
		elseIf (SceneData.FemaleRole != None && SceneData.FemaleRole != PlayerRef)
			comp1 = SceneData.FemaleRole
		endIf
		if (SceneData.SecondMaleRole != None)
			comp2 = SceneData.SecondMaleRole
		else
			comp2 = SceneData.SecondFemaleRole
		endIf
		
		if (self.SleepIntimateSceneAffinityOnSleepID == 3)
			(DTSleep_IntimateAffinityQuest as DTSleep_IntimateAffinityQuestScript).AffinityIntimateSceneStrongPublic()
		elseIf (self.SleepIntimateSceneAffinityOnSleepID == 2)
			(DTSleep_IntimateAffinityQuest as DTSleep_IntimateAffinityQuestScript).AffinityIntimateSceneDogPublic()
		else
			(DTSleep_IntimateAffinityQuest as DTSleep_IntimateAffinityQuestScript).AffinityIntimateScenePublic(comp1, comp2)
		endIf
	endIf
	
	self.SleepIntimateSceneAffinityOnSleepID = -2

endFunction

Function CheckLoverBonusAdd(bool notify = true)

	if (self.SleepLoverBonusOnSleepID > 0)
		Utility.Wait(0.5)
		
		if (self.SleepLoverBonusOnSleepID == 1)
			LoverBonus(true, notify)
			
		elseIf (self.SleepLoverBonusOnSleepID == 2)
			LoverBonusDog(true, notify)
			
		elseIf (self.SleepLoverBonusOnSleepID == 3)
			LoverBonusStrong(true, notify)
		elseIf (self.SleepLoverBonusOnSleepID == 4)
			LoverBonusRestedCoffin(true, notify)
		endIf
	endIf
	
	self.SleepLoverBonusOnSleepID = -2
endFunction

int Function CheckMessages(Location aLoc)
	int result = 0
	
	CheckMessageTipPersuasion()
	
	if (self.MessageOnWakeID > 0)
		Utility.Wait(0.8)
		
		if (self.MessageOnWakeID == OnWakeMsgStartDogTrain)
			result = OnWakeMsgStartDogTrain
			DTSleep_DogTrainQuestP.Start()
			(DTSleep_DogTrainQuestP as DTSleep_DogTrainQuestScript).UpdateTrainingCount()
		elseIf (self.MessageOnWakeID == OnWakeMsgStartTour)
			result = OnWakeMsgStartTour

			DTSleep_IntimateTourQuestP.Start()
			if (aLoc != None)
				(DTSleep_IntimateTourQuestP as DTSleep_IntimateTourQuestScript).CheckLocation(aLoc)
			endIf
		elseIf (self.MessageOnWakeID == OnWakeMsgDiseaseInfectionSTD)
		
			if (HC_Rule_DiseaseEffects.GetValue() == 1.0)
				result = OnWakeMsgDiseaseInfectionSTD

				(DT_PotionHandleQuestP as DT_PotionHandleQuestScript).TryEquipPotion_Global(DTSleep_DiseaseEffect_Infection)

			endIf
		endIf
		
		self.MessageOnWakeID = 0
	endIf
	
	; in case missed when player cancels sleep
	if (self.SleepLoverBonusOnSleepID > 0)
		StartTimer(8.2, LoverBonusAddTimerID)
	endIf
	
	return result
endFunction

int Function CheckMessageOnRest()
	int result = 0
	bool wakeCompanion = false
	
	if (CheckMessageTipPersuasion() <= 0)
		if (DTSleep_RestCount.GetValueInt() >= 1 && TipSleepModeDisplayCount == 2)
		
			Utility.Wait(8.0)
			if (DTSleep_PlayerUsingBed.GetValue() >= 1.0)
				TipSleepModeDisplayCount = 3
				DTSleep_SleepImmersiveTip2Msg.ShowAsHelpMessage("Rest", 6, 30, 1)
			endIf
		endIf
	endIf
	
	if (self.MessageOnRestID == IntimateEmbracePerkTimerID)

		if (DTSleep_SettingNotifications.GetValueInt() > 0)
			StartTimer(5.0, IntimateEmbraceAddTimerID)
		else
			LoverBonusEmbrace(true, false)
		endIf
	elseIf (self.MessageOnRestID == IntimateSexyPerkTimerID)
		if (DTSleep_SettingNotifications.GetValueInt() > 0)
			StartTimer(5.0, IntimateSexyAddTimerID)
		else
			LoverSexyBonus(true, false)
		endIf
	elseIf (self.MessageOnRestID == OnRestMsgCompBedBusy)
		result = OnRestMsgCompBedBusy
		if (DTSleep_SettingNotifications.GetValue() > 0.0 && DTSleep_PlayerUsingBed.GetValue() >= 1.0)
			if (DTSleep_CompSleepQuest.IsRunning() && DTSleep_CompSleepAlias != None)

				DTSleep_NapCompBedBusyMsg.Show()
			endIf
		endIf
		wakeCompanion = true 
		
	elseIf (self.MessageOnRestID == OnRestMsgCompBedClaimed)
		result = OnRestMsgCompBedClaimed
		if (DTSleep_SettingNotifications.GetValue() > 0.0 && DTSleep_PlayerUsingBed.GetValue() >= 1.0)
			if (DTSleep_CompSleepQuest.IsRunning() && DTSleep_CompSleepAlias != None)

				DTSleep_NapCompBedClaimedMsg.Show()
			endIf
		endIf
		wakeCompanion = true
			
	elseIf (self.MessageOnRestID == OnRestMsgCompBedNotFound)
		result = OnRestMsgCompBedNotFound
		if (DTSleep_SettingNotifications.GetValue() > 0.0 && DTSleep_PlayerUsingBed.GetValue() >= 1.0)
			if (DTSleep_CompSleepQuest.IsRunning() && DTSleep_CompSleepAlias != None)

				DTSleep_NapCompNoBedMsg.Show()
			endIf
		endIf
		wakeCompanion = true
		
	elseIf (self.MessageOnRestID == OnRestMsgCompBedBuggy)
		result = OnRestMsgCompBedBuggy
		if (DTSleep_SettingNotifications.GetValue() > 0.0 && DTSleep_PlayerUsingBed.GetValue() >= 1.0)
			if (DTSleep_CompSleepQuest.IsRunning() && DTSleep_CompSleepAlias != None)

				DTSleep_NapCompBedBugMsg.Show()
			endIf
		endIf
		wakeCompanion = true
		
	elseIf (MyPAGlitchTipCount == 1)
		; tip activated   - v2.75
		DisplayTipPAGlitch()
	endIf
	
	if (wakeCompanion)
		if (DTSleep_DogSleepAlias == None)
			WakeIntimateCompanion()
		else
			if (DTSleep_CompSleepAlias != None)
				DTSleep_CompSleepAlias.Clear()
			endIf
			if (DTSleep_CompSecondSleepAlias != None)
				DTSleep_CompSecondSleepAlias.Clear()
			endIf
			if (IntimateCompanionRef != None)
				IntimateCompanionRef.RemoveFromFaction(DTSleep_IntimateFaction)
				IntimateCompanionRef.EvaluatePackage(true)
				IntimateCompanionRef = None
			endIf
		endIf
	endIf
	
	self.MessageOnRestID = -2
	
	return result
endFunction

int Function CheckVRMode()
	
	; Does this work? assumed Form 0xB7DB3 a VR-game keyword
	; https://forums.nexusmods.com/topic/9660828-anyone-with-vr-modding-experience-specifically-from-a-scripting-point-of-view/
	;
	if (DTSleep_VR.GetValue() <= 1.0 && (Game.GetForm(0x50377) as Furniture).HasKeyword(Game.GetForm(0xB7DB3) as Keyword))
	
		DTSleep_VR.SetValue(3.0)
		return 3
	else
		; not a VR game
		DTSleep_VR.SetValue(-1.0)
	endIf

	return 0
endFunction

int Function CheckMessageTipPersuasion()

	int result = 0
	if (self.MessageOnRestTipID == OnRestMsgTipFailPersuadeID)
		PersuadeTutorialFailShown += 1
		if (PersuadeTutorialFailShown == 1)
			DTSleep_PersuadeFailMessage.ShowAsHelpMessage("Rest", 6.0, 30.0, 1)
		elseIf (PersuadeTutorialFailShown == 2)
		
			if (IntimateCheckFailCount > 0)
				DTSleep_PersuadeFailOftenMessage.ShowAsHelpMessage("Rest", 6.0, 30.0, 1)
			else
				DTSleep_PersuadeFailLocMessage.ShowAsHelpMessage("Rest", 6.0, 30.0, 1)
			endIf
		endIf
		result = PersuadeTutorialFailShown
		
	elseIf (self.MessageOnRestTipID == OnRestMsgTipSuccessPersuadeID)
		PersuadeTutorialSuccessShown += 1
		DTSleep_PersuasionSuccessTipMsg.ShowAsHelpMessage("Rest", 7.0, 30.0, 1)
		result = 1
	endIf
	
	self.MessageOnRestTipID = -2

	return result
endFunction

Function EnteredCombatInBed()
	DTDebug(" EnteredCombatInBed", 2)
	
	if (DTSleep_PlayerUsingBed.GetValue() >= 1.0 && SleepBedInUseRef != None)
	
		SleepBedInUseRef.Activate(PlayerRef)
		
		if (DTSleep_SettingNotifications.GetValue() > 0.0)
			Utility.Wait(1.0)
			DTSleep_SleepInterruptedMsg.Show()
		endIf

	endIf
endFunction

Function EnteredSwimmingState()
	
	if (PlayerRef.IsInFaction(DTSleep_MutantAllyFaction))
		Utility.Wait(2.5)
		DTSleep_RemoveMutantAllySpell.Cast(PlayerRef, PlayerRef)
	endIf
endFunction

Function GoCompanionRedress()
	PipboyMenuCloseType = CompanionRedressID
	RegisterForMenuOpenCloseEvent("PipboyMenu")
endFunction

Function GoCompanionRedressMCM()
	if (!MyMenuCheckBusy)
		MyMenuCheckBusy = true
		RedressCompanion()
		MyMenuCheckBusy = false
	endIf
endFunction

Function GoNearbyCompanionInLoveNaked()
	IntimateCompanionSet companionSet = GetCompanionNearbyHighestRelationRank(true)

	(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).AltFemBodyEnabled = false

	SetUndressForManualStop(true, companionSet.CompanionActor, false, companionSet.RequiresNudeSuit, None, false, false, true, false)
endFunction

Function GoNearbyCompanionInLoveUndressForBed()

	PipboyMenuCloseType = CompanionUndressID
	RegisterForMenuOpenCloseEvent("PipboyMenu")
endFunction

Function GoNearbyCompanionInLoveUndressForBedMCM()
	GoSetUndressCompanionForSleep()
endFunction

Function GoSetUndressCompanionForSleep()
	if (!MyMenuCheckBusy)
		MyMenuCheckBusy = true
		Utility.Wait(0.2)					
		IntimateCompanionSet companionSet = GetCompanionNearbyHighestRelationRank(false)

		if (companionSet.CompanionActor != None)
			SetUndressForCompanionSleepwear(companionSet.CompanionActor, companionSet.RequiresNudeSuit)
		else
			DTSleep_CompanionNotFoundMsg.Show()
		endIf
		
		MyMenuCheckBusy = false
	endIf
endFunction

Function GoTestNearbyCompanionPowerArmorGlitched()						; v2.74

	PipboyMenuCloseType = CompanionGlitchTestID
	RegisterForMenuOpenCloseEvent("PipboyMenu")
endFunction

Function GoPlayerNaked()
	
	if (PlayerRef.WornHasKeyword(ArmorTypePower))
		
		pPowerArmorNoActivate.Show()
		return 
	endIf
	PipboyMenuCloseType = PlayerUndressID
	RegisterForMenuOpenCloseEvent("PipboyMenu")
endFunction

Function GoPlayerNakedMCM()
	if (!MyMenuCheckBusy)
		MyMenuCheckBusy = true
		if (PlayerRef.WornHasKeyword(ArmorTypePower))
			
			pPowerArmorNoActivate.Show()
			return 
		endIf
		GoSetUndressPlayerNaked()
		MyMenuCheckBusy = false
	endIf
endFunction

Function GoDance()
	
	if (PlayerRef.WornHasKeyword(ArmorTypePower))
		
		pPowerArmorNoActivate.Show()
		return 
	endIf
	PipboyMenuCloseType = DanceID
	RegisterForMenuOpenCloseEvent("PipboyMenu")
endFunction

Function GoSetUndressPlayerNaked()

	EnablePlayerControlsSleep()
	Utility.Wait(0.05)
	
	DisablePlayerControlsSleep()
	
	GoThirdPerson(true)

	Utility.Wait(0.52)
	
	if (IsUndressCheckRequested())
	
		SetUndressForCheck(true, None)
	else
		SetUndressForNoStop()
	endIf
	
	EnablePlayerControlsSleep()
endFunction

; ********************************************
; ******       regular    functions         *********
;

bool Function ActivatePlayerSleepForBed(ObjectReference bedRef, bool isSpecialAnimBed = false, bool playerNaked = false, bool isFadedOut = false, bool moveToBed = true, bool afterIntimacy = false)
	; Campsite by fadingsignal uses blocking for menu control
	; Sleep Together uses own anims and sleep system - no need to register
	bool result = true
	SleepBedUsesBlock = false
	
	DTDebug("ActivatePlayerSleepForBed " + bedRef + " special? " + isSpecialAnimBed + " moveToBed? " + moveToBed, 1)
	
	
	if (bedRef.IsActivationBlocked())
		DTDebug(" unblocking bed " + bedRef, 2)
		bedRef.BlockActivation(false)
		SleepBedUsesBlock = true
	endIf
	
	bool doActivateBed = true
	SleepBedNapHourCount = 0
	
	if (DTSleep_SettingNapOnly.GetValue() > 0.0 && moveToBed && !afterIntimacy && !isSpecialAnimBed && bedRef.HasKeyword(DTSleep_OutfitContainerKY))
	
		HandlePlayerActivateOutfitContainer(bedRef, true)
		Utility.Wait(0.5)
	endIf
	
	if (isSpecialAnimBed)

		MainQSceneScriptP.GoSceneViewStart(1, true)		; for sleep to force 3rd-person except for FO4VR v3.02

		RegisterForRemoteEvent(bedRef, "OnExitFurniture")
		SleepBedInUseRef = bedRef
		StartTimer(5.8, BedEncounterTimerID)
		
		if (DTSleep_SettingNapOnly.GetValue() > 0.0)

			StartTimerGameTime(9.5, SleepNapLimitGameTimerID)
		endIf
		
		if (isFadedOut)
			FadeInFast(false)
		endIf
		
		; we do not call HandlePlayerSleepStop so let's start health recovery now
		if (!DTSleep_HealthRecoverQuestP.IsRunning())
			DTSleep_HealthRecoverQuestP.Start()
		endIf
		(DTSleep_HealthRecoverQuestP as DTSleep_HealthRecoverQuestScript).SetBedTypeCamping()
		
		
	elseIf (DTSleep_SettingNapOnly.GetValue() > 0.0 || !moveToBed)		; move normally true, but caller may force place in bed even for quick sleep
	
		doActivateBed = false
		
		if (OkayToSleepLocationBed(bedRef))		; v2.33 included moveToBed  ?? TODO:
			SleepBedRegistered = bedRef
			DTSleep_PlayerUsingBed.SetValue(2.0)
			
			float timeLimit = 6.12
			
			if (bedRef.HasKeyword(AnimFurnFloorBedAnims))
				timeLimit = 5.12
			endIf
			if (DTSleep_SettingNapExit.GetValue() >= 1.0)
				timeLimit += 4.13
			endIf
			StartTimerGameTime(timeLimit, SleepNapLimitGameTimerID)
			
			bool alwaysUndress = IsPlayerOkayToUndressForBed(4.0, bedRef, playerNaked)
			
			if (!DTSleep_TimeDayQuestP.IsRunning())
				DTSleep_TimeDayQuestP.Start()
			endIf
			
			if (DTSleep_SettingDogRestrain.GetValue() > 0.0)
				SetDogmeatWait(20, 1200, false)
			endIf
			
			HandlePlayerSleepStop(bedRef, !alwaysUndress, isFadedOut, moveToBed, afterIntimacy, playerNaked)
		else
			DTSleep_BedBusyMessage.Show()
		endIf
	else
		RegisterForSleepWithBed(bedRef)
	endIf
	
	if (doActivateBed)
	
		if (bedRef.Activate(PlayerRef))
			; mark using a bed
			if (isSpecialAnimBed)
				DTSleep_PlayerUsingBed.SetValue(1.0)
			else
				DTSleep_PlayerUsingBed.SetValue(0.5)	; v1.49 - partial - player may cancel sleep
			endIf
			
			if (SleepBedUsesBlock)
				; reset block in case cancel sleep--set again on sleep stop
				bedRef.BlockActivation(true)
			endIf
			
		else
			if (SleepBedUsesBlock)
				bedRef.BlockActivation(true)
				SleepBedUsesBlock = false
			endIf
			DTDebug(" failed to activate bed - unRegister -" + bedRef, 1)
			Utility.Wait(0.02)
			UnregisterForSleepBed(-1.0)
			
			if (DTSleep_PlayerUndressed.GetValue() > 0.0)
				SetUndressStop(true)
			endIf
			result = false
			
			if (DTSleep_HealthRecoverQuestP.IsRunning())
				(DTSleep_HealthRecoverQuestP as DTSleep_HealthRecoverQuestScript).StopAllCancel()
			endIf
			
			if (isFadedOut)
				FadeInFast(true)
			endIf
		endIf
		
	elseIf (isFadedOut)
		FadeInFast(true)
	endIf
	
	return result
EndFunction

bool Function CanPlayerCustomIgnoreScene(int sid)
	if (DTSleep_AdultContentOn.GetValueInt() >= 2)
		int lastSceneID = sid
		if (lastSceneID < 100)
			lastSceneID = (DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).DTSleep_IntimateIdleID.GetValueInt()
		endIf
		if (lastSceneID >= 100 && lastSceneID < 2000)
			if (!(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).GetIsOnIgnoreListSceneID(lastSceneID))
				; only if more than one scene for furniture...
				
				; v3.0 let's allow
				;if ((DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).GetLastSceneCount() > 1)
				;
					return true
				;endIf
			endIf
		endIf
	endIf
	
	return false
EndFunction

bool Function CanPlayerCustomizeSceneView()
	
	if (DTSleep_SettingTestMode.GetValueInt() >= 1 && DTSleep_AdultContentOn.GetValueInt() >= 2 && DTSleep_SettingCancelScene.GetValueInt() > 0)
		int dbVal = DTSleep_DebugMode.GetValueInt()
		
		if (dbVal != 2 && dbVal != 4 && SceneData.IntimateSceneViewType >= 3 && SceneData.IntimateSceneViewType <= 9 && (DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).DTSleep_SettingAACV.GetValueInt() == 1)
			if (DTSleep_SettingNotifications.GetValueInt() >= 1)
				return true
			endIf
		endIf
	endIf
	
	return false
EndFunction

;
;  The Perk activator displays warnings for power armor, encumbered, and combat, but
;  we must check here, too
;  v2.41 - may disable rad-damage check
;
bool Function CanPlayerPerformRest(ObjectReference onBedRef, bool doRadCheck = true)

	if (Game.IsActivateControlsEnabled())
		if (DTSleep_PlayerUsingBed.GetValue() == 0.0)
		
			; several of these should be excluded by the Perk, but let's all test just in case
			float heightLim = 64.0
			if (onBedRef != None)
				float bedHeight = onBedRef.GetPositionZ() - PlayerRef.GetPositionZ()
				if (bedHeight > heightLim)
					Debug.Trace(myScriptName + " bed height diff: " + bedHeight)
					DTSleep_NoRestBedHighMsg.Show()
					return false
				endIf
			endIf
			
			if (PlayerRef.WornHasKeyword(ArmorTypePower))
				
				pPowerArmorNoActivate.Show()
				return false
			endIf
			
			; removing this for now
			;if (PlayerRef.HasKeyword(pAnimFaceArchetypeHappy) && PlayerRef.IsPlayingIdle())
			;	if (DTSleep_SettingTestMode.GetValueInt() > 0 && DTSleep_DebugMode.GetValue() >= 1.0)
			;		Debug.Trace(myScriptName + "  CanPlayerRest False - too happy")
			;	endIf
			;	DTSleep_NoRestMessage2.Show()
			;	
			;	return false
				
			if (PlayerRef.IsInCombat())
				
				DTSleep_NoRestMessage3.Show()
				return false
			endIf
			if (PlayerRef.IsOverEncumbered())
				DTSleep_NoRestMessage1.Show()
				return false
			endIf
			
			if (doRadCheck)
				if (CanPlayerRestRadDam() == false)
					return false
				endIf
			endIf
			
			if (PlayerRef.GetSitState() >= 2)			; v2.25 added since now using for non-perk entry
				return false
			endIf
			
			if (onBedRef != None)
				Form bedBase = onBedRef.GetBaseObject()
				if (bedBase != None && DTSleep_BedChildList.HasForm(bedBase))
					DTSleep_NoRestBedChildMsg.Show()
					Utility.Wait(0.05)
					return false
				endIf
			endIf
			
			; GetActorOwner() and GetActorOwner() on bed does not work on orange-text-owned beds
				;Actor owner = onBedRef.GetActorRefOwner()
				;ActorBase ownerBase = onBedRef.GetActorOwner()
			
		elseIf (SleepBedInUseRef != None)
			;Debug.Trace(myScriptName + " player already using bed; Activate: " + SleepBedInUseRef)
			; activate to get out
			SleepBedInUseRef.Activate(PlayerRef)
			return false
		else
			DTDebug(" player already using no bed -- reset flag", 1)
			UnregisterForSleepBed()
			Utility.WaitMenuMode(0.05)
			
			return CanPlayerPerformRest(onBedRef, doRadCheck)
		endIf
	else
		Debug.Trace(myScriptName + " CanPlayerRest: Player activate controls disabled")
		return false
	endIf
	
	return true 
EndFunction

bool Function CanPlayerRestRadDam()
	
	if (LastRadDamTime > 0.0)
		float curTime = Utility.GetCurrentGameTime()
		float difMin = DTSleep_CommonF.GetGameTimeHoursDifference(curTime, LastRadDamTime) * 60.0
		if (difMin < 6.0)
			
			;if (DTSleep_SettingTestMode.GetValueInt() <= 0 || DTSleep_DebugMode.GetValueInt() < 2)
				DTSleep_NoRestRadDamMsg.Show()
			
				return false
			;endIf
			
		elseIf (difMin > 10080.0)
			; been a week - re-register
			; been a week - re-register
			;DTDebug(" Re-register for rad damage event - been a week ", 2)
			
			UnregisterForRadiationDamageEvent(PlayerRef)
			Utility.WaitMenuMode(0.1)
			RegisterForRadiationDamageEvent(PlayerRef)
		endIf
	endIf
	
	return true
EndFunction

int Function ChanceForIntimateSceneClosestBed()
	ObjectReference bedRef = None
	int companionRelRank = 0
	int companionGender = -1
	
	if (PlayerRef.WornHasKeyword(ArmorTypePower))
		return -1
	endIf
	
	IntimateCompanionSet nearCompanion = new IntimateCompanionSet
	IntimateLocationHourSet locHourSet = new IntimateLocationHourSet
	
	; v3.0 -- allow without undress
	;if (DTSleep_SettingUndress.GetValue() > 0.0)
		nearCompanion = GetCompanionNearbyHighestRelationRank(false)
	;endIf
	
	if (nearCompanion.CompanionActor != None)
	
		bedRef = DTSleep_CommonF.FindNearestObjectInListFromObjRef(DTSleep_BedList, nearCompanion.CompanionActor, 2400.0)
		companionRelRank = CompanionRelationRankForActor(nearCompanion.CompanionActor)
		companionGender = (nearCompanion.CompanionActor.GetBaseObject() as ActorBase).GetSex()
		
		; no reset fails on check
		IntimateChancePair chancePair = ChanceForIntimateScene(nearCompanion, bedRef, None, Utility.GetCurrentGameTime(), companionGender, locHourSet, false)
		
		if (!IsAdultAnimationAvailable())
			chancePair.Chance = ChanceForIntimateSceneAdjDance(chancePair.Chance)
		endIf
		
		return chancePair.Chance
	endIf
	
	return 0
EndFunction

int Function ChanceForHugSceneAdjChair(int chance, int relationRank, bool isProp = false)

	if (chance < 100)
		if (relationRank >= 4)
			chance += 30
		elseIf (relationRank == 3)
			chance += 25
		else
			chance += 10
		endIf
		if (isProp)
			chance += 10
		endIf
		if (chance > 100)
			chance = 100
		endIf
	endIf
	return chance
endFunction

int Function ChanceForIntimateSceneAdjDance(int chance)
	if (chance == 500)
		; version check
		return 2833
	endIf
	; v2+ hug/kiss instead of dance
	
	return chance
endFunction

; may also be used for toture devices
; reduce chance and limit maximum
int Function ChanceForIntimateSceneAdjChair(int chance)
	
	if (chance > 5 && chance < 100)
		if (DressData.PlayerGender == 0)
			chance -= 12
		else
			; female advantage for SavageCabbage or submissive role
			chance -= 5
		endIf
		if (chance < 5)
			chance = 5
		elseIf (chance > 90)
			chance = 90
		endIf
	endIf
	
	return chance
endFunction

int Function ChanceForIntimateCompanionAdj(Actor companionRef)

	int result = 0
	if (companionRef != None)
		Actor noraCompRef = (DTSConditionals as DTSleep_Conditionals).NoraSpouseRef
		if (noraCompRef == None)
			noraCompRef = (DTSConditionals as DTSleep_Conditionals).NoraSpouse2Ref
		endIf
		if (noraCompRef != None && companionRef == noraCompRef)
			; bonus for Nora spouse - she is also a rank higher as if romanced
			CompanionActorScript compAct = companionRef as CompanionActorScript
			if (compAct.IsRomantic() || companionRef.GetValue(CA_AffinityAV) >= 1000.0)
				result = 80					; v2.86 increased
			else
				result = 40
			endIf
			
		elseIf ((DTSConditionals as DTSleep_Conditionals).DualSurvivorsNateRef != None && companionRef == (DTSConditionals as DTSleep_Conditionals).DualSurvivorsNateRef)
			CompanionActorScript compAct = companionRef as CompanionActorScript
			if (compAct.IsRomantic() || companionRef.GetValue(CA_AffinityAV) >= 1000.0)
				result = 80			; v2.86 increased
			else
				result = 40
			endIf
		elseIf ((DTSConditionals as DTSleep_Conditionals).InsaneIvyRef != None && companionRef == (DTSConditionals as DTSleep_Conditionals).InsaneIvyRef)
			result = 86							; v3.0 increased by 10 to be similar to Nora-spouse
		elseIf (companionRef == CurieRef)
			result = 16
		elseIf (companionRef == CompanionDanseRef)
			result = 12
		elseIf (companionRef == GetHeatherActor())
			; heather gets rank of 5 for full romanced even without ring, so small bonus okay
			result = 8
		endIf
	endIf
	if (IntimateCompanionSecRef != None)
		; v2.13 - companion affinity -- reduce chance instead of forbid
		if ((DTSleep_IntimateAffinityQuest as DTSleep_IntimateAffinityQuestScript).CompanionHatesIntimateOtherPublic(IntimateCompanionSecRef))
			result -= 40
		elseIf ((DTSleep_IntimateAffinityQuest as DTSleep_IntimateAffinityQuestScript).CompanionHatesIntimateOtherPublic(IntimateCompanionRef))
			result -= 32
		elseIf (SceneData.SecondFemaleRole != None)
			result -= 9
		elseIf (SceneData.SecondMaleRole != None)
			result -= 15
		endIf
	endIf

	return result
endFunction

; may take 0.25 - 0.35 seconds 
; performance note: each HasMagicEffect/Perk may take 0.02s  -- short-circuit or record
;
; ---------
; generally for romanced lover need a Sex Appeal + Location score of >35 with 1.0 day between scenes to have a fair chance,
;  and a flirting companion need >50, and for extra-NPC (2) need >66
;
; example chart of chance (from before v1.0 - since adjusted):
; version 2: 3 EXP 24-SA, lover at settlement, double-bed, midnight = 34% (with hug perk +16 SA = 50%)
;
;  __at night in undress location(+26) (+8 for rented room), clothed/no-sleep-clothes, 7 charisma (+7), 2-NPCs(+1), Weather(+4) -32 = 6__
;  no EXP (07-SA), lover: 13%  (33% day after first fail or 28% with alcohol)
;  no EXP (07-SA), GF/BF:-8(5) (24% after first fail and rented room or alcohol)
;  no EXP (07-SA), BFF:  -14(5) (treats +6 or -10 without)
;  17 EXP (25-SA), lover: 36%
;  17 EXP (25-SA), GF/BF: 17%  (+10 with faithful)
;  17 EXP (25-SA), BFF:   -2(5) (with alcohol + rented room or sleep clothing 8-11%)
;  52 EXP (52-SA), lover: 59%  
;  52 EXP (52-SA), GF/BF: 40%   
;  52 EXP (52-SA), BFF:   16%   
;
;  _at night in Wilderness location, naked and drunk, +4-weather, no NPCs_ (creatures wild,night,alone work out same as private for humans)
;  no EXP, Strong w/food:  7%  (-11 clothed and sober)[28-SA -6-5 -32 -28 +33+13+4]
;  no EXP, Dog w/food:    12%  (-3 clothed, sober)	[25-SA -5+1 -32 -28  +35+13+4]  (3% home plate)
;  17 EXP, Strong w/food: 14%  (-3 clothed, sober)	[23+24 -12-5 -32 -28 +31+9+4]
;  17 EXP, Dog w/Food:	  20%  (6% clothed, sober)	[23+21 -11+1 -32 -28 +33+9+4]
;  33 EXP, Dog no-food:	  25%  (10% sober, 53% food)[31+24 -15+1 -32 -28 +31+9+4]
;
; forHugs is for actual embrace at chair - not bed-time embrace
;
IntimateChancePair Function ChanceForIntimateScene(IntimateCompanionSet companionSet, ObjectReference bedRef, Form baseBedForm, float gameTime, int companionGender, IntimateLocationHourSet locHourChance, bool failReset = false, int sexAppealScore = -1, bool sameLoverAsLast = false, bool playerIsNaked = false, bool forHugs = false)
	
	IntimateChancePair result = new IntimateChancePair
	int baseChance = -34
	if (forHugs)
		baseChance = -4
	elseIf (DTSleep_AdultContentOn.GetValue() <= 1.5)
		baseChance = -28
	elseIf (IsAdultAnimationAvailable() == false)
		baseChance = -30
	endIf
	if (DTSleep_SettingNapOnly.GetValue() <= 0.0)
		; no sleep bonus available so adjust
		baseChance += 6
	endIf
	Actor companionRef = companionSet.CompanionActor
	int companionRelRank = companionSet.RelationRank
	
	int companionRankChance = 0  ; for lover
	int creatureType = 0
	int chanceLastTime = 0
	int sameLoveBonus = 0
	int specialsChance = 0
	int creaturePenalty = 0
	
	if (companionRef == None)
		result.Chance = 0
		result.SexAppeal = 0
		DTDebug(" ChanceForIntimateScene -- no companion, report zero chance", 1)
		return result
	else
		creatureType = CreatureTypeForCompanion(companionRef)
	endIf
	
	int expCheck = DTSleep_IntimateEXP.GetValueInt()
	if (expCheck != IntimacySceneCount)
		if (DTSleep_SettingTestMode.GetValue() >= 1.0 && expCheck < IntimacySceneCount)
			DTDebug("(Test Mode On) reducing EXP from " + IntimacySceneCount + " to " + expCheck, 1)
			IntimacySceneCount = expCheck
		else
			DTDebug("intimacy EXP correction: " + expCheck + " -> " + IntimacySceneCount, 1)
			DTSleep_IntimateEXP.SetValueInt(IntimacySceneCount)
		endIf
	endIf
	
	if (!forHugs && IntimacySceneCount == 0 && companionRelRank >= 4 && DTSleep_IntimateStrongExp.GetValueInt() == 0)
		baseChance = 6	; first-time easy pass
	endIf

	
	int chance = baseChance
	
	; ----------- Sex Appeal -----------
	
	if (sexAppealScore < 0)
		sexAppealScore = PlayerSexAppeal(playerIsNaked, companionGender, creatureType)
	endIf
	
	if (TestIntSceneReplaySameFurniture(bedRef, false))
		; a free redo -- score now  v2.70
		result.Chance = 100
		result.SexAppeal = sexAppealScore
		return result
	endIf
	
	if (IntimacySceneCount > 7999)
		result.Chance = 98
		result.SexAppeal = sexAppealScore
		return result
	endIf
	
	int sexAppealFraction = 1
	if (sexAppealScore > 6)
		; -2 so small values closer to fifth
		sexAppealFraction = Math.Floor(sexAppealScore * 0.4444) - 2	; 4/9 - 2
	endIf
	
	result.SexAppeal = sexAppealScore   ; generally -20 to 200
	chance += result.SexAppeal
	
	; ----------- companion ----------
	
	if (creatureType == CreatureTypeStrong)
		companionGender = 0
		creaturePenalty = -10 - sexAppealFraction
		if (companionRelRank >= 4)
			creaturePenalty -= 14
		endIf
		
		; note: rank-2 penalty below may also apply if Strong on rank 2
	elseIf (creatureType == CreatureTypeBehemoth)
		companionGender = 0
		creaturePenalty = -16 - sexAppealFraction

	elseIf (creatureType == CreatureTypeHandy)
		companionGender = 0
		creaturePenalty = 48		; robots are easy
		
	elseIf (creatureType == CreatureTypeDog)
		companionGender = 0
		creaturePenalty = -2 - sexAppealFraction 

	endIf
	
	chance += creaturePenalty

	chance += ChanceForIntimateCompanionAdj(companionRef)
	
	if (companionGender < 0 || companionGender > 1)
		companionGender = (companionRef.GetBaseObject() as ActorBase).GetSex()
	endIf
	
	; ---------- faithful -----
	
	if (sameLoverAsLast)
		
		sameLoveBonus = SceneData.CurrentLoverScenCount
		; v2.53 - limit increment to same max
		if (sameLoveBonus < 200)
			sameLoveBonus += 1	
		endIf
		
		if (SceneData.CurrentLoverScenCount > IntimacySceneCount)				; error check
			sameLoveBonus = IntimacySceneCount
			SceneData.CurrentLoverScenCount = sameLoveBonus
		endIf
		
		if (sameLoveBonus > 9)
			; after 10 - +5 bonus and increase at 1/5 or 1/4 per count
			if (sameLoveBonus < 41)
				sameLoveBonus = 12 + ((sameLoveBonus * 0.500) as int)				; v2.53 increase
			elseIf (sameLoveBonus < 200)
				sameLoveBonus = 33 + ((sameLoveBonus * 0.250) as int)
			else
				; v2.53 - max
				sameLoveBonus = 85
			endIf
		endIf
		if (creatureType == 0 && companionRelRank > 2 && sameLoveBonus >= 5 && SceneData.CurrentLoverScenCount >= DTSleep_IntimateEXP.GetValueInt())
			; faithful bonus - includes creature only if creature-EXP > human-EXP
			sameLoveBonus += 16
		endIf
		
	else
		; penalty for switching vary by sex appeal to compensate
		sameLoveBonus = -8
		
		if (sexAppealScore >= 34)
			sameLoveBonus -= (sexAppealScore * 0.083333) as int   ; sexAppealScore / 12
		endIf
		
	endIf
	
	chance += sameLoveBonus
	
	; ---- companion rank -----
	
	; companionRelRank 4 is default (+0)
		
	if (companionRelRank >= 5)
		; for lover's ring - expected to gain faithfullness score over time so this should be small bonus
		companionRankChance = 12
		
	elseIf (companionRelRank == 3)
		companionRankChance = -28
		
	elseIf (companionRelRank == 2)
		; non-romance NPCs expected to have earned max affinity
		; more difficult to convince, but shouldn't be impossible for beginner
		; having experience is less of and advantage so adjust for higher appeal
		; modify by fraction to help with scaling
		
		if (forHugs)
			companionRankChance = -29 - sexAppealFraction
		else
			companionRankChance = -39 - sexAppealFraction
		endIf
		if (companionSet.HasLoverRing)
			companionRankChance += 24
		endIf
		
	elseIf (companionRelRank == 1)
		; only Dogmeat without dog food uses this - what about unhappy companions?
		companionRankChance = -80 - sexAppealFraction
		
		
	elseIf (companionRelRank <= 0)
		; not used 
		companionRankChance = -120 - sexAppealFraction
	endIf
	
	chance += companionRankChance
	
	; ------------------- Location and Time adjustments -----------------	
	if (locHourChance.Chance == 0)
	
		locHourChance = ChanceForIntimateSceneByLocationHour(bedRef, baseBedForm, companionRef, companionRelRank, gameTime, forHugs)
	endIf
	
	; record in case check same spot again
	IntimateCheckAreaScore = locHourChance
	
	chance += locHourChance.ChanceReal
	chance += locHourChance.MidSleepBonusChance

	; 1-day is neutral (zero), -72 (under hour) to +48 (15 days)
	;
	chanceLastTime = ChanceForIntimateSceneByLastTime(companionRelRank, gameTime, failReset, forHugs, true)
	if (chanceLastTime < 0 && locHourChance.MidSleepBonusChance > 0)
		float daysSinceLastIntimate = gameTime - IntimateLastTime
		if (daysSinceLastIntimate > 0.042)
			chanceLastTime = 0				; v2.33 - no penalty for mid-sleep, v2.48 and been at least an hour since last
		else
			chanceLastTime = chanceLastTime / 2		; v2.48
		endIf
	endIf
	chance += chanceLastTime
	
	; ----------- Specials -----------

	int index = 0
	int len = DTSleep_IntimacyChanceMEList.GetSize()

	while (index < len)
		MagicEffect aSpell = DTSleep_IntimacyChanceMEList.GetAt(index) as MagicEffect
		if (aSpell && PlayerRef.HasMagicEffect(aSpell))
			specialsChance += 20
			
			index = len + 10  ; break now
		endIf
		
		index += 1
	endWhile
	
	; v2.53 - additional bonus for busy-day and exhibitionist
	if (PlayerRef.HasPerk(DTSleep_BusyDayPerk))
		specialsChance += 40
	endIf
	if (PlayerRef.HasPerk(DTSleep_ExhibitionPerk))
		specialsChance += 40		; also includes +2 charisma for sex-appeal bonus
	endIf
	
	chance += specialsChance
	
	; ------------------------------
	
	; Torture device adjustment
	int bedFurnitureType = 0
	if (baseBedForm != None && (DTSleep_PilloryList.HasForm(baseBedForm) || DTSleep_TortureDList.HasForm(baseBedForm)))
		if (DressData.PlayerGender == 1)
			chance -= 9
		else
			; extra penalty for asking other to get into device
			chance -= 18
		endIf
		bedFurnitureType = 1
		
	elseIf (bedRef == None)
		bedFurnitureType = -1
		chance -= 5
	endIf
	
	; finalize and return
	result.Chance = chance
	
	int minChance = 5
	if (DTSleep_IntimateLocCount.GetValueInt() >= DTSleep_IntimateTourLocList.GetSize())
	
		minChance = 10
	endIf
	
	if (result.Chance < minChance)
	
		if (companionRelRank > 1)
			result.Chance = minChance
			
		elseIf (result.Chance < 2)
			result.Chance = 2
		endIf
	
	elseIf (companionRelRank <= 2 && chance > 85)
		result.Chance = 85
		
	elseIf (result.Chance > 95)
	
		if (chance >= (180 - locHourChance.MidSleepBonusChance))
			result.Chance = 100		; v2.26 - very favorable 
		else
			result.Chance = 95
		endIf
	endIf

	if (DTSleep_SettingTestMode.GetValueInt() > 0 && DTSleep_DebugMode.GetValue() >= 1.0)

		Debug.Trace(myScriptName + " -------------------------------------------------- ")
		Debug.Trace(myScriptName + " Test-Mode output - may disable in Settings ")
		Debug.Trace(myScriptName + "     intimate chance calculation ")
		Debug.Trace(myScriptName + "     Game Time: " + gameTime)
		Debug.Trace(myScriptName + "      bed type: " + bedFurnitureType + " hugs? " + forHugs)
		Debug.Trace(myScriptName + " -------------------------------------------------- ")
		Debug.Trace(myScriptName + " starting base       : " + baseChance)
		Debug.Trace(myScriptName + " Sex Appeal score    : " + sexAppealScore)
		Debug.Trace(myScriptName + " companion Rank(" + companionRelRank + ")   : " + companionRankChance + " (gender: " + companionGender + ") (" + companionRef + ")")
		Debug.Trace(myScriptName + " creature(" + creatureType + ") penalty : " + creaturePenalty)
		Debug.Trace(myScriptName + " SceneData-IsCreature: " + SceneData.IsUsingCreature)
		Debug.Trace(myScriptName + " intimate same-lover : " + sameLoveBonus + " (count: " + SceneData.CurrentLoverScenCount + ")")
		Debug.Trace(myScriptName + " RaceRestricted      : " + SceneData.RaceRestricted)
		Debug.Trace(myScriptName + " HasToyAvailable     : " + SceneData.HasToyAvailable)
		Debug.Trace(myScriptName + " intimate Location   : " + locHourChance.ChanceReal + " (" + locHourChance.Chance + ")")
		Debug.Trace(myScriptName + "      mid-sleep bonus: " + locHourChance.MidSleepBonusChance)
		Debug.Trace(myScriptName + " intimate time-since : " + chanceLastTime)
		Debug.Trace(myScriptName + " intimate specials   : " + specialsChance)
		Debug.Trace(myScriptName + " ------------------------- ")
		Debug.Trace(myScriptName + " intimate base chance: " + chance)
		Debug.Trace(myScriptName + " intimate fin  chance: " + result.Chance)
		Debug.Trace(myScriptName + " -------------------------------------------------- ")
	endIf
	
	return result
EndFunction

; chance by hour - called by *ByLocationHour
; varies from -21 to +10 for relRank 3, or -14 to +7
;
int Function ChanceForIntimateSceneByHourOfDay(int companionRelRank, int sexEXP, float gameTime, bool indoors, bool forHugs = false)

	int chance = 0
	int dividend = 48
	int divisor = companionRelRank
	int fAdj = 7
	if (divisor <= 1)
		divisor = 2
	endIf
	
	if (sexEXP < 12)
		dividend = 60
		fAdj = 9
	elseIf (sexEXP > 100)
		dividend = 24
		fAdj = 4
	elseIf (sexEXP > 55)
		dividend = 36
		fAdj = 5
	endIf
	if (companionRelRank < 3)
		fAdj += 6
	endIf
	
	int nightBonus = ((dividend / divisor) as int) - fAdj
	float hourOfDay = DTSleep_CommonF.GetGameTimeCurrentHourOfDayFromCurrentTime(gameTime)
	
	if (!forHugs && hourOfDay >= 6.0 && hourOfDay <= 20.0)
		
		; vary by time of day so 1pm gets largest penalty
		
		float hourOffset = 13.0 - hourOfDay
		if (hourOffset > 0)
			hourOffset = 7.0 - hourOffset
		else
			hourOffset = 7.0 + hourOffset
		endIf
		
		int rankFactor = 2   ; for rank 4+
		if (indoors)
			rankFactor = 1
		endIf
		
		if (companionRelRank >= 2 && companionRelRank < 4)
			rankFactor += 1
		endIf
		
		if (rankFactor > 0)
			chance -= (rankFactor * Math.Floor(hourOffset))
		endIf
		
	elseIf (hourOfDay >= 23.0 || hourOfDay <= 3.0)
	
		chance += nightBonus
		
	elseIf (hourOfDay > 20.0 && hourOfDay < 23.0)
		
		; vary by time best at 23.00
		float hourScale = hourOfDay - 20.0
		hourScale = hourScale * 0.33333
		
		chance += Math.Floor((nightBonus as float) * hourScale)
		
	elseIf (hourOfDay > 3.0 && hourOfDay < 6.0)
	
		; vary by time best at 3.0
		float hourScale = 6.0 - hourOfDay
		hourScale = hourScale * 0.33333
		
		chance += Math.Floor((nightBonus as float) * hourScale)
	endIf
	
	return chance

endFunction

; Chance adjustment for Location and time of day - considered as 'safety rating' to report
;  return range: -46 to +57
;  may take 0.18 seconds to process if checking bed for workshop -- if on TownList then cuts time in half
;
IntimateLocationHourSet Function ChanceForIntimateSceneByLocationHour(ObjectReference bedRef, Form baseBedForm, Actor companionRef, int companionRelRank, float gameTime, bool forHugs = false)

	IntimateLocationHourSet result = new IntimateLocationHourSet
	result.BedOwned = false
	result.MidSleepBonusChance = -1
	int chance = 0
	int locChance = 0
	int weatherChance = 0
	int chanceHoliday = 0
	int npcChance = 0
	int hourChance = 0
	int nearbyActorCount = 0
	int wClass = -1
	bool hasBedBonus = false
	bool indoors = false
	bool romanticQuestFin = false
	string locName = "wilderness"
		
	; more experience means less variance --- less experience results in more variance and penalty
	; remember that sex-appeal score not directly related to EXP
	
	float exp = DTSleep_IntimateEXP.GetValue()
	
	int creatureType = CreatureTypeForCompanion(companionRef)
	
	if (creatureType == CreatureTypeStrong || creatureType == CreatureTypeBehemoth)
		exp = IntimacySMCount
	elseIf (creatureType == CreatureTypeDog)
		exp = IntimacyDogCount
	endIf
	
	int expAdj = 10
	
	if (exp > 0.0 && exp < 43.0)
		expAdj = (10.0 - (exp * 0.20)) as int
	elseIf (exp > 43.0)
		expAdj = 0
	endIf
	
	if (DTSleep_IntimateLocCount.GetValueInt() >= DTSleep_IntimateTourLocList.GetSize())
		romanticQuestFin = true
	endIf
	
	; -------------- holiday check --------------
	
	if (creatureType == 0)
		int holidayVal = (DTSleep_TimeDayQuestP as DTSleep_TimeDayQuestScript).GetHolidayVal()
		
		result.HolidayType = holidayVal
		
		if (holidayVal > 0 && !SceneData.IsUsingCreature)
			if (holidayVal == 2)
				chanceHoliday = 54		; Valentine
				if (SceneData.CurrentLoverScenCount > 1)
					chanceHoliday += 46
				endIf
			elseIf (holidayVal == 1)		; New Year
				chanceHoliday = 28
				if (SceneData.CurrentLoverScenCount > 9)
					chanceHoliday += 22
				endIf
			elseIf (holidayVal == 8)
				; Halloween
				chanceHoliday = 38
				if (bedRef != None && bedRef.HasKeyword((DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).AnimFurnLayDownUtilityBoxKY))
					chanceHoliday += 32
				endIf
				if (SceneData.CurrentLoverScenCount > 9)
					chanceHoliday += 10
				endIf
				
			elseIf (holidayVal >= 11 && holidayVal <= 12)
				; Christmas
				chanceHoliday = 46
				if (SceneData.CurrentLoverScenCount > 4)
					chanceHoliday += 24
				endIf
			elseIf (holidayVal == 13)
				; new year eve
				chanceHoliday = 34
				if (SceneData.CurrentLoverScenCount > 1)
					chanceHoliday += 16
				endIf
			else
				chanceHoliday = 20
			endIf
		endIf
	endIf
	
	; ------------ location and weather -----------
	
	bool checkWeather = true
	int checkActorByLocChance = -1   ; 0 is wilderness, 10 = rented or workshop, 20 = town or undress - also for penalty score
	bool checkBedBonus = true
	
	;v2.35 reset SceneData location
	SceneData.IntimateLocationType = 0
	
	Location currentLoc = (SleepPlayerAlias as DTSleep_PlayerAliasScript).CurrentLocation
	if (currentLoc == None)
		if (DTSleep_SettingTestMode.GetValueInt() > 0 && DTSleep_DebugMode.GetValue() >= 2.0)
			Debug.Trace(myScriptName + " no playerAlias location, get current")
		endIf
		currentLoc = PlayerRef.GetCurrentLocation()   ; slow function - better to store current
	endIf
	
	if (currentLoc != None)
		
		; PlayerRef.IsInLocation(DiamondCityPlayerHouseLocation)
		
		if (currentLoc == DiamondCityPlayerHouseLocation)
			if (creatureType == CreatureTypeStrong)
				locChance = 24
			elseIf (creatureType == CreatureTypeHandy)
				locChance = 70
			elseIf (creatureType == CreatureTypeDog)
				locChance = 50
			else
				locChance = 64
			endIf
			checkBedBonus = false
			checkWeather = false
			locName = "home-plate"
			indoors = true
			if (!SceneData.IsUsingCreature && bedRef != None && !bedRef.HasKeyword(AnimFurnFloorBedAnims))
				result.BedOwned = true
			endIf
			SceneData.IntimateLocationType = LocActorChanceOwned
			; not checking checkActorByLocChance - extra NPCs considered a guests so scored as no NPCs
			
		elseIf (DTSleep_PrivateLocationList && (DTSleep_PrivateLocationList.HasForm(currentLoc as Form)))
			locName = "private"
			if (creatureType == CreatureTypeStrong)
				locChance = 24
			else
				locChance = 60
			endIf
			checkBedBonus = false
			checkWeather = false
			indoors = true
			if (!SceneData.IsUsingCreature && bedRef != None && !bedRef.HasKeyword(AnimFurnFloorBedAnims))
				result.BedOwned = IsBedOwnedByPlayer(bedRef, companionRef)
			endIf
			SceneData.IntimateLocationType = LocActorChanceOwned
			; not checking checkActorByLocChance - extra adult NPCs considered a guests
			
		elseIf (!forHugs && DTSleep_CrimeLocationList.HasForm(currentLoc as Form) && !PlayerRef.IsInInterior())
			locChance = 6
			locName = "crime-area"
			checkActorByLocChance = LocActorChanceTown
		elseIf (!forHugs && DTSleep_CrimeLocationIntList.HasForm(currentLoc as Form))
			; v2.16 - check exceptions for rooms within 
			bool isCrimeArea = true
			
			if (currentLoc == DTSleep_CrimeLocationIntList.GetAt(7))		; Vault81Location
				float posZ = PlayerRef.GetPositionZ()
				if (posZ > -272.0 && posZ < -260.0)
					float posX = PlayerRef.GetPositionX()
					float posY = PlayerRef.GetPositionY()
					if (posX > -2400.0 && posX < -1600.0 && posY > -5700.0 && posY < -5000.0)
						; inside reward room near bed
						isCrimeArea = false
					endIf
				endIf
			endif
			
			if (isCrimeArea)
				locChance = 10
				locName = "crime-area"
				checkActorByLocChance = LocActorChanceTown
			else
				locChance = 30
				locName = "non-crime-area"
				checkActorByLocChance = LocActorChanceOwned
			endIf
			
		elseIf (DTSleep_UndressLocationList && (DTSleep_UndressLocationList.HasForm(currentLoc as Form)))
			locName = "undress-safe"
			if (creatureType == CreatureTypeStrong)
				locChance = 19
				if (bedRef != None && bedRef.HasKeyword((DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).DTSleep_SMBed02KY))
					locChance + 15
				endIf
			else
				locChance = 30
			endIf

			checkActorByLocChance = LocActorChanceTownNice			; v2.40
			indoors = PlayerRef.IsInInterior()
			if (!SceneData.IsUsingCreature && bedRef != None && !bedRef.HasKeyword(AnimFurnFloorBedAnims))
				result.BedOwned = IsBedOwnedByPlayer(bedRef, companionRef)
			endIf
		elseIf (romanticQuestFin && (creatureType == 0 || creatureType == CreatureTypeSynth) && DTSleep_IntimateTourLocList.HasForm(currentLoc as Form))
			locChance = 28			; plus additional bonus below
			locName = "romantic"
			indoors = PlayerRef.IsInInterior()
			checkActorByLocChance = LocActorChanceTownNice
			
		elseIf (bedRef != None)
		
			if (creatureType == CreatureTypeStrong && bedRef.HasKeyword((DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).DTSleep_SMBed02KY))
				locChance = 35								; v2.25 new furniture for Strong
				locName = "owned-bed"
				checkActorByLocChance = LocActorChanceTown   ; Strong only uses Wilderness or Town distance -- use town for best advantage
				result.BedOwned = true
			else
				bool bedIsPillory = false
				bool bedIsOtherFurniture = false
				
				if (baseBedForm == None)
					baseBedForm = bedRef.GetBaseObject() as Form
				endIf
				
				if (baseBedForm != None && (DTSleep_PilloryList.HasForm(baseBedForm) || DTSleep_TortureDList.HasForm(baseBedForm)))
					bedIsPillory = true
				elseIf ((DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).IsObjBed(bedRef) == false)
					bedIsOtherFurniture = true
				endIf
					
				if (!bedIsOtherFurniture && !bedIsPillory && companionRef != None && IsBedOwnedByPlayer(bedRef, companionRef))
					
					if (creatureType == CreatureTypeStrong)
						locChance = 18
					elseIf (creatureType == CreatureTypeDog)
						locChance = 25
					else
						locChance = 36
					endIf
					indoors = PlayerRef.IsInInterior()
					if (indoors)
						locChance += 12
					endIf
					locName = "owned-bed"
					checkActorByLocChance = LocActorChanceOwned   ; 10- set to determine distance check and limit penalty
					result.BedOwned = true
					
				elseIf (DTSleep_TownLocationList != None && DTSleep_TownLocationList.HasForm(currentLoc as Form))
					; towns include some settlements, raider forts

					locChance = 14
					if (creatureType == 0 && romanticQuestFin)
						; in addition to bonus below
						locChance += 10
					elseIf (forHugs)
						locChance += 12
					elseIf (creatureType == CreatureTypeStrong)
						locChance += 2
					elseIf (creatureType == CreatureTypeHandy)
						locChance += 12
					endIf
					
					checkActorByLocChance = LocActorChanceTown
					locName = "town"
					
					if (bedIsPillory)
						locChance -= 20
					endIf
					
				elseIf (creatureType == 0 && !bedIsOtherFurniture && !bedIsPillory && companionRef != None && bedRef.IsOwnedBy(companionRef))
					locChance = 24
					if (romanticQuestFin)
						; in addition to bonus below
						locChance += 10
					endIf
					checkActorByLocChance = LocActorChanceSettled   ; usually settlement since most companion homes marked Undress
					locName = "companion-bed"
					result.BedOwned = true
					
				elseIf (currentLoc.HasKeyword(LocTypeWorkshopSettlementKY))
					; faster than using bed-workshop-check below and workshop may be locked which is okay here
					if (creatureType == CreatureTypeStrong || creatureType == CreatureTypeBehemoth)
						locChance = -8
					elseIf (creatureType == CreatureTypeDog)
						locChance = -3
					elseIf (creatureType == CreatureTypeHandy)
						locChance = 16
					elseIf (romanticQuestFin)
						; in addition to bonus below
						locChance = 20
					elseIf (forHugs)
						locChance = 18
					else
						locChance = 10
					endIf
					indoors = PlayerRef.IsInInterior()			;v2.40 indoor workshop may be custom home
					if (indoors)
						if (IsObjBelongPlayerWorkshop(bedRef))		; slow
							DTDebug(" indoor unlocked settlement not on private list... assume custom home", 1)
							locChance += 18			; workshop unlocked, but bed not owned
						else
							locChance += 9
						endIf
					endIf
					
					checkActorByLocChance = LocActorChanceSettled
					locName = "settlement"
					
					if (bedIsPillory)
						locChance -= 20
					endIf
					
				elseIf (PlayerRef.IsInInterior())
					if (creatureType == CreatureTypeStrong)
						locChance = 6
					else
						locChance = 15
					endIf
					checkWeather = false
					checkActorByLocChance = LocActorChanceInterior
					locName = "interior"
					indoors = true
					
				else 
					; check workshops 
					; checked last because slowest - also determines if player has access to workshop
					; Conquest camp uses this
					int workshopBedNum = IsObjBelongPlayerWorkshop(bedRef)
					
					if (workshopBedNum == 2)
						locName = "ConquestWorkshop-bed"
						if (creatureType == 0)
							locChance = 2
						elseIf (creatureType == CreatureTypeStrong || creatureType == CreatureTypeBehemoth)
							locChance = 20
						elseIf (creatureType == CreatureTypeHandy)
							locChance = 30
						elseIf (creatureType == CreatureTypeDog)
							; dog loves camping!
							locChance = 25
						endIf
						checkActorByLocChance = LocActorChanceWild   ; check like wilderness
						
					elseIf (workshopBedNum == 1)
						if (creatureType == CreatureTypeStrong || creatureType == CreatureTypeBehemoth)
							locChance = -8
						elseIf (creatureType == CreatureTypeDog)
							locChance = -5
						else
							locChance = 8
						endIf
						indoors = PlayerRef.IsInInterior()			;v2.40 indoor workshop may be custom home... without keyword
						if (indoors)
							DTDebug(" indoor unlocked workshop without settlement keyword not on private list... custom home??", 1)
							locChance += 19
						endIf
						checkActorByLocChance = LocActorChanceSettled
						locName = "workshop-bed"
						if (bedIsPillory)
							locChance -= 20
						endIf
						
					else
						; wilderness / unknown bed
						if (creatureType == CreatureTypeStrong || creatureType == CreatureTypeBehemoth)
							locChance = 20
						elseIf (creatureType == CreatureTypeHandy)
							locChance = 25
						elseIf (creatureType == CreatureTypeDog)
							; dog outside at night should work out similar to private area
							locChance = 25
						elseIf (forHugs)
							locChance = 0
						else
							locChance = -18
						endIf
						checkActorByLocChance = LocActorChanceWild
					endIf
				endIf
			endIf
		endIf
			
		if (romanticQuestFin)
			locChance += 15		; in addition to selected above situations
		endIf
		
		; bed bonus
		if (checkBedBonus && checkActorByLocChance != LocActorChanceWild && baseBedForm != None)
			if (DTSleep_BedIntimateList.HasForm(baseBedForm))
				hasBedBonus = true
				locChance += 18
			endIf
		endIf
	endIf
	
	; v2.35 update SceneData with location type
	if (SceneData.IntimateLocationType <= 0)
		SceneData.IntimateLocationType = checkActorByLocChance
	endIf

	
	;   NPC nearby penalty 
	;	not checking private locations unless Strong or self/dog-play
	;   in private areas let's assume other actors to be guests or imagined participants - what about child?
	;
	int childCount = 0
	int nearbyActorSleepCount = 0
	int nearbyLoverCount = 0
	int nearbyLoverHateCount = 0
	
	if (!forHugs && (checkActorByLocChance >= 0 || creatureType > 0))	; not checking homes/private (-1) unless sex with creature
	
		int expFactor = 1
		int index = 0
		int len = DTSleep_ActorKYList.GetSize()
		float closestNPCDist = 3900.0
		float distance = 2400.0		; 2400 used by IsNearby
		
		
		if (len > 0)
			if (checkActorByLocChance == LocActorChanceWild)
				distance = 2800.0   ; wilderness  
				
			elseIf (checkActorByLocChance == LocActorChanceOwned && SceneData.IsCreatureType != CreatureTypeStrong)
				
				distance = 700.0
				len = 1		  		; only check NPC
				
			elseIf (checkActorByLocChance == LocActorChanceSettled  && SceneData.IsCreatureType != CreatureTypeStrong)
			
				distance = 1200.0  	; settlement bed
				len = 1		  		; only check NPC
				
			elseIf (checkActorByLocChance == LocActorChanceTownNice)
				distance = 1000.0  	; town, undress location
				len = 1		  		; only check NPC
			elseIf (checkActorByLocChance == LocActorChanceTown)
				distance = 1800.0  	; town
				len = 1		  		; only check NPC
			endIf
			
			while (index < len)
			
				ObjectReference[] actorArray = PlayerRef.FindAllReferencesWithKeyword(DTSleep_ActorKYList.GetAt(index), distance)
				Actor heatherActor = GetHeatherActor()
				Actor barbActor = GetNWSBarbActor()
				bool isSleepyNPC = false
								
				int aCnt = 0
				while (aCnt < actorArray.Length)
					Actor ac = actorArray[aCnt] as Actor
					if (ac != None && ac != PlayerRef && ac.IsEnabled() && !ac.IsDead() && !ac.IsUnconscious())
						
						if (index == 0)
							if ((DTSConditionals as DTSleep_Conditionals).IsWorkShop02DLCActive && (DTSConditionals as DTSleep_Conditionals).DLC05ArmorRackKY != None && ac.HasKeyword((DTSConditionals as DTSleep_Conditionals).DLC05ArmorRackKY))
								; do nothing -
								; not counting workshop armor mannequin which is NPC
							
							else
								isSleepyNPC = false
								CompanionActorScript aCompanion = GetCompanionOfActor(ac)
								
								if (aCompanion != None && creatureType <= 0 && ac != companionRef)
								
									; even if sleeping - poses risk and concern for current companion
									if ((DTSleep_IntimateAffinityQuest as DTSleep_IntimateAffinityQuestScript).CompanionHatesIntimateOtherPublic(ac))
										nearbyLoverHateCount += 1
									elseIf (ac.GetSleepState() >= 3)
										nearbyActorSleepCount += 1
									else
										bool isPartner = false
										float intimateSetting = DTSleep_SettingIntimate.GetValue()
										if (aCompanion.IsRomantic())
											isPartner = true
										elseIf (aCompanion.IsInFatuated())
											isPartner = true
										elseIf (DTSleep_CompanionRomanceList.HasForm(ac as Form) && aCompanion.GetValue(CA_AffinityAV) >= 1000.0)
											isPartner = true
										elseIf ((intimateSetting == 2.0 || intimateSetting == 4.0) && PlayerHasPerkOfCompanion(ac))
											isPartner = true
										endIf

										if (isPartner)
											nearbyLoverCount += 1
										else
											nearbyActorCount += 1	; companion not romanced
										endIf
									endIf
								
								elseIf (heatherActor != None && heatherActor != companionRef && heatherActor == ac)
									if (ac.GetSleepState() < 3)
										if (IsHeatherInLove() >= 1)
											nearbyLoverCount += 1
										else
											nearbyActorCount += 1
										endIf
									else
										nearbyActorSleepCount += 1
									endIf
								
								elseIf (barbActor != None && barbActor != companionRef && barbActor == ac)
									if (ac.GetSleepState() < 3)
										if (IsNWSBarbInLove())
											nearbyLoverCount += 1
										else
											nearbyActorCount += 1
										endIf
									else
										nearbyActorSleepCount += 1
									endIf
									
								elseIf (ac.GetSleepState() == 3)
									; sleeping only counts if not Strong companion and far enough away
									
									if (creatureType != CreatureTypeStrong && creatureType != CreatureTypeBehemoth && ac.GetDistance(PlayerRef) > 250.0)
										nearbyActorSleepCount += 1
										isSleepyNPC = true
									else
										; chance to wake up? TODO: 
										nearbyActorCount += 1
									endIf
								else
									; current companion also counts
									nearbyActorCount += 1
								endIf
								
								if (closestNPCDist > 200.0 && ac != IntimateCompanionRef && ac!= SceneData.SecondMaleRole && ac != SceneData.SecondFemaleRole)
									float dist = ac.GetDistance(PlayerRef)
									if (dist < closestNPCDist)
										closestNPCDist = dist
									endIf
								endIf
								
								if (ac.HasKeyword(ActorTypeChildKY) && !isSleepyNPC)
									childCount += 1
								endIf
							endIf
							
						else
							; non-human types
							nearbyActorCount += 1
						endIf
					endIf
				
					aCnt += 1
				endWhile
			
				index += 1
			endWhile
		endIf
		
		; one nearby actor expected to be companion unless self/dog-play which does not allow active companions
		; 	Dogmeat only counts if searching for creature or animal - and we are not
		;
		if ((nearbyActorCount + nearbyActorSleepCount + nearbyLoverCount + nearbyLoverHateCount) >= 1)
			
			int count = nearbyActorCount				
			
			if (creatureType != CreatureTypeDog && creatureType != CreatureTypeBehemoth)
				count -= 1											; subtract for love-companion
			endIf
			
			; adjust for number of spectators, more for beginners and less for experts
			; also area penalty below
			
			if (expAdj > 7)
				expFactor = 7
			else
				expFactor = 5
			endIf
			if (count > 9)
				expFactor += 2
			elseIf (count > 5)
				expFactor += 1
			endIf
			
			if (closestNPCDist < 200.0)
				expFactor += 3
			elseIf (closestNPCDist < 367.0)
				expFactor += 2
			endIf
			
			if (checkActorByLocChance < 0 || checkActorByLocChance == LocActorChanceOwned)
				; rented and private areas tend to have more guests nearby
				expFactor -= 2
				count -= 1
			elseIf (checkActorByLocChance == LocActorChanceWild)
				expFactor += 2
			endIf

			; don't get caught with Strong or Dogmeat!!
			if (creatureType != 0)
				if (creatureType == CreatureTypeStrong || creatureType == CreatureTypeBehemoth)
					expFactor += 9
			
				elseIf (creatureType == CreatureTypeDog)
					expFactor += 4
				endIf
			endIf
			
			npcChance = -2							; penalty for NPCs around 
			
			if (count > 1)
				npcChance -= (count * expFactor)  	; penalty per additional NPCs beyond 1
			endIf
			
			if (nearbyActorSleepCount > 0)
				npcChance -= nearbyActorSleepCount
			endIf
			if (nearbyLoverCount > 0)
				npcChance -= nearbyLoverCount
			endIf
			if (nearbyLoverHateCount > 0)
				npcChance -= (nearbyLoverHateCount * 12)
			endIf
			
			if (childCount > 0)
				int penalty = 24															; (in addition to nearbyCount) for child
				if (DTSleep_AdultContentOn.GetValue() >= 2.0 && IsAdultAnimationAvailable()); v2.53 increase for adult
					penalty = 40
				endIf
				npcChance -= (childCount * penalty)		
			endIf
		endIf
		
		; area penalty or bonus for being alone
		
		if (checkActorByLocChance == LocActorChanceWild)
			; wilderness - compensate for unknown area penalty if no spectators
			
			int count = nearbyActorCount				
			
			if (creatureType != CreatureTypeDog && creatureType != CreatureTypeBehemoth)
				count -= 1											; subtract for love-companion
			endIf
			
			if (count >= 3)
				npcChance -= 10
				
			elseIf (count <= 0 && nearbyActorSleepCount == 0 && nearbyLoverCount == 0)
				; all alone!
				npcChance += 18
				
				; best be alone with creatures - extra bonus for beginners
				if (creatureType == CreatureTypeDog)
					npcChance += (10 + expAdj)

				elseIf (creatureType == CreatureTypeStrong || creatureType == CreatureTypeBehemoth)
					npcChance += (8 + expAdj)
				endIf
				
			elseIf (count <= 0 && nearbyLoverCount == 1 && creatureType <= 0)
				npcChance += 2
			elseIf (count <= 0 && nearbyActorSleepCount == 1)
				npcChance += 4
			elseIf ((count + nearbyActorSleepCount) <= 2)
				npcChance += 1
			endIf
		elseIf (checkActorByLocChance == LocActorChanceTown)
		
			int count = nearbyActorCount
		
			if (count >= 3)
				npcChance -= 5
				
			elseIf (count <= 0 && nearbyActorSleepCount == 0 && nearbyLoverCount == 0)
				; all alone!
				npcChance += 10
				
				; best be alone with creatures - extra bonus for beginners
				if (creatureType == CreatureTypeDog)
					npcChance += (8 + expAdj)

				elseIf (creatureType == CreatureTypeStrong || creatureType == CreatureTypeBehemoth)
					npcChance += (4 + expAdj)
				endIf
			endIf
			
		elseIf (nearbyActorCount >= 8)
			; too much audience
			; remember: also negated for actor count
			npcChance -= checkActorByLocChance
			
		elseIf (nearbyActorCount > 4)
			; okay, a small audience
			
			npcChance -= (checkActorByLocChance * 0.5) as int
			
		elseIf (nearbyActorCount <= 2)
			; alone at last-- not checking private areas
			npcChance += 6
			
			if (nearbyActorCount <= 1)
				if (creatureType == CreatureTypeDog)
					npcChance += 11 
				elseIf (creatureType == CreatureTypeStrong || creatureType == CreatureTypeBehemoth)
					npcChance += 8
				endIf
			endIf
		
		endIf
		
	elseIf (!forHugs)
		; in private area - assume adults are guests and only check children
		; generally child in private area if leading child by quest, main-quest child, or using mod to add children
		; 
		ObjectReference[] actorArray = PlayerRef.FindAllReferencesWithKeyword(ActorTypeChildKY, 800.0)
		if (actorArray != None && actorArray.Length > 0)
			int aCnt = 0
			; v2.53 check sleeping state and increase penalty for adult animations
			while (aCnt < actorArray.Length)
				Actor ac = actorArray[aCnt] as Actor
				if (ac.GetSleepState() == 3)
					nearbyActorSleepCount += 1
				else
					childCount += 1
				endIf
				
				aCnt += 1
			endWhile
			if (childCount > 0)
				int penalty = 20
				if (DTSleep_AdultContentOn.GetValue() >= 2.0 && IsAdultAnimationAvailable())
					penalty = 36
				endIf
				npcChance -= (penalty * childCount)			
			endIf
			if (nearbyActorSleepCount > 0)
				npcChance -= (5 * nearbyActorSleepCount)
			endIf
		endIf
	endIf
	
	; get hour of day factor

	hourChance = ChanceForIntimateSceneByHourOfDay(companionRelRank, exp as int, gameTime, indoors, forHugs)
	
	if (creatureType > 0 && creatureType != CreatureTypeSynth && hourChance > 0)
		hourChance += 1
	
	endIf
	
	if (checkWeather && !indoors)
		
		IntimateWeatherScoreSet wScore = ChanceForIntimateSceneWeatherScore()
		wClass = wScore.wClass
		weatherChance = wScore.Score
		if (creatureType > 0 && weatherChance < 0)
			weatherChance = 0
		endIf
		
	endIf
	
	chance = chanceHoliday + weatherChance + npcChance + locChance + hourChance
	
	; v2.24
	if (bedRef.HasKeyword(DTSleep_OutfitContainerKY))
		chance += 12
	endIf
	
	; determine to report guess or uncertainty
	
	result.LocChanceType = checkActorByLocChance			; v2.35 moved up here before needed
	
	if (checkActorByLocChance < 0 || (DTSleep_IntimateLocCount.GetValueInt() >= DTSleep_IntimateTourLocList.GetSize()))
		result.Chance = chance
		
	elseIf (locChance > 49 && result.LocChanceType != LocActorChanceWild)
		result.Chance = chance
	else
		int bound = (exp + 36.0) as int
		if (bound > 88)
			bound = 88
		endIf
		
		if (result.LocChanceType == LocActorChanceWild)
			bound = Math.Floor(bound / 2) + 2
		elseIf (result.LocChanceType == LocActorChanceOwned)
			bound += 16
		elseIf (locChance >= 32)
			bound += 16
		elseIf (locChance >= 26 && indoors)
			bound += 10
		elseIf (result.LocChanceType == LocActorChanceSettled)
			bound += 10
		elseIf (result.LocChanceType == LocActorChanceTown)
			bound += 4
		endIf
		
		int roll =  Utility.RandomInt(0, 99)
		
		if (roll <= bound)
			result.Chance = chance   ; actual
		elseIf (roll < (bound + 20))
			Utility.Wait(0.06)
			result.Chance = chance + Utility.RandomInt(-5, 12)   ; guess
		else
			result.Chance = -200   ; uncertain
		endIf
	endIf
	
	if (forHugs)
		result.LocChanceType = LocActorChanceHugs
	endIf
	
	if (DTSleep_SettingTestMode.GetValueInt() > 0 && DTSleep_DebugMode.GetValue() >= 2.0)
	
		int hourOfDay = (DTSleep_CommonF.GetGameTimeCurrentHourOfDayFromCurrentTime(gameTime) as int)
		Debug.Trace(myScriptName + " -------------------------------------------------- ")
		Debug.Trace(myScriptName + " Test-Mode output - may disable in Settings ")
		Debug.Trace(myScriptName + " is Romantic Quest complete? " + romanticQuestFin + "-- for hugs? " + forHugs)
		Debug.Trace(myScriptName + " LocChanceType = " + result.LocChanceType)
		Debug.Trace(myScriptName + " -------------------------------------------------- ")
		Debug.Trace(myScriptName + " location type score : " + locChance + " (" + locName + " - " + currentLoc + " - bed: " + bedRef + "/" + baseBedForm + ") (bonus? " + hasBedBonus + ")")
		Debug.Trace(myScriptName + " location hour(" + hourOfDay + ")   : " + hourChance)
		Debug.Trace(myScriptName + " location nearActors : " + npcChance + " (count: " + (nearbyActorCount + nearbyActorSleepCount + nearbyLoverCount + nearbyLoverHateCount) + " / child: " + childCount + " / sleeping: " + nearbyActorSleepCount + " / lovers: " + nearbyLoverCount + " )")
		Debug.Trace(myScriptName + " location Weather(" + wClass + ") : " + weatherChance)
		Debug.Trace(myScriptName + "      	holiday bonus : " + chanceHoliday)
		Debug.Trace(myScriptName + " ------------------------- ")
		Debug.Trace(myScriptName + " reported chance     : (" + result.Chance + ")")
		Debug.Trace(myScriptName + " location sub-total  : " + chance + " (carried over to final calculation)")
		Debug.Trace(myScriptName + " -------------------------------------------------- ")
	endIf
	
	; v2.33 mid-sleep bonus
	int midSleepBonus = 0
	if (DTSleep_SettingNapOnly.GetValue() >= 1.0 && hourChance >= 0)
		int sleepHours = (DTSleep_HealthRecoverQuestP as DTSleep_HealthRecoverQuestScript).HourCount
		if (sleepHours >= 2 && sleepHours < 6)
			float hoursSinceSleep = (DTSleep_HealthRecoverQuestP as DTSleep_HealthRecoverQuestScript).GetHoursSinceLastSleepTime(gameTime)
			if (hoursSinceSleep < 2.0)
				if ((gameTime - IntimateCheckLastFailTime) < 1.0)
					midSleepBonus = 24								; recent fail--smaller bonus to not display special prompt
				elseIf (companionRelRank >= 5)
					midSleepBonus = 44
				elseIf (companionRelRank >= 3)
					midSleepBonus = 36
				else
					midSleepBonus = 25
				endIf
			endIf
		endIf
	endIf
		
	result.ChanceReal = chance
	
	result.MidSleepBonusChance = midSleepBonus
	result.NpcAdj = npcChance
	result.NearActors = nearbyActorCount
	result.HourAdj = hourChance
	result.WeatherAdj = weatherChance
	result.LocAdj = locChance
	result.LocTypeName = locName
	result.LocChecked = currentLoc
	result.HolidayBonus = chanceHoliday
	result.CheckTime = gameTime
	
	; set reported chance based on exp and area
	
	return result
EndFunction

; 1 day is neutral; fails reach -28 (-72 for too soon), and peaks +50 at 12-18 days
; uses last-intimate time unless SceneData-creature then uses dog-time if more recent - never uses dog-time for humans
;
int Function ChanceForIntimateSceneByLastTime(int companionRelRank, float gameTime, bool failReset, bool forHugs, bool outputLog = false)

	int chance = 0
	int chanceFails = 0
	int chanceSince = 0
	int failCount = IntimateCheckFailCount
	float hoursSinceLastFail = 1000.0
	float daysSinceLastIntimate = 0.0
	; check highest exp
	int exp = DTSleep_IntimateEXP.GetValueInt()
	int expStr = DTSleep_IntimateStrongExp.GetValueInt()
	int expDog = DTSleep_IntimateDogEXP.GetValueInt()
	
	if (expStr > exp)
		exp = expStr
	endIf
	if (expDog > exp)
		exp = expDog
	endIf
	
	if ((gameTime - IntimateCheckLastFailTime) < 3.0)
		hoursSinceLastFail = DTSleep_CommonF.GetGameTimeHoursDifference(gameTime, IntimateCheckLastFailTime)
	endIf
	
	if (forHugs)
		if (hoursSinceLastFail < 3.0)
			if (failCount > 0)
				chanceFails = -52 + Math.Floor(17.3333 * hoursSinceLastFail)
			else
				chanceFails = -28 + Math.Floor(9.3333 * hoursSinceLastFail)
			endIf
		endIf
	
	elseIf (IntimateCheckFailCount > 0 && companionRelRank > 1)
			
		if (hoursSinceLastFail < 4.0)
			if (companionRelRank > 3)
				chanceFails = -64 + Math.Floor(11.00 * hoursSinceLastFail)
			else
				chanceFails = -92 + Math.Floor(28.00 * hoursSinceLastFail)
			endIf
			
		elseIf (exp > 0)

			if (IntimateCheckFailCount == 1)
				chanceFails = -7
			elseIf (IntimateCheckFailCount < 4)
				
				chanceFails = -3 - (IntimateCheckFailCount * 4)
			else
				chanceFails = -20
			endIf
			
		elseIf (hoursSinceLastFail > 6.0)
		
			; no experience yet, grant bonus to help get started
			if (SceneData.IsUsingCreature)
				chanceFails = 18
			else
				if (companionRelRank >= 3)
					chanceFails = 20
				else
					chanceFails = 12
				endIf
				if (expDog == 0 && expStr == 0)
					chanceFails += 16
				endIf
			endIf
		endIf
		
	elseIf (exp == 0 && hoursSinceLastFail > 12.0 && hoursSinceLastFail < 56.0 && DTSleep_CommonF.GetGameTimeHoursDifference(gameTime, IntimateLastEmbraceTime) < 36.0)
			; v2.16 - hug negates fail-count so need to give bonus
			; no experience yet, grant bonus to help get started
			if (SceneData.IsUsingCreature)
				chanceFails = 18
			else
				if (companionRelRank >= 3)
					chanceFails = 20
				else
					chanceFails = 12
				endIf
				if (expDog == 0 && expStr == 0)
					chanceFails += 16
				endIf
			endIf
	elseIf (hoursSinceLastFail < 3.0)
		chanceFails = -28 + Math.Floor(9.3333 * hoursSinceLastFail)
		
	;elseIf ((gameTime - IntimateCheckLastDogFailTime) < 3.0)
	;	hoursSinceLastFail = DTSleep_CommonF.GetGameTimeHoursDifference(gameTime, IntimateCheckLastDogFailTime)
	;	
	;	if (hoursSinceLastFail < 1.67)
	;		; recent fail with self/dog 
	;	
	;		chanceFails = -20
	;	endIf
	endIf
	if (IntimateSucPrevTime <= 0.0)
		IntimateSucPrevTime = DTSleep_IntimateTime.GetValue() - 1.0
	endIf
	
	float daysSincePrevInt = gameTime - IntimateSucPrevTime
	daysSinceLastIntimate = gameTime - IntimateLastTime
	;float hoursSinceLastIntimate = DTSleep_CommonF.GetGameTimeHoursDifference(gameTime, DTSleep_IntimateTime.GetValue())
	
	; chance recovery and fall-off going without intimacy
	; varies by exp and creature
	; peak chance approx +50
	;
	float daysLimitPeak = 12.0			; highest chance day before fall-off; pre-calculated on dailyFactor
	float daysLimitDecline = 30.0		; fall-off limit to flat-chance 16% bonus
	float dailyFactor = 5.12			; chance gained per day until peak
	
	if (SceneData.IsUsingCreature)
		daysLimitPeak = 18.0
		daysLimitDecline = 36.0
		if (exp >= 5)
			dailyFactor = 3.733
		endIf
		
		; time since self/dog-play counts for any creature
		float daysSinceLastDogPlay = gameTime - DTSleep_IntimateDogTime.GetValue()
		
		if (daysSinceLastDogPlay < daysSinceLastIntimate)
			daysSinceLastIntimate = daysSinceLastDogPlay
		endIf
	elseIf (exp < 6)
		; beginners gain more chance per day
		daysLimitPeak = 9.0
		daysLimitDecline = 28.0
		dailyFactor = 7.62
	
	elseIf (companionRelRank < 3)
		daysLimitPeak = 16.0
		daysLimitDecline = 32.0
		dailyFactor = 2.0
		
	elseIf (exp > 31)
		; experts recover less
		daysLimitPeak = 16.0
		daysLimitDecline = 32.0
		dailyFactor = 3.733
	endIf
	
	if (SceneData.CurrentLoverScenCount > 4)
		daysLimitDecline = 60.0
	endIf
	
	if (daysSinceLastIntimate < 0.0417)
		;DTDebug(" chance intimate -- too soon!", 2)
		chanceSince = -82
		if (forHugs)
			chanceSince = -52
		elseIf (daysSincePrevInt < 0.50)
			chanceSince -= 30
		endIf
		
	elseIf (exp > 0 && daysSinceLastIntimate <= 0.967)
		if (forHugs)
			chanceSince = 0 - (52 - (52.0 * daysSinceLastIntimate) as int)
		else
			chanceSince = 0 - (75 - (75.0 * daysSinceLastIntimate) as int)
			if (daysSincePrevInt < 0.50)
				chanceSince += Math.Floor(chanceSince * 0.20)
			endIf
		endIf
		
	elseIf (exp > 0 && daysSinceLastIntimate < 1.667)
		chanceSince = 3
		
	elseIf (exp > 0 && daysSinceLastIntimate < daysLimitPeak)
	
		chanceSince = 4 + ((dailyFactor * (daysSinceLastIntimate - 1.62)) as int)

		
		if (daysSinceLastIntimate > 1.333 && failReset)
			if (IntimateCheckFailCount > 0)
				IntimateCheckFailCount -= 1
			endIf
		endIf
		
	elseIf (exp > 0 && daysSinceLastIntimate <= daysLimitDecline)
	
		chanceSince = 16 + ((daysLimitDecline as int) * 2) - (2 * Math.Floor(daysSinceLastIntimate))
		
		if (failReset)
			IntimateCheckFailCount = 0
		endIf
		
	elseIf (exp == 0)
	
		if (daysSinceLastIntimate > daysLimitDecline)
			; get after first game-month unless have fails-bonus
			chanceSince = 48
		elseIf (daysSinceLastIntimate > 0.8)
			chanceSince = 20
		endIf
		if (failReset)
			IntimateCheckFailCount = 0
		endIf
	endIf
	
	chance = chanceFails + chanceSince
	
	int sameDayPen = 0
	
	if (IntimacyDayCount > 0)
		int curDay = Math.Floor(Utility.GetCurrentGameTime())
		int intimateDay = Math.Floor(IntimateLastTime)
		if (curDay != intimateDay)
			; reset
			IntimacyDayCount = 0
		endIf
	endIf
	
	if (IntimacyDayCount > 1)
		int endurVal = (PlayerRef.GetValue((DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).EnduranceAV) as int)
																		; v2.53	- reduced penalty with more emphasis on endurance
		int penaltyFactor = 36 - (endurVal * 3) + IntimacyDayCount		; 		- removed day-count multiplier and added endurance multiplier
		if (penaltyFactor < 8)											;       - reduced min for endurance 10+
			penaltyFactor = 8
		endIf
		sameDayPen = 0 - (IntimacyDayCount * penaltyFactor)
		chance += sameDayPen
		; end=5 -- -46, -72, -100, -130
		; end=9 -- -22, -36, -52, -80
	endIf
	
	if (DTSleep_SettingTestMode.GetValueInt() > 0 && DTSleep_DebugMode.GetValue() >= 2.0)
	
		Debug.Trace(myScriptName + " -------------------------------------------------- ")
		Debug.Trace(myScriptName + " Test-Mode output - may disable in Settings ")
		Debug.Trace(myScriptName + " -------------------------------------------------- ")
		Debug.Trace(myScriptName + "      same-day score : " + sameDayPen + " with count " + IntimacyDayCount)
		Debug.Trace(myScriptName + " time-since failscore: " + chanceFails + " -- hours since last fail: " + hoursSinceLastFail + " fail count: " + IntimateCheckFailCount)
		Debug.Trace(myScriptName + " time-since sex score: " + chanceSince + " -- days since last sexy: " + daysSinceLastIntimate)
		Debug.Trace(myScriptName + " ------------------------- ")
		Debug.Trace(myScriptName + " time-since sub-total: " + chance + " (carried over to final calculation)")
		Debug.Trace(myScriptName + " -------------------------------------------------- ")
	endIf
	
	return chance

EndFunction

; convenience checks TrueLoveAlias 
int Function CompanionRelationRankForActor(Actor actorRef)
	if (actorRef == None)
		return -2
	endIf
	bool trueLove = false
	if (DTSleep_TrueLoveAlias != None)
		Actor loverActor = DTSleep_TrueLoveAlias.GetActorReference()
		if (loverActor != None && loverActor == actorRef)
			trueLove = true
		endIf
	endIf
	
	return GetRelationRankActor(actorRef, trueLove)
EndFunction

IntimateWeatherScoreSet Function ChanceForIntimateSceneWeatherScore()
	int weatherChance = -1
	IntimateWeatherScoreSet result = new IntimateWeatherScoreSet
	
	Weather cWeather = Weather.GetCurrentWeather()
		
	if (cWeather)
		result.wClass = cWeather.GetClassification()
		
		if (result.wClass == 0)      	; pleasant, dusty
			weatherChance = 6
		elseIf (result.wClass == 1)  	; cloudy
			weatherChance = -1
		elseIf (result.wClass == 2)		; rainy
			weatherChance = -10			;
		elseIf (result.wClass >= 3)		; rad-storm (snowy) - player can't Rest if taking damage
			weatherChance= -32
		else
			weatherChance = 2
		endIf
	endIf
	
	if ((DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).IsWinterSeason())
		weatherChance -= 12
		result.wClass += 10
	elseIf ((DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).IsSummerSeason())
		weatherChance += 8
	endIf

	result.Score = weatherChance
	
	return result
endFunction



int Function CheckCustomGear(int minCountShow = 0)
	
	int changeCount = (SleepPlayerAlias as DTSleep_PlayerAliasScript).CheckCustomPlayerHomes()
	changeCount += (SleepPlayerAlias as DTSleep_PlayerAliasScript).CheckCustomArmorsAndBackpacks()
	changeCount += (SleepPlayerAlias as DTSleep_PlayerAliasScript).CheckUniquePlayerFollowers()
	
	if (changeCount >= minCountShow)
		DTSleep_ModScanUpdateMsg.Show(changeCount)
	endIf
	
	return DTSleep_SettingModActive.GetValueInt()
EndFunction

Function CheckSwapSceneRolesForSameGender()

	if (IntimateCompanionSecRef != None && IntimateCompanionRef != None)
	
		if (SceneData.SameGender)
			if (SceneData.SecondFemaleRole != None || SceneData.SecondMaleRole != None)
				if (SceneData.MaleRoleGender == 1)
					DTDebug("swapping FF to FM roles " + IntimateCompanionSecRef + " to M and + " + IntimateCompanionRef + " to F2", 2)
					if (SceneData.MaleRole == PlayerRef)
						SceneData.FemaleRole = PlayerRef
					endIf
					SceneData.SecondFemaleRole = IntimateCompanionRef
					SceneData.MaleRole = IntimateCompanionSecRef
					SceneData.SecondMaleRole = None
					SceneData.SameGender = false
					SceneData.MaleRoleGender = 0
				else
					; two males
					if (SceneData.FemaleRole == PlayerRef)
						SceneData.MaleRole = PlayerRef
					endIf
					SceneData.FemaleRole = IntimateCompanionSecRef
					SceneData.SecondMaleRole = IntimateCompanionRef
					SceneData.SecondFemaleRole = None
					SceneData.SameGender = false
				endIf
			else
				;DTDebug("check swap scene roles clearing second actors -- does not meet requirements", 1)
				SceneData.SecondFemaleRole = None
				SceneData.SecondMaleRole = None
				ClearIntimateSecondCompanion()
			endIf
		endIf
	else
		DTDebug(" can't check swap scene roles - missing companions", 1)
	endIf
endFunction

Function ClearIntimateSecondCompanion()

	if (IntimateCompanionSecRef != None)
	
		; check swap back
		if (IntimateCompanionSecRef == SceneData.MaleRole)
			;DTDebug(" on clear 2nd lover swap back " + IntimateCompanionRef + " to male role ", 2)
			SceneData.MaleRole = IntimateCompanionRef
			SceneData.SameGender = true
		elseIf (IntimateCompanionSecRef == SceneData.FemaleRole)
			;DTDebug(" on clear 2nd lover swap back " + IntimateCompanionRef + " to female role ", 2)
			SceneData.FemaleRole = IntimateCompanionRef
			SceneData.SameGender = true
		endIf
	
		if (IntimateCompanionSecRef.IsInFaction(DTSleep_IntimateFaction))
			IntimateCompanionSecRef.RemoveFromFaction(DTSleep_IntimateFaction)
		endIf
		if (DTSleep_CompIntimateLover2Alias != None)
			DTSleep_CompIntimateLover2Alias.Clear()
		endIf
		IntimateCompanionSecRef.EvaluatePackage()
		IntimateCompanionSecRef = None
	endIf
endFunction

Function ClearIntimateSecondSwapWithMain()
	if (IntimateCompanionSecRef != None && IntimateCompanionRef != None)
		IntimateCompanionRef.RemoveFromFaction(DTSleep_IntimateFaction)
		IntimateCompanionRef.FollowerFollow()
		IntimateCompanionRef.EvaluatePackage()
		DTSleep_CompIntimateLover2Alias.Clear()
		
		IntimateCompanionRef = IntimateCompanionSecRef
		IntimateCompanionSecRef = None
		if (!IntimateCompanionRef.IsInFaction(DTSleep_IntimateFaction))
			IntimateCompanionRef.AddToFaction(DTSleep_IntimateFaction)
		endIf
		DTSleep_CompIntimateAlias.ForceRefTo(IntimateCompanionRef)
		ResetSceneData(true)
		SceneData.IsUsingCreature = true
		SceneData.IsCreatureType = CreatureTypeBehemoth
		SceneData.MaleRole = IntimateCompanionRef
		SceneData.FemaleRole = PlayerRef
		SceneData.MaleRoleGender = 1
	endIf
endFunction

; does not include Synth-Gen2
int Function CreatureTypeForCompanion(Actor companionRef)

	if (companionRef != None)
		if (companionRef == StrongCompanionRef)
		
			return CreatureTypeStrong
		elseIf (companionRef.HasKeyword(ActorTypeSuperMutantBehemothKY))
			return CreatureTypeBehemoth
		;elseIf (companionRef.HasKeyword(ActorTypeSynth))			; allow as human
		;	return CreatureTypeSynth
		elseIf (companionRef.HasKeyword(ActorTypeSuperMutant))
			return CreatureTypeStrong
			
		elseIf (companionRef.HasKeyword(ActorTypeRobotKY))
			
			return CreatureTypeHandy
		
		elseIf (companionRef.HasKeyword(ActorTypeDogmeatKY))
		
			return CreatureTypeDog
		endIf
	endIf
	
	return 0
endFunction

; level = 1 disables activation; -1 allows menu/pip-boy toggle
; calling this function already disabled does nothing
;
; Function DisablePlayerControls(bool abMovement = true, bool abFighting = true, bool abCamSwitch = false, \
;  bool abLooking = false, bool abSneaking = false, bool abMenu = true, bool abActivate = true, \
;  bool abJournalTabs = false, bool abVATS = true, bool abFavorites = true, bool abRunning = false) native
; https://www.creationkit.com/fallout4/index.php?title=DisablePlayerControls_-_InputEnableLayer
;
; ; zooming only works with CamSwitch which breaks the animation
;
Function DisablePlayerControlsSleep(int level = 0)
	if (SleepInputLayer != None)
		SleepInputLayer.Reset()
		Utility.Wait(0.05)
	endIf
	if (SleepInputLayer == None)
		SleepInputLayer = InputEnableLayer.Create()
	endIf
	if (level == 5)
		
		SleepInputLayer.DisablePlayerControls(true, true, false, false, true, true, true, true, true, true, false)
	elseIf (level == 6)
		;SleepInputLayer  disable activate    move,  fight, camSw, look, snk, menu, act, journ, Vats, Favs, run
		SleepInputLayer.DisablePlayerControls(true, true, true, false, true, true, true, true, true, true, true)
	elseIf (level >= 3)
		SleepInputLayer.DisablePlayerControls(false, true, true, false, true, true, true, true, true, true, true)
	elseIf (level == 2)
		;SleepInputLayer  disable activate    move,  fight, camSw, look, snk, menu, act, journ, Vats, Favs, run
		SleepInputLayer.DisablePlayerControls(true, true, true, true, true, true, true, true, true, true, true)
	elseIf (level == 1)
		;SleepInputLayer  disable activate    move,  fight, camSw, look, snk, menu, act, journ, Vats, Favs, run
		SleepInputLayer.DisablePlayerControls(true, true, true, false, true, true, true, true, true, true, true)
	elseIf (level < 0)
		;SleepInputLayer  menu enable         move,  fight, camSw, look, snk, menu, act, journ, Vats, Favs, run
		SleepInputLayer.DisablePlayerControls(false, true, true, false, false, false, true, true, true, true, true)
	else
		; 0
		SleepInputLayer.DisablePlayerControls(false, true, true, false, false, true, false, true, true, true, true)
	endIf
EndFunction

Function DisplayErrorAAF()
	DTSleep_ErrorAAFMessage.Show()
endFunction

Function DisplayTipCamera()
	if (DTSleep_SettingCamera.GetValueInt() > 0)
		DTSleep_CustomCamTipMessage.ShowAsHelpMessage("Awaken", 8.0, 30.0, 1)
	endIf
endFunction

Function DisplayTipRestNoShow()
	if (DTSleep_PlayerUsingBed.GetValue() <= 0.0 && DTSleep_RestCount.GetValueInt() <= 0)
		DTSleep_TipNoRestShowMessage.ShowAsHelpMessage("Rest", 9.0, 30.0, 1)
	endIf
endFunction

Function DisplayTipPAGlitch()
	
	; make sure marked to show
	if (MyPAGlitchTipCount == 1 && DTSleep_SettingNotifications.GetValueInt() > 0)
	
		int aafSetVal = DTSleep_SettingAAF.GetValueInt()
		
		if (aafSetVal >= 1 && aafSetVal < 3)
			MyPAGlitchTipCount = 3				; mark shown
			DTSleep_PersuadePAFlagHelpMsg.ShowAsHelpMessage("Rest", 8.0, 30.0, 1)
		elseIf (aafSetVal >= 3)
			MyPAGlitchTipCount = 2   ; no need to show 
		else
			MyPAGlitchTipCount = 0   ; reset for not ready to show
		endIf
	endIf	
endFunction

Function DisplayTipSleepMode()

	if (DTSleep_SettingNotifications.GetValue() > 0.0)
	
		if (DTSleep_SettingNapOnly.GetValue() > 0.0)
			DTSleep_SleepImmersiveTipMsg.ShowAsHelpMessage("Awaken", 6.0, 30.0, 1)
		else
			DTSleep_SleepQuickTipMsg.ShowAsHelpMessage("Awaken", 6.0, 30.0, 1)
		endIf
		
		TipSleepModeDisplayCount = 1
		
		Utility.Wait(16.25)
		if (DTSleep_PlayerUsingBed.GetValue() >= 1.0)
			TipSleepModeDisplayCount = 2
			
			DTSleep_ExitBedTipMsg.ShowAsHelpMessage("Awaken", 8.0, 30.0, 1)
		endIf
		
	endIf

endFunction

Function DisplayTipBuildStrongBed()
	if (DTSleep_SettingNotifications.GetValue() > 0.0)
		TipBuildStrongBedDisplayCount += 1
		
		DTSleep_StrongBuildBedTipMsg.ShowAsHelpMessage("Rest", 8.0, 30.0, 1)
	endIf
endFunction

Function DTDebug(string msgStr, int level)
	if (DTSleep_SettingTestMode.GetValue() > 0.0 && DTSleep_DebugMode.GetValueInt() >= level)
		Debug.Trace(myScriptName + " " + msgStr)
	endIf
endFunction

Function EnablePlayerControlsSleep()
	if (SleepInputLayer != None)
		;DTDebug(" Enable Controls", 3)

		SleepInputLayer.EnablePlayerControls()
		Utility.Wait(0.02)
		if (!SleepInputLayer.IsRunningEnabled() || !SleepInputLayer.IsFightingEnabled())
			SleepInputLayer.Reset()
		endIf
		Utility.Wait(0.03)
		
		SleepInputLayer.Delete()
	endIf
	SleepInputLayer = None 
EndFunction

Function FadeInFast(bool fast = true)
	
	if (FadeIsFadedOut)
		FadeIsFadedOut = false
		
		;DTDebug("  FadeIn, fast:" + fast, 3)
	
		if (fast)
			Game.FadeOutGame(false, true, 0.0, 0.5)
		else
			Game.FadeOutGame(false, true, 0.36, 2.6)
		endIf
		
	else
		DTDebug("  FadeIn skipped ", 3)
	endIf

EndFunction

Function FadeOutFast(bool fast = true)
	
	FadeIsFadedOut = true
	;DTDebug("  FadeOut, fast:", 3)
	
	if (fast)
		Game.FadeOutGame(true, true, 0.0, 0.2, true)
	else
		Game.FadeOutGame(true, true, 0.4, 2.1, true)
	endIf

EndFunction

IntimateBedFoundSet Function FindBedForCompanion(Actor aCompanionRef, ObjectReference closestToRef, ObjectReference notBed = None, ObjectReference notBed2 = None)

	IntimateBedFoundSet result = new IntimateBedFoundSet
	bool foundBug = false
	ObjectReference aBedRef = None
	ObjectReference closeBedRef = None
	if (notBed == None)
		notBed = SleepBedInUseRef
	endIf
	
	float distance = 1672.0				; reasonable for most areas
	if (IsLocationPrivateOrUndress())
		distance = 2100.0
	elseIf (aCompanionRef.IsInInterior())
		distance = 950.0
	endIf
	
	if (DTSleep_CompBedRestAlias != None)
		aBedRef = DTSleep_CompBedRestAlias.GetReference()
	endIf
	
	; check for bed closer to player bed -
	; note: may find beds behind locked doors causing companion to just stand dressed for bed (unable to path)
	;
	closeBedRef = DTSleep_CommonF.FindNearestOpenBedFromObject(closestToRef, DTSleep_BedList, notBed, distance, aCompanionRef, notBed2)
	
	if (closeBedRef == closestToRef)
		DTDebug(" encountered too many player-bed matches when searching bed", 1)
		foundBug = true
		closeBedRef = None
	endIf

	DTDebug(" FindBed for Companion: " + aCompanionRef + ", found close/quest beds: " + closeBedRef + " / " + aBedRef, 2)
	
	if (closeBedRef != None && closeBedRef != aBedRef)
		
		if (IntimateCompanionRef == None || IntimateCompanionRef == aCompanionRef)
			if (aBedRef == None || aBedRef == SleepBedInUseRef || aBedRef.IsFurnitureInUse())		; v1.53 alias bed may be in use
				;DTDebug(" forcing (1) bed alias to closeBed", 2)
				DTSleep_CompBedRestAlias.ForceRefTo(closeBedRef)
				aBedRef = closeBedRef
			elseIf (closeBedRef.GetDistance(SleepBedInUseRef) < aBedRef.GetDistance(SleepBedInUseRef))
				;DTDebug(" forcing (2) bed alias to closeBed", 2)
				DTSleep_CompBedRestAlias.ForceRefTo(closeBedRef)
				aBedRef = closeBedRef
			elseIf (aBedRef.HasActorRefOwner())
				; v1.54 owned check
				if (aBedRef.IsOwnedBy(aCompanionRef) == false)
					;DTDebug(" forcing (3) bed alias to closeBed", 2)
					DTSleep_CompBedRestAlias.ForceRefTo(closeBedRef)
					aBedRef = closeBedRef
				endIf
			endIf
			
		elseIf (closeBedRef != SleepBedInUseRef && DTSleep_CompBedSecondRefAlias != None)
			DTSleep_CompBedSecondRefAlias.ForceRefTo(closeBedRef)
			aBedRef = closeBedRef
		endIf
	elseIf (closeBedRef == None && aBedRef != None)
		if (aBedRef.IsFurnitureInUse())
			;DTDebug("quest bed alias in use and no other bed found", 2)
			aBedRef = None
		elseIf (aBedRef.HasActorRefOwner())
			; v1.54 owned check
			if (aBedRef.IsOwnedBy(aCompanionRef) == false)
				DTDebug("quest bed alias owned by another and no other bed found", 2)
				aBedRef = None
			endIf
		else
			; must check HasActorRefOwner is false before this
			ActorBase bedOwnerBase = aBedRef.GetActorOwner()
			if (bedOwnerBase != None)
				DTDebug("quest bed alias owned (orange) and no other bed found", 2)
			endIf
		endIf
	endIf
	
	result.BedFoundRef = aBedRef
	result.BugDetected = foundBug

	return result

endFunction

Actor Function GetNWSBarbActor()
	
	return (DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).GetNWSBarbActor()
endFunction



Actor Function GetHeatherActor()
	
	return (DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).GetHeatherActor()
EndFunction



; if a companion lover in bed then returns actor else None
;
Actor Function GetCompanionInLoveUsingBed(ObjectReference bedRef)
	
	if ((DTSConditionals as DTSleep_Conditionals).LoverRingEquipCount > 0)
	
		if (DTSleep_TrueLoveAlias != None)
			Actor loverActor = DTSleep_TrueLoveAlias.GetActorReference()
			; v2.64 - changed DTSleep_ArmorLoverRing count to worn keyword
			if (loverActor != None && loverActor.WornHasKeyword(DTSleep_LoverRingKY) && loverActor.GetDistance(PlayerRef) < 500.0)
				if (DTSleep_CommonF.IsActorOnBed(loverActor, bedRef))
				
					return loverActor
				endIf
			endIf
		endIf
		
		return None
	endIf
	
	;if (SleepCompanionAlias != None)
	;	Actor sleepCompActor = SleepCompanionAlias.GetActorReference() as Actor
	;	if (sleepCompActor != None)
	;		CompanionActorScript myCompanion = sleepCompActor as CompanionActorScript
	;		if (myCompanion != None)
	;			if (myCompanion.IsInfatuated() || myCompanion.IsRomantic())
;
	;				return sleepCompActor
	;			endIf
	;		endIf
	;	endIf
	;endIf
	
	float intimateSetting = DTSleep_SettingIntimate.GetValue()
	
	if (CompanionAlias != None)
		Actor companionActor = CompanionAlias.GetActorReference()
		if (companionActor != None && companionActor != StrongCompanionRef) 
			if (DTSleep_CommonF.IsActorOnBed(companionActor, bedRef))

				CompanionActorScript myCompanion = companionActor as CompanionActorScript
				if (myCompanion != None)
					if (myCompanion.IsRomantic())
						return companionActor
					elseIf (myCompanion.GetValue(CA_AffinityAV) >= 1000.0)
						if (DTSleep_CompanionRomanceList.HasForm(companionActor as Form))
							return companionActor
						elseIf ((intimateSetting == 2.0 || intimateSetting == 4.0) && PlayerHasPerkOfCompanion(companionActor))
							return companionActor
						endIf
					endIf
				endIf
				
				return None
			endIf
		endIf
	endIf
	
	if ((DTSConditionals as DTSleep_Conditionals).IsHeatherCompanionActive)
		
		Actor heatherActor = GetHeatherActor()
		if (heatherActor != None && heatherActor.GetDistance(PlayerRef) < 500.0)
		
			if (DTSleep_CommonF.IsActorOnBed(heatherActor, bedRef))
				; Heather doesn't use relationship
				if (IsHeatherInLove() >= 1)
					
					return heatherActor
				endIf

			endIf
		endIf
	endIf
	
	if ((DTSConditionals as DTSleep_Conditionals).IsNWSBarbActive)
		Actor barbActor = GetNWSBarbActor()
		if (barbActor != None && barbActor.GetDistance(PlayerRef) < 500.0)
			
			if (DTSleep_CommonF.IsActorOnBed(barbActor, bedRef))

				if (IsNWSBarbInLove())
					
					return barbActor
				endIf

			endIf
		endIf
	endIf
	
	if (ActiveCompanionCollectionAlias != None)
		int count = ActiveCompanionCollectionAlias.GetCount()
		int idx = 0
		
		while (idx < count)
			CompanionActorScript aCompanion = ActiveCompanionCollectionAlias.GetAt(idx) as CompanionActorScript
			if (aCompanion != None && aCompanion != StrongCompanionRef && aCompanion.GetValue(CA_AffinityAV) >= 1000.0 && aCompanion.GetDistance(PlayerRef) < 350.0)
				
				if (DTSleep_CommonF.IsActorOnBed(aCompanion, bedRef))
					
					if (DTSleep_CompanionRomanceList.HasForm(aCompanion as Form))
						return aCompanion
					elseIf ((intimateSetting == 2.0 || intimateSetting == 4.0) && PlayerHasPerkOfCompanion(aCompanion))
						return aCompanion
					endIf

					return None
				endIf
			endIf
			
			idx += 1
		endWhile
	endIf
	
	return None
EndFunction

CompanionActorScript Function GetCompanionOfActor(Actor anActor)
	
	int count = ActiveCompanionCollectionAlias.GetCount()
	int idx = 0
	;DTDebug(" ActiveCompanion Count: " + count, 3)
	
	while (idx < count)

		Actor activeComp = ActiveCompanionCollectionAlias.GetAt(idx) as Actor
		if (activeComp == anActor)
			CompanionActorScript aCompanion = activeComp as CompanionActorScript
			idx = count + 100
			
			return aCompanion
		endIf
		
		idx += 1
	endWhile
	
	return None
endFunction

bool Function PlayerHasPerkOfCompanion(Actor aCompanion, ActorBase compBase = None)
	
	; v2.21 - ensure not hate
	if (aCompanion.GetValue(CA_AffinityAV) >= 250)
		if (aCompanion == StrongCompanionRef)
			return PlayerRef.HasPerk(CompStrongPerk)
		elseIf (aCompanion == CompanionDeaconRef)
			return PlayerRef.HasPerk(CompDeaconPerk)
		elseIf (aCompanion == CompanionX6Ref)
			return PlayerRef.HasPerk(CompX6Perk)
		elseIf ((DTSConditionals as DTSleep_Conditionals).IsCoastDLCActive && (DTSConditionals as DTSleep_Conditionals).FarHarborDLCLongfellowRef != None && aCompanion == (DTSConditionals as DTSleep_Conditionals).FarHarborDLCLongfellowRef)
			return PlayerRef.HasPerk((DTSConditionals as DTSleep_Conditionals).FarHarborDLCLongfellowPerk)
			
		elseIf ((DTSConditionals as DTSleep_Conditionals).IsRobotDLCActive && (DTSConditionals as DTSleep_Conditionals).RobotAdaRef != None && aCompanion == (DTSConditionals as DTSleep_Conditionals).RobotAdaRef)
			; Ada must be human and finished DLC main quest 
			if (compBase == None)
				compBase = aCompanion.GetActorBase()
			endIf
			if (compBase != None && compBase.GetRace() == HumanRace)
				if ((DTSConditionals as DTSleep_Conditionals).RobotMQ105Quest != None && (DTSConditionals as DTSleep_Conditionals).RobotMQ105Quest.GetStageDone(1000))
					return true
				endIf
			endIf
		endIf
	endIf
	
	return false
endFunction

IntimateCompanionSet Function GetCompanionCustomInLoveOfActor(Actor anActor)

	IntimateCompanionSet result = new IntimateCompanionSet
	result.Gender = -1
	
	if ((DTSConditionals as DTSleep_Conditionals).IsHeatherCompanionActive)
		
		Actor heatherActor = GetHeatherActor()
		if (heatherActor == anActor)
			int heatherLove = IsHeatherInLove()
			if (!heatherActor.WornHasKeyword(ArmorTypePower) && heatherLove >= 1)
				result.CompanionActor = heatherActor
				result.RelationRank = 4
				result.RequiresNudeSuit = true
				
				if (heatherLove >= 2)
					result.RelationRank = 5
				endIf
				result.Gender = 1
				if (heatherActor.IsInPowerArmor())
					if (DTSleep_SettingAAF.GetValueInt() < 3)			; v2.74 consider ignore setting 3
						result.PowerArmorFlag = true
					endIf
				endIf
				
				return result
			endIf
		endIf
	endIf
	
	if ((DTSConditionals as DTSleep_Conditionals).IsNWSBarbActive)
		Actor barbActor = GetNWSBarbActor()
		
		if (barbActor == anActor)
			if (!barbActor.WornHasKeyword(ArmorTypePower) && IsNWSBarbInLove())
				result.CompanionActor = barbActor
				result.RelationRank = 4
				result.Gender = 1
				if (barbActor.IsInPowerArmor())
					if (DTSleep_SettingAAF.GetValueInt() < 3)			; v2.74 consider ignore setting 3
						result.PowerArmorFlag = true
					endIf
				endIf
				
				return result
			endIf
		endIf
	endIf

	return result
endFunction

IntimateCompanionSet[] Function GetCompanionNearbyLoversArray(int minRank = 3, Actor notActor = None)
	IntimateCompanionSet[] resultArray = new IntimateCompanionSet[0]
	int aCnt = 0
	int prefGender = DTSleep_SettingGenderPref.GetValueInt()
	
	if ((DTSConditionals as DTSleep_Conditionals).LoverRingEquipCount > 0)
	
		if (DTSleep_TrueLoveAlias != None)
			Actor loverActor = DTSleep_TrueLoveAlias.GetActorReference()
			; v2.64 - changed DTSleep_ArmorLoverRing count to worn has keyword
			if (loverActor != None && loverActor != notActor && loverActor.WornHasKeyword(DTSleep_LoverRingKY) && loverActor.GetDistance(PlayerRef) < 2000.0)
				;DTDebug("found true love ring holder " + loverActor, 2)
				if (loverActor.IsDead())
					; ummm...
					
				elseIf (!loverActor.IsUnconscious() && !loverActor.WornHasKeyword(ArmorTypePower))
					IntimateCompanionSet ics = new IntimateCompanionSet
					ics.CompanionActor = loverActor
					ics.HasLoverRing = true
					ics.RelationRank = GetRelationRankActor(loverActor, true)
					if (loverActor.IsInPowerArmor())
						if (DTSleep_SettingAAF.GetValueInt() < 3)			; v2.74 consider ignore setting 3
							ics.PowerArmorFlag = true
						endIf
					endIf
					resultArray.Add(ics)
				endIf
				
				return resultArray
			endIf
		endIf
	endIf
	
	if (prefGender >= 3 && SceneData.CurrentLoverScenCount >= 3)	
		; faithful
		Actor companionRef = None
		if (SceneData.MaleRole != None && SceneData.MaleRole != PlayerRef)
			companionRef = SceneData.MaleRole
		elseIf (SceneData.FemaleRole != None && SceneData.FemaleRole != PlayerRef)
			companionRef = SceneData.FemaleRole
		endIf
		
		if (companionRef != None && companionRef.IsEnabled() && !companionRef.IsDead())
			if (companionRef != notActor && !companionRef.IsUnconscious() && companionRef.GetDistance(PlayerRef) < 900.0 && companionRef.GetSleepState() <= 2 && !companionRef.WornHasKeyword(ArmorTypePower))
				IntimateCompanionSet ics = new IntimateCompanionSet
				ics.CompanionActor = companionRef
				CompanionActorScript aCompanion = GetCompanionOfActor(companionRef)
				
				if (aCompanion != None)
					if (aCompanion.IsRomantic())
						ics.RelationRank = 4
					elseIf (aCompanion.IsInFatuated())
						ics.RelationRank = 3
					elseIf (DTSleep_CompanionRomanceList.HasForm(companionRef as Form))
						ics.RelationRank = 3
					elseIf (minRank == 2 && PlayerHasPerkOfCompanion(companionRef))
						ics.RelationRank = 2
					endIf
					if (companionRef.IsInPowerArmor())
						if (DTSleep_SettingAAF.GetValueInt() < 3)			; v2.74 consider ignore setting 3
							ics.PowerArmorFlag = true
						endIf
					endIf
					resultArray.Add(ics)
				endIf
			endIf
			
			return resultArray
		endIf
	endIf
	
	ObjectReference[] actorArray = PlayerRef.FindAllReferencesWithKeyword(DTSleep_ActorKYList.GetAt(0), 900.0)
	
	while (actorArray != None && aCnt < actorArray.Length)
		Actor ac = actorArray[aCnt] as Actor
		
		if (ac != None && ac != notActor && ac != PlayerRef && ac.IsEnabled() && !ac.IsDead() && !ac.IsUnconscious())
			
			if ((DTSConditionals as DTSleep_Conditionals).IsWorkShop02DLCActive && (DTSConditionals as DTSleep_Conditionals).DLC05ArmorRackKY != None && ac.HasKeyword((DTSConditionals as DTSleep_Conditionals).DLC05ArmorRackKY))
				; do nothing -
				; don't want no workshop armor mannequin which is NPC
				
			elseIf (DTSleep_NotHumanList != None && DTSleep_NotHumanList.HasForm(ac as Form))
				; v2.62 not a human - do nothing
				
			elseIf (ac.GetSleepState() <= 2)
				
				CompanionActorScript aCompanion = GetCompanionOfActor(ac)
				
				if (aCompanion != None && !aCompanion.IsChild())
				
					bool isCompRomantic = aCompanion.IsRomantic()
					
					if (aCompanion.IsInfatuated() || isCompRomantic || aCompanion.GetValue(CA_AffinityAV) >= 1000.0)
						if (IsCompanionRaceCompatible(ac, None, isCompRomantic))
						
							IntimateCompanionSet ics = new IntimateCompanionSet
							ics.CompanionActor = ac
							
							if (!aCompanion.WornHasKeyword(ArmorTypePower))
								
								ics.Gender = (DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).GetGenderForActor(ac)
								
								if (prefGender == 2 || prefGender == ics.Gender)
									if (aCompanion.IsInPowerArmor())
										if (DTSleep_SettingAAF.GetValueInt() < 3)			; v2.74 consider ignore setting 3
											ics.PowerArmorFlag = true
										endIf
									endIf
									if (aCompanion.IsRomantic())
										ics.RelationRank = 4
									elseIf (aCompanion.IsInFatuated())
										ics.RelationRank = 3
									elseIf (DTSleep_CompanionRomanceList.HasForm(ac as Form))
										ics.RelationRank = 3
									elseIf (minRank == 2 && PlayerHasPerkOfCompanion(ac))
										ics.RelationRank = 2
									endIf
									
									if (ics.RelationRank >= minRank)
										

										resultArray.Add(ics)
									endIf
								endIf
							endIf
						endIf
					endIf
				else
					IntimateCompanionSet customCompSet = GetCompanionCustomInLoveOfActor(ac)
					if (customCompSet != None && customCompSet.CompanionActor != None && customCompSet.RelationRank >= minRank)
						resultArray.Add(customCompSet)
					endIf
				endIf
			endIf
		endIf
	
		aCnt += 1
	endWhile
	
	return resultArray
endFunction

; only returns companion in power armor if Danse or main companion if no other companion found 
;  -- includes Heather, Barb
;  - considers sit/sleep states otherwise returns highest rank
;  - genderOverride: if player preference both genders, this forces specific gender  (v2.15)
;
IntimateCompanionSet Function GetCompanionNearbyHighestRelationRank(bool useNudeSuit, int minRank = 3, int genderOverride = -1)
	IntimateCompanionSet result = new IntimateCompanionSet
	;Actor companionActor = None
	int topRelationRank = -1
	bool topRelBusy = false				; if top-pick is not busy then don't replace with higher rank busy
	result.RequiresNudeSuit = useNudeSuit  ; default - check mod companions
	result.PowerArmorFlag = false		; flag to avoid using in AAF scenes
	bool mainCompanionPA = false		; return if no other companions available and main in power armor to report busy-reminder
	int mainCompanionRank = 0
	int prefGender = DTSleep_SettingGenderPref.GetValueInt()
	if (genderOverride >= 0 && genderOverride <= 1 && prefGender == 2)
		prefGender = genderOverride
	endIf
	result.Gender = -1
	result.RaceIntimateCompatible = 0			; v2.60 - only set to 1 after checking race and immediate return to save time later
	
	float intimateSetting = DTSleep_SettingIntimate.GetValue()			; v2.60 extra NPCs may be 2 or 4
	
	; note: Ada from DLCRobot starts as IsInfatuated - so ensure is not a robot
	
	; v2.22 - also check alias together with count just in case
	if ((DTSConditionals as DTSleep_Conditionals).LoverRingEquipCount > 0 && DTSleep_TrueLoveAlias != None)
		; companion has a ring - consider only the ring!
		
		Actor loverActor = DTSleep_TrueLoveAlias.GetActorReference()
		DTDebug(" checking for nearby lover ring owner for actor " + loverActor, 2)
		
		if (loverActor != None && loverActor.WornHasKeyword(DTSleep_LoverRingKY) && loverActor.GetDistance(PlayerRef) < 2000.0)
			;DTDebug("found true love ring holder " + loverActor, 2)
			if (loverActor.IsDead())
				; ummm...
				DTDebug(" lover's ring wearer, " + loverActor + " is... dead.", 1)
			elseIf (loverActor.IsChild() || loverActor.HasKeyword(ActorTypeChildKY))		; v2.60
				DTDebug(" lover's ring wearer, " + loverActor + " is a child", 1)
				
			elseIf (!loverActor.IsUnconscious())
				; check if custom companion on romance list - v2.21: limit to non-ExtraNPC and check affinity before adding to list in case of bug
				if (loverActor != CompanionX6Ref && loverActor != CompanionDeaconRef && loverActor != (DTSConditionals as DTSleep_Conditionals).FarHarborDLCLongfellowRef)
					if (!DTSleep_CompanionRomanceList.HasForm(loverActor as Form))
						CompanionActorScript aCompanion = loverActor as CompanionActorScript
						if (aCompanion != None && aCompanion.IsRomantic() && aCompanion.GetValue(CA_AffinityAV) >= 1000.0)
							DTSleep_CompanionRomanceList.AddForm(loverActor)
						endIf
					endIf
				endIf
				result.CompanionActor = loverActor
				result.HasLoverRing = true
				result.RelationRank = GetRelationRankActor(loverActor, true)
				if (loverActor.WornHasKeyword(ArmorTypePower))
					mainCompanionPA = true
				elseIf (loverActor.IsInPowerArmor())
					if (DTSleep_SettingAAF.GetValueInt() < 3)			; v2.74 consider ignore setting 3
						result.PowerArmorFlag = true
					endIf
				endIf
				;result.Gender = (DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).GetGenderForActor(loverActor)
			else
				DTDebug(" lover's ring wearer, " + loverActor + " is... unconscience.", 1)
			endIf
		endIf
	else
		;DTDebug(" checking for nearby lovers...", 2)
		
		if (PlayerHasActiveCompanion.GetValueInt() > 0 && CompanionAlias != None)
		
			; *********     main companion
			; *
			; v2.51 don't mark seated main companion busy if is faithful lover
			; 
			CompanionActorScript aCompanion = CompanionAlias.GetActorReference() as CompanionActorScript
			
			if (aCompanion != None && aCompanion.IsEnabled() && !aCompanion.IsDead() && !aCompanion.IsUnconscious())
			
				; check NoraSpouse and DualSurvivor first - assume in love
				Actor noraCompRef = (DTSConditionals as DTSleep_Conditionals).NoraSpouseRef
				;if (noraCompRef == None)
				;	noraCompRef = (DTSConditionals as DTSleep_Conditionals).NoraSpouse2Ref
				;endIf
				if (noraCompRef != None && aCompanion == noraCompRef)
				
					if (aCompanion.GetDistance(PlayerRef) < 1800.0)
						result.CompanionActor = noraCompRef
						result.HasLoverRing = false
						result.RelationRank = 4
						if (aCompanion.IsRomantic() || aCompanion.GetValue(CA_AffinityAV) >= 900.0)
							result.RelationRank = 5
						endIf
						if (aCompanion.WornHasKeyword(ArmorTypePower))
							mainCompanionPA = true
						elseIf (aCompanion.IsInPowerArmor())
							if (DTSleep_SettingAAF.GetValueInt() < 3)			; v2.74 consider ignore setting 3
								result.PowerArmorFlag = true
							endIf
						endIf
						if (aCompanion.GetSitState() <= 1 && aCompanion.GetSleepState() <= 2)
							topRelBusy = false
							if (SceneData.CurrentLoverScenCount >= 10)			; v2.53
								; main companion same lover, return now
								return result
							endIf
						elseIf (!mainCompanionPA)
							if (SceneData.CurrentLoverScenCount >= 5)			; v2.51
								; main companion same lover, don't mark busy
								topRelBusy = false
								if (SceneData.CurrentLoverScenCount >= 10)
									return result
								endIf
							else
								topRelBusy = true
							endIf
						endIf
					endIf
					
				elseIf ((DTSConditionals as DTSleep_Conditionals).DualSurvivorsNateRef != None && aCompanion == (DTSConditionals as DTSleep_Conditionals).DualSurvivorsNateRef)
					if (aCompanion.GetDistance(PlayerRef) < 1800.0)
						result.CompanionActor = (DTSConditionals as DTSleep_Conditionals).DualSurvivorsNateRef
						result.HasLoverRing = false
						result.RelationRank = 4
						if (aCompanion.IsRomantic() || aCompanion.GetValue(CA_AffinityAV) >= 900.0)
							result.RelationRank = 5
						endIf
						if (aCompanion.WornHasKeyword(ArmorTypePower))
							mainCompanionPA = true
						elseIf (aCompanion.IsInPowerArmor())
							if (DTSleep_SettingAAF.GetValueInt() < 3)			; v2.74 consider ignore setting 3
								result.PowerArmorFlag = true
							endIf
						endIf
						
						if (aCompanion.GetSleepState() <= 2)
							if (aCompanion.GetSitState() <= 1)
								topRelBusy = false
							elseIf (SceneData.CurrentLoverScenCount >= 5)			; v2.51
								; main companion same lover, don't mark busy
								topRelBusy = false
								if (SceneData.CurrentLoverScenCount >= 10)
									return result
								endIf
							else
								topRelBusy = true
							endIf
						else
							topRelBusy = true
						endIf
					endIf
				elseIf ((DTSConditionals as DTSleep_Conditionals).InsaneIvyRef != None && aCompanion == (DTSConditionals as DTSleep_Conditionals).InsaneIvyRef)
					; v2.86 - make Ivy higher rank - she becomes romantic near start after her voucher quest
					if (aCompanion.GetDistance(PlayerRef) < 1800.0)
						
						result.CompanionActor = (DTSConditionals as DTSleep_Conditionals).InsaneIvyRef
						result.HasLoverRing = false
						result.RelationRank = 4
						
						if (aCompanion.IsRomantic())
							result.RelationRank = 5
						endIf
						
						if (aCompanion.WornHasKeyword(ArmorTypePower))
							mainCompanionPA = true
						elseIf (aCompanion.IsInPowerArmor())
							if (DTSleep_SettingAAF.GetValueInt() < 3)	
								result.PowerArmorFlag = true
							endIf
						endIf
						if (aCompanion.GetSitState() <= 1 && aCompanion.GetSleepState() <= 2)
							topRelBusy = false
							if (SceneData.CurrentLoverScenCount >= 10)			
								; main companion same lover, return now
								return result
							endIf
						elseIf (!mainCompanionPA)
							if (SceneData.CurrentLoverScenCount >= 5)			
								; main companion same lover, don't mark busy
								topRelBusy = false
								if (SceneData.CurrentLoverScenCount >= 10)
									return result
								endIf
							else
								topRelBusy = true
							endIf
						endIf
					endIf
				
				elseIf (IsFPFPMarriedActor(aCompanion as Actor))
					; Family Planning Enhanced Redux married  - v2.71
					result.CompanionActor = aCompanion as Actor
					result.RelationRank = 4
					if (aCompanion.WornHasKeyword(ArmorTypePower))
						mainCompanionPA = true
					elseIf (aCompanion.IsInPowerArmor())
						if (DTSleep_SettingAAF.GetValueInt() < 3)			; v2.74 consider ignore setting 3
							result.PowerArmorFlag = true
						endIf
					endIf
					if (aCompanion.GetSleepState() > 2)
						topRelBusy = true
					else
						return result
					endIf
					
				elseIf (minRank <= 2 && (intimateSetting == 2.0 || intimateSetting == 4.0))
					; ---- optional extra NPCs -------------
					
					if (aCompanion == StrongCompanionRef)
					 
						if (!(DTSConditionals as DTSleep_Conditionals).IsVulpineRacePlayerActive)
							if (prefGender == 2 || prefGender == 0)
								if (DressData.PlayerGender == 1 && PlayerRef.HasPerk(CompStrongPerk) && aCompanion.GetValue(CA_AffinityAV) >= 900.0)
								
									float distance = aCompanion.GetDistance(PlayerRef)
									if (distance < 1200.0)
										result.CompanionActor = aCompanion as Actor
										result.RelationRank = 2   ; default 
										
										if (IntimacySMCount >= 40)
											result.RelationRank = 4
										elseIf (IntimacySMCount >= 20)
											result.RelationRank = 3
										elseIf (PlayerHasMutantTreats())
											result.RelationRank = 3
										endIf
										result.RaceIntimateCompatible = 1
									
										return result
									endIf
								endIf
							endIf
						endIf
					elseIf (aCompanion.HasKeyword(ActorTypeRobotKY) && (DTSConditionals as DTSleep_Conditionals).RobotAdaRef != None && aCompanion != (DTSConditionals as DTSleep_Conditionals).RobotAdaRef)
						if (intimateSetting == 2.0 && DressData.PlayerGender == 1 && DTSleep_AdultContentOn.GetValue() >= 2.0 && (DTSConditionals as DTSleep_Conditionals).ImaPCMod)
							float distance = aCompanion.GetDistance(PlayerRef)
							if (distance < 1200.0)
								if (IsCompanionRaceCompatible(aCompanion as Actor, None, false))
									result.RaceIntimateCompatible = 1
									result.CompanionActor = aCompanion as Actor
									result.RelationRank = 3   ; default

									if (aCompanion.GetValue(CA_AffinityAV) >= 600.0)
										result.RelationRank = 4
									endIf
									
									return result
								endIf
							endIf
						endIf
						
					elseIf (PlayerHasPerkOfCompanion(aCompanion as Actor))
					
						bool affinityOk = false
						bool genderOkay = true
						
						if ((DTSConditionals as DTSleep_Conditionals).IsRobotDLCActive && (DTSConditionals as DTSleep_Conditionals).RobotAdaRef != None && aCompanion == (DTSConditionals as DTSleep_Conditionals).RobotAdaRef)
							; Ada normally starts at 1000 affinity, but never changes affinity so let's not assume
							affinityOk = true
						elseIf (aCompanion.GetValue(CA_AffinityAV) >= 900.0)
							affinityOk = true
						endIf
						
						if (prefGender >= 3 && SceneData.CurrentLoverScenCount >= 3)
							; faithful
							if (aCompanion != SceneData.MaleRole && aCompanion != SceneData.FemaleRole)
								genderOkay = false
							endIf
						elseIf (prefGender < 2)
							int compGender = (DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).GetGenderForActor(aCompanion as Actor)
							if (prefGender != compGender)
								genderOkay = false
							endIf
						endIf
						
						if (genderOkay && affinityOk)
							float distance = aCompanion.GetDistance(PlayerRef)
							
							if (distance < 900.0 && !aCompanion.WornHasKeyword(ArmorTypePower))
								if (aCompanion.IsInPowerArmor())
									DTDebug("power armor bug for extra NPC " + aCompanion, 1)
									if (DTSleep_SettingAAF.GetValueInt() < 3)			; v2.74 consider ignore setting 3
										result.PowerArmorFlag = true
									endIf
								endIf
								result.CompanionActor = aCompanion as Actor
								if (aCompanion.IsRomantic())
									; must be a romance mod  -v2.18
									DTDebug(" romantic extra NPC - " + aCompanion, 2)
									result.RelationRank = 3
									topRelationRank = 3
								else
									result.RelationRank = 2
									topRelationRank = 2
								endIf
								if (aCompanion.GetSleepState() <= 2)
									if (aCompanion.GetSitState() <= 1)
										topRelBusy = false
									elseIf (SceneData.CurrentLoverScenCount >= 5)			; v2.51
										; main companion same lover, don't mark busy
										topRelBusy = false
										if (SceneData.CurrentLoverScenCount >= 10)
											return result
										endIf
									else
										topRelBusy = true
									endIf
								else
									topRelBusy = true 
								endIf
							endIf
						endIf
					endIf
					
				endIf ; -------------------------- end extra NPCs
				
				; affinity over 1000 should be infatuated, but check for game bug by including romance list
				
				if (aCompanion.IsInfatuated() || aCompanion.IsRomantic() || DTSleep_CompanionRomanceList.HasForm((aCompanion as Actor) as Form))
					
					float distance = aCompanion.GetDistance(PlayerRef)
					bool isCompRomantic = aCompanion.IsRomantic()
					bool genderOkay = true
					float compAffinity = aCompanion.GetValue(CA_AffinityAV)
					
					; v1.60 - remember: extra NPCs may show as infatuated and we've already considered these above
					if (aCompanion == StrongCompanionRef)
						; skip
					elseIf (!isCompRomantic && (aCompanion == CompanionDeaconRef || aCompanion == CompanionX6Ref))
						;DTDebug("GetCompanion Alias Romance-able - skip check Extra-NPC " + aCompanion, 2)
					elseIf (!isCompRomantic && (DTSConditionals as DTSleep_Conditionals).IsCoastDLCActive && (DTSConditionals as DTSleep_Conditionals).FarHarborDLCLongfellowRef != None && aCompanion == (DTSConditionals as DTSleep_Conditionals).FarHarborDLCLongfellowRef)
						;DTDebug("GetCompanion Alias Romance-able - skip check Extra-NPC " + aCompanion, 2)
					elseIf (!isCompRomantic && (DTSConditionals as DTSleep_Conditionals).IsRobotDLCActive && (DTSConditionals as DTSleep_Conditionals).RobotAdaRef != None && aCompanion == (DTSConditionals as DTSleep_Conditionals).RobotAdaRef)
						;DTDebug("GetCompanion Alias Romance-able - skip check Extra-NPC " + aCompanion, 2)
					
					elseIf (distance < 1800.0 && !aCompanion.IsChild() && compAffinity > 900.0)
						; v2.82 include condition, Affinity, before check race-compatibility
						
						if (IsCompanionRaceCompatible((aCompanion as Actor), None, isCompRomantic))
						
							if (aCompanion.WornHasKeyword(ArmorTypePower))
								mainCompanionPA = true
								topRelBusy = false
								;DTDebug("main companion in PA " + aCompanion, 2)
							endIf
								
							genderOkay = true
							if (prefGender >= 3 && SceneData.CurrentLoverScenCount >= 3)
								; faithful
								if (aCompanion != SceneData.MaleRole && aCompanion != SceneData.FemaleRole)
									genderOkay = false
								endIf
							elseIf (prefGender < 2)
								if (SceneData.IsCreatureType == CreatureTypeHandy)
									if (prefGender != 0)
										genderOkay = false
									endIf
								else
									int compGender = (DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).GetGenderForActor(aCompanion as Actor)
									if (prefGender != compGender)
										genderOkay = false
									endIf
								endIf
							endIf
							
							if (genderOkay)
								bool sleeping = false
								bool sitting = false
								if (aCompanion.GetSitState() >= 2)
									sitting = true
								endIf
								if (aCompanion.GetSleepState() >= 3)
									sleeping = true
								endIf
							
								if (!mainCompanionPA && aCompanion.IsInPowerArmor())
									; power armor is a race change - AAF will try and fail to exit power armor
									
									;DTDebug(" InPowerArmor Race, but not Worn TypePower for ", 3)
									if (DTSleep_SettingAAF.GetValueInt() < 3)			; v2.74 consider ignore setting 3
										result.PowerArmorFlag = true
									endIf
									result.RequiresNudeSuit = true
								endIf
								
								if (isCompRomantic)
									
									; only return if not sitting or sleeping - mark companion
									if (!mainCompanionPA)
										result.CompanionActor = aCompanion as Actor
										result.RelationRank = 4
										topRelationRank = 4
										
										if (!sitting && !sleeping)
											; ready now
											;result.Gender = (DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).GetGenderForActor(aCompanion)
											result.RaceIntimateCompatible = 1
											return result
										elseIf (SceneData.CurrentLoverScenCount >= 5 && !sleeping)			; v2.51
											; main companion same lover, don't mark busy
											topRelBusy = false
											if (SceneData.CurrentLoverScenCount >= 10)
												result.RaceIntimateCompatible = 1
												return result
											endIf
										else
											topRelBusy = true
										endIf
									endIf
									mainCompanionRank = 4
								elseIf (IsFPFPMarriedActor(aCompanion as Actor))
									; Family Planning Enhanced Redux married  - v2.71
									result.CompanionActor = aCompanion as Actor
									result.RelationRank = 4
									if (aCompanion.WornHasKeyword(ArmorTypePower))
										mainCompanionPA = true
									elseIf (aCompanion.IsInPowerArmor())
										if (DTSleep_SettingAAF.GetValueInt() < 3)			; v2.74 consider ignore setting 3
											result.PowerArmorFlag = true
										endIf
									endIf
									if (aCompanion.GetSleepState() > 2)
										topRelBusy = true
									else
										return result
									endIf
									
								elseIf (aCompanion.IsInfatuated())
									
									if (!mainCompanionPA)
										topRelationRank = 3
										result.CompanionActor = aCompanion as Actor
										result.RelationRank = 3
										if (!sitting && !sleeping)
											topRelBusy = false
										elseIf (SceneData.CurrentLoverScenCount >= 5 && !sleeping)			; v2.51
											; main companion same lover, don't mark busy
											topRelBusy = false
										else
											topRelBusy = true
										endIf
									endIf
									mainCompanionRank = 3
									
								elseIf (DTSleep_SettingShowIntimateCheck.GetValue() > 0.0 && compAffinity >= 1000.0)
									; allow even without extra NPCs
									DTDebug("not romanced/infatuated (or possible game romance bug) with " + aCompanion, 1)
									if (!mainCompanionPA)
										topRelationRank = 3
										result.RelationRank = 3
										result.CompanionActor = aCompanion as Actor
										if (!sitting && !sleeping)
											topRelBusy = false
										elseIf (SceneData.CurrentLoverScenCount >= 5 && !sleeping)			; v2.51
											; main companion same lover, don't mark busy
											topRelBusy = false
											
										else
											topRelBusy = true
										endIf
									endIf
									mainCompanionRank = 3
								endIf
							endIf    ; end genderOkay
						endIf ; end race-compatibility
					endIf
				endIf
			endIf
		endIf			; ********  end main companion
		
		if ((DTSConditionals as DTSleep_Conditionals).IsHeatherCompanionActive && prefGender >= 1)
			
			Actor heatherActor = GetHeatherActor()
			if (heatherActor != None && heatherActor.IsEnabled() && !heatherActor.IsDead() && !heatherActor.IsUnconscious() && heatherActor.GetDistance(PlayerRef) < 1300.0)
			
				bool paBug = false
				
				if (!heatherActor.WornHasKeyword(ArmorTypePower))
					
					if (heatherActor.IsInPowerArmor())
						; power armor is a race change - seems to cause problems
						result.RequiresNudeSuit = true
						paBug = true
						;DTDebug(" InInPowerArmor Race, but not Worn TypePower for Heather!!", 3)
						
					endIf
					
					int heatherLove = IsHeatherInLove()
					if (heatherLove >= 1)
						bool sitting = false
						bool sleeping = false
						bool okayToSelect = true
						
						if (heatherActor.GetSitState() > 1)
							sitting = true
						endIf
						if (heatherActor.GetSleepState() > 2)
							sleeping = true
						endIf
						
						if (sitting || sleeping)
							if (topRelationRank >= 2 && !topRelBusy)
								okayToSelect = false
							elseIf (mainCompanionPA)
								okayToSelect = false
							endIf
						endIf
						if (prefGender >= 3 && SceneData.CurrentLoverScenCount >= 3)
							; faithful
							if (SceneData.FemaleRole != heatherActor && SceneData.MaleRole != heatherActor)
								
								okayToSelect = false
							endIf
						endIf
						
						; if found a companion only replace if not sitting or sleeping
						if (okayToSelect && (topRelationRank < 4 || topRelBusy))
							topRelationRank = 4
							if (heatherLove >= 2)
								topRelationRank = 5
							endIf
							result.CompanionActor = heatherActor
							result.RelationRank = topRelationRank
							result.PowerArmorFlag = paBug
							result.RequiresNudeSuit = true
							result.Gender = 1
							if (!sitting && !sleeping)
								; only return if not sleeping in case another companion found
								return result
							else
								topRelBusy = true
							endIf
						endIf
					endIf
				endIf
			endIf
		endIf
		
		if ((DTSConditionals as DTSleep_Conditionals).IsNWSBarbActive && prefGender >= 1)
			Actor barbActor = GetNWSBarbActor()
			
			if (barbActor && barbActor.IsEnabled() && !barbActor.IsDead() && !barbActor.IsUnconscious())
				if (barbActor.GetDistance(PlayerRef) < 1500.0)
		
					bool paBug = false
					if (IsCompanionPowerArmorGlitched(barbActor, true))
					
						result.RequiresNudeSuit = true
						paBug = true
						;DTDebug(" InInPowerArmor Race, but not Worn TypePower for nwsBarb!!", 3)
					endIf
					
					if (IsNWSBarbInLove())
						bool sitting = false
						bool sleeping = false
						bool okayToSelect = true
						
						if (barbActor.GetSitState() > 1)
							sitting = true
						endIf
						if (barbActor.GetSleepState() > 2)
							sleeping = true
						endIf
						
						if (sitting || sleeping)
							if (topRelationRank >= 2 && !topRelBusy)
								okayToSelect = false
							elseIf (mainCompanionPA)
								okayToSelect = false
							endIf
						endIf
						if (prefGender >= 3 && SceneData.CurrentLoverScenCount >= 3)
							if (SceneData.FemaleRole != barbActor && SceneData.MaleRole != barbActor)
								okayToSelect = false
							endIf
						endIf
						if (okayToSelect && (topRelationRank < 4 || topRelBusy))
							topRelationRank = 4
							result.CompanionActor = barbActor
							result.RelationRank = topRelationRank
							result.PowerArmorFlag = paBug
							result.Gender = 1
							if (!sitting && !sleeping)
								; only return if not sleeping
								return result
							else
								topRelBusy = true
							endIf
						endIf
					endIf
				endIf
			endIf
		endIf
		
		; ------------- 
		; v1.02 - don't allow non-following companions nearby unless settings for reduced conversations or AFT or EFF
		;  --- HasGamesetReducedConv must be true -- see DTSleep_PlayerAliasScript-CheckGameSettings
		; 1) speeds up checks
		; 2) some companions not following initiate dialog often
		;
		bool okayToInspect = false
		
		;DTDebug("okay to inspect others? topRelBusy: " + topRelBusy + " topRelationRank: " + topRelationRank + " actor? " + result.CompanionActor, 2)
		
		if (topRelBusy || topRelationRank <= 3)
			okayToInspect = (DTSConditionals as DTSleep_Conditionals).IsAFTActive
			if (!okayToInspect)
				if ((DTSConditionals as DTSleep_Conditionals).IsEFFActive)
					okayToInspect = true
				else
					okayToInspect = (DTSConditionals as DTSleep_Conditionals).HasGamesetReducedConv
				endIf
			endIf
		endIf
		
		if (ActiveCompanionCollectionAlias != None && okayToInspect) 
		
			int count = ActiveCompanionCollectionAlias.GetCount()
			int idx = 0
			;DTDebug(" ActiveCompanion Count: " + count, 2)
			
			while (idx < count)
		
				Actor activeComp = ActiveCompanionCollectionAlias.GetAt(idx) as Actor
				
				; v1.25 - extra NPCs may show as infatuated and must be main companion for consideration, so skip here
				if (activeComp == StrongCompanionRef || activeComp == CompanionDeaconRef || activeComp == CompanionX6Ref)
					
				elseIf (activeComp != None && (DTSConditionals as DTSleep_Conditionals).IsCoastDLCActive && (DTSConditionals as DTSleep_Conditionals).FarHarborDLCLongfellowRef != None && activeComp == (DTSConditionals as DTSleep_Conditionals).FarHarborDLCLongfellowRef)
					
				elseIf (activeComp != None && (DTSConditionals as DTSleep_Conditionals).IsRobotDLCActive && (DTSConditionals as DTSleep_Conditionals).RobotAdaRef != None && activeComp == (DTSConditionals as DTSleep_Conditionals).RobotAdaRef)
					; v1.60 - must also check Ada for human-Ada mods
					
				elseIf (activeComp != None && !activeComp.IsDead() && !activeComp.IsUnconscious())
				
					bool okayToSelect = true
					if (prefGender >= 3 && SceneData.CurrentLoverScenCount >= 3)
						; faithful
						if (SceneData.FemaleRole != activeComp && SceneData.MaleRole != activeComp)
							okayToSelect = false
						endIf
					endIf
					
					; v2.60 skip if same as main companion
					if (okayToSelect && result.CompanionActor != None && result.CompanionActor == activeComp)
						okayToSelect = false
					endIf
					
					CompanionActorScript aCompanion = activeComp as CompanionActorScript
					useNudeSuit = false
					
					
					if (okayToSelect && result.RelationRank < 4 && aCompanion != None && (aCompanion.IsInfatuated() || aCompanion.IsRomantic()))
						bool isCompRomantic = aCompanion.IsRomantic()
						float distance = aCompanion.GetDistance(PlayerRef)

						; v2.18 - fix Valentine picked even if not romanced
						if (distance < 900.0 && !aCompanion.IsChild() && IsCompanionRaceCompatible(activeComp, None, isCompRomantic))
							
							if (!aCompanion.WornHasKeyword(ArmorTypePower))
							
								bool sitting = false
								bool sleeping = false
								if (aCompanion.GetSitState() >= 2)
									sitting = true
								endIf
								if (aCompanion.GetSleepState() >= 3)
									sleeping = true
								endIf
							
								;DTDebug(" nearby friend/lover: " + aCompanion + " sitState: " + aCompanion.GetSitState(), 2)
							
								if (aCompanion.IsInPowerArmor())
									; power armor is a race change that may hurt our animations and undressing
									;DTDebug(" InPowerArmor Race, but not Worn TypePower for " + aCompanion, 3)
									
									useNudeSuit = true
								endIf
								
								bool genderOkay = true
								if (prefGender < 2)
									int compGender = (DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).GetGenderForActor(aCompanion as Actor)
									if (prefGender != compGender)
										genderOkay = false
									endIf
								endIf
								
								if (genderOkay)
									if (isCompRomantic)
									
										; if found a companion only replace if not sitting or sleeping
										if (topRelationRank < 4)
											bool readyToGo = false
											if (!sitting && !sleeping)
												readyToGo = true
											endIf
											if (topRelBusy || readyToGo || topRelationRank <= 2)
												
												topRelationRank = 4
												result.CompanionActor = aCompanion as Actor
												result.RelationRank = 4
												result.RequiresNudeSuit = useNudeSuit
												result.PowerArmorFlag = useNudeSuit
												if (readyToGo)
													result.RaceIntimateCompatible = 1
													return result
												else
													topRelBusy = true
												endIf
											endIf
										endIf
										
									elseIf (aCompanion.IsInfatuated())
									
										; if found a companion only replace if not sitting or sleeping
										if (topRelationRank < 3)
										
											if (topRelBusy || (!sitting && !sleeping))
												result.CompanionActor = aCompanion as Actor
												result.RelationRank = 3
												result.RequiresNudeSuit = useNudeSuit
												result.PowerArmorFlag = useNudeSuit
												;DTDebug("active- isInfatuated: " + aCompanion, 2)
											endIf
										endIf
									endIf
								endIf ; end genderOkay
							endIf  ; end not in power armor
						endIf  ; end distance
					endIf  ; end rank
				endIf
				
				idx += 1
			endWhile
		endIf        ; end okay inspect nearby
	endIf			; end consider ring or not
	
	if (result.CompanionActor == None && mainCompanionPA && mainCompanionRank >= 3)
		result.CompanionActor = (CompanionAlias.GetActorReference() as CompanionActorScript) as Actor
		result.RelationRank = mainCompanionRank
		DTDebug("on final -- main companion in PA " + result.CompanionActor, 2)
		
	elseIf (topRelBusy) 
		; TODO: do we need to?
		DTDebug("top relation actor busy (clearing) " + result.CompanionActor, 2)
		;result.CompanionActor = None
		;result.RelationRank = 0
	endIf

	if (result.CompanionActor != None && result.Gender < 0)
		result.Gender = (DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).GetGenderForActor(result.CompanionActor)
	endIf
	
	;DTDebug(" GetCompanionTop return " + result.CompanionActor, 2)
	
	return result
EndFunction

ObjectReference Function GetDanceProp(ObjectReference nearFurniture)

	if (DTSleep_AdultContentOn.GetValue() >= 2.0 && DressData.PlayerGender == 1 && (DTSConditionals as DTSleep_Conditionals).ImaPCMod)
		if ((DTSConditionals as DTSleep_Conditionals).SavageCabbageVers >= 1.10)
			
			return DTSleep_CommonF.FindNearestObjectInListFromObjRef(DTSleep_FlagpoleList, nearFurniture, 950.0, true)
		endIf
	endIf
	
	return None
endFunction

int Function GetRelationRankActor(Actor actorRef, bool isTrueLove)

	if (actorRef == None)
		return -1
	endIf
	int romanceRank = 4
	if (isTrueLove)
		romanceRank = 5
	endIf
	if (DTSleep_CompanionRomanceList.HasForm(actorRef))
		CompanionActorScript compActor = actorRef as CompanionActorScript
		if (compActor.IsRomantic())
			return romanceRank
		elseIf (compActor.IsInFatuated())
			return romanceRank - 1
		elseIf ((DTSConditionals as DTSleep_Conditionals).NoraSpouseRef != None && actorRef == (DTSConditionals as DTSleep_Conditionals).NoraSpouseRef)
			return romanceRank
		elseIf ((DTSConditionals as DTSleep_Conditionals).NoraSpouse2Ref != None && actorRef == (DTSConditionals as DTSleep_Conditionals).NoraSpouse2Ref)
			return romanceRank
		elseIf ((DTSConditionals as DTSleep_Conditionals).DualSurvivorsNateRef != None && actorRef == (DTSConditionals as DTSleep_Conditionals).DualSurvivorsNateRef)
			return romanceRank
		elseIf (actorRef.GetValue(CA_AffinityAV) >= 1000.0)
			return romanceRank - 1
		else
			; affinity too low
			return 1
		endIf
		
	; extras always return normal rank even if with ring
	elseIf (actorRef == CompanionDeaconRef)
		return 2
	elseIf (actorRef == CompanionX6Ref)
		return 2
	elseIf ((DTSConditionals as DTSleep_Conditionals).IsCoastDLCActive && (DTSConditionals as DTSleep_Conditionals).FarHarborDLCLongfellowRef != None && actorRef == (DTSConditionals as DTSleep_Conditionals).FarHarborDLCLongfellowRef)
		return 2
	elseIf (actorRef == StrongCompanionRef)
		return 1	; base
		
	; custom companions
	elseIf ((DTSConditionals as DTSleep_Conditionals).IsHeatherCompanionActive && actorRef == GetHeatherActor())
		int heatherLove = IsHeatherInLove()
		if (heatherLove >= 2)
			return 5
		elseIf (isTrueLove || heatherLove >= 1)
			return romanceRank
		endIf
		
	elseIf ((DTSConditionals as DTSleep_Conditionals).IsNWSBarbActive && actorRef == GetNWSBarbActor())
		if (isTrueLove || IsNWSBarbInLove())
			return romanceRank
		endIf
	elseIf ((DTSConditionals as DTSleep_Conditionals).IsRobotDLCActive && actorRef == (DTSConditionals as DTSleep_Conditionals).RobotAdaRef)
		return 2
	endIf
	
	; unknown custom
	if (isTrueLove)
		return 3
	endIf

	return 1
endFunction


Function GoFirstPerson()
	Utility.Wait(0.333)
	if (DTSleep_WasPlayerThirdPerson.GetValue() < 0.0)

		Game.ForceFirstPerson()
	endIf
EndFunction

Function GoThirdPerson(bool override)

	int limit = 2
	if (override)
		limit = 3
	endIf
	
	if (DTSleep_VR.GetValueInt() < limit)				;v3.0
		if (PlayerRef.GetAnimationVariableBool("IsFirstPerson"))
			
			DTSleep_WasPlayerThirdPerson.SetValue(-1.0)
		else
			DTSleep_WasPlayerThirdPerson.SetValue(1.0)
		endIf
		Game.ForceThirdPerson()
	endIf
EndFunction

;------------------
; in v3.03 now only bed -- seat uses its own
;
Function HandleExitBed()
	
	PlayerSleepPerkRemove()		; hide until out
	Utility.Wait(1.333)
	
	MainQSceneScriptP.GoSceneViewDone(false)
	Utility.Wait(0.333)
	
	if ((DTSConditionals as DTSleep_Conditionals).IsPlayerCommentsActive)
		ModPlayerCommentsEnable()
	endIf

	EnablePlayerControlsSleep()
	
	Location currentLoc = (SleepPlayerAlias as DTSleep_PlayerAliasScript).CurrentLocation
	CheckMessages(currentLoc)
	
	SleepBedIsPillowBed = false
	
	; v1.57 - increase from 4.5 to 5.25 to ensure after auto-save -- once did not restore until change location
	StartTimer(5.25, PlayerSleepPerkTimerID) ; wait a bit extra to prevent activate bed/storage too soon
	
	if (DTSleep_SettingNapOnly.GetValue() > 0.0 && DTSleep_IsSoSActive.GetValue() <= 1.0)
	
		int sleepHours = (DTSleep_HealthRecoverQuestP as DTSleep_HealthRecoverQuestScript).HourCount
		float curTime = Utility.GetCurrentGameTime()
		int contHourLimit = 4
		
		if (sleepHours >= 2 && sleepHours <= contHourLimit)

			if (DTSleep_SettingNotifications.GetValue() > 0.0)
				Utility.Wait(0.4)
				float hoursSinceSleep = DTSleep_CommonF.GetGameTimeHoursDifference(curTime, DTSleep_HRLastSleepTime.GetValue())
				float hoursLeft = (2.33 - hoursSinceSleep) 
				
				int hoursInt = Math.Floor(hoursLeft)
				if (hoursLeft > 1.7500)
					hoursInt = 2
				elseIf (hoursLeft > 0.8330)
					hoursInt = 1
				endIf
				if (hoursInt >= 1)
					DTSleep_NapContinueMsg.Show(hoursInt as float)
				endIf
			endIf
		endIf
		
		if (DTSleep_SettingSave.GetValue() > 0.0)
			
			bool saveOK = false
			int hourLimit = 2
			int sleepPrefVal = DTSleep_SettingSave.GetValueInt()
			float hourSinceLimit = 3.2			; v3.0 reduced by 5
			
			if (sleepPrefVal == 2)
				hourLimit = 5
			elseIf (sleepPrefVal >= 3)			; allow save on get in-out of bed v3.0
				hourLimit = 0
				if (Game.GetDifficulty() < 6)
					hourSinceLimit = 1.01		; non-survival 
				endIf
			endIf
			
			if (sleepPrefVal >= 3 && !(DTSleep_HealthRecoverQuestP as DTSleep_HealthRecoverQuestScript).SleepStarted)
				saveOK = true			; okay to save when get-in-and-out of bed  v3.02
			
			elseIf (sleepHours >= hourLimit && (DTSleep_HealthRecoverQuestP as DTSleep_HealthRecoverQuestScript).SleepStarted)
				saveOK = true
			endIf
			
			if (saveOK && LastGameSaveTime > 0.0)
				; check minimum time since last save 
				float hoursSince = DTSleep_CommonF.GetGameTimeHoursDifference(curTime, LastGameSaveTime)
				if (hoursSince < hourSinceLimit)
					saveOK = false
				endIf
			endIf
			
			if (saveOK)
				;DTSleep_SaveMessage.Show()  ; not needed for auto-save
				Utility.Wait(0.3333)
				
				; v1.54 - make sure done dressing before save
				int rCount = 0
				while (rCount < 16 && (DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).IsRedressing)
					Utility.Wait(0.25)
					rCount += 1
				endWhile
				Utility.Wait(2.0)
				
				LastGameSaveTime = curTime
				Game.RequestAutoSave()
			endIf
		endIf
	endIf

EndFunction

;------------
; not bed -- seat or other furniture  v3.03
;
Function HandleExitSeat()
	
	PlayerSleepPerkRemove()		; hide until out
	Utility.Wait(1.0)
	
	MainQSceneScriptP.GoSceneViewDone(false)
	Utility.Wait(0.1)
	
	if ((DTSConditionals as DTSleep_Conditionals).IsPlayerCommentsActive)
		ModPlayerCommentsEnable()
	endIf

	EnablePlayerControlsSleep()
	
	Location currentLoc = (SleepPlayerAlias as DTSleep_PlayerAliasScript).CurrentLocation
	CheckMessages(currentLoc)
	
	
	StartTimer(3.0, PlayerSleepPerkTimerID) 
	

EndFunction

Function HandleIntimateAnimStartError(int errorCount)

	if (errorCount <= -2)
		if (SceneData.AnimationSet >= 5)
		
			DTSleep_SettingAAF.SetValueInt(0)
			; display error in a few seconds
			StartTimer(3.0, AnimationErrorAAFTimerID)
		
		endIf
	endIf
endFunction

Function HandleOnExitFurniture(ObjectReference bedRef)

	CancelTimerGameTime(SleepNapLimitGameTimerID)
	
	; mark player not using bed
	DTSleep_PlayerUsingBed.SetValue(0.0)
	
	if (SleepBedUsesBlock && SleepBedInUseRef != None)
		
		; ensure bed re-blocked such as for Campsite by fadingsignal
		SleepBedInUseRef.BlockActivation(true)
	endIf
	bool speakWake = false
	int hoursSleep = 5
	
	if (DTSleep_HealthRecoverQuestP.IsRunning())
		
		UnregisterForCustomEvent((DTSleep_HealthRecoverQuestP as DTSleep_HealthRecoverQuestScript), "RestInterruptionEvent")
		hoursSleep = (DTSleep_HealthRecoverQuestP as DTSleep_HealthRecoverQuestScript).HourCount
		
		if (DTSleep_SettingNapOnly.GetValue() > 0.0)
			; if short sleep then decrement rest count
			if (hoursSleep <= 2)
			
				int restCount = DTSleep_RestCount.GetValueInt() - 1
				if (restCount > 1)
					DTSleep_RestCount.SetValueInt(restCount)
				endIf
			endIf
		endIf
		
		if (hoursSleep >= 6)
			(DTSleep_HealthRecoverQuestP as DTSleep_HealthRecoverQuestScript).StopAllDone(true)
		else
			(DTSleep_HealthRecoverQuestP as DTSleep_HealthRecoverQuestScript).StopAllCancel()
			LoverBonusRested(false)
		endIf
	endIf
	
	if (DTSleep_TimeDayQuestP.IsRunning())
		(DTSleep_TimeDayQuestP as DTSleep_TimeDayQuestScript).StopAll()
	endIf
	
	; should companion follow?
	if (SleepBedCompanionUseRef != None && IntimateCompanionRef != None && IntimateCompanionRef.GetSleepState() >= 3)
		Utility.Wait(0.6)
		
		
		if (DTSleep_SettingNapOnly.GetValue() > 0.0 && hoursSleep >= 3)
			if (CompanionRelationRankForActor(IntimateCompanionRef) >= 4)
				speakWake = true
				
				; check for bonus
				if ((DTSleep_HealthRecoverQuestP as DTSleep_HealthRecoverQuestScript).PlayerWellRested && IntimateCompanionRef.GetDistance(PlayerRef) < 300.0)
					if (SleepBedInUseRef.HasKeyword((DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).AnimFurnLayDownUtilityBoxKY) && SleepBedCompanionUseRef.HasKeyword((DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).AnimFurnLayDownUtilityBoxKY))
						if (DTSleep_SettingNotifications.GetValueInt() > 0)
							StartTimer(8.0, IntimateRestedCoffAddTimerID)
						else
							LoverBonusRestedCoffin(true, false)
						endIf
					elseIf (DTSleep_SettingNotifications.GetValueInt() > 0)
						StartTimer(8.0, IntimateRestedAddTimerID)
					else
						LoverBonusRested(true, false)
					endIf
				endIf
			endIf
		endIf
		
		WakeIntimateCompanion(speakWake)
		
	elseIf (DTSleep_CompSleepQuest.IsRunning())
		WakeStopCompQuest()
	endIf
	
	; Dogmeat follow?
	if (DTSleep_SettingDogRestrain.GetValue() > 0.0 && DogmeatCompanionAlias != None)
	
		SetDogmeatFollow()
	endIf
	
	Utility.Wait(0.1)
	(DTSleep_HealthRecoverQuestP as DTSleep_HealthRecoverQuestScript).PlayerWellRested = false
	SleepBedNapHourCount = 0
	SleepBedUsesBlock = false
	SleepBedInUseRef = None
	SleepBedCompanionUseRef = None
	SleepBedUsesSpecialAnims = false
	
	RegisterForMenuOpenCloseEvent("WorkshopMenu")
	;DTDebug(" OnExitFurniture - " + bedRef, 2)
	
	bool isBed = true		; v3.03 - tell difference between seat and bed
	
	float timeToWait = 5.4
	
	if (bedRef != None && (DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).IsObjBed(bedRef))
	
	
		if (bedRef.HasKeyword(AnimFurnFloorBedAnims))  ; what about slow-side exit?	
			timeToWait += 1.90
		endIf
	else
		isBed = false
	endIf
	

	if (isBed)

		StartTimer(timeToWait, ExitBedHandleTimerID)
	else
		StartTimer(timeToWait, ExitSeatHandleTimerID)	; v3.03 handle differently from bed
	endIf
endFunction

Function HandlePlayerActivateBed(ObjectReference targetRef, bool isNaked, bool isSpecialAnimBed)
	SleepBedUsesSpecialAnims = isSpecialAnimBed
	
	DisablePlayerControlsSleep(2)	; v1.25 changed level-2 to prevent look

	IntimateCompanionRef = None
	bool companionReady = false
	bool bedCompatible = true  	; v2.60 - now using for Strong bed-check to skip warning when incompatible
	bool undressOK = false
	bool noPreBedAnim = true
	bool undressCheck = IsUndressCheckRequested()  ; if check undress instead of sleep
	bool cancledScene = false
	bool sameLover = false
	bool dogmeatScene = false
	bool doggySafe = true
	bool sleepSafe = OkayToSleepLocationBed(targetRef)
	bool bedIntimateGood = true
	float bedHeight = targetRef.GetPositionZ() - PlayerRef.GetPositionZ()
	Form basebedForm = None
	int creatureType = 0
	int rIdx = -1
	int pickStyle = -1 ; chosen from menu
	float gameTime = Utility.GetCurrentGameTime()
	bool spectatorOkay = true								; to disable spectators v2.16
	IntimateCompanionSet nearCompanion = new IntimateCompanionSet
	SceneData.CompanionBribeType = 0
	bool playerIntimateOK = false
	bool companionRaceOK = true   	; v2.60
	int scenePickerType = 0       ; 0 = default, 1 = FF, 2 = MM     v3.0
	
	; v2.35 moved to top to ensure check once for regular sleep or intimacy
	bool sleepTime = (DTSleep_HealthRecoverQuestP as DTSleep_HealthRecoverQuestScript).IsSleepTimePublic(gameTime)
	int sleepNapPrefVal = DTSleep_SettingNapOnly.GetValueInt()
	
	SceneData.SecondFemaleRole = None
	SceneData.SecondMaleRole = None
	
	;  note: specialAnims bed with relax keyword should be blocked so other NPCs don't use during intimate scene
	;
	; only 1 case - nothing to do here
	;if (SleepBedUsesSpecialAnims)
	;	if (!targetRef.HasKeyword(FurnitureClassRelaxationKY))
	;		bedCompatible = false
	;	endIf
	;endIf
	
	DTSleep_SIDIgnoreOK.SetValueInt(-1)					; reset on Rest v2.74

	; check FarHarbor quest to clear for napping
	if ((DTSConditionals as DTSleep_Conditionals).IsCoastDLCActive && sleepNapPrefVal > 0)
	
		Location lastPlankLoc = (DTSConditionals as DTSleep_Conditionals).FarHarborLastPlankLocation
		Location currentLoc = (SleepPlayerAlias as DTSleep_PlayerAliasScript).CurrentLocation
		
		if (lastPlankLoc != None && lastPlankLoc == currentLoc)
			pickStyle = 3				; v2.17 - no room on bed for sex animation;  v3.0 incremented to 3 for pickspot
			
			Quest rentQuest = (DTSConditionals as DTSleep_Conditionals).FarHarborBedRentQuest
			if (rentQuest != None && rentQuest.IsRunning())
				
				rentQuest.SetStage(100)
			endIf
		endIf
	endIf
	
	;v2.35 first-time prompt for sleep-rate
	if (TipSleepModePromptVal < 2)
		if (sleepNapPrefVal >= 1)
			if (sleepNapPrefVal == 1)
				; on default constant-rate, ask player to pick
				sleepNapPrefVal = DTSleep_SleepImmersiveRatePromptMsg.Show()
				DTSleep_SettingNapOnly.SetValueInt(sleepNapPrefVal)
				
				TipSleepModePromptVal = 3
				
				Utility.Wait(0.25)
			else
				TipSleepModePromptVal = 2
			endIf
		elseIf (TipSleepModeDisplayCount >= 2)
			; player has seen the tips
			TipSleepModePromptVal = 2
		endIf
	endIf
	
	; ------ get companion --- 
	;
	int minRank = 3
	float intimateSetting = DTSleep_SettingIntimate.GetValue()			; v2.60
	if (intimateSetting == 2.0 || intimateSetting == 4.0)
		minRank = 2
	endIf
	
	if (DTSleep_SettingUndress.GetValue() > 0.0)
		undressOK = true
	endIf
	
	nearCompanion = GetCompanionNearbyHighestRelationRank(true, minRank)
	
	; ------ check companion and start intimate-companion quest
		
	if (nearCompanion != None && nearCompanion.CompanionActor != None)
	
		nearCompanion.CompanionActor.AddToFaction(DTSleep_IntimateFaction)

		bool hugOnly = false       ; to allow short-circuit checks   v2.82
		
		if (DTSleep_AdultContentOn.GetValueInt() < 2 || DTSleep_SettingIntimate.GetValueInt() >= 3)		; v2.82
			; no adult or XOXO-mode enabled 
			hugOnly = true
			companionRaceOK = false			; just mark now
		endIf
	
		if (nearCompanion.RelationRank >= 3)
			IntimateCompanionRef = nearCompanion.CompanionActor		; mark now to save time for sleep check
		endIf
	
		; same lover check before update SceneData
		if (DTSleep_IntimateEXP.GetValue() <= 0.0)
		
			sameLover = true  ; no penalty to get started
		
		elseIf (SceneData.MaleRole == None && SceneData.FemaleRole == None)
			sameLover = true
			
		elseIf (SceneData.MaleRole == nearCompanion.CompanionActor || SceneData.FemaleRole == nearCompanion.CompanionActor)
			
			if (SceneData.CurrentLoverScenCount > 0)
				sameLover = true
			endIf
		endIf
		
		DTDebug(" check nearCompanion " + nearCompanion.CompanionActor, 1)

		;  ***** verify companion is ready and update SceneData
		;
		; note: unknown race and AnimeRace (NanaRace) will intentionally fail intimate-compatible check -- only allowed to hug/kiss
		; 
		int readyVal = 0
		
		playerIntimateOK = PlayerIntimateCompatible()
		
		if (bedCompatible)												; v2.60 - now allow embrace --- check race later
		
			if ((gameTime - IntimateCheckLastFailTime) < 0.047)
				readyVal = -101			; too soon!
			else
				; no-hug check, v2.60 - bad race returns -1001
				; v2.82 -- added hugOnly for short-circuit checks	
				readyVal = IsCompanionActorReadyForScene(nearCompanion, false, targetRef, true, hugOnly)				; Ready for Scene? also updates SceneData
				if (readyVal == -1001)
					companionRaceOK = false
					readyVal = IsCompanionActorReadyForScene(nearCompanion, false, targetRef, false, true)		
				endIf
			endIf
			
			DTSleep_CompIntimateQuest.Start()
			
			
			; check intimate alias 
			Actor intimateAliasActor = DTSleep_CompIntimateAlias.GetActorReference()
			if (intimateAliasActor != None && intimateAliasActor != nearCompanion.CompanionActor)
				DTDebug(" correcting intimate companion alias; found " + intimateAliasActor + " instead of " + nearCompanion.CompanionActor, 1)
				intimateAliasActor.RemoveFromFaction(DTSleep_IntimateFaction)
				DTSleep_CompIntimateAlias.ForceRefTo(nearCompanion.CompanionActor)
			endIf
			if (readyVal > 0)
				nearCompanion.CompanionActor.EvaluatePackage()
				;Utility.Wait(0.25) ; we wait later
			endIf
			
			; check to clear Dogmeat v2.22 -- v2.35 clear the bed
			if (PlayerHasActiveDogmeatCompanion.GetValueInt() <= 0)
				Utility.Wait(0.2)
				if (DTSleep_DogBedIntimateAlias != None)
					DTSleep_DogBedIntimateAlias.Clear()
				endIf
			endIf
		
			if (readyVal > 0)
		
				if (nearCompanion.CompanionActor == StrongCompanionRef && playerIntimateOK && companionRaceOK)				; v2.60 check race
					; v1.46 allow double-bed if have SavageCabbages
					bool bedOkay = false
					if (targetRef.HasKeyword(AnimFurnFloorBedAnims) || targetRef.IsActivationBlocked())
						bedOkay = true
					elseIf (DTSleep_AdultContentOn.GetValue() >= 2.0 && (DTSConditionals as DTSleep_Conditionals).IsSavageCabbageActive)
						basebedForm = (targetRef.GetBaseObject() as Form)
						if (baseBedForm != None && DTSleep_BedsBigDoubleList.HasForm(baseBedForm))
							bedOkay = true
						endIf
					endIf
					if (bedOkay)
						IntimateCompanionRef = StrongCompanionRef
						creatureType = CreatureTypeStrong
						DTDebug(" strong set " + nearCompanion.CompanionActor, 2)
						companionReady = true
					else
						bedCompatible = false			; v2.60 skip warning (disagrees with situation)
					endIf
				elseIf (nearCompanion.CompanionActor.HasKeyword(ActorTypeRobotKY) && playerIntimateOK && companionRaceOK)			; v2.60 check race
					if (intimateSetting == 2.0 && DressData.PlayerGender == 1)
						if (DTSleep_AdultContentOn.GetValue() >= 2.0 && (DTSConditionals as DTSleep_Conditionals).IsSavageCabbageActive)
							companionReady = true
							IntimateCompanionRef = nearCompanion.CompanionActor
						endIf
					endIf
				elseIf (nearCompanion.HasLoverRing || (nearCompanion.RelationRank >= 2 && (intimateSetting == 2.0 || intimateSetting == 4.0)))
					companionReady = true
					IntimateCompanionRef = nearCompanion.CompanionActor
					
				elseIf (nearCompanion.RelationRank >= 3)
					companionReady = true
				endIf
				
			endIf
		endIf
		;  ***
		
		;  *** tutorial check if intimate okay
		if (bedCompatible && !undressCheck && intimateSetting > 0.0)
		
			if (nearCompanion != None && nearCompanion.CompanionActor != None && nearCompanion.CompanionActor.GetSleepState() <= 2)
			
				if (PersuadeTutorialShown <= 0)
					int tutorVal = -1
					
					if (companionReady)
						tutorVal = DTSleep_PersuadeReadyTutorMsg.Show()
						PersuadeTutorialShown = 2
						
					elseIf (IsAdultAnimationAvailable() && PersuadeTutorialXFFShown == 1)
						PersuadeTutorialXFFShown = 2

						DTSleep_PersuadeBusyTutorXFFMsg.Show()
						
					else
						PersuadeTutorialXFFShown = 3
						tutorVal = DTSleep_PersuadeBusyTutorMsg.Show()
						PersuadeTutorialShown = 1
						cancledScene = true
					endIf
					Utility.Wait(0.6)
					
					if (tutorVal == 1)
						DTSleep_SettingWarnLoverBusy.SetValue(1.0)
					else
						DTSleep_SettingWarnLoverBusy.SetValue(0.0)
					endIf
					
				elseIf (DTSleep_SettingWarnLoverBusy.GetValue() > 0.0)
					
					if (!companionReady || readyVal == 505)
						if (DisplayCompanionBusyWarn(readyVal) >= 1)
						
							Utility.Wait(0.25)
							cancledScene = true
						else
							Utility.Wait(0.50)
						endIf
					endIf
				endIf
			endIf
		endIf
	endIf
	
	; ----------------- check if twin/double-bed ownership and occupancy ---------------
	
	Location currentLoc = (SleepPlayerAlias as DTSleep_PlayerAliasScript).CurrentLocation
		
	if (currentLoc != None && DTSleep_PrivateLocationList.HasForm(currentLoc as Form))
	
		if (baseBedForm == None)
			baseBedForm = (targetRef.GetBaseObject() as Form)
		endIf
		
		if (companionReady && DTSleep_BedsBigDoubleList.HasForm(baseBedForm))
			; check twin-side for occupation
			ObjectReference twinBed = DTSleep_CommonF.FindNearestAnyBedFromObject(targetRef, DTSleep_BedList, targetRef, 200.0, true)
			if (twinBed != None && twinBed.IsFurnitureInUse())
				; only sleep here - no intimacy
				if (DTSleep_SettingNotifications.GetValue() >= 1.0)
					DTSleep_IntimacyTwinBedInUseMsg.Show()
				endIf
				companionReady = false
			endIf
		endIf
	
	elseIf (!cancledScene && !undressCheck && !SceneData.IsUsingCreature)
		; not private location
		
		int bedOwnCheck = (DTSleep_BedOwnQuestP as DTSleep_BedOwnQuestScript).CheckBedOwnership(targetRef, basebedForm, IntimateCompanionRef, currentLoc)
		
		if (bedOwnCheck < -10)
			; no intimacy, sleep only
			if (bedOwnCheck == -11 && companionReady && DTSleep_SettingNotifications.GetValue() >= 1.0)
				DTSleep_IntimacyTwinBedInUseMsg.Show()
			endIf
			companionReady = false
			
		elseIf (bedOwnCheck < 0)
			cancledScene = true
		endIf
	endIf
	
	; ----------------- ready for sex? --------------- 
	
	
	if (bedCompatible && !cancledScene && !undressCheck && intimateSetting > 0.0 && companionReady && IntimateCompanionRef != None)
	
		int[] animPacks = new int[0]
		if (baseBedForm == None)
			baseBedForm = (targetRef.GetBaseObject() as Form)
		endIf
		
		SceneData.AnimationSet = -2
		
		if (basebedForm != None && !DTSleep_BedNoIntimateList.HasForm(basebedForm))
			
			bool adultScenesAvailable = false
			bool playSlowMo = false
			bool useLowSceneCam = true
			bool playerPositioned = false
			bool pickSpotSelected = false
			bool bedIsBunk = false
			ObjectReference twinBedRef = None
			
			if ((DTSConditionals as DTSleep_Conditionals).IsHZSHomebuilderActive > 0)
				if ((SleepPlayerAlias as DTSleep_PlayerAliasScript).DTSleep_BedPillowBedList.HasForm(baseBedForm))
					ObjectReference bedFrameRef = DTSleep_CommonF.FindNearestAnyBedFromObject(targetRef, (SleepPlayerAlias as DTSleep_PlayerAliasScript).DTSleep_BedPillowFrameBadList, None, 86.0)
					if (bedFrameRef != None)
						bedIntimateGood = false
					endIf
				endIf
			endIf
			
			
			int luck = (PlayerRef.GetValue(LuckAV) as int)
			(DT_RandomQuestP as DT_RandomQuestScript).MySizedPackCount = luck
			float timeSinceShuffle = DTSleep_CommonF.GetGameTimeHoursDifference((DT_RandomQuestP as DT_RandomQuestScript).MyLastHundredShuffleTime, gameTime)
			int shuffleIndex = (DT_RandomQuestP as DT_RandomQuestScript).ShuffledHundredIndex
			
			if (timeSinceShuffle > 64.0 || shuffleIndex > 20)
				; time to shuffle randomizer
				
				(DT_RandomQuestP as DT_RandomQuestScript).ShuffleOnTimerPublic(0.10)
				rIdx = 0
			else
				rIdx = (DT_RandomQuestP as DT_RandomQuestScript).ValidatePublic()
			endIf
			
			; ------------  Set Companion and Dogmeat to follower Wait ------------
		
			float waitSecs = 0.65  ; for follower to get into wait position
			
			if (DTSleep_SettingDogRestrain.GetValue() > 0.0 && PlayerHasActiveDogmeatCompanion.GetValueInt() >= 1)
				
				processingDogmeatWait = 3
				StartTimer(0.10, DogmeatSetWaitTimerID) 
				
			endIf
			
			IntimateCompanionRef.FollowerWait()         ; for cleaner entry into animations
			
			; v 1.53 - not using
			;if (!dogmeatScene && DTSleep_CompBedSexRefAlias != None)	; v1.25 restrict dogmeat from force
			;	;DTSleep_CompBedSexRefAlias.ForceRefTo() ??
			;endIf 
			
			; ---------- done follower wait ----------------------
			
			if (PlayerRef.HasMagicEffect(SlowTimeJet))
				playSlowMo = true
			endIf

			; ---------------- Check for scene compatibility and safety
			
			; check available animation sets  -- also undressOK for v3.0 since can now hug/kiss without undress 
			if (playerIntimateOK && companionRaceOK && undressOK && SceneData.RaceRestricted < 10)		;v2.60 now check race for adult to allow embrace--v2.82 added race-restricted check
				adultScenesAvailable = IsAdultAnimationAvailable()
			endIf
			
			bool doScene = false
			
			int playerSex = DressData.PlayerGender
			if (playerSex < 0)
				playerSex = (PlayerRef.GetLeveledActorBase() as ActorBase).GetSex()
				DressData.PlayerGender = playerSex
			endIf
			
			float bedHtLim = 24.0
			if (SleepBedIsPillowBed)
				bedHtLim = 69.0
			endIf
			
			if (bedHeight < bedHtLim && bedHeight > -50.0) ; bed should be relatively level with player
			
				int companionGender = -1
				bool bedIsCoffin = targetRef.HasKeyword((DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).AnimFurnLayDownUtilityBoxKY)
				if (!bedIsCoffin)
					bedIsBunk = (DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).IsSleepingBunkBed(targetRef, baseBedForm, SleepBedIsPillowBed)
				endIf 
				
				if (DressData.PlayerGender >= 0)
					if (SceneData.SameGender == 1)
						companionGender = DressData.PlayerGender
					elseIf (DressData.PlayerGender == 0)
						companionGender = 1
					else
						companionGender = 0
					endIf
				endIf
				
				; only need for threaded doggy wait
				;int count = 10
				;while (count > 0 && processingDogmeatWait >= 2)
				
				;	Utility.Wait(0.1)
				;	waitSecs -= 0.1
				;	count -= 1
				;endWhile
				
				if (!dogmeatScene)
					doggySafe = IsSceneDogmeatSafe(targetRef)
				endIf
				
				; ---------------- check for extra partner --------
				;   all multiple-partner scenes for SceneData assume primary male and female plus one 2nd lover (FMM or FMF)
				;   so if primary lover is same gender need to swap roles for scene to include 2nd lover,
				;   but swap after passing check!
				;
				if (adultScenesAvailable && DTSleep_AdultContentOn.GetValue() >= 2.0 && DTSleep_SettingLover2.GetValue() >= 1.0 && !SceneData.CompanionInPowerArmor && Debug.GetPlatformName() as bool)
				
					if (!SceneData.IsUsingCreature)
						; v2.14 - disallow AAF for power-armor-flag
						if (!IsAAFReady() || !nearCompanion.PowerArmorFlag)
							; v2.13 -- allow jealous type and reduce chance instead 
							;if (!(DTSleep_IntimateAffinityQuest as DTSleep_IntimateAffinityQuestScript).CompanionHatesIntimateOtherPublic(IntimateCompanionRef))
						
							int extraLoverReady = (DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).GetFurnitureSupportExtraActorForPacks(targetRef, basebedForm, None)
							
							if (extraLoverReady >= 4)			; check companion gender and adjust to 3 or 2 - v2.90
								if (SceneData.SameGender)
									extraLoverReady = 3
								else
									extraLoverReady = 2
								endIf
							endIf
							
							DTDebug("extraLoverReady " + extraLoverReady + " for bed ", 2)
							
							if (extraLoverReady >= 0)
								int loverType = extraLoverReady
								if (SceneData.SameGender && loverType >= 0)
									if (SceneData.MaleRoleGender == 0 && extraLoverReady != 1)
										; missing a female for FemaleRole -- if player chooses this 2nd lover will need to swap roles
										loverType = 0
									elseIf (SceneData.MaleRoleGender == 1 && extraLoverReady >= 1)
										; missing a male for MaleRole -- if player chooses this 2nd lover will need to swap roles
										loverType = 1
									else
										loverType = -1
									endIf
								endIf
								if (loverType >= 0)
									; sets SceneData Second role and alias for name
									SetExtraLovePartners(loverType)
								endIf
							endIf
						endIf
					elseIf (SceneData.IsCreatureType == CreatureTypeStrong)
						SetExtraMutantPartner()
					endIf
				endIf
				; ------------------------end partner set
				
				; ------------- Get Chance - Auto or Prompt ----------------
				
				IntimateChancePair chanceForScene = new IntimateChancePair
				IntimateLocationHourSet locHourChance = new IntimateLocationHourSet
				int sexAppealScore = -2
				
				;bool promptOkay = true
				
				;int friskyScore = PlayerFriskyScore()
				;
				;if (LocationScoreByFriskyScore(friskyScore) > 10)
				;	promptOkay = false
				;endIf
				
				; --- can player pick a scene?
				; 
				;  ----------- SexStyle level found on DTSleep_IntimateScenePickMessage ------
				;										v3 - added cancel/return to 0 and self-pleasure at 3; others incremented
				;		0 = cancel/return
				;		1 = let partner decide
				;      	2 = Cuddle
				;      	3 = Stand/Pick Spot
				;      	4 = situational (default)
				;      	5 = Manual or Oral
				;      	6 = Doggy
				;      	7 = Cowgirl			-limitlevel = 6
				;      	8 = Spoon			-limitlevel = 7
				;
				;  ---------FF SexStyle level found on DTSleep_IntimateScenePickFFMessage ------  v3 
				;
				;		0 = cancel/return
				;		1 = let partner decide
				;      	2 = Cuddle
				;      	3 = Stand/Pick Spot
				;      	4 = situational (default)
				;      	5 = Oral
				;      	6 = 69
				;      	7 = scissors		-limitlevel = 6
				;      	8 = spoon  -not used     
				;
				; -------------
				;  ---------MM SexStyle level found on DTSleep_IntimateScenePickMMMessage ------  v3 
				;
				;		0 = cancel/return
				;		1 = let partner decide
				;      	2 = Cuddle
				;      	3 = Stand/Pick Spot
				;      	4 = situational (default)
				;      	5 = Oral / Manual
				;      	6 = 69
				;      	7 = cowboy 			-limitlevel = 6
				;      	8 = spoon  - not used
				
				
				if (adultScenesAvailable && !dogmeatScene && !SceneData.CompanionInPowerArmor && sleepSafe && bedIntimateGood)
					
					
					float limitLevel = 2.0
					DTSleep_SceneFFMissionEnable.SetValueInt(0)
					
					
					if (!SceneData.IsUsingCreature)
						if (!bedIsBunk && !bedIsCoffin)
							
							if ((DTSConditionals as DTSleep_Conditionals).IsLeitoActive && DTSleep_IsLeitoActive.GetValue() >= 1.0)
								limitLevel = 7.0
							elseIf ((DTSConditionals as DTSleep_Conditionals).IsLeitoAAFActive && DTSleep_IsLeitoActive.GetValue() >= 1.0)
								limitLevel = 7.0
							elseIf ((DTSConditionals as DTSleep_Conditionals).IsBP70Active)
								limitLevel = 7.0
							elseIf ((DTSConditionals as DTSleep_Conditionals).IsSavageCabbageActive)
								limitLevel = 6.0
							elseIf ((DTSConditionals as DTSleep_Conditionals).IsAtomicLustActive && (DTSConditionals as DTSleep_Conditionals).AtomicLustVers >= 2.42)
								limitLevel = 6.0
								if ((DTSConditionals as DTSleep_Conditionals).IsRufgtActive)
									limitLevel = 7.0			; includes spoon    v3.0
								endIf
							elseIf ((DTSConditionals as DTSleep_Conditionals).IsCrazyAnimGunActive)
								limitLevel = 6.0
							elseIf ((DTSConditionals as DTSleep_Conditionals).IsRufgtActive)
								limitLevel = 4.0
							endIf
							
							if (limitLevel >= 7.0 && SceneData.SameGender)
								; spoon no good  v3.0
								limitLevel = 6.0
							endIf
						endIf
						
						if (limitLevel > 3.0)
							if (SceneData.SameGender)
								bool toyScenesAvailable = false									; --- v2.82 be more specific to limit prompt
								
								if (SceneData.HasToyAvailable)
									if ((DTSConditionals as DTSleep_Conditionals).IsLeitoActive || (DTSConditionals as DTSleep_Conditionals).IsLeitoAAFActive)
										if (DTSleep_IsLeitoActive.GetValue() >= 1.0)
											toyScenesAvailable = true
										endIf
									endIf
								endIf
								
								if (SceneData.MaleRoleGender == 1)
									if (!toyScenesAvailable || !SceneData.HasToyAvailable)										; 
										if ((DTSConditionals as DTSleep_Conditionals).IsRufgtActive)
											; all from FF-picker available
											limitLevel = 6.0
											scenePickerType = 1
											if ((DTSConditionals as DTSleep_Conditionals).IsGrayAnimsActive)
												DTSleep_SceneFFMissionEnable.SetValueInt(1)
											endIf
										;elseIf ((DTSConditionals as DTSleep_Conditionals).IsAtomicLustActive)
										;	; includes scissors only -- v3
										;	limitLevel = 4.0				; v2.82 added to include Atomic Lust
										elseIf ((DTSConditionals as DTSleep_Conditionals).IsGrayAnimsActive)
											limitLevel = 3.0
											scenePickerType = 1
											DTSleep_SceneFFMissionEnable.SetValueInt(1)
										elseIf (!toyScenesAvailable)
											; no others
											limitLevel = 1.0				; v2.82 lowered to hug-only list
											
										endIf
									endIf
								elseIf (SceneData.MaleRoleGender == 0)
									if ((DTSConditionals as DTSleep_Conditionals).IsAtomicLustActive)
										limitLevel = 7.0
										scenePickerType = 2
									else
										limitLevel = 1.0
									endIf
								endIf
							endIf
						endIf
					elseIf (SceneData.IsCreatureType == CreatureTypeStrong && SceneData.SecondMaleRole == None)
						limitLevel = 1.0
						if ((DTSConditionals as DTSleep_Conditionals).IsSavageCabbageActive)
							if ((DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).IsSleepingDoubleBed(targetRef, baseBedForm))
								limitLevel = 6.0
							elseIf (targetRef.HasKeyword(AnimFurnFloorBedAnims))			; v2.73 - ensure only on floor bed
								limitLevel = 5.0
							endIf
						endIf
						if (limitLevel < 2.0 && (DTSConditionals as DTSleep_Conditionals).IsMutatedLustActive)			; v2.73
							limitLevel = 4.0
						endIf
						; Strong Leito -- not enough without SC to pick on its own
						;if (limitLevel < 4.0 && targetRef.HasKeyword(AnimFurnFloorBedAnims) && (DTSConditionals as DTSleep_Conditionals).LeitoAnimVers >= 2.1)
						;	limitLevel = 5.0
						;endIf
					endIf
					
					DTSleep_SexStyleLevel.SetValue(limitLevel)
					
					
				else
					DTSleep_SexStyleLevel.SetValue(1.0)
				endIf
				
				if (SceneData.FemaleRaceHasTail)
					DTSleep_SexStyleFemHasTail.SetValue(1.0)
				else
					DTSleep_SexStyleFemHasTail.SetValue(0.0)
				endIf
				
				;DTDebug(" Pick-Scene SexStyleLevel " + DTSleep_SexStyleLevel.GetValue(), 2)
				
				;---------------------- check prompt
				
				int showPromptVal = DTSleep_SettingShowIntimateCheck.GetValueInt()
				
				if (doggySafe && showPromptVal > 0)
				
					; ------------ 2nd lover prompt
					if (adultScenesAvailable && !dogmeatScene)
						if (DTSleep_SettingLover2.GetValue() >= 1.0 && IntimateCompanionSecRef != None && (SceneData.SecondMaleRole != None || SceneData.SecondFemaleRole != None))
							; yes/no question
							if (SceneData.IsCreatureType == CreatureTypeStrong || SceneData.IsCreatureType == CreatureTypeBehemoth)
								if (DTSleep_IntimateCheckSecondOtherMsg.Show() >= 1)
									; no extra - remove 2nd mutant
									SceneData.SecondMaleRole = None
									SceneData.SecondFemaleRole = None
									ClearIntimateSecondCompanion()
									SceneData.IsCreatureType = CreatureTypeStrong
									
								else
									; if behemoth, swap with Strong
									if (SceneData.IsCreatureType == CreatureTypeBehemoth && SceneData.SecondMaleRole != None)
										
										ClearIntimateSecondSwapWithMain()
									endIf
									if (DTSleep_SexStyleLevel.GetValue() >= 3.0)
										; 2nd mutant limit scene picking
										DTSleep_SexStyleLevel.SetValue(2.0)
									endIf
								endIf
							elseIf (DTSleep_IntimateCheckSecondLovMsg.Show() >= 1)
								; no extra - remove 2nd lover
								ClearIntimateSecondCompanion()
								SceneData.SecondMaleRole = None
								SceneData.SecondFemaleRole = None
							elseIf (DTSleep_SexStyleLevel.GetValue() >= 3.0)
								; 2nd lover limit scene picking
								DTSleep_SexStyleLevel.SetValue(2.0)
							endIf
							Utility.Wait(0.85)
						endIf
					endIf
				
					; ------------- prompt for sex
					
					sexAppealScore = PlayerSexAppeal(isNaked, companionGender, creatureType)
					int checkVal = 10
					
					bool locCheck = true
					if (IntimateCheckAreaScore != None && IntimateCheckAreaScore.LocChecked == currentLoc)
						if (IntimateCheckAreaScore.LocChanceType != LocActorChanceHugs)
							float timeDiff = DTSleep_CommonF.GetGameTimeHoursDifference(gameTime, IntimateCheckAreaScore.CheckTime)
							if (timeDiff < 0.0336)		; 2 game-minute
								;DTDebug("no location recheck", 2)
								locCheck = false
							endIf
						endIf
					endIf
					if (locCheck)
						locHourChance = ChanceForIntimateSceneByLocationHour(targetRef, baseBedForm, IntimateCompanionRef, nearCompanion.RelationRank, gameTime)
						IntimateCheckAreaScore = locHourChance
					endIf
					
					if (locHourChance != None && locHourChance.LocTypeName == "non-crime-area")			; v2.16
						spectatorOkay = false 
					endIf
					
					while (checkVal >= 4)
					
						checkVal = ShowIntimatePrompt(checkVal, nearCompanion, sexAppealScore, chanceForScene.Chance as float, locHourChance, gameTime, dogmeatScene)
						
						if (checkVal >= 0 && checkVal <= 1)
							; player chose to persuade sex
							
							if (chanceForScene.Chance == 0)
								chanceForScene = ChanceForIntimateScene(nearCompanion, targetRef, baseBedForm, gameTime, companionGender, locHourChance, true, sexAppealScore, sameLover)
							endIf
							if (pickStyle < 0 && checkVal == 1)
								
								; v1.70 -- show style-pick menu - pickspot chosen from menu
								Utility.WaitMenuMode(0.3)
								
								if (scenePickerType == 1)
									pickStyle = DTSleep_IntimateScenePickFFMessage.Show()
								elseIf (scenePickerType == 2)
									pickStyle = DTSleep_IntimateScenePickMMMessage.Show()
								else
									pickStyle = DTSleep_IntimateScenePickMessage.Show()
								endIf
								
								if (pickStyle <= 0)						; allow cancel v3.0
									; return to previous menu (nevermind)
									pickStyle = -2
									checkVal = 10    ; re-display original prompt
									Utility.WaitMenuMode(0.1)
								else
									; old way before cancel v2
									if (pickStyle == 3)				; incremented for v3.0
										; okay for 2nd lover
										pickSpotSelected = true
										
									elseIf (SceneData.SecondFemaleRole != None || SceneData.SecondMaleRole != None)
										; remove 2nd lover for chosen preference
										ClearIntimateSecondCompanion()
										SceneData.SecondFemaleRole = None
										SceneData.SecondMaleRole = None
									endIf
									
									if (chanceForScene.Chance == 0)
										chanceForScene = ChanceForIntimateScene(nearCompanion, targetRef, baseBedForm, gameTime, companionGender, locHourChance, true, sexAppealScore, sameLover)
									endIf
									
									if (pickStyle == 1)			; no longer include 0
										; this will set player's choice based on companion
										chanceForScene.Chance += 15
										if (chanceForScene.Chance > 100)
											chanceForScene.Chance = 100
										endIf
										
									elseIf (pickStyle > 1)
										chanceForScene.Chance -= 7
										if (chanceForScene.Chance < 5)
											chanceForScene.Chance = 5
										endIf
									endIf
								endIf
								
							elseIf (!sleepSafe && adultScenesAvailable)
								; no room on bed
								pickSpotSelected = true
							elseIf (!bedIntimateGood && adultScenesAvailable)
								pickSpotSelected = true
							elseIf (bedIsBunk && adultScenesAvailable && !(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).BunkBedAdultScenesAvailable(SceneData.SameGender))
								pickSpotSelected = true
								
							elseIf (pickStyle == 3 && adultScenesAvailable)  ; incremented for v3.0
								; v2.17 - some beds have no room on bed so force pickspot
								pickSpotSelected = true
							endIf
							
						elseIf (checkVal == 2)
							; player chose to sleep - force failure
							chanceForScene.Chance = -2
							SceneData.AnimationSet = -2

						elseIf (checkVal == 3)
							; player chose cancel - force failure
							chanceForScene.Chance = -4
							SceneData.AnimationSet = -4
							cancledScene = true
							noPreBedAnim = false
							
						elseIf (checkVal == 4)
							; show actual chance
							Utility.Wait(0.6)
							chanceForScene = ChanceForIntimateScene(nearCompanion, targetRef, baseBedForm, gameTime, companionGender, locHourChance, true, sexAppealScore, sameLover)
						
						endIf
						
					endWhile  ; end checkVal >= 4
				
				elseIf (!doggySafe)
				
					SceneData.AnimationSet = -3
					chanceForScene.Chance = -8		; force fail
					cancledScene = true
					if (PlayerKnowsDogmeatName.GetValue() > 0.0)
						DTSleep_SceneDogMUnsafeMsg.Show()
					else
						DTSleep_SceneDoggyUnsafeMsg.Show()
					endIf
					Utility.Wait(0.2)
				else
					; no prompt / automatic -- v1.44 limit by hours to avoid penalties
					float daysSinceFail = gameTime - IntimateCheckLastFailTime
					float daysSinceLast = gameTime - IntimateLastTime
					float daysSinceFailLim = 0.3333   ; 8 hours
					float daysSinceLastLim = 0.1250   ; 3 hours
					
					if (dogmeatScene)
						daysSinceFail = gameTime - IntimateCheckLastDogFailTime
						daysSinceLast = gameTime - DTSleep_IntimateDogTime.GetValue()
						daysSinceFailLim = 0.1250 
						daysSinceLastLim = 1.0
					endIf
					if (daysSinceLast > daysSinceLastLim && daysSinceFail > daysSinceFailLim)

						chanceForScene = ChanceForIntimateScene(nearCompanion, targetRef, baseBedForm, gameTime, companionGender, locHourChance, true, sexAppealScore, sameLover, isNaked)
					else
						; too soon for auto
						SceneData.AnimationSet = -3
						chanceForScene.Chance = -9		; force fail
						cancledScene = true
					endIf
				endIf
				; ----------------- done Get Chance --------------
				
				Utility.Wait(0.05)
				
				; ------------------- Roll random --
				
				int randomChance = 101
				
				bool luckRoll = false
				bool testDemoEnabled = false
				
				if (!cancledScene)
					testDemoEnabled = TestIntSceneEnabled(targetRef)
				endIf
					
				if (testDemoEnabled)
					randomChance = 1
				elseIf (doggySafe)
					randomChance = (DT_RandomQuestP as DT_RandomQuestScript).GetNextHundredPackIntPublic()
				endIf
				
				; if chance is low and luck high and failed then try again
				
				if (chanceForScene.Chance > 1 && randomChance > chanceForScene.Chance && luck > 5 && timeSinceShuffle > 0.05 && chanceForScene.Chance <= 55)
					
					int randomLuckRoll = (DT_RandomQuestP as DT_RandomQuestScript).GetNextSizedPackIntPublic()
					if (randomLuckRoll > 5)
						; roll again
						luckRoll = true
						
						randomChance = (DT_RandomQuestP as DT_RandomQuestScript).GetNextHundredPackIntPublic()
					endIf
					
				endIf
				DTDebug(" Intimacy Scene chance to beat, Random roll: " + chanceForScene.Chance + " > " + randomChance + " -- luck roll? " + luckRoll, 2)

				
				; ------------------ got random - now do scene or not
				
				if (!cancledScene && DTSleep_AdultContentOn.GetValue() >= 2.0 && adultScenesAvailable)		; v2.53 -- change from 1.0 to 2.0 since XOXO includes hug/kiss
					; picks animation pack	(also includes non-adult cuddles				; v2.60 -- include adult-scene restriction since changed player-check
					
					animPacks = IntimateAnimPacksPick(adultScenesAvailable, nearCompanion.PowerArmorFlag, playerSex, targetRef, basebedForm, false, pickStyle)
				endIf
				
				if (adultScenesAvailable && animPacks.Length > 0)							; v2.60 -- stricter since changed player-check						
				
					if (chanceForScene.Chance >= randomChance)
					
						doScene = true				; ***** successs ****
						
						; -------- speak and notify ------------------------------
						EnablePlayerControlsSleep()
						DisablePlayerControlsSleep(0)	;v1.46 - enable move-control to show HUD notifications
						
						if (testDemoEnabled)
							IntimacyTestCount += 1
							
						else
							PlayerRef.SayCustom(PlayerLockResultSubtype, None, randomChance > 50) ; speak in head if rand > 50
							
							SetProgressIntimacy(sexAppealScore, creatureType, rIdx, locHourChance.nearActors)
						endIf
						
						SetAffinityForCreature(creatureType)
						
						if (pickSpotSelected)		; v1.70 - now only if player chose stand scene
							
							PlayPickSpotTimer()
							
							playerPositioned = true
							
							if (PlayerRef.IsInCombat() || IntimateCompanionRef.IsInCombat() || IntimateCompanionRef.IsWeaponDrawn())
								cancledScene = true
								doScene = false
								
								PlayerRef.SayCustom(PlayerHackFailSubtype, None)
								
							endIf
						endIf
						
						
						if (!cancledScene && luckRoll && DTSleep_SettingNotifications.GetValueInt() > 0)
							if (dogmeatScene)
								DTSleep_LuckyDogMessage.Show()
							else
								DTSleep_LuckyMessage.Show()
							endIf
							Utility.Wait(0.5)
						endIf

						if (SceneData.AnimationSet <= -100 || animPacks == None || animPacks.Length == 0)
							; none matching our situation
							
							if (SceneData.AnimationSet == -101 && nearCompanion.PowerArmorFlag)
								DTSleep_PersuadeBusyWarnPAFlagMsg.Show()
								Utility.Wait(1.0)
							endIf
							
							SceneData.AnimationSet = 0
						endIf
						
						; allow for follower-wait to finish
						if (waitSecs > 0.1)
							Utility.Wait(waitSecs)
						endIf
						EnablePlayerControlsSleep()
						if (!cancledScene)
							DisablePlayerControlsSleep(2)	;v1.46 - hide HUD
						endIf
						; ---------------------------------------------------
						
						if (pickSpotSelected && SceneData.IsCreatureType != CreatureTypeDog)
							useLowSceneCam = false
						elseIf (SceneData.IsCreatureType == CreatureTypeStrong)
							; v2.60 
							useLowSceneCam = false
						elseIf (SceneData.IsCreatureType == CreatureTypeBehemoth || SceneData.IsCreatureType == CreatureTypeHandy)
							; v2.60 these never use lowCam
							useLowSceneCam = false
						endif
						
					elseIf (chanceForScene.Chance >= 5)
						
						PlayerRef.SayCustom(PlayerHackFailSubtype, None, randomChance > 50)
						
						; only mark fail if chance and no more often than 3/4 hours
						
						if (dogmeatScene && ((gameTime - IntimateCheckLastFailTime) > 0.1250))
							IntimateCheckLastDogFailTime = gameTime
							
						elseIf (!dogmeatScene && ((gameTime - IntimateCheckLastFailTime) > 0.16667))     
							
							IntimateCheckFailCount += 1
							IntimateCheckLastFailTime = gameTime
							LoverBonus(false)
							
							if (DTSleep_SettingNotifications.GetValue() > 0.0 && PersuadeTutorialFailShown < 1)
						
								self.MessageOnRestTipID = OnRestMsgTipFailPersuadeID
							endIf
						endIf
						Utility.Wait(0.3)
					endIf
					
				elseIf (ChanceForIntimateSceneAdjDance(chanceForScene.Chance) > randomChance)
				
					doScene = true				; **** success ***
					
					; ------ speak and notify
					EnablePlayerControlsSleep()
					DisablePlayerControlsSleep(0)	;v1.55 - enable move-control to show HUD notifications
					
					if (!testDemoEnabled)
						PlayerRef.SayCustom(PlayerLockResultSubtype, None, randomChance > 50) ; speak in head if rand > 50
					endIf
					
					SetAffinityForCreature(creatureType)
					
					if (waitSecs > 0.1)
						Utility.Wait(waitSecs)
					endIf
					SceneData.AnimationSet = 0
					
					if (testDemoEnabled)
						IntimacyTestCount += 1
					else
						SetProgressIntimacy(sexAppealScore, creatureType, rIdx, locHourChance.nearActors)
					endIf

					if (luckRoll && DTSleep_SettingNotifications.GetValueInt() > 0)
						if (dogmeatScene)
							; not currently enabled for non-adult scenes
							DTSleep_LuckyDogMessage.Show()
						else
							DTSleep_LuckyMessage.Show()
						endIf
						Utility.Wait(0.5)
					endIf
					
					EnablePlayerControlsSleep()
					DisablePlayerControlsSleep(2)	;v1.55 - hide HUD
					
				elseIf (chanceForScene.Chance >= 5)
				
					; ******* fail *********
					PlayerRef.SayCustom(PlayerHackFailSubtype, None, randomChance > 50) 
					
					; only mark fail if chance and no more often than 4 hours
					
					if (!dogmeatScene && ((gameTime - IntimateCheckLastFailTime) > 0.16667))     
						
						if (IntimateCheckFailCount < 6)
							IntimateCheckFailCount += 1
						endIf
						IntimateCheckLastFailTime = gameTime
						LoverBonus(false)
						
						if (DTSleep_SettingNotifications.GetValue() > 0.0)
							if (PersuadeTutorialFailShown < 1)
								; show first tip
								self.MessageOnRestTipID = OnRestMsgTipFailPersuadeID
								
							elseIf (IntimateCheckFailCount >= 4)
								; v2.14 - show tip - reset to 1 to display again
								PersuadeTutorialFailShown = 1
								self.MessageOnRestTipID = OnRestMsgTipFailPersuadeID
							endIf
						endIf
					endIf
					
					; check if sleepy to go to bed, or not sleep to cancel scene -- v2.70
					if (!sleepTime)
						cancledScene = true
					endIf
					Utility.Wait(0.2)
				endIf
				
			else
				SceneData.AnimationSet = -1
				cancledScene = true	; no sleep
				noPreBedAnim = false
				DTSleep_BadBedHeightMessage.Show()
				
				if (waitSecs > 0.1)
					Utility.Wait(waitSecs)
				endIf
			endIf
			
			int sequenceID = -1
			
			if (doScene)
				
				; pre-scene setup
				
				bool doFade = true
				
				if (SceneData.AnimationSet == 0)
					; disable fade by setting or by random for quick dance --- v1.88 -hugs not dance
					useLowSceneCam = false
					
					; v2.82 -- split power-armor check and creature so we can fix Valentine skipping embrace animation
					if (SceneData.CompanionInPowerArmor)
						; animPack check failed to find packs matching situation
						IntimateCompanionRef.FollowerFollow()
						;;;   IntimateCompanionRef = None     ; no need to remove -v2.82
						doFade = false
						
					elseIf (SceneData.IsUsingCreature)
						; v2.82 limit only creatures without hug animations; fix for Valentine Romance XOXO going to bed without animation
						if (SceneData.IsCreatureType < 3 || SceneData.IsCreatureType > 4)
							IntimateCompanionRef.FollowerFollow()
							doFade = false
						endIf
					endIf
					
				elseIf (animPacks.Length > 0 && (DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).GetTimeForPlayID(6001) != 316.22)
					Debug.Trace(myScriptName + " bad anim controller found")
					useLowSceneCam = false
					SceneData.AnimationSet = 0
					animPacks = new int[0]
				endIf
				
				Utility.Wait(0.36)
				
				int undressLevel = -1   ; 1 for bed, 2 for naked intimacy
				if (doFade)
					if (DTSleep_AdultContentOn.GetValue() <= 1.5 || SceneData.AnimationSet == 0 || pickStyle == 2)
						; v3.0 cuddles now pickStyle 2
						if (pickStyle == 2 && DTSleep_AdultContentOn.GetValue() >= 2.0 && DTSleep_SettingIntimate.GetValueInt() < 3)
							; allow naked cuddles or sleep clothes v3.0
							undressLevel = 2
						else
							; normal sleep-undress pref
							undressLevel = 1
							; if sleeping bag and outdoors, normal clothed respect
							if (targetRef.HasKeyword(AnimFurnFloorBedAnims) && !PlayerRef.IsInInterior())
								undressLevel = 0
							endIf
						endIf
					else
						undressLevel = 2
					endIf
				endIf
				; ----------
				; sets up the scene player, companion preferences, clears 2nd lovers if not needed, and also undress according to undressLevel and pickStyle
				; 
				sequenceID = SetUndressAndFadeForIntimateScene(IntimateCompanionRef, targetRef, undressLevel, playerPositioned, playSlowMo, dogmeatScene, useLowSceneCam, animPacks, isNaked, twinBedRef, pickStyle, nearCompanion.PowerArmorFlag)
				; ---------------
				
				bool playerNakedOrPJ = isNaked
				
				if (sleepTime)
					if (!isNaked)
						playerNakedOrPJ = (DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).IsUndressAll
					endIf
					if (!playerNakedOrPJ)
						if ((DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).UndressedForType == 3)
							playerNakedOrPJ = true
							
						elseIf (sleepNapPrefVal > 0 && DTSleep_SettingFadeEndScene.GetValue() >= 1.0)
							; only bother checking if need to know to save time
							playerNakedOrPJ = (DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).IsActorWearingSleepwear(PlayerRef)
						endIf
					endIf
				endIf
				
				if (sleepTime && playerNakedOrPJ && sleepNapPrefVal > 0 && DTSleep_SettingFadeEndScene.GetValue() >= 1.0)
					if (SceneData.AnimationSet < 5 || !IsAAFReady() || !(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).IsSceneAAFSafe(sequenceID, false))
						; only move directly to bed for non-AAF, sleepy time
						if (sleepSafe)
							(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).PlaceInBedOnFinish = true
						else
							(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).PlaceInBedOnFinish = false
						endIf
					else
						(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).PlaceInBedOnFinish = false
					endIF
				else
					(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).PlaceInBedOnFinish = false
				endIf
			endIf
			
			; check to clear 2nd lover if not needed
			if (SceneData.SecondFemaleRole == None && SceneData.SecondMaleRole == None)
				if (DTSleep_CompIntimateLover2Alias != None)
					DTSleep_CompIntimateLover2Alias.Clear()
				endIf
				if (IntimateCompanionSecRef != None)
					if (IntimateCompanionSecRef.IsInFaction(DTSleep_IntimateFaction))
						IntimateCompanionSecRef.RemoveFromFaction(DTSleep_IntimateFaction)
					endIf
					IntimateCompanionSecRef.EvaluatePackage()
					IntimateCompanionSecRef = None
				endIf
			endIf
			
			; start scene - adult pack or regular 
			
			if (doScene && SceneData.AnimationSet > 0 && sequenceID >= 100 && (DTSConditionals as DTSleep_Conditionals).ImaPCMod && TestVersion == -2)
								
				if (SceneData.AnimationSet < 20 && (DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).PlayActionIntimateSeq(sequenceID))
					noPreBedAnim = false
					RegisterForRemoteEvent(targetRef, "OnActivate")			; watch for NPC activate
					RegisterForCustomEvent((DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript), "IntimateSequenceDoneEvent")
					if (spectatorOkay)
						if (pickSpotSelected)
							SetStartSpectators(PlayerRef)					; v2.51 pick-spot spectators face player
						else
							SetStartSpectators(targetRef)
						endIf
					endIf
					
				elseIf ((!SceneData.IsUsingCreature || SceneData.IsCreatureType == CreatureTypeSynth || SceneData.IsCreatureType == CreatureTypeSynthNude) && !SceneData.CompanionInPowerArmor && (DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).PlayActionXOXO())
					; v2.82 some creatures are okay to hug
					noPreBedAnim = false
					RegisterForCustomEvent((DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript), "IntimateSequenceDoneEvent")
					
				elseIf (SceneData.CompanionInPowerArmor && (DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).PlayActionDancing(false))
					; dance for Danse in Power Armor
					noPreBedAnim = false
					RegisterForCustomEvent((DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript), "IntimateSequenceDoneEvent")
					
				else
					noPreBedAnim = true
					
					(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).StopAll()
					FadeInFast(false)
					
					; free retry - v2.73
					if (IntimacyTestCount < 3)
						MyNextSceneOnSameFurnitureIsFreeSID = (DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).DTSleep_IntimateIdleID.GetValueInt()
						if (DTSleep_SettingNotifications.GetValue() >= 1.0)
							if (nearCompanion.PowerArmorFlag || IntimateCompanionRef.WornHasKeyword(ArmorTypePower))
								StartTimer(2.0, IntimateSceneCancelRetryPATimerID)
							else
								StartTimer(2.0, IntimateSceneCancelRetryTimerID)
							endIf
						endIf
					endIf
				endIf
				
			elseIf (doScene && SceneData.AnimationSet == 0)
			
				if (!IntimateCompanionRef.WornHasKeyword(ArmorTypePower) && (DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).PlayActionXOXO())
					noPreBedAnim = false
					RegisterForCustomEvent((DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript), "IntimateSequenceDoneEvent")
					if (spectatorOkay)
						SetStartSpectators(targetRef)
					endIf
						
				elseIf (SceneData.CompanionInPowerArmor && (DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).PlayActionDancing(false))
					; only for Danse in Power Armor --- v2.73
					noPreBedAnim = false
					(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).PlaceInBedOnFinish = false
					RegisterForCustomEvent((DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript), "IntimateSequenceDoneEvent")

				else
					noPreBedAnim = true
					
					(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).StopAll()
					FadeInFast(false)
					
					; free retry - v2.73
					if (IntimacyTestCount < 3)
						MyNextSceneOnSameFurnitureIsFreeSID = 97
						if (DTSleep_SettingNotifications.GetValue() >= 1.0)
							if (nearCompanion.PowerArmorFlag || IntimateCompanionRef.WornHasKeyword(ArmorTypePower))
								StartTimer(2.0, IntimateSceneCancelRetryPATimerID)
							else
								StartTimer(2.0, IntimateSceneCancelRetryTimerID)
							endIf
						endIf
					endIf
				endIf
			else
				SceneData.AnimationSet = -1
				FadeInFast(false)
				noPreBedAnim = true
				(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).StopAll()
			endIf
			
			EnablePlayerControlsSleep()		;v1.25 - moved here from before scene setup to prevent movement during setup
			Utility.Wait(0.08)
			bool aafPlay = IsAAFReady()
			if (aafPlay && !(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).IsSCeneAAFSafe(sequenceID, false))			; v2.73
				aafPlay = false
			endIf
			if (SceneData.AnimationSet >= 5 && SceneData.AnimationSet < 12 && aafPlay && DTSleep_SettingTestMode.GetValue() >= 1.0)
				DisablePlayerControlsSleep(3)	; allow move to show HUD
			elseIf (DTSleep_SettingCancelScene.GetValue() > 0 && SceneData.AnimationSet >= 1 && !aafPlay)
				DisablePlayerControlsSleep(-1)	; allow menu to cancel
			else
				;DisablePlayerControlsSleep(0)
				DisablePlayerControlsSleep(1)  ; no move
			endIf

		else
			DTDebug(" on no-intimate list - " + basebedForm, 1)
			;cancledScene = true
			noPreBedAnim = true
			if (DTSleep_SettingWarnLoverBusy.GetValue() > 0.0)
				DTSleep_BadBedIntimateMessage.Show()
				Utility.Wait(1.7)
			endIf
			
		endIf
	endIf
	
	if (IntimateCompanionRef != None)
		; if no-scene then remove invalid intimate companions, otherwise will remove on flipside
			
		if (IntimateCompanionRef == StrongCompanionRef || SceneData.IsCreatureType >= 5 || dogmeatScene || nearCompanion.RelationRank <= 2 || IntimateCompanionRef.WornHasKeyword(ArmorTypePower))
		
			if (noPreBedAnim || cancledScene || undressCheck)
				
				IntimateCompanionRef.FollowerFollow()
				IntimateCompanionRef = None
			endIf
		endIf
	endIf
	
	if (undressCheck)
		WakeStopIntimQuest(true)
		if (nearCompanion != None && nearCompanion.CompanionActor != None && nearCompanion.CompanionActor.IsInFaction(DTSleep_IntimateFaction))
			nearCompanion.CompanionActor.RemoveFromFaction(DTSleep_IntimateFaction)
		endIf
		HandleUndressCheck(IntimateCompanionRef, nearCompanion.RequiresNudeSuit)
	
	elseIf (cancledScene)
		
		WakeStopIntimQuest(true)
		if (nearCompanion != None && nearCompanion.CompanionActor != None && nearCompanion.CompanionActor.IsInFaction(DTSleep_IntimateFaction))
			nearCompanion.CompanionActor.RemoveFromFaction(DTSleep_IntimateFaction)
		endIf
		SetDogAndCompanionFollow(IntimateCompanionRef)
		EnablePlayerControlsSleep()
		
		if (SceneData.CurrentLoverScenCount == 0 && SceneData.BackupCurrentLoverScenCount > 0 && SceneData.BackupMaleRole != None)
			RestoreSceneData()
		endIf
		
	elseIf (noPreBedAnim)
		
		WakeStopIntimQuest(true)
		if (nearCompanion != None && nearCompanion.CompanionActor != None && nearCompanion.CompanionActor.IsInFaction(DTSleep_IntimateFaction))
			nearCompanion.CompanionActor.RemoveFromFaction(DTSleep_IntimateFaction)
		endIf
		SetDogAndCompanionFollow(IntimateCompanionRef)
		
		if (isSpecialAnimBed && DTSleep_PlayerUndressed.GetValue() == 0.0 && DTSleep_SettingUndress.GetValue() > 0.0)
		
			;DisablePlayerControlsSleep(0)
			SetUndressForSpecialAnimBed(targetRef, false, isNaked)
			
		elseIf (DTSleep_PlayerUndressed.GetValue() > 0.0)
			SetUndressStop(false)
		endIf
		
		if (SceneData.CurrentLoverScenCount == 0 && SceneData.BackupCurrentLoverScenCount > 0 && SceneData.BackupMaleRole != None)
			RestoreSceneData()
		endIf
		
		EnablePlayerControlsSleep()
		
		; record for future sleepy checks
		(DTSleep_HealthRecoverQuestP as DTSleep_HealthRecoverQuestScript).LastSleepCheckTime = gameTime
		
		ActivatePlayerSleepForBed(targetRef, isSpecialAnimBed, isNaked)

	endIf
EndFunction

Function HandlePlayerActivateOutfitContainer(ObjectReference akTarget, bool forBed = false)
	
	; v2.60 - always redress with quick dress
	(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).PlayerRedressEnabled = true
	
	if (akTarget != None)

		bool undressCheck = IsUndressCheckRequested()
		
		; if has stored outfit, get
		Form[] oldOutfit = None
		
		if (akTarget.HasKeyword(DTSleep_OutfitContainerKY))
		
			if ((akTarget as DTSleep_OutfitContainerScript).HasStoredOutfit > 0)
			
				bool doGet = true
				if (forBed && (akTarget as DTSleep_OutfitContainerScript).HasStoredOutfit != 2)
					; a precaution to make sure only get sleep outfit for bed
					doGet = false
				elseIf (forBed)
					; v2.14 - skip get if wearing PJs
					if ((DressData.PlayerEquippedSlot58IsSleepwear || DressData.PlayerEquippedSlotFXIsSleepwear))
						doGet = false
					elseIf (DressData.PlayerEquippedSleepwearItem != None)
						doGet = false
					endIf
				endIf

				if (undressCheck && DTSleep_PlayerUndressed.GetValue() > 0.0)
					oldOutfit = (akTarget as DTSleep_OutfitContainerScript).GetOutfit(PlayerRef)
					
				elseIf (!undressCheck && doGet)
					oldOutfit = (akTarget as DTSleep_OutfitContainerScript).GetOutfit(PlayerRef)
				endIf
			endIf
			
			if (!forBed)
				akTarget.Activate(PlayerRef)
			endIf
		endIf
		
		; undress
		DisablePlayerControlsSleep(1)  ; look enabled, activate disabled
		GoThirdPerson(true)
		Utility.Wait(0.42)
		float timeToWait = 1.76
		
		if (undressCheck)
			if (DTSleep_PlayerUndressed.GetValue() <= 0.0)
				
				SetUndressForCheck(true, None)

			endIf
		else
			(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).AltFemBodyEnabled = false
			;   clothing, no companion, no winter, no companion nudeSuit, no bed, no Pip-boy, no drop sleepwear, carryBonus, placePack
			SetUndressForManualStop(true, None, false, false, None, false, false, forBed, forBed)  
		endIf
		
		Utility.Wait(timeToWait)  ; wait for undress monitor and allow time for player to experience dressing
		
		Form[] newOutfit = (DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).GetPlayerStoredArmorArray()
		
		(akTarget as DTSleep_OutfitContainerScript).AddOutfit(newOutfit, PlayerRef)
		
		; get dressed
		(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).SetPlayerStoredArmorArray(oldOutfit)
		
		if (forBed)
			; v1.61 - block removal of carry bonus on redress when changing clothes
			(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).EnableCarryBonusRemove = false
		endIf
		
		if ((DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).UndressedForType >= 5)
			; equip system had initialized
			StartTimer(2.5, UndressedInitTipTimerID)
		endIf
		
		; force redress
		(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).StopAll(false)
		
		Utility.Wait(0.30)
		int i = 0
		while (i < 10 && (DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).IsRedressing)
			Utility.Wait(0.1)
			i += 1
		endWhile

		Utility.Wait(0.33)
		
		DTSleep_CaptureExtraPartsEnable.SetValue(0.0)
		
		if (!forBed)
			GoFirstPerson()
		endIf
		EnablePlayerControlsSleep()
		
	endIf
	
EndFunction

bool HandlePlayerFurnitureBusy = false

; specialFurn: <0 = any chair, 1 = pillory, 2 = chair supporting sex, 3 = desk, 4 = PA Repair station, 5 = workbench
;  101 = dance pole, 102 = sedan/motorcycle, 103 = pool table, 104 = picnic table, 105 = jail door, 106 = locker door
;
;  note: isNaked only covered by perk; not 101, 102, 103
;
Function HandlePlayerActivateFurniture(ObjectReference akFurniture, int specialFurn, bool isNaked = false)

	if (HandlePlayerFurnitureBusy || (DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SceneIsPlaying)
		Debug.Trace(myScriptName + " HandlePlayerActivateFurniture cancel is busy (" + HandlePlayerFurnitureBusy + ") or SceneIsPlaying")
		return
	endIf
	
	IntimateCompanionRef = None
	Form furnBaseForm = None
	;ObjectReference akPillory = None
	ObjectReference propObjRef = None
	ObjectReference furnToPlayObj = akFurniture
	bool companionReady = false
	bool cancledScene = false
	bool noPreBedAnim = true
	bool doFade = true
	bool sameLover = false
	bool testPassEnabled = false
	bool hugsOnly = false
	bool kissOK = true					; v2.90
	bool kissPicked = false 				; v2.90
	bool showPrompt = true
	bool isPillory = false
	bool pickSpot = false
	int pickedOtherFurniture = 0
	int playerPickedStyle = -1				; for chairs supporting oral(5) or other
	bool doDance = false
	bool doSexyDance = false
	bool doOtherProp = false
	bool recheckFurnUse = false
	bool chairActuallyInUse = false
	bool lapDanceOkay = false
	bool companionFound = false
	int creatureVal = 0
	int rIdx = -1
	int readyVal = 0
	float gameTime = Utility.GetCurrentGameTime()
	float daysSinceLastIntimate = gameTime - IntimateLastTime
	float daysSinceLastEmbraceScore = gameTime - IntimateLastEmbraceScoreTime
	float daysSinceFail = gameTime - IntimateCheckLastFailTime
	float hoursSinceLastFail = DTSleep_CommonF.GetGameTimeHoursDifference(gameTime, IntimateCheckLastFailTime)
	IntimateCompanionSet nearCompanion = new IntimateCompanionSet
	int[] animPacks = new int[1]
	SceneData.CompanionBribeType = 0 
	
	; v3.0 - enable romance dance
	DTSleep_RomDanceEnable.SetValueInt(1)   ; init to 1 -- change to 2 for display in prompt
	
	; allow regular dancing with non-romanced companion, or slow-dance for romanced -- v3.0
	bool compRomance = true								
	
	DTSleep_SIDIgnoreOK.SetValueInt(-1)					; reset on Relax v2.74
	
	if (specialFurn == 1)
		isPillory = true
	elseIf (specialFurn == 101)
		doSexyDance = true

	elseIf (specialFurn >= 102)
		doOtherProp = true
		
		if (DTSleep_SettingChairsEnabled.GetValueInt() < 2)
			doOtherProp = false
			hugsOnly = true
			
		elseIf (specialFurn == 102 && (DTSConditionals as DTSleep_Conditionals).SavageCabbageVers < 1.1)
			if ((DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).IsObjSedan(akFurniture))
				doOtherProp = false
				hugsOnly = true
			endIf
		endIf
	endIf
	
	if (DTSleep_SettingModActive.GetValue() <= 0.0)		;v2.24 since now possible to access with mod disabled
		DTSleep_IntimateDisabledMsg.Show()
		return

	elseIf (specialFurn >= 1 && !CanPlayerPerformRest(None, false))			; don't check height of furniture, v2.41 skip rad-damage check
		return
		
	elseIf ((DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).GetTimeForPlayID(6001) != 316.22)
		Debug.Trace(myScriptName + " bad anim controller found")
		return
	
	elseIf (DTSleep_SettingIntimate.GetValue() <= 0.0)	;v2.24 - intimate check for sex scenes
		if (specialFurn > 0 && specialFurn < 100)
			DTSleep_IntimateDisabledMsg.Show()
			return
		elseIf (specialFurn >= 100 && DTSleep_AdultContentOn.GetValue() >= 2.0)
			DTSleep_IntimateDisabledMsg.Show()
			return
		endIf
		hugsOnly = true
		doOtherProp = false

	elseIf (specialFurn > 0 && !IsAdultAnimationAvailable())			; v2.26 check adult now
		hugsOnly = true
		doOtherProp = false
		doSexyDance = false
		
	elseIf (specialFurn > 0 && specialFurn != 101 && !CanPlayerRestRadDam())				; v2.41 now do rad-damage check
		Utility.Wait(0.33)
		hugsOnly = true
		doOtherProp = false
		cancledScene = true							; cancel for sit v3.0
		
		
	elseIf (DTSleep_SettingUndress.GetValue() <= 0.0)	; v2.24 undress check
	
		hugsOnly = true
		doOtherProp = false
		
		; v3.0 hug-only except for sexy-dance situations  
		if (DTSleep_AdultContentOn.GetValueInt() >= 2 && (DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).GetGenderForActor(PlayerRef) == 1)
		
			if (specialFurn == 101)
				hugsOnly = false
			elseIf (specialFurn == 2 && IsSexyDanceCompatibleFurn(akFurniture, furnBaseForm, true))  
				hugsOnly = false
				lapDanceOkay = true
			endIf
		endIf
		
	endIf
	
	if (specialFurn > 0 && !PlayerIntimateCompatible())								; v2.60
		hugsOnly = true
		doOtherProp = false
		doSexyDance = false
	endIf
	
	if (hugsOnly && specialFurn == 101)							; v2.60 fix - force dance pole to dance
		doDance = true
		doSexyDance = false
		;compRomance = false
	endIf
	
	if (!doSexyDance && !doDance && !doOtherProp && akFurniture.IsFurnitureInUse())
	
		if (specialFurn > 2)
			if (DTSleep_SettingNotifications.GetValue() > 0.0)
				DTSleep_PilloryBusyMessage.Show()
			endIf
			
			return

		elseIf (IsFurnitureActuallyInUse(akFurniture, true))
			; is true-love partner using chair?
			bool okayToGo = false
			chairActuallyInUse = true
			
			if ((DTSConditionals as DTSleep_Conditionals).WeightBenchKY != None && akFurniture.HasKeyword((DTSConditionals as DTSleep_Conditionals).WeightBenchKY))
				; cannot use 
				okayToGo = false
				
			elseIf ((DTSConditionals as DTSleep_Conditionals).LoverRingEquipCount > 0)
				if (DTSleep_TrueLoveAlias != None)
					Actor loverActor = DTSleep_TrueLoveAlias.GetActorReference()
					; v2.64 - changed DTSleep_ArmorLoverRing count to keyword check
					if (loverActor != None && loverActor.WornHasKeyword(DTSleep_LoverRingKY) && loverActor.GetDistance(PlayerRef) < 200.0)
						if (DTSleep_CommonF.IsActorOnBed(loverActor, akFurniture))
							; is ringer bearer so let normal find work below
							okayToGo = true
						endIf
					endIf
				endIf
			else
				Actor actorInBed = GetCompanionInLoveUsingBed(akFurniture)
				if (actorInBed != None)
					bool compOK = false
					int acGender = (DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).GetGenderForActor(actorInBed)
					int playerGender = (DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).GetGenderForActor(PlayerRef)
					int genderPref = DTSleep_SettingGenderPref.GetValueInt()
					if (genderPref == 2 || acGender == genderPref)
						if (isPillory)
							if (acGender != playerGender)
								compOK = true
							endIf
						else
							compOK = true
						endIf
						if (compOK)
							companionFound = true
							okayToGo = true
							nearCompanion = new IntimateCompanionSet
							nearCompanion.CompanionActor = actorInBed
							nearCompanion.Gender = acGender
							nearCompanion.HasLoverRing = true   ; not really, but let's pretend -- allows sit and grants bonus to chance
							nearCompanion.RelationRank = GetRelationRankActor(actorInBed, false)
							if (IsCompanionPowerArmorGlitched(actorInBed, true))
								nearCompanion.PowerArmorFlag = true
							endIf
						endIf
					endIf
				endIf
			endIf
			if (!okayToGo)
				bool okayToSit = false
				
				if (!isPillory)
					okayToSit = OkaySitOnSeat(akFurniture)
				endIf
				if (okayToSit)
					SetUndressForRespectSit(akFurniture)
					
				elseIf (DTSleep_SettingNotifications.GetValue() > 0.0)
					DTSleep_PilloryBusyMessage.Show()
				endIf
				
				return
			endIf
		else
			recheckFurnUse = true			; recheck again to cancel if actor gets too close
		endIf
	elseIf (specialFurn == 4)
		int pasCheck = IsPAStationOpen(akFurniture)
		if (pasCheck <= 0)
			if (DTSleep_SettingNotifications.GetValue() > 0.0)
				if (pasCheck >= -1)
					DTSleep_PilloryBusyMessage.Show()
				elseIf (pasCheck == -2)
					DTSleep_PAStationPANearMessage.Show()
				endIf
			endIf
			
			return
		endIf
	endIf
	
	if (!doDance && daysSinceFail < 0.047)
		
		if (specialFurn > 2)
			DTSleep_PersuadeSoonMessage.Show()
		elseIf (!chairActuallyInUse)
			SetUndressForRespectSit(akFurniture)
			if (PlayerHasActiveCompanion.GetValueInt() == 1 && DTSleep_SettingWarnLoverBusy.GetValue() > 0.0)
				DTSleep_PersuadeSoonMessage.Show()
			endIf
		elseIf (PlayerHasActiveCompanion.GetValueInt() == 1 && DTSleep_SettingWarnLoverBusy.GetValue() > 0.0)
			DTSleep_PersuadeSoonMessage.Show()
		endIf
		
		return
	endIf
	
	PlayerSleepPerkRemove()						; v2.41 remove until end for safety 
	
	HandlePlayerFurnitureBusy = true
	
	; resets
	SceneData.SecondFemaleRole = None
	SceneData.SecondMaleRole = None
	DTSleep_SexStyleLevel.SetValue(0.5)				; v2.90 change to 0.5 for kiss inclusion -- now uses EmbraceLevel v3
	DTSleep_EmbraceLevel.SetValue(1.0)				; v3.01 - set to kiss
	
	
	if ((DTSConditionals as DTSleep_Conditionals).IsVulpineRace != None && (DTSConditionals as DTSleep_Conditionals).IsVulpineRacePlayerActive)
		kissOK = false
		DTSleep_SexStyleLevel.SetValue(0.0)
		DTSleep_EmbraceLevel.SetValue(0.0)
	endIf
	
	if (hugsOnly)
		doOtherProp = false
		animPacks[0] = 0
		; doSexyDance handled later
	elseIf (DTSleep_AdultContentOn.GetValue() <= 1.5 || TestVersion == -3 || (DTSConditionals as DTSleep_Conditionals).ImaPCMod == false)
		hugsOnly = true
		animPacks[0] = 0
		doOtherProp = false
		; doSexyDance handled later
		
	elseIf (isPillory && (DTSConditionals as DTSleep_Conditionals).ImaPCMod)
		animPacks.Clear()
		if ((DTSConditionals as DTSleep_Conditionals).ImaPCMod && (DTSConditionals as DTSleep_Conditionals).IsSavageCabbageActive)
			animPacks.Add(7)
		endIf
		if ((SleepPlayerAlias as DTSleep_PlayerAliasScript).DTSleep_IsZaZOut.GetValueInt() > 0 && (DTSConditionals as DTSleep_Conditionals).ZaZPilloryKW != None)
			bool okayToAdd = true
			if (animPacks.Length > 0 && !akFurniture.HasKeyword((DTSConditionals as DTSleep_Conditionals).ZaZPilloryKW))
				if (Utility.RandomInt(4, 8) <= 6)
					okayToAdd = false
				endIf
			endIf
			if (okayToAdd)
				animPacks.Add(8)
			endIf
		endIf
	elseIf (specialFurn == 4)
		if ((DTSConditionals as DTSleep_Conditionals).IsAtomicLustActive)
			animPacks[0] = 5
		else
			hugsOnly = true
			animPacks[0] = 0
		endIf
	elseIf (specialFurn == 2 && (DTSConditionals as DTSleep_Conditionals).WeightBenchKY != None && akFurniture.HasKeyword((DTSConditionals as DTSleep_Conditionals).WeightBenchKY))
		; weight bench
		if ((DTSConditionals as DTSleep_Conditionals).IsSavageCabbageActive && (DTSConditionals as DTSleep_Conditionals).SavageCabbageVers >= 1.10)
			; requires SavageCabbage 1.1
			animPacks[0] = 7
		else 
			hugsOnly = true
			animPacks[0] = 0
			doOtherProp = false
		endIf
		
	elseIf (specialFurn >= 103 && specialFurn <= 104 && IsAdultAnimationAvailable())
		if (furnBaseForm == None)
			furnBaseForm = akFurniture.GetBaseObject()
		endIf
		; get animpacks after get companion
	elseIf (specialFurn == 105 && (DTSConditionals as DTSleep_Conditionals).IsSavageCabbageActive && (DTSConditionals as DTSleep_Conditionals).SavageCabbageVers >= 1.20)
		animPacks[0] = 7
		; oral choice
		;if (kissOK)
		;	DTSleep_SexStyleLevel.SetValue(9.5)
		;else
		DTSleep_SexStyleLevel.SetValue(9.0)
		;endIf
	
	elseIf (specialFurn == 106 && ((DTSConditionals as DTSleep_Conditionals).IsSavageCabbageActive && (DTSConditionals as DTSleep_Conditionals).SavageCabbageVers >= 1.27))
		; v2.77 - locker
		animPacks.Clear()
		if ((DTSConditionals as DTSleep_Conditionals).IsSavageCabbageActive && (DTSConditionals as DTSleep_Conditionals).SavageCabbageVers >= 1.27)
			animPacks.Add(7)
		endIf
		
		if ((DTSConditionals as DTSleep_Conditionals).IsBP70Active)
			animPacks.Add(10)
		endIf
		
		DTSleep_SexStyleLevel.SetValue(0.0)
		
	elseIf (specialFurn > 0 && specialFurn != 103 && specialFurn != 104 && IsAdultAnimationChairAvailable())
		; may be mutliple packs with chair support --- v2.73
		animPacks.Clear()
		if ((DTSConditionals as DTSleep_Conditionals).IsSavageCabbageActive)
			animPacks.Add(7)
		endIf
		if (specialFurn == 2)
			float leitoVal = DTSleep_IsLeitoActive.GetValue()					
			if (leitoVal >= 2.10 && leitoVal <= 2.9)
				animPacks.Add(6)								; if same-gender, no-toy may need to remove this pack
			endIf
			if ((DTSConditionals as DTSleep_Conditionals).IsAtomicLustActive)
				animPacks.Add(5)
			endIf

			if ((DTSConditionals as DTSleep_Conditionals).IsBP70Active)
				animPacks.Add(10)
			endIf

		endIf
		if (animPacks.Length == 0)
			hugsOnly = true
			doOtherProp = false
			animpacks.Add(0)
		endIf
	else
		hugsOnly = true
		doOtherProp = false
		animPacks[0] = 0
		; doSexyDance handled later
	endIf
	
	DisablePlayerControlsSleep(2)	; prevent look
	
	; ------ get companion --- 
	;
	int minRank = 3
	int genderPref = -2
	float intimateSetting = DTSleep_SettingIntimate.GetValue()
	if (intimateSetting == 2.0 || intimateSetting == 4.0)
		minRank = 2
	endIf
	if (!cancledScene && !companionFound)
		if (isPillory || specialFurn == 105 || (specialFurn >= 3 && specialFurn < 100))
			; force pillory, desk, jail, and sometimes PA to opposite gender for search
			int playerGender = (DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).GetGenderForActor(PlayerRef)
			if (playerGender == 1)
				if (specialFurn != 4)		; allow FF for PA (4)
					genderPref = 0
				endIf
			else
				genderPref = 1
			endIf
		endIf
		
		nearCompanion = GetCompanionNearbyHighestRelationRank(true, minRank, genderPref)
	endIf

	; ------ check companion 
	; 
	
	bool companionCompatible = false			
	
	if (!cancledScene && nearCompanion != None && nearCompanion.CompanionActor != None)
	
		if (doSexyDance)
			companionCompatible = true
			;compRomance = false
			
		elseIf (hugsOnly)
			if (!isPillory && !doOtherProp)
				if (nearCompanion.CompanionActor == StrongCompanionRef || nearCompanion.CompanionActor.HasKeyword(ActorTypeRobotKY))
					companionCompatible = false
					compRomance = false
				else
					companionCompatible = true
				endIf
			endIf
			
		elseIf (nearCompanion.CompanionActor == StrongCompanionRef || nearCompanion.CompanionActor.HasKeyword(ActorTypeRobotKY) || nearCompanion.CompanionActor.HasKeyword(ActorTypeSuperMutantBehemothKY))
			; Strong force pick-spot for chairs except for SMBed, v2.70 and also sofa if have SC 1.2.6
			
			kissOK = false    ; no kiss Strong or robot   v2.90
			
			if (!isPillory && specialFurn != 4 && specialFurn < 102)
				companionCompatible = true
				creatureVal = CreatureTypeStrong
				compRomance = false
				
				if (DTSleep_AdultContentOn.GetValue() >= 2.0 && (DTSConditionals as DTSleep_Conditionals).ImaPCMod && TestVersion == -2)
					animPacks.Clear()
					
					bool setPickSpot = true
					
					if ((DTSConditionals as DTSleep_Conditionals).IsSavageCabbageActive)
						animPacks.Add(7)
						if (akFurniture.HasKeyword((DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).DTSleep_SMBed02KY))
							DTSleep_SexStyleLevel.SetValueInt(6)
							setPickSpot = false
						elseIf (akFurniture.HasKeyword((DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).AnimFurnCouchKY))
							if ((DTSConditionals as DTSleep_Conditionals).SavageCabbageVers >= 1.26)
								DTSleep_SexStyleLevel.SetValueInt(6)
								setPickSpot = false
							endIf
						elseIf ((DTSConditionals as DTSleep_Conditionals).SavageCabbageVers >= 1.26)
							; try other sofas
							if (furnBaseForm == None)
								furnBaseForm = akFurniture.GetBaseObject()
							endIf
							if ((DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).DTSleep_IntimateCouchList.HasForm(furnBaseForm))
								DTSleep_SexStyleLevel.SetValueInt(6)
								setPickSpot = false
							endIf
						endIf
					endIf
					
					; check Leito's 2.1 -- v2.73
					if ((DTSConditionals as DTSleep_Conditionals).IsLeitoAAFActive && (DTSConditionals as DTSleep_Conditionals).LeitoAnimVers >= 2.1)
						if ((DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).IsObjBenchSofa(akFurniture, furnBaseForm))
							animPacks.Add(6)
							DTSleep_SexStyleLevel.SetValueInt(6)
							setPickSpot = false
						endIf
					endIf
					
					;if (setPickSpot)  ; v2.70 --- remove random --- || Utility.RandomInt(2,9) > 6)   ;---v2.88 commented otu
						if ((DTSConditionals as DTSleep_Conditionals).IsLeitoActive)
							animPacks.Add(1)
						elseIf ((DTSConditionals as DTSleep_Conditionals).IsLeitoAAFActive)
							animPacks.Add(6)
						endIf
						
						if ((DTSConditionals as DTSleep_Conditionals).IsMutatedLustActive)			; v2.88 fix strong uses mutated, not atomic
							animPacks.Add(5)
						endIf
						
						if ((DTSConditionals as DTSleep_Conditionals).IsGrayCreatureActive)
							animPacks.Add(9)
						endIf
						
						
					;endIf
					
					if (animPacks.Length > 0)
						if (setPickSpot)
							pickSpot = true
						endIf
					else
						animPacks.Add(0)
						hugsOnly = true
						doDance = true
					endIf
				else
					companionCompatible = false
				endIf
			endIf
		elseIf (akFurniture.HasKeyword((DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).DTSleep_SMBed02KY))
			companionCompatible = true
			animPacks.Clear()
			
			if ((DTSConditionals as DTSleep_Conditionals).IsSavageCabbageActive)
				animPacks.Add(7)
			endIf
			if (pickSpot || Utility.RandomInt(2,9) < 5)
				if ((DTSConditionals as DTSleep_Conditionals).IsLeitoActive)
					animPacks.Add(1)
				elseIf ((DTSConditionals as DTSleep_Conditionals).IsLeitoAAFActive)
					animPacks.Add(6)
				endIf
				if ((DTSConditionals as DTSleep_Conditionals).IsGrayAnimsActive)
					animPacks.Add(9)
				endIf
				if (animPacks.Length == 0)
					animPacks.Add(0)
					hugsOnly = true
				endIf
			endIf
		else
			companionCompatible = true
		endIf
	endIf
	
	bool secondLoverCheckPreferHugs = false								; v2.51 to handle case where same gender can find 2nd lover
	bool sameGenderPickSpotOK = false									; v2.51 to handle pick-spot and 2nd lover checks
	
	if (!cancledScene && companionCompatible)
	
		if (nearCompanion.Gender < 0)
			nearCompanion.Gender = (DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).GetGenderForActor(nearCompanion.CompanionActor)
		endIf
		nearCompanion.CompanionActor.AddToFaction(DTSleep_IntimateFaction)
		
		if (compRomance)
			; make sure
			if (!nearCompanion.HasLoverRing && nearCompanion.RelationRank < 4)
				; no ring and at best infatuated
				compRomance = false
			endIf
		endIf

		; same lover check before update SceneData
		if (DTSleep_IntimateEXP.GetValue() <= 0.0)
		
			sameLover = true  ; no penalty to get started
		
		elseIf (SceneData.MaleRole == None && SceneData.FemaleRole == None)
			sameLover = true
			
		elseIf (SceneData.MaleRole == nearCompanion.CompanionActor || SceneData.FemaleRole == nearCompanion.CompanionActor)
			
			if (SceneData.CurrentLoverScenCount > 0)
				sameLover = true
			endIf
		endIf
		
		;DTDebug(" furniture activate check nearCompanion " + nearCompanion.CompanionActor + " gender = " + nearCompanion.Gender, 2)

		;  ***** verify companion is ready and update SceneData
		;
		bool powerArmorOK = false
		bool hugOK = false
		if (specialFurn <= 2 && nearCompanion.CompanionActor != StrongCompanionRef)
			if (!hugsOnly && IsAdultAnimationAvailable() == false)		; v2.60 - limit 
				hugOK = true											; reduce time checking characters for race or strap-on
			endIf
		elseIf (specialFurn >= 100)		
			if (specialFurn >= 103 && specialFurn <= 104)
				if ((DTSConditionals as DTSleep_Conditionals).IsAtomicLustActive)
					powerArmorOK = true	
				endIf
			endIf
		endIf
		
		; also updates SceneData,
		readyVal = IsCompanionActorReadyForScene(nearCompanion, false, None, powerArmorOK, hugOK)
		
		; v2.60 - check to force hugs
		if (readyVal == -1001)
			hugOK = true
			powerArmorOK = false
			hugsOnly = true
			doOtherProp = false
			doSexyDance = false					; no gender check for sexydance-- old commented below v2.82
			if (specialFurn == 101)				; 
				doDance = true
			endIf
			;if (doSexyDance)
			;	if ((DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).GetGenderForActor(PlayerRef) == 0)
			;		doSexyDance = false
			;		if (specialFurn == 101)
			;			doDance = true
			;		endIf
			;	endIf
			;endIf
			; also updates scene-data  but **** hugOK skips same-gender toy check!! ****
			readyVal = IsCompanionActorReadyForScene(nearCompanion, false, None, powerArmorOK, hugOK)			
		endIf
		DTSleep_CompIntimateQuest.Start()

		DTSleep_OtherFurnitureRefAlias.ForceRefTo(akFurniture)		; if player chooses other prop, this will update to prop
		
		; check intimate alias 

		Actor intimateAliasActor = DTSleep_CompIntimateAlias.GetActorReference()
		if (intimateAliasActor != None && intimateAliasActor != nearCompanion.CompanionActor)
			DTDebug(" correcting intimate companion alias; found " + intimateAliasActor + " instead of " + nearCompanion.CompanionActor, 1)
			if (intimateAliasActor.IsInFaction(DTSleep_IntimateFaction))
				DTDebug(" correcting other actor (" + intimateAliasActor + ") remove from intimateFaction", 2)
				intimateAliasActor.RemoveFromFaction(DTSleep_IntimateFaction)
			endIf
			DTSleep_CompIntimateAlias.ForceRefTo(nearCompanion.CompanionActor)
		endIf
		if (readyVal > 0)
			nearCompanion.CompanionActor.EvaluatePackage()
			Utility.Wait(0.333)
		endIf
		
		; check to clear Dogmeat v2.22 -- v2.35 clear the bed
		if (PlayerHasActiveDogmeatCompanion.GetValueInt() <= 0)
			; prevent Dogmeat teleport later
			Utility.Wait(0.2)
			if (DTSleep_DogBedIntimateAlias != None)
				DTSleep_DogBedIntimateAlias.Clear()
			endIf
		endIf
		
		if (readyVal > 0)
			; update packs with SceneData gender info
			
			IntimateCompanionRef = nearCompanion.CompanionActor
			
			if (DTSleep_RomDanceEnable.GetValueInt() > 0)
				; romance dances available
				if (compRomance)
					; display Dance in prompt
					DTSleep_RomDanceEnable.SetValueInt(2)
				else
					; hide dance in prompt, set back to 1
					DTSleep_RomDanceEnable.SetValueInt(1)
				endIf
			endIf
			
			if (DTSleep_AdultContentOn.GetValue() >= 2.0 && TestVersion == -2 && !hugsOnly && specialFurn >= 102)	; check special furniture
				
				; --------------- SexStyle Level found on each DTSleep_ChairCheck* message ------------------
				;
				;  0,9 = Embrace (or 0.5, 0.95)
				;  1 = try table   returns 8
				;  2 = consider pool table
				;  3 = motorcycle
				;  4 = shower
				;  5,25 = Lap Dance
				;  5,9,19 = oral / Manual
				;  18,19 = Anal   -- returns 7
				;  6 = Pick Spot
				;  7 = Try super mutant bed
				;  8 = kitchen counter
				;  10 = Try railing
				;  20 = Stove (SM)
				; -----------------------------------------------------
				
				if (specialFurn >= 103 && specialFurn <= 104)
					; tables get multiple scenes from multiple packs
					animPacks.Clear()
					animPacks = IntimateAnimPacksPick(true, false, (DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).GetGenderForActor(PlayerRef), akFurniture, furnBaseForm)
					
					if (animPacks.Length == 0 || animPacks[0] <= 0)
						animPacks = new int[1]
						animPacks[0] = 0
						hugsOnly = true
						doOtherProp = false
						
					; v2.53 check for oral   -- SameGender handled below
					elseIf (!SceneData.SameGender)
						if (specialFurn == 103 && DTSleep_CommonF.IsIntegerInArray(7, animPacks))
							; pool table
							; embrace or oral
							;if (kissOK)
							;	DTSleep_SexStyleLevel.SetValue(9.5)
							;else
								DTSleep_SexStyleLevel.SetValue(9.0)
							;endIf
						elseIf (DTSleep_CommonF.IsIntegerInArray(1, animPacks) || DTSleep_CommonF.IsIntegerInArray(6, animPacks))
							; embrace or oral
							;if (kissOK)
								DTSleep_SexStyleLevel.SetValue(9.5)
							;else
								DTSleep_SexStyleLevel.SetValue(9.0)
							;endIf
						endIf
					endIf
				elseIf (specialFurn == 102)
					; sedan or motorcycle
					if ((DTSConditionals as DTSleep_Conditionals).SavageCabbageVers >= 1.1)
						if ((DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).IsObjSedan(akFurniture))
							; any sedan post-war or pre-war support oral 
							; embrace or oral
							;if (kissOK)
							;	DTSleep_SexStyleLevel.SetValue(9.5)
							;else
								DTSleep_SexStyleLevel.SetValue(9.0)
							;endIf
						endIf
					endIf
				endIf
			endIf
			
			if (!doSexyDance)
				companionReady = true
			
				if (SceneData.IsUsingCreature)
					; v2.82 re-order for synth first
					if (SceneData.IsCreatureType == CreatureTypeSynth)
						hugsOnly = true
						animPacks[0] = 0
					elseIf (isPillory || specialFurn == 102)
						companionReady = false
						IntimateCompanionRef = None
					endIf
				
				;
				; TODO: check here for new animationpacks supporting chairs FMF or same-gender
				;
				; --------- SameGender check -------------------			
						; v2.52 added specialFurn restriction
						; v2.60 added !hugsOnly and TestVersion
				elseIf (SceneData.SameGender && specialFurn >= 2 && !hugsOnly && !doSexyDance && TestVersion == -2) 					
					
					if (isPillory)
						companionReady = false
						IntimateCompanionRef = None
						
					elseIf (doOtherProp && specialFurn >= 103 && specialFurn <= 104)				; table animations
						if (SceneData.MaleRoleGender == 1)
							if (!(DTSConditionals as DTSleep_Conditionals).IsAtomicLustActive && !(DTSConditionals as DTSleep_Conditionals).IsRufgtActive)
								if ((DTSConditionals as DTSleep_Conditionals).IsLeitoAAFActive || (DTSConditionals as DTSleep_Conditionals).IsLeitoActive)
									if (!SceneData.HasToyAvailable)
										hugsOnly = true
										animPacks[0] = 0
									endIf
								else
									hugsOnly = true
									animPacks[0] = 0
								endIf
							elseIf (DTSleep_AdultContentOn.GetValueInt() >= 2 && (DTSConditionals as DTSleep_Conditionals).IsRufgtActive)
								; embrace or oral
								;if (kissOK)
								;	DTSleep_SexStyleLevel.SetValue(9.5)
								;else
									DTSleep_SexStyleLevel.SetValue(9.0)
								;endIf
							endIf
						elseIf (!(DTSConditionals as DTSleep_Conditionals).IsAtomicLustActive)
							animPacks[0] = 0
							hugsOnly = true
						endIf
						
					elseIf (doOtherProp)
						animPacks[0] = 0				; no pick-spot for sedan or motorcycle
						hugsOnly = true
					elseIf (specialFurn == 4)
						if (nearCompanion.Gender == 0)
							hugsOnly = true
							animPacks[0] = 0
							
						elseIf (DTSleep_SettingSwapRoles.GetValueInt() >= 1)				; check swap roles v2.82
							SceneData.MaleRole = PlayerRef
							SceneData.FemaleRole = nearCompanion.CompanionActor
						else
							SceneData.MaleRole = nearCompanion.CompanionActor
							SceneData.FemaleRole = PlayerRef
						endIf
					elseIf (!doOtherProp)
						if (specialFurn == 2 && IsSexyDanceCompatibleFurn(akFurniture, furnBaseForm, true))
							lapDanceOkay = true
						elseIf (specialFurn == 2 && SceneData.MaleRoleGender == 0 && DTSleep_SettingLover2.GetValue() >= 1.0 && DTSleep_AdultContentOn.GetValueInt() >= 2)
							; v2.51 - hold off to allow pick of female lover
							secondLoverCheckPreferHugs = true
							int sameGenderVal = (DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).GetFurnitureSupportSameGender(akFurniture, furnBaseForm)
							if (sameGenderVal < 2 && sameGenderVal != 0)
								sameGenderPickSpotOK = true
							endIf
						elseIf (specialFurn == 2 && DTSleep_AdultContentOn.GetValueInt() >= 2)			; v2.51.1 fix Relax
							int sameGenderVal = (DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).GetFurnitureSupportSameGender(akFurniture, furnBaseForm)
							if (sameGenderVal == 1)
								if (SceneData.HasToyAvailable)
									DTDebug("no pick-spot for same-gender female with toy since has supported animation pack for furniture " + furnBaseForm, 2)
								else
									DTDebug("allow pick-spot for same-gender female no-toy at furniture " + furnBaseForm, 2)
									sameGenderPickSpotOK = true
								endIf
							elseIf (sameGenderVal == 2)
								DTDebug("no pick-spot for same-gender female since has supported animation pack for furniture " + furnBaseForm, 2)
							else
								DTDebug("allow pick-spot for same-gender female at furniture " + furnBaseForm, 2)
								sameGenderPickSpotOK = true
							endIf
						else								; v2.51.1 fix Relax 
							hugsOnly = true
							animPacks[0] = 0
						endIf
					endIf
				endIf
			endIf
		endIf 
	endIf
	
	SceneData.CompanionBribeType = -1
	bool furnObjReady = true
	if (recheckFurnUse && IsFurnitureActuallyInUse(akFurniture, true))
		
		furnObjReady = false
	endIf
	
	if (!cancledScene && companionReady && IntimateCompanionRef != None && furnObjReady)
	
		int companionGender = -1

		if (DressData.PlayerGender >= 0)
			if (SceneData.SameGender == 1)
				companionGender = DressData.PlayerGender
			elseIf (DressData.PlayerGender == 0)
				companionGender = 1
			else
				companionGender = 0
			endIf
		endIf
		
		int luck = (PlayerRef.GetValue(LuckAV) as int)
		(DT_RandomQuestP as DT_RandomQuestScript).MySizedPackCount = luck
		float timeSinceShuffle = DTSleep_CommonF.GetGameTimeHoursDifference((DT_RandomQuestP as DT_RandomQuestScript).MyLastHundredShuffleTime, gameTime)
		int shuffleIndex = (DT_RandomQuestP as DT_RandomQuestScript).ShuffledHundredIndex
		
		if (timeSinceShuffle > 64.0 || shuffleIndex > 20)
			; time to shuffle randomizer
			
			(DT_RandomQuestP as DT_RandomQuestScript).ShuffleOnTimerPublic(0.10)
			rIdx = 0
		else
			rIdx = (DT_RandomQuestP as DT_RandomQuestScript).ValidatePublic()
		endIf
		
		; ------------  Set Companion and Dogmeat to follower Wait ------------
		
		if (DTSleep_SettingDogRestrain.GetValue() > 0.0 && PlayerHasActiveDogmeatCompanion.GetValueInt() >= 1)

			processingDogmeatWait = 3
			StartTimer(0.20, DogmeatSetWaitTimerID)
		endIf
		
		IntimateCompanionRef.FollowerWait()         ; for cleaner entry into animations
		; -------------
		
		IntimateChancePair chanceForScene = new IntimateChancePair
		IntimateLocationHourSet locHourChance = new IntimateLocationHourSet
		int sexAppealScore = -2
		int showPromptVal = DTSleep_SettingShowIntimateCheck.GetValueInt()
		
		if (isPillory)
			furnBaseForm = akFurniture.GetBaseObject()
		endIf
		
		; ---------------- check for extra partner --------
		;   all multiple-partner scenes for SceneData assume primary male and female plus one 2nd lover (FMM or FMF)
		;   so if primary lover is same gender need to swap roles for scene to include 2nd lover,
		;   but swap after passing check!
		;
		if (!hugsOnly && !doDance && specialFurn != 4 && DTSleep_AdultContentOn.GetValue() >= 2.0 && intimateSetting < 3 && DTSleep_SettingLover2.GetValue() >= 1.0 && !SceneData.CompanionInPowerArmor && Debug.GetPlatformName() as bool)
			; v2.13 - allow jealous type and reduce chance instead of affinity Companion hates
			if (!SceneData.IsUsingCreature)
				int extraLoverReady = (DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).GetFurnitureSupportExtraActorForPacks(furnToPlayObj, None, animPacks)
				;DTDebug("extraLoverReady " + extraLoverReady + " for furniture " + furnToPlayObj, 2)
				if (extraLoverReady >= 0)
					int loverType = extraLoverReady
					if (SceneData.SameGender && loverType >= 0)
						if (SceneData.MaleRoleGender == 0 && extraLoverReady >= 1)
							; missing a female for FemaleRole -- if player chooses this 2nd lover will need to swap roles
							loverType = 1
						elseIf (SceneData.MaleRoleGender == 1 && extraLoverReady != 1)
							; missing a male for MaleRole -- if player chooses this 2nd lover will need to swap roles
							loverType = 0
						else
							loverType = -1
						endIf
					endIf
					if (loverType >= 0)
						; sets SceneData Second role and alias for name
						SetExtraLovePartners(loverType)
					elseIf (secondLoverCheckPreferHugs)					; v2.51 - since held off
						if (!sameGenderPickSpotOK)
							hugsOnly = true
						endIf
					endIf
				elseIf (secondLoverCheckPreferHugs)						; v2.51 - since held off
					if (!sameGenderPickSpotOK)
						hugsOnly = true
					endIf
				endIf
			elseIf (SceneData.IsCreatureType == CreatureTypeStrong)
				; check for nearby mutants 
				SetExtraMutantPartner()
			elseIf (secondLoverCheckPreferHugs)
				hugsOnly = true
			endIf
		elseIf (secondLoverCheckPreferHugs)
			if (!sameGenderPickSpotOK)
				hugsOnly = true
			endIf
		endIf
		; ------------------------end partner set
		
		if (sameGenderPickSpotOK && specialFurn > 0 && SceneData.SecondMaleRole == None && SceneData.SecondFemaleRole == None) ; v2.51
			animpacks.Clear()
			if (SceneData.MaleRoleGender == 1 && !SceneData.HasToyAvailable)
				; for speed we might have skipped checking toy earlier (hugOK) so let's check now if there is a supported animation pack
				if ((DTSConditionals as DTSleep_Conditionals).IsLeitoActive || (DTSConditionals as DTSleep_Conditionals).IsLeitoAAFActive)
					Armor strapOn = (DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).GetStrapOnForActor(PlayerRef, true, None)
					if (strapOn == None)
						strapOn = (DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).GetStrapOnForActor(nearCompanion.CompanionActor, false, None)
					endIf
					if (strapOn != None)
						SceneData.HasToyAvailable = true
						SceneData.ToyArmor = strapOn
					endIf
				endIf
			endIf
			
			if (SceneData.MaleRoleGender == 0 || SceneData.HasToyAvailable)
				if ((DTSConditionals as DTSleep_Conditionals).IsLeitoActive)
					animPacks.Add(1)
				elseIf ((DTSConditionals as DTSleep_Conditionals).IsLeitoAAFActive)
					animPacks.Add(6)
				endIf
			endIf
			if ((DTSConditionals as DTSleep_Conditionals).IsAtomicLustActive || (DTSConditionals as DTSleep_Conditionals).IsRufgtActive)
				animPacks.Add(5)
			endIf
			if (animPacks.Length == 0)
				animPacks.Add(0)
				hugsOnly = true
				DTDebug("sameGender pickSpot false--hugsOnly", 2)
			else
				pickSpot = true
				DTSleep_SexStyleLevel.SetValueInt(6)
				DTDebug("sameGender pickSpot true", 2)
			endIf
		endIf
		
		bool dogSafe = true ;IsSceneDogmeatSafe(furnToPlayObj)
		bool oralSameGenderOK = false	; some chairs allow same-gender oral/manual; otherwise force pick-spot   v3.0
		
		if (doDance || doSexyDance)
			chanceForScene.Chance = 100
			
		; ----------------------------------------------------------------- show prompt 
		elseIf (showPromptVal > 0 && (dogSafe || hugsOnly))
			; prompt for hugs/sex
			
			; check 2nd lover prompt
			
			if (!hugsOnly && DTSleep_SettingLover2.GetValue() >= 1.0 && IntimateCompanionSecRef != None && (SceneData.SecondMaleRole != None || SceneData.SecondFemaleRole != None))
				; yes/no question
				if (SceneData.IsCreatureType == 0 || SceneData.IsCreatureType == CreatureTypeStrong || SceneData.IsCreatureType == CreatureTypeBehemoth)
					if (SceneData.IsCreatureType == CreatureTypeStrong || SceneData.IsCreatureType == CreatureTypeBehemoth)
						if (DTSleep_IntimateCheckSecondOtherMsg.Show() >= 1)
							; no extra - remove 2nd mutant
							SceneData.SecondMaleRole = None
							SceneData.SecondFemaleRole = None
							ClearIntimateSecondCompanion()
							SceneData.IsCreatureType = CreatureTypeStrong
						else
							; if behemoth, swap with Strong
							if (SceneData.IsCreatureType == CreatureTypeBehemoth && SceneData.SecondMaleRole != None)
								ClearIntimateSecondSwapWithMain()
							endIf
						endIf
					elseIf (DTSleep_IntimateCheckSecondLovMsg.Show() >= 1)
						; no extra - remove 2nd lover
						SceneData.SecondMaleRole = None
						SceneData.SecondFemaleRole = None
						ClearIntimateSecondCompanion()
					endIf
					Utility.Wait(0.85)
				endIf
			endIf
			
			; check props or sexstyle level for menu
			if (specialFurn == 2 && !hugsOnly && DTSleep_AdultContentOn.GetValue() >= 2.0 && TestVersion == -2)
				
				if (SceneData.IsUsingCreature && SceneData.IsCreatureType == CreatureTypeStrong)
					
					if (SceneData.SecondMaleRole == None && DTSleep_SexStyleLevel.GetValueInt() != 6)			; SexStyle may previously be set for SMBbed
						if ((DTSConditionals as DTSleep_Conditionals).IsSavageCabbageActive || (DTSConditionals as DTSleep_Conditionals).IsMutatedLustActive)
							; has oral option
							DTSleep_SexStyleLevel.SetValue(19.0)			; strong oral value to avoid including embrace
							if ((DTSConditionals as DTSleep_Conditionals).SavageCabbageVers >= 1.29 && DTSleep_SettingProps.GetValueInt() >= 1)
								
								; is there a patio table nearby?   v2.88
								propObjRef = DTSleep_CommonF.FindNearestObjectInListFromObjRef(DTSleep_IntimatePatioTwoTableList, akFurniture, 600.0, true)
								if (propObjRef != None)
									DTSleep_SexStyleLevel.SetValue(30.0)
								else
									; is there an stove nearby?  v2.84
									propObjRef = DTSleep_CommonF.FindNearestObjectInListFromObjRef(DTSleep_IntimateStoveList, akFurniture, 600.0, true)
									if (propObjRef != None)
										DTSleep_SexStyleLevel.SetValue(20.0)
									endIf
								endIf
							endIf
						else
							DTSleep_SexStyleLevel.SetValueInt(6)			; hide Embrace and show Pick-Spot
						endIf
					else
						DTSleep_SexStyleLevel.SetValueInt(6)			; hide Embrace and show Pick-Spot
					endIf
					
				elseIf (lapDanceOkay || IsSexyDanceCompatibleFurn(akFurniture, furnBaseForm, SceneData.SameGender))
					; lap dance
					
					if (DTSleep_SettingUndress.GetValueInt() <= 0)
						DTSleep_SexStyleLevel.SetValue(25.0)	; only lap dance for no-undress   v3.0
					
					elseIf (SceneData.SameGender)						; v2.60 - better choices
						if ((DTSConditionals as DTSleep_Conditionals).IsRufgtActive || (DTSConditionals as DTSleep_Conditionals).IsAtomicLustActive)
							DTSleep_SexStyleLevel.SetValue(5.0)		; oral or lap dance
							animPacks.Add(5)
						else
							DTSleep_SexStyleLevel.SetValue(25.0)	; only lap dance
						endIf	
					else
						DTSleep_SexStyleLevel.SetValue(5.0)			; lap dance also supports oral choice
					endIf
					
				elseIf (!doOtherProp)					;; same-gender okay--check below-- v3.0
				
					int seatOralOrAnalVal = -1
					
					if (SceneData.SecondFemaleRole == None && SceneData.SecondMaleRole == None)
						seatOralOrAnalVal = (DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).HasFurnitureOralAnalChoiceInt(akFurniture, furnBaseForm)
					endIf
					
					if (seatOralOrAnalVal > 0)
						; set oral / manual option on prompt
						float val = 0.0
						
						if (!SceneData.SameGender)
							val = 9.0
						
							if (seatOralOrAnalVal == 3)
								val = 18.0
							elseIf (seatOralOrAnalVal == 4)
								val = 17.0		; both
							endIf
						elseIf (seatOralOrAnalVal == 2 && SceneData.SameGender && SceneData.MaleRoleGender == 1)
							val = 9.0
							oralSameGenderOK = true

						elseIf (seatOralOrAnalVal == 1 && SceneData.MaleRoleGender == 0)
							val = 9.0			; allow any furniture
						endIf
						
						;if (kissOK && val < 10)
						;	val += 0.5
						;endIf
						
						DTSleep_SexStyleLevel.SetValue(val)
						
					elseIf (DTSleep_SettingProps.GetValueInt() >= 1 && (DTSConditionals as DTSleep_Conditionals).IsSavageCabbageActive)
						; search for nearby tables and other props
						; v2.53 fix to include true to ignore floors above and below
						propObjRef = DTSleep_CommonF.FindNearestObjectInListFromObjRef(DTSleep_IntimatePropList, akFurniture, 600.0, true)	
						
						if (propObjRef != None)
							;
							Form propBaseForm = propObjRef.GetBaseObject() as Form
							DTDebug(" ----- found prop base-form " + propBaseForm, 2)
							
							if ((DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).DTSleep_IntimateMotorcycleList.HasForm(propBaseForm))
								DTSleep_SexStyleLevel.SetValue(3.0)
							elseIf ((DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).DTSleep_IntimatePoolTableList.HasForm(propBaseForm))
								DTSleep_SexStyleLevel.SetValue(2.0)
							
							elseIf ((DTSConditionals as DTSleep_Conditionals).SavageCabbageVers >= 1.10 && (DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).DTSleep_IntimateShowerList.HasForm(propBaseForm))
								;DTDebug(" prop on shower list", 2)
								DTSleep_SexStyleLevel.SetValue(4.0)
								
							elseIf ((DTSConditionals as DTSleep_Conditionals).SavageCabbageVers >= 1.20 && (DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).DTSleep_IntimateKitchenCounterList.HasForm(propBaseForm))
								DTSleep_SexStyleLevel.SetValue(8.0)
							elseIf ((DTSConditionals as DTSleep_Conditionals).SavageCabbageVers >= 1.26 && (DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).DTSleep_IntimatePierRailingList.HasForm(propBaseForm))
								; v2.70 railings for SC 1.2.6
								; make sure seat far enough away from the railing
								if (propObjRef.GetDistance(akFurniture) > 126.0)
									DTSleep_SexStyleLevel.SetValue(10.0)
								else
									propObjRef = None
								endIf
							endIf
						else
							propObjRef = DTSleep_CommonF.FindNearestObjectInListFromObjRef(DTSleep_IntimateTablesAllList, akFurniture, 375.0, true) ;v2.19 limit to same plane
							
							if (propObjRef != None)
								; table may be fallen over or upside-down
								DTDebug(" ----- found table prop Ref " + propObjRef, 2)
								float angleX = propObjRef.GetAngleX()
								float angleY = propObjRef.GetAngleY()
								if (angleX < 10.0 && angleX > -10.0 &&  angleY < 10.0 && angleY > -10.0)
									DTSleep_SexStyleLevel.SetValue(1.0)
								else
									propObjRef = None
								endIf
								
							elseIf (akFurniture.HasKeyword((DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).DTSleep_SMBed02KY))
								; TODO: these may be stacked or facing a wall
								propObjRef = None
								;DTSleep_SexStyleLevel.SetValueInt(6)	; pick-spot
							endIf
						endIf
					endIf
				endIf
			;elseIf (SceneData.IsCreatureType == CreatureTypeStrong || SceneData.IsCreatureType == CreatureTypeBehemoth || SceneData.IsCreatureType == CreatureTypeDog)
			;	; TODO: smbBed may be stacked or facing wrong way
			;	propObjRef = None
			;	if (DTSleep_SettingTestMode.GetValue() >= 1.0)
			;		propObjRef = DTSleep_CommonF.FindNearestObjectInListFromObjRef((DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).DTSleep_IntimateSMBedList, akFurniture, 600.0)
			;	endIf
			;	if (propObjRef != None)
			;		DTSleep_SexStyleLevel.SetValueInt(7)
			;	else
			;		DTSleep_SexStyleLevel.SetValueInt(6)			; hide Embrace and show Pick-Spot
			;	endIf
			elseIf (SceneData.IsCreatureType == CreatureTypeHandy)
				DTSleep_SexStyleLevel.SetValueInt(6)			; hide Embrace and show Pick-Spot
			endIf
			
			sexAppealScore = PlayerSexAppeal(isNaked, companionGender, creatureVal)
			int checkVal = 15
			
			Location curLoc = (SleepPlayerAlias as DTSleep_PlayerAliasScript).CurrentLocation
			bool checkLoc = true
			
			; nearby NPCs don't matter for hugs, so don't bother checking again if same location within 1 hour
			;
			if (hugsOnly && curLoc != None && IntimateCheckAreaScore != None && IntimateCheckAreaScore.LocChecked != None && curLoc == IntimateCheckAreaScore.LocChecked)
				
				if (IntimateCheckAreaScore.LocChanceType == LocActorChanceHugs)
					
					; if same place, same weather, under an hour then keep old values
					IntimateWeatherScoreSet wScore = new IntimateWeatherScoreSet
					
					if (!PlayerRef.IsInInterior() && IntimateCheckAreaScore.WeatherAdj != 0)
						wScore = ChanceForIntimateSceneWeatherScore()
					else
						wScore.Score = 0
					endIf
					float timeDiff = DTSleep_CommonF.GetGameTimeHoursDifference(gameTime, IntimateCheckAreaScore.CheckTime)
					
					if (wScore.Score == IntimateCheckAreaScore.WeatherAdj && timeDiff < 1.1)
						
						checkLoc = false
						locHourChance = IntimateCheckAreaScore
					endIf
				endIf
			endIf
			
			if (hugsOnly || animPacks.Length == 0 || animpacks[0] == 0)		; v2.53 - in case reverted to hugs
				if (DTSleep_SexStyleLevel.GetValue() >= 1.0)
					DTDebug(" ******************** REVERT SexStyle!!!! ***************", 1)
				endIf
				;if (kissOK)
				;	DTSleep_SexStyleLevel.SetValue(0.5)
				;else
					DTSleep_SexStyleLevel.SetValue(0.0)
				;endIf
			endIf 
			
			if (checkLoc)
				locHourChance = ChanceForIntimateSceneByLocationHour(akFurniture, furnBaseForm, IntimateCompanionRef, nearCompanion.RelationRank, gameTime, hugsOnly)
				; record in case we repeat check after sit/cancel - NPCs don't matter for hugs
				IntimateCheckAreaScore = locHourChance
			endIf
			
			DTDebug("   ------   chair/prop SexStyleLevel = " + DTSleep_SexStyleLevel.GetValue(), 2)
			
			while (checkVal >= 2)
				
				if (hugsOnly)
					
					; -------------------------------- hug-only prompts
					; 0 = Embrace
					; 1 = sit/cancel
					; 2 = show chance
					; 3 = dance
					; 4 = kiss
					;
					if (checkVal == 2)
						; reveal chance score
						checkVal = DTSleep_IntimateCheckHugsChanceMsg.Show(sexAppealScore, chanceForScene.Chance)
					else
						
						float hoursSinceLastIntimate = DTSleep_CommonF.GetGameTimeHoursDifference(gameTime, IntimateLastTime)
						float hoursSinceLastEmbrace = DTSleep_CommonF.GetGameTimeHoursDifference(gameTime, IntimateLastEmbraceTime)
						
						if (isPillory || (specialFurn > 2 && specialFurn != 104))
							; not a chair so should offer cancel instead of sit option  - v2.24
							checkVal = DTSleep_IntimateCheckHugNoSitMsg.Show(sexAppealScore)
							
						elseIf (hoursSinceLastFail > 20.0 && hoursSinceLastIntimate > 20.0 && hoursSinceLastEmbrace > 20.0)
							; default prompt
							checkVal = DTSleep_IntimateCheckHugsMsg.Show(sexAppealScore)
							
						elseIf (hoursSinceLastEmbrace < hoursSinceLastFail && hoursSinceLastEmbrace < hoursSinceLastIntimate)
							; last hug time prompt
							checkVal = DTSleep_IntimateCheckHugsLastHugMsg.Show(sexAppealScore, hoursSinceLastEmbrace)
							
						elseIf (hoursSinceLastFail < hoursSinceLastIntimate)
							checkVal = DTSleep_IntimateCheckHugsRecentMsg.Show(sexAppealScore, hoursSinceLastFail)
						else
							checkVal = DTSleep_IntimateCheckHugsRecentMsg.Show(sexAppealScore, hoursSinceLastIntimate)
						endIf
					endIf
					
				elseIf (specialFurn == 5)
					; use pillory prompt to show name of workbench   -- v2.70
					checkVal = ShowPilloryPrompt(checkVal, nearCompanion, sexAppealScore, chanceForScene.Chance, locHourChance, gameTime)
				elseIf (specialFurn == 4)
					checkVal = ShowPAStationPrompt(checkVal, nearCompanion, sexAppealScore, chanceForScene.Chance, locHourChance, gameTime)
					
				elseIf (specialFurn == 3)
					checkVal = ShowDeskPrompt(checkVal, nearCompanion, sexAppealScore, chanceForScene.Chance, locHourChance, gameTime)
					
				elseIf (isPillory || (doOtherProp && specialFurn != 104))
					checkVal = ShowPilloryPrompt(checkVal, nearCompanion, sexAppealScore, chanceForScene.Chance, locHourChance, gameTime)
					
				else
					checkVal = ShowChairPrompt(checkVal, nearCompanion, sexAppealScore, chanceForScene.Chance, locHourChance, gameTime)
				endIf
				
				; --------------------------------
				; note
				;  for v2.90, increment by checkVal >4 by 1 since added Kiss at 4
				;  for v3.0, increment another 1 since added Dance at 6
				; ------------------------------
					
				if (checkVal == 12)					
					; chose Lap dance
					checkVal = 0
					doDance = false
					doSexyDance = true
					pickSpot = false
					hugsOnly = true
				elseIf (checkVal == 13)
					; pick-spot
					checkVal = 0
					pickSpot = true
					
				elseIf (checkVal >= 3 && checkVal <= 4)				; added 4-kiss v2.90
					; chose normal dance OR embrace OR kiss
					
					if (checkVal == 4)								; v2.90
						kissPicked = true
					elseIf (hugsOnly)
						doDance = true		; on hug-only prompt, embrace is 0 and dance is 3
						chanceForScene.Chance = 100
					endIf
					checkVal = 0
					doSexyDance = false
					animPacks[0] = 0
					hugsOnly = true
					pickSpot = false
					
					if (!doDance) 					; v2.90 - should we do dance instead ?
						if (specialFurn <= 0)
							if (!kissPicked)			; v2.90
								doDance = true
							endIf
						elseIf (SceneData.IsCreatureType == CreatureTypeStrong || SceneData.IsCreatureType == CreatureTypeBehemoth || IntimateCompanionRef == None)
							doDance = true
						elseIf (specialFurn >= 100 && DTSleep_SettingChairsEnabled.GetValue() <= 1.0)		; v2.48.1 fix - dance is 3rd on menu when embrace default
							if (!kissPicked)			; v2.90
								doDance = true
							endIf
						elseIf (specialFurn >= 100 && DTSleep_AdultContentOn.GetValue() <= 1.5)				; v2.48.1 fix - dance just in case
							if (!kissPicked)			; v2.90
								doDance = true
							endIf
						elseIf (SceneData.IsUsingCreature)
							if (!kissPicked)			; v2.90
								; v2.82 fix -- dance is 3rd on menu with Nick Valentine
								doDance = true
							endIf
						endIf
					endIf
					
					
				elseIf (checkVal == 5)
					; chose oral / manual 
					checkVal = 0
					playerPickedStyle = 5				; v3 incremented by 1 due to including a cancel at bed
					doDance = false
					if (!oralSameGenderOK && SceneData.SameGender && specialFurn == 2)		
						; v2.60 - lack chair animations, so must stand
						pickSpot = true
						hugsOnly = false
					endIf
					
				elseIf (checkVal == 6)
					; chose dance / romance dance
					checkVal = 0
					doDance = true
					chanceForScene.Chance = 100
					doSexyDance = false
					hugsOnly = true
					
				elseIf (checkVal == 7)
					; chose anal
					checkVal = 0
					playerPickedStyle = 9
					
				elseIf (checkVal >= 8)
					; picked a table or other prop
					checkVal = 0
					if (propObjRef != None)
						furnToPlayObj = propObjRef
					endIf
					pickSpot = false
					int sexStyleVal = DTSleep_SexStyleLevel.GetValueInt()
					if (sexStyleVal == 4)
						pickedOtherFurniture = 4				; shower needs special message
					elseIf (sexStyleVal == 9)
						pickedOtherFurniture = 8				; kitchen counter needs message
					elseIf (sexStyleVal == 11)
						pickedOtherFurniture = 10				; railing needs message v2.70
					else
						pickedOtherFurniture = 1
					endIf
					DTSleep_OtherFurnitureRefAlias.ForceRefTo(furnToPlayObj)
				endIf
				
				if (checkVal == 0)
					; player chose to attempt sex/hug/dance
					
					if (!doDance && chanceForScene.Chance == 0)
						chanceForScene = ChanceForIntimateScene(nearCompanion, akFurniture, furnBaseForm, gameTime, companionGender, locHourChance, true, sexAppealScore, sameLover, isNaked, hugsOnly)
						
						if (hugsOnly)
							chanceForScene.Chance = ChanceForHugSceneAdjChair(chanceForScene.Chance, nearCompanion.RelationRank)
						elseIf (specialFurn < 100)
							chanceForScene.Chance = ChanceForIntimateSceneAdjChair(chanceForScene.Chance)
						endIf
					endIf

				elseIf (checkVal == 1)
					; player chose cancel - force failure
					chanceForScene.Chance = -4
					SceneData.AnimationSet = -4
					cancledScene = true
					
				elseIf (checkVal == 2)
					; show actual chance
					Utility.Wait(0.6)
					
					chanceForScene = ChanceForIntimateScene(nearCompanion, akFurniture, furnBaseForm, gameTime, companionGender, locHourChance, true, sexAppealScore, sameLover, isNaked, hugsOnly)
					
					if (hugsOnly)
						chanceForScene.Chance = ChanceForHugSceneAdjChair(chanceForScene.Chance, nearCompanion.RelationRank)
					elseIf (specialFurn < 100)
						chanceForScene.Chance = ChanceForIntimateSceneAdjChair(chanceForScene.Chance)
					endIf
				endIf
				
			endWhile  ; end prompt checkVal >= 2
			
		elseIf (!dogSafe && !hugsOnly)
			; --------------------------------------------------------------- no prompt, but un-safe! cancel!
			SceneData.AnimationSet = -3
			chanceForScene.Chance = -8		; force fail
			cancledScene = true

			if (!dogSafe)
				if (PlayerKnowsDogmeatName.GetValue() > 0.0)
					DTSleep_SceneDogMUnsafeMsg.Show()
				else
					DTSleep_SceneDoggyUnsafeMsg.Show()
				endIf
				Utility.Wait(0.2)
			endIf
			
		elseIf (showPromptVal <= 0)
			; ------------------------------------------------------------------------ no prompt - just go!
			; no prompt / automatic -- limit by hours to avoid penalties
			float daysSinceFailLim = 0.3333   ; 8 hours
			float daysSinceLastLim = 0.1250   ; 3 hours
			
			if (hugsOnly)
				daysSinceFailLim = 0.0
				daysSinceLastLim = 0.0
			endIf
			
			if (daysSinceLastIntimate > daysSinceLastLim && daysSinceFail > daysSinceFailLim)

				chanceForScene = ChanceForIntimateScene(nearCompanion, akFurniture, furnBaseForm, gameTime, companionGender, locHourChance, true, sexAppealScore, sameLover, false, hugsOnly)
				if (hugsOnly)
					chanceForScene.Chance = ChanceForHugSceneAdjChair(chanceForScene.Chance, nearCompanion.RelationRank)
				elseIf (specialFurn < 100)
					chanceForScene.Chance = ChanceForIntimateSceneAdjChair(chanceForScene.Chance)
				endIf
			else
				; too soon for auto
				SceneData.AnimationSet = -3
				chanceForScene.Chance = -9		; force fail
				cancledScene = true
			endIf
		endIf
		; ----------------- done Get Chance --------------
		
		; ------------------- Roll random --
		
		int randomChance = 101
		bool luckRoll = false
		testPassEnabled = false
		
		if (!cancledScene)
		
			testPassEnabled = TestIntSceneEnabled(furnToPlayObj)
		endIf
		
		if (doDance)
			if (IntimateCompanionRef != None && IntimateCompanionRef.GetSitState() >= 2)
				; no dance for seated companion
				;Debug.Trace(myScriptName + " companion seated -- no dance!")
				IntimateCompanionRef = None
			else
				SetExtraLovePartners(-1, false)		; any gender, no seated lovers 
			endIf
			randomChance = 1

		elseIf (testPassEnabled)
			randomChance = 1
		else
		
			randomChance = (DT_RandomQuestP as DT_RandomQuestScript).GetNextHundredPackIntPublic()
		endIf
		
		; if chance is low and luck high and failed then try again
		
		if (chanceForScene.Chance > 1 && randomChance > chanceForScene.Chance && luck > 5 && timeSinceShuffle > 0.05 && chanceForScene.Chance <= 55)
			
			int randomLuckRoll = (DT_RandomQuestP as DT_RandomQuestScript).GetNextSizedPackIntPublic()
			if (randomLuckRoll > 5)
				; roll again
				luckRoll = true
				
				randomChance = (DT_RandomQuestP as DT_RandomQuestScript).GetNextHundredPackIntPublic()
			endIf
			
		endIf
		
		DTDebug(" Intimacy Scene chance to beat, Random roll: " + chanceForScene.Chance + " > " + randomChance + " -- luck roll? " + luckRoll, 2)

		
		; ------------------ got random - now do scene or not
		
		if (chanceForScene.Chance >= randomChance && !cancledScene)
			
			int sequenceID = 99
			
			; -------- speak and notify ------------------------------
			if (specialFurn == 105)
				int doorState = akFurniture.GetOpenState()
				if (doorState >= 1 && doorState <= 2)
					akFurniture.SetOpen(false)
					Utility.Wait(0.5)
				endIf
			endIf
			EnablePlayerControlsSleep()
			DisablePlayerControlsSleep(0)	;v1.46 - enable move-control to show HUD notifications

			
			if (testPassEnabled && !doDance && !doSexyDance)
				IntimacyTestCount += 1
			elseIf (!doDance)
				if (!testPassEnabled)   ; v2.82 no speak for testing
					PlayerRef.SayCustom(PlayerLockResultSubtype, None, randomChance > 50) ; speak in head if rand > 50
				endIf
				
				if (hugsOnly)								; includes lap dance 
					if (hoursSinceLastFail < 12.0)
						IntimateCheckLastFailTime -= 12.0	; set-back fail-time to avoid penalize bed intimacy
					endIf
					if (IntimateCheckFailCount > 0)
						; hugs and lap dance reduce fails
						IntimateCheckFailCount -= 1
					endIf
					
					
					if (doSexyDance)
						if (specialFurn == 2)				; do not include dance pole since is free
							self.MessageOnRestID = IntimateSexyPerkTimerID	; check to award sexy bonus after scene
						endIf
					else									; only hugs, not lap dance
						IntimateLastEmbraceTime = gameTime	; record time
						
						self.MessageOnRestID = IntimateEmbracePerkTimerID	; check to award hug perk after scene
					endIf
				else
					; set intimate progress for sex
					SetProgressIntimacy(sexAppealScore, 0, rIdx, locHourChance.NearActors)
				endIf
			endIf
			
			if (!doDance && !doSexyDance)
				SetAffinityForCreature(SceneData.IsCreatureType)
			endIf
			
			if (luckRoll && DTSleep_SettingNotifications.GetValueInt() > 0)

				DTSleep_LuckyMessage.Show()
				Utility.Wait(0.5)
			endIf
			
			; v3.0 decision moved below under if (doDance)
			;if (doDance) ; || (hugsOnly && animPacks[0] == 5))
			;	doFade = false
			;endIf
			
			if (pickSpot)
				PlayPickSpotTimer()
			elseIf (pickedOtherFurniture > 0 && !IsAAFReady())
				
				PlayPickSpotTimer(pickedOtherFurniture)
				
			elseIf (animPacks[0] >= 7 && animPacks[0] < 10 && !IsAAFReady() && PlayerRef.GetDistance(akFurniture) < 90.0)
				; step back
				PlayPickSpotTimer(2)
			endIf
			
			if (!doDance)
				Utility.Wait(0.36)
				
				if (PlayerRef.IsInCombat() || IntimateCompanionRef.IsInCombat() || IntimateCompanionRef.IsWeaponDrawn())
					cancledScene = true
					doSexyDance = false
					PlayerRef.SayCustom(PlayerHackFailSubtype, None)
				endIf
			endIf
			
			if (!cancledScene)
				; sets up the scene player, companion preferences, and also undress if ready
				
				DisablePlayerControlsSleep(1)
				
				if (doDance)
					
					bool doFadeEnable = false
					bool remJacketsOutside = false
					

					doFadeEnable = compRomance   ;v3.02 includes one romance dance
					if (compRomance)
						remJacketsOutside = true 
						if (SceneData.SameGender)
							; for same-gender ensure player is lead dancer v3.0
							if (SceneData.MaleRole != PlayerRef)
								if (DTSleep_SettingSwapRoles.GetValueInt() <= 0)
									SceneData.MaleRole = PlayerRef
									SceneData.FemaleRole = IntimateCompanionRef
								endIf
							endIf
						endIf
					endIf

					(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).StartForActorsAndBed(PlayerRef, IntimateCompanionRef, furnToPlayObj, doFadeEnable, true, false)
					(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SleepBedLocation = (SleepPlayerAlias as DTSleep_PlayerAliasScript).CurrentLocation
					if (doFadeEnable)
						; fade for romantic dance  v3.0
						FadeOutFast(false)
						if (DTSleep_SettingUndress.GetValueInt() > 0.0)
							SetUndressFootwearVals(2)			; dance-only
							(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).PlayerRedressEnabled = true
							(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).PlaceBackpackOkay = false
							(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).DropSleepClothes = false
							(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).EnableCarryBonus = true
							(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).KeepShoesEquipped = true   	; always for dance - v3.02 
							(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).KeepStockingsEquipped = true 
							
							(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).StartForManualStopRespect(IntimateCompanionRef, true, remJacketsOutside)
						endIf
						Utility.Wait(0.4)
					endIf
					
					if (DTSleep_VR.GetValueInt() == 2)
						; override VR-mode for dancing   v3.0

						MainQSceneScriptP.GoSceneViewStart(-5)

					else
						MainQSceneScriptP.GoSceneViewStart(-1)
					endIf
				
					if ((DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).PlayActionDancing(compRomance))
						noPreBedAnim = false
						RegisterForCustomEvent((DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript), "IntimateSequenceDoneEvent")
					endIf
				elseIf (doSexyDance)
					
					if (SetUndressPlaySexyDance(furnToPlayObj, isNaked, compRomance) > 0)
						
						noPreBedAnim = false
					endIf
					
				else
					
					int undressLevel = 0
					if (doFade && !hugsOnly)
						undressLevel = 2
					elseIf (!doFade)
						undressLevel = -1
					endIf
					if (animPacks[0] <= 0)
						animPacks.Clear()
						animPacks = None
					endIf
					
					bool seatIsSpecialEmbrace = false
					bool dinerBoothCustomReady = false 	; for custom animations (not embrace)  v2.83
					
					; v2.83 moved up before undress to pass along if dinerBooth
					; v2.87 or couch cuddle
					if (hugsOnly && !doDance && DTSleep_AdultContentOn.GetValue() >= 1.0)

						if ((DTSConditionals as DTSleep_Conditionals).IsSavageCabbageActive && DTSleep_AdultContentOn.GetValue() >= 2.0)
							; consider ignore list -- v3.0
							if (!(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).GetIsOnIgnoreListSceneID(780))
								if ((DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).IsObjDinerBoothTable(furnToPlayObj, furnBaseForm))
									dinerBoothCustomReady = true
									if (!kissPicked)					;   -- v2.90 
										undressLevel = 3				; set to observe footwear preferences  - v2.83
										seatIsSpecialEmbrace = true
									endIf
								endIf
							endIf
						endIf
						
						; check CHAK at sofa or stool  v3.0
						if (!seatIsSpecialEmbrace && (DTSConditionals as DTSleep_Conditionals).IsCHAKPackActive)
							if ((DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).IsObjStool(furnToPlayObj))  ; fix several stool keywords v3.02
								if (kissPicked)
									seatIsSpecialEmbrace = true
									undressLevel = 3
								endIf
							elseIf (furnToPlayObj.HasKeyword((DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).AnimFurnPicnickTableKY))
								if (kissPicked)
									seatIsSpecialEmbrace = true
									undressLevel = 3
								endIf
							elseIf ((DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).IsObjSofa(furnToPlayObj, furnBaseForm))
								
								if (furnBaseForm != None && !(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).DTSleep_IntimateCouchLimSpaceList.HasForm(furnBaseForm))
									undressLevel = 4  ; treat like a bed
									seatIsSpecialEmbrace = true
								else
									undressLevel = 3
								endIf
							endIf
						endIf
						
						; consider ignore list -- v3.0
						if (!seatIsSpecialEmbrace && !(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).GetIsOnIgnoreListSceneID(535))
							if ((DTSConditionals as DTSleep_Conditionals).IsRufgtRaidHeartActive)
								if ((DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).IsObjSofa(furnToPlayObj, furnBaseForm))
									seatIsSpecialEmbrace = true
									if (!kissPicked)					;   -- v2.90 
										undressLevel = 3				; set observe footwear preferences
									endIf
								endIf
							endIf
						endIf
					endIf
					
					; **** undress and get scene ID if there is one 
					;
					sequenceID = SetUndressAndFadeForIntimateScene(IntimateCompanionRef, furnToPlayObj, undressLevel, pickSpot, false, false, false, animPacks, false, None, playerPickedStyle, nearCompanion.PowerArmorFlag)
					; ****
					
					(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).PlaceInBedOnFinish = false
					
					
					if (sequenceID >= 100 && SceneData.AnimationSet > 0)
					
						if ((DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).PlayActionIntimateSeq(sequenceID))
							noPreBedAnim = false
							if (specialFurn < 100)
								RegisterForRemoteEvent(furnToPlayObj, "OnActivate")			; watch for NPC activate
							endIf
							RegisterForCustomEvent((DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript), "IntimateSequenceDoneEvent")
							if (specialFurn < 4 || specialFurn >= 100)
								; spectators ignore radius on PA station so skip
								if (pickSpot)
									SetStartSpectators(PlayerRef)					; v2.51 - pick-spot spectators face player
								else
									SetStartSpectators(furnToPlayObj)
								endIf
							endIf
						else
							noPreBedAnim = true
							
							(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).StopAll()
							FadeInFast(false)
						endIf
						
					elseIf (!kissPicked && (DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).PlayActionHugs(seatIsSpecialEmbrace))
						; v2.86 - added condition for couch cuddle--TODO: need or remove?
						; v2.90 - replaced random with !kissPicked
						; v3.0 - now use special-embrace furniture
						if (seatIsSpecialEmbrace && DressData.PlayerGender == 1 && dinerBoothCustomReady)
							; change embrace to sexy for female  v2.83
							self.MessageOnRestID = IntimateSexyPerkTimerID
						endIf
						noPreBedAnim = false
						RegisterForCustomEvent((DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript), "IntimateSequenceDoneEvent")
						
					elseIf (kissPicked && (DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).PlayActionKiss(DTSleep_SettingIntimate.GetValueInt(), seatIsSpecialEmbrace))
						; v2.90 added kiss
						noPreBedAnim = false
						RegisterForCustomEvent((DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript), "IntimateSequenceDoneEvent")
					else
						noPreBedAnim = true
						
						(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).StopAll()
						FadeInFast(false)
						
					endIf
				endIf
			endIf
			
			EnablePlayerControlsSleep()
			Utility.Wait(0.08)
			
			if (!cancledScene)
				
				bool aafPlay = IsAAFReady()
				if (aafPlay && !(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).IsSCeneAAFSafe(sequenceID, false))		; v2.73
					aafPlay = false
				endIf
				
				if (SceneData.AnimationSet >= 5 && SceneData.AnimationSet < 12 && aafPlay && DTSleep_SettingTestMode.GetValue() >= 1.0)
					DisablePlayerControlsSleep(3)	; allow move to show HUD
				elseIf (DTSleep_SettingCancelScene.GetValue() > 0 && !hugsOnly && SceneData.AnimationSet >= 1 && !aafPlay)
					DisablePlayerControlsSleep(-1)	; allow menu to cancel
				else
					; v3.0 check CHAK for cancel
					int sid = (DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).DTSleep_IntimateIdleID.GetValueInt()
					if (sid >= 450 && sid < 490 && DTSleep_SettingCancelScene.GetValue() > 0)
						DisablePlayerControlsSleep(-1)	; allow menu to cancel
					else
						DisablePlayerControlsSleep(1)  ; no move
					endIf
				endIf
			endIf
			
		elseIf (chanceForScene.Chance >= 5 && !cancledScene)
			
			PlayerRef.SayCustom(PlayerHackFailSubtype, None, randomChance > 50)
			
			; only mark fail if chance and no more often than 3 hours
			
			if (daysSinceFail > 0.1250)   
				
				if (!hugsOnly)
					IntimateCheckFailCount += 1
				endIf
				IntimateCheckLastFailTime = gameTime
				LoverBonus(false)
			endIf
			Utility.Wait(0.3)
		endIf
		
		if (cancledScene || noPreBedAnim)

			if (DTSleep_PlayerUndressed.GetValue() > 0.0)
				SetUndressStop(false)
				Utility.Wait(0.3)
			endIf
			if (SceneData.CurrentLoverScenCount == 0 && SceneData.BackupCurrentLoverScenCount > 0 && SceneData.BackupMaleRole != None)
				RestoreSceneData()
			endIf
			
			if (specialFurn == 2 || specialFurn <= 0 || specialFurn == 104)
				Utility.Wait(0.2)
				if (!chairActuallyInUse || OkaySitOnSeat(akFurniture, furnBaseForm))
					SetUndressForRespectSit(akFurniture)
				else
					; may or may not be in use for case: lover-ring just stood up
					akFurniture.Activate(PlayerRef)
				endIf
			endIf
			
			WakeStopIntimQuest(true)
			
			if (nearCompanion != None && nearCompanion.CompanionActor != None && nearCompanion.CompanionActor.IsInFaction(DTSleep_IntimateFaction))
				nearCompanion.CompanionActor.RemoveFromFaction(DTSleep_IntimateFaction)
			endIf
			
			SetDogAndCompanionFollow(IntimateCompanionRef)
			EnablePlayerControlsSleep()
			
			SceneData.SecondFemaleRole = None
			SceneData.SecondMaleRole = None
			IntimateCompanionRef = None
		endIf
		
	elseIf (!cancledScene && doSexyDance)
		; do we need a partner for dance pole?
		if (IntimateCompanionRef == None && (DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).GetGenderForActor(PlayerRef) == 1)
			Actor heatherActor = GetHeatherActor()
			if (PlayerHasActiveCompanion.GetValueInt() > 0 && CompanionAlias != None)
				ResetSceneData(true)
				SceneData.FemaleRole = PlayerRef
				SceneData.MaleRole = CompanionAlias.GetActorReference()
				IntimateCompanionRef = SceneData.MaleRole
				
			elseIf (heatherActor != None && PlayerRef.GetDistance(heatherActor) < 2000.0)
				ResetSceneData(true)
				SceneData.FemaleRole = PlayerRef
				SceneData.MaleRole = heatherActor
				IntimateCompanionRef = heatherActor
			elseIf (PlayerHasActiveDogmeatCompanion.GetValueInt() >= 1 && DogmeatCompanionAlias != None)
				ResetSceneData(true)
				SceneData.FemaleRole = PlayerRef
				SceneData.MaleRole = DogmeatCompanionAlias.GetActorReference()
				SceneData.IsUsingCreature = true
				SceneData.IsCreatureType = CreatureTypeDog
				IntimateCompanionRef = SceneData.MaleRole
			endIf
		endIf
		
		if (IntimateCompanionRef != None)
			if (SceneData.FemaleRole != PlayerRef)
				SceneData.MaleRole = IntimateCompanionRef
				SceneData.FemaleRole = PlayerRef
			endIf
			if (PlayerRef.GetDistance(akFurniture) < 100.0)
				; step back
				PlayPickSpotTimer(2)
			endIf
		endIf
		
		
		SetUndressPlaySexyDance(furnToPlayObj, isNaked, compRomance)
		
	elseIf (!furnObjReady)
		EnablePlayerControlsSleep()
		WakeStopIntimQuest(true)
		IntimateCompanionRef = None
		
		if ((specialFurn == 2 || specialFurn == 104) && OkaySitOnSeat(akFurniture, furnBaseForm))
			SetUndressForRespectSit(akFurniture)
				
		elseIf (DTSleep_SettingNotifications.GetValue() > 0.0)
			DTSleep_PilloryBusyMessage.Show()
		endIf
	else
		; no companion ready
		EnablePlayerControlsSleep()
		
		if (isPillory || (specialFurn >= 3 && specialFurn != 104))
			if (DTSleep_SettingWarnLoverBusy.GetValue() > 0.0)
				DTSleep_PersuadePilloryNoneMsg.Show()
			endIf
		elseIf (DTSleep_SettingWarnLoverBusy.GetValue() > 0.0)
			
			if (DTSleep_CompIntimateQuest.IsRunning())
				; companion found, but not available for scene
				SceneData.SecondFemaleRole = None
				SceneData.SecondMaleRole = None
				
				if (readyVal >= -1)
					if (DTSleep_SettingShowIntimateCheck.GetValue() > 0.0 && PlayerHasActiveCompanion.GetValueInt() >= 1)
						int chk = DTSleep_ChairCheckNoCompMessage.Show()
						if (chk == 1)
							SetUndressForRespectSit(akFurniture)
						elseIf (chk == 2)
						
							(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).StartForActorsAndBed(PlayerRef, None, akFurniture, false, true, false)
							(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SleepBedLocation = (SleepPlayerAlias as DTSleep_PlayerAliasScript).CurrentLocation
							if (DTSleep_VR.GetValueInt() == 2)
								; override VR-mode for dancing   v3.0
								MainQSceneScriptP.GoSceneViewStart(-5)
							else
								MainQSceneScriptP.GoSceneViewStart(-1)
							endIf
							
							if ((DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).PlayActionDancing(false))
								
								RegisterForCustomEvent((DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript), "IntimateSequenceDoneEvent")
							endIf
						endIf
					else
						SetUndressForRespectSit(akFurniture)
						Utility.Wait(0.5)
						DTSleep_PersuadePilloryNoneMsg.Show()
					endIf
				
				elseIf (DTSleep_SettingWarnLoverBusy.GetValue() > 0.0)
					if (DisplayCompanionBusyWarn(readyVal, 1) <= 0)
						DisablePlayerControlsSleep()
						Utility.Wait(1.2)
						SetUndressForRespectSit(akFurniture)
						EnablePlayerControlsSleep()
					endIf
				else
					; no warn, quietly sit
					SetUndressForRespectSit(akFurniture)
				endIf			
			else
				; no companion found
				SetUndressForRespectSit(akFurniture)
			endIf
		else
			; no warn just sit
			SetUndressForRespectSit(akFurniture)
		endIf
		
		WakeStopIntimQuest(true)
		IntimateCompanionRef = None
		
		if (nearCompanion != None && nearCompanion.CompanionActor != None && nearCompanion.CompanionActor.IsInFaction(DTSleep_IntimateFaction))
			nearCompanion.CompanionActor.RemoveFromFaction(DTSleep_IntimateFaction)
		endIf
	endIf
	
	PlayerSleepPerkAdd()					; v2.41 add back
	HandlePlayerFurnitureBusy = false
	
EndFunction

Function HandlePlayerSleepStart(float desiredSleepTime, ObjectReference akBed)

	if (SleepBedRegistered == None || SleepBedRegistered != akBed)
		DTDebug(" Sleep start - assume switched beds - bed does not match registered bed " + akBed + ", " + SleepBedRegistered, 1)

		UnregisterForSleepBed(-2.0)
		
		return
	endIf
	
	if (desiredSleepTime < 1.3)
		; decrement rest count 
		int restCount = DTSleep_RestCount.GetValueInt() - 1
		if (restCount > 1)
			DTSleep_RestCount.SetValueInt(restCount)
		endIf
	endIf
	
	if (DTSleep_PlayerUndressed.GetValue() < 1.0)
		IsPlayerOkayToUndressForBed(desiredSleepTime, akBed)
	endIf
	DTDebug("  sleep started in bed " + akBed + ", hours: " + desiredSleepTime + ", canUndress: " + IsUndressReady, 2)

EndFunction


Function HandlePlayerSleepStop(ObjectReference akBed, bool observeWinter = false, bool isFadedOut = false, bool moveToBed = true, bool afterIntimacy = false, bool playerNaked = false)
	bool isBedBusy = false
	int napComp = DTSleep_SettingNapComp.GetValueInt()
	int napOnly = DTSleep_SettingNapOnly.GetValueInt()
	
	Utility.Wait(0.1)		; wait for case of game load  -v2.16
	
	if (DTSleep_PlayerUndressed.GetValueInt() <= 0)
		; dressed - clear second
		if (IntimateCompanionSecRef != None)
			DTDebug("clearing IntimateCompanionSecRef " + IntimateCompanionSecRef + " on HandlePlayerSleepStop", 2)
			if (IntimateCompanionSecRef.IsInFaction(DTSleep_IntimateFaction))
				IntimateCompanionSecRef.RemoveFromFaction(DTSleep_IntimateFaction)
			endIf
			IntimateCompanionSecRef.EvaluatePackage()
			IntimateCompanionSecRef = None
		endIf
		(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).CompanionSecondRef = None
	endIf
	
	if (napComp > 2)
		napComp = 1
		DTSleep_SettingNapComp.SetValueInt(1)
	endIf
	if (afterIntimacy && napComp == 0)
		napComp = 1
	endIf
	
	;Debug.Trace(myScriptName + " HandlePlayerSleepStop ... usingBed: " + DTSleep_PlayerUsingBed.GetValue())

	if (DTSleep_PlayerUsingBed.GetValue() <= 0.0 || akBed == None)
		DTDebug("Handle SleepStop: player not using bed - assumed canceled", 1)

		SleepBedInUseRef = None    	; should be None
		SleepBedRegistered = None
		SleepBedIsPillowBed = false
		DTSleep_PlayerUsingBed.SetValue(0.0)
		
		if (isFadedOut)
			FadeInFast(true)
		endIf
	
		if (DTSleep_SettingNotifications.GetValue() > 0.5)
			DTSleep_SleepCancledSleepStopMsg.Show()
		endIf
		
		return
		
	elseIf (SleepBedRegistered == None || SleepBedRegistered != akBed)
		DTDebug("Handle SleepStop: bed (" + akBed + ") does not match registered bed: " + SleepBedRegistered, 1)

		SleepBedInUseRef = None    	; should be None
		SleepBedRegistered = None
		SleepBedIsPillowBed = false
		DTSleep_PlayerUsingBed.SetValue(-3.0)
		
		if (isFadedOut)
			FadeInFast(true)
		endIf
		
		return
	endIf
	
	SleepBedRegistered = None
	
	if (moveToBed)
		if (akBed == None)
			isBedBusy = true
			DTDebug(" HandlePlayerSleepStop - bed is None!", 1)
			
		elseIf (!OkayToSleepLocationBed(akBed))
			isBedBusy = true
			
		elseIf (akBed.IsFurnitureMarkerInUse(0) || akBed.IsFurnitureMarkerInUse(1))
			; player can't get into double-bed if NPC using marker 0 or 1
			isBedBusy = true
			; ------------------------
			; is this a problem?
			if (IsFurnitureActuallyInUse(akBed))	; v1.92
				isBedBusy = true
			endIf
		elseIf (!akBed.IsEnabled() || !akBed.Is3DLoaded())
			; v2.13 - make sure bed is actually here
			DTDebug(" HandlePlayerSleepStop - bed disabled or not loaded!", 1)
			isBedBusy = true
		endIf
	endIf
		
	if (isBedBusy || akBed == None)
		; too late to catch companion - mark busy

		DTSleep_BedBusyMessage.Show()
		
		DTSleep_PlayerUsingBed.SetValue(0.0)
		
		if (DTSleep_PlayerUndressed.GetValue() > 0.0)
			SetUndressStop(true)
		endIf
		MainQSceneScriptP.GoSceneViewDone(false)
		EnablePlayerControlsSleep()
		
		if (isFadedOut)
			FadeInFast(false)
		endIf
		
		; happy notice - which otherwise displays in bed - v2.14 added here for bed busy
		if (self.SleepLoverBonusOnSleepID > 0)
			StartTimer(5.5, LoverBonusAddTimerID)
		endIf
	else
		; bed not busy 
		; Safe to put player in bed
		SleepBedInUseRef = akBed
		DTSleep_PlayerUsingBed.SetValue(1.0)
		
		; disable HUD until ready to move player
		DisablePlayerControlsSleep(2)
		
		; ---------------------- keeping IntimateCompanionRef even if sleeping
		;  TODO: consider inspecting twin-bed
		; Is a lover nearby and sleeping (or using special bed)? 
		; if so, undress lover
		;IntimateCompanionSet nearCompanion = new IntimateCompanionSet
		;if (IntimateCompanionRef == None)
		;	; is lover already sleeping?
		;	nearCompanion = GetCompanionNearbyHighestRelationRank(false)
		;	if (nearCompanion != None && nearCompanion.CompanionActor != None)
		;		if (nearCompanion.RelationRank >= 3 && nearCompanion.CompanionActor != StrongCompanionRef)
		;			IntimateCompanionRef = nearCompanion.CompanionActor
		;		endIf
		;	endIf
		;endIf
		; ----------------------------------------------------------
		
		; undress companion if in bed or using special anims bed
		SleepBedCompanionUseRef = None	
		bool dogSleeping = false
		
		
		if (SleepBedUsesSpecialAnims)
			moveToBed = false
		else
			; start companion sleep quest?
			if (napOnly > 0 && napComp > 0)
				
				if (IntimateCompanionRef != None && IntimateCompanionRef != StrongCompanionRef)
					
					if (IntimateCompanionRef != None && !IntimateCompanionRef.WornHasKeyword(ArmorTypePower))
					
						if (IntimateCompanionRef.GetSleepState() <= 2)
							
							IntimateCompanionRef.AddToFaction(DTSleep_IntimateFaction)
							Utility.Wait(0.08)
							; start sleep quest
							DTDebug(" start CompSleepQuest for companion not sleeping...", 2)
							DTSleep_CompSleepQuest.Start()
							Utility.Wait(0.24)
						else							
							; is sleeping mark bed
							ObjectReference aBed = DTSleep_CommonF.FindNearestAnyBedFromObject(IntimateCompanionRef, DTSleep_BedList, SleepBedInUseRef, 200.0)
							if (aBed != None)
								
								DTDebug(" companion sleeping, mark nearest known bed " + aBed, 2)
								SleepBedCompanionUseRef = aBed
							endIf
							if (!IntimateCompanionRef.IsInFaction(DTSleep_IntimateFaction))
								IntimateCompanionRef.AddToFaction(DTSleep_IntimateFaction)
							endIf
							DTDebug(" start CompSleepQuest for companion already sleeping...", 2)
							DTSleep_CompSleepQuest.Start()
							if (DTSleep_CompBedRestAlias != None)
								if (SleepBedCompanionUseRef == None)		; v2.35 - check Alias bed
									; did not find bed
									ObjectReference bedFromAliasRef = DTSleep_CompBedRestAlias.GetReference()
									if (bedFromAliasRef != None && (DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).IsObjBed(bedFromAliasRef))
										; is this the right bed?
										if (bedFromAliasRef.IsFurnitureInUse())
											if (DTSleep_CommonF.IsActorOnBed(IntimateCompanionRef, bedFromAliasRef))
												; correct bed - assign
												DTDebug(" companion sleeping, mark alias bed " + aBed, 1)
												SleepBedCompanionUseRef = bedFromAliasRef
												; check list
												Form bedForm = bedFromAliasRef.GetBaseObject()
												if (bedForm != None)
													if (!DTSleep_BedList.HasForm(bedForm))
														; not on our list... add the bed
														DTDebug("adding unknown bed " + bedForm + " to bedList for companion " + IntimateCompanionRef + " sleeping on bed", 1)
														DTSleep_BedList.AddForm(bedForm)
													endIf
												endIf
											endIf
										endIf
									endIf
								else									
									DTSleep_CompBedRestAlias.ForceRefTo(SleepBedCompanionUseRef)
								endIf
							endIf
						endIf
					endIf
				endIf
				
			elseIf (napOnly <= 0 && IntimateCompanionRef != None && IntimateCompanionRef != StrongCompanionRef && !IntimateCompanionRef.WornHasKeyword(ArmorTypePower))
				; check if in bed
				
				; if multiple same beds detected returns fromObj--IntimateCompanionRef
				ObjectReference aBed = DTSleep_CommonF.FindNearestAnyBedFromObject(IntimateCompanionRef, DTSleep_BedList, SleepBedInUseRef, 200.0)
				if (aBed != None && aBed != IntimateCompanionRef)
					if (DTSleep_CommonF.IsActorOnBed(IntimateCompanionRef, aBed))
					
						; appear to be getting into bed or in bed ... okay to get naked!
						SleepBedCompanionUseRef = aBed
						if (!IntimateCompanionRef.IsInFaction(DTSleep_IntimateFaction))
							IntimateCompanionRef.AddToFaction(DTSleep_IntimateFaction)
						endIf
						DTDebug(" start CompSleepQuest for companion already sleeping...", 2)
						DTSleep_CompSleepQuest.Start()
						if (DTSleep_CompBedRestAlias != None)
							DTSleep_CompBedRestAlias.ForceRefTo(SleepBedCompanionUseRef)
						endIf
						
					elseIf (aBed.IsFurnitureInUse())
						; bed not available - cancel undress companion
						IntimateCompanionRef = None
						
					else
						; near bed available - set bed in case companion uses bed such as player commands from bed
						SleepBedCompanionUseRef = aBed
					endIf
					
				elseIf (IntimateCompanionRef.GetSleepState() <= 2)
					; no bed and not sleeping - cancel undress companion
					IntimateCompanionRef = None
				endIf
			endIf
			
			if (napComp > 0 && !DTSleep_CompSleepQuest.IsRunning() && DogmeatCompanionAlias != None && PlayerHasActiveDogmeatCompanion.GetValueInt() >= 1)
		
				; start sleep quest
				DTDebug(" start CompSleepQuest for Dogmeat...", 2)
				
				DTSleep_CompSleepQuest.Start()
				Utility.Wait(0.24)
			endIf
			
			; does companion need to go to bed?
			;
			if (napOnly && napComp > 0 && IntimateCompanionRef != None && IntimateCompanionRef != StrongCompanionRef && !IntimateCompanionRef.WornHasKeyword(ArmorTypePower) && DTSleep_CompSleepQuest.IsRunning() && SleepBedCompanionUseRef == None)
				
				; find a bed for companion
				if (DTSleep_CompSleepAlias != None)
					DTDebug("find bed for companion " + IntimateCompanionRef, 2)
					IntimateBedFoundSet aBedFound = FindBedForCompanion(IntimateCompanionRef, SleepBedInUseRef)
					ObjectReference aBedRef = aBedFound.BedFoundRef
					
					bool bedFound = true
					bool bedClaimed = false
	
					if (aBedRef == None || aBedRef == SleepBedInUseRef)
						bedFound = false
						aBedRef = None
						DTSleep_CompBedRestAlias.Clear()
						
					elseIf (aBedRef.HasActorRefOwner())
						
						if (!aBedRef.IsOwnedBy(IntimateCompanionRef))
							DTDebug("bed (" + aBedRef + ") has owner (" + aBedRef.GetActorRefOwner() + ") and no other bed found", 2)
							aBedRef = None
							bedClaimed = true
						endIf
					endIf
					
					if (IntimateCompanionRef != DTSleep_CompSleepAlias.GetActorReference())
						DTDebug(" somehow incorrect CompSleepAlias  -- forcing", 2)
						
						DTSleep_CompSleepAlias.ForceRefTo(IntimateCompanionRef)
					endIf
					
					if (aBedRef != None)
						DTDebug(" setting aBedRef to SleepBedCompanionBed: " + aBedRef, 2)
						SleepBedCompanionUseRef = aBedRef
						
						if (!dogSleeping && DTSleep_SettingDogRestrain.GetValue() >= 0.0 && DogmeatCompanionAlias != None)
							; ensure dog stays out of way
							SetDogmeatFollow()
						endIf
						
						IntimateCompanionRef.EvaluatePackage(true)
						Utility.Wait(0.1)
						
						; ---------
						; find another lover a bed -- undress 2nd companion
						;
						if (DTSleep_SettingLover2.GetValue() > 0.0)
							; get nearest humans and check if on DTSleep_CompanionRomanceList or custom companion
							DTDebug(" looking for 2nd companion for bed-time ", 2)
							if (afterIntimacy && DTSleep_PlayerUndressed.GetValue() > 0.0 && IntimateCompanionSecRef == None)
								; v2.35 expected since we clear IntimateQuest
								IntimateCompanionSecRef = (DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).CompanionSecondRef
							endIf
							if (IntimateCompanionSecRef == None)
								; v2.14 - changed to handle after intimacy so we don't break existing undressed companion
								;  find then clear if not needed
								DTDebug("no IntimateCompanionSecRef... searching...", 2)
								IntimateCompanionSet[] nearbyCompsArray = GetCompanionNearbyLoversArray(3, IntimateCompanionRef)
							
								if (nearbyCompsArray.Length > 0 && nearbyCompsArray[0].CompanionActor != IntimateCompanionRef)
								
									IntimateCompanionSecRef = nearbyCompsArray[0].CompanionActor
								endIf
							endIf
							
							if (IntimateCompanionSecRef != None)
							
								IntimateBedFoundSet anotherBedFound = FindBedForCompanion(IntimateCompanionSecRef, IntimateCompanionSecRef as ObjectReference, SleepBedCompanionUseRef, SleepBedInUseRef)
								if (anotherBedFound != None && anotherBedFound.BedFoundRef != None)
									
									if (anotherBedFound.BedFoundRef != SleepBedInUseRef && anotherBedFound.BedFoundRef != SleepBedCompanionUseRef)
									
										DTSleep_CompSecondSleepAlias.ForceRefTo(IntimateCompanionSecRef)
										Utility.Wait(0.1)
										
										IntimateCompanionSecRef.EvaluatePackage(true)
										
										(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).CompanionSecondRef = IntimateCompanionSecRef
									else
										DTDebug(" cancel 2nd lover goto-bed---2nd bed (" + anotherBedFound.BedFoundRef + ")already occupied: " + SleepBedInUseRef + ", " + SleepBedCompanionUseRef, 2)
										DTSleep_CompBedSecondRefAlias.Clear()
										DTSleep_CompSecondSleepAlias.Clear()
										IntimateCompanionSecRef = None
										(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).CompanionSecondRef = None
									endIf
									
								elseIf (DTSleep_CompSecondSleepAlias != None)
									DTSleep_CompBedSecondRefAlias.Clear()
									DTSleep_CompSecondSleepAlias.Clear()
									IntimateCompanionSecRef = None
									(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).CompanionSecondRef = None
								endIf
	
							elseIf (DTSleep_CompSecondSleepAlias != None)
								DTSleep_CompBedSecondRefAlias.Clear()
								DTSleep_CompSecondSleepAlias.Clear()
							endIf
						endIf
						
					else
						; no bed found
						if (bedClaimed)
							self.MessageOnRestID = OnRestMsgCompBedClaimed
						elseIf (bedFound)
							self.MessageOnRestID = OnRestMsgCompBedBusy
						elseIf (aBedFound.BugDetected)
							self.MessageOnRestID = OnRestMsgCompBedBuggy
						else
							self.MessageOnRestID = OnRestMsgCompBedNotFound
						endIf
						
						; no bed, no undress
						; note: if undressed afterIntimacy will stay undressed and walk around --- will equip weapon
						;
						if (IntimateCompanionRef.IsInFaction(DTSleep_IntimateFaction))
							IntimateCompanionRef.RemoveFromFaction(DTSleep_IntimateFaction)
						endIf
						IntimateCompanionRef.EvaluatePackage(false)
						IntimateCompanionRef = None
					endIf
				else
					; should not happen 
					DTDebug(" no CompanionSleep Alias - no sleep or undress ", 1)
					self.MessageOnRestID = OnRestMsgCompBedNotFound
					; no bed, no undress
					if (IntimateCompanionRef != None)
						if (IntimateCompanionRef.IsInFaction(DTSleep_IntimateFaction))
							IntimateCompanionRef.RemoveFromFaction(DTSleep_IntimateFaction)
						endIf
						IntimateCompanionRef.EvaluatePackage(false)
					endIf
					IntimateCompanionRef = None
					IntimateCompanionSecRef = None
					
				endIf
			elseIf (SleepBedCompanionUseRef == None && IntimateCompanionRef != None)
				; cancel companion undress since not going to bed
				if (IntimateCompanionRef.IsInFaction(DTSleep_IntimateFaction))
					IntimateCompanionRef.RemoveFromFaction(DTSleep_IntimateFaction)
				endIf
				IntimateCompanionRef.EvaluatePackage(false)
				IntimateCompanionRef = None
				IntimateCompanionSecRef = None			; should already be cleared
			endIf
			
			; check Dogmeat
			if (napComp > 0 && DTSleep_CompSleepQuest.IsRunning() && PlayerHasActiveDogmeatCompanion.GetValueInt() >= 1 && DTSleep_DogSleepAlias != None)
				bool dogSleepFound = false
				
				if (DTSleep_SettingDogRestrain.GetValue() >= 0.0 && DogmeatSetWait)
					SetDogmeatFollow()
				endIf
				if (DTSleep_CompDogBedRefAlias != None)
					Actor dogActor = DTSleep_DogSleepAlias.GetActorReference()
					ObjectReference dogBedRef = DTSleep_CompDogBedRefAlias.GetReference()
					if (dogActor != None && dogBedRef != None)
					
						if (dogActor.GetSleepState() > 2)
							dogSleeping = true
							;DTSleep_CompDogBedRefAlias.Clear()
							dogSleepFound = true
							
						elseIf (dogBedRef.GetDistance(dogActor) > 3000.0 || dogBedRef.IsFurnitureInUse())
						
							; the alias closest-to Ref in loaded area sometimes finds doghouse farther away than another
							
							ObjectReference dogSleepNearRef = DTSleep_CommonF.FindNearestObjHaveKeywordFromObject(PlayerRef, DTSleep_DogSleepKWList, 3200.0)
							if (dogSleepNearRef != None)
								DTSleep_CompDogBedRefAlias.ForceRefTo(dogSleepNearRef)
								dogSleeping = true
								;DTDebug("send Dogmeat to near bed at " + dogSleepNearRef, 2)
								dogActor.EvaluatePackage(false)
								dogSleepFound = true
							else
								; too far
								DTSleep_CompDogBedRefAlias.Clear()
								;DTDebug("Dogmeat bed too far " + dogBedRef, 2)
							endIf
						else
							dogSleeping = true
							;DTDebug("send Dogmeat to bed at " + dogBedRef, 2)
							dogActor.EvaluatePackage(false)
							dogSleepFound = true
						endIf
					else
						DTSleep_CompDogBedRefAlias.Clear()
					endIf
				endIf
				if (!dogSleepFound)
					if (akBed.HasKeyword(AnimFurnFloorBedAnims))
						float distance = 6.0
						float offsetX = 0.0
						int angle = Utility.RandomInt(85, 94)
						if ((DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).IsSleepingBag(akBed))
							distance = 12.9
							offsetX = 4.8
						endIf
						offsetX += Utility.RandomInt(-1, 6)	;jitter
						SleepBedDogPlacedRef = DTSleep_CommonF.PlaceFormAtFootOfBedRef(DogmeatLay01Marker, akBed, distance, offsetX, angle as float)
						
					else
						Actor dogActor = DTSleep_DogSleepAlias.GetActorReference()
						if (dogActor != None)
							if (dogActor.GetDistance(PlayerRef) < 800.0)
								; make sure dog is not on player or companion bed
								if (SleepBedInUseRef != None && !DTSleep_CommonF.IsActorOnBed(dogActor, SleepBedInUseRef))
									if (SleepBedCompanionUseRef == None)
										SleepBedDogPlacedRef = DTSleep_CommonF.PlaceFormAtObjectRef(DogmeatLay01Marker, dogActor)
									elseIf (!DTSleep_CommonF.IsActorOnBed(dogActor, SleepBedCompanionUseRef))
										SleepBedDogPlacedRef = DTSleep_CommonF.PlaceFormAtObjectRef(DogmeatLay01Marker, dogActor)
									endIf
								else
									DTDebug("Dogmeat on player's bed ", 2)
								endIf
							endIf
						endIf
					endIf
					if (SleepBedDogPlacedRef != None)
						
						DTSleep_CompDogBedRefAlias.ForceRefTo(SleepBedDogPlacedRef)
					else
						DTSleep_DogSleepAlias.Clear()
					endIf
				endIf
			elseIf (DTSleep_CompDogBedRefAlias != None)
				DTSleep_CompDogBedRefAlias.Clear()
			endIf      ; end check Dogmeat sleep
		
		endIf
		
		if (!DTSleep_HealthRecoverQuestP.IsRunning())
			DTSleep_HealthRecoverQuestP.Start()
		endIf
		
		RegisterForCustomEvent((DTSleep_HealthRecoverQuestP as DTSleep_HealthRecoverQuestScript), "RestInterruptionEvent")
		
		if (SleepBedInUseRef != None)
		
			if (IntimateLastTime > 0.0)
				; v2.33 - bonus for recent intimacy
				float timeSinceLast = DTSleep_CommonF.GetGameTimeHoursDifference(IntimateLastTime, Utility.GetCurrentGameTime())
				if (timeSinceLast < 2.00)
					(DTSleep_HealthRecoverQuestP as DTSleep_HealthRecoverQuestScript).SleepTimeIntimacyCount = 1
				endIf
			endIf
		
			if (SleepBedInUseRef.HasKeyword(AnimFurnFloorBedAnims))
				if (SleepBedUsesSpecialAnims || SleepBedUsesBlock)
					(DTSleep_HealthRecoverQuestP as DTSleep_HealthRecoverQuestScript).SetBedTypeCamping()
					(DTSleep_HealthRecoverQuestP as DTSleep_HealthRecoverQuestScript).HoursOversleep = 5
				else
					if (SleepBedInUseRef.HasKeyword(HC_Obj_SleepingBagKY))
						(DTSleep_HealthRecoverQuestP as DTSleep_HealthRecoverQuestScript).SetBedTypeSleepingBag()
						(DTSleep_HealthRecoverQuestP as DTSleep_HealthRecoverQuestScript).HoursOversleep = 5
					else
						(DTSleep_HealthRecoverQuestP as DTSleep_HealthRecoverQuestScript).SetBedTypeMattress()
						(DTSleep_HealthRecoverQuestP as DTSleep_HealthRecoverQuestScript).HoursOversleep = 5
					endIf
					
				endIf
			elseIf (SleepBedInUseRef.HasKeyword((DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).AnimFurnLayDownUtilityBoxKY))
				
				(DTSleep_HealthRecoverQuestP as DTSleep_HealthRecoverQuestScript).SetBedTypeOwn()
				(DTSleep_HealthRecoverQuestP as DTSleep_HealthRecoverQuestScript).HoursOversleep = 7
				
			elseIf (IsBedOwnedByPlayer(SleepBedInUseRef, IntimateCompanionRef))
				(DTSleep_HealthRecoverQuestP as DTSleep_HealthRecoverQuestScript).SetBedTypeOwn()
				if (SleepBedInUseRef.HasKeyword(DTSleep_OutfitContainerKY)) 
					(DTSleep_HealthRecoverQuestP as DTSleep_HealthRecoverQuestScript).HoursOversleep = 8
				elseIf (DTSleep_BedsBigDoubleList.HasForm(SleepBedInUseRef.GetBaseObject()))
					(DTSleep_HealthRecoverQuestP as DTSleep_HealthRecoverQuestScript).HoursOversleep = 8
				else
					(DTSleep_HealthRecoverQuestP as DTSleep_HealthRecoverQuestScript).HoursOversleep = 7
				endIf
			else
				(DTSleep_HealthRecoverQuestP as DTSleep_HealthRecoverQuestScript).SetBedTypeFull()
				(DTSleep_HealthRecoverQuestP as DTSleep_HealthRecoverQuestScript).HoursOversleep = 7
			endIf
		endIf
		
		if (SleepBedInUseRef != None)
			UnregisterForMenuOpenCloseEvent("WorkshopMenu")
			SetPlayerAndCompanionBedTime(SleepBedInUseRef, SleepBedCompanionUseRef, false, observeWinter, isFadedOut, moveToBed, playerNaked)
		else
			DTDebug("HandlePlayerSleepStop -- SleepBedInUseRef is None - skip Set bedtime", 1)
			DTSleep_PlayerUsingBed.SetValue(0.0)
			UnregisterForCustomEvent((DTSleep_HealthRecoverQuestP as DTSleep_HealthRecoverQuestScript), "RestInterruptionEvent")
		endIf
	endIf
	
	return
EndFunction

; for bed or stand-alone - do not use with outfit container
;
Function HandleUndressCheck(Actor companionActor = None, bool companionRequiresNudeSuit = true)

	if (DTSleep_PlayerUndressed.GetValue() <= 0.0)
	
		bool includeClothing = true
	
		if (PlayerRef.GetAnimationVariableBool("IsFirstPerson"))
			DTSleep_WasPlayerThirdPerson.SetValue(-1.0)
		else
			DTSleep_WasPlayerThirdPerson.SetValue(1.0)
		endIf
		if (DTSleep_VR.GetValueInt() < 3)
			Game.ForceThirdPerson()
			Utility.Wait(0.5)
		endIf
		EnablePlayerControlsSleep()
		Utility.Wait(0.1)
		SetUndressForCheck(includeClothing, companionActor, companionRequiresNudeSuit)

	else
		
		DTSleep_CaptureExtraPartsEnable.SetValue(0.0)
		
		if (DTSleep_VR.GetValueInt() < 3)
			Game.ForceThirdPerson()
			Utility.Wait(0.1)
		endIf
		
		SetUndressStop(false)
		
		Utility.Wait(0.76)
		
		if (DTSleep_WasPlayerThirdPerson.GetValue() < 0.0)
			Game.ForceFirstPerson()
		endIf
		
		EnablePlayerControlsSleep()
	endIf
endFunction

Function InitSleepQuest(bool silent = false)
	
	DTSleep_SettingModActive.SetValue(1.0)
	
	Location currentLoc = PlayerRef.GetCurrentLocation()
	if (currentLoc != Vault111Loc)
		; no rest in vault
		PlayerSleepPerkAdd()
	endIf
	
	if (MQ102.GetStageDone(10))
		(DTSConditionals as DTSleep_Conditionals).HasReloaded = true
	endIf
	
	Debug.Trace(myScriptName + " InitSleepQuest")
	
	DTSleep_SettingIntimate.SetValue(1.0)
	DTSleep_SettingUndress.SetValue(1.0)
	DTSleep_SettingModActive.SetValue(2.0)
	DTSleep_SettingModMCMCtl.SetValue(1.0)
	RegisterForMenuOpenCloseEvent("WorkshopMenu")

	LastRadDamTime = -1.0
	
	float pickPromptVal = DTSleep_SettingShowIntimateCheck.GetValue()
	if (pickPromptVal > 0.0 && DTSleep_AdultContentOn.GetValue() >= 2.0)
		DTSleep_SettingShowIntimateCheck.SetValue(2.0)
	endIf
	
	(SleepPlayerAlias as DTSleep_PlayerAliasScript).StartUp()
	
	if ((SleepPlayerAlias as DTSleep_PlayerAliasScript).CheckGameSettings())
		StartTimer(4.0, CheckCustomArmorsTimerID)
		StartTimer(64.0, CustomCameraTipTimerID)
		StartTimer(200.0, IntroRestNotShowTipTimerID)
		
		float adultOn = DTSleep_AdultContentOn.GetValue()
		
		if (!silent)
			if (DTSleep_VR.GetValueInt() == 3)
				DTSleep_StartedVR2Message.Show()					;v3.0
			elseIf (IsAdultAnimationAvailable())
				DTSleep_StartedExplicitMessage.Show()
			elseIf (adultOn >= 1.0 && adultOn <= 1.50)
				DTSleep_StartedSafeMessage.Show()
			else
				DTSleep_StartedMessage.Show()
			endIf
		endIf
		
		; process whatever StartUp found
		ProcessCompatibleMods()
		
		; v2.60
		SetRestRedressDefault()
	else
		; uh-oh something went wrong
		Game.QuitToMainMenu()
	endIf
EndFunction

;
; sets SceneData.AnimationSet and returns if should do stand-only scene
; all of SceneData should be set first
; v3 stylePicked now includes cancel at 0
;
int[] Function IntimateAnimPacksPick(bool adultScenesAvailable, bool powerArmorFlag, int playerSex, ObjectReference furnObjRef, Form baseBedForm, bool hasTwinBed = false, int stylePicked = -1)

	; SceneData.AnimationSet: 5+ for AAF, 
	;   1 = original Leito (positioned 70 apart)
	;   2 = Crazy Gun
	;   4 = CHAK cuddls/hug/kiss
	;   5 = Atomic Lust & Mutated Lust
	;   6 = Leito v2
	;   7 = SavageCabbages
	;	8 = ZaZOut4
	;   9 = AAF_GrayAnimations & AAF_CreaturePack
	;  10 = BP70
	
	; v2.26 - ignore powerArmorFlag here --- later before scene start will disable AnimQuestScript.PlayAAFEnabled
	powerArmorFlag = false 

	bool aafEnabled = IsAAFReady()
	bool hasAtomicLustAnims = false
	bool hasCrazyGunAnims = false
	bool hasLeitoAnims = false
	bool hasSavageCabbageAnims = false
	bool hasGrayAnims = false
	bool hasLeitoV2Anims = false	; compatible with AAF, but cannot have old X_Anims patch due to shared file locations
	bool hasBP70Anims = false
	bool hasCHAKAnims = false		; only for bed and table
	int animSetCount = 0
	int animSetFailCount = 0
	int multiLoverGender = -1
	bool limitedSpace = false
	int[] animSets = new int[0]
	
	;init to nothing, but high to pass checks -- set to -100 for have packs, but none for this situation
	SceneData.AnimationSet = 100  		;
	SceneData.PreferStandOnly = false  	; reset
	
	if ((DTSConditionals as DTSleep_Conditionals).ImaPCMod)
		if (!Debug.GetPlatformName() as bool)
			(DTSConditionals as DTSleep_Conditionals).ImaPCMod = false
			SceneData.AnimationSet = 0
			return animSets
		endIf
	endIf
	
	if (baseBedForm != None)
		limitedSpace = DTSleep_BedsLimitedSpaceLst.HasForm(baseBedForm)
		DTDebug("IntimateAnimsPick seting bed has limited space for bed " + baseBedForm, 2)
	endIf
	
	if (adultScenesAvailable)
	
		DTDebug("IntimateAnimPacksPick powerArmorFlag?" + powerArmorFlag + " inPowerArmor? " + SceneData.CompanionInPowerArmor + " stylePicked? " + stylePicked, 2)
		
		if (SceneData.CompanionInPowerArmor || SceneData.IsCreatureType == CreatureTypeSynth)	; v2.17 - added synth condition
			; intended for Danse in power armor or synth
			
			if ((DTSConditionals as DTSleep_Conditionals).IsAtomicLustActive)		; not AAF
				hasAtomicLustAnims = true
				animSetCount += 1
			endIf
				
			if (playerSex == 1 && (DTSConditionals as DTSleep_Conditionals).IsSavageCabbageActive && baseBedForm != None && DTSleep_BedsBigDoubleList.HasForm(baseBedForm))
				; solo for Danse in PA limited to scene
				hasSavageCabbageAnims = true
				animSetCount += 1
			endIf
			if ((DTSConditionals as DTSleep_Conditionals).IsGrayAnimsActive)
				hasGrayAnims = true
				animSetCount += 1
			endIf
			
			; does not work??
			;if ((DTSConditionals as DTSleep_Conditionals).IsCrazyAnimGunActive)
			;	hasCrazyGunAnims = true
			;	animSetCount += 1
			;endIf
		else
			; no power armor
			if ((DTSConditionals as DTSleep_Conditionals).IsCHAKPackActive)    ; v3.0
				; TODO: limit to choosing cuddles only?
				if (stylePicked == 2 || stylepicked <= 0)
					if ((DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).IsObjBed(furnObjRef))
						; must be a bed or table
						hasCHAKAnims = true  
						animSetCount += 1
					elseIf (baseBedForm != None && (DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).IsObjTable(furnObjRef, baseBedForm))
						; must be a bed or table
						hasCHAKAnims = true  
						animSetCount += 1
					endIf
				endIf
			endIf
			
			if ((DTSConditionals as DTSleep_Conditionals).IsLeitoActive && DTSleep_IsLeitoActive.GetValue() >= 1.0)
			
				if ((DTSConditionals as DTSleep_Conditionals).IsLeitoAAFActive == false)
					hasLeitoAnims = true
					animSetCount += 1
					
				elseIf (DTSleep_IsLeitoActive.GetValueInt() >= 4)
					; new X_Anims patch moved files so okay to have new Leito plugin
					hasLeitoAnims = true
					animSetCount += 1
				else
					animSetFailCount += 1
				endIf
			endIf
			if ((DTSConditionals as DTSleep_Conditionals).IsCrazyAnimGunActive)
				hasCrazyGunAnims = true
				animSetCount += 1
			endIf

			if ((DTSConditionals as DTSleep_Conditionals).IsBP70Active)
				hasBP70Anims = true
				animSetCount += 1
			endIf

		
			; AAF fails if power armor bug - restrict by powerArmorFlag
			
			if ((DTSConditionals as DTSleep_Conditionals).IsLeitoAAFActive)
				if (aafEnabled && powerArmorFlag && DTSleep_IsLeitoActive.GetValueInt() <= 2)
					animSetFailCount += 1
				else
					if ((DTSConditionals as DTSleep_Conditionals).IsLeitoActive)
						; old loose files clash with new - must have new X_Anims patch
						if (aafEnabled)
							hasLeitoV2Anims = true
							animSetCount += 1
						elseIf (DTSleep_IsLeitoActive.GetValueInt() < 4 || (SleepPlayerAlias as DTSleep_PlayerAliasScript).DTSleep_SIXPatch.GetValueInt() < 4)  ; v2.40a had:  || aafEnabled || (SleepPlayerAlias as DTSleep_PlayerAliasScript).DTSleep_SIXPatch.GetValueInt() <= 0)
							; not allowed
							hasLeitoV2Anims = false
							hasLeitoAnims = false
						endIf
					else
						hasLeitoV2Anims = true
						animSetCount += 1
					endIf
				endIf
			endIf
			
			if ((DTSConditionals as DTSleep_Conditionals).IsAtomicLustActive)
				if (powerArmorFlag && aafEnabled)
					animSetFailCount += 1
				else
					hasAtomicLustAnims = true
					animSetCount += 1
				endIf
			elseIf ((DTSConditionals as DTSleep_Conditionals).IsRufgtActive)
				hasAtomicLustAnims = true
				animSetCount += 1
			endIf
			
			; savageCabbage scenes favor female player
			if (playerSex == 1 || (!hasLeitoAnims && !hasLeitoV2Anims) || SceneData.CurrentLoverScenCount > 5 || Utility.RandomInt(1,5) > 2)		; v2.60 increase male chance by 1, v2.86-added lover-count condition
				if ((DTSConditionals as DTSleep_Conditionals).IsSavageCabbageActive && !limitedSpace)
					if (SceneData.SameGender == false || SceneData.MaleRoleGender == 1)
						if (aafEnabled && powerArmorFlag)
							animSetFailCount += 1
						else
							hasSavageCabbageAnims = true
							animSetCount += 1
							if (playerSex == 1)
								multiLoverGender = 0
								
							endIf
						endIf
					endIf
				endIf
			endIf
			
			if ((DTSConditionals as DTSleep_Conditionals).IsGrayAnimsActive)
				if (aafEnabled && powerArmorFlag)
					animSetFailCount += 1
				else
					hasGrayAnims = true
					animSetCount += 1
				endIf
			endIf
		endIf
		
	endIf  ; ------------------ done found packs 
	
	
	if (adultScenesAvailable)
	
		if ((DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).IsObjPoolTable(furnObjRef, baseBedForm) || furnObjRef.HasKeyword((DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).AnimFurnPicnickTableKY))
			; Pool Table or picnic table
			bool getMore = true
			bool getSC = true
			if (DressData.PlayerGender == 0 && (hasLeitoAnims || hasLeitoV2Anims) && Utility.RandomInt(5, 15) < 12)
				getSC = false		; favor female player character
			endIf
			
			if (hasSavageCabbageAnims && !SceneData.SameGender && getSC)
				animSets.Add(7)
				; v2.53 - picnic table always needs to include Leito for oral/manual choice
				if (!furnObjRef.HasKeyword((DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).AnimFurnPicnickTableKY) && Utility.RandomInt(2,9) > 4)
					getMore = false
				endIf
			endIf
			if (getMore)
				if (!SceneData.SameGender || (playerSex == 1 && SceneData.HasToyAvailable))
					if (hasLeitoAnims)
						animSets.Add(1)
					elseIf (hasLeitoV2Anims)
						animSets.Add(6)
					endIf
				endIf
				if (hasAtomicLustAnims)
					animSets.Add(5)
				endIf
				if (hasBP70Anims)
					animSets.Add(10)
				endIf
			endIf
			
		elseIf (furnObjRef != None && (DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).IsObjDinerBoothTable(furnObjRef, baseBedForm))
			; diner booth table
			if (hasSavageCabbageAnims && !SceneData.SameGender)
				animSets.Add(7)
			endif
			
		elseIf (IntimateCompanionRef == StrongCompanionRef)
		
			SceneData.PreferStandOnly = true
			
			if (baseBedForm != None)
				if (hasSavageCabbageAnims)
					
					if (baseBedForm.HasKeyword(AnimFurnFloorBedAnims))
						animSets.Add(7)
						SceneData.PreferStandOnly = false
					elseIf (DTSleep_BedsBigDoubleList.HasForm(baseBedForm))
						animSets.Add(7)
						SceneData.PreferStandOnly = false
					endIf
				endIf
				if (baseBedForm.HasKeyword(AnimFurnFloorBedAnims))
					if (hasLeitoAnims)
						animSets.Add(1)
					elseIf (hasLeitoV2Anims)
						animSets.Add(6)
					endIf
				endIf
			endIf
			
			if ((DTSConditionals as DTSleep_Conditionals).IsMutatedLustActive)
				animSetCount += 1
				animSets.Add(5)
			endIf
			if ((DTSConditionals as DTSleep_Conditionals).IsGrayCreatureActive)
				animSetCount += 1
				animSets.Add(9)
			endIf
			
			
			if (animSetCount == 0)
				SceneData.AnimationSet = 0
			endIf
		elseIf (IntimateCompanionRef.HasKeyword(ActorTypeSuperMutantBehemothKY))
			SceneData.PreferStandOnly = true
			if (hasSavageCabbageAnims && !SceneData.SameGender)
				animSets.Add(7)
			endIf
		
		elseIf (IntimateCompanionRef.HasKeyword(ActorTypeRobotKY))
			SceneData.PreferStandOnly = true
			if (hasSavageCabbageAnims && !SceneData.SameGender)
				animSets.Add(7)
			endIf
			
		;elseIf (SceneData.IsUsingCreature && baseBedForm.HasKeyword(AnimFurnFloorBedAnims))
		;	if (hasLeitoAnims)
		;		SceneData.PreferStandOnly = true
		;		animSets.Add(1)
		;	endIf
		;	if (hasSavageCabbageAnims && !aafEnabled)
		;		animSets.Add(7)
		;	endIf
			
		elseIf (SceneData.SameGender && playerSex == 1 && SceneData.HasToyAvailable == false)
			; also supports 2nd lover if before swapping roles
			DTDebug(" IntimateAnimPacksPick - FF-noToy ", 2)
			if (hasAtomicLustAnims)
				animSets.Add(5)
			endIf
			if (hasSavageCabbageAnims)			; include for dance
				animSets.Add(7)
			endIf
			if (hasGrayAnims)
				animSets.Add(9)
			endIf
			if (hasCHAKAnims)					; v3.0
				animSets.Add(4)
			endIf
			if (hasBP70Anims)				
				animSets.Add(10)
			endIf
			
		elseIf (playerSex == 0 && SceneData.SameGender)
		
			if (hasLeitoAnims)
				animSets.Add(0)
			elseIf (hasLeitoV2Anims)
				animSets.Add(6)
			endIf
			
			if (SceneData.SecondFemaleRole != None)		; if before swapping roles
				if (hasSavageCabbageAnims)
					animSets.Add(7)
				endIf
			endIf
			
			if (hasCHAKAnims)					; v3.0
				animSets.Add(4)
			endIf
			
			if (hasGrayAnims)
				animSets.Add(9)
			endIf
			
			if (hasBP70Anims)	
				animSets.Add(10)
			endIf
			
			if (hasAtomicLustAnims)

				if ((DTSConditionals as DTSleep_Conditionals).AtomicLustVers >= 2.43)
					animSets.Add(5)
				endIf
				
			elseIf (hasCrazyGunAnims)
				if (animSets.Length == 0)
					SceneData.AnimationSet = 2
				endIf
				SceneData.PreferStandOnly = true
				animSets.Add(SceneData.AnimationSet)
				
			elseIf (animSets.Length == 0)
				SceneData.AnimationSet = 0
			endIf
		
		else
			; set bed restriction
			if (playerSex == 1 && SceneData.MaleRole == PlayerRef && limitedSpace)
				SceneData.PreferStandOnly = true
				
			elseIf (limitedSpace && Utility.RandomInt(0, 3) > 0)
				; prefer stand for small bed
				SceneData.PreferStandOnly = true
			endIf

			if (animSetCount > 0)
				animSets = new int[animSetCount]
				
				int index = 0
				if (hasAtomicLustAnims)
					animSets[index] = 5
					index += 1
				endIf
				
				if (hasCHAKAnims)					; v3.0
					animSets[index] = 4
					index += 1
				endIf
				
				if (hasCrazyGunAnims)
					animSets[index] = 2
					index += 1
				endIf
				
				bool getLeito = true				; v2.60 - female favor SC so limit Leito
				if (hasSavageCabbageAnims)			
					animSets[index] = 7
					index += 1
					; v2.64 - fix added no-same-gender restriction
					if (stylePicked <= 0 && !SceneData.SameGender && playerSex == 1 && !limitedSpace && !furnObjRef.HasKeyword(AnimFurnFloorBedAnims))
						if (Utility.RandomInt(10, 26) > 15)
							getLeito = false
						endIf
					endIf
				endIf
				
				if (getLeito)
					if (hasLeitoAnims)
						animSets[index] = 1
						index += 1
					endIf
					if (hasLeitoV2Anims)
						animSets[index] = 6
						index += 1
					endIf
				endIf
				
				if (hasGrayAnims)
					animSets[index] = 9
					index += 1
				endIf
				
				if (hasBP70Anims)				
					animSets[index] = 10
					index += 1
				endIf
			else
				SceneData.AnimationSet = 0
			endIf
		endIf
		
	elseIf (SceneData.IsUsingCreature == false)
		; no-adult 
		if (animSetCount > 0)
			animSets = new int[animSetCount]
			
			; currently only the one
			int index = 0
			if (hasAtomicLustAnims)
				animSets[index] = 5
				index += 1
				SceneData.AnimationSet = 5
			else
				animSets[index] = 0
				SceneData.AnimationSet = 0
			endIf
		else
			SceneData.AnimationSet = 0
		endIf
	endIf
	
	if (stylePicked > 0 && stylePicked <= 2 && !hasAtomicLustAnims && !hasCHAKAnims)		; v3.0 - include CHAK 	
		; cuddle or let companion pick
		animSets.Add(0)
	endIf
	
	if (SceneData.AnimationSet != 0 && animSets.Length > 0)
		SceneData.AnimationSet = 100  ; let IntimateAnimQuest pick
	elseIf (animSetFailCount > 0 && animSets.Length == 0)
		SceneData.AnimationSet = -100
		if (powerArmorFlag)
			SceneData.AnimationSet = -101
		endIf
		DTDebug("Animation pack check: have packs, but none for this situation bed: " + baseBedForm + ", playerSex: " + playerSex + " companion powerArmorFlag: " + powerArmorFlag, 1)
	endIf
	
	return animSets
endFunction

bool Function IsAAFReady()
	
	if (DTSleep_VR.GetValueInt() <= 1 && DTSleep_SettingAAF.GetValue() > 0.0 && (DTSConditionals as DTSleep_Conditionals).IsF4SE)
		if ((DTSConditionals as DTSleep_Conditionals).IsAAFActive)
			return true
		endIf
	endIf

	return false
endFunction

bool Function IsAAFInstalled()
	if ((DTSConditionals as DTSleep_Conditionals).IsF4SE)
		if ((DTSConditionals as DTSleep_Conditionals).IsAAFActive)
			return true
		endIf
	endIf
	return false

endFunction

bool Function IsAdultAnimationAvailable(int gender = -1)


	; v2.35 updated for solo scenes by gender
	if (DTSleep_SettingModActive.GetValue() >= 2.0 && DTSleep_AdultContentOn.GetValue() >= 2.0 && (DTSConditionals as DTSleep_Conditionals).ImaPCMod && TestVersion == -2)
	
		float leitoVal = DTSleep_IsLeitoActive.GetValue()
		if (gender != 0 && leitoVal >= 1.0 && leitoVal <= 4.0)
			if ((DTSConditionals as DTSleep_Conditionals).IsLeitoActive || (DTSConditionals as DTSleep_Conditionals).IsLeitoAAFActive)
				return true
			endIf
		endIf
		if ((DTSConditionals as DTSleep_Conditionals).IsBP70Active)				
			return true
		endIf
		
		if ((DTSConditionals as DTSleep_Conditionals).IsCrazyAnimGunActive)
			return true
		
		elseIf ((DTSConditionals as DTSleep_Conditionals).IsAtomicLustActive)
			return true
	
		elseIf (gender != 0 && (DTSConditionals as DTSleep_Conditionals).IsLeitoAAFActive && leitoVal > 0.0 && leitoVal <= 4.0)
			return true
		elseIf ((DTSConditionals as DTSleep_Conditionals).IsSavageCabbageActive)
			return true
		elseIf (gender < 0 && (SleepPlayerAlias as DTSleep_PlayerAliasScript).DTSleep_IsZaZOut.GetValue() >= 1.0)
			return true
		elseIf ((DTSConditionals as DTSleep_Conditionals).IsGrayAnimsActive)
			return true
		elseIf (gender < 0 && (DTSConditionals as DTSleep_Conditionals).IsRufgtActive)
			return true
		endIf
	endIf
	
	return false
endFunction

; v2.73 - may have multiple animation packs with chair animations
bool Function IsAdultAnimationChairAvailable()
	if ((DTSConditionals as DTSleep_Conditionals).IsSavageCabbageActive)
		return true
	endif
	if ((DTSConditionals as DTSleep_Conditionals).IsBP70Active)			
		return true
	endIf
	if ((DTSConditionals as DTSleep_Conditionals).IsLeitoAAFActive)
		float leitoVal = DTSleep_IsLeitoActive.GetValue()
		if (leitoVal >= 2.10 && leitoVal <= 2.9 && (DTSConditionals as DTSleep_Conditionals).LeitoAnimVers >= 2.10)
			return true
		endIf
	endIf
	; not counting Atomic Lust on its own since very limited
	
	return false
endFunction


bool Function IsEmbraceAnimationPacksAvailable()			; v3.0

	if ((DTSConditionals as DTSleep_Conditionals).IsCHAKPackActive)
		return true
	endIf
	
	; do not include Raide My Heart since only a single animation
	
	return false
endFunction

bool Function IsEmraceChairAnimationsAvailable()			; v3.0
	
	if ((DTSConditionals as DTSleep_Conditionals).IsCHAKPackActive)
		return true
	endIf
	; not counting RaidMyHeart since only a single
	
	return false
endFunction

bool Function IsBedDogCompatible(ObjectReference bedRef, bool isSpecialAnimBed = false)
	if (bedRef != None)
		if (bedRef.HasKeyword(AnimFurnFloorBedAnims))
			return true
		elseIf (isSpecialAnimBed)
			return true
		endIf
	endIf

	return false
endFunction

; no longer used
;bool Function IsCompanionMultiLoveCompatible(Actor companionActor, ActorBase compBase = None, bool checkRace = true)
;
;	if ((DTSleep_IntimateAffinityQuest as DTSleep_IntimateAffinityQuestScript).CompanionHatesIntimateOtherPublic(companionActor))
;		return false
;		
;	elseIf (checkRace)
;		return IsCompanionRaceCompatible(companionActor, compBase, false)
;	endIf
;	
;	return true
;endFunction

bool Function IsCompanionPowerArmorGlitched(Actor companionActor, bool includeSettingCheck)
	
	if (!includeSettingCheck || DTSleep_SettingAAF.GetValueInt() < 3)
		if (companionActor != None)
			if (companionActor.WornHasKeyword(ArmorTypePower) == false)
				if (companionActor.IsInPowerArmor())
					DTDebug("companion " + companionActor + " has power-armor glitch ", 1)
					return true
				endIf
			endIf
		endIf
	endIf
	
	return false
endFunction

Function IsCompanionPowerArmorGlitchedDisplayNearby()
	if (!MyMenuCheckBusy)
		MyMenuCheckBusy = true
		Utility.Wait(0.2)			
		IntimateCompanionSet companionSet = GetCompanionNearbyHighestRelationRank(false)

		if (companionSet.CompanionActor != None)
			IntimateCompanionRef = companionSet.CompanionActor
			DTSleep_CompIntimateQuest.Start()
			Utility.Wait(0.1)
			DTSleep_CompIntimateAlias.ForceRefTo(companionSet.CompanionActor)
			
			if (companionSet.CompanionActor.WornHasKeyword(ArmorTypePower))
				DTSleep_PersuadeBusyWarnPAMsg.Show()
			elseIf (IsCompanionPowerArmorGlitched(companionSet.CompanionActor, false))
				DTSleep_PersuadeBusyWarnPAFlagMsg.Show()
			else
				DTSleep_NoPAFlagMessage.Show()
			endIf
			Utility.WaitMenuMode(1.6)
			DTSleep_CompIntimateQuest.Stop()
			DTSleep_CompIntimateAlias.Clear()
			IntimateCompanionRef = None
		else
			DTSleep_CompanionNotFoundMsg.Show()
		endIf
		
		MyMenuCheckBusy = false
	endIf
endFunction

bool Function IsCompanion2RaceCompatible(Actor companionActor)					; v2.64
	; Nick Valentine not considered for 2nd partner, so romantic is false 
	return IsCompanionRaceCompatible(companionActor, None, false, false)
endFunction


bool Function IsCompanionRaceCompatible(Actor companionActor, ActorBase compBase = None, bool romantic = true, bool updateSceneData = true)

	if (companionActor == None)
		return false
	endIf
	
	if (updateSceneData)
		; reset before apply
		SceneData.FemaleRaceHasTail = false
		SceneData.IsUsingCreature = false
		SceneData.IsCreatureType = 0
		SceneData.RaceRestricted = 13				; v2.60 init to unknown race
	endIf
	
	if (updateSceneData && companionActor == StrongCompanionRef)

		SceneData.RaceRestricted = 0

		if ((DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).GetGenderForActor(PlayerRef) == 1)
			SceneData.IsUsingCreature = true
			SceneData.IsCreatureType = CreatureTypeStrong
			
			return true
		endIf
		return false
	endIf
	
	if (companionActor.IsChild() || companionActor.HasKeyword(ActorTypeChildKY))			; v2.60
		DTDebug("IsCompanion Compatible false -- isChild", 1)
		return false
	endIf
	
	if (compBase == None)
		compBase = (companionActor.GetLeveledActorBase() as ActorBase)
	endIf
	
	if (compBase != None)
	
		DTDebug("-----*---checking companion race for " + compBase + ", updateSceneData = " + updateSceneData, 1)
		Race compRace = compBase.GetRace()
		; Curie synth shows as gen2-Valentine, male gender - so we include 
		
		if (compRace == HumanRace || compRace == GhoulRace)
			if (updateSceneData)
				SceneData.RaceRestricted = 0
			endIf
			return true
								
		elseIf (updateSceneData && (DTSConditionals as DTSleep_Conditionals).IsVulpineRace != None && compRace == (DTSConditionals as DTSleep_Conditionals).IsVulpineRace)
			SceneData.RaceRestricted = 2			; limit body swaps companion
		
			if (compBase.GetSex() == 1)
				SceneData.FemaleRaceHasTail = true
			else
				SceneData.MaleBodySwapEnabled = -1
			endIf

			return true
			
		; v2.60
		elseIf (updateSceneData && (DTSConditionals as DTSleep_Conditionals).NanaRace != None && (compRace == (DTSConditionals as DTSleep_Conditionals).NanaRace || compRace == (DTSConditionals as DTSleep_Conditionals).NanaRace2))
			
			SceneData.RaceRestricted = 10			; embrace only
			if (compBase.GetSex() == 0)
				SceneData.MaleBodySwapEnabled = -1
			endIf
			DTDebug(" companion race is Anime NanaRace, " + compRace + ", actor: " + companionActor, 1)
			
			return true
		
		elseIf (updateSceneData && compRace == HandyRace)
			; may be Codsworth or Curie robot
			DTDebug(" found HandyRace, " + compRace + ", actor: " + companionActor, 1)			; v2.64 for testing
			if (DTSleep_AdultContentOn.GetValue() >= 2.0 && (DTSConditionals as DTSleep_Conditionals).ImaPCMod && DTSleep_SettingIntimate.GetValue() == 2.0)
			
				; TODO: only Test-Mode 
				if (DTSleep_SettingTestMode.GetValue() >= 1.0)
					if ((DTSConditionals as DTSleep_Conditionals).SavageCabbageVers >= 1.20)
						if (DressData.PlayerGender == 1)
							SceneData.IsUsingCreature = true
							SceneData.IsCreatureType = CreatureTypeHandy
							SceneData.RaceRestricted = 0
						
							return true
						endIf
					endIf
				endIf
			endIf
			
			return false
			
		elseIf (updateSceneData && compRace == SynthGen2RaceValentine)
		
			if (companionActor == CurieRef)
				; human Curie may show as synth-2 even though gen-3 should be human
				if (updateSceneData)
					SceneData.RaceRestricted = 0
				endIf
				return true
					
			elseIf (romantic)
				SceneData.IsUsingCreature = true
				; v1.08 - Xbox-only / non-adult scenes to support romanced Nick Valentine mod
				; v1.60 - also XOXO
				; v1.67 - any by included creature type to check
				
				; v2.82 rewrite order for easier reading
				if (DTSleep_SettingSynthHuman.GetValue() >= 1.0 && DTSleep_AdultContentOn.GetValue() >= 2.0 && (DTSConditionals as DTSleep_Conditionals).ImaPCMod)
					SceneData.IsUsingCreature = false					; for normal human-like 
					SceneData.IsCreatureType = CreatureTypeSynthNude	; v2.18 - to use synthGen2 nude armors
					SceneData.RaceRestricted = 0
				else
					SceneData.IsCreatureType = CreatureTypeSynth
					SceneData.RaceRestricted = 10			; embrace only			; v2.82 fix for R-X
				endIf
				
				return true

			else
				DTDebug(" not compatible SynthGen2: " + companionActor + ", updateSceneData = " + updateSceneData, 1)
			endIf
		else
			DTDebug(" not compatible race: " + compRace + ", actor: " + companionActor + ", updateSceneData = " + updateSceneData, 1)
		endIf
	else
		DTDebug(" IsCompanionRaceCompatible compBase is NONE!... actor: " + companionActor, 1)			; v2.64  - not expected 
	endIf
	
	return false
endFunction

bool Function IsDogPlaySettingsOn()

	if (DTSleep_SettingIntimate.GetValueInt() <= 0)
		return false
	endIf
	
	;Dog animation issues - for v2 disable for starting new, but allow current players
	if (DTSleep_IntimateDogEXP.GetValueInt() <= 0)
		return false
	endIf
	
	; player must know Dogmeat name
	if (PlayerKnowsDogmeatName.GetValue() <= 0.0)
		return false
	endIf
	
	if (IsAAFReady())
		; not supporting AAF play
		return false
	endIf
	
	if (DTSleep_SettingDogRestrain.GetValue() == 0.0 && IsAdultAnimationAvailable())
		if (!(DTSConditionals as DTSleep_Conditionals).IsLeitoActive && !(DTSConditionals as DTSleep_Conditionals).IsLeitoAAFActive && !(DTSConditionals as DTSleep_Conditionals).IsSavageCabbageActive)
			return false
		endIf
	endIf
	if (DressData.PlayerGender == 1)
		return true
	endIf

	return false
endFunction

int Function IsObjBelongPlayerWorkshop(ObjectReference objRef)
	ObjectReference linkRef = objRef.GetLinkedRef(WorkshopItemKeyword)   ; takes 0.1 seconds - check keywords first
	if (linkRef != None)

		; v2.46 - check for none first
		if (DTSConditionals.ConquestWorkshopKW != None && linkRef.HasKeyword(DTSConditionals.ConquestWorkshopKW))

			return 2
		elseIf (linkRef.GetValue(WorkshopPlayerOwned) >= 1.0)
			return 1
		endIf
	endIf
	
	return 0
EndFunction

bool Function IsFurnitureActuallyInUse(ObjectReference akFurniture, bool wideCheck = false)

	if (akFurniture != None)
		ObjectReference[] actorArray = akFurniture.FindAllReferencesWithKeyword(DTSleep_ActorKYList.GetAt(0), 200.0)
		if (actorArray != None)
			int i = 0
			while (i < actorArray.Length)
			
				Actor actRef = actorArray[i] as Actor
				if (actRef != None && actRef.IsEnabled() && actRef != PlayerRef)
					if (DTSleep_CommonF.IsActorOnBed(actRef, akFurniture, wideCheck))
						DTDebug("Furniture " + akFurniture + " ActuallyInUse by " + actRef, 2)
						return true
					endIf
				endIf
				
				i += 1
			endWhile
		endIf
		DTDebug("Furniture " + akFurniture + " NOT ActuallyInUse ", 2)
		return false
	endIf
	
	return true
endFunction

bool Function IsLocationPrivateOrUndress()
	Location currentLoc = (SleepPlayerAlias as DTSleep_PlayerAliasScript).CurrentLocation
	if (currentLoc == None)
		
		currentLoc = PlayerRef.GetCurrentLocation()   ; slow function - better to store current
	endIf
	if (DTSleep_PrivateLocationList.HasForm(currentLoc))
		return true
	elseIf (DTSleep_UndressLocationList.HasForm(currentLoc))
		return true
	endIf
	
	return false
endFunction

bool Function IsBedOwnedByPlayer(ObjectReference aBedRef, Actor companionRef)
	
	if (aBedRef != None)
	
		; v1.60 - consider ownership-quest
		int bedClaim = (DTSleep_BedOwnQuestP as DTSleep_BedOwnQuestScript).HasClaimedBeds(aBedRef, companionRef)
		
		if (bedClaim >= 1)
			return true
		elseIf (bedClaim < 0)
			; owned by another lover
			return false
		endIf
		
		bool ownedByPlayer = aBedRef.IsOwnedBy(PlayerRef)		; usually rented room or sometimes workshop set by game
		
		if (!ownedByPlayer)
			; can player claim ownership?
			bool bedHasOwner = aBedRef.HasActorRefOwner()
			if (bedHasOwner)
				
				if (companionRef != None && aBedRef.IsOwnedBy(companionRef))
					
					ownedByPlayer = true
				endIf
			elseIf (!aBedRef.HasKeyword(AnimFurnFloorBedAnims))
			
				if (IsLocationPrivateOrUndress())
					ActorBase bedOwnerBase = aBedRef.GetActorOwner()
					if (bedOwnerBase == None)
						ownedByPlayer = true   ; claim it!
					elseIf (companionRef != None && companionRef.GetLeveledActorBase() == bedOwnerBase)
						ownedByPlayer = true
					endIf
				elseIf (IsObjBelongPlayerWorkshop(aBedRef) == 1)
					
					ownedByPlayer = true  ; yep
				endIf
			endIf
		endIf
		
		return ownedByPlayer
	endIf
	
	return false
endFunction

;  furnType 0 for bed, 1 for chair
;
int Function DisplayCompanionBusyWarn(int val, int furnType = 0)
	
	if (val == 505)
		DTSleep_PersuadeBusyWarnNoToyMsg.Show()
		Utility.Wait(0.33)
		return -1
		
	elseIf (val > 0)
		; companion found ready, but not compatible with scene setup
		return DTSleep_PersuadeBusyWarnInCompMsg.Show(val)
		
	elseIf (val == 0)
		; not available
		return DTSleep_PersuadeBusyWarnNoCompMsg.Show()
		
	elseIf (val == -101)
		return DTSleep_PersuadeSoonPromptMsg.Show()
		
	elseIf (val == -20)
		; no strap-on - notify only
		DTSleep_PersuadeBusyWarnNoToyMsg.Show()
		return 0
		
	elseIf (val == -1 || val == -1001)
		; race or actor incompatible
		return DTSleep_PersuadeBusyWarnInCompMsg.Show(val)
		
	elseIf (val >= -3)
		; busy sit/sleep
		if (furnType == 0)
			return DTSleep_PersuadeBusyWarnSitMsg.Show()
		else
			DTSleep_PersuadeBusyWarnNoticeMsg.Show()
			return 0
		endIf
		
	elseIf (val == -4)
		; in scene
		return DTSleep_PersuadeBusyWarnSceneMsg.Show()
		
	elseIf (val == -12)
		return DTSleep_PersuadeBusyWarnPAMsg.Show()
		
	elseIf (val > -20 && val <= -9)
		; combat, sneak, weapon out
		return DTSleep_PersuadeBusyWarnCombatMsg.Show(val)
	endIf
	
	return DTSleep_PersuadeBusyWarnMsg.Show(val)
endFunction

; also update SceneData
int Function IsCompanionActorReadyForScene(IntimateCompanionSet intimateActor, bool sleepingOK = false, ObjectReference bedRef = None, bool pAOk = false, bool hugOkay = false)

	Actor compActor = intimateActor.CompanionActor
	SceneData.ToyFromContainer = false
	bool inPowerArmor = false
	SceneData.CompanionInPowerArmor = false

	if (compActor != None)
	
		int sitState = compActor.GetSitState()
	
		; ring bearer allowed to sit
		if (!intimateActor.HasLoverRing && sitState >= 2 && sitState <= 3)
			
			; animation playing - sitting - for companions only sitting (3) ever flagged
			float d1 = compActor.GetDistance(PlayerRef)
			Utility.Wait(0.333)
			float d2 = compActor.GetDistance(PlayerRef)
			float diff = d2 - d1
			
			if (diff < -17.0 || diff > 17.0)
				;Debug.Trace(myScriptName + " sit but walk")
			else
				;DTDebug(" IsCompanionready - No: companion sitting/workbench/other ", 2)
				return -3
			endIf
			
		elseIf (!sleepingOK && compActor.GetSleepState() > 2)	

			return -2
			
		elseIf (compActor.IsInCombat())
			;DTDebug(" IsCompanionready - No: companion is in combat ", 2)
			return -11
		elseIf (compActor.WornHasKeyword(ArmorTypePower))
			if (pAOk && compActor == CompanionDanseRef)
				; allow it
				inPowerArmor = true
			else 
				;DTDebug(" IsCompanionready - No: has PowerArmor, but not Danse or allowed for scene ", 1)
				return -12
			endIf
			
		elseIf (compActor.IsInScene())
			DTDebug("IsCompanionready - No: companion is busy in a scene ", 1)
			return -4
			
		elseIf (compActor.IsSneaking())
			DTDebug(" IsCompanionready - No: companion sneaking ", 1)
			return -14
			
		elseIf (compActor.IsWeaponDrawn())
			DTDebug(" IsCompanionready - No: companion has weapon drawn ", 1)
			return -13
		endIf
		
		int playerGender = -1
		int companionGender = -1
		bool sameCompanion = false
		
		if (DressData && DressData.PlayerGender >= 0)
			playerGender = DressData.PlayerGender
		else
			ActorBase playerBase = (PlayerRef.GetBaseObject() as ActorBase)
			playerGender = playerBase.GetSex()
			DressData.PlayerGender = playerGender
		endIf

		if (SceneData.MaleRole == compActor)
			companionGender = SceneData.MaleRoleGender	 
			sameCompanion = true
		elseIf (SceneData.FemaleRole == compActor)
			sameCompanion = true
			if (SceneData.SameGender)
				companionGender = playerGender
			elseIf (playerGender == 1)
				companionGender = 0
			else
				companionGender = 1
			endIf
			
			; double-check genders
			if (SceneData.SameGender)
				if (companionGender != playerGender)
					companionGender = -2
				endIf
			elseIf (companionGender == playerGender)
				companionGender = -2
			endIf
		else
			ResetSceneData(!hugOkay)									; keep race info unless hugs v2.82
			if (MyPAGlitchMessageCount > 1)								; reset glitch count v2.75
				MyPAGlitchMessageCount = 0
			endIf
		endIf
		
		SceneData.CompanionInPowerArmor = inPowerArmor
		
		if ((DTSConditionals as DTSleep_Conditionals).IsCoastDLCActive && compActor == (DTSConditionals as DTSleep_Conditionals).FarHarborDLCLongfellowRef)
			
			SceneData.CompanionBribeType = IntimateBribeTypeBooze
			
		elseIf (compActor == CompanionMacCreadyRef)
			
			SceneData.CompanionBribeType = IntimateBribeTypeMutfruit
			
		elseIf (compActor == CompanionHancockRef)
			SceneData.CompanionBribeType = IntimateBribeNaked
			
		elseIf (compActor == CompanionCaitRef)
			SceneData.CompanionBribeType = IntimateBribeNaked
		elseIf (compActor == StrongCompanionRef)
			if (intimateActor.RelationRank >= 3 && IntimacySMCount < 20)
				SceneData.CompanionBribeType = IntimateBribeTypeMeat
			else
				SceneData.CompanionBribeType = IntimateBribeNaked
			endIf
		elseIf (compActor == CompanionPiperRef)
			
			SceneData.CompanionBribeType = IntimateBribeTypeCandy
		elseIf (compActor == CompanionX6Ref)
			SceneData.CompanionBribeType = IntimateBribeSynthTreat
		endIf
		
		; custom player race check - is tail?
		;
		if ((DTSConditionals as DTSleep_Conditionals).IsVulpineRacePlayerActive)
			if (playerGender == 1)
				SceneData.FemaleRaceHasTail = true
			endIf
		endIf
		
		
		if (companionGender < 0 || SceneData.RaceRestricted >= 13)					; v2.64 - added race check to force update
			if (compActor == StrongCompanionRef)
			
				companionGender = 0
				SceneData.IsUsingCreature = true
				SceneData.IsCreatureType = CreatureTypeStrong
				SceneData.RaceRestricted = 0										; v2.64 - in case multi-follower
			elseIf (compActor.HasKeyword(ActorTypeSuperMutantBehemothKY))
				companionGender = 0
				SceneData.IsUsingCreature = true
				SceneData.IsCreatureType = CreatureTypeBehemoth
				SceneData.RaceRestricted = 0										; v2.64 - in case multi-follower
			elseIf (hugOkay && compActor.HasKeyword(ActorTypeRobotKY))				; v2.82 if for hugs then record now else do race check
				companionGender = 0
				SceneData.IsUsingCreature = true
				SceneData.IsCreatureType = CreatureTypeHandy
				SceneData.RaceRestricted = 10
				
			; v2.60 this may backfire--hide for now
			;elseIf (DressData.CompanionActor == compActor && DressData.CompanionGender >= 0)
			;	companionGender = DressData.CompanionGender
			;	if (companionGender == 1)
			;		; tail check
			;		if ((DTSConditionals as DTSleep_Conditionals).IsVulpineRace != None)
			;			ActorBase compBase = (compActor.GetBaseObject() as ActorBase)
			;			Race compRace = compBase.GetRace()
			;			if (compRace == (DTSConditionals as DTSleep_Conditionals).IsVulpineRace)
			;				SceneData.FemaleRaceHasTail = true
			;			endIf
			;		endIf
			;	endIf
			else
				ActorBase compBase = None
				
				; v2.82 removed condition intimateActor.RaceIntimateCompatible == 0
				;   -- skip this short-circuit for now until review 
				if (!hugOkay && !IsCompanionRaceCompatible(compActor, compBase, true))  ; includes tail check and returns creature if synth -- assume romanced
					DTDebug("IsCompReadyForScene - companion " + compActor + " not race compatible (-1001)", 1)
					; v2.82 do not! ResetSceneData()
					
					return -1001
					
				elseIf (compActor == CurieRef)
					companionGender = 1
				else
					if (compBase == None)
						compBase = (compActor.GetLeveledActorBase() as ActorBase)
					endIf
					if (compBase != None)						; v2.64 just in case
						companionGender = compBase.GetSex()
					endIf
				endIf
				
				if (DressData.CompanionActor == compActor)
					DressData.CompanionGender = companionGender
				endIf

			endIf
			
			if (companionGender == 0)
			
				if ((DTSConditionals as DTSleep_Conditionals).IsUniqueFollowerMaleActive)
					
					int armorIndex = (DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).GetCompanionLeitoArmorIndexPublic(compActor)
					
					if (armorIndex >= 0)
						armorIndex += 1
						
						SceneData.MaleRoleCompanionIndex = armorIndex
					endIf
				endIf
			
			endIf
		endIf
		
		if (!hugOkay && SceneData.RaceRestricted >= 10)					; v2.60 - not intimate ready
			DTDebug("IsCompReadyForScene - companion " + compActor + " RaceRestricted = " + SceneData.RaceRestricted + "  (-1001)", 1)
			return -1001
		endIf
			
		if (playerGender == companionGender)
		
			SceneData.MaleRoleGender = playerGender  ; same gender so whichever role
			
			if (compActor == StrongCompanionRef || compActor.HasKeyword(ActorTypeSuperMutantBehemothKY))
				return -1
			elseIf (compActor.HasKeyword(ActorTypeRobotKY))
				return -1
			endIf
			
			SceneData.SameGender = true
		
			if (playerGender == 1)
				
				; one character requires a strap-on for adult animations
				bool requireStrapOn = false
				
				if (DTSleep_AdultContentOn.GetValueInt() >= 2 && !inPowerArmor)		; removed !hugOkay condition to force re-check v3.0
				
					if (DTSleep_IsLeitoActive.GetValue() > 0.0 && (DTSConditionals as DTSleep_Conditionals).IsLeitoActive)
						requireStrapOn = true
					elseIf ((DTSConditionals as DTSleep_Conditionals).IsLeitoAAFActive)
						requireStrapOn = true
					elseIf ((DTSConditionals as DTSleep_Conditionals).IsCrazyAnimGunActive)
						requireStrapOn = true
					elseIf ((DTSConditionals as DTSleep_Conditionals).IsGrayAnimsActive)
						requireStrapOn = true
					endIf
				endIf
				
				if (requireStrapOn)
				
					if (SceneData.HasToyAvailable && SceneData.ToyArmor != None)
						; is it still available?
						if (DressData.PlayerEquippedStrapOnItem && DressData.PlayerEquippedStrapOnItem == SceneData.ToyArmor)
							; still have it!
								SceneData.MaleRole = PlayerRef
								SceneData.FemaleRole = compActor
								MainQSceneScriptP.IsMaleCamOffset = true
								;MainQSceneScriptP.ReverseCamXOffset = true
								SceneData.HasToyEquipped = true
								
								return 3
						elseIf (DressData.PlayerLastEquippedStrapOnItem && DressData.PlayerLastEquippedStrapOnItem == SceneData.ToyArmor)
							if (PlayerRef.GetItemCount(SceneData.ToyArmor) > 0)
								; still have it!
								SceneData.MaleRole = PlayerRef
								SceneData.FemaleRole = compActor
								MainQSceneScriptP.IsMaleCamOffset = true
								;MainQSceneScriptP.ReverseCamXOffset = true
								SceneData.HasToyEquipped = PlayerRef.IsEquipped(SceneData.ToyArmor)			; just in case  v3.0

								
								return 2
							endIf
						elseIf (sameCompanion && DressData.CompanionEquippedStrapOnItem && DressData.CompanionEquippedStrapOnItem == SceneData.ToyArmor)
							if (compActor.GetItemCount(SceneData.ToyArmor) > 0)
								; still have it!
								SceneData.MaleRole = compActor
								SceneData.FemaleRole = PlayerRef
								MainQSceneScriptP.IsMaleCamOffset = false
								MainQSceneScriptP.ReverseCamXOffset = false
								SceneData.HasToyEquipped = compActor.IsEquipped(SceneData.ToyArmor)
								
								return 2
							endIf
						endIf
					endIf
				
						
					Armor strapOn = (DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).GetStrapOnForActor(PlayerRef, true, bedRef)
					
					if (strapOn != None)
					
						SceneData.MaleRole = PlayerRef
						SceneData.FemaleRole = compActor
						MainQSceneScriptP.IsMaleCamOffset = true
						;MainQSceneScriptP.ReverseCamXOffset = true
						SceneData.HasToyAvailable = true
						SceneData.ToyArmor = strapOn
						if (DressData.PlayerEquippedStrapOnItem && DressData.PlayerEquippedStrapOnItem == strapOn)
							
							SceneData.HasToyEquipped = true
						elseIf (DressData.PlayerLastEquippedStrapOnItem && DressData.PlayerLastEquippedStrapOnItem == strapOn)
							
							SceneData.HasToyEquipped = false
						else
							SceneData.HasToyEquipped = PlayerRef.IsEquipped(strapOn)
						endIf
						
						if (!SceneData.HasToyEquipped && PlayerRef.GetItemCount(strapOn) == 0)
							SceneData.ToyFromContainer = true
						endIf

						return 2
					else
						strapOn = (DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).GetStrapOnForActor(compActor, false)
						if (strapOn != None)
							SceneData.FemaleRole = PlayerRef
							SceneData.MaleRole = compActor
							MainQSceneScriptP.IsMaleCamOffset = false
							MainQSceneScriptP.ReverseCamXOffset = false
							SceneData.HasToyAvailable = true
							SceneData.ToyArmor = strapOn
							if (DressData.CompanionEquippedStrapOnItem && DressData.CompanionEquippedStrapOnItem == strapOn)
								SceneData.HasToyEquipped = true
							else
								SceneData.HasToyEquipped = false
							endIf
							
							return 2
						endIf
					endIf
					
					; v1.24 - no longer require toy
					; check swap setting v2.82 
					if (DTSleep_SettingSwapRoles.GetValueInt() <= 0)			; v2.84.1 fixed order
						; default player in male role as has been the case
						SceneData.FemaleRole = PlayerRef
						SceneData.MaleRole = compActor
						MainQSceneScriptP.IsMaleCamOffset = false
					else
						SceneData.MaleRole = PlayerRef
						SceneData.FemaleRole = compActor
						MainQSceneScriptP.IsMaleCamOffset = true
					endIf
					;MainQSceneScriptP.ReverseCamXOffset = true
					SceneData.HasToyAvailable = false
					SceneData.ToyArmor = None
				
					if ((DTSConditionals as DTSleep_Conditionals).IsAtomicLustActive)
						return 1			; no toy necessary
					elseIf ((DTSConditionals as DTSleep_Conditionals).IsSavageCabbageActive)
						return 1
					elseIf ((DTSConditionals as DTSleep_Conditionals).IsRufgtActive)
						return 1
					endIf
					
					return 505			; no toy available, but need one
				else
					; strap-on not required
					
					if (DTSleep_SettingSwapRoles.GetValueInt() <= 0)			; v2.82 swap setting
						; no  swap, same roles as old versions
						SceneData.FemaleRole = PlayerRef
						SceneData.MaleRole = compActor
						MainQSceneScriptP.IsMaleCamOffset = false
					else
						SceneData.FemaleRole = compActor
						SceneData.MaleRole = PlayerRef
						MainQSceneScriptP.IsMaleCamOffset = true
					endIf
					MainQSceneScriptP.ReverseCamXOffset = false
					SceneData.HasToyAvailable = false
					SceneData.HasToyEquipped = false
					SceneData.ToyArmor = DressData.PlayerEquippedStrapOnItem
					if (SceneData.ToyArmor != None)
						SceneData.HasToyEquipped = true
						SceneData.HasToyAvailable = true
					endIf
					
					return 1
				endIf
			else
				; both genders male
				if (DTSleep_SettingSwapRoles.GetValueInt() <= 0)			; v2.82 swap setting
					SceneData.MaleRole = PlayerRef
					SceneData.FemaleRole = compActor
					MainQSceneScriptP.IsMaleCamOffset = true
				else
					SceneData.MaleRole = compActor
					SceneData.FemaleRole = PlayerRef
					MainQSceneScriptP.IsMaleCamOffset = false
				endIf
				;MainQSceneScriptP.ReverseCamXOffset = true
				SceneData.HasToyAvailable = false
				SceneData.SameGender = true
				
				return 1
			endIf
			
		elseIf (playerGender == 0)
			SceneData.MaleRoleGender = playerGender
			SceneData.MaleRole = PlayerRef
			SceneData.FemaleRole = compActor
			MainQSceneScriptP.IsMaleCamOffset = true
			;MainQSceneScriptP.ReverseCamXOffset = true
			SceneData.HasToyAvailable = false
			SceneData.SameGender = false
			SceneData.ToyArmor = DressData.CompanionEquippedStrapOnItem
			if (SceneData.ToyArmor != None)
				SceneData.HasToyEquipped = true
				SceneData.HasToyAvailable = true
			endIf
			
			return 1
		else
			
			SceneData.FemaleRole = PlayerRef
			SceneData.MaleRole = compActor
			SceneData.MaleRoleGender = companionGender
			MainQSceneScriptP.IsMaleCamOffset = false
			MainQSceneScriptP.ReverseCamXOffset = false
			SceneData.HasToyAvailable = false
			SceneData.SameGender = false
			SceneData.ToyArmor = DressData.PlayerEquippedStrapOnItem
			if (SceneData.ToyArmor != None)
				SceneData.HasToyEquipped = true
				SceneData.HasToyAvailable = true
			endIf
			
			if (SceneData.MaleRole == StrongCompanionRef)
				SceneData.IsUsingCreature = true
				SceneData.IsCreatureType = CreatureTypeStrong
			elseIf (SceneData.MaleRole.HasKeyword(ActorTypeSuperMutantBehemothKY))
				SceneData.IsUsingCreature = true
				SceneData.IsCreatureType = CreatureTypeBehemoth
			elseIf (SceneData.MaleRole.HasKeyword(ActorTypeRobotKY))
				SceneData.IsUsingCreature = true
				SceneData.IsCreatureType = CreatureTypeHandy
			endIf
			
			return 1
		endIf
	;elseIf (compActor != None)
	;	
	;	DTSleep_BadCompanionMsg.Show()
	;	Utility.Wait(0.2)
	endIf
	
	return 0
EndFunction

bool Function IsFPFPMarriedActor(Actor akActor)
	if ((DTSConditionals as DTSleep_Conditionals).ModFPFP_Married != None && akActor.HasPerk((DTSConditionals as DTSleep_Conditionals).ModFPFP_Married))
		return true
	elseIf ((DTSConditionals as DTSleep_Conditionals).ModFPFP_Married2 != None && akActor.HasPerk((DTSConditionals as DTSleep_Conditionals).ModFPFP_Married2))
	
		return true
	endIf
	return false
EndFunction


int Function IsHeatherInLove()

	if ((DTSConditionals as DTSleep_Conditionals).IsHeatherCompInLove)
		return 2
	else
		; v2.78 update for HeatherV2
		string heatherPluginName = "llamaCompanionHeatherv2.esp"
		if ((DTSConditionals as DTSleep_Conditionals).HeatherCampanionVers < 1.5)
			heatherPluginName = "llamaCompanionHeather.esp"
		endIf
		
		Quest heatherCoreQuest = Game.GetFormFromFile(0x0300C9BA, heatherPluginName) as Quest
		
		if (heatherCoreQuest != None)
			if (heatherCoreQuest.GetStageDone(1002))
				(DTSConditionals as DTSleep_Conditionals).IsHeatherCompInLove = false
				return 0			; v2.14 - player chose not romantic
			
			elseIf (heatherCoreQuest.GetStageDone(1001))
				; full romance - flag
				(DTSConditionals as DTSleep_Conditionals).IsHeatherCompInLove = true
				
				return 2
				
			elseIf (heatherCoreQuest.GetStageDone(751))
				; idolize and heather flirts
				; v2.14 - do not mark flag in case player chooses to end relationship
				
				return 1
			endIf
		endIf
	endIf
	
	return 0
EndFunction

bool Function IsNWSBarbInLove()
	if ((DTSConditionals as DTSleep_Conditionals).IsNWSBarbActive)
		Perk barbPerk = (DTSConditionals as DTSleep_Conditionals).ModCompNWSBarbRewardPerk
		if (barbPerk != None && PlayerRef.HasPerk(barbPerk))
		
			return true
		endIf
	endIf
	
	return false
endFunction

; caller expected to have checked IsFurnitureInUse
; return -2 for power armor furniture nearby, -1 for NPC nearby
;
int Function IsPAStationOpen(ObjectReference akFurniture)
	if (akFurniture != None)
		; assume a Power Armor Repair Station -- is a frame nearby?
		
		if (IsFurnitureActuallyInUse(akFurniture, true))
			return -1
		else
			ObjectReference[] paFrameArray = akFurniture.FindAllReferencesWithKeyword(FurnitureTypePowerArmorKY, 96.0)
			
			if (paFrameArray.Length > 0)
				int i = 0
				while (i < paFrameArray.Length)
				
					ObjectReference paFrameRef = paFrameArray[i] as ObjectReference
					if (paFrameRef != None && paFrameRef.IsEnabled())
						DTDebug(" IsPAStationOpen-false  found power armor furniture at distance " + paFrameRef.GetDistance(akFurniture), 2)
						return -2
					endIf
					
					i += 1
				endWhile
			endIf
		endIf
		
		return 1
	endIf

	return 0
endFunction

; returns true if always undress--private location or undress location--meaning override observe winter
;
bool Function IsPlayerOkayToUndressForBed(float desiredSleepTime, ObjectReference akBed, bool playerNaked = false)

	IsUndressReady = playerNaked
	bool alwaysUndress = false
	
	; if the player owns the bed or owns the workshop connected then okay to undress
	Location currentLoc = (SleepPlayerAlias as DTSleep_PlayerAliasScript).CurrentLocation
	if (!currentLoc)
		currentLoc = PlayerRef.GetCurrentLocation()  ; up to extra 0.12 seconds
	endIf
	
	int undressLevel = DTSleep_SettingUndress.GetValueInt()
	
	if (undressLevel == 2 || undressLevel >= 4)
		IsUndressReady = true
		
	elseIf (undressLevel == 1 || undressLevel == 3)
	
		if (desiredSleepTime < 3.4)
			; no undress for nap!
			IsUndressReady = false
			
		elseIf (PlayerRef.IsChild())
			; in case player using play-as-child mod
			Debug.Trace(myScriptName + "  player character is child ", 0)
		elseIf (currentLoc == DiamondCityPlayerHouseLocation)
			IsUndressReady = true
			alwaysUndress = true
			
		elseIf (currentLoc != None && DTSleep_PrivateLocationList.HasForm(currentLoc as Form))
			; original intent: some private locations also on Undress, but not anymore so check shorter list first
			IsUndressReady = true
			alwaysUndress = true
			
		elseIf (currentLoc != None && DTSleep_UndressLocationList.HasForm(currentLoc as Form))
			IsUndressReady = true
			alwaysUndress = true
			
		elseIf (currentLoc != None && DTSleep_TownLocationList.HasForm(currentLoc as Form))
			IsUndressReady = true
			
			; some towns are also settlements
			; workshop check takes time so only check if location has KY
			if (currentLoc.HasKeyword(LocTypeWorkshopSettlementKY))
				if (IsObjBelongPlayerWorkshop(akBed) > 0)
					alwaysUndress = true
				endIf
			endIf
			
		elseIf (akBed.IsOwnedBy(PlayerRef))
			IsUndressReady = true				; some rents outside
			alwaysUndress = true				; v1.51 - always so not confused when workshop sets
			
		elseIf (IntimateCompanionRef != None && akBed.IsOwnedBy(IntimateCompanionRef))
			IsUndressReady = true
			alwaysUndress = true
			
		elseIf (currentLoc != None && currentLoc.HasKeyword(LocTypeWorkshopSettlementKY))
			; this means will be undress-safe even if not yet taken workshop--like a town
			IsUndressReady = true
			if (IsObjBelongPlayerWorkshop(akBed) > 0)
				; this check takes time so only check if location has KY
				alwaysUndress = true
			endIf
		endIf
	endIf
	
	return alwaysUndress
EndFunction

bool Function IsSceneDogmeatSafe(ObjectReference bedRef, float minDistance = 116.0)
	
	if (DogmeatCompanionAlias != None && PlayerHasActiveDogmeatCompanion.GetValueInt() > 0)
		Actor dogmeatRef = DogmeatCompanionAlias.GetActorReference()
		
		if (dogmeatRef && dogmeatRef.GetSitState() < 2)
			
			float dist = DTSleep_CommonF.DistanceBetweenObjects(dogmeatRef, PlayerRef, false) ; no ignore z-axis -v1.48
			
			if (dist < minDistance)
			
				if (DogmeatSetWait)
					; dog set to wait in the way - v1.49
					SetDogmeatFollow()
				endIf
				
				return false
			endIf
		endIf
	endIf
	
	return true
endFunction

bool Function IsSexyDanceCompatibleFurn(ObjectReference akFurniture, Form furnBaseForm, bool sameGenderComp)

	if ((DTSConditionals as DTSleep_Conditionals).IsSavageCabbageActive)
		if (!sameGenderComp || (DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).GetGenderForActor(PlayerRef) == 1)
			
			if (DTSleep_SettingChairsEnabled.GetValue() >= 2.0 && (DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).GetFurnitureSupportDanceSexy(akFurniture, furnBaseForm) >= 100)
				return true
			endIf
		endIf
	endIf
	
	return false
endFunction

bool Function IsUndressCheckRequested()

	if (DTSleep_CaptureExtraPartsEnable.GetValue() > 0.0)
		float curTime = Utility.GetCurrentGameTime()
		float captureTime = DTSleep_CaptureExtraPartsEnable.GetValue()
		float minDiff = DTSleep_CommonF.GetGameTimeHoursDifference(curTime, captureTime) * 60.0
		
		if (minDiff < 20.0)
			return true
		else
			DTSleep_CaptureExtraPartsEnable.SetValue(0.0)
		endIf	
	endIf
	
	return false
endFunction

bool Function IsUnsafeToRestBed(ObjectReference akBed)
	
	; The Tent_Forest01 search stopped working so also test cells where tent resides
	if (akBed.HasKeyword(AnimFurnFloorBedAnims) || (DTSConditionals as DTSleep_Conditionals).IsSnapBedsActive)
	
		Location currentLoc = (SleepPlayerAlias as DTSleep_PlayerAliasScript).CurrentLocation
		
		ObjectReference closestShelter = Game.FindClosestReferenceOfAnyTypeInListFromRef(DTSleep_BadSheltersList, akBed, 460.0)
		;ObjectReference closestShelter =;DTSleep_CommonF.FindNearestObjectInListFromObjRef(DTSleep_BadSheltersList, akBed, 160.0)
		if (closestShelter != None)
			if (akBed.GetDistance(closestShelter) < 160.0)
				
				DTDebug(" found bad shelter " + closestShelter + " near bed " + akBed + " distance: " + closestShelter.GetDistance(akbed), 1)
			
				return true
			else
				; too far - no cell check
				DTDebug(" found bad shelter " + closestShelter + " outside range of bed " + akBed + " distance: " + closestShelter.GetDistance(akbed), 1)
				
				return false
			endIf
		elseIf (currentLoc != None && DTSleep_BadShelterLocationList.HasForm(currentLoc as Form))
			; check positions of known bad tents
			float bedX = akBed.GetPositionX()
			float bedY = akBed.GetPositionY()
			
			if (bedX > 81650.0 && bedX < 81760.0 && bedY > 96450.0 && bedY < 96550.0)		;fish plant
				return true
			elseIf (bedX > 30900.0 && bedX < 31000.0 && bedY > -88400.0 && bedY < -88280.0)	; quincyRuins5
				return true
			elseIf (bedX > 75390.0 && bedX < 75500.0 && bedY > -68200.0 && bedY < -6800.0)	; spectacleIsland
				return true
			endIf
		endIf
		
		Cell currentCell = akBed.GetParentCell()
		if (currentCell != None)			
			if (DTSleep_BedCellNoRestList.HasForm(currentCell as Form))
				
				Form baseForm = akBed.GetBaseObject()
				DTDebug(" UnsafeToRest in a bad cell, check bed " + baseForm, 1)

				if (baseForm != None && DTSleep_BedPlacedNoRestList.HasForm(baseForm))
					DTDebug(" on no-rest bed list " + akBed + " in Cell " + currentCell, 1)

					return true
				endIf
			endIf
		endIf
	endIf
	
	return false
endFunction

; see PlayerFriskyScore for score
;
int Function LocationScoreByFriskyScore(int friskyScore, Location currentLoc = None)
	
	float exp = DTSleep_IntimateEXP.GetValue()
	if (exp > 5.0)
		int adjustLim = 0
		if (exp >= 130.0)
			adjustLim = 13
		else
			adjustLim = Math.Floor(exp * 0.10)
			if (adjustLim > 13)
				adjustLim = 13
			endIf
		endIf
		if (currentLoc == None)
			currentLoc = (SleepPlayerAlias as DTSleep_PlayerAliasScript).CurrentLocation
		endIf
		
		if (currentLoc != None && friskyScore > 5)

			if (DTSleep_PrivateLocationList.HasForm(currentLoc as Form))
				if (friskyScore > (42 + adjustLim))
					return 14
				else
					return 4
				endIf
			
			elseIf (DTSleep_UndressLocationList.HasForm(currentLoc as Form))
				if (friskyScore > (52 + adjustLim))
					return 13
				else
					return 3
				endIf
				
			elseIf (DTSleep_TownLocationList.HasForm(currentLoc as Form))
				if (friskyScore > (72 + adjustLim))
					return 12
				else
					return 2
				endIf
			endIf
		endIf
	endIf
	
	return 0
EndFunction

Function LoverBonus(bool isAdd, bool notify = false)
	if (isAdd)
		if (!PlayerRef.HasPerk(DTSleep_LoversBonusPerk))
			LoverBonusStrong(false)
			
			PlayerRef.AddPerk(DTSleep_LoversBonusPerk)
			if (notify)
				DTSleep_LoverBonusMsg.Show()
			endIf
			StartTimerGameTime(20.0, LoverPerkGameTimerID)  ; in game hours
		endIf
	else
		if (PlayerRef.HasPerk(DTSleep_LoversBonusPerk))

			PlayerRef.RemovePerk(DTSleep_LoversBonusPerk)
			CancelTimerGameTime(LoverPerkGameTimerID)
		else
			LoverBonusStrong(false)
		endIf
		LoverBonusEmbrace(false)
	endIf
endFunction

Function LoverBonusDog(bool isAdd, bool notify = false)
	if (isAdd)
		if (!PlayerRef.HasPerk(DTSleep_LoverDogBonusPerk))
			PlayerRef.AddPerk(DTSleep_LoverDogBonusPerk)
			if (notify)
				DTSleep_LoverBonusDogMsg.Show()
			endIf
			StartTimerGameTime(20.0, LoverDogPerkGameTimerID)     ; in game hours
		endIf
	
	elseIf (PlayerRef.HasPerk(DTSleep_LoverDogBonusPerk))
		
		PlayerRef.RemovePerk(DTSleep_LoverDogBonusPerk)
		CancelTimerGameTime(LoverDogPerkGameTimerID)
	endIf
endFunction

Function LoverBonusEmbrace(bool isAdd, bool notify = false)
	if (isAdd)
		if (!PlayerRef.HasPerk(DTSleep_LoversEmbraceHugPerk) && !PlayerRef.HasPerk(DTSleep_LoversSexyPerk))
			PlayerRef.AddPerk(DTSleep_LoversEmbraceHugPerk)
	
			if (notify)
				DTSleep_LoversEmbraceHugMsg.Show()
			endIf
			StartTimerGameTime(8.0, IntimateEmbracePerkTimerID)
		endIf
	elseIf (PlayerRef.HasPerk(DTSleep_LoversEmbraceHugPerk))
		
		PlayerRef.RemovePerk(DTSleep_LoversEmbraceHugPerk)
		CancelTimerGameTime(IntimateEmbracePerkTimerID)
	elseIf (PlayerRef.HasPerk(DTSleep_LoversSexyPerk))
		PlayerRef.RemovePerk(DTSleep_LoversSexyPerk)
		CancelTimerGameTime(IntimateSexyPerkTimerID)
	endIf
endFunction

Function LoverSexyBonus(bool isAdd, bool notify = false)
	if (isAdd)
		if (!PlayerRef.HasPerk(DTSleep_LoversSexyPerk) && !PlayerRef.HasPerk(DTSleep_LoversEmbraceHugPerk))
			PlayerRef.AddPerk(DTSleep_LoversSexyPerk)
			if (notify)
				DTSleep_LoversSexyMsg.Show()
			endIf
			StartTimerGameTime(8.0, IntimateSexyPerkTimerID)
		endIf
	elseIf (PlayerRef.HasPerk(DTSleep_LoversSexyPerk))
		PlayerRef.RemovePerk(DTSleep_LoversSexyPerk)
		CancelTimerGameTime(IntimateSexyPerkTimerID)
	endIf
endFunction

Function LoverBonusRested(bool isAdd, bool notify = false)
	if (isAdd)
		if (!PlayerRef.HasPerk(DTSleep_LoversEmbracePerk) && !PlayerRef.HasPerk(DTSleep_LoversCoffinPerk))
			PlayerRef.AddPerk(DTSleep_LoversEmbracePerk)
			if (notify)
				DTSleep_LoversEmbraceMsg.Show()
			endIf
			StartTimerGameTime(22.0, IntimateRestedPerkTimerID)
		endIf
	else
		CancelTimerGameTime(IntimateRestedPerkTimerID)
		if (PlayerRef.HasPerk(DTSleep_LoversEmbracePerk))
			PlayerRef.RemovePerk(DTSleep_LoversEmbracePerk)
		elseIf (PlayerRef.HasPerk(DTSleep_LoversCoffinPerk))
			PlayerRef.RemovePerk(DTSleep_LoversCoffinPerk)
		endIf
	endIf
endFunction

Function LoverBonusRestedCoffin(bool isAdd, bool notify = false)
	if (isAdd)
		if (!PlayerRef.HasPerk(DTSleep_LoversEmbracePerk) && !PlayerRef.HasPerk(DTSleep_LoversCoffinPerk))
			PlayerRef.AddPerk(DTSleep_LoversCoffinPerk)
			if (notify)
				DTSleep_LoversEmbraceCoffinMsg.Show()
			endIf
			StartTimerGameTime(20.0, IntimateRestedPerkTimerID)
		endIf
	elseIf (PlayerRef.HasPerk(DTSleep_LoversCoffinPerk))
		CancelTimerGameTime(IntimateRestedPerkTimerID)
		PlayerRef.RemovePerk(DTSleep_LoversCoffinPerk)
	endIf
endFunction

Function LoverBonusStrong(bool isAdd, bool notify = false)
	if (isAdd)
		if (!PlayerRef.HasPerk(DTSleep_LoverStrongBonusPerk))
			LoverBonus(false)
			PlayerRef.AddPerk(DTSleep_LoverStrongBonusPerk)
			if (notify)
				DTSleep_LoverBonusStrongMsg.Show()
			endIf
			
			StartTimerGameTime(20.0, LoverStrongPerkGameTimerID)     ; in game hours
		endIf

		; v2.87 - okay for all--removed test-mode requirement
		if (IntimacySMCount >= 5)
			if (!PlayerRef.IsInFaction(DTSleep_MutantAllyFaction))
				if (PlayerHasActiveCompanion.GetValueInt() <= 0)
					DTSleep_MutantAllySpell.Cast(PlayerRef, PlayerRef)
				elseIf (CompanionAlias != None && CompanionAlias.GetActorReference() == StrongCompanionRef)
					DTSleep_MutantAllySpell.Cast(PlayerRef, PlayerRef)
				endIf
			endIf
		endIf
	
	elseIf (PlayerRef.HasPerk(DTSleep_LoverStrongBonusPerk))
		
		PlayerRef.RemovePerk(DTSleep_LoverStrongBonusPerk)
		CancelTimerGameTime(LoverStrongPerkGameTimerID)
	endIf
endFunction

Function ModSetSaveOrSleepToggle()
	int val = DTSleep_IsSoSActive.GetValueInt()
	perk sosPerk = (DTSConditionals as DTSleep_Conditionals).ModSoSPerk
	
	if (sosPerk != None)
		if (val >= 2.0)
		
			if (PlayerRef.HasPerk(sosPerk))
				PlayerRef.RemovePerk(sosPerk)
			endIf
			DTSleep_IsSoSActive.SetValue(1.0)
			
			DTSleep_ModSoSDisabledMsg.Show()

		elseIf (val == 1.0)
			if (!PlayerRef.HasPerk(sosPerk))
				PlayerRef.AddPerk(sosPerk)
			endIf
			
			DTSleep_IsSoSActive.SetValue(2.0)
			
			DTSleep_ModSoSEnabledMsg.Show()
		endIf
	endIf
	
endFunction

Function ModSetNNESToggle()

	int val = DTSleep_IsNNESActive.GetValueInt()
	perk nnesPerk = (DTSConditionals as DTSleep_Conditionals).ModNNESPerk
	
	if (nnesPerk != None && DTSleep_SettingModActive.GetValue() >= 0.0)    
		if (val >= 2.0 || PlayerRef.HasPerk(nnesPerk))                   ; fix on reload v3.004
			if (PlayerRef.HasPerk(nnesPerk))
				PlayerRef.RemovePerk(nnesPerk)
			endIf
			DTSleep_IsNNESActive.SetValue(1.0)
			
			DTSleep_ModNNESDisableMsg.Show()
			
		elseIf (val == 1.0)
			if (!PlayerRef.HasPerk(nnesPerk))
				PlayerRef.AddPerk(nnesPerk)
			endIf
			
			DTSleep_IsNNESActive.SetValue(2.0)
			
			DTSleep_ModNNESEnableMsg.Show()
		endIf
	endIf

EndFunction

int Function ModSYSleepDisable()

	int result = 0
	
	string sleepName = "See You Sleep CW editon - Beta.esp"
	Perk abPerk = Game.GetFormFromFile(0x01004C53, sleepName) as Perk
	Perk asPerk = Game.GetFormFromFile(0x0100EBD0, sleepName) as Perk
	GlobalVariable abToggle = Game.GetFormFromFile(0x0100E433, sleepName) as GlobalVariable
	
	if (abToggle != None && abToggle.GetValueInt() >= 1)

		abToggle.SetValue(0.0)
		result = 1
	endIf
	
	if (abPerk != None && PlayerRef.HasPerk(abPerk))
		PlayerRef.RemovePerk(abPerk)
		DTDebug(" removed See-You-Sleep sleep perk", 2)

	endIf
	if (asPerk != None && PlayerRef.HasPerk(asPerk))
		PlayerRef.RemovePerk(asPerk)
		DTDebug(" removed See-You-Sleep sleep save perk", 2)
	endIf

	return result
endFunction


; ------
;  moving player forces a fade-out/load-screen
; MoveTo: https://www.creationkit.com/fallout4/index.php?title=MoveTo_-_ObjectReference
; There's a [General] INI setting called fMinPlayerMoveToDistForLoadScreen which defines the minimum distance to call for a loadscreen.
; PathToReference: https://www.creationkit.com/fallout4/index.php?title=PathToReference_-_Actor (latent-suspends script)
;
Function MoveActorToBed(Actor akActor, ObjectReference akBed)
	
	DTDebug(" move actor " + akActor + " to bed " + akBed, 2)
	
	if (akActor == PlayerRef)
		
		Utility.Wait(0.3)
		; even with a fade-to-black the MoveTo forces a load screen
		akActor.MoveTo(akBed)
		
		StartTimer(1.0, FadeInTimerID)
	else
		
		;akActor.PathToReference(akBed, 0.7)  ; suspends script
		akActor.FollowerWait()
		Utility.Wait(0.2)
		akActor.MoveTo(akBed)
		Utility.Wait(0.1)
		
		akBed.Activate(akActor)
		
	endIf
	
EndFunction

int Function ModPlayerCommentsDisable()
	
	; note: the PCHT global and PHT global work differently and PHT needs not start/stop quest
	if ((DTSConditionals as DTSleep_Conditionals).IsPlayerCommentsActive && !(DTSConditionals as DTSleep_Conditionals).ModPlayerCommentsDisabled)
		
		if ((DTSConditionals as DTSleep_Conditionals).ModPlayerCommentsGlobDisabled != None)
			GlobalVariable pcGV = (DTSConditionals as DTSleep_Conditionals).ModPlayerCommentsGlobDisabled
			
			if (pcGV != None)
				Quest pcQuest = ModGetPlayerCommentsQuest()
				int pcDisVal = pcGV.GetValueInt()

				if (pcQuest != None && pcDisVal < 1)
					DTDebug(" disable PCHT ", 2)

					(DTSConditionals as DTSleep_Conditionals).ModPlayerCommentsDisabled = true
					
					DisablePlayerControlsSleep(-1)
					DTSleep_ModPlayerCommentOffMsg.Show()
					
					pcQuest.Stop()
					PlayerRef.ClearLookAt()
					ModPlayerCommentSetGlobals(1.0)
					Utility.Wait(2.25)
					DisablePlayerControlsSleep()
					return 2
				else
					(DTSConditionals as DTSleep_Conditionals).ModPlayerCommentsDisabled = true
					DisablePlayerControlsSleep(-1)
					DTSleep_ModPlayerCommentOffMsg.Show()
					pcGV.SetValueInt(0)
					PlayerRef.ClearLookAt()
					Utility.Wait(1.2)
					DisablePlayerControlsSleep()
					return 1
				endIf
			endIf
		else
			DTDebug(" PCHT global is None!!", 1)
		endIf
	endIf
	
	return 0
endFunction

int Function ModPlayerCommentsEnable()
	; note: the PCHT global and PHT global work differently and PHT needs not start/stop quest
	if ((DTSConditionals as DTSleep_Conditionals).ModPlayerCommentsDisabled)
		Quest pcQuest = ModGetPlayerCommentsQuest()
		(DTSConditionals as DTSleep_Conditionals).ModPlayerCommentsDisabled = false
		if (pcQuest != None)
			if (!pcQuest.IsRunning())
				DTDebug("enable PCHT quest...", 2)
				
				PlayerRef.ClearLookAt()
				ModPlayerCommentSetGlobals(0.0)
				pcQuest.SetStage(0)
			endIf
		else
			GlobalVariable pcGV = (DTSConditionals as DTSleep_Conditionals).ModPlayerCommentsGlobDisabled
			pcGV.SetValueInt(1)
		endIf
		
		DTSleep_ModPlayerCommentOnMsg.Show()
		Utility.Wait(1.1)
		
		return 2
	endIf
	
	return 0
endFunction

Function ModPlayerCommentSetGlobals(float val)
	GlobalVariable pcGV = (DTSConditionals as DTSleep_Conditionals).ModPlayerCommentsGlobDisabled
	pcGV.SetValue(val)
	GlobalVariable pcudVar = (DTSConditionals as DTSleep_Conditionals).ModPlayerCommentsGlobMisc
	if (pcudVar == None)
		pcudVar = Game.GetFormFromFile(0x0920D107, "PlayerComments.esp") as GlobalVariable
		(DTSConditionals as DTSleep_Conditionals).ModPlayerCommentsGlobMisc = pcudVar
	endIf
	if (val == 1)
		val = -1
	endIf
	pcudVar.SetValue(val)
endFunction

Quest Function ModGetPlayerCommentsQuest()
	Quest pcQ = (DTSConditionals as DTSleep_Conditionals).ModPlayerCommentsQuest
	if (pcQ == None)
		pcQ = Game.GetFormFromFile(0x09000F99, "PlayerComments.esp") as Quest
		(DTSConditionals as DTSleep_Conditionals).ModPlayerCommentsQuest = pcQ
	endIf
	DTDebug(" PCHT get Quest " + pcQ, 2)
	return pcQ
endFunction

bool Function OkaySitOnSeat(ObjectReference akFurniture, Form furnBaseForm = None)

	if (akFurniture == None)
		return false
	endIf
	bool okayToSit = true
	if (furnBaseForm == None)
		furnBaseForm = akFurniture.GetBaseObject()
	endIf
	if ((DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).IsObjBenchSofa(akFurniture, furnBaseForm))
		if (akFurniture.IsFurnitureMarkerInUse(0, true) && akFurniture.IsFurnitureMarkerInUse(1, true))
			okayToSit = false
		endIf
	else
		okayToSit = false
	endIf

	return okayToSit
endFunction

; to catch areas not easily identified as blocked beds and may still need bed for intimacy
bool Function OkayToSleepLocationBed(ObjectReference aBedRef)
	Location curLoc = (SleepPlayerAlias as DTSleep_PlayerAliasScript).CurrentLocation
	if ((DTSConditionals as DTSleep_Conditionals).LocTourFHGHotelIndex > 0)
		if (curLoc == DTSleep_IntimateTourLocList.GetAt((DTSConditionals as DTSleep_Conditionals).LocTourFHGHotelIndex))
			; tour Grand Harbor only bed has corpse on it
			if (!aBedRef.HasKeyword(AnimFurnFloorBedAnims))
				return false
			endIf
		endIf
	endIf

	return true
endFunction

; the urge determined by how long it's been since sex and at night
; max is 96 at 7 days and during day no more than 5
; score after 3 days at night: 48
;
int Function PlayerFriskyScore(float gameTime)

	if (DTSleep_IntimateEXP.GetValue() <= 4.0)
		return -1
	elseIf (DTSleep_SettingIntimate.GetValue() <= 0.0 || DTSleep_SettingUndress.GetValue() < 0.0)
		return -2
	endIf
	
	int result = 0
	
	if (IsAdultAnimationAvailable())
	
		float daysSinceLastIntimate = gameTime - IntimateLastTime
		
		if (daysSinceLastIntimate > 0.99 && daysSinceLastIntimate < 32.0)
		
			result = ChanceForIntimateSceneByLastTime(4, gameTime, false, false)
			if (result < 1)
				return 0
			endIf
			
			float hourOfDay = DTSleep_CommonF.GetGameTimeCurrentHourOfDayFromCurrentTime(gameTime)
			
			if (hourOfDay >= 19.0 || hourOfDay < 5.0)
				if (DressData.PlayerGender == 0)
					result = result * 3
				else
					result = result * 2
				endIf
			elseIf (result > 9)
				result = 9
			endIf
			
			int exp = DTSleep_IntimateEXP.GetValueInt()
			if (exp > 120)
				result = result * 4
			elseIf (exp >= 60)
				result = result * 3
			elseIf (exp >= 20)
				result = result * 2
			endIf
		endIf
	else
		; do we want score for dancing intimacy?
		result = -10
	endIf
	
	return result 
endFunction

int ReRacecheck = 50					; v2.60 - in case player changes race mid-game

bool Function PlayerIntimateCompatible()
	; v2.60 check race if using NanaRace but still human in case added later
	if ((DTSConditionals as DTSleep_Conditionals).PlayerRace == None || ReRacecheck >= 50 || ((DTSConditionals as DTSleep_Conditionals).NanaRace != None && (DTSConditionals as DTSleep_Conditionals).PlayerRace == HumanRace))
		ReRacecheck = 0
		ActorBase playerBase = (PlayerRef.GetBaseObject() as ActorBase)
		if (playerBase != None)
			Race playerR = playerBase.GetRace()
			DTDebug("set player race to " + playerR, 1)
			(DTSConditionals as DTSleep_Conditionals).PlayerRace = playerR
		endIf
	endIf
	
	ReRacecheck += 1
	int intimateSetting = DTSleep_SettingIntimate.GetValueInt()
	
	; v2.60 - only check for adult animations, otherwise limit to embrace anyway
	if (intimateSetting >= 1 && IsAdultAnimationAvailable())
		
		if (intimateSetting <= 2)				; v2.60 increasing over default (3 or 4) forces XOXO mode
			if (PlayerRef.IsChild())
				Debug.Trace(myScriptName + " ***** player is child! - fail intimate-compatible check *****")
				return false
			endIf
		
			Race pr = (DTSConditionals as DTSleep_Conditionals).PlayerRace
			
			if (pr != None && (pr == HumanRace || pr == GhoulRace))
				
				return true
				
			elseIf (pr == SynthGen2RaceValentine)
				; is even a thing?
				if ((DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).GetGenderForActor(PlayerRef) == 0)
					SceneData.MaleBodySwapEnabled = 0
				endIf
				return true
				
			elseIf ((DTSConditionals as DTSleep_Conditionals).IsVulpineRacePlayerActive)
				
				if ((DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).GetGenderForActor(PlayerRef) == 0)
					SceneData.MaleBodySwapEnabled = 0
				endIf
				return true
				
			; v2.60
			elseIf (pr != None && pr == ((DTSConditionals as DTSleep_Conditionals).NanaRace || pr == (DTSConditionals as DTSleep_Conditionals).NanaRace2))
				; no sex animations per mod permission restrictions
				Debug.Trace(myScriptName + "player AnimeRace intimate-incompatible! " + pr)
				return false
			endIf
			
			Debug.Trace(myScriptName + "player race unknown - intimate-incompatible! " + pr)
		else
			DTDebug("PlayerIntimateCompatible false -- Intimate Setting (" + intimateSetting + ") forced XOXO", 1)
		endIf
	endIf
	
	return false
endFunction

Function PlayerKilledActor(Actor akActor)
	if (PlayerRef.IsInFaction(DTSleep_MutantAllyFaction))
		if (akActor.HasKeyword(ActorTypeSuperMutant) || akActor.HasKeyword(ActorTypeSuperMutantBehemothKY))
		
			DTSleep_RemoveMutantAllySpell.Cast(PlayerRef, PlayerRef)
		endIf
	endIf
endFunction

;
; current - gradual increase with EXP and varies by charisma, clothing, alcohol, addiction
;	creatureType 0 = human, see constants for Dog or Strong
;
;   range: -159 (8 addictions) to 180 (19 CHA)
;  time: 0.18 - 0.20
;
int Function PlayerSexAppeal(bool isNaked, int companionGender, int creatureType = 0)
	int result = 0
	int addictCount = (PlayerRef.GetValue(AddictionCountAV) as int)
	int exp = IntimacySceneCount
	
	if (creatureType == CreatureTypeDog)
		; for human experience grant a small bonus
		if (exp >= 96)
			exp = 16
		elseIf (exp > 9)
			exp = Math.Floor(exp * 0.166667)
		else
			exp = 0
		endIf
		exp += IntimacyDogCount
		
		
	elseIf (creatureType == CreatureTypeStrong || creatureType == CreatureTypeBehemoth)
		; for human experience grant a small bonus
		if (exp >= 120)
			exp = 10
		elseIf (exp > 9)
			exp = Math.Floor(exp * 0.083333)
		else
			exp = 0
		endIf
		exp += IntimacySMCount
		
	endIf
	
	if (exp > 0)
		if (exp >= 5000)
			result = 200
		elseIf (exp >= 2500)
			result = 190
		elseIf (exp >= 1000)
			result = 178
		elseIf (exp > 100)
			result = (64.0 + ((exp - 98) * 0.1250)) as int
			
		elseIf (exp == 100)
			result = 64
		elseIf (exp > 64)  ; 50
			result = (50.0 + ((exp - 62) * 0.368421)) as int

		elseIf (exp > 20)   ; 28
			result = (17.5 + (0.50 * exp)) as int
			
		elseIf (exp >= 4)  
			result = 7 + exp
		elseIf (exp == 3)
			result = 9
		else
			result += (exp * 3)
		endIf
		
	endIf
	
	int gDiff = Game.GetDifficulty()
	if (gDiff >= 6)
	
		if (PlayerRef.HasMagicEffect(HC_Disease_Infection_DamagePlayer_Effect))
			DTDebug(" Sex Appeal penalty -- too sick! ", 2)
			
			result -= 72
		
		elseIf (PlayerRef.HasMagicEffect(HC_Disease_Fatigue_Effect))
			DTDebug(" Sex Appeal penalty -- too tired! ", 2)
			result -= 24
		elseIf (PlayerRef.HasMagicEffect(HC_Disease_NeedMoreFood_Effect))
			result -= 12
		endIf
	else
		result -= 8  ; adjust for non-survival
	endIf
	
	; level-base for life experience 
	int playerLevel = PlayerRef.GetLevel()
	int levelChance = 0
	
	; v2 - player level bonus for having experienced the Commonwealth
	if (playerLevel >= 64)
		levelChance = 32
	elseIf (playerLevel >= 2 && playerLevel < 4)
		levelChance = 1
	elseIf (playerLevel >= 4)
		levelChance = playerLevel / 2
	endIf
	
	result += levelChance
	
	; charisma - alcohol takes precedence which may hurt if charisma > 9
	
	; charisma of 7 is +7 no matter exp: ((charisma * charismaFactor) - charismaAdj)
	int charismaScore = 0
	int charismaFactor = 4    
	int charismaAdj = 21
	float charismaScale = 1.0
	int charisma = (PlayerRef.GetValue(CharismaAV) as int)
	if (charisma > 30)
		charisma = 30
	endIf
	
	if (charisma > 7)
		; above pivot then scale down bonus with exp or creature
		if (creatureType == 0)
			if (exp > 5 && exp < 40)
				charismaScale = (120.0 - exp as float) / 120.0
			elseIf (exp >= 40)
				; about 60-64%
				charismaFactor = 2
				charismaAdj = 7
			endIf

		else
			charismaFactor = 2
			charismaAdj = 7
		endIf
	endIf
	
	bool isIntoxicated = false
	
	if (PlayerRef.HasMagicEffectWithKeyword(AlcoholEffectKY))
	
		isIntoxicated = true
		charismaScore = 10 + charismaFactor
		
		if (creatureType == CreatureTypeDog)
			; compensate for penalty and +4 over human
			charismaScore += 8
			
		elseIf (creatureType == CreatureTypeStrong || creatureType == CreatureTypeBehemoth)
			; after penalty +2 compared to human
			charismaScore += 5
		endIf
		
	elseIf (PlayerRef.HasMagicEffect(abReduceEnduranceME))
		charismaScore = -6
		
	else
		; calculate charisma score based on charisma
		;
		; charisma of  5 and 6 considered normal -1 and +3
		; charisma of  7 always +7 no matter exp
		; charisma of  9: +15 to +10
		; charisma of 14: +35 to +21  - grape mentats helps more at low exp
		
		charismaScore = ((charisma * charismaFactor) - charismaAdj)
		if (charismaScale < 1.0)
			charismaScore = (charismaScore * charismaScale) as int
		endIf
	endIf
	
	result += charismaScore
	
	; ---- addictions ------
	if (addictCount > 0)
	
		if (creatureType == 0 && addictCount > 1)
			result = result - ((addictCount - 1) * 14) + 7	; half for first
		else
			result -= (addictCount * 7)
		endIf
	endIf
	
	int playerSex = DressData.PlayerGender
	if (playerSex < 0)
		playerSex = (PlayerRef.GetBaseObject() as ActorBase).GetSex()
		DressData.PlayerGender = playerSex
	endIf
	
	; LadyKiller / BlackWidow
	int charismaPerkLevel = SceneData.LkbwLevel
	
	; v1.25 - support gender-swapped perks - init for existing
	if ((DTSConditionals as DTSleep_Conditionals).HasGenderSwappedPerks < 0)
		if (charismaPerkLevel == 3)
			; double-check
			if (playerSex == 1 && PlayerRef.HasPerk(BlackWidow03))
				(DTSConditionals as DTSleep_Conditionals).HasGenderSwappedPerks = 0
			elseIf (playerSex == 0 && PlayerRef.HasPerk(LadyKiller03))
				(DTSConditionals as DTSleep_Conditionals).HasGenderSwappedPerks = 0
			else
				; reset
				charismaPerkLevel = 1
			endIf
		endIf
	endIf
	
	if (charismaPerkLevel < 3)
	
		; performance: short-circuit to reduce perk checks
		
		if ((DTSConditionals as DTSleep_Conditionals).HasGenderSwappedPerks < 0)
		
			if (PlayerRef.HasPerk(LadyKiller01))
				
				if (playerSex == 0)
					(DTSConditionals as DTSleep_Conditionals).HasGenderSwappedPerks = 0
				else
					(DTSConditionals as DTSleep_Conditionals).HasGenderSwappedPerks = 1
				endIf
				if (charismaPerkLevel >= 1 && PlayerRef.HasPerk(LadyKiller03))
					SceneData.LkbwLevel = 3  ; record for performance
					charismaPerkLevel = 3
				else
					SceneData.LkbwLevel = 1  ; record for performance
					charismaPerkLevel = 1
				endIf
				
			elseIf (PlayerRef.HasPerk(BlackWidow01))
				if (playerSex == 1)
					(DTSConditionals as DTSleep_Conditionals).HasGenderSwappedPerks = 0
				else
					(DTSConditionals as DTSleep_Conditionals).HasGenderSwappedPerks = 1
				endIf
				if (charismaPerkLevel >= 1 && PlayerRef.HasPerk(BlackWidow03))
					SceneData.LkbwLevel = 3  ; record for performance
					charismaPerkLevel = 3
				else
					SceneData.LkbwLevel = 1  ; record for performance
					charismaPerkLevel = 1
				endIf
			endIf
		elseIf (playerSex == 0 && (DTSConditionals as DTSleep_Conditionals).HasGenderSwappedPerks == 0)
		
			if (PlayerRef.HasPerk(LadyKiller03))
				SceneData.LkbwLevel = 3  ; record for performance
				charismaPerkLevel = 3
			endIf
		elseIf (playerSex == 1 && (DTSConditionals as DTSleep_Conditionals).HasGenderSwappedPerks == 1)
		
			if (PlayerRef.HasPerk(LadyKiller03))
				SceneData.LkbwLevel = 3  ; record for performance
				charismaPerkLevel = 3
			endIf
			
		elseIf (PlayerRef.HasPerk(BlackWidow03))
			SceneData.LkbwLevel = 3  ; record for performance
			charismaPerkLevel = 3
		endIf
	endIf
	
	if (companionGender >= 0)
		if (companionGender != playerSex && (DTSConditionals as DTSleep_Conditionals).HasGenderSwappedPerks == 0)
			
			if (creatureType != CreatureTypeDog)
				; for Strong penalty reduces effectiveness to 2/3 so considered okay
				if (charismaPerkLevel >= 3)

					if (playerSex == 1)
						result += 28
					else
						result += 22
					endIf
					
				elseIf (charismaPerkLevel >= 1)

					result += 8
				endIf
			endIf
		elseIf ((DTSConditionals as DTSleep_Conditionals).HasGenderSwappedPerks == 1)
		
			if (charismaPerkLevel >= 3)

					if (playerSex == 1)
						result += 24
					else
						result += 18
					endIf
					
				elseIf (charismaPerkLevel >= 1)

					result += 7
				endIf
			
		elseIf (companionGender == playerSex)
			result -= 12  ; minor adjustment for social stigma
		endIf
	endIf
	
	; bribes
	int playerHasBribeType = 0
	
	; creatures get their own bribe award: rank increase
	if (creatureType == 0 && SceneData.CompanionBribeType > 0 && SceneData.CompanionBribeType != IntimateBribeNaked)
	
		if (PlayerHasTreatsBribe(SceneData.CompanionBribeType))
			playerHasBribeType = SceneData.CompanionBribeType
			result += 8
		else
			SceneData.CompanionBribeType = -1   ; cancel
			result -= 4
		endIf
		
	elseIf (creatureType == CreatureTypeDog)
		; only super treat improves chances since all treats improve rank
		if (PlayerHasDogTreatsSuper(false))
			playerHasBribeType == IntimateBribeTypeDogTreat
			result += 20
		endIf
	endIf
	
	if (playerSex > 0)
		; women get a small jewelry bonus
		if (DressData.PlayerEquippedNecklaceItem)
			result += 2
		endIf
		if (DressData.PlayerEquippedChokerItem)
			result += 4
		endIf
	endIf

	if (DTSleep_MagnoliaScene.GetValue() >= 1.0)
		; completed Magnolia "date"
		result += 16
	endIf
	
	int clothBonus = 0
	
	if (creatureType == 0 && DressData.PlayerEquippedSleepwearItem)
		; sleepwear improves charisma, +2 for bathrobe (+8 charismaScore) - lacy/sporty underwear does not unless player edited
		clothBonus = 11
		
	elseIf (creatureType == 0 && DressData.PlayerEquippedSlot58IsSleepwear || DressData.PlayerEquippedSlotFXIsSleepwear)
		clothBonus = 14
		
	elseIf (creatureType == 0 && DressData.PlayerEquippedIntimateAttireItem != None)
		
		clothBonus = 18
		
	elseIf (creatureType == 0 && DressData.PlayerHasSexyOutfitEquipped)
	
		clothBonus = 8
		
	elseIf (isNaked)
		
		if (SceneData.CompanionBribeType == IntimateBribeNaked)
			; bribe
			playerHasBribeType = IntimateBribeNaked
			
			if (creatureType == CreatureTypeStrong || creatureType == CreatureTypeBehemoth)
				clothBonus = 32
			else
				clothBonus = 20
			endIf
		else
			; regular 
			if (playerSex > 0)
			
				if (creatureType == CreatureTypeStrong || creatureType == CreatureTypeBehemoth)
					if (isIntoxicated)
						clothBonus = 16
					else
						clothBonus = 28
					endIf
					
				elseIf (isIntoxicated)
					clothBonus = 8
					
				elseIf (creatureType == CreatureTypeDog)
					clothBonus = 12
					
				elseIf (charisma > 3)	
					clothBonus = 12
				else
					clothBonus = 5
				endIf
			else
				clothBonus = 8
			endIf
		endIf
	endIf
	
	result += clothBonus
	
	if (SceneData.CompanionBribeType == IntimateBribeNaked)
		if (playerHasBribeType != IntimateBribeNaked)
		
			; penalty for those prefer naked and not naked
			result -= 8
		endIf
	endIf
	
	int restPerkBonus = 0
	if (PlayerRef.HasPerk(DTSleep_LoversEmbracePerk))
		restPerkBonus = 20
		result += restPerkBonus
	elseIf (SceneData.IsCreatureType == CreatureTypeStrong && PlayerRef.HasPerk(DTSleep_LoverStrongBonusPerk))
		restPerkBonus = 18				; v2.35
		result += restPerkBonus
	endIf
	if (PlayerRef.HasPerk(DTSleep_LoversEmbraceHugPerk) || PlayerRef.HasPerk(DTSleep_LoversSexyPerk))
		result += 16
		restPerkBonus += 16
	endIf
	
	; v2.35
	if (PlayerRef.IsInFaction(DTSleep_MutantAllyFaction))
		if (SceneData.IsCreatureType == CreatureTypeStrong)
			result += 20
			restPerkBonus += 20
		elseIf (SceneData.IsCreatureType == CreatureTypeBehemoth)
			result += 7
			restPerkBonus += 7
		else
			result -= 12
			restPerkBonus -= 12
		endIf
	endIf
	
	if (DTSleep_SettingTestMode.GetValue() > 0.0 && DTSleep_DebugMode.GetValue() >= 2.0)
		Debug.Trace(myScriptName + " -------------------------------------------")
		Debug.Trace(myScriptName + " Test-Mode output - may disable in Settings ")
		Debug.Trace(myScriptName + " -------------------------------------------")
		Debug.Trace(myScriptName + "  Sex Appeal gender " + playerSex + " intoxicated? " + isIntoxicated)
		Debug.Trace(myScriptName + "   game difficulty : " + gDiff)
		Debug.Trace(myScriptName + "       level bonus : " + levelChance)
		Debug.Trace(myScriptName + "   creature type   : " + creatureType)
		Debug.Trace(myScriptName + "   LadyKill/BlackW : " + charismaPerkLevel)
		Debug.Trace(myScriptName + "   addiction count : " + addictCount)
		Debug.Trace(myScriptName + "   player bribe    : " + playerHasBribeType)
		Debug.Trace(myScriptName + " sleepw/sexy/naked : " + clothBonus)
		Debug.Trace(myScriptName + "           rest/hug: " + restPerkBonus)
		Debug.Trace(myScriptName + "   charisma score  : " + charismaScore)
		Debug.Trace(myScriptName + "   Intimate EXP    : " + exp + " (base: " + DTSleep_IntimateEXP.GetValueInt() + ")")
		Debug.Trace(myScriptName + " ---------------------")
		Debug.Trace(myScriptName + "      Sex Appeal   : " + result)
		Debug.Trace(myScriptName + " ----------------------------------------")
	endIf
	
	return result
endFunction

Function PlayerDiseaseCheckSTD(int creatureType)

	if (self.MessageOnWakeID <= 0 && HC_Rule_DiseaseEffects.GetValue() == 1.0 && SceneData.CurrentLoverScenCount < 9)
		
		int chanceDisease = 43	; 14% chance
		if (PlayerRef.HasMagicEffect(HC_Herbal_Antimicrobial_Effect))
			chanceDisease = 47	; 6% chance
		elseIf (SceneData.CurrentLoverScenCount > 3)
			chanceDisease += 2
		elseIf (SceneData.CurrentLoverScenCount <= 1)
			chanceDisease -= 1
		endIf
		
		if (creatureType == CreatureTypeDog)
			chanceDisease += 4
		elseIf (creatureType == CreatureTypeStrong || creatureType == CreatureTypeBehemoth)
			chanceDisease -= 2
		elseIf (creatureType == CreatureTypeSynth || creatureType == CreatureTypeHandy)
			return
		endIf
		
		int randRoll = Utility.RandomInt(0, 49)
		if (randRoll >= chanceDisease)
			self.MessageOnWakeID = OnWakeMsgDiseaseInfectionSTD
		endIf
	endIf

endFunction

bool Function PlayerHasDogTreatsSuper(bool spend = false)

	return PlayerHasTreatsOnList(DTSleep_DogSuperTreatsList, spend)
endFunction

bool Function PlayerHasDogTreats(bool spend = false)

	return PlayerHasTreatsOnList(DTSleep_DogTreatsList, spend)
	
endFunction

bool Function PlayerHasMutantTreats(bool spend = false)

	return PlayerHasTreatsOnList(DTSleep_MutantTreatsList, spend)

endFunction

bool Function PlayerHasTreatsForCreature(int creatureType, int treatType = 0)

	bool spend = false 
	if (treatType > 0)
		spend = true
	endIf
	
	if (creatureType == CreatureTypeDog)
		if (PlayerHasDogTreatsSuper(spend))
			return true
		endIf
		return PlayerHasDogTreats(spend)
		
	elseIf (creatureType == CreatureTypeStrong)
		return PlayerHasMutantTreats(spend)
	else
		return PlayerHasTreatsBribe(treatType, spend)
	endIf
	
	return false
endFunction

bool Function PlayerHasTreatsBribe(int bribeType, bool spend = false)

	if (bribeType == IntimateBribeTypeBooze)
		return PlayerHasTreatsOnList(DTSleep_BoozeTreatsList, spend)
	elseIf (bribeType == IntimateBribeTypeCandy)
		return PlayerHasTreatsOnList(DTSleep_CandyTreatsList, spend)
	elseIf (bribeType == IntimateBribeTypeDogTreat)
		if (PlayerHasDogTreatsSuper(spend))
			return true 
		endIf
		return PlayerHasDogTreats(spend)
		
	elseIf (bribeType == IntimateBribeTypeMeat)
		return PlayerHasMutantTreats(spend)
	elseIf (bribeType == IntimateBribeTypeMutfruit)
		return PlayerHasTreatsOnList(DTSleep_MutfruitList, spend)
	endIf
	
	return false
endFunction

bool Function PlayerHasTreatsOnList(FormList treatsList, bool spend = false)

	if (treatsList != None)
		
		int len = treatsList.GetSize()
		int index = 0
		
		while (index < len)
			
			Form treatForm = treatsList.GetAt(index)
			if (treatForm != None && PlayerRef.GetItemCount(treatForm) > 0)
				
				if (spend)
					PlayerRef.RemoveItem(treatForm)
					Utility.Wait(0.5)
				endIf
				
				return true
			endIf
			
			index += 1
		endWhile
	
	endIf
	
	return false

endFunction

; only called when healthrecoverquest timer expires or caught interruptedEvent and still in bed
; or v2.35 MCM hotkey
;
Function PlayerSleepAwake(bool doneSleep)

	if (SleepBedInUseRef != None && DTSleep_PlayerUsingBed.GetValue() > 0.0)
		; stop recovery quest
		if (DTSleep_HealthRecoverQuestP.IsRunning())
			if (doneSleep)
				(DTSleep_HealthRecoverQuestP as DTSleep_HealthRecoverQuestScript).StopAllDone(!SleepBedInUseRef.HasKeyword(AnimFurnFloorBedAnims))
				
			else
				(DTSleep_HealthRecoverQuestP as DTSleep_HealthRecoverQuestScript).StopAllCancel()
			endIf
			Utility.Wait(0.1)
		endIf
		
		SleepBedInUseRef.Activate(PlayerRef)
	endIf
endFunction


Function PlayerSleepPerkAdd()
	
	if (DTSleep_SettingModActive.GetValue() > 0.0)
	
		if (!PlayerRef.HasPerk(DTSleep_PlayerSleepBedPerk))
			PlayerRef.AddPerk(DTSleep_PlayerSleepBedPerk)
		endIf
		
		self.RegisterForRemoteEvent(DTSleep_PlayerSleepBedPerk, "OnEntryRun")
	endIf
	
EndFunction

Function PlayerSleepPerkRemove()

	self.UnregisterForRemoteEvent(DTSleep_PlayerSleepBedPerk, "OnEntryRun")
	
	if (PlayerRef.HasPerk(DTSleep_PlayerSleepBedPerk))
		PlayerRef.RemovePerk(DTSleep_PlayerSleepBedPerk)
	endIf
EndFunction

Function PlayerSwapHolotapes()

	Utility.WaitMenuMode(0.05)
	int sort = DTSleep_SettingSortHolotape.GetValueInt()
	Holotape tapeOld = DTSleep_OptionsHolotape2
	Holotape tapeNew = DTSleep_OptionsHolotape
	if (sort > 0)
		tapeNew = DTSleep_OptionsHolotape2
		tapeOld = DTSleep_OptionsHolotape
	endIf
	int count = PlayerRef.GetItemCount(tapeOld as Form)
	if (count > 0)
		PlayerRef.RemoveItem(tapeOld as Form, count, true)
		PlayerRef.AddItem(tapeNew, 1, true)
	endIf

EndFunction

Function PlayPickSpotTimer(int pickType = 0)

	PlayerSleepPerkRemove()
	EnablePlayerControlsSleep()
	Utility.Wait(0.08)
	DisablePlayerControlsSleep(3)	; move and look only
	Utility.Wait(0.3)
	
	int countDown = 4
	if (DTSleep_SettingNotifications.GetValue() > 0.0)
		countDown = 3
		
		if (pickType == 8)
			DTSleep_PickPositionViewKitchenCtrMsg.Show()
		elseIf (pickType == 10)
			DTSleep_PickPositionViewRailingMsg.Show()				; v2.70
		elseIf (pickType == 4)
			DTSleep_PickPositionViewShowerMsg.Show()
		elseIf (pickType == 1)
			DTSleep_PickPositionViewMsg.Show()
		elseIf (pickType == 2)
			countDown = 2
			DTSleep_PickPositionStepBackMsg.Show()
		else
			DTSleep_PickPositionMsg.Show()
		endIf

		Utility.Wait(1.333)
	endIf
	
	while (countDown > 0)
		
		Utility.Wait(1.333)
		DTSleep_CountMessage.Show(countDown)
		countDown -= 1
	endWhile
	
	Utility.Wait(1.3)
	
	PlayerSleepPerkAdd()
	Utility.Wait(0.1)
EndFunction

Function PlayPostSleepCelebration()
	if (DTSleep_IntimateAnimQuestP && IntimateCompanionRef)
		
		if (!DTSleep_IntimateAnimQuestP.IsRunning())
			DTSleep_IntimateAnimQuestP.Start()
		endIf
		RegisterForCustomEvent((DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript), "IntimateSequenceDoneEvent")
		
		(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).StartForActorsAndBed(PlayerRef, IntimateCompanionRef, None, false)

		if ((DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).PlayActionReactionRand())
			; TODO: do nothing?
		else
			UnregisterForCustomEvent((DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript), "IntimateSequenceDoneEvent")
		endIf
	endIf
EndFunction

Function ProcessCompatibleMods(bool showMsg = true)

	int sysCWActiveVal = DTSleep_IsSYSCWActive.GetValueInt()
	
	if (sysCWActiveVal > 0.0 && DTSleep_SettingPrefSYSC.GetValue() < 0.0)
		Utility.Wait(2.0)
		if (ModSYSleepDisable() > 0 && showMsg)
			Utility.Wait(0.5)
			DTSleep_SeeYouSleepModFoundMessage.Show()
		endIf
		
	elseIf (sysCWActiveVal == -2)
		; removed
		DTSleep_SettingPrefSYSC.SetValue(-2.0)
		DTSleep_IsSYSCWActive.SetValue(-12.0)
	endIf
	
	if (DTSleep_IsSoSActive.GetValue() >= 3.0)
		
		if (DTSleep_ModSoSActiveMessage.Show() > 0)
			Utility.Wait(0.4)
			ModSetSaveOrSleepToggle()
		endIf
	endIf
	
	int nnesActiveVal = DTSleep_IsNNESActive.GetValueInt()
	
	if (nnesActiveVal >= 1.0)						; always toggle if initialized v3.004
		Utility.WaitMenuMode(0.4)
		ModSetNNESToggle()
	endIf
	
	if ((DTSConditionals as DTSleep_Conditionals).IsPlayerCommentsActive)
		if (!(DTSConditionals as DTSleep_Conditionals).ModPlayerCommentWarnShown)
			(DTSConditionals as DTSleep_Conditionals).ModPlayerCommentWarnShown = true
			DTSleep_ModPlayerCommentRemindMsg.Show()
			
			Utility.Wait(0.2)
		endIf
	endIf
	
	if ((DTSConditionals as DTSleep_Conditionals).ITPCCactiveLevel == 1)
		
		DTSleep_SettingCamera2.SetValue(0.0)
		(DTSConditionals as DTSleep_Conditionals).ITPCCactiveLevel = 2
	endIf
	
	if (DTSleep_SettingChairsEnabled.GetValue() <= -1.0)
		SetSettingsChairActivDefault()
	endIf
	
	if (DTSleep_SettingAAF.GetValue() < 0.0)
		; init to disabled if have AAF otherwise leave hidden
		if ((DTSConditionals as DTSleep_Conditionals).IsAAFActive && (DTSConditionals as DTSleep_Conditionals).IsF4SE)
			DTSleep_SettingAAF.SetValue(0.0)
		endIf
	endIf
	
	if (DTSleep_AdultContentOn.GetValue() >= 2.0 && (DTSConditionals as DTSleep_Conditionals).ImaPCMod && TestVersion == -2)
		Race pRace = (DTSConditionals as DTSleep_Conditionals).PlayerRace
		if (pRace == None)
			ActorBase playerBase = (PlayerRef.GetBaseObject() as ActorBase)
			if (playerBase != None)
				pRace = playerBase.GetRace()
				(DTSConditionals as DTSleep_Conditionals).PlayerRace = pRace
			endIf
		endIf
		if (pRace != None) 
			if (pRace != (DTSConditionals as DTSleep_Conditionals).NanaRace && pRace != (DTSConditionals as DTSleep_Conditionals).NanaRace2)
				DTSleep_AdultOutfitOn.SetValue(2.0)
			else
				DTSleep_AdultOutfitOn.SetValue(1.0)
			endIf
		endIf
	elseIf (!(DTSConditionals as DTSleep_Conditionals).ImaPCMod)
		DTSleep_AdultOutfitOn.SetValue(0.0)
	endIf
	
	if (Game.IsPluginInstalled("Z_Horizon.esp"))
		(DTSleep_HealthRecoverQuestP as DTSleep_HealthRecoverQuestScript).DTSleep_SettingHealthRecover.SetValueInt(0)
		
	endIf
	
	; v2.60 check to reset
	if ((DTSConditionals as DTSleep_Conditionals).PlayerRace != None && (DTSConditionals as DTSleep_Conditionals).PlayerRace != HumanRace)
		(DTSConditionals as DTSleep_Conditionals).PlayerRace = None
	endIf

EndFunction

Function RedressCompanion()
	IsUndressReady = false
	if (SleepInputLayer != None)
		EnablePlayerControlsSleep()
	endIf
	
	SetUndressStop(false)
endFunction

Function RegisterForSleepWithBed(ObjectReference bedRef)
	DTDebug(" Registered for Sleep event with " + bedRef, 2)
	
	RegisterForPlayerSleep()
	SleepBedRegistered = bedRef
endFunction

; reset before moving player to bed acts as a cancel
Function ResetAll()

	if (DTSleep_PlayerUsingBed.GetValue() > 0.0 || DTSleep_CompSleepQuest.IsRunning())
		DTSleep_PlayerUsingBed.SetValue(0.0)			; needs to happen straight away for on-load -v2.16
		WakeStopCompQuest()
	endIf
	
	IsUndressReady = false
	DTSleep_PlayerUsingBed.SetValue(0.0)
	SleepBedIsPillowBed = false
	MyMenuCheckBusy = false
	MyPAGlitchMessageCount = 0
	
	UnregisterForPlayerSleep()
	
	if (DTSleep_TimeDayQuestP.IsRunning())
		(DTSleep_TimeDayQuestP as DTSleep_TimeDayQuestScript).StopAll()
	endIf
	
	if (SleepBedUsesBlock && SleepBedInUseRef)
		SleepBedInUseRef.BlockActivation(true)
	endIf
	if (DTSleep_HealthRecoverQuestP.IsRunning())
		(DTSleep_HealthRecoverQuestP as DTSleep_HealthRecoverQuestScript).StopAllCancel()
		
	elseIf ((DTSleep_HealthRecoverQuestP as DTSleep_HealthRecoverQuestScript).DTSleep_SettingFastSleepEffect.GetValueInt() > 0)
		(DTSleep_HealthRecoverQuestP as DTSleep_HealthRecoverQuestScript).FastSleepEffectOff()
	endIf
	
	CancelTimerGameTime(SleepNapLimitGameTimerID)
	

	(DTSleep_EncounterQuestP as DTSleep_EncounterQuest).StopAll()
	
	SleepBedUsesBlock = false
	if (SleepBedInUseRef != None)
		UnregisterForRemoteEvent(SleepBedInUseRef, "OnActivate")
		SleepBedInUseRef = None
	endIf
	
	SleepBedCompanionUseRef = None
	if (SleepBedTwin != None)
		UnregisterForRemoteEvent(SleepBedTwin, "OnActivate")
		SleepBedTwin = None
	endIf
	; ensure game HUD available
	;Game.SetCharGenHUDMode(0)

	EnablePlayerControlsSleep()
	MainQSceneScriptP.GoSceneViewDone(false)

	
	if ((DTSConditionals as DTSleep_Conditionals).IsPlayerCommentsActive)
		ModPlayerCommentsEnable()
	endIf
	
	; just in case - re-register
	PlayerSleepPerkAdd()
	
	SetUndressStop(false)
	
	SetDogmeatFollow()
	
	RegisterForMenuOpenCloseEvent("WorkshopMenu")
	
	HandlePlayerFurnitureBusy = false
	PropActivatorLock = 0
	
	Utility.Wait(0.1)
	
	DTDebug("ResetAll Done", 2)

EndFunction

Function ResetHelpTips()

	PersuadeTutorialFailShown = 0
	TipSleepModeDisplayCount = 1
	PersuadeTutorialXFFShown = 0
	PersuadeTutorialSuccessShown = 0
	TipSleepModePromptVal = 1
	MyPAGlitchTipCount = 0						; added v2.75
	
	StartTimer(64.0, CustomCameraTipTimerID)
	StartTimer(200.0, IntroRestNotShowTipTimerID)

endFunction

Function ResetSceneData(bool includeRace)				; may not alays want to remove race info  v2.82 
	SceneData.BackupMaleRole = SceneData.MaleRole
	SceneData.BackupFemaleRole = SceneData.FemaleRole
	SceneData.BackupMaleRoleGender = SceneData.MaleRoleGender
	SceneData.BackupSameGender = SceneData.SameGender
	SceneData.BackupCurrentLoverScenCount = SceneData.CurrentLoverScenCount
	SceneData.MaleRole = None
	SceneData.MaleRoleGender = -1
	SceneData.FemaleRole = None
	SceneData.ToyArmor = None
	SceneData.HasToyAvailable = false
	SceneData.HasToyEquipped = false
	SceneData.ToyFromContainer = false
	SceneData.SameGender = false
	
	if (includeRace)
		SceneData.IsUsingCreature = false
		SceneData.IsCreatureType = 0
		SceneData.FemaleRaceHasTail = false
		SceneData.CompanionInPowerArmor = false
		SceneData.RaceRestricted = 0				; v2.60  - for companion only
	endIf
	SceneData.MaleRoleCompanionIndex = -1
	SceneData.CurrentLoverScenCount = 0
	SceneData.CompanionBribeType = 0
	SceneData.SecondFemaleRole = None
	SceneData.SecondMaleRole = None
	; do not reset LkbwLevel
	SceneData.MaleBodySwapEnabled = 1
	
	
endFunction

Function RestoreSceneData()
	SceneData.MaleRole = SceneData.BackupMaleRole
	SceneData.FemaleRole = SceneData.BackupFemaleRole
	SceneData.BackupMaleRole = None
	SceneData.BackupFemaleRole = None
	SceneData.MaleRoleGender = SceneData.BackupMaleRoleGender
	SceneData.SameGender = SceneData.BackupSameGender
	SceneData.CurrentLoverScenCount = SceneData.BackupCurrentLoverScenCount
	SceneData.CompanionBribeType = 0						; v2.35 reset
	SceneData.ToyArmor = None
	SceneData.HasToyAvailable = false
	SceneData.HasToyEquipped = false
	SceneData.ToyFromContainer = false
	SceneData.CompanionInPowerArmor = false
	SceneData.SecondFemaleRole = None
	SceneData.SecondMaleRole = None
	SceneData.MaleRoleCompanionIndex = -1
	SceneData.MaleBodySwapEnabled = 1
	SceneData.IsUsingCreature = false
	SceneData.IsCreatureType = 0
	
	; should not be necessary?  v2.35 restore all this anyway
	if (SceneData.MaleRole == StrongCompanionRef)			
		SceneData.IsUsingCreature = true
		SceneData.IsCreatureType = CreatureTypeStrong
		
	elseIf ((DTSConditionals as DTSleep_Conditionals).IsVulpineRacePlayerActive && SceneData.FemaleRole == PlayerRef)
		SceneData.FemaleRaceHasTail = true
	else
		Actor companionActor = None
		int companionGender = -1
		
		if (SceneData.MaleRole != PlayerRef)
			companionActor = SceneData.MaleRole
			companionGender = SceneData.MaleRoleGender
		else
			companionActor = SceneData.FemaleRole
			if (!SceneData.SameGender)
				companionGender = 1
			else
				companionGender = SceneData.MaleRoleGender
			endIf
		endIf
		
		if (companionActor != None)
			if (companionActor == CurieRef || companionActor == CompanionPiperRef || companionActor == CompanionCaitRef || companionActor == CompanionHancockRef || companionActor == CompanionDeaconRef || companionActor == CompanionMacCreadyRef || companionActor == (DTSConditionals as DTSleep_Conditionals).NukaWorldDLCGageRef || companionActor == (DTSConditionals as DTSleep_Conditionals).FarHarborDLCLongfellowRef)
				; v2.64 - all good
				SceneData.RaceRestricted = 0
			
			elseIf (companionActor == CompanionDanseRef)
				if (companionActor.WornHasKeyword(ArmorTypePower))
					SceneData.CompanionInPowerArmor = true
				endIf
				SceneData.RaceRestricted = 0				; v2.64
			elseIf (DogmeatCompanionAlias != None && PlayerHasActiveDogmeatCompanion.GetValueInt() >= 1 && companionActor == DogmeatCompanionAlias.GetActorReference())
				SceneData.IsUsingCreature = true
				SceneData.IsCreatureType = CreatureTypeDog
			else
				ActorBase compBase = (companionActor.GetLeveledActorBase() as ActorBase)
				
				if (compBase != None)
					Race compRace = compBase.GetRace()
					
					if ((DTSConditionals as DTSleep_Conditionals).IsVulpineRace != None && compRace == (DTSConditionals as DTSleep_Conditionals).IsVulpineRace)
						SceneData.RaceRestricted = 2
						
						if (companionGender == 1)
							SceneData.FemaleRaceHasTail = true
						else
							SceneData.MaleBodySwapEnabled = 0
						endIf
					elseIf (compRace == SynthGen2RaceValentine)
					
						; v2.82 re-order for easier reading
						SceneData.IsUsingCreature = true
						if (DTSleep_AdultContentOn.GetValue() >= 2.0 && DTSleep_SettingSynthHuman.GetValue() >= 1.0 && (DTSConditionals as DTSleep_Conditionals).ImaPCMod)
							SceneData.IsCreatureType = CreatureTypeSynthNude
						else
							SceneData.IsCreatureType = CreatureTypeSynth
							SceneData.RaceRestricted = 10				; v2.82 for hugOnly
						endIf
						
					elseIf (compRace == HumanRace || compRace == GhoulRace)
						; all good
						SceneData.RaceRestricted = 0
					elseIf ((DTSConditionals as DTSleep_Conditionals).NanaRace != None && (compRace == (DTSConditionals as DTSleep_Conditionals).NanaRace || compRace == (DTSConditionals as DTSleep_Conditionals).NanaRace2))
						; v2.60
						SceneData.RaceRestricted = 10
					else
						; v2.60 - unknown restricted
						SceneData.RaceRestricted = 13
					endIf
				endIf
			endIf
		endIf
		
		if (companionGender == 0)	
			if ((DTSConditionals as DTSleep_Conditionals).IsUniqueFollowerMaleActive)
				
				int armorIndex = (DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).GetCompanionLeitoArmorIndexPublic(companionActor)
				
				if (armorIndex >= 0)
					armorIndex += 1
					
					SceneData.MaleRoleCompanionIndex = armorIndex
				endIf
			endIf
		endIf
	endIf
	
	DTDebug(" Restored backup SceneData for couple (" + SceneData.MaleRole + ", " + SceneData.FemaleRole + ") to lover-count: " + SceneData.CurrentLoverScenCount, 1)
endFunction

Function ResetSceneOnLoad()
	Utility.Wait(1.0)
	
	DTDebug(" ResetSceneOnLoad..", 2)
	MainQSceneScriptP.GoSceneViewStart(1, true)		; player likely sleeping in bed--force forSleep true v3.02
	MyMenuCheckBusy = false
endFunction


bool Function SetDogmeatFollow()

	processingDogmeatWait = -5
	
	if (DogmeatCompanionAlias != None && PlayerHasActiveDogmeatCompanion.GetValueInt() >= 1)
		
		Actor dogmeatRef = DogmeatCompanionAlias.GetActorReference()
		if (dogmeatRef != None)
			if (DogmeatSetWait)
				DogmeatSetWait = false
				dogmeatRef.SetRestrained(false)
				
				dogmeatRef.FollowerFollow()
				DTDebug(" Dogmeat, come along, boy! ", 2)
			endIf
			
			return true
		endIf
	endIf
	DogmeatSetWait = false
	
	return false
endFunction

; forIntimateSecond -- 0=FMM, 1=FMF, 2=M/F (FMM or FMF), 3=FFF/MMM
Function SetExtraLovePartners(int forIntimateSecond = -1, bool seatedOK = true)

	DTDebug("check extra loversl (" + forIntimateSecond + ") with lover " + IntimateCompanionRef + " and current SecondRoles: " + SceneData.SecondMaleRole + ", " + SceneData.SecondFemaleRole, 2)
	if (DTSleep_SettingLover2.GetValue() <= 0.0 || IntimateCompanionRef == StrongCompanionRef)
		return
	endIf
	ObjectReference[] actorArray = PlayerRef.FindAllReferencesWithKeyword(DTSleep_ActorKYList.GetAt(0), 820.0)
	
	Actor heatherActor = GetHeatherActor()
	Actor barbActor = GetNWSBarbActor()	
	int aCnt = 0
	
	SceneData.SecondFemaleRole = None
	SceneData.SecondMaleRole = None
	float intimateSetting = DTSleep_SettingIntimate.GetValue()
	
	while (aCnt < actorArray.Length && (SceneData.SecondFemaleRole == None || SceneData.SecondMaleRole == None))
		Actor ac = actorArray[aCnt] as Actor
		
		if (ac != None && ac != PlayerRef && ac != StrongCompanionRef && ac.IsEnabled())
		
			;DTDebug("checking enabled extra actor " + ac, 2)

			if ((DTSConditionals as DTSleep_Conditionals).IsWorkShop02DLCActive && (DTSConditionals as DTSleep_Conditionals).DLC05ArmorRackKY != None && ac.HasKeyword((DTSConditionals as DTSleep_Conditionals).DLC05ArmorRackKY))
				; do nothing -
				; not counting workshop armor mannequin which is NPC
			
			elseIf (!ac.IsDead() && !ac.IsUnconscious() && ac.GetSleepState() < 3 && !ac.WornHasKeyword(ArmorTypePower))
			
				if (seatedOK || ac.GetSitState() < 2)
			
					CompanionActorScript aCompanion = GetCompanionOfActor(ac)
					
					if (aCompanion != None && ac != IntimateCompanionRef)
					
						;DTDebug("checking companion " + ac, 2)
			
						; make certain partner is not the jealous type   -- v2.13: jealous okay
						;if ((DTSleep_IntimateAffinityQuest as DTSleep_IntimateAffinityQuestScript).CompanionHatesIntimateOtherPublic(ac) == false)
					
							bool isPartner = false
							if (IsCompanion2RaceCompatible(ac))					; v2.64 - make sure 2nd lover is race-safe
							
								if (aCompanion.IsRomantic())
									isPartner = true
								elseIf (aCompanion.IsInFatuated())
									isPartner = true
								elseIf (DTSleep_CompanionRomanceList.HasForm(ac as Form) && aCompanion.GetValue(CA_AffinityAV) >= 1000.0)
									isPartner = true
								elseIf ((intimateSetting == 2.0 || intimateSetting == 4.0) && PlayerHasPerkOfCompanion(ac))
									isPartner = true
								elseIf ((DTSConditionals as DTSleep_Conditionals).ModPersonalGuardCtlKY != None)
									; v2.41
									if (ac.HasKeyword((DTSConditionals as DTSleep_Conditionals).ModPersonalGuardCtlKY))
										isPartner = true
									endIf
								endIf
							endIf
							
							if (isPartner)
									
								if ((DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).GetGenderForActor(ac) == 1)
								
									SceneData.SecondFemaleRole = ac
								elseIf (SceneData.SecondMaleRole == None)
									SceneData.SecondMaleRole = ac
								endIf
							endIf
						;endIf
					elseIf (SceneData.SecondFemaleRole == None && heatherActor != None && heatherActor == ac && heatherActor != IntimateCompanionRef)
						
						if (IsHeatherInLove() >= 1)
							
							SceneData.SecondFemaleRole = ac
						endIf
					
					elseIf (SceneData.SecondFemaleRole == None && barbActor != None && barbActor == ac && barbActor != IntimateCompanionRef)
						if (IsNWSBarbInLove())
							
							SceneData.SecondFemaleRole = ac
						endIf
					elseIf ((DTSConditionals as DTSleep_Conditionals).ModPersonalGuardCtlKY != None)				; v2.41
						if (ac.HasKeyword((DTSConditionals as DTSleep_Conditionals).ModPersonalGuardCtlKY))
							if ((DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).GetGenderForActor(ac) == 1)
							
								SceneData.SecondFemaleRole = ac
							elseIf (SceneData.SecondMaleRole == None)
								SceneData.SecondMaleRole = ac
							endIf
						endIf
					endIf
				endIf
			endIf
		endIf
	
		aCnt += 1
	endWhile
	
	; check second actors to set ready
	; 0=FMM, 1=FMF, 2=M/F (FMM or FMF), 3=FFF/MMM
	;
	if (forIntimateSecond >= 0 && (SceneData.SecondMaleRole != None || SceneData.SecondFemaleRole != None))
		int playerGender = (DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).GetGenderForActor(PlayerRef)
		int companGender = (DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).GetGenderForActor(IntimateCompanionRef)
		int setForGender = -1		; gender needed
		
		; v2.14 fixes for missing order of companions
		
		if (forIntimateSecond == 0)
			; FMM case
			if (playerGender == 0 && companGender == 0)
				if (SceneData.SecondFemaleRole != None)
					setForGender = 1	; MM need F
				endIf
				
			elseIf (playerGender != companGender && SceneData.SecondMaleRole != None)
				setForGender = 0		; FM need M
			endIf
		;elseIf (forIntimateSecond == 3 && playerGender == 1 && companGender == 1 && SceneData.SecondFemaleRole != None)
			; have FFF so done 
		;	SceneData.SecondMaleRole = None
			
		;elseIf (forIntimateSecond == 3 && playerGender == 0 && companGender == 0 && SceneData.SecondMaleRole != None)
		;	; have MMM so done - 
		;	SceneData.SecondFemaleRole = None
			
		elseIf (forIntimateSecond >= 1)
			; FMF case - need FMF pattern (if player female, need male and female)
			int genderCF = 0	; companion gender (= m) looking for female - default for female player
			int genderCM = 1	; companion gender (= f) looking for male
			
			if (playerGender == 0)	; male player, flip
				genderCF = 1
				genderCM = 0
			endIf
			
			if (companGender == genderCF && SceneData.SecondFemaleRole != None)
				setForGender = 1
				
			elseIf (companGender == genderCM && SceneData.SecondMaleRole != None)
				setForGender = 0
				
			elseIf (forIntimateSecond == 2 && companGender == 0)
				; FMM (companion must be male or would have been matched above)
				if (playerGender == 1 && SceneData.SecondMaleRole != None)		
					setForGender = 0
				elseIf (playerGender == 0 && SceneData.SecondFemaleRole != None)
					setForGender = 1
				endIf	
			endIf
		endIf
		
		if (setForGender == 0)
			if (DTSleep_CompIntimateLover2Alias != None)
				IntimateCompanionSecRef = SceneData.SecondMaleRole
				
			elseIf (seatedOK || (SceneData.SecondMaleRole.GetSitState() < 2))
				SceneData.SecondMaleRole = None
			endIf
			SceneData.SecondFemaleRole = None
				
		elseIf (setForGender == 1)
			if (DTSleep_CompIntimateLover2Alias != None)
				IntimateCompanionSecRef = SceneData.SecondFemaleRole
			elseIf (seatedOK || (SceneData.SecondFemaleRole.GetSitState() < 2))
				SceneData.SecondFemaleRole = None
			endIf
			SceneData.SecondMaleRole = None
		endIf
		
		if (IntimateCompanionSecRef != None)
			IntimateCompanionSecRef.AddToFaction(DTSleep_IntimateFaction)
			DTSleep_CompIntimateLover2Alias.ForceRefTo(IntimateCompanionSecRef)
			IntimateCompanionSecRef.EvaluatePackage()
		else
			SceneData.SecondFemaleRole = None
			SceneData.SecondMaleRole = None
		endIf
	endIf
endFunction

;v2.35
Function SetExtraMutantPartner()

	SceneData.SecondFemaleRole = None
	SceneData.SecondMaleRole = None
	
	if (!(DTSConditionals as DTSleep_Conditionals).IsSavageCabbageActive || !(DTSConditionals as DTSleep_Conditionals).ImaPCMod)
		return
	endIf
		
	; must have mutant stink and with Strong
	if (IntimateCompanionRef == StrongCompanionRef && PlayerRef.IsInFaction(DTSleep_MutantAllyFaction) && DTSleep_SettingLover2.GetValue() >= 1.0)
		int skillOkay = 0
		if (IntimacySMCount > 26 && TestVersion == -2)
			
			skillOkay = 2
		elseIf (IntimacySMCount > 15)
			skillOkay = 1
		elseIf (DTSleep_SettingTestMode.GetValue() >= 1.0 && DTSleep_DebugMode.GetValue() >= 3.0)
			skillOkay = 2
		endIf
		if (skillOkay > 0)
			DTDebug("check extra mutants with lover " + IntimateCompanionRef, 2)

			int kind = 2
			ObjectReference[] actorArray = None
			if (skillOkay == 2)
				; behemoth requires morphs
				actorArray = PlayerRef.FindAllReferencesWithKeyword(ActorTypeSuperMutantBehemothKY, 750.0)
			endIf
			if (actorArray.Length == 0)
				kind = 1
				actorArray = PlayerRef.FindAllReferencesWithKeyword(ActorTypeSuperMutant, 650.0)
			endIf
			
			int aCnt = 0
			
			while (aCnt < actorArray.Length && SceneData.SecondMaleRole == None)
				Actor ac = actorArray[aCnt] as Actor
				if (ac != None && ac != StrongCompanionRef && ac.IsEnabled() && !ac.IsDead() && !ac.IsUnconscious())
					
					if (ac.IsInCombat() == false)
						
						SceneData.SecondMaleRole = ac
						if (kind == 2)
							SceneData.IsCreatureType = CreatureTypeBehemoth
						endIf
					endIf
				endIf
				
				aCnt += 1
			endWhile
			
			if (SceneData.SecondMaleRole != None)
				IntimateCompanionSecRef = SceneData.SecondMaleRole
				IntimateCompanionSecRef.AddToFaction(DTSleep_IntimateFaction)
				DTSleep_CompIntimateLover2Alias.ForceRefTo(IntimateCompanionSecRef)
				IntimateCompanionSecRef.EvaluatePackage()
			endIf
		endIf
	endIf
endFunction

; v2.24
int Function RestoreSettingsDefault()

	; v2.60  - reset for new check
	(DTSConditionals as DTSleep_Conditionals).PlayerRace = None
	; v2.73 - clear scene ignore-list even if not active
	(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetSceneIDToIgnoreClearAll()
	MyMenuCheckBusy = false
	
	; commented out settings not reset
	if (DTSleep_SettingModActive.GetValue() >= 2.0)
	
		Utility.Wait(0.333)
		
		if (DTSleep_ConfirmRestoreDefMsg.Show() == 1)
	
			(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).DTSleep_SettingAACV.SetValue(1.0)
			DTSleep_SettingAAF.SetValueInt(0)
			;DTSleep_SettingAltFemBody
			DTSleep_SettingBedDecor.SetValue(1.0)
			(DTSleep_BedOwnQuestP as DTSleep_BedOwnQuestScript).DTSleep_SettingBedOwn.SetValue(1.0)
			;DTSleep_SettingCamera
			DTSleep_SettingCancelScene.SetValue(0.0)
			SetSettingsChairActivDefault()
			DTSleep_SettingChemCraft.SetValue(0.0)
			(DTSleep_SpectatorQuestP as DTSleep_SpectatorQuestScript).DTSleep_SettingCrime.SetValue(1.0)
			(DTSleep_IntimateAffinityQuest as DTSleep_IntimateAffinityQuestScript).DTSleep_SettingDoAffinity.SetValue(1.0)
			DTSleep_SettingDogRestrain.SetValue(1.0)
			DTSleep_SettingFadeEndScene.SetValue(1.0)
			(DTSleep_HealthRecoverQuestP as DTSleep_HealthRecoverQuestScript).DTSleep_SettingFastSleepEffect.SetValue(1.0)
			;DTSleep_SettingFastTime
			;DTSleep_SettingGenderPref
			(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).DTSleep_SettingIncludeExtSlots.SetValue(1.0)
			DTSleep_SettingIntimate.SetValue(1.0)
			DTSleep_SettingLover2.SetValue(1.0)
			DTSleep_SettingMenuStyle.SetValue(2.0)
			DTSleep_SettingNapComp.SetValue(1.0)
			DTSleep_SettingNapExit.SetValue(1.0)
			DTSleep_SettingNapRecover.SetValue(1.0)
			DTSleep_SettingSwapRoles.SetValueInt(0)				; v2.82
			DTSleep_SettingUndressShoes.SetValueInt(0)
			DTSleep_SettingUndressStockings.SetValueInt(0)
			

			; SetModDef below may change this
			if (Game.GetDifficulty() == 6)
				DTSleep_SettingNapOnly.SetValue(2.0)
			else
				DTSleep_SettingNapOnly.SetValue(0.0)
			endIf
			
			CheckVRMode()									; v3.0
			
			DTSleep_SettingNotifications.SetValue(1.0)
			;DTSleep_SettingNPCExtras - not used
			(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).DTSleep_SettingPackOnGround.SetValue(2.0)
			DTSleep_SettingPickPos.SetValue(-10.0)
			;DTSleep_SettingPilloryEnabled
			DTSleep_SettingPrefSYSC.SetValue(0.0)		;ProcessCompatibleMods will adjust
			DTSleep_SettingSave.SetValue(2.0)
			(DTSleep_TimeDayQuestP as DTSleep_TimeDayQuestScript).DTSleep_SettingShowHourly.SetValue(1.0)
			if (DTSleep_AdultContentOn.GetValue() >= 2.0)
				DTSleep_SettingShowIntimateCheck.SetValue(2.0)
			else
				DTSleep_SettingShowIntimateCheck.SetValue(1.0)
			endIf
			float sortTape = DTSleep_SettingSortHolotape.GetValue()
			if (sortTape > 0.0 && sortTape < 1.0)
				; v2.78 error correction
				DTDebug("corrrecting holotape sort value of " + sortTape + " to 0.0", 1)
				DTSleep_SettingSortHolotape.SetValue(0.0)
			endIf
			DTSleep_SettingSynthHuman.SetValue(0.0)
			DTSleep_SettingTestMode.SetValue(0.0)
			DTSleep_SettingTourEnabled.SetValue(1.0)
			
			;v2.60
			SetRestRedressDefault()
			
			;DTSleep_SettingUndressGlasses
			DTSleep_SettingUndressPipboy.SetValue(1.0)
			(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).DTSleep_SettingUndressTimer.SetValue(3.20)
			;DTSleep_SettingUseBT2Gun
			(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).DTSleep_SettingUseLeitoGun.SetValue(2.0)
			DTSleep_SettingWarnLoverBusy.SetValue(1.0)
			
			DTSleep_SettingRadCheck.SetValueInt(2)
			DTSleep_SettingScaleActorKiss.SetValueInt(0)
			
			(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).DTSleep_SettingCollision.SetValueInt(1)			; v2.70
		
			; may overide based on game settings
			SetModDefaultSettingsForGame()
			ProcessCompatibleMods()
			
			if (DTSleep_IsNNESActive.GetValueInt() == 2)				;  check to disable  v3.0
				ModSetNNESToggle()
			endIf
		endIf
	endIf
endFunction

int Function RestoreTestSettings(float oldVersion = 0.0)
	int count = 0
	if (TestVersion > 0)
		Debug.Notification("Sleep Intimate TEST loose script file! please remove!")
		return -1
	endIf
	
	if (oldVersion > 1.0 && oldVersion < 1.5420 && DTSleep_PlayerUsingBed.GetValue() <= 0.0)
		RegisterForMenuOpenCloseEvent("WorkshopMenu")
	endIf
	
	
	if (DTSleep_AdultContentOn.GetValue() <= 1.5)
		if (DTSleep_SettingChairsEnabled.GetValueInt() >= 2)
			DTSleep_SettingChairsEnabled.SetValueInt(1)
		endIf
		if (DTSleep_SettingShowIntimateCheck.GetValue() >= 2.0)
			DTSleep_SettingShowIntimateCheck.SetValue(1.0)
		endIf
	endIf
	
	; version updates
	if (oldVersion <= 1.540)
		; fix for error in previous version
		int napComp = DTSleep_SettingNapComp.GetValueInt()
		if (napComp > 1)
			napComp = 1
			DTSleep_SettingNapComp.SetValueInt(napComp)
		endIf
	endIf
	
	;if (DTSleep_SettingTestMode.GetValueInt() > 0)
	;	DTSleep_SettingTestMode.SetValue(0.0)
	;	count += 1
	;endIf
	
	if (oldVersion < 1.670)
		; ModActive should have been set on update to v1.62, but forgot
		float modActiveVal = DTSleep_SettingModActive.GetValue()
		if (modActiveVal > 0.0 && modActiveVal < 2.0)
			count += 1
			DTSleep_SettingModActive.SetValue(2.0)
		endIf
		
		; pick-a-spot replaced by pick-a-scene
		float pickPromptVal = DTSleep_SettingShowIntimateCheck.GetValue()
		if (pickPromptVal > 0.0 && DTSleep_AdultContentOn.GetValue() >= 2.0)
			DTSleep_SettingShowIntimateCheck.SetValue(2.0)
			count += 1
		endIf
	endIf
	
	if (oldVersion < 1.900)
		
		; new features
		IntimateLastEmbraceTime = Utility.GetCurrentGameTime() - 1.1
		IntimateLastTime = DTSleep_IntimateTime.GetValue()
		
		; setting no longer used for testing; now used for go-to-bed afer intimacy
		; reset to new default
		if (DTSleep_SettingFadeEndScene.GetValueInt() < 1)
			DTSleep_SettingFadeEndScene.SetValue(1.0)
			count += 1
		endIf
	endIf
	
	if (oldVersion < 1.950)
	
		IntimateLastEmbraceScoreTime = Utility.GetCurrentGameTime() - 1.1
		; reset tips/wake messages
		self.MessageOnWakeID = 0
		self.MessageOnRestID = 0
		self.MessageOnRestTipID = 0
		
		; forcing AAC player on update
		if (DTSleep_SettingAAF.GetValue() > 0.0)
			if (IsAAFReady())
				; force disable and notify if on
				if (DTSleep_SettingAAF.GetValue() >= 1.0)
					StartTimer(2.5, AAFDisabledMsgTimerID)
				endIf
			endIf
			DTSleep_SettingAAF.SetValue(0.0)
			count += 1
		elseIf (DTSleep_SettingAAF.GetValue() < 0.0)
			DTSleep_SettingAAF.SetValue(0.0)
			count += 1
		endIf		
	endIf
	
	if (oldVersion < 2.05)
		if (DTSleep_DogTrainQuestP.IsRunning())
			DTSleep_DogTrainQuestP.SetStage(60)  ; pause / hide display
		endIf
		if (DTSleep_SettingDogRestrain.GetValueInt() == 0)
			DTSleep_SettingDogRestrain.SetValueInt(-1)
			count += 1
		endIf
	endIf
	
	if (oldVersion < 2.14)
		if (IntimateCheckFailCount > 2)
			IntimateCheckFailCount = 2
		endIf
	endIf
	
	if (oldVersion < 2.18)
		int evbVal = (DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).DTSleep_SettingUseLeitoGun.GetValueInt()
		if (DTSleep_AdultContentOn.GetValueInt() >= 2)
			if (evbVal < 3)
				(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).DTSleep_SettingUseLeitoGun.SetValueInt(3)
				count += 1
			endIf
		
		elseIf (evbVal > 0)
			(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).DTSleep_SettingUseLeitoGun.SetValueInt(0)
			count += 1
		endIf
		
		; error correction
		int beforeSize = (DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).DTSleep_IntimateTableList.GetSize()
		(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).DTSleep_IntimateTableList.Revert()
		int afterSize = (DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).DTSleep_IntimateTableList.GetSize()
		if  (DTSleep_AdultContentOn.GetValueInt() >= 1)
			Debug.Trace(myScriptName + " correction for TableList before size = " + beforeSize + ", and after size = " + afterSize)
		endIf
	endIf
	
	if (oldVersion < 2.220)
		VerifyRomanceList()
	endIf
	
	if (DTSleep_SettingTestMode.GetValue() < 0.0)		; correction so MCM will work
		DTSleep_SettingTestMode.SetValue(0.0)
		count += 1
	endIf
	if (DTSleep_SettingModActive.GetValue() >= 2.0)
		DTSleep_SettingModMCMCtl.SetValue(1.0)
	else
		DTSleep_SettingModMCMCtl.SetValue(0.0)
	endIf
	
	if (oldVersion < 2.280 && DTSleep_PlayerUsingBed.GetValueInt() <= 0)
	
		; clean-up
		UnregisterForAllRemoteEvents()
		
		PlayerSleepPerkAdd()		; re-register
	endIf
	
	if (oldVersion < 2.35 && TipSleepModeDisplayCount >= 2 && DTSleep_SettingNapOnly.GetValueInt() != 1)
		TipSleepModePromptVal = 2
	endIf
	
	if (oldVersion < 2.60 && (DTSConditionals as DTSleep_Conditionals).IsUPFPlayerActive)			; v2.60
		SetToggleRedress()
	endIf
	
	if (oldVersion < 2.70 && (DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).DTSleep_SettingAACV.GetValueInt() != 1)								
		; v2.70 - reset test view to updated default
		(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).DTSleep_SettingAACV.SetValue(1.0)
		count += 1
	endIf


	if (oldVersion >= 2.64 && oldVersion < 2.84)			; v2.84
		; kiss-align on-update patcher fix

		count += FixKissAlignScaleBug()	
	endIf
	
	return count
endFunction

; ---------------------------------------------------Fix kiss-align scale bug --------------------
; v2.84 - check and fix companion scales for known issues with kiss-align (player using height mod)
    ;        and known game bug (after using furniture female stuck at male height)
	;
	;    original Kiss-Align failed to account for modified heights / base-scale
	;       - modified base-scale smaller than default would cause actor to shrink
	;       - modified base-scale larger than default would cause actor to grow
	;
	;    original Kiss-Align on R-X  playing female (Nora) could cause female companion to shrink
	;  		- after initiated intimate scene with female companion with PC having ToyArmor then embraces afterwards
	;       - shrinking by 0.98 * 0.98 = 0.9604 and so on
	;
	;    origScale (SetScale) * baseScale = gameScale (GetScale)
	;    baseScale may be modifed by patch override of Height Min/Max; Height of 1.0 for female is 0.98 baseScale, for male is 1.0
	; --------------------------------------
	;    returns zero unless changes kiss-align preference to 2 due to using custom scales more than once
	;
int Function FixKissAlignScaleBug()
	int bugFixCount = 0							; scale fixes due to game-bug
	int kissFixCount = 0						; scale fixes due to kiss-align bug
	int notFixCount = 0							; modified scale, not fixed
	int totalActorsChecked = 0
	Actor heatherActor = GetHeatherActor()		
	Actor nwBarbActor = GetNWSBarbActor()
	Actor anActorFixedForKissBug = None
	
	Debug.Trace(" ---------------------------------------------------------------------------- ")
	Debug.Trace(myScriptName + " -----       Kiss-Align Patch: checking romanced companions")
	Debug.Trace(" ---------------------------------------------------------------------------- ")
	
	; check only those that may have been kissed -- if infatuated and human (or synth)
	
	if (CompanionCaitRef.GetValue(CA_AffinityAV) > 999.0)
		ActorBase compBase = (CompanionCaitRef.GetLeveledActorBase() as ActorBase)
		
		if (compBase.GetRace() == HumanRace)
			totalActorsChecked += 1
			int checkVal = CheckScaleAndFixKissAlignForActor(CompanionCaitRef, 0.98)
			if (checkVal == 0)
				notFixCount += 1
			elseIf (checkVal == 1)
				bugFixCount += 1
			elseIf (checkVal >= 2)
				kissFixCount += 1
				anActorFixedForKissBug = CompanionCaitRef
			endIf
		endIf
	endIf
	if (CurieRef.GetValue(CA_AffinityAV) > 999.0)
		ActorBase compBase = (CurieRef.GetLeveledActorBase() as ActorBase)
		Race curieRace = compBase.GetRace()
		; SynthGen2 is for Valentine, but for some reason Curie may show as that race so we include
		if (curieRace == SynthGen2RaceValentine || curieRace == HumanRace)
			totalActorsChecked += 1
			int checkVal = CheckScaleAndFixKissAlignForActor(CurieRef, 0.98)
			if (checkVal == 0)
				notFixCount += 1
			elseIf (checkVal == 1)
				bugFixCount += 1
			elseIf (checkVal >= 2)
				kissFixCount += 1
				anActorFixedForKissBug = CurieRef
			endIf
		endIf
	endIf
	if (CompanionPiperRef.GetValue(CA_AffinityAV) > 999.0)
		ActorBase compBase = (CompanionPiperRef.GetLeveledActorBase() as ActorBase)
		if (compBase.GetRace() == HumanRace)
			totalActorsChecked += 1
			int checkVal = CheckScaleAndFixKissAlignForActor(CompanionPiperRef, 0.98)
			if (checkVal == 0)
				notFixCount += 1
			elseIf (checkVal == 1)
				bugFixCount += 1
			elseIf (checkVal >= 2)
				kissFixCount += 1
				anActorFixedForKissBug = CompanionPiperRef
			endIf
		endIf
	endIf
	
	; males
	if (CompanionDeaconRef.GetValue(CA_AffinityAV) > 999.0)
		ActorBase compBase = (CompanionDeaconRef.GetLeveledActorBase() as ActorBase)
		if (compBase.GetRace() == HumanRace)
			totalActorsChecked += 1
			int checkVal = CheckScaleAndFixKissAlignForActor(CompanionDeaconRef, 1.00)
			if (checkVal == 0)
				notFixCount += 1
			elseIf (checkVal == 1)
				bugFixCount += 1
			elseIf (checkVal >= 2)
				kissFixCount += 1
				anActorFixedForKissBug = CompanionDeaconRef
			endIf
		endIf
	endIf
	if (CompanionX6Ref.GetValue(CA_AffinityAV) > 999.0)
		totalActorsChecked += 1
		int checkVal = CheckScaleAndFixKissAlignForActor(CompanionX6Ref, 1.00)
		if (checkVal == 0)
			notFixCount += 1
		elseIf (checkVal == 1)
			bugFixCount += 1
		elseIf (checkVal >= 2)
			kissFixCount += 1
			anActorFixedForKissBug = CompanionX6Ref
		endIf
	endIf
	if (CompanionMacCreadyRef.GetValue(CA_AffinityAV) > 999.0)
		ActorBase compBase = (CompanionMacCreadyRef.GetLeveledActorBase() as ActorBase)
		if (compBase.GetRace() == HumanRace)
			totalActorsChecked += 1
			int checkVal = CheckScaleAndFixKissAlignForActor(CompanionMacCreadyRef, 1.00)
			if (checkVal == 0)
				notFixCount += 1
			elseIf (checkVal == 1)
				bugFixCount += 1
			elseIf (checkVal >= 2)
				kissFixCount += 1
				anActorFixedForKissBug = CompanionMacCreadyRef
			endIf
		endIf
	endIf
	
	if ((DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).GarveyRef.GetValue(CA_AffinityAV) > 999.0)
		ActorBase compBase = ((DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).GarveyRef.GetLeveledActorBase() as ActorBase)
		if (compBase.GetRace() == HumanRace)
			totalActorsChecked += 1
			int checkVal = CheckScaleAndFixKissAlignForActor((DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).GarveyRef, 1.00)
			if (checkVal == 0)
				notFixCount += 1
			elseIf (checkVal == 1)
				bugFixCount += 1
			elseIf (checkVal >= 2)
				kissFixCount += 1
				anActorFixedForKissBug = (DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).GarveyRef
			endIf
		endIf
	endIf
	if ((DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).HancockRef.GetValue(CA_AffinityAV) > 999.0)
		ActorBase compBase = ((DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).HancockRef.GetLeveledActorBase() as ActorBase)
		if (compBase.GetRace() == GhoulRace)
			totalActorsChecked += 1
			int checkVal = CheckScaleAndFixKissAlignForActor((DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).HancockRef, 1.00)
			if (checkVal == 0)
				notFixCount += 1
			elseIf (checkVal == 1)
				bugFixCount += 1
			elseIf (checkVal >= 2)
				kissFixCount += 1
				anActorFixedForKissBug = (DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).HancockRef
			endIf
		endIf
	endIf
	
	if ((DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).CompanionValentineRef.GetValue(CA_AffinityAV) > 999.0)
		CompanionActorScript compActor = (DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).CompanionValentineRef as CompanionActorScript
		if (compActor.IsRomantic())
			totalActorsChecked += 1
			int checkVal = CheckScaleAndFixKissAlignForActor((DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).CompanionValentineRef, 1.00)
			if (checkVal == 0)
				notFixCount += 1
			elseIf (checkVal == 1)
				bugFixCount += 1
			elseIf (checkVal >= 2)
				kissFixCount += 1
				anActorFixedForKissBug = (DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).CompanionValentineRef
			endIf
		endIf
	endIf
	
	if ((DTSConditionals as DTSleep_Conditionals).NukaWorldDLCGageRef != None)
		if ((DTSConditionals as DTSleep_Conditionals).NukaWorldDLCGageRef.GetValue(CA_AffinityAV) > 999.0)
			ActorBase compBase = ((DTSConditionals as DTSleep_Conditionals).NukaWorldDLCGageRef.GetLeveledActorBase() as ActorBase)
			if (compBase.GetRace() == HumanRace)
				totalActorsChecked += 1
				int checkVal = CheckScaleAndFixKissAlignForActor((DTSConditionals as DTSleep_Conditionals).NukaWorldDLCGageRef, 1.00)
				if (checkVal == 0)
					notFixCount += 1
				elseIf (checkVal == 1)
					bugFixCount += 1
				elseIf (checkVal >= 2)
					kissFixCount += 1
					anActorFixedForKissBug = (DTSConditionals as DTSleep_Conditionals).NukaWorldDLCGageRef
				endIf
			endIf
		endIf
	endIf
	if ((DTSConditionals as DTSleep_Conditionals).FarHarborDLCLongfellowRef != None)
		if ((DTSConditionals as DTSleep_Conditionals).FarHarborDLCLongfellowRef.GetValue(CA_AffinityAV) > 999.0)
			ActorBase compBase = ((DTSConditionals as DTSleep_Conditionals).FarHarborDLCLongfellowRef.GetLeveledActorBase() as ActorBase)
			if (compBase.GetRace() == HumanRace)
				totalActorsChecked += 1
				int checkVal = CheckScaleAndFixKissAlignForActor((DTSConditionals as DTSleep_Conditionals).FarHarborDLCLongfellowRef, 1.00)
				if (checkVal == 0)
					notFixCount += 1
				elseIf (checkVal == 1)
					bugFixCount += 1
				elseIf (checkVal >= 2)
					kissFixCount += 1
					anActorFixedForKissBug = (DTSConditionals as DTSleep_Conditionals).FarHarborDLCLongfellowRef
				endIf
			endIf
		endIf
	endIf
	
	; mods
	if (heatherActor != None)
		if (IsHeatherInLove() >= 1)
			totalActorsChecked += 1
			int checkVal = CheckScaleAndFixKissAlignForActor(heatherActor, 0.98)
			if (checkVal == 0)
				notFixCount += 1
			elseIf (checkVal == 1)
				bugFixCount += 1
			elseIf (checkVal >= 2)
				kissFixCount += 1
				if (anActorFixedForKissBug == None)
					anActorFixedForKissBug = heatherActor
				endIf
			endIf
		endIf 
	endIf
	if (nwBarbActor != None)
		if (IsNWSBarbInLove())
			totalActorsChecked += 1
			int checkVal = CheckScaleAndFixKissAlignForActor(nwBarbActor, 0.98)
			if (checkVal == 0)
				notFixCount += 1
			elseIf (checkVal == 1)
				bugFixCount += 1
			elseIf (checkVal >= 2)
				kissFixCount += 1
				if (anActorFixedForKissBug == None)
					anActorFixedForKissBug = nwBarbActor
				endIf
			endIf
		endIf
	endIf
	
	if (kissFixCount > 0)
		; report
		Utility.WaitMenuMode(0.5)
		
		DTSleep_PatchKissFixMessage.Show(kissFixCount, totalActorsChecked)
		
		Utility.WaitMenuMode(1.33)
		
	elseIf (notFixCount > 2)
		; no report
		if (DTSleep_SettingScaleActorKiss.GetValueInt() == 1 && (DTSConditionals as DTSleep_Conditionals).ImaPCMod)
		
			DTSleep_SettingScaleActorKiss.SetValueInt(2)
			
			return 1
		endIf

		
	endIf
	
	Debug.Trace(" ---------------------------------------------------------------------------- ")
	Debug.Trace(myScriptName + " -----       Kiss-Align Patch Done!! ")
	Debug.Trace(" ---------------------------------------------------------------------------- ")
	
	return 0
endFunction

; ------------------- check and fix known kiss-align issues ----------------
; returns negative for no issue, 
; returns 0 for found modified-scale not fixed,
;         1 for game bug fix
;         2 for modified-height fix,
;         3 for R-X same-gender role-reverse bug 
;
int Function CheckScaleAndFixKissAlignForActor(Actor anActor, float expectedScale)

	; (1) there exists a furniture bug that may leave females scaled up (1.02 * 0.98 = 1.0)
	; (2) when base-scale != in-game-scale pre-2.84 kiss-align broke, so fix (2)
	; (3) when same-gender female on R-X with reversed roles, pre-2.84 kiss-align shrinks companion, so fix 
	
	if (anActor == None)
		return -2
	endIf
	
	float currentScale = anActor.GetScale()
	
	if (currentScale != expectedScale && currentScale > 0.5 && currentScale < 1.5)
		anActor.SetScale(1.0)
		float baseScale = anActor.GetScale()
		if (baseScale != currentScale)
			if (baseScale == 0.98 && currentScale > 0.9995 && currentScale <= 1.00)
				; game bug
				Debug.Trace(myScriptName + " ******* FIX SCALE for actor " + anActor + " likely due to game bug left scaled up to 1.0")
				anActor.SetScale(1.0)
				
				return 1
				
			elseIf (baseScale != expectedScale && baseScale != 1.0)
				; height-modified actor -- could be kiss-align bug
				float kissScale1 = baseScale * baseScale				; first kiss resulting scale
				
				if (baseScale < 1.0 && currentScale <= kissScale1)
					Debug.Trace(myScriptName + " ******* FIX SCALE for short actor " + anActor + " from in-game scale " + currentScale + " with MODIFIED base-scale " + baseScale)
					anActor.SetScale(1.0)
					
					return 2
				elseIf (baseScale > 1.0 && currentScale >= kissScale1)
					Debug.Trace(myScriptName + " ******* FIX SCALE for tall actor " + anActor + " from in-game scale " + currentScale + " with MODIFIED base-scale " + baseScale)
					anActor.SetScale(1.0)
					
					return 2
				endIf

			elseIf (baseScale == 0.98 && expectedScale == 0.98 && currentScale > 0.77 && currentScale < 0.98)
				; could be same-gender female kiss-align bug
				if (DTSleep_AdultContentOn.GetValue() >= 2.0 && IsAdultAnimationAvailable() && (Debug.GetPlatformName() as bool))
					if (currentScale <= 0.96040 && currentScale > 0.72)
						Debug.Trace(myScriptName + " ******* FIX SCALE for actor " + anActor + " from scale " + currentScale + " likely due to R-X same-gender role-reverse")
						anActor.SetScale(1.0)
						
						return 3
					endIf
				endIf
			endIf
			
			Debug.Trace(myScriptName + " ******** found scaled actor " + anActor + " not fixed with baseScale " + baseScale + " at in-game scale " + currentScale)
			
			return 0
		endIf
	endIf
	
	return -1		; no issues
endFunction
; ---------------------------------------------- end Fix kiss-align on-update -----------------------

Function SetAffinityForCreature(int creatureType)

	if (creatureType == CreatureTypeDog)
		self.SleepIntimateSceneAffinityOnSleepID = 2
	elseIf (creatureType == CreatureTypeStrong || creatureType == CreatureTypeBehemoth)
		self.SleepIntimateSceneAffinityOnSleepID = 3
	else
		self.SleepIntimateSceneAffinityOnSleepID = 1
	endIf
	CheckCompanionIntimateAffinity()
	Utility.Wait(1.0)

endFunction

Function SetDogAndCompanionFollow(Actor companionRef)

	; ensure doggy ready to set follow
	int count = 10
	while (count > 0 && processingDogmeatWait >= 2)
	
		Utility.Wait(0.1)
		count -= 1
	endWhile
	
	if (DTSleep_SettingDogRestrain.GetValue() > 0.0 && DogmeatCompanionAlias != None)
		SetDogmeatFollow()
	endIf
	
	if (companionRef != None)
		companionRef.FollowerFollow()
	endIf

endFunction

; minimum distance -- if underfoot might want to move dog first
; return -1 for too close; 0 for out of range; 1 for waiting
;
int Function SetDogmeatWait(float minDistance = 64.0, float maxDistance = 3200.0, bool restrainDog = true)
	
	DogmeatSetWait = false
	processingDogmeatWait = 2
	
	; must have dog alias and not in sleep quest
	; 
	if (DogmeatCompanionAlias != None && PlayerHasActiveDogmeatCompanion.GetValueInt() >= 1 && !DTSleep_CompSleepQuest.IsRunning())
	
		Actor dogmeatRef = DogmeatCompanionAlias.GetActorReference()
		
		; assume SitState is using a doghouse
		if (dogmeatRef != None && dogmeatRef.GetSitState() < 2)
			
			ObjectReference dogSleepNearRef = None
			if (DTSleep_CompIntimateQuest.IsRunning())
				if (DTSleep_DogBedIntimateAlias != None)
					dogSleepNearRef = DTSleep_DogBedIntimateAlias.GetReference()
				endIf
			endIf
			if (dogSleepNearRef == None)

				float dist = DTSleep_CommonF.DistanceBetweenObjects(dogmeatRef, PlayerRef, true)
			
				if (dist > minDistance && dist < maxDistance)
					; no doghouse so tell doggy to wait 
					DogmeatSetWait = true
					
					dogmeatRef.FollowerWait()
					dogmeatRef.SetDogAnimArchetypeNeutral()
					
					;if (restrainDog)
					;	dogmeatRef.SetRestrained(true)
					;endIf
					
					DTDebug(" Dogmeat nearby - wait, Dogmeat, at your spot! ", 2) 
					
					processingDogmeatWait = -1
					
					return 1
				else
					processingDogmeatWait = -1
					return -1
				endIf
			endIf
			if (dogSleepNearRef != None)
				
				Actor dogActor = None
				if (DTSleep_DogIntimateRestAlias != None)
					dogActor = DTSleep_DogIntimateRestAlias.GetActorReference()
					if (dogActor != None)
						DTDebug("send Dogmeat (" + dogActor + ") to dog-sleep bed: " + dogSleepNearRef, 2)
						dogActor.EvaluatePackage(false)
					else
						DTDebug("!! no dogActor from alias!!", 1)
					endIf
				else
					dogmeatRef.EvaluatePackage()
				endIf
			endIf
		endIf
	endIf
	
	processingDogmeatWait = 0
	
	return 0
endFunction

Function SetModDefaultSettingsForGame()

	if (Game.GetDifficulty() < 6)
		; not hardcore survival so switch to simple
		DTSleep_SettingNapOnly.SetValue(0.0)
	endIf
	if (Game.IsPluginInstalled("AdvancedNeeds2.esp"))
		; set preference to needs for sleep handling and recovery
		DTSleep_SettingNapOnly.SetValue(0.0)
		DTSleep_SettingNapRecover.SetValue(0.0)
		(DTSConditionals as DTSleep_Conditionals).HasModReqNormSleep = true
	endIf
	
	if (Game.IsPluginInstalled("Z_Horizon.esp"))
		(DTSleep_HealthRecoverQuestP as DTSleep_HealthRecoverQuestScript).DTSleep_SettingHealthRecover.SetValueInt(0)
	else
		(DTSleep_HealthRecoverQuestP as DTSleep_HealthRecoverQuestScript).DTSleep_SettingHealthRecover.SetValueInt(1)
	endIf
	
	if (DTSleep_AdultContentOn.GetValue() <= 1.5 && DTSleep_SettingUndressPipboy.GetValueInt() == 1)
		; default 1 not applicable 
		DTSleep_SettingUndressPipboy.SetValue(0.0)
	endIf
	
	if (DTSleep_AdultContentOn.GetValueInt() >= 2 && (Debug.GetPlatformName() as bool))
		(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).DTSleep_SettingUseLeitoGun.SetValueInt(2)
	else
		(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).DTSleep_SettingUseLeitoGun.SetValueInt(0)
	endIf
endFunction

Function SetPersuadeTutorStatus()
	
	if (DTSleep_IntimateEXP.GetValue() > 0.0 || DTSleep_IntimateDogEXP.GetValue() > 0.0 || DTSleep_IntimateStrongExp.GetValue() > 0)
		PersuadeTutorialShown = 2
	else
		PersuadeTutorialShown = 0
	endIf
endFunction

;	move player character to bed - companion uses package and quest
;
Function SetPlayerAndCompanionBedTime(ObjectReference akBed, ObjectReference akCompanionBed, bool companionReqNudeSuit, bool observeWinter = true, bool isFadedOut = false, bool moveToBed = true, bool playerNaked = false)
	
	bool undressOK = true
	
	; must check in case of load game 
	if (akBed == None || DTSleep_PlayerUsingBed.GetValue() <= 0.5)
	
		DTDebug("  SetPlayerAndCompanionBedtime bed is None; Cancel player move", 1)

		ResetAll()
		
		; on reload auto-save - this may get missed 
		if (self.SleepLoverBonusOnSleepID > 0)
			StartTimer(3.2, LoverBonusAddTimerID)
		endIf
		
		return 
	endIf
	
	if ((DTSConditionals as DTSleep_Conditionals).IsPlayerCommentsActive)
		ModPlayerCommentsDisable()
	endIf
	
	PlayerSleepPerkRemove()    ; temp hide

	if (!isFadedOut)
		FadeOutFast(true)
		Utility.Wait(0.45)
	endIf
	
	; enable to ensure we have correct disable method
	if (SleepInputLayer != None)
		EnablePlayerControlsSleep()
	endIf
	
	; always do before undress: disable and 3rd person
	DisablePlayerControlsSleep(0)
	if (akBed.HasKeyword(AnimFurnFloorBedAnims) || akBed.HasKeyword((DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).AnimFurnLayDownUtilityBoxKY))
		MainQSceneScriptP.CamHeightOffset = -24.0
	else
		MainQSceneScriptP.CamHeightOffset = 0.0
	endIf
	
	MainQSceneScriptP.GoSceneViewStart(1, true)		; for sleep to force 3rd-person except for FO4VR v3.02
	
	float undressLevel = DTSleep_SettingUndress.GetValue()
	
	if (undressLevel > 0.0) 
		if (DTSleep_PlayerUndressed.GetValue() == 0.0)

			if (undressLevel == 2.0 || undressLevel >= 4.0)
				observeWinter = false
			endIf
			
			undressOK = SetUndressForBed(akBed, IntimateCompanionRef, akCompanionBed, observeWinter, companionReqNudeSuit, playerNaked)
		
		elseIf (IntimateCompanionRef != None)
			; since already undressed, check remove weapon   - v2.75
			int remWeaponVal = (DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).DTSleep_SettingUndressWeapon.GetValueInt()
			if (remWeaponVal >= 2)
				(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).UndressActorWeapon(PlayerRef)
			endIf
			if (remWeaponVal == 1 || remWeaponVal == 3)
				(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).UndressActorWeapon(IntimateCompanionRef)
			endIf
		endIf
	else
		undressOK = false
	endIf
	
	bool findTwinBed = true
	if (undressOK && SleepBedCompanionUseRef != None && SleepBedCompanionUseRef != SleepBedInUseRef)
		if (SleepBedCompanionUseRef.GetDistance(SleepBedInUseRef) < 150.0)
			findTwinBed = false
			
			SleepBedTwin = SleepBedCompanionUseRef
			RegisterForRemoteEvent(SleepBedTwin, "OnActivate")
			
			; if companion using twin or will use twin then set affinity for on sleep
			if (IntimateCompanionRef != None)
				if (DTSleep_CompSleepQuest.IsRunning() && IntimateCompanionRef.IsInFaction(DTSleep_IntimateFaction))
					self.SleepIntimateSceneAffinityOnSleepID = 1
				elseIf (IntimateCompanionRef.GetSleepState() == 3 && SleepBedCompanionUseRef.IsFurnitureInUse() && DTSleep_CommonF.IsActorOnBed(IntimateCompanionRef, SleepBedCompanionUseRef))
					self.SleepIntimateSceneAffinityOnSleepID = 1
				endIf
			endIf

		endIf
	endIf
	
	if (undressOK && findTwinBed)
		; test if a twin-bed to mark to keep track of activation - not same-level to look for bunk
		ObjectReference testBed = DTSleep_CommonF.FindNearestAnyBedFromObject(akBed, DTSleep_BedList, akBed, 220.0, false)
		
		if (testBed != None)
			SleepBedTwin = testBed
			RegisterForRemoteEvent(SleepBedTwin, "OnActivate")
		endIf
	endIf
	
	if (moveToBed)
		; put player in bed

		MoveActorToBed(PlayerRef, akBed)
	endIf
	
	
	Utility.Wait(0.06)

	int encType = SetPlayerSleepEncounter(akBed, IntimateCompanionRef, IntimateCompanionRef)

	FadeInFast(false)
	
	if (SleepBedUsesBlock)
		; unblock so we can get out
		akBed.BlockActivation(false)
	endIf
		
	int restCount = 1 + DTSleep_RestCount.GetValueInt()
	if (restCount < 4000)
		DTSleep_RestCount.SetValueInt(restCount)
	endIf
	
	if (restCount == 1)
		StartTimer(12.1, TipSleepModeTimerID)
	elseIf (TipSleepModeDisplayCount <= 1)
		TipSleepModeDisplayCount = 2
	endIf
	
	if (DTSleep_SettingNapOnly.GetValue() > 0.0)
		
		StartTimer (5.5, MsgOnRestTimerID)
	endIf
	
	; check affinity
	if (self.SleepIntimateSceneAffinityOnSleepID > 0)
		StartTimer(6.5, LoverAffinityCheckTimerID)
	endIf
	
	if (self.SleepLoverBonusOnSleepID > 0)
		StartTimer(8.2, LoverBonusAddTimerID)
	endIf

	Utility.Wait(0.4)
	PlayerSleepPerkAdd()      ;v1.49 add back for Wake

	RegisterForRemoteEvent(akBed, "OnExitfurniture")
	RegisterForRemoteEvent(akBed, "OnActivate")			; watch for NPC activate
	
EndFunction

;	start sleep encounter quest
;
int Function SetPlayerSleepEncounter(ObjectReference akBed, Actor companionRef, bool isLover)
	if (!DTSleep_EncounterQuestP.IsRunning())
		DTSleep_EncounterQuestP.Start()
	endIf
	if (DTSleep_SettingBedDecor.GetValue() > 0.0 && !SleepBedIsPillowBed)
		if (akBed != None)
			return (DTSleep_EncounterQuestP as DTSleep_EncounterQuest).StartEncounter(akBed, companionRef, isLover)
		endIf
	else
		return -1
	endIf
	
	return -2
EndFunction

; creatureType: 0 = human, see constants for Dog or Strong
;
Function SetProgressIntimacy(int sexAppealScore = -1, int creatureType = 0, int randCheckIdx = -1, int nearActorCount = 0)
	IntimateCheckFailCount = 0
	IntimacyTestCount = 0
	
	;
	; intimate time for dog is unique and does not apply to human or Strong
	; treating dog-play as self-pleasure and not enough to satisfy intimacy
	; no bonuses for dog/self-play
	;
	float intimateTime = Utility.GetCurrentGameTime()
	
	int curDay = Math.Floor(intimateTime)
	int lastDay = Math.Floor(IntimateLastTime)
	
	if (curDay == lastDay)
		IntimacyDayCount += 1
	else
		IntimacyDayCount = 1
	endIf
		
	if (PlayerHasTreatsForCreature(creatureType, SceneData.CompanionBribeType))  ; spend treat if applicable
		; wait extra for message to display

		Utility.Wait(0.7)
	endIf
	
	if (!SceneData.CompanionInPowerArmor && SceneData.IsCreatureType != CreatureTypeSynth)
		if ((DTSConditionals as DTSleep_Conditionals).NoraSpouseRef != None && IntimateCompanionRef == (DTSConditionals as DTSleep_Conditionals).NoraSpouseRef)
			; no disease
		elseIf ((DTSConditionals as DTSleep_Conditionals).NoraSpouse2Ref != None && IntimateCompanionRef == (DTSConditionals as DTSleep_Conditionals).NoraSpouse2Ref)
			; no disease
		elseIf ((DTSConditionals as DTSleep_Conditionals).DualSurvivorsNateRef != None && IntimateCompanionRef == (DTSConditionals as DTSleep_Conditionals).DualSurvivorsNateRef)
			; no disease
		else
			PlayerDiseaseCheckSTD(creatureType)
		endIf
	endIf
	
	float timeSinceLast = DTSleep_CommonF.GetGameTimeHoursDifference(IntimateLastTime, intimateTime)
	
	if (nearActorCount > 9)
		if (!PlayerRef.HasPerk(DTSleep_ExhibitionPerk))
			PlayerRef.AddPerk(DTSleep_ExhibitionPerk)
			StartTimerGameTime(24.0, IntimateExhibitionGameTimerID)
		endIf
		TotalExhibitionCount += 1
		DTSleep_ExhibitionMessage.Show()
		Utility.Wait(1.0)
	elseIf (IntimacyDayCount >= 5 && !PlayerRef.HasPerk(DTSleep_BusyDayPerk))
		
		PlayerRef.AddPerk(DTSleep_BusyDayPerk)
		TotalBusyDayCount += 1
		StartTimerGameTime(12.0, IntimateBusyDayGameTimerID)
		DTSleep_BusyDayMessage.Show(IntimacyDayCount)
		Utility.Wait(1.0)
	endIf
	
	if (creatureType != CreatureTypeDog && creatureType != CreatureTypeHandy)
	
		IntimateSucPrevTime = IntimateLastTime
		DTSleep_IntimateTime.SetValue(intimateTime)     ; human or Strong - record time
		IntimateLastTime = intimateTime
		if (SceneData.CurrentLoverScenCount < 200)
			SceneData.CurrentLoverScenCount += 1		    ; keep track for same-love / faithful bonus
		endIf
		
		; check intimate tour
		if (DTSleep_SettingTourEnabled.GetValue() > 0 && DTSleep_IntimateLocCount.GetValueInt() < DTSleep_IntimateTourLocList.GetSize())
			
			Location aLoc = (SleepPlayerAlias as DTSleep_PlayerAliasScript).CurrentLocation
			if (aLoc == None)
				aLoc = PlayerRef.GetCurrentLocation()
				(SleepPlayerAlias as DTSleep_PlayerAliasScript).CurrentLocation = aLoc
			endIf
			
			if (aLoc != None && !DTSleep_IntimateTourQuestP.IsRunning() && !DTSleep_IntimateTourQuestP.GetStageDone(5))
				
				self.MessageOnWakeID = OnWakeMsgStartTour
			endIf
		
		
			if (DTSleep_IntimateTourQuestP.IsRunning() && !DTSleep_IntimateTourQuestP.IsCompleted())
			
				if (PlayerRef.IsInInterior() || !DTSleep_IntimateTourIndoorOnlyLocList.HasForm(aLoc as Form))

					int completeCount = (DTSleep_IntimateTourQuestP as DTSleep_IntimateTourQuestScript).CheckLocation(aLoc)
					
					if (completeCount > 0)
					
						;DTSleep_TourLocCheckedMsg.Show(completeCount)
						Utility.Wait(0.4)
						
						if (completeCount >= DTSleep_IntimateTourLocList.GetSize() && DTSleep_IntimateLocCount.GetValueInt() >= DTSleep_IntimateTourLocList.GetSize())
							if (!PlayerRef.HasPerk(DTSleep_LoversTourBonusPerk))
								PlayerRef.AddPerk(DTSleep_LoversTourBonusPerk)
							endIf
						endIf
					endIf
				endIf
			endIf
		endIf
		
		; apply experience
		int exp = DTSleep_IntimateEXP.GetValueInt()
		
		if (randCheckIdx == (DT_RandomQuestP as DT_RandomQuestScript).ShuffledHundredIndex)
			DTDebug("shuffle check fail " + randCheckIdx, 2)
			return 
		elseIf (timeSinceLast < 4.0 && exp > 4)
			; considered same session, but let beginners learn from lucky break
			return
		endIf
		
		if (DTSleep_SettingNotifications.GetValue() > 0.0 && PersuadeTutorialSuccessShown < 1)
						
			self.MessageOnRestTipID = OnRestMsgTipSuccessPersuadeID
		endIf
		
		; re-roll randomizer for next time
		(DT_RandomQuestP as DT_RandomQuestScript).ShuffleOnTimerPublic(15.0)
		
		if (creatureType == 0 || creatureType == CreatureTypeSynth)
		
			if (IntimacySceneCount < 9999)
				IntimacySceneCount += 1
				exp = IntimacySceneCount
			endIf
			DTSleep_IntimateEXP.SetValueInt(IntimacySceneCount)
		
		elseIf (creatureType == CreatureTypeStrong || creatureType == CreatureTypeBehemoth)
		
			; Strong EXP 
			if (IntimacySMCount < 9999)
				IntimacySMCount += 1
				exp = IntimacySMCount
			endIf
			DTSleep_IntimateStrongExp.SetValueInt(IntimacySMCount)
		endIf
		
		if (DTSleep_SettingNotifications.GetValue() > 0.0)
		
			if (exp == 4)
				if (creatureType == 0)
					DTSleep_IntimacySuccessAMsg.Show(exp)
				else
					DTSleep_IntimacySuccessStrongAMsg.Show(exp)
				endIf
				Utility.Wait(0.67)
				
			elseIf (exp >= 12 && exp % 12 == 0)
			
				if (SceneData.CurrentLoverScenCount >= exp)
					
					DTSleep_IntimacySuccessSameLoveMsg.Show(exp)
				else
				
					if (creatureType == 0)
						if (sexAppealScore < 0)
							sexAppealScore = PlayerSexAppeal(false, -1)
						endIf
						DTSleep_IntimacySuccessMsg.Show(exp, sexAppealScore)
						
					elseIf (DTSleep_IntimateEXP.GetValueInt() == 0)
						DTSleep_IntimacySuccessStrongOnlyMsg.Show(exp)
						
					elseIf (DTSleep_IntimateEXP.GetValueInt() < exp)
					
						DTSleep_IntimacySuccessStrongPrefMsg.Show(exp)
					else
						DTSleep_IntimacySuccessStrongBMsg.Show(exp)
					endIf
				endIf
				Utility.Wait(1.8)
			endIf
		endIf
		
	elseIf (creatureType == CreatureTypeDog)
	
		; limit to how often dog may be trained and gaining EXP for self/dog-play
		
		float hoursSinceDogPlay = DTSleep_CommonF.GetGameTimeHoursDifference(intimateTime, DTSleep_IntimateDogTime.GetValue())
		
		if (hoursSinceDogPlay < 3.0)
			return
		endIf
		
		; dog training only counts once per session limit
		if (DTSleep_IntimateDogEXP.GetValueInt() >= IntimateDogTrainEXPLimit || hoursSinceDogPlay > IntimateDogTrainHourLimit)
		
			DTSleep_IntimateDogTime.SetValue(intimateTime)
			if (IntimacyDogCount < 9999)
				IntimacyDogCount += 1
			endIf
			DTSleep_IntimateDogEXP.SetValueInt(IntimacyDogCount)					; record self/dog-play EXP
			
			; update training quest
			if (IntimacyDogCount < IntimateDogTrainEXPLimit && !DTSleep_DogTrainQuestP.IsRunning() && !DTSleep_DogTrainQuestP.IsCompleted())
				self.MessageOnWakeID = OnWakeMsgStartDogTrain
			endIf
			
			if (DTSleep_DogTrainQuestP.IsRunning() && !DTSleep_DogTrainQuestP.IsCompleted())
				(DTSleep_DogTrainQuestP as DTSleep_DogTrainQuestScript).UpdateTrainingCount()
			endIf
			
			if (DTSleep_SettingNotifications.GetValue() > 0.0)
			
				if (IntimacyDogCount == 4)
					DTSleep_IntimacySuccessDogAMsg.Show(IntimacyDogCount)
					Utility.Wait(0.67)
					
				elseIf (IntimacyDogCount == IntimateDogTrainEXPLimit)
				
					DTSleep_IntimacySuccessDogTrainedMsg.Show(IntimacyDogCount)
					Utility.Wait(0.67)
					
				elseIf (IntimacyDogCount > 4 && IntimacyDogCount % 8 == 0)
					
					if (DTSleep_IntimateEXP.GetValueInt() == 0 && IntimacyDogCount == 5)
						; only spent time with dog
						DTSleep_IntimacySuccessDogOnlyMsg.Show(IntimacyDogCount)
						
					elseIf (DTSleep_IntimateEXP.GetValueInt() < IntimacyDogCount)
						; prefer dog
						DTSleep_IntimacySuccessDogPrefMsg.Show(IntimacyDogCount)
					else
						; regular advancement message
						DTSleep_IntimacySuccessDogBMsg.Show(IntimacyDogCount)
					endIf
					Utility.Wait(0.67)
				endIf
			endIf
		endIf
	
	endIf
EndFunction

Function SetSceneForAltFemBody(bool isUndressing)

	if (isUndressing)
		; option setting: 1 = always, 2 = ZeX-only, 3 = EVB/CBBE-only
		int altFemVal = (DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).DTSleep_SettingAltFemBody.GetValueInt()
		if (altFemVal >= 2)
			if ((DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).AnimationSetSupportsZeX(SceneData.AnimationSet))
				if (altFemVal >= 3)
					(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).AltFemBodyEnabled = false
				endIf
			elseIf (altFemVal == 2)
				(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).AltFemBodyEnabled = false
			endIf
		elseIf (altFemVal <= 0)
			(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).AltFemBodyEnabled = false
		endIf
	else
		(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).AltFemBodyEnabled = false
	endIf
EndFunction

IntimateCompanionSet Function SetSceneForDogmeat()

	IntimateCompanionSet nearCompanion = new IntimateCompanionSet
	nearCompanion.Gender = -1
	
	if (IsDogPlaySettingsOn() && PlayerHasActiveDogmeatCompanion.GetValueInt() > 0 && DogmeatCompanionAlias != None && PlayerRef.HasPerk(LoneWanderer01))
			
		Actor dogmeatRef = DogmeatCompanionAlias.GetActorReference()
		
		if (!dogmeatRef.IsDead() && !dogmeatRef.IsUnconscious() && dogmeatRef.GetDistance(PlayerRef) < 900.0 && dogmeatRef.GetSitState() <= 1)

			ResetSceneData(true)
			
			nearCompanion.CompanionActor = dogmeatRef
			nearCompanion.RelationRank = 1  
			
			if (PlayerHasDogTreatsSuper(false) || PlayerHasDogTreats(false))
				if (DTSleep_IntimateDogEXP.GetValueInt() > IntimateDogTrainEXPLimit)
					nearCompanion.RelationRank = 4
				else
					nearCompanion.RelationRank = 3
				endIf
				
				SceneData.CompanionBribeType = IntimateBribeTypeDogTreat
			endIf
			
			if (DTSleep_DogBedIntimateAlias != None)
				DTSleep_DogBedIntimateAlias.Clear()
			endIf
			
			SceneData.MaleRole = dogmeatRef
			SceneData.FemaleRole = PlayerRef
			SceneData.MaleRoleGender = 0
			SceneData.SameGender = false
			if (DressData.PlayerGender == 0)
				SceneData.SameGender = true
			endIf
			SceneData.IsUsingCreature = true
			SceneData.IsCreatureType = CreatureTypeDog
		endIf
	endIf
	
	return nearCompanion

endFunction

Function SetSettingsChairActivDefault()
	if (DTSleep_AdultContentOn.GetValueInt() >= 2.0)
		if ((DTSConditionals as DTSleep_Conditionals).LeitoAnimVers >= 2.10)				; v2.73 - Leito now supports chairs
			DTSleep_SettingChairsEnabled.SetValue(2.0)
		elseIf ((DTSConditionals as DTSleep_Conditionals).IsSavageCabbageActive)
			int gender = (DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).GetGenderForActor(PlayerRef)
			if (gender == 1)
				DTSleep_SettingChairsEnabled.SetValue(2.0)
			else
				DTSleep_SettingChairsEnabled.SetValue(1.0)
			endIf
		else
			; Atomic Lust only 1 chair animation, so ignore
			DTSleep_SettingChairsEnabled.SetValue(1.0)
		endIf
	else
		DTSleep_SettingChairsEnabled.SetValue(1.0)
	endIf
endFunction

Function SetStartSpectators(ObjectReference forFurnitureRef)

	DTSleep_SpectatorQuestP.Start()

	if (SceneData.AnimationSet <= 0 || forFurnitureRef == None)
		(DTSleep_SpectatorQuestP as DTSleep_SpectatorQuestScript).SetTargetObject(PlayerRef)
	else
		(DTSleep_SpectatorQuestP as DTSleep_SpectatorQuestScript).SetTargetObject(forFurnitureRef)
	endIf
	
endFunction

int Function SetUndressBodySwaps()					; v2.60

	if (DTSleep_SettingUndress.GetValueInt() >= 1)			; v3.0 make sure
		(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).BodySwapPlayerEnabled = true
		(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).BodySwapCompanionEnabled = true


		if ((DTSConditionals as DTSleep_Conditionals).IsVulpineRacePlayerActive)
			(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).BodySwapPlayerEnabled = false
		else
			Race pRace = (DTSConditionals as DTSleep_Conditionals).PlayerRace
			if (pRace == None)
				ActorBase playerBase = (PlayerRef.GetBaseObject() as ActorBase)
				if (playerBase != None)
					pRace = playerBase.GetRace()
					(DTSConditionals as DTSleep_Conditionals).PlayerRace = pRace
				endIf
			endIf
			
			if (pRace == None)
				(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).BodySwapPlayerEnabled = false
			elseIf ((DTSConditionals as DTSleep_Conditionals).NanaRace != None && (pRace == (DTSConditionals as DTSleep_Conditionals).NanaRace || (DTSConditionals as DTSleep_Conditionals).NanaRace2))
				(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).BodySwapPlayerEnabled = false
			elseIf (pRace != HumanRace && pRace != GhoulRace)
				(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).BodySwapPlayerEnabled = false
			endIf
		endIf
		
		if (SceneData.RaceRestricted >= 2)
			(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).BodySwapCompanionEnabled = false
		endIf
	endIf

	return 1
endFunction

; v2.60 - some mods may work better without Redress
Function SetRestRedressDefault()
	if ((DTSConditionals as DTSleep_Conditionals).IsUPFPlayerActive)
		DTSleep_SettingUndress.SetValue(3.0)
	else
		DTSleep_SettingUndress.SetValue(1.0)
	endIf
endFunction

int Function SetToggleRedress()

	int cVal = DTSleep_SettingUndress.GetValueInt()
	
	if (cVal >= 1)
		if (cVal <= 2)
			cVal += 2
		else
			cVal -= 2
		endIf
		DTSleep_SettingUndress.SetValueInt(cVal)
		
		ShowToggleRedress(cVal)
	endIf

	return DTSleep_SettingUndress.GetValueInt()
endFunction

Function ShowToggleRedress(int cVal)
	Utility.WaitMenuMode(0.67)
	if (cVal >= 3)
		DTSleep_ToggleRedressOffMsg.Show()
	else
		DTSleep_ToggleRedressOnMsg.Show()
	endIf
endFunction

int Function SetToggleSwapRoles()								; v2.82
	Utility.WaitMenuMode(0.2)
	int val = DTSleep_SettingSwapRoles.GetValueInt()
	if (val <= 0)
		val = 1
	else
		val = 0
	endIf
	DTSleep_SettingSwapRoles.SetValueInt(val)
	
	return val
endFunction

; v2.60 - to toggle force-XOXO or allow-adult
int Function SetToggleXOXOMode()
	int cVal = DTSleep_SettingIntimate.GetValueInt()
	
	if(cVal >= 1)
		if (cVal <= 2)
			if (DTSleep_AdultContentOn.GetValue() >= 2.0)
				cVal += 2
				if (DTSleep_SettingChairsEnabled.GetValue() >= 2.0)
					DTSleep_SettingChairsEnabled.SetValue(1.0)
				endIf
			endIf
		else
			cVal -= 2
		endIf
		DTSleep_SettingIntimate.SetValueInt(cVal)
	endIf
	
	return DTSleep_SettingIntimate.GetValueInt()
endFunction

; -------------------
; forBed: 0 = no, 1=yes, 2=dance-only
; v2.80
Function SetUndressFootwearVals(int forBed)
	; settingVals: 0 for always remove, 1 remove bed only, 2 keep equipped always
	;
	int shoeVal = DTSleep_SettingUndressShoes.GetValueInt()
	int stockingVal = DTSleep_SettingUndressStockings.GetValueInt()
	
	DTDebug("SetUndressFootwearVals forBed = " + forBed + "; shoePref = " + shoeVal + "; sockPref = " + stockingVal, 2)
	
	if (forBed == 1)
		; for bed so decrease value to remove
		if (shoeVal == 1)
			shoeVal = 0
		endIf
		if (stockingVal == 1)
			stockingVal = 0
		endIf
	endIf
	; v2.90 -- added forBed conditions
	if (forBed >= 0 && shoeVal >= 1)
		(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).KeepShoesEquipped = true
	else
		(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).KeepShoesEquipped = false
	endIf
	if (forBed >= 0 && stockingVal >= 1)
		(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).KeepStockingsEquipped = true
	else
		(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).KeepStockingsEquipped = false
	endIf
	
	if (forBed == 2 && stockingVal >= 1)		
		; do we need to override AltFemBody ??
		if ((DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).AltFemBodyEnabled)
			if (DressData.PlayerEquippedStockingsItem != None)
				DTDebug("override AltFemBodyEnabled due to stockings worn", 1)
				(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).AltFemBodyEnabled = false
			endIf
		endIf
	endIf
endFunction
	

;	start Intimate Undress Quest for using bed - best in 3rd-person view
;
bool Function SetUndressForBed(ObjectReference playerBed, Actor companionActor, ObjectReference companionBed, bool observeWinter, bool companionReqNudeSuit, bool playerNaked)

	;DTDebug("  SetUndressForBed beds: " + playerBed + "," + companionBed + ", undressReady: " + IsUndressReady, 2)

	
	(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).EnableCarryBonus = true
	(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).SuspendEquipStore = false
	(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).PlayerIsAroused = false
	(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).AltFemBodyEnabled = false
	SetUndressFootwearVals(1)			; undress shoes and socks?   v2.80
	int undressLevel = DTSleep_SettingUndress.GetValueInt()
	(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).PlayerRedressEnabled = true
	if (undressLevel >= 3)
		(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).PlayerRedressEnabled = false
	endIf
	SetUndressBodySwaps()
	
	if (SleepBedIsPillowBed)
		(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).PlaceBackpackOkay = false
	endIf
	
	;if (IsAdultAnimationAvailable() && companionActor != None && PlayerFriskyScore() > 60)
	;	(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).PlayerIsAroused = true
	;endIf
	
	IntimateWeatherScoreSet wScore = ChanceForIntimateSceneWeatherScore()
	(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).WeatherClass = wScore.wClass
	
	bool includePipBoy = false
	if (DTSleep_SettingUndressPipboy.GetValue() >= 2.0)
		includePipBoy = true
	endIf
	
	return (DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).StartForBedWake(IsUndressReady, playerBed, companionActor, companionBed, observeWinter, companionReqNudeSuit, includePipBoy, playerNaked)
	
EndFunction

bool Function SetUndressForCheck(bool includeClothing, Actor companionActor, bool companionReqNudeSuit = true)

	float partsEnableVal = DTSleep_CaptureExtraPartsEnable.GetValue()
	DTSleep_CaptureExtraPartsEnable.SetValue(0.0)   ; disable to undress	
	
	DTSleep_UndressCheckStartMsg.Show()
	
	(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).EnableCarryBonus = false
	(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).SuspendEquipStore = true
	(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).PlayerIsAroused = false
	(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).AltFemBodyEnabled = false
	SetUndressFootwearVals(1)			; undress shoes and socks?   v2.80
	int undressLevel = DTSleep_SettingUndress.GetValueInt()
	(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).PlayerRedressEnabled = true
	;if (undressLevel >= 3)
	;	(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).PlayerRedressEnabled = false
	;endIf
	SetUndressBodySwaps()
	
	;bool includePipBoy = false
	;if (DTSleep_SettingUndressPipboy.GetValue() >= 1.0)
	;	includePipBoy = true
	;endIf
	
	bool result = (DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).StartForManualStop(includeClothing, companionActor, false, companionReqNudeSuit, None, false)
	
	Utility.Wait(0.1)
	DTSleep_CaptureExtraPartsEnable.SetValue(partsEnableVal) ; re-enable
	
	return result
endFunction

bool Function SetUndressForRespectSit(ObjectReference akFurniture, Actor companionActor = None)

	; normally footwear remains equipped,
	;    but let's make exceptions for dancing or other activities to observe footwear preferences
	
	; v2.15 - check combat and if activate success
	if (akFurniture != None && !PlayerRef.IsInCombat())
		if (akFurniture.Activate(PlayerRef))
			float undressLevel = DTSleep_SettingUndress.GetValue()
			
			if (DTSleep_SettingSave.GetValueInt() >= 3)
				RegisterForRemoteEvent(akFurniture, "OnExitFurniture")
			endIf
			
			if (undressLevel >= 1.0)
				(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).EnableCarryBonus = true
				(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).SuspendEquipStore = false
				(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).PlayerIsAroused = false
				(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).AltFemBodyEnabled = false
				(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).PlayerRedressEnabled = true
				(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).KeepShoesEquipped = true   	; v2.88 change to true
				(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).KeepStockingsEquipped = true  ;   changed to true
				; always redress 
				
				SetUndressFootwearVals(0)					; v2.88 --normally Undress ignores footwear unless remove hat and jacket
				SetUndressBodySwaps()
				
				IntimateWeatherScoreSet wScore = ChanceForIntimateSceneWeatherScore()
				(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).WeatherClass = wScore.wClass
				
				; includeHatsOutside and jackets false to keep on outdoors unless a weight bench
				bool includeHat = false
				if ((DTSConditionals as DTSleep_Conditionals).WeightBenchKY != None && akFurniture.HasKeyword((DTSConditionals as DTSleep_Conditionals).WeightBenchKY))
					includeHat = true
					SetUndressFootwearVals(2)		; same as dance-only may keep shoes on exception v2.90
				else
					; normally footwear stays on, but let's set it anyway    -v2.90
					SetUndressFootwearVals(0)		; not a bed preference
				endIf
				
				; jacket same as hat
				return (DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).StartForFurnitureExitRespect(akFurniture, companionActor, includeHat, includeHat)
			endIf
		endIf
	endIf

	return false
endFunction


;
; note: playerIsNaked always false for dance pole
;
int Function SetUndressPlaySexyDance(ObjectReference furnToPlayObj, bool playerIsNaked, bool compIsRomantic)		; v2.82 added naked parameter

	; v2.60 - fix allow cancel
	if (DTSleep_SettingCancelScene.GetValue() > 0)
		DisablePlayerControlsSleep(-1)	; allow menu to cancel
	else
		DisablePlayerControlsSleep(1)
	endIf
	
	int undressVal = DTSleep_SettingUndress.GetValueInt()		; v3.0 allow if no-undress if naked

	if (furnToPlayObj != None)
		bool adultReady = false
		bool playerReady = false
		bool spectatorOkay = true
		bool furnIsPole = (DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).IsObjectDancePole(furnToPlayObj)
		
		if (undressVal > 0 || playerIsNaked || furnIsPole)
			playerReady = true 
		else
			DTDebug("SetUndressPlaySexyDance -- player not ready for scene!! undressVal = " + undressVal + ", isPole = " + furnIsPole, 1)
		endIf
		
		if (playerReady && (DTSConditionals as DTSleep_Conditionals).SavageCabbageVers >= 1.1 && DTSleep_AdultContentOn.GetValue() >= 2.0 && (DTSConditionals as DTSleep_Conditionals).ImaPCMod)
			if (TestVersion == -2)
				adultReady = true
			endIf
		endIf
		
		SceneData.AnimationSet = 7
			
		(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).FadeEnable = true 
		(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).StartForActorsAndBed(PlayerRef, IntimateCompanionRef, furnToPlayObj, true, true, false)
		(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).PlaceInBedOnFinish = false
		(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).MainActorPositionByCaller = false
		(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SleepBedLocation = (SleepPlayerAlias as DTSleep_PlayerAliasScript).CurrentLocation
		
		
		
		
		bool includePipboy = false
		if (DTSleep_SettingUndressPipboy.GetValue() > 0.0)
			includePipBoy = true
		endIf
		
		; v2.82 --- female player strips-and-dances for lap dance by default,
		;           may swap with female companion
		if (furnIsPole || (DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).GetGenderForActor(PlayerRef) == 1)
		
			if (!furnIsPole && SceneData.SameGender && DTSleep_SettingSwapRoles.GetValueInt() >= 1)
				; swap roles for pair dance, female-player should be male 
				if (PlayerRef == SceneData.FemaleRole)
					SceneData.MaleRole = PlayerRef
					SceneData.FemaleRole = IntimateCompanionRef
				endIf
			else
				; default, make sure player in female role
				if (PlayerRef != SceneData.FemaleRole)
					SceneData.MaleRole = IntimateCompanionRef
					SceneData.FemaleRole = PlayerRef
				endIf
			endIf
		endIf
		
		; v2.60 --- female player always strips-and-dances for lap dance
		;if (furnIsPole || (DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).GetGenderForActor(PlayerRef) == 1)
		;	if (PlayerRef != SceneData.FemaleRole)
		;		SceneData.MaleRole = IntimateCompanionRef
		;		SceneData.FemaleRole = PlayerRef
		;	endIf
		;endIf
		
		; v2.33
		if ((DTSConditionals as DTSleep_Conditionals).IsPlayerCommentsActive)
			ModPlayerCommentsDisable()
		endIf
		
		if (IntimateCompanionRef == None || !adultReady)
			SceneData.AnimationSet = 0
			
			if (DTSleep_VR.GetValueInt() == 2)
				; override VR-mode for dancing  v3.0

				MainQSceneScriptP.GoSceneViewStart(-5)
			else
				MainQSceneScriptP.GoSceneViewStart(0)
			endIf
			
			
			if (IntimateCompanionRef != None && (DTSConditionals as DTSleep_Conditionals).IsCHAKPackActive && undressVal > 0 && compIsRomantic)
				(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).FadeEnable = true
				(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).EnableCarryBonus = true
				(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).SuspendEquipStore = false
				(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).KeepShoesEquipped = true
				(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).KeepStockingsEquipped = true
			
				(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).StartForManualStopRespect(IntimateCompanionRef, true, true)
				
			else 
				(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).FadeEnable = false
				compIsRomantic = false
			endIf
			
			if ((DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).PlayActionDancing(compIsRomantic))
				RegisterForCustomEvent((DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript), "IntimateSequenceDoneEvent")
				
				return 1
			else
				MainQSceneScriptP.GoSceneViewDone(true)
			endIf
		else
			
			; adult ready
			MainQSceneScriptP.GoSceneViewStart(0)
			
			if (DTSleep_CompIntimateAlias != None)
				DTSleep_CompIntimateAlias.Clear()
			endIf
			
			
			if (undressVal > 0)
				
				FadeOutFast(false)
				SetSceneForAltFemBody(true)
				SetUndressBodySwaps()
			else
				FadeOutFast(true)
				Utility.Wait(0.6)
			endIf
			
			; setup and undress
			
			if (furnIsPole)
				; do not include companion
				if (undressVal > 0)
					SetUndressForManualStop(true, None, false, false, None, includePipboy, isDance = true)
				endIf
				
				IntimateCompanionRef.SetRestrained(false)
				if (IntimateCompanionRef.IsInFaction(DTSleep_IntimateFaction))
					IntimateCompanionRef.RemoveFromFaction(DTSleep_IntimateFaction)
				endIf
			elseIf (undressVal > 0)
				(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).CompanionSecondRef = None
				(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).DropSleepClothes = true
				(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).PlaceBackpackOkay = true
				(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).EnableCarryBonus = true
				(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).SuspendEquipStore = false
				SetUndressFootwearVals(2)			; undress shoes and socks?   v2.80
				;(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).PlayerIsAroused = false
				
				(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).PlayerRedressEnabled = true
				if (undressVal >= 3)
					(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).PlayerRedressEnabled = false
				endIf
				IntimateWeatherScoreSet wScore = ChanceForIntimateSceneWeatherScore()
				(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).WeatherClass = wScore.wClass
				
				; v2.82 - if naked keep clothes; set gender based on roles
				int playerGender = -2
				if (SceneData.FemaleRole == PlayerRef)
					playerGender = 1
				else
					playerGender = 0
				endIf

				if (playerIsNaked)
					(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).StartForGirlSexy(IntimateCompanionRef, false, includePipBoy, true, playerGender)
				else
					(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).StartForGirlSexy(IntimateCompanionRef, true, includePipBoy, true, playerGender)
				endIf
				
			endIf
			
			; do scene
			
			if (furnIsPole && (DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).PlayActionDancePole())
			
				RegisterForCustomEvent((DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript), "IntimateSequenceDoneEvent")
				if (spectatorOkay)
					SetStartSpectators(furnToPlayObj)
				endIf
				
				return 1
			elseIf (!furnIsPole && adultReady && (DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).PlayActionDanceSexy())
				if (SceneData.MaleRole != PlayerRef)
					RegisterForRemoteEvent(furnToPlayObj, "OnActivate")			; watch for NPC activate
				endIf
				RegisterForCustomEvent((DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript), "IntimateSequenceDoneEvent")
				if (spectatorOkay)
					SetStartSpectators(furnToPlayObj)
				endIf
				return 1
			else
				Debug.Trace(myScriptName + "PlayActionDancePole or DanceSexy failed... reset scene")
				(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).StopAll()
				SetUndressStop(false)
				FadeInFast()
				MainQSceneScriptP.GoSceneViewDone(true)
				return -1
			endIf
		endIf
	endIf
	return 0
endFunction



; fadeUndressLevel -1 for nothing-no-fade, 0 for hats, 1 for bed, 2 for clothing/naked, 3 for footwear-only, 4 footwear for bed/sofa
; -- animPacks should only include adult packs
;
int Function SetUndressAndFadeForIntimateScene(Actor companionRef, ObjectReference bedRef, int fadeUndressLevel, bool mainActorIsPositioned, bool playSlowMo = false, bool isDogmeatScene = false, bool lowCam = true, int[] animPacks = None, bool isNaked = false, ObjectReference twinBedRef = None, int playerScenePick = -1, bool companionPowerArmorFlag = false)
	
	int seqID = -1
	int evbBestFitVal = (DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).DTSleep_SettingUseLeitoGun.GetValueInt()
	int bt2Val = (DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).DTSleep_SettingUseBT2Gun.GetValueInt()
	bool animationZeX = (DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).AnimationSetSupportsZeX(SceneData.AnimationSet)
	int aafPlaySetting = DTSleep_SettingAAF.GetValueInt()
	int intimateSetting = DTSleep_SettingIntimate.GetValueInt()				; 3 or 4 forces XOXO-mode    v3.0
	bool aafIsReady = IsAAFReady()
	int adultContentVal = DTSleep_AdultContentOn.GetValueInt()
	bool xoxoMode = true
	int undressPrefVal = DTSleep_SettingUndress.GetValueInt()													; assume XOXO then check   v3.0
	
	if (adultContentVal >= 2 && intimateSetting < 3 && intimateSetting >= 1)
		if (IsAdultAnimationAvailable())
			xoxoMode = false							
		endIf
	endIf
	
	DTDebug("SetUndressAndFade (" + fadeUndressLevel + ")....mainActorIsPositioned " + mainActorIsPositioned, 2) 
	
	
	; function follows these steps -- order important
	; 1. limit scene choices
	; 2. startup/reset scene to set bed and companion 
	; 3. set companion prefs before pick scene
	; 4. set animation packs to get sequenceID and animation set
	; 5. check set for camera
	; 6. set camera
	; then undress characters
	
	if (!DTSleep_IntimateAnimQuestP.IsRunning())
		DTSleep_IntimateAnimQuestP.Start()
	endIf
	SceneData.MaleBodySwapEnabled = 1
	
	if (undressPrefVal >= 1)
		SetUndressBodySwaps()
		Utility.Wait(0.1)
	endIf
	
	;Utility.Wait(0.17)
	
	if ((DTSConditionals as DTSleep_Conditionals).IsPlayerCommentsActive)
		ModPlayerCommentsDisable()
	endIf
	
	int camLevel = 0
	MainQSceneScriptP.CamHeightOffset = 0.0
	bool fadePlay = true
	if (fadeUndressLevel < 0)
		fadePlay = false
	endIf
	
	bool testModeOn = false
	if (DTSleep_SettingTestMode.GetValue() > 0.0)
		testModeOn = true
	endIf
	
	;if (SceneData.AnimationSet >= 10 || SceneData.AnimationSet < 5)			; v2.641 - not established yet
	;	aafIsReady = false
	;endIf
	
	
	; ------------------------- setup scene order
	; 1. limit scene choices
	;
	int arousalAngle = -1
	if (adultContentVal >= 2 && !xoxoMode && TestVersion == -2 && (Debug.GetPlatformName() as bool))  ; v2.73 fix limited to player is male-role so same-gender works
		if (DressData.PlayerGender == 0 && SceneData.MaleRole == PlayerRef)			
			
			;if (evbBestFitVal > 0)
			;	if (evbBestFitVal == 1)
			;		arousalAngle = 0
			;	elseIf (bt2Val > 0)
			;		arousalAngle = Utility.RandomInt(0,1)
			;	endIf
			;elseIf (bt2Val > 0)
			;	if (animationZeX)
			;		arousalAngle = 0
			;	else
			;		arousalAngle = Utility.RandomInt(0,1)
			;	endIf
			;endIf
			
		elseIf (DressData.PlayerGender == 1 && SceneData.SameGender)
			; for strap-on toy
			arousalAngle = 0
		endIf
	endIf
	
	;--------------------------------------------------
	; 2. startup/reset scene to set bed and companion 
	;
	(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).StartForActorsAndBed(PlayerRef, companionRef, bedRef, fadePlay, mainActorIsPositioned, playSlowMo)
	(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SleepBedTwinRef = twinBedRef
	(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SleepBedLocation = (SleepPlayerAlias as DTSleep_PlayerAliasScript).CurrentLocation

	if (SleepBedIsPillowBed)
		(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SleepBedIsPillowBed = true
	endIf
	
	; --------------------------------------------
	; ** 3. ** set companion prefs before pick scene
	;
	UpdateIntimateAnimPreferences(playerScenePick)
	
	; --------------------------------------
	; ** 4. ** set animation packs to get sequenceID and animation set
	;
	if (adultContentVal >= 1 && (DTSConditionals as DTSleep_Conditionals).ImaPCMod)
		; set animation packs
		if (animPacks.Length > 0 && undressPrefVal >= 1)
			; v3.0 added undress condition since we now allow disable undressing for hug/kiss scenes
			
			if (arousalAngle >= 0 && playerScenePick < 0)				; fix-- removed isPlayer condition v2.73
				if (aafIsReady || DressData.PlayerGender == 1)
					(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).RestrictScenesToErectAngle = arousalAngle
				endIf
			endIf
			
			if (IntimateCompanionSecRef != None)
				if (IntimateCompanionSecRef == IntimateCompanionRef)
					IntimateCompanionSecRef = None
					DTDebug(" 2nd lover same as main lover removed  - " + IntimateCompanionRef, 2)
				else
					; must swap before get scene picking
					DTDebug(" 2nd lover ready, check for swaps...", 2)
					CheckSwapSceneRolesForSameGender()
				endIf
			endIf
						
			
			
			; also sets SceneData.AnimationSet if valid ID found and may clear 2nd lovers if not needed
			seqID = (DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetAnimationPacksAndGetSceneID(animPacks, false, MyNextSceneOnSameFurnitureIsFreeSID)

			
			;if (seqID >= 500 && aafIsReady && arousalAngle >= 0 && DressData.PlayerGender == 0)
			;	if (SceneData.AnimationSet == 8)
			;		arousalAngle = 0
			;	endIf
			;else
				arousalAngle = -1
			;endIf
			
			if (seqID <= 99)
				SceneData.AnimationSet = 0
			endIf
			
			; check to clear 2nd lover and swap back if not needed
			if (SceneData.SecondFemaleRole == None && SceneData.SecondMaleRole == None)
				;DTDebug(" clear 2nd lover - not needed by iAnim", 2)
				ClearIntimateSecondCompanion()
			endIf
		endIf
	endIf
	
	MyNextSceneOnSameFurnitureIsFreeSID = -1					; reset, no longer need
	
	; ----------------------------------------------------
	; ** 5. ** check set for camera    ; v2.60 - updated to force for more scenes and not on table
	;
	bool isTable = false		 ; v2.70 - updated to exclude some table scenes we want to use lowCam
	Form baseBedForm = None
	int sceneViewVal = (DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).DTSleep_SettingAACV.GetValueInt()
	
	if (seqID >= 100)
		if (sceneViewVal < 3 && bedRef.HasKeyword((DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).AnimFurnPicnickTableKY))
			if ((seqID >= 150 && seqID < 500) || (seqID >= 650 && seqID < 900) || (seqID >= 500 && sceneViewVal == 2))
				isTable = true
			endIf
		elseIf (sceneViewVal < 3 && (DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).IsObjPoolTable(bedRef, baseBedForm))
			if ((seqID >= 150 && seqID < 500) || (seqID >= 650 && seqID < 900) || (seqID >= 500 && sceneViewVal == 2))
				isTable = true
			endIf
		elseIf ((DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).IsObjTable(bedRef, baseBedForm))
			isTable = true
		endIf
		
		if (!lowCam && seqID >= 100 && !isTable)
			if (seqID >= 590 && seqID < 650)
				lowCam = true
			elseIf (seqID >= 900)
				lowCam = true
			elseIf (seqID < 600)
				int baseID = DTSleep_CommonF.BaseIDForFullSequenceID(seqID)
				;DTDebug(" set lowcam for base-id " + baseID, 3)
				if (baseID < 50)
					lowCam = true	; force for non-stand scenes
				endIf
			endIf
		endIf
	endIf
	
	if (aafIsReady && seqID >= 500)
		; check if will actually play using AAF   - v2.73  ---- v2.75 - need to also set strictlyID true
		if (!(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).IsSCeneAAFSafe(seqID, true))
			aafIsReady = false
		endIf
	endIf
	
	if (SceneData.AnimationSet >= 5 && SceneData.AnimationSet < 12)
		if (aafIsReady)
			; v2.74 also check glitch
			if (companionPowerArmorFlag == false && aafPlaySetting < 3)
				; double-check because flag may have been cleared during search or not set for same companion
				if (IsCompanionPowerArmorGlitched(companionRef, true))
					companionPowerArmorFlag = true
				endIf
			endIf
			
			if (aafPlaySetting < 3 && companionPowerArmorFlag)
				; force fade for AAC-play
				fadePlay = true
				
				if (SceneData.AnimationSet == 9)
					lowCam = true
				endIf
			
				if (DTSleep_SettingNotifications.GetValue() > 0.0 && MyPAGlitchMessageCount < 4)	; v2.75 limit number of times warning displays
					EnablePlayerControlsSleep()
					DisablePlayerControlsSleep(0)
					Utility.Wait(0.1)
					
					if (MyPAGlitchMessageCount >= 1 && MyPAGlitchTipCount < 1)
						DTDebug("set MyPAGlitchTipCount to 1 so it will display", 2)
						MyPAGlitchTipCount = 1				; warned once before now mark to show tip   v2.75
					endIf
					; show warning
					DTSleep_PersuadeBusyWarnPAFlagMsg.Show()
					MyPAGlitchMessageCount += 1
					Utility.Wait(1.1)
					EnablePlayerControlsSleep()
					DisablePlayerControlsSleep(2)
				endIf
			else
				camLevel = -1  ; disable custom
				lowCam = false
				if (aafPlaySetting == 2)
					; cancel fade (expected	already set to false)
					fadePlay = false
				elseIf (aafPlaySetting >= 3)
					; disable tip since using setting
					MyPAGlitchTipCount = 2
				endIf
			endIf
		elseIf (SceneData.AnimationSet == 9)
			lowCam = true
		endIf
	elseIf (SceneData.AnimationSet == 4)
		if (seqID >= 490)
			camLevel = -1
		endIf
	elseIf (SceneData.AnimationSet == 0 || seqID < 100)
		camLevel = -1
	endIf
				
	; v2.74 moved here since already establishing check above		
	if (companionPowerArmorFlag && aafPlaySetting < 3)
		(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).PlayAAFEnabled = false
	else
		(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).PlayAAFEnabled = true
	endIf
	
	(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).FadeEnable = fadePlay
	
	; ---------------------------------
	; ** 6. ** set camera
	;
	if (seqID >= 536 && seqID <= 537)
		; PA repair station  - v2.70
		MainQSceneScriptP.CamHeightOffset = 18.0
	
	elseIf (seqID < 100 || mainActorIsPositioned || (DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SceneIDAtPlayerPosition(seqID))
		; check VR-mode v3.0 
		camLevel = 0
		if (DTSleep_VR.GetValueInt() == 2 && (DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SceneOkayLookViewSit(seqID, bedRef) < 0)
			
			camLevel = -5   ; override to force third-person camera
		endIf
	elseIf (seqID == 683)
		; override for doggy at seat  v2.73
		camLevel = 2
	elseIf (lowCam)
		if (bedRef != None && bedRef.HasKeyword(AnimFurnFloorBedAnims))
			MainQSceneScriptP.CamHeightOffset = -18.0
		endIf
		if (isDogmeatScene)
			camLevel = 2
		else
			camLevel = 1
		endIf
	elseIf (camLevel >= 0)
		MainQSceneScriptP.CamHeightOffset = -12.0
	endIf
	
	;Debug.Trace(myScriptName + " SetUndressFade lowCam: " + camLevel + " / " + lowCam + " (AnimationSet: " + SceneData.AnimationSet + ")") 
	MainQSceneScriptP.GoSceneViewStart(camLevel)

	; -------------------------------------------------------------------------------------------
	; --------------scene setup done, now undress if undressing
	;
	
	if (fadePlay)
		if (undressPrefVal <= 0)
			; fade-fast for no undress -- v3.0
			FadeOutFast(true)
			Utility.WaitMenuMode(0.5)
		else
			FadeOutFast(false)
			Utility.WaitMenuMode(0.1)
		endIf
		
	endIf
	
	if (fadeUndressLevel >= 0 && undressPrefVal > 0)
		
		bool includeClothing = true
		
		; set 2nd lover if any
		(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).CompanionSecondRef = IntimateCompanionSecRef
		
		Utility.Wait(0.08)
		
		
		if (seqID < 100 || (seqID >= 490 && seqID < 500))			; also include CHAK stand-embrace v3.0
			includeClothing = false
			if (fadeUndressLevel == 2)
				; hug/dance: lower undress to sleep clothes / respect level
				fadeUndressLevel = 1
			endIf
		elseIf (fadeUndressLevel < 2 && !(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SceneIDIsCuddle(seqID))
			if (!xoxoMode)
				; uh-oh, caller expected dance or cuddle, but picker chose sexy scene!
				DTDebug("SetUndressAndFadeForIntimateScene undress-level set to respect/sleep, but ID  " + seqID, 2)
				fadeUndressLevel = 2
			else
				DTDebug("SetUndressAndFadeForIntimateScene found invalid scene picked!! (" + seqID + ") forcing hug! (98)", 1)
				seqID = 98
				includeClothing = false
			endIf
		endIf
		
		if (!isNaked)						; v1.57 - if naked on activate bed, take it all off
		
			if (xoxoMode || SceneData.AnimationSet == 0 || animPacks.Length == 0 || SceneData.AnimationSet == 4)
				; out of respect hug/kiss/cuddle defaults to clothed or sleep-outfit with exceptions
				; -----------------------------------------------------------------------------
				; v3.0 changes for standing and bed cuddles
				; --------------------------
				; standing hug/kiss
				;    - XOXO: sleep clothes or mostly dressed  
				;    - R: sleep pref  (v3 change)
				; bed cuddles:
				;   - XOXO: sleep clothes (not bathrobe which may flip up) or sleep preferences
				;	- R: sleep preferences or naked
				; -----------------------------------------------------------------------
				includeClothing = false
				arousalAngle = -1
				
				if (seqID >= 450 && seqID < 490)
					; CHAK furniture (not bed) cuddles
					if (fadeUndressLevel > 0 && fadeUndressLevel < 3)
						fadeUndressLevel = 3			; observe footwear and remove jackets
					endIf
					
				elseIf ((seqID >= 400 && seqID < 450) || playerScenePick == 2 || seqID == 501)
					; bed cuddles 
					; allow other sleepwear - no bathrobe
					if ((undressPrefVal == 2 || undressPrefVal == 4) && !xoxoMode)
						; always undress unless already in sleep clothes except bathrobe
						if ((DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).IsActorWearingSleepwear(PlayerRef, true))
							fadeUndressLevel = 1
						elseIf (fadeUndressLevel == 2)
							includeClothing = true
						endIf
					elseIf ((DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).IsActorCarryingSleepwear(PlayerRef, None, true) && (DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).IsActorCarryingSleepwear(IntimateCompanionRef, None, true))
						; has sleep clothes; follow sleep-undress preferences
						fadeUndressLevel = 1
						
					elseIf (fadeUndressLevel < 3)
						; no sleep outfit, follow respect undress preferences
						fadeUndressLevel = 0
					endIf
				
				elseIf (fadeUndressLevel == 2)
					; stand hug/kiss
					if ((DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).IsActorCarryingSleepwear(PlayerRef, None, false) && (DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).IsActorCarryingSleepwear(IntimateCompanionRef, None, false))
						; bathrobe okay
						fadeUndressLevel = 1		
					elseIf (xoxoMode)
						fadeUndressLevel = 0
					elseIf (undressPrefVal == 2 || undressPrefVal == 4)
						includeClothing = true							; allow adult-mode  to embrace naked
					else 
						fadeUndressLevel = 3
					endIf
				endIf
				
			elseIf (SceneData.AnimationSet == 5)
				if (seqID >= 548 && seqID <= 549)
					; partial undress check for hugs
					if (fadeUndressLevel >= 2)
						fadeUndressLevel = 1			; sleep clothes / respect
					elseIf (mainActorIsPositioned)
						includeClothing = false
					endIf
				elseIf (seqID == 501)
					; bed cuddle
					if (undressPrefVal == 2 || undressPrefVal == 4)
						; undress always unless already in sleep clothes
						if ((DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).IsActorWearingSleepwear(PlayerRef, true))
							fadeUndressLevel = 1
						else
							includeClothing = true
							fadeUndressLevel = 2
						endIf
					
					; allow other sleepwear, not bathrobe - what about dresses??    v2.87
					elseIf ((DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).IsActorCarryingSleepwear(PlayerRef, None, true) && (DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).IsActorCarryingSleepwear(IntimateCompanionRef, None, true))
						fadeUndressLevel = 1
					elseIf (fadeUndressLevel < 3)
						fadeUndressLevel = 3			; observe footwear, no change into sleepwear due to bathrobe flipping up
						includeClothing = false
					endIf
				endIf
			endIf
		else
			DTDebug("... SetUndressAndFadeForIntimateScene ... player is Naked...", 1)
		endIf
		
		(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).ForceEVBNude = false
		
		if (aafIsReady)
			if (includeClothing && arousalAngle >= 0 && DressData.PlayerGender == 0 && adultContentVal >= 2)
				bool forceEVB = false
				if (SceneData.AnimationSet >= 5)
					if (seqID >= 800 && seqID < 900)
						; incompatible with BodyTalk
						(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).ForceEVBNude = true
					elseIf (seqID >= 600 && seqID < 700)
						(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).ForceEVBNude = true
					endIf
					arousalAngle = (DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).SetPlayerArousedLevel(arousalAngle)
				endIf
			endIf
		endIf
		
		bool includePipboy = false
		
		if (DTSleep_SettingUndressPipboy.GetValue() > 0.0)
			includePipBoy = true
		endIf
		
		; for intimacy scenes no winter check and companion always uses nude suit
		
		; check alt-female nude-suit for specific scenes - only need to disable since undress defaults to enabled and checks setting
		SetSceneForAltFemBody(fadeUndressLevel == 2)
		bool doPlacePack = true
		bool doPlaceSleepOutfit = true			; added v3.0
		
		if (seqID == 797)
			; railing   - v2.70
			doPlacePack = false
		elseIf (bedRef != None && (DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).IsObjSedan(bedRef))
			doPlacePack = false
		elseIf (mainActorIsPositioned || (DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SceneIDAtPlayerPosition(seqID))
			; drop clothes not good for standing scenes v3.0
			doPlacePack = false
			doPlaceSleepOutfit = false
		endIf
		
		; first check respect
		if (fadeUndressLevel >= 0 && fadeUndressLevel <= 4 && fadeUndressLevel != 2)
			(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).DropSleepClothes = false
			(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).EnableCarryBonus = true
			(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).SuspendEquipStore = false
			if (SleepBedIsPillowBed)
				(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).PlaceBackpackOkay = false
			else
				(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).PlaceBackpackOkay = true
			endIf

			(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).PlayerRedressEnabled = true
			if (undressPrefVal >= 3 && fadeUndressLevel == 1)
				(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).PlayerRedressEnabled = false
			endIf
			
			IntimateWeatherScoreSet wScore = ChanceForIntimateSceneWeatherScore()
			(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).WeatherClass = wScore.wClass
					
			; check if normal respect or else sleep clothes
			if (fadeUndressLevel == 0 || fadeUndressLevel >= 3)
				; normal respect
				; if at bed or special furniture, observe footwear preferences and remove jackets  v2.83
				bool remJacketsOutside = false
				
				if (fadeUndressLevel >= 3 || (DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).IsObjBed(bedRef))
					remJacketsOutside = true
					if (fadeUndressLevel == 4)
						; bed/sofa cuddles, mark footwear for bed
						SetUndressFootwearVals(1)
						
					;elseIf (seqID >= 400 && seqID < 490 && seqID != 460)
					;	; bed/sofa cuddles, mark footwear for bed
					;	SetUndressFootwearVals(1)
					else
						SetUndressFootwearVals(0)			; not in sleep clothes so don't mark as bed even if a bed for standing scenes
					endIf
				else
					(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).KeepShoesEquipped = true
					(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).KeepStockingsEquipped = true
				endIf
			
				(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).StartForManualStopRespect(companionRef, true, remJacketsOutside)
				
			else
				; sleep clothes
				SetUndressFootwearVals(1)   ; check for bed first -v2.90
				
				if ((DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).StartForManualStopSleepwear(companionRef, bedRef, isNaked) == false)
					; no sleep clothes found... 
					; ? could check undress pref for always
					SetUndressFootwearVals(0)
					(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).StartForManualStopRespect(companionRef, true, true)
				endIf
			endIf
			
		elseIf (isDogmeatScene || SceneData.IsCreatureType == CreatureTypeBehemoth || SceneData.IsCreatureType == CreatureTypeHandy)		; v2.40 added behemoth, robot
		
			SetUndressForManualStop(true, None, false, false, bedRef, includePipboy)
			
		elseIf (SceneData.CompanionInPowerArmor || SceneData.IsCreatureType == CreatureTypeSynth)		; v2.17 - added synth; v3.0 added scenePick
		
			SetUndressForManualStop(includeClothing, None, false, false, bedRef, includePipboy)
			
				
		elseIf (seqID >= 536 && seqID <= 537)
			; v2.25 -- PA Station - only female get naked 
			(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).CompanionSecondRef = None
			(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).DropSleepClothes = doPlaceSleepOutfit
			(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).PlaceBackpackOkay = doPlacePack
			(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).EnableCarryBonus = true
			(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).SuspendEquipStore = false
			SetUndressFootwearVals(0)			; undress shoes and socks?   v2.80

			(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).PlayerRedressEnabled = true
			if (undressPrefVal >= 3)
				(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).PlayerRedressEnabled = false
			endIf
		
			; v2.82 use gender for undress
			int playerGender = -2
			if (SceneData.FemaleRole == PlayerRef)
				playerGender = 1
			else
				playerGender = 0
			endIf
		
			(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).StartForGirlSexy(companionRef, true, includePipBoy, true, playerGender)
		else
			
			; normal undress for sex
			bool companionReqNudeSuit = true    ; always for sex to make sure companion outfit stays off due to auto-equip
			bool footwearOK = true				; some scenes may be unsuitable for footwear   v2.90
			if (seqID == 1030)
				DTDebug("no-shoes for Scene ID " + seqID, 2)
				footwearOK = false
			endIf
			; bool undressAll, Actor companionActor, bool observeWinter, bool companionReqNudeSuit, ObjectReference optionalBedRef = None, bool includePipBoy = false, bool dropSleepGear = true, bool carryBonus = true, bool placeBackPack = true, bool isDance = false, bool footwearOK = true)
			; FIX doPlacePack in wrong spot   - v2.90
			SetUndressForManualStop(includeClothing, companionRef, false, companionReqNudeSuit, bedRef, includePipboy, doPlaceSleepOutfit, true, doPlacePack, false, footwearOK)
			
			if (SceneData.SecondFemaleRole != None)
				Armor toyArmor = (DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).GetStrapOnForActor(SceneData.SecondFemaleRole, false, None, true)
				if (toyArmor != None)
					SceneData.SecondFemaleRole.UnequipItem(toyArmor, false, true)
				endIf
			endIf
			
			if (SceneData.MaleRoleGender == 0)
				if (bt2Val <= 0.0 || (SceneData.AnimationSet > 4 && SceneData.AnimationSet != 8))
					; compatible animation packs
					if (SceneData.MaleRole == PlayerRef)
						if (DressData.PlayerEquippedIntimateAttireItem != None)
							SceneData.MaleBodySwapEnabled = 0
						endIf
					elseIf (DressData.CompanionEquippedIntimateAttireItem != None)
						SceneData.MaleBodySwapEnabled = 0
					endIf
				endIf
			endIf
		endIf
		Utility.Wait(0.24)
		
		; get toys from storage?
		if (SceneData.ToyFromContainer)
			if (bedRef != None && bedRef.HasKeyword(DTSleep_OutfitContainerKY) && SceneData.AnimationSet > 0 && SceneData.AnimationSet != 4 && !SceneData.HasToyEquipped && SceneData.ToyArmor != None)
				
				bedRef.RemoveItem(SceneData.ToyArmor, 1, true, SceneData.MaleRole)
			else
				SceneData.ToyFromContainer = false
			endIf
		endIf
	elseIf (undressPrefVal > 0)
		DTDebug(" ?? SetUndressAndFadeForIntimateScene  - no undress situation (fadeUndressLevel = " + fadeUndressLevel + ") -- do hats", 1)
		if (SceneData.AnimationSet == 0 || (SceneData.AnimationSet >= 4 && SceneData.AnimationSet <= 5))
			; no undress - let's do hats
			(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).StartForManualStopRespect(companionRef, true, false)
		endIf
	endIf
	
	;Utility.Wait(0.24)

	EnablePlayerControlsSleep()
	Utility.Wait(0.04)
	
	return seqID
endFunction

bool Function SetUndressForCompanionSleepwear(Actor companionActor, bool companionReqNudeSuit)

	(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).DropSleepClothes = false
	(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).SuspendEquipStore = false
	(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).AltFemBodyEnabled = false
	
	return (DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).StartForCompanionSleepwear(companionActor, companionReqNudeSuit)
EndFunction

; start Intimate Undress Quest - best in 3rd-person view
; 
bool Function SetUndressForManualStop(bool undressAll, Actor companionActor, bool observeWinter, bool companionReqNudeSuit, ObjectReference optionalBedRef = None, bool includePipBoy = false, bool dropSleepGear = true, bool carryBonus = true, bool placeBackPack = true, bool isDance = false, bool footwearOK = true)
	
	(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).DropSleepClothes = dropSleepGear
	if (SleepBedIsPillowBed)
		(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).PlaceBackpackOkay = false
	else
		(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).PlaceBackpackOkay = placeBackPack
	endIf
	(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).EnableCarryBonus = carryBonus
	(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).SuspendEquipStore = false
	;(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).PlayerIsAroused = false
	IntimateWeatherScoreSet wScore = ChanceForIntimateSceneWeatherScore()
	(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).WeatherClass = wScore.wClass
	int undressLevel = DTSleep_SettingUndress.GetValueInt()
	(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).PlayerRedressEnabled = true
	if (undressLevel >= 3)
		(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).PlayerRedressEnabled = false
	endIf
	
	int footwearForBed = 1
	if (isDance)
		footwearForBed = 2
	elseIf (optionalBedRef == None)
		if (!footwearOK)
			footwearForBed = -1
		else
			footwearForBed = 0
		endIf
		
	elseIf ((DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).IsObjBed(optionalBedRef) == false)
		if (!footwearOK)
			; v2.90
			footwearForBed = -1
		
		elseIf ((DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).IsObjShower(optionalBedRef, None))
			; v2.82 - no footwear for shower
			footwearForBed = -1
		else
			footwearForBed = 0
		endIf
	endIf

	SetUndressFootwearVals(footwearForBed)			; undress shoes and socks?   v2.80
	
	return (DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).StartForManualStop(undressAll, companionActor, observeWinter, companionReqNudeSuit, optionalBedRef, includePipBoy)
	
EndFunction

bool Function SetUndressForNoStop(bool carryBonus = false)
	
	(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).DropSleepClothes = false
	(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).PlaceBackpackOkay = false
	(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).EnableCarryBonus = carryBonus
	(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).PlayerIsAroused = false
	IntimateWeatherScoreSet wScore = ChanceForIntimateSceneWeatherScore()
	(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).WeatherClass = wScore.wClass
	(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).AltFemBodyEnabled = false
	int undressLevel = DTSleep_SettingUndress.GetValueInt()
	(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).PlayerRedressEnabled = true
	if (undressLevel >= 3)
		(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).PlayerRedressEnabled = false
	endIf
	SetUndressFootwearVals(0)			; undress shoes and socks?   v2.80
	
	return (DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).StartForNeverRedress()
	
EndFunction

; for beds that have their own activate animations - undress first before activating
; -see Sleep Together Camp
;
bool Function SetUndressForSpecialAnimBed(ObjectReference targetRef, bool companionRequiresNudeSuit, bool playerNaked)

	GoThirdPerson(true)
	DisablePlayerControlsSleep()
			
	bool alwaysUndress = IsPlayerOkayToUndressForBed(4.0, targetRef)
	
	bool observeWinter = true
	if (alwaysUndress || DTSleep_SettingUndress.GetValue() == 2.0 || DTSleep_SettingUndress.GetValue() == 4.0)
		observeWinter = false
	endIf
		
	bool result = SetUndressForBed(targetRef, IntimateCompanionRef, None, observeWinter, companionRequiresNudeSuit, playerNaked)
	Utility.Wait(0.67)
	EnablePlayerControlsSleep()
	Utility.Wait(0.06)

	return result
endFunction

Function SetUndressStop(bool slowly)
	if (DTSleep_IntimateUndressQuestP != None)
		
		if ((DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).UndressedForType >= 5)
			; equip system had initialized
			StartTimer(4.0, UndressedInitTipTimerID)
		endIf
		
		(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).StopAll(slowly)
	endIf
EndFunction

;
;  Display prompt for intimate scene check - yes, "Rest" (no), cancel, or (optional) display true chance score
;
int Function ShowIntimatePrompt(int checkVal, IntimateCompanionSet nearCompanion, int sexAppealScore, float totalChance, IntimateLocationHourSet locHourChance, float gameTime, bool dogmeatScene)

	bool showBeginnerPrompt = true
	float hoursSinceLastFail = DTSleep_CommonF.GetGameTimeHoursDifference(gameTime, IntimateCheckLastFailTime)
	float hoursSinceLastDogFail = DTSleep_CommonF.GetGameTimeHoursDifference(gameTime, IntimateCheckLastDogFailTime)
	float hoursSinceLastIntimate = DTSleep_CommonF.GetGameTimeHoursDifference(gameTime, IntimateLastTime)
	float daysSinceLastIntimate = gameTime - IntimateLastTime
	int addictCount = (PlayerRef.GetValue(AddictionCountAV) as int)
	int dogEXP = DTSleep_IntimateDogEXP.GetValueInt()
	float hoursSinceLastDogIntimate = 100.0
	float hoursSinceWarnLim = 8.0
	if (sexAppealScore < 50)
		hoursSinceWarnLim = 12.0
	elseIf (sexAppealScore > 120)
		hoursSinceWarnLim = 5.0
	endIf
	
	; v2.35  same for chair; remove bribe type for high chance
	if (SceneData.IsCreatureType == 0 && SceneData.CompanionBribeType > 0 && SceneData.CompanionBribeType != IntimateBribeNaked)
		if (totalChance > 67.67)
			SceneData.CompanionBribeType = 0
		endIf
	endIf

	; need intro prompt?
	
	if (dogmeatScene)
	
		if (dogEXP > 0)
			showBeginnerPrompt = false
			hoursSinceLastDogIntimate = DTSleep_CommonF.GetGameTimeHoursDifference(gameTime, DTSleep_IntimateDogTime.GetValue())
			float checkDays = gameTime - DTSleep_IntimateDogTime.GetValue()
			if (checkDays < daysSinceLastIntimate)
				; more recent for dog
				daysSinceLastIntimate = gameTime - DTSleep_IntimateDogTime.GetValue()
			endIf
		endIf
		
	elseIf (nearCompanion.CompanionActor == StrongCompanionRef && DTSleep_IntimateStrongExp.GetValueInt() > 0)
		
		showBeginnerPrompt = false
		
	elseIf (DTSleep_IntimateEXP.GetValueInt() > 0)
	
		showBeginnerPrompt = false
	endIf
	
	; -------------- request for show all (checkVal-3) must come first

	if (checkVal == 4)
	
		; ----- show chances -----
		
		int chanceScore = locHourChance.ChanceReal
		if (DTSleep_DebugMode.GetValueInt() <= 1)
			chanceScore = locHourChance.Chance
			if (chanceScore <= -200)
				chanceScore = locHourChance.ChanceReal
			endIf
		endIf
		checkVal = DTSleep_IntimateCheckShowChanceMsg.Show(sexAppealScore, chanceScore, totalChance)
		
	elseIf (locHourChance.LocTypeName == "crime-area")
	
		checkVal = DTSleep_IntimateCheckCrimeMsg.Show(sexAppealScore, daysSinceLastIntimate)
		
	; -------------------- hour limits, holidays, mid-sleep, and addiction warnings -----------
		
	elseIf (dogmeatScene && dogEXP > 0 && dogEXP < IntimateDogTrainEXPLimit && hoursSinceLastDogIntimate < IntimateDogTrainHourLimit)
	
		if (hoursSinceLastDogIntimate < 1.67)
			checkVal = DTSleep_IntimateCheckRecentDogHourMsg.Show(sexAppealScore, dogEXP)
		else
			checkVal = DTSleep_IntimateCheckRecentDogMsg.Show(sexAppealScore, hoursSinceLastDogIntimate, dogEXP)
		endIf	
		
	elseIf (!showBeginnerPrompt && !dogmeatScene && (hoursSinceLastFail < (hoursSinceWarnLim * 2.0) || hoursSinceLastIntimate < hoursSinceWarnLim))
		
		if (hoursSinceLastFail < hoursSinceLastIntimate)
			checkVal = DTSleep_IntimateCheckRecentMsg.Show(sexAppealScore, hoursSinceLastFail)
		else
			checkVal = DTSleep_IntimateCheckRecentMsg.Show(sexAppealScore, hoursSinceLastIntimate)
		endIf
		
	elseIf (locHourChance.HolidayBonus > 0)
	
		; ------ show holiday bonus prompt 
		int baseLocChance = locHourChance.ChanceReal - locHourChance.HolidayBonus
		
		if (locHourChance.HolidayType == 1)
			; New Year - just use Independence Day (fireworks)
			checkVal = DTSleep_IntimateCheckHolidayIndpMsg.Show(sexAppealScore, baseLocChance, locHourChance.HolidayBonus)
		elseIf (locHourChance.HolidayType == 2)
			checkVal = DTSleep_IntimateCheckHolidayValMsg.Show(sexAppealScore, baseLocChance, locHourChance.HolidayBonus)
		elseIf (locHourChance.HolidayType == 3)
			checkVal = DTSleep_IntimateCheckHolidayPatrickMsg.Show(sexAppealScore, baseLocChance, locHourChance.HolidayBonus)
		elseIf (locHourChance.HolidayType == 4)
			checkVal = DTSleep_IntimateCheckHolidayNWMsg.Show(sexAppealScore, baseLocChance, locHourChance.HolidayBonus)
		elseIf (locHourChance.HolidayType == 5)
			checkVal = DTSleep_IntimateCheckHolidayRobCoMsg.Show(sexAppealScore, baseLocChance, locHourChance.HolidayBonus)
		elseIf (locHourChance.HolidayType == 6)
			checkVal = DTSleep_IntimateCheckHolidayIndpMsg.Show(sexAppealScore, baseLocChance, locHourChance.HolidayBonus)
		elseIf (locHourChance.HolidayType == 7)
			checkVal = DTSleep_IntimateCheckHolidayGWDMsg.Show(sexAppealScore, baseLocChance, locHourChance.HolidayBonus)
		elseIf (locHourChance.HolidayType == 8)
			checkVal = DTSleep_IntimateCheckHolidayHallowMsg.Show(sexAppealScore, baseLocChance, locHourChance.HolidayBonus)
		elseIf (locHourChance.HolidayType == 9)
			checkVal = DTSleep_IntimateCheckHolidayMrPebMsg.Show(sexAppealScore, baseLocChance, locHourChance.HolidayBonus)
		elseIf (locHourChance.HolidayType == 10)
			checkVal = DTSleep_IntimateCheckHolidayTeaDayMsg.Show(sexAppealScore, baseLocChance, locHourChance.HolidayBonus)
		elseIf (locHourChance.HolidayType >= 11 && locHourChance.HolidayType <= 12)
			checkVal = DTSleep_IntimateCheckHolidayChristmasMsg.Show(sexAppealScore, baseLocChance, locHourChance.HolidayBonus)
		else
			checkVal = DTSleep_IntimatecheckHolidayMsg.Show(sexAppealScore, baseLocChance, locHourChance.HolidayBonus)
		endIf
		
	elseIf (locHourChance.MidSleepBonusChance >= 25)
		
		; show mid-sleep bonus
		if (daysSinceLastIntimate >= 1.0)
		
			checkVal = DTSleep_IntimateCheckMidSleepMsg.Show(sexAppealScore, daysSinceLastIntimate)
		else
			checkVal = DTSleep_IntimateCheckMidSleepHrsMsg.Show(sexAppealScore, hoursSinceLastIntimate)
		endIf
		
		; ------- fail and addictions
		
	elseIf (!dogmeatScene && IntimateCheckFailCount >= 3 && hoursSinceLastFail < 20.0)
		
		checkVal = DTSleep_IntimateCheckFailsMsg.Show(IntimateCheckFailCount)
		
	elseIf (!dogmeatScene && addictCount >= 3)
	
		checkVal = DTSleep_IntimateCheckAddictMsg.Show(sexAppealScore, locHourChance.Chance)
			
	; --------- owned bed ----------
	
	elseIf (!showBeginnerPrompt && !dogmeatScene && locHourChance.BedOwned)
	
		if (daysSinceLastIntimate >= 1.0)
			checkVal = DTSleep_IntimateCheckOwnedBedMsg.Show(sexAppealScore, daysSinceLastIntimate)
		else
			checkVal = DTSleep_IntimateCheckOwnedHrsBedMsg.Show(sexAppealScore, hoursSinceLastIntimate)
		endIf
		
	; ------------ location uncertainty -----------------

	elseIf (!dogmeatScene && locHourChance.Chance <= -200 && locHourChance.ChanceReal < 28)			; v2.16 -- added ChanceReal requirement for less confusion
	
		; --- rolled-uncertain or truly dangerous ---------
		
		if (locHourChance.ChanceReal <= -200 || showBeginnerPrompt)

			checkVal = DTSleep_IntimateCheckWarnNoChanceMsg.Show(sexAppealScore)
		else
			
			checkVal = DTSleep_IntimateCheckWarnUnsureMsg.Show(sexAppealScore, daysSinceLastIntimate)
		endIf
		
	elseIf (!dogmeatScene && locHourChance.ChanceReal < 0 && sexAppealScore < 5 && daysSinceLastIntimate < 1.667)
	
		; --------- No chance (5%) reminder prompt ----
		
		checkVal = DTSleep_IntimateCheckWarnNoChanceMsg.Show(sexAppealScore)
	
	elseIf (!showBeginnerPrompt && locHourChance.NearActors > 1 && ((locHourChance.ChanceReal - locHourChance.LocAdj) < -23) && locHourChance.NpcAdj < -9)
	
		; --------- bad area / too many NPCs ------ avoid revealing hidden NPCs nearby and provide hints
		
		bool displayEstimateOK = true
		bool tooDangerous = false
		int nearbyActorEstimate = locHourChance.NearActors - 1   ; subtract 1 for companion
		if (nearbyActorEstimate > 6)
			nearbyActorEstimate = 6
		endIf
		
		if (locHourChance.LocChanceType < 0)
			
			; private area
			checkVal = DTSleep_IntimateCheckWarnNearbyMsg.Show(sexAppealScore, daysSinceLastIntimate, locHourChance.NearActors - 1)
		else
			; non-private area
			
			if (locHourChance.LocChanceType == LocActorChanceSettled || locHourChance.LocChanceType == LocActorChanceTown)
			
				if (locHourChance.NearActors > 7)
					displayEstimateOK = false
				endIf
			
			elseIf (locHourChance.LocChanceType == LocActorChanceWild)
				if (locHourChance.ChanceReal < -30 || nearbyActorEstimate > 3)
					displayEstimateOK = false
					tooDangerous = true
				endIf
			elseIf (locHourChance.ChanceReal < -20)
				displayEstimateOK = false
				tooDangerous = true
			elseIf (locHourChance.NearActors > 4)
				displayEstimateOK = false
			endIf
			
			if (tooDangerous)
				checkVal = DTSleep_IntimateCheckDangerMsg.Show(sexAppealScore, daysSinceLastIntimate)
				
			elseIf (displayEstimateOK)
			
				if (dogmeatScene)
					checkVal = DTSleep_IntimateCheckDogmeatNearbyMsg.Show(sexAppealScore, daysSinceLastIntimate, nearbyActorEstimate)
					
				elseIf (IntimateCompanionRef == StrongCompanionRef && locHourChance.WeatherAdj != 0)
				
					checkVal = DTSleep_IntimateCheckStrongNearbyMsg.Show(sexAppealScore, daysSinceLastIntimate, nearbyActorEstimate)
				else
					checkVal = DTSleep_IntimateCheckWarnNearbyMsg.Show(sexAppealScore, daysSinceLastIntimate, nearbyActorEstimate)
				endIf

			elseIf (dogmeatScene)
			
				checkVal = DTSleep_IntimateCheckDogmeatNearbyMaxMsg.Show(sexAppealScore)
				
			elseIf (IntimateCompanionRef == StrongCompanionRef)
			
				checkVal = DTSleep_IntimateCheckStrongNearbyMaxMsg.Show(sexAppealScore)
			else
				checkVal = DTSleep_IntimateCheckWarnUnsureMsg.Show(sexAppealScore, daysSinceLastIntimate)
			endIf
		endIf
	
	elseIf (dogmeatScene)
	
		;  ------ Dogmeat -----------
	
		if (hoursSinceLastDogFail < 2.0)
			checkVal = DTSleep_IntimateCheckRecentDogFailMsg.Show(sexAppealScore, hoursSinceLastDogFail)
			
		elseIf (showBeginnerPrompt)
			checkVal = DTSleep_IntimateDogmeatBeginMsg.Show(sexAppealScore, locHourChance.Chance)
			
		elseIf (nearCompanion.RelationRank <= 1)
		
			; dog - no food, not trained
			checkVal = DTSleep_IntimateDogmeatCheckMsg.Show(sexAppealScore, daysSinceLastIntimate, locHourChance.Chance)
			
		elseIf (nearCompanion.RelationRank == 4)
		
			; dog must have been trained and has food
			if (locHourChance.Chance > IntimateLocChancePerfectScore)
				checkVal = DTSleep_IntimateDogmeatCheckTrainedBonusPerfectMsg.Show(sexAppealScore, daysSinceLastIntimate)
			elseIf (locHourChance.Chance > IntimateLocChanceGoodScore)
				checkVal = DTSleep_IntimateDogmeatCheckTrainedBonusMsg.Show(sexAppealScore, daysSinceLastIntimate)
			elseIf (locHourChance.Chance > IntimateLocChancePoorScore)
				checkVal = DTSleep_IntimateDogmeatCheckTrainedBonusPoorMsg.Show(sexAppealScore, daysSinceLastIntimate)
			else
				checkVal = DTSleep_IntimateDogmeatCheckTrainedBonusRiskyMsg.Show(sexAppealScore, daysSinceLastIntimate)
			endIf
			
			
		elseIf (DTSleep_IntimateDogEXP.GetValueInt() > IntimateDogTrainEXPLimit)
		
			; dog trained, but no food
			if (locHourChance.Chance > IntimateLocChancePerfectScore)
				checkVal = DTSleep_IntimateDogmeatCheckTrainedPerfectMsg.Show(sexAppealScore, daysSinceLastIntimate)
			elseIf (locHourChance.Chance > IntimateLocChanceGoodScore)
				checkVal = DTSleep_IntimateDogmeatCheckTrainedMsg.Show(sexAppealScore, daysSinceLastIntimate)
			elseIf (locHourChance.Chance > IntimateLocChancePoorScore)
				checkVal = DTSleep_IntimateDogmeatCheckTrainedPoorMsg.Show(sexAppealScore, daysSinceLastIntimate)
			else
				checkVal = DTSleep_IntimateDogmeatCheckTrainedRiskyMsg.Show(sexAppealScore, daysSinceLastIntimate)
			endIf
			
		else
			; has dog food, not trained yet
			if (locHourChance.Chance > IntimateLocChancePerfectScore)
				checkVal = DTSleep_IntimateDogmeatCheckBonusPerfectMsg.Show(sexAppealScore, daysSinceLastIntimate)
			elseIf (locHourChance.Chance > IntimateLocChanceGoodScore)
				checkVal = DTSleep_IntimateDogmeatCheckBonusMsg.Show(sexAppealScore, daysSinceLastIntimate)
			elseIf (locHourChance.Chance > IntimateLocChancePoorScore)
				checkVal = DTSleep_IntimateDogmeatCheckBonusPoorMsg.Show(sexAppealScore, daysSinceLastIntimate)
			else
				checkVal = DTSleep_IntimateDogmeatCheckBonusRiskyMsg.Show(sexAppealScore, daysSinceLastIntimate)
			endIf
			
		endIf
		
	elseIf (IntimateCompanionRef == StrongCompanionRef)
		
		; -------------------------- Strong --------------
		
		if (showBeginnerPrompt)
		
			if (locHourChance.Chance > IntimateLocChanceGoodScore)
				checkVal = DTSleep_IntimateStrongIntroMsg.Show(sexAppealScore)
			elseIf (locHourChance.Chance > IntimateLocChancePoorScore)
				checkVal = DTSleep_IntimateStrongIntroPoorMsg.Show(sexAppealScore)
			else
				checkVal = DTSleep_IntimateStrongIntroRiskyMsg.Show(sexAppealScore)
			endIf
			
			
		elseIf (nearCompanion.RelationRank <= 2)
			
			; no meat - Strong want meat!
			
			if (locHourChance.Chance > IntimateLocChancePerfectScore)
				checkVal = DTSleep_IntimateStrongCheckPerfectMsg.Show(sexAppealScore, daysSinceLastIntimate)
			elseIf (locHourChance.Chance > IntimateLocChanceGoodScore)
				checkVal = DTSleep_IntimateStrongCheckMsg.Show(sexAppealScore, daysSinceLastIntimate)
			elseIf (locHourChance.Chance > IntimateLocChancePoorScore)
				checkVal = DTSleep_IntimateStrongCheckPoorMsg.Show(sexAppealScore, daysSinceLastIntimate)
			else
				checkVal = DTSleep_IntimateStrongCheckRiskyMsg.Show(sexAppealScore, daysSinceLastIntimate)
			endIf
			
		elseIf (SceneData.CompanionBribeType == IntimateBribeTypeMeat)
			; higher rank, Strong like naked or meat
			
			if (locHourChance.Chance > IntimateLocChancePerfectScore)
				checkVal = DTSleep_IntimateStrongCheckBonusPerfectMsg.Show(sexAppealScore, daysSinceLastIntimate)
			elseIf (locHourChance.Chance > IntimateLocChanceGoodScore)
				checkVal = DTSleep_IntimateStrongCheckBonusMsg.Show(sexAppealScore, daysSinceLastIntimate)
			elseIf (locHourChance.Chance > IntimateLocChancePoorScore)
				checkVal = DTSleep_IntimateStrongCheckBonusPoorMsg.Show(sexAppealScore, daysSinceLastIntimate)
			else
				checkVal = DTSleep_IntimateStrongCheckBonusRiskyMsg.Show(sexAppealScore, daysSinceLastIntimate)
			endIf
			
			; v2.35 new prompts for no meat at higher exp
		elseIf (locHourChance.Chance > IntimateLocChanceGoodScore)
			checkVal = DTSleep_IntimateCheckStrongHLGoodMsg.Show(sexAppealScore, daysSinceLastIntimate)
		elseIf (locHourChance.Chance > IntimateLocChancePoorScore)
			checkVal = DTSleep_IntimateCheckStrongHLPoorMsg.Show(sexAppealScore, daysSinceLastIntimate)
		else
			checkVal = DTSleep_IntimateCheckStrongHLRiskyMsg.Show(sexAppealScore, daysSinceLastIntimate)

		endIf
		
	elseIf (showBeginnerPrompt)
	
		; ----- Beginner ---------
	
		if (locHourChance.Chance > IntimateLocChanceGoodScore)
			checkVal = DTSleep_IntimateCheckIntroMsg.Show(sexAppealScore)
		elseIf (locHourChance.Chance > IntimateLocChancePoorScore)
			checkVal = DTSleep_IntimateCheckIntroPoorMsg.Show(sexAppealScore)
		else
			checkVal = DTSleep_IntimateCheckIntroRiskyMsg.Show(sexAppealScore)
		endIf
		
		
	elseIf (SceneData.CompanionBribeType > 0 && SceneData.CompanionBribeType != IntimateBribeNaked)
	
		; -------  Bribes ----------- player has bribe and should offer it
		
		if (SceneData.CompanionBribeType == IntimateBribeTypeCandy)
		
			if (locHourChance.Chance > IntimateLocChanceGoodScore)
				checkVal = DTSleep_IntimateCheckBribeCandyMsg.Show(sexAppealScore, daysSinceLastIntimate)
			elseIf (locHourChance.Chance > IntimateLocChancePoorScore)
				checkVal = DTSleep_IntimateCheckBribeCandyPoorMsg.Show(sexAppealScore, daysSinceLastIntimate)
			else
				checkVal = DTSleep_IntimateCheckBribeCandyRiskyMsg.Show(sexAppealScore, daysSinceLastIntimate)
			endIf
		elseIf (SceneData.CompanionBribeType == IntimateBribeTypeBooze)
		
			if (locHourChance.Chance > IntimateLocChanceGoodScore)
				checkVal = DTSleep_IntimateCheckBribeBoozeMsg.Show(sexAppealScore, daysSinceLastIntimate)
			elseIf (locHourChance.Chance > IntimateLocChancePoorScore)
				checkVal = DTSleep_IntimateCheckBribeBoozePoorMsg.Show(sexAppealScore, daysSinceLastIntimate)
			else
				checkVal = DTSleep_IntimateCheckBribeBoozeRiskyMsg.Show(sexAppealScore, daysSinceLastIntimate)
			endIf
			
		elseIf (SceneData.CompanionBribeType == IntimateBribeTypeMutfruit)
			
			if (locHourChance.Chance > IntimateLocChanceGoodScore)
				checkVal = DTSleep_IntimateCheckBribeMutfruitMsg.Show(sexAppealScore, daysSinceLastIntimate)
			elseIf (locHourChance.Chance > IntimateLocChancePoorScore)
				checkVal = DTSleep_IntimateCheckBribeMutfruitPoorMsg.Show(sexAppealScore, daysSinceLastIntimate)
			else
				checkVal = DTSleep_IntimateCheckBribeMutfruitRiskyMsg.Show(sexAppealScore, daysSinceLastIntimate)
			endIf
			
		elseIf (SceneData.CompanionBribeType == IntimateBribeSynthTreat)
		
			if (locHourChance.Chance > IntimateLocChanceGoodScore)
				checkVal = DTSleep_IntimateCheckBribeSynthTreatMsg.Show(sexAppealScore, daysSinceLastIntimate)
			elseIf (locHourChance.Chance > IntimateLocChancePoorScore)
				checkVal = DTSleep_IntimateCheckBribeSynthTreatPoorMsg.Show(sexAppealScore, daysSinceLastIntimate)
			else
				checkVal = DTSleep_IntimateCheckBribeSynthTreatRiskyMsg.Show(sexAppealScore, daysSinceLastIntimate)
			endIf
			
		else
			; uh-oh - revert to normal
			Debug.Trace(myScriptName + " ShowIntimatePrompt ---- bad bribe type found: " + SceneData.CompanionBribeType)
			SceneData.CompanionBribeType = -2
			ShowIntimatePrompt(checkVal, nearCompanion, sexAppealScore, totalChance, locHourChance, gameTime, dogmeatScene)
			
		endIf
			
	elseIf (SceneData.CurrentLoverScenCount > 4)
	
		; ------ Lover Counts ---- remaining true - how romantic!
		
		if (SceneData.CurrentLoverScenCount >= DTSleep_IntimateEXP.GetValueInt() && DTSleep_IntimateStrongExp.GetValueInt() == 0)
		
			if (locHourChance.Chance > IntimateLocChancePerfectScore)
				checkVal = DTSleep_IntimateCheckSingleLoverPerfectMsg.Show(sexAppealScore, daysSinceLastIntimate)
			elseIf (locHourChance.Chance > IntimateLocChanceGoodScore)
				checkVal = DTSleep_IntimateCheckSingleLoverMsg.Show(sexAppealScore, daysSinceLastIntimate)
			elseIf (locHourChance.Chance > IntimateLocChancePoorScore)
				checkVal = DTSleep_IntimateCheckSingleLoverPoorMsg.Show(sexAppealScore, daysSinceLastIntimate)
			else
				checkVal = DTSleep_IntimateCheckSingleLoverRiskyMsg.Show(sexAppealScore, daysSinceLastIntimate)
			endIf
		else
			if (locHourChance.Chance > IntimateLocChancePerfectScore)
				checkVal = DTSleep_IntimateCheckSameLoverPerfectMsg.Show(sexAppealScore, SceneData.CurrentLoverScenCount, daysSinceLastIntimate)
			elseIf (locHourChance.Chance > IntimateLocChanceGoodScore)
				checkVal = DTSleep_IntimateCheckSameLoverMsg.Show(sexAppealScore, SceneData.CurrentLoverScenCount, daysSinceLastIntimate)
			elseIf (locHourChance.Chance > IntimateLocChancePoorScore)
				checkVal = DTSleep_IntimateCheckSameLoverPoorMsg.Show(sexAppealScore, SceneData.CurrentLoverScenCount, daysSinceLastIntimate)
			else
				checkVal = DTSleep_IntimateCheckSameLoverRiskyMsg.Show(sexAppealScore, SceneData.CurrentLoverScenCount, daysSinceLastIntimate)
			endIf
		endIf
		

	elseIf (nearCompanion.RelationRank <= 2)
	
		; just friend
		if (locHourChance.Chance > IntimateLocChancePerfectScore)
			checkVal = DTSleep_IntimateCheckFriendPerfectMsg.Show(sexAppealScore, daysSinceLastIntimate)
		elseIf (locHourChance.Chance > IntimateLocChanceGoodScore)
			if (daysSinceLastIntimate >= 1.0)
				checkVal = DTSleep_IntimateCheckFriendMsg.Show(sexAppealScore, daysSinceLastIntimate)
			else
				checkVal = DTSleep_IntimateCheckFriendHrsMsg.Show(sexAppealScore, hoursSinceLastIntimate)
			endIf
		elseIf (locHourChance.Chance > IntimateLocChancePoorScore)
			checkVal = DTSleep_IntimateCheckFriendPoorMsg.Show(sexAppealScore, daysSinceLastIntimate)
		else
			checkVal = DTSleep_IntimateCheckFriendRiskyMsg.Show(sexAppealScore, daysSinceLastIntimate)
		endIf
		
		
	elseIf (nearCompanion.RelationRank == 3)
	
		; infatuated
		if (locHourChance.Chance > IntimateLocChancePerfectScore)
			if (daysSinceLastIntimate >= 1.0)
				checkVal = DTSleep_IntimateInfatCheckPerfectMsg.Show(sexAppealScore, daysSinceLastIntimate)
			else
				checkVal = DTSleep_IntimateCheckInfatPerfectHrsMsg.Show(sexAppealScore, hoursSinceLastIntimate)
			endIf
		elseIf (locHourChance.Chance > IntimateLocChanceGoodScore)
			if (daysSinceLastIntimate >= 1.0)
				checkVal = DTSleep_IntimateInfatCheckMsg.Show(sexAppealScore, daysSinceLastIntimate)
			else
				checkVal = DTSleep_IntimateCheckInfatHrsMsg.Show(sexAppealScore, hoursSinceLastIntimate)
			endIf
		elseIf (locHourChance.Chance > IntimateLocChancePoorScore)
			checkVal = DTSleep_IntimateInfatCheckPoorMsg.Show(sexAppealScore, daysSinceLastIntimate)
		else
			checkVal = DTSleep_IntimateInfatCheckRiskyMsg.Show(sexAppealScore, daysSinceLastIntimate)
		endIf
		
	else
	
		; --- romantic companion  - default
		if (locHourChance.Chance > IntimateLocChancePerfectScore)
			if (daysSinceLastIntimate >= 1.0)
				checkVal = DTSleep_IntimateCheckLoverPerfectMsg.Show(sexAppealScore, daysSinceLastIntimate)
			else
				checkVal = DTSleep_IntimateCheckLoverPerfectHrsMsg.Show(sexAppealScore, hoursSinceLastIntimate)
			endIf
		elseIf (locHourChance.Chance > IntimateLocChanceGoodScore)
			if (daysSinceLastIntimate >= 1.0)
				checkVal = DTSleep_IntimateCheckMsg.Show(sexAppealScore, daysSinceLastIntimate)
			else
				checkVal = DTSleep_IntimateCheckHrsMsg.Show(sexAppealScore, hoursSinceLastIntimate)
			endIf
		elseIf (locHourChance.Chance > IntimateLocChancePoorScore)
			checkVal = DTSleep_IntimateCheckLoverPoorMsg.Show(sexAppealScore, daysSinceLastIntimate)
		else
			checkVal = DTSleep_IntimateCheckLoverRiskyMsg.Show(sexAppealScore, daysSinceLastIntimate)
		endIf
	endIf
	
	return checkVal

endFunction

int Function ShowChairPrompt(int checkVal, IntimateCompanionSet nearCompanion, int sexAppealScore, float totalChance, IntimateLocationHourSet locHourChance, float gameTime)
	
	if (SceneData.IsCreatureType == CreatureTypeDog)
		Message basicMsg = DTSleep_ChairCheckDogTrainedMsg
		if (DTSleep_IntimateDogEXP.GetValue() < IntimateDogTrainEXPLimit)
			if (SceneData.CompanionBribeType > 0)
				basicMsg = DTSleep_ChairCheckDogBonusMsg
			else
				basicMsg = DTSleep_ChairCheckDogNoBonusMsg
			endIf
		endIf
		
		return ShowFurnitureSpecPrompt(basicMsg, DTSleep_ChairCheckBeginMsg, DTSleep_ChairCheckShowChanceMsg, DTSleep_ChairCheckDogRecentMsg, DTSleep_ChairCheckDogNPCMsg, checkVal, nearCompanion, sexAppealScore, totalChance, locHourChance, gameTime, true)
	endIf
	
	return ShowFurnitureSpecPrompt(DTSleep_ChairCheckMsg, DTSleep_ChairCheckBeginMsg, DTSleep_ChairCheckShowChanceMsg, DTSleep_ChairCheckRecentMsg, DTSleep_ChairCheckNPCMsg, checkVal, nearCompanion, sexAppealScore, totalChance, locHourChance, gameTime, true)
endFunction

int Function ShowDeskPrompt(int checkVal, IntimateCompanionSet nearCompanion, int sexAppealScore, float totalChance, IntimateLocationHourSet locHourChance, float gameTime)

	return ShowFurnitureSpecPrompt(DTSleep_DeskCheckMsg, DTSleep_DeskCheckBeginMsg, DTSleep_DeskCheckShowChanceMsg, DTSleep_DeskCheckRecentMsg, DTSleep_DeskCheckNPCMsg, checkVal, nearCompanion, sexAppealScore, totalChance, locHourChance, gameTime, false)

endFunction

int Function ShowPAStationPrompt(int checkVal, IntimateCompanionSet nearCompanion, int sexAppealScore, float totalChance, IntimateLocationHourSet locHourChance, float gameTime)

	return ShowFurnitureSpecPrompt(DTSleep_PASCheckMsg, DTSleep_PASCheckBeginMsg, DTSleep_PASCheckShowChanceMsg, DTSleep_PASCheckRecentMsg, DTSleep_PASCheckNPCMsg, checkVal, nearCompanion, sexAppealScore, totalChance, locHourChance, gameTime, false)
endFunction

int Function ShowFurnitureSpecPrompt(Message prompt, Message promptBegin, Message promptChance, Message promptRecent, Message promptNPCWarn, int checkVal, IntimateCompanionSet nearCompanion, int sexAppealScore, float totalChance, IntimateLocationHourSet locHourChance, float gameTime, bool isChair)

	float hoursSinceLastFail = DTSleep_CommonF.GetGameTimeHoursDifference(gameTime, IntimateCheckLastFailTime)
	float hoursSinceLastIntimate = DTSleep_CommonF.GetGameTimeHoursDifference(gameTime, IntimateLastTime)
	float daysSinceLastIntimate = gameTime - IntimateLastTime
	bool showBeginnerPrompt = true
	int nearbyActorEstimate = locHourChance.NearActors - 1   ; subtract 1 for companion
	if (nearbyActorEstimate > 9)
		nearbyActorEstimate = 9
	endIf
	
	; v2.16 remove gift for high chance
	if (SceneData.IsCreatureType == 0 && SceneData.CompanionBribeType > 0 && SceneData.CompanionBribeType != IntimateBribeNaked)
		if (totalChance > 66.67)
			SceneData.CompanionBribeType = 0
		endIf
	endIf
	
	if (nearCompanion.CompanionActor == StrongCompanionRef && DTSleep_IntimateStrongExp.GetValueInt() > 0)
		
		showBeginnerPrompt = false
		
	elseIf (DTSleep_IntimateEXP.GetValueInt() > 0)
	
		showBeginnerPrompt = false
	endIf
	
	if (SceneData.IsCreatureType == CreatureTypeDog)
		if (DTSleep_IntimateDogEXP.GetValueInt() > 0)
			showBeginnerPrompt = false
		endIf
		daysSinceLastIntimate = gameTime - DTSleep_IntimateDogTime.GetValue()
	endIf
	
	; -------------- request for show all (checkVal-3) must come first

	if (checkVal == 2)
	
		; ----- show chances -----
		
		int chanceScore = locHourChance.ChanceReal
		if (DTSleep_DebugMode.GetValueInt() <= 1)
			chanceScore = locHourChance.Chance
			if (chanceScore <= -200)
				chanceScore = locHourChance.ChanceReal
			endIf
		endIf
		checkVal = promptChance.Show(sexAppealScore, chanceScore, totalChance)
	
	elseIf (locHourChance.LocTypeName == "crime-area")
	
		if (isChair)
			checkVal = DTSleep_ChairCheckCrimeMsg.Show(sexAppealScore, daysSinceLastIntimate)
		else
			checkVal = DTSleep_FurnUseCheckCrimeMsg.Show(sexAppealScore, daysSinceLastIntimate)
		endIf
	
	elseIf (showBeginnerPrompt)
	
		checkVal = promptBegin.Show(sexAppealScore)
		
	; -------------------- hour limits, voyuer, holidays? -----------
		
	elseIf (nearbyActorEstimate > 1 && hoursSinceLastIntimate > 2.0 && DTSleep_AdultContentOn.GetValue() >= 2.0 && DTSleep_SettingChairsEnabled.GetValue() >= 2.0)
		; v2.53 only warn for adult and limit by hours
		checkVal = promptNPCWarn.Show(sexAppealScore, daysSinceLastIntimate, nearbyActorEstimate)
		
	elseIf (hoursSinceLastFail < 20.0 || hoursSinceLastIntimate < 12.0)
		
		if (hoursSinceLastFail < hoursSinceLastIntimate)
			checkVal = promptRecent.Show(sexAppealScore, hoursSinceLastFail)
		else
			checkVal = promptRecent.Show(sexAppealScore, hoursSinceLastIntimate)
		endIf
	else
		checkVal = prompt.Show(sexAppealScore, daysSinceLastIntimate)
	endIf
	
	return checkVal
endFunction

int Function ShowPilloryPrompt(int checkVal, IntimateCompanionSet nearCompanion, int sexAppealScore, float totalChance, IntimateLocationHourSet locHourChance, float gameTime)
	
	return ShowFurnitureSpecPrompt(DTSleep_PilloryCheckMsg, DTSleep_PilloryCheckBeginMsg, DTSleep_PilloryCheckShowChanceMsg, DTSleep_PilloryCheckRecentMsg, DTSleep_PilloryCheckNPCMsg, checkVal, nearCompanion, sexAppealScore, totalChance, locHourChance, gameTime, false)
endFunction

Function ShowSceneIgnorePreferencePicker()
	
	int sid = DTSleep_SIDIgnoreOK.GetValueInt()
	int responseToMsg = -1
	DTSleep_SIDIgnoreOK.SetValueInt(-2)				; clear now
	
	if (sid >= 100 && sid < 2000)
		responseToMsg = DTSleep_PrefSceneIgnoreMsg.Show(sid)
		if (responseToMsg == 1)
			(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetSceneIDToIgnore(sid)
		endIf
	endIf
	
	
endFunction

Function ShowSceneClearIgnoreList()
	(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetSceneIDToIgnoreClearAll()
endFunction

; show player Scene View preference for Clone/not for Look-view/Orbit-view  v2.70
Function ShowSceneViewPreferencePicker()
	; update for message
	int prefTotalCount = (DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).PlayerPrefSceneTotalCount()
	DTSleep_SceneViewPrefCount.SetValueInt(prefTotalCount)
	int responseToMsg = -1
	int sid = (DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).DTSleep_IntimateIdleID.GetValueInt()
	
	if (sid >= 100 && sid < 2000)
		if (SceneData.IntimateSceneViewType == 3 || SceneData.IntimateSceneViewType == 5)
			; was cloned scene, ask to add to no-clone list
			responseToMsg = DTSleep_PrefSceneCloneOffAddMsg.Show()
			
		elseIf (SceneData.IntimateSceneViewType == 4 || SceneData.IntimateSceneViewType == 6)
			; was a no-clone scene, ask to add to clone list
			responseToMsg = DTSleep_PrefSceneCloneOnAddMsg.Show()
		elseIf (SceneData.IntimateSceneViewType != 1 && SceneData.IntimateSceneViewType != 2)
			DTDebug("ShowSceneViewPreferencePicker called, but nothing to show!!! --IntimateSceneViewType = " + SceneData.IntimateSceneViewType, 1)
		endIf
		
		if (responseToMsg == 1)
			; first clear any existing sid from both lists
			(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).PlayerPrefSceneRemoveSID(sid)
			
			; add to appropriate list
			if (SceneData.IntimateSceneViewType == 3 || SceneData.IntimateSceneViewType == 5)
				(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).PlayerPrefSceneAddSIDNoClone(sid)
			else
				(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).PlayerPrefSceneAddSIDCloneOkay(sid)
			endIf
			
		elseIf (responseToMsg == 2)
			; clear all preferences
			(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).PlayerPrefSceneClear()
		endIf
	else
		DTDebug("ShowSceneViewPreferencePicker invalid scene ID found: " + sid, 1)
	endIf
endFunction

Function Shutdown(bool completely = false)
	
	Utility.WaitMenuMode(1.2)
	
	
	if (DTSleep_ShutdownConfirmMsg.Show() == 1)
		
		UnregisterForMenuOpenCloseEvent("WorkshopMenu")
		
		Utility.WaitMenuMode(0.1)
		DTSleep_SettingModActive.SetValue(-1.0)
		DTSleep_SettingModMCMCtl.SetValue(0.0)
		
		if (DTSleep_DogTrainQuestP.IsRunning())
			DTSleep_DogTrainQuestP.SetStage(60)  ; pause / hide display
		endIf
		
		if (DTSleep_IntimateTourQuestP.IsRunning())
			DTSleep_SettingTourEnabled.SetValue(0.0)
			(DTSleep_IntimateTourQuestP as DTSleep_IntimateTourQuestScript).UpdateLocationObjectiveDisplay()
		endIf
		
		; v2.44 make sure recover quest stopped
		if (DTSleep_PlayerUsingBed.GetValueInt() > 0)
			(DTSleep_HealthRecoverQuestP as DTSleep_HealthRecoverQuestScript).StopAllCancel()
		elseIf ((DTSleep_HealthRecoverQuestP as DTSleep_HealthRecoverQuestScript).DTSleep_SettingFastSleepEffect.GetValueInt() > 0)
			(DTSleep_HealthRecoverQuestP as DTSleep_HealthRecoverQuestScript).FastSleepEffectOff(true)
		endIf

		PlayerSleepPerkRemove()
		
		UnregisterForAllRemoteEvents()
		
		DTSleep_SettingIntimate.SetValue(-1.0)
		
		(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).StopAll(false, -3)
		
		(SleepPlayerAlias as DTSleep_PlayerAliasScript).Shutdown()
		
		if (DTSleep_TrueLoveQuestP.IsRunning())
			DTSleep_TrueLoveQuestP.Stop()
		endIf
		
		Utility.WaitMenuMode(0.7)
		
		; start-up others  v3.0
		if (DTSleep_IsNNESActive.GetValueInt() == 1)
			ModSetNNESToggle()
		endIf
		
		if (completely)
			; perma-stop this quest and undress quest
			; TODO: doesn't do anything different so do we need this?
			
			DTSleep_SettingModActive.SetValue(-2.0)
			
			if (DTSleep_IntimateAnimQuestP.IsRunning())
				DTSleep_IntimateAnimQuestP.Stop()
			endIf
		
			DTSleep_IntimateUndressQuestP.Stop()
			
			if (DTSleep_EncounterQuestP.IsRunning())
				DTSleep_EncounterQuestP.Stop()
			endIf
		
			self.Stop()
		else
			DTSleep_ShutdownMsg.Show()
		endIf
	endIf
EndFunction

float SirTime = 2.290

bool Function TestIntSceneReplaySameFurniture(ObjectReference furnObj, bool clearStatus)
	
	if (MyNextSceneOnSameFurnitureIsFreeSID > 0)
			
		if (furnObj != None && furnObj == (DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SleepBedRef)
			if (IntimacyTestCount < 3)
				if (clearStatus)
					DTDebug("replay same furniture as Test Scene auto-pass with count " + IntimacyTestCount, 1)
					; clear MyNextSceneOnSameFurnitureIsFreeSID later since we need the SID number
				endIf
				
				return true
				
			elseIf (clearStatus)
				DTDebug("no replay scene - count max reached", 1)
				MyNextSceneOnSameFurnitureIsFreeSID = 0			; clear now
			endIf
		elseIf (clearStatus)
			DTDebug("no replay scene - different furniture, " + furnObj + " != " + (DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SleepBedRef, 1)
			MyNextSceneOnSameFurnitureIsFreeSID = 0			; clear now
		endIf
	endIf
	
	return false
EndFunction

bool Function TestIntSceneEnabled(ObjectReference furnObj)

	if (TestIntSceneReplaySameFurniture(furnObj, true))
		return true
	endIf

	if (DTSleep_SettingTestMode.GetValue() > 0.0 && IntimacyTestCount < 5)

		float sceneCheckTime = DTSleep_SceneTestMode.GetValue()
		
		if (sceneCheckTime == 0.0 && SirTime == 2.290 && DTSleep_DebugMode.GetValue() == 3.0)
			return true
			
		elseIf (sceneCheckTime > 0.0)
			bool okayGo = false
			float curTime = Utility.GetCurrentGameTime()
			float timeSince = DTSleep_CommonF.GetGameTimeHoursDifference(curTime, sceneCheckTime)
			
			if (timeSince < 0.1667)
				if (SirTime == 2.290 && (DTSConditionals as DTSleep_Conditionals).LocTourStat == -1)
					okayGo = true 
				elseIf (SirTime > 20.0 && (curTime - SirTime) > 28.8 && (DTSConditionals as DTSleep_Conditionals).LocTourStat == 2)
					okayGo = true
				endIf
			endIf
			
			if (okayGo)
				SirTime = curTime
				(DTSConditionals as DTSleep_Conditionals).LocTourStat = 2
				DTDebug("Test Scene enabled... ", 1)
				DTSleep_SettingTestMode.SetValue(-2.0)

				return true
			endIf
		endIf
	endIf
	
	return false
EndFunction

Function TestModeOutput()

	; --------------Test Mode Output --------------------
	
	if (DTSleep_SettingTestMode.GetValue() > 0.0 && DTSleep_DebugMode.GetValue() >= 1.0)
	
		Debug.Trace(myScriptName + " =====================================================================")
		Debug.Trace(myScriptName + "       version: " + DTSleep_Version.GetValue() + " ---- TEST MODE ---- ")
		Debug.Trace(myScriptName + "       VR-mode: " + DTSleep_VR.GetValueInt())
		Debug.Trace(myScriptName + "  UndressQuest: " + DTSleep_IntimateUndressQuestP.IsRunning())
		Debug.Trace(myScriptName + "      Location: " + (SleepPlayerAlias as DTSleep_PlayerAliasScript).CurrentLocation)
		Debug.Trace(myScriptName + "     game time: " + Utility.GetCurrentGameTime())
		Debug.Trace(myScriptName + " Player Gender: " + DressData.PlayerGender)
		Debug.Trace(myScriptName + "   Player Race: " + (DTSConditionals as DTSleep_Conditionals).PlayerRace)
		Debug.Trace(myScriptName + "genderSwapPerk: " + (DTSConditionals as DTSleep_Conditionals).HasGenderSwappedPerks)
		Debug.Trace(myScriptName + "    Rest Count: " + DTSleep_RestCount.GetValueInt())
		Debug.Trace(myScriptName + " ScnCount / Xp: " + IntimacySceneCount + " / " + DTSleep_IntimateEXP.GetValueInt())
		Debug.Trace(myScriptName + " IntTest count: " + IntimacyTestCount)
		Debug.Trace(myScriptName + "     Strong Xp: " + DTSleep_IntimateStrongExp.GetValueInt())
		Debug.Trace(myScriptName + "   self/dog Xp: " + DTSleep_IntimateDogEXP.GetValueInt())
		Debug.Trace(myScriptName + "  last SceneID: " + (DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).DTSleep_IntimateIdleID.GetValueInt())
		Debug.Trace(myScriptName + "  UndressReady: " + IsUndressReady)
		Debug.Trace(myScriptName + "      SleepBed: " + SleepBedInUseRef)
		Debug.Trace(myScriptName + "     Using Bed: " + DTSleep_PlayerUsingBed.GetValue())
		Debug.Trace(myScriptName + "     Undressed: " + DTSleep_PlayerUndressed.GetValue())
		Debug.Trace(myScriptName + "      IntFails: " + IntimateCheckFailCount)
		Debug.Trace(myScriptName + "      LastFail: " + IntimateCheckLastFailTime)
		Debug.Trace(myScriptName + "      LastSucc: " + DTSleep_IntimateTime.GetValue() + " / " + IntimateLastTime)
		Debug.Trace(myScriptName + "       LastHug: " + IntimateLastEmbraceTime)
		Debug.Trace(myScriptName + "   LastDogSucc: " + DTSleep_IntimateDogTime.GetValue())
		Debug.Trace(myScriptName + "  EquipMonInit: " + (DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).DTSleep_EquipMonInit.GetValue())
		Debug.Trace(myScriptName + " Rad resist:    " + PlayerRef.GetValue(RadResistExposureAV))
		
		
		Debug.Trace(myScriptName + " =====================================================================")
		Debug.Trace(myScriptName + "    ----------- TEST MODE --- settings -------")
		Debug.Trace(myScriptName + "     AdultMode: " + DTSleep_AdultContentOn.GetValue())
		Debug.Trace(myScriptName + "    promptVal:  " + DTSleep_SettingShowIntimateCheck.GetValue())
		Debug.Trace(myScriptName + " AdultLeitoEVB: " + DTSleep_IsLeitoActive.GetValue())
		Debug.Trace(myScriptName + "     Scene AAC: " + (DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).DTSleep_SettingAACV.GetValueInt())
		Debug.Trace(myScriptName + "        AAF on: " + DTSleep_SettingAAF.GetValue())
		Debug.Trace(myScriptName + "   SeeYouSleep: " + DTSleep_IsSYSCWActive.GetValue() + " / " + DTSleep_SettingPrefSYSC.GetValue())
		Debug.Trace(myScriptName + "          NNES: " + DTSleep_IsNNESActive.GetValue())
		Debug.Trace(myScriptName + "  Cancel Scene: " + DTSleep_SettingCancelScene.GetValue())
		Debug.Trace(myScriptName + "    Bed  Decor: " + DTSleep_SettingBedDecor.GetValue())
		Debug.Trace(myScriptName + "  Dog Restrain: " + DTSleep_SettingDogRestrain.GetValue())
		Debug.Trace(myScriptName + "      Intimate: " + DTSleep_SettingIntimate.GetValue())
		Debug.Trace(myScriptName + "       Undress: " + DTSleep_SettingUndress.GetValue())
		Debug.Trace(myScriptName + "        Chairs: " + DTSleep_SettingChairsEnabled.GetValue())
		Debug.Trace(myScriptName + "        Camera: " + DTSleep_SettingCamera2.GetValue())
		Debug.Trace(myScriptName + "Immersive Rest: " + DTSleep_SettingNapOnly.GetValue())
		Debug.Trace(myScriptName + "      nap-comp: " + DTSleep_SettingNapComp.GetValue())
		Debug.Trace(myScriptName + "      nap-exit: " + DTSleep_SettingNapExit.GetValue())
		Debug.Trace(myScriptName + "  healthRecover:" + (DTSleep_HealthRecoverQuestP as DTSleep_HealthRecoverQuestScript).DTSleep_SettingHealthRecover.GetValue())
		Debug.Trace(myScriptName + "   nap-recover: " + DTSleep_SettingNapRecover.GetValue())
		Debug.Trace(myScriptName + " Warn Busy Lov: " + DTSleep_SettingWarnLoverBusy.GetValue())
		Debug.Trace(myScriptName + "      nap-Save: " + DTSleep_SettingSave.GetValue())
		Debug.Trace(myScriptName + "   Gender Pref: " + DTSleep_SettingGenderPref.GetValue())
		Debug.Trace(myScriptName + "        Lover2: " + DTSleep_SettingLover2.GetValue())
		Debug.Trace(myScriptName + "    Spectators: " + (DTSleep_SpectatorQuestP as DTSleep_SpectatorQuestScript).DTSleep_SettingSpectate.GetValue())
		Debug.Trace(myScriptName + "    AltFemBody: " + (DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).DTSleep_SettingAltFemBody.GetValue())
		Debug.Trace(myScriptName + "  EVB Best-fit: " + (DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).DTSleep_SettingUseLeitoGun.GetValue())
		Debug.Trace(myScriptName + "    BodyTalk2 : " + (DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).DTSleep_SettingUseBT2Gun.GetValue())
		Debug.Trace(myScriptName + "SynthGen2-to-3: " + DTSleep_SettingSynthHuman.GetValue())
		Debug.Trace(myScriptName + "Sleep RadCheck: " + DTSleep_SettingRadCheck.GetValue())
		Debug.Trace(myScriptName + "    Kiss Align: " + DTSleep_SettingScaleActorKiss.GetValue())
		
		
		if (DTSleep_AdultContentOn.GetValueInt() >= 2)
			Debug.Trace(myScriptName + " =====================================================================")
			Debug.Trace(myScriptName + "         ----- TEST MODE ---- Animation Packs -------")
			Debug.Trace(myScriptName + "     LeFO4Anim: " + (DTSConditionals as DTSleep_Conditionals).IsLeitoActive)
			Debug.Trace(myScriptName + "      CrazyGun: " + (DTSConditionals as DTSleep_Conditionals).IsCrazyAnimGunActive)
			Debug.Trace(myScriptName + "     Leito AAF: " + (DTSConditionals as DTSleep_Conditionals).IsAAFActive)
			Debug.Trace(myScriptName + "     Leito ver: " + (DTSConditionals as DTSleep_Conditionals).LeitoAnimVers)
			Debug.Trace(myScriptName + "      CHAKPack: " + (DTSConditionals as DTSleep_Conditionals).IsCHAKPackActive)
			Debug.Trace(myScriptName + "   Atomic Lust: " + (DTSConditionals as DTSleep_Conditionals).IsAtomicLustActive)
			Debug.Trace(myScriptName + "   Atomic vers: " + (DTSConditionals as DTSleep_Conditionals).AtomicLustVers)
			Debug.Trace(myScriptName + "  Mutated Lust: " + (DTSConditionals as DTSleep_Conditionals).IsMutatedLustActive)
			Debug.Trace(myScriptName + "     old Rufgt: " + (DTSConditionals as DTSleep_Conditionals).IsRufgtActive)
			Debug.Trace(myScriptName + "   RaidMyHeart: " + (DTSConditionals as DTSleep_Conditionals).IsRufgtRaidHeartActive)
			Debug.Trace(myScriptName + " LeFO4Anim AAF: " + (DTSConditionals as DTSleep_Conditionals).IsLeitoAAFActive)
			Debug.Trace(myScriptName + " SavageCabbage: " + (DTSConditionals as DTSleep_Conditionals).IsSavageCabbageActive)
			Debug.Trace(myScriptName + "  SavageC vers: " + (DTSConditionals as DTSleep_Conditionals).SavageCabbageVers)
			Debug.Trace(myScriptName + "       ZaZOut4: " + (SleepPlayerAlias as DTSleep_PlayerAliasScript).DTSleep_IsZaZOut.GetValue())
			Debug.Trace(myScriptName + "       GrayMod: " + (DTSConditionals as DTSleep_Conditionals).IsGrayAnimsActive)
			Debug.Trace(myScriptName + "  GrayCreature: " + (DTSConditionals as DTSleep_Conditionals).IsGrayCreatureActive)
			Debug.Trace(myScriptName + "          BP70: " + (DTSConditionals as DTSleep_Conditionals).IsBP70Active)
		endIf
		
		Debug.Trace(myScriptName + "         ----- TEST MODE ---- conditionals ----------")
		Debug.Trace(myScriptName + "  LoverRingCnt:	" + (DTSConditionals as DTSleep_Conditionals).LoverRingEquipCount)
		Debug.Trace(myScriptName + "  gamesetRConv: " + (DTSConditionals as DTSleep_Conditionals).HasGamesetReducedConv)
		Debug.Trace(myScriptName + "hasModReqSleep: " + (DTSConditionals as DTSleep_Conditionals).HasModReqNormSleep)
		Debug.Trace(myScriptName + " DLC NukaWorld: " + (DTSConditionals as DTSleep_Conditionals).IsNukaWorldDLCActive)
		Debug.Trace(myScriptName + "     DLC Robot: " + (DTSConditionals as DTSleep_Conditionals).IsRobotDLCActive)
		Debug.Trace(myScriptName + "     DLC Coast: " + (DTSConditionals as DTSleep_Conditionals).IsCoastDLCActive)
		Debug.Trace(myScriptName + "  DLC Workshop: " + (DTSConditionals as DTSleep_Conditionals).IsWorkShop03DLCActive)
		Debug.Trace(myScriptName + " playerComment: " + (DTSConditionals as DTSleep_Conditionals).IsPlayerCommentsActive)
		Debug.Trace(myScriptName + "         ITPCC: " + (DTSConditionals as DTSleep_Conditionals).ITPCCactiveLevel)
		Debug.Trace(myScriptName + "         AWKCR: " + (DTSConditionals as DTSleep_Conditionals).IsAWKCRActive)
		Debug.Trace(myScriptName + "      Conquest: " + (DTSConditionals as DTSleep_Conditionals).IsConquestActive)
		Debug.Trace(myScriptName + "  llamaHeather: " + (DTSConditionals as DTSleep_Conditionals).IsHeatherCompanionActive)
		Debug.Trace(myScriptName + "  Heather Vers: " + (DTSConditionals as DTSleep_Conditionals).HeatherCampanionVers)
		Debug.Trace(myScriptName + "       nwsBarb: " + (DTSConditionals as DTSleep_Conditionals).IsNWSBarbActive)
		Debug.Trace(myScriptName + "    NoraSpouse: " + (DTSConditionals as DTSleep_Conditionals).NoraSpouseRef)
		Debug.Trace(myScriptName + "     Dual-Nate: " + (DTSConditionals as DTSleep_Conditionals).DualSurvivorsNateRef)
		Debug.Trace(myScriptName + "    Insane Ivy: " + (DTSConditionals as DTSleep_Conditionals).InsaneIvyRef)
		Debug.Trace(myScriptName + "   I'm Darlene: " + (DTSConditionals as DTSleep_Conditionals).ModDarleneRef)
		Debug.Trace(myScriptName + " Tori/Victoria: " + (DTSConditionals as DTSleep_Conditionals).ModCompVictoriaRef)
		Debug.Trace(myScriptName + "SmokableCigars: " + (DTSConditionals as DTSleep_Conditionals).IsSmokableCigarsActive)
		Debug.Trace(myScriptName + "   DX AtomGirl: " + (DTSConditionals as DTSleep_Conditionals).IsDXAtomGirlActive)
		Debug.Trace(myScriptName + "NukaBear index: " + (DTSConditionals as DTSleep_Conditionals).DXAtomGirlNukaBearIndex)
		Debug.Trace(myScriptName + "       Holoboy: " + (DTSConditionals as DTSleep_Conditionals).IsHoloboyActive)
		Debug.Trace(myScriptName + "Lacy Underwear: " + (DTSConditionals as DTSleep_Conditionals).IsLacyUnderwearActive)
		Debug.Trace(myScriptName + "    RangerGear: " + (DTSConditionals as DTSleep_Conditionals).IsRangerGearActive)
		Debug.Trace(myScriptName + "ProvisBackpack: " + (DTSConditionals as DTSleep_Conditionals).IsProvisionerBackPackActive)
		Debug.Trace(myScriptName + "         VIOso: " + (DTSConditionals as DTSleep_Conditionals).IsVioStrapOnActive)
		Debug.Trace(myScriptName + "      Campsite: " + (DTSConditionals as DTSleep_Conditionals).IsCampsiteActive)
		Debug.Trace(myScriptName + "BasementLiving: " + (DTSConditionals as DTSleep_Conditionals).IsBasementLivingActive)
		Debug.Trace(myScriptName + "     LetsDance: " + (DTSConditionals as DTSleep_Conditionals).IsLetsDanceActive)
		Debug.Trace(myScriptName + "   Fusion City: " + (DTSConditionals as DTSleep_Conditionals).IsFusionCityActive)
		Debug.Trace(myScriptName + "UniqFolFemales: " + (DTSConditionals as DTSleep_Conditionals).IsUniqueFollowerFemActive)
		Debug.Trace(myScriptName + "  UniqFolMales: " + (DTSConditionals as DTSleep_Conditionals).IsUniqueFollowerMaleActive)
		Debug.Trace(myScriptName + "   UniqPlayerM: " + (DTSConditionals as DTSleep_Conditionals).IsUniquePlayerMaleActive)
		Debug.Trace(myScriptName + "   UF FemBodID: " + (DTSConditionals as DTSleep_Conditionals).ModUniqueFollowerFemBodyBaseIndex)
		Debug.Trace(myScriptName + "  UF MaleBodID: " + (DTSConditionals as DTSleep_Conditionals).ModUniqueFollowerMaleBodyBaseIndex)
		Debug.Trace(myScriptName + "  UF FemBodLen: " + (DTSConditionals as DTSleep_Conditionals).ModUniqueFollowerFemBodyLength)
		Debug.Trace(myScriptName + "  UF MalBodLen: " + (DTSConditionals as DTSleep_Conditionals).ModUniqueFollowerMaleBodyLength)
		Debug.Trace(myScriptName + " HeatherBodIdx: " + (DTSConditionals as DTSleep_Conditionals).ModCompanionBodyHeatherIndex)
		Debug.Trace(myScriptName + " HeatherActIdx: " + (DTSConditionals as DTSleep_Conditionals).ModCompanionActorHeatherIndex)
		Debug.Trace(myScriptName + "   NoraBodyIdx: " + (DTSConditionals as DTSleep_Conditionals).ModCompanionBodyNoraIndex)
		Debug.Trace(myScriptName + "    IvyBodyIdx: " + (DTSConditionals as DTSleep_Conditionals).ModCompanionBodyInsaneIvyIndex)
		Debug.Trace(myScriptName + "DarelenBodyIdx: " + (DTSConditionals as DTSleep_Conditionals).ModCompanionBodyDarleneIndex)
		Debug.Trace(myScriptName + "   ToriBodyIdx: " + (DTSConditionals as DTSleep_Conditionals).ModCompanionBodyCompVictoriaIndex)
		Debug.Trace(myScriptName + " VulpineRace:   " + (DTSConditionals as DTSleep_Conditionals).IsVulpineRacePlayerActive)
		Debug.Trace(myScriptName + " NanaRace:      " + (DTSConditionals as DTSleep_Conditionals).NanaRace)
		Debug.Trace(myScriptName + " =====================================================================")
	endIf

endFunction



Function UnregisterForSleepBed(float bedUseCodeVal = 0.0)
	;DTDebug(" UnregisterFroSleepBed code: " + bedUseCodeVal, 2)

	UnregisterForPlayerSleep()
	SleepBedRegistered = None
	DTSleep_PlayerUsingBed.SetValue(bedUseCodeVal)
endFunction

Function UpdateIntimateAnimPreferences(int playerChoice)
	; v3.0 now includes cancel at 0, all others incremented by 1
	; v3.0 also includes FF and MM picker menus
	
	; -----------------------
	; playerChoice
	;
	; 1 - let companion decide  -- which sets player's choice 
	; 2 - cuddle
	; 3 - Pick-Spot
	; 4 - missionary
	; 5 - oral / manual
	; 6 - Doggy OR 69
	; 7 - Cowboy OR scissors
	; 8 - Spoon
	; 9 - anal
	; ---------------------------

	; playerChoice -- see DTSleep_IntimateScenePickMessage for index
	; playerChoice == 1 is let companion pick

	if (playerChoice == 2)
		(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePlayerPrefCuddle()

	elseIf (playerChoice == 3)
		(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePlayerPrefStand()
	elseIf (playerChoice == 4)
		; for same-gender message labeled 'Situational' and others is Missionary   v3.0
		if (!SceneData.SameGender || SceneData.HasToyAvailable)
			(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePlayerPrefMissionary()
		endIf
	elseIf (playerChoice == 5)
		(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePlayerPrefOral()
	elseIf (playerChoice == 6)
		if (SceneData.SameGender)
			(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePlayerPrefSixNine()
		else
			(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePlayerPrefDoggy()
		endIf
	elseIf (playerChoice == 7)
		if (SceneData.SameGender && SceneData.MaleRoleGender == 1)
			(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePlayerPrefScissors()
		else
			(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePlayerPrefCowgirl()
		endIf
	elseIf (playerChoice == 8)
		(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePlayerPrefSpoon()
	elseIf (playerChoice == 9)
		(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePlayerPrefAnal()
	endIf

	if (IntimateCompanionRef != None)
	
		Actor noraCompRef = (DTSConditionals as DTSleep_Conditionals).NoraSpouseRef
		if (noraCompRef == None)
			noraCompRef = (DTSConditionals as DTSleep_Conditionals).NoraSpouse2Ref
		endIf
		
		Actor heatherCompRef = GetHeatherActor()
		
		if (noraCompRef != None && IntimateCompanionRef == noraCompRef)
	
			(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePrefSpanking(true)
			if (playerChoice == 1)
				(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePlayerPrefCowgirl()
				(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePlayerPrefMissionary()
				(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePlayerPrefCunn()
			else
				(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePrefCuddle(true)
				(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePrefCowgirl(true)
				(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePrefMissionary(true)
				(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePrefDoggy(false)
			endIf

		elseIf (heatherCompRef != None && IntimateCompanionRef == heatherCompRef)		; v3.0
			; Heather Casdin
			if (playerChoice == 1)
				(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePlayerPrefCuddle()
				(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePlayerPrefMissionary()
				(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePlayerPrefCunn()
				(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePlayerPrefSixNine()
			endIf
		
		elseIf ((DTSConditionals as DTSleep_Conditionals).InsaneIvyRef != None && IntimateCompanionRef == (DTSConditionals as DTSleep_Conditionals).InsaneIvyRef)
			; Insane Ivy
			if (playerChoice == 1)
				if (Utility.RandomInt(2, 10) > 6)
					(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePlayerPrefCuddle()
				endIf
				(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePlayerPrefDoggy()
				(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePlayerPrefOral()
				(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePlayerPrefSixNine()
			else
				(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePrefCuddle(true)
				(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePrefCowgirl(false) 
				(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePrefDoggy()
			endIf
		elseIf (IntimateCompanionRef == CompanionPiperRef)
		
			(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePrefSpanking(true)
			
			if (playerChoice == 1)
				if (Utility.RandomInt(5, 10) > 7)
					(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePlayerPrefCuddle()
				endIf
				if (DressData.PlayerGender == 0)
					(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePlayerPrefCowgirl()
					(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePlayerPrefCunn()
				endIf
				(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePlayerPrefStand()
				(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePlayerPrefMissionary()
			else
				(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePrefCuddle(true)
				(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePrefCowgirl(false) ; and hate scissors
				(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePrefCarry(true)
			endIf

			
		elseIf (IntimateCompanionRef == CompanionCaitRef)
			if (playerChoice == 1)
				(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePlayerPrefCowgirl()
				(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePlayerPrefOral()
				(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePlayerPrefSixNine()
			else
				(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePrefBlowJob()
				(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePrefCuddle(false)
				(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePrefMissionary(false)
				(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePrefCowgirl(true)
			endIf
			
		elseIf (IntimateCompanionRef == CompanionDanseRef)
			; normally stuck in power armor, but player have a mod
			if (playerChoice == 1)
				if (Utility.RandomInt(5, 10) > 7)
					(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePlayerPrefCuddle()
				endIf
				(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePrefCuddle(true)
				(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePlayerPrefStand()
			else
				(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePrefCuddle(true)
				(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePrefCowgirl(false)
				(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePrefCarry(true)
			endIf
			
		elseIf (IntimateCompanionRef == CompanionDeaconRef)
		
			if (playerChoice == 1)
				(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePlayerPrefDoggy()
				(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePlayerPrefStand()
			else
				(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePrefMissionary(false)
				(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePrefDoggy()
				(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePrefBlowJob(false)
				(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePrefDance(true)
			endIf
				
		elseIf (IntimateCompanionRef == CompanionMacCreadyRef)
			if (playerChoice == 1)
				(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePlayerPrefDoggy()
				(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePrefCuddle(true)
			else
				(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePrefCuddle(true)
				(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePrefDoggy()
				(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePrefCarry(false)
				(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePrefDance(true)
			endIf
			
		elseIf (IntimateCompanionRef == CompanionHancockRef)
		
			(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePrefSpanking(true)
			if (playerChoice == 1)
				(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePlayerPrefMissionary()
				(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePlayerPrefDoggy()
			else
				(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePrefDoggy()
				(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePrefCowgirl(false)
				(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePrefBlowJob(false)
				(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePrefDance(true)
			endIf
		elseIf (IntimateCompanionRef == StrongCompanionRef)
			if (playerChoice >= 1 && playerChoice <= 2)
				(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePlayerPrefDoggy()
				(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePlayerPrefCowgirl()
				if (playerChoice == 1)
					(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePlayerPrefOral()
				endIf
			else
				(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePrefBlowJob()
				(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePrefDoggy()
			endIf
			
		elseIf (IntimateCompanionRef == CompanionX6Ref)
		
			if (playerChoice == 1)
				(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePlayerPrefOral()
				(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePrefSpanking(true)
				(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePlayerPrefDoggy()
			else
				(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePrefCuddle(false)
				(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePrefBlowJob()
				(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePrefCowgirl(false)
			endIf
			
		elseIf (IntimateCompanionRef == CurieRef)
			(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePrefSpanking(true)
			if (playerChoice == 1)
				(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePrefDoggy()
				(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePlayerPrefStand()
				(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePlayerPrefCowgirl()
				(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePlayerPrefCunn()
				(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePlayerPrefSixNine()
			else
				(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePrefCuddle(true)
				(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePrefCowgirl()
				(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePrefBlowJob(false)
			endIf
			
		elseIf ((DTSConditionals as DTSleep_Conditionals).NukaWorldDLCGageRef != None && IntimateCompanionRef == (DTSConditionals as DTSleep_Conditionals).NukaWorldDLCGageRef)
			if (playerChoice == 1)
				(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePrefBlowJob()
				(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePrefDoggy()
			else
				(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePrefCuddle(false)
				(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePrefBlowJob()
				(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePrefMissionary(false)
			endIf
			
		elseIf ((DTSConditionals as DTSleep_Conditionals).IsCoastDLCActive && IntimateCompanionRef == (DTSConditionals as DTSleep_Conditionals).FarHarborDLCLongfellowRef)
			if (playerChoice == 1)
				if (Utility.RandomInt(5, 10) <= 7)
					(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePlayerPrefCuddle()
				endIf
				(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePrefCuddle(true)
				(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePlayerPrefMissionary()
			else
				(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePrefCuddle(true)
				(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePrefCarry(false)
				(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePrefMissionary(true)
				(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePrefSpanking(false)
				(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePrefDance(true)
			endIf
		endIf
	endIf
endFunction

Function UpgradeTour()

	if (DTSleep_SettingTourEnabled.GetValue() > 0.0)
		if (DTSleep_IntimateTourQuestP.IsRunning())
			Utility.Wait(1.0)
			(DTSleep_IntimateTourQuestP as DTSleep_IntimateTourQuestScript).UpdateLocationCount(true)
		endIf
	endIf

endFunction

Function ValidatePerks()

	if (PlayerRef.HasPerk(DTSleep_LoversEmbracePerk) || PlayerRef.HasPerk(DTSleep_LoversCoffinPerk))
		float checkT = (DTSleep_HealthRecoverQuestP as DTSleep_HealthRecoverQuestScript).PlayerWellRestedTime
		
		if (checkT <= 0.0)
			LoverBonusRested(false)
		else
			float gameTime = Utility.GetCurrentGameTime()
			if (DTSleep_CommonF.GetGameTimeHoursDifference(gameTime, checkT) > 21.0)
				(DTSleep_HealthRecoverQuestP as DTSleep_HealthRecoverQuestScript).PlayerWellRestedTime = -3.0
				LoverBonusRested(false)
			endIf
		endIf
	endIf

endFunction

; check added companions -- may have been incorrectly added using the Lover's Ring which failed to check affinity prior to v2.21
;
Function VerifyRomanceList()

	int i = DTSleep_CompanionRomanceList.GetSize() - 1
	Actor heatherActor = GetHeatherActor()			; on intimate-all list, but should not be on Romance list
	Actor nwBarbActor = GetNWSBarbActor()			; on intimate-all list, but should not be on Romance list
	
	while (i >= 0)
		Actor act = DTSleep_CompanionRomanceList.GetAt(i) as Actor
		
		if (act != None)
			if (heatherActor != None && act == heatherActor)
				Debug.Trace(myScriptName + " Verify Romance list removing non-affinity Heather from list")
				DTSleep_CompanionRomanceList.RemoveAddedForm(act as Form)
			elseIf (nwBarbActor != None && act == nwBarbActor)
				Debug.Trace(myScriptName + " Verify Romance list removing non-affinity NWBarb from list")
				DTSleep_CompanionRomanceList.RemoveAddedForm(act as Form)
			elseIf ((DTSConditionals as DTSleep_Conditionals).FarHarborDLCLongfellowRef != None && act == (DTSConditionals as DTSleep_Conditionals).FarHarborDLCLongfellowRef)
				Debug.Trace(myScriptName + " Verify Romance list removing Longfellow from list")
				DTSleep_CompanionRomanceList.RemoveAddedForm(act as Form)
			elseIf (act == CompanionDeaconRef)
				Debug.Trace(myScriptName + " Verify Romance list removing Deacon from list")
				DTSleep_CompanionRomanceList.RemoveAddedForm(act as Form)
			elseIf (act == CompanionX6Ref)
				Debug.Trace(myScriptName + " Verify Romance list removing X688 from list")
				DTSleep_CompanionRomanceList.RemoveAddedForm(act as Form)
			elseIf (act == StrongCompanionRef)
				Debug.Trace(myScriptName + " Verify Romance list removing Strong from list")
				DTSleep_CompanionRomanceList.RemoveAddedForm(act as Form)
				
			elseIf (!(SleepPlayerAlias as DTSleep_PlayerAliasScript).DTSleep_CompanionIntimateAllList.HasForm(act as Form))
				
				float affinity = act.GetValue(CA_AffinityAV)
				if (affinity < 1000.0)
					Debug.Trace(myScriptName + " Verify Romance List removing actor " + act + " due to low affinity " + affinity)
					DTSleep_CompanionRomanceList.RemoveAddedForm(act as Form)
				endIf
			endIf
		endIf
		
		i -= 1
	endWhile
endFunction

; waits until DTSleep_PlayerUndressed set or time-out
;
Function WaitForRedressAfterScene(int waitLim = 5)

	int redressWaitCount = 0
	if (waitLim > 12)
		waitLim = 12
	endIf
	while (redressWaitCount < waitLim && DTSleep_PlayerUndressed.GetValueInt() > 0)
		Utility.Wait(1.0)
		if (redressWaitCount == 3 || redressWaitCount == 7 || redressWaitCount == 10)
			DTSleep_WaitOnSceneFinishMsg.Show()
		endIf
		redressWaitCount += 1
	endWhile
endFunction

Function WakeIntimateCompanion(bool speakWake = false)

	if (DTSleep_CompSleepQuest.IsRunning())
		
		WakeStopCompQuest()
		
	elseIf (SleepBedCompanionUseRef != None && IntimateCompanionRef != None)
	
		SleepBedCompanionUseRef.Activate(IntimateCompanionRef)
		Utility.Wait(0.3)
	else
		speakWake = false
	endIf
	
	if (IntimateCompanionRef != None)
		if (speakWake)
			Utility.Wait(0.76)
			IntimateCompanionRef.SayCustom(CAT_Event_SleepTogetherWakeKY, IntimateCompanionRef, false, PlayerRef)
		endIf
		IntimateCompanionRef.FollowerFollow()
		IntimateCompanionRef.EvaluatePackage(true)
	endIf
endFunction

Function WakeStopCompQuest()
	DTDebug(" stopping CompSleepQuest...", 2)
	
	DTSleep_CompSleepQuest.Stop()
	
	if (IntimateCompanionRef != None)
		
		IntimateCompanionRef.RemoveFromFaction(DTSleep_IntimateFaction)
	endIf
	
	
	if (DTSleep_CompSleepAlias != None)
		DTSleep_CompSleepAlias.Clear()
	endIf
	if (DTSleep_CompSecondSleepAlias != None)
		DTSleep_CompSecondSleepAlias.Clear()
	endIf
	if (DTSleep_CompBedRestAlias != None)
		DTSleep_CompBedRestAlias.Clear()
	endIf
	if (DTSleep_CompBedSecondRefAlias != None)
		DTSleep_CompBedSecondRefAlias.Clear()
	endIf
	
	if (DTSleep_DogSleepAlias != None)
		DTSleep_DogSleepAlias.Clear()
	endIf
	
	if (DTSleep_CompDogBedRefAlias != None)
		DTSleep_CompDogBedRefAlias.Clear()
	endIf
	
	if (SleepBedDogPlacedRef != None)
		StartTimer(1.8, DisableSleepDogPlacedTimerID)
	endIf
	
	if (IntimateCompanionSecRef != None)
		if (IntimateCompanionSecRef.IsInFaction(DTSleep_IntimateFaction))
			DTDebug(" stop compQuest - removing 2nd lover from intimate faction", 2)
			IntimateCompanionSecRef.RemoveFromFaction(DTSleep_IntimateFaction)
		endIf
		IntimateCompanionSecRef = None
	endIf
	
	Utility.Wait(0.2)
endFunction

Function WakeStopIntimQuest(bool remFaction = true)
	DTDebug("stop intimate quest...", 2)
	if (remFaction && IntimateCompanionRef != None && IntimateCompanionRef.IsInFaction(DTSleep_IntimateFaction))
		IntimateCompanionRef.RemoveFromFaction(DTSleep_IntimateFaction)
	endIf
	
	if (IntimateCompanionSecRef != None)
		if (IntimateCompanionSecRef.IsInFaction(DTSleep_IntimateFaction))
			DTDebug(" stop Intimate quest - removing 2nd lover from intimate faction", 2)
			IntimateCompanionSecRef.RemoveFromFaction(DTSleep_IntimateFaction)
		endIf
	endIf
	
	if (DTSleep_DogBedIntimateAlias != None)
		DTSleep_DogBedIntimateAlias.Clear()
	endIf
	
	if (SleepBedDogPlacedRef != None)
		; should not happen here
		DTDebug(" !found Dogmeat temp bed on WakeStopIntimQuest! - should only place for sleep", 1)
		DTSleep_CommonF.DisableAndDeleteObjectRef(SleepBedDogPlacedRef, false, true)
		SleepBedDogPlacedRef = None
	endIf
	
	if (DTSleep_CompIntimateQuest.IsRunning())
		DTDebug(" stopping CompIntimatequest....", 2)
		
		DTSleep_CompIntimateQuest.Stop()
		DTSleep_CompIntimateAlias.Clear()
		
		if (DTSleep_CompBedSexRefAlias != None)
			DTSleep_CompBedSexRefAlias.Clear()
		endIf
		
		if (DTSleep_OtherFurnitureRefAlias != None)
			DTSleep_OtherFurnitureRefAlias.Clear()
		endIf
		
		if (DTSleep_CompIntimateLover2Alias != None)
			DTSleep_CompIntimateLover2Alias.Clear()
		endIf
	endIf
	
	if (IntimateCompanionSecRef != None)
		IntimateCompanionSecRef.EvaluatePackage()
	endIf
	
	if (IntimateCompanionRef != None)
		IntimateCompanionRef.SetRestrained(false)
		IntimateCompanionRef.EvaluatePackage(true)
	endIf
	
	if (PlayerHasActiveDogmeatCompanion.GetValueInt() >= 1 && DogmeatCompanionAlias != None)
		Actor dogActor = DogmeatCompanionAlias.GetActorReference()
		if (dogActor != None)
			dogActor.EvaluatePackage(false)
		endIf
	endIf
	
	IntimateCompanionSecRef = None

EndFunction


; ----------------------------------------
;  not using / deprecated
;
Group Z_Deprecated
FormList property DTSleep_SleepAttireFemale auto const
{ not using }
FormList property DTSleep_SleepAttireMale auto const
{ not using }
FormList property DTSleep_IntimacyChanceNegSpellList auto const
{ not used }
Keyword property PlayerNerdRageDialogue auto const
MagicEffect property FortifyCharismaAlcoholME auto const
Keyword property PlayerHackSuccessSubtype auto const
Message property DTSleep_TourLocCheckedMsg auto const
GlobalVariable property DTSleep_SettingCamera auto
{ deprecated }
Quest property DTSleep_DogTrainQuestP auto
{ no longer used }
ActorValue property HealthAV auto const									; not used
EndGroup
float IntimateLastEmbraceScoreTime ; not using
