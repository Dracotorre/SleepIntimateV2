Scriptname DTSleep_LoverRingScript extends ObjectReference Const

; *********************
; script by DracoTorre
; Sleep Intimate
; https://www.dracotorre.com/mods/sleepintimate/
; https://github.com/Dracotorre/SleepIntimate
;
; lover's ring to restrict companion selection for bed or scenes to only the companion having ring equipped
; starts and stops the ring quest, DTSleep_TrueLoveQuest, which also has the IsAllowedLover function to tell if okay to start
;
; to avoid annoying player for re-equip on companion including mod features that force undress ring (CWSS), 
; let's delay quest stop using TrueLove quest PreparingToStop function

; ------------- properties

DTSleep_Conditionals property DTSConditionals auto const Mandatory
Quest property DTSleep_TrueLoveQuest auto const
ReferenceAlias property DTSleep_TrueLoveAlias auto const 
Faction property DTSleep_LoverRingFaction auto const
Message property DTSleep_RingNoLoveMsg auto const
GlobalVariable property DTSleep_SettingNotifications auto const
Keyword property DTSleep_LoverRingKY auto const								; added v2.64 to handle check if other ring worn


; -------------- events 

Event OnEquipped(Actor akActor)

	if (DTSleep_TrueLoveQuest != None && (DTSleep_TrueLoveQuest as DTSleep_TrueLoveQuestScript).IsAllowedLover(akActor))
		if (DTSleep_LoverRingFaction != None)
			;Debug.Trace("[DTSleep_LoverRingScript] add to lover-ring: " + akActor)
			DTSConditionals.LoverRingEquipCount += 1
			akActor.AddToFaction(DTSleep_LoverRingFaction)
			
			if (DTSleep_TrueLoveQuest.IsRunning())
			
				if (DTSleep_TrueLoveAlias != None)
					Actor ringActor = DTSleep_TrueLoveAlias.GetActorReference()
					if (ringActor != None)
						if (ringActor == akActor)
							; cancel stop
							if ((DTSleep_TrueLoveQuest as DTSleep_TrueLoveQuestScript).PreparingToStop)
								(DTSleep_TrueLoveQuest as DTSleep_TrueLoveQuestScript).CancelStop()
							endIf
						else
							; new actor - restart to force start quest log
							DTSleep_TrueLoveQuest.Stop()
							Utility.WaitMenuMode(0.2)
							DTSleep_TrueLoveQuest.Start()
						endIf
					elseIf ((DTSleep_TrueLoveQuest as DTSleep_TrueLoveQuestScript).PreparingToStop)
						; should not happen, but in case Alias error re-display existing
						(DTSleep_TrueLoveQuest as DTSleep_TrueLoveQuestScript).CancelStop()
					endIf
				endIf
			else
				DTSleep_TrueLoveQuest.Start()
			endIf
		endIf
	elseIf (DTSleep_RingNoLoveMsg != None)
		if (DTSleep_SettingNotifications == None || DTSleep_SettingNotifications.GetValue() >= 1.0)
			DTSleep_RingNoLoveMsg.Show()
		endIf
		
		; v2.64 - check if quest running without lover
		if (DTSleep_TrueLoveQuest != None && DTSleep_TrueLoveQuest.IsRunning() && DTSleep_TrueLoveAlias != None)
			Actor loverActor = DTSleep_TrueLoveAlias.GetActorReference()
			if (loverActor == None)
				Debug.Trace("[DTSleep_LoverRingScript] OnEquipped not allowed --- TrueLoveQuest running but TrueLovAlias None!  ... stopping quest")
				DTSleep_TrueLoveQuest.SetObjectiveDisplayed(10, false)		; hide objective from journal
				DTSleep_TrueLoveQuest.Stop()
			endIf
		endIf
	endIf
endEvent


Event OnUnequipped(Actor akActor)

	if (DTSleep_LoverRingFaction != None && akActor.IsInFaction(DTSleep_LoverRingFaction))
	
		if (DTSConditionals.LoverRingEquipCount > 0)
			DTSConditionals.LoverRingEquipCount -= 1
		endIf
		;Debug.Trace("[DTSleep_LoverRingScript] remove from lover-ring: " + akActor)
		
		; v2.64 - actor may have other ring so wait and check before removing from faction
		int waitCount = 3
		while (waitCount > 0 && akActor.WornHasKeyword(DTSleep_LoverRingKY))
			Utility.WaitMenuMode(0.1)
			waitCount -= 1
		endWhile
		
		if (!akActor.WornHasKeyword(DTSleep_LoverRingKY))					; v2.64
			akActor.RemoveFromFaction(DTSleep_LoverRingFaction)
		endIf
		
		if (DTSConditionals.LoverRingEquipCount <= 0)
			if (DTSleep_TrueLoveQuest != None && DTSleep_TrueLoveQuest.IsRunning())
				(DTSleep_TrueLoveQuest as DTSleep_TrueLoveQuestScript).PrepareStop()
			endIf
		elseIf (DTSleep_TrueLoveAlias != None)
			Actor loverActor = DTSleep_TrueLoveAlias.GetActorReference()
			if (loverActor != None && loverActor == akActor)
				; this actor, so restart quest to select new lover
				DTSleep_TrueLoveAlias.Clear()
				DTSleep_TrueLoveQuest.SetObjectiveDisplayed(10, false)		; hide objective from journal
				DTSleep_TrueLoveQuest.Stop()
				Utility.WaitMenuMode(0.5)
				
				if (DTSConditionals.LoverRingEquipCount > 0)		; v2.64 double check after wait in case multiple rings removed quickly
					DTSleep_TrueLoveQuest.Start()
				endIf
			endIf
			
			; still have a ring equipped out there
			Debug.Trace("[DTSleep_LoverRingScript] remain ring count: " + DTSConditionals.LoverRingEquipCount)
		endIf
	endIf
endEvent

