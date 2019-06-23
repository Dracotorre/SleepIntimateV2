Scriptname DT_RandomQuestScript extends Quest

; *************************************
; script by DracoTorre
; included with Sleep Intimate
; https://www.dracotorre.com/mods/sleepintimate/
; https://github.com/Dracotorre/SleepIntimate
;
; random number generator
; replace Utility.RandomInt where improved pseudo-random generation desired with storage array helpful for shuffled packs
; uses basic Fischer-Yates shuffle
;
; permission: free to use with credit
;
; ****************

int property MySizedPackCount auto hidden
float property MyLastHundredShuffleTime auto hidden
float property MyLastSizedShuffleTime auto hidden
bool property MyShuffleHundredReady auto hidden
bool property MyShuffleSizedReady auto hidden
int property ShuffledHundredIndex auto hidden

; variables

int[] PShuffledHundredArray
int[] PShuffledSizedArray
int PShuffledSizedIndex
int PVIVal
int PStopShuffleIndex
bool PIShuffleRequest

int ShuffleTimerID = 101 const
int ValidateDataTimerID = 102 const
int ShuffleSizedTimerID = 103 const

; **************************
;   events

Event OnQuestInit()
    
	MySizedPackCount = 5
	InitPacks()
EndEvent

Event OnTimer(int aiTimerID)

	if (aiTimerID == ShuffleTimerID)
		ShuffleHundredPackPublic()
	elseIf (aiTimerID == ShuffleSizedTimerID)
		ShuffleSizedPackPublic()
		
	elseIf (aiTimerID == ValidateDataTimerID)
		ValidatePackData()
	endIf
EndEvent

; **************************
;   functions - public

int Function GetNextInRangePublic(int low, int high)
	if (high <= low)
		return low
	endIf
	int nextRand = GetNextHundredPackIntPublic()
	float fraction = (nextRand as float) * 0.01
	float rangeLen = (high - low) as float
	nextRand = ((rangeLen * fraction) + low) as int
	
	;Debug.Trace("[DT_RandomQuest] return next rand " + nextRand + " in range: " + low + "-" + high + " (" + rangeLen + ")")
	
	return nextRand
endFunction

int Function GetNextHundredPackIntPublic()
	
	int nextRand = -1
	int waitSec = 0
	if (!MyShuffleHundredReady)
		PStopShuffleIndex = 40
	elseIf (PStopShuffleIndex < 5)
		PStopShuffleIndex = 100
	endIf
	while (!MyShuffleHundredReady && waitSec < 100)
		Utility.WaitMenuMode(0.032)
		
		waitSec += 1
	endWhile
	
	if (!PIShuffleRequest && ShuffledHundredIndex >= (PShuffledHundredArray.Length - 10) || ShuffledHundredIndex >= (PStopShuffleIndex - 2))
		;Debug.Trace("[DT_RandomQuest] getNext time to re-shuffle atIndex: " + ShuffledHundredIndex)
		PIShuffleRequest = true
		StartTimer(2.0, ShuffleTimerID)
	endif
	
	nextRand = PShuffledHundredArray[ShuffledHundredIndex]
	;Debug.Trace("[DT_RandomQuest] return next Hundred rand: " + nextRand + " atIndex: " + ShuffledHundredIndex + " waitSec: " + waitSec)
	
	ShuffledHundredIndex += 1
	
	return nextRand
endFunction

int Function GetNextSizedPackIntPublic()
	int nextRand = -1
	
	int waitSec = 0
	while (!MyShuffleSizedReady && waitSec < 100)
		Utility.WaitMenuMode(0.032)
		waitSec += 1
	endWhile
	
	if (MySizedPackCount != PShuffledSizedArray.Length)
		InitFillSizedPack()
		ShuffleSizedPackPublic()
		
	elseIf (PShuffledSizedIndex >= PShuffledSizedArray.Length)
		ShuffleSizedPackPublic()
	endIf
	
	nextRand = PShuffledSizedArray[PShuffledSizedIndex]
	;Debug.Trace("[DT_RandomQuest] return next Sized rand: " + nextRand + " atIndex: " + PShuffledSizedIndex + " waitSec: " + waitSec)
	
	PShuffledSizedIndex += 1
	
	return nextRand
endFunction

int Function ShuffleOnTimerPublic(float seconds)
	
	if (seconds < 0.20)
		seconds = 0.20
	elseIf (seconds > 300.0)
		seconds = 300.0
	endIf
	
	StartTimer(seconds, ShuffleTimerID)
	StartTimer(seconds + 0.24, ShuffleSizedTimerID)
	
	return 1
