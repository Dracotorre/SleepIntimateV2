;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
Scriptname Fragments:Terminals:TERM_DTSleep_OptionSleepwear_0103AF45 Extends Terminal Hidden Const

;BEGIN FRAGMENT Fragment_Terminal_01
Function Fragment_Terminal_01(ObjectReference akTerminalRef)
;BEGIN CODE
(pDTSleep_MainQuest as DTSleep_MainQuestScript).CaptureSleepwearEquipToMark()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_02
Function Fragment_Terminal_02(ObjectReference akTerminalRef)
;BEGIN CODE
(pDTSleep_MainQuest as DTSleep_MainQuestScript).CaptureSleepwearUnmarkCurrent()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_04
Function Fragment_Terminal_04(ObjectReference akTerminalRef)
;BEGIN CODE
(pDTSleep_MainQuest as DTSleep_MainQuestScript).CaptureIntimateApparelEquipToMark()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_05
Function Fragment_Terminal_05(ObjectReference akTerminalRef)
;BEGIN CODE
if (!pDTSleep_IntimateUndressQuest.IsRunning())
   pDTSleep_IntimateUndressQuest.Start()
endIf

(pDTSleep_IntimateUndressQuest as DTSleep_IntimateUndressQuestScript).UndressPlayerSleepwear(false)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_06
Function Fragment_Terminal_06(ObjectReference akTerminalRef)
;BEGIN CODE
(pDTSleep_MainQuest as DTSleep_MainQuestScript).CaptureStrapOnItemEquipToMark()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_10
Function Fragment_Terminal_10(ObjectReference akTerminalRef)
;BEGIN CODE
(pDTSleep_MainQuest as DTSleep_MainQuestScript).CaptureIntimateApparelUnmarkCurrent()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_11
Function Fragment_Terminal_11(ObjectReference akTerminalRef)
;BEGIN CODE
(pDTSleep_MainQuest as DTSleep_MainQuestScript).CaptureStrapOnUnmarkCurrent()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_12
Function Fragment_Terminal_12(ObjectReference akTerminalRef)
;BEGIN CODE
pDTSleep_SettingClothesBody.SetValue(0.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_13
Function Fragment_Terminal_13(ObjectReference akTerminalRef)
;BEGIN CODE
pDTSleep_SettingClothesBody.SetValue(3.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_14
Function Fragment_Terminal_14(ObjectReference akTerminalRef)
;BEGIN CODE
pDTSleep_SettingClothesBody.SetValue(2.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_15
Function Fragment_Terminal_15(ObjectReference akTerminalRef)
;BEGIN CODE
pDTSleep_SettingClothesBody.SetValue(1.0)
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

Quest Property pDTSleep_MainQuest Auto Const Mandatory

Quest Property pDTSleep_IntimateUndressQuest Auto Const Mandatory

GlobalVariable Property pDTSleep_SettingClothesBody Auto Const Mandatory
