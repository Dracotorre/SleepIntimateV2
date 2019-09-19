Scriptname DTSleep_HealthRecoverQuestScript extends Quest

; by DracoTorre
; www.dracotorre.com/mods/sleepintimate/
; https://github.com/Dracotorre/SleepIntimateV2
;
; gradually recover health over game-time with chance for disease 
; supports Hardcore/Survival which simply recovers health and fatigue since HC_Manager runs everything on timers
; player may interrupt and continue sleep if within 2 hours
;
; see HourCount for length of time, considered public
;
; notes:
; we can ignore sleep effects potions since HC_Manager timer will re-apply automatically even during our game-time nap
; so, adjust fatigue (HC_SleepEffect actor value) which points to which sleep effect in HC-SleepEffects list
; 
; checks for time jumps via console commands or mods--one such mod is SleepTogether Anywhere which has its own sleep menu to pass time
;

Quest property DT_PotionHandleQuestP auto const
Quest property HC_Manager auto const

Actor property PlayerRef auto const
GlobalVariable property TimeScale auto const
GlobalVariable property GameHour auto
GlobalVariable property HC_Rule_DiseaseEffects auto const
GlobalVariable property HC_SE_Incapacitated auto const
ActorValue property HealthAV auto const
ActorValue property HC_SleepEffectAV auto const
ActorValue property HC_AdrenalineAV auto const
ActorValue property EnduranceCondition auto const
ActorValue property LeftAttackCondition auto const
ActorValue property LeftMobilityCondition auto const
ActorValue property PerceptionCondition auto const
ActorValue property RightAttackCondition auto const
ActorValue property RightMobilityCondition auto const
Perk property HC_AdrenalinePerk auto const
MagicEffect property HC_Disease_Insomnia_Effect auto const
MagicEffect property HC_Herbal_Antimicrobial_Effect auto const
GlobalVariable property DTSleep_HRLastSleepHourCount auto
GlobalVariable property DTSleep_HRLastSleepTime auto
GlobalVariable property DTSleep_PlayerUsingBed auto const
{ set to zero if player done resting }
GlobalVariable property DTSleep_SettingNapRecover auto const
GlobalVariable property DTSleep_SettingNotifications auto const
GlobalVariable property DTSleep_SettingNapOnly auto const
GlobalVariable property DTSleep_SettingTestMode auto const
GlobalVariable property DTSleep_SettingFastTime auto const
GlobalVariable property DTSleep_SettingFastSleepEffect auto const
GlobalVariable property DTSleep_DebugMode auto const
GlobalVariable property DTSleep_StatHoursRest auto
Message property DTSleep_InsomniaWarnMsg auto const
Message property DTSleep_TimePassFastMsg auto const
Message property DTSleep_TimePassRestoreMsg auto const
Message property DTSleep_RestOverEncumberedMsg auto const
Message property DTSleep_ResumeRestMsg auto const
Message property DTSleep_ResumeRestPoorMsg auto const
Potion property HC_DiseaseEffect_Infection auto const
Potion property HC_DiseaseEffect_Lethargy auto const

ImageSpaceModifier property FastTimeISM auto const
ImageSpaceModifier property FastTimeFadeInISM auto const
ImageSpaceModifier property FastTimeFadeOutISM auto const

int property BedType = 0 auto hidden			; set using convenience functions
int property FastSleepStatus = 0 auto hidden
int property HourCount = 0 auto hidden
int property HoursOversleep auto hidden
int property PoorSleepHourLimit auto hidden
float property SleepWaitHours = 0.0 auto hidden
bool property IsDone = false auto hidden
bool property GoodSleep auto hidden
float property LastGameTimeHourUpdate auto hidden
float property RestStartedTime auto hidden
float property TimeScaleOriginal auto hidden
float property LastSleepCheckTime auto hidden
bool property SleepInterrupted auto hidden
bool property SleepStarted auto hidden
bool property PlayerWellRested auto hidden
bool property SleepyPlayer auto hidden
{ set on SleepTime check - only valid if recently checked IsSleepTimePublic }
float property PlayerWellRestedTime auto hidden

; ---------------------------------------------------------------------
; ************************ Custom Events ******************************
; ---------------------------------------------------------------------
; listen to this to be notified of poor rest
;  - 0=player exit early, 1=over-encumbered, 2=poor sleep
;  - no notification if player exit bed before 1 game-hour 
CustomEvent RestInterruptionEvent

; listen to this for notification of rest finished, interrupted or not
;   - will only notify if rest 1+ hours so that player may exit bed without counting as sleep
CustomEvent RestCompleteEvent
;   kArgs[0] = interruptType: 0=player exit early, 1=over-encumbered, 2=poor sleep
;   kArgs[1] = HourCount	: rest hours
;   kArgs[2] = IsDone		: bool- full-rest for bed type (5 for ground bed, 7+ for regular bed)
;   kArgs[3] = GoodSleep	: bool- no interruption, complete
;   kArgs[4] = BedType		: see SleepBed*ID below
;	kArgs[5] = RecoveryPref : int- 0=no fatigue or health recovery applied, 1=health recovery; fatigue set if Survival difficulty
;   

