#if defined _sf2_nav_included
 #endinput
#endif
#define _sf2_nav_included

#define JumpCrouchHeight 58.0

static Handle g_hFuncNavPrefer;

methodmap NavPath < Handle
{
	public NavPath()
	{
		return NavPath:CreateNavPath();
	}

	public int AddNodeToHead(float nodePos[3],int nodeIndex)
	{
		return NavPathAddNodeToHead(this, nodePos, nodeIndex);
	}
	
	public int AddNodeToTail(float nodePos[3], int nodeIndex)
	{
		return NavPathAddNodeToTail(this, nodePos, nodeIndex);
	}
	
	public void GetNodePosition(int nodeIndex, float buffer[3])
	{
		NavPathGetNodePosition(this, nodeIndex, buffer);
	}
	
	public int GetNodeAreaIndex(int nodeIndex)
	{
		return NavPathGetNodeAreaIndex(this, nodeIndex);
	}
	
	public int GetNodeLadderIndex(int nodeIndex)
	{
		return NavPathGetNodeLadderIndex(this, nodeIndex);
	}
	
	public bool ConstructPathFromPoints(float startPos[3], float endPos[3], float nearestAreaRadius, Function costFunction, any costData, bool populateIfIncomplete = true, int &closestAreaIndex = -1)
	{
		return NavPathConstructPathFromPoints(this, startPos, endPos, nearestAreaRadius, costFunction, costData, populateIfIncomplete, closestAreaIndex);
	}
}

void Nav_Initialize()
{
	g_hFuncNavPrefer = CreateArray();
}

stock void NavCollectFuncNavPrefer()
{
	ClearArray(g_hFuncNavPrefer);
	int iFunc = -1;
	while ((iFunc = FindEntityByClassname(iFunc, "func_nav_prefer")) != -1)
	{
		PushArrayCell(g_hFuncNavPrefer, iFunc);
	}
}

stock bool NavHasFuncPrefer(int iAreaIndex)
{
	float flCenter[3];
	NavMeshArea_GetCenter(iAreaIndex, flCenter);
	if (GetArraySize(g_hFuncNavPrefer) > 0)
	{
		for (int a = 1;a <= (GetArraySize(g_hFuncNavPrefer) - 1);a++)
		{
			int iFunc = GetArrayCell(g_hFuncNavPrefer, a);
			if (SDK_PointIsWithin(iFunc, flCenter))
				return true;
		}
	}
	return false;
}

stock Handle CreateNavPath()
{
	return CreateArray(5);
}

stock void NavPathGetNodePosition(Handle hNavPath,int iNodeIndex, float buffer[3])
{
	buffer[0] = Float:GetArrayCell(hNavPath, iNodeIndex, 0);
	buffer[1] = Float:GetArrayCell(hNavPath, iNodeIndex, 1);
	buffer[2] = Float:GetArrayCell(hNavPath, iNodeIndex, 2);
}

stock int NavPathGetNodeAreaIndex(Handle hNavPath,int iNodeIndex)
{
	return GetArrayCell(hNavPath, iNodeIndex, 3);
}

stock int NavPathGetNodeLadderIndex(Handle hNavPath,int iNodeIndex)
{
	return GetArrayCell(hNavPath, iNodeIndex, 4);
}

stock int NavPathAddNodeToHead(Handle hNavPath, const float flNodePos[3],int iNodeAreaIndex,int iLadderIndex=-1)
{
	int iIndex = -1;

	if (GetArraySize(hNavPath) == 0)
	{
		iIndex = PushArrayArray(hNavPath, flNodePos, 3);
		
	}
	else
	{
		iIndex = 0;
		ShiftArrayUp(hNavPath, 0);
		SetArrayArray(hNavPath, iIndex, flNodePos, 3);
	}
	
	SetArrayCell(hNavPath, iIndex, iNodeAreaIndex, 3);
	SetArrayCell(hNavPath, iIndex, iLadderIndex, 4);
	
	return iIndex;
}

