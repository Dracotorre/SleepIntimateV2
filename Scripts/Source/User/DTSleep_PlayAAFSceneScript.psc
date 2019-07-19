Scriptname DTSleep_PlayAAFSceneScript extends Quest


; *********************
; script by DracoTorre
; Sleep Intimate
; https://www.dracotorre.com/mods/sleepintimate/
;
; plays scene using Advanced Animation Framework (AAF) beta 38+
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
;
; AAF uses a doppelganger borrowing player-character armor items which is then returned afterward
; and rather late.
;

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
GlobalVariable property DTSleep_AAFTestTipShown auto	; time last shown
EndGroup

Group A_GameData
Actor property PlayerRef auto const Mandatory
DTSleep_SceneData property SceneData auto const
{ all we need to know actors, creatures, markers, ... }
;FormList property DTSleep_StrapOnList auto const
FormList property DTSleep_LeitoGunList auto const
{ nude male body sets with erection 'gun' aimed - use when need to replace AAF morph }
FormList property DTSleep_BT2GunList auto const
;Armor property DTSleep_NudeSuitPlayerUp auto const
Message property DTSleep_TestModeIDMessage auto const   ; reminds in test mode - could activate AAF interface to see ID
Message property DTSleep_AAFGUIReminderMsg auto const
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

; *************************
;          variables

CustomEvent SleepIntAAFPlayDoneEvent

InputEnableLayer DTSleepPlaySceneInputLayer

AStageItem[] MyPositionIDArray
int SeqLimitTimerID = 101 const
int ShowTestSceneNumTimerID = 102 const
int ChangeSettingsAndStopTimerID = 103 const
int ShowAAFEquipTipTimerID = 104 const
int CheckSceneStartTimerID = 9 const
int AAFCheckStartCount = 0
int MyMaleRoleGender = -1
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
	
	if (goodToGo == 1)
		UnregisterForCustomEvent(AAF_API, "OnAnimationStart")
		SceneData.Interrupted = 0
		MySceneStatus = 1
		
		if (MSceneFadeEnabled)
			Game.FadeOutGame(false, true, 0.0, 1.1)
		endIf
		if (SceneData.AnimationSet == 5)
			if (SequenceID == 547)
				PlayAtomicLustContinuedSequence(547)
			elseIf (SequenceID == 546)
				PlayAtomicLustContinuedSequence(546)
			else
				Utility.Wait(30.1)
				MySceneStatus = 2
				StopAnimationSequence()
			endIf
		elseIf (CurrentSingleDuration > 4.0)
			Utility.Wait(CurrentSingleDuration)
			MySceneStatus = 2
			StopAnimationSequence()
			
		elseIf (SequenceID < 660)
			PlayPairContinuedSequence(SceneData.WaitSecs)
		elseIf (SequenceID >= 660 && SequenceID < 700)
			PlayLeitoStrongContinuedSequence()
		elseIf (SequenceID == 712)
			PlayPairContinuedSequence(8.4)
		else
			PlayPairContinuedSequence(SceneData.WaitSecs)
		endIf
		
	elseIf (goodToGo <= -1)
	
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
	else
		MainActor = aMainActor
		Debug.Trace("[DTSleep_PlayAAF] caster only play ")
	endIf
	
	if (MainActor && DTSConditionals.IsF4SE && (Debug.GetPlatformName() as bool))
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
			if (DTSleep_SettingAAF.GetValueInt() < 2)
				AAF_API.ChangeSetting("hide_error_messages", "false")  ; restore
			endIf
		else
			AAF_API.ChangeSetting("disable_equipment_handling", "true")
			if (DTSleep_SettingAAF.GetValueInt() >= 2)
				if (MSceneFadeEnabled)
					AAF_API.ChangeSetting("walk_timeout", "8")
				endIf
			else
				if (MSceneFadeEnabled)
					AAF_API.ChangeSetting("walk_timeout", "2")
				endIf
				AAF_API.ChangeSetting("hide_error_messages", "true")  ; hide when using fade
			endIf
		endIf
	endIf
endFunction

