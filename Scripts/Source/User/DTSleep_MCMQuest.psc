Scriptname DTSleep_MCMQuest extends Quest

Group A_Main
Quest property pDTSleep_MainQuest auto const
Actor property PlayerRef auto const
GlobalVariable property DTSleep_MCMEnable auto
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
EndGroup

string property MCMmodName = "SleepIntimate" auto const hidden

; ***************************** Events ********************************

Event OnQuestInit()
    DTSleep_MCMEnable.SetValueInt(2)
    RegisterCustomEvents()
	Debug.Trace("[DTSleep_MCM] started...")
EndEvent



; ************************************************* functions ****************

;Function OnMCMOpen()
;    RefreshMCMFromGlobals()
;    MCM.RefreshMenu()
;EndFunction

Function OnMCMSettingChange(string modName, string id)
    if (modName == MCMmodName) ; if you registered with OnMCMSettingChange|MCM_Demo this should always be true

		;Debug.Trace("[DTSleep_MCM] setting " + id + " value was changed ")
        
		if (id == "MCM_SettingTestMode:Main")
			Debug.Trace("[DTSleep_MCM] setting " + id + " value was changed to " + DTSleep_SettingTestMode.GetValue())
			if (DTSleep_SettingTestMode.GetValue() >= 1.0)
				(pDTSleep_MainQuest as DTSleep_MainQuestScript).TestModeOutput()
			endIf
		elseIf (id == "MCM_SettingSortHolotape:Main")
			(pDTSleep_MainQuest as DTSleep_MainQuestScript).PlayerSwapHolotapes()
        endIf
    endIf
EndFunction

Function RegisterCustomEvents()
   ;RegisterForExternalEvent("OnMCMOpen", "OnMCMOpen")
    RegisterForExternalEvent("OnMCMSettingChange|" + MCMmodName, "OnMCMSettingChange")
EndFunction