stock int NavPathAddNodeToTail(Handle hNavPath, const float flNodePos[3],int iNodeAreaIndex,int iLadderIndex=-1)
{
	int iIndex = PushArrayArray(hNavPath, flNodePos, 3);
	SetArrayCell(hNavPath, iIndex, iNodeAreaIndex, 3);
	SetArrayCell(hNavPath, iIndex, iLadderIndex, 4);
	
	return iIndex;
}

/**
 *	Constructs a straight path leading from flStartPos to flEndPos. Useful if both points are within the same area, so pathing around is unnecessary.
 */
stock bool NavPathConstructTrivialPath(Handle hNavPath, const float flStartPos[3], const float flEndPos[3], float flNearestAreaRadius)
{
	ClearArray(hNavPath);

	int iStartAreaIndex = NavMesh_GetNearestArea(flStartPos, _, flNearestAreaRadius);
	if (iStartAreaIndex == -1) return false;
	
	int iEndAreaIndex = NavMesh_GetNearestArea(flEndPos, _, flNearestAreaRadius);
	if (iEndAreaIndex == -1) return false;

	// Build a trivial path instead.
	float flStartPosOnNavMesh[3];
	flStartPosOnNavMesh[0] = flStartPos[0];
	flStartPosOnNavMesh[1] = flStartPos[1];
	flStartPosOnNavMesh[2] = NavMeshArea_GetZ(iStartAreaIndex, flStartPos);
	
	NavPathAddNodeToTail(hNavPath, flStartPosOnNavMesh, iStartAreaIndex);
	
	float flEndPosOnNavMesh[3];
	flEndPosOnNavMesh[0] = flEndPos[0];
	flEndPosOnNavMesh[1] = flEndPos[1];
	flEndPosOnNavMesh[2] = NavMeshArea_GetZ(iEndAreaIndex, flEndPos);
	
	NavPathAddNodeToTail(hNavPath, flEndPosOnNavMesh, iEndAreaIndex);

	return true;
}

/**
 *	Constructs a path leading from flStartPos to flEndPos. First node index (0) is the start of the path, last node index is the end.
 */
stock bool NavPathConstructPathFromPoints(Handle hNavPath, const float flStartPos[3], const float flEndPos[3], float flNearestAreaRadius, Function fCostFunction, any iCostData=-1, bool bPopulateIfIncomplete=false,int &iClosestAreaIndex=0)
{
	ClearArray(hNavPath);
	
	int iStartAreaIndex = NavMesh_GetNearestArea(flStartPos, _, flNearestAreaRadius);
	if (iStartAreaIndex == -1) return false;
	
	int iEndAreaIndex = NavMesh_GetNearestArea(flEndPos, _, flNearestAreaRadius);
	if (iEndAreaIndex == -1) return false;
	
	if (iStartAreaIndex == iEndAreaIndex)
	{
		return NavPathConstructTrivialPath(hNavPath, flStartPos, flEndPos, flNearestAreaRadius);
	}
	
	iClosestAreaIndex = 0;
	
	bool bResult = NavMesh_BuildPath(iStartAreaIndex,
		iEndAreaIndex,
		flEndPos,
		fCostFunction,
		iCostData,
		iClosestAreaIndex);
		
	if (!bResult && bPopulateIfIncomplete) return false;
	
	if (bResult)
	{
		// Because we were able to get to the goal position successfully, add the goal position itself.
		float flEndPosOnNavMesh[3];
		flEndPosOnNavMesh[0] = flEndPos[0];
		flEndPosOnNavMesh[1] = flEndPos[1];
		flEndPosOnNavMesh[2] = NavMeshArea_GetZ(iEndAreaIndex, flEndPos);
		
		NavPathAddNodeToHead(hNavPath, flEndPosOnNavMesh, iEndAreaIndex);
	}
	
	float flCenter[3], Float:flCenterPortal[3], Float:flClosestPoint[3];
	
	int iTempAreaIndex = iClosestAreaIndex;
	int iTempParentAreaIndex = NavMeshArea_GetParent(iTempAreaIndex);
	int iNavDirection;
	float flHalfWidth;
	
	while (iTempParentAreaIndex != -1)
	{
		// Build a path of waypoints along the nav mesh for our AI to follow.
		
		NavMeshArea_GetCenter(iTempParentAreaIndex, flCenter);
		iNavDirection = NavMeshArea_ComputeDirection(iTempAreaIndex, flCenter);
		NavMeshArea_ComputePortal(iTempAreaIndex, iTempParentAreaIndex, iNavDirection, flCenterPortal, flHalfWidth);
		NavMeshArea_ComputeClosestPointInPortal(iTempAreaIndex, iTempParentAreaIndex, iNavDirection, flCenterPortal, flClosestPoint);
		
		flClosestPoint[2] = NavMeshArea_GetZ(iTempAreaIndex, flClosestPoint);
		
		NavPathAddNodeToHead(hNavPath, flClosestPoint, iTempAreaIndex);
		
		iTempAreaIndex = iTempParentAreaIndex;
		iTempParentAreaIndex = NavMeshArea_GetParent(iTempAreaIndex);
	}
	
	float flStartPosOnNavMesh[3];
	flStartPosOnNavMesh[0] = flStartPos[0];
	flStartPosOnNavMesh[1] = flStartPos[1];
	flStartPosOnNavMesh[2] = NavMeshArea_GetZ(iStartAreaIndex, flStartPos);
	
	NavPathAddNodeToHead(hNavPath, flStartPosOnNavMesh, iStartAreaIndex);
	
	return bResult;
}

