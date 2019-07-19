ScriptName DTSleep_CommonF Hidden

; *****************  Structs **************
Struct Point3DOrient
   float X = 0.0
   float Y = 0.0
   float Z = 0.0
   float Heading = 0.0
   {Z angle}
 EndStruct 

 
; ************* bed gets *******

float Function GetHalfBedWidth() global
	return 40.0
EndFunction

float Function GetHalfBedLength() global
	return 92.0
EndFunction

float Function GetBedHeight() global
	return 45.4    ; 45 for standard bed 
EndFunction

float Function GetLowBedHeight() global
	return 11.2
EndFunction
 
; *************** Functions ************

Form[] Function CopyFormArray(Form[] formArray) global

	Form[] resultArray = new Form[0]
	
	int index = 0
	
	while (index < formArray.Length)
	
		Form item = formArray[index]
		
		if (item != None)
			resultArray.Add(item)
		endIf
		
		index += 1
	endWhile
	
	return resultArray

endFunction

; after spawning item use this to remove it
; based on Chesko's Campfire object placement removal - shared on GitHub under MIT license
bool Function DisableAndDeleteObjectRef(ObjectReference objRef, bool fadeOut, bool fast = false) global
	int cnt  = 24
	if (fast)
		cnt = 10
	endIf
	
	while (cnt > 0)
		if (objRef && objRef.IsEnabled())
			objRef.Disable(fadeOut)
			objRef.Delete()
			Utility.Wait(0.10)
		else
			cnt = -2
		endIf
		
		cnt -= 1
	endWhile
	
	if (objRef && objRef.IsEnabled())
		return false
	endIf
	
	return true
EndFunction

int Function DistanceBetweenAngles(float alpha, float beta) global

	int phi = (Math.Abs(beta as int - alpha as int)) as int % 360
	if (phi > 180)
		return 360 - phi
	endIf
	return phi
	
endFunction

float Function DistanceBetweenPoints(Point3DOrient ptA, Point3DOrient ptB, bool ignoreZ = false) global
	if (ptA && ptB && ptA != ptB)
		float xDif = ptB.X - ptA.X
		float yDif = ptB.Y - ptA.Y
		
		if (ignoreZ || ptB.Z == ptA.Z)
			return Math.sqrt((xDif * xDif) + (yDif * yDif))
		endIf
		float zDif = ptB.Z - ptA.Z
		return Math.sqrt((xDif * xDif) + (yDif * yDif) + (zDif * zDif))
	endIf
	return 0.0
EndFunction

float Function DistanceBetweenObjects(ObjectReference objA, ObjectReference objB, bool ignoreZ = false) global

	Point3DOrient ptA = PointOfObject(objA)
	Point3DOrient ptB = PointOfObject(objB)
	
	return DistanceBetweenPoints(ptA, ptB, ignoreZ)
endFunction

float Function DistanceHeightBetweenObjects(ObjectReference objA, ObjectReference objB) global

	Point3DOrient ptA = PointOfObject(objA)
	Point3DOrient ptB = PointOfObject(objB)
	
	float zDif = ptA.Z - ptB.Z
	
	return Math.Abs(zDif)
endFunction

ObjectReference Function FindNearestAnyBedFromObject(ObjectReference fromObj, FormList bedList, ObjectReference notBedRef, float distance = 400.0, bool sameLevel = false) global
	;return FindNearestOpenBedFromObject(fromObj, bedList, notBedRef, distance, None, None)
	ObjectReference result = None
	int closestIDX = -1
	int bedMatchCount = 0
	float closestDist = 10000.0
	ObjectReference[] nearBedArr = fromObj.FindAllReferencesOfType(bedList, distance)
	
	if (nearBedArr)
		int index = 0
		while (index < nearBedArr.Length)
			ObjectReference aBedRef = nearBedArr[index]
			if (aBedRef != None && aBedRef != notBedRef && aBedRef.IsEnabled())
				float dist = DistanceBetweenObjects(aBedRef, fromObj)
				
				if (dist < closestDist)
					if (sameLevel && notBedRef != None)
						float nearZ = aBedRef.GetPositionZ()
						float notBedZ = notBedRef.GetPositionZ()
						if (nearZ - 5.0 < notBedZ && nearZ + 5.0 > notBedZ)
							; same level okay to consider
							closestDist = dist
							closestIDX = index
						endIf
					else
						closestDist = dist
						closestIDX = index
					endIf
				endIf
			endIf
			index += 1
		endWhile
	endIf
	
	if (closestIDX >= 0)
		result = nearBedArr[closestIDX]
	endIf
	
	return result
