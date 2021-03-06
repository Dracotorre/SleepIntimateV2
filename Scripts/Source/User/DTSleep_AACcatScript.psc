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
; Atomic Lust (500s) - 11 scenes
; SavageCabbage_Animations (700s) - 42 scenes
; ZaZOut4 (800s) - 4 scenes (2 broken into shorter scenes)
; Gray (900s)
;

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
EndStruct

; ***************** Functions ************************** ;

DTAACSceneStageStruct[] Function GetSeqCatArrayForSequenceID(int seqID, int longScene = 0, int genders = -1, int other = 0, bool scEVB = true) global

	DTAACSceneStageStruct[] result = new DTAACSceneStageStruct[0]
	int stageTotal = 1
	int count = 0
	
	if (other > 0 && seqID >= 701 && seqID <= 702)
		; force short scene
		stageTotal = GetStageCountForSequenceID(seqID, -2)
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
	
	if (seqID >= 500 && seqID < 600)
		result = 1
		if (seqID >= 509 && seqID <= 511)
			result = 2
		elseIf (seqID >= 546 && seqID <= 547)
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
		elseIf (seqID == 796)
			if (longScene)
				return 6
			endIf
			return 4
		elseIf (seqID == 784 || seqID == 787)
			return 1
		elseIf (seqID >= 780 && seqID <= 781)
			if (longScene > 0)
				return 2
			endIf
			return 1
		elseIf (seqID == 792)
			return 2
		elseIf (seqID == 785)
			if (longScene <= 0)
				return 2
			endIf
			return 4
			
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
				result = 1
			elseIf (longScene >= 1)
				result = 6
			endIf
		elseIf (seqID == 760 && longScene > 0)
			result = 6
		elseIf (seqID == 759)
			result = 6
		elseIf (seqID >= 754 && seqID <= 755)
			result = 1
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
		elseIf (seqID == 732)
			result = 2
		elseIf (seqID >= 713 && seqID <= 715)
			if (longScene == 1)
				result = 2
			elseIf (longScene >= 2)
				result = 3
			else
				result = 1
			endIf								
		elseIf (seqID >= 710 && seqID <= 712)	; v2.53 fix include 712
			result = 6
		
		elseIf (seqID == 707)
			if (other > 0 && longScene > 0)
				result = 2
			else
				result = 1
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
		elseIf (seqID >= 701 && seqID <= 703)
			result = 6
		
		elseIf (seqID >= 770 && seqID <= 773)
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
	
	if (seqID >= 960 && seqID < 1000)
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
				if (stageNumber == 1)						;SIX_SC_FM-DoubleBed02-01Tease
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
				if (stageNumber == 1)						;SIX_SC_FM-DoubleBed03-01Tease
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
					ssStruct.MAnimFormID = 0x050082CB
					ssStruct.PositionID = "DTSIXMM_713_S1"
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
				elseIf (stageNumber == 2 || stageNumber == 4)
					ssStruct.FAnimFormID = 0x05010C3C
					ssStruct.OAnimFormID = 0x05010C3E			; v2.49 swapped male roles so primary on bottom
					ssStruct.MAnimFormID = 0x05010C3D
					ssStruct.PositionID = "DTSIXFMM_715_S1"
				else
					ssStruct.FAnimFormID = 0x0502FD9E			; v2.49, SC 1.2.4
					ssStruct.MAnimFormID = 0x0502FD9F			; note order for male assignment to prevent sudden switch places
					ssStruct.OAnimFormID = 0x0502FDA0
					ssStruct.PositionID = "DTSIXFMM_715_S2"		
				endIf
				if (scEVB)
					ssStruct.ArmorNudeAGun = 1
					ssStruct.ArmorNudeBGun = 1
				else
					ssStruct.ArmorNudeBGun = 0
				endIf
				if (longScene > 0 || stageNumber > 1)
					if (longScene >= 2)
						ssStruct.StageTime = 10.67
					else
						ssStruct.StageTime = 16.0
					endIf
				else
					ssStruct.StageTime = 32.0
				endIf
				ssStruct.PositionOrigID = "FMM-BunkBed01-03Threesome"
				
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
				if (stageNumber == 1 || (longScene <= 0 && stageNumber == 3))
					ssStruct.FAnimFormID = 0x0500101A
					ssStruct.MAnimFormID = 0x0500101B
					ssStruct.PositionID = "DTSIX_733_S1"
					ssStruct.PositionOrigID = "FM-Throne01-03Handjob"
				elseIf (stageNumber == 2 || (longScene <= 0 && stageNumber == 4))
					ssStruct.FAnimFormID = 0x0500E62E
					ssStruct.MAnimFormID = 0x0500E62F
					ssStruct.PositionID = "DTSIX_733_S2"
					ssStruct.PositionOrigID = "FM-Throne01-04Handjob"
				elseIf (stageNumber == 3)

					ssStruct.FAnimFormID = 0x05027335
					ssStruct.MAnimFormID = 0x05027336
					ssStruct.PositionID = "DTSIX_733_S3"
					ssStruct.PositionOrigID = "SIX_SC_FM-Throne01-05Blowjob"
				elseIf (stageNumber == 4)
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
					if (stageNumber == 2)
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
						ssStruct.FAnimFormID = 0x05002763
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
			elseIf (seqID == 739)
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
				elseIf (stageNumber == 4 || stageNumber == 6)							; v2.53 -- skip climax
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
				endIf
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
				if (stageNumber == 2)	
					ssStruct.FAnimFormID = 0x0500D67A
					ssStruct.MAnimFormID = 0x0500D67B
					ssStruct.PositionID = "DTSIX_753_S2"
					ssStruct.PositionOrigID = "FM-Stool01-04Doggy"
				elseIf (stageNumber == 3)
					ssStruct.FAnimFormID = 0x05006C14
					ssStruct.MAnimFormID = 0x05006C15
					ssStruct.PositionID = "DTSIX_753_S3"
					ssStruct.PositionOrigID = "FM-Stool01-05Doggy"
				else
					ssStruct.FAnimFormID = 0x05002761	; 1,4
					ssStruct.MAnimFormID = 0x05002762
					ssStruct.PositionID = "DTSIX_753_S1"
					ssStruct.PositionOrigID = "FM-Stool01-03Doggy"
				endIf
			elseIf (seqID == 754)	
				ssStruct.FAnimFormID = 0x05001000	
				ssStruct.MAnimFormID = 0x05001001
				ssStruct.StageTime = 32.0
				if (scEVB)
					ssStruct.ArmorNudeAGun = 1
				endIf
				ssStruct.PositionID = "DTSIX_754_S1"
				ssStruct.PositionOrigID = "FM-ChairHigh01-03Doggy"
			elseIf (seqID == 755)	
				ssStruct.FAnimFormID = 0x05001002	
				ssStruct.MAnimFormID = 0x05001003
				ssStruct.StageTime = 32.0
				ssStruct.PositionID = "DTSIX_755_S1"
				ssStruct.PositionOrigID = "FM-ChairLow01-02Doggy"
				
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
					else
						ssStruct.FAnimFormID = 0x0500104C	; second and last
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
					ssStruct.PositionOrigID = "FM-Bench01-01Tease"
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
					ssStruct.StageTime = 31.0
					ssStruct.FAnimFormID = 0x050104A0
					ssStruct.MAnimFormID = 0x050104A1
					ssStruct.OAnimFormID = 0x050104A2
					ssStruct.ArmorNudeBGun = 0
					if (scEVB)
						ssStruct.ArmorNudeBGun = 1
					endIf
					ssStruct.PositionID = "DTSIXSMSM_761_S1"
					ssStruct.PositionOrigID = "FSMSM-Standing01-03DoubleTeam"
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
					ssStruct.PositionID = "DTSIXSM_763_S4"
					ssStruct.PositionOrigID = "FSM-Floor01-05Wheelbarrow"
				elseIf (sNum == 5)
					ssStruct.FAnimFormID = 0x05014944
					ssStruct.MAnimFormID = 0x05014945
					ssStruct.ArmorNudeAGun = 0
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
					ssStruct.StageTime = 14.0
					ssStruct.PositionID = "DTSIXSM_766_S2"
					ssStruct.PositionOrigID = "SC-FM-SuperMutant-DoubleBed03-02Start"
				elseIf (stageNumber == 3)
					ssStruct.FAnimFormID = 0x0500E626
					ssStruct.MAnimFormID = 0x0500E627
					ssStruct.StageTime = 13.0
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
						ssStruct.PositionID = "DTSIXSM_768_S1"
						ssStruct.PositionOrigID = "SC-FM-SuperMutant-SMBed02-01Tease"
					elseIf (sNum == 2)
						ssStruct.FAnimFormID = 0x0500C7A2
						ssStruct.MAnimFormID = 0x0500C7A3
						ssStruct.ArmorNudeAGun = 1
						ssStruct.PositionID = "DTSIXSM_768_S2"
						ssStruct.PositionOrigID = "FSM-SMBed02-03Doggy"
					elseIf (sNum == 3)
						ssStruct.FAnimFormID = 0x050139F9
						ssStruct.MAnimFormID = 0x050139FA
						ssStruct.PositionID = "DTSIXSM_768_S3"
						ssStruct.PositionOrigID = "FSM-SMBed02-04Doggy"
					elseIf (sNum == 4)
						ssStruct.FAnimFormID = 0x050139FB
						ssStruct.MAnimFormID = 0x050139FC
						ssStruct.PositionID = "DTSIXSM_768_S4"
						ssStruct.PositionOrigID = "FSM-SMBed02-05Doggy"
					elseIf (sNum >= 5)
						ssStruct.FAnimFormID = 0x050139FD
						ssStruct.MAnimFormID = 0x050139FE
						ssStruct.ArmorNudeAGun = 2
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
					if (longScene > 0)
						ssStruct.StageTime = 13.0
					else
						ssStruct.StageTime = 25.0
					endIf
					ssStruct.PositionID = "DTSIX_781_S1"
					ssStruct.PositionOrigID = "SC-FM-Human-Couch_PlayerHouse01-03Facefuck"
				else
					ssStruct.FAnimFormID = 0x0502FD89				; v2.49, SC 1.2.4
					ssStruct.MAnimFormID = 0x0502FD8A
					ssStruct.StageTime = 12.0
					ssStruct.PositionID = "DTSIX_781_S2"			; not in AAF
					ssStruct.PositionOrigID = "SC-FM-Human-Couch_PlayerHouse01-04Facefuck"
				endIf
				
			elseIf (seqID == 784)
				ssStruct.FAnimFormID = 0x0502C012					; hanging from crane
				ssStruct.MAnimFormID = 0x0502C013
				ssStruct.StageTime = 31.0
				ssStruct.PositionID = "DTSIX_784_S1"
				ssStruct.PositionOrigID = "SC-FM-Human-Crane01-03Carry"
				
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
			elseIf (seqID == 787)
				ssStruct.FAnimFormID = 0x0502C022
				ssStruct.MAnimFormID = 0x0502C023
				ssStruct.StageTime = 31.0
				ssStruct.PositionID = "DTSIX_787_S1"
				ssStruct.PositionOrigID = "SC-FM-Human-Throne02-03ReverseCowgirl"
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
			elseIf (stageNumber == 4 || stageNumber == 6)
				ssStruct.FAnimFormID = 0x0502B0B9	
				ssStruct.MAnimFormID = 0x0502B0BA
				ssStruct.PositionID = "DTSIX_796_S3"
				ssStruct.PositionOrigID = "SC-FM-Human-JailCellSmall01-05Carry"
			else
				ssStruct.FAnimFormID = 0x0502B0BB	
				ssStruct.MAnimFormID = 0x0502B0BC
				ssStruct.PositionID = "DTSIX_796_S4"
				ssStruct.PositionOrigID = "SC-FM-Human-JailCellSmall01-06Carry"
			endIf
			
		;  ---------------- solo -------------------
		elseIf (seqID == 797)
			ssStruct.FAnimFormID = 0x050099DE
			ssStruct.MAnimFormID = 0x0500CF44
			ssStruct.StageTime = 32.0
			ssStruct.PositionID = "DTSIXF_797_S1"
			ssStruct.PositionOrigID = "DTSIXM_797_S1"
		elseIf (seqID == 798)
			ssStruct.FAnimFormID = 0x05000FD3
			ssStruct.MAnimFormID = 0x05000FD4
			ssStruct.StageTime = 32.0
			ssStruct.PositionID = "DTSIXF_798_S1"
			ssStruct.PositionOrigID = "DTSIXM_798_S1"
			
		elseIf (seqID == 799)
			ssStruct.FAnimFormID = 0x0500CF43
			ssStruct.MAnimFormID = 0x0500CF44
			ssStruct.StageTime = 32.0
			ssStruct.PositionID = "DTSIXF_799_S1"
			ssStruct.PositionOrigID = "DTSIXM_799_S1"
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
		elseIf (seqID == 547)							;Atomic spanking
			ssStruct.ArmorNudeAGun = -1
			if (stageNumber == 1)
				ssStruct.FAnimFormID = 0x0201C0F4
				ssStruct.MAnimFormID = 0x0201C0F5
				ssStruct.StageTime = 9.5
				ssStruct.PositionOrigID = "Atomic Spanking S1"
				ssStruct.PositionID = "DTSIX_547_S1"
			elseIf (stageNumber == 2)
				ssStruct.FAnimFormID = 0x0201C88F
				ssStruct.MAnimFormID = 0x0201C890
				ssStruct.StageTime = 3.0
				ssStruct.PositionOrigID = "Atomic Spanking S1 Tran"
				ssStruct.PositionID = "DTSIX_547_S2"
			elseIf (stageNumber == 3)
				ssStruct.FAnimFormID = 0x0201D7C5
				ssStruct.MAnimFormID = 0x0201D02B
				ssStruct.StageTime = 11.5
				ssStruct.PositionOrigID = "Atomic Spanking S2"
				ssStruct.PositionID = "DTSIX_547_S3"
			elseIf (stageNumber == 4)
				ssStruct.FAnimFormID = 0x0201DF5F
				ssStruct.MAnimFormID = 0x0201DF60
				ssStruct.StageTime = 3.0
				ssStruct.PositionOrigID = "Atomic Spanking S2 Tran"
				ssStruct.PositionID = "DTSIX_547_S4"
			elseIf (stageNumber == 5)
				ssStruct.FAnimFormID = 0x0201EE93
				ssStruct.MAnimFormID = 0x0201EE94
				ssStruct.StageTime = 10.5
				ssStruct.PositionOrigID = "Atomic Spanking S3"
				ssStruct.PositionID = "DTSIX_547_S5"
			else
				ssStruct.FAnimFormID = 0x0201F62E
				ssStruct.MAnimFormID = 0x0201F62F
				ssStruct.StageTime = 6.5
				ssStruct.PositionOrigID = "Atomic Spanking S3 Spank"
				ssStruct.PositionID = "DTSIX_547_S6"
			endIf
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
			ssStruct.PositionOrigID = "Supermutant Blowjob"
			ssStruct.PositionID = "DTSIXSM_562_S1"
		elseIf (seqID == 563)	
			ssStruct.FAnimFormID = 0x01004C70
			ssStruct.MAnimFormID = 0x01004C71
			ssStruct.ArmorNudeAGun = 1
			ssStruct.PositionOrigID = "Supermutant Penis Lick"
			ssStruct.PositionID = "DTSIXSM_563_S1"
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
	endIf
	
	return ssStruct

endFunction




