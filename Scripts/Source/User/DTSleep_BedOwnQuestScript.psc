Scriptname DTSleep_BedOwnQuestScript extends Quest

; by DracoTorre
; www.dracotorre.com/mods/sleepintimate/
;
; keeps track of  twin/double beds owned and declined ownership
; a twin bed may be two single beds placed side-by-side or a custom double-bed having 2 beds put together
;
; this helper quest for MainQuest expects to have DTSleep_CompIntimateQuest already running with alias filled
; for messages with companion name otherwise will not perform checks.
;
; keyword - DTSleep_OwnBedCheckedKY
; marks beds having been checked and declined by player to avoid asking again

;------------------------------------
; v1.57 changes
;
; assigning companion to bed limited to companion belonging to workshop using normal assign using workshop script
; for other companions, bed only marked private (keyword) so any companion may use --- setting them as owner becomes problematic on workshop refresh
; on workshop refresh the game may give player ownership to non-assigned bed so we must check this case
; 
; keyword - DTSleep_OwnBedPrivateKY
; simply setting bed workshop-ID to -1 without removing from workshop does not make private, so use keyword to check on next bed activation
;  -- if has keyword and a settler assigned, kick settler out
;
; ------------------------------

; ************************** property *************
;
DTSleep_Conditionals property DTSConditionals auto
Actor property PlayerRef auto const
Faction Property PlayerFaction auto const
WorkShopParentScript Property WorkshopParent Auto Const
ReferenceAlias property DTSleep_CompIntimateAlias auto const
ReferenceAlias property DTSleep_OtherOwnerAlias auto const
Keyword property WorkshopItemKeyword auto const Mandatory
Keyword property LocTypeWorkshopSettlementKY auto const
Keyword property AnimFurnFloorBedAnims auto const
Keyword property DTSleep_OwnBedCheckedKY auto const
{ added to bed that has been declined by player to avoid asking again }
Keyword property DTSleep_OwnBedPrivateKY auto const
{ added to bed marked private }
FormList property DTSleep_CompanionIntimateAllList auto const
Furniture property WorkshopNPCBedPlayerHouseLay01 auto const
{ only bed on both intimate and bigDouble lists to ignore as working double }
ActorValue property WorkshopPlayerOwned auto Const
GlobalVariable property DTSleep_SettingBedOwn auto const
GlobalVariable property DTSleep_SettingTestMode auto const
GlobalVariable property DTSleep_CompanionBelongWorkshop auto
{ set to 1 if workshop is home for current companion }
GlobalVariable property DTSleep_DebugMode auto const
FormList property DTSleep_BedList auto const
FormList property DTSleep_BedIntimateList auto const
FormList property DTSleep_BedsBigDoubleList auto const
FormList property DTSleep_BedPillowBedList auto const
FormList property DTSleep_BedPillowFrameDBList auto const
Message property DTSleep_OwnBedDoubleReqMessage auto const
Message property DTSleep_OwnBedTwinReqMessage auto const
Message property DTSleep_OwnBedOwnedWarnMessage auto const
{ this bed owned by someone else message}
Message property DTSleep_OwnBedDoubleReassignMessage auto const
Message property DTSleep_OwnBedTwinReassignMessage auto const
Message property DTSleep_OwnBedWarnOwnOtherSideMsg auto const
{ player owns other side message }
Message property DTSleep_OwnBedRemoveAssignmentMessage auto const
Message property DTSleep_OwnBedOtherAssignWarnMsg auto const
Message property DTSleep_OwnBedOwnedCompWarnMessage auto const
Message property DTSleep_OwnBedOwnedCompWarnInUseMsg auto const

; -------------------- hidden ------------

ObjectReference property LastBedRef = None auto hidden
ObjectReference property LastTwinBedRef = None auto hidden
float property LastBedUpdateTime = 0.0 auto hidden


; --------------------- private -----------------

ObjectReference[] BedCheckedArray	 ; not using
WorkshopScript MyWorkshopRef		; store for easy access

float TwinBedDistLimit = 220.0 const

; ***************************** events *************

Event OnQuestInit()
	BedCheckedArray = new ObjectReference[0]	; not using, but init anyhow
	MyWorkshopRef = None
	DTSleep_CompanionBelongWorkshop.SetValue(-1.0)
EndEvent


; ************************* functions ****************
; functions intended as public first