endFunction

int Function ShuffleHundredPackPublic()
	
	PStopShuffleIndex = 100
	MyShuffleHundredReady = false
	;Debug.Trace("[DT_RandomQuest] Shuffle Hundred pack")
	ShuffledHundredIndex = 0
	ShuffleIntArray(PShuffledHundredArray)
	MyLastHundredShuffleTime = Utility.GetCurrentGameTime()
	PVIVal = PShuffledHundredArray[0]
	MyShuffleHundredReady = true
	PIShuffleRequest = false
	
	return 1
endFunction


int Function ShuffleSizedPackPublic()
	MyShuffleSizedReady = false
	if (MySizedPackCount != PShuffledSizedArray.Length)
		InitFillSizedPack()
	endIf
	;Debug.Trace("[DT_RandomQuest] Shuffle Sized pack " + MySizedPackCount)
		
	PShuffledSizedIndex = 0
	ShuffleIntArray(PShuffledSizedArray)

	MyLastSizedShuffleTime = Utility.GetCurrentGameTime()
	MyShuffleSizedReady = true
	
	return 1
endFunction

int Function ValidatePublic()
	StartTimer(0.25, ValidateDataTimerID)
	
	return ShuffledHundredIndex
endFunction

; **************************
;   functions intended private

Function FillArrays()
	
	PShuffledHundredArray = new int[100]
	InitSizedArray()
	;Debug.Trace("[DT_RandomQuest] FillArrays init sizes: " + PShuffledHundredArray.Length + " / " + PShuffledSizedArray.Length)
	int i = 0
	int longLength = 100
	if (MySizedPackCount > 100)
		longLength = MySizedPackCount
	endIf
	
	while (i < longLength)
	
		if (i < PShuffledHundredArray.Length)
			PShuffledHundredArray[i] = i + 1
		endIf
		if (i < PShuffledSizedArray.Length)
			PShuffledSizedArray[i] = i + 1
		endIf
		
		i += 1
	endWhile
endFunction

Function InitPacks()
	MyShuffleHundredReady = false
	MyShuffleSizedReady = false
	PStopShuffleIndex = 100
	FillArrays()
	ShuffleSizedPackPublic()
	ShuffleHundredPackPublic()
	
	Utility.WaitMenuMode(0.12)
	ShuffleHundredPackPublic()
endFunction

Function InitFillSizedPack()
	MyShuffleSizedReady = false
	InitSizedArray()
	int i = 0
	while (i < PShuffledSizedArray.Length)
	
		PShuffledSizedArray[i] = i + 1

		i += 1
	endWhile
endFunction

Function InitSizedArray()
	if (MySizedPackCount <= 4)
		MySizedPackCount = 5
	elseIF (MySizedPackCount > 54)
		MySizedPackCount = 54
	endIf
	PShuffledSizedArray = new int[MySizedPackCount]
endFunction

int Function ShuffleIntArray(int[] anArray)
	if (anArray == None || anArray.Length < 4)
		Debug.Trace("[DT_RandomQuest] ShuffleIntArray - no array!!!")
		return -1
	endIf
	int i = 0
	int len = anArray.Length - 2
	int j = 1
	
	while (i < len && i < PStopShuffleIndex)
		if (i == 2 || i == 8)
			Utility.WaitMenuMode((Utility.RandomInt(2, 9) as float) * 0.1)
		endIf
		j = Utility.RandomInt(i, anArray.Length - 1)
		if (j != i)
			int swapInt = anArray[i]
			anArray[i] = anArray[j]
			anArray[j] = swapInt
		endIf
		
		i += 1
	endWhile
	
	return 1
endFunction

Function ValidatePackData()

	if (PShuffledHundredArray == None || PShuffledHundredArray.Length != 100)
		InitPacks()
	elseIf (PVIVal != PShuffledHundredArray[0])
		Debug.Trace("[DT_RandomQuest] Validation: bad data found - reset!!!")
		InitPacks()
	else
		bool packValid = true
		int i = 1
		while (packValid && i < 17)
			if (PShuffledHundredArray[i] > 100)
				packValid = false
				
			elseIf (PShuffledHundredArray[i] == PShuffledHundredArray[0])
				packValid = false
			endIf
			i += 1
		endWhile
		
		if (!packValid)
			Debug.Trace("[DT_RandomQuest] Validation: pack bad - reset!!!")
			InitPacks()
		endIf
	endIf
endFunction