endFunction

ObjectReference Function FindNearestObjHaveKeywordFromObject(ObjectReference fromObj, FormList kwList, float distance = 900.0) global
	
	if (fromObj != None && kwList != None)
		
		ObjectReference closestRef = None
		
		float closestDist = 10000.0
		int kwIndex = 0
		int kwLen = kwList.GetSize()
			
		while (kwIndex < kwLen)
		
			Keyword kw = kwList.GetAt(kwIndex) as Keyword
			if (kw != None)
		
				ObjectReference[] nearArr = fromObj.FindAllReferencesWithKeyword(kw, distance)
				int closestIDX = -1
				
				if (nearArr)
					int index = 0
					while (index < nearArr.Length)
						
						ObjectReference aNearObjRef = nearArr[index]
						if (aNearObjRef != None && aNearObjRef.IsEnabled())
							float dist = DistanceBetweenObjects(aNearObjRef, fromObj)
							if (dist < closestDist)
								closestDist = dist
								closestIDX = index
							endIf
						endIf
						
						index += 1
					endWhile
					
					if (closestIDX >= 0)
						closestRef = nearArr[closestIDX]
					endIf
				endIf
			endIf
		
			kwIndex += 1
		endWhile
		
		return closestRef
	endIf
	
	return None
endFunction


; in case duplicate beds -- returns fromObj
ObjectReference Function FindNearestOpenBedFromObject(ObjectReference fromObj, FormList bedList, ObjectReference notBedRef, float distance = 900.0, Actor ownerRef = None, ObjectReference norThisBedRef = None) global
	if (fromObj != None && bedList != None)
	
		;ObjectReference aNearBed = FindNearestObjectInListFromPoint(bedList, fromPt, 350.0)
		
		ObjectReference[] nearBedArr = fromObj.FindAllReferencesOfType(bedList, distance)
		; ------
		int closestIDX = -1
		int ownedIDX = -1	; added v1.45
		int bedMatchCount = 0
		float closestDist = 10000.0
		float closestOwnedDist = 10000.0
		ActorBase ourOwnerBase = None
		if (ownerRef != None)
			ourOwnerBase = ownerRef.GetActorBase()
		endIf
		
		if (nearBedArr)
			int index = 0
			while (index < nearBedArr.Length)
			
				ObjectReference aNearBed = nearBedArr[index]
				if (aNearBed != None && aNearBed.IsEnabled())
					
					if (aNearBed == notBedRef)
						bedMatchCount += 1			; expect exactly 1
					elseIf (norThisBedRef != None && aNearBed == norThisBedRef)
						; skip this bed
						
					elseIf (aNearBed.IsFurnitureMarkerInUse(0, true) || aNearBed.IsFurnitureMarkerInUse(1, true))
						; skip this bed  ignore reserved
						
					elseIf (aNearBed.HasActorRefOwner())
						; only allowed if owned by our ownerRef
						if (aNearBed.IsOwnedBy(ownerRef))
							float dist = DistanceBetweenObjects(aNearBed, fromObj)
							if (dist < closestDist)
								closestIDX = index
								closestDist = dist
							endIf
							if (ownedIDX >= 0)
								if (dist < closestOwnedDist)
									ownedIDX = index
									closestOwnedDist = dist
								endIf
							else
								ownedIDX = index
								closestOwnedDist = dist
							endIf
						endIf
					else
						; must check owner-ref first (above) -- if false then check GetActorOwner
						; if None then not marked owned (orange)
						; see https://www.creationkit.com/fallout4/index.php?title=GetActorOwner_-_ObjectReference
						ActorBase bedOwnerBase = aNearBed.GetActorOwner()
						; see https://www.creationkit.com/index.php?title=GetFactionOwner_-_ObjectReference
						Faction bedOwnerFaction = aNearBed.GetFactionOwner()
						
						if (bedOwnerBase != None)
							if (ourOwnerBase != None && ourOwnerBase == bedOwnerBase)
								ownedIDX = index
							endIf
						elseIf (bedOwnerFaction != None)				; v1.95 - forgout about this - includes rented beds and private homes
							if (ownerRef.IsInFaction(bedOwnerFaction))
								ownedIDX = index
							endIf
						elseIf (!aNearBed.IsFurnitureMarkerInUse(0, true) && !aNearBed.IsFurnitureMarkerInUse(1, true))
							; ignore reserve
							float dist = DistanceBetweenObjects(aNearBed, fromObj)
							if (dist < closestDist)
								closestDist = dist
								closestIDX = index
							endIf
						endIf
					endIf
				endIf
			
				index += 1
			endWhile
			
			if (closestIDX >= 0)
			
				if (ownedIDX >= 0 && closestOwnedDist < 1000.0)
					return nearBedArr[ownedIDX]
				endIf
			
				return nearBedArr[closestIDX]
				
			elseIf (ownedIDX >= 0)
				return nearBedArr[ownedIDX]
				
			elseIf (bedMatchCount > 1)
				
				; made a mistake - report issue by returning from 
				return fromObj	; return from to denote found same bed twice 
			endIf
		endIf
	endIf

	return None
