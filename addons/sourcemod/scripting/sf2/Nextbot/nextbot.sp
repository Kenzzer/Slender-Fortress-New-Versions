//Special thanks to Arthurdead for helping me on some functions about Nextbot and for providing the base ILocomotion methodmap!
//This method is build on ILocomotion & NextBotGroundLocomotion & CTFBaseBossLocomotion only! In other words it supports "base_boss" and "tank_boss" only!!!!

/* INextBot */
//Handle g_hClimbUpToLedge;
//Handle g_hJumpAcrossGap;
Handle g_hGetGravity;
Handle g_hGetMaxDeceleration;
Handle g_hGetAcceleration;
Handle g_hGetFrictionForward;
Handle g_hGetFrictionSideways;
Handle g_hIsAbleToClimb;
Handle g_hIsAbleToJumpAcrossGaps;
Handle g_hGetStepHeight;
Handle g_hGetMaxJumpHeight;
Handle g_hGetRunSpeed;
Handle g_hGetWalkSpeed;
Handle g_hGetSpeedLimit;
Handle g_hShouldCollide;

/* IBody */
Handle g_hStartActivity;
Handle g_hGetHullWidth;
Handle g_hGetHullHeight;
Handle g_hGetStandHullHeight;
Handle g_hGetCrouchHullHeight;
Handle g_hGetHullMins;
Handle g_hGetHullMaxs;
Handle g_hGetSolidMask;

/* NextBotGroundLocomotion */
static Handle g_hSDKSetVel;
static Handle g_hSDKGetGravity;

methodmap NextBotGroundLocomotion < ILocomotion
{
	public void SetVelocity(float vecVel[3])
	{
		if (g_hSDKSetVel != INVALID_HANDLE)
			SDKCall(g_hSDKSetVel, this, vecVel);
	}
	public float GetGravity()
	{
		if (g_hSDKGetGravity != INVALID_HANDLE)
			return SDKCall(g_hSDKGetGravity, this);
		return 0.0;
	}
}

