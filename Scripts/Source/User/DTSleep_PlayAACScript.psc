Scriptname DTSleep_PlayAACScript extends ActiveMagicEffect

; *********************
; script by DracoTorre
; Sleep Intimate
; https://www.dracotorre.com/mods/sleepintimate/
; https://github.com/Dracotorre/SleepIntimateV2
;
; positions actors and plays singles or sequences of paired animated idles where each actor is positioned at origin--no offset between actors
; 
; actors expected to be undressed as desired - male nude-body swap as required by seqID-and-stageID
; use SceneData.MarkerOrientationAllowance if orientation may be close enough, such as on a bed, to reduce actor turning
;
; actors positioned by translate-slowly method to allow actors to be positioned in same location as other objects
; (normally collision intersection forces actors away so no two actors can be placed any close than 50 units)
; avoid moving player by limit turning/positioning only second actor to match orientation then translate both
;
; SceneData holds actors, sequence length
; 
; 
import DTSleep_AACcatScript

Group B_Globals
GlobalVariable property DTSleep_IntimateIdleID auto Mandatory
{expected < 150 pair bed sequences, 150+ for pair standing sequences}
GlobalVariable property DTSleep_IntimateSceneLen auto
GlobalVariable property DTSleep_IntimateDogEXP auto
GlobalVariable property DTSleep_SettingUseLeitoGun auto const
GlobalVariable property DTSleep_SettingUseBT2Gun auto const
GlobalVariable property DTSleep_SettingSynthHuman auto const
EndGroup

Group A_GameData
Actor property PlayerRef auto const
Quest property DTSleep_IntimateAnimQuestP auto const
DTSleep_SceneData property SceneData auto const
DTSleep_Conditionals property DTSConditionals auto
Keyword property AnimFaceArchetypeHappy auto const 
;Keyword Property AnimFaceArchetypeSinisterSmile Auto Const
;Keyword Property AnimFaceArchetypeInPain Auto Const
;Keyword Property AnimFaceArchetypeFlirting Auto Const
;Keyword property AnimFaceArchetypeSinisterSmile auto const
Keyword property PlayerHackFailSubtype auto const
;FormList property DTSleep_StrapOnList auto const
FormList property DTSleep_LeitoGunList auto const
FormList property DTSleep_BT2GunList auto const
FormList property DTSleep_LeitoGunSynthList auto const
Armor property DTSleep_NudeSuitPlayerUp auto const
;Armor property DTSleep_LeitoNudeDogmeat auto const
;Armor property SkinDogmeat auto const
Static property DTSleep_MainNode auto const
EndGroup

Group C_Idles
Idle property DTSleep_TRRGTEmbraceFIdle auto const
Idle property DTSleep_TRRGTEmbraceMIdle auto const
Idle property DTSleep_TRRGTKissingFIdle auto const
Idle property DTSleep_TRRGTKissingMIdle auto const
Idle property LooseIdleStop auto const Mandatory
EndGroup

; ---------- hidden ----------
Actor property MainActor auto hidden
Actor property SecondActor auto hidden
Actor property ThirdActor auto hidden
int property SequenceID auto hidden
ObjectReference property MainActorOriginMarkRef auto hidden
ObjectReference property SecondActorOriginMarkRef auto hidden
ObjectReference property ThirdActorOriginMarkRef auto hidden
ObjectReference property PlayerOriginMarkerRef auto hidden



; *************************
;          variables

int LastGunAIndex = -1
int LastGunBIndex = -1
int MaleRoleSex = -1
int SceneRunning = -1
InputEnableLayer DTSleepPlayAACInputLayer
int DoggyQuitTimer = 99 const
int SeqLimitTimerID = 101 const

; ********************************************
; *****                Events       ***********
;

Event OnTimer(int aiTimerID)
	if (aiTimerID == SeqLimitTimerID)
		StopAnimationSequence()
	elseIf (aiTimerID == DoggyQuitTimer)
		PlayDogQuit()
	endIf
endEvent

Event OnMenuOpenCloseEvent(string asMenuName, bool abOpening)
    if (asMenuName== "PipboyMenu")
		Debug.Trace("[DTSleep_PlayAAC] Open menu - cancel scene")
		UnregisterForMenuOpenCloseEvent("PipboyMenu")
		
		Utility.Wait(1.5)
		StopAnimationSequence()
		
	endIf