endFunction

ObjectReference Function FindNearestObjectInListFromObjRef(FormList list, ObjectReference fromObjRef, float radius) global
	if (list && fromObjRef != None)
		;
		;ObjectReference objRef = Game.FindClosestReferenceOfAnyTypeInListFromRef(list, fromObjRef, radius)
		;if (objRef != None && objRef.IsEnabled())
		;	return objRef
		;endIf
		float closestDist = 10000.0
		int closestIDX = -1
		ObjectReference[] nearObjArr = fromObjRef.FindAllReferencesOfType(list, radius)
		if (nearObjArr != None)
			int index = 0
			while (index < nearObjArr.Length)
				ObjectReference objRef = nearObjArr[index]
				if (objRef != None && objRef.IsEnabled())
					
					float dist = DistanceBetweenObjects(fromObjRef, objRef)
					if (dist < closestDist)
						closestDist = dist
						closestIDX = index
					endIf
				endIf
			
				index += 1
			endWhile
			
			if (closestIDX >= 0)
				return nearObjArr[closestIDX]
			endIf
		endIf
	endIf
	return None
EndFunction

ObjectReference Function FindNearestObjectInListFromPoint(FormList list, Point3DOrient fromPt, float radius) global

	if (list != None)
		
		ObjectReference objRef = Game.FindClosestReferenceOfAnyTypeInList(list, fromPt.X, fromPt.Y, fromPt.Z, radius)
		if (objRef != None && objRef.IsEnabled())
			return objRef
		endIf
	endIf

	return None
endFunction

; point relative to bed (as if at origin)
; returns left edge or right edge from center of bed -- X-value only
Point3DOrient Function FindNearestSideOfBedRelativeToBed(Point3DOrient bedPoint, Point3DOrient sideNearPoint) global
	Point3DOrient ptRes = new Point3DOrient
	
	if (sideNearPoint.Heading > bedPoint.Heading && sideNearPoint.Heading  <= bedPoint.Heading + 180.0)
		ptRes.X = -1 * GetHalfBedWidth()
		return ptRes
	endIf
	ptRes.X = GetHalfBedWidth()
	return ptRes
EndFunction

float Function GetGameTimeHoursDifference(float time1, float time2) global
	float result = 0.0
	if (time2 == time1)
		return 0.0
	elseIf (time2 > time1)
		result = time2 - time1
	else
		result = time1 - time2
	endIf
	result *= 24.0
	return result
endFunction

float Function GetGameTimeCurrentHourOfDay() global
 
	float gameTime = Utility.GetCurrentGameTime()  ; number days
	return GetGameTimeCurrentHourOfDayFromCurrentTime(gameTime)
EndFunction

float Function GetGameTimeCurrentHourOfDayFromCurrentTime(float gameTime) global
	gameTime -= Math.Floor(gameTime) ; keep only decimal
	float hourOfDay = gameTime * 24.0
	
	return hourOfDay
endFunction

Point3DOrient Function GetPointBedCrazyRugFem(float zAngleOfBed) global
	Point3DOrient positionResult = new Point3DOrient
	positionResult.Y = -34.0 - GetHalfBedLength()
	positionResult = GetPointOrientedFromPointByAngle(positionResult, zAngleOfBed)
	
	return positionResult
EndFunction

