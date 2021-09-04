ScriptName DTSleep_PlayLeitoIdle extends ActiveMagicEffect

; *********************
; script by DracoTorre
; Sleep Intimate
;
; plays sequences of animated idles by Leito
; requires plugin, "FO4 Animations By Leito"
; 
; casting script should ensure have appropriate actors positioned and choose sequence by ID
; actors expected to be undressed, but this script includes nude suits for males
;
; SceneData holds actors, sequence length
; Idles are stored in FormLists of multi-stage sequence by name identified by ID
;
; 24 scenes

Group B_Globals
;GlobalVariable property DTSleep_WasPlayerThirdPerson auto Mandatory
GlobalVariable property DTSleep_IntimateIdleID auto Mandatory
{expected < 150 pair bed sequences, 150+ for pair standing sequences}
GlobalVariable property DTSleep_IntimateSceneLen auto
GlobalVariable property DTSleep_IntimateDogEXP auto
GlobalVariable property DTSleep_SettingUseLeitoGun auto const
GlobalVariable property DTSleep_SettingUseBT2Gun auto const
EndGroup

Group A_GameData
Actor property PlayerRef auto const
DTSleep_SceneData property SceneData auto const
DTSleep_Conditionals property DTSConditionals auto
Keyword property AnimFaceArchetypeHappy auto const Mandatory
Keyword Property AnimFaceArchetypeSinisterSmile Auto Const
Keyword Property AnimFaceArchetypeInPain Auto Const
Keyword Property AnimFaceArchetypeFlirting Auto Const
Keyword property PlayerHackFailSubtype auto const
;Keyword property AnimFaceArchetypeSinisterSmile auto const Mandatory
Idle property LooseIdleStop auto const Mandatory
FormList property DTSleep_StrapOnList auto const
FormList property DTSleep_LeitoGunList auto const
FormList property DTSleep_BT2GunList auto const
Armor property DTSleep_NudeSuitPlayerUp auto const
EndGroup

Group C_AnimSeqLists
FormList property DTSleep_LeitoBlowjobA1List auto const
FormList property DTSleep_LeitoBlowjobA2List auto const
FormList property DTSleep_LeitoCarryA1List auto const
FormList property DTSleep_LeitoCarryA2List auto const
FormList property DTSleep_LeitoCowgirl1A1List auto const
FormList property DTSleep_LeitoCowgirl1A2List auto const
FormList property DTSleep_LeitoCowgirl2A1List auto const
FormList property DTSleep_LeitoCowgirl2A2List auto const
FormList property DTSleep_LeitoCowgirl3A1List auto const
FormList property DTSleep_LeitoCowgirl3A2List auto const
FormList property DTSleep_LeitoCowgirl4A1List auto const
FormList property DTSleep_LeitoCowgirl4A2List auto const
FormList property DTSleep_LeitoCowgirlRev1A1List auto const
FormList property DTSleep_LeitoCowgirlRev1A2List auto const
FormList property DTSleep_LeitoCowgirlRev2A1List auto const
FormList property DTSleep_LeitoCowgirlRev2A2List auto const
FormList property DTSleep_LeitoDoggy1A1List auto const
FormList property DTSleep_LeitoDoggy1A2List auto const
FormList property DTSleep_LeitoDoggy2A1List auto const
FormList property DTSleep_LeitoDoggy2A2List auto const
FormList property DTSleep_LeitoStandDoggy1A1List auto const
FormList property DTSleep_LeitoStandDoggy1A2List auto const
FormList property DTSleep_LeitoStandDoggy2A1List auto const
FormList property DTSleep_LeitoStandDoggy2A2List auto const
FormList property DTSleep_LeitoMissionary1A1List auto const
FormList property DTSleep_LeitoMissionary1A2List auto const
FormList property DTSleep_LeitoMissionary2A1List auto const
FormList property DTSleep_LeitoMissionary2A2List auto const
FormList property DTSleep_LeitoSpoonA1List auto const
FormList property DTSleep_LeitoSpoonA2List auto const
FormList property DTSleep_LeitoStrongMaleList auto const
FormList property DTSleep_LeitoStrongFemaleList auto const
FormList property DTSleep_LeitoCanineDogList auto const
FormList property DTSleep_LeitoCanineFemaleList auto const
FormList property DTSleep_LeitoCanine2DogList auto const
FormList property DTSleep_LeitoCanine2FemaleList auto const
EndGroup

; ---------- hidden ----------
Actor property MainActor auto hidden
Actor property SecondActor auto hidden
int property SequenceID auto hidden
int property ArmGunBodyType auto hidden


; *************************
;          variables

InputEnableLayer DTSleepPlayLeitoInputLayer
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
		
		Utility.Wait(0.5)
		StopAnimationSequence()
		
	endIf
EndEvent

