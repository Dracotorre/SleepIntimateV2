Scriptname DTSleep_MagnoliaDateQuestScript extends Quest

; Sleep Intimate by DracoTorre
; Magnolia date scene
; scene starts immediately -- Magnolia and player expected to be positioned in same location

ReferenceAlias Property Magnolia Auto
ObjectReference property HotelRexfordPlayerBed2REF auto const
ObjectReference property VIPRoomSeatREF auto const
DTSleep_Conditionals property DTSConditionals auto
Quest property DTSleep_IntimateUndressQuestP auto
Quest property DTSleep_IntimateAnimQuestP auto
DTSleep_SceneData property SceneData auto const
DTSleep_MainQSceneScript property MainQSceneScriptP auto
GlobalVariable property DTSleep_AdultContentOn auto
{ enable Leito animations regardless if plugin active }
GlobalVariable property DTSleep_SettingUndress auto Const Mandatory
GlobalVariable property DTSleep_SettingIntimate auto Const Mandatory
{ setting to get intimate with lover after waking }
GlobalVariable property DTSleep_SettingAAF auto const
GlobalVariable property DTSleep_IsLeitoActive auto const


; ------------------------------------ 
InputEnableLayer myLayer


Event OnQuestInit()
	MagnoliaDateScene()
EndEvent

; event to catch end-scene
;
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
		
		self.SetStage(100)
	endIf
	
EndEvent

Function MagnoliaDateScene()

	Actor myPlayer = Game.GetPlayer()
	Actor MagnoliaREF = Magnolia.GetActorRef()
	bool doPlayAdultAnim = false
	bool noPreBedAnim = true
	bool adultOn = false
	bool modSafe = true
	bool includeClothing = false
	int scenID = 0
	ObjectReference bedRef = HotelRexfordPlayerBed2REF
	if (VIPRoomSeatREF != None && myPlayer.GetDistance(VIPRoomSeatREF) < 1000.0)
		bedRef = VIPRoomSeatREF
	endIf
	
	self.SetStage(20)
	
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
		
		(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).StartForActorsAndBed(myPlayer, MagnoliaREF, bedRef, true, true)
		
		if ((DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).PlayActionIntimateSeq(scenID))
			noPreBedAnim = false
			RegisterForCustomEvent((DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript), "IntimateSequenceDoneEvent")
		else
			Debug.Trace("[DTSleep DialogueGoodneighborScript] IAnim returned false!")
		endIf
		
	elseIf (modSafe && DTSleep_SettingIntimate.GetValue() > 0.0)
		
		(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).PlaceInBedOnFinish = false
		
		(DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).StartForActorsAndBed(myPlayer, MagnoliaREF, bedRef, false, true)
		
		if ((DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).PlayActionXOXO())
			noPreBedAnim = false
			RegisterForCustomEvent((DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript), "IntimateSequenceDoneEvent")
		endIf
	endIf
	
	if (noPreBedAnim)
		(DTSleep_IntimateUndressQuestP as DTSleep_IntimateUndressQuestScript).StopAll(false)
		self.SetStage(90)
	endIf
endFunction