/**
 *	Return the closest point to our current position on our current path
 *	If "local" is true, only check the portion of the path surrounding iPathNodeIndex.
 *	(function imported from HL SDK)
 */
stock int FindClosestPositionOnPath(Handle hNavPath, const float flFeetPos[3], const float flCentroidPos[3], const float flEyePos[3], float flBuffer[3]=NULL_VECTOR, bool bLocal=false, int iPathNodeIndex=-1)
{
	if (hNavPath == INVALID_HANDLE) return -1;
	
	int iNodeCount = GetArraySize(hNavPath);
	if (iNodeCount == 0) return -1;
	
	int iStartNode = -1;
	int iEndNode = -1;
	
	if (bLocal)
	{
		// Clamp nodes to stay within path segment.
		iStartNode = iPathNodeIndex - 3;
		if (iStartNode < 1) iStartNode = 1;
		
		iEndNode = iPathNodeIndex + 3;
		if (iEndNode > iNodeCount) iEndNode = iNodeCount;
	}
	else
	{
		iStartNode = 1;
		iEndNode = iNodeCount;
	}
	
	float flFrom[3], Float:flTo[3];
	float flAlong[3], Float:flToFeetPos[3];
	
	float flLength, Float:flCloseLength, Float:flDistSq;
	
	float flPos[3], Float:flSub[3], Float:flProbe[3];
	
	float flCloseDistSq = 9999999999.9;
	int iCloseIndex = -1;
	
	float flMidHeight = flCentroidPos[2] - flFeetPos[2];
	
	for (int i = iStartNode; i < iEndNode; i++)
	{
		NavPathGetNodePosition(hNavPath, i - 1, flFrom);
		NavPathGetNodePosition(hNavPath, i, flTo);
		
		// Convert flAlong to unit vector.
		SubtractVectors(flTo, flFrom, flAlong);
		flLength = GetVectorLength(flAlong);
		NormalizeVector(flAlong, flAlong);
		
		SubtractVectors(flFeetPos, flFrom, flToFeetPos);
		
		// Clamp point onto current path segment.
		flCloseLength = GetVectorDotProduct(flToFeetPos, flAlong);
		if (flCloseLength <= 0.0)
		{
			flPos[0] = flFrom[0];
			flPos[1] = flFrom[1];
			flPos[2] = flFrom[2];
		}
		else if (flCloseLength >= flLength)
		{
			flPos[0] = flTo[0];
			flPos[1] = flTo[1];
			flPos[2] = flTo[2];
		}
		else
		{
			flPos[0] = flFrom[0] + (flCloseLength * flAlong[0]);
			flPos[1] = flFrom[1] + (flCloseLength * flAlong[1]);
			flPos[2] = flFrom[2] + (flCloseLength * flAlong[2]);
		}
		
		SubtractVectors(flPos, flFeetPos, flSub);
		flDistSq = GetVectorLength(flSub, true);
		
		if (flDistSq < flCloseDistSq)
		{
			flProbe[0] = flPos[0];
			flProbe[1] = flPos[1];
			flProbe[2] = flPos[2] + flMidHeight;
			
			if (!IsWalkableTraceLineClear(flEyePos, flProbe, WALK_THRU_DOORS | WALK_THRU_BREAKABLES)) continue;
			
			flCloseDistSq = flDistSq;
			CopyVector(flPos, flBuffer);
			
			iCloseIndex = i - 1;
		}
	}
	
	return iCloseIndex;
}

