ScriptName DTSleep_PlayerAliasScript extends ReferenceAlias

; ********************* 
; player alias - main quest for Sleep Intimate
; by DracoTorre
;
; compatibility check for mods, updates version, and reports events for main quest
;
; by DracoTorre
; www.dracotorre.com/mods/sleepintimate/

; ***************************************
; * Properties
;

Group A_GameData
Quest property DTSleep_MCMQuestP auto const
Quest property DTSleep_SMMQuestP auto const
GlobalVariable property DTSleep_MCMEnable auto const
FormList property modScrapRecipe_NullMelee_Cloth auto const
GlobalVariable property DTSleep_Version auto const
GlobalVariable property DTSleep_LastVersion auto
GlobalVariable property DTSleep_SIXPatch auto const
GlobalVariable property DTSleep_IsLeitoActive auto
GlobalVariable property DTSleep_IsSYSCWActive auto
GlobalVariable property DTSleep_SettingPrefSYSC auto
GlobalVariable property DTSleep_IsSoSActive auto
GlobalVariable property DTSleep_IsSleepTogetherActive auto
GlobalVariable property DTSleep_IsZaZOut auto
GlobalVariable property DTSleep_SettingUseLeitoGun auto const
GlobalVariable property DTSleep_SettingUndressTimer auto
DTSleep_MainQuestScript property SleepQuestScript auto
Quest property DTSConditionals auto
GlobalVariable property DTSleep_PlayerUsingBed auto
GlobalVariable property DTSleep_ExtraArmorsEnabled auto
GlobalVariable property DTSleep_AdultContentOn auto const
{ disable to block loading forms from adult mods }
GlobalVariable property DTSleep_CompanionUndressed auto const
GlobalVariable property DTSleep_PlayerUndress auto const
GlobalVariable property DTSleep_SettingUndressPipboy auto const
GlobalVariable property DTSleep_IntimateLocCountThreshold auto
GlobalVariable property DTSleep_TestTourLocAtIdx auto
GlobalVariable property DTSleep_ActivChairs auto
GlobalVariable property DTSleep_ActivPAStation auto
GlobalVariable property DTSleep_ActivFlagpole auto
GlobalVariable property DTSleep_EquipMonInit auto const
GlobalVariable property DTSleep_PlayerCollisionEnabled auto					; added v2.70 - check to reset collision
Keyword property DTSleep_WorkshopRecipeKY auto const
Armor property DTSleep_NudeSuit auto const
Armor property DTSleep_ClothesBathrobePink auto const
Armor property DTSleep_ClothesBathrobePurple auto const
Armor property DTSleep_ClothesBathrobeRed auto const
Armor property DTSleep_ClothesBathrobeWhite auto const
Container property DTSleep_Outfit_FedDresserShort01 auto const
Container property DTSleep_Outfit_PH_Dresser01 auto const
Container property DTSleep_VaultLocker auto const
FormList property WorkshopMenu01Furniture auto const
FormList property DTSleep_IntimacyChanceMEList auto
FormList property DTSleep_UndressLocationList auto const
FormList property DTSleep_PrivateLocationList auto const
FormList property DTSleep_TownLocationList auto const
{ towns, settlements, and other fortified locations for safer intimacy }
FormList property DTSleep_IntimateTourLocList auto const
FormList property DTSleep_BedsBigList auto const
FormList property DTSleep_BedsBigDoubleList auto const
FormList property DTSleep_BedsBunkList auto const   ; v2.25
FormList property DTSleep_BedList auto const
FormList property DTSleep_BedChildList auto const
FormList property DTSleep_BedsLimitedSpaceLst auto const
FormList property DTSleep_BedPlacedNoRestList auto const
{ bad bed types if in specific cells }
FormList property DTSleep_BedCellNoRestList auto const
{ cells that have bad beds listed above }
FormList property DTSleep_BedIntimateList auto const
{ mod-added beds like Campsite }
FormList property DTSleep_FemBedItemFList auto const
FormList property DTSleep_BadSheltersList auto const
FormList property DTSleep_BedNoIntimateList auto const
FormList property DTSleep_BedPillowBedList auto const
FormList property DTSleep_BedPillowFrameDBList auto const
FormList property DTSleep_BedPillowFrameSBList auto const
FormList property DTSleep_BedPillowFrameBadList auto const
FormList property DTSleep_BedBunkFrameList auto const
FormList property DTSleep_ModCompanionActorList auto const
{ safe for intimacy - base forms only }
FormList property DTSleep_CandyTreatsList auto const
FormList property DTSleep_CompanionRomance2List auto const
FormList property DTSleep_CompanionIntimateAllList auto const
FormList property DTSleep_PilloryList auto const
FormList property DTSleep_TortureDList auto const
FormList property DTSleep_IntimateBenchList auto const
FormList property DTSleep_IntimateBenchAdjList auto const
{ bench with short backrest }
FormList property DTSleep_IntimateKitchenSeatList auto const
FormList property DTSleep_IntimateCouchList auto const
FormList property DTSleep_IntimateCouchFedList auto const
FormList property DTSleep_IntimateChairHighList auto const
FormList property DTSleep_IntimateChairLowList auto const
FormList property DTSleep_IntimateChairsList auto const
FormList property DTSleep_IntimateChairThroneList auto const
FormList property DTSleep_IntimateRoundTableList auto const
FormList property DTSleep_IntimateStoolNoAngleList auto const
FormList property DTSleep_IntimateStoolBackList auto const
FormList property DTSleep_IntimateShowerList auto const
FormList property DTSleep_IntimatePropList auto const
FormList property DTSleep_IntimateSedanPreWarList auto const
FormList property DTSleep_IntimateWeightBenchList auto const 		; added v2.25
FormList property DTSleep_SettlerFactionList auto const
FormList property DTSleep_IntimateDinerBoothTableAllList auto const ; added v2.35
FormList property DTSleep_JailDoorBadLocationList auto const 		; added v2.40
FormList property DTSleep_IntimateDeskList auto const 			; added v2.51
FormList property DTSleep_IntimateDesk90List auto const 			; added v2.51
FormList property DTSleep_BedPrivateList auto const					; added v2.53
FormList property DTSleep_IntimateChairOttomanList auto const		; added v2.60
FormList property DTSleep_NotHumanList auto const					; added 2.62
FormList property DTSleep_IntimateRailingList auto const			; added v2.70
FormList property DTSleep_IntimateLockerList auto const				; added v2.77
FormList property DTSleep_IntimateLockerAdjList auto const			; 
Message property DTSleep_VersionMsg auto const
Message property DTSleep_VersionDowngradeMsg auto const				; v2.60
Message property DTSleep_VersionExplicitMsg auto const
Message property DTSleep_VersionSafeMsg auto const
Message property DTSleep_VersionOffMsg auto const
Message property DTSleep_VersionUpUndressMsg auto const
Message property DTSleep_AdultPlatformWarnMsg auto const
Message property DTSleep_BadVersWarnMsg auto const
Message property DTSleep_TestSetResetMsg auto const
LeveledItem property LLI_Vendor_Clothes_Any_Rare auto const
EndGroup

Group B_ArmorLists
FormList property DTSleep_ArmorExtraPartsList auto const
FormList property DTSleep_ArmorBackPacksList auto const
FormList property DTSleep_ArmorBackPacksNoGOList auto const
FormList property DTSleep_ArmorCarryPouchList auto const
FormList property DTSleep_ArmorExtraClothingList auto const
FormList property DTSleep_ArmorHatHelmList auto const
FormList property DTSleep_ArmorJacketsClothingList auto const
FormList property DTSleep_ArmorSlotULegList auto const
FormList property DTSleep_ArmorSlot41List auto const
FormList property DTSleep_ArmorSlot55List auto const
FormList property DTSleep_ArmorSlot58List auto const
FormList property DTSleep_ArmorSlotFXList auto const
FormList property DTSleep_ArmorJewelry58List auto const
FormList property DTSleep_ArmorJewelry57List auto const				; added v2.71
FormList property DTSleep_ArmorJewelry56List auto const				; added v2.71
FormList property DTSleep_ArmorAllExceptionList auto const
FormList property DTSleep_StrapOnList auto const
FormList property DTSleep_SleepAttireFemale auto const
FormList property DTSleep_SleepAttireMale auto const
FormList property DTSleep_LeitoGunList auto const
FormList property DTSleep_ArmorChokerList auto const
FormList property DTSleep_ArmorNecklaceSlot50List auto const
FormList property DTSleep_ArmorMaskList auto const
FormList property DTSleep_ModCompanionBodiesLst auto const
FormList property DTSleep_ArmorPipPadList auto const
FormList property DTSleep_ArmorGlassesList auto const
FormList property DTSleep_IntimateAttireFemaleOnlyList auto const
FormList property DTSleep_IntimateAttireList auto const
FormList property DTSleep_ArmorPipBoyList auto const
FormList property DTSleep_ArmorTorsoList auto const
FormList property DTSleep_ArmorArmLeftList auto const
FormList property DTSleep_ArmorArmRightList auto const
FormList property DTSleep_ArmorLegLeftList auto const
FormList property DTSleep_ArmorLegRightList auto const
FormList property DTSleep_SexyClothesFList auto const
FormList property DTSleep_SexyClothesMList auto const
FormList property DTSleep_IntimateAttireOKUnderList auto const
{ must remove under armor on these intimate outfits -- usually slot-33 only with shoes }
FormList property DTSleep_SleepAttireHandsList auto const
FormList property DTSleep_QuestItemModList auto const				; added v2.53
EndGroup

Group C_AnimSeqLists
FormList property DTSleep_LeitoBlowjobA1List auto const
FormList property DTSleep_LeitoBlowjobA2List auto const
FormList property DTSleep_LeitoCanineDogList auto const
FormList property DTSleep_LeitoCanineFemaleList auto const
FormList property DTSleep_LeitoCanine2DogList auto const
FormList property DTSleep_LeitoCanine2FemaleList auto const
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
FormList property DTSleep_LeitoMissionary1A1List auto const
FormList property DTSleep_LeitoMissionary1A2List auto const
FormList property DTSleep_LeitoMissionary2A1List auto const
FormList property DTSleep_LeitoMissionary2A2List auto const
FormList property DTSleep_LeitoSpoonA1List auto const
FormList property DTSleep_LeitoSpoonA2List auto const
FormList property DTSleep_LeitoStandDoggy1A1List auto const
FormList property DTSleep_LeitoStandDoggy1A2List auto const
FormList property DTSleep_LeitoStandDoggy2A1List auto const
FormList property DTSleep_LeitoStandDoggy2A2List auto const
FormList property DTSleep_LeitoStrongMaleList auto const
FormList property DTSleep_LeitoStrongFemaleList auto const
FormList property DTSleep_CrazyGunBedFemaleList auto const
FormList property DTSleep_CrazyGunBedMaleList auto const
FormList property DTSleep_CrazyGunStandFemaleList auto const
FormList property DTSleep_CrazyGunStandMaleList auto const
FormList property DTSleep_Dance2List auto const
;FormList property DTSleep_ZaZIdleFList auto const
;FormList property DTSleep_ZaZIdleMList auto const
EndGroup

; hidden properties

Location property CurrentLocation auto hidden
int property ActiveLevel auto hidden

string myScriptName = "[DTSleep-Intimate]" const


; *****************************************************
;    Events
 
Event OnKill(Actor akVictim)
  SleepQuestScript.PlayerKilledActor(akVictim)
endEvent

Event OnPlayerLoadGame()
	
	(DTSConditionals as DTSleep_Conditionals).HasReloaded = true
	SleepQuestScript.DTSleep_SIDIgnoreOK.SetValueInt(-3)					; v2.74 reset on load
	
	; v2.70 - check player collision
	if (DTSleep_PlayerCollisionEnabled.GetValueInt() <= 0)
		Utility.SetIniBool("bDisablePlayerCollision:Havok", false)			; reset
		DTSleep_PlayerCollisionEnabled.SetValueInt(1)
		Debug.Trace(myScriptName + " OnLoad re-enable player-collision!!!")
	endIf
	
	if ((DTSConditionals as DTSleep_Conditionals).ImaPCMod)
		if ((DTSConditionals as DTSleep_Conditionals).IsAAFActive)
			CheckF4SEMCM(true)
		else
			CheckF4SEMCM(false)
		endIf
	endIf
	
	if (DTSleep_PlayerUsingBed.GetValue() > 0.0 || SleepQuestScript.SleepBedUsesBlock)
		if (SleepQuestScript.SleepBedInUseRef == None)
			Debug.Trace(myScriptName + " OnLoad reset sleepQuest")
			SleepQuestScript.ResetAll()
		else
			
			SleepQuestScript.ResetSceneOnLoad()
		endIf
	; else check reload??
	endIf
	
	
	StartTimer(4.2, 13)
EndEvent

Event OnPlayerSwimming()
	SleepQuestScript.EnteredSwimmingState()
endEvent

; faster to record current location than looking up location at bedtime
Event OnLocationChange(Location akOldLoc, Location akNewLoc)
	if (akNewLoc)
		CurrentLocation = akNewLoc
		
		if (DTSleep_PlayerUsingBed.GetValue() > 0.0 || SleepQuestScript.SleepBedUsesBlock)
			SleepQuestScript.ResetAll()
			
		elseIf (DTSleep_CompanionUndressed.GetValue() > 0.0 || DTSleep_PlayerUndress.GetValue() > 0.0)
			SleepQuestScript.RedressCompanion()
		endIf
		
		if (ActiveLevel > 0)
			int index = DTSleep_IntimateTourLocList.Find(akNewLoc as Form)
			DTSleep_TestTourLocAtIdx.SetValueInt(index)
			
			SleepQuestScript.CheckLocation(akOldLoc, CurrentLocation)
		endIf
	endIf
endEvent

Event OnCombatStateChanged(Actor akTarget, int aeCombatState)
	if (ActiveLevel > 0)
		if (aeCombatState == 1)

			if (DTSleep_PlayerUsingBed.GetValue() > 0.0)
				SleepQuestScript.EnteredCombatInBed()
			endIf

		endIf
	endIf
endEvent

; player sneak control disabled in scenes -- if error prevents scene, this backup control resets
Event OnEnterSneaking()
	if (DTSleep_PlayerUsingBed.GetValue() > 0.0 || SleepQuestScript.SleepBedUsesBlock)
		;Debug.Notification("DTSleep cancel bed on sneak")
		SleepQuestScript.ResetAll()
	elseIf (DTSleep_PlayerUndress.GetValue() > 0.0)
		SleepQuestScript.ResetAll()
	elseIf (!Game.IsFightingControlsEnabled() || !Game.IsMenuControlsEnabled())
		if (ActiveLevel > 0)
			SleepQuestScript.ResetAll()
		endIf
	endIf
endEvent

Event OnTimer(int aiTimerID)
	if (aiTimerID == 13)
		if (CheckGameSettings())
		
			CheckCompatibility()
			
			SleepQuestScript.ProcessCompatibleMods()
			
			if (DTSleep_LastVersion.GetValue() != DTSleep_Version.GetValue())
				UpgradeToVersion()
			endIf
		else
			; uh-oh something went wrong - quit
			Game.QuitToMainMenu()
		endIf
	endIf
EndEvent

; ***************************************************************
;   Functions
;

; adds to normal list and mod-bed list
Function AddToBedsList(Form bedForm, bool isDoubleBed = false, FormList otherList = None)
	if (bedForm != None)
		DTSleep_BedList.AddForm(bedForm)
		DTSleep_BedIntimateList.AddForm(bedForm)
		if (isDoubleBed)
			DTSleep_BedsBigDoubleList.AddForm(bedForm)
		endIf
		if (otherList != None)
			otherList.AddForm(bedForm)
		endIf
	endIf
endFunction

int Function AddStrapOnToLists(Armor strapOn, FormList list2)
	if (strapOn != None)
		if (!DTSleep_StrapOnList.HasForm(strapOn))
			DTSleep_StrapOnList.AddForm(strapOn)
			if (list2)
				list2.AddForm(strapOn)
			endIf
			
			LLI_Vendor_Clothes_Any_Rare.AddForm(strapOn, 1, 1)
			return 1
		endIf
	endIf
	return 0
endFunction

Function AddSleepTogetherSeats()

	Form seatForm = Game.GetFormFromFile(0x0902FC25, "Hoamaii_SleepTogetherAnywhere.esp")								; driftwood bench
	if (seatForm != None && !DTSleep_IntimateBenchList.HasForm(seatForm))
		Debug.Trace(myScriptName + " indexing Sleep Together seats...")
		DTSleep_IntimateBenchList.AddForm(seatForm)
		;seatForm = Game.GetFormFromFile(0x0902FC29, "Hoamaii_SleepTogetherAnywhere.esp")								; Lobster Cage bench clips too much
		;DTSleep_IntimateBenchList.AddForm(seatForm)
		;DTSleep_IntimateBenchAdjList.AddForm(seatForm)
		;DTSleep_IntimateBenchList.AddForm(Game.GetFormFromFile(0x09034FC7, "Hoamaii_SleepTogetherAnywhere.esp"))		; suitcase bench
		DTSleep_IntimateStoolNoAngleList.AddForm(Game.GetFormFromFile(0x0902FC28, "Hoamaii_SleepTogetherAnywhere.esp"))	; Barricade stool
		DTSleep_IntimateStoolNoAngleList.AddForm(Game.GetFormFromFile(0x0902FC26, "Hoamaii_SleepTogetherAnywhere.esp"))	; Lobster Cage stool
		DTSleep_IntimateStoolBackList.AddForm(Game.GetFormFromFile(0x09023DCB, "Hoamaii_SleepTogetherAnywhere.esp"))	; crate stool
		DTSleep_IntimateStoolNoAngleList.AddForm(Game.GetFormFromFile(0x090312FA, "Hoamaii_SleepTogetherAnywhere.esp"))	; office box stool
		DTSleep_IntimateChairHighList.AddForm(Game.GetFormFromFile(0x0902FC2D, "Hoamaii_SleepTogetherAnywhere.esp"))		; federalist chair
	endIf
	DTSleep_IsSleepTogetherActive.SetValue(2.0)
endFunction

Function CheckCompatibility()
	Debug.Trace(myScriptName + " =====================================================================")
	Debug.Trace(myScriptName + "               *****      SleepIntimate v" + DTSleep_Version.GetValue() + "  *****")
	Debug.Trace(myScriptName + "     -- begin compatibility check -- ")
	Debug.Trace(myScriptName + " =====================================================================")

	
	; Robot DLC
	;
	if ((DTSConditionals as DTSleep_Conditionals).IsRobotDLCActive == false)
		Armor helmet = IsPluginActive(0x0200864A, "DLCRobot.esm") as Armor
		if (helmet != None)
			(DTSConditionals as DTSleep_Conditionals).IsRobotDLCActive = true
			if (!DTSleep_ArmorHatHelmList.HasForm(helmet))
				DTSleep_ArmorHatHelmList.AddForm(helmet)
				DTSleep_ArmorHatHelmList.AddForm(Game.GetFormFromFile(0x0200864C, "DLCRobot.esm"))
				DTSleep_ArmorHatHelmList.AddForm(Game.GetFormFromFile(0x0200864E, "DLCRobot.esm"))
				DTSleep_ArmorHatHelmList.AddForm(Game.GetFormFromFile(0x02008BC3, "DLCRobot.esm"))
			endIf
		endIf
		Form locForm = Game.GetFormFromFile(0x020008A4, "DLCRobot.esm")  ;Lair
		if (locForm != None && !DTSleep_UndressLocationList.HasForm(locForm))
			DTSleep_UndressLocationList.AddForm(locForm)
			DTSleep_UndressLocationList.AddForm(Game.GetFormFromFile(0x0201089D, "DLCRobot.esm"))
			DTSleep_JailDoorBadLocationList.AddForm(locForm)			; v2.40
		endIf
		
		(DTSConditionals as DTSleep_Conditionals).RobotAdaRef = Game.GetFormFromFile(0x0200FF12, "DLCRobot.esm") as Actor
		(DTSConditionals as DTSleep_Conditionals).RobotMQ105Quest = Game.GetFormFromFile(0x020010F5, "DLCRobot.esm") as Quest
		
		LoadHelmetsRobot()
		
		;v2 armors
		DTSleep_ArmorTorsoList.AddForm(Game.GetFormFromFile(0x0200863F, "DLCRobot.esm"))
		DTSleep_ArmorArmRightList.AddForm(Game.GetFormFromFile(0x02008642, "DLCRobot.esm"))
		DTSleep_ArmorArmLeftList.AddForm(Game.GetFormFromFile(0x02008644, "DLCRobot.esm"))
		DTSleep_ArmorLegRightList.AddForm(Game.GetFormFromFile(0x02008646, "DLCRobot.esm"))
		DTSleep_ArmorLegLeftList.AddForm(Game.GetFormFromFile(0x02008648, "DLCRobot.esm"))
	endIf
	
	; Far Harbor DLC
	;
	if ((DTSConditionals as DTSleep_Conditionals).IsCoastDLCActive == false)
		Armor bodyExtra = IsPluginActive(0x0200914E, "DLCCoast.esm") as Armor
		if (bodyExtra != None)
			(DTSConditionals as DTSleep_Conditionals).IsCoastDLCActive = true
			
			if (!DTSleep_ArmorAllExceptionList.HasForm(bodyExtra as Form))
				DTSleep_ArmorAllExceptionList.AddForm(bodyExtra)
				DTSleep_ArmorAllExceptionList.AddForm(Game.GetFormFromFile(0x0300914F, "DLCCoast.esm"))
				DTSleep_ArmorAllExceptionList.AddForm(Game.GetFormFromFile(0x030247C8, "DLCCoast.esm"))
				DTSleep_ArmorAllExceptionList.AddForm(Game.GetFormFromFile(0x030305BE, "DLCCoast.esm"))
				DTSleep_ArmorAllExceptionList.AddForm(Game.GetFormFromFile(0x030391E6, "DLCCoast.esm"))
				DTSleep_ArmorAllExceptionList.AddForm(Game.GetFormFromFile(0x03048234, "DLCCoast.esm"))
				DTSleep_ArmorAllExceptionList.AddForm(Game.GetFormFromFile(0x0304B9B1, "DLCCoast.esm"))
				DTSleep_ArmorAllExceptionList.AddForm(Game.GetFormFromFile(0x0304E698, "DLCCoast.esm"))
				DTSleep_ArmorAllExceptionList.AddForm(Game.GetFormFromFile(0x0304FA88, "DLCCoast.esm"))
				DTSleep_ArmorAllExceptionList.AddForm(Game.GetFormFromFile(0x030570D3, "DLCCoast.esm"))
				DTSleep_ArmorAllExceptionList.AddForm(Game.GetFormFromFile(0x030570D4, "DLCCoast.esm"))
				DTSleep_ArmorAllExceptionList.AddForm(Game.GetFormFromFile(0x030570D9, "DLCCoast.esm"))
				DTSleep_ArmorAllExceptionList.AddForm(Game.GetFormFromFile(0x030570DA, "DLCCoast.esm"))
			endIf
			
			Form locForm = Game.GetFormFromFile(0x03038AE6, "DLCCoast.esm")
			if (locForm && !DTSleep_UndressLocationList.HasForm(locForm))    ; Vault 118
				DTSleep_UndressLocationList.AddForm(locForm)
				locForm = Game.GetFormFromFile(0x03006126, "DLCCoast.esm")   ; Acadia
				DTSleep_UndressLocationList.AddForm(locForm)
				DTSleep_IntimateTourLocList.AddForm(locForm)
				(DTSConditionals as DTSleep_Conditionals).LocTourFHAcadiaIndex = DTSleep_IntimateTourLocList.GetSize() - 1
				DTSleep_IntimateTourLocList.AddForm(Game.GetFormFromFile(0x030217D4, "DLCCoast.esm"))	; Grand Harbor Hotel
				(DTSConditionals as DTSleep_Conditionals).LocTourFHGHotelIndex = DTSleep_IntimateTourLocList.GetSize() - 1
				DTSleep_UndressLocationList.AddForm(Game.GetFormFromFile(0x03004477, "DLCCoast.esm"))   ; Nucleus
				DTSleep_TownLocationList.AddForm(Game.GetFormFromFile(0x0300220C, "DLCCoast.esm"))       ; Nakano
				DTSleep_TownLocationList.AddForm(Game.GetFormFromFile(0x03005C79, "DLCCoast.esm")) 		; Far Harbor
				DTSleep_TownLocationList.AddForm(Game.GetFormFromFile(0x03004C7C, "DLCCoast.esm")) 		; Eden Meadows Cinemas
				DTSleep_TownLocationList.AddForm(Game.GetFormFromFile(0x03009353, "DLCCoast.esm")) 		; Visitors Center
				DTSleep_TownLocationList.AddForm(Game.GetFormFromFile(0x0300AFF9, "DLCCoast.esm")) 		; Mother's Shrine
				DTSleep_TownLocationList.AddForm(Game.GetFormFromFile(0x0300F044, "DLCCoast.esm")) 		; Horizon Flight
				DTSleep_TownLocationList.AddForm(Game.GetFormFromFile(0x0300F101, "DLCCoast.esm")) 		; Echo Lake
				DTSleep_TownLocationList.AddForm(Game.GetFormFromFile(0x0301049F, "DLCCoast.esm")) 		; NP Headquarters
				DTSleep_TownLocationList.AddForm(Game.GetFormFromFile(0x03020649, "DLCCoast.esm")) 		; Longfellow's Cabin
				DTSleep_TownLocationList.AddForm(Game.GetFormFromFile(0x030247BE, "DLCCoast.esm")) 		; NP Camp
				DTSleep_TownLocationList.AddForm(Game.GetFormFromFile(0x03038EAE, "DLCCoast.esm")) 		; Dalton Farm
				DTSleep_TownLocationList.AddForm(Game.GetFormFromFile(0x030140E0, "DLCCoast.esm")) 		; Eagle Cove Tannery
				DTSleep_TownLocationList.AddForm(Game.GetFormFromFile(0x0300F041, "DLCCoast.esm")) 		; Cliff's Edge Hotel
				
				DTSleep_IntimateLocCountThreshold.SetValueInt(DTSleep_IntimateTourLocList.GetSize())
			endIf
			
			Actor longfellowRef = Game.GetFormFromFile(0x03014602, "DLCCoast.esm") as Actor
			if (longfellowRef != None)
				(DTSConditionals as DTSleep_Conditionals).FarHarborDLCLongfellowRef = longfellowRef
				(DTSConditionals as DTSleep_Conditionals).FarHarborDLCLongfellowPerk = Game.GetFormFromFile(0x03018621, "DLCCoast.esm") as Perk
				
				DTSleep_CompanionIntimateAllList.AddForm(longfellowRef as Form)
			endIf
			
			Cell bCell = Game.GetFormFromFile(0x03000C69, "DLCCoast.esm") as Cell
			if (bCell != None && !DTSleep_BedCellNoRestList.HasForm(bCell))
				DTSleep_BedCellNoRestList.AddForm(bCell)
				DTSleep_BedCellNoRestList.AddForm(Game.GetFormFromFile(0x03000D89, "DLCCoast.esm"))
				DTSleep_BedCellNoRestList.AddForm(Game.GetFormFromFile(0x03002747, "DLCCoast.esm"))
				DTSleep_BedCellNoRestList.AddForm(Game.GetFormFromFile(0x03000B97, "DLCCoast.esm"))
			endIf
			
			Quest lastPlankRentQuest = Game.GetFormFromFile(0x0304DE89, "DLCCoast.esm") as Quest
			if (lastPlankRentQuest != None)
				(DTSConditionals as DTSleep_Conditionals).FarHarborBedRentQuest = lastPlankRentQuest
			endIf
			Location lastPlankLoc = Game.GetFormFromFile(0x03005CB6, "DLCCoast.esm") as Location
			(DTSConditionals as DTSleep_Conditionals).FarHarborLastPlankLocation = lastPlankLoc
			
			LoadHelmetsFarHarbor()
			
			; v2 armors
			DTSleep_ArmorArmLeftList.AddForm(Game.GetFormFromFile(0x03009E56, "DLCCoast.esm"))
			DTSleep_ArmorArmRightList.AddForm(Game.GetFormFromFile(0x03009E57, "DLCCoast.esm"))
			DTSleep_ArmorLegLeftList.AddForm(Game.GetFormFromFile(0x03009E59, "DLCCoast.esm"))
			DTSleep_ArmorLegRightList.AddForm(Game.GetFormFromFile(0x03009E5A, "DLCCoast.esm"))
			DTSleep_ArmorTorsoList.AddForm(Game.GetFormFromFile(0x03009E5B, "DLCCoast.esm"))
			
			DTSleep_ArmorArmLeftList.AddForm(Game.GetFormFromFile(0x0300EE75, "DLCCoast.esm"))
			DTSleep_ArmorArmRightList.AddForm(Game.GetFormFromFile(0x0300EE76, "DLCCoast.esm"))
			DTSleep_ArmorLegLeftList.AddForm(Game.GetFormFromFile(0x0300EE77, "DLCCoast.esm"))
			DTSleep_ArmorLegRightList.AddForm(Game.GetFormFromFile(0x0300EE78, "DLCCoast.esm"))
			DTSleep_ArmorTorsoList.AddForm(Game.GetFormFromFile(0x0300EE79, "DLCCoast.esm"))
			
			DTSleep_ArmorArmLeftList.AddForm(Game.GetFormFromFile(0x0300F04A, "DLCCoast.esm"))
			DTSleep_ArmorArmRightList.AddForm(Game.GetFormFromFile(0x0300F04B, "DLCCoast.esm"))
			DTSleep_ArmorLegLeftList.AddForm(Game.GetFormFromFile(0x0300F04C, "DLCCoast.esm"))
			DTSleep_ArmorLegRightList.AddForm(Game.GetFormFromFile(0x0300F04D, "DLCCoast.esm"))
			DTSleep_ArmorTorsoList.AddForm(Game.GetFormFromFile(0x0300F04E, "DLCCoast.esm"))
			
			; v2.70 - railings
			; Echo Lake
			Form railingForm = Game.GetFormFromFile(0x0303DC61, "DLCCoast.esm")
			DTSleep_IntimateRailingList.AddForm(railingForm)
			DTSleep_IntimatePropList.AddForm(railingForm)
			railingForm = Game.GetFormFromFile(0x0303DC63, "DLCCoast.esm")
			DTSleep_IntimateRailingList.AddForm(railingForm)
			DTSleep_IntimatePropList.AddForm(railingForm)
			railingForm = Game.GetFormFromFile(0x0303DC65, "DLCCoast.esm")
			DTSleep_IntimateRailingList.AddForm(railingForm)
			DTSleep_IntimatePropList.AddForm(railingForm)
			; bouy railings Nakano, Far Harbor
			railingForm = Game.GetFormFromFile(0x03001938, "DLCCoast.esm")
			DTSleep_IntimateRailingList.AddForm(railingForm)
			DTSleep_IntimatePropList.AddForm(railingForm)
			railingForm = Game.GetFormFromFile(0x03001932, "DLCCoast.esm")
			DTSleep_IntimateRailingList.AddForm(railingForm)
			DTSleep_IntimatePropList.AddForm(railingForm)
			
			; backward rails at Dalton Farm
			(DTSConditionals as DTSleep_Conditionals).DLCCoastDaltonRailingBackward01 = Game.GetFormFromFile(0x0300472F, "DLCCoast.esm") as ObjectReference
			(DTSConditionals as DTSleep_Conditionals).DLCCoastDaltonRailingBackward02 = Game.GetFormFromFile(0x03004726, "DLCCoast.esm") as ObjectReference
			(DTSConditionals as DTSleep_Conditionals).DLCCoastDaltonRailingBackward03 = Game.GetFormFromFile(0x0300472C, "DLCCoast.esm") as ObjectReference
			(DTSConditionals as DTSleep_Conditionals).DLCCoastDaltonRailingBackward04 = Game.GetFormFromFile(0x03004730, "DLCCoast.esm") as ObjectReference
			(DTSConditionals as DTSleep_Conditionals).DLCCoastDaltonRailingBackward05 = Game.GetFormFromFile(0x03004731, "DLCCoast.esm") as ObjectReference
		endIf
	endIf
	
	; Nuka-World
	;
	if ((DTSConditionals as DTSleep_Conditionals).IsNukaWorldDLCActive == false)
		Form teddyBearForm = IsPluginActive(0x0102689C, "DLCNukaWorld.esm")
		if (teddyBearForm)
			;Debug.Trace(myScriptName + " adding NukaWorld toys and locations")
			; 0x0102689C = DLC04_SouvenirTeddyBear
			
			(DTSConditionals as DTSleep_Conditionals).IsNukaWorldDLCActive = true
			
			if (!DTSleep_FemBedItemFList.HasForm(teddyBearForm))
				;Debug.Trace(myScriptName + " adding to FemBedList: " + teddyBearForm)
				DTSleep_FemBedItemFList.AddForm(teddyBearForm)
			endIf
			teddyBearForm = Game.GetFormFromFile(0x0102A180, "DLCNukaWorld.esm")
			if (!DTSleep_FemBedItemFList.HasForm(teddyBearForm))
				;Debug.Trace(myScriptName + " adding to FemBedList: " + teddyBearForm)
				DTSleep_FemBedItemFList.AddForm(teddyBearForm)
			endIf
			Form slothToyForm = Game.GetFormFromFile(0x0102A185, "DLCNukaWorld.esm")
			if (!DTSleep_FemBedItemFList.HasForm(slothToyForm))
				;Debug.Trace(myScriptName + " adding to FemBedList: " + slothToyForm)
				DTSleep_FemBedItemFList.AddForm(slothToyForm)
			endIf
			
			Form treatForm = Game.GetFormFromFile(0x0602689A, "DLCNukaWorld.esm") ; cotton candy bites
			if (!DTSleep_CandyTreatsList.HasForm(treatForm))
				DTSleep_CandyTreatsList.AddForm(treatForm)
				DTSleep_CandyTreatsList.AddForm(Game.GetFormFromFile(0x06030EFC, "DLCNukaWorld.esm"))  ; nuka-love
				DTSleep_CandyTreatsList.AddForm(Game.GetFormFromFile(0x06024534, "DLCNukaWorld.esm"))	; nuka-grape
			endIf
			
			Form locForm = Game.GetFormFromFile(0x06056DB2, "DLCNukaWorld.esm") ;Fizztop
			if (!DTSleep_UndressLocationList.HasForm(locForm))
				DTSleep_UndressLocationList.AddForm(locForm)
				; Parlor
				DTSleep_UndressLocationList.AddForm(Game.GetFormFromFile(0x06056DB3, "DLCNukaWorld.esm") as Location)
				; Bradberton
				DTSleep_UndressLocationList.AddForm(Game.GetFormFromFile(0x06055A05, "DLCNukaWorld.esm") as Location)
				; NukaTownUSA
				locForm = Game.GetFormFromFile(0x0601FCEC, "DLCNukaWorld.esm") as Location
				DTSleep_UndressLocationList.AddForm(locForm)
				DTSleep_IntimateTourLocList.AddForm(locForm)
				(DTSConditionals as DTSleep_Conditionals).LocTourNWTownIndex = DTSleep_IntimateTourLocList.GetSize() - 1
				DTSleep_IntimateTourLocList.AddForm(Game.GetFormFromFile(0x0601EB9B, "DLCNukaWorld.esm"))	; Grandchester Mansion
				(DTSConditionals as DTSleep_Conditionals).LocTourNWMansionIndex = DTSleep_IntimateTourLocList.GetSize() - 1
				DTSleep_TownLocationList.AddForm(Game.GetFormFromFile(0x0600BCED, "DLCNukaWorld.esm"))		; Red Rocket
				DTSleep_TownLocationList.AddForm(Game.GetFormFromFile(0x06007EC4, "DLCNukaWorld.esm"))   	; transit center
				DTSleep_TownLocationList.AddForm(Game.GetFormFromFile(0x0600E765, "DLCNukaWorld.esm"))		; Galactic Zone
				DTSleep_TownLocationList.AddForm(Game.GetFormFromFile(0x0601763E, "DLCNukaWorld.esm"))		; Junkyard
				DTSleep_TownLocationList.AddForm(Game.GetFormFromFile(0x06017645, "DLCNukaWorld.esm"))		; Kiddie Kingdom
				DTSleep_TownLocationList.AddForm(Game.GetFormFromFile(0x0601CE0C, "DLCNukaWorld.esm"))		; Hub Camp
				DTSleep_TownLocationList.AddForm(Game.GetFormFromFile(0x0601FB1C, "DLCNukaWorld.esm"))		; Dry Rock
				DTSleep_TownLocationList.AddForm(Game.GetFormFromFile(0x0601FC7F, "DLCNukaWorld.esm"))		; Safari
				DTSleep_TownLocationList.AddForm(Game.GetFormFromFile(0x06017643, "DLCNukaWorld.esm"))		; Bottle Plant
				DTSleep_TownLocationList.AddForm(Game.GetFormFromFile(0x06042B5A, "DLCNukaWorld.esm"))		; Dunmore home
				DTSleep_TownLocationList.AddForm(Game.GetFormFromFile(0x060503B3, "DLCNukaWorld.esm"))		; Bradberton Overpass
				DTSleep_TownLocationList.AddForm(Game.GetFormFromFile(0x0604E130, "DLCNukaWorld.esm"))		; Bradberton town
				DTSleep_TownLocationList.AddForm(Game.GetFormFromFile(0x0600B8E5, "DLCNukaWorld.esm"))		; Nuka-Station
				
				DTSleep_IntimateLocCountThreshold.SetValueInt(DTSleep_IntimateTourLocList.GetSize())
			endIf
			
			Actor gageRef = Game.GetFormFromFile(0x0600A5B1, "DLCNukaWorld.esm") as Actor
			
			if (gageRef != None)
				(DTSConditionals as DTSleep_Conditionals).NukaWorldDLCGageRef = gageRef
				DTSleep_CompanionRomance2List.AddForm(gageRef as Form)
				DTSleep_CompanionIntimateAllList.AddForm(gageRef as Form)
			endIf
			
			DTSleep_ArmorNecklaceSlot50List.AddForm(Game.GetFormFromFile(0x06029AFA, "DLCNukaWorld.esm")) ; shock collar
			DTSleep_ArmorSlot41List.AddForm(Game.GetFormFromFile(0x0602741F, "DLCNukaWorld.esm")) ; pack necklace
			DTSleep_ArmorSlot41List.AddForm(Game.GetFormFromFile(0x0603B8A9, "DLCNukaWorld.esm")) ; pack feather necklace
			DTSleep_ArmorSlot41List.AddForm(Game.GetFormFromFile(0x0604E26F, "DLCNukaWorld.esm")) ; Yao-Guai necklace
			
			Armor bodyExtra = Game.GetFormFromFile(0x06029C06, "DLCNukaWorld.esm") as Armor  ; Gage armor
			if (bodyExtra && !DTSleep_ArmorAllExceptionList.HasForm(bodyExtra))
				DTSleep_ArmorAllExceptionList.AddForm(bodyExtra)
				DTSleep_ArmorAllExceptionList.AddForm(Game.GetFormFromFile(0x06029C08, "DLCNukaWorld.esm"))  ; western
				DTSleep_ArmorAllExceptionList.AddForm(Game.GetFormFromFile(0x06029C09, "DLCNukaWorld.esm"))  ; western
				DTSleep_ArmorAllExceptionList.AddForm(Game.GetFormFromFile(0x06029C0A, "DLCNukaWorld.esm"))  ; western-orange
				DTSleep_ArmorAllExceptionList.AddForm(Game.GetFormFromFile(0x06029C0B, "DLCNukaWorld.esm"))  ; western-cowhide
				DTSleep_ArmorAllExceptionList.AddForm(Game.GetFormFromFile(0x06029C0C, "DLCNukaWorld.esm"))  ; Hubologist
				DTSleep_ArmorAllExceptionList.AddForm(Game.GetFormFromFile(0x0603407C, "DLCNukaWorld.esm"))  ; magicians
				DTSleep_ArmorAllExceptionList.AddForm(Game.GetFormFromFile(0x06042325, "DLCNukaWorld.esm"))  ; western duster
				DTSleep_ArmorAllExceptionList.AddForm(Game.GetFormFromFile(0x06044DA7, "DLCNukaWorld.esm"))  ; jacket jeans
				DTSleep_ArmorAllExceptionList.AddForm(Game.GetFormFromFile(0x06044DA8, "DLCNukaWorld.esm"))  ; jacket jeans cappy
				DTSleep_ArmorAllExceptionList.AddForm(Game.GetFormFromFile(0x060520CF, "DLCNukaWorld.esm"))  ; furry pants, shirt
			endIf
			
			DTSleep_ArmorGlassesList.AddForm(Game.GetFormFromFile(0x06013A47, "DLCNukaWorld.esm"))  ; cappy glasses
			DTSleep_ArmorGlassesList.AddForm(Game.GetFormFromFile(0x0602873D, "DLCNukaWorld.esm"))  ; disciples goggles
			DTSleep_ArmorGlassesList.AddForm(Game.GetFormFromFile(0x0602873E, "DLCNukaWorld.esm"))  ; disciples glasses
			DTSleep_ArmorGlassesList.AddForm(Game.GetFormFromFile(0x060424A1, "DLCNukaWorld.esm"))  ; bottlecap sunglasses
			
			Armor mask = Game.GetFormFromFile(0x06027709, "DLCNukaWorld.esm") as Armor
			if (mask != None && !DTSleep_ArmorMaskList.HasForm(mask as Form))
				DTSleep_ArmorMaskList.AddForm(mask as Form)
				DTSleep_ArmorMaskList.AddForm(Game.GetFormFromFile(0x0602770A, "DLCNukaWorld.esm"))
				DTSleep_ArmorMaskList.AddForm(Game.GetFormFromFile(0x0602770B, "DLCNukaWorld.esm"))
				DTSleep_ArmorMaskList.AddForm(Game.GetFormFromFile(0x06027708, "DLCNukaWorld.esm"))
			endIf
			
			Form gangFactForm = Game.GetFormFromFile(0x0600F438, "DLCNukaWorld.esm")
			if (gangFactForm != None && !DTSleep_SettlerFactionList.HasForm(gangFactForm))
				DTSleep_SettlerFactionList.AddForm(gangFactForm)
				DTSleep_SettlerFactionList.AddForm(Game.GetFormFromFile(0x0600F439, "DLCNukaWorld.esm"))
				DTSleep_SettlerFactionList.AddForm(Game.GetFormFromFile(0x0600F43A, "DLCNukaWorld.esm"))
				DTSleep_SettlerFactionList.AddForm(Game.GetFormFromFile(0x06013A45, "DLCNukaWorld.esm"))
			endIf
			
			DTSleep_IntimateChairThroneList.AddForm(Game.GetFormFromFile(0x0602F326, "DLCNukaWorld.esm"))
			
			;v2
			LoadNukaWorldOuterArmors()
			LoadHelmetsNukaWorld()
		else
			(DTSConditionals as DTSleep_Conditionals).IsNukaWorldDLCActive = false
		endIf
	endIf
	; pink undergarments: 01027422
	; furry undergarment: 01027423
	
	; Workshop DLCs
	;
	if ((DTSConditionals as DTSleep_Conditionals).IsWorkShop02DLCActive == false)
		Keyword rackKY = IsPluginActive(0x050008B2, "DLCWorkshop02.esm")  as Keyword            ; the armorRack KY
		if (rackKY != None)
			(DTSConditionals as DTSleep_Conditionals).IsWorkShop02DLCActive = true
			(DTSConditionals as DTSleep_Conditionals).DLC05ArmorRackKY = rackKY
			
			(DTSConditionals as DTSleep_Conditionals).DLC05PilloryKY = Game.GetFormFromFile(0x05000AC8, "DLCWorkshop02.esm") as Keyword
			Form pilloryForm = Game.GetFormFromFile(0x05000AAD, "DLCWorkshop02.esm")
			DTSleep_PilloryList.AddForm(pilloryForm)
		endIf
	endIf
	
	if ((DTSConditionals as DTSleep_Conditionals).IsWorkShop03DLCActive == false)
		Form bedForm = IsPluginActive(0x05004981, "DLCWorkshop03.esm")
		if (bedForm != None)
			(DTSConditionals as DTSleep_Conditionals).IsWorkShop03DLCActive = true
			if (!DTSleep_BedsBigList.HasForm(bedForm))
				DTSleep_BedsBigList.AddForm(bedForm)
				DTSleep_BedList.AddForm(bedForm)
				DTSleep_BedIntimateList.AddForm(bedForm)
			endIf
			DTSleep_UndressLocationList.AddForm(Game.GetFormFromFile(0x05003DDF, "DLCWorkshop03.esm"))   ; Vault 88
			
			; v1.65 chairs and benches
			DTSleep_IntimateKitchenSeatList.AddForm(Game.GetFormFromFile(0x05005337, "DLCWorkshop03.esm"))
			DTSleep_IntimateKitchenSeatList.AddForm(Game.GetFormFromFile(0x05005340, "DLCWorkshop03.esm"))
			DTSleep_IntimateBenchList.AddForm(Game.GetFormFromFile(0x050049F4, "DLCWorkshop03.esm"))
			DTSleep_IntimateBenchList.AddForm(Game.GetFormFromFile(0x05004984, "DLCWorkshop03.esm"))
			DTSleep_IntimateKitchenSeatList.AddForm(Game.GetFormFromFile(0x05005343, "DLCWorkshop03.esm"))
			DTSleep_IntimateKitchenSeatList.AddForm(Game.GetFormFromFile(0x05005344, "DLCWorkshop03.esm"))
			DTSleep_IntimateKitchenSeatList.AddForm(Game.GetFormFromFile(0x05005345, "DLCWorkshop03.esm"))
			DTSleep_IntimateKitchenSeatList.AddForm(Game.GetFormFromFile(0x05005346, "DLCWorkshop03.esm"))
			DTSleep_IntimateKitchenSeatList.AddForm(Game.GetFormFromFile(0x05005347, "DLCWorkshop03.esm"))
			DTSleep_IntimateKitchenSeatList.AddForm(Game.GetFormFromFile(0x05005348, "DLCWorkshop03.esm"))
			DTSleep_IntimateKitchenSeatList.AddForm(Game.GetFormFromFile(0x0500538B, "DLCWorkshop03.esm"))
			DTSleep_IntimateKitchenSeatList.AddForm(Game.GetFormFromFile(0x0500538C, "DLCWorkshop03.esm"))
			DTSleep_IntimateRoundTableList.AddForm(Game.GetFormFromFile(0x05005368, "DLCWorkshop03.esm"))
			
			DTSleep_IntimateWeightBenchList.AddForm(Game.GetFormFromFile(0x0500119A, "DLCWorkshop03.esm"))
			(DTSConditionals as DTSleep_Conditionals).WeightBenchKY = (Game.GetFormFromFile(0x05001A52, "DLCWorkshop03.esm") as Keyword)
			
			DTSleep_IntimateDinerBoothTableAllList.AddForm(Game.GetFormFromFile(0x050049F3, "DLCWorkshop03.esm"))
			
			; v2.51 - desk-container
			Form deskForm = Game.GetFormFromFile(0x0500539C, "DLCWorkshop03.esm")		; highTech
			DTSleep_IntimateDeskList.AddForm(deskForm)
			DTSleep_IntimateDesk90List.AddForm(deskForm)
			deskForm = Game.GetFormFromFile(0x0500539D, "DLCWorkshop03.esm")		; highTech
			DTSleep_IntimateDeskList.AddForm(deskForm)
			DTSleep_IntimateDesk90List.AddForm(deskForm)
			deskForm = Game.GetFormFromFile(0x05004987, "DLCWorkshop03.esm")		; vault desk
			DTSleep_IntimateDeskList.AddForm(deskForm)
			DTSleep_IntimateDesk90List.AddForm(deskForm)
			
			; v2.70 - ottoman
			DTSleep_IntimateChairOttomanList.AddForm(Game.GetFormFromFile(0x050005341, "DLCWorkshop03.esm"))
			DTSleep_IntimateChairOttomanList.AddForm(Game.GetFormFromFile(0x05000534B, "DLCWorkshop03.esm"))
			
			; v2.77 - vault locker
			Form lockerForm = Game.GetFormFromFile(0x05004988, "DLCWorkshop03.esm")
			DTSleep_IntimateLockerList.AddForm(lockerForm)
			DTSleep_IntimateLockerAdjList.AddForm(lockerForm)
		endIf
	endIf
	
	;  ---------------- mod check -------------
	
	; SMM
	if (Game.IsPluginInstalled("SettlementMenuManager.esp"))
		
		if ((DTSConditionals as DTSleep_Conditionals).IsSMMActive == false)
			
			(DTSConditionals as DTSleep_Conditionals).IsSMMActive = true
			
			; remove before starting SMM
			Debug.Trace(myScriptName + " starting SMM support...")
			if (WorkshopMenu01Furniture.HasForm(DTSleep_WorkshopRecipeKY))
				WorkshopMenu01Furniture.RemoveAddedForm(DTSleep_WorkshopRecipeKY)
				Utility.Wait(0.1)
			endIf
			
			DTSleep_SMMQuestP.Start()
		endIf
	elseIf ((DTSConditionals as DTSleep_Conditionals).IsSMMActive)
		Debug.Trace(myScriptName + " SMM removed! - switch to our menu control")
		(DTSConditionals as DTSleep_Conditionals).IsSMMActive = false
		DTSleep_SMMQuestP.Stop()
	endIf
	
	if (ActiveLevel > 0 && (DTSConditionals as DTSleep_Conditionals).IsSMMActive == false)
	
		WorkshopMenu01Furniture.AddForm(DTSleep_WorkshopRecipeKY)
	endIf
	
	; AFT
	
	if ((DTSConditionals as DTSleep_Conditionals).IsAFTActive == false)
		Spell aftManageSpell = IsPluginActive(0x09002E0C, "AmazingFollowerTweaks.esp") as Spell
		if (aftManageSpell != None)
			(DTSConditionals as DTSleep_Conditionals).IsAFTActive = true
		endIf
	elseIf (!Game.IsPluginInstalled("AmazingFollowerTweaks.esp"))
		(DTSConditionals as DTSleep_Conditionals).IsAFTActive = false
		Debug.Trace(myScriptName + "AFT has been removed")
	endIf
	
	; Unlimited Companion Framework - EFF
	(DTSConditionals as DTSleep_Conditionals).IsEFFActive = Game.IsPluginInstalled("EFF.esp")
	
	; Player Comments Head Tracking
	
	if ((DTSConditionals as DTSleep_Conditionals).IsPlayerCommentsActive == false)
		GlobalVariable pcudVar = IsPluginActive(0x09226B19, "PlayerComments.esp") as GlobalVariable
		if (pcudVar != None)
			(DTSConditionals as DTSleep_Conditionals).IsPlayerCommentsActive = true
			(DTSConditionals as DTSleep_Conditionals).ModPlayerCommentsGlobDisabled = pcudVar
			pcudVar = Game.GetFormFromFile(0x0920D107, "PlayerComments.esp") as GlobalVariable
			(DTSConditionals as DTSleep_Conditionals).ModPlayerCommentsGlobMisc = pcudVar
			Quest pcQ = Game.GetFormFromFile(0x09000F99, "PlayerComments.esp") as Quest
			(DTSConditionals as DTSleep_Conditionals).ModPlayerCommentsQuest = pcQ
			(DTSConditionals as DTSleep_Conditionals).ModPlayerCommentsDisabled = false
		endIf
	elseIf (!Game.IsPluginInstalled("PlayerComments.esp"))
		Debug.Trace(myScriptName + " PlayerComments removed")
		(DTSConditionals as DTSleep_Conditionals).IsPlayerCommentsActive = false
		(DTSConditionals as DTSleep_Conditionals).ModPlayerCommentsGlobDisabled = None
		(DTSConditionals as DTSleep_Conditionals).ModPlayerCommentsGlobMisc = None
		(DTSConditionals as DTSleep_Conditionals).ModPlayerCommentsQuest = None
	endIf
	
	if ((DTSConditionals as DTSleep_Conditionals).IsPlayerCommentsActive == false)
		GlobalVariable pcudVar = IsPluginActive(0x09001737, "PlayerHeadTracking.esp") as GlobalVariable
		if (pcudVar != None)
			(DTSConditionals as DTSleep_Conditionals).IsPlayerCommentsActive = true
			(DTSConditionals as DTSleep_Conditionals).ModPlayerCommentsGlobDisabled = pcudVar
			;Quest pcQ = Game.GetFormFromFile(0x09000F99, "PlayerHeadTracking.esp") as Quest
			(DTSConditionals as DTSleep_Conditionals).ModPlayerCommentsQuest = None
			(DTSConditionals as DTSleep_Conditionals).ModPlayerCommentsDisabled = false
		endIf
	elseIf (!Game.IsPluginInstalled("PlayerHeadTracking.esp") && !Game.IsPluginInstalled("PlayerComments.esp"))
		Debug.Trace(myScriptName + " PlayerHeadTracking removed")
		(DTSConditionals as DTSleep_Conditionals).IsPlayerCommentsActive = false
		(DTSConditionals as DTSleep_Conditionals).ModPlayerCommentsGlobDisabled = None
		(DTSConditionals as DTSleep_Conditionals).ModPlayerCommentsQuest = None
	endIf
	
	; Sleep-or-Save
	
	if (DTSleep_IsSoSActive.GetValue() <= 0.0)
		Perk sosPerk = IsPluginActive(0x09000F99, "SleepOrSave.esp") as Perk
		if (sosPerk != None)
			DTSleep_IsSoSActive.SetValue(3.0)  ; initialize
			(DTSConditionals as DTSleep_Conditionals).ModSoSPerk = sosPerk
		endIf
	elseIf (!Game.IsPluginInstalled("SleepOrSave.esp"))
		Debug.Trace(myScriptName + "SleepOrSave has been removed")
		DTSleep_IsSoSActive.SetValue(-1.0)
		(DTSConditionals as DTSleep_Conditionals).ModSoSPerk = None
	endIf
	
	; See-You-Sleep
	; 0x0100E433 is AB_SleepToggle
	string sleepName = "See You Sleep CW editon - Beta.esp"
	
	if (DTSleep_IsSYSCWActive.GetValue() <= 0.0)
		Form syscwForm = IsPluginActive(0x0100E433, sleepName)
		if (syscwForm != None)
			DTSleep_IsSYSCWActive.SetValue(1.0)
			DTSleep_SettingPrefSYSC.SetValue(-2.0)
		endIf
	elseIf (!Game.IsPluginInstalled(sleepName))
		Debug.Trace(myScriptName + "See-You-Sleep has been removed")
		DTSleep_IsSYSCWActive.SetValue(-2.0)
	else
		Debug.Trace(myScriptName + "See-You-Sleep previously found")
	endIf
	
	; AWKCR
	;
	if ((DTSConditionals as DTSleep_Conditionals).IsAWKCRActive == false)
		Keyword satchelKY = IsPluginActive(0x06000861, "ArmorKeywords.esm") as Keyword
		if (satchelKY)
			; the ClothingSlotSatchel_Slot55 Keyword
			(DTSConditionals as DTSleep_Conditionals).IsAWKCRActive = true
			(DTSConditionals as DTSleep_Conditionals).AWKCRSatchelKW = satchelKY
			
			Keyword awkKey = Game.GetFormFromFile(0x06000812, "ArmorKeywords.esm") as Keyword
			(DTSConditionals as DTSleep_Conditionals).AWKCRPiercingKW = awkKey
			awkKey = Game.GetFormFromFile(0x06000839, "ArmorKeywords.esm") as Keyword
			(DTSConditionals as DTSleep_Conditionals).AWKCRCloakKW = awkKey
			awkKey = Game.GetFormFromFile(0x06000832, "ArmorKeywords.esm") as Keyword
			(DTSConditionals as DTSleep_Conditionals).AWKCRJacketKW = awkKey
			awkKey = Game.GetFormFromFile(0x06000824, "ArmorKeywords.esm") as Keyword
			(DTSConditionals as DTSleep_Conditionals).AWKCRPackKW = awkKey
			awkKey = Game.GetFormFromFile(0x06000838, "ArmorKeywords.esm") as Keyword
			(DTSConditionals as DTSleep_Conditionals).AWKCRBandolKW = awkKey
		endIf
	elseIf (!Game.IsPluginInstalled("ArmorKeywords.esm"))
		Debug.Trace(myScriptName + " AWKCR has been removed ")
		(DTSConditionals as DTSleep_Conditionals).IsAWKCRActive = false
		(DTSConditionals as DTSleep_Conditionals).AWKCRPiercingKW = None
		(DTSConditionals as DTSleep_Conditionals).AWKCRCloakKW = None
		(DTSConditionals as DTSleep_Conditionals).AWKCRJacketKW = None
		(DTSConditionals as DTSleep_Conditionals).AWKCRPackKW = None
		(DTSConditionals as DTSleep_Conditionals).AWKCRBandolKW = None
	endIf
	
	; UPF
	;
	if (Game.IsPluginInstalled("UniquePlayerPlugin.esp"))
		(DTSConditionals as DTSleep_Conditionals).IsUPFPlayerActive = true
	else
		(DTSConditionals as DTSleep_Conditionals).IsUPFPlayerActive = false
	endIf
	
	; Conquest by Chesko
	;
	if ((DTSConditionals as DTSleep_Conditionals).IsConquestActive == false)
		Keyword kw = IsPluginActive(0x09005C1D, "Conquest.esp") as Keyword
		if (kw)
			(DTSConditionals as DTSleep_Conditionals).IsConquestActive = true
			(DTSConditionals as DTSleep_Conditionals).ConquestWorkshopKW = kw
			
			Form tentForm = Game.GetFormFromFile(0x0900E0A3, "Conquest.esp")
			if (tentForm && !DTSleep_BadSheltersList.HasForm(tentForm))
				DTSleep_BadSheltersList.AddForm(tentForm)
			endIf
		endIf
	elseIf (!Game.IsPluginInstalled("Conquest.esp"))
		Debug.Trace(myScriptName + " Conquest has been removed ")
		(DTSConditionals as DTSleep_Conditionals).IsConquestActive = false
		(DTSConditionals as DTSleep_Conditionals).ConquestWorkshopKW = None
	endIf
	
	; APC Transport - not enough room inside APC for animation on sleeping bag
	if (!(DTSConditionals as DTSleep_Conditionals).IsAPCTransportFound && Game.IsPluginInstalled("LR_APCTransport.esp"))
		Form sleepBagForm = Game.GetFormFromFile(0x090036CA, "LR_APCTransport.esp")
		if (sleepBagForm != None && !DTSleep_BadSheltersList.HasForm(sleepBagForm))
			DTSleep_BadSheltersList.AddForm(sleepBagForm)
			(DTSConditionals as DTSleep_Conditionals).IsAPCTransportFound = true
		endIf
	endIf
	
	; Campsite by Fadingsignal
	;
	if ((DTSConditionals as DTSleep_Conditionals).IsCampsiteActive == false)
		Furniture bag = IsPluginActive(0x09000800, "Campsite.esp") as Furniture
		if (bag)
			(DTSConditionals as DTSleep_Conditionals).IsCampsiteActive = true
			if (!DTSleep_BedList.HasForm(bag))
				; sleeping bags
				AddToBedsList(bag)
				AddToBedsList(Game.GetFormFromFile(0x09000835, "Campsite.esp"))
				AddToBedsList(Game.GetFormFromFile(0x0900083D, "Campsite.esp"))
				AddToBedsList(Game.GetFormFromFile(0x0900083E, "Campsite.esp"))
				AddToBedsList(Game.GetFormFromFile(0x0900083F, "Campsite.esp"))
				AddToBedsList(Game.GetFormFromFile(0x09000840, "Campsite.esp"))
				AddToBedsList(Game.GetFormFromFile(0x09000841, "Campsite.esp"))
				AddToBedsList(Game.GetFormFromFile(0x09000842, "Campsite.esp"))
				AddToBedsList(Game.GetFormFromFile(0x09000843, "Campsite.esp"))
				AddToBedsList(Game.GetFormFromFile(0x09000846, "Campsite.esp"))
				AddToBedsList(Game.GetFormFromFile(0x09000906, "Campsite.esp"))
				AddToBedsList(Game.GetFormFromFile(0x09000907, "Campsite.esp"))
				AddToBedsList(Game.GetFormFromFile(0x09000908, "Campsite.esp"))
				AddToBedsList(Game.GetFormFromFile(0x09000909, "Campsite.esp"))
				AddToBedsList(Game.GetFormFromFile(0x0900090A, "Campsite.esp"))
				AddToBedsList(Game.GetFormFromFile(0x0900090B, "Campsite.esp"))
				AddToBedsList(Game.GetFormFromFile(0x0900090C, "Campsite.esp"))
				AddToBedsList(Game.GetFormFromFile(0x0900090D, "Campsite.esp"))
				AddToBedsList(Game.GetFormFromFile(0x0900090E, "Campsite.esp"))
				
				; tents restrict access
				DTSleep_BedNoIntimateList.AddForm(Game.GetFormFromFile(0x0900080D, "Campsite.esp"))  	; pole tent
				DTSleep_BadSheltersList.AddForm(Game.GetFormFromFile(0x0900080C, "Campsite.esp"))  		; makeshift / tarp
				DTSleep_BedNoIntimateList.AddForm(Game.GetFormFromFile(0x0900080E, "Campsite.esp"))  	; pole tent
				DTSleep_BedNoIntimateList.AddForm(Game.GetFormFromFile(0x09000865, "Campsite.esp"))
				DTSleep_BedNoIntimateList.AddForm(Game.GetFormFromFile(0x09000866, "Campsite.esp"))
				DTSleep_BedNoIntimateList.AddForm(Game.GetFormFromFile(0x09000867, "Campsite.esp"))
				DTSleep_BedNoIntimateList.AddForm(Game.GetFormFromFile(0x09000868, "Campsite.esp"))
				DTSleep_BedNoIntimateList.AddForm(Game.GetFormFromFile(0x09000869, "Campsite.esp"))
				DTSleep_BedNoIntimateList.AddForm(Game.GetFormFromFile(0x0900086A, "Campsite.esp"))
				DTSleep_BedNoIntimateList.AddForm(Game.GetFormFromFile(0x0900086B, "Campsite.esp"))
				DTSleep_BedNoIntimateList.AddForm(Game.GetFormFromFile(0x0900086C, "Campsite.esp"))
				DTSleep_BedNoIntimateList.AddForm(Game.GetFormFromFile(0x0900086D, "Campsite.esp"))
				DTSleep_BedNoIntimateList.AddForm(Game.GetFormFromFile(0x0900086E, "Campsite.esp"))
				DTSleep_BedNoIntimateList.AddForm(Game.GetFormFromFile(0x0900086F, "Campsite.esp"))
				DTSleep_BedNoIntimateList.AddForm(Game.GetFormFromFile(0x09000870, "Campsite.esp"))
				DTSleep_BedNoIntimateList.AddForm(Game.GetFormFromFile(0x0900090F, "Campsite.esp"))		; WS tent
				DTSleep_BedNoIntimateList.AddForm(Game.GetFormFromFile(0x09000910, "Campsite.esp"))
				DTSleep_BedNoIntimateList.AddForm(Game.GetFormFromFile(0x09000911, "Campsite.esp"))
				DTSleep_BedNoIntimateList.AddForm(Game.GetFormFromFile(0x09000912, "Campsite.esp"))
				DTSleep_BedNoIntimateList.AddForm(Game.GetFormFromFile(0x09000913, "Campsite.esp"))
				DTSleep_BedNoIntimateList.AddForm(Game.GetFormFromFile(0x09000914, "Campsite.esp"))
				DTSleep_BedNoIntimateList.AddForm(Game.GetFormFromFile(0x09000915, "Campsite.esp"))
				DTSleep_BedNoIntimateList.AddForm(Game.GetFormFromFile(0x09000916, "Campsite.esp"))
				DTSleep_BedNoIntimateList.AddForm(Game.GetFormFromFile(0x09000917, "Campsite.esp"))
				DTSleep_BedNoIntimateList.AddForm(Game.GetFormFromFile(0x09000918, "Campsite.esp"))
				DTSleep_BedNoIntimateList.AddForm(Game.GetFormFromFile(0x09000919, "Campsite.esp"))
				DTSleep_BedNoIntimateList.AddForm(Game.GetFormFromFile(0x0900091A, "Campsite.esp"))
				DTSleep_BedNoIntimateList.AddForm(Game.GetFormFromFile(0x0900091B, "Campsite.esp"))
				DTSleep_BedNoIntimateList.AddForm(Game.GetFormFromFile(0x0900091C, "Campsite.esp"))
				DTSleep_BadSheltersList.AddForm(Game.GetFormFromFile(0x0900091E, "Campsite.esp"))  		; WSmakeshift / tarp
			endIf
		endIf
	elseIf (!Game.IsPluginInstalled("Campsite.esp"))
		Debug.Trace(myScriptName + " Campsite has been removed")
		(DTSConditionals as DTSleep_Conditionals).IsCampsiteActive = false
	endIf
	
	; Basement Living 
	if ((DTSConditionals as DTSleep_Conditionals).IsBasementLivingActive == false)
		Form locForm = IsPluginActive(0x090200DC, "BasementLiving.esp")
		if (locForm)
			(DTSConditionals as DTSleep_Conditionals).IsBasementLivingActive = true
			if (!DTSleep_PrivateLocationList.HasForm(locForm))
				DTSleep_PrivateLocationList.AddForm(locForm)
				DTSleep_PrivateLocationList.AddForm(Game.GetFormFromFile(0x0902034B, "BasementLiving.esp"))
				DTSleep_PrivateLocationList.AddForm(Game.GetFormFromFile(0x0902035C, "BasementLiving.esp"))
				DTSleep_PrivateLocationList.AddForm(Game.GetFormFromFile(0x090206BA, "BasementLiving.esp"))
				DTSleep_PrivateLocationList.AddForm(Game.GetFormFromFile(0x090206BB, "BasementLiving.esp"))
				DTSleep_PrivateLocationList.AddForm(Game.GetFormFromFile(0x090206BC, "BasementLiving.esp"))
				DTSleep_PrivateLocationList.AddForm(Game.GetFormFromFile(0x090207FD, "BasementLiving.esp"))
				DTSleep_PrivateLocationList.AddForm(Game.GetFormFromFile(0x0902087B, "BasementLiving.esp"))
				DTSleep_PrivateLocationList.AddForm(Game.GetFormFromFile(0x09020A82, "BasementLiving.esp"))
				DTSleep_PrivateLocationList.AddForm(Game.GetFormFromFile(0x09020EC3, "BasementLiving.esp"))
			endIf
		endIf
	elseIf (!Game.IsPluginInstalled("BasementLiving.esp"))
		Debug.Trace(myScriptName + " BasementLiving has been removed")
		(DTSConditionals as DTSleep_Conditionals).IsBasementLivingActive = false
	endIf
	
	; Sleep Together
	if (DTSleep_IsSleepTogetherActive.GetValue() <= 0.0)
		Furniture sleepBag = IsPluginActive(0x0900B008, "Hoamaii_SleepTogetherAnywhere.esp") as Furniture
		if (sleepBag != None)
			DTSleep_IsSleepTogetherActive.SetValue(1.0)
			if (!DTSleep_BedIntimateList.HasForm(sleepBag))
				DTSleep_BedIntimateList.AddForm(sleepBag)		; mod-bed/camping -- okay to undress
				;DTSleep_BedNoIntimateList.AddForm(sleepBag)		; no need to add to BedList for companion
			endIf
			AddSleepTogetherSeats()
		endIf
	elseIf (!Game.IsPluginInstalled("Hoamaii_SleepTogetherAnywhere.esp"))
		Debug.Trace(myScriptName + " SleepTogether has been removed")
		DTSleep_IsSleepTogetherActive.SetValue(-1.0)
	elseIf (DTSleep_IsSleepTogetherActive.GetValue() < 2.0)
	
		AddSleepTogetherSeats()
	endIf
	
	if ((DTSConditionals as DTSleep_Conditionals).ITPCCactiveLevel > 0)
		if (!Game.IsPluginInstalled("ITPCC.esp"))
			(DTSConditionals as DTSleep_Conditionals).ITPCCactiveLevel = -2
		endIf
	elseIf (Game.IsPluginInstalled("ITPCC.esp"))
		(DTSConditionals as DTSleep_Conditionals).ITPCCactiveLevel = 1
	endIf
	
	; Smoke-able Cigars
	if ((DTSConditionals as DTSleep_Conditionals).IsSmokableCigarsActive)
		if (!Game.IsPluginInstalled("Smoke-able Cigars.esp"))
			Debug.Trace(myScriptName + " Smoke-able Cigars has been removed")
			(DTSConditionals as DTSleep_Conditionals).IsSmokableCigarsActive = false
		endIf
	elseIf (IsPluginActive(0x03000FA9, "Smoke-able Cigars.esp"))
		; 0x03000FA9 is spell, AA_abAddictionNicotine
		(DTSConditionals as DTSleep_Conditionals).IsSmokableCigarsActive = true
		Spell jointSpell = (Game.GetFormFromFile(0x03002E37, "Smoke-able Cigars.esp") as Spell)
		if (jointSpell && !DTSleep_IntimacyChanceMEList.HasForm(jointSpell))
			DTSleep_IntimacyChanceMEList.AddForm(jointSpell)
		endIf
	else
		(DTSConditionals as DTSleep_Conditionals).IsSmokableCigarsActive = false 
	endIf
	
	; Pip-Pad and PiP-Boy2000
	string pippadName = "PIP-Pad.esp"
	if (!Game.IsPluginInstalled(pippadName))
		pippadName = "PiP-Boy2000.esp"
	endIf
	Armor pippad = IsPluginActive(0x12009883, pippadName) as Armor   ; slot51
	if (pippad != None)
		
		int pipPadVal = (DTSConditionals as DTSleep_Conditionals).PipPadSlotIndex
		
		if (pipPadVal < 20 || pipPadVal > 31)
			(DTSConditionals as DTSleep_Conditionals).PipPadSlotIndex = 100   ; initialize
		endIf
		
		if (!DTSleep_ArmorPipPadList.HasForm(pippad))
			DTSleep_ArmorPipPadList.AddForm(pippad)
			
			pippad = Game.GetFormFromFile(0x12005BA6, pippadName) as Armor   ; 54
			DTSleep_ArmorPipPadList.AddForm(pippad)
			pippad = Game.GetFormFromFile(0x12005BA7, pippadName) as Armor   ; 55
			DTSleep_ArmorPipPadList.AddForm(pippad)
			pippad = Game.GetFormFromFile(0x12005BA8, pippadName) as Armor   ; 56
			DTSleep_ArmorPipPadList.AddForm(pippad)
			pippad = Game.GetFormFromFile(0x12005BA9, pippadName) as Armor   ; 57
			DTSleep_ArmorPipPadList.AddForm(pippad)
			pippad = Game.GetFormFromFile(0x12005BAA, pippadName) as Armor   ; 58
			DTSleep_ArmorPipPadList.AddForm(pippad)
			pippad = Game.GetFormFromFile(0x12005BAB, pippadName) as Armor   ; 61 - default
			DTSleep_ArmorPipPadList.AddForm(pippad)
		endIf
		; v2.27 - check for fix
		pippad = Game.GetFormFromFile(0x12005B9F, pippadName) as Armor
		if (pippad != None)
			float oldVers = DTSleep_LastVersion.GetValue()
			if (oldVers > 1.1 && oldVers < 2.27)
				UpdateRemListsPipPadForm(pippad as Form)
			endIf
			
			; v2.27 add fake pads which equip on activation
			
			if (!DTSleep_ArmorPipPadList.HasForm(pippad))
				DTSleep_ArmorPipPadList.AddForm(pippad As Form)					; fakeFX
				Form itemForm = Game.GetFormFromFile(0x12005B9E, pippadName)
				DTSleep_ArmorPipPadList.AddForm(itemForm)						; fake58
				if (oldVers > 1.1 && oldVers < 2.27)
					UpdateRemListsPipPadForm(itemForm)
				endIf
				itemForm = Game.GetFormFromFile(0x12005B9D, pippadName)
				DTSleep_ArmorPipPadList.AddForm(itemForm)						; fake57
				if (oldVers > 1.1 && oldVers < 2.27)
					UpdateRemListsPipPadForm(itemForm)
				endIf
				itemForm = Game.GetFormFromFile(0x12005B9C, pippadName)
				DTSleep_ArmorPipPadList.AddForm(itemForm)						; fake56
				if (oldVers > 1.1 && oldVers < 2.27)
					UpdateRemListsPipPadForm(itemForm)
				endIf
				itemForm = Game.GetFormFromFile(0x12005B9B, pippadName)
				DTSleep_ArmorPipPadList.AddForm(itemForm)						; fake55
				if (oldVers > 1.1 && oldVers < 2.27)
					UpdateRemListsPipPadForm(itemForm)
				endIf
				itemForm = Game.GetFormFromFile(0x12003D35, pippadName)			
				DTSleep_ArmorPipPadList.AddForm(itemForm)						; fake54
				if (oldVers > 1.1 && oldVers < 2.27)
					UpdateRemListsPipPadForm(itemForm)
				endIf
			endIf
		endIf
	else
		(DTSConditionals as DTSleep_Conditionals).PipPadSlotIndex = -1
		(DTSConditionals as DTSleep_Conditionals).PipPadListIndex = -1
	endIf
	
	; Locksmith mod
	if ((DTSConditionals as DTSleep_Conditionals).IsLocksmithActive == false)
		FormList noLockList = IsPluginActive(0x09001EF5, "Locksmith.esp") as FormList
		if (noLockList != None)
			(DTSConditionals as DTSleep_Conditionals).IsLocksmithActive = true
			noLockList.AddForm(DTSleep_Outfit_FedDresserShort01 as Form)
			noLockList.AddForm(DTSleep_Outfit_PH_Dresser01 as Form)
			noLockList.AddForm(DTSleep_VaultLocker as Form)
		endIf
	elseIf (!Game.IsPluginInstalled("Locksmith.esp"))
		(DTSConditionals as DTSleep_Conditionals).IsLocksmithActive = false
	endIf
	
	; CWSS
	if ((DTSConditionals as DTSleep_Conditionals).IsCWSSActive == false)
		Form showerForm = IsPluginActive(0x09002675, "CWSS Redux.esp")
		if (showerForm != None)
			(DTSConditionals as DTSleep_Conditionals).IsCWSSActive = true
			DTSleep_IntimateShowerList.AddForm(showerForm)
			DTSleep_IntimatePropList.AddForm(showerForm)
			showerForm = Game.GetFormFromFile(0x09002676, "CWSS Redux.esp")
			DTSleep_IntimateShowerList.AddForm(showerForm)
			DTSleep_IntimatePropList.AddForm(showerForm)
		endIf
	endIf
	
	; wastlander barb - nws
	if ((DTSConditionals as DTSleep_Conditionals).IsNWSBarbActive == false)
		Form barbRefForm = IsPluginActive(0x03010374, "NWS_Barbara.esp")	; npc
		
		if (barbRefForm != None)
			(DTSConditionals as DTSleep_Conditionals).IsNWSBarbActive = true
			
			if (!DTSleep_ModCompanionActorList.HasForm(barbRefForm))
				DTSleep_ModCompanionActorList.AddForm(barbRefForm)
				(DTSConditionals as DTSleep_Conditionals).ModCompanionActorNWSBarbIndex = DTSleep_ModCompanionActorList.GetSize() - 1
			endIf
			
			DTSleep_CompanionIntimateAllList.AddForm(barbRefForm)
			
			Perk barbRewardPerk = Game.GetFormFromFile(0x0302716A, "NWS_Barbara.esp") as Perk
			(DTSConditionals as DTSleep_Conditionals).ModCompNWSBarbRewardPerk = barbRewardPerk
			
		endIf
		
	elseIf (!Game.IsPluginInstalled("NWS_Barbara.esp"))
	
		(DTSConditionals as DTSleep_Conditionals).IsNWSBarbActive = false
		Debug.Trace(myScriptName + " nwsBarb has been removed")
		
		UpdateCompanionSupportRemoval()
		
		(DTSConditionals as DTSleep_Conditionals).ModCompanionActorNWSBarbIndex = -2
	endIf
	
	; Heather Casdin
	string heatherPluginName = "llamaCompanionHeatherv2.esp"				; start with V2 - v2.78
	float heatherVers = 2.0
	
	; LlamaRC recommends starting a new game for V2 so no upgrade path here
	;  though player could remove original plugin, start game and exit, then activate v2 plugin
	
	if ((DTSConditionals as DTSleep_Conditionals).IsHeatherCompanionActive == false)
		Form heatherForm = IsPluginActive(0x0300AB33, heatherPluginName)
		
		if (heatherForm == None)
			; check for original Heather
			heatherVers = 1.0
			heatherPluginName =  "llamaCompanionHeather.esp"
		endIf
		
		; 0x0300AB33 is NPC preset
		if (heatherForm != None)
		
			(DTSConditionals as DTSleep_Conditionals).IsHeatherCompanionActive = true
			(DTSConditionals as DTSleep_Conditionals).HeatherCampanionVers = heatherVers
			
			Armor heatherBag = Game.GetFormFromFile(0x02245C47, heatherPluginName) as Armor
			if (heatherBag != None)
				if (!DTSleep_ArmorBackPacksList.HasForm(heatherBag))
					Debug.Trace(myScriptName + " adding heather bag to backpacks")
					DTSleep_ArmorBackPacksList.AddForm(heatherBag)
				endIf
			endIf
			Location bunker = Game.GetFormFromFile(0x0202D693, heatherPluginName) as Location
			if (bunker && !DTSleep_UndressLocationList.HasForm(bunker))
				Debug.Trace(myScriptName + " adding heather bunker to locations list")
				DTSleep_UndressLocationList.AddForm(bunker)
				DTSleep_PrivateLocationList.AddForm(bunker)
				; the bed in v2 has a new FormID
				Form bed = None
				if (heatherVers < 1.5)
					Game.GetFormFromFile(0x0211E893, heatherPluginName)
				else
					Game.GetFormFromFile(0x04CA8A1E, heatherPluginName)
				endIf
				if (bed != None)
					DTSleep_BedList.AddForm(bed)
					DTSleep_BedsBigList.AddForm(bed)
					DTSleep_BedsBigDoubleList.AddForm(bed)
				endIf
			endIf
			DTSleep_ArmorHatHelmList.AddForm(Game.GetFormFromFile(0x031CB6B3, heatherPluginName))
			DTSleep_ArmorHatHelmList.AddForm(Game.GetFormFromFile(0x0325F709, heatherPluginName))
			
			Armor bodyNakedArmor = Game.GetFormFromFile(0x0200BA6D, heatherPluginName) as Armor
			if (bodyNakedArmor && !DTSleep_ModCompanionBodiesLst.HasForm(bodyNakedArmor))
				DTSleep_ModCompanionBodiesLst.AddForm(bodyNakedArmor)
				
				(DTSConditionals as DTSleep_Conditionals).ModCompanionBodyHeatherIndex = DTSleep_ModCompanionBodiesLst.GetSize() - 1
			endIf
			
			Actor heatherActor = Game.GetFormFromFile(0x0300D157, heatherPluginName) as Actor
			
			if (heatherActor && !DTSleep_ModCompanionActorList.HasForm(heatherActor))
				DTSleep_ModCompanionActorList.AddForm(heatherActor)
				
				(DTSConditionals as DTSleep_Conditionals).ModCompanionActorHeatherIndex = DTSleep_ModCompanionActorList.GetSize() - 1
				
				DTSleep_CompanionIntimateAllList.AddForm(heatherActor as Form)
			endIf
		endIf
	elseIf (!Game.IsPluginInstalled("llamaCompanionHeather.esp"))
		if (!Game.IsPluginInstalled("llamaCompanionHeatherv2.esp"))
			Debug.Trace(myScriptName + " llamaCompanionHeather has been removed")
			
			(DTSConditionals as DTSleep_Conditionals).IsHeatherCompanionActive = false
			
			UpdateCompanionSupportRemoval()
			
			(DTSConditionals as DTSleep_Conditionals).ModCompanionActorHeatherIndex = -2
			(DTSConditionals as DTSleep_Conditionals).ModCompanionBodyHeatherIndex = -2
		endIf
	endIf
	
	; Nora Spouse companion
	if (Game.IsPluginInstalled("NoraSpouse.esm"))
		if ((DTSConditionals as DTSleep_Conditionals).NoraSpouse2Ref == None) 
			(DTSConditionals as DTSleep_Conditionals).NoraSpouse2Ref = Game.GetFormFromFile(0x21000F9A, "NoraSpouse.esm") as Actor
			DTSleep_CompanionRomance2List.AddForm((DTSConditionals as DTSleep_Conditionals).NoraSpouse2Ref as Form)
			DTSleep_CompanionIntimateAllList.AddForm((DTSConditionals as DTSleep_Conditionals).NoraSpouse2Ref as Form)
		endIf
	else
		(DTSConditionals as DTSleep_Conditionals).NoraSpouse2Ref = None
	endIf
	if (Game.IsPluginInstalled("NoraSpouse.esp"))
		if ((DTSConditionals as DTSleep_Conditionals).NoraSpouseRef == None) 
			(DTSConditionals as DTSleep_Conditionals).NoraSpouseRef = Game.GetFormFromFile(0x21001735, "NoraSpouse.esp") as Actor
			DTSleep_CompanionRomance2List.AddForm((DTSConditionals as DTSleep_Conditionals).NoraSpouseRef as Form)
			DTSleep_CompanionIntimateAllList.AddForm((DTSConditionals as DTSleep_Conditionals).NoraSpouseRef as Form)
		endIf
	else
		(DTSConditionals as DTSleep_Conditionals).NoraSpouseRef = None
	endIf
	
	; Dual Survivors
	if (Game.IsPluginInstalled("DualSurvivors.esp"))
		if ((DTSConditionals as DTSleep_Conditionals).DualSurvivorsNateRef == None)
			(DTSConditionals as DTSleep_Conditionals).DualSurvivorsNateRef = Game.GetFormFromFile(0x2100361B, "DualSurvivors.esp") as Actor
			DTSleep_CompanionRomance2List.AddForm((DTSConditionals as DTSleep_Conditionals).DualSurvivorsNateRef as Form)
			DTSleep_CompanionIntimateAllList.AddForm((DTSConditionals as DTSleep_Conditionals).DualSurvivorsNateRef as Form)
		endIf
	else
		(DTSConditionals as DTSleep_Conditionals).DualSurvivorsNateRef = None
	endIf
	
	; companion Insane Ivy
	if (DTSleep_AdultContentOn.GetValue() >= 1.0 && (DTSConditionals as DTSleep_Conditionals).ImaPCMod)
		if (Game.IsPluginInstalled("CompanionIvy.esp"))
			if ((DTSConditionals as DTSleep_Conditionals).InsaneIvyRef == None)
				(DTSConditionals as DTSleep_Conditionals).InsaneIvyRef = Game.GetFormFromFile(0x2108598C, "CompanionIvy.esp") as Actor
			endIf
		else
			(DTSConditionals as DTSleep_Conditionals).InsaneIvyRef = None
		endIf
	endIf
	
	; "Construct a Custom Companion" -v2.41
	if ((DTSConditionals as DTSleep_Conditionals).ModPersonalGuardCtlKY == None)
		if (Game.IsPluginInstalled("PersonalGuard.esp"))
			(DTSConditionals as DTSleep_Conditionals).ModPersonalGuardCtlKY = Game.GetFormFromFile(0x09000801, "PersonalGuard.esp") as Keyword
		endIf
	elseIf (Game.IsPluginInstalled("PersonalGuard.esp") == false)
		(DTSConditionals as DTSleep_Conditionals).ModPersonalGuardCtlKY = None
	endIf
	
	; Let's dance
	if ((DTSConditionals as DTSleep_Conditionals).IsLetsDanceActive == false)
		Idle danceIdle = IsPluginActive(0x21000F9C, "AA Lets Dance.esp") as Idle   ; booty shake
		if (danceIdle)
			(DTSConditionals as DTSleep_Conditionals).IsLetsDanceActive = true
			DTSleep_Dance2List.AddForm(danceIdle)
		endIf
	elseIf (!Game.IsPluginInstalled("AA Lets Dance.esp"))
		Debug.Trace(myScriptName + " AA Lets Dance has been removed")
		(DTSConditionals as DTSleep_Conditionals).IsLetsDanceActive = false
	endIf
	
	; Fusion City
	if ((DTSConditionals as DTSleep_Conditionals).IsFusionCityActive == false)
		Idle danceIdle = IsPluginActive(0x21FC2B4E, "AA FusionCityRising.esp") as Idle   ; booty shake
		if (danceIdle != None)
			(DTSConditionals as DTSleep_Conditionals).IsFusionCityActive = true
			
			if (!DTSleep_Dance2List.HasForm(danceIdle))
				DTSleep_Dance2List.AddForm(danceIdle)
				
				DTSleep_TownLocationList.AddForm(Game.GetFormFromFile(0x21590002, "AA FusionCityRising.esp"))    ; vault 59
				DTSleep_TownLocationList.AddForm(Game.GetFormFromFile(0x21FA050B, "AA FusionCityRising.esp"))    ; residential
				DTSleep_TownLocationList.AddForm(Game.GetFormFromFile(0x21FC3DA6, "AA FusionCityRising.esp"))    ; City
				DTSleep_TownLocationList.AddForm(Game.GetFormFromFile(0x21FC7B8E, "AA FusionCityRising.esp"))    ; Club Fusion
				DTSleep_TownLocationList.AddForm(Game.GetFormFromFile(0x21FC1B37, "AA FusionCityRising.esp"))    ; FCU
			endIf
		endIf
	elseIf (!Game.IsPluginInstalled("AA FusionCityRising.esp"))
		Debug.Trace(myScriptName + " AA FusionCityRising has been removed")
		(DTSConditionals as DTSleep_Conditionals).IsFusionCityActive = false
	endIf
	
	; Depravity
	if ((DTSConditionals as DTSleep_Conditionals).DepravityHotelRexLoc == None)
	
		Location dRexLoc = IsPluginActive(0x090835D0, "Depravity.esp") as Location
		if (dRexLoc != None)
			(DTSConditionals as DTSleep_Conditionals).DepravityHotelRexLoc = dRexLoc
			DTSleep_UndressLocationList.AddForm(dRexLoc)
		endIf
	elseIf (!Game.IsPluginInstalled("Depravity.esp"))
		Debug.Trace(myScriptName + " Depravity has been removed")
		(DTSConditionals as DTSleep_Conditionals).DepravityHotelRexLoc = None
	endIf
	
	; Vulpine - Lupine - Amelia   -- updated v2.75.1, v2.76
	; these may be installed together for companions with only 1 player plug-in
	; for simplicity we only allow one master at a time--other combinations handled as unknown race for hug-and-kiss only
	string tailRaceMaster = "VulpineRace.esm"
	int tailRaceFormID = 0x09000F99
	if (!Game.IsPluginInstalled(tailRaceMaster))
		tailRaceMaster = "LupineRace.esm"
	endIf
	if (!Game.IsPluginInstalled(tailRaceMaster))
		tailRaceMaster = "AmeliaRace.esp"
		tailRaceFormID = 0x09000804
	endIf
	if ((DTSConditionals as DTSleep_Conditionals).IsVulpineRace == None)
		Race modRace = IsPluginActive(tailRaceFormID, tailRaceMaster) as Race
		if (modRace != None)
			(DTSConditionals as DTSleep_Conditionals).IsVulpineRace = modRace
			; consider any player-plugin
			if (Game.IsPluginInstalled("VulpinePlayer.esp") || Game.IsPluginInstalled("LupinePlayer.esp") || Game.IsPluginInstalled("AmeliaPlayer.esp"))
				(DTSConditionals as DTSleep_Conditionals).IsVulpineRacePlayerActive = true
			else
				(DTSConditionals as DTSleep_Conditionals).IsVulpineRacePlayerActive = false
			endIf
		endIf
	elseIf (!Game.IsPluginInstalled(tailRaceMaster))
		; has been removed
		(DTSConditionals as DTSleep_Conditionals).IsVulpineRace = None
		(DTSConditionals as DTSleep_Conditionals).IsVulpineRacePlayerActive = false
	elseIf (Game.IsPluginInstalled("VulpinePlayer.esp") || Game.IsPluginInstalled("LupinePlayer.esp") || Game.IsPluginInstalled("AmeliaPlayer.esp"))
		(DTSConditionals as DTSleep_Conditionals).IsVulpineRacePlayerActive = true
	else
		(DTSConditionals as DTSleep_Conditionals).IsVulpineRacePlayerActive = false
	endIf
	
	
	; v2.60 - AnimeRace_Nanako
	if ((DTSConditionals as DTSleep_Conditionals).NanaRace == None)
		Race modRace = IsPluginActive(0x09000F99, "AnimeRace_Nanako.esp") as Race
		if (modRace != None)
			(DTSConditionals as DTSleep_Conditionals).NanaRace = modRace
			(DTSConditionals as DTSleep_Conditionals).NanaRace2 = Game.GetFormFromFile(0x090020ED, "AnimeRace_Nanako.esp") as Race
			; reset player race -- normally overrides player, but possible changed for NPCs-only or added late game
			(DTSConditionals as DTSleep_Conditionals).PlayerRace = None
			Form bodyNakedArmor = Game.GetFormFromFile(0x09001F00, "AnimeRace_Nanako.esp")
			if (bodyNakedArmor != None)
				DTSleep_ModCompanionBodiesLst.AddForm(bodyNakedArmor)
				
				(DTSConditionals as DTSleep_Conditionals).ModCompanionBodyNanaIndex = DTSleep_ModCompanionBodiesLst.GetSize() - 1
				DTSleep_ModCompanionBodiesLst.AddForm(Game.GetFormFromFile(0x090020EA, "AnimeRace_Nanako.esp"))
			endIf
		endIf
	elseIf (!Game.IsPluginInstalled("AnimeRace_Nanako.esp"))
		Debug.Trace(myScriptName + " AnimeRace_Nanako has been removed")
		(DTSConditionals as DTSleep_Conditionals).NanaRace = None
		(DTSConditionals as DTSleep_Conditionals).NanaRace2 = None
		(DTSConditionals as DTSleep_Conditionals).PlayerRace = None			; reset for next check
	endIf
	
	Armor extraArmor = None
	
	; Holoboy
	if ((DTSConditionals as DTSleep_Conditionals).IsHoloboyActive)
		if (!Game.IsPluginInstalled("Holoboy.esp"))
			(DTSConditionals as DTSleep_Conditionals).IsHoloboyActive = false
		endIf
	else
		extraArmor = IsPluginActive(0x05000A03, "Holoboy.esp") as Armor
		if (extraArmor != None)
			(DTSConditionals as DTSleep_Conditionals).IsHoloboyActive = true
			if (!DTSleep_ArmorPipBoyList.HasForm(extraArmor))
				DTSleep_ArmorPipBoyList.AddForm(extraArmor)
				
				if (DTSleep_ArmorExtraPartsList.HasForm(extraArmor as Form))
					Debug.Trace(myScriptName + " removing Holoboy from ExtraParts list")
					DTSleep_ArmorExtraPartsList.RemoveAddedForm(extraArmor as Form)
				endIf
			endIf
		endIf
	endIf
	
	
	;  DX Atom Girl
	if ((DTSConditionals as DTSleep_Conditionals).IsDXAtomGirlActive)
		if (!Game.IsPluginInstalled("DX_Atom_Girl_Outfit.esp"))
			Debug.Trace(myScriptName + " DX_Atom_Girl_Outfit has been removed")
			(DTSConditionals as DTSleep_Conditionals).IsDXAtomGirlActive = false
		endIf
	else 
		extraArmor = IsPluginActive(0x02000955, "DX_Atom_Girl_Outfit.esp") as Armor
		
		if (extraArmor)
			; Atom Girl added
			; 0x02000955 is DX_Nukabear
			(DTSConditionals as DTSleep_Conditionals).IsDXAtomGirlActive = true
			DTSleep_ExtraArmorsEnabled.SetValue(1.0)
			
			if (!DTSleep_ArmorExtraPartsList.HasForm(extraArmor))
				DTSleep_ArmorExtraPartsList.AddForm(extraArmor)
				DTSleep_ArmorCarryPouchList.AddForm(extraArmor)
				DTSleep_ArmorExtraPartsList.AddForm(Game.GetFormFromFile(0x02000951, "DX_Atom_Girl_Outfit.esp") as Armor)
				DTSleep_ArmorExtraClothingList.AddForm(Game.GetFormFromFile(0x02000956, "DX_Atom_Girl_Outfit.esp") as Armor) ; panty
				DTSleep_ArmorExtraClothingList.AddForm(Game.GetFormFromFile(0x02000957, "DX_Atom_Girl_Outfit.esp") as Armor) ; skirt
				DTSleep_ArmorExtraClothingList.AddForm(Game.GetFormFromFile(0x0200096A, "DX_Atom_Girl_Outfit.esp") as Armor) ; skirt torn
				DTSleep_ArmorExtraPartsList.AddForm(Game.GetFormFromFile(0x02000959, "DX_Atom_Girl_Outfit.esp") as Armor) ; cables
			endIf
			
			if (!DTSleep_FemBedItemFList.HasForm(extraArmor))
				DTSleep_FemBedItemFList.AddForm(extraArmor)
				(DTSConditionals as DTSleep_Conditionals).DXAtomGirlNukaBearIndex = DTSleep_FemBedItemFList.GetSize() - 1
			endIf
			; fishnet and panty use cage armor ground object - do not use for sleepwear
		endIf
	endIf
	
	; DX Black Widow
	if ((DTSConditionals as DTSleep_Conditionals).IsDXBlackWidowActive == false)
		extraArmor = IsPluginActive(0x2E006BEC, "DX_Black_Widow.esp") as Armor ; main outfit
		if (extraArmor != None)
			(DTSConditionals as DTSleep_Conditionals).IsDXBlackWidowActive = true
			DTSleep_ArmorAllExceptionList.AddForm(extraArmor as Form)
			DTSleep_ArmorHatHelmList.AddForm(Game.GetFormFromFile(0x2E001FBD, "DX_Black_Widow.esp"))
		endIf
	elseIf (!Game.IsPluginInstalled("DX_Black_Widow.esp"))
		Debug.Trace(myScriptName + "DX_Black_Widow has been removed")
		(DTSConditionals as DTSleep_Conditionals).IsDXBlackWidowActive = false
	endIf
	
	; DX Vault 111 Outfit -- added v2.70
	if ((DTSConditionals as DTSleep_Conditionals).IsDXVaultOutfitActive == false)
		extraArmor = IsPluginActive(0x09011365, "DX_Vault_111_Outfit.esp") as Armor    ; backpack
		if (extraArmor != None)
			(DTSConditionals as DTSleep_Conditionals).IsDXVaultOutfitActive == true
			DTSleep_ArmorBackPacksNoGOList.AddForm(extraArmor as Form)
		endIf
	endIf
	
	; Ranger Gear
	if ((DTSConditionals as DTSleep_Conditionals).IsRangerGearActive == false)
		Armor helmet = IsPluginActive(0x02000805, "Rangergearnew.esp") as Armor
		if (helmet)
			(DTSConditionals as DTSleep_Conditionals).IsRangerGearActive = true
			
			if (!DTSleep_ArmorHatHelmList.HasForm(helmet))
				DTSleep_ArmorHatHelmList.AddForm(helmet)
				DTSleep_ArmorHatHelmList.AddForm(Game.GetFormFromFile(0x02000806, "Rangergearnew.esp"))
				DTSleep_ArmorHatHelmList.AddForm(Game.GetFormFromFile(0x0200083E, "Rangergearnew.esp"))
				DTSleep_ArmorHatHelmList.AddForm(Game.GetFormFromFile(0x020017F6, "Rangergearnew.esp"))
				DTSleep_ArmorHatHelmList.AddForm(Game.GetFormFromFile(0x020017F7, "Rangergearnew.esp"))
				DTSleep_ArmorHatHelmList.AddForm(Game.GetFormFromFile(0x020017F8, "Rangergearnew.esp"))
				DTSleep_ArmorHatHelmList.AddForm(Game.GetFormFromFile(0x0200A13C, "Rangergearnew.esp"))
				DTSleep_ArmorHatHelmList.AddForm(Game.GetFormFromFile(0x0200A560, "Rangergearnew.esp"))
				DTSleep_ArmorHatHelmList.AddForm(Game.GetFormFromFile(0x0200A561, "Rangergearnew.esp"))
				DTSleep_ArmorHatHelmList.AddForm(Game.GetFormFromFile(0x0200A562, "Rangergearnew.esp"))
				DTSleep_ArmorHatHelmList.AddForm(Game.GetFormFromFile(0x0200A563, "Rangergearnew.esp"))
				DTSleep_ArmorMaskList.AddForm(Game.GetFormFromFile(0x02000805, "Rangergearnew.esp"))
				DTSleep_ArmorMaskList.AddForm(Game.GetFormFromFile(0x0200083E, "Rangergearnew.esp"))
				DTSleep_ArmorMaskList.AddForm(Game.GetFormFromFile(0x020017F6, "Rangergearnew.esp"))
				DTSleep_ArmorMaskList.AddForm(Game.GetFormFromFile(0x020017F7, "Rangergearnew.esp"))
				DTSleep_ArmorMaskList.AddForm(Game.GetFormFromFile(0x020017F8, "Rangergearnew.esp"))
				DTSleep_ArmorMaskList.AddForm(Game.GetFormFromFile(0x0200A13C, "Rangergearnew.esp"))
				DTSleep_ArmorMaskList.AddForm(Game.GetFormFromFile(0x0200A560, "Rangergearnew.esp"))
				DTSleep_ArmorMaskList.AddForm(Game.GetFormFromFile(0x0200A561, "Rangergearnew.esp"))
				DTSleep_ArmorMaskList.AddForm(Game.GetFormFromFile(0x0200A562, "Rangergearnew.esp"))
				DTSleep_ArmorCarryPouchList.AddForm(Game.GetFormFromFile(0x0200D05C, "Rangergearnew.esp"))
				DTSleep_ArmorCarryPouchList.AddForm(Game.GetFormFromFile(0x0200D05D, "Rangergearnew.esp"))
				DTSleep_ArmorCarryPouchList.AddForm(Game.GetFormFromFile(0x0200D05E, "Rangergearnew.esp"))
				DTSleep_ArmorCarryPouchList.AddForm(Game.GetFormFromFile(0x0200D05F, "Rangergearnew.esp"))
				DTSleep_ArmorAllExceptionList.AddForm(Game.GetFormFromFile(0x02000804, "Rangergearnew.esp"))
				DTSleep_ArmorAllExceptionList.AddForm(Game.GetFormFromFile(0x02002674, "Rangergearnew.esp"))
				DTSleep_ArmorAllExceptionList.AddForm(Game.GetFormFromFile(0x0200A55F, "Rangergearnew.esp"))
				
				; new for v2
				DTSleep_ArmorArmLeftList.AddForm(Game.GetFormFromFile(0x0200081D, "Rangergearnew.esp"))
				DTSleep_ArmorArmRightList.AddForm(Game.GetFormFromFile(0x0200081C, "Rangergearnew.esp"))
				DTSleep_ArmorLegLeftList.AddForm(Game.GetFormFromFile(0x0200081E, "Rangergearnew.esp"))
				DTSleep_ArmorLegRightList.AddForm(Game.GetFormFromFile(0x0200081F, "Rangergearnew.esp"))
				DTSleep_ArmorTorsoList.AddForm(Game.GetFormFromFile(0x02000820, "Rangergearnew.esp"))
				DTSleep_ArmorTorsoList.AddForm(Game.GetFormFromFile(0x020054D5, "Rangergearnew.esp"))
				DTSleep_ArmorTorsoList.AddForm(Game.GetFormFromFile(0x020054D6, "Rangergearnew.esp"))
				DTSleep_ArmorArmLeftList.AddForm(Game.GetFormFromFile(0x020054D7, "Rangergearnew.esp"))
				DTSleep_ArmorArmRightList.AddForm(Game.GetFormFromFile(0x020054D8, "Rangergearnew.esp"))
				DTSleep_ArmorArmLeftList.AddForm(Game.GetFormFromFile(0x020054D9, "Rangergearnew.esp"))
				DTSleep_ArmorArmRightList.AddForm(Game.GetFormFromFile(0x020054DA, "Rangergearnew.esp"))
			endIf
		endIf
	elseIf (!Game.IsPluginInstalled("Rangergearnew.esp"))
		Debug.Trace(myScriptName + " Rangergearnew has been removed")
		(DTSConditionals as DTSleep_Conditionals).IsRangerGearActive = false
	endIf
	
	; ProvisionerBackPack
	if ((DTSConditionals as DTSleep_Conditionals).IsProvisionerBackPackActive == false)
		extraArmor = IsPluginActive(0x01000801, "ProvisionerBackPack.esp") as Armor
		if (extraArmor)
			(DTSConditionals as DTSleep_Conditionals).IsProvisionerBackPackActive = true
			if (!DTSleep_ArmorBackPacksList.HasForm(extraArmor))
				DTSleep_ArmorBackPacksList.AddForm(extraArmor)
			endIf
		endIf
	elseIf (!Game.IsPluginInstalled("ProvisionerBackPack.esp"))
		Debug.Trace(myScriptName + " ProvisionerBackPack has been removed")
		(DTSConditionals as DTSleep_Conditionals).IsProvisionerBackPackActive = false
	endIf
	
	; Scavver's Backpacks
	if ((DTSConditionals as DTSleep_Conditionals).IsScavversBackPackActive == false)
		extraArmor = IsPluginActive(0x01000FB0, "Scavver's Backpacks.esp") as Armor
		if (extraArmor != None)
			(DTSConditionals as DTSleep_Conditionals).IsScavversBackPackActive = true
			if (!DTSleep_ArmorBackPacksList.HasForm(extraArmor as Form))
				DTSleep_ArmorBackPacksList.AddForm(extraArmor as Form)
				DTSleep_ArmorBackPacksList.AddForm(Game.GetFormFromFile(0x020035DC, "Scavver's Backpacks.esp"))
			endIf
		endIf
	elseIf (!Game.IsPluginInstalled("Scavver's Backpacks.esp"))
		Debug.Trace(myScriptName + " Scavvers Backpacks has been removed")
		(DTSConditionals as DTSleep_Conditionals).IsScavversBackPackActive = false
	endIf
	
	; SnapBeds
	; v2.25 update force check to correct for error
	;
	if ((DTSConditionals as DTSleep_Conditionals).IsSnapBedsActive == false || DTSleep_LastVersion.GetValue() < 2.250)
	
		Furniture snapBed = IsPluginActive(0x030035A3, "SnapBeds.esp") as Furniture
		
		if (snapBed == None)
			(DTSConditionals as DTSleep_Conditionals).IsSnapBedsActive = false
		else
			(DTSConditionals as DTSleep_Conditionals).IsSnapBedsActive = true
			if (!DTSleep_BedList.HasForm(snapBed as Form))
		
				DTSleep_BedList.AddForm(snapBed as Form)
				DTSleep_BedList.AddForm(Game.GetFormFromFile(0x03004C72, "SnapBeds.esp"))
				DTSleep_BedList.AddForm(Game.GetFormFromFile(0x03004C77, "SnapBeds.esp"))
				snapBed = Game.GetFormFromFile(0x03004C78, "SnapBeds.esp") as Furniture
				DTSleep_BedList.AddForm(snapBed as Form)
				DTSleep_BedsLimitedSpaceLst.AddForm(snapBed as Form)
				DTSleep_BedList.AddForm(Game.GetFormFromFile(0x03004C79, "SnapBeds.esp"))
				DTSleep_BedList.AddForm(Game.GetFormFromFile(0x03004C7A, "SnapBeds.esp"))
				DTSleep_BedList.AddForm(Game.GetFormFromFile(0x03004C7B, "SnapBeds.esp"))
				DTSleep_BedChildList.AddForm(Game.GetFormFromFile(0x03005425, "SnapBeds.esp"))
				DTSleep_BedChildList.AddForm(Game.GetFormFromFile(0x03005426, "SnapBeds.esp")) ; child
				DTSleep_BedChildList.AddForm(Game.GetFormFromFile(0x03005427, "SnapBeds.esp"))  ; child
				DTSleep_BedChildList.AddForm(Game.GetFormFromFile(0x03005BD8, "SnapBeds.esp"))  ; child
				DTSleep_BedChildList.AddForm(Game.GetFormFromFile(0x03005BD9, "SnapBeds.esp"))  ; child
				DTSleep_BedChildList.AddForm(Game.GetFormFromFile(0x03005BDB, "SnapBeds.esp"))  ; child
				
				; only include "left half" for companion -- v1.53: allow companion in both sides
				
				snapBed = Game.GetFormFromFile(0x03006364, "SnapBeds.esp") as Furniture	; "right" pre-war
				if (snapBed != None)
					AddToBedsList(snapBed, true)
					DTSleep_BedsBigList.AddForm(snapBed as Form)
				endIf
				snapBed = Game.GetFormFromFile(0x03006365, "SnapBeds.esp") as Furniture	; "left" pre-war
				AddToBedsList(snapBed, true)
				DTSleep_BedsBigList.AddForm(snapBed as Form)
				
				DTSleep_BedChildList.AddForm(Game.GetFormFromFile(0x03006B01, "SnapBeds.esp"))  ; hospital
				DTSleep_BedList.AddForm(Game.GetFormFromFile(0x03006B04, "SnapBeds.esp"))
				DTSleep_BedChildList.AddForm(Game.GetFormFromFile(0x03006B04, "SnapBeds.esp")) ; cot
				DTSleep_BedChildList.AddForm(Game.GetFormFromFile(0x03006B07, "SnapBeds.esp"))  ; cot
				DTSleep_BedList.AddForm(Game.GetFormFromFile(0x03006B09, "SnapBeds.esp"))
				DTSleep_BedList.AddForm(Game.GetFormFromFile(0x03006B0B, "SnapBeds.esp"))
				DTSleep_BedList.AddForm(Game.GetFormFromFile(0x03006B0D, "SnapBeds.esp"))
				DTSleep_BedList.AddForm(Game.GetFormFromFile(0x03006B0F, "SnapBeds.esp"))
				DTSleep_BedList.AddForm(Game.GetFormFromFile(0x03006B11, "SnapBeds.esp"))
				DTSleep_BedList.AddForm(Game.GetFormFromFile(0x03006B14, "SnapBeds.esp"))
				DTSleep_BedList.AddForm(Game.GetFormFromFile(0x03006B16, "SnapBeds.esp"))
				DTSleep_BedList.AddForm(Game.GetFormFromFile(0x03006B1A, "SnapBeds.esp"))
				DTSleep_BedList.AddForm(Game.GetFormFromFile(0x03006B1C, "SnapBeds.esp"))
				DTSleep_BedList.AddForm(Game.GetFormFromFile(0x03006B1F, "SnapBeds.esp"))
				DTSleep_BedList.AddForm(Game.GetFormFromFile(0x03006B21, "SnapBeds.esp"))
				DTSleep_BedList.AddForm(Game.GetFormFromFile(0x03006B44, "SnapBeds.esp"))
				DTSleep_BedList.AddForm(Game.GetFormFromFile(0x03006B45, "SnapBeds.esp"))
				DTSleep_BedList.AddForm(Game.GetFormFromFile(0x03006B46, "SnapBeds.esp"))
				DTSleep_BedList.AddForm(Game.GetFormFromFile(0x03006B48, "SnapBeds.esp"))
				DTSleep_BedList.AddForm(Game.GetFormFromFile(0x03006B49, "SnapBeds.esp"))
				DTSleep_BedList.AddForm(Game.GetFormFromFile(0x03006B4A, "SnapBeds.esp"))
				DTSleep_BedList.AddForm(Game.GetFormFromFile(0x03006B4B, "SnapBeds.esp"))
				DTSleep_BedList.AddForm(Game.GetFormFromFile(0x03006B4C, "SnapBeds.esp"))
				DTSleep_BedList.AddForm(Game.GetFormFromFile(0x03006B4D, "SnapBeds.esp"))
				DTSleep_BedList.AddForm(Game.GetFormFromFile(0x03006B4E, "SnapBeds.esp"))
				DTSleep_BedList.AddForm(Game.GetFormFromFile(0x03006B4F, "SnapBeds.esp"))
				DTSleep_BedList.AddForm(Game.GetFormFromFile(0x03006B50, "SnapBeds.esp"))
				DTSleep_BedList.AddForm(Game.GetFormFromFile(0x03006B52, "SnapBeds.esp"))
				DTSleep_BedList.AddForm(Game.GetFormFromFile(0x03006B53, "SnapBeds.esp"))
				DTSleep_BedChildList.AddForm(Game.GetFormFromFile(0x03006B55, "SnapBeds.esp")) ; child
				DTSleep_BedChildList.AddForm(Game.GetFormFromFile(0x03006B56, "SnapBeds.esp")) ; child
				DTSleep_BedChildList.AddForm(Game.GetFormFromFile(0x03006B57, "SnapBeds.esp")) ; child
				DTSleep_BedChildList.AddForm(Game.GetFormFromFile(0x03006B58, "SnapBeds.esp")) ; child
				DTSleep_BedChildList.AddForm(Game.GetFormFromFile(0x03006B59, "SnapBeds.esp")) ; child
				DTSleep_BedChildList.AddForm(Game.GetFormFromFile(0x03006B5A, "SnapBeds.esp")) ; child
				DTSleep_BedChildList.AddForm(Game.GetFormFromFile(0x03006B5B, "SnapBeds.esp")) ; child
				DTSleep_BedChildList.AddForm(Game.GetFormFromFile(0x03006B5C, "SnapBeds.esp")) ; child
				DTSleep_BedChildList.AddForm(Game.GetFormFromFile(0x03006B5D, "SnapBeds.esp")) ; child
				DTSleep_BedChildList.AddForm(Game.GetFormFromFile(0x03006B5E, "SnapBeds.esp")) ; child
				DTSleep_BedChildList.AddForm(Game.GetFormFromFile(0x03006B5F, "SnapBeds.esp")) ; child
				DTSleep_BedChildList.AddForm(Game.GetFormFromFile(0x03006B60, "SnapBeds.esp")) ; child
				DTSleep_BedChildList.AddForm(Game.GetFormFromFile(0x03006B61, "SnapBeds.esp")) ; child
				DTSleep_BedChildList.AddForm(Game.GetFormFromFile(0x03006B62, "SnapBeds.esp")) ; child
				DTSleep_BedChildList.AddForm(Game.GetFormFromFile(0x03006B63, "SnapBeds.esp")) ; child
				DTSleep_BedChildList.AddForm(Game.GetFormFromFile(0x03006B64, "SnapBeds.esp")) ; child
				
				; double-bed: right-half for player -intimate and left-half for companion
				; v1.54 - allow both sides - v1.57 - include both sides on double-bed list
				
				AddToBedsList(Game.GetFormFromFile(0x03006B65, "SnapBeds.esp"), true)		; left-half
				AddToBedsList(Game.GetFormFromFile(0x03006B66, "SnapBeds.esp"), true) ; right-half
				AddToBedsList(Game.GetFormFromFile(0x03006B67, "SnapBeds.esp"), true)
				AddToBedsList(Game.GetFormFromFile(0x03006B68, "SnapBeds.esp"), true)
				AddToBedsList(Game.GetFormFromFile(0x03006B69, "SnapBeds.esp"), true)
				AddToBedsList(Game.GetFormFromFile(0x03006B6A, "SnapBeds.esp"), true)
				AddToBedsList(Game.GetFormFromFile(0x03006B6B, "SnapBeds.esp"), true)
				AddToBedsList(Game.GetFormFromFile(0x03006B6C, "SnapBeds.esp"), true)
				AddToBedsList(Game.GetFormFromFile(0x03006B6D, "SnapBeds.esp"), true)
				AddToBedsList(Game.GetFormFromFile(0x03006B6E, "SnapBeds.esp"), true)
				AddToBedsList(Game.GetFormFromFile(0x03006B6F, "SnapBeds.esp"), true)
				AddToBedsList(Game.GetFormFromFile(0x03006B70, "SnapBeds.esp"), true)
				AddToBedsList(Game.GetFormFromFile(0x03006B71, "SnapBeds.esp"), true)
				AddToBedsList(Game.GetFormFromFile(0x03006B72, "SnapBeds.esp"), true)
				AddToBedsList(Game.GetFormFromFile(0x03006B73, "SnapBeds.esp"), true)
				AddToBedsList(Game.GetFormFromFile(0x03006B74, "SnapBeds.esp"), true)
				AddToBedsList(Game.GetFormFromFile(0x03006B75, "SnapBeds.esp"), true)
				AddToBedsList(Game.GetFormFromFile(0x03006B76, "SnapBeds.esp"), true)
				AddToBedsList(Game.GetFormFromFile(0x03006B77, "SnapBeds.esp"), true)
				AddToBedsList(Game.GetFormFromFile(0x03006B78, "SnapBeds.esp"), true)
				AddToBedsList(Game.GetFormFromFile(0x03006B79, "SnapBeds.esp"), true)
				AddToBedsList(Game.GetFormFromFile(0x03006B7A, "SnapBeds.esp"), true)
				AddToBedsList(Game.GetFormFromFile(0x03006B7B, "SnapBeds.esp"), true)
				AddToBedsList(Game.GetFormFromFile(0x03006B7C, "SnapBeds.esp"), true)
				AddToBedsList(Game.GetFormFromFile(0x03006B7D, "SnapBeds.esp"), true)
				AddToBedsList(Game.GetFormFromFile(0x03006B7E, "SnapBeds.esp"), true)
				AddToBedsList(Game.GetFormFromFile(0x03006B7F, "SnapBeds.esp"), true)
				AddToBedsList(Game.GetFormFromFile(0x03006B80, "SnapBeds.esp"), true)
				AddToBedsList(Game.GetFormFromFile(0x03006B81, "SnapBeds.esp"), true)
				AddToBedsList(Game.GetFormFromFile(0x03006B82, "SnapBeds.esp"), true)
				AddToBedsList(Game.GetFormFromFile(0x03006B83, "SnapBeds.esp"), true)
				AddToBedsList(Game.GetFormFromFile(0x03006B84, "SnapBeds.esp"), true)
				
				snapBed = Game.GetFormFromFile(0x03009967, "SnapBeds.esp") as Furniture
				DTSleep_BedList.AddForm(snapBed as Form)
				DTSleep_BedsLimitedSpaceLst.AddForm(snapBed)
				snapBed = Game.GetFormFromFile(0x03009968, "SnapBeds.esp") as Furniture
				DTSleep_BedList.AddForm(snapBed as Form)
				DTSleep_BedsLimitedSpaceLst.AddForm(snapBed as Form)
				DTSleep_BedsBigList.AddForm(Game.GetFormFromFile(0x03006B66, "SnapBeds.esp"))
				DTSleep_BedsBigList.AddForm(Game.GetFormFromFile(0x03006B68, "SnapBeds.esp"))
				DTSleep_BedsBigList.AddForm(Game.GetFormFromFile(0x03006B6A, "SnapBeds.esp"))
				DTSleep_BedsBigList.AddForm(Game.GetFormFromFile(0x03006B6C, "SnapBeds.esp"))
				DTSleep_BedsBigList.AddForm(Game.GetFormFromFile(0x03006B6E, "SnapBeds.esp"))
				DTSleep_BedsBigList.AddForm(Game.GetFormFromFile(0x03006B70, "SnapBeds.esp"))
				DTSleep_BedsBigList.AddForm(Game.GetFormFromFile(0x03006B72, "SnapBeds.esp"))
				DTSleep_BedsBigList.AddForm(Game.GetFormFromFile(0x03006B74, "SnapBeds.esp"))
				DTSleep_BedsBigList.AddForm(Game.GetFormFromFile(0x03006B7D, "SnapBeds.esp"))
				DTSleep_BedsBigList.AddForm(Game.GetFormFromFile(0x03006B7E, "SnapBeds.esp"))
				DTSleep_BedsBigList.AddForm(Game.GetFormFromFile(0x03006B7F, "SnapBeds.esp"))
				DTSleep_BedsBigList.AddForm(Game.GetFormFromFile(0x03006B80, "SnapBeds.esp"))
				DTSleep_BedsBigList.AddForm(Game.GetFormFromFile(0x03006B81, "SnapBeds.esp"))
				DTSleep_BedsBigList.AddForm(Game.GetFormFromFile(0x03006B82, "SnapBeds.esp"))
				DTSleep_BedsBigList.AddForm(Game.GetFormFromFile(0x03006B83, "SnapBeds.esp"))
				DTSleep_BedsBigList.AddForm(Game.GetFormFromFile(0x03006B84, "SnapBeds.esp"))
				
				; mark bunks as no-go zones
				DTSleep_BedBunkFrameList.AddForm(Game.GetFormFromFile(0x03001ED3, "SnapBeds.esp"))
				
			endIf
		endIf
	elseIf (!Game.IsPluginInstalled("SnapBeds.esp"))
		(DTSConditionals as DTSleep_Conditionals).IsSnapBedsActive = false		; v2.25 corrected
	endIf
	
	; HZS Easy Homebuilder
	string hzsName = "HZS Easy Homebuilder and Working Double Beds.esp"
	
	if ((DTSConditionals as DTSleep_Conditionals).IsHZSHomebuilderActive <= 0)
		Form pillowForm = IsPluginActive(0x09002E14, hzsName)
		if (pillowForm != None)
			(DTSConditionals as DTSleep_Conditionals).IsHZSHomebuilderActive = 1
			if (!DTSleep_BedPillowBedList.HasForm(pillowForm))
				AddToBedsList(pillowForm, false, DTSleep_BedPillowBedList)
				AddToBedsList(Game.GetFormFromFile(0x0902D00F, hzsName), false, DTSleep_BedPillowBedList)	; invisible player pillow
				AddToBedsList(Game.GetFormFromFile(0x0902D010, hzsName), false, DTSleep_BedPillowBedList)
				AddToBedsList(Game.GetFormFromFile(0x0902F61A, hzsName), false, DTSleep_BedPillowBedList)	; player pillow	
				AddToBedsList(Game.GetFormFromFile(0x0902F61B, hzsName), false, DTSleep_BedPillowBedList)
				AddToBedsList(Game.GetFormFromFile(0x09005BC6, hzsName), false, DTSleep_BedPillowBedList)
				AddToBedsList(Game.GetFormFromFile(0x09005BC7, hzsName), false, DTSleep_BedPillowBedList)
				AddToBedsList(Game.GetFormFromFile(0x09005BE0, hzsName), false, DTSleep_BedPillowBedList)
				AddToBedsList(Game.GetFormFromFile(0x09006B0E, hzsName), false, DTSleep_BedPillowBedList)
				AddToBedsList(Game.GetFormFromFile(0x09005BE2, hzsName), false, DTSleep_BedPillowBedList)
				AddToBedsList(Game.GetFormFromFile(0x0900647B, hzsName), false, DTSleep_BedPillowBedList)
				AddToBedsList(Game.GetFormFromFile(0x0900647C, hzsName), false, DTSleep_BedPillowBedList)
				AddToBedsList(Game.GetFormFromFile(0x0900647D, hzsName), false, DTSleep_BedPillowBedList)
				AddToBedsList(Game.GetFormFromFile(0x0900647E, hzsName), false, DTSleep_BedPillowBedList)
				AddToBedsList(Game.GetFormFromFile(0x0900647F, hzsName), false, DTSleep_BedPillowBedList)
				AddToBedsList(Game.GetFormFromFile(0x09006480, hzsName), false, DTSleep_BedPillowBedList)
				AddToBedsList(Game.GetFormFromFile(0x09006C4B, hzsName), false, DTSleep_BedPillowBedList)
				AddToBedsList(Game.GetFormFromFile(0x09006C4C, hzsName), false, DTSleep_BedPillowBedList)
				AddToBedsList(Game.GetFormFromFile(0x09006C4D, hzsName), false, DTSleep_BedPillowBedList)
				AddToBedsList(Game.GetFormFromFile(0x09006C4E, hzsName), false, DTSleep_BedPillowBedList)
				AddToBedsList(Game.GetFormFromFile(0x09006C4F, hzsName), false, DTSleep_BedPillowBedList)
				AddToBedsList(Game.GetFormFromFile(0x09006C50, hzsName), false, DTSleep_BedPillowBedList)
				AddToBedsList(Game.GetFormFromFile(0x09003DF4, hzsName), false, DTSleep_BedPillowBedList)
				AddToBedsList(Game.GetFormFromFile(0x09005BD8, hzsName), false, DTSleep_BedPillowBedList)
				AddToBedsList(Game.GetFormFromFile(0x0900729F, hzsName), false, DTSleep_BedPillowBedList)
				AddToBedsList(Game.GetFormFromFile(0x09009137, hzsName), false, DTSleep_BedPillowBedList)
				AddToBedsList(Game.GetFormFromFile(0x0900A072, hzsName), false, DTSleep_BedPillowBedList)
				AddToBedsList(Game.GetFormFromFile(0x0900C59B, hzsName), false, DTSleep_BedPillowBedList)
				AddToBedsList(Game.GetFormFromFile(0x0900C69B, hzsName), false, DTSleep_BedPillowBedList)
				AddToBedsList(Game.GetFormFromFile(0x09020010, hzsName), false, DTSleep_BedPillowBedList)
				
				; ground pillows
				pillowForm = Game.GetFormFromFile(0x09006C59, hzsName)
				DTSleep_BedList.AddForm(pillowForm)
				DTSleep_BedPillowBedList.AddForm(pillowForm)
				pillowForm = Game.GetFormFromFile(0x09003D4F, hzsName)
				DTSleep_BedList.AddForm(pillowForm)
				DTSleep_BedPillowBedList.AddForm(pillowForm)
				pillowForm = Game.GetFormFromFile(0x09005BD9, hzsName)
				DTSleep_BedList.AddForm(pillowForm)
				DTSleep_BedPillowBedList.AddForm(pillowForm)
				pillowForm = Game.GetFormFromFile(0x09005BDB, hzsName)
				DTSleep_BedList.AddForm(pillowForm)
				DTSleep_BedPillowBedList.AddForm(pillowForm)
				pillowForm = Game.GetFormFromFile(0x0901051E, hzsName)
				DTSleep_BedList.AddForm(pillowForm)
				DTSleep_BedPillowBedList.AddForm(pillowForm)
				pillowForm = Game.GetFormFromFile(0x09006C5A, hzsName)
				DTSleep_BedList.AddForm(pillowForm)
				DTSleep_BedPillowBedList.AddForm(pillowForm)
				pillowForm = Game.GetFormFromFile(0x09006C5B, hzsName)
				DTSleep_BedList.AddForm(pillowForm)
				DTSleep_BedPillowBedList.AddForm(pillowForm)
				pillowForm = Game.GetFormFromFile(0x09006C5C, hzsName)
				DTSleep_BedList.AddForm(pillowForm)
				DTSleep_BedPillowBedList.AddForm(pillowForm)
				pillowForm = Game.GetFormFromFile(0x09006C5D, hzsName)
				DTSleep_BedList.AddForm(pillowForm)
				DTSleep_BedPillowBedList.AddForm(pillowForm)
				pillowForm = Game.GetFormFromFile(0x09006C5E, hzsName)
				DTSleep_BedList.AddForm(pillowForm)
				DTSleep_BedPillowBedList.AddForm(pillowForm)
				
				; coffin
				DTSleep_BedList.AddForm(Game.GetFormFromFile(0x0900DEC4, hzsName))

				; chairs
				DTSleep_IntimateKitchenSeatList.AddForm(Game.GetFormFromFile(0x09006B50, hzsName))
				DTSleep_IntimateCouchList.AddForm(Game.GetFormFromFile(0x090098F6, hzsName))
				DTSleep_IntimateCouchFedList.AddForm(Game.GetFormFromFile(0x090098F7, hzsName))
				DTSleep_IntimateCouchFedList.AddForm(Game.GetFormFromFile(0x09006B4D, hzsName))
				DTSleep_IntimateCouchList.AddForm(Game.GetFormFromFile(0x09007A4A, hzsName))
				DTSleep_IntimateChairsList.AddForm(Game.GetFormFromFile(0x09007A49, hzsName))
				
				; double-bed frames
				
				DTSleep_BedPillowFrameDBList.AddForm(Game.GetFormFromFile(0x0901050D, hzsName))
				DTSleep_BedPillowFrameDBList.AddForm(Game.GetFormFromFile(0x0900FD67, hzsName))
				DTSleep_BedPillowFrameDBList.AddForm(Game.GetFormFromFile(0x0901050A, hzsName))
				DTSleep_BedPillowFrameDBList.AddForm(Game.GetFormFromFile(0x0901050B, hzsName))
				;DTSleep_BedPillowFrameDBList.AddForm(Game.GetFormFromFile(0x09007B0A, hzsName))
				DTSleep_BedPillowFrameDBList.AddForm(Game.GetFormFromFile(0x0901050C, hzsName))
				DTSleep_BedPillowFrameDBList.AddForm(Game.GetFormFromFile(0x09010527, hzsName))
				DTSleep_BedPillowFrameDBList.AddForm(Game.GetFormFromFile(0x0901052B, hzsName))
				DTSleep_BedPillowFrameDBList.AddForm(Game.GetFormFromFile(0x0900FD63, hzsName))
				
				; single-bed big frames
				DTSleep_BedPillowFrameSBList.AddForm(Game.GetFormFromFile(0x09011469, hzsName))
				DTSleep_BedPillowFrameSBList.AddForm(Game.GetFormFromFile(0x0901146C, hzsName))
				DTSleep_BedPillowFrameSBList.AddForm(Game.GetFormFromFile(0x0901146D, hzsName))
				DTSleep_BedPillowFrameSBList.AddForm(Game.GetFormFromFile(0x09011471, hzsName))
				DTSleep_BedPillowFrameSBList.AddForm(Game.GetFormFromFile(0x09011472, hzsName))
				DTSleep_BedPillowFrameSBList.AddForm(Game.GetFormFromFile(0x09011473, hzsName))
				DTSleep_BedPillowFrameSBList.AddForm(Game.GetFormFromFile(0x09011481, hzsName))
				; intitute big frames
				DTSleep_BedPillowFrameSBList.AddForm(Game.GetFormFromFile(0x09005C13, hzsName))
				DTSleep_BedPillowFrameSBList.AddForm(Game.GetFormFromFile(0x09005C15, hzsName))
				DTSleep_BedPillowFrameSBList.AddForm(Game.GetFormFromFile(0x09007B0B, hzsName))
				DTSleep_BedPillowFrameSBList.AddForm(Game.GetFormFromFile(0x09007B0C, hzsName))
				DTSleep_BedPillowFrameSBList.AddForm(Game.GetFormFromFile(0x09007B0A, hzsName))
				DTSleep_BedPillowFrameSBList.AddForm(Game.GetFormFromFile(0x0900A075, hzsName))
				DTSleep_BedPillowFrameSBList.AddForm(Game.GetFormFromFile(0x09007B0D, hzsName))
				DTSleep_BedPillowFrameSBList.AddForm(Game.GetFormFromFile(0x09007B0E, hzsName))
				DTSleep_BedPillowFrameSBList.AddForm(Game.GetFormFromFile(0x09002E18, hzsName))
				
				;narrow bed frames - pillows align too low
				DTSleep_BedPillowFrameBadList.AddForm(Game.GetFormFromFile(0x09008287, hzsName))
				DTSleep_BedPillowFrameBadList.AddForm(Game.GetFormFromFile(0x09008AA9, hzsName))
				DTSleep_BedPillowFrameBadList.AddForm(Game.GetFormFromFile(0x09009900, hzsName))
				DTSleep_BedPillowFrameBadList.AddForm(Game.GetFormFromFile(0x09005C6D, hzsName))
				
				; cot pillow poor alignment for animations
				DTSleep_BedNoIntimateList.AddForm(Game.GetFormFromFile(0x09020010, hzsName))
				
				; child beds
				DTSleep_BedChildList.AddForm(Game.GetFormFromFile(0x09006B34, hzsName))
				DTSleep_BedChildList.AddForm(Game.GetFormFromFile(0x09006B36, hzsName))
				DTSleep_BedChildList.AddForm(Game.GetFormFromFile(0x09006B3A, hzsName))
				DTSleep_BedChildList.AddForm(Game.GetFormFromFile(0x090072D9, hzsName))
				DTSleep_BedChildList.AddForm(Game.GetFormFromFile(0x09010520, hzsName))
				DTSleep_BedChildList.AddForm(Game.GetFormFromFile(0x09010522, hzsName))
				DTSleep_BedChildList.AddForm(Game.GetFormFromFile(0x09006391, hzsName))
				DTSleep_BedChildList.AddForm(Game.GetFormFromFile(0x09008996, hzsName))
				DTSleep_BedChildList.AddForm(Game.GetFormFromFile(0x09008998, hzsName))
				
				; sedans
				DTSleep_IntimateSedanPreWarList.AddForm(Game.GetFormFromFile(0x09008A3B, hzsName))
				DTSleep_IntimateSedanPreWarList.AddForm(Game.GetFormFromFile(0x09008A46, hzsName))
				DTSleep_IntimateSedanPreWarList.AddForm(Game.GetFormFromFile(0x09008A47, hzsName))
				
				; bunk frame
				DTSleep_BedBunkFrameList.AddForm(Game.GetFormFromFile(0x09011473, hzsName))
			endIf
		endIf
	elseIf (!Game.IsPluginInstalled(hzsName))
		(DTSConditionals as DTSleep_Conditionals).IsHZSHomebuilderActive = -1
	endIf
	
	
	; check for mods that require normal game sleep events
	if (!(DTSConditionals as DTSleep_Conditionals).HasModReqNormSleep)
		if (Game.IsPluginInstalled("AdvancedNeeds2.esp"))

			(DTSConditionals as DTSleep_Conditionals).HasModReqNormSleep = true
		endIf
	endIf
	
	; ------------------------ 
	;   Adult only
	;
	if (DTSleep_AdultContentOn.GetValue() >= 1.0)
	
		if (Game.IsPluginInstalled("LooksMenu.esp"))
			;if (!(DTSConditionals as DTSleep_Conditionals).IsLooksMenuActive)
			;	; TODO: set pref
			;	
			;endIf
			(DTSConditionals as DTSleep_Conditionals).IsLooksMenuActive = true
		else
			(DTSConditionals as DTSleep_Conditionals).IsLooksMenuActive = false
		endIf
	
		if (Game.IsPluginInstalled("AAFMorningSexWithLover.esp"))
			(DTSConditionals as DTSleep_Conditionals).IsMorningSexActive = true
		else
			(DTSConditionals as DTSleep_Conditionals).IsMorningSexActive = false
		endIf
	
		; Lacy Underwear
		string lacyPlugin = "Lacy Underwear.esp"
		
		if ((DTSConditionals as DTSleep_Conditionals).IsLacyUnderwearActive)
			Debug.Trace(myScriptName + " Lacy Underwear previously found")
			if (!Game.IsPluginInstalled(lacyPlugin))
				Debug.Trace(myScriptName + "Lacy Underwear has been removed")
				(DTSConditionals as DTSleep_Conditionals).IsLacyUnderwearActive = false
			endIf
		else
			
			if (!Game.IsPluginInstalled(lacyPlugin))
				lacyPlugin = "Lacy Underwear (AWKCR).esp"
			endIf
		
			extraArmor = IsPluginActive(0x01100005, lacyPlugin) as Armor
			if (extraArmor)
				(DTSConditionals as DTSleep_Conditionals).IsLacyUnderwearActive = true
				DTSleep_ExtraArmorsEnabled.SetValue(1.0)
				
				if (!DTSleep_ArmorSlotFXList.HasForm(extraArmor))
					DTSleep_ArmorSlotFXList.AddForm(extraArmor)
					extraArmor = Game.GetFormFromFile(0x01100006, lacyPlugin) as Armor
					DTSleep_ArmorSlotFXList.AddForm(extraArmor)
					extraArmor = Game.GetFormFromFile(0x01100007, lacyPlugin) as Armor
					DTSleep_ArmorSlotFXList.AddForm(extraArmor)
					extraArmor = Game.GetFormFromFile(0x01100008, lacyPlugin) as Armor
					DTSleep_ArmorSlotFXList.AddForm(extraArmor)
				endIf
				extraArmor = Game.GetFormFromFile(0x01100009, lacyPlugin) as Armor
				if (!DTSleep_ArmorSlot58List.HasForm(extraArmor))
					DTSleep_ArmorSlot58List.AddForm(extraArmor)
					DTSleep_SleepAttireFemale.AddForm(extraArmor)
					extraArmor = Game.GetFormFromFile(0x0110000A, lacyPlugin) as Armor
					DTSleep_ArmorSlot58List.AddForm(extraArmor)
					DTSleep_SleepAttireFemale.AddForm(extraArmor)
					extraArmor = Game.GetFormFromFile(0x0110000B, lacyPlugin) as Armor
					DTSleep_ArmorSlot58List.AddForm(extraArmor)
					DTSleep_SleepAttireFemale.AddForm(extraArmor)
					extraArmor = Game.GetFormFromFile(0x0110000C, lacyPlugin) as Armor
					DTSleep_ArmorSlot58List.AddForm(extraArmor)
					DTSleep_SleepAttireFemale.AddForm(extraArmor)
				endIf
				extraArmor = Game.GetFormFromFile(0x01100001, lacyPlugin) as Armor
				if (!DTSleep_SleepAttireFemale.HasForm(extraArmor))
					DTSleep_SleepAttireFemale.AddForm(extraArmor)
					DTSleep_SleepAttireFemale.AddForm(Game.GetFormFromFile(0x01100002, lacyPlugin) as Armor)
					DTSleep_SleepAttireFemale.AddForm(Game.GetFormFromFile(0x01100003, lacyPlugin) as Armor)
					DTSleep_SleepAttireFemale.AddForm(Game.GetFormFromFile(0x01100004, lacyPlugin) as Armor)
				endIf
			endIf
		endIf
		
		; SavageCabbage - allow in XOXO so player can have extra dance
		if (Game.IsPluginInstalled("SavageCabbage_Animations.esp"))
			
			bool fixNeeded = true
			
			if (!(DTSConditionals as DTSleep_Conditionals).IsSavageCabbageActive)
				Idle danceIdle = Game.GetFormFromFile(0x0800182C, "SavageCabbage_Animations.esp") as Idle
				if (danceIdle != None && !DTSleep_Dance2List.HasForm(danceIdle))
					fixNeeded = false
					DTSleep_Dance2List.AddForm(danceIdle as Form)
					DTSleep_Dance2List.AddForm(Game.GetFormFromFile(0x0800182D, "SavageCabbage_Animations.esp"))
				endIf
				(DTSConditionals as DTSleep_Conditionals).SavageCabbageVers = 1.04
			endIf
			(DTSConditionals as DTSleep_Conditionals).IsSavageCabbageActive = true					;v2.50 moved below dance idle
			
			Form idleForm = None
			if ((DTSConditionals as DTSleep_Conditionals).SavageCabbageVers < 1.280)				; v2.79 updated for latest SC
				
				idleForm = Game.GetFormFromFile(0x08032D6E, "SavageCabbage_Animations.esp")
				
				if (idleForm != None)
					(DTSConditionals as DTSleep_Conditionals).SavageCabbageVers = 1.280
				else
					idleForm = Game.GetFormFromFile(0x0803257D, "SavageCabbage_Animations.esp")
					if (idleForm != None)
						(DTSConditionals as DTSleep_Conditionals).SavageCabbageVers = 1.270
					else
						idleForm = Game.GetFormFromFile(0x08030D9C, "SavageCabbage_Animations.esp")
						if (idleForm != None)
							(DTSConditionals as DTSleep_Conditionals).SavageCabbageVers = 1.260
							
						else 
							idleForm = Game.GetFormFromFile(0x08030575, "SavageCabbage_Animations.esp")
							if (idleForm != None)
								(DTSConditionals as DTSleep_Conditionals).SavageCabbageVers = 1.250
							endIf
						endIf
					endIf
				endIf
				
				; fix for if missing above
				if (fixNeeded)
					Idle danceIdle = Game.GetFormFromFile(0x0800182C, "SavageCabbage_Animations.esp") as Idle
					if (danceIdle != None && !DTSleep_Dance2List.HasForm(danceIdle))
						DTSleep_Dance2List.AddForm(danceIdle as Form)
						DTSleep_Dance2List.AddForm(Game.GetFormFromFile(0x0800182D, "SavageCabbage_Animations.esp"))
					endIf
				endIf
			endIf
			if ((DTSConditionals as DTSleep_Conditionals).SavageCabbageVers < 1.240)
		
				idleForm = Game.GetFormFromFile(0x0802FDA6, "SavageCabbage_Animations.esp")
				if (idleForm != None)
					(DTSConditionals as DTSleep_Conditionals).SavageCabbageVers = 1.240
				endIf
			endIf
			if ((DTSConditionals as DTSleep_Conditionals).SavageCabbageVers < 1.230)
		
				idleForm = Game.GetFormFromFile(0x0802F5E4, "SavageCabbage_Animations.esp")
				if (idleForm != None)
					(DTSConditionals as DTSleep_Conditionals).SavageCabbageVers = 1.230
				endIf
			endIf
			if ((DTSConditionals as DTSleep_Conditionals).SavageCabbageVers < 1.220)
		
				idleForm = Game.GetFormFromFile(0x0802E685, "SavageCabbage_Animations.esp")
				if (idleForm != None)
					(DTSConditionals as DTSleep_Conditionals).SavageCabbageVers = 1.220
				endIf
			endIf
			if ((DTSConditionals as DTSleep_Conditionals).SavageCabbageVers < 1.210)
		
				idleForm = Game.GetFormFromFile(0x0802DEBA, "SavageCabbage_Animations.esp")
				if (idleForm != None)
					(DTSConditionals as DTSleep_Conditionals).SavageCabbageVers = 1.210
				endIf
			endIf
			if ((DTSConditionals as DTSleep_Conditionals).SavageCabbageVers < 1.20)
		
				idleForm = Game.GetFormFromFile(0x0802C023, "SavageCabbage_Animations.esp")
				if (idleForm != None)
					(DTSConditionals as DTSleep_Conditionals).SavageCabbageVers = 1.20
				endIf
			endIf
			if ((DTSConditionals as DTSleep_Conditionals).SavageCabbageVers < 1.1)
				idleForm = Game.GetFormFromFile(0x05024CE1, "SavageCabbage_Animations.esp")
				if (idleForm != None)
					DTSleep_Dance2List.AddForm(idleForm)
					(DTSConditionals as DTSleep_Conditionals).SavageCabbageVers = 1.10
				endIf
			endIf
			
		else
			(DTSConditionals as DTSleep_Conditionals).IsSavageCabbageActive = false
			(DTSConditionals as DTSleep_Conditionals).SavageCabbageVers = -1.0
		endIf
		
		; -------------------------- X ------------------
		
		if (DTSleep_AdultContentOn.GetValue() >= 2.0)
		
			; AAF - v1.92 moved down here since no longer needed for XOXO
			if (Game.IsPluginInstalled("AAF.esm"))
				(DTSConditionals as DTSleep_Conditionals).IsAAFActive = true
			else
				(DTSConditionals as DTSleep_Conditionals).IsAAFActive = false
			endIf
		
			;Vio Strap-On by Vioxis
			if ((DTSConditionals as DTSleep_Conditionals).IsVioStrapOnActive == false)
				String vioName = "VIO_Strap-On.esp"
				int vioAltNameIdx = 0
				
				Armor strapOn = IsPluginActive(0x08000F9F, vioName) as Armor
				if (strapOn == None)
					; v2.63 -- alternate by an3k
					vioName = "Vioxsis_Strap-Ons.esp"
					vioAltNameIdx = 1
					strapOn = IsPluginActive(0x08000F9F, vioName) as Armor
				endIf
				if (strapOn != None)
					Debug.Trace(myScriptName + " found VIO Strap-On")
					(DTSConditionals as DTSleep_Conditionals).IsVioStrapOnActive = true
					DTSleep_ExtraArmorsEnabled.SetValue(1.0)
					
					if (!DTSleep_StrapOnList.HasForm(strapOn as Form))
						AddStrapOnToLists(strapOn, DTSleep_ArmorSlot55List)
						strapOn = Game.GetFormFromFile(0x08000FA0, vioName) as Armor
						AddStrapOnToLists(strapOn, DTSleep_ArmorSlot55List)
						strapOn = Game.GetFormFromFile(0x0800173B, vioName) as Armor
						AddStrapOnToLists(strapOn, DTSleep_ArmorSlot55List)
						strapOn = Game.GetFormFromFile(0x08002E0A, vioName) as Armor
						AddStrapOnToLists(strapOn, DTSleep_ArmorSlot55List)
						; this is my addition - available with patch
						string myPatchName = "VIO_Strap-On_SIXPatch.esp"
						if (vioAltNameIdx == 1)
							myPatchName = "Vioxsis_Strap-Ons_SIXPatch.esp"
						endIf
						strapOn = Game.GetFormFromFile(0x080044D9, myPatchName) as Armor
						if (strapOn != None)
							AddStrapOnToLists(strapOn, DTSleep_ArmorSlot55List)
						endIf
					endIf
					; new from v3
					strapOn = Game.GetFormFromFile(0x08005413, vioName) as Armor
					if (strapOn != None)
						AddStrapOnToLists(strapOn, DTSleep_ArmorSlot55List)
						AddStrapOnToLists(Game.GetFormFromFile(0x08005414, vioName) as Armor, DTSleep_ArmorSlot55List)
						AddStrapOnToLists(Game.GetFormFromFile(0x08005415, vioName) as Armor, DTSleep_ArmorSlot55List)
						AddStrapOnToLists(Game.GetFormFromFile(0x08005416, vioName) as Armor, DTSleep_ArmorSlot55List)
					endIf
				endIf
			elseIf (!Game.IsPluginInstalled("VIO_Strap-On.esp") && !Game.IsPluginInstalled("VIO_Strap-Ons.esp"))
				Debug.Trace(myScriptName + " VIO_Strap-On has been removed")
				(DTSConditionals as DTSleep_Conditionals).IsVioStrapOnActive = false
			endIf
			
			bool noPlayChild = true
			
			if (IsChildPluginActive())
				Debug.Trace(myScriptName + " has custom play-as-child plug-in ")
				DTSleep_IsLeitoActive.SetValueInt(-10)
				noPlayChild = false
				if ((DTSConditionals as DTSleep_Conditionals).IsLeitoActive)
					(DTSConditionals as DTSleep_Conditionals).IsLeitoActive = false
					RevertLeitoLists()
				endIf
			endIf
			
			if (noPlayChild)
		
				; Atomic Lust  --- AAF is a master, but we'll allow it if player removed master
				; v1.92 - moved down here since no longer needed for XOXO
				;
				string alPlugName = "Atomic Lust.esp"
				if (Game.IsPluginInstalled(alPlugName))
					(DTSConditionals as DTSleep_Conditionals).IsAtomicLustActive = true
					DTSleep_ActivPAStation.SetValue(1.0)
					
					if ((DTSConditionals as DTSleep_Conditionals).AtomicLustVers < 2.61)
						Idle anIdle = Game.GetFormFromFile(0x0804D0BC, alPlugName) as Idle
						
						if (anIdle != None)
							(DTSConditionals as DTSleep_Conditionals).AtomicLustVers = 2.61
					
						elseIf ((DTSConditionals as DTSleep_Conditionals).AtomicLustVers < 2.50)
							anIdle = Game.GetFormFromFile(0x0804C920, alPlugName) as Idle
							if (anIdle != None)
								(DTSConditionals as DTSleep_Conditionals).AtomicLustVers = 2.50
							
							elseIf ((DTSConditionals as DTSleep_Conditionals).AtomicLustVers < 2.43)
								anIdle = Game.GetFormFromFile(0x08043FBA, alPlugName) as Idle
								if (anIdle != None)
									(DTSConditionals as DTSleep_Conditionals).AtomicLustVers = 2.43
								else
									(DTSConditionals as DTSleep_Conditionals).AtomicLustVers = 2.21
								endIf
							endIf
						endIf
					endIf
				else
					(DTSConditionals as DTSleep_Conditionals).IsAtomicLustActive = false
					(DTSConditionals as DTSleep_Conditionals).AtomicLustVers = -1.0
					DTSleep_ActivPAStation.SetValue(-1.0)
				endIf
				
				; Mutated Lust
				if (Game.IsPluginInstalled("Mutated Lust.esp"))
					(DTSConditionals as DTSleep_Conditionals).IsMutatedLustActive = true
				else
					(DTSConditionals as DTSleep_Conditionals).IsMutatedLustActive = false
				endIf
				
				; old Rufgt
				if (Game.IsPluginInstalled("Rufgt's Animations.esp"))
					(DTSConditionals as DTSleep_Conditionals).IsRufgtActive = true
				else
					(DTSConditionals as DTSleep_Conditionals).IsRufgtActive = false
				endIf
				
				extraArmor = None
			
				; F04 Animations by Leito
				string fo4LeitoPluginName = "FO4_AnimationsByLeito.esp"
				float patchVal = DTSleep_IsLeitoActive.GetValue()
				int sixVal = DTSleep_SIXPatch.GetValueInt()
				
				; for v1.80+ resorted plugin checks by priority giving X_Anims preference for old player
				
				if (patchVal >= 3.0 || sixVal >= 4)
				
					if (Game.IsPluginInstalled("SleepIntimateX_Anims.esp"))
						Debug.Trace(myScriptName + " found SleepIntimateX_Anims v" + sixVal)
						
						if (patchVal == 3.0 && sixVal >= 4)
							; upgrade - reload data
							RevertLeitoLists()
							LoadLeitoAnimForms("SleepIntimateX_Anims.esp")
							LoadLeitoCreatureAnimForms("SleepIntimateX_Anims.esp")
						elseIf (patchVal <= 2)
							; new
							RevertLeitoLists()
							LoadLeitoAnimForms("SleepIntimateX_Anims.esp")
							LoadLeitoCreatureAnimForms("SleepIntimateX_Anims.esp")
						endIf
						DTSleep_IsLeitoActive.SetValueInt(sixVal)
						patchVal = sixVal as float
						(DTSConditionals as DTSleep_Conditionals).IsLeitoActive = true
					else
						Debug.Trace(myScriptName + " SleepIntimateX_Anims v" + patchVal + " has been removed")
						RevertLeitoLists()
						(DTSConditionals as DTSleep_Conditionals).IsLeitoActive = false	; reset
						DTSleep_IsLeitoActive.SetValue((0.0 - patchVal))
						(DTSConditionals as DTSleep_Conditionals).LeitoAnimVers = -1.0
						patchVal = -3.0
					endIf
				elseIf (patchVal <= -3.0)
					patchVal = -1.0				; in case regular plugin active
				endIf
				
				; Leito's v2 for AAF
				Form leitoForm = IsPluginActive(0x0800D692, fo4LeitoPluginName)	;v2 - LeitoZazSquirtUberAnim
					
				if ((DTSConditionals as DTSleep_Conditionals).IsLeitoAAFActive)
					if (leitoForm == None)
						Debug.Trace(myScriptName + " FO4 animations by Leito v2 plugin has been removed ")
						(DTSConditionals as DTSleep_Conditionals).IsLeitoAAFActive = false
						(DTSConditionals as DTSleep_Conditionals).LeitoAnimVers = -2.0
						if (patchVal < 3 && sixVal < 4)
							RevertLeitoLists()				;v2.16 - force revert and set patchVal
							patchVal = -1.0
							DTSleep_IsLeitoActive.SetValue(-1.0)
						endIf
					elseIf (patchVal <= 1)				;v2.40a
						RevertLeitoLists()
						DTSleep_IsLeitoActive.SetValue(2.0)	; best-fit
						LoadLeitoAnimForms(fo4LeitoPluginName)
						LoadLeitoCreatureAnimForms(fo4LeitoPluginName)
					endIf
					
				elseIf (leitoForm != None)
					
					(DTSConditionals as DTSleep_Conditionals).IsLeitoAAFActive = true
					
					if (patchVal <= 0.0)
						; new   v2.16 -- was handled below, but not for case when failed to Revert from earlier
						DTSleep_IsLeitoActive.SetValue(2.0)	; best-fit
						RevertLeitoLists()
						LoadLeitoAnimForms(fo4LeitoPluginName)
						LoadLeitoCreatureAnimForms(fo4LeitoPluginName)
						
					elseIf ((DTSConditionals as DTSleep_Conditionals).IsLeitoActive && patchVal <= 2.0)
						; upgrade from old
						Debug.Trace(myScriptName + " FO4 animations by Leito upgrade to v2 ")
						(DTSConditionals as DTSleep_Conditionals).IsLeitoActive = false
						DTSleep_IsLeitoActive.SetValue(2.0)	; best-fit
						RevertLeitoLists()
						LoadLeitoAnimForms(fo4LeitoPluginName)
						LoadLeitoCreatureAnimForms(fo4LeitoPluginName)
					endIf
					
					if (patchVal != 2.1)
						; check for chair animatinos -- v2.73
						leitoForm = Game.GetFormFromFile(0x0800CEE4, fo4LeitoPluginName)
						if (leitoForm != None)
							Debug.Trace(myScriptName + " found Leito's FO4 Animations v2.1")
							DTSleep_IsLeitoActive.SetValue(2.1)
							(DTSConditionals as DTSleep_Conditionals).LeitoAnimVers = 2.10
						endIf
					endIf
				endIf
				
				if (!(DTSConditionals as DTSleep_Conditionals).IsLeitoAAFActive && sixVal < 3)
				
					leitoForm = IsPluginActive(0x0800636A, fo4LeitoPluginName)		; old v1.4 gun armor 
						
					if ((DTSConditionals as DTSleep_Conditionals).IsLeitoActive)
						if (leitoForm == None)
							Debug.Trace(myScriptName + " FO4 animations by Leito v1.4 plugin has been removed ")
							(DTSConditionals as DTSleep_Conditionals).IsLeitoActive = false
							DTSleep_IsLeitoActive.SetValue(-2.0);
							RevertLeitoLists()
							
						elseIf (patchVal < 0.0)
							; new
							RevertLeitoLists()
							LoadLeitoAnimForms(fo4LeitoPluginName)
							LoadLeitoCreatureAnimForms(fo4LeitoPluginName)
							DTSleep_IsLeitoActive.SetValue(2.0)  ; best-fit and dog -- v1.44
						else
							; check for missing idles

							if (DTSleep_LeitoCowgirl2A2List.GetSize() < 4)
								Debug.Trace(myScriptName + " updating missing leito anims - all")
								RevertLeitoLists()
								LoadLeitoAnimForms(fo4LeitoPluginName)
								LoadLeitoCreatureAnimForms(fo4LeitoPluginName)
							elseIf (DTSleep_LeitoCanine2DogList.GetSize() < 3 || DTSleep_LeitoCanine2FemaleList.GetSize() < 3 || DTSleep_LeitoStrongMaleList.GetSize() < 4)
								Debug.Trace(myScriptName + " updating missing leito creature anims")
								RevertLeitoCreatureLists()
								
								LoadLeitoCreatureAnimForms(fo4LeitoPluginName)
							endIf
							
							DTSleep_IsLeitoActive.SetValue(2.0)  ; best-fit and dog -- v1.44
						endIf
				
					elseIf (leitoForm != None)
						(DTSConditionals as DTSleep_Conditionals).IsLeitoActive = true
						(DTSConditionals as DTSleep_Conditionals).LeitoAnimVers = -1.0
						DTSleep_IsLeitoActive.SetValue(2.0)  ; best-fit and dog -- v1.44
						
						RevertLeitoLists()
						LoadLeitoAnimForms(fo4LeitoPluginName)
						LoadLeitoCreatureAnimForms(fo4LeitoPluginName)
					else
						(DTSConditionals as DTSleep_Conditionals).IsLeitoActive = false
						(DTSConditionals as DTSleep_Conditionals).LeitoAnimVers = -1.0
					endIf
				endIf
				
				; Crazy Animations Gun version
				Idle crazyIdle = IsPluginActive(0x08004C8D, "Crazy_Animations_Gun.esp") as Idle
				if ((DTSConditionals as DTSleep_Conditionals).IsCrazyAnimGunActive)
					if (crazyIdle == None)
						Debug.Trace(myScriptName + " Crazy_Animations_Gun has been removed")
						(DTSConditionals as DTSleep_Conditionals).IsCrazyAnimGunActive = false
					endIf
				elseIf (crazyIdle)
					(DTSConditionals as DTSleep_Conditionals).IsCrazyAnimGunActive = true
					if (!DTSleep_CrazyGunBedFemaleList.HasForm(crazyIdle))
						DTSleep_CrazyGunBedFemaleList.AddForm(crazyIdle)  ; missionary
						DTSleep_CrazyGunBedFemaleList.AddForm(Game.GetFormFromFile(0x08004C8A, "Crazy_Animations_Gun.esp"))  ; Pound
						DTSleep_CrazyGunBedFemaleList.AddForm(Game.GetFormFromFile(0x08004C89, "Crazy_Animations_Gun.esp"))  ; DDogNorm
						DTSleep_CrazyGunBedFemaleList.AddForm(Game.GetFormFromFile(0x0800173F, "Crazy_Animations_Gun.esp"))  ; Riding
						DTSleep_CrazyGunStandFemaleList.AddForm(Game.GetFormFromFile(0x08005432, "Crazy_Animations_Gun.esp"))  ; MbateLayF
						DTSleep_CrazyGunStandFemaleList.AddForm(Game.GetFormFromFile(0x08006368, "Crazy_Animations_Gun.esp"))  ; HandJob
					endIf
					crazyIdle = Game.GetFormFromFile(0x08004C8E, "Crazy_Animations_Gun.esp") as Idle   ; missionary
					if (crazyIdle && !DTSleep_CrazyGunBedMaleList.HasForm(crazyIdle))
						DTSleep_CrazyGunBedMaleList.AddForm(crazyIdle)
						DTSleep_CrazyGunBedMaleList.AddForm(Game.GetFormFromFile(0x08004C8B, "Crazy_Animations_Gun.esp"))  ; Pound
						DTSleep_CrazyGunBedMaleList.AddForm(Game.GetFormFromFile(0x08001738, "Crazy_Animations_Gun.esp"))  ; DDog
						DTSleep_CrazyGunBedMaleList.AddForm(Game.GetFormFromFile(0x08001740, "Crazy_Animations_Gun.esp"))  ; Riding
						DTSleep_CrazyGunStandMaleList.AddForm(Game.GetFormFromFile(0x08005433, "Crazy_Animations_Gun.esp"))  ; JerkOffM
						DTSleep_CrazyGunStandMaleList.AddForm(Game.GetFormFromFile(0x08006369, "Crazy_Animations_Gun.esp"))  ; HandJob
					endIf
				else
					(DTSConditionals as DTSleep_Conditionals).IsCrazyAnimGunActive = false
				endIf
				
				; ZaZOut4
				if (Game.IsPluginInstalled("ZaZOut4.esp"))

					DTSleep_IsZaZOut.SetValue(2.0)
					(DTSConditionals as DTSleep_Conditionals).ZaZPilloryKW = Game.GetFormFromFile(0x0900266F, "ZaZOut4.esp") as Keyword
					
					Form pilloryForm = Game.GetFormFromFile(0x09002670, "ZaZOut4.esp")
					if (pilloryForm != None && !DTSleep_PilloryList.HasForm(pilloryForm))
						DTSleep_PilloryList.AddForm(pilloryForm)
						DTSleep_PilloryList.AddForm(Game.GetFormFromFile(0x09004CA1, "ZaZOut4.esp"))
						DTSleep_PilloryList.AddForm(Game.GetFormFromFile(0x09004CA3, "ZaZOut4.esp"))
						DTSleep_PilloryList.AddForm(Game.GetFormFromFile(0x09004CA5, "ZaZOut4.esp"))
						
						
						
						;LoadZaZAnimForms("ZaZOut4.esp")
					endIf
				else
					DTSleep_IsZaZOut.SetValue(-1.0)
					(DTSConditionals as DTSleep_Conditionals).ZaZPilloryKW = None
				endIf
				
				; GrayAnimations - 50 Shades of Fallout
				if (Game.IsPluginInstalled("AAF_GrayAnimations.esp"))
				
					(DTSConditionals as DTSleep_Conditionals).IsGrayAnimsActive = true
				else
					(DTSConditionals as DTSleep_Conditionals).IsGrayAnimsActive = false
				endIf
				if (Game.IsPluginInstalled("AAF_CreaturePack01.esp"))
					(DTSConditionals as DTSleep_Conditionals).IsGrayCreatureActive = true
				else
					(DTSConditionals as DTSleep_Conditionals).IsGrayCreatureActive = false
				endIf
				
				; FPFP Family Planning Enhanced  - v2.71
				if ((DTSConditionals as DTSleep_Conditionals).ModFPFP_Married == None)
					Perk fpMarriedPerk = Game.GetFormFromFile(0x0901E9A1, "FP_FamilyPlanningEnhanced.esp") as Perk
					
					if (fpMarriedPerk != None)
						(DTSConditionals as DTSleep_Conditionals).ModFPFP_Married = fpMarriedPerk
						(DTSConditionals as DTSleep_Conditionals).ModFPFP_Married2 = Game.GetFormFromFile(0x0901E9AA, "FP_FamilyPlanningEnhanced.esp") as Perk
					endIf
					
				endIf
				
				; ------------------------chair animations check ------------------------------------------------
				;
				; v2.73 moved this block down to here after we checked all animation packs
				; check sex chair-mod active (Atomic Lust just 1 animation--only include with other packs)
				if ((DTSConditionals as DTSleep_Conditionals).IsSavageCabbageActive)
					if ((DTSConditionals as DTSleep_Conditionals).SavageCabbageVers >= 1.27)			; v2.77
						DTSleep_ActivFlagpole.SetValue(2.0)
						DTSleep_ActivChairs.SetValue(5.0)
					elseIf ((DTSConditionals as DTSleep_Conditionals).SavageCabbageVers >= 1.26)
						DTSleep_ActivFlagpole.SetValue(2.0)
						DTSleep_ActivChairs.SetValue(4.0)
					elseIf ((DTSConditionals as DTSleep_Conditionals).SavageCabbageVers >= 1.20)
						DTSleep_ActivFlagpole.SetValue(2.0)
						DTSleep_ActivChairs.SetValue(3.0)
					elseIf ((DTSConditionals as DTSleep_Conditionals).SavageCabbageVers >= 1.10)
						DTSleep_ActivFlagpole.SetValue(2.0)
						DTSleep_ActivChairs.SetValue(2.0)
					else
						DTSleep_ActivFlagpole.SetValue(-1.0)
						DTSleep_ActivChairs.SetValue(2.0)
					endIf
				elseIf ((DTSConditionals as DTSleep_Conditionals).LeitoAnimVers >= 2.1)				; v2.73 allow only having Leito chairs
					DTSleep_ActivFlagpole.SetValue(-1.0)
					DTSleep_ActivChairs.SetValue(1.60)		; set to more restrictive list of seats for perk to mark as Relax+
				else
					DTSleep_ActivChairs.SetValue(-1.0)
					DTSleep_ActivFlagpole.SetValue(-1.0)
					if (SleepQuestScript.DTSleep_SettingChairsEnabled.GetValueInt() >= 2)
						SleepQuestScript.DTSleep_SettingChairsEnabled.SetValue(1.0)
					endIf
				endIf
				; ---------------------------------------------------------------------
				
				ValidateLeitoSettings()
				
			endIf	; end no-play-child
		else
			; no adult allowed
			DTSleep_ActivChairs.SetValue(-2.0)
			DTSleep_ActivPAStation.SetValue(-1.0)
			DTSleep_IsZaZOut.SetValue(-2.0)
			if (SleepQuestScript.DTSleep_SettingChairsEnabled.GetValueInt() >= 2)
				SleepQuestScript.DTSleep_SettingChairsEnabled.SetValue(1.0)
			endIf
		endIf
	endIf
	; ------------------ end Adult only ---------------------
	
	
	Debug.Trace(myScriptName + " =====================================================================")
	Debug.Trace(myScriptName + "           ------- end compatibility check ---------- ")
	Debug.Trace(myScriptName + " =====================================================================")
EndFunction

int Function CheckF4SEMCM(bool always = false)
	int result = 0
	if (always || (DTSleep_MCMEnable.GetValue() <= 0.0 && !(DTSConditionals as DTSleep_Conditionals).IsF4SE))
		Debug.Trace(myScriptName + " check F4SE - expected error if without")
		if (F4SE.GetVersionRelease() > 0)
			(DTSConditionals as DTSleep_Conditionals).IsF4SE = true
			if (!DTSleep_MCMQuestP.IsRunning())
				result = 1
				DTSleep_MCMQuestP.Start()

			endIf
		else
			(DTSConditionals as DTSleep_Conditionals).IsF4SE = false
			if (DTSleep_MCMEnable.GetValueInt() < 0)
				DTSleep_MCMEnable.SetValue(0.0)
			endIf
		endIf
	endIf
	
	if (result != 1 && (DTSConditionals as DTSleep_Conditionals).IsF4SE && DTSleep_MCMQuestP.IsRunning())
		(DTSleep_MCMQuestP as DTSleep_MCMQuest).DoOnLoad()
	endIf
	return result
endFunction

int Function CheckCustomPlayerHomes()
	int modCount = 0
	
	Debug.Trace(myScriptName + " =====================================================================")
	Debug.Trace(myScriptName + "------- begin Custom Player Homes, Locations, and Furniture ------  ")
	Debug.Trace(myScriptName + "  **** only checked on first load, updates, and by request  *****")
	
	Form locForm = IsPluginActive(0x0300359F, "Eli_Chestnut Lodge DLC.esp")
	if (locForm && !DTSleep_PrivateLocationList.HasForm(locForm))
		modCount += 1
		DTSleep_PrivateLocationList.AddForm(locForm)
		
		Furniture bed = Game.GetFormFromFile(0x032002B7, "Eli_Chestnut Lodge DLC.esp") as Furniture
		if (bed && !DTSleep_BedList.HasForm(bed))
			DTSleep_BedList.AddForm(bed)
			DTSleep_BedsBigList.AddForm(bed)
		endIf
	endIf
	
	; EferasBetterBeds
	
	string eferasName = "EferasBetterBeds.esp"
	if (!Game.IsPluginInstalled(eferasName))
		eferasName = "EferasBetterBeds.esl"
	endIf

	
	locForm = IsPluginActive(0x03000804, eferasName)
	if (locForm != None)
		if (!DTSleep_BedList.HasForm(locForm))
			modCount += 1
			AddToBedsList(locForm)
			DTSleep_BedsBigList.AddForm(locForm)
			DTSleep_BedIntimateList.AddForm(Game.GetFormFromFile(0x03000802, eferasName))
		endIf
	endIf
	
	locForm = IsPluginActive(0x03001681, "3DNPC_FO4.esp")
	if (locForm != None)
		if (!DTSleep_UndressLocationList.HasForm(locForm))
			modCount += 1
			DTSleep_UndressLocationList.AddForm(locForm)
			DTSleep_TownLocationList.AddForm(Game.GetFormFromFile(0x030023A3, "3DNPC_FO4.esp"))
			DTSleep_TownLocationList.AddForm(Game.GetFormFromFile(0x0300560E, "3DNPC_FO4.esp"))
			DTSleep_ArmorAllExceptionList.AddForm(Game.GetFormFromFile(0x030077EE, "3DNPC_FO4.esp"))
			DTSleep_ArmorAllExceptionList.AddForm(Game.GetFormFromFile(0x0300C9A3, "3DNPC_FO4.esp"))
			DTSleep_ArmorMaskList.AddForm(Game.GetFormFromFile(0x03003CDD, "3DNPC_FO4.esp"))
			DTSleep_ArmorMaskList.AddForm(Game.GetFormFromFile(0x03006099, "3DNPC_FO4.esp"))
			
		endIf
	endIf
	
	; Settlements Expanded
	string ssexName = "SSEX.esp"
	if (!Game.IsPluginInstalled(ssexName))
		ssexName = "SSEX.esl"
	endIf
	
	Form bedForm = IsPluginActive(0x09000B8C, ssexName)
	if (bedForm != None)
		if (!DTSleep_BedsBigList.HasForm(bedForm))
			modCount += 1
			DTSleep_BedsBigList.AddForm(bedForm)
			DTSleep_BedsBigDoubleList.AddForm(bedForm)
			AddToBedsList(bedForm)
			bedForm = Game.GetFormFromFile(0x09000B95, ssexName)
			AddToBedsList(bedForm, true)
			DTSleep_BedsBigList.AddForm(bedForm)
			bedForm = Game.GetFormFromFile(0x09000BA2, ssexName)
			AddToBedsList(bedForm, true)
			DTSleep_BedsBigList.AddForm(bedForm)
			DTSleep_BedList.AddForm(Game.GetFormFromFile(0x09000B8A, ssexName))
			DTSleep_BedList.AddForm(Game.GetFormFromFile(0x09000B8B, ssexName))
			DTSleep_BedList.AddForm(Game.GetFormFromFile(0x09000B8D, ssexName))
			DTSleep_BedList.AddForm(Game.GetFormFromFile(0x09000B9B, ssexName))
			DTSleep_BedList.AddForm(Game.GetFormFromFile(0x09000B9C, ssexName))
			DTSleep_BedList.AddForm(Game.GetFormFromFile(0x09000BA0, ssexName))
		endIf
		if (DTSleep_ActivChairs.GetValueInt() >= 2)
			bedForm = Game.GetFormFromFile(0x09000A18, ssexName)
			if (bedForm != None && !DTSleep_IntimateChairsList.HasForm(bedForm))
				DTSleep_IntimateChairsList.AddForm(bedForm)
				DTSleep_IntimateChairHighList.AddForm(Game.GetFormFromFile(0x09000A17, ssexName))
				DTSleep_IntimateChairHighList.AddForm(Game.GetFormFromFile(0x09000A00, ssexName))
				DTSleep_IntimateChairLowList.AddForm(Game.GetFormFromFile(0x09000A16, ssexName))
				DTSleep_IntimateChairLowList.AddForm(Game.GetFormFromFile(0x09000A05, ssexName))
			endIf
		endIf
		bedForm = Game.GetFormFromFile(0x09000B9B, ssexName)
		if (!DTSleep_BedsBunkList.HasForm(bedForm))
			DTSleep_BedsBunkList.AddForm(bedForm)
			DTSleep_BedsBunkList.AddForm(Game.GetFormFromFile(0x09000B9C, ssexName))
		endIf
	endIf
	
	if (Game.IsPluginInstalled("Homemaker.esm"))
		if (DTSleep_ActivChairs.GetValueInt() >= 2)
			Form chairForm = Game.GetFormFromFile(0x09001764, "Homemaker.esm")
			if (chairForm != None && !DTSleep_IntimateChairsList.HasForm(chairForm))
				
				DTSleep_IntimateChairsList.AddForm(chairForm)
				DTSleep_IntimateChairHighList.AddForm(Game.GetFormFromFile(0x0900114F, "Homemaker.esm"))
				DTSleep_IntimateChairLowList.AddForm(Game.GetFormFromFile(0x09001D8B, "Homemaker.esm"))
				DTSleep_IntimateChairLowList.AddForm(Game.GetFormFromFile(0x09001D8C, "Homemaker.esm"))
			endIf
		endIf
		
		bedForm = Game.GetFormFromFile(0x0900099A, "Homemaker.esm")
		if (!DTSleep_BedList.HasForm(bedForm))
			modCount += 1
			
			DTSleep_BedList.AddForm(bedForm)
			DTSleep_BedsBigList.AddForm(bedForm)
			bedForm = Game.GetFormFromFile(0x090012E7, "Homemaker.esm")
			DTSleep_BedList.AddForm(bedForm)
			DTSleep_BedsBigList.AddForm(bedForm)
			bedForm = Game.GetFormFromFile(0x09001DB2, "Homemaker.esm")
			DTSleep_BedList.AddForm(bedForm)
			DTSleep_BedsBigList.AddForm(bedForm)
			DTSleep_BedList.AddForm(Game.GetFormFromFile(0x09000997, "Homemaker.esm"))
			DTSleep_BedList.AddForm(Game.GetFormFromFile(0x09000998, "Homemaker.esm"))
			DTSleep_BedList.AddForm(Game.GetFormFromFile(0x09001D96, "Homemaker.esm"))
			DTSleep_BedList.AddForm(Game.GetFormFromFile(0x09001D97, "Homemaker.esm"))
			DTSleep_BedList.AddForm(Game.GetFormFromFile(0x09001D98, "Homemaker.esm"))
		endIf
	endIf
	
	if (Game.IsPluginInstalled("WorkshopRearranged.esp"))
		Furniture dbBed = Game.GetFormFromFile(0x09009C94, "WorkshopRearranged.esp") as Furniture
		if (dbBed != None && !DTSleep_BedList.HasForm(dbBed as Form))
			modCount += 1
			AddToBedsList(dbBed, true)
			AddToBedsList(Game.GetFormFromFile(0x0903D5B8, "WorkshopRearranged.esp") as Furniture, true)
			AddToBedsList(Game.GetFormFromFile(0x0903D5BA, "WorkshopRearranged.esp") as Furniture, true)
			AddToBedsList(Game.GetFormFromFile(0x0903D5BC, "WorkshopRearranged.esp") as Furniture, true)
		endIf
	endIf
	
	string ccName = "cczsef04001-bhouse.esm"
	if (!Game.IsPluginInstalled(ccName))
		ccName = "cczsef04001-bhouse.esl"
	endIf
	if (Game.IsPluginInstalled(ccName))
		bedForm = Game.GetFormFromFile(0x09000A18, ccName)
		if (bedForm != None && !DTSleep_BedList.HasForm(bedForm))
			modCount += 1
			DTSleep_BedList.AddForm(bedForm)
			DTSleep_BedsBigList.AddForm(bedForm)
		endIf
		if (DTSleep_ActivChairs.GetValueInt() >= 2)
			bedForm = Game.GetFormFromFile(0x0900081D, ccName)
			if (bedForm != None && !DTSleep_IntimateChairsList.HasForm(bedForm))
				DTSleep_IntimateChairsList.AddForm(bedForm)
				DTSleep_IntimateChairsList.AddForm(Game.GetFormFromFile(0x0900081B, ccName))
				DTSleep_IntimateKitchenSeatList.AddForm(Game.GetFormFromFile(0x09000A7D, ccName))
				DTSleep_IntimateKitchenSeatList.AddForm(Game.GetFormFromFile(0x09000B3F, ccName))
				DTSleep_IntimateKitchenSeatList.AddForm(Game.GetFormFromFile(0x09000818, ccName))
				DTSleep_IntimateKitchenSeatList.AddForm(Game.GetFormFromFile(0x09000819, ccName))
			endIf
		endIf
	endIf
	
	ccName = "cctosfo4001-neosky.esm"
	if (!Game.IsPluginInstalled(ccName))
		ccName = "cctosfo4001-neosky.esl"
	endIf
	if (Game.IsPluginInstalled(ccName))
		bedForm = Game.GetFormFromFile(0x09000888, ccName)
		if (bedForm != None && !DTSleep_BedList.HasForm(bedForm))
			modCount += 1
			DTSleep_BedList.AddForm(bedForm)
			DTSleep_BedsBigList.AddForm(bedForm)
			bedForm = Game.GetFormFromFile(0x0900088A, ccName)
			DTSleep_BedList.AddForm(bedForm)
			DTSleep_BedsBigList.AddForm(bedForm)
		endIf
		if (DTSleep_ActivChairs.GetValueInt() >= 2)
			bedForm = Game.GetFormFromFile(0x09000889, ccName)
			if (bedForm != None && !DTSleep_IntimateChairsList.HasForm(bedForm))
				DTSleep_IntimateChairsList.AddForm(bedForm)
				DTSleep_IntimateKitchenSeatList.AddForm(Game.GetFormFromFile(0x0900088C, ccName))
				DTSleep_IntimateKitchenSeatList.AddForm(Game.GetFormFromFile(0x090008A9, ccName))
				DTSleep_IntimateCouchList.AddForm(Game.GetFormFromFile(0x09000884, ccName))
			endIf
		endIf
	endIf
	
	ccName = "cceejfo4002-nuka.esl"
	if (Game.IsPluginInstalled(ccName))
		bedForm = Game.GetFormFromFile(0x0900083A, ccName)
		if (bedForm != None && !DTSleep_BedList.HasForm(bedForm))
			modCount += 1
			DTSleep_BedList.AddForm(bedForm)
			DTSleep_BedsBigList.AddForm(bedForm)
			bedForm = Game.GetFormFromFile(0x09000839, ccName)
			DTSleep_BedList.AddForm(bedForm)
			DTSleep_BedsBigList.AddForm(bedForm)
			bedForm = Game.GetFormFromFile(0x0900083B, ccName)
			DTSleep_BedList.AddForm(bedForm)
			DTSleep_BedsBigList.AddForm(bedForm)
		endIf
		if (DTSleep_ActivChairs.GetValueInt() >= 2)
			Form chairForm = Game.GetFormFromFile(0x0900083E, ccName)
			if (chairForm != None && DTSleep_IntimateChairsList.HasForm(chairForm))
				DTSleep_IntimateChairsList.AddForm(chairForm)
				DTSleep_IntimateChairsList.AddForm(Game.GetFormFromFile(0x0900083F, ccName))
				DTSleep_IntimateChairsList.AddForm(Game.GetFormFromFile(0x09000840, ccName))
				DTSleep_IntimateChairsList.AddForm(Game.GetFormFromFile(0x09000833, ccName))
				DTSleep_IntimateCouchList.AddForm(Game.GetFormFromFile(0x0900083C, ccName))
				DTSleep_IntimateCouchList.AddForm(Game.GetFormFromFile(0x09000832, ccName))
				DTSleep_IntimateCouchList.AddForm(Game.GetFormFromFile(0x0900083D, ccName))
				DTSleep_IntimateCouchList.AddForm(Game.GetFormFromFile(0x09000841, ccName))
				DTSleep_IntimateKitchenSeatList.AddForm(Game.GetFormFromFile(0x09000837, ccName))
				DTSleep_IntimateKitchenSeatList.AddForm(Game.GetFormFromFile(0x09000836, ccName))
				DTSleep_IntimateKitchenSeatList.AddForm(Game.GetFormFromFile(0x09000838, ccName))
				DTSleep_IntimateBenchList.AddForm(Game.GetFormFromFile(0x09000834, ccName))
			endIf
		endIf
	endIf
			
	
	; Thirty-Yard Bunker - Eli Bunker
	locForm = IsPluginActive(0x09037056, "Eli_Bunker.esp")
	if (locForm != None)
		if (!DTSleep_PrivateLocationList.HasForm(locForm))
			modCount += 1
			DTSleep_PrivateLocationList.AddForm(locForm)
		endIf
	endIf
	
	; RRTV Goodneighbor Condo by RedRocketTV
	locForm = IsPluginActive(0x0900D2A1, "RRTV_GoodneighborCondo.esp")
	if (locForm != None)
		if (!DTSleep_PrivateLocationList.HasForm(locForm))
			modCount += 1
			DTSleep_PrivateLocationList.AddForm(locForm)
		endIf
	endIf
	
	; Femshepping's Cliff-side Home
	locForm = IsPluginActive(0x09011980, "FemsheppingsCliffsideHome.esp")
	if (locForm != None && !DTSleep_PrivateLocationList.HasForm(locForm))
		modCount += 1
		DTSleep_PrivateLocationList.AddForm(locForm)
	endIf
	
	; Torture Devices
	if (DTSleep_ActivChairs.GetValueInt() >= 2)
		Form pilloryForm = IsPluginActive(0x090098C7, "TortureDevices.esm")
		if (pilloryForm != None && !DTSleep_TortureDList.HasForm(pilloryForm))
			modCount += 1
			DTSleep_TortureDList.AddForm(pilloryForm)
			DTSleep_TortureDList.AddForm(Game.GetFormFromFile(0x090098CA, "TortureDevices.esm"))
			(DTSConditionals as DTSleep_Conditionals).TortureDPilloryKW = Game.GetFormFromFile(0x090098C8, "TortureDevices.esm") as Keyword
		endIf
	endIf
	
	; This is MY Bed  - v2.53
	string thisBedName = "This is MY Bed (Extended).esp"
	if (!Game.IsPluginInstalled(thisBedName))
		thisBedName = "This is MY Bed (Basic).esp"
		if (!Game.IsPluginInstalled(thisBedName))
			thisBedName = "This is MY Bed.esp"
		endIf
	endIf
	Form thisBedForm = IsPluginActive(0x0900080F, thisBedName)
	if (thisBedForm != None && !DTSleep_BedPrivateList.HasForm(thisBedForm))
		modCount += 1
		DTSleep_BedPrivateList.AddForm(thisBedForm)
		DTSleep_BedsBigList.AddForm(thisBedForm)
		DTSleep_BedPrivateList.AddForm(Game.GetFormFromFile(0x0900081E, thisBedName))
		DTSleep_BedsLimitedSpaceLst.AddForm(Game.GetFormFromFile(0x09000826, thisBedName))
		DTSleep_BedsLimitedSpaceLst.AddForm(Game.GetFormFromFile(0x09000827, thisBedName))
		thisBedForm = Game.GetFormFromFile(0x0900083D, thisBedName)
		if (thisBedForm != None)
			DTSleep_BedPrivateList.AddForm(thisBedForm)
			DTSleep_BedPrivateList.AddForm(Game.GetFormFromFile(0x09000842, thisBedName))
			thisBedForm = Game.GetFormFromFile(0x09000845, thisBedName)
			DTSleep_BedsBunkList.AddForm(thisBedForm)
			DTSleep_BedPrivateList.AddForm(thisBedForm)
			DTSleep_BedPrivateList.AddForm(Game.GetFormFromFile(0x09000847, thisBedName))
			DTSleep_BedPrivateList.AddForm(Game.GetFormFromFile(0x0900084F, thisBedName))
			thisBedForm = Game.GetFormFromFile(0x09000860, thisBedName)
			DTSleep_BedsBunkList.AddForm(thisBedForm)
			DTSleep_BedPrivateList.AddForm(thisBedForm)
			DTSleep_BedPrivateList.AddForm(Game.GetFormFromFile(0x09000865, thisBedName))
		endIf	
	endIf
	
	bool bedPrivate = true
	
	; BlackWidowBed
	string ladyKillerBedName = "MyBlackWidowBed.esp"
	
	if (!Game.IsPluginInstalled(ladyKillerBedName))
		ladyKillerBedName = "BlackWidowBed.esp"
		bedPrivate = false
	endIf
	Form blackWidBedForm = IsPluginActive(0x09000901, ladyKillerBedName)
	if (blackWidBedForm != None && !DTSleep_BedsBigDoubleList.HasForm(blackWidBedForm))
		modCount += 1
		DTSleep_BedsBigDoubleList.AddForm(blackWidBedForm)
		if (bedPrivate)
			DTSleep_BedPrivateList.AddForm(blackWidBedForm)
		else
			DTSleep_BedIntimateList.AddForm(blackWidBedForm)
			DTSleep_BedList.AddForm(blackWidBedForm)
		endIf
	endIf
	
	; LadyKillerBed
	ladyKillerBedName = "MyLadyKillerBed.esp"
	
	if (!Game.IsPluginInstalled(ladyKillerBedName))
		ladyKillerBedName = "LadyKillerBed.esp"
		bedPrivate = false
	endIf
	blackWidBedForm = IsPluginActive(0x09000901, ladyKillerBedName)
	if (blackWidBedForm != None && !DTSleep_BedsBigDoubleList.HasForm(blackWidBedForm))
		modCount += 1
		DTSleep_BedsBigDoubleList.AddForm(blackWidBedForm)
		if (bedPrivate)
			DTSleep_BedPrivateList.AddForm(blackWidBedForm)
		else
			DTSleep_BedIntimateList.AddForm(blackWidBedForm)
			DTSleep_BedList.AddForm(blackWidBedForm)
		endIf
	endIf
	
	; Cozy Beds
	bedPrivate = false
	string cozyBedName = "Cozy Beds.esp"
	if (!Game.IsPluginInstalled(cozyBedName))
		bedPrivate = true
		cozyBedName = "Cozy Beds - My Bed.esp"
	endIf
	Form cozyBedForm = IsPluginActive(0x09000800,cozyBedName)
	if (cozyBedForm != None && !DTSleep_BedsBigDoubleList.HasForm(cozyBedForm))
		modCount += 1
		DTSleep_BedsBigDoubleList.AddForm(cozyBedForm)
		if (bedPrivate)
			DTSleep_BedPrivateList.AddForm(cozyBedForm)
			cozyBedForm = Game.GetFormFromFile(0x09000803, cozyBedName)
			DTSleep_BedPrivateList.AddForm(cozyBedForm)
			DTSleep_BedsBigDoubleList.AddForm(cozyBedForm)
			cozyBedForm = Game.GetFormFromFile(0x09000804, cozyBedName)
			DTSleep_BedPrivateList.AddForm(cozyBedForm)
			DTSleep_BedsBigDoubleList.AddForm(cozyBedForm)
			cozyBedForm = Game.GetFormFromFile(0x09000807, cozyBedName)
			DTSleep_BedPrivateList.AddForm(cozyBedForm)
			DTSleep_BedsBigDoubleList.AddForm(cozyBedForm)
			cozyBedForm = Game.GetFormFromFile(0x09000824, cozyBedName)
			DTSleep_BedPrivateList.AddForm(cozyBedForm)
			DTSleep_BedsBigDoubleList.AddForm(cozyBedForm)
			cozyBedForm = Game.GetFormFromFile(0x09000825, cozyBedName)
			DTSleep_BedPrivateList.AddForm(cozyBedForm)
			DTSleep_BedsBigDoubleList.AddForm(cozyBedForm)
			cozyBedForm = Game.GetFormFromFile(0x09000826, cozyBedName)
			DTSleep_BedPrivateList.AddForm(cozyBedForm)
			DTSleep_BedsBigDoubleList.AddForm(cozyBedForm)
			cozyBedForm = Game.GetFormFromFile(0x09000827, cozyBedName)
			DTSleep_BedPrivateList.AddForm(cozyBedForm)
			DTSleep_BedsBigDoubleList.AddForm(cozyBedForm)
			cozyBedForm = Game.GetFormFromFile(0x09000828, cozyBedName)
			DTSleep_BedPrivateList.AddForm(cozyBedForm)
			DTSleep_BedsBigDoubleList.AddForm(cozyBedForm)
			cozyBedForm = Game.GetFormFromFile(0x09000829, cozyBedName)
			DTSleep_BedPrivateList.AddForm(cozyBedForm)
			DTSleep_BedsBigDoubleList.AddForm(cozyBedForm)
			cozyBedForm = Game.GetFormFromFile(0x0900082A, cozyBedName)
			DTSleep_BedPrivateList.AddForm(cozyBedForm)
			DTSleep_BedsBigDoubleList.AddForm(cozyBedForm)
			cozyBedForm = Game.GetFormFromFile(0x0900082B, cozyBedName)
			DTSleep_BedPrivateList.AddForm(cozyBedForm)
			DTSleep_BedsBigDoubleList.AddForm(cozyBedForm)
			cozyBedForm = Game.GetFormFromFile(0x0900082D, cozyBedName)
			DTSleep_BedPrivateList.AddForm(cozyBedForm)
			DTSleep_BedsBigDoubleList.AddForm(cozyBedForm)
			cozyBedForm = Game.GetFormFromFile(0x09000844, cozyBedName)
			DTSleep_BedPrivateList.AddForm(cozyBedForm)
			DTSleep_BedsBigDoubleList.AddForm(cozyBedForm)
			cozyBedForm = Game.GetFormFromFile(0x09000845, cozyBedName)
			DTSleep_BedPrivateList.AddForm(cozyBedForm)
			DTSleep_BedsBigDoubleList.AddForm(cozyBedForm)
			cozyBedForm = Game.GetFormFromFile(0x0900084A, cozyBedName)
			DTSleep_BedPrivateList.AddForm(cozyBedForm)
			DTSleep_BedsBigDoubleList.AddForm(cozyBedForm)
		else
			DTSleep_BedIntimateList.AddForm(cozyBedForm)
			DTSleep_BedList.AddForm(cozyBedForm)
			AddToBedsList(Game.GetFormFromFile(0x09000803, cozyBedName), true)
			AddToBedsList(Game.GetFormFromFile(0x09000804, cozyBedName), true)
			AddToBedsList(Game.GetFormFromFile(0x09000807, cozyBedName), true)
			AddToBedsList(Game.GetFormFromFile(0x09000809, cozyBedName), false)
			AddToBedsList(Game.GetFormFromFile(0x0900080B, cozyBedName), false)
			AddToBedsList(Game.GetFormFromFile(0x0900080C, cozyBedName), false)
			AddToBedsList(Game.GetFormFromFile(0x0900080F, cozyBedName), false)
			AddToBedsList(Game.GetFormFromFile(0x09000824, cozyBedName), true)
			AddToBedsList(Game.GetFormFromFile(0x09000825, cozyBedName), true)
			AddToBedsList(Game.GetFormFromFile(0x09000826, cozyBedName), true)
			AddToBedsList(Game.GetFormFromFile(0x09000827, cozyBedName), true)
			AddToBedsList(Game.GetFormFromFile(0x09000828, cozyBedName), true)
			AddToBedsList(Game.GetFormFromFile(0x09000829, cozyBedName), true)
			AddToBedsList(Game.GetFormFromFile(0x0900082A, cozyBedName), true)
			AddToBedsList(Game.GetFormFromFile(0x0900082B, cozyBedName), true)
			AddToBedsList(Game.GetFormFromFile(0x0900082D, cozyBedName), true)
			AddToBedsList(Game.GetFormFromFile(0x09000832, cozyBedName), false)
			AddToBedsList(Game.GetFormFromFile(0x09000833, cozyBedName), false)
			AddToBedsList(Game.GetFormFromFile(0x09000834, cozyBedName), false)
			AddToBedsList(Game.GetFormFromFile(0x09000835, cozyBedName), false)
			AddToBedsList(Game.GetFormFromFile(0x0900083A, cozyBedName), false)
			AddToBedsList(Game.GetFormFromFile(0x0900083B, cozyBedName), false)
			AddToBedsList(Game.GetFormFromFile(0x0900083C, cozyBedName), false)
			AddToBedsList(Game.GetFormFromFile(0x0900083D, cozyBedName), false)
			AddToBedsList(Game.GetFormFromFile(0x0900083E, cozyBedName), false)
			AddToBedsList(Game.GetFormFromFile(0x09000846, cozyBedName), false)
			AddToBedsList(Game.GetFormFromFile(0x09000847, cozyBedName), false)
			AddToBedsList(Game.GetFormFromFile(0x0900084B, cozyBedName), false)
			AddToBedsList(Game.GetFormFromFile(0x09000844, cozyBedName), true)
			AddToBedsList(Game.GetFormFromFile(0x09000845, cozyBedName), true)
			AddToBedsList(Game.GetFormFromFile(0x0900084A, cozyBedName), true)
		endIf
		
	endIf
	
	bedPrivate = false
	
	; CleanSettlement Beds
	string cleanBedName = "CleanSettlement Beds.esp"
	Form cleanBedForm = IsPluginActive(0x09000830, cleanBedName)
	if (cleanBedForm != None && !DTSleep_BedList.HasForm(cleanBedForm))
		modCount += 1
		AddToBedsList(cleanBedForm, false, DTSleep_BedsBigList)
		AddToBedsList(Game.GetFormFromFile(0x09000831, cleanBedForm), false)
		AddToBedsList(Game.GetFormFromFile(0x09000832, cleanBedForm), false)
		AddToBedsList(Game.GetFormFromFile(0x09000833, cleanBedForm), false)
		AddToBedsList(Game.GetFormFromFile(0x09000840, cleanBedForm), false, DTSleep_BedsBigList)
		AddToBedsList(Game.GetFormFromFile(0x09000842, cleanBedForm), false, DTSleep_BedsBigList)
		AddToBedsList(Game.GetFormFromFile(0x09000843, cleanBedForm), false, DTSleep_BedsBigList)
		AddToBedsList(Game.GetFormFromFile(0x09000845, cleanBedForm), false, DTSleep_BedsLimitedSpaceLst)
		AddToBedsList(Game.GetFormFromFile(0x09000846, cleanBedForm), false, DTSleep_BedsLimitedSpaceLst)
		AddToBedsList(Game.GetFormFromFile(0x09000847, cleanBedForm), false, DTSleep_BedsLimitedSpaceLst)
		AddToBedsList(Game.GetFormFromFile(0x09000848, cleanBedForm), false, DTSleep_BedsLimitedSpaceLst)
		AddToBedsList(Game.GetFormFromFile(0x09000849, cleanBedForm), false, DTSleep_BedsLimitedSpaceLst)
		AddToBedsList(Game.GetFormFromFile(0x0900084A, cleanBedForm), false, DTSleep_BedsLimitedSpaceLst)
		AddToBedsList(Game.GetFormFromFile(0x09000850, cleanBedForm), false, DTSleep_BedsLimitedSpaceLst)
		AddToBedsList(Game.GetFormFromFile(0x09000860, cleanBedForm), false)
		AddToBedsList(Game.GetFormFromFile(0x09000862, cleanBedForm), false)
		AddToBedsList(Game.GetFormFromFile(0x09000863, cleanBedForm), false)
		AddToBedsList(Game.GetFormFromFile(0x09000870, cleanBedForm), false)
		AddToBedsList(Game.GetFormFromFile(0x09000871, cleanBedForm), false)
		AddToBedsList(Game.GetFormFromFile(0x09000872, cleanBedForm), false)
		AddToBedsList(Game.GetFormFromFile(0x09000873, cleanBedForm), false)
		AddToBedsList(Game.GetFormFromFile(0x09000874, cleanBedForm), false)
	endIf
	
	; AES Renovated Furniture   - v2.60
	string aesFurnName = "AES_Renovated Furniture.esp"
	Form aesForm = IsPluginActive(0x090009A1, aesFurnName)				; Friffy_bed5 - double
	if (aesForm != None && !DTSleep_BedList.HasForm(aesForm))
		modCount += 1
		AddToBedsList(aesForm, false)
		AddToBedsList(Game.GetFormFromFile(0x090009A2, aesFurnName), true)
		AddToBedsList(Game.GetFormFromFile(0x090009A3, aesFurnName), true)
		AddToBedsList(Game.GetFormFromFile(0x090009A4, aesFurnName), true)
		AddToBedsList(Game.GetFormFromFile(0x090011F9, aesFurnName), true)
		AddToBedsList(Game.GetFormFromFile(0x090011FA, aesFurnName), true)
		AddToBedsList(Game.GetFormFromFile(0x090011FB, aesFurnName), true)
		AddToBedsList(Game.GetFormFromFile(0x09001264, aesFurnName), true)
		AddToBedsList(Game.GetFormFromFile(0x09001265, aesFurnName), true)
		AddToBedsList(Game.GetFormFromFile(0x09001266, aesFurnName), true)
		AddToBedsList(Game.GetFormFromFile(0x09001267, aesFurnName), true)
		AddToBedsList(Game.GetFormFromFile(0x09001268, aesFurnName), true)
		AddToBedsList(Game.GetFormFromFile(0x09001269, aesFurnName), true)
		AddToBedsList(Game.GetFormFromFile(0x0900126A, aesFurnName), true)
		AddToBedsList(Game.GetFormFromFile(0x0900126B, aesFurnName), true)
		AddToBedsList(Game.GetFormFromFile(0x0900126C, aesFurnName), true)
		AddToBedsList(Game.GetFormFromFile(0x0900126D, aesFurnName), true)
		AddToBedsList(Game.GetFormFromFile(0x0900126E, aesFurnName), true)
		
		DTSleep_IntimateKitchenSeatList.AddForm(Game.GetFormFromFile(0x0900081C, aesFurnName))
		aesForm = Game.GetFormFromFile(0x0900081D, aesFurnName)
		DTSleep_IntimateChairsList.AddForm(aesForm)
		DTSleep_IntimateChairsList.AddForm(Game.GetFormFromFile(0x0900081E, aesFurnName))

		DTSleep_IntimateChairHighList.AddForm(Game.GetFormFromFile(0x09000832, aesFurnName))		;federalist
		DTSleep_IntimateCouchFedList.AddForm(Game.GetFormFromFile(0x09000833, aesFurnName))
		DTSleep_IntimateCouchFedList.AddForm(Game.GetFormFromFile(0x09000838, aesFurnName))
		DTSleep_IntimateChairHighList.AddForm(Game.GetFormFromFile(0x09000839, aesFurnName))
		DTSleep_IntimateCouchFedList.AddForm(Game.GetFormFromFile(0x09000847, aesFurnName))
		DTSleep_IntimateChairHighList.AddForm(Game.GetFormFromFile(0x09000848, aesFurnName))
		DTSleep_IntimateCouchFedList.AddForm(Game.GetFormFromFile(0x09000849, aesFurnName))
		DTSleep_IntimateChairHighList.AddForm(Game.GetFormFromFile(0x0900084A, aesFurnName))
		DTSleep_IntimateChairsList.AddForm(Game.GetFormFromFile(0x09000852, aesFurnName))
		DTSleep_IntimateChairsList.AddForm(Game.GetFormFromFile(0x09000853, aesFurnName))
		DTSleep_IntimateChairsList.AddForm(Game.GetFormFromFile(0x09000854, aesFurnName))
		DTSleep_IntimateChairOttomanList.AddForm(Game.GetFormFromFile(0x09000869, aesFurnName))
		DTSleep_IntimateChairOttomanList.AddForm(Game.GetFormFromFile(0x0900086C, aesFurnName))
		DTSleep_IntimateChairOttomanList.AddForm(Game.GetFormFromFile(0x0900086F, aesFurnName))
		DTSleep_IntimateChairsList.AddForm(Game.GetFormFromFile(0x09000981, aesFurnName))
		DTSleep_IntimateCouchList.AddForm(Game.GetFormFromFile(0x09000982, aesFurnName))
		DTSleep_IntimateChairsList.AddForm(Game.GetFormFromFile(0x09000988, aesFurnName))
		DTSleep_IntimateChairsList.AddForm(Game.GetFormFromFile(0x09000989, aesFurnName))
		DTSleep_IntimateChairsList.AddForm(Game.GetFormFromFile(0x0900098A, aesFurnName))
		DTSleep_IntimateChairsList.AddForm(Game.GetFormFromFile(0x0900098B, aesFurnName))
		DTSleep_IntimateChairsList.AddForm(Game.GetFormFromFile(0x0900098C, aesFurnName))
		DTSleep_IntimateChairHighList.AddForm(Game.GetFormFromFile(0x09001367, aesFurnName))
		DTSleep_IntimateCouchFedList.AddForm(Game.GetFormFromFile(0x09001368, aesFurnName))
	endIf
	
	; Functional Displays  --added v2.62
	Form mannequinForm = IsPluginActive(0x09000852, "FunctionalDisplays.esp")
	if (mannequinForm != None && !DTSleep_NotHumanList.HasForm(mannequinForm))
		modCount += 1
		
		DTSleep_NotHumanList.AddForm(mannequinForm)
		DTSleep_NotHumanList.AddForm(Game.GetFormFromFile(0x090008C6, aesFurnName))
	endIf
	
	; BasementLiving handled in regular section
	
	Debug.Trace(myScriptName + " ================= End Custom Home/Location check ====================")
	
	return modCount
endFunction

int Function CheckUniquePlayerFollowers()
	int modCount
	
	if (DTSleep_AdultContentOn.GetValue() < 1.0)				; v2.61 - allow 1.0 although should not matter
		return 0
	endIf
	
	; male player exist flag for Leito-gun
	; female followers for nude-suit
	; male followers for nude-suit and exists flag for Leito-gun
	; female player tracking not needed
	
	Debug.Trace(myScriptName + " =====================================================================")
	Debug.Trace(myScriptName + "------- begin Unique Player and Followers check ------  ")
	
	bool maleFollowers = false
	bool femaleFollowers = false
	bool hasFemFollowerESP = false	
	bool hasMaleFollowerESP = false
	
	; check male-player plugins
	
	string upName = "UniqueMalePlayer.esp"
	
	Armor skinArmor = IsPluginActive(0x16000833, upName) as Armor
	
	; old 
	if (skinArmor == None)
		upName = "UniquePlayer.esp"
		skinArmor = IsPluginActive(0x16000D64, upName) as Armor
	endIf
	
	if (skinArmor == None)
		upName = "UniqueMalePlayerAndFollowers.esp"
		skinArmor = IsPluginActive(0x16000833, upName) as Armor
		if (skinArmor != None)
			maleFollowers = true 
			femaleFollowers = true
		endIf
	endIf
	if (skinArmor == None)
		upName = "UniqueMalePlayerAndFollowersDLC.esp"
		skinArmor = IsPluginActive(0x16000833, upName) as Armor
		if (skinArmor != None)
			maleFollowers = true 
			femaleFollowers = true
		endIf
	endIf
	if (skinArmor == None)
		upName = "UniqueMalePlayerAndFollowersDLCNoHancock.esp"
		skinArmor = IsPluginActive(0x16000833, upName) as Armor
		if (skinArmor != None)
			maleFollowers = true 
			femaleFollowers = true
		endIf
	endIf
	if (skinArmor == None)
		upName = "UniqueMalePlayerAndFollowersNoHancock.esp"
		skinArmor = IsPluginActive(0x16000833, upName) as Armor
		if (skinArmor != None)
			maleFollowers = true 
			femaleFollowers = true
		endIf
	endIf

	
	if (skinArmor != None)
		(DTSConditionals as DTSleep_Conditionals).IsUniquePlayerMaleActive = true
	else
		(DTSConditionals as DTSleep_Conditionals).IsUniquePlayerMaleActive = false
	endIf
	
	; v2.61 removed early return
	
	if (!femaleFollowers)
		skinArmor = None   ; reset 
		; check female player and follower plugins
	endIf
	
	if (skinArmor == None)
		upName = "UniqueFemalePlayerAndFollowersNoHancock.esp"
		skinArmor = IsPluginActive(0x16000833, upName) as Armor
		if (skinArmor != None)
			maleFollowers = true 
			femaleFollowers = true
		endIf
	endIf
	if (skinArmor == None)
		upName = "UniqueFemalePlayerAndFollowers.esp"
		skinArmor = IsPluginActive(0x16000833, upName) as Armor
		if (skinArmor != None)
			maleFollowers = true 
			femaleFollowers = true
		endIf
	endIf
	if (skinArmor == None)
		upName = "UniqueFemalePlayerAndFollowersDLC.esp"
		skinArmor = IsPluginActive(0x16000833, upName) as Armor
		if (skinArmor != None)
			maleFollowers = true 
			femaleFollowers = true
		endIf
	endIf
	if (skinArmor == None)
		upName = "UniqueFemalePlayerAndFollowersDLCNoHancock.esp"
		skinArmor = IsPluginActive(0x16000833, upName) as Armor
		if (skinArmor != None)
			maleFollowers = true 
			femaleFollowers = true
		endIf
	endIf
	
	if (!femaleFollowers)
		skinArmor = IsPluginActive(0x16000805, "UniqueFemaleFollowers.esp") as Armor
		if (skinArmor != None)
			femaleFollowers = true
			hasFemFollowerESP = true
		endIf
	endIf
	if (!maleFollowers)
		skinArmor = IsPluginActive(0x1600080A, "UniqueMaleFollowers.esp") as Armor
		if (skinArmor != None)
			maleFollowers = true
			hasMaleFollowerESP = true
		endIf
	endIf
	
	if (femaleFollowers || maleFollowers)					; v2.61 fix for when female but no male
	
		if (maleFollowers)
			if (hasMaleFollowerESP)
				upName = "UniqueMaleFollowers.esp"
			endIf
			(DTSConditionals as DTSleep_Conditionals).IsUniqueFollowerMaleActive = true
			skinArmor = Game.GetFormFromFile(0x1600080A, upName) as Armor   ; Danse
			
			if (skinArmor != None && !DTSleep_ModCompanionBodiesLst.HasForm(skinArmor))
				DTSleep_ModCompanionBodiesLst.AddForm(skinArmor)
				(DTSConditionals as DTSleep_Conditionals).ModUniqueFollowerMaleBodyBaseIndex = DTSleep_ModCompanionBodiesLst.GetSize() - 1
				skinArmor = Game.GetFormFromFile(0x16000855, upName) as Armor  ; Gage
				if (skinArmor)
					DTSleep_ModCompanionBodiesLst.AddForm(skinArmor)
				else
					DTSleep_ModCompanionBodiesLst.AddForm(DTSleep_NudeSuit)
				endIf
				DTSleep_ModCompanionBodiesLst.AddForm(Game.GetFormFromFile(0x1600080B, upName))   ; Garvey
				skinArmor = Game.GetFormFromFile(0x1600081A, upName) as Armor  ; Hancock
				if (skinArmor)
					DTSleep_ModCompanionBodiesLst.AddForm(skinArmor)
				else
					DTSleep_ModCompanionBodiesLst.AddForm(DTSleep_NudeSuit)
				endIf
				DTSleep_ModCompanionBodiesLst.AddForm(Game.GetFormFromFile(0x16000828, upName))   ; MacCready
				
				int size = DTSleep_ModCompanionBodiesLst.GetSize() - (DTSConditionals as DTSleep_Conditionals).ModUniqueFollowerMaleBodyBaseIndex
				(DTSConditionals as DTSleep_Conditionals).ModUniqueFollowerMaleBodyLength = size
			endIf
		else
			(DTSConditionals as DTSleep_Conditionals).IsUniqueFollowerMaleActive = false
		endIf
		
		if (femaleFollowers)
			if (hasFemFollowerESP)
				upName = "UniqueFemaleFollowers.esp"
			endIf
			(DTSConditionals as DTSleep_Conditionals).IsUniqueFollowerFemActive = true
			skinArmor = Game.GetFormFromFile(0x16000805, upName) as Armor  ; Cait
			
			if (skinArmor != None && !DTSleep_ModCompanionBodiesLst.HasForm(skinArmor))
				
				(DTSConditionals as DTSleep_Conditionals).ModUniqueFollowerFemBodyBaseIndex = DTSleep_ModCompanionBodiesLst.GetSize()
				DTSleep_ModCompanionBodiesLst.AddForm(skinArmor)
				
				DTSleep_ModCompanionBodiesLst.AddForm(Game.GetFormFromFile(0x16000806, upName))  ;Curie
				DTSleep_ModCompanionBodiesLst.AddForm(Game.GetFormFromFile(0x16000804, upName))  ;Piper
			
				int size = DTSleep_ModCompanionBodiesLst.GetSize() - (DTSConditionals as DTSleep_Conditionals).ModUniqueFollowerFemBodyBaseIndex
				(DTSConditionals as DTSleep_Conditionals).ModUniqueFollowerFemBodyLength = size
			endIf
		else
			(DTSConditionals as DTSleep_Conditionals).IsUniqueFollowerFemActive = false
		endIf
	endIf
	
	
	
	Debug.Trace(myScriptName + " ================= End Unique Player and Followers check ====================")
	
	return modCount
endFunction

int Function CheckCustomArmorsAndBackpacks()
	
	int modCount = 0

	Debug.Trace(myScriptName + " =====================================================================")
	Debug.Trace(myScriptName + "------- begin Custom Armor and Backpack check ------  ")
	Debug.Trace(myScriptName + "  **** only checked on first load, updates, and by request  *****")
	
	Armor jewelry = IsPluginActive(0x11100000, "Elegant Hardware.esp") as Armor
	if (jewelry != None)
		if (!DTSleep_ArmorNecklaceSlot50List.HasForm(jewelry))
			DTSleep_ArmorNecklaceSlot50List.AddForm(jewelry)
			DTSleep_ArmorChokerList.AddForm(Game.GetFormFromFile(0x11100001, "Elegant Hardware.esp"))
			DTSleep_ArmorChokerList.AddForm(Game.GetFormFromFile(0x11100059, "Elegant Hardware.esp"))
		endIf
		Form jewelForm = Game.GetFormFromFile(0x110009B5, "Elegant Hardware.esp")	; belly ring
		if (jewelForm != None && !DTSleep_ArmorJewelry58List.HasForm(jewelForm))
			modCount += 1
			DTSleep_ArmorJewelry58List.AddForm(jewelForm)
			DTSleep_ArmorSlot58List.AddForm(jewelForm)
		endIf
	endIf
	
	; DX FetishFashion   - v2.78
	jewelry = IsPluginActive(0x11039F0B, "DX_FetishFashion_Part1.esp") as Armor			; heart patches
	if (jewelry != None)
		if (!DTSleep_ArmorJewelry58List.HasForm(jewelry))
			modCount += 1
			DTSleep_ArmorJewelry58List.AddForm(jewelry as Form)
			DTSleep_ArmorSlot58List.AddForm(jewelry as Form)
			Form jewelForm = Game.GetFormFromFile(0x11039F0E, "DX_FetishFashion_Part1.esp")  ; ball piercings
			DTSleep_ArmorJewelry58List.AddForm(jewelForm)
			DTSleep_ArmorSlot58List.AddForm(jewelForm)
			jewelForm = Game.GetFormFromFile(0x11039F11, "DX_FetishFashion_Part1.esp")  ; ring piercings
			DTSleep_ArmorJewelry58List.AddForm(jewelForm)
			DTSleep_ArmorSlot58List.AddForm(jewelForm)
			jewelForm = Game.GetFormFromFile(0x11039F08, "DX_FetishFashion_Part1.esp")  ; X patches
			DTSleep_ArmorJewelry58List.AddForm(jewelForm)
			DTSleep_ArmorSlot58List.AddForm(jewelForm)
			jewelForm = Game.GetFormFromFile(0x1103C514, "DX_FetishFashion_Part1.esp")  ; choker
			DTSleep_ArmorNecklaceSlot50List.AddForm(jewelForm)
			DTSleep_ArmorChokerList.AddForm(jewelForm)
			
			; bottom straps stretch and clip during animations -- comment out to undress by default
			;DTSleep_ArmorSlot55List.AddForm(Game.GetFormFromFile(0x11039EFF, "DX_FetishFashion_Part1.esp")) ; bottom straps
			; set female-only in case marked as intimate outfit
			DTSleep_IntimateAttireFemaleOnlyList.AddForm(Game.GetFormFromFile(0x11039EFF, "DX_FetishFashion_Part1.esp"))
			
			; extra sex appeal outfits
			DTSleep_SexyClothesFList.AddForm(Game.GetFormFromFile(0x1103C517, "DX_FetishFashion_Part1.esp"))
			DTSleep_SexyClothesFList.AddForm(Game.GetFormFromFile(0x1103882B, "DX_FetishFashion_Part1.esp"))
			DTSleep_SexyClothesFList.AddForm(Game.GetFormFromFile(0x11035A87, "DX_FetishFashion_Part1.esp"))
			DTSleep_SexyClothesFList.AddForm(Game.GetFormFromFile(0x11037159, "DX_FetishFashion_Part1.esp"))
			DTSleep_SexyClothesFList.AddForm(Game.GetFormFromFile(0x110378F6, "DX_FetishFashion_Part1.esp"))
			DTSleep_SexyClothesFList.AddForm(Game.GetFormFromFile(0x11039EFC, "DX_FetishFashion_Part1.esp"))
		endIf
	endIf
	
	; DX Pornstar Fashion - v2.79
	jewelry = IsPluginActive(0x11023F6D, "DX_Pornstar_Fashion.esp") as Armor			; earrings
	if (jewelry != None)
		if (!DTSleep_ArmorSlot55List.HasForm(jewelry))
			modCount += 1
			DTSleep_ArmorSlot55List.AddForm(jewelry as Form)
			Form jewelForm = Game.GetFormFromFile(0x11024709, "DX_Pornstar_Fashion.esp")  ; collar
			DTSleep_ArmorNecklaceSlot50List.AddForm(jewelForm)
			DTSleep_ArmorChokerList.AddForm(jewelForm)
			; purse like backpack
			DTSleep_ArmorBackPacksList.AddForm(Game.GetFormFromFile(0x11024EA5, "DX_Pornstar_Fashion.esp"))
		endIf
	endIf
	
	; DX Overboss
	Armor extraArmor = IsPluginActive(0x03000936, "DX_Overboss_Outfit.esp") as Armor
	if (extraArmor != None)
		DTSleep_ExtraArmorsEnabled.SetValue(1.0)
		if (!DTSleep_ArmorJacketsClothingList.HasForm(extraArmor))
			modCount += 1
			DTSleep_ArmorJacketsClothingList.AddForm(extraArmor)
		endIf	
	endIf
	
	; DX Harley Quinn
	extraArmor = IsPluginActive(0x03000936, "DX_Harley_Quinn_Outfit.esp") as Armor
	if (extraArmor != None)
		DTSleep_ExtraArmorsEnabled.SetValue(1.0)
		if (!DTSleep_ArmorJacketsClothingList.HasForm(extraArmor))
			modCount += 1
			DTSleep_ArmorJacketsClothingList.AddForm(extraArmor)
		endIf
	endIf
	
	; CROSS old Brotherhood under armor 
	if ((DTSConditionals as DTSleep_Conditionals).IsCrossBosUniActive == false)
		extraArmor = IsPluginActive(0x080009BC, "CROSS_Uni_BosUniform.esp") as Armor  ; boots
		if (extraArmor)
			DTSleep_ExtraArmorsEnabled.SetValue(1.0)
			(DTSConditionals as DTSleep_Conditionals).IsCrossBosUniActive = true
			if (!DTSleep_ArmorExtraClothingList.HasForm(extraArmor))
				modCount += 1
				DTSleep_ArmorExtraClothingList.AddForm(extraArmor)
				DTSleep_ArmorExtraClothingList.AddForm(Game.GetFormFromFile(0x080009B8, "CROSS_Uni_BosUniform.esp") as Armor)
			endIf
		endIf
	endIf
	
	; CROSS BrotherhoodRecon
	string crossPluginName = "CROSS_BrotherhoodRecon.esp"
	extraArmor = IsPluginActive(0x0900081F, crossPluginName) as Armor
	
	if (extraArmor == None)
		crossPluginName = "CROSS_BrotherhoodRecon.esl"
		extraArmor = IsPluginActive(0x0900081F, crossPluginName) as Armor
	endIf
	
	if (extraArmor)
		DTSleep_ExtraArmorsEnabled.SetValue(1.0)
		if (!DTSleep_ArmorJacketsClothingList.HasForm(extraArmor))
			modCount += 1
			DTSleep_ArmorJacketsClothingList.AddForm(extraArmor)
			DTSleep_ArmorJacketsClothingList.AddForm(Game.GetFormFromFile(0x09000821, crossPluginName))
			DTSleep_ArmorHatHelmList.AddForm(Game.GetFormFromFile(0x0900081D, crossPluginName))
			DTSleep_ArmorHatHelmList.AddForm(Game.GetFormFromFile(0x09000820, crossPluginName))
			DTSleep_ArmorMaskList.AddForm(Game.GetFormFromFile(0x090008F7, crossPluginName))
			DTSleep_ArmorGlassesList.AddForm(Game.GetFormFromFile(0x09000827, crossPluginName))
		endIf
	endIf
	
	; CROSS MojaveManhunter
	crossPluginName = "CROSS_MojaveManhunter.esp"
	extraArmor = IsPluginActive(0x0900085B, crossPluginName) as Armor   ; duster
	
	if (extraArmor == None)
		crossPluginName = "CROSS_MojaveManhunter.esl"
		extraArmor = IsPluginActive(0x0900085B, crossPluginName) as Armor
	endIf
	
	if (extraArmor != None)
		if (DTSleep_ExtraArmorsEnabled.GetValue() < 1.0)
			DTSleep_ExtraArmorsEnabled.SetValue(1.0)
		endIf
		
		if (!DTSleep_ArmorJacketsClothingList.HasForm(extraArmor))
			modCount += 1
			DTSleep_ArmorJacketsClothingList.AddForm(extraArmor)
			DTSleep_ArmorHatHelmList.AddForm(Game.GetFormFromFile(0x09000847, crossPluginName))
			DTSleep_ArmorMaskList.AddForm(Game.GetFormFromFile(0x0900085A, crossPluginName))
		endIf
		
		extraArmor = Game.GetFormFromFile(0x0900085C, crossPluginName) as Armor
		if (extraArmor != None && !DTSleep_ArmorTorsoList.HasForm(extraArmor))
			;Debug.Trace(myScriptName + " adding Mojave Vest to torso list")
			DTSleep_ArmorTorsoList.AddForm(extraArmor)
		endIf
	endIf
	
	; CROSS Institute Expedition
	crossPluginName = "CROSS_InstituteExpeditionarySuit.esp"
	extraArmor = IsPluginActive(0x09000848, crossPluginName) as Armor   ; duster
	
	if (extraArmor == None)
		crossPluginName = "CROSS_InstituteExpeditionarySuit.esl"
		extraArmor = IsPluginActive(0x09000848, crossPluginName) as Armor
	endIf
	
	if (extraArmor != None)
		if (DTSleep_ExtraArmorsEnabled.GetValue() < 1.0)
			DTSleep_ExtraArmorsEnabled.SetValue(1.0)
		endIf
		
		if (!DTSleep_ArmorMaskList.HasForm(extraArmor))
			modCount += 1
			DTSleep_ArmorMaskList.AddForm(extraArmor)
			DTSleep_ArmorHatHelmList.AddForm(Game.GetFormFromFile(0x09000847, crossPluginName))
			
		endIf
	endIf
	
	crossPluginName = "CROSS_2077.esp"
	extraArmor = IsPluginActive(0x0900085B, crossPluginName) as Armor
	
	if (extraArmor == None)
		crossPluginName = "CROSS_2077.esl"
		extraArmor = IsPluginActive(0x0900085B, crossPluginName) as Armor
	endIf
	
	if (extraArmor != None)
		if (DTSleep_ExtraArmorsEnabled.GetValue() < 1.0)
			DTSleep_ExtraArmorsEnabled.SetValue(1.0)
		endIf
		
		if (!DTSleep_ArmorJacketsClothingList.HasForm(extraArmor))
			modCount += 1
			DTSleep_ArmorJacketsClothingList.AddForm(extraArmor)
			; leaving out headset for player choice
			;DTSleep_ArmorMaskList.AddForm(Game.GetFormFromFile(0x0900085A, crossPluginName))
		endIf
	endIf
	
	; CROSS Children of Atom
	
	crossPluginName = "CROSS_CoA.esl"
	extraArmor = IsPluginActive(0x0900085B, crossPluginName) as Armor			; overcoat
	
	if (extraArmor == None)
		crossPluginName = "CROSS_CoA.esp"
		extraArmor = IsPluginActive(0x0900085B, crossPluginName) as Armor
	endIf
	
	if (extraArmor != None)
		if (DTSleep_ExtraArmorsEnabled.GetValue() < 1.0)
			DTSleep_ExtraArmorsEnabled.SetValue(1.0)
		endIf
		
		if (!DTSleep_ArmorJacketsClothingList.HasForm(extraArmor))
			modCount += 1
			DTSleep_ArmorJacketsClothingList.AddForm(extraArmor)
			
			DTSleep_ArmorMaskList.AddForm(Game.GetFormFromFile(0x09000874, crossPluginName))
			DTSleep_ArmorMaskList.AddForm(Game.GetFormFromFile(0x0900085A, crossPluginName))
			DTSleep_ArmorHatHelmList.AddForm(Game.GetFormFromFile(0x09000847, crossPluginName))
		endIf
		
		extraArmor = Game.GetFormFromFile(0x0900085C, crossPluginName) as Armor
		if (extraArmor != None && !DTSleep_ArmorTorsoList.HasForm(extraArmor))
			DTSleep_ArmorTorsoList.AddForm(extraArmor)
			DTSleep_ArmorArmLeftList.AddForm(Game.GetFormFromFile(0x0900086B, crossPluginName))
			DTSleep_ArmorArmRightList.AddForm(Game.GetFormFromFile(0x0900086C, crossPluginName))
			DTSleep_ArmorLegLeftList.AddForm(Game.GetFormFromFile(0x0900086D, crossPluginName))
			DTSleep_ArmorLegRightList.AddForm(Game.GetFormFromFile(0x09000873, crossPluginName))
		endIf
	endIf
	
	; CROSS Courser
	crossPluginName = "CROSS_CourserStrigidae.esl"
	extraArmor = IsPluginActive(0x0900083F, crossPluginName) as Armor
	
	if (extraArmor == None)
		crossPluginName = "CROSS_CourserStrigidae.esp"
		extraArmor = IsPluginActive(0x0900083F, crossPluginName) as Armor
	endIf
	
	if (extraArmor != None)
		if (DTSleep_ExtraArmorsEnabled.GetValue() < 1.0)
			DTSleep_ExtraArmorsEnabled.SetValue(1.0)
		endIf
		if (!DTSleep_ArmorHatHelmList.HasForm(extraArmor as Form))
			modCount += 1
			DTSleep_ArmorHatHelmList.AddForm(extraArmor as Form)
			DTSleep_ArmorHatHelmList.AddForm(Game.GetFormFromFile(0x09000837, crossPluginName))
			DTSleep_ArmorJacketsClothingList.AddForm(Game.GetFormFromFile(0x09000836, crossPluginName))
			DTSleep_ArmorJacketsClothingList.AddForm(Game.GetFormFromFile(0x0900083E, crossPluginName))
		endIf
	endIf
	
	; CROSS Wasteland Ronin
	crossPluginName = "CROSS_Wasteland_Ronin.esl"
	extraArmor = IsPluginActive(0x09000847, crossPluginName) as Armor
	
	if (extraArmor == None)
		crossPluginName = "CROSS_Wasteland_Ronin.esp"
		extraArmor = IsPluginActive(0x09000847, crossPluginName) as Armor
	endIf
	
	if (extraArmor != None)
		if (DTSleep_ExtraArmorsEnabled.GetValue() < 1.0)
			DTSleep_ExtraArmorsEnabled.SetValue(1.0)
		endIf
		if (!DTSleep_ArmorHatHelmList.HasForm(extraArmor as Form))
			modCount += 1
			DTSleep_ArmorHatHelmList.AddForm(extraArmor as Form)
			DTSleep_ArmorTorsoList.AddForm(Game.GetFormFromFile(0x0900085C, crossPluginName))
			DTSleep_ArmorLegLeftList.AddForm(Game.GetFormFromFile(0x0900086D, crossPluginName))
			DTSleep_ArmorLegRightList.AddForm(Game.GetFormFromFile(0x09000873, crossPluginName))
			DTSleep_ArmorArmLeftList.AddForm(Game.GetFormFromFile(0x0900086B, crossPluginName))
			DTSleep_ArmorArmRightList.AddForm(Game.GetFormFromFile(0x0900086C, crossPluginName))
		endIf
	endIf
	
	; CROSS Flightsuit
	crossPluginName = "CROSS_VertibirdFlightsuit.esl"
	extraArmor = IsPluginActive(0x09000847, crossPluginName) as Armor
	
	if (extraArmor != None)
		if (DTSleep_ExtraArmorsEnabled.GetValue() < 1.0)
			DTSleep_ExtraArmorsEnabled.SetValue(1.0)
		endIf
		if (!DTSleep_ArmorHatHelmList.HasForm(extraArmor as Form))
			modCount += 1
			DTSleep_ArmorHatHelmList.AddForm(extraArmor as Form)
			DTSleep_ArmorJacketsClothingList.AddForm(Game.GetFormFromFile(0x0900085C, crossPluginName))
		endIf
	endIf
	
	; DX Banshee
	
	extraArmor = IsPluginActive(0x09006BEC, "DX_Banshee_Recon_Armor.esp") as Armor
	if (extraArmor != None)
		if (!DTSleep_ArmorAllExceptionList.HasForm(extraArmor))
			modCount += 1
			DTSleep_ArmorAllExceptionList.AddForm(extraArmor)
		endIf
	endIf
	
	; MyMinuteMen
	string myminutemenPlugin = "My_Minutemen.esp"
	if (!Game.IsPluginInstalled(myminutemenPlugin))
		myminutemenPlugin = "W.A.T.Minutemen.esp"
	endIf
	extraArmor = IsPluginActive(0x11000801, myminutemenPlugin) as Armor
	if (extraArmor != None)
		if (!DTSleep_ArmorTorsoList.HasForm(extraArmor))
			modCount += 1
			DTSleep_ArmorTorsoList.AddForm(extraArmor)
			DTSleep_ArmorLegRightList.AddForm(Game.GetFormFromFile(0x11000802, myminutemenPlugin))
			DTSleep_ArmorArmRightList.AddForm(Game.GetFormFromFile(0x11000804, myminutemenPlugin))
			DTSleep_ArmorArmLeftList.AddForm(Game.GetFormFromFile(0x11000805, myminutemenPlugin))
			DTSleep_ArmorLegLeftList.AddForm(Game.GetFormFromFile(0x1100082E, myminutemenPlugin))
		endIf
	endIf
	
	
	; Sporty Underwear
	string sportyPlugin = "Sporty Underwear.esp"
	if (!Game.IsPluginInstalled(sportyPlugin))
		sportyPlugin = "Sporty Underwear (AWKCR).esp"
	endIf
	
	extraArmor = IsPluginActive(0x01100006, sportyPlugin) as Armor
	
	if (extraArmor != None)
		if (DTSleep_ExtraArmorsEnabled.GetValue() < 1.0)
			DTSleep_ExtraArmorsEnabled.SetValue(1.0)
		endIf
		if (!DTSleep_ArmorSlotFXList.HasForm(extraArmor))
			modCount += 1
			DTSleep_ArmorSlotFXList.AddForm(extraArmor)
			extraArmor = Game.GetFormFromFile(0x01100007, sportyPlugin) as Armor
			DTSleep_ArmorSlotFXList.AddForm(extraArmor)
			extraArmor = Game.GetFormFromFile(0x01100008, sportyPlugin) as Armor
			DTSleep_ArmorSlotFXList.AddForm(extraArmor)
			extraArmor = Game.GetFormFromFile(0x01100009, sportyPlugin) as Armor
			DTSleep_ArmorSlotFXList.AddForm(extraArmor)
			extraArmor = Game.GetFormFromFile(0x0110000A, sportyPlugin) as Armor
			DTSleep_ArmorSlotFXList.AddForm(extraArmor)
		endIf
		extraArmor = Game.GetFormFromFile(0x0110000B, sportyPlugin) as Armor
		if (!DTSleep_ArmorSlot58List.HasForm(extraArmor))
			DTSleep_ArmorSlot58List.AddForm(extraArmor)
			DTSleep_SleepAttireFemale.AddForm(extraArmor)
			extraArmor = Game.GetFormFromFile(0x0110000C, sportyPlugin) as Armor
			DTSleep_ArmorSlot58List.AddForm(extraArmor)
			DTSleep_SleepAttireFemale.AddForm(extraArmor)
			extraArmor = Game.GetFormFromFile(0x0110000D, sportyPlugin) as Armor
			DTSleep_ArmorSlot58List.AddForm(extraArmor)
			DTSleep_SleepAttireFemale.AddForm(extraArmor)
			extraArmor = Game.GetFormFromFile(0x0110000E, sportyPlugin) as Armor
			DTSleep_ArmorSlot58List.AddForm(extraArmor)
			DTSleep_SleepAttireFemale.AddForm(extraArmor)
			extraArmor = Game.GetFormFromFile(0x0110000F, sportyPlugin) as Armor
			DTSleep_ArmorSlot58List.AddForm(extraArmor)
			DTSleep_SleepAttireFemale.AddForm(extraArmor)
		endIf
		extraArmor = Game.GetFormFromFile(0x01100001, sportyPlugin) as Armor
		if (!DTSleep_SleepAttireFemale.HasForm(extraArmor))
			DTSleep_SleepAttireFemale.AddForm(extraArmor)
			DTSleep_SleepAttireFemale.AddForm(Game.GetFormFromFile(0x01100002, sportyPlugin) as Armor)
			DTSleep_SleepAttireFemale.AddForm(Game.GetFormFromFile(0x01100003, sportyPlugin) as Armor)
			DTSleep_SleepAttireFemale.AddForm(Game.GetFormFromFile(0x01100004, sportyPlugin) as Armor)
			DTSleep_SleepAttireFemale.AddForm(Game.GetFormFromFile(0x01100005, sportyPlugin) as Armor)
		endIf
	endIf
	
	; Tera Nurse
	
	string teraName = "TERANurseUniform.esp"
	if (!Game.IsPluginInstalled(teraName))
		teraName = "TERANurseUniform.esl"
	endIf
	extraArmor = IsPluginActive(0x01100805, teraName) as Armor
	
	if (extraArmor != None)
		if (DTSleep_ExtraArmorsEnabled.GetValue() < 1.0)
			DTSleep_ExtraArmorsEnabled.SetValue(1.0)
		endIf
		if (!DTSleep_ArmorHatHelmList.HasForm(extraArmor))
			modCount += 1
			DTSleep_ArmorHatHelmList.AddForm(extraArmor)
			extraArmor = Game.GetFormFromFile(0x01100804, teraName) as Armor
			DTSleep_SleepAttireFemale.AddForm(extraArmor)
			DTSleep_ArmorSlot58List.AddForm(extraArmor)  ; actually uses 54, but leg-strap uses 58
			
		endIf
	endIf
	
	; ComfySocks
	string sockName = "ComfySocks.esl"
	if (!Game.IsPluginInstalled(sockName))
		sockName = "ComfySocks.esp"
	endIf
	extraArmor = IsPluginActive(0x11000804, sockName) as Armor
	if (extraArmor != None)
		if (DTSleep_ExtraArmorsEnabled.GetValue() < 1.0)
			DTSleep_ExtraArmorsEnabled.SetValue(1.0)
		endIf
		if (!DTSleep_ArmorSlotULegList.HasForm(extraArmor as Form))
			modCount += 1
			DTSleep_ArmorSlotULegList.AddForm(extraArmor)
			DTSleep_ArmorSlotULegList.AddForm(Game.GetFormFromFile(0x01100824, sockName))
			DTSleep_ArmorSlotULegList.AddForm(Game.GetFormFromFile(0x01100825, sockName))
			DTSleep_ArmorSlotULegList.AddForm(Game.GetFormFromFile(0x01100826, sockName))
			DTSleep_ArmorSlotULegList.AddForm(Game.GetFormFromFile(0x01100827, sockName))
			DTSleep_ArmorSlotULegList.AddForm(Game.GetFormFromFile(0x01100828, sockName))
			DTSleep_ArmorSlotULegList.AddForm(Game.GetFormFromFile(0x01100829, sockName))
			DTSleep_ArmorSlotULegList.AddForm(Game.GetFormFromFile(0x0110082A, sockName))
			DTSleep_ArmorSlotULegList.AddForm(Game.GetFormFromFile(0x0110082B, sockName))
			DTSleep_ArmorSlotULegList.AddForm(Game.GetFormFromFile(0x0110082C, sockName))
			DTSleep_ArmorSlotULegList.AddForm(Game.GetFormFromFile(0x01100831, sockName))
			DTSleep_ArmorSlotULegList.AddForm(Game.GetFormFromFile(0x01100832, sockName))
			DTSleep_ArmorSlotULegList.AddForm(Game.GetFormFromFile(0x01100834, sockName))
			DTSleep_ArmorSlotULegList.AddForm(Game.GetFormFromFile(0x01100835, sockName))
			DTSleep_ArmorSlotULegList.AddForm(Game.GetFormFromFile(0x01100836, sockName))
			DTSleep_ArmorSlotULegList.AddForm(Game.GetFormFromFile(0x01100839, sockName))
			DTSleep_ArmorSlotULegList.AddForm(Game.GetFormFromFile(0x01100856, sockName))
			DTSleep_ArmorSlotULegList.AddForm(Game.GetFormFromFile(0x01100857, sockName))
			DTSleep_ArmorSlotULegList.AddForm(Game.GetFormFromFile(0x0110085E, sockName))
			DTSleep_ArmorSlotULegList.AddForm(Game.GetFormFromFile(0x01100866, sockName))
			DTSleep_ArmorSlotULegList.AddForm(Game.GetFormFromFile(0x01100867, sockName))
			DTSleep_ArmorSlotULegList.AddForm(Game.GetFormFromFile(0x01100868, sockName))
			DTSleep_ArmorSlotULegList.AddForm(Game.GetFormFromFile(0x0110086E, sockName))
			DTSleep_ArmorSlotULegList.AddForm(Game.GetFormFromFile(0x01100874, sockName))
			DTSleep_ArmorSlotULegList.AddForm(Game.GetFormFromFile(0x01100875, sockName))
			DTSleep_ArmorSlotULegList.AddForm(Game.GetFormFromFile(0x0110087A, sockName))
		endIf
		extraArmor = Game.GetFormFromFile(0x0110087E, sockName) as Armor
		if (extraArmor != None && !DTSleep_ArmorSlotULegList.HasForm(extraArmor as Form))
			DTSleep_ArmorSlotULegList.AddForm(extraArmor)
			DTSleep_ArmorSlotULegList.AddForm(Game.GetFormFromFile(0x01100885, sockName))
			DTSleep_ArmorSlotULegList.AddForm(Game.GetFormFromFile(0x01100886, sockName))
			DTSleep_ArmorSlotULegList.AddForm(Game.GetFormFromFile(0x01100887, sockName))
			DTSleep_ArmorSlotULegList.AddForm(Game.GetFormFromFile(0x0110088D, sockName))
			DTSleep_ArmorSlotULegList.AddForm(Game.GetFormFromFile(0x01100891, sockName))
			DTSleep_ArmorSlotULegList.AddForm(Game.GetFormFromFile(0x01100893, sockName))
		endIf
	endIf
	
	; newermind Girls Workshop
	extraArmor = IsPluginActive(0x11000F9A, "Girls Workshop.esp") as Armor
	if (extraArmor != None)
		if (DTSleep_ExtraArmorsEnabled.GetValue() < 1.0)
			DTSleep_ExtraArmorsEnabled.SetValue(1.0)
		endIf
		if (!DTSleep_ArmorExtraClothingList.HasForm(extraArmor as Form))
			modCount += 1
			DTSleep_ArmorExtraClothingList.AddForm(extraArmor as Form)
			DTSleep_ArmorExtraClothingList.AddForm(Game.GetFormFromFile(0x01104523, "Girls Workshop.esp"))
			DTSleep_ArmorExtraClothingList.AddForm(Game.GetFormFromFile(0x01107A82, "Girls Workshop.esp"))
			DTSleep_ArmorJacketsClothingList.AddForm(Game.GetFormFromFile(0x01103D68, "Girls Workshop.esp"))
			DTSleep_ArmorJacketsClothingList.AddForm(Game.GetFormFromFile(0x01103D69, "Girls Workshop.esp"))
		endIf
	endIf
	
	; Femshepping CuteSleepwear
	string cuteSleepName = "CuteSleepwearCBBE_Femshepping.esp"
	if (!Game.IsPluginInstalled(cuteSleepName))
		cuteSleepName = "CuteSleepwearVanilla_Femshepping.esp"
		if (Game.IsPluginInstalled("CuteSleepwear_Femshepping.esp"))
			cuteSleepName = "CuteSleepwear_Femshepping.esp"
		endIf
	endIf
	extraArmor = IsPluginActive(0x11000801, cuteSleepName) as Armor
	if (extraArmor != None)
		if (DTSleep_ExtraArmorsEnabled.GetValue() < 1.0)
			DTSleep_ExtraArmorsEnabled.SetValue(1.0)
		endIf
		if (!DTSleep_SleepAttireFemale.HasForm(extraArmor as Form))
			modCount += 1
			DTSleep_SleepAttireFemale.AddForm(extraArmor as Form)
			DTSleep_SleepAttireFemale.AddForm(Game.GetFormFromFile(0x11000805, cuteSleepName))
			DTSleep_SleepAttireFemale.AddForm(Game.GetFormFromFile(0x11000806, cuteSleepName))
			DTSleep_SleepAttireFemale.AddForm(Game.GetFormFromFile(0x11000807, cuteSleepName))
		endIf
	endIf
	
	; jags78 Utility Belt    - v2.53
	string jagsStr = "jags78_UtilityBelt.esl"
	if (!Game.IsPluginInstalled(jagsStr))
		jagsStr = "jags78_UtilityBelt.esp"
	endIf
	Form jagsBeltForm = IsPluginActive(0x0100003E, jagsStr)
	if (extraArmor != None && !DTSleep_QuestItemModList.HasForm(jagsBeltForm))
		modCount += 1
		DTSleep_QuestItemModList.AddForm(jagsBeltForm)
	endIf
	
	; DX Red Ribbon   - v2.76
	;   - Stardust using slot 54, not normally removed and can be left on naked body
	;   - Fireworks using slot 57, normally removed
	string redRibbonStr = "DX_RedRibbon.esp"
	extraArmor = IsPluginActive(0x11024709, redRibbonStr) as Armor
	if (extraArmor != None && !DTSleep_ArmorChokerList.HasForm(extraArmor as Form))
		modCount += 1
		DTSleep_ArmorChokerList.AddForm(extraArmor as Form)
		DTSleep_ArmorBackPacksList.AddForm(Game.GetFormFromFile(0x11023F6D, redRibbonStr))	; candy cane on back
		DTSleep_SexyClothesFList.AddForm(Game.GetFormFromFile(0x11031620, redRibbonStr))	; outfitOpen / unstrapped
	endIf
	
	; ---------------- Adult only -------------
	;
	if (DTSleep_AdultContentOn.GetValue() > 0.0)
	
		Form pantsForm = IsPluginActive(0x11000F9C, "TBOS-Sweatpants.esp")
		if (pantsForm != None && !DTSleep_SleepAttireMale.HasForm(pantsForm))
			modCount += 1
			DTSleep_SleepAttireMale.AddForm(pantsForm)
			DTSleep_SleepAttireFemale.AddForm(pantsForm)
		endIf
	
		if (DTSleep_AdultContentOn.GetValue() >= 2.0)
		
			string crazySexToysName = "Crazy - Sex Toys of the Commonwealth.esp"
			Form crazyItem = IsPluginActive(0x1100266D, crazySexToysName)
			if (crazyItem != None && !DTSleep_FemBedItemFList.HasForm(crazyItem))
				modCount += 1
				DTSleep_FemBedItemFList.AddForm(crazyItem)
				DTSleep_FemBedItemFList.AddForm(Game.GetFormFromFile(0x110026A5, crazySexToysName))
				DTSleep_FemBedItemFList.AddForm(Game.GetFormFromFile(0x11002E2D, crazySexToysName))
				DTSleep_FemBedItemFList.AddForm(Game.GetFormFromFile(0x11002E2E, crazySexToysName))
				DTSleep_FemBedItemFList.AddForm(Game.GetFormFromFile(0x11002E2F, crazySexToysName))
				DTSleep_FemBedItemFList.AddForm(Game.GetFormFromFile(0x11002E30, crazySexToysName))
				DTSleep_FemBedItemFList.AddForm(Game.GetFormFromFile(0x11002E3C, crazySexToysName))
				DTSleep_FemBedItemFList.AddForm(Game.GetFormFromFile(0x11002E43, crazySexToysName))
				DTSleep_FemBedItemFList.AddForm(Game.GetFormFromFile(0x11002E44, crazySexToysName))
				DTSleep_FemBedItemFList.AddForm(Game.GetFormFromFile(0x11002E46, crazySexToysName))
				DTSleep_FemBedItemFList.AddForm(Game.GetFormFromFile(0x11002E47, crazySexToysName))
				DTSleep_FemBedItemFList.AddForm(Game.GetFormFromFile(0x11002E48, crazySexToysName))
				DTSleep_FemBedItemFList.AddForm(Game.GetFormFromFile(0x11002E49, crazySexToysName))
				DTSleep_FemBedItemFList.AddForm(Game.GetFormFromFile(0x11002E4A, crazySexToysName))
				DTSleep_FemBedItemFList.AddForm(Game.GetFormFromFile(0x11004518, crazySexToysName))
				DTSleep_FemBedItemFList.AddForm(Game.GetFormFromFile(0x1100451C, crazySexToysName))
				DTSleep_FemBedItemFList.AddForm(Game.GetFormFromFile(0x1100451D, crazySexToysName))
				DTSleep_FemBedItemFList.AddForm(Game.GetFormFromFile(0x1100451E, crazySexToysName))
				DTSleep_FemBedItemFList.AddForm(Game.GetFormFromFile(0x11004520, crazySexToysName))
				DTSleep_FemBedItemFList.AddForm(Game.GetFormFromFile(0x11004521, crazySexToysName))
				DTSleep_FemBedItemFList.AddForm(Game.GetFormFromFile(0x11004522, crazySexToysName))
				DTSleep_FemBedItemFList.AddForm(Game.GetFormFromFile(0x11004523, crazySexToysName))
				DTSleep_FemBedItemFList.AddForm(Game.GetFormFromFile(0x11004524, crazySexToysName))
				DTSleep_FemBedItemFList.AddForm(Game.GetFormFromFile(0x11004525, crazySexToysName))
				DTSleep_FemBedItemFList.AddForm(Game.GetFormFromFile(0x11004526, crazySexToysName))
				DTSleep_FemBedItemFList.AddForm(Game.GetFormFromFile(0x11011171, crazySexToysName))
				DTSleep_FemBedItemFList.AddForm(Game.GetFormFromFile(0x11011172, crazySexToysName))
				DTSleep_FemBedItemFList.AddForm(Game.GetFormFromFile(0x11011173, crazySexToysName))
				DTSleep_FemBedItemFList.AddForm(Game.GetFormFromFile(0x11011174, crazySexToysName))
				DTSleep_FemBedItemFList.AddForm(Game.GetFormFromFile(0x11011175, crazySexToysName))
				DTSleep_FemBedItemFList.AddForm(Game.GetFormFromFile(0x11011176, crazySexToysName))
				DTSleep_FemBedItemFList.AddForm(Game.GetFormFromFile(0x11011177, crazySexToysName))
				DTSleep_FemBedItemFList.AddForm(Game.GetFormFromFile(0x11011178, crazySexToysName))
				DTSleep_FemBedItemFList.AddForm(Game.GetFormFromFile(0x1101796F, crazySexToysName))
			endIf
			
			; TheKite VTS
			crossPluginName = "TheKite_VTS.esp"
			extraArmor = IsPluginActive(0x0900216E, crossPluginName) as Armor   ; outfit
			if (extraArmor != None)
				if (!DTSleep_IntimateAttireOKUnderList.HasForm(extraArmor as Form))
					modCount += 1
					DTSleep_IntimateAttireOKUnderList.AddForm(extraArmor as Form)
					DTSleep_IntimateAttireFemaleOnlyList.AddForm(extraArmor as Form)
					; do not include DTSleep_IntimateAttireList because outfit modification can cover all; let player add
					DTSleep_SleepAttireHandsList.AddForm(extraArmor as Form)				; v2.48 - not a hand-slot, but gloves go with outfit
				elseIf (!DTSleep_SleepAttireHandsList.HasForm(extraArmor as Form))				
					modCount += 1
					DTSleep_SleepAttireHandsList.AddForm(extraArmor as Form)
				endIf
			endIf
		endIf
	
		; TheKite Militia
		crossPluginName = "TheKite_MilitiaWoman.esp"
		extraArmor = IsPluginActive(0x09003A18, crossPluginName) as Armor   ; pack
		if (extraArmor != None)
			if (!DTSleep_ArmorBackPacksList.HasForm(extraArmor))
				modCount += 1
				DTSleep_ArmorBackPacksList.AddForm(extraArmor)
			endIf
			extraArmor = Game.GetFormFromFile(0x090041DB, crossPluginName) as Armor ; overcoat
			if (extraArmor && !DTSleep_ArmorJacketsClothingList.HasForm(extraArmor))
				DTSleep_ArmorJacketsClothingList.AddForm(extraArmor)
			endIf
			
			extraArmor = Game.GetFormFromFile(0x09003253, crossPluginName) as Armor
			if (extraArmor != None && !DTSleep_IntimateAttireOKUnderList.HasForm(extraArmor as Form))
				DTSleep_IntimateAttireOKUnderList.AddForm(extraArmor as Form)
				DTSleep_IntimateAttireFemaleOnlyList.AddForm(extraArmor as Form)
				 ; do not include DTSleep_IntimateAttireList
			endIf
		endIf
	
		;TheKite Railroad
		crossPluginName = "TheKite_Railroad_Handmaiden.esp"
		
		extraArmor = IsPluginActive(0x0900083E, crossPluginName) as Armor ; overcoat
		if (extraArmor == None)
			crossPluginName = "TheKite_Railroad_Handmaiden.esl"
			extraArmor = IsPluginActive(0x0900083E, crossPluginName) as Armor ; overcoat
		endIf	
		
		if (extraArmor != None)
			if (!DTSleep_ArmorJacketsClothingList.HasForm(extraArmor as Form))
				modCount += 1
				DTSleep_ArmorJacketsClothingList.AddForm(extraArmor as Form)
				DTSleep_ArmorHatHelmList.AddForm(Game.GetFormFromFile(0x0900083F, crossPluginName))
			endIf
			
			extraArmor = Game.GetFormFromFile(0x09000840, crossPluginName) as Armor
			if (extraArmor != None && !DTSleep_IntimateAttireOKUnderList.HasForm(extraArmor as Form))
				DTSleep_IntimateAttireFemaleOnlyList.AddForm(extraArmor as Form)
				DTSleep_IntimateAttireOKUnderList.AddForm(extraArmor as Form)
				; do not include DTSleep_IntimateAttireList
				DTSleep_SexyClothesFList.AddForm(extraArmor as Form)
				DTSleep_SexyClothesMList.AddForm(extraArmor as Form)
			endIf
		endIf
		
		
		; Nexus NSFW Strap-On
		Armor strapOn = IsPluginActive(0x08000F9B, "DildoBatStrapOn.esp") as Armor
		if (strapOn != NOne)
			DTSleep_ExtraArmorsEnabled.SetValue(1.0)
			modCount += AddStrapOnToLists(strapOn, DTSleep_ArmorSlot41List)
			AddStrapOnToLists(Game.GetFormFromFile(0x08000F9C, "DildoBatStrapOn.esp") as Armor, None)
		endIf
		
		; DA Lingerie Black
		string daName = "DA Lingerie Set Black(No AE & AWKCR).esp"
		extraArmor = IsPluginActive(0x09000801, daName) as Armor
		if (extraArmor == None)
			daName = "DA Lingerie Set Black.esp"
			extraArmor = IsPluginActive(0x09000801, daName) as Armor
		endIf
		
		if (extraArmor != None)
			if (!DTSleep_SleepAttireFemale.HasForm(extraArmor as Form))
				modCount += 1
				DTSleep_SleepAttireFemale.AddForm(extraArmor)
			endIf
		endIf
		
		; FO4 Peircings SED7
		extraArmor = IsPluginActive(0x05000F9A, "FO4PiercingsSED7.esp") as Armor
		if (extraArmor != None)
			if (!DTSleep_ArmorSlot58List.HasForm(extraArmor as Form))
				modCount += 1
				DTSleep_ArmorSlot58List.AddForm(extraArmor as Form)
				DTSleep_ArmorJewelry58List.AddForm(extraArmor as Form)
				DTSleep_ArmorSlot55List.AddForm(Game.GetFormFromFile(0x050122C8, "FO4PiercingsSED7.esp"))
				Form jewelForm = Game.GetFormFromFile(0x05012A67, "FO4PiercingsSED7.esp")
				DTSleep_ArmorSlot58List.AddForm(jewelForm)
				DTSleep_ArmorJewelry58List.AddForm(jewelForm)
				DTSleep_ArmorSlot55List.AddForm(Game.GetFormFromFile(0x05013205, "FO4PiercingsSED7.esp"))
				
			elseIf (!DTSleep_ArmorJewelry58List.HasForm(extraArmor as Form))
				DTSleep_ArmorJewelry58List.AddForm(extraArmor as Form)
				DTSleep_ArmorJewelry58List.AddForm(Game.GetFormFromFile(0x05012A67, "FO4PiercingsSED7.esp"))
			endIf
		endIf
		
	 endIf
	; ----------------------- end Adult only --------------------------
	
	; Modular Jackets
	extraArmor = IsPluginActive(0x03000801, "BallisticModularJackets.esp") as Armor
	if (extraArmor)
		DTSleep_ExtraArmorsEnabled.SetValue(1.0)
		if (!DTSleep_ArmorJacketsClothingList.HasForm(extraArmor))
			modCount += 1
			DTSleep_ArmorJacketsClothingList.AddForm(extraArmor)
			DTSleep_ArmorJacketsClothingList.AddForm(Game.GetFormFromFile(0x01000802, "BallisticModularJackets.esp") as Armor)
			DTSleep_ArmorJacketsClothingList.AddForm(Game.GetFormFromFile(0x01000803, "BallisticModularJackets.esp") as Armor)
			DTSleep_ArmorJacketsClothingList.AddForm(Game.GetFormFromFile(0x01000804, "BallisticModularJackets.esp") as Armor)
			DTSleep_ArmorJacketsClothingList.AddForm(Game.GetFormFromFile(0x01000805, "BallisticModularJackets.esp") as Armor)
		endIf
	endIf
	
	
	
	; El Men's Underwear (Unterhozen) by Yusei0
	Armor underwear = IsPluginActive(0x08000F9A, "Unterhosen.esp") as Armor
	if (underwear && !DTSleep_SleepAttireMale.HasForm(underwear))
		modCount += 1
		DTSleep_SleepAttireMale.AddForm(underwear)
		DTSleep_SleepAttireMale.AddForm(Game.GetFormFromFile(0x08000F9D, "Unterhosen.esp"))
		DTSleep_SleepAttireMale.AddForm(Game.GetFormFromFile(0x08000F9E, "Unterhosen.esp"))
		DTSleep_SleepAttireMale.AddForm(Game.GetFormFromFile(0x0800173D, "Unterhosen.esp"))
		DTSleep_SleepAttireMale.AddForm(Game.GetFormFromFile(0x08002E1F, "Unterhosen.esp"))
		DTSleep_SleepAttireMale.AddForm(Game.GetFormFromFile(0x08002E20, "Unterhosen.esp"))
		DTSleep_SleepAttireMale.AddForm(Game.GetFormFromFile(0x08002E21, "Unterhosen.esp"))
		DTSleep_SleepAttireMale.AddForm(Game.GetFormFromFile(0x08002E22, "Unterhosen.esp"))
		DTSleep_SleepAttireMale.AddForm(Game.GetFormFromFile(0x08002E23, "Unterhosen.esp"))
		DTSleep_SleepAttireMale.AddForm(Game.GetFormFromFile(0x08002E24, "Unterhosen.esp"))
		DTSleep_SleepAttireMale.AddForm(Game.GetFormFromFile(0x08002E25, "Unterhosen.esp"))
		DTSleep_SleepAttireMale.AddForm(Game.GetFormFromFile(0x08002E26, "Unterhosen.esp"))
		DTSleep_SleepAttireMale.AddForm(Game.GetFormFromFile(0x08002E27, "Unterhosen.esp"))
		DTSleep_SleepAttireMale.AddForm(Game.GetFormFromFile(0x08002E28, "Unterhosen.esp"))
		DTSleep_SleepAttireMale.AddForm(Game.GetFormFromFile(0x08002E29, "Unterhosen.esp"))
		DTSleep_SleepAttireMale.AddForm(Game.GetFormFromFile(0x08002E2B, "Unterhosen.esp"))
		DTSleep_SleepAttireMale.AddForm(Game.GetFormFromFile(0x08002E2C, "Unterhosen.esp"))
		DTSleep_SleepAttireMale.AddForm(Game.GetFormFromFile(0x08002E2D, "Unterhosen.esp"))
		DTSleep_SleepAttireMale.AddForm(Game.GetFormFromFile(0x08002E2E, "Unterhosen.esp"))
		DTSleep_SleepAttireMale.AddForm(Game.GetFormFromFile(0x08002E2F, "Unterhosen.esp"))
		DTSleep_SleepAttireMale.AddForm(Game.GetFormFromFile(0x08002E30, "Unterhosen.esp"))
		DTSleep_SleepAttireMale.AddForm(Game.GetFormFromFile(0x08002E31, "Unterhosen.esp"))
		DTSleep_SleepAttireMale.AddForm(Game.GetFormFromFile(0x08002E32, "Unterhosen.esp"))
		DTSleep_SleepAttireMale.AddForm(Game.GetFormFromFile(0x08002E33, "Unterhosen.esp"))
		DTSleep_SleepAttireMale.AddForm(Game.GetFormFromFile(0x08002E3E, "Unterhosen.esp"))
	endIf

	
	; Jacket's of the Commonwealth
	extraArmor = IsPluginActive(0x07000803, "Jacket.esp") as Armor
	if (extraArmor)
		DTSleep_ExtraArmorsEnabled.SetValue(1.0)
		
		if (!DTSleep_ArmorJacketsClothingList.HasForm(extraArmor))
			modCount += 1
			DTSleep_ArmorJacketsClothingList.AddForm(extraArmor)
			DTSleep_ArmorJacketsClothingList.AddForm(Game.GetFormFromFile(0x07000808, "Jacket.esp"))
			DTSleep_ArmorJacketsClothingList.AddForm(Game.GetFormFromFile(0x0700080B, "Jacket.esp"))
			DTSleep_ArmorJacketsClothingList.AddForm(Game.GetFormFromFile(0x0700080C, "Jacket.esp"))
			DTSleep_ArmorJacketsClothingList.AddForm(Game.GetFormFromFile(0x0700080D, "Jacket.esp"))
			DTSleep_ArmorJacketsClothingList.AddForm(Game.GetFormFromFile(0x07000812, "Jacket.esp"))
			DTSleep_ArmorJacketsClothingList.AddForm(Game.GetFormFromFile(0x07000813, "Jacket.esp"))
			DTSleep_ArmorJacketsClothingList.AddForm(Game.GetFormFromFile(0x07000814, "Jacket.esp"))
			DTSleep_ArmorJacketsClothingList.AddForm(Game.GetFormFromFile(0x07000815, "Jacket.esp"))
			DTSleep_ArmorJacketsClothingList.AddForm(Game.GetFormFromFile(0x07000816, "Jacket.esp"))
			DTSleep_ArmorJacketsClothingList.AddForm(Game.GetFormFromFile(0x07000817, "Jacket.esp"))
			DTSleep_ArmorJacketsClothingList.AddForm(Game.GetFormFromFile(0x07000818, "Jacket.esp"))
			DTSleep_ArmorJacketsClothingList.AddForm(Game.GetFormFromFile(0x07000819, "Jacket.esp"))
			DTSleep_ArmorJacketsClothingList.AddForm(Game.GetFormFromFile(0x0700081A, "Jacket.esp"))
			DTSleep_ArmorJacketsClothingList.AddForm(Game.GetFormFromFile(0x07000827, "Jacket.esp"))
			DTSleep_ArmorJacketsClothingList.AddForm(Game.GetFormFromFile(0x0700083B, "Jacket.esp"))
			DTSleep_ArmorJacketsClothingList.AddForm(Game.GetFormFromFile(0x0700083C, "Jacket.esp"))
			DTSleep_ArmorJacketsClothingList.AddForm(Game.GetFormFromFile(0x07000844, "Jacket.esp"))
			DTSleep_ArmorJacketsClothingList.AddForm(Game.GetFormFromFile(0x07000845, "Jacket.esp"))
			DTSleep_ArmorJacketsClothingList.AddForm(Game.GetFormFromFile(0x07000846, "Jacket.esp"))
			DTSleep_ArmorJacketsClothingList.AddForm(Game.GetFormFromFile(0x07000847, "Jacket.esp"))
			DTSleep_ArmorJacketsClothingList.AddForm(Game.GetFormFromFile(0x07000848, "Jacket.esp"))
			DTSleep_ArmorJacketsClothingList.AddForm(Game.GetFormFromFile(0x07000849, "Jacket.esp"))
			DTSleep_ArmorJacketsClothingList.AddForm(Game.GetFormFromFile(0x0700084A, "Jacket.esp"))
			DTSleep_ArmorJacketsClothingList.AddForm(Game.GetFormFromFile(0x0700084B, "Jacket.esp"))
			DTSleep_ArmorJacketsClothingList.AddForm(Game.GetFormFromFile(0x0700084C, "Jacket.esp"))
			DTSleep_ArmorJacketsClothingList.AddForm(Game.GetFormFromFile(0x0700084D, "Jacket.esp"))
			DTSleep_ArmorJacketsClothingList.AddForm(Game.GetFormFromFile(0x0700084E, "Jacket.esp"))
			DTSleep_ArmorJacketsClothingList.AddForm(Game.GetFormFromFile(0x0700084F, "Jacket.esp"))
			DTSleep_ArmorJacketsClothingList.AddForm(Game.GetFormFromFile(0x07000850, "Jacket.esp"))
			DTSleep_ArmorJacketsClothingList.AddForm(Game.GetFormFromFile(0x07000851, "Jacket.esp"))
			DTSleep_ArmorJacketsClothingList.AddForm(Game.GetFormFromFile(0x07000852, "Jacket.esp"))
			DTSleep_ArmorJacketsClothingList.AddForm(Game.GetFormFromFile(0x07000866, "Jacket.esp"))
			DTSleep_ArmorJacketsClothingList.AddForm(Game.GetFormFromFile(0x0700086C, "Jacket.esp"))
			DTSleep_ArmorJacketsClothingList.AddForm(Game.GetFormFromFile(0x0700086D, "Jacket.esp"))
			DTSleep_ArmorJacketsClothingList.AddForm(Game.GetFormFromFile(0x0700086E, "Jacket.esp"))
			DTSleep_ArmorJacketsClothingList.AddForm(Game.GetFormFromFile(0x0700086F, "Jacket.esp"))
			DTSleep_ArmorJacketsClothingList.AddForm(Game.GetFormFromFile(0x07000878, "Jacket.esp"))
			DTSleep_ArmorJacketsClothingList.AddForm(Game.GetFormFromFile(0x07000879, "Jacket.esp"))
			DTSleep_ArmorJacketsClothingList.AddForm(Game.GetFormFromFile(0x07000883, "Jacket.esp"))
			DTSleep_ArmorJacketsClothingList.AddForm(Game.GetFormFromFile(0x07000884, "Jacket.esp"))
			DTSleep_ArmorJacketsClothingList.AddForm(Game.GetFormFromFile(0x07000888, "Jacket.esp"))
			DTSleep_ArmorJacketsClothingList.AddForm(Game.GetFormFromFile(0x0700088A, "Jacket.esp"))
			DTSleep_ArmorJacketsClothingList.AddForm(Game.GetFormFromFile(0x0700088D, "Jacket.esp"))
			DTSleep_ArmorJacketsClothingList.AddForm(Game.GetFormFromFile(0x0700088E, "Jacket.esp"))
			DTSleep_ArmorJacketsClothingList.AddForm(Game.GetFormFromFile(0x070008C6, "Jacket.esp"))
		endIf
	endIf
	
	; Field Scribe Backpack
	extraArmor = IsPluginActive(0x09000805, "FieldScribeBackpack.esp") as Armor
	if (extraArmor)
		if (!DTSleep_ArmorBackPacksNoGOList.HasForm(extraArmor))
			modCount += 1
			DTSleep_ArmorBackPacksNoGOList.AddForm(extraArmor)
			DTSleep_ArmorBackPacksNoGOList.AddForm(Game.GetFormFromFile(0x0900080C, "FieldScribeBackpack.esp"))
			DTSleep_ArmorBackPacksNoGOList.AddForm(Game.GetFormFromFile(0x0900080D, "FieldScribeBackpack.esp"))
			DTSleep_ArmorBackPacksNoGOList.AddForm(Game.GetFormFromFile(0x09000814, "FieldScribeBackpack.esp"))
			DTSleep_ArmorBackPacksNoGOList.AddForm(Game.GetFormFromFile(0x09000815, "FieldScribeBackpack.esp"))
			DTSleep_ArmorBackPacksNoGOList.AddForm(Game.GetFormFromFile(0x09000816, "FieldScribeBackpack.esp"))
			DTSleep_ArmorBackPacksNoGOList.AddForm(Game.GetFormFromFile(0x09000817, "FieldScribeBackpack.esp"))
			DTSleep_ArmorBackPacksNoGOList.AddForm(Game.GetFormFromFile(0x09000818, "FieldScribeBackpack.esp"))
			DTSleep_ArmorBackPacksNoGOList.AddForm(Game.GetFormFromFile(0x09000819, "FieldScribeBackpack.esp"))
			DTSleep_ArmorBackPacksNoGOList.AddForm(Game.GetFormFromFile(0x0900081F, "FieldScribeBackpack.esp"))
			DTSleep_ArmorBackPacksNoGOList.AddForm(Game.GetFormFromFile(0x09000820, "FieldScribeBackpack.esp"))
			DTSleep_ArmorBackPacksNoGOList.AddForm(Game.GetFormFromFile(0x09000821, "FieldScribeBackpack.esp"))
			DTSleep_ArmorBackPacksNoGOList.AddForm(Game.GetFormFromFile(0x09000827, "FieldScribeBackpack.esp"))
			DTSleep_ArmorBackPacksNoGOList.AddForm(Game.GetFormFromFile(0x09000828, "FieldScribeBackpack.esp"))
			DTSleep_ArmorBackPacksNoGOList.AddForm(Game.GetFormFromFile(0x09000829, "FieldScribeBackpack.esp"))
			DTSleep_ArmorBackPacksNoGOList.AddForm(Game.GetFormFromFile(0x0900082A, "FieldScribeBackpack.esp"))
		endIf
	endIf
	
	
	; AnS Wearable Backpacks
	extraArmor = IsPluginActive(0x03000807, "AnS Wearable Backpacks and Pouches.esp") as Armor
	if (extraArmor)
		if (!DTSleep_ArmorBackPacksList.HasForm(extraArmor))
			modCount += 1
			DTSleep_ArmorBackPacksList.AddForm(extraArmor)
			DTSleep_ArmorBackPacksList.AddForm(Game.GetFormFromFile(0x01000833, "AnS Wearable Backpacks and Pouches.esp"))
			DTSleep_ArmorBackPacksList.AddForm(Game.GetFormFromFile(0x01000835, "AnS Wearable Backpacks and Pouches.esp"))
			DTSleep_ArmorBackPacksList.AddForm(Game.GetFormFromFile(0x01000847, "AnS Wearable Backpacks and Pouches.esp"))
			DTSleep_ArmorBackPacksList.AddForm(Game.GetFormFromFile(0x01000848, "AnS Wearable Backpacks and Pouches.esp"))
			DTSleep_ArmorBackPacksList.AddForm(Game.GetFormFromFile(0x01000849, "AnS Wearable Backpacks and Pouches.esp"))
			DTSleep_ArmorBackPacksList.AddForm(Game.GetFormFromFile(0x0100086B, "AnS Wearable Backpacks and Pouches.esp"))
			DTSleep_ArmorBackPacksList.AddForm(Game.GetFormFromFile(0x0100087D, "AnS Wearable Backpacks and Pouches.esp"))
			DTSleep_ArmorBackPacksList.AddForm(Game.GetFormFromFile(0x0100087E, "AnS Wearable Backpacks and Pouches.esp"))
			DTSleep_ArmorBackPacksList.AddForm(Game.GetFormFromFile(0x010008F5, "AnS Wearable Backpacks and Pouches.esp"))
			DTSleep_ArmorBackPacksList.AddForm(Game.GetFormFromFile(0x010008F6, "AnS Wearable Backpacks and Pouches.esp"))
			DTSleep_ArmorBackPacksList.AddForm(Game.GetFormFromFile(0x010008F7, "AnS Wearable Backpacks and Pouches.esp"))
			DTSleep_ArmorBackPacksList.AddForm(Game.GetFormFromFile(0x010009AF, "AnS Wearable Backpacks and Pouches.esp"))
			DTSleep_ArmorBackPacksList.AddForm(Game.GetFormFromFile(0x010009B0, "AnS Wearable Backpacks and Pouches.esp"))
			DTSleep_ArmorBackPacksList.AddForm(Game.GetFormFromFile(0x010009B1, "AnS Wearable Backpacks and Pouches.esp"))
			DTSleep_ArmorBackPacksList.AddForm(Game.GetFormFromFile(0x010009B2, "AnS Wearable Backpacks and Pouches.esp"))
			DTSleep_ArmorBackPacksList.AddForm(Game.GetFormFromFile(0x010009B8, "AnS Wearable Backpacks and Pouches.esp"))
			DTSleep_ArmorBackPacksList.AddForm(Game.GetFormFromFile(0x010009EA, "AnS Wearable Backpacks and Pouches.esp"))
			DTSleep_ArmorBackPacksList.AddForm(Game.GetFormFromFile(0x010009EB, "AnS Wearable Backpacks and Pouches.esp"))
			DTSleep_ArmorBackPacksList.AddForm(Game.GetFormFromFile(0x010009EC, "AnS Wearable Backpacks and Pouches.esp"))
			DTSleep_ArmorBackPacksList.AddForm(Game.GetFormFromFile(0x010009F4, "AnS Wearable Backpacks and Pouches.esp"))
			DTSleep_ArmorBackPacksList.AddForm(Game.GetFormFromFile(0x010009F5, "AnS Wearable Backpacks and Pouches.esp"))
			DTSleep_ArmorBackPacksList.AddForm(Game.GetFormFromFile(0x010009F6, "AnS Wearable Backpacks and Pouches.esp"))
			DTSleep_ArmorBackPacksList.AddForm(Game.GetFormFromFile(0x010009F7, "AnS Wearable Backpacks and Pouches.esp"))
		endIf
	endIf
	
	; Backpacks of the Commonwealth
	extraArmor = IsPluginActive(0x4003E0CA, "Backpacks of the Commonwealth.esp") as Armor			; v2.70 updated to start with missing Wastlander's Backpack
	if (extraArmor != None)
		if (!DTSleep_ArmorBackPacksList.HasForm(extraArmor))
			modCount += 1
			DTSleep_ArmorBackPacksList.AddForm(extraArmor)
			if (DTSleep_ArmorBackPacksNoGOList.HasForm(extraArmor))
				; fix to get ground object for missing backpack if player had added it to no-GroundObject list
				DTSleep_ArmorBackPacksNoGOList.RemoveAddedForm(extraArmor)
			endIf
			DTSleep_ArmorBackPacksList.AddForm(Game.GetFormFromFile(0x400026E1, "Backpacks of the Commonwealth.esp"))
			DTSleep_ArmorBackPacksList.AddForm(Game.GetFormFromFile(0x40002E76, "Backpacks of the Commonwealth.esp"))
			DTSleep_ArmorBackPacksList.AddForm(Game.GetFormFromFile(0x40002E8B, "Backpacks of the Commonwealth.esp"))
			DTSleep_ArmorBackPacksList.AddForm(Game.GetFormFromFile(0x40002E9A, "Backpacks of the Commonwealth.esp"))
			DTSleep_ArmorBackPacksList.AddForm(Game.GetFormFromFile(0x40002E9D, "Backpacks of the Commonwealth.esp"))
			DTSleep_ArmorBackPacksList.AddForm(Game.GetFormFromFile(0x4000636D, "Backpacks of the Commonwealth.esp"))
			DTSleep_ArmorBackPacksList.AddForm(Game.GetFormFromFile(0x40006B1F, "Backpacks of the Commonwealth.esp"))
			DTSleep_ArmorBackPacksList.AddForm(Game.GetFormFromFile(0x40007C2C, "Backpacks of the Commonwealth.esp"))
			DTSleep_ArmorBackPacksList.AddForm(Game.GetFormFromFile(0x400098C3, "Backpacks of the Commonwealth.esp"))
			DTSleep_ArmorBackPacksList.AddForm(Game.GetFormFromFile(0x4000AD66, "Backpacks of the Commonwealth.esp"))
			DTSleep_ArmorBackPacksList.AddForm(Game.GetFormFromFile(0x4000AD7C, "Backpacks of the Commonwealth.esp"))
			DTSleep_ArmorBackPacksList.AddForm(Game.GetFormFromFile(0x4000B745, "Backpacks of the Commonwealth.esp"))
			DTSleep_ArmorBackPacksList.AddForm(Game.GetFormFromFile(0x4000D27A, "Backpacks of the Commonwealth.esp"))
			DTSleep_ArmorBackPacksList.AddForm(Game.GetFormFromFile(0x4000D3F4, "Backpacks of the Commonwealth.esp"))
			DTSleep_ArmorBackPacksList.AddForm(Game.GetFormFromFile(0x40000F9C, "Backpacks of the Commonwealth.esp"))
		endIf
	endIf
	
	; Survivalist GoBags
	string pluginNameGoBag = "Survivalist GoBags-Chem Station.esp"
	extraArmor = IsPluginActive(0x12000805, pluginNameGoBag) as Armor
	
	;if (extraArmor == None)
	;	pluginNameGoBag = "Survivalist Go-Bags_AE_AWKCR.esp"  ; should work with AWKCR flag
	;	extraArmor = IsPluginActive(0x12000805, pluginNameGoBag)
	;endIf
	
	if (extraArmor)
		if (!DTSleep_ArmorBackPacksList.HasForm(extraArmor))
			modCount += 1
			DTSleep_ArmorBackPacksList.AddForm(extraArmor)
			DTSleep_ArmorBackPacksList.AddForm(Game.GetFormFromFile(0x1200080C, pluginNameGoBag))
			DTSleep_ArmorBackPacksList.AddForm(Game.GetFormFromFile(0x1200080D, pluginNameGoBag))
			DTSleep_ArmorBackPacksList.AddForm(Game.GetFormFromFile(0x12000827, pluginNameGoBag))
			DTSleep_ArmorBackPacksList.AddForm(Game.GetFormFromFile(0x12001776, pluginNameGoBag))
			DTSleep_ArmorBackPacksList.AddForm(Game.GetFormFromFile(0x12001784, pluginNameGoBag))
			DTSleep_ArmorBackPacksList.AddForm(Game.GetFormFromFile(0x12001785, pluginNameGoBag))
			DTSleep_ArmorBackPacksList.AddForm(Game.GetFormFromFile(0x1200178A, pluginNameGoBag))
			DTSleep_ArmorBackPacksList.AddForm(Game.GetFormFromFile(0x1200178B, pluginNameGoBag))
			DTSleep_ArmorBackPacksList.AddForm(Game.GetFormFromFile(0x12001790, pluginNameGoBag))
			DTSleep_ArmorBackPacksList.AddForm(Game.GetFormFromFile(0x12001791, pluginNameGoBag))
			DTSleep_ArmorBackPacksList.AddForm(Game.GetFormFromFile(0x1200179A, pluginNameGoBag))
			DTSleep_ArmorBackPacksList.AddForm(Game.GetFormFromFile(0x1200179B, pluginNameGoBag))
			DTSleep_ArmorBackPacksList.AddForm(Game.GetFormFromFile(0x1200179C, pluginNameGoBag))
			DTSleep_ArmorBackPacksList.AddForm(Game.GetFormFromFile(0x1200179D, pluginNameGoBag))
			DTSleep_ArmorBackPacksList.AddForm(Game.GetFormFromFile(0x1200179E, pluginNameGoBag))
			DTSleep_ArmorBackPacksList.AddForm(Game.GetFormFromFile(0x1200179F, pluginNameGoBag))
			DTSleep_ArmorBackPacksList.AddForm(Game.GetFormFromFile(0x120017A8, pluginNameGoBag))
			DTSleep_ArmorBackPacksList.AddForm(Game.GetFormFromFile(0x120017AC, pluginNameGoBag))
			DTSleep_ArmorBackPacksList.AddForm(Game.GetFormFromFile(0x120017AD, pluginNameGoBag))
			DTSleep_ArmorBackPacksList.AddForm(Game.GetFormFromFile(0x120017B2, pluginNameGoBag))
			DTSleep_ArmorBackPacksList.AddForm(Game.GetFormFromFile(0x120017B3, pluginNameGoBag))
			DTSleep_ArmorBackPacksList.AddForm(Game.GetFormFromFile(0x120017B8, pluginNameGoBag))
			DTSleep_ArmorBackPacksList.AddForm(Game.GetFormFromFile(0x120017B9, pluginNameGoBag))
			DTSleep_ArmorBackPacksList.AddForm(Game.GetFormFromFile(0x120017BD, pluginNameGoBag))
			DTSleep_ArmorBackPacksList.AddForm(Game.GetFormFromFile(0x120017C1, pluginNameGoBag))
			DTSleep_ArmorBackPacksList.AddForm(Game.GetFormFromFile(0x120017C2, pluginNameGoBag))
			DTSleep_ArmorBackPacksList.AddForm(Game.GetFormFromFile(0x120017C7, pluginNameGoBag))
			DTSleep_ArmorBackPacksList.AddForm(Game.GetFormFromFile(0x120017C8, pluginNameGoBag))
			DTSleep_ArmorBackPacksList.AddForm(Game.GetFormFromFile(0x120017DE, pluginNameGoBag))
			DTSleep_ArmorBackPacksList.AddForm(Game.GetFormFromFile(0x120017DF, pluginNameGoBag))
			DTSleep_ArmorBackPacksList.AddForm(Game.GetFormFromFile(0x120017E0, pluginNameGoBag))
			DTSleep_ArmorBackPacksList.AddForm(Game.GetFormFromFile(0x120017E1, pluginNameGoBag))
			DTSleep_ArmorBackPacksList.AddForm(Game.GetFormFromFile(0x120017E2, pluginNameGoBag))
			DTSleep_ArmorBackPacksList.AddForm(Game.GetFormFromFile(0x120017E3, pluginNameGoBag))
			DTSleep_ArmorBackPacksList.AddForm(Game.GetFormFromFile(0x120017EE, pluginNameGoBag))
			DTSleep_ArmorBackPacksList.AddForm(Game.GetFormFromFile(0x120017F2, pluginNameGoBag))
			DTSleep_ArmorBackPacksList.AddForm(Game.GetFormFromFile(0x120017F3, pluginNameGoBag))
			DTSleep_ArmorBackPacksList.AddForm(Game.GetFormFromFile(0x120017FB, pluginNameGoBag))
			DTSleep_ArmorBackPacksList.AddForm(Game.GetFormFromFile(0x120017FC, pluginNameGoBag))
			DTSleep_ArmorBackPacksList.AddForm(Game.GetFormFromFile(0x120017FD, pluginNameGoBag))
			DTSleep_ArmorBackPacksList.AddForm(Game.GetFormFromFile(0x120017FF, pluginNameGoBag))
			DTSleep_ArmorBackPacksList.AddForm(Game.GetFormFromFile(0x12001800, pluginNameGoBag))
			DTSleep_ArmorBackPacksList.AddForm(Game.GetFormFromFile(0x12001801, pluginNameGoBag))
		endIf
	endIf
	
	; Azar Holstered Weapons
	extraArmor = IsPluginActive(0x110035BF, "AzarHolsteredWeapons.esp") as Armor
	if (extraArmor)
		DTSleep_ExtraArmorsEnabled.SetValue(1.0)
		
		if (!DTSleep_ArmorBackPacksNoGOList.HasForm(extraArmor))
			modCount += 1
			
			; backpacks
			DTSleep_ArmorBackPacksNoGOList.AddForm(extraArmor)
			DTSleep_ArmorBackPacksNoGOList.AddForm(Game.GetFormFromFile(0x11003D5C, "AzarHolsteredWeapons.esp"))
			DTSleep_ArmorBackPacksNoGOList.AddForm(Game.GetFormFromFile(0x1100542F, "AzarHolsteredWeapons.esp"))
			DTSleep_ArmorBackPacksNoGOList.AddForm(Game.GetFormFromFile(0x11006B2A, "AzarHolsteredWeapons.esp"))
			DTSleep_ArmorBackPacksNoGOList.AddForm(Game.GetFormFromFile(0x11006B2D, "AzarHolsteredWeapons.esp"))
			DTSleep_ArmorBackPacksNoGOList.AddForm(Game.GetFormFromFile(0x11006B30, "AzarHolsteredWeapons.esp"))
			DTSleep_ArmorBackPacksNoGOList.AddForm(Game.GetFormFromFile(0x11006B33, "AzarHolsteredWeapons.esp"))
			DTSleep_ArmorBackPacksNoGOList.AddForm(Game.GetFormFromFile(0x11006B36, "AzarHolsteredWeapons.esp"))
			DTSleep_ArmorBackPacksNoGOList.AddForm(Game.GetFormFromFile(0x11006B39, "AzarHolsteredWeapons.esp"))
			DTSleep_ArmorBackPacksNoGOList.AddForm(Game.GetFormFromFile(0x11006B3C, "AzarHolsteredWeapons.esp"))
			
			DTSleep_ArmorExtraPartsList.AddForm(Game.GetFormFromFile(0x11000F99, "AzarHolsteredWeapons.esp"))  
			DTSleep_ArmorExtraPartsList.AddForm(Game.GetFormFromFile(0x11001738, "AzarHolsteredWeapons.esp"))
			DTSleep_ArmorExtraPartsList.AddForm(Game.GetFormFromFile(0x1100173C, "AzarHolsteredWeapons.esp"))
			DTSleep_ArmorExtraPartsList.AddForm(Game.GetFormFromFile(0x11001740, "AzarHolsteredWeapons.esp"))
			DTSleep_ArmorExtraPartsList.AddForm(Game.GetFormFromFile(0x11001743, "AzarHolsteredWeapons.esp"))
			DTSleep_ArmorExtraPartsList.AddForm(Game.GetFormFromFile(0x11001746, "AzarHolsteredWeapons.esp"))
			DTSleep_ArmorExtraPartsList.AddForm(Game.GetFormFromFile(0x11001749, "AzarHolsteredWeapons.esp"))
			DTSleep_ArmorExtraPartsList.AddForm(Game.GetFormFromFile(0x1100174C, "AzarHolsteredWeapons.esp"))
			DTSleep_ArmorExtraPartsList.AddForm(Game.GetFormFromFile(0x1100174F, "AzarHolsteredWeapons.esp"))
			DTSleep_ArmorExtraPartsList.AddForm(Game.GetFormFromFile(0x11001752, "AzarHolsteredWeapons.esp"))
			DTSleep_ArmorExtraPartsList.AddForm(Game.GetFormFromFile(0x11001755, "AzarHolsteredWeapons.esp"))
			DTSleep_ArmorExtraPartsList.AddForm(Game.GetFormFromFile(0x11001758, "AzarHolsteredWeapons.esp"))
			DTSleep_ArmorExtraPartsList.AddForm(Game.GetFormFromFile(0x1100175B, "AzarHolsteredWeapons.esp"))
			DTSleep_ArmorExtraPartsList.AddForm(Game.GetFormFromFile(0x1100175E, "AzarHolsteredWeapons.esp"))
			DTSleep_ArmorExtraPartsList.AddForm(Game.GetFormFromFile(0x11001761, "AzarHolsteredWeapons.esp"))
			DTSleep_ArmorExtraPartsList.AddForm(Game.GetFormFromFile(0x11001764, "AzarHolsteredWeapons.esp"))
			DTSleep_ArmorExtraPartsList.AddForm(Game.GetFormFromFile(0x11001767, "AzarHolsteredWeapons.esp"))
			DTSleep_ArmorExtraPartsList.AddForm(Game.GetFormFromFile(0x1100176A, "AzarHolsteredWeapons.esp"))
			DTSleep_ArmorExtraPartsList.AddForm(Game.GetFormFromFile(0x1100176D, "AzarHolsteredWeapons.esp"))
			DTSleep_ArmorExtraPartsList.AddForm(Game.GetFormFromFile(0x11001770, "AzarHolsteredWeapons.esp"))
			DTSleep_ArmorExtraPartsList.AddForm(Game.GetFormFromFile(0x11001773, "AzarHolsteredWeapons.esp"))
			DTSleep_ArmorExtraPartsList.AddForm(Game.GetFormFromFile(0x11001776, "AzarHolsteredWeapons.esp"))
			DTSleep_ArmorExtraPartsList.AddForm(Game.GetFormFromFile(0x11001779, "AzarHolsteredWeapons.esp"))
			DTSleep_ArmorExtraPartsList.AddForm(Game.GetFormFromFile(0x1100177C, "AzarHolsteredWeapons.esp"))
			DTSleep_ArmorExtraPartsList.AddForm(Game.GetFormFromFile(0x1100177F, "AzarHolsteredWeapons.esp"))
			DTSleep_ArmorExtraPartsList.AddForm(Game.GetFormFromFile(0x11001782, "AzarHolsteredWeapons.esp"))
			DTSleep_ArmorExtraPartsList.AddForm(Game.GetFormFromFile(0x11001785, "AzarHolsteredWeapons.esp"))
			DTSleep_ArmorExtraPartsList.AddForm(Game.GetFormFromFile(0x11001788, "AzarHolsteredWeapons.esp"))
			DTSleep_ArmorExtraPartsList.AddForm(Game.GetFormFromFile(0x1100178B, "AzarHolsteredWeapons.esp"))
			DTSleep_ArmorExtraPartsList.AddForm(Game.GetFormFromFile(0x1100178E, "AzarHolsteredWeapons.esp"))
			DTSleep_ArmorExtraPartsList.AddForm(Game.GetFormFromFile(0x11001791, "AzarHolsteredWeapons.esp"))
			DTSleep_ArmorExtraPartsList.AddForm(Game.GetFormFromFile(0x11001795, "AzarHolsteredWeapons.esp"))
			DTSleep_ArmorExtraPartsList.AddForm(Game.GetFormFromFile(0x11001798, "AzarHolsteredWeapons.esp"))
			DTSleep_ArmorExtraPartsList.AddForm(Game.GetFormFromFile(0x11001ECF, "AzarHolsteredWeapons.esp"))
			DTSleep_ArmorExtraPartsList.AddForm(Game.GetFormFromFile(0x11001ED2, "AzarHolsteredWeapons.esp"))
			DTSleep_ArmorExtraPartsList.AddForm(Game.GetFormFromFile(0x11001F3C, "AzarHolsteredWeapons.esp"))
			DTSleep_ArmorExtraPartsList.AddForm(Game.GetFormFromFile(0x11001F3F, "AzarHolsteredWeapons.esp"))
			DTSleep_ArmorExtraPartsList.AddForm(Game.GetFormFromFile(0x11001F42, "AzarHolsteredWeapons.esp"))
			DTSleep_ArmorExtraPartsList.AddForm(Game.GetFormFromFile(0x11001F45, "AzarHolsteredWeapons.esp"))
			DTSleep_ArmorExtraPartsList.AddForm(Game.GetFormFromFile(0x11001F48, "AzarHolsteredWeapons.esp"))
			DTSleep_ArmorExtraPartsList.AddForm(Game.GetFormFromFile(0x11001F4B, "AzarHolsteredWeapons.esp"))
			DTSleep_ArmorExtraPartsList.AddForm(Game.GetFormFromFile(0x11001F4E, "AzarHolsteredWeapons.esp"))
			DTSleep_ArmorExtraPartsList.AddForm(Game.GetFormFromFile(0x11001F51, "AzarHolsteredWeapons.esp"))
			DTSleep_ArmorExtraPartsList.AddForm(Game.GetFormFromFile(0x11001F54, "AzarHolsteredWeapons.esp"))
			DTSleep_ArmorExtraPartsList.AddForm(Game.GetFormFromFile(0x11001F57, "AzarHolsteredWeapons.esp"))
			DTSleep_ArmorExtraPartsList.AddForm(Game.GetFormFromFile(0x11001F5A, "AzarHolsteredWeapons.esp"))
			DTSleep_ArmorExtraPartsList.AddForm(Game.GetFormFromFile(0x11001F5D, "AzarHolsteredWeapons.esp"))
			DTSleep_ArmorExtraPartsList.AddForm(Game.GetFormFromFile(0x11001F60, "AzarHolsteredWeapons.esp"))
			DTSleep_ArmorExtraPartsList.AddForm(Game.GetFormFromFile(0x11001F63, "AzarHolsteredWeapons.esp"))
			DTSleep_ArmorExtraPartsList.AddForm(Game.GetFormFromFile(0x11001F66, "AzarHolsteredWeapons.esp"))
			DTSleep_ArmorExtraPartsList.AddForm(Game.GetFormFromFile(0x11001F69, "AzarHolsteredWeapons.esp"))
			DTSleep_ArmorExtraPartsList.AddForm(Game.GetFormFromFile(0x11001F6C, "AzarHolsteredWeapons.esp"))
			DTSleep_ArmorExtraPartsList.AddForm(Game.GetFormFromFile(0x11001F6F, "AzarHolsteredWeapons.esp"))
			DTSleep_ArmorExtraPartsList.AddForm(Game.GetFormFromFile(0x11001F72, "AzarHolsteredWeapons.esp"))
			DTSleep_ArmorExtraPartsList.AddForm(Game.GetFormFromFile(0x11001F75, "AzarHolsteredWeapons.esp"))
			DTSleep_ArmorExtraPartsList.AddForm(Game.GetFormFromFile(0x11001F78, "AzarHolsteredWeapons.esp"))
			DTSleep_ArmorExtraPartsList.AddForm(Game.GetFormFromFile(0x11001F7B, "AzarHolsteredWeapons.esp"))
			DTSleep_ArmorExtraPartsList.AddForm(Game.GetFormFromFile(0x11001F7E, "AzarHolsteredWeapons.esp"))
			DTSleep_ArmorExtraPartsList.AddForm(Game.GetFormFromFile(0x11001F81, "AzarHolsteredWeapons.esp"))
			DTSleep_ArmorExtraPartsList.AddForm(Game.GetFormFromFile(0x11001F84, "AzarHolsteredWeapons.esp"))
			DTSleep_ArmorExtraPartsList.AddForm(Game.GetFormFromFile(0x11001F87, "AzarHolsteredWeapons.esp"))
			DTSleep_ArmorExtraPartsList.AddForm(Game.GetFormFromFile(0x11001F8A, "AzarHolsteredWeapons.esp"))
			DTSleep_ArmorExtraPartsList.AddForm(Game.GetFormFromFile(0x11001F8D, "AzarHolsteredWeapons.esp"))
			DTSleep_ArmorExtraPartsList.AddForm(Game.GetFormFromFile(0x11001F90, "AzarHolsteredWeapons.esp"))
			DTSleep_ArmorExtraPartsList.AddForm(Game.GetFormFromFile(0x11001F93, "AzarHolsteredWeapons.esp"))
			DTSleep_ArmorExtraPartsList.AddForm(Game.GetFormFromFile(0x11001F96, "AzarHolsteredWeapons.esp"))
			DTSleep_ArmorExtraPartsList.AddForm(Game.GetFormFromFile(0x11001F99, "AzarHolsteredWeapons.esp"))
			DTSleep_ArmorExtraPartsList.AddForm(Game.GetFormFromFile(0x11001F9C, "AzarHolsteredWeapons.esp"))
			DTSleep_ArmorExtraPartsList.AddForm(Game.GetFormFromFile(0x11001F9F, "AzarHolsteredWeapons.esp"))
			DTSleep_ArmorExtraPartsList.AddForm(Game.GetFormFromFile(0x11001FA2, "AzarHolsteredWeapons.esp"))
			DTSleep_ArmorExtraPartsList.AddForm(Game.GetFormFromFile(0x11001FA5, "AzarHolsteredWeapons.esp"))
			DTSleep_ArmorExtraPartsList.AddForm(Game.GetFormFromFile(0x11001FA8, "AzarHolsteredWeapons.esp"))
			DTSleep_ArmorExtraPartsList.AddForm(Game.GetFormFromFile(0x11001FAB, "AzarHolsteredWeapons.esp"))
			DTSleep_ArmorExtraPartsList.AddForm(Game.GetFormFromFile(0x11001FAE, "AzarHolsteredWeapons.esp"))
			DTSleep_ArmorExtraPartsList.AddForm(Game.GetFormFromFile(0x11001FB1, "AzarHolsteredWeapons.esp"))
			DTSleep_ArmorExtraPartsList.AddForm(Game.GetFormFromFile(0x11001FB4, "AzarHolsteredWeapons.esp"))
			DTSleep_ArmorExtraPartsList.AddForm(Game.GetFormFromFile(0x11001FB7, "AzarHolsteredWeapons.esp"))
			DTSleep_ArmorExtraPartsList.AddForm(Game.GetFormFromFile(0x11001FBA, "AzarHolsteredWeapons.esp"))
			DTSleep_ArmorExtraPartsList.AddForm(Game.GetFormFromFile(0x11001FBD, "AzarHolsteredWeapons.esp"))
			DTSleep_ArmorExtraPartsList.AddForm(Game.GetFormFromFile(0x11001FC0, "AzarHolsteredWeapons.esp"))
			DTSleep_ArmorExtraPartsList.AddForm(Game.GetFormFromFile(0x11001FC3, "AzarHolsteredWeapons.esp"))
			DTSleep_ArmorExtraPartsList.AddForm(Game.GetFormFromFile(0x11001FC6, "AzarHolsteredWeapons.esp"))
			DTSleep_ArmorExtraPartsList.AddForm(Game.GetFormFromFile(0x11001FC9, "AzarHolsteredWeapons.esp"))
			DTSleep_ArmorExtraPartsList.AddForm(Game.GetFormFromFile(0x11001FCC, "AzarHolsteredWeapons.esp"))
			DTSleep_ArmorExtraPartsList.AddForm(Game.GetFormFromFile(0x11001FCF, "AzarHolsteredWeapons.esp"))
			DTSleep_ArmorExtraPartsList.AddForm(Game.GetFormFromFile(0x11001FD2, "AzarHolsteredWeapons.esp"))
			DTSleep_ArmorExtraPartsList.AddForm(Game.GetFormFromFile(0x11001FD5, "AzarHolsteredWeapons.esp"))
			DTSleep_ArmorExtraPartsList.AddForm(Game.GetFormFromFile(0x11001FD8, "AzarHolsteredWeapons.esp"))
			DTSleep_ArmorExtraPartsList.AddForm(Game.GetFormFromFile(0x11001FDB, "AzarHolsteredWeapons.esp"))
			DTSleep_ArmorExtraPartsList.AddForm(Game.GetFormFromFile(0x11001FDE, "AzarHolsteredWeapons.esp"))
			DTSleep_ArmorExtraPartsList.AddForm(Game.GetFormFromFile(0x11001FE1, "AzarHolsteredWeapons.esp"))
			DTSleep_ArmorExtraPartsList.AddForm(Game.GetFormFromFile(0x11001FE4, "AzarHolsteredWeapons.esp"))
			DTSleep_ArmorExtraPartsList.AddForm(Game.GetFormFromFile(0x11001FE7, "AzarHolsteredWeapons.esp"))
			DTSleep_ArmorExtraPartsList.AddForm(Game.GetFormFromFile(0x11001FEA, "AzarHolsteredWeapons.esp"))
			DTSleep_ArmorExtraPartsList.AddForm(Game.GetFormFromFile(0x11001FED, "AzarHolsteredWeapons.esp"))
			DTSleep_ArmorExtraPartsList.AddForm(Game.GetFormFromFile(0x11001FF0, "AzarHolsteredWeapons.esp"))
			DTSleep_ArmorExtraPartsList.AddForm(Game.GetFormFromFile(0x11001FF3, "AzarHolsteredWeapons.esp"))
			DTSleep_ArmorExtraPartsList.AddForm(Game.GetFormFromFile(0x11001FF6, "AzarHolsteredWeapons.esp"))
			DTSleep_ArmorExtraPartsList.AddForm(Game.GetFormFromFile(0x11001FF9, "AzarHolsteredWeapons.esp"))
			DTSleep_ArmorExtraPartsList.AddForm(Game.GetFormFromFile(0x11001FFC, "AzarHolsteredWeapons.esp"))
			DTSleep_ArmorExtraPartsList.AddForm(Game.GetFormFromFile(0x11001FFF, "AzarHolsteredWeapons.esp"))
			DTSleep_ArmorExtraPartsList.AddForm(Game.GetFormFromFile(0x11002002, "AzarHolsteredWeapons.esp"))
			DTSleep_ArmorExtraPartsList.AddForm(Game.GetFormFromFile(0x11002005, "AzarHolsteredWeapons.esp"))
			DTSleep_ArmorExtraPartsList.AddForm(Game.GetFormFromFile(0x11002008, "AzarHolsteredWeapons.esp"))
			DTSleep_ArmorExtraPartsList.AddForm(Game.GetFormFromFile(0x1100200B, "AzarHolsteredWeapons.esp"))
			DTSleep_ArmorExtraPartsList.AddForm(Game.GetFormFromFile(0x1100200E, "AzarHolsteredWeapons.esp"))
			DTSleep_ArmorExtraPartsList.AddForm(Game.GetFormFromFile(0x11002011, "AzarHolsteredWeapons.esp"))
			DTSleep_ArmorExtraPartsList.AddForm(Game.GetFormFromFile(0x11002014, "AzarHolsteredWeapons.esp"))
			DTSleep_ArmorExtraPartsList.AddForm(Game.GetFormFromFile(0x11002017, "AzarHolsteredWeapons.esp"))
			DTSleep_ArmorExtraPartsList.AddForm(Game.GetFormFromFile(0x1100266E, "AzarHolsteredWeapons.esp"))
			DTSleep_ArmorExtraPartsList.AddForm(Game.GetFormFromFile(0x11002671, "AzarHolsteredWeapons.esp"))
			DTSleep_ArmorExtraPartsList.AddForm(Game.GetFormFromFile(0x1100267F, "AzarHolsteredWeapons.esp"))
			DTSleep_ArmorExtraPartsList.AddForm(Game.GetFormFromFile(0x11002683, "AzarHolsteredWeapons.esp"))
			DTSleep_ArmorExtraPartsList.AddForm(Game.GetFormFromFile(0x11002E20, "AzarHolsteredWeapons.esp"))
			DTSleep_ArmorExtraPartsList.AddForm(Game.GetFormFromFile(0x110035BC, "AzarHolsteredWeapons.esp"))
			
			; more gear
			DTSleep_ArmorExtraPartsList.AddForm(Game.GetFormFromFile(0x11006B3F, "AzarHolsteredWeapons.esp"))
			DTSleep_ArmorExtraPartsList.AddForm(Game.GetFormFromFile(0x11006B42, "AzarHolsteredWeapons.esp"))
			DTSleep_ArmorExtraPartsList.AddForm(Game.GetFormFromFile(0x11006B45, "AzarHolsteredWeapons.esp"))
			DTSleep_ArmorExtraPartsList.AddForm(Game.GetFormFromFile(0x11006B48, "AzarHolsteredWeapons.esp"))
			DTSleep_ArmorExtraPartsList.AddForm(Game.GetFormFromFile(0x11006B4B, "AzarHolsteredWeapons.esp"))
			DTSleep_ArmorExtraPartsList.AddForm(Game.GetFormFromFile(0x11006B4E, "AzarHolsteredWeapons.esp"))
			DTSleep_ArmorExtraPartsList.AddForm(Game.GetFormFromFile(0x11006B51, "AzarHolsteredWeapons.esp"))
			DTSleep_ArmorExtraPartsList.AddForm(Game.GetFormFromFile(0x11006B54, "AzarHolsteredWeapons.esp"))
			DTSleep_ArmorExtraPartsList.AddForm(Game.GetFormFromFile(0x11006B57, "AzarHolsteredWeapons.esp"))
			DTSleep_ArmorExtraPartsList.AddForm(Game.GetFormFromFile(0x11006B5A, "AzarHolsteredWeapons.esp"))
			DTSleep_ArmorExtraPartsList.AddForm(Game.GetFormFromFile(0x110072F6, "AzarHolsteredWeapons.esp"))
		endIf
	endIf
	
	; TeddyBearBackack - no ground object https://www.nexusmods.com/fallout4/mods/10882
	extraArmor = IsPluginActive(0x01001000, "TeddyBearBackPack.esp") as Armor
	if (extraArmor)
		if (!DTSleep_ArmorBackPacksList.HasForm(extraArmor) && !DTSleep_ArmorBackPacksNoGOList.HasForm(extraArmor))
			modCount += 1
			DTSleep_ArmorBackPacksNoGOList.AddForm(extraArmor)
			DTSleep_ArmorBackPacksNoGOList.AddForm(Game.GetFormFromFile(0x01001001, "TeddyBearBackPack.esp") as Armor)
			DTSleep_ArmorBackPacksNoGOList.AddForm(Game.GetFormFromFile(0x01001002, "TeddyBearBackPack.esp") as Armor)
			DTSleep_ArmorBackPacksNoGOList.AddForm(Game.GetFormFromFile(0x01001003, "TeddyBearBackPack.esp") as Armor)
			DTSleep_ArmorBackPacksNoGOList.AddForm(Game.GetFormFromFile(0x01001004, "TeddyBearBackPack.esp") as Armor)
			DTSleep_ArmorBackPacksNoGOList.AddForm(Game.GetFormFromFile(0x01001005, "TeddyBearBackPack.esp") as Armor)
			DTSleep_ArmorBackPacksNoGOList.AddForm(Game.GetFormFromFile(0x01001006, "TeddyBearBackPack.esp") as Armor)
			DTSleep_ArmorBackPacksNoGOList.AddForm(Game.GetFormFromFile(0x01001007, "TeddyBearBackPack.esp") as Armor)
			DTSleep_ArmorBackPacksNoGOList.AddForm(Game.GetFormFromFile(0x01001008, "TeddyBearBackPack.esp") as Armor)
			DTSleep_ArmorBackPacksNoGOList.AddForm(Game.GetFormFromFile(0x01001009, "TeddyBearBackPack.esp") as Armor)
		endIf
	endIf
	
	; Commonwealth Teddy Bears; no ground object https://www.nexusmods.com/fallout4/mods/28995?tab=posts
	extraArmor = IsPluginActive(0x01000F9A, "Backpack_TeddyBearByFeather.esp") as Armor
	if (extraArmor != None)
		if (!DTSleep_ArmorBackPacksList.HasForm(extraArmor) && !DTSleep_ArmorBackPacksNoGOList.HasForm(extraArmor))
			modCount += 1
			DTSleep_ArmorBackPacksNoGOList.AddForm(extraArmor)
			DTSleep_ArmorBackPacksNoGOList.AddForm(Game.GetFormFromFile(0x01000FA0, "Backpack_TeddyBearByFeather.esp") as Armor)
			DTSleep_ArmorBackPacksNoGOList.AddForm(Game.GetFormFromFile(0x0100173D, "Backpack_TeddyBearByFeather.esp") as Armor)
			DTSleep_ArmorBackPacksNoGOList.AddForm(Game.GetFormFromFile(0x01001EDB, "Backpack_TeddyBearByFeather.esp") as Armor)
			DTSleep_ArmorBackPacksNoGOList.AddForm(Game.GetFormFromFile(0x01002677, "Backpack_TeddyBearByFeather.esp") as Armor)
			DTSleep_ArmorBackPacksNoGOList.AddForm(Game.GetFormFromFile(0x0100267A, "Backpack_TeddyBearByFeather.esp") as Armor)
			DTSleep_ArmorBackPacksNoGOList.AddForm(Game.GetFormFromFile(0x0100267D, "Backpack_TeddyBearByFeather.esp") as Armor)
			DTSleep_ArmorBackPacksNoGOList.AddForm(Game.GetFormFromFile(0x01002681, "Backpack_TeddyBearByFeather.esp") as Armor)
			DTSleep_ArmorBackPacksNoGOList.AddForm(Game.GetFormFromFile(0x01002684, "Backpack_TeddyBearByFeather.esp") as Armor)
		endIf
	endIf
			
	; Efera's Shoulder Bags -- no ground object
	extraArmor = IsPluginActive(0x02000827, "EferasShoulderBag.esp") as Armor
	if (extraArmor != None)
		if (!DTSleep_ArmorBackPacksList.HasForm(extraArmor) && !DTSleep_ArmorBackPacksNoGOList.HasForm(extraArmor))
			modCount += 1
			DTSleep_ArmorBackPacksNoGOList.AddForm(extraArmor)
			DTSleep_ArmorBackPacksNoGOList.AddForm(Game.GetFormFromFile(0x02000828, "EferasShoulderBag.esp"))
			DTSleep_ArmorBackPacksNoGOList.AddForm(Game.GetFormFromFile(0x02000829, "EferasShoulderBag.esp"))
			DTSleep_ArmorBackPacksNoGOList.AddForm(Game.GetFormFromFile(0x0200082A, "EferasShoulderBag.esp"))
			DTSleep_ArmorBackPacksNoGOList.AddForm(Game.GetFormFromFile(0x0200082B, "EferasShoulderBag.esp"))
			DTSleep_ArmorBackPacksNoGOList.AddForm(Game.GetFormFromFile(0x0200082C, "EferasShoulderBag.esp"))
			DTSleep_ArmorBackPacksNoGOList.AddForm(Game.GetFormFromFile(0x0200082D, "EferasShoulderBag.esp"))
			DTSleep_ArmorBackPacksNoGOList.AddForm(Game.GetFormFromFile(0x02000837, "EferasShoulderBag.esp"))
		endIf
	endIf
	
	; HitchHiker robe
	extraArmor = IsPluginActive(0x05000F99, "hhgttgBathrobe.esp") as Armor
	if (extraArmor != None)
		if (!DTSleep_SleepAttireMale.HasForm(extraArmor as Form))
			modCount += 1
			DTSleep_SleepAttireMale.AddForm(extraArmor as Form)
			DTSleep_SleepAttireFemale.AddForm(extraArmor as Form)
			DTSleep_ArmorAllExceptionList.AddForm(extraArmor as Form)
		endIf
		if (DTSleep_ArmorJacketsClothingList.HasForm(extraArmor as Form))
			; v2.27 fix for error below
			DTSleep_ArmorJacketsClothingList.RemoveAddedForm(extraArmor as Form)
		endIf
	endIf
	
	; Vtaw Wardrobe 1
	string vtawPlugName = "VtawWardrobe1.esp"
	if (!Game.IsPluginInstalled(vtawPlugName))
		vtawPlugName = "VtawWardrobe1.esl"
	endIf
	Form extraForm  = IsPluginActive(0x0900087D, vtawPlugName)				
	if (extraForm != None)			; v2.27 fix - replaced extraArmor with extraForm
	
		if (!DTSleep_IntimateAttireOKUnderList.HasForm(extraForm))
			modCount += 1
			DTSleep_IntimateAttireOKUnderList.AddForm(extraForm)  ; boots-outfit
			DTSleep_ArmorJacketsClothingList.AddForm(Game.GetFormFromFile(0x0900088F, vtawPlugName))
			DTSleep_ArmorJacketsClothingList.AddForm(Game.GetFormFromFile(0x09000890, vtawPlugName))
			DTSleep_ArmorExtraClothingList.AddForm(Game.GetFormFromFile(0x09000898, vtawPlugName))
		endIf
	endIf
	
	; Vtaw Wardrobe 2
	vtawPlugName = "VtawWardrobe2.esp"
	if (!Game.IsPluginInstalled(vtawPlugName))
		vtawPlugName = "VtawWardrobe2.esl"
	endIf
	extraForm  = IsPluginActive(0x09000FAA, vtawPlugName)	
	if (extraForm != None && !DTSleep_IntimateAttireOKUnderList.HasForm(extraForm))
		modCount += 1
		DTSleep_IntimateAttireOKUnderList.AddForm(extraForm)
	endIf
	
	; Vtaw Wardrobe 4
	vtawPlugName = "VtawWardrobe4.esp"
	extraForm = IsPluginActive(0x0900CF16, vtawPlugName)			
	if (extraForm != None && !DTSleep_IntimateAttireOKUnderList.HasForm(extraForm))
		modCount += 1
		DTSleep_IntimateAttireOKUnderList.AddForm(extraForm)  ; boots-outfit
		DTSleep_IntimateAttireOKUnderList.AddForm(Game.GetFormFromFile(0x09000CF17, vtawPlugName))
		DTSleep_IntimateAttireOKUnderList.AddForm(Game.GetFormFromFile(0x090004588, vtawPlugName))
		DTSleep_ArmorJacketsClothingList.AddForm(Game.GetFormFromFile(0x09000FA7, vtawPlugName))
		DTSleep_ArmorJacketsClothingList.AddForm(Game.GetFormFromFile(0x09000890, vtawPlugName))
		DTSleep_ArmorJacketsClothingList.AddForm(Game.GetFormFromFile(0x0900026E8, vtawPlugName))
		DTSleep_ArmorJacketsClothingList.AddForm(Game.GetFormFromFile(0x0900026EB, vtawPlugName))
	endIf
	
	; Vtaw Utility pack 1
	vtawPlugName = "VtawUtilityPack1.esp"
	extraForm = IsPluginActive(0x09001F29, vtawPlugName)
	if (extraForm != None && !DTSleep_IntimateAttireOKUnderList.HasForm(extraForm))
		modCount += 1
		DTSleep_IntimateAttireOKUnderList.AddForm(extraForm)  ; boots-outfit
		DTSleep_IntimateAttireOKUnderList.AddForm(Game.GetFormFromFile(0x09000361B, vtawPlugName))
		DTSleep_ArmorExtraClothingList.AddForm(Game.GetFormFromFile(0x0900173E, vtawPlugName))			; Top-Mid in Beard slot
		DTSleep_ArmorExtraClothingList.AddForm(Game.GetFormFromFile(0x09006423, vtawPlugName))			; onePiece in beard slot
		DTSleep_ArmorExtraClothingList.AddForm(Game.GetFormFromFile(0x0900B0D9, vtawPlugName))			; pantyhose in beard slot
		DTSleep_ArmorExtraClothingList.AddForm(Game.GetFormFromFile(0x0900B0FA, vtawPlugName))			; pantyhose
		DTSleep_ArmorChokerList.AddForm(Game.GetFormFromFile(0x09000830B, vtawPlugName))
	endIf
	
	; Oakley M glasses
	string oakleyName = "OakleyMFrame.esp"
	if (!Game.IsPluginInstalled(oakleyName))
		oakleyName = "OakleyMFrame.esl"
	endIf
	extraForm = IsPluginActive(0x09000802, oakleyName)
	if (extraForm != None && !DTSleep_ArmorGlassesList.HasForm(extraForm))
		modCount += 1
		DTSleep_ArmorGlassesList.AddForm(extraForm)
	endIf
	
	; DX Vintage Summer suit   - v2.71
	string dxVintageName = "DX_Vintage_Summer.esp"
	extraForm = IsPluginActive(0x090194FC, dxVintageName)						; glasses
	if (extraForm != None && !DTSleep_ArmorGlassesList.HasForm(extraForm))
		modCount += 1
		DTSleep_ArmorGlassesList.AddForm(extraForm)
		DTSleep_ArmorHatHelmList.AddForm(Game.GetFormFromFile(0x09019C9A, dxVintageName))
		DTSleep_ArmorJewelry58List.AddForm(Game.GetFormFromFile(0x0901BB0A, dxVintageName))		; necklace
		DTSleep_ArmorExtraClothingList.AddForm(Game.GetFormFromFile(0x0901A436, dxVintageName)) ; duck
		; new lists for v2.71
		DTSleep_ArmorJewelry56List.AddForm(Game.GetFormFromFile(0x0901ABD2, dxVintageName))		; bracelet
		DTSleep_ArmorJewelry57List.AddForm(Game.GetFormFromFile(0x0901B36E, dxVintageName))		; anklet
	endIf
	
	
	Debug.Trace(myScriptName + " =====================================================================")
	Debug.Trace(myScriptName + "            ------- end one-time / by-request check ---------- ")
	Debug.Trace(myScriptName + " =====================================================================")
	
	return modCount
EndFunction

bool Function CheckGameSettings()
	
	; social timer and distances
	; see "You Talk Too Much" page for 50% less-talk values at https://www.nexusmods.com/fallout4/mods/10570
	; 25% less-talk YTTM values:
	; minGreetDist = 75, socChance = 75, commWait = 40, socTimerMin = 45
	;
	float minGreetDist = Game.GetGameSettingFloat("fAIMinGreetingDistance")
	;float socChance = Game.GetGameSettingFloat("fAISocialchanceForConversation")
	;float socChanceInt = Game.GetGameSettingFloat("fAISocialchanceForConversationInterior")
	;float commWait = Game.GetGameSettingFloat("fAICommentWaitingForPlayerInput")	; how long to wait for player to answer
	;float socTimerMin = Game.GetGameSettingFloat("fAISocialTimerForConversationsMin")
	
	if (minGreetDist > 0.1 && minGreetDist <= 65.0)
		; for intimate animations our characters positioned 70 apart, 
		; - this meets YTTM 50% less-talk selection
		
		(DTSConditionals as DTSleep_Conditionals).HasGamesetReducedConv = true
	else
		(DTSConditionals as DTSleep_Conditionals).HasGamesetReducedConv = false
	endIf
	
	if (Debug.GetPlatformName() as bool)
		(DTSConditionals as DTSleep_Conditionals).ImaPCMod = true
	else
		(DTSConditionals as DTSleep_Conditionals).ImaPCMod = false
		if (DTSleep_AdultContentOn.GetValue() > 0.0 || DTSleep_SIXPatch.GetValue() >= 3.0)

			if (DTSleep_AdultPlatformWarnMsg.Show() >= 1)
				Utility.Wait(0.33)
				
				return false
			endIf
		endIf
	endIf
	
	; check for old main script
	if (SleepQuestScript.ChanceForIntimateSceneAdjDance(500) != 2413)
	
		if (DTSleep_BadVersWarnMsg.Show() >= 1)
			Utility.Wait(0.33)
			
			return false
		endIf
		
	endIf
	
	return true
EndFunction

bool Function IsChildPluginActive()
	if (Game.IsPluginInstalled("Custom Playable Children.esp") || Game.IsPluginInstalled("Playable Children.esp"))
		return true
	elseIf (Game.IsPluginInstalled("AnimeRace_Loli.esp"))
		return true
	endIf
	return false
EndFunction

Form Function IsPluginActive(int formID, string pluginName)
	if (Game.IsPluginInstalled(pluginName))
		; from CreationKit.com: "Note the top most byte in the given ID is unused so 0000ABCD works as well as 0400ABCD"
		Form formFound = Game.GetFormFromFile(formID, pluginName)
		if (formFound != None)
			Debug.Trace(myScriptName + " found plugin: " + pluginName)
			return formFound 
		endIf
	endIf
	
	return None
EndFunction

Function LoadLeitoAnimForms(string pluginName)
	Idle leitoIdle = Game.GetFormFromFile(0x0900173F, pluginName) as Idle
	if (!DTSleep_LeitoCowgirl1A1List.HasForm(leitoIdle))
		; Cowgirl 1 regular
		DTSleep_LeitoCowgirl1A1List.AddForm(leitoIdle)
		DTSleep_LeitoCowgirl1A1List.AddForm(Game.GetFormFromFile(0x09002E27, pluginName))
		DTSleep_LeitoCowgirl1A1List.AddForm(Game.GetFormFromFile(0x09002E28, pluginName))
		DTSleep_LeitoCowgirl1A1List.AddForm(Game.GetFormFromFile(0x09002E29, pluginName))
		DTSleep_LeitoCowgirl1A2List.AddForm(Game.GetFormFromFile(0x09001740, pluginName))
		DTSleep_LeitoCowgirl1A2List.AddForm(Game.GetFormFromFile(0x09002E2A, pluginName))
		DTSleep_LeitoCowgirl1A2List.AddForm(Game.GetFormFromFile(0x09002E2B, pluginName))
		DTSleep_LeitoCowgirl1A2List.AddForm(Game.GetFormFromFile(0x09002E2C, pluginName))
		
		; Cowgirl 2-4
		DTSleep_LeitoCowgirl2A1List.AddForm(Game.GetFormFromFile(0x09005C34, pluginName))
		DTSleep_LeitoCowgirl2A1List.AddForm(Game.GetFormFromFile(0x09005C35, pluginName))
		DTSleep_LeitoCowgirl2A1List.AddForm(Game.GetFormFromFile(0x09005C36, pluginName))
		DTSleep_LeitoCowgirl2A1List.AddForm(Game.GetFormFromFile(0x09005C37, pluginName))
		DTSleep_LeitoCowgirl2A2List.AddForm(Game.GetFormFromFile(0x09005C38, pluginName))
		DTSleep_LeitoCowgirl2A2List.AddForm(Game.GetFormFromFile(0x09005C39, pluginName))
		DTSleep_LeitoCowgirl2A2List.AddForm(Game.GetFormFromFile(0x09005C3A, pluginName))
		DTSleep_LeitoCowgirl2A2List.AddForm(Game.GetFormFromFile(0x09005C3B, pluginName))
		DTSleep_LeitoCowgirl3A1List.AddForm(Game.GetFormFromFile(0x090063DF, pluginName))
		DTSleep_LeitoCowgirl3A1List.AddForm(Game.GetFormFromFile(0x090063E0, pluginName))
		DTSleep_LeitoCowgirl3A1List.AddForm(Game.GetFormFromFile(0x090063E1, pluginName))
		DTSleep_LeitoCowgirl3A1List.AddForm(Game.GetFormFromFile(0x090063E2, pluginName))
		DTSleep_LeitoCowgirl3A2List.AddForm(Game.GetFormFromFile(0x090063E3, pluginName))
		DTSleep_LeitoCowgirl3A2List.AddForm(Game.GetFormFromFile(0x090063E4, pluginName))
		DTSleep_LeitoCowgirl3A2List.AddForm(Game.GetFormFromFile(0x090063E5, pluginName))
		DTSleep_LeitoCowgirl3A2List.AddForm(Game.GetFormFromFile(0x090063E6, pluginName))
		DTSleep_LeitoCowgirl4A1List.AddForm(Game.GetFormFromFile(0x0900A899, pluginName))
		DTSleep_LeitoCowgirl4A1List.AddForm(Game.GetFormFromFile(0x0900A89A, pluginName))
		DTSleep_LeitoCowgirl4A1List.AddForm(Game.GetFormFromFile(0x0900A89B, pluginName))
		DTSleep_LeitoCowgirl4A1List.AddForm(Game.GetFormFromFile(0x0900A89C, pluginName))
		DTSleep_LeitoCowgirl4A2List.AddForm(Game.GetFormFromFile(0x0900A89D, pluginName))
		DTSleep_LeitoCowgirl4A2List.AddForm(Game.GetFormFromFile(0x0900A89E, pluginName))
		DTSleep_LeitoCowgirl4A2List.AddForm(Game.GetFormFromFile(0x0900A89F, pluginName))
		DTSleep_LeitoCowgirl4A2List.AddForm(Game.GetFormFromFile(0x0900A8A0, pluginName))
		; Cowgirl Reverse 1-2
		DTSleep_LeitoCowgirlRev1A1List.AddForm(Game.GetFormFromFile(0x09006B82, pluginName))
		DTSleep_LeitoCowgirlRev1A1List.AddForm(Game.GetFormFromFile(0x09006B83, pluginName))
		DTSleep_LeitoCowgirlRev1A1List.AddForm(Game.GetFormFromFile(0x09006B84, pluginName))
		DTSleep_LeitoCowgirlRev1A1List.AddForm(Game.GetFormFromFile(0x09006B85, pluginName))
		DTSleep_LeitoCowgirlRev1A2List.AddForm(Game.GetFormFromFile(0x09006B86, pluginName))
		DTSleep_LeitoCowgirlRev1A2List.AddForm(Game.GetFormFromFile(0x09006B87, pluginName))
		DTSleep_LeitoCowgirlRev1A2List.AddForm(Game.GetFormFromFile(0x09006B88, pluginName))
		DTSleep_LeitoCowgirlRev1A2List.AddForm(Game.GetFormFromFile(0x09006B89, pluginName))
		DTSleep_LeitoCowgirlRev2A1List.AddForm(Game.GetFormFromFile(0x0900732E, pluginName))
		DTSleep_LeitoCowgirlRev2A1List.AddForm(Game.GetFormFromFile(0x0900732F, pluginName))
		DTSleep_LeitoCowgirlRev2A1List.AddForm(Game.GetFormFromFile(0x09007330, pluginName))
		DTSleep_LeitoCowgirlRev2A1List.AddForm(Game.GetFormFromFile(0x09007331, pluginName))
		DTSleep_LeitoCowgirlRev2A2List.AddForm(Game.GetFormFromFile(0x09007332, pluginName))
		DTSleep_LeitoCowgirlRev2A2List.AddForm(Game.GetFormFromFile(0x09007333, pluginName))
		DTSleep_LeitoCowgirlRev2A2List.AddForm(Game.GetFormFromFile(0x09007334, pluginName))
		DTSleep_LeitoCowgirlRev2A2List.AddForm(Game.GetFormFromFile(0x09007335, pluginName))
		
		; Doggy 1-2
		DTSleep_LeitoDoggy1A1List.AddForm(Game.GetFormFromFile(0x09001739, pluginName))
		DTSleep_LeitoDoggy1A1List.AddForm(Game.GetFormFromFile(0x09001EDE, pluginName))
		DTSleep_LeitoDoggy1A1List.AddForm(Game.GetFormFromFile(0x09001EDF, pluginName))
		DTSleep_LeitoDoggy1A1List.AddForm(Game.GetFormFromFile(0x09001EE0, pluginName))
		DTSleep_LeitoDoggy1A2List.AddForm(Game.GetFormFromFile(0x09001738, pluginName))
		DTSleep_LeitoDoggy1A2List.AddForm(Game.GetFormFromFile(0x09001EE1, pluginName))
		DTSleep_LeitoDoggy1A2List.AddForm(Game.GetFormFromFile(0x09001EE2, pluginName))
		DTSleep_LeitoDoggy1A2List.AddForm(Game.GetFormFromFile(0x09001EE3, pluginName))
		DTSleep_LeitoDoggy2A1List.AddForm(Game.GetFormFromFile(0x09002E35, pluginName))
		DTSleep_LeitoDoggy2A1List.AddForm(Game.GetFormFromFile(0x09002E36, pluginName))
		DTSleep_LeitoDoggy2A1List.AddForm(Game.GetFormFromFile(0x09002E37, pluginName))
		DTSleep_LeitoDoggy2A1List.AddForm(Game.GetFormFromFile(0x09002E38, pluginName))
		DTSleep_LeitoDoggy2A2List.AddForm(Game.GetFormFromFile(0x09002E39, pluginName))
		DTSleep_LeitoDoggy2A2List.AddForm(Game.GetFormFromFile(0x09002E3A, pluginName))
		DTSleep_LeitoDoggy2A2List.AddForm(Game.GetFormFromFile(0x09002E3B, pluginName))
		DTSleep_LeitoDoggy2A2List.AddForm(Game.GetFormFromFile(0x09002E3C, pluginName))
		; Missionary 1-2
		DTSleep_LeitoMissionary1A1List.AddForm(Game.GetFormFromFile(0x09004C8D, pluginName))
		DTSleep_LeitoMissionary1A1List.AddForm(Game.GetFormFromFile(0x09002682, pluginName))
		DTSleep_LeitoMissionary1A1List.AddForm(Game.GetFormFromFile(0x09002683, pluginName))
		DTSleep_LeitoMissionary1A1List.AddForm(Game.GetFormFromFile(0x09002684, pluginName))
		DTSleep_LeitoMissionary1A2List.AddForm(Game.GetFormFromFile(0x09004C8E, pluginName))
		DTSleep_LeitoMissionary1A2List.AddForm(Game.GetFormFromFile(0x09002685, pluginName))
		DTSleep_LeitoMissionary1A2List.AddForm(Game.GetFormFromFile(0x09002686, pluginName))
		DTSleep_LeitoMissionary1A2List.AddForm(Game.GetFormFromFile(0x09002687, pluginName))
		DTSleep_LeitoMissionary2A1List.AddForm(Game.GetFormFromFile(0x09002E2D, pluginName))
		DTSleep_LeitoMissionary2A1List.AddForm(Game.GetFormFromFile(0x09002E2E, pluginName))
		DTSleep_LeitoMissionary2A1List.AddForm(Game.GetFormFromFile(0x09002E2F, pluginName))
		DTSleep_LeitoMissionary2A1List.AddForm(Game.GetFormFromFile(0x09002E30, pluginName))
		DTSleep_LeitoMissionary2A2List.AddForm(Game.GetFormFromFile(0x09002E31, pluginName))
		DTSleep_LeitoMissionary2A2List.AddForm(Game.GetFormFromFile(0x09002E32, pluginName))
		DTSleep_LeitoMissionary2A2List.AddForm(Game.GetFormFromFile(0x09002E33, pluginName))
		DTSleep_LeitoMissionary2A2List.AddForm(Game.GetFormFromFile(0x09002E34, pluginName))
		; Spoon
		DTSleep_LeitoSpoonA1List.AddForm(Game.GetFormFromFile(0x09004CEB, pluginName))
		DTSleep_LeitoSpoonA1List.AddForm(Game.GetFormFromFile(0x09004CEC, pluginName))
		DTSleep_LeitoSpoonA1List.AddForm(Game.GetFormFromFile(0x09004CED, pluginName))
		DTSleep_LeitoSpoonA1List.AddForm(Game.GetFormFromFile(0x09004CEE, pluginName))
		DTSleep_LeitoSpoonA2List.AddForm(Game.GetFormFromFile(0x09004CEF, pluginName))
		DTSleep_LeitoSpoonA2List.AddForm(Game.GetFormFromFile(0x09004CF0, pluginName))
		DTSleep_LeitoSpoonA2List.AddForm(Game.GetFormFromFile(0x09004CF1, pluginName))
		DTSleep_LeitoSpoonA2List.AddForm(Game.GetFormFromFile(0x09004CF2, pluginName))
		; blowjob
		DTSleep_LeitoBlowjobA1List.AddForm(Game.GetFormFromFile(0x09004CB2, pluginName))
		DTSleep_LeitoBlowjobA1List.AddForm(Game.GetFormFromFile(0x09004CB3, pluginName))
		DTSleep_LeitoBlowjobA1List.AddForm(Game.GetFormFromFile(0x09004CB4, pluginName))
		DTSleep_LeitoBlowjobA1List.AddForm(Game.GetFormFromFile(0x09004CB5, pluginName))
		DTSleep_LeitoBlowjobA2List.AddForm(Game.GetFormFromFile(0x09004CB6, pluginName))
		DTSleep_LeitoBlowjobA2List.AddForm(Game.GetFormFromFile(0x09004CB7, pluginName))
		DTSleep_LeitoBlowjobA2List.AddForm(Game.GetFormFromFile(0x09004CB8, pluginName))
		DTSleep_LeitoBlowjobA2List.AddForm(Game.GetFormFromFile(0x09004CB9, pluginName))
		; standing doggy 1
		DTSleep_LeitoStandDoggy1A1List.AddForm(Game.GetFormFromFile(0x09007AD1, pluginName))
		DTSleep_LeitoStandDoggy1A1List.AddForm(Game.GetFormFromFile(0x09007AD2, pluginName))
		DTSleep_LeitoStandDoggy1A1List.AddForm(Game.GetFormFromFile(0x09007AD3, pluginName))
		DTSleep_LeitoStandDoggy1A1List.AddForm(Game.GetFormFromFile(0x09007AD4, pluginName))
		DTSleep_LeitoStandDoggy1A2List.AddForm(Game.GetFormFromFile(0x09007AD5, pluginName))
		DTSleep_LeitoStandDoggy1A2List.AddForm(Game.GetFormFromFile(0x09007AD6, pluginName))
		DTSleep_LeitoStandDoggy1A2List.AddForm(Game.GetFormFromFile(0x09007AD7, pluginName))
		DTSleep_LeitoStandDoggy1A2List.AddForm(Game.GetFormFromFile(0x09007AD8, pluginName))
		; standing doggy 2
		DTSleep_LeitoStandDoggy2A1List.AddForm(Game.GetFormFromFile(0x09007AD9, pluginName))
		DTSleep_LeitoStandDoggy2A1List.AddForm(Game.GetFormFromFile(0x09007ADA, pluginName))
		DTSleep_LeitoStandDoggy2A1List.AddForm(Game.GetFormFromFile(0x09007ADB, pluginName))
		DTSleep_LeitoStandDoggy2A1List.AddForm(Game.GetFormFromFile(0x09007ADC, pluginName))
		DTSleep_LeitoStandDoggy2A2List.AddForm(Game.GetFormFromFile(0x09007ADD, pluginName))
		DTSleep_LeitoStandDoggy2A2List.AddForm(Game.GetFormFromFile(0x09007ADE, pluginName))
		DTSleep_LeitoStandDoggy2A2List.AddForm(Game.GetFormFromFile(0x09007ADF, pluginName))
		DTSleep_LeitoStandDoggy2A2List.AddForm(Game.GetFormFromFile(0x09007AE0, pluginName))
		; carry
		DTSleep_LeitoCarryA1List.AddForm(Game.GetFormFromFile(0x09004503, pluginName))
		DTSleep_LeitoCarryA1List.AddForm(Game.GetFormFromFile(0x09004504, pluginName))
		DTSleep_LeitoCarryA1List.AddForm(Game.GetFormFromFile(0x09004505, pluginName))
		DTSleep_LeitoCarryA1List.AddForm(Game.GetFormFromFile(0x09004506, pluginName))
		DTSleep_LeitoCarryA2List.AddForm(Game.GetFormFromFile(0x09004507, pluginName))
		DTSleep_LeitoCarryA2List.AddForm(Game.GetFormFromFile(0x09004508, pluginName))
		DTSleep_LeitoCarryA2List.AddForm(Game.GetFormFromFile(0x09004509, pluginName))
		DTSleep_LeitoCarryA2List.AddForm(Game.GetFormFromFile(0x0900450A, pluginName))
		
	endIf
endFunction

Function LoadLeitoCreatureAnimForms(string pluginName)

	Idle leitoIdle = Game.GetFormFromFile(0x09001EDD, pluginName) as Idle
	if (!DTSleep_LeitoStrongMaleList.HasForm(leitoIdle))
	
		Debug.Trace(myScriptName + " adding Leito Canine and Supermutant idles")
		DTSleep_LeitoStrongMaleList.AddForm(leitoIdle)
		DTSleep_LeitoStrongFemaleList.AddForm(Game.GetFormFromFile(0x09001EDC, pluginName))  ; Carry
		DTSleep_LeitoStrongMaleList.AddForm(Game.GetFormFromFile(0x09004C8C, pluginName))    ; Reverse Carry
		DTSleep_LeitoStrongFemaleList.AddForm(Game.GetFormFromFile(0x09004C8F, pluginName))
		DTSleep_LeitoStrongMaleList.AddForm(Game.GetFormFromFile(0x0900542E, pluginName))	  ; Stand Doggy
		DTSleep_LeitoStrongFemaleList.AddForm(Game.GetFormFromFile(0x0900542B, pluginName))
		DTSleep_LeitoStrongMaleList.AddForm(Game.GetFormFromFile(0x0900542F, pluginName))	 ; Stand Sideways
		DTSleep_LeitoStrongFemaleList.AddForm(Game.GetFormFromFile(0x0900542C, pluginName))
		
	endIf

endFunction

Function RevertLeitoLists()
	if (DTSleep_LeitoBlowjobA1List.GetSize() > 0)
		
		DTSleep_LeitoBlowjobA1List.Revert()
		DTSleep_LeitoBlowjobA2List.Revert()
		DTSleep_LeitoCarryA1List.Revert()
		DTSleep_LeitoCarryA2List.Revert()
		DTSleep_LeitoCowgirl1A1List.Revert()
		DTSleep_LeitoCowgirl1A2List.Revert()
		DTSleep_LeitoCowgirl2A1List.Revert()
		DTSleep_LeitoCowgirl2A2List.Revert()
		DTSleep_LeitoCowgirl3A1List.Revert()
		DTSleep_LeitoCowgirl3A2List.Revert()
		DTSleep_LeitoCowgirl4A1List.Revert()
		DTSleep_LeitoCowgirl4A2List.Revert()
		DTSleep_LeitoCowgirlRev1A1List.Revert()
		DTSleep_LeitoCowgirlRev1A2List.Revert()
		DTSleep_LeitoCowgirlRev2A1List.Revert()
		DTSleep_LeitoCowgirlRev2A2List.Revert()
		DTSleep_LeitoDoggy1A1List.Revert()
		DTSleep_LeitoDoggy1A2List.Revert()
		DTSleep_LeitoDoggy2A1List.Revert()
		DTSleep_LeitoDoggy2A2List.Revert()
		DTSleep_LeitoMissionary1A1List.Revert()
		DTSleep_LeitoMissionary1A2List.Revert()
		DTSleep_LeitoMissionary2A1List.Revert()
		DTSleep_LeitoMissionary2A2List.Revert()
		DTSleep_LeitoSpoonA1List.Revert()
		DTSleep_LeitoSpoonA2List.Revert()
		DTSleep_LeitoStandDoggy1A1List.Revert()
		DTSleep_LeitoStandDoggy1A2List.Revert()
		DTSleep_LeitoStandDoggy2A1List.Revert()
		DTSleep_LeitoStandDoggy2A2List.Revert()
		
		
	endIf
	RevertLeitoCreatureLists()
endFunction

Function RevertLeitoCreatureLists()
	; creature
	DTSleep_LeitoStrongFemaleList.Revert()
	DTSleep_LeitoStrongMaleList.Revert()
	DTSleep_LeitoCanine2DogList.Revert()
	DTSleep_LeitoCanine2FemaleList.Revert()
	DTSleep_LeitoCanineDogList.Revert()
	DTSleep_LeitoCanineFemaleList.Revert()
endFunction

Function LoadNukaWorldOuterArmors()
	Debug.Trace(myScriptName + " loading Nuka-World armor outer lists")
	DTSleep_ArmorTorsoList.AddForm(Game.GetFormFromFile(0x06026BAB, "DLCNukaWorld.esm"))
	DTSleep_ArmorLegRightList.AddForm(Game.GetFormFromFile(0x06026BAD, "DLCNukaWorld.esm"))
	DTSleep_ArmorLegLeftList.AddForm(Game.GetFormFromFile(0x06026BAF, "DLCNukaWorld.esm"))
	DTSleep_ArmorArmRightList.AddForm(Game.GetFormFromFile(0x06026BB2, "DLCNukaWorld.esm"))
	DTSleep_ArmorArmLeftList.AddForm(Game.GetFormFromFile(0x06026BB4, "DLCNukaWorld.esm"))
	
	DTSleep_ArmorTorsoList.AddForm(Game.GetFormFromFile(0x06026BB8, "DLCNukaWorld.esm"))
	DTSleep_ArmorLegRightList.AddForm(Game.GetFormFromFile(0x06026BB9, "DLCNukaWorld.esm"))
	DTSleep_ArmorLegRightList.AddForm(Game.GetFormFromFile(0x06026BBA, "DLCNukaWorld.esm"))
	DTSleep_ArmorLegLeftList.AddForm(Game.GetFormFromFile(0x06026BBB, "DLCNukaWorld.esm"))
	DTSleep_ArmorLegLeftList.AddForm(Game.GetFormFromFile(0x06026BBC, "DLCNukaWorld.esm"))
	DTSleep_ArmorArmRightList.AddForm(Game.GetFormFromFile(0x06026BBE, "DLCNukaWorld.esm"))
	DTSleep_ArmorArmRightList.AddForm(Game.GetFormFromFile(0x06026BBF, "DLCNukaWorld.esm"))
	DTSleep_ArmorArmLeftList.AddForm(Game.GetFormFromFile(0x06026BC0, "DLCNukaWorld.esm"))
	DTSleep_ArmorArmLeftList.AddForm(Game.GetFormFromFile(0x06026BC1, "DLCNukaWorld.esm"))
	
	DTSleep_ArmorTorsoList.AddForm(Game.GetFormFromFile(0x06027414, "DLCNukaWorld.esm"))
	DTSleep_ArmorLegRightList.AddForm(Game.GetFormFromFile(0x06027412, "DLCNukaWorld.esm"))
	DTSleep_ArmorLegLeftList.AddForm(Game.GetFormFromFile(0x06027410, "DLCNukaWorld.esm"))
	DTSleep_ArmorArmRightList.AddForm(Game.GetFormFromFile(0x0602740D, "DLCNukaWorld.esm"))
	DTSleep_ArmorArmLeftList.AddForm(Game.GetFormFromFile(0x0602740B, "DLCNukaWorld.esm"))
	
	DTSleep_ArmorTorsoList.AddForm(Game.GetFormFromFile(0x0602741E, "DLCNukaWorld.esm"))
	DTSleep_ArmorLegRightList.AddForm(Game.GetFormFromFile(0x0602741C, "DLCNukaWorld.esm"))
	DTSleep_ArmorLegLeftList.AddForm(Game.GetFormFromFile(0x0602741A, "DLCNukaWorld.esm"))
	DTSleep_ArmorArmRightList.AddForm(Game.GetFormFromFile(0x06027417, "DLCNukaWorld.esm"))
	DTSleep_ArmorArmLeftList.AddForm(Game.GetFormFromFile(0x06027415, "DLCNukaWorld.esm"))
	
	DTSleep_ArmorTorsoList.AddForm(Game.GetFormFromFile(0x0602873B, "DLCNukaWorld.esm"))
	DTSleep_ArmorLegRightList.AddForm(Game.GetFormFromFile(0x06028736, "DLCNukaWorld.esm"))
	DTSleep_ArmorLegRightList.AddForm(Game.GetFormFromFile(0x06028737, "DLCNukaWorld.esm"))
	DTSleep_ArmorLegLeftList.AddForm(Game.GetFormFromFile(0x06028735, "DLCNukaWorld.esm"))
	DTSleep_ArmorLegLeftList.AddForm(Game.GetFormFromFile(0x06028734, "DLCNukaWorld.esm"))
	DTSleep_ArmorArmRightList.AddForm(Game.GetFormFromFile(0x06028733, "DLCNukaWorld.esm"))
	DTSleep_ArmorArmRightList.AddForm(Game.GetFormFromFile(0x06028732, "DLCNukaWorld.esm"))
	DTSleep_ArmorArmLeftList.AddForm(Game.GetFormFromFile(0x06028731, "DLCNukaWorld.esm"))
	DTSleep_ArmorArmLeftList.AddForm(Game.GetFormFromFile(0x06028730, "DLCNukaWorld.esm"))
	
	DTSleep_ArmorTorsoList.AddForm(Game.GetFormFromFile(0x06028743, "DLCNukaWorld.esm"))
	DTSleep_ArmorLegRightList.AddForm(Game.GetFormFromFile(0x06028741, "DLCNukaWorld.esm"))
	DTSleep_ArmorLegLeftList.AddForm(Game.GetFormFromFile(0x0602873F, "DLCNukaWorld.esm"))
	DTSleep_ArmorArmRightList.AddForm(Game.GetFormFromFile(0x0602873B, "DLCNukaWorld.esm"))
	DTSleep_ArmorArmLeftList.AddForm(Game.GetFormFromFile(0x06028739, "DLCNukaWorld.esm"))
	
	DTSleep_ArmorLegRightList.AddForm(Game.GetFormFromFile(0x0603B555, "DLCNukaWorld.esm"))
	DTSleep_ArmorLegLeftList.AddForm(Game.GetFormFromFile(0x0603B556, "DLCNukaWorld.esm"))
	DTSleep_ArmorArmRightList.AddForm(Game.GetFormFromFile(0x0603B558, "DLCNukaWorld.esm"))
	DTSleep_ArmorArmLeftList.AddForm(Game.GetFormFromFile(0x0603B559, "DLCNukaWorld.esm"))
	
	DTSleep_ArmorTorsoList.AddForm(Game.GetFormFromFile(0x0603B8AE, "DLCNukaWorld.esm"))
	DTSleep_ArmorArmRightList.AddForm(Game.GetFormFromFile(0x0603B8AB, "DLCNukaWorld.esm"))
	DTSleep_ArmorArmLeftList.AddForm(Game.GetFormFromFile(0x0603B8AA, "DLCNukaWorld.esm"))	
endFunction

Function LoadHelmetsNukaWorld()
	DTSleep_ArmorHatHelmList.AddForm(Game.GetFormFromFile(0x06026BB0, "DLCNukaWorld.esm"))
	DTSleep_ArmorHatHelmList.AddForm(Game.GetFormFromFile(0x06026BB5, "DLCNukaWorld.esm"))
	DTSleep_ArmorHatHelmList.AddForm(Game.GetFormFromFile(0x06026BB6, "DLCNukaWorld.esm"))
	DTSleep_ArmorHatHelmList.AddForm(Game.GetFormFromFile(0x06026BB7, "DLCNukaWorld.esm"))
	DTSleep_ArmorHatHelmList.AddForm(Game.GetFormFromFile(0x06027419, "DLCNukaWorld.esm"))
	DTSleep_ArmorHatHelmList.AddForm(Game.GetFormFromFile(0x06027705, "DLCNukaWorld.esm"))
	DTSleep_ArmorHatHelmList.AddForm(Game.GetFormFromFile(0x06027706, "DLCNukaWorld.esm"))
	DTSleep_ArmorHatHelmList.AddForm(Game.GetFormFromFile(0x06027707, "DLCNukaWorld.esm"))
	DTSleep_ArmorHatHelmList.AddForm(Game.GetFormFromFile(0x0602770C, "DLCNukaWorld.esm"))
	DTSleep_ArmorHatHelmList.AddForm(Game.GetFormFromFile(0x0602770D, "DLCNukaWorld.esm"))
	DTSleep_ArmorHatHelmList.AddForm(Game.GetFormFromFile(0x0602770E, "DLCNukaWorld.esm"))
	DTSleep_ArmorHatHelmList.AddForm(Game.GetFormFromFile(0x060296B8, "DLCNukaWorld.esm"))
	DTSleep_ArmorHatHelmList.AddForm(Game.GetFormFromFile(0x0603407D, "DLCNukaWorld.esm"))
	DTSleep_ArmorHatHelmList.AddForm(Game.GetFormFromFile(0x0603B557, "DLCNukaWorld.esm"))
	DTSleep_ArmorHatHelmList.AddForm(Game.GetFormFromFile(0x060417D0, "DLCNukaWorld.esm"))
	DTSleep_ArmorHatHelmList.AddForm(Game.GetFormFromFile(0x0604231F, "DLCNukaWorld.esm"))
	DTSleep_ArmorHatHelmList.AddForm(Game.GetFormFromFile(0x06042322, "DLCNukaWorld.esm"))
	DTSleep_ArmorHatHelmList.AddForm(Game.GetFormFromFile(0x06042323, "DLCNukaWorld.esm")) 	; black cowboy hat
endFunction

Function LoadHelmetsFarHarbor()
	Form helmet = Game.GetFormFromFile(0x03009E58, "DLCCoast.esm") 
	if (helmet != None && !DTSleep_ArmorHatHelmList.HasForm(helmet))
		DTSleep_ArmorHatHelmList.AddForm(helmet)
		DTSleep_ArmorHatHelmList.AddForm(Game.GetFormFromFile(0x0300914B, "DLCCoast.esm"))
		DTSleep_ArmorHatHelmList.AddForm(Game.GetFormFromFile(0x0300914C, "DLCCoast.esm"))
		DTSleep_ArmorHatHelmList.AddForm(Game.GetFormFromFile(0x030247C5, "DLCCoast.esm"))
		DTSleep_ArmorHatHelmList.AddForm(Game.GetFormFromFile(0x030391E8, "DLCCoast.esm"))
		DTSleep_ArmorHatHelmList.AddForm(Game.GetFormFromFile(0x0303A557, "DLCCoast.esm"))
		DTSleep_ArmorHatHelmList.AddForm(Game.GetFormFromFile(0x0304262B, "DLCCoast.esm"))
		DTSleep_ArmorHatHelmList.AddForm(Game.GetFormFromFile(0x03046024, "DLCCoast.esm"))
		DTSleep_ArmorHatHelmList.AddForm(Game.GetFormFromFile(0x0304B9B3, "DLCCoast.esm"))
		DTSleep_ArmorHatHelmList.AddForm(Game.GetFormFromFile(0x0304FA89, "DLCCoast.esm"))
		DTSleep_ArmorHatHelmList.AddForm(Game.GetFormFromFile(0x030540FC, "DLCCoast.esm"))	
	endIf
endFunction

Function LoadHelmetsRobot()
	Form helmet = Game.GetFormFromFile(0x03009E58, "DLCCoast.esm") 	; marine helmet
	if (helmet != None && !DTSleep_ArmorHatHelmList.HasForm(helmet))
		DTSleep_ArmorHatHelmList.AddForm(helmet)
		DTSleep_ArmorHatHelmList.AddForm(Game.GetFormFromFile(0x0300914B, "DLCCoast.esm"))
		DTSleep_ArmorHatHelmList.AddForm(Game.GetFormFromFile(0x0300914C, "DLCCoast.esm"))
		DTSleep_ArmorHatHelmList.AddForm(Game.GetFormFromFile(0x030247C5, "DLCCoast.esm"))
		DTSleep_ArmorHatHelmList.AddForm(Game.GetFormFromFile(0x030391E8, "DLCCoast.esm"))
		DTSleep_ArmorHatHelmList.AddForm(Game.GetFormFromFile(0x0303A557, "DLCCoast.esm"))
		DTSleep_ArmorHatHelmList.AddForm(Game.GetFormFromFile(0x0304262B, "DLCCoast.esm"))
		DTSleep_ArmorHatHelmList.AddForm(Game.GetFormFromFile(0x03046024, "DLCCoast.esm"))
		DTSleep_ArmorHatHelmList.AddForm(Game.GetFormFromFile(0x0304B9B3, "DLCCoast.esm"))
		DTSleep_ArmorHatHelmList.AddForm(Game.GetFormFromFile(0x0304FA89, "DLCCoast.esm"))
		DTSleep_ArmorHatHelmList.AddForm(Game.GetFormFromFile(0x030540FC, "DLCCoast.esm"))	
	endIf
endFunction

Function UpgradeToVersion()
	float lastVers = DTSleep_LastVersion.GetValue()
	float currentVersion = DTSleep_Version.GetValue()
	;Debug.Trace(myScriptName + "check upgrade: " + lastVers + ", " + currentVersion)
	
	; added v2.60 - R is now +0.0002 over XOXO, so switch may be detected
	;             - also in case rolls back and loads newer save-game
	if ((DTSConditionals as DTSleep_Conditionals).ImaPCMod && lastVers > currentVersion)
	
		DTSleep_VersionDowngradeMsg.Show(currentVersion, lastVers)
		
	elseIf (lastVers > 0.0 && lastVers < currentVersion)
		; do stuff
		
		;ActiveLevel = 1
		int settingChangeCount = 0
		
		
		; ***********************************************************************
		; upgrades
		if (lastVers > 0.90 && lastVers < 1.06)
			
			SleepQuestScript.SetPersuadeTutorStatus()
		endIf
		
		if (lastVers > 0.70 && lastVers < 1.20)
		
			if ((DTSConditionals as DTSleep_Conditionals).IsCoastDLCActive)
				Form locForm = Game.GetFormFromFile(0x03038AE6, "DLCCoast.esm")
				if (locForm && !DTSleep_UndressLocationList.HasForm(locForm))    ; Vault 118
					DTSleep_UndressLocationList.AddForm(locForm)
					DTSleep_UndressLocationList.AddForm(Game.GetFormFromFile(0x03004477, "DLCCoast.esm"))   ; Nucleus
					DTSleep_TownLocationList.AddForm(Game.GetFormFromFile(0x0300220C, "DLCCoast.esm"))       ; Nakano
					DTSleep_TownLocationList.AddForm(Game.GetFormFromFile(0x03005C79, "DLCCoast.esm")) 		; Far Harbor
					DTSleep_TownLocationList.AddForm(Game.GetFormFromFile(0x03004C7C, "DLCCoast.esm")) 		; Eden Meadows Cinemas
					DTSleep_TownLocationList.AddForm(Game.GetFormFromFile(0x03009353, "DLCCoast.esm")) 		; Visitors Center
					DTSleep_TownLocationList.AddForm(Game.GetFormFromFile(0x0300AFF9, "DLCCoast.esm")) 		; Mother's Shrine
					DTSleep_TownLocationList.AddForm(Game.GetFormFromFile(0x0300F044, "DLCCoast.esm")) 		; Horizon Flight
					DTSleep_TownLocationList.AddForm(Game.GetFormFromFile(0x0300F101, "DLCCoast.esm")) 		; Echo Lake
					DTSleep_TownLocationList.AddForm(Game.GetFormFromFile(0x0301049F, "DLCCoast.esm")) 		; NP Headquarters
					DTSleep_TownLocationList.AddForm(Game.GetFormFromFile(0x03020649, "DLCCoast.esm")) 		; Longfellow's Cabin
					DTSleep_TownLocationList.AddForm(Game.GetFormFromFile(0x030247BE, "DLCCoast.esm")) 		; NP Camp
					
					DTSleep_TownLocationList.AddForm(Game.GetFormFromFile(0x03038EAE, "DLCCoast.esm")) 		; Dalton Farm
					DTSleep_TownLocationList.AddForm(Game.GetFormFromFile(0x030140E0, "DLCCoast.esm")) 		; Eagle Cove Tannery
					DTSleep_TownLocationList.AddForm(Game.GetFormFromFile(0x0300F041, "DLCCoast.esm")) 		; Cliff's Edge Hotel
					
					DTSleep_IntimateLocCountThreshold.SetValueInt(DTSleep_IntimateTourLocList.GetSize())
				endIf
				
				locForm = Game.GetFormFromFile(0x03006126, "DLCCoast.esm")   ; Acadia
				DTSleep_UndressLocationList.AddForm(locForm)
				if (locForm && !DTSleep_IntimateTourLocList.HasForm(locForm))
					DTSleep_IntimateTourLocList.AddForm(locForm)
					(DTSConditionals as DTSleep_Conditionals).LocTourFHAcadiaIndex = DTSleep_IntimateTourLocList.GetSize() - 1
				endIf
				locForm = Game.GetFormFromFile(0x030217D4, "DLCCoast.esm")   ; grand harbor
				if (locForm && !DTSleep_IntimateTourLocList.HasForm(locForm))
					DTSleep_IntimateTourLocList.AddForm(locForm)
					(DTSConditionals as DTSleep_Conditionals).LocTourFHGHotelIndex = DTSleep_IntimateTourLocList.GetSize() - 1
				endIf
				
				DTSleep_IntimateLocCountThreshold.SetValueInt(DTSleep_IntimateTourLocList.GetSize())
				SleepQuestScript.UpgradeTour()
			endIf
		endIf
		if (lastVers == 1.200)
			if ((DTSConditionals as DTSleep_Conditionals).IsCoastDLCActive == false)
				(DTSConditionals as DTSleep_Conditionals).LocTourFHAcadiaIndex = -1
				(DTSConditionals as DTSleep_Conditionals).LocTourFHGHotelIndex = -1
			endIf
		endIf
		
		if (lastVers < 1.240)
			; include green bed on intimate list
			if ((DTSConditionals as DTSleep_Conditionals).IsWorkShop03DLCActive)
				Form bedForm = Game.GetFormFromFile(0x05004981, "DLCWorkshop03.esm")
				if (bedForm)
					DTSleep_BedIntimateList.AddForm(bedForm)
				endIf
			endIf
		endIf
		
		if (lastVers < 1.242 && (DTSConditionals as DTSleep_Conditionals).IsNukaWorldDLCActive)
			
			Form treatForm = Game.GetFormFromFile(0x0602689A, "DLCNukaWorld.esm") ; cotton candy bites
			if (!DTSleep_CandyTreatsList.HasForm(treatForm))
				
				DTSleep_CandyTreatsList.AddForm(treatForm)
				DTSleep_CandyTreatsList.AddForm(Game.GetFormFromFile(0x06030EFC, "DLCNukaWorld.esm"))  ; nuka-love
				DTSleep_CandyTreatsList.AddForm(Game.GetFormFromFile(0x06024534, "DLCNukaWorld.esm"))	; nuka-grape
			endIf
		endIf
		
		if (lastVers < 1.260 && (DTSConditionals as DTSleep_Conditionals).IsVioStrapOnActive && DTSleep_AdultContentOn.GetValueInt() >= 2)
			Armor strapOn = Game.GetFormFromFile(0x080044D9, "VIO_Strap-On_SIXPatch.esp") as Armor
			if (strapOn != None)
				AddStrapOnToLists(strapOn, DTSleep_ArmorSlot55List)
			endIf
		endIf
		
		if (lastVers < 1.280)
			modScrapRecipe_NullMelee_Cloth.AddForm(DTSleep_ClothesBathrobeRed)
			modScrapRecipe_NullMelee_Cloth.AddForm(DTSleep_ClothesBathrobeWhite)
			LLI_Vendor_Clothes_Any_Rare.AddForm(DTSleep_ClothesBathrobeRed, 1, 1)
			LLI_Vendor_Clothes_Any_Rare.AddForm(DTSleep_ClothesBathrobeWhite, 1, 1)
		endIf
		
		if (lastVers < 1.340 && (DTSConditionals as DTSleep_Conditionals).IsNukaWorldDLCActive)
			Form gageRef = Game.GetFormFromFile(0x0600A5B1, "DLCNukaWorld.esm")
			
			if (gageRef != None)
				DTSleep_CompanionRomance2List.AddForm(gageRef)
			endIf
		endIf
		
		if (lastVers < 1.420)
			SleepQuestScript.CheckCompanionDress()
		endIf
		
		if (lastVers < 1.46)
			
			if ((DTSConditionals as DTSleep_Conditionals).IsSnapBedsActive)
				; add to double-bed list
				DTSleep_BedsBigDoubleList.AddForm(Game.GetFormFromFile(0x03006364, "SnapBeds.esp"))
				DTSleep_BedsBigList.AddForm(Game.GetFormFromFile(0x03006364, "SnapBeds.esp"))
				DTSleep_BedIntimateList.AddForm(Game.GetFormFromFile(0x03006364, "SnapBeds.esp"))
				DTSleep_BedsBigDoubleList.AddForm(Game.GetFormFromFile(0x03006B66, "SnapBeds.esp"))
				DTSleep_BedsBigDoubleList.AddForm(Game.GetFormFromFile(0x03006B68, "SnapBeds.esp"))
				DTSleep_BedsBigDoubleList.AddForm(Game.GetFormFromFile(0x03006B6A, "SnapBeds.esp"))
				DTSleep_BedsBigDoubleList.AddForm(Game.GetFormFromFile(0x03006B6C, "SnapBeds.esp"))
				DTSleep_BedsBigDoubleList.AddForm(Game.GetFormFromFile(0x03006B6E, "SnapBeds.esp"))
				DTSleep_BedsBigDoubleList.AddForm(Game.GetFormFromFile(0x03006B70, "SnapBeds.esp"))
				DTSleep_BedsBigDoubleList.AddForm(Game.GetFormFromFile(0x03006B72, "SnapBeds.esp"))
				DTSleep_BedsBigDoubleList.AddForm(Game.GetFormFromFile(0x03006B74, "SnapBeds.esp"))
				DTSleep_BedsBigDoubleList.AddForm(Game.GetFormFromFile(0x03006B7D, "SnapBeds.esp"))
				DTSleep_BedsBigDoubleList.AddForm(Game.GetFormFromFile(0x03006B7E, "SnapBeds.esp"))
				DTSleep_BedsBigDoubleList.AddForm(Game.GetFormFromFile(0x03006B7F, "SnapBeds.esp"))
				DTSleep_BedsBigDoubleList.AddForm(Game.GetFormFromFile(0x03006B80, "SnapBeds.esp"))
				DTSleep_BedsBigDoubleList.AddForm(Game.GetFormFromFile(0x03006B81, "SnapBeds.esp"))
				DTSleep_BedsBigDoubleList.AddForm(Game.GetFormFromFile(0x03006B82, "SnapBeds.esp"))
				DTSleep_BedsBigDoubleList.AddForm(Game.GetFormFromFile(0x03006B83, "SnapBeds.esp"))
				DTSleep_BedsBigDoubleList.AddForm(Game.GetFormFromFile(0x03006B84, "SnapBeds.esp"))
			endIf
		endIf
		
		if (lastVers < 1.543)
			float undressWait = DTSleep_SettingUndressTimer.GetValue()
			if (undressWait <= 2.20)
				DTSleep_SettingUndressTimer.SetValue(3.20)
			endIf
		endIf
		
		if (lastVers < 1.546 && DTSleep_IsSleepTogetherActive.GetValue() >= 1.0)
			Form sleepBag = IsPluginActive(0x0900B008, "Hoamaii_SleepTogetherAnywhere.esp")
			if (sleepBag != None && DTSleep_BedNoIntimateList.HasForm(sleepBag))
				DTSleep_BedNoIntimateList.RemoveAddedForm(sleepBag)
			endIf
		endIf
		
		if (lastVers < 1.547 && (DTSConditionals as DTSleep_Conditionals).IsCoastDLCActive)
			Form loc = Game.GetFormFromFile(0x03004477, "DLCCoast.esm")
			if (loc != None && !DTSleep_UndressLocationList.HasForm(loc))
				DTSleep_UndressLocationList.AddForm(loc)   ; Nucleus
			endIf
		endIf
		
		if (lastVers < 1.57)
		
			if ((DTSConditionals as DTSleep_Conditionals).IsCoastDLCActive && (DTSConditionals as DTSleep_Conditionals).FarHarborDLCLongfellowRef != None)
				DTSleep_CompanionIntimateAllList.AddForm((DTSConditionals as DTSleep_Conditionals).FarHarborDLCLongfellowRef as Form)
			endIf
			if ((DTSConditionals as DTSleep_Conditionals).IsNukaWorldDLCActive && (DTSConditionals as DTSleep_Conditionals).NukaWorldDLCGageRef != None)
				DTSleep_CompanionIntimateAllList.AddForm((DTSConditionals as DTSleep_Conditionals).NukaWorldDLCGageRef as Form)
			endIf
			
			if ((DTSConditionals as DTSleep_Conditionals).IsHeatherCompanionActive)
				string heatherPluginName = "llamaCompanionHeather.esp"
				if ((DTSConditionals as DTSleep_Conditionals).HeatherCampanionVers >= 2.0)
					heatherPluginName = "llamaCompanionHeatherv2.esp"
				endIf
				Form heatherActor = Game.GetFormFromFile(0x0300D157, heatherPluginName)
				if (heatherActor != None)
					DTSleep_CompanionIntimateAllList.AddForm(heatherActor)
				endIf
			endIf
			
			if ((DTSConditionals as DTSleep_Conditionals).IsNWSBarbActive)
				Form barbRefForm = IsPluginActive(0x03010374, "NWS_Barbara.esp")
				if (barbRefForm != None)
					DTSleep_CompanionIntimateAllList.AddForm(barbRefForm)
				endIf
			endIf
		endIf
		
		if (lastVers < 1.60)
			; check intimate faction
			int i = 0
			while (i < DTSleep_CompanionIntimateAllList.GetSize())
				
				Actor ac = DTSleep_CompanionIntimateAllList.GetAt(i) as Actor
				if (ac != None && ac.IsInFaction(SleepQuestScript.DTSleep_IntimateFaction))
					Debug.Trace("Version Update Check: removing companion " + ac + " from intimate faction")
					ac.RemoveFromFaction(SleepQuestScript.DTSleep_IntimateFaction)
				endIf
				
				i += 1
			endWhile
		endIf
		
		if (lastVers < 1.6010 && (DTSConditionals as DTSleep_Conditionals).IsRobotDLCActive)
		
			(DTSConditionals as DTSleep_Conditionals).RobotAdaRef = Game.GetFormFromFile(0x0200FF12, "DLCRobot.esm") as Actor
			(DTSConditionals as DTSleep_Conditionals).RobotMQ105Quest = Game.GetFormFromFile(0x020010F5, "DLCRobot.esm") as Quest
		endIf
		
		if (lastVers < 1.65)
			if ((DTSConditionals as DTSleep_Conditionals).IsWorkShop03DLCActive)
				; chairs and benches
				DTSleep_IntimateKitchenSeatList.AddForm(Game.GetFormFromFile(0x05005337, "DLCWorkshop03.esm"))
				DTSleep_IntimateKitchenSeatList.AddForm(Game.GetFormFromFile(0x05005340, "DLCWorkshop03.esm"))
				DTSleep_IntimateBenchList.AddForm(Game.GetFormFromFile(0x050049F4, "DLCWorkshop03.esm"))
				DTSleep_IntimateBenchList.AddForm(Game.GetFormFromFile(0x05004984, "DLCWorkshop03.esm"))
				DTSleep_IntimateKitchenSeatList.AddForm(Game.GetFormFromFile(0x05005343, "DLCWorkshop03.esm"))
				DTSleep_IntimateKitchenSeatList.AddForm(Game.GetFormFromFile(0x05005344, "DLCWorkshop03.esm"))
				DTSleep_IntimateKitchenSeatList.AddForm(Game.GetFormFromFile(0x05005345, "DLCWorkshop03.esm"))
				DTSleep_IntimateKitchenSeatList.AddForm(Game.GetFormFromFile(0x05005346, "DLCWorkshop03.esm"))
				DTSleep_IntimateKitchenSeatList.AddForm(Game.GetFormFromFile(0x05005347, "DLCWorkshop03.esm"))
				DTSleep_IntimateKitchenSeatList.AddForm(Game.GetFormFromFile(0x05005348, "DLCWorkshop03.esm"))

			endIf
		endIf
		
		if (lastVers < 1.910)
			if ((DTSConditionals as DTSleep_Conditionals).IsNukaWorldDLCActive)
				Form gangFactForm = Game.GetFormFromFile(0x0600F438, "DLCNukaWorld.esm")
				if (gangFactForm != None && !DTSleep_SettlerFactionList.HasForm(gangFactForm))
					DTSleep_SettlerFactionList.AddForm(gangFactForm)
					DTSleep_SettlerFactionList.AddForm(Game.GetFormFromFile(0x0600F439, "DLCNukaWorld.esm"))
					DTSleep_SettlerFactionList.AddForm(Game.GetFormFromFile(0x0600F43A, "DLCNukaWorld.esm"))
					DTSleep_SettlerFactionList.AddForm(Game.GetFormFromFile(0x06013A45, "DLCNukaWorld.esm"))
				endIf
			endIf
		endIf
		
		if (lastVers < 1.960)
		
			if ((DTSConditionals as DTSleep_Conditionals).IsRobotDLCActive)
				DTSleep_ArmorTorsoList.AddForm(Game.GetFormFromFile(0x0200863F, "DLCRobot.esm"))
				DTSleep_ArmorArmRightList.AddForm(Game.GetFormFromFile(0x02008642, "DLCRobot.esm"))
				DTSleep_ArmorArmLeftList.AddForm(Game.GetFormFromFile(0x02008644, "DLCRobot.esm"))
				DTSleep_ArmorLegRightList.AddForm(Game.GetFormFromFile(0x02008646, "DLCRobot.esm"))
				DTSleep_ArmorLegLeftList.AddForm(Game.GetFormFromFile(0x02008648, "DLCRobot.esm"))
			endIf
			if ((DTSConditionals as DTSleep_Conditionals).IsCoastDLCActive)
				DTSleep_ArmorArmLeftList.AddForm(Game.GetFormFromFile(0x03009E56, "DLCCoast.esm"))
				DTSleep_ArmorArmRightList.AddForm(Game.GetFormFromFile(0x03009E57, "DLCCoast.esm"))
				DTSleep_ArmorLegLeftList.AddForm(Game.GetFormFromFile(0x03009E59, "DLCCoast.esm"))
				DTSleep_ArmorLegRightList.AddForm(Game.GetFormFromFile(0x03009E5A, "DLCCoast.esm"))
				DTSleep_ArmorTorsoList.AddForm(Game.GetFormFromFile(0x03009E5B, "DLCCoast.esm"))
				
				DTSleep_ArmorArmLeftList.AddForm(Game.GetFormFromFile(0x0300EE75, "DLCCoast.esm"))
				DTSleep_ArmorArmRightList.AddForm(Game.GetFormFromFile(0x0300EE76, "DLCCoast.esm"))
				DTSleep_ArmorLegLeftList.AddForm(Game.GetFormFromFile(0x0300EE77, "DLCCoast.esm"))
				DTSleep_ArmorLegRightList.AddForm(Game.GetFormFromFile(0x0300EE78, "DLCCoast.esm"))
				DTSleep_ArmorTorsoList.AddForm(Game.GetFormFromFile(0x0300EE79, "DLCCoast.esm"))
				
				DTSleep_ArmorArmLeftList.AddForm(Game.GetFormFromFile(0x0300F04A, "DLCCoast.esm"))
				DTSleep_ArmorArmRightList.AddForm(Game.GetFormFromFile(0x0300F04B, "DLCCoast.esm"))
				DTSleep_ArmorLegLeftList.AddForm(Game.GetFormFromFile(0x0300F04C, "DLCCoast.esm"))
				DTSleep_ArmorLegRightList.AddForm(Game.GetFormFromFile(0x0300F04D, "DLCCoast.esm"))
				DTSleep_ArmorTorsoList.AddForm(Game.GetFormFromFile(0x0300F04E, "DLCCoast.esm"))
			endIf
			if ((DTSConditionals as DTSleep_Conditionals).IsNukaWorldDLCActive)
				LoadNukaWorldOuterArmors()
			endIf
			if ((DTSConditionals as DTSleep_Conditionals).IsRangerGearActive)
				DTSleep_ArmorArmLeftList.AddForm(Game.GetFormFromFile(0x0200081D, "Rangergearnew.esp"))
				DTSleep_ArmorArmRightList.AddForm(Game.GetFormFromFile(0x0200081C, "Rangergearnew.esp"))
				DTSleep_ArmorLegLeftList.AddForm(Game.GetFormFromFile(0x0200081E, "Rangergearnew.esp"))
				DTSleep_ArmorLegRightList.AddForm(Game.GetFormFromFile(0x0200081F, "Rangergearnew.esp"))
				DTSleep_ArmorTorsoList.AddForm(Game.GetFormFromFile(0x02000820, "Rangergearnew.esp"))
				DTSleep_ArmorTorsoList.AddForm(Game.GetFormFromFile(0x020054D5, "Rangergearnew.esp"))
				DTSleep_ArmorTorsoList.AddForm(Game.GetFormFromFile(0x020054D6, "Rangergearnew.esp"))
				DTSleep_ArmorArmLeftList.AddForm(Game.GetFormFromFile(0x020054D7, "Rangergearnew.esp"))
				DTSleep_ArmorArmRightList.AddForm(Game.GetFormFromFile(0x020054D8, "Rangergearnew.esp"))
				DTSleep_ArmorArmLeftList.AddForm(Game.GetFormFromFile(0x020054D9, "Rangergearnew.esp"))
				DTSleep_ArmorArmRightList.AddForm(Game.GetFormFromFile(0x020054DA, "Rangergearnew.esp"))
			endIf
		endIf
		
		if (lastVers < 1.990)
			if ((DTSConditionals as DTSleep_Conditionals).IsWorkShop03DLCActive)
				DTSleep_IntimateRoundTableList.AddForm(Game.GetFormFromFile(0x05005368, "DLCWorkshop03.esm"))
			endIf
		
			; apparently forgot helmets a few updates ago...
			if ((DTSConditionals as DTSleep_Conditionals).IsCoastDLCActive)
				LoadHelmetsFarHarbor()
			endIf
			if ((DTSConditionals as DTSleep_Conditionals).IsRobotDLCActive)
				LoadHelmetsRobot()
			endIf
			if ((DTSConditionals as DTSleep_Conditionals).IsNukaWorldDLCActive)
				LoadHelmetsNukaWorld()
			endIf
			
			; review extras lists to clean-up user-added items on our updated lists
			UpdateExtraPartsList()
		endIf
		
		if (lastVers < 2.140)
			; reset Heather for updated in-love check
			(DTSConditionals as DTSleep_Conditionals).IsHeatherCompInLove = false
		endIf
		
		if (lastVers < 2.171)
			
			if ((DTSConditionals as DTSleep_Conditionals).IsCoastDLCActive)
				; check if missing
				Cell bCell = Game.GetFormFromFile(0x03000C69, "DLCCoast.esm") as Cell
				if (bCell != None && !DTSleep_BedCellNoRestList.HasForm(bCell))
					;Debug.Trace(myScriptName + " adding DLCCoast missing bad-rest cells...")
					DTSleep_BedCellNoRestList.AddForm(bCell)
					DTSleep_BedCellNoRestList.AddForm(Game.GetFormFromFile(0x03000D89, "DLCCoast.esm"))
					DTSleep_BedCellNoRestList.AddForm(Game.GetFormFromFile(0x03002747, "DLCCoast.esm"))
					DTSleep_BedCellNoRestList.AddForm(Game.GetFormFromFile(0x03000B97, "DLCCoast.esm"))
				endIf
			endIf
		endIf
		
		if (lastVers < 2.18)
			if ((DTSConditionals as DTSleep_Conditionals).IsVioStrapOnActive && DTSleep_AdultContentOn.GetValueInt() >= 2)
				Form strapOn = Game.GetFormFromFile(0x08005413, "VIO_Strap-On.esp")
				if (strapOn != None)
					AddStrapOnToLists(strapOn as Armor, DTSleep_ArmorSlot55List)
					AddStrapOnToLists(Game.GetFormFromFile(0x08005414, "VIO_Strap-On.esp") as Armor, DTSleep_ArmorSlot55List)
					AddStrapOnToLists(Game.GetFormFromFile(0x08005415, "VIO_Strap-On.esp") as Armor, DTSleep_ArmorSlot55List)
					AddStrapOnToLists(Game.GetFormFromFile(0x08005416, "VIO_Strap-On.esp") as Armor, DTSleep_ArmorSlot55List)
				endIf
			endIf
		endIf
		
		if (lastVers < 2.201)
			if ((DTSConditionals as DTSleep_Conditionals).IsWorkShop03DLCActive)
				DTSleep_IntimateKitchenSeatList.AddForm(Game.GetFormFromFile(0x0500538B, "DLCWorkshop03.esm"))
				DTSleep_IntimateKitchenSeatList.AddForm(Game.GetFormFromFile(0x0500538C, "DLCWorkshop03.esm"))
			endIf
		endIf
		
		if (lastVers < 2.241)
		
			if ((DTSConditionals as DTSleep_Conditionals).IsNukaWorldDLCActive)
				DTSleep_IntimateChairThroneList.AddForm(Game.GetFormFromFile(0x0602F326, "DLCNukaWorld.esm"))
			endIf
			if ((DTSConditionals as DTSleep_Conditionals).NoraSpouseRef != None)
				DTSleep_CompanionIntimateAllList.AddForm((DTSConditionals as DTSleep_Conditionals).NoraSpouseRef as Form)
			endIf
			if ((DTSConditionals as DTSleep_Conditionals).DualSurvivorsNateRef != None)
				DTSleep_CompanionIntimateAllList.AddForm((DTSConditionals as DTSleep_Conditionals).DualSurvivorsNateRef as Form)
			endIf
		endIf
		if (lastVers < 2.242)
			; some reports of not showing so just in case
			if ((DTSConditionals as DTSleep_Conditionals).IsVioStrapOnActive)
				LLI_Vendor_Clothes_Any_Rare.AddForm(Game.GetFormFromFile(0x08000FA0, "VIO_Strap-On.esp"), 1, 1)
				LLI_Vendor_Clothes_Any_Rare.AddForm(Game.GetFormFromFile(0x08000F9F, "VIO_Strap-On.esp"), 1, 1)
			endIf
		endIf
		
		if (lastVers < 2.253)
		
			if ((DTSConditionals as DTSleep_Conditionals).IsWorkShop03DLCActive)
				DTSleep_IntimateWeightBenchList.AddForm(Game.GetFormFromFile(0x0500119A, "DLCWorkshop03.esm"))
				(DTSConditionals as DTSleep_Conditionals).WeightBenchKY = (Game.GetFormFromFile(0x05001A52, "DLCWorkshop03.esm") as Keyword)
			endIf
			
			if ((DTSConditionals as DTSleep_Conditionals).IsWorkShop02DLCActive)
				(DTSConditionals as DTSleep_Conditionals).DLC05PilloryKY = Game.GetFormFromFile(0x05000AC8, "DLCWorkshop02.esm") as Keyword
				Form pilloryForm = Game.GetFormFromFile(0x05000AAD, "DLCWorkshop02.esm")
				DTSleep_PilloryList.AddForm(pilloryForm)
			endIf
		
			if ((DTSConditionals as DTSleep_Conditionals).IsSnapBedsActive)
				Form bunkForm = Game.GetFormFromFile(0x03001ED3, "SnapBeds.esp")
				if (bunkForm != None)
					if (DTSleep_BadSheltersList.HasForm(bunkForm))
						DTSleep_BadSheltersList.RemoveAddedForm(bunkForm)
					endIf
					if (DTSleep_BedNoIntimateList.HasForm(bunkForm))
						DTSleep_BedNoIntimateList.RemoveAddedForm(bunkForm)
					endIf
					DTSleep_BedBunkFrameList.AddForm(bunkForm)
				endIf
			endIf
			
			if ((DTSConditionals as DTSleep_Conditionals).IsHeatherCompanionActive)
				; add to double-bed list
				
				Form bed = None
				if ((DTSConditionals as DTSleep_Conditionals).HeatherCampanionVers < 1.5)
					bed = Game.GetFormFromFile(0x0211E893, "llamaCompanionHeather.esp")
				else
					bed = Game.GetFormFromFile(0x04CA8A1E, "llamaCompanionHeatherv2.esp")
				endIf
				if (bed != None)
					DTSleep_BedsBigDoubleList.AddForm(bed)
				endIf
			endIf
		endIf
		
		if (lastVers < 2.351)
			if ((DTSConditionals as DTSleep_Conditionals).IsWorkShop03DLCActive)
				DTSleep_IntimateDinerBoothTableAllList.AddForm(Game.GetFormFromFile(0x050049F3, "DLCWorkshop03.esm"))
			endIf
		endIf
		
		if (lastVers < 2.400)
			if ((DTSConditionals as DTSleep_Conditionals).IsRobotDLCActive)
				DTSleep_JailDoorBadLocationList.AddForm(Game.GetFormFromFile(0x020008A4, "DLCRobot.esm"))		; DLC01LairLocation
			endIf
		endIf
		
		if (lastVers < 2.5100)
			if ((DTSConditionals as DTSleep_Conditionals).IsWorkShop03DLCActive)
				; v2.51 - desk-container
				Form deskForm = Game.GetFormFromFile(0x0500539C, "DLCWorkshop03.esm")		; highTech
				DTSleep_IntimateDeskList.AddForm(deskForm)
				DTSleep_IntimateDesk90List.AddForm(deskForm)
				deskForm = Game.GetFormFromFile(0x0500539D, "DLCWorkshop03.esm")		; highTech
				DTSleep_IntimateDeskList.AddForm(deskForm)
				DTSleep_IntimateDesk90List.AddForm(deskForm)
				deskForm = Game.GetFormFromFile(0x05004987, "DLCWorkshop03.esm")		; vault desk
				DTSleep_IntimateDeskList.AddForm(deskForm)
				DTSleep_IntimateDesk90List.AddForm(deskForm)
			endIf
		endIf
		
		if (lastVers < 2.7003)
			if ((DTSConditionals as DTSleep_Conditionals).IsWorkShop03DLCActive)
				; v2.70 - ottoman
				DTSleep_IntimateChairOttomanList.AddForm(Game.GetFormFromFile(0x050005341, "DLCWorkshop03.esm"))
				DTSleep_IntimateChairOttomanList.AddForm(Game.GetFormFromFile(0x05000534B, "DLCWorkshop03.esm"))
			endIf
			if ((DTSConditionals as DTSleep_Conditionals).IsCoastDLCActive)
				; railings
				; Echo Lake
				Form railingForm = Game.GetFormFromFile(0x0303DC61, "DLCCoast.esm")
				DTSleep_IntimateRailingList.AddForm(railingForm)
				DTSleep_IntimatePropList.AddForm(railingForm)
				railingForm = Game.GetFormFromFile(0x0303DC63, "DLCCoast.esm")
				DTSleep_IntimateRailingList.AddForm(railingForm)
				DTSleep_IntimatePropList.AddForm(railingForm)
				railingForm = Game.GetFormFromFile(0x0303DC65, "DLCCoast.esm")
				DTSleep_IntimateRailingList.AddForm(railingForm)
				DTSleep_IntimatePropList.AddForm(railingForm)
				; bouy railings Nakano
				railingForm = Game.GetFormFromFile(0x03001938, "DLCCoast.esm")
				DTSleep_IntimateRailingList.AddForm(railingForm)
				DTSleep_IntimatePropList.AddForm(railingForm)
				railingForm = Game.GetFormFromFile(0x03001932, "DLCCoast.esm")
				DTSleep_IntimateRailingList.AddForm(railingForm)
				DTSleep_IntimatePropList.AddForm(railingForm)
				
				; backward rails at Dalton Farm
				(DTSConditionals as DTSleep_Conditionals).DLCCoastDaltonRailingBackward01 = Game.GetFormFromFile(0x0300472F, "DLCCoast.esm") as ObjectReference
				(DTSConditionals as DTSleep_Conditionals).DLCCoastDaltonRailingBackward02 = Game.GetFormFromFile(0x03004726, "DLCCoast.esm") as ObjectReference
				(DTSConditionals as DTSleep_Conditionals).DLCCoastDaltonRailingBackward03 = Game.GetFormFromFile(0x0300472C, "DLCCoast.esm") as ObjectReference
				(DTSConditionals as DTSleep_Conditionals).DLCCoastDaltonRailingBackward04 = Game.GetFormFromFile(0x03004730, "DLCCoast.esm") as ObjectReference
				(DTSConditionals as DTSleep_Conditionals).DLCCoastDaltonRailingBackward05 = Game.GetFormFromFile(0x03004731, "DLCCoast.esm") as ObjectReference
			endIf
		endIf
		
		if (lastVers < 2.770)
			if ((DTSConditionals as DTSleep_Conditionals).IsWorkShop03DLCActive)
				Form lockerForm = Game.GetFormFromFile(0x05004988, "DLCWorkshop03.esm")
				DTSleep_IntimateLockerList.AddForm(lockerForm)
				DTSleep_IntimateLockerAdjList.AddForm(lockerForm)
			endIf
		endIf
		
	
		;  ***************************** check mods
		
		int modActiveValue = SleepQuestScript.CheckCustomGear(1)
		if (modActiveValue > 0)
			ActiveLevel = 1
		endIf
		
		settingChangeCount = SleepQuestScript.RestoreTestSettings(lastVers)
		
		if (ActiveLevel > 0)
			if (DTSleep_EquipMonInit.GetValueInt() < 5 && SleepQuestScript.DTSleep_SettingUndress.GetValue() > 0.0)
				DTSleep_VersionUpUndressMsg.Show(currentVersion)
				
			elseIf (SleepQuestScript.IsAdultAnimationAvailable())
				DTSleep_VersionExplicitMsg.Show(currentVersion)
				
			elseIf (DTSleep_AdultContentOn.GetValue() == 1.0)
				DTSleep_VersionSafeMsg.Show(currentVersion)
			else
				DTSleep_VersionMsg.Show(currentVersion)
			endIf
		else
			DTSleep_VersionOffMsg.Show(currentVersion)
		endIf
		
		if (settingChangeCount > 0)
			Utility.Wait(1.0)
			DTSleep_TestSetResetMsg.Show(settingChangeCount)
		endIf
	endIf
	
	DTSleep_LastVersion.SetValue(currentVersion)
	
EndFunction

Function StartUp()
	
	CheckCompatibility()
	
	UpdateSleepWear()
	ActiveLevel = 1
	if ((DTSConditionals as DTSleep_Conditionals).IsSMMActive == false)
		WorkshopMenu01Furniture.AddForm(DTSleep_WorkshopRecipeKY)
	endIf
EndFunction

Function Shutdown()

	ActiveLevel = -1
	if ((DTSConditionals as DTSleep_Conditionals).IsSMMActive == false)
		WorkshopMenu01Furniture.RemoveAddedForm(DTSleep_WorkshopRecipeKY)
	endIf
EndFunction

Function UpdateCompanionSupportRemoval()
	
	; rebuild
	DTSleep_ModCompanionActorList.Revert()
	DTSleep_ModCompanionBodiesLst.Revert()
	
	if (DTSleep_LastVersion.GetValue() == DTSleep_Version.GetValue())
		CheckUniquePlayerFollowers()  ; v2.47
		;else we do this later
	endIf
	
	if ((DTSConditionals as DTSleep_Conditionals).IsHeatherCompanionActive)
		string heatherPluginName = "llamaCompanionHeather.esp"
		if ((DTSConditionals as DTSleep_Conditionals).HeatherCampanionVers >= 2.0)
			heatherPluginName = "llamaCompanionHeatherv2.esp"
		endIf
		Form bodyNakedArmor = Game.GetFormFromFile(0x0200BA6D, heatherPluginName)
		if (bodyNakedArmor != None)
			DTSleep_ModCompanionBodiesLst.AddForm(bodyNakedArmor)
			
			(DTSConditionals as DTSleep_Conditionals).ModCompanionBodyHeatherIndex = DTSleep_ModCompanionBodiesLst.GetSize() - 1
		endIf
		
		Form heatherActor = Game.GetFormFromFile(0x0300D157, heatherPluginName)
		
		if (heatherActor != None)
			DTSleep_ModCompanionActorList.AddForm(heatherActor)
			
			(DTSConditionals as DTSleep_Conditionals).ModCompanionActorHeatherIndex = DTSleep_ModCompanionActorList.GetSize() - 1
		endIf
	endIf
	
	if ((DTSConditionals as DTSleep_Conditionals).IsNWSBarbActive)
		Form barbRefForm = Game.GetFormFromFile(0x03010374, "NWS_Barbara.esp")
		if (barbRefForm != None)
			DTSleep_ModCompanionActorList.AddForm(barbRefForm)
			(DTSConditionals as DTSleep_Conditionals).ModCompanionActorNWSBarbIndex = DTSleep_ModCompanionActorList.GetSize() - 1
		endIf
	endIf

endFunction

;------
; users may have added armor to custom lists that later version handles - trim duplicates for performance
;
Function UpdateExtraPartsList()

	int origLen = DTSleep_ArmorExtraPartsList.GetSize()
	int i = origLen - 1
	
	; go backwards since removing
	while (i >= 0 && i < DTSleep_ArmorExtraPartsList.GetSize())
	
		Form item = DTSleep_ArmorExtraPartsList.GetAt(i)
		if (item != None)
			if (DTSleep_ArmorHatHelmList.HasForm(item))
				DTSleep_ArmorExtraPartsList.RemoveAddedForm(item)
			elseIf (DTSleep_ArmorArmLeftList.HasForm(item))
				DTSleep_ArmorExtraPartsList.RemoveAddedForm(item)
			elseIf (DTSleep_ArmorArmRightList.HasForm(item))
				DTSleep_ArmorExtraPartsList.RemoveAddedForm(item)
			elseIf (DTSleep_ArmorLegLeftList.HasForm(item))
				DTSleep_ArmorExtraPartsList.RemoveAddedForm(item)
			elseIf (DTSleep_ArmorLegRightList.HasForm(item))
				DTSleep_ArmorExtraPartsList.RemoveAddedForm(item)
			elseIf (DTSleep_ArmorTorsoList.HasForm(item))
				DTSleep_ArmorExtraPartsList.RemoveAddedForm(item)
			endIf
		endIf
	
		i -= 1
	endWhile
	
	int finDif = origLen - DTSleep_ArmorExtraPartsList.GetSize()
	if (finDif > 0)
		Debug.Trace(myScriptName + " update - trimmed custom ExtraParts list by " + finDif)
	else
		Debug.Trace(myScriptName + " update - no change to custom ExtraParts list of size " + origLen)
	endIf
endFunction

Function UpdateRemListsPipPadForm(Form pippad)
	if (DTSleep_SleepAttireFemale.HasForm(pippad))
		DTSleep_SleepAttireFemale.RemoveAddedForm(pippad)
	endIf
	if (DTSleep_SleepAttireMale.HasForm(pippad as Form))
		DTSleep_SleepAttireMale.RemoveAddedForm(pippad)
	endIf
	if (DTSleep_ArmorBackPacksList.HasForm(pippad))
		DTSleep_ArmorBackPacksList.RemoveAddedForm(pippad)
	endIf
	if (DTSleep_ArmorJacketsClothingList.HasForm(pippad))
		DTSleep_ArmorJacketsClothingList.RemoveAddedForm(pippad)
	endIf
	if (DTSleep_ArmorMaskList.HasForm(pippad))
		DTSleep_ArmorMaskList.RemoveAddedForm(pippad)
	endIf
endFunction

Function UpdateSleepWear()

	if (!modScrapRecipe_NullMelee_Cloth.HasForm(DTSleep_ClothesBathrobePink))
		modScrapRecipe_NullMelee_Cloth.AddForm(DTSleep_ClothesBathrobePink)
		modScrapRecipe_NullMelee_Cloth.AddForm(DTSleep_ClothesBathrobePurple)
		modScrapRecipe_NullMelee_Cloth.AddForm(DTSleep_ClothesBathrobeRed)
		modScrapRecipe_NullMelee_Cloth.AddForm(DTSleep_ClothesBathrobeWhite)
	endIf
	if (ActiveLevel <= 0)
		LLI_Vendor_Clothes_Any_Rare.AddForm(DTSleep_ClothesBathrobePink, 1, 1)
		LLI_Vendor_Clothes_Any_Rare.AddForm(DTSleep_ClothesBathrobePurple, 1, 1)
		LLI_Vendor_Clothes_Any_Rare.AddForm(DTSleep_ClothesBathrobeRed, 1, 1)
		LLI_Vendor_Clothes_Any_Rare.AddForm(DTSleep_ClothesBathrobeWhite, 1, 1)
	endIf
endFunction

; only call after checking plug-ins
; - makes sure set properly for Dogmeat scenes since not available for AAF (TODO: change?)
; - also checks for if previous version updates made a mistake of hiding EVB-best-fit setting
; - Dog scenes DTSleep_IsLeitoActive - 2+
; - EVB best-fit - DTSleep_IsLeitoActive - 1+
;
bool Function ValidateLeitoSettings()
	bool  settChanged = false
	int sixVal = DTSleep_SIXPatch.GetValueInt()
	int curLAVal = DTSleep_IsLeitoActive.GetValueInt()
	
	if ((DTSConditionals as DTSleep_Conditionals).IsLeitoActive || sixVal >= 2)
		if ((DTSConditionals as DTSleep_Conditionals).IsLeitoAAFActive)
			if (sixVal >= 4)
				; okay to have both
				if (curLAVal < sixVal)
					DTSleep_IsLeitoActive.SetValueInt(sixVal)
					settChanged = true
				endIf
			elseIf ((DTSConditionals as DTSleep_Conditionals).IsSavageCabbageActive)
				DTSleep_IsLeitoActive.SetValueInt(2)
			elseIf ((DTSConditionals as DTSleep_Conditionals).IsAtomicLustActive || DTSleep_IsZaZOut.GetValueInt() > 0)
				DTSleep_IsLeitoActive.SetValueInt(1)
			elseIf (sixVal >= 2 && sixVal <= 3)
				; nope - shared mixed files with old patch
				DTSleep_IsLeitoActive.SetValueInt(-12)
			else
				DTSleep_IsLeitoActive.SetValueInt(1)	; allow it -- hopefully player set loose files properly
			endIf
		else
			; no AAF-Leito
			if (curLAVal < 2)
				if (sixVal > 2)
					DTSleep_IsLeitoActive.SetValueInt(sixVal)
				else
					DTSleep_IsLeitoActive.SetValueInt(2) 
				endIf
				settChanged = true
			endIf
		endIf
	elseIf ((DTSConditionals as DTSleep_Conditionals).IsSavageCabbageActive)
		if (curLAVal < 2)
			DTSleep_IsLeitoActive.SetValueInt(2)
			settChanged = true
		endIf
	elseIf ((DTSConditionals as DTSleep_Conditionals).IsLeitoAAFActive)
		if (curLAVal < 2)
			DTSleep_IsLeitoActive.SetValueInt(2)
			settChanged = true
		endIf
	elseIf ((DTSConditionals as DTSleep_Conditionals).IsAtomicLustActive || DTSleep_IsZaZOut.GetValueInt() > 0)
		DTSleep_IsLeitoActive.SetValueInt(1)
	elseIf (curLAVal > 0)
		DTSleep_IsLeitoActive.SetValueInt(0)
	endIf
	
	if (DTSleep_SettingUseLeitoGun.GetValueInt() < 0 && DTSleep_IsLeitoActive.GetValueInt() >= 1)
		; init default
		DTSleep_SettingUseLeitoGun.SetValue(0.0)
	endIf
	
	return settChanged
endFunction


; **************************************
; not currently used - decided not to use rugs, but may consider other uses in future
Group D_Deprecated
FormList property DTSleep_DanceList auto const
{not used }
FormList property DTSleep_CrazyRugBedFemaleList auto const
FormList property DTSleep_CrazyRugBedMaleList auto const
FormList property DTSleep_CrazyRugStandFemaleList auto const
FormList property DTSleep_CrazyRugStandMaleList auto const
FormList property DTSleep_CompanionRomanceList auto const 
EndGroup
