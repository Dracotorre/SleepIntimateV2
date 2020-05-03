ScriptName DTSleep_EncounterQuest extends Quest
{An encounter start on Register and stops itself after player exits furniture or Unregister}

; ******************
; DTSleep_EncounterQuest for SleepIntimate
; by DracoTorre
; www.dracotorre.com/mods/sleepintimate/
; 
; an encounter may be decorating bed with a gift, sleeping with a teddy bear,
; drug items for addicts, or lover's gifts
;
; addiction spells: abAddictionAlcohol, abAddictionBerryMentats, abAddictionBuffjet...
; Smokable Cigars: AA_abAddictionNicotine
; --------------------
import DTSleep_CommonF

; ********************************************
; ****         properties        *****
;
Actor property PlayerRef auto const
ActorValue property CharismaAV auto const
Keyword property AnimFurnFloorBedAnimKY auto const
Keyword property AnimFurnLayDownUtilityBoxKY auto const
Spell property AbAddictionAlcoholSp auto const
Spell property AbAddictionNukaQuantumSp auto const
MagicEffect property abReduceEnduranceAddictionME auto const
MagicEffect property abReduceCharismaAddictionME auto const
MiscObject property TeddyBear auto const 
MiscObject property BonesSkull auto const
Keyword property DTSleep_OutfitContainerKY auto const

DTSleep_Conditionals property DTSConditionals auto 
FormList property DTSleep_AddictionChemsFList auto 
FormList property DTSleep_AddictionDrinkFList auto 
FormList property DTSleep_BedItemFlist auto 
FormList property DTSleep_FemBedItemFList auto 
FormList property DTSleep_LoverItemFList auto
FormList property DTSleep_BedsBigDoubleList auto const

Static property DTSleep_DummyNode auto const

; hidden
ObjectReference property SleepBedRef auto hidden
Actor property CompanionRef auto hidden
bool property CompanionIsLover auto hidden
int property SleepEncounterType auto hidden
int property PlayerGender auto hidden
{ set to 10,11 for male,female - store for reuse }

; ********************************************
; ******           variables     ***********
;
ObjectReference[] BedDecorationObjRefArray
;int InitTimerID = 100 const
int RunEncounterID = 101 const
int RemoveDecorationTimerID = 102 const
string myScriptName = "[DTSleep_Encounter]" const

; ********************************************
; *****                Events       ***********
;
Event OnQuestInit()
	; do nothing
EndEvent

Event ObjectReference.OnExitFurniture(ObjectReference akSender, ObjectReference akActionRef)
	
	if (akActionRef == PlayerRef)
		UnregisterForRemoteEvent(akSender, "OnExitfurniture")
		if (SleepEncounterType > 0)
			SleepEncounterType = 0
			StartTimer(0.8, RemoveDecorationTimerID)
		else
			StopAll()
		endIf
	endIf
EndEvent

Event OnTimer(int aiTimerID)
	if (aiTimerID == RunEncounterID)
		ProcessEncounter()
	elseIf aiTimerID == RemoveDecorationTimerID
		RemoveBedDecoration()
		StopAll()
	endIf
EndEvent

; ******************** Start / Stop *************

; return 0 for none, < 100 for awaken encounters
; 100 - 199 is for player requested functions
; 
int Function StartEncounter(ObjectReference bedRef, Actor companionActorRef, bool isLover)
	if (SleepEncounterType > 0)
		RemoveBedDecoration()
		SleepEncounterType = 0
		Utility.Wait(0.33)
	endIf
	SleepBedRef = bedRef
	CompanionRef = companionActorRef
	CompanionIsLover = isLover
	
	return StartupEncounter()
endFunction

Function StopAll()
	
	if (SleepEncounterType > 0)
		StartTimer(0.5, RemoveDecorationTimerID)
		SleepEncounterType = 0
		Utility.Wait(0.33)
	endIf

	if (SleepBedRef != None)
		UnregisterForRemoteEvent(SleepBedRef, "OnExitfurniture")
	endIf
	CompanionRef = None
	SleepBedRef = None
	
	; do not stop quest
endFunction

; ********************************************
; *****          Functions      *********

