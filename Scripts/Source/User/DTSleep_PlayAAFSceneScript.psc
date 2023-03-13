Scriptname DTSleep_PlayAAFSceneScript extends Quest


; *********************
; script by DracoTorre
; Sleep Intimate
; https://www.dracotorre.com/mods/sleepintimate/
; updated for Sleep Intimate v2.17 to use AACcat for all except Leito and some Atomic scenes
;
; plays scene using Advanced Animation Framework (AAF) beta
;   - supports variable-length, multi-branching staged scenes controlled by script
;   - disables AAF undress/redress in favor of SleepIntimate undress expected before start
;   - scene chosen and setup by DTSleep_IntimateAnimQuestScript
;   - expected scene info found in SceneData
;
; build requires F4SE and AAF sources
;
; Leito's scenes require XMLs for FO4_AnimationsByLeito: 
;   - SleepIntimateX_Leito_positionData.xml
;	- SleepIntimateX_Leito_animationData.xml
;
; Atomic scenes require on XML for AtomicLust:
;	- SleepIntimateX_AtomicLust_positionData.xml
;	- SleepIntimateX_AtomicLust_animationData.xml
;
; SavageCabbage scenes:
;	- SleepIntimateX_SavageCabbage_positionData.xml
;	- SleepIntimateX_SavageCabbage_animationData.xml
;
; ZaZOut4 scenes:
; 	- SleepIntimateX_ZaZOut4_positionData.xml
;	- SleepIntimateX_ZaZOut4_animationData.xml
;
; 50 Shades of Fallout by Gray scenes:
;   - SleepIntimateX_Graymod_positionData.xml
;   - SleepIntimateX_Graymod_animationData.xml
;
; note: AAF uses a doppelganger borrowing player-character armor items which is then returned afterward
; and rather late.
;
import DTSleep_AACcatScript

; holds info for single stage of sequence
Struct AStageItem
	string StageIDStr
	Armor NudeArmorGun		; first male
	Armor NudeArmorGunM2	; second male
	float StageTime
EndStruct

Group A_DTQuests
DTSleep_Conditionals property DTSConditionals auto
EndGroup

Group B_Globals
;GlobalVariable property DTSleep_WasPlayerThirdPerson auto Mandatory
GlobalVariable property DTSleep_IntimateIdleID auto Mandatory
{expected >= 500 }
GlobalVariable property DTSleep_IntimateSceneLen auto
{ count of blocks of time until scene finished }
GlobalVariable property DTSleep_SettingTestMode auto const
GlobalVariable property DTSleep_DebugMode auto const
GlobalVariable property DTSleep_SettingAAF auto const
GlobalVariable property DTSleep_SettingUseLeitoGun auto const
GlobalVariable property DTSleep_SettingUseBT2Gun auto const
{ if using erection 'gun' nude body for male }
GlobalVariable property DTSleep_SettingSynthHuman auto const
GlobalVariable property DTSleep_AAFTestTipShown auto	; time last shown
GlobalVariable property DTSleep_SettingUseSMMorph auto const
EndGroup

Group A_GameData
Actor property PlayerRef auto const Mandatory
DTSleep_SceneData property SceneData auto const
{ all we need to know actors, creatures, markers, ... }
;FormList property DTSleep_StrapOnList auto const
FormList property DTSleep_LeitoGunList auto const
{ nude male body sets with erection 'gun' aimed - use when need to replace AAF morph }
FormList property DTSleep_BT2GunList auto const
FormList property DTSleep_LeitoGunSynthList auto const
;Armor property DTSleep_NudeSuitPlayerUp auto const
Message property DTSleep_TestModeIDMessage auto const   ; reminds in test mode - could activate AAF interface to see ID
Message property DTSleep_AAFGUIReminderMsg auto const
Keyword property DTSleep_MorphKeyword auto const
EndGroup

; ---------- hidden ----------
Actor property MainActor auto hidden
Actor property SecondActor auto hidden
ObjectReference property BedInSceneRef auto hidden
int property SequenceID auto hidden
int property MySceneStatus auto hidden
int property MySceneStartErrorCount auto hidden
string property MyStartSeqID auto hidden   ; to look for on event start
bool property MSceneFadeEnabled auto hidden
bool property MaleBodyMorphEnabled auto hidden

; *************************
;          variables

CustomEvent SleepIntAAFPlayDoneEvent

InputEnableLayer DTSleepPlaySceneInputLayer
DTAACSceneStageStruct[] MySeqStagesArray = None

AStageItem[] MyPositionIDArray
int SeqLimitTimerID = 101 const
int ShowTestSceneNumTimerID = 102 const
int ChangeSettingsAndStopTimerID = 103 const
int ShowAAFEquipTipTimerID = 104 const
int CheckSceneStartTimerID = 9 const
int AAFCheckStartCount = 0
int MyMaleRoleGender = -1
int SecondRoleGender = -1
float CurrentSingleDuration = -1.0

AAF:AAF_API AAF_API

; ********************************************
; *****                Events       ***********
;

Event OnQuestInit()
	InitAAFAPI()
	CurrentSingleDuration = -1.0
	MyMaleRoleGender = -1
	MainActor = None
	SecondActor = None
	MySeqStagesArray = None
	MaleBodyMorphEnabled = false
	
	if ((DTSConditionals as DTSleep_Conditionals).IsF4SE && (DTSConditionals as DTSleep_Conditionals).IsLooksMenuActive && SceneData.IsCreatureType != 3)
		if (DTSleep_SettingUseBT2Gun.GetValue() >= 2.0 && SceneData.AnimationSet != 8 && SceneData.IsCreatureType < 5 && SceneData.IsCreatureType != 1)
			if (SceneData.SameGender == false || SceneData.MaleRoleGender == 0)
				;Debug.Trace("[DTSleep_PlayAAF] male morph enabled")
				MaleBodyMorphEnabled = true
			endIf
		elseIf (SceneData.IsCreatureType == 1 || SceneData.IsCreatureType == 6)
			if (DTSleep_SettingUseSMMorph.GetValue() >= 1.0)
			
				MaleBodyMorphEnabled = true
			endIf
		endIf
	endIf
EndEvent

Event OnTimer(int aiTimerID)

	if (aiTimerID == CheckSceneStartTimerID)
		CheckSceneStart()
	elseIf (aiTimerID == ShowTestSceneNumTimerID)
		if (MySceneStatus == 1 && SceneData.Interrupted <= 0 && Game.IsMovementControlsEnabled())
			DTSleep_TestModeIDMessage.Show(SequenceID)
		endIf
	elseIf (aiTimerID == ShowAAFEquipTipTimerID)
		if (MySceneStatus == 1 && SceneData.Interrupted <= 0 && Game.IsMovementControlsEnabled())
			DTSleep_AAFGUIReminderMsg.ShowAsHelpMessage("Rest", 8, 30, 1)
			Utility.Wait(1.0)
			if (MySceneStatus == 1 && SceneData.Interrupted <= 0)
				DTSleep_AAFTestTipShown.SetValue(Utility.GetCurrentGameTime())
			endIf
		endIf
	elseIf (aiTimerID == ChangeSettingsAndStopTimerID)
		ChangeSettingsDefaultEnabled(true)
		self.Stop()
	endIf
EndEvent

Event OnMenuOpenCloseEvent(string asMenuName, bool abOpening)
    if (asMenuName== "PipboyMenu")
	
		UnregisterForMenuOpenCloseEvent("PipboyMenu")
		SceneData.Interrupted = 1
		Utility.Wait(0.5)
		StopAnimationSequence(true)
		
	endIf
EndEvent


Event AAF:AAF_API.OnAnimationStart(AAF:AAF_API akSender, Var[] akArgs)
	if (DTSleep_SettingTestMode.GetValue() > 0.0 && DTSleep_DebugMode.GetValue() >= 1.0) ;TODO remove
		Debug.Trace("[DTSleep_PlayAAF] event OnAnimationStart")
	endIf
	
	; make certain this is our scene and playing correctly
	
	int goodToGo = 0
	if (akArgs != None && akArgs.Length >= 3)
		int stat = akArgs[0] as int
	
		if (stat == 0)
			string posId = akArgs[2] as string
			
			if (posId == MyStartSeqID)
				goodToGo = 1
				MySceneStartErrorCount = 0
				if (IsTestModeOn())

					DTSleepPlaySceneInputLayer.EnablePlayerControls()
					Utility.Wait(0.1)
					DTSleepPlaySceneInputLayer.DisablePlayerControls(false, true, true, false, true, false, true, true, true, true, true)

					StartTimer(3.6, ShowTestSceneNumTimerID)
					
					

					if (DTSleep_SettingAAF.GetValueInt() > 1)
						float lastShown = DTSleep_AAFTestTipShown.GetValue()
						if (lastShown <= 0.0 || (Utility.GetCurrentGameTime() - lastShown) > 9.5)
							StartTimer(9.0, ShowAAFEquipTipTimerID)
						endIf
					endIf
				endIf
			elseIf (DTSleep_SettingTestMode.GetValue() > 0.0 && DTSleep_DebugMode.GetValue() >= 2.0)
				Debug.Trace("[DTSleep_PlayAAF] not my scene - " + posId)
			endIf
			; else another scene
		else
			; error starting scene
			goodToGo = -1
			MySceneStartErrorCount += 1
			
			string errMsg = akArgs[1] as string
			Debug.Trace("[DTSleep_PlayAAF] error on AnimationStart with error:---" + errMsg)
		endIf
	endIf
	
	if (goodToGo == 1 && SceneData.Interrupted <= 0)				; check interrupted in case Anim canceled  -- v2.73
		UnregisterForCustomEvent(AAF_API, "OnAnimationStart")
		SceneData.Interrupted = 0
		MySceneStatus = 1
		
		if (MSceneFadeEnabled)
			Game.FadeOutGame(false, true, 0.0, 1.1)
		endIf
		
		;if (SequenceID >= 600 && SequenceID < 660)
		;	PlayLeitoPairContinuedSequence(SceneData.WaitSecs)
		;elseIf (SequenceID >= 660 && SequenceID < 680)					; Leito uses AAC now - v2.73
		;	PlayLeitoStrongContinuedSequence()
		;else
			PlayAAContinuedSequence(SceneData.WaitSecs)
		;endIf
		
	elseIf (goodToGo <= -1 || SceneData.Interrupted >= 1)				; may have been interrupted -- v2.73
	
		if (DTSleep_SettingTestMode.GetValue() > 0.0 && DTSleep_DebugMode.GetValue() >= 1.0)
			Debug.Trace("[DTSleep_PlayAAF] OnAnimationStart issues found  - goodToGo: " + goodToGo)
		endIf
		UnregisterForCustomEvent(AAF_API, "OnAnimationStart")
		SceneData.Interrupted = 6
		MySceneStatus = 6
		StopAnimationSequence(true)	; cancel
		
	elseIf (goodToGo == 0)
		if (DTSleep_SettingTestMode.GetValue() > 0.0 && DTSleep_DebugMode.GetValue() >= 2.0)
			Debug.Trace("[DTSleep_PlayAAF] OnAnimationStart not my scene? ")
		endIf
	endIf
