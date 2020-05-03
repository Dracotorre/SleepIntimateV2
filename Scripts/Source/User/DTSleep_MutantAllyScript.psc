Scriptname DTSleep_MutantAllyScript extends ActiveMagicEffect


; ******************
; DTSleep_SpectatorQuestScript for SleepIntimate
; by DracoTorre
; www.dracotorre.com/mods/sleepintimate/
; https://github.com/Dracotorre/SleepIntimateV2
;
; added v2.35
;------------

perk property blackwidow02 auto const
Faction property SuperMutantFaction auto const
Faction property DTSleep_MutantAllyFaction auto const
Message property DTSleep_MutantAllyEndMessage auto const
Message property DTSleep_MutantAllyStartMessage auto const
GlobalVariable property DTSleep_SettingNotifications auto const
GlobalVariable property DTSleep_IntimateStrongEXP auto const
GlobalVariable property DTSleep_SettingTestMode auto const
GlobalVariable property DTSleep_DebugMode auto const

Event OnEffectStart(actor akTarget, actor akCaster)

	Actor playerRef = Game.GetPlayer()
	int chanceToBeat = 10
	int exp = DTSleep_IntimateStrongEXP.GetValueInt()
	
	if (exp >= 90)
		chanceToBeat += 32
	elseIf (exp >= 3)
		chanceToBeat += (exp / 3)
	endIf
	if (playerRef.HasPerk(blackwidow02))
		chanceToBeat += 8
	endIf
	if (DTSleep_SettingTestMode.GetValueInt() >= 1 && DTSleep_DebugMode.GetValueInt() >= 3)
		chanceToBeat = 100
	endIf
	
	if (akTarget == playerRef && Utility.RandomInt(1, 100) <= chanceToBeat)
		DTSleep_MutantAllyFaction.SetAlly(SuperMutantFaction)
		akTarget.AddToFaction(DTSleep_MutantAllyFaction)
		
		if (DTSleep_MutantAllyStartMessage != None && DTSleep_SettingNotifications != None)
			if (DTSleep_SettingNotifications.GetValueInt() >= 1)
				DTSleep_MutantAllyStartMessage.Show()
			endIf
		endIf
	else
		self.Dispel()
	endIf
EndEvent

Event OnEffectFinish(actor akTarget, actor akCaster)

	if (akTarget.IsInFaction(DTSleep_MutantAllyFaction))
		akTarget.RemoveFromFaction(DTSleep_MutantAllyFaction)

		if (DTSleep_MutantAllyEndMessage != None && DTSleep_SettingNotifications != None)
			if (DTSleep_SettingNotifications.GetValueInt() >= 1)
				DTSleep_MutantAllyEndMessage.Show()
			endIf
		endIf
	endIf
EndEvent

