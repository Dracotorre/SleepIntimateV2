Scriptname DTSleep_EquipMonitor extends ReferenceAlias

; Equip Monitor for Sleep Intimate 
; DracoTorre
;
; used with DTSleep_IntimateUndressQuest - player alias
;
; keep quest running on player alias to keep track
; of specialty gear stored in DTSleep_DressData
;
;
;

Group A_Main
DTSleep_Conditionals property DTSConditionals auto
GlobalVariable property DTSleep_EquipMonInit auto
{ initialized }
GlobalVariable property DTSleep_AdultContentOn auto const
GlobalVariable property DTSleep_PlayerEquipBackpackCount auto
GlobalVariable property DTSleep_PlayerEquipSleepwearCount auto
GlobalVariable property DTSleep_PlayerEquipSleepGloveCount auto			; v2.48
GlobalVariable property DTSleep_PlayerEquipIntimateItemCount auto
GlobalVariable property DTSleep_PlayerEquipStrapOnCount auto
GlobalVariable property DTSleep_PlayerEquipJacketCount auto
GlobalVariable property DTSleep_PlayerEquipMaskCount auto
GlobalVariable property DTSleep_PlayerNecklaceChokerCount auto
{ 10 = choker, 1 = necklace, 11 = both }
GlobalVariable property DTSleep_PlayerEquipExtraPartsCount auto
{ extra parts and clothing }
GlobalVariable property DTSleep_PlayerEquipFootWearCount auto		; v2.80
{ 10 = stockings, 1 = shoes, 11 = both }
GlobalVariable property DTSleep_CaptureSleepwearEnable auto
GlobalVariable property DTSleep_CaptureBackpackEnable auto
GlobalVariable property DTSleep_CaptureIntimateApparelEnable auto
GlobalVariable property DTSleep_CaptureStrapOnEnable auto
GlobalVariable property DTSleep_CaptureJacketEnable auto
GlobalVariable property DTSleep_CaptureMaskEnable auto
GlobalVariable property DTSleep_CaptureExtraPartsEnable auto
GlobalVariable property DTSleep_CaptureShoeEnable auto				; v2.80
GlobalVariable property DTSleep_CaptureStockingEnable auto
GlobalVariable property DTSleep_ExtraArmorsEnabled auto
{ only works when storing equipment }
GlobalVariable property DTSleep_SettingMultiJacketOn auto const
{ allow 2 jackets or force 2nd off }
DTSleep_DressData property DressData auto const
Message property DTSleep_SleepwearAddMsg auto const
Message property DTSleep_SleepwearRemMsg auto const
Message property DTSleep_BackpackAddMsg auto const
Message property DTSleep_BackpackRemMsg auto const
Message property DTSleep_ExtraPartsAddMsg auto const
Message property DTSleep_ExtraPartsRemMsg auto const
Message property DTSleep_IntimateAttireAddMsg auto const
Message property DTSleep_InitmateAttireRemMsg auto const
Message property DTSleep_MaskAddMsg auto const
Message property DTSleep_MaskRemMsg auto const
Message property DTSleep_StrapOnAddMsg auto const
Message property DTSleep_StrapOnRemMsg auto const
Message property DTSleep_JacketAddMsg auto const
Message property DTSleep_JacketRemMsg auto const
Message property DTSleep_FailedToAddCustomArmorMsg auto const
Message property DTSleep_ShoeAddMsg auto const					; v2.80
Message property DTSleep_ShoeRemMsg auto const					; v2.80
Message property DTSleep_StockingsAddMsg auto const				; v2.80
Message property DTSleep_StockingsRemMsg auto const				; v2.80
Armor property DTSleep_NudeRing auto const
Armor property DTSleep_NudeRingNoHands auto const
Armor property DTSleep_NudeSuit auto const
Armor property DTSleep_NudeSuitPlayerUp auto const
EndGroup

Group B_Keywords
Keyword property ArmorTypeHatKY auto const
Keyword property ArmorTypeHelmetKY auto const
Keyword property ArmorTypePowerKY auto const
Keyword property ArmorBodyPartHeadKY auto const  ; also used for shock collar, some masks
{ not currently used }
Keyword property DTSleep_IntimateOutfitFemKY auto const
Keyword property DTSleep_SleepWearCamiKY auto const
Keyword property DTSleep_SleepwearKY auto const
EndGroup

Group C_Lists
FormList property DTSleep_ArmorExtraPartsList auto const
{ extra slot accessories always removed }
FormList property DTSleep_ArmorExtraClothingList auto const
{ extra slot clothing removed if undressing }
FormList property DTSleep_ArmorSlot41List auto const
{ slot 41 armor clothing  }
FormList property DTSleep_ArmorSlot55List auto const
{ slot 55 armor clothing  }
FormList property DTSleep_ArmorSlot58List auto const
{ slot 58 armor clothing  }
FormList property DTSleep_ArmorSlotFXList auto const
{ slot 61-FX armor clothing }
FormList property DTSleep_ArmorSlotULegList auto const
FormList property DTSleep_StrapOnList auto const
FormList property DTSleep_ArmorBackPacksList auto const
FormList property DTSleep_ArmorBackPacksnoGOList auto const
FormList property DTSleep_ArmorCarryPouchList auto const
FormList property DTSleep_ArmorHatHelmList auto const
FormList property DTSleep_ArmorTorsoList auto const
FormList property DTSleep_ArmorArmLeftList auto const
FormList property DTSleep_ArmorArmRightList auto const
FormList property DTSleep_ArmorLegLeftList auto const
FormList property DTSleep_ArmorLegRightList auto const
FormList property DTSleep_ArmorJacketsClothingList auto const
FormList property DTSleep_IntimateAttireList auto const
FormList property DTSleep_IntimateAttireMaleList auto const
FormList property DTSleep_SleepAttireFemale auto const
FormList property DTSleep_SleepAttireMale auto const
FormList property DTSleep_ArmorAllExceptionList auto const
{ full body clothing that includes outer armor }
FormList property DTSleep_ArmorChokerList auto const
FormList property DTSleep_ArmorNecklaceSlot50List auto const
FormList property DTSleep_ArmorMaskList auto const
FormList property DTSleep_LeitoGunList auto const
FormList property DTSleep_BT2GunList auto const					; added v2.14 (forgot to add sooner)
FormList property DTSleep_ArmorGlassesList auto const
FormList property DTSleep_ArmorPipBoyList auto const
FormList property DTSleep_ArmorPipPadList auto const
FormList property DTSleep_IntimateAttireFemaleOnlyList auto const
FormList property DTSleep_NudeRingList auto const
FormList property DTSleep_SexyClothesFList auto const
FormList property DTSleep_SexyClothesMList auto const
FormList property DTSleep_ArmorJewelry58List auto const			; added v2.27
FormList property DTSleep_SleepAttireHandsList auto const 		; added v2.48 to keep track of intimate outfit with gloves
FormList property DTSleep_ArmorJewelry57List auto const				; added v2.71
FormList property DTSleep_ArmorJewelry56List auto const				; added v2.71
FormList property DTSleep_ArmorShoeList auto const				; v2.80
FormList property DTSleep_ArmorStockingsList auto const			; v2.80
EndGroup

; -------------------  hidden
;
Actor property CompanionRegistered auto hidden			; store and keep track in DressData
Actor property CompanionSecondRegistered auto hidden	; store only, no tracking
bool property StoringPlayerEquipment auto hidden
bool property StoringCompanionEquipment auto hidden


; ------------- variables
;
bool processingUnequip = false
bool processingCompUnequip = false
int PlayerExtraClothingCount = 0
int PlayerExtraPartsCount = 0
int CompanionExtraClothingCount = 0
int CompanionExtraPartsCount = 0
int RemSecondJacketTimerID = 15 const

Form[] EMPlayerEquippedArmorFormArray     		; list to re-equip after
Form[] EMCompanionEquippedArmorFormArray		; list to re-equip after
Form[] EMCompanionSecEquippedArmorFormArray		; list to re-equip after
Form[] MyPlayerEquippedArray					; all currently equipped;  init=5
Form[] MyPlayerNeedToUnEquipArray 	; unequip later

; **************************** Events *******************

Event OnTimer(int aiTimerID)
	if (aiTimerID == 13)
		StoreProcessPlayerNeedToUnEquip()
	elseIf (aiTimerID == RemSecondJacketTimerID)
		RemoveSecondJacket()
	endIf
EndEvent

; -------------------------
; player character

Event OnItemEquipped(Form akBaseObject, ObjectReference akReference)
	
	
	if (akBaseObject as Armor)

		if (DTSleep_IntimateOutfitFemKY != None && akBaseObject.HasKeyword(DTSleep_IntimateOutfitFemKY))
			if (DTSleep_AdultContentOn.GetValueInt() < 2 || !(Debug.GetPlatformName() as bool) || (DTSConditionals as DTSleep_Conditionals).NanaRace != None)
				Utility.WaitMenuMode(0.3)
				Actor playerRef = self.GetActorReference()
				playerRef.UnequipItem(akBaseObject)
				
				return
			endIf
		endIf
		
		if (DTSleep_EquipMonInit.GetValue() >= 0.0)
	
			int i = 0
			while (processingUnequip && i < 45)
				Utility.WaitMenuMode(0.05)
				i += 1
			endWhile
		
			; ignore nude-suit armor
			if (akBaseObject == DTSleep_NudeSuitPlayerUp || DTSleep_LeitoGunList.HasForm(akBaseObject) || DTSleep_NudeRingList.HasForm(akBaseObject) || DTSleep_BT2GunList.HasForm(akBaseObject))
				return
			endIf
			
			if (DTSleep_EquipMonInit.GetValue() >= 5.0)
				
				if (StoreAddMyPlayerEquipItem(akBaseObject) == false)
					; already equipped or un-equip requested  -- auto-re-equip may cause this due to our priority process wait on UnEquip
					;Debug.Trace("[DTSleep Equip] player OnEquip -- not setting item " + akBaseObject)
					return
				endIf
			endIf
		
			if (StoringPlayerEquipment)
				StoreRemoveFromPlayerEquip(akBaseObject)
			endIf
			
			if (akBaseObject.HasKeyword(ArmorTypeHatKY) || akBaseObject.HasKeyword(ArmorTypeHelmetKY) || DTSleep_ArmorHatHelmList.HasForm(akBaseObject))
				
				DressData.PlayerLastEquippedHat = DressData.PlayerEquippedHat
				DressData.PlayerEquippedHat = akBaseObject as Armor
				
			elseIf (DTSleep_ArmorChokerList != None && DTSleep_ArmorChokerList.HasForm(akBaseObject))
				DressData.PlayerEquippedChokerItem = akBaseObject as Armor
			elseIf (DTSleep_ArmorNecklaceSlot50List != None && DTSleep_ArmorNecklaceSlot50List.HasForm(akBaseObject))
				
				DressData.PlayerEquippedNecklaceItem = akBaseObject as Armor
				
			elseIf (DTSleep_ArmorTorsoList != None && DTSleep_ArmorTorsoList.HasForm(akBaseObject))
				DressData.PlayerEquippedArmorTorsoItem = akBaseObject as Armor
				DressData.PlayerEquippedSlot41Item = None
			elseIf (DTSleep_ArmorArmLeftList != None && DTSleep_ArmorArmLeftList.HasForm(akBaseObject))
				DressData.PlayerEquippedArmorArmLeftItem = akBaseObject as Armor
			elseIf (DTSleep_ArmorArmRightList != None && DTSleep_ArmorArmRightList.HasForm(akBaseObject))
				DressData.PlayerEquippedArmorArmRightItem = akBaseObject as Armor
			elseIf (DTSleep_ArmorLegLeftList != None && DTSleep_ArmorLegLeftList.HasForm(akBaseObject))
				DressData.PlayerEquippedArmorLegLeftItem = akBaseObject as Armor
			elseIf (DTSleep_ArmorLegRightList != None && DTSleep_ArmorLegRightList.HasForm(akBaseObject))
				DressData.PlayerEquippedArmorLegRightItem = akBaseObject as Armor
				
			elseIf (ValidArmorToCheck(akBaseObject as Armor, akBaseObject))
				;if (akReference)
					;SetArmorItem((akReference as Form) as Armor) ; this may not be right
				;else
				
				if (DTSleep_CaptureSleepwearEnable.GetValue() > 0.0 && DTSleep_EquipMonInit.GetValue() > 0.0)
					int gender = DressData.PlayerGender
					if (gender < 0)
						gender = (Game.GetPlayer().GetBaseObject() as ActorBase).GetSex()
						DressData.PlayerGender = gender
					endIf
					
					if (ProcessSleepwearItem(akBaseObject, gender))
					
						if (DTSleep_ArmorSlot58List.HasForm(akBaseObject))
							DressData.PlayerEquippedSlot58IsSleepwear = true
							DressData.PlayerEquippedSlot58Item = akBaseObject as Armor
						elseIf (DTSleep_ArmorSlotFXList.HasForm(akBaseObject))
							DressData.PlayerEquippedSlotFXIsSleepwear = true
							DressData.PlayerEquippedSlotFXItem = akBaseObject as Armor
						else
							DressData.PlayerEquippedSleepwearItem = akBaseObject as Armor
						endIf
					else
						SetArmorItem(akBaseObject as Armor)
					endIf
					DTSleep_CaptureSleepwearEnable.SetValueInt(0)
					
				elseIf (DTSleep_CaptureIntimateApparelEnable.GetValue() > 0.0 && DTSleep_EquipMonInit.GetValue() > 0.0)
					int gender = DressData.PlayerGender
					if (gender < 0)
						gender = (Game.GetPlayer().GetBaseObject() as ActorBase).GetSex()
						DressData.PlayerGender = gender
					endIf
					if (ProcessIntimateItem(akBaseObject, gender))
						DressData.PlayerEquippedIntimateAttireItem = akBaseObject as Armor
					else
						SetArmorItem(akBaseObject as Armor)
					endIf
					
					DTSleep_CaptureIntimateApparelEnable.SetValueInt(0)
					
				elseIf (DTSleep_CaptureMaskEnable.GetValue() > 0.0 && DTSleep_EquipMonInit.GetValue() > 0.0)
					if (ProcessMaskItem(akBaseObject))
						DressData.PlayerEquippedMask = akBaseObject as Armor
					else
						SetArmorItem(akBaseObject as Armor)
					endIf
					DTSleep_CaptureMaskEnable.SetValueInt(0)
					
				elseIf (DTSleep_CaptureStrapOnEnable.GetValue() > 0.0 && DTSleep_EquipMonInit.GetValue() > 0.0)
					
					if (ProcessStrapOnItem(akBaseObject))
						DressData.PlayerEquippedStrapOnItem = akBaseObject as Armor
					else
						SetArmorItem(akBaseObject as Armor)
					endIf
					
					DTSleep_CaptureStrapOnEnable.SetValueInt(0)
					
				elseIf (DTSleep_CaptureBackpackEnable.GetValue() > 0.0 && DTSleep_EquipMonInit.GetValue() > 0.0)
					if (ProcessBackpackItem(akBaseObject))
						DressData.PlayerEquippedBackpackItem = akBaseObject as Armor
					else
						SetArmorItem(akBaseObject as Armor)
					endIf
					
					DTSleep_CaptureBackpackEnable.SetValueInt(0)
					
				elseIf (DTSleep_CaptureJacketEnable.GetValue() > 0.0 && DTSleep_EquipMonInit.GetValue() > 0.0)
					if (ProcessJacketItem(akBaseObject))
						if (DressData.PlayerEquippedJacketItem != None && DressData.PlayerEquippedJacketSecondItem == None)
							DressData.PlayerEquippedJacketSecondItem = akBaseObject as Armor
						else
							DressData.PlayerEquippedJacketItem = akBaseObject as Armor
						endIf
					else
						SetArmorItem(akBaseObject as Armor)
					endIf
					
					DTSleep_CaptureJacketEnable.SetValueInt(0)
					
				elseIf (DTSleep_CaptureShoeEnable.GetValue() > 0.0 && DTSleep_EquipMonInit.GetValue() > 0.0)		; v2.80
					if (ProcessShoeItem(akBaseObject))
						DressData.PlayerEquippedShoeItem = akBaseObject as Armor
					else
						SetArmorItem(akBaseObject as Armor)
					endIf
					
					DTSleep_CaptureShoeEnable.SetValueInt(0)
					
				elseIf (DTSleep_CaptureStockingEnable.GetValue() > 0.0 && DTSleep_EquipMonInit.GetValue() > 0.0)		; v2.80
					if (ProcessStockingsItem(akBaseObject))
						DressData.PlayerEquippedStockingsItem = akBaseObject as Armor
					else
						SetArmorItem(akBaseObject as Armor)
					endIf
					
					DTSleep_CaptureStockingEnable.SetValueInt(0)
				else
				
					SetArmorItem(akBaseObject as Armor)
				endIf
			endIf
			
			UpdateClothingCounts()
			
			;Debug.Trace("[DTSleep_EquipMon] equipped " + akBaseObject)
			;Debug.Trace("[DTSleep_EquipMon] EndEquip Jacket: " + DressData.PlayerEquippedJacketItem)
			;Debug.Trace("[DTSleep_EquipMon] EndEquip Last: " + DressData.PlayerLastEquippedJacketItem)
			;Debug.Trace("[DTSleep_EquipMon] EndEquip Second: " + DressData.PlayerEquippedJacketSecondItem)
		endIf
	endIf
