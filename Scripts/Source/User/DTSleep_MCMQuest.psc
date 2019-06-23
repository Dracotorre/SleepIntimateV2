Scriptname DTSleep_MCMQuest extends Quest

Group A_Main
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


Event OnQuestInit()
    DTSleep_MCMEnable.SetValueInt(2)
    ;RegisterForRemoteEvent(PlayerRef, "OnPlayerLoadGame")
    ;RegisterCustomEvents()
    ;RefreshMCMFromGlobals()
	Debug.Trace("[DTSleep_MCM] started...")
EndEvent

Event Actor.OnPlayerLoadGame(Actor akSender)
    ;RegisterCustomEvents()
    ;RefreshMCMFromGlobals()
EndEvent

Function OnMCMOpen()
    RefreshMCMFromGlobals()
    MCM.RefreshMenu()
EndFunction

Function OnMCMSettingChange(string modName, string id)
    
EndFunction


; Function RefreshMCMFromGlobals()
	; Debug.Trace("[DTSleep_MCM] refresh from globs")
	; MCM.SetModSettingInt(MCMmodName, "MCM_SettingCamera:Main", DTSleep_SettingCamera.GetValueInt())
	; MCM.SetModSettingInt(MCMmodName, "MCM_SettingCancelScene:Intimacy", DTSleep_SettingCancelScene.GetValueInt())
	; MCM.SetModSettingInt(MCMmodName, "MCM_SettingChemCraft:Main", DTSleep_SettingChemCraft.GetValueInt())
	; MCM.SetModSettingInt(MCMmodName, "MCM_SettingIntimate:Rest", DTSleep_SettingIntimate.GetValueInt())
	; MCM.SetModSettingInt(MCMmodName, "MCM_SettingNapComp:Rest", DTSleep_SettingNapComp.GetValueInt())
	; MCM.SetModSettingInt(MCMmodName, "MCM_SettingNapExit:Rest", DTSleep_SettingNapExit.GetValueInt())
	; MCM.SetModSettingInt(MCMmodName, "MCM_SettingNapOnly:Rest", DTSleep_SettingNapOnly.GetValueInt())
	; MCM.SetModSettingInt(MCMmodName, "MCM_SettingNapRecover:Rest", DTSleep_SettingNapRecover.GetValueInt())
	; MCM.SetModSettingInt(MCMmodName, "MCM_SettingNotifications:Main", DTSleep_SettingNotifications.GetValueInt())
	; MCM.SetModSettingInt(MCMmodName, "MCM_SettingSave:Rest", DTSleep_SettingSave.GetValueInt())
	; MCM.SetModSettingInt(MCMmodName, "MCM_SettingShowIntimateCheck:Intimacy", DTSleep_SettingShowIntimateCheck.GetValueInt())
	; MCM.SetModSettingInt(MCMmodName, "MCM_SettingTestMode:Main", DTSleep_SettingTestMode.GetValueInt())
	; MCM.SetModSettingInt(MCMmodName, "MCM_SettingTourEnabled:Intimacy", DTSleep_SettingTourEnabled.GetValueInt())
	; MCM.SetModSettingInt(MCMmodName, "MCM_SettingUndress:Rest", DTSleep_SettingUndress.GetValueInt())
	; MCM.SetModSettingInt(MCMmodName, "MCM_SettingUndressPipboy:Intimacy", DTSleep_SettingUndressPipboy.GetValueInt())
	; MCM.SetModSettingInt(MCMmodName, "MCM_SettingWarnLoverBusy:Intimacy", DTSleep_SettingWarnLoverBusy.GetValueInt())
	
; EndFunction

Function RegisterCustomEvents()
    RegisterForExternalEvent("OnMCMOpen", "OnMCMOpen")
    RegisterForExternalEvent("OnMCMSettingChange|" + MCMmodName, "OnMCMSettingChange")
EndFunction


; Function UpdateGlobalInt(GlobalVariable gv, string id)
	
	; int val = MCM.GetModSettingInt(MCMmodName, id)
	; Debug.Trace("[DTSleep_MCM] update GV " + gv + " id: " + id + " to val: " + val)
	; if (val >= 0)
		; gv.SetValueInt(val)
	; endIf
	; MCM.RefreshMenu()
; EndFunction