EndEvent

Event AAF:AAF_API.OnAnimationStop(AAF:AAF_API akSender, Var[] akArgs)
	UnregisterForCustomEvent(AAF_API, "OnAnimationStop")
	if (DTSleep_SettingTestMode.GetValue() > 0.0 && DTSleep_DebugMode.GetValue() >= 2.0)
		Debug.Trace("[DTSleep_PlayAAF] event OnAnimationStop - status: " + MySceneStatus)
	endIf
	
	if (MySceneStatus < 3)
		if (MySceneStatus < 2)
			SceneData.Interrupted = 1
		endIf
		MySceneStatus = 3
		StopAnimationSequence()
	endIf

EndEvent

; ********************************************
; *****                Functions       ***********
;

; begin animations - 
; second actor must be akfActor (target) and not player in two-person sequences
; This will start AAF scene and set flags so caller can sync scene timer with animation-start event 
;
bool Function StartupScenePublic(Actor aMainActor, Actor aSecondaryActor, ObjectReference aBedRef = None, bool fadeEnabled = false)
	
	SequenceID = DTSleep_IntimateIdleID.GetValueInt()
	AAFCheckStartCount = 0
	BedInSceneRef = aBedRef
	MyMaleRoleGender = -2
	MSceneFadeEnabled = fadeEnabled
	
	if (aMainActor && aSecondaryActor != PlayerRef)
		SecondActor = aSecondaryActor
		MainActor = aMainActor
		
		; remove weapons since may be using visble/holstered weapons mod - v2.71.1
		Weapon mainW = MainActor.GetEquippedWeapon()
		if (mainW != None)
			MainActor.UnequipItem(mainW, false, true)
			Utility.Wait(0.1)
		endIf
		Weapon secW = MainActor.GetEquippedWeapon(1)							; in case of visible weapons mod
		if (secW != None)
			MainActor.UnequipItem(secW, false, true)
		endIf
		
		CheckRemoveSecondActorWeapon()
	else
		MainActor = aMainActor
		if (DTSleep_SettingTestMode.GetValue() > 0.0 && DTSleep_DebugMode.GetValue() >= 1.0)
			Debug.Trace("[DTSleep_PlayAAF] caster only play ")
		endIf
	endIf
	
	
	if (MainActor != None && DTSConditionals.IsF4SE && (Debug.GetPlatformName() as bool))
		DTSleepPlaySceneInputLayer = InputEnableLayer.Create()
		
			;         SleepInputLayer                     move,  fight, camSw, look, snk, menu, act, journ, Vats, Favs, run
		DTSleepPlaySceneInputLayer.DisablePlayerControls(true, true, true, false, true, true, true, true, true, true, true)
		
		RegisterForMenuOpenCloseEvent("PipboyMenu")
		Utility.Wait(0.2)
		
		return PlaySequence()
	else
		SceneData.Interrupted = 2  ; force interrupt
		StopAnimationSequence(false, false)
	endIf
	
	return false
endFunction

Function ChangeSettingsDefaultEnabled(bool defaultOn)
	if (AAF_API == None)
		InitAAFAPI()
	endIf
	if (AAF_API != None)
		if (defaultOn)
			AAF_API.ChangeSetting("disable_equipment_handling", "false")
			if (MSceneFadeEnabled)
				AAF_API.ChangeSetting("walk_timeout", "60")
			endIf
		else
			AAF_API.ChangeSetting("disable_equipment_handling", "true")
			if (DTSleep_SettingAAF.GetValueInt() >= 2)
				if (MSceneFadeEnabled)
					AAF_API.ChangeSetting("walk_timeout", "16")
				endIf
			else
				if (MSceneFadeEnabled)
					AAF_API.ChangeSetting("walk_timeout", "5")
				endIf
			endIf
		endIf
	endIf
endFunction

Function CheckRemoveSecondActorWeapon(float waitSecs = 0.07)
	if (SecondActor != None)
		Weapon weapItem = SecondActor.GetEquippedWeapon()
		
		;SecondActor.SetRestrained()										; allow walk v2.73
		if (weapItem != None)
			SecondActor.UnequipItem(weapItem, false, true)
			
		endIf
		weapItem = SecondActor.GetEquippedWeapon(1)							; v2.71 in case of visible weapons mod
		if (weapItem != None)
			SecondActor.UnequipItem(weapItem, false, true)
		endIf
	endIf
	Actor thirdActor = None
	if (SceneData.SecondMaleRole != None)
		thirdActor = SceneData.SecondMaleRole
	elseIf (SceneData.SecondFemaleRole != None)
		thirdActor = SceneData.SecondFemaleRole
	endIf
	
	if (thirdActor != None)
		Weapon weapItem = thirdActor.GetEquippedWeapon()
		
		;thirdActor.SetRestrained()											; allow walk v2.73
		if (weapItem != None)
			thirdActor.UnequipItem(weapItem, false, true)
		endIf
	endif
	if (waitSecs > 0.0)
		Utility.Wait(waitSecs)
	endIf
EndFunction

bool Function CheckEquipActorArmGun(Actor maleActor, Armor armGun)
	int maleActorGender = -1
	
	if (maleActor != None && armGun != None)
		if (maleActor == SceneData.MaleRole)
			if (MyMaleRoleGender < 0)
				MyMaleRoleGender = (SceneData.MaleRole.GetLeveledActorBase() as ActorBase).GetSex()
			endIf
			maleActorGender = MyMaleRoleGender
		elseIf (maleActor == SceneData.SecondMaleRole)
			if (SecondRoleGender < 0)
				SecondRoleGender = (SceneData.SecondMaleRole.GetLeveledActorBase() as ActorBase).GetSex()
			endIf
			if (SecondRoleGender == 0)
				SceneData.SecondMaleRole.EquipItem(armGun, true, true)
			endIf
			return true
		else
			maleActorGender = (maleActor.GetLeveledActorBase() as ActorBase).GetSex()
		endIf
		
		if (maleActorGender == 0)
			SceneData.MaleRole.EquipItem(armGun, true, true)
			return true
		endIf
	endIf
	
	return false
endFunction

Function CheckSceneStart()
	if (SceneData.Interrupted < 0)
		if (MSceneFadeEnabled)
			Game.FadeOutGame(false, true, 0.0, 1.25)
		endIf
		AAFCheckStartCount += 1
		if (AAFCheckStartCount < 3)
			StartTimer(12.0, CheckSceneStartTimerID)
		else
			Debug.Trace("[DTSleep_PlayAAF] AAF did not start - force stop ")
			MySceneStatus = -1
			StopAnimationSequence(true)
		endIf
	endIf
endFunction

Function InitAAFAPI()
	; Create a reference to the AAF API:
	if (AAF_API == None)
		AAF_API = Game.GetFormFromFile(0x00000F99, "AAF.esm") as AAF:AAF_API
	endIf
endFunction

bool Function IsActorLockingEnabled()

	if (IsTestModeOn() && DTSleep_SettingAAF.GetValueInt() >= 2)
		return false
	endIf
	return true
endFunction

bool Function IsTestModeOn()
	if (DTSleep_SettingTestMode.GetValue() >= 1.0)
		if (DTSleep_DebugMode.GetValueInt() >= 3)
			return true
		elseIf (DTSleep_SettingAAF.GetValueInt() >= 2)
			return true
		endIf
	endIf
	return false
endFunction