EndEvent

; begin animations - 
; second actor must be akfActor (target) and not player in two-person sequences
;
Event OnEffectStart(Actor akfActor, Actor akmActor)
	
	SequenceID = DTSleep_IntimateIdleID.GetValueInt()
	LastGunAIndex = -1
	LastGunBIndex = -1
	MaleRoleSex = -1
	ThirdActor = None
	bool secondActorOkay = true
	
	if (SceneData.IsCreatureType == 2)
		MaleRoleSex = 0
	endIf
	
	if (SceneData.CompanionInPowerArmor)
		secondActorOkay = false
	elseIf (SceneData.IsCreatureType == 3)	; v2.17 - added synth
		if (SequenceID >= 100)
			secondActorOkay = false
		endIf
	elseIf (SceneData.MaleRole != akfActor && SceneData.FemaleRole != akfActor)
		secondActorOkay = false
	elseIf (akfActor == akmActor)
		secondActorOkay = false
	endIf
	
	if (akfActor != None && akfActor != akmActor)
		
		if (secondActorOkay)
			MainActor = akmActor
			SecondActor = akfActor
			
			SecondActorOriginMarkRef = DTSleep_CommonF.PlaceFormAtObjectRef(DTSleep_MainNode, SecondActor)
			SecondActor.SetAnimationVariableBool("bHumanoidFootIKDisable", true)
			Utility.Wait(0.2)
			SecondActor.ChangeAnimFaceArchetype(AnimFaceArchetypeHappy)
			SecondActor.SetGhost(true)
			
			if (SceneData.SecondFemaleRole != None)
				ThirdActor = SceneData.SecondFemaleRole
			elseIf (SceneData.SecondMaleRole != None)
				ThirdActor = SceneData.SecondMaleRole
			endIf
			
			if (ThirdActor != None)
				ThirdActor.SetAnimationVariableBool("bHumanoidFootIKDisable", true)
				ThirdActor.ChangeAnimFaceArchetype(AnimFaceArchetypeHappy)
				ThirdActor.SetGhost(true)
				ThirdActor.SetRestrained()
				ThirdActorOriginMarkRef = DTSleep_CommonF.PlaceFormAtObjectRef(DTSleep_MainNode, ThirdActor)
			endIf
			
			CheckRemoveSecondActorWeapon(0.2)
		else
			Debug.Trace("[DTSleep_PlayAAC] secondActor not okay --- single actor start " + akfActor)
			MainActor = akfActor
		endIf
		
		MainActorOriginMarkRef = DTSleep_CommonF.PlaceFormAtObjectRef(DTSleep_MainNode, MainActor)
	else
		Debug.Trace("[DTSleep_PlayAAC] single actor start " + akfActor)
		MainActor = akfActor
	endIf

	
	if (MainActor != None)
		DTSleepPlayAACInputLayer = InputEnableLayer.Create()
		
		Weapon mainW = MainActor.GetEquippedWeapon()
		if (mainW != None)
			MainActor.UnequipItem(mainW, false, true)
			Utility.Wait(0.1)
		endIf
		
		; https://www.creationkit.com/fallout4/index.php?title=DisablePlayerControls_-_InputEnableLayer
		; movement, fighting, camSwitch, Looking, sneaking, menus, activate, journal, VATS, Favs, running
		; disable movement may interfere with cam zoom
		
		Utility.Wait(0.1)
		;            SleepInputLayer                     move,  fight, camSw, look, snk, menu, act, journ, Vats, Favs, run
		DTSleepPlayAACInputLayer.DisablePlayerControls(true, true, true, false, true, false, true, true, true, true, true)
		
		MainActor.SetAnimationVariableBool("bHumanoidFootIKDisable", true)
		;MainActor.ChangeAnimFaceArchetype(AnimFaceArchetypeHappy)
		
		RegisterForMenuOpenCloseEvent("PipboyMenu")
		Utility.Wait(0.2)
		
		InitSceneAndPlay()
		
	else
		StopAnimationSequence()
	endIf