endEvent

; player character
Event OnItemUnequipped(Form akBaseObject, ObjectReference akReference)
	; for bump item, order is equip-first then unequip
	
	processingUnequip = true
	
	if (akBaseObject as Armor && DTSleep_EquipMonInit.GetValue() >= 0.0)
	
		if (akBaseObject == DTSleep_NudeSuitPlayerUp || DTSleep_LeitoGunList.HasForm(akBaseObject) || DTSleep_NudeRingList.HasForm(akBaseObject))
			;Debug.Trace("[DTSleep_EquipMon] **** ignore un-equip nude-armor " + akBaseObject)
			return
		endIf
		
		if (DTSleep_EquipMonInit.GetValue() >= 5.0)
			if (StoreRemoveMyPlayerEquip(akBaseObject) == false)
				; could be timing issue with auto-re-equip and our process pause - add to equip-ignore list
				;Debug.Trace("[DTSleep_EquipMon] OnItemUnequipped baseObject as Armor: " + akBaseObject + " not found on equip list")
				if (MyPlayerNeedToUnEquipArray == None)
					MyPlayerNeedToUnEquipArray = new Form[0]
				endIf
				MyPlayerNeedToUnEquipArray.Add(akBaseObject)
				; timer to clear array
				StartTimer(1.7, 13)
			endIf
		endIf

		if (StoringPlayerEquipment)

			StoreAddToPlayerEquip(akBaseObject, akReference)
		endIf
		
		if (akBaseObject.HasKeyword(ArmorTypeHatKY) || akBaseObject.HasKeyword(ArmorTypeHelmetKY) || DTSleep_ArmorHatHelmList.HasForm(akBaseObject))
			if (DressData.PlayerEquippedHat == akBaseObject)
				DressData.PlayerLastEquippedHat = DressData.PlayerEquippedHat
				DressData.PlayerEquippedHat = None
			endIf

		elseIf (DTSleep_ArmorChokerList && DTSleep_ArmorChokerList.HasForm(akBaseObject))
			if (DressData.PlayerEquippedChokerItem == akBaseObject)
				DressData.PlayerEquippedChokerItem = None
			endIf
		elseIf (DTSleep_ArmorNecklaceSlot50List && DTSleep_ArmorNecklaceSlot50List.HasForm(akBaseObject))
			if (DressData.PlayerEquippedNecklaceItem == akBaseObject)
				DressData.PlayerEquippedNecklaceItem = None
			endIf
		elseIf (DTSleep_ArmorTorsoList != None && DTSleep_ArmorTorsoList.HasForm(akBaseObject))
			if (DressData.PlayerEquippedArmorTorsoItem == akBaseObject)
				DressData.PlayerEquippedArmorTorsoItem = None
			endIf
		elseIf (DTSleep_ArmorArmLeftList != None && DTSleep_ArmorArmLeftList.HasForm(akBaseObject))
			if (DressData.PlayerEquippedArmorArmLeftItem == akBaseObject)
				DressData.PlayerEquippedArmorArmLeftItem = None
			endIf
		elseIf (DTSleep_ArmorArmRightList != None && DTSleep_ArmorArmRightList.HasForm(akBaseObject))
			if (DressData.PlayerEquippedArmorArmRightItem == akBaseObject)
				DressData.PlayerEquippedArmorArmRightItem = None
			endIf
		elseIf (DTSleep_ArmorLegLeftList != None && DTSleep_ArmorLegLeftList.HasForm(akBaseObject))
			if (DressData.PlayerEquippedArmorLegLeftItem == akBaseObject)
				DressData.PlayerEquippedArmorLegLeftItem = None
			endIf
		elseIf (DTSleep_ArmorLegRightList != None && DTSleep_ArmorLegRightList.HasForm(akBaseObject))
			if (DressData.PlayerEquippedArmorLegRightItem  == akBaseObject)
				DressData.PlayerEquippedArmorLegRightItem = None
			endIf
			
		elseIf (ValidArmorToCheck(akBaseObject as Armor, akBaseObject))
			
			RemoveArmorItem(akBaseObject as Armor)
		endIf
		
		UpdateClothingCounts()
	endIf
	
	processingUnequip = false
endEvent

; -------------------------------------------------------
; companion
Event Actor.OnItemEquipped(Actor akSender, Form akBaseObject, ObjectReference akReference)
	
	
	if (akBaseObject as Armor)
	
		if (akBaseObject.HasKeyword(DTSleep_IntimateOutfitFemKY))
			if (DTSleep_AdultContentOn.GetValueInt() < 2 || !DTSConditionals.ImaPCMod)
				Utility.WaitMenuMode(0.3)
				akSender.UnequipItem(akBaseObject)
				
				return
			endIf
		endIf
	
		int i = 0
		while (processingCompUnequip && i < 45)
			Utility.WaitMenuMode(0.05)
			i += 1
		endWhile
		
		if (CompanionSecondRegistered != None && akSender == CompanionSecondRegistered)
		
			if (StoringCompanionEquipment)
				StoreRemoveFromCompanionSecEquip(akBaseObject)
			endIf
			
		elseIf (akSender == CompanionRegistered && DTSleep_EquipMonInit.GetValue() >= 0.0)
		
			;Debug.Trace("[DTSleep EquipMon] companion OnItemEquipped " + akSender + " baseObject as Armor: " + akBaseObject)
			if (StoringCompanionEquipment)
				StoreRemoveFromCompanionEquip(akBaseObject)
			endIf
			
			if (akBaseObject.HasKeyword(ArmorTypeHatKY) || akBaseObject.HasKeyword(ArmorTypeHelmetKY) || DTSleep_ArmorHatHelmList.HasForm(akBaseObject))
				
				DressData.CompanionHat = akBaseObject as Armor
				
			elseIf (DTSleep_ArmorChokerList && DTSleep_ArmorChokerList.HasForm(akBaseObject))
				DressData.CompanionChokerItem = akBaseObject as Armor
			elseIf (DTSleep_ArmorNecklaceSlot50List && DTSleep_ArmorNecklaceSlot50List.HasForm(akBaseObject))

				DressData.CompanionNecklaceItem = akBaseObject as Armor
			elseIf (DTSleep_ArmorTorsoList != None && DTSleep_ArmorTorsoList.HasForm(akBaseObject))
				DressData.CompanionEquippedArmorTorsoItem = akBaseObject as Armor
				DressData.CompanionEquippedSlot41Item = None
			elseIf (DTSleep_ArmorArmLeftList != None && DTSleep_ArmorArmLeftList.HasForm(akBaseObject))
				DressData.CompanionEquippedArmorArmLeftItem = akBaseObject as Armor
			elseIf (DTSleep_ArmorArmRightList != None && DTSleep_ArmorArmRightList.HasForm(akBaseObject))
				DressData.CompanionEquippedArmorArmRightItem = akBaseObject as Armor
			elseIf (DTSleep_ArmorLegLeftList != None && DTSleep_ArmorLegLeftList.HasForm(akBaseObject))
				DressData.CompanionEquippedArmorLegLeftItem = akBaseObject as Armor
			elseIf (DTSleep_ArmorLegRightList != None && DTSleep_ArmorLegRightList.HasForm(akBaseObject))
				DressData.CompanionEquippedArmorLegRightItem = akBaseObject as Armor
				
			elseIf (ValidArmorToCheck(akBaseObject as Armor, akBaseObject))
			
				if (DTSleep_CaptureSleepwearEnable.GetValue() > 0.0 && DTSleep_EquipMonInit.GetValue() > 0.0)
					int gender = (akSender.GetBaseObject() as ActorBase).GetSex()

					if (ProcessSleepwearItem(akBaseObject, gender))
					
						if (DTSleep_ArmorSlot58List.HasForm(akBaseObject))
							DressData.CompanionEquippedSlot58IsSleepwear = true 
							DressData.CompanionEquippedSlot58Item = akBaseObject as Armor
						elseIf (DTSleep_ArmorSlotFXList.HasForm(akBaseObject))
							DressData.CompanionEquippedSlotFXIsSleepwear = true
							DressData.CompanionEquippedSlotFXItem = akBaseObject as Armor
						else
							DressData.CompanionEquippedSleepwearItem = akBaseObject as Armor
						endIf
					else
						SetCompanionArmorItem(akBaseObject as Armor)
					endIf
					DTSleep_CaptureSleepwearEnable.SetValueInt(0)
					
				elseIf (DTSleep_CaptureIntimateApparelEnable.GetValue() > 0.0 && DTSleep_EquipMonInit.GetValue() > 0.0)
					int gender = (akSender.GetBaseObject() as ActorBase).GetSex()
					
					if (ProcessIntimateItem(akBaseObject, gender))
						DressData.CompanionEquippedIntimateAttireItem = akBaseObject as Armor
					else
						SetCompanionArmorItem(akBaseObject as Armor)			; v2.50 - fix
					endIf
					
					DTSleep_CaptureIntimateApparelEnable.SetValueInt(0)
					
				; v2.50 -- allow capture other items on companion
				elseIf (DTSleep_CaptureMaskEnable.GetValue() > 0.0 && DTSleep_EquipMonInit.GetValue() > 0.0)
					if (ProcessMaskItem(akBaseObject))
						DressData.CompanionEquippedMask = akBaseObject as Armor
					else
						SetCompanionArmorItem(akBaseObject as Armor)
					endIf
					DTSleep_CaptureMaskEnable.SetValueInt(0)
					
				elseIf (DTSleep_CaptureStrapOnEnable.GetValue() > 0.0 && DTSleep_EquipMonInit.GetValue() > 0.0)
					
					if (ProcessStrapOnItem(akBaseObject))
						DressData.CompanionEquippedStrapOnItem = akBaseObject as Armor
					else
						SetCompanionArmorItem(akBaseObject as Armor)
					endIf
					
					DTSleep_CaptureStrapOnEnable.SetValueInt(0)
					
				elseIf (DTSleep_CaptureBackpackEnable.GetValue() > 0.0 && DTSleep_EquipMonInit.GetValue() > 0.0)
					if (ProcessBackpackItem(akBaseObject))
						DressData.CompanionEquippedBackpackItem = akBaseObject as Armor
					else
						SetCompanionArmorItem(akBaseObject as Armor)
					endIf
					
					DTSleep_CaptureBackpackEnable.SetValueInt(0)
					
				elseIf (DTSleep_CaptureJacketEnable.GetValue() > 0.0 && DTSleep_EquipMonInit.GetValue() > 0.0)
					if (ProcessJacketItem(akBaseObject))
						if (DressData.CompanionEquippedJacketItem != None && DressData.CompanionEquippedJacketSecondItem == None)
							DressData.CompanionEquippedJacketSecondItem = akBaseObject as Armor
						else
							DressData.CompanionEquippedJacketItem = akBaseObject as Armor
						endIf
					else
						SetCompanionArmorItem(akBaseObject as Armor)
					endIf
					
					DTSleep_CaptureJacketEnable.SetValueInt(0)
				else
					SetCompanionArmorItem(akBaseObject as Armor)
				endIf
				
			endIf
		endIf
	endIf
EndEvent

; companion
Event Actor.OnItemUnequipped(Actor akSender, Form akBaseObject, ObjectReference akReference)
	; order of replace is Equip-first then Unequip, so set None if same item
	; wait player first
	;int i = 0
	;while (processingUnequip && i < 45)
	;	Utility.WaitMenuMode(0.05)
	;	i += 1
	;endWhile
	processingCompUnequip = true
	
	if (akBaseObject as Armor)
		
		if (CompanionSecondRegistered != None && akSender == CompanionSecondRegistered && DTSleep_EquipMonInit.GetValue() >= 0.0)
			
			if (StoringCompanionEquipment)
				;Debug.Trace("[DTSleep_EquipMon] Store Un-equip 2nd Comp: " + akSender + " baseObject as Armor: " + akBaseObject)
				
				StoreAddToCompanionSecEquip(akBaseObject)
			endIf
		elseIf (akSender == CompanionRegistered && DTSleep_EquipMonInit.GetValue() >= 0.0)
			
			if (StoringCompanionEquipment)
				StoreAddToCompanionEquip(akBaseObject, akReference)
			endIf
		
			if (akBaseObject.HasKeyword(ArmorTypeHatKY) || akBaseObject.HasKeyword(ArmorTypeHelmetKY) || DTSleep_ArmorHatHelmList.HasForm(akBaseObject))
				if (DressData.CompanionHat == akBaseObject)
					DressData.CompanionHat = None
				endIf
			elseIf (DTSleep_ArmorChokerList && DTSleep_ArmorChokerList.HasForm(akBaseObject))
				if (DressData.CompanionChokerItem == akBaseObject)
					DressData.CompanionChokerItem = None
				endIf
			elseIf (DTSleep_ArmorNecklaceSlot50List && DTSleep_ArmorNecklaceSlot50List.HasForm(akBaseObject))
				if (DressData.CompanionNecklaceItem == akBaseObject)
					DressData.CompanionNecklaceItem = None
				endIf
			elseIf (DTSleep_ArmorTorsoList != None && DTSleep_ArmorTorsoList.HasForm(akBaseObject))
				if (DressData.CompanionEquippedArmorTorsoItem)
					DressData.CompanionEquippedArmorTorsoItem = None
				endIf
			elseIf (DTSleep_ArmorArmLeftList != None && DTSleep_ArmorArmLeftList.HasForm(akBaseObject))
				if (DressData.CompanionEquippedArmorArmLeftItem == akBaseObject)
					DressData.CompanionEquippedArmorArmLeftItem = None
				endIf
			elseIf (DTSleep_ArmorArmRightList != None && DTSleep_ArmorArmRightList.HasForm(akBaseObject))
				if (DressData.CompanionEquippedArmorArmRightItem)
					DressData.CompanionEquippedArmorArmRightItem = None
				endIf
			elseIf (DTSleep_ArmorLegLeftList != None && DTSleep_ArmorLegLeftList.HasForm(akBaseObject))
				if (DressData.CompanionEquippedArmorLegLeftItem == akBaseObject)
					DressData.CompanionEquippedArmorLegLeftItem = None
				endIf
			elseIf (DTSleep_ArmorLegRightList != None && DTSleep_ArmorLegRightList.HasForm(akBaseObject))
				if (DressData.CompanionEquippedArmorLegRightItem == akBaseObject)
					DressData.CompanionEquippedArmorLegRightItem = None
				endIf
				
			elseIf (ValidArmorToCheck(akBaseObject as Armor, akBaseObject))
				RemoveCompanionArmorItem(akBaseObject as Armor)
			endIf
		endIf
	endIf
	
	processingCompUnequip = false