bool Function PlaySequence()
	
	if (DTSleep_SettingTestMode.GetValue() > 0.0 && DTSleep_DebugMode.GetValue() >= 2.0) ;TODO remove
		Debug.Trace("[DTSleep_PlayAAF] playSequence " + SequenceID + " actors: " + MainActor + ", " + SecondActor + ", (" + SceneData.SecondMaleRole + ", " + SceneData.SecondFemaleRole + ")")
	endIf
	if (MainActor == None || SceneData == None)
		SceneData.Interrupted = 5
		StopAnimationSequence(false, false)
		
		return false
	endIf
	
	int longScene = 0
	int genders = -1		; FM, 0 = MM, 1 = FF
	int otherActor = 0
	
	if (SceneData.SecondMaleRole != None || SceneData.SecondFemaleRole != None)
		otherActor = 1
	endIf
	
	if (SceneData.CompanionInPowerArmor)
		longScene = -1
	elseIf (SequenceID == 705 || SequenceID == 715)
		if ((DTSConditionals as DTSleep_Conditionals).SavageCabbageVers == 1.24)
			longScene = 1
		elseIf ((DTSConditionals as DTSleep_Conditionals).SavageCabbageVers >= 1.25)
			longScene = 2
		endIf
	elseIf (SequenceID == 706 || SequenceID == 707)
		if (otherActor > 0 && (DTSConditionals as DTSleep_Conditionals).SavageCabbageVers >= 1.25)
			longScene = 1
		endIf
	elseIf (SequenceID == 737 || SequenceID == 733 || SequenceID == 742 || SequenceID == 748 || SequenceID == 749)
		if ((DTSConditionals as DTSleep_Conditionals).SavageCabbageVers >= 1.1)
			longScene = 1
			if (SequenceID == 737 && DTSleep_IntimateSceneLen.GetValueInt() >= 3)
				longScene = 2
			endIf
		endIf
	elseIf (SequenceID == 765)
		if ((DTSConditionals as DTSleep_Conditionals).SavageCabbageVers >= 1.22)
			longScene = 2
		elseIf ((DTSConditionals as DTSleep_Conditionals).SavageCabbageVers >= 1.1)
			longScene = 1
		endIf
	elseIf (SequenceID == 701 || SequenceID == 760)
		if ((DTSConditionals as DTSleep_Conditionals).SavageCabbageVers >= 1.20)
			longScene = 1
		endIf
	elseIf (SequenceID == 735)
		if (otherActor == 0 && (DTSConditionals as DTSleep_Conditionals).SavageCabbageVers >= 1.22)
			longScene = 1
		elseIf (otherActor == 1)
			if ((DTSConditionals as DTSleep_Conditionals).SavageCabbageVers >= 1.260)
				longScene = 2
			elseIf ((DTSConditionals as DTSleep_Conditionals).SavageCabbageVers >= 1.250)
				longScene = 1
			endIf
		endIf
	elseIf (SequenceID == 736)
		if ((DTSConditionals as DTSleep_Conditionals).SavageCabbageVers >= 1.22)
			longScene = 2
		elseIf ((DTSConditionals as DTSleep_Conditionals).SavageCabbageVers >= 1.20)
			longScene = 1
		endIf
	elseIf (SequenceID == 741)
		if ((DTSConditionals as DTSleep_Conditionals).SavageCabbageVers >= 1.230)
			longScene = 1
		endIf
	elseIf (SequenceID == 747)
		if ((DTSConditionals as DTSleep_Conditionals).SavageCabbageVers >= 1.240)
			longScene = 1
		endIf
	elseIf (SequenceID == 746)
		if ((DTSConditionals as DTSleep_Conditionals).SavageCabbageVers >= 1.22)
			longScene = 2
		elseIf ((DTSConditionals as DTSleep_Conditionals).SavageCabbageVers >= 1.20)
			longScene = 1
		endIf
		
	elseIf (SequenceID == 752)
		if ((DTSConditionals as DTSleep_Conditionals).SavageCabbageVers >= 1.22)
			longScene = 2
		elseIf ((DTSConditionals as DTSleep_Conditionals).SavageCabbageVers >= 1.20)
			longScene = 1
		endIf
	elseIf (SequenceID == 754)
		if ((DTSConditionals as DTSleep_Conditionals).SavageCabbageVers >= 1.29)			; v2.84
			longScene = 2
		elseIf ((DTSConditionals as DTSleep_Conditionals).SavageCabbageVers >= 1.28)		; v2.79
			longScene = 1
		endIf
	elseIf (SequenceID == 755)
		if ((DTSConditionals as DTSleep_Conditionals).SavageCabbageVers >= 1.29)			; v2.84
			longScene = 1
		endIf
	elseIf (SequenceID == 758)
		if (otherActor > 0 && (DTSConditionals as DTSleep_Conditionals).SavageCabbageVers >= 1.270)
			longScene = 2
		elseIf ((DTSConditionals as DTSleep_Conditionals).SavageCabbageVers >= 1.250)
			longScene = 1
		endIf	
	elseIf (SequenceID == 759)
		if ((DTSConditionals as DTSleep_Conditionals).SavageCabbageVers >= 1.22)
			longScene = 1
		endIf
	elseIf (SequenceID == 761)
		if (otherActor > 0)
			if ((DTSConditionals as DTSleep_Conditionals).SavageCabbageVers >= 1.29)		; v2.84
				longScene = 1
			endIf
		elseIf ((DTSConditionals as DTSleep_Conditionals).SavageCabbageVers >= 1.23)
			longScene = 1
		endIf
	elseIf (SequenceID >= 763 && SequenceID <= 764)
		if ((DTSConditionals as DTSleep_Conditionals).SavageCabbageVers >= 1.23)
			longScene = 2
		elseIf ((DTSConditionals as DTSleep_Conditionals).SavageCabbageVers >= 1.22)
			longScene = 1
		endIf
	elseIf (SequenceID == 766)
		if ((DTSConditionals as DTSleep_Conditionals).SavageCabbageVers >= 1.22)
			longScene = 2
		elseIf ((DTSConditionals as DTSleep_Conditionals).SavageCabbageVers >= 1.20)
			longScene = 1
		endIf
	elseIf (SequenceID >= 767 && SequenceID <= 768 && SceneData.SecondMaleRole == None)
		if ((DTSConditionals as DTSleep_Conditionals).SavageCabbageVers >= 1.23)
			longScene = 1
		endIf
	elseIf (SequenceID == 768 && SceneData.SecondMaleRole != None)
		if ((DTSConditionals as DTSleep_Conditionals).SavageCabbageVers >= 1.20)
			longScene = 1
		endIf
	elseIf (SequenceID == 774)
		if ((DTSConditionals as DTSleep_Conditionals).SavageCabbageVers >= 1.23)
			longScene = 2
		elseIf ((DTSConditionals as DTSleep_Conditionals).SavageCabbageVers >= 1.22)
			longScene = 1
		endIf
	elseIf (SequenceID == 775)
		if ((DTSConditionals as DTSleep_Conditionals).SavageCabbageVers >= 1.250)
			longScene = 1
		endIf
	elseIf (SequenceID == 781)
		if ((DTSConditionals as DTSleep_Conditionals).SavageCabbageVers >= 1.240)
			if ((DTSConditionals as DTSleep_Conditionals).SavageCabbageVers >= 1.29)
				longScene = 2
			else
				longScene = 1
			endIf
		endIf
	elseIf (SequenceID == 782)											; v2.79
		if ((DTSConditionals as DTSleep_Conditionals).SavageCabbageVers >= 1.280)
			longScene = 1
		endIf
	elseIf (SequenceID == 783)
		if ((DTSConditionals as DTSleep_Conditionals).SavageCabbageVers >= 1.290)		; v2.84
			longScene = 2
		elseIf ((DTSConditionals as DTSleep_Conditionals).SavageCabbageVers >= 1.280)
			longScene = 1
		endIf
	elseIf (SequenceID >= 793 && SequenceID <= 794)										; v2.84
		if ((DTSConditionals as DTSleep_Conditionals).SavageCabbageVers >= 1.290)
			longScene = 1
		endIf
	elseIf (SequenceID == 795)
		if ((DTSConditionals as DTSleep_Conditionals).SavageCabbageVers >= 1.21)
			longScene = 1
		endIf
	elseIf (SequenceID == 796)
		if ((DTSConditionals as DTSleep_Conditionals).SavageCabbageVers >= 1.270)				; v2.77
			longScene = 2
		elseIf ((DTSConditionals as DTSleep_Conditionals).SavageCabbageVers >= 1.250)
			longScene = 1
		endIf
	elseIf (SequenceID == 785)
		if ((DTSConditionals as DTSleep_Conditionals).SavageCabbageVers >= 1.21)
			longScene = 1
		endIf
	
	elseIf (DTSleep_IntimateSceneLen.GetValueInt() >= 3)
		longScene = 1
	endIf
	
	
	if (SceneData.SameGender && !SceneData.HasToyEquipped)
		genders = SceneData.MaleRoleGender
	endIf
	
	InitAAFAPI()
	
	MySceneStatus = 0
	
	if (AAF_API == None)
		Debug.Trace("[DTSleep_PlayAAF] AAF API not found! ")
		MySceneStatus = 5
		SceneData.Interrupted = 5
		MySceneStartErrorCount += 1
		
		StopAnimationSequence(false, false)
		
		return false
	else
	
		bool mActorReady = true
		bool fActorReady = true
		bool forceEVB = true
		if (SceneData.MaleRole.HasKeyWord(AAF_API.AAF_ActorLocked) || SceneData.MaleRole.HasKeyword(AAF_API.AAF_ActorBusy))
			mActorReady = false
			
		elseIf (IsActorLockingEnabled())
			
			mActorReady = AAF_API.SetActorLocked(SceneData.MaleRole, true)
		endIf
		if (SceneData.FemaleRole != None)
			if (SceneData.FemaleRole.HasKeyWord(AAF_API.AAF_ActorLocked) || SceneData.FemaleRole.HasKeyword(AAF_API.AAF_ActorBusy))
				fActorReady = false
				
			elseIf (IsActorLockingEnabled())
				fActorReady = AAF_API.SetActorLocked(SceneData.FemaleRole, true)
			endIf
		endIf
		if (SceneData.AnimationSet == 7 && DTSleep_SettingUseBT2Gun.GetValueInt() > 0)
			if ((DTSConditionals as DTSleep_Conditionals).SavageCabbageVers >= 1.10)
				forceEVB = false
			endIf
		endIf
		
		if (mActorReady && fActorReady)
		
			SceneData.Interrupted = -1  ; mark init
			
			; disable undress
			ChangeSettingsDefaultEnabled(false)
			
			; check gender - not necessary for usage here
			;if (SceneData.SameGender && SceneData.HasToyEquipped && SceneData.MaleRoleGender == 1)
			;	if (!SceneData.MaleRole.HasKeyword(AAF_API.AAF_GenderOverride_Male))
			;		SceneData.MaleRole.AddKeyword(AAF_API.AAF_GenderOverride_Male)
			;	endIf
			;endIf
			
			if (SequenceID < 600)
				if (SequenceID >= 546 && SequenceID <= 549)
					PlayAASequence()
				else
					PlayAtomicScene()
				endIf
			;elseIf (SequenceID >= 600 && SequenceID < 660)					; v2.73 Leito using AAC now
			;	PlaySequenceLeitoStages()
			;elseIf (SequenceID < 670)
			;	PlaySequenceLeitoStrongStages()
			else
				MySeqStagesArray = DTSleep_AACcatScript.GetSeqCatArrayForSequenceID(SequenceID, longScene, genders, otherActor, forceEVB)
				
				if (MySeqStagesArray.Length == 1)
					
					string posID = MySeqStagesArray[0].PositionID
					if (SecondActor == None)
						if (SceneData.MaleRole != None && MainActor == SceneData.MaleRole)
							posID = MySeqStagesArray[0].PositionOrigID
						endIf
					endIf
					
					Armor armGunA = None
					Armor armGunB = None
					
					if (MaleBodyMorphEnabled)
						;Debug.Trace("[DTSleep_PlayAAF] setting morph " + MySeqStagesArray[0].ArmorNudeAGun + " on actor " + SceneData.MaleRole)
						; updated to include morph angle value - v2.73
						SetMorphForActor(SceneData.MaleRole, -1, MySeqStagesArray[0].ArmorNudeAGun, MySeqStagesArray[0].MorphAngleA)
						if (SceneData.SecondMaleRole != None && MySeqStagesArray[0].ArmorNudeBGun >= 0)
							SetMorphForActor(SceneData.SecondMaleRole, -1, MySeqStagesArray[0].ArmorNudeBGun, MySeqStagesArray[0].MorphAngleB)
						endIf
					else 
						int ngValA = MySeqStagesArray[0].ArmorNudeAGun
						if (ngValA != 0 && MySeqStagesArray[0].MorphAngleA > 0.0 && MySeqStagesArray[0].MorphAngleA < 0.27)
							; use forward if minor morph   v2.73
							ngValA = 0
						endIf
						armGunA = GetArmorNudeGun(ngValA)
						if (SceneData.SecondMaleRole != None && MySeqStagesArray[0].ArmorNudeBGun >= 0)
							armGunB = GetArmorNudeGun(MySeqStagesArray[0].ArmorNudeBGun)
						endIf
					endIf
					
					PlaySingleStageScene(posID, MySeqStagesArray[0].StageTime, SceneData.MaleMarker, armGunA, armGunB)
					
				elseIf (MySeqStagesArray.Length > 1)
					PlayAASequence()
				else
					Debug.Trace("[DTSleep_PlayAAF] invalid sequence ID " + SequenceID)
				
					if (MSceneFadeEnabled)
						Game.FadeOutGame(false, true, 0.0, 1.25)
					endIf
					MySceneStatus = 9
					SceneData.Interrupted = 9
					StopAnimationSequence(false, false)
					
					return false
				endIf
			endIf
		else
			Debug.Trace("[DTSleep_PlayAAF] actors locked - cancel scene")
			
			if (MSceneFadeEnabled)
				Game.FadeOutGame(false, true, 0.0, 1.25)
			endIf
			MySceneStatus = 10
			SceneData.Interrupted = 10
			StopAnimationSequence(false, false)
			
			return false
		endIf
	endIf
	
	return true
