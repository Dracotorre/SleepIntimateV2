Scriptname DTSleep_DogTrainQuestScript extends Quest

GlobalVariable property DTSleep_IntimateDogExp auto const

Event OnQuestInit()
	 
	self.SetStage(10)
	
EndEvent

Function UpdateTrainingCount()
	
	UpdateCurrentInstanceGlobal(DTSleep_IntimateDogExp)
	self.SetObjectiveDisplayed(10, true, true)
	
	if (DTSleep_IntimateDogExp.GetValueInt() >= 32)
		self.SetStage(50)
	endIf
	
endFunction