EndEvent


; *************************** Functions ***************
;

Function BeginStorePlayerEquipment()
	StoringPlayerEquipment = true
	EMPlayerEquippedArmorFormArray = new Form[0]
endFunction

Function BeginStoreCompanionEquipment(Actor aCompanion, Actor secondCompanion = None)
	;Debug.Trace("[DTSleep_EquipMon] BeginStoreCompanionEquipment: " + aCompanion + " and " + secondCompanion)
	
	MonitorCompanion(aCompanion, secondCompanion)
	
	StoringCompanionEquipment = true
	EMCompanionEquippedArmorFormArray = new Form[0]
	EMCompanionSecEquippedArmorFormArray = new Form[0]
endFunction

Function ClearDressDataBackpacks(Armor tItem)
	if (tItem != None)
		if (tItem == DressData.PlayerEquippedBackpackItem)
			DressData.PlayerEquippedBackpackItem = None
		endIf
		if (tItem == DressData.PlayerLastEquippedBackpackItem)
			DressData.PlayerLastEquippedBackpackItem = None
		endIf
		if (tItem == DressData.CompanionEquippedBackpackItem)
			DressData.CompanionEquippedBackpackItem = None
		endIf
		if (tItem == DressData.CompanionLastEquippedBackpackItem)
			DressData.CompanionLastEquippedBackpackItem = None
		endIf
	endIf
endFunction

Function ClearDressDataIntimateApparel(Armor tItem)
	if (tItem != None)
		if (tItem == DressData.PlayerEquippedIntimateAttireItem)
			DressData.PlayerEquippedIntimateAttireItem = None
		endIf
		if (tItem == DressData.PlayerLastEquippedIntimateAttireItem)
			DressData.PlayerLastEquippedIntimateAttireItem = None
		endIf
		if (tItem == DressData.CompanionEquippedIntimateAttireItem)
			DressData.CompanionEquippedIntimateAttireItem = None
		endIf
		if (tItem == DressData.CompanionLastEquippedIntimateAttireItem)
			DressData.CompanionLastEquippedIntimateAttireItem = None
		endIf
	endIf
endFunction

; v2.80
Function ClearDressDataFootwear(Armor tItem)					
	if (tItem != None)
		if (tItem == DressData.PlayerEquippedShoeItem)
			DressData.PlayerEquippedShoeItem = None
		endIf
		if (tItem == DressData.PlayerLastEquippedShoeItem)
			DressData.PlayerLastEquippedShoeItem = None
		endIf
		if (tItem == DressData.CompanionEquippedShoeItem)
			DressData.CompanionEquippedShoeItem = None
		endIf
		if (tItem == DressData.CompanionLastEquippedShoeItem)
			DressData.CompanionLastEquippedShoeItem = None
		endIf
	endIf
endFunction

Function ClearDressDataJackets(Armor item)
	if (item != None)
		if (item == DressData.PlayerEquippedJacketItem)
			DressData.PlayerEquippedJacketItem = None
		endIf
		if (item == DressData.PlayerEquippedJacketSecondItem)
			DressData.PlayerEquippedJacketSecondItem = None
		endIf
		if (item == DressData.PlayerLastEquippedJacketItem)
			DressData.PlayerLastEquippedJacketItem = None
		endIf
		if (item == DressData.CompanionEquippedJacketItem)
			DressData.CompanionEquippedJacketItem = None
		endIf
		if (item == DressData.CompanionLastEquippedJacketItem)
			DressData.CompanionLastEquippedJacketItem = None
		endIf
		
	endIf
endFunction

Function ClearDressDataMasks(Armor item)
	if (item != None)
		if (item == DressData.PlayerEquippedMask)
			DressData.PlayerEquippedMask = None
		endIf
		if (item == DressData.PlayerLastEquippedMask)
			DressData.PlayerLastEquippedMask = None
		endIf
		if (item == DressData.CompanionEquippedMask)
			DressData.CompanionEquippedMask = None
		endIf
	endIf
endFunction

Function ClearDressDataStrapOn(Armor item)
	if (item != None)
		if (item == DressData.PlayerEquippedStrapOnItem)
			DressData.PlayerEquippedStrapOnItem = None
		endIf
		if (item == DressData.PlayerLastEquippedStrapOnItem)
			DressData.PlayerLastEquippedStrapOnItem = None
		endIf
		if (item == DressData.CompanionEquippedStrapOnItem)
			DressData.CompanionEquippedStrapOnItem = None
		endIf
		if (item == DressData.CompanionLastEquippedStrapOnItem)
			DressData.CompanionLastEquippedStrapOnItem = None
		endIf
	endIf
endFunction

bool Function IsOnBackpacksLists(Form item)
	if (DTSleep_ArmorBackPacksList.HasForm(item) || DTSleep_ArmorCarryPouchList.HasForm(item))
		return true
	elseIf (DTSleep_ArmorBackPacksnoGOList.HasForm(item))
		return true
	endIf
	
	return false
endFunction

bool Function IsOnStandardArmorLists(Form item)

	if (IsOnBackpacksLists(item))
		return false
	elseIf (DTSleep_ArmorChokerList.HasForm(item) || DTSleep_ArmorNecklaceSlot50List.HasForm(item))
		return true
	elseIf (DTSleep_ArmorMaskList.HasForm(item))
		return true
	elseIf (DTSleep_ArmorJacketsClothingList.HasForm(item))
		return true
	elseIf (DTSleep_ArmorShoeList.HasForm(item))			; v2.80
		return true
	elseIf (DTSleep_ArmorStockingsList.HasForm(item))
		return true 
	elseIf (DTSleep_StrapOnList.HasForm(item))
		return true
	endIf
	
	return false
endFunction

Form[] Function EndStoreCompanionEquipment(Actor aCompanion)
	if (aCompanion != None && aCompanion == CompanionSecondRegistered)
		UnRegisterForRemoteEvent(CompanionSecondRegistered, "OnItemUnequipped")
		UnRegisterForRemoteEvent(CompanionSecondRegistered, "OnItemEquipped")
		CompanionSecondRegistered = None
		
		return EMCompanionSecEquippedArmorFormArray
	endIf
	
	if (aCompanion != None && aCompanion == CompanionRegistered)
		StoringCompanionEquipment = false
	
		return EMCompanionEquippedArmorFormArray
	endIf
	
	return new Form[0]
endFunction

Form[] Function EndStorePlayerEquipment()
	StoringPlayerEquipment = false
	return EMPlayerEquippedArmorFormArray
endFunction

float Function GetGameTimeHoursDifference(float time1, float time2) global
	float result = 0.0
	if (time2 == time1)
		return 0.0
	elseIf (time2 > time1)
		result = time2 - time1
	else
		result = time1 - time2
	endIf
	result *= 24.0
	return result
endFunction

; v1.65 - what player is currently wearing 
; - copy of array
Form[] Function GetMyPlayerEquipment()
	int i = 0
	while (processingUnequip && i < 25)
		Utility.WaitMenuMode(0.05)
		i += 1
	endWhile

	if (DTSleep_EquipMonInit.GetValue() >= 5.0 && MyPlayerEquippedArray != None)
		Form[] result = new Form[MyPlayerEquippedArray.Length]
		int index = 0
		while (index < MyPlayerEquippedArray.Length)
			if (MyPlayerEquippedArray[index] != None)
				result[index] = MyPlayerEquippedArray[index]
			else
				Debug.Trace("[DTSleep EquipMon] MyPlayerEquippedArray has None item at " + index)
			endIf
			index += 1
		endWhile
		
		return result
	endIf
	return new Form[0]
endFunction


Function MonitorCompanion(Actor aCompanion, Actor secondCompanion = None)
	if (CompanionRegistered != None && CompanionRegistered != aCompanion)
		UnregisterForRemoteEvent(CompanionRegistered, "OnItemUnequipped")
		UnregisterForRemoteEvent(CompanionRegistered, "OnItemEquipped")
		CompanionRegistered = None
		CompanionExtraClothingCount = 0
		CompanionExtraPartsCount = 0
	endIf
	if (CompanionSecondRegistered != None && secondCompanion != CompanionSecondRegistered)
		UnregisterForRemoteEvent(CompanionSecondRegistered, "OnItemUnequipped")
		UnregisterForRemoteEvent(CompanionSecondRegistered, "OnItemEquipped")
		CompanionSecondRegistered = None
	endIf
	if (aCompanion != None)
		CompanionRegistered = aCompanion
		
		;Debug.Trace("[DTSleep_EquipMon] main companion register " + aCompanion)
		RegisterForRemoteEvent(aCompanion, "OnItemUnequipped")
		RegisterForRemoteEvent(aCompanion, "OnItemEquipped")
	endIf
	if (secondCompanion != None)
		CompanionSecondRegistered = secondCompanion
		;Debug.Trace("[DTSleep_EquipMon] second companion register " + secondCompanion)
		RegisterForRemoteEvent(secondCompanion, "OnItemUnequipped")
		RegisterForRemoteEvent(secondCompanion, "OnItemEquipped")
	endIf
endFunction


; --------- Process custom  add/remove ------

; add or remove backpack - true if added
bool Function ProcessBackpackItem(Form item)
	float captureTime = DTSleep_CaptureBackpackEnable.GetValue()
	float curTime = Utility.GetCurrentGameTime()
	float minDiff = GetGameTimeHoursDifference(curTime, captureTime) * 60.0
	int initialMainCount = DTSleep_ArmorBackPacksList.GetSize()
	int initialNoGoCount = DTSleep_ArmorBackPacksnoGOList.GetSize()
	
	if (minDiff > 20.0)
		return false
	endIf
	
	if (DTSleep_ArmorPipBoyList.HasForm(item))
		return false
	endIf
	
	if (DTSleep_ArmorCarryPouchList.HasForm(item))
		; claim it was added
		DTSleep_BackpackAddMsg.Show()
		
		return false
	endIf
	
	if (initialMainCount > 0 && DTSleep_ArmorBackPacksList.HasForm(item))
		DTSleep_ArmorBackPacksList.RemoveAddedForm(item)
		
		if (DTSleep_ArmorBackPacksList.GetSize() < initialMainCount)
		
			; clear DressData
			Armor tItem = item as Armor
			ClearDressDataBackpacks(tItem)
			
			DTSleep_BackpackRemMsg.Show()
		endIf
	elseIf (initialNoGoCount > 0 && DTSleep_ArmorBackPacksnoGOList.HasForm(item))
		DTSleep_ArmorBackPacksnoGOList.RemoveAddedForm(item)
		
		if (DTSleep_ArmorBackPacksnoGOList.GetSize() < initialNoGoCount)
			
			; clear DressData
			Armor tItem = item as Armor
			ClearDressDataBackpacks(tItem)
			
			DTSleep_BackpackRemMsg.Show()
		endIf
	else
		DTSleep_ArmorBackPacksList.AddForm(item)
		if (DTSleep_ArmorBackPacksList.GetSize() > initialMainCount)
			
			DTSleep_BackpackAddMsg.Show()
			
			return true
		else
			DTSleep_FailedToAddCustomArmorMsg.Show()
		endIf
	endIf
	
	return false
endFunction

bool Function ProcessExtraPartsAdd(Form item)

	if (Utility.IsInMenuMode())
		; only allow if player is in menu
		
		float captureTime = DTSleep_CaptureExtraPartsEnable.GetValue()
		float curTime = Utility.GetCurrentGameTime()
		float minDiff = GetGameTimeHoursDifference(curTime, captureTime) * 60.0
		
		if (minDiff > 20.0)
			
			return false
		endIf
		
		if (IsOnStandardArmorLists(item))
			return false
		endIf
			
		if (!DTSleep_ArmorJacketsClothingList.HasForm(item) && !DTSleep_ArmorPipBoyList.HasForm(item))
		
			DTSleep_ArmorExtraPartsList.AddForm(item)

			DTSleep_ExtraPartsAddMsg.Show()
			
			if (DTSleep_ExtraArmorsEnabled.GetValue() <= 0.0)
				DTSleep_ExtraArmorsEnabled.SetValueInt(2)
			endIf
			
			return true
		else
			DTSleep_FailedToAddCustomArmorMsg.Show()
		endIf
	endIf
	
	return false
endFunction

bool Function ProcessExtraPartsRemove(Form item)

	if (Utility.IsInMenuMode())
		; only allow if player is in menu
		
		float captureTime = DTSleep_CaptureExtraPartsEnable.GetValue()
		float curTime = Utility.GetCurrentGameTime()
		float minDiff = GetGameTimeHoursDifference(curTime, captureTime) * 60.0
		
		if (minDiff > 20.0)
			return false
		endIf
		
		if (!DTSleep_ArmorExtraClothingList.HasForm(item) && DTSleep_ArmorExtraPartsList.HasForm(item))
		
			int initialCount = DTSleep_ArmorExtraPartsList.GetSize()
			
			DTSleep_ArmorExtraPartsList.RemoveAddedForm(item)
			
			if (initialCount > DTSleep_ArmorExtraPartsList.GetSize())
			
				DTSleep_ExtraPartsRemMsg.Show()
				
				return true
			else
				DTSleep_FailedToAddCustomArmorMsg.Show()
			endIf
		endIf
	endIf
	
	return false
endFunction

; add or remove intimate apparel - true if added
bool Function ProcessIntimateItem(Form item, int gender = -1)
	float captureTime = DTSleep_CaptureIntimateApparelEnable.GetValue()
	float curTime = Utility.GetCurrentGameTime()
	float minDiff = GetGameTimeHoursDifference(curTime, captureTime) * 60.0
	FormList sleepwearList = DTSleep_IntimateAttireList
	int initialCount = DTSleep_IntimateAttireList.GetSize()
	
	if (minDiff > 20.0)
		return false
	elseIf (item.HasKeyword(DTSleep_IntimateOutfitFemKY))
		return false
	endIf
	
	if (IsOnStandardArmorLists(item))
		return false
	endIf
	
	if (DTSleep_ArmorPipBoyList.HasForm(item))
		return false
	endIf
	
	if (gender >= 0 && gender <= 1)
		if (gender == 0)
			initialCount = DTSleep_IntimateAttireMaleList.GetSize()
			sleepwearList = DTSleep_IntimateAttireMaleList
		endIf
	
		if (initialCount > 0 && sleepwearList.HasForm(item))
			sleepwearList.RemoveAddedForm(item)
			
			if (sleepwearList.GetSize() < initialCount)
			
				; clear DressData
				ClearDressDataIntimateApparel(item as Armor)
				
				DTSleep_InitmateAttireRemMsg.Show()
			endIf
		else
			if (gender == 1)
				sleepwearList.AddForm(item)
			elseIf (!DTSleep_IntimateAttireFemaleOnlyList.HasForm(item))
				sleepwearList.AddForm(item)
			endIf
			
			if (sleepwearList.GetSize() > initialCount)
				
				DTSleep_IntimateAttireAddMsg.Show()
				
				return true
			else
				DTSleep_FailedToAddCustomArmorMsg.Show()
			endIf
		endIf
	endIf
	
	return false
endFunction

