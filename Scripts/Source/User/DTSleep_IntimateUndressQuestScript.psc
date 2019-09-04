ScriptName DTSleep_IntimateUndressQuestScript extends Quest
{ handles undress and redress of player character and companion }

; ******************
; DTSleep_IntimateUndressQuestScript for SleepIntimate
; by DracoTorre
; www.dracotorre.com/mods/sleepintimate/
; https://github.com/Dracotorre/SleepIntimateV2
;
; handles all dress and undress of player and companion characters 
; armor-only undress (plus attachments) or undress all but jewelry and special clothing
; equipped compatible backpacks/bags when undress placed at foot of bed
;
; uses an EquipMonitor on playerAlias - 
;  on first start initializes equipment by forcing undress fully
;  keep quest running so that EquipMonitor will continue keeping track of equipment
;
;

import DTSleep_CommonF

Struct SleepwearEquipSet
	Armor SleepwearItem
	bool DidEquip
EndStruct

Struct UndressPlacedSet
	int FoundItemCount
	int PlacedItemCount
EndStruct

; ********************************************
; ****         properties        *****
;
Group A_Main
Actor property PlayerRef auto const
Actor property CaitRef auto const
Actor property CurieRef auto const
Actor property PiperRef auto const
Actor property DanseRef auto const
Actor property GarveyRef auto const
Actor property HancockRef auto const
Actor property MacCreadyRef auto const
Actor property CompanionDeaconRef auto const
Actor property CompanionX6Ref auto const
Actor property CompanionStrongRef auto const
Quest property DTSleep_IntimateAnimQuestP auto const

Static property DTSleep_DummyNode auto const

Armor property Pipboy auto const
Keyword property AnimFurnFloorBedAnims auto const
Keyword property AnimFurnCouchKY auto const
Keyword property ArmorTypePower auto const
Keyword property DTSleep_OutfitContainerKY auto const
Keyword property DTSleep_OwnBedPrivateKY auto const
Keyword property IsSleepFurnitureKY auto const

GlobalVariable property DTSleep_EquipMonInit auto
GlobalVariable property DTSleep_ExtraArmorsEnabled auto
DTSleep_DressData property DressData auto const
GlobalVariable property GameDay auto const
GlobalVariable property GameMonth auto Const
GlobalVariable property DTSleep_PlayerUndressed auto
GlobalVariable property DTSleep_PlayerUsingBed auto
;Keyword property ClothingPackSleepKY auto  ; tested to work if ever needed
Quest property DTSConditionals auto
ReferenceAlias property DTSleep_UndressPAlias auto
Spell property DTSleep_UndressCarryWeight auto const
GlobalVariable property DTSleep_UndressCarryBonus auto const
GlobalVariable property DTSleep_CompanionUndressed auto const
GlobalVariable property DTSleep_SettingTestMode auto const
GlobalVariable property DTSleep_SettingPackOnGround auto const
GlobalVariable property DTSleep_DebugMode auto const
GlobalVariable property DTSleep_IUndressStat auto
GlobalVariable property DTSleep_SettingAltFemBody auto	; added v2.12 for alternate female body
EndGroup

Group B_Lists
; List of armor items needing specific unequip attention in extra armor slots
; so we don't interfere with special items intended to stay worn using same slot
FormList property DTSleep_ArmorExtraPartsList auto const
{ extra slot accessories always removed }
FormList property DTSleep_ArmorExtraClothingList auto const
{ extra slot clothing removed if undressing }
FormList property DTSleep_ArmorSlot41List auto const
{ slot 41 armor clothing to remain on for sleep }
FormList property DTSleep_ArmorSlot55List auto const
{ slot 55 armor clothing to remain on for sleep }
FormList property DTSleep_ArmorSlot58List auto const
{ slot 58 armor clothing to remain on for sleep }
FormList property DTSleep_ArmorSlotFXList auto const
{ slot 61-FX armor clothing to remain on for sleep }
FormList property DTSleep_StrapOnList auto const
FormList property DTSleep_ArmorBackPacksList auto const
FormList property DTSleep_ArmorBackPacksnoGOList auto const
FormList property DTSleep_ArmorJacketsClothingList auto const
FormList property DTSleep_ArmorHatHelmList auto const
FormList property DTSleep_IntimateAttireList auto const
{ remains equipped for no-clothing manual start  }
FormList property DTSleep_SleepAttireFemale auto const
FormList property DTSleep_SleepAttireMale auto const
FormList property DTSleep_ArmorMaskList auto const
FormList property DTSleep_ArmorAllExceptionList auto const
FormList property DTSleep_SleepAttireFullArmorList auto const
{ sleepwear that uses armor slots }
FormList property DTSleep_ModCompanionBodiesLst auto const
FormList property DTSleep_ModCompanionActorList auto const
FormList property DTSleep_ArmorPipPadList auto const
FormList property DTSleep_ArmorGlassesList auto const
FormList property DTSleep_LeitoGunList auto const ; for backup check
FormList property DTSleep_BT2GunList auto const
FormList property DTSleep_IntimateAttireFemaleOnlyList auto const
EndGroup

Group C_Armors
Form property DTSGenericBagItem auto const
Armor property DTSleep_NudeSuit auto const
{ for nude scenes when custom unavailable }
Armor property DTSleep_NudeRing auto const
{ no body, includes hands }
Armor property DTSleep_NudeRingNoHands auto const
{ no body, no hands }
Armor property DTSleep_NudeRingArmorOuter auto const
{ only blocks outer armor }
Armor property DTSleep_NudeSuitPlayerUp auto const
Armor property DTSleep_NudeSuitPlayerForw auto const
Armor property DTSleep_LeitoGunNudeUp_UP auto const
Armor property DTSleep_LeitoGunNudeUp_Forw auto const
Armor property DTSleep_PlayerNudeRing auto const
Armor property DTSleep_PlayerNudeBodyNoPipBoy auto const
Armor property DTSleep_AltFemNudeBody auto const			; added v2.12
EndGroup

Group D_Settings
GlobalVariable property DTSleep_SettingUndressTimer auto
GlobalVariable property DTSleep_SettingUseLeitoGun auto const
GlobalVariable property DTSleep_SettingUseBT2Gun auto const
GlobalVariable property DTSleep_AdultContentOn auto const
GlobalVariable property DTSleep_SettingUndressGlasses auto const
GlobalVariable property DTSleep_SettingUndressPipboy auto const		; only for backup to check disabled status - caller decides for regular use
EndGroup

; -------
; ------------- hidden -----------------
Actor property CompanionRef auto hidden
Actor property CompanionSecondRef auto hidden
ObjectReference property CompanionBedRef auto hidden
ObjectReference property PlayerBedRef auto hidden
SleepwearEquipSet property PlayerSleepwearToRemoveSet auto hidden
SleepwearEquipSet property CompanionSleepwearToRemoveSet auto hidden
bool property IsRedressing auto hidden
bool property SuspendEquipStore auto hidden
{ until redress - caller set before using Start-functions }
bool property EnableCarryBonus auto hidden
bool property EnableCarryBonusRemove = true auto hidden
bool property DropSleepClothes = true auto hidden
bool property IsUndressAll = false auto hidden
bool property PlayerIsAroused = false auto hidden
int property PlayerArousedAngle = 0 auto hidden
int property UndressedForType = 0 auto hidden	; 1 for bed, 2 for manual-stop, 3 for sleep clothes, 5 for init, 0 = stopped
int property WeatherClass = 0 auto hidden
bool property AltFemBodyEnabled = true auto hidden	; disable to prevent alternate female nude-suit equip
bool property ForceEVBNude = false auto hidden

; ********************************************
; ******           variables     ***********
;
Form[] PlayerEquippedArmorFormArray     	; list to re-equip after
Form[] PlayerSleepEquippedFormArray			; list of sleep gear for sleeping
Form[] CompanionEquippedArmorFormArray		; list to re-equip after
Form[] CompanionSleepEquippedFormArray     	; list of equipped sleep items
ObjectReference[] PlacedArmorObjRefArray   	; list to clean-up after bed
bool PlayerEquippedArrayUpdated = false
bool CompanionEquippedArrayUpdated = false

int RedressTimerID = 202 const
int UndressGetPlayerEquipDataTimerID = 203 const
int UndressGetCompanionEquipDataTimerID = 204 const
int UndressPlayerAllTimerID = 205 const
int UndressPlayerNoPipTimerID = 206 const
int UndressPlayerClothingTimerID = 207 const
int RedressCompanionTimerID = 208 const
int RecheckNudeSuitsTimerID = 209 const
int UndressPlayerClothingPipboyTimerID = 210 const
int RemovePlacedTimerID = 211 const
int CheckNudeSuitPlayerRemoveTimerID = 212 const
int UndressPlayerNoClothingTimerID = 213 const
int UndressCheckCompanionFinalOuterArmorTimerID = 214 const		;v2.14 - moved final outer-armor check to timer to allow EquipMon chance to catch-up
int UndressCheckPlayerFinalOuterArmorTimerID = 215 const
string myScriptName = "[DTSleep_Undress]" const

InputEnableLayer UndressInputLayer

; ********************************************
; *****                Events       ***********
;
Event OnQuestInit()
	DTSleep_EquipMonInit.SetValue(0.0)    ; so we can initialize
	
	IsRedressing = false
EndEvent

Event OnTimer(int aiTimerID)
	if (aiTimerID == RedressTimerID)
		HandleRedressActors(true)
		
	elseIf (aiTimerID == CheckNudeSuitPlayerRemoveTimerID)
		CheckRemoveAllNudeSuits(PlayerRef)
		
	elseIf (aiTimerID == RemovePlacedTimerID)
		RemovePlacedItems()
		
	elseIf (aiTimerID == UndressGetPlayerEquipDataTimerID)
		HandleGetUndressPlayerData()
	elseIf (aiTimerID == UndressGetCompanionEquipDataTimerID)
		HandleGetUndressCompanionData()
		
	elseIf (aiTimerID == UndressPlayerAllTimerID)
		UndressActor(PlayerRef, 0, true, true, true)
	elseIf (aiTimerID == UndressPlayerNoPipTimerID)
		UndressActor(PlayerRef, 0, true, true, false)
	elseIf (aiTimerID == UndressPlayerClothingTimerID)
		UndressActor(PlayerRef, 1, true)
	elseIf (aiTimerID == UndressPlayerClothingPipboyTimerID)
		UndressActor(PlayerRef, 1, true, false, true)
	elseIf (aiTimerID == UndressPlayerNoClothingTimerID)
		UndressActor(PlayerRef, 1, false)
	elseIf (aiTimerID == UndressCheckCompanionFinalOuterArmorTimerID)
		UndressActorFinalCheckArmors(CompanionRef, false)
	elseIf (aiTimerID == UndressCheckPlayerFinalOuterArmorTimerID)
		UndressActorFinalCheckArmors(PlayerRef, false)
		
	elseIf (aiTimerID == RedressCompanionTimerID)
	
		RedressActor(CompanionRef, CompanionEquippedArmorFormArray, true)
	
		; pause a bit for equip in game to catch up before thread-sync
		Utility.Wait(0.4) 
		
		CompanionEquippedArmorFormArray.Clear()
		DTSleep_CompanionUndressed.SetValue(0.0)
		if (CompanionSleepwearToRemoveSet != None)
			CompanionSleepwearToRemoveSet.DidEquip = false
		endIf
	
	elseIf (aiTimerID == RecheckNudeSuitsTimerID)
		
		CheckNudeSuitsRemoved()
	endIf
EndEvent


Event ObjectReference.OnExitFurniture(ObjectReference akSender, ObjectReference akActionRef)
	
	if (akActionRef == PlayerRef && DTSleep_PlayerUsingBed.GetValue() > 0.0)
	
		EnableCarryBonusRemove = true

		DTDebug(" OnExitFurn... Undressed? " + DTSleep_PlayerUndressed.GetValueInt(), 2)
		
		if (DTSleep_PlayerUndressed.GetValue() > 0.0)
			; dress player and companion characters after getting out 
			StartTimer(2.2, RemovePlacedTimerID)
			StartTimer(3.7, RedressTimerID)
			if (!IsRedressing && UndressInputLayer == None)
				; disable menu until finished RedressActor
				UndressInputLayer = InputEnableLayer.Create()
				;                        disable activate    move,  fight, camSw, look, snk, menu, act, journ, Vats, Favs, run
				UndressInputLayer.DisablePlayerControls(false, false, true, false, false, true, true, true, false, false, false)
			endIf
		endIf
		
		DTSleep_PlayerUsingBed.SetValue(0.0)
		
		UnregisterForRemoteEvent(akSender, "OnExitfurniture")
		
	elseIf (akActionRef == CompanionRef)
		
		if (DTSleep_PlayerUndressed.GetValue() == 0.0 && CompanionEquippedArmorFormArray && CompanionEquippedArmorFormArray.length > 0)
			; player dressed, so start timer for companion
			StartTimer(3.2, RemovePlacedTimerID)
			StartTimer(4.4, RedressTimerID)
		endIf
		
		UnregisterForRemoteEvent(akSender, "OnExitfurniture")
	endIf
EndEvent

Event OnMenuOpenCloseEvent(string asMenuName, bool abOpening)
    if (asMenuName == "PipboyMenu")
	
		UnregisterForMenuOpenCloseEvent("PipboyMenu")
		
		; if in storage get it back!
		if (!IsRedressing && PlayerRef.GetItemCount(Pipboy) > 0 && !PlayerRef.IsEquipped(Pipboy))
		
			if (PlayerEquippedArmorFormArray != None && PlayerEquippedArmorFormArray.Length > 0)
				int index = 0
				
				while (index < PlayerEquippedArmorFormArray.Length)
					
					Armor item = PlayerEquippedArmorFormArray[index] as Armor
					if (item == Pipboy)
					
						PlayerRef.EquipItem(Pipboy, false, true)	;v1.81 fix - 2nd must be false--true blocks player from equipping other pip-boy such as Holoboy
						index = 1000		; v1.81 fix---was wrong array+1 which could have produced loop until array cleared
						
					elseIf ((DTSleep_UndressPAlias as DTSleep_EquipMonitor).DTSleep_ArmorPipBoyList.HasForm(item as Form))
						; v1.81 - handle custom Pip-boy
						PlayerRef.EquipItem(item, false, true)
						index = 1000
					endIf
					
					index += 1
				endWhile
			endIf
		endIf
	endIf
EndEvent

; ************* Get/Set and other publics ***************
;

Function DTDebug(string msgStr, int level)
	if (DTSleep_SettingTestMode.GetValue() > 0.0 && DTSleep_DebugMode.GetValueInt() >= level)
		Debug.Trace(myScriptName + " " + msgStr)
	endIf
endFunction

Form[] Function GetPlayerStoredArmorArray()
	; make copy
	
	if (!PlayerEquippedArrayUpdated)
		CancelTimer(UndressGetPlayerEquipDataTimerID)
		
		Utility.WaitMenuMode(0.333)
		HandleGetUndressPlayerData()
	endIf
	
	return DTSleep_CommonF.CopyFormArray(PlayerEquippedArmorFormArray)
endFunction

bool Function IsSummerSeason()
	int month = GameMonth.GetValueInt()
	if (month == 6)
		if (GameDay.GetValueInt() > 16)
			return true
		endIf
	elseIf (month >= 7 && month <= 8)
		return true
	elseIf (month == 9)
		if (GameDay.GetValueInt() < 23)
			return true
		endIf
	endIf
	
	return false
endFunction

bool Function IsWinterSeason()
	; winter outdoors check
	int month = GameMonth.GetValueInt()
	if (month == 11)
		if (GameDay.GetValueInt() > 11)
			return true
		endIf
	elseIf (month == 12 || month <= 2)
		return true
	elseIf (month == 3)
		if (GameDay.GetValueInt() < 14)
			return true
		endIf
	endIf
	
	return false
endFunction

int Function SetPlayerArousedLevel(int level)
	int angle = 0
	if (DressData.PlayerGender == 0 && (DTSConditionals as DTSleep_Conditionals).ImaPCMod)
		if (level <= 0)
			angle = 0
		elseIf (level >= 1)
			angle = 1
		endIf
		self.PlayerArousedAngle = angle
		if (level >= 0)
			self.PlayerIsAroused = true
		else
			self.PlayerIsAroused = false
		endIf
	else
		self.PlayerIsAroused = false
		return -1
	endIf

	return angle
endFunction

bool Function SetPlayerStoredArmorArray(Form[] formArray)
	; store copy
	if (IsRedressing)
		return false
	endIf
	if (formArray.Length > 0)
		PlayerEquippedArmorFormArray = DTSleep_CommonF.CopyFormArray(formArray)
	else
		PlayerEquippedArmorFormArray.Clear()
	endIf
	
	return true	
endFunction

bool Function SetMonitorCompanionEquip(Actor companionActorRef)
	if (CompanionRef != None && companionActorRef != CompanionRef)
		; already monitoring another companion

		return false
	endIf
	ResetCompanionDressData()
	(DTSleep_UndressPAlias as DTSleep_EquipMonitor).MonitorCompanion(companionActorRef)
	
	return true
endFunction

; use this if switching from manual-stop to bed-exit stop
bool Function SetStopOnBedExit()
	if (PlayerBedRef != None)
		RegisterForRemoteEvent(PlayerBedRef, "OnExitfurniture")
		return true
	endIf
	
	return false
endFunction

; ************** Start / Stop ********
; only undress Companion when player undress or companion only with bed
;
; Reminder: go 3rd-person view first for best results; disable controls good idea
;
bool Function StartForBedWake(bool includeClothing, ObjectReference mainBedRef, Actor companionActorRef, ObjectReference compBedRef, bool observeWinter = true, bool companionReqNudeSuit = true, bool includePipBoy = false, bool playerIsNaked = false)
	if (PlayerBedRef != None)
		DTDebug(" starting BedWake -- already have bed---cancel ", 2)
		return false
	elseIf (PlayerRef.WornHasKeyword(ArmorTypePower))
		DTDebug(" starting BedWake -- player in power armor --- cancel ", 2)
		return false
	endIf
	bool needInitEquipMon = false
	UndressedForType = 1
	AltFemBodyEnabled = false
	DTSleep_IUndressStat.SetValueInt(2)
	EnableCarryBonusRemove = true
	
	CancelTimer(RecheckNudeSuitsTimerID)
	
	if (observeWinter)
		if (mainBedRef != None && mainBedRef.HasKeyWord(DTSleep_OwnBedPrivateKY))
			; no winter for private bed
			observeWinter = false
		else
			; override for sleepwear check
			playerIsNaked = false
		endIf
	endIf
	IsUndressAll = false
	
	;float timeStart = Utility.GetCurrentRealTime()
	
	if (DTSleep_EquipMonInit.GetValueInt() < 5)
		; force naked to initialize
		
		includeClothing = true
		observeWinter = false
		needInitEquipMon = true
		if (includePipBoy)
			UndressedForType = 5
		else
			UndressedForType = 6	; mark to recover Pip-Boy
		endIf
		DTSleep_EquipMonInit.SetValueInt(0)
		ResetPlayerDressData()
		
	elseIf (DressData != None)
		DressData.SearchListsDisabled = true
	elseIf (DTSleep_DebugMode.GetValueInt() > 0)
		Debug.Trace(myScriptName + " no DressData!!")
	endIf

	PlayerBedRef = mainBedRef
	if (companionActorRef != None && !companionActorRef.WornHasKeyword(ArmorTypePower))
		CompanionRef = companionActorRef
	else
		CompanionRef = None
	endIf
	if (CompanionSecondRef != None)
		if (CompanionSecondRef == CompanionRef)
			CompanionSecondRef = None
		elseIf (CompanionSecondRef.WornHasKeyword(ArmorTypePower))
			CompanionSecondRef = None
		endIf
	endIf
	CompanionBedRef = compBedRef
	PlayerSleepwearToRemoveSet = new SleepwearEquipSet
	CompanionSleepwearToRemoveSet = new SleepwearEquipSet
	PlayerInSleepwearToRemove = false
	CompanionInSleepwearToRemove = false
	PlayerSleepEquippedFormArray = new Form[0]
	CompanionSleepEquippedFormArray = new Form[0]
	
	DTDebug(" starting BedWake on beds: " + mainBedRef + "," + compBedRef + " with companion: " + companionActorRef + " with 2nd comp: " + CompanionSecondRef, 2)
	
	if (CompanionRef != None)
	
		if (CompanionRef != DressData.CompanionActor)
			ResetCompanionDressData()
		endIf
	
		DressData.CompanionActor = CompanionRef
		DressData.CompanionRequiresNudeSuit = companionReqNudeSuit
		if ((DTSConditionals as DTSleep_Conditionals).IsVulpineRace != None)
			ActorBase compBase = CompanionRef.GetLeveledActorBase() as ActorBase
			if (compBase)
				Race compRace = compBase.GetRace()
				if (compRace == (DTSConditionals as DTSleep_Conditionals).IsVulpineRace)
					DressData.CompanionCustomRestrictSlot = 58
				endIf
			endIf
		endIf
	endIf
	
	if (PlayerBedRef != None || CompanionBedRef != None)
		PlacedArmorObjRefArray = new ObjectReference[0]
		
		if (!IsActorIndoors(PlayerRef))
			if (includeClothing && observeWinter)
				includeClothing = !IsWinterSeason()
			elseIf (!includeClothing && WeatherClass < 2)
				includeClothing = IsSummerSeason()
			endIf
		endIf
		
		if (PlayerBedRef != None && DTSleep_PlayerUndressed.GetValue() <= 0.0)
		
			; --- threaded undress ---
			; may need more wait-time inside undress steps, but faster overall
			; EquipMonitor supports dual actor undressing with storage
			; Wait to sync below
			;
			DTSleep_PlayerUndressed.SetValue(-2.0)  ; flag start
		
			; *** Undress Player ***
			if (!needInitEquipMon && includeClothing && CompanionRef != None)
			
				;Debug.Trace(myScriptName + " start player undress timer...")
				; okay to start new thread
				if (includeClothing)
					if (includePipBoy)
						StartTimer(0.33, UndressPlayerClothingPipboyTimerID)
					else
						StartTimer(0.33, UndressPlayerClothingTimerID)
					endIf
				else
					StartTimer(0.25, UndressPlayerNoClothingTimerID)
				endIf
			else
				; no thread - undress player first
				UndressActor(PlayerRef, 1, includeClothing, false, includePipBoy)
				
				if (needInitEquipMon)
					SetInitEquipMon()
				endIf
			endIf
			
			if (CompanionRef != None && CompanionSleepwearToRemoveSet != None && !CompanionSleepwearToRemoveSet.DidEquip)
			
				if (includeClothing)
					HandleStartForCompanionSleepwear()
				else 
					; *** undress companion ***
					UndressActor(CompanionRef, 1, includeClothing)
				endIf
				;if (includeClothing)
				;	Debug.Trace(myScriptName + " checking companion for sleepwear...")
				;	CompanionSleepwearToRemoveSet = SleepwearEquipForActor(CompanionRef)
				;endIf
				
				; must undress main companion first - now check 2nd
				if (CompanionSecondRef != None)
					Debug.Trace(myScriptName + " start for bed 2nd companion " + CompanionSecondRef)
					UndressActor(CompanionSecondRef, 1, includeClothing)
					if (includeClothing)
						SleepwearEquipForActor(CompanionSecondRef)
					endIf
				endIf
			endIf
			
			if (DTSleep_PlayerUndressed.GetValue() == -2.0)
			
				; never started undress.... ??
				;Debug.Trace(myScriptName + " player never started undress... force now")
				if (includeClothing)
					CancelTimer(UndressPlayerClothingPipboyTimerID)
					CancelTimer(UndressPlayerClothingTimerID)
				else
					CancelTimer(UndressPlayerNoClothingTimerID)
				endIf
				
				UndressActor(PlayerRef, 1, includeClothing, false, includePipBoy)		
			endIf
			
			; -- sync --
			; wait for player undress
			int wCount = 50
			
			while (DTSleep_PlayerUndressed.GetValue() < 1.0 && wCount > 0)
				Utility.WaitMenuMode(0.1)
				
				wCount -= 1
			endWhile
			;
			;  ----- end threaded undress - now synced ---
			
			
			;  --- player sleepwear check ----
			; check mark sleepwear added for remove later  - v1.41 - skip if player naked
			;
			if (includeClothing && !playerIsNaked && !PlayerSleepwearToRemoveSet.DidEquip)
			
				PlayerSleepwearToRemoveSet = SleepwearEquipForActor(PlayerRef)
			endIf
			
			; -------- register for exit
			DTSleep_IUndressStat.SetValueInt(0)
			DTDebug(" done undress for bed - " + PlayerBedRef, 1)
			
			if (PlayerBedRef != None)
			
				RegisterForRemoteEvent(PlayerBedRef, "OnExitFurniture")
				
				return true
			else
				DTDebug(" missing player bed! skip OnExitFurniture event register and redress now!", 1)
				Utility.WaitMenuMode(0.333)
				StopAll(false)
				Utility.WaitMenuMode(0.1)
				
				return false
			endIf
			
		elseIf (CompanionRef != None && CompanionBedRef != None && CompanionSleepwearToRemoveSet != None && !CompanionSleepwearToRemoveSet.DidEquip)
		
			UndressActor(CompanionRef, 1, includeClothing)
			RegisterForRemoteEvent(CompanionBedRef, "OnExitFurniture")
			
			DTSleep_IUndressStat.SetValueInt(0)
			
			return true
		endIf
	else
		StopAll(false)
	endIf
	
	return false
