Scriptname DTSleep_OutfitContainerScript extends ObjectReference

; *********************
; script by DracoTorre
; Sleep Intimate
; https://www.dracotorre.com/mods/sleepintimate/
; https://github.com/Dracotorre/SleepIntimate
;
;
; holds outfit in array
; if player removes an item of outfit, remove from array

Message property DTSleep_QuestItemTransMsg auto const mandatory
FormList property DTSleep_QuestItemsList auto const mandatory		; items to restrict
FormList property DTSleep_QuestItemModList auto const				; mod items to restrict		--v2.53
Quest property MS04Quest auto const									; restrict quest items if quest incomplete
FormList property DTSleep_ArmorPipBoyList auto const				; v1.92 - restrict these important items as backup measure
FormList property DTSleep_ArmorPipPadList auto const

int property HasStoredOutfit auto hidden
{ 0 for none, 1 for regular outfit storage, 2 for stored sleep outfit}

bool isTransferOutfit
Form[] outfitArmorFormArray

;Event OnItemAdded(Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akSourceContainer)
;	
;EndEvent

Event OnItemRemoved(Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akDestContainer)
	
	if (!isTransferOutfit && HasStoredOutfit > 0)
	
		int index = outfitArmorFormArray.Length - 1
		
		while (index >= 0)
			
			Form storedItem = outfitArmorFormArray[index]
			
			if (storedItem != None && storedItem == akBaseItem)
				
				if (self.GetItemCount(akBaseItem) <= aiItemCount)
					outfitArmorFormArray.Remove(index)
					;Debug.Trace("[DTSleep_OutfitContainer] removing outfit item from list: " + storedItem)
					
					if (outfitArmorFormArray.Length <= 0)
						;Debug.Trace("[DTSleep_OutfitContainer] last item removed - remove HasStoredOutfit flag ")
						HasStoredOutfit = 0
					endIf
				endIf
				
				index = -2
			endIf
			
			index -= 1
		endWhile
		
		if (HasStoredOutfit > 0 && self.GetItemCount() == 0)
			;Debug.Trace("[DTSleep_OutfitContainer] container empty - remove HasStoredOutfit flag ")
			HasStoredOutfit = 0
		endIf
		
	endIf
endEvent

int Function AddOutfit(Form[] armorArray, ObjectReference fromRef, bool isSleepOutfit = false)
	
	bool hasShownQuestWarn = false
	bool ms04Done = false
	
	if (MS04Quest != None && MS04Quest.IsCompleted())
		ms04Done = true
	endIf
	
	if (DTSleep_QuestItemTransMsg == None)
		hasShownQuestWarn = true
	endIf
	
	isTransferOutfit = true
	
	self.RemoveAllInventoryEventFilters()
	
	outfitArmorFormArray = new Form[0]
	
	if (armorArray.Length > 0)
		
		int index = 0
		
		while (index < armorArray.Length)
		
			Form item = armorArray[index]
			if (item != None)
			
				if (!ms04Done && DTSleep_QuestItemsList != None && DTSleep_QuestItemsList.HasForm(item))
					if (!hasShownQuestWarn)
						DTSleep_QuestItemTransMsg.Show()
						hasShownQuestWarn = true
					endIf
				elseIf (DTSleep_QuestItemModList != None && DTSleep_QuestItemModList.HasForm(item))
					; v2.53 - not adding --
					if (fromRef != None && fromRef == Game.GetPlayer() as ObjectReference)
						Game.GetPlayer().EquipItem(item, false, true)	; okay-remove, silent
					endIf
				elseIf (DTSleep_ArmorPipBoyList != None && DTSleep_ArmorPipBoyList.HasForm(item))
					; not adding - 
					if (fromRef != None && fromRef == Game.GetPlayer() as ObjectReference)
						Game.GetPlayer().EquipItem(item, false, true)	; okay-remove, silent
					endIf
					
				elseIf (DTSleep_ArmorPipPadList != None && DTSleep_ArmorPipPadList.HasForm(item))
					; nope
					if (fromRef != None && fromRef == Game.GetPlayer() as ObjectReference)
						
						Game.GetPlayer().EquipItem(item, false, true)		; okay-remove, silent
					endIf
				else
			
					if (fromRef != None && fromRef.GetItemCount(item) > 0)
						fromRef.RemoveItem(item, 1, true, self)
						
						;Debug.Trace("[DTSleep_OutfitContainer] Add-Moving item " + item + " from " + fromRef)
						
						AddOutFitItem(item)
					else
						Debug.Trace("[DTSleep_OutfitContainer] Added item not from source!! " + item)
						;self.AddItem(item, 1, true)
					endIf
				endIf
			endIf
			
			index += 1
		endWhile
		
		if (outfitArmorFormArray.Length > 0)
			if (isSleepOutfit)
				HasStoredOutfit = 2
			else
				HasStoredOutfit = 1
			endIf
		endIf
	endIf
	
	
	isTransferOutfit = false

	return outfitArmorFormArray.Length
endFunction

Function AddOutFitItem(Form item)
	
	if (item != None)
		self.AddInventoryEventFilter(item)  ; only keep track of outfit items
		outfitArmorFormArray.Add(item, 1)
	endIf
endFunction

Form[] Function GetOutfit(ObjectReference toRef)
	
	Form[] resultArray = new Form[0]
	
	isTransferOutfit = true
	
	self.RemoveAllInventoryEventFilters()   ; must clear first
	
	int index = 0
	
	if (HasStoredOutfit >= 1)
	
		while (index < outfitArmorFormArray.Length)
		
			Form item = outfitArmorFormArray[index]
			
			if (item != None && self.GetItemCount(item) > 0)
				;Debug.Trace("[DTSleep_OutfitContainer] Remove-Moving item " + item + " to " + toRef)
				resultArray.Add(item)
				self.RemoveItem(item, 1, true, toRef)
			endIf
		
			index += 1
		endWhile
		
		outfitArmorFormArray.Clear()
	endIf
	
	HasStoredOutfit = 0
	
	isTransferOutfit = false
	
	return resultArray
endFunction