bool Function CheckEquipActorArmGun(Actor maleActor, Armor armGun)
	int maleActorGender = -1
	
	if (maleActor != None && armGun != None)
		if (maleActor == SceneData.MaleRole)
			if (MyMaleRoleGender < 0)
				MyMaleRoleGender = (SceneData.MaleRole.GetLeveledActorBase() as ActorBase).GetSex()
			endIf
			maleActorGender = MyMaleRoleGender
		elseIf (maleActor == SceneData.SecondMaleRole)
			SceneData.SecondMaleRole.EquipItem(armGun, true, true)
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
				if (SequenceID == 547)
					PlayAtomicLustStages(547)
				elseIf (SequenceID == 546)
					PlayAtomicLustStages(546)
					
				elseIf (SequenceID == 549)
					AStageItem[] seqArr = CreateSeqArrayForID(SequenceID, 4, None, false)

					PlayPairSequenceLists(SceneData.MaleRole, SceneData.FemaleRole, None, seqArr, false)
				else
					PlayAtomicScene()
				endIf
			elseIf (SequenceID < 660)
				PlaySequenceLeitoStages()
			elseIf (SequenceID < 670)
				PlaySequenceLeitoStrongStages()
			elseIf (SequenceID == 739)
				; has both FM and FF variations - Create sets string for us
				PlaySingleStageScene(CreateSeqPositionStr(739, 1), 32.0, SceneData.MaleMarker, GetLeitoGun(1))
			elseIf (SequenceID == 751 || SequenceID == 755)
				PlaySingleStageScene(CreateSeqPositionStr(SequenceID, 1), 32.0, SceneData.MaleMarker, GetLeitoGun(0))
			elseIf (SequenceID == 754)
				PlaySingleStageScene(CreateSeqPositionStr(SequenceID, 1), 32.0, SceneData.MaleMarker, GetLeitoGun(1))
			elseIf (SequenceID < 800)
				PlaySequenceSCStages()
			elseIf (SequenceID < 900)
				PlaySequenceZaZStages()
			elseIf (SequenceID < 1000)
				PlaySequenceGrayStages()
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
		AAF_API.StopScene(MainActor)
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
	if (SceneData.AnimationSet > 5)
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

Function PlaySingleStageScene(string positionStr, float duration, ObjectReference locObjRef, Armor armGun = None)

	CurrentSingleDuration = duration
	Actor[] actors = New Actor [2]
	actors[0] = SceneData.FemaleRole													
	actors[1] = SceneData.MaleRole
	if (SceneData.SecondMaleRole != None)
		actors.Add(SceneData.SecondMaleRole)
	endIf
	if (SceneData.CompanionInPowerArmor)
		actors = New Actor [1]
		actors[0] = MainActor
	endIf
	
	; cannot equip nude-armor on player
	;
	if (armGun != None)
		if (SceneData.MaleRole != PlayerRef && SceneData.MaleRoleGender == 0)
			CheckEquipActorArmGun(SceneData.MaleRole, armGun)
		endIf
		if (SceneData.SecondMaleRole != None)
			CheckEquipActorArmGun(SceneData.SecondMaleRole, armGun)
		endIf
	endIf

	AAF:AAF_API:SceneSettings aafSettings = AAF_API.GetSceneSettings()

	aafSettings.duration = duration
	aafSettings.position = positionStr
	aafSettings.locationObject = locObjRef

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
	float timer = 33.5
	
	bool fullID = false
	if (SequenceID == 503 || SequenceID == 504 || SequenceID == 540)
		fullID = true
	elseIf (SequenceID >= 550 && SequenceID <= 552)
		fullID = true
	endIf
	String positionStr = CreateSeqPositionStr(SequenceID, 1, fullID)
	
	if (SceneData.MaleMarker != None)
		objRef = SceneData.MaleMarker
	elseIf (SceneData.FemaleMarker != None)
		objRef = SceneData.FemaleMarker
	elseIf (SequenceID == 501)
		objRef = BedInSceneRef
	elseIf (SequenceID == 503 || SequenceID == 504 || SequenceID == 541)
		objRef = BedInSceneRef
		if (SceneData.SameGender && SceneData.MaleRoleGender == 0)
			armGun = GetLeitoGun(0)
		endIf
	elseIf (SequenceID >= 505 && SequenceID <= 506)
		armGun = GetLeitoGun(0)
	elseIf (SequenceID >= 540 && SequenceID <= 541)
		objRef = MainActor
		if (MainActor == SceneData.MaleRole)
			armGun = GetLeitoGun(0)
		endIf
	elseIf (SequenceID == 548)
		timer = 18.0
	elseIf (SequenceID >= 550 && SequenceID <= 552)
		armGun = GetLeitoGun(0)
	endIf

	PlaySingleStageScene(positionStr, timer, objRef, armGun)
	