; please have DTSleep_CompIntimateQuest running **intimate** companion assigned before calling 
;    OR companionRef == None for player-only privacy check
;  returns negative for player choose to cancel or positive for bed assigned
;
int Function CheckBedOwnership(ObjectReference aBedRef, Form baseBedForm, Actor companionRef, Location atLoc)
	int result = 0
	int bedOwnSetting = DTSleep_SettingBedOwn.GetValueInt()
	bool twinBedOwnedByCompanion = false
	bool twinBedOwnedByPlayer = false
	bool thisBedOwnedByCompanion = false
	bool thisBedOwnedByPlayer = false
	ActorBase twinBedOwnerBase = None
	ActorBase thisBedOwnerBase = None
	bool testModeOn = false
	
	; reset
	MyWorkshopRef = None
	DTSleep_CompanionBelongWorkshop.SetValue(-1.0)
	
	
	if (DTSleep_SettingTestMode.GetValueInt() >= 1)
		testModeOn = true
	endIf
			
	if (bedOwnSetting > 0 && atLoc != None)
		if (atLoc.HasKeyword(LocTypeWorkshopSettlementKY))
		
			if (baseBedForm == None)
				baseBedForm = (aBedRef.GetBaseObject() as Form)
			endIf
			
			if (companionRef == None)
				; no companion so warn-only
				bedOwnSetting = 1
				DTSleep_CompanionBelongWorkshop.SetValue(-2.0)
			endIf
		
			if (!aBedRef.HasKeyword(AnimFurnFloorBedAnims) && DTSleep_BedIntimateList.HasForm(baseBedForm) && baseBedForm != WorkshopNPCBedPlayerHouseLay01)
				
				if (DTSleep_CompIntimateAlias != None && companionRef != None)

					Actor intimateAliasActor = DTSleep_CompIntimateAlias.GetActorReference()
					if (intimateAliasActor != companionRef)
						if (DTSleep_DebugMode.GetValue() >= 1.0)
							Debug.Trace("[DTSleep_BedOwn] companionRef (" + companionRef + ") not the same as DTSleep_CompIntimateAlias (" + intimateAliasActor + "!")
						endIf
						return 0
					endIf
				endIf
				
				if (IsObjBelongPlayerWorkshop(aBedRef) > 0)
					; in a workshop using bed not owned by player -- does it have a twin for double-bed?
					bool findTwin = true
					
					; pillowBed must be on a double-frame
					if ((DTSConditionals as DTSleep_Conditionals).IsHZSHomebuilderActive > 0)
						if (DTSleep_BedPillowBedList.HasForm(baseBedForm))
							ObjectReference bedFrameRef = DTSleep_CommonF.FindNearestAnyBedFromObject(aBedRef, DTSleep_BedPillowFrameDBList, None, 86.0)
							if (bedFrameRef == None)
								findTwin = false
							endIf
						endIf
					endIf
					
					ObjectReference twinBed = None
					
					if (findTwin)
						twinBed = DTSleep_CommonF.FindNearestAnyBedFromObject(aBedRef, DTSleep_BedList, aBedRef, TwinBedDistLimit, true)
					endIf
					
					LastBedRef = aBedRef
					LastTwinBedRef = twinBed
					LastBedUpdateTime = Utility.GetCurrentGameTime()
					
					if (twinBed != None)
						; has twin - check ownership
						bool thisBedIsOwned = aBedRef.HasActorRefOwner()
						bool twinBedIsOwned = twinBed.HasActorRefOwner()
						int msgChoice = -1
						
						if (testModeOn)
							DebugDisplayBedsWorkshopIDs(aBedRef, twinBed)
						endIf
						
						if (thisBedIsOwned)
							if (companionRef != None && aBedRef.IsOwnedBy(companionRef))
								thisBedOwnedByCompanion = true
							elseIf (aBedRef.IsOwnedBy(PlayerRef))
								thisBedOwnedByPlayer = true
							endIf
						endIf
						if (twinBedIsOwned)
							if (companionRef != None && twinBed.IsOwnedBy(companionRef))
								twinBedOwnedByCompanion = true
							elseIf (twinBed.IsOwnedBy(PlayerRef))
								twinBedOwnedByPlayer = true
							endIf
						endIf
						
						; make sure companion is on known list - custom companions may be added
						VerifyCompanionKnown(companionRef)
						
						WorkshopNPCScript workshopCompanion = WorkshopNPCForActor(companionRef)
						
						if (testModeOn && DTSleep_DebugMode.GetValue() >= 1.0)
							Debug.Trace("[DTSleep_BedOwn] (" + aBedRef + ") thisOwn?  " + thisBedIsOwned + ", (" + twinBed + ") twinOwn? " + twinBedIsOwned + " -- does companion belong to workshop? " + DTSleep_CompanionBelongWorkshop.GetValueInt())
						endIf
						
						; --------------------------
						; there are 15 bed own/assignment variations to check for including if game sets player-base ownership to un-assigned bed
						;   pairs -- open, player-owned, companion-assigned, other-companion-assigned, settler-assigned
						; 	where pairs must include player-owned or open (2 x 3 x 2 + 3 = 15)
						;
						; ---------------------------
						; check base ownership and keyword section --- fix if setting enabled
						; --- base ownership only valid if HasActorRefOwner is false
						; --- see https://www.creationkit.com/fallout4/index.php?title=GetActorOwner_-_ObjectReference
						; game assigns player as owner (base - still orange) which apparently may remove assigned ownership as in case
						;   companion assigned by this script and companion not living at settlement
						;
						if (!twinBedIsOwned)
							twinBedOwnerBase = twinBed.GetActorOwner()
							
							if (twinBedOwnerBase != None)
							
								if (twinBedOwnerBase == PlayerRef.GetActorBase())
									if (testModeOn && DTSleep_DebugMode.GetValue() >= 1.0)
										Debug.Trace("[DTSleep_BedOwn] player-base owns twin ")
									endIf
																
									if (bedOwnSetting >= 2)

										twinBed.SetActorOwner(None)
										if (thisBedOwnedByCompanion)
											; claim for player
											twinBedIsOwned = true
											twinBedOwnedByPlayer = true
											twinBed.SetActorRefOwner(PlayerRef, true)
										endIf
									else
										twinBedOwnedByPlayer = true
									endIf
								elseIf (companionRef != None && twinBedOwnerBase == companionRef.GetActorBase())
									twinBedOwnedByCompanion = true
								endIf
							elseIf (thisBedOwnedByCompanion)
								; claim for player
								twinBedIsOwned = true
								twinBedOwnedByPlayer = true
								twinBed.SetActorRefOwner(PlayerRef, true)
							endIf
						endIf
						
						if (!thisBedIsOwned)
							thisBedOwnerBase = aBedRef.GetActorOwner()
							;not expecting Faction issue in workshop
							
							if (thisBedOwnerBase != None)
								
								if (thisBedOwnerBase == PlayerRef.GetActorBase())
									if (testModeOn && DTSleep_DebugMode.GetValue() >= 1.0)
										Debug.Trace("[DTSleep_BedOwn] player-base owns this bed ")
									endIf
									
									if (bedOwnSetting >= 2)

										aBedRef.SetActorOwner(None)
										if (twinBedOwnedByCompanion)
											; claim for player
											if (testModeOn && DTSleep_DebugMode.GetValue() >= 2.0)
												Debug.Trace("[DTSleep_BedOwn] player claims this player-base bed since twin owned by companion")
											endIf
											thisBedIsOwned = true
											thisBedOwnedByPlayer = true
											aBedRef.SetActorRefOwner(PlayerRef, true)
										endIf
									else
										thisBedOwnedByPlayer = true
									endIf
									
								elseIf (companionRef != None && thisBedOwnerBase == companionRef.GetActorBase())
									if (testModeOn && DTSleep_DebugMode.GetValue() >= 1.0)
										Debug.Trace("[DTSleep_BedOwn] companion-base owns this bed ")
									endIf
									thisBedOwnedByCompanion = true
								endIf
								
							elseIf (twinBedOwnedByCompanion)
								; claim for player
								if (testModeOn && DTSleep_DebugMode.GetValue() >= 2.0)
									Debug.Trace("[DTSleep_BedOwn] player claims this bed since twin owned by companion")
								endIf
								
								aBedRef.SetActorRefOwner(PlayerRef, true)
								thisBedIsOwned = true
								thisBedOwnedByPlayer = true
							endIf
						endIf
						
						; check private keyword - if exists player owns a bed
						
						if (aBedRef.HasKeyword(DTSleep_OwnBedPrivateKY))
							
							if (thisBedIsOwned && !thisBedOwnedByPlayer && !thisBedOwnedByCompanion)
							
								; remove only settlers not intimate companions from bed assignment
								if (UnassignObject(aBedRef as WorkshopObjectScript, false))
									if (DTSleep_DebugMode.GetValue() >= 2.0)
										Debug.Trace("[DTSleep_BedOwn] someone took private this-bed " + aBedRef)
									endIf
									
									
									if (twinBedOwnedByPlayer)
										thisBedIsOwned = false
									else
										thisBedIsOwned = true
										thisBedOwnedByPlayer = true
										aBedRef.SetActorRefOwner(PlayerRef, true)
									endIf
								endIf
								
							elseIf (!thisBedIsOwned && !twinBedOwnedByPlayer)
							
								if (testModeOn && DTSleep_DebugMode.GetValue() >= 2.0)
									Debug.Trace("[DTSleep_BedOwn] player claims this bed since private")
								endIf
								thisBedIsOwned = true
								thisBedOwnedByPlayer = true
								aBedRef.SetActorRefOwner(PlayerRef, true)
							endIf
						endIf
						
						if (twinBed.HasKeyword(DTSleep_OwnBedPrivateKY))
						
							if (twinBedIsOwned && !twinBedOwnedByPlayer && !twinBedOwnedByCompanion)
							
								; remove only settlers
								if (UnassignObject(aBedRef as WorkshopObjectScript, false))
									if (DTSleep_DebugMode.GetValue() >= 1.0)
										Debug.Trace("[DTSleep_BedOwn] someone took private twin-bed " + aBedRef)
									endIf
									
									if (thisBedOwnedByPlayer)
										twinBedIsOwned = false
									else
										twinBedIsOwned = true
										twinBedOwnedByPlayer = true
										twinBed.SetActorRefOwner(PlayerRef, true)
									endIf
								endIf
								
							elseIf (!twinBedIsOwned && !thisBedOwnedByPlayer)
							
								if (testModeOn && DTSleep_DebugMode.GetValue() >= 2.0)
									Debug.Trace("[DTSleep_BedOwn] player claims twin bed since private")
								endIf
								twinBedIsOwned = true
								twinBedOwnedByPlayer = true
								twinBed.SetActorRefOwner(PlayerRef, true)
							endIf
						endIf
						
						; ------------------------ done check base ownership, keywords, and fix attempt section
						
						if (companionRef == None)
						
							if (!aBedRef.HasKeyword(DTSleep_OwnBedPrivateKY) && !twinBed.HasKeyword(DTSleep_OwnBedPrivateKY))
								; not private, so warn if settler has taken
								if (thisBedIsOwned && !thisBedOwnedByPlayer)
									
									msgChoice = ShowWarnForSettlerAssigned(aBedRef)
								elseIf (twinBedIsOwned && !twinBedOwnedByPlayer)
									msgChoice = ShowWarnForSettlerAssigned(twinBed)
								endIf
							endIf
							
							if (msgChoice == 0)
								; declined bed
								return -1
							endIf
						
							; nothing more needed without companion 
							return 0
						endIf
						
						; ----- check ownership and if need to swap sides --- requires companion
						;
						if (twinBedIsOwned && twinBedOwnedByPlayer)
							; uh-oh player using opposite bed - silently swap or ask if other owner
							
							if (thisBedIsOwned && !thisBedOwnedByPlayer)
								if (thisBedOwnedByCompanion)
									if (bedOwnSetting >= 2)
										
										; swap
										if (workshopCompanion != None)
											MarkBedsPrivate(aBedRef, None)
											
											AssignCompanionToBed(workshopCompanion, twinBed)
										else
											MarkBedsPrivate(aBedRef, twinBed)
											twinBed.SetActorRefOwner(None, true)			
										endIf
										aBedRef.SetActorRefOwner(PlayerRef, true)
									else
										; player owns other side message
										msgChoice = DTSleep_OwnBedWarnOwnOtherSideMsg.Show()
									endIf
									
								elseIf (bedOwnSetting >= 2)
									; someone else owns this bed - ask to change
									
									; show or quietly remove non-companion settler
									if (ShowOtherOwnerCheck(aBedRef, baseBedForm))
										; replace
										if (workshopCompanion != None)
											MarkBedsPrivate(aBedRef, None)
											AssignCompanionToBed(workshopCompanion, twinBed)
										else
											MarkBedsPrivate(aBedRef, twinBed)
											twinBed.SetActorRefOwner(None, true)			
										endIf
										aBedRef.SetActorRefOwner(PlayerRef, true)
									else
										msgChoice = 0
									endIf
									
								else
									; someone else owns this bed - warn
									msgChoice = ShowWarnForOtherOwner(aBedRef)
								endIf
								
							elseIf (!thisBedIsOwned || bedOwnSetting >= 2)
								; swap
								
								if (thisBedOwnedByCompanion && workshopCompanion != None)
									MarkBedsPrivate(aBedRef, None)
									AssignCompanionToBed(workshopCompanion, twinBed)
								else
									MarkBedsPrivate(aBedRef, twinBed)
									twinBed.SetActorRefOwner(None, true)
								endIf
								aBedRef.SetActorRefOwner(PlayerRef, true)
								
							elseIf (thisBedOwnedByPlayer)
								; player owns both sides?
								twinBed.SetActorOwner(None, true)
								
							elseif (!thisBedOwnedByCompanion)
								; someone else owns
								msgChoice = ShowWarnForOtherOwner(aBedRef)
							endIf
							
						elseIf (thisBedIsOwned && !thisBedOwnedByPlayer && !thisBedOwnedByCompanion)
							; this bed owned by someone other than player or companion
							msgChoice = ShowWarnForOtherOwner(aBedRef)
							
						elseIf (!thisBedIsOwned && twinBedIsOwned && !twinBedOwnedByCompanion)
							; twin bed owned by someone other than player or companion
							msgChoice = ShowWarnForOtherOwner(twinBed)
							
						elseIf (bedOwnSetting >= 2)
							
							if (!thisBedIsOwned && !twinBedIsOwned)
								; not owned - should player-companion own it?
								
								if (OwnershipBedDeclinedCheck(aBedRef, twinBed) == false)
								
									int response = ShowBedsClaimCheck(baseBedForm)
									
									result = HandleBedsClaimResponse(response, workshopCompanion, aBedRef, twinBed)
								endIf
								
							elseIf (thisBedIsOwned && twinBedIsOwned && thisBedOwnedByPlayer && !twinBedOwnedByCompanion)
								; player owned, but twin bed owned by someone else
								
								if (OwnershipBedDeclinedCheck(aBedRef, twinBed) == false)
									
									if (twinBed.IsFurnitureInUse())
									
										if (DTSleep_BedsBigDoubleList.HasForm(baseBedForm))
											
											if (testModeOn && DTSleep_DebugMode.GetValue() >= 1.0)
												Debug.Trace("[DTSleep_BedOwn] double-bed (" + twinBed + ") in use; -11")
											endIf
											
											return -11
										else
											msgChoice = ShowWarnForOtherOwner(twinBed, true)
										endIf
									
									elseIf (ShowOtherOwnerCheck(twinBed, None))
									
										; show or quietly remove non-companion settler
										if (workshopCompanion != None )
											MarkBedsPrivate(aBedRef, None)
											AssignCompanionToBed(workshopCompanion, twinBed)
										else
											MarkBedsPrivate(aBedRef, twinBed)
											twinBed.SetActorRefOwner(None, true)
										endIf
									else
										msgChoice = 0
									endIf
								else
									msgChoice = ShowWarnForOtherOwner(twinBed)
								endIf
								
							elseIf (thisBedIsOwned && thisBedOwnedByPlayer && OwnershipBedDeclinedCheck(aBedRef, twinBed) == false)
								
								; ensure private without removing assignment
								if (workshopCompanion == None)
									MarkBedsPrivate(aBedRef, twinBed, false)
									
								elseIf (!twinBedOwnedByCompanion)
									
									if (testModeOn && DTSleep_DebugMode.GetValue() >= 2.0)
										Debug.Trace("[DTSleep_BedOwn] ask player to claim companion for un-assigned twin")
									endIf
									int response = ShowBedsClaimCheck(baseBedForm)
									
									result = HandleBedsClaimResponse(response, workshopCompanion, aBedRef, twinBed)
								else
									MarkBedsPrivate(aBedRef, None, false)
								endIf
							endIf
						elseIf (thisBedOwnedByPlayer && twinBedIsOwned && !twinBedOwnedByCompanion)
						
							msgChoice = ShowWarnForOtherOwner(twinBed)
							
						elseIf (thisBedIsOwned && twinBedOwnedByPlayer)
						
							msgChoice = DTSleep_OwnBedWarnOwnOtherSideMsg.Show()
						endIf
						
						if (msgChoice == 0)
							; declined to use bed
							result = -1
								
						endIf
					endIf
				endIf
			endIf
		endIf
	endIf
	
	return result
