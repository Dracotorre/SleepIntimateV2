Scriptname DTSleep_MainQuestScript extends Quest
{ Main quest reacts to bed or seat activation via DTSleep_PlayerSleepBedPerk }

; ********************* 
; DTSleep_MainQuestScript main quest controller for Sleep Intimate version 2
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
; power-armor glitch determination: first check keyword then check IsInPowerArmor
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
Faction property DTSleep_IntimateFaction auto const
ReferenceAlias property DTSleep_CompBedRestAlias auto
ReferenceAlias property DTSleep_CompBedSecondRefAlias auto const
ReferenceAlias property DTSleep_CompDogBedRefAlias auto const
ReferenceAlias property DTSleep_CompSleepAlias auto const
ReferenceAlias property DTSleep_CompSecondSleepAlias auto const
ReferenceAlias property DTSleep_DogSleepAlias auto const
ReferenceAlias property DTSleep_CompBedSexRefAlias auto
ReferenceAlias property DTSleep_CompIntimateAlias auto const
ReferenceAlias property DTSleep_DogIntimateRestAlias auto const
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
EndGroup

Group BC_Globals_Settings
GlobalVariable property DTSleep_SettingUndress auto Const Mandatory
{setting to disable = 0 / situational = 1 / always = 2 undressing in bed }
GlobalVariable property DTSleep_SettingIntimate auto Const Mandatory
{ setting to get intimate with lover after waking }
GlobalVariable property DTSleep_DebugMode auto const
GlobalVariable property DTSleep_SettingCancelScene auto const
GlobalVariable property DTSleep_SettingModActive auto
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
{ Male, Female, Both, Faithful}
;GlobalVariable property DTSleep_SettingPickPos auto const
GlobalVariable property DTSleep_SettingChairsEnabled auto
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
ActorValue property HealthAV auto const
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
FormList property DTSleep_IntimacyChanceMEList auto const
{ magic effects granting better chance - keep list very short }
FormList property DTSleep_ActorKYList auto const
FormList property DTSleep_DogSleepKWList auto const
FormList property DTSleep_CompanionRomanceList auto const
FormList property DTSleep_PilloryList auto const
FormList property DTSleep_TortureDList auto const
Spell property DTSleep_LoverBonusSpell auto const
Perk property DTSleep_LoversBonusPerk auto const
Perk property DTSleep_LoverDogBonusPerk auto const
Perk property DTSleep_LoverStrongBonusPerk auto const
Perk property DTSleep_LoversTourBonusPerk auto const
Perk property DTSleep_LoversEmbracePerk auto const
Perk property DTSleep_LoversEmbraceHugPerk auto const
Perk property DTSleep_ExhibitionPerk auto const
Perk property DTSleep_BusyDayPerk auto const
Holotape property DTSleep_OptionsHolotape auto const
Holotape property DTSleep_OptionsHolotape2 auto const
Armor property DTSleep_ArmorLoverRing auto const

;ReferenceAlias property SleepCompanionBedAlias Auto
RefCollectionAlias property ActiveCompanionCollectionAlias auto const
Race property HumanRace auto const Mandatory
Race property GhoulRace auto const
Race property SynthGen2RaceValentine auto const
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
Message property DTSleep_ShutdownMsg auto const
Message property DTSleep_ShutdownConfirmMsg auto const
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
Message property DTSleep_CountMessage auto const
Message property DTSleep_PickPositionMsg auto const
Message property DTSleep_PickPositionViewMsg auto const
Message property DTSleep_PickPositionStepBackMsg auto const
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
Message property DTSleep_LoversEmbraceHugMsg auto const
Message property DTSleep_PersuadePilloryNoneMsg auto const
Message property DTSleep_PilloryBusyMessage auto const
Message property DTSleep_PAStationPANearMessage auto const
Message property DTSleep_UndressInitMessage auto const
Message property DTSleep_IntimateScenePickMessage auto const
Message property DTSleep_AAFDisableMessage auto const
Message property DTSleep_PersuadeSoonMessage auto const
Message property DTSleep_BusyDayMessage auto const
EndGroup

Group E_PromptsHuman
Message property DTSleep_IntimateCheckIntroMsg auto const
Message property DTSleep_IntimateCheckIntroPoorMsg auto const
Message property DTSleep_IntimateCheckIntroRiskyMsg auto const
Message property DTSleep_IntimateCheckMsg auto const
{ for romantic companion }
Message property DTSleep_IntimateCheckLoverPerfectMsg auto const
Message property DTSleep_IntimateCheckLoverPoorMsg auto const
Message property DTSleep_IntimateCheckLoverRiskyMsg auto const
Message property DTSleep_IntimateInfatCheckMsg auto const
{ for infatuated or less }
Message property DTSleep_IntimateInfatCheckPerfectMsg auto const
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
Message property DTSleep_IntimateCheckFriendPerfectMsg auto const
Message property DTSleep_IntimateCheckFriendPoorMsg auto const
Message property DTSleep_IntimateCheckFriendRiskyMsg auto const
Message property DTSleep_IntimateCheckOwnedBedMsg auto const
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
Message property DTSleep_IntimateCheckHugsLastHugMsg auto const
Message property DTSleep_IntimateCheckHugsRecentMsg auto const
Message property DTSleep_IntimateCheckHugsChanceMsg auto const
Message property DTSleep_IntimateCheckSecondLovMsg auto const
Message property DTSleep_PersuadeSoonPromptMsg auto const
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
int PlayerUndressID = 201 const
int CompanionUndressID = 202 const
int CompanionRedressID = 203 const
int DanceID = 204 const
int PlayerUndressSleepID = 205 const
int CreatureTypeDog = 2 const
int CreatureTypeStrong = 1 const
int CreatureTypeSynth = 3 const
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
int LocActorChanceTown = 20 const
int LocActorChanceHugs = 19 const
int LocActorChanceWild = 0 const
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



; ********************************************
; *****           events          *********
;
Event OnQuestInit()
	
	float gameTime = Utility.GetCurrentGameTime()
	DTSleep_SettingModActive.SetValue(0.1)  ; prepare to init
	
	DTSleep_IntimateUndressQuestP.Start()  ; start now and always run
	IntimacyDogCount = 0
	IntimacySMCount = 0
	IntimacySceneCount = 0
	IntimacyDayCount = 0
	TotalBusyDayCount = 0
	TotalExhibitionCount = 0
	
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
	
	if (DTSleep_AdultContentOn.GetValue() <= 1.0 && DTSleep_SettingUndressPipboy.GetValueInt() == 1)
		; default 1 not applicable 
		DTSleep_SettingUndressPipboy.SetValue(0.0)
	endIf
	
	if (DTSleep_AdultContentOn.GetValueInt() >= 2 && (Debug.GetPlatformName() as bool))
		(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).DTSleep_SettingUseLeitoGun.SetValueInt(2)
	else
		(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).DTSleep_SettingUseLeitoGun.SetValueInt(0)
	endIf
	
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
	elseIf (aiTimerID == IntimateEmbraceAddTimerID)
		LoverBonusEmbrace(true, true)
		
	elseIf (aiTimerID == LoverBonusAddTimerID)
		CheckLoverBonusAdd()
		
	elseIf (aiTimerID == LoverAffinityCheckTimerID)
		CheckCompanionIntimateAffinity()
		
	elseIf (aiTimerID == ExitBedHandleTimerID)
		HandleExitBed()
		
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
	elseIf (aiTimerID == IntimateEmbracePerkTimerID)
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
		
	elseIf (Fragment_Entry_01 == 11)
		; PA station
		if (CanPlayerRestRadDam())
			HandlePlayerActivateFurniture(akTarget, 4)
		endIf
		
	elseIf (Fragment_Entry_01 == 10)
		; desk
		if (CanPlayerRestRadDam())
			HandlePlayerActivateFurniture(akTarget, 3)
		endIf
		
	elseIf (Fragment_Entry_01 == 9)
		; chair - no sex  - allow hugs with radiation damage
		HandlePlayerActivateFurniture(akTarget, -5)
		
	elseIf (Fragment_Entry_01 == 8)
		; Torture Device - pillory
		if (CanPlayerRestRadDam())
			HandlePlayerActivateFurniture(akTarget, 1)
		endIf
		
	elseIf (Fragment_Entry_01 == 7)
		; chair, stool, or sofa
		if (CanPlayerRestRadDam())
			HandlePlayerActivateFurniture(akTarget, 2)
		endIf
		
	elseIf (Fragment_Entry_01 == 6)
		; pillory activate - ZaZ
		if (CanPlayerRestRadDam())
			HandlePlayerActivateFurniture(akTarget, 1)
		endIf
		
		
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
		
		if (Fragment_Entry_01 == 2)
			isNaked = true
		elseIf (Fragment_Entry_01 == 3)
			; this bed has its own activate animations (Sleep Anywhere camp bedroll)
			isSpecialAnimBed = true
		endIf
		
		ValidatePerks()
		
		PipboyMenuCloseType = -1
		
		int checkVal = DTSleep_CaptureExtraPartsEnable.GetValueInt()
		
		if (checkVal <= 0 && IsUnsafeToRestBed(akTarget))
		
			DTDebug(" no rest (sleep instead) bed placed: " + akTarget, 1)
			akTarget.Activate(PlayerRef)
			
		elseIf (checkVal > 0 || CanPlayerPerformRest(akTarget))
		
			; player can't active double-bed if NPC in marker 0 or 1
			if (checkVal > 0)
				HandlePlayerActivateBed(akTarget, isNaked, isSpecialAnimBed)
				
			elseIf (!isSpecialAnimBed && akTarget.IsFurnitureInUse(false) && DTSleep_SettingNapOnly.GetValue() <= 0.0)
				; check if romantic companion
				Actor actorInBed = GetCompanionInLoveUsingBed(akTarget)
				if (actorInBed)
					DTDebug("  Activate normal Sleep with companion for bed, " + akTarget, 1)

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
		
		LoverBonusRested(false)			; remove rested bonus
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

	DTDebug(" Got IntimateSequenceDoneEvent ", 1)
	
	if (akArgs.Length >= 6)
	
		int doneStep = akArgs[4] as int
		
		
		if (doneStep == 0)
			DTDebug("prepare to finish...", 2)
			EnablePlayerControlsSleep()
			
			return
		elseIf (doneStep < 0)
			; error starting scene
			DTDebug("error starting scene -- check and report if too many", 2)
			HandleIntimateAnimStartError(doneStep)
		else
			DisablePlayerControlsSleep(3)	; move, no activate
		endIf
		
		UnregisterForCustomEvent((DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript), "IntimateSequenceDoneEvent")
		
	
		Actor mainActor = akArgs[0] as Actor
		ObjectReference bedRef = akArgs[2] as ObjectReference
		bool placeInBedRequested = akArgs[5] as bool
		self.SleepLoverBonusOnSleepID = 1
		bool undressStopped = false
		bool bedActivated = false
		bool redressSlowly = false
		bool activateBedOK = true
		bool sleepTime = (DTSleep_HealthRecoverQuestP as DTSleep_HealthRecoverQuestScript).SleepyPlayer
		bool nakedPlayer = (DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).IsUndressAll
		bool hasAAFBeenDisabled = false
		if ((DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).MSceneChangedAAFSetting == 0)
			hasAAFBeenDisabled = true
		endIf
		
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
					endIf
					SceneData.SecondFemaleRole = None
					SceneData.SecondMaleRole = None
				endIf
				
				if (IntimateCompanionRef == StrongCompanionRef)
					self.SleepLoverBonusOnSleepID = 3

					Utility.Wait(0.1)
					IntimateCompanionRef = None
					
				elseIf (PlayerHasActiveDogmeatCompanion.GetValue() > 0.0 && DogmeatCompanionAlias != None)
					Actor dogRef = DogmeatCompanionAlias.GetActorReference()
					if (dogRef && dogRef == IntimateCompanionRef)
						self.SleepLoverBonusOnSleepID = 2
						Utility.Wait(0.1)
						IntimateCompanionRef = None
					endIf
				endIf
			else
				Debug.Trace(myScriptName + " on intimate done, but no IntimateCompanionRef!!!")
			endIf
			
			if (bedRef == None && SceneData.AnimationSet < 7)
				; no bonus for hugs at chairs
				self.SleepLoverBonusOnSleepID = -2
			endIf
			
			WakeStopIntimQuest(true)
			
			if (DTSleep_SettingDogRestrain.GetValue() >= 0.0 && DogmeatCompanionAlias != None)
				
				SetDogmeatFollow()
			endIf

			bool doFadeIn = false
			bool inBed = (DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).PlaceInBedOnFinish
				
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
				
					if (SceneData.AnimationSet >= 5 && (IsAAFReady() || hasAAFBeenDisabled))
						; AAF scene end - do not go directly to bed! - use prompt if set
						redressSlowly = true
						doFadeIn = true
						Utility.Wait(1.50)
						SetUndressStop(redressSlowly)
						undressStopped = true
						if (hasAAFBeenDisabled)
							StartTimer(2.0, AAFDisabledMsgTimerID)
						endIf
						
					elseIf (!SleepBedUsesSpecialAnims && DTSleep_SettingNapOnly.GetValue() <= 0.0)
						SetUndressStop(redressSlowly)
						undressStopped = true
						Utility.Wait(0.54)
						
						doFadeIn = true	; fade-in to get bed view and sleep menu
					else
						DTDebug(" nap only, undress SetStopOnExit", 2)
						Utility.Wait(0.24) ; ensure done with character
						
						if (intimatePrompt > 0 && !inBed && !placeInBedRequested)
							; not in bed (for some reason) so fade-in for prompt unless requested
							; interruptions handled later
							doFadeIn = true 
							
						endIf
						
						; do not fade-in until bed unless...
						; make sure okay to switch to bed--even if not in bed--so we know ready to move if not there yet
						if ((DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).SetStopOnBedExit() == false)
							Debug.Trace(myScriptName + " set undress SetStopOnBedExit failed... stopping undress")
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
					
					DTDebug("IntimateSequenceDoneEvent -- Fade-in...", 1)
					
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
			
				UnregisterForRemoteEvent(bedRef, "OnActivate")
				
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
					if (DTSleep_SettingNapOnly.GetValue() > 0.0 || SleepBedUsesSpecialAnims || !nakedPlayer)
					
						if (!inBed && !fadedOut && activateBedOK && DTSleep_SettingShowIntimateCheck.GetValueInt() > 0)
							
							int restCheck = 0
							
							; recheck
							if (!sleepTime && Game.GetDifficulty() >= 6 && PlayerRef.GetValue(HC_SleepEffectAV) >= 2.0)
								sleepTime = true
							endIf
							
							if (OkayToSleepLocationBed(bedRef))
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
						
						DTDebug(" scene-done - ActiviatePlayerSleep moveToBed?: " + !inBed, 2)
						
						ActivatePlayerSleepForBed(bedRef, SleepBedUsesSpecialAnims, !undressStopped, fadedOut, !inBed, true)
						
					endIf
				else
					
					DTDebug(" skip bed activate, interrupted? " + SceneData.Interrupted, 1)
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
				DTSleep_AAFSceneSlowMessage.Show()

			elseIf (SceneData.Interrupted == 10)
				DTSleep_AAFSceneLockedMessage.Show()
				DTSleep_SettingAAF.SetValueInt(0)
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
				
				if (self.MessageOnRestID > 0)
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
				int chanceLim = 12
				float radResist = PlayerRef.GetValue(RadResistExposureAV)
				if (radResist >= 40.0)
					chanceLim = 5
				elseIf (radResist >= 20.0)
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
	; wait to re-register as damage lasts a few seconds (catch event immediately) 
	;  and we check based on time since
	StartTimer(12.0, RadiationDamageTimerID)
EndEvent

