ScriptName DTSleep_IntimateAnimQuestScript extends Quest

; Sleep Intimate - animation scene setup quest
; DracoTorre
; https://www.dracotorre.com/mods/sleepintimate/
; https://github.com/Dracotorre/SleepIntimateV2
;
; controls animated sequences including character positioning for Idles, Leito, Crazy, or AAF
; usually with a bed involved.
;
; after setting up scene then launches a player to play sequences or idles
; DTSleep_PlayIdle 				- standard game idles: dances, clap, cheer
; DTSleep_PlayAAC				- (version 2) handles animated idles designed for AAF (all characters start without offsets)
; DTSleep_PlayAAFSceneScript 	- uses AAF API to play sequences
; DTSleep_PlayLeitoIdle			- plays Leito's animations with offset 70 (v1.4) or 0 (v2)
; DTSleep_PlayCrazyIdle			- plays animations by Crazy
;
;
; sequence IDs
;  <90 - generic game idles
;   90 -  99 - hugs/kisses included in Sleep Intimate; idles provided by TheRealRufgt
;  100 - 149 - Leito bed sequences 
;  150 - 199 - Leito standing sequences
;  200 - 249 - Crazy gun bed idles
;  250 - 299 - Crazy gun stand idles
;  300 - 399 - reserved
;  400 - 499 - CHAKPack
;  500 - 599 - "Atomic Lust" and "Mutated lust"  and Old Rufgt and "Raid My Heart"
;  600 - 599 - Leito v2 
;  700 - 799 - SavageCabbage 
;  800 - 899 - ZaZout4 
;  900 - 999 - Graymod and Gray's creature
; 1000 - 1099 - BP70
; 1100 - 1199 - Rohzima
;
; positioning -
; NPC positioning works best if near target and free of obstructions
;
;

import DTSleep_CommonF


;Quest property DTSleep_MainQuestP auto
DTSleep_SceneData property SceneData auto const
Quest property DTSConditionals auto const
Quest property DTSleep_PlayAAFSceneQuest auto const
Quest property DT_RandomQuestP auto const
ActorBase property DTSleep_PlayerClone auto const
ReferenceAlias property DTSleep_UndressPAlias auto
Armor property DTSleep_NudeRing auto const
Armor property DTSleep_AltFemBody auto const
GlobalVariable property TimeScale auto const						; added v3.08
GlobalVariable property GameHour auto								; added v3.08

Actor property CompStrongRef auto const
ActorValue property EnduranceAV auto const
;GlobalVariable property DTSleep_WasPlayerThirdPerson auto
GlobalVariable property DTSleep_AdultContentOn auto const
{ used as a backup for safety }
GlobalVariable property DTSleep_VR auto const						; VR-mode if 3  v3.0
GlobalVariable property DTSleep_IntimateIdleID auto
GlobalVariable property DTSleep_IntimateSceneLen auto
GlobalVariable property DTSleep_IntimateSceneMaxLenCount auto
GlobalVariable property DTSleep_IntimateTime auto
GlobalVariable property DTSleep_SettingAAF auto const
GlobalVariable property DTSleep_SettingTestMode auto const
GlobalVariable property DTSleep_DebugMode auto const
GlobalVariable property DTSleep_SettingUseLeitoGun auto const
GlobalVariable property DTSleep_SettingUseBT2Gun auto const
GlobalVariable property DTSleep_SettingCancelScene auto const
GlobalVariable property DTSleep_SettingFadeEndScene auto const
GlobalVariable property DTSleep_SettingAACV auto const
{ 0 = never clone, 1 = situational, 2 = situational-strict, 3 = always clone }
GlobalVariable property DTSleep_SettingGenderPref auto const
GlobalVariable property DTSleep_SettingAltFemBody auto const
GlobalVariable property DTSleep_PlayerCollisionEnabled auto					; added v2.70 to check to toggle collision check
GlobalVariable property DTSleep_SettingCollision auto const					; added v2.70 to allow player to enable/disable collisions
GlobalVariable property DTSleep_SettingPackPick auto const					; added v3.15 to allow player to limit scenes by pack ID
GlobalVariable property DTSleep_AAFMaxSID auto const							; added v3.16 --highest supported AAF SID value limit
Spell property DTSLeep_PlayIdleSpell auto const
Spell property DTSLeep_PlayIdleTargetSpell auto const
Spell property DTSleep_PlayLeitoTargetSpell auto const
Spell property DTSleep_PlayCrazyGTargetSpell auto const
Spell property DTSleep_SlowTime auto const
Spell property DTSleep_PlayCrazyRugTargetSpell auto const
Spell property DTSLeep_PlayAACSpell auto const
Spell property DTSleep_InvisibiltySpell auto const
Keyword Property AnimFurnFloorBedAnimKY auto const Mandatory
Keyword property AnimFurnCouchKY auto const
Keyword property AnimFurnBarStoolKY auto const
Keyword property AnimFurnEatingNoodlesKY auto const
Keyword property AnimFurnStoolWithBarKY auto const						; added v2.60
Keyword property AnimFurnChairSitAnimsKY auto const
Keyword property AnimFurnChairWithTableKY auto const
Keyword property AnimFurnChairWithRadioKY auto const
Keyword property AnimFurnLayDownUtilityBoxKY auto const
Keyword property AnimFurnPicnickTableKY auto const
Keyword property PowerArmorWorkBenchKY auto const
Keyword property HC_Obj_SleepingBagKY auto const
Keyword property ActorTypeChildKW auto const
Keyword Property isPowerArmorFrame Auto Const
Keyword property DTSleep_IntimateMEKeyword auto const
Keyword property DTSleep_DancePoleKY auto const
Keyword property DTSleep_SedanKeyword auto const
Keyword property DTSleep_MotorcycleKY auto const
Keyword property DTSleep_PoolTableKeyword auto const
Keyword property DTSleep_IntimateChairKeyword auto const
Keyword property DTSleep_SMBed02KY auto const
Keyword property IsSleepFurnitureKY auto const
Keyword property WorkbenchArmorKY auto const							; added v2.70
Keyword property DTSleep_IntimateLockerKeyword auto const				; v2.77
FormList property DTSleep_StrapOnList auto const
FormList property DTSleep_BedsBigList auto const
FormList property DTSleep_BedsBigDoubleList auto const 
FormList property DTSleep_BedsLimitedSpaceLst auto const
FormList property DTSleep_BedsBunkList auto const
FormList property DTSleep_BedBunkFrameList auto const
FormList property DTSleep_BedsInstituteDoubleList auto const			; addded v2.70
FormList property DTSleep_BedPillowFrameDBList auto const
FormList property DTSleep_BedPillowFrameSBList auto const
FormList property DTSleep_IntimateBenchAdjList auto const
{ bench with short backrest }
FormList property DTSleep_IntimateChairsList auto const
{ armchairs support lap dance }
FormList property DTSleep_IntimateCouchList auto const
FormList property DTSleep_IntimateCouchFedList auto const
FormList property DTSleep_IntimateChairHighList auto const
FormList property DTSleep_IntimateChairLowList auto const
FormList property DTSleep_IntimateChairArmSmList auto const					; v3.15
FormList property DTSleep_IntimateChairThroneList auto const
FormList property DTSleep_IntimateChairTooCloseList auto const
FormList property DTSleep_IntimateBenchList auto const
FormList property DTSleep_IntimateKitchenSeatList auto const
FormList property DTSleep_IntimateDeskList auto const
FormList property DTSleep_IntimateDiningTableList auto const
FormList property DTSleep_IntimatePoolTableList auto const
FormList property DTSleep_IntimateRoundTableList auto const
FormList property DTSleep_IntimateStoolBackList auto const
FormList property DTSleep_IntimateStoolNoAngleList auto const
FormList property DTSleep_IntimateTableList auto const
FormList property DTSleep_IntimateMotorcycleList auto const
{ motorcycle etc }
FormList property DTSleep_IntimateShowerList auto const
{ showers etc }
FormList property DTSleep_IntimateSedanPreWarList auto const
FormList property DTSleep_PilloryList auto const
FormList property DTSleep_TortureDList auto const
FormList property DTSleep_IntimatePicnicTLongList auto const		; v2.35
FormList property DTSleep_IntimateDinerBoothTableAllList auto const	;
FormList property DTSleep_IntimateSMBedList auto const				;
FormList property DTSleep_IntimateChairOttomanList auto const 		; v2.40
FormList property DTSleep_IntimateKitchenCounterList auto const 	; v2.40
FormList property DTSleep_IntimateKitchenCabinetList auto const 	; v3.15
FormList property DTSleep_IntimateDoorJailList auto const			; 
FormList property DTSleep_JailAllList auto const
FormList property DTSleep_JailTinyList auto const
FormList property DTSleep_JailSmallList auto const					;
FormList property DTSleep_JailReversedLocList auto const			; v2.40 
FormList property DTSleep_JailDoorwayAltLocList auto const			; v2.40
FormList property DTSleep_JailDoor2AltLoclList auto const				;
FormList property DTSleep_JailDoorTinyLocList auto const			; v2.43
FormList property DTSleep_IntimateDesk90List auto const				; v2.51
FormList property DTSleep_IntimateWorkbenchWLargeList auto const	; v2.70
FormList property DTSleep_IntimatePierRailingList auto const		; v2.70
FormList property DTSleep_IntimateCouchLimSpaceList auto const		; v2.73
FormList property DTSleep_IntimateLockerList auto const				; v2.77
FormList property DTSleep_IntimateLockerAdjList auto const			; 
FormList property DTSleep_IntimateStoveList auto const 				; added v2.84
FormList property DTSleep_IntimatePatioTableList auto const			; added v2.88
{ deprecated }
FormList property DTSleep_IntimatePatioTwoTableList auto const		; correction v3.0 for 2.90
FormList property DTSleep_IntimateCouchHighBackList auto const		; added v2.90
FormList property DTSleep_IntimateBenchNoBackList auto const		; added v3.15
FormList property DTSleep_IntimateBenchShortList auto const			; v3.15
FormList property DTSleep_IntimateCouchMemList auto const			; added v3.15 -- like memory lounge style
FormList property DTSleep_IntimateChairHighNoArmsList auto const	; added v3.15 -- federalist (dining?)
Static property DTSleep_MainNode auto const Mandatory
Static property DTSleep_DummyNode auto const Mandatory
ObjectReference property JailDoor1Quincy1Ref auto const
ObjectReference property JailDoor1Quincy2Ref auto const
ObjectReference property JailDoor1Quincy3Ref auto const
Idle property LooseIdleStop auto const
{ not used }
Idle property LooseIdleStop2 auto const

ObjectReference property DN130_CambridgePDJailDoor03 auto const

ImageSpaceModifier property HoldAtBlackImod auto const
ImageSpaceModifier property FadefromBlackImod auto const

; ---------------- hidden --------------

ObjectReference property SleepBedRef auto hidden
ObjectReference property SleepBedTwinRef auto hidden
ObjectReference property SleepBedTempRef auto hidden
ObjectReference property SleepBedAltRef auto hidden
ObjectReference property MainActorOriginMarkRef auto hidden
ObjectReference property SecondActorOriginMarkRef auto hidden
Location property SleepBedLocation auto hidden				; v2.40
bool property SleepBedIsPillowBed = false auto hidden
int property SecondActorScenePref auto hidden		
{ now only picked - using array for list }
int property SecondActorSceneHate auto hidden
{ now only picked - using array for list }
Actor property MainActorRef auto hidden
Actor property MainActorCloneRef auto hidden
Actor property SecondActorRef auto hidden
bool property HasToyEquipped auto hidden
bool property FadeEnable auto hidden
bool property MainActorPositionByCaller auto hidden
bool property MainActorIsReverseHeading = false auto hidden
bool property PlaySlowTime auto hidden
float property SleepBedShiftedDown auto hidden
bool property HoldToBlackIsSetOn auto hidden
bool property PlaceInBedOnFinish auto hidden
bool property SceneIsPlaying auto hidden
int property MainActorMovedCount auto hidden
int property RestrictScenesToErectAngle = -1 auto hidden
int property MSceneChangedAAFSetting = -1 auto hidden
bool property PlayAAFEnabled = true auto hidden
int property MySleepBedFurnType = -1 auto hidden			; see FurnType* constants below
int property PlayerEndurance = -1 auto hidden  ; v2.90
bool property SleepBedIsHidden = false auto hidden 		; v3.03
float property SceneStartGameTime = 0.0 auto hidden		; ensure intimate scene lasts enough game-time -- v3.08
float property SceneWaitDuration = 0.0 auto hidden		; keep track of partial hours to update Wait stat -- v3.09




; ----------- local --------------

CustomEvent IntimateSequenceDoneEvent

int FadeAndPlayTimerID = 99 const
int SeqEndTimerID = 101 const
int StopMeTimerID = 102 const
int DisableCleanUpTimerID = 103 const
int HoldToBlackClearTimerID = 104 const
int CheckRemoveToysTimerID = 105 const
float AnimActorOffsetDef = 70.0 const
string MyScriptName = "[DTSleep_IAnim]" const

; floor beds
int FurnTypeIsCoffin = 197 const
int FurnTypeIsSleepingBag = 198 const
int FurnTypeIsFloorBed = 199 const
; regular beds
int FurnTypeIsBedSingle = 200 const
int FurnTypeIsDoubleBed = 201 const
int FurnTypeIsBunkBed = 202 const
int FurnTypeIsLimitedSpaceBed = 203 const
int FurnTypePillowBedHasFrame = 204 const
; seats
int FurnTypeIsSeatBasic = 220 const
int FurnTypeIsSeatIntimateChair = 221 const
int FurnTypeIsSeatBench = 222 const
int FurnTypeIsSeatHigh = 223 const
int FurnTypeIsSeatLow = 224 const
int FurnTypeIsSeatSofa = 225 const
int FurnTypeIsSeatKitchen = 226 const
int FurnTypeIsSeatThrone = 227 const
int FurnTypeIsSeatStool = 228 const
int FurnTypeIsSeatOttoman = 229 const
int FurnTypeIsSeatLowArmRest = 230 const				; v3.15
; tables
int FurnTypeIsTableDesk = 250 const
int FurnTypeIsTableDining = 251 const
int FurnTypeIsTableDinerBooth = 252 const
int FurnTypeIsTablePicnic = 253 const
int FurnTypeIsTablePool = 254 const
int FurnTypeIsTableRound = 255 const
int FurnTypeIsTableTable = 256 const
int FurnTypeIsTablePatio = 257 const ; v2.88

; other furniture
int FurnTypeIsPillory = 300 const
int FurnTypeIsPARepair = 301 const
int FurnTypeIsWeightBench = 302 const
int FurnTypeIsMotorCycle = 305 const
int FurnTypeIsSMBed = 307 const
int FurnTypeIsSedanPostWar = 308 const
int FurnTypeIsSedanPreWar = 309 const
int FurnTypeIsShower = 310 const
int FurnTypeIsTableKitchenCounter = 311 const
int FurnTypeIsJail = 312 const
int FurnTypeIsWorkbenchArmor = 313 const
int FurnTypeIsWorkBenchWeaponLarge = 314 const
int FurnTypeIsRailing = 315 const
int FurnTypeIsLocker = 316 const	; v2.77
int FurnTypeIsStove = 317 const		; v2.84
int FurnTypeIsTableKitchenCabinet = 318 const   ; v3.15

; scene preference constants to make easier to read   - v3.0
int ScenePrefIsMission = 501 const
int ScenePrefIsDoggy = 502 const
int ScenePrefIsSixtyNine = 503 const
int ScenePrefIsCowgirl = 504 const
int ScenePrefIsCowboy = 503
int ScenePrefIsCowgirlRev = 506 const
int ScenePrefIsScissors = 507 const
int ScenePrefIsSpoon = 510 const
int ScenePrefSoloPair = 548 const
int ScenePrefisAnal = 549 const
int ScenePrefIsOral = 550 const
int ScenePrefIsCunn = 551 const
int ScenePrefIsStand = 553 const
int ScenePrefIsCarry = 554 const
int ScenePrefIsSpank = 555 const
int ScenePrefIsDance = 595 const
int ScenePrefIsCuddle = 598 const
int ScenePrefIsKiss = 599 const



InputEnableLayer DTSleepIAQInputLayer ;
int CheckRemoveToysCount = 0
int LastSceneID = -1				; reduce repeat scenes at bed
int LastScenePrevID = -1
int LastSceneOtherID = -1			; reduce repeat scenes at other furniture
int LastSceneOtherPrevID = -1		; added v3.13 to reduce seat repeats
int LastSceneKissID = -1			; reduce repeat kiss scenes - v3.02
int LastSceneHugId = -1

int[] SecondActorScenePrefArray
int[] SecondActorSceneHateArray
int[] MainActorScenePrefArray
Form[] MainActorOutfitArray

; access using functions PlayerPrefSceneAdd* PlayerPrefSceneRemoveSID			- v2.70
int[] PlayerPrefSceneCloneNoSIDArray		; player preference never clone on default Scene View
int[] PlayerPrefSceneCloneOKSIDArray		;                   okay to clone on default
int PlayerPrefSceneCloneInit = -1

; player-added scene IDs to ignore   -v2.73
int[] MySceneIgnoreArray					; use SetSceneIDToIgnore() to add an ID
int[] MyLastSceneListArray


; *************************** Events *************
;
Event OnQuestInit()
	; do nothing
EndEvent

Event OnTimer(int aiTimerID)

	if (aiTimerID == FadeAndPlayTimerID)
		FadeAndPlay(DTSleep_IntimateIdleID.GetValueInt())
	elseIf (aiTimerID == SeqEndTimerID)
		FinalizeAndSendFinish()
		
	elseIf (aiTimerID == DisableCleanUpTimerID)
		DoDisableCleanUp()
	elseIf (aiTimerID == HoldToBlackClearTimerID)
		HoldAtBlackImod.Remove()
		FadefromBlackImod.Remove()
	elseIf (aiTimerID == CheckRemoveToysTimerID)
		CheckRemoveToys()
	elseIf (aiTimerID == StopMeTimerID)
		StopAll()
	endIf
EndEvent

Event OnMenuOpenCloseEvent(string asMenuName, bool abOpening)

    if (asMenuName== "PipboyMenu")
		
		if (SceneData.Interrupted <= 0)
			SceneData.Interrupted = 7						; v2.70 changed to 7 for player cancled using Pip-boy
			StartTimer(2.5, SeqEndTimerID)
		endIf
		UnregisterForMenuOpenCloseEvent("PipboyMenu")
		
	elseIf (asMenuName == "WorkshopMenu")
		SceneData.Interrupted = 1
		StartTimer(1.5, SeqEndTimerID)
		UnregisterForMenuOpenCloseEvent("WorkshopMenu")
	endIf
EndEvent

Event DTSleep_PlayAAFSceneScript.SleepIntAAFPlayDoneEvent(DTSleep_PlayAAFSceneScript akSender, Var[] akArgs)
	if (DTSleep_SettingTestMode.GetValue() > 0.0 && DTSleep_DebugMode.GetValue() >= 2.0)
		Debug.Trace(MyScriptName + " OnAAFPlay done event ")
	endIf

	if (akArgs != None && akArgs.Length >= 3)
		
		UnregisterForCustomEvent((DTSleep_PlayAAFSceneQuest as DTSleep_PlayAAFSceneScript), "SleepIntAAFPlayDoneEvent")
		
		bool startedOK = true
		int errCount = 0
		
		if (akArgs != None && akArgs.Length >= 4)
			bool isCanceled = akArgs[1] as bool
			errCount = akArgs[3] as int
			if (isCanceled && errCount >= 1)
				startedOK = false
			endIf
		endIf
		
		if (SceneIsPlaying)
			CancelTimer(SeqEndTimerID)
			if (!startedOK)									; v1.80 - try again without AAF
				
				(DTSleep_PlayAAFSceneQuest as DTSleep_PlayAAFSceneScript).StopAnimationSequence(false)
				; v2.73 do not try again, just stop and let Main handle
				
				;DTSleep_SettingAAF.SetValueInt(0)
				;MSceneChangedAAFSetting = 0
				;Utility.Wait(1.0)
				;FadeAndPlay(DTSleep_IntimateIdleID.GetValueInt())
			endIf
			
			FinalizeAndSendFinish(startedOK, errCount)
		endIf
	endIf
EndEvent

Event OnHit(ObjectReference akTarget, ObjectReference akAggressor, Form akSource, Projectile akProjectile, bool abPowerAttack, \
  bool abSneakAttack, bool abBashAttack, bool abHitBlocked, string apMaterial)
  
	if (SceneData.Interrupted <= 0 && SceneIsPlaying && MainActorRef.IsInCombat())		; v2.24 added combat check
		SceneData.Interrupted = 4
		if (DTSleep_SettingTestMode.GetValue() >= 1)
			Debug.Trace(myScriptName + " on hit " + akTarget + " by aggressor " + akAggressor)
		endIf
		StartTimer(1.5, SeqEndTimerID)
	endIf
EndEvent

Function InitPlayerPrefSceneArrays()
	PlayerPrefSceneCloneInit = 1
	PlayerPrefSceneCloneNoSIDArray = new int[0]
	PlayerPrefSceneCloneOKSIDArray = new int[0]
endFunction

; ******************* Start / Stop  **************************

bool Function CancelScene()

	if (SceneIsPlaying && SceneData.Interrupted <= 0)
		SceneData.Interrupted = 2
		if (DTSleep_SettingTestMode.GetValue() >= 2)
			Debug.Trace(myScriptName + " CancelScene called " )
		endIf
		StartTimer(1.5, SeqEndTimerID)
		return true
	endIf

	return false
endFunction

; setup here and then select a Play* function to begin sequence-
; caller should fade-out and if set this will fade-in when ready then out when done
; listen for done event
;
bool Function StartForActorsAndBed(Actor mainActor, Actor secondActor, ObjectReference bedRef, bool fadeInOut, bool mainActorPositioned = false, bool slowTime = false)
	SleepBedRef = bedRef
	SleepBedAltRef = None
	SleepBedTwinRef = None
	SleepBedTempRef = None
	SleepBedLocation = None
	MainActorRef = None
	MainActorCloneRef = None
	MainActorScenePrefArray = new int[0]			; reset -- in Papyrus array cannot be None, so checking None same as checking Length zero
	SecondActorRef = None
	SecondActorScenePref = -1
	SecondActorSceneHate = -1
	SecondActorScenePrefArray = new int[0]
	SecondActorSceneHateArray = new int[0]
	self.HasToyEquipped = false
	MainActorOriginMarkRef = None
	MainActorPositionByCaller = mainActorPositioned
	PlaySlowTime = slowTime
	SceneData.Interrupted = 0
	SceneIsPlaying = false
	MainActorMovedCount = 0
	CheckRemoveToysCount = 0
	RestrictScenesToErectAngle = -1
	MSceneChangedAAFSetting = -1
	MySleepBedFurnType = -2
	
	
	if (PlayerPrefSceneCloneInit <= 0)
		InitPlayerPrefSceneArrays()
	endIf
	
	SceneData.MarkerOrientationAllowance = 0
	SceneData.IntimateSceneIsDanceHug = 0
	SceneData.IntimateSceneViewType = 0					; reset; added in v2.70
	
	;-------------------------------
	; check pack-pick pref   v3.15
	;
	int packLimitPrefVal = DTSleep_SettingPackPick.GetValueInt()
	if (packLimitPrefVal > 0)
		if (DTSleep_AdultContentOn.GetValue() < 2.0)
			DTSleep_SettingPackPick.SetValueInt(0)
			
		elseIf (packLimitPrefVal == 6 || packLimitPrefVal == 1)
			; which Leito pack?
			if ((DTSConditionals as DTSleep_Conditionals).IsLeitoAAFActive)
				DTSleep_SettingPackPick.SetValueInt(6)
			elseIf ((DTSConditionals as DTSleep_Conditionals).IsLeitoActive)
				DTSleep_SettingPackPick.SetValueInt(1)
			else
				DTSleep_SettingPackPick.SetValueInt(0)
			endIf
			
		elseIf (packLimitPrefVal == 5)
			if (!(DTSConditionals as DTSleep_Conditionals).IsAtomicLustActive && !(DTSConditionals as DTSleep_Conditionals).IsRufgtActive)
				DTSleep_SettingPackPick.SetValueInt(0)
			endIf
		elseIf (packLimitPrefVal == 7)
			if (!(DTSConditionals as DTSleep_Conditionals).IsSavageCabbageActive)
				DTSleep_SettingPackPick.SetValueInt(0)	
			endIf
		elseIf (packLimitPrefVal == 9)
			if (!(DTSConditionals as DTSleep_Conditionals).IsGrayAnimsActive)
				DTSleep_SettingPackPick.SetValueInt(0)
			endIf
		elseIf (packLimitPrefVal == 10)
			if (!(DTSConditionals as DTSleep_Conditionals).IsBP70Active)
				DTSleep_SettingPackPick.SetValueInt(0)
			endIf
		elseIf (packLimitPrefVal == 11)
			if (!(DTSConditionals as DTSleep_Conditionals).IsRZSexActive)
				DTSleep_SettingPackPick.SetValueInt(0)
			endIf
		else
			DTSleep_SettingPackPick.SetValueInt(0)
		endIf
	endIf
	; ------- done pack-pick check
	
	if (mainActor != None && !mainActor.WornHasKeyword(isPowerArmorFrame))
		MainActorRef = mainActor
		PlayerEndurance = (mainActor.GetValue(EnduranceAV) as int)		; v2.90
	else
		StartTimer(2.0, StopMeTimerID)
		return false
	endIf
	if (secondActor != None)
		if (secondActor.WornHasKeyword(isPowerArmorFrame))
			if (SceneData.CompanionInPowerArmor)
				SecondActorRef = secondActor
			endIf
		else
			SecondActorRef = secondActor
		endIf
	endIf
	if (HoldToBlackIsSetOn)
		FadeEnable = true
	else
		FadeEnable = fadeInOut
	endIf

	return true
endFunction

; also sets SceneData.AnimationSet based on scene ID obtained
; returns -2 for too few scenes, or -1 for no compatible scenes
;
int Function SetAnimationPacksAndGetSceneID(int[] animSetsArray, bool hugsOnly = false, int sidPref = -1)

	int seqID = -1
	int includeHugs = 0
	
	if (hugsOnly)
		includeHugs = 2
	endIf
	
	SceneData.IntimateSceneIsDanceHug = 0
	
	; if pillow bed has a frame, use the frame and unmark pillow
	;
	if (SleepBedIsPillowBed && SleepBedRef != None)
		ObjectReference bedFrameRef = DTSleep_CommonF.FindNearestAnyBedFromObject(SleepBedRef, DTSleep_BedPillowFrameDBList, None, 86.0)
		if (bedFrameRef != None)
			SleepBedIsPillowBed = false
			SleepBedAltRef = bedFrameRef
		else
			bedFrameRef = DTSleep_CommonF.FindNearestAnyBedFromObject(SleepBedRef, DTSleep_BedPillowFrameSBList, None, 86.0)
			if (bedFrameRef != None)
				SleepBedIsPillowBed = false
				SleepBedAltRef = bedFrameRef
			endIf
		endIf
	endIf
	
	if (SceneData.MaleRole && SceneData.FemaleRole)

		bool noLeitoGun = false
		bool mainActorIsMaleRole = false
		
		if (MainActorRef == SceneData.MaleRole)
			mainActorIsMaleRole = true
		endIf
		
		
		if (SleepBedRef != None)
			
			seqID = PickIntimateSceneID(mainActorIsMaleRole, SceneData.PreferStandOnly, animSetsArray, includeHugs, sidPref)
			
			if (seqID == -2)
				if (DTSleep_SettingTestMode.GetValue() > 0.0 && DTSleep_DebugMode.GetValue() >= 2.0)
					Debug.Trace(myScriptName + " too few scene selections so hug/dance")
				endIf
				seqID = 99
				
			elseIf (seqID == -1)
				if (DTSleep_SettingTestMode.GetValue() > 0.0 && DTSleep_DebugMode.GetValue() >= 2.0)
					Debug.Trace(myScriptName + " no compatible scene found ")
				endIf
			endIf
		else
			Debug.Trace(myScriptName + " no bed found")
		endIf
	endIf

	return seqID
endFunction

int Function GetLastSceneCount()

	return MyLastSceneListArray.Length
endFunction	

bool Function GetIsOnIgnoreListSceneID(int sid)
	if (sid >= 100 && MySceneIgnoreArray.Length > 0 && MySceneIgnoreArray.Find(sid) >= 0)
		return true
	endIf
	
	return false
endFunction

int Function SetSceneIDToIgnore(int sid)
	
	if (sid >= 100 && sid < 2000)
		if (MySceneIgnoreArray.Length == 0)
			MySceneIgnoreArray = new int[1]
			MySceneIgnoreArray[0] = sid
			Debug.Trace(myScriptName + " adding scene " + MySceneIgnoreArray[0] + " to ignore list")
		
			return 1
		endIf
		if (MySceneIgnoreArray.Find(sid) < 0)
			MySceneIgnoreArray.Add(sid)
			Debug.Trace(myScriptName + " adding scene " + sid + " to ignore list for total of " + MySceneIgnoreArray.Length)
		
			return MySceneIgnoreArray.Length
		endIf
	endIf
	
	return 0
endFunction

int Function SetSceneIDToIgnoreClearAll()
	int len = MySceneIgnoreArray.Length
	if (len > 0)
		MySceneIgnoreArray.Clear()
	endIf
	
	return len
endFunction

Function StopAll(bool fadeIn = false)
	if (DTSleep_SettingTestMode.GetValue() > 0.0 && DTSleep_DebugMode.GetValue() >= 3.0)
		Debug.Trace(MyScriptName + " StopAll ")
	endIf
	;SleepBedRef = None					v2.70 keep so we can check last bed
	SleepBedIsPillowBed = false
	SleepBedAltRef = None
	PlayAAFEnabled = true
	PlayerEndurance = -2					; reset v2.90
	
	UnregisterForMenuOpenCloseEvent("PipboyMenu")
	UnregisterForMenuOpenCloseEvent("WorkshopMenu")
	if (MainActorRef != None)
		UnregisterForHitEvent(MainActorRef)
	endIf
	
	;SleepBedTempRef = None
	MainActorRef = None
	SecondActorRef = None
	FadeEnable = false
	SceneIsPlaying = false
	MainActorMovedCount = 0
	
	if (HoldToBlackIsSetOn)
		
		if (fadeIn)
			FadeInSec(1.0)
		else
			FadeInSec(0.1)
		endIf
		
	endIf
	
	if (DTSleepIAQInputLayer != None)
		DTSleepIAQInputLayer.EnablePlayerControls()
		Utility.Wait(0.02)
		DTSleepIAQInputLayer.Delete()
		DTSleepIAQInputLayer = None
	endIf
	
	; do not stop quest
endFunction

; ************************* get/set ***********************************
;

bool Function AnimationSetSupportsZeX(int animSet)

	if (animSet == 5)
		return true
	elseIf (animSet == 7) ;&& animSet <= 8) ; oddly enough ZaZOut doesn't support ZeX
		return true
	elseIf (animSet == 10)
		return true
	endIf

	return false
endFunction

bool Function BunkBedAdultScenesAvailable(bool sameGender)
	if ((DTSConditionals as DTSleep_Conditionals).IsSavageCabbageActive && (DTSConditionals as DTSleep_Conditionals).SavageCabbageVers >= 1.10 && !sameGender)
		return true
	elseIf ((DTSConditionals as DTSleep_Conditionals).IsAtomicLustActive)
		return true
	elseIf ((DTSConditionals as DTSleep_Conditionals).IsRufgtActive && sameGender)
		return true
	endIf
	
	return false
endFunction

bool Function DoesMainActorPrefID(int prefID)

	return DTSleep_CommonF.IsIntegerInArray(prefID, MainActorScenePrefArray)
endFunction

bool Function DoesSecondActorPrefID(int prefID)
	
	return DTSleep_CommonF.IsIntegerInArray(prefID, SecondActorScenePrefArray)
endFunction

bool Function DoesSecondActorHateID(int prefID)
	
	return DTSleep_CommonF.IsIntegerInArray(prefID, SecondActorSceneHateArray)
endFunction

; returns sceneID or -1 for none
int Function GetFurnitureSupportDanceSexy(ObjectReference aFurnObjRef, Form baseFurnForm)

	if (aFurnObjRef != None)
		if ((DTSConditionals as DTSleep_Conditionals).IsSavageCabbageActive && (DTSConditionals as DTSleep_Conditionals).ImaPCMod)
			if (aFurnObjRef.HasKeyword(DTSleep_IntimateChairKeyword))
				return 739
			endIf
			if (baseFurnForm == None)
				baseFurnForm = aFurnObjRef.GetBaseObject()
			endIf
			if (DTSleep_IntimateChairsList.HasForm(baseFurnForm))
				return 739
			endIf
		endIf
	endIf

	return -1
endFunction

; return -1 for none, 0=FMM, 1=FMF, 2=M/F (FMM or FMF)
int Function GetFurnitureSupportExtraActorForPacks(ObjectReference aFurnObjRef, Form baseFurnForm, int[] packs, bool isPillowBed = false)

	int packLimiVal = DTSleep_SettingPackPick.GetValueInt()			; limit animation pack v3.15
	
	if (aFurnObjRef != None)
		
		if (aFurnObjRef.HasKeyword(IsSleepFurnitureKY))
			if (aFurnObjRef.HasKeyword(AnimFurnLayDownUtilityBoxKY))
				return -1
			endIf
			bool limitedSpace = false
			if (baseFurnForm == None)
				baseFurnForm = aFurnObjRef.GetBaseObject()
			endIf
			limitedSpace = IsObjBedLimitedSpace(aFurnObjRef, baseFurnForm)
			
			if (!limitedSpace)
				if (packs.Length == 0)
					
					if ((DTSConditionals as DTSleep_Conditionals).IsSavageCabbageActive && (packLimiVal <= 0 || packLimiVal == 7))
						
						if (IsSleepingDoubleBed(aFurnObjRef, baseFurnForm, isPillowBed))
							
							return 2
			
						elseIf ((DTSConditionals as DTSleep_Conditionals).SavageCabbageVers >= 1.10)
							if (IsSleepingBunkBed(aFurnObjRef, baseFurnForm, isPillowBed))
								return 0			; fix only FMM; changed from 2 -- v2.70
							endIf
						endIf
						
						if ((DTSConditionals as DTSleep_Conditionals).AtomicLustVers >= 2.43)
							return 2
						endIf
						
						return 0

					elseIf ((DTSConditionals as DTSleep_Conditionals).AtomicLustVers >= 2.43 && (packLimiVal <= 0 || packLimiVal == 5))
						return 2
					endIf
					
				elseIf (DTSleep_CommonF.IsIntegerInArray(7, packs) && (packLimiVal <= 0 || packLimiVal == 7))
					if (IsSleepingDoubleBed(aFurnObjRef, baseFurnForm, isPillowBed))
						
						return 2
						
					elseIf ((DTSConditionals as DTSleep_Conditionals).SavageCabbageVers >= 1.10)
						if (IsSleepingBunkBed(aFurnObjRef, baseFurnForm, isPillowBed))
							return 0   ; change to only FMM v2.90
						endIf
					endIf
					
					return 0
				
				elseIf (DTSleep_CommonF.IsIntegerInArray(5, packs) && (packLimiVal <= 0 || packLimiVal == 5))
					return 2
				endIf
			endIf
		elseIf (aFurnObjRef.HasKeyword(PowerArmorWorkBenchKY))
			return -1
			
		elseIf (aFurnObjRef.HasKeyword(WorkbenchArmorKY))			; v3.15
			
			; actors slide around - not using
			;if ((DTSConditionals as DTSleep_Conditionals).IsRZSexActive && !GetIsOnIgnoreListSceneID(1193))
			;	return 0
			;endIf
			return -1
			
		elseIf ((DTSConditionals as DTSleep_Conditionals).ZaZPilloryKW != None && aFurnObjRef.HasKeyword((DTSConditionals as DTSleep_Conditionals).ZaZPilloryKW))
			if ((DTSConditionals as DTSleep_Conditionals).IsSavageCabbageActive && (packLimiVal <= 0 || packLimiVal == 7))
				return 0
			endIf
			return -1
		elseIf ((DTSConditionals as DTSleep_Conditionals).DLC05PilloryKY != None && aFurnObjRef.HasKeyword((DTSConditionals as DTSleep_Conditionals).DLC05PilloryKY))
			if ((DTSConditionals as DTSleep_Conditionals).IsSavageCabbageActive && (DTSConditionals as DTSleep_Conditionals).SavageCabbageVers >= 1.10 && (packLimiVal <= 0 || packLimiVal == 7))
				return 0
			endIf
			return -1
		endIf
		if (baseFurnForm == None)
			baseFurnForm = aFurnObjRef.GetBaseObject()
		endIf
		if (aFurnObjRef.HasKeyword(DTSleep_IntimateChairKeyword) || DTSleep_IntimateChairsList.HasForm(baseFurnForm))
			if (DTSleep_CommonF.IsIntegerInArray(7, packs) && (packLimiVal <= 0 || packLimiVal == 7))
				return 0
			endIf
		elseIf (DTSleep_IntimateCouchList.HasForm(baseFurnForm))
			if (DTSleep_CommonF.IsIntegerInArray(7, packs) && (packLimiVal <= 0 || packLimiVal == 7))
				return 0
			endIf
		elseIf (DTSleep_TortureDList.HasForm(baseFurnForm))
			if (DTSleep_CommonF.IsIntegerInArray(7, packs) && (packLimiVal <= 0 || packLimiVal == 7))
				return 0
			endIf
		endIf
	endIf
	
	return -1
endFunction

; return negative, 0 for male-only, 1 for female-only-with-toy, 2 for female-only-no-toy-needed, 3 any/all --- v2.73
int Function GetFurnitureSupportSameGender(ObjectReference aFurnObjRef, Form baseForm)

	; do not limit by pack-pref
	
	if (aFurnObjRef != None)
		
		if (aFurnObjRef.HasKeyword(IsSleepFurnitureKY))
			return 3
		endIf
		
		if (IsObjSeat(aFurnObjRef) && (DTSConditionals as DTSleep_Conditionals).LeitoAnimVers >= 2.1)
			if (baseForm == None)
				baseForm = aFurnObjRef.GetBaseObject()
			endIf
		
			if (aFurnObjRef.HasKeyword(DTSleep_IntimateChairKeyword) || DTSleep_IntimateChairsList.HasForm(baseForm))
				return 1
			elseIf (IsObjBenchSofa(aFurnObjRef, baseForm))
				return 1
			elseIf (DTSleep_IntimateChairHighList.HasForm(baseForm))
				return 1
			elseIf (DTSleep_IntimateKitchenSeatList.HasForm(baseForm))
				return 1
			elseIf (DTSleep_IntimateChairLowList.HasForm(baseForm))
				return 1
			endIf
		endIf
		
		if ((DTSConditionals as DTSleep_Conditionals).IsLeitoAAFActive || (DTSConditionals as DTSleep_Conditionals).IsLeitoActive || (DTSConditionals as DTSleep_Conditionals).IsAtomicLustActive)
			if (IsObjPoolTable(aFurnObjRef, baseForm))
				return 3
			endIf
			
			if (aFurnObjRef.HasKeyword(AnimFurnPicnickTableKY))
				return 3
			endIf
		elseIf ((DTSConditionals as DTSleep_Conditionals).IsBP70Active)
			if (aFurnObjRef.HasKeyword(AnimFurnPicnickTableKY))
				return 3
			endIf
		endIf
	endIf
	
	return -1
endFunction

bool Function HasEmbracePacks()
	if ((DTSConditionals as DTSleep_Conditionals).IsCHAKPackActive)
		return true
	endIf
	
	return false
endFunction

bool Function PlayerPrefSceneAddSIDCloneOkay(int sid)
	if (PlayerPrefSceneCloneInit <= 0)
		InitPlayerPrefSceneArrays()
	endIf
	if (PlayerPrefSceneCloneOKSIDArray.Find(sid) < 0)
		PlayerPrefSceneCloneOKSIDArray.Add(sid)
		return true
	endIf
	
	return false
endFunction

bool Function PlayerPrefSceneAddSIDNoClone(int sid)
	if (PlayerPrefSceneCloneInit <= 0)
		InitPlayerPrefSceneArrays()
	endIf
	if (PlayerPrefSceneCloneNoSIDArray.Find(sid) < 0)
		PlayerPrefSceneCloneNoSIDArray.Add(sid)
		return true
	endIf
	
	return false
endFunction

bool Function PlayerPrefSceneClear()
	if (PlayerPrefSceneCloneInit > 0)
		PlayerPrefSceneCloneNoSIDArray.Clear()
		PlayerPrefSceneCloneOKSIDArray.Clear()
		return true
	endIf
	return false
endFunction


bool Function PlayerPrefSceneSIDOnCloneList(int sid)
	if (PlayerPrefSceneCloneInit > 0 && PlayerPrefSceneCloneOKSIDArray.Find(sid) >= 0)
		return true
	endIf
	return false
endFunction

bool Function PlayerPrefSceneSIDOnNoCloneList(int sid)
	if (PlayerPrefSceneCloneInit > 0 && PlayerPrefSceneCloneNoSIDArray.Find(sid) >= 0)
		return true
	endIf
	return false
endFunction

bool Function PlayerPrefSceneRemoveSID(int sid)
	if (PlayerPrefSceneCloneInit > 0)
		int idx = PlayerPrefSceneCloneOKSIDArray.Find(sid)
		if (idx >= 0)
			PlayerPrefSceneCloneOKSIDArray.Remove(idx)
			return true
		endIf
		idx = PlayerPrefSceneCloneNoSIDArray.Find(sid)
		if (idx >= 0)
			PlayerPrefSceneCloneNoSIDArray.Remove(idx)
			return true
		endIf
	endIf
	return false
endFunction

int Function PlayerPrefSceneTotalCount()
	int count = PlayerPrefSceneCloneNoSIDArray.Length
	count += PlayerPrefSceneCloneOKSIDArray.Length
	
	return count
endFunction

Function SetActorScenePlayerPrefAnal()
	MainActorScenePrefArray.Add(ScenePrefIsAnal)
endFunction

Function SetActorScenePlayerPrefSpanking()
	MainActorScenePrefArray.Add(ScenePrefIsSpank)
endFunction

Function SetActorScenePlayerPrefSoloShow()
	MainActorScenePrefArray.Add(ScenePrefSoloPair)
endFunction

; or manual
Function SetActorScenePrefBlowJob(bool lovesIt = true)
	if (lovesIt)
		SecondActorScenePrefArray.Add(ScenePrefIsOral)
		SecondActorScenePref = ScenePrefIsOral
	else
		SecondActorSceneHate = ScenePrefIsOral
		SecondActorSceneHateArray.Add(ScenePrefIsOral)
	endIf
endFunction

; or manual
Function SetActorScenePlayerPrefOral()
	MainActorScenePrefArray.Add(ScenePrefIsOral)
endFunction

Function SetActorScenePrefCuddle(bool lovesIt = true)
	if (lovesIt)
		SecondActorScenePrefArray.Add(ScenePrefIsCuddle)
		SecondActorScenePref = ScenePrefIsCuddle
	else
		SecondActorSceneHate = ScenePrefIsCuddle
		SecondActorSceneHateArray.Add(ScenePrefIsCuddle)
	endIf

endFunction

Function SetActorScenePlayerPrefCuddle()
	MainActorScenePrefArray.Add(ScenePrefIsCuddle)	; use to check cuddle preference 

endFunction

Function SetActorScenePrefDance(bool lovesIt = true)
	if (lovesIt)
		SecondActorScenePrefArray.Add(ScenePrefIsDance)
		SecondActorScenePref = ScenePrefIsDance
	else
		SecondActorSceneHate = ScenePrefIsDance
		SecondActorSceneHateArray.Add(ScenePrefIsDance)
	endIf

endFunction

Function SetActorScenePrefCarry(bool lovesIt = true)
	if (lovesIt)
		SecondActorScenePrefArray.Add(ScenePrefIsCarry)
		SecondActorScenePref = ScenePrefIsCarry
	else
		SecondActorSceneHate = ScenePrefIsCarry
		SecondActorSceneHateArray.Add(ScenePrefIsCarry)
	endIf
endFunction

Function SetActorScenePlayerPrefStand()
	MainActorScenePrefArray.Add(ScenePrefIsStand)
endFunction

Function SetActorScenePrefDoggy(bool lovesIt = true)

	if (lovesIt)
		SecondActorScenePrefArray.Add(ScenePrefIsDoggy)
		SecondActorScenePref = ScenePrefIsDoggy
	else
		SecondActorSceneHate = ScenePrefIsDoggy
		SecondActorSceneHateArray.Add(ScenePrefIsDoggy)
	endIf
endFunction

Function SetActorScenePlayerPrefDoggy()				
	MainActorScenePrefArray.Add(ScenePrefIsDoggy)
endFunction

; for FF this is Scissors
Function SetActorScenePrefCowgirl(bool lovesIt = true)
	if (lovesIt)
		SecondActorScenePrefArray.Add(ScenePrefIsCowboy)
		SecondActorScenePrefArray.Add(ScenePrefIsCowgirl)
		SecondActorScenePrefArray.Add(ScenePrefIsScissors)
		SecondActorScenePref = ScenePrefIsCowgirl
	else
		SecondActorSceneHate = ScenePrefIsCowgirl
		SecondActorSceneHateArray.Add(ScenePrefIsCowgirl)
		SecondActorSceneHateArray.Add(ScenePrefIsCowboy)
		SecondActorSceneHateArray.Add(ScenePrefIsScissors)
	endIf
endFunction

Function SetActorScenePlayerPrefCowgirl()
	MainActorScenePrefArray.Add(ScenePrefIsCowgirl)
	MainActorScenePrefArray.Add(ScenePrefIsCowboy)
endFunction

Function SetActorScenePlayerPrefCunn()
	MainActorScenePrefArray.Add(ScenePrefIsCunn)
endFunction

Function SetActorScenePlayerPrefScissors()
	MainActorScenePrefArray.Add(ScenePrefIsScissors)
endFunction

Function SetActorScenePlayerPrefSixNine()
	MainActorScenePrefArray.Add(ScenePrefIsSixtyNine)
endFunction

Function SetActorScenePrefMissionary(bool lovesIt = true)
	if (lovesIt)
		SecondActorScenePref = ScenePrefIsMission
		SecondActorScenePrefArray.Add(ScenePrefIsMission)
		SecondActorScenePrefArray.Add(1)
	else
		SecondActorSceneHate = ScenePrefIsMission
		SecondActorSceneHateArray.Add(ScenePrefIsMission)
	endIf
endFunction

Function SetActorScenePlayerPrefMissionary()
	MainActorScenePrefArray.Add(ScenePrefIsMission)
endFunction

Function SetActorScenePlayerPrefSpoon()
	MainActorScenePrefArray.Add(ScenePrefIsSpoon)
endFunction

Function SetActorScenePrefSpanking(bool lovesIt = true)
	if (lovesIt)
		SecondActorScenePref = ScenePrefIsSpank
		SecondActorScenePrefArray.Add(ScenePrefIsSpank)
	else
		SecondActorSceneHate = ScenePrefIsSpank
		SecondActorSceneHateArray.Add(ScenePrefIsSpank)
	endIf
endFunction

; *****************Play Functions **************

bool Function PlayActionIntimateSeq(int seqID)
	self.HasToyEquipped = false  ; only flag (CheckActors) if equip toy to remove at end

	if (MainActorRef == None)
		return false
	endIf
	
	if (DTSleep_AdultContentOn.GetValue() <= 0.0)
		return false
	endIf
	
	if (!(DTSConditionals as DTSleep_Conditionals).ImaPCMod)
		return false
	endIf
	
	if (!CheckActorsIntimateCompatible(seqID))
		if (DTSleep_SettingTestMode.GetValue() > 0.0 && DTSleep_DebugMode.GetValue() >= 2.0)
			Debug.Trace(MyScriptName + " PlayActionIntimate failed compatible check for id " + seqID)
		endIf
		return false
	endIf
	
	SceneStartGameTime = Utility.GetCurrentGameTime()    	; to check if scene lasts long enough -- v3.08
	
	
	if (SceneData.MaleRole != None && SceneData.FemaleRole != None)

		bool noLeitoGun = false
		bool mainActorIsMaleRole = false
		
		if (MainActorRef == SceneData.MaleRole)
			mainActorIsMaleRole = true
		endIf
		
		if (seqID == 739 || seqID == 741)					; v2.48
			SceneData.IntimateSceneIsDanceHug = 1
		else
			SceneData.IntimateSceneIsDanceHug = 0
		endIf
		
		if (SleepBedRef != None)
			
			if (seqID >= 100 && SceneData.AnimationSet > 0)
			
				if (DTSleep_SettingTestMode.GetValue() > 0.0 && DTSleep_DebugMode.GetValue() >= 1.0)
					Debug.Trace(myScriptName + " -------------------------------------------------- ")
					Debug.Trace(myScriptName + " Test-Mode output - may disable in Settings ")
					Debug.Trace(MyScriptName + " playIntimate bed: " + SleepBedRef + ", player positioned? " + MainActorPositionByCaller + ", prefer stand? " + SceneData.PreferStandOnly)
					Debug.Trace(myScriptName + " seqID: " + seqID + " for animSet: " + SceneData.AnimationSet)
					DebugLogSceneData()
					Debug.Trace(myScriptName + " -------------------------------------------------- ")
				endIf
				
				if (seqID >= 795 && seqID <= 796)
					int doorState = SleepBedRef.GetOpenState()
					if (doorState >= 1 && doorState <= 2)
						SleepBedRef.SetOpen(false)
						Utility.Wait(0.5)
					endIf
				endIf

				FadeAndPlay(seqID, mainActorIsMaleRole)
				
				return true
				
			elseIf (seqID == -2)
				if (DTSleep_SettingTestMode.GetValue() > 0.0 && DTSleep_DebugMode.GetValue() >= 1.0)
					Debug.Trace(myScriptName + " too few scene selections so random choose return fail for default embrace")
				endIf
			elseIf (DTSleep_SettingTestMode.GetValue() > 0.0 && DTSleep_DebugMode.GetValue() >= 1.0)
				Debug.Trace(myScriptName + " PlayAction no compatible scene found ")
			endIf
		else
			Debug.Trace(myScriptName + " no bed found")
			CheckRemoveToys()
			;int id = 201
			;if (compatibleCheck >= 2)
			;	id = Utility.RandomInt(200, 201)
			;endIf
			;FadeAndPlay(id)
		endIf
	endIf
	
	return false
endFunction

bool Function PlayActionDancing(bool isRomantic = false)

	if (SceneData.IsUsingCreature || SceneData.CompanionInPowerArmor)
		SecondActorRef = None
	endIf
	if (MainActorRef == None)
		return false
	endIf
	
	if (SceneData.ToyArmor != None)
		CheckRemoveToys(false, true)
	endIf
	
	int sid = 11					; default random dance
	if (isRomantic && SecondActorRef != None)	; v3.22 fix only if have 2 actors
		sid = 91
	endIf
	
	SceneData.IntimateSceneIsDanceHug = 2
	SceneStartGameTime = Utility.GetCurrentGameTime()		; to check dance lasted long enough -v3.08
	
	; v3.22 fix check for second actor
	if (isRomantic && SecondActorRef != None && FadeEnable && (DTSConditionals as DTSleep_Conditionals).IsCHAKPackActive)			; v3.0
		if (Utility.RandomInt(1,10) > 5)
			sid = 494
		endIf
	endIf
	
	if (DTSleep_SettingTestMode.GetValue() > 0.0 && DTSleep_DebugMode.GetValue() >= 1.0)
		Debug.Trace(myScriptName + " -------------------------------------------------- ")
		Debug.Trace(myScriptName + " Test-Mode output - may disable in Settings ")
		Debug.Trace(MyScriptName + " play Dancing, furniture: " + SleepBedRef + ", isRomantic? " + isRomantic)
		DebugLogSceneData()
		Debug.Trace(myScriptName + " -------------------------------------------------- ")
	endIf
	
	if (SleepBedRef != None && FadeEnable)
	
		bool mainActorIsMaleRole = true
		
		if (DTSleep_CommonF.IsActorOnBed(MainActorRef, SleepBedRef))
			mainActorIsMaleRole = false
			MainActorPositionByCaller = true
		endIf
		
		;if (MainActorPositionByCaller || MainActorRef == SceneData.MaleRole)
		;	mainActorIsMaleRole = true
		;endIf

		FadeAndPlay(sid, mainActorIsMaleRole)
		
		return true
		
	elseIf (SleepBedRef != None && IsObjBed(SleepBedRef))
		LastScenePrevID == LastSceneID
		LastSceneID = sid
		SceneData.IntimateSceneViewType = 0
	endIf
	
	return PlayIdleAnimationID(sid, GetTimeForPlayID(sid))
endFunction

bool Function PlayActionHugs(bool seatIsSpecial = false)

	if (MainActorRef == None || SceneData.CompanionInPowerArmor || SecondActorRef == None)	; v2.17 corrected for creature and synth
		return false
	elseIf (SceneData.IsUsingCreature && SceneData.IsCreatureType < 3)
		return false
	endIf
	
	bool hasExtraHugs = HasEmbracePacks()					; v3.0
	int sid = 99
	int[] sidArray = new int[0]
	
	if (!seatIsSpecial)
		sidArray.Add(99)
		sidArray.Add(95)
	endIf
	
	SceneData.AnimationSet = 0
	SceneData.IntimateSceneIsDanceHug = 3
	SceneStartGameTime = -1.0			; do not check time for hug -- v3.08
	ClearSecondActors()
	
	if (SceneData.ToyArmor != None)
		CheckRemoveToys(false, true)
	endIf
	
	if (hasExtraHugs || seatIsSpecial)

		SceneIDArrayPrepMyFurnitureType()		; v3.0
		sidArray = SceneIDArrayForAnimationSet(-3, false, true, true, sidArray, 3)
	endIf
	
	UpdateMyLastScenes(siDArray)
	
	if (MyLastSceneListArray.Length > 0)
		sid = MyLastSceneListArray[Utility.RandomInt(0, MyLastSceneListArray.Length - 1)]
		if (sid == LastSceneHugID && MyLastSceneListArray.Length > 1)
			sid = MyLastSceneListArray[Utility.RandomInt(0, MyLastSceneListArray.Length - 1)]
		endIf
	endIf
	
	
	if (sid >= 100)
		int p = Math.Floor(((sid) as float) / 100.0)
		SceneData.AnimationSet = p
	endIf
	
	LastSceneHugID = sid

	
	if (DTSleep_SettingTestMode.GetValue() > 0.0 && DTSleep_DebugMode.GetValue() >= 1.0)
		Debug.Trace(myScriptName + " -------------------------------------------------- ")
		Debug.Trace(myScriptName + " Test-Mode output - may disable in Settings ")
		Debug.Trace(myScriptName + " scenes: " + MyLastSceneListArray)
		Debug.Trace(myScriptName + "   orig: " + sidArray)
		Debug.Trace(MyScriptName + " play Hugs (" + sid + "), furniture: " + SleepBedRef + ", special? " + seatIsSpecial + ", prefer stand? " + SceneData.PreferStandOnly)
		DebugLogSceneData()
		Debug.Trace(myScriptName + " -------------------------------------------------- ")
	endIf
	
	if (SceneIDAtPlayerPosition(sid) && DTSleep_VR.GetValueInt() < 2 && DTSleep_SettingAACV.GetValueInt() < 3)
		MainActorPositionByCaller = true
	endIf

	if (FadeEnable)
		FadeAndPlay(sid, false)
		
		return true
	else
		SceneData.IntimateSceneViewType = 0
	endIf

	return PlayIdleAnimationID(sid, GetTimeForPlayID(99))
endFunction

; added v2.90
bool Function PlayActionKiss(int intimateSettingVal, bool seatIsSpecial = false)
	if (MainActorRef == None || SceneData.CompanionInPowerArmor || SecondActorRef == None)	; v2.17 corrected for creature and synth
		return false
	elseIf (SceneData.IsUsingCreature && SceneData.IsCreatureType < 3)
		return false
	endIf
	
	bool hasExtraHugs = HasEmbracePacks()					; v3.0
	
	SceneData.AnimationSet = 0
	SceneData.IntimateSceneIsDanceHug = 3
	SceneStartGameTime = -2.0						; do not check time for kiss -- v3.08
	ClearSecondActors()
	
	if (SceneData.ToyArmor != None)
		CheckRemoveToys(false, true)
	endIf
	
	if (SceneData.SameGender)
		if (MainActorRef != SceneData.MaleRole)
			; same-gender kiss works best with player-character in male role
			SceneData.FemaleRole = SecondActorRef
			SceneData.MaleRole = MainActorRef
		endIf
	endIf
	
	int sid = 98
	int[] sidArray = new int[0]
	
	if (!seatIsSpecial)
		siDArray.Add(98)
		sidArray.Add(94)
		if (DTSleep_AdultContentOn.GetValueInt() >= 2 && intimateSettingVal < 3)  ;v3.04 make sure R-only
			sidArray.Add(97)
		endIf
	endIf
	
	if (hasExtraHugs || seatIsSpecial)
		
		SceneIDArrayPrepMyFurnitureType()		; v3.0
		sidArray = SceneIDArrayForAnimationSet(-3, false, true, true, sidArray, 4)
	endIf
	
	UpdateMyLastScenes(siDArray)

	if (MyLastSceneListArray.Length > 0)
		sid = MyLastSceneListArray[Utility.RandomInt(0, MyLastSceneListArray.Length - 1)]
		if (sid == LastSceneKissID && sidArray.Length > 1)
			sid = MyLastSceneListArray[Utility.RandomInt(0, MyLastSceneListArray.Length - 1)]
		endIf
	endIf
	
	if (DTSleep_SettingTestMode.GetValue() > 0.0 && DTSleep_DebugMode.GetValue() >= 1.0)
		Debug.Trace(myScriptName + " -------------------------------------------------- ")
		Debug.Trace(myScriptName + " Test-Mode output - may disable in Settings ")
		Debug.Trace(myScriptName + " scenes: " + MyLastSceneListArray)
		Debug.Trace(myScriptName + "   orig: " + sidArray)
		Debug.Trace(MyScriptName + " play Kiss (" + sid + "), furniture: " + SleepBedRef + ", special? " + seatIsSpecial + ", prefer stand? " + SceneData.PreferStandOnly)
		DebugLogSceneData()
		Debug.Trace(myScriptName + " -------------------------------------------------- ")
	endIf
	
	
	if (sid >= 100)
		int p = Math.Floor(((sid) as float) / 100.0)
		SceneData.AnimationSet = p
	endIf
	
	LastSceneKissID = sid
	
	if (SceneIDAtPlayerPosition(sid) && DTSleep_VR.GetValueInt() < 2 && DTSleep_SettingAACV.GetValueInt() < 3)
		MainActorPositionByCaller = true
	endIf

	if (FadeEnable)
		FadeAndPlay(sid, false)
		
		return true
	else
		SceneData.IntimateSceneViewType = 0
	endIf

	return PlayIdleAnimationID(sid, GetTimeForPlayID(sid))
endFunction

bool Function PlayActionDancePole()

	if (MainActorRef == None || SleepBedRef == None || ((DTSConditionals as DTSleep_Conditionals).SavageCabbageVers < 1.1))
		Debug.Trace(myScriptName + " PlayActionDancePole missing requirements")
		return false
	endIf
	if (!SleepBedRef.HasKeyword(DTSleep_DancePoleKY))
		return false
	endIf
	if (SceneData.RaceRestricted == 9)
		Debug.Trace(myScriptName + " PlayActionDancePole RaceRestricted ")
		return false
	endIf
	
	SceneData.AnimationSet = 7
	SceneData.IntimateSceneIsDanceHug = 1				; v2.48
	SceneStartGameTime = -1.0					; do not check pole-dance time -- v3.08
	ClearSecondActors()
	
	if (SceneData.ToyArmor != None)
		CheckRemoveToys(false, true)
	endIf
	
	if (DTSleep_SettingTestMode.GetValue() > 0.0 && DTSleep_DebugMode.GetValue() >= 1.0)
		Debug.Trace(myScriptName + " -------------------------------------------------- ")
		Debug.Trace(myScriptName + " Test-Mode output - may disable in Settings ")
		Debug.Trace(MyScriptName + " play DancePole - pole: " + SleepBedRef)
		DebugLogSceneData()
		Debug.Trace(myScriptName + " -------------------------------------------------- ")
	endIf

	if (FadeEnable)
	
		FadeAndPlay(741, false)
		
		return true
	endIf

	return false
endFunction

bool Function PlayActionDanceSexy()

	if (MainActorRef == None || SleepBedRef == None || (DTSConditionals as DTSleep_Conditionals).IsSavageCabbageActive == false)
		return false
	endIf
	if (SceneData.RaceRestricted == 9)					; v2.60
		return false
	endIf
	if (SceneData.IsUsingCreature)						; v2.60 allow synth or other race to sit in chair
		if (SceneData.IsCreatureType != 3 && SceneData.IsCreatureType != 4 && SceneData.IsCreatureType != 7)
			return false
		endIf
	elseIf (SceneData.CompanionInPowerArmor)
		return false
	endIf
	if (!IsObjSeat(SleepBedRef))
		if (IsObjBed(SleepBedRef) || IsObjectDancePole(SleepBedRef))
			return false
		endIf
	endIf
	if (DTSleep_AdultContentOn.GetValue() < 1.0)
		return false
	endIf
	if (!(DTSConditionals as DTSleep_Conditionals).ImaPCMod)
		return false
	endIf
	
	SceneData.AnimationSet = 7
	SceneData.IntimateSceneIsDanceHug = 1				; v2.48
	SceneStartGameTime = Utility.GetCurrentGameTime()               ; to check if scene lasts long enough -- v3.08
	ClearSecondActors()
	
	CheckRemoveToys(false, true)
	
	if (DTSleep_SettingTestMode.GetValue() > 0.0 && DTSleep_DebugMode.GetValue() >= 1.0)
		Debug.Trace(myScriptName + " -------------------------------------------------- ")
		Debug.Trace(myScriptName + " Test-Mode output - may disable in Settings ")
		Debug.Trace(MyScriptName + " play DanceSexy LapDance: " + SleepBedRef)
		DebugLogSceneData()
		Debug.Trace(myScriptName + " -------------------------------------------------- ")
	endIf

	if (FadeEnable)
	
		FadeAndPlay(739, false)
		
		return true
	endIf
	
	return false
endFunction

bool Function PlayActionXOXO(bool seatisSpecial = false)

	if (MainActorRef == None || SceneData.CompanionInPowerArmor || SecondActorRef == None)	; v2.17 corrected for creature and synth
		return false
	elseIf (SceneData.IsUsingCreature && SceneData.IsCreatureType < 3 && SceneData.IsCreatureType > 0)
		return false
	endIf
	
	if (SceneData.SameGender)
		if (MainActorRef != SceneData.MaleRole)
			; same-gender kiss works best with player-character in male role
			SceneData.FemaleRole = SecondActorRef
			SceneData.MaleRole = MainActorRef
		endIf
	endIf
	
	bool hasExtraHugs = HasEmbracePacks()					; v3.0
	int[] sidArray = new int[2]
	
	sidArray[0] = 97
	sidArray[1] = 94
	
	if (!seatIsSpecial && !hasExtraHugs)
		siDArray.Add(98)
	endIf
	
	
	SceneData.AnimationSet = 0
	SceneData.IntimateSceneIsDanceHug = 0    ; v2.48 imagination sex -- not considered a hug
	SceneStartGameTime = Utility.GetCurrentGameTime()      ; to check if scene lasts long enough -- v3.08
	ClearSecondActors()
	if (SceneData.ToyArmor != None)
		CheckRemoveToys(false, true)
	endIf
	
	
	int id = 97		; hug-and-kiss make default v2.90
	
	if (seatisSpecial || LastSceneID == 97 || hasExtraHugs)
	
		if (seatisSpecial || hasExtraHugs)
			SceneIDArrayPrepMyFurnitureType()		; v3.0
		endIf
		sidArray = SceneIDArrayForAnimationSet(-3, false, true, true, sidArray, 2)
		
		UpdateMyLastScenes(siDArray)
		
		
		if (sidArray.Length == 1)			; v2.60 fix - sometimes returned single
			id = sidArray[0]
			
		elseIf (MyLastSceneListArray.Length > 1)
			id = MyLastSceneListArray[Utility.RandomInt(0, MyLastSceneListArray.Length - 1)]
		endIf
		
		if (SleepBedRef != None && IsObjBed(SleepBedRef))			; reduce repeated hugs at bed  v2.84.1--v3.0 no longer should
			if (id == 99 && LastSceneID == 99)
				id = 97
			endIf

			LastSceneID = id
		endIf
		
		if (id < 90 || (id >= 100 && id < 400) || (id >= 500 && id != 780 && id != 535))
			Debug.Trace(myScriptName + " found invalid hug/kiss id (" + id + ") - force 97 ")
			id = 97
		endIf
	endIf
	
	if ((DTSConditionals as DTSleep_Conditionals).IsVulpineRacePlayerActive)				; v2.60 bad fit big nose
		if (id >= 97 && id <= 98)
			id = 99 ; hug
		endIf
	endIf
	
	if (DTSleep_SettingTestMode.GetValue() > 0.0 && DTSleep_DebugMode.GetValue() >= 1.0)
		Debug.Trace(myScriptName + " -------------------------------------------------- ")
		Debug.Trace(myScriptName + " Test-Mode output - may disable in Settings ")
		Debug.Trace(myScriptName + " scenes: " + MyLastSceneListArray)
		Debug.Trace(myScriptName + "   orig: " + sidArray)
		Debug.Trace(MyScriptName + " play XOXO - " + id + ", bed: " + SleepBedRef + ", prefer stand? " + SceneData.PreferStandOnly)
		DebugLogSceneData()
		Debug.Trace(myScriptName + " -------------------------------------------------- ")
	endIf
	
	
	if (SceneIDAtPlayerPosition(id) && DTSleep_VR.GetValueInt() < 2 && DTSleep_SettingAACV.GetValueInt() < 3)
		MainActorPositionByCaller = true
	endIf

	if (FadeEnable)
	
		FadeAndPlay(id, false)
		
		return true
	else
		SceneData.IntimateSceneViewType = 0
	endIf

	return PlayIdleAnimationID(id, GetTimeForPlayID(id))
endFunction


ObjectReference StartPosNode = None

; v2.35 - self pleasure scenes
bool Function PlayActionIntimateSoloSeq(int gender)

	if (MainActorRef == None)
		return false
	endIf
	
	if (DTSleep_AdultContentOn.GetValue() < 2.0)
		return false
	endIf
	
	if (!(DTSConditionals as DTSleep_Conditionals).ImaPCMod)
		return false
	endIf
	
	if (SceneData.RaceRestricted == 9)
		return false
	endIf
	
	SecondActorRef = None
	
	int sceneID = 0
	int[] sidArray = new int[0]
	
	if ((DTSConditionals as DTSleep_Conditionals).IsAtomicLustActive)
		
		sceneID = 540
		sidArray.Add(540)
	endIf
	
	; crazy untested for solo  --- requires 2
	;if ((DTSConditionals as DTSleep_Conditionals).IsCrazyAnimGunActive)
		
	;	sidArray.Add(250)
	;endIf
	
	
	if (SleepBedRef != None && IsObjBed(SleepBedRef) && (DTSConditionals as DTSleep_Conditionals).IsSavageCabbageActive)
		
		Form baseBedForm = None 
		if (gender == 1 && IsSleepingDoubleBed(SleepBedRef, baseBedForm))
			sidArray.Add(799)
		;elseIf (gender == 0)
		;	sidArray.Add(798) TODO:
		endIf

	endIf
	
	if (sidArray.Length > 0)
		SceneData.IntimateSceneIsDanceHug = 1
		
		if (sidArray.Length == 1)
			sceneID = sidArray[0]
		else
			int rand = Utility.RandomInt(0, sidArray.Length - 1)
			sceneID = sidArray[rand]
		endIf
		if (sceneID >= 100)
			int p = Math.Floor(((sceneID) as float) / 100.0)
			SceneData.AnimationSet = p
		else
			SceneData.AnimationSet = 0
		endIf
	endIf
	
	if (DTSleep_SettingTestMode.GetValue() > 0.0 && DTSleep_DebugMode.GetValue() >= 1.0)
		Debug.Trace(myScriptName + " -------------------------------------------------- ")
		Debug.Trace(myScriptName + " Test-Mode output - may disable in Settings ")
		Debug.Trace(MyScriptName + " play Solo Intimate ID " + sceneID + ", bed: " + SleepBedRef)
		DebugLogSceneData()
		Debug.Trace(myScriptName + " -------------------------------------------------- ")
	endIf
	
	if (sceneID > 0 && SleepBedRef != None && FadeEnable)

		if (SceneIDAtPlayerPosition(sceneID))
			MainActorPositionByCaller = true
		endIf
		FadeAndPlay(sceneID)
		
		return true
	else
		SceneData.IntimateSceneViewType = 0
	endIf
	
	return PlayIdleAnimationID(sceneID, GetTimeForPlayID(sceneID))
endFunction


bool Function PlayActionReactionRand()
	bool result = false
	;int rand = Utility.RandomInt(-2, 3)
	int rand = (DT_RandomQuestP as DT_RandomQuestScript).GetNextInRangePublic(-2, 3)
	
	if (rand >= 0)
		result = PlayIdleAnimationID(rand, 2.5)
	endIf
	if (!result)
		StartTimer(2.0, StopMeTimerID)
	endIf
	return result
endFunction

; ******************** public / general functions **************

Function DebugLogSceneData()
	Debug.Trace(myScriptName + ", roles: " + SceneData.MaleRole + "(gender:" + SceneData.MaleRoleGender +  "), " + SceneData.FemaleRole + "(sameGender? " + SceneData.SameGender + ")")
	Debug.Trace(myScriptName + ", extra roles (M, F): " + SceneData.SecondMaleRole + ", " + SceneData.SecondFemaleRole)
	Debug.Trace(myScriptName + "  Toy/equip? " + SceneData.HasToyAvailable + "/" + SceneData.HasToyEquipped + ", AnimationSet: " + SceneData.AnimationSet + ", creature? " + SceneData.IsUsingCreature + ", companionPowerArmor? " + SceneData.CompanionInPowerArmor)
	Debug.Trace(myScriptName + "  PlaceInBedOnFinish? " + PlaceInBedOnFinish + " -- twinBed? " + SleepBedTwinRef)
endFunction

; ******************** Internal Functions **********************



; ensure actors support scenes
; - human
; - male/female, female/female with strap-on
bool Function CheckActorsIntimateCompatible(int seqID)
	bool result = false
	if (MainActorRef != None)
	
		if (SecondActorRef == None)								; v2.82 re-order first
			return false
		elseIf (seqID == 741 && SceneData.RaceRestricted < 9)
			result = true
		elseIf (SceneData.CompanionInPowerArmor)
			result = true
		endIf
		
		if (!result && !ActorsIntimateCompatible())
			return false
		endIf
		
		if (SceneData.IsUsingCreature && SceneData.IsCreatureType != 3)		; v2.82 3-Synth not okay
			result = true
		endIf
		
		if (!Debug.GetPlatformName() as bool)
			return false
		endIf
		
		CheckRemoveToysCount = 0

		if (SceneData.MaleRole != None && SceneData.FemaleRole != None)
		
			if (SceneData.SameGender)
				if (SceneData.AnimationSet == 4 || SceneData.AnimationSet == 5 || SceneData.AnimationSet == 7 || SceneData.AnimationSet == 10)
					; v3.0 added pack 4 
					if (SceneData.HasToyEquipped && SceneData.ToyArmor != None)
						CheckRemoveToys(false, true)
					endIf
					return true
				
				elseIf (SceneData.MaleRoleGender == 1)
					; v3.15 changes for pack 11
					; v3.20 added PA-Repair 1138
					; v3.21 added desk-spank 1141
					; v3.22 moved to another fuction
					if (SceneIDToyArmorNotOkay(seqID))
						if (SceneData.HasToyEquipped && SceneData.ToyArmor != None)
							CheckRemoveToys(false, true, true)
						endIf
						return true
						
					elseIf (SceneData.HasToyAvailable && SceneData.ToyArmor != None)
					
						if (!SceneData.HasToyEquipped)
							; assumed MaleRole has item in inventory else this adds an item
							SceneData.MaleRole.EquipItem(SceneData.ToyArmor, false, true)				; v3.17 changed Prevent-to-false
							
							SceneData.HasToyEquipped = true
							if (DTSleep_SettingTestMode.GetValue() > 0.0 && DTSleep_DebugMode.GetValue() >= 2.0)
								Debug.Trace(myScriptName + " equip toy and mark to remove later ")
							endIf
							Utility.WaitMenuMode(0.1)
							
							self.HasToyEquipped = true  ; flag so we can remove later
						endIf
						
						return true
					endIf
				else
					; 2 males
					return true
				endIf
			else
				if (SceneData.HasToyEquipped && SceneData.ToyArmor != None)
					CheckRemoveToys(false, true)
				endIf
				return true
			endIf
		endIf
	endIf
	
	return result
endFunction

Function CheckRemoveToys(bool allowRetry = true, bool forceRem = false, bool notAllowed = false)
	if (self.HasToyEquipped || forceRem)
		int index = 0
		bool searchList = false
		
		if (SceneData.ToyArmor != None)
			if (SceneData.HasToyEquipped)
				Actor toyActor = SceneData.MaleRole				; usually in a normal MF-scene using a toy, but female may have equipped in spanking or FF scene
				Actor otherActor = SceneData.FemaleRole				; v3.22
				
				if (forceRem && notAllowed)
					; search anyway in case both actors have one equipped   v3.22
					searchList = true
				endIf
				
				if (!SceneData.SameGender)
					toyActor = SceneData.FemaleRole
					otherActor = None
					searchList = false		; no need to check male
				endIf
				

				if (toyActor.GetItemCount(SceneData.ToyArmor) > 0)
					
					toyActor.UnequipItem(SceneData.ToyArmor, false, true)
					self.HasToyEquipped = false
					SceneData.HasToyEquipped = false
					
				elseIf (forceRem && otherActor != None && otherActor.GetItemCount(SceneData.ToyArmor) > 0)		; other may have equipped - v3.22
				
					otherActor.UnequipItem(SceneData.ToyArmor, false, true)
					self.HasToyEquipped = false
					SceneData.HasToyEquipped = false
					
				elseIf (allowRetry && SceneData.AnimationSet > 4 && CheckRemoveToysCount < 5)
					; may not be copied back yet from AAF
					if (DTSleep_DebugMode.GetValue() > 0.0 && DTSleep_SettingTestMode.GetValue() >= 2.0)
						Debug.Trace(myScriptName + " no ToyArmor inventory -- try again count " + CheckRemoveToysCount)
					endIf
					StartTimer(5.0, CheckRemoveToysTimerID)
					CheckRemoveToysCount += 1
					
					return
				endIf
			else
				self.HasToyEquipped = false
			endIf
		else
			searchList = true
		endIf
		
		if (searchList)
			int len = DTSleep_StrapOnList.GetSize()
			while (index < len)
				Armor toyArmor = DTSleep_StrapOnList.GetAt(index) as Armor
				if (MainActorRef != None && MainActorRef == SceneData.MaleRole)
					if (MainActorRef.IsEquipped(toyArmor))
						MainActorRef.UnequipItem(toyArmor, false, true)
						index = len
						SceneData.HasToyEquipped = false   ; remove flag from Scene since we applied
						self.HasToyEquipped = false
					endIf
				elseIf (MainActorRef != None && !SceneData.SameGender && MainActorRef == SceneData.FemaleRole)
					if (MainActorRef.IsEquipped(toyArmor))
						MainActorRef.UnequipItem(toyArmor, false, true)
						index = len
						SceneData.HasToyEquipped = false   ; remove flag from Scene since we applied
						self.HasToyEquipped = false
					endIf
				endIf
				if (SecondActorRef && SecondActorRef == SceneData.MaleRole)
					if (SecondActorRef.IsEquipped(toyArmor))
						SecondActorRef.UnequipItem(toyArmor, false, true)
						index = len
						SceneData.HasToyEquipped = false   ; remove flag from Scene since we applied
						self.HasToyEquipped = false
					endIf
				endIf
				index += 1
			endWhile
		endIf
	endIf
endFunction

Function ClearSecondActors(bool endScene = false)
	if (SceneData.SecondMaleRole != None)
		if (endScene)
			SceneData.SecondMaleRole.StopTranslation()
		endIf
		SceneData.SecondMaleRole.SetRestrained(false)
	endIf
	if (SceneData.SecondFemaleRole != None)
		if (endScene)
			SceneData.SecondFemaleRole.StopTranslation()
		endIf
		SceneData.SecondFemaleRole.SetRestrained(false)
	endIf
	SceneData.SecondMaleRole = None
	SceneData.SecondFemaleRole = None
endFunction

Function DoDisableControls()
	DTSleepIAQInputLayer = InputEnableLayer.Create()
	
	DTSleepIAQInputLayer.DisablePlayerControls(false, true, true, false, true, false, true, false, true, true, true)
endFunction

Function DoDisableCleanUp()
	;if (DTSleep_SettingTestMode.GetValue() > 0.0 && DTSleep_DebugMode.GetValue() >= 3.0)
	;	Debug.Trace(MyScriptName + " Disable-Clean-Up start..." )
	;endIf
	if (SleepBedTempRef != None)
		Utility.Wait(0.2)
		
		if (DTSleep_CommonF.DisableAndDeleteObjectRef(SleepBedTempRef, false) == false)
			Debug.Trace(MyScriptName + " failed to delete temp bed!")
			Utility.Wait(0.25)
		endIf
		SleepBedTempRef = None
	endIf
	
	if (SceneData.MaleMarker != None)
		DTSleep_CommonF.DisableAndDeleteObjectRef(SceneData.MaleMarker, false)
		SceneData.MaleMarker = None
	elseIf (SceneData.FemaleMarker != None)
		DTSleep_CommonF.DisableAndDeleteObjectRef(SceneData.FemaleMarker, false)
		SceneData.FemaleMarker = None
	endIf
	
	if (SecondActorOriginMarkRef)
		
		DTSleep_CommonF.DisableAndDeleteObjectRef(SecondActorOriginMarkRef, false)
		SecondActorOriginMarkRef = None
	endIf
	if (MainActorOriginMarkRef != None)
		DTSleep_CommonF.DisableAndDeleteObjectRef(MainActorOriginMarkRef, false)
		MainActorOriginMarkRef = None
	endIf
	
	if (MainActorCloneRef != None)
		DTSleep_CommonF.DisableAndDeleteObjectRef(MainActorCloneRef, false)
		MainActorCloneRef = None
	endIf
	
	;if (DTSleep_SettingTestMode.GetValue() > 0.0 && DTSleep_DebugMode.GetValue() >= 3.0)
	;	Debug.Trace(MyScriptName + " Disable-Clean-Up ...stop.")
	;endIf
endFunction

Function FadeAndPlay(int id, bool mainActorIsMaleRole = true)

	DTSleep_IntimateIdleID.SetValueInt(id)
	
	SceneIsPlaying = true
	bool playAAF = false
	bool startResult = true				; assume started okay, otherwise changed to false

	bool seqGoodToGo = false
	bool mainActorPlaced = false		
	
	if (SecondActorRef != None)
		SecondActorRef.SetRestrained()
		Utility.Wait(0.08)
	endIf
	
	if (SleepBedRef != None && !IsObjSedan(SleepBedRef))
		; prevent NPCs from using furniture -- partial solution (NPC will keep trying to sit over and over)
		; v2.18 - use during setup
		SleepBedRef.SetDestroyed(true)
	endIf
	
	int okSit = SceneOkayLookViewSit(id, SleepBedRef)		; 0=clone/stand; 1=clone/sit; 2=no-clone/sit
	int vrMode = DTSleep_VR.GetValueInt()
	bool vrOkay = false
	if (vrMode >= 3 || DTSleep_SettingTestMode.GetValueInt() >= 1)
		vrOkay = true
	endIf
	
	if (vrMode <= 1)
		if (DTSleep_SettingAACV.GetValueInt() == 3)
			; force Look-View    -- TODO: should we keep this?    - v3.02
			vrMode = 2
			vrOkay = true
		endIf
	endIf
	
	; check clone and AAF setting
	if (id >= 500 && id < 1600 && IsAAFEnabled() && IsSceneAAFSafe(id, false))
		;  
		playAAF = true
		SceneData.IntimateSceneViewType = 10
		
	elseIf (vrMode >= 2 && okSit >= 0 && vrOkay)
		; v3.02 -- VR-mode or forced Look-View of standing scenes
		;  --- note: when player seated cannot hide HUD even when disabled
		
		if (okSit >= 0 && okSit <= 1)
			if (ProcessMainActorClone())
	
				Game.ForceFirstPerson()
				Utility.Wait(0.2)
				
				if (okSit == 0)
					; place between player and chair or in front of chair or at angle
					float dist = 58.0	; from player - min activation distance is 80
					float offAngle = 0.0
					float zOffset = 0.0
					bool isLarge = false
					float furnDistCheck = 90.0
					ObjectReference originRef = MainActorRef
					
					; note: for standing hug/kiss we force MainActorPositionByCaller true
					
					if (MainActorPositionByCaller && !SceneIDIsCuddle(id))
						; custom animation and player chose pick-spot
						dist = 72.0
					
					elseIf (IsObjBed(SleepBedRef))
						if (SleepBedRef.HasKeyword(AnimFurnFloorBedAnimKY))
							; player may stand on bed, so place in front
							dist = 64.0
							zOffset = 2.0
						else
							dist = 52.0
							offAngle = 32.0
							isLarge = true
						endIf
						
					elseIf (MySleepBedFurnType == FurnTypeIsSeatSofa)
						isLarge = true
						dist = 44.0
						offAngle = -1.0
						originRef = SleepBedRef
						
					elseIf (MySleepBedFurnType == FurnTypeIsTablePicnic || MySleepBedFurnType == FurnTypeIsTablePool)
						dist = 0.0
						zOffset = 18.8 + DTSleep_CommonF.GetBedHeight()
						originRef = SleepBedRef
						
					elseIf (MySleepBedFurnType == FurnTypeIsMotorcycle || MySleepBedFurnType == FurnTypeIsSedanPostWar || MySleepBedFurnType == FurnTypeIsSedanPreWar)
						dist = 44.0
						offAngle = 24.0
					endIf
					
					Debug.Trace(MyScriptName + " VR-P ..... ** distance " + dist + ", main-actor-positioned? " + MainActorPositionByCaller)
					
					SceneData.MaleMarker = DTSleep_CommonF.PlaceFormAtObjectRef(DTSleep_MainNode, MainActorCloneRef, false, true, true)
					Point3DOrient ptOrig = DTSleep_CommonF.PointOfObject(MainActorRef)
					Point3DOrient ptBed = DTSleep_CommonF.PointOfObject(SleepBedRef)
					Point3DOrient ptTargetNode = new Point3DOrient
					if (offAngle == -1.0)
						; try in front of or on furniture
						ptTargetNode = DTSleep_CommonF.GetPointDistOnHeading(ptBed, dist, 0.0)
					else
						; half-way between player and chair
						ptTargetNode = DTSleep_CommonF.GetPointDistOnHeading(ptOrig, dist, offAngle)
					endIf
					
					if (isLarge && DTSleep_CommonF.IsActorPtOnBed(ptTargetNode, ptBed, furnDistCheck))
						; make furniture disappear
						SleepBedRef.MoveTo(SleepBedRef, 0.0, 0.0, -700.0, true)
						SleepBedIsHidden = true
						Debug.Trace(MyScriptName + " VR-P ..... ** hiding furniture " + SleepBedRef)
					endIf
					
					SceneData.MaleMarker.MoveTo(originRef, ptTargetNode.X, ptTargetNode.Y, zOffset, true)
					
					; is marker too close to player?
					float distMarkerToPlayer = SceneData.MaleMarker.GetDistance(MainActorRef)
					if (originRef == MainActorRef && !SleepBedIsHidden && distMarkerToPlayer < 44.0)
						; make furniture disappear and move to furniture
						SceneData.MaleMarker.MoveTo(SleepBedRef, 0.0, 0.0, 0.0, false)
						SleepBedRef.MoveTo(SleepBedRef, 0.0, 0.0, -700.0, true)
						SleepBedIsHidden = true
						Debug.Trace(MyScriptName + " ..... ** hiding furniture2 " + SleepBedRef)
					endIf
					
					float orientation = Utility.RandomFloat(12.0, 32.0)
					if (Utility.RandomInt(0,8) > 4)
						orientation += 180.0
					endIf
					SceneData.MaleMarker.SetAngle(0.0, 0.0, orientation)
					MainActorCloneRef.MoveTo(SceneData.MaleMarker, 0.0, 0.0, 0.0, true)
					seqGoodToGo = true
					mainActorPlaced = true
				endIf
				
			elseIf (vrMode < 3)
				Game.ForceThirdPerson()
			endIf
		endIf
		
		if (okSit >= 1)
			
			if (okSit == 2)
				SceneData.MaleMarker = DTSleep_CommonF.PlaceFormAtObjectRef(DTSleep_MainNode, MainActorRef, false, true, true)
			endIf
			
			SleepBedRef.Activate(MainActorRef)			; this shows HUD even if disabled
			MainActorMovedCount = 5
			mainActorPlaced = true
			
			seqGoodToGo = true
		endIf
		
	elseIf (SceneOkayToClonePlayer(id))
		
		if (ProcessMainActorClone())
	
			Game.ForceFirstPerson()
		endIf
	endIf

	
	if (SleepBedRef != None && !seqGoodToGo)
	
		if (id < 1600)
			; position markers and actors on bed
			if (id >= 546 && id < 550 && !FadeEnable && playAAF)
				seqGoodToGo = true
				
			elseIf ((id >= 90 && id < 100) || (id >= 490 && id < 500) || MainActorPositionByCaller)
				
				; stand-in-place embrace or dances (v3.0 added CHAK, v3.02 added positioned-by-caller)
				
				seqGoodToGo = true
				
				if (MainActorCloneRef != None)
					SceneData.MaleMarker = DTSleep_CommonF.PlaceFormAtObjectRef(DTSleep_MainNode, MainActorCloneRef, false, true, true)
				else
					SceneData.MaleMarker = DTSleep_CommonF.PlaceFormAtObjectRef(DTSleep_MainNode, MainActorRef, false, true, true)
				endIf
				
			else
				
				seqGoodToGo = PositionIdleMarkersForBed(id, mainActorIsMaleRole, false)
			endIf
			
			if (!seqGoodToGo)
			
				if (id >= 150 && id < 200 && !SceneData.IsUsingCreature)
					; try on the bed with default id
					;Debug.Trace(MyScriptName + " failed stand now try on bed")
					
					if (mainActorIsMaleRole)
						id = 101
					else
						id = 110
					endIf
					
					seqGoodToGo = PositionIdleMarkersForBed(id, mainActorIsMaleRole, false)
				else
					;Debug.Trace(MyScriptName + " failed to position, try switch angle")
					seqGoodToGo = PositionIdleMarkersForBed(id, mainActorIsMaleRole, true)
				endIf
			endIf
		else
			seqGoodToGo = true
		endIf
		
	endIf
	
	if (seqGoodToGo && MainActorCloneRef != None && !mainActorPlaced && SceneIDAtPlayerPosition(id))
	
		SceneData.FemaleMarker = DTSleep_CommonF.PlaceFormAtObjectRef(DTSleep_MainNode, MainActorRef, false, true, true)
		
		if (SceneData.FemaleMarker != None)
			
			SceneData.FemaleMarker.MoveTo(MainActorRef, 0.0, -67.0, 0.0, true)
		endIf
		if (SceneData.MaleMarker != None)
			SceneData.MaleMarker.MoveTo(MainActorRef, 0.0, 12.0, 0.0, true)
			SceneData.MaleMarker.SetAngle(0.0, 0.0, MainActorRef.GetAngleZ() - 36.0)
		endIf
	endIf
	
	float timePlay = 6.0
	
	
	if (seqGoodToGo)
		timePlay = GetTimeForPlayID(id)
		
	else
		if (DTSleep_SettingTestMode.GetValue() > 0.0 && DTSleep_DebugMode.GetValue() >= 1.0)
			Debug.Trace(myScriptName + " FadeAndPlay seq not good to go - change to dance")
		endIf
		id = 11
		
		timePlay = GetTimeForPlayID(id)
		
		if (SceneData.IsUsingCreature || SceneData.CompanionInPowerArmor)
			SecondActorRef = None
		endIf
	endIf
	
	if (timePlay > 16.0 && DTSleep_SettingCancelScene.GetValue() > 0.0)
		RegisterForMenuOpenCloseEvent("PipboyMenu")
	endIf

	RegisterForHitEvent(MainActorRef)

	; should only be accessible when menu control enabled, but always monitor as precaution
	RegisterForMenuOpenCloseEvent("WorkshopMenu")
	
	if (id < 50)
		PlayIdleAnimationWithEndTimer(timePlay)
		
	elseIf (id < 100)
		PlayIntimateAACWithEndTimer(timePlay)
		Utility.Wait(0.1)
		
	elseIf (SceneData.AnimationSet == 1)

		PlayIntimateLeitoAnimWithEndTimer(timePlay)
		
	elseIf (SceneData.AnimationSet == 2)

		PlayIntimateCrazyGAnimWithEndTimer(timePlay)
		
	elseIf (id >= 400)
		if (playAAF && id >= 500)
			if (!FadeEnable)
				SecondActorRef.SetRestrained(false)			; unlock to allow walk
				if (SceneData.SecondFemaleRole != None)
					SceneData.SecondFemaleRole.SetRestrained(false)
				endIf
				if (SceneData.SecondMaleRole != None)
					SceneData.SecondMaleRole.SetRestrained(false)
				endIf
			endIf
			; may return false if unable to start  - v2.73
			startResult = PlayIntimateAAFSceneWithEndTimer(timePlay)
			
		;elseIf (SceneData.AnimationSet == 600 && id < 682)						; (broke branch) v2.73 now plays with AAC
		;
		;	if (MainActorCloneRef != None)
		;		MoveActorsToAACPositions(MainActorCloneRef, SecondActorRef)
		;	else
		;		MoveActorsToAACPositions(MainActorRef, SecondActorRef)
		;	endIf
		;	PlayIntimateLeitoAnimWithEndTimer(timePlay)

		else
			; always returns true
			PlayIntimateAACWithEndTimer(timePlay)
		endIf
	endIf
	
	if (startResult)
		Utility.Wait(0.2)
		FadeInSec(1.7, false)
		
		if (id >= 100 && id < 400)
			;Game.FadeOutGame(false, true, 0.667, 3.1)	;v2 player now fades in
			
		elseIf (id < 50)
			
			Game.FadeOutGame(false, true, 0.33, 2.5)
		endIf
		
		if (!playAAF && PlaySlowTime && MainActorRef != None)

			Utility.Wait(1.5)
			DTSleep_SlowTime.Cast(MainActorRef)	
		endIf
		
		if (SleepBedRef != None && IsObjBed(SleepBedRef))
			; v2 - since have chairs limit to ignore hugs at chairs for repeat scene check
			LastScenePrevID = LastSceneID
			LastSceneID = id
		; v2.90 comment these out, because covered by last case and we don't want to include embrace
		;elseIf ((MySleepBedFurnType == FurnTypeIsTablePool || MySleepBedFurnType == FurnTypeIsTablePicnic)
			; v2.35 keep track of previous for tables supporting many scenes
		;	LastScenePrevID = LastSceneID
		;	LastSceneID = id
		;elseIf (SleepBedRef != None && SleepBedRef.HasKeyword(DTSleep_SMBed02KY))
		;	LastSceneID = id
		elseIf (id >= 100)
			LastSceneOtherPrevID = LastSceneOtherID
			LastSceneOtherID = id
		endIf
		
		if (SleepBedRef != None && !IsObjSedan(SleepBedRef))
			; restore
			SleepBedRef.SetDestroyed(false)
		endIf
	else
		Debug.Trace(myScriptName + " failed to start scene!")
	endIf

endFunction

Function FadeInSec(float secs, bool doWait = true)
	
	if (HoldToBlackIsSetOn)
		StartTimer(secs + 0.2, HoldToBlackClearTimerID)
		HoldAtBlackImod.PopTo(FadefromBlackImod, secs)
		HoldToBlackIsSetOn = false
		if (doWait && secs > 0.1)
			Utility.Wait(secs)
		endIf
	endIf
endFunction

Function FadeOutSec(float secs, bool doWait = true)
	
	if (HoldToBlackIsSetOn == false)
		HoldAtBlackImod.Apply()
		HoldToBlackIsSetOn = true
		if (doWait && secs > 0.1)
			Utility.Wait(secs)
		endIf
	endIf
endFunction

Function FinalizeAndSendFinish(bool seqStartedOK = true, int errCount = 0)

	bool placeBedRequested = PlaceInBedOnFinish
	
	; this should begin before idle ME finishes - allow time to finish
	if (DTSleep_SettingTestMode.GetValue() > 0.0 && DTSleep_DebugMode.GetValue() >= 2.0)
		Debug.Trace(MyScriptName + " Finalize and Finish")
	endIf
	
	if (SceneData.Interrupted < 0)
		SceneData.Interrupted -= 1
		if (DTSleep_SettingTestMode.GetValue() > 0.0 && DTSleep_DebugMode.GetValue() >= 1.0)
			Debug.Trace(myScriptName + " scene never started -- wait")
		endIf
		
		if (SceneData.Interrupted > -4)						; v2.71 -- avoid forever loop, but should not happen since DTSleep_PlayAAFSceneScript detects and sends stop
			StartTimer(24.0, SeqEndTimerID)
		
			return
		endIf
	endIf
	
	; ------------------------------lock controls   until end -- v3.0
	DoDisableControls()
	; -----------------------------
	
	SceneIsPlaying = false
	
	bool noInterruption = true
	if (SceneData.Interrupted > 0)
		noInterruption = false
	endIf
	
	
	;if (SleepBedShiftedDown != 0.0)
	;	ShiftSleepBedZ(SleepBedShiftedDown)
	;endIf
	
	SleepBedShiftedDown = 0.0
	
	if (SleepBedIsHidden)
		SleepBedRef.MoveTo(SleepBedRef, 0.0, 0.0, 700.0, true)
	endIf
	SleepBedIsHidden = false

	;Game.StopDialogueCamera()
	
	; v1.80 - playLeito and playAAC do fade-out so wait for finish first
	int count = 0
	int lim = 30
	if (!FadeEnable && SceneData.AnimationSet >= 5 && DTSleep_SettingAAF.GetValueInt() == 2)
		; more time to allow for walk
		lim = 80
	endIf
	
	while (count < lim && IsSequenceRunning())
		Utility.Wait(0.25)
		count += 1
	endWhile

	; v1.70 - always fade even if interrupted
	if (FadeEnable)
		; do game fade-out then replace with black fade
		Game.FadeOutGame(true, true, 0.0, 1.4, true)
		Utility.Wait(0.6)
	endIf
	
	; wait for clean-up
	while (count < 60 && IsSequenceRunning()) ; && !IsAAFEnabled())				v2.74--wait anyway
		Utility.Wait(0.25)
		count += 1
	endWhile
	
	if (IsSequenceRunning())
		SceneData.Interrupted = 3				; v2.74 changed to 3 since 4 is for OnHit 
		if (SceneData.AnimationSet >= 5 && DTSleep_PlayAAFSceneQuest.IsRunning())
			(DTSleep_PlayAAFSceneQuest as DTSleep_PlayAAFSceneScript).StopAnimationSequence(false)
		endIf
		Utility.Wait(1.0)
	endIf
	
	if (DTSleep_SettingTestMode.GetValue() > 0.0 && DTSleep_DebugMode.GetValue() >= 3.0)
		Debug.Trace(myScriptName + " wait count: " + count)
	endIf
	
	if (SceneData.AnimationSet >= 5 && DTSleep_PlayAAFSceneQuest.IsRunning())
		if (seqStartedOK && errCount == 0 && SceneData.Interrupted <= 0)
			Utility.Wait(2.85)
		else
			Utility.Wait(3.33)
		endIf
	else
		Utility.Wait(0.8)
	endIf
	
	; v2.14 - no longer using
	;if (SleepBedRef != None)
	;	; allow NPCs to use furniture again
	;	SleepBedRef.SetDestroyed(false)
	;endIf
	
	if (SecondActorRef != None)
		SecondActorRef.SetRestrained(false)
		if (SecondActorOriginMarkRef != None)
			
			SecondActorRef.MoveTo(SecondActorOriginMarkRef, 0.0, 0.0, 0.0, true)
			Utility.Wait(0.28)
		endIf
	endIf
	
	bool okayToMoveMainActor = true
	bool settingPrompt = false
	
	if (DTSleep_SettingFadeEndScene.GetValue() <= 0.0)
		okayToMoveMainActor = false
		settingPrompt = true
		
	elseIf (MainActorMovedCount >= 1)
		okayToMoveMainActor = false
	endIf
	
	if (ProcessMainActorRecover())
		; a clone was removed - should we be in third-person view?
		if (DTSleep_VR.GetValue() < 2.0 && DTSleep_SettingAACV.GetValueInt() < 3)
			Game.ForceThirdPerson()
		endIf
		Utility.Wait(0.3)
		if (!settingPrompt)								; make sure setting observed, but not a fix since PlaceInBedOnFinish according to setting - v2.70
			okayToMoveMainActor = true					; should still be true since clone moves, not MainActor
		endIf
	endIf
	

	; v2.70 - updated to allow cancel scene to put player-character back to origin
	
	if (noInterruption && FadeEnable)
		FadeOutSec(0.3)
		Game.FadeOutGame(false, true, 0.0, 0.5)  ; remove game fade before moving main character which forces a fade-load-screen
	endIf
	
	if (noInterruption && PlaceInBedOnFinish && okayToMoveMainActor && SleepBedRef != None && IsObjBed(SleepBedRef))
		
		Utility.Wait(0.67)
		if (DTSleep_SettingTestMode.GetValueInt() > 0 && DTSleep_DebugMode.GetValue() >= 2.0)
			Debug.Trace(MyScriptName + " move main actor in bed ")
		endIf
		Utility.Wait(0.1)
		
		MainActorMovedCount += 1
		MainActorRef.MoveTo(SleepBedRef)
		
	elseIf (MainActorMovedCount == 5 && IsObjSeat(SleepBedRef)) 
		; 5 means override movement at end; player seated in chair   v3.0
	
		; stand
		SleepBedRef.Activate(MainActorRef)
		
	elseIf (MainActorOriginMarkRef != None && MainActorMovedCount < 5)			
		PlaceInBedOnFinish = false
		if (DTSleep_SettingTestMode.GetValueInt() > 0 && DTSleep_DebugMode.GetValue() >= 2.0)
			Debug.Trace(MyScriptName + " translate main actor back to origin")
		endIf
		
		;Utility.Wait(0.06)
		;MainActorMovedCount += 1
		
		DTSleep_CommonF.MoveActorToObject(MainActorRef, MainActorOriginMarkRef)
		Utility.Wait(0.2)
		
		int w = 0
		while (w < 5 && !DTSleep_CommonF.PositionObjsMatch(MainActorRef, MainActorOriginMarkRef))
			Utility.Wait(0.3)
			w += 1
		endWhile
	else
		PlaceInBedOnFinish = false
		if (okayToMoveMainActor)
			Utility.Wait(0.6)
		endIf
	endIf

	
	MainActorRef.StopTranslation()
	
	StartTimer(0.9, DisableCleanUpTimerID)
	
	
	if (SecondActorRef != None)
		SecondActorRef.StopTranslation()
		SecondActorRef.SetRestrained(false)
	endIf
	
	ClearSecondActors(true)
	
	; Did scene last long enough in game-time?    - v3.08
	; if not, Wait 20 minutes for shorter scenes and 60 minutes for long scenes
	;
	int scLen = DTSleep_IntimateSceneLen.GetValueInt()
	
	; only consider scene-length of at least 1
	if (scLen > 0 && TimeScale.GetValueInt() < 20.0)			; limit to less than default TimeScale v3.09
	
		; don't count if interrupted or never started
		if (SceneStartGameTime > 0.0 && seqStartedOK && errCount == 0 && SceneData.Interrupted <= 0)
			float hourTarget = 0.33333  ; 20 minutes for short scene
			if (SceneData.IntimateSceneIsDanceHug >= 3)
				hourTarget = 0.05		; 3 minutes for hug/kiss -- currently not setting StartTime - not checking
			elseIf (SceneData.IntimateSceneIsDanceHug > 0)
				hourTarget = 0.1333		; 8 minutes for dance
			elseIf (scLen >= 4 && PlayerEndurance > 11)			; scLen may be increased for low time-scale or endurance, so ensure has endurance
				hourTarget = 1.00001
			elseIf (scLen >= 3)
				hourTarget = 0.5001
			endIf
			float currentGameTime = Utility.GetCurrentGameTime()
			float hourDiff = GetHoursDifference(currentGameTime, SceneStartGameTime)
			if (hourDiff < hourTarget)
				float hoursShort = hourTarget - hourDiff
				float gHourSet = GameHour.GetValue() + hoursShort
				
				if (gHourSet >= 24.0)
					float overT = gHourSet - 24.0
					gHourSet = 23.98
					hoursShort = 23.98 - GameHour.GetValue()
					hourTarget -= overT
				endIf
				
				if (hoursShort > 0.01)						; v3.09 ensure need to adjust time
					SceneWaitDuration += hoursShort
					
					if (DTSleep_SettingTestMode.GetValueInt() > 0)
						Debug.Trace(MyScriptName + " EndScene add at time " + GameHour.GetValue() + " with Wait of " + hoursShort + " hours; updating GameHour to " + gHourSet)
					endIf
					
					GameHour.SetValue(gHourSet)
				endIf
				
				if (SceneWaitDuration >= 1.0)										; v3.09 changed to use our variable
					Game.IncrementStat("Hours Waiting", 1)
					if (DTSleep_SettingTestMode.GetValueInt() > 0)
						Debug.Trace(MyScriptName + " Updated Wait-Stat by 1")
					endIf
					
					SceneWaitDuration = 0.0				; reset for next
				endIf
			endIf
		endIf
	endIf
	
	
	; unlock controls
	if (DTSleepIAQInputLayer != None)
		DTSleepIAQInputLayer.EnablePlayerControls()
		Utility.Wait(0.02)
		DTSleepIAQInputLayer.Delete()
	endIf
	DTSleepIAQInputLayer = None
	
	Utility.Wait(0.2)
	
	Debug.Trace(myScriptName + " Finalize And Finish --- check toys")  ;TODO: remove
	
	CheckRemoveToys()
	
	;if (DTSleep_SettingFadeEndScene.GetValue() <= 0.0)
	;	SceneData.Interrupted = 13
	;endIf
	
	
	Var[] kArgs = new Var[7]
	kArgs[0] = MainActorRef
	kArgs[1] = SecondActorRef
	
	if (IsObjBed(SleepBedRef))
		;PlaceInBedOnFinish = false
		kArgs[2] = SleepBedRef
	endIf
	kArgs[3] = FadeEnable
	
	if (seqStartedOK)
		kArgs[4] = 2
	elseIf (errCount > 0)
		kArgs[4] = -1 * errCount
	else
		kArgs[4] = -1
	endIf
	kArgs[5] = placeBedRequested
	kArgs[6] = DTSleep_IntimateIdleID.GetValueInt()
	
	SendCustomEvent("IntimateSequenceDoneEvent", kArgs)
endFunction


float Function GetTimeForPlayID(int id)

	; single-stage and special scenes go first followed by multi-stage scenes
	;
	; remember 4-stage scene default timings is total = 
	;       SceneLen 1 = 64 seconds (baseSec)
	;       SceneLen 2 = 86 seconds
	;       SceneLen 3 = 108 seconds
	;                4 = 130 seconds
	
	SceneData.WaitSecs = 11.0							; set to default
	DTSleep_IntimateSceneLen.SetValueInt(0)				; v2.90 -- single stage scene may be set to time-and-a-half using DTSleep_IntimateSceneLen set to 1
	int timeScaleVal = TimeScale.GetValueInt()			; v3.08 -- for low time-scale increase scene length
	float tm = 20.0										; expected total time for scene
	int endurance = PlayerEndurance						; check value obtained at start-up - v2.90
	int scL = 0											; scene length 
	
	if (MainActorRef != None && endurance < 3)
		endurance = (MainActorRef.GetValue(EnduranceAV) as int) ; may be no clothing bonus if naked
		PlayerEndurance = endurance
	endIf
	
	if (endurance < 5)
		SceneData.WaitSecs = 9.0
	endIf
	
	float waitSecX2 = SceneData.WaitSecs + SceneData.WaitSecs
	float waitSecX4 = waitSecX2 + waitSecX2
	
	if (id == 6001)
		return 316.22
	endIf
	
	if (timeScaleVal <= 5)
		scL = 1
		DTSleep_IntimateSceneLen.SetValueInt(scL)		; v3.08
		tm += 11.0
	endIf


	if (id <= 10)
		return 2.5
		
	elseIf (id == 11)
	
		return 14.2
		
	elseIf (id >= 98 && id <= 99)		; hug, kiss
		
		if (SceneData.IntimateSceneIsDanceHug <= 0)				; v3.08
			; XOXO bed scene
			scL += 2
			tm += 22.0
		endIf
		if (endurance >= 7)
			scL += 1
			tm += 10.0
		endIf
		DTSleep_IntimateSceneLen.SetValueInt(scL)
		
		return tm
		
	elseIf (id >= 490 && id < 500)
		; hug/kiss standing or slow-dance
		if (SceneData.IntimateSceneIsDanceHug <= 0)				; v3.08
			; XOXO bed scene
			scL += 2
			tm += 22.0
		endIf
		if (endurance >= 7)
			scL += 1
			tm += 10.0
			
			if (id == 494)
			 	scL += 1
			 	tm += 10.0
			endIf
		endIf
		
		; dance should be longer for low time-scale  ; v3.09
		if (id == 494 && timeScaleVal <= 5)
			scL += 1
			
			tm += 20.0
		endIf
		
		DTSleep_IntimateSceneLen.SetValueInt(scL)
		
		return tm
		
	elseIf (id >= 400 && id < 490)
		if (id == 402)
			return tm
		else
			return tm + 13.0
		endIf
		
	elseIf (id == 548)					; hug
		return tm - 2.0
		
	elseIf (id >= 90 && id < 98)		; hug and kiss and dance
		if (SceneData.IntimateSceneIsDanceHug <= 0)				; v3.08
			; XOXO bed scene
			scL += 2
			tm += 22.0
		endIf
		if (id == 91)
			scL += 1
			tm += 19.0
		endIf
		if (endurance >= 7)
			scL += 1		; single-stage time-and-a-half v2.90
			tm += 12.0
		endIf
		if (timeScaleVal <= 5)
			scL += 1
			tm += 10.0
			if (id == 91)
			  tm += 10.0
			endIf
		endIf
		
		DTSleep_IntimateSceneLen.SetValueInt(scL)
		
		return tm
		
	elseIf (id == 1098)				
		if (endurance >= 7)
			scL += 1
			tm += 10.0
		endIf
		return tm - 2.0
		
	elseIf (id == 549)					; hug and kiss
		return tm + 8.0
	elseIf (id == 535)
		DTSleep_IntimateSceneLen.SetValueInt(scL + 1)
		return tm + 2.0						; couch cuddle  TODO: ?????
		
	elseIf (id == 780)					; booth flirt
		if (endurance > 8)
			DTSleep_IntimateSceneLen.SetValueInt(scL + 1)
			return tm + 36.0
		endIf
		return tm + 22.0
		
	elseIf (id == 1135 || id == 1136 || id == 1148)
		; two-stage/single stage v3.15
		if (endurance > 8)
			DTSleep_IntimateSceneLen.SetValueInt(scL + 1)
			return tm + 36.0
		endIf
		return tm + 22.0
		
	elseIf (id >= 1047 && id <= 1051)
		; single stages -- (some not used) -- added v3.15
		if (endurance > 8)
			DTSleep_IntimateSceneLen.SetValueInt(scL + 1)
			return tm + 36.0
		endIf
		return tm + 22.0
		
	elseIf (id == 1008)
		; best to slow each stage and without repeat stages
		DTSleep_IntimateSceneLen.SetValueInt(0)
		SceneData.WaitSecs = 12.0 + (endurance as float)		; for mid-stage -- others have set times
		
		return tm + 13.0 + SceneData.WaitSecs
	
	elseIf (id >= 100)
		float baseSec = 59.5				; base time for multi-stage scenes
		
		if (id == 547)
			; spank should last at least a ping-pong    v3.16
			scL += 4

			DTSleep_IntimateSceneLen.SetValueInt(scL)
			
			return 7.5 * (scL - 1) + 9.0
		
		elseIf (SceneData.AnimationSet == 5 && id != 547 && id != 546)	
			DTSleep_IntimateSceneLen.SetValueInt(scL)
			
			if (id >= 505 && id <= 510)
				return tm + 13.5
			elseIf (id >= 551 && id < 552)
				return tm + 16.0
			endIf
			
			return tm + 8.0
			
		elseIf (SceneData.AnimationSet == 10)
			if ((id >= 1004 && id <= 1006) || (id >= 1012 && id <= 1020) || (id >= 1035 && id <= 1036) || (id >= 1047 && id <= 1051) || (id >= 1060 && id <= 1061))
				DTSleep_IntimateSceneLen.SetValueInt(scL)
				if (endurance > 8)
					DTSleep_IntimateSceneLen.SetValueInt(scL + 1)
					return tm + 16.0
				endIf
				return tm + 4.0
			endIf
			
		elseIf (id == 1193 && SceneData.SecondMaleRole != None)
			; 8-stage scene, no ping-pong unless for low time-scale   v3.15
			DTSleep_IntimateSceneLen.SetValueInt(scL + 1)
			return 86.0 + (waitSecX2 * scL)
				
		elseIf (id >= 200 && id < 600 && id != 547 && id != 546)
			DTSleep_IntimateSceneLen.SetValueInt(scL)
			
			baseSec = tm + 9.0
			
		elseIf (id >= 764 && id <= 765)
		
			DTSleep_IntimateSceneLen.SetValueInt(1)
			return 78.0
			
		elseIf (id == 766)
			DTSleep_IntimateSceneLen.SetValueInt(scL + 1)
			if ((DTSConditionals as DTSleep_Conditionals).SavageCabbageVers >= 1.22)
				return tm + 72.0
			endIf
			return tm + 62.5
			
		elseIf (SceneData.CompanionInPowerArmor || SceneData.IsCreatureType == 3)
			DTSleep_IntimateSceneLen.SetValueInt(scL)
			
			return tm + 6.4
			
		elseIf (id >= 700 && id < 800)
			if (id >= 798)
				DTSleep_IntimateSceneLen.SetValueInt(scL)
				if (endurance > 8)
					DTSleep_IntimateSceneLen.SetValueInt(scL + 1)			; v2.90
					return tm + 26.0
				endIf
				return tm + 11.0
				
			elseIf (id == 797)
				; 8-stage scene, no ping-pong unless for low time-scale   v3.08
				DTSleep_IntimateSceneLen.SetValueInt(scL + 1)
				return 86.0 + (waitSecX2 * scL)
				
			elseIf (id == 700 && SceneData.SecondFemaleRole != None)
				; 8-stage scene, no ping-pong unless for low time-scale   v3.08
				DTSleep_IntimateSceneLen.SetValueInt(scL + 1)
				return 86.0 + (waitSecX2 * scL)
			
			elseIf (id == 794)
				; v2.84 fall-through for 1.29
				if ((DTSConditionals as DTSleep_Conditionals).SavageCabbageVers < 1.290)
					DTSleep_IntimateSceneLen.SetValueInt(scL + 1)
					return tm + 8.0
				endIf
				
			elseIf (id == 781)
				DTSleep_IntimateSceneLen.SetValueInt(scL)
				
				return tm + 6.0
				
			elseIf (id == 706 || id == 739 || id == 749)				; v2.70.1 - removed 707, it's down below
				tm = 30.7
				if (endurance > 8)
					scL += 1
				endIf
				
				; v3.08
				if (timeScaleVal <= 5)
					tm += waitSecX2
					scL += 1   				; +2 included at top
				endIf
				
				DTSleep_IntimateSceneLen.SetValueInt(scL)
				
				return tm
				
			elseIf (id == 709)
				; 8-stage scene, no ping-pong unless for low time-scale   v3.08
				DTSleep_IntimateSceneLen.SetValueInt(scL + 1)
				return 86.0 + (waitSecX2 * scL)
				
			elseIf (id == 769)
				
				if (endurance > 7)
					scL += 1		; v2.90
					tm += 13.0
				endIf
				DTSleep_IntimateSceneLen.SetValueInt(scL)
				
				return tm + 3.0
			
			elseIf (id == 748 && SceneData.SecondMaleRole != None)
				DTSleep_IntimateSceneLen.SetValueInt(0)
				return 32.0
			
			elseIf (id == 741)
				if (endurance >= 5 && (DTSConditionals as DTSleep_Conditionals).SavageCabbageVers >= 1.230)
					; has enough endurance for longer scene - v2.90
					scL += 1
				endIf
				DTSleep_IntimateSceneLen.SetValueInt(scL)
				return 60.0 * (scL + 1)
				
			elseIf (id >= 743 && id <= 745)
				DTSleep_IntimateSceneLen.SetValueInt(scL)
				return tm + 16.0
			elseIf (id == 746)
				DTSleep_IntimateSceneLen.SetValueInt(0)	
				if ((DTSConditionals as DTSleep_Conditionals).SavageCabbageVers >= 1.20 && (DTSConditionals as DTSleep_Conditionals).SavageCabbageVers <= 1.21)
					return 49.0
				elseIf ((DTSConditionals as DTSleep_Conditionals).SavageCabbageVers < 1.20)
					return 32.0
				; else fall through to regular length
				endIf
			elseIf (id == 732)
				DTSleep_IntimateSceneLen.SetValueInt(scL)
				return 24.0 * (scL + 1)
				
			elseIf (id >= 713 && id <= 714)
				DTSleep_IntimateSceneLen.SetValueInt(scL)
				return tm + 12.0
			elseIf (id == 715 && (DTSConditionals as DTSleep_Conditionals).SavageCabbageVers <= 1.24)		; v2.88
				DTSleep_IntimateSceneLen.SetValueInt(scL)
				return tm + 12.0
			elseIf (SceneData.SecondMaleRole != None && id == 707)
				DTSleep_IntimateSceneLen.SetValueInt(scL)
				return tm + 12.0
			elseIf (id == 701 && SceneData.SecondMaleRole != None)
				if (endurance > 8)
					; v2.90
					scL += 1
				endIf
				DTSleep_IntimateSceneLen.SetValueInt(scL)
				return 15.0 * (scL + 2)
				
			elseIf (SceneData.SecondFemaleRole != None && id == 702)
				if (endurance > 8)
					; v2.90
					scL += 1
				endIf
				DTSleep_IntimateSceneLen.SetValueInt(0)
				return 15.0 * (scL + 2) + 2.0
				
			elseIf (SceneData.SecondMaleRole != None && id == 761)
				DTSleep_IntimateSceneLen.SetValueInt(0)
				return 32.0
				
			elseIf (id == 754)
				; v2.79 - fall through for 1.28
				if ((DTSConditionals as DTSleep_Conditionals).SavageCabbageVers < 1.28)
					DTSleep_IntimateSceneLen.SetValueInt(0)
					return 32.0
				endIf
				
			elseIf (id == 755)
				; v2.84 - fall through for 1.29
				if ((DTSConditionals as DTSleep_Conditionals).SavageCabbageVers < 1.29)
					DTSleep_IntimateSceneLen.SetValueInt(0)
					return 32.0
				endIf
			elseIf (id == 757)
				; no ping-pong allowed
				DTSleep_IntimateSceneLen.SetValueInt(1)
				return 80.0
				
			elseIf (id >= 764 && id <= 766)
				; no ping-pong
				DTSleep_IntimateSceneLen.SetValueInt(1)
				if ((DTSConditionals as DTSleep_Conditionals).SavageCabbageVers >= 1.20)
					return 86.0
				endIf
				return 73.0
				
			elseIf (id == 773)
				; no ping-pong for 8-stage scene unless low time-scale v3.08
				DTSleep_IntimateSceneLen.SetValueInt(scL + 1)
				return 86.0 + (waitSecX2 * scL)
				
			elseIf (id == 781)
				; v2.84 - fall through for 1.28
				if ((DTSConditionals as DTSleep_Conditionals).SavageCabbageVers < 1.29)
					DTSleep_IntimateSceneLen.SetValueInt(0)
					return 30.7
				endIf
			elseIf (id >= 782 && id <= 783)
				; v2.79 - fall through for 1.28
				if ((DTSConditionals as DTSleep_Conditionals).SavageCabbageVers < 1.28)
					DTSleep_IntimateSceneLen.SetValueInt(0)
				
					return 33.7
				endIf
			elseIf (id == 785 && (DTSConditionals as DTSleep_Conditionals).SavageCabbageVers < 1.21)
				DTSleep_IntimateSceneLen.SetValueInt(0)
				return 45.0
				
			elseIf (id == 786 && SceneData.SecondMaleRole != None)		; only for 2nd male else timing is normal
				DTSleep_IntimateSceneLen.SetValueInt(0)
				return 30.0
				
			elseIf (id == 778 || id == 787 || id == 792)
				DTSleep_IntimateSceneLen.SetValueInt(0)
				return 32.0
			elseIf (id >= 798 && id < 800)
				DTSleep_IntimateSceneLen.SetValueInt(0)
				return 32.0
			endIf
		endIf
		
		; -----------
		;  multi-stage scenes usually 4-to-6 stages using baseSec and waitSecX2 for ping-pong looping
		;
		tm = 0.0			; not needed; using baseSec
		scL = 0				; reset since these are different
			
		if (endurance >= 8 && id != 547 && id != 546 && id != 791)						
			;int enduRand = Utility.RandomInt(5, endurance)
			int enduRand = (DT_RandomQuestP as DT_RandomQuestScript).GetNextInRangePublic(5, endurance)
			bool longOK = false
			if ((id >= 100 && id < 200) || (id >= 600 && id < 700))
				longOK = true
			elseIf (id >= 900)
				longOK = true
			endIf
			
			if (longOK && endurance >= 12 && enduRand > 10)
				DTSleep_IntimateSceneLen.SetValueInt(4)
				baseSec += (waitSecX4 + waitSecX2 + 4.0)
				
				; increment count reaching max length
				int endCount = 1 + DTSleep_IntimateSceneMaxLenCount.GetValueInt()
				DTSleep_IntimateSceneMaxLenCount.SetValueInt(endCount)
				
			elseIf (enduRand >= 12)														
				DTSleep_IntimateSceneLen.SetValueInt(3)
				baseSec += waitSecX4 + 3.0
			else
				DTSleep_IntimateSceneLen.SetValueInt(2)
				baseSec += waitSecX2 + 3.5
			endIf
			
		elseIf (endurance >= 6 && id != 547 && id != 546 && id != 791)					; v2.74 reduced endurance limit by 1
			DTSleep_IntimateSceneLen.SetValueInt(2)
			baseSec += waitSecX2
			
		elseIf (id < 700 && baseSec > 40.0 && endurance >= 3 && endurance <= 4 && Utility.RandomInt(-2, endurance) <= 0)		; v2.60 id limit
			DTSleep_IntimateSceneLen.SetValueInt(0)
			baseSec -= waitSecX2 + 1.0
			
		elseIf (baseSec > 40.0 && endurance < 3 && id < 700)				; v2.60 id limit
			DTSleep_IntimateSceneLen.SetValueInt(0)
			baseSec -= waitSecX2 + 1.0
		elseIf (endurance < 4)
			; v3.02 - very low endurance
			DTSleep_IntimateSceneLen.SetValueInt(0)
			baseSec = 38.5
		else
			DTSleep_IntimateSceneLen.SetValueInt(1)
		endIf
		
		; -------------------
		; v3.08 - increase length for low time-scale
		;
		if (timeScaleVal <= 5)
			scL = DTSleep_IntimateSceneLen.GetValueInt() + 2
			DTSleep_IntimateSceneLen.SetValueInt(scL)
			baseSec += waitSecX4 + 3.0
		endIf
		;-------------------
		
		if (id >= 100 && id < 102)
			return baseSec - 0.4
		elseIf (id == 103)
			return baseSec - 0.6
		elseIf (id > 103 && id < 108)
			return baseSec + 0.2
		elseIf (id >= 150 && id < 170)
			if (id == 153)
				return baseSec + 6.8
			endIf
			return baseSec + 0.20
		elseIf (id >= 170 && id < 180)
			return baseSec - 0.5
		elseIf (id >= 600)
			
			if (id >= 701 && id <= 702)
				return baseSec + 8.8
			elseIf (id == 704)
				return baseSec + 8.8
			elseIf (id == 735 && SceneData.SecondMaleRole == None)
				return baseSec + 9.0
			elseIf (id == 738)
				return baseSec + 8.8
			elseIf (id == 742 || id == 746 || id == 753)
				return baseSec + 11.0
			elseIf (id == 756)
				return baseSec + 20.0
			
			elseIf (id >= 795 && id <= 795)
				return baseSec + 12.0
			elseIf (id >= 850)
				return baseSec + 4.6
			endIf
			
			return baseSec + 5.0
		else
			return baseSec
		endIf
	endIf
	
	return 60.0
endFunction

; if includes scenes for oral and other
;   does not include jail, PA-station, or bed/floor
;   all male-female
bool Function HasFurnitureOralChoice(ObjectReference obj, Form baseBedForm)
	int val = HasFurnitureOralAnalChoiceInt(obj, baseBedForm)
	
	if (val == 1 || val == 3)
		return true
	endIf
	
	return false
endFunction

; returns 1 for FM oral, 2 for FF-only oral, 3 for anal, 4 for both anal and FM-oral, 5 for female-stimulation or spanking (FM or FF)
int Function HasFurnitureOralAnalChoiceInt(ObjectReference obj, Form baseBedForm)
	int result = 0			
	
	if (obj != None)
		
		if (obj.HasKeyword(AnimFurnPicnickTableKY))
			if ((DTSConditionals as DTSleep_Conditionals).IsRufgtActive)
				return 2
			endIf
			if ((DTSConditionals as DTSleep_Conditionals).IsLeitoAAFActive || (DTSConditionals as DTSleep_Conditionals).IsLeitoActive)
				return 1
			endIf
			
			return 0
		endIf
		if (obj.HasKeyword(DTSleep_PoolTableKeyword))
			if ((DTSConditionals as DTSleep_Conditionals).IsSavageCabbageActive)
				return 2
			endIf
			if ((DTSConditionals as DTSleep_Conditionals).IsRufgtActive)
				return 2
			endIf
			if ((DTSConditionals as DTSleep_Conditionals).IsLeitoAAFActive || (DTSConditionals as DTSleep_Conditionals).IsLeitoActive)
				return 1
			endIf
			
			return 0
		endIf
		
		if ((DTSConditionals as DTSleep_Conditionals).IsSavageCabbageActive)
			
			bool fallThru = false
			
			if (obj.HasKeyword(DTSleep_IntimateChairKeyword))
				return 1
			endIf
			if (obj.HasKeyword(AnimFurnCouchKY))
				
				if (GetIsOnIgnoreListSceneID(781) && GetIsOnIgnoreListSceneID(735))
					fallThru = true
					
				elseIf ((DTSConditionals as DTSleep_Conditionals).IsRZSexActive && (DTSConditionals as DTSleep_Conditionals).RZSexVers >= 2.50 && !GetIsOnIgnoreListSceneID(1140))
					; has both v3.20
					return 4
				else
					return 1
				endIf
			endIf
			
			if (baseBedForm == None)
				baseBedForm = obj.GetBaseObject()
			endIf

			if (DTSleep_IntimateCouchList.HasForm(baseBedForm))			; v3.15 removed 781 here since must have KY
				
				if (GetIsOnIgnoreListSceneID(735))
					fallThru = true
				else
					return 1
				endIf
			endIf
			if (!fallThru  && DTSleep_IntimateChairsList.HasForm(baseBedForm))
				return 1
			endIf
			if (!fallThru && DTSleep_IntimateChairThroneList.HasForm(baseBedForm))			; v2.70
				return 1
			endIf
			
			if (!fallThru && (DTSleep_IntimateBenchList.HasForm(baseBedForm)))
				
				if ((DTSConditionals as DTSleep_Conditionals).IsBP70Active && !GetIsOnIgnoreListSceneID(1030))
					if (!GetIsOnIgnoreListSceneID(759))
						return 4
					else
						return 3
					endIf
				endIf
				
				return 3
			endIf
		endIf
		
		if ((DTSConditionals as DTSleep_Conditionals).IsRZSexActive)			; v3.15 
			
			if (obj.HasKeyword(AnimFurnCouchKY))
				if ((DTSConditionals as DTSleep_Conditionals).RZSexVers >= 2.50 && !GetIsOnIgnoreListSceneID(1140) && !GetIsOnIgnoreListSceneID(1135))
					; has both v3.20
					return 4
				endIf
				if (!GetIsOnIgnoreListSceneID(1135))
					return 1
				endIf
				if (!GetIsOnIgnoreListSceneID(1140))
					return 3
				endIf
			endIf
			if (!GetIsOnIgnoreListSceneID(1162))
				if (baseBedForm == None)
					baseBedForm = obj.GetBaseObject()
				endIf
				if (DTSleep_IntimateDeskList.HasForm(baseBedForm))
					return 1
				endIf
			endIf
		endIf
		
		
		if ((DTSConditionals as DTSleep_Conditionals).IsBP70Active)	
			
			if (obj.HasKeyword(AnimFurnCouchKY))
				return 1
			endIf
			if (baseBedForm == None)
				baseBedForm = obj.GetBaseObject()
			endIf
			if (DTSleep_IntimateChairHighList.HasForm(baseBedForm))
				return 2
			endIf
			if (!GetIsOnIgnoreListSceneID(1030) && (DTSleep_IntimateBenchList.HasForm(baseBedForm)))
				if ((DTSConditionals as DTSleep_Conditionals).IsSavageCabbageActive && !GetIsOnIgnoreListSceneID(759))
					return 4
				else
					return 1
				endIf
			endIf
			if (DTSleep_IntimateCouchList.HasForm(baseBedForm) || DTSleep_IntimateChairsList.HasForm(baseBedForm))
				return 1
			endIf
		endIf
	endIf
	
	return 0
endFunction

; spanking  - v3.15 
bool Function HasFurnitureSpankChoice(ObjectReference obj, Form baseBedForm)
	
	if ((DTSConditionals as DTSleep_Conditionals).IsRZSexActive)
			
		if (!GetIsOnIgnoreListSceneID(1130))			; v3.21 - fix with correct sid
		
			if (baseBedForm == None)
				baseBedForm = obj.GetBaseObject()
			endIf
		
			if (DTSleep_IntimateKitchenSeatList.HasForm(baseBedForm))
				return true
			endIf
			if (DTSleep_IntimateBenchShortList.HasForm(baseBedForm))
				return true
			endIf
			if (DTSleep_IntimateChairHighNoArmsList.HasForm(baseBedForm))
				return true
			endIf
		endIf
		
		if ((DTSConditionals as DTSleep_Conditionals).RZSexVers >= 2.60 && !GetIsOnIgnoreListSceneID(1141))			; v3.21
		
			if (baseBedForm == None)
				baseBedForm = obj.GetBaseObject()
			endIf
			if (DTSleep_IntimateDeskList.HasForm(baseBedForm))
				return true
			endIf
		endIf
	endIf
	
	return false
endFunction

bool Function IsActorsWithinDistLimit(float dist, float heightA, float heightB, bool onBed)
	
	float limitLow = AnimActorOffsetDef - 2.88
	float limitHigh = AnimActorOffsetDef + 2.24

	if (SceneData.AnimationSet >= 5)
		limitLow -= 12.00
		limitHigh += 6.0
	endIf
	
	if (dist > limitLow && dist < limitHigh)
		float heightDiff = heightA - heightB
		
		if (onBed)
			if (heightDiff > -8.10 && heightDiff < 8.10)
				return true
			endIf
		
		elseIf (SceneData.AnimationSet >= 5)
			if (heightDiff > -5.00 && heightDiff < 5.00)
				return true
			endIf
			
		elseIf (SceneData.IsUsingCreature && heightDiff > -3.05 && heightDiff < 3.05)
			
			return true
		
		elseIf (heightDiff > -1.55 && heightDiff < 1.55)
			
			return true
		endIf
	endIf
	
	return false
endFunction

bool Function IsObjBed(ObjectReference obj)
	
	if (obj != None)
		if (obj.HasKeyword(IsSleepFurnitureKY))
			return true
		endIf
	endIf
	
	return false
endFunction

bool Function IsObjBedLimitedSpace(ObjectReference obj, Form baseBedForm)

	if (obj != None)
		if (baseBedForm == None)
			baseBedForm = obj.GetBaseObject()
		endIf
		if (DTSleep_BedsLimitedSpaceLst.HasForm(baseBedForm))
			return true
		endIf
	endIf
	
	return false
endFunction

bool Function IsObjBenchSofa(ObjectReference obj, Form baseBedForm)
	if (obj != None)
		if (obj.HasKeyword(AnimFurnCouchKY))
			return true
		endIf
		if (baseBedForm == None)
			baseBedForm = obj.GetBaseObject()
		endIf
		if (DTSleep_IntimateCouchList.HasForm(baseBedForm))
			return true
		elseIf (DTSleep_IntimateBenchList.HasForm(baseBedForm))
			return true
		endIf
	endIf
	
	return false
endFunction

bool Function IsObjSofa(ObjectReference obj, Form baseBedForm)
	if (obj != None)
		if (obj.HasKeyword(AnimFurnCouchKY))
			return true
		endIf
		if (baseBedForm == None)
			baseBedForm = obj.GetBaseObject()
		endIf
		if (DTSleep_IntimateCouchList.HasForm(baseBedForm))
			return true
		endIf
	endIf
	
	return false
endFunction

bool Function IsObjectDancePole(ObjectReference obj)

	if (obj != None && obj.HasKeyword(DTSleep_DancePoleKY))
		return true
	endIf

	return false
endFunction

bool Function IsObjDesk(ObjectReference obj, Form baseBedForm)
	if (obj != None)
		if (baseBedForm == None)
			baseBedForm = obj.GetBaseObject()
		endIf
		if (DTSleep_IntimateDeskList.HasForm(baseBedForm))
			return true
		endIf
	endIf
	
	return false
endFunction

bool Function IsObjDinerBoothTable(ObjectReference obj, Form baseBedForm)
	if (obj != None)
		if (baseBedForm == None)
			baseBedForm = obj.GetBaseObject()
		endIf
		if (DTSleep_IntimateDinerBoothTableAllList.HasForm(baseBedForm))
			return true
		endIf
	endIf
	
	return false
endFunction

bool Function IsObjKitchenCabinet(ObjectReference obj, Form baseForm)
	if (obj != None)
		if (baseForm == None)
			baseForm = obj.GetBaseObject()
		endIf
		if (DTSleep_IntimateKitchenCabinetList.HasForm(baseForm))
			return true
		endIf
	endIf
	return false
endFunction

bool Function IsObjKitchenCounter(ObjectReference obj, Form baseForm)
	
	if (obj != None)
		if (baseForm == None)
			baseForm = obj.GetBaseObject()
		endIf
		if (DTSleep_IntimateKitchenCounterList.HasForm(baseForm))
			return true
		endIf
	endIf
	return false
endFunction

bool Function IsObjMotorcycle(ObjectReference obj, Form baseForm)

	if (obj != None)
		if (obj.HasKeyword(DTSleep_MotorcycleKY))
			return true
		endIf
		if (baseForm == None)
			baseForm = obj.GetBaseObject()
		endIf
		if (DTSleep_IntimateMotorcycleList.HasForm(baseForm))
			return true
		endIf
	endIf
	return false
endFunction

bool Function IsObjSedan(ObjectReference obj, Form baseForm = None)
	if (GetObjSedanType(obj, baseForm) > 0)
		return true
	endIf
	return false
endFunction

; returns 1 for post-war and 2 for pre-war 
int Function GetObjSedanType(ObjectReference obj, Form baseForm = None)
	if (obj != None)
		if (obj.HasKeyword(DTSleep_SedanKeyword))
			return FurnTypeIsSedanPostWar
		endIf
		if (baseForm == None)
			baseForm = obj.GetBaseObject()
		endIf
		if (DTSleep_IntimateSedanPreWarList.HasForm(baseForm))
			return FurnTypeIsSedanPreWar
		endIf
	endIf
	
	return 0
endFunction

bool Function IsObjShower(ObjectReference obj, Form baseForm)
	if (obj != None)
		if (baseForm == None)
			baseForm = obj.GetBaseObject()
		endIf
		if (DTSleep_IntimateShowerList.HasForm(baseForm))
			return true
		endIf
	endIf
	return false
endFunction

bool Function IsObjSeat(ObjectReference obj)

	if (obj != None)
		; seats have different keywords for animations or no keyword
		if (obj.HasKeyword(AnimFurnChairSitAnimsKY))
			return true
			
		elseIf (obj.HasKeyword(AnimFurnBarStoolKY) || obj.HasKeyword(AnimFurnCouchKY) || obj.HasKeyword(AnimFurnEatingNoodlesKY))
			return true
			
		elseIf (obj.HasKeyword(AnimFurnStoolWithBarKY))				; v2.60
			return true
			
		elseIf (obj.HasKeyword(AnimFurnChairWithTableKY) || obj.HasKeyword(AnimFurnChairWithRadioKY))
			return true
			
		endIf
	endIf
	
	return false
endFunction

bool Function IsObjStool(ObjectReference obj)
	if (obj != None )
		if (obj.HasKeyword(AnimFurnBarStoolKY) || obj.HasKeyword(AnimFurnEatingNoodlesKY))
			return true
				
		elseIf (obj.HasKeyword(AnimFurnStoolWithBarKY))		
			return true
				
		endIf
	endIf
	
	return false
endFunction

bool Function IsObjPoolTable(ObjectReference obj, Form baseBedForm)

	if (obj != None)
		if (obj.HasKeyword(DTSleep_PoolTableKeyword))
			return true
		endIf
		if (baseBedForm == None)
			baseBedForm = obj.GetBaseObject() as Form
		endIf
		if (DTSleep_IntimatePoolTableList.HasForm(baseBedForm))
			return true
		endIf
	endIf
	return false
endFunction

bool Function IsObjTable(ObjectReference obj, Form baseBedForm)
	if (obj != None)
		
		if (obj.HasKeyword(DTSleep_PoolTableKeyword))
			return true
		endIf
		if (obj.HasKeyword(AnimFurnPicnickTableKY))
			return true
		endIf
		if (baseBedForm == None)
			baseBedForm = obj.GetBaseObject()
		endIf
		if (DTSleep_IntimateDeskList.HasForm(baseBedForm) || DTSleep_IntimateTableList.HasForm(baseBedForm))
			return true
		elseIf (DTSleep_IntimateDiningTableList.HasForm(baseBedForm))
			return true
		elseIf (DTSleep_IntimateRoundTableList.HasForm(baseBedForm))
			return true
		elseIf (DTSleep_IntimateDinerBoothTableAllList.HasForm(baseBedForm))
			return true
		elseIf (DTSleep_IntimatePatioTableList.HasForm(baseBedForm))			; v2.88
			return true
		endIf
	endIf
	
	return false
endFunction

bool Function IsSameScene(int sceneIDToPlay)
	if (sceneIDToPlay == LastSceneID || sceneIDToPlay == LastScenePrevID)
		return true
	elseIf (sceneIDToPlay == LastSceneOtherID || sceneIDToPlay == LastSceneOtherPrevID)
		return true
	endIf
	
	return false
endFunction


bool Function IsSequenceRunning()
	if (MainActorCloneRef != None && MainActorCloneRef.HasMagicEffectWithKeyword(DTSleep_IntimateMEKeyword))
		return true
	endIf
	if (MainActorRef != None && MainActorRef.HasMagicEffectWithKeyword(DTSleep_IntimateMEKeyword)) 
		return true
	endIf
	
	if (SecondActorRef != None && SecondActorRef.HasMagicEffectWithKeyword(DTSleep_IntimateMEKeyword))
		return true
	endIf
	if (SceneData.AnimationSet >= 5 && DTSleep_PlayAAFSceneQuest.IsRunning())
		; status-5 means the stop-scene has completed
		if ((DTSleep_PlayAAFSceneQuest as DTSleep_PlayAAFSceneScript).MySceneStatus < 5)
			
			return true
		endIf
	endIf
	
	return false
endFunction

bool Function IsASuperMutantBed(ObjectReference aBed, Form baseBedForm)
	if (aBed != None)
		if (aBed.HasKeyword(DTSleep_SMBed02KY))
			return true
		endIf
		if (baseBedForm == None)
			baseBedForm = aBed.GetBaseObject() as Form
		endIf
		if (DTSleep_IntimateSMBedList.HasForm(baseBedForm))
			return true
		endIf
	endIf
	
	return false
endFunction

bool Function IsFloorBed(ObjectReference aBed)
	if (aBed != None && aBed.HasKeyword(AnimFurnFloorBedAnimKY))
		return true
	endIf
	return false
endFunction

bool Function IsSleepingBag(ObjectReference aBed)
	
	if (aBed != None && aBed.HasKeyword(AnimFurnFloorBedAnimKY))
		if (aBed.HasKeyword(HC_Obj_SleepingBagKY))
			return true
		endIf
		
		if (aBed.IsActivationBlocked())
			; could be Campsite bag
			return true
		endIf
	endIf
	
	return false
endFunction

; ----------
; check this last after other beds
;
bool Function IsSleepingBunkBed(ObjectReference aBed, Form baseBedForm, bool isPillowBed = false)
	if (aBed != None)
		if (baseBedForm == None)
			baseBedForm = aBed.GetBaseObject() as Form
		endIf
		if (DTSleep_BedsBunkList.HasForm(baseBedForm))
			return true
		endIf
		bool searchOK = false
		if (isPillowBed)
			searchOK = true
		elseIf ((DTSConditionals as DTSleep_Conditionals).IsSnapBedsActive)
			searchOK = true
		endIf
		if (searchOK)
			ObjectReference bedFrameRef = DTSleep_CommonF.FindNearestAnyBedFromObject(aBed, DTSleep_BedBunkFrameList, None, 86.0)
			if (bedFrameRef != None)
				return true
			endIf
		endIf
	endif
	
	return false
endFunction

bool Function IsSleepingDoubleBed(ObjectReference aBed, Form baseBedForm, bool isPillowBed = false)
	if (aBed != None)
		if (baseBedForm == None)
			baseBedForm = aBed.GetBaseObject() as Form
		endIf
		if (DTSleep_BedsBigDoubleList.HasForm(baseBedForm) || DTSleep_BedPillowFrameDBList.HasForm(baseBedForm))
			return true
			
		elseIf (isPillowBed)
			ObjectReference bedFrameRef = DTSleep_CommonF.FindNearestAnyBedFromObject(aBed, DTSleep_BedPillowFrameDBList, None, 86.0)
			if (bedFrameRef != None)
				return true
			endIf
		endIf
	endif
	
	return false
endFunction

;  also sets SceneData.AnimationSet based on scene ID obtained
;
int Function PickIntimateSceneID(bool mainActorIsMaleRole, bool standOnly, int[] animSetsIDArray, int includeHugs = 0, int preferSID = -1)

	int rand = 0
	int sceneIDToPlay = LastSceneID
	int tryCount = 0
	bool actorOnBed = false
	bool checkFurnitures = false
	bool noLeitoGun = false 
	bool hasBigPack = false
	int packLimitPrefVal = DTSleep_SettingPackPick.GetValueInt()				; v3.15
	if (packLimitPrefVal >= 2 && packLimitPrefVal <= 4)
		packLimitPrefVal = -1
	elseIf (packLimitPrefVal > 11)
		packLimitPrefVal = -1
	endIf
	
	if (preferSID >= 100 && MySceneIgnoreArray.Length > 0 && MySceneIgnoreArray.Find(preferSID) >= 0)
		preferSID = -1			; reset preferred SID for being on ignore list
		
	elseIf (preferSID >= 100 && packLimitPrefVal > 0)
		; is same pack??   - v3.15
		int pPrefNum = Math.Floor(preferSID as float / 100.0)
		if (pPrefNum != packLimitPrefVal)
			preferSID = -2
		endIf
	endIf
	
	ObjectReference[] nearStoolsArr = new ObjectReference[0]
	ObjectReference[] nearChairsArr = new ObjectReference[0]
	ObjectReference[] nearCouchArr = new ObjectReference[0]
	
	if (SleepBedRef == None || !IsObjBed(SleepBedRef))
		if (MySleepBedFurnType != FurnTypeIsTablePool && MySleepBedFurnType != FurnTypeIsTablePicnic)		; v2.71 fix repeats
			sceneIDToPlay = LastSceneOtherID
		endIf
	endIf

	
	if (animSetsIDArray == None || animSetsIDArray.Length == 0)
		return -1
	endIf
	
	if (animSetsIDArray.Length > 2)
		hasBigPack = true
	endIf
	
	if (SleepBedRef == None)
		
		Debug.Trace(myScriptName + " pick scene ID !!!! no furniture !!!")
		return -2
	endIf
	
	SceneIDArrayPrepMyFurnitureType()				; v2.35 init MySleepBedFurnType before searching for scene IDs
	
	if (!MainActorPositionByCaller && !standOnly && MySleepBedFurnType > 10 && MySleepBedFurnType < 200)
		if (DTSleep_CommonF.IsActorOnBed(MainActorRef, SleepBedRef))
			actorOnBed = true
		else
			standOnly = true
		endIf
	endIf
	
	int[] sceneIDArray = new int[0]
	int pickCount = 0
	
	while (pickCount < 2)
	
		int animIdx = 0
		while (animIdx < animSetsIDArray.Length)
			int packID = animSetsIDArray[animIdx]
			noLeitoGun = false
			
			if (packID == 7 || packID == 10)
				checkFurnitures = true
				hasBigPack = true
				
			elseIf (packID == 1 || packID == 6) 
			
				hasBigPack = true
				
				if (DTSleep_SettingUseLeitoGun.GetValue() <= 0.0)
					if (packID < 5 || DTSleep_SettingUseBT2Gun.GetValue() <= 0.0)				; allow BodyTalk for newer packs v2.73
						noLeitoGun = true
					endIf
				elseIf (SceneData.SameGender && SceneData.MaleRoleGender == 1)
					noLeitoGun = true
				endIf
			endIf
			
			sceneIDArray = SceneIDArrayForAnimationSet(packID, mainActorIsMaleRole, noLeitoGun, standOnly, sceneIDArray, includeHugs, packLimitPrefVal)
			

			animIdx += 1
		endWhile
		
		if (sceneIDArray.Length > 0)
			pickCount = 100
			
		elseIf (packLimitPrefVal > 0)
			Debug.Trace(myScriptName + " --- no packPick " + packLimitPrefVal + " scenes found, try again and pick from any pack")
			packLimitPrefVal = 0			; try again without limiting by animation pack    v3.15
			
		elseIf (SceneData.SecondFemaleRole != None || SceneData.SecondMaleRole != None)
			SceneData.SecondFemaleRole = None
			SceneData.SecondMaleRole = None
		elseIf (standOnly)
			standOnly = false
		else
			pickCount = 10  ; nothing to find
			sceneIDToPlay = -1
			if (MainActorScenePrefArray.Length > 0)
				MainActorScenePrefArray.Clear()
			endIf
		endIf
		
		pickCount += 1
	endWhile
	
	UpdateMyLastScenes(sceneIDArray)

	if (DTSleep_SettingTestMode.GetValue() > 0.0 && DTSleep_DebugMode.GetValue() >= 1.0)	
		Debug.Trace(myScriptName + " PickIntimateSceneID found " + sceneIDArray.Length + " scenes (before ignored) from " + animSetsIDArray.Length + " packs")
		Debug.Trace(myScriptName + " scenes: " + MyLastSceneListArray)
		Debug.Trace(myScriptName + "   orig: " + sceneIDArray)
		; v2.73 check ignored by comparing
		Debug.Trace(myScriptName + " SameGender? " + SceneData.SameGender + ", maleGender? " + SceneData.MaleRoleGender + ", hasToy? " + SceneData.HasToyAvailable)
	endIf
	
	int tryIdx = 0
	int tryLimit = 2
	if (MyLastSceneListArray.Length <= tryLimit)
		tryLimit = MyLastSceneListArray.Length
	endIf
	
	if (preferSID >= 100 && MyLastSceneListArray.Find(preferSID) >= 0)							; v2.70 allow preference
		sceneIDToPlay = preferSID
		if (DTSleep_SettingTestMode.GetValue() > 0.0 && DTSleep_DebugMode.GetValue() >= 1.0)
			Debug.Trace(myScriptName + " replay preferred Scene ID: " + sceneIDToPlay)
		endIf
	else
	
		while (tryIdx < MyLastSceneListArray.Length && tryIdx < 5 && IsSameScene(sceneIDToPlay))
		
			if (tryIdx < tryLimit && MyLastSceneListArray.Length > 3)
				if (MyLastSceneListArray.Length > 6)
					rand = (DT_RandomQuestP as DT_RandomQuestScript).GetNextInRangePublic(0, MyLastSceneListArray.Length - 1)
				else
					rand = Utility.RandomInt(0, MyLastSceneListArray.Length - 1)
				endIf
			elseIf (rand < MyLastSceneListArray.Length - 1)
				rand += 1
			elseIf (rand > 0)
				rand -= 1
			endIf

			sceneIDToPlay = MyLastSceneListArray[rand]
			
			tryIdx += 1
		endWhile
	endIf
	
	if (sceneIDToPlay >= 100)
		int p = Math.Floor(((sceneIDToPlay) as float) / 100.0)
		SceneData.AnimationSet = p
	else
		SceneData.AnimationSet = 0
	endIf
	
	bool groupPlay = false
	if (SceneData.AnimationSet > 0 && DTSleep_AdultContentOn.GetValue() >= 2.0)
		; sex scenes - most chosen by player, but let's confirm and check for replacement
		if (SceneData.SecondMaleRole != None || SceneData.SecondFemaleRole != None)
		
			if (SceneIDIsGroupPlay(sceneIDToPlay))
				groupPlay = true
				if (SceneData.SecondMaleRole != None)
					SceneData.SecondMaleRole.PlayIdle(LooseIdleStop2)
				endIf
				if (SceneData.SecondFemaleRole != None)
					SceneData.SecondFemaleRole.PlayIdle(LooseIdleStop2)
				endIf
			endIf

			; v2.50 - no replace on random -- have enough scenes
			; randomly replace for more variety
			;if (SceneData.SecondMaleRole != None && MainActorScenePrefArray.Length == 0 && !MainActorPositionByCaller && LastSceneID != 758 && sceneIDToPlay != 735 && sceneIDToPlay >= 700 && sceneIDToPlay < 800 && sceneIDArray.Length <= 2 && Utility.RandomInt(1, 12) < 3)
			;	sceneIDToPlay = 758
			;	groupPlay = true
			;	SceneData.SecondFemaleRole = None
			;	SceneData.SecondMaleRole.PlayIdle(LooseIdleStop2)
			;endIf
		endIf
		
	elseIf (sceneIDToPlay > 80)
		; no group for hugs and kisses
		groupPlay = false
		
	elseIf (SceneData.SecondFemaleRole != None)
		; extra female dancer
		groupPlay = true
		SceneData.SecondFemaleRole.PlayIdle(LooseIdleStop2)
		SceneData.SecondMaleRole = None
	elseIf (SceneData.SecondMaleRole != None)
		; extra male dancer
		groupPlay = true
		SceneData.SecondMaleRole.PlayIdle(LooseIdleStop2)
	endIf
		
	if (groupPlay)
		SecondActorRef.PlayIdle(LooseIdleStop)		; may have been swapped
	else
		; no group - clear extras
		ClearSecondActors()
	endIf

	if (sceneIDArray.Length == 0)
		return -1
		
	elseIf (MainActorScenePrefArray.Length > 0)
		; player picked
		return sceneIDToPlay
		
	elseIf (!groupPlay && LastSceneID >= 100 && LastScenePrevID >= 100 && sceneIDArray.Length < 3 && sceneIDToPlay >= 100 && DTSleep_CommonF.IsIntegerInArray(LastSceneID, sceneIDArray) && sceneIDToPlay < 700 && !SceneData.IsUsingCreature && !hasBigPack)
		rand = Utility.RandomInt(1, 7)
		if (rand == 2 || rand == 5)
			;	 too few including one from last scene - force hug/dance
			return -2
		endIf
	endIf
	
	return sceneIDToPlay 
endFunction

bool Function PlayCheer()
	return PlayIdleAnimationID(10, GetTimeForPlayID(10))
endFunction

bool Function PlayClapping()
	return PlayIdleAnimationID(0, GetTimeForPlayID(0))
endFunction


bool Function PlayIdleAnimationID(int id, float timerSecs)
	DTSleep_IntimateIdleID.SetValueInt(id)
	
	if (id > 50 && id < 100)
		return PlayIntimateAACWithEndTimer(timerSecs)
		
	elseIf (id >= 400 && id < 500)
		return PlayIntimateAACWithEndTimer(timerSecs)
	elseIf (id >= 100 && id < 200)
		return PlayIntimateLeitoAnimWithEndTimer(timerSecs)
	elseIf (id >= 200 && id < 300)
		return PlayIntimateCrazyGAnimWithEndTimer(timerSecs)
	endIf
	
	return PlayIdleAnimationWithEndTimer(timerSecs)
endFunction

bool Function PlayIdleAnimationWithEndTimer(float timerSecs)

	if (SecondActorRef != None && !SceneData.CompanionInPowerArmor && !SceneData.IsUsingCreature)
	
		SecondActorRef.PlayIdle(LooseIdleStop2)
		Utility.Wait(0.333)
		if (MainActorCloneRef != None)
			DTSLeep_PlayIdleTargetSpell.Cast(MainActorCloneRef as ObjectReference, SecondActorRef as ObjectReference)
		else
			DTSLeep_PlayIdleTargetSpell.Cast(MainActorRef as ObjectReference, SecondActorRef as ObjectReference)
		endIf
		
	elseIf (MainActorRef != None)
		DTSLeep_PlayIdleSpell.Cast(MainActorRef as ObjectReference)
	else
		return false
	endIf
	
	StartTimer(timerSecs - 1.0, SeqEndTimerID)
	
	return true
endFunction

bool Function PlayIntimateAAFSceneWithEndTimer(float timerSecs)

	bool startOK = false
	
	if (DTSleep_PlayAAFSceneQuest && SecondActorRef)
		if (!Debug.GetPlatformName() as bool)
			return false
		endIf
		;MainActorRef.SetRestrained(false) - never restrained
		SecondActorRef.SetRestrained(false)
		if (SceneData.SecondMaleRole != None)
			SceneData.SecondMaleRole.SetRestrained(false)
		endIf
		
		SecondActorRef.PlayIdle(LooseIdleStop2)
		Utility.Wait(0.333)

		DTSleep_PlayAAFSceneQuest.Start()
		
		RegisterForCustomEvent((DTSleep_PlayAAFSceneQuest as DTSleep_PlayAAFSceneScript), "SleepIntAAFPlayDoneEvent")
		Utility.Wait(0.1)
		
		startOK = (DTSleep_PlayAAFSceneQuest as DTSleep_PlayAAFSceneScript).StartupScenePublic(MainActorRef, SecondActorRef, SleepBedRef, FadeEnable)
		
	else
		return false
	endIf
	
	; using event v1.47
	;int i = 0
	;; give time for AAF setup before starting sync timer
	;while (i < 64 && (DTSleep_PlayAAFSceneQuest as DTSleep_PlayAAFSceneScript).MySceneStatus < 1)
	;	Utility.Wait(0.5)
	;	i += 1
	;endWhile
	
	if (!FadeEnable && DTSleep_SettingAAF.GetValueInt() == 2)
		; more time to allow for walk
		timerSecs += 9.0
	endIf
	
	if (startOK)
		if (DTSleep_SettingTestMode.GetValue() > 0.0 && DTSleep_DebugMode.GetValue() >= 1.0)
			Debug.Trace(MyScriptName + " Play AAF Animation {" + DTSleep_IntimateIdleID.GetValueInt() + "} with timer: " + timerSecs)
		endIf
		
		if ((DTSleep_PlayAAFSceneQuest as DTSleep_PlayAAFSceneScript).MySceneStatus <= 1)
			StartTimer(timerSecs, SeqEndTimerID)
		else
			StartTimer(3.0, SeqEndTimerID)
		endIf
		
		return true
	else
		FinalizeAndSendFinish(false)
	endIf
	
	return false
endFunction

bool Function PlayIntimateCrazyGAnimWithEndTimer(float timerSecs)
	
	if (DTSleep_PlayCrazyGTargetSpell && SecondActorRef != None && !SceneData.CompanionInPowerArmor)
		if (!Debug.GetPlatformName() as bool)
			return false
		endIf
		SecondActorRef.PlayIdle(LooseIdleStop2)
		Utility.Wait(0.333)
		if (MainActorCloneRef != None)
			DTSleep_PlayCrazyGTargetSpell.Cast(MainActorCloneRef as ObjectReference, SecondActorRef as ObjectReference)
		else
			DTSleep_PlayCrazyGTargetSpell.Cast(MainActorRef as ObjectReference, SecondActorRef as ObjectReference)
		endIf
	else
		return false
	endIf
	
	if (DTSleep_SettingTestMode.GetValue() > 0.0 && DTSleep_DebugMode.GetValue() >= 1.0)
		Debug.Trace(MyScriptName + " Play CrazyG Animation {" + DTSleep_IntimateIdleID.GetValueInt() + "} with timer: " + timerSecs)
	endIf
	
	StartTimer(timerSecs - 1.0, SeqEndTimerID)
	
	return true
endFunction

bool Function PlayIntimateCrazyRugAnimWithEndTimer(float timerSecs)
	if (DTSleep_PlayCrazyRugTargetSpell && SecondActorRef != None && !SceneData.CompanionInPowerArmor)
		DTSleep_PlayCrazyRugTargetSpell.Cast(MainActorRef as ObjectReference, SecondActorRef as ObjectReference)
	else
		return false
	endIf

	; using a wait-for-ME so reduce timer a few to fade out early
	timerSecs -= 0.80
	
	StartTimer(timerSecs, SeqEndTimerID)
	
	return true
endFunction

bool Function PlayIntimateAACWithEndTimer(float timerSecs)
	if (DTSleep_PlayAACSpell != None)

		if (SecondActorRef != None)
			
			if (!SecondActorRef.WornHasKeyword(isPowerArmorFrame))
				SecondActorRef.PlayIdle(LooseIdleStop2)
				Utility.Wait(0.333)
			endIf
			
			if (MainActorCloneRef != None)
				DTSleep_PlayAACSpell.Cast(MainActorCloneRef as ObjectReference, SecondActorRef as ObjectReference)
			else
				DTSleep_PlayAACSpell.Cast(MainActorRef as ObjectReference, SecondActorRef as ObjectReference)
			endIf
		elseIf (MainActorCloneRef != None)
			;Debug.Trace(myScriptName + " play AAC single-caster on Clone )
			MainActorRef.SetGhost(false)
			MainActorRef.SetAlpha(1.0)
			MainActorRef.RemoveSpell(DTSleep_InvisibiltySpell)
			Utility.Wait(0.1)
			DTSleep_PlayAACSpell.Cast(MainActorCloneRef as ObjectReference, MainActorRef as ObjectReference)
		else
			;Debug.Trace(MyScriptName + " PlayACC single-caster ") 
			DTSleep_PlayAACSpell.Cast(MainActorRef as ObjectReference, MainActorRef as ObjectReference)
		endIf
	else
		return false
	endIf
	
	if (DTSleep_SettingTestMode.GetValue() > 0.0 && DTSleep_DebugMode.GetValue() >= 1.0)
		Debug.Trace(MyScriptName + " Play AAC Animation (" + DTSleep_IntimateIdleID.GetValueInt() + ") with timer: " + timerSecs + ", and SceneLenVal = " + DTSleep_IntimateSceneLen.GetValueInt())
	endIf
	
	; using a wait-for-ME so reduce timer a few to fade out early
	timerSecs -= 1.80
	
	StartTimer(timerSecs, SeqEndTimerID)
	
	return true
endFunction

bool Function PlayIntimateLeitoAnimWithEndTimer(float timerSecs)
	if (DTSleep_PlayLeitoTargetSpell != None)
		if (Debug.GetPlatformName() as bool)

			if (SecondActorRef != None && !SceneData.CompanionInPowerArmor && SceneData.IsCreatureType != 3)
				SecondActorRef.PlayIdle(LooseIdleStop2)
				Utility.Wait(0.333)
				
				if (MainActorCloneRef != None)
					DTSleep_PlayLeitoTargetSpell.Cast(MainActorCloneRef as ObjectReference, SecondActorRef as ObjectReference)
				else
					DTSleep_PlayLeitoTargetSpell.Cast(MainActorRef as ObjectReference, SecondActorRef as ObjectReference)
				endIf
			else
				DTSleep_PlayLeitoTargetSpell.Cast(MainActorRef as ObjectReference, MainActorRef as ObjectReference)
			endIf
		else
			return false
		endIf
	else
		return false
	endIf
	
	if (DTSleep_SettingTestMode.GetValue() > 0.0 && DTSleep_DebugMode.GetValue() >= 1.0)
		Debug.Trace(MyScriptName + " Play Leito Animation (" + DTSleep_IntimateIdleID.GetValueInt() + ") with timer: " + timerSecs)
	endIf
	
	; using a wait-for-ME so reduce timer a few to fade out early
	timerSecs -= 0.80
	
	StartTimer(timerSecs, SeqEndTimerID)
	
	return true
endFunction


; place markers on bed and move actors to markers
;  - assumed have SleepBedRef set
;
bool Function PositionIdleMarkersForBed(int id, bool mainActorIsMaleRole, bool useAlternateBedAngle)
	bool playerPositioned = false
	bool mainNodeOnBed = false
	bool seqGoodToGo = true
	bool useTempBed  = false
	bool standOnly = SceneIDAtPlayerPosition(id)
	bool forceMainActorPosition = false
	bool bedIsCoffin = false
	int attemptCount = 2
	MainActorOriginMarkRef = None   ; ensure reset
	MainActorIsReverseHeading = false
	SleepBedShiftedDown = 0.0
	SceneData.FemaleMarker = None
	float rTimeStart = Utility.GetCurrentRealTime()
	float offsetForActors = AnimActorOffsetDef
	
	if (id >= 400)
		offsetForActors = 0.0
	endIf
	
	SceneData.PlayerRoleTranslated = 0
	SceneData.MarkerOrientationAllowance = 0
	if (IsObjBed(SleepBedRef))
		SceneData.MarkerOrientationAllowance = 20
	endIf
	
	
	; may move this node
	ObjectReference mainNode = DTSleep_CommonF.PlaceFormAtObjectRef(DTSleep_MainNode, MainActorRef)
	float rTimeElapse = Utility.GetCurrentRealTime()
	ObjectReference intimateMarkerRef = None
	
	if (mainNode != None && mainNode.Is3DLoaded())
	
		if (SecondActorRef != None)
			
			SecondActorRef.SetRestrained()   ; re-restrain
			if (SceneData.SecondMaleRole != None)
				SceneData.SecondMaleRole.SetRestrained()
			endIf
		endIf
		
		; special cases first
		
		if (SceneIDIsSolo(id))			; pole dance or self
		
			if (SleepBedRef != None && !MainActorPositionByCaller)
				mainNode.MoveTo(SleepBedRef)
				SceneData.MaleMarker = DTSleep_CommonF.PlaceFormAtObjectRef(DTSleep_MainNode, SleepBedRef, false, true, true)
				
				float zOffset = PositionMarkerOnBedZAdjustForSceneID(id)
				if (zOffset != 0.0)
					mainNode.MoveTo(SleepBedRef, 0.0, 0.0, zOffset, true)
					SceneData.MaleMarker.MoveTo(SleepBedRef, 0.0, 0.0, zOffset, true)
				endIf
			endif
			
			if (MainActorCloneRef != None)
				
				MainActorCloneRef.MoveTo(mainNode, 0.0, 0.0, 0.0, true)
				DTSleep_CommonF.MoveActorToObject(MainActorCloneRef, mainNode)
				Utility.Wait(0.3)
				
			elseIf (!IsAAFEnabled())
				if (MainActorOriginMarkRef == None)
					; before moving mark main actor original position to place actor back later
					MainActorOriginMarkRef = DTSleep_CommonF.PlaceFormAtObjectRef(DTSleep_MainNode, MainActorRef)
				endIf
			
				;MainActorMovedCount += 1
				;MainActorRef.MoveTo(mainNode, 0.0, 0.0, 0.0, true)

				DTSleep_CommonF.MoveActorToObject(MainActorRef, mainNode)
				Utility.Wait(1.0)
			endIf
			
			return true
		
		elseIf (MainActorPositionByCaller)
			; TODO: hugs?
			if (id >= 500 && !IsAAFEnabled())
			
				if (SceneIDAtPlayerPosition(id) == false)
					mainNode.MoveTo(MainActorRef, 0.0, 50.5, 0.0, true)
					if (id >= 700 && id < 800)
						mainNode.SetAngle(0.0, 0.0, MainActorRef.GetAngleZ() + 167.0)
					else
						
						mainNode.SetAngle(0.0, 0.0, MainActorRef.GetAngleZ() + 33.0)
					endIf
				endIf
			endIf
		endIf
		
		if (SleepBedRef != None)
			
			bool revHeading = false
			float xOffset = 0.0
			float yOffset = 0.0
			
			bool onFloorOK = false
			bool restrictPlaceOnBed = false	; 1.46 so we can include Strong for all beds 
			bool sleepBedIsDoubleBed = IsSleepingDoubleBed(SleepBedRef, None, SleepBedIsPillowBed)
			bool isFloorBed = false
			
			if (MySleepBedFurnType == FurnTypeIsCoffin)
				bedIsCoffin = true
				isFloorBed = true
				
			elseIf (MySleepBedFurnType < 200)
				;ShiftSleepBedZ(-3.0)
				isFloorBed = true
				SleepBedShiftedDown = 3.0
			elseIf (SceneData.IsUsingCreature)
				; can't place on big beds
				restrictPlaceOnBed = true
			endIf
			
			; this overall attempt -- if placing actors near bed fails then try on bed
			while (attemptCount > 0)
			
				if (id < 1600)
					
					if (!mainActorIsMaleRole && MySleepBedFurnType == FurnTypeIsSleepingBag)
						onFloorOK = true
					elseIf (standOnly)
						onFloorOK = true
					endIf
					
					if (!MainActorPositionByCaller && bedIsCoffin)
						yOffset = 33.2
						useAlternateBedAngle = false

						revHeading = false
						if (mainActorIsMaleRole && id < 300)
							yOffset -= AnimActorOffsetDef
						endIf
						if (standOnly && !mainActorIsMaleRole)
							onFloorOK = true
						else
							onFloorOK = false
						endIf
					
					elseIf (id >= 400)

						; AAF-style do not move player character - move other character or mainNode
						if (MainActorPositionByCaller)
							if (id > 505 && id < 700)
								onFloorOK = true
							elseIf (id >= 1000)
								onFloorOK = true
							elseIf (id >= 490 && id < 500)
								onFloorOK = true
							endIf
							
						elseIf (id > 505 && id < 600)
							mainActorIsMaleRole = false	; force to position 2nd actor behind
							if (id == 550)								; v2.87
								onFloorOK = true
							endIf
							
						elseIf (id >= 650 && id < 682)					; v2.73 - changed upper limit to use newer Leito in AAC
							if (id >= 660)
								yOffset = 13.0				; v3.15 reduced from 15.0
								onFloorOK = true
							elseIf (!mainActorIsMaleRole || MySleepBedFurnType == FurnTypeIsSleepingBag)
								onFloorOK = true
							elseIf (id == 650 || id == 654)
								onFloorOK = true
							endIf
						elseIf (id == 695)									; standing Strong scene v2.73
							onFloorOK = true
						elseIf (id >= 600 && id < 650)
							yOffset = -24.0
							
							if (id >= 604 && id <= 609)
								;cowgirl
								yOffset = -20.0
								if (mainActorIsMaleRole)
									if (Utility.RandomInt(0, 1) == 0)
										revHeading = true
										yOffset = 16.0
									endIf
								endIf
							endIf
						elseIf (id == 740)									; dance just in case v2.73
							onFloorOK = true
						endIf
						
					elseIf (id < 100)
						yOffset = -15.0
						
						if (!mainActorIsMaleRole && !MainActorPositionByCaller && (DT_RandomQuestP as DT_RandomQuestScript).GetNextInRangePublic(-6, 7) > 4)
							; randomly swap positions
							mainActorIsMaleRole = !mainActorIsMaleRole
						endIf
						
						if (mainActorIsMaleRole)
							onFloorOK = true
							yOffset = -8.0
							playerPositioned = true ; keep from moving - v1.55 for new style in 1.46
						else
							revHeading = true
						endIf
					elseIf (id >= 104 && id <= 109)
						;cowgirl
						
						if (mainActorIsMaleRole)
							if (Utility.RandomInt(0, 1) == 0)
								revHeading = true
								yOffset = 4.25	;v1.65 increased to avoid standing on head/bar
								if (sleepBedIsDoubleBed)
									yOffset += 1.75
								endIf
							else
								onFloorOK = true
								if (sleepBedIsDoubleBed)
									yOffset = -2.0
								endIf
							endIf
						endIf
						
					elseIf (id >= 102 && id < 104)
						if (mainActorIsMaleRole)
							yOffset = -2.0
							onFloorOK = true
						else
							yOffset = -1.0
						endIf
						if (sleepBedIsDoubleBed)
							yOffset = -9.0
						endIf
					elseIf (id == 110)  ; spoon
						if (mainActorIsMaleRole)
							xOffset = -7.4
						else
							xOffset = 9.2
							yOffset = 1.0
						endIf
					elseIf (id >= 150 && id < 156)
						yOffset = 2.0
						if ((!mainActorIsMaleRole && MySleepBedFurnType != FurnTypeIsTablePool && MySleepBedFurnType != FurnTypeIsTablePicnic) || MySleepBedFurnType == FurnTypeIsSleepingBag)
							onFloorOK = true
						elseIf (id == 150 || id == 154)
							onFloorOK = true
						endIf
					elseIf (id >= 160 && id < 170)
						yOffset = 15.0
						onFloorOK = true
					elseIf (id >= 170 && id < 180)
						; canine
						yOffset = -8.2
						onFloorOK = false 
						
						if (MainActorPositionByCaller)
							useTempBed = false
							onFloorOK = true
						else
							useTempBed = true
						endIf
					elseIf (id == 180 || id == 280)
						onFloorOK = false	; female solo
						yOffset = -6.0
						
					elseIf (id == 181 || id == 281)
						onFloorOK = false		; 2 females solo
						yOffset = 30.2
					elseIf (id >= 200 && id < 250)
						; Crazy bed
						yOffset = 53.5
					elseIf (id >= 250 && id < 300)
						; Crazy stand
						yOffset = 6.0
					endIf
					
					; -----------------------------------------------------
					
					if (onFloorOK && standOnly && MainActorMovedCount < 1 && attemptCount > 1)

						mainNodeOnBed = false
						;if (id < 700 && attemptCount == 2 && !MainActorPositionByCaller)
						;	TurnActorAtAngle(MainActorRef, 2.1)
						;endIf

						if (MainActorPositionByCaller == false)
							; v2.73 - changed upper limit (from 700 to 682) to use newer Leito for chairs
							bool idOK = false				; v3.15
							if (id >= 100 && id < 682)		
								idOK = true
							elseIf (id == 1150)
								idoK = true
							endIf
							
							if (idOK && mainActorIsMaleRole && !MainActorIsReverseHeading && MySleepBedFurnType != FurnTypeIsSleepingBag)
								
								; turn main actor around  
								MainActorIsReverseHeading = true
								if (id > 505)
									mainNode.SetAngle(0.0, 0.0, 176.0 + mainNode.GetAngleZ())
									
									if (MainActorCloneRef == None)
										TurnActorAtAngle(MainActorRef, 180.0)
									else
										TurnActorAtAngle(MainActorCloneRef, 180.0)
									endIf
								endIf
							endIf
						endIf
						
					elseIf (!MainActorPositionByCaller && id >= 600 && id < 650)
						
						float zOffset = PositionMarkerOnBedZAdjustForSceneID(id)
						mainNodeOnBed = true
						if (SleepBedAltRef != None)
							PositionMarkerOnBed(mainNode, SleepBedAltRef, xOffset, yOffset, zOffset -3.5, true, false, revHeading, useAlternateBedAngle)
						else
							PositionMarkerOnBed(mainNode, SleepBedRef, xOffset, yOffset, zOffset, true, false, revHeading, useAlternateBedAngle)
						endIf
						Utility.Wait(0.08)
						
					elseIf (!MainActorPositionByCaller && id >= 1100 && id < 1150)				; v3.15
					
						float zOffset = PositionMarkerOnBedZAdjustForSceneID(id)
						
						mainNodeOnBed = true
						if (SleepBedAltRef != None)
							PositionMarkerOnBed(mainNode, SleepBedAltRef, xOffset, yOffset, zOffset -3.5, true, false, revHeading, useAlternateBedAngle)
						else
							PositionMarkerOnBed(mainNode, SleepBedRef, xOffset, yOffset, zOffset, true, false, revHeading, useAlternateBedAngle)
						endIf
						
					elseIf (!mainNodeOnBed && MainActorCloneRef != None && id >= 650 && id < 682)	 ;v2.73 - changed upper limit to use newer Leito in AAC
					
						mainNodeOnBed = true
						float zOffset = PositionMarkerOnBedZAdjustForSceneID(id)
						if (SleepBedAltRef != None)
							PositionMarkerOnBed(mainNode, SleepBedAltRef, xOffset, yOffset, zOffset -3.5, true, false, revHeading, useAlternateBedAngle)
						else
							PositionMarkerOnBed(mainNode, SleepBedRef, xOffset, yOffset, zOffset, true, false, revHeading, useAlternateBedAngle)
						endIf
						
					elseIf (id < 400 && !playerPositioned && !restrictPlaceOnBed && !MainActorPositionByCaller && !mainNodeOnBed)  
						; v1.23 - added !mainNodeOnBed to avoid twice move
						; v1.46 - added restrictPlaceOnBed
						; v1.55 - player positioned to force
						
						mainNodeOnBed = true
						
						if (MySleepBedFurnType != FurnTypeIsCoffin)
							if (!revHeading && MySleepBedFurnType == FurnTypeIsLimitedSpaceBed)
								revHeading = true
								
								if (!MainActorIsReverseHeading)
									MainActorIsReverseHeading = true
								endIf
								if (id >= 150 && id < 156)
									yOffset += 5.8
								else
									yOffset += 3.67
								endIf
							endIf
							
							; v1.61 - double solo
							if (id == 181 || id == 281)
								if (SleepBedTwinRef == None)
									xOffset = -26.0
									yOffset = 29.0
								endIf
							; v1.41 - big bed has more room
							elseIf (SleepBedAltRef != None || DTSleep_BedsBigList.HasForm(SleepBedRef.GetBaseObject() as Form))
								if (mainActorIsMaleRole)
									yOffset -= 3.60
								else
									yOffset -= 1.333
								endIf
								if (revHeading)
									yOffset = yOffset + yOffset + yOffset
								endIf
							endIf
						endIf

						float zOffset = PositionMarkerOnBedZAdjustForSceneID(id)	; v2.24 to place on table else should be zero
						
						if (SleepBedAltRef != None)
							PositionMarkerOnBed(mainNode, SleepBedAltRef, xOffset, yOffset, zOffset - 3.0, true, mainActorIsMaleRole, revHeading, useAlternateBedAngle)
						else
							PositionMarkerOnBed(mainNode, SleepBedRef, xOffset, yOffset, zOffset, true, mainActorIsMaleRole, revHeading, useAlternateBedAngle)
						endIf
						
						if (useTempBed)
							mainNode.SetAngle(0.0, 0.0, mainNode.GetAngleZ() - 8.0)
						endIf
						
					
						; TODO: for translated, can we move actors back more?
						; not always translating for id < 400
						
						if (MainActorOriginMarkRef == None)
						
							; before moving mark main actor original position to place actor back later
							MainActorOriginMarkRef = DTSleep_CommonF.PlaceFormAtObjectRef(DTSleep_MainNode, MainActorRef)
						endIf
						
						if (MainActorCloneRef != None)
							
							MainActorCloneRef.MoveTo(mainNode, 0.0, 0.0, 0.0, true)
							DTSleep_CommonF.MoveActorToObject(MainActorCloneRef, mainNode)
							Utility.Wait(0.5)
							
						elseIf (MainActorRef.GetDistance(mainNode) > 4.0)
							MainActorMovedCount += 1
							MainActorRef.MoveTo(mainNode, 0.0, 0.0, 0.0, true)
						else
							
							int angleLim = 20
							float angleNode = mainNode.GetAngleZ()
							int angleDiff = DTSleep_CommonF.DistanceBetweenAngles(angleNode, MainActorRef.GetAngleZ())
							if (sleepBedIsDoubleBed)
								angleLim = 32
							endIf
							
							if (angleDiff > angleLim)
								MainActorMovedCount += 1
								MainActorRef.MoveTo(mainNode, 0.0, 0.0, 0.0, true)
							else
								mainNode.MoveTo(MainActorRef, 0.0, 0.0, 0.0, true)
							endIf
						endIf
						
						Utility.Wait(0.1)
					endIf
					
					playerPositioned = true
					
				endIf
				
				if (SecondActorRef != None && id != 740)
					
					ObjectReference myMainAtMeNode = None
					if (MainActorCloneRef != None)
						myMainAtMeNode = DTSleep_CommonF.PlaceFormAtObjectRef(DTSleep_MainNode, MainActorCloneRef)
					else
						myMainAtMeNode = DTSleep_CommonF.PlaceFormAtObjectRef(DTSleep_MainNode, MainActorRef)
					endIf
					
					if (myMainAtMeNode != None && myMainAtMeNode.Is3DLoaded())
					
						if (useTempBed && SleepBedTempRef == None)
							Form bedForm = SleepBedRef.GetBaseObject() as Form
							SleepBedTempRef = DTSleep_CommonF.PlaceFormAtObjectRef(bedForm, SleepBedRef)
							if (SleepBedTempRef != None)
								
								Point3DOrient pt = DTSleep_CommonF.GetPointBedFootEndToEndForBed(SleepBedRef)
								SleepBedTempRef.SetAngle(0.0, 0.0, pt.Heading)
								SleepBedTempRef.SetPosition(pt.X, pt.Y, pt.Z)
							endIf
						endIf

						; mark second actor original position
						if (SecondActorOriginMarkRef == None)
							SecondActorOriginMarkRef = DTSleep_CommonF.PlaceFormAtObjectRef(DTSleep_MainNode, SecondActorRef)
						endIf
						
						
						xOffset = 0.0
						float head2AngleOffset = 0.0
						
						; Front and Back nodes are 70 units from center
						string facingStr = "Front01"
						if (!mainActorIsMaleRole || id < 100)
							
							facingStr = "Back01"
						endIf
						
						bool placeOnBedSimple = false
						bool markerIsBed = false
						bool bedUseNodeMarker = false
						bool matchRotation = false
						float zOffset = 0.0
						float headingAngle = 0.0
						
						if (id < 100)			
							placeOnBedSimple = true
							
						elseIf (id >= 400 && id < 500)
							placeOnBedSimple = true
							if (id < 490)
								markerIsBed = true
								if (id == 470)
									if (MySleepBedFurnType == FurnTypeIsTablePicnic)
										bedUseNodeMarker = true	; adjust by furniture's orientation
										markerIsBed = false
										if (DTSleep_IntimatePicnicTLongList.HasForm(SleepBedRef.GetBaseObject() as Form))
											yOffset = -89.4			; distance
										else
											yOffset = -58.0
										endIf
										
										zOffset = 0.0
										float actH = MainActorRef.GetAngleZ()				; nearest side
										float tabH = SleepBedRef.GetAngleZ()
										if (actH > tabH && actH <= tabH + 180)
											xOffset = 90.0			; angle
											headingAngle = SleepBedRef.GetAngleZ() + 90.03
										else
											xOffset = -90.0			; angle
											headingAngle = SleepBedRef.GetAngleZ() - 90.03
										endIf
									endIf
								endIf
							endIf
							
						elseIf (id == 181 || id == 681)
							placeOnBedSimple = true
							zOffset = 0.0
							yOffset = 16.0
							revHeading = true
							if (SleepBedTwinRef == None)
								xOffset = -29.0
							endIf
						elseIf (id == 180 || id == 680)
							placeOnBedSimple = true
							zOffset = 0.0
							yOffset = 16.0
							
						elseIf (id == 501 || (id >= 504 && id <= 509) || id == 541)
							placeOnBedSimple = true
							zOffset = PositionMarkerOnBedZAdjustForSceneID(id)
							if (zOffset == 0.0)
								markerIsBed = true
								yOffset = 0.0
							endIf
							
						elseIf (id == 510)
							; spork T-shape will only fit on floor or double-bed
							if (!MainActorPositionByCaller)
								placeOnBedSimple = true
								zOffset = PositionMarkerOnBedZAdjustForSceneID(id)
								if (zOffset == 0.0)
									markerIsBed = true
									yOffset = 0.0
								endIf
							endIf
						elseIf (id >= 535 && id <= 538)
							placeOnBedSimple = true
							markerIsBed = true
						
						elseIf (id == 550)						;v2.87
							if (MainActorPositionByCaller || standOnly || isFloorBed || restrictPlaceOnBed)
								placeOnBedSimple = false
							else
								placeOnBedSimple = true
								; might be placed on table
								zOffset = PositionMarkerOnBedZAdjustForSceneID(id)
							endIf
						elseIf (id == 552)
							zOffset = PositionMarkerOnBedZAdjustForSceneID(id)
							placeOnBedSimple = true
							markerIsBed = false
							matchRotation = true
							;bedUseNodeMarker = true
							yOffset = -32.0
							revHeading = true
						elseIf (id >= 560 && id < 590 && isFloorBed)
							placeOnBedSimple = true
						
						elseIf (id >= 590 && id < 600)
							placeOnBedSimple = true
							
							if (id == 599)
								revHeading = true
							endIf
							yOffset = -24.0
							if (id == 592 && MySleepBedFurnType > 0 && MySleepBedFurnType < 220)
								yOffset = -31.0
							elseIf (id == 590)
								yOffset = 0.0
							endIf
							zOffset = PositionMarkerOnBedZAdjustForSceneID(id)
							
							if (zOffset == 0.0)
								markerIsBed = true
							else
								matchRotation = true
							endIf

						elseIf (id >= 600 && id < 650 && !MainActorPositionByCaller)
							placeOnBedSimple = true
							
							if (id == 610)
								; set revHeading based on player side for Look-View   v2.73
								Point3DOrient ptBed = DTSleep_CommonF.PointOfObject(SleepBedRef)
								Point3DOrient ptActor = DTSleep_CommonF.PointOfObject(MainActorRef)
								Point3DOrient ptSide = DTSleep_CommonF.FindNearestSideOfBedRelativeToBed(ptBed, ptActor)
								if (ptSide.X > 0)
									revHeading = true
								else
									revHeading = false
								endIf
								
								if (mainActorIsMaleRole)
									xOffset = -7.4
								else
									xOffset = 9.2
								endIf
							; -------------                           copied from 100s above -- v2.73
							elseIf (id >= 604 && id <= 609)						
								;cowgirl
								
								; don't need check which actor role for 6  v3.15
								;if (mainActorIsMaleRole)
									if (Utility.RandomInt(0, 1) == 0)
										revHeading = true
										yOffset = 3.5	;v1.65 increased to avoid standing on head/bar
										; 
										if (sleepBedIsDoubleBed)
											yOffset += 1.75
										endIf
									else
										onFloorOK = true
										if (sleepBedIsDoubleBed)
											yOffset = -2.0
										else
											yOffset = -3.0		; v3.15
										endIf
									endIf
								;endIf
								
								
							elseIf (id >= 602 && id < 604)
								
								if (sleepBedIsDoubleBed)
									yOffset = -6.0
								else
									yOffset = 5.0		; move away from foot v3.15
								endIf
								
							elseIf (id >= 600 && id <= 601)
								; move away from bed foot			; v3.15
								yOffset = -7.2	
							endIf
							; --------------------------------
						
							if (!MainActorPositionByCaller)
								zOffset = PositionMarkerOnBedZAdjustForSceneID(id)
							endIf
							
						elseIf (id >= 650 && id < 682 && !restrictPlaceOnBed && !MainActorPositionByCaller && !standOnly) ; v2.73 - changed upper limit (700 to 682) to use newer Leito in AAC
							; stand and creature IDs
							if (MainActorPositionByCaller || standOnly)				; v2.73 make sure
								placeOnBedSimple = false
							else
								placeOnBedSimple = true
								; might be placed on table  v2.73
								zOffset = PositionMarkerOnBedZAdjustForSceneID(id)
							endIf
							
						elseIf (id >= 682 && id < 700 && !MainActorPositionByCaller)
							; new Leito animations on chairs --- v2.73
							placeOnBedSimple = true
							bedUseNodeMarker = true	; adjust by furniture's orientation so xOffset is angle
							markerIsBed = false
							yOffset = 0.0
							xOffset = 0.0			; angle 0 for y-axis movement
							zOffset = 0.0
	
							if (MySleepBedFurnType == FurnTypeIsSeatSofa)
								Form bForm = SleepBedRef.GetBaseObject()
								if (id == 683)						; v3.15 reordered this first and changed offset
									yOffSet = 3.8	
									
								elseIf (DTSleep_IntimateCouchMemList.HasForm(bForm))			; v3.15 
									yOffset = -1.6
									
								elseIf (id == 682 || DTSleep_IntimateCouchLimSpaceList.HasForm(bForm))
									yOffset = 5.0
									;zOffset = 0.0
								else
									yOffset = 1.0			
									;zOffset = 0.0
								endIf
							elseIf (MySleepBedFurnType == FurnTypeIsSeatBench)
								if (id == 682)
									yOffset = -0.2
								else
									yOffset = 4.0
								endIf
							elseIf (MySleepBedFurnType == FurnTypeIsSeatKitchen)
								zOffset = 0.0
								yOffset = 2.3			; default seating position too close to backrest v3.15
								if (id == 683)
									yOffset += 3.0
								endIf
								
								
							elseIf (id == 683)					; v2.90
								; move away from backrest
								
								yOffset = 6.0				; v3.15 
								if (MySleepBedFurnType == FurnTypeIsSeatLowArmRest)
									
									yOffset = 10.0		; a bit more	
								endIf
								xOffset = 0.0
							elseIf (id == 684)				; v2.90
								; move back a bit
								yOffset = 5.2			; was 7.2 v3.15	
								xOffset = 0.0
							elseIf (id == 686)
								; move back a bit
								yOffset = 5.0			; was 6.0 v3.15
								xOffset = 0.0					; so that yOffset distance is closer to chair
							endIf
							
						elseIf (id >= 700 && id < 760)
							placeOnBedSimple = true
							markerIsBed = true
							yOffset = 0.0
							xOffset = 0.0
							zOffset = 0.0
							if (MainActorPositionByCaller)
								placeOnBedSimple = false
								markerIsBed = false
								;zOffset = PositionMarkerOnBedZAdjustForSceneID(id)
							endIf
							
							if (SceneData.SecondMaleRole != None && (id == 713 || id == 714 || id == 705))
								; floor or any bed
								markerIsBed = false
								
								if (MainActorPositionByCaller)
									placeOnBedSimple = false
									
								elseIf (SleepBedIsPillowBed)
									zOffset = -4.0
									yOffset = -8.0
									bedUseNodeMarker = false	; adjust by offset
								else
									yOffset = -10.0
									bedUseNodeMarker = false	; adjust by offset
								endIf
							elseIf (id == 705)
								; single-bed only may be against wall -- rotate to near side
								Point3DOrient ptBed = DTSleep_CommonF.PointOfObject(SleepBedRef)
								Point3DOrient ptActor = DTSleep_CommonF.PointOfObject(MainActorRef)
								Point3DOrient ptSide = DTSleep_CommonF.FindNearestSideOfBedRelativeToBed(ptBed, ptActor)
								if (ptSide.X > 0)
									; rotate to actor side
									markerIsBed = false
									bedUseNodeMarker = false
									revHeading = true
									zOffset = -45.9
									matchRotation = true
									yOffset = -2.0
								endIf
							elseIf (SceneData.SecondMaleRole != None && id == 715)
								; bunk bed may be against wall - turn animation to near side
								Point3DOrient ptBed = DTSleep_CommonF.PointOfObject(SleepBedRef)
								Point3DOrient ptActor = DTSleep_CommonF.PointOfObject(MainActorRef)
								Point3DOrient ptSide = DTSleep_CommonF.FindNearestSideOfBedRelativeToBed(ptBed, ptActor)
								if (ptSide.X > 0)
									; rotate to actor side
									markerIsBed = false
									bedUseNodeMarker = false
									revHeading = true
									zOffset = -45.9
									matchRotation = true
									yOffset = -2.333
								endIf
								
							elseIf (id == 704 && SceneData.SecondMaleRole != None)
								bedUseNodeMarker = true	; adjust by furniture's orientation
								markerIsBed = false
								yOffset = -20.0			; distance
								xOffset = -90.0			; angle when using bedUseNodeMarker (x-axis movement)
								if (isFloorBed)
									zOffset = -37.5
								elseIf (MainActorPositionByCaller)
									zOffset = -40.0
								endIf 
							elseIf (id == 732)
								; ottoman animation faced 90 degrees from normal 
								;  set side facing player and closer to edge due to sat too low
								float actH = MainActorRef.GetAngleZ()
								float tabH = SleepBedRef.GetAngleZ()
								
								if (actH > tabH - 90.0 && actH <= tabH + 90)
									headingAngle = SleepBedRef.GetAngleZ() - 90.03
									xOffset = 90.0
								else
									headingAngle = SleepBedRef.GetAngleZ() + 90.03
									xOffset = -90.0
								endIf
								yOffset = -6.5
								bedUseNodeMarker = true	; adjust by furniture's orientation
								markerIsBed = false

							elseIf (id == 734)
								; federal couch adjustment - keep arms and shoulders from clipping
								yOffset = 3.0
								xOffset = 0.0
								bedUseNodeMarker = true
								markerIsBed = false
								headingAngle = SleepBedRef.GetAngleZ() + 0.03
							elseIf (id == 735 || id == 781)
								; couch adjustment - keep arms and shoulders from clipping
								yOffset = 7.25			; v3.23 +1.0
								xOffset = 0.0
								bedUseNodeMarker = true
								markerIsBed = false
								headingAngle = SleepBedRef.GetAngleZ() + 0.03
								
							elseIf (id >= 743 && id <= 745)
								; support longer dinner table, (v2.35) picnic table and diner booth table
								
								if (MySleepBedFurnType == FurnTypeIsTablePicnic)
									bedUseNodeMarker = true	; adjust by furniture's orientation
									markerIsBed = false
									if (DTSleep_IntimatePicnicTLongList.HasForm(SleepBedRef.GetBaseObject() as Form))
										yOffset = -51.4			; distance
									else
										yOffset = -21.0
									endIf
									if (id >= 744)
										yOffset = 68.0			; opposite angle, so positive
									endIf
									zOffset = PositionMarkerOnBedZAdjustForSceneID(id)
									float actH = MainActorRef.GetAngleZ()				; nearest side
									float tabH = SleepBedRef.GetAngleZ()
									if (actH > tabH && actH <= tabH + 180)
										xOffset = 90.0			; angle
										headingAngle = SleepBedRef.GetAngleZ() + 90.03
									else
										xOffset = -90.0			; angle
										headingAngle = SleepBedRef.GetAngleZ() - 90.03
									endIf
								elseIf (MySleepBedFurnType == FurnTypeIsTableDinerBooth)
									; v2.35 adjusted to handle diner booth table
									Form baseTableForm = SleepBedRef.GetBaseObject() as Form
									int dinerBLen = DTSleep_IntimateDinerBoothTableAllList.GetSize()
									yOffset = -8.0				; normally for dinner table -- set closer
									if (id == 744)				
										yOffset = 26.5			; normally for round table at opposite angle
									elseIf (id == 745)
										yOffset = 24.5			; normally for round table at opposite angle
									endIf
									
									if (dinerBLen > 2 && baseTableForm == DTSleep_IntimateDinerBoothTableAllList.GetAt(2))
										; right-side table
										bedUseNodeMarker = true	; adjust by furniture's orientation
										markerIsBed = false
										xOffset = 90.0
										headingAngle = SleepBedRef.GetAngleZ() - 90.03
									elseIf (dinerBLen > 1 && baseTableForm == DTSleep_IntimateDinerBoothTableAllList.GetAt(1))
										; left-side table
										bedUseNodeMarker = true	; adjust by furniture's orientation
										markerIsBed = false
										xOffset = -90.0
										headingAngle = SleepBedRef.GetAngleZ() + 90.03
									else
										; both sides table - select nearest
										bedUseNodeMarker = true	; adjust by furniture's orientation
										markerIsBed = false
										
										float actH = MainActorRef.GetAngleZ()
										float tabH = SleepBedRef.GetAngleZ()
										
										if (actH > tabH && actH <= tabH + 180)
											xOffset = -90.0
											headingAngle = SleepBedRef.GetAngleZ() + 90.03
										else
											xOffset = 90.0
											headingAngle = SleepBedRef.GetAngleZ() - 90.03
										endIf
										;Debug.Trace(myScriptName + " diner booth left-side; actorZ " + actH + ", tableZ " + tabH)
									endIf
								elseIf (MySleepBedFurnType == FurnTypeIsTableDining)
									; v2.70 --- fix since was included in dining booth section above --- added TypeIsDining section
									Form baseTableForm = SleepBedRef.GetBaseObject() as Form
									int dinnerLen = DTSleep_IntimateDiningTableList.GetSize()
									
									if (dinnerLen > 2 && baseTableForm == DTSleep_IntimateDiningTableList.GetAt(2))
										bedUseNodeMarker = true	; adjust by furniture's orientation
										markerIsBed = false
										yOffset = -50.0			; distance
										xOffset = 0.0			; angle
										if (id >= 744)
											yOffset = 67.0
										endIf
										headingAngle = SleepBedRef.GetAngleZ() + 0.03
										Debug.Trace(myScriptName + " ***** position for dining table at index 2...")
									elseIf (dinnerLen > 1 && baseTableForm == DTSleep_IntimateDiningTableList.GetAt(1))
										bedUseNodeMarker = true	; adjust by furniture's orientation
										markerIsBed = false
										yOffset = -22.5			; distance
										xOffset = 0.0			; angle 
										if (id >= 744)
											yOffset = 39.0
										endIf
										headingAngle = SleepBedRef.GetAngleZ() + 0.03
										Debug.Trace(myScriptName + " ***** position for dining table at index 1...")
									else
										Debug.Trace(myScriptName + " ***** no position adjustmentfor dining table")
									endIf
								endIf
								
							elseIf (id == 748)
								; check pillory   v2.60 fix None check
								if ((DTSConditionals as DTSleep_Conditionals).ZaZPilloryKW != None && SleepBedRef.HasKeyword((DTSConditionals as DTSleep_Conditionals).ZaZPilloryKW))
									bedUseNodeMarker = true
									markerIsBed = false
									yOffset = 13.25
									xOffset = 27.0   ; angle - prevent random
								endIf
								
							elseIf (id == 751)			; stand scene
								markerIsBed = false
								if (MySleepBedFurnType < 200)	; floor bed including coffine
									placeOnBedSimple = true
									bedUseNodeMarker = false
									yOffset = 30.0
								else
									placeOnBedSimple = false
									forceMainActorPosition = true
								endIf
								
							elseIf (id == 752)
								; desk - chair centered gets in way, but move back since close to table
								markerIsBed = false
								bedUseNodeMarker = true
								yOffset = -5.0
								xOffset = 0.0
								Form baseBedForm = SleepBedRef.GetBaseObject()
								if (MySleepBedFurnType == FurnTypeIsTableDesk && DTSleep_IntimateDesk90List.HasForm(baseBedForm))
									xOffset = -90.0				;v2.51
								endIf

								headingAngle = SleepBedRef.GetAngleZ() + xOffset
								
							elseIf (id == 753)
								; stool facing normal sit-direction which bumps head into many counters
								; let's turn at an angle
								markerIsBed = false
								bedUseNodeMarker = true
								Form baseForm = SleepBedRef.GetBaseObject() as Form
								if (DTSleep_IntimateStoolBackList.HasForm(baseForm))
									headingAngle = SleepBedRef.GetAngleZ() + 90.0
									yOffset = 3.0
								elseIf (DTSleep_IntimateStoolNoAngleList.HasForm(baseForm))
									headingAngle = SleepBedRef.GetAngleZ() + 0.1
									yOffset = -6.3
								elseIf (Utility.RandomInt(2,4) > 2)
									headingAngle = SleepBedRef.GetAngleZ() - 42.0
								else
									headingAngle = SleepBedRef.GetAngleZ() + 46.0
								endIf
								
							elseIf (id == 754)
								if (MySleepBedFurnType == FurnTypeIsSeatKitchen)
									zOffset = 0.0
									yOffset = -3.0			; default seating position too close to backrest v3.15
								else 
									; memory lounge, Mama chair -- default too close
									Form chairForm = SleepBedRef.GetBaseObject()
									if (DTSleep_IntimateChairTooCloseList.HasForm(chairForm))
										markerIsBed = false
										bedUseNodeMarker = true
		
										yOffset = 8.46		; 8.67 too far away  -v2.90
										xOffset = -4.0  ; angle offset to shift side-ways
										headingAngle = SleepBedRef.GetAngleZ() + 0.03
									endIf
								endIf
								
							elseIf (id == 756)				; 757 starts at end of pool table
							;	; actual pool table
							;	v2.53 - turn animation to near side
								float actH = MainActorRef.GetAngleZ()
								float tabH = SleepBedRef.GetAngleZ()
								;Debug.Trace("  **** actor angle: " + actH + " ***** table angle: " + tabH)
								if (((actH - tabH) > 0 && (actH - tabH) <= 180) || ((actH - tabH) <= -180 && (actH - tabH) < -360))
									zOffset = -7.00
									markerIsBed = false
									bedUseNodeMarker = false
									matchRotation = true
									revHeading = true
								endIf
								
							elseIf (id == 758 || id == 755)
								yOffset = 5.0				; v2.90 - decrease (closer to front of chair)
								xOffset = 0.0
								markerIsBed = false
								
								if (SceneData.SecondMaleRole != None)
									; a standing scene - not a chair
									
									if (!MainActorPositionByCaller && MySleepBedFurnType == FurnTypeIsCoffin)
										zOffset = 2.0
										xOffset = 0.1
										bedUseNodeMarker = true
									else
										forceMainActorPosition = true
										placeOnBedSimple = false
									endIf
								else
									bedUseNodeMarker = true
								endIf
								
							elseIf (id == 759)				; bench
								markerIsBed = false
								bedUseNodeMarker = true
								yOffset = 3.0		; distance
								xOffset = 0.0		; on heading
								if (MySleepBedFurnType == FurnTypeIsSMBed)
									;yOffset = -46.0	; normal distance straight out - halfway between tires
									yOffset = -55.8		; distance at angle
									xOffset = 32.0		; angle over to get on tire
									zOffset = 4.25
									headingAngle = SleepBedRef.GetAngleZ() + 180.0
								endIf
								;if (DTSleep_IntimateBenchAdjList.HasForm(SleepBedRef.GetBaseObject() as Form))
								;	yOffset = 6.0
								;endIf
								
							elseIf (SleepBedRef.HasKeyword(AnimFurnFloorBedAnimKY))
								; nearly all SavageCabbage on regular beds
								zOffset = PositionMarkerOnBedZAdjustForSceneID(id)
								if (zOffset != 0.0)
									bedUseNodeMarker = true
									markerIsBed = false
								endIf
							endIf
						elseIf (id >= 760 && id <= 773)
							; Strong, Codsworth
							if (sleepBedIsDoubleBed)
								placeOnBedSimple = true
								markerIsBed = true
							elseIf (id >= 767 && id <= 768)
								placeOnBedSimple = true
								markerIsBed = true
							elseIf (id == 773)
								; strong on couch
								placeOnBedSimple = true
								markerIsBed = true
							elseIf (!restrictPlaceOnBed)
								
								if (MySleepBedFurnType == FurnTypeIsSleepingBag) ; isFloorBed)
									;zOffset = 6.0						; causes shake in orbit-view  v2.73
									placeOnBedSimple = true
								;else
								;	forceMainActorPosition = true ; force spot
								endIf
							endIf
						elseIf (id >= 774 && id < 777)
							; SM Behemoth
							if (MainActorCloneRef != None)
								placeOnBedSimple = true
								if (MainActorPositionByCaller == false)
									markerIsBed = false
									zOffset = 6.0
								endIf
							else
								forceMainActorPosition = true ; force spot
							endIf
							
						elseIf (id >= 777 && id < 800)
							placeOnBedSimple = true
							markerIsBed = true
							
							if (id == 778)
								; couch adjustment 
								yOffset = -9.2
								xOffset = 0.0
								bedUseNodeMarker = true
								markerIsBed = false
								
							elseIf (id == 788)					; locker  - v2.77
								; for Vault lockers, nudge out to avoid clipping locker door
								if (DTSleep_IntimateLockerAdjList.HasForm(SleepBedRef.GetBaseObject() as Form))
									zOffset = 0.0			
									yOffset = -8.5			; distance
									xOffset = 0.0			; angle when using bedUseNodeMarker (x-axis movement)
									bedUseNodeMarker = true
									markerIsBed = false
								endIf
								
							elseIf (id < 791)
								zOffset = PositionMarkerOnBedZAdjustForSceneID(id)
								if (zOffset == 0.0)
									markerIsBed = true
								else
									; sleepbag or other furniture
									markerIsBed = false
								endIf
							
							elseIf (id >= 791 && id <= 792)
								zOffset = -11.5		; intended for pre-war sedan
								yOffset = -1.33			; distance
								xOffset = -90.0			; angle when using bedUseNodeMarker (x-axis movement)
								bedUseNodeMarker = true
								markerIsBed = false
								
							elseIf (id == 797)							
								; railing - check if backwards			v2.70
								bool isBackwardRail = false
								if ((DTSConditionals as DTSleep_Conditionals).DLCCoastDaltonRailingBackward01 != None)
					
									if (SleepBedRef == (DTSConditionals as DTSleep_Conditionals).DLCCoastDaltonRailingBackward01)
										isBackwardRail = true
									elseIf (SleepBedRef == (DTSConditionals as DTSleep_Conditionals).DLCCoastDaltonRailingBackward02)
										isBackwardRail = true
									elseIf (SleepBedRef == (DTSConditionals as DTSleep_Conditionals).DLCCoastDaltonRailingBackward03)
										isBackwardRail = true
									elseIf (SleepBedRef == (DTSConditionals as DTSleep_Conditionals).DLCCoastDaltonRailingBackward04)
										isBackwardRail = true
									elseIf (SleepBedRef == (DTSConditionals as DTSleep_Conditionals).DLCCoastDaltonRailingBackward05)
										isBackwardRail = true
									endIf
								endIf
								if (isBackwardRail)
									Debug.Trace(myScriptName + " backward railing ..... reversing the marker...")
									bedUseNodeMarker = true			; adjust by furniture orientation
									markerIsBed = false
									headingAngle = SleepBedRef.GetAngleZ() + 180.0
								endIf
								
							elseIf (id == 795)									
								headingAngle = SleepBedRef.GetAngleZ() + 0.001
								bedUseNodeMarker = true
								markerIsBed = false
								bool jailFound = false
								
								; need to review:
								; NatickBanks (crooked), Goodneighbor Statehouse
								
								; v2.42 updated SavageCabbage 1.21 centers on door instead of jail
								ObjectReference jailRef = None
								if ((DTSConditionals as DTSleep_Conditionals).SavageCabbageVers < 1.21)
									jailRef = DTSleep_CommonF.FindNearestObjectInListFromObjRef(DTSleep_JailAllList, SleepBedRef, 200.0)
								endIf
								
								if (jailRef != None)
									
									Form jailForm = None
									if (jailRef != None)
										jailForm = jailRef.GetBaseObject() as Form
									endIf
									if (jailForm != None && DTSleep_JailTinyList.HasForm(jailForm))
										jailFound = true
										SleepBedAltRef = jailRef		; switch for old version
										bedUseNodeMarker = false
										markerIsBed = true
									elseIf (jailForm != None && DTSleep_JailSmallList.HasForm(jailForm))
										jailFound = true
										SleepBedAltRef = jailRef		; switch for old version
										head2AngleOffset = 0.01
										xOffset = 62.0			; 64 was just too far out
										yOffset = -30.0			; -32 was slightly too close to handle --move negative moves left
									endIf
								endIf
								
								if (!jailFound)
									head2AngleOffset = 0.001
									if ((DTSConditionals as DTSleep_Conditionals).SavageCabbageVers < 1.21)
										xOffset = -65.0		; negative moves inside jail
									endIf
									float jailAngle = SleepBedRef.GetAngleZ()
									
									if (SleepBedLocation != None && DTSleep_JailDoor2AltLoclList.HasForm(SleepBedLocation) && jailAngle > 325.0 && jailAngle < 375.0)
										if (DTSleep_SettingTestMode.GetValue() >= 1.0 && DTSleep_DebugMode.GetValue() >= 2.0)
											Debug.Trace(myScriptName + "---------------------- 795 jail location (" + SleepBedLocation + ") AltCell other heading: " + jailAngle)
										endIf
										; shifted half-bar-width away from handle, so move towards handle (Fens PD side with 2 cells)
										if ((DTSConditionals as DTSleep_Conditionals).SavageCabbageVers < 1.21)
											yOffset = -23.0		; negative moves towards handle
										endIf
									else
										if (DTSleep_SettingTestMode.GetValue() >= 1.0 && DTSleep_DebugMode.GetValue() >= 2.0)
											Debug.Trace(myScriptName + "---------------------- 795 jail location (" + SleepBedLocation + ") other  heading: " + jailAngle)
										endIf
										yOffset = -15.0		; negative moves towards handle
									endIf
								endIf
								
							elseIf (id == 796)
								; door, but need to center on jail
								bedUseNodeMarker = true
								markerIsBed = false
								bool jailFound = false
								ObjectReference jailRef = DTSleep_CommonF.FindNearestObjectInListFromObjRef(DTSleep_JailAllList, SleepBedRef, 200.0)
								bool isTinyJailDoor = false
								if (SleepBedLocation != None && DTSleep_JailDoorTinyLocList.HasForm(SleepBedLocation))
									if (SleepBedRef == JailDoor1Quincy1Ref || SleepBedRef == JailDoor1Quincy2Ref || SleepBedRef == JailDoor1Quincy3Ref)
										Debug.Trace(myScriptName + " ----*---*--- Jail Door is Tiny Quincy ---------Ref: " + SleepBedRef)
										isTinyJailDoor = true
									endIf
								endIf
								
								if (jailRef != None || isTinyJailDoor)
									;DEbug.Trace(myScriptName + " found a JailRef " + jailRef + " ... isTinyJailDoor ? " + isTinyJailDoor)
									Form jailForm = None
									if (jailRef != None)
										jailForm = jailRef.GetBaseObject() as Form
									endIf
									
									if (isTinyJailDoor)
										jailFound = true
										SleepBedAltRef = jailRef		; switch
										;yOffset = 53.0  	; positive moves away from front
										;xOffset = 32.0		; distance to side of jail-Tiny - negative moves outward
										yOffset = -11.5  ;-14.0			; -15.5 had nuckle against bar positive moves away from front
										xOffset = 48.0		; distance to side of jail-Tiny - negative moves outward				
										headingAngle = SleepBedRef.GetAngleZ() + 180.001		; spin around against side where door opens
										head2AngleOffset = -90.0			; angle when using bedUseNodeMarker
										
									elseIf (jailForm != None && DTSleep_JailTinyList.HasForm(jailForm))
										;DEbug.Trace(myScriptName + " found tiny JailRef " + jailRef)
										jailFound = true
										SleepBedAltRef = jailRef		; switch
										yOffset = -11.5  ;-14.0			; -15.5 had nuckle against bar positive moves away from front
										xOffset = 48.0		; distance to side of jail-Tiny - negative moves outward				
										headingAngle = SleepBedRef.GetAngleZ() + 180.001		; spin around against side where door opens
										head2AngleOffset = -90.0			; angle when using bedUseNodeMarker
										
									elseIf (jailForm != None && DTSleep_JailSmallList.HasForm(jailForm))
										;DEbug.Trace(myScriptName + " found small JailRef " + jailRef)
										jailFound = true
										SleepBedAltRef = jailRef		; switch
										bedUseNodeMarker = false
										markerIsBed = true
										headingAngle = SleepBedRef.GetAngleZ() + 0.001
									endIf
								endIf
								
								if (!jailFound)
									;
									float jailAngle = SleepBedRef.GetAngleZ()
									
									if (SleepBedLocation != None && DTSleep_JailReversedLocList.HasForm(SleepBedLocation) && SleepBedRef != DN130_CambridgePDJailDoor03)
										if (DTSleep_SettingTestMode.GetValue() >= 1.0 && DTSleep_DebugMode.GetValue() >= 2.0)
											Debug.Trace(myScriptName + "---------------------- 796 jail location (" + SleepBedLocation + ") REVERSED jail other  heading: " + jailAngle)
										endIf
										yOffset = 90.6 		
										xOffset = -128.2	
										head2AngleOffset = 180.00
										headingAngle = SleepBedRef.GetAngleZ() - 90.001
									
									else
										head2AngleOffset = 0.001
										headingAngle = SleepBedRef.GetAngleZ() + 90.001
										if (SleepBedRef.GetBaseObject() == DTSleep_IntimateDoorJailList.GetAt(0))			; swing door
											
											if (SleepBedRef == DN130_CambridgePDJailDoor03)
												if (DTSleep_SettingTestMode.GetValue() >= 1.0 && DTSleep_DebugMode.GetValue() >= 2.0)
													Debug.Trace(myScriptName + "---------------------- 796 jail location (" + SleepBedLocation + ") swing-door CambPDJDoor03 ")
												endIf
												yOffset = 60.5
												xOffset = -129.5	;-65.0 - 64.0
											;elseIf (SleepBedLocation != None && DTSleep_JailDoorwayAltLocList.HasForm(SleepBedLocation))
												
												
											elseIf (SleepBedLocation != None && DTSleep_JailDoor2AltLoclList.HasForm(SleepBedLocation))
												if (jailAngle > 165.0 && jailAngle < 180.0)
													if (DTSleep_SettingTestMode.GetValue() >= 1.0 && DTSleep_DebugMode.GetValue() >= 2.0)
														Debug.Trace(myScriptName + "---------------------- 796 jail location (" + SleepBedLocation + ") swing-door-Door2Alt other  heading: " + jailAngle)
													endIf
													yOffset = 60.6		; FensPD angle single opposite other two
													xOffset = -129.75	;-65.0 - 64.0
												else
													; shifted ~10 towards handle, move away
													if (DTSleep_SettingTestMode.GetValue() >= 1.0 && DTSleep_DebugMode.GetValue() >= 2.0)
														Debug.Trace(myScriptName + "---------------------- 796 jail location (" + SleepBedLocation + ") swing-door-AltCell other  heading: " + jailAngle)
													endIf
													yOffset = 49.5 		; (FensPD-355-angle two side-by-side)....
													xOffset = -133.0	; negative moves inside
												endIf
											else
												if (DTSleep_SettingTestMode.GetValue() >= 1.0 && DTSleep_DebugMode.GetValue() >= 2.0)
													Debug.Trace(myScriptName + "---------------------- 796 jail location (" + SleepBedLocation + ") swing-door other  heading: " + jailAngle)
												endIf
												yOffset = 60.6		; -16.0 + 76.6 (East Boston PD in water--325 angle, LIbertaliaNorth, BADTFL)
												xOffset = -129.25	;-65.0 - 64.0
											endIf
											
										; slide door
										elseIf (SleepBedLocation != None && DTSleep_JailDoor2AltLoclList.HasForm(SleepBedLocation))
											if (DTSleep_SettingTestMode.GetValue() >= 1.0 && DTSleep_DebugMode.GetValue() >= 2.0)
												Debug.Trace(myScriptName + "---------------------- 796 jail location (" + SleepBedLocation + ") slide-door Door2Alt  heading: " + jailAngle)
											endIf
											yOffset = 49.5 		; Fens
											xOffset = -133.0	; negative moves inside
										else
											if (DTSleep_SettingTestMode.GetValue() >= 1.0 && DTSleep_DebugMode.GetValue() >= 2.0)
												Debug.Trace(myScriptName + "---------------------- 796 jail location (" + SleepBedLocation + ") slide-door other  heading: " + jailAngle)
											endIf
											yOffset = 60.5 		; negative moves towards handle --normal?  BADTFL (180 angle)
											xOffset = -128.5	; negative moves inside jail
										endIf
									endIf
								endIf
							endIf
						
						elseIf (id >= 800 && id < 900)
							placeOnBedSimple = true
							markerIsBed = true
							yOffset = 0.0
							xOffset = 0.0
							zOffset = 0.0
							; check pillory   v2.60 fix None check
							if ((DTSConditionals as DTSleep_Conditionals).DLC05PilloryKY != None && SleepBedRef.HasKeyword((DTSConditionals as DTSleep_Conditionals).DLC05PilloryKY))
								bedUseNodeMarker = true
								markerIsBed = false
								yOffset = -12.25
								xOffset = 1.0		; angle prevent random
							endIf
							
						elseIf (id >= 900 && id < 1200)					; v2.90 adjust limit for future
							; TODO: BP70 position
							if (standOnly && onFloorOK)					; v3.15
								placeOnBedSimple = false
							else
								placeOnBedSimple = true
								matchRotation = true
								zOffset = PositionMarkerOnBedZAdjustForSceneID(id)
							
								yOffset = -16.0
							
								if (id == 903)
									yOffset = -56.0
								endIf
								
								if (MySleepBedFurnType == FurnTypeIsSeatKitchen && id == 1137)
									zOffset = 0.0
									yOffset = -2.5			; default seating position too close to backrest v3.15
									
								elseIf (id == 1116)
									yOffset = 3.0		; v3.16
									
								elseIf (id == 1010)
									; rotate 90 degrees to fit on bed
									bedUseNodeMarker = true
									markerIsBed = false
									headingAngle = SleepBedRef.GetAngleZ() + 89.0   ; turn node on bed
									head2AngleOffset = 2.0							; 
									xOffset = -34.0					
									yOffset = -15.0
									
								elseIf (id == 1008)
									yOffset = 4.0
									
								elseIf (id == 1006)
									yOffset = -18.0
								elseIf (id == 1002)
									yOffset = -15.0		; was -20  v3.16
									
								elseIf (id == 1020)
									yOffset = -19.0

								elseIf (id == 1070)
									; move farther out from locker Door
									yOffset = -9.6
									
								elseIf (id >= 1039 && id < 1042 && id != 1040)
									; these are rotated backside of sofa
									bedUseNodeMarker = true
									markerIsBed = false
									headingAngle = SleepBedRef.GetAngleZ() + 180.001
									head2AngleOffset = -90.0			; angle when using bedUseNodeMarker
									
								elseIf (id == 1047 || id == 1049)
									; rotate 180 degrees 
									; set revHeading based on player side for Look-View   v2.73
									Point3DOrient ptBed = DTSleep_CommonF.PointOfObject(SleepBedRef)
									Point3DOrient ptActor = DTSleep_CommonF.PointOfObject(MainActorRef)
									Point3DOrient ptSide = DTSleep_CommonF.FindNearestSideOfBedRelativeToBed(ptBed, ptActor)
									if (ptSide.X > 0)
										revHeading = false
									else
										revHeading = true
									endIf
									bedUseNodeMarker = false
									markerIsBed = false
									
												
								elseIf (id == 1101)						; v3.15
									; move to center of bed
									yOffset = 30.0	
								elseIf (id == 1106)
									yOffset = 4.0
								elseIf (id == 1149)
									; move towards center of bed
									yOffset = -20.0
								elseIf (id == 1130)
									; move away from back
									yOffset = 4.0						; TODO: check 
									bedUseNodeMarker = true
									markerIsBed = false
								elseIf (id == 1132)						; v3.15		
									; sofa--rotate and z+
									zOffset = 5.0
									;xOffset = -4.0
									bedUseNodeMarker = true
									markerIsBed = false
									headingAngle = SleepBedRef.GetAngleZ() + 180.001
									head2AngleOffset = -90.0			; angle when using bedUseNodeMarker
								elseIf (id == 1134)
									; higher
									zOffset = 6.0
									yOffset = 6.0
									bedUseNodeMarker = true
									markerIsBed = false
								elseIf (id == 1135)	
									zOffset = 11.0
									yOffset = 2.0
									bedUseNodeMarker = true
									markerIsBed = false
								elseIf (id == 1136)
									; need to rotate 180 and move away --- ;TODO check this
									yOffset = 7.2
									if (MySleepBedFurnType == FurnTypeIsSeatLowArmRest)
										yOffset = 9.4
									endIf
									bedUseNodeMarker = true
									markerIsBed = false
									headingAngle = SleepBedRef.GetAngleZ() + 180.001
									;head2AngleOffset = -90.0			; angle when using bedUseNodeMarker -- also shifts left
								elseIf (id == 1137)
									yOffset = 1.5	; due to legs clip v3.15
									
								elseIf (id == 1138)
									; PA Repair  oral hanging 			v3.20
									yOffset = -57.0
									zOffset = 3.0
									bedUseNodeMarker = true
									markerIsBed = false
									headingAngle = SleepBedRef.GetAngleZ()
									
								elseIf (id == 1139)
									; PA Repair doggy on floor   			v3.20
									yOffset = -58.0
									bedUseNodeMarker = true
									markerIsBed = false
									headingAngle = SleepBedRef.GetAngleZ() + 180.001
								elseIf (id == 1141)							;v3.21
									yOffset = 2.0
									bedUseNodeMarker = true
									markerIsBed = false
									headingAngle = SleepBedRef.GetAngleZ()
									
								elseIf (id == 1162)
									; rotate to front of desk  v3.15
									bedUseNodeMarker = true
									markerIsBed = false
									headingAngle = SleepBedRef.GetAngleZ() + 180.001
									head2AngleOffset = -90.0			; angle when using bedUseNodeMarker
									
								elseIf (id == 1193)
									; workbench move closer, also may be off center
									yOffset = 33.4	
									zOffset = -5.2		
									xOffset = 16.2	; turns	
									
								elseIf (id == 963)
									bedUseNodeMarker = true
									markerIsBed = false
									matchRotation = false
									yOffset = -36.0
								elseIf (zOffset == 0.0)
									markerIsBed = true
									yOffset = -8.0
								endIf
							endIf
						endIf
						
						if (placeOnBedSimple)
							; dancing, solo, AAF, AAC
							
							if (id < 100 || id == 181 || id == 180 || (id >= 490 && id < 500))
								
								if (id < 100 && mainNodeOnBed && MainActorOriginMarkRef != None)
									SecondActorRef.MoveTo(MainActorOriginMarkRef, 0.0, -5.0, 0.0, true)
								elseIf (id >= 490 && id < 500 && mainNodeOnBed && MainActorOriginMarkRef != None)
									SecondActorRef.MoveTo(MainActorOriginMarkRef, 0.0, -5.0, 0.0, true)
								else
									ObjectReference bedRef = SleepBedRef
									if (SleepBedTwinRef != None)
										bedRef = SleepBedTwinRef
									elseIf (SleepBedAltRef != None)
										bedRef = SleepBedAltRef
									endIf
									ObjectReference dummyNode = DTSleep_CommonF.PlaceFormAtNodeRefForNodeForm(myMainAtMeNode, facingStr, DTSleep_DummyNode, false)
									PositionMarkerOnBed(dummyNode, bedRef, xOffset, yOffset, 0.0, true, false, revHeading)
									SecondActorRef.MoveTo(dummyNode, 0.0, 0.0, 0.0, true)
									
								endIf
									
							elseIf (id >= 600 && id < 682)     ; v2.73 changed upper bound to limit to bed/floor animations, not new chairs
								
								mainNodeOnBed = true
								; set male-lead / mainActorMale to false so will place centered on bed
								if (SleepBedAltRef != None)
									PositionMarkerOnBed(mainNode, SleepBedAltRef, 0.0, yOffset, zOffset - 0.5, true, false, revHeading, useAlternateBedAngle)
								else
									PositionMarkerOnBed(mainNode, SleepBedRef, 0.0, yOffset, zOffset, true, false, revHeading, useAlternateBedAngle)
								endIf
								SceneData.MaleMarker = DTSleep_CommonF.PlaceFormAtObjectRef(DTSleep_MainNode, mainNode, false, true, true)

							elseIf ((id >= 1100 && id < 1130) || (id >= 1148 && id < 1150))     ; v3.15 
								
								mainNodeOnBed = true
								; set male-lead / mainActorMale to false so will place centered on bed
								if (SleepBedAltRef != None)
									PositionMarkerOnBed(mainNode, SleepBedAltRef, 0.0, yOffset, zOffset - 0.5, true, false, revHeading, useAlternateBedAngle)
								else
									PositionMarkerOnBed(mainNode, SleepBedRef, 0.0, yOffset, zOffset, true, false, revHeading, useAlternateBedAngle)
								endIf
								SceneData.MaleMarker = DTSleep_CommonF.PlaceFormAtObjectRef(DTSleep_MainNode, mainNode, false, true, true)
							else
								
								if (DTSleep_SettingTestMode.GetValue() > 0.0 && DTSleep_DebugMode.GetValue() >= 2.0)
									Debug.Trace(myScriptName + " mark bed simple markerisBed? " + markerIsBed + ", or bedUseNodeMarker? " + bedUseNodeMarker + " xOffset=" + xOffset + " yOffset=" + yOffset + ", zOffset=" + zOffset + ", heading " + headingAngle)
								endIf
								
								if (markerIsBed && !SleepBedIsPillowBed)
									if (SleepBedAltRef != None)
										SceneData.MaleMarker = DTSleep_CommonF.PlaceFormAtObjectRef(DTSleep_MainNode, SleepBedAltRef, false, true, true)
									else
										SceneData.MaleMarker = DTSleep_CommonF.PlaceFormAtObjectRef(DTSleep_MainNode, SleepBedRef, false, true, true)
									endIf
									
								else
									; mark node
										
									if (bedUseNodeMarker)
										ObjectReference bedMarkRef = SleepBedRef
										if (SleepBedAltRef != None)
											bedMarkRef = SleepBedAltRef
										endIf
										; v2.10 - fix offsets for orientation 
										if (SleepBedIsPillowBed && id != 704)
											yOffset -= 69.0
										endIf
										Point3DOrient ptOrig = DTSleep_CommonF.PointOfObject(bedMarkRef)
										Point3DOrient ptTargetNode = new Point3DOrient
										
										if (head2AngleOffset != 0.0)
											ptTargetNode = DTSleep_CommonF.GetPointXYDistOnHeading(ptOrig, xOffset, yOffset, head2AngleOffset)
										else
											; xOffset here is heading angle and yOffset is distance
											ptTargetNode = DTSleep_CommonF.GetPointDistOnHeading(ptOrig, yOffset, xOffset)
										endIf
										
										mainNode.MoveTo(bedMarkRef, ptTargetNode.X, ptTargetNode.Y, zOffset, true)
										
										if (headingAngle == 0.0)
											headingAngle = mainNode.GetAngleZ()
											if (SleepBedAltRef == None && IsObjBed(SleepBedRef))
												headingAngle += Utility.RandomFloat(-6.0, 6.0)
											endIf
										endIf
										;Debug.Trace(myScriptName + " ...**.. mainNode point: " + DTSleep_CommonF.Point3DOrientToString(DTSleep_CommonF.PointOfObject(mainNode)))
										
										mainNode.SetAngle(0, 0, headingAngle)
										
									else
										if (SleepBedAltRef != None)
											PositionMarkerOnBed(mainNode, SleepBedAltRef, xOffset, yOffset, zOffset, matchRotation, false, revHeading, useAlternateBedAngle)
										else
											PositionMarkerOnBed(mainNode, SleepBedRef, xOffset, yOffset, zOffset, matchRotation, false, revHeading, useAlternateBedAngle)
											
										endIf
									endIf
									
									SceneData.MaleMarker = DTSleep_CommonF.PlaceFormAtObjectRef(DTSleep_MainNode, mainNode, false, true, true)
								endIf
								
							endIf
							
							; v2.70 --- check if orbit-view
							;
							if (DTSleep_SettingAACV.GetValueInt() <= 1 && !MainActorPositionByCaller)
								if (!IsAAFEnabled() || !IsSceneAAFSafe(id, false))								; added aaf-safe check v2.73
									if (MainActorCloneRef == None)
										; no clone, must be orbit
										if (MainActorOriginMarkRef == None)
								
											; before moving mark main actor original position to place actor back later
											MainActorOriginMarkRef = DTSleep_CommonF.PlaceFormAtObjectRef(DTSleep_MainNode, MainActorRef)
										endIf
								
										if (DTSleep_DebugMode.GetValue() >= 1)
											Debug.Trace(myScriptName + " position player-actor for orbit positioning with turn at " + SceneData.MaleMarker + "...")
										endIf
										if (TurnActorToObjHeading(MainActorRef, SceneData.MaleMarker))
											MainActorMovedCount += 1
										endIf
										DTSleep_CommonF.MoveActorToObject(MainActorRef, SceneData.MaleMarker)
										Utility.Wait(0.2)
									endIf
								endIf
							endIf
							; -------------------
							
							;if (id > 800)
							;	SceneData.MaleMarker.SetAngle(SceneData.MaleMarker.GetAngleX(), SceneData.MaleMarker.GetAngleY(), SceneData.MaleMarker.GetAngleZ() + 180.0)
							;	;Point3DOrient ptMarker = DTSleep_CommonF.PointOfObject(SceneData.MaleMarker)
							;	;Point3DOrient ptOffset = DTSleep_CommonF.GetPointDistOnHeading(ptMarker, 50.0)
							;	;SceneData.MaleMarker.SetPosition(ptMarker.X + ptOffset.X, ptMarker.Y + ptOffset.Y, ptMarker.Z)
								
							;endIf
							
							
							seqGoodToGo = true
							attemptCount = 0
							
						elseIf ((MainActorPositionByCaller || forceMainActorPosition || standOnly) && id > 400)				; v2.73 added standOnly
						
							SceneData.MaleMarker = DTSleep_CommonF.PlaceFormAtObjectRef(DTSleep_MainNode, mainNode, false, true, true)
							seqGoodToGo = true
							attemptCount = 0
							float yPos = 40.0
							if (forceMainActorPosition)
								yPos = -40.0
							endIf
							
							if (SceneData.MaleMarker != None)
							
								if (MainActorCloneRef != None)
									SceneData.MaleMarker.MoveTo(MainActorRef, 0.0, yPos, 0.0, true)
									SceneData.MaleMarker.SetAngle(0.0, 0.0, MainActorRef.GetAngleZ() + 33.0)
									
								elseIf (SceneData.SecondMaleRole != None || SceneData.SecondFemaleRole != None)
									; v2.77  - fix for player-character getting pushed by multiple actors
									SceneData.MaleMarker.MoveTo(MainActorRef, 0.0, 0.05, 0.0, true)
									DTSleep_CommonF.MoveActorToObject(MainActorRef, SceneData.MaleMarker)
								endIf
							endIf
							
							
						else
							; sex positions -
							
							Point3DOrient ptMainNode = DTSleep_CommonF.PointOfObject(mainNode)
							Point3DOrient ptDummyNode = new Point3DOrient
							Point3DOrient ptMainActor = new Point3DOrient
							if (MainActorCloneRef != None)
								ptMainActor = DTSleep_CommonF.PointOfObject(MainActorCloneRef)
							else
								ptMainActor = DTSleep_CommonF.PointOfObject(MainActorRef)
							endIf
							if (!MainActorPositionByCaller)
								zOffset = PositionMarkerOnBedZAdjustForSceneID(id)
							endIf
						
							
							ObjectReference dummyNode = None
							if (id >= 504)
								; TODO: not needed and wrong???
								; main node should be on bed or at player character
								if (DTSleep_SettingTestMode.GetValue() > 0.0 && DTSleep_DebugMode.GetValue() >= 2.0)
									Debug.Trace(myScriptName + " set dummyNode at mainNode for AnimSet 5+")
								endIf
								dummyNode = DTSleep_CommonF.PlaceFormAtNodeRefForNodeForm(mainNode, facingStr, DTSleep_DummyNode, false)
								ptDummyNode = DTSleep_CommonF.PointOfObject(dummyNode)
								
							elseIf (id < 400)
								dummyNode = DTSleep_CommonF.PlaceFormAtNodeRefForNodeForm(myMainAtMeNode, facingStr, DTSleep_DummyNode, false)
								ptDummyNode = DTSleep_CommonF.PointOfObject(dummyNode)
								
							elseIf (MainActorCloneRef != None)
	
								ptDummyNode = DTSleep_CommonF.PointOfObject(MainActorCloneRef)
							else
								; may update if offset distance not 0
								ptDummyNode = DTSleep_CommonF.PointOfObject(MainActorRef)
							endIf
							
							
							float htDiff = ptMainActor.Z - ptDummyNode.Z
							
							bool badDummyNode = false
							if (dummyNode == None)
								badDummyNode = true
							elseIf (id < 400)
								if (htDiff > 15.0 || htDiff < -15.0)
									badDummyNode = true
								endIf
							endIf
							
							
							if (!playerPositioned && id < 400)
								if (dummyNode == None)
									dummyNode = DTSleep_CommonF.PlaceFormAtNodeRefForNodeForm(myMainAtMeNode, facingStr, DTSleep_DummyNode, false)
								endIf
								
								if (SleepBedAltRef != None)
									PositionMarkerOnBed(dummyNode, SleepBedAltRef, 0.0, yOffset, zOffset)
								else
									PositionMarkerOnBed(dummyNode, SleepBedRef, 0.0, yOffset, zOffset)
								endIf
								Utility.Wait(0.1)
							endIf
									
							if (badDummyNode || dummyNode == None)
								float saDist = 0.0 - offsetForActors
								if (saDist != 0.0 && mainActorIsMaleRole)
									saDist = offsetForActors
								endIf
								
								Point3DOrient saPt = DTSleep_CommonF.GetPointDistOnHeading(ptMainActor, saDist)
								
								if (MainActorCloneRef != None)
									SecondActorRef.MoveTo(MainActorCloneRef, saPt.X, saPt.Y, 0.0, true)
									
								else
									SecondActorRef.MoveTo(MainActorRef, saPt.X, saPt.Y, 0.0, true)
								endIf
								
								ptDummyNode = DTSleep_CommonF.PointOfObject(SecondActorRef)
								
							else
								SecondActorRef.MoveTo(dummyNode, 0.0, 0.0, 0.0, true)
								
								;SceneData.MaleMarker = DTSleep_CommonF.PlaceFormAtObjectRef(DTSleep_MainNode, dummyNode, false, true, true)

							endIf
							SecondActorRef.SetRestrained()   ; re-restrain
							Utility.Wait(0.1)
							
							if (id < 100 && !MainActorIsReverseHeading)  ; should not happen
								if (MainActorCloneRef != None)
									TurnActorAtAngle(MainActorCloneRef, -174.0)
								else
									TurnActorAtAngle(MainActorRef, -174.0)
								endIf
								MainActorIsReverseHeading = true
							endIf
							
							if (id >= 400 && mainNodeOnBed)
								
								; AAF and AAC moves so precision not necessary
								seqGoodToGo = true
								attemptCount = 0
							else
							
								Point3DOrient ptSecActor = DTSleep_CommonF.PointOfObject(SecondActorRef)
								float secActNodeDistance = DTSleep_CommonF.DistanceBetweenPoints(ptSecActor, ptDummyNode, false)
								float actorDistance = DTSleep_CommonF.DistanceBetweenPoints(ptSecActor, ptMainActor, true)
								
								if (DTSleep_SettingTestMode.GetValue() > 0.0 && DTSleep_DebugMode.GetValue() >= 3.0)
									Debug.Trace(myScriptName + " -------------------------------------------------- ")
									Debug.Trace(myScriptName + " Test-Mode output - may disable in Settings ")
									Debug.Trace(myScriptName + "    actor position log for id: " + id)
									Debug.Trace(myScriptName + " ------------------------------------------- ")
									Debug.Trace(myScriptName + " onBed     ? " + mainNodeOnBed)
									Debug.Trace(myScriptName + " mainIsMale? " + mainActorIsMaleRole)
									Debug.Trace(myScriptName + " revHeading? " + MainActorIsReverseHeading)
									Debug.Trace(myScriptName + " facing    : " + facingStr)
									Debug.Trace(myScriptName + "   bed pos : " + DTSleep_CommonF.Point3DOrientToString(DTSleep_CommonF.PointOfObject(SleepBedRef)))
									Debug.Trace(MyScriptName + " mainNode  : " + DTSleep_CommonF.Point3DOrientToString(ptMainNode))
									Debug.Trace(MyScriptName + " dummyNode  : " + DTSleep_CommonF.Point3DOrientToString(ptDummyNode))
									Debug.Trace(MyScriptName + " player    : " + DTSleep_CommonF.Point3DOrientToString(ptMainActor))
									Debug.Trace(MyScriptName + " companion : " + DTSleep_CommonF.Point3DOrientToString(ptSecActor))
									Debug.Trace(MyScriptName + " comp-node distance " + secActNodeDistance)
									Debug.Trace(MyScriptName + " actors    distance " + actorDistance)
									Debug.Trace(MyScriptName + " actors height diff " + (ptMainActor.Z - ptSecActor.Z))
									Debug.Trace(myScriptName + " -------------------------------------------------- ")
								endIf
								
								; keep adjusting placement until correct distance
								int count = 2
								
								if (Math.Abs(ptMainActor.Z - ptSecActor.Z) > 1.5)
									
									SecondActorRef.TranslateTo(ptSecActor.X + 0.01, ptSecActor.Y + 0.01, ptMainActor.Z, 0.0, 0.0, ptMainActor.Heading + 0.1, 400.0, 0.00000001)
									Utility.Wait(0.5)
								endIf
								
								while (count > 0 && !IsActorsWithinDistLimit(actorDistance, ptMainActor.Z, ptSecActor.Z, mainNodeOnBed))
								
									seqGoodToGo = false
									float yAdj = offsetForActors - 0.08 - actorDistance
									if (mainActorIsMaleRole)
										yAdj = actorDistance - offsetForActors + 0.07
									endIf
								
									if (id >= 600 && id < 682)				;  should not happen, but changed upper bound to not handle chair scenes v2.73
										if (DTSleep_SettingTestMode.GetValue() > 0.0 && DTSleep_DebugMode.GetValue() >= 3.0)
											Debug.Trace(myScriptName + " AAF-set-6 --fix- move to bed")
										endIf
										; put second actor on bed
										;;revHeading = true
										PositionMarkerOnBed(mainNode, SleepBedRef, 0.0, yOffset, 0.0, true, false, revHeading, useAlternateBedAngle)
										;SecondActorRef.MoveTo(mainNode, 0.0, 0.0, 0.0, true)
										SceneData.MaleMarker = DTSleep_CommonF.PlaceFormAtObjectRef(DTSleep_MainNode, mainNode, false, true, true)

										count = -1
										seqGoodToGo = true
										attemptCount = 0
										
									elseIf (SceneData.AnimationSet == 5 || SceneData.AnimationSet >= 7 || (id >= 682 && id < 700))		; added Leito chairs v2.73 (unexpected)
									
										if (standOnly)
											PositionMarkerOnBed(mainNode, SleepBedRef, 0.0, 0.0, 0.0, true, false, revHeading, useAlternateBedAngle)
											;SecondActorRef.MoveTo(mainNode, 0.0, 0.0, 0.0, true)
											SceneData.MaleMarker = DTSleep_CommonF.PlaceFormAtObjectRef(DTSleep_MainNode, mainNode, false, true, true)
											
										elseIf (MainActorCloneRef != None)
											; should have been placed simple above
											SceneData.MaleMarker = DTSleep_CommonF.PlaceFormAtObjectRef(DTSleep_MainNode, MainActorCloneRef, false, true, true)
										else
											; should have been placed simple above
											SceneData.MaleMarker = DTSleep_CommonF.PlaceFormAtObjectRef(DTSleep_MainNode, MainActorRef, false, true, true)
										endIf
										count = -1
										seqGoodToGo = true
										attemptCount = 0
										
									elseIf (ptSecActor.Heading > ptMainActor.Heading + 0.7 || ptSecActor.Heading < ptMainActor.Heading - 0.7)
										
										Utility.Wait(0.1)
										if (dummyNode != None)
											SecondActorRef.MoveTo(dummyNode, 0.0, yAdj, 0.0, true)
										else
											SecondActorRef.SetPosition(ptDummyNode.X, ptDummyNode.Y, ptMainNode.Z)
										endIf
										
									elseIf (secActNodeDistance > 9.5)
									
										SecondActorRef.SetPosition(ptDummyNode.X, ptDummyNode.Y, ptMainNode.Z)

									else
										
										float adjDist = 0.8 - offsetForActors - yAdj
										if (mainActorIsMaleRole)
											adjDist = offsetForActors + 0.05 + yAdj
										endIf
										
										Point3DOrient goPt = DTSleep_CommonF.GetPointDistOnHeading(ptMainActor, adjDist)
										if (MainActorCloneRef != None)
											SecondActorRef.MoveTo(MainActorCloneRef, goPt.X, goPt.Y, goPt.Z, false)
										else
											SecondActorRef.MoveTo(MainActorRef, goPt.X, goPt.Y, goPt.Z, false)
										endIf
									endIf
									
									SecondActorRef.SetRestrained()
									Utility.Wait(0.05)
									
									ptSecActor = DTSleep_CommonF.PointOfObject(SecondActorRef)
									secActNodeDistance = DTSleep_CommonF.DistanceBetweenPoints(ptSecActor, ptDummyNode, false)
									actorDistance = DTSleep_CommonF.DistanceBetweenPoints(ptSecActor, ptMainActor, true)
									
									if (DTSleep_SettingTestMode.GetValue() > 0.0 && DTSleep_DebugMode.GetValue() >= 3.0)
										
										Debug.Trace(MyScriptName + " fixCmpion" + DTSleep_CommonF.Point3DOrientToString(ptSecActor))
										Debug.Trace(MyScriptName + " comp-node distance " + secActNodeDistance)
										Debug.Trace(MyScriptName + " actors    distance " + actorDistance)
										Debug.Trace(myScriptName + " -------------------------------------------------- ")
									endIf

									count -= 1
								endWhile
								
								if (!seqGoodToGo)
									if (IsActorsWithinDistLimit(actorDistance, ptMainActor.Z, ptSecActor.Z, mainNodeOnBed))
									
										float limit = offsetForActors
										
										if (secActNodeDistance > 12.5 && !mainNodeOnBed && attemptCount > 1)
											if (actorDistance > (limit - 1.28) && actorDistance < (limit + 0.6333))
												; close enough
												seqGoodToGo = true
												attemptCount = 0
											else
												; try again
												if (DTSleep_SettingTestMode.GetValue() > 0.0 && DTSleep_DebugMode.GetValue() >= 3.0)
													Debug.Trace(MyScriptName + " not on bed (try again)--Companion bad comp-node distance!  " + secActNodeDistance)
													Debug.Trace(myScriptName + " -------------------------------------------------- ")
												endIf
											endIf
										elseIf (secActNodeDistance > 16.2)
											
											if (actorDistance > (limit - 0.8) && actorDistance < (limit + 0.8))
												; close enough
												seqGoodToGo = true
												attemptCount = 0
											else
												seqGoodToGo = false
												attemptCount = 0
											endif
										else
											attemptCount = 0
											seqGoodToGo = true
										endIf
									elseIf (attemptCount > 1 && !mainNodeOnBed)
										if (DTSleep_SettingTestMode.GetValue() > 0.0 && DTSleep_DebugMode.GetValue() >= 3.0)
											Debug.Trace(MyScriptName + " not on bed (try again)--Companion bad distance!!  " + actorDistance)
											Debug.Trace(myScriptName + " -------------------------------------------------- ")
										endIf
										Utility.Wait(0.1)
									else
										seqGoodToGo = false
										attemptCount = 0
										if (DTSleep_SettingTestMode.GetValue() > 0.0 && DTSleep_DebugMode.GetValue() >= 3.0)
											Debug.Trace(MyScriptName + " cancel seq--Companion bad distance!!  " + actorDistance)
											Debug.Trace(myScriptName + " -------------------------------------------------- ")
										endIf
									endIf
								endIf
							endIf
							
							DTSleep_CommonF.DisableAndDeleteObjectRef(dummyNode, false, true)
							
						endIf
						
						DTSleep_CommonF.DisableAndDeleteObjectRef(myMainAtMeNode, false, true)
					else
						Debug.Trace(MyScriptName + " failed to create with 3D for myMainAtMeNode")
						seqGoodToGo = false
						attemptCount = 0
					endIf
				endIf
				
				attemptCount -= 1
			endWhile
			
			if (MainActorCloneRef != None)
				MainActorCloneRef.SetRestrained(true)
			endIf
		endIf
		
		if (DTSleep_CommonF.DisableAndDeleteObjectRef(mainNode, false) == false)
			Debug.Trace(MyScriptName + " Failed to delete Main Node!!")
		endIf
	else
		Debug.Trace(MyScriptName + "-FadeAndPlay--Failed to create mainNode with 3D!!")
		DTSleep_CommonF.DisableAndDeleteObjectRef(mainNode, false)
	endIf
	
	return seqGoodToGo
endFunction

; only works on workshop beds
;Function ShiftSleepBedZ(float val)
;
;	SleepBedRef.SetPosition(SleepBedRef.GetPositionX(), SleepBedRef.GetPositionY(), SleepBedRef.GetPositionZ() + val)
;endFunction

Function PositionMarkerCrazyForBed(ObjectReference markerRef, ObjectReference bedRef, bool isFemaleMarker)
	Point3DOrient ptBed = DTSleep_CommonF.PointOfObject(bedRef)
	Point3DOrient markerPoint = new Point3DOrient
	if (isFemaleMarker)
		markerPoint = DTSleep_CommonF.GetPointBedCrazyRugFem(ptBed.Heading)
	else
		markerPoint = DTSleep_CommonF.GetPointBedCrazyRugMale(ptBed.Heading)
	endIf
	markerRef.SetAngle(0.0, 0.0, ptBed.Heading)
	markerRef.MoveTo(bedRef, markerPoint.X, markerPoint.Y, markerPoint.Z, false)
endFunction

Point3DOrient Function PositionMarkerOnBed(ObjectReference markerRef, ObjectReference bedRef, float xDif, float yDif, float zDif, bool matchRotation = false, bool maleDominate = true, bool revHeading = false, bool alternateBedAngle = false)
	
	;Debug.Trace("[DTSleep_IAnim] PositionMarker OnBed - xDif: " + xDif + ", yDif: " + yDif + ", match Rotate: " + matchRotation)
	
	bool isLowBed = false
	bool isCoffin = false
	bool isBunk = false
	bool isTable = false
	if (bedRef.HasKeyword(AnimFurnFloorBedAnimKY))
		isLowBed = true	
	elseIf (bedRef.HasKeyword(AnimFurnLayDownUtilityBoxKY))
		isLowBed = true
		isCoffin = true
	elseIf (bedRef.HasKeyword(AnimFurnPicnickTableKY))
		isTable = true
	elseIf (!bedRef.HasKeyword(IsSleepFurnitureKY) && !SleepBedIsPillowBed && SleepBedAltRef == None)
		; v2.79 - included SleepBedAltRef since we may have set isPillowBed false and repalced with BedAltRef
		isLowBed = true
	endIf
	
	if (SleepBedIsPillowBed)
		yDif -= 70.0
		if (!isLowBed)
			zDif -= 42.0
		endIf
	endIf
	Point3DOrient ptBed = DTSleep_CommonF.PointOfObject(bedRef)
	
	if (revHeading)
		if (isTable)
			ptBed.Heading += 91.0
		elseIf (isCoffin || matchRotation)
			ptBed.Heading += 180.0
		else
			ptBed.Heading += 196.0
		endIf
		if (ptBed.Heading > 360.0)
			ptBed.Heading -= 360.0
		endIf

	elseIf (!isCoffin)
		; add a small angle - more room? or at least look better not aligned
		ptBed.Heading += (Utility.RandomInt(12, 20) as float)
		if (isTable)
			ptBed.Heading += 90.0
		endIf
	endIf
	if (alternateBedAngle)
		if (isCoffin)
			ptBed.Heading = 1.2
		else
			ptBed.Heading -= 36.0
		endIf
	endIf
	Point3DOrient ptBedPlace = new Point3DOrient

	ptBedPlace = DTSleep_CommonF.GetPointBedLeitoA(isLowBed, ptBed.Heading, xDif, yDif, maleDominate)
	
	if (bedRef.HasKeyword(DTSleep_SMBed02KY))
		markerRef.SetAngle(0.0, 0.0, (ptBed.Heading + 90.0))
	elseIf (isCoffin || matchRotation)
		markerRef.SetAngle(0.0, 0.0, ptBed.Heading)
	endIf
	
	;Debug.Trace("[DTSleep_IAnim] PositionMarker OnBed FIN - xDif: " + xDif + ", yDif: " + yDif + ", zDif: " + zDif)

	markerRef.MoveTo(bedRef, ptBedPlace.X, ptBedPlace.Y, ptBedPlace.Z + zDif, false)
	
	return ptBedPlace
endFunction

float Function PositionMarkerOnBedZAdjustForSceneID(int id)
	
	if (MainActorPositionByCaller)			; backup

		if (id >= 700 && id < 760 && id != 751 && id != 758)
			if (id == 740 && SceneData.SecondMaleRole != None)
				return -40.0
			endIf
			return -44.0
		endIf
	elseIf (SceneIDAtPlayerPosition(id))
		return 0.0
		
	elseIf (SleepBedIsPillowBed || SleepBedRef.HasKeyword(AnimFurnFloorBedAnimKY) || SleepBedRef.HasKeyword(AnimFurnLayDownUtilityBoxKY) || MySleepBedFurnType == FurnTypeIsSleepingBag)
		float offSet = 4.25
		float smallOffset = 1.6
		if (MySleepBedFurnType == FurnTypeIsSleepingBag)
			offSet = 0.0
			smallOffset = 0.0
		endIf
		if (id >= 600 && id < 700)
			return 0.0
		elseIf (id >= 800 && id < 900)
			return 0.0
		elseIf (id >= 1100 && id < 1200)			; v3.15
			if (MySleepBedFurnType == FurnTypeIsSleepingBag)
				return 1.4
			endIf
			return 0.6
			
		elseIf (id >= 700 && id <= 701)
			return -40.1 + offSet
			
		elseIf (id >= 704 && id <= 711)
			if (id == 705 && SceneData.SecondMaleRole != None)
				return 4.0
			endIf
			return -38.5  + offSet
			
		elseIf (id >= 713 && id <= 714)
			return 0.1
		elseIf (id == 504 || id == 541 || id == 550)
			return 0.16 + smallOffset
		elseIf (id >= 900 && id < 960)
			return 0.16	+ smallOffset				; added v1.60
			
		elseIf (id >= 1000 && id < 1019)			
			; BP70 floor animations on bed
			if (id == 1010)
				return offset			; using node marker
			endIf
			return 0.12
		elseIf (id >= 1047 && id < 1070)
			; BP70 floor animations on bed
			return 0.12
		elseIf (id >= 1083 && id < 1100)
			if (id == 1096)
				return offset  ; using node marker 
			endIf
			; BP70 floor animtions on bed
			return 0.12
			
		elseIf (id >= 507 && id <= 508)
			return 0.16 + smallOffset
		elseIf (id == 510)
			return 0.16 + smallOffset
		elseIf (id == 770)
			return 0.2
		elseIf (id == 751 && !SleepBedIsPillowBed)
			return 0.16
		elseIf (id >= 590 && id < 600)
			return 0.24 + smallOffset
		elseIf (id == 180 || id == 680)
			return 5.2
		elseIf (id == 798)
			return -29.2
		elseIf (id == 963)
			return 3.0 + offset
		endIf
	elseIf (SleepBedRef.HasKeyword(DTSleep_SMBed02KY))
		if (id == 759)
			return 4.25
		elseIf (id == 751 || id == 758)
			return 31.25
		elseIf (id >= 767 && id <= 768)
			return 0.0				; actual SMBed scene
		elseIf (id >= 700 && id < 800)
			return -8.75
		elseIf (id >= 505 && id <= 506)
			return -8.75
		elseIf (id == 509)
			return -8.75
		elseIf (id >= 100 && id < 700)
			return 31.25
		elseIf (id >= 900 && id <= 1000)
			return 31.25
		endIf
	elseIf (SleepBedRef.HasKeyword(AnimFurnPicnickTableKY))
		
		if (id >= 700 && id < 800)
			if (id != 743)
				return 10.0
			endIf
		elseIf (id == 470)
			return 0.0
		else
			; up from normal bed height -- for on-ground scenes like Leito, apparently bumped up on top...
			return 10.0
		endIf
	
	elseIf (IsObjBed(SleepBedRef) == false)
	
		if (IsObjPoolTable(SleepBedRef, None))
	
			if (id >= 756 && id <= 757)
				; actual pool table scenes
				return 0.0
			elseIf (id >= 700 && id < 800)
				; up from normal bed height
				return 24.2 ; pool table to shift up
			elseIf (id >= 590 && id < 600)
				return (17.2 + DTSleep_CommonF.GetBedHeight())
			elseIf (id == 504 || id == 507 || id == 540 || id == 541 || id >= 900)
				return (17.2 + DTSleep_CommonF.GetBedHeight())
			elseIf (id >= 400)
				return (18.8 + DTSleep_CommonF.GetBedHeight())
			else
				; up from normal bed height
				return 26.2
			endIf
		endIf
	elseIf (id >= 797 && id <= 799)
		return 8.0
		
	elseIf (id == 180 || id == 680)
		return 43.25
		
	elseIf (id >= 590 && id < 600)
		return 0.12
	elseIf (id == 504 || id == 541 || id == 550)
		; no bed z-offset with this animation so plays at bed position (beneath bed) -- added v1.60
		return 0.12
	elseIf (id >= 900 && id < 1000)
		return 0.12
	elseIf (id >= 1100 && id <= 1049)
		; RZSex floor animations on bed
		return 43.25
		
	elseIf (id >= 1000 && id < 1019)					
		; BP70 floor animations on bed
		if (id == 1010)
			return 43.2				; using node marker
		endIf
		return 0.12
	elseIf (id >= 1047 && id < 1070)
		; BP70 floor animations on bed
		return 0.12
	elseIf (id >= 1083 && id < 1100)
		;if (id == 1096)
		;	return 43.2   ; using node marker 
		;endIf
		; BP70 floor animtions on bed
		return 0.12
	elseIf (id >= 507 && id <= 508)
		return 0.16
	elseIf (id == 510)
		return 0.12
	elseIf (id == 109)
		return 1.0
	endIf

	return 0.0
endFunction


bool Function ProcessCopyEquipItemActors(Armor armorItem, Actor actorFrom, Actor actorTo, bool forceEquip = false, bool overrideCountLimit = false)

	if (armorItem != None)
		; limit to if only 1 to avoid equip wrong item
		; v3.17 -- allow caller to override limit
		
		int cnt = actorFrom.GetItemCount(armorItem)
		
		if (cnt == 1 || (overrideCountLimit && cnt > 1))
			actorFrom.UnequipItem(armorItem, false, true)
			Utility.Wait(0.1)
			actorFrom.RemoveItem(armorItem, 1, true, actorTo)

			actorTo.EquipItem(armorItem, forceEquip, true)
			Utility.WaitMenuMode(0.08)
			
			return true
		endIf
	endIf
	
	return false
endFunction

;
; need F4SE to get actual worn items and modifications
;
bool Function ProcessMainActorClone()

	; if have LooksMenu morphs then should not clone - set pref onLoad then let player decide
	;
	bool hasGameReloaded = (DTSConditionals as DTSleep_Conditionals).HasReloaded
	
	if (DTSleep_PlayerClone != None && hasGameReloaded) ;&& (DTSConditionals as DTSleep_Conditionals).IsF4SE)
	
		MainActorCloneRef = MainActorRef.PlaceActorAtMe(DTSleep_PlayerClone) 
		
		if (MainActorCloneRef != None)
			MainActorCloneRef.Waitfor3dload()
			
			if (MainActorCloneRef.Is3DLoaded())
			
				; use ring to prevent NPC from loading clothes
				if (DTSleep_SettingAltFemBody.GetValueInt() >= 1 && MainActorRef.GetItemCount(DTSleep_AltFemBody) > 0)
					MainActorCloneRef.EquipItem(DTSleep_AltFemBody, true, true)
				else
					MainActorCloneRef.EquipItem(DTSleep_NudeRing, true, true)
				endIf
			
				MainActorCloneRef.SetRestrained(true)
				MainActorRef.AddSpell(DTSleep_InvisibiltySpell, false)
				if (DTSleep_SettingCollision.GetValue() >= 1.0)
					Utility.SetIniBool("bDisablePlayerCollision:Havok", true)				;v2.70 - so NPCs walk through instead of push camera 
					DTSleep_PlayerCollisionEnabled.SetValueInt(-1)							;      - for safety should reset on load --- player may load game before scene ends
				endIf
				MainActorOutfitArray = new Form[0]	; only store moved gear
				Form[] gearList = (DTSleep_UndressPAlias as DTSleep_EquipMonitor).GetMyPlayerEquipment()
				bool foundToyArmor = false
				
				if (gearList != None)

					int i = 0
					while (i < gearList.Length)
						Armor item = gearList[i] as Armor
						if (item != None)
							; only copy as Armor to avoid mod-armor
							
							bool okayToCopy = true
							bool doOverride = false		; normally we only copy unique items, but override for sexy gear  -v3.17
							
							if (SceneData.ToyArmor != None && item == SceneData.ToyArmor)
								foundToyArmor = true
								if (SceneData.HasToyEquipped)
									doOverride = true		; v3.17
								else
									; toy not needed
									okayToCopy = false
								endIf
							
							endIf
							
							if (okayToCopy && MainActorRef.IsEquipped(item))
								
								if (ProcessCopyEquipItemActors(item, MainActorRef, MainActorCloneRef, true, doOverride))
									
									MainActorOutfitArray.Add(gearList[i])
								endIf
							endIf
						endIf
						
						i += 1
					endWhile
				endIf
				
				; -----------
				; double-check
				;
				if (SceneData.ToyArmor != None && SceneData.HasToyEquipped && SceneData.MaleRole == MainActorRef && SceneData.MaleRoleGender == 1)
					
					if (foundToyArmor)
						; ensure clone has toy equipped -- may not copy if player had 2 of same item inventoried -- v3.17
						if (MainActorCloneRef.IsEquipped(SceneData.ToyArmor) == false)
							Debug.Trace(myScriptName + " clone needed ToyArmor, but not equipped... reset and check again")
							foundToyArmor = false
						endIf
					endIf
					
					if (!foundToyArmor)
						; v2.35 check clone 
						; may happen if this script equipped and EquipMonitor still processing when retrieved gearList
						;      or when 2 or more inventoried
						if (DTSleep_SettingTestMode.GetValue() > 0.0 && DTSleep_DebugMode.GetValue() >= 2.0)
							Debug.Trace(myScriptName + " clone needed ToyArmor, but did not find during equip copy... check now")
						endIf
						if (MainActorRef.GetItemCount(SceneData.ToyArmor) > 0)
							; override count-limit v3.17
							if (ProcessCopyEquipItemActors(SceneData.ToyArmor, MainActorRef, MainActorCloneRef, true, true))
								foundToyArmor = true
								MainActorOutfitArray.Add(SceneData.ToyArmor)
							endIf
						endIf
					endIf
				endIf
		
			
				if (SceneData.MaleRole == MainActorRef)
					SceneData.MaleRole = MainActorCloneRef
				elseIf (SceneData.FemaleRole == MainActorRef)
					SceneData.FemaleRole = MainActorCloneRef
				endIf
				
				MainActorRef.SetGhost(true)
				
				MainActorCloneRef.SetGhost(true)
				
				return true
			else
				DTSleep_CommonF.DisableAndDeleteObjectRef(MainActorCloneRef, false)
				MainActorCloneRef = None
				Debug.Trace(myScriptName + " failed to clone player - no 3D!")
			endIf
		else
			MainActorCloneRef = None
			Debug.Trace(myScriptName + " failed to clone player!")
		endIf
	endIf
	
	return false
	
endFunction

; returns true if removed a clone; false if no clone used
;
bool Function ProcessMainActorRecover()

	if (MainActorCloneRef != None)
		if (SceneData.MaleRole == MainActorCloneRef)
			SceneData.MaleRole = MainActorRef
		elseIf (SceneData.FemaleRole == MainActorCloneRef)
			SceneData.FemaleRole = MainActorRef
		endIf
		
		if (MainActorOutfitArray != None)
			int i = 0
			while (i < MainActorOutfitArray.Length)
				Armor item = MainActorOutfitArray[i] as Armor
				ObjectReference armorRef = MainActorOutfitArray[i] as ObjectReference
				
				ProcessCopyEquipItemActors(item, MainActorCloneRef, MainActorRef)
				
				i += 1
			endWhile
			MainActorOutfitArray.Clear()
			MainActorOutfitArray = None
			if (MainActorCloneRef.GetItemCount(DTSleep_NudeRing) > 0)
				
				MainActorCloneRef.RemoveItem(DTSleep_NudeRing)
			endIf
		endIf
		
		MainActorRef.SetGhost(false)
		MainActorRef.SetAlpha(1.0)
		if (DTSleep_SettingCollision.GetValue() >= 1.0)
			Utility.SetIniBool("bDisablePlayerCollision:Havok", false)			; v2.70 - reset
			DTSleep_PlayerCollisionEnabled.SetValueInt(1)
		endIf
		MainActorRef.RemoveSpell(DTSleep_InvisibiltySpell)
		
		return true
	endIf
	
	return false
endFunction

; call this before looping through animation packs where for each pack call SceneIDArrayForAnimationSet
bool Function SceneIDArrayPrepMyFurnitureType()
	MySleepBedFurnType = -1
	if (SleepBedRef == None)
		return false
	endIf
	Form baseBedForm = SleepBedRef.GetBaseObject() as Form
	
	if (IsObjBed(SleepBedRef) || SleepBedIsPillowBed)								; v3.0 check first
			
		if (IsSleepingDoubleBed(SleepBedRef, baseBedForm, SleepBedIsPillowBed))
			MySleepBedFurnType = FurnTypeIsDoubleBed
		elseIf (SleepBedAltRef != None && IsSleepingDoubleBed(SleepBedAltRef, baseBedForm, SleepBedIsPillowBed))
			MySleepBedFurnType = FurnTypeIsDoubleBed
		elseIf (SleepBedRef.HasKeyword(IsSleepFurnitureKY) && IsObjBedLimitedSpace(SleepBedRef, baseBedForm))
			MySleepBedFurnType = FurnTypeIsLimitedSpaceBed
		elseIf (SleepBedRef.HasKeyword(AnimFurnLayDownUtilityBoxKY))
			MySleepBedFurnType = FurnTypeIsCoffin
		elseIf (IsSleepingBag(SleepBedRef))
			MySleepBedFurnType = FurnTypeIsSleepingBag
		elseIf (SleepBedRef.HasKeyword(AnimFurnFloorBedAnimKY))
			MySleepBedFurnType = FurnTypeIsFloorBed
		elseIf (IsSleepingBunkBed(SleepBedRef, baseBedForm))
			MySleepBedFurnType = FurnTypeIsBunkBed
		else
			MySleepBedFurnType = FurnTypeIsBedSingle			; default 
		endIf
	else 
		int sedanType = GetObjSedanType(SleepBedRef, baseBedForm)
		if (sedanType > 0)
			MySleepBedFurnType = sedanType
		elseIf (IsASuperMutantBed(SleepBedRef, baseBedForm))
			MySleepBedFurnType = FurnTypeIsSMBed
		endIf
	endIf
	
	if (MySleepBedFurnType <= 0)
		if ((DTSConditionals as DTSleep_Conditionals).WeightBenchKY != None && SleepBedRef.HasKeyword((DTSConditionals as DTSleep_Conditionals).WeightBenchKY))
			MySleepBedFurnType = FurnTypeIsWeightBench
		elseIf (DTSleep_PilloryList.HasForm(baseBedForm) || DTSleep_TortureDList.HasForm(baseBedForm))
			MySleepBedFurnType = FurnTypeIsPillory
		elseIf (SleepBedRef.HasKeyword(PowerArmorWorkBenchKY))
			MySleepBedFurnType = FurnTypeIsPARepair
		elseIf (SleepBedRef.HasKeyword(WorkbenchArmorKY))				; v2.70
			MySleepBedFurnType = FurnTypeIsWorkbenchArmor
		elseIf (DTSleep_IntimateWorkbenchWLargeList.HasForm(baseBedForm)) ; v2.70
			MySleepBedFurnType = FurnTypeIsWorkBenchWeaponLarge
		elseIf (DTSleep_IntimatePierRailingList.HasForm(baseBedForm))		; v2.70
			MySleepBedFurnType = FurnTypeIsRailing
			
		elseIf (IsObjTable(SleepBedRef, baseBedForm))
			
			if (IsObjPoolTable(SleepBedRef, baseBedForm))
				MySleepBedFurnType = FurnTypeIsTablePool
			elseIf (SleepBedRef.HasKeyword(AnimFurnPicnickTableKY))
				MySleepBedFurnType = FurnTypeIsTablePicnic
			elseIf (IsObjDinerBoothTable(SleepBedRef, baseBedForm))
				MySleepBedFurnType = FurnTypeIsTableDinerBooth
			elseIf (DTSleep_IntimateDiningTableList.HasForm(baseBedForm))
				MySleepBedFurnType = FurnTypeIsTableDining
			elseIf (DTSleep_IntimateRoundTableList.HasForm(baseBedForm))
				MySleepBedFurnType = FurnTypeIsTableRound	
			elseIf (DTSleep_IntimateDeskList.HasForm(baseBedForm))
				MySleepBedFurnType = FurnTypeIsTableDesk
			elseIf (DTSleep_IntimatePatioTwoTableList.HasForm(baseBedForm))
				MySleepBedFurnType = FurnTypeIsTablePatio					; v2.88
			else
				MySleepBedFurnType = FurnTypeIsTableTable
			endIf
			
		elseIf (IsObjSeat(SleepBedRef))
		
			if (SleepBedRef.HasKeyword(DTSleep_IntimateChairKeyword) || DTSleep_IntimateChairsList.HasForm(baseBedForm))
				MySleepBedFurnType = FurnTypeIsSeatIntimateChair
			elseIf (SleepBedRef.HasKeyword(AnimFurnCouchKY) || DTSleep_IntimateCouchList.HasForm(baseBedForm) || DTSleep_IntimateCouchFedList.HasForm(baseBedForm))
				MySleepBedFurnType = FurnTypeIsSeatSofa
			elseIf (DTSleep_IntimateBenchList.HasForm(baseBedForm))
				MySleepBedFurnType = FurnTypeIsSeatBench
			elseIf (DTSleep_IntimateChairLowList.HasForm(baseBedForm))
				MySleepBedFurnType = FurnTypeIsSeatLow
			elseIf (DTSleep_IntimateChairArmSmList.HasForm(baseBedForm))
				MySleepBedFurnType = FurnTypeIsSeatLowArmRest
			elseIf (DTSleep_IntimateChairHighList.HasForm(baseBedForm))
				MySleepBedFurnType = FurnTypeIsSeatHigh
			elseIf (DTSleep_IntimateKitchenSeatList.HasForm(baseBedForm))
				MySleepBedFurnType = FurnTypeIsSeatKitchen
			elseIf (DTSleep_IntimateChairThroneList.HasForm(baseBedForm))
				MySleepBedFurnType = FurnTypeIsSeatThrone
			elseIf (SleepBedRef.HasKeyword(AnimFurnBarStoolKY) || SleepBedRef.HasKeyword(AnimFurnEatingNoodlesKY) || SleepBedRef.HasKeyword(AnimFurnStoolWithBarKY))
				MySleepBedFurnType = FurnTypeIsSeatStool
			elseIf (DTSleep_IntimateChairOttomanList.HasForm(baseBedForm))
				MySleepBedFurnType = FurnTypeIsSeatOttoman
			else
				MySleepBedFurnType = FurnTypeIsSeatBasic
			endIf
		elseIf (IsObjShower(SleepBedRef, baseBedForm))
			MySleepBedFurnType = FurnTypeIsShower
		elseIf (IsObjMotorcycle(SleepBedRef, baseBedForm))
			MySleepBedFurnType = FurnTypeIsMotorCycle
		elseIf (IsObjKitchenCounter(SleepBedRef, baseBedForm))
			MySleepBedFurnType = FurnTypeIsTableKitchenCounter
		elseIf (IsObjKitchenCabinet(SleepBedRef, baseBedForm))
			MySleepBedFurnType == FurnTypeIsTableKitchenCabinet
		elseIf (DTSleep_IntimateDoorJailList.HasForm(baseBedForm))
			MySleepBedFurnType = FurnTypeIsJail
		elseIf (SleepBedRef.HasKeyword(DTSleep_IntimateLockerKeyword) || DTSleep_IntimateLockerList.HasForm(baseBedForm))
			MySleepBedFurnType = FurnTypeIsLocker
		elseIf (DTSleep_IntimateStoveList.HasForm(baseBedForm))
			MySleepBedFurnType = FurnTypeIsStove
		endIf	
	endIf

	return true
endFunction

; set includeHugs ==1 for chose cuddle, ==2 for XOXO, ==3 for hug-only, ==4 for kiss-only
; call SceneIDArrayPrepMyFurnitureType first
; NOTE: for basic hug-and-kiss animations set packID 0
; standOnly is a preference
;
int[] Function SceneIDArrayForAnimationSet(int packID, bool mainActorIsMaleRole, bool noLeitoGun, bool standOnly, int[] sidArray, int includeHugs, int packLimitVal = -1)
	int startIndex = 0
	bool playerPick = false
	if (sidArray == None)
		sidArray = new int[0]
	else
		startIndex = sidArray.Length
	endIf
	
	if (packID > 3 && packLimitVal >= 1)				; limit by pack ID no longer using debugMode   v3.15
		if (packLimitVal != packID)
			Debug.Trace(MyScriptName + " pack " + packID + " not checked for packLimit Pref ID " + packLimitVal)
			return sidArray
		endIf
	endIf
	
	bool bedIsFloorBed = false
	bool bedIsCoffin = false
	bool restricted = false   ; if same-gender no toy
	bool pillowBedHasFrame = false
	bool bedIsSMBed = false
	bool bedDoubleIsInstitute = false										; v2.70 - to differentiate SC 1.2.6 animation
	Form baseBedForm = None
	
	if (MySleepBedFurnType == FurnTypeIsDoubleBed)
		; v2.70 - is specific institute bed?
		if ((DTSConditionals as DTSleep_Conditionals).SavageCabbageVers >= 1.26)
			; TODO - is it an institute bed?  
		endIf
	elseIf (MySleepBedFurnType == FurnTypeIsCoffin)
		bedIsFloorBed = false
		bedIsCoffin = true
	elseIf (MySleepBedFurnType == FurnTypeIsFloorBed)					; v2.70 changed from DoubleBed
		bedIsFloorBed = true
		standOnly = false
	elseIf (MySleepBedFurnType == FurnTypeIsSMBed)
		bedIsFloorBed = false											; not a floor bed v2.73
		bedIsSMBed = true
	elseIf (MySleepBedFurnType == FurnTypeIsSleepingBag)
		bedIsFloorBed = true
		standOnly = false
	elseIf (SleepBedRef.HasKeyword(AnimFurnFloorBedAnimKY))
		bedIsFloorBed = true
		standOnly = false
	endIf
	
	; isPillowBed may be false if frame already found 
	;  -- IsPillowBed considered floor bed, but may be placed on a bed
	if (SleepBedIsPillowBed && !bedIsFloorBed)
		pillowBedHasFrame = true
	endIf
	
	if (noLeitoGun && packID >= 1 && packID <= 2 && DTSleep_SettingUseBT2Gun.GetValue() > 0.0)
		if (SceneData.SameGender && SceneData.MaleRoleGender == 1)
			; 2 females okay
		else
			Debug.Trace(myScriptName + " ScenePick for packID " + packID + " no LeitoGun Pref so no scenes added ")
			return sidArray
		endIf
	endIf
	
	if (MainActorScenePrefArray.Length > 0)
		playerPick = true
		noLeitoGun = false					; ignore when pick   v2.73
	endIf
	
	bool okayAdd = true
	;; No longer needed v3.0 -- int genderPref = DTSleep_SettingGenderPref.GetValueInt()  ; 2 for both; 1 = female
	int embraceType = 1	; hug or kiss
	
	if (includeHugs > 2)
		embraceType = includeHugs
	endIf

	bool cuddlesOnly = false
	
	if (includeHugs < 2)
		; fix v2.90
		if (includeHugs == 1 || DoesMainActorPrefID(ScenePrefIsCuddle) || DoesMainActorPrefID(ScenePrefIsKiss))
			includeHugs = 1
			cuddlesOnly = true
		endIf
	endIf
	
	if (DTSleep_SettingTestMode.GetValueInt() >= 1 && DTSleep_DebugMode.GetValueInt() >= 1)
		Debug.Trace(myScriptName + " checking pack " + packID + ", includeHugs = "  + includeHugs + ", playerPick? " + playerPick + ", FurnitureType = " + MySleepBedFurnType + ", compInPowerArmor = " + SceneData.CompanionInPowerArmor + ", pref-Stand? " + SceneData.PreferStandOnly + ", mainActorPositioned? " + MainActorPositionByCaller)
		if (playerPick)
			Debug.Trace(myScriptName + "---------- playerPickArray = " + MainActorScenePrefArray)
		endIf
	endIf
	
	; safe content first
	; using packID-zero for all safe-content no matter which pack
	; v3.0 also include CHAK pack-4 found only here
	;
	if (includeHugs > 0 && (packID <= 0 || packID == 4)) 
		; v2 included hugs/kisses
		if (!SceneData.CompanionInPowerArmor)
			if (!SceneData.IsUsingCreature || SceneData.IsCreatureType == 3)
				
				; v2.60 allow diner booth flirt for adult-pack users
				; v2.86 also include XOXO-PC users
				
				if (MySleepBedFurnType >= 197 &&  MySleepBedFurnType < 220)
					; a bed - no hug/kiss choice, but split anyway
					if (embraceType <= 1 || embraceType == 3)
						; hugs
						
						if (!MainActorPositionByCaller && (DTSConditionals as DTSleep_Conditionals).IsCHAKPackActive && DTSleep_AdultContentOn.GetValue() >= 1.0)
							if (MySleepBedFurnType == FurnTypeIsBedSingle)
								sidArray.Add(400, 3)
							elseIf (MySleepBedFurnType == FurnTypeIsDoubleBed)
								sidArray.Add(401, 3)
							endIf
						endIf
						if (!cuddlesOnly && packID <= 0)
							sidArray.Add(99)
							sidArray.Add(95)
						endIf
					endIf
					if (embraceType <= 1 || embraceType == 4)
						; kisses
						
						if (!MainActorPositionByCaller && (DTSConditionals as DTSleep_Conditionals).IsCHAKPackActive && DTSleep_AdultContentOn.GetValue() >= 1.0)
							if (MySleepBedFurnType == FurnTypeIsDoubleBed)
								sidArray.Add(402, 3)
							endIf
						endIf
						if (!cuddlesOnly && packID <= 0)
							sidArray.Add(97)
							if (!SceneData.SameGender)
								sidArray.Add(94)
							endIf
						endIf
					endIf
				
				elseIf (embraceType == 3 && packID <= 0 && MySleepBedFurnType == FurnTypeIsTableDinerBooth && DTSleep_AdultContentOn.GetValue() >= 1.0 && (DTSConditionals as DTSleep_Conditionals).IsSavageCabbageActive && (DTSConditionals as DTSleep_Conditionals).ImaPCMod)
					
					; booth-sit flirt
					sidArray.Add(780)
					
				else
					; v3.0 - decided by hug or kiss and furniture
					; basics first
					if (embraceType <= 1 && packID <= 0)
						; basic hugs
						sidArray.Add(99)
						sidArray.Add(95)
					endIf
					if (embraceType <= 1 && packID <= 0)
						; basic kisses
						sidArray.Add(98)
						sidArray.Add(97)
						if (!SceneData.SameGender)
							sidArray.Add(94)			; height mismatch
						endIf
					endIf
					
					; special situations for packs
					if (embraceType == 3)
						; hugs
						
						if (!MainActorPositionByCaller && MySleepBedFurnType == FurnTypeIsSeatSofa && DTSleep_AdultContentOn.GetValue() >= 1.0)
							if ((DTSConditionals as DTSleep_Conditionals).IsRufgtRaidHeartActive && packID <= 0)
								; v2.87 - allow couch cuddle for PC users
								sidArray.Add(535)
							endIf
							if ((DTSConditionals as DTSleep_Conditionals).IsCHAKPackActive)
								if (baseBedForm == None)
									baseBedForm = SleepBedRef.GetBaseObject() as Form
								endIf
								if (!DTSleep_IntimateCouchLimSpaceList.HasForm(baseBedForm))
									
									sidArray.Add(451)
								endIf
							endIf
						else
							; standing hugs
							if ((DTSConditionals as DTSleep_Conditionals).IsCHAKPackActive)
								
								sidArray.Add(497)
								sidArray.Add(496)
							endIf
						endIf
						
					elseIf (embraceType == 4)
						; kisses
						if ((DTSConditionals as DTSleep_Conditionals).IsCHAKPackActive && DTSleep_AdultContentOn.GetValue() >= 1.0)
							; check furniture
							if (!MainActorPositionByCaller && MySleepBedFurnType == FurnTypeIsSeatStool)
								sidArray.Add(460)
							
							elseIf (!MainActorPositionByCaller && MySleepBedFurnType == FurnTypeIsSeatSofa)
								if (baseBedForm == None)
									baseBedForm = SleepBedRef.GetBaseObject() as Form
								endIf
								if (!DTSleep_IntimateCouchLimSpaceList.HasForm(baseBedForm))
									sidArray.Add(450)
									sidArray.Add(452)
								endIf
							
							elseIf (MySleepBedFurnType == FurnTypeIsTablePicnic || MySleepBedFurnType == FurnTypeIsTableDining)
									sidArray.Add(470)
							
							elseIf (DTSleep_AdultContentOn.GetValue() >= 2.0 && (DTSConditionals as DTSleep_Conditionals).IsBP70Active)
							
								sidArray.Add(1098)
							endIf
						endIf
					endIf
				endIf
			endIf
		endIf
	endIf
	
	
	; sexual content
	;
	if (packID > 0 && DTSleep_AdultContentOn.GetValue() >= 2.0 && includeHugs <= 1)
	
		if (MySleepBedFurnType == FurnTypeIsPillory && !SceneData.IsUsingCreature && !SceneData.CompanionInPowerArmor)
		
			if (packID == 8 && SceneData.SecondMaleRole == None && SceneData.SecondFemaleRole == None && MySleepBedFurnType == FurnTypeIsPillory)
				if (!SceneData.SameGender); && SleepBedRef.HasKeyword((DTSConditionals as DTSleep_Conditionals).ZaZPilloryKW))
				
					if (RestrictScenesToErectAngle < 0)
						sidArray.Add(50)
						sidArray.Add(49)
					endIf
					if (RestrictScenesToErectAngle <= 0)
							
						if (!SceneData.FemaleRaceHasTail)
							sidArray.Add(51)
							sidArray.Add(52)
						endIf
					endIf
				endIf
			elseIf (packID == 7 && !SceneData.FemaleRaceHasTail)
				
				if (!SceneData.SameGender)
					if (baseBedForm == None)
						baseBedForm = SleepBedRef.GetBaseObject() as Form
					endIf
					if (MySleepBedFurnType == FurnTypeIsPillory)				; v2.60 fix None check
						if (SceneData.SecondMaleRole != None || ((DTSConditionals as DTSleep_Conditionals).DLC05PilloryKY != None && SleepBedRef.HasKeyword((DTSConditionals as DTSleep_Conditionals).DLC05PilloryKY)))
							if ((DTSConditionals as DTSleep_Conditionals).SavageCabbageVers >= 1.10 || SceneData.SecondMaleRole == None)
								sidArray.Add(48)
							endIf
						endIf
					elseIf (DTSleep_TortureDList.HasForm(baseBedForm))
						if ((DTSConditionals as DTSleep_Conditionals).SavageCabbageVers >= 1.10 || SceneData.SecondMaleRole == None)
							sidArray.Add(49)	; includes 2nd male
						endIf
					endIf
				endIf
			endIf
		elseIf (MySleepBedFurnType == FurnTypeIsWeightBench && !SceneData.IsUsingCreature && !SceneData.CompanionInPowerArmor && !MainActorPositionByCaller)
			if (packID == 7 && !SceneData.SameGender && (DTSConditionals as DTSleep_Conditionals).SavageCabbageVers >= 1.10)
				sidArray.Add(42)
			endIf
		elseIf (MySleepBedFurnType == FurnTypeIsPARepair && !SceneData.IsUsingCreature && !SceneData.CompanionInPowerArmor)
			
			if (packID == 5)
				bool okayToAdd = true 	
				if ((DTSConditionals as DTSleep_Conditionals).RZSexVers >= 2.50)
					; has pack with regular sex, so only add if picked oral     	v3.20
					if (!playerPick || !DoesMainActorPrefID(ScenePrefIsOral))
						okayToAdd = false
					endIf
				endIf
				if (okayToAdd)
					if (SceneData.SameGender && SceneData.MaleRoleGender == 1)
						sidArray.Add(36)	
						;sidArray.Add(37) ; actors position needs adjustment
					elseIf (!SceneData.SameGender)
						sidArray.Add(36)
						;sidArray.Add(37)
					endIf
				endIf
			elseIf (packID == 11 && (DTSConditionals as DTSleep_Conditionals).RZSexVers >= 2.50)				; v3.20
				if (playerPick && DoesMainActorPrefID(ScenePrefIsOral))
					sidArray.Add(38)    ;  oral
				elseIf (!playerPick)
					if (!SceneData.SameGender || SceneData.HasToyAvailable)
						sidArray.Add(39)	;  doggy
					else
						sidArray.Add(38)    ;  oral
					endIf
				endIf
			endIf
		elseIf (MySleepBedFurnType == FurnTypeIsWorkbenchArmor && !SceneData.IsUsingCreature && !SceneData.CompanionInPowerArmor && !MainActorPositionByCaller)
			; v2.70 added workbench for SC 1.2.6
			if (packID == 7 && !SceneData.SameGender && (DTSConditionals as DTSleep_Conditionals).SavageCabbageVers >= 1.26)
				sidArray.Add(93)
			endIf
			if (packID == 11 && !SceneData.SameGender)				; v3.15
				sidArray.Add(93)
			endIf
		elseIf (MySleepBedFurnType == FurnTypeIsWorkBenchWeaponLarge && !SceneData.IsUsingCreature && !SceneData.CompanionInPowerArmor && !MainActorPositionByCaller)
			; v2.70 added workbench for SC 1.2.6
			if (packID == 7 && !SceneData.SameGender && (DTSConditionals as DTSleep_Conditionals).SavageCabbageVers >= 1.26)
				sidArray.Add(94)
			endIf
		elseIf (MySleepBedFurnType == FurnTypeIsRailing && !SceneData.IsUsingCreature && !SceneData.CompanionInPowerArmor && !MainActorPositionByCaller)
			; v2.70 added railing for SC 1.2.6
			if (packID == 7 && !SceneData.SameGender && (DTSConditionals as DTSleep_Conditionals).SavageCabbageVers >= 1.26)
				sidArray.Add(97)
			endIf
		elseIf (MySleepBedFurnType >= 220 && MySleepBedFurnType < 250 && SceneData.MaleRole != CompStrongRef && !standOnly && !MainActorPositionByCaller)
			; 
			;  ****** chairs *******
			;
			
			if (SceneData.CompanionInPowerArmor)					; v2.90
				; self-play
				if (MySleepBedFurnType == FurnTypeIsSeatSofa)
					if (packID == 10)
						sidArray.Add(61)
					endIf
				endIf
				
			elseIf (!SceneData.CompanionInPowerArmor && SceneData.IsCreatureType != 3 && SceneData.IsCreatureType < 5)
			
				if (packID == 5 && (DTSConditionals as DTSleep_Conditionals).AtomicLustVers >= 2.43 && !SceneData.IsUsingCreature && !SceneData.SameGender)
					if (MySleepBedFurnType == FurnTypeIsSeatIntimateChair)
						if (SceneData.SecondMaleRole == None && SceneData.SecondFemaleRole == None && playerPick && DoesMainActorPrefID(ScenePrefIsOral))
							sidArray.Add(38)
						endIf
					endIf
					
				elseIf (packID == 6 && (DTSConditionals as DTSleep_Conditionals).LeitoAnimVers >= 2.1)
					; FO4 Animations by Leito v2.1 added chair animations  - v2.73
					
					if (!SceneData.SameGender || (SceneData.HasToyAvailable))
						; v2.82 fix limit same-gender to toy
						
						if (playerPick && DoesMainActorPrefID(ScenePrefIsOral) && !(DTSConditionals as DTSleep_Conditionals).IsSavageCabbageActive)
							; picked oral/manual, but no SC oral available
							sidArray.Add(50)
							
						elseIf (!playerPick && SceneData.SecondFemaleRole == None && SceneData.SecondMaleRole == None)
							; no oral choice or extra lovers
							bool cowgirlOK = false
							bool cowgirlRevOK = false
							bool doggyOk = false
							bool missionOK = false 			; 682 grabs backrest
							
							if (MySleepBedFurnType == FurnTypeIsSeatIntimateChair)
								doggyOk = true
								missionOK = true
								cowgirlOK = true
								cowgirlRevOK = true
								
							elseIf (MySleepBedFurnType == FurnTypeIsSeatSofa)
								
								if (baseBedForm == None)
									baseBedForm = SleepBedRef.GetBaseObject()
								endIf
								if (DTSleep_IntimateCouchLimSpaceList.HasForm(baseBedForm))
									doggyOk = true
								else
									; limit for female player with male companion if SC exist
									if (!SceneData.SameGender && (DTSConditionals as DTSleep_Conditionals).IsSavageCabbageActive && !mainActorIsMaleRole && Utility.RandomInt(1,4) < 3)
										if (!DTSleep_IntimateCouchHighBackList.HasForm(baseBedForm))
											cowgirlOK = true
										else
											cowgirlRevOK = true
										endIf
									else
										doggyOk = true
										cowgirlOK = true
										cowgirlRevOK = true
										if (!DTSleep_IntimateCouchHighBackList.HasForm(baseBedForm))			; v2.90 changed from Federalist to HighBack to include more
											missionOK = true
										endIf
									endIf
								endIf
								
								if (SleepBedRef.HasKeyword(AnimFurnCouchKY) && cowgirlOK && cowgirlRevOK && doggyOK && missionOK)
									doggyOK = false					; to reduce numbers since also on limited couch  v3.15
								endIf

							elseIf (MySleepBedFurnType == FurnTypeIsSeatHigh)
								; modern domestic lounge, Federalist dining chair, Memory Lounge, Mama Murphy's chair
								; not enough room and backrest too high - restrict to doggy
								
								doggyOk = true
								
							elseIf (MySleepBedFurnType == FurnTypeIsSeatBench)
								doggyOk = true
								if (DTSleep_IntimateBenchAdjList.GetSize() > 0)
									if (baseBedForm == None)
										baseBedForm = SleepBedRef.GetBaseObject()
									endIf
									if (DTSleep_IntimateBenchAdjList.HasForm(baseBedForm))
										missionOK = true    ; benches with short backrest--not diner booth
									endIf
								endIf

							elseIf (MySleepBedFurnType == FurnTypeIsSeatKitchen || MySleepBedFurnType == FurnTypeIsSeatLow)
								; armless chair
								cowgirlOK = true
								doggyOk = true
							elseIf (MySleepBedFurnType == FurnTypeIsSeatLowArmRest)
								doggyOK = true		; armrest - v3.15
							endIf
						
							if (cowgirlOK)
								if (IsMaleErectAngleRestrictedForPack(1, packID))
									sidArray.Add(86)
									sidArray.Add(84)
								endIf
							endIf
							if (cowgirlRevOK)
								if (!SceneData.FemaleRaceHasTail)
									if (IsMaleErectAngleRestrictedForPack(2, packID))
										sidArray.Add(88)
									endIf
									if (IsMaleErectAngleRestrictedForPack(1, packID))
										sidArray.Add(85)
										sidArray.Add(87)
									endIf
								endIf
							endIf
							if (doggyOk && !SceneData.FemaleRaceHasTail)
								sidArray.Add(83)
							endIf
							if (missionOk)
								sidArray.Add(82)
							endIf
						endIf
					endIf
			
				elseIf (packID == 7)
				
					;if (SceneData.IsUsingCreature && SceneData.IsCreatureType == 2)
					;	if (!IsAAFEnabled())
					;		if (SleepBedRef.HasKeyword(AnimFurnCouchKY) || DTSleep_IntimateCouchList.HasForm(baseBedForm))
					;			sidArray.Add(78)
					;		elseIf (DTSleep_IntimateChairsList.HasForm(baseBedForm))
					;			sidArray.Add(77)
					;		endIf
					;		sidArray.Add(73) ; stand-only
					;	endIf
						
					if (MySleepBedFurnType == FurnTypeIsSeatIntimateChair)
					
						if (!SceneData.SameGender && SceneData.SecondFemaleRole == None)			; v2.40 pick oral or not
							if (SceneData.SecondMaleRole == None && playerPick && DoesMainActorPrefID(ScenePrefIsOral))
								sidArray.Add(38)
							else
								sidArray.Add(37)		; includes 2nd male
								sidArray.Add(55) 		; added v3.15 TODO
							endIf
							
						elseIf (SceneData.MaleRoleGender == 1 && (DTSConditionals as DTSleep_Conditionals).LeitoAnimVers < 2.1)
							; only if no other chair packs -v2.73
							sidArray.Add(39)				; player can pick this, but no other female-female scene
						endIf
					elseIf (MySleepBedFurnType == FurnTypeIsSeatStool)
						if (SceneData.SameGender == false && !SceneData.FemaleRaceHasTail)
							sidArray.Add(53)
						;else
						;	sidArray.Add(40)		-- v2.73 twerk-dance should not be here
						endIf
					elseIf (MySleepBedFurnType == FurnTypeIsSeatOttoman)
						if ((DTSConditionals as DTSleep_Conditionals).SavageCabbageVers >= 1.20)
							sidArray.Add(32)
						else
							sidArray.Add(51)		; standing doggy
						endIf
						
					elseIf (MySleepBedFurnType == FurnTypeIsSeatSofa)
						bool isFedSofa = false
						bool oralOnly = false
						bool analOnly = false
						
						if (playerPick)						; v2.40 pick oral or not
							if (DoesMainActorPrefID(ScenePrefIsOral))
								oralOnly = true
							elseIf (DoesMainActorPrefID(ScenePrefIsAnal))				; v3.0
								analOnly = true
							endIf
						endIf
						if (SceneData.SameGender)
							;sidArray.Add(40)				;v2.73 twerk-dance should not be here		
						elseIf (SceneData.SecondFemaleRole == None)
							if ((DTSConditionals as DTSleep_Conditionals).SavageCabbageVers >= 1.10 && SceneData.SecondMaleRole == None)
								if (baseBedForm == None)
									baseBedForm = SleepBedRef.GetBaseObject() as Form
								endIf
								if (DTSleep_IntimateCouchFedList.HasForm(baseBedForm))
									isFedSofa = true
									if (!oralOnly && !analOnly)
										sidArray.Add(34)
										sidArray.Add(85)		; fix - rev-cowgirl not anal v3.15
									endIf
								endIf
							endIf
							if (oralOnly || SceneData.SecondMaleRole != None)
								if (SceneData.SecondMaleRole != None || !isFedSofa)
									sidArray.Add(35)  ; includes 2nd male lover
								endIf
							endIf
							if (!isFedSofa && !SceneData.FemaleRaceHasTail && SceneData.SecondMaleRole == None)
								if (!oralOnly && !analOnly)
									sidArray.Add(36)
								endIf
								if (oralOnly && (DTSConditionals as DTSleep_Conditionals).SavageCabbageVers >= 1.20 && SleepBedRef.HasKeyword(AnimFurnCouchKY))
									; limit to couch KY  -- v3.15
									; reduce chance to prefer other oral v3.15
									if (sidArray.Length > 1 && Utility.RandomInt(0, 6) > 4)
										
										sidArray.Add(81)
									endIf
								endIf
							endIf
						endIf
					elseIf (MySleepBedFurnType == FurnTypeIsSeatLowArmRest && !SceneData.SameGender && !playerPick)
						sidArray.Add(55)			; v3.15 changed to chair with armrest
						
						
					elseIf (MySleepBedFurnType == FurnTypeIsSeatHigh && !SceneData.SameGender && !playerPick)
						bool okayToAdd = true		; check for armchair and other packs   v3.15
						if ((DTSConditionals as DTSleep_Conditionals).IsRZSexActive)
							if (baseBedForm == None)
								baseBedForm = SleepBedRef.GetBaseObject() as Form
							endIf
							if (DTSleep_IntimateChairHighNoArmsList.HasForm(baseBedForm))
								okayToAdd = false
							endIf
						endIf
						if (okayToAdd)
							sidArray.Add(54)			; male holds arm-rest so ignore Federalist chair unless no other packs
						endIf
					elseIf (bedIsSMBed || MySleepBedFurnType == FurnTypeIsSeatBench)
						if (playerPick && DoesMainActorPrefID(ScenePrefisAnal))
							sidArray.Add(59)
						endIf
					elseIf (MySleepBedFurnType == FurnTypeIsSeatKitchen && !SceneData.SameGender && !playerPick)
						sidArray.Add(58)
						;;sidArray.Add(55)  removed--no armrest to hold-- v3.15
					elseIf (MySleepBedFurnType == FurnTypeIsSeatThrone && !SceneData.SameGender)
						if (playerPick && DoesMainActorPrefID(ScenePrefIsOral))				; v2.70 added oral pick-only
							sidArray.Add(33)
						elseIf ((DTSConditionals as DTSleep_Conditionals).SavageCabbageVers >= 1.20)
							sidArray.Add(87)
						endIf
					endIf
				elseIf (packID == 10)			
					
					; TODO: chaise
					if (MySleepBedFurnType == FurnTypeIsSeatHigh)
						
						if (playerPick && DoesMainActorPrefID(ScenePrefIsOral))
							if (!SceneData.SameGender || SceneData.MaleRoleGender == 1)
								sidArray.Add(37)
							endIf
						
						elseIf (!playerPick)
							sidArray.Add(35)
							sidArray.Add(36)
						endIf
					elseIf (MySleepBedFurnType == FurnTypeIsSeatBench)

						if (!SceneData.SameGender && playerPick && DoesMainActorPrefID(ScenePrefIsOral))
							; not short bench v3.15
							if (baseBedForm == None)
								baseBedForm = SleepBedRef.GetBaseObject()
							endIf
							if (!DTSleep_IntimateBenchShortList.HasForm(baseBedForm))
								sidArray.Add(30)
							endIf
						endIf
					elseIf (MySleepBedFurnType == FurnTypeIsSeatSofa)
						if (SceneData.SameGender)

						elseIf (playerPick && DoesMainActorPrefID(ScenePrefIsOral))
							
							sidArray.Add(39)
						elseIf (!playerPick)
							sidArray.Add(40)
							;sidArray.Add(41)
							if (baseBedForm == None)
								baseBedForm = SleepBedRef.GetBaseObject()
							endIf
							if (!DTSleep_IntimateCouchLimSpaceList.HasForm(baseBedForm))
								sidArray.Add(42)
							endIf
							;sidArray.Add(43)
						endIf
					endIf
				elseIf (packID == 11)			; v3.15
				
					if (playerPick) 
						if (DoesMainActorPrefID(ScenePrefIsOral))
							if (SleepBedRef.HasKeyword(AnimFurnCouchKY))
								if (!SceneData.SameGender)
									if (mainActorIsMaleRole)
										
										if (Utility.RandomInt(0, 6) > 4)
											sidArray.Add(35)			; only using 2 stages due to angle changes
										else
											sidArray.Add(33)
										endIf
									else
										sidArray.Add(35)
										if (Utility.RandomInt(0, 6) > 4)
											sidArray.Add(33)
										endIf
									endIf
								endIf
							endIf
						elseIf (DoesMainActorPrefID(ScenePrefIsSpank))
							if (MySleepBedFurnType == FurnTypeIsSeatKitchen)
								sidArray.Add(30)
							elseIf (MySleepBedFurnType == FurnTypeIsSeatBench)
								; must be short bench
								if (baseBedForm == None)
									baseBedForm = SleepBedRef.GetBaseObject()
								endIf
								if (DTSleep_IntimateBenchShortList.HasForm(baseBedForm))
									sidArray.Add(30)
								endIf
							elseIf (MySleepBedFurnType == FurnTypeIsSeatHigh)
								; no arms
								if (baseBedForm == None)
									baseBedForm = SleepBedRef.GetBaseObject()
								endIf
								if (DTSleep_IntimateChairHighNoArmsList.HasForm(baseBedForm))
									sidArray.Add(30)
								endIf
							endIf
						elseIf (DoesMainActorPrefID(ScenePrefIsAnal))			;v3.20
							if (MySleepBedFurnType == FurnTypeIsSeatSofa)
								sidArray.Add(40)
							endIf
						endIf
					; end player-picked
					elseif (MySleepBedFurnType == FurnTypeIsSeatBench)
						
						if (DTSleep_IntimateBenchNoBackList.GetSize() > 0)
							if (baseBedForm == None)
								baseBedForm = SleepBedRef.GetBaseObject()
							endIf
							if (DTSleep_IntimateBenchNoBackList.HasForm(baseBedForm))
								sidArray.Add(34)
							else
								sidArray.Add(37)
							endIf
						endIf
						
						
					elseIf (MySleepBedFurnType == FurnTypeIsSeatSofa)
						
						if (!SceneData.SameGender)
							
							if (SleepBedRef.HasKeyword(AnimFurnCouchKY))
								sidArray.Add(31)
								
							else
								if (baseBedForm == None)
									baseBedForm = SleepBedRef.GetBaseObject()
								endIf
								if (DTSleep_IntimateCouchMemList.hasForm(baseBedForm))
									sidArray.Add(32)		; TODO: appear to fit memory lounge couch ??
								else
									sidArray.Add(37)
								endIf
							endIf
						endIf
					elseIf (MySleepBedFurnType == FurnTypeIsSeatIntimateChair)
						
						if (!SceneData.SameGender)
							sidArray.Add(37)  
						endIf
					elseIf (MySleepBedFurnType == FurnTypeIsSeatLow)
						; TODO: check this
						if (!SceneData.SameGender)
							sidArray.Add(36)	; hand on back corner
						endIf
					elseIf (MySleepBedFurnType == FurnTypeIsSeatLowArmRest)
						if (!SceneData.SameGender)
							sidArray.Add(36)	; hand on back corner
						endIf
					elseIf (MySleepBedFurnType == FurnTypeIsSeatKitchen)
						if (!SceneData.SameGender)
							sidArray.Add(36)	; hand on back corner
							sidArray.Add(37) 
						endIf
					elseIf (MySleepBedFurnType == FurnTypeIsSeatHigh)
						if (!SceneData.SameGender)
							; no arms
							if (baseBedForm == None)
								baseBedForm = SleepBedRef.GetBaseObject()
							endIf
							if (DTSleep_IntimateChairHighNoArmsList.HasForm(baseBedForm))
								sidArray.Add(37)	; clips a bit with armrest
							endIf
						endIf
					endIf
				endIf
			endIf
		elseIf (MySleepBedFurnType >= 250 && MySleepBedFurnType < 300 && !MainActorPositionByCaller)
			;
			; ***** tables ******
			;
			if (SceneData.IsUsingCreature && !SceneData.SameGender && SceneData.IsCreatureType == 1)
				
				if (MySleepBedFurnType == FurnTypeIsTablePatio)				; v2.88
					if (packID == 7)
						sidArray.Add(72)
						
					endIf
				endIf
				
			elseIf (!SceneData.IsUsingCreature && !SceneData.CompanionInPowerArmor)
			
				; oral-pick first
				if (playerPick && DoesMainActorPrefID(ScenePrefIsOral))								; v2.53 -- moved 2.51 fix so can have oral
					if (packID == 7)
						if (MySleepBedFurnType == FurnTypeIsTablePool)
							sidArray.Add(56)  ; Cunnilingus for pool table - includes FMM
						endIf
					elseIf (packID == 1 || packID == 6)
						if (!SceneData.SameGender || SceneData.MaleRoleGender == 0)
							if (MySleepBedFurnType == FurnTypeIsTablePicnic)
								sidArray.Add(50)
							elseIf ((!(DTSConditionals as DTSleep_Conditionals).IsSavageCabbageActive && MySleepBedFurnType == FurnTypeIsTablePool))
								sidArray.Add(50)
							endIf
						endIf
					elseIf (packID == 5 && (DTSConditionals as DTSleep_Conditionals).AtomicLustVers >= 2.70 )		; v2.87
						if (!SceneData.SameGender || SceneData.MaleRoleGender == 0)
							if (MySleepBedFurnType == FurnTypeIsTablePicnic)
								sidArray.Add(50)
							elseIf ((!(DTSConditionals as DTSleep_Conditionals).IsSavageCabbageActive && MySleepBedFurnType == FurnTypeIsTablePool))
								sidArray.Add(50)
							endIf
						endIf
					elseIf (packID == 10)
						if (MySleepBedFurnType == FurnTypeIsTablePicnic)
							if (!SceneData.SameGender)
								sidArray.Add(50)
								sidArray.Add(51)
							elseIf (!SceneData.SameGender || SceneData.MaleRoleGender == 1)
								sidArray.Add(47) ;; is right? TODO:
							endIf
						endIf
					elseIf (packID == 11)    						; v3.15
						if (MySleepBedFurnType == FurnTypeIsTablePicnic)
							if (!SceneData.SameGender)
								if (mainActorIsMaleRole)
									sidArray.Add(50)
								endIf
								sidArray.Add(48)
								sidArray.Add(49)
							endIf
						elseIf (MySleepBedFurnType == FurnTypeIsTableDesk)
							sidArray.Add(62)
						endIf
					endIf
					
				; ----- end oral/manual on tables --- start regular scenes on tables
				elseIf (packID == 11)								; v3.15
					if (!SceneData.SameGender)
						if (MySleepBedFurnType == FurnTypeIsTablePicnic)
							;sidArray.Add(4)
							sidArray.Add(6)
						elseIf (MySleepBedFurnType == FurnTypeIsTablePool)
							sidArray.Add(3)
						endIf
					endIf
					
					if (MySleepBedFurnType == FurnTypeIsTableDesk)
						; v3.21
						if ((DTSConditionals as DTSleep_Conditionals).RZSexVers >= 2.60)
							if (playerPick && DoesMainActorPrefID(ScenePrefIsSpank))
								sidArray.Add(41)
							endIf
						endIf
					endIf
				
				elseIf (packID == 10)		
					if (MySleepBedFurnType == FurnTypeIsTablePicnic)
						; big enough so let's add more
						if (SceneData.SameGender)
							if (SceneData.MaleRoleGender == 0)
								sidArray.Add(12)
								sidArray.Add(13)
							else
								sidArray.Add(90)
							endIf
						else
							sidArray.Add(4)
							sidArray.Add(5)
						endIf
					endIf
					
				elseIf (packID == 7)
					if (!SceneData.SameGender)
						if (MySleepBedFurnType == FurnTypeIsTablePool)
							; big so allow other animations, too
							if (SceneData.SecondMaleRole != None)			; v2.53 restrict -- oral choice above
								sidArray.Add(56)  ; for pool table - includes FMM
							else
								sidArray.Add(57)  ; for pool table
							endIf
						elseIf (MySleepBedFurnType == FurnTypeIsTablePicnic)
							sidArray.Add(43)
						elseIf (MySleepBedFurnType == FurnTypeIsTableDinerBooth)		;v2.35
							sidArray.Add(43)
							;if ((DTSConditionals as DTSleep_Conditionals).SavageCabbageVers >= 1.20)
							;	sidArray.Add(80)		
							;endIf
							sidArray.Add(44)
						elseIf (MySleepBedFurnType == FurnTypeIsTableDining)
							sidArray.Add(43)
						elseIf (MySleepBedFurnType == FurnTypeIsTableRound)
							sidArray.Add(44)
							sidArray.Add(45)
						elseIf (MySleepBedFurnType == FurnTypeIsTableDesk)
							if (!playerPick)			; no-pick only v3.21
								sidArray.Add(52)  ; desk/desk-table
							endIf
						endIf
					endIf
				elseIf (packID == 6 || packID == 1)
					if (MySleepBedFurnType == FurnTypeIsTablePool || MySleepBedFurnType == FurnTypeIsTablePicnic)
						
						if (!playerPick)		; v2.71  - player may only pick oral at table
							sidArray.Add(5)
							if (!SceneData.FemaleRaceHasTail)
								sidArray.Add(53)
								if (mainActorIsMaleRole)
									sidArray.Add(3)					; v2.51 - replaced 9 since works poorly for FF
								endIf
							endIf
							if (!SceneData.SameGender)
								sidArray.Add(9)
							endIf
						endIf
					endIf
				endIf
			endIf
			
			
			if (packID == 5)
				if (MySleepBedFurnType == FurnTypeIsTablePool || MySleepBedFurnType == FurnTypeIsTablePicnic)
					; v2.51 - fix for playerPick oral
					if (SceneData.SameGender && !SceneData.IsUsingCreature && !SceneData.CompanionInPowerArmor)
						if ((DTSConditionals as DTSleep_Conditionals).IsAtomicLustActive && !playerPick)
							sidArray.Add(4)
						endIf
						if ((DTSConditionals as DTSleep_Conditionals).IsRufgtActive)
							if (playerPick && DoesMainActorPrefID(ScenePrefIsOral))
								if (SceneData.MaleRoleGender == 1)
									sidArray.Add(90)
									sidArray.Add(92)
								endIf
							elseIf (SceneData.MaleRoleGender == 1)
								sidArray.Add(91)
							endIf
						endIf
					elseIf ((DTSConditionals as DTSleep_Conditionals).IsAtomicLustActive && !playerPick)
						if (SceneData.CompanionInPowerArmor) ; || SceneData.IsUsingCreature)
							; self-play
							sidArray.Add(40)
							sidArray.Add(41)
						else
							sidArray.Add(7)
							sidArray.Add(10)
						endIf
					endIf
				endIf
			endIf
		
		; ---------------------
		; other props
		;
		elseIf (MySleepBedFurnType == FurnTypeIsMotorCycle)
			if (!SceneData.IsUsingCreature && !SceneData.CompanionInPowerArmor && !SceneData.SameGender)
				if (packID == 7 && (DTSConditionals as DTSleep_Conditionals).SavageCabbageVers >= 1.10)
					sidArray.Add(46)
				endIf
			endIf
		elseIf (MySleepBedFurnType == FurnTypeIsShower)
			if (!SceneData.IsUsingCreature && !SceneData.CompanionInPowerArmor && !SceneData.SameGender)
				if (packID == 7 && (DTSConditionals as DTSleep_Conditionals).SavageCabbageVers >= 1.10)
					sidArray.Add(47)
				endIf
			endIf
		elseIf (MySleepBedFurnType == FurnTypeIsTableKitchenCounter)
			if (packID == 7)
				if (SceneData.SecondMaleRole != None && (DTSConditionals as DTSleep_Conditionals).SavageCabbageVers >= 1.230)
					sidArray.Add(86)
				elseIf ((DTSConditionals as DTSleep_Conditionals).SavageCabbageVers >= 1.20)
					sidArray.Add(86)
				endIf
			endIf
			if (packID == 11)
				sidArray.Add(85)
			endIf
		elseIf (MySleepBedFurnType == FurnTypeIsTableKitchenCabinet)
			; v3.15
			if (packID == 11)
				sidArray.Add(85)
			endIf
			if (packID == 7)
				if (SceneData.SecondMaleRole != None && (DTSConditionals as DTSleep_Conditionals).SavageCabbageVers >= 1.230)
					sidArray.Add(86)
				elseIf ((DTSConditionals as DTSleep_Conditionals).SavageCabbageVers >= 1.20)
					sidArray.Add(86)
				endIf
			endIf
		elseIf (MySleepBedFurnType == FurnTypeIsJail)
			if ((DTSConditionals as DTSleep_Conditionals).SavageCabbageVers >= 1.20)
				if (playerPick && DoesMainActorPrefID(ScenePrefIsOral))
					sidArray.Add(95)
				else
					sidArray.Add(96)
				endIf
			endIf
		elseIf (MySleepBedFurnType == FurnTypeIsLocker)										; v2.77
			if (packID == 7 && (DTSConditionals as DTSleep_Conditionals).SavageCabbageVers >= 1.27)
				sidArray.Add(88)
			elseIf (packID == 10) 		
				sidArray.Add(70)
			endIf
		elseIf (MySleepBedFurnType == FurnTypeIsSedanPostWar || MySleepBedFurnType == FurnTypeIsSedanPreWar)
			if (!SceneData.IsUsingCreature && !SceneData.CompanionInPowerArmor && !SceneData.SameGender)
				if (packID == 7 && (DTSConditionals as DTSleep_Conditionals).SavageCabbageVers >= 1.1)
					if (MySleepBedFurnType == FurnTypeIsSedanPostWar)
						sidArray.Add(90)
					endIf
					; pre-war works for both
					if (playerPick && DoesMainActorPrefID(ScenePrefIsOral))				; v3.0 fix main-actor
						sidArray.Add(91)				; blowjob + cowgirl
					else
						sidArray.Add(92)
					endIf
				endIf
			endIf
		; ------------------	
		; Codsworth scenes
		;
		elseIf (SceneData.IsUsingCreature && SceneData.IsCreatureType == 6 && !SceneData.SameGender)
		
			if (packID == 7 && (DTSConditionals as DTSleep_Conditionals).SavageCabbageVers >= 1.20)
				sidArray.Add(71)
			endIf
		;-------------------------
		; super mutant behemoth scenes
		elseIf (SceneData.IsUsingCreature && SceneData.IsCreatureType == 5 && !SceneData.SameGender)
			
			if (packID == 7 && (DTSConditionals as DTSleep_Conditionals).SavageCabbageVers >= 1.20)
				
				bool playerpickFound = false
				if (playerPick && DoesMainActorPrefID(ScenePrefIsOral))
					sidArray.Add(74)
					playerpickFound = true
				endIf
				if (!playerpickFound && Utility.RandomInt(0, 6) > 4)
					sidArray.Add(75)
				elseIf (!playerPick)
					sidArray.Add(74)
				endIf
				if (!playerpickFound)
					sidArray.Add(76)
				endIf
			endIf
		;---------------------------	
		; Strong scenes
		;
		elseIf (SceneData.IsUsingCreature && SceneData.MaleRole == CompStrongRef && !SceneData.SameGender)
		
			if (SceneData.SecondMaleRole != None)
				if (packID == 7)
					if (!SceneData.FemaleRaceHasTail)
						sidArray.Add(61)
					endIf
					if (MySleepBedFurnType == FurnTypeIsSMBed && !MainActorPositionByCaller)
						sidArray.Add(68)
					endIf
				endIf
			elseIf (MySleepBedFurnType == FurnTypeIsSMBed && !MainActorPositionByCaller)
				if (packID == 7)
					sidArray.Add(67)
					if (!SceneData.FemaleRaceHasTail)
						sidArray.Add(68)
					endIf
				endIf
			elseIf (MySleepBedFurnType == FurnTypeIsSeatSofa && !MainActorPositionByCaller)				; v2.70 - added Strong sofa; v2.73 restrict by not pick-spot
				if (packID == 7 && (DTSConditionals as DTSleep_Conditionals).SavageCabbageVers >= 1.26)
					sidArray.Add(73)
				elseIf (packID == 6 && (DTSConditionals as DTSleep_Conditionals).LeitoAnimVers >= 2.1)		;v2.73
					sidArray.Add(96)
					sidArray.Add(97)
				endIf
			elseIf (MySleepBedFurnType == FurnTypeIsSeatBench && !MainActorPositionByCaller)				;v2.73
				if (packID == 6 && (DTSConditionals as DTSleep_Conditionals).LeitoAnimVers >= 2.1)
					if (!playerPick)
						sidArray.Add(96)
						sidArray.Add(97)
					endIf
				endIf
			elseIf (MySleepBedFurnType == FurnTypeIsStove && !MainActorPositionByCaller)					; v2.84
				if (packID == 7)
					sidArray.Add(79)
				endIf
			elseIf (packID == 9)
				okayAdd = true
				if (playerPick && !DoesMainActorPrefID(ScenePrefIsDoggy))
					okayAdd = false
				endIf
				if (okayAdd)
					if (MainActorPositionByCaller || bedIsFloorBed)
						sidArray.Add(63)
						if (!SceneData.FemaleRaceHasTail && Utility.RandomInt(2, 6) > 4)
							sidArray.Add(62)
						endIf
					endIf
				endIf
			elseIf (packID == 1 || packID == 6 || packID == 7)
				
				if (playerPick)
					
					if (DoesMainActorPrefID(ScenePrefIsOral))							; oral
						if (packID == 7)
							if (MySleepBedFurnType == FurnTypeIsDoubleBed && !MainActorPositionByCaller)
								sidArray.Add(64)
							else
								sidArray.Add(62)
							endIf
						;elseIf (packID == 6 && (DTSConditionals as DTSleep_Conditionals).LeitoAnimVers >= 2.10) ;---missing animations
						;	sidArray.Add(95)
						endIf
					elseIf (DoesMainActorPrefID(ScenePrefIsDoggy))									; doggy-style
						if (packID == 1 || packID == 6)
							if (MainActorPositionByCaller || bedIsFloorBed)
								if (!SceneData.FemaleRaceHasTail)
									sidArray.Add(61)
								endIf
								sidArray.Add(62)
							endIf
						elseIf (packID == 7)
							if (MySleepBedFurnType == FurnTypeIsDoubleBed && !MainActorPositionByCaller)
								sidArray.Add(65)
							else
								sidArray.Add(68)
							endIf
						endIf
					elseIf (DoesMainActorPrefID(ScenePrefIsCowgirl) && packID == 7 && MySleepBedFurnType == FurnTypeIsDoubleBed && !MainActorPositionByCaller)
						; cowgirl 
						sidArray.Add(66)
					elseIf (MainActorPositionByCaller || bedIsFloorBed)
						; V3.10 - added picked stand
						sidArray.Add(60)
						if (!SceneData.FemaleRaceHasTail)
							sidArray.Add(61)
							sidArray.Add(63)
						endIf
						if (packID != 7)						; skip SC hand-job v2.73
							sidArray.Add(62)
						endIf
						if (packID == 7 && (DTSConditionals as DTSleep_Conditionals).SavageCabbageVers >= 1.20)
							sidArray.Add(69)
						endIf
					endIf
				
				elseIf (MySleepBedFurnType != FurnTypeIsDoubleBed || MainActorPositionByCaller)
					sidArray.Add(60)
					if (!SceneData.FemaleRaceHasTail)
						sidArray.Add(61)
						sidArray.Add(63)
					endIf
					if (packID != 7)						; skip SC hand-job v2.73
						sidArray.Add(62)
					endIf
					if (packID == 7 && (DTSConditionals as DTSleep_Conditionals).SavageCabbageVers >= 1.20)
						sidArray.Add(69)
					endIf
				endIf
				if (!playerPick && packID == 7 && MySleepBedFurnType == FurnTypeIsDoubleBed && !MainActorPositionByCaller)
					
					; v3.10 - don't believe this belongs here
					;if (bedDoubleIsInstitute)					; v2.70
					;sidArray.Add(09)
					;else
						if (!SceneData.FemaleRaceHasTail)
							sidArray.Add(65)
						endIf
						sidArray.Add(66)
					;endIf
				endIf
			elseIf (packID == 5)
				if (playerPick && DoesMainActorPrefID(ScenePrefIsOral))
					if (!(DTSConditionals as DTSleep_Conditionals).IsSavageCabbageActive || Utility.RandomInt(1, 7) > 5)
						; reduce frequency - v2.73
						sidArray.Add(62)
					endIf
					sidArray.Add(63) ; requires specific mesh, but close enough
					if ((DTSConditionals as DTSleep_Conditionals).MutatedLustVers >= 1.4)
						sidArray.Add(65)
					endIf
				elseIf (!playerPick)
					; check MutantLust version-  v2.88

					if ((DTSConditionals as DTSleep_Conditionals).MutatedLustVers >= 1.4)
						
						sidArray.Add(64)
					elseIf (!(DTSConditionals as DTSleep_Conditionals).IsSavageCabbageActive && !(DTSConditionals as DTSleep_Conditionals).IsLeitoActive && !(DTSConditionals as DTSleep_Conditionals).IsLeitoAAFActive && !(DTSConditionals as DTSleep_Conditionals).IsGrayCreatureActive)
					
						; nothing else, must add
						sidArray.Add(62)
						sidArray.Add(63) ; requires specific mesh, but close enough
					endIf
				endIf
			endIf			; end strong, robot, monster ....
		
		; --------------------------------------------------------------------------
		; bed or stand scenes
		; ------------
		
		; Atomic Lust and RufGT - bed or stand
		elseIf (packID == 5 && !pillowBedHasFrame)
			
			; old Rufgt
			if (MySleepBedFurnType != FurnTypeIsCoffin && !bedIsSMBed && (DTSConditionals as DTSleep_Conditionals).IsRufgtActive && !SceneData.IsUsingCreature && !SceneData.CompanionInPowerArmor)
				if (SceneData.SecondMaleRole == None && SceneData.SecondFemaleRole == None)
					if (SceneData.SameGender && SceneData.MaleRoleGender == 1)
						; female-female
						okayAdd = true
						if (SceneData.HasToyAvailable && !playerPick && Utility.RandomInt(1,7) > 4)					
							; v2.74 - change to HasToyAvailable and added random
							; give preference for toy scenes
							if ((DTSConditionals as DTSleep_Conditionals).IsGrayAnimsActive)
								okayAdd = false
							elseIf ((DTSConditionals as DTSleep_Conditionals).IsLeitoAAFActive || (DTSConditionals as DTSleep_Conditionals).IsLeitoActive)
								okayAdd = false
							endIf
						endIf
						if (okayAdd)
							if (!playerPick || DoesMainActorPrefID(ScenePrefIsScissors))
								sidArray.Add(91)
							endIf
							if (playerPick && (DoesMainActorPrefID(ScenePrefIsOral) || DoesMainActorPrefID(ScenePrefIsCunn)))
								; v3.0 only one
								sidArray.Add(92)
							endIf
							if (playerPick && DoesMainActorPrefID(ScenePrefIsSixtyNine))
								; v3.0 69
								sidArray.Add(90)
							endIf
						endIf
					elseIf (!SceneData.SameGender)
						if (!playerPick || DoesMainActorPrefID(ScenePrefIsSpoon))
							sidArray.Add(99)			; spoon
						endIf
					endIf
				endIf
			endIf
			
			; regular Atomic Lust
			if ((DTSConditionals as DTSleep_Conditionals).IsAtomicLustActive)
			
				if (SceneData.CompanionInPowerArmor) ; || SceneData.IsUsingCreature)   v2.73 ignore creature
					; self-play
					sidArray.Add(40)
					sidArray.Add(41)
				elseIf (cuddlesOnly)
					if (!standOnly && MySleepBedFurnType != FurnTypeIsCoffin && !bedIsSMBed)
						sidArray.Add(1)
					endIf
				elseIf (playerPick && DoesMainActorPrefID(ScenePrefIsSpank))		; added v3.15
					sidArray.Add(47)
				elseIf (bedIsCoffin)
					if ((DoesSecondActorPrefID(ScenePrefIsSpank) || DoesMainActorPrefID(ScenePrefIsSpank)) && !SceneData.SameGender)
						sidArray.Add(47)		
					endIf
				else
					; check 2nd actor first
					if (SceneData.SecondMaleRole != None)
						sidArray.Add(51)
					elseIf (SceneData.SecondFemaleRole != None)
						sidArray.Add(52)
						
					else
						; stand or bed
						if ((DoesSecondActorPrefID(ScenePrefIsSpank) || DoesMainActorPrefID(ScenePrefIsSpank)) && !SceneData.SameGender)
							sidArray.Add(47)		
						endIf
						if (playerPick && !bedIsSMBed)
							if (DoesMainActorPrefID(ScenePrefIsCuddle) || DoesMainActorPrefID(ScenePrefIsMission))
								if (!standOnly)
									sidArray.Add(1)
								endIf
							endIf
							if (SceneData.SameGender) 
								if (SceneData.MaleRoleGender == 1 && DoesMainActorPrefID(ScenePrefIsScissors))
									sidArray.Add(4)
								elseIf (SceneData.MaleRoleGender == 0 && (DTSConditionals as DTSleep_Conditionals).AtomicLustVers >= 2.50)
									if (DoesMainActorPrefID(ScenePrefIsCowboy))
										sidArray.Add(4)
									elseIf (DoesMainActorPrefID(ScenePrefIsSixtyNine))
										sidArray.Add(3)
									endIf
								endIf
							endIf

							if ((DTSConditionals as DTSleep_Conditionals).AtomicLustVers >= 2.61 && DoesMainActorPrefID(ScenePrefIsSpoon) && !SceneData.SameGender)
								if (MySleepBedFurnType == FurnTypeIsDoubleBed || bedIsFloorBed || standOnly)
									sidArray.Add(10)
								endIf
							endIf
							if ((DTSConditionals as DTSleep_Conditionals).AtomicLustVers >= 2.70 && DoesMainActorPrefID(ScenePrefIsOral) && (!SceneData.SameGender || SceneData.MaleRoleGender == 0))
								sidArray.Add(50)			; v2.87
							endIf
							if ((DTSConditionals as DTSleep_Conditionals).AtomicLustVers >= 2.42 && !SceneData.SameGender)
								if (DoesMainActorPrefID(ScenePrefIsCowgirl) && MySleepBedFurnType == FurnTypeIsDoubleBed && !standOnly)
									sidArray.Add(5)
								elseIf ((DTSConditionals as DTSleep_Conditionals).AtomicLustVers >= 2.50 && DoesMainActorPrefID(ScenePrefIsCowgirl))
									if (!bedIsFloorBed && !standOnly)
										sidArray.Add(8)
									endIf
									sidArray.Add(7)
								endIf
							endIf
						elseIf (!bedIsSMBed)
							; no pick
							
							if (SceneData.SameGender && SceneData.MaleRoleGender == 1 && !DoesSecondActorHateID(ScenePrefIsScissors))
								sidArray.Add(4)		; scissors replace cowgirl-1 - companion restricted
							endIf
							;if (!SceneData.SameGender)
							;	sidArray.Add(46)
							;endIf

							if ((DTSConditionals as DTSleep_Conditionals).AtomicLustVers >= 2.42)

								if (RestrictScenesToErectAngle == 1 || RestrictScenesToErectAngle < 0 || DTSleep_SettingUseBT2Gun.GetValueInt() == 1)
									if (!SceneData.SameGender)
										if (MySleepBedFurnType == FurnTypeIsDoubleBed && !standOnly)
											sidArray.Add(5); cowgirl double-bed
										elseIf (!bedIsFloorBed && !standOnly)
											sidArray.Add(6); cowgirl vault
										endIf
										if ((DTSConditionals as DTSleep_Conditionals).AtomicLustVers >= 2.50)
											sidArray.Add(7)			; ground cowgirl
											sidArray.Add(8)
											if (!bedIsFloorBed && !standOnly)
												sidArray.Add(8)	; on-bed reversed cowgirl - 2 stage no ping-pong
											endIf
										endIf
										if ((DTSConditionals as DTSleep_Conditionals).AtomicLustVers >= 2.61)
											if (standOnly || MySleepBedFurnType == FurnTypeIsDoubleBed || bedIsFloorBed)
												sidArray.Add(10)
											endIf
										endIf
										
									elseIf (SceneData.SameGender && SceneData.MaleRoleGender == 0)
										sidArray.Add(4) ; cowboy
										sidArray.Add(3) ; atomic rocket
									endIf
								endIf
							endIf
						endIf
					endIf
				endIf
			endIf	; end isAtomicLust
			
		; RZSex  v3.15
		elseIf (packID == 11 && !SceneData.IsUsingCreature)
			
			if (SceneData.CompanionInPowerArmor) 
			
				; player gender should match role
				sidArray.Add(21)
				
			elseIf (SceneData.SecondFemaleRole != None)
			
				; nothing
				
			elseIf (SceneData.SecondMaleRole != None)
			
				; nothing currently
				
			elseIf (SceneData.SameGender && SceneData.MaleRoleGender == 0)
					
				sidArray.Add(21)
				
			elseIf (SceneData.SameGender && SceneData.MaleRoleGender == 1 && !SceneData.HasToyAvailable)
				; FF without toy
				if (!playerPick)
					sidArray.Add(52)
				endIf
				
			elseIf (MySleepBedFurnType == FurnTypeIsCoffin || MainActorPositionByCaller)
			
				if (playerPick && DoesMainActorPrefID(ScenePrefIsOral))
					if (!SceneData.SameGender)
						sidArray.Add(50)
					endIf
				else
					sidArray.Add(55)
				endIf
				
			elseIf (pillowBedHasFrame)

				; assume not okay due to height adjusted animations
				
			elseIf (MySleepBedFurnType == FurnTypeIsBunkBed)
			
				; nothing fits
				
			elseIf (!SceneData.SameGender || SceneData.HasToyAvailable)
				;
				; not coffin, no powerarmor, not MM, FF only if hasToy
				;
				if (!playerPick || DoesMainActorPrefID(ScenePrefIsMission))
					if (MySleepBedFurnType == FurnTypeIsSleepingBag || MySleepBedFurnType == FurnTypeIsFloorBed || MySleepBedFurnType == FurnTypeIsDoubleBed)
						; too long for standard bed
						sidArray.Add(1)
					endIf
					if (playerPick && !SceneData.SameGender)
						if (MySleepBedFurnType == FurnTypeIsSleepingBag || MySleepBedFurnType == FurnTypeIsFloorBed)
							sidArray.Add(0)
						endIf
					endIf
				endIf
				if (!playerPick || DoesMainActorPrefID(ScenePrefIsDoggy))
				
					sidArray.Add(3)
					if (bedIsFloorBed)
						if (playerPick && !SceneData.SameGender)
							sidArray.Add(2)
						endIf
					endIf
					
				endIf
				if (!playerPick || DoesMainActorPrefID(ScenePrefIsCowgirl))
					if (MySleepBedFurnType != FurnTypeIsLimitedSpaceBed)
						;sidArray.Add(4)
						sidArray.Add(6)
					endIf
				endIf
				
				if (playerPick && DoesMainActorPrefID(ScenePrefSoloPair))
					if (!SceneData.SameGender)
						sidArray.Add(21)	; female standing, male sitting -- okay on some beds
					endIf
					if (bedIsFloorBed)
						; actor rotations must use player-clone, so avoid pick-spot and use floor beds
						sidArray.Add(53)	; both standing
						sidArray.Add(54)	; both standing
					endIf
					
				elseIf (playerPick && DoesMainActorPrefID(ScenePrefIsOral) && !SceneData.SameGender)
					bool addedScene = false
					if (bedIsFloorBed || MySleepBedFurnType == FurnTypeIsTablePicnic)
						
						sidArray.Add(49)	; face-sit
						addedScene = true
						if (MySleepBedFurnType != FurnTypeIsTablePicnic)
							sidArray.Add(52)  	; manual
						endIf
					elseIf (!mainActorIsMaleRole && MySleepBedFurnType == FurnTypeIsDoubleBed)
						sidArray.Add(49)	; face-sit
						addedScene = true
						
					elseIf (MySleepBedFurnType == FurnTypeIsBedSingle)
						
					endIf
					if (!mainActorIsMaleRole)
						sidArray.Add(48)	; face-sit reverse
						addedScene = true
					endIf
					
					if (!addedScene)
						sidArray.Add(50)
					endIf
				elseIf (MainActorPositionByCaller)
					
					sidArray.Add(55)
					
				elseIf (!playerPick)
					
					sidArray.Add(16)
				endIf
			endIf
			
		; BP70
		elseIf (packID == 10)
			
			if (!SceneData.IsUsingCreature && SceneData.SecondMaleRole  == None)			; v3.16 no second male
			
				if (cuddlesOnly)
					if (MySleepBedFurnType == FurnTypeIsDoubleBed)
						sidArray.Add(19)
					endIf
				elseIf (SceneData.CompanionInPowerArmor)
					; self-play on bed
					if (MySleepBedFurnType == FurnTypeIsDoubleBed || MySleepBedFurnType == FurnTypeIsBedSingle)
						sidArray.Add(60)	
					endIf
						
				elseIf (SceneData.SameGender && SceneData.SecondFemaleRole == None)
					if (SceneData.MaleRoleGender == 0)
						sidArray.Add(85)

					elseIf (playerPick && DoesMainActorPrefID(ScenePrefIsScissors))
						sidArray.Add(13)
					elseIf (playerPick && (DoesMainActorPrefID(ScenePrefIsOral) || DoesMainActorPrefID(ScenePrefIsCunn)))
						sidArray.Add(47)
					elseIf (playerPick && DoesMainActorPrefID(ScenePrefIsSpank))
						sidArray.Add(20)
					elseIf (!playerPick)
						sidArray.Add(12)
						sidArray.Add(13)
						sidArray.Add(14)
					endIf
				elseIf (SceneData.SecondFemaleRole == None)
					; F-M scenes bed-specific first
					if (MySleepBedFurnType == FurnTypeIsDoubleBed && !MainActorPositionByCaller)
						if (playerPick && DoesMainActorPrefID(ScenePrefIsCuddle))
							sidArray.Add(19)
						endIf
						if (playerPick && DoesMainActorPrefID(ScenePrefIsOral))
							sidArray.Add(21)
						endIf
						
					elseIf (MySleepBedFurnType == FurnTypeIsBedSingle && !MainActorPositionByCaller)
						if (playerPick && DoesMainActorPrefID(ScenePrefIsSpank))
							sidArray.Add(20)
						endIf
					endIf
					
					; F-M scenes on floor  or bed
					if ((MySleepBedFurnType != FurnTypeIsBunkBed && !bedIsCoffin) || MainActorPositionByCaller)
						if (MySleepBedFurnType == FurnTypeIsDoubleBed || bedIsFloorBed)
							; not single bed  v3.16
							if (!playerPick || DoesMainActorPrefID(ScenePrefIsMission))
								;sidArray.Add(0)
								sidArray.Add(1)
							endIf
						endIf
						if (!SceneData.FemaleRaceHasTail)
							if (!playerPick || DoesMainActorPrefID(ScenePrefIsDoggy))
								
								if (MainActorPositionByCaller || MySleepBedFurnType == FurnTypeIsDoubleBed || bedIsFloorBed)
									sidArray.Add(3)
								endIf 
							endIf
						endIf
						if (!playerPick)		
							; v3.16 fix: not doggy
							sidArray.Add(2)
						endIf
						if (!playerPick || DoesMainActorPrefID(ScenePrefIsCowgirl))
							
							sidArray.Add(5)
							sidArray.Add(6)
						endIf
						if (!playerPick || DoesMainActorPrefID(ScenePrefIsSpoon))
							sidArray.Add(10)
						endIf
						if (playerPick)
							if (DoesMainActorPrefID(ScenePrefIsOral) || DoesMainActorPrefID(ScenePrefIsCunn))
								if (bedIsFloorBed || MainActorPositionByCaller)
									sidArray.Add(47)
								endIf
								if (bedIsFloorBed || MySleepBedFurnType == FurnTypeIsDoubleBed)
									sidArray.Add(48)
								endIf
								
								if (MainActorRef == SceneData.FemaleRole || DoesMainActorPrefID(ScenePrefIsCunn))
									sidArray.Add(8)
								else
									sidArray.Add(49)
								endIf
							endIf
						endIf
					endIf
					
					; standing scenes
					if (bedIsFloorBed || MainActorPositionByCaller)
						if (playerPick && DoesMainActorPrefID(ScenePrefIsOral) && bedIsFloorBed)
							sidArray.Add(50)
							sidArray.Add(51)
						elseIf (!playerPick || DoesMainActorPrefID(ScenePrefIsCarry) || DoesMainActorPrefID(ScenePrefIsStand))
							; added pref stand v3.01
							sidArray.Add(54)
						endIf 
					endIf
				endIf
			endIf

		
		; 50 Shades by Gray
		elseIf (packID == 9 && !pillowBedHasFrame && MySleepBedFurnType != FurnTypeIsBunkBed && !bedIsCoffin)
			if (SceneData.SecondFemaleRole == None && SceneData.SecondMaleRole == None)
				if (!SceneData.CompanionInPowerArmor && !SceneData.IsUsingCreature)

					if (DoesSecondActorPrefID(ScenePrefIsSpank) && (!playerPick || DoesMainActorPrefID(ScenePrefIsSpank)))
						sidArray.Add(47)		; spanking limited to companions
					endIf
					
					if (SceneData.SameGender)
						if (SceneData.MaleRoleGender == 1 && SceneData.HasToyAvailable == false)
							restricted = true
						elseIf (SceneData.MaleRoleGender == 0)
							restricted = true
						endIf
					endIf
					
					if (!restricted)
						okayAdd = true
						if (playerPick && !DoesMainActorPrefID(ScenePrefIsMission))
							okayAdd = false
						endIf
						if (okayAdd)
							sidArray.Add(1)
						endIf
						okayAdd = true
						if (playerPick && !DoesMainActorPrefID(ScenePrefIsDoggy))
							okayAdd = false
						endIf
						if (okayAdd && !SceneData.FemaleRaceHasTail)
							sidArray.Add(3)
						endIf
					endIf
				endIf
			endIf
			
		; SavageCabbages
		elseIf (packID == 7 && !pillowBedHasFrame)			
			
			if (SceneData.CompanionInPowerArmor || SceneData.IsCreatureType == 3)		; v2.17 added synth type
				if (MySleepBedFurnType == FurnTypeIsDoubleBed)							
					sidArray.Add(99)
					; v2.70.2 removed 97 since now used for railing
				elseIf (!SceneData.SameGender && SceneData.MaleRoleGender == 0)
					sidArray.Add(98)
				elseIf (SceneData.SameGender && SceneData.MaleRoleGender == 1)
					sidArray.Add(98)
				endIf
			elseIf (!cuddlesOnly && !SceneData.IsUsingCreature)
				okayAdd = true
				
				; FMM scenes
				if (SceneData.SecondMaleRole != None && MySleepBedFurnType == FurnTypeIsBunkBed && !standOnly && !MainActorPositionByCaller)
					if ((DTSConditionals as DTSleep_Conditionals).SavageCabbageVers >= 1.10)
						sidArray.Add(15)		; on edge, flip side to face player to avoid wall
					endIf
					
				elseIf (SceneData.SecondMaleRole != None && !bedIsCoffin)

					if (!standOnly && !MainActorPositionByCaller && MySleepBedFurnType != FurnTypeIsBunkBed)
						sidArray.Add(4)		; single bed
					endIf
					
					if (standOnly || MainActorPositionByCaller)
						sidArray.Add(5)		; floor scene
						sidArray.Add(58)
						sidArray.Add(13)		; pick-spot only
						sidArray.Add(14)
						
					elseIf (MySleepBedFurnType == FurnTypeIsDoubleBed)
						if ((DTSConditionals as DTSleep_Conditionals).SavageCabbageVers >= 1.10)
							sidArray.Add(7)				; includes oral, but no selection for extra partners
							sidArray.Add(6)
						endIf
						if ((DTSConditionals as DTSleep_Conditionals).SavageCabbageVers >= 1.26)
							sidArray.Add(1)
						endIf 
					elseIf (bedIsFloorBed)
						sidArray.Add(14)
						sidArray.Add(5)
					endIf
					
				; FMF scene
				elseIf (SceneData.SecondFemaleRole != None)
					if (standOnly || MainActorPositionByCaller || (DTSConditionals as DTSleep_Conditionals).SavageCabbageVers < 1.1)
						sidArray.Add(58)
					endIf
					; v2.21 - restrict positioned by caller to avoid standing in air
					if (MySleepBedFurnType == FurnTypeIsDoubleBed && !MainActorPositionByCaller && (DTSConditionals as DTSleep_Conditionals).SavageCabbageVers >= 1.10)
						sidArray.Add(2)
						if ((DTSConditionals as DTSleep_Conditionals).SavageCabbageVers >= 1.26)			; v2.70 added new FMF
							sidArray.Add(0)
						endIf
					endIf
					
				; FM scenes --------------------
				elseIf (!SceneData.SameGender && SceneData.SecondFemaleRole == None && SceneData.SecondMaleRole == None)
					; no same-gender scenes here
				
					int numToAdd = 1
					if (!mainActorIsMaleRole && !bedIsSMBed && !bedIsCoffin && MySleepBedFurnType != FurnTypeIsBunkBed)
						; add multiple to improve chance pick
						numToAdd = (DT_RandomQuestP as DT_RandomQuestScript).GetNextSizedPackIntPublic() - 2
						if (numToAdd < 0)
							numToAdd = 1
						elseIf (numToAdd < 3)
							numToAdd = 2
						elseIf (numToAdd > 3)
							numToAdd = 3
						endIf
					endIf
					
					; ----------------------- standing or floorbed
					okayAdd = true
					int addedFloorBedCount = 0						; v2.79 - so not to add other beds if not needed
					
					if (playerPick && !DoesMainActorPrefID(ScenePrefIsDoggy))
						okayAdd = false
					elseIf (SceneData.FemaleRaceHasTail)
						okayAdd = false
					endIf
					if (MySleepBedFurnType == FurnTypeIsSMBed)
						if (standOnly || MainActorPositionByCaller || Utility.RandomInt(0,5) > 3)
							if (okayAdd && (DTSConditionals as DTSleep_Conditionals).SavageCabbageVers >= 1.10)
								sidArray.Add(51)
							endIf
						endIf
					elseIf (bedIsFloorBed && (DTSConditionals as DTSleep_Conditionals).SavageCabbageVers >= 1.27)		; v2.77
						if (playerPick && DoesMainActorPrefID(ScenePrefIsOral))
							sidArray.Add(84)			; floor oral
							addedFloorBedCount += 1
						elseIf (MySleepBedFurnType == FurnTypeIsSleepingBag)
							if (okayAdd)
								sidArray.Add(83)
								addedFloorBedCount += 1
							endIf
						elseif (!playerPick ||DoesMainActorPrefID(ScenePrefIsMission))
							sidArray.Add(82)
							addedFloorBedCount += 1
						endIf
					elseIf (bedIsFloorBed || standOnly || MainActorPositionByCaller)
						if (playerPick && DoesMainActorPrefID(ScenePrefIsOral) && (DTSConditionals as DTSleep_Conditionals).SavageCabbageVers >= 1.26)
							sidArray.Add(84)			; floor oral -- v2.70
							addedFloorBedCount += 1
						elseIf (okayAdd && (DTSConditionals as DTSleep_Conditionals).SavageCabbageVers >= 1.10)
							sidArray.Add(51, numToAdd)	; stand doggy
							addedFloorBedCount += 1
						endIf
					endIf
					; ---------------------
					
					if (MySleepBedFurnType != FurnTypeIsLimitedSpaceBed && !standOnly && !MainActorPositionByCaller && !bedIsCoffin && !bedIsSMBed)

						if (MySleepBedFurnType == FurnTypeIsDoubleBed)
							okayAdd = true
							if (!playerPick)
								sidArray.Add(1, numToAdd)			; not missionary -- v3.0
							endIf
							if (playerPick && !DoesMainActorPrefID(ScenePrefIsMission))
								okayAdd = false
							endIf
							if (okayAdd)
								
								if ((DTSConditionals as DTSleep_Conditionals).SavageCabbageVers >= 1.10 && DTSleep_SettingUseBT2Gun.GetValueInt() > 0)
									sidArray.Add(0, numToAdd)
								elseIf (RestrictScenesToErectAngle <= 0)
									sidArray.Add(0, numToAdd)
								endIf
								if ((DTSConditionals as DTSleep_Conditionals).SavageCabbageVers >= 1.21)
									sidArray.Add(6)
								endIf
								if ((DTSConditionals as DTSleep_Conditionals).SavageCabbageVers >= 1.26)			; v2.70 added 
									sidArray.Add(7)
								endIf
							endif
							okayAdd = true
							
							if (!SceneData.FemaleRaceHasTail)
								okayAdd = true
								if (playerPick && !DoesMainActorPrefID(ScenePrefIsDoggy))
									okayAdd = false
								elseIf (DoesSecondActorHateID(ScenePrefIsDoggy))
									okayAdd = false
								endIf
								if (okayAdd)
									if ((DTSConditionals as DTSleep_Conditionals).SavageCabbageVers >= 1.10)
										sidArray.Add(12, numToAdd)
									endIf
									if ((DTSConditionals as DTSleep_Conditionals).SavageCabbageVers >= 1.26)
										sidArray.Add(7, numToAdd)
									endIf
									if ((DTSConditionals as DTSleep_Conditionals).SavageCabbageVers >= 1.10 && DTSleep_SettingUseBT2Gun.GetValueInt() > 0)
										sidArray.Add(3, numToAdd)
										sidArray.Add(2)
									else
										if (RestrictScenesToErectAngle == 1 || RestrictScenesToErectAngle < 0)
											sidArray.Add(3, numToAdd)
										endIf	
										if (RestrictScenesToErectAngle == 0 || RestrictScenesToErectAngle < 0)
											sidArray.Add(2)
										endIf
									endIf
								endIf
							endIf
						endIf
						if (RestrictScenesToErectAngle == 1 || RestrictScenesToErectAngle < 0 || ((DTSConditionals as DTSleep_Conditionals).SavageCabbageVers >= 1.10 && DTSleep_SettingUseBT2Gun.GetValueInt() > 0))
							okayAdd = true
							if (playerPick && !DoesMainActorPrefID(ScenePrefIsCowgirl))
								okayAdd = false
							elseIf (DoesSecondActorHateID(ScenePrefIsDoggy))
								okayAdd = false
							endIf
							if (okayAdd)
								if (addedFloorBedCount <= 0 ||  MySleepBedFurnType != FurnTypeIsFloorBed)
									; v2.79 - orbit cam has problems with lowering to floor bed
									sidArray.Add(4)
								endIf
								if (MySleepBedFurnType != FurnTypeIsDoubleBed && MySleepBedFurnType != FurnTypeIsBunkBed && !SleepBedRef.HasKeyword(AnimFurnFloorBedAnimKY) && !IsSleepingBag(SleepBedRef))
									if (baseBedForm == None)
										baseBedForm = SleepBedRef.GetBaseObject() as Form
									endIf
									if (!DTSleep_BedsBigList.HasForm(baseBedForm))	; v2.26 - limit to normal single bed
										sidArray.Add(5, numToAdd)		; on edge of single bed - flip side to face player
									endIf
								endIf
							endIf
						endIf
						if (RestrictScenesToErectAngle <= 0 || ((DTSConditionals as DTSleep_Conditionals).SavageCabbageVers >= 1.10 && DTSleep_SettingUseBT2Gun.GetValueInt() > 0))
							
							if (MySleepBedFurnType != FurnTypeIsBunkBed)
								if (playerPick && DoesMainActorPrefID(ScenePrefIsOral))				; v2.53 only for oral/manual
									sidArray.Add(10, numToAdd)  ; blow-job
									sidArray.Add(11, numToAdd)  ; hand/tit-job
								endIf
							endIf
						endIf
					endIf
				endIf
			endIf
		
				
		elseIf (packID == 1 || packID == 2 || packID == 6)
			
			if (SceneData.CompanionInPowerArmor || SceneData.IsUsingCreature)
				
				if (packID == 2)
					sidArray.Add(50)	; solo
				endIf
				
			elseIf (!SceneData.IsUsingCreature && !cuddlesOnly && SceneData.SecondMaleRole == None && SceneData.SecondFemaleRole == None)
				
				;int numToAdd = 1
				;if (!mainActorIsMaleRole)
				;	numToAdd = 2
				;endIf
				restricted = false
				
				if (SceneData.SameGender && SceneData.MaleRoleGender == 1)
					
					if (SceneData.HasToyAvailable == false)
				
						restricted = true
						;if (packID == 1)
						;	if (bedIsDouble || SleepBedTwinRef != None)
						;		sidArray.Add(81)
						;	endIf
						;endIf
					endIf
				endIf
				
				if (!restricted)
					
					if (!standOnly && !MainActorPositionByCaller && !bedIsCoffin && MySleepBedFurnType != FurnTypeIsBunkBed)
						
						okayAdd = true
						if (playerPick && !DoesMainActorPrefID(ScenePrefIsMission))
							okayAdd = false
						endIf
						if (okayAdd && !bedIsSMBed)
							if (!SceneData.SameGender)
								if (packID == 1 || packID == 2 || IsMaleErectAngleRestrictedForPack(1, packID))
									sidArray.Add(0)
								endIf
							endIf
							if (MySleepBedFurnType != FurnTypeIsLimitedSpaceBed)	; v2.20 - bad fit for some devices, v3.15 - no cot
								sidArray.Add(1)
							endIf
						endIf
						
						okayAdd = true
						if (playerPick && !DoesMainActorPrefID(ScenePrefIsDoggy))
							okayAdd = false
						elseIf (!playerPick && DoesSecondActorHateID(ScenePrefIsDoggy))
							; v3.16 only when not picked
							okayAdd = false
						endIf
						if (okayAdd)
							if (!SceneData.FemaleRaceHasTail)  
								if (playerPick || MySleepBedFurnType != FurnTypeIsLimitedSpaceBed)	; v3.15 no cot unless picked
									sidArray.Add(2)
								endIf
								if (MySleepBedFurnType != FurnTypeIsLimitedSpaceBed)		; no cot	
									sidArray.Add(3)
								endIf
							endIf
						endIf
						if (!bedIsSMBed)
							okayAdd = true
							if (playerPick && !DoesMainActorPrefID(ScenePrefIsCowgirl))
								okayAdd = false
							elseIf (!playerPick && DoesSecondActorHateID(ScenePrefIsCowgirl))
								; v3.16 only when not picked
								okayAdd = false
							endIf
							if (okayAdd && !SceneData.SameGender)
								sidArray.Add(4)
							endIf
							if (packID != 2)
								if (okayAdd)
									
									if (playerPick || !SceneData.SameGender)	; v2.75 limit same-gender only if picked cowgirl
										sidArray.Add(5)
										if (!SceneData.SameGender)				; v2.74 - changed restriction to no-same-gender.. was if pack==1
											sidArray.Add(6)
										endIf
										sidArray.Add(7)
									endIf
								endIf
								
								okayAdd = true
								if (playerPick && !DoesMainActorPrefID(ScenePrefIsSpoon))
									okayAdd = false
								endIf
								if (okayAdd)
									; spoon
									if (packID == 1 || IsMaleErectAngleRestrictedForPack(1, packID))
										if (!SceneData.SameGender)
											
											if (MySleepBedFurnType != FurnTypeIsLimitedSpaceBed || playerPick)
												sidArray.Add(10)
											endIf
										endIf
									endIf
								endIf
							endIf
						endIf
						
						
						if (!SceneData.SameGender && packID != 2 && !bedIsSMBed && MySleepBedFurnType != FurnTypeIsLimitedSpaceBed)
							; reverse cowgirl bad fit for strap-on
							okayAdd = true
							if (playerPick && !DoesMainActorPrefID(ScenePrefIsCowgirl))
								okayAdd = false
							elseIf (DoesSecondActorHateID(ScenePrefIsCowgirl))
								okayAdd = false
							endIf
							if (okayAdd)
								if (packID == 1 || IsMaleErectAngleRestrictedForPack(1, packID))
									sidArray.Add(8)
									;sidArray.Add(9)			; too far out of alignment--not including--v2.73
								endIf
							endIf
						endIf
					endIf	; end non-stand-only  
					
					bool bedOK = true
					if (MySleepBedFurnType == FurnTypeIsBunkBed)
						bedOk = false
						if (MainActorPositionByCaller || standOnly || !playerPick || DoesMainActorPrefID(ScenePrefIsMission) || DoesMainActorPrefID(ScenePrefIsSpoon))
							; added pref-stand v3.01 fix
							; spoon and mission  v3.15
							bedOk = true
						endIf
						
					elseIf (MainActorPositionByCaller || bedIsFloorBed)
						bedOK = true				; v3.01 -- fix for v2.73
					else
						bedOk = false
					endIf
					
					if (bedOk)
						int standToAdd = 1		
						if (bedIsFloorBed && !bedIsCoffin)
							standToAdd = 2			; floor bed increased chance of stand scenes
						endIf

						; standing blow job
						if (!SceneData.SameGender)
							if (playerPick && DoesMainActorPrefID(ScenePrefIsOral))					; only add if picked v2.70
								if (SceneData.FemaleRole == MainActorRef)
									if (DoesSecondActorHateID(ScenePrefIsOral) == false)
										sidArray.Add(50)
									elseIf (sidArray.Length == 0)
										sidArray.Add(50)
									endIf
								else
									sidArray.Add(50)
								endIf
							elseIf (!MainActorPositionByCaller)						; more for bunkbed v3.15
								if (!playerPick || DoesMainActorPrefID(ScenePrefIsMission))
									sidArray.Add(0)
								endIf
								if (!playerPick || DoesMainActorPrefID(ScenePrefIsSpoon))
									sidArray.Add(10)
								endIf
							endIf
							
						elseIf (SceneData.MaleRoleGender == 0)
							; 2 males
							sidArray.Add(50)
						endif

						if (!SceneData.FemaleRaceHasTail)
							; stand doggy
							okayAdd = true
							if (playerpick && DoesMainActorPrefID(ScenePrefIsStand))			; v3.01 fix
								okayAdd = true
							elseIf (playerPick && !DoesMainActorPrefID(ScenePrefIsDoggy))
								okayAdd = false
							elseIf (DoesSecondActorHateID(ScenePrefIsDoggy))
								okayAdd = false
							endIf
							if (okayAdd)
								if (standToAdd > 1 && !mainActorIsMaleRole && !standOnly && Utility.RandomInt(1, 7) < 4)
									standToAdd = 1
								endIf

								if (!noLeitoGun)
									if (packID == 1 || (packID == 2 && !SceneData.SameGender) || IsMaleErectAngleRestrictedForPack(1, packID))
										sidArray.Add(51, standToAdd)
									endIf
								endIf
								if (packID == 1 || IsMaleErectAngleRestrictedForPack(0, packID))
									sidArray.Add(52, standToAdd)
									sidArray.Add(53, standToAdd)
								endIf
							endIf

						endIf
						if (!SceneData.SameGender && SceneData.MaleRoleGender == 0)
							okayAdd = true
							if (playerpick && DoesMainActorPrefID(ScenePrefIsStand))
								okayAdd = true
							elseIf (playerPick && !DoesMainActorPrefID(ScenePrefIsCarry))
								okayAdd = false
							elseIf (DoesSecondActorHateID(ScenePrefIsCarry))
								okayAdd = false
							endIf
							if (okayAdd)
								; carry
								sidArray.Add(54, standToAdd)
							endIf
							
						endIf
					endIf
				endIf
			endIf
		endIf
	
	
		; packs only adjust id 100s and replace hates with likes on random

		int addUp = 0
		if (packID > 0)
			addUp = packID * 100
		endIf
		int idx = startIndex

		if (packID > 0)
			while (idx < sidArray.Length)
				int seqIdVal = sidArray[idx]
				
				if (seqIdVal < 100)

					sidArray[idx] = seqIdVal + addUp
				endIf
					
				idx += 1
			endWhile
		endIf
	endIf
	
	return sidArray
endFunction

bool Function SceneIDIsCuddle(int sid)

	if (sid >= 94 && sid <= 99)
		return true
	elseIf (sid >= 400 && sid < 500)					; v3.0
		return true
	elseIf (sid == 501)
		return true
	elseIf (sid >= 548 && sid <= 549)
		return true
	elseIf (sid == 1098)
		return true	
	endIf
	
	return false
endFunction

bool Function SceneIDIsGroupPlay(int sid)
	
	if (sid >= 1100)				; v3.15
		if (sid == 1193)
			return true
		endIf
	elseIf (sid >= 700 && sid < 800)
		if (sid == 700)
			return true									; v2.70 - FMF
		elseIf (sid >= 702 && sid <= 707 && sid != 703)
			return true
		elseIf (sid >= 713 && sid <= 715)
			return true
		elseIf (sid == 735 || sid == 737 || sid == 749 || sid == 748 || sid == 756 || sid == 758)
			return true
		elseIf (sid == 761 || sid == 768)
			return true
		elseIf (sid == 786 && (DTSConditionals as DTSleep_Conditionals).SavageCabbageVers >= 1.230)
			return true
		endIf
	elseIf (sid >= 551 && sid <= 552)
		return true
	endIf
	
	return false
endFunction

bool Function SceneIDIsRomanceDance(int seqID)
	if (seqID == 91)
		return true
	elseIf (seqID >= 494 && seqID <= 495)
		return true
	endIf
	return false
endFunction

bool Function SceneIDIsSolo(int id)
	if (id == 741)
		; pole dance
		return true
	elseIf (id >= 798 && id <= 799)
		return true
	elseIf (id == 540 || id == 250 || id == 680 || id == 180)
		return true
	elseIf (id == 940)
		return true
	elseIf (id >= 1060 && id <= 1061)
		return true
	endIf
	return false
endFunction

bool Function SceneIDIsShowFlirt(int id)			; v3.15
	if (id >= 1152 && id <= 1154)
		return true
	elseIf (id == 1131)
		return true
	endIf
	return false
endFunction

bool Function SceneIDIsSpanking(int id)				; v3.15
	if (id == 1130)
		return true
	elseIf (id == 1141)
		return true 		; v3.21
	elseIf (id == 937)
		return true
	elseIf (id == 547)
		return true
	endIf
	return false
endFunction

bool Function SceneIDToyArmorNotOkay(int seqID)		;v3.22	
	
	; first FF-pair scenes
	if (seqID >= 1000 && seqID < 1100)
		return true
	elseIf (seqID == 181 || seqID == 180 || seqID == 680 || seqID == 681 || seqID == 281 || seqID == 947 || seqID == 1130 || seqID == 1135 || seqID == 1138 || seqID == 1141 || seqID == 1149 || seqID == 1152)
		
		return true
	endIf
	
	; MF-only scenes
	if (seqID >= 700 && seqID < 800)
		return true
	endIf
	
	return false ;scene okay to have toy armor equipped
endFunction

bool Function ActorsIntimateCompatible()

	if (MainActorRef.IsChild() || MainActorRef.HasKeyword(ActorTypeChildKW) || SecondActorRef.IsChild())
		Debug.Trace(MyScriptName + " A Child!!! ")
		return false
	endIf
	
	if (SceneData.RaceRestricted >= 9)
		Debug.Trace(MyScriptName + " companion race intimate restricted!")
		return false
	endIf
	
	; v2.82
	if (SceneData.IsCreatureType == 3)
		Debug.Trace(MyScriptName + " companion synth intimate restricted!")
		return false
	endIf
	
	Race pr = (DTSConditionals as DTSleep_Conditionals).PlayerRace

	if (pr != None && (DTSConditionals as DTSleep_Conditionals).NanaRace != None)
	
		if (pr == ((DTSConditionals as DTSleep_Conditionals).NanaRace || pr == (DTSConditionals as DTSleep_Conditionals).NanaRace2))
			Debug.Trace(MyScriptName + " player AnimeRace intimate restricted!")
			return false
		endIf
	endIf

	return true
endFunction

bool Function IsAAFEnabled()
	
	if (DTSleep_VR.GetValueInt() < 2)				; v3.0
		if (DTSleep_SettingAAF.GetValue() >= 1.0 && (DTSConditionals as DTSleep_Conditionals).IsF4SE && (DTSConditionals as DTSleep_Conditionals).IsAAFActive)
			return true
		endIf
	endIf
	
	return false
endFunction

bool Function IsMaleErectAngleRestrictedForPack(int angle, int packID)

	if (packID > 5)
		if (RestrictScenesToErectAngle == angle || RestrictScenesToErectAngle < 0)
			return true
		endIf
		return false
	endIf
	
	return true
endFunction

bool Function IsSceneAAFSafe(int sid, bool strictlyID)					; v2.75 added strictlyID to ignore enabled-variable
	if (!strictlyID && !PlayAAFEnabled)
		return false
	endIf
	if (sid < 500)				; 400s do not use AAF
		return false
	endIf
	if (sid > DTSleep_AAFMaxSID.GetValueInt())
		; not supported yet    v3.15  TODO ??
		return false
	endIf
	if (sid == 540)
		return false
	
	elseIf (sid == 771)
		return false						; Handy robot in Test Mode
	elseIf (sid >= 740 && sid <= 741)
		return false
	;elseIf (sid >= 797 && sid <= 799 && (DTSConditionals as DTSleep_Conditionals).SavageCabbageVers < 1.1)
	;	return false
	;
	elseIf (sid == 541)
		return true							; these solo scenes okay for AAF
	elseIf (SceneIDIsSolo(sid))
		return false
	elseIf (sid == 749 && SceneData.SecondMaleRole != None)
		return false
	elseIf (sid == 768 || sid == 761)
		if (SceneData.SecondMaleRole != None)
			return false
		endIf
	elseIf (sid == 780)
		return false
	elseIf (sid == 535)
		return false

	elseIf (sid >= 590 && sid <= 599)
		return true							; v2.74 now with XMLs
	endIf
	
	if (sid == 761 && (DTSConditionals as DTSleep_Conditionals).SavageCabbageVers < 1.1)
		return false
	endIf
	
	return true
endFunction


Function MoveActorsToAACPositions(Actor mainActor, Actor secondActor, Actor thirdActor = None, float mainYOff = 0.0, float mainAngleOff = 0.0, float secondAngleOff = 0.0, float mainZOff = 0.0)

	float posX = 0.0
	float posY = 0.0
	float secondYOff = 0.0 - mainYOff
	float secondZOff = 0.0 - mainZOff

	; v2.60 - only clone to help fix shaky scenes -- embrace
	if (MainActorCloneRef != None && SceneData.MaleMarker != None)

		if (mainActor == MainActorRef)
			if (DTSleep_CommonF.PositionObjsMatch(SceneData.MaleMarker, MainActorRef) == false)
				; they really should

				SceneData.MaleMarker.MoveTo(MainActorRef, 0.0, 0.0, 0.0, true)
			endIf
		else
			TurnActorToObjHeading(mainActor, SceneData.MaleMarker, mainAngleOff)
		endIf
		posX = SceneData.MaleMarker.GetPositionX()
		posY = SceneData.MaleMarker.GetPositionY()
		
		; offsets: y, z, x  
		DTSleep_CommonF.MoveActorToObject(mainActor, SceneData.MaleMarker, mainAngleOff, mainYOff, 0.0)		; never move mainActor Z-axis
		
		if (secondActor != None)
		
			TurnActorToObjHeading(secondActor, SceneData.MaleMarker, secondAngleOff)
			DTSleep_CommonF.MoveActorToObject(secondActor, SceneData.MaleMarker, secondAngleOff)
		endIf
		if (thirdActor != None)
			thirdActor.MoveTo(SceneData.MaleMarker, 0.0, 0.0, 0.0, true)
			DTSleep_CommonF.MoveActorToObject(thirdActor, SceneData.MaleMarker, secondAngleOff)
		endIf
		
	elseIf (secondActor != None)
		TurnActorToObjHeading(secondActor, mainActor, secondAngleOff)
		DTSleep_CommonF.MoveActorToObject(secondActor, mainActor, secondAngleOff, secondYOff, secondZOff)
		
		if (mainAngleOff != 0.0)
			ObjectReference myMarker = SceneData.MaleMarker
			if (myMarker == None)
				myMarker = SceneData.FemaleMarker
			endIf
			
			DTSleep_CommonF.MoveActorToObject(mainActor, SceneData.MaleMarker, mainAngleOff, mainYOff, 0.0)		; never move mainActor Z-axis
		endIf
		
		if (thirdActor != None)
			thirdActor.MoveTo(mainActor, 0.0, 0.0, 0.0, true)
			DTSleep_CommonF.MoveActorToObject(thirdActor, mainActor, secondAngleOff, secondYOff, secondZOff)
		endIf
	endIf
	
	Utility.Wait(0.1)
	
	int i = 0
	if (mainYOff == 0.0 && mainZOff == 0.0 && posX != 0.0 && posY != 0.0)
		while (i < 4 && secondActor != None && DTSleep_CommonF.PositionObjsMatch(mainActor, secondActor) == false)
			Utility.Wait(0.25)
			i += 1
		endWhile
	else
		Utility.Wait(0.86)
	endIf
	
	; v2.60 - only clone to help fix shaky stand scenes -- embrace
	if (MainActorCloneRef != None && SceneData.MaleMarker != None)
		; check height
		float posZ = mainActor.GetPositionZ()
		float targetZ = SceneData.MaleMarker.GetPositionZ()
		float diff = posZ - targetZ
		if (Math.Abs(diff) > 1.0)

			DTSleep_CommonF.MoveActorToObject(mainActor, SceneData.MaleMarker, mainAngleOff, mainYOff, 0.0)		; never move mainActor Z-axis
			Utility.Wait(0.25)
			
			if (secondActor != None)
				; ensure alignment
				DTSleep_CommonF.MoveActorToObject(secondActor, mainActor, secondAngleOff, secondYOff, secondZOff)
			endIf
			if (thirdActor != None)
				; ensure alignment
				DTSleep_CommonF.MoveActorToObject(thirdActor, mainActor, secondAngleOff, secondYOff, secondZOff)
			endIf
			if (secondActor != None || thirdActor != None)
				Utility.Wait(0.33)
			endif
		endIf
	endIf
endFunction

bool Function TurnActorToObjHeading(Actor actorRef, ObjectReference obj, float offset = 0.0)
	
	bool turnRequired = true
	float angleObj = obj.GetAngleZ() + offset
	
	if (angleObj < -180.0)
		angleObj += 360.0
	elseIf (angleObj > 360.0)
		angleObj -= 360.0
	endIf
	
	if (SceneData.MarkerOrientationAllowance > 0)
		
		int angleDiff = DTSleep_CommonF.DistanceBetweenAngles(angleObj, actorRef.GetAngleZ())
		
		if (angleDiff < SceneData.MarkerOrientationAllowance)
			turnRequired = false
		endIf
	endIf

	if (turnRequired)
		actorRef.SetAngle(0.0, 0.0, angleObj)
		return true
	endIf
	
	return false
endFunction

; these scenes all start at player's position -- no move to furniture
bool Function SceneIDAtPlayerPosition(int sid)

	if (sid >= 90 && sid < 100)
		return true
	elseIf (sid >= 490 && sid < 500)
		return true
	elseIf (sid == 1098)
		return true
	;elseIf (sid == 1051)			; v3.02  -> v3.15--uses actor rotation
	;	return true
	elseIf (sid >= 1154 && sid <= 1155)			; v3.15
		return true
		
	elseIf (sid >= 150 && sid < 160)
		if (SleepBedRef == None || SleepBedRef.HasKeyword(AnimFurnFloorBedAnimKY))
			return true
		elseIf (sid > 150 && sid < 154 && SceneData.FemaleRole == MainActorRef)
			if (SleepBedRef.HasKeyword(AnimFurnLayDownUtilityBoxKY))
				if (sid == 151)
					return false
				endIf
			elseIf (MySleepBedFurnType == FurnTypeIsTablePicnic || MySleepBedFurnType == FurnTypeIsTablePool)
				; put on table v2.70
				return false
			endIf
		endIf
		return true
		
	elseIf (sid >= 250 && sid < 300)
		return true
	elseIf (sid == 540 && !SleepBedRef.HasKeyword(DTSleep_PoolTableKeyword))
		return true
	elseIf (sid >= 546 && sid <= 549)
		return true
	elseIf (sid == 550)							; v2.87
		if (SleepBedRef == None || SleepBedRef.HasKeyword(AnimFurnFloorBedAnimKY))
			return true
		elseIf (SceneData.FemaleRole == MainActorRef)
			if (MySleepBedFurnType == FurnTypeIsTablePicnic || MySleepBedFurnType == FurnTypeIsTablePool)
				; put on table 
				return false
			endIf
		endIf

		return true
		
	elseIf (sid >= 562 && sid <= 563)
		return true
	;elseIf (sid == 551)	; not enough room - causes player character to get pushed	
	;	return true
	elseIf (sid >= 650 && sid < 660)
		if (SleepBedRef == None || SleepBedRef.HasKeyword(AnimFurnFloorBedAnimKY))
			return true
		elseIf (sid > 650 && sid < 654 && SceneData.FemaleRole == MainActorRef)
			if (SleepBedRef.HasKeyword(AnimFurnLayDownUtilityBoxKY))			; v2.70 be like 150
				if (sid == 651)													; v2.87 corrected 151 -> 651
					return false
				endIf
			elseIf (MySleepBedFurnType == FurnTypeIsTablePicnic || MySleepBedFurnType == FurnTypeIsTablePool)
				; put on table v2.70
				return false
			endIf
		endIf
		return true				; v2.73 moved down default to catch-all
		
	elseIf (sid == 740)	
		return true
	elseIf (sid == 751)
		if (SleepBedRef == None)
			return true
		elseIf (SleepBedRef.HasKeyword(AnimFurnLayDownUtilityBoxKY))
			return false
		endIf
		return true
	elseIf (sid == 758)
		if (SceneData.SecondMaleRole != None)
			return true
		endIf
	elseIf (sid >= 760 && sid < 764)
		return true
	elseIf (sid == 769)
		return true
	elseIf (sid >= 770 && sid <= 776 && sid != 773 && sid != 772)		;v2.70 added 773 to strong on couch, v2.88 added 772-patio-table
		return true
	elseIf (sid == 784)
		return true
		
	elseIf (sid >= 960 && sid < 963)
		return true
	endIf
	
	

	return false
endFunction


bool Function SceneOkayToClonePlayer(int sid)

	; updated for v2.70 to allow more scenes not cloned for orbit-view with new strict-preference to maintain old way
	; -- height adjusted scenes (all 600s sid on beds) should always be cloned, but allowed in Force-Orbit-view
	; -- for beds default always clone unless preference prompt-for-sleep then use orbit for animations designed for bed (non-height-adjusted)
	
	; cloneOkay: 1 = situational-new (default), 0 = no clone (orbit view), 
	;            2 = situational-strict (original 1), 3 = always clone (look view)
	
	int cloneOkay = DTSleep_SettingAACV.GetValueInt()
	int promptForSleep = DTSleep_SettingFadeEndScene.GetValueInt()			; toggles -- default = 1 for go-to-bed tired, 0 = always prompt
																			; allow player to change no matter the toggle
																			
	; ---SceneData.IntimateSceneViewType to return---
	;    1 = forced clone, 2 = forced orbit
	;    3 = cloned, player may change
	;    4 = no-cloned, player may change
	;    5 = cloned by preference, 6 = not-cloned by preference
	;    10 = AAF
	; ------------
	
	; v3.0 fixes -- check furnitures for positioned-by-caller
	
		
	if (sid < 100)
	
		SceneData.IntimateSceneViewType = 2	
		return false
	endIf
	
	if (DTSleep_VR.GetValue() >= 2.0)
		; clone player for VR-mode with exceptions  -- v3.0
		if (MainActorPositionByCaller || SceneIDAtPlayerPosition(sid))
			
			; standing scene best with orbit-view
			SceneData.IntimateSceneViewType = 2
			return false
		endIf

		; clone for VR-mode, what about standing? TODO:    v3.0
		SceneData.IntimateSceneViewType = 1
		return true
	endIf
	
	SceneData.IntimateSceneViewType = 4			; default return false for not cloned and may change by preference
	if (cloneOkay == 2)
		SceneData.IntimateSceneViewType = 2		; strict, default to forced on return false
	endIf
		
	if (cloneOkay >= 3)
		; force clone / look-view
		SceneData.IntimateSceneViewType = 1			; forced by settings
		return true
		
	elseIf (sid == 741 || sid == 795)		; pole-dance and jail-oral before, because pole/bars cause issue with orbit-view
		SceneData.IntimateSceneViewType = 1	; forced
		return true
		
	elseIf (SceneHasRotatePlayerForID(sid))
		
		SceneData.IntimateSceneViewType = 1 ; forced due to actor rotations			v3.15
		return true
	
	elseIf (sid == 1193)
		SceneData.IntimateSceneViewType = 1 ; forced due to rotation and shift			v3.15
		return true
	elseIf (sid == 1138)
		SceneData.IntimateSceneViewType = 1 ; forced due to z-offset		v3.20
		return true
		
	elseIf ((MySleepBedFurnType == FurnTypeIsLocker && !MainActorPositionByCaller && sid > 700) || sid == 788)
		; clone to keep camera outside of locker
		SceneData.IntimateSceneViewType = 1	; forced
		return true
		
	elseIf (MainActorPositionByCaller || SceneIDAtPlayerPosition(sid))
		; standing scene best with orbit-view
		
		SceneData.IntimateSceneViewType = 2
		return false
		
	elseIf ((MySleepBedFurnType == FurnTypeIsSedanPostWar || MySleepBedFurnType == FurnTypeIsSedanPreWar) && !MainActorPositionByCaller && sid > 700)
		; must be cloned else character forced outside car
		SceneData.IntimateSceneViewType = 1	; forced
		return true
		
	elseIf (MySleepBedFurnType == FurnTypeIsRailing && !MainActorPositionByCaller && sid > 700)
		; cannot position player correctly so always clone
		SceneData.IntimateSceneViewType = 1
		return true
		
	elseIf (MySleepBedFurnType == FurnTypeIsBunkBed && !MainActorPositionByCaller && sid > 500)
		; bunk bed gets in way of positioning, must be cloned
		SceneData.IntimateSceneViewType = 1
		return true
		
	elseIf (cloneOkay <= 0)					; force-orbit preference
		SceneData.IntimateSceneViewType = 2	; forced by settings
		return false
		
	elseIf (sid < 400)
		; older animations (pre-AAF) character placed apart and many height-adjusted
		SceneData.IntimateSceneViewType = 2	
		return false
		
	elseIf (cloneOkay == 1)
	
		; default decide updated for v2.70  (2 is strict/original which we let fall through to clone)
		
		;  ******* player pref first *******
		if (PlayerPrefSceneCloneOKSIDArray.Length > 0 && DTSleep_CommonF.IsIntegerInArray(sid, PlayerPrefSceneCloneOKSIDArray))
			SceneData.IntimateSceneViewType = 5				; by preference
			return true
			
		elseIf (PlayerPrefSceneCloneNoSIDArray.Length > 0 && DTSleep_CommonF.IsIntegerInArray(sid, PlayerPrefSceneCloneNoSIDArray))
			SceneData.IntimateSceneViewType = 6				; by preference
			return false
		endIf
		; *****************
		
		if (MySleepBedFurnType == FurnTypeIsWorkbenchArmor || MySleepBedFurnType == FurnTypeIsWorkBenchWeaponLarge || MySleepBedFurnType == FurnTypeIsShower)
			; okay for orbit
			return false
		elseIf (sid == 739)
			; lap dance okay for orbit, but may shake too much on constructed surfaces  v3.0
			SceneData.IntimateSceneViewType = 3
			return true 
			
		elseIf (MySleepBedFurnType >= 220 && MySleepBedFurnType <= 230 && !MainActorPositionByCaller && sid >= 500)
			; all seats  default to clone look-view -- player may change  v3.15

			SceneData.IntimateSceneViewType = 3
			return true
			
		elseIf (sid >= 660 && sid < 700)
			; seats (handled above) shake too much

			; all other Leito furniture and super mutant scenes (660-663) on floor or floor-bed okay for orbit
			SceneData.IntimateSceneViewType = 4
			return false
			
		elseIf (MySleepBedFurnType == FurnTypeIsDoubleBed)
			; Strong  okay, no height-adjusted animations, but sometimes shakes 
			if (sid >= 700 && sid < 800)
				if (sid == 700 && SceneData.SecondFemaleRole != None)
					; without plenty space likely to be misaligned

					SceneData.IntimateSceneViewType = 3		; always prompt, player may change
					return true
					
				elseIf (sid >= 764 || promptForSleep <= 0)
					if (sid == 765)
						; may camera chake  v3.16
						SceneData.IntimateSceneViewType = 3
						return true
					endIf
					return false
				endIf
			elseIf (sid == 505 && promptForSleep <= 0)
				; designed for bed
				return false
			endIf
		elseIf (MySleepBedFurnType == FurnTypeIsBedSingle || SleepBedIsPillowBed || MySleepBedFurnType == FurnTypePillowBedHasFrame || MySleepBedFurnType == FurnTypeIsLimitedSpaceBed)
			; do not include height-adjusted scenes (all 600s, most 500s, all 900s)
			; v2.79 - included SleepBedIsPillowBed 
			
			if (sid >= 700 && sid < 800)
				if (promptForSleep <= 0)
					return false
				endIf
			elseIf (sid == 506 || sid == 509)
				if (promptForSleep <= 0)
					return false
				endIf
			endIf
		elseIf (MySleepBedFurnType == FurnTypeIsSleepingBag)

			if (sid == 704)
				return true				; v2.79 -- orbit has issues on this lowered animation
			endIf
		
			; probably okay to orbit
			return false
			
		elseIf (MySleepBedFurnType == FurnTypeIsFloorBed)
			; v3.15 now same as sleeping bag
			if (sid == 704)
				return true				; v2.79 -- orbit has issues on this lowered animation
			endIf
			
			; probably okay to orbit
			return false
			
		elseIf (MySleepBedFurnType == FurnTypeIsWeightBench || MySleepBedFurnType == FurnTypeIsMotorCycle)
			return true											; position too high for orbit--prefer clone v2.90
		elseIf (MySleepBedFurnType == FurnTypeIsPARepair)
			return false
		elseIf (MySleepBedFurnType == FurnTypeIsCoffin)
			; mostly stand animations
			return false
			
		elseIf (sid == 796)
			; jail stand okay
			return false
		elseIf (sid == 748)
			; base-game Pillory okay for orbit (not ZaZOut which shakes too much)
			return false

		elseIf (MySleepBedFurnType == FurnTypeIsTablePicnic)
			if (sid == 470)
				return true
			endIf
			; height-adjusted animations appear to work on table
			return false
		elseIf (MySleepBedFurnType == FurnTypeIsTablePool)
			; height-adjusted animations seem okay, but SavageCabbage's climb onto table sometimes shaky
			if (sid == 756)
				return true							; v2.90
			endIf
			return false
		elseIf (MySleepBedFurnType == FurnTypeIsSMBed)
			if (sid == 768)
				; orbit works, but not centered
				return false				
			endif
			return false
		elseIf (sid == 752)
			; desk doggy sometimes shakes sometimes okay
			SceneData.IntimateSceneViewType = 3
			return true
		;elseIf (sid == 743)
			; table sit missionary-743 okay for orbit  - dining table or diner booth
			; okay, but characters float slightly above table -- let's default to view -- v2.90
			;;return false
		endIf
	endIf
	
	; sid 744, 745 at small table shakes too much
	
	SceneData.IntimateSceneViewType =  1				; cloned, no changes
	
	if (cloneOkay == 1)
		; update view type for beds?  - player may change beds no matter go-to-bed since go-to-bed toggles view
		
		SceneData.IntimateSceneViewType = 3			; cloned and may change by preference
	endIf
	
	return true
endFunction

; allow viewing from chair of scene?
; return -1 = no, 0 = no-sit/stand-OK, 1 = clone/sit, 2 = no-clone/sit
int Function SceneOkayLookViewSit(int id, ObjectReference furnRef)

	if (furnRef == None)
		return -1
	endIf
	
	; player likely looking at bed/chair and we want to put clone between
	; note: for standing hug/kiss we force MainActorPositionByCaller true so check last
	
	float dist = MainActorRef.GetDistance(furnRef)
	bool isSeat = false
	bool isFloorBed = false
	
	if (furnRef.HasKeyword(AnimFurnFloorBedAnimKY))
		isFloorBed = true
	
	elseIf (IsObjSeat(furnRef))
	
		isSeat = true
		; can player sit for scene? 
		; --- note: seated player shows HUD even disabled, so use TestMode for now
		if (id == 739 && MainActorRef == SceneData.MaleRole && DTSleep_SettingTestMode.GetValueInt() >= 1)
			return 2
		endIf
	endIf
	
	if (id < 100)
		if (isSeat && dist > 80.0)
			return 0
		elseIf (isFloorBed)
			return 0
		endIf
	elseIf (id >= 490 && id < 500 && isSeat)
		if (isSeat && dist > 80.0)
			return 0
		elseIf (isFloorBed)
			return 0
		endIf
	elseIf (id == 1098)
		if (isSeat && dist > 80.0)
			return 0
		elseIf (isFloorBed)
			return 0
		endIf
	
	elseIf (MainActorPositionByCaller && SceneIDAtPlayerPosition(id))
		if (dist > 96.0)
			return 0
		endIf
	endIf

	return -1
endFunction

; does scene have rotation for player role?
; we cannot rotate player, but we can rotate clone
; v3.15
bool Function SceneHasRotatePlayerForID(int sid)
	if (MainActorRef == SceneData.MaleRole)
		if (sid >= 1149 && sid <= 1153)
			return true
		elseIf (sid == 1136 || sid == 1100 || sid == 1101 || sid == 1162)
			return true
		elseIf (sid >= 800 && sid < 900)
			return true
		endIf
	else
		; player in female role
		if (sid >= 1130 && sid <= 1135 && sid != 1132)
			return true
		elseIf (sid >= 1050 && sid <= 1051)
			return true
		endIf
	endIf
	
	return false
endFunction

float Function GetHoursDifference(float time1, float time2)
	float result = 0.0
	if (time2 == time1)
		return 0.0
	elseIf (time2 > time1)
		result = time2 - time1
	else
		result = time1 - time2
	endIf
	result *= 24.0
	return result
endFunction

bool Function IsFurnTypeBed(int furnType)
	if (furnType == FurnTypeIsBedSingle || furnType == FurnTypeIsBunkBed || furnType == FurnTypeIsCoffin || furnType == FurnTypeIsDoubleBed)
		return true
	elseIf (furnType == FurnTypeIsFloorBed || furnType == FurnTypePillowBedHasFrame || furnType == FurnTypeIsLimitedSpaceBed)
		return true
	elseIf (furnType == FurnTypeIsSleepingBag)
		return true
	endIf
	
	return false
endFunction

Function TurnActorAtAngle(Actor actorRef, float angle)
	float angleZ = actorRef.GetAngleZ() + angle
	if (angleZ > 360.0)
		angleZ -= 360.0
	elseIf (angleZ < 0.0)
		angleZ += 360.0
	endIf
	if (DTSleep_SettingTestMode.GetValue() > 0.0 && DTSleep_DebugMode.GetValue() >= 3.0)
		Debug.Trace(myScriptName + " turning main actor " + angleZ)
	endIf
	actorRef.SetAngle(0.0, 0.0, angleZ)
	
	if (actorRef == MainActorRef)
		MainActorMovedCount += 1
	endIf
endFunction

Function UpdateMyLastScenes(int[] sceneIDArray)
	if (MySceneIgnoreArray.Length > 0 && sceneIDArray.Length > 1)
		; copy over IDs not on ignore-list
		MyLastSceneListArray = new int[0]
		
		int i = 0
		while (i < sceneIDArray.Length)
			
			if (MySceneIgnoreArray.Find(sceneIDArray[i]) < 0)
				MyLastSceneListArray.Add(sceneIDArray[i])
			endIf
		
			i += 1
		endWhile
		
		; ---- v3.0 -- allow empty
		;if (MyLastSceneListArray.Length == 0)
		;	; must have at least one even if ignored
		;	MyLastSceneListArray.Add(sceneIDArray[0])
		;endIf
	else
		; copy all
		MyLastSceneListArray = DTSleep_CommonF.CopyIntArray(sceneIDArray)
	endIf
endFunction