endFunction

Function StopAnimationSequence(bool canceledScene = false, bool startedOK = true)

	if (MySceneStatus == 4 || !self.IsRunning())
		return
	endIf
	if (MySceneStatus < 0)
		; never started
		
		SceneData.Interrupted = 50
		Utility.Wait(0.23)
	elseIf (!canceledScene && MySceneStatus == 1 && SceneData.Interrupted <= 0)
		; started - let finish
		return
	endIf
	
	MySceneStatus = 4
	
	CancelTimer(CheckSceneStartTimerID)
	
	if (AAF_API != None)
		if (DTSleep_SettingTestMode.GetValue() > 0.0 && DTSleep_DebugMode.GetValue() >= 2.0) ;TODO remove
			Debug.Trace("[DTSleep_PlayAAF] call API stop scene for " + MainActor)
		endIf
		AAF_API.StopScene(MainActor, -1)								; v2.74.1 added levels default -1
		if (!canceledScene && SceneData.Interrupted <= 0)
			Utility.Wait(0.5)
		endIf
	endIf
	
	int waitOnEndCount = 0
	while (MySceneStatus == 2 && SceneData.Interrupted <= 0 && waitOnEndCount < 30)
		Utility.Wait(0.2)
		waitOnEndCount += 1
	endWhile
	
	
	if (DTSleep_SettingTestMode.GetValue() > 0.0 && DTSleep_DebugMode.GetValue() >= 2.0) ;TODO remove
		Debug.Trace("[DTSleep_PlayAAF] StopAnimationSeq... waitOnEndCount: " + waitOnEndCount + ", isCanceled? " + canceledScene + "/" + SceneData.Interrupted)
	endIf
	
	UnregisterForMenuOpenCloseEvent("PipboyMenu")
	Utility.Wait(0.30)
	
	if (AAF_API != None)
		
		UnregisterForCustomEvent(AAF_API, "OnAnimationStart")
		UnregisterForCustomEvent(AAF_API, "OnAnimationStop")
		
	endIf
		;AAF_API.SetActorLocked(MainActor, false)
		;if (SecondActor != None)
		;	AAF_API.SetActorLocked(MainActor, false)
		;endIf
	
	if (AAF_API != None && SceneData.MaleRole != None)
	
		if (SceneData.MaleRole.HasKeyWord(AAF_API.AAF_ActorLocked))
			AAF_API.SetActorLocked(SceneData.MaleRole, false)
			
			if (SceneData.MaleRole.HasKeyWord(AAF_API.AAF_ActorLocked))
				Debug.Trace("[DTSleep_PlayAAF] Failed to remove actor lock!!!")
			endIf
		endIf
		if (SceneData.FemaleRole != None && SceneData.FemaleRole.HasKeyWord(AAF_API.AAF_ActorLocked))
			AAF_API.SetActorLocked(SceneData.FemaleRole, false)
			
		endIf
		
		; check gender
		if (SceneData.MaleRole.HasKeyword(AAF_API.AAF_GenderOverride_Male))
			SceneData.MaleRole.RemoveKeyword(AAF_API.AAF_GenderOverride_Male)
		endIf
	endIf
	
	; this must go before marking scene done (5)
	if (SceneData.AnimationSet >= 5)
		if (SceneData.MaleRole != None)
			if ((SceneData.MaleRole.GetLeveledActorBase() as ActorBase).GetSex() == 0)
				RemoveLeitoGuns(SceneData.MaleRole)
			endIf
			if (SceneData.SecondMaleRole != None)
				RemoveLeitoGuns(SceneData.SecondMaleRole)
			endIf
			if (SceneData.SameGender && SceneData.MaleRoleGender == 0 && SceneData.FemaleRole != None)
				RemoveLeitoGuns(SceneData.FemaleRole)
			endIf
		else
			Debug.Trace("[DTSleep_PlayAAF] no SceneData.MaleRole actor!!")
		endIf
	endIf
	
	MySceneStatus = 5	; now we are done
	
	Utility.Wait(0.50)
	
	
	if (DTSleepPlaySceneInputLayer != None)
		DTSleepPlaySceneInputLayer.EnablePlayerControls()
		Utility.Wait(0.05)
		DTSleepPlaySceneInputLayer.Delete()
	endIf
	
	MainActor = None
	SecondActor = None
	DTSleepPlaySceneInputLayer = None
	CurrentSingleDuration = -2.0
	
	if (startedOK)
		Var[] kArgs = new Var[4]
		kArgs[0] = SequenceID
		kArgs[1] = canceledScene
		kArgs[2] = MySceneStatus
		kArgs[3] = MySceneStartErrorCount
		SendCustomEvent("SleepIntAAFPlayDoneEvent", kArgs)
	endIf
	
	StartTimer(3.3, ChangeSettingsAndStopTimerID) 
endFunction

Function PlaySingleStageScene(string positionStr, float duration, ObjectReference locObjRef, Armor armGun = None, Armor arm2Gun = None)

	CurrentSingleDuration = duration
	Actor[] actors = New Actor [2]
	actors[0] = SceneData.FemaleRole													
	actors[1] = SceneData.MaleRole
	if (SceneData.SecondMaleRole != None)
		actors.Add(SceneData.SecondMaleRole)
	endIf
	if (SceneData.SecondFemaleRole != None)
		actors.Add(SceneData.SecondFemaleRole)
	endIf
	if (SceneData.CompanionInPowerArmor || SceneData.IsCreatureType == 3)	; v2.17 - added synth
		actors = New Actor [1]
		actors[0] = MainActor
	endIf
	
	; can only equip on player before start scene
	;
	if (armGun != None)
		if (SceneData.MaleRoleGender == 0)
			CheckEquipActorArmGun(SceneData.MaleRole, armGun)
			if (SceneData.MaleRole == PlayerRef)
				Utility.Wait(0.33)
			endIf
		endIf
		if (SceneData.SecondMaleRole != None && arm2Gun != None)
			CheckEquipActorArmGun(SceneData.SecondMaleRole, arm2Gun)
		endIf
	endIf

	AAF:AAF_API:SceneSettings aafSettings = AAF_API.GetSceneSettings()

	aafSettings.duration = duration
	aafSettings.position = positionStr
	aafSettings.locationObject = locObjRef
	if (MSceneFadeEnabled)
		aafSettings.skipWalk = true
	endIf

	RegisterForCustomEvent(AAF_API, "OnAnimationStart")
	RegisterForCustomEvent(AAF_API, "OnAnimationStop") 
	
	MyStartSeqID = positionStr
	AAF_API.StartScene(actors, aafSettings)
	
	StartTimer(20.0, CheckSceneStartTimerID)

endFunction

; *****************
; Atomic Lust