endFunction

int Function IsObjBelongPlayerWorkshop(ObjectReference objRef)
	ObjectReference linkRef = objRef.GetLinkedRef(WorkshopItemKeyword)   ; takes 0.1 seconds - check keywords first
	if (linkRef != None)

		MyWorkshopRef = linkRef as WorkshopScript
		
		if (linkRef.HasKeyword(DTSConditionals.ConquestWorkshopKW))

			return 2
		elseIf (linkRef.GetValue(WorkshopPlayerOwned) >= 1.0)
			return 1
		endIf
	endIf
	
	return 0
EndFunction

int Function HasClaimedBeds(ObjectReference bedRef, Actor companionRef)

	if (bedRef != None && bedRef.HasKeyword(DTSleep_OwnBedPrivateKY))
		
		if (companionRef != None)
			if (bedRef.HasActorRefOwner())
				Actor ownerActor = bedRef.GetActorRefOwner()
				if (ownerActor != None && ownerActor != PlayerRef && ownerActor != companionRef)
					
					return -1
				endIf
			endIf
			
			ObjectReference twinBed = None
			
			if (Utility.GetCurrentGameTime() - LastBedUpdateTime < 0.0014)
				if (bedRef == LastBedRef)
					twinBed = LastTwinBedRef
				elseIf (bedRef == LastTwinBedRef)
					twinBed = LastBedRef
				endIf
			endIf
			
			if (twinBed == None)
				twinBed = DTSleep_CommonF.FindNearestAnyBedFromObject(bedRef, DTSleep_BedList, bedRef, TwinBedDistLimit, true)
			endIf
			
			if (twinBed != None && twinBed.HasActorRefOwner())
				Actor ownerActor = twinBed.GetActorRefOwner()
				if (ownerActor != None && ownerActor != PlayerRef && ownerActor != companionRef)
					
					return -1
				endIf
			endIf
		endIf
		
		return 1
	endIf
	
	return 0