; begin animations - 
; second actor must be akfActor (target) and not player in two-person sequences
;
Event OnEffectStart(Actor akfActor, Actor akmActor)

	;Debug.Trace("[DTSleep_PlayLeitoIdle] OnEffectStart")
	
	SequenceID = DTSleep_IntimateIdleID.GetValueInt()
	
	if (SequenceID >= 600)
		SequenceID = SequenceID - 500
		; v2.21 - change to prefer EVB
		if (DTSleep_SettingUseBT2Gun.GetValue() > 0.0 && SceneData.IsCreatureType <= 0 && DTSleep_SettingUseLeitoGun.GetValueInt() <= 0)
			ArmGunBodyType = 2
		else
			ArmGunBodyType = 1
		endIf
	else
		ArmGunBodyType = 1
	endIf
	
	if (akfActor != None && akfActor != PlayerRef)
		SecondActor = akfActor
		MainActor = akmActor
		
		CheckRemoveSecondActorWeapon(0.08)
		
		SecondActor.SetAnimationVariableBool("bHumanoidFootIKDisable", true)
		SecondActor.ChangeAnimFaceArchetype(AnimFaceArchetypeHappy)
	else
		MainActor = akfActor
		;Debug.Trace("[DTSleep_PlayLeito] caster only play ")
	endIf
	
	if (MainActor != None && (Debug.GetPlatformName() as bool))
		DTSleepPlayLeitoInputLayer = InputEnableLayer.Create()
		
		 Weapon mainW = MainActor.GetEquippedWeapon()					; v2.71.1
		 if (mainW != None)
			 MainActor.UnequipItem(mainW, false, true)
			 Utility.Wait(0.1)
		 endIf
		
		; https://www.creationkit.com/fallout4/index.php?title=DisablePlayerControls_-_InputEnableLayer
		; movement, fighting, camSwitch, Looking, sneaking, menus, activate, journal, VATS, Favs, running
		; disable movement may interfere with cam zoom
		
		;            SleepInputLayer                     move,  fight, camSw, look, snk, menu, act, journ, Vats, Favs, run
		DTSleepPlayLeitoInputLayer.DisablePlayerControls(true, true, true, false, true, false, true, true, true, true, true)
		
		; if player translated on bed (not ground) this causes shaking
		
		MainActor.SetAnimationVariableBool("bHumanoidFootIKDisable", true)
		MainActor.ChangeAnimFaceArchetype(AnimFaceArchetypeHappy)
	
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
	;Debug.Trace("[DTSleep_PlayLeitoIdle] OnEffectFinish begin")
	
	UnregisterForMenuOpenCloseEvent("PipboyMenu")

	if (MainActor != None)
		MainActor.ChangeAnimFaceArchetype()
		MainActor.SetAnimationVariableBool("bHumanoidFootIKDisable", false)

		if ((MainActor.GetLeveledActorBase() as ActorBase).GetSex() == 0)
			RemoveLeitoGuns(MainActor)
		endIf
	endIf
	if (SecondActor != None)
		SecondActor.ChangeAnimFaceArchetype()
		SecondActor.SetAnimationVariableBool("bHumanoidFootIKDisable", false)
		SecondActor.SetAvoidPlayer(true)
		SecondActor.SetRestrained(false)
		if ((SecondActor.GetLeveledActorBase() as ActorBase).GetSex() == 0)
			RemoveLeitoGuns(SecondActor)
		endIf
	endIf
	if (DTSleepPlayLeitoInputLayer != None)
		DTSleepPlayLeitoInputLayer.EnablePlayerControls()
		Utility.Wait(0.05)
		DTSleepPlayLeitoInputLayer.Delete()
	else
		Debug.Trace("[DTSleep_PlayLeitoIdle] NO input layer!!!")
	endIf
	
	MainActor = None
	SecondActor = None
	DTSleepPlayLeitoInputLayer = None
endEvent

Event OnDeath(Actor akKiller)
	self.Dispel()																
EndEvent

; ********************************************
; *****                Functions       ***********
;

Function CheckRemoveSecondActorWeapon(float waitSecs = 0.07)
	if (SecondActor != None)
		Weapon weapItem = SecondActor.GetEquippedWeapon()
		
		SecondActor.SetRestrained()
		if (weapItem)
			;Debug.Trace("[DTSleep_PlayLeito] removing secondActor weapon!")
			SecondActor.UnequipItem(weapItem, false, true)
			if (waitSecs > 0.0)
				Utility.Wait(waitSecs)
			endIf
		endIf
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
	
	; v2.54 - check body swap restrictions
	if (SceneData.MaleBodySwapEnabled <= 0)
		return None
	endIf
	
	int evbVal = DTSleep_SettingUseLeitoGun.GetValueInt()
	
	if (SceneData.IsCreatureType == 1)
		evbVal = 2
	elseIf (ArmGunBodyType == 2 && !DTSConditionals.IsUniquePlayerMaleActive)
		evbVal = DTSleep_SettingUseBT2Gun.GetValueInt()
	endIf
	
	if (ArmGunBodyType == 1 && kind > 0 && evbVal == 1)
		kind = 0
	endIf
	
	if (evbVal > 0 && SceneData.IsCreatureType != 2)
	
		if (SceneData.MaleRole == PlayerRef || SceneData.FemaleRole == SecondActor)
			if (ArmGunBodyType == 1 && DTSConditionals.IsUniquePlayerMaleActive)
				kind += 3
			;else
				;return DTSleep_NudeSuitPlayerUp
			endIf
		elseIf (DTSConditionals.IsUniqueFollowerMaleActive)
			if (SceneData.MaleRoleCompanionIndex > 0)
				kind += (3 * SceneData.MaleRoleCompanionIndex)
			endIf
		endIf
		
		if (kind >= 0)
			if (ArmGunBodyType == 1 && DTSleep_LeitoGunList != None && DTSleep_LeitoGunlist.GetSize() > kind)
				gun = DTSleep_LeitoGunList.GetAt(kind) as Armor
			elseIf (ArmGunBodyType == 2 && DTSleep_BT2GunList != None && DTSleep_BT2GunList.GetSize() > kind)
				gun = DTSleep_BT2GunList.GetAt(kind) as Armor
			endIf
		endIf
	endIf
	
	return gun
endFunction

Function PlayDogReaction()

	int rand = Utility.RandomInt(1, 8)
	if (rand <= 2)
		DogmeatIdles.BarkCurious()
	elseIf (rand == 3)
		DogmeatIdles.WhimperSad()
	elseIf (rand == 4)
		DogmeatIdles.BarkPlayful()
	elseIf (rand == 5)
		DogmeatIdles.WhimperAttention()
	elseIf (rand == 6)
		DogmeatIdles.HowlPlayful()
	else
		DogmeatIdles.BarkPlayful()
	endIf
	
	Utility.Wait(1.0)
	PlayerRef.SayCustom(PlayerHackFailSubtype, None)
	