endFunction

Function PlayAtomicLustStages(int sid)

	string position = CreateSeqPositionStr(sid, 1, false)  ; shortID
	
	Actor[] actors = new Actor[2]
	if (SceneData.MaleRole == MainActor)
		actors[0] = SecondActor												
		actors[1] = MainActor
	else
		actors[1] = SecondActor												
		actors[0] = MainActor
	endIf
	
	AAF:AAF_API:SceneSettings aafSettings = AAF_API.GetSceneSettings()

	aafSettings.duration = 20.5
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

string Function CreateSeqPositionStr(int seqId, int stageNum, bool fullStr = true)
	return CreateSeqBaseStr(fullStr) + CreateSeqIDStageStr(seqId, stageNum)
endFunction

; use if morph not available, but not on player's character which is a doppelganger
; 0 = normal, 1 = up, 2 = down
Armor Function GetLeitoGun(int kind)

	return GetArmorNudeGun(kind)
endFunction

; 0 = normal, 1 = up, 2 = down
Armor Function GetArmorNudeGun(int kind)
	Armor gun = None
	if (kind < 0)
		return None
	endIf
	if (!Debug.GetPlatformName() as bool)
		return None
	endIf
	if (DTSleep_SettingTestMode.GetValue() < 1.0)
		return None
	endIf
	int evbVal = DTSleep_SettingUseLeitoGun.GetValueInt()
	int bt2Val = DTSleep_SettingUseBT2Gun.GetValueInt()
	
	if (SceneData.IsCreatureType == 1)
		evbVal = 2
		bt2Val = -1
	elseIf (DTSConditionals.IsUniquePlayerMaleActive && evbVal > 0 && SceneData.MaleRole == PlayerRef)
		bt2Val = -1
	endIf
	
	if (kind > 0 && evbVal == 1)
		kind = 0
	endIf
	
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
			if (bt2Val < 0 && DTSleep_LeitoGunList != None && DTSleep_LeitoGunlist.GetSize() > kind)
				gun = DTSleep_LeitoGunList.GetAt(kind) as Armor
			elseIf (bt2Val >= 0 && DTSleep_BT2GunList != None && DTSleep_BT2GunList.GetSize() > kind)
				gun = DTSleep_BT2GunList.GetAt(kind) as Armor
			endIf
		endIf
	endIf
	
	return gun
endFunction

