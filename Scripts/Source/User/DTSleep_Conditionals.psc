ScriptName DTSleep_Conditionals extends Quest conditional

; game settings
bool property HasGamesetReducedConv = false auto conditional hidden
bool property ImaPCMod = false auto conditional hidden
bool property HasReloaded = false auto conditional hidden
bool property IsF4SE = false auto conditional hidden
int property LoverRingEquipCount = 0 auto conditional hidden

; DLC
bool Property IsNukaWorldDLCActive = false auto conditional hidden
bool Property IsRobotDLCActive = false auto conditional hidden
bool Property IsCoastDLCActive = false auto conditional hidden
bool property IsWorkShop02DLCActive = false auto conditional hidden
bool property IsWorkShop03DLCActive = false auto conditional hidden
Keyword property DLC05ArmorRackKY = None auto conditional hidden
Keyword property DLC05PilloryKY = None auto conditional hidden
Keyword property WeightBenchKY = None auto conditional hidden
Actor property NukaWorldDLCGageRef = None auto conditional hidden
Actor property FarHarborDLCLongfellowRef = None auto conditional hidden
Perk property FarHarborDLCLongfellowPerk = None auto conditional hidden
Quest property FarHarborBedRentQuest = None auto conditional hidden
Location property FarHarborLastPlankLocation = None auto conditional hidden
Quest property RobotMQ105Quest = None auto conditional hidden
Actor property RobotAdaRef = None auto conditional hidden

