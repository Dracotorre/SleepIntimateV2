Scriptname DTSleep_MCMQuest extends Quest

Group A_Main
Quest property pDTSleep_MainQuest auto const
Quest property pDTSleep_IntimateTourQuest auto const
Actor property PlayerRef auto const
GlobalVariable property DTSleep_MCMEnable auto
GlobalVariable property DTSleep_PlayerEquipBackpackCount auto const
GlobalVariable property DTSleep_EquipModInit auto const
GlobalVariable property DTSleep_PlayerEquipSleepwearCount auto const
GlobalVariable property DTSleep_PlayerEquipIntimateItemCount auto const
GlobalVariable property DTSleep_PlayerEquipStrapOnCount auto const
GlobalVariable property DTSleep_PlayerEquipJacketCount auto const
GlobalVariable property DTSleep_PlayerEquipNecklaceChokerCount auto const
GlobalVariable property DTSleep_PlayerEquipMaskCount auto const
GlobalVariable property DTSleep_PlayerEquipExtraPartsCount auto const
GlobalVariable property DTSleep_CaptureExtraPartsEnabled auto const
GlobalVariable property DTSleep_PlayerUndressed auto const
GlobalVariable property DTSleep_CompanionUndressed auto const
GlobalVariable property DTSleep_ActivChairs auto const
GlobalVariable property DTSleep_IsSoSActive2 auto const
GlobalVariable property DTSleep_IsSoSActive auto const
{ deprecated }
EndGroup

Group B_Global_Settings
GlobalVariable property DTSleep_SettingUndress auto
{setting to disable = 0 / situational = 1 / always = 2 undressing in bed }
GlobalVariable property DTSleep_SettingIntimate auto
{ setting to get intimate with lover after waking }
GlobalVariable property DTSleep_SettingCancelScene auto
GlobalVariable property DTSleep_SettingDogRestrain auto
GlobalVariable property DTSleep_SettingTestMode auto
GlobalVariable property DTSleep_SettingUndressPipboy auto
GlobalVariable property DTSleep_SettingShowIntimateCheck auto
GlobalVariable property DTSleep_SettingNotifications auto
GlobalVariable property DTSleep_SettingNapOnly auto
GlobalVariable property DTSleep_SettingNapRecover auto
GlobalVariable property DTSleep_SettingNapExit auto
GlobalVariable property DTSleep_SettingTourEnabled auto
GlobalVariable property DTSleep_SettingWarnLoverBusy auto
GlobalVariable property DTSleep_SettingNapComp auto
GlobalVariable property DTSleep_SettingSave auto
GlobalVariable property DTSleep_SettingCamera auto
GlobalVariable property DTSleep_SettingChemCraft auto
GlobalVariable property DTSleep_SettingModActive auto const
GlobalVariable property DTSleep_SettingModMCMCtl auto const
GlobalVariable property DTSleep_UndressCarryBonus auto const
GlobalVariable property DTSleep_SettingChairsEnabled auto const
EndGroup

