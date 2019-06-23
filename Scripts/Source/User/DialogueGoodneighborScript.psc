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
		
		DTSleep_MagnoliaScene.SetValue(1.0)
		
		Utility.Wait(1.0)
		MagnoliaDateFinish(Game.GetPlayer())

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
	; modified by moving to global script level
	myLayer = InputEnableLayer.Create()
	Actor myPlayer = Game.GetPlayer()
	Actor MagnoliaREF = Magnolia.GetActorRef()

	myLayer.DisablePlayerControls()
	Game.FadeOutGame(True, True, 0.0, 3.0, True)
	Utility.Wait(5.0)
	;Game.PassTime(4)

	Utility.Wait(0.1)
	MagnoliaREF.moveto(HotelMagnoliaMarkerREF)
	myPlayer.Moveto(HotelPlayerMarkerREF)
	
	; ====== begin DTSleep =======
	bool doPlayAdultAnim = false
	bool noPreBedAnim = true
	bool adultOn = false
	bool modSafe = true
	bool includeClothing = false
	int scenID = 0
	
	;Game.FadeOutGame(True, True, 0.0, 1.0, True)
	;Utility.Wait(0.33)
	
	if (DTSleep_AdultContentOn.GetValue() >= 2.0 && DTSConditionals.ImaPCMod)
		adultOn = true
	endIf
	
	SceneData.MaleRole = myPlayer
	SceneData.FemaleRole = MagnoliaREF
	SceneData.HasToyEquipped = false
	SceneData.SameGender = false
	SceneData.AnimationSet = 0
	
	if (DTSleep_SettingIntimate.GetValue() > 0.0 && DTSleep_SettingUndress.GetValue() > 0.0)
	
		if (adultOn)
			if (DTSConditionals.IsAAFActive && DTSConditionals.IsF4SE && DTSleep_SettingAAF.GetValue() > 0.0 && DTSConditionals.IsAtomicLustActive)
				SceneData.AnimationSet = 5
				SceneData.PreferStandOnly = true
				scenID = 548
				doPlayAdultAnim = true
				
			elseIf (DTSConditionals.IsLeitoActive && DTSleep_IsLeitoActive.GetValueInt() >= 1)
				if (DTSConditionals.IsLeitoAAFActive == false)
					SceneData.AnimationSet = 1
					includeClothing = true
					scenID = Utility.RandomInt(152, 153)
					
				elseIf (DTSleep_IsLeitoActive.GetValueInt() >= 4)
					SceneData.AnimationSet = 1
					includeClothing = true
					scenID = Utility.RandomInt(152, 153)
				else
					adultOn = false
				endIf
			else
				adultOn = false
			endIf
		endIf
		if (!DTSleep_IntimateUndressQuestP.IsRunning())
			DTSleep_IntimateUndressQuestP.Start()
		endIf
		
		if (adultOn)
			(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).StartForManualStop(includeClothing, MagnoliaREF, false, true, None)
		else
			(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).StartForManualStopRespect(MagnoliaREF)
		endIf
		
		MainQSceneScriptP.GoSceneViewStart(0)
		
		
		if (DTSConditionals.IsPlayerCommentsActive)
			GlobalVariable gv = DTSConditionals.ModPlayerCommentsGlobDisabled
			if (gv && gv.GetValueInt() <= 0)
				modSafe = false
			endIf
		endIf
		
		if (modSafe && adultOn)
			
			if (SceneData.AnimationSet == 1)
			
				if ((myPlayer.GetBaseObject() as ActorBase).GetSex() == 1)
				
					SceneData.SameGender = true
					Armor strapOn = (DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).GetStrapOnForActor(myPlayer, true)
					if (strapOn)
						doPlayAdultAnim = true
						SceneData.ToyArmor = strapOn
						SceneData.HasToyAvailable = true
						SceneData.HasToyEquipped = false
					endIf
				else
					doPlayAdultAnim = true
				endIf
			endIf
		endIf
		
		Utility.Wait(0.2)
	endIf
	
	if (modSafe && doPlayAdultAnim && DTSConditionals.ImaPCMod)
		
		(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).PlaceInBedOnFinish = false
		
		(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).StartForActorsAndBed(myPlayer, MagnoliaREF, HotelRexfordPlayerBed2REF, true, true)
		
		if ((DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).PlayActionIntimateSeq(scenID))
			noPreBedAnim = false
			RegisterForCustomEvent((DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript), "IntimateSequenceDoneEvent")
		else
			Debug.Trace("[DTSleep DialogueGoodneighborScript] IAnim returned false!")
		endIf
		
	elseIf (modSafe && DTSleep_SettingIntimate.GetValue() > 0.0)
		
		(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).PlaceInBedOnFinish = false
		
		(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).StartForActorsAndBed(myPlayer, MagnoliaREF, HotelRexfordPlayerBed2REF, false, true)
		
		if ((DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).PlayActionDancing())
			noPreBedAnim = false
			RegisterForCustomEvent((DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript), "IntimateSequenceDoneEvent")
		endIf
	endIf
	
	if (noPreBedAnim)
		(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).StopAll(false)
		Utility.Wait(0.4)
		MagnoliaDateFinish(myPlayer)
	endIf
	
	; remainder moved to MagnoliaDateFinish
	; ======  end DTSleep  =======
		
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
EndFunction