; listen to this for notification of rest started for first game hour completed --- 
;    this gives chance for player to change mind and exit bed in first hour
CustomEvent RestStartedEvent
;	kArgs[0] = HourCount  	: if larger than 1, rest continued 
;
; ****************************************************************************

int TimeScaleSpeedVal = 40 const			; default fast-time speed
int SleepBedNoneID = 0 const
int SleepBedSleepBagID = 1 const
int SleepBedGroundMattressID = 2 const
int SleepBedCampingID = 3 const
int SleepBedFullID = 4 const
int SleepBedOwnID = 5 const
int SleepNapRecRealTimerID = 98 const
int SleepNapRecGameTimerID = 104 const		; health
int SleepNapFatGameTimerID = 106 const		; fatigue and adrenaline
int SleepNapTimeScaleTimerID = 99 const

; *************************************************************
; events

Event OnQuestInit()
	HourCount = -1
	SleepWaitHours = 0.0
	SleepStarted = false
	IsDone = false
	GoodSleep = true
	PlayerWellRested = false
	PlayerWellRestedTime = -1.0
	LastGameTimeHourUpdate = Utility.GetCurrentGameTime()
	RestStartedTime = LastGameTimeHourUpdate
	TimeScaleOriginal = TimeScale.GetValue()
	HoursOversleep = 7
	PoorSleepHourLimit = 4
	SleepInterrupted = false
	
	StartTimer(57.0, SleepNapTimeScaleTimerID)			; check after minute --player committed to sleep
	StartTimerGameTime(0.356, SleepNapRecGameTimerID)
	StartTimerGameTime(0.987, SleepNapFatGameTimerID)	; first hour a bit short; 59m
EndEvent

Event OnTimer(int aiTimerID)
	if (aiTimerID == SleepNapTimeScaleTimerID)
		CheckPrepareSleep()
		CheckTimeScale()
	elseIf (aiTimerID == SleepNapRecRealTimerID)
		PlayerNapRecover()
	endIf
EndEvent

Event OnTimerGameTime(int aiTimerID)

	if (aiTimerID == SleepNapRecGameTimerID)
		PlayerNapRecover()
		
	elseIf (aiTimerID == SleepNapFatGameTimerID)
		PlayerNapRecoverFatigue()
	endIf
EndEvent

; ****************************************************
; public convenience functions and Stop functions

; only use this once before rest check as it marks last time checked
; for repeat checks between Rest see SleepyPlayer property
;
bool Function IsSleepTimePublic(float gameTime)
	SleepyPlayer = false
	
	if (Game.GetDifficulty() >= 6)
		; fatigue sleep effect
		int sleepEffectVal = PlayerRef.GetValue(HC_SleepEffectAV) as int
		if (sleepEffectVal >= 2)
			; sleepy
			SleepyPlayer = true
		endIf
	endIf
	
	if (SleepyPlayer)
		if (LastGameTimeHourUpdate > 0.0 && (gameTime - LastGameTimeHourUpdate) < 2.0)
			if ((gameTime - LastGameTimeHourUpdate) > 0.74)
				
				return true
			endIf
		elseIf (LastSleepCheckTime > 0.0 && (gameTime - LastSleepCheckTime) < 2.0)
			if ((gameTime - LastSleepCheckTime) > 0.76)
				
				SleepyPlayer = true
			endIf
		else
			; use hour of day
			float dayFrac = gameTime - Math.Floor(gameTime)
			
			if (dayFrac > 0.7917 || dayFrac < 0.1667)
			
				SleepyPlayer = true
			endIf
		endIf
	endIf
	
	LastSleepCheckTime = gameTime
	
	return SleepyPlayer	
endFunction

Function SetBedTypeCamping()
	BedType = SleepBedCampingID
endFunction

Function SetBedTypeFull()
	BedType = SleepBedFullID
endFunction

Function SetBedTypeOwn()
	BedType = SleepBedOwnID
endFunction

Function SetBedTypeMattress()
	BedType = SleepBedGroundMattressID
endFunction

Function SetBedTypeSleepingBag()
	BedType = SleepBedSleepBagID
endFunction

Function StopAllCancel()
	
	if (!IsDone)
		;Debug.Trace("[DTSleep_HealthRec] StopAllCancel HourCount = " + HourCount)
		IsDone = true
		if (HourCount >= 5)
			if (HourCount >= 7)
				HandleStop(true, true)		;v2.13 allow full recover for 7+ hours
			else
				HandleStop(true, false)
			endIf
		else 
			HandleStop()
		endIf
	endIf
	