Point3DOrient Function GetPointBedCrazyRugMale(float zAngleOfBed) global
	Point3DOrient positionResult = new Point3DOrient
	positionResult.Y = -85.0 - GetHalfBedLength()
	positionResult = GetPointOrientedFromPointByAngle(positionResult, zAngleOfBed)
	
	return positionResult
EndFunction

; returns point relative to bed
Point3DOrient Function GetPointBedCuddle(bool isLowBed, float zAngleOfBed) global
	Point3DOrient positionResult = new Point3DOrient
	positionResult.Y = 18.1   ; for bed head facing north
	positionResult.X = 10.8
	positionResult = GetPointOrientedFromPointByAngle(positionResult, zAngleOfBed)
	if isLowBed
		positionResult.Z = GetLowBedHeight() + 0.5
	else
		positionResult.Z = GetBedHeight() + 1.0
	endIf 
	positionResult.Z += 3.0
	positionResult.Heading += Utility.RandomFloat(-5.0, 16.0)
	
	return positionResult
EndFunction

Point3DOrient Function GetPointBedHands(bool isLowBed, float zAngleOfBed) global
	Point3DOrient positionResult = new Point3DOrient
	positionResult.Y = 34.5
	positionResult.X = 22.5  ; for bed head facing north
	
	positionResult = GetPointOrientedFromPointByAngle(positionResult, zAngleOfBed)
	if isLowBed
		positionResult.Z = GetLowBedHeight() + 0.7
	else
		positionResult.Z = GetBedHeight() + 1.2
	endIf
	positionResult.Z += 7.0
	positionResult.Heading += Utility.RandomFloat(178.0, 192.0)
	
	return positionResult
EndFunction

Point3DOrient Function GetPointBedKnees(bool isLowBed, float zAngleOfBed) global
	Point3DOrient positionResult = new Point3DOrient
	positionResult.X = -12.2  ; for bed head facing north
	positionResult.Y = -19.0
	
	positionResult = GetPointOrientedFromPointByAngle(positionResult, zAngleOfBed)
	if isLowBed
		positionResult.Z = GetLowBedHeight()
	else
		positionResult.Z = GetBedHeight()
	endIf 
	positionResult.Z += 2.0
	positionResult.Heading += Utility.RandomFloat(-5.0, 16.0)
	
	return positionResult
EndFunction

; relative to bed
Point3DOrient Function GetPointBedLeitoA(bool isLowBed, float zAngleOfBed, float xDif, float yDif, bool maleLead = true) global
	Point3DOrient positionResult = new Point3DOrient
	positionResult.X = xDif  ; for bed head facing north then rotate to match angle
	
	; Leito nodes place actors 70 units apart - must fit on bed and avoid rail pushing chars
	positionResult.Y = 1.5 + yDif
	if (maleLead)
		positionResult.Y = -66.7 + yDif
	endIf
	
	positionResult = GetPointOrientedFromPointByAngle(positionResult, zAngleOfBed)
	if isLowBed
		positionResult.Z = 7.3
	else
		positionResult.Z = 46.4
	endIf
	 
	positionResult.Heading = 0.0
	
	return positionResult
EndFunction

; relative to pt
Point3DOrient Function GetPointDistOnHeading(Point3DOrient pt, float dist, float offsetAngle = 0.0) global
	Point3DOrient positionResult = new Point3DOrient
	positionResult.X = 0.0
	positionResult.Y = 0.0
	positionResult.Z = pt.Z
	if (dist > -1.00 && dist < 1.00)
		positionResult.Heading = pt.Heading
	else
		positionResult.Y = dist
		positionResult = GetPointOrientedFromPointByAngle(positionResult, pt.Heading + offsetAngle)
		positionResult.Heading = pt.Heading
	endIf
	
	return positionResult
endFunction

; relative to pt
Point3DOrient Function GetPointXDistOnHeading(Point3DOrient pt, float xdist) global
	Point3DOrient positionResult = new Point3DOrient
	positionResult.X = 0.0
	positionResult.Y = 0.0
	positionResult.Z = pt.Z
	if (xdist > -1.00 && xdist < 1.00)
		positionResult.Heading = pt.Heading
	else
		positionResult.X = xdist
		positionResult = GetPointOrientedFromPointByAngle(positionResult, pt.Heading)
		positionResult.Heading = pt.Heading
	endIf
	
	return positionResult
endFunction