endFunction

; ------------ functions intended private -------------

Function AssignCompanionToBed(WorkshopNPCScript workshopCompanion, ObjectReference bedRef)

	if (workshopCompanion != None && bedRef != None)
		
		WorkshopObjectScript workBed = bedRef as WorkshopObjectScript
		
		if (workBed.WorkshopID == MyWorkshopRef.GetWorkshopID())
		
			if (UnassignActorFromBeds(workshopCompanion, workBed))

				WorkshopParent.AssignActorToObjectPUBLIC(workshopCompanion, workBed, true)
			endIf
		endIf
	endIf
endFunction

Function DebugDisplayBedsWorkshopIDs(ObjectReference bedRef, ObjectReference twinRef)
	if (DTSleep_DebugMode.GetValue() >= 1.0)
		if (bedRef != None && MyWorkshopRef != None)
			bool bedHasKeyword = bedRef.HasKeyword(DTSleep_OwnBedPrivateKY)
			bool twinHasKeyword = false
			if (twinRef != None)
				twinHasKeyword = twinRef.HasKeyword(DTSleep_OwnBedPrivateKY)
			endIf
			WorkshopObjectScript workBed = bedRef as WorkshopObjectScript
			int bedID = -1
			if (workBed != None)
				bedID = workBed.WorkshopID
			endIf
			
			Debug.Trace("[DTSleep_BedOwn] marked private (wid=" + bedID + ")? this/twin beds:  " + bedHasKeyword + "/" + twinHasKeyword)
		endIf
	endIf