endFunction

Function StopAllDone(bool fullRecover)
	
	if (!IsDone)
		IsDone = true
		HandleStop(fullRecover, true)
		
		Utility.Wait(0.2)
	endIf
endFunction

; **************************************************************
; considered private functions

; ------

; AdvanceTime - sets GameHour ahead at rate just faster (0.8) than game-hour per real-minute
; - it takes the game ~2 seconds to actually update the game time then allow time for game-hour timers
; - additionally, time between skips (timeRemainInRealSec) must allow process time
; --- and consider features dependent on order of real-time and game-time events
; - avoids skipping over day-change to allow game to handle updates and record stats
;
; hourToNext - send total game-hour time between events
; returns real-time seconds remaining (for timers)
;
float Function AdvanceTime(float hourToNext = 0.33330) ;float hourToNext = 0.250)
	float timeSkip = 0.233330; 0.1750							; default time-scale and hourToNext pre-calc
	float timeRemainInRealSec = 18.00; 13.50				; time-scale independent - to return
	float timeScaleVal = TimeScale.GetValue()		; get current time-scale - player or another mod may change
													; approximates 66 TimeScale by set clock
	
	; restrict - faster time-scale same as fast-time setting
	if (timeScaleVal >= 0.250 && timeScaleVal <= 30.0)
	
		if (timeScaleVal != 20.0 || hourToNext != 0.33330)
			if (timeScaleVal == 30.0 && hourToNext == 0.33330)
				timeSkip = 0.183330; 0.100
			else
				; calculate skip
				float multi = 60.0 / timeScaleVal
				float subSec = timeRemainInRealSec / (multi * 60)
				timeSkip = hourToNext - subSec
			endIf
		endIf
		float gHour = GameHour.GetValue()
		
		; ensure day-change processed including days-passed stat
		if (gHour < 23.7330)
			float newVal = gHour + timeSkip
			if (newVal >= 23.967)
				newVal = 23.967		; 6 real-time seconds (20 time-scale) before day change
			endIf
			GameHour.SetValue(newVal)
		else
			; 6 real-time seconds (20 time-scale) before day change
			timeSkip = 23.967 - gHour
			GameHour.SetValue(23.967)
		endif
		
		; record total to update Hours Waited stat at end
		SleepWaitHours += timeSkip
	else
		timeSkip = 0.0
	endIf
	
	return timeRemainInRealSec
endFunction

; player might have skipped time! check to make sure and adjust as needed
; returns number of hours inremented or zero for error--out of game-time --- v2.16: changed from bool to int to handle skip-time
;
int Function CheckGameHourIncrement()
	int result = 1
	
	if (HourCount < 0)
		InitHourCount()
		int napOnly = DTSleep_SettingNapOnly.GetValueInt()
		
		if (HourCount >= 1)
			SleepInterrupted = true
			
			if (DTSleep_SettingNotifications.GetValue() > 0.0 && napOnly > 0)
				if (GoodSleep)
					DTSleep_ResumeRestMsg.Show(HourCount + 1)
				else
					DTSleep_ResumeRestPoorMsg.Show(HourCount + 1)
				endIf
			endIf
		endIf
		
		if (napOnly > 0)
			SendRestStartedEvent()
		endIf
	endIf

	HourCount += 1
	
	float currentGameTime = Utility.GetCurrentGameTime()
	float hourDiff = GetHoursDifference(currentGameTime, LastGameTimeHourUpdate)
	
	if (hourDiff >= 2.0)			 
		
		if (currentGameTime < LastGameTimeHourUpdate)
			; so we went backwards?
			HourCount -= (hourDiff as int)
			if (HourCount < 1)
				HourCount = 1
			endIf
			result = 0
			Debug.Trace("[DTSleep_HealthRec] time went backwards by " + hourDiff + " hours!!")
		else
			result = Math.Floor(hourDiff)			; v2.16 - return increment
			HourCount += (result - 1)				; already incremented 1
			
			if (DTSleep_DebugMode.GetValueInt() >= 1)
				Debug.Trace("[DTSleep_HealthRec] time skipped ahead by " + hourDiff + " hours-- set HourCount = " + HourCount)
			endIf
		endIf
	endIf
	
	LastGameTimeHourUpdate = currentGameTime

	return result
	
endFunction

Function CheckPrepareSleep()

	SleepStarted = true
	int napOnly = DTSleep_SettingNapOnly.GetValueInt()
	
	; check to prevent forced wake due fatigue level
	if (Game.GetDifficulty() >= 6 && napOnly > 0)
		float sleepEffectVal = PlayerRef.GetValue(HC_SleepEffectAV)
		float incapVal = HC_SE_Incapacitated.GetValue()
		if (sleepEffectVal >= incapVal)
			; set 1 better (Exhausted) to prevent incapacitated forcing wake
			sleepEffectVal = incapVal - 1
			PlayerRef.SetValue(HC_SleepEffectAV, sleepEffectVal)
		endIf
	endIf