; SavageCabbages
Function PlaySequenceSCStages()

	int seqLen = 6
	bool shortSeq = false
	
	if (DTSleep_IntimateSceneLen.GetValueInt() <= 0)
		seqLen = 4
		shortSeq = true
	elseIf (SequenceID == 700 || SequenceID == 705 || SequenceID == 711)
		seqLen = 4
	elseIf (SequenceID == 703)
		seqLen = 4
	elseIf (SequenceID >= 735 && SequenceID <= 737)
		seqLen = 4
	elseIf (SequenceID == 753)
		seqLen = 4
	elseIf (SequenceID == 739)
		seqLen = 1  ; in case of mistake - not a sequence 
	elseIf (SequenceID == 740)
		seqLen = 2
	elseIf (SequenceID == 756)
		seqLen = 7
	elseIf (SequenceID == 751 || SequenceID == 754 || SequenceID == 755)
		seqLen = 1 ; in case of mistake - not a sequence
	elseIf (SequenceID == 752)
		seqLen = 4
	elseIf (SequenceID >= 758 && SequenceID < 764)
		seqLen = 4
	endIf
	Armor gunStart = GetLeitoGun(0)
	Armor gun2Start = GetLeitoGun(0)
	if (SequenceID == 703)
		gunStart = GetLeitoGun(1)
	elseIf (SequenceID >= 735 && SequenceID <= 737)
		if (SceneData.SecondMaleRole == None)
			gunStart = GetLeitoGun(1)
		endIf
	elseIf (SequenceID >= 758 && SequenceID <= 760)
		gunStart = GetLeitoGun(1)
	elseIf (SequenceID == 764)
		gunStart = GetLeitoGun(2)
	endIf
	
	AStageItem[] seqArr = CreateSeqArrayForID(SequenceID, seqLen, gunStart)
	seqArr[seqArr.Length - 1].StageTime = 10.0

	if (SequenceID == 700)
		seqArr[0].StageTime = 13.5
		seqArr[3].StageTime = 7.0
	elseIf (SequenceID == 701)
		seqArr[0].StageTime = 14.0
		seqArr[2].NudeArmorGun = GetLeitoGun(1)
		seqArr[3].StageTime = 9.0
	elseIf (SequenceID == 703)
		seqArr[0].StageTime = 13.5
		; TODO: ? replace with normal body for finale?
		
	elseIf (SequenceID == 704)
		seqArr[1].NudeArmorGun = GetLeitoGun(1)
		seqArr[2].NudeArmorGun = GetLeitoGun(1)
		seqArr[3].NudeArmorGun = GetLeitoGun(1)
		if (!shortSeq)
			seqArr[4].NudeArmorGun = GetLeitoGun(1)
		endIf
	elseIf (SequenceID == 705)
		seqArr[1].NudeArmorGun = GetLeitoGun(1)
		seqArr[2].NudeArmorGun = GetLeitoGun(1)
		seqArr[3].NudeArmorGun = GetLeitoGun(1)
		seqArr[0].StageTime = 13.0
		seqArr[1].StageTime = 8.2
	elseIf (SequenceID == 756)
		seqArr[0].StageTime = 12.5
		seqArr[1].StageTime = 2.5
		seqArr[4].NudeArmorGun = GetLeitoGun(1)
		seqArr[5].NudeArmorGun = GetLeitoGun(1)
		
		
	; ----- this was moved somewhere ??
	;elseIf (SequenceID == 757 && SceneData.SecondMaleRole != None && Utility.RandomInt(1, 5) > 3)
	;	seqArr[2].StageIDStr = CreateSeqPositionStr(757, 4)
	;	seqArr[3].StageIDStr = CreateSeqPositionStr(757, 5)
	; -------------
	
	elseIf (SequenceID == 758)
		if (SceneData.SecondMaleRole == None)
			seqArr[0].StageTime = 15.0
			seqArr[1].StageTime = 22.0
		else
			seqArr[0].NudeArmorGun = GetLeitoGun(0)
			seqArr[0].NudeArmorGunM2 = GetLeitoGun(0)
		endIf
	elseIf (SequenceID == 761)
		seqArr[2].NudeArmorGun = GetLeitoGun(1)
		seqArr[3].NudeArmorGun = GetLeitoGun(1)
	elseIf (SequenceID == 763)
		seqArr[0].NudeArmorGun = GetLeitoGun(1)
		seqArr[3].NudeArmorGun = GetLeitoGun(2)
	elseIf (SequenceID == 764)
		seqArr[2].NudeArmorGun = GetLeitoGun(2)
		if (!shortSeq)
			seqArr[5].NudeArmorGun = GetLeitoGun(2)
		endIf
	elseIf (SequenceID == 766)
		seqArr[3].NudeArmorGun = GetLeitoGun(1)
		if (!shortSeq)
			seqArr[4].NudeArmorGun = GetLeitoGun(1)
			seqArr[5].NudeArmorGun = GetLeitoGun(1)
		endIf
	endIf
	
	PlayPairSequenceLists(SceneData.MaleRole, SceneData.FemaleRole, SceneData.SecondMaleRole, seqArr, true)
endFunction

Function PlaySequenceGrayStages()

	Armor gunStart = GetLeitoGun(0)
	AStageItem[] seqArr = CreateSeqArrayForID(SequenceID, 4, gunStart)
	
	PlayPairSequenceLists(SceneData.MaleRole, SceneData.FemaleRole, None, seqArr, true)
endFunction

Function PlaySequenceZaZStages()

	Armor gunStart = GetLeitoGun(1)
	AStageItem[] seqArr = CreateSeqArrayForID(SequenceID, 6, gunStart)
	seqArr[seqArr.Length - 1].StageTime = 10.0
	
	if (SequenceID == 850)
		seqArr[2].NudeArmorGun = GetLeitoGun(0)
		seqArr[4].NudeArmorGun = GetLeitoGun(0)
		seqArr[5].NudeArmorGun = GetLeitoGun(0)
	else
		seqArr = CreateSeqArrayForID(SequenceID, 6, GetLeitoGun(0))
		if (SequenceID == 849)
			seqArr[1].StageTime = 6.4
			seqArr[3].StageTime = 6.4
		endIf
	endIf

	PlayPairSequenceLists(SceneData.MaleRole, SceneData.FemaleRole, None, seqArr, true)