endFunction

bool Function StartForCompanionSleepwear(Actor companionActorRef, bool companionReqNudeSuit = true)
	if (PlayerBedRef != None)
	
		return false
	endIf
	if (companionActorRef == None || companionActorRef.WornHasKeyword(ArmorTypePower))
		return false
	endIf
	AltFemBodyEnabled = false
	if (UndressedForType <= 0)
		UndressedForType = 1
	endIf
	
	CancelTimer(RecheckNudeSuitsTimerID)
	
	CompanionSleepwearToRemoveSet = new SleepwearEquipSet
	
	;Debug.Trace(myScriptName + " starting manual undress to sleepwear for companion: " + companionActorRef)
	
	if (companionActorRef != DressData.CompanionActor)
		ResetCompanionDressData()
		
	elseIf (DressData.CompanionEquippedSleepwearItem)
		if (DressData.CompanionDressValid || companionActorRef.IsEquipped(DressData.CompanionEquippedSleepwearItem))
			CompanionRef = companionActorRef
			if (CompanionSleepwearToRemoveSet != None)
				CompanionSleepwearToRemoveSet.DidEquip = false
				CompanionSleepwearToRemoveSet.SleepwearItem = DressData.CompanionEquippedSleepwearItem
				;Debug.Trace(myScriptName + " already in sleepwear main outfit - return true")
			endIf
			
			return true
		else
			DressData.CompanionEquippedSleepwearItem = None
		endIf
		
	elseIf (DressData.CompanionEquippedSlot58IsSleepwear && DressData.CompanionDressValid)
		CompanionRef = companionActorRef
		if (CompanionSleepwearToRemoveSet != None)
			CompanionSleepwearToRemoveSet.DidEquip = true
			CompanionSleepwearToRemoveSet.SleepwearItem = DressData.CompanionEquippedSlot58Item
			;Debug.Trace(myScriptName + " already in slot58 sleepwear - return true ")
		endIf
		
		return true
	endIf
	
	CompanionRef = companionActorRef
	DressData.CompanionActor = companionActorRef
	DressData.CompanionRequiresNudeSuit = companionReqNudeSuit
	
	return HandleStartForCompanionSleepwear()
endFunction

;  hats, backpack, jacket if indoors/summer --- for hugs and such -v1.70
;	- for outdoors set includeHatsOutside false to keep on
;
bool Function StartForManualStopRespect(Actor companionActorRef, bool includeHatsOutside = true)

	if (DTSleep_EquipMonInit.GetValue() < 5.0)
		Debug.Trace(myScriptName + " system not yet initialized for respect undress")
		return false
	endIf
	
	CancelTimer(RecheckNudeSuitsTimerID)
	
	if (companionActorRef != None && !companionActorRef.WornHasKeyword(ArmorTypePower))
		CompanionRef = companionActorRef
	else
		CompanionRef = None
	endIf
	if (CompanionSecondRef != None)
		if (CompanionRef == None || CompanionSecondRef == CompanionRef)
			CompanionSecondRef = None
		elseIf (CompanionSecondRef.WornHasKeyword(ArmorTypePower))
			CompanionSecondRef = None
		endIf
	endIf
	UndressedForType = 1
	DTSleep_IUndressStat.SetValueInt(3)
	EnableCarryBonusRemove = true
	if (CompanionRef != None && CompanionRef != DressData.CompanionActor)
		ResetCompanionDressData()
	endIf
	
	PlayerEquippedArrayUpdated = false
	CompanionEquippedArrayUpdated = false
	bool isIndoors = IsActorIndoors(PlayerRef)
	
	if (CompanionRef != None)
		UndressActorRespect(CompanionRef, isIndoors, includeHatsOutside)
	endIf
	UndressActorRespect(PlayerRef, isIndoors, includeHatsOutside)
	
	IsUndressAll = false
	DTSleep_PlayerUndressed.SetValue(1.0)

	return true
endFunction

bool Function StartForFurnitureExitRespect(ObjectReference aFurnitureRef, Actor companionActorRef, bool includeHatsOutside = true)

	PlayerBedRef = aFurnitureRef
	if (aFurnitureRef != None && StartForManualStopRespect(companionActorRef, includeHatsOutside))
		
		DTSleep_PlayerUsingBed.SetValueInt(1)
		RegisterForRemoteEvent(PlayerBedRef, "OnExitfurniture")
		
		return true
	else
		PlayerBedRef = None
	endIf

	return false
endFunction

; added v1.80 so hugs and kisses before bed may dress in pajamas
;
bool Function StartForManualStopSleepwear(Actor companionActorRef, ObjectReference bedRef)
		
	bool removeNudeSuit = false
	if (DTSleep_EquipMonInit.GetValue() < 5.0)
		
		removeNudeSuit = true
	endIf
	AltFemBodyEnabled = false
	
	if (IsActorWearingSleepwear(PlayerRef))
		return true
	endIf
	
	CancelTimer(RecheckNudeSuitsTimerID)
	
	if (IsActorCarryingSleepwear(PlayerRef, bedRef))
		
		if (companionActorRef != None && IsActorCarryingSleepwear(companionActorRef))
		
			if (CompanionSecondRef != None && !IsActorCarryingSleepwear(CompanionSecondRef))
				CompanionSecondRef = None
			endIf
		
			; get into PJs as if going to bed
			StartForBedWake(true, bedRef, companionActorRef, None, false)
			
			; un-do since manual stop - 
			if (PlayerBedRef != None)
				UnregisterForRemoteEvent(PlayerBedRef, "OnExitfurniture")
			endIf
			
			if (UndressedForType < 5)
				UndressedForType = 3
			endIf
			
			return true
		endIf
	endIf
	
	;Debug.Trace(myScriptName + " no sleep clothes - no start")
	
	return false
endFunction

; will stay undressed until StopAll
; if includeClothing and observeWinter=false then also removes Lacy Underwear bottoms etc
;
bool Function StartForManualStop(bool includeClothing, Actor companionActorRef, bool observeWinter = true, bool companionReqNudeSuit = true, ObjectReference optionalBedRef = none, bool includePipBoy = false)
	;Debug.Trace(myScriptName + " starting manual undress with companion: " + companionActorRef)
	
	;float timeStart = Utility.GetCurrentRealTime()
	
	if (companionActorRef != None && !companionActorRef.WornHasKeyword(ArmorTypePower))
		CompanionRef = companionActorRef
	else
		CompanionRef = None
	endIf
	PlayerBedRef = optionalBedRef
	UndressedForType = 2
	DTSleep_IUndressStat.SetValueInt(3)
	EnableCarryBonusRemove = true
	
	CancelTimer(RecheckNudeSuitsTimerID)
	
	PlayerSleepwearToRemoveSet = new SleepwearEquipSet
	CompanionSleepwearToRemoveSet = new SleepwearEquipSet
	
	bool includeExceptions = false
	bool needInitEquipMon = false
	
	if (CompanionRef != None && CompanionRef != DressData.CompanionActor)
		ResetCompanionDressData()
	endIf
	
	if (CompanionRef != None)
		DressData.CompanionActor = CompanionRef
		DressData.CompanionRequiresNudeSuit = companionReqNudeSuit
		
		if (companionReqNudeSuit)
			DressData.CompanionNudeSuit = GetCustomNudeSuitForCompanion(CompanionRef)
		else
			DressData.CompanionNudeSuit = None
		endIf
	endIf
	
	if (CompanionSecondRef != None)
		if (CompanionRef == None || CompanionSecondRef == CompanionRef)
			CompanionSecondRef = None
		elseIf (CompanionSecondRef.WornHasKeyword(ArmorTypePower))
			CompanionSecondRef = None
		endIf
	endIf
	
	DTDebug(" starting manual stop with companion: " + CompanionRef + " and 2nd comp: " + CompanionSecondRef, 2)
	
	if (DTSleep_EquipMonInit.GetValueInt() < 5)
		; force naked to initialize

		includeClothing = true
		observeWinter = false
		needInitEquipMon = true
		if (includePipBoy)
			UndressedForType = 5
		else
			UndressedForType = 6	; mark to recover Pip-Boy
		endIf
	elseIf (DressData)
		DressData.SearchListsDisabled = true
	elseIf (DTSleep_DebugMode.GetValueInt() > 0)
		Debug.Trace(myScriptName + " no DressData!!")
	endIf

	if (includeClothing && observeWinter && !IsActorIndoors(PlayerRef))
		includeClothing = !IsWinterSeason()
		
	elseIf (includeClothing && !observeWinter)
		includeExceptions = true
	endIf
	
	if (includeClothing && includeExceptions)
		IsUndressAll = true
	else
		IsUndressAll = false
	endIf
	
	; --- threaded undress ---
	; may need more wait-time inside undress steps, but faster overall
	; EquipMonitor supports dual actor undressing with storage
	; Wait to sync below
	;
	DTSleep_PlayerUndressed.SetValue(-2.0)  ; flag start 
	
	if (!needInitEquipMon && includeClothing && includeExceptions)
		
		; okay to start new thread for player
		
		if (includePipBoy)
			StartTimer(0.38, UndressPlayerAllTimerID)
		else
			StartTimer(0.38, UndressPlayerNoPipTimerID)
		endIf
	else
		; not threaded - player first
		UndressActor(PlayerRef, 0, includeClothing, includeExceptions, includePipBoy)
		
		if (needInitEquipMon)
			SetInitEquipMon()
		endIf
	endIf
	
	if (CompanionRef != None)
	
		if (CompanionSleepwearToRemoveSet != None && CompanionSleepwearToRemoveSet.DidEquip)
		
			UndressSleepwearForActor(CompanionRef, CompanionSleepEquippedFormArray)
			CompanionSleepwearToRemoveSet.DidEquip = false
			CompanionSleepwearToRemoveSet.SleepwearItem = None
			CompanionEquippedArmorFormArray.Clear()
		else 
			UndressActor(CompanionRef, 0, includeClothing, includeExceptions)
		endIf
		
		; must undress main companion first - now check 2nd
		if (CompanionSecondRef != None)
			UndressActor(CompanionSecondRef, 1, includeClothing)
			Utility.Wait(0.333)
		endIf
		; Companions finished
	endIf
	
	int wCount = 20
	while (DTSleep_PlayerUndressed.GetValue() == -2.0 && wCount > 0)
		Utility.WaitMenuMode(0.1)
		wCount -= 1
	endWhile
	
	if (DTSleep_PlayerUndressed.GetValue() == -2.0)
	
		; never started undress...
		DTDebug("... never started undress for player... - start now", 2)
		if (includePipBoy)
			CancelTimer(UndressPlayerAllTimerID)
		else
			CancelTimer(UndressPlayerNoPipTimerID)
		endIf
		
		UndressActor(PlayerRef, 0, includeClothing, includeExceptions, includePipBoy)
		
	endIf
	
	; --- sync ---
	; wait for player to finish undress
	wCount = 50
	
	while (DTSleep_PlayerUndressed.GetValue() < 1.0 && wCount > 0)
		Utility.WaitMenuMode(0.1)
		wCount -= 1
	endWhile
	;
	; ---- end threaded undress now synced ---
	
	
	if (CompanionRef != None)
		; check to remove Strap-On if different genders and removing all
		
		if (DTSleep_StrapOnList && includeClothing && includeExceptions)
			bool playerChecked = false
			bool companionChecked = false
			
			int playerGender = GetGenderForActor(PlayerRef)
			int companionGender = GetGenderForActor(CompanionRef)
			
			if (playerGender != companionGender)
				if (DTSleep_EquipMonInit.GetValueInt() > 0)
					if (DressData.PlayerEquippedStrapOnItem)
						PlayerRef.UnequipItem(DressData.PlayerEquippedStrapOnItem, false, true)
					endIf
					playerChecked = true
					
					if (DressData.CompanionActor != None)
						if (companionGender == 1 && DressData.CompanionEquippedStrapOnItem)
							if (CompanionRef.IsEquipped(DressData.CompanionEquippedStrapOnItem))
								CompanionRef.UnequipItem(DressData.CompanionEquippedStrapOnItem, false, true)
								companionChecked = true
							else
								DressData.CompanionEquippedStrapOnItem = None
							endIf
						endIf
						companionChecked = true
					endIf
				endIf
				
				if (!playerChecked || !companionChecked)
					int len = DTSleep_StrapOnList.GetSize()
					if (len > 0)
						int i = 0
						while (i < len)
							Form toyForm = DTSleep_StrapOnList.GetAt(i)
							if (toyForm)
								Armor toyArmor = toyForm as Armor
								if (toyArmor)
									if (!playerChecked && playerGender == 1 && PlayerRef.GetItemCount(toyForm) > 0 && PlayerRef.IsEquipped(toyArmor))
										PlayerRef.UnequipItem(toyArmor, false, true)
									endIf
									if (!companionChecked && companionGender == 1 && CompanionRef.GetItemCount(toyForm) > 0 && CompanionRef.IsEquipped(toyArmor))
										CompanionRef.UnequipItem(toyArmor, false, true)
									endIf
								endIf
							endIf
							
							i += 1
						endWhile
					endIf
				endIf
			endIf
		endIf
	endIf
	
	;float timeElapse = Utility.GetCurrentRealTime() - timeStart
	;Debug.Trace(myScriptName + " total undress time: " + timeElapse)
	DTSleep_IUndressStat.SetValueInt(0)
	
	return true	
EndFunction

; player only
bool Function StartForNeverRedress()
	
	bool result = StartForManualStop(true, None, false)

	; reset values as if never undressed
	
	DTSleep_PlayerUndressed.SetValue(0.0)
	
	PlayerBedRef = None
	CompanionBedRef = None
	SuspendEquipStore = false
	PlayerEquippedArmorFormArray.Clear()
	
	return result 
EndFunction

Function StopAll(bool redressSlowly, int resetEquipInitVal = -10)

	;Debug.Trace(myScriptName + "--stopping...")
	UnregisterForMenuOpenCloseEvent("PipboyMenu")
	
	if (PlayerBedRef != None)
		UnregisterForRemoteEvent(PlayerBedRef, "OnExitfurniture")
	endIf
	
	bool allDone = true
	
	if (DTSleep_PlayerUndressed.GetValue() > 0.0)
	
		DTDebug(" Stop-All redress request", 1)
		
		if (redressSlowly && !IsRedressing)
			allDone = false
			StartTimer(0.5, RedressTimerID)
			StartTimer(2.2, RemovePlacedTimerID)
			
		elseIf (!IsRedressing)
			
			HandleRedressActors(false)		; do not call StopAll again

			StartTimer(0.3, RemovePlacedTimerID)
		endIf
		if (CompanionRef != None)
			StartTimer(3.5, RecheckNudeSuitsTimerID)			
		endIf

	elseIf (DTSleep_CompanionUndressed.GetValue() > 0.0 || (CompanionSleepwearToRemoveSet != None && CompanionSleepwearToRemoveSet.DidEquip))
		
		if (!IsRedressing)
			HandleRedressActors(false)
			StartTimer(1.0, RecheckNudeSuitsTimerID)
		endIf
	endIf
	
	SuspendEquipStore = false  ; should have been set false in Redress
	
	if (resetEquipInitVal > -5)
		DTSleep_EquipMonInit.SetValueInt(resetEquipInitVal)
		
	endIf
	
	if (allDone)
		DoneStopAll()
	endIf
	WeatherClass = 0
	
	; never stop this quest 
endFunction	
	

; ********************************************
; *****          Functions      *********

Function DoneStopAll()
	UndressedForType = 0
	; do not clear CompanionRef or CompanionSecondRef so CheckNudeSuitsRemoved may check
	PlayerBedRef = None
	CompanionBedRef = None
	if (DTSleep_AdultContentOn.GetValue() >= 2.0)
		AltFemBodyEnabled = true
	else
		AltFemBodyEnabled = false
	endIf
	DTSleep_IUndressStat.SetValueInt(0)
	DTDebug("DoneStopAll ", 2)
endFunction

Function CheckAndEquipIntimateOutfit(Actor actorRef)
	if (actorRef == PlayerRef)
		if (DressData.PlayerEquippedIntimateAttireItem == None)
			if (DressData.PlayerLastEquippedIntimateAttireItem != None)
				actorRef.UnequipItemSlot(3)
				Utility.WaitMenuMode(0.10)
				DTDebug(" re-equip Intimate outfit ", 3)
				
				PlayerRef.EquipItem(DressData.PlayerLastEquippedIntimateAttireItem, false, true)
			elseIf (DTSleep_DebugMode.GetValueInt() > 0)
				Debug.Trace(myScriptName + " missing intimate clothing item!!")
			endIf
		endIf
	elseIf (actorRef == CompanionRef && DressData.CompanionEquippedIntimateAttireItem == None)
	
		if (DressData.CompanionGender == 0 && DTSleep_IntimateAttireFemaleOnlyList.HasForm(DressData.CompanionEquippedIntimateAttireItem as Form))
			DressData.CompanionEquippedIntimateAttireItem = None	; correction
			DressData.CompanionLastEquippedIntimateAttireItem = None
			return
		endIf
		if (DressData.CompanionLastEquippedIntimateAttireItem != None)
			;actorRef.UnequipItemSlot(3)
			DTDebug(" re-equip Intimate outfit ", 2)

			actorRef.EquipItem(DressData.CompanionLastEquippedIntimateAttireItem, true, true)
		elseIf (DTSleep_DebugMode.GetValueInt() > 0)
			Debug.Trace(myScriptName + " missing intimate clothing item!!")
		endIf
	
	endIf
endFunction

Function CheckAndEquipStrapOnItem(Actor actorRef, Armor toyCheckRef)
	if (toyCheckRef != None)
		if (actorRef == PlayerRef)
			if (DressData.PlayerEquippedStrapOnItem == None)
				
				PlayerRef.EquipItem(toyCheckRef, false, true)
			endIf
			
		elseIf (actorRef == CompanionRef && DressData.CompanionEquippedStrapOnItem == None)
			actorRef.EquipItem(toyCheckRef, false, true)
		endIf
	endIf
endFunction

; to verify sleep outfit - only call if supposed to have equipped sleepwear
;
Function CheckAndEquipMainSleepOutfit(Actor actorRef)
	if (actorRef == None)
		Debug.Trace(myScriptName + " CheckAndEquipMainSleepOutfit - actor is None!!")
		return
	endIf
	
	if (DTSleep_EquipMonInit.GetValueInt() > 0)
		if (actorRef == PlayerRef)
			if (DressData.PlayerEquippedSleepwearItem == None)
			
				if (UndressedForType >= 5 && PlayerRef.GetItemCount(DTSleep_PlayerNudeBodyNoPipBoy) > 0)
					RedressActorRemoveNudeSuits(actorRef, DTSleep_PlayerNudeBodyNoPipBoy, " player nude-body-noPip", true)
				endIf
				if (DressData.PlayerLastEquippedSleepwearItem != None)
					actorRef.UnequipItemSlot(3)
					
					PlayerRef.EquipItem(DressData.PlayerLastEquippedSleepwearItem, false, true)
				elseIf (DTSleep_DebugMode.GetValueInt() > 0)
					Debug.Trace(myScriptName + " missing sleepwear!!")
				endIf
			endIf
			
		elseIf (actorRef == CompanionRef && DressData.CompanionEquippedSleepwearItem == None)
		
			; assume nude-ring knocked sleepwear off
			RedressActorRemoveNudeSuits(actorRef, DTSleep_NudeRing, " nude ring ")
			RedressActorRemoveNudeSuits(actorRef, DTSleep_NudeRingNoHands, " nude ring no-hands ")
			Utility.WaitMenuMode(0.2)
			
			if (DressData.CompanionEquippedSleepwearItem == None && DressData.CompanionLastEquippedSleepwearItem != None)
				
				actorRef.EquipItem(DressData.CompanionLastEquippedSleepwearItem, false, true)
			elseIf (DTSleep_DebugMode.GetValueInt() > 0)
				Debug.Trace(myScriptName + " missing sleepwear item! " + actorRef)
			endIf
		endIf
	endIf
endFunction

bool Function CheckActorHasSleepwearMainOutfit(Actor actorRef, int equipMonInitLevel)
	if (actorRef == None)
		Debug.Trace(myScriptName + " CheckActorHasSleepwearMainOutfit - actor is None!!")
		return false
	endIf
	
	if (equipMonInitLevel > 0)
		if (actorRef == PlayerRef)
			if (DressData.PlayerEquippedSleepwearItem)
				if (!DTSleep_ArmorSlot58List.HasForm(DressData.PlayerEquippedSleepwearItem))
					return true
				endIf
			endIf
			
			return false
			
		elseIf (actorRef == CompanionRef && DressData.CompanionActor && DressData.CompanionEquippedSleepwearItem)
			if (actorRef.IsEquipped(DressData.CompanionEquippedSleepwearItem))
				if (!DTSleep_ArmorSlot58List.HasForm(DressData.CompanionEquippedSleepwearItem))
					return true
				endIf
				
				return false
			else
				DressData.CompanionEquippedSleepwearItem = None
			endIf
		endIf
	endIf
	
	FormList sleepWearList = SleepWearListForActor(actorRef)
	if (sleepWearList != None)
		Armor item = GetArmorForActorWearingClothingOnList(actorRef, sleepWearList)
		if (item && !DTSleep_ArmorSlot58List.HasForm(item))
			if (actorRef == CompanionRef && DressData.CompanionActor)
				DressData.CompanionEquippedSleepwearItem = item
			endIf
			return true
		endIf
	endIf
	
	return false
