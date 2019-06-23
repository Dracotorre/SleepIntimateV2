Scriptname DTSleep_IntimateTourQuestScript extends Quest

DTSleep_Conditionals property DTSConditionals auto
GlobalVariable property DTSleep_IntimateLocCount auto
GlobalVariable property DTSleep_IntimateLocCountThreshold auto
GlobalVariable property DTSleep_SettingIntimate auto const
GlobalVariable property DTSleep_SettingTourEnabled auto const
FormList property DTSleep_IntimateTourLocList auto const



Event OnQuestInit()
	 
	self.SetStage(5)
	
EndEvent

; ***************************************
;  Functions

;  public - after intimacy call this to confirm location on tour
;  returns positive if marked, 0 for not location of interest, or negative error
;
int Function CheckLocation(Location aLoc)

	if (DTSleep_SettingTourEnabled.GetValue() <= 0.0)
		;if (self.IsObjectiveDisplayed(1000))  ; not necessary
		;	UpdateLocationObjectiveDisplay()
		;endIf
		return -4
	endIf
	
	;Debug.Trace("[DTSleep_IntimateTour] check location...")
	
	if (aLoc == None)
		return -3
	elseIf (self.GetStageDone(1000))
		return -2
	endIf
	
	
	if (!self.IsObjectiveDisplayed(1000))
		UpdateLocationObjectiveDisplay()
		Utility.Wait(3.0)

	endIf
	
	int index = DTSleep_IntimateTourLocList.Find(aLoc as Form)
	
	if (index >= 0)
		
		if (index < 13)
			int stageNum = ((index + 1) * 10)
			
			if (!self.GetStageDone(stageNum))

				self.SetStage(stageNum)
				return UpdateLocationCount()
			elseIf (!self.IsObjectiveCompleted(stageNum))
				self.SetObjectiveCompleted(stageNum)
			endIf
		elseIf (DTSConditionals.LocTourFHAcadiaIndex == index)
			if (!self.GetStageDone(200))
				self.SetStage(200)
				return UpdateLocationCount()
			elseIf (!self.IsObjectiveCompleted(200))
				self.SetObjectiveCompleted(200)
			endIf
		elseIf (DTSConditionals.LocTourFHGHotelIndex == index)
			if (!self.GetStageDone(210))
				self.SetStage(210)
				return UpdateLocationCount()
			elseIf (!self.IsObjectiveCompleted(210))
				self.SetObjectiveCompleted(210)
			endIf
		elseIf (DTSConditionals.LocTourNWTownIndex == index)
			if (!self.GetStageDone(300))
				self.SetStage(300)
				return UpdateLocationCount()
			elseIf (!self.IsObjectiveCompleted(300))
				self.SetObjectiveCompleted(300)
			endIf
		elseIf (DTSConditionals.LocTourNWMansionIndex == index)
			if (!self.GetStageDone(310))
				self.SetStage(310)
				return UpdateLocationCount()
			elseIf (!self.IsObjectiveCompleted(310))
				self.SetObjectiveCompleted(310)
			endIf
			
		endIf
		
		return UpdateLocationCount()
	
	endIf
	
	;if (!self.IsObjectiveDisplayed(1000))
	;	;Debug.Trace("[DTSleep_IntimateTour] not displayed - update now: ")
	;	UpdateLocationObjectiveDisplay()
	;endIf
	
	return 0
endFunction


