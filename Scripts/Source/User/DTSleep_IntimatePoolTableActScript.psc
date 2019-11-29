Scriptname DTSleep_IntimatePoolTableActScript extends ObjectReference Const

; ******************
; DTSleep_IntimatePoolTableActScript for SleepIntimate
; by DracoTorre
; www.dracotorre.com/mods/sleepintimate/
; https://github.com/Dracotorre/SleepIntimateV2
;
; added for v2.24 update
;
; calls the main quest special furniture handler
;
;

DTSleep_MainQuestScript property SleepQuestScript auto const

Event OnTimer(int aiTimerID)

	if (aiTimerID == 13)
		if (SleepQuestScript != None)
			SleepQuestScript.HandlePlayerActivateFurniture(self, 103)
			SleepQuestScript.PropActivatorLock = 0
		endIf
	endIf
EndEvent

Event OnActivate(ObjectReference akActionRef)
   if (akActionRef == Game.GetPlayer())
		if (SleepQuestScript != None && SleepQuestScript.PropActivatorLock <= 0)
			SleepQuestScript.PropActivatorLock = 103			; prevent double-tap
			;Debug.Trace("[DTSleep_IntimatePoolTable] OnActivate")
			StartTimer(0.4, 13)
		endIf
   endif
EndEvent