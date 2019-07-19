Scriptname DTSleep_SpectatorQuestScript extends Quest

; ******************
; DTSleep_SpectatorQuestScript for SleepIntimate
; by DracoTorre
; www.dracotorre.com/mods/sleepintimate/
; https://github.com/Dracotorre/SleepIntimate
;
; added v1.70 for v2 release
; 
; spectators limited to companions and guards - no settlers to avoid upsetting their delicate packages :)
; guards may report crime (optional violence preference) for bedroom behavior if player chrisma+luck < 20 on random roll
; if crime, on StopAll(such as scene end) a notice displays and 2-second delay until violence to give player a chance

Group A_Quests
DTSleep_Conditionals property DTSConditionals auto
DTSleep_SceneData property SceneData auto const
RefCollectionAlias property ActiveCompanionCollectionAlias auto const
RefCollectionAlias property DTSleep_CrowdRefCollAlias auto const
ReferenceAlias property DTSleep_CrowdTargetRefAlias auto const
Quest property DTSleep_IntimateAffinityQuestP auto const
EndGroup

Group B_Main
Actor property PlayerRef auto const
ActorValue property CharismaAV auto const
ActorValue property LuckAV auto const
Keyword property ActorTypeNPCKY auto const
Keyword property ArmorTypePowerKY auto const
Keyword property WorkshopItemKeyword auto const
;GlobalVariable property DTSleep_AdultContentOn auto const
GlobalVariable property DTSleep_SettingCrime auto const
Message property DTSleep_CrimeReportMessage auto const
Faction property DTSleep_SpecatorComnFaction auto const
Faction property DTSleep_SpecatorGuardFaction auto const
FormList property DTSleep_ModCompanionActorList auto const
FormList property DTSleep_GuardFactionList auto const
FormList property DTSleep_SpectatorRaceOKList auto const
EndGroup

Group C_Idles
Idle property LooseIdleStop auto const
Idle property IdleClapping auto const
Idle property IdleBooingStanding auto const
Idle property IdleHeadShakeNo auto const
;Idle property IdleThinking auto const
Idle property IdleShrug auto const
EndGroup


; -----------------------------
; private

Actor[] MGuardActorArray
Actor[] MSpectatorActorArray
int CrimeReportGuardIndex = -1

int CrowdReactionTimer = 101 const
int CrowdEndLimitTimer = 102 const
int CrimeReportedTimer = 103 const
int CrimeReportMsgTimer = 104 const

; *************************** Events *************
;
Event OnQuestInit()

	AddAvailableNearbyNPCs()
	; wait a few seconds to start reactions
	CrimeReportGuardIndex = -1
	
	StartTimer(120.0, CrowdEndLimitTimer)		; backup to make sure stops
	
	int crowdCount = 0
	if (MSpectatorActorArray != None)
		crowdCount = MSpectatorActorArray.Length
	endIf
	if (crowdCount > 0)
		StartTimer(10.0, CrowdReactionTimer)
	endIf
	;Debug.Trace("[DTSleep_SpectatorQuest] init with spectator count: " + crowdCount)
EndEvent

Event OnTimer(int aiTimerID)

	if (aiTimerID == CrowdReactionTimer)
		ProcessReactions()
	elseIf (aiTimerID == CrimeReportMsgTimer)
		DTSleep_CrimeReportMessage.Show()
		
	elseIf (aiTimerID == CrimeReportedTimer)
	
		if (CrimeReportGuardIndex >=0 && MGuardActorArray != None && CrimeReportGuardIndex < MGuardActorArray.Length)
			MGuardActorArray[CrimeReportGuardIndex].SetPlayerResistingArrest()
			Utility.Wait(0.2)
			MGuardActorArray.Clear()
			
			self.Stop()
		endIf
			
	elseIf (aiTimerID == CrowdEndLimitTimer)
		StopAll()
	endIf
EndEvent


; ******************** Functions *****************
;