Point3DOrient Function GetPointBedFloor(float zAngleOfBed) global
	Point3DOrient positionResult = new Point3DOrient
	positionResult.X = 0.0 - GetHalfBedWidth() ; for bed head facing north
	positionResult.Y = 36.0 - GetHalfBedLength()
	
	positionResult = GetPointOrientedFromPointByAngle(positionResult, zAngleOfBed) 
	positionResult.Heading = Utility.RandomFloat(-5.0, 16.0)
	
	return positionResult
EndFunction

; relative to bed
;
Point3DOrient Function GetPointBedArmorPlaceAtFoot(Point3DOrient bedPoint, Point3DOrient sideNearPoint, float xOffset = 0.0, float yOffset = 0.0) global
	
	Point3DOrient positionResult = FindNearestSideOfBedRelativeToBed(bedPoint, sideNearPoint)
	positionResult.Y = 45.0 - GetHalfBedLength() + yOffset
	if (positionResult.X > 0)
		positionResult.X += (16.67 + xOffset)
	else
		positionResult.X -= (16.67 + xOffset)
	endIf
	positionResult = GetPointOrientedFromPointByAngle(positionResult, bedPoint.Heading) 
	positionResult.Heading = Utility.RandomFloat(86.0, 94.0) + bedPoint.Heading
	if (positionResult.Heading > 360.0)
		positionResult.Heading -= 360.0
	endIf
	positionResult.Z = 1.8
	
	return positionResult
EndFunction

; relative to bed
;
Point3DOrient Function GetPointBedArmorPlaceAtHead(Point3DOrient bedPoint, Point3DOrient sideNearPoint, float xOffset = 0.0, float yOffset = 0.0) global
	
	Point3DOrient positionResult = FindNearestSideOfBedRelativeToBed(bedPoint, sideNearPoint)
	positionResult.Y = -36.0 + GetHalfBedLength() + yOffset
	if (positionResult.X > 0)
		positionResult.X += (16.5 + xOffset)
	else
		positionResult.X -= (16.5 + xOffset)
	endIf
	positionResult = GetPointOrientedFromPointByAngle(positionResult, bedPoint.Heading) 
	positionResult.Heading = Utility.RandomFloat(86.0, 94.0) + bedPoint.Heading
	if (positionResult.Heading > 360.0)
		positionResult.Heading -= 360.0
	endIf
	positionResult.Z = 1.8
	
	return positionResult
EndFunction

; relative to seat (offset)
Point3DOrient Function GetPointSeatPlace(Point3DOrient bedPoint, Point3DOrient sideNearPoint, float xOffset = 0.0, float yOffset = 0.0) global

	Point3DOrient positionResult = FindNearestSideOfBedRelativeToBed(bedPoint, sideNearPoint)
	positionResult.Y = 34.0 + yOffset
	if (positionResult.X > 0)
		positionResult.X += (8.67 + xOffset)
	else
		positionResult.X -= (8.67 + xOffset)
	endIf
	positionResult = GetPointOrientedFromPointByAngle(positionResult, bedPoint.Heading) 
	positionResult.Heading = Utility.RandomFloat(86.0, 94.0) + bedPoint.Heading
	if (positionResult.Heading > 360.0)
		positionResult.Heading -= 360.0
	endIf
	positionResult.Z = 0.25
	
	return positionResult
EndFunction

Point3DOrient Function GetPointBedFootEndToEndForBed(ObjectReference aBedRef, float distFromBed = 18.0, float offset = 0.0) global

	Point3DOrient positionResult = new Point3DOrient
	positionResult.Y = 28.0 - GetHalfBedLength() - distFromBed
	;positionResult.X = -12.0 + offset  ;nose near center of sleeping bag
	positionResult.X = 4.0 + offset
	Point3DOrient pointBed = PointOfObject(aBedRef)
	positionResult = GetPointOrientedFromPointByAngle(positionResult, pointBed.Heading)
	positionResult.X += pointBed.X
	positionResult.Y += pointBed.Y
	positionResult.Z += pointBed.Z - 2.33
	positionResult.Heading = pointBed.Heading
	
	return positionResult
EndFunction

; around origin on z-axis rotation (heading)
;
Point3DOrient Function GetPointOrientedFromPointByAngle(Point3DOrient pt, float angle) global
	Point3DOrient positionResult = new Point3DOrient
	positionResult.X = pt.X
	positionResult.Y = pt.Y
	positionResult.Z = pt.Z

	while (angle < 0.0)
		angle += 360.0
	endWhile
	if (angle > 8.0 && angle < 352.0)
		; not northward so calculate position relative to bed
		positionResult.Heading = angle
		positionResult = RotateXYbyHeading(positionResult)
	endIf

	return positionResult