endFunction

int Function HandleBedsClaimResponse(int response, WorkshopNPCScript workshopCompanion, ObjectReference aBedRef, ObjectReference twinBed)

	int result = 0
	
	if (response == 1 && workshopCompanion != None)
		; claim for both
		MarkBedsPrivate(aBedRef, twinBed)
		AssignCompanionToBed(workshopCompanion, twinBed)
		
		aBedRef.SetActorRefOwner(PlayerRef, true)
		
		if (DTSleep_DebugMode.GetValue() >= 2.0)
			Debug.Trace("[DTSleep_BedOwn] set own twin bed: " + twinBed + " by " + workshopCompanion)
		endIf
		result = 2
		
	elseIf (response <= 2)
		; player only own
		MarkBedsPrivate(aBedRef, twinBed)
		aBedRef.SetActorRefOwner(PlayerRef, true)
		OwnershipBedDeclinedAdd(twinBed)
		result = 1
	else
		; decline (0 or 3)
		if (response >= 3)
			; disable this feature
			DTSleep_SettingBedOwn.SetValue(1.0)
		else
			OwnershipBedDeclinedAdd(aBedRef)
		endIf
	endIf

	return result
endFunction

Function MarkBedPublic(ObjectReference bedRef)

	if (bedRef != None && MyWorkshopRef != None)
	
		WorkshopObjectScript wObj = bedRef as WorkshopObjectScript
		if (wObj != None)
			if (wObj.WorkshopID < 0 || bedRef.HasKeyword(DTSleep_OwnBedPrivateKY))
				int wID = MyWorkshopRef.GetWorkshopID()
				if (wID >= 0)
					if (DTSleep_DebugMode.GetValue() >= 2.0)
						Debug.Trace("[DTSleep_BedOwn] mark " + bedRef + " as public for workshop ID " + wID)
					endIf
					wObj.WorkshopID = wID
					if (bedRef.HasKeyword(DTSleep_OwnBedPrivateKY))
						bedRef.RemoveKeyword(DTSleep_OwnBedPrivateKY)
					endIf
				endIf
			endIf
		endIf
	endIf