/**
 *	Computes a point a fixed distance ahead of our path.
 *	Returns path index just after point.
 *	(function imported from HL SDK)
 */
stock int FindAheadPathPoint(Handle hNavPath, float flAheadRange,int iPathNodeIndex, const float flFeetPos[3], const float flCentroidPos[3], const float flEyePos[3], float flPoint[3],int &iPrevPathNodeIndex)
{
	if (hNavPath == INVALID_HANDLE) return -1;
	
	int iAfterPathNodeIndex;
	
	float flClosestPos[3];
	
	int iStartPathNodeIndex = FindClosestPositionOnPath(hNavPath, flFeetPos, flCentroidPos, flEyePos, flClosestPos, true, iPathNodeIndex);
	iPrevPathNodeIndex = iStartPathNodeIndex;
	
	if (iStartPathNodeIndex <= 0)
	{
		// Went off the end of the path or next point in path is unwalkable (ie: jump-down). Keep same point
		return iPathNodeIndex;
	}
	
	float flFeetPos2D[3], Float:flPathNodePos2D[3];
	CopyVector(flFeetPos, flFeetPos2D);
	flFeetPos2D[2] = 0.0;
	
	while (iStartPathNodeIndex < (GetArraySize(hNavPath) - 1))
	{
		float flPathNodePos[3];
		NavPathGetNodePosition(hNavPath, iStartPathNodeIndex, flPathNodePos);
		flPathNodePos2D[2] = 0.0;
		
		static Float:closeEpsilon = 20.0;
		
		if (GetVectorDistance(flFeetPos2D, flPathNodePos2D) < closeEpsilon)
		{
			iStartPathNodeIndex++;
		}
		else
		{
			break;
		}
	}
	
	// Approaching jump area? Look no further, we must stop here.
	if (iStartPathNodeIndex > iPathNodeIndex && iStartPathNodeIndex < GetArraySize(hNavPath) &&
		NavMeshArea_GetFlags(NavPathGetNodeAreaIndex(hNavPath, iStartPathNodeIndex)) & NAV_MESH_JUMP)
	{
		NavPathGetNodePosition(hNavPath, iStartPathNodeIndex, flPoint);
		return iStartPathNodeIndex;
	}
	
	iStartPathNodeIndex++;
	
	// Approaching jump area? Look no further, we must stop here.
	if (iStartPathNodeIndex < GetArraySize(hNavPath) &&
		NavMeshArea_GetFlags(NavPathGetNodeAreaIndex(hNavPath, iStartPathNodeIndex)) & NAV_MESH_JUMP)
	{
		NavPathGetNodePosition(hNavPath, iStartPathNodeIndex, flPoint);
		return iStartPathNodeIndex;
	}
	
	// Get the direction of the path segment we're currently on.
	float flStartPathNodePos[3], Float:flPrevStartPathNodePos[3];
	NavPathGetNodePosition(hNavPath, iStartPathNodeIndex, flStartPathNodePos);
	NavPathGetNodePosition(hNavPath, iStartPathNodeIndex - 1, flPrevStartPathNodePos);
	
	float flInitDir[3];
	SubtractVectors(flStartPathNodePos, flPrevStartPathNodePos, flInitDir);
	NormalizeVector(flInitDir, flInitDir);
	
	float flRangeSoFar = 0.0;
	
	// bVisible is true if our ahead point is visible.
	bool bVisible = true;
	
	float flPrevDir[3];
	CopyVector(flInitDir, flPrevDir);
	
	bool bIsCorner = false;
	int i = 0;
	
	float flMidHeight = flCentroidPos[2] - flFeetPos[2];
	
	// Step along the path until we pass flAheadRange.
	for (i = iStartPathNodeIndex; i < GetArraySize(hNavPath); i++)
	{
		float flPathNodePos[3], Float:flTo[3], Float:flDir[3];
		NavPathGetNodePosition(hNavPath, i, flPathNodePos);
		NavPathGetNodePosition(hNavPath, i - 1, flTo);
		NegateVector(flTo);
		AddVectors(flPathNodePos, flTo, flTo);
		
		NormalizeVector(flTo, flDir);
		
		if (GetVectorDotProduct(flDir, flInitDir) < 0.0)
		{
			// Don't double back.
			i--;
			break;
		}
		
		if (GetVectorDotProduct(flDir, flPrevDir) < 0.0)
		{
			// Don't cut corners.
			bIsCorner = true;
			i--;
			break;
		}
		
		CopyVector(flDir, flPrevDir);
		
		float flProbe[3];
		CopyVector(flPathNodePos, flProbe);
		flProbe[2] += flMidHeight;
		
		if (!IsWalkableTraceLineClear( flEyePos, flProbe, WALK_THRU_BREAKABLES ))
		{
			// Points aren't visible ahead; stick to the last visible point ahead.
			bVisible = false;
			break;
		}
		
		if (NavMeshArea_GetFlags(NavPathGetNodeAreaIndex(hNavPath, i)) & NAV_MESH_JUMP)
		{
			// Jump area here; stop.
			break;
		}
		
		if (i == iStartPathNodeIndex)
		{
			float flAlong[3];
			SubtractVectors(flPathNodePos, flFeetPos, flAlong);
			flAlong[2] = 0.0;
			flRangeSoFar += GetVectorLength(flAlong);
		}
		else
		{
			flRangeSoFar += GetVectorLength(flTo);
		}
		
		if (flRangeSoFar >= flAheadRange)
		{
			// Went ahead of flAheadRange; stop.
			break;
		}
	}
	
	// clamp iAfterPathNodeIndex between starting path node and the end
	if (i < iStartPathNodeIndex)
	{
		iAfterPathNodeIndex = iStartPathNodeIndex;
	}
	else if (i < GetArraySize(hNavPath))
	{
		iAfterPathNodeIndex = i;
	}
	else
	{
		iAfterPathNodeIndex = GetArraySize(hNavPath) - 1;
	}
	
	if (iAfterPathNodeIndex == 0)
	{
		NavPathGetNodePosition(hNavPath, 0, flPoint);
	}
	else
	{
		// Interpolate point along path segment to get exact distance.
		float flBeforePointPos[3], Float:flAfterPointPos[3];
		NavPathGetNodePosition(hNavPath, iAfterPathNodeIndex, flAfterPointPos);
		NavPathGetNodePosition(hNavPath, iAfterPathNodeIndex - 1, flBeforePointPos);
		
		float flTo[3], Float:flTo2D[3];
		SubtractVectors(flAfterPointPos, flBeforePointPos, flTo);
		CopyVector(flTo, flTo2D);
		flTo2D[2] = 0.0;
		
		float flLength = GetVectorLength(flTo2D);
		float t = 1.0 - ((flRangeSoFar - flAheadRange) / flLength);
		
		if (t < 0.0) t = 0.0;
		else if (t > 1.0) t = 1.0;
		
		for (int i2 = 0; i2 < 3; i2++)
		{
			flPoint[i2] = flBeforePointPos[i2] + (t * flTo[i2]);
		}
		
		if (!bVisible)
		{
			// iAfterPathNodeIndex isn't visible, so slide back towards previous node until it is. 
		
			static const Float:flSightStepSize = 25.0;
			float dt = flSightStepSize / flLength;
			
			float flProbe[3];
			CopyVector(flPoint, flProbe);
			flProbe[2] += flMidHeight;
			
			while (t > 0.0 && !IsWalkableTraceLineClear(flEyePos,  flProbe, WALK_THRU_BREAKABLES))
			{
				t -= dt;
				
				for (int i2 = 0; i2 < 3; i2++)
				{
					flPoint[i2] = flBeforePointPos[i2] + (t * flTo[i2]);
				}
			}
			
			if (t <= 0.0)
			{
				CopyVector(flBeforePointPos, flPoint);
			}
		}
	}
	
	// Is there a corner ahead?
	if (!bIsCorner)
	{
		// If position found is behind us or it's too close to us, force it farther down the path so we don't stop and wiggle.
	
		static const Float:epsilon = 50.0;
		
		float flCentroid2D[3];
		CopyVector(flCentroidPos, flCentroid2D);
		flCentroid2D[2] = 0.0;
		
		float flTo2D[3];
		flTo2D[0] = flPoint[0] - flCentroid2D[0];
		flTo2D[1] = flPoint[1] - flCentroid2D[1];
		flTo2D[2] = 0.0;
		
		float flInitDir2D[3];
		CopyVector(flInitDir, flInitDir2D);
		flInitDir2D[2] = 0.0;
		
		if (GetVectorDotProduct(flTo2D, flInitDir2D) < 0.0 || GetVectorLength(flTo2D) < epsilon)
		{
			// Check points ahead.
			for (i = iStartPathNodeIndex; i < GetArraySize(hNavPath); i++)
			{
				float flPathNodePos[3];
				NavPathGetNodePosition(hNavPath, i, flPathNodePos);
			
				flTo2D[0] = flPathNodePos[0] - flCentroid2D[0];
				flTo2D[1] = flPathNodePos[1] - flCentroid2D[1];
				
				// Check if the point ahead is either a jump/ladder area or is far enough.
				if (NavMeshArea_GetFlags(NavPathGetNodeAreaIndex(hNavPath, i)) & NAV_MESH_JUMP || GetVectorLength(flTo2D) > epsilon)
				{
					CopyVector(flPathNodePos, flPoint);
					iStartPathNodeIndex = i;
					break;
				}
			}
			
			if (i == GetArraySize(hNavPath))
			{
				iStartPathNodeIndex = GetArraySize(hNavPath) - 1;
				NavPathGetNodePosition(hNavPath, iStartPathNodeIndex, flPoint);
			}
		}
	}
	
	if (iStartPathNodeIndex < GetArraySize(hNavPath))
	{
		return iStartPathNodeIndex;
	}
	
	return GetArraySize(hNavPath) - 1;
}


