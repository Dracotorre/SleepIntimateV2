;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
Scriptname Fragments:Terminals:TERM_DTSleep_OptionJacketTer_01040AAE Extends Terminal Hidden Const

;BEGIN FRAGMENT Fragment_Terminal_01
Function Fragment_Terminal_01(ObjectReference akTerminalRef)
;BEGIN CODE
(pDTSleep_MainQuest as DTSleep_MainQuestScript).CaptureJacketEquipToMark()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_02
Function Fragment_Terminal_02(ObjectReference akTerminalRef)
;BEGIN CODE
(pDTSleep_MainQuest as DTSleep_MainQuestScript).CaptureJacketUnmarkCurrent()
;rb
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_04
Function Fragment_Terminal_04(ObjectReference akTerminalRef)
;BEGIN CODE
if (pDTSleep_SettingTestMode.GetValue() > 0.0)
   pDTSleep_SettingMultiJacketOn.SetValue(2.0)
else
   pDTSleep_SettingMultiJacketOn.SetValue(0.0)
endIf
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_05
Function Fragment_Terminal_05(ObjectReference akTerminalRef)
;BEGIN CODE
pDTSleep_SettingMultiJacketOn.SetValue(1.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_06
Function Fragment_Terminal_06(ObjectReference akTerminalRef)
;BEGIN CODE
pDTSleep_SettingMultiJacketOn.SetValue(0.0)
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

Quest Property pDTSleep_MainQuest Auto Const Mandatory

GlobalVariable Property pDTSleep_SettingMultiJacketOn Auto Const Mandatory

GlobalVariable Property pDTSleep_SettingTestMode Auto Const Mandatory