; decision functions for awaken encounters such as bed decorations or lover activity
;
; Decide if actor should awaken to something extra then pass to PlaceEncounterForBed
; Returns positive for bonus type or zero for none
; chance depends on charisma, addictions, and if is lover 
;
; 1 = Teddy Bear
; 2 = random female list
; 3 = Charisma Addiction
; 4 = Endurance Addiction
; 5 = Nuka Addiction
; 6 = Alcohol Addiction
; 7 = Nicotine Addiction
; 8 = lover items
; 9 = 6 gifts from lover
; 10 = random bed item 
; 11 = Nuka Bear
; 12 = 6 teddy bears
; 13 = skull 
; 14 = 3 teddy bears
; 15 = teddy bears from bed container
; 16 = female item from bed container
;
int Function GetAwakenEncounterTypeOnChanceForActors(Actor playerActorRef, Actor companionActorRef, bool isLover, bool playerActorWakesInBed = true)
	
	
	if (SleepBedRef != None && SleepBedRef.HasKeyword(DTSleep_OutfitContainerKY))
		if (SleepBedRef.GetItemCount(TeddyBear) > 0)
			return 15
		else
			int listSize = DTSleep_FemBedItemFList.GetSize()
			if (listSize > 4)
				int i = 4

				while (i > 2)
					Form item = DTSleep_FemBedItemFList.GetAt(i)
					if (item != None && SleepBedRef.GetItemCount(item) > 0)
						
						return 16
					endIf
					
					i -= 1
				endWhile
			endIf
		endIf
	endIf
	
	int randomRoll = Utility.RandomInt(-2, 90)
	float charisma = playerActorRef.GetValue(CharismaAV)
	randomRoll += (charisma as int) * 2
	
	;Debug.Trace(myScriptName + " Random Encounter Roll: " + randomRoll + " for playerAct Charisma " + charisma + " and bed: " + SleepBedRef)
	
	; check for special encounters based on inventory counts
	int itemCount = playerActorRef.GetItemCount(TeddyBear as Form)
	if (itemCount >= 3 && itemCount < 6 && playerActorWakesInBed && randomRoll > 30)
		
		return 14

	elseIf (itemCount >= 6 && playerActorWakesInBed && randomRoll > 36)
		return 6
	endIf
	
	if (randomRoll > 40 && charisma < 8)
		itemCount = playerActorRef.GetItemCount(BonesSkull)
		if (itemCount >= 2)
			return 13
		endIf
	endIf
	
	if (PlayerGender < 10)
		ActorBase playerBase = playerActorRef.GetBaseObject() as ActorBase
		PlayerGender = playerBase.GetSex() + 10
	endIf
	
	if (companionActorRef && isLover)
	
		int targetRoll = 32
		
		if (PlayerGender == 10)
			targetRoll = 45
		endIf
		
		if (randomRoll > targetRoll && DTSleep_LoverItemFList.GetSize() > 1)
		
			Form giftForm = DTSleep_LoverItemFList.GetAt(0)
			itemCount = companionActorRef.GetItemCount(giftForm)
			
			; need a half-dozen at least
			if (itemCount >= 6)
				return 9
			endIf
		endIf
	endIf
	
	if (randomRoll > 21)
		if (companionActorRef && isLover)
			; TODO: finish
			if (playerActorWakesInBed)
				if (randomRoll > 52)
					return 8
				elseIf (charisma >= 5 && randomRoll > 45)
					return 1
				endIf
			endIf
	
			if (PlayerGender == 11 && (DTSConditionals as DTSleep_Conditionals).IsDXAtomGirlActive)
				
				Armor nukaBear = GetNukabearArmor()
				
				if (nukaBear != None)
					if (playerActorRef.GetItemCount(nukaBear) > 0)
						return 11
					elseIf (SleepBedRef != None && SleepBedRef.HasKeyword(DTSleep_OutfitContainerKY) && SleepBedRef.GetItemCount(nukaBear) > 0)
						return 11
					endIf
				endIf
			endIf
			
			if (PlayerGender == 11 && randomRoll > 58)
				return 2

			elseIf (randomRoll > 50 && playerActorRef.HasSpell(AbAddictionAlcoholSp))
				return 6
			endIf
		else
			; no lover 
			if (randomRoll > 64 && playerActorRef.HasMagicEffect(abReduceCharismaAddictionME))
				return 3
			endIf
			if (randomRoll > 54 && playerActorRef.HasMagicEffect(abReduceEnduranceAddictionME))
				return 4
			endIf
			
			;if (randomRoll > 79 && (DTSConditionals as DTSleep_Conditionals).IsSmokableCigarsActive)
			;
			;	Spell nicotineAddictionSpell = (Game.GetFormFromFile(0x03000FA9, "Smoke-able Cigars.esp") as Spell)
			;	if (nicotineAddictionSpell && playerActorRef.HasSpell(nicotineAddictionSpell))
			;		return 7
			;	endIf
			;endIf
			
			
			if (PlayerGender == 11 && charisma >= 4.0)
			
				if (DTSConditionals as DTSleep_Conditionals).IsDXAtomGirlActive
					Armor nukaBear = GetNukabearArmor()
					if (nukaBear != None)
						if (playerActorRef.GetItemCount(nukaBear) > 0)
							return 11
						elseIf (SleepBedRef != None && SleepBedRef.HasKeyword(DTSleep_OutfitContainerKY) && SleepBedRef.GetItemCount(nukaBear) > 0)
							return 11
						endIf
					endIf
				endIf
				
				if (randomRoll > 35 && playerActorRef.HasSpell(AbAddictionAlcoholSp))
					return 6
				elseIf (randomRoll > 58)
					return 2
				elseIf (randomRoll > 28)
					return 1
				endIf
			
			elseIf (randomRoll > 40 && playerActorRef.HasSpell(AbAddictionAlcoholSp))
				return 6
			elseIf (charisma >= 4 && charisma < 10 && randomRoll > 64)
				return 1
			elseIf (randomRoll > 50)
				return 10
			endIf
			
		endIf
	endIf
	
	return 0