bool Function ProcessJacketItem(Form item)
	float captureTime = DTSleep_CaptureJacketEnable.GetValue()
	float curTime = Utility.GetCurrentGameTime()
	float minDiff = GetGameTimeHoursDifference(curTime, captureTime) * 60.0
	int initialCount = DTSleep_ArmorJacketsClothingList.GetSize()
	
	if (minDiff > 20.0)
		return false 
	endIf
	
	if (IsOnBackpacksLists(item))
		return false
	endIf
	
	if (DTSleep_ArmorPipBoyList.HasForm(item))
		return false
	endIf
	
	if (initialCount > 0 && DTSleep_ArmorJacketsClothingList.HasForm(item))
		DTSleep_ArmorJacketsClothingList.RemoveAddedForm(item)
		
		if (DTSleep_ArmorJacketsClothingList.GetSize() < initialCount)
			; clear DressData
			ClearDressDataJackets(item as Armor)
			
			DTSleep_JacketRemMsg.Show()
		endIf
	else
		DTSleep_ArmorJacketsClothingList.AddForm(item)
		
		if (DTSleep_ArmorJacketsClothingList.GetSize() > initialCount)
			
			DTSleep_JacketAddMsg.Show()
			
			return true
		else
			DTSleep_FailedToAddCustomArmorMsg.Show()
		endIf
	endIf
	
	return false
endFunction

bool Function ProcessMaskItem(Form item)
	float captureTime = DTSleep_CaptureMaskEnable.GetValue()
	float curTime = Utility.GetCurrentGameTime()
	float minDiff = GetGameTimeHoursDifference(curTime, captureTime) * 60.0
	int initialCount = DTSleep_ArmorMaskList.GetSize()
	
	if (minDiff > 20.0)
		return false 
	endIf
	
	if (IsOnBackpacksLists(item))
		return false
	endIf
	
	if (DTSleep_ArmorPipBoyList.HasForm(item))
		return false
	endIf
	
	if (initialCount > 0 && DTSleep_ArmorMaskList.HasForm(item))
		DTSleep_ArmorMaskList.RemoveAddedForm(item)
		
		if (DTSleep_ArmorMaskList.GetSize() < initialCount)
			ClearDressDataMasks(item as Armor)
			
			DTSleep_MaskRemMsg.Show()
		endIf
	else
		DTSleep_ArmorMaskList.AddForm(item)
		
		if (DTSleep_ArmorMaskList.GetSize() > initialCount)
			
			DTSleep_MaskAddMsg.Show()
			
			return true
		else
			DTSleep_FailedToAddCustomArmorMsg.Show()
		endIf
	endIf
		
	return false
endFunction

; add or remove sleepwear - true if added
bool Function ProcessSleepwearItem(Form item, int gender = -1)
	float captureTime = DTSleep_CaptureSleepwearEnable.GetValue()
	float curTime = Utility.GetCurrentGameTime()
	float minDiff = GetGameTimeHoursDifference(curTime, captureTime) * 60.0
	int initialCount = DTSleep_SleepAttireFemale.GetSize()
	FormList sleepwearList = DTSleep_SleepAttireFemale
	
	if (item == None || minDiff > 20.0)
		return false
	elseIf (item.HasKeyword(DTSleep_SleepwearKY))
		return false
	endIf
	
	if (IsOnStandardArmorLists(item))
		return false
	endIf
	
	if (DTSleep_ArmorPipBoyList.HasForm(item))
		return false
	endIf
	
	if (gender >= 0 && gender <= 1)
		if (gender == 0)
			initialCount = DTSleep_SleepAttireMale.GetSize()
			sleepwearList = DTSleep_SleepAttireMale
		endIf
		
		if (initialCount > 1 && sleepwearList.HasForm(item))
			sleepwearList.RemoveAddedForm(item)
			if (sleepwearList.GetSize() < initialCount)
			
				; clear DressData sleep gear
				Armor tItem = item as Armor
				if (tItem != None)
					if (tItem == DressData.PlayerEquippedSleepwearItem)
						DressData.PlayerEquippedSleepwearItem = None
					endIf
					if (tItem == DressData.PlayerLastEquippedSleepwearItem)
						DressData.PlayerLastEquippedSleepwearItem = None
					endIf
					if (tItem == DressData.CompanionEquippedSleepwearItem)
						DressData.CompanionEquippedSleepwearItem = None
					endIf
					if (tItem == DressData.CompanionLastEquippedSleepwearItem)
						DressData.CompanionLastEquippedSleepwearItem = None
					endIf
				endIf
				
				DTSleep_SleepwearRemMsg.Show()
			endIf
		else
			sleepwearList.AddForm(item)
			if (sleepwearList.GetSize() > initialCount)
				DTSleep_SleepwearAddMsg.Show()
				return true
			else
				DTSleep_FailedToAddCustomArmorMsg.Show()
			endIf
		endIf
	endIf
	
	return false
endFunction

bool Function ProcessStrapOnItem(Form item)

	float captureTime = DTSleep_CaptureStrapOnEnable.GetValue()
	float curTime = Utility.GetCurrentGameTime()
	float minDiff = GetGameTimeHoursDifference(curTime, captureTime) * 60.0
	int initialCount = DTSleep_StrapOnList.GetSize()

	
	;Debug.Trace("EquipMon -- process Strap-On: " + item + " minutes: " + minDiff)
	
	if (item != None && minDiff < 24.0)
	
		if (DTSleep_ArmorPipBoyList.HasForm(item))
			return false
		endIf
		
		if (initialCount > 0 && DTSleep_StrapOnList.HasForm(item))
			
			; clear DressData
			DTSleep_StrapOnList.RemoveAddedForm(item)
			ClearDressDataStrapOn(item as Armor)
			
			DTSleep_StrapOnRemMsg.Show()
		else
			DTSleep_StrapOnList.AddForm(item)
			
			if (initialCount < DTSleep_StrapOnList.GetSize())
				
				DTSleep_StrapOnAddMsg.Show()
				
				return true
			else
				DTSleep_FailedToAddCustomArmorMsg.Show()
			endIf
		endIf
	endIf

	return false
endFunction

; v2.80
bool Function ProcessShoeItem(Form item)

	float captureTime = DTSleep_CaptureShoeEnable.GetValue()
	float curTime = Utility.GetCurrentGameTime()
	float minDiff = GetGameTimeHoursDifference(curTime, captureTime) * 60.0
	int initialCount = DTSleep_ArmorShoeList.GetSize()

	
	;Debug.Trace("EquipMon -- process Strap-On: " + item + " minutes: " + minDiff)
	
	if (item != None && minDiff < 24.0)
	
		if (DTSleep_ArmorPipBoyList.HasForm(item))
			return false
		endIf
		
		if (initialCount > 0 && DTSleep_ArmorShoeList.HasForm(item))
			
			; clear DressData
			DTSleep_ArmorShoeList.RemoveAddedForm(item)
			ClearDressDataFootwear(item as Armor)
			
			DTSleep_ShoeRemMsg.Show()
		else
			DTSleep_ArmorShoeList.AddForm(item)
			
			if (initialCount < DTSleep_ArmorShoeList.GetSize())
				
				DTSleep_ShoeAddMsg.Show()
				
				return true
			else
				DTSleep_FailedToAddCustomArmorMsg.Show()
			endIf
		endIf
	endIf

	return false
endFunction

; v2.80
bool Function ProcessStockingsItem(Form item)

	float captureTime = DTSleep_CaptureStockingEnable.GetValue()
	float curTime = Utility.GetCurrentGameTime()
	float minDiff = GetGameTimeHoursDifference(curTime, captureTime) * 60.0
	int initialCount = DTSleep_ArmorStockingsList.GetSize()

	
	;Debug.Trace("EquipMon -- process Strap-On: " + item + " minutes: " + minDiff)
	
	if (item != None && minDiff < 24.0)
	
		if (DTSleep_ArmorPipBoyList.HasForm(item))
			return false
		endIf
		
		if (initialCount > 0 && DTSleep_ArmorStockingsList.HasForm(item))
			
			; clear DressData
			DTSleep_ArmorStockingsList.RemoveAddedForm(item)
			ClearDressDataFootwear(item as Armor)
			
			DTSleep_StockingsRemMsg.Show()
		else
			DTSleep_ArmorStockingsList.AddForm(item)
			
			if (initialCount < DTSleep_ArmorStockingsList.GetSize())
				
				DTSleep_StockingsAddMsg.Show()
				
				return true
			else
				DTSleep_FailedToAddCustomArmorMsg.Show()
			endIf
		endIf
	endIf

	return false
endFunction

Function CheckSwapClearSecondJacket()
	if (DTSleep_SettingMultiJacketOn.GetValueInt() < 2)
		if (DressData.PlayerLastEquippedJacketItem != None)
			Actor playerRef = Game.GetPlayer()
			if (playerRef.IsEquipped(DressData.PlayerLastEquippedJacketItem))
				DressData.PlayerEquippedJacketSecondItem = DressData.PlayerLastEquippedJacketItem
			else
				DressData.PlayerEquippedJacketSecondItem = None
			endIf
		else
			DressData.PlayerEquippedJacketSecondItem = None
		endIf
	else
		DressData.PlayerEquippedJacketSecondItem = None
	endIf
endFunction

Function CheckSwapJacketsForItem(Armor toItem)
	int jacketPref = DTSleep_SettingMultiJacketOn.GetValueInt()
	if (jacketPref == 1)
		; allow 2 jackets
		DressData.PlayerEquippedJacketSecondItem = toItem
	elseIf (jacketPref >= 2)
		; ignore - do old way
		DressData.PlayerEquippedJacketItem = toItem
	else
		; swap
		DressData.PlayerEquippedJacketSecondItem = DressData.PlayerEquippedJacketItem
		DressData.PlayerEquippedJacketItem = toItem
	endIf
endFunction

Function CheckSwapJacketsForCompanionItem(ARmor toItem)
	int jacketPref = DTSleep_SettingMultiJacketOn.GetValueInt()
	if (jacketPref < 2)
		; allow 2 jackets
		DressData.CompanionEquippedJacketSecondItem = toItem
	else
		; ignore - do old way
		DressData.CompanionEquippedJacketItem = toItem
	endIf

endFunction

Function RemoveSecondJacket()

	if (DressData.PlayerEquippedJacketSecondItem != None)
		bool lastSameAsSecond = false
		bool lastSameAsMain = false
		if (DressData.PlayerLastEquippedJacketItem == DressData.PlayerEquippedJacketSecondItem)
			lastSameAsSecond = true
		endIf
		if (DressData.PlayerLastEquippedJacketItem == DressData.PlayerEquippedJacketItem)
			lastSameAsMain = true
		endIf
		Actor playerRef = Game.GetPlayer()
		if (playerRef.IsEquipped(DressData.PlayerEquippedJacketSecondItem))
			
			playerRef.UnequipItem(DressData.PlayerEquippedJacketSecondItem)
		endIf
		if (!lastSameAsSecond && !lastSameAsMain && DressData.PlayerLastEquippedJacketItem != None)
			if (playerRef.GetItemCount(DressData.PlayerLastEquippedJacketItem) > 0 && playerRef.IsEquipped(DressData.PlayerLastEquippedJacketItem))
				playerRef.UnequipItem(DressData.PlayerLastEquippedJacketItem)
			endIf
		endIf
	endIf
endFunction

; -------------------------------------

; player
Function RemoveArmorItem(Armor item)
	int initLevel = DTSleep_EquipMonInit.GetValueInt()
	if (initLevel >= 2)
		SetDressDataMatchArmorToArmor(item, None)
	elseIf (initLevel > 0)
		SetDressDataBasicMatchFormToArmor(item, None)
	elseIf (!DressData.SearchListsDisabled)
		; avoid by setting init level
		SetDressDataMatchingFormToArmor(item as Form, None)
	endIf
endFunction

; companion
Function RemoveCompanionArmorItem(Armor item)
	int initLevel = DTSleep_EquipMonInit.GetValueInt()
	if (initLevel >= 2)
		SetCompanionDataMatchArmorToArmor(item, None)
	elseIf (initLevel > 0)
		SetCompanionDressDataBasicMatchFormToArmor(item, None)
	elseIf (!DressData.SearchListsDisabled)
		; avoid by setting init level
		SetCompanionDressDataMatchingFormToArmor(item as Form, None)
	endIf
endFunction

; player
Function SetArmorItem(Armor item)
	int initLevel = DTSleep_EquipMonInit.GetValueInt()

	if (initLevel >= 2.0)
		SetDressDataMatchArmorToArmor(item, item)
	elseIf (initLevel > 0)
		SetDressDataBasicMatchFormToArmor(item, item)
	elseIf (!DressData.SearchListsDisabled)
		; avoid by setting init level
		SetDressDataMatchingFormToArmor(item as Form, item)
	endIf
endFunction

; companion
Function SetCompanionArmorItem(Armor item)
	int initLevel = DTSleep_EquipMonInit.GetValueInt()

	if (initLevel >= 2.0)
		SetCompanionDataMatchArmorToArmor(item, item)
	elseIf (initLevel > 0)
		SetCompanionDressDataBasicMatchFormToArmor(item, item)
	elseIf (!DressData.SearchListsDisabled)
		; avoid by setting init level
		SetCompanionDressDataMatchingFormToArmor(item as Form, item)
	endIf
endFunction