endEvent

; end animation - clean up
Event OnEffectFinish(Actor akfActor, Actor akmActor)
	;Debug.Trace("[DTSleep_PlayAAC] OnEffectFinish begin")
	
	UnregisterForMenuOpenCloseEvent("PipboyMenu")

	if (PlayerOriginMarkerRef != None)
		DTSleep_CommonF.MoveActorToObject(PlayerRef, PlayerOriginMarkerRef)
		Utility.Wait(0.2)
	endIf

	if (MainActor != None)
	
		if (MainActor != PlayerRef)
			MainActor.SetAlpha(0.0)
		endIf
	
		MainActor.ChangeAnimFaceArchetype()
		MainActor.SetAnimationVariableBool("bHumanoidFootIKDisable", false)

		if ((MainActor.GetLeveledActorBase() as ActorBase).GetSex() == 0)
			RemoveLeitoGuns(MainActor)
		endIf
		
		DTSleep_CommonF.MoveActorToObject(MainActor, MainActorOriginMarkRef)
		Utility.Wait(1.0)
		MainActor.StopTranslation()
	endIf
	
	if (SecondActor != None)
		SecondActor.StopTranslation()
		
		SecondActor.SetAnimationVariableBool("bHumanoidFootIKDisable", false)

		SecondActor.MoveTo(SecondActorOriginMarkRef, 0.0, 0.0, 0.0, true)
		
		if ((SecondActor.GetLeveledActorBase() as ActorBase).GetSex() == 0)
			RemoveLeitoGuns(SecondActor)
		endIf
		
		SecondActor.SetGhost(false)
		SecondActor.SetRestrained(false)
	endIf
	
	if (ThirdActor != None)
		ThirdActor.StopTranslation()
		;Debug.Trace("[DTSleep_PlayAAC] move third-actor back to origin")
		ThirdActor.SetAnimationVariableBool("bHumanoidFootIKDisable", false)

		ThirdActor.MoveTo(ThirdActorOriginMarkRef, 0.0, 0.0, 0.0, true)
		
		if ((ThirdActor.GetLeveledActorBase() as ActorBase).GetSex() == 0)
			RemoveLeitoGuns(ThirdActor)
		endIf
		
		ThirdActor.SetGhost(false)
		ThirdActor.SetRestrained(false)
	endIf
	
	if (MainActorOriginMarkRef != None)
		DTSleep_CommonF.DisableAndDeleteObjectRef(MainActorOriginMarkRef, false)
		MainActorOriginMarkRef = None
	endIf
	if (SecondActorOriginMarkRef != None)
		DTSleep_CommonF.DisableAndDeleteObjectRef(SecondActorOriginMarkRef, false)
		SecondActorOriginMarkRef = None
	endIf
	if (ThirdActorOriginMarkRef != None)
		DTSleep_CommonF.DisableAndDeleteObjectRef(ThirdActorOriginMarkRef, false)
		ThirdActorOriginMarkRef  = None
	endIf
	
	if (DTSleepPlayAACInputLayer != None)
		DTSleepPlayAACInputLayer.EnablePlayerControls()
		Utility.Wait(0.05)
		DTSleepPlayAACInputLayer.Delete()
	else
		Debug.Trace("[DTSleep_PlayAAC] NO input layer!!!")
	endIf
	
	if (PlayerOriginMarkerRef != None || SceneData.FemaleMarker != None)
		PlayerRef.StopTranslation()
	endIf
	
	if (PlayerOriginMarkerRef != None)
		DTSleep_CommonF.DisableAndDeleteObjectRef(PlayerOriginMarkerRef, false)
		PlayerOriginMarkerRef = None
	endIf
	
	
	MainActor = None
	SecondActor = None
	ThirdActor = None
	DTSleepPlayAACInputLayer = None
endEvent

Event OnDeath(Actor akKiller)
	self.Dispel()																
EndEvent

; ********************************************
; *****                Functions       ***********
;


bool Function ChanceDogQuits()

	int dogEXP = DTSleep_IntimateDogEXP.GetValueInt()
	int dogStartRoll = Utility.RandomInt(0, 6 + dogEXP)   ; chance dog may quit
	
	if (dogEXP < 32 && dogStartRoll < 4)
		
		return true
	endIf
	
	return false
