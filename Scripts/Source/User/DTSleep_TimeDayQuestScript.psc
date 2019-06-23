Scriptname DTSleep_TimeDayQuestScript extends Quest

; regular time notification showing day-of-week and game time
;
; by DracoTorre
; www.dracotorre.com/mods/sleepintimate/

DTSleep_Conditionals property DTSConditionals auto

GlobalVariable property GameYear auto const
GlobalVariable property GameMonth auto const
GlobalVariable property GameDay auto const
GlobalVariable property DTSleep_SettingNotifications auto const
GlobalVariable property DTSleep_SettingShowHourly auto const

Message property DTSleep_TimeSundayMsg auto const
Message property DTSleep_TimeMondayMsg auto const
Message property DTSleep_TimeTuesdayMsg auto const
Message property DTSleep_TimeWednesdayMsg auto const
Message property DTSleep_TimeThursdayMsg auto const
Message property DTSleep_TimeFridayMsg auto const
Message property DTSleep_TimeSaturdayMsg auto const

float property NoticeIntervalHours = 1.0 auto hidden
bool property HourlyNoticeEnabled = true auto hidden	; use to temporarily hide
int property CurrentGameDay auto hidden
int property CurrentGameMonth auto hidden
int property CurrentDOW auto hidden

int HourlyNoticeTimerID = 107 const


Event OnQuestInit()
	CurrentGameDay = -1
	CurrentDOW = -1
	NoticeIntervalHours = 0.998
	
	StartTimerGameTime(0.950, HourlyNoticeTimerID) ; first timer a bit shorter to bring ahead of other hourly events
EndEvent

Event OnTimerGameTime(int aiTimerID)

	if (aiTimerID == HourlyNoticeTimerID)
		ShowHourlyNotice()
	endIf
EndEvent

Function StopAll()
	CancelTimerGameTime(HourlyNoticeTimerID)
	
	self.Stop()
endFunction


Function ShowHourlyNotice()

	if (DTSleep_SettingNotifications.GetValue() > 0.0 && DTSleep_SettingShowHourly.GetValue())
	
		if (HourlyNoticeEnabled)
	
			float gameTime = Utility.GetCurrentGameTime()
			float hour = DTSleep_CommonF.GetGameTimeCurrentHourOfDayFromCurrentTime(gameTime)
			float mins = hour
			mins -= Math.Floor(hour)
			mins = Math.Floor(mins * 60.0)   ; prevent Message from rounding up
			hour = Math.Floor(hour)			 ; ditto
			
			int dow = CurrentDOW
			
			if (dow < 0 || dow > 6 || CurrentGameDay != GameDay.GetValueInt() || CurrentGameMonth != GameMonth.GetValueInt())
				dow = DayOfWeek()
				
				CurrentDOW = dow
				CurrentGameDay = GameDay.GetValueInt()
				CurrentGameMonth = GameMonth.GetValueInt()
			endIf
			
			if (dow == 0)
				DTSleep_TimeSundayMsg.Show(hour, mins)
			elseIf (dow == 1)
				DTSleep_TimeMondayMsg.Show(hour, mins)
			elseIf (dow == 2)
				DTSleep_TimeTuesdayMsg.Show(hour, mins)
			elseIf (dow == 3)
				DTSleep_TimeWednesdayMsg.Show(hour, mins)
			elseIf (dow == 4)
				DTSleep_TimeThursdayMsg.Show(hour, mins)
			elseIf (dow == 5)
				DTSleep_TimeFridayMsg.Show(hour, mins)
			elseIf (dow == 6)
				DTSleep_TimeSaturdayMsg.Show(hour, mins)
			endIf
		endIf
	
		StartTimerGameTime(NoticeIntervalHours, HourlyNoticeTimerID)
	endIf
	
endFunction

; 0 = Sunday ... 6 = Saturday
; year expected as 3 digits from GameYear
;
int Function DayOfWeek()

	; Zeller's Rule
	; f = k + [(13*m-1)/5] + D + [D/4] + [C/4] - 2*C.
	
	int k = GameDay.GetValueInt()
	int m = GameMonth.GetValueInt() - 2  ; march = 1 for convenience after leap-year
	
	int C = 22  ; first 2 digits of year
	int D = GameYear.GetValueInt() ; 3 digits 
	D -= 200 ; last 2 digits
	
	if (m <= 0)
		m += 12
		D -= 1
	endIf
	
	
	int f = k + ((13 * m - 1) / 5) as int + D + (D / 4) as int + (C / 4) as int - 2 * C
	
	int div7 = f / 7
	int remainder = f - (7 * div7)
	if (remainder < 0)
		remainder += 7
	endIf
	
	return remainder 
endFunction

int Function GetHolidayVal()
	int result = 0
	
	int month = GameMonth.GetValueInt()
	int day = GameDay.GetValueInt()
	
	if (month == 1 && day == 1)
		result = 1
	elseIf (month == 2 && day == 14)
		result = 2
	elseIf (month == 3 && day == 17)
		result = 3
	elseIf (month == 5 && day == 1)
		; Nuka-World opening
		result = 4
	elseIf (month == 6 && day == 25)
		; RobCo day
		result = 5
	elseIf (month == 7 && day == 4)
		result = 6
	elseIf (month == 10)
		if (day == 23)
			result = 7
		elseIf (day == 31)
			result = 8
		endIf
	elseIf (month == 11 && day == 3)
		; Mr Pebbles Day
		result = 9
	elseIf (month == 12)
		if (day == 16)
			result = 10
		elseIf (day == 24)
			result = 11
		elseIf (day == 25)
			result = 12
		elseIf (day == 31)
			result = 13
		endIf
	endIf
		
	return result
endFunction