Function AddAvailableNearbyNPCs()

	float distance = 2400.0			; used by IsNearby
	if (PlayerRef.IsInInterior())
		distance = 800.0
	endIf
	ObjectReference[] actorArray = PlayerRef.FindAllReferencesWithKeyword(ActorTypeNPCKY, distance)
	
	int aCnt = 0
	;Debug.Trace("[DTSleep_SpectatorQuest] searching found total actor count: " + actorArray.Length)
	
	while (aCnt < actorArray.Length)
		Actor ac = actorArray[aCnt] as Actor
		
		if (ac != None && ac != PlayerRef)
		
			if (DTSleep_ModCompanionActorList.HasForm(ac as Form))
				AddSpectator(ac)
			elseIf (ActiveCompanionCollectionAlias.Find(ac) > 0)
				AddSpectator(ac)
			else
				int fIdx = 0
				int len = DTSleep_GuardFactionList.GetSize()
				while (fIdx < len)
					
					Faction gFact = DTSleep_GuardFactionList.GetAt(fIdx) as Faction
					if (gFact != None)
						if (ac.IsInFaction(gFact))
							AddGuard(ac)
						endIf
					endIf
					
					fIdx += 1
				endWhile
			endIf
		endIf
	
		aCnt += 1
	endWhile
	
endFunction

Function AddGuard(Actor guardActor)

	if (MGuardActorArray == None)
		MGuardActorArray = new Actor[0]
	endIf
	if (guardActor != None && ActorOkayToSpectate(guardActor))
		if (Utility.RandomInt(3,10) > 4)
			;Debug.Trace("[DTSleep_SpectatorQuest] adding guard spectator: " + guardActor)
			guardActor.AddToFaction(DTSleep_SpecatorGuardFaction)
			MGuardActorArray.Add(guardActor)
			DTSleep_CrowdRefCollAlias.AddRef(guardActor)
		endIf
	endIf
endFunction

Function AddSpectator(Actor spectActor)
	
	if (MSpectatorActorArray == None)
		MSpectatorActorArray = new Actor[0]
	endIf
	if (spectActor != None && ActorOkayToSpectate(spectActor))
	
		int lim = 7
		if (spectActor.GetSitState() < 2)
			lim = 10
		endIf
	
		if (Utility.RandomInt(5,12) > lim)
			spectActor.AddToFaction(DTSleep_SpecatorComnFaction)
			;Debug.Trace("[DTSleep_SpectatorQuest] adding spectator: " + spectActor)
			MSpectatorActorArray.Add(spectActor)
			DTSleep_CrowdRefCollAlias.AddRef(spectActor)
		endIf
	endIf
	
endFunction

Function SetTargetObject(ObjectReference targetRef)

	if (DTSleep_CrowdTargetRefAlias != None && targetRef != None)
		DTSleep_CrowdTargetRefAlias.ForceRefTo(targetRef)
	endIf
	
endFunction


