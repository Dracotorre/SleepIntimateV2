ScriptName DialogueGoodneighborScript extends Quest Conditional

Int Property MQ04IrmaReject Auto Conditional
;Has the player rejected going into the memory pod? 1 = yes

ActorValue Property Strength Auto Const
ActorValue Property Perception Auto Const
ActorValue Property Endurance Auto Const
ActorValue Property Charisma Auto Const
ActorValue Property Intelligence Auto Const
ActorValue Property Agility Auto Const
ActorValue Property Luck Auto Const

Int HighestSpecial Conditional
Int Property HateJazz Auto Conditional
Int Property MagnoliaFlirt Auto Conditional
Int Property DateComplete Auto Conditional
Int Property MagnoliaRelationshipOver Auto Conditional

Scene Property MagnoliaGreetScene03 Auto
ReferenceAlias Property Magnolia Auto
ObjectReference Property HotelPlayerMarkerREF Auto
ObjectReference Property HotelMagnoliaMarkerREF Auto
Spell Property LoversEmbracePerkSpell Auto

; ============== DTSleep edit - moved from local function to global script
InputEnableLayer myLayer

; ==============  DTSleep added properties
DTSleep_Conditionals property DTSConditionals auto
ObjectReference property HotelRexfordPlayerBed2REF auto const
Quest property DTSleep_IntimateUndressQuestP auto
Quest property DTSleep_IntimateAnimQuestP auto
DTSleep_SceneData property SceneData auto const
DTSleep_MainQSceneScript property MainQSceneScriptP auto
GlobalVariable property DTSleep_MagnoliaScene auto
GlobalVariable property DTSleep_AdultContentOn auto
{ enable Leito animations regardless if plugin active }
GlobalVariable property DTSleep_SettingUndress auto Const Mandatory
GlobalVariable property DTSleep_SettingIntimate auto Const Mandatory
{ setting to get intimate with lover after waking }
GlobalVariable property DTSleep_SettingAAF auto const
GlobalVariable property DTSleep_IsLeitoActive auto const
; ------------- added v2.14 - original markers too close to wall
ObjectReference Property DTSleep_HotelRexPlayerMarkerREF Auto
ObjectReference Property DTSleep_HotelRexMagnoliaMarkerREF Auto

int property ScenePick auto conditional

bool property DateBusy = false auto hidden
bool property DoPimaryDateFinish = false auto hidden
ObjectReference property OurBedRef = None auto hidden
float property IntimateTime = 0.0 auto hidden


; ============  "Date Magnolia" patch - leave commented out unless building for patch plugin
;Quest Property LNMagnoliaAndPlayerConvince Auto Const
; set stage at date finish

; ==================== DTSleep added events

Event DTSleep_IntimateAnimQuestScript.IntimateSequenceDoneEvent(DTSleep_IntimateAnimQuestScript akSender, Var[] akArgs)
	
	if (akArgs.Length >= 5)
	
		int doneStep = akArgs[4] as int
	
		if (doneStep == 0)
			; preparing, but not done yet 
			return
		endIf
		UnregisterForCustomEvent((DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript), "IntimateSequenceDoneEvent")
		
		MainQSceneScriptP.GoSceneViewDone(true)
			
		if (DTSleep_IntimateUndressQuestP != None)
			(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).StopAll(false)
		endIf
		
		
		(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).StopAll()
		
		DateBusy = false
		
		if (DoPimaryDateFinish)
		
			DTSleep_MagnoliaScene.SetValue(1.0)
			Utility.Wait(1.0)
			MagnoliaDateFinish(Game.GetPlayer())
		else
			Game.FadeOutGame(False, True, 0.0, 2.0)
		endIf
		
		if (DTSleep_SettingAAF != None && DTSleep_SettingAAF.GetValue() == -5.0)
			DTSleep_SettingAAF.SetValue(1.0)	; turn back on
		endIf
		
		ScenePick = 0
	endIf
	
EndEvent

; ====================================