endFunction

Function PlaySequenceLeitoStages()
	;Debug.Trace("[DTSleep_PlayAAF_Seq] playSequence " + SequenceID)
	
	int seqLen = 4
	if (DTSleep_IntimateSceneLen.GetValueInt() >= 2)
		seqLen = 6
	endIf
	
	Armor gunStart = GetLeitoGun(0)
	AStageItem[] seqArr = CreateSeqArrayForID(SequenceID, seqLen, gunStart, false)
	AStageItem[] seqExtraArr = CreateSeqArrayForID(SequenceID, 4, gunStart, false)
	

	if (SequenceID < 650)
		; bed sequences
		if (SceneData.MaleRole && SceneData.FemaleRole)
			if (SequenceID <= 600)
				if (SceneData.MaleRole != PlayerRef)
					gunStart = GetLeitoGun(1)
					seqExtraArr = CreateSeqArrayForID(601, 4, gunStart, false)
					seqArr = CreateSeqArrayForID(601, 4, gunStart, false)
				endIf
			elseIf (SequenceID == 601)
				gunStart = GetLeitoGun(1)
				seqExtraArr = CreateSeqArrayForID(601, 4, gunStart, false)
				seqArr = CreateSeqArrayForID(601, 4, gunStart, false)

			elseIf (SequenceID == 603)
				; TODO: chance for doggy mix??
				
			elseIf (SequenceID == 604)
				if (SceneData.MaleRole != PlayerRef)
					;gunStart = GetLeitoGun(0)
					seqArr[1].NudeArmorGun = GetLeitoGun(1)
					seqExtraArr[1].NudeArmorGun = GetLeitoGun(1)
				endIf
			elseIf (SequenceID == 605)
				; cowgirl
				;gunStart = GetLeitoGun(0)
				seqExtraArr = CreateSeqArrayForID(607, 4, gunStart, false)

			elseIf (SequenceID >= 606 && SequenceID <= 607)
				seqArr[0].NudeArmorGun = GetLeitoGun(2)
				seqArr[1].NudeArmorGun = GetLeitoGun(2)
				seqArr[2].NudeArmorGun = GetLeitoGun(2)
				seqArr[3].NudeArmorGun = GetLeitoGun(2)
				seqExtraArr = CreateSeqArrayForID(607, 4, GetLeitoGun(2), false)

			elseIf (SequenceID >= 608 && SequenceID <= 609)
				seqArr[0].NudeArmorGun = GetLeitoGun(1)
				seqArr[1].NudeArmorGun = GetLeitoGun(1)
				seqArr[2].NudeArmorGun = GetLeitoGun(1)
				seqArr[3].NudeArmorGun = GetLeitoGun(1)
				seqExtraArr = CreateSeqArrayForID(609, 4, GetLeitoGun(1), false)
			elseIf (SequenceID >= 610)
				seqArr[0].NudeArmorGun = GetLeitoGun(1)
				seqArr[1].NudeArmorGun = GetLeitoGun(1)
				seqArr[2].NudeArmorGun = GetLeitoGun(1)
				seqArr[3].NudeArmorGun = GetLeitoGun(1)
				seqExtraArr = CreateSeqArrayForID(610, 4, GetLeitoGun(1), false)
			endIf
		endIf
	elseIf (SequenceID == 650)
		if (SceneData.HasToyEquipped == false)
			;gunStart = GetLeitoGun(0)
		else
			seqArr = CreateSeqArrayForID(651, 4, GetLeitoGun(1), false)
			seqExtraArr = CreateSeqArrayForID(651, 4, GetLeitoGun(1), false)
		endIf
	elseIf (SequenceID == 651)
		gunStart = GetLeitoGun(1)
		seqArr = CreateSeqArrayForID(651, 4, gunStart, false)
		seqExtraArr = CreateSeqArrayForID(651, 4, gunStart, false)

	elseIf (SequenceID == 653)
		seqArr[0].NudeArmorGun = GetLeitoGun(1)
		seqExtraArr[0].NudeArmorGun = GetLeitoGun(1)

	elseIf (SequenceID >= 654 && SequenceID < 660)
		gunStart = GetLeitoGun(1)
		seqArr = CreateSeqArrayForID(651, 4, gunStart, false)
		seqExtraArr = CreateSeqArrayForID(651, 4, gunStart, false)
	endIf
	
	if (seqLen > 4)
		seqArr[3] = seqExtraArr[1]
		seqArr[4] = seqExtraArr[2]
		seqArr[5] = seqExtraArr[3]
	endIf
	
	PlayPairSequenceLists(SceneData.MaleRole, SceneData.FemaleRole, None, seqArr)