endFunction

Function MarkBedsPrivate(ObjectReference bedRef, ObjectReference twinRef, bool removeAssignment = true)
	
	if (bedRef != None)
		WorkshopObjectScript wObj = bedRef as WorkshopObjectScript
		;ObjectReference linkRef = bedRef.GetLinkedRef(WorkshopItemKeyword)
		
		if (wObj != None)
			
			if (MyWorkshopRef != None)
				
				if (!bedRef.HasKeyword(DTSleep_OwnBedPrivateKY))
					if (DTSleep_DebugMode.GetValue() >= 2.0)
						Debug.Trace("[DTSleep_BedOwn] mark " + bedRef + " as private -- remove assignment? " + removeAssignment)
					endIf
					if (removeAssignment)
						; this parent script throws a Papyrus error so let's do same
						;WorkshopParent.UnassignObject(wObj, true)
						UnassignObject(wObj)
					endIf
					
					bedRef.AddKeyword(DTSleep_OwnBedPrivateKY)
				endIf
			endIf
			
			if (twinRef != None)
				wObj = twinRef as WorkshopObjectScript
				if (wObj != None)
					
					if (!twinRef.HasKeyword(DTSleep_OwnBedPrivateKY))
						if (DTSleep_DebugMode.GetValue() >= 2.0)
							Debug.Trace("[DTSleep_BedOwn] mark " + twinRef + " as private")
						endIf
						if (removeAssignment)
							UnassignObject(wObj)
						endIf
						
						twinRef.AddKeyword(DTSleep_OwnBedPrivateKY)
					endIf
				endIf
			endIf
		endIf
	endIf