Function SetCompanionDataMatchArmorToArmor(Armor matchItem, Armor toItem)
	if (matchitem)
	
		; priority named before slots except sleepwear which marks in both
		;Debug.Trace("[DTSleep_EquipMon] SetComp MatchArmor " + matchItem + " set to " + toItem)
		
		if (DressData.CompanionEquippedBackpackItem == matchItem)
			DressData.CompanionLastEquippedBackpackItem = DressData.CompanionEquippedBackpackItem
			DressData.CompanionEquippedBackpackItem = toItem
			if (toItem && DTSleep_ArmorBackPacksnoGOList && DTSleep_ArmorBackPacksnoGOList.HasForm(toItem as Form))
				DressData.CompanionBackPackNoGOModel = true
			else
				DressData.CompanionBackPackNoGOModel = false
			endIf
		elseIf (DressData.CompanionLastEquippedBackpackItem == matchItem)
			if (toItem != None)
				; may use different slots
				DressData.CompanionEquippedBackpackItem = toItem
			endIf
			if (toItem && DTSleep_ArmorBackPacksnoGOList && DTSleep_ArmorBackPacksnoGOList.HasForm(toItem as Form))
				DressData.CompanionBackPackNoGOModel = true
			else
				DressData.CompanionBackPackNoGOModel = false
			endIf
		elseIf (DressData.CompanionEquippedCarryPouchItem == matchItem)
			DressData.CompanionEquippedCarryPouchItem = toItem
		elseIf (DTSConditionals.AWKCRPackKW != None && matchItem.HasKeyword(DTSConditionals.AWKCRPackKW))
			DressData.CompanionEquippedBackpackItem = toItem
			DressData.CompanionBackPackNoGOModel = false
		elseIf (DTSConditionals.AWKCRBandolKW != None && matchItem.HasKeyword(DTSConditionals.AWKCRBandolKW))
			DressData.CompanionEquippedCarryPouchItem = toItem
			
		; do intimate items first since could be anything
		
		elseIf (DressData.CompanionEquippedIntimateAttireItem == matchItem)
			DressData.CompanionLastEquippedIntimateAttireItem = DressData.CompanionEquippedIntimateAttireItem
			DressData.CompanionEquippedIntimateAttireItem = toItem
			if (DressData.CompanionGender == 1 && DressData.CompanionLastEquippedIntimateAttireItem != None)
				if (DressData.CompanionEquippedIntimateAttireItem.HasKeyword(DTSleep_SleepWearCamiKY))
					; v2.30 allow both
					DressData.CompanionLastEquippedSleepwearItem =  DressData.CompanionLastEquippedIntimateAttireItem
				elseIf (DTSleep_SleepAttireFemale.HasForm(DressData.CompanionLastEquippedIntimateAttireItem))
					; v2.30 allow both
					DressData.CompanionLastEquippedSleepwearItem =  DressData.CompanionLastEquippedIntimateAttireItem
				endIf
			endIf
		elseIf (DressData.CompanionLastEquippedIntimateAttireItem == matchItem)
			if (toItem != None)
				DressData.CompanionEquippedIntimateAttireItem = toItem
			endIf
		elseIf (DressData.CompanionGender == 0 && DTSleep_IntimateAttireMaleList.HasForm(matchItem))
			DressData.CompanionEquippedIntimateAttireItem = toItem
		elseIf (DressData.CompanionGender == 1 && matchItem.HasKeyword(DTSleep_IntimateOutfitFemKY))
			DressData.CompanionEquippedIntimateAttireItem = toItem
		elseIf (DressData.CompanionGender == 1 && DTSleep_IntimateAttireList.HasForm(matchItem))
			DressData.CompanionEquippedIntimateAttireItem = toItem

		; mask
		
		elseIf (DressData.CompanionEquippedMask == matchItem)
			DressData.CompanionEquippedMask = toItem
		elseIf (DTSleep_ArmorMaskList && DTSleep_ArmorMaskList.HasForm(matchItem))
			
			DressData.CompanionEquippedMask = toItem
			
		; glasses
		
		elseIf (DressData.CompanionEquippedGlassesItem == matchItem)
			DressData.CompanionLastEquippedGlassesItem = DressData.CompanionEquippedGlassesItem
			DressData.CompanionEquippedGlassesItem = toItem
		elseIf (DressData.CompanionLastEquippedGlassesItem == matchItem)
			DressData.CompanionEquippedGlassesItem = toItem
		elseIf (DTSleep_ArmorGlassesList.HasForm(matchItem))
			
			DressData.CompanionEquippedGlassesItem = toItem
			
		; jacket
			
		elseIf (DressData.CompanionEquippedJacketItem == matchItem)
			if (DressData.CompanionEquippedJacketSecondItem == matchitem)
				DressData.CompanionEquippedJacketSecondItem = None
			endIf
			DressData.CompanionLastEquippedJacketItem = DressData.CompanionEquippedJacketItem
			DressData.CompanionEquippedJacketItem = toItem
		elseIf (DressData.CompanionLastEquippedJacketItem == matchItem)
			if (toItem != None)
				; may use different slots - case overlap equip
				if (DressData.CompanionEquippedJacketItem != None && DressData.CompanionEquippedJacketItem != toItem)
					; v2.24 check preference
					CheckSwapJacketsForCompanionItem(toItem)
				else
					; old way
					DressData.CompanionEquippedJacketItem = toItem
				endIf
			endIf
		elseIf (DressData.CompanionEquippedJacketSecondItem == matchitem)
			if (toItem != None && DressData.CompanionEquippedJacketItem != None && toItem == DressData.CompanionEquippedJacketItem)
				; matched, but already have on main so clear second
				DressData.CompanionEquippedJacketSecondItem = None
			elseIf (toItem == None)
				DressData.CompanionEquippedJacketSecondItem = None
			endIf
		elseIf (DTSConditionals.AWKCRCloakKW != None && matchItem.HasKeyword(DTSConditionals.AWKCRCloakKW))
			if (toItem != None && DressData.CompanionEquippedJacketItem != None && toItem != DressData.CompanionEquippedJacketItem)
				CheckSwapJacketsForCompanionItem(toItem)
			else
				DressData.CompanionEquippedJacketItem = toItem
			endIf
		elseIf (DTSConditionals.AWKCRJacketKW != None && matchItem.HasKeyword(DTSConditionals.AWKCRJacketKW))
			if (toItem != None && DressData.CompanionEquippedJacketItem != None && toItem != DressData.CompanionEquippedJacketItem)
				CheckSwapJacketsForCompanionItem(toItem)
			else
				DressData.CompanionEquippedJacketItem = toItem
			endIf
			
		elseIf (DressData.CompanionEquippedStrapOnItem == matchItem)
			DressData.CompanionLastEquippedStrapOnItem = DressData.CompanionEquippedStrapOnItem
			DressData.CompanionEquippedStrapOnItem = toItem
		elseIf (DressData.CompanionLastEquippedStrapOnItem == matchItem)
			if (toItem != None)
				DressData.CompanionEquippedStrapOnItem = toItem
			endIf
	; slots
		elseIf (DressData.CompanionEquippedSlot41Item == matchItem)
			DressData.CompanionLastEquippedSlot41Item = DressData.CompanionEquippedSlot41Item
			DressData.CompanionEquippedSlot41Item = toItem
		elseIf (DressData.CompanionLastEquippedSlot41Item == matchItem)
			DressData.CompanionEquippedSlot41Item = toItem
		elseIf (DressData.CompanionEquippedSlot55Item == matchItem)
			DressData.CompanionLastEquippedSlot55Item = DressData.CompanionEquippedSlot55Item
			DressData.CompanionEquippedSlot55Item = toItem
		elseIf (DressData.CompanionLastEquippedSlot55Item == matchItem)
			DressData.CompanionEquippedSlot55Item = toItem
		elseIf (DressData.CompanionEquippedSlot56Item == matchItem)							; v2.71
			; no last item
			DressData.CompanionEquippedSlot56Item = toItem
			DressData.CompanionEquippedSlot56IsJewelry = false
			if (toItem != None && DTSleep_ArmorJewelry56List.HasForm(toItem as Form))
				DressData.CompanionEquippedSlot56IsJewelry = true
			endIf
		elseIf (DressData.CompanionEquippedSlot57Item == matchItem)								; v2.71
			; no last item
			DressData.CompanionEquippedSlot57Item = toItem
			DressData.CompanionEquippedSlot57IsJewelry = false
			if (toItem != None && DTSleep_ArmorJewelry57List.HasForm(toItem as Form))
				DressData.CompanionEquippedSlot56IsJewelry = true
			endIf
		elseIf (DressData.CompanionEquippedSlot58Item == matchItem)
			DressData.CompanionLastEquippedSlot58Item = DressData.CompanionEquippedSlot58Item
			DressData.CompanionEquippedSlot58Item = toItem
			; maybe a sleepwear or jewelry
			DressData.CompanionLastSlot58IsSleepwear = DressData.CompanionEquippedSlot58IsSleepwear
			if (toItem != None)
				if (DTSleep_SleepAttireFemale.HasForm(toItem))
					DressData.CompanionEquippedSlot58IsSleepwear = true
					DressData.CompanionEquippedSlot58IsJewelry = false
				elseIf ((DTSConditionals as DTSleep_Conditionals).IsAWKCRActive && (DTSConditionals as DTSleep_Conditionals).AWKCRPiercingKW != None && toItem.HasKeyword((DTSConditionals as DTSleep_Conditionals).AWKCRPiercingKW))
					DressData.CompanionEquippedSlot58IsJewelry = true
					DressData.CompanionEquippedSlot58IsSleepwear = false
				elseIf (DTSleep_ArmorJewelry58List.HasForm(toItem))
					DressData.CompanionEquippedSlot58IsJewelry = true
					DressData.CompanionEquippedSlot58IsSleepwear = false
				endIf
			else
				DressData.CompanionEquippedSlot58IsSleepwear = false
				DressData.CompanionEquippedSlot58IsJewelry = false
			endIf
		elseIf (DressData.CompanionLastEquippedSlot58Item == matchItem)
			DressData.CompanionEquippedSlot58Item = toItem
			; maybe a sleepwear
			if (toItem != None)
				if (DTSleep_SleepAttireFemale.HasForm(toItem))
					DressData.CompanionEquippedSlot58IsSleepwear = true
					DressData.CompanionEquippedSlot58IsJewelry = false
				elseIf ((DTSConditionals as DTSleep_Conditionals).IsAWKCRActive && (DTSConditionals as DTSleep_Conditionals).AWKCRPiercingKW != None && toItem.HasKeyword((DTSConditionals as DTSleep_Conditionals).AWKCRPiercingKW))
					DressData.CompanionEquippedSlot58IsJewelry = true
					DressData.CompanionEquippedSlot58IsSleepwear = false
				elseIf (DTSleep_ArmorJewelry58List.HasForm(toItem))
					DressData.CompanionEquippedSlot58IsJewelry = true
					DressData.CompanionEquippedSlot58IsSleepwear = false
				endIf
			else
				DressData.CompanionEquippedSlot58IsSleepwear = false
				DressData.CompanionEquippedSlot58IsJewelry = false
			endIf
		elseIf (DressData.CompanionEquippedSlotFXItem == matchItem)
			DressData.CompanionLastEquippedSlotFXItem = DressData.CompanionEquippedSlotFXItem
			DressData.CompanionEquippedSlotFXItem = toItem 
			; maybe a sleepwear
			DressData.CompanionLastSlotFXIsSleepwear = DressData.CompanionEquippedSlotFXIsSleepwear 
			if (toItem && DTSleep_SleepAttireFemale.HasForm(toItem))
				DressData.CompanionEquippedSlotFXIsSleepwear  = true
			else
				DressData.CompanionEquippedSlotFXIsSleepwear  = false
			endIf
		elseIf (DressData.CompanionLastEquippedSlotFXItem == matchItem)
			DressData.CompanionEquippedSlotFXItem = toItem
			; maybe sleepwear
			if (toItem && DTSleep_SleepAttireFemale.HasForm(toItem))
				DressData.CompanionEquippedSlotFXIsSleepwear = true
			else
				DressData.CompanionEquippedSlotFXIsSleepwear = false
			endIf
		elseIf (DressData.CompanionLastEquippedULegItem == matchItem)
			DressData.CompanionEquippedULegItem = toItem
			; stocking may also be ULeg								; v2.80
			if (DTSleep_ArmorStockingsList != None && DTSleep_ArmorStockingsList.HasForm(matchItem as Form))
				DressData.CompanionLastEquippedStockingsItem = DressData.CompanionEquippedStockingsItem
				DressData.CompanionEquippedStockingsItem = toItem
			endIf

		elseIf (DTSleep_ArmorExtraClothingList && DTSleep_ArmorExtraClothingList.HasForm(matchItem))
			if (toItem == None)
				CompanionExtraClothingCount -= 1
			else
				CompanionExtraClothingCount += 1
			endIf
			if (CompanionExtraClothingCount <= 0)
				CompanionExtraClothingCount = 0
				DressData.CompanionHasExtraClothingEquipped = false
			else
				DressData.CompanionHasExtraClothingEquipped = true
			endIf
		elseIf (DTSleep_ArmorExtraPartsList && DTSleep_ArmorExtraPartsList.HasForm(matchItem))
			if (toItem == None)
				CompanionExtraPartsCount -= 1
			else
				CompanionExtraPartsCount += 1
			endIf
			if (CompanionExtraPartsCount <= 0)
				CompanionExtraPartsCount = 0
				DressData.CompanionHasExtraPartsEquipped = false
			else
				DressData.CompanionHasExtraPartsEquipped = true
			endIf
			
	; sleepwear 
		elseIf (DressData.CompanionEquippedSleepwearItem == matchItem)
			DressData.CompanionLastEquippedSleepwearItem = DressData.CompanionEquippedSleepwearItem
			DressData.CompanionEquippedSleepwearItem = toItem 
		elseIf (DressData.CompanionLastEquippedSleepwearItem == matchItem)
			if (toItem != None)
				DressData.CompanionEquippedSleepwearItem = toItem
			endIf

		elseIf (DTSleep_EquipMonInit.GetValue() >= 2.0 && !DressData.SearchListsDisabled)
			
			SetCompanionDressDataMatchingFormToArmor(matchItem as Form, toItem)
		endIf
		
		; double-check jackets
		if (DressData.CompanionEquippedJacketSecondItem != None)
			if (DressData.CompanionEquippedJacketSecondItem == DressData.CompanionEquippedJacketItem)
				; same jacket - remove 2nd
				DressData.CompanionEquippedJacketSecondItem = None
			endIf
		endIf
		
	endIf
endFunction