Event ObjectReference.OnActivate(ObjectReference akSender, ObjectReference akActionRef)
	Utility.Wait(0.02)
	
	if (akActionRef != PlayerRef)
	
		DTDebug(" this furniture " + akSender + " activated by " + akActionRef, 1)
		
		if (DTSleep_PlayerUsingBed.GetValue() >= 1.0 && SleepBedInUseRef != None && SleepBedInUseRef == akSender)
			; get out of bed!!
			DTDebug(" forcing player out of bed on activation by " + akActionRef, 2)
			SleepBedInUseRef.Activate(PlayerRef)
			
		elseIf ((DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SceneIsPlaying)
			SceneData.Interrupted = 2
			UnregisterForRemoteEvent(akSender, "OnActivate")
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
	
	if ((DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).UndressedForType >= 5)
		; equip system had initialized
		StartTimer(6.5, UndressedInitTipTimerID)
	endIf
	
	UnregisterForRemoteEvent(akSender, "OnExitfurniture")
	UnregisterForRemoteEvent(akSender, "OnActivate")
	if (SleepBedTwin != None)
		UnregisterForRemoteEvent(SleepBedTwin, "OnActivate")
		SleepBedTwin = None
	endIf
	
	HandleOnExitFurniture(akSender)
EndEvent

; Pip-boy close
;
Event OnMenuOpenCloseEvent(string asMenuName, bool abOpening)
	if (asMenuName == "WorkshopMenu")

		if (abOpening)
			PlayerSleepPerkRemove()
		else
			PlayerSleepPerkAdd()
		endIf
		
    elseIf (asMenuName== "PipboyMenu" && !abOpening)
		
		DTDebug(" Pip-boy close event", 2)
		
		UnregisterForMenuOpenCloseEvent("PipboyMenu")
		
		if (PipboyMenuCloseType == PlayerUndressID)
			PipboyMenuCloseType = -2
			
			EnablePlayerControlsSleep()
			Utility.Wait(0.05)
			
			DisablePlayerControlsSleep()
			
			GoThirdPerson()
	
			Utility.Wait(0.52)
			
			if (IsUndressCheckRequested())
			
				SetUndressForCheck(true, None)
			else
				SetUndressForNoStop()
			endIf
	
			GoFirstPerson()
			
			EnablePlayerControlsSleep()
			
		elseIf (PipboyMenuCloseType == CompanionUndressID)
		
			Utility.Wait(0.2)
			IntimateCompanionSet companionSet = GetCompanionNearbyHighestRelationRank(false)
	
			if (companionSet.CompanionActor != None)
				SetUndressForCompanionSleepwear(companionSet.CompanionActor, companionSet.RequiresNudeSuit)
			else
				DTSleep_CompanionNotFoundMsg.Show()
			endIf
			
		elseIf (PipboyMenuCloseType == CompanionRedressID)
		
			RedressCompanion()
			
		elseIf (PipboyMenuCloseType == DanceID)
		
			Utility.Wait(0.2)
			IntimateCompanionSet companionSet = GetCompanionNearbyHighestRelationRank(false)
			Actor compActorRef = None
			if (companionSet != None && companionSet.CompanionActor != None)
				compActorRef = companionSet.CompanionActor
			endIf
			
			SetUndressAndFadeForIntimateScene(compActorRef, None, -1, true, lowCam = false)
			
			if ((DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).PlayActionDancing())

				RegisterForCustomEvent((DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript), "IntimateSequenceDoneEvent")
			endIf
		endIf	
	endIf
EndEvent

; SleepQuest event - start sleep
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
	;
	if (!abInterrupted && !PlayerRef.IsInCombat() && akBed != None && akBed.IsEnabled() && akbed.Is3DLoaded())
	
		Location currentLoc = (SleepPlayerAlias as DTSleep_PlayerAliasScript).CurrentLocation
		bool observeWinter = true
		if (akBed.IsOwnedBy(PlayerRef))
			observeWinter = false
		elseIf (currentLoc != None && currentLoc.HasKeyword(LocTypeWorkshopSettlementKY))
			if (IsObjBelongPlayerWorkshop(akBed) > 0)
				; this check takes time so only check if location has KY
				observeWinter = true
			endIf
		endIf

		HandlePlayerSleepStop(akBed, observeWinter)
		
	else
		; done using bed
		if (abInterrupted)
			DTDebug(" OnSleepStop interrupted...", 1)
			DTSleep_SleepInterruptedSleepStopMsg.Show()
		elseIf (akBed == None || !akBed.IsEnabled() || !akbed.Is3DLoaded())
			; v2.13
			DTDebug(" OnSleepStop no bed!", 1)
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
	
	if (myCompanion)
		
		(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).SetMonitorCompanionEquip(myCompanion)
	endIf
	
	DTSleep_CaptureIntimateApparelEnable.SetValue(Utility.GetCurrentGameTime())
endFunction

Function CaptureIntimateApparelUnmarkCurrent()

	Armor item = (DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).UndressPlayerIntimateItem(true)
	if (item != None)
		DTSleep_CaptureIntimateApparelEnable.SetValue(Utility.GetCurrentGameTime())
		Utility.WaitMenuMode(0.3)
		PlayerRef.EquipItem(item, false, true)
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
		DTDebug("checking nude suits - ActiveCompanion Count: " + count, 1)
		
		while (idx < count)
	
			Actor activeComp = ActiveCompanionCollectionAlias.GetAt(idx) as Actor
			
			if (activeComp == StrongCompanionRef)
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
	
	; if (DTSleep_SettingNotifications.GetValue() > 0.0)
	
		;Frisky notices
		
		; Utility.Wait(2.5)
		
		; int friskyScore = PlayerFriskyScore()
		; int sexySpotScore = LocationScoreByFriskyScore(friskyScore)
		; float gameTime = Utility.GetCurrentGameTime()
		
		
		; if ((gameTime - NoticeFriskyLastShown) > 2.3)
		
			; bool companionIsInLove = false
			
			; if (CompanionAlias != None)
				; CompanionActorScript aCompanion = CompanionAlias.GetActorReference() as CompanionActorScript
				
				; if (aCompanion && aCompanion.IsRomantic())
				
					; companionIsInLove = true
				; endIf
			; endIf
		
			; if (sexySpotScore > 10 && companionIsInLove)
			
				; DTSleep_FriskyForLocationMessage.Show()
				; NoticeFriskyLastShown = gameTime
				
			; elseIf (sexySpotScore > 0 && friskyScore > 25 && friskyScore <= 60)
			
				; DTSleep_FriskyFeelingMessage.Show()
				; NoticeFriskyLastShown = gameTime
				
			; elseIf (sexySpotScore > 0 && friskyScore > 60)
			
				; DTSleep_FriskyNeedMessage.Show()
				; NoticeFriskyLastShown = gameTime
			; endIf
		; endIf
	
	; endif
	
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
		if (DTSleep_RestCount.GetValueInt() > 1 && TipSleepModeDisplayCount == 2)
		
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

Function GoCompanionRedress()
	PipboyMenuCloseType = CompanionRedressID
	RegisterForMenuOpenCloseEvent("PipboyMenu")
endFunction

Function GoNearbyCompanionInLoveNaked()
	IntimateCompanionSet companionSet = GetCompanionNearbyHighestRelationRank(true)

	(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).AltFemBodyEnabled = false

	SetUndressForManualStop(true, companionSet.CompanionActor, false, companionSet.RequiresNudeSuit, None, false, false)
endFunction

Function GoNearbyCompanionInLoveUndressForBed()


	PipboyMenuCloseType = CompanionUndressID
	RegisterForMenuOpenCloseEvent("PipboyMenu")
endFunction

Function GoPlayerNaked()

	PipboyMenuCloseType = PlayerUndressID
	RegisterForMenuOpenCloseEvent("PipboyMenu")
endFunction

Function GoDance()

	PipboyMenuCloseType = DanceID
	RegisterForMenuOpenCloseEvent("PipboyMenu")
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
		MainQSceneScriptP.GoSceneViewStart()
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
		
		if (moveToBed && OkayToSleepLocationBed(bedRef))
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

;
;  The Perk activator displays warnings for power armor, encumbered, and combat, but
;  we must check here, too
;
bool Function CanPlayerPerformRest(ObjectReference onBedRef)

	if (Game.IsActivateControlsEnabled())
		if (DTSleep_PlayerUsingBed.GetValue() == 0.0)
		
			; several of these should be excluded by the Perk, but let's all test just in case
			
			float bedHeight = onBedRef.GetPositionZ() - PlayerRef.GetPositionZ()
			if (bedHeight > 64.0)
				DTSleep_NoRestBedHighMsg.Show()
				return false
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
			
			if (CanPlayerRestRadDam() == false)
				return false
			endIf
			
			Form bedBase = onBedRef.GetBaseObject()
			if (bedBase != None && DTSleep_BedChildList.HasForm(bedBase))
				DTSleep_NoRestBedChildMsg.Show()
				Utility.Wait(0.05)
				return false
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
			
			return CanPlayerPerformRest(onBedRef)
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
			
			DTSleep_NoRestRadDamMsg.Show()
			
			return false
			
		elseIf (difMin > 10080.0)
			; been a week - re-register
			; been a week - re-register
			DTDebug(" Re-register for rad damage event - been a week ", 1)
			
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
	
	if (DTSleep_SettingUndress.GetValue() > 0.0)
		nearCompanion = GetCompanionNearbyHighestRelationRank(false)
	endIf
	
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

int Function ChanceForHugSceneAdjChair(int chance, int relationRank)

	if (relationRank >= 4)
		chance += 30
	elseIf (relationRank == 3)
		chance += 25
	else
		chance += 10
	endIf
	if (chance > 100)
		chance = 100
	endIf
	return chance
endFunction

int Function ChanceForIntimateSceneAdjDance(int chance)
	if (chance == 500)
		; version check
		return 2152
	endIf
	; v2+ hug/kiss instead of dance
	
	return chance
endFunction

; may also be used for toture devices
; reduce chance and limit maximum
int Function ChanceForIntimateSceneAdjChair(int chance)
	
	if (chance > 5)
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
		if ((DTSConditionals as DTSleep_Conditionals).NoraSpouseRef != None && companionRef == (DTSConditionals as DTSleep_Conditionals).NoraSpouseRef)
			; bonus for Nora spouse - she is also a rank higher as if romanced
			CompanionActorScript compAct = companionRef as CompanionActorScript
			if (compAct.IsRomantic() || companionRef.GetValue(CA_AffinityAV) >= 1000.0)
				;Debug.Trace(myScriptName + " Nora bonus romanced")
				result = 40
			else
				result = 20
			endIf
			
		elseIf ((DTSConditionals as DTSleep_Conditionals).DualSurvivorsNateRef != None && companionRef == (DTSConditionals as DTSleep_Conditionals).DualSurvivorsNateRef)
			CompanionActorScript compAct = companionRef as CompanionActorScript
			if (compAct.IsRomantic() || companionRef.GetValue(CA_AffinityAV) >= 1000.0)
				result = 40
			else
				result = 20
			endIf
		elseIf ((DTSConditionals as DTSleep_Conditionals).InsaneIvyRef != None && companionRef == (DTSConditionals as DTSleep_Conditionals).InsaneIvyRef)
			result = 36
		elseIf (companionRef == CurieRef)
			result = 16
		elseIf (companionRef == CompanionDanseRef)
			result = 12
		elseIf (companionRef == GetHeatherActor())
			; heather gets rank of 5 for full romanced even without ring
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
	elseIf (DTSleep_AdultContentOn.GetValue() <= 1.0)
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
	
	if (!companionRef)
		result.Chance = 0
		result.SexAppeal = 0
		
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
		
		; note: rank-2 penalty below may also apply if Strong on rank 2

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
		
		sameLoveBonus = 1 + SceneData.CurrentLoverScenCount
		if (SceneData.CurrentLoverScenCount > IntimacySceneCount)
			sameLoveBonus = IntimacySceneCount
			SceneData.CurrentLoverScenCount = sameLoveBonus
		endIf
		
		if (sameLoveBonus > 9)
			; after 10 - +5 bonus and increase at 1/4 per count
			sameLoveBonus = 12 + ((sameLoveBonus * 0.25) as int)
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
			companionRankChance = -39 - sexAppealFraction
		else
			companionRankChance = -48 - sexAppealFraction
		endIf
		if (companionSet.HasLoverRing)
			companionRankChance += 26
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

	; 1-day is neutral (zero), -72 (under hour) to +48 (15 days)
	;
	chanceLastTime = ChanceForIntimateSceneByLastTime(companionRelRank, gameTime, failReset, forHugs, true)
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
	
		result.Chance = 95
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
		Debug.Trace(myScriptName + " intimate same-lover : " + sameLoveBonus + " (count: " + SceneData.CurrentLoverScenCount + ")")
		Debug.Trace(myScriptName + " intimate Location   : " + locHourChance.ChanceReal + " (" + locHourChance.Chance + ")")
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
		
		;Debug.Trace(myScriptName + " chance morn-hour scale: " + hourScale + " at hour: " + hourOfDay)
		
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
	
	if (creatureType == CreatureTypeStrong)
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
				chanceHoliday = 36		; Valentine
				if (SceneData.CurrentLoverScenCount > 1)
					chanceHoliday += 32
				endIf
			elseIf (holidayVal == 1)
				chanceHoliday = 24
				if (SceneData.CurrentLoverScenCount > 1)
					chanceHoliday += 16
				endIf
			elseIf (holidayVal == 8)
				; Halloween
				chanceHoliday = 28
				
			elseIf (holidayVal >= 11 && holidayVal <= 12)
				; Christmas
				chanceHoliday = 30
				if (SceneData.CurrentLoverScenCount > 1)
					chanceHoliday += 24
				endIf
			elseIf (holidayVal == 13)
				; new year eve
				chanceHoliday = 24
				
			else
				chanceHoliday = 16
			endIf
		endIf
	endIf
	
	; ------------ location and weather -----------
	
	bool checkWeather = true
	int checkActorByLocChance = -1   ; 0 is wilderness, 10 = rented or workshop, 20 = town or undress - also for penalty score
	
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
				locChance = 21
			elseIf (creatureType == CreatureTypeDog)
				locChance = 44
			else
				locChance = 42
			endIf
			checkWeather = false
			locName = "home-plate"
			indoors = true
			if (!SceneData.IsUsingCreature && bedRef != None && !bedRef.HasKeyword(AnimFurnFloorBedAnims))
				result.BedOwned = true
			endIf
			; not checking checkActorByLocChance - extra NPCs considered a guests so scored as no NPCs
			
		elseIf (DTSleep_PrivateLocationList && (DTSleep_PrivateLocationList.HasForm(currentLoc as Form)))
			locName = "private"
			if (creatureType == CreatureTypeStrong)
				locChance = 24
			else
				locChance = 40
			endIf
			checkWeather = false
			indoors = true
			if (!SceneData.IsUsingCreature && bedRef != None && !bedRef.HasKeyword(AnimFurnFloorBedAnims))
				result.BedOwned = IsBedOwnedByPlayer(bedRef, companionRef)
			endIf
			; not checking checkActorByLocChance - extra adult NPCs considered a guests
			
		elseIf (!forHugs && DTSleep_CrimeLocationList.HasForm(currentLoc as Form) && !PlayerRef.IsInInterior())
			locChance = 5
			locName = "crime-area"
			checkActorByLocChance = LocActorChanceTown
		elseIf (!forHugs && DTSleep_CrimeLocationIntList.HasForm(currentLoc as Form))
			locChance = 10
			locName = "crime-area"
			checkActorByLocChance = LocActorChanceTown
			
		elseIf (DTSleep_UndressLocationList && (DTSleep_UndressLocationList.HasForm(currentLoc as Form)))
			locName = "undress-safe"
			if (creatureType == CreatureTypeStrong)
				locChance = 20
			else
				locChance = 26
			endIf

			checkActorByLocChance = LocActorChanceTown ;20
			indoors = PlayerRef.IsInInterior()
			if (!SceneData.IsUsingCreature && bedRef != None && !bedRef.HasKeyword(AnimFurnFloorBedAnims))
				result.BedOwned = IsBedOwnedByPlayer(bedRef, companionRef)
			endIf
		elseIf (romanticQuestFin && (creatureType == 0 || creatureType == CreatureTypeSynth) && DTSleep_IntimateTourLocList.HasForm(currentLoc as Form))
			locChance = 25			; plus additional bonus below
			locName = "romantic"
			indoors = PlayerRef.IsInInterior()
			checkActorByLocChance = LocActorChanceTown
			
		elseIf (bedRef != None)
			bool bedIsPillory = false
			bool bedIsOtherFurniture = false
			
			if (baseBedForm == None)
				baseBedForm = bedRef.GetBaseObject() as Form
			endIf
			
			if (baseBedForm != None && (DTSleep_PilloryList.HasForm(baseBedForm) || DTSleep_TortureDList.HasForm(baseBedForm)))
				bedIsPillory = true
			elseIf (!(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).IsObjBed(bedRef))
				bedIsOtherFurniture = true
			endIf
				
			if (!bedIsOtherFurniture && !bedIsPillory && IsBedOwnedByPlayer(bedRef, companionRef))
				
				if (creatureType == CreatureTypeStrong)
					locChance = 16
				elseIf (creatureType == CreatureTypeDog)
					locChance = 25
				else
					locChance = 32
				endIf
				locName = "owned-bed"
				checkActorByLocChance = LocActorChanceOwned   ; 10- set to determine distance check and limit penalty
				result.BedOwned = true
				
			elseIf (DTSleep_TownLocationList && DTSleep_TownLocationList.HasForm(currentLoc as Form))
				; towns include some settlements, raider forts

				locChance = 14
				if (creatureType == 0 && romanticQuestFin)
					; in addition to bonus below
					locChance += 10
				elseIf (forHugs)
					locChance += 12
				endIf
				
				checkActorByLocChance = LocActorChanceTown
				locName = "town"
				
				if (bedIsPillory)
					locChance -= 20
				endIf
				
			elseIf (creatureType == 0 && !bedIsOtherFurniture && !bedIsPillory && bedRef.IsOwnedBy(companionRef))
				locChance = 22
				if (romanticQuestFin)
					; in addition to bonus below
					locChance += 10
				endIf
				checkActorByLocChance = LocActorChanceSettled   ; usually settlement since most companion homes marked Undress
				locName = "companion-bed"
				result.BedOwned = true
				
			elseIf (currentLoc.HasKeyword(LocTypeWorkshopSettlementKY))
				; faster than using bed-workshop-check below and workshop may be locked which is okay here
				if (creatureType == CreatureTypeStrong)
					locChance = -8
				elseIf (creatureType == CreatureTypeDog)
					locChance = -3
				elseIf (romanticQuestFin)
					; in addition to bonus below
					locChance = 18
				elseIf (forHugs)
					locChance += 12
				else
					locChance = 9
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
				checkActorByLocChance = 12
				locName = "interior"
				indoors = true
				
				
			elseIf (DTSleep_BedIntimateList.HasForm(baseBedForm))
				; mod beds like Campsite or intimate bonus
				if (bedRef.HasKeyword(AnimFurnFloorBedAnims))
					; these beds also provide bonus below
					if (creatureType == 0)
						locChance = -15
					elseIf (creatureType == CreatureTypeStrong)
						locChance = 10
					elseIf (creatureType == CreatureTypeDog)
						; dog loves camping! and mod-beds outdoors
						locChance = 15
					endIf
					checkActorByLocChance = LocActorChanceWild    	; check like wilderness
					locName = "mod-bed camping"
				else
					locChance = 5
					locName = "intimate bed not-town/settlement"
				endIf
				
			else 
				; check workshops 
				; checked last because slowest - also determines if player has access to workshop
				; Conquest camp uses this
				int workshopBedNum = IsObjBelongPlayerWorkshop(bedRef)
				
				if (workshopBedNum == 2)
					locName = "ConquestWorkshop-bed"
					if (creatureType == 0)
						locChance = 3
					elseIf (creatureType == CreatureTypeStrong)
						locChance = 20
					elseIf (creatureType == CreatureTypeDog)
						; dog loves camping!
						locChance = 25
					endIf
					checkActorByLocChance = LocActorChanceWild   ; check like wilderness
					
				elseIf (workshopBedNum == 1)
					if (creatureType == CreatureTypeStrong)
						locChance = -8
					elseIf (creatureType == CreatureTypeDog)
						locChance = -5
					else
						locChance = 7
					endIf
					checkActorByLocChance = LocActorChanceSettled
					locName = "workshop-bed"
					if (bedIsPillory)
						locChance -= 20
					endIf
					
				else
					; wilderness / unknown bed
					if (creatureType == CreatureTypeStrong)
						locChance = 17
					elseIf (creatureType == CreatureTypeDog)
						; dog outside at night should work out similar to private area
						locChance = 21
					elseIf (forHugs)
						locChance = -8
					else
						locChance = -18
					endIf
					checkActorByLocChance = LocActorChanceWild
				endIf
			endIf
		endIf
		
		if (romanticQuestFin)
			locChance += 15		; in addition to selected above situations
		endIf
		
		; bed bonus
		if (baseBedForm != None && DTSleep_BedIntimateList.HasForm(baseBedForm))
			hasBedBonus = true
			locChance += 18
		endIf
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
		float closestNPCDist = 2500.0
		float distance = 1800.0		; 2400 used by IsNearby
		
		
		if (len > 0)
			if (checkActorByLocChance == LocActorChanceWild)
				distance = 2400.0   ; wilderness  
				
			elseIf (checkActorByLocChance == LocActorChanceOwned)
				
				distance = 656.0
				len = 1		  		; only check NPC
				
			elseIf (checkActorByLocChance == LocActorChanceSettled)
			
				distance = 760.0  	; settlement bed
				len = 1		  		; only check NPC
				
			elseIf (checkActorByLocChance == LocActorChanceTown)
				distance = 1200.0  	; town, undress location
				len = 1		  		; only check NPC
			endIf
			
			while (index < len)
			
				ObjectReference[] actorArray = PlayerRef.FindAllReferencesWithKeyword(DTSleep_ActorKYList.GetAt(index), distance)
				Actor heatherActor = GetHeatherActor()
				Actor barbActor = GetNWSBarbActor()
								
				int aCnt = 0
				while (aCnt < actorArray.Length)
					Actor ac = actorArray[aCnt] as Actor
					if (ac != None && ac != PlayerRef && ac.IsEnabled() && !ac.IsDead() && !ac.IsUnconscious())
						
						if (index == 0)
							if ((DTSConditionals as DTSleep_Conditionals).IsWorkShop02DLCActive && ac.HasKeyword((DTSConditionals as DTSleep_Conditionals).DLC05ArmorRackKY))
								; do nothing -
								; not counting workshop armor mannequin which is NPC
							
							else
								
								CompanionActorScript aCompanion = GetCompanionOfActor(ac)
								
								if (aCompanion != None && creatureType <= 0 && ac != companionRef)
								
									; even if sleeping - poses risk and concern for current companion
									if ((DTSleep_IntimateAffinityQuest as DTSleep_IntimateAffinityQuestScript).CompanionHatesIntimateOtherPublic(ac))
										nearbyLoverHateCount += 1
									elseIf (ac.GetSleepState() >= 3)
										nearbyActorSleepCount += 1
									else
										bool isPartner = false
										if (aCompanion.IsRomantic())
											isPartner = true
										elseIf (aCompanion.IsInFatuated())
											isPartner = true
										elseIf (DTSleep_CompanionRomanceList.HasForm(ac as Form) && aCompanion.GetValue(CA_AffinityAV) >= 1000.0)
											isPartner = true
										elseIf (PlayerHasPerkOfCompanion(ac))
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
									
									if (creatureType != CreatureTypeStrong && ac.GetDistance(PlayerRef) > 250.0)
										nearbyActorSleepCount += 1
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
							endIf
							
							if (ac.HasKeyword(ActorTypeChildKY))
								childCount += 1
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
			
			if (creatureType != CreatureTypeDog)
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
				if (creatureType == CreatureTypeStrong)
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
				npcChance -= (childCount * 24)		; extra penalty for child nearby
			endIf
		endIf
		
		; area penalty
		
		if (checkActorByLocChance == LocActorChanceWild)
			; wilderness - compensate for unknown area penalty if no spectators
			
			int count = nearbyActorCount				
			
			if (creatureType != CreatureTypeDog)
				count -= 1											; subtract for love-companion
			endIf
			
			if (count >= 3)
				npcChance -= 10
				
			elseIf (count <= 0 && nearbyActorSleepCount == 0 && nearbyLoverCount == 0)
				; all alone!
				npcChance += 6
				
				; best be alone with creatures - extra bonus for beginners
				if (creatureType == CreatureTypeDog)
					npcChance += (12 + expAdj)

				elseIf (creatureType == CreatureTypeStrong)
					npcChance += (4 + expAdj)
				endIf
				
			elseIf (count <= 0 && nearbyLoverCount == 1 && creatureType <= 0)
				npcChance += 2
			elseIf (count <= 0 && nearbyActorSleepCount == 1)
				npcChance += 4
			elseIf ((count + nearbyActorSleepCount) <= 2)
				npcChance += 1
			endIf
			
		elseIf (nearbyActorCount >= 8)
			; too much audience
			; remember: also negated for actor count
			npcChance -= checkActorByLocChance
			
		elseIf (nearbyActorCount > 4)
			; okay, a small audience
			
			npcChance -= (checkActorByLocChance * 0.5) as int
			
		elseIf (locChance < 40 && nearbyActorCount <= 2)
			; alone at last-- not checking private areas, but locChance < 40 in case change mind
			npcChance += 2
			
			if (nearbyActorCount == 1)
				if (creatureType == CreatureTypeDog)
					npcChance += 7 
				elseIf (creatureType == CreatureTypeStrong)
					npcChance += 4
				endIf
			endIf
		
		endIf
		
	elseIf (!forHugs)
		; in private area - assume adults are guests and only check children
		; generally child in private area if leading child by quest or using mod to add children
		;
		ObjectReference[] actorArray = PlayerRef.FindAllReferencesWithKeyword(ActorTypeChildKY, 800.0)
		if (actorArray != None && actorArray.Length > 0)
			childCount = actorArray.Length
			npcChance -= (16 * childCount)
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
	
	; determine to report guess or uncertainty
	
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
	else
		result.LocChanceType = checkActorByLocChance
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
	
	result.ChanceReal = chance
	
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
				chanceFails = 16
			else
				if (companionRelRank >= 3)
					chanceFails = 20
				else
					chanceFails = 8
				endIf
				if (expDog == 0 && expStr == 0)
					chanceFails += 8
				endIf
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
		DTDebug(" chance intimate -- too soon!", 2)
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
			chanceSince = 16
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
		int penaltyFactor = 18 - endurVal + (IntimacyDayCount * 5)
		if (penaltyFactor < 10)
			penaltyFactor = 10
		endIf
		sameDayPen = 0 - (IntimacyDayCount * penaltyFactor)
		chance += sameDayPen
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

; returns negative if not a companion else relation rank
int Function CompanionRelationRankForActor(Actor actorRef)
	if (!actorRef)
		return -2
	endIf
	
	CompanionActorScript myCompanion = actorRef as CompanionActorScript
	if (myCompanion != None)
		if (myCompanion.IsRomantic())
			return 4
		elseIf (myCompanion.IsInfatuated())
			return 3
		endIf
		
		if (DTSleep_CompanionRomanceList.HasForm(actorRef))
			if (myCompanion.GetValue(CA_AffinityAV) >= 1000.0)
				Debug.Trace(myScriptName + " high affinity romance, but not Romantic for actor " + actorRef)
				return 3
			endIf 
		endIf
	endIf
	
	if ((DTSConditionals as DTSleep_Conditionals).IsHeatherCompanionActive)
		
		Actor heatherActor = GetHeatherActor()
		
		if (heatherActor && heatherActor == actorRef)
			;if (heatherActor.GetDistance(PlayerRef) < 1800.0)
				; Heather doesn't use relationship rank
				int relationRank = 2
				int heatherLove = IsHeatherInLove()
				if (heatherLove >= 2)
					relationRank = 5
				elseIf (heatherLove == 1)
					relationRank = 4
				endIf
				return relationRank
			;endIf
		endIf
	endIf
	
	if ((DTSConditionals as DTSleep_Conditionals).IsNWSBarbActive)
		Actor barbActor = GetNWSBarbActor()
		
		if (barbActor && barbActor == actorRef)
			if (IsNWSBarbInLove())
			
				return 4
			else
				return 2
			endIf
		endIf
	endIf


	return 1
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
				DTDebug("check swap scene roles clearing second actors -- does not meet requirements", 1)
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
			DTDebug(" on clear 2nd lover swap back " + IntimateCompanionRef + " to male role ", 2)
			SceneData.MaleRole = IntimateCompanionRef
			SceneData.SameGender = true
		elseIf (IntimateCompanionSecRef == SceneData.FemaleRole)
			DTDebug(" on clear 2nd lover swap back " + IntimateCompanionRef + " to female role ", 2)
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

FormList Function CombinedTableFormList()

	FormList result = (DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).DTSleep_IntimateTableList
	FormList dinTableList = (DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).DTSleep_IntimateDiningTableList
	FormList roundTableList = (DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).DTSleep_IntimateRoundTableList

	int i = 0
	int len = dinTableList.GetSize()
	while (i < len)
		Form item = dinTableList.GetAt(i)
		result.AddForm(item)
		
		i += 1
	endWhile
	i = 0
	len = roundTableList.GetSize()
	while (i < len)
		Form item = roundTableList.GetAt(i)
		result.AddForm(item)
		
		i += 1
	endWhile

	return result
endFunction

; does not include Synth-Gen2
int Function CreatureTypeForCompanion(Actor companionRef)

	if (companionRef == StrongCompanionRef)
	
		return CreatureTypeStrong
	
	elseIf (companionRef.HasKeyword(ActorTypeDogmeatKY))
	
		return CreatureTypeDog
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

Function DTDebug(string msgStr, int level)
	if (DTSleep_SettingTestMode.GetValue() > 0.0 && DTSleep_DebugMode.GetValueInt() >= level)
		Debug.Trace(myScriptName + " " + msgStr)
	endIf
endFunction

Function EnablePlayerControlsSleep()
	if (SleepInputLayer != None)
		DTDebug(" Enable Controls", 3)

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
		
		DTDebug("  FadeIn, fast:" + fast, 3)
	
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
	DTDebug("  FadeOut, fast:", 3)
	
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
	
	float distance = 1260.0				; reasonable for most areas
	if (IsLocationPrivateOrUndress())
		distance = 1500.0
	elseIf (aCompanionRef.IsInInterior())
		distance = 850.0
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

	DTDebug(" FindBed for Companion: " + aCompanionRef + ", found close/quest beds: " + closeBedRef + " / " + aBedRef, 1)
	
	if (closeBedRef != None && closeBedRef != aBedRef)
		
		if (IntimateCompanionRef == None || IntimateCompanionRef == aCompanionRef)
			if (aBedRef == None || aBedRef == SleepBedInUseRef || aBedRef.IsFurnitureInUse())		; v1.53 alias bed may be in use
				DTDebug(" forcing (1) bed alias to closeBed", 2)
				DTSleep_CompBedRestAlias.ForceRefTo(closeBedRef)
				aBedRef = closeBedRef
			elseIf (closeBedRef.GetDistance(SleepBedInUseRef) < aBedRef.GetDistance(SleepBedInUseRef))
				DTDebug(" forcing (2) bed alias to closeBed", 2)
				DTSleep_CompBedRestAlias.ForceRefTo(closeBedRef)
				aBedRef = closeBedRef
			elseIf (aBedRef.HasActorRefOwner())
				; v1.54 owned check
				if (aBedRef.IsOwnedBy(aCompanionRef) == false)
					DTDebug(" forcing (3) bed alias to closeBed", 2)
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
			DTDebug("quest bed alias in use and no other bed found", 2)
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
			if (loverActor != None && loverActor.GetItemCount(DTSleep_ArmorLoverRing) > 0 && loverActor.GetDistance(PlayerRef) < 500.0)
				if (DTSleep_CommonF.IsActorOnBed(loverActor, bedRef))
				
					return loverActor
				endIf
			endIf
		endIf
		
		return None
	endIf
	
	if (SleepCompanionAlias != None)
		Actor sleepCompActor = SleepCompanionAlias.GetActorReference() as Actor
		if (sleepCompActor)
			CompanionActorScript myCompanion = sleepCompActor as CompanionActorScript
			if (myCompanion)
				if (myCompanion.IsInfatuated() || myCompanion.IsRomantic())

					return sleepCompActor
				endIf
			endIf
		endIf
	endIf
	
	if (CompanionAlias != None)
		Actor companionActor = CompanionAlias.GetActorReference()
		if (companionActor) 
			if (DTSleep_CommonF.IsActorOnBed(companionActor, bedRef))

				CompanionActorScript myCompanion = companionActor as CompanionActorScript
				if (myCompanion && myCompanion.IsRomantic())

					return companionActor
				endIf
			endIf
		endIf
	endIf
	
	if ((DTSConditionals as DTSleep_Conditionals).IsHeatherCompanionActive)
		
		Actor heatherActor = GetHeatherActor()
		if (heatherActor && heatherActor.GetDistance(PlayerRef) < 500.0)
		
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
		if (barbActor && barbActor.GetDistance(PlayerRef) < 500.0)
			
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
		
		while(idx < count)
			CompanionActorScript aCompanion = ActiveCompanionCollectionAlias.GetAt(idx) as CompanionActorScript
			if (aCompanion && aCompanion.IsInfatuated() && aCompanion.GetDistance(PlayerRef) < 300.0)
				
				if (DTSleep_CommonF.IsActorOnBed(aCompanion, bedRef))

					return aCompanion
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
	DTDebug(" ActiveCompanion Count: " + count, 3)
	
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
	
	if (aCompanion == StrongCompanionRef)
		return PlayerRef.HasPerk(CompStrongPerk)
	elseIf (aCompanion == CompanionDeaconRef)
		return PlayerRef.HasPerk(CompDeaconPerk)
	elseIf (aCompanion == CompanionX6Ref)
		return PlayerRef.HasPerk(CompX6Perk)
	elseIf ((DTSConditionals as DTSleep_Conditionals).IsCoastDLCActive && aCompanion == (DTSConditionals as DTSleep_Conditionals).FarHarborDLCLongfellowRef)
		return PlayerRef.HasPerk((DTSConditionals as DTSleep_Conditionals).FarHarborDLCLongfellowPerk)
		
	elseIf ((DTSConditionals as DTSleep_Conditionals).IsRobotDLCActive && aCompanion == (DTSConditionals as DTSleep_Conditionals).RobotAdaRef)
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
				if (heatherLove >= 2)
					result.RelationRank = 5
				endIf
				result.Gender = 1
				if (heatherActor.IsInPowerArmor())
					result.PowerArmorFlag = true
					result.RequiresNudeSuit = true
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
					result.PowerArmorFlag = true
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
			if (loverActor != None && loverActor != notActor && loverActor.GetItemCount(DTSleep_ArmorLoverRing) > 0 && loverActor.GetDistance(PlayerRef) < 2000.0)
				DTDebug("found true love ring holder " + loverActor, 1)
				if (loverActor.IsDead())
					; ummm...
					
				elseIf (!loverActor.IsUnconscious() && !loverActor.WornHasKeyword(ArmorTypePower))
					IntimateCompanionSet ics = new IntimateCompanionSet
					ics.CompanionActor = loverActor
					ics.HasLoverRing = true
					ics.RelationRank = GetRelationRankActor(loverActor, true)
					if (loverActor.IsInPowerArmor())
						ics.PowerArmorFlag = true
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
						ics.PowerArmorFlag = true
					endIf
					resultArray.Add(ics)
				endIf
			endIf
			
			return resultArray
		endIf
	endIf
	
	ObjectReference[] actorArray = PlayerRef.FindAllReferencesWithKeyword(DTSleep_ActorKYList.GetAt(0), 900.0)
	;Debug.Trace(myScriptName + " found nearby npc count " + actorArray.Length)
	
	while (actorArray != None && aCnt < actorArray.Length)
		Actor ac = actorArray[aCnt] as Actor
		
		if (ac != None && ac != notActor && ac != PlayerRef && ac.IsEnabled() && !ac.IsDead() && !ac.IsUnconscious())
			
			if ((DTSConditionals as DTSleep_Conditionals).IsWorkShop02DLCActive && ac.HasKeyword((DTSConditionals as DTSleep_Conditionals).DLC05ArmorRackKY))
				; do nothing -
				; don't want no workshop armor mannequin which is NPC
				
			elseIf (ac.GetSleepState() <= 2)
				
				CompanionActorScript aCompanion = GetCompanionOfActor(ac)
				
				if (aCompanion != None && !aCompanion.IsChild())
				
					bool isCompRomantic = aCompanion.IsRomantic()
					
					if (aCompanion.IsInfatuated() || isCompRomantic || aCompanion.GetValue(CA_AffinityAV) >= 1000.0)
						if (IsCompanionRaceCompatible((aCompanion as Actor), None, isCompRomantic))
						
							IntimateCompanionSet ics = new IntimateCompanionSet
							ics.CompanionActor = ac
							
							if (!aCompanion.WornHasKeyword(ArmorTypePower))
								
								ics.Gender = (DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).GetGenderForActor(ac)
								
								if (prefGender == 2 || prefGender == ics.Gender)
									if (aCompanion.IsInPowerArmor())
										ics.PowerArmorFlag = true
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
	
	; note: Ada from DLCRobot starts as IsInfatuated - so ensure is not a robot
	
	if ((DTSConditionals as DTSleep_Conditionals).LoverRingEquipCount > 0)
		; companion has a ring - consider only the ring!
		DTDebug(" checking for nearby lover ring owner...", 2)
		
		if (DTSleep_TrueLoveAlias != None)
			Actor loverActor = DTSleep_TrueLoveAlias.GetActorReference()
			if (loverActor != None && loverActor.GetItemCount(DTSleep_ArmorLoverRing) > 0 && loverActor.GetDistance(PlayerRef) < 2000.0)
				DTDebug("found true love ring holder " + loverActor, 1)
				if (loverActor.IsDead())
					; ummm...
					DTDebug("  lover's ring wearer, " + loverActor + " is... dead.", 1)
				elseIf (!loverActor.IsUnconscious())
					result.CompanionActor = loverActor
					result.HasLoverRing = true
					result.RelationRank = GetRelationRankActor(loverActor, true)
					if (loverActor.WornHasKeyword(ArmorTypePower))
						mainCompanionPA = true
					elseIf (loverActor.IsInPowerArmor())
						result.PowerArmorFlag = true
					endIf
					;result.Gender = (DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).GetGenderForActor(loverActor)
				endIf
			endIf
		endIf
	else
		DTDebug(" checking for nearby lovers...", 2)
		
		if (PlayerHasActiveCompanion.GetValueInt() > 0 && CompanionAlias != None)
		
			; main companion
			CompanionActorScript aCompanion = CompanionAlias.GetActorReference() as CompanionActorScript
			
			if (aCompanion != None && aCompanion.IsEnabled() && !aCompanion.IsDead() && !aCompanion.IsUnconscious())
			
				; check NoraSpouse and DualSurvivor first - assume in love
				if ((DTSConditionals as DTSleep_Conditionals).NoraSpouseRef != None && aCompanion == (DTSConditionals as DTSleep_Conditionals).NoraSpouseRef)
				
					if (aCompanion.GetDistance(PlayerRef) < 1600.0)
						result.CompanionActor = (DTSConditionals as DTSleep_Conditionals).NoraSpouseRef
						result.HasLoverRing = false
						result.RelationRank = 4
						if (aCompanion.IsRomantic() || aCompanion.GetValue(CA_AffinityAV) >= 900.0)
							result.RelationRank = 5
						endIf
						if (aCompanion.WornHasKeyword(ArmorTypePower))
							mainCompanionPA = true
						elseIf (aCompanion.IsInPowerArmor())
							result.PowerArmorFlag = true
						endIf
						if (aCompanion.GetSitState() <= 1 && aCompanion.GetSleepState() <= 2)
							topRelBusy = false
						else
							topRelBusy = true
						endIf
					endIf
					
				elseIf ((DTSConditionals as DTSleep_Conditionals).DualSurvivorsNateRef != None && aCompanion == (DTSConditionals as DTSleep_Conditionals).DualSurvivorsNateRef)
					if (aCompanion.GetDistance(PlayerRef) < 1600.0)
						result.CompanionActor = (DTSConditionals as DTSleep_Conditionals).DualSurvivorsNateRef
						result.HasLoverRing = false
						result.RelationRank = 4
						if (aCompanion.IsRomantic() || aCompanion.GetValue(CA_AffinityAV) >= 900.0)
							result.RelationRank = 5
						endIf
						if (aCompanion.WornHasKeyword(ArmorTypePower))
							mainCompanionPA = true
						elseIf (aCompanion.IsInPowerArmor())
							result.PowerArmorFlag = true
						endIf
						if (aCompanion.GetSitState() <= 1 && aCompanion.GetSleepState() <= 2)
							topRelBusy = false
						else
							topRelBusy = true
						endIf
					endIf
				elseIf (minRank <= 2 && DTSleep_SettingIntimate.GetValue() >= 2.0)
					; ---- optional extra NPCs -------------
					
					if (DTSleep_AdultContentOn.GetValue() >= 1.0 && aCompanion == StrongCompanionRef)
					 
						if (!(DTSConditionals as DTSleep_Conditionals).IsVulpineRacePlayerActive)
							if (prefGender == 2 || prefGender == 0)
								if (DTSleep_SettingIntimate.GetValue() >= 2.0 && DressData.PlayerGender == 1 && PlayerRef.HasPerk(CompStrongPerk) && aCompanion.GetValue(CA_AffinityAV) >= 900.0)
								
									float distance = aCompanion.GetDistance(PlayerRef)
									if (distance < 900.0)
										result.CompanionActor = aCompanion as Actor
										result.RelationRank = 2   ; default 
										
										if (PlayerHasMutantTreats())
											result.RelationRank = 3
										endIf
									
										return result
									endIf
								endIf
							endIf
						endIf
						
					elseIf (PlayerHasPerkOfCompanion(aCompanion as Actor))
					
						bool affinityOk = false
						bool genderOkay = true
						
						if ((DTSConditionals as DTSleep_Conditionals).IsRobotDLCActive && aCompanion == (DTSConditionals as DTSleep_Conditionals).RobotAdaRef)
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
									result.PowerArmorFlag = true
								endIf
								result.CompanionActor = aCompanion as Actor
								result.RelationRank = 2
								topRelationRank = 2
								
								if (aCompanion.GetSitState() <= 1 && aCompanion.GetSleepState() <= 2)
									topRelBusy = false
								else
									topRelBusy = true
								endIf
							endIf
						endIf
					endIf
					
				endIf ; -------------------------- end extra NPCs
				
				; affinity over 1000 should be infatuated (if flirting), but check for game bug by including romance list
				
				if (aCompanion.IsInfatuated() || aCompanion.IsRomantic() || DTSleep_CompanionRomanceList.HasForm((aCompanion as Actor) as Form))
				
					float distance = aCompanion.GetDistance(PlayerRef)
					bool romantic = aCompanion.IsRomantic()
					bool genderOkay = true
					
					; v1.60 - remember: extra NPCs may show as infatuated and we've already considered these above
					if (aCompanion == StrongCompanionRef)
						; skip
					elseIf (aCompanion == CompanionDeaconRef || aCompanion == CompanionX6Ref)
						; skip
					elseIf (aCompanion != None && (DTSConditionals as DTSleep_Conditionals).IsCoastDLCActive && aCompanion == (DTSConditionals as DTSleep_Conditionals).FarHarborDLCLongfellowRef)
						; skip
					elseIf (aCompanion != None && (DTSConditionals as DTSleep_Conditionals).IsRobotDLCActive && aCompanion == (DTSConditionals as DTSleep_Conditionals).RobotAdaRef)
						; skip
					
					elseIf (distance < 1400.0 && !aCompanion.IsChild() && IsCompanionRaceCompatible((aCompanion as Actor), None, romantic))
						
						if (aCompanion.WornHasKeyword(ArmorTypePower))
							mainCompanionPA = true
						endIf
							
						genderOkay = true
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
								
								DTDebug(" InPowerArmor Race, but not Worn TypePower for ", 3)
								result.PowerArmorFlag = true
								result.RequiresNudeSuit = true
							endIf
							
							if (romantic)
								
								; only return if not sitting or sleeping - mark companion
								if (!mainCompanionPA)
									result.CompanionActor = aCompanion as Actor
									result.RelationRank = 4
									topRelationRank = 4
									
									if (!sitting && !sleeping)
										; ready now
										;result.Gender = (DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).GetGenderForActor(aCompanion)
										return result
									else
										topRelBusy = true
									endIf
								endIf
								mainCompanionRank = 4
								
							elseIf (aCompanion.IsInfatuated())
								
								if (!mainCompanionPA)
									topRelationRank = 3
									result.CompanionActor = aCompanion as Actor
									result.RelationRank = 3
									if (!sitting && !sleeping)
										topRelBusy = false
									else
										topRelBusy = true
									endIf
								endIf
								mainCompanionRank = 3
								
							elseIf (DTSleep_SettingShowIntimateCheck.GetValue() > 0.0 && aCompanion.GetValue(CA_AffinityAV) >= 1000.0)
								; allow even without extra NPCs
								DTDebug("not romanced/infatuated (or possible game romance bug) with " + aCompanion, 1)
								if (!mainCompanionPA)
									topRelationRank = 3
									result.RelationRank = 3
									result.CompanionActor = aCompanion as Actor
									if (!sitting && !sleeping)
										topRelBusy = false
									else
										topRelBusy = true
									endIf
								endIf
								mainCompanionRank = 3
							endIf
						endIf    ; end genderOkay
					endIf
				endIf
			endIf
		endIf
		
		if ((DTSConditionals as DTSleep_Conditionals).IsHeatherCompanionActive && prefGender >= 1)
			
			Actor heatherActor = GetHeatherActor()
			if (heatherActor != None && heatherActor.IsEnabled() && !heatherActor.IsDead() && !heatherActor.IsUnconscious() && heatherActor.GetDistance(PlayerRef) < 1300.0)
			
				bool paBug = false
				
				if (!heatherActor.WornHasKeyword(ArmorTypePower))
					
					if (heatherActor.IsInPowerArmor())
						; power armor is a race change - seems to cause problems
						result.RequiresNudeSuit = true
						paBug = true
						DTDebug(" InInPowerArmor Race, but not Worn TypePower for Heather!!", 3)
						
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
					if (IsCompanionPowerArmorGlitched(barbActor))
					
						result.RequiresNudeSuit = true
						paBug = true
						DTDebug(" InInPowerArmor Race, but not Worn TypePower for nwsBarb!!", 3)
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
			DTDebug(" ActiveCompanion Count: " + count, 2)
			
			while (idx < count)
		
				Actor activeComp = ActiveCompanionCollectionAlias.GetAt(idx) as Actor
				
				; v1.25 - extra NPCs may show as infatuated and must be main companion for consideration, so skip here
				if (activeComp == StrongCompanionRef || activeComp == CompanionDeaconRef || activeComp == CompanionX6Ref)
					
				elseIf (activeComp != None && (DTSConditionals as DTSleep_Conditionals).IsCoastDLCActive && activeComp == (DTSConditionals as DTSleep_Conditionals).FarHarborDLCLongfellowRef)
					
				elseIf (activeComp != None && (DTSConditionals as DTSleep_Conditionals).IsRobotDLCActive && activeComp == (DTSConditionals as DTSleep_Conditionals).RobotAdaRef)
					; v1.60 - must also check Ada for human-Ada mods
					
				elseIf (activeComp != None && !activeComp.IsDead() && !activeComp.IsUnconscious())
				
					bool okayToSelect = true
					if (prefGender >= 3 && SceneData.CurrentLoverScenCount >= 3)
						; faithful
						if (SceneData.FemaleRole != activeComp && SceneData.MaleRole != activeComp)
							okayToSelect = false
						endIf
					endIf
					
					CompanionActorScript aCompanion = activeComp as CompanionActorScript
					useNudeSuit = false
					
					if (okayToSelect && result.RelationRank < 4 && aCompanion != None && (aCompanion.IsInfatuated() || aCompanion.IsRomantic()))
						
						float distance = aCompanion.GetDistance(PlayerRef)

						if (distance < 900.0 && !aCompanion.IsChild() && IsCompanionRaceCompatible(aCompanion))
							
							if (!aCompanion.WornHasKeyword(ArmorTypePower))
							
								bool sitting = false
								bool sleeping = false
								if (aCompanion.GetSitState() >= 2)
									sitting = true
								endIf
								if (aCompanion.GetSleepState() >= 3)
									sleeping = true
								endIf
							
								DTDebug(" nearby friend/lover: " + aCompanion + " sitState: " + aCompanion.GetSitState(), 2)
							
								if (aCompanion.IsInPowerArmor())
									; power armor is a race change that may hurt our animations and undressing
									DTDebug(" InPowerArmor Race, but not Worn TypePower for " + aCompanion, 3)
									
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
									if (aCompanion.IsRomantic())
									
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
		DTDebug("main companion in PA " + result.CompanionActor, 2)
		
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

int Function GetRelationRankActor(Actor actorRef, bool isTrueLove)

	int romanceRank = 4
	if (isTrueLove)
		romanceRank = 5
	endIf
	if (DTSleep_CompanionRomanceList.HasForm(actorRef))
		if (actorRef.GetValue(CA_AffinityAV) >= 1000.0)
			return romanceRank
		elseIf (isTrueLove || (DTSConditionals as DTSleep_Conditionals).NoraSpouseRef != None && actorRef == (DTSConditionals as DTSleep_Conditionals).NoraSpouseRef)
			return 4
		elseIf ((DTSConditionals as DTSleep_Conditionals).DualSurvivorsNateRef != None && actorRef == (DTSConditionals as DTSleep_Conditionals).DualSurvivorsNateRef)
			return 4
		else
			return 3
		endIf
		
	elseIf (actorRef == CompanionDeaconRef)
		return 2
	elseIf (actorRef == CompanionX6Ref)
		return 2
	elseIf ((DTSConditionals as DTSleep_Conditionals).IsCoastDLCActive && actorRef == (DTSConditionals as DTSleep_Conditionals).FarHarborDLCLongfellowRef)
		return 2
	elseIf (actorRef == StrongCompanionRef)
		return 1	; base
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

Function GoThirdPerson()

	if (PlayerRef.GetAnimationVariableBool("IsFirstPerson"))
		
		DTSleep_WasPlayerThirdPerson.SetValue(-1.0)
	else
		DTSleep_WasPlayerThirdPerson.SetValue(1.0)
	endIf
	Game.ForceThirdPerson()
	
EndFunction


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
			if (DTSleep_SettingSave.GetValue() >= 2.0)
				hourLimit = 5
			endIf
			
			if (sleepHours >= hourLimit && (DTSleep_HealthRecoverQuestP as DTSleep_HealthRecoverQuestScript).SleepStarted)
				saveOK = true
				if (LastGameSaveTime > 0.0)
					float hoursSince = DTSleep_CommonF.GetGameTimeHoursDifference(curTime, LastGameSaveTime)
					if (hoursSince < 8.2)
						saveOK = false
					endIf
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
			if (hoursSleep <= 1)
			
				int restCount = DTSleep_RestCount.GetValueInt() - 1
				if (restCount > 1)
					DTSleep_RestCount.SetValueInt(restCount)
				endIf
			endIf
		endIf
		
		if (hoursSleep >= 6)
			(DTSleep_HealthRecoverQuestP as DTSleep_HealthRecoverQuestScript).StopAllDone(true)
		else
			LoverBonusRested(false)			; remove rested bonus
			(DTSleep_HealthRecoverQuestP as DTSleep_HealthRecoverQuestScript).StopAllCancel()
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
					if (DTSleep_SettingNotifications.GetValueInt() > 0)
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
	DTDebug(" OnExitFurniture - " + bedRef, 2)
	
	float timeToWait = 5.4
	if (bedRef.HasKeyword(AnimFurnFloorBedAnims))  ; what about slow-side exit?
		timeToWait += 1.90
	endIf

	StartTimer(timeToWait, ExitBedHandleTimerID)
endFunction

Function HandlePlayerActivateBed(ObjectReference targetRef, bool isNaked, bool isSpecialAnimBed)
	SleepBedUsesSpecialAnims = isSpecialAnimBed
	
	DisablePlayerControlsSleep(2)	; v1.25 changed level-2 to prevent look

	IntimateCompanionRef = None
	bool companionReady = false
	bool bedCompatible = true  	; not using
	bool undressOK = false
	bool noPreBedAnim = true
	bool undressCheck = IsUndressCheckRequested()  ; if check undress instead of sleep
	bool cancledScene = false
	bool sameLover = false
	bool dogmeatScene = false
	bool doggySafe = true
	bool sleepSafe = OkayToSleepLocationBed(targetRef)
	float bedHeight = targetRef.GetPositionZ() - PlayerRef.GetPositionZ()
	Form basebedForm = None
	int creatureType = 0
	int rIdx = -1
	int pickStyle = -1 ; chosen from menu
	float gameTime = Utility.GetCurrentGameTime()
	IntimateCompanionSet nearCompanion = new IntimateCompanionSet
	
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

	; check FarHarbor quest to clear for napping
	if ((DTSConditionals as DTSleep_Conditionals).IsCoastDLCActive && DTSleep_SettingNapOnly.GetValue() > 0)
	
		Location lastPlankLoc = (DTSConditionals as DTSleep_Conditionals).FarHarborLastPlankLocation
		Location currentLoc = (SleepPlayerAlias as DTSleep_PlayerAliasScript).CurrentLocation
		
		if (lastPlankLoc != None && lastPlankLoc == currentLoc)
			Quest rentQuest = (DTSConditionals as DTSleep_Conditionals).FarHarborBedRentQuest
			if (rentQuest != None && rentQuest.IsRunning())
				
				rentQuest.SetStage(100)
			endIf
		endIf
	endIf
	
	; ------ get companion --- 
	;
	
	
	if (DTSleep_SettingUndress.GetValue() > 0.0)
		undressOK = true
		nearCompanion = GetCompanionNearbyHighestRelationRank(true, 2)
	endIf
	
	; ------ check companion and start intimate-companion quest
		
	if (nearCompanion != None && nearCompanion.CompanionActor != None)
	
		nearCompanion.CompanionActor.AddToFaction(DTSleep_IntimateFaction)

	
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
		int readyVal = 0
		
		if (bedCompatible && PlayerIntimateCompatible())
		
			if ((gameTime - IntimateCheckLastFailTime) < 0.047)
				readyVal = -101			; too soon!
			else
				readyVal = IsCompanionActorReadyForScene(nearCompanion, false, targetRef, true)				; Ready for Scene? also updates SceneData
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
		
			if (readyVal > 0)
		
				if (nearCompanion.CompanionActor == StrongCompanionRef)
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
						DTDebug(" strong set " + nearCompanion.CompanionActor, 1)
						companionReady = true
					endIf
					
				elseIf (DTSleep_SettingIntimate.GetValue() >= 2.0 && nearCompanion.RelationRank >= 2)
					companionReady = true
					IntimateCompanionRef = nearCompanion.CompanionActor
					
				elseIf (nearCompanion.RelationRank >= 3)
					companionReady = true
				endIf
				
			endIf
		endIf
		;  ***
		
		;  *** tutorial check if intimate okay
		if (!undressCheck && DTSleep_SettingIntimate.GetValue() > 0.0 && DTSleep_SettingUndress.GetValue() > 0.0)
		
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
		if (DTSleep_BedsBigDoubleList.HasForm(baseBedForm))
			; check twin-side for occupation
			ObjectReference twinBed = DTSleep_CommonF.FindNearestAnyBedFromObject(targetRef, DTSleep_BedList, targetRef, 200.0, true)
			if (twinBed != None && twinBed.IsFurnitureInUse())
				; only sleep here - no intimacy
				companionReady = false
			endIf
		endIf
	
	elseIf (!cancledScene && !undressCheck && !SceneData.IsUsingCreature)
		; not private location
		
		int bedOwnCheck = (DTSleep_BedOwnQuestP as DTSleep_BedOwnQuestScript).CheckBedOwnership(targetRef, basebedForm, IntimateCompanionRef, currentLoc)
		
		if (bedOwnCheck < -10)
			; no intimacy, sleep only
			companionReady = false
			
		elseIf (bedOwnCheck < 0)
			cancledScene = true
		endIf
	endIf
	
	; ----------------- ready for sex? ---------------
	
	
	if (!cancledScene && !undressCheck && DTSleep_SettingIntimate.GetValue() > 0.0 && companionReady && IntimateCompanionRef != None)
	
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
			ObjectReference twinBedRef = None
			
			
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
			
			if (DTSleep_SettingDogRestrain.GetValue() > 0.0)
				
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
			
			; check available animation sets
			adultScenesAvailable = IsAdultAnimationAvailable()
			
			bool doScene = false
			
			int playerSex = DressData.PlayerGender
			if (playerSex < 0)
				playerSex = (PlayerRef.GetLeveledActorBase() as ActorBase).GetSex()
				DressData.PlayerGender = playerSex
			endIf
			
			
			if (bedHeight < 24.0 && bedHeight > -50.0) ; bed should be relatively level with player
			
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
				if (!SceneData.IsCreatureType && DTSleep_AdultContentOn.GetValue() >= 2.0 && DTSleep_SettingLover2.GetValue() >= 1.0 && !SceneData.CompanionInPowerArmor)
				
					; v2.14 - disallow AAF for power-armor-flag
					if (!IsAAFReady() || !nearCompanion.PowerArmorFlag)
						; v2.13 -- allow jealous type and reduce chance instead 
						;if (!(DTSleep_IntimateAffinityQuest as DTSleep_IntimateAffinityQuestScript).CompanionHatesIntimateOtherPublic(IntimateCompanionRef))
					
						int extraLoverReady = (DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).GetFurnitureSupportExtraActorForPacks(targetRef, basebedForm, None)
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
				if (adultScenesAvailable && !dogmeatScene && !SceneData.IsUsingCreature && !SceneData.CompanionInPowerArmor && sleepSafe)
					
					float limitLevel = 2.0
					
					if ((DTSConditionals as DTSleep_Conditionals).IsLeitoActive && DTSleep_IsLeitoActive.GetValue() >= 1.0)
						limitLevel = 7.0
					elseIf ((DTSConditionals as DTSleep_Conditionals).IsLeitoAAFActive && DTSleep_IsLeitoActive.GetValue() >= 1.0)
						limitLevel = 7.0
					elseIf ((DTSConditionals as DTSleep_Conditionals).IsSavageCabbageActive)
						limitLevel = 6.0
					elseIf ((DTSConditionals as DTSleep_Conditionals).IsAtomicLustActive && (DTSConditionals as DTSleep_Conditionals).AtomicLustVers >= 2.42)
						limitLevel = 6.0
					elseIf ((DTSConditionals as DTSleep_Conditionals).IsCrazyAnimGunActive)
						limitLevel = 6.0
					endIf
					
					if (limitLevel > 3.0)
						if (SceneData.SameGender)
							if (SceneData.MaleRoleGender == 1 && !SceneData.HasToyAvailable)
								limitLevel = 3.0
								; TODO - manual/oral animation for females
							elseIf (SceneData.MaleRoleGender == 0)
								limitLevel = 4.0
							endIf
						endIf
					endIf
					
					DTSleep_SexStyleLevel.SetValue(limitLevel)
				else
					DTSleep_SexStyleLevel.SetValue(1.0)
				endIf
				
				DTDebug(" Pick-Scene SexStyleLevel " + DTSleep_SexStyleLevel.GetValue(), 2)
				
				;---------------------- check prompt
				
				int showPromptVal = DTSleep_SettingShowIntimateCheck.GetValueInt()
				
				if (doggySafe && showPromptVal > 0)
				
					; ------------ 2nd lover prompt
					if (adultScenesAvailable && !dogmeatScene && !SceneData.IsUsingCreature)
						if (DTSleep_SettingLover2.GetValue() >= 1.0 && IntimateCompanionSecRef != None && (SceneData.SecondMaleRole != None || SceneData.SecondFemaleRole != None))
							; yes/no question
							if (DTSleep_IntimateCheckSecondLovMsg.Show() >= 1)
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
								DTDebug("no location recheck", 2)
								locCheck = false
							endIf
						endIf
					endIf
					if (locCheck)
						locHourChance = ChanceForIntimateSceneByLocationHour(targetRef, baseBedForm, IntimateCompanionRef, nearCompanion.RelationRank, gameTime)
						IntimateCheckAreaScore = locHourChance
					endIf
					
					while (checkVal >= 4)
					
						checkVal = ShowIntimatePrompt(checkVal, nearCompanion, sexAppealScore, chanceForScene.Chance, locHourChance, gameTime, dogmeatScene)
						
						if (checkVal >= 0 && checkVal <= 1)
							; player chose to persuade sex
							
							if (chanceForScene.Chance == 0)
								chanceForScene = ChanceForIntimateScene(nearCompanion, targetRef, baseBedForm, gameTime, companionGender, locHourChance, true, sexAppealScore, sameLover)
							endIf
							if (checkVal == 1)
								
								; v1.70 -- show style-pick menu - pickspot chosen from menu
								Utility.Wait(1.0)
								pickStyle = DTSleep_IntimateScenePickMessage.Show()
								
								if (pickStyle == 2)
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
								if (pickStyle <= 1)
									chanceForScene.Chance += 15
									if (chanceForScene.Chance > 100)
										chanceForScene.Chance = 100
									endIf
									
								else
									chanceForScene.Chance -= 7
									if (chanceForScene.Chance < 5)
										chanceForScene.Chance = 5
									endIf
								endIf
							elseIf (!sleepSafe && adultScenesAvailable)
								; no room on bed
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
						
					endWhile  ; end checkVal >= 3
				
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
				bool testDemoEnabled = TestIntSceneEnabled()
				
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
				
				if (DTSleep_AdultContentOn.GetValue() >= 2.0)		; v2 -- change from 1.0 to 2.0 since XOXO includes hug/kiss
					; picks animation pack
					
					animPacks = IntimateAnimPacksPick(adultScenesAvailable, nearCompanion.PowerArmorFlag, playerSex, basebedForm, pickStyle)
				endIf
				
				if (adultScenesAvailable || animPacks.Length > 0)
				
					if (chanceForScene.Chance >= randomChance)
					
						doScene = true
						
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
						
						if (pickSpotSelected && creatureType != CreatureTypeDog)
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
				
					doScene = true
					
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
					
					if (SceneData.IsUsingCreature || SceneData.CompanionInPowerArmor)
						; animPack check failed to find packs matching situation
						IntimateCompanionRef.FollowerFollow()
						IntimateCompanionRef = None
						doFade = false
					endIf
					
				elseIf (animPacks.Length > 0 && (DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).GetTimeForPlayID(1001) != 169.27)
					Debug.Trace(myScriptName + " bad anim controller found")
					useLowSceneCam = false
					SceneData.AnimationSet = 0
					animPacks = new int[0]
				endIf
				
				Utility.Wait(0.36)
				
				int undressLevel = -1
				if (doFade)
					if (DTSleep_AdultContentOn.GetValue() <= 1.0 || SceneData.AnimationSet == 0 || pickStyle == 1)
						undressLevel = 1
						; if sleeping bag and outdoors, normal clothed respect
						if (targetRef.HasKeyword(AnimFurnFloorBedAnims) && !PlayerRef.IsInInterior())
							undressLevel = 0
						endIf
					else
						undressLevel = 2
					endIf
				endIf
				; ----------
				; sets up the scene player, companion preferences, clears 2nd lovers if not needed, and also undress if ready
				;
				sequenceID = SetUndressAndFadeForIntimateScene(IntimateCompanionRef, targetRef, undressLevel, playerPositioned, playSlowMo, dogmeatScene, useLowSceneCam, animPacks, isNaked, twinBedRef, pickStyle)
				; ---------------
				
				bool sleepTime = (DTSleep_HealthRecoverQuestP as DTSleep_HealthRecoverQuestScript).IsSleepTimePublic(gameTime)
				bool playerNakedOrPJ = isNaked
				
				if (sleepTime)
					if (!isNaked)
						playerNakedOrPJ = (DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).IsUndressAll
					endIf
					if (!playerNakedOrPJ)
						if ((DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).UndressedForType == 3)
							playerNakedOrPJ = true
							
						elseIf (DTSleep_SettingNapOnly.GetValue() > 0.0&& DTSleep_SettingFadeEndScene.GetValue() >= 1.0)
							; only bother checking if need to know to save time
							playerNakedOrPJ = (DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).IsActorWearingSleepwear(PlayerRef)
						endIf
					endIf
				endIf
				
				if (sleepTime && playerNakedOrPJ && DTSleep_SettingNapOnly.GetValue() > 0.0 && DTSleep_SettingFadeEndScene.GetValue() >= 1.0)
					if (SceneData.AnimationSet < 5 || !IsAAFReady())
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
				
				if ((DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).PlayActionIntimateSeq(sequenceID))
					noPreBedAnim = false
					RegisterForRemoteEvent(targetRef, "OnActivate")			; watch for NPC activate
					RegisterForCustomEvent((DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript), "IntimateSequenceDoneEvent")
					SetStartSpectators(targetRef)
					
				elseIf (!SceneData.IsUsingCreature && (DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).PlayActionXOXO())
					noPreBedAnim = false
					RegisterForCustomEvent((DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript), "IntimateSequenceDoneEvent")
					
				elseIf (SceneData.CompanionInPowerArmor && (DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).PlayActionDancing())
					noPreBedAnim = false
					RegisterForCustomEvent((DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript), "IntimateSequenceDoneEvent")
					
				else
					noPreBedAnim = true
					
					(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).StopAll()
					FadeInFast(false)
				endIf
				
			elseIf (doScene && SceneData.AnimationSet == 0)
			
				if (!IntimateCompanionRef.WornHasKeyword(ArmorTypePower) && (DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).PlayActionXOXO())
					noPreBedAnim = false
					RegisterForCustomEvent((DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript), "IntimateSequenceDoneEvent")
					SetStartSpectators(targetRef)
						
				elseIf ((DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).PlayActionDancing())
					noPreBedAnim = false
					(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).PlaceInBedOnFinish = false
					RegisterForCustomEvent((DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript), "IntimateSequenceDoneEvent")

				else
					noPreBedAnim = true
					
					(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).StopAll()
					FadeInFast(false)
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
			if (SceneData.AnimationSet >= 5 && aafPlay && DTSleep_SettingTestMode.GetValue() >= 1.0)
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
			
		if (IntimateCompanionRef == StrongCompanionRef || dogmeatScene || nearCompanion.RelationRank <= 2 || IntimateCompanionRef.WornHasKeyword(ArmorTypePower))
		
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
		
		EnablePlayerControlsSleep()
		
		; record for future sleepy checks
		(DTSleep_HealthRecoverQuestP as DTSleep_HealthRecoverQuestScript).LastSleepCheckTime = gameTime
		
		ActivatePlayerSleepForBed(targetRef, isSpecialAnimBed, isNaked)

	endIf
EndFunction

Function HandlePlayerActivateOutfitContainer(ObjectReference akTarget, bool forBed = false)
	
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
		GoThirdPerson()
		Utility.Wait(0.42)
		float timeToWait = 1.76
		
		if (undressCheck)
			if (DTSleep_PlayerUndressed.GetValue() <= 0.0)
				
				SetUndressForCheck(true, None)

			endIf
		else
			(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).AltFemBodyEnabled = false
			;   clothing, no companion, no winter, no companion nudeSuit, no bed, no Pip-boy, no drop sleepwear, carryBonus
			SetUndressForManualStop(true, None, false, false, None, false, false, forBed)  
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

; specialFurn: <0 = any chair, 1 = pillory, 2 = chair supporting sex, 3 = desk, 4 = PA Repair station
;
Function HandlePlayerActivateFurniture(ObjectReference akFurniture, int specialFurn)

	IntimateCompanionRef = None
	Form furnBaseForm = None
	;ObjectReference akPillory = None
	ObjectReference tableObjRef = None
	ObjectReference furnToPlayObj = akFurniture
	bool companionReady = false
	bool cancledScene = false
	bool noPreBedAnim = true
	bool doFade = true
	bool sameLover = false
	bool testPassEnabled = false
	bool hugsOnly = false
	bool showPrompt = true
	bool isPillory = false
	bool pickSpot = false
	bool pickedOtherFurniture = false
	bool doDance = false
	bool recheckFurnUse = false
	bool chairActuallyInUse = false
	int rIdx = -1
	int readyVal = 0
	float gameTime = Utility.GetCurrentGameTime()
	float daysSinceLastIntimate = gameTime - IntimateLastTime
	float daysSinceLastEmbraceScore = gameTime - IntimateLastEmbraceScoreTime
	float daysSinceFail = gameTime - IntimateCheckLastFailTime
	float hoursSinceLastFail = DTSleep_CommonF.GetGameTimeHoursDifference(gameTime, IntimateCheckLastFailTime)
	IntimateCompanionSet nearCompanion = new IntimateCompanionSet
	int[] animPacks = new int[1]
	
	if (specialFurn == 1)
		isPillory = true
	endIf
	
	if (PlayerRef.WornHasKeyword(ArmorTypePower))
		pPowerArmorNoActivate.Show()
		return
		
	elseIf ((DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).GetTimeForPlayID(1001) != 169.27)
		Debug.Trace(myScriptName + " bad anim controller found")
		return
	endIf
	
	if (akFurniture.IsFurnitureInUse())
	
		if (isPillory || specialFurn > 2)
			if (DTSleep_SettingNotifications.GetValue() > 0.0)
				DTSleep_PilloryBusyMessage.Show()
			endIf
			
			return

		elseIf (IsFurnitureActuallyInUse(akFurniture, true))
			; is true-love partner using chair?
			bool okayToGo = false
			chairActuallyInUse = true
			
			if ((DTSConditionals as DTSleep_Conditionals).LoverRingEquipCount > 0)
				if (DTSleep_TrueLoveAlias != None)
					Actor loverActor = DTSleep_TrueLoveAlias.GetActorReference()
					if (loverActor != None && loverActor.GetItemCount(DTSleep_ArmorLoverRing) > 0 && loverActor.GetDistance(PlayerRef) < 200.0)
						if (DTSleep_CommonF.IsActorOnBed(loverActor, akFurniture))
							okayToGo = true
						endIf
					endIf
				endIf
			endIf
			if (!okayToGo)
				bool okayToSit = OkaySitOnSeat(akFurniture)
					
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
	
	if (daysSinceFail < 0.047)
		
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
	
	; resets
	SceneData.SecondFemaleRole = None
	SceneData.SecondMaleRole = None
	DTSleep_SexStyleLevel.SetValue(0.0)
	
	; extras available? - set sexStyle level for menu
	if (specialFurn == 2)
		; search for nearby tables
		FormList searchlist = (DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).DTSleep_IntimatePoolTableList
		tableObjRef = DTSleep_CommonF.FindNearestObjectInListFromObjRef(searchlist, akFurniture, 600.0)
		
		if (tableObjRef != None)
			DTSleep_SexStyleLevel.SetValue(2.0)
		else
			searchlist = CombinedTableFormList()
			tableObjRef = DTSleep_CommonF.FindNearestObjectInListFromObjRef(searchlist, akFurniture, 350.0)
			if (tableObjRef != None)
				DTSleep_SexStyleLevel.SetValue(1.0)
			endIf
		endIf
	endIf

	
	if (DTSleep_AdultContentOn.GetValue() <= 1.0 || TestVersion == -3 || (DTSConditionals as DTSleep_Conditionals).ImaPCMod == false)
		hugsOnly = true
		animPacks[0] = 0
		
	elseIf (isPillory && akFurniture.HasKeyword((DTSConditionals as DTSleep_Conditionals).ZaZPilloryKW))
		if ((DTSConditionals as DTSleep_Conditionals).ImaPCMod)
			animPacks[0] = 8
		endIf
	elseIf (specialFurn == 4)
		if ((DTSConditionals as DTSleep_Conditionals).IsAtomicLustActive)
			animPacks[0] = 5
		else
			hugsOnly = true
			animPacks[0] = 0
		endIf
		
	elseIf (specialFurn > 0 && (DTSConditionals as DTSleep_Conditionals).IsSavageCabbageActive)
		animPacks[0] = 7
		if (specialFurn == 2 && (DTSConditionals as DTSleep_Conditionals).IsAtomicLustActive)
			animPacks.Add(5)
		endIf
	else
		hugsOnly = true
		;v2.10 - just use internal hugs
		;if (IsAAFReady() && (DTSConditionals as DTSleep_Conditionals).IsAtomicLustActive)
		;	animPacks[0] = 5
		;else
			animPacks[0] = 0
		;endIf
	endIf
	
	DisablePlayerControlsSleep(2)	; prevent look
	
	; ------ get companion --- 
	;
	int minRank = 3
	int genderPref = -2
	if (DTSleep_SettingIntimate.GetValue() >= 2.0)
		minRank = 2
	endIf
	if (isPillory || specialFurn >= 3)
		; force pillory, desk, and sometimes PA to opposite gender for search
		int playerGender = (DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).GetGenderForActor(PlayerRef)
		if (playerGender == 1)
			if (specialFurn != 4)		; allow FF
				genderPref = 0
			endIf
		else
			genderPref = 1
		endIf
	endIf
	nearCompanion = GetCompanionNearbyHighestRelationRank(true, minRank, genderPref)
	
	; ------ check companion 
	; 
	bool companionCompatible = false
	
	if (nearCompanion != None && nearCompanion.CompanionActor != None)
	
		if (hugsOnly)
			if (!isPillory)
				if (nearCompanion.CompanionActor == StrongCompanionRef)
					companionCompatible = false
				else
					companionCompatible = true
				endIf
			endIf
			
		elseIf (nearCompanion.CompanionActor == StrongCompanionRef)
			if (!isPillory && specialFurn != 4)
				companionCompatible = true
				
				if (DTSleep_AdultContentOn.GetValue() >= 2.0 && (DTSConditionals as DTSleep_Conditionals).ImaPCMod && TestVersion == -2)
					if (animPacks[0] == 7)
						pickSpot = true
						
					elseIf ((DTSConditionals as DTSleep_Conditionals).IsLeitoAAFActive)
						animPacks[0] = 6
						pickSpot = true
					elseIf ((DTSConditionals as DTSleep_Conditionals).IsLeitoActive)
						animPacks[0] = 1
						pickSpot = true
					else
						animPacks[0] = 0
						hugsOnly = true
						doDance = true
					endIf
				else
					companionCompatible = false
				endIf
			endIf
		else
			companionCompatible = true
		endIf
	endIf
	
	if (companionCompatible)
	
		if (nearCompanion.Gender < 0)
			nearCompanion.Gender = (DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).GetGenderForActor(nearCompanion.CompanionActor)
		endIf
		nearCompanion.CompanionActor.AddToFaction(DTSleep_IntimateFaction)

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
		
		DTDebug(" furniture activate check nearCompanion " + nearCompanion.CompanionActor + " gender = " + nearCompanion.Gender, 1)

		;  ***** verify companion is ready and update SceneData
		;
			
		readyVal = IsCompanionActorReadyForScene(nearCompanion, false, None)			; also updates scene-data
		
		DTSleep_CompIntimateQuest.Start()
		DTSleep_OtherFurnitureRefAlias.ForceRefTo(akFurniture)
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
		
		if (readyVal > 0)
			companionReady = true
			IntimateCompanionRef = nearCompanion.CompanionActor
			
			if (SceneData.IsUsingCreature)
				if (isPillory)
					companionReady = false
					IntimateCompanionRef = None
					
				elseIf (SceneData.IsCreatureType == CreatureTypeSynth)
					hugsOnly = true
					animPacks[0] = 0
				endIf
				
			elseIf (SceneData.SameGender)
				; TODO: check here for new animationpacks supporting chairs FMF or same-gender
				if (isPillory)
					companionReady = false
					IntimateCompanionRef = None
				elseIf (specialFurn == 4)
					if (nearCompanion.Gender == 0)
						hugsOnly = true
						animPacks[0] = 0
					endIf
				else
					hugsOnly = true
					animPacks[0] = 0
				endIf
			endIf
		endIf 
	endIf
	
	SceneData.CompanionBribeType = -1
	bool furnObjReady = true
	if (recheckFurnUse && IsFurnitureActuallyInUse(akFurniture, true))
		
		furnObjReady = false
	endIf
	
	if (companionReady && IntimateCompanionRef != None && furnObjReady)
	
		int companionGender = -1
		testPassEnabled = TestIntSceneEnabled()

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
		
		if (DTSleep_SettingDogRestrain.GetValue() > 0.0)

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
		if (!hugsOnly && !doDance && specialFurn != 4 && !SceneData.IsCreatureType && DTSleep_AdultContentOn.GetValue() >= 2.0 && DTSleep_SettingLover2.GetValue() >= 1.0)
			if (!isPillory || animPacks[0] == 7)
				; v2.13 - allow jealous type and reduce chance instead 
				;if (!(DTSleep_IntimateAffinityQuest as DTSleep_IntimateAffinityQuestScript).CompanionHatesIntimateOtherPublic(IntimateCompanionRef))
			
					int extraLoverReady = (DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).GetFurnitureSupportExtraActorForPacks(furnToPlayObj, None, animPacks)
					DTDebug("extraLoverReady " + extraLoverReady + " for furniture " + furnToPlayObj, 2)
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
						endIf
					endIf
				;endIf
			endIf
		endIf
		; ------------------------end partner set
		
		
		bool dogSafe = true ;IsSceneDogmeatSafe(furnToPlayObj)
		
		if (doDance)
			chanceForScene.Chance = 100
			
		; ----------------------------------------------------------------- show prompt 
		elseIf (showPromptVal > 0 && (dogSafe || hugsOnly))
			; prompt for hugs/sex
			
			; check 2nd lover prompt
			
			if (DTSleep_SettingLover2.GetValue() >= 1.0 && IntimateCompanionSecRef != None && (SceneData.SecondMaleRole != None || SceneData.SecondFemaleRole != None))
				; yes/no question
				if (DTSleep_IntimateCheckSecondLovMsg.Show() >= 1)
					; no extra - remove 2nd lover
					SceneData.SecondMaleRole = None
					SceneData.SecondFemaleRole = None
					ClearIntimateSecondCompanion()
				endIf
				Utility.Wait(0.85)
			endIf
			
			sexAppealScore = PlayerSexAppeal(false, companionGender, 0)
			int checkVal = 10
			
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
			
			if (checkLoc)
				locHourChance = ChanceForIntimateSceneByLocationHour(akFurniture, furnBaseForm, IntimateCompanionRef, nearCompanion.RelationRank, gameTime, hugsOnly)
				; record in case we repeat check after sit/cancel - NPCs don't matter for hugs
				IntimateCheckAreaScore = locHourChance
			endIf
			
			while (checkVal >= 2)
			
				if (hugsOnly)
					if (checkVal == 2)
						; reveal chance score
						checkVal = DTSleep_IntimateCheckHugsChanceMsg.Show(sexAppealScore, chanceForScene.Chance)
					elseIf (checkVal == 3)
						; chose dance
						checkVal = 0
						doDance = true
						animPacks[0] = 0
					else
						
						float hoursSinceLastIntimate = DTSleep_CommonF.GetGameTimeHoursDifference(gameTime, IntimateLastTime)
						float hoursSinceLastEmbrace = DTSleep_CommonF.GetGameTimeHoursDifference(gameTime, IntimateLastEmbraceTime)
						
						if (hoursSinceLastFail > 20.0 && hoursSinceLastIntimate > 20.0 && hoursSinceLastEmbrace > 20.0)
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
					
				elseIf (specialFurn == 4)
					checkVal = ShowPAStationPrompt(checkVal, nearCompanion, sexAppealScore, chanceForScene.Chance, locHourChance, gameTime)
					
				elseIf (specialFurn == 3)
					checkVal = ShowDeskPrompt(checkVal, nearCompanion, sexAppealScore, chanceForScene.Chance, locHourChance, gameTime)
					
				elseIf (isPillory)
					checkVal = ShowPilloryPrompt(checkVal, nearCompanion, sexAppealScore, chanceForScene.Chance, locHourChance, gameTime)
				
				else
					checkVal = ShowChairPrompt(checkVal, nearCompanion, sexAppealScore, chanceForScene.Chance, locHourChance, gameTime)
					
					if (checkVal == 3)
						; chose dance
						checkVal = 0
						doDance = true
						animPacks[0] = 0
						hugsOnly = true
						pickSpot = false
						
					elseIf (checkVal >= 4)
						; picked a table
						checkVal = 0
						if (tableObjRef != None)
							furnToPlayObj = tableObjRef
						endIf
						pickSpot = false
						pickedOtherFurniture = true
						DTSleep_OtherFurnitureRefAlias.ForceRefTo(tableObjRef)
					endIf
				endIf
				
				if (checkVal == 0)
					; player chose to attempt sex/hug
					
					if (chanceForScene.Chance == 0)
						chanceForScene = ChanceForIntimateScene(nearCompanion, akFurniture, furnBaseForm, gameTime, companionGender, locHourChance, true, sexAppealScore, sameLover, false, hugsOnly)
						
						if (hugsOnly)
							chanceForScene.Chance = ChanceForHugSceneAdjChair(chanceForScene.Chance, nearCompanion.RelationRank)
						else
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
					chanceForScene = ChanceForIntimateScene(nearCompanion, akFurniture, furnBaseForm, gameTime, companionGender, locHourChance, true, sexAppealScore, sameLover, false, hugsOnly)
					
					if (hugsOnly)
						chanceForScene.Chance = ChanceForHugSceneAdjChair(chanceForScene.Chance, nearCompanion.RelationRank)
					else
						chanceForScene.Chance = ChanceForIntimateSceneAdjChair(chanceForScene.Chance)
					endIf
				endIf
				
			endWhile  ; end prompt checkVal >= 2
			
		elseIf (!dogSafe && !hugsOnly)
			; --------------------------------------------------------------- no prompt, but un-safe! cancel!
			SceneData.AnimationSet = -3
			chanceForScene.Chance = -8		; force fail
			cancledScene = true
			; TODO: what other message ????
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
				else
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
		
		if (doDance)
			if (IntimateCompanionRef != None && IntimateCompanionRef.GetSitState() >= 2)
				; no dance for seated companion
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
		
			; -------- speak and notify ------------------------------
			EnablePlayerControlsSleep()
			DisablePlayerControlsSleep(0)	;v1.46 - enable move-control to show HUD notifications

			
			if (testPassEnabled && !doDance)
				IntimacyTestCount += 1
			elseIf (!doDance)
				PlayerRef.SayCustom(PlayerLockResultSubtype, None, randomChance > 50) ; speak in head if rand > 50
				
				if (hugsOnly)
					if (hoursSinceLastFail < 12.0)
						IntimateCheckLastFailTime -= 12.0	; set-back fail-time to avoid penalize bed intimacy
					endIf
					if (IntimateCheckFailCount > 0)
						; hugs reduce fails
						IntimateCheckFailCount -= 1
					endIf
					IntimateLastEmbraceTime = gameTime	 	; always record time
					
					self.MessageOnRestID = IntimateEmbracePerkTimerID
				else
					; set intimate progress for sex
					SetProgressIntimacy(sexAppealScore, 0, rIdx, locHourChance.NearActors)
				endIf
			endIf
			
			SetAffinityForCreature(SceneData.IsCreatureType)
			
			if (luckRoll && DTSleep_SettingNotifications.GetValueInt() > 0)

				DTSleep_LuckyMessage.Show()
				Utility.Wait(0.5)
			endIf
			
			if (doDance) ;|| (hugsOnly && animPacks[0] == 5))
				doFade = false
			endIf
			
			if (pickSpot)
				PlayPickSpotTimer()
			elseIf (pickedOtherFurniture)
				PlayPickSpotTimer(1)
			elseIf (animPacks[0] >= 7 && !IsAAFReady() && PlayerRef.GetDistance(akFurniture) < 90.0)
				; step back
				PlayPickSpotTimer(2)
			endIf
			
			if (!doDance)
				Utility.Wait(0.36)
				
				if (PlayerRef.IsInCombat() || IntimateCompanionRef.IsInCombat() || IntimateCompanionRef.IsWeaponDrawn())
					cancledScene = true
					
					PlayerRef.SayCustom(PlayerHackFailSubtype, None)
				endIf
			endIf
			
			if (!cancledScene)
				; sets up the scene player, companion preferences, and also undress if ready
				
				if (doDance)
					(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).StartForActorsAndBed(PlayerRef, IntimateCompanionRef, furnToPlayObj, false, true, false)
					
					MainQSceneScriptP.GoSceneViewStart(-1)
				
					if ((DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).PlayActionDancing())
					
						noPreBedAnim = false
						RegisterForCustomEvent((DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript), "IntimateSequenceDoneEvent")
						
					endIf
				else
					int sequenceID = 99
					int undressLevel = 0
					if (doFade && !hugsOnly)
						undressLevel = 2
					elseIf (!doFade)
						undressLevel = -1
					endIf
					if (animPacks[0] <= 0)
						animPacks = None
					endIf
				
					sequenceID = SetUndressAndFadeForIntimateScene(IntimateCompanionRef, furnToPlayObj, undressLevel, pickSpot, false, false, false, animPacks, false, None)

					
					(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).PlaceInBedOnFinish = false
					
					if (sequenceID >= 100 && SceneData.AnimationSet > 0)
					
						if ((DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).PlayActionIntimateSeq(sequenceID))
							noPreBedAnim = false
							RegisterForRemoteEvent(furnToPlayObj, "OnActivate")			; watch for NPC activate
							RegisterForCustomEvent((DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript), "IntimateSequenceDoneEvent")
							if (specialFurn < 4)
								; spectators ignore radius on PA station so skip
								SetStartSpectators(furnToPlayObj)
							endIf
						else
							noPreBedAnim = true
							
							(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).StopAll()
							FadeInFast(false)
						endIf
						
					elseIf (Utility.RandomInt(5, 16) > 8 && (DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).PlayActionHugs())
						noPreBedAnim = false
						RegisterForCustomEvent((DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript), "IntimateSequenceDoneEvent")
						
					elseIf ((DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).PlayActionXOXO())
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
				if (!hugsOnly && SceneData.AnimationSet >= 5 && IsAAFReady() && DTSleep_SettingTestMode.GetValue() > 0.0)
					DisablePlayerControlsSleep(3)
				else
					DisablePlayerControlsSleep(1)  ; no move
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
			
			if (!isPillory && specialFurn < 3)
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
		
	elseIf (!furnObjReady)
		EnablePlayerControlsSleep()
		WakeStopIntimQuest(true)
		IntimateCompanionRef = None
		
		if (specialFurn < 3 && OkaySitOnSeat(akFurniture, furnBaseForm))
			SetUndressForRespectSit(akFurniture)
				
		elseIf (DTSleep_SettingNotifications.GetValue() > 0.0)
			DTSleep_PilloryBusyMessage.Show()
		endIf
	else
		; no companion ready
		EnablePlayerControlsSleep()
		
		if (isPillory || specialFurn >= 3)
			if (DTSleep_SettingWarnLoverBusy.GetValue() > 0.0)
				DTSleep_PersuadePilloryNoneMsg.Show()
			endIf
		elseIf (DTSleep_SettingWarnLoverBusy.GetValue() > 0.0)
			
			if (DTSleep_CompIntimateQuest.IsRunning())
				; companion found, but not available for scene
				
				if (readyVal >= -1)
					if (DTSleep_SettingShowIntimateCheck.GetValue() > 0.0 && PlayerHasActiveCompanion.GetValueInt() >= 1)
						int chk = DTSleep_ChairCheckNoCompMessage.Show()
						if (chk == 1)
							SetUndressForRespectSit(akFurniture)
						elseIf (chk == 2)
						
							(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).StartForActorsAndBed(PlayerRef, None, akFurniture, false, true, false)
						
							MainQSceneScriptP.GoSceneViewStart(-1)
							
							if ((DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).PlayActionDancing())
	
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
	DTDebug("  sleep started in bed " + akBed + ", hours: " + desiredSleepTime + ", canUndress: " + IsUndressReady, 1)

