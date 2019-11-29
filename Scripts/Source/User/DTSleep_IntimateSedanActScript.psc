Scriptname DTSleep_IntimateSedanActScript extends ObjectReference Const

; ******************
; DTSleep_IntimateSedanActScript for SleepIntimate
; by DracoTorre
; www.dracotorre.com/mods/sleepintimate/
; https://github.com/Dracotorre/SleepIntimateV2
;
; added for v2.24 update
;
; calls the main quest special prop handler - sedan or motorcycle
;
;

DTSleep_MainQuestScript property SleepQuestScript auto const

Event OnTimer(int aiTimerID)

	if (aiTimerID == 13)
		if (SleepQuestScript != None)
			SleepQuestScript.HandlePlayerActivateFurniture(self, 102)
			SleepQuestScript.PropActivatorLock = 0
		endIf
	endIf
EndEvent

Event OnActivate(ObjectReference akActionRef)
   if (akActionRef == Game.GetPlayer())
		if (SleepQuestScript != None && SleepQuestScript.PropActivatorLock <= 0)
			SleepQuestScript.PropActivatorLock = 102			; prevent double-tap
			;Debug.Trace("[DTSleep_IntimateSedan] OnActivate")
			StartTimer(0.333, 13)
		endIf
   endif
EndEvent