; companion
; only necessary if have mods - init = 2
Function SetCompanionDressDataMatchingFormToArmor(Form matchForm, Armor toItem)
	if (matchForm)
	; priority named before slots except sleepwear which marks in both
		;Debug.Trace("[DTSleep_EquipMon] SetDressDataMatchForm: " + matchForm)
		
		if (DTSleep_ArmorBackPacksList && DTSleep_ArmorBackPacksList.HasForm(matchForm))
			DressData.CompanionLastEquippedBackpackItem = DressData.CompanionEquippedBackpackItem
			DressData.CompanionEquippedBackpackItem = toItem
			if (toItem && DTSleep_ArmorBackPacksnoGOList && DTSleep_ArmorBackPacksnoGOList.HasForm(toItem as Form))
				DressData.CompanionBackPackNoGOModel = true
			else
				DressData.CompanionBackPackNoGOModel = false
			endIf
		elseIf (DTSleep_ArmorBackPacksnoGOList && DTSleep_ArmorBackPacksnoGOList.HasForm(matchForm))
			DressData.CompanionLastEquippedBackpackItem = DressData.CompanionEquippedBackpackItem
			DressData.CompanionEquippedBackpackItem = toItem
			if (toItem && DTSleep_ArmorBackPacksnoGOList && DTSleep_ArmorBackPacksnoGOList.HasForm(toItem as Form))
				DressData.CompanionBackPackNoGOModel = true
			else
				DressData.CompanionBackPackNoGOModel = false
			endIf
		elseIf (DTSleep_ArmorCarryPouchList && DTSleep_ArmorCarryPouchList.HasForm(matchForm))
			DressData.CompanionEquippedCarryPouchItem = toItem
			
		; do intimate items first since could be anything
		
		elseIf (DressData.CompanionGender == 0 && DTSleep_IntimateAttireMaleList.HasForm(matchForm))
			DressData.CompanionEquippedIntimateAttireItem = toItem
			
		elseIf (DressData.CompanionGender == 1 && matchform.HasKeyword(DTSleep_IntimateOutfitFemKY))
			DressData.CompanionEquippedIntimateAttireItem = toItem
		elseIf (DressData.CompanionGender == 1 && DTSleep_IntimateAttireList.HasForm(matchForm))
			DressData.CompanionEquippedIntimateAttireItem = toItem

		elseIf (DTSleep_ArmorMaskList && DTSleep_ArmorMaskList.HasForm(matchForm))
			DressData.CompanionEquippedMask = toItem
			
		elseIf (DTSleep_ArmorGlassesList.HasForm(matchform))
			DressData.CompanionLastEquippedGlassesItem = DressData.CompanionEquippedGlassesItem
			DressData.CompanionEquippedGlassesItem = toItem
			
		elseIf (DTSleep_ArmorExtraClothingList && DTSleep_ArmorExtraClothingList.HasForm(matchForm))
			if (toItem == None)
				CompanionExtraClothingCount -= 1
			else
				CompanionExtraClothingCount += 1
			endIf
			if (CompanionExtraClothingCount <= 0)
				CompanionExtraClothingCount = 0
				DressData.CompanionHasExtraClothingEquipped = false
			else
				DressData.CompanionHasExtraClothingEquipped = true
			endIf
		elseIf (DTSleep_ArmorExtraPartsList && DTSleep_ArmorExtraPartsList.HasForm(matchForm))
			if (toItem == None)
				CompanionExtraPartsCount -= 1
			else
				CompanionExtraPartsCount += 1
			endIf
			if (CompanionExtraPartsCount <= 0)
				CompanionExtraPartsCount = 0
				DressData.CompanionHasExtraPartsEquipped = false
			else
				DressData.CompanionHasExtraPartsEquipped = true
			endIf
		elseIf (DTSleep_ArmorJacketsClothingList && DTSleep_ArmorJacketsClothingList.HasForm(matchForm))
			DressData.CompanionLastEquippedJacketItem = DressData.CompanionEquippedJacketItem
			DressData.CompanionEquippedJacketItem = toItem 
		elseIf (DTSleep_StrapOnList && DTSleep_StrapOnList.HasForm(matchForm))
			; check before slot55 to give priority
			DressData.CompanionLastEquippedStrapOnItem = DressData.CompanionEquippedStrapOnItem
			DressData.CompanionEquippedStrapOnItem = toItem 
		elseIf (DTSleep_ArmorShoeList != None && DTSleep_ArmorShoeList.HasForm(matchForm))
			; v2.80 check before slots below
			DressData.CompanionLastEquippedShoeItem = DressData.CompanionEquippedShoeItem
			DressData.CompanionEquippedShoeItem = toItem
		elseIf (DTSleep_ArmorStockingsList != None && DTSleep_ArmorStockingsList.HasForm(matchForm))
			DressData.CompanionLastEquippedStockingsItem = DressData.CompanionEquippedStockingsItem
			DressData.CompanionEquippedStockingsItem = toItem
			; stocking may also be ULeg
			if (DTSleep_ArmorSlotULegList != None && DTSleep_ArmorSlotULegList.HasForm(matchForm))
				DressData.CompanionLastEquippedULegItem = DressData.CompanionEquippedULegItem
				DressData.CompanionEquippedULegItem = toItem
			endIf
			
	; slots
		elseIf (DTSleep_ArmorSlot41List != None && DTSleep_ArmorSlot41List.HasForm(matchForm))
			DressData.CompanionLastEquippedSlot41Item = DressData.CompanionEquippedSlot41Item
			DressData.CompanionEquippedSlot41Item = toItem 
		elseIf (DTSleep_ArmorSlot55List != None && DTSleep_ArmorSlot55List.HasForm(matchForm))
			DressData.CompanionLastEquippedSlot55Item = DressData.CompanionEquippedSlot55Item
			DressData.CompanionEquippedSlot55Item = toItem
			; could also be a strap-on - do we care?
		elseIf (DTSleep_ArmorJewelry56List != None && DTSleep_ArmorJewelry56List.HasForm(matchForm))			; v2.71
			DressData.CompanionEquippedSlot56Item = toItem
			DressData.CompanionEquippedSlot56IsJewelry = false
			if (toItem != None)
				if (DTSleep_ArmorJewelry56List.HasForm(toItem))
					DressData.CompanionEquippedSlot56IsJewelry = true
				endIf
			endIf
		elseIf (DTSleep_ArmorJewelry57List != None && DTSleep_ArmorJewelry57List.HasForm(matchForm))			; v2.71
			DressData.CompanionEquippedSlot57Item = toItem
			DressData.CompanionEquippedSlot57IsJewelry = false
			if (toItem != None)
				if (DTSleep_ArmorJewelry57List.HasForm(toItem))
					DressData.CompanionEquippedSlot57IsJewelry = true
				endIf
			endIf
		elseIf (DTSleep_ArmorSlot58List && DTSleep_ArmorSlot58List.HasForm(matchForm))
			
			DressData.CompanionLastEquippedSlot58Item = DressData.CompanionEquippedSlot58Item
			DressData.CompanionLastSlot58IsSleepwear = DressData.CompanionEquippedSlot58IsSleepwear
			DressData.CompanionEquippedSlot58Item = toItem
			
			; check sleepwear
			if (toItem != None)
				if (DTSleep_SleepAttireFemale.HasForm(matchForm))
					DressData.CompanionEquippedSlot58IsSleepwear = true
					DressData.CompanionEquippedSlot58IsJewelry = false
				elseIf ((DTSConditionals as DTSleep_Conditionals).IsAWKCRActive && (DTSConditionals as DTSleep_Conditionals).AWKCRPiercingKW != None && toItem.HasKeyword((DTSConditionals as DTSleep_Conditionals).AWKCRPiercingKW))
					DressData.CompanionEquippedSlot58IsJewelry = true
					DressData.CompanionEquippedSlot58IsSleepwear = false
				elseIf (DTSleep_ArmorJewelry58List.HasForm(matchForm))
					DressData.CompanionEquippedSlot58IsJewelry = true
					DressData.CompanionEquippedSlot58IsSleepwear = false
				endIf
			else
				DressData.CompanionEquippedSlot58IsSleepwear = false
				DressData.CompanionEquippedSlot58IsJewelry = false
			endIf
			
		elseIf (DTSleep_ArmorSlotFXList && DTSleep_ArmorSlotFXList.HasForm(matchForm))
			DressData.CompanionLastEquippedSlotFXItem = DressData.CompanionEquippedSlotFXItem
			DressData.CompanionLastSlotFXIsSleepwear = DressData.CompanionEquippedSlotFXIsSleepwear
			DressData.CompanionEquippedSlotFXItem = toItem
			; check sleepwear
			if (toItem && DTSleep_SleepAttireFemale && DTSleep_SleepAttireFemale.HasForm(matchForm))
				DressData.CompanionEquippedSlotFXIsSleepwear = true
			else
				DressData.CompanionEquippedSlotFXIsSleepwear = false
			endIf
		elseIf (DTSleep_ArmorSlotULegList != None && DTSleep_ArmorSlotULegList.HasForm(matchForm))
			DressData.CompanionLastEquippedULegItem = DressData.CompanionEquippedULegItem
			DressData.CompanionEquippedULegItem = toItem
			; may also be stocking
			if (DTSleep_ArmorSlotULegList != None && DTSleep_ArmorSlotULegList.HasForm(matchForm))
				DressData.CompanionLastEquippedULegItem = DressData.CompanionEquippedULegItem
				DressData.CompanionEquippedULegItem = toItem
			endIf
		else
			; includes sleepwear
			SetCompanionDressDataBasicMatchFormToArmor(matchForm, toItem)
		endIf
		
	endIf
endFunction

; companion
; lists supported by base game
Function SetCompanionDressDataBasicMatchFormToArmor(Form matchForm, Armor toItem)
	if (matchForm != None)
		;Debug.Trace("[DTSleep_EquipMon] SetDressDataBasic: " + matchform)
		if (DTSleep_SleepAttireFemale && DTSleep_SleepAttireFemale.HasForm(matchForm))
			DressData.CompanionLastEquippedSleepwearItem = DressData.CompanionEquippedSleepwearItem
			DressData.CompanionEquippedSleepwearItem = toItem as Armor
		elseIf (DTSleep_SleepAttireMale && DTSleep_SleepAttireMale.HasForm(matchForm))
			DressData.CompanionLastEquippedSleepwearItem = DressData.CompanionEquippedSleepwearItem
			DressData.CompanionEquippedSleepwearItem = toItem as Armor
		endIf
		
		if (DTSleep_ArmorAllExceptionList && DTSleep_ArmorAllExceptionList.HasForm(matchForm))
			;Debug.Trace("[DTSleep_EquipMon] SetDressBasic ArmorAll to " + toItem)
			DressData.CompanionHasArmorAllEquipped = (toItem as bool)
			DressData.CompanionOutfitBody = toItem
		endIf
	endIf
endFunction

; player
Function SetDressDataMatchArmorToArmor(Armor matchItem, Armor toItem)
	if (matchitem != None)
	; priority named before slots except sleepwear which marks in both
		;Debug.Trace("[DTSleep_EquipMon] SetDressDataMatchArmor: " + matchItem + " set to " + toItem)
		
		if (DressData.PlayerEquippedBackpackItem == matchItem)
			DressData.PlayerLastEquippedBackpackItem = DressData.PlayerEquippedBackpackItem
			DressData.PlayerEquippedBackpackItem = toItem
			if (toItem && DTSleep_ArmorBackPacksnoGOList && DTSleep_ArmorBackPacksnoGOList.HasForm(toItem as Form))
				DressData.PlayerBackPackNoGOModel = true
			else
				DressData.PlayerBackPackNoGOModel = false
			endIf
		elseIf (DressData.PlayerLastEquippedBackpackItem == matchItem)
			if (toItem != None)
				; may have different slots - only replace since bump or remove will match equipped above
				DressData.PlayerEquippedBackpackItem = toItem
			endIf
			if (toItem && DTSleep_ArmorBackPacksnoGOList && DTSleep_ArmorBackPacksnoGOList.HasForm(toItem as Form))
				DressData.PlayerBackPackNoGOModel = true
			else
				DressData.PlayerBackPackNoGOModel = false
			endIf
		elseIf (DressData.PlayerEquippedCarryPouchItem == matchItem)
			DressData.PlayerEquippedCarryPouchItem = toItem
		elseIf (DTSConditionals.AWKCRPackKW != None && matchItem.HasKeyword(DTSConditionals.AWKCRPackKW))
			DressData.PlayerEquippedBackpackItem = toItem
			DressData.PlayerBackPackNoGOModel = false
		elseIf (DTSConditionals.AWKCRBandolKW != None && matchItem.HasKeyword(DTSConditionals.AWKCRBandolKW))
			DressData.PlayerEquippedCarryPouchItem = toItem
			
		; intimate attire before others
		
		elseIf (DressData.PlayerEquippedIntimateAttireItem == matchItem)
			DressData.PlayerLastEquippedIntimateAttireItem = DressData.PlayerEquippedIntimateAttireItem
			DressData.PlayerEquippedIntimateAttireItem = toItem
			if (DressData.PlayerGender == 1 && DressData.PlayerLastEquippedIntimateAttireItem != None)
				if (DressData.PlayerLastEquippedIntimateAttireItem.HasKeyword(DTSleep_SleepWearCamiKY))
					;v2.30 - allow both 
					DressData.PlayerLastEquippedSleepwearItem = DressData.PlayerLastEquippedIntimateAttireItem
				elseIf (DTSleep_SleepAttireFemale.HasForm(DressData.PlayerLastEquippedIntimateAttireItem))
					;v2.30 - allow both
					DressData.PlayerLastEquippedSleepwearItem = DressData.PlayerLastEquippedIntimateAttireItem
				endIf
			endIf
		elseIf (DressData.PlayerLastEquippedIntimateAttireItem == matchItem)
			DressData.PlayerEquippedIntimateAttireItem = toItem
		elseIf (DressData.PlayerGender == 1 && matchItem.HasKeyword(DTSleep_IntimateOutfitFemKY))
			DressData.PlayerEquippedIntimateAttireItem = toItem
		elseIf (DressData.PlayerGender == 1 && DTSleep_IntimateAttireList.HasForm(matchItem as Form))
			DressData.PlayerEquippedIntimateAttireItem = toItem
		elseIf (DressData.PlayerGender == 0 && DTSleep_IntimateAttireMaleList.HasForm(matchItem as Form))
			DressData.PlayerEquippedIntimateAttireItem = toItem
			
		; mask 
		
		elseIf (DressData.PlayerEquippedMask == matchItem)
			DressData.PlayerLastEquippedMask = DressData.PlayerEquippedMask
			DressData.PlayerEquippedMask = toItem
		elseIf (DressData.PlayerLastEquippedMask == matchItem)
			if (toItem != None)
				DressData.PlayerEquippedMask = toItem
			endIf
		; glasses
		
		elseIf (DressData.PlayerEquippedGlassesItem == matchItem)
			DressData.PlayerLastEquippedGlassesItem = DressData.PlayerEquippedGlassesItem
			DressData.PlayerEquippedGlassesItem  = toItem
		elseIf (DressData.PlayerLastEquippedGlassesItem == matchItem)
			if (toItem != None)
				DressData.PlayerEquippedGlassesItem = toItem
			endIf
		elseIf (DTSleep_ArmorGlassesList.HasForm(matchItem))

			DressData.PlayerEquippedGlassesItem = toItem
		
		; jacket  - some jackets may not replace other jacket (different slots) -consider case removing old after equip new
			
		elseIf (DressData.PlayerEquippedJacketItem == matchItem)
			if (DressData.PlayerEquippedJacketSecondItem == matchItem)
				CheckSwapClearSecondJacket()
			endIf
			DressData.PlayerLastEquippedJacketItem = DressData.PlayerEquippedJacketItem
			DressData.PlayerEquippedJacketItem = toItem
			
		elseIf (DressData.PlayerLastEquippedJacketItem == matchItem)
			if (toItem != None)
				; do not null since unequip will match existing equipped by bump or by manual
				if (DressData.PlayerEquippedJacketItem != None && DressData.PlayerEquippedJacketItem != toItem)
					; v2.24 check preference
					CheckSwapJacketsForItem(toItem)
				else
					; old way
					DressData.PlayerEquippedJacketItem = toItem
				endIf
			endIf
		elseIf (DressData.PlayerEquippedJacketSecondItem == matchitem)
			if (toItem != None && DressData.PlayerEquippedJacketItem != None && toItem == DressData.PlayerEquippedJacketItem)
				; matched, but already have on main so clear second
				CheckSwapClearSecondJacket()
			elseIf (toItem == None)
				CheckSwapClearSecondJacket()
			endIf
			
		elseIf (DTSConditionals.AWKCRCloakKW != None && matchItem.HasKeyword(DTSConditionals.AWKCRCloakKW))
			if (toItem != None && DressData.PlayerEquippedJacketItem != None && toItem != DressData.PlayerEquippedJacketItem)
				CheckSwapJacketsForItem(toItem)
			else
				DressData.PlayerEquippedJacketItem = toItem
			endIf
		elseIf (DTSConditionals.AWKCRJacketKW != None && matchItem.HasKeyword(DTSConditionals.AWKCRJacketKW))
			if (toItem != None && DressData.PlayerEquippedJacketItem != None && toItem != DressData.PlayerEquippedJacketItem)
				CheckSwapJacketsForItem(toItem)
			else
				DressData.PlayerEquippedJacketItem = toItem
			endIf
			
		; strap-on
		
		elseIf (DressData.PlayerEquippedStrapOnItem == matchItem)
			DressData.PlayerLastEquippedStrapOnItem = DressData.PlayerEquippedStrapOnItem
			DressData.PlayerEquippedStrapOnItem = toItem
		elseIf (DressData.PlayerLastEquippedStrapOnItem == matchItem)
			if (toItem != None)
				DressData.PlayerEquippedStrapOnItem = toItem
			endIf
		
		; footwear v2.80
		
		elseIf (DressData.PlayerEquippedShoeItem == matchItem)
			DressData.PlayerLastEquippedShoeItem = DressData.PlayerEquippedShoeItem
			DressData.PlayerEquippedShoeItem = toItem
		elseIf (DressData.PlayerLastEquippedShoeItem == matchItem)
			if (toItem != None)
				DressData.PlayerEquippedShoeItem = toItem
			endIf
			
	; slots			
		elseIf (DressData.PlayerEquippedSlot41Item == matchItem)
			DressData.PlayerLastEquippedSlot41Item = DressData.PlayerEquippedSlot41Item
			DressData.PlayerEquippedSlot41Item = toItem 
		elseIf (DressData.PlayerLastEquippedSlot41Item == matchItem)
			DressData.PlayerEquippedSlot41Item = toItem 
		elseIf (DressData.PlayerEquippedSlot55Item == matchItem)
			DressData.PlayerLastEquippedSlot55Item = DressData.PlayerEquippedSlot55Item
			DressData.PlayerEquippedSlot55Item = toItem 
		elseIf (DressData.PlayerLastEquippedSlot55Item == matchItem)
			DressData.PlayerEquippedSlot55Item = toItem 
		elseIf (DressData.PlayerEquippedSlot56Item == matchItem)								; v2.71
			; no last item
			DressData.PlayerEquippedSlot56Item = toItem
			DressData.PlayerEquippedSlot56IsJewelry = false
			if (toItem != None && DTSleep_ArmorJewelry56List.HasForm(toItem as Form))
				DressData.PlayerEquippedSlot56IsJewelry = true
			endIf
		elseIf (DressData.PlayerEquippedSlot57Item == matchItem)								; v2.71
			; no last item
			DressData.PlayerEquippedSlot57Item = toItem
			DressData.PlayerEquippedSlot57IsJewelry = false
			if (toItem != None && DTSleep_ArmorJewelry57List.HasForm(toItem as Form))
				DressData.PlayerEquippedSlot56IsJewelry = true
			endIf
		elseIf (DressData.PlayerEquippedSlot58Item == matchItem)
			
			DressData.PlayerLastEquippedSlot58Item = DressData.PlayerEquippedSlot58Item
			DressData.PlayerEquippedSlot58Item = toItem
			; maybe a sleepwear
			DressData.PlayerLastEquippedSlot58IsSleepwear = DressData.PlayerEquippedSlot58IsSleepwear
			if (toItem != None)
				if (DTSleep_SleepAttireFemale.HasForm(toItem))
					DressData.PlayerEquippedSlot58IsSleepwear = true
					DressData.PlayerEquippedSlot58IsJewelry = false
				elseIf ((DTSConditionals as DTSleep_Conditionals).IsAWKCRActive && (DTSConditionals as DTSleep_Conditionals).AWKCRPiercingKW != None && toItem.HasKeyword((DTSConditionals as DTSleep_Conditionals).AWKCRPiercingKW))
					DressData.PlayerEquippedSlot58IsJewelry = true
					DressData.PlayerEquippedSlot58IsSleepwear = false
				elseIf (DTSleep_ArmorJewelry58List.HasForm(toItem))
					DressData.PlayerEquippedSlot58IsJewelry = true
					DressData.PlayerEquippedSlot58IsSleepwear = false
				endIf
			else
				DressData.PlayerEquippedSlot58IsSleepwear = false
				DressData.PlayerEquippedSlot58IsJewelry = false
			endIf
		elseIf (DressData.PlayerLastEquippedSlot58Item == matchItem)
			
			DressData.PlayerEquippedSlot58Item = toItem 
			; maybe a sleepwear
			if (toItem != None)
				if (DTSleep_SleepAttireFemale.HasForm(toItem))
					DressData.PlayerEquippedSlot58IsSleepwear = true
					DressData.PlayerEquippedSlot58IsJewelry = false
				elseIf ((DTSConditionals as DTSleep_Conditionals).IsAWKCRActive && (DTSConditionals as DTSleep_Conditionals).AWKCRPiercingKW != None && toItem.HasKeyword((DTSConditionals as DTSleep_Conditionals).AWKCRPiercingKW))
					DressData.PlayerEquippedSlot58IsJewelry = true
					DressData.PlayerEquippedSlot58IsSleepwear = false
				elseIf (DTSleep_ArmorJewelry58List.HasForm(toItem))
					DressData.PlayerEquippedSlot58IsJewelry = true
					DressData.PlayerEquippedSlot58IsSleepwear = false
				endIf
			else
				DressData.PlayerEquippedSlot58IsSleepwear = false
				DressData.PlayerEquippedSlot58IsJewelry = false
			endIf
		elseIf (DressData.PlayerEquippedSlotFXItem == matchItem)
			DressData.PlayerLastEquippedSlotFXItem = DressData.PlayerEquippedSlotFXItem
			DressData.PlayerEquippedSlotFXItem = toItem 
			; maybe a sleepwear
			DressData.PlayerLastEquippedSlotFXIsSleepwear = DressData.PlayerEquippedSlotFXIsSleepwear
			if (toItem && DTSleep_SleepAttireFemale.HasForm(toItem))
				DressData.PlayerEquippedSlotFXIsSleepwear = true
			else
				DressData.PlayerEquippedSlotFXIsSleepwear = false
			endIf
		elseIf (DressData.PlayerLastEquippedSlotFXItem == matchItem)
			DressData.PlayerEquippedSlotFXItem = toItem 
			; maybe a sleepwear
			if (toItem && DTSleep_SleepAttireFemale.HasForm(toItem))
				DressData.PlayerEquippedSlotFXIsSleepwear = true
			else
				DressData.PlayerEquippedSlotFXIsSleepwear = false
			endIf
		elseIf (DressData.PlayerLastEquippedULegItem == matchItem)
			DressData.PlayerLastEquippedULegItem = DressData.PlayerEquippedULegItem				; v2.80 fix--was missing
			DressData.PlayerEquippedULegItem = toItem
			; stocking may also be ULeg								; v2.80
			if (DTSleep_ArmorStockingsList != None && DTSleep_ArmorStockingsList.HasForm(matchItem as Form))
				DressData.PlayerLastEquippedStockingsItem = DressData.PlayerEquippedStockingsItem
				DressData.PlayerEquippedStockingsItem = toItem
			endIf
			
		elseIf (DTSleep_ArmorExtraClothingList && DTSleep_ArmorExtraClothingList.HasForm(matchItem))
			if (toItem == None)
				PlayerExtraClothingCount -= 1
			else
				PlayerExtraClothingCount += 1
			endIf
			if (PlayerExtraClothingCount <= 0)
				PlayerExtraClothingCount = 0
				DressData.PlayerHasExtraClothingEquipped = false
			else
				DressData.PlayerHasExtraClothingEquipped = true
			endIf
		elseIf (DTSleep_ArmorExtraPartsList && DTSleep_ArmorExtraPartsList.HasForm(matchItem))
			if (toItem == None)
				PlayerExtraPartsCount -= 1
			else
				PlayerExtraPartsCount += 1
			endIf
			if (PlayerExtraPartsCount <= 0)
				PlayerExtraPartsCount = 0
				DressData.PlayerHasExtraPartsEquipped = false
			else
				DressData.PlayerHasExtraPartsEquipped = true
			endIf
			
	; sleepwear 
		elseIf (DressData.PlayerEquippedSleepwearItem == matchItem)
			
			DressData.PlayerLastEquippedSleepwearItem = DressData.PlayerEquippedSleepwearItem
			DressData.PlayerEquippedSleepwearItem = toItem

		elseIf (DressData.PlayerLastEquippedSleepwearItem == matchItem)
			if (toItem != None)
				; may be different slots 
				DressData.PlayerEquippedSleepwearItem = toItem
			endIf
			
	; search lists
		elseIf (DTSleep_EquipMonInit.GetValue() >= 2.0 && !DressData.SearchListsDisabled)
			
			SetDressDataMatchingFormToArmor(matchItem as Form, toItem)
		endIf
		
		; double-check jackets
		if (DressData.PlayerEquippedJacketSecondItem != None)
			if (DressData.PlayerEquippedJacketSecondItem == DressData.PlayerEquippedJacketItem)
				; same jacket - remove 2nd
				DressData.PlayerEquippedJacketSecondItem = None
			else
				int jacketPref = DTSleep_SettingMultiJacketOn.GetValueInt()
				if (jacketPref >= 2)
					; ignore preference - remove 2nd
					if (DressData.PlayerEquippedJacketItem == None)
						DressData.PlayerEquippedJacketItem = DressData.PlayerEquippedJacketSecondItem
					endIf
					DressData.PlayerEquippedJacketSecondItem = None
					
				elseIf (jacketPref <= 0 && DressData.PlayerEquippedJacketItem != None)
					; prevent preference - have 2 jackets on
					; okay for many jacket changes -- we check if equip and timer paused until exit menu, repeat resets timer
					StartTimer(1.1, RemSecondJacketTimerID)
				endIf
			endIf
		endIf
	endIf
