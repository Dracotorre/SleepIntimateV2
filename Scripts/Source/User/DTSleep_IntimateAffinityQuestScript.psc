Scriptname DTSleep_IntimateAffinityQuestScript extends Quest


; by DracoTorre
; www.dracotorre.com/mods/sleepintimate/
;
; helper quest to update affinity for intimate actions

Actor property CompanionCaitRef auto const
Actor property CurieRef auto const
Actor property CompanionDanseRef auto const
Actor property CompanionHancockRef auto const
Actor property CompanionMacCreadyRef auto const
Actor property CompanionPiperRef auto const
Actor property CompanionPrestonRef auto const

Keyword property CA_CustomEvent_CaitHatesKY auto const
Keyword property CA_CustomEvent_CurieHatesKY auto const
Keyword property CA_CustomEvent_DanseHatesKY auto const
Keyword property CA_CustomEvent_HancockHatesKY auto const
Keyword property CA_CustomEvent_MacCreadyHatesKY auto const
Keyword property CA_CustomEvent_PiperHatesKY auto const
Keyword property CA_CustomEvent_PrestonHatesKY auto const

Keyword property CA_CustomEvent_CaitLikesKY auto const
Keyword property CA_CustomEvent_HancockLikesKY auto const

GlobalVariable property DTSleep_SettingDoAffinity auto const

float property LastAffinitySentTime auto hidden


; **************************** public functions *******************************

Function AffinityIntimateScenePublic(Actor comp1, Actor comp2 = None)
	if (DTSleep_SettingDoAffinity.GetValueInt() > 0 && comp1 != None)
	
		if (CheckOkayTimeToSend())
			SendIntimateEventAffinity(comp1, comp2)
		endIf
	endIf
endFunction

Function AffinityIntimateSceneStrongPublic()
	; no setting override

	SendIntimateStrongEventAffinity()
endFunction

Function AffinityIntimateSceneDogPublic()
	if (DTSleep_SettingDoAffinity.GetValueInt() > 0)
		if (CheckOkayTimeToSend())
			SendIntimateDogEventAffinity()
		endIf
	endIf
endFunction

bool Function CompanionHatesIntimateOtherPublic(Actor companionRef)

	if (companionRef == CompanionCaitRef)
		return true
	elseIf (companionRef == CompanionDanseRef)
		return true
	elseIf (companionRef == CompanionHancockRef)
		return true
	elseIf (companionRef == CompanionMacCreadyRef)
		return true
	elseIf (companionRef == CompanionPiperRef)
		return true
	endIf

	return false
endFunction

; ***************************** functions intended private *********************

bool Function CheckOkayTimeToSend()

	float curTime = Utility.GetCurrentGameTime()
	float timeSince = 10.0
	if (LastAffinitySentTime > 0.0)
		timeSince = curTime - LastAffinitySentTime
	endIf

	if (timeSince > 0.041)		; about an hour
		LastAffinitySentTime = curTime
		
		return true
	endIf
	
	return false
endFunction

Function SendAffinityEvent(keyword affinityKeyword, bool suppressComment = false, bool dialogueBump = false, bool checkProximity = true)
	
	;Debug.Trace("[DTSleep_IntimateAffinity] send affinity event KY " + affinityKeyword + " LastTime: " + LastAffinitySentTime)
	; global function
	FollowersScript.SendAffinityEvent(self, affinityKeyword, ShouldSuppressComment = suppressComment, IsDialogueBump = dialogueBump, CheckCompanionProximity = checkProximity)
endFunction

Function SendIntimateDogEventAffinity()

	if (CompanionCaitRef.GetSleepState() <= 2)
		; same as naked like
		SendAffinityEvent(CA_CustomEvent_CaitLikesKY)
	endIf
	
	CompanionActorScript aCompanion = CompanionDanseRef as CompanionActorScript
	if (aCompanion != None && aCompanion.IsRomantic() && CompanionDanseRef.GetSleepState() <= 2)
		SendAffinityEvent(CA_CustomEvent_DanseHatesKY)
	endIf
	
	if (CompanionHancockRef.GetSleepState() <= 2)
		; same as naked like
		SendAffinityEvent(CA_CustomEvent_HancockLikesKY)
	endIf
	
	aCompanion = CompanionMacCreadyRef as CompanionActorScript
	if (aCompanion != None && aCompanion.IsRomantic() && CompanionMacCreadyRef.GetSleepState() <= 2)
		SendAffinityEvent(CA_CustomEvent_MacCreadyHatesKY)
	endIf
	
	aCompanion = CompanionPiperRef as CompanionActorScript
	if (aCompanion != None && aCompanion.IsRomantic() && CompanionPiperRef.GetSleepState() <= 2)
		SendAffinityEvent(CA_CustomEvent_PiperHatesKY)
	endIf
	
