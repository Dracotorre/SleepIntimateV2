Scriptname DTSleep_PlayCrazyGIdle extends ActiveMagicEffect

; *********************
; script by DracoTorre
; Sleep Intimate
;
; plays animated idles by Crazy
; requires plugin, "Crazy_Animations_Gun.esp"
; 
; casting script should ensure have appropriate actors positioned and choose sequence by ID
; actors expected to be undressed
;
; SceneData holds actors, sequence length
; Idles are held in FormLists and retrieved based in ID-to-index

Group B_Globals
GlobalVariable property DTSleep_IntimateIdleID auto Mandatory
{expected 200 - 202 for bed; 250 - 251 for standing }
GlobalVariable property DTSleep_IntimateSceneLen auto
GlobalVariable property DTSleep_SettingUseLeitoGun auto const
FormList property DTSleep_LeitoGunList auto const
EndGroup

Group A_GameData
Actor property PlayerRef auto const Mandatory
DTSleep_SceneData property SceneData auto const
DTSleep_Conditionals property DTSConditionals auto
Keyword property AnimFaceArchetypeHappy auto const Mandatory
Idle property LooseIdleStop auto const Mandatory
EndGroup

Group C_AnimSeqLists
FormList property DTSleep_CrazyGunBedFemaleList auto const
FormList property DTSleep_CrazyGunBedMaleList auto const
FormList property DTSleep_CrazyGunStandFemaleList auto const
FormList property DTSleep_CrazyGunStandMaleList auto const
EndGroup

; 200 - missionary
; 202 - DDogNormBed
; 203 - doggy
; 204 - riding
; 250 - Mbate
; 251 - HandJob

; ---------- hidden ----------
Actor property MainActor auto hidden
Actor property SecondActor auto hidden
int property SequenceID auto hidden


; *************************
;          variables

InputEnableLayer DTSleepPlayCrazyInputLayer
int SeqLimitTimerID = 101 const

; ********************************************
; *****                Events       ***********
;

Event OnTimer(int aiTimerID)
	if (aiTimerID == SeqLimitTimerID)
		StopAnimationSequence()
	endIf
endEvent

Event OnMenuOpenCloseEvent(string asMenuName, bool abOpening)
    if (asMenuName== "PipboyMenu")
	
		UnregisterForMenuOpenCloseEvent("PipboyMenu")
		
		StopAnimationSequence()
		
	endIf
EndEvent

; begin animations
; second actor must be akfActor (target) and not player in two-person sequences
;
Event OnEffectStart(Actor akfActor, Actor akmActor)
	Debug.Trace("[DTSleep_PlayCrazyGIdle] OnEffectStart " + akfActor + ", " + akmActor)
	SequenceID = DTSleep_IntimateIdleID.GetValueInt()
	if (akfActor && akfActor != PlayerRef)
		SecondActor = akfActor
		MainActor = akmActor
		Weapon weapItem = SecondActor.GetEquippedWeapon()
		if (weapItem != None)
			SecondActor.UnequipItem(weapItem, false, true)
		endIf
		weapItem = MainActor.GetEquippedWeapon()					; v2.71.1
		if (weapItem != None)
			MainActor.UnequipItem(weapItem, false, true)
		endIf
		SecondActor.AllowPCDialogue(false)
		SecondActor.SetRestrained()
		SecondActor.SetAnimationVariableBool("bHumanoidFootIKDisable", true)
		SecondActor.SetAvoidPlayer(true)
		SecondActor.ChangeAnimFaceArchetype(AnimFaceArchetypeHappy)
	else
		MainActor = akfActor
		Debug.Trace("[DTSleep_PlayCrazyGIdle] caster only play ")
	endIf
	
	if (MainActor)
		DTSleepPlayCrazyInputLayer = InputEnableLayer.Create()
		
		; https://www.creationkit.com/fallout4/index.php?title=DisablePlayerControls_-_InputEnableLayer
		; movement, fighting, camSwitch, Looking, sneaking, menus, activate, journal, VATS, Favs, running
		; disable movement may interfere with cam zoom
		
		Utility.Wait(0.2)
		;            SleepInputLayer                     move,  fight, camSw, look, snk, menu, act, journ, Vats, Favs, run
		DTSleepPlayCrazyInputLayer.DisablePlayerControls(true, true, true, false, true, false, true, true, true, true, true)
		MainActor.ChangeAnimFaceArchetype(AnimFaceArchetypeHappy)
		MainActor.SetAnimationVariableBool("bHumanoidFootIKDisable", true)
		
		; fade-in
		Game.FadeOutGame(false, true, 0.67, 2.1)
		
		RegisterForMenuOpenCloseEvent("PipboyMenu")
		PlaySequence()
	else
		StopAnimationSequence()
	endIf