endFunction

Function CheckNudeSuitsRemoved()

	if (IsRedressing)
		StartTimer(1.0, RecheckNudeSuitsTimerID)
		return
	endIf
	if (UndressedForType == 0)
		; only check if not undressed in case undressing again
		DTDebug(" CheckNudeSuitsRemoved ...", 2)
		
		if (CompanionRef != None)
			RedressActorRemoveNudeSuits(CompanionRef, DTSleep_NudeRingArmorOuter, " Recheck-nudeRingArmorOut", false)
			RedressActorRemoveNudeSuits(CompanionRef, DTSleep_NudeRing, " Recheck-nudeRing ", false)
			RedressActorRemoveNudeSuits(CompanionRef, DTSleep_NudeRingNoHands, " Recheck-nudeRingNoHands ", false)
			RedressActorRemoveNudeSuits(CompanionRef, DTSleep_NudeSuit, " Recheck-nudeSuit ", false)
			
			CheckRemoveLeitoGuns(CompanionRef)
		endIf
		if (CompanionSecondRef != None && UndressedForType == 0)
			RedressActorRemoveNudeSuits(CompanionSecondRef, DTSleep_NudeRingArmorOuter, " Recheck-nudeRingArmorOut", false)
			RedressActorRemoveNudeSuits(CompanionSecondRef, DTSleep_NudeRing, " Recheck-nudeRing ", false)
			RedressActorRemoveNudeSuits(CompanionSecondRef, DTSleep_NudeRingNoHands, " Recheck-nudeRingNoHands ", false)
			RedressActorRemoveNudeSuits(CompanionSecondRef, DTSleep_NudeSuit, " Recheck-nudeSuit ", false)
		endIf
		if (CompanionSecondRef != None && UndressedForType == 0)
			CheckRemoveLeitoGuns(CompanionSecondRef)
		endIf
		
		;do not clear CompanionRef -- let start handle
	endIf
endFunction

; backup for after scenes
Function CheckRemoveLeitoGuns(Actor aActor)

	CheckRemoveBT2Guns(aActor)
	
	if (DTSleep_LeitoGunList != None)
	
		int len = DTSleep_LeitoGunList.GetSize()
		int idx = 0
		while (idx < len)
			Armor gun = DTSleep_LeitoGunList.GetAt(idx) as Armor
			if (gun)
				int count = aActor.GetItemCount(gun)
				if (count > 0)
					aActor.UnequipItem(gun as Form, true, true)
					aActor.RemoveItem(gun as Form, count, true, None)
				endIf
			endIf
			idx += 1
		endWhile
	endIf
EndFunction

Function CheckRemoveBT2Guns(Actor aActor)
	
	int len = DTSleep_BT2GunList.GetSize()
	int idx = 0
	while (idx < len)
		Armor gun = DTSleep_BT2GunList.GetAt(idx) as Armor
		if (gun)
			int count = aActor.GetItemCount(gun)
			if (count > 0)
				aActor.UnequipItem(gun as Form, true, true)
				aActor.RemoveItem(gun as Form, count, true, None)
			endIf
		endIf
		idx += 1
	endWhile

EndFunction

bool Function CheckRemoveAllNudeSuits(Actor actorRef, bool checkCustom = true)

	if (actorRef == PlayerRef)
		if (PlayerIsAroused && DressData.PlayerGender == 0)
		
			bool okRemoved = RedressActorRemoveNudeSuits(PlayerRef, GetPlayerNudeSuitMale(), "player male nude suit")
			if (okRemoved)
				PlayerIsAroused = false
			else
				; may need to check later since AAF slow to replace after end of scene
				;----StartTimer(2.5, CheckNudeSuitPlayerRemoveTimerID)
				return false
			endIf
		else
			RedressActorRemoveNudeSuits(PlayerRef, DTSleep_PlayerNudeRing, " player nude-ring ")
		endIf
	else
		DTDebug("checking nude suit for " + actorRef, 2)
		; check both anyway
		RedressActorRemoveNudeSuits(actorRef, DTSleep_NudeRing, " nude ring ")
		
		RedressActorRemoveNudeSuits(actorRef, DTSleep_NudeRingArmorOuter, " nude ring-ArmorOut")
		RedressActorRemoveNudeSuits(actorRef, DTSleep_NudeRingNoHands, " nude ring no-hands ")
		
		if (checkCustom && actorRef == CompanionRef && DressData.CompanionNudeSuit != None)
			RedressActorRemoveNudeSuits(actorRef, DressData.CompanionNudeSuit, " custom nude suit ")
		else
			RedressActorRemoveNudeSuits(actorRef, DTSleep_NudeSuit, " nude suit ")
		endIf
	endIf
	
	return true
endFunction

int Function GetCompanionLeitoArmorIndexPublic(Actor actorRef)
	
	int armorIndex = -1
	
	if (actorRef != None)
	
		if (actorRef == DanseRef)
			armorIndex = 0
		elseIf (actorRef == GarveyRef)
			armorIndex = 2
		elseIf (actorRef == HancockRef)
			armorIndex = 3
		elseIf (actorRef == MacCreadyRef)
			armorIndex = 4
		elseIf (actorRef == CompanionDeaconRef)
			armorIndex = 5
		elseIf (actorRef == CompanionX6Ref)
			armorIndex = 6
		elseIf ((DTSConditionals as DTSleep_Conditionals).IsNukaWorldDLCActive)
			
			if ((DTSConditionals as DTSleep_Conditionals).NukaWorldDLCGageRef != None)
				if (actorRef == (DTSConditionals as DTSleep_Conditionals).NukaWorldDLCGageRef)
					armorIndex = 1
				endIf
			endIf
		endIf
	
	endIf
	
	return armorIndex
endFunction

int Function GetGenderForActor(Actor actorRef)
	if (actorRef == None)
		Debug.Trace(myScriptName + " GetGenderForActor - actor is None!!")
		return -1
	endIf

	int gender = -1
	
	if (actorRef == PlayerRef)
		if (DressData.PlayerGender >= 0)
			gender = DressData.PlayerGender
			return gender
		else
			ActorBase actBase = actorRef.GetBaseObject() as ActorBase
			gender = actBase.GetSex()
			DressData.PlayerGender = gender
			
			return gender
		endIf
	elseIf (DressData.CompanionActor == actorRef && DressData.CompanionGender >= 0)
		gender = DressData.CompanionGender
		
		return gender
	elseIf (actorRef == CaitRef)
		gender = 1
	elseIf (actorRef == CurieRef)
		gender = 1
	elseIf (actorRef == PiperRef)
		gender = 1
	elseIf (actorRef == DanseRef)
		gender = 0
	elseIf (actorRef == GarveyRef)
		gender = 0
	elseIf (actorRef == HancockRef)
		gender = 0
	elseIf (actorRef == MacCreadyRef)
		gender = 0
	elseIf (actorRef == CompanionDeaconRef)
		gender = 0
	elseIf (actorRef == CompanionX6Ref)
		gender = 0
	elseIf (actorRef == CompanionStrongRef)
		gender = 0
	else
		; Curie synth shows as gen2-Valentine, male gender -- set above
		; Ada is female, but human-mod could possibly set male 
		
		ActorBase actBase = actorRef.GetLeveledActorBase() as ActorBase
		gender = actBase.GetSex()
		DTDebug(" GetGenderForActor " + actorRef + " = " + gender, 2)
	endIf
	
	if (actorRef == DressData.CompanionActor)
		DressData.CompanionGender = gender
	endIf
		
	return gender
endFunction

Actor Function GetNWSBarbActor()
	if ((DTSConditionals as DTSleep_Conditionals).IsNWSBarbActive)
		int index = (DTSConditionals as DTSleep_Conditionals).ModCompanionActorNWSBarbIndex
		
		return GetModActor(index)
	endIf
	
	return None
EndFunction

Actor Function GetHeatherActor()
	if ((DTSConditionals as DTSleep_Conditionals).IsHeatherCompanionActive)
		int index = (DTSConditionals as DTSleep_Conditionals).ModCompanionActorHeatherIndex

		return GetModActor(index)
	endIf
	
	return None
EndFunction

Actor Function GetModActor(int index)
	if (index >= 0)
		int len = DTSleep_ModCompanionActorList.GetSize()
		
		if (index < len)
			return (DTSleep_ModCompanionActorList.GetAt(index) as Actor)
		else
			Debug.Trace(myScriptName + " error GetModActor - index > size (" + index + " > " + len + ")" )
		endIf
	endIf
	
	return None
endFunction

; None for no custom found
;
Armor Function GetCustomNudeSuitForCompanion(Actor actorRef)

	if (actorRef != None)
	
		int armorIndex = -1
		
		if ((DTSConditionals as DTSleep_Conditionals).IsUniqueFollowerFemActive)
			if (actorRef == CaitRef)
				armorIndex = 0
			elseIf (actorRef == CurieRef)
				armorIndex = 1
			elseIf (actorRef == PiperRef)
				armorIndex = 2
			endIf
			
			if (armorIndex >= 0)
				armorIndex += (DTSConditionals as DTSleep_Conditionals).ModUniqueFollowerFemBodyBaseIndex
			endIf
		endIf
		
		if (armorIndex < 0 && (DTSConditionals as DTSleep_Conditionals).IsUniqueFollowerMaleActive)
			
			armorIndex = GetCompanionLeitoArmorIndexPublic(actorRef)
			
			if (armorIndex >= 0)
				armorIndex += (DTSConditionals as DTSleep_Conditionals).ModUniqueFollowerMaleBodyBaseIndex
			endIf
		endIf
			
		if (armorIndex < 0 && (DTSConditionals as DTSleep_Conditionals).IsHeatherCompanionActive)
			if (actorRef == GetHeatherActor())
				armorIndex = (DTSConditionals as DTSleep_Conditionals).ModCompanionBodyHeatherIndex
			endIf
		endIf
		
		if (armorIndex >= 0)
			int len = DTSleep_ModCompanionBodiesLst.GetSize()
			if (armorIndex < len)
				return (DTSleep_ModCompanionBodiesLst.GetAt(armorIndex) as Armor)
			else
				Debug.Trace(myScriptName + " error GetCustomNudeSuitForCompanion - armor index > size (" + armorIndex + " > " + len + ")" )
			endIf
		endIf
	endIf
	
	return None
endFunction

Armor Function GetPlayerNudeSuitMale()

	if (DTSleep_AdultContentOn.GetValueInt() > 1)
	
		if ((DTSConditionals as DTSleep_Conditionals).IsUniquePlayerMaleActive && DTSleep_SettingUseLeitoGun.GetValueInt() > 0)
			if (self.PlayerArousedAngle >= 1)
				return DTSleep_LeitoGunNudeUp_UP
			else
				return DTSleep_LeitoGunNudeUp_Forw
			endIf
		elseIf (self.PlayerArousedAngle >= 1)
			
			if (DTSleep_SettingUseBT2Gun.GetValueInt() > 0 && !ForceEVBNude)
				return DTSleep_BT2GunList.GetAt(1) as Armor
			elseIf (DTSleep_SettingUseLeitoGun.GetValueInt() > 1)
				return DTSleep_NudeSuitPlayerUp
			endIf
		else
			if (DTSleep_SettingUseBT2Gun.GetValueInt() > 0 && !ForceEVBNude)
				return DTSleep_BT2GunList.GetAt(0) as Armor
			elseIf (DTSleep_SettingUseLeitoGun.GetValueInt() > 0)
				return DTSleep_NudeSuitPlayerForw
			endIf
		endIf
	endIf
	
	return None
endFunction

Armor Function GetStrapOnForActor(Actor actorRef, bool isPlayer, ObjectReference bedRef = None)
	if (actorRef == None)
		Debug.Trace(myScriptName + " GetStrapOnForActor - actor is None!!")
		return None
	endIf
	
	if ((DTSConditionals as DTSleep_Conditionals).ImaPCMod == false)
		return None
	endIf

	if (DTSleep_EquipMonInit.GetValueInt() > 0)
	
		if (isPlayer)
			if (DressData.PlayerEquippedStrapOnItem)
				return DressData.PlayerEquippedStrapOnItem
				
			elseIf (DressData.PlayerLastEquippedStrapOnItem)
			
				if (PlayerRef.GetItemCount(DressData.PlayerLastEquippedStrapOnItem) > 0)
					return DressData.PlayerLastEquippedStrapOnItem
				endIf
			endIf
			; else search inventory
			
		elseIf (actorRef == CompanionRef && DressData.CompanionActor && DressData.CompanionEquippedStrapOnItem)
			if (actorRef.IsEquipped(DressData.CompanionEquippedStrapOnItem))
			
				return DressData.CompanionEquippedStrapOnItem
			else
				DressData.CompanionEquippedStrapOnItem = None
			endIf
		endIf
	endIf
	
	; search inventory
	int i = 0
	int len = DTSleep_StrapOnList.GetSize()
	while (i < len)
		Armor toy = DTSleep_StrapOnList.GetAt(i) as Armor
		if (toy != None)
			if (actorRef.GetItemCount(toy) > 0)
				if (RaceRestrictedSlot58(actorRef))
					if (DTSleep_ArmorSlot58List.HasForm(toy as Form))
						toy = None
					endIf
				endIf
				
				if (!isPlayer && toy != None)
					if (actorRef.IsEquipped(toy))
						; mark companion equip storage for later
						DressData.CompanionEquippedStrapOnItem = toy
					endIf
				endIf
				if (toy != None)
					return toy
				endIf
				
			elseIf (isPlayer && bedRef != None && bedRef.HasKeyWord(DTSleep_OutfitContainerKY))
				; v1.58 - search bed container
				if (bedRef.GetItemCount(toy) > 0)
					
					return toy
				endIf
			endIf
		endIf
		
		i += 1
	endWhile
	
	return None
endFunction


; each IsEquipped takes 0.05 seconds - which is why we save in DressData
Armor Function GetArmorForActorWearingClothingOnList(Actor actorRef, FormList list)
	if (actorRef != None && list != None)
		int idx = 0
		while (idx < list.GetSize())
			Form itemForm = list.GetAt(idx)
			if (itemForm != None && actorRef.GetItemCount(itemForm) > 0 && actorRef.IsEquipped(itemForm))
				return itemForm as Armor
			endIf
			idx += 1
		endWhile
	endIf
	return None
endFunction

Function HandleGetUndressPlayerData()

	if (!PlayerEquippedArrayUpdated)
	
		PlayerEquippedArrayUpdated = true
		PlayerEquippedArmorFormArray = (DTSleep_UndressPAlias as DTSleep_EquipMonitor).EndStorePlayerEquipment()
		
		DTDebug(" PlayerEquipArray Length: " + PlayerEquippedArmorFormArray.Length, 3)
	endIf
endFunction

Function HandleGetUndressCompanionData()

	if (!CompanionEquippedArrayUpdated)
	
		CompanionEquippedArrayUpdated = true
		CompanionEquippedArmorFormArray = (DTSleep_UndressPAlias as DTSleep_EquipMonitor).EndStoreCompanionEquipment(CompanionRef)
		
		DTDebug(" CompanionEquipArray Length: " + CompanionEquippedArmorFormArray.Length, 3)
	endIf
endFunction

int MyNudeSuitRemAttemptCount = 0

; redress both
Function HandleRedressActors(bool slowly = true)

	if (IsRedressing)
		DTDebug(" HandleRedressActors - already IsRedressing - cancel", 1)
		return
	endIf
	DTSleep_IUndressStat.SetValueInt(1)
	IsRedressing = true
	
	DTDebug(" handleRedressActors", 3)
	
	; the following check only expected after AAF scene or if player activated AAF when undressed
	; due to delayed copy of armor items
	;
	if (CheckRemoveAllNudeSuits(PlayerRef) == false)
		if (MyNudeSuitRemAttemptCount < 10)
			DTDebug("nude-suit removal of player not ready - delay redress until later", 2)
			; delay until later
			StartTimer(3.5, RedressTimerID)
			IsRedressing = false
			MyNudeSuitRemAttemptCount += 1
			
			return
		endIf
		
	elseIf (CompanionRef != None && CheckRemoveAllNudeSuits(CompanionRef) == false)
		if (MyNudeSuitRemAttemptCount < 10)
			DTDebug("nude-suit removal of companion not ready - delay redress until later", 2)
			; delay until later
			StartTimer(1.25, RedressTimerID)
			IsRedressing = false
			MyNudeSuitRemAttemptCount += 1
			
			return
		endIf
		
		Utility.WaitMenuMode(0.2)
	endIf
	
	MyNudeSuitRemAttemptCount = 0
	Utility.WaitMenuMode(0.2)
	
	if (SuspendEquipStore || !PlayerEquippedArrayUpdated)
	
		; Check nude-suits first - may need to delay
		; check nude suits
	
		if (!SuspendEquipStore)
			Utility.WaitMenuMode(0.333)
		endIf
		
		HandleGetUndressPlayerData()
		
		if (CompanionRef != None)
			HandleGetUndressCompanionData()
		endIf
		
		SuspendEquipStore = false
		Utility.WaitMenuMode(0.4)
	endIf
	
	; companion first to thread if slowly
	
	if (CompanionRef != None)
		;Debug.Trace(myScriptName + " redress main companion (" + CompanionRef + ") length " + CompanionEquippedArmorFormArray.Length)
		
		if (CompanionSleepEquippedFormArray.Length > 0)
			UndressSleepwearForActor(CompanionRef, CompanionSleepEquippedFormArray)
			CompanionSleepEquippedFormArray.Clear()
			
		elseIf (CompanionSleepwearToRemoveSet != None && CompanionSleepwearToRemoveSet.DidEquip)
		
			if (DressData.CompanionEquippedSleepwearItem != None)
				CompanionRef.UnequipItem(DressData.CompanionEquippedSleepwearItem, false, true)
			endIf
			if (DressData.CompanionEquippedSlot58IsSleepwear && DressData.CompanionEquippedSlot58Item != None)
				CompanionRef.UnequipItem(DressData.CompanionEquippedSlot58Item, false, true)
			endIf
		endIf
		
		if (slowly)
			; threading
			StartTimer(0.2, RedressCompanionTimerID)
		else
			
			RedressActor(CompanionRef, CompanionEquippedArmorFormArray, slowly)
			Utility.WaitMenuMode(0.08)
			CompanionEquippedArmorFormArray.Clear()
			DTSleep_CompanionUndressed.SetValue(0.0)
			if (CompanionSleepwearToRemoveSet != None)
				CompanionSleepwearToRemoveSet.DidEquip = false
			endIf
		endIf
	endIf
	
	if (CompanionSecondRef != None)
		
		Form[] compSecArray = (DTSleep_UndressPAlias as DTSleep_EquipMonitor).EndStoreCompanionEquipment(CompanionSecondRef)
		if (compSecArray != None && compSecArray.Length > 0)
			;Debug.Trace(myScriptName + " redress secondComp len " + compSecArray.Length)
			RedressActor(CompanionSecondRef, compSecArray, false)
		endIf
	endIf
	
	; v1.58 storage bed
	Form[] storageOutfit = new Form[0]
	
	if (PlayerBedRef != None && PlayerBedRef.HasKeyword(DTSleep_OutfitContainerKY))
	
		if ((PlayerBedRef as DTSleep_OutfitContainerScript).HasStoredOutfit == 1)
			; only get regular outfit, not sleep outfit (2) 
			storageOutfit = (PlayerBedRef as DTSleep_OutfitContainerScript).GetOutfit(PlayerRef)
		endIf
	endIf
	
	if (PlayerSleepEquippedFormArray != None && PlayerSleepEquippedFormArray.length > 0)
	
		UndressSleepwearForActor(PlayerRef, PlayerSleepEquippedFormArray)
		
		if (PlayerBedRef != None && PlayerBedRef.HasKeyword(DTSleep_OutfitContainerKY) && (PlayerBedRef as DTSleep_OutfitContainerScript).HasStoredOutfit < 2)
			; not replacing existing sleep outfit
			if (PlayerSleepwearToRemoveSet.SleepwearItem != None && PlayerBedRef != None && PlayerBedRef.HasKeyword(DTSleep_OutfitContainerKY))
				Form[] sleepOutfitArray = new Form[1]
				sleepOutfitArray[0] = PlayerSleepwearToRemoveSet.SleepwearItem
				(PlayerBedRef as DTSleep_OutfitContainerScript).AddOutfit(sleepOutfitArray, PlayerRef, true)
			endIf
		endIf
		
		PlayerSleepEquippedFormArray.Clear()
		PlayerSleepwearToRemoveSet.DidEquip = false
		PlayerSleepwearToRemoveSet.SleepwearItem = None
	endIf
	
	if (PlayerEquippedArmorFormArray.Length == 0 && DTSleep_SettingUndressPipBoy.GetValue() > 0.0 && DTSleep_PlayerUndressed.GetValueInt() > 0)
		if (UndressedForType > 1 || DTSleep_SettingUndressPipBoy.GetValue() >= 2.0)
			DTDebug("player equip array empty! - check pip-boy", 1)
			
			if ((DTSConditionals as DTSleep_Conditionals).PipPadSlotIndex == 0 && PlayerRef.GetItemCount(Pipboy) >= 1 && !PlayerRef.IsEquipped(Pipboy))
				bool pipOK = false
				FormList pipList = (DTSleep_UndressPAlias as DTSleep_EquipMonitor).DTSleep_ArmorPipBoyList
				if (pipList != None)
					int len = pipList.GetSize()
					int i = 0
					while (i < len)
						Armor pipArmor = pipList.GetAt(i) as Armor
						if (pipArmor != None && PlayerRef.GetItemCount(pipArmor) && PlayerRef.IsEquipped(pipArmor))
							pipOK = true
							i = 100
						endIf
						
						i += 1
					endWhile
					if (!pipOK)
						DTDebug("no Pip-boy equipped! Let's equip default Pip-boy", 1)
						PlayerRef.EquipItem(Pipboy, false, true)
					endIf
				endIf
			endIf
		endIf
	endIf
	
	RedressActor(PlayerRef, PlayerEquippedArmorFormArray, slowly)
	PlayerEquippedArmorFormArray.Clear()
	
	if (storageOutfit.Length > 0)
		RedressActor(PlayerRef, storageOutfit, slowly)
	endIf
	
	; sync - wait for other thread
	int idx = 0
	while (DTSleep_CompanionUndressed.GetValue() != 0.0 && idx < 30)
		Utility.Wait(0.1)
		idx += 1
	endWhile
	; ------------ threading done ------
	
	DTSleep_PlayerUndressed.SetValue(0.0)
	
	if (DTSleep_CompanionUndressed.GetValueInt() != 0)
		DTDebug("companion time-out undress", 1)
		DTSleep_CompanionUndressed.SetValue(0.0)
		if (CompanionSleepwearToRemoveSet != None)
			CompanionSleepwearToRemoveSet.DidEquip = false
		endIf
	endIf

	DressData.SearchListsDisabled = false
	
	IsRedressing = false

	StopAll(false)