string property MCMmodName = "SleepIntimate" auto const hidden
int property MCMBackpackNotFound = 0 auto hidden
int property MCMAAFReady = 0 auto hidden
int property MCMAAFEnabled = 0 auto hidden
int property MCMAAFDisabled = 0 auto hidden
int property MCMAdultModsOn = 0 auto hidden
int property MCMAdultModsOff = 0 auto hidden
int property MCMAdultSexSeatsOff = 1 auto hidden
int property MCMAdultSexSeatsOn = 0 auto hidden
int property MCMUndressReady = 0 auto hidden
int property MCMUndressNeedInit = 0 auto hidden
int property MCMBackpackCarry = 0 auto hidden
int property MCMSleepClothesNotFound = 0 auto hidden
int property MCMStrapOnNotFound = 0 auto hidden
int property MCMPlayerFemale = -1 auto hidden
int property MCMPlayerDressed = 0 auto hidden
int property MCMCompanionDressed = 0 auto hidden
int property MCMCompanionUndressed = 0 auto hidden
int property MCMJacketNotFound = 0 auto hidden
int property MCMJacketOneFound = 0 auto hidden
int property MCMJacketTwoFound = 0 auto hidden
int property MCMMaskNotFound = 0 auto hidden
int property MCMNecklaceEquipped = 0 auto hidden
int property MCMNecklaceNotFound = 0 auto hidden
int property MCMExtraPartsEquipped = 0 auto hidden
int property MCMExtraPartsNotFound = 0 auto hidden
int property MCMIntimateEnabled = 0 auto hidden
int property MCMIntimateDisabled = 0 auto hidden
int property MCMUndressCheckStopped = 0 auto hidden
int property MCMUndressCheckStarted = 0 auto hidden
int property MCMUndressEnabled = 0 auto hidden
int property MCMUndressDisabled = 0 auto hidden
int property MCMSoSActiveOn = 0 auto hidden
int property MCMSoSActiveOff = 0 auto hidden

; ***************************** Events ********************************

Event OnQuestInit()
    DTSleep_MCMEnable.SetValueInt(2)
    RegisterCustomEvents()
	Update(false)

EndEvent


; ************************************************* functions ****************

Function DoOnLoad()
	;Debug.Trace("[DTSleep_MCM] onPlayerLoad")
    RegisterCustomEvents()
	Update(true)
EndFunction

Function OnMCMOpen()

	Update(true)
EndFunction

Function OnMCMSettingChange(string modName, string id)
    if (modName == MCMmodName) ; if you registered with OnMCMSettingChange|MCM_Demo this should always be true

		;Debug.Trace("[DTSleep_MCM] setting " + id + " value was changed ")
        
		if (id == "MCM_SettingModMCMCtl:Main")
			int setReq = DTSleep_SettingModMCMCtl.GetValueInt()
			int modActive = DTSleep_SettingModActive.GetValueInt()
			
			if (setReq == 0 && modActive >= 2)
				(pDTSleep_MainQuest as DTSleep_MainQuestScript).Shutdown()
			elseIf (setReq == 1 && modActive <= 1)
				(pDTSleep_MainQuest as DTSleep_MainQuestScript).InitSleepQuest()
			elseIf (modActive >= 2)
				DTSleep_SettingModMCMCtl.SetValueInt(1)
			else
				DTSleep_SettingModMCMCtl.SetValueInt(0)
			endIf
		elseIf (id == "MCM_SettingTestMode:Main")
			;Debug.Trace("[DTSleep_MCM] setting " + id + " value was changed to " + DTSleep_SettingTestMode.GetValue())
			if (DTSleep_SettingTestMode.GetValue() >= 1.0)
				(pDTSleep_MainQuest as DTSleep_MainQuestScript).TestModeOutput()
			endIf
			MCM.RefreshMenu()
		elseIf (id == "MCM_SettingSortHolotape:Main")
			(pDTSleep_MainQuest as DTSleep_MainQuestScript).PlayerSwapHolotapes()
		elseIf (id == "MCM_SettingAAF:Intimacy")
		
			UpdateAdultValues()
			MCM.RefreshMenu()
		elseIf (id == "MCM_UndressCarryBonus:Backpack")
			SetBackpackCarryBonusLevel(MCMBackpackCarry)
		elseIf (id == "MCM_SettingTourEnabled:Intimacy")
			if (DTSleep_SettingTourEnabled.GetValueInt() > 0)
				if (pDTSleep_IntimateTourQuest.IsRunning())
					(pDTSleep_IntimateTourQuest as DTSleep_IntimateTourQuestScript).UpdateLocationObjectiveDisplay()
					Utility.WaitMenuMode(0.33)
					(pDTSleep_IntimateTourQuest as DTSleep_IntimateTourQuestScript).UpdateLocationCount(true)
				endIf
			elseIf (pDTSleep_IntimateTourQuest.IsRunning())
				(pDTSleep_IntimateTourQuest as DTSleep_IntimateTourQuestScript).UpdateLocationObjectiveDisplay()
			endIf
        endIf
    endIf