EndFunction

Armor Function GetNukabearArmor()
	Armor nukaBear = None
	
	if ((DTSConditionals as DTSleep_Conditionals).IsDXAtomGirlActive)
	
		int nukaIndex = (DTSConditionals as DTSleep_Conditionals).DXAtomGirlNukaBearIndex
		
		if (nukaIndex >= 0 && nukaIndex < DTSleep_FemBedItemFList.GetSize())
			nukaBear = DTSleep_FemBedItemFList.GetAt(nukaIndex) as Armor
			;Debug.Trace(myScriptName + " getting Nukabear by index: " + nukaIndex + ", item " + nukaBear)
		else 
			nukaBear = Game.GetFormFromFile(0x02000955, "DX_Atom_Girl_Outfit.esp") as Armor
		endIf
	endIf

	return nukaBear
endFunction

Form Function GetPillowFormIfActorHas(Actor actorRef, ObjectReference bedRef = None)
	Form resultForm = None
	if (DTSleep_FemBedItemFList.GetSize() > 2)
		Form pillow = DTSleep_FemBedItemFList.GetAt(2)
		
		if (actorRef.GetItemCount(pillow) > 0)
			resultForm = pillow
		elseIf (bedRef != None && bedRef.GetItemCount(pillow))
			resultForm = pillow
		endIf
	endIf
	return resultForm
endFunction