; mod compatibility 
bool property HasModReqNormSleep = false auto conditional hidden
Actor property NoraSpouseRef = None auto conditional hidden
Actor property NoraSpouse2Ref = None auto conditional hidden
Actor property DualSurvivorsNateRef = None auto conditional hidden
Actor property InsaneIvyRef = None auto conditional hidden
Location property DepravityHotelRexLoc = None auto conditional hidden
bool property IsSMMActive = false auto conditional hidden
bool property IsAWKCRActive = false auto conditional hidden
bool property IsAFTActive = false auto conditional hidden
bool property IsAPCTransportFound = false auto conditional hidden
Keyword property AWKCRPackKW = None auto conditional hidden
Keyword property AWKCRSatchelKW = None auto conditional hidden
Keyword property AWKCRBandolKW = None auto conditional hidden
Keyword property AWKCRPiercingKW = None auto conditional hidden
Keyword property AWKCRCloakKW = None auto conditional hidden
Keyword property AWKCRJacketKW = None auto conditional hidden
Keyword property ZaZPilloryKW = None auto conditional hidden
Keyword property TortureDPilloryKW = None auto conditional hidden
Perk property ModSoSPerk = None auto conditional hidden
int property ITPCCactiveLevel = -1 auto conditional hidden
bool property IsAAFActive = false auto conditional hidden
bool property IsCWSSActive = false auto conditional hidden
bool property IsLooksMenuActive = false auto conditional hidden
bool property IsEFFActive = false auto conditional hidden
int property IsHZSHomebuilderActive = 0 auto conditional hidden
bool property IsAtomicLustActive = false auto conditional hidden
float property AtomicLustVers = 0.0 auto conditional hidden
bool property IsBP70Active = false auto conditional hidden
bool property IsMutatedLustActive = false auto conditional hidden
bool property IsRufgtActive = false auto conditional hidden
bool property IsHoloboyActive = false auto conditional hidden
bool property IsGrayAnimsActive = false auto conditional hidden
bool property IsGrayCreatureActive = false auto conditional hidden
bool property IsLocksmithActive = false auto conditional hidden
bool property IsSavageCabbageActive = false auto conditional hidden
float property SavageCabbageVers = 0.0 auto conditional hidden
bool property IsConquestActive = false auto conditional hidden
Keyword property ConquestWorkshopKW = None auto conditional hidden
bool property IsCrossBosUniActive = false auto conditional hidden
bool Property IsHeatherCompanionActive = false auto conditional hidden
bool property IsHeatherCompInLove = false auto conditional hidden
bool property IsNWSBarbActive = false auto conditional hidden
Perk property ModCompNWSBarbRewardPerk = None auto conditional hidden
bool Property IsSmokableCigarsActive = false auto conditional hidden
bool Property IsDXAtomGirlActive = false auto conditional hidden
int property DXAtomGirlNukaBearIndex = -1 auto conditional hidden
bool property IsDXBlackWidowActive = false auto conditional hidden
bool property IsDXVaultOutfitActive = false auto conditional hidden				; added v2.70
bool Property IsLacyUnderwearActive = false auto conditional hidden
bool Property IsRangerGearActive = false auto conditional hidden
;bool Property IsDXOverbossActive = false auto conditional hidden
;bool Property IsEfrasShoulderBagActive = false auto conditional hidden
bool Property IsProvisionerBackPackActive = false auto conditional hidden
bool Property IsVioStrapOnActive = false auto conditional hidden
bool property IsLeitoActive = false auto conditional hidden
bool property IsLeitoAAFActive = false auto conditional hidden
bool property IsCrazyAnimGunActive = false auto conditional hidden
bool property IsCrazyAnimRugsActive = false auto conditional hidden
bool property IsCampsiteActive = false auto conditional hidden
bool property IsBasementLivingActive = false auto conditional hidden
bool property IsLetsDanceActive = false auto conditional hidden
bool property IsFusionCityActive = false auto conditional hidden
bool property IsPlayerCommentsActive = false auto conditional hidden
bool property IsMorningSexActive = false auto conditional hidden
bool property IsSnapBedsActive = false auto conditional hidden
bool property IsScavversBackPackActive = false auto conditional hidden
bool property IsUPFPlayerActive = false auto conditional hidden					; v2.60
int property HasGenderSwappedPerks = -1 auto conditional hidden
GlobalVariable property ModPlayerCommentsGlobDisabled = None auto conditional hidden
GlobalVariable property ModPlayerCommentsGlobMisc = None auto conditional hidden
Quest property ModPlayerCommentsQuest = None auto conditional hidden
bool property ModPlayerCommentsDisabled = false auto conditional hidden
bool property ModPlayerCommentWarnShown = false auto conditional hidden
Keyword property ModPersonalGuardCtlKY = None auto conditional hidden
bool property IsUniqueFollowerFemActive = false auto conditional hidden
bool property IsUniqueFollowerMaleActive = false auto conditional hidden
bool property IsUniquePlayerMaleActive = false auto conditional hidden
Race property IsVulpineRace = None auto conditional hidden
Race property PlayerRace = None auto conditional hidden
Race property NanaRace = None auto conditional hidden								; v2.60
Race property NanaRace2 = None auto conditional hidden								; v2.60
bool property IsVulpineRacePlayerActive = false auto conditional hidden
int property PipPadListIndex = 0 auto conditional hidden
int property PipPadSlotIndex = 0 auto conditional hidden
int property LocTourFHAcadiaIndex = -1 auto conditional hidden
int property LocTourFHGHotelIndex = -1 auto conditional hidden
int property LocTourNWTownIndex = -1 auto conditional hidden
int property LocTourNWMansionIndex = -1 auto conditional hidden
int property LocTourStat = -1 auto conditional hidden

; special object handling   v2.70
ObjectReference property DLCCoastDaltonRailingBackward01 = None auto conditional hidden
ObjectReference property DLCCoastDaltonRailingBackward02 = None auto conditional hidden
ObjectReference property DLCCoastDaltonRailingBackward03 = None auto conditional hidden
ObjectReference property DLCCoastDaltonRailingBackward04 = None auto conditional hidden
ObjectReference property DLCCoastDaltonRailingBackward05 = None auto conditional hidden

; mod companion index
int property ModUniqueFollowerFemBodyBaseIndex = -1 auto conditional hidden
int property ModUniqueFollowerMaleBodyBaseIndex = -1 auto conditional hidden
int property ModUniqueFollowerFemBodyLength = -1 auto conditional hidden
int property ModUniqueFollowerMaleBodyLength = -1 auto conditional hidden
int property ModCompanionBodyHeatherIndex = -1 auto conditional hidden
int property ModCompanionActorHeatherIndex = -1 auto conditional hidden
int property ModCompanionActorNWSBarbIndex = -1 auto conditional hidden
int property ModCompanionBodyNanaIndex = -1 auto conditional hidden			; v2.60, first of 2
int property DTSleep_ModCompanionActorList = -1 auto conditional hidden		; not used