endFunction

Function CheckRemoveSecondActorWeapon(float waitSecs = 0.07)
	if (SecondActor != None)
		Weapon weapItem = SecondActor.GetEquippedWeapon()
		
		SecondActor.SetRestrained()
		if (weapItem != None)
			;Debug.Trace("[DTSleep_PlayAAC] removing secondActor weapon!")
			SecondActor.UnequipItem(weapItem, false, true)
			
		endIf
	endIf
	if (ThirdActor != None)
		Weapon weapItem = ThirdActor.GetEquippedWeapon()
		
		ThirdActor.SetRestrained()
		if (weapItem != None)
			;Debug.Trace("[DTSleep_PlayAAC] removing ThirdActor weapon!")
			ThirdActor.UnequipItem(weapItem, false, true)
		endIf
	endif
	if (waitSecs > 0.0)
		Utility.Wait(waitSecs)
	endIf
EndFunction

; 0 = normal, 1 = up, 2 = down
Armor Function GetArmorNudeGun(int kind)
	Armor gun = None
	if (kind < 0)
		return None
	endIf
	if (!Debug.GetPlatformName() as bool)
		return None
	endIf
	int evbVal = DTSleep_SettingUseLeitoGun.GetValueInt()
	int bt2Val = DTSleep_SettingUseBT2Gun.GetValueInt()
	int synthVal = DTSleep_SettingSynthHuman.GetValueInt()
	
	if (SceneData.IsCreatureType == 1)
		evbVal = 2
		bt2Val = -1
	elseIf (SceneData.AnimationSet == 8)
		bt2Val = -1
		evbVal = 2
		synthVal = 1
	elseIf (DTSConditionals.IsUniquePlayerMaleActive && evbVal > 0 && SceneData.MaleRole == PlayerRef)
		bt2Val = -1
	endIf
	
	if (kind > 0 && evbVal == 1)
		kind = 0
	elseIf (kind > 0 && bt2Val > 0)
		if (SceneData.AnimationSet == 5)
			; these animate penis so only need base
			if (SequenceID >= 503 && SequenceID < 551)
				kind = 0
			endIf
		endIf
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
			;Debug.Trace("[DTSleep_PlayAAC] get nude-armor-gun kind = " + kind)
			if (SceneData.IsCreatureType == 4)
				if (synthVal >= 2 && DTSleep_BT2GunList.GetSize() > (kind + 3))
					gun = DTSleep_BT2GunList.GetAt(kind + 3) as Armor
				elseIf (DTSleep_LeitoGunSynthList != None && DTSleep_LeitoGunSynthList.GetSize() > kind)
					gun = DTSleep_LeitoGunSynthList.GetAt(kind) as Armor
				endIf
			elseIf (bt2Val <= 0 && DTSleep_LeitoGunList != None && DTSleep_LeitoGunlist.GetSize() > kind)
				gun = DTSleep_LeitoGunList.GetAt(kind) as Armor
			elseIf (bt2Val > 0 && DTSleep_BT2GunList != None && DTSleep_BT2GunList.GetSize() > kind)
				; Atomic Lust animates the skeleton for BodyTalk so limit to kind = 0
				if (kind == 0 || SceneData.AnimationSet != 5)
					gun = DTSleep_BT2GunList.GetAt(kind) as Armor
				endIf
			endIf
		endIf
	endIf
	
	return gun
endFunction