;  if encounter unavailable then returns false else true for placed
; 
bool Function PlaceEncounterOnBedForActors(int encounterType, ObjectReference bedRef, Actor playerActorRef, Actor companionActorRef)
	BedDecorationObjRefArray = new ObjectReference[0]
	FormList bedDecorList = None 
	int idx = -1
	int tryCount = 3
	int itemsToPlace = 2
	bool isLowBed = false
	
	if (bedRef.HasKeyword(AnimFurnFloorBedAnimKY))
		isLowBed = true
	elseIf (bedRef.HasKeyword(AnimFurnLayDownUtilityBoxKY))
		isLowBed = true
	endIf
	
	;Debug.Trace(myScriptName + "PlaceEncounter type: " + encounterType)
	
	if (encounterType == 1 && DTSleep_FemBedItemFList)
		bedDecorList = DTSleep_FemBedItemFList
		idx = 1
		
	elseIf (encounterType == 2)
		; place something from FemList
		bedDecorList = DTSleep_FemBedItemFList
		int listSize = DTSleep_FemBedItemFList.GetSize()
		if (listSize > 0)
			if (listSize > 1)
				idx = Utility.RandomInt(0, listSize - 1)

				if (idx > 5)
					tryCount = listSize - 3
				endIf
			endIf
		else
			idx = 0
		endIf
	elseIf (encounterType == 3 && DTSleep_AddictionChemsFList)
		; charisma addiction
		bedDecorList = DTSleep_AddictionChemsFList
		if (bedDecorList.GetSize() > 1)
			idx = 1
		endIf
	elseIf (encounterType == 4 && DTSleep_AddictionChemsFList)
		; endurance addiction
		bedDecorList = DTSleep_AddictionChemsFList
		int listSize = bedDecorList.GetSize()
		if (listSize > 1)
			idx = Utility.RandomInt(5, listSize - 1)
			itemsToPlace = 3
			tryCount = 4
		endIf
	elseIf (encounterType == 5 && DTSleep_AddictionDrinkFList)
		; nuka cola addiction
		bedDecorList = DTSleep_AddictionDrinkFList
		if (bedDecorList.GetSize() > 6)
			idx = Utility.RandomInt(0, 5)
		endIf
	elseIf (encounterType == 6 && DTSleep_AddictionDrinkFList)
		; alcohol addiction
		bedDecorList = DTSleep_AddictionDrinkFList
		int listSize = DTSleep_AddictionDrinkFList.GetSize()
		if (listSize > 9)
			idx = Utility.RandomInt(7, listSize - 1)
			itemsToPlace = 3
			tryCount = 4
		endIf
	elseIf (encounterType == 7 && DTSleep_BedItemFlist)
		; nicotine addiction
		bedDecorList = DTSleep_BedItemFlist
		idx = 2
		tryCount = 2
	elseIf (encounterType == 8 && DTSleep_LoverItemFList)
		; lover items
		bedDecorList = DTSleep_LoverItemFList
		int listSize = DTSleep_LoverItemFList.GetSize()
		idx = Utility.RandomInt(-2, listSize)
		if (idx < 2)
			DTSleep_LoverItemFList.GetSize() - 1
		endIf
		tryCount = 3
	elseIf (encounterType == 9 && DTSleep_LoverItemFList)
		; half-dozen first item
		bedDecorList = DTSleep_LoverItemFList
		idx = 0
	elseIf (encounterType == 10 && DTSleep_BedItemFlist)
		; bed item
		bedDecorList = DTSleep_BedItemFlist
		idx = 4
		
	elseIf (encounterType == 11)
		; nuka bear
		bedDecorList = DTSleep_FemBedItemFList

		idx = (DTSConditionals as DTSleep_Conditionals).DXAtomGirlNukaBearIndex
		;Debug.Trace(myScriptName + "encounter 11 Nukabear index - " + idx)
		
		if (idx < 0)
			
			Armor nukaBear = GetNukabearArmor()
			if (nukaBear)
				
				if (bedDecorList.HasForm(nukaBear as Form))
					
					idx = bedDecorList.Find(nukaBear)
					
					(DTSConditionals as DTSleep_Conditionals).DXAtomGirlNukaBearIndex = idx
					;Debug.Trace(myScriptName + " found Nukabear index - " + idx)
				endIf
			endIf
		endIf
		
	elseIf (encounterType == 12)
		; teddy bears
		itemsToPlace = 6
		bedDecorList = DTSleep_FemBedItemFList
		idx = 1
	elseIf (encounterType == 13)
		; skull
		bedDecorList = DTSleep_BedItemFlist
		idx = 0
	elseIf (encounterType == 14)
		; special - 3 bears
		itemsToPlace = 3
		bedDecorList = DTSleep_FemBedItemFList
		idx = 1
	elseIf (encounterType >= 15)
		; bears from bed
		bedDecorList = DTSleep_FemBedItemFList
		idx = 1
		
		if (SleepBedRef != None)
			if (encounterType == 16)
				idx = bedDecorList.GetSize() - 1
				itemsToPlace = 1
			else
				itemsToPlace = SleepBedRef.GetItemCount(TeddyBear as Form)
				if (itemsToPlace > 12)
					itemsToPlace = 12
				endIf
			endIf
		endIf
	endIf
	
	if (idx >= 0 && bedDecorList && idx < bedDecorList.GetSize())
		int placedItemCount = 0
		int listSize = bedDecorList.GetSize()
		bool isDoubleBed = false
		if (DTSleep_BedsBigDoubleList.HasForm(bedRef.GetBaseObject()))
			isDoubleBed = true
		endIf

		;Debug.Trace(myScriptName + " placing items... idx: " + idx + " in list-Size: " + listSize)
		
		while (idx >= 0 && idx < listSize && tryCount > 0 && itemsToPlace > 0)
		
			; ensure have a base Form and not a specific Form of item to get proper count
			Form baseForm = bedDecorList.GetAt(idx) As Form
			if (placedItemCount == 0)
				if (encounterType == 100 || encounterType == 1 || encounterType == 12 || encounterType == 15)
					baseForm = TeddyBear as Form
				endIf
			endIf
			
			int itemCount = itemsToPlace
			
			if (encounterType < 15)
				; find out how many player or companion have 
				
				itemCount = playerActorRef.GetItemCount(baseForm)
				
				if (itemCount > 3)
					if (encounterType == 12 && itemCount > 6)
						itemCount = 6
					elseIf (encounterType == 9 && itemCount > 6)
						itemCount = 6
					else
						itemCount = 3
					endIf
				endIf
				
				if (itemCount == 0)
					
					if (bedRef.HasKeyword(DTSleep_OutfitContainerKY) && bedRef.GetItemCount(baseForm) > 0)
						itemCount = 1
					elseIf (CompanionRef != None && CompanionIsLover)
						itemCount = CompanionRef.GetItemCount(baseForm)
					endIf
				endIf
			endIf
			
			if (itemCount > 0)
				placedItemCount += 1
				itemsToPlace -= 1
				
				;Debug.Trace(myScriptName + "  we have something to place: " + baseForm + " at angle: " + bedRef.GetAngleZ())
				; we have something to place on bed
				Point3DOrient placeBedPoint
				Point3DOrient bedPoint = DTSleep_CommonF.PointOfObject(bedRef)
				int randomPlace = Utility.RandomInt(1, 3)
				
				ObjectReference mainNodeRef = PlaceFormAtObjectRef(DTSleep_DummyNode, playerActorRef)
				
				if (mainNodeRef != None)
				
					while (itemCount > 0)
					
						if (randomPlace == 1)
							placeBedPoint = GetPointBedCuddle(isLowBed, bedRef.GetAngleZ())
						elseIf (randomPlace == 2)
							placeBedPoint = GetPointBedHands(isLowBed, bedRef.GetAngleZ())
						elseIf (randomPlace == 3)
							placeBedPoint = GetPointBedKnees(isLowBed, bedRef.GetAngleZ())
						else
							placeBedPoint = GetPointBedFloor(bedRef.GetAngleZ())
						endIf
						
						
						float jitter = Utility.RandomFloat(0.5, 3.5)
						float xOffset = 0.0
						if (isDoubleBed)
							xOffset = 40.0
						endIf
						
						;Debug.Trace(myScriptName + "  placing item on bed at X,Y " + placeBedPoint.X + "," + placeBedPoint.Y)
						mainNodeRef.SetAngle(0.0, 0.0, placeBedPoint.Heading)
						mainNodeRef.SetPosition(bedPoint.X + placeBedPoint.X + xOffset + jitter, bedPoint.Y + placeBedPoint.Y - jitter, bedPoint.Z + placeBedPoint.Z)
						;mainNodeRef.MoveTo(bedRef, placeBedPoint.X + jitter, placeBedPoint.Y - jitter, placeBedPoint.Z, false)
					
						ObjectReference placedObjRef = PlaceFormAtObjectRef(baseForm, mainNodeRef)
					
						if (placedObjRef != None)
							;placedObjRef.SetAngle(0.0, 0.0, placeBedPoint.Heading)
							BedDecorationObjRefArray.Add(placedObjRef)
						endIf
						
						randomPlace += 1
						if (randomPlace > 3)
							Utility.Wait(0.02)
							randomPlace = Utility.RandomInt(1,2)
						endIf
						itemCount -= 1
					endWhile
					
					DTSleep_CommonF.DisableAndDeleteObjectRef(mainNodeRef, false)
				endIf
			else
				tryCount -= 1
			endIf
			
			idx -= 1
		endWhile
		
		if (placedItemCount > 0)
		
			return true
		endIf
	endIf
	
	BedDecorationObjRefArray = None
	
	return false 