EndFunction

Function RegisterCustomEvents()
    RegisterForExternalEvent("OnMCMOpen", "OnMCMOpen")
    RegisterForExternalEvent("OnMCMSettingChange|" + MCMmodName, "OnMCMSettingChange")
EndFunction

Function GoCompanionNaked(float val)
	(pDTSleep_MainQuest as DTSleep_MainQuestScript).GoNearbyCompanionInLoveUndressForBedMCM()
EndFunction

Function GoCompanionRedress(float val)
	(pDTSleep_MainQuest as DTSleep_MainQuestScript).GoCompanionRedressMCM()
EndFunction

Function GoPlayerNaked(float val)
	(pDTSleep_MainQuest as DTSleep_MainQuestScript).GoPlayerNakedMCM()
EndFunction

Function MarkBackpack(float val)
	
	if (DTSleep_PlayerEquipBackpackCount.GetValueInt() > 0)
		(pDTSleep_MainQuest as DTSleep_MainQuestScript).CaptureBackpackUnmarkCurrent()
	else
		(pDTSleep_MainQuest as DTSleep_MainQuestScript).CaptureBackpackEquipToMark()
	endIf
EndFunction

Function MarkIntimateOutfit(float val)
	if (DTSleep_PlayerEquipIntimateItemCount.GetValueInt() > 0)
		(pDTSleep_MainQuest as DTSleep_MainQuestScript).CaptureIntimateApparelUnmarkCurrent()
	else
		(pDTSleep_MainQuest as DTSleep_MainQuestScript).CaptureIntimateApparelEquipToMark()
	endIf
EndFunction

Function MarkItemAsStrapOn(float val)
	if (DTSleep_PlayerEquipStrapOnCount.GetValueInt() > 0)
		(pDTSleep_MainQuest as DTSleep_MainQuestScript).CaptureStrapOnUnmarkCurrent()
	else
		(pDTSleep_MainQuest as DTSleep_MainQuestScript).CaptureStrapOnItemEquipToMark()
	endIf
EndFunction

Function MarkJacket(float val)
	if (DTSleep_PlayerEquipJacketCount.GetValueInt() > 0)
		(pDTSleep_MainQuest as DTSleep_MainQuestScript).CaptureJacketUnmarkCurrent()
	else
		(pDTSleep_MainQuest as DTSleep_MainQuestScript).CaptureJacketEquipToMark()
	endIf
EndFunction

Function MarkMask(float val)
	if (DTSleep_PlayerEquipMaskCount.GetValueInt() > 0)
		(pDTSleep_MainQuest as DTSleep_MainQuestScript).CaptureMaskUnmarkCurrent()
	else
		(pDTSleep_MainQuest as DTSleep_MainQuestScript).CaptureMaskEquipToMark()
	endIf
EndFunction

Function MarkSleepOutfit(float val)
	if (DTSleep_PlayerEquipSleepwearCount.GetValueInt() > 0)
		(pDTSleep_MainQuest as DTSleep_MainQuestScript).CaptureSleepwearUnmarkCurrent()
	else
		(pDTSleep_MainQuest as DTSleep_MainQuestScript).CaptureSleepwearEquipToMark()
	endIf
EndFunction

Function ScanModsForGear(float val)
	
	(pDTSleep_MainQuest as DTSleep_MainQuestScript).CheckCustomGear(0)
EndFunction

Function SetBackpackCarryBonusLevel(int level)

	if (level <= 0)
		DTSleep_UndressCarryBonus.SetValue(50.0)
	elseIf (level == 1)
		DTSleep_UndressCarryBonus.SetValue(100.0)
	elseIf (level == 2)
		DTSleep_UndressCarryBonus.SetValue(300.0)
	elseIf (level >= 3)
		DTSleep_UndressCarryBonus.SetValue(1000.0)
	endIf
		
EndFunction