Function PlayAtomicScene()

	ObjectReference objRef = SecondActor
	Armor armGun = None
	int armGunKind = 0
	float timer = 33.5
	
	bool fullID = false
	
	String positionStr = CreateSeqPositionStr(SequenceID, 1)
	
	if (SceneData.MaleMarker != None)
		objRef = SceneData.MaleMarker
	elseIf (SceneData.FemaleMarker != None)
		objRef = SceneData.FemaleMarker
	elseIf (SequenceID == 501)
		objRef = BedInSceneRef
		armGunKind = -1
	elseIf (SequenceID == 503 || SequenceID == 504 || SequenceID == 509 || SequenceID == 541)
		objRef = BedInSceneRef
		if (SceneData.SameGender && SceneData.MaleRoleGender == 0)
			armGunKind = 0
		elseIf (SequenceID == 509)
			armGunKind = 1
		endIf
	endIf
	if (SequenceID >= 505 && SequenceID <= 510)
		armGunKind = 0
	elseIf (SequenceID >= 540 && SequenceID <= 541)
		objRef = MainActor
		if (MainActor == SceneData.MaleRole)
			armGunKind = 0
		endIf
	elseIf (SequenceID == 548)
		timer = 18.0
	elseIf (SequenceID >= 550 && SequenceID <= 552)
		armGunKind = 0
	elseIf (SequenceID >= 560)
		if (SequenceID == 563 || SequenceID == 599)					; v2.74.1 also 599
			armGunKind = 1
		else
			armGunKind = 0
		endIf
	endIf
	
	if (MaleBodyMorphEnabled && armGunKind >= 0)
		SetMorphForActor(SceneData.MaleRole, -1, armGunKind, 1.0)
	elseIf (armGunKind >= 0)
		armGun = GetArmorNudeGun(armGunKind)
	endIf

	PlaySingleStageScene(positionStr, timer, objRef, armGun)
	
endFunction

; *****************************************
; stage Sequence play functions
;

AStageItem[] Function CreateSeqArrayForID(int id, int count, Armor armItem, bool fullStr = true)
	AStageItem[] seqArr = new AStageItem[count]
	int i = 0
	string baseStr = CreateSeqBaseStr(fullStr)
	
	while (i < count)
		seqArr[i] = new AStageItem
		seqArr[i].StageIDStr = baseStr + CreateSeqIDStageStr(id, (i + 1))
		seqArr[i].NudeArmorGun = armItem
		seqArr[i].NudeArmorGunM2 = armItem
		i += 1
	endWhile
	
	return seqArr
endFunction

string Function CreateSeqBaseStr(bool fullStr = true)
	string baseStr = "DTSIX_"
	if (fullStr)
		if (SequenceID >= 540 && SequenceID <= 541)
			if (SceneData.MaleRole == MainActor)
				baseStr = "DTSIXM_"
			else
				baseStr = "DTSIXF_"
			endIf
		elseIf (SequenceID == 741)
			baseStr = "DTSIXF_"
		elseIf (SequenceID == 940)
			baseStr = "DTSIXF_"
		
		elseIf (SceneData.SameGender && SceneData.MaleRoleGender == 1)
			if (SceneData.SecondMaleRole != None)
				baseStr = "DTSIXFMF_"
			else
				baseStr = "DTSIXFF_"
			endIf
		elseIf (SceneData.SameGender && SceneData.MaleRoleGender == 0)
			baseStr = "DTSIXMM_"
		elseIf (SceneData.IsUsingCreature)
			if (SequenceID >= 650 && SequenceID < 670)
				baseStr = "DTSIXSM_"
			elseIf (SequenceID >= 750 && SequenceID <= 770)
				baseStr = "DTSIXSM_"
			else
				baseStr = "DTSIXFC_"
			endIf
		elseIf (SceneData.SecondMaleRole != None) 
			baseStr = "DTSIXFMM_"
		elseIf (SceneData.SecondFemaleRole != None)
			baseStr = "DTSIXFMF_"
		
		endIf
	endIf
	
	return baseStr
endFunction

string Function CreateSeqIDStageStr(int id, int stageNum)
	return id + "_S" + stageNum
endFunction

string Function CreateSeqPositionStr(int seqId, int stageNum)
	bool fullStr = true
	bool fullID = false
	
	if (seqId >= 500 && seqId < 560)
		fullStr = false
		if (seqId == 503 || seqId == 504 || seqId == 540 || seqId == 541)	;v2.19 - added 541
			fullStr = true
		elseIf (seqId >= 550 && seqId <= 552)
			fullStr = true
		elseIf (seqId >= 560)
			fullStr = true
		endIf
	endIf
	
	return CreateSeqBaseStr(fullStr) + CreateSeqIDStageStr(seqId, stageNum)
endFunction

; 0 = normal, 1 = up, 2 = down
Armor Function GetArmorNudeGun(int kind)
	;Debug.Trace("[DTSleep_PlayAAF] GetArmorNudeGun start kind = " + kind)
	if (kind < 0)
		return None
	endIf
	Armor gun = None
	if (!Debug.GetPlatformName() as bool)
		return None
	endIf
	if (SceneData.MaleBodySwapEnabled <= 0)
		return None
	endIf

	int evbVal = DTSleep_SettingUseLeitoGun.GetValueInt()
	int bt2Val = DTSleep_SettingUseBT2Gun.GetValueInt()
	int synthVal = DTSleep_SettingSynthHuman.GetValueInt()
	
	if (SceneData.IsCreatureType == 1)
		evbVal = 2
		bt2Val = -1
	elseIf (SceneData.AnimationSet == 8)		; BodyTalk2 incompatible
		bt2Val = -1
		synthVal = 1
	elseIf (SceneData.IsCreatureType >= 6)
		return None
		
	elseIf (DTSConditionals.IsUniquePlayerMaleActive && evbVal > 0 && SceneData.MaleRole == PlayerRef)
		bt2Val = -1
	;elseIf (SceneData.AnimationSet == 6 && evbVal > 0)					; no longer prefer evb --- v2.73
	;	bt2Val = -1
	endIf
	
	if (evbVal <= 0 && bt2Val <= 0)
		return None
	endIf
	
	if (kind > 0 && evbVal == 1)
		kind = 0
	elseIf (SequenceID >= 503 && SequenceID < 551 && bt2Val > 0)
		kind = 0
	endIf
	
	;Debug.Trace("[DTSleep_PlayAAF] GetArmorNudeGun kind = " + kind)
	
	if ((evbVal > 0 || bt2Val > 0) && SceneData.IsCreatureType != 2)
	
		if (SceneData.MaleRole == PlayerRef || SceneData.FemaleRole == SecondActor)
			if (evbVal > 0 && DTSConditionals.IsUniquePlayerMaleActive)
				kind += 3
			;else
				;return DTSleep_NudeSuitPlayerUp
			endIf
		elseIf (evbVal > 0 && DTSConditionals.IsUniqueFollowerMaleActive)
			if (SceneData.MaleRoleCompanionIndex > 0)
				kind += (3 * SceneData.MaleRoleCompanionIndex)
			endIf
		endIf
		
		if (kind >= 0)
			if (SceneData.IsCreatureType == 4)
				if (synthVal >= 2 && DTSleep_BT2GunList.GetSize() > (kind + 3))
					gun = DTSleep_BT2GunList.GetAt(kind + 3) as Armor
				elseIf (DTSleep_LeitoGunSynthList != None && DTSleep_LeitoGunSynthList.GetSize() > kind)
					gun = DTSleep_LeitoGunSynthList.GetAt(kind) as Armor
				endIf
			elseIf (bt2Val <= 0 && evbVal > 0 && DTSleep_LeitoGunList != None && DTSleep_LeitoGunlist.GetSize() > kind)
				; v2.74.1 fix changed conditional <= 0 since zero means off and added condtion, evbVal > 0, to ensure something is on
				gun = DTSleep_LeitoGunList.GetAt(kind) as Armor
			elseIf (bt2Val > 0 && DTSleep_BT2GunList != None && DTSleep_BT2GunList.GetSize() > kind)
				; v2.74.1 fix bt2Val cannot be zero
				; Atomic Lust animates the skeleton for BodyTalk so limit to kind = 0
				if (kind == 0 || SceneData.AnimationSet != 5)
					gun = DTSleep_BT2GunList.GetAt(kind) as Armor
				endIf
			endIf
		endIf
	endIf
	
	return gun
endFunction

String Function GetArmorNudeMorphString(int kind)
	if (kind == 1)
		return "Erection Up"
	elseIf (kind == 2)
		return "Erection Down"
	endIf
	if (SceneData.IsCreatureType == 5 || SceneData.IsCreatureType == 1)
		return "CErection"
	endIf
	return "Erection"
endFunction

int Function GetArmorNudeKindForGun(Armor gunArmor)
	if (gunArmor != None)
		int i = 0
		int len = DTSleep_BT2GunList.GetSize()
		int result = -1
		
		while (i < len)
			if (gunArmor == (DTSleep_BT2GunList.GetAt(i) as Armor))
				result = i
				i = 100
			endIf
			
			i += 1
		endWhile
		
		return result
	endIf
	
	return -1
endFunction

Function PlayAASequence()
	Actor otherActor = SceneData.SecondMaleRole
	if (SceneData.SecondFemaleRole != None)
		otherActor = SceneData.SecondFemaleRole
	endIf

	PlayAASequenceLists(SceneData.MaleRole, SceneData.FemaleRole, otherActor)
endFunction