EndFunction


Function HandlePlayerSleepStop(ObjectReference akBed, bool observeWinter = false, bool isFadedOut = false, bool moveToBed = true, bool afterIntimacy = false, bool playerNaked = false)
	bool isBedBusy = false
	int napComp = DTSleep_SettingNapComp.GetValueInt()
	int napOnly = DTSleep_SettingNapOnly.GetValueInt()
	
	if (DTSleep_PlayerUndressed.GetValueInt() <= 0)
		; dressed - clear second
		if (IntimateCompanionSecRef != None)
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

	if (DTSleep_PlayerUsingBed.GetValue() <= 0.0 || akBed == None)
		DTDebug("Handle SleepStop: player not using bed - assumed canceled", 1)

		SleepBedInUseRef = None    	; should be None
		SleepBedRegistered = None
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
				
				if (IntimateCompanionRef != None)
					
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
								
								DTDebug(" companion sleeping, mark bed " + aBed, 2)
								SleepBedCompanionUseRef = aBed
							endIf
							if (!IntimateCompanionRef.IsInFaction(DTSleep_IntimateFaction))
								IntimateCompanionRef.AddToFaction(DTSleep_IntimateFaction)
							endIf
							DTDebug(" start CompSleepQuest for companion already sleeping...", 2)
							DTSleep_CompSleepQuest.Start()
							if (DTSleep_CompBedRestAlias != None)
								if (SleepBedCompanionUseRef != None)
									DTSleep_CompBedRestAlias.ForceRefTo(SleepBedCompanionUseRef)
								endIf
							endIf
						endIf
					endIf
				endIf
				
			elseIf (napOnly <= 0 && IntimateCompanionRef != None && !IntimateCompanionRef.WornHasKeyword(ArmorTypePower))
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
			
			if (napComp > 0 && !DTSleep_CompSleepQuest.IsRunning() && DogmeatCompanionAlias != None)
		
				; start sleep quest
				DTDebug(" start CompSleepQuest for Dogmeat...", 2)
				
				DTSleep_CompSleepQuest.Start()
				Utility.Wait(0.24)
			endIf
			
			; does companion need to go to bed?
			;
			if (napOnly && napComp > 0 && IntimateCompanionRef != None && !IntimateCompanionRef.WornHasKeyword(ArmorTypePower) && DTSleep_CompSleepQuest.IsRunning() && SleepBedCompanionUseRef == None)
				
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
						DTDebug(" setting aBedRef to SleepBedCompanionBed: " + aBedRef, 1)
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
							
							if (IntimateCompanionSecRef == None)
								; v2.14 - changed to handle after intimacy so we don't break existing undressed companion
								;  find then clear if not needed
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
						IntimateCompanionRef = None
					endIf
				else
					; should not happen 
					DTDebug(" no CompanionSleep Alias - no sleep or undress ", 1)
					self.MessageOnRestID = OnRestMsgCompBedNotFound
					; no bed, no undress
					IntimateCompanionRef = None
					IntimateCompanionSecRef = None
					IntimateCompanionRef.EvaluatePackage(false)
				endIf
			elseIf (SleepBedCompanionUseRef == None)
				; cancel companion undress since not going to bed
				IntimateCompanionRef = None
				IntimateCompanionSecRef = None
			endIf
			
			; check Dogmeat
			if (napComp > 0 && DTSleep_CompSleepQuest.IsRunning() && DTSleep_DogSleepAlias != None)
				bool dogSleepFound = false
				
				if (DTSleep_SettingDogRestrain.GetValue() >= 0.0 && DogmeatSetWait && DogmeatCompanionAlias != None)
					SetDogmeatFollow()
				endIf
				if (DTSleep_CompDogBedRefAlias != None)
					Actor dogActor = DTSleep_DogSleepAlias.GetActorReference()
					ObjectReference dogBedRef = DTSleep_CompDogBedRefAlias.GetReference()
					if (dogActor != None && dogBedRef != None)
					
						if (dogActor.GetSleepState() > 2)
							dogSleeping = true
							DTSleep_CompDogBedRefAlias.Clear()
							DTSleep_DogSleepAlias.Clear()
							
						elseIf (dogBedRef.GetDistance(dogActor) > 3000.0 || dogBedRef.IsFurnitureInUse())
						
							; the alias closest-to Ref in loaded area sometimes finds doghouse farther away than another
							
							ObjectReference dogSleepNearRef = DTSleep_CommonF.FindNearestObjHaveKeywordFromObject(PlayerRef, DTSleep_DogSleepKWList, 3200.0)
							if (dogSleepNearRef != None)
								DTSleep_CompDogBedRefAlias.ForceRefTo(dogSleepNearRef)
								dogSleeping = true
								DTDebug("send Dogmeat to near bed at " + dogSleepNearRef, 2)
								dogActor.EvaluatePackage(false)
								dogSleepFound = true
							else
								; too far
								;DTSleep_DogSleepAlias.Clear()
								DTSleep_CompDogBedRefAlias.Clear()
								DTDebug("Dogmeat bed too far " + dogBedRef, 2)
							endIf
						else
							dogSleeping = true
							DTDebug("send Dogmeat to bed at " + dogBedRef, 2)
							dogActor.EvaluatePackage(false)
							dogSleepFound = true
						endIf
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
			endIf      ; end check Dogmeat sleep
		
		endIf
		
		if (!DTSleep_HealthRecoverQuestP.IsRunning())
			DTSleep_HealthRecoverQuestP.Start()
		endIf
		
		RegisterForCustomEvent((DTSleep_HealthRecoverQuestP as DTSleep_HealthRecoverQuestScript), "RestInterruptionEvent")
		
		if (SleepBedInUseRef != None)
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
			elseIf (IsBedOwnedByPlayer(SleepBedInUseRef, IntimateCompanionRef))

				(DTSleep_HealthRecoverQuestP as DTSleep_HealthRecoverQuestScript).SetBedTypeOwn()
				(DTSleep_HealthRecoverQuestP as DTSleep_HealthRecoverQuestScript).HoursOversleep = 8
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
		
		Game.ForceThirdPerson()
		Utility.Wait(0.5)
		EnablePlayerControlsSleep()
		Utility.Wait(0.1)
		SetUndressForCheck(includeClothing, companionActor, companionRequiresNudeSuit)

	else
		
		DTSleep_CaptureExtraPartsEnable.SetValue(0.0)
		
		Game.ForceThirdPerson()
		Utility.Wait(0.1)
		
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
		
		if (!silent)
			if (IsAdultAnimationAvailable())
				DTSleep_StartedExplicitMessage.Show()
			elseIf (DTSleep_AdultContentOn.GetValue() == 1.0)
				DTSleep_StartedSafeMessage.Show()
			else
				DTSleep_StartedMessage.Show()
			endIf
		endIf
		
		; process whatever StartUp found
		ProcessCompatibleMods()
	else
		; uh-oh something went wrong
		Game.QuitToMainMenu()
	endIf