EndFunction


Function ProcessEncounter()
	if (SleepEncounterType > 0)
		
		if (SleepEncounterType <= 100 && PlaceEncounterOnBedForActors(SleepEncounterType, SleepBedRef, PlayerRef, CompanionRef))
			;Debug.Trace(myScriptName + "  started with encounter: " + SleepEncounterType)
			RegisterForRemoteEvent(SleepBedRef, "OnExitfurniture")
		endIf
	else
		;Debug.Trace(myScriptName + "  started with no encounter")
		StopAll()
	endIf
EndFunction

Function RemoveBedDecoration()
	if BedDecorationObjRefArray
		int len = BedDecorationObjRefArray.length
		;Debug.Trace(myScriptName + "  removing decoration count: " + len)
		int idx = 0
		
		while (idx < len)
			ObjectReference decorationRef = BedDecorationObjRefArray[idx]
			bool fade = true
			if (idx < len - 2)
				fade = false
			endIf
			
			if (!DisableAndDeleteObjectRef(decorationRef, fade))
				Debug.Trace(myScriptName + "  failed to remove: " + decorationRef)
			endIf
			idx += 1
		endWhile
		
		BedDecorationObjRefArray.Clear()
	endIf
	BedDecorationObjRefArray = None
EndFunction

int Function StartupEncounter()
	SleepEncounterType = 0
	if (SleepBedRef && PlayerRef)
		int encType = GetAwakenEncounterTypeOnChanceForActors(PlayerRef, CompanionRef, CompanionIsLover)
		SleepEncounterType = encType
		
		StartTimer(1.2, RunEncounterID)
	endIf
	
	return SleepEncounterType
EndFunction