EndFunction

bool Function HandleStartForCompanionSleepwear()
	
	; begin storing in case sleepwear equip bumps armor
	bool removeClothing = true
	
	(DTSleep_UndressPAlias as DTSleep_EquipMonitor).BeginStoreCompanionEquipment(CompanionRef, CompanionSecondRef)
	
	; v1.63 - knock all off first - sleepwear may knock off nude-ring
	
	DressData.CompanionRequiresNudeSuit = false			; force ring for sleep clothes
	UndressActorCompanionDressNudeSuit(CompanionRef)
	
	; note - this may put on sleepwear beneath armor or character may have sleepwear on beneath armor
	; - fix during Undress
	CompanionSleepwearToRemoveSet = SleepwearEquipForActor(CompanionRef)
	
	DTDebug(" HandleStartCompaninSleepwear - " + CompanionSleepwearToRemoveSet, 2)
	
	if (CompanionSleepwearToRemoveSet != None && CompanionSleepwearToRemoveSet.DidEquip)
		WaitForEquipSleepwearActor(CompanionRef)
		if (CompanionSleepwearToRemoveSet.SleepwearItem != None)
			if (DTSleep_SleepAttireFullArmorList.HasForm(CompanionSleepwearToRemoveSet.SleepwearItem as Form))
				removeClothing = false
			elseIf (DTSleep_ArmorAllExceptionList.HasForm(CompanionSleepwearToRemoveSet.SleepWearItem as Form))
				removeClothing = false
			endIf
		endIf
	endIf
	
	UndressActor(CompanionRef, 1, removeClothing, false)

	if (CompanionSleepwearToRemoveSet != None && CompanionSleepwearToRemoveSet.SleepwearItem != None)
		
		if (DressData.CompanionEquippedSleepwearItem == None && !DressData.CompanionEquippedSlot58IsSleepwear && DressData.CompanionEquippedIntimateAttireItem == None)

			DTDebug(" companion has sleepWear but didn't equip during UndressActor!! - equip now", 2)
			
			
			if (DressData.CompanionNudeSuit != None)
				RedressActorRemoveNudeSuits(CompanionRef, DressData.CompanionNudeSuit, " custom nude-suit ")
			elseIf (DressData.CompanionRequiresNudeSuit)
				RedressActorRemoveNudeSuits(CompanionRef, DTSleep_NudeSuit, " nude-suit ")
			else 
				CheckRemoveAllNudeSuits(CompanionRef, false)
			endIf
			
			CompanionRef.EquipItem(CompanionSleepwearToRemoveSet.SleepwearItem)
			CompanionSleepwearToRemoveSet.DidEquip = true
		endIf
		
		return true
	endIf

	return false
endFunction

bool Function IsActorIndoors(Actor actorRef)
	if (actorRef != None)
		if (actorRef.IsInInterior())
			return true
		endIf
	endIf
	return false
EndFunction

;bool Function IsActorWearingClothingOnList(Actor actorRef, FormList list)
;	if (actorRef && list)
;		Armor item = GetArmorForActorWearingClothingOnList(actorRef, list)
;		return item as bool
;	endIf
;	return false
;endFunction

; armors including full body (33) and outer armor slots 41-45
bool Function IsActorWearingArmorAllException(Actor actorRef, bool searchList)
	if (actorRef != None)
		if (DTSleep_EquipMonInit.GetValueInt() > 0)
			if (actorRef == PlayerRef)
			
				return DressData.PlayerHasArmorAllEquipped
				
			elseIf (actorRef == CompanionRef)
				if (DressData.CompanionDressValid || DressData.CompanionDressArmorAllValid)
					return DressData.CompanionHasArmorAllEquipped
					
				elseIf (DressData.CompanionHasArmorAllEquipped && DressData.CompanionOutfitBody != None)
					if (DTSleep_ArmorAllExceptionList.HasForm(DressData.CompanionOutfitBody as Form))
						return true
					endIf
				endIf
			endIf
		endIf
		if (searchList)
			Armor item = GetArmorForActorWearingClothingOnList(actorRef, DTSleep_ArmorAllExceptionList)
			if (CompanionRef != None && actorRef == CompanionRef)
				DressData.CompanionDressArmorAllValid = true
				if (item != None)
					DressData.CompanionOutfitBody = item
					DressData.CompanionHasArmorAllEquipped
					return true
				endIf
			elseIf (item != None)
				return true
			endIf
		endIf
	endIf
	return false
endFunction

bool Function IsActorWearingIntimateItem(Actor actorRef)
	if (actorRef)
		if (DTSleep_EquipMonInit.GetValue() > 0.0)
			if (actorRef == PlayerRef)
				return DressData.PlayerEquippedIntimateAttireItem as bool
				
			elseIf (actorRef == CompanionRef && DressData.CompanionDressValid && DressData.CompanionEquippedIntimateAttireItem != None)
				if (DressData.CompanionGender == 0 && DTSleep_IntimateAttireFemaleOnlyList.HasForm(DressData.CompanionEquippedIntimateAttireItem as Form))
					DressData.CompanionEquippedIntimateAttireItem = None	; correction
					DressData.CompanionLastEquippedIntimateAttireItem = None
					return false
				endIf
				DTDebug(" companion wearing intimate outfit: " + DressData.CompanionEquippedIntimateAttireItem, 1)
				return true
			else
				Armor item = GetArmorForActorWearingClothingOnList(actorRef, DTSleep_IntimateAttireList)
				if (item != None)
					if (actorRef == CompanionRef)
						if (GetGenderForActor(actorRef) == 0 && DTSleep_IntimateAttireFemaleOnlyList.HasForm(item as Form))
							DressData.CompanionEquippedIntimateAttireItem = None	; make sure
							DressData.CompanionLastEquippedIntimateAttireItem = None
							return false
						else
							DressData.CompanionEquippedIntimateAttireItem = item
						endIf
					elseIf (CompanionSecondRef != None && CompanionSecondRef == actorRef)
						if (GetGenderForActor(actorRef) == 0 && DTSleep_IntimateAttireFemaleOnlyList.HasForm(item as Form))
							return false
						endIf
					endIf
					
					return true
				endIf
			endIf
		endIf
	endIf
	
	return false
endFunction

bool Function IsActorWearingJacket(Actor actorRef)
	if (actorRef != None)
		if (DTSleep_EquipMonInit.GetValueInt() > 0)
			if (actorRef == PlayerRef)
				;Debug.Trace(myScriptName + " PlayerEquipJacket: " + DressData.PlayerEquippedJacketItem)
				
				return DressData.PlayerEquippedJacketItem as bool
				
			elseIf (actorRef == CompanionRef && DressData.CompanionEquippedJacketItem != None)
				if (DressData.CompanionDressValid || actorRef.IsEquipped(DressData.CompanionEquippedJacketItem))
					return true
				else
					DressData.CompanionEquippedJacketItem = None
				endIf
			endIf
		endIf
		;Debug.Trace(myScriptName + " isActorWearingJacket list check " + actorRef)
		Armor item = GetArmorForActorWearingClothingOnList(actorRef, DTSleep_ArmorJacketsClothingList)
		if (item != None)
			if (actorRef == CompanionRef && DressData.CompanionActor)
				DressData.CompanionEquippedJacketItem = item
			endIf
			return true
		endIf
	endIf
	return false
endFunction

bool Function IsActorCarryingSleepwear(Actor actorRef, ObjectReference bedContainerRef = None)
	if (actorRef != None)
		if (bedContainerRef != None && bedContainerRef.HasKeyWord(DTSleep_OutfitContainerKY) && (bedContainerRef as DTSleep_OutfitContainerScript).HasStoredOutfit == 2)
			return true
			
		elseIf (DTSleep_EquipMonInit.GetValueInt() > 0)
			if (actorRef == PlayerRef)
				if (DressData.PlayerEquippedSleepwearItem != None)
					return true
				elseIf (DressData.PlayerEquippedSlot58IsSleepwear)
					return true
				elseIf (DressData.CompanionEquippedSlotFXIsSleepwear)
					return true
				endIf
			elseIf (actorRef == CompanionRef && DressData.CompanionActor)
				if (DressData.CompanionEquippedSleepwearItem != None)
					return true
				elseIf (DressData.CompanionEquippedSlot58IsSleepwear)
					return true
				elseIf (DressData.CompanionEquippedSlotFXIsSleepwear)
					return true
				endIf
			endIf
		endIf
		Armor item = None
		int gender = GetGenderForActor(actorRef)
		
		if (gender == 1)
			item = SleepwearFoundForActorFromList(actorRef, DTSleep_SleepAttireFemale)
		else
			item = SleepwearFoundForActorFromList(actorRef, DTSleep_SleepAttireMale)
		endIf
		if (item != None)
			return true
		endIf
	endIf

	return false
endFunction

bool Function IsActorWearingSleepwear(Actor actorRef)
	if (actorRef != None)
		if (DTSleep_EquipMonInit.GetValueInt() > 0)
			if (actorRef == PlayerRef)
				if (DressData.PlayerEquippedSlot58IsSleepwear)
					return true
				elseIf (DressData.PlayerEquippedSlotFXIsSleepwear)
					return true
				endIf
				return DressData.PlayerEquippedSleepwearItem as bool
				
			elseIf (actorRef == CompanionRef && DressData.CompanionActor && DressData.CompanionEquippedSleepwearItem)
				if (DressData.CompanionDressValid || actorRef.IsEquipped(DressData.CompanionEquippedSleepwearItem))
					return true
				elseIf (DressData.CompanionEquippedSlotFXIsSleepwear)
					return true
				elseIf (DressData.CompanionEquippedSlot58IsSleepwear)
					return true
				endIf
			endIf
		endIf
		Armor item = None
		int gender = GetGenderForActor(actorRef)
		
		if (gender == 1)
			item = GetArmorForActorWearingClothingOnList(actorRef, DTSleep_SleepAttireFemale)
		else
			item = GetArmorForActorWearingClothingOnList(actorRef, DTSleep_SleepAttireMale)
		endIf

		if (item != None)
			if (actorRef == CompanionRef && DressData.CompanionActor)
				DressData.CompanionEquippedSleepwearItem = item
			endIf
			
			return true
		endIf
	endIf
	
	return false
endFunction

bool Function IsActorWearingSlot41Exceptions(Actor actorRef)
	if (actorRef == None)
		Debug.Trace(myScriptName + " IsActorWearingSlot41Exceptions - actor is None!!")
		return false
	endIf

	if (DTSleep_ExtraArmorsEnabled.GetValueInt() > 0)
		if (DTSleep_EquipMonInit.GetValueInt() > 0)
			if (actorRef == PlayerRef)
				return DressData.PlayerEquippedSlot41Item as bool
			elseIf (actorRef == CompanionRef && DressData.CompanionActor && DressData.CompanionEquippedSlot41Item)
				if (DressData.CompanionDressValid || actorRef.IsEquipped(DressData.CompanionEquippedSlot41Item))
					return true
				else
					DressData.CompanionEquippedSlot41Item = None
				endIf
			endIf
		endIf
		Armor item = GetArmorForActorWearingClothingOnList(actorRef, DTSleep_ArmorSlot41List)
		if (item)
			if (actorRef == CompanionRef && DressData.CompanionActor)
				DressData.CompanionEquippedSlot41Item = item
			endIf
			return true
		endIf
	endIf
	return false
endFunction

bool Function IsActorWearingSlot55Exceptions(Actor actorRef)
	if (actorRef == None)
		Debug.Trace(myScriptName + " IsActorWearingSlot55Exceptions - actor is None!!")
		return false
	endIf
	
	if (DTSleep_ExtraArmorsEnabled.GetValueInt() > 0)
		if (DTSleep_EquipMonInit.GetValueInt() > 0)
			if (actorRef == PlayerRef)
				return DressData.PlayerEquippedSlot55Item as bool
			elseIf (actorRef == CompanionRef)
				if (DressData.CompanionEquippedSlot55Item != None)
					if (DressData.CompanionDressValid || DressData.CompanionDressArmorExtendedValid || actorRef.IsEquipped(DressData.CompanionEquippedSlot55Item))
						return true
					else
						DressData.CompanionEquippedSlot55Item = None
					endIf
				elseIf (DressData.CompanionDressArmorExtendedValid)
					return false
				endIf
			endIf
		endIf
		Armor item = GetArmorForActorWearingClothingOnList(actorRef, DTSleep_ArmorSlot55List)
		if (item != None)
			if (actorRef == CompanionRef)
				if (DTSleep_StrapOnList.HasForm(item as Form))
					DressData.CompanionEquippedStrapOnItem = item
				else
					DressData.CompanionEquippedSlot55Item = item
				endIf
			endIf
			
			return true
		endIf
	endIf
	
	return false
endFunction

bool Function IsActorWearingSlot58Exceptions(Actor actorRef)
	if (actorRef == None)
		Debug.Trace(myScriptName + " IsActorWearingSlot58Exceptions - actor is None!!")
		return false
	endIf
	
	if ((DTSConditionals as DTSleep_Conditionals).IsAWKCRActive)
		if ((DTSConditionals as DTSleep_Conditionals).AWKCRPiercingKW != None)
			if (actorRef.WornHasKeyword((DTSConditionals as DTSleep_Conditionals).AWKCRPiercingKW))
				return true
			endIf
		endIf
	endIf
	
	if (DTSleep_ExtraArmorsEnabled.GetValueInt() > 0)
		if (DTSleep_EquipMonInit.GetValueInt() > 0 && DressData)
			if (actorRef == PlayerRef)
				
				return DressData.PlayerEquippedSlot58Item as bool
				
			elseIf (actorRef == CompanionRef)
				if (DressData.CompanionEquippedSlot58Item != None)
					if (DressData.CompanionDressValid || DressData.CompanionDressArmorExtendedValid || actorRef.IsEquipped(DressData.CompanionEquippedSlot58Item))
						return true
					else
						DressData.CompanionEquippedSlot58Item = None
					endIf
				elseIf (DressData.CompanionDressArmorExtendedValid)
					return false
				endIf
			endIf
		endIf
		;Debug.Trace(myScriptName + " slot58 check list")
		
		Armor item = GetArmorForActorWearingClothingOnList(actorRef, DTSleep_ArmorSlot58List)
		if (item != None)
			if (actorRef == CompanionRef && DressData.CompanionActor)
				DressData.CompanionEquippedSlot58Item = item
			endIf
			return true
		endIf
	endIf
	
	return false
endFunction

bool Function IsActorWearingSlot61Exceptions(Actor actorRef)
	if (actorRef == None)
		Debug.Trace(myScriptName + " IsActorWearingSlot61Exceptions - actor is None!!")
		return false
	endIf

	if (DTSleep_ExtraArmorsEnabled.GetValueInt() > 0)
		if (DTSleep_EquipMonInit.GetValueInt() > 0)
			if (actorRef == PlayerRef)
				return DressData.PlayerEquippedSlotFXItem as bool
				
			elseIf (actorRef == CompanionRef)
				if (DressData.CompanionEquippedSlotFXItem != None)
					if (DressData.CompanionDressValid || DressData.CompanionDressArmorExtendedValid || actorRef.IsEquipped(DressData.CompanionEquippedSlotFXItem))
						return true
					else
						DressData.CompanionEquippedSlotFXItem = None
					endIf
				elseIf (DressData.CompanionDressArmorExtendedValid)
					return false
				endIf
			endIf
		endIf
		
		Armor item = GetArmorForActorWearingClothingOnList(actorRef, DTSleep_ArmorSlotFXList)
		if (item != None)
			if (actorRef == CompanionRef && DressData.CompanionActor)
				DressData.CompanionEquippedSlotFXItem = item
			endIf
			
			return true
		endIf
	endIf
	
	return false
EndFunction

bool Function PlaceFormItemAtActorFeet(Form item, Actor atActor)
	if (item && atActor)
		if (!PlacedArmorObjRefArray)
			PlacedArmorObjRefArray = new ObjectReference[0]
		endIf
		
		ObjectReference placedObjRef = DTSleep_CommonF.PlaceFormAtObjectRef(item, atActor)
		
		if (placedObjRef)
			PlacedArmorObjRefArray.Add(placedObjRef)
			return true
		endIf
	endIf
	return false
endFunction

bool Function PlaceFormItemAtBed(Form item, ObjectReference bedRef, Actor fromActor, int cornerVal = 0)
	bool result = false
	if (bedRef != None && item != None && fromActor != None)
		;Debug.Trace(myScriptName + "  PlaceArmorItemAtBed: " + bedRef + ", item: " + item + " actor: " + fromActor)
		
		if (PlacedArmorObjRefArray == None)
			PlacedArmorObjRefArray = new ObjectReference[0]
		endIf
		
		Point3DOrient placeBedPoint = PlacePointAtBed(bedRef, fromActor, cornerVal)
		Point3DOrient bedPoint = PointOfObject(bedRef)
		placeBedPoint.X += bedPoint.X
		placeBedPoint.Y += bedPoint.Y
		placeBedPoint.Z += bedPoint.Z
		
		ObjectReference mainNodeRef = PlaceFormAtObjectRef(DTSleep_DummyNode, fromActor)
		
		if (mainNodeRef != None)
			; smoother to place object at node instead of place-and-move
			
			mainNodeRef.SetAngle(0.0, 0.0, placeBedPoint.Heading)
			mainNodeRef.SetPosition(placeBedPoint.X, placeBedPoint.Y, placeBedPoint.Z)
		
			ObjectReference placedObjRef = DTSleep_CommonF.PlaceFormAtObjectRef(item, mainNodeRef)
			
			if (placedObjRef != None)
				;Debug.Trace(myScriptName + "  placing armor item relative to bed at X,Y,Z " + Point3DOrientToString(placeBedPoint))
				placedObjRef.SetMotionType(placedObjRef.Motion_Keyframed) ; keep item from getting kicked about
				PlacedArmorObjRefArray.Add(placedObjRef)
				
				result = true
			endIf
		endIf
		DTSleep_CommonF.DisableAndDeleteObjectRef(mainNodeRef, false)
	endIf
	return result
EndFunction

bool Function PlaceFormNearFeet(Form item, Actor actorRef)
	bool result = false
	if (item != None && actorRef != None)
	
		if (PlacedArmorObjRefArray == None)
			PlacedArmorObjRefArray = new ObjectReference[0]
		endIf
		
		ObjectReference mainNodeRef = PlaceFormAtObjectRef(DTSleep_DummyNode, actorRef)
		
		if (mainNodeRef != None)
			; better to place node first then place object at node to prevent getting kicked
			Point3DOrient actorPoint = DTSleep_CommonF.PointOfObject(actorRef)
			Point3DOrient packPoint = DTSleep_CommonF.GetPointXDistOnHeading(actorPoint, 40.8)	;offset
			packPoint.X += actorPoint.X
			packPoint.Y += actorPoint.Y
			packPoint.Z += actorPoint.Z
			packPoint.Heading = Utility.RandomFloat(87.0, 93.0) + packPoint.Heading
			mainNodeRef.SetAngle(0.0, 0.0, packPoint.Heading)
			mainNodeRef.SetPosition(packPoint.X, packPoint.Y, packPoint.Z)
			
			ObjectReference placedObjRef = DTSleep_CommonF.PlaceFormAtObjectRef(item, mainNodeRef)
			
			if (placedObjRef != None)
				;Debug.Trace(myScriptName + " place at feet, item " + item + " at " + packPoint + " from actor at " + actorPoint)
				
				placedObjRef.SetMotionType(placedObjRef.Motion_Keyframed) ; keep item from getting kicked about
				PlacedArmorObjRefArray.Add(placedObjRef)
				
				result = true
			endIf
		endIf
		
		DTSleep_CommonF.DisableAndDeleteObjectRef(mainNodeRef, false)
	endIf
	return result
endFunction

Point3DOrient Function PlacePointAtBed(ObjectReference bedRef, Actor fromActor, int cornerVal)

	Point3DOrient placeBedPoint = new Point3DOrient
	if (bedRef && fromActor)
		Point3DOrient ptBed = DTSleep_CommonF.PointOfObject(bedRef)
		Point3DOrient ptActor = DTSleep_CommonF.PointOfObject(fromActor)
		if (cornerVal == 0)
			placeBedPoint = DTSleep_CommonF.GetPointBedArmorPlaceAtFoot(ptBed, ptActor)
		elseIf (cornerVal < 0)
			float xOff = 0.0
			float yOff = 0.0		; some chairs are backward so would need to reverse

			if ((DTSleep_IntimateAnimQuestP as DTSleep_IntimateAnimQuestScript).IsObjBenchSofa(bedRef, None))	
				xOff = 22.0
			endIf
			placeBedPoint = DTSleep_CommonF.GetPointSeatPlace(ptBed, ptActor, xOff, yOff)
		else
			placeBedPoint = DTSleep_CommonF.GetPointBedArmorPlaceAtHead(ptBed, ptActor)
		endIf
	endIf
	
	return placeBedPoint
endFunction

bool Function RedressActorRemoveNudeSuits(Actor actorRef, Armor nudeGear, string nudeArmorString = "", bool doUnequip = true)
	if (actorRef != None && nudeGear != None)
	
		int count = actorRef.GetItemCount(nudeGear)
		if (count > 0)

			DTDebug(" removing nudeGear " + count + " " + nudeArmorString + " from " + actorRef, 2)

			if (doUnequip)
				actorRef.UnequipItem(nudeGear, true, true)
			endIf
			actorRef.RemoveItem(nudeGear, count, true, None)
			
			return true
		endIf
	endIf
	
	return false
endFunction

