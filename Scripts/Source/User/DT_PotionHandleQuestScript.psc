Scriptname DT_PotionHandleQuestScript extends Quest

; based on VATS fix by 
; safely add potions when not in VATS since equip during VATS causes game freeze
;
; always runs - do not stop

Actor property PlayerRef auto const Mandatory

; --------------------------------
; Keep track of whether VATSMenu is open (VATS fix)
bool IsVATSMenuOpen = false

; Holds our potions for later processing (VATS fix)
Potion[] PotionQueue
bool ProcessingPotions = false

Event OnQuestInit()
	
	RegisterForMenuOpenCloseEvent("VATSMenu") ;for delaying EquipItem() calls (VATS fix)

EndEvent

Event OnMenuOpenCloseEvent(string asMenuName, bool abOpening)

	if (asMenuName == "VATSMenu") ;(VATS fix)
		if (abOpening)
			; VATS has initiated
			IsVATSMenuOpen = true
		else
			; VATS has ended
			IsVATSMenuOpen = false
			CallFunctionNoWait("TProcessPotionQueue", new var[0])
		endIf	
	endIf
EndEvent


; ---------- Global functions ---------------

; Equip potion if not in VATS, else add to PotionQueue (VATS fix)
Function TryEquipPotion_Global(Potion potionToApply)

	if (PotionQueue == None)
		PotionQueue = new Potion[0]
	endIf

	; when VATS opened, no movement controls, but let's check VATS anyway
	;
	if (IsVATSMenuOpen || !Game.IsMovementControlsEnabled())
		PotionQueue.Add(potionToApply)
	else
		if PotionQueue.Length > 0
			PotionQueue.Add(potionToApply)

			TProcessPotionQueue()

		else
			
			PlayerRef.EquipItem(potionToApply, false, true)
		endIf
	endIf
EndFunction

; ----------------  private functions

; Try to equip all potions in the queue (VATS fix)
Function TProcessPotionQueue()
	if !ProcessingPotions
		
		ProcessingPotions = true
		
		;if (PotionQueue.length > 0)
		;	Debug.Notification("VATS process potions")
		;endIf

		; when VATS open no movement controls, but let's chack VATS anyway
		while (PotionQueue.Length > 0 && !IsVATSMenuOpen && Game.IsMovementControlsEnabled())
			PlayerRef.EquipItem(PotionQueue[0], false, true)
			PotionQueue.Remove(0)
		endWhile
		
		ProcessingPotions = false
	endIf
EndFunction


; -----------------------------------------------