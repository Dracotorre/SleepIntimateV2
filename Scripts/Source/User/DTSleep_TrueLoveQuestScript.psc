Scriptname DTSleep_TrueLoveQuestScript extends Quest

; *********************
; script by DracoTorre
; Sleep Intimate
; https://www.dracotorre.com/mods/sleepintimate/
; https://github.com/Dracotorre/SleepIntimateV2
;
;
; quest may be started and stopped repeatedly
; works with the ring, DTSleep_LoverRingScript, which starts and stops this quest
; alias holds ring-wearer's name and quest can locate wearer on map from player's journal
; player may issue multiple rings, but only keep track of a single alias
; upon stop quest, a quest fragment removes from quest journal
;
; to avoid annoying player with repeated starts, use PreparingToStop function which 
;    hides quest objective and stops quest after x game-time
; re-display quest objective using CancelStop function

Actor property PlayerRef auto const
DTSleep_Conditionals property DTSConditionals auto const
ReferenceAlias property DTSleep_TrueLoveAlias auto const 
RefCollectionAlias property ActiveCompanionCollectionAlias auto const
ActorValue property CA_AffinityAV auto const

GlobalVariable property DTSleep_SettingModActive auto const
GlobalVariable property DTSleep_SettingIntimate auto const		; not currently used; could limit non-romance companions per this setting, but let's allow it
GlobalVariable property DTSleep_SettingTestMode auto const				
FormList property DTSleep_ModCompanionActorList auto const		; known custom companions (Heather, Barb) stored here
FormList property DTSleep_CompanionRomanceList auto const		; romance-ready companions for easy lookup
FormList property DTSleep_SettlerFactionList auto const			; factions used by settlers or gangs - companion may be included, but assuming not custom companion
;
; these companions not romance-ready and so require perk -- normally preference setting must be set to enable these extra NPCs
Actor property CompanionDeaconRef auto const
Actor property CompanionX6Ref auto const
Actor property StrongCompanionRef auto const
Perk property CompStrongPerk auto const
Perk property CompDeaconPerk auto const
Perk property CompX6Perk auto const

Race property HumanRace auto const								; to check in case mods like Ada-to-Human to allow Ada
Keyword property ActorTypeRobotKY auto const					; v2.49 no robots

; ----------------------
bool property PreparingToStop auto hidden

; ----------------------

int PrepStopTimerID = 11 const

Event OnQuestInit()

	if (DTSleep_SettingModActive.GetValue() > 0 && (DTSConditionals as DTSleep_Conditionals).LoverRingEquipCount > 0)
		self.SetStage(10)
		SetObjectiveDisplayed(10, true)		; mark quest journal with ring owner's name
		; keep going until stopped, and a fragment hides the journal entry
		Utility.WaitMenuMode(0.2)
		Actor loverActor = DTSleep_TrueLoveAlias.GetActorReference()
		if (loverActor == None)
			Debug.Trace("[DTSleep_TrueLoveQuest] OnInit -- no TrueLoveAlias actor reference found ... stop")
			SetObjectiveDisplayed(10, false)
			self.Stop()
		endIf
	else
		Debug.Trace("[DTSleep_TrueLoveQuest] OnInit -- mod inactive or ring count is zero! - stop quest")
		Utility.WaitMenuMode(0.1)
		self.Stop()
	endIf
EndEvent

Event OnTimerGameTime(int aiTimerID)
	if (aiTimerID == PrepStopTimerID)
		PreparingToStop = false
		self.Stop()
	endIf
EndEvent