EndFunction
 
Point3DOrient Function GetPointFacingTargetPointAtDistanceNearestPoint(Point3DOrient targetPoint, float distance, Point3DOrient nearPoint) global
	Point3DOrient positionResult = new Point3DOrient
	
	return positionResult
EndFunction

; world point
;
Point3DOrient Function GetPointOnSideOfBedWorld(float distanceOut, float bedX, float bedY, float bedZ, float zAngleOfBed) global
	Point3DOrient pt = new Point3DOrient
	pt.X = distanceOut
	pt = GetPointOrientedFromPointByAngle(pt, zAngleOfBed)
	pt.X = pt.X + bedX
	pt.Y = pt.Y + bedY
	pt.Z = pt.Z + bedZ
	
	return pt
EndFunction

; when actor on a furniture marker, have same coordinates -- this also covers if standing on bed
bool Function IsActorOnBed(Actor actorRef, ObjectReference bedRef, bool wideCheck = false) global
	if (actorRef != None && bedRef != None)
		float dist = 64.0
		if (wideCheck)
			dist = 96.0
		endIf
		Point3DOrient bedPoint = PointOfObject(bedRef)
		Point3DOrient actorPoint = PointOfObject(actorRef)
		if (actorPoint.Z > bedPoint.Z - 16.0 && actorPoint.Z < bedPoint.Z + 64.0)
			if (actorPoint.X > bedPoint.X - dist && actorPoint.X < bedPoint.X + dist && actorPoint.Y > bedPoint.Y - dist && actorPoint.Y < bedPoint.Y + dist)
				return true
			endIf
		endIf
	endIf
	return false
EndFunction

bool Function IsIntegerInArray(int anInt, int[] anArray) global
	bool result = false
	if (anArray != None)		; in Papyrus, array never None so check array None same as Length zero
		int idx = 0
		while (idx < anArray.Length)
			if (anArray[idx] == anInt)
				result = true
				idx = anArray.Length + 100
			endIf
			idx += 1
		endWhile
	endIf
	
	return result
EndFunction

Function MoveActorFacingDistance(Actor actorRef, float distance) global

	if (actorRef != None)
		Point3DOrient ptActor = PointOfObject(actorRef)
		Point3DOrient ptBack = GetPointDistOnHeading(ptActor, distance)
		
		actorRef.TranslateTo(ptBack.X + 0.001, ptBack.Y + 0.0001, ptBack.Z, 0.0, 0.0, 0.05, 100.0, 0.000000001)
	endIf
endFunction

Function MoveActorToObject(Actor actorRef, ObjectReference posObjRef, float atAngleOff = 0.1, float yOffset = 0.001, float turnAngleSpeed = 0.00000000001) global
	

	if (actorRef != None && posObjRef != None)
		;actorRef.SetPosition(posObjRef.GetPositionX(), posObjRef.GetPositionY(), posObjRef.GetPositionZ())
		;actorRef.SetAngle(0, 0, posObjRef.GetAngleZ())
				
		actorRef.StopTranslation()
			
		float x = posObjRef.GetPositionX()
		float y = posObjRef.GetPositionY()
		float z = posObjRef.GetPositionZ()
		float h = posObjRef.GetAngleZ()
			
		actorRef.TranslateTo(x + 0.001, y + yOffset, z, 0.0, 0.0, h + 0.05 + atAngleOff, 400.0, turnAngleSpeed)
	endIf
endFunction

; -----
; spawns new object 
; place form at a marker reference; returns last created;
; for spawned item best to remove using DisableAndDeleteObjectRef to prevent bloat
; see https://www.creationkit.com/fallout4/index.php?title=PlaceAtMe_-_ObjectReference
; havok motion type: https://www.creationkit.com/fallout4/index.php?title=SetMotionType_-_ObjectReference
;
; based on Chesko's Campfire object placement shared on GitHub under license
ObjectReference Function PlaceFormAtObjectRef(Form formToPlace, ObjectReference objRef, bool persist = false, bool blockActivate = true, bool alignAngle = false) global
	
	if (objRef != None && formToPlace != None)
		ObjectReference newObj = objRef.PlaceAtMe(formToPlace, 1, persist)
		newObj = Ensure3DIsLoadedForNewObjRef(newObj, blockActivate)
		newObj.SetPosition(objRef.GetPositionX(), objRef.GetPositionY(), objRef.GetPositionZ() + 0.1)
		if (alignAngle)
			newObj.SetAngle(0.0, 0.0, objRef.GetAngleZ())
		endIf
		return newObj
	endIf
	
	return None