public void InitNextBotGameData(Handle hGameData)
{
	//Hook
	int iOffset = GameConfGetOffset(hGameData, "NextBotGroundLocomotion::GetGravity"); 
	g_hGetGravity = DHookCreate(iOffset, HookType_Raw, ReturnType_Float, ThisPointer_Address, GetGravity);
	
	StartPrepSDKCall(SDKCall_Raw);
	PrepSDKCall_SetFromConf(hGameData, SDKConf_Virtual, "NextBotGroundLocomotion::SetVelocity");
	PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_ByValue);
	g_hSDKSetVel = EndPrepSDKCall();
	if (g_hSDKSetVel == INVALID_HANDLE)
	{
		PrintToServer("Failed to retrieve NextBotGroundLocomotion::SetVelocity offset from SF2 gamedata!");
	}
	
	StartPrepSDKCall(SDKCall_Raw);
	PrepSDKCall_SetFromConf(hGameData, SDKConf_Virtual, "NextBotGroundLocomotion::GetGravity");
	PrepSDKCall_SetReturnInfo(SDKType_Float, SDKPass_ByValue);
	g_hSDKGetGravity = EndPrepSDKCall();
	if (g_hSDKGetGravity == INVALID_HANDLE)
	{
		PrintToServer("Failed to retrieve NextBotGroundLocomotion::GetGravity offset from SF2 gamedata!");
	}
	
	/*iOffset = GameConfGetOffset(hGameData, "ILocomotion::ClimbUpToLedge"); 
	g_hClimbUpToLedge = DHookCreate(iOffset, HookType_Raw, ReturnType_Void, ThisPointer_Address, ClimbUpToLedge);
	if (g_hClimbUpToLedge == null) SetFailState("Failed to create hook for ILocomotion::ClimbUpToLedge!");
	DHookAddParam(g_hClimbUpToLedge, HookParamType_VectorPtr);
	DHookAddParam(g_hClimbUpToLedge, HookParamType_VectorPtr);
	DHookAddParam(g_hClimbUpToLedge, HookParamType_CBaseEntity);*/
	
	/*iOffset = GameConfGetOffset(hGameData, "ILocomotion::JumpAcrossGap"); 
	g_hJumpAcrossGap = DHookCreate(iOffset, HookType_Raw, ReturnType_Void, ThisPointer_Address, ClimbUpToLedge);
	if (g_hJumpAcrossGap == null) SetFailState("Failed to create hook for ILocomotion::JumpAcrossGap!");
	DHookAddParam(g_hJumpAcrossGap, HookParamType_VectorPtr);
	DHookAddParam(g_hJumpAcrossGap, HookParamType_VectorPtr);*/

	iOffset = GameConfGetOffset(hGameData, "NextBotGroundLocomotion::GetMaxDeceleration"); 
	g_hGetMaxDeceleration = DHookCreate(iOffset, HookType_Raw, ReturnType_Float, ThisPointer_Address, GetMaxDeceleration);

	iOffset = GameConfGetOffset(hGameData, "NextBotGroundLocomotion::GetFrictionForward"); 
	g_hGetFrictionForward = DHookCreate(iOffset, HookType_Raw, ReturnType_Float, ThisPointer_Address, GetFrictionForward);
	
	iOffset = GameConfGetOffset(hGameData, "NextBotGroundLocomotion::GetFrictionSideways"); 
	g_hGetFrictionSideways = DHookCreate(iOffset, HookType_Raw, ReturnType_Float, ThisPointer_Address, GetFrictionSideways);
	
	iOffset = GameConfGetOffset(hGameData, "ILocomotion::IsAbleToClimb"); 
	g_hIsAbleToClimb = DHookCreate(iOffset, HookType_Raw, ReturnType_Bool, ThisPointer_Address, IsAbleToClimb);
	if (g_hIsAbleToClimb == null) SetFailState("Failed to create hook for ILocomotion::IsAbleToClimb!");
	
	iOffset = GameConfGetOffset(hGameData, "ILocomotion::IsAbleToJumpAcrossGaps"); 
	g_hIsAbleToJumpAcrossGaps = DHookCreate(iOffset, HookType_Raw, ReturnType_Bool, ThisPointer_Address, IsAbleToClimb);
	if (g_hIsAbleToJumpAcrossGaps == null) SetFailState("Failed to create hook for ILocomotion::IsAbleToJumpAcrossGaps!");

	iOffset = GameConfGetOffset(hGameData, "ILocomotion::GetStepHeight"); 
	g_hGetStepHeight = DHookCreate(iOffset, HookType_Raw, ReturnType_Float, ThisPointer_Address, GetStepHeight);
	if (g_hGetStepHeight == null) SetFailState("Failed to create hook for ILocomotion::GetStepHeight!");
	
	iOffset = GameConfGetOffset(hGameData, "ILocomotion::GetMaxJumpHeight"); 
	g_hGetMaxJumpHeight = DHookCreate(iOffset, HookType_Raw, ReturnType_Float, ThisPointer_Address, GetMaxJumpHeight);
	if (g_hGetMaxJumpHeight == null) SetFailState("Failed to create hook for ILocomotion::GetMaxJumpHeight!");
	
	iOffset = GameConfGetOffset(hGameData, "ILocomotion::GetMaxAcceleration"); 
	g_hGetAcceleration = DHookCreate(iOffset, HookType_Raw, ReturnType_Float, ThisPointer_Address, GetAcceleration);
	if (g_hGetAcceleration == null) SetFailState("Failed to create hook for ILocomotion::GetMaxAcceleration!");
	
	iOffset = GameConfGetOffset(hGameData, "ILocomotion::GetRunSpeed"); 
	g_hGetRunSpeed = DHookCreate(iOffset, HookType_Raw, ReturnType_Float, ThisPointer_Address, GetRunSpeed);
	if (g_hGetRunSpeed == null) SetFailState("Failed to create hook for ILocomotion::GetRunSpeed!");
	
	iOffset = GameConfGetOffset(hGameData, "ILocomotion::GetWalkSpeed"); 
	g_hGetWalkSpeed = DHookCreate(iOffset, HookType_Raw, ReturnType_Float, ThisPointer_Address, GetWalkSpeed);
	if (g_hGetWalkSpeed == null) SetFailState("Failed to create hook for ILocomotion::GetWalkSpeed!");
	
	iOffset = GameConfGetOffset(hGameData, "ILocomotion::GetSpeedLimit");
	g_hGetSpeedLimit = DHookCreate(iOffset, HookType_Raw, ReturnType_Float, ThisPointer_Address, GetSpeedLimit);
	if (g_hGetSpeedLimit == null) SetFailState("Failed to create hook for ILocomotion::GetSpeedLimit!");
	
	iOffset = GameConfGetOffset(hGameData, "ILocomotion::ShouldCollideWith");
	g_hShouldCollide = DHookCreate(iOffset, HookType_Raw, ReturnType_Bool, ThisPointer_Address, ShouldCollideWith);
	if (g_hShouldCollide == null) SetFailState("Failed to create hook for ILocomotion::ShouldCollideWith!");
	DHookAddParam(g_hShouldCollide, HookParamType_CBaseEntity);

	iOffset = GameConfGetOffset(hGameData, "IBody::StartActivity");
	g_hStartActivity = DHookCreate(iOffset, HookType_Raw, ReturnType_Bool, ThisPointer_Address, StartActivity);
	if (g_hStartActivity == null) SetFailState("Failed to create hook for IBody::StartActivity!");

	iOffset = GameConfGetOffset(hGameData, "IBody::GetHullWidth");
	if(iOffset == -1) SetFailState("Failed to get offset of IBody::GetHullWidth");
	g_hGetHullWidth = DHookCreate(iOffset, HookType_Raw, ReturnType_Float, ThisPointer_Address, GetHullWidth);
	
	iOffset = GameConfGetOffset(hGameData, "IBody::GetHullHeight");
	if(iOffset == -1) SetFailState("Failed to get offset of IBody::GetHullHeight");
	g_hGetHullHeight = DHookCreate(iOffset, HookType_Raw, ReturnType_Float, ThisPointer_Address, GetHullHeight);

	iOffset = GameConfGetOffset(hGameData, "IBody::GetStandHullHeight");
	if(iOffset == -1) SetFailState("Failed to get offset of IBody::GetStandHullHeight");
	g_hGetStandHullHeight = DHookCreate(iOffset, HookType_Raw, ReturnType_Float, ThisPointer_Address, GetStandHullHeight);

	iOffset = GameConfGetOffset(hGameData, "IBody::GetCrouchHullHeight");
	g_hGetCrouchHullHeight = DHookCreate(iOffset, HookType_Raw, ReturnType_Float, ThisPointer_Address, GetCrouchHullHeight);
	if (g_hGetCrouchHullHeight == null) SetFailState("Failed to create hook for IBody::GetCrouchHullHeight!");
	
	iOffset = GameConfGetOffset(hGameData, "IBody::GetHullMins");
	g_hGetHullMins = DHookCreate(iOffset, HookType_Raw, ReturnType_VectorPtr, ThisPointer_Address, GetHullMins);
	if (g_hGetHullMins == null) SetFailState("Failed to create hook for IBody::GetHullMins!");
	
	iOffset = GameConfGetOffset(hGameData, "IBody::GetHullMaxs");
	g_hGetHullMaxs = DHookCreate(iOffset, HookType_Raw, ReturnType_VectorPtr, ThisPointer_Address, GetHullMaxs);
	if (g_hGetHullMaxs == null) SetFailState("Failed to create hook for IBody::GetHullMaxs!");
	
	iOffset = GameConfGetOffset(hGameData, "IBody::GetSolidMask");
	g_hGetSolidMask = DHookCreate(iOffset, HookType_Raw, ReturnType_Int, ThisPointer_Address, GetSolidMask);
	if (g_hGetSolidMask == null) SetFailState("Failed to create hook for IBody::GetSolidMask!");
}