endFunction

Function SendIntimateStrongEventAffinity()

	if (CompanionCaitRef.GetSleepState() <= 2)
		SendAffinityEvent(CA_CustomEvent_CaitHatesKY)
	endIf
	
	if (CurieRef.GetSleepState() <= 2)
		SendAffinityEvent(CA_CustomEvent_CurieHatesKY)
	endIf
			
	if (CompanionDanseRef.GetSleepState() <= 2)
		SendAffinityEvent(CA_CustomEvent_DanseHatesKY)
	endIf
	
	if (CompanionHancockRef.GetSleepState() <= 2)
		SendAffinityEvent(CA_CustomEvent_HancockHatesKY)
	endIf
	
	if (CompanionMacCreadyRef.GetSleepState() <= 2)
		SendAffinityEvent(CA_CustomEvent_MacCreadyHatesKY)
	endIf
	
	if (CompanionPiperRef.GetSleepState() <= 2)
		SendAffinityEvent(CA_CustomEvent_PiperHatesKY)
	endIf
	
	if (CompanionPrestonRef.GetSleepState() <= 2)
		SendAffinityEvent(CA_CustomEvent_PrestonHatesKY)
	endIf
	
endFunction

Function SendIntimateEventAffinity(Actor comp1, Actor comp2)
		
	if (comp1 != CompanionCaitRef && comp2 != CompanionCaitRef)
		
		CompanionActorScript aCompanion = CompanionCaitRef as CompanionActorScript
				
		if (aCompanion != None && aCompanion.IsRomantic() && CompanionCaitRef.GetSleepState() <= 2)
			SendAffinityEvent(CA_CustomEvent_CaitHatesKY)
		endIf
	endIf
	
	if (comp1 != CurieRef && comp2 != CurieRef)
		
		CompanionActorScript aCompanion = CurieRef as CompanionActorScript
				
		if (aCompanion != None && aCompanion.IsRomantic() && CurieRef.GetSleepState() <= 2)
			SendAffinityEvent(CA_CustomEvent_CurieHatesKY)
		endIf
	endIf
	
	if (comp1 != CompanionDanseRef && comp2 != CompanionDanseRef)
		
		CompanionActorScript aCompanion = CompanionDanseRef as CompanionActorScript
				
		if (aCompanion != None && aCompanion.IsRomantic() && CompanionDanseRef.GetSleepState() <= 2)
			SendAffinityEvent(CA_CustomEvent_DanseHatesKY)
		endIf
	endIf
	
	if (comp1 != CompanionHancockRef && comp2 != CompanionHancockRef)
		
		CompanionActorScript aCompanion = CompanionHancockRef as CompanionActorScript
				
		if (aCompanion != None && aCompanion.IsRomantic() && CompanionHancockRef.GetSleepState() <= 2)
			SendAffinityEvent(CA_CustomEvent_HancockHatesKY)
		endIf
	endIf
	
	if (comp1 != CompanionMacCreadyRef && comp2 != CompanionMacCreadyRef)
		
		CompanionActorScript aCompanion = CompanionMacCreadyRef as CompanionActorScript
				
		if (aCompanion != None && aCompanion.IsRomantic() && CompanionMacCreadyRef.GetSleepState() <= 2)
			SendAffinityEvent(CA_CustomEvent_MacCreadyHatesKY)
		endIf
	endIf
	
	if (comp1 != CompanionPiperRef && comp2 != CompanionPiperRef)
		
		CompanionActorScript aCompanion = CompanionPiperRef as CompanionActorScript
				
		if (aCompanion != None && aCompanion.IsRomantic() && CompanionPiperRef.GetSleepState() <= 2)
			SendAffinityEvent(CA_CustomEvent_PiperHatesKY)
		endIf
	endIf
endFunction