endEvent

; end animation - clean up
Event OnEffectFinish(Actor akfActor, Actor akmActor)
	Debug.Trace("[DTSleep_PlayCrazyGIdle] OnEffectFinish begin")
	UnregisterForMenuOpenCloseEvent("PipboyMenu")

	if (MainActor)
		MainActor.ChangeAnimFaceArchetype()
		MainActor.SetAnimationVariableBool("bHumanoidFootIKDisable", false)
		RemoveLeitoGuns(MainActor)
	endIf
	if (SecondActor != None)
		SecondActor.AllowPCDialogue(true)
		SecondActor.ChangeAnimFaceArchetype()
		SecondActor.SetAnimationVariableBool("bHumanoidFootIKDisable", false)
		SecondActor.SetAvoidPlayer(true)
		SecondActor.SetRestrained(false)
		RemoveLeitoGuns(SecondActor)
	endIf
	if (DTSleepPlayCrazyInputLayer)
		DTSleepPlayCrazyInputLayer.EnablePlayerControls()
		Utility.Wait(0.05)
	else
		Debug.Trace("[DTSleep_PlayCrazyGIdle] NO input layer!!!")
	endIf
	
	MainActor = None
	SecondActor = None
	DTSleepPlayCrazyInputLayer = None
endEvent

; ********************************************
; *****                Functions       ***********
;

; 0 = normal, 1 = up, 2 = down
Armor Function GetLeitoGun(int kind)
	Armor gun = None
	
	; v2.54 - check body swap restrictions
	if (SceneData.MaleBodySwapEnabled <= 0)
		return None
	endIf
	if (DTSleep_SettingUseLeitoGun.GetValue() > 0)
	
		if (SceneData.MaleRole == PlayerRef || SceneData.FemaleRole == SecondActor)
			if (DTSConditionals.IsUniquePlayerMaleActive)
				kind += 3
			endIf
		elseIf (DTSConditionals.IsUniqueFollowerMaleActive)
			if (SceneData.MaleRoleCompanionIndex > 0)
				kind += (3 * SceneData.MaleRoleCompanionIndex)
			endIf
		endIf
		
		if (kind >= 0 && DTSleep_LeitoGunList && DTSleep_LeitoGunlist.GetSize() > kind)
			gun = DTSleep_LeitoGunList.GetAt(kind) as Armor
		endIf
	endIf
	
	return gun
endFunction

Function PlaySequence()
	Debug.Trace("[DTSleep_PlayCrazyGIdle] playSequence " + SequenceID)
	if (!MainActor || SceneData == None)
		StopAnimationSequence()
		return
	endIf
	
	if (SequenceID < 250)
		; bed sequences
		if (SceneData.MaleRole && SceneData.FemaleRole)
			if (SequenceID <= 201)
				PlayMissionarySeq(SceneData.MaleRole, SceneData.FemaleRole)
			elseIf (SequenceID == 202)
				PlayPoundSeq(SceneData.MaleRole, SceneData.FemaleRole)
			elseIf (SequenceID == 203)
				PlayDDogNormBedSeq(SceneData.MaleRole, SceneData.FemaleRole)
			elseIf (SequenceID >= 204)
				PlayRidingSeq(SceneData.MaleRole, SceneData.FemaleRole)
			endIf
		endIf
	elseIf (SequenceID == 250)
		if (SceneData.SameGender)
			if (SceneData.MaleRoleGender == 0)
				PlayMasterbateMalesSeq(SceneData.MaleRole, SceneData.FemaleRole)
			else
				if (SceneData.HasToyEquipped)
					SceneData.MaleRole.UnequipItem(SceneData.ToyArmor, false, true)
				endIf
				PlayMasterbateFemalesSeq(SceneData.MaleRole, SceneData.FemaleRole)
			endIf
		else
			PlayMasterbateSeq(SceneData.MaleRole, SceneData.FemaleRole)
		endIf

	elseIf (SequenceID >= 251)
		PlayHandJobSeq(SceneData.MaleRole, SceneData.FemaleRole)
	endIf
	Utility.Wait(0.2)

	StopAnimationSequence()
endFunction