Function PlayAASequenceLists(Actor mActor, Actor fActor, Actor oActor)

	if (MySeqStagesArray.Length > 0)
	
		if (MaleBodyMorphEnabled)
			;Debug.Trace("[DTSleep_PlayAAF] setting morph " + MySeqStagesArray[0].ArmorNudeAGun + " on actor " + mActor)
			SetMorphForActor(mActor, -1, MySeqStagesArray[0].ArmorNudeAGun, MySeqStagesArray[0].MorphAngleA)				; updated with angle v2.73
			
		else
			int ngValA = MySeqStagesArray[0].ArmorNudeAGun
			if (ngValA != 0 && MySeqStagesArray[0].MorphAngleA > 0.0 && MySeqStagesArray[0].MorphAngleA < 0.27)
				; use forward if minor morph   v2.73
				ngValA = 0
			endIf
			Armor armS1 = GetArmorNudeGun(ngValA)
			
			if (mActor != None && armS1 != None)
				; can only equip on player before start scene
				if (mActor == PlayerRef  && MySeqStagesArray.Length > 1)
					if (MySeqStagesArray[0].ArmorNudeAGun == 1 && MySeqStagesArray[0].ArmorNudeAGun != 1)
						armS1 = GetArmorNudeGun(MySeqStagesArray[1].ArmorNudeAGun)
					endIf
				endIf
				CheckEquipActorArmGun(mActor, armS1)
				if (SceneData.MaleRole == PlayerRef)
					Utility.Wait(0.33)
				endIf
			endIf
		endIf 
		
		Actor[] actors = new Actor[2]
		if (oActor != None)
			actors = new Actor[3]
			actors[2] = oActor
			if (oActor != None && oActor == SceneData.SecondMaleRole && MySeqStagesArray[0].ArmorNudeBGun >= 0)
				if (MaleBodyMorphEnabled)
					;Debug.Trace("[DTSleep_PlayAAF] setting morph " + stage.ArmorNudeAGun + " on actor " + oActor)
					SetMorphForActor(oActor, -1, MySeqStagesArray[0].ArmorNudeBGun, MySeqStagesArray[0].MorphAngleB)			; updated with angle v2.73
				else
					int ngValB = MySeqStagesArray[0].ArmorNudeAGun
					if (ngValB != 0 && MySeqStagesArray[0].MorphAngleB > 0.0 && MySeqStagesArray[0].MorphAngleB < 0.27)
						; use forward if minor morph   v2.73
						ngValB = 0
					endIf
					Armor armS1 = GetArmorNudeGun(ngValB)
					CheckEquipActorArmGun(SceneData.SecondMaleRole, armS1)
				endIf
			endIf
		endIf

		actors[1] = mActor   ; place 2nd position											
		actors[0] = fActor
		if (SceneData.CompanionInPowerArmor || SceneData.IsCreatureType == 3)
			; remove 2nd actor from scene
			actors = New Actor [1]
			actors[0] = MainActor
		endIf
		
		AAF:AAF_API:SceneSettings aafSettings = AAF_API.GetSceneSettings()

		aafSettings.duration = 10.0
		aafSettings.position = MySeqStagesArray[0].PositionID
		if (SecondActor == None)
			if (SceneData.MaleRole != None && MainActor == SceneData.MaleRole)
				aafSettings.position = MySeqStagesArray[0].PositionOrigID
			endIf
		endIf
		;aafSettings.position = CreateSeqPositionStr(SequenceID, 1)
		if (MSceneFadeEnabled)
			aafSettings.skipWalk = true
		endIf
		
		if (SceneData.MaleMarker != None)
			aafSettings.locationObject = SceneData.MaleMarker
		elseIf (SceneData.FemaleMarker != None)
			aafSettings.locationObject = SceneData.FemaleMarker
		else
			aafSettings.locationObject = SecondActor
		endIf
		if (MySeqStagesArray[0].StageTime > 0.0)
			aafSettings.duration = MySeqStagesArray[0].StageTime
		endIf
		
		if (SequenceID >= 682 && SequenceID < 700 && aafSettings.locationObject != None)
			; these Leito chair scenes play backward in AAF  (??)
			aafSettings.locationObject.SetAngle(0.0, 0.0, 180.0 + aafSettings.locationObject.GetAngleZ())
		endIf
		
		if (DTSleep_SettingTestMode.GetValue() > 0.0 && DTSleep_DebugMode.GetValue() >= 1.0)
			;TODO remove
			Debug.Trace("[DTSleep_PlayAAF_Seq] start AASeq position ID " + aafSettings.position + " at Loc " + aafSettings.locationObject + " with sceneLen " + DTSleep_IntimateSceneLen.GetValueInt() + " and scene count " + MySeqStagesArray.Length + " and actor count " + actors.Length)
		endIf
		RegisterForCustomEvent(AAF_API, "OnAnimationStart")
		RegisterForCustomEvent(AAF_API, "OnAnimationStop")
	
		MyStartSeqID = aafSettings.position
		
		AAF_API.StartScene(actors, aafSettings)
		; will continue on Event
		
		StartTimer(20.0, CheckSceneStartTimerID)
	endIf
endFunction

Function PlayAAContinuedSequence(float waitSecs)

	if (MySeqStagesArray == None)
		Utility.Wait(waitSecs)
		StopAnimationSequence()
		return
	endIf

	int seqCount = 1
	int seqTotalCount = 0
	int seqLen = MySeqStagesArray.Length
	int pingPongCount = DTSleep_IntimateSceneLen.GetValueInt() - 1
	float loopWaitSecs = waitSecs
	float startSecs = 9.1
	if (MySeqStagesArray[0].StageTime > 0.0)
		startSecs = MySeqStagesArray[0].StageTime
	endIf
	if (seqLen <= 2)
		pingPongCount = 0
	elseIf (startSecs <= 13.0 && waitSecs < 13.0 && seqLen <= 5)
		pingPongCount += 1
	endIf
	int armGunLastIndex = MySeqStagesArray[0].ArmorNudeAGun
	int armGunM2LastIndex = MySeqStagesArray[0].ArmorNudeBGun
	
	;Debug.Trace("[DTSleep_PlayAAF] play AAContinued; Interrupted? " + SceneData.Interrupted)
	
	Utility.Wait(startSecs - 0.8)
	
	while (seqCount < seqLen && SceneData.Interrupted <= 0)
	
		; armor?
		if (seqCount >= 1 && seqCount < seqLen - 1)
			
			int ngValA = MySeqStagesArray[0].ArmorNudeAGun
			
			if (MaleBodyMorphEnabled)
				
				SetMorphForActor(SceneData.MaleRole, armGunLastIndex, MySeqStagesArray[seqCount].ArmorNudeAGun, MySeqStagesArray[seqCount].MorphAngleA)
				if (SceneData.SecondMaleRole != None)
					SetMorphForActor(SceneData.SecondMaleRole, armGunM2LastIndex, MySeqStagesArray[seqCount].ArmorNudeBGun, MySeqStagesArray[seqCount].MorphAngleB)
				endIf
			else
				
				if (ngValA != 0 && MySeqStagesArray[seqCount].MorphAngleA > 0.0 && MySeqStagesArray[seqCount].MorphAngleA < 0.27)
					; use forward if minor morph   v2.73
					ngValA = 0
				endIf

				if (ngValA != armGunLastIndex)
					Armor armGun = GetArmorNudeGun(ngValA)
					if (SceneData.MaleRole != PlayerRef && SceneData.MaleRoleGender == 0)
					
						CheckEquipActorArmGun(SceneData.MaleRole, armGun)
					endIf
				endIf
				if (SceneData.SecondMaleRole != None && MySeqStagesArray[seqCount].ArmorNudeBGun != armGunM2LastIndex)
					Armor armGunM2 = GetArmorNudeGun(MySeqStagesArray[seqCount].ArmorNudeBGun)
					CheckEquipActorArmGun(SceneData.SecondMaleRole, armGunM2)
				endIf
			endIf
			
			armGunLastIndex = ngValA
			armGunM2LastIndex = MySeqStagesArray[seqCount].ArmorNudeBGun
		endIf
		
		; wait time
		if (MySeqStagesArray[seqCount].StageTime > 0.0)
			loopWaitSecs = MySeqStagesArray[seqCount].StageTime
		elseIf (seqCount == seqLen - 1)
			loopWaitSecs = 5.75
		elseIf (seqCount == 0)
			loopWaitSecs = startSecs
		else
			loopWaitSecs = waitSecs
		endIf
		
		if (seqCount > 0)
			;PlayPosition(CreateSeqPositionStr(SequenceID, MySeqStagesArray[seqCount].StageNum), loopWaitSecs)
			PlayPosition(MySeqStagesArray[seqCount].PositionID, loopWaitSecs)
		endIf
		
		if (pingPongCount > 0 && seqCount == (seqLen - 2))
			pingPongCount -= 1
			seqCount = seqLen - 4
		endIf
		
		Utility.Wait(loopWaitSecs - 0.2)

		seqCount += 1
		seqTotalCount += 1
	endWhile
	
	MySceneStatus = 2
	StopAnimationSequence()
endFunction

Function PlayPosition(string posStr, float duration)
	
	;Debug.Trace("[DTSleep_PlayAAF] PlayPosition " + posStr)
	AAF:AAF_API:PositionSettings posSettings = AAF_API.GetPositionSettings()
	posSettings.position = posStr
	posSettings.duration = (duration + 0.2)
	
	AAF_API.ChangePosition(MainActor, posSettings)
endFunction