Function InitSceneAndPlay()

	float angleOffset = 0.0
	float angleM = 0.0
	float angleF = 0.0
	float yOffM = 0.0
	float mainAngleOff = 0.0
	float secondAngleOff = 0.0
	float mainYOff = 0.0
	float secondYOff = 0.0
	bool turned = false
	int longScene = 0
	int genders = -1		; FM, 0 = MM, 1 = FF
	int otherActor = 0
	bool forceEVB = true
	DTAACSceneStageStruct[] seqStagesArray = None
	
	if (SceneData.AnimationSet == 7 && DTSleep_SettingUseBT2Gun.GetValueInt() > 0)
		if ((DTSConditionals as DTSleep_Conditionals).SavageCabbageVers >= 1.10)
			forceEVB = false
		endIf
	endIf
	
	if (SceneData.CompanionInPowerArmor)
		longScene = -1
	elseIf (SequenceID == 737 || SequenceID == 765)
		if ((DTSConditionals as DTSleep_Conditionals).SavageCabbageVers >= 1.1)
			longScene = 1
			if (SequenceID == 737 && DTSleep_IntimateSceneLen.GetValueInt() >= 3)
				longScene = 2
			endIf
		endIf
	elseIf (DTSleep_IntimateSceneLen.GetValueInt() >= 3)
		longScene = 1
	endIf
	if (SceneData.SecondMaleRole != None || SceneData.SecondFemaleRole != None)
		otherActor = 1
	endIf
	
	if (SceneData.SameGender && !SceneData.HasToyEquipped)
		genders = SceneData.MaleRoleGender
	endIf
	
	if (SceneData.IsCreatureType == 2 && ChanceDogQuits())
		StopSecondActorDone()
		StartTimer(5.0, DoggyQuitTimer)
		if (SequenceID >= 770)
			SequenceID = 740 ; dance
		endIf
	endIf
	
	if (SequenceID >= 500 && DTSConditionals.ImaPCMod)
		seqStagesArray = DTSleep_AACcatScript.GetSeqCatArrayForSequenceID(SequenceID, longScene, genders, otherActor, forceEVB)
	endIf
	
	SceneRunning = 1
	
	if (seqStagesArray != None)
		; get initial offsets to position characters
		angleM = seqStagesArray[0].MAngleOffset
		angleF = seqStagesArray[0].FAngleOffset
		yOffM = seqStagesArray[0].MPosYOffset
		if (otherActor > 0 && seqStagesArray[0].OAnimFormID > 0)
			; require third actor
			if (ThirdActor == None)
				Debug.Trace("[DTSleep_PlayAAC] missing ThirdActor for scene: " + SequenceID)
			endIf
		elseIf (ThirdActor != None)
			Debug.Trace("[DTSleep_PlayAAC] clearing Third actor -- not needed for scene!")
			ThirdActor = None
		endIf
	endIf
	
	if (MainActor == SceneData.MaleRole)
		mainAngleOff = angleOffset + angleM
		mainYOff = yOffM
	else
		mainAngleOff = angleOffset + angleF
	endIf
	
	if (SecondActor != None)
		; first move second actor close, but out of talk-too-much range
		SecondActor.MoveTo(MainActor, 0.0, -70.0, 0.0, true)
		if (SecondActor == SceneData.MaleRole)
			secondAngleOff = angleOffset + angleM
			secondYOff = yOffM
		else
			secondAngleOff = angleOffset + angleF
		endIf
	endIf
	
	if (SceneData.FemaleMarker != None)
		PlayerOriginMarkerRef = DTSleep_CommonF.PlaceFormAtObjectRef(DTSleep_MainNode, PlayerRef)
		
		DTSleep_CommonF.MoveActorToObject(PlayerRef, SceneData.FemaleMarker)
		Utility.Wait(0.2)
	endIf
	
	; in other file for easy access
	(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).MoveActorsToAACPositions(MainActor, SecondActor, ThirdActor, mainYOff, mainAngleOff, secondAngleOff)

	;Debug.Trace("[DTSleep_PlayAAC] actors (MST) " + MainActor + "/" + SecondActor + "/" + ThirdActor)

	;if (SecondActor != None)
	;	;SecondActor.SetRestrained(true)
	;	SecondActor.PlayIdle(LooseIdleStop)
	;	Utility.Wait(0.2)
	;endIf
	
	; fade-in
	Game.FadeOutGame(false, true, 0.67, 2.1)
		
	; Play
	if (SequenceID == 99 || SequenceID == 548)

		PlaySingleStage(SceneData.MaleRole, SceneData.FemaleRole, None, DTSleep_TRRGTEmbraceMIdle, DTSleep_TRRGTEmbraceFIdle, None, 18.0)
		Utility.Wait(0.2)
	
		SceneRunning = 0
		StopAnimationSequence()
		
	elseIf (SequenceID == 98)
	
		PlaySingleStage(SceneData.MaleRole, SceneData.FemaleRole, None, DTSleep_TRRGTKissingMIdle, DTSleep_TRRGTKissingFIdle, None, 18.0)
		Utility.Wait(0.2)
	
		SceneRunning = 0
		StopAnimationSequence()
		
	elseIf (SequenceID <= 97 || SequenceID == 549)
		PlaySingleStage(SceneData.MaleRole, SceneData.FemaleRole, None, DTSleep_TRRGTEmbraceMIdle, DTSleep_TRRGTEmbraceFIdle, None, 8.0)
		
		PlaySingleStage(SceneData.MaleRole, SceneData.FemaleRole, None, DTSleep_TRRGTKissingMIdle, DTSleep_TRRGTKissingFIdle, None, 12.0)
		
		PlaySingleStage(SceneData.MaleRole, SceneData.FemaleRole, None, DTSleep_TRRGTEmbraceMIdle, DTSleep_TRRGTEmbraceFIdle, None, 8.0)
	
		Utility.Wait(0.2)
		SceneRunning = 0
		StopAnimationSequence()
	else
		
		PlaySequence(seqStagesArray)
	endIf

