ScriptName DTSleep_AACcatScript Hidden
;
; *********************
; script by DracoTorre
; Sleep Intimate
; https://www.dracotorre.com/mods/sleepintimate/
; hhttps://github.com/Dracotorre/SleepIntimateV2
;
; supports DTSleep_PlayAACScript with animation pack Form data for idles and scene-setup data
; animation idles designed for AAF default actors and furniture begin at same position with same facing
;   offsets may be included if actors in different position
; 
; sequences by IDs defined in DTSleep_IntimateAnimQuestScript
;
; built-in hug & kiss (90s)
; CHAK (400s)
; Atomic Lust, RufGt, Mutant Lust (500s) - 11 scenes
; SavageCabbage_Animations (700s) - 42 scenes
; ZaZOut4 (800s) - 4 scenes (2 broken into shorter scenes)
; Gray (900s)
; BP70 (1000s)
; Rohzima (1100s)

; **********************  Structs **************
;
;  a stage within a sequence for a scene
Struct DTAACSceneStageStruct
	string PluginName = ""				; name of animation pack
	float StageTime = -1.0				; duration in seconds - if <0.0 then use default
	float FAngleOffset = 0.0			; female-role (or 2nd actor) angle offset - how much to turn
	float MAngleOffset = 0.0			; male-role (or 1st actor) angle offset
	float MPosYOffset = 0.0				; male-role Y-offset
	float MPosZOffset = 0.0				; male-role Z-offset
	int ArmorNudeAGun = 0				; male erection angle for primary male-role
	int ArmorNudeBGun = -1				; for secondary male-role
	int ArmorNudeCGun = -1
   	int MAnimFormID = 0					; male-role idle FormID
	int FAnimFormID = 0					; female-role idle FormID
	int OAnimFormID = 0					; third-role idle FormID
	int StageNum = 0					; number of stage in sequence (1+)
	string PositionID = ""				; AAF position ID for XML
	string PositionOrigID = ""			; AAF original position ID for pack
	float MorphAngleA = 0.0				; how much to morph in ArmorNudeAGun direction
	float MorphAngleB = 0.0
EndStruct

; ***************** Functions ************************** ;

DTAACSceneStageStruct[] Function GetSeqCatArrayForSequenceID(int seqID, int longScene = 0, int genders = -1, int other = 0, bool scEVB = true) global

	DTAACSceneStageStruct[] result = new DTAACSceneStageStruct[0]
	int stageTotal = 1
	int count = 0
	
	if (other > 0 && seqID >= 701 && seqID <= 702)
		; force short scene
		stageTotal = GetStageCountForSequenceID(seqID, -2, other)					; v2.70 added missing param other
	else
		stageTotal = GetStageCountForSequenceID(seqID, longScene, other)
	endIf
	
	while (count < stageTotal)
		DTAACSceneStageStruct ssStruct = GetSingleStage(seqID, count + 1, genders, other, longScene, scEVB)		
		result.Add(ssStruct)
		
		count += 1
	endWhile
	
	return result
endFunction

int Function GetStageCountForSequenceID(int seqID, int longScene = 0, int other = 0) global
	int result = 4   ; most of them
	
	if (seqID >= 1100)
		result = 6
		if (seqID == 1102 || seqID == 1106)
			result = 4
		elseIf (seqID == 1120)
			result = 4
		elseIf (seqID >= 1130 && seqID <= 1131)
			result = 4
		elseIf (seqID == 1135)
			result = 2
		;elseIf (seqID == 1134)
		;	result = 4
		elseIf (seqID == 1148)
			result = 1
		elseIf (seqID >= 1149 && seqID <= 1150)
			result = 4
		elseIf (seqID == 1153)
			result = 4
		elseIf (seqID == 1162)
			result = 4
		elseIf (seqID == 1193 && other > 0)
			result = 8
		endIf
		
	elseIf (seqID >= 400 && seqID < 500)
		result = 1
		if (seqID == 401 || seqID == 451 || seqID == 460)
			result = 2
		elseIf (seqID >= 450 && seqID < 490)
			result = 3
		elseIf (seqID == 494)
			result = 2
		endIf
	elseIf (seqID >= 500 && seqID < 600)
		result = 1
		if (seqID >= 509 && seqID <= 511)
			result = 2
		elseIf (seqID == 535)
			result = 4
		elseIf (seqID >= 546 && seqID <= 547)
			result = 6
		endIf
	elseIf (seqID >= 682 && seqID < 700)
		if (seqID == 697)
			result = 6
		endIf
	elseIf (seqID >= 849 && seqID < 900)
		if (seqID >= 851 && longScene > 0)
			return 9
		endIf
		result = 6
	elseIf (seqID >= 700)
		if (longScene < 0)
			return 1
		elseIf (seqID >= 798 && seqID < 800)
			return 1
		elseIf (seqID == 797)
			return 8
		elseIf (seqID == 796)
			if (longScene)
				return 6
			endIf
			return 4
		elseIf (seqID == 794)	
			if (longScene > 0)
				return 6
			endIf
			return 2
		elseIf (seqID == 793)
			if (longScene > 0)
				return 8
			endIf
			return 6
		elseIf (seqID == 788)
			if (longScene >= 1)
				return 8
			endIf
			return 6
		elseIf (seqID == 787)
			if (longScene >= 1)
				return 8
			endIf
			return 1
		elseIf (seqID == 784)
			return 6
		elseIf (seqID == 780)
			if (longScene > 0)
				return 2
			endIf
			return 1
		elseIf (seqID == 781)
			if (longScene == 1)
				return 2
			elseIf (longScene >= 2)
				return 4
			endIf
			return 1
		elseIf (seqID == 792)
			return 2
		elseIf (seqID == 785)
			if (longScene <= 0)
				return 2
			endIf
			return 4
		elseIf (seqID >= 782 && seqID <= 783)				; v2.77; updated v2.79
			if (longScene <= 0)
				return 2
			elseIf (seqID == 783 && longScene > 2)
				return 8
			endIf
			return 6
		elseIf (seqID == 779)
			return 8
		elseIf (seqId >= 772 && seqID <= 773)
			return 8
		elseIf (seqID == 771)
			return 6
		elseIf (seqID == 769)
			return 1
		elseIf (seqID == 768 && longScene > 0)
			return 6
		elseIf (seqID == 763)
			if (longScene > 0)
				return 6
			endIf
		elseIf (seqID >= 764 && seqID < 767)
			result = 6
			if (seqID != 765 && longScene >= 2)
				result = 7
			endIf
		elseIf (seqID == 767)
			if (longScene >= 1)
				result = 6
			endIf
		elseIf (seqID == 756)
			if (other <= 0)
				result = 7
			else
				result = 1
			endIf
		elseIf (seqID == 761)
			if (other >= 1)
				if (longScene > 0)
					result = 2
				else
					result = 1
				endIf
			elseIf (longScene >= 1)
				result = 6
			endIf
		elseIf (seqID == 760 && longScene > 0)
			result = 6
		elseIf (seqID == 759)
			result = 6
		elseIf (seqID == 755)
			if (longScene > 0)
				result = 4
			else
				result = 1
			endIf
		elseIf (seqID == 754)
			if (longScene <= 0)
				result = 1
			else
				result = 6
			endIf
		elseIf (seqID == 753)
			if (longScene <= 0)
				result = 4
			else
				result = 6
			endIf
		elseIf (seqID == 752)
			if (longScene > 0)
				result = 6
			endIf
		elseIf (seqID == 749)
			if (other == 0 && longScene >= 1)
				result = 4
			else
				result = 1
			endIf
		elseIf (seqID == 748)
			if (other > 0)
				result = 1
			elseIf (longScene > 0)
				result = 6
			endIf
		elseIf (seqID == 747)
			if (longScene > 0)
				result = 6
			endIf
		elseIf (seqID == 740)
			result = 2
		elseIf (seqID == 741)
			if (longScene <= 0)
				result = 2
			else
				result = 4
			endIf
		elseIf (seqID == 742)
			result = 6
		elseIf (seqID >= 743 && seqID <= 745)
			result = 1
		elseIf (seqID == 746)
			if (longScene <= 0)
				result = 1
			elseIf (longScene == 1)
				result = 2
			else
				result = 6
			endIf
		elseIf (seqID == 739)
			result = 1
		elseIf (seqID == 738)
			if (longScene > 0)
				result = 8
			else
				result = 6
			endIf
		elseIf (seqID == 737 && longScene >= 0 && other <= 0)
			if (longScene > 1)
				result = 8
			else
				result = 6
			endIf
		elseIf (seqID >= 734 && seqID <= 736 && other <= 0)
			result = 6
		elseIf (seqID == 735 && other >= 2)
			result = 6
		elseIf (seqID == 732)
			result = 2
		elseIf (seqID >= 713 && seqID <= 715)
			if (longScene == 1)
				result = 2
			elseIf (longScene >= 2)
				if (seqID == 715 && longScene >= 3)
					result = 6
				else
					result = 3
				endIf
			else
				result = 1
			endIf								
		elseIf (seqID >= 710 && seqID <= 712)	; v2.53 fix include 712
			result = 6
		elseIf (seqID == 709)
			result = 8
		elseIf (seqID == 707)
			if (other > 0 && longScene > 0)
				result = 2
			else
				result = 6
			endIf
		elseIf (seqID == 706)
			if (other > 0)
				if (longScene > 0)
					result = 2
				else
					result = 1
				endIf
			else
				result = 6
			endIf
		elseIf (seqID == 705)
			result = 4
			if (longScene > 0 && other <= 0)
				result = 6
			endIf
		elseIf (seqID == 704)
			result = 6
		elseIf (seqID == 702 && other > 0)
			result = 1
		elseIf (seqID >= 701 && seqID <= 703)
			if (other > 0)
				result = 1
			else
				result = 6
			endIf
		elseIf (seqID == 700 && other > 0)
			result = 8
		elseIf (seqID >= 770 && seqID <= 772)
			result = 2
		elseIf (seqID >= 774 && seqID <= 775)
			if (longScene > 0)
				result = 6
			else
				result = 4
			endIf
		elseIf (seqID == 778)
			result = 2
		elseIf (seqID == 777)
			result = 3
		endIf
	elseIf (seqID >= 1000)					; v3.00
		result = 4
		if (seqID == 1088)
			result = 8
		elseIf (seqID >= 1096)
			result = 1
		elseIf (seqID >= 1080 && seqID < 1083)
			result = 1
		elseIf (seqID == 1071)
			result = 8
		elseIf (seqID >= 1060 && seqID < 1061)
			result = 1
		elseIf (seqID == 1054)
			result = 4
		elseIf (seqID >= 1047 && seqID <= 1051)
			result = 1
		elseIf (seqID >= 1031 && seqID <= 1036)
			result = 1
		elseIf (seqID >= 1019 && seqID <= 1020)
			result = 1
		elseIf (seqID >= 1017 && seqID <= 1018)
			result = 1
		elseIf (seqID == 1016)
			result = 6
		elseIf (seqID >= 1012 && seqID <= 1015)
			result = 1
		elseIf (seqID == 1009)
			result = 6
		elseIf (seqID >= 1004 && seqID <= 1006)
			result = 1
		elseIf (seqID == 1003)
			result = 6
		endIf
	endIf
	
	return result
endFunction

DTAACSceneStageStruct Function GetSingleStage(int seqID, int stageNumber, int genders = -1, int other = 0, int longScene = 0, bool scEVB = true) global

	DTAACSceneStageStruct ssStruct = new DTAACSceneStageStruct
	ssStruct.StageNum = stageNumber
	ssStruct.ArmorNudeAGun = 0
	ssStruct.ArmorNudeBGun = -1			;v2.25 - changed to default negative; always set for male
	ssStruct.ArmorNudeCGun = -1
	
	if (!Debug.GetPlatformName() as bool)
		return ssStruct
	endIf
	
	if (seqID >= 1100)
		ssStruct.PluginName = "RZSex.esp"					; added v3.15 -- 25 scenes
		
		if (seqID == 1100)
			if (stageNumber == 1)
				ssStruct.FAnimFormID = 0x090091BC
				ssStruct.MAnimFormID = 0x090091BD
				ssStruct.PositionOrigID = "RZ_MissionaryGroundRough01"
				ssStruct.PositionID = "DTSIX_1100_S1"
				ssStruct.MAngleOffset = 180.0
			elseIf (stageNumber == 2)
				ssStruct.FAnimFormID = 0x090091BE
				ssStruct.MAnimFormID = 0x090091BF
				ssStruct.PositionOrigID = "RZ_MissionaryGroundRough02"
				ssStruct.PositionID = "DTSIX_1100_S2"
				ssStruct.MAngleOffset = 180.0
			elseIf (stageNumber == 3)
				ssStruct.FAnimFormID = 0x090091C0
				ssStruct.MAnimFormID = 0x090091C1
				ssStruct.PositionOrigID = "RZ_MissionaryGroundRough03"
				ssStruct.PositionID = "DTSIX_1100_S3"
				ssStruct.MAngleOffset = 180.0
			elseIf (stageNumber == 4)
				ssStruct.FAnimFormID = 0x090091C2
				ssStruct.MAnimFormID = 0x090091C3
				ssStruct.PositionOrigID = "RZ_MissionaryGroundRough04"
				ssStruct.PositionID = "DTSIX_1100_S4"
				ssStruct.MAngleOffset = 180.0
			else
				ssStruct.FAnimFormID = 0x090091C4
				ssStruct.MAnimFormID = 0x090091C5
				ssStruct.PositionOrigID = "RZ_MissionaryGroundRough05"
				ssStruct.PositionID = "DTSIX_1100_S5"
				ssStruct.MAngleOffset = 180.0
			endIf
		
		elseIf (seqID == 1101)
			if (stageNumber == 1)
				ssStruct.FAnimFormID = 0x09001EED
				ssStruct.MAnimFormID = 0x09001EEE
				ssStruct.PositionOrigID = "RZ_MissionaryGroundTender01"
				ssStruct.PositionID = "DTSIX_1101_S1"
				ssStruct.MAngleOffset = 180.0
			elseIf (stageNumber == 2)
				ssStruct.FAnimFormID = 0x09001EEF
				ssStruct.MAnimFormID = 0x09001EF0
				ssStruct.PositionOrigID = "RZ_MissionaryGroundTender02"
				ssStruct.PositionID = "DTSIX_1101_S2"
				ssStruct.MAngleOffset = 180.0
			elseIf (stageNumber == 3)
				ssStruct.FAnimFormID = 0x09001EF1
				ssStruct.MAnimFormID = 0x09001EF2
				ssStruct.PositionOrigID = "RZ_MissionaryGroundTender03"
				ssStruct.PositionID = "DTSIX_1101_S3"
				ssStruct.MAngleOffset = 180.0
			elseIf (stageNumber == 4)
				ssStruct.FAnimFormID = 0x09001EF3
				ssStruct.MAnimFormID = 0x09001EF4
				ssStruct.PositionOrigID = "RZ_MissionaryGroundTender04"
				ssStruct.PositionID = "DTSIX_1101_S4"
				ssStruct.MAngleOffset = 180.0
			elseIf (stageNumber == 5)
				ssStruct.FAnimFormID = 0x09001EF5
				ssStruct.MAnimFormID = 0x09001EF6
				ssStruct.PositionOrigID = "RZ_MissionaryGroundTender05"
				ssStruct.PositionID = "DTSIX_1101_S5"
				ssStruct.MAngleOffset = 180.0
			else
				ssStruct.FAnimFormID = 0x09001EF7
				ssStruct.MAnimFormID = 0x09001EF8
				ssStruct.PositionOrigID = "RZ_MissionaryGroundTender06"
				ssStruct.PositionID = "DTSIX_1101_S6"
				ssStruct.MAngleOffset = 180.0
			endIf
		elseIf (seqID == 1102)
			if (stageNumber == 1)
				ssStruct.FAnimFormID = 0x0900FCCC				
				ssStruct.MAnimFormID = 0x0900FCCD
				ssStruct.PositionOrigID = "RZ_DoggyGroundRough01"
				ssStruct.PositionID = "DTSIX_1102_S1"
			elseIf (stageNumber == 2)
				ssStruct.FAnimFormID = 0x0900FCD2				
				ssStruct.MAnimFormID = 0x0900FCD3
				ssStruct.PositionOrigID = "RZ_DoggyGroundRough04"
				ssStruct.PositionID = "DTSIX_1102_S2"
			elseIf (stageNumber == 3)
				ssStruct.FAnimFormID = 0x0900FCD4				
				ssStruct.MAnimFormID = 0x0900FCD5
				ssStruct.PositionOrigID = "RZ_DoggyGroundRough05"
				ssStruct.PositionID = "DTSIX_1102_S3"
			else
				ssStruct.FAnimFormID = 0x0900FCD6				
				ssStruct.MAnimFormID = 0x0900FCD7
				ssStruct.PositionOrigID = "RZ_DoggyGroundRough06"
				ssStruct.PositionID = "DTSIX_1102_S4"
			endIf
		
		elseIf (seqID == 1103)
			if (stageNumber == 1)
				ssStruct.FAnimFormID = 0x09000F99				; start on side -- floor or double-bed only
				ssStruct.MAnimFormID = 0x09000F9A
				ssStruct.PositionOrigID = "RZ_DoggyGroundTender01"
				ssStruct.PositionID = "DTSIX_1103_S1"
			elseIf (stageNumber == 2)
				ssStruct.FAnimFormID = 0x09000F9B
				ssStruct.MAnimFormID = 0x09000F9C
				ssStruct.PositionOrigID = "RZ_DoggyGroundTender02"
				ssStruct.PositionID = "DTSIX_1103_S2"
			elseIf (stageNumber == 3)
				ssStruct.FAnimFormID = 0x09000F9D
				ssStruct.MAnimFormID = 0x09000F9E
				ssStruct.PositionOrigID = "RZ_DoggyGroundTender03"
				ssStruct.PositionID = "DTSIX_1103_S3"
			elseIf (stageNumber == 4)
				ssStruct.FAnimFormID = 0x09000F9F
				ssStruct.MAnimFormID = 0x09000FA0
				ssStruct.PositionOrigID = "RZ_DoggyGroundTender04"
				ssStruct.PositionID = "DTSIX_1103_S4"
			elseIf (stageNumber == 5)
				ssStruct.FAnimFormID = 0x09000FA1
				ssStruct.MAnimFormID = 0x09000FA4
				ssStruct.PositionOrigID = "RZ_DoggyGroundTender05"
				ssStruct.PositionID = "DTSIX_1103_S5"
			else
				ssStruct.FAnimFormID = 0x09000FA2
				ssStruct.MAnimFormID = 0x09000FA3
				ssStruct.PositionOrigID = "RZ_DoggyGroundTender06"
				ssStruct.PositionID = "DTSIX_1103_S6"
			endIf
		elseIf (seqID == 1104)
			if (stageNumber == 1)
				ssStruct.FAnimFormID = 0x09001EE1					; sit on torso, manual
				ssStruct.MAnimFormID = 0x09001EE2
				ssStruct.PositionOrigID = "RZ_CowgirlGroundTender01"
				ssStruct.PositionID = "DTSIX_1104_S1"
				ssStruct.MAngleOffset = 180.0
				;ssStruct.MPosYOffset = -3.4							; position appears off
			elseIf (stageNumber == 2)
				ssStruct.FAnimFormID = 0x09001EE3					; cowgirl rev
				ssStruct.MAnimFormID = 0x09001EE4
				ssStruct.PositionOrigID = "RZ_CowgirlGroundTender02"
				ssStruct.PositionID = "DTSIX_1104_S2"
				ssStruct.MAngleOffset = 180.0
			elseIf (stageNumber == 3)
				ssStruct.FAnimFormID = 0x09001EE6
				ssStruct.MAnimFormID = 0x09001EE5
				ssStruct.PositionOrigID = "RZ_CowgirlGroundTender03"
				ssStruct.PositionID = "DTSIX_1104_S3"
				ssStruct.MAngleOffset = 180.0
			elseIf (stageNumber == 4)
				ssStruct.FAnimFormID = 0x09001EE7
				ssStruct.MAnimFormID = 0x09001EE8
				ssStruct.PositionOrigID = "RZ_CowgirlGroundTender04"
				ssStruct.PositionID = "DTSIX_1104_S4"
				ssStruct.MAngleOffset = 180.0
			elseIf (stageNumber == 5)
				ssStruct.FAnimFormID = 0x09001EE9
				ssStruct.MAnimFormID = 0x09001EEA
				ssStruct.PositionOrigID = "RZ_CowgirlGroundTender05"
				ssStruct.PositionID = "DTSIX_1104_S5"
				ssStruct.MAngleOffset = 180.0
			else
				ssStruct.FAnimFormID = 0x09001EEB
				ssStruct.MAnimFormID = 0x09001EEC
				ssStruct.PositionOrigID = "RZ_CowgirlGroundTender06"
				ssStruct.PositionID = "DTSIX_1104_S6"
				ssStruct.MAngleOffset = 180.0
			endIf
			
		elseIf (seqID == 1106)
			if (stageNumber == 0)
				ssStruct.FAnimFormID = 0x090026A6					; sit on face rev
				ssStruct.MAnimFormID = 0x090026AB
				ssStruct.PositionOrigID = "RZ_RevCowgirlGroundTender01"
				ssStruct.PositionID = "DTSIX_1106_S0"
			elseIf (stageNumber == 1)
				ssStruct.FAnimFormID = 0x090026A7					; rev-cowgirl
				ssStruct.MAnimFormID = 0x090026AC
				ssStruct.PositionOrigID = "RZ_RevCowgirlGroundTender02"
				ssStruct.PositionID = "DTSIX_1106_S2"
				
			elseIf (stageNumber == 2)
				ssStruct.FAnimFormID = 0x090026A8
				ssStruct.MAnimFormID = 0x090026AD
				ssStruct.PositionOrigID = "RZ_RevCowgirlGroundTender03"
				ssStruct.PositionID = "DTSIX_1106_S3"
				
			elseIf (stageNumber == 3)
				ssStruct.FAnimFormID = 0x090026A9
				ssStruct.MAnimFormID = 0x090026AE
				ssStruct.PositionOrigID = "RZ_RevCowgirlGroundTender04"
				ssStruct.PositionID = "DTSIX_1106_S4"
				
			else
				ssStruct.FAnimFormID = 0x090026AA
				ssStruct.MAnimFormID = 0x090026AF
				ssStruct.PositionOrigID = "RZ_RevCowgirlGroundTender05"
				ssStruct.PositionID = "DTSIX_1106_S5"
				ssStruct.ArmorNudeAGun = 2
			endIf
		elseIf (seqID == 1116)
			if (stageNumber == 1)
				ssStruct.FAnimFormID = 0x09001EF9								
				ssStruct.MAnimFormID = 0x09001EFA								
				ssStruct.PositionOrigID = "RZ_ProneGroundTender01"
				ssStruct.PositionID = "DTSIX_1116_S1"
			elseIf (stageNumber == 2)
				ssStruct.FAnimFormID = 0x09001EFB								
				ssStruct.MAnimFormID = 0x09001EFC								
				ssStruct.PositionOrigID = "RZ_ProneGroundTender02"
				ssStruct.PositionID = "DTSIX_1116_S2"
			elseIf (stageNumber == 3)
				ssStruct.FAnimFormID = 0x09001EFD								
				ssStruct.MAnimFormID = 0x09001EFE								
				ssStruct.PositionOrigID = "RZ_ProneGroundTender03"
				ssStruct.PositionID = "DTSIX_1116_S3"
			elseIf (stageNumber == 4)
				ssStruct.FAnimFormID = 0x09001EFF								
				ssStruct.MAnimFormID = 0x09001F00								
				ssStruct.PositionOrigID = "RZ_ProneGroundTender04"
				ssStruct.PositionID = "DTSIX_1116_S4"
			else
				ssStruct.FAnimFormID = 0x09001F01								
				ssStruct.MAnimFormID = 0x09001F02								
				ssStruct.PositionOrigID = "RZ_ProneGroundTender05"
				ssStruct.PositionID = "DTSIX_1116_S5"
			endIf
		
		elseIf (seqID == 1121)
			if (stageNumber == 1)
				ssStruct.FAnimFormID = 0x0900FCC2								; stand posing
				ssStruct.MAnimFormID = 0x0900FCC3								; self-pleasure
				ssStruct.PositionOrigID = "RZ_ButtWorshipGroundTender01"
				ssStruct.PositionID = "DTSIX_1121_S1"
			elseIf (stageNumber == 2)
				ssStruct.FAnimFormID = 0x0900FCC4
				ssStruct.MAnimFormID = 0x0900FCC5
				ssStruct.PositionOrigID = "RZ_ButtWorshipGroundTender02"
				ssStruct.PositionID = "DTSIX_1121_S2"
			elseIf (stageNumber == 3)
				ssStruct.FAnimFormID = 0x0900FCC6
				ssStruct.MAnimFormID = 0x0900FCC7
				ssStruct.PositionOrigID = "RZ_ButtWorshipGroundTender03"
				ssStruct.PositionID = "DTSIX_1121_S3"
			elseIf (stageNumber == 4)
				ssStruct.FAnimFormID = 0x0900FCC8
				ssStruct.MAnimFormID = 0x0900FCC9
				ssStruct.PositionOrigID = "RZ_ButtWorshipGroundTender04"
				ssStruct.PositionID = "DTSIX_1121_S4"
			else
				ssStruct.FAnimFormID = 0x0900FCCA
				ssStruct.MAnimFormID = 0x0900FCCB
				ssStruct.PositionOrigID = "RZ_ButtWorshipGroundTender05"
				ssStruct.PositionID = "DTSIX_1121_S5"
			endIf
		elseIf (seqID == 1130)
			if (stageNumber == 1)
				ssStruct.FAnimFormID = 0x0900E5B9
				ssStruct.MAnimFormID = 0x0900E5BA
				ssStruct.PositionOrigID = "RZ_SpankingChairTender02"
				ssStruct.PositionID = "DTSIX_1130_S1"
				ssStruct.FAngleOffset = 270.0
				ssStruct.ArmorNudeAGun = -1
			elseIf (stageNumber == 2)
				ssStruct.FAnimFormID = 0x0900E5BB
				ssStruct.MAnimFormID = 0x0900E5BC
				ssStruct.PositionOrigID = "RZ_SpankingChairTender03"
				ssStruct.PositionID = "DTSIX_1130_S2"
				ssStruct.FAngleOffset = 270.0
				ssStruct.ArmorNudeAGun = -1
			elseIf (stageNumber == 3)
				ssStruct.FAnimFormID = 0x0900E5BD
				ssStruct.MAnimFormID = 0x0900E5BE
				ssStruct.PositionOrigID = "RZ_SpankingChairTender04"
				ssStruct.PositionID = "DTSIX_1130_S3"
				ssStruct.FAngleOffset = 270.0
				ssStruct.ArmorNudeAGun = -1
			else
				ssStruct.FAnimFormID = 0x0900E5BF
				ssStruct.MAnimFormID = 0x0900E5C0
				ssStruct.PositionOrigID = "RZ_SpankingChairTender05"
				ssStruct.PositionID = "DTSIX_1130_S4"
				ssStruct.FAngleOffset = 270.0
				ssStruct.ArmorNudeAGun = -1
			;else
			;	ssStruct.FAnimFormID = 0x0900E5C1
			;	ssStruct.MAnimFormID = 0x0900E5C2
			;	ssStruct.PositionOrigID = "RZ_SpankingChairTender06"
			;	ssStruct.PositionID = "DTSIX_1120_S5"
			;	ssStruct.FAngleOffset = 270.0
			endIf
		
		elseIf (seqID == 1131)
			if (stageNumber == 0)								; FAngle changes not supported, so skip first 2 stages
				ssStruct.FAnimFormID = 0x0900DE14
				ssStruct.MAnimFormID = 0x0900DE15
				ssStruct.PositionOrigID = "RZ_SexCouchTender01"
				ssStruct.PositionID = "DTSIX_1131_S1"
				ssStruct.FAngleOffset = 180.0
			;elseIf (stageNumber == 2)
			;	ssStruct.FAnimFormID = 0x0900DE16
			;	ssStruct.MAnimFormID = 0x0900DE17
			;	ssStruct.PositionOrigID = "RZ_SexCouchTender02"
			;	ssStruct.PositionID = "DTSIX_1131_S2"
			;	ssStruct.FAngleOffset = 180.0
			elseIf (stageNumber == 3)
				ssStruct.FAnimFormID = 0x0900DE18
				ssStruct.MAnimFormID = 0x0900DE19
				ssStruct.PositionOrigID = "RZ_SexCouchTender03"
				ssStruct.PositionID = "DTSIX_1131_S3"
			elseIf (stageNumber == 4)
				ssStruct.FAnimFormID = 0x0900DE1A
				ssStruct.MAnimFormID = 0x0900DE1B
				ssStruct.PositionOrigID = "RZ_SexCouchTender04"
				ssStruct.PositionID = "DTSIX_1131_S4"
			else
				ssStruct.FAnimFormID = 0x0900DE1C
				ssStruct.MAnimFormID = 0x0900DE1D
				ssStruct.PositionOrigID = "RZ_SexCouchTender05"
				ssStruct.PositionID = "DTSIX_1131_S5"
			endIf
		elseIf (seqID == 1132)								; rotate 180, Z+  ?? seems only fits memory lounge couch?
			if (stageNumber == 1)
				ssStruct.FAnimFormID = 0x09006B67
				ssStruct.MAnimFormID = 0x09006B68
				ssStruct.PositionOrigID = "RZ_DoggyCouchTender01"
				ssStruct.PositionID = "DTSIX_1132_S1"
			elseIf (stageNumber == 2)
				ssStruct.FAnimFormID = 0x09006B69
				ssStruct.MAnimFormID = 0x09006B6A
				ssStruct.PositionOrigID = "RZ_DoggyCouchTender02"
				ssStruct.PositionID = "DTSIX_1132_S2"
			elseIf (stageNumber == 3)
				ssStruct.FAnimFormID = 0x09006B6B
				ssStruct.MAnimFormID = 0x09006B6C
				ssStruct.PositionOrigID = "RZ_DoggyCouchTender03"
				ssStruct.PositionID = "DTSIX_1132_S3"
			elseIf (stageNumber == 4)
				ssStruct.FAnimFormID = 0x09006B6D
				ssStruct.MAnimFormID = 0x09006B6E
				ssStruct.PositionOrigID = "RZ_DoggyCouchTender04"
				ssStruct.PositionID = "DTSIX_1132_S4"
			else
				ssStruct.FAnimFormID = 0x09006B6f
				ssStruct.MAnimFormID = 0x09006B70
				ssStruct.PositionOrigID = "RZ_DoggyCouchTender05"
				ssStruct.PositionID = "DTSIX_1132_S5"
			endIf
		elseIf (seqID == 1133)					; AnimFurnCouch KY only					
			if (stageNumber == 1)
				ssStruct.FAnimFormID = 0x0900DE0A
				ssStruct.MAnimFormID = 0x0900DE0B
				ssStruct.PositionOrigID = "RZ_BlowjobCouchTender01"
				ssStruct.PositionID = "DTSIX_1133_S1"
				ssStruct.FAngleOffset = 180.0
			elseIf (stageNumber == 2)
				ssStruct.FAnimFormID = 0x0900DE0C
				ssStruct.MAnimFormID = 0x0900DE0D
				ssStruct.PositionOrigID = "RZ_BlowjobCouchTender02"
				ssStruct.PositionID = "DTSIX_1133_S2"
				ssStruct.FAngleOffset = 180.0
			elseIf (stageNumber == 3)
				ssStruct.FAnimFormID = 0x0900DE0E
				ssStruct.MAnimFormID = 0x0900DE0F
				ssStruct.PositionOrigID = "RZ_BlowjobCouchTender03"
				ssStruct.PositionID = "DTSIX_1133_S3"
				ssStruct.FAngleOffset = 180.0
			elseIf (stageNumber == 4)
				ssStruct.FAnimFormID = 0x0900DE10
				ssStruct.MAnimFormID = 0x0900DE11
				ssStruct.PositionOrigID = "RZ_BlowjobCouchTender04"
				ssStruct.PositionID = "DTSIX_1133_S4"
				ssStruct.FAngleOffset = 180.0
			else
				ssStruct.FAnimFormID = 0x0900DE12
				ssStruct.MAnimFormID = 0x0900DE13
				ssStruct.PositionOrigID = "RZ_BlowjobCouchTender05"
				ssStruct.PositionID = "DTSIX_1133_S5"
				ssStruct.FAngleOffset = 180.0
			endIf
		elseIf (seqID == 1134)												; use bench without back
			if (stageNumber == 1)
				ssStruct.FAnimFormID = 0x0900ED70
				ssStruct.MAnimFormID = 0x0900ED71
				ssStruct.PositionOrigID = "RZ_CowgirlCouchTender01"
				ssStruct.PositionID = "DTSIX_1134_S1"
				ssStruct.FAngleOffset = 180.0
			elseIf (stageNumber == 2)
				ssStruct.FAnimFormID = 0x0900ED72
				ssStruct.MAnimFormID = 0x0900ED73
				ssStruct.PositionOrigID = "RZ_CowgirlCouchTender02"
				ssStruct.PositionID = "DTSIX_1134_S2"
				ssStruct.FAngleOffset = 180.0
			elseIf (stageNumber == 3)
				ssStruct.FAnimFormID = 0x0900ED74
				ssStruct.MAnimFormID = 0x0900ED75
				ssStruct.PositionOrigID = "RZ_CowgirlCouchTender03"
				ssStruct.PositionID = "DTSIX_1134_S3"
				ssStruct.FAngleOffset = 180.0
			elseIf (stageNumber == 4)
				ssStruct.FAnimFormID = 0x0900ED76
				ssStruct.MAnimFormID = 0x0900ED77
				ssStruct.PositionOrigID = "RZ_CowgirlCouchTender04"			; feet out -- chair without back
				ssStruct.PositionID = "DTSIX_1134_S4"
				ssStruct.FAngleOffset = 180.0
			else
				ssStruct.FAnimFormID = 0x0900ED78
				ssStruct.MAnimFormID = 0x0900ED79
				ssStruct.PositionOrigID = "RZ_CowgirlCouchTender05"			; feet out -- chair without back
				ssStruct.PositionID = "DTSIX_1134_S5"
				ssStruct.FAngleOffset = 180.0
			endIf
		elseIf (seqID == 1135)								; oral/manual -- FAngle changes, not supported, use 2 stages
			if (stageNumber == 1)
				ssStruct.FAnimFormID = 0x0900ED66
				ssStruct.MAnimFormID = 0x0900ED67
				ssStruct.PositionOrigID = "RZ_DomGirlCouchTender01"
				ssStruct.PositionID = "DTSIX_1135_S1"
				ssStruct.FAngleOffset = 180.0
				ssStruct.StageTime = 10.0
			elseIf (stageNumber == 2)
				ssStruct.FAnimFormID = 0x0900ED68
				ssStruct.MAnimFormID = 0x0900ED69
				ssStruct.PositionOrigID = "RZ_DomGirlCouchTender02"
				ssStruct.PositionID = "DTSIX_1135_S2"
				ssStruct.FAngleOffset = 180.0
				ssStruct.StageTime = 12.0
			elseIf (stageNumber == 3)
				ssStruct.FAnimFormID = 0x0900ED6A
				ssStruct.MAnimFormID = 0x0900ED6B
				ssStruct.PositionOrigID = "RZ_DomGirlCouchTender03"
				ssStruct.PositionID = "DTSIX_1135_S3"
				ssStruct.FAngleOffset = 270.0
			elseIf (stageNumber == 4)
				ssStruct.FAnimFormID = 0x0900ED6C
				ssStruct.MAnimFormID = 0x0900ED6D
				ssStruct.PositionOrigID = "RZ_DomGirlCouchTender04"
				ssStruct.PositionID = "DTSIX_1135_S4"
			else
				ssStruct.FAnimFormID = 0x0900ED6E
				ssStruct.MAnimFormID = 0x0900ED6F
				ssStruct.PositionOrigID = "RZ_DomGirlCouchTender05"
				ssStruct.PositionID = "DTSIX_1135_S5"
			endIf
		elseIf (seqID == 1136)								; need to rotation 180 on positioning
			if (stageNumber == 0)							; skip first due to rotation change
				ssStruct.FAnimFormID = 0x09008276
				ssStruct.MAnimFormID = 0x09008277
				ssStruct.PositionOrigID = "RZ_DoggyChairTender01"
				ssStruct.PositionID = "DTSIX_1136_S1"
				ssStruct.MAngleOffset = 90.0
			elseIf (stageNumber == 1)
				ssStruct.FAnimFormID = 0x09008278
				ssStruct.MAnimFormID = 0x09008279
				ssStruct.PositionOrigID = "RZ_DoggyChairTender02"
				ssStruct.PositionID = "DTSIX_1136_S2"
			elseIf (stageNumber == 2)
				ssStruct.FAnimFormID = 0x0900827A
				ssStruct.MAnimFormID = 0x0900827B
				ssStruct.PositionOrigID = "RZ_DoggyChairTender03"
				ssStruct.PositionID = "DTSIX_1136_S3"
			elseIf (stageNumber == 3)
				ssStruct.FAnimFormID = 0x0900827C
				ssStruct.MAnimFormID = 0x0900827D
				ssStruct.PositionOrigID = "RZ_DoggyChairTender04"
				ssStruct.PositionID = "DTSIX_1136_S4"
			else
				ssStruct.FAnimFormID = 0x0900827E
				ssStruct.MAnimFormID = 0x0900827F
				ssStruct.PositionOrigID = "RZ_DoggyChairTender05"
				ssStruct.PositionID = "DTSIX_1136_S5"
			endIf
		elseIf (seqID == 1137)									; seated, no arms or wide
			if (stageNumber == 1)							
				ssStruct.FAnimFormID = 0x090035E2
				ssStruct.MAnimFormID = 0x090035E3
				ssStruct.PositionOrigID = "RZ_SexBehindChairTender01"
				ssStruct.PositionID = "DTSIX_1137_S1"
			elseIf (stageNumber == 2)
				ssStruct.FAnimFormID = 0x09003D7D
				ssStruct.MAnimFormID = 0x09003D7E
				ssStruct.PositionOrigID = "RZ_SexBehindChairTender02"
				ssStruct.PositionID = "DTSIX_1137_S2"
			elseIf (stageNumber == 3)
				ssStruct.FAnimFormID = 0x09003D7F
				ssStruct.MAnimFormID = 0x09003D80
				ssStruct.PositionOrigID = "RZ_SexBehindChairTender03"
				ssStruct.PositionID = "DTSIX_1137_S3"
			elseIf (stageNumber == 4)
				ssStruct.FAnimFormID = 0x09003D81
				ssStruct.MAnimFormID = 0x09003D82
				ssStruct.PositionOrigID = "RZ_SexBehindChairTender04"
				ssStruct.PositionID = "DTSIX_1137_S4"
			elseIf (stageNumber == 5)
				ssStruct.FAnimFormID = 0x09003D81
				ssStruct.MAnimFormID = 0x09003D82
				ssStruct.PositionOrigID = "RZ_SexBehindChairTender05"
				ssStruct.PositionID = "DTSIX_1137_S5"
			else
				ssStruct.FAnimFormID = 0x09003D83
				ssStruct.MAnimFormID = 0x09003D84
				ssStruct.PositionOrigID = "RZ_SexBehindChairTender05"
				ssStruct.PositionID = "DTSIX_1137_S5"
			endIf
		elseIf (seqID == 1148)
			
			ssStruct.FAnimFormID = 0x090026A6					; sit on face rev
			ssStruct.MAnimFormID = 0x090026AB
			ssStruct.PositionOrigID = "RZ_RevCowgirlGroundTender01"
			ssStruct.PositionID = "DTSIX_1106_S0"
			ssStruct.StageTime = 24.0
			
		elseIf (seqID == 1149)
			if (stageNumber == 0)					; skip female standing
				ssStruct.FAnimFormID = 0x0900269C
				ssStruct.MAnimFormID = 0x090026A1
				ssStruct.PositionOrigID = "RZ_FaceSittingTender01"
				ssStruct.PositionID = "DTSIX_1149_S1"
				ssStruct.MAngleOffset = 180.0
			elseIf (stageNumber == 1)
				ssStruct.FAnimFormID = 0x0900269D
				ssStruct.MAnimFormID = 0x090026A2
				ssStruct.PositionOrigID = "RZ_FaceSittingTender02"
				ssStruct.PositionID = "DTSIX_1149_S2"
				ssStruct.MAngleOffset = 180.0
			elseIf (stageNumber == 2)
				ssStruct.FAnimFormID = 0x0900269E
				ssStruct.MAnimFormID = 0x090026A3
				ssStruct.PositionOrigID = "RZ_FaceSittingTender03"
				ssStruct.PositionID = "DTSIX_1149_S3"
				ssStruct.MAngleOffset = 180.0
			elseIf (stageNumber == 3)
				ssStruct.FAnimFormID = 0x0900269F
				ssStruct.MAnimFormID = 0x090026A4
				ssStruct.PositionOrigID = "RZ_FaceSittingTender04"
				ssStruct.PositionID = "DTSIX_1149_S4"
				ssStruct.MAngleOffset = 180.0
			else
				ssStruct.FAnimFormID = 0x090026A0
				ssStruct.MAnimFormID = 0x090026A5
				ssStruct.PositionOrigID = "RZ_FaceSittingTender05"
				ssStruct.PositionID = "DTSIX_1149_S5"
				ssStruct.MAngleOffset = 180.0
			endIf
		elseIf (seqID == 1150)
			if (stageNumber == 1)
				ssStruct.FAnimFormID = 0x09001ED7
				ssStruct.MAnimFormID = 0x09001ED8
				ssStruct.PositionOrigID = "RZ_BJGroundTender01"
				ssStruct.PositionID = "DTSIX_1150_S1"
				ssStruct.MAngleOffset = 180.0
			elseIf (stageNumber == 2)
				ssStruct.FAnimFormID = 0x09001ED9
				ssStruct.MAnimFormID = 0x09001EDA
				ssStruct.PositionOrigID = "RZ_BJGroundTender02"
				ssStruct.PositionID = "DTSIX_1150_S2"
				ssStruct.MAngleOffset = 180.0
			elseIf (stageNumber == 3)
				ssStruct.FAnimFormID = 0x09001EDB
				ssStruct.MAnimFormID = 0x09001EDC
				ssStruct.PositionOrigID = "RZ_BJGroundTender03"
				ssStruct.PositionID = "DTSIX_1150_S3"
				ssStruct.MAngleOffset = 180.0
			elseIf (stageNumber == 4)
				ssStruct.FAnimFormID = 0x09001EDD
				ssStruct.MAnimFormID = 0x09001EDE
				ssStruct.PositionOrigID = "RZ_BJGroundTender04"
				ssStruct.PositionID = "DTSIX_1150_S4"
				ssStruct.MAngleOffset = 180.0
			else
				ssStruct.FAnimFormID = 0x09001EDF
				ssStruct.MAnimFormID = 0x09001EE0
				ssStruct.PositionOrigID = "RZ_BJGroundTender05"
				ssStruct.PositionID = "DTSIX_1150_S5"
				ssStruct.MAngleOffset = 180.0
			endIf
		elseIf (seqID == 1152)								; no repeat stages
			if (stageNumber == 1)
				ssStruct.FAnimFormID = 0x0900F51D
				ssStruct.MAnimFormID = 0x0900F51E
				ssStruct.PositionOrigID = "RZ_MedicalGroundTender01"
				ssStruct.PositionID = "DTSIX_1152_S1"
				ssStruct.MAngleOffset = 180.0
			elseIf (stageNumber == 2)
				ssStruct.FAnimFormID = 0x0900F51F
				ssStruct.MAnimFormID = 0x0900F520
				ssStruct.PositionOrigID = "RZ_MedicalGroundTender02"
				ssStruct.PositionID = "DTSIX_1152_S2"
				ssStruct.MAngleOffset = 180.0
				ssStruct.StageTime = 9.0
			elseIf (stageNumber == 3)
				ssStruct.FAnimFormID = 0x0900F521
				ssStruct.MAnimFormID = 0x0900F522
				ssStruct.PositionOrigID = "RZ_MedicalGroundTender03"
				ssStruct.PositionID = "DTSIX_1152_S3"
				ssStruct.MAngleOffset = 180.0
			else
				ssStruct.FAnimFormID = 0x0900F523		; fingering
				ssStruct.MAnimFormID = 0x0900F524
				ssStruct.PositionOrigID = "RZ_MedicalGroundTender04"
				ssStruct.PositionID = "DTSIX_1152_S4"
				ssStruct.MAngleOffset = 180.0
				ssStruct.StageTime = 15.0
			endIf
		elseIf (seqID == 1153)								; do not repeat stages
			if (stageNumber == 1)
				ssStruct.FAnimFormID = 0x09006B71
				ssStruct.MAnimFormID = 0x09006B72
				ssStruct.PositionOrigID = "RZ_SecSearchGroundTender01"
				ssStruct.PositionID = "DTSIX_1153_S1"
				ssStruct.MAngleOffset = 180.0
				ssStruct.ArmorNudeAGun = -1
			elseIf (stageNumber == 2)
				ssStruct.FAnimFormID = 0x09006B73			; open mouth??? works okay without
				ssStruct.MAnimFormID = 0x09006B74
				ssStruct.PositionOrigID = "RZ_SecSearchGroundTender02"
				ssStruct.PositionID = "DTSIX_1153_S2"
				ssStruct.MAngleOffset = 180.0
				ssStruct.ArmorNudeAGun = -1
			elseIf (stageNumber == 3)
				ssStruct.FAnimFormID = 0x09006B75			
				ssStruct.MAnimFormID = 0x09006B76
				ssStruct.PositionOrigID = "RZ_SecSearchGroundTender03"
				ssStruct.PositionID = "DTSIX_1153_S3"
				ssStruct.MAngleOffset = 180.0
				ssStruct.ArmorNudeAGun = -1
			else
				ssStruct.FAnimFormID = 0x09006B7B			
				ssStruct.MAnimFormID = 0x09006B7C
				ssStruct.PositionOrigID = "RZ_SecSearchGroundTender06"
				ssStruct.PositionID = "DTSIX_1153_S4"
				ssStruct.MAngleOffset = 180.0
				ssStruct.ArmorNudeAGun = -1
			endIf
		elseIf (seqID == 1154)
			if (stageNumber == 1)
				ssStruct.FAnimFormID = 0x0900F513
				ssStruct.MAnimFormID = 0x0900F514
				ssStruct.PositionOrigID = "RZ_GropeGroundTender01"
				ssStruct.PositionID = "DTSIX_1154_S1"
			elseIf (stageNumber == 2)
				ssStruct.FAnimFormID = 0x0900F515
				ssStruct.MAnimFormID = 0x0900F516
				ssStruct.PositionOrigID = "RZ_GropeGroundTender02"
				ssStruct.PositionID = "DTSIX_1154_S2"
			else
				ssStruct.FAnimFormID = 0x0900F519
				ssStruct.MAnimFormID = 0x0900F51A
				ssStruct.PositionOrigID = "RZ_GropeGroundTender04"
				ssStruct.PositionID = "DTSIX_1154_S3"
			endIf
		
		elseIf (seqID == 1155)
			if (stageNumber == 1)
				ssStruct.FAnimFormID = 0x09005452
				ssStruct.MAnimFormID = 0x09005453
				ssStruct.PositionOrigID = "RZ_StandingGroundTender01"
				ssStruct.PositionID = "DTSIX_1155_S1"
			elseIf (stageNumber == 2)
				ssStruct.FAnimFormID = 0x09005454
				ssStruct.MAnimFormID = 0x09005455
				ssStruct.PositionOrigID = "RZ_StandingGroundTender02"
				ssStruct.PositionID = "DTSIX_1155_S2"
			elseIf (stageNumber == 3)
				ssStruct.FAnimFormID = 0x09005456
				ssStruct.MAnimFormID = 0x09005457
				ssStruct.PositionOrigID = "RZ_StandingGroundTender03"
				ssStruct.PositionID = "DTSIX_1155_S3"
			elseIf (stageNumber == 4)
				ssStruct.FAnimFormID = 0x09005458
				ssStruct.MAnimFormID = 0x09005459
				ssStruct.PositionOrigID = "RZ_StandingGroundTender04"
				ssStruct.PositionID = "DTSIX_1155_S4"
			else
				ssStruct.FAnimFormID = 0x0900545A
				ssStruct.MAnimFormID = 0x0900545B
				ssStruct.PositionOrigID = "RZ_StandingGroundTender05"
				ssStruct.PositionID = "DTSIX_1155_S5"
			endIf
		elseIf (seqID == 1162)									; manual & oral  -- do not repeat mid-stages!
			if (stageNumber == 1)
				ssStruct.FAnimFormID = 0x09007328
				ssStruct.MAnimFormID = 0x09007329
				ssStruct.PositionOrigID = "RZ_SexDeskTender01"
				ssStruct.PositionID = "DTSIX_1162_S1"
				ssStruct.MAngleOffset = 180.0
			elseIf (stageNumber == 2)
				ssStruct.FAnimFormID = 0x0900732A
				ssStruct.MAnimFormID = 0x0900732B
				ssStruct.PositionOrigID = "RZ_SexDeskTender02"
				ssStruct.PositionID = "DTSIX_1162_S2"
				ssStruct.MAngleOffset = 180.0
			elseIf (stageNumber == 3)
				ssStruct.FAnimFormID = 0x0900732C
				ssStruct.MAnimFormID = 0x0900732D
				ssStruct.PositionOrigID = "RZ_SexDeskTender03"
				ssStruct.PositionID = "DTSIX_1162_S3"
				ssStruct.MAngleOffset = 180.0
			else
				ssStruct.FAnimFormID = 0x0900732E				; cun
				ssStruct.MAnimFormID = 0x0900732F
				ssStruct.PositionOrigID = "RZ_SexDeskTender04"
				ssStruct.PositionID = "DTSIX_1162_S4"
				ssStruct.StageTime = 12.0
				ssStruct.MAngleOffset = 180.0
			endIf
		elseIf (seqID == 1185)										; kitchen cabinet/counter
			if (stageNumber == 0)									; after stage male slides closer, so skip
				ssStruct.FAnimFormID = 0x09010471
				ssStruct.MAnimFormID = 0x09010472
				ssStruct.PositionOrigID = "RZ_DoggyCounterTender01"
				ssStruct.PositionID = "DTSIX_1185_S1"
			elseIf (stageNumber == 1)
				ssStruct.FAnimFormID = 0x09010473
				ssStruct.MAnimFormID = 0x09010474
				ssStruct.PositionOrigID = "RZ_DoggyCounterTender02"
				ssStruct.PositionID = "DTSIX_1185_S2"
			elseIf (stageNumber == 2)
				ssStruct.FAnimFormID = 0x09010475
				ssStruct.MAnimFormID = 0x09010476
				ssStruct.PositionOrigID = "RZ_DoggyCounterTender03"
				ssStruct.PositionID = "DTSIX_1185_S3"
			elseIf (stageNumber == 3)
				ssStruct.FAnimFormID = 0x09010477
				ssStruct.MAnimFormID = 0x09010478
				ssStruct.PositionOrigID = "RZ_DoggyCounterTender04"
				ssStruct.PositionID = "DTSIX_1185_S4"
			elseIf (stageNumber == 4)
				ssStruct.FAnimFormID = 0x09010479
				ssStruct.MAnimFormID = 0x0901047A
				ssStruct.PositionOrigID = "RZ_DoggyCounterTender05"
				ssStruct.PositionID = "DTSIX_1185_S5"
			else
				ssStruct.FAnimFormID = 0x0901047B
				ssStruct.MAnimFormID = 0x0901047C
				ssStruct.PositionOrigID = "RZ_DoggyCounterTender06"
				ssStruct.PositionID = "DTSIX_1185_S6"
			endIf
			
		elseIf (seqID == 1193)
			if (other > 0)
				; male actors slide around
				ssStruct.ArmorNudeBGun = 1
				
				if (stageNumber == 1)
					ssStruct.FAnimFormID = 0x0900BF6E
					ssStruct.MAnimFormID = 0x0900BF6F
					ssStruct.OAnimFormID = 0x0900BF70
					ssStruct.PositionOrigID = "RZ_Doggy3MWorkbenchTender01"
					ssStruct.PositionID = "DTSIXFMM_1193_S1"
				elseIf (stageNumber == 2)
					ssStruct.FAnimFormID = 0x0900BF72
					ssStruct.MAnimFormID = 0x0900BF73
					ssStruct.OAnimFormID = 0x0900BF74
					ssStruct.PositionOrigID = "RZ_Doggy3MWorkbenchTender02"
					ssStruct.PositionID = "DTSIXFMM_1193_S2"
				elseIf (stageNumber == 3)
					ssStruct.FAnimFormID = 0x0900BF76
					ssStruct.MAnimFormID = 0x0900BF77
					ssStruct.OAnimFormID = 0x0900BF78
					ssStruct.PositionOrigID = "RZ_Doggy3MWorkbenchTender03"
					ssStruct.PositionID = "DTSIXFMM_1193_S3"
				elseIf (stageNumber == 4)
					ssStruct.FAnimFormID = 0x0900BF7A
					ssStruct.MAnimFormID = 0x0900BF7B
					ssStruct.OAnimFormID = 0x0900BF7C
					ssStruct.PositionOrigID = "RZ_Doggy3MWorkbenchTender04"
					ssStruct.PositionID = "DTSIXFMM_1193_S4"
				elseIf (stageNumber == 5)
					ssStruct.FAnimFormID = 0x0900CEB0
					ssStruct.MAnimFormID = 0x0900CEB1
					ssStruct.OAnimFormID = 0x0900CEB2
					ssStruct.PositionOrigID = "RZ_Doggy3MWorkbenchTender05"
					ssStruct.PositionID = "DTSIXFMM_1193_S5"
				elseIf (stageNumber == 6)
					ssStruct.FAnimFormID = 0x0900CEB4
					ssStruct.MAnimFormID = 0x0900CEB5
					ssStruct.OAnimFormID = 0x0900CEB6
					ssStruct.PositionOrigID = "RZ_Doggy3MWorkbenchTender06"
					ssStruct.PositionID = "DTSIXFMM_1193_S6"
				elseIf (stageNumber == 7)
					ssStruct.FAnimFormID = 0x0900CEB8
					ssStruct.MAnimFormID = 0x0900CEB9
					ssStruct.OAnimFormID = 0x0900CEBA
					ssStruct.PositionOrigID = "RZ_Doggy3MWorkbenchTender07"
					ssStruct.PositionID = "DTSIXFMM_1193_S7"
				else
					ssStruct.FAnimFormID = 0x0900CEBC
					ssStruct.MAnimFormID = 0x0900CEBD
					ssStruct.OAnimFormID = 0x0900CEBE
					ssStruct.PositionOrigID = "RZ_Doggy3MWorkbenchTender08"
					ssStruct.PositionID = "DTSIXFMM_1193_S8"
				endIf
			elseIf (stageNumber == 1)
				ssStruct.FAnimFormID = 0x09007318
				ssStruct.MAnimFormID = 0x09007319
				ssStruct.PositionOrigID = "RZ_DoggyWorkbenchTender01"
				ssStruct.PositionID = "DTSIX_1193_S1"
			elseIf (stageNumber == 2)
				ssStruct.FAnimFormID = 0x0900731A
				ssStruct.MAnimFormID = 0x0900731B
				ssStruct.PositionOrigID = "RZ_DoggyWorkbenchTender02"
				ssStruct.PositionID = "DTSIX_1193_S2"
			elseIf (stageNumber == 3)
				ssStruct.FAnimFormID = 0x0900731C
				ssStruct.MAnimFormID = 0x0900731D
				ssStruct.PositionOrigID = "RZ_DoggyWorkbenchTender03"
				ssStruct.PositionID = "DTSIX_1193_S3"
			elseIf (stageNumber == 4)
				ssStruct.FAnimFormID = 0x0900731E
				ssStruct.MAnimFormID = 0x0900731F
				ssStruct.PositionOrigID = "RZ_DoggyWorkbenchTender04"
				ssStruct.PositionID = "DTSIX_1193_S4"
			elseIf (stageNumber == 5)
				ssStruct.FAnimFormID = 0x09007320
				ssStruct.MAnimFormID = 0x09007321
				ssStruct.PositionOrigID = "RZ_DoggyWorkbenchTender05"
				ssStruct.PositionID = "DTSIX_1193_S5"
			else
				ssStruct.FAnimFormID = 0x09007322
				ssStruct.MAnimFormID = 0x09007323
				ssStruct.PositionOrigID = "RZ_DoggyWorkbenchTender06"
				ssStruct.PositionID = "DTSIX_1193_S6"
			endIf
		endIf
		
		
	elseIf (seqID >= 1000)
		ssStruct.PluginName = "rxl_bp70_animations.esp"
		
		if (seqID >= 1000 && seqID <= 1001)							; reviewed
			if (stageNumber == 1)
				ssStruct.FAnimFormID = 0x0900A85C
				ssStruct.MAnimFormID = 0x0900A85D
				ssStruct.PositionOrigID = "BP70 Bed Romantic Missionary 1 (Single Bed)"
				ssStruct.PositionID = "DTSIX_1001_S1"
			elseIf (stageNumber == 2)
				ssStruct.FAnimFormID = 0x0900A85E
				ssStruct.MAnimFormID = 0x0900A85F
				ssStruct.PositionOrigID = "BP70 Bed Romantic Missionary 2 (Single Bed)"
				ssStruct.PositionID = "DTSIX_1001_S2"
			elseIf (stageNumber == 3)
				ssStruct.FAnimFormID = 0x0900A860
				ssStruct.MAnimFormID = 0x0900A861
				ssStruct.PositionOrigID = "BP70 Bed Romantic Missionary 3 (Single Bed)"
				ssStruct.PositionID = "DTSIX_1001_S3"
			elseIf (stageNumber == 4)
				ssStruct.FAnimFormID = 0x0900A862
				ssStruct.MAnimFormID = 0x0900A863
				ssStruct.PositionOrigID = "BP70 Bed Romantic Missionary 4 (Single Bed)"
				ssStruct.PositionID = "DTSIX_1001_S4"
			else
				ssStruct.FAnimFormID = 0x0900A864
				ssStruct.MAnimFormID = 0x0900A865
				ssStruct.PositionOrigID = "BP70 Bed Romantic Missionary 5 (Single Bed)"
				ssStruct.PositionID = "DTSIX_1001_S5"
			endIf
		elseIf (seqID == 1002)									; reviewed
			if (stageNumber == 1)
				ssStruct.FAnimFormID = 0x09015F1D
				ssStruct.MAnimFormID = 0x09015F1E
				ssStruct.PositionOrigID = "BP70 Prone Bone 01"
				ssStruct.PositionID = "DTSIX_1002_S1"
			elseIf (stageNumber == 2)
				ssStruct.FAnimFormID = 0x09015F1F
				ssStruct.MAnimFormID = 0x09015F20
				ssStruct.PositionOrigID = "BP70 Prone Bone 02"
				ssStruct.PositionID = "DTSIX_1002_S2"
			elseIf (stageNumber == 3)
				ssStruct.FAnimFormID = 0x09015F21
				ssStruct.MAnimFormID = 0x09015F22
				ssStruct.PositionOrigID = "BP70 Prone Bone 03"
				ssStruct.PositionID = "DTSIX_1002_S3"
			elseIf (stageNumber == 4)
				ssStruct.FAnimFormID = 0x09015F23
				ssStruct.MAnimFormID = 0x09015F24
				ssStruct.PositionOrigID = "BP70 Prone Bone 04"
				ssStruct.PositionID = "DTSIX_1002_S4"
			endIf
		
		elseIf (seqID == 1003)							; reviewed
			stageNumber += 1
			if (stageNumber == 1)
				ssStruct.FAnimFormID = 0x09005454
				ssStruct.MAnimFormID = 0x09005455
				ssStruct.PositionOrigID = "BP70 Pit Doggy 01"
				ssStruct.PositionID = "DTSIX_1003_S1"
			elseIf (stageNumber == 2)
				ssStruct.FAnimFormID = 0x09005456
				ssStruct.MAnimFormID = 0x09005457
				ssStruct.PositionOrigID = "BP70 Pit Doggy 02"
				ssStruct.PositionID = "DTSIX_1003_S2"
			elseIf (stageNumber == 3)
				ssStruct.FAnimFormID = 0x09005458
				ssStruct.MAnimFormID = 0x09005459
				ssStruct.PositionOrigID = "BP70 Pit Doggy 03"
				ssStruct.PositionID = "DTSIX_1003_S3"
			elseIf (stageNumber == 4)
				ssStruct.FAnimFormID = 0x0900545A
				ssStruct.MAnimFormID = 0x0900545B
				ssStruct.PositionOrigID = "BP70 Pit Doggy 04"
				ssStruct.PositionID = "DTSIX_1003_S4"
			elseIf (stageNumber == 5)
				ssStruct.FAnimFormID = 0x0900545C
				ssStruct.MAnimFormID = 0x0900545D
				ssStruct.PositionOrigID = "BP70 Pit Doggy 05"
				ssStruct.PositionID = "DTSIX_1003_S5"
			elseIf (stageNumber == 6)
				ssStruct.FAnimFormID = 0x0900545E
				ssStruct.MAnimFormID = 0x0900545F
				ssStruct.PositionOrigID = "BP70 Pit Doggy 06"
				ssStruct.PositionID = "DTSIX_1003_S6"
			else
				ssStruct.FAnimFormID = 0x09005460
				ssStruct.MAnimFormID = 0x09005461
				ssStruct.PositionOrigID = "BP70 Pit Doggy 07"
				ssStruct.PositionID = "DTSIX_1003_S7"
			endIf
		elseIf (seqID == 1004)									; poor alignment
			ssStruct.FAnimFormID = 0x09000808
			ssStruct.MAnimFormID = 0x09000809
			ssStruct.PositionOrigID = "rBP70 Lotus"
			ssStruct.PositionID = "DTSIX_1004_S1"
			ssStruct.StageTime = 24.0
		elseIf (seqID == 1005)								; reviewed
			ssStruct.FAnimFormID = 0x09000800
			ssStruct.MAnimFormID = 0x09000801
			ssStruct.PositionOrigID = "BP70 Cowgirl"
			ssStruct.PositionID = "DTSIX_1005_S1"
			ssStruct.StageTime = 24.0
		elseIf (seqID == 1006)								; reviewed
			ssStruct.FAnimFormID = 0x09000FAD
			ssStruct.MAnimFormID = 0x09000FAE
			ssStruct.PositionOrigID = "BP70 Romantic Cowgirl"
			ssStruct.PositionID = "DTSIX_1006_S1"
			ssStruct.StageTime = 24.0
			ssStruct.ArmorNudeAGun = 1
			
		elseIf (seqID == 1008)							
						; best without repeat stages
			if (stageNumber == 1)
				ssStruct.FAnimFormID = 0x0900174F			; manual
				ssStruct.MAnimFormID = 0x09001750
				ssStruct.PositionOrigID = "BP70 Mistress 1"
				ssStruct.PositionID = "DTSIX_1008_S1"
				ssStruct.StageTime = 12.0
			elseIf (stageNumber == 2)
				ssStruct.FAnimFormID = 0x09001751			; step on face
				ssStruct.MAnimFormID = 0x09001752
				ssStruct.PositionOrigID = "BP70 Mistress 2"
				ssStruct.PositionID = "DTSIX_1008_S2"
				ssStruct.StageTime = 9.0
			elseIf (stageNumber == 3)
				ssStruct.FAnimFormID = 0x09001753			; sit on face
				ssStruct.MAnimFormID = 0x09001754
				ssStruct.PositionOrigID = "BP70 Mistress 3"
				ssStruct.PositionID = "DTSIX_1008_S3"
				; use custom time
			elseIf (stageNumber == 4)
				ssStruct.FAnimFormID = 0x09001755		; cowgirl 
				ssStruct.MAnimFormID = 0x09001756
				ssStruct.PositionOrigID = "BP70 Mistress 4"
				ssStruct.PositionID = "DTSIX_1008_S4"
				ssStruct.StageTime = 12.0
			endIf
		; spoon
		elseIf (seqID == 1010)					; reviewed bed
			if (stageNumber == 1)
				ssStruct.FAnimFormID = 0x0900FC66
				ssStruct.MAnimFormID = 0x0900FC67
				ssStruct.PositionOrigID = "BP70 Spooning 01"
				ssStruct.PositionID = "DTSIX_1010_S1"
			elseIf (stageNumber == 2)
				ssStruct.FAnimFormID = 0x0900FC68
				ssStruct.MAnimFormID = 0x0900FC69
				ssStruct.PositionOrigID = "BP70 Spooning 02"
				ssStruct.PositionID = "DTSIX_1010_S2"
			elseIf (stageNumber == 3)
				ssStruct.FAnimFormID = 0x0900FC6A
				ssStruct.MAnimFormID = 0x0900FC6B
				ssStruct.PositionOrigID = "BP70 Spooning 03"
				ssStruct.PositionID = "DTSIX_1010_S3"
			elseIf (stageNumber == 4)
				ssStruct.FAnimFormID = 0x0900FC6C
				ssStruct.MAnimFormID = 0x0900FC6D
				ssStruct.PositionOrigID = "BP70 Spooning 04"
				ssStruct.PositionID = "DTSIX_1010_S4"
			elseIf (stageNumber == 5)
				ssStruct.FAnimFormID = 0x0900FC6E
				ssStruct.MAnimFormID = 0x0900FC6F
				ssStruct.PositionOrigID = "BP70 Spooning Orgasm (loop)"
				ssStruct.PositionID = "DTSIX_1010_S5"
			endIf
		; other bed/floor
		elseIf (seqID == 1012)
			ssStruct.FAnimFormID = 0x0900C6A4
			ssStruct.MAnimFormID = 0x0900C6A5
			ssStruct.PositionOrigID = "P70 Lesbian Footplay"
			ssStruct.PositionID = "DTSIXFF_1012_S1"
			ssStruct.StageTime = 24.0
			
		elseIf (seqID == 1013)						; reviewed single-bed
			ssStruct.FAnimFormID = 0x0900C6A6
			ssStruct.MAnimFormID = 0x0900C6A7
			ssStruct.PositionOrigID = "BP70 Lesbian Scissor"
			ssStruct.PositionID = "DTSIXFF_1013_S1"
			ssStruct.StageTime = 24.0
		elseIf (seqID == 1014)
			ssStruct.FAnimFormID = 0x09007A5E
			ssStruct.MAnimFormID = 0x09007A5F
			ssStruct.PositionOrigID = "BP70 Lesbian Cycling"
			ssStruct.PositionID = "DTSIXFF_1014_S1"
			ssStruct.StageTime = 24.0
			
		; require bed
		elseIf (seqID == 1019)											; reviewed
			ssStruct.FAnimFormID = 0x09005BDD
			ssStruct.MAnimFormID = 0x09005BDE
			ssStruct.PositionOrigID = "BP70 Pre-War Bed After Sex Relax"		; double bed cuddle
			ssStruct.PositionID = "DTSIX_1019_S1"
			ssStruct.StageTime = 24.0
		elseIf (seqID == 1020)												; spanking - reviewed
			ssStruct.FAnimFormID = 0x0900DD90
			ssStruct.MAnimFormID = 0x0900DD91
			ssStruct.PositionOrigID = "BP70 Bed Female Body Worship"	
			ssStruct.PositionID = "DTSIX_1020_S1"
			ssStruct.StageTime = 24.0
			ssStruct.MPosYOffset = -12.0
		elseIf (seqID == 1021)												; reviewed
			if (stageNumber == 1)
				ssStruct.FAnimFormID = 0x0901674F
				ssStruct.MAnimFormID = 0x09016750
				ssStruct.PositionOrigID = "BP70 Pre-War Bed Pussy Play 1"	; doublebed oral
				ssStruct.PositionID = "DTSIX_1021_S1"
			elseIf (stageNumber == 2)
				ssStruct.FAnimFormID = 0x09016751
				ssStruct.MAnimFormID = 0x09016752
				ssStruct.PositionOrigID = "BP70 Pre-War Bed Pussy Play 2"
				ssStruct.PositionID = "DTSIX_1021_S2"
			elseIf (stageNumber == 3)
				ssStruct.FAnimFormID = 0x09016753
				ssStruct.MAnimFormID = 0x09016754
				ssStruct.PositionOrigID = "BP70 Pre-War Bed Pussy Play 3"
				ssStruct.PositionID = "DTSIX_1021_S3"
			elseIf (stageNumber == 4)
				ssStruct.FAnimFormID = 0x09016755
				ssStruct.MAnimFormID = 0x09016756
				ssStruct.PositionOrigID = "BP70 Pre-War Bed Pussy Play 4"
				ssStruct.PositionID = "DTSIX_1021_S4"
			endIf
			
		; chair, sofa
		elseIf (seqID == 1030)								; bench

			if (stageNumber == 1)
				ssStruct.FAnimFormID = 0x0900E52E
				ssStruct.MAnimFormID = 0x0900E52F
				ssStruct.PositionOrigID = "BP70 Shaun's Conception 1"			; oral/manual - no shoes!!!
				ssStruct.PositionID = "DTSIX_1030_S1"
			elseIf (stagenumber == 2)
				ssStruct.FAnimFormID = 0x0900E530
				ssStruct.MAnimFormID = 0x0900E531
				ssStruct.PositionOrigID = "BP70 Shaun's Conception 2"
				ssStruct.PositionID = "DTSIX_1030_S2"
			elseIf (stagenumber == 3)
				ssStruct.FAnimFormID = 0x0900E532
				ssStruct.MAnimFormID = 0x0900E533
				ssStruct.PositionOrigID = "BP70 Shaun's Conception 3"
				ssStruct.PositionID = "DTSIX_1030_S3"
			elseIf (stagenumber == 4)
				ssStruct.FAnimFormID = 0x0900CE50
				ssStruct.MAnimFormID = 0x0900CE51
				ssStruct.PositionOrigID = "BP70 Shaun's Conception 4"
				ssStruct.PositionID = "DTSIX_1030_S4"
			elseIf (stagenumber == 5)
				ssStruct.FAnimFormID = 0x0900E534
				ssStruct.MAnimFormID = 0x0900E535
				ssStruct.PositionOrigID = "BP70 Shaun's Conception 5"
				ssStruct.PositionID = "DTSIX_1030_S5"
			endIf
			
		elseIf (seqID == 1035)							; Chair-high missionary
			ssStruct.FAnimFormID = 0x0900543A
			ssStruct.MAnimFormID = 0x0900543B
			ssStruct.PositionOrigID = "BP70 Armchair Missionary"
			ssStruct.PositionID = "DTSIX_1035_S1"
			ssStruct.StageTime = 24.0
		elseIf (seqID == 1036)							; Chair-high cowgirl
			ssStruct.FAnimFormID = 0x0900543C
			ssStruct.MAnimFormID = 0x0900543D
			ssStruct.PositionOrigID = "BP70 Armchair Cowgirl"
			ssStruct.PositionID = "DTSIX_1036_S1"
			ssStruct.StageTime = 24.0
		elseIf (seqID == 1037)							; Chair-high oral
			if (stageNumber == 1)
				ssStruct.StageTime = 7.5
				ssStruct.FAnimFormID = 0x0900547A
				ssStruct.MAnimFormID = 0x0900547C
				ssStruct.PositionOrigID = "BP70 Armchair Cunnilingus 01"
				ssStruct.PositionID = "DTSIX_1037_S1"
			elseIf (stageNumber == 2)
				ssStruct.FAnimFormID = 0x0900547D
				ssStruct.MAnimFormID = 0x0900547E
				ssStruct.PositionOrigID = "BP70 Armchair Cunnilingus 02"
				ssStruct.PositionID = "DTSIX_1037_S2"
			elseIf (stageNumber == 3)
				ssStruct.FAnimFormID = 0x0900547F
				ssStruct.MAnimFormID = 0x09005480
				ssStruct.PositionOrigID = "BP70 Armchair Cunnilingus 03"
				ssStruct.PositionID = "DTSIX_1037_S3"
			elseIf (stageNumber == 4)
				ssStruct.FAnimFormID = 0x09005481
				ssStruct.MAnimFormID = 0x09005482
				ssStruct.PositionOrigID = "BP70 Armchair Cunnilingus 04"
				ssStruct.PositionID = "DTSIX_1037_S4"
			elseIf (stageNumber == 5)
				ssStruct.StageTime = 13.0
				ssStruct.FAnimFormID = 0x09005483
				ssStruct.MAnimFormID = 0x09005484
				ssStruct.PositionOrigID = "BP70 Armchair Cunnilingus 05"
				ssStruct.PositionID = "DTSIX_1037_S5"
			endIf
		
		elseIf (seqID == 1039)							; couch blowjob  - reviewed
			if (stageNumber == 1)
				ssStruct.FAnimFormID = 0x0900A07B
				ssStruct.MAnimFormID = 0x0900A07C
				ssStruct.PositionOrigID = "BP70 Couch Blowjob 1"
				ssStruct.PositionID = "DTSIX_1039_S1"
			elseIf (stageNumber == 2)
				ssStruct.FAnimFormID = 0x0900A07D
				ssStruct.MAnimFormID = 0x0900A07E
				ssStruct.PositionOrigID = "BP70 Couch Blowjob 2"
				ssStruct.PositionID = "DTSIX_1039_S2"
			elseIf (stageNumber == 3)
				ssStruct.FAnimFormID = 0x0900A07F
				ssStruct.MAnimFormID = 0x0900A080
				ssStruct.PositionOrigID = "BP70 Couch Blowjob 3"
				ssStruct.PositionID = "DTSIX_1039_S3"
			elseIf (stageNumber == 4)
				ssStruct.FAnimFormID = 0x0900A081
				ssStruct.MAnimFormID = 0x0900A082
				ssStruct.PositionOrigID = "BP70 Couch Blowjob 4"
				ssStruct.PositionID = "DTSIX_1039_S4"
			elseIf (stageNumber == 5)
				ssStruct.FAnimFormID = 0x0900A083
				ssStruct.MAnimFormID = 0x0900A084
				ssStruct.PositionOrigID = "BP70 Couch Blowjob Orgasm (Loop)"
				ssStruct.PositionID = "DTSIX_1039_S5"
			endIf
		elseIf (seqID == 1040)							; couch cowgirl -reviewed
			if (stageNumber == 1)
				ssStruct.FAnimFormID = 0x09011B09
				ssStruct.MAnimFormID = 0x09011B0A
				ssStruct.PositionOrigID = "BP70 Couch Cowgirl 1"
				ssStruct.PositionID = "DTSIX_1040_S1"
			elseIf (stageNumber == 2)
				ssStruct.FAnimFormID = 0x09011B0B
				ssStruct.MAnimFormID = 0x09011B0C
				ssStruct.PositionOrigID = "BP70 Couch Cowgirl 2"
				ssStruct.PositionID = "DTSIX_1040_S2"
			elseIf (stageNumber == 3)
				ssStruct.FAnimFormID = 0x09011B0D
				ssStruct.MAnimFormID = 0x09011B0E
				ssStruct.PositionOrigID = "BP70 Couch Cowgirl 3"
				ssStruct.PositionID = "DTSIX_1040_S3"
			elseIf (stageNumber == 4)
				ssStruct.FAnimFormID = 0x09011B0F
				ssStruct.MAnimFormID = 0x09011B10
				ssStruct.PositionOrigID = "BP70 Couch Cowgirl 4"
				ssStruct.PositionID = "DTSIX_1040_S4"
			elseIf (stageNumber == 5)
				ssStruct.FAnimFormID = 0x09011B11
				ssStruct.MAnimFormID = 0x09011B12
				ssStruct.PositionOrigID = "BP70 Couch Cowgirl 5"
				ssStruct.PositionID = "DTSIX_1040_S5"
			endIf
		elseIf (seqID == 1041)							; couch doggy -- leans over backside possibly hitting wall
			if (stageNumber == 1)
				ssStruct.FAnimFormID = 0x090112F8
				ssStruct.MAnimFormID = 0x090112F9
				ssStruct.PositionOrigID = "BP70 Couch Doggy 1"
				ssStruct.PositionID = "DTSIX_1041_S1"
			elseIf (stageNumber == 2)
				ssStruct.FAnimFormID = 0x090112FA
				ssStruct.MAnimFormID = 0x090112FB
				ssStruct.PositionOrigID = "BP70 Couch Doggy 2"
				ssStruct.PositionID = "DTSIX_1041_S2"
			elseIf (stageNumber == 3)
				ssStruct.FAnimFormID = 0x090112FC
				ssStruct.MAnimFormID = 0x090112FD
				ssStruct.PositionOrigID = "BP70 Couch Doggy 3"
				ssStruct.PositionID = "DTSIX_1041_S3"
			elseIf (stageNumber == 4)
				ssStruct.FAnimFormID = 0x090112FE
				ssStruct.MAnimFormID = 0x090112FF
				ssStruct.PositionOrigID = "BP70 Couch Doggy 4"
				ssStruct.PositionID = "DTSIX_1041_S4"
			elseIf (stageNumber == 5)
				ssStruct.FAnimFormID = 0x09011300
				ssStruct.MAnimFormID = 0x09011301
				ssStruct.PositionOrigID = "BP70 Couch Doggy 5"
				ssStruct.PositionID = "DTSIX_1041_S5"
			endIf
		elseIf (seqID == 1042)							; couch (long) missionary  - reviewed
			if (stageNumber == 1)
				ssStruct.FAnimFormID = 0x090035C4
				ssStruct.MAnimFormID = 0x090035C5
				ssStruct.PositionOrigID = "BP70 Couch Missionary 1"
				ssStruct.PositionID = "DTSIX_1042_S1"
			elseIf (stageNumber == 2)
				ssStruct.FAnimFormID = 0x090035C6
				ssStruct.MAnimFormID = 0x090035C7
				ssStruct.PositionOrigID = "BP70 Couch Missionary 2"
				ssStruct.PositionID = "DTSIX_1042_S2"
			elseIf (stageNumber == 3)
				ssStruct.FAnimFormID = 0x090035CA
				ssStruct.MAnimFormID = 0x090035CB
				ssStruct.PositionOrigID = "BP70 Couch Missionary 3"
				ssStruct.PositionID = "DTSIX_1042_S3"
			elseIf (stageNumber == 4)
				ssStruct.FAnimFormID = 0x090035CC
				ssStruct.MAnimFormID = 0x090035CD
				ssStruct.PositionOrigID = "BP70 Couch Missionary 4"
				ssStruct.PositionID = "DTSIX_1042_S4"
			elseIf (stageNumber == 5)
				ssStruct.FAnimFormID = 0x090035CE
				ssStruct.MAnimFormID = 0x090035CF
				ssStruct.PositionOrigID = "BP70 Couch Missionary 5"
				ssStruct.PositionID = "DTSIX_1042_S5"
			endIf
			
			; oral/manual bed/floor
		elseIf (seqID == 1047)						; FF-OK reviewed double-bed, picnick table, single(foot hangs over)
			ssStruct.FAnimFormID = 0x0900638B
			ssStruct.MAnimFormID = 0x0900638C
			ssStruct.PositionOrigID = "BP70 Leg Wrap Cunnilingus"
			ssStruct.PositionID = "DTSIX_1047_S1"
			ssStruct.StageTime = 24.0
		elseIf (seqID == 1048)						; reviewed double-bed
			ssStruct.FAnimFormID = 0x09007A63
			ssStruct.MAnimFormID = 0x09007A64
			ssStruct.PositionOrigID = "BP70 Laying Blowjob"
			ssStruct.PositionID = "DTSIX_1048_S1"
			ssStruct.StageTime = 24.0
		elseIf (seqID == 1049)							; MF-only reviwed double-bed
			ssStruct.FAnimFormID = 0x09000FB3
			ssStruct.MAnimFormID = 0x09000FB4
			ssStruct.PositionOrigID = "BP70 Cunnilingus"
			ssStruct.PositionID = "DTSIX_1049_S1"
			ssStruct.StageTime = 24.0
			ssStruct.ArmorNudeAGun = 1
			
		; standing oral/manual (50-51)
		elseIf (seqID == 1050)
			ssStruct.FAnimFormID = 0x09006389
			ssStruct.MAnimFormID = 0x0900638A
			ssStruct.PositionOrigID = "BP70 Blowjob"
			ssStruct.PositionID = "DTSIX_1050_S1"
			ssStruct.StageTime = 24.0
			ssStruct.FAngleOffset = 180.0
		elseIf (seqID == 1051)							; shakes on floor bed
			ssStruct.FAnimFormID = 0x0901038F
			ssStruct.MAnimFormID = 0x09010390
			ssStruct.PositionOrigID = "BP70 Standing 69"
			ssStruct.PositionID = "DTSIX_1051_S1"
			ssStruct.StageTime = 24.0
			ssStruct.FAngleOffset = 180.0

		; standing doggy (52-53), standing carry (54-55)
		elseIf (seqID == 1054)										; reviewed
			if (stageNumber == 1)
				ssStruct.FAnimFormID = 0x090098D1
				ssStruct.MAnimFormID = 0x090098D2
				ssStruct.PositionOrigID = "BP70 Standing Sequence Stage 1"
				ssStruct.PositionID = "DTSIX_1054_S1"
			elseIf (stageNumber == 2)
				ssStruct.FAnimFormID = 0x090098D3
				ssStruct.MAnimFormID = 0x090098D4
				ssStruct.PositionOrigID = "BP70 Standing Sequence Stage 2"
				ssStruct.PositionID = "DTSIX_1054_S2"
			elseIf (stageNumber == 3)
				ssStruct.FAnimFormID = 0x090098D5
				ssStruct.MAnimFormID = 0x090098D6
				ssStruct.PositionOrigID = "BP70 Standing Sequence Stage 3"
				ssStruct.PositionID = "DTSIX_1054_S3"
			elseIf (stageNumber == 4)
				ssStruct.FAnimFormID = 0x090098D7
				ssStruct.MAnimFormID = 0x090098D8
				ssStruct.PositionOrigID = "BP70 Standing Sequence Stage 4"
				ssStruct.PositionID = "DTSIX_1054_S5"
			endIf
			
		; masturbation solo 60-69
		elseIf (seqID == 1060)					; single bed
			ssStruct.FAnimFormID = 0x090035E5
			ssStruct.MAnimFormID = 0x090035E6
			ssStruct.PositionOrigID = ""
			ssStruct.PositionID = "DTSIX_1060_S1"
			ssStruct.StageTime = 24.0
		elseIf (seqID == 1061)					; couch
			ssStruct.FAnimFormID = 0x09012241
			ssStruct.MAnimFormID = 0x09012242
			ssStruct.PositionOrigID = ""
			ssStruct.PositionID = "DTSIX_1061_S1"
			ssStruct.StageTime = 24.0
		
		; other furniture
		
		elseIf (seqID == 1070)			; locker
			if (stageNumber == 1)
				ssStruct.FAnimFormID = 0x0900DDDF
				ssStruct.MAnimFormID = 0x0900DDE0
				ssStruct.PositionOrigID = "BP70 Locker Sex 1"
				ssStruct.PositionID = "DTSIX_1070_S1"
			elseIf (stageNumber == 2)
				ssStruct.FAnimFormID = 0x0900DDE1
				ssStruct.MAnimFormID = 0x0900DDE2
				ssStruct.PositionOrigID = "BP70 Locker Sex 2"
				ssStruct.PositionID = "DTSIX_1070_S2"
			elseIf (stageNumber == 3)
				ssStruct.FAnimFormID = 0x0900DDE3
				ssStruct.MAnimFormID = 0x0900DDE4
				ssStruct.PositionOrigID = "BP70 Locker Sex 3"
				ssStruct.PositionID = "DTSIX_1070_S3"
			elseIf (stageNumber == 4)
				ssStruct.FAnimFormID = 0x0900DDE5
				ssStruct.MAnimFormID = 0x0900DDE6
				ssStruct.PositionOrigID = "BP70 Locker Sex 4"
				ssStruct.PositionID = "DTSIX_1070_S4"
			elseIf (stageNumber == 5)
				ssStruct.FAnimFormID = 0x0900DDE7
				ssStruct.MAnimFormID = 0x0900DDE8
				ssStruct.PositionOrigID = "BP70 Locker Sex 5"
				ssStruct.PositionID = "DTSIX_1070_S5"
			endIf
			
			
		; MM floor/bed
		elseIf (seqID == 1085) 					; doggy
			if (stageNumber == 1)
				ssStruct.FAnimFormID = 0x09017D9C
				ssStruct.MAnimFormID = 0x09015F1E
				ssStruct.PositionOrigID = "BP70 Gay Prone Bone 01"
				ssStruct.PositionID = "DTSIXMM_1090_S1"
			elseIf (stageNumber == 2)
				ssStruct.FAnimFormID = 0x09017D9D
				ssStruct.MAnimFormID = 0x09017D93
				ssStruct.PositionOrigID = "BP70 Gay Prone Bone 02"
				ssStruct.PositionID = "DTSIXMM_1090_S2"
			elseIf (stageNumber == 3)
				ssStruct.FAnimFormID = 0x09017D9E
				ssStruct.MAnimFormID = 0x09017D95
				ssStruct.PositionOrigID = "BP70 Gay Prone Bone 03"
				ssStruct.PositionID = "DTSIXMM_1090_S3"
			elseIf (stageNumber == 4)
				ssStruct.FAnimFormID = 0x09017D9F
				ssStruct.MAnimFormID = 0x09017D97
				ssStruct.PositionOrigID = "BP70 Gay Prone Bone 04"
				ssStruct.PositionID = "DTSIXMM_1090_S4"
			endIf
			
		; kiss, hug (97+)
		elseIf (seqID == 1098)
			ssStruct.FAnimFormID = 0x0900D642
			ssStruct.MAnimFormID = 0x0900D643
			ssStruct.ArmorNudeAGun = -2
			ssStruct.PositionOrigID = "rxl_bp70_kissing"
			ssStruct.PositionID = "DTSIX_1098_S1"
			ssStruct.StageTime = 24.0
		endIf
				
	elseIf (seqID >= 960 && seqID < 1000)
		ssStruct.PluginName = "AAF_CreaturePack01.esp"
		if (seqID == 962)
			if (stageNumber == 1)
				ssStruct.FAnimFormID = 0x090098FB
				ssStruct.MAnimFormID = 0x090098F7
				ssStruct.PositionOrigID = "Mutant Stage 01"
				ssStruct.PositionID = "DTSIXSM_962_S1"

			elseIf (stageNumber == 2)
				ssStruct.FAnimFormID = 0x090098FD
				ssStruct.MAnimFormID = 0x090098F8
				ssStruct.PositionOrigID = "Mutant Stage 02"
				ssStruct.PositionID = "DTSIXSM_962_S2"
				
			elseIf (stageNumber == 3)
				ssStruct.FAnimFormID = 0x090098FE
				ssStruct.MAnimFormID = 0x090098F9
				ssStruct.PositionOrigID = "Mutant Stage 03"
				ssStruct.PositionID = "DTSIXSM_962_S3"
			else
				ssStruct.FAnimFormID = 0x090098FF
				ssStruct.MAnimFormID = 0x090098FA
				ssStruct.PositionOrigID = "Mutant Stage 04"
				ssStruct.PositionID = "DTSIXSM_962_S4"
			endIf
		elseIf (seqID == 963)
			ssStruct.MPosZOffset = -4.1
			ssStruct.MPosYOffset = -1.50
			if (stageNumber == 1)
				ssStruct.FAnimFormID = 0x0900A0A5
				ssStruct.MAnimFormID = 0x0900A099
				ssStruct.PositionOrigID = "Mutant 2 Stage 01"
				ssStruct.PositionID = "DTSIXSM_963_S1"

			elseIf (stageNumber == 2)
				ssStruct.FAnimFormID = 0x0900A0A6
				ssStruct.MAnimFormID = 0x0900A09A
				ssStruct.PositionOrigID = "Mutant 2 Stage 02"
				ssStruct.PositionID = "DTSIXSM_963_S2"
				
			elseIf (stageNumber == 3)
				ssStruct.FAnimFormID = 0x0900A0A7
				ssStruct.MAnimFormID = 0x0900A09B
				;ssStruct.ArmorNudeAGun = 2
				ssStruct.PositionOrigID = "Mutant 2 Stage 03"
				ssStruct.PositionID = "DTSIXSM_963_S3"
			else
				ssStruct.FAnimFormID = 0x0900A0A8
				ssStruct.MAnimFormID = 0x0900A09C
				;ssStruct.ArmorNudeAGun = 2
				ssStruct.PositionOrigID = "Mutant 2 Stage 04"
				ssStruct.PositionID = "DTSIXSM_963_S4"
			endIf
		endIf
	elseIf (seqID >= 900)
		ssStruct.PluginName = "AAF_GrayAnimations.esp"
			
		if (seqID == 901)
			if (stageNumber == 1)
				ssStruct.FAnimFormID = 0x09002677
				if (genders == 1)
					ssStruct.MAnimFormID = 0x0900544D
					ssStruct.PositionOrigID = "Gray_Missionary02FF_S1"
					ssStruct.PositionID = "DTSIXFF_901_S1"
				else
					ssStruct.MAnimFormID = 0x09002678
					ssStruct.PositionOrigID = "Gray_Missionary02_S1"
					ssStruct.PositionID = "DTSIX_901_S1"
				endIf
			elseIf (stageNumber == 2)
				ssStruct.FAnimFormID = 0x09002679
				if (genders == 1)
					ssStruct.MAnimFormID = 0x0900544E
					ssStruct.PositionOrigID = "Gray_Missionary02FF_S2"
					ssStruct.PositionID = "DTSIXFF_901_S2"
				else
					ssStruct.MAnimFormID = 0x0900267A
					ssStruct.PositionOrigID = "Gray_Missionary02_S2"
					ssStruct.PositionID = "DTSIX_901_S2"
				endIf
				
			elseIf (stageNumber == 3)
				ssStruct.FAnimFormID = 0x0900267B
				if (genders == 1)
					ssStruct.MAnimFormID = 0x0900544F
					ssStruct.PositionOrigID = "Gray_Missionary02FF_S3"
					ssStruct.PositionID = "DTSIXFF_901_S3"
				else
					ssStruct.MAnimFormID = 0x0900267C
					ssStruct.PositionOrigID = "Gray_Missionary02_S3"
					ssStruct.PositionID = "DTSIX_901_S3"
				endIf
			else
				ssStruct.FAnimFormID = 0x0900267D
				if (genders == 1)
					ssStruct.MAnimFormID = 0x09005450
					ssStruct.PositionOrigID = "Gray_Missionary02FF_S4"
					ssStruct.PositionID = "DTSIXFF_901_S4"
				else
					ssStruct.MAnimFormID = 0x0900267E
					ssStruct.PositionOrigID = "Gray_Missionary02_S4"
					ssStruct.PositionID = "DTSIX_901_S4"
				endIf
			endIf
		elseIf (seqID == 903)
			if (stageNumber == 1)
				ssStruct.FAnimFormID = 0x0900267F
				if (genders == 1)
					ssStruct.MAnimFormID = 0x09005BEA
					ssStruct.PositionOrigID = "Gray_Doggy01FF_S1"
					ssStruct.PositionID = "DTSIXFF_903_S1"
				else
					ssStruct.MAnimFormID = 0x09002680
					ssStruct.PositionOrigID = "Gray_Doggy01_S1"
					ssStruct.PositionID = "DTSIX_903_S1"
				endIf
			elseIf (stageNumber == 2)
				ssStruct.FAnimFormID = 0x09002681
				if (genders == 1)
					ssStruct.MAnimFormID = 0x09005BEB
					ssStruct.PositionOrigID = "Gray_Doggy01FF_S2"
					ssStruct.PositionID = "DTSIXFF_903_S2"
				else
					ssStruct.MAnimFormID = 0x09002682
					ssStruct.PositionOrigID = "Gray_Doggy01_S2"
					ssStruct.PositionID = "DTSIX_903_S2"
				endIf
			elseIf (stageNumber == 3)
				ssStruct.FAnimFormID = 0x09002683
				if (genders == 1)
					ssStruct.MAnimFormID = 0x09005BEC
					ssStruct.PositionOrigID = "Gray_Doggy01FF_S3"
					ssStruct.PositionID = "DTSIXFF_903_S3"
				else
					ssStruct.MAnimFormID = 0x09002684
					ssStruct.PositionOrigID = "Gray_Doggy01_S3"
					ssStruct.PositionID = "DTSIX_903_S3"
				endIf
			else
				ssStruct.FAnimFormID = 0x09002685
				if (genders == 1)
					ssStruct.MAnimFormID = 0x09005BED
					ssStruct.PositionOrigID = "Gray_Doggy01FF_S4"
					ssStruct.PositionID = "DTSIXFF_903_S4"
				else
					ssStruct.MAnimFormID = 0x09002686
					ssStruct.PositionOrigID = "Gray_Doggy01_S4"
					ssStruct.PositionID = "DTSIX_903_S4"
				endIf
			endIf
		elseIf (seqID == 940)										; F solo
			if (stageNumber == 1)
				ssStruct.MAnimFormID = 0x090063A7
				ssStruct.FAnimFormID = 0x090063A7
				ssStruct.PositionOrigID = "Gray_Bent_m"
				ssStruct.PositionID = "DTSIXF_940_S1"
			elseIf (stageNumber == 2)
				ssStruct.MAnimFormID = 0x090063B0
				ssStruct.FAnimFormID = 0x090063B0
				ssStruct.PositionOrigID = "Gray_Facedown_m"
				ssStruct.PositionID = "DTSIXF_940_S2"
			elseIf (stageNumber == 3)
				ssStruct.MAnimFormID = 0x09005C02
				ssStruct.FAnimFormID = 0x09005C02
				ssStruct.PositionOrigID = "Gray_Hogtie_m"
				ssStruct.PositionID = "DTSIXF_940_S3"
			else
				ssStruct.MAnimFormID = 0x090063B9
				ssStruct.FAnimFormID = 0x090063B9
				ssStruct.PositionOrigID = "Gray_Side_m"
				ssStruct.PositionID = "DTSIXF_940_S4"
			endIf
		elseIf (seqID == 947)										; spanking
			ssStruct.ArmorNudeAGun = 1
			if (stageNumber == 1)
				ssStruct.MAnimFormID = 0x09002690
				ssStruct.FAnimFormID = 0x0900268F
				ssStruct.PositionOrigID = "Gray_Spanking02_S1"
				ssStruct.PositionID = "DTSIX_947_S1"
			elseIf (stageNumber == 2)
				ssStruct.MAnimFormID = 0x09002692
				ssStruct.FAnimFormID = 0x09002691
				ssStruct.PositionOrigID = "Gray_Spanking02_S2"
				ssStruct.PositionID = "DTSIX_947_S2"
			elseIf (stageNumber == 3)
				ssStruct.MAnimFormID = 0x09002694
				ssStruct.FAnimFormID = 0x09002693
				ssStruct.PositionOrigID = "Gray_Spanking02_S3"
				ssStruct.PositionID = "DTSIX_947_S3"
			else
				ssStruct.MAnimFormID = 0x09002696
				ssStruct.FAnimFormID = 0x09002695
				ssStruct.PositionOrigID = "Gray_Spanking02_S4"
				ssStruct.PositionID = "DTSIX_947_S4"
			endIf
		endIf
	
	elseIf (seqID >= 800)
		ssStruct.PluginName = "ZaZOut4.esp"
		if (seqID >= 849 && seqID <= 850)
			
			ssStruct.MAngleOffset = 180.0
			ssStruct.MPosYOffset = -1.0
			
			if (stageNumber == 1)
				if (seqID == 849)  					
					ssStruct.MAnimFormID = 0x05004503
					ssStruct.FAnimFormID = 0x05004504
					ssStruct.ArmorNudeAGun = 0
					ssStruct.PositionOrigID = "PilloryOral_BJ-00"
					ssStruct.PositionID = "DTSIX_849_S1"
				else
					ssStruct.MAnimFormID = 0x050035C7	
					ssStruct.FAnimFormID = 0x050035C8
					ssStruct.ArmorNudeAGun = 1
					ssStruct.PositionOrigID = "PilloryOral_BJ-02"
					ssStruct.PositionID = "DTSIX_850_S1"
				endIf
			elseIf (stageNumber == 2)	
				if (seqID == 849)						
					ssStruct.MAnimFormID = 0x05003D84
					ssStruct.FAnimFormID = 0x05003D85
					ssStruct.StageTime = 6.4
					ssStruct.PositionOrigID = "PilloryOral_BJ-03_TR"
					ssStruct.PositionID = "DTSIX_849_S2"
				else
					ssStruct.MAnimFormID = 0x050035C9
					ssStruct.FAnimFormID = 0x050035CA
					ssStruct.ArmorNudeAGun = 1
					ssStruct.PositionOrigID = "PilloryOral_BJ-03"
					ssStruct.PositionID = "DTSIX_850_S2"
				endIf
			elseIf (stageNumber == 3)
				ssStruct.MAnimFormID = 0x05003D65
				ssStruct.FAnimFormID = 0x05003D66
				ssStruct.PositionOrigID = "PilloryOral_BJ-04"
				ssStruct.PositionID = "DTSIX_849_S3"
			elseIf (stageNumber == 4)
				if (seqID == 849)
					ssStruct.MAnimFormID = 0x05004528
					ssStruct.FAnimFormID = 0x05004529
					ssStruct.StageTime = 6.4
					ssStruct.PositionOrigID = "PilloryOral_BJ-04_TR"
					ssStruct.PositionID = "DTSIX_849_S4"
				else
					ssStruct.MAnimFormID = 0x05004501
					ssStruct.FAnimFormID = 0x05004502
					ssStruct.ArmorNudeAGun = 1
					ssStruct.PositionOrigID = "PilloryOral_BJ-05"
					ssStruct.PositionID = "DTSIX_850_S4"
				endIf
			elseIf (stageNumber == 5)					
				ssStruct.MAnimFormID = 0x05004505
				ssStruct.FAnimFormID = 0x05004506
				ssStruct.PositionOrigID = "PilloryOral_BJ-06"
				ssStruct.PositionID = "DTSIX_849_S5"
			elseIf (stageNumber == 6)				
				ssStruct.MAnimFormID = 0x0500452A
				ssStruct.FAnimFormID = 0x0500452B
				ssStruct.PositionOrigID = "PilloryOral_BJ-07"
				ssStruct.PositionID = "DTSIX_849_S6"
			endIf
		elseIf (seqID == 851)
			if (stageNumber == 1)						
				ssStruct.MAnimFormID = 0x05001EE3
				ssStruct.FAnimFormID = 0x05001EE4
				ssStruct.PositionOrigID = "PillorySex_A-Pussy-00"
				ssStruct.PositionID = "DTSIX_851_S1"
			elseIf (stageNumber == 2)				
				ssStruct.MAnimFormID = 0x05001EE6
				ssStruct.FAnimFormID = 0x05001EE5
				ssStruct.PositionOrigID = "PillorySex_A-Pussy-01"
				ssStruct.PositionID = "DTSIX_851_S2"
			elseIf (stageNumber == 3)
				ssStruct.MAnimFormID = 0x05001EEA
				ssStruct.FAnimFormID = 0x05001EEB
				ssStruct.PositionOrigID = "PillorySex_A-Pussy-02"
				ssStruct.PositionID = "DTSIX_851_S3"
			elseIf (stageNumber == 4)
				ssStruct.MAnimFormID = 0x05002690
				ssStruct.FAnimFormID = 0x05002691
				ssStruct.PositionOrigID = "PillorySex_A-Pussy-03"
				ssStruct.PositionID = "DTSIX_851_S4"
			elseIf (stageNumber == 5)					
				ssStruct.MAnimFormID = 0x05002693
				ssStruct.FAnimFormID = 0x05002694
				ssStruct.PositionOrigID = "PillorySex_A-Pussy-04"
				ssStruct.PositionID = "DTSIX_851_S5"
			elseIf (stageNumber == 6)
				if (longScene > 0)
					ssStruct.MAnimFormID = 0x05002695		
					ssStruct.FAnimFormID = 0x05002696
					ssStruct.PositionOrigID = "PillorySex_A-Pussy-05"
					ssStruct.PositionID = "DTSIX_852_S3"
				else
					ssStruct.MAnimFormID = 0x050026A8		
					ssStruct.FAnimFormID = 0x050026A9
					ssStruct.PositionOrigID = "PillorySex_A-Pussy-08"
					ssStruct.PositionID = "DTSIX_851_S6"
				endIf
			elseIf (stageNumber == 7)
				ssStruct.MAnimFormID = 0x05002699
				ssStruct.FAnimFormID = 0x0500269A
				ssStruct.PositionOrigID = "PillorySex_A-Pussy-06"
				ssStruct.PositionID = "DTSIX_852_S4"
			elseIf (stageNumber == 8)
				ssStruct.MAnimFormID = 0x050026A2
				ssStruct.FAnimFormID = 0x050026A3
				ssStruct.PositionOrigID = "PillorySex_A-Pussy-06_TR"
				ssStruct.PositionID = "DTSIX_852_S5"
				ssStruct.StageTime = 4.0
			elseIf (stageNumber == 9)
				ssStruct.MAnimFormID = 0x050026A4
				ssStruct.FAnimFormID = 0x050026A5
				ssStruct.PositionOrigID = "PillorySex_A-Pussy-07"
				ssStruct.PositionID = "DTSIX_852_S6"
			elseIf (stageNumber == 10)
				ssStruct.MAnimFormID = 0x050026A6
				ssStruct.FAnimFormID = 0x050026A7
				ssStruct.StageTime = 2.0
				ssStruct.PositionOrigID = "PillorySex_A-Pussy-07_TR"
				ssStruct.PositionID = "DTSIX_852_S7"
			elseIf (stageNumber == 11)
				ssStruct.MAnimFormID = 0x050026A8	
				ssStruct.FAnimFormID = 0x050026A9
				ssStruct.PositionOrigID = "PillorySex_A-Pussy-08"
				ssStruct.PositionID = "DTSIX_852_S8"
			endIf
		elseIf (seqID == 852)
			if (longScene > 0)
				return GetSingleStage(851, stageNumber, -1, 0, 1)
			endIf
			if (stageNumber == 1)
				DTAACSceneStageStruct ss = GetSingleStage(851, 3, -1, 0)
				ss.StageNum = 1
				ss.PositionOrigID = "PillorySex_A-Pussy-03"
				ss.PositionID = "DTSIX_851_S4"
				return ss
			elseIf (stageNumber == 2)	
				DTAACSceneStageStruct ss = GetSingleStage(851, 5, -1, 0)
				ss.StageNum = 2
				ss.PositionOrigID = "PillorySex_A-Pussy-04"
				ss.PositionID = "DTSIX_851_S5"
				return ss
			elseIf (stageNumber == 3)
				DTAACSceneStageStruct ss = GetSingleStage(851, 6, -1, 0, 1)
				ss.StageNum = 3
				ss.PositionOrigID = "PillorySex_A-Pussy-05"
				ss.PositionID = "DTSIX_852_S3"
				return ss
			elseIf (stageNumber == 4)
				DTAACSceneStageStruct ss = GetSingleStage(851, 7, -1, 0)
				ss.StageNum = 4
				ss.PositionOrigID = "PillorySex_A-Pussy-06"
				ss.PositionID = "DTSIX_852_S4"
				return ss
			elseIf (stageNumber == 5)					;ZaZ_PillorySex_A-Pussy-07;
				DTAACSceneStageStruct ss = GetSingleStage(851, 9, -1, 0)
				ss.StageNum = 5
				ss.PositionOrigID = "PillorySex_A-Pussy-07"
				ss.PositionID = "DTSIX_852_S6"
				return ss
			elseIf (stageNumber == 6)				
				DTAACSceneStageStruct ss = GetSingleStage(851, 6, -1, 0)
				ss.StageNum = 2
				ss.PositionOrigID = "PillorySex_A-Pussy-08"
				ss.PositionID = "DTSIX_852_S8"
				return ss
			endIf
		
		endIf
	elseIf (seqID >= 700)
		ssStruct.PluginName = "SavageCabbage_Animations.esp"
		ssStruct.ArmorNudeAGun = 0
		if (seqID >= 700 && seqID < 750)				; beds and some other furniture
			if (seqID == 700)
				if (other > 0)
					if (stageNumber == 1)						; v2.70 FMF, SC 1.2.6
						ssStruct.FAnimFormID = 0x05030D97
						ssStruct.MAnimFormID = 0x05030D98
						ssStruct.OAnimFormID = 0x05030D99
						ssStruct.PositionID = "DTSIXFMF_700_S1"
						ssStruct.PositionOrigID = "SC-FMF-Human-DoubleBed02-01Tease"
					elseIf (stageNumber == 2)
						ssStruct.FAnimFormID = 0x05030D9A
						ssStruct.MAnimFormID = 0x05030D9B
						ssStruct.OAnimFormID = 0x05030D9C
						ssStruct.StageTime = 8.6
						ssStruct.PositionID = "DTSIXFMF_700_S2"
						ssStruct.PositionOrigID = "SC-FMF-Human-DoubleBed02-02Start"
					elseIf (stageNumber == 3)
						ssStruct.FAnimFormID = 0x05030D9D
						ssStruct.MAnimFormID = 0x05030D9E
						ssStruct.OAnimFormID = 0x05030D9F
						ssStruct.PositionID = "DTSIXFMF_700_S3"
						ssStruct.PositionOrigID = "SC-FMF-Human-DoubleBed02-03Threesome"
					elseIf (stageNumber == 4)
						ssStruct.FAnimFormID = 0x05030DA0
						ssStruct.MAnimFormID = 0x05030DA1
						ssStruct.OAnimFormID = 0x05030DA2
						ssStruct.PositionID = "DTSIXFMF_700_S4"
						ssStruct.PositionOrigID = "SC-FMF-Human-DoubleBed02-04Threesome"
					elseIf (stageNumber == 5)
						ssStruct.FAnimFormID = 0x05030DA3
						ssStruct.MAnimFormID = 0x05030DA4
						ssStruct.OAnimFormID = 0x05030DA5
						ssStruct.PositionID = "DTSIXFMF_700_S5"
						ssStruct.PositionOrigID = "SC-FMF-Human-DoubleBed02-05Threesome"
					elseIf (stageNumber == 6)
						ssStruct.FAnimFormID = 0x05030DA6
						ssStruct.MAnimFormID = 0x05030DA7
						ssStruct.OAnimFormID = 0x05030DA8
						ssStruct.PositionID = "DTSIXFMF_700_S6"
						ssStruct.PositionOrigID = "SC-FMF-Human-DoubleBed02-06Threesome"
					elseIf (stageNumber == 7)
						ssStruct.FAnimFormID = 0x05030DA9
						ssStruct.MAnimFormID = 0x05030DAA
						ssStruct.OAnimFormID = 0x05030DAB
						ssStruct.PositionID = "DTSIXFMF_700_S7"
						ssStruct.PositionOrigID = "SC-FMF-Human-DoubleBed02-07ClimaxLoop"
					else
						ssStruct.FAnimFormID = 0x05030DAC
						ssStruct.MAnimFormID = 0x05030DAD
						ssStruct.OAnimFormID = 0x05030DAE
						ssStruct.PositionID = "DTSIXFMF_700_S8"
						ssStruct.PositionOrigID = "SC-FMF-Human-DoubleBed02-08Finish"
					endIf
				elseIf (stageNumber == 1)						;SIX_SC_FM-DoubleBed02-01Tease
					ssStruct.FAnimFormID = 0x0500CF43
					ssStruct.MAnimFormID = 0x0500CF44
					ssStruct.StageTime = 13.0
					ssStruct.PositionID = "DTSIX_700_S1"
				elseIf (stageNumber == 2)
					ssStruct.FAnimFormID = 0x050017FE
					ssStruct.MAnimFormID = 0x050017FF
					ssStruct.PositionID = "DTSIX_700_S2"
				elseIf (stageNumber == 3)
					ssStruct.FAnimFormID = 0x0500644E
					ssStruct.MAnimFormID = 0x0500644F
					ssStruct.PositionID = "DTSIX_700_S3"
				elseIf (stageNumber == 4)
					ssStruct.FAnimFormID = 0x0500DE15
					ssStruct.MAnimFormID = 0x0500DE16
					ssStruct.StageTime = 7.0
					ssStruct.PositionID = "DTSIX_700_S4"
				endIf
			elseIf (seqID == 701)
				if (other > 0)
																; v2.70 FMM SC 1.2.6
					ssStruct.FAnimFormID = 0x05031574
					ssStruct.MAnimFormID = 0x05031575
					ssStruct.OAnimFormID = 0x05031576
					ssStruct.StageTime = 32.0
					ssStruct.PositionID = "DTSIXFMM_701_S1"
					ssStruct.PositionOrigID = "SC-FMM-Human-DoubleBed03-03Threesome"
						
				elseIf (stageNumber == 1)						;SIX_SC_FM-DoubleBed03-01Tease
					ssStruct.FAnimFormID = 0x050099DE
					ssStruct.MAnimFormID = 0x050099DF
					if (longScene < 0)
						ssStruct.StageTime = 26.0
					else
						ssStruct.StageTime = 14.0
					endIf
					ssStruct.PositionID = "DTSIX_701_S1"
				elseIf (stageNumber == 2)
					ssStruct.FAnimFormID = 0x05005CA9
					ssStruct.MAnimFormID = 0x05005CAA
					ssStruct.PositionID = "DTSIX_701_S2"
				elseIf (stageNumber == 3)
					ssStruct.FAnimFormID = 0x0500B80B
					ssStruct.MAnimFormID = 0x0500B80C
					if (scEVB)
						ssStruct.ArmorNudeAGun = 1
					endIf
					ssStruct.PositionID = "DTSIX_701_S3"
				elseIf (stageNumber == 4 || (stageNumber == 6 && longScene <= 0))
					ssStruct.FAnimFormID = 0x0500DE15
					ssStruct.MAnimFormID = 0x0500DE16
					ssStruct.StageTime = 9.0
					ssStruct.PositionID = "DTSIX_701_S4"
				elseIf (stageNumber == 5)
					ssStruct.FAnimFormID = 0x0500DE17
					ssStruct.MAnimFormID = 0x0500DE18
					ssStruct.PositionID = "DTSIX_701_S5"
				elseIf (longScene > 0)
					ssStruct.FAnimFormID = 0x05027AE4
					ssStruct.MAnimFormID = 0x05027AE5
					ssStruct.PositionID = "DTSIX_701_S6"
					ssStruct.PositionOrigID = "SC-FM-Human-DoubleBed03-07ClimaxLoop"
				endIf
			elseIf (seqID == 702)
				if (other > 0)
					ssStruct.FAnimFormID = 0x0502360A
					ssStruct.MAnimFormID = 0x0502360B
					ssStruct.OAnimFormID = 0x0502360C
					;ssStruct.ArmorNudeAGun = 1
					ssStruct.StageTime = 32.0
					ssStruct.PositionID = "DTSIXFMF_702_S1"
					
				elseIf (stageNumber == 1)						;SIX_SC_FM-DoubleBed01-01Doggy
					ssStruct.FAnimFormID = 0x05001008
					ssStruct.MAnimFormID = 0x05001009
					ssStruct.PositionID = "DTSIX_702_S1"
				elseIf (stageNumber == 2)
					ssStruct.FAnimFormID = 0x0500100A
					ssStruct.MAnimFormID = 0x0500100B
					ssStruct.PositionID = "DTSIX_702_S2"
				elseIf (stageNumber == 3)
					ssStruct.FAnimFormID = 0x0500100C
					ssStruct.MAnimFormID = 0x0500100D
					ssStruct.PositionID = "DTSIX_702_S3"
				elseIf (stageNumber == 4)
					ssStruct.FAnimFormID = 0x05004D6A
					ssStruct.MAnimFormID = 0x05004D6B
					ssStruct.PositionID = "DTSIX_702_S4"
				elseIf (stageNumber == 5)
					ssStruct.FAnimFormID = 0x05004D6C
					ssStruct.MAnimFormID = 0x05004D6D
					ssStruct.PositionID = "DTSIX_702_S5"
				else
					ssStruct.FAnimFormID = 0x05007386
					ssStruct.MAnimFormID = 0x05007387
					ssStruct.PositionID = "DTSIX_702_S6"
				endIf
			elseIf (seqID == 703)
				if (stageNumber == 1 || stageNumber == 6)						;SIX_SC_FM-DoubleBed04-01Tease
					ssStruct.FAnimFormID = 0x050099E0
					ssStruct.MAnimFormID = 0x050099E1
					ssStruct.StageTime = 13.0
					if (scEVB)
						ssStruct.ArmorNudeAGun = 1
					endIf
					ssStruct.PositionID = "DTSIX_703_S1"
				elseIf (stageNumber == 2)					;SIX_SC_FM-DoubleBed04-03Doggy
					ssStruct.FAnimFormID = 0x05004D70
					ssStruct.MAnimFormID = 0x05004D71
					if (scEVB)
						ssStruct.ArmorNudeAGun = 1
					endIf
					ssStruct.PositionID = "DTSIX_703_S2"
				elseIf (stageNumber == 3)
					ssStruct.FAnimFormID = 0x0500B80D
					ssStruct.MAnimFormID = 0x0500B80E
					ssStruct.PositionID = "DTSIX_703_S3"
					if (scEVB)
						ssStruct.ArmorNudeAGun = 1
					endIf
				elseIf (stageNumber == 4)
					ssStruct.FAnimFormID = 0x05006C0E
					ssStruct.MAnimFormID = 0x05006C0F
					if (scEVB)
						ssStruct.ArmorNudeAGun = 1
					endIf
					ssStruct.PositionID = "DTSIX_703_S6"
				elseIf (stageNumber == 5)
					ssStruct.FAnimFormID = 0x05008A9E
					ssStruct.MAnimFormID = 0x05008A9F
					if (scEVB)
						ssStruct.ArmorNudeAGun = 1
					endIf
					ssStruct.PositionID = "DTSIX_703_S5"
				endIf
			elseIf (seqID == 704)							
				if (other == 0)
					if (stageNumber == 2)
						ssStruct.FAnimFormID = 0x05000FEA
						ssStruct.MAnimFormID = 0x05000FEB
						if (scEVB)
							ssStruct.ArmorNudeAGun = 1
						endIf
						ssStruct.PositionID = "DTSIX_704_S2"
						ssStruct.PositionOrigID = "FM-Bed02-01Straddle"
					elseIf (stageNumber == 3)
						ssStruct.FAnimFormID = 0x05000FEC
						ssStruct.MAnimFormID = 0x05000FED
						if (scEVB)
							ssStruct.ArmorNudeAGun = 1
						endIf
						ssStruct.PositionID = "DTSIX_704_S3"
					elseIf (stageNumber == 4)
						ssStruct.FAnimFormID = 0x05000FEE
						ssStruct.MAnimFormID = 0x05000FEF
						if (scEVB)
							ssStruct.ArmorNudeAGun = 1
						endIf
						ssStruct.PositionID = "DTSIX_704_S4"
					elseIf (stageNumber == 5)
						ssStruct.FAnimFormID = 0x05006C08
						ssStruct.MAnimFormID = 0x05006C09
						if (scEVB)
							ssStruct.ArmorNudeAGun = 1
						endIf
						ssStruct.PositionID = "DTSIX_704_S5"
					elseIf (stageNumber == 6 && longScene > 0)
						if (Utility.RandomInt(1,6) < 4)
							ssStruct.FAnimFormID = 0x0502DEA7		; v2.49, SC 1.2.4  last 
							ssStruct.MAnimFormID = 0x0502DEA8
							ssStruct.PositionOrigID = "SC-FM-Human-Bed02-07ClimaxLoop"
						else
							ssStruct.FAnimFormID = 0x0502FD85		; v2.53, SC 1.2.4  last 
							ssStruct.MAnimFormID = 0x0502FD86
							ssStruct.PositionOrigID = "SC-FM-Human-Bed02-08Finish"
						endIf
						ssStruct.PositionID = "DTSIX_704_S6"	
					else
						ssStruct.FAnimFormID = 0x05000FE8		; first and last
						ssStruct.MAnimFormID = 0x05000FE9
						ssStruct.PositionID = "DTSIX_704_S1"
					endIf
				else
					ssStruct.ArmorNudeBGun = 0
					if (stageNumber == 1)						
						ssStruct.FAnimFormID = 0x0500101C		
						ssStruct.OAnimFormID = 0x0500101D		; v2.26 - swap males
						ssStruct.MAnimFormID = 0x0500101E
						ssStruct.PositionID = "DTSIXFMM_704_S1"
						ssStruct.PositionOrigID = "FMM-Bed01-01Handjob-Doggy"
					elseIf (stageNumber == 3 || stageNumber == 5)
						ssStruct.FAnimFormID = 0x05001022
						ssStruct.OAnimFormID = 0x05001023
						ssStruct.MAnimFormID = 0x05001024
						ssStruct.PositionID = "DTSIXFMM_704_S3"
					elseIf (stageNumber == 4)
						ssStruct.FAnimFormID = 0x05001025
						ssStruct.OAnimFormID = 0x05001026
						ssStruct.MAnimFormID = 0x05001027
						ssStruct.PositionID = "DTSIXFMM_704_S4"
					else
						ssStruct.FAnimFormID = 0x0500101F		; second and last -
						ssStruct.OAnimFormID = 0x05001020
						ssStruct.MAnimFormID = 0x05001021
						ssStruct.PositionID = "DTSIXFMM_704_S2"
					endIf
				endIf
			elseIf (seqID == 705)						
				if (other == 0)
					if (stageNumber == 1)						
						ssStruct.FAnimFormID = 0x050099DA
						ssStruct.MAnimFormID = 0x050099DB
						ssStruct.StageTime = 13.0
						ssStruct.PositionID = "DTSIX_705_S1"
					elseIf (stageNumber == 2)
						ssStruct.FAnimFormID = 0x05006C0A
						ssStruct.MAnimFormID = 0x05006C0B
						if (scEVB)
							ssStruct.ArmorNudeAGun = 1
						endIf
						ssStruct.StageTime = 7.5
						ssStruct.PositionID = "DTSIX_705_S2"
					elseIf (stageNumber == 3)
						ssStruct.FAnimFormID = 0x0500923C
						ssStruct.MAnimFormID = 0x0500923D
						if (scEVB)
							ssStruct.ArmorNudeAGun = 1
						endIf
						ssStruct.PositionID = "DTSIX_705_S3"
					elseIf (stageNumber == 4)
						ssStruct.FAnimFormID = 0x0500E62A
						ssStruct.MAnimFormID = 0x0500E62B
						if (scEVB)
							ssStruct.ArmorNudeAGun = 1
						endIf
						ssStruct.PositionID = "DTSIX_705_S4"				
					elseIf (stageNumber == 5)								; v2.50
						ssStruct.FAnimFormID = 0x0502731D
						ssStruct.MAnimFormID = 0x0502731E
						if (scEVB)
							ssStruct.ArmorNudeAGun = 1
						endIf
						ssStruct.PositionID = "DTSIX_705_S5"
					elseIf (stageNumber == 6)								; v2.50
						ssStruct.FAnimFormID = 0x0502DEA9
						ssStruct.MAnimFormID = 0x0502DEAA
						if (scEVB)
							ssStruct.ArmorNudeAGun = 1
						endIf
						ssStruct.PositionID = "DTSIX_705_S5"
					endIf
				else
					ssStruct.ArmorNudeBGun = 0
					if (stageNumber == 1 || stageNumber == 3)				;FMM-Floor01-01DoubleTeam
						ssStruct.FAnimFormID = 0x05001034
						ssStruct.MAnimFormID = 0x05001035
						ssStruct.OAnimFormID = 0x05001036
						ssStruct.PositionID = "DTSIXFMM_705_S1"
					elseIf (stageNumber == 2)
						ssStruct.FAnimFormID = 0x05001037
						ssStruct.MAnimFormID = 0x05001038
						ssStruct.OAnimFormID = 0x05001039
						ssStruct.PositionID = "DTSIXFMM_705_S2"
					elseIf (longScene > 0)									; v2.49, SC 1.2.4
						ssStruct.FAnimFormID = 0x0502FDA1
						ssStruct.MAnimFormID = 0x0502FDA2
						ssStruct.OAnimFormID = 0x0502FDA3
						ssStruct.PositionID = "DTSIXFMM_705_S3"				
					else
						ssStruct.FAnimFormID = 0x05001037
						ssStruct.MAnimFormID = 0x05001038
						ssStruct.OAnimFormID = 0x05001039
						ssStruct.PositionID = "DTSIXFMM_705_S2"
					endIf
				endIf
			elseIf (seqID == 706)
					if (other > 0)
						if (scEVB)
							ssStruct.ArmorNudeAGun = 1
							ssStruct.ArmorNudeBGun = 1
						else
							ssStruct.ArmorNudeBGun = 0
						endIf
						if (longScene <= 0)
							ssStruct.StageTime = 36.0
						else
							ssStruct.StageTime = 18.0
						endIf
						if (stageNumber == 1)
							ssStruct.FAnimFormID = 0x05021EF5
							ssStruct.MAnimFormID = 0x05021EF7		; reversed male role
							ssStruct.OAnimFormID = 0x05021EF6
							ssStruct.PositionID = "DTSIXFMM_706_S1"
							ssStruct.PositionOrigID = "SC_FMM-DoubleBed01-03DoubleTeam"
						else
							ssStruct.FAnimFormID = 0x0503056A				; v2.50  SC 1.2.5
							ssStruct.MAnimFormID = 0x0503056C		; reversed male
							ssStruct.OAnimFormID = 0x0503056B
							ssStruct.PositionID = "DTSIXFMM_706_S2"
							ssStruct.PositionOrigID = "SC_FMM-Human-DoubleBed01-04DoubleTeam"
						endIf
						
					elseIf (stageNumber == 1)						;v1.21
						ssStruct.FAnimFormID = 0x0502DEAB
						ssStruct.MAnimFormID = 0x0502DEAC
						ssStruct.StageTime = 13.0
						ssStruct.PositionID = "DTSIX_706_S0"
						ssStruct.PositionOrigID = "SC-FM-Human-Bed04-01Tease"
					elseIf (stageNumber == 2)						;v1.21
						ssStruct.FAnimFormID = 0x0500E62C
						ssStruct.MAnimFormID = 0x0500E62D
						ssStruct.PositionID = "DTSIX_706_S1"
						ssStruct.PositionOrigID = "SC-FM-Human-Bed04-03Missionary"
					elseIf (stageNumber == 3)
						ssStruct.FAnimFormID = 0x0502B0A5
						ssStruct.MAnimFormID = 0x0502B0A6
						ssStruct.PositionID = "DTSIX_706_S2"
						ssStruct.PositionOrigID = "SC-FM-Human-Bed04-04Missionary"
					elseIf (stageNumber == 4)
						ssStruct.FAnimFormID = 0x0502B0A7
						ssStruct.MAnimFormID = 0x0502B0A8
						ssStruct.PositionID = "DTSIX_706_S3"
						ssStruct.PositionOrigID = "SC-FM-Human-Bed04-05Missionary"
					elseIf (stageNumber == 5)
						ssStruct.FAnimFormID = 0x0502B0A9
						ssStruct.MAnimFormID = 0x0502B0AA
						ssStruct.PositionID = "DTSIX_706_S4"	
						ssStruct.PositionOrigID = "SC-FM-Human-Bed04-06Missionary"
					elseIf (stageNumber == 6)
						ssStruct.FAnimFormID = 0x0502DEAD
						ssStruct.MAnimFormID = 0x0502DEAE
						ssStruct.StageTime = 7.0
						ssStruct.PositionID = "DTSIX_706_S5"	
						ssStruct.PositionOrigID = "SC-FM-Human-Bed04-07ClimaxLoop"
					endIf
				
			elseIf (seqID == 707)
				if (other > 0)
					if (stageNumber == 1)
						ssStruct.FAnimFormID = 0x05021EF2
						ssStruct.MAnimFormID = 0x05021EF3
						ssStruct.OAnimFormID = 0x05021EF4
						ssStruct.PositionID = "DTSIXFMM_707_S1"
						ssStruct.PositionOrigID = "FMM-DoubleBed02-03ReverseCowgirl-Blowjob"
					else
						ssStruct.FAnimFormID = 0x0503056D				; v2.50  SC 1.2.5
						ssStruct.MAnimFormID = 0x0503056E
						ssStruct.OAnimFormID = 0x0503056F
						ssStruct.PositionID = "DTSIXFMM_707_S2"
						ssStruct.PositionOrigID = "SC-FMM-Human-DoubleBed02-04ReverseCowgirl-Blowjob"
					endIf
					if (scEVB)
						ssStruct.ArmorNudeAGun = 1
						ssStruct.ArmorNudeBGun = 1
					else
						ssStruct.ArmorNudeBGun = 0
					endIf
					if (longScene <= 0)
						ssStruct.StageTime = 37.0
					else
						ssStruct.StageTime = 18.5
					endIf
				else
					if (stageNumber == 1)											; v2.70, SC 1.2.6
						ssStruct.FAnimFormID = 0x05030D44
						ssStruct.MAnimFormID = 0x05030D45
						ssStruct.StageTime = 12.0
						ssStruct.PositionID = "DTSIX_707_S1"
						ssStruct.PositionOrigID = "FM-Human-DoubleBed05-01Tease"
					elseIf (stageNumber == 2)
						ssStruct.FAnimFormID = 0x05030D46
						ssStruct.MAnimFormID = 0x05030D47
						ssStruct.PositionID = "DTSIX_707_S2"
						ssStruct.PositionOrigID = "FM-Human-DoubleBed05-02Start"
					elseIf (stageNumber == 3)											
						ssStruct.FAnimFormID = 0x05030D48
						ssStruct.MAnimFormID = 0x05030D49
						ssStruct.PositionID = "DTSIX_707_S3"
						ssStruct.PositionOrigID = "FM-Human-DoubleBed05-03Doggy"
					elseIf (stageNumber == 4)											
						ssStruct.FAnimFormID = 0x05030D4A
						ssStruct.MAnimFormID = 0x05030D4B
						ssStruct.PositionID = "DTSIX_707_S4"
						ssStruct.PositionOrigID = "FM-Human-DoubleBed05-04Doggy"
					elseIf (stageNumber == 5)											
						ssStruct.FAnimFormID = 0x05030D4C
						ssStruct.MAnimFormID = 0x05030D4D
						ssStruct.PositionID = "DTSIX_707_S5"
						ssStruct.PositionOrigID = "FM-Human-DoubleBed05-05Doggy"
					elseIf (stageNumber == 6)											
						ssStruct.FAnimFormID = 0x05030D4E
						ssStruct.MAnimFormID = 0x05030D4F
						ssStruct.PositionID = "DTSIX_707_S6"
						ssStruct.PositionOrigID = "FM-Human-DoubleBed05-06Doggy"
					endIf
				endIf
			
			elseIf (seqID == 709)													; v2.70, SC 1.2.6
				if (stageNumber == 1)
					ssStruct.FAnimFormID = 0x05030D87
					ssStruct.MAnimFormID = 0x05030D88
					ssStruct.StageTime = 12.0
					ssStruct.PositionID = "DTSIX_709_S1"
					ssStruct.PositionOrigID = "FM-Human-DoubleBedInstitute01-01Tease"
				elseIf (stageNumber == 2)
					ssStruct.FAnimFormID = 0x05030D89
					ssStruct.MAnimFormID = 0x05030D8A
					ssStruct.PositionID = "DTSIX_709_S2"
					ssStruct.PositionOrigID = "FM-Human-DoubleBedInstitute01-02Start"
				elseIf (stageNumber == 3)
					ssStruct.FAnimFormID = 0x05030D8B
					ssStruct.MAnimFormID = 0x05030D8C
					ssStruct.PositionID = "DTSIX_709_S3"
					ssStruct.PositionOrigID = "FM-Human-DoubleBedInstitute01-03ReverseCowGirl"
				elseIf (stageNumber == 4)
					ssStruct.FAnimFormID = 0x05030D8D
					ssStruct.MAnimFormID = 0x05030D8E
					ssStruct.PositionID = "DTSIX_709_S4"
					ssStruct.PositionOrigID = "FM-Human-DoubleBedInstitute01-04ReverseCowGirl"
				elseIf (stageNumber == 5)
					ssStruct.FAnimFormID = 0x05030D8F
					ssStruct.MAnimFormID = 0x05030D90
					ssStruct.PositionID = "DTSIX_709_S5"
					ssStruct.PositionOrigID = "FM-Human-DoubleBedInstitute01-05ReverseCowGirl"
				elseIf (stageNumber == 6)
					ssStruct.FAnimFormID = 0x05030D91
					ssStruct.MAnimFormID = 0x05030D92
					ssStruct.PositionID = "DTSIX_709_S6"
					ssStruct.PositionOrigID = "FM-Human-DoubleBedInstitute01-06ReverseCowGirl"
				elseIf (stageNumber == 7)
					ssStruct.FAnimFormID = 0x05030D93
					ssStruct.MAnimFormID = 0x05030D94
					ssStruct.PositionID = "DTSIX_709_S7"
					ssStruct.PositionOrigID = "FM-Human-DoubleBedInstitute01-07ClimaxLoop"
				else
					ssStruct.FAnimFormID = 0x05030D95
					ssStruct.MAnimFormID = 0x05030D96
					ssStruct.PositionID = "DTSIX_709_S8"
					ssStruct.PositionOrigID = "FM-Human-DoubleBedInstitute01-08Finish"
				endIf
			elseIf (seqID == 710)													; v2.53 variation of 711 -- same AAF
				if (stageNumber == 1)
					ssStruct.FAnimFormID = 0x05000FD3
					ssStruct.MAnimFormID = 0x05000FD4
					ssStruct.StageTime = 12.0
					ssStruct.PositionID = "DTSIX_711_S1"
					ssStruct.PositionOrigID = "FM-Bed01-01Tease"
				elseIf (stageNumber == 2)
					ssStruct.FAnimFormID = 0x05000FD5
					ssStruct.MAnimFormID = 0x05000FD6
					ssStruct.PositionID = "DTSIX_711_S2"
					ssStruct.PositionOrigID = "FM-Bed01-02Start"
				elseIf (stageNumber == 3)
					ssStruct.FAnimFormID = 0x05000FD7
					ssStruct.MAnimFormID = 0x05000FD8
					ssStruct.PositionID = "DTSIX_711_S3"
					ssStruct.PositionOrigID = "SC-FM-Human-Bed01-06Blowjob"
				elseIf (stageNumber == 4)
					ssStruct.FAnimFormID = 0x05000FDF
					ssStruct.MAnimFormID = 0x05000FE0
					ssStruct.PositionID = "DTSIX_711_S4"
					ssStruct.PositionOrigID = "SC-FM-Human-Bed01-07Deepthroat"
				elseIf (stageNumber == 5)
					ssStruct.FAnimFormID = 0x05000FE1
					ssStruct.MAnimFormID = 0x05000FE2
					ssStruct.PositionID = "DTSIX_711_S5"
					ssStruct.PositionOrigID = "SC-FM-Human-Bed01-08Blowjob"
				else
					ssStruct.FAnimFormID = 0x05000FE3	
					ssStruct.MAnimFormID = 0x05000FE4
					ssStruct.PositionID = "DTSIX_711_S6"
					ssStruct.PositionOrigID = "SC-FM-Human-Bed01-09Climax"
				endIf
			elseIf (seqID == 711)
				if (stageNumber == 1)
					ssStruct.FAnimFormID = 0x05000FD3
					ssStruct.MAnimFormID = 0x05000FD4
					ssStruct.StageTime = 12.0
					ssStruct.PositionID = "DTSIX_711_S1"
					ssStruct.PositionOrigID = "FM-Bed01-01Tease"
				elseIf (stageNumber == 2)
					ssStruct.FAnimFormID = 0x05000FD5
					ssStruct.MAnimFormID = 0x05000FD6
					ssStruct.PositionID = "DTSIX_711_S2"
					ssStruct.PositionOrigID = "FM-Bed01-02Start"
				elseIf (stageNumber == 3)
					ssStruct.FAnimFormID = 0x05000FD7
					ssStruct.MAnimFormID = 0x05000FD8
					ssStruct.PositionID = "DTSIX_711_S3"
					ssStruct.PositionOrigID = "FM-Bed01-03Handjob"
				elseIf (stageNumber == 4)
					ssStruct.FAnimFormID = 0x05000FD9
					ssStruct.MAnimFormID = 0x05000FDA
					ssStruct.PositionID = "DTSIX_711_S4"
					ssStruct.PositionOrigID = "FM-Bed01-04Handjob"
				elseIf (stageNumber == 5)
					ssStruct.FAnimFormID = 0x05000FDB
					ssStruct.MAnimFormID = 0x05000FDC
					ssStruct.PositionID = "DTSIX_711_S5"
					ssStruct.PositionOrigID = "FM-Bed01-05Titjob"
				else
					ssStruct.FAnimFormID = 0x05000FE5	
					ssStruct.MAnimFormID = 0x05000FE7
					ssStruct.PositionID = "DTSIX_711_S6"
					ssStruct.PositionOrigID = "SC-FM-Human-Bed01-10Finish"
				endIf
			elseIf (seqID == 712)
				if (stageNumber == 1)
					ssStruct.FAnimFormID = 0x05025C26
					ssStruct.MAnimFormID = 0x05025C27
					ssStruct.PositionID = "DTSIX_712_S1"
					ssStruct.PositionOrigID = "FM-DoubleBedWoodPreWar01-01Tease"
				elseIf (stageNumber == 2)
					ssStruct.FAnimFormID = 0x05025C28
					ssStruct.MAnimFormID = 0x05025C29
					ssStruct.PositionID = "DTSIX_712_S2"
					ssStruct.PositionOrigID = "FM-DoubleBedWoodPreWar01-02Start"
				elseIf (stageNumber == 3)
					ssStruct.FAnimFormID = 0x05025C2A
					ssStruct.MAnimFormID = 0x05025C2B
					ssStruct.PositionID = "DTSIX_712_S3"
					ssStruct.PositionOrigID = "FM-DoubleBedWoodPreWar01-03Doggy"
				elseIf (stageNumber == 4)
					ssStruct.FAnimFormID = 0x05025C2C
					ssStruct.MAnimFormID = 0x05025C2D
					ssStruct.PositionID = "DTSIX_712_S4"
					ssStruct.PositionOrigID = "FM-DoubleBedWoodPreWar01-04Doggy"
				elseIf (stageNumber == 5)							
					ssStruct.FAnimFormID = 0x05025C2E
					ssStruct.MAnimFormID = 0x05025C2F
					ssStruct.PositionID = "DTSIX_712_S5"
					ssStruct.PositionOrigID = "FM-DoubleBedWoodPreWar01-05Sideways"
				else
					ssStruct.FAnimFormID = 0x05025C30	
					ssStruct.MAnimFormID = 0x05025C31
					ssStruct.PositionID = "DTSIX_712_S6"
					ssStruct.PositionOrigID = "FM-DoubleBedWoodPreWar01-06Missionary"
				endIf
				
			elseIf (seqID == 713)						
				ssStruct.FAnimFormID = 0x050082C9
				if (other > 0)
					ssStruct.MAnimFormID = 0x050082CA
					ssStruct.OAnimFormID = 0x050082CB
					if (scEVB)
						ssStruct.ArmorNudeBGun = 1
					endIf
					ssStruct.PositionID = "DTSIXFMM_713_S1"
				else
					ssStruct.MAnimFormID = 0x050082CB							; not used
					ssStruct.PositionID = "DTSIX_713_S1"
				endIf
				if (scEVB)
					ssStruct.ArmorNudeAGun = 1
				endIf
				ssStruct.StageTime = 32.0
				ssStruct.PositionOrigID = "FMM-Floor04-03DoubleTeam"
				
			elseIf (seqID == 714)						
				ssStruct.FAnimFormID = 0x0500BFA8
				ssStruct.MAnimFormID = 0x0500BFAA
				ssStruct.OAnimFormID = 0x0500BFA9
				ssStruct.ArmorNudeBGun = 0
				if (scEVB)
					ssStruct.ArmorNudeBGun = 1
				endIf
				ssStruct.PositionID = "DTSIXFMM_714_S1"
				ssStruct.ArmorNudeAGun = 0
				ssStruct.StageTime = 32.0
				ssStruct.PositionOrigID = "FMM-Floor05-03DoubleTeam"
			elseIf (seqID == 715)
				if (longScene < 2)
					stageNumber += 1
				endIf
				if (stageNumber == 1)
					ssStruct.FAnimFormID = 0x05030564			; v2.50, SC 1.2.5
					ssStruct.MAnimFormID = 0x05030566			; swapped order
					ssStruct.OAnimFormID = 0x05030565
					ssStruct.PositionID = "DTSIXFMM_715_S0"	
				elseIf (stageNumber == 2 || (longScene < 3 && stageNumber >= 4))
					ssStruct.FAnimFormID = 0x05010C3C
					ssStruct.OAnimFormID = 0x05010C3E			; v2.49 swapped male roles so primary on bottom
					ssStruct.MAnimFormID = 0x05010C3D
					ssStruct.PositionID = "DTSIXFMM_715_S1"
					ssStruct.PositionOrigID = "FMM-BunkBed01-03Threesome"
				elseIf (stageNumber == 3)
					ssStruct.FAnimFormID = 0x0502FD9E			; v2.49, SC 1.2.4
					ssStruct.MAnimFormID = 0x0502FD9F			; note order for male assignment to prevent sudden switch places
					ssStruct.OAnimFormID = 0x0502FDA0
					ssStruct.PositionID = "DTSIXFMM_715_S2"
				elseIf (stageNumber == 4 && longScene >= 3)
					ssStruct.FAnimFormID = 0x050344F2			; v2.88
					ssStruct.MAnimFormID = 0x050344F3			
					ssStruct.OAnimFormID = 0x050344F4
					ssStruct.PositionID = "DTSIXFMM_715_S3"
					ssStruct.PositionOrigID = "SC-FMM-Human-BunkBed01-05Threesome"
																
				elseIf (stageNumber == 5)
					ssStruct.FAnimFormID = 0x050344F5			; v2.88
					ssStruct.MAnimFormID = 0x050344F6			
					ssStruct.OAnimFormID = 0x050344F7
					ssStruct.PositionID = "DTSIXFMM_715_S4"
					ssStruct.PositionOrigID = "SC-FMM-Human-BunkBed01-06Threesome"
				elseIf (longScene >= 3)
					ssStruct.FAnimFormID = 0x050344F8			; v2.88
					ssStruct.MAnimFormID = 0x050344F9			
					ssStruct.OAnimFormID = 0x050344FA
					ssStruct.PositionID = "DTSIXFMM_715_S5"
					ssStruct.PositionOrigID = "SC-FMM-Human-BunkBed01-07ClimaxLoop"
				endIf
				if (scEVB)
					ssStruct.ArmorNudeAGun = 1
					ssStruct.ArmorNudeBGun = 1
				else
					ssStruct.ArmorNudeBGun = 0
				endIf
				if (longScene > 0 || stageNumber > 1)
					if (longScene == 2)
						ssStruct.StageTime = 11.67
					elseIf (longScene == 1)
						ssStruct.StageTime = 16.0
					endIf
				elseIf (longScene <= 0)
					ssStruct.StageTime = 32.0
				endIf
				
			elseIf (seqID == 732)
				if (stageNumber == 1)
					ssStruct.FAnimFormID = 0x0502B86A
					ssStruct.MAnimFormID = 0x0502B86B
					ssStruct.StageTime = 24.0
					ssStruct.PositionID = "DTSIX_732_S1"
					ssStruct.PositionOrigID = "SC-FM-Human-Ottoman01-03Handjob"
				else
					ssStruct.FAnimFormID = 0x0502B86C
					ssStruct.MAnimFormID = 0x0502B86D
					ssStruct.StageTime = 24.0
					ssStruct.PositionID = "DTSIX_732_S2"
					ssStruct.PositionOrigID = "SC-FM-Human-Ottoman01-04Blowjob"
				endIf
				
			elseIf (seqID == 733)
				if (stageNumber == 1 && longScene >= 2)						; SC 1.3.0 - v2.88
					ssStruct.FAnimFormID = 0x050344DC
					ssStruct.MAnimFormID = 0x050344DD
					ssStruct.PositionID = "DTSIX_733_S0"
					ssStruct.PositionOrigID = "FM-Throne01-02Start"
				elseIf (stageNumber == 2 || (longScene <= 0 && stageNumber == 4))
					ssStruct.FAnimFormID = 0x0500101A
					ssStruct.MAnimFormID = 0x0500101B
					ssStruct.PositionID = "DTSIX_733_S1"
					ssStruct.PositionOrigID = "FM-Throne01-03Handjob"
				elseIf (stageNumber == 3)
					ssStruct.FAnimFormID = 0x0500E62E
					ssStruct.MAnimFormID = 0x0500E62F
					ssStruct.PositionID = "DTSIX_733_S2"
					ssStruct.PositionOrigID = "FM-Throne01-04Handjob"
				elseIf (stageNumber == 4)

					ssStruct.FAnimFormID = 0x05027335
					ssStruct.MAnimFormID = 0x05027336
					ssStruct.PositionID = "DTSIX_733_S3"
					ssStruct.PositionOrigID = "SIX_SC_FM-Throne01-05Blowjob"
				elseIf (stageNumber >= 5)
					ssStruct.FAnimFormID = 0x05027343
					ssStruct.MAnimFormID = 0x05027344
					ssStruct.PositionID = "DTSIX_733_S4"
					ssStruct.PositionOrigID = "FSIX_SC_FM-Throne01-06Blowjob"
				endIf
			elseIf (seqID == 734)
				if (stageNumber == 1)
					ssStruct.FAnimFormID = 0x0502547D
					ssStruct.MAnimFormID = 0x0502547E
					ssStruct.PositionID = "DTSIX_734_S1"
					ssStruct.PositionOrigID = "FM-FederalistCouch01-01Tease"
				elseIf (stageNumber == 2)
					ssStruct.FAnimFormID = 0x0502547F
					ssStruct.MAnimFormID = 0x05025480
					ssStruct.PositionID = "DTSIX_734_S2"
					ssStruct.PositionOrigID = "FM-FederalistCouch01-02Start"
				elseIf (stageNumber == 3)
					ssStruct.FAnimFormID = 0x05025481
					ssStruct.MAnimFormID = 0x05025482
					ssStruct.PositionID = "DTSIX_734_S3"
					ssStruct.PositionOrigID = "FM-FederalistCouch01-03Missionary"
				elseIf (stageNumber == 4)
					ssStruct.FAnimFormID = 0x05025483
					ssStruct.MAnimFormID = 0x05025484
					ssStruct.PositionID = "DTSIX_734_S4"
					ssStruct.PositionOrigID = "FM-FederalistCouch01-04Missionary"
				elseIf (stageNumber == 5)
					ssStruct.FAnimFormID = 0x05025485
					ssStruct.MAnimFormID = 0x05025486
					ssStruct.PositionID = "DTSIX_734_S5"
					ssStruct.PositionOrigID = "FM-FederalistCouch01-05Missionary"
				else
					ssStruct.FAnimFormID = 0x05025487	
					ssStruct.MAnimFormID = 0x05025488
					ssStruct.PositionID = "DTSIX_734_S6"
					ssStruct.PositionOrigID = "FM-FederalistCouch01-06Missionary"
				endIf
			elseIf (seqID == 735)							;SIX_SC_FM-Couch02-01Teas / SIX_SC_FMM-Couch02-03Handjob
				if (other == 0)
					ssStruct.ArmorNudeAGun = 0
					if (scEVB)
						ssStruct.ArmorNudeAGun = 1
					endIf
					if (stageNumber == 1)						
						ssStruct.FAnimFormID = 0x0500C7A4
						ssStruct.MAnimFormID = 0x0500C7A5
						ssStruct.PositionID = "DTSIX_735_S1"
						ssStruct.PositionOrigID = "FM-Couch02-01Tease"
					elseIf (stageNumber == 2)
						ssStruct.FAnimFormID = 0x05006448
						ssStruct.MAnimFormID = 0x05006449
						ssStruct.PositionID = "DTSIX_735_S2"
						ssStruct.PositionOrigID = "FM-Couch02-03Handjob"
					elseIf (stageNumber == 3 || stageNumber == 6)
						ssStruct.FAnimFormID = 0x0500644A
						ssStruct.MAnimFormID = 0x0500644B
						ssStruct.PositionID = "DTSIX_735_S3"
						ssStruct.PositionOrigID = "FM-Couch02-04Handjob"
					elseIf (stageNumber == 4)
						ssStruct.FAnimFormID = 0x0500644C
						ssStruct.MAnimFormID = 0x0500644D
						ssStruct.PositionID = "DTSIX_735_S4"
						ssStruct.PositionOrigID = "FM-Couch02-05Blowjob"
					elseIf (stageNumber == 5 || (stageNumber == 6 && longScene < 0))
						ssStruct.FAnimFormID = 0x05027321
						ssStruct.MAnimFormID = 0x05027322
						ssStruct.PositionID = "DTSIX_735_S5"
						ssStruct.PositionOrigID = "FM-Couch02-06Blowjob"
					elseIf (longScene >= 1)
						ssStruct.FAnimFormID = 0x0502DED3
						ssStruct.MAnimFormID = 0x0502DED4
						ssStruct.PositionID = "DTSIX_735_S5"
						ssStruct.PositionOrigID = "FM-Couch02-07ClimaxLoop"
					endIf
				else
					if (scEVB)
						ssStruct.ArmorNudeAGun = 1				;SC_FMM-Couch02-03Handjob
						ssStruct.ArmorNudeBGun = 1
					else
						ssStruct.ArmorNudeBGun = 0
					endIf
					if (stageNumber == 1 && longScene >= 2)				; v2.70 1st stage updated, SC 1.2.6
						ssStruct.FAnimFormID = 0x05030D25
						ssStruct.MAnimFormID = 0x05030D26
						ssStruct.OAnimFormID = 0x05030D27
						ssStruct.PositionID = "DTSIXFMM_735_S1"
						ssStruct.PositionOrigID = "FMM-Couch02-01Tease"
					elseIf (stageNumber == 2)
						ssStruct.FAnimFormID = 0x05012319
						ssStruct.MAnimFormID = 0x0501231A
						ssStruct.OAnimFormID = 0x0501231B
						ssStruct.PositionID = "DTSIXFMM_735_S2"
						ssStruct.PositionOrigID = "FMM-Couch02-04Handjob"
					elseIf (stageNumber == 3)
						ssStruct.FAnimFormID = 0x05003698
						ssStruct.MAnimFormID = 0x05003699
						ssStruct.OAnimFormID = 0x0500369A
						ssStruct.PositionID = "DTSIXFMM_735_S3"
						ssStruct.PositionOrigID = "FMM-Couch02-05Blowjob"
					elseIf (stageNumber == 4 && longScene > 0)
						ssStruct.FAnimFormID = 0x05030567				;v2.50  SC 1.2.5
						ssStruct.MAnimFormID = 0x05030568
						ssStruct.OAnimFormID = 0x05030569
						ssStruct.PositionID = "DTSIXFMM_735_S4"
						ssStruct.PositionOrigID = "FMM-Human-Couch02-06Blowjob"
					else
						ssStruct.FAnimFormID = 0x05002763				; first if SC < 1.2.6
						ssStruct.MAnimFormID = 0x05002764
						ssStruct.OAnimFormID = 0x05002765
						ssStruct.PositionID = "DTSIXFMM_735_S1"
						ssStruct.PositionOrigID = "FMM-Couch02-03Handjob"
					endIf
				endIf
			elseIf (seqID == 736)		
				if (scEVB)
					ssStruct.ArmorNudeAGun = 1
				endIf
				if (stageNumber == 1)						
					ssStruct.FAnimFormID = 0x0500C001
					ssStruct.MAnimFormID = 0x0500C002
					ssStruct.PositionID = "DTSIX_736_S1"
					ssStruct.PositionOrigID = "FM-Couch01-01Tease"
				elseIf (stageNumber == 2)					
					ssStruct.FAnimFormID = 0x05003E34
					ssStruct.MAnimFormID = 0x05003E35
					ssStruct.PositionID = "DTSIX_736_S2"
					ssStruct.PositionOrigID = "FM-Couch01-03Spoon"
				elseIf (stageNumber == 3 || (longScene <= 0 && stageNumber >= 5))
					ssStruct.FAnimFormID = 0x05004D6E
					ssStruct.MAnimFormID = 0x05004D6F
					ssStruct.PositionID = "DTSIX_736_S3"
					ssStruct.PositionOrigID = "FM-Couch01-04Spoon"
				elseIf (stageNumber == 4)				
					ssStruct.FAnimFormID = 0x05006444
					ssStruct.MAnimFormID = 0x05006445
					ssStruct.PositionID = "DTSIX_736_S4"
					ssStruct.PositionOrigID = "FM-Couch01-05Spoon"
				elseIf (longScene >= 1 && stageNumber == 5)
					ssStruct.FAnimFormID = 0x0502B0AB					;v1.2
					ssStruct.MAnimFormID = 0x0502B0AC
					ssStruct.PositionID = "DTSIX_736_S5"
					ssStruct.PositionOrigID = "FM-Couch01-06Spoon"
				elseIf (longScene >= 2 && stageNumber == 6)
					ssStruct.FAnimFormID = 0x0502DED1					;v1.2.2
					ssStruct.MAnimFormID = 0x0502DED2
					ssStruct.PositionID = "DTSIX_736_S6"
					ssStruct.PositionOrigID = "SC-FM-Human-Couch01-07ClimaxLoop"
				endIf
			elseIf (seqID == 737)
				if (other == 0)			
					if (stageNumber == 1)						
						ssStruct.FAnimFormID = 0x05000FF0
						ssStruct.MAnimFormID = 0x05000FF1
						if (scEVB)
							ssStruct.ArmorNudeAGun = 2
						endIf
						ssStruct.PositionID = "DTSIX_737_S1"
					elseIf (stageNumber == 2)
						if (longScene >= 1)
							ssStruct.FAnimFormID = 0x050263E3
							ssStruct.MAnimFormID = 0x050263E4
							if (scEVB)
								ssStruct.ArmorNudeAGun = 1
							endIf
							ssStruct.PositionID = "DTSIX_737_S2"
						else
							ssStruct.FAnimFormID = 0x05000FF4
							ssStruct.MAnimFormID = 0x05000FF5
							if (scEVB)
								ssStruct.ArmorNudeAGun = 1
							endIf
							ssStruct.PositionID = "DTSIX_737_S4"
						endIf
					elseIf (stageNumber == 3)
						ssStruct.FAnimFormID = 0x05000FF2
						ssStruct.MAnimFormID = 0x05000FF3
						if (scEVB)
							ssStruct.ArmorNudeAGun = 1
						endIf
						ssStruct.PositionID = "DTSIX_737_S3"
					elseIf (stageNumber == 4)
						ssStruct.FAnimFormID = 0x05000FF4
						ssStruct.MAnimFormID = 0x05000FF5
						if (scEVB)
							ssStruct.ArmorNudeAGun = 1
						endIf
						ssStruct.PositionID = "DTSIX_737_S4"
					elseIf (stageNumber == 5)		
						ssStruct.FAnimFormID = 0x050073B5
						ssStruct.MAnimFormID = 0x050073B6
						if (scEVB)
							ssStruct.ArmorNudeAGun = 1
						endIf
						ssStruct.PositionID = "DTSIX_737_S5"
					elseIf (stageNumber == 6)		
						ssStruct.FAnimFormID = 0x05021EF0
						ssStruct.MAnimFormID = 0x05021EF1
						if (scEVB)
							ssStruct.ArmorNudeAGun = 1
						endIf
						ssStruct.PositionID = "DTSIX_737_S6"
					elseIf (stageNumber == 7)		
						ssStruct.FAnimFormID = 0x05026B80
						ssStruct.MAnimFormID = 0x05026B81
						if (scEVB)
							ssStruct.ArmorNudeAGun = 1
						endIf
						ssStruct.StageTime = 4.5
						ssStruct.PositionOrigID = "FM-Armchair01-07ClimaxLoop"
						ssStruct.PositionID = "DTSIX_737_S7"
					elseIf (stageNumber == 8)		
						ssStruct.FAnimFormID = 0x05026B82
						ssStruct.MAnimFormID = 0x05026B83
						if (scEVB)
							ssStruct.ArmorNudeAGun = 1
						endIf
						ssStruct.PositionID = "DTSIX_737_S8"
						ssStruct.PositionOrigID = "FM-Armchair01-08Finish"
					endIf
				else
					; SC_FMM-Chair01-02Handjob-Doggy	- v2.17 switched male roles O and M
					ssStruct.ArmorNudeBGun = 0
					if (stageNumber == 1)					
						ssStruct.FAnimFormID = 0x05001028
						ssStruct.OAnimFormID = 0x05001029
						ssStruct.MAnimFormID = 0x0500102A
						ssStruct.PositionID = "DTSIXFMM_737_S1"
					elseIf (stageNumber == 2)
						ssStruct.FAnimFormID = 0x0500102B
						ssStruct.OAnimFormID = 0x0500102C
						ssStruct.MAnimFormID = 0x0500102D
						ssStruct.PositionID = "DTSIXFMM_737_S2"
					elseIf (stageNumber == 3)
						ssStruct.FAnimFormID = 0x0500102E
						ssStruct.OAnimFormID = 0x0500102F
						ssStruct.MAnimFormID = 0x05001030
						ssStruct.PositionID = "DTSIXFMM_737_S3"
					elseIf (stageNumber == 4)
						ssStruct.FAnimFormID = 0x05001031	
						ssStruct.OAnimFormID = 0x05001032
						ssStruct.MAnimFormID = 0x05001033
						ssStruct.PositionID = "DTSIXFMM_737_S4"
					elseIf (stageNumber == 5)
						ssStruct.FAnimFormID = 0x0500181C	
						ssStruct.OAnimFormID = 0x0500181D
						ssStruct.MAnimFormID = 0x0500181E
						ssStruct.PositionID = "DTSIXFMM_737_S5"
					elseIf (stageNumber == 6)
						ssStruct.FAnimFormID = 0x0500181F	
						ssStruct.OAnimFormID = 0x05001820
						ssStruct.MAnimFormID = 0x05001821
						ssStruct.PositionID = "DTSIXFMM_737_S6"
					endIf
				endIf
			elseIf (seqID == 738)
				int stNum = 1
				if (longScene > 0)
					stNum = 2
					if (stageNumber == 1)
						; start with lap dance
						ssStruct.FAnimFormID = 0x05001800
						ssStruct.MAnimFormID = 0x05001801
						ssStruct.StageTime = 17.0
						if (genders == 1)
							ssStruct.PositionID = "DTSIXFF_739_S1"
						else
							ssStruct.PositionID = "DTSIX_739_S1"
						endIf
						return ssStruct
					endIf
				endIf
				if (stageNumber == stNum)
					if (longScene > 0)
						ssStruct.FAnimFormID = 0x050263E5
						ssStruct.MAnimFormID = 0x050263E6
						ssStruct.PositionID = "DTSIX_738_S1"
					else
						ssStruct.FAnimFormID = 0x05000FF6
						ssStruct.MAnimFormID = 0x05000FF7
						ssStruct.PositionID = "DTSIX_738_S2"
					endIf
				elseIf (stageNumber == (stNum + 1))
					if (Utility.RandomInt(1,6) > 3)
						ssStruct.FAnimFormID = 0x05000FF8
						ssStruct.MAnimFormID = 0x05000FF9
						ssStruct.PositionID = "DTSIX_738_S3"
						ssStruct.PositionOrigID = "SC-FM-Human-Armchair02-03Handjob"
					else
						ssStruct.FAnimFormID = 0x05000FF6
						ssStruct.MAnimFormID = 0x05000FF7
						ssStruct.PositionID = "DTSIX_738_S2"
					endIf
				elseIf (stageNumber == (stNum + 2))				
					ssStruct.FAnimFormID = 0x05000FFA
					ssStruct.MAnimFormID = 0x05000FFB
					ssStruct.PositionID = "DTSIX_738_S4"
				elseIf (stageNumber == (stNum + 3))
					ssStruct.FAnimFormID = 0x05000FFC
					ssStruct.MAnimFormID = 0x05000FFD
					ssStruct.PositionID = "DTSIX_738_S5"
				elseIf (stageNumber == (stNum + 4))
					ssStruct.FAnimFormID = 0x05000FFE
					ssStruct.MAnimFormID = 0x05000FFF
					ssStruct.PositionID = "DTSIX_738_S6"
				elseIf (stageNumber == (stNum + 5))
					ssStruct.FAnimFormID = 0x050017F8
					ssStruct.MAnimFormID = 0x050017F9
					ssStruct.PositionID = "DTSIX_738_S7"
				else
					ssStruct.FAnimFormID = 0x050017FA
					ssStruct.MAnimFormID = 0x050017FB
					ssStruct.PositionID = "DTSIX_738_S8"
				endIf
			elseIf (seqID == 739)						; lap dance
				ssStruct.FAnimFormID = 0x05001800
				if (other <= 0)
					ssStruct.MAnimFormID = 0x05001801
				endIf
				ssStruct.ArmorNudeAGun = -2				; no male swap
				ssStruct.StageTime = 31.0
				ssStruct.PositionID = "DTSIX_739_S1"
				ssStruct.PositionOrigID = "FM-LapDance01-01LapDance"
			elseIf (seqID == 740)		
				ssStruct.StageTime = 20.0
				if (stageNumber == 1)
					ssStruct.FAnimFormID = 0x0500182D
					ssStruct.MAnimFormID = 0x0500182E
					ssStruct.PositionID = "DTSIXF_740_S1"
					ssStruct.PositionOrigID = "F-Dance02-01TwerkStart"
				else
					ssStruct.FAnimFormID = 0x0500182E
					ssStruct.MAnimFormID = 0x0500182D
					ssStruct.PositionID = "DTSIXF_740_S2"
					ssStruct.PositionOrigID = "F-Dance03-01TwerkStart"
				endIf
			elseIf (seqID == 741)		
				ssStruct.StageTime = 30.0
				if (stageNumber == 1)
					ssStruct.FAnimFormID = 0x05024CE2
					ssStruct.PositionID = "F-StripPole01-01PoleDance"
					ssStruct.PositionOrigID = "F-StripPole01-01PoleDance"
				elseIf (stageNumber == 2)
					ssStruct.FAnimFormID = 0x05024CE3
					ssStruct.PositionID = "F-StripPole01-02PoleDance"
					ssStruct.PositionOrigID = "F-StripPole01-02PoleDance"
				elseIf (stageNumber == 3)											;1.2.3
					ssStruct.FAnimFormID = 0x0502EE23
					ssStruct.PositionID = "SC-F-Human-StripPole01-03PoleDance-F1"
					ssStruct.PositionOrigID = "SC-F-Human-StripPole01-03PoleDance-F1"
				else
					ssStruct.FAnimFormID = 0x0502EE24
					ssStruct.PositionID = "SC-F-Human-StripPole01-04PoleDance-F1"
					ssStruct.PositionOrigID = "SC-F-Human-StripPole01-04PoleDance-F1"
				endIf
			elseIf (seqID == 742)
				if (stageNumber == 1)						
					ssStruct.FAnimFormID = 0x05027337
					ssStruct.MAnimFormID = 0x05027338
					ssStruct.ArmorNudeAGun = 1
					ssStruct.PositionID = "DTSIX_742_S1"
					ssStruct.PositionOrigID = "FM-WeightBench01-01Tease"
				elseIf (stageNumber == 2)					
					ssStruct.FAnimFormID = 0x05027339
					ssStruct.MAnimFormID = 0x0502733A
					ssStruct.PositionID = "DTSIX_742_S2"
					ssStruct.PositionOrigID = "FM-WeightBench01-03Cowgirl"
				elseIf (stageNumber == 3)
					ssStruct.FAnimFormID = 0x0502733B
					ssStruct.MAnimFormID = 0x0502733C
					ssStruct.PositionID = "DTSIX_742_S3"
					ssStruct.PositionOrigID = "FM-WeightBench01-04Cowgirl"
				elseIf (stageNumber == 4 || stageNumber == 6)				
					ssStruct.FAnimFormID = 0x0502733D
					ssStruct.MAnimFormID = 0x0502733E
					ssStruct.PositionID = "DTSIX_742_S4"
					ssStruct.PositionOrigID = "FM-WeightBench01-05Cowgirl"
				elseIf (stageNumber == 5)				
					ssStruct.FAnimFormID = 0x0502733F
					ssStruct.MAnimFormID = 0x05027340
					ssStruct.PositionID = "DTSIX_742_S5"
					ssStruct.PositionOrigID = "FM-WeightBench01-06Cowgirl"
				endIf
			elseIf (seqID == 743)	
				ssStruct.FAnimFormID = 0x050045CF
				ssStruct.MAnimFormID = 0x050045D0
				ssStruct.StageTime = 36.0
				ssStruct.PositionID = "DTSIX_743_S1"
				ssStruct.PositionOrigID = "FM-Table01-03Missionary"
			elseIf (seqID == 744)		
				ssStruct.FAnimFormID = 0x0500B070
				ssStruct.MAnimFormID = 0x0500B071
				ssStruct.StageTime = 36.0
				ssStruct.PositionID = "DTSIX_744_S1"
				ssStruct.PositionOrigID = "FM-RoundTable01-03Doggy"
			elseIf (seqID == 745)		
				ssStruct.FAnimFormID = 0x05006C12
				ssStruct.MAnimFormID = 0x05006C13
				ssStruct.StageTime = 36.0
				ssStruct.PositionID = "DTSIX_745_S1"
				ssStruct.PositionOrigID = "FM-RoundTable02-03RoughSideways"
			elseIf (seqID == 746)
				
				if (stageNumber == 1 && longScene >= 1)
					ssStruct.FAnimFormID = 0x0502B868
					ssStruct.MAnimFormID = 0x0502B869
					if (longScene < 2)
						ssStruct.StageTime = 14.0
					endIf
					ssStruct.PositionID = "DTSIX_746_S1"	
					ssStruct.PositionOrigID = "SC-FM-Human-Motorbike01-01Tease"
				elseIf (longScene <= 0 || stageNumber == 2)
					ssStruct.FAnimFormID = 0x0502171E
					ssStruct.MAnimFormID = 0x0502171F
					if (scEVB)
						ssStruct.ArmorNudeAGun = 1
					endIf
					if (longScene <= 0)
						ssStruct.StageTime = 36.0
					endIf
					ssStruct.PositionID = "DTSIX_746_S2"	
					ssStruct.PositionOrigID = "FM-Motorbike01-03Cowgirl"
				elseIf (stageNumber == 3)
					ssStruct.FAnimFormID = 0x0502E678
					ssStruct.MAnimFormID = 0x0502E679
					ssStruct.PositionID = "DTSIX_746_S3"	
					ssStruct.PositionOrigID = "SC-FM-Human-Motorbike01-04Cowgirl"
				elseIf (stageNumber == 4 || stageNumber == 6)
					ssStruct.FAnimFormID = 0x0502E67A
					ssStruct.MAnimFormID = 0x0502E67B
					ssStruct.PositionID = "DTSIX_746_S4"	
					ssStruct.PositionOrigID = "SC-FM-Human-Motorbike01-05Cowgirl"
				elseIf (stageNumber == 5)
					ssStruct.FAnimFormID = 0x0502E67C
					ssStruct.MAnimFormID = 0x0502E67D
					ssStruct.PositionID = "DTSIX_746_S5"	
					ssStruct.PositionOrigID = "SC-FM-Human-Motorbike01-06Cowgirl"
				endIf
			elseIf (seqID == 747)
				ssStruct.ArmorNudeAGun = 0
				if (stageNumber == 1)
					ssStruct.FAnimFormID = 0x0502732B
					ssStruct.MAnimFormID = 0x0502732C
					ssStruct.PositionID = "DTSIX_747_S1"	
					ssStruct.PositionOrigID = "FM-ShowerPlayerHouse01-01Tease"
				elseIf (stageNumber == 2)
					ssStruct.FAnimFormID = 0x0502732D
					ssStruct.MAnimFormID = 0x0502732E
					ssStruct.PositionID = "DTSIX_747_S2"	
					ssStruct.PositionOrigID = "FM-ShowerPlayerHouse01-03Doggy"
				elseIf (stageNumber == 3)
					ssStruct.FAnimFormID = 0x0502732F
					ssStruct.MAnimFormID = 0x05027330
					ssStruct.PositionID = "DTSIX_747_S3"	
					ssStruct.PositionOrigID = "FM-ShowerPlayerHouse01-04Doggy"
				elseIf (stageNumber == 4); || stageNumber == 6)							; v2.53 -- skip climax
					ssStruct.FAnimFormID = 0x05027331
					ssStruct.MAnimFormID = 0x05027332
					ssStruct.PositionID = "DTSIX_747_S4"	
					ssStruct.PositionOrigID = "SC-FM-Human-ShowerPlayerHouse01-05Doggy"
				elseIf (stageNumber == 5)												; v2.49
					ssStruct.FAnimFormID = 0x05027333
					ssStruct.MAnimFormID = 0x05027334
					ssStruct.PositionID = "DTSIX_747_S5"								
					ssStruct.PositionOrigID = "SC-FM-Human-ShowerPlayerHouse01-06Doggy"
				else																	; v2.49, SC 1.2.4
					ssStruct.FAnimFormID = 0x0502FD94									
					ssStruct.MAnimFormID = 0x0502FD95									; ?? appears to duplicate female stance
					ssStruct.PositionID = "DTSIX_747_S6"									
					ssStruct.PositionOrigID = "SC-FM-Human-ShowerPlayerHouse01-07ClimaxLoop"
				endIf													; SC 1.2.6 added -08Finish IDs 31568, 9
			elseIf (seqID == 748)
				if (other == 0)
					if (stageNumber == 1)
						ssStruct.FAnimFormID = 0x0500CEDF
						ssStruct.MAnimFormID = 0x0500CEE0
						ssStruct.PositionID = "DTSIX_748_S1"
						ssStruct.PositionOrigID = "FM-Stocks01-01Tease"
					elseIf (stageNumber == 2)
						ssStruct.FAnimFormID = 0x05001818
						ssStruct.MAnimFormID = 0x05001819
						ssStruct.PositionID = "DTSIX_748_S2"
						ssStruct.PositionOrigID = "FM-Stocks01-02Start"
					elseIf (stageNumber == 3)
						ssStruct.FAnimFormID = 0x05001018
						ssStruct.MAnimFormID = 0x05001019
						ssStruct.PositionID = "DTSIX_748_S3"
						ssStruct.PositionOrigID = "FM-Stocks01-03Doggy"
					elseIf (stageNumber == 4 || stageNumber == 6)
						ssStruct.FAnimFormID = 0x0500181A
						ssStruct.MAnimFormID = 0x0500181B
						ssStruct.PositionID = "DTSIX_748_S4"
						ssStruct.PositionOrigID = "FM-Stocks01-04Doggy"
					elseIf (stageNumber == 5)
						ssStruct.FAnimFormID = 0x0501325E
						ssStruct.MAnimFormID = 0x0501325F
						ssStruct.PositionID = "DTSIX_748_S5"
						ssStruct.PositionOrigID = "FM-Stocks01-05Doggy"
					endIf
				else
					ssStruct.FAnimFormID = 0x0500104F
					ssStruct.MAnimFormID = 0x05001050
					ssStruct.OAnimFormID = 0x05001051
					ssStruct.ArmorNudeBGun = 0
					if (scEVB)
						ssStruct.ArmorNudeBGun = 1
					endIf
					ssStruct.StageTime = 32.0
					ssStruct.PositionID = "DTSIXFMM_748_S1"
					ssStruct.PositionOrigID = "FMM-Stocks01-02DoubleTeam"
				endIf
				
			elseIf (seqID == 749)
				if (other == 0)
					if (stageNumber == 1 || stageNumber == 4)
						ssStruct.FAnimFormID = 0x0500100E
						ssStruct.MAnimFormID = 0x0500100F
						ssStruct.PositionID = "DTSIX_749_S1"
						ssStruct.PositionOrigID = "FM-HydroPillory01-02Doggy"
					elseIf (stageNumber == 2)
						ssStruct.FAnimFormID = 0x05027323
						ssStruct.MAnimFormID = 0x05027324
						ssStruct.PositionID = "DTSIX_749_S2"
						ssStruct.PositionOrigID = "FM-HydroPillory01-03Doggy"
					else
						ssStruct.FAnimFormID = 0x05027325
						ssStruct.MAnimFormID = 0x05027326
						ssStruct.PositionID = "DTSIX_749_S2"
						ssStruct.PositionOrigID = "FM-HydroPillory01-03Doggy"
					endIf
				else
					ssStruct.FAnimFormID = 0x05001040
					ssStruct.MAnimFormID = 0x05001041
					ssStruct.OAnimFormID = 0x05001042
					ssStruct.ArmorNudeBGun = 0
					ssStruct.PositionID = "DTSIXFMM_749_S1"
					ssStruct.PositionOrigID = "FMM-HydroPillory01-02DoubleTeam"
				endIf
			endIf
		elseIf (seqID >= 750 && seqID < 760)								; furniture + 1 standing
			if (seqID == 751)
				if (stageNumber == 1)	
					ssStruct.FAnimFormID = 0x050263DB
					ssStruct.MAnimFormID = 0x050263DC
					ssStruct.PositionID = "DTSIX_751_S1"
					ssStruct.PositionOrigID = "FM-Standing01-03Doggy"
				elseIf (stageNumber == 2)
					ssStruct.FAnimFormID = 0x050263DD
					ssStruct.MAnimFormID = 0x050263DE
					ssStruct.PositionID = "DTSIX_751_S2"
					ssStruct.PositionOrigID = "FM-Standing01-04Doggy"
				elseIf (stageNumber == 3)
					ssStruct.FAnimFormID = 0x050263DF
					ssStruct.MAnimFormID = 0x050263E0
					ssStruct.PositionID = "DTSIX_751_S3"
					ssStruct.PositionOrigID = "FM-Standing01-05Doggy"
				else
					ssStruct.FAnimFormID = 0x050263E1
					ssStruct.MAnimFormID = 0x050263E2
					ssStruct.PositionID = "DTSIX_751_S4"
					ssStruct.PositionOrigID = "FM-Standing01-06Doggy"
				endIf
			elseIf (seqID == 752)
				
				if (stageNumber == 1)	
					ssStruct.FAnimFormID = 0x0500C003
					ssStruct.MAnimFormID = 0x0500C004
					ssStruct.PositionID = "DTSIX_752_S1"
					ssStruct.PositionOrigID = "FM-Desk01-01Tease"
				elseIf (stageNumber == 2 || (longScene <= 0 && stageNumber == 4))
					ssStruct.FAnimFormID = 0x05001FC9	; 
					ssStruct.MAnimFormID = 0x05001FCA
					ssStruct.PositionID = "DTSIX_752_S2"
					ssStruct.PositionOrigID = "FM-Desk01-03Doggy"
				elseIf (stageNumber == 3)
					ssStruct.FAnimFormID = 0x0500C005
					ssStruct.MAnimFormID = 0x0500C006
					ssStruct.PositionID = "DTSIX_752_S3"
					ssStruct.PositionOrigID = "FM-Desk01-04Doggy"
				elseIf (stageNumber == 4 && longScene > 0)				; v1.2
					ssStruct.FAnimFormID = 0x0502B0AD	
					ssStruct.MAnimFormID = 0x0502B0AE
					ssStruct.PositionID = "DTSIX_752_S4"
					ssStruct.PositionOrigID = "SC-FM-Human-Desk01-05Doggy"
				elseIf (stageNumber == 5 || longScene == 1)
					ssStruct.FAnimFormID = 0x0502B0B3					; v1.2
					ssStruct.MAnimFormID = 0x0502B0B4
					ssStruct.PositionID = "DTSIX_752_S5"
					ssStruct.PositionOrigID = "SC-FM-Human-Desk01-06Doggy"
				elseIf (stageNumber == 6 && longScene >= 2)
					ssStruct.FAnimFormID = 0x0502E676					; v1.2.2
					ssStruct.MAnimFormID = 0x0502E677
					ssStruct.PositionID = "DTSIX_752_S6"
					ssStruct.PositionOrigID = "SC-FM-Human-Desk01-07ClimaxLoop"
				endIf
			elseIf (seqID == 753)
				if (stageNumber == 1 && longScene > 0)
					ssStruct.FAnimFormID = 0x050344D8					; SC 1.3.0 - v2.88
					ssStruct.MAnimFormID = 0x050344D9
					ssStruct.PositionID = "DTSIX_753_ST"
					ssStruct.PositionOrigID = "FM-Stool01-01Tease"
				elseIf (stageNumber == 2 && longScene > 0)
					ssStruct.FAnimFormID = 0x050344DA					; SC 1.3.0 - v2.88
					ssStruct.MAnimFormID = 0x050344DB
					ssStruct.PositionID = "DTSIX_753_S0"
					ssStruct.PositionOrigID = "FM-Stool01-01Start"
				elseIf ((stageNumber == 2 && longScene <= 0) || (longScene > 0 && stageNumber == 4))	
					ssStruct.FAnimFormID = 0x0500D67A
					ssStruct.MAnimFormID = 0x0500D67B
					ssStruct.PositionID = "DTSIX_753_S2"
					ssStruct.PositionOrigID = "FM-Stool01-04Doggy"
				elseIf (stageNumber == 3)
					ssStruct.FAnimFormID = 0x05002761
					ssStruct.MAnimFormID = 0x05002762
					ssStruct.PositionID = "DTSIX_753_S1"
					ssStruct.PositionOrigID = "FM-Stool01-03Doggy"
				else
					ssStruct.FAnimFormID = 0x05006C14
					ssStruct.MAnimFormID = 0x05006C15
					ssStruct.PositionID = "DTSIX_753_S3"
					ssStruct.PositionOrigID = "FM-Stool01-05Doggy"
				endIf
			elseIf (seqID == 754)	
				
				if (scEVB)
					ssStruct.ArmorNudeAGun = 1
				endIf
				if (longScene <= 0)
					ssStruct.StageTime = 32.0
					ssStruct.FAnimFormID = 0x05001000	
					ssStruct.MAnimFormID = 0x05001001
					ssStruct.PositionID = "DTSIX_754_S3"				
					ssStruct.PositionOrigID = "FM-ChairHigh01-03Doggy"
				else
					; additional stages SC 1.2.8 - v2.79
					; some stages male holds arm of armchair
					if (stageNumber == 1)	
						ssStruct.FAnimFormID = 0x05032D42
						ssStruct.MAnimFormID = 0x05032D43
						ssStruct.PositionID = "DTSIX_754_S1"
						ssStruct.PositionOrigID = "SC-FM-Human-ChairHigh01-01Tease"
					elseIf (stageNumber == 2)
						ssStruct.FAnimFormID = 0x05032D44
						ssStruct.MAnimFormID = 0x05032D45
						ssStruct.PositionID = "DTSIX_754_S2"
						ssStruct.PositionOrigID = "SC-FM-Human-ChairHigh01-02Start"
					elseIf (stageNumber == 3)
						ssStruct.FAnimFormID = 0x05001000	
						ssStruct.MAnimFormID = 0x05001001
						ssStruct.PositionID = "DTSIX_754_S3"
						ssStruct.PositionOrigID = "SC-FM-Human-ChairHigh01-03Doggy"
					elseIf (stageNumber == 4)
						ssStruct.FAnimFormID = 0x05032D46
						ssStruct.MAnimFormID = 0x05032D47
						ssStruct.PositionID = "DTSIX_754_S4"
						ssStruct.PositionOrigID = "SC-FM-Human-ChairHigh01-04Doggy"
					elseIf (stageNumber == 5)
						ssStruct.FAnimFormID = 0x05032D48
						ssStruct.MAnimFormID = 0x05032D49
						ssStruct.PositionID = "DTSIX_754_S5"
						ssStruct.PositionOrigID = "SC-FM-Human-ChairHigh01-05Doggy"
					elseIf (longScene || Utility.RandomInt(1,6) >= 4)
						ssStruct.FAnimFormID = 0x05032D4A
						ssStruct.MAnimFormID = 0x05032D4B
						ssStruct.PositionID = "DTSIX_754_S6"
						ssStruct.PositionOrigID = "SC-FM-Human-ChairHigh01-06Doggy"
					else
						ssStruct.FAnimFormID = 0x05033CB2
						ssStruct.MAnimFormID = 0x05033CB3
						ssStruct.PositionID = "DTSIX_754_S8"
						ssStruct.PositionOrigID = "SC-FM-Human-ChairHigh01-08Finish"
					endIf
				endIf
				
			elseIf (seqID == 755)
				if (stageNumber == 1)
					ssStruct.FAnimFormID = 0x05001002	
					ssStruct.MAnimFormID = 0x05001003
					if (longScene <= 0)
						ssStruct.StageTime = 32.0
					endIf
					ssStruct.PositionID = "DTSIX_755_S1"
					ssStruct.PositionOrigID = "FM-ChairLow01-03Doggy"
				elseIf (stageNumber == 2)										;v2.84, SC 1.2.9
					ssStruct.FAnimFormID = 0x05033CB4	
					ssStruct.MAnimFormID = 0x05033CB5
					ssStruct.PositionID = "DTSIX_755_S2"
					ssStruct.PositionOrigID = "FM-ChairLow01-04Doggy"
				else
					ssStruct.FAnimFormID = 0x05033CB6	
					ssStruct.MAnimFormID = 0x05033CB7
					ssStruct.PositionID = "DTSIX_755_S3"
					ssStruct.PositionOrigID = "FM-ChairLow01-05Doggy"
				endIf
				
			elseIf (seqID == 756)
				if (other > 0)
					ssStruct.FAnimFormID = 0x05001822
					ssStruct.MAnimFormID = 0x05001823
					ssStruct.OAnimFormID = 0x05001824
					ssStruct.StageTime = 26.0
					ssStruct.PositionID = "DTSIXFMM_756_S1"
					ssStruct.PositionOrigID = "FMM-PoolTable01-01Tease"
				elseIf (stageNumber == 1)
					ssStruct.FAnimFormID = 0x05001802
					ssStruct.MAnimFormID = 0x05001803
					ssStruct.StageTime = 13.0
					ssStruct.PositionID = "DTSIX_756_S1"
					ssStruct.PositionOrigID = "FM-PoolTable01-01Tease"
				elseIf (stageNumber == 2)
					ssStruct.FAnimFormID = 0x05001804
					ssStruct.MAnimFormID = 0x05001805
					ssStruct.StageTime = 2.1
					ssStruct.PositionID = "DTSIX_756_S2"
					ssStruct.PositionOrigID = "FM-PoolTable01-02Start"
				elseIf (stageNumber == 3)
					ssStruct.FAnimFormID = 0x05001807
					ssStruct.MAnimFormID = 0x05001806
					ssStruct.PositionID = "DTSIX_756_S3"
					ssStruct.PositionOrigID= "FM-PoolTable01-03Cunnilingus"
				elseIf (stageNumber == 4)
					ssStruct.FAnimFormID = 0x05001808
					ssStruct.MAnimFormID = 0x05001809
					ssStruct.StageTime = 8.5
					ssStruct.PositionID = "DTSIX_756_S4"
					ssStruct.PositionOrigID = "FM-PoolTable01-04Cunnilingus"
				elseIf (stageNumber == 5)
					ssStruct.FAnimFormID = 0x0500180A
					ssStruct.MAnimFormID = 0x0500180B
					ssStruct.StageTime = 9.0
					if (scEVB)
						ssStruct.ArmorNudeAGun = 1
					endIf
					ssStruct.PositionID = "DTSIX_756_S5"
					ssStruct.PositionOrigID = "FM-PoolTable01-05Missionary"
				elseIf (stageNumber == 6)
					ssStruct.FAnimFormID = 0x05006C10
					ssStruct.MAnimFormID = 0x05006C11
					if (scEVB)
						ssStruct.ArmorNudeAGun = 1
					endIf
					ssStruct.PositionID = "DTSIX_756_S6"
					ssStruct.PositionOrigID = "FM-PoolTable01-06Missionary"
				else
					ssStruct.FAnimFormID = 0x0500C7A6
					ssStruct.MAnimFormID = 0x0500C7A7
					ssStruct.PositionID = "DTSIX_756_S7"
					ssStruct.PositionOrigID = "FM-PoolTable01-07Missionary"
				endIf
			elseIf (seqID == 757)	
				if (stageNumber == 1)
					ssStruct.FAnimFormID = 0x0500180C
					ssStruct.MAnimFormID = 0x0500180D
					ssStruct.PositionID = "DTSIX_757_S1"
					ssStruct.PositionOrigID = "FM-PoolTable02-01RoughTease"
				elseIf (stageNumber == 2)
					ssStruct.FAnimFormID = 0x0500180E
					ssStruct.MAnimFormID = 0x0500180F
					ssStruct.PositionID = "DTSIX_757_S2"
					ssStruct.PositionOrigID = "FM-PoolTable02-02RoughStart"
				elseIf (stageNumber == 3)
					ssStruct.FAnimFormID = 0x05001810
					ssStruct.MAnimFormID = 0x05001811
					ssStruct.StageTime = 9.0
					ssStruct.PositionID = "DTSIX_757_S3"
					ssStruct.PositionOrigID = "FM-PoolTable02-03RoughDoggy"
				elseIf (stageNumber == 4)
					ssStruct.FAnimFormID = 0x05001812  
					ssStruct.MAnimFormID = 0x05001813
					ssStruct.PositionID = "DTSIX_757_S4"
					ssStruct.PositionOrigID = "FM-PoolTable02-04RoughDoggy"			; leaning against
				elseIf (stageNumber >= 5)
					ssStruct.FAnimFormID = 0x05001814
					ssStruct.MAnimFormID = 0x05001815
					ssStruct.PositionID = "DTSIX_757_S5"
					ssStruct.PositionOrigID = "SC-FM-Human-PoolTable02-05RoughBlowjob"			; this changed
				endIf
			elseIf (seqID == 758)								;SIX_SC_FM-Seat01			
				if (other == 0)
					if (scEVB)
						ssStruct.ArmorNudeAGun = 1
					endIf
					if (stageNumber == 2)						;SIX_SC_FM-Seat01-03Cowgirl
						ssStruct.FAnimFormID = 0x050082FD
						ssStruct.MAnimFormID = 0x050082FE
						ssStruct.PositionID = "DTSIX_758_S2"
						ssStruct.PositionOrigID = "FM-Seat01-04Cowgirl"
					elseIf (stageNumber == 3)
						ssStruct.FAnimFormID = 0x0500CF45
						ssStruct.MAnimFormID = 0x0500CF46
						ssStruct.PositionID = "DTSIX_758_S3"
						ssStruct.PositionOrigID = "FM-Seat01-05Cowgirl"
					elseIf (stageNumber == 1 || longScene <= 0)
						ssStruct.FAnimFormID = 0x05006446	; 1,4
						ssStruct.MAnimFormID = 0x05006447
						ssStruct.PositionID = "DTSIX_758_S1"
						ssStruct.PositionOrigID = "FM-Seat01-03Cowgirl"
					elseIf (stageNumber == 4)
						ssStruct.FAnimFormID = 0x05030562				;v2.50  SC 1.2.5
						ssStruct.MAnimFormID = 0x05030563
						ssStruct.PositionID = "DTSIX_758_S4"
						ssStruct.PositionOrigID = "SC-FM-Human-Seat01-06Cowgirl"
					endIf
				else				
					if (stageNumber == 1)					
						ssStruct.FAnimFormID = 0x05001825
						ssStruct.MAnimFormID = 0x05001827
						ssStruct.OAnimFormID = 0x05001826		; v2.25 reverse roles
						ssStruct.ArmorNudeBGun = 0
						ssStruct.PositionID = "DTSIXFMM_758_S1"
						ssStruct.PositionOrigID = "FMM-Standing01-01Caught"
					elseIf (stageNumber == 2 || (stageNumber >= 4 && longScene <= 1))
						ssStruct.FAnimFormID = 0x0500104C	
						ssStruct.MAnimFormID = 0x0500104E
						ssStruct.OAnimFormID = 0x0500104D
						if (scEVB)
							ssStruct.ArmorNudeAGun = 1
							ssStruct.ArmorNudeBGun = 1
						else
							ssStruct.ArmorNudeBGun = 0
						endIf
						ssStruct.PositionID = "DTSIXFMM_758_S2"
						ssStruct.PositionOrigID = "FMM-Standing01-02DoubleTeam"
					elseIf (stageNumber == 3)
						ssStruct.FAnimFormID = 0x05001828
						ssStruct.MAnimFormID = 0x0500182A
						ssStruct.OAnimFormID = 0x05001829
						if (scEVB)
							ssStruct.ArmorNudeAGun = 1
							ssStruct.ArmorNudeBGun = 1
						else
							ssStruct.ArmorNudeBGun = 0
						endIf
						ssStruct.PositionID = "DTSIXFMM_758_S3"
						ssStruct.PositionOrigID = "FMM-Standing01-03DoubleTeam"
					elseIf (longScene >= 2)
						; added SC 1.2.7 - v2.77
						ssStruct.FAnimFormID = 0x0503254D
						ssStruct.MAnimFormID = 0x0503254F				; reversed roles
						ssStruct.OAnimFormID = 0x0503254E
						if (scEVB)
							ssStruct.ArmorNudeAGun = 1
							ssStruct.ArmorNudeBGun = 1
						else
							ssStruct.ArmorNudeBGun = 0
						endIf
						ssStruct.PositionID = "DTSIXFMM_758_S4"
						ssStruct.PositionOrigID = "FMM-Standing01-05DoubleTeam"
					endIf
				endIf
			elseIf (seqID == 759)
				if (scEVB)
					ssStruct.ArmorNudeAGun = 1
				endIf
				if (stageNumber == 1)						
					ssStruct.FAnimFormID = 0x050099DC
					ssStruct.MAnimFormID = 0x050099DD
					ssStruct.PositionID = "DTSIX_759_S1"
					ssStruct.PositionOrigID = "FM-Bench01-01Tease"		; seated kissing
				elseIf (stageNumber == 2)
					ssStruct.FAnimFormID = 0x0500550B
					ssStruct.MAnimFormID = 0x0500550C
					ssStruct.PositionID = "DTSIX_759_S2"
					ssStruct.PositionOrigID = "FM-Bench01-03ReverseCowgirlAnal"
				elseIf (stageNumber == 3 || (stageNumber >= 5 && longScene <= 0))
					ssStruct.FAnimFormID = 0x0500C744
					ssStruct.MAnimFormID = 0x0500C745
					ssStruct.PositionID = "DTSIX_759_S3"
					ssStruct.PositionOrigID = "FM-Bench01-04ReverseCowgirlAnal"
				elseIf (stageNumber == 4)
					ssStruct.FAnimFormID = 0x05006C0C
					ssStruct.MAnimFormID = 0x05006C0D
					ssStruct.PositionID = "DTSIX_759_S4"
					ssStruct.PositionOrigID = "FM-Bench01-05ReverseCowgirlAnal"
				elseIf (stageNumber == 5)
					ssStruct.FAnimFormID = 0x0502731F
					ssStruct.MAnimFormID = 0x05027320
					ssStruct.PositionID = "DTSIX_759_S5"
					ssStruct.PositionOrigID = "FM-Bench01-06ReverseCowgirlAnal"
				elseIf (stageNumber == 6)											;1.2.2
					ssStruct.FAnimFormID = 0x0502DECF
					ssStruct.MAnimFormID = 0x0502DED0
					ssStruct.PositionID = "DTSIX_759_S6"
					ssStruct.PositionOrigID = "SC-FM-Bench01-07ClimaxLoop"
				endIf	
			endIf
		; --------------------- Supermutant 
		
		elseIf (seqID >= 760 && seqID < 770)
			if (seqID == 760)	
				ssStruct.ArmorNudeAGun = 1
				if (stageNumber == 1)						
					ssStruct.FAnimFormID = 0x0500D6E6
					ssStruct.MAnimFormID = 0x0500D6E7
					ssStruct.PositionID = "DTSIXSM_760_S1"
					ssStruct.PositionOrigID = "FSM-Standing03-01Tease"
				elseIf (stageNumber == 2)
					ssStruct.FAnimFormID = 0x0500D6E8
					ssStruct.MAnimFormID = 0x0500D6E9
					ssStruct.PositionID = "DTSIXSM_760_S2"
					ssStruct.PositionOrigID = "FSM-Standing03-03Carry"
				elseIf (stageNumber == 3)
					ssStruct.FAnimFormID = 0x05012317
					ssStruct.MAnimFormID = 0x05012318
					ssStruct.PositionID = "DTSIXSM_760_S3"
					ssStruct.PositionOrigID = "FSM-Standing03-04Carry"
				elseIf (stageNumber == 4)
					ssStruct.FAnimFormID = 0x05012326
					ssStruct.MAnimFormID = 0x05012327
					ssStruct.PositionID = "DTSIXSM_760_S4"
					ssStruct.PositionOrigID = "FSM-Standing03-05Carry"
				else
					ssStruct.FAnimFormID = 0x0502A156
					ssStruct.MAnimFormID = 0x0502A157
					ssStruct.PositionID = "DTSIXSM_760_S5"
					ssStruct.PositionOrigID = "SC-FM-SuperMutant-Standing03-06Carry"
				endIf
			elseIf (seqID == 761)							
				ssStruct.ArmorNudeAGun = 1
				if (other == 0)
					int sNum = stageNumber
					if (longScene <= 0)
						sNum = stageNumber + 1
					endIf
					if (stageNumber == 1)								;1.2.3
						ssStruct.ArmorNudeAGun = 0
						ssStruct.FAnimFormID = 0x0502F5E0
						ssStruct.MAnimFormID = 0x0502F5E1
						ssStruct.PositionID = "DTSIXSM_761_S1"
						ssStruct.PositionOrigID = "SC-FM-SuperMutant-Standing01-02Start"
					elseIf (stageNumber == 2)
						ssStruct.ArmorNudeAGun = 0
						ssStruct.FAnimFormID = 0x05002F04
						ssStruct.MAnimFormID = 0x05002F05
						ssStruct.PositionID = "DTSIXSM_761_S2"
						ssStruct.PositionOrigID = "FSM-Standing01-03Doggy"
					elseIf (stageNumber == 3)
						ssStruct.ArmorNudeAGun = 0
						ssStruct.FAnimFormID = 0x0500B85F
						ssStruct.MAnimFormID = 0x0500B860
						ssStruct.PositionID = "DTSIXSM_761_S3"
						ssStruct.PositionOrigID = "FSM-Standing01-04Doggy"
					elseIf (stageNumber == 4)
						ssStruct.FAnimFormID = 0x0500B861
						ssStruct.MAnimFormID = 0x0500B862
						ssStruct.PositionID = "DTSIXSM_761_S4"
						ssStruct.PositionOrigID = "FSM-Standing01-05Doggy"
					elseIf (stageNumber >= 5)
						ssStruct.FAnimFormID = 0x0500B863
						ssStruct.MAnimFormID = 0x0500B864
						ssStruct.PositionID = "DTSIXSM_761_S5"
						ssStruct.PositionOrigID = "FSM-Standing01-06Doggy"
					endIf
				else
					if (stageNumber == 1)
						if (longScene > 0)
							ssStruct.StageTime = 15.0
						else
							ssStruct.StageTime = 31.0
						endIf
						ssStruct.FAnimFormID = 0x050104A0
						ssStruct.MAnimFormID = 0x050104A1
						ssStruct.OAnimFormID = 0x050104A2
						ssStruct.ArmorNudeBGun = 0
						if (scEVB)
							ssStruct.ArmorNudeBGun = 1
						endIf
						ssStruct.PositionID = "DTSIXSMSM_761_S1"
						ssStruct.PositionOrigID = "FSMSM-Standing01-03DoubleTeam"
					else
						if (longScene > 0)							; v2.84, SC 1.2.9 added stage
							ssStruct.StageTime = 16.0
						else
							ssStruct.StageTime = 31.0
						endIf
						ssStruct.FAnimFormID = 0x05033CF6
						ssStruct.MAnimFormID = 0x05033CF7
						ssStruct.OAnimFormID = 0x05033CF8
						ssStruct.ArmorNudeBGun = 0
						if (scEVB)
							ssStruct.ArmorNudeBGun = 1
						endIf
						ssStruct.PositionID = "DTSIXSMSM_761_S2"
						ssStruct.PositionOrigID = "FSMSM-Standing01-04DoubleTeam"
					endIf
				endIf
			elseIf (seqID == 762)
				if (stageNumber == 1)						
					ssStruct.FAnimFormID = 0x05007B5F
					ssStruct.MAnimFormID = 0x05007B60
					ssStruct.PositionID = "DTSIXSM_762_S1"
					ssStruct.PositionOrigID = "FSM-Standing02-03Handjob"
				elseIf (stageNumber == 2)
					ssStruct.FAnimFormID = 0x0500DE87
					ssStruct.MAnimFormID = 0x0500DE88
					ssStruct.PositionID = "DTSIXSM_762_S2"
					ssStruct.PositionOrigID = "FSM-Standing02-04Handjob"
				elseIf (stageNumber == 3)
					ssStruct.FAnimFormID = 0x050150E6
					ssStruct.MAnimFormID = 0x050150E7
					ssStruct.PositionID = "DTSIXSM_762_S3"
					ssStruct.PositionOrigID = "FSM-Standing02-05Handjob"
				elseIf (stageNumber == 4)
					ssStruct.FAnimFormID = 0x050150E8
					ssStruct.MAnimFormID = 0x050150E9
					ssStruct.PositionID = "DTSIXSM_762_S4"
					ssStruct.PositionOrigID = "FSM-Standing02-06Handjob"
				endIf
			elseIf (seqID == 763)
				int sNum = stageNumber
				if (longScene < 2)
					sNum = stageNumber + 1
				endIf
				if (sNum == 1)						; 1.2.3
					ssStruct.FAnimFormID = 0x0502F5D8
					ssStruct.MAnimFormID = 0x0502F5D9
					ssStruct.ArmorNudeAGun = 0
					ssStruct.PositionID = "DTSIXSM_763_S1"
					ssStruct.PositionOrigID = "SC-FM-SuperMutant-Floor01-01Tease"
				elseIf (sNum == 2)
					ssStruct.FAnimFormID = 0x0501493E
					ssStruct.MAnimFormID = 0x0501493F
					ssStruct.ArmorNudeAGun = 1
					ssStruct.PositionID = "DTSIXSM_763_S2"
					ssStruct.PositionOrigID = "FSM-Floor01-03Doggy"
				elseIf (sNum == 3)
					ssStruct.FAnimFormID = 0x05014940
					ssStruct.MAnimFormID = 0x05014941
					ssStruct.PositionID = "DTSIXSM_763_S3"
					ssStruct.PositionOrigID = "FSM-Floor01-04Doggy"
				elseIf (sNum == 4)
					ssStruct.FAnimFormID = 0x05014942
					ssStruct.MAnimFormID = 0x05014943
					ssStruct.ArmorNudeAGun = 0
					ssStruct.PositionID = "DTSIXSM_763_S4"
					ssStruct.PositionOrigID = "FSM-Floor01-05Wheelbarrow"
				elseIf (sNum == 5)
					ssStruct.FAnimFormID = 0x05014944
					ssStruct.MAnimFormID = 0x05014945
					ssStruct.ArmorNudeAGun = 2
					ssStruct.PositionID = "DTSIXSM_763_S5"
					ssStruct.PositionOrigID = "FSM-Floor01-06Wheelbarrow"
				elseIf (sNum == 6)										;1.2.2
					ssStruct.FAnimFormID = 0x0502E684
					ssStruct.MAnimFormID = 0x0502E685
					ssStruct.ArmorNudeAGun = 0
					ssStruct.PositionID = "DTSIXSM_763_S6"
					ssStruct.PositionOrigID = "SC-FM-SuperMutant-Floor01-07ClimaxLoop"
				endIf
			elseIf (seqID == 764)							;SIX_SC_FSM-DoubleBed02-03Blowjob
				if (stageNumber == 1)						
					ssStruct.FAnimFormID = 0x05007B5D
					ssStruct.MAnimFormID = 0x05007B5E
					ssStruct.StageTime = 12.0
					ssStruct.ArmorNudeAGun = 2
					ssStruct.PositionID = "DTSIXSM_764_S1"
					ssStruct.PositionOrigID = "FSM-DoubleBed02-03Blowjob"
				elseIf (stageNumber == 2)
					ssStruct.FAnimFormID = 0x050099E2
					ssStruct.MAnimFormID = 0x050099E3
					ssStruct.StageTime = 13.0
					ssStruct.ArmorNudeAGun = 2
					ssStruct.PositionID = "DTSIXSM_764_S2"
					ssStruct.PositionOrigID = "FSM-DoubleBed02-04Blowjob"
				elseIf (stageNumber == 3)
					ssStruct.FAnimFormID = 0x0500A91F
					ssStruct.MAnimFormID = 0x0500A920
					ssStruct.ArmorNudeAGun = 2
					ssStruct.StageTime = 13.0
					ssStruct.PositionID = "DTSIXSM_764_S3"
					ssStruct.PositionOrigID = "FSM-DoubleBed02-05Standing69"
				elseIf (stageNumber == 4)
					ssStruct.FAnimFormID = 0x0500E624
					ssStruct.MAnimFormID = 0x0500E625
					ssStruct.StageTime = 13.0
					ssStruct.PositionID = "DTSIXSM_764_S4"
					ssStruct.PositionOrigID = "FSM-DoubleBed02-06Standing69"
				elseIf (stageNumber == 5)
					ssStruct.FAnimFormID = 0x05012313
					ssStruct.MAnimFormID = 0x05012314
					ssStruct.StageTime = 13.0
					ssStruct.PositionID = "DTSIXSM_764_S5"
					ssStruct.PositionOrigID = "FSM-DoubleBed02-07Standing69"
				elseIf (longScene <= 0 || Utility.RandomInt(1,6) >= 5)
					ssStruct.FAnimFormID = 0x05012315
					ssStruct.MAnimFormID = 0x05012316
					ssStruct.StageTime = 13.0
					ssStruct.ArmorNudeAGun = 1
					ssStruct.PositionID = "DTSIXSM_764_S6"
					ssStruct.PositionOrigID = "FSM-DoubleBed02-08Deepthroat69"
				elseIf (longScene >= 1)
					ssStruct.FAnimFormID = 0x0502E680
					ssStruct.MAnimFormID = 0x0502E681
					ssStruct.StageTime = 13.0
					ssStruct.ArmorNudeAGun = 1
					ssStruct.PositionID = "DTSIXSM_764_S7"
					ssStruct.PositionOrigID = "SC-FM-SuperMutant-DoubleBed02-09ClimaxLoop"
				endIf
			elseIf (seqID == 765)							;SIX_SC_FSM-DoubleBed01-02Start / doggy
				if (stageNumber == 2)
					ssStruct.FAnimFormID = 0x05007B5B
					ssStruct.MAnimFormID = 0x05007B5C
					ssStruct.StageTime = 13.0
					ssStruct.PositionID = "DTSIXSM_765_S2"
					ssStruct.PositionOrigID = "FSM-DoubleBed01-03Doggy"
				elseIf (stageNumber == 3)
					ssStruct.FAnimFormID = 0x0500923E
					ssStruct.MAnimFormID = 0x0500923F
					ssStruct.StageTime = 14.0
					ssStruct.PositionID = "DTSIXSM_765_S3"
					ssStruct.PositionOrigID = "FSM-DoubleBed01-04Doggy"
				elseIf (stageNumber == 4)
					ssStruct.FAnimFormID = 0x0500D6E2
					ssStruct.MAnimFormID = 0x0500D6E3
					ssStruct.StageTime = 13.0
					ssStruct.PositionID = "DTSIXSM_765_S4"
					ssStruct.PositionOrigID = "FSM-DoubleBed01-05Doggy"
				elseIf (stageNumber == 5)
					ssStruct.FAnimFormID = 0x0500D6E4
					ssStruct.MAnimFormID = 0x0500D6E5
					ssStruct.StageTime = 13.0
					ssStruct.PositionID = "DTSIXSM_765_S5"
					ssStruct.PositionOrigID = "FSM-DoubleBed01-06Doggy"
				elseIf (stageNumber == 1 && longScene >= 1)
					ssStruct.FAnimFormID = 0x05021F0B
					ssStruct.MAnimFormID = 0x05021F0C
					ssStruct.StageTime = 13.0
					ssStruct.PositionID = "DTSIXSM_765_S1"
					ssStruct.PositionOrigID = "FSM-DoubleBed01-02Start"
				elseIf (stageNumber == 6 && longScene >= 2)
					ssStruct.FAnimFormID = 0x0502E67E
					ssStruct.MAnimFormID = 0x0502E67F
					ssStruct.StageTime = 7.0
					ssStruct.PositionID = "DTSIXSM_765_S6"
					ssStruct.PositionOrigID = "FSM-DoubleBed01-07ClimaxLoop"
				else
					ssStruct.FAnimFormID = 0x0500923E					; same as stage3
					ssStruct.MAnimFormID = 0x0500923F
					ssStruct.StageTime = 13.0
					ssStruct.PositionID = "DTSIXSM_765_S3"
					ssStruct.PositionOrigID = "FSM-DoubleBed01-04Doggy"
				endIf
			elseIf (seqID == 766)							;SIX_SC_FSM-DoubleBed03-01Tease / cowgirl
				if (stageNumber == 1)
					ssStruct.FAnimFormID = 0x05021EDA
					ssStruct.MAnimFormID = 0x05021EDB
					ssStruct.StageTime = 14.0
					ssStruct.PositionID = "DTSIXSM_766_S1"
					ssStruct.PositionOrigID = "FSM-DoubleBed03-01Tease"
				elseIf (stageNumber == 2 && longScene > 0)
					ssStruct.FAnimFormID = 0x0502A151
					ssStruct.MAnimFormID = 0x0502A152
					ssStruct.StageTime = 13.3
					ssStruct.PositionID = "DTSIXSM_766_S2"
					ssStruct.PositionOrigID = "SC-FM-SuperMutant-DoubleBed03-02Start"
				elseIf (stageNumber == 3)
					ssStruct.FAnimFormID = 0x0500E626
					ssStruct.MAnimFormID = 0x0500E627
					ssStruct.StageTime = 12.5
					ssStruct.PositionID = "DTSIXSM_766_S3"
					ssStruct.PositionOrigID = "FSM-DoubleBed03-03Cowgirl"
				elseIf (stageNumber == 4 || (longScene <= 0 && stageNumber == 2))
					ssStruct.FAnimFormID = 0x0500E628
					ssStruct.MAnimFormID = 0x0500E629
					ssStruct.StageTime = 16.0
					ssStruct.PositionID = "DTSIXSM_766_S4"
					ssStruct.PositionOrigID = "FSM-DoubleBed03-04Cowgirl"
				elseIf (stageNumber == 5)
					ssStruct.FAnimFormID = 0x0500EDCB
					ssStruct.MAnimFormID = 0x0500EDCC
					ssStruct.StageTime = 13.0
					ssStruct.ArmorNudeAGun = 1
					ssStruct.PositionID = "DTSIXSM_766_S5"
					ssStruct.PositionOrigID = "FSM-DoubleBed03-05Cowgirl"
				elseIf (stageNumber == 6)
					ssStruct.FAnimFormID = 0x0500F566
					ssStruct.MAnimFormID = 0x0500F567
					ssStruct.StageTime = 13.0
					ssStruct.ArmorNudeAGun = 1
					ssStruct.PositionID = "DTSIXSM_766_S6"
					ssStruct.PositionOrigID = "FSM-DoubleBed03-06Cowgirl"
				elseIf (stageNumber == 7)
					ssStruct.FAnimFormID = 0x0502E682
					ssStruct.MAnimFormID = 0x0502E683
					ssStruct.StageTime = 7.0
					ssStruct.ArmorNudeAGun = 1
					ssStruct.PositionID = "DTSIXSM_766_S7"
					ssStruct.PositionOrigID = "SC-FM-SuperMutant-DoubleBed03-07ClimaxLoop"
				endIf
			elseIf (seqID == 767)
				ssStruct.ArmorNudeAGun = 1
				if (stageNumber == 1)
					ssStruct.FAnimFormID = 0x05003E3D
					ssStruct.MAnimFormID = 0x05003E3E
					ssStruct.PositionID = "DTSIXSM_767_S1"
					ssStruct.PositionOrigID = "FSM-SMBed01-01Tease"
				elseIf (stageNumber == 2)
					ssStruct.FAnimFormID = 0x05003E3F
					ssStruct.MAnimFormID = 0x05003E40
					ssStruct.PositionID = "DTSIXSM_767_S2"
					ssStruct.PositionOrigID = "FSM-SMBed01-02Startl"
				elseIf (stageNumber == 3)
					ssStruct.FAnimFormID = 0x05003E41
					ssStruct.MAnimFormID = 0x05003E42
					ssStruct.PositionID = "DTSIXSM_767_S3"
					ssStruct.PositionOrigID = "FSM-SMBed01-03Missionary"
				elseIf (stageNumber == 4)
					ssStruct.FAnimFormID = 0x05003E43
					ssStruct.MAnimFormID = 0x05003E44
					ssStruct.PositionID = "DTSIXSM_767_S4"
					ssStruct.PositionOrigID = "FSM-SMBed01-04Missionary"
				elseIf (stageNumber == 5)
					ssStruct.FAnimFormID = 0x05003E45
					ssStruct.MAnimFormID = 0x05003E46
					ssStruct.PositionID = "DTSIXSM_767_S5"
					ssStruct.PositionOrigID = "FSM-SMBed01-05Missionary"
				elseIf (stageNumber == 6)
					ssStruct.FAnimFormID = 0x0502F5DA						;1.2.3
					ssStruct.MAnimFormID = 0x0502F5DB
					ssStruct.PositionID = "DTSIXSM_767_S6"
					ssStruct.PositionOrigID = "SC-FM-SuperMutant-SMBed01-06Missionary"
				elseIf (longScene >= 1)
					ssStruct.FAnimFormID = 0x0502F5DC						;1.2.3
					ssStruct.MAnimFormID = 0x0502F5DD
					ssStruct.PositionID = "DTSIXSM_767_S7"
					ssStruct.PositionOrigID = "SC-FM-SuperMutant-SMBed01-07ClimaxLoop"
				endIf

			elseIf (seqID == 768)
				if (other == 0)
					int sNum = stageNumber
					if (longScene <= 0)
						sNum = stageNumber + 1
					endIf
					if (sNum == 1)											;1.2.3
						ssStruct.FAnimFormID = 0x0502F5DE
						ssStruct.MAnimFormID = 0x0502F5DF
						ssStruct.ArmorNudeAGun = 1
						ssStruct.MorphAngleA = 1.3
						ssStruct.PositionID = "DTSIXSM_768_S1"
						ssStruct.PositionOrigID = "SC-FM-SuperMutant-SMBed02-01Tease"
					elseIf (sNum == 2)
						ssStruct.FAnimFormID = 0x0500C7A2			; bends over during animation?
						ssStruct.MAnimFormID = 0x0500C7A3
						ssStruct.ArmorNudeAGun = 1
						ssStruct.MorphAngleA = 0.9
						ssStruct.PositionID = "DTSIXSM_768_S2"
						ssStruct.PositionOrigID = "FSM-SMBed02-03Doggy"
					elseIf (sNum == 3)
						ssStruct.FAnimFormID = 0x050139F9
						ssStruct.MAnimFormID = 0x050139FA
						ssStruct.ArmorNudeAGun = 0						
						ssStruct.PositionID = "DTSIXSM_768_S3"
						ssStruct.PositionOrigID = "FSM-SMBed02-04Doggy"
					elseIf (sNum == 4)
						ssStruct.FAnimFormID = 0x050139FB
						ssStruct.MAnimFormID = 0x050139FC
						ssStruct.ArmorNudeAGun = 0						
						ssStruct.PositionID = "DTSIXSM_768_S4"
						ssStruct.PositionOrigID = "FSM-SMBed02-05Doggy"
					elseIf (sNum >= 5)
						ssStruct.FAnimFormID = 0x050139FD
						ssStruct.MAnimFormID = 0x050139FE
						ssStruct.ArmorNudeAGun = 0					; was down?? v2.73
						ssStruct.PositionID = "DTSIXSM_768_S5"
						ssStruct.PositionOrigID = "FSM-SMBed02-06Doggy"
					endIf
				else
					; Tease added 1.23 0x0502F5D5 - 7
					if (stageNumber == 1)
						ssStruct.FAnimFormID = 0x0501049D
						ssStruct.MAnimFormID = 0x0501049E
						ssStruct.OAnimFormID = 0x0501049F
						ssStruct.PositionID = "DTSIXSMSM_768_S1"
						ssStruct.PositionOrigID = "FSMSM-SMBed01-03Handjob-Doggy"
					elseIf (stageNumber == 2)
						ssStruct.FAnimFormID = 0x05014946
						ssStruct.MAnimFormID = 0x05014947
						ssStruct.OAnimFormID = 0x05014948
						ssStruct.PositionID = "DTSIXSMSM_768_S2"
						ssStruct.PositionOrigID = "FSMSM-SMBed01-04Handjob-Doggy"
					elseIf (stageNumber == 3)
						ssStruct.FAnimFormID = 0x05014949
						ssStruct.MAnimFormID = 0x0501494A
						ssStruct.OAnimFormID = 0x0501494B
						ssStruct.PositionID = "DTSIXSMSM_768_S4"
						ssStruct.PositionOrigID = "SC-FMM-SuperMutant-SMBed01-05Spitroast"
					elseIf (longScene > 0)
						ssStruct.FAnimFormID = 0x0502A153
						ssStruct.MAnimFormID = 0x0502A154
						ssStruct.OAnimFormID = 0x0502A155
						ssStruct.PositionID = "DTSIXSMSM_768_S5"
						ssStruct.PositionOrigID = "SC-FMM-SuperMutant-SMBed01-06Spitroast"
					endIf
				
				endIf
			elseIf (seqID == 769)
				ssStruct.FAnimFormID = 0x0502A158
				ssStruct.MAnimFormID = 0x0502A159
				ssStruct.ArmorNudeAGun = 1						; added v2.73
				ssStruct.StageTime = 24.0
				ssStruct.PositionID = "DTSIXSM_769_S1"
				ssStruct.PositionOrigID = "SC-FM-SuperMutant-Standing04-01Tease"
			endIf
		
		elseIf (seqID >= 770 && seqID < 780)		; Mr Handy or other
		
			
			if (seqID == 771)
				ssStruct.ArmorNudeAGun = -1
				
				if (stageNumber == 1)		
					ssStruct.FAnimFormID = 0x0502B0C3
					ssStruct.MAnimFormID = 0x0502B0C4
					ssStruct.PositionID = "DTSIXFR_771_S1"
					ssStruct.PositionOrigID = "SC-FM-Handy-Floor01-01Tease"
				elseIf (stageNumber == 2)
					ssStruct.FAnimFormID = 0x050291E9
					ssStruct.MAnimFormID = 0x050291EA
					ssStruct.PositionID = "DTSIXFR_771_S2"
					ssStruct.PositionOrigID = "SC-FM-Handy-Floor01-03Doggy"
				elseIf (stageNumber == 3)
					ssStruct.FAnimFormID = 0x0502998C
					ssStruct.MAnimFormID = 0x0502998D
					ssStruct.PositionID = "DTSIXFR_771_S3"
					ssStruct.PositionOrigID = "SC-FM-Handy-Floor01-04Doggy"
				elseIf (stageNumber == 4)
					ssStruct.FAnimFormID = 0x0502B0C5
					ssStruct.MAnimFormID = 0x0502B0C6
					ssStruct.PositionID = "DTSIXFR_771_S4"
					ssStruct.PositionOrigID = "SC-FM-Handy-Floor01-05Doggy"
				elseIf (stageNumber == 5)
					ssStruct.FAnimFormID = 0x0502B0C7
					ssStruct.MAnimFormID = 0x0502B0C8
					ssStruct.PositionID = "DTSIXFR_771_S5"
					ssStruct.PositionOrigID = "SC-FM-Handy-Floor01-06Doggy"
				else
					ssStruct.FAnimFormID = 0x0502B0C9
					ssStruct.MAnimFormID = 0x0502B0CA
					ssStruct.PositionID = "DTSIXFR_771_S6"
					ssStruct.PositionOrigID = "SC-FM-Handy-Floor01-07Climax"
				endIf
			elseIf (seqID == 772)										; v2.88 SuperMutant on patio table, SC 1.3.0
				if (stageNumber == 1)
					ssStruct.FAnimFormID = 0x05034503
					ssStruct.MAnimFormID = 0x05034504
					ssStruct.PositionID = "DTSIXSM_772_S1"
					ssStruct.PositionOrigID = "SC-FM-SuperMutant-PatioTable01-01Tease"
				elseIf (stageNumber == 2)
					ssStruct.FAnimFormID = 0x05034505
					ssStruct.MAnimFormID = 0x05034506
					ssStruct.PositionID = "DTSIXSM_772_S2"
					ssStruct.PositionOrigID = "SC-FM-SuperMutant-PatioTable01-02Start"
				elseIf (stageNumber == 3)
					ssStruct.FAnimFormID = 0x05034507
					ssStruct.MAnimFormID = 0x05034508
					ssStruct.PositionID = "DTSIXSM_772_S3"
					ssStruct.PositionOrigID = "SC-FM-SuperMutant-PatioTable01-03Sitting"
				elseIf (stageNumber == 4)
					ssStruct.FAnimFormID = 0x05034509
					ssStruct.MAnimFormID = 0x0503450A
					ssStruct.PositionID = "DTSIXSM_772_S4"
					ssStruct.PositionOrigID = "SC-FM-SuperMutant-PatioTable01-04Missionary"
				elseIf (stageNumber == 5)
					ssStruct.FAnimFormID = 0x0503450B
					ssStruct.MAnimFormID = 0x0503450C
					ssStruct.PositionID = "DTSIXSM_772_S5"
					ssStruct.PositionOrigID = "SC-FM-SuperMutant-PatioTable01-05Sideways"
				elseIf (stageNumber == 6)
					ssStruct.FAnimFormID = 0x0503450D
					ssStruct.MAnimFormID = 0x0503450E
					ssStruct.PositionID = "DTSIXSM_772_S6"
					ssStruct.PositionOrigID = "SC-FM-SuperMutant-PatioTable01-06Sideways"
				elseIf (stageNumber == 7)
					ssStruct.FAnimFormID = 0x0503450F
					ssStruct.MAnimFormID = 0x05034510
					ssStruct.PositionID = "DTSIXSM_772_S7"
					ssStruct.PositionOrigID = "SC-FM-SuperMutant-PatioTable01-07ClimaxLoop"
				elseIf (stageNumber == 8)
					ssStruct.FAnimFormID = 0x05034511
					ssStruct.MAnimFormID = 0x05034512
					ssStruct.PositionID = "DTSIXSM_772_S8"
					ssStruct.PositionOrigID = "SC-FM-SuperMutant-PatioTable01-08Finish"
				endIf
			elseIf (seqID == 773)										; v2.70 SuperMutant on couch, SC 1.2.6
				if (stageNumber == 1)
					ssStruct.FAnimFormID = 0x05030D54
					ssStruct.MAnimFormID = 0x05030D55
					ssStruct.ArmorNudeAGun = 1
					ssStruct.PositionID = "DTSIXSM_773_S1"
					ssStruct.PositionOrigID = "SC-FM-SuperMutant-Couch_PlayerHouse01-01Tease"
				elseIf (stageNumber == 2)
					ssStruct.FAnimFormID = 0x05030D56
					ssStruct.MAnimFormID = 0x05030D57
					ssStruct.ArmorNudeAGun = 1
					ssStruct.PositionID = "DTSIXSM_773_S2"
					ssStruct.PositionOrigID = "SC-FM-SuperMutant-Couch_PlayerHouse01-02Start"
				elseIf (stageNumber == 3)
					ssStruct.FAnimFormID = 0x05030D58
					ssStruct.MAnimFormID = 0x05030D59
					ssStruct.ArmorNudeAGun = 1
					ssStruct.PositionID = "DTSIXSM_773_S3"
					ssStruct.PositionOrigID = "SC-FM-SuperMutant-Couch_PlayerHouse01-03ReverseCowGirl"
				elseIf (stageNumber == 4)
					ssStruct.FAnimFormID = 0x05030D5A
					ssStruct.MAnimFormID = 0x05030D5B
					ssStruct.ArmorNudeAGun = 1
					ssStruct.PositionID = "DTSIXSM_773_S4"
					ssStruct.PositionOrigID = "SC-FM-SuperMutant-Couch_PlayerHouse01-04ReverseCowGirl"
				elseIf (stageNumber == 5)
					ssStruct.FAnimFormID = 0x05030D5C
					ssStruct.MAnimFormID = 0x05030D5D
					ssStruct.ArmorNudeAGun = 1
					ssStruct.PositionID = "DTSIXSM_773_S5"
					ssStruct.PositionOrigID = "SC-FM-SuperMutant-Couch_PlayerHouse01-05ReverseCowGirl"
				elseIf (stageNumber == 6)
					ssStruct.FAnimFormID = 0x05030D5E
					ssStruct.MAnimFormID = 0x05030D5F
					ssStruct.ArmorNudeAGun = 1
					ssStruct.PositionID = "DTSIXSM_773_S6"
					ssStruct.PositionOrigID = "SC-FM-SuperMutant-Couch_PlayerHouse01-06ReverseCowGirl"
				elseIf (stageNumber == 7)
					ssStruct.FAnimFormID = 0x05030D60
					ssStruct.MAnimFormID = 0x05030D61
					ssStruct.ArmorNudeAGun = 1
					ssStruct.PositionID = "DTSIXSM_773_S7"
					ssStruct.PositionOrigID = "SC-FM-SuperMutant-Couch_PlayerHouse01-07ClimaxLoop"
				else
					ssStruct.FAnimFormID = 0x05030D62
					ssStruct.MAnimFormID = 0x05030D63
					ssStruct.PositionID = "DTSIXSM_773_S8"
					ssStruct.PositionOrigID = "SC-FM-SuperMutant-Couch_PlayerHouse01-08Finish"
				endIf
			elseIf (seqID == 774)
				int sNum = stageNumber
				if (longScene <= 1)
					sNum = stageNumber + 1
				endIf
				if (sNum == 1)											;1.2.3		
					ssStruct.FAnimFormID = 0x0502F5E4
					ssStruct.MAnimFormID = 0x0502F5E5
					ssStruct.PositionID = "DTSIXSM_774_S1"
					ssStruct.PositionOrigID = "SC-FM-SMBehemoth-Floor01-01Tease"
				elseIf (sNum == 2)		
					ssStruct.FAnimFormID = 0x0502A141
					ssStruct.MAnimFormID = 0x0502A142
					ssStruct.PositionID = "DTSIXSM_774_S2"
					ssStruct.PositionOrigID = "SC-FM-SMBehemoth-Floor01-03ReverseCowgirl"
				elseIf (sNum == 3)
					ssStruct.FAnimFormID = 0x0502A143
					ssStruct.MAnimFormID = 0x0502A143
					ssStruct.PositionID = "DTSIXSM_774_S3"
					ssStruct.PositionOrigID = "SC-FM-SMBehemoth-Floor01-04Blowjob"
				elseIf (sNum == 4)
					ssStruct.FAnimFormID = 0x0502A145
					ssStruct.MAnimFormID = 0x0502A146
					ssStruct.PositionID = "DTSIXSM_774_S4"
					ssStruct.PositionOrigID = "SC-FM-SMBehemoth-Floor01-05Cowgirl"
				elseIf (sNum == 5)
					ssStruct.FAnimFormID = 0x0502A147
					ssStruct.MAnimFormID = 0x0502A148
					ssStruct.PositionID = "DTSIXSM_774_S5"
					ssStruct.PositionOrigID = "SC-FM-SMBehemoth-Floor01-06Cowgirl"
				elseIf (sNum == 6)
					ssStruct.FAnimFormID = 0x0502DEDB					;1.2.2
					ssStruct.MAnimFormID = 0x0502DEDC
					ssStruct.PositionID = "DTSIXSM_774_S6"
					ssStruct.PositionOrigID = "SC-FM-SMBehemoth-Floor01-07-Climax"
				endIf
			elseIf (seqID == 775)
				if (longScene <= 0)
					stageNumber += 1
				endIf
				if (stageNumber == 1)		
					ssStruct.FAnimFormID = 0x0503057C					;v2.50  SC 1.2.5
					ssStruct.MAnimFormID = 0x0503057D
					ssStruct.PositionID = "DTSIXSM_775_S0"
					ssStruct.PositionOrigID = "SC-FM-SMBehemoth-Floor02-01Tease"
				elseIf (stageNumber == 2)		
					ssStruct.FAnimFormID = 0x05027AE6
					ssStruct.MAnimFormID = 0x05027AE7
					ssStruct.PositionID = "DTSIXSM_775_S1"
					ssStruct.PositionOrigID = "SC-FM-SMBehemoth-Floor02-03Missionary"
				elseIf (stageNumber == 3)
					ssStruct.FAnimFormID = 0x05024546
					ssStruct.MAnimFormID = 0x05024548
					ssStruct.PositionID = "DTSIXSM_775_S2"
					ssStruct.PositionOrigID = "SC-FM-SMBehemoth-Floor02-04Missionary"
				elseIf (stageNumber == 4 || stageNumber == 6)
					ssStruct.FAnimFormID = 0x05027AE9
					ssStruct.MAnimFormID = 0x05027AEA
					ssStruct.PositionID = "DTSIXSM_775_S3"
					ssStruct.PositionOrigID = "SC-FM-SMBehemoth-Floor02-05Missionary"
				elseIf (stageNumber == 5)
					ssStruct.FAnimFormID = 0x05027AED
					ssStruct.MAnimFormID = 0x05027AEE
					ssStruct.ArmorNudeAGun = 1
					ssStruct.PositionID = "DTSIXSM_775_S4"
					ssStruct.PositionOrigID = "SC-FM-SMBehemoth-Floor02-06Missionary"
				endIf
			elseIf (seqID == 776)
				if (stageNumber == 1)		
					ssStruct.FAnimFormID = 0x0502A149
					ssStruct.MAnimFormID = 0x0502A14A
					ssStruct.PositionID = "DTSIXSM_776_S1"
					ssStruct.PositionOrigID = "SC-FM-SMBehemoth-Floor03-03Handjob"
				elseIf (stageNumber == 2)
					ssStruct.FAnimFormID = 0x0502A14B
					ssStruct.MAnimFormID = 0x0502A14C
					ssStruct.ArmorNudeAGun = 1
					ssStruct.PositionID = "DTSIXSM_776_S2"
					ssStruct.PositionOrigID = "SC-FM-SMBehemoth-Floor03-04Titjob"
				elseIf (stageNumber == 3)
					ssStruct.FAnimFormID = 0x0502A14D
					ssStruct.MAnimFormID = 0x0502A14E
					ssStruct.ArmorNudeAGun = 1
					ssStruct.PositionID = "DTSIXSM_776_S3"
					ssStruct.PositionOrigID = "SC-FM-SMBehemoth-Floor03-05Blowjob"
				elseIf (stageNumber == 4)
					ssStruct.FAnimFormID = 0x0502A14F
					ssStruct.MAnimFormID = 0x0502A150
					ssStruct.PositionID = "DTSIXSM_776_S4"
					ssStruct.PositionOrigID = "SC-FM-SMBehemoth-Floor03-06Blowjob"
				endIf
			
			
			elseIf (seqID == 777)
				if (stageNumber == 1)		
					ssStruct.FAnimFormID = 0x05017E8A
					ssStruct.MAnimFormID = 0x05017E8B
					ssStruct.StageTime = 16.0
					ssStruct.PositionID = "FD-Chair01-01Tease"
				elseIf (stageNumber == 2)
					ssStruct.FAnimFormID = 0x05018625
					ssStruct.MAnimFormID = 0x05018626
					ssStruct.StageTime = 8.0
					ssStruct.PositionID = "FD-Chair01-02Start"
				else
					ssStruct.FAnimFormID = 0x0501BB6E
					ssStruct.MAnimFormID = 0x0501BB6F
					ssStruct.StageTime = 8.0
					ssStruct.PositionID = "FD-Chair01-08Finish"
				endIf
			elseIf (seqID == 778)
				if (stageNumber == 1)
					ssStruct.FAnimFormID = 0x0501E914
					ssStruct.MAnimFormID = 0x0501E915
					ssStruct.StageTime = 24.0
					ssStruct.PositionID = "FD-Couch01-01Tease"
				else
					ssStruct.FAnimFormID = 0x0501E916	
					ssStruct.MAnimFormID = 0x0501E917
					ssStruct.StageTime = 8.0
					ssStruct.PositionID = "FD-Couch01-02Start"
				endIf
			elseIf (seqID == 779)									; SuperMutant - Stove   v2.84, SC 1.2.9
				if (stageNumber == 1)
					ssStruct.FAnimFormID = 0x05033CFB
					ssStruct.MAnimFormID = 0x05033CFC
					ssStruct.PositionID = "DTSIXSM_769_S1"
					ssStruct.PositionOrigID = "SC-FM-SuperMutant-StovePlayerHouseRuin01-01Tease"
				elseIf (stageNumber == 2)
					ssStruct.FAnimFormID = 0x05033CFD
					ssStruct.MAnimFormID = 0x05033CFE
					ssStruct.PositionID = "DTSIXSM_769_S2"
					ssStruct.PositionOrigID = "SC-FM-SuperMutant-StovePlayerHouseRuin01-02Start"
				elseIf (stageNumber == 3)
					ssStruct.FAnimFormID = 0x05033CFF
					ssStruct.MAnimFormID = 0x05033D00
					ssStruct.PositionID = "DTSIXSM_769_S3"
					ssStruct.PositionOrigID = "SC-FM-SuperMutant-StovePlayerHouseRuin01-03Missionary"
				elseIf (stageNumber == 4)
					ssStruct.FAnimFormID = 0x05033D01
					ssStruct.MAnimFormID = 0x05033D02
					ssStruct.PositionID = "DTSIXSM_769_S4"
					ssStruct.PositionOrigID = "SC-FM-SuperMutant-StovePlayerHouseRuin01-04Missionary"
				elseIf (stageNumber == 5)
					ssStruct.FAnimFormID = 0x05033D03
					ssStruct.MAnimFormID = 0x05033D04
					ssStruct.PositionID = "DTSIXSM_769_S5"
					ssStruct.PositionOrigID = "SC-FM-SuperMutant-StovePlayerHouseRuin01-05Missionary"
				elseIf (stageNumber == 6)
					ssStruct.FAnimFormID = 0x05033D05
					ssStruct.MAnimFormID = 0x05033D06
					ssStruct.PositionID = "DTSIXSM_769_S6"
					ssStruct.PositionOrigID = "SC-FM-SuperMutant-StovePlayerHouseRuin01-06Missionary"
				elseIf (stageNumber == 7)
					ssStruct.FAnimFormID = 0x05033D07
					ssStruct.MAnimFormID = 0x05033D08
					ssStruct.PositionID = "DTSIXSM_769_S7"
					ssStruct.PositionOrigID = "SC-FM-SuperMutant-StovePlayerHouseRuin01-07Missionary"
				else
					ssStruct.FAnimFormID = 0x05033D09
					ssStruct.MAnimFormID = 0x05033D0A
					ssStruct.PositionID = "DTSIXSM_769_S8"
					ssStruct.PositionOrigID = "SC-FM-SuperMutant-StovePlayerHouseRuin01-08Finish"
				endIf
			endIf
		
		elseIf (seqID >= 780 && seqID < 790)							; standing and more furniture scenes
		
			if (seqID == 780)
				ssStruct.FAnimFormID = 0x0502B866
				ssStruct.MAnimFormID = 0x0502B867
				ssStruct.StageTime = 25.0
				ssStruct.PositionID = "DTSIX_780_S1"
				ssStruct.PositionOrigID = "SC-FM-Human-DinerBooth01-01Tease"
				ssStruct.ArmorNudeAGun = -1				; not naked

			elseIf (seqID == 781)
				if (stageNumber == 1)
					ssStruct.FAnimFormID = 0x0502C010
					ssStruct.MAnimFormID = 0x0502C011
					if (longScene > 0 && longScene < 2)
						ssStruct.StageTime = 13.0
					else
						ssStruct.StageTime = 25.0
					endIf
					ssStruct.PositionID = "DTSIX_781_S1"
					ssStruct.PositionOrigID = "SC-FM-Human-Couch_PlayerHouse01-03Facefuck"
				elseIf (stageNumber == 2)
					ssStruct.FAnimFormID = 0x0502FD89				; v2.49, SC 1.2.4
					ssStruct.MAnimFormID = 0x0502FD8A
					if (longScene < 2)
						ssStruct.StageTime = 12.0
					endIf
					ssStruct.PositionID = "DTSIX_781_S2"			; not in AAF
					ssStruct.PositionOrigID = "SC-FM-Human-Couch_PlayerHouse01-04Facefuck"
				elseIf (stageNumber == 3)
					ssStruct.FAnimFormID = 0x05033CB8				; v2.84, SC 1.2.9
					ssStruct.MAnimFormID = 0x05033CB9
					ssStruct.PositionID = "DTSIX_781_S3"			; not in AAF
					ssStruct.PositionOrigID = "SC-FM-Human-Couch_PlayerHouse01-05Facefuck"
				else
					ssStruct.FAnimFormID = 0x05033CBA				; v2.84, SC 1.2.9
					ssStruct.MAnimFormID = 0x05033CBB
					ssStruct.PositionID = "DTSIX_781_S4"			; not in AAF
					ssStruct.PositionOrigID = "SC-FM-Human-Couch_PlayerHouse01-06Facefuck"
				endIf
			elseIf (seqID == 782)
				if (longScene < 2 && stageNumber > 1)
					stageNumber += 1
				endIf
				if (stageNumber == 1)							; SC 1.2.7 - v2.77
					ssStruct.FAnimFormID = 0x05032543
					ssStruct.MAnimFormID = 0x05032544
					ssStruct.StageTime = 9.0
					ssStruct.PositionID = "DTSIX_782_S1"
					ssStruct.PositionOrigID = "SC-FM-Human-Mattress01-01Tease"
				elseIf (stageNumber == 2)						; v2.84, SC 1.2.9
					ssStruct.FAnimFormID = 0x05033CD2
					ssStruct.MAnimFormID = 0x05033CD3
					ssStruct.PositionID = "DTSIX_782_S1A"
					ssStruct.PositionOrigID = "SC-FM-Human-Mattress01-02Start"
				elseIf (stageNumber == 3)				
					ssStruct.FAnimFormID = 0x05032545
					ssStruct.MAnimFormID = 0x05032546
					if (longScene <= 0)
						ssStruct.StageTime = 24.0
					endIf
					ssStruct.PositionID = "DTSIX_782_S2"
					ssStruct.PositionOrigID = "SC-FM-Human-Mattress01-03Missionary"
				elseIf (stageNumber == 4)							; added SC 1.2.8 - v2.79
					ssStruct.FAnimFormID = 0x05032D56
					ssStruct.MAnimFormID = 0x05032D57
					ssStruct.PositionID = "DTSIX_782_S3"
					ssStruct.ArmorNudeAGun = 2
					ssStruct.PositionOrigID = "SC-FM-Human-Mattress01-04Missionary"
				elseIf (stageNumber == 5)
					ssStruct.FAnimFormID = 0x05032D58
					ssStruct.MAnimFormID = 0x05032D59
					ssStruct.ArmorNudeAGun = 2
					ssStruct.PositionID = "DTSIX_782_S4"
					ssStruct.PositionOrigID = "SC-FM-Human-Mattress01-05Missionary"	
				elseIf (stageNumber >= 6)
					ssStruct.FAnimFormID = 0x05032D5A
					ssStruct.MAnimFormID = 0x05032D5B
					ssStruct.ArmorNudeAGun = 2
					ssStruct.PositionID = "DTSIX_782_S5"
					ssStruct.PositionOrigID = "SC-FM-Human-Mattress01-06Missionary"
				endIf
			elseIf (seqID == 783)
				if (stageNumber == 1)							; SC 1.2.7 - v2.77
					ssStruct.FAnimFormID = 0x05032549
					ssStruct.MAnimFormID = 0x0503254A
					ssStruct.StageTime = 9.0
					ssStruct.PositionID = "DTSIX_783_S1"
					ssStruct.PositionOrigID = "SC-FM-Human-SleepingBag01-01Tease"
				elseIf (stageNumber == 2 && longScene >= 1)		; SC 1.2.8 - v2.79
					ssStruct.FAnimFormID = 0x05032D5C
					ssStruct.MAnimFormID = 0x05032D5D
					ssStruct.PositionID = "DTSIX_783_S2"
					ssStruct.PositionOrigID = "SC-FM-Human-SleepingBag01-02Start"
				elseIf (stageNumber == 3 || longScene <= 0)
					ssStruct.FAnimFormID = 0x0503254B			; SC 1.2.7 - v2.77
					ssStruct.MAnimFormID = 0x0503254C
					if (longScene <= 0)
						ssStruct.StageTime = 24.0
					endIf
					ssStruct.PositionID = "DTSIX_783_S3"	
					ssStruct.PositionOrigID = "SC-FM-Human-SleepingBag01-03Doggy"
				elseIf (stageNumber == 4)						; SC 1.2.8 - v2.79
					ssStruct.FAnimFormID = 0x05032D5E
					ssStruct.MAnimFormID = 0x05032D5F
					ssStruct.PositionID = "DTSIX_783_S4"
					ssStruct.PositionOrigID = "SC-FM-Human-SleepingBag01-04Doggy"
				elseIf (stageNumber == 5)
					ssStruct.FAnimFormID = 0x05032D6C
					ssStruct.MAnimFormID = 0x05032D6D
					ssStruct.PositionID = "DTSIX_783_S5"
					ssStruct.PositionOrigID = "SC-FM-Human-SleepingBag01-05Doggy"
				elseIf (stageNumber == 6)
					ssStruct.FAnimFormID = 0x05032D6E
					ssStruct.MAnimFormID = 0x05032D6F
					ssStruct.PositionID = "DTSIX_783_S6"
					ssStruct.PositionOrigID = "SC-FM-Human-SleepingBag01-06Doggy"
				elseIf (stageNumber == 7)													; SC 1.3.0 - v2.88
					ssStruct.FAnimFormID = 0x050344D4
					ssStruct.MAnimFormID = 0x050344D5
					ssStruct.PositionID = "DTSIX_783_S7"
					ssStruct.PositionOrigID = "SC-FM-Human-SleepingBag01-07ClimaxLoop"
				elseIf (stageNumber == 8)													; SC 1.3.0 - v2.88
					ssStruct.FAnimFormID = 0x050344D6
					ssStruct.MAnimFormID = 0x050344D7
					ssStruct.PositionID = "DTSIX_783_S8"
					ssStruct.PositionOrigID = "SC-FM-Human-SleepingBag01-08Finish"
				endIf
				
			elseIf (seqID == 784)									; stand/floor oral v2.70, SC 1.2.6
				if (stageNumber == 1)
					ssStruct.FAnimFormID = 0x05030DAF					
					ssStruct.MAnimFormID = 0x05030DB0
					ssStruct.PositionID = "DTSIX_784_S1"
					ssStruct.PositionOrigID = "SC-FM-Human-Floor01-01Tease"
				elseIf (stageNumber == 2)
					ssStruct.FAnimFormID = 0x05030DB1					
					ssStruct.MAnimFormID = 0x05030DB2
					ssStruct.PositionID = "DTSIX_784_S2"
					ssStruct.PositionOrigID = "SC-FM-Human-Floor01-02Start"
				elseIf (stageNumber == 3)
					ssStruct.FAnimFormID = 0x05030DB3					
					ssStruct.MAnimFormID = 0x05030DB4
					ssStruct.PositionID = "DTSIX_784_S3"
					ssStruct.PositionOrigID = "SC-FM-Human-Floor01-03Blowjob"
				elseIf (stageNumber == 4)
					ssStruct.FAnimFormID = 0x05030DB5				
					ssStruct.MAnimFormID = 0x05030DB6
					ssStruct.PositionID = "DTSIX_784_S4"
					ssStruct.PositionOrigID = "SC-FM-Human-Floor01-04Blowjob"
				elseIf (stageNumber == 5)
					ssStruct.FAnimFormID = 0x05030DBB				
					ssStruct.MAnimFormID = 0x05030DBC
					ssStruct.PositionID = "DTSIX_784_S5"
					ssStruct.PositionOrigID = "SC-FM-Human-Floor01-07ClimaxLoop"
				else
					ssStruct.FAnimFormID = 0x05030DBD				
					ssStruct.MAnimFormID = 0x05030DBE
					ssStruct.PositionID = "DTSIX_784_S6"
					ssStruct.PositionOrigID = "SC-FM-Human-Floor01-08Finish"
				endIf
				
			elseIf (seqID == 785)
				if (stageNumber == 1)
					ssStruct.FAnimFormID = 0x0502B0B5
					ssStruct.MAnimFormID = 0x0502B0B6
					if (longScene <= 0)
						ssStruct.StageTime = 24.0
					endIf
					ssStruct.PositionID = "DTSIX_785_S1"
					ssStruct.PositionOrigID = "SC-FM-Human-FederalistCouch02-03ReverseCowGirl" 
				elseIf (stageNumber == 2)
					ssStruct.FAnimFormID = 0x0502B0B5
					ssStruct.MAnimFormID = 0x0502B0B6
					if (longScene <= 0)
						ssStruct.StageTime = 24.0
					endIf
					ssStruct.PositionID = "DTSIX_785_S2"
					ssStruct.PositionOrigID = "SC-FM-Human-FederalistCouch02-04ReverseCowGirl"
				elseIf (stageNumber == 3)
					ssStruct.FAnimFormID = 0x0502DEB7
					ssStruct.MAnimFormID = 0x0502DEB8
					ssStruct.PositionID = "DTSIX_785_S3"
					ssStruct.PositionOrigID = "SC-FM-Human-FederalistCouch02-05ReverseCowGirl"
				elseIf (stageNumber == 4)
					ssStruct.FAnimFormID = 0x0502DEB9
					ssStruct.MAnimFormID = 0x0502DEBA
					ssStruct.PositionID = "DTSIX_785_S4"
					ssStruct.PositionOrigID = "SC-FM-Human-FederalistCouch02-06ReverseCowGirl"
				endIf
			elseIf (seqID == 786)
				if (other >= 1)
					ssStruct.StageTime = 30.0
					ssStruct.FAnimFormID = 0x0502F5D2				;1.2.3
					ssStruct.MAnimFormID = 0x0502F5D3
					ssStruct.OAnimFormID = 0x0502F5D4
					ssStruct.PositionID = "DTSIXFMM_786_S1"
					ssStruct.PositionOrigID = "SC-FMM-Human-KitchenPostWar01-03Doggy"
					
				elseIf (stageNumber == 1)
					ssStruct.FAnimFormID = 0x0502C016
					ssStruct.MAnimFormID = 0x0502C017
					ssStruct.PositionID = "DTSIX_786_S1"
					ssStruct.PositionOrigID = "SC-FM-Human-KitchenPostWar01-03Doggy"
				elseIf (stageNumber == 2)
					ssStruct.FAnimFormID = 0x0502C018
					ssStruct.MAnimFormID = 0x0502C019
					ssStruct.PositionID = "DTSIX_786_S2"
					ssStruct.PositionOrigID = "SC-FM-Human-KitchenPostWar01-03Doggy"
				elseIf (stageNumber == 3)
					ssStruct.FAnimFormID = 0x0502C01A
					ssStruct.MAnimFormID = 0x0502C01B
					ssStruct.PositionID = "DTSIX_786_S3"
					ssStruct.PositionOrigID = "SC-FM-Human-KitchenPostWar01-05Doggy"
				else
					ssStruct.FAnimFormID = 0x0502F5D0				;1.2.3
					ssStruct.MAnimFormID = 0x0502F5D1
					ssStruct.PositionID = "DTSIX_786_S4"
					ssStruct.PositionOrigID = "SC-FM-Human-KitchenPostWar01-06Doggy"
				endIf
			elseIf (seqID == 787)												; SC 1.3.0 - v2.88 - added stages
				if (longScene <= 0 || stageNumber == 3)
					ssStruct.FAnimFormID = 0x0502C022
					ssStruct.MAnimFormID = 0x0502C023
					if (longScene <= 0)
						ssStruct.StageTime = 31.0
					endIf
					ssStruct.PositionID = "DTSIX_787_S1"
					ssStruct.PositionOrigID = "SC-FM-Human-Throne02-03ReverseCowgirl"
				elseIf (stageNumber == 1)
					ssStruct.FAnimFormID = 0x050344DE
					ssStruct.MAnimFormID = 0x050344DF
					ssStruct.PositionID = "DTSIX_787_S0"
					ssStruct.PositionOrigID = "SC-FM-Human-Throne02-01Tease"
				elseIf (stageNumber == 2)
					ssStruct.FAnimFormID = 0x050344E0
					ssStruct.MAnimFormID = 0x050344E1
					ssStruct.PositionID = "DTSIX_787_S2"
					ssStruct.PositionOrigID = "SC-FM-Human-Throne02-02Start"
				elseIf (stageNumber == 4)
					ssStruct.FAnimFormID = 0x050344E2
					ssStruct.MAnimFormID = 0x050344E3
					ssStruct.PositionID = "DTSIX_787_S4"
					ssStruct.PositionOrigID = "SC-FM-Human-Throne02-04ReverseCowgirl"
				elseIf (stageNumber == 5)
					ssStruct.FAnimFormID = 0x050344E4
					ssStruct.MAnimFormID = 0x050344E5
					ssStruct.PositionID = "DTSIX_787_S5"
					ssStruct.PositionOrigID = "SC-FM-Human-Throne02-05ReverseCowgirl"
				elseIf (stageNumber == 6)
					ssStruct.FAnimFormID = 0x050344E6
					ssStruct.MAnimFormID = 0x050344E7
					ssStruct.PositionID = "DTSIX_787_S6"
					ssStruct.PositionOrigID = "SC-FM-Human-Throne02-06ReverseCowgirl"
				elseIf (stageNumber == 7)
					ssStruct.FAnimFormID = 0x050344E8
					ssStruct.MAnimFormID = 0x050344E9
					ssStruct.PositionID = "DTSIX_787_S7"
					ssStruct.PositionOrigID = "SC-FM-Human-Throne02-07ClimaxLoop"
				elseIf (stageNumber == 8)
					ssStruct.FAnimFormID = 0x050344EA
					ssStruct.MAnimFormID = 0x050344EB
					ssStruct.PositionID = "DTSIX_787_S8"
					ssStruct.PositionOrigID = "SC-FM-Human-Throne02-08Finish"
				endIf
				
			elseIf (seqID == 788)			; lockers 1.2.7 - v2.77
				; skip stages 4,5 if short scene
				int pickedStage = stageNumber
				if (longScene < 1 && stageNumber >= 4)
					pickedStage += 2
				endIf
				if (pickedStage == 1)
					ssStruct.FAnimFormID = 0x05032533
					ssStruct.MAnimFormID = 0x05032534
					ssStruct.PositionID = "DTSIX_788_S1"
					ssStruct.PositionOrigID = "SC-FM-Human-Lockers01-01Tease"
				elseIf (pickedStage == 2)
					ssStruct.FAnimFormID = 0x05032535
					ssStruct.MAnimFormID = 0x05032536
					ssStruct.PositionID = "DTSIX_788_S2"
					ssStruct.PositionOrigID = "SC-FM-Human-Lockers01-02Start"
				elseIf (pickedStage == 3)
					ssStruct.FAnimFormID = 0x05032537
					ssStruct.MAnimFormID = 0x05032538
					ssStruct.PositionID = "DTSIX_788_S3"
					ssStruct.PositionOrigID = "SC-FM-Human-Lockers01-03Standing"
				elseIf (pickedStage == 4)
					ssStruct.FAnimFormID = 0x05032539
					ssStruct.MAnimFormID = 0x0503253A
					ssStruct.PositionID = "DTSIX_788_S4"
					ssStruct.PositionOrigID = "SC-FM-Human-Lockers01-04Standing"
				elseIf (pickedStage == 5)
					ssStruct.FAnimFormID = 0x0503253B
					ssStruct.MAnimFormID = 0x0503253C
					ssStruct.PositionID = "DTSIX_788_S5"
					ssStruct.PositionOrigID = "SC-FM-Human-Lockers01-05Standing"
				elseIf (pickedStage == 6)
					ssStruct.FAnimFormID = 0x0503253D
					ssStruct.MAnimFormID = 0x0503253E
					ssStruct.PositionID = "DTSIX_788_S6"
					ssStruct.PositionOrigID = "SC-FM-Human-Lockers01-06Carry"
				elseIf (pickedStage == 7)
					ssStruct.FAnimFormID = 0x0503253F
					ssStruct.MAnimFormID = 0x05032540
					ssStruct.PositionID = "DTSIX_788_S7"
					ssStruct.PositionOrigID = "SC-FM-Human-Lockers01-07ClimaxLoop"
				else
					ssStruct.FAnimFormID = 0x05032541
					ssStruct.MAnimFormID = 0x05032542
					ssStruct.PositionID = "DTSIX_788_S8"
					ssStruct.PositionOrigID = "SC-FM-Human-Lockers01-08Finish"
				endIf
			endIf
			
		; ------------------   other props
		elseIf (seqID == 790)
			if (stageNumber == 1)
				ssStruct.FAnimFormID = 0x05021EC5
				ssStruct.MAnimFormID = 0x05021EC6
				ssStruct.PositionID = "DTSIX_790_S1"
				ssStruct.PositionOrigID = "FM-SedanPostWar01-03Doggy"
			elseIf (stageNumber == 2)
				ssStruct.FAnimFormID = 0x05027345	
				ssStruct.MAnimFormID = 0x05027346
				ssStruct.PositionID = "DTSIX_790_S2"
				ssStruct.PositionOrigID = "FM-SedanPostWar01-04Doggy"
			elseIf (stageNumber == 3)
				ssStruct.FAnimFormID = 0x05027347	
				ssStruct.MAnimFormID = 0x05027348
				ssStruct.PositionID = "DTSIX_790_S3"
				ssStruct.PositionOrigID = "FM-SedanPostWar01-05Doggy"
			else
				ssStruct.FAnimFormID = 0x05027349	
				ssStruct.MAnimFormID = 0x0502734A
				ssStruct.PositionID = "DTSIX_790_S4"
				ssStruct.PositionOrigID = "FM-SedanPostWar01-06Doggy"
			endIf
		elseIf (seqID == 791)
			if (stageNumber == 1 || stageNumber == 3)
				ssStruct.FAnimFormID = 0x05027327
				ssStruct.MAnimFormID = 0x05027328
				ssStruct.PositionID = "DTSIX_791_S1"
				ssStruct.PositionOrigID = "FM-SedanPreWar02-03Blowjob"
			elseIf (stageNumber == 2 || stageNumber == 4)
				ssStruct.FAnimFormID = 0x05027341	
				ssStruct.MAnimFormID = 0x05027342
				ssStruct.PositionID = "DTSIX_791_S2"
				ssStruct.PositionOrigID = "FM-SedanPreWar02-04Cowgirl"
			endIf
		elseIf (seqID == 792)
			if (stageNumber == 1 || longScene < 1)
				ssStruct.StageTime = 16.0
				ssStruct.FAnimFormID = 0x0502171C
				ssStruct.MAnimFormID = 0x0502171D
				ssStruct.PositionID = "DTSIX_792_S1"
				ssStruct.PositionOrigID = "FM-SedanPreWar01-03Backseat"
			else
				ssStruct.StageTime = 16.0
				ssStruct.FAnimFormID = 0x0502C01E
				ssStruct.MAnimFormID = 0x0502C01F
				ssStruct.PositionID = "DTSIX_792_S2"
				ssStruct.PositionOrigID = "SC-FM-Human-SedanPreWar01-04MissionaryBackseat"
			endIf
		elseIf (seqID == 793)									; v2.70, SC 1.2.6 --- Armor Bench
			if (longScene < 1 && stageNumber > 1)				; v2.84, SC 1.2.9: 2 new stages added
				stageNumber += 1
			endIf
			if (stageNumber == 1)
				ssStruct.FAnimFormID = 0x05030D28								
				ssStruct.MAnimFormID = 0x05030D29
				ssStruct.PositionID = "DTSIX_793_S1"
				ssStruct.PositionOrigID = "SC-FM-Human-ArmorBench01-01Tease"
			elseIf (stageNumber == 2)
				ssStruct.FAnimFormID = 0x05033CAE						; v2.84					
				ssStruct.MAnimFormID = 0x05033CAF
				ssStruct.PositionID = "DTSIX_793_S1A"
				ssStruct.PositionOrigID = "SC-FM-Human-ArmorBench01-01Start"
			elseIf (stageNumber == 3)
				ssStruct.FAnimFormID = 0x05030D2A								
				ssStruct.MAnimFormID = 0x05030D2B
				ssStruct.PositionID = "DTSIX_793_S2"
				ssStruct.PositionOrigID = "SC-FM-Human-ArmorBench01-03Doggy"
			elseIf (stageNumber == 4)
				ssStruct.FAnimFormID = 0x05030D2C								
				ssStruct.MAnimFormID = 0x05030D2D
				ssStruct.PositionID = "DTSIX_793_S3"
				ssStruct.PositionOrigID = "SC-FM-Human-ArmorBench01-04Doggy"
			elseIf (stageNumber == 5)
				ssStruct.FAnimFormID = 0x05030D2E								
				ssStruct.MAnimFormID = 0x05030D2F
				ssStruct.PositionID = "DTSIX_793_S4"
				ssStruct.PositionOrigID = "SC-FM-Human-ArmorBench01-05Doggy"
			elseIf (stageNumber == 6)
				ssStruct.FAnimFormID = 0x05030D30								
				ssStruct.MAnimFormID = 0x05030D31
				ssStruct.PositionID = "DTSIX_793_S5"
				ssStruct.PositionOrigID = "SC-FM-Human-ArmorBench01-06Doggy"
			elseIf (stageNumber == 7)
				ssStruct.FAnimFormID = 0x05030D32								
				ssStruct.MAnimFormID = 0x05030D33
				ssStruct.PositionID = "DTSIX_793_S6"
				ssStruct.PositionOrigID = "SC-FM-Human-ArmorBench01-07ClimaxLoop"
			else
				ssStruct.FAnimFormID = 0x05033CB0						; v2.84						
				ssStruct.MAnimFormID = 0x05033CB1
				ssStruct.PositionID = "DTSIX_793_S7"
				ssStruct.PositionOrigID = "SC-FM-Human-ArmorBench01-08Finish"
			endIf
		elseIf (seqID == 794)									; v2.70, SC 1.2.6 --- Weapon Bench
			if (longScene < 1)									; v2.84, SC 1.2.9 adds 3 more stages
				stageNumber += 1
			endIf
			if (stageNumber == 1)
				if (longScene >= 2 && Utility.RandomInt(1,5) > 3)
					ssStruct.FAnimFormID = 0x050344EC				; v2.88	added stage	from SC 1.3.0					
					ssStruct.MAnimFormID = 0x050344ED
					ssStruct.PositionID = "DTSIX_794_S01"
					ssStruct.PositionOrigID = "SC-FM-Human-WeaponWorkbenchLarge01-02Start"
				else
					ssStruct.FAnimFormID = 0x05033CD8				; v2.84	added stage						
					ssStruct.MAnimFormID = 0x05033CD9
					ssStruct.PositionID = "DTSIX_794_S0"
					ssStruct.PositionOrigID = "SC-FM-Human-WeaponWorkbenchLarge01-01Tease"
				endIf
			elseIf (stageNumber == 2)
				ssStruct.FAnimFormID = 0x05031D12								
				ssStruct.MAnimFormID = 0x05031D13
				if (longScene < 1)
					ssStruct.StageTime = 12.0
				endIf
				ssStruct.PositionID = "DTSIX_794_S1"
				ssStruct.PositionOrigID = "SC-FM-Human-WeaponWorkbenchLarge01-03Doggy"
			elseIf (stageNumber == 3)
				ssStruct.FAnimFormID = 0x05031D14								
				ssStruct.MAnimFormID = 0x05031D15
				if (longScene < 1)
					ssStruct.StageTime = 12.0
				endIf
				ssStruct.PositionID = "DTSIX_794_S2"
				ssStruct.PositionOrigID = "SC-FM-Human-WeaponWorkbenchLarge01-04Doggy"
			elseIf (stageNumber == 4)
				ssStruct.FAnimFormID = 0x05033CDA				; v2.84	added stage							
				ssStruct.MAnimFormID = 0x05033CDB
				ssStruct.PositionID = "DTSIX_794_S3"
				ssStruct.PositionOrigID = "SC-FM-Human-WeaponWorkbenchLarge01-05Doggy"
			elseIf (longScene < 2 || stageNumber == 5)
				ssStruct.FAnimFormID = 0x05033CDC				; v2.84	added stage					
				ssStruct.MAnimFormID = 0x05033CDD
				ssStruct.PositionID = "DTSIX_794_S4"
				ssStruct.PositionOrigID = "SC-FM-Human-WeaponWorkbenchLarge01-06Doggy"
			elseIf (longScene >= 2)
				ssStruct.FAnimFormID = 0x050344EE				; v2.88	added stage					
				ssStruct.MAnimFormID = 0x050344EF
				ssStruct.PositionID = "DTSIX_794_S5"
				ssStruct.PositionOrigID = "SC-FM-Human-WeaponWorkbenchLarge01-07ClimaxLoop"
			endIf
		elseIf (seqID == 795)
			if (stageNumber <= 2)
				if (stageNumber == 1 && longScene >= 1)
					ssStruct.FAnimFormID = 0x0502D6FD
					ssStruct.MAnimFormID = 0x0502D6FE
					ssStruct.PositionID = "DTSIX_795_S0"
					ssStruct.PositionOrigID = "SC-FM-Human-JailCellTinyWithDoor01-01Tease"
				else
					ssStruct.FAnimFormID = 0x0502B0BD
					ssStruct.MAnimFormID = 0x0502B0BE
					ssStruct.PositionID = "DTSIX_795_S1"
					ssStruct.PositionOrigID = "SC-FM-Human-JailCellTinyWithDoor01-03Blowjob"
				endIf
			elseIf (stageNumber == 3)
				ssStruct.FAnimFormID = 0x0502B0BF	
				ssStruct.MAnimFormID = 0x0502B0C0
				ssStruct.PositionID = "DTSIX_795_S2"
				ssStruct.PositionOrigID = "SC-FM-Human-JailCellTinyWithDoor01-04Blowjob"
			elseIf (stageNumber == 4)
				ssStruct.FAnimFormID = 0x0502B0C1	
				ssStruct.MAnimFormID = 0x0502B0C2
				ssStruct.PositionID = "DTSIX_795_S3"
				ssStruct.PositionOrigID = "SC-FM-Human-JailCellTinyWithDoor01-05Blowjob"
			else
				ssStruct.FAnimFormID = 0x0502C014	
				ssStruct.MAnimFormID = 0x0502C015
				ssStruct.PositionID = "DTSIX_795_S4"
				ssStruct.PositionOrigID = "SC-FM-Human-JailCellTinyWithDoor01-06Facefuck"
			endIf
		elseIf (seqID == 796)
			;ssStruct.MPosYOffset = -28.0
			if (longScene <= 0)
				stageNumber += 1
			endIf
			
			if (stageNumber == 1)
				ssStruct.FAnimFormID = 0x05030560								; v2.50  SC 1.2.5
				ssStruct.MAnimFormID = 0x05030561
				ssStruct.PositionID = "DTSIX_796_S0"
				ssStruct.StageTime = 15.0
				ssStruct.PositionOrigID = "SC-FM-Human-JailCellSmall01-01Tease"
			elseIf (stageNumber == 2)
				ssStruct.FAnimFormID = 0x0502A135
				ssStruct.MAnimFormID = 0x0502A136
				ssStruct.PositionID = "DTSIX_796_S1"
				ssStruct.PositionOrigID = "SC-FM-Human-JailCellSmall01-03Standing"
			elseIf (stageNumber == 3)
				ssStruct.FAnimFormID = 0x0502A137	
				ssStruct.MAnimFormID = 0x0502A138
				ssStruct.PositionID = "DTSIX_796_S2"
				ssStruct.PositionOrigID = "SC-FM-Human-JailCellSmall01-04Standing"
			elseIf (stageNumber == 4 || (stageNumber == 6 && longScene <= 1))
				ssStruct.FAnimFormID = 0x0502B0B9	
				ssStruct.MAnimFormID = 0x0502B0BA
				ssStruct.PositionID = "DTSIX_796_S3"
				ssStruct.PositionOrigID = "SC-FM-Human-JailCellSmall01-05Carry"
			elseIf (stageNumber == 6 && longScene >= 2)
				ssStruct.FAnimFormID = 0x05032531								; v2.77 SC 1.2.7
				ssStruct.MAnimFormID = 0x05032532
				ssStruct.PositionID = "DTSIX_796_S5"
				ssStruct.PositionOrigID = "SC-FM-Human-JailCellSmall01-07ClimaxLoop"
			else
				ssStruct.FAnimFormID = 0x0502B0BB	
				ssStruct.MAnimFormID = 0x0502B0BC
				ssStruct.PositionID = "DTSIX_796_S4"
				ssStruct.PositionOrigID = "SC-FM-Human-JailCellSmall01-06Carry"
			endIf
			
		
		elseIf (seqID == 797)
			if (stageNumber == 1)
				ssStruct.FAnimFormID = 0x05031D48								; v2.70  SC 1.2.6 -- railing
				ssStruct.MAnimFormID = 0x05031D49
				ssStruct.PositionID = "DTSIX_797_S1"
				ssStruct.PositionOrigID = "SC-FM-Human-Railing01-01Tease"
			elseIf (stageNumber == 2)
				ssStruct.FAnimFormID = 0x05031D4A								
				ssStruct.MAnimFormID = 0x05031D4B
				ssStruct.PositionID = "DTSIX_797_S2"
				ssStruct.PositionOrigID = "SC-FM-Human-Railing01-02Start"
			elseIf (stageNumber == 3)
				ssStruct.FAnimFormID = 0x05031D4C							
				ssStruct.MAnimFormID = 0x05031D4D
				ssStruct.PositionID = "DTSIX_797_S3"
				ssStruct.PositionOrigID = "SC-FM-Human-Railing01-03Doggy"
			elseIf (stageNumber == 4)
				ssStruct.FAnimFormID = 0x05031D4E							
				ssStruct.MAnimFormID = 0x05031D4F
				ssStruct.PositionID = "DTSIX_797_S4"
				ssStruct.PositionOrigID = "SC-FM-Human-Railing01-04Sideways"
			elseIf (stageNumber == 5)
				ssStruct.FAnimFormID = 0x05031D50						
				ssStruct.MAnimFormID = 0x05031D51
				ssStruct.PositionID = "DTSIX_797_S5"
				ssStruct.PositionOrigID = "SC-FM-Human-Railing01-05Sideways"
			elseIf (stageNumber == 6)
				ssStruct.FAnimFormID = 0x05031D52					
				ssStruct.MAnimFormID = 0x05031D53
				ssStruct.PositionID = "DTSIX_797_S6"
				ssStruct.PositionOrigID = "SC-FM-Human-Railing01-06Sideways"
			elseIf (stageNumber == 7)
				ssStruct.FAnimFormID = 0x05031D54						
				ssStruct.MAnimFormID = 0x05031D55
				ssStruct.PositionID = "DTSIX_797_S7"
				ssStruct.PositionOrigID = "SC-FM-Human-Railing01-07ClimaxLoop"
			else
				ssStruct.FAnimFormID = 0x05031D56						
				ssStruct.MAnimFormID = 0x05031D57
				ssStruct.PositionID = "DTSIX_797_S8"
				ssStruct.PositionOrigID = "SC-FM-Human-Railing01-078Finish"
			endIf
		elseIf (seqID == 798)
			ssStruct.FAnimFormID = 0x05000FD3						; solo
			ssStruct.MAnimFormID = 0x05000FD4
			ssStruct.StageTime = 32.0
			ssStruct.PositionID = "DTSIXF_798_S1"
			ssStruct.PositionOrigID = "DTSIXM_798_S1"
			
		elseIf (seqID == 799)
			ssStruct.FAnimFormID = 0x0500CF43						; solo double-bed
			ssStruct.MAnimFormID = 0x0500CF44
			ssStruct.StageTime = 32.0
			ssStruct.PositionID = "DTSIXF_799_S1"
			ssStruct.PositionOrigID = "DTSIXM_799_S1"
		endIf
		
	; Leito's v2.1  -- v2.73
	elseIf (seqID >= 600 && seqID < 700)		
		ssStruct.PluginName = "FO4_AnimationsByLeito.esp"
		ssStruct.ArmorNudeAGun = 0
		
		if (seqID == 600)
			if (stageNumber == 1)
				ssStruct.FAnimFormID = 0x01004C8D			; A1 is female						
				ssStruct.MAnimFormID = 0x01004C8E			; A2 is male
				ssStruct.ArmorNudeAGun = 1
				ssStruct.MorphAngleA = 0.7
				ssStruct.PositionID = "DTSIX_601_S1"
				ssStruct.PositionOrigID = "LeitoMissionary_S1"
			elseIf (stageNumber == 2)
				ssStruct.FAnimFormID = 0x01002682								
				ssStruct.MAnimFormID = 0x01002685			
				ssStruct.ArmorNudeAGun = 1
				ssStruct.MorphAngleA = 0.7
				ssStruct.PositionID = "DTSIX_601_S2"
				ssStruct.PositionOrigID = "LeitoMissionary_S2"
			elseIf (stageNumber == 3)
				ssStruct.FAnimFormID = 0x01002683								
				ssStruct.MAnimFormID = 0x01002686			
				ssStruct.ArmorNudeAGun = 1
				ssStruct.MorphAngleA = 0.7
				ssStruct.PositionID = "DTSIX_601_S3"
				ssStruct.PositionOrigID = "LeitoMissionary_S3"
			else
				ssStruct.FAnimFormID = 0x01002684								
				ssStruct.MAnimFormID = 0x01002687			
				ssStruct.ArmorNudeAGun = 1
				ssStruct.MorphAngleA = 0.7
				ssStruct.PositionID = "DTSIX_601_S4"
				ssStruct.PositionOrigID = "LeitoMissionary_S4"
			endIf
		elseIf (seqID == 601)
			if (stageNumber == 1)
				ssStruct.FAnimFormID = 0x01002E2D									
				ssStruct.MAnimFormID = 0x01002E31			
				ssStruct.PositionID = "DTSIX_601_S1"
				ssStruct.PositionOrigID = "LeitoMissionary_2_S1"
			elseIf (stageNumber == 2)
				ssStruct.FAnimFormID = 0x01002682								
				ssStruct.MAnimFormID = 0x01002685			
				ssStruct.PositionID = "DTSIX_601_S2"
				ssStruct.PositionOrigID = "LeitoMissionary_2_S2"
			elseIf (stageNumber == 3)
				ssStruct.FAnimFormID = 0x01002683								
				ssStruct.MAnimFormID = 0x01002686			
				ssStruct.PositionID = "DTSIX_601_S3"
				ssStruct.PositionOrigID = "LeitoMissionary_2_S3"
			else
				ssStruct.FAnimFormID = 0x01002684								
				ssStruct.MAnimFormID = 0x01002687			
				ssStruct.PositionID = "DTSIX_601_S4"
				ssStruct.PositionOrigID = "LeitoMissionary_2_S4"
			endIf
		elseIf (seqID == 602)
			if (stageNumber == 1)
				ssStruct.FAnimFormID = 0x01001739									
				ssStruct.MAnimFormID = 0x01001738			
				ssStruct.PositionID = "DTSIX_602_S1"
				ssStruct.PositionOrigID = "Leito_Doggy_1_S1"
			elseIf (stageNumber == 2)
				ssStruct.FAnimFormID = 0x01001EDE								
				ssStruct.MAnimFormID = 0x01001EE1			
				ssStruct.PositionID = "DTSIX_602_S2"
				ssStruct.PositionOrigID = "Leito_Doggy_1_S2"
			elseIf (stageNumber == 3)
				ssStruct.FAnimFormID = 0x01001EDF								
				ssStruct.MAnimFormID = 0x01001EE2			
				ssStruct.PositionID = "DTSIX_602_S3"
				ssStruct.PositionOrigID = "Leito_Doggy_1_S3"
			else
				ssStruct.FAnimFormID = 0x01001EE0								
				ssStruct.MAnimFormID = 0x01001EE3			
				ssStruct.PositionID = "DTSIX_602_S4"
				ssStruct.PositionOrigID = "Leito_Doggy_1_S4"
			endIf
		elseIf (seqID == 603)
			if (stageNumber == 1)
				ssStruct.FAnimFormID = 0x01002E35									
				ssStruct.MAnimFormID = 0x01002E39			
				ssStruct.PositionID = "DTSIX_603_S1"
				ssStruct.PositionOrigID = "Leito_Doggy_2_S1"
			elseIf (stageNumber == 2)
				ssStruct.FAnimFormID = 0x01002E36								
				ssStruct.MAnimFormID = 0x01002E3A			
				ssStruct.PositionID = "DTSIX_603_S2"
				ssStruct.PositionOrigID = "Leito_Doggy_2_S2"
			elseIf (stageNumber == 3)
				ssStruct.FAnimFormID = 0x01002E37								
				ssStruct.MAnimFormID = 0x01002E3B			
				ssStruct.PositionID = "DTSIX_603_S3"
				ssStruct.PositionOrigID = "Leito_Doggy_2_S3"
			else
				ssStruct.FAnimFormID = 0x01002E38								
				ssStruct.MAnimFormID = 0x01002E3C			
				ssStruct.PositionID = "DTSIX_603_S4"
				ssStruct.PositionOrigID = "Leito_Doggy_2_S4"
			endIf
		elseIf (seqID == 604)
			if (stageNumber == 1)
				ssStruct.FAnimFormID = 0x0100173F									
				ssStruct.MAnimFormID = 0x01001740			
				ssStruct.PositionID = "DTSIX_604_S1"
				ssStruct.PositionOrigID = "LeitoCowgirl_S1"
			elseIf (stageNumber == 2)
				ssStruct.FAnimFormID = 0x01002E27								
				ssStruct.MAnimFormID = 0x01002E2A
				ssStruct.ArmorNudeAGun = 1
				ssStruct.MorphAngleA = 0.6				
				ssStruct.PositionID = "DTSIX_604_S2"
				ssStruct.PositionOrigID = "LeitoCowgirl_S2"
			elseIf (stageNumber == 3)
				ssStruct.FAnimFormID = 0x01002E28								
				ssStruct.MAnimFormID = 0x01002E2B
				ssStruct.ArmorNudeAGun = 1
				ssStruct.MorphAngleA = 1.5				; increased to avoid sticking through backside when female leans down v2.73
				ssStruct.PositionID = "DTSIX_604_S3"
				ssStruct.PositionOrigID = "LeitoCowgirl_S3"
			else
				ssStruct.FAnimFormID = 0x01002E29								
				ssStruct.MAnimFormID = 0x01002E2C
				ssStruct.ArmorNudeAGun = 1
				ssStruct.MorphAngleA = 1.0
				ssStruct.PositionID = "DTSIX_604_S4"
				ssStruct.PositionOrigID = "LeitoCowgirl_S4"
			endIf
		elseIf (seqID == 605)
			if (stageNumber == 1)
				ssStruct.FAnimFormID = 0x01005C34									
				ssStruct.MAnimFormID = 0x01005C38
				ssStruct.ArmorNudeAGun = 2							; down a bit v2.73
				ssStruct.MorphAngleA = 0.12				
				ssStruct.PositionID = "DTSIX_605_S1"
				ssStruct.PositionOrigID = "Leito_Cowgirl_2_S1"
			elseIf (stageNumber == 2)
				ssStruct.FAnimFormID = 0x01005C35								
				ssStruct.MAnimFormID = 0x01005C39				
				ssStruct.PositionID = "DTSIX_605_S2"
				ssStruct.PositionOrigID = "Leito_Cowgirl_2_S2"
			elseIf (stageNumber == 3)
				ssStruct.FAnimFormID = 0x01005C36								
				ssStruct.MAnimFormID = 0x01005C3A
				ssStruct.PositionID = "DTSIX_605_S3"
				ssStruct.PositionOrigID = "Leito_Cowgirl_2_S3"
			else
				ssStruct.FAnimFormID = 0x01005C37								
				ssStruct.MAnimFormID = 0x01005C3B
				ssStruct.PositionID = "DTSIX_605_S4"
				ssStruct.PositionOrigID = "Leito_Cowgirl_2_S4"
			endIf
		elseIf (seqID == 606)
			if (stageNumber == 1)
				ssStruct.FAnimFormID = 0x010063DF									
				ssStruct.MAnimFormID = 0x010063E3
				ssStruct.ArmorNudeAGun = 2
				ssStruct.MorphAngleA = 1.0
				ssStruct.PositionID = "DTSIX_606_S1"
				ssStruct.PositionOrigID = "Leito_Cowgirl_3_S1"
			elseIf (stageNumber == 2)
				ssStruct.FAnimFormID = 0x010063E0								
				ssStruct.MAnimFormID = 0x010063E4
				ssStruct.ArmorNudeAGun = 2
				ssStruct.MorphAngleA = 1.3							; increased v2.73
				ssStruct.PositionID = "DTSIX_606_S2"
				ssStruct.PositionOrigID = "Leito_Cowgirl_3_S2"
			elseIf (stageNumber == 3)
				ssStruct.FAnimFormID = 0x010063E1								
				ssStruct.MAnimFormID = 0x010063E5
				ssStruct.ArmorNudeAGun = 2
				ssStruct.MorphAngleA = 1.0
				ssStruct.PositionID = "DTSIX_606_S3"
				ssStruct.PositionOrigID = "Leito_Cowgirl_3_S3"
			else
				ssStruct.FAnimFormID = 0x010063E2								
				ssStruct.MAnimFormID = 0x010063E6
				ssStruct.ArmorNudeAGun = 2
				ssStruct.MorphAngleA = 1.4							; increased v2.73
				ssStruct.PositionID = "DTSIX_606_S4"
				ssStruct.PositionOrigID = "Leito_Cowgirl_3_S4"
			endIf
		elseIf (seqID == 607)
			if (stageNumber == 1)
				ssStruct.FAnimFormID = 0x0100A899									
				ssStruct.MAnimFormID = 0x0100A89D
				ssStruct.PositionID = "DTSIX_607_S1"
				ssStruct.PositionOrigID = "Leito_Cowgirl_4_S1"
			elseIf (stageNumber == 2)
				ssStruct.FAnimFormID = 0x0100A89A								
				ssStruct.MAnimFormID = 0x0100A89E
				ssStruct.PositionID = "DTSIX_607_S2"
				ssStruct.PositionOrigID = "Leito_Cowgirl_4_S2"
			elseIf (stageNumber == 3)
				ssStruct.FAnimFormID = 0x0100A89B								
				ssStruct.MAnimFormID = 0x0100A89F
				ssStruct.PositionID = "DTSIX_607_S3"
				ssStruct.PositionOrigID = "Leito_Cowgirl_4_S3"
			else
				ssStruct.FAnimFormID = 0x0100A89C								
				ssStruct.MAnimFormID = 0x0100A8A0
				ssStruct.PositionID = "DTSIX_607_S4"
				ssStruct.PositionOrigID = "Leito_Cowgirl_4_S4"
			endIf
		elseIf (seqID == 608)
			if (stageNumber == 1)
				ssStruct.FAnimFormID = 0x01006B82									
				ssStruct.MAnimFormID = 0x01006B86
				ssStruct.ArmorNudeAGun = 1
				ssStruct.MorphAngleA = 1.30									; increased v2.73
				ssStruct.PositionID = "DTSIX_608_S1"
				ssStruct.PositionOrigID = "Leito_ReverseCowgirl_1_S1"
			elseIf (stageNumber == 2)
				ssStruct.FAnimFormID = 0x01006B83								
				ssStruct.MAnimFormID = 0x01006B87
				ssStruct.ArmorNudeAGun = 1
				ssStruct.MorphAngleA = 1.25									; increased v2.73
				ssStruct.PositionID = "DTSIX_608_S2"
				ssStruct.PositionOrigID = "Leito_ReverseCowgirl_1_S2"
			elseIf (stageNumber == 3)
				ssStruct.FAnimFormID = 0x01006B84								
				ssStruct.MAnimFormID = 0x01006B88
				ssStruct.ArmorNudeAGun = 1
				ssStruct.MorphAngleA = 1.25									; increased v2.73
				ssStruct.PositionID = "DTSIX_608_S3"
				ssStruct.PositionOrigID = "Leito_ReverseCowgirl_1_S3"
			else
				ssStruct.FAnimFormID = 0x01006B85								
				ssStruct.MAnimFormID = 0x01006B89
				ssStruct.ArmorNudeAGun = 1
				ssStruct.MorphAngleA = 1.25									; increased v2.73
				ssStruct.PositionID = "DTSIX_608_S4"
				ssStruct.PositionOrigID = "Leito_ReverseCowgirl_1_S4"
			endIf
		elseIf (seqID == 609)
			if (stageNumber == 1)
				ssStruct.FAnimFormID = 0x0100732E									
				ssStruct.MAnimFormID = 0x01007332
				ssStruct.ArmorNudeAGun = 1
				ssStruct.MorphAngleA = 1.4
				ssStruct.PositionID = "DTSIX_609_S1"
				ssStruct.PositionOrigID = "Leito_ReverseCowgirl_2_S1"
			elseIf (stageNumber == 2)
				ssStruct.FAnimFormID = 0x0100732F								
				ssStruct.MAnimFormID = 0x01007333
				ssStruct.ArmorNudeAGun = 1
				ssStruct.MorphAngleA = 1.6
				ssStruct.PositionID = "DTSIX_609_S2"
				ssStruct.PositionOrigID = "Leito_ReverseCowgirl_2_S2"
			elseIf (stageNumber == 3)
				ssStruct.FAnimFormID = 0x01007330								
				ssStruct.MAnimFormID = 0x01007334
				ssStruct.ArmorNudeAGun = 1
				ssStruct.MorphAngleA = 2.0								; originally 1.4---needs to go above maximum value
				ssStruct.PositionID = "DTSIX_609_S3"
				ssStruct.PositionOrigID = "Leito_ReverseCowgirl_2_S3"
			else
				ssStruct.FAnimFormID = 0x01007331								
				ssStruct.MAnimFormID = 0x01007335
				ssStruct.ArmorNudeAGun = 1
				ssStruct.MorphAngleA = 2.0
				ssStruct.PositionID = "DTSIX_609_S4"
				ssStruct.PositionOrigID = "Leito_ReverseCowgirl_2_S4"
			endIf
		elseIf (seqID == 610)
			if (stageNumber == 1)
				ssStruct.FAnimFormID = 0x01004CEB									
				ssStruct.MAnimFormID = 0x01004CEF
				ssStruct.ArmorNudeAGun = 1
				ssStruct.MorphAngleA = 2.2
				ssStruct.PositionID = "DTSIX_610_S1"
				ssStruct.PositionOrigID = "Leito_Spoon_S1"
			elseIf (stageNumber == 2)
				ssStruct.FAnimFormID = 0x01004CEC								
				ssStruct.MAnimFormID = 0x01004CF0
				ssStruct.ArmorNudeAGun = 1
				ssStruct.MorphAngleA = 2.2
				ssStruct.PositionID = "DTSIX_610_S2"
				ssStruct.PositionOrigID = "Leito_Spoon_S2"
			elseIf (stageNumber == 3)
				ssStruct.FAnimFormID = 0x01004CED								
				ssStruct.MAnimFormID = 0x01004CF1
				ssStruct.ArmorNudeAGun = 1
				ssStruct.MorphAngleA = 1.8
				ssStruct.PositionID = "DTSIX_610_S3"
				ssStruct.PositionOrigID = "Leito_Spoon_S3"
			else
				ssStruct.FAnimFormID = 0x01004CEE								
				ssStruct.MAnimFormID = 0x01004CF2
				ssStruct.ArmorNudeAGun = 1
				ssStruct.MorphAngleA = 1.8
				ssStruct.PositionID = "DTSIX_610_S4"
				ssStruct.PositionOrigID = "Leito_Spoon_S4"
			endIf
		elseIf (seqID == 650)
			if (stageNumber == 1)
				ssStruct.FAnimFormID = 0x01004CB2									
				ssStruct.MAnimFormID = 0x01004CB6
				ssStruct.ArmorNudeAGun = 2					;  on no-morph setting, PlayAAC will switch to 0 for minor MorphAngleA
				ssStruct.MorphAngleA = 0.2
				ssStruct.PositionID = "DTSIX_650_S1"
				ssStruct.PositionOrigID = "Leito_Blowjob_S1"
			elseIf (stageNumber == 2)
				ssStruct.FAnimFormID = 0x01004CB3								
				ssStruct.MAnimFormID = 0x01004CB7
				ssStruct.ArmorNudeAGun = 2
				ssStruct.MorphAngleA = 0.2
				ssStruct.PositionID = "DTSIX_650_S2"
				ssStruct.PositionOrigID = "Leito_Blowjob_S2"
			elseIf (stageNumber == 3)
				ssStruct.FAnimFormID = 0x01004CB4								
				ssStruct.MAnimFormID = 0x01004CB8
				ssStruct.ArmorNudeAGun = 2
				ssStruct.MorphAngleA = 0.2
				ssStruct.PositionID = "DTSIX_650_S3"
				ssStruct.PositionOrigID = "Leito_Blowjob_S3"
			else
				ssStruct.FAnimFormID = 0x01004CB5								
				ssStruct.MAnimFormID = 0x01004CB9
				ssStruct.ArmorNudeAGun = 2
				ssStruct.MorphAngleA = 0.2
				ssStruct.PositionID = "DTSIX_650_S4"
				ssStruct.PositionOrigID = "Leito_Blowjob_S4"
			endIf
		elseIf (seqID == 651 || (seqID == 653 && stageNumber == 1))
			if (stageNumber == 1)
				ssStruct.FAnimFormID = 0x01007AD1									
				ssStruct.MAnimFormID = 0x01007AD5
				ssStruct.ArmorNudeAGun = 1
				ssStruct.MorphAngleA = 2.0
				ssStruct.PositionID = "DTSIX_651_S1"
				ssStruct.PositionOrigID = "Leito_StandingDoggy_1_S1"
			elseIf (stageNumber == 2)
				ssStruct.FAnimFormID = 0x01007AD2								
				ssStruct.MAnimFormID = 0x01007AD6
				ssStruct.ArmorNudeAGun = 1
				ssStruct.MorphAngleA = 2.0
				ssStruct.PositionID = "DTSIX_651_S2"
				ssStruct.PositionOrigID = "Leito_StandingDoggy_1_S2"
			elseIf (stageNumber == 3)
				ssStruct.FAnimFormID = 0x01007AD3								
				ssStruct.MAnimFormID = 0x01007AD7
				ssStruct.ArmorNudeAGun = 1
				ssStruct.MorphAngleA = 1.5
				ssStruct.PositionID = "DTSIX_651_S3"
				ssStruct.PositionOrigID = "Leito_StandingDoggy_1_S3"
			else
				ssStruct.FAnimFormID = 0x01007AD4								
				ssStruct.MAnimFormID = 0x01007AD8
				ssStruct.ArmorNudeAGun = 1
				ssStruct.MorphAngleA = 1.5
				ssStruct.PositionID = "DTSIX_651_S4"
				ssStruct.PositionOrigID = "Leito_StandingDoggy_1_S4"
			endIf
		elseIf (seqID >= 652 && seqID <= 653)
			int sNum = stageNumber
			
			if (sNum == 1)
				ssStruct.FAnimFormID = 0x01007AD9									
				ssStruct.MAnimFormID = 0x01007ADD
				ssStruct.PositionID = "DTSIX_652_S1"
				ssStruct.PositionOrigID = "Leito_StandingDoggy_2_S1"
			elseIf (sNum == 2)
				ssStruct.FAnimFormID = 0x01007ADA								
				ssStruct.MAnimFormID = 0x01007ADE
				ssStruct.PositionID = "DTSIX_652_S2"
				ssStruct.PositionOrigID = "Leito_StandingDoggy_2_S2"
			elseIf (sNum == 3)
				ssStruct.FAnimFormID = 0x01007ADB								
				ssStruct.MAnimFormID = 0x01007ADF
				ssStruct.PositionID = "DTSIX_652_S3"
				ssStruct.PositionOrigID = "Leito_StandingDoggy_2_S3"
			else
				ssStruct.FAnimFormID = 0x01007ADC								
				ssStruct.MAnimFormID = 0x01007AE0
				ssStruct.PositionID = "DTSIX_652_S4"
				ssStruct.PositionOrigID = "Leito_StandingDoggy_2_S4"
			endIf
		elseIf (seqID == 654)
			if (stageNumber == 1)
				ssStruct.FAnimFormID = 0x01004503									
				ssStruct.MAnimFormID = 0x01004507
				ssStruct.ArmorNudeAGun = 1			
				ssStruct.MorphAngleA = 0.7
				ssStruct.PositionID = "DTSIX_654_S1"
				ssStruct.PositionOrigID = "Leito_Carry_1_S1"
			elseIf (stageNumber == 2)
				ssStruct.FAnimFormID = 0x01004504								
				ssStruct.MAnimFormID = 0x01004508
				ssStruct.ArmorNudeAGun = 1
				ssStruct.MorphAngleA = 0.7
				ssStruct.PositionID = "DTSIX_654_S2"
				ssStruct.PositionOrigID = "Leito_Carry_1_S2"
			elseIf (stageNumber == 3)
				ssStruct.FAnimFormID = 0x01004505								
				ssStruct.MAnimFormID = 0x01004509
				ssStruct.ArmorNudeAGun = 1
				ssStruct.MorphAngleA = 0.7
				ssStruct.PositionID = "DTSIX_654_S3"
				ssStruct.PositionOrigID = "Leito_Carry_1_S3"
			else
				ssStruct.FAnimFormID = 0x01004506								
				ssStruct.MAnimFormID = 0x0100450A
				ssStruct.ArmorNudeAGun = 1
				ssStruct.MorphAngleA = 0.7
				ssStruct.PositionID = "DTSIX_654_S4"
				ssStruct.PositionOrigID = "Leito_Carry_1_S4"
			endIf
		elseIf (seqID == 655)
			if (stageNumber == 1)
				ssStruct.FAnimFormID = 0x0100A891									
				ssStruct.MAnimFormID = 0x0100A895
				ssStruct.ArmorNudeAGun = 1			
				ssStruct.MorphAngleA = 0.7
				ssStruct.PositionID = "DTSIX_655_S1"
				ssStruct.PositionOrigID = "Leito_Carry_2_S1"
			elseIf (stageNumber == 2)
				ssStruct.FAnimFormID = 0x0100A892								
				ssStruct.MAnimFormID = 0x0100A896
				ssStruct.ArmorNudeAGun = 1
				ssStruct.MorphAngleA = 0.7
				ssStruct.PositionID = "DTSIX_655_S2"
				ssStruct.PositionOrigID = "Leito_Carry_2_S2"
			elseIf (stageNumber == 3)
				ssStruct.FAnimFormID = 0x0100A893								
				ssStruct.MAnimFormID = 0x0100A897
				ssStruct.ArmorNudeAGun = 1
				ssStruct.MorphAngleA = 0.7
				ssStruct.PositionID = "DTSIX_655_S3"
				ssStruct.PositionOrigID = "Leito_Carry_2_S3"
			else
				ssStruct.FAnimFormID = 0x0100A894								
				ssStruct.MAnimFormID = 0x0100A898
				ssStruct.ArmorNudeAGun = 1
				ssStruct.MorphAngleA = 0.7
				ssStruct.PositionID = "DTSIX_655_S4"
				ssStruct.PositionOrigID = "Leito_Carry_2_S4"
			endIf
		elseIf (seqID >= 660 && seqID < 670)								; super mutant mixes original single-stage scenes
			int sNum = stageNumber
			if (seqID == 660)
				if (stageNumber == 2)
					sNum = 4
				elseIf (stageNumber == 3)
					sNum = 2
				endIf
			elseIf (seqID == 661)
				if (stageNumber == 1 || stageNumber == 3)
					sNum = 3
				else
					sNum = 4
				endIf
			elseIf (seqID == 662)
				if (stageNumber == 1 || stageNumber == 3)
					sNum = 4
				else
					sNum = 3
				endIf
			elseIf (seqID >= 663)
				if (stageNumber <= 2)
					sNum = 2
				endIf
			endIf
			
			if (sNum == 1)
				ssStruct.FAnimFormID = 0x01001EDC								
				ssStruct.MAnimFormID = 0x01001EDD
				ssStruct.ArmorNudeAGun = 1
				ssStruct.MorphAngleA = 1.0
				ssStruct.PositionID = "DTSIXSM_660_S1"
				ssStruct.PositionOrigID = "Leito_SuperMutant_Carry"
			elseIf (sNum == 2)
				ssStruct.FAnimFormID = 0x01004C8F								
				ssStruct.MAnimFormID = 0x01004C8C
				ssStruct.ArmorNudeAGun = 1
				ssStruct.MorphAngleA = 0.9
				ssStruct.PositionID = "DTSIXSM_663_S1"
				ssStruct.PositionOrigID = "Leito_SuperMutant_ReverseCarry"
			elseIf (sNum == 3)
				ssStruct.FAnimFormID = 0x0100542B								
				ssStruct.MAnimFormID = 0x0100542E
				ssStruct.ArmorNudeAGun = 0					; fix v3.16
				ssStruct.MorphAngleA = 0.12
				ssStruct.PositionID = "DTSIXSM_661_S1"
				ssStruct.PositionOrigID = "Leito_SuperMutant_StandingDoggy"
			else
				ssStruct.FAnimFormID = 0x0100542C								
				ssStruct.MAnimFormID = 0x0100542F
				ssStruct.ArmorNudeAGun = 0					; fix v3.16
				ssStruct.MorphAngleA = 0.16
				ssStruct.PositionID = "DTSIXSM_662_S1"
				ssStruct.PositionOrigID = "Leito_SuperMutant_StandingSideways"
			endIf
			
		; new Leito 2.1 chair scenes
		elseIf (seqID == 682)
			if (stageNumber == 1)
				ssStruct.FAnimFormID = 0x060035F4			; A1 is female						
				ssStruct.MAnimFormID = 0x050035F8			; A2 is male
				ssStruct.PositionID = "DTSIX_682_S1"
				ssStruct.PositionOrigID = "Leito_Chair_Missionary_1_S1"
			elseIf (stageNumber == 2)
				ssStruct.FAnimFormID = 0x060035F5								
				ssStruct.MAnimFormID = 0x050035F9
				;ssStruct.ArmorNudeAGun = 2					; from XML at 0.2, but 0 works well, too
				ssStruct.PositionID = "DTSIX_682_S2"
				ssStruct.PositionOrigID = "Leito_Chair_Missionary_1_S2"
			elseIf (stageNumber == 3)
				ssStruct.FAnimFormID = 0x060035F6								
				ssStruct.MAnimFormID = 0x050035FA
				ssStruct.ArmorNudeAGun = 0				
				ssStruct.PositionID = "DTSIX_682_S3"
				ssStruct.PositionOrigID = "Leito_Chair_Missionary_1_S3"
			else
				ssStruct.FAnimFormID = 0x060035F7								
				ssStruct.MAnimFormID = 0x050035FB
				ssStruct.ArmorNudeAGun = 1
				ssStruct.MorphAngleA = 0.2
				ssStruct.PositionID = "DTSIX_682_S4"
				ssStruct.PositionOrigID = "Leito_Chair_Missionary_1_S4"
			endIf
		elseIf (seqID == 683)
			if (stageNumber == 1)
				ssStruct.FAnimFormID = 0x06003D9D								
				ssStruct.MAnimFormID = 0x05003DA1			
				ssStruct.PositionID = "DTSIX_683_S1"
				ssStruct.PositionOrigID = "Leito_Chair_Doggy_1_S1"
			elseIf (stageNumber == 2)
				ssStruct.FAnimFormID = 0x06003D9E								
				ssStruct.MAnimFormID = 0x05003DA2
				;ssStruct.ArmorNudeAGun = 1						; from XML at 0.3, but forward works, too
				ssStruct.PositionID = "DTSIX_683_S2"
				ssStruct.PositionOrigID = "Leito_Chair_Doggy_1_S2"
			elseIf (stageNumber == 3)
				ssStruct.FAnimFormID = 0x06003D9F								
				ssStruct.MAnimFormID = 0x05003DA3			
				ssStruct.PositionID = "DTSIX_683_S3"
				ssStruct.PositionOrigID = "Leito_Chair_Doggy_1_S3"
			else
				ssStruct.FAnimFormID = 0x06003DA0								
				ssStruct.MAnimFormID = 0x05003DA4			
				ssStruct.PositionID = "DTSIX_683_S4"
				ssStruct.PositionOrigID = "Leito_Chair_Doggy_1_S4"
			endIf
		elseIf (seqID == 684)
			if (stageNumber == 1)
				ssStruct.FAnimFormID = 0x0600B042								
				ssStruct.MAnimFormID = 0x0500B043			
				ssStruct.PositionID = "DTSIX_684_S1"
				ssStruct.PositionOrigID = "Leito_Chair_Cowgirl_1_S1"
			elseIf (stageNumber == 2)
				ssStruct.FAnimFormID = 0x0600B7F0								
				ssStruct.MAnimFormID = 0x0500B7F3			
				ssStruct.PositionID = "DTSIX_684_S2"
				ssStruct.PositionOrigID = "Leito_Chair_Cowgirl_1_S2"
			elseIf (stageNumber == 3)
				ssStruct.FAnimFormID = 0x0600B7F1								
				ssStruct.MAnimFormID = 0x0500B7F4
				ssStruct.ArmorNudeAGun = 1
				ssStruct.MorphAngleA = 2.0
				ssStruct.PositionID = "DTSIX_684_S3"
				ssStruct.PositionOrigID = "Leito_Chair_Cowgirl_1_S3"
			else
				ssStruct.FAnimFormID = 0x0600B7F2								
				ssStruct.MAnimFormID = 0x0500B7F5
				ssStruct.ArmorNudeAGun = 1
				ssStruct.MorphAngleA = 2.0
				ssStruct.PositionID = "DTSIX_684_S4"
				ssStruct.PositionOrigID = "Leito_Chair_Cowgirl_1_S4"
			endIf
		elseIf (seqID == 685)
			if (stageNumber == 1)
				ssStruct.FAnimFormID = 0x0600BF92							
				ssStruct.MAnimFormID = 0x0500BF96
				ssStruct.ArmorNudeAGun = 1					
				ssStruct.MorphAngleA = 0.5
				ssStruct.PositionID = "DTSIX_685_S1"
				ssStruct.PositionOrigID = "Leito_Chair_ReverseCowgirl_S1"
			elseIf (stageNumber == 2)
				ssStruct.FAnimFormID = 0x0600BF93						
				ssStruct.MAnimFormID = 0x0500BF97
				ssStruct.ArmorNudeAGun = 1
				ssStruct.MorphAngleA = 0.1
				ssStruct.PositionID = "DTSIX_685_S2"
				ssStruct.PositionOrigID = "Leito_Chair_ReverseCowgirl_S2"
			elseIf (stageNumber == 3)
				ssStruct.FAnimFormID = 0x0600BF94						
				ssStruct.MAnimFormID = 0x0500BF98
				ssStruct.ArmorNudeAGun = 1
				ssStruct.MorphAngleA = 0.1
				ssStruct.PositionID = "DTSIX_685_S3"
				ssStruct.PositionOrigID = "Leito_Chair_ReverseCowgirl_S3"
			else
				ssStruct.FAnimFormID = 0x0600BF95						
				ssStruct.MAnimFormID = 0x0500BF99
				ssStruct.ArmorNudeAGun = 1
				ssStruct.MorphAngleA = 0.1
				ssStruct.PositionID = "DTSIX_685_S4"
				ssStruct.PositionOrigID = "Leito_Chair_ReverseCowgirl_S4"
			endIf
		elseIf (seqID == 686)
			if (stageNumber == 1)
				ssStruct.FAnimFormID = 0x0600C733							
				ssStruct.MAnimFormID = 0x0500C737
				ssStruct.ArmorNudeAGun = 1
				ssStruct.MorphAngleA = 2.0
				ssStruct.PositionID = "DTSIX_686_S1"
				ssStruct.PositionOrigID = "Leito_Chair_Cowgirl_2_S1"
			elseIf (stageNumber == 2)
				ssStruct.FAnimFormID = 0x0600C734							
				ssStruct.MAnimFormID = 0x0500C738
				ssStruct.ArmorNudeAGun = 1
				ssStruct.MorphAngleA = 2.0
				ssStruct.PositionID = "DTSIX_686_S2"
				ssStruct.PositionOrigID = "Leito_Chair_Cowgirl_2_S2"
			elseIf (stageNumber == 3)
				ssStruct.FAnimFormID = 0x0600C735							
				ssStruct.MAnimFormID = 0x0500C739
				ssStruct.ArmorNudeAGun = 1
				ssStruct.MorphAngleA = 2.0
				ssStruct.PositionID = "DTSIX_686_S3"
				ssStruct.PositionOrigID = "Leito_Chair_Cowgirl_2_S3"
			else
				ssStruct.FAnimFormID = 0x0600C736							
				ssStruct.MAnimFormID = 0x0500C73A
				ssStruct.ArmorNudeAGun = 1
				ssStruct.MorphAngleA = 2.0
				ssStruct.PositionID = "DTSIX_686_S4"
				ssStruct.PositionOrigID = "Leito_Chair_Cowgirl_2_S4"
			endIf
		elseIf (seqID == 687)
			if (stageNumber == 1)
				ssStruct.FAnimFormID = 0x0600CED5							
				ssStruct.MAnimFormID = 0x0500CED9
				ssStruct.ArmorNudeAGun = 1
				ssStruct.MorphAngleA = 0.5
				ssStruct.PositionID = "DTSIX_687_S1"
				ssStruct.PositionOrigID = "Leito_Chair_ReverseCowgirl_2_S1"
			elseIf (stageNumber == 2)
				ssStruct.FAnimFormID = 0x0600CED6							
				ssStruct.MAnimFormID = 0x0500CEDA
				ssStruct.ArmorNudeAGun = 1
				ssStruct.MorphAngleA = 0.2
				ssStruct.PositionID = "DTSIX_687_S2"
				ssStruct.PositionOrigID = "Leito_Chair_ReverseCowgirl_2_S2"
			elseIf (stageNumber == 3)
				ssStruct.FAnimFormID = 0x0600CED7							
				ssStruct.MAnimFormID = 0x0500CEDB
				ssStruct.ArmorNudeAGun = 1
				ssStruct.MorphAngleA = 0.2
				ssStruct.PositionID = "DTSIX_687_S3"
				ssStruct.PositionOrigID = "Leito_Chair_ReverseCowgirl_2_S3"
			else
				ssStruct.FAnimFormID = 0x0600CED8							
				ssStruct.MAnimFormID = 0x0500CEDC
				ssStruct.ArmorNudeAGun = 1
				ssStruct.MorphAngleA = 0.2
				ssStruct.PositionID = "DTSIX_687_S4"
				ssStruct.PositionOrigID = "Leito_Chair_ReverseCowgirl_2_S4"
			endIf
		elseIf (seqID == 688)
			if (stageNumber == 1)
				ssStruct.FAnimFormID = 0x0600CEDD							
				ssStruct.MAnimFormID = 0x0500CEE1
				ssStruct.ArmorNudeAGun = 0
				ssStruct.PositionID = "DTSIX_688_S1"
				ssStruct.PositionOrigID = "Leito_Chair_ReverseCowgirl_3_S1"
			elseIf (stageNumber == 2)
				ssStruct.FAnimFormID = 0x0600CEDE							
				ssStruct.MAnimFormID = 0x0500CEE2
				ssStruct.ArmorNudeAGun = 0
				ssStruct.PositionID = "DTSIX_688_S2"
				ssStruct.PositionOrigID = "Leito_Chair_ReverseCowgirl_3_S2"
			elseIf (stageNumber == 3)
				ssStruct.FAnimFormID = 0x0600CEDF				
				ssStruct.MAnimFormID = 0x0500CEE3
				ssStruct.ArmorNudeAGun = 2
				ssStruct.MorphAngleA = 0.25						; decrease from forward until limit of non-morph
				ssStruct.PositionID = "DTSIX_688_S3"
				ssStruct.PositionOrigID = "Leito_Chair_ReverseCowgirl_3_S3"
			else
				ssStruct.FAnimFormID = 0x0600CEE0				
				ssStruct.MAnimFormID = 0x0500CEE4
				ssStruct.ArmorNudeAGun = 2
				ssStruct.MorphAngleA = 0.5
				ssStruct.PositionID = "DTSIX_688_S4"
				ssStruct.PositionOrigID = "Leito_Chair_ReverseCowgirl_3_S4"
			endIf
		elseIf (seqID == 695)									; Do not use!!  idle animations missing
			if (stageNumber == 1)
				ssStruct.FAnimFormID = 0x0600640C							
				ssStruct.MAnimFormID = 0x05006410
				ssStruct.ArmorNudeAGun = 0
				ssStruct.PositionID = "DTSIXSM_695_S1"
				ssStruct.PositionOrigID = "Leito_SuperMutant_BJ_S1"
			elseIf (stageNumber == 2)
				ssStruct.FAnimFormID = 0x0600640D							
				ssStruct.MAnimFormID = 0x05006411
				ssStruct.ArmorNudeAGun = 0
				ssStruct.PositionID = "DTSIXSM_695_S2"
				ssStruct.PositionOrigID = "Leito_SuperMutant_BJ_S2"
			elseIf (stageNumber == 3)
				ssStruct.FAnimFormID = 0x0600640E				
				ssStruct.MAnimFormID = 0x05006412
				ssStruct.ArmorNudeAGun = 0
				ssStruct.PositionID = "DTSIXSM_695_S3"
				ssStruct.PositionOrigID = "Leito_SuperMutant_BJ_S3"
			else
				ssStruct.FAnimFormID = 0x0600640F				
				ssStruct.MAnimFormID = 0x05006413
				ssStruct.ArmorNudeAGun = 0
				ssStruct.PositionID = "DTSIXSM_695_S4"
				ssStruct.PositionOrigID = "Leito_SuperMutant_BJ_S4"
			endIf
		elseIf (seqID == 696)
			if (stageNumber == 1)
				ssStruct.FAnimFormID = 0x06002E55							
				ssStruct.MAnimFormID = 0x05002E51
				ssStruct.ArmorNudeAGun = 0
				ssStruct.PositionID = "DTSIXSM_696_S1"
				ssStruct.PositionOrigID = "Leito_SuperMutant_Chair_Cowgirl_1_S1"
			elseIf (stageNumber == 2)
				ssStruct.FAnimFormID = 0x06002E56							
				ssStruct.MAnimFormID = 0x05002E52
				ssStruct.ArmorNudeAGun = 0
				ssStruct.PositionID = "DTSIXSM_696_S2"
				ssStruct.PositionOrigID = "Leito_SuperMutant_Chair_Cowgirl_1_S2"
			elseIf (stageNumber == 3)
				ssStruct.FAnimFormID = 0x06002E57				
				ssStruct.MAnimFormID = 0x05002E53
				ssStruct.ArmorNudeAGun = 1
				ssStruct.MorphAngleA = 2.0
				ssStruct.PositionID = "DTSIXSM_696_S3"
				ssStruct.PositionOrigID = "Leito_SuperMutant_Chair_Cowgirl_1_S3"
			else
				ssStruct.FAnimFormID = 0x06002E58				
				ssStruct.MAnimFormID = 0x05002E54
				ssStruct.ArmorNudeAGun = 1
				ssStruct.MorphAngleA = 2.0
				ssStruct.PositionID = "DTSIXSM_696_S4"
				ssStruct.PositionOrigID = "Leito_SuperMutant_Chair_Cowgirl_1_S4"
			endIf
		elseIf (seqID == 697)
			if (stageNumber == 1)
				ssStruct.FAnimFormID = 0x0600DE2C							
				ssStruct.MAnimFormID = 0x0500DE30
				ssStruct.ArmorNudeAGun = 0
				ssStruct.PositionID = "DTSIXSM_697_S1"
				ssStruct.PositionOrigID = "Leito_SuperMutant_Chair_ReverseCowgirl_1_S1"
			elseIf (stageNumber == 2)
				ssStruct.FAnimFormID = 0x0600DE2D							
				ssStruct.MAnimFormID = 0x0500DE31
				ssStruct.ArmorNudeAGun = 1						
				ssStruct.MorphAngleA = 0.35
				ssStruct.PositionID = "DTSIXSM_697_S2"
				ssStruct.PositionOrigID = "Leito_SuperMutant_Chair_ReverseCowgirl_1_S2"
			elseIf (stageNumber == 3)
				ssStruct.FAnimFormID = 0x0600DE2E				
				ssStruct.MAnimFormID = 0x0500DE32
				ssStruct.ArmorNudeAGun = 1						
				ssStruct.MorphAngleA = 0.32
				ssStruct.PositionID = "DTSIXSM_697_S3"
				ssStruct.PositionOrigID = "Leito_SuperMutant_Chair_ReverseCowgirl_1_S3"
			elseIf (stageNumber == 4)
				ssStruct.FAnimFormID = 0x0600DE2F				
				ssStruct.MAnimFormID = 0x0500DE33
				ssStruct.ArmorNudeAGun = 1						
				ssStruct.MorphAngleA = 0.3
				ssStruct.PositionID = "DTSIXSM_697_S4"
				ssStruct.PositionOrigID = "Leito_SuperMutant_Chair_ReverseCowgirl_1_S4"
			elseIf (stageNumber == 5)
				ssStruct.FAnimFormID = 0x06007B16				
				ssStruct.MAnimFormID = 0x05007B14
				ssStruct.ArmorNudeAGun = 1						
				ssStruct.MorphAngleA = 0.25
				ssStruct.PositionID = "DTSIXSM_697_S5"
				ssStruct.PositionOrigID = "Leito_SuperMutant_Chair_ReverseCowgirl_1_S5"
			elseIf (stageNumber == 6)
				ssStruct.FAnimFormID = 0x06007B17				
				ssStruct.MAnimFormID = 0x05007B15
				ssStruct.ArmorNudeAGun = 1
				ssStruct.MorphAngleA = 0.24
				ssStruct.PositionID = "DTSIXSM_697_S6"
				ssStruct.PositionOrigID = "Leito_SuperMutant_Chair_ReverseCowgirl_1_S6"
			endIf
		endIf
		
	; Atomic Lust
	elseIf (seqID >= 500 && seqID < 560)
		ssStruct.PluginName = "Atomic Lust.esp"
		ssStruct.StageTime = 32.5
		
		if (seqID == 501)
			ssStruct.FAnimFormID = 0x0201B959
			ssStruct.MAnimFormID = 0x0201B95A
			ssStruct.ArmorNudeAGun = 2
			ssStruct.PositionOrigID = "Atomic Bed Cuddle"
			ssStruct.PositionID = "DTSIX_501_S1"
		elseIf (seqID == 503)
			ssStruct.FAnimFormID = 0x0202B43D
			ssStruct.MAnimFormID = 0x0202B43E
			ssStruct.PositionOrigID = "Atomic Rocket 69 (Gay)"
			ssStruct.PositionID = "DTSIXMM_503_S1"
		elseIf (seqID == 504)
			if (genders == 1)
				ssStruct.FAnimFormID = 0x02018BBB
				ssStruct.MAnimFormID = 0x02018BBC
				ssStruct.PositionOrigID = "Atomic Scissor"
				ssStruct.PositionID = "DTSIXFF_504_S1"
			elseIf (genders == 0)
				ssStruct.FAnimFormID = 0x0204381F
				ssStruct.MAnimFormID = 0x02043820
				ssStruct.PositionOrigID = "Atomic Cowboy"
				ssStruct.PositionID = "DTSIXMM_504_S1"
			endIf
		elseIf (seqID == 505)
			ssStruct.FAnimFormID = 0x0203D530
			ssStruct.MAnimFormID = 0x0203D531
			ssStruct.PositionOrigID = "Atomic Cowgirl (Double Bed)"
			ssStruct.PositionID = "DTSIX_505_S1"
		elseIf (seqID == 506)
			ssStruct.FAnimFormID = 0x0203DCCF
			ssStruct.MAnimFormID = 0x0203DCD0
			ssStruct.PositionOrigID = "Atomic Cowgirl (Vault Bed)"
			ssStruct.PositionID = "DTSIX_506_S1"
		elseIf (seqID == 507)
			ssStruct.FAnimFormID = 0x0204C91D
			ssStruct.MAnimFormID = 0x0204C91E
			ssStruct.ArmorNudeAGun = 1
			ssStruct.PositionOrigID = "Atomic Cowgirl 2"
			ssStruct.PositionID = "DTSIX_507_S1"
		elseIf (seqID == 508)
			ssStruct.FAnimFormID = 0x0204C91F
			ssStruct.MAnimFormID = 0x0204C920
			ssStruct.ArmorNudeAGun = 1
			ssStruct.PositionOrigID = "Atomic Cowgirl 2 Alt 1"
			ssStruct.PositionID = "DTSIX_508_S1"
		elseIf (seqID == 509)
			ssStruct.StageTime = 13.5
			if (stageNumber == 1)
				ssStruct.FAnimFormID = 0x0204C917
				ssStruct.MAnimFormID = 0x0204C918
				ssStruct.ArmorNudeAGun = 1
				ssStruct.PositionOrigID = "Atomic Reversed Cowgirl (Vault Bed)"
				ssStruct.PositionID = "DTSIX_509_S1"
			else
				ssStruct.FAnimFormID = 0x0204C919
				ssStruct.MAnimFormID = 0x0204C91A
				ssStruct.PositionOrigID = "Atomic Reversed Cowgirl (Vault Bed) Orgasm"
				ssStruct.PositionID = "DTSIX_509_S2"
			endIf
		elseIf (seqID == 510)
			ssStruct.StageTime = 13.5
			if (stageNumber == 1)
				ssStruct.FAnimFormID = 0x0204D0BA		; Atomic Spork
				ssStruct.MAnimFormID = 0x0204D0BB
				ssStruct.PositionOrigID = "Atomic Spork"
				ssStruct.PositionID = "DTSIX_510_S1"
			else
				ssStruct.FAnimFormID = 0x0204D0BC		; Atomic Spork II
				ssStruct.MAnimFormID = 0x0204D0BD
				ssStruct.PositionOrigID = "Atomic Spork II"
				ssStruct.PositionID = "DTSIX_510_S2"
			endIf
			ssStruct.ArmorNudeAGun = 1
		elseIf (seqID == 535)						; RaidMyHeart  v2.90
			ssStruct.PluginName = "Raid My Heart.esp"
			ssStruct.ArmorNudeAGun = -1
			if (stageNumber == 1)
				ssStruct.FAnimFormID = 0x02000F99		
				ssStruct.MAnimFormID = 0x02000F9A
				ssStruct.PositionOrigID = "RMH Couch Cuddle S1"
				ssStruct.PositionID = "DTSIX_535_S1"
				ssStruct.StageTime = 6.5
			elseIf (stageNumber == 2)
				ssStruct.FAnimFormID = 0x02000F9B		
				ssStruct.MAnimFormID = 0x02000F9C
				ssStruct.PositionOrigID = "RMH Couch Cuddle S1 - S2"
				ssStruct.PositionID = "DTSIX_535_S2"
				ssStruct.StageTime = 5.0
			elseIf (stageNumber == 3)
				ssStruct.FAnimFormID = 0x02000F9D		
				ssStruct.MAnimFormID = 0x02000F9E
				ssStruct.PositionOrigID = "RMH Couch Cuddle S2"
				ssStruct.PositionID = "DTSIX_535_S3"
				ssStruct.StageTime = 2.0
			;elseIf (stageNumber == 3)
			;	ssStruct.FAnimFormID = 0x02000F9F		
			;	ssStruct.MAnimFormID = 0x02000FA0
			;	ssStruct.PositionOrigID = "RMH Couch Cuddle S2 - S3"
			;	ssStruct.PositionID = "DTSIX_535_S4"
			;	ssStruct.StageTime = 2.0
			else
				ssStruct.FAnimFormID = 0x02000FA1		
				ssStruct.MAnimFormID = 0x02000FA2
				ssStruct.PositionOrigID = "RMH Couch Cuddle S3"
				ssStruct.PositionID = "DTSIX_535_S5"
				ssStruct.StageTime = 11.5
			endIf
			
		elseIf (seqID == 536)						; Atomic PA 2 
			ssStruct.FAnimFormID = 0x0201A288
			ssStruct.MAnimFormID = 0x0201A289
			ssStruct.ArmorNudeAGun = -2				; no male swap
			ssStruct.PositionOrigID = "Atomic Cunnilingus PA"
			ssStruct.PositionID = "DTSIX_536_S1"
		elseIf (seqID == 537)						; Atomic PA (position needs adjusting)
			ssStruct.FAnimFormID = 0x0201B1BE
			ssStruct.MAnimFormID = 0x0201B1BF
			ssStruct.ArmorNudeAGun = -2				; no male swap
			ssStruct.PositionOrigID = "Atomic Cunnilingus Alt PA"
			ssStruct.PositionID = "DTSIX_537_S1"
		elseIf (seqID == 538)						; Atomic Blowjob (Player House Chair)
			ssStruct.FAnimFormID = 0x02043FBA
			ssStruct.MAnimFormID = 0x02043FBB
			ssStruct.PositionOrigID = "Atomic Blowjob (Player House Chair"
			ssStruct.PositionID = "DTSIX_538_S1"
		elseIf (seqID == 540)						; solo
			;if (Utility.RandomInt(1,5) > 3)		; fingering -sit -- uses a pole
			;	ssStruct.FAnimFormID = 0x020428DF	; starts holding pole
			;else
			ssStruct.FAnimFormID = 0x020428E0	; starts seated then use pole
			;endIf
			ssStruct.PositionID = "DTSIXF_540_S1"
			ssStruct.MAnimFormID = 0x020428DC		; jerk
			ssStruct.PositionOrigID = "DTSIXM_540_S1"
			;ssStruct.PositionOrigID = "Atomic Jerking" ;"Atomic Fingering 2 (Sitting)"
		elseIf (seqID == 541)
			ssStruct.FAnimFormID = 0x020428DE
			ssStruct.MAnimFormID = 0x020428DC
			ssStruct.PositionOrigID = "Atomic Fingering (Laying)"
			ssStruct.PositionID = "DTSIXF_541_S1"
		elseIf (seqID == 546)							;Atomic Lust (kiss and jerk)
			if (stageNumber == 1)
				ssStruct.FAnimFormID = 0x02043082
				ssStruct.MAnimFormID = 0x02043083
				ssStruct.StageTime = 5.5
				ssStruct.PositionID = "Standing Idle"
				;ssStruct.PositionID = "DTSIX_546_S1"
			elseIf (stageNumber == 2)
				ssStruct.FAnimFormID = 0x02043084
				ssStruct.MAnimFormID = 0x02043085
				ssStruct.StageTime = 3.6
				ssStruct.PositionID = "Standing Idle to Holding Hands"
				;ssStruct.PositionID = "DTSIX_546_S2"
			elseIf (stageNumber == 3)
				ssStruct.FAnimFormID = 0x0204307A
				ssStruct.MAnimFormID = 0x0204307B
				ssStruct.StageTime = 2.2
				ssStruct.PositionID = "Holding Hands"
				;ssStruct.PositionID = "DTSIX_546_S3"
			elseIf (stageNumber == 4)
				ssStruct.FAnimFormID = 0x0204307E
				ssStruct.MAnimFormID = 0x0204307F
				ssStruct.StageTime = 18.0
				ssStruct.PositionID = "Holding Hands to Holding Jerking"
				;ssStruct.PositionID = "DTSIX_546_S4"
			elseIf (stageNumber == 5)
				ssStruct.FAnimFormID = 0x0204307C
				ssStruct.MAnimFormID = 0x0204307D
				ssStruct.StageTime = 2.5
				ssStruct.PositionID = "Holding Hands to Holding Kissing"
				;ssStruct.PositionID = "DTSIX_546_S5"
			else
				ssStruct.FAnimFormID = 0x02043080
				ssStruct.MAnimFormID = 0x02043081
				ssStruct.StageTime = 7.5
				ssStruct.PositionID = "Holding Kissing"
				;ssStruct.PositionID = "DTSIX_546_S6"
			endIf
		elseIf (seqID == 547)							;Atomic spanking  ; v3.16--adjusted timings and moved spank stage up for repeats
			ssStruct.ArmorNudeAGun = -1
			if (stageNumber == 1)
				ssStruct.FAnimFormID = 0x0201C0F4
				ssStruct.MAnimFormID = 0x0201C0F5
				ssStruct.StageTime = 6.0
				ssStruct.PositionOrigID = "Atomic Spanking S1"
				ssStruct.PositionID = "DTSIX_547_S1"
			elseIf (stageNumber == 2)
				ssStruct.FAnimFormID = 0x0201C88F
				ssStruct.MAnimFormID = 0x0201C890
				ssStruct.StageTime = 2.0
				ssStruct.PositionOrigID = "Atomic Spanking S1 Tran"
				ssStruct.PositionID = "DTSIX_547_S2"
			;elseIf (stageNumber == 3)
			;	ssStruct.FAnimFormID = 0x0201D7C5
			;	ssStruct.MAnimFormID = 0x0201D02B
			;	ssStruct.StageTime = 3.0
			;	ssStruct.PositionOrigID = "Atomic Spanking S2"
			;	ssStruct.PositionID = "DTSIX_547_S3"
			;elseIf (stageNumber == 4)
			;	ssStruct.FAnimFormID = 0x0201DF5F
			;	ssStruct.MAnimFormID = 0x0201DF60
			;	ssStruct.StageTime = 1.0
			;	ssStruct.PositionOrigID = "Atomic Spanking S2 Tran"
			;	ssStruct.PositionID = "DTSIX_547_S4"
				
			elseIf (stageNumber == 5 || stageNumber == 3)
				ssStruct.FAnimFormID = 0x0201EE93
				ssStruct.MAnimFormID = 0x0201EE94				
				ssStruct.StageTime = 2.5
				ssStruct.PositionOrigID = "Atomic Spanking S3"
				ssStruct.PositionID = "DTSIX_547_S5"
			else	
				ssStruct.FAnimFormID = 0x0201F62E				
				ssStruct.MAnimFormID = 0x0201F62F				
				ssStruct.StageTime = 2.5
				ssStruct.PositionOrigID = "Atomic Spanking S3 Spank"
				ssStruct.PositionID = "DTSIX_547_S6"
				
			endIf
		elseIf (seqID == 550)						; Atomic Blow Job - AL2.7, v2.86
			ssStruct.FAnimFormID = 0x0204E055
			ssStruct.MAnimFormID = 0x0204E056
			ssStruct.PositionOrigID = "Atomic Blowjob"
			ssStruct.PositionID = "DTSIX_550_S1"
		
		elseIf (seqID == 551)						; Atomic Threesome FMM Handjob
			ssStruct.FAnimFormID = 0x02005BAE
			ssStruct.MAnimFormID = 0x02005BAF
			ssStruct.OAnimFormID = 0x02005BB0
			ssStruct.ArmorNudeAGun = 0
			ssStruct.ArmorNudeBGun = 0
			ssStruct.PositionOrigID = "Atomic Threesome Handjob"
			ssStruct.PositionID = "DTSIXFMM_551_S1"
		elseIf (seqID == 552)						; Atomic Threesome 2 FMF
			ssStruct.FAnimFormID = 0x02043FBC
			ssStruct.MAnimFormID = 0x02043FBE
			ssStruct.OAnimFormID = 0x02043FBD		; female other on top
			ssStruct.PositionOrigID = "Atomic Threesome 2"
			ssStruct.PositionID = "DTSIXFMF_552_S1"
		;elseIf (seqID == 553)									; added AL2.7, v2.86
		;	ssStruct.FAnimFormID = 0x0204E7F0
		;	ssStruct.MAnimFormID = 0x0204E7F1
		;	ssStruct.PositionOrigID = "Atomic Flying-V (Player House Kitchen Table)"
		;	ssStruct.PositionID = "DTSIX_553_S1"
		endIf
	elseIf (seqID >= 560 && seqID < 590)
		ssStruct.PluginName = "Mutated Lust.esp"
		ssStruct.StageTime = 30.0
		if (seqID == 560)							; mini-nuke, poor alignment
			ssStruct.FAnimFormID = 0x0100AF46
			ssStruct.MAnimFormID = 0x0100AF47
			ssStruct.PositionOrigID = "Supermutant Forced Missionary"
			ssStruct.PositionID = "DTSIXSM_560_S1"
		elseIf (seqID == 562)
			ssStruct.FAnimFormID = 0x01000F9B
			ssStruct.MAnimFormID = 0x01000F9C
			ssStruct.ArmorNudeAGun = 2
			ssStruct.MorphAngleA = 0.06								; down slightly from forward v2.73
			ssStruct.PositionOrigID = "Supermutant Blowjob"
			ssStruct.PositionID = "DTSIXSM_562_S1"
		elseIf (seqID == 563)	
			ssStruct.FAnimFormID = 0x01004C70
			ssStruct.MAnimFormID = 0x01004C71
			ssStruct.ArmorNudeAGun = 1
			ssStruct.MorphAngleA = 0.96								; down slightly from up v2.73
			ssStruct.PositionOrigID = "Supermutant Penis Lick"
			ssStruct.PositionID = "DTSIXSM_563_S1"
		elseIf (seqID == 564)	
			ssStruct.FAnimFormID = 0x0100BE7D						; v2.88
			ssStruct.MAnimFormID = 0x0100BE7E
			ssStruct.ArmorNudeAGun = 2
			ssStruct.MorphAngleA = 0.48							;
			ssStruct.PositionOrigID = "MutatedSMCowgirl"
			ssStruct.PositionID = "DTSIXSM_564_S1"
		elseIf (seqID == 565)	
			ssStruct.FAnimFormID = 0x0100C618						; v2.88
			ssStruct.MAnimFormID = 0x0100C619
			ssStruct.ArmorNudeAGun = 1
			ssStruct.MorphAngleA = 0.20							;
			ssStruct.PositionOrigID = "MutatedSMJerking"
			ssStruct.PositionID = "DTSIXSM_565_S1"
		endIf
	elseIf (seqID >= 590 && seqID < 600)
		ssStruct.PluginName = "Rufgt's Animations.esp"
		ssStruct.StageTime = 30.0
		if (seqID == 590)											
			ssStruct.FAnimFormID = 0x01001732
			ssStruct.MAnimFormID = 0x01001ECC
			ssStruct.PositionOrigID = "Rocket 69"
			ssStruct.PositionID = "DTSIXFF_590_S1"
		elseIf (seqID == 591)
			ssStruct.FAnimFormID = 0x01003D35
			ssStruct.MAnimFormID = 0x01003D36
			ssStruct.PositionOrigID = "The Scissor"
			ssStruct.PositionID = "DTSIXFF_591_S1"
		elseIf (seqID == 592)	
			ssStruct.FAnimFormID = 0x01007A0D
			ssStruct.MAnimFormID = 0x01007A0E
			ssStruct.PositionOrigID = "Cunnilingus"
			ssStruct.PositionID = "DTSIXFF_592_S1"
		elseIf (seqID == 599)	
			ssStruct.FAnimFormID = 0x01008943
			ssStruct.MAnimFormID = 0x01008942
			ssStruct.ArmorNudeAGun = 1
			ssStruct.PositionOrigID = "Spooning"
			ssStruct.PositionID = "DTSIX_599_S1"
		endIf
		
	; CHAKpack
	elseIf (seqID >= 400 && seqID < 500)						;  v3.0
		ssStruct.PluginName = "AVilas_CHAKPack.esp"
		ssStruct.ArmorNudeAGun = -1
		ssStruct.StageTime = 20.0
		
		if (seqID >= 490)
			if (seqID == 497)									; hug02
				ssStruct.FAnimFormID = 0x01001ECE
				ssStruct.MAnimFormID = 0x01001ECF
			elseIf (seqID == 496)									; cuddle01
				ssStruct.FAnimFormID = 0x01002E04
				ssStruct.MAnimFormID = 0x01002E05
			elseIf (seqID == 494)									; slowDance02 plus dip
				if (stageNumber == 1)
					ssStruct.StageTime = 17.5
					ssStruct.FAnimFormID = 0x0100912F
					ssStruct.MAnimFormID = 0x0100912E
				else
					ssStruct.StageTime = 3.0						; dip
					ssStruct.FAnimFormID = 0x01009130
					ssStruct.MAnimFormID = 0x01009131
				endIf
			endIf
		elseIf (seqID < 450)
			if (seqID == 400)										; single bed cuddle
				ssStruct.FAnimFormID = 0x01006AE0
				ssStruct.MAnimFormID = 0x01006AE1
			elseIf (seqID == 401)									; double-bed cuddle01
				ssStruct.StageTime = 11.0
				if (stageNumber == 1)
					ssStruct.FAnimFormID = 0x0100911B
					ssStruct.MAnimFormID = 0x0100911C
				elseIf (stageNumber == 2)
					ssStruct.FAnimFormID = 0x0100911F
					ssStruct.MAnimFormID = 0x0100911D
				else
					ssStruct.FAnimFormID = 0x01009120
					ssStruct.MAnimFormID = 0x0100911E
				endIf
			elseIf (seqID == 402)									; double-bed kiss
				ssStruct.FAnimFormID = 0x01009123
				ssStruct.MAnimFormID = 0x01009124
			endIf
		elseIf (seqID >= 450 && seqID < 490)
			if (seqID == 450)										; couch cuddle A 
				ssStruct.StageTime = 16.0
				if (stageNumber == 1)
					ssStruct.FAnimFormID = 0x01005410
					ssStruct.MAnimFormID = 0x01005411
				else
					ssStruct.FAnimFormID = 0x01007A17	; kiss
					ssStruct.MAnimFormID = 0x01007A16
				endIf
			elseIf (seqID == 451)									; couch cuddle B 
				ssStruct.StageTime = 16.0
				if (stageNumber == 1)
					ssStruct.FAnimFormID = 0x0100727B
					ssStruct.MAnimFormID = 0x0100727C
				else
					ssStruct.FAnimFormID = 0x010090ED
					ssStruct.MAnimFormID = 0x010090EC
				endIf
			elseIf (seqID == 452)									; couch romance
				ssStruct.StageTime = 11.0
				if (stageNumber == 1)
					ssStruct.FAnimFormID = 0x0100910D
					ssStruct.MAnimFormID = 0x0100910E
				elseIf (stageNumber == 2)
					ssStruct.FAnimFormID = 0x01009111
					ssStruct.MAnimFormID = 0x0100910F
				else
					ssStruct.FAnimFormID = 0x01009112
					ssStruct.MAnimFormID = 0x01009110
				endIf
			elseIf (seqID == 460)									; stool kiss
				ssStruct.StageTime = 16.0
				if (stageNumber == 1)
					ssStruct.FAnimFormID = 0x01009107
					ssStruct.MAnimFormID = 0x01009108
				else
					ssStruct.FAnimFormID = 0x0100910A
					ssStruct.MAnimFormID = 0x01009109
				endIf
			elseIf (seqID == 470)									; table (sits on edge)
				ssStruct.StageTime = 11.0
				if (stageNumber == 1)
					ssStruct.FAnimFormID = 0x01009103
					ssStruct.MAnimFormID = 0x01009104
				elseIf (stageNumber == 2)
					ssStruct.FAnimFormID = 0x01009105
					ssStruct.MAnimFormID = 0x01009106
				else
					ssStruct.FAnimFormID = 0x0100910C
					ssStruct.MAnimFormID = 0x0100910B
				endIf
			endIf
		endIf
	endIf
	
	return ssStruct

endFunction




