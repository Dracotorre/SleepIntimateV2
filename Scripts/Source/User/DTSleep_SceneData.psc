Scriptname DTSleep_SceneData extends Quest Conditional

; Scene Data for Sleep Intimate 
; DracoTorre
; 
; store data for repeat use and to pass to the MagicEffect

Actor property MaleRole auto conditional hidden
{ male/dominate }
int property MaleRoleGender = -1 auto conditional hidden
{ 0 (male) or 1 (female) real gender for re-use and toy type }
int property MaleRoleCompanionIndex = -1 auto conditional hidden
{ if need custom body - 0 = player, 1 = UniquePlayer, 2 = Danse, 3 = Gage, 4 = Garvey, 5 = MacCready}
Actor property FemaleRole auto conditional hidden
{ female for when it matters }
Actor property SecondFemaleRole auto conditional hidden
{ extra female participant - matching gender, please }
Actor property SecondMaleRole auto conditional hidden
{ extra male participant - proper gender, please }
Armor property ToyArmor auto conditional hidden
{ ie: strap-on when MaleRoleGender = 1 }
bool property HasToyAvailable = false auto conditional hidden
{true if fem/fem with toy in one inventory}
bool property HasToyEquipped = false auto conditional hidden
{ ie: set true if MaleRole is female with toy equipped }
bool property ToyFromContainer = false auto conditional hidden
bool property SameGender = false auto conditional hidden
int property AnimationSet = 0 auto conditional hidden
{ 0 for normal, 1 = Leito, 2 = CrazyGun, >5 = AAF scenes}
int property Interrupted = 0 auto conditional hidden
{ 10 and 50 reserved for AAF issues }
int property LkbwLevel = 0 auto conditional hidden
{ LadyKiller / BlackWidow perk level record and keep }
ObjectReference property MaleMarker = None auto conditional hidden
ObjectReference property FemaleMarker = None auto conditional hidden
int property MarkerOrientationAllowance = 5 auto conditional hidden
int property CurrentLoverScenCount = 0 auto conditional hidden
bool property IsUsingCreature = false auto conditional hidden
int property IsCreatureType = 0 auto conditional hidden
int property CompanionBribeType = 0 auto conditional hidden
bool property FemaleRaceHasTail = false auto conditional hidden
float property WaitSecs = 11.2 auto conditional hidden
bool property PreferStandOnly = false auto conditional hidden
bool property CompanionInPowerArmor = false auto conditional hidden
int property PlayerRoleTranslated = 0 auto conditional hidden

; -------------------------- backup data if need to restore after reset ---------

Actor property BackupMaleRole auto conditional hidden
int property BackupMaleRoleGender = -1 auto conditional hidden
Actor property BackupFemaleRole auto conditional hidden
bool property BackupSameGender = false auto conditional hidden
int property BackupCurrentLoverScenCount = 0 auto conditional hidden