EndFunction

;
; sets SceneData.AnimationSet and returns if should do stand-only scene
; all of SceneData should be set first
;
int[] Function IntimateAnimPacksPick(bool adultScenesAvailable, bool powerArmorFlag, int playerSex, Form baseBedForm, bool hasTwinBed = false, int stylePicked = -1)

	; SceneData.AnimationSet: 5+ for AAF, 
	;   1 = original Leito (positioned 70 apart)
	;   2 = Crazy Gun
	;   5 = Atomic Lust & Mutated Lust
	;   6 = Leito v2
	;   7 = SavageCabbages
	;	8 = ZaZOut4
	;   9 = AAF_GrayAnimations

	bool aafEnabled = IsAAFReady()
	bool hasAtomicLustAnims = false
	bool hasMutatedLustAnims = false
	bool hasCrazyGunAnims = false
	bool hasLeitoAnims = false
	bool hasSavageCabbageAnims = false
	bool hasGrayAnims = false
	bool hasLeitoV2Anims = false	; compatible with AAF, but cannot have old X_Anims patch due to shared file locations
	int animSetCount = 0
	int animSetFailCount = 0
	int multiLoverGender = -1
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
	
	; non-adult packs or packs including clothed animations
	if ((DTSConditionals as DTSleep_Conditionals).IsAtomicLustActive)
		if (powerArmorFlag && aafEnabled)
			animSetFailCount += 1
		else
			hasAtomicLustAnims = true		; Danse in power armor allowed for solo-female
			animSetCount += 1
		endIf
	endIf
	
	if (adultScenesAvailable)
	
		DTDebug("IntimateAnimPacksPick powerArmorFlag?" + powerArmorFlag + " inPowerArmor? " + SceneData.CompanionInPowerArmor + " stylePicked? " + stylePicked, 2)
		
		if (SceneData.CompanionInPowerArmor)
			; intended for Danse in power armor
			if (playerSex == 1 && !aafEnabled && (DTSConditionals as DTSleep_Conditionals).IsSavageCabbageActive && DTSleep_BedsBigDoubleList.HasForm(baseBedForm))
				; solo for Danse in PA limited to scene
				hasSavageCabbageAnims = true
				animSetCount += 1
			endIf
			if ((DTSConditionals as DTSleep_Conditionals).IsGrayAnimsActive)
				hasGrayAnims = true
				animSetCount += 1
			endIf
			if ((DTSConditionals as DTSleep_Conditionals).IsCrazyAnimGunActive)
				hasCrazyGunAnims = true
				animSetCount += 1
			endIf
		else
			; no power armor
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
		
			; AAF fails if power armor bug - restrict by powerArmorFlag
			
			if ((DTSConditionals as DTSleep_Conditionals).IsLeitoAAFActive)
				if (aafEnabled && powerArmorFlag)
					animSetFailCount += 1
				else
					if ((DTSConditionals as DTSleep_Conditionals).IsLeitoActive)
						; old loose files clash with new - must have new X_Anims patch
						if (DTSleep_IsLeitoActive.GetValueInt() >= 4 || aafEnabled || (SleepPlayerAlias as DTSleep_PlayerAliasScript).DTSleep_SIXPatch.GetValueInt() <= 0)
							hasLeitoV2Anims = true
							animSetCount += 1
						endIf
					else
						hasLeitoV2Anims = true
						animSetCount += 1
					endIf
				endIf
			endIf
			
			; savageCabbage scenes favor female player
			if (playerSex == 1 || (!hasLeitoAnims && !hasLeitoV2Anims) || Utility.RandomInt(1,5) > 3)
				if ((DTSConditionals as DTSleep_Conditionals).IsSavageCabbageActive && !DTSleep_BedsLimitedSpaceLst.HasForm(basebedForm))
					if (SceneData.SameGender == false || SceneData.MaleRoleGender == 1)
						if (aafEnabled && powerArmorFlag)
							animSetFailCount += 1
						else
							hasSavageCabbageAnims = true
							animSetCount += 1
							if (DressData.PlayerGender == 1)
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
	
		if (IntimateCompanionRef == StrongCompanionRef)
			if (hasSavageCabbageAnims)
				
				if (baseBedForm.HasKeyword(AnimFurnFloorBedAnims))
					animSets.Add(7)
					
				elseIf (DTSleep_BedsBigDoubleList.HasForm(baseBedForm))
					animSets.Add(7)

				endIf
			endIf
			if (baseBedForm.HasKeyword(AnimFurnFloorBedAnims))
				if (hasLeitoAnims)
					animSets.Add(1)
				elseIf (hasLeitoV2Anims)
					animSets.Add(6)
				endIf
			endIf
			
			if ((DTSConditionals as DTSleep_Conditionals).IsMutatedLustActive)
				animSetCount += 1
				animSets.Add(5)
			endIf
			SceneData.PreferStandOnly = true
			
			if (animSetCount == 0)
				SceneData.AnimationSet = 0
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
			if (hasSavageCabbageAnims)
				animSets.Add(7)
			endIf
			if (hasGrayAnims)
				animSets.Add(9)
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
			
			if (hasGrayAnims)
				animSets.Add(9)
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
				
			if (playerSex == 1 && SceneData.MaleRole == PlayerRef && DTSleep_BedsLimitedSpaceLst.HasForm(basebedForm))
				SceneData.PreferStandOnly = true
				
			elseIf (DTSleep_BedsLimitedSpaceLst.HasForm(basebedForm) && Utility.RandomInt(0, 3) > 0)
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
				if (hasCrazyGunAnims)
					animSets[index] = 2
					index += 1
				endIf
				if (hasLeitoAnims)
					animSets[index] = 1
					index += 1
				endIf
				if (hasLeitoV2Anims)
					animSets[index] = 6
					index += 1
				endIf
				if (hasSavageCabbageAnims)
					animSets[index] = 7
					index += 1
				endIf
				if (hasGrayAnims)
					animSets[index] = 9
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
	
	if (stylePicked >= 0 && stylePicked <= 1 && !hasAtomicLustAnims)
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
	
	if (DTSleep_SettingAAF.GetValue() > 0.0 && (DTSConditionals as DTSleep_Conditionals).IsF4SE)
		if ((DTSConditionals as DTSleep_Conditionals).IsAAFActive)
			return true
		endIf
	endIf

	return false