endFunction

Function PlaySequence()
	;Debug.Trace("[DTSleep_PlayLeitoIdle] playSequence " + SequenceID)
	if (!MainActor || SceneData == None)
		StopAnimationSequence()
		return
	endIf
	
	if (SequenceID < 150)
		; bed sequences
		if (SceneData.MaleRole && SceneData.FemaleRole)
			if (SequenceID <= 100)
				if (DTSleep_IntimateSceneLen.GetValue() >= 2)
					PlayMissionaryMixSeq(SceneData.MaleRole, SceneData.FemaleRole)
				else
					PlayMissionary1Seq(SceneData.MaleRole, SceneData.FemaleRole)
				endIf
				
			elseIf (SequenceID == 101)
				;if (DTSleep_IntimateSceneLen.GetValue() >= 2)
				;	PlayMissionaryMixSeq(SceneData.MaleRole, SceneData.FemaleRole)
				;else
					PlayMissionary2Seq(SceneData.MaleRole, SceneData.FemaleRole)
				;endIf
			elseIf (SequenceID == 102)
				if (DTSleep_IntimateSceneLen.GetValue() >= 2)
					PlayDoggyMixSeq(SceneData.MaleRole, SceneData.FemaleRole)
				else
					PlayDoggy1Seq(SceneData.MaleRole, SceneData.FemaleRole)
				endIf
			elseIf (SequenceID == 103)
				if (DTSleep_IntimateSceneLen.GetValue() >= 2)
					PlayDoggyMixSeq(SceneData.MaleRole, SceneData.FemaleRole)
				else
					PlayDoggy2Seq(SceneData.MaleRole, SceneData.FemaleRole)
				endIf
			elseIf (SequenceID == 104)
				PlayCowgirlSeq(SceneData.MaleRole, SceneData.FemaleRole)
			elseIf (SequenceID == 105)
				PlayCowgirl2Seq(SceneData.MaleRole, SceneData.FemaleRole)
			elseIf (SequenceID == 106)
				if (DTSleep_IntimateSceneLen.GetValue() >= 2)
					PlayCowgirl3ExtrSeq(SceneData.MaleRole, SceneData.FemaleRole)
				else
					PlayCowgirl3Seq(SceneData.MaleRole, SceneData.FemaleRole)
				endIf
			elseIf (SequenceID == 107)
				if (DTSleep_IntimateSceneLen.GetValue() >= 2)
					PlayCowgirl3ExtrSeq(SceneData.MaleRole, SceneData.FemaleRole)
				else
					PlayCowgirl4Seq(SceneData.MaleRole, SceneData.FemaleRole)
				endIf
			elseIf (SequenceID == 108)
				PlayCowgirlReverse1Seq(SceneData.MaleRole, SceneData.FemaleRole)
			elseIf (SequenceID == 109)
				PlayCowgirlReverse2Seq(SceneData.MaleRole, SceneData.FemaleRole)
			elseIf (SequenceID >= 110)
				PlaySpoonSeq(SceneData.MaleRole, SceneData.FemaleRole)
			endIf
		endIf
	elseIf (SequenceID == 150)
		if (SceneData.HasToyEquipped == false)
			
			PlayBlowjobStandSeq(SceneData.MaleRole, SceneData.FemaleRole)
		endIf
	elseIf (SequenceID == 151)
		PlayStandDoggy1Seq(SceneData.MaleRole, SceneData.FemaleRole)
	elseIf (SequenceID == 152)
		PlayStandDoggy2Seq(SceneData.MaleRole, SceneData.FemaleRole)
	elseIf (SequenceID == 153)
		PlayStandDoggy3Mix(SceneData.MaleRole, SceneData.FemaleRole)
	elseIf (SequenceID >= 154 && SequenceID < 160)
		PlayCarrySeq(SceneData.MaleRole, SceneData.FemaleRole)
	elseIf (SequenceID == 160)
		PlayStrongCarry(SceneData.MaleRole, SceneData.FemaleRole)
	elseIf (SequenceID == 161)
		PlayStrongStandDoggy(SceneData.MaleRole, SceneData.FemaleRole)
	elseIf (SequenceID == 162)
		PlayStrongStandSideways(SceneData.MaleRole, SceneData.FemaleRole)
	elseIf (SequenceID >= 163 && SequenceID < 169)
		PlayStrongCarryReverse(SceneData.MaleRole, SceneData.FemaleRole)
	elseIf (SequenceID == 180)
		PlayFemaleMasterbate(SceneData.FemaleRole)
	elseIf (SequenceID == 181)
		PlayFemalePairMasterbate(SceneData.MaleRole, SceneData.FemaleRole)
	endIf
	Utility.Wait(0.2)


	StopAnimationSequence()
endFunction

Function PlayPairAnimFromListIndex(int listIndex, Actor mActor, Actor fActor, FormList mList, FormList fList, float waitSecs, Armor armS1 = None)

	if (mActor && fActor && mList && fList)
		int listLen = mList.GetSize()
		
		int mSex = (mActor.GetLeveledActorBase() as ActorBase).GetSex()
		if (armS1 != None && mSex == 0)
			mActor.EquipItem(armS1, true, true)
		endIf
		
		if (listIndex < 0 || listIndex > listLen)
			listIndex = 0
		endIf
		
		if (listIndex < listLen)
		
			Idle a2 = mList.GetAt(listIndex) as Idle
			Idle a1 = fList.GetAt(listIndex) as Idle
			
			;Debug.Trace("[DTSleep_PlayLeito] play idles " + a2 + ", " + a1 + " mActor: " + mActor)
			
			if (a1 && a2)
				; play second-actor first
				if (MainActor == mActor)
					fActor.PlayIdle(a1)
					mActor.PlayIdle(a2)
				else
					mActor.PlayIdle(a2)
					fActor.PlayIdle(a1)
				endIf
				
				Utility.Wait(waitSecs)
			endIf
		else
			Debug.Trace("[DTSleep_PlayLeito] listIndex outside range " + listIndex)
		endIf
	
	endIf
