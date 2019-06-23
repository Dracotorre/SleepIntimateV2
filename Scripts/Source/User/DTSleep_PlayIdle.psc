ScriptName DTSleep_PlayIdle extends ActiveMagicEffect

DTSleep_SceneData property SceneData auto const
GlobalVariable property DTSleep_WasPlayerThirdPerson auto
GlobalVariable property DTSleep_IntimateIdleID auto

Actor Property PlayerRef auto const
Keyword Property AnimFaceArchetypeHappy Auto Const
Idle property HeadShakeYes auto const
Idle property IdleBeautifulView auto const
Idle property IdleClapping auto const
Idle property IdleFightWinner auto const
;Idle property IdleLookupInspect auto const
Idle property IdlePointing auto const
Idle property IdleThinking auto const
Idle property LooseIdleStop auto const
Idle property ShrugIdle auto const
idle property IdleMagnoliaSong05 auto const
FormList property DTSleep_Dance2List auto const


; ---------- hidden ----------
Actor property MainActor auto hidden
Actor property SecondActor auto hidden
int property SequenceID auto hidden


; *************************
;          variables

InputEnableLayer DTSleepPlayInputLayer
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

; begin animations - caster is considered dominate;
; second actor must be target and not player in two-person sequences
;
Event OnEffectStart(Actor akTarget, Actor akCaster)
	;Debug.Trace("[DTSleep_PlayIdle] OnEffectStart " + akTarget + ", " + akCaster)
	SequenceID = DTSleep_IntimateIdleID.GetValueInt()
	if (akTarget && akTarget != PlayerRef)
		SecondActor = akTarget
		MainActor = akCaster
		Weapon weapItem = SecondActor.GetEquippedWeapon()
		if (weapItem)
			SecondActor.UnequipItem(weapItem, false, true)
		endIf
		SecondActor.SetRestrained()
		;SecondActor.SetAnimationVariableBool("bHumanoidFootIKDisable", true)
		;SecondActor.SetAvoidPlayer(false)
		SecondActor.ChangeAnimFaceArchetype(AnimFaceArchetypeHappy)
		if (SceneData != None && SceneData.SecondMaleRole != None)
			SceneData.SecondMaleRole.SetRestrained()
		endIf
		if (SceneData != None && SceneData.SecondFemaleRole != None)
			SceneData.SecondFemaleRole.SetRestrained()
		endIf
	else
		MainActor = akTarget
	endIf
	
	if (MainActor != None)
		DTSleepPlayInputLayer = InputEnableLayer.Create()
		;if PlayerRef.GetAnimationVariableBool("IsFirstPerson")
		;	DTSleep_WasPlayerThirdPerson.SetValue(-1.0)
		;	Game.ForceThirdPerson()
		;else
		;	DTSleep_WasPlayerThirdPerson.SetValue(1.0)
		;endIf
		Utility.Wait(0.2)
		;       SleepInputLayer                     move,  fight, camSw, look, snk, menu, act, journ, Vats, Favs, run
		DTSleepPlayInputLayer.DisablePlayerControls(true, true, true, false, true, false, true, true, true, true, true)
		;MainActor.SetAnimationVariableBool("bHumanoidFootIKDisable", true)
		
		RegisterForMenuOpenCloseEvent("PipboyMenu")
		PlaySequence()
	else
		StopAnimationSequence()
	endIf
endEvent

; end animation - clean up
Event OnEffectFinish(Actor akTarget, Actor akCaster)
	;Debug.Trace("[DTSleep_PlayIdle] OnEffectFinish")
	
	UnregisterForMenuOpenCloseEvent("PipboyMenu")
	
	if (MainActor != None)
		MainActor.ChangeAnimFaceArchetype()
		;MainActor.SetAnimationVariableBool("bHumanoidFootIKDisable", false)
	endIf
	if (SecondActor!= None)
		SecondActor.ChangeAnimFaceArchetype()
		;SecondActor.SetAnimationVariableBool("bHumanoidFootIKDisable", false)
		;SecondActor.SetAvoidPlayer(true)
		SecondActor.SetRestrained(false)
	endIf
	if (SceneData != None && SceneData.SecondMaleRole != None)
		SceneData.SecondMaleRole.SetRestrained(false)
	endIf
	if (SceneData != None && SceneData.SecondFemaleRole != None)
		SceneData.SecondFemaleRole.SetRestrained(false)
	endIf
	DTSleepPlayInputLayer.EnablePlayerControls()
	MainActor = None
	SecondActor = None
	DTSleepPlayInputLayer = None
	
	;if (DTSleep_WasPlayerThirdPerson.GetValue() < 1.0)
	;	Utility.Wait(0.2)
	;	if (!PlayerRef.GetAnimationVariableBool("IsFirstPerson"))
	;		Game.ForceFirstPerson()
	;	endIf
	;endIf