; no longer used --- v2.73
Function PlaySequenceLeitoStages()
	;Debug.Trace("[DTSleep_PlayAAF_Seq] playSequence " + SequenceID)
	
	int seqLen = 4
	if (DTSleep_IntimateSceneLen.GetValueInt() >= 2)
		seqLen = 6
	endIf
	
	Armor gunStart = GetArmorNudeGun(0)
	AStageItem[] seqArr = CreateSeqArrayForID(SequenceID, seqLen, gunStart, false)
	AStageItem[] seqExtraArr = CreateSeqArrayForID(SequenceID, 4, gunStart, false)
	

	if (SequenceID < 650)
		; bed sequences
		if (SceneData.MaleRole && SceneData.FemaleRole)
			if (SequenceID <= 600)
				if (SceneData.MaleRole != PlayerRef)
					gunStart = GetArmorNudeGun(1)
					seqExtraArr = CreateSeqArrayForID(601, 4, gunStart, false)
					seqArr = CreateSeqArrayForID(601, 4, gunStart, false)
				endIf
			elseIf (SequenceID == 601)
				gunStart = GetArmorNudeGun(1)
				seqExtraArr = CreateSeqArrayForID(601, 4, gunStart, false)
				seqArr = CreateSeqArrayForID(601, 4, gunStart, false)

			elseIf (SequenceID == 603)
				; TODO: chance for doggy mix??
				
			elseIf (SequenceID == 604)
				if (SceneData.MaleRole != PlayerRef)
					;gunStart = GetArmorNudeGun(0)
					seqArr[1].NudeArmorGun = GetArmorNudeGun(1)
					seqExtraArr[1].NudeArmorGun = GetArmorNudeGun(1)
				endIf
			elseIf (SequenceID == 605)
				; cowgirl
				;gunStart = GetArmorNudeGun(0)
				seqExtraArr = CreateSeqArrayForID(607, 4, gunStart, false)

			elseIf (SequenceID >= 606 && SequenceID <= 607)
				seqArr[0].NudeArmorGun = GetArmorNudeGun(2)
				seqArr[1].NudeArmorGun = GetArmorNudeGun(2)
				seqArr[2].NudeArmorGun = GetArmorNudeGun(2)
				seqArr[3].NudeArmorGun = GetArmorNudeGun(2)
				seqExtraArr = CreateSeqArrayForID(607, 4, GetArmorNudeGun(2), false)

			elseIf (SequenceID >= 608 && SequenceID <= 609)
				seqArr[0].NudeArmorGun = GetArmorNudeGun(1)
				seqArr[1].NudeArmorGun = GetArmorNudeGun(1)
				seqArr[2].NudeArmorGun = GetArmorNudeGun(1)
				seqArr[3].NudeArmorGun = GetArmorNudeGun(1)
				seqExtraArr = CreateSeqArrayForID(609, 4, GetArmorNudeGun(1), false)
			elseIf (SequenceID >= 610)
				seqArr[0].NudeArmorGun = GetArmorNudeGun(1)
				seqArr[1].NudeArmorGun = GetArmorNudeGun(1)
				seqArr[2].NudeArmorGun = GetArmorNudeGun(1)
				seqArr[3].NudeArmorGun = GetArmorNudeGun(1)
				seqExtraArr = CreateSeqArrayForID(610, 4, GetArmorNudeGun(1), false)
			endIf
		endIf
	elseIf (SequenceID == 650)
		if (SceneData.HasToyEquipped == false)
			;gunStart = GetArmorNudeGun(0)
		else
			seqArr = CreateSeqArrayForID(651, 4, GetArmorNudeGun(1), false)
			seqExtraArr = CreateSeqArrayForID(651, 4, GetArmorNudeGun(1), false)
		endIf
	elseIf (SequenceID == 651)
		gunStart = GetArmorNudeGun(1)
		seqArr = CreateSeqArrayForID(651, 4, gunStart, false)
		seqExtraArr = CreateSeqArrayForID(651, 4, gunStart, false)

	elseIf (SequenceID == 653)
		seqArr[0].NudeArmorGun = GetArmorNudeGun(1)
		seqExtraArr[0].NudeArmorGun = GetArmorNudeGun(1)

	elseIf (SequenceID >= 654 && SequenceID < 660)
		gunStart = GetArmorNudeGun(1)
		seqArr = CreateSeqArrayForID(651, 4, gunStart, false)
		seqExtraArr = CreateSeqArrayForID(651, 4, gunStart, false)
	endIf
	
	if (seqLen > 4)
		seqArr[3] = seqExtraArr[1]
		seqArr[4] = seqExtraArr[2]
		seqArr[5] = seqExtraArr[3]
	endIf
	
	PlayLeitoPairSequenceLists(SceneData.MaleRole, SceneData.FemaleRole, None, seqArr)

endFunction

; ---- no longer used ---- v2.73--- mActor is considered dominate
Function PlayLeitoPairSequenceLists(Actor mActor, Actor fActor, Actor oActor, AStageItem[] positionIDArr, bool useBedLocation = false)
	
	if (mActor != None && fActor != None && positionIDArr != None && positionIDArr.Length > 0)
	
		Armor armS1 = positionIDArr[0].NudeArmorGun
		
		MyPositionIDArray = positionIDArr
		
		if (MaleBodyMorphEnabled)
			int kind = GetArmorNudeKindForGun(armS1)
			SetMorphForActor(mActor, -1, kind, 1.0)
		else
			; can only equip on player before scene start
			;
			if (positionIDArr[0].NudeArmorGun != None)
				; can only equip on player before start scene
				if (mActor == PlayerRef  && positionIDArr.Length > 1)
					if (positionIDArr[0].NudeArmorGun != positionIDArr[1].NudeArmorGun)
						armS1 = positionIDArr[1].NudeArmorGun
					endIf
				endIf
				CheckEquipActorArmGun(mActor, armS1)
				if (SceneData.MaleRole == PlayerRef)
					Utility.Wait(0.33)
				endIf
			endIf
		endIf

		Actor[] actors = new Actor[2]
		if (oActor != None)
			actors = new Actor[3]
			actors[2] = oActor
			if (oActor == SceneData.SecondMaleRole && positionIDArr[0].NudeArmorGunM2 != None)
				CheckEquipActorArmGun(SceneData.SecondMaleRole, positionIDArr[0].NudeArmorGunM2)
			endIf
		endIf

		actors[1] = mActor   ; place 2nd position											
		actors[0] = fActor
		if (SceneData.CompanionInPowerArmor || SceneData.IsCreatureType == 3)	; v2.17 - added
			actors = New Actor [1]
			actors[0] = MainActor
		endIf
		
		AAF:AAF_API:SceneSettings aafSettings = AAF_API.GetSceneSettings()

		aafSettings.duration = 10.0
		aafSettings.position = positionIDArr[0].StageIDStr
		;if (useBedLocation)
		;	aafSettings.locationObject = BedInSceneRef
		if (SceneData.MaleMarker != None)
			aafSettings.locationObject = SceneData.MaleMarker
		elseIf (SceneData.FemaleMarker != None)
			aafSettings.locationObject = SceneData.FemaleMarker
		else
			aafSettings.locationObject = SecondActor
		endIf
		if (positionIDArr[0].StageTime > 0.0)
			aafSettings.duration = positionIDArr[0].StageTime
		endIf
		
		if (DTSleep_SettingTestMode.GetValue() > 0.0 && DTSleep_DebugMode.GetValue() >= 2.0)
			;TODO remove
			Debug.Trace("[DTSleep_PlayAAF_Seq] start position ID " + positionIDArr[0].StageIDStr + " at Loc " + aafSettings.locationObject + " with sceneLen " + DTSleep_IntimateSceneLen.GetValueInt() + " and actor count " + actors.Length)
		endIf
		RegisterForCustomEvent(AAF_API, "OnAnimationStart")
		RegisterForCustomEvent(AAF_API, "OnAnimationStop")
	
		MyStartSeqID = positionIDArr[0].StageIDStr
		AAF_API.StartScene(actors, aafSettings)
		; will continue on Event
		
		StartTimer(20.0, CheckSceneStartTimerID)
	else
		Debug.Trace("[DTSleep_PlayAAF] PlayPairSeq - bad data - canceled")
		SceneData.Interrupted = 8
		if (MSceneFadeEnabled)
			Game.FadeOutGame(false, true, 0.0, 1.0)
		endIf
		StopAnimationSequence()
	endIf
	
endFunction

; no longer used --- v2.73
Function PlayLeitoPairContinuedSequence(float waitSecs)

	int seqCount = 1
	int seqTotalCount = 0
	int seqLen = MyPositionIDArray.Length
	int pingPongCount = DTSleep_IntimateSceneLen.GetValueInt() - 1
	float loopWaitSecs = waitSecs
	float startSecs = 9.1
	if (MyPositionIDArray[0].StageTime > 0.0)
		startSecs = MyPositionIDArray[0].StageTime
	endIf
	if (seqLen <= 2)
		pingPongCount = 0
	elseIf (startSecs <= 13.0 && waitSecs < 13.0 && seqLen <= 5)
		pingPongCount += 1
	endIf
	Armor armGunLast = MyPositionIDArray[0].NudeArmorGun
	Armor armGunM2Last = MyPositionIDArray[0].NudeArmorGunM2
	
	;float startTime = Utility.GetCurrentRealTime() ;TODO remove
	
	Utility.Wait(startSecs - 0.8)
	
	while (seqCount < seqLen && SceneData.Interrupted <= 0)
	
		; armor?
		if (seqCount >= 1 && seqCount < seqLen - 1)
			
			
			Armor armGun = MyPositionIDArray[seqCount].NudeArmorGun
			Armor armGunM2 = MyPositionIDArray[seqCount].NudeArmorGunM2
			
			if (MaleBodyMorphEnabled)
				int kind = GetArmorNudeKindForGun(armGun)
				SetMorphForActor(SceneData.MaleRole, GetArmorNudeKindForGun(armGunLast), kind, 1.0)
			
			elseIf (armGun != None && armGun != armGunLast)
				if (SceneData.MaleRole != PlayerRef && SceneData.MaleRoleGender == 0)
					armGunLast = armGun
					CheckEquipActorArmGun(SceneData.MaleRole, armGun)
				endIf
			endIf
			if (SceneData.SecondMaleRole != None && armGunM2 != None && armGunM2 != armGunM2Last)
				armGunM2Last = armGunM2
				CheckEquipActorArmGun(SceneData.SecondMaleRole, armGunM2)
			endIf
		endIf
		
		; wait time
		if (MyPositionIDArray[seqCount].StageTime > 0.0)
			loopWaitSecs = MyPositionIDArray[seqCount].StageTime
		elseIf (seqCount == seqLen - 1)
			loopWaitSecs = 5.75
		elseIf (seqCount == 0)
			loopWaitSecs = startSecs
		else
			loopWaitSecs = waitSecs
		endIf
		
		if (seqCount > 0)
			PlayPosition(MyPositionIDArray[seqCount].StageIDStr, loopWaitSecs)
		endIf
		
		if (pingPongCount > 0 && seqCount == (seqLen - 2))
			pingPongCount -= 1
			seqCount = seqLen - 4
		endIf
		
		Utility.Wait(loopWaitSecs - 0.2)

		seqCount += 1
		seqTotalCount += 1
	endWhile
	
	;if (DTSleep_SettingTestMode.GetValue() > 0.0 && DTSleep_DebugMode.GetValue() >= 2.0)
	;	;TODO remove
	;	float elapseTime = Utility.GetCurrentRealTime()
	;
	;
	;	Debug.Trace("[DTSleep_PlayAAF] scene time (early): " + (elapseTime - startTime))
	;endIf
	
	MySceneStatus = 2
	StopAnimationSequence()
endFunction