endFunction

Function PlaySingleAnimListIndex(int listIndex, Actor aActor, FormList aList, float waitSecs)

	if (aActor && aList)
		
		if (listIndex >= 0 && listIndex < aList.GetSize())
			
			Idle a1 = aList.GetAt(listIndex) as Idle
			
			if (a1)
				aActor.PlayIdle(a1)
				Utility.Wait(waitSecs)
			endIf
		endIf
	endIf

endFunction



; mActor is considered dominate
Function PlayPairSequenceLists(Actor mActor, Actor fActor, FormList mList, FormList fList, float waitSecs, int startCount = 0, Armor armS1 = None, Armor armS2 = None, Armor armS3 = None)
	if (mActor != None && fActor != None && mList != None && fList)
		int mSex = (mActor.GetLeveledActorBase() as ActorBase).GetSex()
		if (armS1 != None && mSex == 0)
			mActor.EquipItem(armS1, true, true)
		endIf
		int seqCount = startCount
		int seqTotalCount = 0
		int seqLen = mList.GetSize()
		int pingPongCount = DTSleep_IntimateSceneLen.GetValueInt() - 1
		if (waitSecs <= 13.0)
			pingPongCount += 1
		endIf
		
		while (seqCount < seqLen && SceneData.Interrupted <= 0)
					
			Idle a2 = mList.GetAt(seqCount) as Idle
			Idle a1 = fList.GetAt(seqCount) as Idle
			if (a1 && a2)
				if (mSex == 0)
					if (armS2 && seqCount == 1)
						mActor.EquipItem(armS2, true, true)
					elseIf (armS3 && seqCount == 2)
						mActor.EquipItem(armS3, true, true)
					endIf
				endIf
				
				if (seqTotalCount > seqLen)
					if (seqCount == 0)
						mActor.ChangeAnimFaceArchetype(AnimFaceArchetypeSinisterSmile)
						fActor.ChangeAnimFaceArchetype(AnimFaceArchetypeInPain)
					elseIf (seqCount == 1)
						mActor.ChangeAnimFaceArchetype(AnimFaceArchetypeHappy)
						fActor.ChangeAnimFaceArchetype(AnimFaceArchetypeHappy)
					endIf
				elseIf (seqCount == 1)
					fActor.ChangeAnimFaceArchetype(AnimFaceArchetypeFlirting)
				elseIf (seqCount == 2)
					fActor.ChangeAnimFaceArchetype(AnimFaceArchetypeHappy)
				endIf
				
				; play second-actor first
				if (MainActor == mActor)
					fActor.PlayIdle(a1)
					mActor.PlayIdle(a2)
				else
					mActor.PlayIdle(a2)
					fActor.PlayIdle(a1)
				endIf
				
				if (seqCount == 0)
					Utility.Wait(10.0)
				elseIf (seqCount == seqLen - 1)
					fActor.ChangeAnimFaceArchetype(AnimFaceArchetypeInPain)
					mActor.ChangeAnimFaceArchetype(AnimFaceArchetypeInPain)
					Utility.Wait(6.0)
				else
					if (pingPongCount > 0 && seqCount == 2)
						pingPongCount -= 1
						if (mSex == 0 && armS3 && armS2 == None && armS1)
							mActor.EquipItem(armS1 as Form, true, true)
						endIf
						seqCount = 0
					endIf
					Utility.Wait(waitSecs)
				endIf
			endIf
			
			seqCount += 1
			seqTotalCount += 1
		endWhile
	endIf
endFunction


Function PlayBlowjobStandSeq(Actor mActor, Actor fActor)
	Armor gunStart = GetArmorNudeGun(0)
	fActor.ChangeAnimFaceArchetype(AnimFaceArchetypeInPain)
	mActor.ChangeAnimFaceArchetype(AnimFaceArchetypeSinisterSmile)
	PlayPairSequenceLists(mActor, fActor, DTSleep_LeitoBlowjobA2List, DTSleep_LeitoBlowjobA1List, SceneData.WaitSecs, 0, gunStart)
endFunction

Function PlayCarrySeq(Actor mActor, Actor fActor)
	Armor gunStart = GetArmorNudeGun(1)
	PlayPairSequenceLists(mActor, fActor, DTSleep_LeitoCarryA2List, DTSleep_LeitoCarryA1List, SceneData.WaitSecs, 0, gunStart)
endFunction

Function PlayCowgirlSeq(Actor mActor, Actor fActor)
	Armor gunStart = GetArmorNudeGun(0)
	Armor gun2 = GetArmorNudeGun(1)
	fActor.ChangeAnimFaceArchetype(AnimFaceArchetypeFlirting)
	PlayPairSequenceLists(mActor, fActor, DTSleep_LeitoCowgirl1A2List, DTSleep_LeitoCowgirl1A1List, SceneData.WaitSecs, 0, gunStart, gun2)

endFunction

Function PlayCowgirl2Seq(Actor mActor, Actor fActor)
	Armor gunStart = GetArmorNudeGun(0)
	PlayPairSequenceLists(mActor, fActor, DTSleep_LeitoCowgirl2A2List, DTSleep_LeitoCowgirl2A1List, SceneData.WaitSecs, 0, gunStart)
endFunction