endFunction

bool Function IsAdultAnimationAvailable()

	if (DTSleep_AdultContentOn.GetValue() >= 2.0 && (DTSConditionals as DTSleep_Conditionals).ImaPCMod)
	
		float leitoVal = DTSleep_IsLeitoActive.GetValue()
		if ((DTSConditionals as DTSleep_Conditionals).IsLeitoActive && leitoVal > 0.0 && leitoVal <= 4.0)
			
			return true
		elseIf ((DTSConditionals as DTSleep_Conditionals).IsCrazyAnimGunActive)
			return true
		
		elseIf ((DTSConditionals as DTSleep_Conditionals).IsAtomicLustActive)
			return true
	
		elseIf ((DTSConditionals as DTSleep_Conditionals).IsLeitoAAFActive)
			return true
		elseIf ((DTSConditionals as DTSleep_Conditionals).IsSavageCabbageActive)
			return true
		elseIf ((SleepPlayerAlias as DTSleep_PlayerAliasScript).DTSleep_IsZaZOut.GetValue() >= 1.0)
			return true
		endIf
	endIf
	
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

bool Function IsCompanionMultiLoveCompatible(Actor companionActor, ActorBase compBase = None, bool checkRace = true)

	if ((DTSleep_IntimateAffinityQuest as DTSleep_IntimateAffinityQuestScript).CompanionHatesIntimateOtherPublic(companionActor))
		return false
		
	elseIf (checkRace)
		return IsCompanionRaceCompatible(companionActor, compBase)
	endIf
	
	return true
