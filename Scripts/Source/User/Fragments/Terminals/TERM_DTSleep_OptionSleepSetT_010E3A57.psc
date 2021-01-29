;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
Scriptname Fragments:Terminals:TERM_DTSleep_OptionSleepSetT_010E3A57 Extends Terminal Hidden Const

;BEGIN FRAGMENT Fragment_Terminal_01
Function Fragment_Terminal_01(ObjectReference akTerminalRef)
;BEGIN CODE
pDTSleep_SettingNapOnly.SetValue(2.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_02
Function Fragment_Terminal_02(ObjectReference akTerminalRef)
;BEGIN CODE
pDTSleep_SettingNapOnly.SetValue(3.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_03
Function Fragment_Terminal_03(ObjectReference akTerminalRef)
;BEGIN CODE
pDTSleep_SettingNapOnly.SetValue(1.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_04
Function Fragment_Terminal_04(ObjectReference akTerminalRef)
;BEGIN CODE
pDTSleep_SettingNapExit.SetValue(0.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_05
Function Fragment_Terminal_05(ObjectReference akTerminalRef)
;BEGIN CODE
pDTSleep_SettingNapExit.SetValue(1.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_06
Function Fragment_Terminal_06(ObjectReference akTerminalRef)
;BEGIN CODE
int cval = pDTSleep_SettingUndress.GetValueInt()
cval += 1
pDTSleep_SettingUndress.SetValueInt(cval)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_07
Function Fragment_Terminal_07(ObjectReference akTerminalRef)
;BEGIN CODE
pDTSleep_SettingUndress.SetValue(0.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_08
Function Fragment_Terminal_08(ObjectReference akTerminalRef)
;BEGIN CODE
(pDTSleep_MainQuest as DTSleep_MainQuestScript).SetRestRedressDefault()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_09
Function Fragment_Terminal_09(ObjectReference akTerminalRef)
;BEGIN CODE
pDTSleep_SettingSave.SetValue(1.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_10
Function Fragment_Terminal_10(ObjectReference akTerminalRef)
;BEGIN CODE
pDTSleep_SettingSave.SetValue(2.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_11
Function Fragment_Terminal_11(ObjectReference akTerminalRef)
;BEGIN CODE
pDTSleep_SettingSave.SetValue(0.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_12
Function Fragment_Terminal_12(ObjectReference akTerminalRef)
;BEGIN CODE
pDTSleep_SettingNapComp.SetValue(0.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_13
Function Fragment_Terminal_13(ObjectReference akTerminalRef)
;BEGIN CODE
pDTSleep_SettingNapComp.SetValue(-1.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_14
Function Fragment_Terminal_14(ObjectReference akTerminalRef)
;BEGIN CODE
pDTSleep_SettingBedDecor.SetValue(0.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_15
Function Fragment_Terminal_15(ObjectReference akTerminalRef)
;BEGIN CODE
pDTSleep_SettingBedDecor.SetValue(1.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_16
Function Fragment_Terminal_16(ObjectReference akTerminalRef)
;BEGIN CODE
pDTSleep_SettingBedOwn.SetValue(1.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_17
Function Fragment_Terminal_17(ObjectReference akTerminalRef)
;BEGIN CODE
pDTSleep_SettingBedOwn.SetValue(0.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_18
Function Fragment_Terminal_18(ObjectReference akTerminalRef)
;BEGIN CODE
pDTSleep_SettingBedOwn.SetValue(2.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_19
Function Fragment_Terminal_19(ObjectReference akTerminalRef)
;BEGIN CODE
pDTSleep_SettingPrefSYSC.SetValue(0.0)
(pDTSleep_MainQuest as DTSleep_MainQuestScript).ModSYSleepDisable()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_20
Function Fragment_Terminal_20(ObjectReference akTerminalRef)
;BEGIN CODE
pDTSleep_SettingPrefSYSC.SetValue(1.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_21
Function Fragment_Terminal_21(ObjectReference akTerminalRef)
;BEGIN CODE
(pDTSleep_MainQuest as DTSleep_MainQuestScript).ModSetSaveOrSleepToggle()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_22
Function Fragment_Terminal_22(ObjectReference akTerminalRef)
;BEGIN CODE
(pDTSleep_MainQuest as DTSleep_MainQuestScript).ModSetSaveOrSleepToggle()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_23
Function Fragment_Terminal_23(ObjectReference akTerminalRef)
;BEGIN CODE
pDTSleep_SettingUndressTimer.SetValue(3.20)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_24
Function Fragment_Terminal_24(ObjectReference akTerminalRef)
;BEGIN CODE
pDTSleep_SettingUndressTimer.SetValue(4.50)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_25
Function Fragment_Terminal_25(ObjectReference akTerminalRef)
;BEGIN CODE
pDTSleep_SettingUndressTimer.SetValue(2.20)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_27
Function Fragment_Terminal_27(ObjectReference akTerminalRef)
;BEGIN CODE
pDTSleep_SettingNapOnly.SetValue(4.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_28
Function Fragment_Terminal_28(ObjectReference akTerminalRef)
;BEGIN CODE
pDTSleep_SettingFastSleepEffect.SetValue(0.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_29
Function Fragment_Terminal_29(ObjectReference akTerminalRef)
;BEGIN CODE
pDTSleep_SettingFastSleepEffect.SetValue(1.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_30
Function Fragment_Terminal_30(ObjectReference akTerminalRef)
;BEGIN CODE
pDTSleep_SettingNapRecover.SetValue(0.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_31
Function Fragment_Terminal_31(ObjectReference akTerminalRef)
;BEGIN CODE
pDTSleep_SettingNapRecover.SetValue(1.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_32
Function Fragment_Terminal_32(ObjectReference akTerminalRef)
;BEGIN CODE
pDTSleep_SettingNapComp.SetValue(1.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_33
Function Fragment_Terminal_33(ObjectReference akTerminalRef)
;BEGIN CODE
pDTSleep_SettingIncludeExtSlots.SetValue(0.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_34
Function Fragment_Terminal_34(ObjectReference akTerminalRef)
;BEGIN CODE
pDTSleep_SettingIncludeExtSlots.SetValue(1.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_35
Function Fragment_Terminal_35(ObjectReference akTerminalRef)
;BEGIN CODE
pDTSleep_SettingNapOnly.SetValue(0.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_36
Function Fragment_Terminal_36(ObjectReference akTerminalRef)
;BEGIN CODE
pDTSleep_SettingHealthRecover.SetValue(0.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_37
Function Fragment_Terminal_37(ObjectReference akTerminalRef)
;BEGIN CODE
pDTSleep_SettingHealthRecover.SetValue(1.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_38
Function Fragment_Terminal_38(ObjectReference akTerminalRef)
;BEGIN CODE
pDTSleep_SettingUndressPipboy.SetValue(2.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_39
Function Fragment_Terminal_39(ObjectReference akTerminalRef)
;BEGIN CODE
pDTSleep_SettingUndressPipboy.SetValue(0.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_40
Function Fragment_Terminal_40(ObjectReference akTerminalRef)
;BEGIN CODE
pDTSleep_SettingUndressPipboy.SetValue(1.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_41
Function Fragment_Terminal_41(ObjectReference akTerminalRef)
;BEGIN CODE
pDTSleep_SettingUndressWeapon.SetValue(1.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_42
Function Fragment_Terminal_42(ObjectReference akTerminalRef)
;BEGIN CODE
pDTSleep_SettingUndressWeapon.SetValue(2.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_43
Function Fragment_Terminal_43(ObjectReference akTerminalRef)
;BEGIN CODE
pDTSleep_SettingUndressWeapon.SetValue(3.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_44
Function Fragment_Terminal_44(ObjectReference akTerminalRef)
;BEGIN CODE
pDTSleep_SettingUndressWeapon.SetValue(0.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_45
Function Fragment_Terminal_45(ObjectReference akTerminalRef)
;BEGIN CODE
pDTSleep_SettingRadCheck.SetValue(1.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_46
Function Fragment_Terminal_46(ObjectReference akTerminalRef)
;BEGIN CODE
pDTSleep_SettingRadCheck.SetValue(0.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_47
Function Fragment_Terminal_47(ObjectReference akTerminalRef)
;BEGIN CODE
pDTSleep_SettingRadCheck.SetValue(4.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_48
Function Fragment_Terminal_48(ObjectReference akTerminalRef)
;BEGIN CODE
pDTSleep_SettingRadCheck.SetValue(2.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_49
Function Fragment_Terminal_49(ObjectReference akTerminalRef)
;BEGIN CODE
(pDTSleep_MainQuest as DTSleep_MainQuestScript).SetToggleRedress()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_50
Function Fragment_Terminal_50(ObjectReference akTerminalRef)
;BEGIN CODE
(pDTSleep_MainQuest as DTSleep_MainQuestScript).SetToggleRedress()
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

GlobalVariable Property pDTSleep_SettingNapOnly Auto Const Mandatory

GlobalVariable Property pDTSleep_SettingNapExit Auto Const Mandatory

GlobalVariable Property pDTSleep_SettingUndress Auto Const Mandatory

GlobalVariable Property pDTSleep_SettingSave Auto Const Mandatory

GlobalVariable Property pDTSleep_SettingBedDecor Auto Const Mandatory

GlobalVariable Property pDTSleep_SettingNapComp Auto Const Mandatory

GlobalVariable Property pDTSleep_SettingBedOwn Auto Const Mandatory

GlobalVariable Property pDTSleep_SettingPrefSYSC Auto Const Mandatory

Quest Property pDTSleep_MainQuest Auto Const Mandatory

GlobalVariable Property pDTSleep_SettingUndressTimer Auto Const Mandatory

GlobalVariable Property pDTSleep_SettingFastSleepEffect Auto Const Mandatory

GlobalVariable Property pDTSleep_SettingNapRecover Auto Const Mandatory

GlobalVariable Property pDTSleep_SettingIncludeExtSlots Auto Const Mandatory

GlobalVariable Property pDTSleep_SettingHealthRecover Auto Const Mandatory

GlobalVariable Property pDTSleep_SettingUndressPipboy Auto Const Mandatory

GlobalVariable Property pDTSleep_SettingUndressWeapon Auto Const Mandatory

GlobalVariable Property pDTSleep_SettingRadCheck Auto Const Mandatory