int Function UpdateLocationCount(bool reMark = false)
	
	;int locCount = 1 + DTSleep_IntimateLocCount.GetValueInt()
	;DTSleep_IntimateLocCount.SetValueInt(locCount)
	int objCount = 0
	int count = 1
	
	if (reMark && DTSleep_SettingTourEnabled.GetValue() <= 0.0 || DTSleep_SettingIntimate.GetValue() <= 0.0)
		reMark = false
	endIf
	
	Utility.Wait(0.1)
	
	while (count <= 13)
		int objID = count * 10

		if (self.IsObjectiveCompleted(objID))
			objCount += 1

		elseIf (self.GetStageDone(objID))
			objCount += 1

			if (reMark)
				self.SetObjectiveCompleted(objID)
			endIf
		endIf
		
		count += 1
	endWhile
	
	if (self.IsObjectiveCompleted(200))
		objCount += 1
	elseIf (self.GetStageDone(200))
		objCount += 1
		if (reMark)
			self.SetObjectiveCompleted(200)
		endIf
	endIf
	if (self.IsObjectiveCompleted(210))
		objCount += 1

	elseIf (self.GetStageDone(210))
		objCount += 1
		if (reMark)
			self.SetObjectiveCompleted(210)
		endIf
	endIf
	if (self.IsObjectiveCompleted(300))
		objCount += 1
	elseIf (self.GetStageDone(300))
		objCount += 1
		if (reMark)
			self.SetObjectiveCompleted(300)
		endIf
	endIf
	if (self.IsObjectiveCompleted(310))
		objCount += 1
	elseIf (self.GetStageDone(310))
		objCount += 1
		if (reMark)
			self.SetObjectiveCompleted(310)
		endIf
	endIf
	
	DTSleep_IntimateLocCount.SetValueInt(objCount)
	
	
	if (objCount >= DTSleep_IntimateLocCountThreshold.GetValueInt())
		; quest completed
		self.SetStage(1000)
	endIf
	
	UpdateLocationObjectiveDisplay()

	return objCount
endFunction

Function UpdateLocationObjectiveDisplay()

	if (!self.IsRunning())
		return
	endIf

	UpdateCurrentInstanceGlobal(DTSleep_IntimateLocCount)
	UpdateCurrentInstanceGlobal(DTSleep_IntimateLocCountThreshold)

	bool enabled = true
	if (DTSleep_SettingTourEnabled.GetValue() <= 0.0 || DTSleep_SettingIntimate.GetValue() <= 0.0)
		enabled = false
	endIf
		
	if (DTSleep_IntimateLocCount.GetValueInt() < DTSleep_IntimateLocCountThreshold.GetValueInt())
	
		self.SetObjectiveDisplayed(10, enabled)
		self.SetObjectiveDisplayed(20, enabled)
		self.SetObjectiveDisplayed(30, enabled)
		self.SetObjectiveDisplayed(40, enabled)
		self.SetObjectiveDisplayed(50, enabled)
		self.SetObjectiveDisplayed(60, enabled)
		self.SetObjectiveDisplayed(70, enabled)
		self.SetObjectiveDisplayed(80, enabled)
		self.SetObjectiveDisplayed(90, enabled)
		self.SetObjectiveDisplayed(100, enabled)
		self.SetObjectiveDisplayed(110, enabled)
		self.SetObjectiveDisplayed(120, enabled)
		self.SetObjectiveDisplayed(130, enabled)
		
		if (DTSConditionals.IsCoastDLCActive && DTSConditionals.LocTourFHAcadiaIndex > 0)
			self.SetObjectiveDisplayed(200, enabled)
			self.SetObjectiveDisplayed(210, enabled)
		else
			self.SetObjectiveDisplayed(200, false)
			self.SetObjectiveDisplayed(210, false)
		endIf
		
		if (DTSConditionals.IsNukaWorldDLCActive)
			self.SetObjectiveDisplayed(300, enabled)
			self.SetObjectiveDisplayed(310, enabled)
		else
			self.SetObjectiveDisplayed(300, false)
			self.SetObjectiveDisplayed(310, false)
		endIf
		
	endIf
	
	;Debug.Trace("[DTSleep_IntimateTour] display objective count: " + DTSleep_IntimateLocCount.GetValueInt())

	self.SetObjectiveDisplayed(1000, enabled, true)
	;self.SetStage(500)

endFunction