; --------------
; IsAllowedLover  - check here before starting quest 
; - any romantic companion allowed
; - other companions allowed if player has perk
; - custom 'Heather Casdin' and 'Wastelander Barb' allowed if in-love
; - try to allow other custom companions by checking if not a settler
;
bool Function IsAllowedLover(Actor akActor)

	bool foundInCompCollection = false
	
	if (akActor == PlayerRef)
		return false
	elseIf (akActor == None)
		Debug.Trace("[DTSleep_TrueLoveQuest] IsAllowed? actor is None!")
		return false
	elseIf (akActor.IsChild())					; v2.60
		Debug.Trace("[DTSleep_TrueLoveQuest] IsAllowed? actor is child!")
	endIf
	
	; first check spouse custom companions
	if ((DTSConditionals as DTSleep_Conditionals).NoraSpouseRef != None && akActor == (DTSConditionals as DTSleep_Conditionals).NoraSpouseRef)
			
		return true

	elseIf ((DTSConditionals as DTSleep_Conditionals).DualSurvivorsNateRef != None && akActor == (DTSConditionals as DTSleep_Conditionals).DualSurvivorsNateRef)
		
		return true
	endIf
	
	; v2.49
	if (akActor.HasKeyword(ActorTypeRobotKY))
		return false
	endIf
	
	; check regular companions first
	
	if (ActiveCompanionCollectionAlias != None)
		int count = ActiveCompanionCollectionAlias.GetCount()
		int idx = 0
		
		while (idx < count)
			Actor activeComp = ActiveCompanionCollectionAlias.GetAt(idx) as Actor
			if (activeComp != None && activeComp == akActor)
				
				foundInCompCollection = true
				
				; check normal romance-ready companions
				if (DTSleep_CompanionRomanceList.HasForm(activeComp as Form))
					CompanionActorScript aCompanion = ActiveCompanionCollectionAlias.GetAt(idx) as CompanionActorScript
					if (aCompanion != None)
						if (aCompanion.IsInfatuated() || aCompanion.IsRomantic())
							
							return true
						endIf
						
						float affinity = aCompanion.GetValue(CA_AffinityAV)
						if (affinity >= 1000.0)
							; in case of romance bug
							return true
						endIf
						
						; v2.21 if zero affinity and test mode, let continue
						if (DTSleep_SettingTestMode.GetValue() > 0.0)
							if (affinity >= 750.0)
								return true
							elseIf (affinity != 0.0)
								return false
							endIf
						else
							return false
						endIf
					else
						Debug.Trace("[DTSleep_TrueLoveQuest] found UNKNOWN companion (failed CompanionActorScript) = " + activeComp + " in Active Companion list")
						idx = count + 10
					endif
					
				; v2.21 - no Strong and extras must at least be a friend
				elseIf (activeComp == StrongCompanionRef)
					return false

				elseIf (activeComp == CompanionDeaconRef)
					if (PlayerRef.HasPerk(CompDeaconPerk))
						if (DTSleep_SettingTestMode.GetValue() > 0.0 || activeComp.GetValue(CA_AffinityAV) >= 250)
							return true
						endIf
					endIf
					return false
					
				elseIf (activeComp == CompanionX6Ref)
					if (PlayerRef.HasPerk(CompX6Perk))
						if (DTSleep_SettingTestMode.GetValue() > 0.0 || activeComp.GetValue(CA_AffinityAV) >= 250)
							return true
						endIf
					endIf
					return false
					
				elseIf ((DTSConditionals as DTSleep_Conditionals).IsCoastDLCActive && activeComp == (DTSConditionals as DTSleep_Conditionals).FarHarborDLCLongfellowRef)
					if (PlayerRef.HasPerk((DTSConditionals as DTSleep_Conditionals).FarHarborDLCLongfellowPerk))
					
						return (DTSleep_SettingTestMode.GetValue() > 0.0 || activeComp.GetValue(CA_AffinityAV) >= 250.0)
					endIf
					return false
					
				elseIf ((DTSConditionals as DTSleep_Conditionals).IsRobotDLCActive && activeComp == (DTSConditionals as DTSleep_Conditionals).RobotAdaRef)
					
					; Ada must be human and finished DLC main quest 
					ActorBase compBase = activeComp.GetActorBase()
					if (compBase != None && compBase.GetRace() == HumanRace)
						if ((DTSConditionals as DTSleep_Conditionals).RobotMQ105Quest != None && (DTSConditionals as DTSleep_Conditionals).RobotMQ105Quest.GetStageDone(1000))
							return true
						endIf
					endIf
					
					return false ; Ada not compatible or not ready
				endIf
				
				int customCheck = CheckCustomCompanionsForActor(akActor)
				if (customCheck >= 0)
					; found custom actor
					if (customCheck >= 2)
						return true
					endIf
					return false
				endIf
				
				; actor found in collection
				;  exit loop, but do not return
				idx = count + 10
			endIf
			
			idx += 1
		endWhile
	endIf
	
	; check known custom companions that may not be in ActiveCompanionCollectionAlias
	int customCheck = CheckCustomCompanionsForActor(akActor)
	if (customCheck >= 0)
		if (customCheck >= 2)
			return true
		endIf
		return false
	endIf
	
	CompanionActorScript unkActor = akActor as CompanionActorScript
	if (unkActor != None)
		float affinity = unkActor.GetValue(CA_AffinityAV)
		if (affinity > 0.0)
		
			if (affinity > 900.0)
				Debug.Trace("[DTSleep_TrueLoveQuest] Accepted for affinity (" + affinity + ") of UNKNOWN companion = " + akActor)
				return true
			elseIf (DTSleep_SettingTestMode.GetValue() > 0.0 && affinity >= 750)
				Debug.Trace("[DTSleep_TrueLoveQuest] Accepted for affinity (" + affinity + ") of UNKNOWN companion = " + akActor)
				return true
			endIf
			Debug.Trace("[DTSleep_TrueLoveQuest] REFUSED for low affinity (" + affinity + ") of UNKNOWN companion = " + akActor)
			return false
		elseIf (affinity < 0.0)
			;v2.21 - hated
			Debug.Trace("[DTSleep_TrueLoveQuest] REFUSED for negative affinity (" + affinity + ") of UNKNOWN companion = " + akActor)
			return false
		endIf
	endIf
	
	; uncertain how best to handle custom companion not using affinity
	;
	if (DTSleep_SettingTestMode.GetValue() > 0.0)
		; to allow other custom companions, check if in a settler faction to exclude
		if (foundInCompCollection)
			
			Debug.Trace("[DTSleep_TrueLoveQuest] assume okay for unknown affinity of UKNOWN companion = " + akActor) 
			return true
			
		elseIf (DTSleep_SettlerFactionList != None)
			int len = DTSleep_SettlerFactionList.GetSize()
			int idx = 0
			while (idx < len)
				Faction aFact = DTSleep_SettlerFactionList.GetAt(idx) as Faction
				if (aFact != None)
					if (akActor.IsInFaction(aFact))
						Debug.Trace("[DTSleep_TrueLoveQuest] not a companion actor " + akActor + " in faction " + aFact)
						
						return false
					endIf
				endIf
				
				idx += 1
			endWhile
			
			; assume okay
			Debug.Trace("[DTSleep_TrueLoveQuest] assuming a companion, actor = " + akActor) 
			return true
		endIf
	endIf

	return false