Function GetPlayerHighestSpecial()
	debug.trace(self + "GetPlayerHighestSpecial function started")
	Int HighestValue = 15

	Actor PlayerREF = Game.GetPlayer()
	Int PlayerStrengthValue = PlayerREF.GetValue(Strength) as Int
	debug.trace("PlayerStrengthValue is: " + PlayerStrengthValue)

	Int PlayerPerceptionValue = PlayerREF.GetValue(Perception) as Int
	debug.trace("PlayerPerceptionValue is: " + PlayerPerceptionValue)

	Int PlayerEnduranceValue = PlayerREF.GetValue(Endurance) as Int
	debug.trace("PlayerEnduranceValue is: " + PlayerEnduranceValue)

	Int PlayerCharismaValue = PlayerREF.GetValue(Charisma) as Int
	debug.trace("PlayerCharismaValue is: " + PlayerCharismaValue)

	Int PlayerIntelligenceValue = PlayerREF.GetValue(Intelligence) as Int
	debug.trace("PlayerIntelligenceValue is: " + PlayerIntelligenceValue)

	Int PlayerAgilityValue = PlayerREF.GetValue(Agility) as Int
	debug.trace("PlayerAgilityValue is: " + PlayerAgilityValue)

	Int PlayerLuckValue = PlayerREF.GetValue(Luck) as Int
	debug.trace("PlayerLuckValue is: " + PlayerLuckValue)

	While HighestValue > 0
		debug.trace(self + "GetPlayerHighestSpecial function is starting its While Loop")
		debug.trace("HighestValue is: " + HighestValue)
		If PlayerStrengthValue >= HighestValue
			HighestSpecial = 1
			Return
		ElseIf PlayerPerceptionValue >= HighestValue
			HighestSpecial = 2
			Return
		ElseIf PlayerEnduranceValue >= HighestValue
			HighestSpecial = 3
			Return
		ElseIf PlayerCharismaValue >= HighestValue
			HighestSpecial = 4
			Return
		ElseIf PlayerIntelligenceValue >= HighestValue
			HighestSpecial = 5
			Return
		ElseIf PlayerAgilityValue >= HighestValue
			HighestSpecial = 6
			Return
		ElseIf PlayerLuckValue >= HighestValue
			HighestSpecial = 7
			Return
		EndIf

		HighestValue = HighestValue - 1
	EndWhile
EndFunction

Function MagnoliaDate()
	DoPimaryDateFinish = true						; the first date so we finish
	OurBedRef = HotelRexfordPlayerBed2REF			; at the Hotel Rex
	; modified by moving to global script level
	myLayer = InputEnableLayer.Create()
	Actor myPlayer = Game.GetPlayer()
	Actor MagnoliaREF = Magnolia.GetActorRef()

	myLayer.DisablePlayerControls()
	Game.FadeOutGame(True, True, 0.0, 3.0, True)
	Utility.Wait(3.0)
	;Game.PassTime(4)

	Utility.Wait(0.1)
	; use Sleep Intimate markers if available since regular markers too close to wall causing animation issues
	if (DTSleep_HotelRexMagnoliaMarkerREF != None && DTSleep_HotelRexPlayerMarkerREF != None)
		MagnoliaREF.Moveto(DTSleep_HotelRexMagnoliaMarkerREF)
		myPlayer.Moveto(DTSleep_HotelRexPlayerMarkerREF)
	else
		MagnoliaREF.Moveto(HotelMagnoliaMarkerREF)
		myPlayer.Moveto(HotelPlayerMarkerREF)
	endIf
	MagnoliaREF.SetRestrained()
	
	; ====== begin DTSleep =======
	ScenePick = 0
	MagnoliaDateSI(myPlayer)
	
	; remainder moved to MagnoliaDateFinish
	; ======  end DTSleep  =======
EndFunction