Function SleepOrSaveToggle(float val)
	(pDTSleep_MainQuest as DTSleep_MainQuestScript).ModSetSaveOrSleepToggle()
	UpdateSoS()
	MCM.RefreshMenu()
EndFunction

Function StartUndressCheck(float val)
	;Debug.Trace("[DTSleep_MCM] StartUndressCheck")
	DTSleep_CaptureExtraPartsEnabled.SetValue(Utility.GetCurrentGameTime())

EndFunction

Function StopUndressCheck(float val)
	DTSleep_CaptureExtraPartsEnabled.SetValue(0.0)

	(pDTSleep_MainQuest as DTSleep_MainQuestScript).RedressCompanion()
EndFunction

Function SetRestoreDefaults(float val)

	(pDTSleep_MainQuest as DTSleep_MainQuestScript).RestoreSettingsDefault()
EndFunction

Function ToggleChairScenes(float val)
	
	int chairVal = 1 + DTSleep_SettingChairsEnabled.GetValueInt()
	if (chairVal < 0)
		chairVal == 1
	endIf
	
	if (DTSleep_ActivChairs.GetValue() < 1.6)					; v2.72 - Leito-only is 1.6, 2.0 for normal
		
		if (chairVal > 1)
			chairVal = 0
		endIf
		
	elseIf (chairVal > 2)
		chairVal = 0
	endIf
	
	DTSleep_SettingChairsEnabled.SetValueInt(chairVal)
EndFunction

Function ToggleRedress(float val)
	(pDTSleep_MainQuest as DTSleep_MainQuestScript).SetToggleRedress()
EndFunction

Function WakePlayer(float val)
	if (Game.IsActivateControlsEnabled())
		(pDTSleep_MainQuest as DTSleep_MainQuestScript).PlayerSleepAwake(false)
	endIf
EndFunction


Function Update(bool doRefresh)
	if (MCMPlayerFemale < 0)
		ActorBase actBase = PlayerRef.GetBaseObject() as ActorBase
		MCMPlayerFemale = actBase.GetSex()
	endIf
	UpdateAdultValues()
	UpdateIntimateUndressValues()
	
	
	if (DTSleep_EquipModInit.GetValue() >= 5.0)
		MCMUndressReady = 1
		MCMUndressNeedInit = 0
	else
		MCMUndressReady = 0
		MCMUndressNeedInit = 1
	endIf
	if (DTSleep_PlayerEquipBackpackCount.GetValueInt() > 0)
		MCMBackpackNotFound = 0
	else
		MCMBackpackNotFound = 1
	endIf
	int carryBonus = DTSleep_UndressCarryBonus.GetValueInt()
	if (carryBonus <= 75)
		MCMBackpackCarry = 0
	elseIf (carryBonus <= 150)
		MCMBackpackCarry = 1
	elseIf (carryBonus <= 500)
		MCMBackpackCarry = 2
	else
		MCMBackpackCarry = 3
	endIf
	if (DTSleep_PlayerEquipSleepwearCount.GetValueInt() <= 0 && DTSleep_PlayerEquipIntimateItemCount.GetValueInt() <= 0)
		MCMSleepClothesNotFound = 1
	else
		MCMSleepClothesNotFound = 0
	endIf

	if (DTSleep_PlayerEquipStrapOnCount.GetValueInt() <= 0)
		MCMStrapOnNotFound = 1
	else
		MCMStrapOnNotFound = 0
	endIf
	
	int jacketCount = DTSleep_PlayerEquipJacketCount.GetValueInt()
	if (jacketCount <= 0)
		MCMJacketNotFound = 1
		MCMJacketOneFound = 0
		MCMJacketTwoFound = 0
	elseIf (jacketCount == 1)
		MCMJacketNotFound = 0
		MCMJacketOneFound = 1
		MCMJacketTwoFound = 0
	else
		MCMJacketNotFound = 0
		MCMJacketOneFound = 0
		MCMJacketTwoFound = 1
	endIf
	if (DTSleep_PlayerEquipExtraPartsCount.GetValueInt() > 0)
		MCMExtraPartsEquipped = 1
		MCMExtraPartsNotFound = 0
	else
		MCMExtraPartsEquipped = 0
		MCMExtraPartsNotFound = 1
	endIf
	if (DTSleep_PlayerEquipMaskCount.GetValueInt() <= 0)
		MCMMaskNotFound = 1
	else
		MCMMaskNotFound = 0
	endIf
	if (DTSleep_PlayerEquipNecklaceChokerCount.GetValueInt() > 0)
		MCMNecklaceEquipped = 1
		MCMNecklaceNotFound = 0
	else
		MCMNecklaceEquipped = 0
		MCMNecklaceNotFound = 1
	endIf
	
	if (DTSleep_CaptureExtraPartsEnabled.GetValueInt() > 0)
		MCMUndressCheckStarted = 1
		MCMUndressCheckStopped = 0
	else
		MCMUndressCheckStarted = 0
		MCMUndressCheckStopped = 1
	endIf
	
	if (DTSleep_PlayerUndressed.GetValue() <= 0.0)
		MCMPlayerDressed = 1
	else
		MCMPlayerDressed = 0
	endIf
	
	if (DTSleep_CompanionUndressed.GetValue() <= 0.0)
		MCMCompanionDressed = 1
		MCMCompanionUndressed = 0
	else
		MCMCompanionDressed = 0
		MCMCompanionUndressed = 1
	endIf
	UpdateSoS()
	
	if (doRefresh)
		MCM.RefreshMenu()
	endIf