stock void CalculateFeelerReflexAdjustment(const float flOriginalMovePos[3], 
	const float flOriginalFeetPos[3], 
	const float flFloorNormalDir[3],
	float flFeelerHeight, 
	float flFeelerOffset, 
	float flFeelerLength, 
	float flAvoidRange, 
	float flBuffer[3], 
	int iTraceMask=MASK_PLAYERSOLID,
	Function fTraceFilterFunction=INVALID_FUNCTION, 
	any iTraceFilterFunctionData=-1)
{
	// Forward direction vector.
	float flOriginalMoveDir[3], Float:flLateralDir[3];
	SubtractVectors(flOriginalMovePos, flOriginalFeetPos, flOriginalMoveDir);
	flOriginalMoveDir[2] = 0.0;
	
	GetVectorAngles(flOriginalMoveDir, flOriginalMoveDir);
	GetAngleVectors(flOriginalMoveDir, flOriginalMoveDir, flLateralDir, NULL_VECTOR);
	NormalizeVector(flOriginalMoveDir, flOriginalMoveDir);
	NormalizeVector(flLateralDir, flLateralDir);
	NegateVector(flLateralDir);
	
	// Correct move direction vector along floor.
	float flDir[3];
	GetVectorCrossProduct(flLateralDir, flFloorNormalDir, flDir);
	NormalizeVector(flDir, flDir);
	
	// Correct lateral direction vector along floor.
	GetVectorCrossProduct(flDir, flFloorNormalDir, flLateralDir);
	NormalizeVector(flLateralDir, flLateralDir);
	
	if (flFeelerHeight <= 0.0)
	{
		flFeelerHeight = StepHeight + 0.1;
	}
	
	float flFeetPos[3];
	CopyVector(flOriginalFeetPos, flFeetPos);
	flFeetPos[2] += flFeelerHeight;
	
	float flFromPos[3];
	float flToPos[3];
	
	// Check the left.
	for (int i = 0; i < 3; i++)
	{
		flFromPos[i] = flFeetPos[i] + (flFeelerOffset * flLateralDir[i]);
		flToPos[i] = flFromPos[i] + (flFeelerLength * flDir[i]);
	}
	
	Handle hTrace = INVALID_HANDLE;
	if (fTraceFilterFunction != INVALID_FUNCTION)
	{
		hTrace = TR_TraceRayFilterEx(flFromPos, flToPos, iTraceMask, RayType_EndPoint, fTraceFilterFunction, iTraceFilterFunctionData);
	}
	else
	{
		hTrace = TR_TraceRayEx(flFromPos, flToPos, iTraceMask, RayType_EndPoint);
	}
	
	bool bLeftClear = !TR_DidHit(hTrace);
	CloseHandle(hTrace);
	
#if defined DEBUG
	
	if (bLeftClear)
	{
		TE_SetupBeamPoints(flFromPos, flToPos, PrecacheModel("sprites/laser.vmt"), PrecacheModel("sprites/laser.vmt"), 0, 30, 0.1, 5.0, 5.0, 1, 0.0, { 0, 255, 0, 255 }, 30);
	}
	else
	{
		TE_SetupBeamPoints(flFromPos, flToPos, PrecacheModel("sprites/laser.vmt"), PrecacheModel("sprites/laser.vmt"), 0, 30, 0.1, 5.0, 5.0, 1, 0.0, { 255, 0, 0, 255 }, 30);
	}
	
	TE_SendToAll();
	
#endif
	
	// Check the right.
	for (int i = 0; i < 3; i++)
	{
		flFromPos[i] = flFeetPos[i] - (flFeelerOffset * flLateralDir[i]);
		flToPos[i] = flFromPos[i] + (flFeelerLength * flDir[i]);
	}
	
	if (fTraceFilterFunction != INVALID_FUNCTION)
	{
		hTrace = TR_TraceRayFilterEx(flFromPos, flToPos, iTraceMask, RayType_EndPoint, fTraceFilterFunction, iTraceFilterFunctionData);
	}
	else
	{
		hTrace = TR_TraceRayEx(flFromPos, flToPos, iTraceMask, RayType_EndPoint);
	}
	
	bool bRightClear = !TR_DidHit(hTrace);
	CloseHandle(hTrace);
	
#if defined DEBUG
	
	if (bRightClear)
	{
		TE_SetupBeamPoints(flFromPos, flToPos, PrecacheModel("sprites/laser.vmt"), PrecacheModel("sprites/laser.vmt"), 0, 30, 0.1, 5.0, 5.0, 1, 0.0, { 0, 255, 0, 255 }, 30);
	}
	else
	{
		TE_SetupBeamPoints(flFromPos, flToPos, PrecacheModel("sprites/laser.vmt"), PrecacheModel("sprites/laser.vmt"), 0, 30, 0.1, 5.0, 5.0, 1, 0.0, { 255, 0, 0, 255 }, 30);
	}
	
	TE_SendToAll();
	
#endif
	
	if (!bRightClear)
	{
		if (bLeftClear)
		{
			for (int i = 0; i < 3; i++)
			{
				flBuffer[i] = flOriginalMovePos[i] + (flAvoidRange * flLateralDir[i]);
			}
		}
	}
	else if (!bLeftClear)
	{
		for (int i = 0; i < 3; i++)
		{
			flBuffer[i] = flOriginalMovePos[i] - (flAvoidRange * flLateralDir[i]);
		}
	}
}