Scriptname DTSleep_IntimateFlagPoleActScript extends ObjectReference Const

; ******************
; DTSleep_IntimateFlagPoleActScript for SleepIntimate
; by DracoTorre
; www.dracotorre.com/mods/sleepintimate/
; https://github.com/Dracotorre/SleepIntimateV2
;
; added for v2.22 update
;
; calls the main quest special furniture handler
;
;

DTSleep_MainQuestScript property SleepQuestScript auto const

Event OnTimer(int aiTimerID)

	if (aiTimerID == 13)
		if (SleepQuestScript != None)
			SleepQuestScript.HandlePlayerActivateFurniture(self, 101)
			SleepQuestScript.PropActivatorLock = 0
		endIf
	endIf
EndEvent

Event OnActivate(ObjectReference akActionRef)
   if (akActionRef == Game.GetPlayer())
		if (SleepQuestScript != None && SleepQuestScript.PropActivatorLock <= 0)
			SleepQuestScript.PropActivatorLock = 101			; prevent double-tap
			StartTimer(0.333, 13)
		endIf
   endif
EndEvent