Function PlayPairSequenceLists(int seqIndex, Actor mActor, Actor fActor, FormList mList, FormList fList, float waitSecs)
	if (mActor && fActor && mList && fList)
	
		if (DTSleep_SettingUseLeitoGun.GetValue() > 0)
			Armor lGun = GetLeitoGun(0)
			mActor.EquipItem(lGun, true, true)
		endIf
	
		int seqLen = mList.GetSize()
		if (seqLen == 0 || seqLen != fList.GetSize())
			Debug.Trace("[DTSleep_PlayCrazyGIdle] mismatch male-female list lengths!!")
			return
		endIf
		int seqTimeMult = DTSleep_IntimateSceneLen.GetValueInt()
		if (seqTimeMult <= 0)
			waitSecs -= 22.0
		elseIf (seqTimeMult == 2)
			waitSecs += 22.0
		elseIf (seqTimeMult > 2)
			waitSecs += 44.0
		endIf
		;Debug.Trace("[DTSleep_PlayCrazyGIdle] playSeq ")
		if (seqIndex >= 0 && seqIndex < seqLen)
			Idle a2 = mList.GetAt(seqIndex) as Idle
			Idle a1 = fList.GetAt(seqIndex) as Idle
			if (a1 && a2)
				
				fActor.PlayIdle(a1)
				mActor.PlayIdle(a2)
				
				Utility.Wait(waitSecs)
			endIf
		else
			Debug.Trace("[DTSleep_PlayCrazyGIdle] Bad Seq ID " + seqIndex + " for length " + seqLen)
		endIf
	endIf
endFunction

; 200 - MissionBed
; 201 - Pound
; 202 - DDogNormBed
; 203 - Riding 

; 250 - Mbate
; 251 - HandJob


Function PlayRidingSeq(Actor mActor, Actor fActor)
	PlayPairSequenceLists(3, mActor, fActor, DTSleep_CrazyGunBedMaleList, DTSleep_CrazyGunBedFemaleList, 30.0)
endFunction

Function PlayPoundSeq(Actor mActor, Actor fActor)
	
	PlayPairSequenceLists(1, mActor, fActor, DTSleep_CrazyGunBedMaleList, DTSleep_CrazyGunBedFemaleList, 30.0)
endFunction

Function PlayDDogNormBedSeq(Actor mActor, Actor fActor)
	
	PlayPairSequenceLists(2, mActor, fActor, DTSleep_CrazyGunBedMaleList, DTSleep_CrazyGunBedFemaleList, 30.0)
endFunction

Function PlayHandJobSeq(Actor mActor, Actor fActor)
	PlayPairSequenceLists(0, mActor, fActor, DTSleep_CrazyGunStandMaleList, DTSleep_CrazyGunStandFemaleList, 30.0)
endFunction

Function PlayMasterbateSeq(Actor mActor, Actor fActor)
	PlayPairSequenceLists(1, mActor, fActor, DTSleep_CrazyGunStandMaleList, DTSleep_CrazyGunStandFemaleList, 30.0)
endFunction

Function PlayMasterbateFemalesSeq(actor mainActor, Actor secondActor)
	PlayPairSequenceLists(1, mainActor, secondActor, DTSleep_CrazyGunStandFemaleList, DTSleep_CrazyGunStandFemaleList, 30.0)
endFunction

Function PlayMasterbateMalesSeq(actor mainActor, Actor secondActor)
	PlayPairSequenceLists(1, mainActor, secondActor, DTSleep_CrazyGunStandMaleList, DTSleep_CrazyGunStandMaleList, 30.0)
endFunction

Function PlayMissionarySeq(Actor mActor, Actor fActor)
	PlayPairSequenceLists(0, mActor, fActor, DTSleep_CrazyGunBedMaleList, DTSleep_CrazyGunBedFemaleList, 30.0)
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
					aActor.UnequipItem(gun as Form, false, true)
					aActor.RemoveItem(gun as Form, count, true, None)
				endIf
			endIf
			idx += 1
		endWhile
	endIf
EndFunction

Function StopActor(Actor aActor)
	if (aActor)
		aActor.PlayIdle(LooseIdleStop)
	endIf
endFunction

Function StopAnimationSequence()
	Debug.Trace("[DTSleep_PlayCrazyGIdle] StopSequence")
	StopActor(MainActor)
	StopActor(SecondActor)
	Utility.Wait(0.8)
	
	
	;Utility.Wait(0.2)
	if (self != None)
		self.Dispel()
	endIf
endFunction