endFunction

Function CheckTimeScale()
	
	int napSpeed = DTSleep_SettingNapOnly.GetValueInt()
	
	; v1.61 - no scale if player over-encumbered
	if (napSpeed >= 2 && !PlayerRef.IsOverEncumbered() && HourCount <= 4 && DTSleep_PlayerUsingBed.GetValue() >= 1.0)

		float curTime = Utility.GetCurrentGameTime()
		float hoursSinceStart = GetHoursDifference(RestStartedTime, curTime)
		if (hoursSinceStart < 1.50)				; v2.16 - prevent time-scale change if skipped time
			if (napSpeed == 3)
				int curVal = TimeScale.GetValueInt()			; get current - may have changed since original recorded
				if (curVal < 20)
					; speed up for players using longer hours so final hour reduced to 3 minutes real-time
					IncreaseTimeScale(20)
				endIf
			elseIf (napSpeed == 2)
				; TimeScale adjust
				int curVal = TimeScale.GetValueInt()			; get current - may have changed since init
				
				if (curVal < TimeScaleSpeedVal)
					int timeScaleVal = TimeScaleSpeedVal
					int timeScaleSettingVal = DTSleep_SettingFastTime.GetValueInt()
					
					if (timeScaleSettingVal > 0)
						if (timeScaleSettingVal == 1)
							timeScaleVal = 50
						elseIf (timeScaleSettingVal >= 2)
							; risky? -- game-hour = real-time minute
							timeScaleVal = 60
						endIf
					endIf
					IncreaseTimeScale(timeScaleVal)
				endIf
			endIf
		elseIf (DTSleep_DebugMode.GetValue() >= 1.0)
			Debug.Trace("[DTSleep_HealthRec] not adjusting time-scale due to skipped hours " + hoursSinceStart)
		endIf
	endIf
		
endFunction

Function FastSleepEffectOff()

	FastSleepStatus = 0
	if (DTSleep_SettingFastSleepEffect.GetValue() > 0.0)
		FastTimeISM.PopTo(FastTimeFadeOutISM)
		Utility.Wait(1.0)
		FastTimeFadeOutISM.Remove()
	endIf
endFunction

Function FastSleepEffectOn(int status = 2)
	FastSleepStatus = status
	
	if (DTSleep_SettingFastSleepEffect.GetValue() > 0.0)
		FastTimeFadeInISM.Apply()
		Utility.Wait(1.0)
		FastTimeFadeInISM.PopTo(FastTimeISM)
	endIf
endFunction

Function IncreaseTimeScale(int timeScaleVal)
	TimeScale.SetValueInt(timeScaleVal)
	
	FastSleepEffectOn()
	
	if (DTSleep_SettingNotifications.GetValue() >= 1.0)
		DTSleep_TimePassFastMsg.Show()
	endIf
endFunction

Function InitHourCount(bool resetHours = false)
	HourCount = 0
	
	int lastSleepHours = DTSleep_HRLastSleepHourCount.GetValueInt()
	float curTime = Utility.GetCurrentGameTime()
	
	if (curTime > RestStartedTime)
		if (DTSleep_SettingNapOnly.GetValue() >= 1.0 && lastSleepHours >= 2)
			float hoursSince = GetHoursDifference(DTSleep_HRLastSleepTime.GetValue(), LastGameTimeHourUpdate)
			int upperLim = 5
			
			if (hoursSince < 2.5)
				if (resetHours)
					HourCount = lastSleepHours
					
				elseIf (lastSleepHours >= upperLim)
					HourCount = upperLim - 1
					GoodSleep = false
				else
					HourCount = lastSleepHours - 1
				endIf
				
				if (!GoodSleep && HourCount >= PoorSleepHourLimit)
					PoorSleepHourLimit = HourCount + 1
				endIf
				
				if (DTSleep_SettingTestMode.GetValueInt() > 0 && DTSleep_DebugMode.GetValue() >= 2.0)
					Debug.Trace("[DTSleep_HealthRec] resume-sleep init setting HourCount " + HourCount)
				endIf
			elseIf (hoursSince < 8.0 && lastSleepHours >= 5)
				HourCount = 1
			endIf
		endIf
		
	elseIf (curTime < RestStartedTime)
		Debug.Trace("[DTSleep_HealthRec] InitHourCount detected went backward in time!! ")
	endIf
endFunction

float Function GetHoursDifference(float time1, float time2)
	float result = 0.0
	if (time2 == time1)
		return 0.0
	elseIf (time2 > time1)
		result = time2 - time1
	else
		result = time1 - time2
	endIf
	result *= 24.0
	return result
endFunction