EndFunction

Function UpdateAdultValues()
	bool adultOn = false
	if ((pDTSleep_MainQuest as DTSleep_MainQuestScript).IsAdultAnimationAvailable())
		MCMAdultModsOn = 1
		MCMAdultModsOff = 0
		adultOn = true
		if ((pDTSleep_MainQuest as DTSleep_MainQuestScript).IsAAFInstalled())
			MCMAAFReady = 1
		endIf
		if ((pDTSleep_MainQuest as DTSleep_MainQuestScript).IsAAFReady())
			MCMAAFEnabled = 1
			MCMAAFDisabled = 0
		else
			MCMAAFEnabled = 0
			MCMAAFDisabled = 1
		endIf
	else
		MCMAdultModsOn = 0
		MCMAdultModsOff = 1
		MCMAAFReady = 0
		MCMAAFEnabled = 0
		MCMAAFDisabled = 1
	endIf
	
	if (adultOn && DTSleep_ActivChairs.GetValue() >= 1.60)					; v2.72 - Leito-only is 1.6
		MCMAdultSexSeatsOn = 1
		MCMAdultSexSeatsOff = 0
	else
		MCMAdultSexSeatsOn = 0
		MCMAdultSexSeatsOff = 1
	endIf
EndFunction

Function UpdateIntimateUndressValues()
	if (DTSleep_SettingIntimate.GetValueInt() > 0)
		MCMIntimateDisabled = 0
		MCMIntimateEnabled = 1
	else
		MCMIntimateDisabled = 1
		MCMIntimateEnabled = 0
	endIf
	if (DTSleep_SettingUndress.GetValueInt() > 0)
		MCMUndressDisabled = 0
		MCMUndressEnabled = 1
	else
		MCMUndressDisabled = 1
		MCMUndressEnabled = 0
	endIf
EndFunction

Function UpdateSoS()

	if (DTSleep_IsSoSActive2 != None)
		int sosVal = DTSleep_IsSoSActive2.GetValueInt()
		if (sosVal >= 2)
			MCMSoSActiveOn = 1
			MCMSoSActiveOff = 0
		elseIf (sosVal == 1)
			MCMSoSActiveOn = 0
			MCMSoSActiveOff = 1
		else
			MCMSoSActiveOn = 0
			MCMSoSActiveOff = 0
		endIf
	endIf

EndFunction