; - no longer used ---- v2.73
Function PlaySequenceLeitoStrongStages()
	
	string position = CreateSeqPositionStr(SequenceID, 1)
	Armor gunStart = GetArmorNudeGun(0)
	if (SequenceID == 660 || SequenceID == 663)
		gunStart = GetArmorNudeGun(1)
	endIf
	
	if (gunStart != None)
		SecondActor.EquipItem(gunStart, true, true)
	endIf
	
	Actor[] actors = new Actor[2]
	actors[1] = SecondActor												
	actors[0] = MainActor
	
	AAF:AAF_API:SceneSettings aafSettings = AAF_API.GetSceneSettings()

	aafSettings.duration = 9.6
	aafSettings.position = position
	if (SceneData.MaleMarker != None)
		aafSettings.locationObject = SceneData.MaleMarker
	elseIf (SceneData.FemaleMarker != None)
		aafSettings.locationObject = SceneData.FemaleMarker
	else
		aafSettings.locationObject = SecondActor
	endIf
	
	RegisterForCustomEvent(AAF_API, "OnAnimationStart")
	RegisterForCustomEvent(AAF_API, "OnAnimationStop")
	
	MyStartSeqID = position
	AAF_API.StartScene(actors, aafSettings)
	; will continue on Event
	
	StartTimer(20.0, CheckSceneStartTimerID)
	
endFunction


Function PlayLeitoStrongContinuedSequence()

	int sceneLen = DTSleep_IntimateSceneLen.GetValueInt()
	
	if (SequenceID == 660)
		PlayStrongContinuedCarry(sceneLen)
	elseIf (SequenceID == 661)
		PlayStrongContinuedStandDoggy(sceneLen)
	elseIf (SequenceID == 662)
		PlayStrongContinuedSideways(sceneLen)
	elseIf (SequenceID >= 663)
		PlayStrongContinuedCarryReverse(sceneLen)
	endIf
	
	MySceneStatus = 2
	StopAnimationSequence()
endFunction

Function PlayStrongContinuedCarry(int sceneLen)

	int sceneCount = 0
	string posStr = CreateSeqPositionStr(663, 1)
	Armor arm2 = GetArmorNudeGun(0)
	Armor arm1 = GetArmorNudeGun(1)
	
	Utility.Wait(37.0)
	
	while (sceneCount < sceneLen && SceneData.Interrupted <= 0)
	
		if (sceneCount == 0 || sceneCount == 2)
			if (arm2 != None)
				SecondActor.EquipItem(arm2, true, true)
				
			endIf
			posStr = CreateSeqPositionStr(662, 1)
		else
			if (arm1 != None)
				SecondActor.EquipItem(arm1, true, true)
			endIf
			posStr = CreateSeqPositionStr(663, 1)
		endIf
		
		PlayPosition(posStr, (SceneData.WaitSecs * 2.0))
		Utility.Wait(22.2)
		
		sceneCount += 1
	endWhile
endFunction

Function PlayStrongContinuedStandDoggy(int sceneLen)

	int sceneCount = 0
	string posStr = CreateSeqPositionStr(663, 1)
	
	Utility.Wait(37.5)
	
	while (sceneCount < sceneLen && SceneData.Interrupted <= 0)
	
		if (sceneCount == 0 || sceneCount == 2)
			posStr = CreateSeqPositionStr(662, 1)
		else
			posStr = CreateSeqPositionStr(661, 1)
		endIf
		
		PlayPosition(posStr, (SceneData.WaitSecs * 2.0))
		Utility.Wait(22.5)
		
		sceneCount += 1
	endWhile

endFunction

Function PlayStrongContinuedCarryReverse(int sceneLen)
	
	int sceneCount = 0
	string posStr = CreateSeqPositionStr(663, 1)
	Armor arm2 = GetArmorNudeGun(0)
	Armor arm1 = GetArmorNudeGun(1)
	Utility.Wait(37.5)
	
	while (sceneCount < sceneLen && SceneData.Interrupted <= 0)
	
		if (sceneCount == 1)
			posStr = CreateSeqPositionStr(663, 1)
			if (arm1 != None)
				SecondActor.EquipItem(arm1, true, true)
			endIf
			
		elseIf (sceneCount == 2)
			posStr = CreateSeqPositionStr(661, 1)
			if (arm2 != None)
				SecondActor.EquipItem(arm2, true, true)
			endIf
		else
			posStr = CreateSeqPositionStr(662, 1)
			
			if (arm2 != None)
				SecondActor.EquipItem(arm2, true, true)
			endIf
		endIf
		
		PlayPosition(posStr, (SceneData.WaitSecs * 2.0))
		Utility.Wait(22.5)
		
		sceneCount += 1
	endWhile
endFunction

Function PlayStrongContinuedSideways(int sceneLen)

	int sceneCount = 0
	string posStr = CreateSeqPositionStr(663, 1)
	
	Utility.Wait(37.5)
	
	while (sceneCount < sceneLen && SceneData.Interrupted <= 0)
	
		if (sceneCount == 0 || sceneCount == 2)
			posStr = CreateSeqPositionStr(661, 1)
		else
			posStr = CreateSeqPositionStr(662, 1)
		endIf
		
		PlayPosition(posStr, (SceneData.WaitSecs * 2.0))
		Utility.Wait(22.5)
		
		sceneCount += 1
	endWhile
endFunction

Function RemoveLeitoGuns(Actor aActor)
	
	if (DTSleep_SettingUseBT2Gun.GetValueInt() > 0 || DTSleep_SettingSynthHuman.GetValueInt() >= 2)
		RemoveBT2Guns(aActor)
	elseIf (MaleBodyMorphEnabled)
		if (DTSleep_SettingUseSMMorph.GetValueInt() > 0 && (SceneData.IsCreatureType == 1 || SceneData.IsCreatureType == 5))
			RemoveMorphs(aActor)
			
			return
		endIf	
	endIf
	
	if (DTSleep_SettingSynthHuman.GetValueInt() == 1 && SceneData.IsCreatureType == 4 && DTSleep_LeitoGunSynthList != None)
		int j = 0
		while (j < DTSleep_LeitoGunSynthList.GetSize())
			Armor item = DTSleep_LeitoGunSynthList.GetAt(j) as Armor
			if (item != None)
				int count = aActor.GetItemCount(item)
				if (count > 0)
					if (DTSleep_SettingTestMode.GetValue() > 0.0 && DTSleep_DebugMode.GetValue() >= 1.0) ;TODO remove
						Debug.Trace("[DTSleep_PlayAAF] removing synth nude gear: " + item)
					endIf
					aActor.UnequipItem(item as Form, false, true)
					aActor.RemoveItem(item as Form, count, true, None)
				endIf
			endIf
			j += 1
		endWhile
	endIf
	
	if (DTSleep_LeitoGunList != None)
		if (DTSleep_DebugMode.GetValueInt() >= 2)
			Debug.Trace("[DTSleep_PlayAAF] remove LeitoGuns for actor " + aActor)
		endIf
		int len = DTSleep_LeitoGunList.GetSize()
		int idx = 0
		while (idx < len)
			Armor gun = DTSleep_LeitoGunList.GetAt(idx) as Armor
			if (gun != None)
				int count = aActor.GetItemCount(gun)
				if (count > 0)
					if (DTSleep_SettingTestMode.GetValue() > 0.0 && DTSleep_DebugMode.GetValue() >= 2.0) ;TODO remove
						Debug.Trace("[DTSleep_PlayAAF] removing nude gun: " + gun)
					endIf
					aActor.UnequipItem(gun as Form, false, true)
					aActor.RemoveItem(gun as Form, count, true, None)
				endIf
			endIf
			idx += 1
		endWhile
	endIf
EndFunction

Function RemoveBT2Guns(Actor aActor)
	if (MaleBodyMorphEnabled)
		RemoveMorphs(aActor)
		
	elseIf (DTSleep_BT2GunList != None)
		int len = DTSleep_BT2GunList.GetSize()
		if (len > 3 && DTSleep_SettingSynthHuman.GetValueInt() < 2 && SceneData.IsCreatureType != 4)
			len = 3
		endIf
		int idx = 0
		while (idx < len)
			Armor gun = DTSleep_BT2GunList.GetAt(idx) as Armor
			if (gun != None)
				int count = aActor.GetItemCount(gun)
				if (count > 0)
					if (DTSleep_SettingTestMode.GetValue() > 0.0 && DTSleep_DebugMode.GetValue() >= 2.0)
						Debug.Trace("[DTSleep_PlayAAC] removing nude gun: " + gun)
					endIf
					aActor.UnequipItem(gun as Form, false, true)
					aActor.RemoveItem(gun as Form, count, true, None)
				endIf
			endIf
			idx += 1
		endWhile
	endIf
endFunction

Function RemoveMorphs(Actor aActor)
	;Debug.Trace("[DTSleep_PlayAAF] removing morphs from actor " + aActor)
	BodyGen.RemoveMorphsByKeyword(aActor, false, DTSleep_MorphKeyword)
	BodyGen.UpdateMorphs(aActor)
endFunction

Function SetMorphForActor(Actor aActor, int lastKind, int toKind, float toMorphVal)			; updated for value v2.73

	if (lastKind < 0)
		BodyGen.SetMorph(aActor, false, GetArmorNudeMorphString(0), DTSleep_MorphKeyword, 1.0)
	elseIf (lastKind > 0)
		; remove
		BodyGen.SetMorph(aActor, false, GetArmorNudeMorphString(lastKind), DTSleep_MorphKeyword, 0.0)
	endIf
	if (toKind > 0)
		float morphVal = 1.0
		if (SceneData.IsCreatureType == 5)
			morphVal = 0.88
		elseIf (SceneData.AnimationSet == 7 && (DTSConditionals as DTSleep_Conditionals).SavageCabbageVers >= 1.20)
			morphVal = -1.0
		elseIf (toMorphVal > 0.0)
			morphVal = toMorphVal
		endIf
		if (morphVal > 0.0)
			BodyGen.SetMorph(aActor, false, GetArmorNudeMorphString(toKind), DTSleep_MorphKeyword, morphVal)
		endIf
	endIf
	
	BodyGen.UpdateMorphs(aActor)
endFunction