endFunction

Function PlayDogQuit()

	PlayDogReaction()
	Utility.Wait(1.0)
	PlayerRef.SayCustom(PlayerHackFailSubtype, None)	
endFunction

Function PlayDogReaction()

	int rand = Utility.RandomInt(1, 8)
	if (rand <= 3)
		DogmeatIdles.BarkCurious()
	elseIf (rand == 4)
		DogmeatIdles.BarkPlayful()
	elseIf (rand == 5)
		DogmeatIdles.WhimperAttention()
	elseIf (rand == 6)
		DogmeatIdles.HowlPlayful()
	else
		DogmeatIdles.BarkPlayful()
	endIf
	
endFunction

Function PlaySequence(DTAACSceneStageStruct[] seqStagesArray)

	;Debug.Trace("[DTSleep_PlayAAC] playSequence " + SequenceID + " with " + MainActor + ", " + SecondActor)
	if (MainActor == None || SceneData == None)
		StopAnimationSequence()
		return
	endIf
	
	Armor gunArmor = None
	int gunIndex = -1
	float waitSecs = 11.0
	float startSecs = 9.7
	
	int seqLen = seqStagesArray.Length
	int pingPongCount = DTSleep_IntimateSceneLen.GetValueInt() - 1
	if (seqStagesArray[0].StageTime > 0.0)
		startSecs = seqStagesArray[0].StageTime
	endIf
	
	if (seqLen == 1)
		waitSecs = 24.0
	endIf

	if (seqLen <= 3)
		pingPongCount = 0
	elseIf (seqLen > 2 && startSecs <= 13.0 && waitSecs < 13.0 && seqLen <= 5)
		pingPongCount += 1
	endIf
	
	int seqCount = 0
	while (seqCount < seqLen && SceneData.Interrupted <= 0 && SceneRunning > 0)
		; wait
		if (seqCount == 0)
			waitSecs = startSecs
		elseIf (seqCount == seqLen - 1)
			waitSecs = 8.33
		else
			waitSecs = SceneData.WaitSecs
			if (seqStagesArray[seqCount].StageTime > 0.0)
				waitSecs = seqStagesArray[seqCount].StageTime
			endIf
		endIf
		; armor gun
		;if (seqStagesArray[seqCount].ArmorNudeAGun != gunIndex)
		;	gunIndex = seqStagesArray[seqCount].ArmorNudeAGun
		;	gunArmor = GetArmorNudeGun(gunIndex)
		;endIf
		
		PlayAnimAtStage(seqStagesArray[seqCount], SceneData.MaleRole, SceneData.FemaleRole, ThirdActor, waitSecs)
		
		if (pingPongCount > 0 && seqCount == (seqLen - 2))
			pingPongCount -= 1
			seqCount = seqLen - 4
		endIf
		
		if (SceneData.IsCreatureType == 2 && SecondActor != None && seqCount < (seqLen - 1))
			
			;DTSleep_CommonF.MoveActorFacingDistance(SecondActor, -60.0)
			DTSleep_CommonF.MoveActorToObject(SecondActor, MainActorOriginMarkRef, 0.0, -36.0)
			Utility.Wait(0.2)
			SecondActor.PlayIdle(LooseIdleStop)
			Utility.Wait(0.67)
			DTSleep_CommonF.MoveActorToObject(SecondActor, MainActor, 0.0, 0.0)
		endIf
	
		seqCount += 1
	endWhile
	
	Utility.Wait(0.2)
	
	SceneRunning = 0

	StopAnimationSequence()