endFunction


; player
; only necessary if have mods - init = 2
Function SetDressDataMatchingFormToArmor(Form matchForm, Armor toItem)
	if (matchForm)
	; priority named before slots except sleepwear which marks in both
		;Debug.Trace("[DTSleep_EquipMon] SetDressDataMatchForm: " + matchForm)
		if (DTSleep_ArmorBackPacksList && DTSleep_ArmorBackPacksList.HasForm(matchForm))
			DressData.PlayerLastEquippedBackpackItem = DressData.PlayerEquippedBackpackItem
			DressData.PlayerEquippedBackpackItem = toItem
			if (toItem && DTSleep_ArmorBackPacksnoGOList && DTSleep_ArmorBackPacksnoGOList.HasForm(toItem as Form))
				DressData.PlayerBackPackNoGOModel = true
			else
				DressData.PlayerBackPackNoGOModel = false
			endIf
		elseIf (DTSleep_ArmorBackPacksnoGOList && DTSleep_ArmorBackPacksnoGOList.HasForm(matchForm))
			DressData.PlayerLastEquippedBackpackItem = DressData.PlayerEquippedBackpackItem
			DressData.PlayerEquippedBackpackItem = toItem
			if (toItem && DTSleep_ArmorBackPacksnoGOList && DTSleep_ArmorBackPacksnoGOList.HasForm(toItem as Form))
				DressData.PlayerBackPackNoGOModel = true
			else
				DressData.PlayerBackPackNoGOModel = false
			endIf
		elseIf (DTSleep_ArmorCarryPouchList && DTSleep_ArmorCarryPouchList.HasForm(matchForm))
			DressData.PlayerEquippedCarryPouchItem = toItem
		
		elseIf (DressData.PlayerGender == 1 &&  matchForm.HasKeyword(DTSleep_IntimateOutfitFemKY))
			DressData.PlayerEquippedIntimateAttireItem = toItem
		elseIf (DressData.PlayerGender == 1 && DTSleep_IntimateAttireList.HasForm(matchForm))
			DressData.PlayerEquippedIntimateAttireItem = toItem
		elseIf (DressData.PlayerGender == 0 && DTSleep_IntimateAttireMaleList.HasForm(matchForm))
			DressData.PlayerEquippedIntimateAttireItem = toItem
			
		elseIf (DTSleep_ArmorMaskList && DTSleep_ArmorMaskList.HasForm(matchForm))
			DressData.PlayerEquippedMask = toItem
			
		elseIf (DTSleep_ArmorGlassesList.HasForm(matchForm))
			DressData.PlayerEquippedGlassesItem = toItem
		
		elseIf (DTSleep_ArmorExtraClothingList && DTSleep_ArmorExtraClothingList.HasForm(matchForm))
			if (toItem == None)
				PlayerExtraClothingCount -= 1
			else
				PlayerExtraClothingCount += 1
			endIf
			if (PlayerExtraClothingCount <= 0)
				PlayerExtraClothingCount = 0
				DressData.PlayerHasExtraClothingEquipped = false
			else
				DressData.PlayerHasExtraClothingEquipped = true
			endIf
		elseIf (DTSleep_ArmorExtraPartsList && DTSleep_ArmorExtraPartsList.HasForm(matchForm))
			if (toItem == None)
				PlayerExtraPartsCount -= 1
			else
				PlayerExtraPartsCount += 1
			endIf
			if (PlayerExtraPartsCount <= 0)
				PlayerExtraPartsCount = 0
				DressData.PlayerHasExtraPartsEquipped = false
			else
				DressData.PlayerHasExtraPartsEquipped = true
			endIf
		
		elseIf (DTSleep_ArmorJacketsClothingList && DTSleep_ArmorJacketsClothingList.HasForm(matchForm))
		
			; watch for case: jacket previously equipped and now remove another jacket (different slots)
			if (toItem == None && DressData.PlayerEquippedJacketItem != None && DressData.PlayerEquippedJacketItem != matchForm)

				DressData.PlayerLastEquippedJacketItem = matchForm as Armor

			elseIf (toItem != None && DressData.PlayerEquippedJacketItem != None && toItem != DressData.PlayerEquippedJacketItem)
				CheckSwapJacketsForItem(toItem)
			else
				if (DressData.PlayerEquippedJacketItem != None)
					DressData.PlayerLastEquippedJacketItem = DressData.PlayerEquippedJacketItem
				endIf
				DressData.PlayerEquippedJacketItem = toItem
			endIf
			
		elseIf (DTSleep_StrapOnList != None && DTSleep_StrapOnList.HasForm(matchForm))
			; check before slot55 to give priority
			DressData.PlayerLastEquippedStrapOnItem = DressData.PlayerEquippedStrapOnItem
			DressData.PlayerEquippedStrapOnItem = toItem 
		elseIf (DTSleep_ArmorShoeList != None && DTSleep_ArmorShoeList.HasForm(matchForm))
			; v2.80 may be any slot so check before slots below
			DressData.PlayerLastEquippedShoeItem = DressData.PlayerEquippedShoeItem
			DressData.PlayerEquippedShoeItem = toItem
		elseIf (DTSleep_ArmorStockingsList != None && DTSleep_ArmorStockingsList.HasForm(matchForm))
			DressData.PlayerLastEquippedStockingsItem = DressData.PlayerEquippedStockingsItem
			DressData.PlayerEquippedStockingsItem = toItem
			; stocking may also be ULeg 
			if (DTSleep_ArmorSlotULegList != None && DTSleep_ArmorSlotULegList.HasForm(matchForm))
				DressData.PlayerLastEquippedULegItem = DressData.PlayerEquippedULegItem
				DressData.PLayerEquippedULegItem = toItem
			endIf
	; slots
		elseIf (DTSleep_ArmorSlot41List && DTSleep_ArmorSlot41List.HasForm(matchForm))
			DressData.PlayerLastEquippedSlot41Item = DressData.PlayerEquippedSlot41Item
			DressData.PlayerEquippedSlot41Item = toItem 
		elseIf (DTSleep_ArmorSlot55List && DTSleep_ArmorSlot55List.HasForm(matchForm))
			DressData.PlayerLastEquippedSlot55Item = DressData.PlayerEquippedSlot55Item
			DressData.PlayerEquippedSlot55Item = toItem
			; could also be a strap-on - do we care?
		elseIf (DTSleep_ArmorJewelry56List != None && DTSleep_ArmorJewelry56List.HasForm(matchForm))			; v2.71
			DressData.PlayerEquippedSlot56Item = toItem
			DressData.PlayerEquippedSlot56IsJewelry = false
			if (toItem != None)
				if (DTSleep_ArmorJewelry56List.HasForm(toItem))
					DressData.PlayerEquippedSlot56IsJewelry = true
				endIf
			endIf
		elseIf (DTSleep_ArmorJewelry57List != None && DTSleep_ArmorJewelry57List.HasForm(matchForm))			; v2.71
			DressData.PlayerEquippedSlot57Item = toItem
			DressData.PlayerEquippedSlot57IsJewelry = false
			if (toItem != None)
				if (DTSleep_ArmorJewelry57List.HasForm(toItem))
					DressData.PlayerEquippedSlot57IsJewelry = true
				endIf
			endIf
		elseIf (DTSleep_ArmorSlot58List && DTSleep_ArmorSlot58List.HasForm(matchForm))
			
			DressData.PlayerLastEquippedSlot58Item = DressData.PlayerEquippedSlot58Item
			DressData.PlayerLastEquippedSlot58IsSleepwear = DressData.PlayerEquippedSlot58IsSleepwear
			DressData.PlayerEquippedSlot58Item = toItem
			
			; check sleepwear
			if (toItem != None)
				if (DTSleep_SleepAttireFemale.HasForm(matchForm))
					DressData.PlayerEquippedSlot58IsSleepwear = true
					DressData.PlayerEquippedSlot58IsJewelry = false
				elseIf ((DTSConditionals as DTSleep_Conditionals).IsAWKCRActive && (DTSConditionals as DTSleep_Conditionals).AWKCRPiercingKW != None && toItem.HasKeyword((DTSConditionals as DTSleep_Conditionals).AWKCRPiercingKW))
					DressData.PlayerEquippedSlot58IsJewelry = true
					DressData.PlayerEquippedSlot58IsSleepwear = false
				elseIf (DTSleep_ArmorJewelry58List.HasForm(matchform))
					DressData.PlayerEquippedSlot58IsJewelry = true
					DressData.PlayerEquippedSlot58IsSleepwear = false
				endIf
			else
				DressData.PlayerEquippedSlot58IsSleepwear = false
				DressData.PlayerEquippedSlot58IsJewelry = false
			endIf
			
		elseIf (DTSleep_ArmorSlotFXList && DTSleep_ArmorSlotFXList.HasForm(matchForm))
			DressData.PlayerLastEquippedSlotFXItem = DressData.PlayerEquippedSlotFXItem
			DressData.PlayerLastEquippedSlotFXIsSleepwear = DressData.PlayerEquippedSlotFXIsSleepwear
			DressData.PlayerEquippedSlotFXItem = toItem
			; check sleepwear
			if (toItem && DTSleep_SleepAttireFemale != None && DTSleep_SleepAttireFemale.HasForm(matchForm))
				DressData.PlayerEquippedSlotFXIsSleepwear = true
			else
				DressData.PlayerEquippedSlotFXIsSleepwear = false
			endIf
		elseIf (DTSleep_ArmorSlotULegList != None && DTSleep_ArmorSlotULegList.HasForm(matchForm))
			DressData.PlayerLastEquippedULegItem = DressData.PlayerEquippedULegItem
			DressData.PLayerEquippedULegItem = toItem
		else
			; includes sleepwear
			SetDressDataBasicMatchFormToArmor(matchForm, toItem)
		endIf
		
	endIf