bool Function StopAll()

	bool crimeCommitted = false
	int charisma = (PlayerRef.GetValue(CharismaAV) as int)
	int luck = (PlayerRef.GetValue(LuckAV) as int)
	CancelTimer(CrowdReactionTimer)
	
	if (self.IsRunning())
		; remove factions from actors and set guards violent unless lucky or beautiful
		if (MSpectatorActorArray != None)
			
			int index = 0
			while (index < MSpectatorActorArray.Length)
				if (MSpectatorActorArray[index] != None)
					MSpectatorActorArray[index].PlayIdle(LooseIdleStop)
					Utility.Wait(0.2)
					if (MSpectatorActorArray[index].IsInFaction(DTSleep_SpecatorComnFaction))
						MSpectatorActorArray[index].RemoveFromFaction(DTSleep_SpecatorComnFaction)
					endIf
					MSpectatorActorArray[index].ChangeAnimArchetype()
					MSpectatorActorArray[index].EvaluatePackage()
					;Debug.Trace("[DTSleep_SpectatorQuest] removed spectator: " + MSpectatorActorArray[index])
				endIf
				
				index += 1
			endWhile
			MSpectatorActorArray.Clear()
		endIf
		if (MGuardActorArray != None)
			int index = 0
			while (index < MGuardActorArray.Length)
				if (MGuardActorArray[index] != None && MGuardActorArray [index].IsInFaction(DTSleep_SpecatorGuardFaction))
					MGuardActorArray[index].PlayIdle(LooseIdleStop)
					Utility.Wait(0.2)
					MGuardActorArray[index].RemoveFromFaction(DTSleep_SpecatorGuardFaction)
					MGuardActorArray[index].ChangeAnimArchetype()
					MGuardActorArray[index].EvaluatePackage()
					
					if (DTSleep_SettingCrime.GetValue() > 0.0 && !crimeCommitted)
						int limit = charisma + luck
						
						if (limit <= 20 && Utility.RandomInt(6, 20) >= limit)
							crimeCommitted = true
							CrimeReportGuardIndex = index
							; timer for warning message
							StartTimer(3.0, CrimeReportMsgTimer)
							; timer to give player a chance to react
							StartTimer(5.6, CrimeReportedTimer)
						endIf
					endIf
				endIf
				
				index += 1
			endWhile
			if (!crimeCommitted)
				MGuardActorArray.Clear()
			endIf
		
		endIf
		
		if (DTSleep_CrowdRefCollAlias != None)
			DTSleep_CrowdRefCollAlias.RemoveAll()
		endIf
		
		if (DTSleep_CrowdTargetRefAlias != None)
			DTSleep_CrowdTargetRefAlias.Clear()
		endIf
		
		;Debug.Trace("[DTSleep_SpectatorQuest] StopAll")

		if (!crimeCommitted)
			self.Stop()
		endIf
	endIf
	
	return crimeCommitted
endFunction


bool Function ActorOkayToSpectate(Actor aActorRef)

	if (aActorRef != None && aActorRef.IsEnabled() && !aActorRef.IsDead() && !aActorRef.IsUnconscious() && aActorRef.GetSleepState() < 3)
		
		if (aActorRef != SceneData.MaleRole && aActorRef != SceneData.FemaleRole && aActorRef != SceneData.SecondMaleRole && aActorRef != SceneData.SecondFemaleRole)
		
			; haters will not participate
			if (!(DTSleep_IntimateAffinityQuestP as DTSleep_IntimateAffinityQuestScript).CompanionHatesIntimateOtherPublic(aActorRef))
				
				ActorBase aBase = aActorRef.GetLeveledActorBase() as ActorBase
				if (aBase != None)
					Race aRace = aBase.GetRace()
					if (DTSleep_SpectatorRaceOKList.HasForm(aRace as Form))
					
						return true
					endIf
				endIf
			endIf
		endIf
	endIf

	return false
endFunction


Function ProcessReactions()

	if (self.IsRunning() && DTSleep_CrowdRefCollAlias != None)
	
		;Debug.Trace("[DTSleep_SpectatorQuest] play reactions")
		int index = 0
		int count = DTSleep_CrowdRefCollAlias.GetCount()
		while (index < count)
		
			ProcessReactionForActor(DTSleep_CrowdRefCollAlias.GetAt(index) as Actor)
			Utility.Wait(0.3)
			index += 1
		endWhile
		
		StartTimer(8.0, CrowdReactionTimer)
	endIf
endFunction

Function ProcessReactionForActor(Actor actorRef)
	
	Idle rIdle = IdleShrug
	
	if (actorRef.WornHasKeyword(ArmorTypePowerKY))
		return
	endIf
	
	if (MGuardActorArray != None && MGuardActorArray.Find(actorRef) >= 0)
		rIdle = IdleHeadShakeNo
	else
	
		int rand = Utility.RandomInt(0, 5)
		if (SceneData.IsCreatureType >= 1 && SceneData.IsCreatureType <= 2)
			rIdle = IdleHeadShakeNo
			if (rand >= 3)
				rIdle = IdleBooingStanding
			endIf
			
		elseIf (rand <= 2)
			rIdle = IdleClapping
		;elseIf (rand == 2)
		
		elseIf (rand >= 4)
			rIdle = IdleHeadShakeNo
		endIf
	endIf
	
	actorRef.PlayIdle(rIdle)

endFunction