Function PlayCowgirl3Seq(Actor mActor, Actor fActor)
	Armor gunStart = GetArmorNudeGun(2)
	PlayPairSequenceLists(mActor, fActor, DTSleep_LeitoCowgirl3A2List, DTSleep_LeitoCowgirl3A1List, SceneData.WaitSecs, 0, gunStart)
endFunction

Function PlayCowgirl4Seq(Actor mActor, Actor fActor)
	Armor gunStart = GetArmorNudeGun(0)
	PlayPairSequenceLists(mActor, fActor, DTSleep_LeitoCowgirl4A2List, DTSleep_LeitoCowgirl4A1List, SceneData.WaitSecs, 0, gunStart)
endFunction

Function PlayCowgirl3ExtrSeq(Actor mActor, Actor fActor)
	Armor gunStart = GetArmorNudeGun(2)
	PlayPairAnimFromListIndex(0, mActor, fActor, DTSleep_LeitoCowgirl3A2List, DTSleep_LeitoCowgirl3A1List, 6.5, gunStart)
	PlayPairAnimFromListIndex(1, mActor, fActor, DTSleep_LeitoCowgirl3A2List, DTSleep_LeitoCowgirl3A1List, SceneData.WaitSecs, gunStart)
	gunStart = GetArmorNudeGun(0)
	PlayPairSequenceLists(mActor, fActor, DTSleep_LeitoCowgirl4A2List, DTSleep_LeitoCowgirl4A1List, SceneData.WaitSecs, 2, gunStart)
endFunction

Function PlayCowgirlReverse1Seq(Actor mActor, Actor fActor)
	Armor gunStart = GetArmorNudeGun(1)
	PlayPairSequenceLists(mActor, fActor, DTSleep_LeitoCowgirlRev1A2List, DTSleep_LeitoCowgirlRev1A1List, SceneData.WaitSecs, 0, gunStart)
endFunction

Function PlayCowgirlReverse2Seq(Actor mActor, Actor fActor)
	Armor gunStart = GetArmorNudeGun(1)
	PlayPairSequenceLists(mActor, fActor, DTSleep_LeitoCowgirlRev2A2List, DTSleep_LeitoCowgirlRev2A1List, SceneData.WaitSecs, 0, gunStart)
endFunction

Function PlayDoggy1Seq(Actor mActor, Actor fActor)
	Armor gunStart = GetArmorNudeGun(0)
	PlayPairSequenceLists(mActor, fActor, DTSleep_LeitoDoggy1A2List, DTSleep_LeitoDoggy1A1List, SceneData.WaitSecs, 0, gunStart)
EndFunction

Function PlayDoggy2Seq(Actor mActor, Actor fActor)
	Armor gunStart = GetArmorNudeGun(0)
	PlayPairSequenceLists(mActor, fActor, DTSleep_LeitoDoggy2A2List, DTSleep_LeitoDoggy2A1List, SceneData.WaitSecs, 0, gunStart)
EndFunction

Function PlayDoggyMixSeq(Actor mActor, Actor fActor)
	Armor gunStart = GetArmorNudeGun(0)
	PlayPairAnimFromListIndex(0, mActor, fActor, DTSleep_LeitoDoggy1A2List, DTSleep_LeitoDoggy1A1List, 6.5, gunStart)
	PlayPairAnimFromListIndex(1, mActor, fActor, DTSleep_LeitoDoggy1A2List, DTSleep_LeitoDoggy1A1List, SceneData.WaitSecs, gunStart)
	PlayPairSequenceLists(mActor, fActor, DTSleep_LeitoDoggy2A2List, DTSleep_LeitoDoggy2A1List, SceneData.WaitSecs, 2, gunStart)
endFunction

Function PlayMissionary1Seq(Actor mActor, Actor fActor)
	Armor gunStart = GetArmorNudeGun(1)
	PlayPairSequenceLists(mActor, fActor, DTSleep_LeitoMissionary1A2List, DTSleep_LeitoMissionary1A1List, SceneData.WaitSecs, 0, gunStart)
EndFunction	

Function PlayMissionary2Seq(Actor mActor, Actor fActor)
	Armor gunStart = GetArmorNudeGun(0)
	;Armor gun3 = GetArmorNudeGun(1)
	PlayPairSequenceLists(mActor, fActor, DTSleep_LeitoMissionary2A2List, DTSleep_LeitoMissionary2A1List, SceneData.WaitSecs, 0, gunStart)
EndFunction

Function PlayMissionaryMixSeq(Actor mActor, Actor fActor)
	Armor gunStart = GetArmorNudeGun(1)
	PlayPairAnimFromListIndex(0, mActor, fActor, DTSleep_LeitoMissionary1A2List, DTSleep_LeitoMissionary1A1List, 6.5, gunStart)
	PlayPairAnimFromListIndex(1, mActor, fActor, DTSleep_LeitoMissionary1A2List, DTSleep_LeitoMissionary1A1List, SceneData.WaitSecs, gunStart)
	gunStart = GetArmorNudeGun(0)
	PlayPairSequenceLists(mActor, fActor, DTSleep_LeitoMissionary2A2List, DTSleep_LeitoMissionary2A1List, SceneData.WaitSecs, 2, gunStart)
endFunction

Function PlaySpoonSeq(Actor mActor, Actor fActor)
	Armor gunStart = GetArmorNudeGun(1)
	PlayPairSequenceLists(mActor, fActor, DTSleep_LeitoSpoonA2List, DTSleep_LeitoSpoonA1List, SceneData.WaitSecs, 0, gunStart)
EndFunction

Function PlayStandDoggy1Seq(Actor mActor, Actor fActor)
	Armor gunStart = GetArmorNudeGun(1)
	PlayPairSequenceLists(mActor, fActor, DTSleep_LeitoStandDoggy1A2List, DTSleep_LeitoStandDoggy1A1List, SceneData.WaitSecs, 0, gunStart)
