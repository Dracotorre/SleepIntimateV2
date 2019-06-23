Scriptname DTSleep_MainQSceneScript extends Quest

; Sleep Intimate - Scene Camera
; DracoTorre
;
; part of MainQuest
;
; no required Camera section changes in Fallout4Custom.ini
; will set bApplyCameraNodeAnimations
;
Actor property PlayerRef auto const Mandatory
GlobalVariable property DTSleep_WasPlayerThirdPerson auto
{ keep track if player was in 3rd or 1st person view }
GlobalVariable property DTSL_CamCustomEnabled auto const
GlobalVariable property DTSleep_SettingCamera auto const

GlobalVariable property DTSL_CamCus_MinCurZoom auto const
{ custom camera ini fMinCurrentZoom }
GlobalVariable property DTSL_CamCus_OverShoulderX auto const
{ custom camera ini fOverShoulderPosX }
GlobalVariable property DTSL_CamCus_OverShoulderZ auto const
{ custom camera ini fOverShoulderPosZ }
GlobalVariable property DTSL_CamCus_VanModeMax auto const
{ custom camera ini fVanityModeMaxDist }
GlobalVariable property DTSL_CamCus_VanModeMin auto const
{ custom camera ini fVanityModeMinDist }
GlobalVariable property DTSL_CamDef_MinCurZoom auto const
{ default camera ini fMinCurrentZoom = 0.0 }
GlobalVariable property DTSL_CamDef_OverShoulderX auto const
{ default camera ini fOverShoulderPosX = 0.0 }
GlobalVariable property DTSL_CamDef_OverShoulderZ auto const
{ default camera ini fOverShoulderPosZ = 0.0 }
GlobalVariable property DTSL_CamDef_VanModeMax auto const
{ default camera ini fVanityModeMaxDist = 200.0}
GlobalVariable property DTSL_CamDef_VanModeMin auto const
{ default camera ini fVanityModeMinDist = 32.0 }

bool property ReverseCamXOffset auto hidden
bool property IsMaleCamOffset auto hidden
float property CamHeightOffset auto hidden

Function GoSceneViewCamCustom(int lowCam = 1)
	if (lowCam >= 0 && DTSL_CamCustomEnabled.GetValue() > 0.0 && DTSleep_SettingCamera.GetValue() > 0.0)
	; Utility.SetINIBool("bForceAutoVanityMode:Camera", false)
	; Utility.SetINIFloat("fVanityModeMaxDist:Camera", 320.0)
	; Utility.SetINIFloat("fVanityModeMinDist:Camera", 64.0)
	; Utility.SetINIFloat("fOverShoulderPosZ:Camera", -76.0)
	; Utility.SetINIFloat("fOverShoulderPosX:Camera", 5.0)
	; Utility.SetINIFloat("fFurnitureCameraAngle:Camera", 2.8)
	; ; --Utility.SetINIFloat("fFurnitureCameraZoom:Camera", 300.0000)
	; Utility.SetINIFloat("fMinCurrentZoom:Camera", 0.3)
		Utility.SetINIBool("bApplyCameraNodeAnimations:Camera", false)
		Utility.SetINIFloat("fVanityModeMaxDist:Camera", DTSL_CamCus_VanModeMax.GetValue())
		Utility.SetINIFloat("fVanityModeMinDist:Camera", DTSL_CamCus_VanModeMin.GetValue())
		
		if (lowCam >= 1)
			float camZ = DTSL_CamCus_OverShoulderZ.GetValue() + CamHeightOffset
			if (lowCam >= 2)
				camZ -= 12.0
			endIf
			Utility.SetINIFloat("fOverShoulderPosZ:Camera", camZ)
			
		elseIf (CamHeightOffset != 0.0)
			; offset of default cam
			Utility.SetINIFloat("fOverShoulderPosZ:Camera", DTSL_CamDef_OverShoulderZ.GetValue() + CamHeightOffset)
		endIf
		
		float overX = DTSL_CamCus_OverShoulderX.GetValue()
		if (IsMaleCamOffset)
			overX += 25.0
		endIf
		if (overX != 0.0 && ReverseCamXOffset)
			overX = -1 * overX - 2.0
		endIf
		Utility.SetINIFloat("fOverShoulderPosX:Camera", overX)
		;Utility.SetINIFloat("fFurnitureCameraAngle:Camera", 0.3927)
		Utility.SetINIFloat("fMinCurrentZoom:Camera", DTSL_CamCus_MinCurZoom.GetValue())
		Utility.Wait(0.08)
	endIf
endFunction

Function GoSceneViewCamDefault()
	if (DTSL_CamCustomEnabled.GetValue() > 0.0 && DTSleep_SettingCamera.GetValue() > 0.0)
		Utility.SetINIBool("bApplyCameraNodeAnimations:Camera", true)
		; Utility.SetINIFloat("fVanityModeMaxDist:Camera", 200.0)
		; Utility.SetINIFloat("fVanityModeMinDist:Camera", 32.0)
		; Utility.SetINIFloat("fOverShoulderPosZ:Camera", 0.0)
		; Utility.SetINIFloat("fOverShoulderPosX:Camera", 0.0)
		; Utility.SetINIFloat("fFurnitureCameraAngle:Camera", 0.3927)
		; Utility.SetINIFloat("fMinCurrentZoom:Camera", 0.0)
		Utility.SetINIFloat("fVanityModeMaxDist:Camera", DTSL_CamDef_VanModeMax.GetValue())
		Utility.SetINIFloat("fVanityModeMinDist:Camera", DTSL_CamDef_VanModeMin.GetValue())
		Utility.SetINIFloat("fOverShoulderPosZ:Camera", DTSL_CamDef_OverShoulderZ.GetValue())
		Utility.SetINIFloat("fOverShoulderPosX:Camera", DTSL_CamDef_OverShoulderX.GetValue())
		;Utility.SetINIFloat("fFurnitureCameraAngle:Camera", 0.3927)
		Utility.SetINIFloat("fMinCurrentZoom:Camera", DTSL_CamDef_MinCurZoom.GetValue())
		Utility.Wait(0.08)
	endIf
endFunction

Function GoSceneViewDone(bool goFirstOK)
	;if (!PlayerRef.GetAnimationVariableBool("IsFirstPerson"))
		if (goFirstOK && DTSleep_WasPlayerThirdPerson.GetValue() < 0.0)
		
			;Debug.Trace("[DTSLeep_SceneScr] ViewDone force first person")
			Game.ForceFirstPerson()
			PlayerRef.SetAnimationVariableBool("IsFirstPerson", true)
		endIf
	;endIf
	GoSceneViewCamDefault()
	
endFunction

Function GoSceneViewStart(int useLowCam = 1)

	; this AnimationVariable sometimes misreports so always force ThirdPerson
	if (PlayerRef.GetAnimationVariableBool("IsFirstPerson"))
		;Debug.Trace("[DTSLeep_SceneScr] ViewStart set first-person")
		DTSleep_WasPlayerThirdPerson.SetValue(-1.0)
		Game.ForceFirstPerson()  ; toggle anyway - sometimes reports wrong
		Utility.Wait(0.33)
	else
		;Debug.Trace("[DTSLeep_SceneScr] ViewStart set was third-person")
		DTSleep_WasPlayerThirdPerson.SetValue(1.0)
		Game.ForceFirstPerson()  ; toggle before setting custom cam
		Utility.Wait(0.67)
	endIf
	
	GoSceneViewCamCustom(useLowCam)  ; set custom cam before going third-person
	Utility.Wait(0.06)
	Game.ForceThirdPerson()

endFunction