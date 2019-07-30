;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
Scriptname Fragments:Terminals:TERM_DTSleep_OptionIntimacyS_010E3A58 Extends Terminal Hidden Const

;BEGIN FRAGMENT Fragment_Terminal_01
Function Fragment_Terminal_01(ObjectReference akTerminalRef)
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

if (pDTSleep_SettingUndressPipboy.GetValue() == 1.0)
    pDTSleep_SettingUndressPipboy.SetValue(0.0)
endIf
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_02
Function Fragment_Terminal_02(ObjectReference akTerminalRef)
;BEGIN CODE
pDTSleep_SettingIntimate.SetValue(2.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_03
Function Fragment_Terminal_03(ObjectReference akTerminalRef)
;BEGIN CODE
pDTSleep_SettingIntimate.SetValue(1.0)

 if (pDTSleep_IntimateTourQuest.IsRunning() && pDTSleep_SettingTourEnabled.GetValue() > 0.0)
        (pDTSleep_IntimateTourQuest as DTSleep_IntimateTourQuestScript).UpdateLocationObjectiveDisplay()
       Utility.WaitMenuMode(0.33)
      (pDTSleep_IntimateTourQuest as DTSleep_IntimateTourQuestScript).UpdateLocationCount(true)
endIf
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_04
Function Fragment_Terminal_04(ObjectReference akTerminalRef)
;BEGIN CODE
pDTSleep_SettingTourEnabled.SetValue(0.0)
if (pDTSleep_IntimateTourQuest.IsRunning())
     (pDTSleep_IntimateTourQuest as DTSleep_IntimateTourQuestScript).UpdateLocationObjectiveDisplay()
endIf
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_05
Function Fragment_Terminal_05(ObjectReference akTerminalRef)
;BEGIN CODE
pDTSleep_SettingTourEnabled.SetValue(1.0)
if (pDTSleep_IntimateTourQuest.IsRunning())
      (pDTSleep_IntimateTourQuest as DTSleep_IntimateTourQuestScript).UpdateLocationObjectiveDisplay()
      Utility.WaitMenuMode(0.33)
     (pDTSleep_IntimateTourQuest as DTSleep_IntimateTourQuestScript).UpdateLocationCount(true)
endIf
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_06
Function Fragment_Terminal_06(ObjectReference akTerminalRef)
;BEGIN CODE
pDTSleep_SettingCancelScene.SetValue(0.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_07
Function Fragment_Terminal_07(ObjectReference akTerminalRef)
;BEGIN CODE
pDTSleep_SettingCancelScene.SetValue(1.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_08
Function Fragment_Terminal_08(ObjectReference akTerminalRef)
;BEGIN CODE
pDTSleep_SettingDogRestrain.SetValue(-1.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_09
Function Fragment_Terminal_09(ObjectReference akTerminalRef)
;BEGIN CODE
pDTSleep_SettingUseLeitoGun.SetValue(0.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_10
Function Fragment_Terminal_10(ObjectReference akTerminalRef)
;BEGIN CODE
pDTSleep_SettingDogRestrain.SetValue(1.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_11
Function Fragment_Terminal_11(ObjectReference akTerminalRef)
;BEGIN CODE
pDTSleep_SettingUseBT2Gun.SetValue(0.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_12
Function Fragment_Terminal_12(ObjectReference akTerminalRef)
;BEGIN CODE
pDTSleep_SettingDogRestrain.SetValue(1.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_13
Function Fragment_Terminal_13(ObjectReference akTerminalRef)
;BEGIN CODE
pDTSleep_SettingDogRestrain.SetValue(-1.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_14
Function Fragment_Terminal_14(ObjectReference akTerminalRef)
;BEGIN CODE
pDTSleep_SettingWarnLoverBusy.SetValue(0.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_15
Function Fragment_Terminal_15(ObjectReference akTerminalRef)
;BEGIN CODE
pDTSleep_SettingWarnLoverBusy.SetValue(1.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_16
Function Fragment_Terminal_16(ObjectReference akTerminalRef)
;BEGIN CODE
pDTSleep_SettingAAF.SetValue(1.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_17
Function Fragment_Terminal_17(ObjectReference akTerminalRef)
;BEGIN CODE
pDTSleep_SettingAAF.SetValue(2.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_18
Function Fragment_Terminal_18(ObjectReference akTerminalRef)
;BEGIN CODE
pDTSleep_SettingAAF.SetValue(0.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_19
Function Fragment_Terminal_19(ObjectReference akTerminalRef)
;BEGIN CODE
pDTSleep_SettingUseLeitoGun.SetValue(2.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_20
Function Fragment_Terminal_20(ObjectReference akTerminalRef)
;BEGIN CODE
pDTSleep_SettingUseLeitoGun.SetValue(1.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_22
Function Fragment_Terminal_22(ObjectReference akTerminalRef)
;BEGIN CODE
if (pDTSleep_AdultContentOn.GetValue() >= 2.0)
      pDTSleep_SettingShowIntimateCheck.SetValue(2.0)
else
    pDTSleep_SettingShowIntimateCheck.SetValue(0.0)
endIf
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_23
Function Fragment_Terminal_23(ObjectReference akTerminalRef)
;BEGIN CODE
pDTSleep_SettingShowIntimateCheck.SetValue(0.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_24
Function Fragment_Terminal_24(ObjectReference akTerminalRef)
;BEGIN CODE
pDTSleep_SettingShowIntimateCheck.SetValue(1.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_25
Function Fragment_Terminal_25(ObjectReference akTerminalRef)
;BEGIN CODE
pDTSleep_SettingDoAffinity.SetValue(0.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_26
Function Fragment_Terminal_26(ObjectReference akTerminalRef)
;BEGIN CODE
pDTSleep_SettingDoAffinity.SetValue(1.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_27
Function Fragment_Terminal_27(ObjectReference akTerminalRef)
;BEGIN CODE
pDTSleep_SettingGenderPref.SetValue(0.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_28
Function Fragment_Terminal_28(ObjectReference akTerminalRef)
;BEGIN CODE
pDTSleep_SettingGenderPref.SetValue(1.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_29
Function Fragment_Terminal_29(ObjectReference akTerminalRef)
;BEGIN CODE
pDTSleep_SettingGenderPref.SetValue(2.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_30
Function Fragment_Terminal_30(ObjectReference akTerminalRef)
;BEGIN CODE
pDTSleep_SettingGenderPref.SetValue(2.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_31
Function Fragment_Terminal_31(ObjectReference akTerminalRef)
;BEGIN CODE
pDTSleep_SettingPilloryEnabled.SetValue(0.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_32
Function Fragment_Terminal_32(ObjectReference akTerminalRef)
;BEGIN CODE
pDTSleep_SettingPilloryEnabled.SetValue(1.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_33
Function Fragment_Terminal_33(ObjectReference akTerminalRef)
;BEGIN CODE
if (pDTSleep_AdultContentOn.GetValue() >= 2.0 && pDTSleep_ActivChairs.GetValue() >= 2.0)
   pDTSleep_SettingChairsEnabled.SetValue(2.0)
else
   pDTSleep_SettingChairsEnabled.SetValue(0.0)
endIf
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_34
Function Fragment_Terminal_34(ObjectReference akTerminalRef)
;BEGIN CODE
pDTSleep_SettingChairsEnabled.SetValue(1.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_35
Function Fragment_Terminal_35(ObjectReference akTerminalRef)
;BEGIN CODE
pDTSleep_SettingLover2.SetValue(0.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_36
Function Fragment_Terminal_36(ObjectReference akTerminalRef)
;BEGIN CODE
pDTSleep_SettingLover2.SetValue(1.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_37
Function Fragment_Terminal_37(ObjectReference akTerminalRef)
;BEGIN CODE
pDTSleep_SettingChairsEnabled.SetValue(0.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_38
Function Fragment_Terminal_38(ObjectReference akTerminalRef)
;BEGIN CODE
pDTSleep_SettingChairsEnabled.SetValue(0.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_39
Function Fragment_Terminal_39(ObjectReference akTerminalRef)
;BEGIN CODE
pDTSleep_SettingCrime.SetValue(0.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_40
Function Fragment_Terminal_40(ObjectReference akTerminalRef)
;BEGIN CODE
pDTSleep_SettingCrime.SetValue(1.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_41
Function Fragment_Terminal_41(ObjectReference akTerminalRef)
;BEGIN CODE
pDTSleep_SettingFadeEndScene.SetValue(0.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_42
Function Fragment_Terminal_42(ObjectReference akTerminalRef)
;BEGIN CODE
pDTSleep_SettingFadeEndScene.SetValue(1.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_43
Function Fragment_Terminal_43(ObjectReference akTerminalRef)
;BEGIN CODE
pDTSleep_SettingUseBT2Gun.SetValue(1.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_44
Function Fragment_Terminal_44(ObjectReference akTerminalRef)
;BEGIN CODE
pDTSleep_SettingAltFemBody.SetValue(2.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_45
Function Fragment_Terminal_45(ObjectReference akTerminalRef)
;BEGIN CODE
pDTSleep_SettingAltFemBody.SetValue(1.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_46
Function Fragment_Terminal_46(ObjectReference akTerminalRef)
;BEGIN CODE
pDTSleep_SettingAltFemBody.SetValue(3.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_47
Function Fragment_Terminal_47(ObjectReference akTerminalRef)
;BEGIN CODE
pDTSleep_SettingAltFemBody.SetValue(0.0)
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

GlobalVariable Property pDTSleep_SettingIntimate Auto Const Mandatory

GlobalVariable Property pDTSleep_SettingDogRestrain Auto Const Mandatory

Quest Property pDTSleep_DogTrainQuest Auto Const Mandatory

Quest Property pDTSleep_IntimateTourQuest Auto Const Mandatory

GlobalVariable Property pDTSleep_SettingCancelScene Auto Const Mandatory

GlobalVariable Property pDTSleep_SettingUndressPipboy Auto Const Mandatory

GlobalVariable Property pDTSleep_SettingTourEnabled Auto Const Mandatory

Quest Property pDTSleep_MainQuest Auto Const Mandatory

GlobalVariable Property pDTSleep_IsLeitoActive Auto Const Mandatory

GlobalVariable Property pDTSleep_AdultContentOn Auto Const Mandatory

GlobalVariable Property pDTSleep_SettingWarnLoverBusy Auto Const Mandatory

GlobalVariable Property pDTSleep_SettingAAF Auto Const Mandatory

GlobalVariable Property pDTSleep_SettingUseLeitoGun Auto Const Mandatory

GlobalVariable Property pDTSleep_SettingShowIntimateCheck Auto Const Mandatory

GlobalVariable Property pDTSleep_SettingDoAffinity Auto Const Mandatory

GlobalVariable Property pDTSleep_SettingGenderPref Auto Const Mandatory

GlobalVariable Property pDTSleep_SettingPilloryEnabled Auto Const Mandatory

GlobalVariable Property pDTSleep_SettingChairsEnabled Auto Const Mandatory

GlobalVariable Property pDTSleep_SettingLover2 Auto Const Mandatory

GlobalVariable Property pDTSleep_ActivChairs Auto Const Mandatory

GlobalVariable Property pDTSleep_SettingCrime Auto Const Mandatory

GlobalVariable Property pDTSleep_SettingFadeEndScene Auto Const Mandatory

GlobalVariable Property pDTSleep_IntimateDogExp Auto Const Mandatory

GlobalVariable Property pDTSleep_SettingUseBT2Gun Auto Const Mandatory

GlobalVariable Property pDTSleep_SettingAltFemBody Auto Const Mandatory