endFunction

Function OwnershipBedDeclinedAdd(ObjectReference bedRef)
	bedRef.AddKeyword(DTSleep_OwnBedCheckedKY)
	;BedCheckedArray.Add(bedRef)
endFunction

bool Function OwnershipBedDeclinedCheck(ObjectReference bed1Ref, ObjectReference bed2Ref)
	bool result = false
	
	if (bed1Ref != None)
		if (bed1Ref.HasKeyword(DTSleep_OwnBedCheckedKY))
			result = true
		endIf
	endIf
	if (bed2Ref != None && bed2Ref.HasKeyword(DTSleep_OwnBedCheckedKY))
		result = true
	endIf

	return result
endFunction

int Function ShowBedsClaimCheck(Form baseBedForm)
	int response = -1
	
	if (DTSleep_BedsBigDoubleList.HasForm(baseBedForm))
		response = DTSleep_OwnBedDoubleReqMessage.Show()
	else
		response = DTSleep_OwnBedTwinReqMessage.Show()
	endIf
	return response
endFunction

bool Function ShowOtherOwnerCheck(ObjectReference twinBed, Form baseBedForm)
	bool result = false
	Actor otherActor = twinBed.GetActorRefOwner()
	
	if (otherActor == None)
		; nobody actually owns
		Debug.Trace("[DTSleep_BedOwn] WARN! ShowOtherOwnercheck no owner found!!")
		result = true
		
	elseIf (DTSleep_CompanionIntimateAllList.HasForm(otherActor as Form))
		
		; twin not occupied - prompt to replace
		if (DTSleep_DebugMode.GetValue() >= 2.0)
			Debug.Trace("[DTSleep_BedOwn] another companion (" + otherActor + ") owns bed " + twinBed + " -- prompt for replace")
		endIf
		
		DTSleep_OtherOwnerAlias.ForceRefTo(otherActor)
		int response = -1
		
		if (DTSleep_CompanionBelongWorkshop.GetValueInt() > 0)
			; companion belongs to this workshop so may replace
			if (baseBedForm == None)
				baseBedForm = twinBed.GetBaseObject() as Form
			endIf
			if (DTSleep_BedsBigDoubleList.HasForm(baseBedForm))
				response = DTSleep_OwnBedDoubleReassignMessage.Show()
			else
				response = DTSleep_OwnBedTwinReassignMessage.Show()
			endIf
			if (response >= 1)
				
				result = true
			endIf
		else
			; companion does not belong to this workshop - ask to remove assignment
			if (DTSleep_OwnBedRemoveAssignmentMessage.Show() >= 1)
				result = true
			endIf
		endIf
		DTSleep_OtherOwnerAlias.Clear()
	
	else
		if (DTSleep_DebugMode.GetValue() >= 2.0)
			Debug.Trace("[DTSleep_BedOwn] someone else (" + otherActor + ") owns bed " + twinBed + " -- silent swap")
		endIf
		
		return true
	endIf

	return result
endFunction

int Function ShowWarnForOtherOwner(ObjectReference bedRef, bool inUse = false)

	if (bedRef == None)
		return 5
	endIf
	Actor otherActor = bedRef.GetActorRefOwner()
	
	if (otherActor != None)
		
		if (DTSleep_CompanionIntimateAllList.HasForm(otherActor as Form))
			DTSleep_OtherOwnerAlias.ForceRefTo(otherActor)
			
			int choice = 0
			if (inUse)
				choice = DTSleep_OwnBedOwnedCompWarnInUseMsg.Show()
			else
				choice = DTSleep_OwnBedOwnedCompWarnMessage.Show()
			endIf
			DTSleep_OtherOwnerAlias.Clear()
			
			return choice
		endIf

	endIf
	
	return DTSleep_OwnBedOwnedWarnMessage.Show()
endFunction

