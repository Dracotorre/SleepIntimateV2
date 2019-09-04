;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
Scriptname Fragments:Terminals:TERM_DTSleep_OptionsSettingT_01040312 Extends Terminal Hidden Const

;BEGIN FRAGMENT Fragment_Terminal_01
Function Fragment_Terminal_01(ObjectReference akTerminalRef)
;BEGIN CODE
pDTSleep_SettingCamera.SetValue(0.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_02
Function Fragment_Terminal_02(ObjectReference akTerminalRef)
;BEGIN CODE
pDTSleep_SettingCamera.SetValue(1.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_03
Function Fragment_Terminal_03(ObjectReference akTerminalRef)
;BEGIN CODE
pDTSleep_SettingUndress.SetValue(2.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_04
Function Fragment_Terminal_04(ObjectReference akTerminalRef)
;BEGIN CODE
pDTSleep_SettingUndress.SetValue(1.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_05
Function Fragment_Terminal_05(ObjectReference akTerminalRef)
;BEGIN CODE
pDTSleep_SettingIntimate.SetValue(2.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_06
Function Fragment_Terminal_06(ObjectReference akTerminalRef)
;BEGIN CODE
pDTSleep_SettingIntimate.SetValue(1.0)

 if (pDTSleep_IntimateTourQuest.IsRunning() && pDTSleep_SettingTourEnabled.GetValue() > 0.0)
        (pDTSleep_IntimateTourQuest as DTSleep_IntimateTourQuestScript).UpdateLocationObjectiveDisplay()
 endIf
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_07
Function Fragment_Terminal_07(ObjectReference akTerminalRef)
;BEGIN CODE
;pDTSleep_SettingTestMode.SetValue(-1.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_08
Function Fragment_Terminal_08(ObjectReference akTerminalRef)
;BEGIN CODE
pDTSleep_SettingTestMode.SetValue(-1.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_09
Function Fragment_Terminal_09(ObjectReference akTerminalRef)
;BEGIN CODE
pDTSleep_SettingTestMode.SetValue(1.0)

(pDTSleep_MainQuest as DTSleep_MainQuestScript).TestModeOutput()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_10
Function Fragment_Terminal_10(ObjectReference akTerminalRef)
;BEGIN CODE
pDTSleep_SettingUseLeitoGun.SetValue(0.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_11
Function Fragment_Terminal_11(ObjectReference akTerminalRef)
;BEGIN CODE
pDTSleep_SettingUseLeitoGun.SetValue(1.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_12
Function Fragment_Terminal_12(ObjectReference akTerminalRef)
;BEGIN CODE
pDTSleep_SettingCancelScene.SetValue(0.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_13
Function Fragment_Terminal_13(ObjectReference akTerminalRef)
;BEGIN CODE
pDTSleep_SettingCancelScene.SetValue(1.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_14
Function Fragment_Terminal_14(ObjectReference akTerminalRef)
;BEGIN CODE
pDTSleep_SettingUndress.SetValue(0.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_16
Function Fragment_Terminal_16(ObjectReference akTerminalRef)
;BEGIN CODE
pDTSleep_SettingUndressTimer.SetValue(3.20)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_17
Function Fragment_Terminal_17(ObjectReference akTerminalRef)
;BEGIN CODE
pDTSleep_SettingNapExit.SetValue(0.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_18
Function Fragment_Terminal_18(ObjectReference akTerminalRef)
;BEGIN CODE
pDTSleep_SettingNapExit.SetValue(1.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_19
Function Fragment_Terminal_19(ObjectReference akTerminalRef)
;BEGIN CODE
pDTSleep_SettingDogRestrain.SetValue(1.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_20
Function Fragment_Terminal_20(ObjectReference akTerminalRef)
;BEGIN CODE
if (pDTSleep_IsLeitoActive.GetValue() >= 2.0 && pDTSleep_AdultContentOn.GetValue() > 0.0 && pDTSleep_SettingIntimate.GetValue() > 0.0)

    pDTSleep_SettingDogRestrain.SetValue(0.0)

else
     pDTSleep_SettingDogRestrain.SetValue(-1.0)
endIf
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_21
Function Fragment_Terminal_21(ObjectReference akTerminalRef)
;BEGIN CODE
pDTSleep_SettingDogRestrain.SetValue(1.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_22
Function Fragment_Terminal_22(ObjectReference akTerminalRef)
;BEGIN CODE
pDTSleep_SettingUndressTimer.SetValue(4.50)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_23
Function Fragment_Terminal_23(ObjectReference akTerminalRef)
;BEGIN CODE
pDTSleep_SettingUndressTimer.SetValue(2.20)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_24
Function Fragment_Terminal_24(ObjectReference akTerminalRef)
;BEGIN CODE
pDTSleep_SettingChemCraft.SetValue(0.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_25
Function Fragment_Terminal_25(ObjectReference akTerminalRef)
;BEGIN CODE
pDTSleep_SettingChemCraft.SetValue(1.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_26
Function Fragment_Terminal_26(ObjectReference akTerminalRef)
;BEGIN CODE
pDTSleep_SettingUndressPipboy2.SetValue(2.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_27
Function Fragment_Terminal_27(ObjectReference akTerminalRef)
;BEGIN CODE
if (pDTSleep_SettingIntimate.GetValue() >= 1.0 && pDTSleep_AdultContentOn.GetValue() > 0.0)
   pDTSleep_SettingUndressPipboy2.SetValue(1.0)
else
   pDTSleep_SettingUndressPipboy2.SetValue(2.0)
endIf
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_28
Function Fragment_Terminal_28(ObjectReference akTerminalRef)
;BEGIN CODE
if (pDTSleep_AdultContentOn.GetValue() >= 1.0)
      pDTSleep_SettingShowIntimateCheck.SetValue(2.0)
else
    pDTSleep_SettingShowIntimateCheck.SetValue(0.0)
endIf
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_29
Function Fragment_Terminal_29(ObjectReference akTerminalRef)
;BEGIN CODE
pDTSleep_SettingShowIntimateCheck.SetValue(1.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_30
Function Fragment_Terminal_30(ObjectReference akTerminalRef)
;BEGIN CODE
pDTSleep_SettingDogRestrain.SetValue(-1.0)

if (pDTSleep_DogTrainQuest.IsRunning())
     pDTSleep_DogTrainQuest.SetStage(60)
endIf
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_31
Function Fragment_Terminal_31(ObjectReference akTerminalRef)
;BEGIN CODE
pDTSleep_SettingIntimate.SetValue(0.0)

if (pDTSleep_SettingDogRestrain.GetValue() == 0.0)
    pDTSleep_SettingDogRestrain.SetValue(1.0)
    if (pDTSleep_DogTrainQuest.IsRunning())
        pDTSleep_DogTrainQuest.SetStage(60)
    endIf
endIf

 if (pDTSleep_IntimateTourQuest.IsRunning())
        (pDTSleep_IntimateTourQuest as DTSleep_IntimateTourQuestScript).UpdateLocationObjectiveDisplay()
 endIf

; using new property
if (pDTSleep_SettingUndressPipboy2.GetValue() == 1.0)
    pDTSleep_SettingUndressPipboy2.SetValue(0.0)
endIf
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_32
Function Fragment_Terminal_32(ObjectReference akTerminalRef)
;BEGIN CODE
pDTSleep_SettingNotifications.SetValue(0.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_33
Function Fragment_Terminal_33(ObjectReference akTerminalRef)
;BEGIN CODE
pDTSleep_SettingNotifications.SetValue(1.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_34
Function Fragment_Terminal_34(ObjectReference akTerminalRef)
;BEGIN CODE
pDTSleep_SettingDogRestrain.SetValue(-1.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_35
Function Fragment_Terminal_35(ObjectReference akTerminalRef)
;BEGIN CODE
pDTSleep_SettingTourEnabled.SetValue(0.0)
if (pDTSleep_IntimateTourQuest.IsRunning())
     (pDTSleep_IntimateTourQuest as DTSleep_IntimateTourQuestScript).UpdateLocationObjectiveDisplay()
endIf
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_36
Function Fragment_Terminal_36(ObjectReference akTerminalRef)
;BEGIN CODE
pDTSleep_SettingTourEnabled.SetValue(1.0)
if (pDTSleep_IntimateTourQuest.IsRunning())
      (pDTSleep_IntimateTourQuest as DTSleep_IntimateTourQuestScript).UpdateLocationObjectiveDisplay()
     (pDTSleep_MainQuest as DTSleep_MainQuestScript).UpgradeTour()
endIf
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_37
Function Fragment_Terminal_37(ObjectReference akTerminalRef)
;BEGIN CODE
pDTSleep_SettingPrefSYSC.SetValue(0.0)
(pDTSleep_MainQuest as DTSleep_MainQuestScript).ModSYSleepDisable()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_38
Function Fragment_Terminal_38(ObjectReference akTerminalRef)
;BEGIN CODE
pDTSleep_SettingPrefSYSC.SetValue(1.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_39
Function Fragment_Terminal_39(ObjectReference akTerminalRef)
;BEGIN CODE
pDTSleep_SettingNapOnly.SetValue(2.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_40
Function Fragment_Terminal_40(ObjectReference akTerminalRef)
;BEGIN CODE
pDTSleep_SettingNapOnly.SetValue(1.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_41
Function Fragment_Terminal_41(ObjectReference akTerminalRef)
;BEGIN CODE
pDTSleep_SettingNapOnly.SetValue(3.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_42
Function Fragment_Terminal_42(ObjectReference akTerminalRef)
;BEGIN CODE
pDTSleep_SettingDogRestrain.SetValue(0.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_43
Function Fragment_Terminal_43(ObjectReference akTerminalRef)
;BEGIN CODE
(pDTSleep_MainQuest as DTSleep_MainQuestScript).ResetHelpTips()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_44
Function Fragment_Terminal_44(ObjectReference akTerminalRef)
;BEGIN CODE
pDTSleep_SettingUndressPipboy2.SetValue(0.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_45
Function Fragment_Terminal_45(ObjectReference akTerminalRef)
;BEGIN CODE
(pDTSleep_MainQuest as DTSleep_MainQuestScript).ModSetSaveOrSleepToggle()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_46
Function Fragment_Terminal_46(ObjectReference akTerminalRef)
;BEGIN CODE
(pDTSleep_MainQuest as DTSleep_MainQuestScript).ModSetSaveOrSleepToggle()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_47
Function Fragment_Terminal_47(ObjectReference akTerminalRef)
;BEGIN CODE
pDTSleep_SettingWarnLoverBusy.SetValue(0.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_48
Function Fragment_Terminal_48(ObjectReference akTerminalRef)
;BEGIN CODE
pDTSleep_SettingWarnLoverBusy.SetValue(1.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_49
Function Fragment_Terminal_49(ObjectReference akTerminalRef)
;BEGIN CODE
pDTSleep_SettingNapComp.SetValue(0.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_50
Function Fragment_Terminal_50(ObjectReference akTerminalRef)
;BEGIN CODE
pDTSleep_SettingNapComp.SetValue(1.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_51
Function Fragment_Terminal_51(ObjectReference akTerminalRef)
;BEGIN CODE
pDTSleep_SettingSave.SetValue(1.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_52
Function Fragment_Terminal_52(ObjectReference akTerminalRef)
;BEGIN CODE
pDTSleep_SettingSave.SetValue(2.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_53
Function Fragment_Terminal_53(ObjectReference akTerminalRef)
;BEGIN CODE
pDTSleep_SettingBedDecor.SetValue(0.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_54
Function Fragment_Terminal_54(ObjectReference akTerminalRef)
;BEGIN CODE
pDTSleep_SettingBedDecor.SetValue(1.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_55
Function Fragment_Terminal_55(ObjectReference akTerminalRef)
;BEGIN CODE
pDTSleep_SettingShowIntimateCheck.SetValue(0.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_56
Function Fragment_Terminal_56(ObjectReference akTerminalRef)
;BEGIN CODE
pDTSleep_SettingSave.SetValue(0.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_57
Function Fragment_Terminal_57(ObjectReference akTerminalRef)
;BEGIN CODE
pDTSleep_SettingNapOnly.SetValue(0.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_58
Function Fragment_Terminal_58(ObjectReference akTerminalRef)
;BEGIN CODE
pDTSleep_SettingSortHolotape.SetValueInt(1)
(pDTSleep_MainQuest as DTSleep_MainQuestScript).PlayerSwapHolotapes()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_59
Function Fragment_Terminal_59(ObjectReference akTerminalRef)
;BEGIN CODE
pDTSleep_SettingSortHolotape.SetValueInt(0)
(pDTSleep_MainQuest as DTSleep_MainQuestScript).PlayerSwapHolotapes()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_60
Function Fragment_Terminal_60(ObjectReference akTerminalRef)
;BEGIN CODE
pDTSleep_SettingAAF.SetValue(2.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_61
Function Fragment_Terminal_61(ObjectReference akTerminalRef)
;BEGIN CODE
pDTSleep_SettingAAF.SetValue(1.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_62
Function Fragment_Terminal_62(ObjectReference akTerminalRef)
;BEGIN CODE
pDTSleep_SettingAAF.SetValue(0.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_63
Function Fragment_Terminal_63(ObjectReference akTerminalRef)
;BEGIN CODE
pDTSleep_SettingBedOwn.SetValue(1.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_64
Function Fragment_Terminal_64(ObjectReference akTerminalRef)
;BEGIN CODE
pDTSleep_SettingBedOwn.SetValue(0.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_65
Function Fragment_Terminal_65(ObjectReference akTerminalRef)
;BEGIN CODE
pDTSleep_SettingBedOwn.SetValue(2.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_66
Function Fragment_Terminal_66(ObjectReference akTerminalRef)
;BEGIN CODE
pDTSleep_SettingMenuStyle.SetValue(2.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_67
Function Fragment_Terminal_67(ObjectReference akTerminalRef)
;BEGIN CODE
pDTSleep_SettingMenuStyle.SetValue(1.0)
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

GlobalVariable Property pDTSleep_SettingCamera Auto Const Mandatory

GlobalVariable Property pDTSleep_SettingUndress Auto Const Mandatory

GlobalVariable Property pDTSleep_SettingIntimate Auto Const Mandatory

GlobalVariable Property pDTSleep_SettingTestMode Auto Const Mandatory

GlobalVariable Property pDTSleep_SettingUseLeitoGun Auto Const Mandatory

GlobalVariable Property pDTSleep_SettingCancelScene Auto Const Mandatory

Quest Property pDTSleep_MainQuest Auto Const Mandatory

GlobalVariable Property pDTSleep_SettingDogRestrain Auto Const Mandatory

GlobalVariable Property pDTSleep_SettingUndressTimer Auto Const Mandatory

GlobalVariable Property pDTSleep_SettingChemCraft Auto Const Mandatory

GlobalVariable Property pDTSleep_SettingUndressPipboy Auto Const Mandatory

GlobalVariable Property pDTSleep_SettingShowIntimateCheck Auto Const Mandatory



GlobalVariable Property pDTSleep_IsLeitoActive Auto Const Mandatory

GlobalVariable Property pDTSleep_AdultContentOn Auto Const Mandatory

GlobalVariable Property pDTSleep_SettingNotifications Auto Const Mandatory


GlobalVariable Property pDTSleep_SettingNPCExtras Auto Const Mandatory

Quest Property pDTSleep_DogTrainQuest Auto Const Mandatory

Quest Property pDTSleep_IntimateTourQuest Auto Const Mandatory

GlobalVariable Property pDTSleep_SettingTourEnabled Auto Const Mandatory

GlobalVariable Property pDTSleep_SettingPrefSYSC Auto Const Mandatory

GlobalVariable Property pDTSleep_SettingNapOnly Auto Const Mandatory

GlobalVariable Property pDTSleep_SettingNapExit Auto Const Mandatory

GlobalVariable Property pDTSleep_SettingUndressPipboy2 Auto Const Mandatory

GlobalVariable Property pDTSleep_IsSoSActive Auto Const Mandatory

GlobalVariable Property pDTSleep_SettingWarnLoverBusy Auto Const Mandatory

GlobalVariable Property pDTSleep_SettingNapComp Auto Const Mandatory

GlobalVariable Property pDTSleep_SettingSave Auto Const Mandatory

GlobalVariable Property pDTSleep_SettingBedDecor Auto Const Mandatory

GlobalVariable Property pDTSleep_SettingPickPos Auto Const Mandatory

GlobalVariable Property pDTSleep_SettingSortHolotape Auto Const Mandatory

GlobalVariable Property pDTSleep_SettingAAF Auto Const Mandatory

GlobalVariable Property pDTSleep_SettingBedOwn Auto Const Mandatory

GlobalVariable Property pDTSleep_SettingMenuStyle Auto Const Mandatory