EndFunction

Function PlayStandDoggy2Seq(Actor mActor, Actor fActor)
	Armor gunStart = GetArmorNudeGun(0)
	PlayPairSequenceLists(mActor, fActor, DTSleep_LeitoStandDoggy2A2List, DTSleep_LeitoStandDoggy2A1List, SceneData.WaitSecs, 0, gunStart)
EndFunction

Function PlayStandDoggy3Mix(Actor mActor, Actor fActor)
	Armor gunStart = GetArmorNudeGun(1)
	Armor gunTwo = GetArmorNudeGun(0)
	
	PlayPairAnimFromListIndex(0, mActor, fActor, DTSleep_LeitoStandDoggy1A2List, DTSleep_LeitoStandDoggy1A1List, 9.2, gunStart)
	
	PlayPairSequenceLists(mActor, fActor, DTSleep_LeitoStandDoggy2A2List, DTSleep_LeitoStandDoggy2A1List, SceneData.WaitSecs, 1, gunTwo)
EndFunction

Function PlayStrongCarry(Actor mActor, Actor fActor)
	Armor gunStart = GetArmorNudeGun(1)
	Armor gunForward = GetArmorNudeGun(0)
	int sceneLen = DTSleep_IntimateSceneLen.GetValueInt()
	int sceneCount = 0
	
	PlayPairAnimFromListIndex(0, mActor, fActor, DTSleep_LeitoStrongMaleList, DTSleep_LeitoStrongFemaleList, 37.7, gunStart)
	
	while (sceneCount < sceneLen && SceneData.Interrupted <= 0)
	
		if (sceneCount == 0 || sceneCount == 2)
			PlayPairAnimFromListIndex(3, mActor, fActor, DTSleep_LeitoStrongMaleList, DTSleep_LeitoStrongFemaleList, (SceneData.WaitSecs * 2.0), gunForward)
		else
			PlayPairAnimFromListIndex(1, mActor, fActor, DTSleep_LeitoStrongMaleList, DTSleep_LeitoStrongFemaleList, (SceneData.WaitSecs * 2.0), gunStart)
		endIf
		
		sceneCount += 1
	endWhile
EndFunction

Function PlayStrongCarryReverse(Actor mActor, Actor fActor)
	Armor gunStart = GetArmorNudeGun(1)
	Armor gunForward = GetArmorNudeGun(0)
	int sceneLen = DTSleep_IntimateSceneLen.GetValueInt()
	int sceneCount = 0
	
	PlayPairAnimFromListIndex(1, mActor, fActor, DTSleep_LeitoStrongMaleList, DTSleep_LeitoStrongFemaleList, 37.7, gunStart)
	
	while (sceneCount < sceneLen && SceneData.Interrupted <= 0)
	
		if (sceneCount == 1)
			PlayPairAnimFromListIndex(1, mActor, fActor, DTSleep_LeitoStrongMaleList, DTSleep_LeitoStrongFemaleList, (SceneData.WaitSecs * 2.0), gunStart)
			
		elseIf (sceneCount == 2)
			
			PlayPairAnimFromListIndex(2, mActor, fActor, DTSleep_LeitoStrongMaleList, DTSleep_LeitoStrongFemaleList, (SceneData.WaitSecs * 2.0), gunForward)
		else
			PlayPairAnimFromListIndex(3, mActor, fActor, DTSleep_LeitoStrongMaleList, DTSleep_LeitoStrongFemaleList, (SceneData.WaitSecs * 2.0), gunForward)
		endIf
		
		sceneCount += 1
	endWhile
EndFunction

Function PlayStrongStandDoggy(Actor mActor, Actor fActor)
	Armor gunStart = GetArmorNudeGun(0)
	int sceneLen = DTSleep_IntimateSceneLen.GetValueInt()
	
	PlayPairAnimFromListIndex(2, mActor, fActor, DTSleep_LeitoStrongMaleList, DTSleep_LeitoStrongFemaleList, 37.7, gunStart)
	
	if (sceneLen >= 1 && SceneData.Interrupted <= 0)
		PlayPairAnimFromListIndex(3, mActor, fActor, DTSleep_LeitoStrongMaleList, DTSleep_LeitoStrongFemaleList, (SceneData.WaitSecs * 2.0), None)
	endIf
	if (sceneLen >= 2 && SceneData.Interrupted <= 0)
		PlayPairAnimFromListIndex(2, mActor, fActor, DTSleep_LeitoStrongMaleList, DTSleep_LeitoStrongFemaleList, (SceneData.WaitSecs * 2.0), None)
	endIf
	if (sceneLen >= 3 && SceneData.Interrupted <= 0)
		PlayPairAnimFromListIndex(3, mActor, fActor, DTSleep_LeitoStrongMaleList, DTSleep_LeitoStrongFemaleList, (SceneData.WaitSecs * 2.0), None)
	endIf
	if (sceneLen >= 4 && SceneData.Interrupted <= 0)
		PlayPairAnimFromListIndex(2, mActor, fActor, DTSleep_LeitoStrongMaleList, DTSleep_LeitoStrongFemaleList, (SceneData.WaitSecs * 2.0), None)
	endIf
EndFunction