endFunction

bool Function IsCompanionPowerArmorGlitched(Actor companionActor)
	
	if (companionActor != None)
		if (companionActor.WornHasKeyword(ArmorTypePower) == false)
			if (companionActor.IsInPowerArmor())
				return true
			endIf
		endIf
	endIf
	
	return false
endFunction

bool Function IsCompanionRaceCompatible(Actor companionActor, ActorBase compBase = None, bool romantic = true)

	if (companionActor == None)
		return false
	endIf
	
	; reset before apply
	SceneData.FemaleRaceHasTail = false
	SceneData.IsUsingCreature = false
	SceneData.IsCreatureType = 0
	
	if (companionActor == StrongCompanionRef)
		if ((DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).GetGenderForActor(PlayerRef) == 1)
			SceneData.IsUsingCreature = true
			SceneData.IsCreatureType = CreatureTypeStrong
			
			return true
		endIf
		return false
	endIf
	
	if (compBase == None)
		compBase = (companionActor.GetLeveledActorBase() as ActorBase)
	endIf
	
	if (compBase != None)
		Race compRace = compBase.GetRace()
		; Curie synth shows as gen2-Valentine, male gender - so we include 
		
		if (compRace == HumanRace || compRace == GhoulRace)
			return true
		
		elseIf ((DTSConditionals as DTSleep_Conditionals).IsVulpineRace != None && compRace == (DTSConditionals as DTSleep_Conditionals).IsVulpineRace)
			
			if (compBase.GetSex() == 1)
				SceneData.FemaleRaceHasTail = true
			endIf
			
			return true
			
		elseIf (compRace == SynthGen2RaceValentine)
		
			if (companionActor == CurieRef)
				; human Curie may show as synth-2 even though gen-3 should be human
				return true
					
			elseIf (romantic)
				; v1.08 - Xbox-only / non-adult scenes to support romanced Nick Valentine mod
				; v1.60 - also XOXO
				; v1.67 - any by included creature type to check
				SceneData.IsUsingCreature = true
				SceneData.IsCreatureType = CreatureTypeSynth
				
				return true

			else
				DTDebug(" not compatible SynthGen2: " + companionActor, 1)
			endIf
		else
			DTDebug(" not compatible race: " + compRace + ", actor: " + companionActor, 1)
		endIf
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
	if (linkRef)

		
		if (linkRef.HasKeyword(DTSConditionals.ConquestWorkshopKW))

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
		
	elseIf (val == -1)
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
int Function IsCompanionActorReadyForScene(IntimateCompanionSet intimateActor, bool sleepingOK = false, ObjectReference bedRef = None, bool pAOk = false)

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
				return -3
			endIf
			
		elseIf (!sleepingOK && compActor.GetSleepState() > 2)	

			return -2
			
		elseIf (compActor.IsInCombat())

			return -11
		elseIf (compActor.WornHasKeyword(ArmorTypePower))
			if (pAOk && compActor == CompanionDanseRef)
				; allow it
				inPowerArmor = true
			else 
				return -12
			endIf
			
		elseIf (compActor.IsInScene())
			Debug.Trace(myScriptName + " companion is busy in a scene ")
			return -4
			
		elseIf (compActor.IsSneaking())
			return -14
			
		elseIf (compActor.IsWeaponDrawn())

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
		else
			ResetSceneData()
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
		elseIf (compActor == StrongCompanionRef && intimateActor.RelationRank >= 3)
			SceneData.CompanionBribeType = IntimateBribeTypeMeat
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
		
		
		if (companionGender < 0)
			if (compActor == StrongCompanionRef)
			
				companionGender = 0
				SceneData.IsUsingCreature = true
				SceneData.IsCreatureType = CreatureTypeStrong
				
			elseIf (DressData.CompanionActor == compActor && DressData.CompanionGender >= 0)
				companionGender = DressData.CompanionGender
				if (companionGender == 1)
					; tail check
					if ((DTSConditionals as DTSleep_Conditionals).IsVulpineRace != None)
						ActorBase compBase = (compActor.GetBaseObject() as ActorBase)
						Race compRace = compBase.GetRace()
						if (compRace == (DTSConditionals as DTSleep_Conditionals).IsVulpineRace)
							SceneData.FemaleRaceHasTail = true
						endIf
					endIf
				endIf
			else
				ActorBase compBase = (compActor.GetLeveledActorBase() as ActorBase)
				
				if (!IsCompanionRaceCompatible(compActor, compBase))  ; includes tail check and returns creature if synth
					
					ResetSceneData()
					
					return -1
						
				elseIf (compActor == CurieRef)
					companionGender = 1
				else
					companionGender = compBase.GetSex()
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
			
		if (playerGender == companionGender)
		
			SceneData.MaleRoleGender = playerGender  ; same gender so whichever role
			
			if (compActor == StrongCompanionRef)
				return -1
			endIf
			
			SceneData.SameGender = true
		
			if (playerGender == 1)
				
				; one character requires a strap-on for adult animations
				bool requireStrapOn = false
				
				if (DTSleep_AdultContentOn.GetValueInt() >= 2 && !inPowerArmor)
				
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
				
					if (SceneData.HasToyAvailable && SceneData.ToyArmor)
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
								SceneData.HasToyEquipped = false

								
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
					SceneData.MaleRole = PlayerRef
					SceneData.FemaleRole = compActor
					MainQSceneScriptP.IsMaleCamOffset = true
					;MainQSceneScriptP.ReverseCamXOffset = true
					SceneData.HasToyAvailable = false
					SceneData.ToyArmor = None
				
					if ((DTSConditionals as DTSleep_Conditionals).IsAtomicLustActive)
						return 1
					elseIf ((DTSConditionals as DTSleep_Conditionals).IsSavageCabbageActive)
						return 1
					endIf
					
					return 505
				else
					; strap-on not required
					
					SceneData.FemaleRole = PlayerRef
					SceneData.MaleRole = compActor
					MainQSceneScriptP.IsMaleCamOffset = false
					MainQSceneScriptP.ReverseCamXOffset = false
					SceneData.HasToyAvailable = false
					SceneData.HasToyEquipped = false
					SceneData.ToyArmor = None
					
					return 1
				endIf
			else
				; both genders male
				SceneData.MaleRole = PlayerRef
				SceneData.FemaleRole = compActor
				MainQSceneScriptP.IsMaleCamOffset = true
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
			
			return 1
		else
			
			SceneData.FemaleRole = PlayerRef
			SceneData.MaleRole = compActor
			SceneData.MaleRoleGender = companionGender
			MainQSceneScriptP.IsMaleCamOffset = false
			MainQSceneScriptP.ReverseCamXOffset = false
			SceneData.HasToyAvailable = false
			SceneData.SameGender = false
			
			if (SceneData.MaleRole == StrongCompanionRef)
				SceneData.IsUsingCreature = true
				SceneData.IsCreatureType = CreatureTypeStrong
			endIf
			
			return 1
		endIf
	elseIf (compActor != None)
		
		DTSleep_BadCompanionMsg.Show()
		Utility.Wait(0.2)
	endIf
	
	return 0
EndFunction


int Function IsHeatherInLove()

	if ((DTSConditionals as DTSleep_Conditionals).IsHeatherCompInLove)
		return 2
	else
		Quest heatherCoreQuest = Game.GetFormFromFile(0x0300C9BA, "llamaCompanionHeather.esp") as Quest
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
						DTDebug(" IsPAStationOpen-false  found power armor furniture at distance " + paFrameRef.GetDistance(akFurniture), 1)
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
	
	if (undressLevel > 1)
		IsUndressReady = true
		
	elseIf (undressLevel == 1)
	
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
	
	if (DogmeatCompanionAlias != None)
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
	
	if (akBed.HasKeyword(AnimFurnFloorBedAnims) || (DTSConditionals as DTSleep_Conditionals).IsSnapBedsActive)
		
		ObjectReference closestShelter = DTSleep_CommonF.FindNearestObjectInListFromObjRef(DTSleep_BadSheltersList, akBed, 160.0)
		if (closestShelter)
			DTDebug(" found bad shelter " + closestShelter + " near bed " + akBed + " distance: " + closestShelter.GetDistance(akbed), 2)
			
			return true
		endIf
		
		Cell currentCell = akBed.GetParentCell()
		if (currentCell != None)
			
			if (DTSleep_BedCellNoRestList.HasForm(currentCell as Form))
				Form baseForm = akBed.GetBaseObject()
				
				if (baseForm && DTSleep_BedPlacedNoRestList.HasForm(baseForm))
					DTDebug(" on no-rest bed list " + akBed + " in Cell " + currentCell, 2)

					return true
				endIf
			endIf
		endIf
		
	endIf
	
	return false
endFunction

; see PlayerFriskyScore for score
;
int Function LocationScoreByFriskyScore(int friskyScore)
	
	float exp = DTSleep_IntimateEXP.GetValue()
	if (exp > 5.0)
		int adjustLim = Math.Floor(exp * 0.10)
		if (adjustLim > 13)
			adjustLim = 13
		endIf

		Location currentLoc = (SleepPlayerAlias as DTSleep_PlayerAliasScript).CurrentLocation
		if (currentLoc && friskyScore > 3)

			if (DTSleep_PrivateLocationList.HasForm(currentLoc as Form))
				if (friskyScore > (50 + adjustLim))
					return 14
				else
					return 4
				endIf
			
			elseIf (DTSleep_UndressLocationList.HasForm(currentLoc as Form))
				if (friskyScore > (58 + adjustLim))
					return 13
				else
					return 3
				endIf
				
			elseIf (DTSleep_TownLocationList.HasForm(currentLoc as Form))
				if (friskyScore > (70 + adjustLim))
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
			Utility.Wait(0.06)
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
		if (!PlayerRef.HasPerk(DTSleep_LoversEmbraceHugPerk))
			PlayerRef.AddPerk(DTSleep_LoversEmbraceHugPerk)
	
			if (notify)
				DTSleep_LoversEmbraceHugMsg.Show()
			endIf
			StartTimerGameTime(8.0, IntimateEmbracePerkTimerID)
		endIf
	elseIf (PlayerRef.HasPerk(DTSleep_LoversEmbraceHugPerk))
		
		PlayerRef.RemovePerk(DTSleep_LoversEmbraceHugPerk)
		CancelTimerGameTime(IntimateEmbracePerkTimerID)
	endIf
endFunction

Function LoverBonusRested(bool isAdd, bool notify = false)
	if (isAdd)
		if (!PlayerRef.HasPerk(DTSleep_LoversEmbracePerk))
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
		endIf
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
	
	if ((DTSConditionals as DTSleep_Conditionals).IsPlayerCommentsActive && !(DTSConditionals as DTSleep_Conditionals).ModPlayerCommentsDisabled)
		
		
		if ((DTSConditionals as DTSleep_Conditionals).ModPlayerCommentsGlobDisabled != None)
			GlobalVariable pcGV = (DTSConditionals as DTSleep_Conditionals).ModPlayerCommentsGlobDisabled
			
			int pcDisVal = pcGV.GetValueInt()

			if (pcDisVal < 1)
				DTDebug(" disable PCHT ", 1)
				Quest pcQuest = ModGetPlayerCommentsQuest()
				
				if (pcQuest == None)
					return -1
					DTDebug("PCHT Quest is None!! ", 1)
				else
					(DTSConditionals as DTSleep_Conditionals).ModPlayerCommentsDisabled = true
					
					DTSleep_ModPlayerCommentOffMsg.Show()
					
					pcQuest.Stop()
					PlayerRef.ClearLookAt()
					ModPlayerCommentSetGlobals(1.0)
					Utility.Wait(2.25)
					
					return 2
				endIf
			endIf
		else
			DTDebug(" PCHT global is None!!", 1)
		endIf
	endIf
	
	return 0
endFunction

int Function ModPlayerCommentsEnable()
	if ((DTSConditionals as DTSleep_Conditionals).ModPlayerCommentsDisabled)
		Quest pcQuest = ModGetPlayerCommentsQuest()
		(DTSConditionals as DTSleep_Conditionals).ModPlayerCommentsDisabled = false
		if (pcQuest != None && !pcQuest.IsRunning())
			DTDebug("enable PCHT quest...", 2)
			DTSleep_ModPlayerCommentOnMsg.Show()
			
			PlayerRef.ClearLookAt()
			ModPlayerCommentSetGlobals(0.0)
			pcQuest.SetStage(0)
			Utility.Wait(1.1)
		endIf
		
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
			;Debug.Trace(myScriptName + " bench/couch 2 markers in use")
			okayToSit = false
		endIf
	else
		;Debug.Trace(myScriptName + " chair (not bench) in use")
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
int Function PlayerFriskyScore()

	if (DTSleep_IntimateEXP.GetValue() <= 0.0)
		return -1
	elseIf (DTSleep_SettingIntimate.GetValue() <= 0.0 || DTSleep_SettingUndress.GetValue() < 0.0)
		return -2
	endIf
	
	int result = 0
	
	if (IsAdultAnimationAvailable())
	
		float gameTime = Utility.GetCurrentGameTime()
		float daysSinceLastIntimate = gameTime - IntimateLastTime
		
		
		if (daysSinceLastIntimate > 1.0 && daysSinceLastIntimate < 32.0)
		
			result = ChanceForIntimateSceneByLastTime(4, gameTime, false, false)
			
			float hourOfDay = DTSleep_CommonF.GetGameTimeCurrentHourOfDayFromCurrentTime(gameTime)
			
			if (hourOfDay >= 19.0 && hourOfDay < 23.99)
				if (DressData.PlayerGender == 0)
					result = result * 3
				else
					result = result * 2
				endIf
			elseIf (hourOfDay > 4.0 && hourOfDay <= 6.0)
				if (DressData.PlayerGender == 0)
					result = ((result * 1.50) as int)
				else
					result = result * 2
				endIf
			elseIf (result > 5)
				result = 5
			endIf
		endIf
	else
		; do we want score for dancing intimacy?
		result = -10
	endIf
	
	return result 
endFunction

bool Function PlayerIntimateCompatible()
	if ((DTSConditionals as DTSleep_Conditionals).PlayerRace == None)
		ActorBase playerBase = (PlayerRef.GetBaseObject() as ActorBase)
		if (playerBase)
			Race playerR = playerBase.GetRace()
			(DTSConditionals as DTSleep_Conditionals).PlayerRace = playerR
		endIf
	endIf
	Race pr = (DTSConditionals as DTSleep_Conditionals).PlayerRace
	if (pr != None && pr == HumanRace || pr == GhoulRace || pr == SynthGen2RaceValentine)
		return true
	elseIf ((DTSConditionals as DTSleep_Conditionals).IsVulpineRacePlayerActive)
		return true
	endIf
	
	return false
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
		exp += DTSleep_IntimateDogEXP.GetValueInt()
		
		
	elseIf (creatureType == CreatureTypeStrong)
		; for human experience grant a small bonus
		if (exp >= 120)
			exp = 10
		elseIf (exp > 9)
			exp = Math.Floor(exp * 0.083333)
		else
			exp = 0
		endIf
		exp += DTSleep_IntimateStrongExp.GetValueInt()
		
	endIf
	
	if (exp > 0)
		if (exp >= 306)
			result = 90
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
			DTDebug(" Sex Appeal penalty -- too sick! ", 1)
			
			result -= 72
		
		elseIf (PlayerRef.HasMagicEffect(HC_Disease_Fatigue_Effect))
			DTDebug(" Sex Appeal penalty -- too tired! ", 1)
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
	if (playerLevel >= 48)
		levelChance = 24
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
			
		elseIf (creatureType == CreatureTypeStrong)
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
	
		clothBonus = 7
		
	elseIf (isNaked)
		
		if (SceneData.CompanionBribeType == IntimateBribeNaked)
			; bribe
			playerHasBribeType = IntimateBribeNaked
			
			clothBonus = 16
		else
			; regular 
			if (playerSex > 0)
			
				if (creatureType == CreatureTypeStrong)
					if (isIntoxicated)
						clothBonus = 19
					else
						clothBonus = 28
					endIf
					
				elseIf (isIntoxicated)
					clothBonus = 8
					
				elseIf (creatureType == CreatureTypeDog)
					clothBonus = 12
					
				elseIf (charisma > 3)	
					clothBonus = 10
				else
					clothBonus = 5
				endIf
			else
				clothBonus = 7
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
	endIf
	if (PlayerRef.HasPerk(DTSleep_LoversEmbraceHugPerk))
		result += 16
		restPerkBonus += 16
	endIf
	
	if (DTSleep_SettingTestMode.GetValue() > 0.0 && DTSleep_DebugMode.GetValue() >= 0.50)
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
		elseIf (creatureType == CreatureTypeStrong)
			chanceDisease -= 2
		elseIf (creatureType == CreatureTypeSynth)
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
;
Function PlayerSleepAwake(bool doneSleep)

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
		if (pickType == 1)
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
	
	Utility.Wait(1.2)
	
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
		if (DTSleep_AdultContentOn.GetValueInt() >= 2.0 && (DTSConditionals as DTSleep_Conditionals).IsSavageCabbageActive)
			int gender = (DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).GetGenderForActor(PlayerRef)
			if (gender == 1)
				DTSleep_SettingChairsEnabled.SetValue(2.0)
			else
				DTSleep_SettingChairsEnabled.SetValue(1.0)
			endIf
		else
			DTSleep_SettingChairsEnabled.SetValue(1.0)
		endIf
	endIf
	
	if (DTSleep_SettingAAF.GetValue() < 0.0)
		; init to disabled if have AAF otherwise leave hidden
		if ((DTSConditionals as DTSleep_Conditionals).IsAAFActive && (DTSConditionals as DTSleep_Conditionals).IsF4SE)
			DTSleep_SettingAAF.SetValue(0.0)
		endIf
	endIf
	
EndFunction

Function RedressCompanion()
	IsUndressReady = false
	if SleepInputLayer
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
		WakeStopCompQuest()
	endIf
	
	DTSleep_PlayerUsingBed.SetValue(0.0)
	IsUndressReady = false
	
	UnregisterForPlayerSleep()
	
	if (DTSleep_TimeDayQuestP.IsRunning())
		(DTSleep_TimeDayQuestP as DTSleep_TimeDayQuestScript).StopAll()
	endIf
	
	if (SleepBedUsesBlock && SleepBedInUseRef)
		SleepBedInUseRef.BlockActivation(true)
	endIf
	if (DTSleep_HealthRecoverQuestP.IsRunning())
		(DTSleep_HealthRecoverQuestP as DTSleep_HealthRecoverQuestScript).StopAllCancel()
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
	
	Utility.Wait(0.1)
	
	DTDebug("ResetAll Done", 1)

EndFunction

Function ResetHelpTips()

	PersuadeTutorialFailShown = 0
	TipSleepModeDisplayCount = 1
	PersuadeTutorialXFFShown = 0
	PersuadeTutorialSuccessShown = 0
	
	StartTimer(64.0, CustomCameraTipTimerID)
	StartTimer(200.0, IntroRestNotShowTipTimerID)

endFunction

Function ResetSceneData()
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
	SceneData.IsUsingCreature = false
	SceneData.IsCreatureType = 0
	SceneData.MaleRoleCompanionIndex = -1
	SceneData.CurrentLoverScenCount = 0
	SceneData.CompanionBribeType = 0
	SceneData.FemaleRaceHasTail = false
	SceneData.CompanionInPowerArmor = false
	SceneData.SecondFemaleRole = None
	SceneData.SecondMaleRole = None
	; do not reset LkbwLevel
	
endFunction

Function RestoreSceneData()
	SceneData.MaleRole = SceneData.BackupMaleRole
	SceneData.FemaleRole = SceneData.BackupFemaleRole
	SceneData.MaleRoleGender = SceneData.BackupMaleRoleGender
	SceneData.SameGender = SceneData.BackupSameGender
	SceneData.CurrentLoverScenCount = SceneData.BackupCurrentLoverScenCount

endFunction

Function ResetSceneOnLoad()
	Utility.Wait(1.0)
	
	DTDebug(" ResetSceneOnLoad..", 1)
	MainQSceneScriptP.GoSceneViewStart()
endFunction

bool Function SetDogmeatFollow()

	processingDogmeatWait = -5
	
	if (DogmeatCompanionAlias != None)
		
		Actor dogmeatRef = DogmeatCompanionAlias.GetActorReference()
		if (dogmeatRef)
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