endEvent

; ********************************************
; *****                Functions       ***********
;

Function PlaySequence()
	;Debug.Trace("[DTSleep_PlayIdle] playSequence " + SequenceID)
	if (SequenceID == 0)
		PlayClapping(MainActor, SecondActor)
	elseIf (SequenceID == 1)
		PlayShrugAndYes(MainActor)
	elseIf (SequenceID == 2)
		PlayPointAtView(MainActor)
	elseIf (SequenceID == 3)
		PlayThinking(MainActor)
	elseIf (SequenceID == 10)
		PlayCelebration(MainActor, SecondActor)
	elseIf (SequenceID == 11)
		PlayRandomDance(MainActor, SecondActor)
	endIf
	Utility.Wait(0.2)
	StopAnimationSequence()
endFunction

Function PlayPointAtView(Actor aActor)
	if (!aActor || !IdleBeautifulView || !IdlePointing)
		return
	endIf
	aActor.PlayIdle(IdlePointing)
	Utility.Wait(0.8)
	aActor.PlayIdle(LooseIdleStop)
	aActor.PlayIdle(IdleBeautifulView)
	Utility.Wait(0.6)
endFunction

Function PlayClapping(Actor aActor, Actor bActor)
	if (!aActor || !IdleClapping)
		return
	endIf
	aActor.ChangeAnimFaceArchetype(AnimFaceArchetypeHappy)
	aActor.PlayIdle(IdleClapping)
	if (bActor)
		Utility.Wait(0.3)
		bActor.PlayIdle(IdleClapping)
	endIf
	Utility.Wait(1.5)
endFunction

Function PlayCelebration(Actor aActor, Actor bActor)
	if (!aActor || !IdleFightWinner)
		return
	endIf
	aActor.ChangeAnimFaceArchetype(AnimFaceArchetypeHappy)
	aActor.PlayIdle(IdleFightWinner)
	if (bActor)
		Utility.Wait(0.2)
		bActor.ChangeAnimFaceArchetype(AnimFaceArchetypeHappy)
		bActor.PlayIdle(IdleFightWinner)
	endIf
	Utility.Wait(1.0)
	aActor.PlayIdle(LooseIdleStop)
	if (bActor)
		Utility.Wait(0.2)
		bActor.PlayIdle(LooseIdleStop)
	endIf
	aActor.PlayIdle(IdleFightWinner)
	if (bActor)
		Utility.Wait(0.3)
		bActor.PlayIdle(IdleFightWinner)
	endIf
	Utility.Wait(1.0)
endFunction

Function PlayDanceIdle(Idle danceIdle, Actor aActor, Actor bActor)
	if (danceIdle != None)
	
		Actor danceActor = None
		Actor clapActor = None
		if (aActor != None && (aActor.GetLeveledActorBase() as ActorBase).GetSex() == 1)
			danceActor = aActor
			clapActor = bActor
		else
			danceActor = bActor
			clapActor = aActor
		endIf
		if (danceActor != None)
			danceActor.ChangeAnimFaceArchetype(AnimFaceArchetypeHappy)
			danceActor.PlayIdle(danceIdle)

			if (SceneData != None && SceneData.SecondFemaleRole != None)
				SceneData.SecondFemaleRole.PlayIdle(danceIdle)
			endIf
			Utility.Wait(1.25)
		endIf
		if (clapActor)
			clapActor.ChangeAnimFaceArchetype(AnimFaceArchetypeHappy)
			if (Utility.RandomInt(1, 5) > 3)
				clapActor.PlayIdle(IdleFightWinner)
			else
				PlayClapping(clapActor, None)
			endIf
			if (SceneData != None && SceneData.SecondMaleRole != None)
				PlayClapping(SceneData.SecondMaleRole, None)
			endIf
		endIf
		if (danceActor || clapActor)
			Utility.Wait(9.33)
		endIf
		if (danceActor)
			PlayClapping(danceActor, None)
			Utility.Wait(1.0)
		endIf
		if (clapActor)
			clapActor.PlayIdle(IdleBeautifulView)
			Utility.Wait(1.0)
		endIf
	endIf
	Utility.Wait(1.7)