Function HandleStop(bool fullRecover = false, bool fullSleep = false)
	
	CancelTimer(SleepNapTimeScaleTimerID)
	CancelTimerGameTime(SleepNapRecGameTimerID)
	CancelTimerGameTime(SleepNapFatGameTimerID)
	
	float currentGameTime = Utility.GetCurrentGameTime()
	float hourDiff = GetHoursDifference(currentGameTime, LastGameTimeHourUpdate)
	float hourDFraction =  hourDiff - Math.Floor(hourDiff)
	bool updateStats = true
	
	if (HourCount < 0)
		; check if resume sleep
		updateStats = false		; added v1.24
		InitHourCount(true)		; edited with true-flag v1.24
		SleepInterrupted = true
	else
		; stayed in bed long enough to start sleep and init hours
		DTSleep_HRLastSleepTime.SetValue(currentGameTime)
	endIf
	
	if (hourDFraction >= 0.75)
		; close enough to round up
		HourCount += 1
	endIf
	
	if (HourCount > 0 && updateStats)
		
		DTSleep_HRLastSleepHourCount.SetValueInt(HourCount)
		
		; record stat
		float hoursSinceStart = GetHoursDifference(currentGameTime, RestStartedTime)
		float totalRest = hoursSinceStart + DTSleep_StatHoursRest.GetValue()
		DTSleep_StatHoursRest.SetValue(totalRest)
		
		if (DTSleep_SettingTestMode.GetValueInt() > 0 && DTSleep_DebugMode.GetValue() >= 2.0)
			Debug.Trace("[DTSleep_HealthRec] recording HourCount " + HourCount)
		endIf
	endIf
	
	if (TimeScaleOriginal < 1)
		TimeScaleOriginal = 20
	endIf
	
	if (updateStats)
		; v1.33 don't give disease on continued rest under 1 hour
		bool diseaseGiven = PlayerDiseaseCheckBed(BedType, HourCount)  
		
		if (GoodSleep && !diseaseGiven && HourCount >= 2)
			if (fullSleep)
				PlayerNapRecoverFinal(2)
			elseIf (fullRecover)
				PlayerNapRecoverFinal(1)
			else
				PlayerNapRecoverFinal(0)
			endIf
			
		elseIf (HourCount == 1 && Game.GetDifficulty() >= 6 && DTSleep_SettingNapOnly.GetValue() > 0.0)
		
			; penalty for hour nap - no penalty for under hour
			int sleepEffectVal = 1 + (PlayerRef.GetValue(HC_SleepEffectAV) as int)
			
			PlayerRef.SetValue(HC_SleepEffectAV, sleepEffectVal as float)
			; no reset at start so reset now for new sleep effect
			SetHCSleepTimer(8.0, false)
			
			SendRestCompleteEvent(0)
		endIf
	endIf
	
	if (TimeScaleOriginal != TimeScale.GetValue())
		if (DTSleep_SettingTestMode.GetValueInt() > 0 && DTSleep_DebugMode.GetValue() >= 2.0)
			Debug.Trace("[DTSleep_HealthRec] restoring TimeScale to " + TimeScaleOriginal)
		endIf
		
		TimeScale.SetValue(TimeScaleOriginal)
		
		FastSleepEffectOff()
		
		;if (DTSleep_SettingNotifications.GetValue() >= 1.0)
		;	DTSleep_TimePassRestoreMsg.Show()
		;	Utility.Wait(1.2)
		;endIf
	elseIf (FastSleepStatus > 0)
		FastSleepEffectOff()
	endIf
	
	if (SleepWaitHours > 0.0)
		int waitHourCount = SleepWaitHours as int
		if (waitHourCount >= 1)
			Game.IncrementStat("Hours Waiting", waitHourCount)
		endIf
		SleepWaitHours = 0.0
	endIf
	
	self.Stop()
endFunction