endFunction

; lists supported by base game
Function SetDressDataBasicMatchFormToArmor(Form matchForm, Armor toItem)
	if (matchForm != None)
		;Debug.Trace("[DTSleep_EquipMon] SetDressDataBasic: " + matchform)
		if (matchForm.HasKeyword(DTSleep_SleepwearKY))
			DressData.PlayerLastEquippedSleepwearItem = DressData.PlayerEquippedSleepwearItem
			DressData.PlayerEquippedSleepwearItem = toItem
		elseIf (DressData.PlayerGender == 1 && DTSleep_SleepAttireFemale.HasForm(matchForm))
			DressData.PlayerLastEquippedSleepwearItem = DressData.PlayerEquippedSleepwearItem
			DressData.PlayerEquippedSleepwearItem = toItem
		elseIf (DressData.PlayerGender == 0 &&DTSleep_SleepAttireMale != None && DTSleep_SleepAttireMale.HasForm(matchForm))
			DressData.PlayerLastEquippedSleepwearItem = DressData.PlayerEquippedSleepwearItem
			DressData.PlayerEquippedSleepwearItem = toItem
		endIf
		
		if (DTSleep_ArmorAllExceptionList != None && DTSleep_ArmorAllExceptionList.HasForm(matchForm))
			;Debug.Trace("[DTSleep_EquipMon] SetDressBasic ArmorAll to " + toItem)
			
			if (toItem == None)
				DressData.PlayerHasArmorAllEquipped = false
			else
				DressData.PlayerHasArmorAllEquipped = true
			endIf
			DressData.PlayerEquippedBodyOutfit = toItem
			DressData.PlayerLastEquippedBodyOutfit = None
			
			; is it a sexy armor-all?
			if (DressData.PlayerGender == 0)
				if (DTSleep_SexyClothesFList != None && DTSleep_SexyClothesFList.HasForm(matchForm))
					DressData.PlayerHasSexyOutfitEquipped = DressData.PlayerHasArmorAllEquipped
				endIf
			elseIf (DTSleep_SexyClothesMList != None && DTSleep_SexyClothesMList.HasForm(matchForm))
				DressData.PlayerHasSexyOutfitEquipped = DressData.PlayerHasArmorAllEquipped
			endIf
		else
			; check sexy clothes that may not be armor-all
			bool isSexy = false
			if (DressData.PlayerGender == 0)
				if (DTSleep_SexyClothesFList != None && DTSleep_SexyClothesFList.HasForm(matchForm))
					isSexy = true
				endIf
			elseIf (DTSleep_SexyClothesMList != None && DTSleep_SexyClothesMList.HasForm(matchForm))
				isSexy = true
			endIf
			
			if (isSexy)
				if (toItem == None)
					DressData.PlayerHasSexyOutfitEquipped = false
				else
					DressData.PlayerHasSexyOutfitEquipped = true
				endIf
				DressData.PlayerEquippedBodyOutfit = toItem
				DressData.PlayerLastEquippedBodyOutfit = None
			endIf
		endIf
	endIf
endFunction

; ------------------- storage ---------------

Function StoreAddToCompanionSecEquip(Form akBaseObject)
	if (akBaseObject == DTSleep_NudeRing || akBaseObject == DTSleep_NudeRingNoHands || akBaseObject == DTSleep_NudeSuit)
		;Debug.Trace("[DTSleep_EquipMon] companion found nude-armor" + akBaseObject + " NOT storing!")
		return
		
	elseIf (DressData.CompanionNudeSuit != None && akBaseObject == DressData.CompanionNudeSuit)
		;Debug.Trace("[DTSleep_EquipMon] companion found custom nude-armor" + akBaseObject + " NOT storing!")
		return 
		
	elseIf (DTSleep_LeitoGunList.HasForm(akBaseObject) || DTSleep_NudeRingList.HasForm(akBaseObject) || DTSleep_BT2GunList.HasForm(akBaseObject))
		;Debug.Trace("[DTSleep_EquipMon] companion found Leito nude-armor" + akBaseObject + " NOT storing!")
		return
	endIf
	
	EMCompanionSecEquippedArmorFormArray.Add(akBaseObject, 1)
endFunction

Function StoreAddToCompanionEquip(Form akBaseObject, ObjectReference akReference)
	
	if (akBaseObject == DTSleep_NudeRing || akBaseObject == DTSleep_NudeRingNoHands || akBaseObject == DTSleep_NudeSuit)
		;Debug.Trace("[DTSleep_EquipMon] companion found nude-armor" + akBaseObject + " NOT storing!")
		return
		
	elseIf (DressData.CompanionNudeSuit != None && akBaseObject == DressData.CompanionNudeSuit)
		;Debug.Trace("[DTSleep_EquipMon] companion found custom nude-armor" + akBaseObject + " NOT storing!")
		return 
		
	elseIf (DTSleep_LeitoGunList.HasForm(akBaseObject) || DTSleep_NudeRingList.HasForm(akBaseObject) || DTSleep_BT2GunList.HasForm(akBaseObject))
		;Debug.Trace("[DTSleep_EquipMon] companion found Leito nude-armor" + akBaseObject + " NOT storing!")
		return
	endIf

	EMCompanionEquippedArmorFormArray.Add(akBaseObject, 1)
	
	if (DTSleep_CaptureExtraPartsEnable.GetValueInt() > 0)
		if (ProcessExtraPartsAdd(akBaseObject))
			CompanionExtraPartsCount += 1
		endIf
	endIf
endFunction

Function StoreAddToPlayerEquip(Form akBaseObject, ObjectReference akReference)
	;Debug.Trace("[DTSleep_EquipMon] storing player item " + akBaseObject + ", Ref: " + akReference)
	

	EMPlayerEquippedArmorFormArray.Add(akBaseObject, 1)

	if (!DTSleep_ArmorPipPadList.HasForm(akBaseObject) && !DTSleep_ArmorPipBoyList.HasForm(akBaseObject))
		if (DTSleep_CaptureExtraPartsEnable.GetValueInt() > 0)
			if (ProcessExtraPartsAdd(akBaseObject))
				PlayerExtraPartsCount += 1
			endIf
		endIf
	endIf
endFunction


Function StoreRemoveFromCompanionEquip(Form baseObject)

	int index = EMCompanionEquippedArmorFormArray.Length - 1
	
	while (index >= 0)
		Form emItem = EMCompanionEquippedArmorFormArray[index]
		if (emItem != None && emItem == baseObject)
			EMCompanionEquippedArmorFormArray.Remove(index)
			
			if (DTSleep_CaptureExtraPartsEnable.GetValueInt() > 0)
				if (ProcessExtraPartsRemove(baseObject))
					CompanionExtraPartsCount -= 1
					if (CompanionExtraPartsCount < 0)
						CompanionExtraPartsCount = 0
					endIf
				endIf
			endIf
			
			index = -1
		endIf
		
		index -= 1
	endWhile
endFunction

Function StoreRemoveFromCompanionSecEquip(Form baseObject)

	int index = EMCompanionSecEquippedArmorFormArray.Length - 1
	
	while (index >= 0)
		Form emItem = EMCompanionSecEquippedArmorFormArray[index]
		if (emItem != None && emItem == baseObject)
			EMCompanionSecEquippedArmorFormArray.Remove(index)
			
			index = -1
		endIf
		
		index -= 1
	endWhile
endFunction

Function StoreRemoveFromPlayerEquip(Form baseObject)
	int index = EMPlayerEquippedArmorFormArray.Length - 1
	
	while (index >= 0)
		Form emItem = EMPlayerEquippedArmorFormArray[index]
		if (emItem != None && emItem == baseObject)
			EMPlayerEquippedArmorFormArray.Remove(index)
			
			if (DTSleep_CaptureExtraPartsEnable.GetValueInt() > 0)
				if (ProcessExtraPartsRemove(baseObject))
					PlayerExtraPartsCount -= 1
					if (PlayerExtraPartsCount < 0)
						PlayerExtraPartsCount = 0
					endIf
				endIf
			endIf
			
			index = -1
		endIf
		
		index -= 1
	endWhile
endFunction

bool Function StoreAddMyPlayerEquipItem(Form baseObject)

	if (MyPlayerEquippedArray == None)
		MyPlayerEquippedArray = new Form[0]
	endIf
	
	if (MyPlayerNeedToUnEquipArray != None)
		int i = MyPlayerNeedToUnEquipArray.Length - 1
		while (i >= 0)
			if (MyPlayerNeedToUnEquipArray[i] == baseObject)
				MyPlayerNeedToUnEquipArray.Remove(i)
				
				return false
			endIf
		
			i -= 1
		endWhile
	endIf
	
	int count = 0
	int index = 0
	while (index < MyPlayerEquippedArray.Length)
		if (MyPlayerEquippedArray[index] == baseObject)
			count += 1
		endIf
		
		index += 1
	endWhile
	
	if (count == 0)
		MyPlayerEquippedArray.Add(baseObject)
		
		return true
	endIf
	
	return false
endFunction

Function StoreProcessPlayerNeedToUnEquip()
	
	if (processingUnequip)
		StartTimer(0.5, 13)
		return
	endIf
	
	;Debug.Trace("[DTSleep_EquipMon] process need-to-unequip count " + MyPlayerNeedToUnEquipArray.Length + " with playerEquip count " + MyPlayerEquippedArray.Length)

	int index = 0
	while (index < MyPlayerNeedToUnEquipArray.Length)
	
		Form item = MyPlayerNeedToUnEquipArray[index]
		StoreRemoveMyPlayerEquip(item)

		index += 1
	endWhile
	
	;Debug.Trace("[DTSleep_EquipMon] donce process with playerEquip count " + MyPlayerEquippedArray.Length)
	
	MyPlayerNeedToUnEquipArray.Clear()
endFunction

bool Function StoreRemoveMyPlayerEquip(Form baseObject)
	if (MyPlayerEquippedArray == None)
		return false
	endIf
	int index = MyPlayerEquippedArray.Length - 1
	int count = 0
	
	while (index >= 0)
		Form emItem = MyPlayerEquippedArray[index]
		if (emItem != None && emItem == baseObject)
			MyPlayerEquippedArray.Remove(index)
			count += 1
			;look for more copies to remove
		endIf
		
		index -= 1
	endWhile
	
	if (count > 0)
		return true
	endIf
	
	return false
endFunction


Function SetExtraPartsCountEmpty()
	PlayerExtraPartsCount = 0
	PlayerExtraClothingCount = 0
	DTSleep_PlayerEquipExtraPartsCount.SetValueInt(0)
endFunction


; --------------------------------------

Function UpdateClothingCounts()
	
	int count = 0
	DTSleep_PlayerEquipSleepGloveCount.SetValueInt(0)
	
	if (DressData.PlayerEquippedCarryPouchItem != None)
		count = 1
	endIf
	if (DressData.PlayerEquippedBackpackItem != None)
		count += 1
	endIf
	
	DTSleep_PlayerEquipBackpackCount.SetValueInt(count)
	
	count = 0
	
	if (DressData.PlayerEquippedSleepwearItem != None)
		count += 1
		;v2.48 add a count if includes gloves
		if (DTSleep_SleepAttireHandsList.HasForm(DressData.PlayerEquippedSleepwearItem))
			DTSleep_PlayerEquipSleepGloveCount.SetValueInt(1)
		endIf
	endIf
	if (DressData.PlayerEquippedSlot58IsSleepwear)
		count += 1
	endIf
	if (DressData.PlayerEquippedSlotFXIsSleepwear)
		count += 1
	endIf
	
	DTSleep_PlayerEquipSleepwearCount.SetValueInt(count)
	
	count = 0
	
	if (DressData.PlayerEquippedStrapOnItem != None)
		count = 1
	endIf
	
	DTSleep_PlayerEquipStrapOnCount.SetValueInt(count)
	
	;---- v2.80 count footwear; shoe is 1, stockings is 10; so both is 11
	count = 0
	
	if (DressData.PlayerEquippedShoeItem != None)
		count = 1
	endIf
	if (DressData.PlayerEquippedStockingsItem != None)
		count += 10
	endIf
	
	DTSleep_PlayerEquipFootWearCount.SetValueInt(count)
	; ------------------
	
	count = 0
	
	if (DressData.PlayerEquippedIntimateAttireItem != None)
		count = 1
		;v2.48 add a count if includes gloves
		if (DTSleep_SleepAttireHandsList.HasForm(DressData.PlayerEquippedIntimateAttireItem))
			DTSleep_PlayerEquipSleepGloveCount.SetValueInt(1)
		endIf
	endIf
	
	DTSleep_PlayerEquipIntimateItemCount.SetValueInt(count)
	
	count = 0
	
	if (DressData.PlayerEquippedJacketItem != None)
		count = 1
	endIf
	if (DressData.PlayerEquippedJacketSecondItem != None)
		count += 1
	endIf
	
	DTSleep_PlayerEquipJacketCount.SetValueInt(count)
	
	count  = 0
	
	if (DressData.PlayerEquippedMask != None)
		count = 1
	endIf
	
	DTSleep_PlayerEquipMaskCount.SetValueInt(count)
	
	count = 0
	
	if (DressData.PlayerEquippedChokerItem != None)
		count = 10
	endIf
	
	if (DressData.PlayerEquippedNecklaceItem != None)
		count += 1
	endIf
	
	DTSleep_PlayerNecklaceChokerCount.SetValueInt(count)
	
	count = PlayerExtraPartsCount + PlayerExtraClothingCount
	
	DTSleep_PlayerEquipExtraPartsCount.SetValueInt(count)
	
endFunction

; I guess I originally intended to pass reference instead of armor... doesn't matter now
bool Function ValidArmorToCheck(Armor item, Form baseForm = None)
	if (item != None)
		if (item.HasKeyword(ArmorTypePowerKY))
			return false
		elseIf (item.HasKeyword(ArmorTypeHatKY) || item.HasKeyword(ArmorTypeHelmetKY)) ; || item.HasKeyword(ArmorBodyPartHeadKY))
			return false
		endIf
		; v2.27
		if ((DTSConditionals as DTSleep_Conditionals).PipPadSlotIndex > 0)
			if (DTSleep_ArmorPipPadList.HasForm(item))
				return false
			endIf
		endIf
		return true
	elseIf (baseForm != None)
		if ((DTSConditionals as DTSleep_Conditionals).PipPadSlotIndex > 0)
			if (DTSleep_ArmorPipPadList.HasForm(baseForm))
				return false
			endIf
		endIf
	endIf
	
	return false
endFunction