Function RedressActor(Actor actorRef, Form[] equippedFormArray, bool slowly = true)
	if (actorRef == None)
		return
	endIf
	
	; v1.61
	if (actorRef == PlayerRef)
	
		;v1.96 - disable menu controls until done
		if (UndressInputLayer == None)
			UndressInputLayer = InputEnableLayer.Create()
			;SleepInputLayer  disable activate    move,  fight, camSw, look, snk, menu, act, journ, Vats, Favs, run
			UndressInputLayer.DisablePlayerControls(false, false, true, false, false, true, true, true, false, false, false)
		endIf
	
		if (DTSleep_SettingAltFemBody.GetValueInt() >= 1 && AltFemBodyEnabled && GetGenderForActor(actorRef) == 1 && PlayerRef.GetItemCount(DTSleep_AltFemNudeBody) > 0)
			RedressActorRemoveNudeSuits(actorRef, DTSleep_AltFemNudeBody, " player Alt-Fem nude-suit", true)
		elseIf (PlayerRef.GetItemCount(DTSleep_PlayerNudeRing) > 0)
			RedressActorRemoveNudeSuits(actorRef, DTSleep_PlayerNudeRing, " player nude-ring", true)
		endIf
		;v1.81
		if (UndressedForType >= 5)
			if (PlayerRef.GetItemCount(DTSleep_PlayerNudeBodyNoPipBoy) > 0)
				RedressActorRemoveNudeSuits(actorRef, DTSleep_PlayerNudeBodyNoPipBoy, " player nude-body-noPip", true)
			else
				DTDebug("no nude-suit pip-boy found to remove...", 1)
			endIf
		endIf
		
	elseIf (actorRef == CompanionRef)
		if (DTSleep_SettingAltFemBody.GetValueInt() >= 1 && AltFemBodyEnabled && GetGenderForActor(actorRef) == 1 && actorRef.GetItemCount(DTSleep_AltFemNudeBody) > 0)
			RedressActorRemoveNudeSuits(actorRef, DTSleep_AltFemNudeBody, " player alt-fem nude-suit", true)
		elseIf (DressData.CompanionNudeSuit != None)
			RedressActorRemoveNudeSuits(CompanionRef, DressData.CompanionNudeSuit, " custom nude-suit ")
		else
			CheckRemoveAllNudeSuits(CompanionRef, false)
		endIf
	elseIf (CompanionSecondRef != None && CompanionSecondRef == actorRef)
		CheckRemoveAllNudeSuits(actorRef, false)
	endIf

	Utility.WaitMenuMode(0.1)
	int arrayLen = equippedFormArray.Length
	int i = arrayLen - 1
	int bt2Val = DTSleep_SettingUseBT2Gun.GetValueInt()
	DTDebug("  redress " + actorRef + " equip Len: " + (i + 1) + " slowly: " + slowly, 2)

	; equip by array
	
	while (i >= 0 )

		bool equipOK = false
		if (equippedFormArray.Length < i)
			DTDebug("WARNING! redress array (length " + arrayLen + ") disappeared! at index " + i, 1)

			return
		endIf
		Armor item = equippedFormArray[i] as Armor
		
		;Utility.WaitMenuMode(0.04)
		
		if (item != None)
			
			;Debug.Trace(myScriptName + " item to equip: " + item + " for " + actorRef)
			
			; if nude-suit knocked off into list, remove without un-equip
			if (item == DTSleep_PlayerNudeRing)
				RedressActorRemoveNudeSuits(actorRef, DTSleep_PlayerNudeRing, " player nude-ring", false)
			elseIf (item == DTSleep_NudeRing)
				RedressActorRemoveNudeSuits(actorRef, DTSleep_NudeRing, " nude ring ", false)
			elseIf (item == DTSleep_NudeSuit)
				RedressActorRemoveNudeSuits(actorRef, DTSleep_NudeSuit, " nude suit ", false)
			elseIf (item == DTSleep_NudeRingArmorOuter)
				RedressActorRemoveNudeSuits(actorRef, DTSleep_NudeRingArmorOuter, " nude ring armor-outer ", false)
			elseIf (item == DTSleep_NudeRingNoHands)
				RedressActorRemoveNudeSuits(actorRef, DTSleep_NudeRingNoHands, " nude ring-no-hands ", false)
			elseIf (item == DressData.CompanionNudeSuit)
				RedressActorRemoveNudeSuits(actorRef, DressData.CompanionNudeSuit, " custom nude suit ", false)
			elseIf (item == DTSleep_NudeSuitPlayerUp)
				RedressActorRemoveNudeSuits(actorRef, DTSleep_NudeSuitPlayerUp, " playerNudeSuit-Up", false)
			elseIf (item == DTSleep_LeitoGunNudeUp_UP)
				RedressActorRemoveNudeSuits(actorRef, DTSleep_LeitoGunNudeUp_UP, " LeitoGunUP-Up", false)
			elseIf (item == DTSleep_NudeSuitPlayerForw)
				RedressActorRemoveNudeSuits(actorRef, DTSleep_NudeSuitPlayerForw, " playerNudeSuit-Forw", false)
			elseIf (item == DTSleep_LeitoGunNudeUp_Forw)
				RedressActorRemoveNudeSuits(actorRef, DTSleep_LeitoGunNudeUp_Forw, " LeitoGunUP-Forw", false)
			elseIf (item == DTSleep_PlayerNudeBodyNoPipBoy)
				; v2.13 -- ensure remove / avoid putting back
				DTDebug("nude-suit no-Pip-Boy in equip-list... skip/remove now", 1)
				RedressActorRemoveNudeSuits(actorRef, DTSleep_PlayerNudeBodyNoPipBoy, " player nude-suit no-pip-boy ", false)
			elseIf (item == DTSleep_AltFemNudeBody)
				; v2.13
				RedressActorRemoveNudeSuits(actorRef, DTSleep_AltFemNudeBody, " alt-fem-body ", false)
			elseIf (bt2Val > 0 && item == (DTSleep_BT2GunList.GetAt(0) as Armor))
				RedressActorRemoveNudeSuits(actorRef, (DTSleep_BT2GunList.GetAt(0) as Armor), " BT2NudeSuit-Forw", false)
			elseIf (bt2Val > 0 && item == (DTSleep_BT2GunList.GetAt(1) as Armor))
				RedressActorRemoveNudeSuits(actorRef, (DTSleep_BT2GunList.GetAt(1) as Armor), " BT2NudeSuite-Up", false)
			elseIf (bt2Val > 0 && item == (DTSleep_BT2GunList.GetAt(2) as Armor))
				RedressActorRemoveNudeSuits(actorRef, (DTSleep_BT2GunList.GetAt(2) as Armor), " BT2NudeSuite-Down", false)
			else
			
				actorRef.EquipItem(item, false, true)
				equipOK = true
			endIf
		else
			ObjectReference armorRef = equippedFormArray[i] as ObjectReference
			
			if (armorRef != None)
				Utility.WaitMenuMode(0.1)
				
				;DTDebug(" armorRef to equip: " + armorRef, 2)
				
				if (armorRef.Is3DLoaded())
					
					actorRef.EquipItem(armorRef, false, true)
					equipOK = true
				else
					DTDebug(" no 3D! on ObjRef: " + armorRef + " - get base object", 1)
					
					; does this cause problems?
					; this returns a non-armor inventory item form that appears correct on character
					; TestMode-only -- not equipping 
					;
					if (DTSleep_SettingTestMode.GetValueInt() > 0)
					
						Form baseForm = armorRef.GetBaseObject()
						if (baseForm != None)
							DTDebug(" found baseForm: " + baseForm, 2)
							
							Armor baseArmor = baseForm as Armor
							if (baseArmor)
								DTDebug(" found base objectArmor: " + baseArmor, 2)

								; not equipping
							;	actorRef.EquipItem(baseArmor, false, true)
							
							else
								DTDebug( " not armor - no equip!", 1)
							endIf
						endIf
					endIf
					; end testMode-only
				endIf
			else
				DTDebug(" armorREf is none! ", 1)
			endIf
		endIf
		
		if (slowly && i >= 2 && i <= 3)
			; slow for final 3 items as if taking time to dress
			Utility.WaitMenuMode(0.24)
		elseIf (i == 1)
			; always pause before final piece
			Utility.WaitMenuMode(0.5)
		elseIf (slowly && i > (equippedFormArray.Length - 3))
			; slow for first 2 items
			Utility.WaitMenuMode(0.32)
		endIf
		
		i -= 1
	endWhile
	
	Utility.WaitMenuMode(0.08)
	if (actorRef == PlayerRef)
		UndressInputLayer.EnablePlayerControls()
		UndressInputLayer.Delete()
		UndressInputLayer = None
	endIf
	
	if (EnableCarryBonusRemove && DTSleep_UndressCarryWeight && actorRef == PlayerRef && PlayerRef.HasSpell(DTSleep_UndressCarryWeight))
		
		Utility.Wait(0.3)
		PlayerRef.RemoveSpell(DTSleep_UndressCarryWeight)
	endIf
	
	EnableCarryBonusRemove = true	; always toggle back 
	
EndFunction

Function RemovePlacedItems()
	if PlacedArmorObjRefArray
		int len = PlacedArmorObjRefArray.length
		DTDebug("  removing decoration count: " + len, 2)
		
		int idx = 0
		while (idx < len)
			ObjectReference decorationRef = PlacedArmorObjRefArray[idx]
			DisableAndDeleteObjectRef(decorationRef, true)
			idx += 1
		endWhile
		PlacedArmorObjRefArray.Clear()
	endIf
	PlacedArmorObjRefArray = None
EndFunction

Function ResetCompanionDressData()

	DressData.CompanionActor = None
	DressData.CompanionDressValid = false
	DressData.CompanionDressArmorAllValid = false
	DressData.CompanionDressArmorExtendedValid = false
	DressData.CompanionGender = -1
	DressData.CompanionRequiresNudeSuit = true
	DressData.CompanionNudeSuit = None
	DressData.CompanionBackPackNoGOModel = false
	DressData.CompanionHasExtraPartsEquipped = false
	DressData.CompanionHasExtraClothingEquipped = false
	DressData.CompanionEquippedBackpackItem = None
	DressData.CompanionEquippedJacketItem = None
	DressData.CompanionEquippedSleepwearItem = None
	DressData.CompanionEquippedSlot41Item = None
	DressData.CompanionEquippedSlot55Item = None
	DressData.CompanionEquippedSlot58Item = None
	DressData.CompanionEquippedSlotFXItem = None
	DressData.CompanionEquippedStrapOnItem = None
	DressData.CompanionHat = None
	DressData.CompanionChokerItem = None
	DressData.CompanionNecklaceItem = None
	DressData.CompanionOutfitBody = None
	DressData.CompanionEquippedMask = None
	DressData.CompanionEquippedGlassesItem = None
	DressData.CompanionEquippedCarryPouchItem = None
	DressData.CompanionEquippedSlot58IsSleepwear = false
	DressData.CompanionLastSlotFXIsSleepwear = false
	
	DressData.CompanionLastEquippedBackpackItem = None
	DressData.CompanionEquippedIntimateAttireItem = None
	DressData.CompanionLastEquippedIntimateAttireItem = None
	DressData.CompanionLastEquippedJacketItem = None
	DressData.CompanionLastEquippedSlot58Item = None
	DressData.CompanionLastEquippedSlot41Item = None
	DressData.CompanionEquippedSlotFXIsSleepwear = false
	DressData.CompanionLastSlot58IsSleepwear = false
	DressData.CompanionLastEquippedStrapOnItem = None
	DressData.CompanionLastEquippedGlassesItem = None
	DressData.CompanionHasArmorAllEquipped = false
	DressData.CompanionCustomRestrictSlot = -1
	DressData.CompanionLastEquippedSleepwearItem = None
	DressData.CompanionLastEquippedSlot55Item = None
	DressData.CompanionLastEquippedSlotFXItem = None

endFunction

Function ResetPlayerDressData()
	DressData.PlayerBackPackNoGOModel = false
	DressData.PlayerHasArmorAllEquipped = false
	DressData.PlayerHasExtraClothingEquipped = false
	DressData.PlayerHasExtraPartsEquipped = false
	DressData.PlayerEquippedSlot58IsSleepwear = false
	DressData.PlayerEquippedSlotFXIsSleepwear = false
	
	; upgrade v1.81 check - custom player lists may have pip-boy added by custom equip such as Holoboy or mod allowing equip/un-equip
	FormList pipList = (DTSleep_UndressPAlias as DTSleep_EquipMonitor).DTSleep_ArmorPipBoyList
	
	if (pipList != None)
		int len = pipList.GetSize()
		int i = 0
		while (i < len)
			Form pipForm = pipList.GetAt(i)
			if (pipForm != None)
				if (DTSleep_ArmorBackPacksList.HasForm(pipForm))
					DTDebug("removing Pip-boy " + pipForm + " from Backpack list", 1)
					DTSleep_ArmorBackPacksList.RemoveAddedForm(pipForm)
				endIf
				if (DTSleep_ArmorExtraPartsList.HasForm(pipForm))
					DTDebug("removing Pip-boy " + pipForm + " from Extra Parts list", 1)
					DTSleep_ArmorExtraPartsList.RemoveAddedForm(pipForm)
				endIf
				if (DTSleep_ArmorJacketsClothingList.HasForm(pipForm))
					DTDebug("removing Pip-boy " + pipForm + " from Jackets list", 1)
					DTSleep_ArmorJacketsClothingList.RemoveAddedForm(pipForm)
				endIf
				if (DTSleep_ArmorMaskList.HasForm(pipForm))
					DTDebug("removing Pip-boy " + pipForm + " from Masks list", 1)
					DTSleep_ArmorMaskList.RemoveAddedForm(pipForm)
				endIf
				if (DTSleep_SleepAttireFemale.HasForm(pipForm))
					DTDebug("removing Pip-boy " + pipForm + " from SleepAttire list", 1)
					DTSleep_SleepAttireFemale.RemoveAddedForm(pipForm)
				endIf
				if (DTSleep_SleepAttireMale.HasForm(pipForm))
					DTDebug("removing Pip-boy " + pipForm + " from SleepAttire list", 1)
					DTSleep_SleepAttireMale.RemoveAddedForm(pipForm)
				endIf
				if (DTSleep_IntimateAttireList.HasForm(pipForm))
					DTDebug("removing Pip-boy " + pipForm + " from Intimate list", 1)
					DTSleep_IntimateAttireList.RemoveAddedForm(pipForm)
				endIf
				if (DTSleep_StrapOnList.HasForm(pipForm))
					DTDebug("removing Pip-boy " + pipForm + " from StrapOn list", 1)
					DTSleep_StrapOnList.RemoveAddedForm(pipForm)
				endIf
			endIf
			
			i += 1
		endWhile
	
	endif
endFunction

Function SetInitEquipMon()
	;if (DTSleep_ExtraArmorsEnabled.GetValueInt() > 0)
	;	
	;	DTSleep_EquipMonInit.SetValue(2.0)
	;else
	;	DTSleep_EquipMonInit.SetValue(1.0)
	;endIf
	DressData.PlayerHasArmorAllEquipped = false
	DressData.CompanionHasArmorAllEquipped = false
	
	DTSleep_EquipMonInit.SetValue(5.0) ;v1.65
	
	if (DressData.PlayerGender < 0)
		int gender = GetGenderForActor(PlayerRef)
		DressData.PlayerGender = gender
	endIf
	
	if ((DTSConditionals as DTSleep_Conditionals).PipPadSlotIndex >= 100.0)
		SetPlayerPipPadIndex()
	endIf
	
endFunction

Function SetPlayerCarryWeightBonus()
	
	if (EnableCarryBonus && DTSleep_UndressCarryBonus.GetValue() > 0.0)
		; need a long delay so add anyway
		;if (PlayerRef.IsOverEncumbered())
		
			if (DTSleep_UndressCarryWeight != None && !PlayerRef.HasSpell(DTSleep_UndressCarryWeight))
				
				if (PlayerRef.AddSpell(DTSleep_UndressCarryWeight, false) == false)

					Debug.Trace(myScriptName + " failed add carry bonus spell!!! ")
				endIf
			endIf
		;endIf
	endIf
endFunction

int Function SetPlayerPipPadIndex()
	
	bool foundPipPad = false
	int index = DTSleep_ArmorPipPadList.GetSize() - 1
	(DTSConditionals as DTSleep_Conditionals).PipPadSlotIndex = 0    ; reset
	(DTSConditionals as DTSleep_Conditionals).PipPadListIndex = 0  ; reset
	
	while (index >= 0 && !foundPipPad)
	
		Armor pipPad = DTSleep_ArmorPipPadList.GetAt(index) as Armor
		if (pipPad != None)
			if (PlayerRef.GetItemCount(pipPad) > 0)
			
				(DTSConditionals as DTSleep_Conditionals).PipPadSlotIndex = GetPipPadSlotIndexByListIndex(index)
				(DTSConditionals as DTSleep_Conditionals).PipPadListIndex = index
				
				index = -1   ; cancel
			endIf
			
		endIf
	
		index -= 1
	endWhile
	
	return (DTSConditionals as DTSleep_Conditionals).PipPadSlotIndex
endFunction

int Function GetPipPadSlotIndexByListIndex(int listIndex)
	;  Ascending order starting with 51
	;pippad = Game.GetFormFromFile(0x12005BA6, pippadName) as Armor   ; 54
	;pippad = Game.GetFormFromFile(0x12005BA7, pippadName) as Armor   ; 55
	;pippad = Game.GetFormFromFile(0x12005BA8, pippadName) as Armor   ; 56
	;pippad = Game.GetFormFromFile(0x12005BA9, pippadName) as Armor   ; 57
	;pippad = Game.GetFormFromFile(0x12005BAA, pippadName) as Armor   ; 58
	;pippad = Game.GetFormFromFile(0x12005BAB, pippadName) as Armor   ; 61 - default
	
	if (listIndex == 0)
		return 21
	elseIf (listIndex >= 1 && listIndex <= 5)
		return listIndex + 23
	elseIf (listIndex == 6)
		return 31
	endIf
	
	return -1
endFunction

bool Function RaceRestrictedSlot58(actor actorRef)

	if (actorRef == PlayerRef && (DTSConditionals as DTSleep_Conditionals).IsVulpineRacePlayerActive)
		return true 
	elseIf (actorRef == CompanionRef && DressData.CompanionCustomRestrictSlot == 58)
		return true
	endIf

	return false
endFunction

; return DidEquip true if equipped an item; false if wearing an item or none
;
SleepwearEquipSet Function SleepwearEquipForActor(Actor actorRef)

	SleepwearEquipSet result = new SleepwearEquipSet

	if (actorRef != None)
		
		if (DTSleep_EquipMonInit.GetValueInt() > 0)
		
			if (actorRef == PlayerRef)
			
				if (DressData.PlayerEquippedIntimateAttireItem != None)
					; intimate clothing preferred over sleep clothing
					
					return result
				else
				
					if (DressData.PlayerEquippedSleepwearItem != None || DressData.PlayerEquippedStrapOnItem != None)
						; already wearing sleepwear
						
						result.SleepwearItem = DressData.PlayerEquippedSleepwearItem
						result.DidEquip = false
						
						if (result.SleepwearItem != None && PlayerBedRef != None && PlayerBedRef.HasKeyword(DTSleep_OutfitContainerKY))
							; v1.58 - using storage bed, must mark to put away on redress
							PlayerSleepEquippedFormArray.Add(result.SleepwearItem, 1)
						endIf
						
						return result
						
					elseIf (DressData.PlayerEquippedSlot58IsSleepwear)
						
						result.SleepwearItem = DressData.PlayerEquippedSlot58Item
						result.DidEquip = false
						
						if (result.SleepwearItem != None && PlayerBedRef != None && PlayerBedRef.HasKeyword(DTSleep_OutfitContainerKY))
							; v1.58 - using storage bed, must mark to put away on redress
							PlayerSleepEquippedFormArray.Add(result.SleepwearItem, 1)
						endIf
						
						return result
						
					elseIf (DressData.PlayerEquippedSlotFXIsSleepwear)
					
						result.SleepwearItem = DressData.PlayerEquippedSlotFXItem
						result.DidEquip = false
						
						if (result.SleepwearItem != None && PlayerBedRef != None && PlayerBedRef.HasKeyword(DTSleep_OutfitContainerKY))
							; v1.58 - using storage bed, must mark to put away on redress
							PlayerSleepEquippedFormArray.Add(result.SleepwearItem, 1)
						endIf
						
						return result
						
					elseIf (DressData.PlayerLastEquippedSleepwearItem != None)
						
						Armor sleepWear = DressData.PlayerLastEquippedSleepwearItem
						
						; check storage first even if different item
						if (PlayerBedRef != None && PlayerBedRef.HasKeyword(DTSleep_OutfitContainerKY))
						
							if ((PlayerBedRef as DTSleep_OutfitContainerScript).HasStoredOutfit == 2)
								; has a stored sleep outfit - use it
								Form[] storageOutfit = (PlayerBedRef as DTSleep_OutfitContainerScript).GetOutfit(PlayerRef)
								if (storageOutfit != None && storageOutfit.Length > 0)
									
									result.SleepwearItem = storageOutfit[0] as Armor
									if (result.SleepwearItem != None)
										result.DidEquip = true

										actorRef.EquipItem(result.SleepwearItem, false, true)
										PlayerSleepEquippedFormArray.Add(result.SleepwearItem, 1)
										
										return result
									endIf
								endIf
							endIf
							; search storage for last item
							if (sleepWear != None && PlayerBedRef.GetItemCount(sleepWear) > 0)
								
								PlayerBedRef.RemoveItem(sleepWear, 1, true, PlayerRef)
								result.SleepwearItem = sleepWear
								result.DidEquip = true

								actorRef.EquipItem(sleepWear, false, true)
								PlayerSleepEquippedFormArray.Add(sleepWear, 1)
								Utility.WaitMenuMode(0.1)
								
								return result
							endIf
						endIf
						
						; now check actor
						if (sleepWear != None && actorRef.GetItemCount(sleepWear) > 0)
							result.SleepwearItem = sleepWear
							result.DidEquip = true

							actorRef.EquipItem(sleepWear, false, true)
							PlayerSleepEquippedFormArray.Add(sleepWear, 1)
							Utility.WaitMenuMode(0.1)
							
							return result
							
						endIf
					endIf
				endIf
				
				if (DressData.PlayerLastEquippedSlot58Item != None && DressData.PlayerLastEquippedSlot58IsSleepwear)
					Armor sleepWear = DressData.PlayerLastEquippedSlot58Item
					
					if (sleepWear != None && actorRef.GetItemCount(sleepWear) > 0)
						result.SleepwearItem = sleepWear
						result.DidEquip = true
						actorRef.EquipItem(sleepWear, false, true)
						PlayerSleepEquippedFormArray.Add(sleepWear, 1)
						Utility.WaitMenuMode(0.1)
						
						return result
					
					elseIf (sleepWear != None && PlayerBedRef != None && PlayerBedRef.HasKeyword(DTSleep_OutfitContainerKY))
						
						if (PlayerBedRef.GetItemCount(sleepWear) > 0)
							
							PlayerBedRef.RemoveItem(sleepWear, 1, true, PlayerRef)
							result.SleepwearItem = sleepWear
							result.DidEquip = true

							actorRef.EquipItem(sleepWear, false, true)
							PlayerSleepEquippedFormArray.Add(sleepWear, 1)
							Utility.WaitMenuMode(0.1)
							
							return result
						endIf
					endIf
				endIf
				
			elseIf (actorRef == CompanionRef && DressData.CompanionActor != None)
			
				if (DressData.CompanionEquippedIntimateAttireItem != None)
					; prefer intimate
					if (DressData.CompanionDressValid || actorRef.IsEquipped(DressData.CompanionEquippedIntimateAttireItem))
						
						if (DressData.CompanionGender == 0 && DTSleep_IntimateAttireFemaleOnlyList.HasForm(DressData.CompanionEquippedIntimateAttireItem as Form))
							DressData.CompanionEquippedIntimateAttireItem = None	; correction
							DressData.CompanionLastEquippedIntimateAttireItem = None
						else
							return result
						endIf
					endIf
				endIf
				
				if (DressData.CompanionEquippedSleepwearItem != None)
					
					if (actorRef.GetItemCount(DressData.CompanionEquippedSleepwearItem) > 0)
						
						result.SleepwearItem = DressData.CompanionEquippedSleepwearItem
						
						if (DressData.CompanionDressValid || actorRef.IsEquipped(DressData.CompanionEquippedSleepwearItem))
							
							result.DidEquip = false
							
							return result
						endIf

						; force sleepwear no-unequip
						actorRef.EquipItem(DressData.CompanionEquippedSleepwearItem, true, true)
						CompanionSleepEquippedFormArray.Add(DressData.CompanionEquippedSleepwearItem, 1)
						result.DidEquip = true
						Utility.WaitMenuMode(0.1)
						
						return result
					else
						DressData.CompanionEquippedSleepwearItem = None
					endIf
					
				elseIf (DressData.CompanionLastEquippedSleepwearItem != None)
				
					if (actorRef.GetItemCount(DressData.CompanionLastEquippedSleepwearItem) > 0)
					
						result.SleepwearItem = DressData.CompanionLastEquippedSleepwearItem
						result.DidEquip = true
						DTDebug("SleepEquip from DressData-Last " + result.SleepWearItem + " on companion " + actorRef, 2)
						; force equip prevent remove
						actorRef.EquipItem(DressData.CompanionLastEquippedSleepwearItem, true, true)
						CompanionSleepEquippedFormArray.Add(DressData.CompanionLastEquippedSleepwearItem, 1)
						Utility.WaitMenuMode(0.1)
						
						return result
					endIf
					
				elseIf (DressData.CompanionEquippedStrapOnItem != None)
				
					if (actorRef.GetItemCount(DressData.CompanionEquippedStrapOnItem) > 0)
						if (actorRef.IsEquipped(DressData.CompanionEquippedStrapOnItem))
							return result
						endIf
					else
						DressData.CompanionEquippedStrapOnItem = None
					endIf
				endIf
			endIf
		endIf
		
		result = SleepwearEquipForActorFromList(actorRef, SleepWearListForActor(actorRef))
	endIf
	
	return result