Function SetExtraLovePartners(int forIntimateSecond = -1, bool seatedOK = true)

	DTDebug("check extra loversl (" + forIntimateSecond + ") with lover " + IntimateCompanionRef + " and current SecondRoles: " + SceneData.SecondMaleRole + ", " + SceneData.SecondFemaleRole, 2)
	if (DTSleep_SettingLover2.GetValue() <= 0.0)
		return
	endIf
	ObjectReference[] actorArray = PlayerRef.FindAllReferencesWithKeyword(DTSleep_ActorKYList.GetAt(0), 720.0)
	
	Actor heatherActor = GetHeatherActor()
	Actor barbActor = GetNWSBarbActor()	
	int aCnt = 0
	
	SceneData.SecondFemaleRole = None
	SceneData.SecondMaleRole = None
	
	while (aCnt < actorArray.Length && (SceneData.SecondFemaleRole == None || SceneData.SecondMaleRole == None))
		Actor ac = actorArray[aCnt] as Actor
		
		if (ac != None && ac != PlayerRef && ac.IsEnabled())
		
			DTDebug("checking enabled extra actor " + ac, 2)

			if ((DTSConditionals as DTSleep_Conditionals).IsWorkShop02DLCActive && ac.HasKeyword((DTSConditionals as DTSleep_Conditionals).DLC05ArmorRackKY))
				; do nothing -
				; not counting workshop armor mannequin which is NPC
			
			elseIf (!ac.IsDead() && !ac.IsUnconscious() && ac.GetSleepState() < 3 && !ac.WornHasKeyword(ArmorTypePower) && (!IsAAFReady() || !ac.IsInPowerArmor()))
			
				if (seatedOK || ac.GetSitState() < 2)
			
					CompanionActorScript aCompanion = GetCompanionOfActor(ac)
					
					if (aCompanion != None && ac != IntimateCompanionRef)
					
						DTDebug("checking companion " + ac, 2)
			
						; make certain partner is not the jealous type   -- v2.13: jealous okay
						;if ((DTSleep_IntimateAffinityQuest as DTSleep_IntimateAffinityQuestScript).CompanionHatesIntimateOtherPublic(ac) == false)
					
							bool isPartner = false
							if (aCompanion.IsRomantic())
								isPartner = true
							elseIf (aCompanion.IsInFatuated())
								isPartner = true
							elseIf (DTSleep_CompanionRomanceList.HasForm(ac as Form) && aCompanion.GetValue(CA_AffinityAV) >= 1000.0)
								isPartner = true
							elseIf (PlayerHasPerkOfCompanion(ac))
								isPartner = true
							endIf
							if (isPartner)
									
								if ((DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).GetGenderForActor(ac) == 1)
									if (SceneData.SecondFemaleRole == None)
										SceneData.SecondFemaleRole = ac
									endIf
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
					endIf
				endIf
			endIf
		endIf
	
		aCnt += 1
	endWhile
	
	; check second actors to set ready
	; 0=FMM, 1=FMF, 2=M/F (FMM or FMF)
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
				
			elseIf (SceneData.SecondMaleRole.GetSitState() < 2)
				SceneData.SecondMaleRole = None
			endIf
			SceneData.SecondFemaleRole = None
				
		elseIf (setForGender == 1)
			if (DTSleep_CompIntimateLover2Alias != None)
				IntimateCompanionSecRef = SceneData.SecondFemaleRole
			elseIf (SceneData.SecondFemaleRole.GetSitState() < 2)
				SceneData.SecondFemaleRole = None
			endIf
			SceneData.SecondMaleRole = None
		endIf
		
		if (IntimateCompanionSecRef != None)
			IntimateCompanionSecRef.AddToFaction(DTSleep_IntimateFaction)
			DTSleep_CompIntimateLover2Alias.ForceRefTo(IntimateCompanionSecRef)
			IntimateCompanionSecRef.EvaluatePackage()
			Utility.Wait(0.1)
		else
			SceneData.SecondFemaleRole = None
			SceneData.SecondMaleRole = None
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
	
	if (DTSleep_AdultContentOn.GetValueInt() <= 1.0 && DTSleep_SettingChairsEnabled.GetValueInt() >= 2)
		DTSleep_SettingChairsEnabled.SetValueInt(1)
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
	
	if (oldVersion < 2.08)
		int evbVal = (DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).DTSleep_SettingUseLeitoGun.GetValueInt()
		if (DTSleep_AdultContentOn.GetValueInt() >= 2 && IsAAFReady())
			if (evbVal > 0)
				(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).DTSleep_SettingUseLeitoGun.SetValueInt(0)
				count += 1
			endIf
		elseIf (DTSleep_AdultContentOn.GetValueInt() >= 2 && DTSleep_IsLeitoActive.GetValueInt() >= 2 && (DTSConditionals as DTSleep_Conditionals).IsLeitoActive)
			if (evbVal < 2)
				(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).DTSleep_SettingUseLeitoGun.SetValueInt(2)
				count += 1
			endIf
		elseIf (evbVal > 0)
			(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).DTSleep_SettingUseLeitoGun.SetValueInt(0)
			count += 1
		endIf
	endIf
	
	if (oldVersion < 2.14)
		if (IntimateCheckFailCount > 2)
			IntimateCheckFailCount = 2
		endIf
	endIf
	
	return count
endFunction

Function SetAffinityForCreature(int creatureType)

	if (creatureType == CreatureTypeDog)
		self.SleepIntimateSceneAffinityOnSleepID = 2
	elseIf (creatureType == CreatureTypeStrong)
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
int Function SetDogmeatWait(float minDistance = 64.0, float maxDistance = 2400.0, bool restrainDog = true)
	
	DogmeatSetWait = false
	processingDogmeatWait = 2
	
	; must have dog alias and not in sleep quest
	; 
	if (DogmeatCompanionAlias != None && !DTSleep_CompSleepQuest.IsRunning())
	
		Actor dogmeatRef = DogmeatCompanionAlias.GetActorReference()
		
		; assume SitState is using a doghouse
		if (dogmeatRef != None && dogmeatRef.GetSitState() < 2)
		
			float dist = DTSleep_CommonF.DistanceBetweenObjects(dogmeatRef, PlayerRef, true)
			
			if (dist > minDistance)
				if (dist < maxDistance)
				
					ObjectReference dogSleepNearRef = DTSleep_CommonF.FindNearestObjHaveKeywordFromObject(PlayerRef, DTSleep_DogSleepKWList, 3200.0)
					if (dogSleepNearRef == None)
						; no doghouse so tell doggy to wait
						DogmeatSetWait = true
						
						dogmeatRef.FollowerWait()
						dogmeatRef.SetDogAnimArchetypeNeutral()
						
						if (restrainDog)
							dogmeatRef.SetRestrained(true)
						endIf
						
						DTDebug(" Dogmeat nearby - wait, Dogmeat, wait! ", 2)

						processingDogmeatWait = -1
						
						return 1
					else
						DTDebug(" dog-sleep nearby, skip Dogmeat wait", 2)
						dogmeatRef.EvaluatePackage()
					endIf
				endIf
			else
				processingDogmeatWait = -1
				return -1
			endIf
		endIf
	endIf
	
	processingDogmeatWait = 0
	
	return 0
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
	if (akBed.HasKeyword(AnimFurnFloorBedAnims))
		MainQSceneScriptP.CamHeightOffset = -24.0
	else
		MainQSceneScriptP.CamHeightOffset = 0.0
	endIf
	MainQSceneScriptP.GoSceneViewStart()
	
	float undressLevel = DTSleep_SettingUndress.GetValue()
	
	if (undressLevel > 0.0 && DTSleep_PlayerUndressed.GetValue() == 0.0)

		if (undressLevel >= 2.0)
			observeWinter = false
		endIf
		
		undressOK = SetUndressForBed(akBed, IntimateCompanionRef, akCompanionBed, observeWinter, companionReqNudeSuit, playerNaked)
	endIf
	
	bool findTwinBed = true
	if (undressOK && SleepBedCompanionUseRef != None && SleepBedCompanionUseRef != SleepBedInUseRef)
		if (SleepBedCompanionUseRef.GetDistance(SleepBedInUseRef) < 150.0)
			findTwinBed = false
			
			SleepBedTwin = SleepBedCompanionUseRef
			RegisterForRemoteEvent(SleepBedTwin, "OnActivate")
			DTDebug(" listening to sleepComp bed for second activator: " + SleepBedTwin, 2)
			
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
			DTDebug(" listening to nearby bed for second activator: " + testBed, 2)

			SleepBedTwin = testBed
			RegisterForRemoteEvent(SleepBedTwin, "OnActivate")
		else
			DTDebug(" no twin bed found ", 2)
		endIf
	endIf
	
	if (moveToBed)
		; put player in bed
		DTDebug(" SetBedTime: placing in bed..." , 2)

		MoveActorToBed(PlayerRef, akBed)
		
	else
		DTDebug(" SetBedTime: skip place in bed", 2)
	endIf
	
	
	Utility.Wait(0.06)

	int encType = SetPlayerSleepEncounter(akBed, IntimateCompanionRef, IntimateCompanionRef)
	DTDebug(" sleep-wake encounter: " + encType, 2)

	FadeInFast(false)
	
	if (SleepBedUsesBlock)
		; unblock so we can get out
		akBed.BlockActivation(false)
	endIf
		
	int restCount = 1 + DTSleep_RestCount.GetValueInt()
	DTSleep_RestCount.SetValueInt(restCount)
	
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
	if (DTSleep_SettingBedDecor.GetValue() > 0.0)
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
	
	if (!SceneData.CompanionInPowerArmor)
		if ((DTSConditionals as DTSleep_Conditionals).NoraSpouseRef != None && IntimateCompanionRef == (DTSConditionals as DTSleep_Conditionals).NoraSpouseRef)
			; no disease
		else
			PlayerDiseaseCheckSTD(creatureType)
		endIf
	endIf
	
	float timeSinceLast = DTSleep_CommonF.GetGameTimeHoursDifference(IntimateLastTime, intimateTime)
	
	if (nearActorCount > 11)
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
	
	if (creatureType != CreatureTypeDog)
	
		IntimateSucPrevTime = IntimateLastTime
		DTSleep_IntimateTime.SetValue(intimateTime)     ; human or Strong - record time
		IntimateLastTime = intimateTime
		SceneData.CurrentLoverScenCount += 1		    ; keep track for same-love / faithful bonus
		
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
		
			IntimacySceneCount += 1
			exp = IntimacySceneCount
		
			DTSleep_IntimateEXP.SetValueInt(IntimacySceneCount)
		
		elseIf (creatureType == CreatureTypeStrong)
		
			; Strong EXP 
			IntimacySMCount += 1
			exp = IntimacySMCount
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
		
			IntimacyDogCount += 1
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

IntimateCompanionSet Function SetSceneForDogmeat()

	IntimateCompanionSet nearCompanion = new IntimateCompanionSet
	nearCompanion.Gender = -1
	
	if (IsDogPlaySettingsOn() && PlayerHasActiveDogmeatCompanion.GetValueInt() > 0 && DogmeatCompanionAlias != None && PlayerRef.HasPerk(LoneWanderer01))
			
		Actor dogmeatRef = DogmeatCompanionAlias.GetActorReference()
		
		if (!dogmeatRef.IsDead() && !dogmeatRef.IsUnconscious() && dogmeatRef.GetDistance(PlayerRef) < 900.0 && dogmeatRef.GetSitState() <= 1)

			ResetSceneData()
			
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
			
			if (DTSleep_DogIntimateRestAlias != None)
				DTSleep_DogIntimateRestAlias.Clear()
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

Function SetStartSpectators(ObjectReference forFurnitureRef)

	DTSleep_SpectatorQuestP.Start()
	if (SceneData.AnimationSet <= 0)
		(DTSleep_SpectatorQuestP as DTSleep_SpectatorQuestScript).SetTargetObject(PlayerRef)
	else
		(DTSleep_SpectatorQuestP as DTSleep_SpectatorQuestScript).SetTargetObject(forFurnitureRef)
	endIf
	
endFunction
	

;	start Intimate Undress Quest for using bed - best in 3rd-person view
;
bool Function SetUndressForBed(ObjectReference playerBed, Actor companionActor, ObjectReference companionBed, bool observeWinter, bool companionReqNudeSuit, bool playerNaked)

	DTDebug("  SetUndressForBed beds: " + playerBed + "," + companionBed + ", undressReady: " + IsUndressReady, 1)

	
	(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).EnableCarryBonus = true
	(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).SuspendEquipStore = false
	(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).PlayerIsAroused = false
	(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).AltFemBodyEnabled = false
	
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
				
	DTDebug(" SetUndressForCheck..", 1)
	
	DTSleep_UndressCheckStartMsg.Show()
	
	(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).EnableCarryBonus = false
	(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).SuspendEquipStore = true
	(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).PlayerIsAroused = false
	(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).AltFemBodyEnabled = false
	
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
	
	; v2.15 - check combat and if activate success
	if (akFurniture != None && !PlayerRef.IsInCombat())
		if (akFurniture.Activate(PlayerRef))
		
			if (DTSleep_SettingUndress.GetValue() >= 1.0)
				(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).EnableCarryBonus = true
				(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).SuspendEquipStore = false
				(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).PlayerIsAroused = false
				(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).AltFemBodyEnabled = false
				
				IntimateWeatherScoreSet wScore = ChanceForIntimateSceneWeatherScore()
				(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).WeatherClass = wScore.wClass
				
				; includeHatsOutside false to keep on outdoors
				return (DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).StartForFurnitureExitRespect(akFurniture, companionActor, false)
			endIf
		endIf
	endIf

	return false
endFunction