EndFunction

ObjectReference Function PlaceFormAtFootOfBedRef(Form formToPlace, ObjectReference bedRef, float distanceAway = 18.0, float offsetX = 0.0, float angle = 0.0) global

	if (formToPlace != None && bedRef != None)
		Point3DOrient ptFoot = GetPointBedFootEndToEndForBed(bedRef, distanceAway, offsetX)
		ObjectReference newObj = bedRef.PlaceAtMe(formToPlace, 1, false)
		newObj = Ensure3DIsLoadedForNewObjRef(newObj, true)
		if (distanceAway >= 10.0)
			newObj.SetPosition(ptFoot.X, ptFoot.Y, ptFoot.Z + 2.0)
		else
			newObj.SetPosition(ptFoot.X, ptFoot.Y, ptFoot.Z + GetLowBedHeight())
		endIf
		
		if (angle != 0.0)
			newObj.SetAngle(0.0, 0.0, ptFoot.Heading + angle)
		endIf
		
		return newObj
	endIf
	
	return None
EndFunction

ObjectReference Function PlaceFormAtNodeRefForNodeForm(ObjectReference nodeRef, string nodeString, Form nodeForm, bool blockActivate = true) global
	if (nodeRef && nodeString && nodeForm)
		ObjectReference newObj = nodeRef.PlaceAtNode(nodeString, nodeForm)
		return Ensure3DIsLoadedForNewObjRef(newObj, blockActivate)
	endIf
	return None
EndFunction

ObjectReference Function Ensure3DIsLoadedForNewObjRef(ObjectReference newObj, bool blockActivate = true) global
	if (newObj)
		; make sure 3D loaded
		int tryCnt = 0
		while (tryCnt < 50)
			if (newObj.Is3DLoaded())
				;newObj.SetMotionType(4)
				if (blockActivate)
					newObj.BlockActivation(true, true)
				endIf
				tryCnt = 100
				return newObj
			else
				Utility.Wait(0.03)
			endIf
			tryCnt += 1
		endWhile
	endIf
	return None
EndFunction

string Function Point3DOrientToString(Point3DOrient pt) global
	return "(" + pt.X + "," + pt.Y + "," + pt.Z + " H:" + pt.Heading + ")"
EndFunction
 
bool Function PositionObjRefFacingNearestSideOfTargetRef(ObjectReference objToPlaceRef, ObjectReference targetRef, Point3DOrient nearPoint) global
	
	return false
EndFunction

Point3DOrient Function PointOfObject(ObjectReference objRef) global
	Point3DOrient pt = new Point3DOrient
	if (objRef)
		pt.X = objRef.GetPositionX()
		pt.Y = objRef.GetPositionY()
		pt.Z = objRef.GetPositionZ()
		pt.Heading = objRef.GetAngleZ()
	endIf
	return pt
EndFunction

bool Function PositionObjsMatch(ObjectReference objA, ObjectReference objB) global
	if (objA != None && objB != None)
		float posX = objB.GetPositionX()
		float posY = objB.GetPositionY()
		return PositionObjMatchXY(objA, posX, posY)
	endIf

	return false
endFunction

bool Function PositionObjMatchXY(ObjectReference obj, float x, float y) global

	if (obj != None)
		float posX = obj.GetPositionX()
		float posY = obj.GetPositionY()
		if (posX > (x - 0.7) && posY < (x + 0.7) && posY > (y - 0.7) && posY < (y + 0.7))
			return true
		endIf
	endIf
	
	return false
endFunction

Point3DOrient Function RotateXYbyHeading(Point3DOrient pt) global
	Point3DOrient resultPoint = new Point3DOrient
	resultPoint.X = pt.X * Math.cos(pt.Heading) + pt.Y * Math.sin(pt.Heading)
	resultPoint.Y = pt.Y * Math.cos(pt.Heading) - pt.X * Math.sin(pt.Heading)
	
	return resultPoint
EndFunction
 