EndFunction

FormList Function SleepWearListForActor(Actor actorRef)
	if (actorRef != None)
		int gender = GetGenderForActor(actorRef)
		if (gender == 1)
			return DTSleep_SleepAttireFemale
		endIf
		return DTSleep_SleepAttireMale
	endIf
	return None
endFunction

SleepwearEquipSet Function SleepwearEquipForActorFromList(Actor actorRef, FormList fromSleepwearList)

	SleepwearEquipSet result = new SleepwearEquipSet

	if (actorRef != None && fromSleepwearList != None)
	
		Armor item = GetArmorForActorWearingClothingOnList(actorRef, fromSleepwearList)
		if (item != None)
			; wearing sleep clothes so not equipping
			result.SleepwearItem = item
			result.DidEquip = false
			
			return result
		endIf
		
		item = GetArmorForActorWearingClothingOnList(actorRef, DTSleep_StrapOnList)
		if (item)
			; wearing a strap-on, consider sleepwear
			
			return result
		endIf
		
		Armor armorItem = SleepwearFoundForActorFromList(actorRef, fromSleepwearList)
		
		if (armorItem != None)
		
			if (RaceRestrictedSlot58(actorRef))
			
				if (DTSleep_ArmorSlot58List.HasForm(armorItem as Form))
					return result
				endIf
				
			endIf
		
			result.SleepWearItem = armorItem
			
			if (!actorRef.IsEquipped(armorItem))
				DTDebug(" sleepEquipFromLast equip sleep clothes " + armorItem + " on " + actorRef, 2)
				actorRef.EquipItem(armorItem, false, true)
				Utility.WaitMenuMode(0.1)
				
				if (actorRef == PlayerRef)
					PlayerSleepEquippedFormArray.Add(armorItem, 1)
					
				elseIf (actorRef == CompanionRef)
					CompanionSleepEquippedFormArray.Add(armorItem, 1)
					
				endIf
				
				result.DidEquip = true
			endIf
		endIf
	endIf
	
	return result
EndFunction

Armor Function SleepwearFoundForActorFromList(Actor actorRef, FormList fromSleepwearList)
	if (actorRef && fromSleepwearList)
		int len = fromSleepwearList.GetSize()
		int i = 0

		while (i < len)
			Armor armorItem = fromSleepwearList.GetAt(i) as Armor
			if (armorItem != None)
				int itemCount = actorRef.GetItemCount(armorItem)
				if (itemCount > 0)
					return armorItem
					
				elseIf (PlayerBedRef != None && PlayerBedRef.HasKeyword(DTSleep_OutfitContainerKY))
						
					if (PlayerBedRef.GetItemCount(armorItem) > 0)
						;Debug.Trace(myScriptName + " getting sleepwear from bed container")
						PlayerBedRef.RemoveItem(armorItem, 1, true, PlayerRef)
						
						return armorItem
					endIf
				endIf
			endIf
			
			i += 1
		endWhile
	endIf
	return None
EndFunction

Function UndressSleepwearForActor(Actor actorRef, Form[] equippedFormArray)

	int i = 0
	while (i < equippedFormArray.length)
		Armor item = equippedFormArray[i] as Armor
		if (item)
			actorRef.UnequipItem(item, false, true)
		endIf
		i += 1
	endWhile
EndFunction