endFunction

Function PlayAnimAtStage(DTAACSceneStageStruct stage, Actor mActor, Actor fActor, Actor oActor, float waitSecs)

	if (fActor != None && stage.FAnimFormID > 0 && SceneRunning > 0)
	
		if (stage.StageTime > 0.0)
			waitSecs = stage.StageTime
		endIf
		
		if (SecondActor == None && mActor != None && fActor != None)
			if (MainActor == mActor)
				fActor = None
			else
				mActor = None
			endIf
		endIf
		
		;Debug.Trace("[DTSleep_PlayAAC] stage " + stage.StageNum + ", waitSecs = " + waitSecs)
		
		Idle a2 = None
		Idle a1 = Game.GetFormFromFile(stage.FAnimFormID, stage.PluginName) as Idle
		Idle a3 = None
		
		if (stage.MAnimFormID > 0)
			a2 = Game.GetFormFromFile(stage.MAnimFormID, stage.PluginName) as Idle
		endIf
		if (stage.OAnimFormID > 0)
			a3 = Game.GetFormFromFile(stage.OAnimFormID, stage.PluginName) as Idle
		endIf
		
		if (a1 != None)
		
			if (stage.ArmorNudeAGun != LastGunAIndex)
				LastGunAIndex = stage.ArmorNudeAGun
				Armor armS1 = GetArmorNudeGun(stage.ArmorNudeAGun)
				;Debug.Trace("[DTSleep_PlayAAC] got armor-nude index " + stage.ArmorNudeAGun + " armor " + armS1)
				if (MaleRoleSex < 0 && mActor != None)
					MaleRoleSex = (mActor.GetLeveledActorBase() as ActorBase).GetSex()
				endIf
				if (armS1 != None && mActor != None && MaleRoleSex == 0)
					mActor.EquipItem(armS1, true, true)
					
				endIf
			endIf
			if (oActor != None && stage.ArmorNudeBGun >= 0 && LastGunBIndex != stage.ArmorNudeBGun)
				LastGunBIndex = stage.ArmorNudeBGun
				Armor armB1 = GetArmorNudeGun(stage.ArmorNudeBGun)
				if (armB1 != None)
					oActor.EquipItem(armB1, true, true)
				endIf
			endIf
			
			PlaySingleStage(mActor, fActor, oActor, a2, a1, a3, waitSecs)
			
		else
			Debug.Trace("[DTSleep_PlayAAC] missing idles for stage " + stage.StageNum + " formIDs: (" + stage.MAnimFormID + "," + stage.FAnimFormID + ") for plugin " + stage.PluginName)
		endIf
	else
		Debug.Trace("[DTSleep_PlayAAC] nothing to play for stage " + stage)
	endIf

endFunction

Function PlaySingleStage(Actor mActor, Actor fActor, Actor oActor, Idle mIdle, Idle fIdle, Idle oIdle, float waitSecs)

	if (mActor != None || fActor != None)
	
		;Debug.Trace("[DTSleep_PlayAAC] play idles " + mIdle + ", " + fIdle + " mActor: " + mActor + ", fActor: " + fActor)
			
		if (fIdle != None)

			if (mActor != None && mIdle != None)
				mActor.PlayIdle(mIdle)
			endIf
			if (fActor != none)
				fActor.PlayIdle(fIdle)
			endIf
			
			if (oActor != None && oIdle != None)
				oActor.PlayIdle(oIdle)
			endIf
			
			WaitOnScene(waitSecs)
		endIf
	endIf
endFunction