endFunction

; 14 secs
Function PlayMagnoliaDance(Actor aActor, Actor bActor)
	Actor danceActor = bActor
	Actor clapActor = aActor
	if (!bActor || (bActor.GetLeveledActorBase() as ActorBase).GetSex() == 0)
		danceActor = aActor
		clapActor = bActor
	endIf
	danceActor.ChangeAnimFaceArchetype(AnimFaceArchetypeHappy)
	
	if (Utility.RandomInt(0, 5) > 3)
		danceActor.PlayIdle(IdleFightWinner)
		Utility.Wait(1.7)
	endIf
	
	danceActor.PlayIdle(IdleMagnoliaSong05)
	Utility.Wait(2.0)
	if (SceneData != None && SceneData.SecondFemaleRole != None)
		SceneData.SecondFemaleRole.PlayIdle(IdleMagnoliaSong05)
	endIf
	
	if (clapActor != None)
		
		if (SceneData != None && SceneData.SecondMaleRole != None)
			PlayClapping(SceneData.SecondMaleRole, None)
		endIf
		Utility.Wait(2.25)
		if (Utility.RandomInt(-1, 3) > 0)
			PlayClapping(clapActor, None)
		else
			clapActor.PlayIdle(IdleBeautifulView)
		endIf
		clapActor.PlayIdle(LooseIdleStop)
		Utility.Wait(3.75)
		
		if (Utility.RandomInt(0, 5) > 2)
			clapActor.PlayIdle(IdleFightWinner)
		else
			PlayClapping(clapActor, None)
		endIf
		
		Utility.Wait(2.0)
	else
		Utility.Wait(8.0)
	endIf
	if (SceneData != None && SceneData.SecondFemaleRole != None)
		SceneData.SecondFemaleRole.PlayIdle(LooseIdleStop)
	endIf
	if (SceneData != None && SceneData.SecondMaleRole != None)
		SceneData.SecondMaleRole.PlayIdle(LooseIdleStop)
	endIf
	Utility.Wait(2.0)
	danceActor.PlayIdle(LooseIdleStop)
	Utility.Wait(0.3)
	danceActor.PlayIdle(IdleFightWinner)
	Utility.Wait(1.7)
endFunction

Function PlayRandomDance(Actor aActor, Actor bActor)

	int danceCount = DTSleep_Dance2List.GetSize()
	
	if (danceCount > 0)
		int rand = Utility.RandomInt(-2, danceCount - 1)
		if (rand < 0)
			PlayMagnoliaDance(aActor, bActor)
		else
			PlayDanceIdle(DTSleep_Dance2List.GetAt(rand) as Idle, aActor, bActor)
		endIf
	else
		PlayMagnoliaDance(aActor, bActor)
	endIf
	
endFunction

Function PlayShrugAndYes(Actor aActor)
	if (!aActor || !HeadShakeYes || !ShrugIdle)
		return
	endIf
	aActor.PlayIdle(ShrugIdle)
	Utility.Wait(1.0)
	aActor.PlayIdle(LooseIdleStop)
	aActor.PlayIdle(HeadShakeYes)
	Utility.Wait(0.8)
endFunction

Function PlayThinking(Actor aActor)
	if (!aActor || !IdleThinking)
		return
	endIf
	aActor.PlayIdle(IdleThinking)
	Utility.Wait(1.5)
endFunction

Function StopActor(Actor aActor)
	if (aActor)
		aActor.PlayIdle(LooseIdleStop)
	endIf
endFunction

Function StopAnimationSequence()
	;Debug.Trace("[DTSleep_PlayIdle] StopSequence")
	StopActor(MainActor)
	StopActor(SecondActor)
	if (SceneData != None && SceneData.SecondFemaleRole != None)
		StopActor(SceneData.SecondFemaleRole)
	endIf
	Utility.Wait(0.67)
	self.Dispel()
endFunction

; ---------------------
FormList property DTSleep_DanceList auto const
{ deprecated }