;
; use instead of regular UndressActor to undress only respectful items:
;   - hats, glasses, masks, jacket, backpack
;   - outer-armors only if known items
;
Function UndressActorRespect(Actor actorRef, bool isIndoors, bool remHatsOutside = true)

	; limited undress - avoid items that knock off entire outfit since we cannot know for certain
	; if outfit covers many slots

	bool summer = IsSummerSeason()
	if (summer && WeatherClass >= 2)
		; too rainy
		summer = false
	endIf
	
	if (actorRef == PlayerRef)
		PlayerEquippedArrayUpdated = false
		DTSleep_PlayerUndressed.SetValue(-1.0)   ; flag started

		if ((DTSleep_UndressPAlias as DTSleep_EquipMonitor).StoringPlayerEquipment == false)
		
			(DTSleep_UndressPAlias as DTSleep_EquipMonitor).BeginStorePlayerEquipment()
		endIf
	elseIf (actorRef == CompanionRef)
		CompanionEquippedArrayUpdated = false
		; wait until finish to mark companion as valid
		
		if ((DTSleep_UndressPAlias as DTSleep_EquipMonitor).StoringCompanionEquipment == false)
			
			(DTSleep_UndressPAlias as DTSleep_EquipMonitor).BeginStoreCompanionEquipment(CompanionRef, CompanionSecondRef)
		endIf
		
		if (CompanionSecondRef != None)
			;Debug.Trace(myScriptName + " undress respect 2nd companion " + CompanionSecondRef)
			if (isIndoors || remHatsOutside)
				UndressActorArmorHat(CompanionSecondRef)
			endIf
			UndressActorArmorMask(CompanionSecondRef)
			UndressActorBackPack(CompanionSecondRef, false)
			if (isIndoors || summer)
				UndressJacketForActor(CompanionSecondRef)
			endIf
		endIf
	endIf
	
	if (isIndoors || remHatsOutside || summer)
		UndressActorArmorHat(actorRef)
		Utility.Wait(0.22)
	endIf
	UndressActorArmorMask(actorRef)
	Utility.Wait(0.15)
	
	if (actorRef == PlayerRef)
		bool placeOnGround = true
		if (DTSleep_SettingPackOnGround.GetValueInt() <= 1)
			placeOnGround = false
		endIf
		
		if (DressData.PlayerEquippedBackpackItem != None || DressData.PlayerEquippedCarryPouchItem != None)
			SetPlayerCarryWeightBonus()
			Utility.Wait(0.1)
			if (UndressActorBackPack(actorRef, placeOnGround) == false)
				; not expected to happen
				DTDebug(" missing backpack? remove carry bonus", 1)
				Utility.Wait(0.2)
				if (PlayerRef.HasSpell(DTSleep_UndressCarryBonus))
					PlayerRef.RemoveSpell(DTSleep_UndressCarryWeight)
				endIf
			endIf
		endIf
	else
		UndressActorBackPack(actorRef, false)
	endIf
	if (isIndoors || summer)
		; jackets and armor together since some jackets go with armor (like Neiro's MojaveManhunter), and it's hot in summer
		UndressJacketForActor(actorRef)
		if (!IsActorWearingArmorAllException(actorRef, false))
			UndressActorArmorOutSlots(actorRef, false, true)			; include upper, respect-only
		endIf
		; no gloves - no list or keyword - cannot be certain by slot since may knock off entire outfit 
	endIf
	if (DTSleep_SettingUndressGlasses.GetValueInt() >= 2)
		UndressActorArmorGlasses(actorRef)
	endIf
	
	if (actorRef == PlayerRef)
		
		StartTimer(1.75, UndressGetPlayerEquipDataTimerID)  ; wait for monitor to finish storing
	elseIf (actorRef == CompanionRef)
		StartTimer(1.75, UndressGetCompanionEquipDataTimerID)
	endIf
	
endFunction

; --------------------
; only undress normal items so actor may keep wearing jewelry and special underwear
; UnequipItemSlot actually uses index not slot - https://www.creationkit.com/fallout4/index.php?title=Biped_Slots
;
; note that UnequipItemSlot is by race -- PowerArmorRace uses different slots such as 32 for body, 33 hands, 36 ring
; some companions get stuck in PowerArmorRace after leaving power armor due to game bug!
; many companions need a nude suit due to re-equip outfit -- exceptions for mod companion use variable in DressData
;
Function UndressActor(Actor actorRef, int bedLevel, bool includeClothing = false, bool includeExceptions = false, bool includePipBoy = false)

	;float timeStart = Utility.GetCurrentRealTime()
	bool forBed = true
	
	if (bedLevel < 1)
		forBed = false
	endIf
	
	DTDebug("  undress " + actorRef + ", includeClothing: " + includeClothing + ", includeExceptions: " + includeExceptions, 2)

	bool hasSleepWearMainOutfit = false
	int equipMonInitLevel = DTSleep_EquipMonInit.GetValueInt()
	bool extraArmorosEnabled = false
	bool actorWearingIntimateItem = false
	bool actorWearingArmorAll = false
	bool isWinter = IsWinterSeason()
	bool isIndoors = false
	Form[] playerEquipArray = None
	Armor toyCheckRef = None
	int pipPadSlotIndex = (DTSConditionals as DTSleep_Conditionals).PipPadSlotIndex
	
	if (DTSleep_ExtraArmorsEnabled.GetValueInt() > 0)
		extraArmorosEnabled = true
	endIf
	
	if (pipPadSlotIndex > 10 && actorRef == PlayerRef)
		; double-check player has item
		
		Armor pipPad = DTSleep_ArmorPipPadList.GetAt((DTSConditionals as DTSleep_Conditionals).PipPadListIndex) as Armor
		
		if (pipPad == None)
			pipPadSlotIndex = SetPlayerPipPadIndex()
		elseIf (PlayerRef.GetItemCount(pipPad) == 0)
			pipPadSlotIndex = SetPlayerPipPadIndex()
		endIf
	endIf
				 
	
	if (actorRef == PlayerRef)
		PlayerEquippedArrayUpdated = false
		if (equipMonInitLevel >= 5)
			; get the starting equipped list - use for faster checking of extra armors and clothing lists
			playerEquipArray = (DTSleep_UndressPAlias as DTSleep_EquipMonitor).GetMyPlayerEquipment()
		endIf
		
	elseIf (actorRef == CompanionRef)
		CompanionEquippedArrayUpdated = false
	endIf
	
	if (includeClothing)
		; check if need to ensure intimate clothing is on at end
		if (equipMonInitLevel > 0)
		
			; intimate item could be in any slot so check at end to re-equip
			actorWearingIntimateItem = IsActorWearingIntimateItem(actorRef)
			if (actorRef == PlayerRef)
				toyCheckRef = DressData.PlayerEquippedStrapOnItem
			elseIf (actorRef == CompanionRef)
				toyCheckRef = DressData.CompanionEquippedStrapOnItem
			endIf
		endIf
		
		if (!actorWearingIntimateItem)
			
			hasSleepWearMainOutfit = CheckActorHasSleepwearMainOutfit(actorRef, equipMonInitLevel)
		endIf
	else
		isIndoors = IsActorIndoors(actorRef)
		if (actorRef == PlayerRef && PlayerIsAroused)
			PlayerIsAroused = false
		endIf
	endIf
	
	DTDebug(" actor " + actorRef + " in sleepwear? " + hasSleepWearMainOutfit + " or intimate? " + actorWearingIntimateItem, 2)
	
	; register to fill equipment form using EquipMonitor
	
	if (actorRef == PlayerRef)
	
		DTSleep_PlayerUndressed.SetValue(-1.0)   ; flag started

		if ((DTSleep_UndressPAlias as DTSleep_EquipMonitor).StoringPlayerEquipment == false)
		
			(DTSleep_UndressPAlias as DTSleep_EquipMonitor).BeginStorePlayerEquipment()
		endIf
	elseIf (actorRef == CompanionRef)
		; wait until finish to mark companion as valid
		
		if ((DTSleep_UndressPAlias as DTSleep_EquipMonitor).StoringCompanionEquipment == false)
			
			(DTSleep_UndressPAlias as DTSleep_EquipMonitor).BeginStoreCompanionEquipment(actorRef, CompanionSecondRef)
		endIf
	endIf
	
	; note - pass slot index
	;   
	;   https://www.creationkit.com/fallout4/index.php?title=Biped_Slots
	
	bool placeOnGround = !includeExceptions
	int packSetting = DTSleep_SettingPackOnGround.GetValueInt()				; 2=sleep+chair, 1 = sleep-only
	if (PlayerBedRef == None || !PlayerBedRef.HasKeyWord(IsSleepFurnitureKY))
		packSetting -= 1	; adjust to compare to 1
	endIf
			
	if (actorRef == PlayerRef)
		; v1.94 place on ground bed or feet if carry bonus and settings true
		; carry checked so can avoid placing for Quick Dress container
		if (EnableCarryBonus)
			if (packSetting >= 1)
				placeOnGround = true	
				if (PlayerBedRef != None && PlayerBedRef.HasKeyword(DTSleep_OutfitContainerKY))
					placeOnGround = false
				endIf
			else
				placeOnGround = false
			endIf
		endIf
	elseIf (packSetting <= 1)
		; companion only place at bed
		placeOnGround = false
	endIf
	
	; remove and place backpacks
	if (UndressActorBackPack(actorRef, placeOnGround) && actorRef == PlayerRef)
		
		SetPlayerCarryWeightBonus()
	endIf
	
	UndressActorArmorHat(actorRef)
	Utility.WaitMenuMode(0.1)
	
	bool removeJacket = false
	bool wearingJacket = IsActorWearingJacket(actorRef)
	bool skipUpperOuterArmorSlots = false
	bool ensureNude = false
	bool playerArmorKnockOff = false

	if (includeClothing || isIndoors)
		
		removeJacket = true
	elseIf (WeatherClass < 2)  ; instead of !winter
	
		removeJacket = true
	endIf

	if (removeJacket && wearingJacket)
		; remove jackets not removed by slot
		
		UndressJacketForActor(actorRef)
		; wait for item event- CROSS-MojaveManhunter overcoat delays 0.20 to update mod-attach
		Utility.WaitMenuMode(0.22)
		
	elseIf (!removeJacket && wearingJacket)
		; wearing jacket, but we want to keep it on so skip torso and arm armors
		skipUpperOuterArmorSlots = true
	endIf
	
	; Armor-All-Exception check
	; outer armor to remove, but don't remove if outside with armor-all outfit OR if wearing jacket
	;
	if (!includeClothing && !hasSleepWearMainOutfit && IsActorWearingArmorAllException(actorRef, true))
		; v2.0 stick to no-clothing since will not put on sleep clothes
		;  previously in v1.55 for indoors and forBed went ahead and removed armor-all to be naked,
		;  but doesn't fit all cases so stick to given request by caller
		actorWearingArmorAll = true

	elseIf (actorRef == PlayerRef)
		
		if (includeClothing && includeExceptions)
			if (actorWearingIntimateItem)
				UndressActorArmorOutSlots(actorRef, skipUpperOuterArmorSlots)
				
			elseIf (!skipUpperOuterArmorSlots && !IsActorWearingSlot41Exceptions(actorRef))
				; force off and prevent auto-equip items until done undressing
				playerArmorKnockOff = true
				PlayerRef.EquipItem(DTSleep_NudeRingArmorOuter, true, true)
				UndressActorArmorOutSlots(actorRef, true, hasSleepWearMainOutfit)
			else
				UndressActorArmorOutSlots(actorRef, skipUpperOuterArmorSlots, hasSleepWearMainOutfit)
			endIf
		else
			; v2.14 - if has sleepwear set to respect-only to avoid removing by slot
			UndressActorArmorOutSlots(actorRef, skipUpperOuterArmorSlots, hasSleepWearMainOutfit)
		endIf

	elseIf (!includeClothing && !wearingJacket)
		; v 1.08 
		; companion and if include all then nude-ring removes these below
		; remove by slots on companion only works sometimes
		; v1.54; v1.57 - check if sleepwear includes outer armor
		if (hasSleepWearMainOutfit && DressData.CompanionEquippedSleepwearItem != None)
			if (DTSleep_SleepAttireFullArmorList.HasForm(DressData.CompanionEquippedSleepwearItem as Form))
				actorWearingArmorAll = true
			elseIf (DTSleep_ArmorAllExceptionList.HasForm(DressData.CompanionEquippedSleepwearItem as Form))
				actorWearingArmorAll = true
			endIf
		elseIf (!skipUpperOuterArmorSlots)
			; v2.14 - add extra seconds for nude-ring-knock-off re-equip by scripted equip such as Niero outfits
			Utility.WaitMenuMode(0.16)
			actorRef.EquipItem(DTSleep_NudeRingArmorOuter, false, true)		; allow removal, silent
		endIf
	elseIf (includeClothing)
		if (DressData.CompanionDressValid && actorRef == CompanionRef)
			DTDebug(" companion include clothing -- Undress outerslots skipUpper? " + skipUpperOuterArmorSlots + ", sleepWear? " + hasSleepWearMainOutfit, 2)
			UndressActorArmorOutSlots(actorRef, skipUpperOuterArmorSlots, hasSleepWearMainOutfit)
			
		elseIf (!hasSleepWearMainOutfit && !skipUpperOuterArmorSlots)
			; DressData invalid  -- will knock off slot-41 exceptions       
			; TODO - v2.14
			if (includeExceptions && actorRef == CompanionRef && DressData.CompanionNudeSuit == None)
				; v2.14 - knock it all off
				actorRef.EquipItem(DTSleep_NudeRing, true, true)
			else
				actorRef.EquipItem(DTSleep_NudeRingArmorOuter, false, true)		; allow removal, silent
			endIf
		endIf
	endIf
		
	if (includeClothing)
		
		if (hasSleepWearMainOutfit)
			if (includeExceptions)
			
				UndressActorArmorMainSleepwearPlaceAtFeet(actorRef, DropSleepClothes)
				
				if (actorRef == PlayerRef)
					; ensure
					; v1.61 - check if auto-re-equip
					ensureNude = true
					actorRef.UnequipItemSlot(3) 	; 33 - full body outfit
					Utility.WaitMenuMode(0.16)
					actorRef.UnequipItemSlot(4) 	; 34 - left hand 
					actorRef.UnequipItemSlot(5)
				endIf
			else
				if (actorRef == CompanionRef)
					
					if (DressData.CompanionEquippedSleepwearItem != None && !DTSleep_SleepAttireFullArmorList.HasForm(DressData.CompanionEquippedSleepwearItem as Form))
						DressData.CompanionRequiresNudeSuit = false  ; force off
						; may knock main sleepwear off - fix later
						UndressActorCompanionDressNudeSuit(actorRef, hasSleepWearMainOutfit)
					endIf
				endIf
				actorRef.UnequipItemSlot(4) 	; 34 - left hand 
				actorRef.UnequipItemSlot(5)
			endIf
		elseIf (actorRef == PlayerRef)
		
			; assume intimate a main outfit then check at end for correction
			if (!actorWearingIntimateItem)
				ensureNude = true
				
				actorRef.UnequipItemSlot(3) ; 33 - full body outfit
				; wait for a mod item event
				Utility.WaitMenuMode(0.12)
			endIf
			
			UndressActorArmorInnerSlots(actorRef)
			
		elseIf (includeExceptions || !actorWearingArmorAll)  ; companion
			if (actorRef == CompanionRef)
				if (hasSleepWearMainOutfit || actorWearingIntimateItem)
					; override since has sleepwear on
					DressData.CompanionRequiresNudeSuit = false 
				elseIf (actorRef == CompanionStrongRef)
					DressData.CompanionRequiresNudeSuit = false 
				endIf
			endIf
			
			; includes waits
			UndressActorCompanionDressNudeSuit(actorRef, hasSleepWearMainOutfit)
		endIf
		
	elseIf (isIndoors || (!isWinter && WeatherClass < 2))
		if (actorRef == PlayerRef)
			actorRef.UnequipItemSlot(4) 	; 34 - left hand
			actorRef.UnequipItemSlot(5)
		endIf
	endIf
	
	if (extraArmorosEnabled)
	
		; any clothing items always comes off - must be on list
		; also see extra-parts list below
		
		if (equipMonInitLevel > 0)
			if (actorRef == PlayerRef)
				if (DressData.PlayerHasExtraClothingEquipped)
					if (equipMonInitLevel >= 5)
						
						int cnt = UndressActorArmorForListFromArray(PlayerRef, DTSleep_ArmorExtraClothingList, playerEquipArray)
						DTDebug("remove player extra clothing count " + cnt, 2)
					else
						UndressActorExtraArmorList(actorRef, DTSleep_ArmorExtraClothingList)
					endIf
				endIf
			elseIf (actorRef == CompanionRef && !DressData.CompanionDressValid)
				
				UndressActorExtraArmorList(actorRef, DTSleep_ArmorExtraClothingList)
				
			elseIf (actorRef == CompanionRef && DressData.CompanionHasExtraClothingEquipped)

				UndressActorExtraArmorList(actorRef, DTSleep_ArmorExtraClothingList)
			endIf
		else
			UndressActorExtraArmorList(actorRef, DTSleep_ArmorExtraClothingList)
		endIf
	endIf
	
	; slots 46 - 61 skips 60
	UndressActorArmorExtendedSlots(actorRef, forBed, includeExceptions, hasSleepWearMainOutfit)

	; 60, pip-boy 
	if (actorRef == PlayerRef && includeClothing && includePipBoy)
		if (UndressedForType >= 5 && !hasSleepWearMainOutfit)
			
			PlayerRef.EquipItem(DTSleep_PlayerNudeBodyNoPipBoy, true, true)
		else
			actorRef.UnequipItemSlot(30)
		endIf
	endIf
	
	;  extra parts list
	;
	if (DTSleep_ArmorExtraPartsList != None && extraArmorosEnabled)
		
		if (equipMonInitLevel > 0)
			if (actorRef == PlayerRef)
				if (DressData.PlayerHasExtraPartsEquipped)
					if (equipMonInitLevel >= 5)
						int cnt = UndressActorArmorForListFromArray(PlayerRef, DTSleep_ArmorExtraPartsList, playerEquipArray)
						DTDebug("remove player extra parts count " + cnt, 2)
					else
						UndressActorExtraArmorList(actorRef, DTSleep_ArmorExtraPartsList)
					endIf
				endIf
			elseIf (actorRef == CompanionRef && DressData.CompanionDressValid)
				if (DressData.CompanionHasExtraPartsEquipped)
					UndressPlacedSet placeSet = UndressActorExtraArmorList(actorRef, DTSleep_ArmorExtraPartsList)
					if (placeSet.FoundItemCount == 0)
						DressData.CompanionHasExtraPartsEquipped = false
					endIf
				endIf
			else
				UndressActorExtraArmorList(actorRef, DTSleep_ArmorExtraPartsList)
			endIf
		else
			UndressActorExtraArmorList(actorRef, DTSleep_ArmorExtraPartsList)
		endIf
	endIf
	
	; v2.14 - moved wait up above sleep-clothes check
	;float timeElapse = Utility.GetCurrentRealTime() - timeStart
	Utility.WaitMenuMode(0.333)   ; give monitor time to catch up
	
	; double-check intimate and sleep outfit since may get bumped
	; player can mark sleepwear outfits and may not be a main outfit
	;
	if (actorWearingIntimateItem)
		CheckAndEquipIntimateOutfit(actorRef)
		
	elseIf (toyCheckRef != None)
		CheckAndEquipStrapOnItem(actorRef, toyCheckRef)
		
	elseIf (hasSleepWearMainOutfit)
		CheckAndEquipMainSleepOutfit(actorRef)
		
	endIf

	
	float timerSecs = DTSleep_SettingUndressTimer.GetValue() + 0.25
	
	if (timerSecs > 6.5)
		timerSecs = 6.5
		DTSleep_SettingUndressTimer.SetValue(timerSecs)
	endIf
	
	if (UndressedForType >= 5 && timerSecs < 4.0)
		timerSecs = 4.0
	endIf
	
	
	if (actorRef == PlayerRef)
	
		if (playerArmorKnockOff)
			RedressActorRemoveNudeSuits(PlayerRef, DTSleep_NudeRingArmorOuter, " player nude-ring-armor-outer")
			if (!ensureNude)
				Utility.WaitMenuMode(0.16)
			endIf
		endIf
	
		if (ensureNude)
			Utility.WaitMenuMode(0.3)
			
			; double-check torso armor - armors with auto-equip like Manhunter by Neiro may re-equip
			if (!actorWearingArmorAll && !IsActorWearingSlot41Exceptions(actorRef))
				
				if (!skipUpperOuterArmorSlots)
					;DTDebug(myScriptName + " double-check player armor-41 removal", 2)
					actorRef.UnequipItemSlot(11)
				endIf
				if (removeJacket && wearingJacket)
					;DTDebug(myScriptName + " double-check jacket removal", 2)
					UndressJacketForActor(actorRef)
				endIf
			endIf
			
			if (DTSleep_SettingAltFemBody.GetValueInt() >= 1 && AltFemBodyEnabled && DTSleep_AdultContentOn.GetValue() >= 2.0 && DressData.PlayerGender == 1)
				DTDebug(" ****** equip  Alt-Fem-Body on player *****", 2)
				actorRef.EquipItem(DTSleep_AltFemNudeBody, true, true)
			else
				actorRef.UnequipItemSlot(3)
			endIf
		endIf
		
		if (PlayerIsAroused && DressData.PlayerGender == 0 && includeClothing && includeExceptions && !hasSleepWearMainOutfit && (DTSConditionals as DTSleep_Conditionals).ImaPCMod)
			Armor nudeSuitAroused = GetPlayerNudeSuitMale()
			if (nudeSuitAroused != None && (DTSConditionals as DTSleep_Conditionals).ImaPCMod && Debug.GetPlatformName() as bool)
				DTDebug(" equip player nude-suite " + nudeSuitAroused, 2)
				PlayerRef.EquipItem(nudeSuitAroused, true, true)
			else
				PlayerIsAroused = false
			endIf
		else
			PlayerIsAroused = false
		endIf
		
		if (!SuspendEquipStore || UndressedForType >= 5)
			if (timerSecs < 2.0 || UndressedForType >= 5)
				
				Utility.WaitMenuMode(2.4)
				
				; v2.14 - double-check armors usually due to custom armors with re-equip scripts like Neiro re-fit outfits
				if (includeClothing && !skipUpperOuterArmorSlots)
					UndressActorFinalCheckArmors(actorRef, false)
					Utility.WaitMenuMode(0.333)
				endIf

				HandleGetUndressPlayerData()
				
				;
				; check if need to recover Pip-boy after undress update
				; avoid storage, so close first
				;
				if (UndressedForType >= 6 && !includePipBoy)
				
					Armor armorPipBoy = GetArmorForActorWearingClothingOnList(PlayerRef, (DTSleep_UndressPAlias as DTSleep_EquipMonitor).DTSleep_ArmorPipBoyList)
				
					if (armorPipBoy != None)
						; we bump and block in case of another function re-equips
						DTDebug(" equip player nude-ring-no-pip to bump pipboy: " + armorPipBoy, 1)
						
						PlayerRef.EquipItem(DTSleep_PlayerNudeBodyNoPipBoy, true, true)	
						
						Utility.WaitMenuMode(0.67)

						; restore pip-boy
						RedressActorRemoveNudeSuits(PlayerRef, DTSleep_PlayerNudeBodyNoPipBoy, " player nude-body-noPip", true)
						if (armorPipBoy != None && PlayerRef.GetItemCount(armorPipBoy) >= 1)
							DTDebug(" replace Pip-Boy equip ", 1)
							PlayerRef.EquipItem(armorPipBoy, false, true)
						endIf
					endIf
				endIf
			else
			
				; v2.14 - double-check armors usually due to custom armors with re-equip scripts like Neiro re-fit outfits
				if (includeClothing && !skipUpperOuterArmorSlots)
					StartTimer(timerSecs - 0.5, UndressCheckPlayerFinalOuterArmorTimerID)
				endIf
				StartTimer(timerSecs, UndressGetPlayerEquipDataTimerID)  ; wait for monitor to finish storing
			endIf
		else
			; v2.14 - double-check armors usually due to custom armors with re-equip scripts like Neiro re-fit outfits
			if (includeClothing && !skipUpperOuterArmorSlots)
				StartTimer(1.0, UndressCheckPlayerFinalOuterArmorTimerID)
			endIf
		endIf
		
		DTSleep_PlayerUndressed.SetValue(1.0)
		if (includeClothing && includeExceptions)
			DressData.PlayerHasArmorAllEquipped = false
		endIf
		
		; to handle check re-equip Pip-boy
		RegisterForMenuOpenCloseEvent("PipboyMenu")

	elseIf (actorRef == CompanionRef)
	
		if (!DressData.CompanionDressValid)
			if (includeExceptions || hasSleepWearMainOutfit)
				DressData.CompanionDressValid = true
				DressData.CompanionDressArmorAllValid = true
			endIf
		endIf
		
		if (UndressedForType >= 5)
			Utility.WaitMenuMode(1.67)
		endIf
		
		; 2nd companion goes second so may need to wait
		if (!SuspendEquipStore && CompanionSecondRef == None)
			if (timerSecs < 2.50)
				Utility.WaitMenuMode(2.67)
				
				; v2.14 - double-check armors usually due to custom armors with re-equip scripts like Neiro re-fit outfits
				if (includeClothing && !skipUpperOuterArmorSlots)
					UndressActorFinalCheckArmors(actorRef, false)
					Utility.WaitMenuMode(0.333)
				endIf
				HandleGetUndressCompanionData()
			else
				; v2.14 - double-check armors usually due to custom armors with re-equip scripts like Neiro re-fit outfits
				if (includeClothing && !skipUpperOuterArmorSlots)
					StartTimer(timerSecs - 0.333, UndressCheckCompanionFinalOuterArmorTimerID)
				endIf
				StartTimer(timerSecs + 0.75, UndressGetCompanionEquipDataTimerID) ; wait for monitor to finish storing
			endIf
		else
			; v2.14 - double-check armors usually due to custom armors with re-equip scripts like Neiro re-fit outfits
			if (includeClothing && !skipUpperOuterArmorSlots)
				StartTimer(timerSecs - 0.333, UndressCheckCompanionFinalOuterArmorTimerID)
			endIf
		endIf
		
		if (includeClothing)
			DTSleep_CompanionUndressed.SetValue(2.0)
			DressData.CompanionHasArmorAllEquipped = false
		else
			DTSleep_CompanionUndressed.SetValue(1.0)
		endIf
	elseIf (actorRef == CompanionSecondRef)
		
		; 2nd goes second, so we're done -- end store
		if (!SuspendEquipStore)
			if (timerSecs < 2.00)
				Utility.WaitMenuMode(2.5)
				
				; v2.14 - double-check armors usually due to custom armors with re-equip scripts like Neiro re-fit outfits
				if (includeClothing && !skipUpperOuterArmorSlots)
					UndressActorFinalCheckArmors(actorRef, false)
					Utility.WaitMenuMode(0.333)
				endIf
				HandleGetUndressCompanionData()
			else
				Utility.WaitMenuMode(0.2)
				StartTimer(timerSecs + 1.5, UndressGetCompanionEquipDataTimerID) ; wait for monitor to finish storing
			endIf
		endIf
	endIf
	
	;float timeFin = Utility.GetCurrentRealTime() - timeStart
	;Debug.Trace(myScriptName + " Done Undress actor " + actorRef + ", time: " + timeElapse + " timeFin " + timeFin)
EndFunction
; ----------- end UndressActor

Function UndressActorArmorHat(Actor actorRef)

	; check DressData for hat first
	if (actorRef == PlayerRef)
		if (DressData.PlayerEquippedHat != None)
			PlayerRef.UnequipItem(DressData.PlayerEquippedHat, false, true)
		else
			actorRef.UnequipItemSlot(0)		; 30 - Hair Top - hat 
		endIf
	elseIf (CompanionRef != None && actorRef == CompanionRef && DressData.CompanionHat != None)
		
		actorRef.UnequipItem(DressData.CompanionHat, false, true)
	else
		UndressActorExtraArmorList(actorRef, DTSleep_ArmorHatHelmList)
	endIf
	
	Utility.WaitMenuMode(0.08)  ; helms may have lights or extras
endFunction

int Function UndressActorArmorForListFromArray(Actor actorRef, FormList armorList, Form[] equipArray)
	int count = 0
	if (actorRef != None && armorList != None)
		int i = 0
		while (i < equipArray.Length)
			if (equipArray[i] != None && armorList.HasForm(equipArray[i]))
				count += 1
				actorRef.UnequipItem(equipArray[i], false, true)
			endIf
			
			i += 1
		endWhile
	endIf
	
	return count
endFunction

Function UndressActorArmorInnerSlots(Actor actorRef)
		
	actorRef.UnequipItemSlot(4) 	; 34 - left hand 
	actorRef.UnequipItemSlot(5)
	
	; normally considered under-armor clothing pieces
	actorRef.UnequipItemSlot(6) 	; 36 - u-torso !!!(AWK-Bracelet)!!
	actorRef.UnequipItemSlot(7) 	; 37 - u-L arm  AWK-Jacket, Cross overcoats
	actorRef.UnequipItemSlot(8)
	actorRef.UnequipItemSlot(9) 	; 39 - u-L leg  CROSS-Bos boots, AWK-*OnHip
	actorRef.UnequipItemSlot(10)
endFunction

;
Function UndressActorArmorOutSlots(Actor actorRef, bool skipUpper = false, bool respectOnly = false)

	bool includeArms = true
	
	if (!skipUpper)

		if (actorRef == PlayerRef && DTSleep_EquipMonInit.GetValue() < 5.0)
			actorRef.UnequipItemSlot(11)
			
		elseIf (!IsActorWearingSlot41Exceptions(actorRef))
			; exception items stay on - remove non-exception
			if (actorRef == PlayerRef)
				if (DressData.PlayerEquippedArmorTorsoItem != None)
					PlayerRef.UnequipItem(DressData.PlayerEquippedArmorTorsoItem, false, true)
				elseIf (!respectOnly)
					actorRef.UnequipItemSlot(11) 	; 41 - armor torso; nuka necklaces
				endIf
				
			elseIf (actorRef == CompanionRef)
				if (DressData.CompanionEquippedArmorTorsoItem != None)
					if (actorRef.GetItemCount(DressData.CompanionEquippedArmorTorsoItem) >= 1)
						DTDebug(" remove companion outer torso " + DressData.CompanionEquippedArmorTorsoItem, 2)
						actorRef.UnequipItem(DressData.CompanionEquippedArmorTorsoItem, false, true)
					else
						DressData.CompanionEquippedArmorTorsoItem = None
					endIf
				elseIf (!respectOnly)
					; v2.14 -- 2nd Companion - make sure stay off - no removal, silent
					actorRef.EquipItem(DTSleep_NudeRingArmorOuter, true, true)
					includeArms = false
				endIf
			elseIf (!respectOnly)
				; 2nd companion - ; v2.14 -- make sure stay off - no removal, silent
				actorRef.EquipItem(DTSleep_NudeRingArmorOuter, true, true)		
				includeArms = false
			endIf
			Utility.WaitMenuMode(0.20)      ; wait for item event
		endIf

		if (actorRef == PlayerRef && DressData.PlayerEquippedArmorArmLeftItem != None)
			PlayerRef.UnequipItem(DressData.PlayerEquippedArmorArmLeftItem, false, true)
			
		elseIf (actorRef == CompanionRef && includeArms && DressData.CompanionEquippedArmorArmLeftItem != None)
			if (actorRef.GetItemCount(DressData.CompanionEquippedArmorArmLeftItem) > 0)
				actorRef.UnequipItem(DressData.CompanionEquippedArmorArmLeftItem, false, true)
			else
				DressData.CompanionEquippedArmorArmLeftItem = None
			endIf
		elseIf (!respectOnly && includeArms)
			actorRef.UnequipItemSlot(12)  	; 42 - armor left arm, Heather's bag
		endIf
		if (actorRef == PlayerRef && DressData.PlayerEquippedArmorArmRightItem != None)
			PlayerRef.UnequipItem(DressData.PlayerEquippedArmorArmRightItem, false, true)
			
		elseIf (actorRef == CompanionRef && includeArms && DressData.CompanionEquippedArmorArmRightItem != None)
			if (actorRef.GetItemCount(DressData.CompanionEquippedArmorArmRightItem) > 0)
				actorRef.UnequipItem(DressData.CompanionEquippedArmorArmRightItem, false, true)
			else
				DressData.CompanionEquippedArmorArmRightItem = None
			endIf
		elseIf (!respectOnly && includeArms)
			actorRef.UnequipItemSlot(13)   	; 43 - armor R arm
		endIf
	
		actorRef.UnequipItemSlot(16)	; 46 - headband (hat), AWK-Earing/Mask/headband
	endIf
	
	if (actorRef == PlayerRef && DressData.PlayerEquippedArmorLegLeftItem != None)
		PlayerRef.UnequipItem(DressData.PlayerEquippedArmorLegLeftItem, false, true)
	elseIf (actorRef == CompanionRef && DressData.CompanionEquippedArmorLegLeftItem != None)
		if (actorRef.GetItemCount(DressData.CompanionEquippedArmorLegLeftItem) > 0)
			actorRef.UnequipItem(DressData.CompanionEquippedArmorLegLeftItem, false, true)
		else
			DressData.CompanionEquippedArmorLegLeftItem = None
		endIf
	elseIf (!respectOnly)
		actorRef.UnequipItemSlot(14)  	; 44 - armor left leg
	endIf
	if (actorRef == PlayerRef && DressData.PlayerEquippedArmorLegRightItem != None)
		PlayerRef.UnequipItem(DressData.PlayerEquippedArmorLegRightItem, false, true)
	elseIf (actorRef == CompanionRef && DressData.CompanionEquippedArmorLegRightItem != None)
		if (actorRef.GetItemCount(DressData.CompanionEquippedArmorLegRightItem) > 0)
			actorRef.UnequipItem(DressData.CompanionEquippedArmorLegRightItem, false, true)
		else
			DressData.CompanionEquippedArmorLegRightItem = None
		endIf
	elseIf (!respectOnly)
		actorRef.UnequipItemSlot(15)   	; 45 - armor R leg
	endIf
	
	return
endFunction

; generally only works for player
; slots 46+ not including Pipboy-slot60
;
Function UndressActorArmorExtendedSlots(Actor actorRef, bool forBed, bool includeExceptions, bool hasSleepWearMainOutfit)

	int pipPadSlot = (DTSConditionals as DTSleep_Conditionals).PipPadSlotIndex
	if (actorRef != PlayerRef)
		pipPadSlot = 0
	endIf
	
	; most removed with masks or hats
	if (actorRef == PlayerRef && DTSleep_EquipMonInit.GetValue() < 5.0)
		actorRef.UnequipItemSlot(26)  ; 46 - headband; Cross IEX Mask - some removed with hat
	endIf
	
	; glasses check - 3 settings: never, 1=bed-only, 2=always
	int glassesSetting = DTSleep_SettingUndressGlasses.GetValueInt()
	
	if (glassesSetting > 0.0)
		if (forBed || glassesSetting >= 2)
			UndressActorArmorGlasses(actorRef)
		endIf
	endIf
	
	; ----  slots not removed -----
	; 47 - eye: glasses, Petrovich Necklace  -- see above to remove glasses by list
	; 48 - Beard - Elegant Hardware choker; Cross MojaveManhunter mask 
	; -----------------
	; 49 - mouth; bandannas and HN66 Earrings, Elegant Hardware earrings, Bobby Pin Earrings
	if (actorRef == PlayerRef && DTSleep_EquipMonInit.GetValue() < 5.0)
		actorRef.UnequipItemSlot(17)
		actorRef.UnequipItemSlot(18)
		actorRef.UnequipItemSlot(19)
		actorRef.UnequipItemSlot(20)
		actorRef.UnequipItemSlot(21)
		actorRef.UnequipItemSlot(24)
	endIf
	
	UndressActorArmorMask(actorRef)
	
	; ---------- not removed -------------
	; 50 - neck; necklace, shock collar, scarf, Elegant Hardware necklace, AWK-necklace
	; 51 - ring ; "Wearable Camo Backpacks" gives choice of 50,51,61
	
	; 54 - Atom Girl Rifle, Overboss/HarleyQ Jacket, AWK-Cloak, Ranger Harness, Backpack Of Comm, AnSBackpack, TNR Shoulder Lamp
	;    - TheKite_MilitiaWoman Pack; Defy Noncomformist Top
	; 59 (shield)
	; -----------------------------
	
	; 55 - belt, VIO strap-on, Atom Girl Nuka Bear, Ranger Bandoleer, AnSBackpack, AWK-Satchel(KY-06000861), Azar Holstered gun, CC MMBP?
	if (actorRef == PlayerRef && pipPadSlot != 25)
		if (includeExceptions)
			bool isStrapOn = false
			;if (actorRef == PlayerRef)
				if (DressData.PlayerEquippedStrapOnItem)
					if (DTSleep_ArmorSlot55List.HasForm(DressData.PlayerEquippedStrapOnItem as Form))
						isStrapOn = true
					endIf
				endIf
			;elseIf (actorRef == CompanionRef && DressData.CompanionGender == 1 && DressData.CompanionDressValid && DressData.CompanionLastEquippedStrapOnItem)
			;	isStrapOn = true
			;elseIf (IsActorWearingSlot55Exceptions(actorRef))
			;	if (actorRef == CompanionRef && DressData.CompanionEquippedStrapOnItem != None)
			;		isStrapOn = true
			;	endIf
			;endIf
			
			if (!isStrapOn)
				actorRef.UnequipItemSlot(25)
			endIf
		elseIf (DTSleep_EquipMonInit.GetValue() < 5.0 || !IsActorWearingSlot55Exceptions(actorRef))
			actorRef.UnequipItemSlot(25)
		endIf
	endIf
	
	; 56 - Atom Girl Panty, Ranger Bandoleer, TeddyBear BackPack, AnSBackpack, Butterfly wings, AWK-Harness, AWK-Bandoleer, TheKite_MilitiaWoman Overcoat, Azar Holstered
	if (pipPadSlot != 26 && actorRef == PlayerRef)
		actorRef.UnequipItemSlot(26)
	endIf
	; 57 - Atom Girl Skirt, ProvisionorBackPack, Field Scribe Backpack-full, ***AWK-Belt***, AWK-Vest, AWK-MeleeOnHip, Azar Holstered
	if (pipPadSlot != 27 && actorRef == PlayerRef)
		actorRef.UnequipItemSlot(27)
	endIf
	
	if (!RaceRestrictedSlot58(actorRef) && pipPadSlot != 28)
		; 58 - Lacy Underwear panty, Atom Girl Cables, Survivalist Go-Bag, Field Scribe Backpack-low, AWK-GunOnBack, 
		;      !!!AWK-Piercing(KY-06000812)!!!, Azar Holstered gun
		;
		if (includeExceptions || hasSleepWearMainOutfit || !IsActorWearingSlot58Exceptions(actorRef))
		
			bool placeAtFeet = false
			if (includeExceptions && DropSleepClothes)
				placeAtFeet = true
			endIf

			UndressActorArmorSlot58(actorRef, placeAtFeet)
		endIf
	endIf
	
	; 61 - FX (baby bundle), Lacy Underwear bra, Efera's bag, Wearable Camo Backpacks, AWK-offhand, Cross MojaveManhunter duster
	;  - this slot includes 1st-person so enticing for mod armor to use
	;
	if (pipPadSlot != 31)
		if (includeExceptions || hasSleepWearMainOutfit || !IsActorWearingSlot61Exceptions(actorRef))
			
			UndressActorArmorSlotFX(actorRef, includeExceptions)
		endIf
	endIf
	
	if (actorRef == CompanionRef)
		DressData.CompanionDressArmorExtendedValid = true
	endIf
	
	return
endFunction

Function UndressActorArmorGlasses(Actor actorRef)
	
	if (DTSleep_EquipMonInit.GetValueInt() > 0)
		if (actorRef == PlayerRef)
			if (DressData.PlayerEquippedGlassesItem != None)
				actorRef.UnequipItem(DressData.PlayerEquippedGlassesItem, false, true)
				
			elseIf (DressData.PlayerLastEquippedGlassesItem == None)
				; may have non-recognized eyewear
				actorRef.UnequipItemSlot(17)
			endIf
		elseIf (actorRef == CompanionRef)
			if (DressData.CompanionEquippedGlassesItem != None)
				if (DressData.CompanionDressValid || actorRef.GetItemCount(DressData.CompanionEquippedGlassesItem) > 0)
					actorRef.UnequipItem(DressData.CompanionEquippedGlassesItem, false, true)
				else
					UndressPlacedSet placeSet = UndressActorExtraArmorList(actorRef, DTSleep_ArmorGlassesList)
					if (placeSet.FoundItemCount == 0)
						DressData.CompanionEquippedGlassesItem = None
					endIf
				endIf
			elseIf (!DressData.CompanionDressValid)
				UndressActorExtraArmorList(actorRef, DTSleep_ArmorGlassesList)
			endIf			
		else
			UndressActorExtraArmorList(actorRef, DTSleep_ArmorGlassesList)
		endIf
	else
		actorRef.UnequipItemSlot(17)	; may not work on companions
	endIf
	
	return
endFunction

; main sleepwear only - not slot58
;
bool Function UndressActorArmorMainSleepwearPlaceAtFeet(Actor actorRef, bool placeIt)
	; place sleepwear at actor feet
	bool result = false
	
	; only main sleep outfit - slot58 and FX taken care of elsewhere
				
	if (actorRef == PlayerRef)
	
		if (DressData.PlayerEquippedSleepwearItem != None)
			if (placeIt)
				PlaceFormItemAtActorFeet(DressData.PlayerEquippedSleepwearItem as Form, actorRef)
				
				result = true
			endIf
			
			actorRef.UnequipItem(DressData.PlayerEquippedSleepwearItem, false, true)
		endIf
		
		Utility.WaitMenuMode(0.05)
		
	elseIf (actorRef == CompanionRef && DressData.CompanionDressValid)
		
		if (DressData.CompanionEquippedSleepwearItem != None)
		
			if (placeIt)
				PlaceFormItemAtActorFeet(DressData.CompanionEquippedSleepwearItem as Form, actorRef)
					
				result = true
			endIf
			
			actorRef.UnequipItem(DressData.CompanionEquippedSleepwearItem, false, true)
		endIf
		
		if (DressData.CompanionRequiresNudeSuit)
			;Debug.Trace(myScriptName + " equip Nude Suit on " + actorRef)
			
			actorRef.EquipItem(DTSleep_NudeSuit, true, true)
			Utility.WaitMenuMode(0.1)
		endIf
		
	endIf
	
	return result
endFunction

Function UndressActorArmorMask(Actor actorRef)
	if (actorRef == None)
		return
	endIf
	
	if (actorRef == PlayerRef)
		if (DTSleep_EquipMonInit.GetValue() > 0.0)
			if (DressData.PlayerEquippedMask != None)
				actorRef.UnequipItem(DressData.PlayerEquippedMask, false, true)
				
			endIf
		else
			UndressActorExtraArmorList(actorRef, DTSleep_ArmorMaskList)
		endIf
	elseIf (actorRef == CompanionRef)
		if (DressData.CompanionEquippedMask != None)
			if (DressData.CompanionDressValid || actorRef.GetItemCount(DressData.CompanionEquippedMask) > 0)
				actorRef.UnequipItem(DressData.CompanionEquippedMask, false, true)
			elseIf (!DressData.CompanionDressValid)
				UndressPlacedSet placeSet = UndressActorExtraArmorList(actorRef, DTSleep_ArmorMaskList)
				if (placeSet.FoundItemCount == 0)
					DressData.CompanionEquippedMask = None
				endIf
			endIf
		elseIf (!DressData.CompanionDressValid)
			UndressActorExtraArmorList(actorRef, DTSleep_ArmorMaskList)
		endIf
	else
		UndressActorExtraArmorList(actorRef, DTSleep_ArmorMaskList)
	endIf
	
endFunction

; if sleepWear then only undress if placing
;
Function UndressActorArmorSlot58(Actor actorRef, bool placeSleepwearAtFeet)
		
	if (actorRef == PlayerRef)
	
		if (DressData.PlayerEquippedSlot58IsSleepwear && DressData.PlayerEquippedSlot58Item != None)
		
			; only remove if placing
			
			if (placeSleepwearAtFeet)
				
				PlaceFormItemAtActorFeet(DressData.PlayerEquippedSlot58Item as Form, actorRef)
				
				PlayerRef.UnequipItem(DressData.PlayerEquippedSlot58Item, false, true)
				
			endIf
			
		elseIf (DressData.PlayerEquippedSlot58Item != None)
		
			PlayerRef.UnequipItem(DressData.PlayerEquippedSlot58Item, false, true)
		else
			PlayerRef.UnequipItemSlot(28)
		endIf

		Utility.WaitMenuMode(0.05)
	elseIf (actorRef == CompanionRef)
	
		Armor item = DressData.CompanionEquippedSlot58Item
		
		if (item != None && (DressData.CompanionDressValid || DressData.CompanionDressArmorExtendedValid || actorRef.IsEquipped(item)))
		
			if (DressData.CompanionEquippedSlot58IsSleepwear)
				
				if (placeSleepwearAtFeet)
					PlaceFormItemAtActorFeet(DressData.CompanionEquippedSlot58Item as Form, actorRef)
				
					actorRef.UnequipItem(item, false, true)
				endIf
			else
				actorRef.UnequipItem(item, false, true)
			endIf
			
		elseIf (placeSleepwearAtFeet || (!DressData.CompanionDressValid && !DressData.CompanionDressArmorExtendedValid))
		
			item = GetArmorForActorWearingClothingOnList(actorRef, DTSleep_ArmorSlot58List)
			if (item)
				actorRef.UnequipItem(item, false, true)
			endIf
		endIf
	endIf
endFunction

Function UndressActorArmorSlotFX(Actor actorRef, bool includeExceptions)

	bool itemRemoved = false
		
	if (actorRef == PlayerRef)
		if (includeExceptions)
			
			if (DressData.PlayerEquippedSlotFXItem != None)
				
				if (DressData.PlayerEquippedSlotFXIsSleepwear && DropSleepClothes)
					PlaceFormItemAtActorFeet(DressData.PlayerEquippedSlotFXItem as Form, actorRef)
				endIf
			
				PlayerRef.UnequipItem(DressData.PlayerEquippedSlotFXItem, false, true)
			else
				actorRef.UnequipItemSlot(31)
			endIf
		endIf
	elseIf (actorRef == CompanionRef && DressData.CompanionEquippedSlotFXItem != None && DressData.CompanionDressValid)
		
		actorRef.UnequipItem(DressData.CompanionEquippedSlotFXItem, false, true)
		
	elseIf (includeExceptions)
		
		Armor item = GetArmorForActorWearingClothingOnList(actorRef, DTSleep_ArmorSlotFXList)
		if (item)
			
			actorRef.UnequipItem(item, false, true)
		endIf
	endIf
		
endFunction

bool Function UndressActorBackPack(Actor actorRef, bool placeOnGround = true)
	if (actorRef == None)
		return false
	endIf
	
	int placedCount = 0
	bool checkBackPack = false
	bool foundPack = false
	
	if (DTSleep_EquipMonInit.GetValueInt() > 0)
		if (actorRef == PlayerRef)
			checkBackPack = true
			
			if (DressData.PlayerEquippedCarryPouchItem != None)
				; do not place pouches
				PlayerRef.UnequipItem(DressData.PlayerEquippedCarryPouchItem, false, true)
				foundPack = true
			endIf
			
			Armor backpack = DressData.PlayerEquippedBackpackItem
			if (backpack != None)
				foundPack = true
				
				if (placeOnGround)
					
					if (PlayerBedRef != None)
						int cornerVal = 0
						if (PlayerBedRef.HasKeyWord(AnimFurnFloorBedAnims))
							cornerVal = 1
						elseIf (PlayerBedRef.HasKeyWord(IsSleepFurnitureKY) == false)
							cornerVal = -1
						endIf
						
						placedCount += UndressPlaceExtraArmorForBed(PlayerBedRef, actorRef, backpack, cornerVal, DressData.PlayerBackPackNoGOModel)
					else
						placedCount += UndressPlaceExtraArmorAtFeet(actorRef, backpack, DressData.PlayerBackPackNoGOModel)
					endIf
				endIf
				
				PlayerRef.UnequipItem(backpack, false, true)
			endIf
		elseIf (actorRef == CompanionRef && DressData.CompanionDressValid)
			checkBackPack = true
			
			if (DressData.CompanionEquippedCarryPouchItem != None)
				foundPack = true
				actorRef.UnequipItem(DressData.CompanionEquippedCarryPouchItem, false, true)
			endIf
			
			if (DressData.CompanionEquippedBackpackItem != None)
				
				foundPack = true
				
				if (placeOnGround && PlayerBedRef != None)
					int cornerVal = 0
					if (PlayerBedRef.HasKeyWord(AnimFurnFloorBedAnims))
						cornerVal = 1
					endIf
					placedCount += UndressPlaceExtraArmorForBed(CompanionBedRef, actorRef, DressData.CompanionEquippedBackpackItem, cornerVal, DressData.CompanionBackPackNoGOModel)
				endIf
					
				actorRef.UnequipItem(DressData.CompanionEquippedBackpackItem, false, true)
			endIf
		endIf
	endIf
	
	if (!checkBackPack)
		
		if (DTSleep_ArmorBackPacksList != None)	
			
			UndressPlacedSet placeSet = UndressActorExtraArmorList(actorRef, DTSleep_ArmorBackPacksList, placeOnGround, false)
			placedCount += placeSet.PlacedItemCount
			if (placeSet.FoundItemCount > 0)
				foundPack = true
				Utility.WaitMenuMode(0.1)
			endIf
		endIf
		
		if (placedCount == 0 && DTSleep_ArmorBackPacksnoGOList != None)
			UndressPlacedSet placeSet = UndressActorExtraArmorList(actorRef, DTSleep_ArmorBackPacksnoGOList, placeOnGround, true)
			placedCount += placeSet.PlacedItemCount
			if (placeSet.FoundItemCount > 0)
				foundPack = true
				Utility.WaitMenuMode(0.1)
			endIf
		endIf
	endIf
	
	; AWKCR pack uses slot 55 - should normally be caught by EquipMonitor except on first bed use
	;
	if (actorRef == PlayerRef && placedCount == 0 && (DTSConditionals as DTSleep_Conditionals).IsAWKCRActive)
	
		Keyword satchelKY = (DTSConditionals as DTSleep_Conditionals).AWKCRPackKW
		
		if (satchelKY)
			if (actorRef.WornHasKeyword(satchelKY))
				foundPack = true
				actorRef.UnequipItemSlot(25)

				if (placeOnGround)
					int cornerVal = 0
					if (PlayerBedRef.HasKeyWord(AnimFurnFloorBedAnims))
						cornerVal = 1
					endIf
					if (PlaceFormItemAtBed(DTSGenericBagItem, PlayerBedRef, actorRef, cornerVal))
						placedCount += 1
					endIf
					
				endIf
			endIf
		endIf
	endIf

	return foundPack
EndFunction

Function UndressActorCompanionDressNudeSuit(Actor actorRef, bool hasSleepMainOutfit = false)
	; companions may auto-dress
	; companion intimate apparel re-added at end in case bumped
	;
	; equip nude-suit/ring directly with prevent remove - do not add nude ring/suit first 
	; adding armor to NPC container first causes NPC to reset clothing
	
	if (actorRef == PlayerRef)
		return
	endIf
	Utility.WaitMenuMode(0.10)
	
	if (DressData.CompanionNudeSuit == None && DTSleep_SettingAltFemBody.GetValue() >= 1.0 && AltFemBodyEnabled && DTSleep_AdultContentOn.GetValue() >= 2.0 && GetGenderForActor(actorRef) == 1)
		
		actorRef.EquipItem(DTSleep_AltFemNudeBody, true, true)
		
	elseIf (DressData.CompanionRequiresNudeSuit)
	
		; prevent actor from bumping nude-suit (EquipItem true on 1st parameter)
		; sleep clothing may not bump nude-suits - check to remove before equip sleepwear
		
		if (DressData.CompanionNudeSuit == None)
			DTDebug(" equip default Nude Suit on " + actorRef, 2)
			
			actorRef.EquipItem(DTSleep_NudeSuit, true, true)   ; prevent NPC main outfit auto-equip
			Utility.WaitMenuMode(0.12)
		else
			; use ring to knock off armors then put on custom nude-suit 
			
			actorRef.EquipItem(DTSleep_NudeRingNoHands, true, true)
			Utility.WaitMenuMode(0.16)
			DTDebug(" equip custom companion nude-ring + Nude Suit " + DressData.CompanionNudeSuit + " on " + actorRef, 2)
			
			actorRef.EquipItem(DressData.CompanionNudeSuit, true, true) ; prevent NPC main outfit auto-equip
			Utility.WaitMenuMode(0.15)
		endIf
	else
		DTDebug(" equip Nude Ring on " + actorRef, 2)
		
		actorRef.EquipItem(DTSleep_NudeRing, true, true)  ; v1.33 prevent bump 
		Utility.WaitMenuMode(0.16)
		
		if (!hasSleepMainOutfit)
			; sometimes works on NPCs - fine for sleep scene
			actorRef.UnequipItemSlot(3) ; 33 - nude ring doesn't include main body
		endIf
	endIf
endFunction

; v2.14 - moved final player checks here and added checks
;
Function UndressActorFinalCheckArmors(Actor actorRef, bool skipUpperOuterArmorSlots)

	if (actorRef == PlayerRef)
	
		; double-check torso armor - armors with auto-equip like Manhunter by Neiro may re-equip

		if (!skipUpperOuterArmorSlots)
			if (DressData.PlayerEquippedArmorTorsoItem != None)
				actorRef.UnequipItem(DressData.PlayerEquippedArmorTorsoItem, false, true)
				DTDebug(" player final check: armor-torso needs removing " + DressData.PlayerEquippedArmorTorsoItem, 2)
			endIf
			if (DressData.PlayerEquippedArmorArmLeftItem != None)
				actorRef.UnequipItem(DressData.PlayerEquippedArmorArmLeftItem, false, true)
				DTDebug(" player final check: armor-left-arm needs removing " + DressData.PlayerEquippedArmorArmLeftItem, 2)
			endIf
			if (DressData.PlayerEquippedArmorArmRightItem != None)
				actorRef.UnequipItem(DressData.PlayerEquippedArmorArmRightItem, false, true)
				DTDebug(" player final check: armor-right-arm needs removing " + DressData.PlayerEquippedArmorArmRightItem, 2)
			endIf
		endIf
		if (DressData.PlayerEquippedArmorLegLeftItem != None)
			actorRef.UnequipItem(DressData.PlayerEquippedArmorLegLeftItem, false, true)
			DTDebug(" player final check: armor-left-leg needs removing " + DressData.PlayerEquippedArmorLegLeftItem, 2)
		endIf
		if (DressData.PlayerEquippedArmorLegRightItem != None)
			actorRef.UnequipItem(DressData.PlayerEquippedArmorLegRightItem, false, true)
			DTDebug(" player final check: armor-right-leg needs removing " + DressData.PlayerEquippedArmorLegRightItem, 2)
		endIf
			
	elseIf (actorRef == CompanionRef)
	
		if (!skipUpperOuterArmorSlots)
			if (DressData.CompanionEquippedArmorTorsoItem != None)
				
				actorRef.UnequipItem(DressData.CompanionEquippedArmorTorsoItem, false, true)
				DTDebug(" companion final check: armor-torso needs removing " + DressData.CompanionEquippedArmorTorsoItem, 2)
			endIf
			if (DressData.CompanionEquippedArmorArmLeftItem != None)
				
				actorRef.UnequipItem(DressData.CompanionEquippedArmorArmLeftItem, false, true)
				DTDebug(" companion final check: armor-left-arm needs removing " + DressData.CompanionEquippedArmorArmLeftItem, 2)
			endIf
			if (DressData.CompanionEquippedArmorArmRightItem != None)
				
				actorRef.UnequipItem(DressData.CompanionEquippedArmorArmRightItem, false, true)
				DTDebug(" companion final check: armor-right-arm needs removing " + DressData.CompanionEquippedArmorArmRightItem, 2)
			endIf
		endIf
		if (DressData.CompanionEquippedArmorLegLeftItem != None)
			
			actorRef.UnequipItem(DressData.CompanionEquippedArmorLegLeftItem, false, true)
			DTDebug(" companion final check: armor-left-leg needs removing " + DressData.CompanionEquippedArmorLegLeftItem, 2)
		endIf
		if (DressData.CompanionEquippedArmorLegRightItem != None)
			
			actorRef.UnequipItem(DressData.CompanionEquippedArmorLegRightItem, false, true)
			DTDebug(" companion final check: armor-right-leg needs removing " + DressData.CompanionEquippedArmorLegRightItem, 2)
		endIf
	endIf

endFunction

; returns found count placed or not
UndressPlacedSet Function UndressActorExtraArmorList(Actor actorRef, FormList inArmorList, bool placeAtActorBed = false, bool useGenericBag = false)
	UndressPlacedSet result = new UndressPlacedSet
	
	if (inArmorList == None || actorRef == None)
		return result
	endIf
	int foundCount = 0
	int len = inArmorList.GetSize()
	int placedCount = 0
	if (PlacedArmorObjRefArray)
		placedCount = PlacedArmorObjRefArray.length
	endIf
	
	if (len > 0)
		int idx = 0
		while (idx < len)
			Armor armorItem = inArmorList.GetAt(idx) as Armor
			
			if (armorItem && actorRef.GetItemCount(armorItem) > 0 && actorRef.IsEquipped(armorItem))   ; takes 0.05 seconds
				actorRef.UnequipItem(armorItem, false, true)
				foundCount += 1
	
				if (placeAtActorBed && placedCount < 1)
					
					ObjectReference bedRef = None
					
					if (actorRef == PlayerRef)
						bedRef = PlayerBedRef
					elseIf (actorRef == CompanionRef)
						bedRef = CompanionBedRef
					endIf
					
					placedCount += UndressPlaceExtraArmorForBed(bedRef, actorRef, armorItem, 0, useGenericBag)

				endIf
				
				if (actorRef == CompanionRef && DressData.CompanionActor)
					if (inArmorList == DTSleep_ArmorBackPacksList)
						DressData.CompanionEquippedBackpackItem = armorItem
						DressData.CompanionBackPackNoGOModel = false
					elseIf (inArmorList == DTSleep_ArmorBackPacksnoGOList)
						DressData.CompanionEquippedBackpackItem = armorItem
						DressData.CompanionBackPackNoGOModel = true
					endIf
				endIf
			endIf
			idx += 1
		endWhile
	endIf
	
	result.FoundItemCount = foundCount
	result.PlacedItemCount = placedCount
	
	return result
EndFunction

int Function UndressPlaceExtraArmorAtFeet(Actor actorRef, Armor armorItem, bool useGenericBag = false)
	int count = 0
	if (actorRef != None && armorItem != None)
		
		if (useGenericBag && DTSGenericBagItem != None)
			if (PlaceFormNearFeet(DTSGenericBagItem, actorRef))
				count += 1
			endIf
		elseIf (PlaceFormNearFeet(armorItem as Form, actorRef))
			count += 1
		endIf
	endIf
	
	return count
endFunction

int Function UndressPlaceExtraArmorForBed(ObjectReference bedRef, Actor actorRef, Armor armorItem, int cornerVal = 0, bool useGenericBag = false)
	int count = 0
	if (actorRef != None && bedRef != None && armorItem != None)
		if (useGenericBag && DTSGenericBagItem != None)
			if (PlaceFormItemAtBed(DTSGenericBagItem, bedRef, actorRef, cornerVal))
				count += 1
			endIf
		elseIf (PlaceFormItemAtBed(armorItem as Form, bedRef, actorRef, cornerVal))
			count += 1
		endIf
	endIf
	
	return count
endFunction

Armor Function UndressPlayerIntimateItem(bool silent = false)
	Armor item = None
	
	if (DressData.PlayerEquippedIntimateAttireItem != None)
		item = DressData.PlayerEquippedIntimateAttireItem
		PlayerRef.UnequipItem(item, false, silent)
		Utility.WaitMenuMode(0.1)
	endIf
	
	return item
endFunction

; only for initialed DressData
Armor Function UndressPlayerJacket(bool silent = false)
	Armor jacket = None
	
	if (DressData.PlayerEquippedJacketItem != None)
		
		jacket = DressData.PlayerEquippedJacketItem
		
		PlayerRef.UnequipItem(jacket, false, silent)
		Utility.WaitMenuMode(0.1)
	endIf
	
	return jacket
endFunction

Armor Function UndressPlayerMask(bool silent = false)
	Armor mask = None
	
	if (DressData.PlayerEquippedMask != None)
		mask = DressData.PlayerEquippedMask
		PlayerRef.UnequipItem(mask, false, silent)
		Utility.WaitMenuMode(0.1)
	endIf
	
	return mask
endFunction

; no placement - just remove - external may use
Armor Function UndressPlayerPackOrPouch(bool silent = false)
	Armor backpack = None
	
	; unusual first
	if (DressData.PlayerEquippedCarryPouchItem != None)
		backpack = DressData.PlayerEquippedCarryPouchItem
		PlayerRef.UnequipItem(backpack, false, silent)
		Utility.WaitMenuMode(0.1)
	endIf
	
	
	; common second to prefer return
	if (DressData.PlayerEquippedBackpackItem != None)
		backpack = DressData.PlayerEquippedBackpackItem
		PlayerRef.UnequipItem(backpack, false, silent)
		Utility.WaitMenuMode(0.1)
	endIf
	
	return backpack
endFunction

Armor Function UndressPlayerSleepwear(bool silent = false)
	Armor sleepItem = None
	
	if (DressData.PlayerEquippedSleepwearItem != None)
		sleepItem = DressData.PlayerEquippedSleepwearItem
	elseIf (DressData.PlayerEquippedSlot58IsSleepwear && DressData.PlayerEquippedSlot58Item)
		sleepItem = DressData.PlayerEquippedSlot58Item
	elseIf (DressData.PlayerEquippedSlotFXIsSleepwear && DressData.PlayerEquippedSlotFXItem)
		sleepItem = DressData.PlayerEquippedSlotFXItem
	endIf
	
	if (sleepItem != None)
		PlayerRef.UnequipItem(sleepItem, false, silent)
	endIf
	
	return sleepItem
endFunction

Armor Function UndressPlayerStrapOn(bool silent = false)
	Armor item = None
	
	if (DressData.PlayerEquippedStrapOnItem != None)
		item = DressData.PlayerEquippedStrapOnItem
		PlayerRef.UnequipItem(item, false, silent)
		Utility.WaitMenuMode(0.1)
	endIf
	
	return item
endFunction


Function UndressJacketForActor(Actor actorRef)
	if (actorRef)
		if (DTSleep_EquipMonInit.GetValueInt() > 0)
			if (actorRef == PlayerRef)
				UndressPlayerJacket(true)
				
			elseIf (actorRef == CompanionRef && DressData.CompanionEquippedJacketItem != None && DressData.CompanionDressValid)
				actorRef.UnequipItem(DressData.CompanionEquippedJacketItem, false, true)
			else
				UndressActorExtraArmorList(actorRef, DTSleep_ArmorJacketsClothingList)
			endIf
		else
			UndressActorExtraArmorList(actorRef, DTSleep_ArmorJacketsClothingList)
		endIf
	endIf
endFunction

Function WaitForEquipSleepwearActor(Actor actorRef)

	int waitCount = 16
	bool sleepEquipped = false
	
	while (waitCount > 0 && !sleepEquipped)
	
		Utility.WaitMenuMode(0.05)
		
		if (actorRef == PlayerRef)
			if (DressData.PlayerEquippedSleepwearItem != None)
				sleepEquipped = true
			elseIf (DressData.PlayerEquippedSlot58IsSleepwear || DressData.PlayerEquippedSlotFXIsSleepwear)
				sleepEquipped = true
			endIf
		elseIf (actorRef == CompanionRef)
			if (DressData.CompanionEquippedSleepwearItem != None)
				sleepEquipped = true
				;Debug.Trace(myScriptName + " in sleepwear! waitCount: " + waitCount)
			elseIf (DressData.CompanionEquippedSlot58IsSleepwear)
				;Debug.Trace(myScriptName + " in slot58! waitCount: " + waitCount)
				sleepEquipped = true
			endIf
		endIf
		
		waitCount -= 1
	endWhile
					
endFunction

; ---------------------------------------------------
; Deprecated / not used
;
Group Z_Deprecated
bool property PlayerInSleepwearToRemove auto hidden
{ deprecated }
bool property CompanionInSleepwearToRemove auto hidden
{ deprecated }
Armor property ClothesBathrobe auto const
{ deprecated - see SleepAttire lists }
EndGroup