endFunction

Function PlaySequenceLeitoStrongStages()
	
	string position = CreateSeqPositionStr(SequenceID, 1)
	Armor gunStart = GetLeitoGun(0)
	if (SequenceID == 660 || SequenceID == 663)
		gunStart = GetLeitoGun(1)
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

; mActor is considered dominate
Function PlayPairSequenceLists(Actor mActor, Actor fActor, Actor oActor, AStageItem[] positionIDArr, bool useBedLocation = false)
	
	if (mActor != None && fActor != None && positionIDArr != None && positionIDArr.Length > 0)
	
		Armor armS1 = positionIDArr[0].NudeArmorGun
		
		MyPositionIDArray = positionIDArr
	
		; cannot equip nude-armor on player
		;
		if (mActor != PlayerRef && positionIDArr[0].NudeArmorGun != None)
			CheckEquipActorArmGun(mActor, armS1)
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
		
		if (DTSleep_SettingTestMode.GetValue() > 0.0 && DTSleep_DebugMode.GetValue() >= 1.0)
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

Function PlayAtomicLustContinuedSequence(int sid)

	int seqCount = 0
	int loopCount = 12 * (1 + DTSleep_IntimateSceneLen.GetValueInt())
	float waitSecs = 1.267
	
	Utility.Wait(5.0)
	PlayPosition(CreateSeqPositionStr(sid, 2, false), 2.0)
	Utility.Wait(2.0)
	PlayPosition(CreateSeqPositionStr(sid, 3, false), waitSecs)
	Utility.Wait(waitSecs)
	PlayPosition(CreateSeqPositionStr(sid, 4, false), 1.3)
	Utility.Wait(1.3)
	
	; spank! or that other sequence
	; each loop is 2.24 - 12x = 22.4 seconds
	while (seqCount < loopCount && SceneData.Interrupted <= 0)
		
		PlayPosition(CreateSeqPositionStr(sid, 5, false), waitSecs - 0.01)
		Utility.Wait(waitSecs)
		PlayPosition(CreateSeqPositionStr(sid, 6, false), 0.59)
		Utility.Wait(0.60)
	
		seqCount += 1
	endWhile
	
	; return
	PlayPosition(CreateSeqPositionStr(sid, 5, false), waitSecs)
	Utility.Wait(waitSecs)
	PlayPosition(CreateSeqPositionStr(sid, 4, false), 1.5)
	Utility.Wait(1.5)
	PlayPosition(CreateSeqPositionStr(sid, 3, false), 3.0)
	Utility.Wait(2.9)
	
	MySceneStatus = 2
	StopAnimationSequence()
endFunction

Function PlayPairContinuedSequence(float waitSecs)

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
			
			if (armGun != None && armGun != armGunLast)
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

Function PlayPosition(string posStr, float duration)
	
	AAF:AAF_API:PositionSettings posSettings = AAF_API.GetPositionSettings()
	posSettings.position = posStr
	posSettings.duration = (duration + 0.2)
	AAF_API.ChangePosition(MainActor, posSettings)
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
	Armor arm2 = GetLeitoGun(0)
	Armor arm1 = GetLeitoGun(1)
	
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
	Armor arm2 = GetLeitoGun(0)
	Armor arm1 = GetLeitoGun(1)
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
	
	if (DTSleep_LeitoGunList)
	
		int len = DTSleep_LeitoGunList.GetSize()
		int idx = 0
		while (idx < len)
			Armor gun = DTSleep_LeitoGunList.GetAt(idx) as Armor
			if (gun)
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