; set timer to whatever and regain default fraction 
; fraction 0.02500 every 15 game-minutes = 1/2 full recovery in 5 game-hours (6-hour sleep)
; fraction 0.03333 every 20 game-minutes = 1/2 full recovery in 5 game-hours
;
Function PlayerNapRecover(float fractionVal = 0.03333, float nextTimerHours = 0.33330)
	
	if (PlayerRef.IsOverEncumbered())
			GoodSleep = false
			if (DTSleep_SettingNotifications.GetValue() > 1.0)
				DTSleep_RestOverEncumberedMsg.Show()
				Utility.Wait(0.6)
			endIf
			
			Utility.Wait(0.8)
			SendRestInterruptEvent(1)
			
	elseIf (GoodSleep && DTSleep_SettingNapRecover.GetValue() > 0.0 && DTSleep_PlayerUsingBed.GetValue() > 0.0)
	
		if (SleepStarted)
			; heal okay after committed to sleep
			if (HourCount >= 5)
				fractionVal = fractionVal * 2.0
			endIf
			float healthTrueMax = PlayerRef.GetValue(HealthAV)
			RestoreValueByFraction(HealthAV, fractionVal, healthTrueMax)
			
			if (Game.GetDifficulty() >= 6)
				
				; bone recovery - copied from HC_Manager and adjusted for per-hour basis
				float enduranceTrueMax     = PlayerRef.GetValue(EnduranceCondition)
				float leftAttackTrueMax    = PlayerRef.GetValue(LeftAttackCondition)
				float leftMobilityTrueMax  = PlayerRef.GetValue(LeftMobilityCondition)
				float perceptionTrueMax    = PlayerRef.GetValue(PerceptionCondition)
				float rightAttackTrueMax   = PlayerRef.GetValue(RightAttackCondition)
				float rightMobilityTrueMax = PlayerRef.GetValue(RightMobilityCondition)
				
				RestoreValueByFraction(EnduranceCondition, fractionVal, enduranceTrueMax)
				RestoreValueByFraction(LeftAttackCondition, fractionVal, leftAttackTrueMax)
				RestoreValueByFraction(LeftMobilityCondition, fractionVal, leftMobilityTrueMax)
				RestoreValueByFraction(PerceptionCondition, fractionVal, perceptionTrueMax)
				RestoreValueByFraction(RightAttackCondition, fractionVal, rightAttackTrueMax)
				RestoreValueByFraction(RightMobilityCondition, fractionVal, rightMobilityTrueMax)
				
			endIf
		endIf
		
		int hourLimit = 5
		
		if (BedType == SleepBedOwnID)
			hourLimit = 6
		endIf
		
		if (SleepStarted && HourCount < hourLimit && DTSleep_SettingNapOnly.GetValueInt() == 3)
			; faster-wait-time
			
			float nextRealTime = AdvanceTime(nextTimerHours)
			if (nextRealTime > 0.0)
				if (FastSleepStatus < 1)
					FastSleepEffectOn(1)
				endIf
				StartTimer(nextRealTime, SleepNapRecRealTimerID)
			else
				StartTimerGameTime(nextTimerHours, SleepNapRecGameTimerID)
			endIf
		else
			StartTimerGameTime(nextTimerHours, SleepNapRecGameTimerID)
			if (FastSleepStatus == 1)
				FastSleepEffectOff()
				DTSleep_TimePassRestoreMsg.Show()
			endIf
		endIf
	
	elseIf (DTSleep_PlayerUsingBed.GetValue() <= 0.0)
		; apparently player left bed
		;SendRestInterruptEvent(0)
		;Debug.Trace("[DTSleep_HealthRec] player not using bed -- cancel now")
		StopAllCancel()
		
	elseIf (!GoodSleep && FastSleepStatus == 1)
		FastSleepEffectOff()
		if (DTSleep_SettingNotifications.GetValue() >= 1.0)
			DTSleep_TimePassRestoreMsg.Show()
		endIf
	endIf
	
endFunction