int Function ShowWarnForSettlerAssigned(ObjectReference bedRef)

	if (bedRef == None)
		return 5
	endIf
	
	WorkshopObjectScript theBed = bedRef as WorkshopObjectScript
	if (theBed != None)
		; get my owner (if any)
		WorkshopNPCScript assignedActor = theBed.GetAssignedActor()

		if (assignedActor != None)
			Actor anActor = assignedActor as Actor
			if (anActor != None)
				if (!DTSleep_CompanionIntimateAllList.HasForm(anActor as Form))
				
					return DTSleep_OwnBedOtherAssignWarnMsg.Show()
				endIf
			endIf
		endIf
	endIf
	
	return 10
endFunction

; return false if already assigned to notBed else true
;
bool Function UnassignActorFromBeds(WorkshopNPCScript workshopActor, WorkshopObjectScript notBed)

	bool result = true
	
	if (MyWorkshopRef != None && workshopActor != None)
	
		ObjectReference[] beds = WorkshopParent.GetBeds(MyWorkshopRef)
		int i = 0
		
		while (i < beds.length)
			
			WorkshopObjectScript theBed = beds[i] as WorkshopObjectScript

			if (theBed.IsActorAssigned() && theBed.GetAssignedActor() == workshopActor)
			
				if (notBed != None && notBed == theBed)
					
					result = false
				else
					if (DTSleep_DebugMode.GetValue() >= 2.0)
						Debug.Trace("[DTSleep_BedOwn] remove actor " + workshopActor + " from old bed " + theBed)
					endIf
					UnassignObject(theBed)
				endIf
			endIf
			
			i += 1
		endWhile	
	endIf
	
	return result
endFunction

; copied and trimmed from WorkShopParentScript
;
bool Function UnassignObject(WorkshopObjectScript theObject, bool includeCompanions = true)

	; get my owner (if any)
	WorkshopNPCScript assignedActor = theObject.GetAssignedActor()

	if (assignedActor != None)
	
		if (!includeCompanions)
			Actor anActor = assignedActor as Actor
			if (anActor != None && DTSleep_CompanionIntimateAllList.HasForm(anActor as Form))
				; do not remove assignment

				return false
			endIf
		endIf
	
		if (DTSleep_DebugMode.GetValue() >= 2.0)
			Debug.Trace("[DTSleep_BedOwn] UnassignObject bed assigned to " + assignedActor)
		endIf
		
		; clear ownership
		theObject.AssignActor(none)

		; clear link if it exists
		if (theObject.AssignedActorLinkKeyword)
			assignedActor.SetLinkedRef(NONE, theObject.AssignedActorLinkKeyword)
		endif
		
		; only need partial from this function in parent script
		;Self.UpdateWorkshopRatingsForResourceObject(theObject, workshopRef, bRemoveObject, True)
		if (MyWorkshopRef != None)
			MyWorkshopRef.RecalculateWorkshopResources(true)
		endIf
		
		return true
	endIf
	
	return false
endFunction

Function VerifyCompanionKnown(Actor companionRef)

	if (companionRef != None && !DTSleep_CompanionIntimateAllList.HasForm(companionRef as Form))
	
		; assumed companion is romantic
		if (DTSleep_DebugMode.GetValue() >= 1.0)
			Debug.Trace("[DTSleep_BedOwn] ****adding**** " + companionRef + " to known intimate companion list")
		endIf
		DTSleep_CompanionIntimateAllList.AddForm(companionRef as Form)
	endIf

endFunction

; returns none if does not belong to this workshop
;
WorkshopNPCScript Function WorkshopNPCForActor(Actor actorRef)

	if (MyWorkshopRef == None || actorRef == None)
		return None
	endIf
	int workshopID = MyWorkshopRef.GetWorkshopID()
	if (workshopID <= 0)
		; not a real workshop
		return None
	endIf

	WorkshopNPCScript worker = actorRef as WorkshopNPCScript
	if (worker != None)
		int workerID = worker.GetWorkshopID()

		if (workerID >= 0)
			if (workerID == workshopID)
				DTSleep_CompanionBelongWorkshop.SetValue(1.0)
				
				return worker
			else
				return None
			endIf
		endIf
	endIf
	
	; just in case, check list
	ObjectReference[] workshopActorsArray = MyWorkshopRef.GetWorkshopResourceObjects(WorkshopParent.WorkshopRatings[WorkshopParent.WorkshopRatingPopulation].resourceValue, 0)
	
	if (workshopActorsArray != None)
		int i = 0
		while (i < workshopActorsArray.Length)
		
			WorkshopNPCScript npc = workshopActorsArray[i] as WorkshopNPCScript
			if (npc != None && npc.GetWorkshopID() == workshopID)
			
				Actor npcActor = npc as Actor
				if (npcActor == actorRef)
					; mark it
					DTSleep_CompanionBelongWorkshop.SetValue(1.0)
					
					return npc
				endIf
			endIf
			i += 1
		endWhile
	endIf
	
	return None
endFunction