endFunction

Function CancelStop()
	PreparingToStop = false
	CancelTimerGameTime(PrepStopTimerID)
	SetObjectiveDisplayed(10, true)			; re-display objective in journal
endFunction

Function PrepareStop()
	SetObjectiveDisplayed(10, false)		; hide objective from journal
	PreparingToStop = true
	StartTimerGameTime(1.2, PrepStopTimerID)

endFunction

; --------------------------

; negative means not found, 0 = no, 2 = love
;
int Function CheckCustomCompanionsForActor(Actor akActor)

	if (DTSConditionals.IsHeatherCompanionActive)
		Actor heatherActor = GetHeatherActor()
		if (heatherActor != None && heatherActor == akActor)
			if (IsHeatherInLove())
				return 2
			endIf
			return 0
		endIf
	endIf
	
	if (DTSConditionals.IsNWSBarbActive)
		Actor barbActor = GetNWSBarbActor()
		if (barbActor != None && barbActor == akActor)
			Perk barbPerk = DTSConditionals.ModCompNWSBarbRewardPerk
			if (barbPerk != None && Game.GetPlayer().HasPerk(barbPerk))
			
				return 2
			endIf
			return 0
		endIf
	endIf
	
	; v2.85 - Ivy now available from start
	if ((DTSConditionals as DTSleep_Conditionals).InsaneIvyRef != None && akActor == (DTSConditionals as DTSleep_Conditionals).InsaneIvyRef)
		
		return 2
	endIf
	
	;v2.41
	if (DTSConditionals.ModPersonalGuardCtlKY != None)
		if (akActor.HasKeyword(DTSConditionals.ModPersonalGuardCtlKY))
			; PersonalGuard does not use affinity
			return 2
		endIf
	endIf

	return -1
endFunction

Actor Function GetNWSBarbActor()
	if (DTSConditionals.IsNWSBarbActive)
		int index = DTSConditionals.ModCompanionActorNWSBarbIndex
		
		return GetModActor(index)
	endIf
	
	return None
EndFunction

Actor Function GetHeatherActor()
	if (DTSConditionals.IsHeatherCompanionActive)
		int index = DTSConditionals.ModCompanionActorHeatherIndex

		return GetModActor(index)
	endIf
	
	return None
EndFunction

Actor Function GetModActor(int index)
	if (index >= 0)
		int len = DTSleep_ModCompanionActorList.GetSize()
		
		if (index < len)
			return (DTSleep_ModCompanionActorList.GetAt(index) as Actor)
		else
			Debug.Trace("[DTSleep_LoverRingScript] error GetModActor - index > size (" + index + " > " + len + ")" )
		endIf
	endIf
	
	return None
endFunction

bool Function IsHeatherInLove()

	if ((DTSConditionals as DTSleep_Conditionals).IsHeatherCompInLove)
		return true
	else
		string heatherPluginName = "llamaCompanionHeatherv2.esp"
		if ((DTSConditionals as DTSleep_Conditionals).HeatherCampanionVers < 1.5)
			heatherPluginName = "llamaCompanionHeather.esp"
		endIf
		Quest heatherCoreQuest = Game.GetFormFromFile(0x0300C9BA, heatherPluginName) as Quest
		if (heatherCoreQuest != None)
			if (heatherCoreQuest.GetStageDone(751))
			
				return true
				
			elseIf (heatherCoreQuest.GetStageDone(1001))
				; only record if fully romanced
				(DTSConditionals as DTSleep_Conditionals).IsHeatherCompInLove = true
				
				return true
			endIf
		endIf
	endIf
	
	return false
EndFunction

