;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
Scriptname Fragments:Terminals:TERM_DTSleep_OptionTerminal_01031ED1 Extends Terminal Hidden Const

;BEGIN FRAGMENT Fragment_Terminal_05
Function Fragment_Terminal_05(ObjectReference akTerminalRef)
;BEGIN CODE
(pDTSleep_MainQuest as DTSleep_MainQuestScript).GoPlayerNaked()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_06
Function Fragment_Terminal_06(ObjectReference akTerminalRef)
;BEGIN CODE
(pDTSleep_MainQuest as DTSleep_MainQuestScript).InitSleepQuest()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_07
Function Fragment_Terminal_07(ObjectReference akTerminalRef)
;BEGIN CODE
(pDTSleep_MainQuest as DTSleep_MainQuestScript).CheckCustomGear(0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_08
Function Fragment_Terminal_08(ObjectReference akTerminalRef)
;BEGIN CODE
int totalBusy = (pDTSleep_MainQuest as DTSleep_MainQuestScript).TotalBusyDayCount
int totalExhibit =  (pDTSleep_MainQuest as DTSleep_MainQuestScript).TotalExhibitionCount

if (totalBusy > 0 || totalExhibit > 0)
   pDTSleep_TotalAchieveMessage.Show(totalBusy, totalExhibit)
endIf

int sexAppeal = (pDTSleep_MainQuest as DTSleep_MainQuestScript).PlayerSexAppeal(false, -1)
pDTSleep_IntimacySuccessMsg.Show(pDTSleep_IntimateEXP.GetValue(), sexAppeal)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_09
Function Fragment_Terminal_09(ObjectReference akTerminalRef)
;BEGIN CODE
int chance = (pDTSleep_MainQuest as DTSleep_MainQuestScript).ChanceForIntimateSceneClosestBed()

if (chance == -1)
   pDTSleep_IntimateChanceZeroPowerArmorMsg.Show()
elseIf (chance > 0)
    pDTSleep_IntimateChanceMsg.Show(chance)
else
   pDTSleep_IntimateChanceZeroMsg.Show()
endIf
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_11
Function Fragment_Terminal_11(ObjectReference akTerminalRef)
;BEGIN CODE
(pDTSleep_MainQuest as DTSleep_MainQuestScript).Shutdown()
; stops the scripts, not quest- see Uninstall to stop quest
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

GlobalVariable Property pDTSleep_SettingCamera Auto Const Mandatory

GlobalVariable Property pDTSleep_SettingIntimate Auto Const Mandatory

GlobalVariable Property pDTSleep_SettingUndress Auto Const Mandatory

Quest Property pDTSleep_MainQuest Auto Const Mandatory

Message Property pDTSleep_IntimacySuccessMsg Auto Const Mandatory

GlobalVariable Property pDTSleep_IntimateEXP Auto Const Mandatory

Message Property pDTSleep_IntimateChanceMsg Auto Const Mandatory

Message Property pDTSleep_IntimateChanceZeroMsg Auto Const Mandatory

Message Property pDTSleep_IntimateChanceZeroPowerArmorMsg Auto Const Mandatory

Message Property pDTSleep_TotalAchieveMessage Auto Const Mandatory