; fadeUndressLevel -1 for nothing-no-fade, 0 for hats, 1 for bed, 2 for clothing/naked
;
int Function SetUndressAndFadeForIntimateScene(Actor companionRef, ObjectReference bedRef, int fadeUndressLevel, bool mainActorIsPositioned, bool playSlowMo = false, bool isDogmeatScene = false, bool lowCam = true, int[] animPacks = None, bool isNaked = false, ObjectReference twinBedRef = None, int playerScenePick = -1)
	
	int seqID = -1
	int evbBestFitVal = (DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).DTSleep_SettingUseLeitoGun.GetValueInt()
	int bt2Val = (DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).DTSleep_SettingUseBT2Gun.GetValueInt()
	bool animationZeX = false
	
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
	bool aafIsReady = IsAAFReady()
	int adultContentVal = DTSleep_AdultContentOn.GetValueInt()
	bool testModeOn = false
	if (DTSleep_SettingTestMode.GetValue() > 0.0)
		testModeOn = true
	endIf
	
	
	; ------------------------- setup scene order
	; 1. limit scene choices
	int arousalAngle = -1
	if (SceneData.MaleRole == PlayerRef && adultContentVal >= 2 && TestVersion == -2 && (Debug.GetPlatformName() as bool))
		if (DressData.PlayerGender == 0)
			
			if (evbBestFitVal > 0)
				if (evbBestFitVal == 1)
					arousalAngle = 0
				elseIf (bt2Val > 0)
					arousalAngle = Utility.RandomInt(0,1)
				endIf
			elseIf (bt2Val > 0)
				arousalAngle = Utility.RandomInt(0,1)
			endIf
			
		elseIf (DressData.PlayerGender == 1 && SceneData.SameGender)
			; for strap-on toy
			arousalAngle = 0
		endIf
	endIf
	
	; 2. startup/reset scene to set bed and companion 
	(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).StartForActorsAndBed(PlayerRef, companionRef, bedRef, fadePlay, mainActorIsPositioned, playSlowMo)
	(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SleepBedTwinRef = twinBedRef
	
	; 3. set companion prefs before pick scene
	UpdateIntimateAnimPreferences(playerScenePick)
	
	; 4. set animation packs to get sequenceID and animation set
	if (adultContentVal >= 1 && (DTSConditionals as DTSleep_Conditionals).ImaPCMod)
		; set animation packs
		if (animPacks.Length > 0)
			
			if (adultContentVal >= 2 && arousalAngle >= 0 && SceneData.MaleRole == PlayerRef && playerScenePick < 0 && DressData.PlayerGender == 1)
				(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).RestrictScenesToErectAngle = arousalAngle
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
			seqID = (DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetAnimationPacksAndGetSceneID(animPacks)
			
			; TODO: check this
			;animationZeX = (DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).AnimationSetSupportsZeX(SceneData.AnimationSet)
			
			if (aafIsReady && arousalAngle >= 0)
				if (SceneData.AnimationSet == 5 || SceneData.AnimationSet == 8)
					arousalAngle = 0
				endIf
			else
				arousalAngle = -1
			endIf
			
			if (seqID <= 99)
				SceneData.AnimationSet = 0
			;elseIf (aafIsReady && doArousal)
				; no swapping during AAF and since scene picker does not restrict these then adjust to best
				;if (arousalAngle == 0 && seqID >= 735 && seqID < 738)
				;	arousalAngle = 1
				;elseIf (arousalAngle != 1 && seqID >= 758 && seqID <= 759)
				;	arousalAngle = 1
				;elseIf (arousalAngle != 1 && seqID == 754)
				;	arousalAngle = 1
				;elseIf (arousalAngle == 1 && (seqID == 753 || seqID == 755 || seqID == 738 || seqID == 751))
				;	arousalAngle = 0
				;elseIf (seqID == 547)
				;	arousalAngle = -1
				;endIf
			endIf
			
			; check to clear 2nd lover and swap back if not needed
			if (SceneData.SecondFemaleRole == None && SceneData.SecondMaleRole == None)
				DTDebug(" clear 2nd lover - not needed by iAnim", 2)
				ClearIntimateSecondCompanion()
			endIf
		endIf
	endIf
	
	; 5. check set for camera
	if (!lowCam)
		int baseID = DTSleep_CommonF.BaseIDForFullSequenceID(seqID)
		DTDebug(" set lowcam for base-id " + baseID, 2)
		if (baseID < 50)
			lowCam = true	; force for non-stand scenes
		endIf
	endIf
	
	if (SceneData.AnimationSet >= 5 && SceneData.AnimationSet < 100)
		if (aafIsReady)
			if (DTSleep_SettingAAF.GetValueInt() >= 2)
				; cancel fade
				fadePlay = false
			endIf
			camLevel = -1  ; disable custom
			lowCam = false
		elseIf (SceneData.AnimationSet == 9)
			lowCam = true
		endIf
	elseIf (SceneData.AnimationSet == 0 || seqID < 100)
		camLevel = -1
	endIf
	
	(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).FadeEnable = fadePlay
	
	; 6. set camera
	if (lowCam)
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

	; --------------scene setup done, now undress if undressing
	if (fadeUndressLevel >= 0 && DTSleep_SettingUndress.GetValue() > 0.0)
		
		if (fadePlay)
			FadeOutFast(false)
		endIf
		
		; set 2nd lover if any
		(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).CompanionSecondRef = IntimateCompanionSecRef
		
		Utility.Wait(0.08)
		
		bool includeClothing = true
		if (seqID < 100)
			includeClothing = false
			if (fadeUndressLevel >= 2)
				; hug/dance: lower undress to sleep clothes / respect level
				fadeUndressLevel = 1
			endIf
		elseIf (fadeUndressLevel < 2 && !(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SceneIDIsCuddle(seqID))
			if (adultContentVal >= 2.0)
				; uh-oh, caller expected dance or cuddle, but picker chose sexy scene!
				DTDebug("SetUndressAndFadeForIntimateScene undress-level set to respect/sleep, but ID  ", 2)
				fadeUndressLevel = 2
			else
				DTDebug("SetUndressAndFadeForIntimateScene found invalid scene picked!! (" + seqID + ") forcing hug! (98)", 2)
				seqID = 98
				includeClothing = false
			endIf
		endIf
		
		if (!isNaked)						; v1.57 - if naked on activate bed, take it all off
		
			if (adultContentVal <= 1.0 || SceneData.AnimationSet == 0 || animPacks == None)
				; out of respect for players consider naked/underwear dancing implies too much
				; let's restrict undress so depending on outfit may remain dressed
				includeClothing = false
				arousalAngle = -1
				if (fadeUndressLevel >= 2)
					fadeUndressLevel = 0
				endIf
				
			elseIf (SceneData.AnimationSet == 5 && seqID >= 548 && seqID <= 549)
				; partial undress check for hugs
				if (fadeUndressLevel >= 2)
					fadeUndressLevel = 1
				elseIf (mainActorIsPositioned)
					includeClothing = false
				endIf
			endIf
		endIf
		
		(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).ForceEVBNude = false
		
		if (aafIsReady)
			if (includeClothing && arousalAngle >=0 && DressData.PlayerGender == 0 && adultContentVal >= 2)
				bool forceEVB = false
				if (SceneData.AnimationSet == 5 || SceneData.AnimationSet == 6 || SceneData.AnimationSet == 8)
					if (seqID >= 800 && seqID < 900)
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
		endIf
		
		; first check respect
		if (fadeUndressLevel >= 0 && fadeUndressLevel <= 1)
			(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).DropSleepClothes = false
			(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).EnableCarryBonus = true
			(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).SuspendEquipStore = false
			
			
			IntimateWeatherScoreSet wScore = ChanceForIntimateSceneWeatherScore()
			(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).WeatherClass = wScore.wClass
			
			
			
			; sleep clothes if have them and if for bed
			
			if (fadeUndressLevel == 0)
			
				(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).StartForManualStopRespect(IntimateCompanionRef)
				
			elseIf ((DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).StartForManualStopSleepwear(IntimateCompanionRef, bedRef) == false)
			
				(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).StartForManualStopRespect(IntimateCompanionRef)
			endIf
			
		elseIf (isDogmeatScene)
		
			SetUndressForManualStop(true, None, false, false, bedRef, includePipboy)
			
		elseIf (SceneData.CompanionInPowerArmor)
		
			SetUndressForManualStop(includeClothing, None, false, false, bedRef, includePipboy)
		else
			SetUndressForManualStop(includeClothing, companionRef, false, true, bedRef, includePipboy, true)
		endIf
		Utility.Wait(0.24)
		
		; get toys from storage?
		if (SceneData.ToyFromContainer)
			if (bedRef != None && bedRef.HasKeyword(DTSleep_OutfitContainerKY) && SceneData.AnimationSet > 0 && !SceneData.HasToyEquipped && SceneData.ToyArmor != None)
				DTDebug(" remove toy armor from bed", 2)
				bedRef.RemoveItem(SceneData.ToyArmor, 1, true, SceneData.MaleRole)
			else
				SceneData.ToyFromContainer = false
			endIf
		endIf
	elseIf (SceneData.AnimationSet == 5 && DTSleep_SettingUndress.GetValue() > 0.0)
		; no undress - let's do hats
		(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).StartForManualStopRespect(IntimateCompanionRef)
		;SetUndressForManualStop(false, companionRef, false, true, None, false)
	endIf
	
	;Utility.Wait(0.24)

	EnablePlayerControlsSleep()
	Utility.Wait(0.04)
	
	return seqID
endFunction

bool Function SetUndressForCompanionSleepwear(Actor companionActor, bool companionReqNudeSuit)

	(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).DropSleepClothes = false
	(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).SuspendEquipStore = false
	
	return (DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).StartForCompanionSleepwear(companionActor, companionReqNudeSuit)
EndFunction

; start Intimate Undress Quest - best in 3rd-person view
; 
bool Function SetUndressForManualStop(bool undressAll, Actor companionActor, bool observeWinter, bool companionReqNudeSuit, ObjectReference optionalBedRef = None, bool includePipBoy = false, bool dropSleepGear = true, bool carryBonus = true)
	
	(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).DropSleepClothes = dropSleepGear
	(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).EnableCarryBonus = carryBonus
	(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).SuspendEquipStore = false
	;(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).PlayerIsAroused = false
	IntimateWeatherScoreSet wScore = ChanceForIntimateSceneWeatherScore()
	(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).WeatherClass = wScore.wClass
	
	return (DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).StartForManualStop(undressAll, companionActor, observeWinter, companionReqNudeSuit, optionalBedRef, includePipBoy)
	
EndFunction

bool Function SetUndressForNoStop(bool carryBonus = false)
	
	(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).DropSleepClothes = false
	(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).EnableCarryBonus = carryBonus
	(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).PlayerIsAroused = false
	IntimateWeatherScoreSet wScore = ChanceForIntimateSceneWeatherScore()
	(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).WeatherClass = wScore.wClass
	
	return (DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).StartForNeverRedress()
	
EndFunction

; for beds that have their own activate animations - undress first before activating
; -see Sleep Together Camp
;
bool Function SetUndressForSpecialAnimBed(ObjectReference targetRef, bool companionRequiresNudeSuit, bool playerNaked)

	GoThirdPerson()
	DisablePlayerControlsSleep()
			
	bool alwaysUndress = IsPlayerOkayToUndressForBed(4.0, targetRef)
	
	bool observeWinter = true
	if (alwaysUndress || DTSleep_SettingUndress.GetValue() >= 2.0)
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
	float hoursSinceWarnLim = 4.25
	if (sexAppealScore < 50)
		hoursSinceWarnLim = 7.5
	elseIf (sexAppealScore > 120)
		hoursSinceWarnLim = 2.5
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
		
	; -------------------- hour limits, holidays, and addiction warnings -----------
		
	elseIf (dogmeatScene && dogEXP > 0 && dogEXP < IntimateDogTrainEXPLimit && hoursSinceLastDogIntimate < IntimateDogTrainHourLimit)
	
		if (hoursSinceLastDogIntimate < 1.67)
			checkVal = DTSleep_IntimateCheckRecentDogHourMsg.Show(sexAppealScore, dogEXP)
		else
			checkVal = DTSleep_IntimateCheckRecentDogMsg.Show(sexAppealScore, hoursSinceLastDogIntimate, dogEXP)
		endIf	
		
	elseIf (!showBeginnerPrompt && !dogmeatScene && (hoursSinceLastFail < hoursSinceWarnLim || hoursSinceLastIntimate < hoursSinceWarnLim))
		
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
		
		; ------- fail and addictions
		
	elseIf (!dogmeatScene && IntimateCheckFailCount >= 3 && hoursSinceLastFail < 20.0)
		
		checkVal = DTSleep_IntimateCheckFailsMsg.Show(IntimateCheckFailCount)
		
	elseIf (!dogmeatScene && addictCount >= 3)
	
		checkVal = DTSleep_IntimateCheckAddictMsg.Show(sexAppealScore, locHourChance.Chance)
			
	; --------- owned bed ----------
	
	elseIf (!showBeginnerPrompt && !dogmeatScene && locHourChance.BedOwned)
	
		checkVal = DTSleep_IntimateCheckOwnedBedMsg.Show(sexAppealScore, daysSinceLastIntimate)
		
	; ------------ location uncertainty -----------------

	elseIf (!dogmeatScene && locHourChance.Chance <= -200)
	
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
			
		else
			; higher rank, Strong like meat!
			
			if (locHourChance.Chance > IntimateLocChancePerfectScore)
				checkVal = DTSleep_IntimateStrongCheckBonusPerfectMsg.Show(sexAppealScore, daysSinceLastIntimate)
			elseIf (locHourChance.Chance > IntimateLocChanceGoodScore)
				checkVal = DTSleep_IntimateStrongCheckBonusMsg.Show(sexAppealScore, daysSinceLastIntimate)
			elseIf (locHourChance.Chance > IntimateLocChancePoorScore)
				checkVal = DTSleep_IntimateStrongCheckBonusPoorMsg.Show(sexAppealScore, daysSinceLastIntimate)
			else
				checkVal = DTSleep_IntimateStrongCheckBonusRiskyMsg.Show(sexAppealScore, daysSinceLastIntimate)
			endIf
			
			
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
			checkVal = DTSleep_IntimateCheckFriendMsg.Show(sexAppealScore, daysSinceLastIntimate)
		elseIf (locHourChance.Chance > IntimateLocChancePoorScore)
			checkVal = DTSleep_IntimateCheckFriendPoorMsg.Show(sexAppealScore, daysSinceLastIntimate)
		else
			checkVal = DTSleep_IntimateCheckFriendRiskyMsg.Show(sexAppealScore, daysSinceLastIntimate)
		endIf
		
		
	elseIf (nearCompanion.RelationRank == 3)
	
		; infatuated
		if (locHourChance.Chance > IntimateLocChancePerfectScore)
			checkVal = DTSleep_IntimateInfatCheckPerfectMsg.Show(sexAppealScore, daysSinceLastIntimate)
		elseIf (locHourChance.Chance > IntimateLocChanceGoodScore)
			checkVal = DTSleep_IntimateInfatCheckMsg.Show(sexAppealScore, daysSinceLastIntimate)
		elseIf (locHourChance.Chance > IntimateLocChancePoorScore)
			checkVal = DTSleep_IntimateInfatCheckPoorMsg.Show(sexAppealScore, daysSinceLastIntimate)
		else
			checkVal = DTSleep_IntimateInfatCheckRiskyMsg.Show(sexAppealScore, daysSinceLastIntimate)
		endIf
		
	else
	
		; --- romantic companion  - default
		if (locHourChance.Chance > IntimateLocChancePerfectScore)
			checkVal = DTSleep_IntimateCheckLoverPerfectMsg.Show(sexAppealScore, daysSinceLastIntimate)
		elseIf (locHourChance.Chance > IntimateLocChanceGoodScore)
			checkVal = DTSleep_IntimateCheckMsg.Show(sexAppealScore, daysSinceLastIntimate)
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
		
	elseIf (nearbyActorEstimate > 1)
		checkVal = promptNPCWarn.Show(sexAppealScore, daysSinceLastIntimate, nearbyActorEstimate)
		
	elseIf (hoursSinceLastFail < 12.0 || hoursSinceLastIntimate < 12.0)
		
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

Function Shutdown(bool completely = false)
	
	Utility.WaitMenuMode(1.2)
	
	
	if (DTSleep_ShutdownConfirmMsg.Show() == 1)
		
		UnregisterForMenuOpenCloseEvent("WorkshopMenu")
		Utility.WaitMenuMode(0.1)
		DTSleep_SettingModActive.SetValue(-1.0)
		
		if (DTSleep_DogTrainQuestP.IsRunning())
			DTSleep_DogTrainQuestP.SetStage(60)  ; pause / hide display
		endIf
		
		if (DTSleep_IntimateTourQuestP.IsRunning())
			DTSleep_SettingTourEnabled.SetValue(0.0)
			(DTSleep_IntimateTourQuestP as DTSleep_IntimateTourQuestScript).UpdateLocationObjectiveDisplay()
		endIf

		PlayerSleepPerkRemove()
		
		DTSleep_SettingIntimate.SetValue(-1.0)
		
		(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).StopAll(false, -3)
		
		(SleepPlayerAlias as DTSleep_PlayerAliasScript).Shutdown()
		
		Utility.WaitMenuMode(0.7)
		
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

bool Function TestIntSceneEnabled()

	if (DTSleep_SettingTestMode.GetValue() > 0.0 && IntimacyTestCount < 5)
		
		float sceneCheckTime = DTSleep_SceneTestMode.GetValue()
		
		if (sceneCheckTime == 0.0 && SirTime == 2.290 && DTSleep_DebugMode.GetValue() >= 3.0)
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
	
	if (DTSleep_SettingTestMode.GetValue() > 0.0 && DTSleep_DebugMode.GetValue() >= 0.50)
	
		bool powerArmorGlitch = IsCompanionPowerArmorGlitched(IntimateCompanionRef)
	
		Debug.Trace(myScriptName + " =====================================================================")
		Debug.Trace(myScriptName + "       version: " + DTSleep_Version.GetValue() + " ---- TEST MODE ---- ")
		Debug.Trace(myScriptName + "  UndressQuest: " + DTSleep_IntimateUndressQuestP.IsRunning())
		Debug.Trace(myScriptName + "      Location: " + (SleepPlayerAlias as DTSleep_PlayerAliasScript).CurrentLocation)
		Debug.Trace(myScriptName + "     game time: " + Utility.GetCurrentGameTime())
		Debug.Trace(myScriptName + " Player Gender: " + DressData.PlayerGender)
		Debug.Trace(myScriptName + "genderSwapPerk: " + (DTSConditionals as DTSleep_Conditionals).HasGenderSwappedPerks)
		Debug.Trace(myScriptName + "    Rest Count: " + DTSleep_RestCount.GetValueInt())
		Debug.Trace(myScriptName + " ScnCount / Xp: " + IntimacySceneCount + " / " + DTSleep_IntimateEXP.GetValueInt())
		Debug.Trace(myScriptName + " IntTest count: " + IntimacyTestCount)
		Debug.Trace(myScriptName + "     Strong Xp: " + DTSleep_IntimateStrongExp.GetValueInt())
		Debug.Trace(myScriptName + "   self/dog Xp: " + DTSleep_IntimateDogEXP.GetValueInt())
		Debug.Trace(myScriptName + "  UndressReady: " + IsUndressReady)
		Debug.Trace(myScriptName + "      SleepBed: " + SleepBedInUseRef)
		Debug.Trace(myScriptName + "     Using Bed: " + DTSleep_PlayerUsingBed.GetValue())
		Debug.Trace(myScriptName + "     Undressed: " + DTSleep_PlayerUndressed.GetValue())
		Debug.Trace(myScriptName + "  IntCompanion: " + IntimateCompanionRef + " (PA glitch? " + powerArmorGlitch + ")")
		Debug.Trace(myScriptName + "      IntFails: " + IntimateCheckFailCount)
		Debug.Trace(myScriptName + "      LastFail: " + IntimateCheckLastFailTime)
		Debug.Trace(myScriptName + " self/dog Fail: " + IntimateCheckLastDogFailTime)
		Debug.Trace(myScriptName + "      LastSucc: " + DTSleep_IntimateTime.GetValue() + " / " + IntimateLastTime)
		Debug.Trace(myScriptName + "       LastHug: " + IntimateLastEmbraceTime)
		Debug.Trace(myScriptName + "   LastDogSucc: " + DTSleep_IntimateDogTime.GetValue())
		
		
		Debug.Trace(myScriptName + " =====================================================================")
		Debug.Trace(myScriptName + "    ----------- TEST MODE --- settings -------")
		Debug.Trace(myScriptName + "     AdultMode: " + DTSleep_AdultContentOn.GetValue())
		Debug.Trace(myScriptName + " AdultLeitoEVB: " + DTSleep_IsLeitoActive.GetValue())
		Debug.Trace(myScriptName + "       ZaZOut4: " + (SleepPlayerAlias as DTSleep_PlayerAliasScript).DTSleep_IsZaZOut.GetValue())
		Debug.Trace(myScriptName + "        AAF on: " + DTSleep_SettingAAF.GetValue())
		Debug.Trace(myScriptName + "   SeeYouSleep: " + DTSleep_IsSYSCWActive.GetValue() + " / " + DTSleep_SettingPrefSYSC.GetValue())
		Debug.Trace(myScriptName + "  Cancel Scene: " + DTSleep_SettingCancelScene.GetValue())
		Debug.Trace(myScriptName + "    Bed  Decor: " + DTSleep_SettingBedDecor.GetValue())
		Debug.Trace(myScriptName + "  Dog Restrain: " + DTSleep_SettingDogRestrain.GetValue())
		Debug.Trace(myScriptName + "      Intimate: " + DTSleep_SettingIntimate.GetValue())
		Debug.Trace(myScriptName + "       Undress: " + DTSleep_SettingUndress.GetValue())
		Debug.Trace(myScriptName + "        Camera: " + DTSleep_SettingCamera2.GetValue())
		Debug.Trace(myScriptName + "Immersive Rest: " + DTSleep_SettingNapOnly.GetValue())
		Debug.Trace(myScriptName + "      nap-comp: " + DTSleep_SettingNapComp.GetValue())
		Debug.Trace(myScriptName + "      nap-exit: " + DTSleep_SettingNapExit.GetValue())
		Debug.Trace(myScriptName + "   nap-recover: " + DTSleep_SettingNapRecover.GetValue())
		Debug.Trace(myScriptName + " Warn Busy Lov: " + DTSleep_SettingWarnLoverBusy.GetValue())
		Debug.Trace(myScriptName + "      nap-Save: " + DTSleep_SettingSave.GetValue())
		Debug.Trace(myScriptName + "   Gender Pref: " + DTSleep_SettingGenderPref.GetValue())
		Debug.Trace(myScriptName + "        Lover2: " + DTSleep_SettingLover2.GetValue())
		
	
		Debug.Trace(myScriptName + " =====================================================================")
		Debug.Trace(myScriptName + "         ----- TEST MODE ---- conditionals ----------")
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
		Debug.Trace(myScriptName + "       nwsBarb: " + (DTSConditionals as DTSleep_Conditionals).IsNWSBarbActive)
		Debug.Trace(myScriptName + "SmokableCigars: " + (DTSConditionals as DTSleep_Conditionals).IsSmokableCigarsActive)
		Debug.Trace(myScriptName + "   DX AtomGirl: " + (DTSConditionals as DTSleep_Conditionals).IsDXAtomGirlActive)
		Debug.Trace(myScriptName + "NukaBear index: " + (DTSConditionals as DTSleep_Conditionals).DXAtomGirlNukaBearIndex)
		Debug.Trace(myScriptName + "       Holoboy: " + (DTSConditionals as DTSleep_Conditionals).IsHoloboyActive)
		Debug.Trace(myScriptName + "Lacy Underwear: " + (DTSConditionals as DTSleep_Conditionals).IsLacyUnderwearActive)
		Debug.Trace(myScriptName + "    RangerGear: " + (DTSConditionals as DTSleep_Conditionals).IsRangerGearActive)
		Debug.Trace(myScriptName + "ProvisBackpack: " + (DTSConditionals as DTSleep_Conditionals).IsProvisionerBackPackActive)
		Debug.Trace(myScriptName + "         VIOso: " + (DTSConditionals as DTSleep_Conditionals).IsVioStrapOnActive)
		Debug.Trace(myScriptName + "     LeFO4Anim: " + (DTSConditionals as DTSleep_Conditionals).IsLeitoActive)
		Debug.Trace(myScriptName + "      CrazyGun: " + (DTSConditionals as DTSleep_Conditionals).IsCrazyAnimGunActive)
		Debug.Trace(myScriptName + "           AAF: " + (DTSConditionals as DTSleep_Conditionals).IsAAFActive)
		Debug.Trace(myScriptName + "   Atomic Lust: " + (DTSConditionals as DTSleep_Conditionals).IsAtomicLustActive)
		Debug.Trace(myScriptName + "   Atomic vers: " + (DTSConditionals as DTSleep_Conditionals).AtomicLustVers)
		Debug.Trace(myScriptName + "  Mutated Lust: " + (DTSConditionals as DTSleep_Conditionals).IsMutatedLustActive)
		Debug.Trace(myScriptName + " LeFO4Anim AAF: " + (DTSConditionals as DTSleep_Conditionals).IsLeitoAAFActive)
		Debug.Trace(myScriptName + " SavageCabbage: " + (DTSConditionals as DTSleep_Conditionals).IsSavageCabbageActive)
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
		Debug.Trace(myScriptName + " =====================================================================")
	endIf

endFunction



Function UnregisterForSleepBed(float bedUseCodeVal = 0.0)
	DTDebug(" UnregisterFroSleepBed code: " + bedUseCodeVal, 2)

	UnregisterForPlayerSleep()
	SleepBedRegistered = None
	DTSleep_PlayerUsingBed.SetValue(bedUseCodeVal)
endFunction

Function UpdateIntimateAnimPreferences(int playerChoice)


	; playerChoice -- see DTSleep_IntimateScenePickMessage for index

	if (playerChoice == 1)
		(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePlayerPrefCuddle()
	elseIf (playerChoice == 2)
		(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePlayerPrefStand()
	elseIf (playerChoice == 3)
		; this labeled in Message as 'Situational' since actually depends on genders
		(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePlayerPrefMissionary()
	elseIf (playerChoice == 4)
		(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePlayerPrefOral()
	elseIf (playerChoice == 5)
		(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePlayerPrefDoggy()
	elseIf (playerChoice == 6)
		(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePlayerPrefCowgirl()
	elseIf (playerChoice == 7)
		(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePlayerPrefSpoon()
	endIf

	if (IntimateCompanionRef != None)
	
		if ((DTSConditionals as DTSleep_Conditionals).NoraSpouseRef != None && IntimateCompanionRef == (DTSConditionals as DTSleep_Conditionals).NoraSpouseRef)
	
			(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePrefSpanking(true)
			if (playerChoice == 0)
				(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePlayerPrefCowgirl()
				(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePlayerPrefMissionary()
			else
				(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePrefCuddle(true)
				(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePrefCowgirl(true)
				(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePrefMissionary(true)
				(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePrefDoggy(false)
			endIf
			
		elseIf ((DTSConditionals as DTSleep_Conditionals).InsaneIvyRef != None && IntimateCompanionRef == (DTSConditionals as DTSleep_Conditionals).InsaneIvyRef)
			if (playerChoice == 0)
				(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePlayerPrefSpoon()
				(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePlayerPrefDoggy()
			else
				(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePrefCuddle(false)
				(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePrefCowgirl(false) 
				(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePrefDoggy()
			endIf
		elseIf (IntimateCompanionRef == CompanionPiperRef)
		
			(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePrefSpanking(true)
			
			if (playerChoice == 0)
				if (Utility.RandomInt(5, 10) > 7)
					(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePlayerPrefCuddle()
				endIf
				if (DressData.PlayerGender == 0)
					(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePlayerPrefCowgirl()
				endIf
				(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePlayerPrefStand()
				(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePlayerPrefMissionary()
			else
				(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePrefCuddle(true)
				(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePrefCowgirl(false) ; and hate scissors
				(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePrefCarry(true)
			endIf

			
		elseIf (IntimateCompanionRef == CompanionCaitRef)
			if (playerChoice == 0)
				(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePlayerPrefCowgirl()
				(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePlayerPrefOral()
			else
				(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePrefBlowJob()
				(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePrefCuddle(false)
				(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePrefMissionary(false)
				(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePrefCowgirl(true)
			endIf
			
		elseIf (IntimateCompanionRef == CompanionDanseRef)
			; normally stuck in power armor, but player have a mod
			if (playerChoice == 0)
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
		
			if (playerChoice == 0)
				(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePlayerPrefDoggy()
				(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePlayerPrefStand()
			else
				(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePrefMissionary(false)
				(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePrefDoggy()
				(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePrefBlowJob(false)
				(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePrefDance(true)
			endIf
				
		elseIf (IntimateCompanionRef == CompanionMacCreadyRef)
			if (playerChoice == 0)
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
			if (playerChoice == 0)
				(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePlayerPrefMissionary()
				(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePlayerPrefDoggy()
			else
				(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePrefDoggy()
				(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePrefCowgirl(false)
				(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePrefBlowJob(false)
				(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePrefDance(true)
			endIf
			
		elseIf (IntimateCompanionRef == CompanionX6Ref)
		
			if (playerChoice == 0)
				(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePlayerPrefOral()
			else
				(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePrefCuddle(false)
				(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePrefBlowJob()
				(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePrefCowgirl(false)
			endIf
			
		elseIf (IntimateCompanionRef == CurieRef)
			(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePrefSpanking(true)
			if (playerChoice == 0)
				(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePrefDoggy()
				(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePlayerPrefStand()
				(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePlayerPrefCowgirl()
			else
				(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePrefCuddle(true)
				(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePrefCowgirl()
				(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePrefBlowJob(false)
			endIf
			
		elseIf (IntimateCompanionRef == (DTSConditionals as DTSleep_Conditionals).NukaWorldDLCGageRef)
			if (playerChoice == 0)
				(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePrefBlowJob()
				(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePrefDoggy()
			else
				(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePrefCuddle(false)
				(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePrefBlowJob()
				(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).SetActorScenePrefMissionary(false)
			endIf
			
		elseIf ((DTSConditionals as DTSleep_Conditionals).IsCoastDLCActive && IntimateCompanionRef == (DTSConditionals as DTSleep_Conditionals).FarHarborDLCLongfellowRef)
			if (playerChoice == 0)
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

	if (PlayerRef.HasPerk(DTSleep_LoversEmbracePerk))
		float checkT = (DTSleep_HealthRecoverQuestP as DTSleep_HealthRecoverQuestScript).PlayerWellRestedTime
		
		if (checkT <= 0.0)
			LoverBonusRested(false)
		else
			float gameTime = Utility.GetCurrentGameTime()
			if (DTSleep_CommonF.GetGameTimeHoursDifference(gameTime, checkT) > 20.0)
				(DTSleep_HealthRecoverQuestP as DTSleep_HealthRecoverQuestScript).PlayerWellRestedTime = -3.0
				LoverBonusRested(false)
			endIf
		endIf
	endIf

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
	DTDebug(" stopping CompSleepQuest...", 1)
	
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
		StartTimer(2.0, DisableSleepDogPlacedTimerID)
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
	
	if (remFaction && IntimateCompanionRef != None && IntimateCompanionRef.IsInFaction(DTSleep_IntimateFaction))
		IntimateCompanionRef.RemoveFromFaction(DTSleep_IntimateFaction)
	endIf
	
	if (IntimateCompanionSecRef != None)
		if (IntimateCompanionSecRef.IsInFaction(DTSleep_IntimateFaction))
			DTDebug(" stop Intimate quest - removing 2nd lover from intimate faction", 2)
			IntimateCompanionSecRef.RemoveFromFaction(DTSleep_IntimateFaction)
		endIf
	endIf
	
	if (SleepBedDogPlacedRef != None)
		StartTimer(2.0, DisableSleepDogPlacedTimerID)
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
		if (DTSleep_DogIntimateRestAlias != None)
			DTSleep_DogIntimateRestAlias.Clear()
		endIf
		if (DTSleep_CompIntimateLover2Alias != None)
			DTSleep_CompIntimateLover2Alias.Clear()
		endIf
	endIf
	
	if (IntimateCompanionSecRef != None)
		IntimateCompanionSecRef.EvaluatePackage()
	endIf
	
	if (IntimateCompanionRef != None)
		IntimateCompanionRef.EvaluatePackage(true)
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
EndGroup
float IntimateLastEmbraceScoreTime ; not using