Function RemoveLeitoGuns(Actor aActor)
	;Debug.Trace("[DTSleep_PlayAAC] RemoveLeitoGuns")
	
	if (DTSleep_SettingUseBT2Gun.GetValueInt() > 0)
		RemoveBT2Guns(aActor)
	endIf	
	
	if (DTSleep_LeitoGunList != None && DTSleep_SettingUseLeitoGun.GetValueInt() > 0)
	
		int len = DTSleep_LeitoGunList.GetSize()
		int idx = 0
		while (idx < len)
			Armor gun = DTSleep_LeitoGunList.GetAt(idx) as Armor
			if (gun != None)
				int count = aActor.GetItemCount(gun)
				if (count > 0)
					;Debug.Trace("[DTSleep_PlayAAC] removing nude gun: " + gun)
					aActor.UnequipItem(gun as Form, false, true)
					aActor.RemoveItem(gun as Form, count, true, None)
				endIf
			endIf
			idx += 1
		endWhile
	endIf
EndFunction

Function RemoveBT2Guns(Actor aActor)
	if (DTSleep_BT2GunList != None)
		int len = DTSleep_BT2GunList.GetSize()
		if (len > 3 && DTSleep_SettingSynthHuman.GetValueInt() < 2)
			len = 3
		endIf
		int idx = 0
		while (idx < len)
			Armor gun = DTSleep_BT2GunList.GetAt(idx) as Armor
			if (gun != None)
				int count = aActor.GetItemCount(gun)
				if (count > 0)
					;Debug.Trace("[DTSleep_PlayAAC] removing nude gun: " + gun)
					aActor.UnequipItem(gun as Form, false, true)
					aActor.RemoveItem(gun as Form, count, true, None)
				endIf
			endIf
			idx += 1
		endWhile
	endIf
endFunction

Function StopActor(Actor aActor)
	if (aActor != None)
		;Debug.Trace("[DTSleep_PlayAAC] stop actor " + aActor)
		aActor.PlayIdle(LooseIdleStop)
	endIf
	
endFunction

Function StopSecondActorDone()

	; letting actor go early
	if (SecondActor != None)
		;Debug.Trace("[DTSleep_PlayAAC] stop SecondActor Done")
		SecondActor.StopTranslation()
		SecondActor.MoveTo(SecondActorOriginMarkRef, 0.0, 0.0, 0.0, true)
		
		if ((SecondActor.GetLeveledActorBase() as ActorBase).GetSex() == 0)
			RemoveLeitoGuns(SecondActor)
		endIf
		
		SecondActor.SetGhost(false)
		SecondActor.PlayIdle(LooseIdleStop)
		SecondActor.ChangeAnimFaceArchetype()
		SecondActor.SetAnimationVariableBool("bHumanoidFootIKDisable", false)
		SecondActor.SetAvoidPlayer(true)
		
		
		SecondActor = None
	endIf
endFunction

Function StopAnimationSequence()
	;Debug.Trace("[DTSleep_PlayAAC] StopSequence")
	
	float fadeTime = 1.75
	if (SceneData.Interrupted > 0)
		fadeTime = 0.50
	elseIf (SequenceID < 100)
		fadeTime = 0.86
	endIf
	Game.FadeOutGame(true, true, 0.0, fadeTime, true)
	Utility.Wait(fadeTime - 0.25)
	; use controller fade since game-fade sometimes fails - controller will fade-in
	(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).FadeOutSec(0.25)
	
	if (SceneRunning > 0)
		SceneRunning = 0
		Utility.Wait(1.0)
	endIf
	StopActor(MainActor)
	StopActor(SecondActor)
	StopActor(ThirdActor)
	Utility.Wait(fadeTime * 0.5)
	Game.FadeOutGame(false, true, 0.0, 0.5)  ; remove game fade
	
	self.Dispel()
endFunction

Function WaitOnScene(float waitSecs)

	if (waitSecs < 5.0)
		Utility.Wait(waitSecs)
	else
		float fractionSecs = waitSecs - Math.Floor(waitSecs)
		int w = 0
		while (w < (waitSecs as int) && SceneData.Interrupted <= 0 && SceneRunning)
			Utility.Wait(1.0)
			w += 1
		endWhile
		if (fractionSecs > 0.1)
			Utility.Wait(fractionSecs)
		endIf
	endIf

endFunction