Function PlayStrongStandSideways(Actor mActor, Actor fActor)
	Armor gunStart = GetArmorNudeGun(0)
	int sceneLen = DTSleep_IntimateSceneLen.GetValueInt()
	
	PlayPairAnimFromListIndex(3, mActor, fActor, DTSleep_LeitoStrongMaleList, DTSleep_LeitoStrongFemaleList, 37.7, gunStart)
	
	if (sceneLen >= 1 && SceneData.Interrupted <= 0)
		PlayPairAnimFromListIndex(2, mActor, fActor, DTSleep_LeitoStrongMaleList, DTSleep_LeitoStrongFemaleList, (SceneData.WaitSecs * 2.0), None)
	endIf
	if (sceneLen >= 2 && SceneData.Interrupted <= 0)
		PlayPairAnimFromListIndex(3, mActor, fActor, DTSleep_LeitoStrongMaleList, DTSleep_LeitoStrongFemaleList, (SceneData.WaitSecs * 2.0), None)
	endIf
	if (sceneLen >= 3 && SceneData.Interrupted <= 0)
		PlayPairAnimFromListIndex(2, mActor, fActor, DTSleep_LeitoStrongMaleList, DTSleep_LeitoStrongFemaleList, (SceneData.WaitSecs * 2.0), None)
	endIf
	if (sceneLen >= 4 && SceneData.Interrupted <= 0)
		PlayPairAnimFromListIndex(3, mActor, fActor, DTSleep_LeitoStrongMaleList, DTSleep_LeitoStrongFemaleList, (SceneData.WaitSecs * 2.0), None)
	endIf
EndFunction

; no actual animations - borrow canine doggy
Function PlayMaleMasterbate(Actor mActor, bool doIntro)

	int sceneLen = DTSleep_IntimateSceneLen.GetValueInt()
	int sceneCount = 0
	Armor gunStart = GetArmorNudeGun(1)
	mActor.EquipItem(gunStart, true, true)

	if (doIntro)
		PlaySingleAnimListIndex(1, mActor, DTSleep_LeitoCanineFemaleList, 9.425)
		PlaySingleAnimListIndex(2, mActor, DTSleep_LeitoCanineFemaleList, 9.425)

		PlaySingleAnimListIndex(1, mActor, DTSleep_LeitoCanineFemaleList, 18.85)

	endIf
	
	while (sceneCount < sceneLen && SceneData.Interrupted <= 0)

		if (sceneCount == 0 || sceneCount == 2)	
			
			PlaySingleAnimListIndex(2, mActor, DTSleep_LeitoCanineFemaleList, (SceneData.WaitSecs * 2.0))

		else
			PlaySingleAnimListIndex(1, mActor, DTSleep_LeitoCanineFemaleList, (SceneData.WaitSecs * 2.0))
		endIf

		sceneCount += 1
	endWhile	

EndFunction

Function PlayFemaleMasterbate(Actor fActor, bool doIntro = true)

	int sceneLen = DTSleep_IntimateSceneLen.GetValueInt()
	int sceneCount = 0
	int oddOrEven = 1
	int rand = Utility.RandomInt(0,4)
	if (rand < 2)
		oddOrEven = 0
	endIf
	
	if (doIntro)
		
		PlaySingleAnimListIndex(0, fActor, DTSleep_LeitoCanineFemaleList, 7.0)			; 37.7s total intro
		PlaySingleAnimListIndex(1, fActor, DTSleep_LeitoMissionary2A1List, 16.2)
		PlaySingleAnimListIndex(0, fActor, DTSleep_LeitoCanineFemaleList, 7.8)

		if (SceneData.Interrupted <= 0)
			if (rand > 2)
				; butt in air
				PlaySingleAnimListIndex(0, fActor, DTSleep_LeitoCanine2FemaleList, 6.7)
			else
				PlaySingleAnimListIndex(1, fActor, DTSleep_LeitoMissionary2A1List, 6.7)
			endIf
		endIf
	endIf
	
	while (sceneCount < sceneLen && SceneData.Interrupted <= 0)
	
		if (sceneCount == oddOrEven || sceneCount == (oddOrEven + 2) || sceneCount == (oddOrEven + 4))
		
			; rocking then touching then rocking
			PlaySingleAnimListIndex(1, fActor, DTSleep_LeitoCanineFemaleList, 4.0)			; 22.4s
			PlaySingleAnimListIndex(2, fActor, DTSleep_LeitoCanineFemaleList, 3.833)
			PlaySingleAnimListIndex(1, fActor, DTSleep_LeitoCanine2FemaleList, 9.234)
			PlaySingleAnimListIndex(1, fActor, DTSleep_LeitoCanineFemaleList, 5.333)
		
		elseIf (sceneCount == sceneLen - 1)
			; touching then finish touching

			PlaySingleAnimListIndex(1, fActor, DTSleep_LeitoCanine2FemaleList, 14.4)
			PlaySingleAnimListIndex(2, fActor, DTSleep_LeitoCanine2FemaleList, 8.0)
		else
			; on back touching
			PlaySingleAnimListIndex(1, fActor, DTSleep_LeitoMissionary2A1List, 14.4)
			if (rand > 3)
				PlaySingleAnimListIndex(0, fActor, DTSleep_LeitoCanineFemaleList, 5.0)
				PlaySingleAnimListIndex(0, fActor, DTSleep_LeitoCanine2FemaleList, 3.0)
			else
				PlaySingleAnimListIndex(0, fActor, DTSleep_LeitoCanineFemaleList, 8.0)
			endIf
		endIf
	
		sceneCount += 1
	endWhile


endFunction