Function PlayerNapRecoverFatigue()

	int hourIncCount = CheckGameHourIncrement()	; always increment HourCount  - v2.16 changed from bool to int hour-increment
	
	if (DTSleep_PlayerUsingBed.GetValue() > 0.0 && DTSleep_SettingNapRecover.GetValue() > 0.0)
	
		if (GoodSleep && Game.GetDifficulty() >= 6)
			; fatigue sleep effect
			int sleepEffectVal = PlayerRef.GetValue(HC_SleepEffectAV) as int
			
			if (HourCount > 1)
				; skip first hour  - Min hours cure sleep effects = 2
				;Debug.Trace("[DTSleep_HealthRec] HC_SleepEffect: " + sleepEffectVal)
				
				int limit = 2
				if (hourIncCount > 0 && HourCount >= 5)
					limit = 1
				endIf
				
				if (sleepEffectVal > limit)				
					; decrement by hours to handle skip-time like "Sleep Together Anywhere" --v2.16
					sleepEffectVal -= hourIncCount
					if (sleepEffectVal < limit)
						sleepEffectVal = limit
					endIf
					PlayerRef.SetValue(HC_SleepEffectAV, sleepEffectVal as float)
				endIf
			endIf
			
			; adrenaline - recover 10 per hour (HC_Manager is 10 to 50 for 1-7 hours)
			; 1 perk rank = 5 adrenaline
			
			int curVal = (PlayerRef.GetValue(HC_AdrenalineAV) as int)
			;Debug.Trace("[DTSleep_HealthRec] HC_Adrenaline: " + curVal)
			
			if (curVal > 0)
				int rank = 0
				int remVal = 10
				int divVal = 5
				if (hourIncCount > 1)
					remVal = hourIncCount * 10
					divVal = 5 * hourIncCount
				endIf
				int val = curVal - remVal
				if (val < 0)
					val = 0
				else
					rank = val / divVal
				endIf
				
				PlayerRef.SetValue(HC_AdrenalineAV, val as float)
				
				PlayerRef.RemovePerk(HC_AdrenalinePerk)	; removes all ranks
				;Debug.Trace("[DTSleep_HealthRec] re-adding adrenaline perks: " + rank)
				
				while (rank > 0)
					PlayerRef.AddPerk(HC_AdrenalinePerk)
					rank -= 1
				endWhile
			endIf
			
			if (HourCount > 1 && PlayerRef.HasMagicEffect(HC_Disease_Insomnia_Effect))
				; chance to stop recovering - 25%
				if (Utility.RandomInt(1, 59) >= 44)
					
					DTSleep_InsomniaWarnMsg.Show()
					GoodSleep = false
					if (DTSleep_SettingTestMode.GetValueInt() > 0 && DTSleep_DebugMode.GetValue() >= 2.0)
						Debug.Trace("[DTSleep_HealthRec] Insomnia warn at hour count: " + HourCount)
					endIf
				endIf
			endIf
			
			if (HourCount >= 5 && DTSleep_SettingNapOnly.GetValue() > 0.0 && sleepEffectVal <= 1)
				
				
				if (BedType == SleepBedOwnID)
					if (HourCount >= 7)
						SendRestInterruptEvent(0)
					endIf
				elseIf (BedType == SleepBedFullID)
					if (HourCount >= 6)
						SendRestInterruptEvent(0)
					endIf
				else 
					SendRestInterruptEvent(0)
				endIf
			endIf
			
		elseIf (!GoodSleep)
		
			if (HourCount >= PoorSleepHourLimit)
				SendRestInterruptEvent(2)
			endIf
		elseIf (HourCount >= HoursOversleep)
		
			SendRestInterruptEvent(0)
		endIf
		
	endIf	; end if using bed and nap-recover
	
	; keep counting hours
	StartTimerGameTime(1.0, SleepNapFatGameTimerID)

endFunction

; call at end of sleep
;
bool Function PlayerDiseaseCheckBed(int bedStyle, int hourSleep)
	
	if (Game.GetDifficulty() == 6 && HC_Rule_DiseaseEffects.GetValue() == 1.0 && hourSleep >= 1 && DTSleep_SettingNapOnly.GetValue() > 0.0)
	
		int diseaseType = 0
		int chanceDisease = 45	; 10% chance
		
		if (PlayerRef.HasMagicEffect(HC_Herbal_Antimicrobial_Effect))
			chanceDisease = 49	; 2% chance
		endIf
		
		if (hourSleep >= 3 && hourSleep <= HoursOversleep)
			; check infection
			diseaseType = 1
			
			if (bedStyle == SleepBedNoneID)
				chanceDisease += 1
			elseIf (bedStyle == SleepBedOwnID)
				chanceDisease += 3
			elseIf (bedStyle == SleepBedCampingID)
				chanceDisease -= 1
			elseIf (bedStyle == SleepBedGroundMattressID)
				chanceDisease -= 3
			elseIf (bedStyle == SleepBedSleepBagID)
				chanceDisease -= 4
			endIf
			
			if (hourSleep < 5)
				chanceDisease -= (6 - hourSleep)
			endIf
			
		elseIf (bedStyle != SleepBedNoneID)
		
			diseaseType = Utility.RandomInt(1,2)	;  infection or lethargy
			chanceDisease -= 1
			
			if (bedStyle == SleepBedGroundMattressID)
				chanceDisease -= 4
			elseIf (bedStyle == SleepBedSleepBagID)
				chanceDisease -= 5
			elseIf (bedStyle == SleepBedOwnID)
				chanceDisease += 2
			elseIf (bedStyle == SleepBedCampingID)
				chanceDisease -= 2
			endIf
			if (HourCount > HoursOversleep)
				chanceDisease -= (2 * (HourCount - HoursOversleep))
			endIf
		endIf
		
		int randRoll = Utility.RandomInt(0, 49)
		if (randRoll >= chanceDisease)
			Utility.Wait(0.2)
			
			if (diseaseType == 1)
				(DT_PotionHandleQuestP as DT_PotionHandleQuestScript).TryEquipPotion_Global(HC_DiseaseEffect_Infection)
				
				return true
				
			elseIf (diseaseType == 2)
				int sleepEffectVal = PlayerRef.GetValue(HC_SleepEffectAV) as int
				if (sleepEffectVal < 2)
					PlayerRef.SetValue(HC_SleepEffectAV, 2.0)
				endIf
				(DT_PotionHandleQuestP as DT_PotionHandleQuestScript).TryEquipPotion_Global(HC_DiseaseEffect_Lethargy)
				
				return true
			endIf
		endIf
	endIf
	
	return false
endFunction