; characters expected to be positioned and OurBedRef set
; "Dating Magnolia" patch may call this function, so there is a wait at end to let function run until animated scene finishes
;
Function MagnoliaDateSI(Actor myPlayer)
	
	Actor MagnoliaREF = Magnolia.GetActorRef()
	DateBusy = true
	bool doPlayAdultAnim = false
	bool noPreBedAnim = true
	bool adultOn = false
	bool modSafe = true
	bool includeClothing = false
	int scenID = 0
	
	Utility.Wait(0.5)
	Game.FadeOutGame(True, True, 0.0, 1.0, True)		; does not always work after teleport fade-in
	Utility.Wait(0.2)
	
	if (DTSleep_AdultContentOn != None && DTSleep_AdultContentOn.GetValue() >= 2.0 && DTSConditionals != None && DTSConditionals.ImaPCMod)
	
		; v2.60
		if (DTSConditionals.PlayerRace != None && DTSConditionals.NanaRace == None)
		
			adultOn = true
		endIf
	endIf
	
	if (SceneData != None && DTSleep_IntimateAnimQuestP != None)
		SceneData.MaleRole = myPlayer
		SceneData.FemaleRole = MagnoliaREF
		SceneData.SameGender = false
		SceneData.PreferStandOnly = true
		SceneData.IsUsingCreature = false
		SceneData.MaleRoleGender = 0
		SceneData.ToyArmor = None
		SceneData.HasToyAvailable = false
		SceneData.HasToyEquipped = false
		SceneData.ToyFromContainer = false
		SceneData.IsUsingCreature = false
		SceneData.IsCreatureType = 0
		SceneData.MaleRoleCompanionIndex = -1
		SceneData.CurrentLoverScenCount = 0
		SceneData.CompanionBribeType = 0
		SceneData.FemaleRaceHasTail = false
		SceneData.CompanionInPowerArmor = false
		SceneData.SecondFemaleRole = None
		SceneData.SecondMaleRole = None
		SceneData.AnimationSet = 0
		
		if ((myPlayer.GetBaseObject() as ActorBase).GetSex() == 1)
			SceneData.SameGender = true
			SceneData.MaleRoleGender = 1
		endIf
	else
		adultOn = false
		modSafe = false
	endIf
	
	
	if (DTSleep_IntimateAnimQuestP != None && DTSleep_SettingIntimate != None && DTSleep_SettingIntimate.GetValue() > 0.0 && DTSleep_SettingUndress.GetValue() > 0.0)
	
		(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).FadeOutSec(0.5, false)		; make sure fade-to-black
		
		if (adultOn)
		
			float timeSinceLast = 10.0
			if (IntimateTime > 0.1)
				timeSinceLast = Utility.GetCurrentGameTime() - IntimateTime
			endIf
			
			if (timeSinceLast > 0.20 && ScenePick == 50 && SceneData.MaleRoleGender == 0 && (DTSConditionals.IsLeitoActive || DTSConditionals.IsLeitoAAFActive))
				doPlayAdultAnim = true
				
				if (DTSConditionals.IsLeitoAAFActive)
					SceneData.AnimationSet = 6
					includeClothing = true
					scenID = 650
				else
					SceneData.AnimationSet = 1
					includeClothing = true
					scenID = 150
				endIf
			elseIf (timeSinceLast > 0.33 && DTSConditionals.IsRufgtActive && SceneData.SameGender && SceneData.MaleRoleGender == 1)
			
				scenID = Utility.RandomInt(591, 593)
				SceneData.AnimationSet = 5
				doPlayAdultAnim = true
				
			elseIf (timeSinceLast > 0.33 && DTSConditionals.IsAtomicLustActive && Utility.RandomInt(1,5) > 3)
				if (SceneData.SameGender)
					
					scenID = 504
				else
					scenID = 547
				endIf
				SceneData.AnimationSet = 5
				doPlayAdultAnim = true
				
			elseIf (timeSinceLast > 0.67 && DTSConditionals.IsLeitoAAFActive && DTSleep_IsLeitoActive.GetValueInt() >= 1)
				doPlayAdultAnim = true
				
				SceneData.AnimationSet = 6
				includeClothing = true
				if (SceneData.SameGender)
					scenID = Utility.RandomInt(652, 653)
				else
					scenID = Utility.RandomInt(651, 654)
				endIf
					
			elseIf (timeSinceLast > 0.67 && DTSConditionals.IsLeitoActive && DTSleep_IsLeitoActive.GetValueInt() >= 1)
				doPlayAdultAnim = true
				
				SceneData.AnimationSet = 1
				includeClothing = true
				if (SceneData.SameGender)
					scenID = Utility.RandomInt(152, 153)
				else
					scenID = Utility.RandomInt(151, 154)
				endIf

			elseIf (timeSinceLast > 0.40 && DTSConditionals.IsSavageCabbageActive && !SceneData.SameGender)
				doPlayAdultAnim = true
				SceneData.AnimationSet = 7
				scenID = 751
			else
				adultOn = false
			endIf
			
			if (SceneData.AnimationSet == 1 || SceneData.AnimationSet == 6)
			
				if (SceneData.SameGender)
					Armor strapOn = (DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).GetStrapOnForActor(myPlayer, true)
					if (strapOn != None)
						doPlayAdultAnim = true
						SceneData.ToyArmor = strapOn
						SceneData.HasToyAvailable = true
						SceneData.HasToyEquipped = false
					else
						doPlayAdultAnim = false
						adultOn = false
					endIf
				else
					doPlayAdultAnim = true
				endIf
			endIf
		endIf
		if (!DTSleep_IntimateUndressQuestP.IsRunning())
			DTSleep_IntimateUndressQuestP.Start()
		endIf
		
		if (adultOn && doPlayAdultAnim)
			
			(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).StartForManualStop(includeClothing, MagnoliaREF, false, true, None)
		else
			(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).StartForManualStopRespect(MagnoliaREF)
		endIf
		
		if (DTSConditionals.IsPlayerCommentsActive)
			; PCHT and PHT work differently  -- v2.32
			Quest pcQ = (DTSConditionals as DTSleep_Conditionals).ModPlayerCommentsQuest
			GlobalVariable gv = DTSConditionals.ModPlayerCommentsGlobDisabled
			int pcDisVal = -1
			if (gv != None)
				pcDisVal = gv.GetValueInt()
			endIf
			if (pcQ != None)
				; PCHT enabled
				if (pcQ.IsRunning() && pcDisVal < 1)
					modSafe = false
					if (SceneData != None)
						SceneData.AnimationSet = 0
					endIf
				endIf
			elseIf (pcDisVal >= 1)
				; PHT enabled
				modSafe = false
				if (SceneData != None)
					SceneData.AnimationSet = 0
				endIf
			endIf
		endIf
		
		if (adultOn && SceneData.AnimationSet == 5)
			MainQSceneScriptP.CamHeightOffset = -24.0
			MainQSceneScriptP.GoSceneViewStart(1)
		else
			MainQSceneScriptP.GoSceneViewStart(0)
		endIf
		
		Utility.Wait(0.2)
	endIf
	
	MagnoliaREF.SetRestrained(false)
	
	if (modSafe && adultOn && doPlayAdultAnim && DTSleep_IntimateAnimQuestP != None && DTSConditionals.ImaPCMod)
		
		if (DTSleep_SettingAAF != None && DTSleep_SettingAAF.GetValue() >= 1.0)
			DTSleep_SettingAAF.SetValue(-5.0)	; force off
		endIf
		(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).PlaceInBedOnFinish = false
		
		(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).StartForActorsAndBed(myPlayer, MagnoliaREF, OurBedRef, true, true)
		
		if ((DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).PlayActionIntimateSeq(scenID))
			noPreBedAnim = false
			IntimateTime = Utility.GetCurrentGameTime()
			RegisterForCustomEvent((DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript), "IntimateSequenceDoneEvent")
			
		elseIf ((DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).PlayActionDancing()) 
			noPreBedAnim = false
			RegisterForCustomEvent((DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript), "IntimateSequenceDoneEvent")
		else
			Debug.Trace("[DTSleep DialogueGoodneighborScript] IAnim returned false!")
		endIf
		
	elseIf (modSafe && DTSleep_SettingIntimate.GetValue() > 0.0 && DTSleep_IntimateAnimQuestP != None)
		
		(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).PlaceInBedOnFinish = false
		
		(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).StartForActorsAndBed(myPlayer, MagnoliaREF, OurBedRef, true, true)
		
		; original markers too close too wall so dance instead
		if (DoPimaryDateFinish && DTSleep_HotelRexPlayerMarkerREF == None)
			if ((DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).PlayActionDancing()) 
				noPreBedAnim = false
				RegisterForCustomEvent((DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript), "IntimateSequenceDoneEvent")
			endIf
		elseIf ((DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).PlayActionHugs()) 
			noPreBedAnim = false
			RegisterForCustomEvent((DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript), "IntimateSequenceDoneEvent")
		endIf
	endIf
	
	ScenePick = 0
	
	if (noPreBedAnim)
		if (DTSleep_IntimateUndressQuestP != None)
			(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).StopAll(false)
		endIf
		if (DTSleep_SettingAAF != None && DTSleep_SettingAAF.GetValue() == -5.0)
			DTSleep_SettingAAF.SetValue(1.0)	; turn back on
		endIf
		Utility.Wait(0.4)
		DateBusy = false
		if (DoPimaryDateFinish)
			MagnoliaDateFinish(myPlayer)
		else
			Game.FadeOutGame(False, True, 0.0, 3.0)
		endIf
	else
		Game.FadeOutGame(False, True, 0.0, 3.0)
	endIf
	
	if (!DoPimaryDateFinish)
		; wait for anim event-done
		int i = 0
		while (i < 120 && DateBusy)
			Utility.Wait(1.0)
			i += 1
		endWhile
	endIf
		
EndFunction

; end of MagnoliaDate moved here by DTSleep
Function MagnoliaDateFinish(Actor myPlayer)
	Utility.Wait(0.1)

	Game.FadeOutGame(False, True, 0.0, 3.0)
	
	;track when the scene should progress
	DateComplete = 0
	MagnoliaGreetScene03.Start()
	Utility.Wait(3.0)
	LoversEmbracePerkSpell.Cast(myPlayer, myPlayer)
	DateComplete = 1
	; ----- "Date Magnolia" patch ------ leaved commented out unless building for patch plugin
	;LNMagnoliaAndPlayerConvince.SetStage(10)
	; ----------------------==========
	myLayer.EnablePlayerControls()
	myLayer.Delete()
	myLayer = None
	DoPimaryDateFinish = false
EndFunction
