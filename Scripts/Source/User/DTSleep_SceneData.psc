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
{ true if fem/fem with toy in one inventory}
bool property HasToyEquipped = false auto conditional hidden
{ ie: set true if MaleRole is female with toy equipped }
bool property ToyFromContainer = false auto conditional hidden
bool property SameGender = false auto conditional hidden
int property AnimationSet = 0 auto conditional hidden
{ 0 for normal, 1 = Leito, 2 = CrazyGun, >5 = AAF scenes}
int property Interrupted = 0 auto conditional hidden
{ 10 and 50 reserved for AAF issues, 1 for default, 2 for canceled by NPC, 7 for player cancel using pipboy, 4 is combat }
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
{ reserved for Danse in Power Armor }
int property PlayerRoleTranslated = 0 auto conditional hidden
int property MaleBodySwapEnabled = 1 auto conditional hidden
int property RaceRestricted = 0 auto conditional hidden						; v2.60 embrace only
;
; additional scene info v2.35
;
int property IntimateLocationType = 0 auto conditional hidden
;
; more info v2.48
int property IntimateSceneIsDanceHug = 0 auto conditional hidden ; 0=no, 1 = sexy dance, 2 = normal dance, 3 = hug

; additional scene info for v2.70
;
; 0 = unknown, 1 = clone-forced, 2 = never-clone, 3 = cloned, 4 = not-cloned, 5 = cloned-by-pref, 6 = not-cloned-by-pref, 10 = AAF 
int property IntimateSceneViewType = 0 auto conditional hidden

int property SceneIsTest = 0 auto conditional hidden		; player using test-mode for free scene  v3.15


; -------------------------- backup data if need to restore after reset ---------

Actor property BackupMaleRole auto conditional hidden
int property BackupMaleRoleGender = -1 auto conditional hidden
Actor property BackupFemaleRole auto conditional hidden
bool property BackupSameGender = false auto conditional hidden
int property BackupCurrentLoverScenCount = 0 auto conditional hidden