Function PlayFemalePairMasterbate(Actor aActor, Actor fActor, bool doIntro = true)

	int sceneLen = DTSleep_IntimateSceneLen.GetValueInt()
	int sceneCount = 0
	int oddOrEven = 1
	int rand = Utility.RandomInt(0,4)
	if (rand < 3)
		oddOrEven = 0
	endIf
	
	if (doIntro)
		
		; 37.7s total intro
		if (oddOrEven == 1)
			PlayPairAnimFromListIndex(1, aActor, fActor, DTSleep_LeitoCanineFemaleList, DTSleep_LeitoCanineFemaleList, 7.0, None)
			PlayPairAnimFromListIndex(2, aActor, fActor, DTSleep_LeitoCanineFemaleList, DTSleep_LeitoCanineFemaleList, 16.2, None)
			PlayPairAnimFromListIndex(1, aActor, fActor, DTSleep_LeitoCanineFemaleList, DTSleep_LeitoCanineFemaleList, 7.8, None)
		else
			PlayPairAnimFromListIndex(0, aActor, fActor, DTSleep_LeitoCanineFemaleList, DTSleep_LeitoCanineFemaleList, 7.0, None)
			PlayPairAnimFromListIndex(1, aActor, fActor, DTSleep_LeitoMissionary2A1List, DTSleep_LeitoCanineFemaleList, 16.2, None)
			PlayPairAnimFromListIndex(0, aActor, fActor, DTSleep_LeitoCanineFemaleList, DTSleep_LeitoCanineFemaleList, 7.8, None)
		endIf

		if (SceneData.Interrupted <= 0)
			if (rand > 2)
				; butt in air
				PlayPairAnimFromListIndex(0, aActor, fActor, DTSleep_LeitoCanine2FemaleList, DTSleep_LeitoCanine2FemaleList, 6.7, None)
			else
				PlayPairAnimFromListIndex(1, aActor, fActor, DTSleep_LeitoCanineFemaleList, DTSleep_LeitoMissionary2A1List, 6.7, None)
			endIf
		endIf
	endIf
	
	while (sceneCount < sceneLen && SceneData.Interrupted <= 0)
	
		if (sceneCount == oddOrEven || sceneCount == (oddOrEven + 2) || sceneCount == (oddOrEven + 4))
		
			; rocking then touching then rocking - 22.4s
			PlayPairAnimFromListIndex(1, aActor, fActor, DTSleep_LeitoCanineFemaleList, DTSleep_LeitoCanineFemaleList, 4.0, None)
			PlayPairAnimFromListIndex(2, aActor, fActor, DTSleep_LeitoCanineFemaleList, DTSleep_LeitoCanineFemaleList, 3.833, None)	
			PlayPairAnimFromListIndex(1, aActor, fActor, DTSleep_LeitoCanine2FemaleList, DTSleep_LeitoCanineFemaleList, 9.234, None)
			PlayPairAnimFromListIndex(1, aActor, fActor, DTSleep_LeitoCanineFemaleList, DTSleep_LeitoCanineFemaleList, 5.333, None)
		
		elseIf (sceneCount == sceneLen - 1)
			; touching then finish touching
			PlayPairAnimFromListIndex(1, aActor, fActor, DTSleep_LeitoCanine2FemaleList, DTSleep_LeitoCanine2FemaleList, 14.4, None)
			PlayPairAnimFromListIndex(2, aActor, fActor, DTSleep_LeitoCanine2FemaleList, DTSleep_LeitoCanine2FemaleList, 8.0, None)
		else
			; on back touching
			PlayPairAnimFromListIndex(1, aActor, fActor, DTSleep_LeitoMissionary2A1List, DTSleep_LeitoCanineFemaleList, 14.4, None)
			if (rand >= 3)
				PlayPairAnimFromListIndex(0, aActor, fActor, DTSleep_LeitoCanineFemaleList, DTSleep_LeitoCanineFemaleList, 5.0, None)
				PlayPairAnimFromListIndex(0, aActor, fActor, DTSleep_LeitoCanine2FemaleList, DTSleep_LeitoCanine2FemaleList, 3.0, None)
			else
				PlayPairAnimFromListIndex(0, aActor, fActor, DTSleep_LeitoCanineFemaleList, DTSleep_LeitoCanine2FemaleList, 8.0, None)
			endIf
		endIf
	
		sceneCount += 1
	endWhile
endFunction

Function RemoveLeitoGuns(Actor aActor)
	;Debug.Trace("[DTSleep_PlayLeito] RemoveLeitoGuns")
	
	if (ArmGunBodyType == 2)
		RemoveBT2Guns(aActor)
	
	elseIf (DTSleep_LeitoGunList != None)
	
		int len = DTSleep_LeitoGunList.GetSize()
		int idx = 0
		while (idx < len)
			Armor gun = DTSleep_LeitoGunList.GetAt(idx) as Armor
			if (gun)
				int count = aActor.GetItemCount(gun)
				if (count > 0)
					;Debug.Trace("[DTSleep_PlayLeito] removing nude gun: " + gun)
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
		int idx = 0
		while (idx < len)
			Armor gun = DTSleep_BT2GunList.GetAt(idx) as Armor
			if (gun != None)
				int count = aActor.GetItemCount(gun)
				if (count > 0)
					Debug.Trace("[DTSleep_PlayAAC] removing BT2 nude gun: " + gun)
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
		aActor.PlayIdle(LooseIdleStop)
	endIf
endFunction

Function StopSecondActorDone()

	; letting actor go early
	if (SecondActor)
		SecondActor.PlayIdle(LooseIdleStop)
		SecondActor.ChangeAnimFaceArchetype()
		SecondActor.SetAnimationVariableBool("bHumanoidFootIKDisable", false)
		SecondActor.SetAvoidPlayer(true)
		SecondActor.SetRestrained(false)
		
		SecondActor = None
	endIf
endFunction

Function StopAnimationSequence()
	;Debug.Trace("[DTSleep_PlayLeitoIdle] StopSequence")
	Game.FadeOutGame(true, true, 0.0, 1.333, true)
	Utility.Wait(0.67)
	StopActor(MainActor)
	StopActor(SecondActor)
	Utility.Wait(0.667)
	
	;Utility.Wait(0.2)
	(self as ActiveMagicEffect).Dispel()
endFunction