; only call if no disease
; level 2 = full recover
; level 1 = partial recover
; level 0 = exited bed early
Function PlayerNapRecoverFinal(int recoverLevel)

	if (DTSleep_SettingTestMode.GetValueInt() > 0 && DTSleep_DebugMode.GetValue() >= 1.0)
		Debug.Trace("[DTSleep_HealthRec] RecoverFinal full? " + recoverLevel + " for HourCount " + HourCount + " with GoodSleep? " + GoodSleep)
	endIf
	
	if (GoodSleep && Game.GetDifficulty() >= 6 && DTSleep_SettingNapRecover.GetValue() > 0.0)
	
		; sleep effect 
		int sleepEffectVal = PlayerRef.GetValue(HC_SleepEffectAV) as int
		if (sleepEffectVal <= 1)
			SleepyPlayer = false
			
			if (recoverLevel >= 2)
				
				
				if (DTSleep_SettingNapOnly.GetValue() > 0.0)
					; HC-Deprivation timer default takes 2 cycles of 14.0 hours to become tired (SleepEffect-2),
					; for 8-hour sleep set to 2 (2 + 14 = 16)
					float hoursSlept = HourCount as float
					if (hoursSlept > 7.5)
						hoursSlept = 7.5
					endIf
					
					float sleepTimer = -5.5 + hoursSlept
					
					if (sleepTimer < 0.5)
						PlayerRef.SetValue(HC_SleepEffectAV, 1.0)
						sleepTimer += 8.50
					else
						PlayerRef.SetValue(HC_SleepEffectAV, 0.0)			; full fatigue recovery 
					endIf
					SetHCSleepTimer(sleepTimer, SleepInterrupted)
				endIf
				
			elseIf (recoverLevel == 1)
				
				if (DTSleep_SettingNapOnly.GetValue() > 0.0)
					float sleepTimer = 2.5 + HourCount as float
					if (sleepTimer > 8.5)
						sleepTimer = 8.5
					endIf
					SetHCSleepTimer(sleepTimer, SleepInterrupted)
				endIf
				
			elseIf (HourCount >= 2 && DTSleep_SettingNapOnly.GetValue() > 0.0)
				float sleepTimer = -1.5 + HourCount as float
				if (HourCount >= 5)
					sleepTimer = 1.5 + HourCount as float
				endIf
				if (sleepTimer > 5.5)
					sleepTimer = 5.5
				endIf
				SetHCSleepTimer(sleepTimer, SleepInterrupted)
			endIf
		elseIf (HourCount >= 3)
			SleepyPlayer = true
			; allow some time before next drop
			float sleepTimer = 2.5 + HourCount as float
			SetHCSleepTimer(sleepTimer, SleepInterrupted)
		endIf
		
			
	elseIf (Game.GetDifficulty() < 6)
		SleepyPlayer = false
	endIf
	
	if (BedType == SleepBedOwnID && HourCount >= 7 && recoverLevel >= 2 && GoodSleep && !SleepyPlayer && !SleepInterrupted)
		PlayerWellRested = true
		
		PlayerWellRestedTime = Utility.GetCurrentGameTime()
	endIf
	
	SendRestCompleteEvent(0)
	
endFunction

Function RestoreValueByFraction(ActorValue actorValToRestore, float fractionVal, float maxVal)

	float valRestore = fractionVal * maxVal
	PlayerRef.RestoreValue(actorValToRestore, valRestore)
endFunction

Function SendRestCompleteEvent(int interruptType)

	if (DTSleep_SettingNapOnly.GetValue() >= 1.0)
		Var[] kArgs = new Var[6]
		kArgs[0] = interruptType
		kArgs[1] = HourCount
		kArgs[2] = IsDone
		kArgs[3] = GoodSleep
		kArgs[4] = BedType
		kArgs[5] = DTSleep_SettingNapRecover.GetValueInt()

		SendCustomEvent("RestCompleteEvent", kArgs)
	endIf
endFunction

Function SendRestInterruptEvent(int interruptType)

	Var[] kArgs = new Var[2]
	kArgs[0] = interruptType
	kArgs[1] = HourCount

	
	SendCustomEvent("RestInterruptionEvent", kArgs)
endFunction

Function SendRestStartedEvent()

	if (DTSleep_SettingNapOnly.GetValue() >= 1.0)
		Var[] kArgs = new Var[2]
		kArgs[0] = HourCount
		kArgs[1] = SleepInterrupted
		
		SendCustomEvent("RestStartedEvent", kArgs)
	endIf
endFunction

Function SetHCSleepTimer(float sleepTimer, bool interrupted = false)

	if (sleepTimer >= 0.25)
		if (interrupted && sleepTimer >= 3.0)
			sleepTimer -= 2.0
		endIf
		(HC_Manager as Hardcore:HC_ManagerScript).StartSleepDeprivationTimer(sleepTimer, true)
	endIf
endFunction