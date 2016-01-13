#if defined _sf2_npc_chaser_included
 #endinput
#endif
#define _sf2_npc_chaser_included

static Float:g_flNPCStepSize[MAX_BOSSES];

static Float:g_flNPCWalkSpeed[MAX_BOSSES][Difficulty_Max];
static Float:g_flNPCAirSpeed[MAX_BOSSES][Difficulty_Max];

static Float:g_flNPCMaxWalkSpeed[MAX_BOSSES][Difficulty_Max];
static Float:g_flNPCMaxAirSpeed[MAX_BOSSES][Difficulty_Max];

static Float:g_flNPCWakeRadius[MAX_BOSSES];

static bool:g_bNPCStunEnabled[MAX_BOSSES];
static Float:g_flNPCStunDuration[MAX_BOSSES];
static bool:g_bNPCStunFlashlightEnabled[MAX_BOSSES];
static Float:g_flNPCStunFlashlightDamage[MAX_BOSSES];
static Float:g_flNPCStunInitialHealth[MAX_BOSSES];
static Float:g_flNPCStunHealth[MAX_BOSSES];

static g_iNPCState[MAX_BOSSES] = { -1, ... };
static g_iNPCMovementActivity[MAX_BOSSES] = { -1, ... };

enum SF2NPCChaser_BaseAttackStructure
{
	SF2NPCChaser_BaseAttackType,
	Float:SF2NPCChaser_BaseAttackDamage,
	Float:SF2NPCChaser_BaseAttackDamageVsProps,
	Float:SF2NPCChaser_BaseAttackDamageForce,
	SF2NPCChaser_BaseAttackDamageType,
	Float:SF2NPCChaser_BaseAttackDamageDelay,
	Float:SF2NPCChaser_BaseAttackRange,
	Float:SF2NPCChaser_BaseAttackDuration,
	Float:SF2NPCChaser_BaseAttackSpread,
	Float:SF2NPCChaser_BaseAttackBeginRange,
	Float:SF2NPCChaser_BaseAttackBeginFOV,
	Float:SF2NPCChaser_BaseAttackCooldown,
	Float:SF2NPCChaser_BaseAttackNextAttackTime
};

static g_NPCBaseAttacks[MAX_BOSSES][SF2_CHASER_BOSS_MAX_ATTACKS][SF2NPCChaser_BaseAttackStructure];

#if defined METHODMAPS

const SF2NPC_Chaser SF2_INVALID_NPC_CHASER = SF2NPC_Chaser:-1;


methodmap SF2NPC_Chaser < SF2NPC_BaseNPC
{
	property float WakeRadius
	{
		public get() { return NPCChaserGetWakeRadius(this.Index); }
	}
	
	property float StepSize
	{
		public get() { return NPCChaserGetStepSize(this.Index); }
	}
	
	property bool StunEnabled
	{
		public get() { return NPCChaserIsStunEnabled(this.Index); }
	}
	
	property bool StunByFlashlightEnabled
	{
		public get() { return NPCChaserIsStunByFlashlightEnabled(this.Index); }
	}
	
	property float StunFlashlightDamage
	{
		public get() { return NPCChaserGetStunFlashlightDamage(this.Index); }
	}
	
	property float StunDuration
	{
		public get() { return NPCChaserGetStunDuration(this.Index); }
	}
	
	property float StunHealth
	{
		public get() { return NPCChaserGetStunHealth(this.Index); }
		public set(float amount) { NPCChaserSetStunHealth(this.Index, amount); }
	}
	
	property float StunInitialHealth
	{
		public get() { return NPCChaserGetStunInitialHealth(this.Index); }
	}
	
	property int State
	{
		public get() { return NPCChaserGetState(this.Index); }
		public set(int state) { NPCChaserSetState(this.Index, state); }
	}
	
	property int MovementActivity
	{
		public get() { return NPCChaserGetMovementActivity(this.Index); }
		public set(int movementActivity) { NPCChaserSetMovementActivity(this.Index, movementActivity); }
	}
	
	public SF2NPC_Chaser(int index)
	{
		return SF2NPC_Chaser:SF2NPC_BaseNPC(index);
	}
	
	public float GetWalkSpeed(int difficulty)
	{
		return NPCChaserGetWalkSpeed(this.Index, difficulty);
	}
	
	public void SetWalkSpeed(int difficulty, float amount)
	{
		NPCChaserSetWalkSpeed(this.Index, difficulty, amount);
	}
	
	public float GetAirSpeed(int difficulty)
	{
		return NPCChaserGetAirSpeed(this.Index, difficulty);
	}
	
	public void SetAirSpeed(int difficulty, float amount)
	{
		NPCChaserSetAirSpeed(this.Index, difficulty, amount);
	}
	
	public float GetMaxWalkSpeed(int difficulty)
	{
		return NPCChaserGetMaxWalkSpeed(this.Index, difficulty);
	}
	
	public void SetMaxWalkSpeed(int difficulty, float amount)
	{
		NPCChaserSetMaxWalkSpeed(this.Index, difficulty, amount);
	}
	
	public float GetMaxAirSpeed(int difficulty)
	{
		return NPCChaserGetMaxAirSpeed(this.Index, difficulty);
	}
	
	public void SetMaxAirSpeed(int difficulty, float amount)
	{
		NPCChaserSetMaxAirSpeed(this.Index, difficulty, amount);
	}
	
	public void AddStunHealth(float amount)
	{
		NPCChaserAddStunHealth(this.Index, amount);
	}
}

#endif

public NPCChaserInitialize()
{
	for (new iNPCIndex = 0; iNPCIndex < MAX_BOSSES; iNPCIndex++)
	{
		NPCChaserResetValues(iNPCIndex);
	}
}

Float:NPCChaserGetWalkSpeed(iNPCIndex, iDifficulty)
{
	return g_flNPCWalkSpeed[iNPCIndex][iDifficulty];
}

NPCChaserSetWalkSpeed(iNPCIndex, iDifficulty, Float:flAmount)
{
	g_flNPCWalkSpeed[iNPCIndex][iDifficulty] = flAmount;
}

Float:NPCChaserGetAirSpeed(iNPCIndex, iDifficulty)
{
	return g_flNPCAirSpeed[iNPCIndex][iDifficulty];
}

NPCChaserSetAirSpeed(iNPCIndex, iDifficulty, Float:flAmount)
{
	g_flNPCAirSpeed[iNPCIndex][iDifficulty] = flAmount;
}

Float:NPCChaserGetMaxWalkSpeed(iNPCIndex, iDifficulty)
{
	return g_flNPCMaxWalkSpeed[iNPCIndex][iDifficulty];
}

NPCChaserSetMaxWalkSpeed(iNPCIndex, iDifficulty, Float:flAmount)
{
	g_flNPCMaxWalkSpeed[iNPCIndex][iDifficulty] = flAmount;
}

Float:NPCChaserGetMaxAirSpeed(iNPCIndex, iDifficulty)
{
	return g_flNPCMaxAirSpeed[iNPCIndex][iDifficulty];
}

NPCChaserSetMaxAirSpeed(iNPCIndex, iDifficulty, Float:flAmount)
{
	g_flNPCMaxAirSpeed[iNPCIndex][iDifficulty] = flAmount;
}

Float:NPCChaserGetWakeRadius(iNPCIndex)
{
	return g_flNPCWakeRadius[iNPCIndex];
}

Float:NPCChaserGetStepSize(iNPCIndex)
{
	return g_flNPCStepSize[iNPCIndex];
}

NPCChaserGetAttackType(iNPCIndex, iAttackIndex)
{
	return g_NPCBaseAttacks[iNPCIndex][iAttackIndex][SF2NPCChaser_BaseAttackType];
}

Float:NPCChaserGetAttackDamage(iNPCIndex, iAttackIndex)
{
	return g_NPCBaseAttacks[iNPCIndex][iAttackIndex][SF2NPCChaser_BaseAttackDamage];
}

Float:NPCChaserGetAttackDamageVsProps(iNPCIndex, iAttackIndex)
{
	return g_NPCBaseAttacks[iNPCIndex][iAttackIndex][SF2NPCChaser_BaseAttackDamageVsProps];
}

Float:NPCChaserGetAttackDamageForce(iNPCIndex, iAttackIndex)
{
	return g_NPCBaseAttacks[iNPCIndex][iAttackIndex][SF2NPCChaser_BaseAttackDamageForce];
}

NPCChaserGetAttackDamageType(iNPCIndex, iAttackIndex)
{
	return g_NPCBaseAttacks[iNPCIndex][iAttackIndex][SF2NPCChaser_BaseAttackDamageType];
}

Float:NPCChaserGetAttackDamageDelay(iNPCIndex, iAttackIndex)
{
	return g_NPCBaseAttacks[iNPCIndex][iAttackIndex][SF2NPCChaser_BaseAttackDamageDelay];
}

Float:NPCChaserGetAttackRange(iNPCIndex, iAttackIndex)
{
	return g_NPCBaseAttacks[iNPCIndex][iAttackIndex][SF2NPCChaser_BaseAttackRange];
}

Float:NPCChaserGetAttackDuration(iNPCIndex, iAttackIndex)
{
	return g_NPCBaseAttacks[iNPCIndex][iAttackIndex][SF2NPCChaser_BaseAttackDuration];
}

Float:NPCChaserGetAttackSpread(iNPCIndex, iAttackIndex)
{
	return g_NPCBaseAttacks[iNPCIndex][iAttackIndex][SF2NPCChaser_BaseAttackSpread];
}

Float:NPCChaserGetAttackBeginRange(iNPCIndex, iAttackIndex)
{
	return g_NPCBaseAttacks[iNPCIndex][iAttackIndex][SF2NPCChaser_BaseAttackBeginRange];
}

Float:NPCChaserGetAttackBeginFOV(iNPCIndex, iAttackIndex)
{
	return g_NPCBaseAttacks[iNPCIndex][iAttackIndex][SF2NPCChaser_BaseAttackBeginFOV];
}

bool:NPCChaserIsStunEnabled(iNPCIndex)
{
	return g_bNPCStunEnabled[iNPCIndex];
}

bool:NPCChaserIsStunByFlashlightEnabled(iNPCIndex)
{
	return g_bNPCStunFlashlightEnabled[iNPCIndex];
}

Float:NPCChaserGetStunFlashlightDamage(iNPCIndex)
{
	return g_flNPCStunFlashlightDamage[iNPCIndex];
}

Float:NPCChaserGetStunDuration(iNPCIndex)
{
	return g_flNPCStunDuration[iNPCIndex];
}

Float:NPCChaserGetStunHealth(iNPCIndex)
{
	return g_flNPCStunHealth[iNPCIndex];
}

NPCChaserSetStunHealth(iNPCIndex, Float:flAmount)
{
	g_flNPCStunHealth[iNPCIndex] = flAmount;
}

NPCChaserAddStunHealth(iNPCIndex, Float:flAmount)
{
	NPCChaserSetStunHealth(iNPCIndex, NPCChaserGetStunHealth(iNPCIndex) + flAmount);
}

Float:NPCChaserGetStunInitialHealth(iNPCIndex)
{
	return g_flNPCStunInitialHealth[iNPCIndex];
}

NPCChaserGetState(iNPCIndex)
{
	return g_iNPCState[iNPCIndex];
}

NPCChaserSetState(iNPCIndex, iState)
{
	g_iNPCState[iNPCIndex] = iState;
}

NPCChaserGetMovementActivity(iNPCIndex)
{
	return g_iNPCMovementActivity[iNPCIndex];
}

NPCChaserSetMovementActivity(iNPCIndex, iMovementActivity)
{
	g_iNPCMovementActivity[iNPCIndex] = iMovementActivity;
}

NPCChaserOnSelectProfile(iNPCIndex)
{
	new iUniqueProfileIndex = NPCGetUniqueProfileIndex(iNPCIndex);

	g_flNPCWakeRadius[iNPCIndex] = GetChaserProfileWakeRadius(iUniqueProfileIndex);
	g_flNPCStepSize[iNPCIndex] = GetChaserProfileStepSize(iUniqueProfileIndex);
	
	for (new iDifficulty = 0; iDifficulty < Difficulty_Max; iDifficulty++)
	{
		g_flNPCWalkSpeed[iNPCIndex][iDifficulty] = GetChaserProfileWalkSpeed(iUniqueProfileIndex, iDifficulty);
		g_flNPCAirSpeed[iNPCIndex][iDifficulty] = GetChaserProfileAirSpeed(iUniqueProfileIndex, iDifficulty);
		
		g_flNPCMaxWalkSpeed[iNPCIndex][iDifficulty] = GetChaserProfileMaxWalkSpeed(iUniqueProfileIndex, iDifficulty);
		g_flNPCMaxAirSpeed[iNPCIndex][iDifficulty] = GetChaserProfileMaxAirSpeed(iUniqueProfileIndex, iDifficulty);
	}
	
	// Get attack data.
	for (new i = 0; i < GetChaserProfileAttackCount(iUniqueProfileIndex); i++)
	{
		g_NPCBaseAttacks[iNPCIndex][i][SF2NPCChaser_BaseAttackType] = GetChaserProfileAttackType(iUniqueProfileIndex, i);
		g_NPCBaseAttacks[iNPCIndex][i][SF2NPCChaser_BaseAttackDamage] = GetChaserProfileAttackDamage(iUniqueProfileIndex, i);
		g_NPCBaseAttacks[iNPCIndex][i][SF2NPCChaser_BaseAttackDamageVsProps] = GetChaserProfileAttackDamageVsProps(iUniqueProfileIndex, i);
		g_NPCBaseAttacks[iNPCIndex][i][SF2NPCChaser_BaseAttackDamageForce] = GetChaserProfileAttackDamageForce(iUniqueProfileIndex, i);
		g_NPCBaseAttacks[iNPCIndex][i][SF2NPCChaser_BaseAttackDamageType] = GetChaserProfileAttackDamageType(iUniqueProfileIndex, i);
		g_NPCBaseAttacks[iNPCIndex][i][SF2NPCChaser_BaseAttackDamageDelay] = GetChaserProfileAttackDamageDelay(iUniqueProfileIndex, i);
		g_NPCBaseAttacks[iNPCIndex][i][SF2NPCChaser_BaseAttackRange] = GetChaserProfileAttackRange(iUniqueProfileIndex, i);
		g_NPCBaseAttacks[iNPCIndex][i][SF2NPCChaser_BaseAttackDuration] = GetChaserProfileAttackDuration(iUniqueProfileIndex, i);
		g_NPCBaseAttacks[iNPCIndex][i][SF2NPCChaser_BaseAttackSpread] = GetChaserProfileAttackSpread(iUniqueProfileIndex, i);
		g_NPCBaseAttacks[iNPCIndex][i][SF2NPCChaser_BaseAttackBeginRange] = GetChaserProfileAttackBeginRange(iUniqueProfileIndex, i);
		g_NPCBaseAttacks[iNPCIndex][i][SF2NPCChaser_BaseAttackBeginFOV] = GetChaserProfileAttackBeginFOV(iUniqueProfileIndex, i);
		g_NPCBaseAttacks[iNPCIndex][i][SF2NPCChaser_BaseAttackCooldown] = GetChaserProfileAttackCooldown(iUniqueProfileIndex, i);
		g_NPCBaseAttacks[iNPCIndex][i][SF2NPCChaser_BaseAttackNextAttackTime] = -1.0;
	}
	
	// Get stun data.
	g_bNPCStunEnabled[iNPCIndex] = GetChaserProfileStunState(iUniqueProfileIndex);
	g_flNPCStunDuration[iNPCIndex] = GetChaserProfileStunDuration(iUniqueProfileIndex);
	g_bNPCStunFlashlightEnabled[iNPCIndex] = GetChaserProfileStunFlashlightState(iUniqueProfileIndex);
	g_flNPCStunFlashlightDamage[iNPCIndex] = GetChaserProfileStunFlashlightDamage(iUniqueProfileIndex);
	g_flNPCStunInitialHealth[iNPCIndex] = GetChaserProfileStunHealth(iUniqueProfileIndex);
	
	NPCChaserSetStunHealth(iNPCIndex, NPCChaserGetStunInitialHealth(iNPCIndex));
}

NPCChaserOnRemoveProfile(iNPCIndex)
{
	NPCChaserResetValues(iNPCIndex);
}

/**
 *	Resets all global variables on a specified NPC. Usually this should be done last upon removing a boss from the game.
 */
static NPCChaserResetValues(iNPCIndex)
{
	g_flNPCWakeRadius[iNPCIndex] = 0.0;
	g_flNPCStepSize[iNPCIndex] = 0.0;
	
	for (new iDifficulty = 0; iDifficulty < Difficulty_Max; iDifficulty++)
	{
		g_flNPCWalkSpeed[iNPCIndex][iDifficulty] = 0.0;
		g_flNPCAirSpeed[iNPCIndex][iDifficulty] = 0.0;
		
		g_flNPCMaxWalkSpeed[iNPCIndex][iDifficulty] = 0.0;
		g_flNPCMaxAirSpeed[iNPCIndex][iDifficulty] = 0.0;
	}
	
	// Clear attack data.
	for (new i = 0; i < SF2_CHASER_BOSS_MAX_ATTACKS; i++)
	{
		// Base attack data.
		g_NPCBaseAttacks[iNPCIndex][i][SF2NPCChaser_BaseAttackType] = SF2BossAttackType_Invalid;
		g_NPCBaseAttacks[iNPCIndex][i][SF2NPCChaser_BaseAttackDamage] = 0.0;
		g_NPCBaseAttacks[iNPCIndex][i][SF2NPCChaser_BaseAttackDamageVsProps] = 0.0;
		g_NPCBaseAttacks[iNPCIndex][i][SF2NPCChaser_BaseAttackDamageForce] = 0.0;
		g_NPCBaseAttacks[iNPCIndex][i][SF2NPCChaser_BaseAttackDamageType] = 0;
		g_NPCBaseAttacks[iNPCIndex][i][SF2NPCChaser_BaseAttackDamageDelay] = 0.0;
		g_NPCBaseAttacks[iNPCIndex][i][SF2NPCChaser_BaseAttackRange] = 0.0;
		g_NPCBaseAttacks[iNPCIndex][i][SF2NPCChaser_BaseAttackDuration] = 0.0;
		g_NPCBaseAttacks[iNPCIndex][i][SF2NPCChaser_BaseAttackSpread] = 0.0;
		g_NPCBaseAttacks[iNPCIndex][i][SF2NPCChaser_BaseAttackBeginRange] = 0.0;
		g_NPCBaseAttacks[iNPCIndex][i][SF2NPCChaser_BaseAttackBeginFOV] = 0.0;
		g_NPCBaseAttacks[iNPCIndex][i][SF2NPCChaser_BaseAttackCooldown] = 0.0;
		g_NPCBaseAttacks[iNPCIndex][i][SF2NPCChaser_BaseAttackNextAttackTime] = -1.0;
	}
	
	g_bNPCStunEnabled[iNPCIndex] = false;
	g_flNPCStunDuration[iNPCIndex] = 0.0;
	g_bNPCStunFlashlightEnabled[iNPCIndex] = false;
	g_flNPCStunInitialHealth[iNPCIndex] = 0.0;
	
	NPCChaserSetStunHealth(iNPCIndex, 0.0);
	
	g_iNPCState[iNPCIndex] = -1;
	g_iNPCMovementActivity[iNPCIndex] = -1;
}

//	So this is how the thought process of the bosses should go.
//	1. Search for enemy; either by sight or by sound.
//		- Any noticeable sounds should be investigated.
//		- Too many sounds will put me in alert mode.
//	2. Alert of an enemy; I saw something or I heard something unusual
//		- Go to the position where I last heard the sound.
//		- Keep on searching until I give up. Then drop back to idle mode.
//	3. Found an enemy! Give chase!
//		- Keep on chasing until enemy is killed or I give up.
//			- Keep a path in memory as long as I still have him in my sights.
//			- If I lose sight or I'm unable to traverse safely, find paths around obstacles and follow memorized path.
//			- If I reach the end of my path and I still don't see him and I still want to pursue him, keep on going in the direction I'm going.

stock bool:IsTargetValidForSlender(iTarget, bool:bIncludeEliminated=false)
{
	if (!iTarget || !IsValidEntity(iTarget)) return false;
	
	if (IsValidClient(iTarget))
	{
		if (!IsClientInGame(iTarget) || 
			!IsPlayerAlive(iTarget) || 
			IsClientInDeathCam(iTarget) || 
			(!bIncludeEliminated && g_bPlayerEliminated[iTarget]) ||
			IsClientInGhostMode(iTarget) || 
			DidClientEscape(iTarget)) return false;
	}
	
	return true;
}

public Action:Timer_SlenderChaseBossThink(Handle:timer, any:entref)
{
	if (!g_bEnabled) return Plugin_Stop;

	new slender = EntRefToEntIndex(entref);
	if (!slender || slender == INVALID_ENT_REFERENCE) return Plugin_Stop;
	
	new iBossIndex = NPCGetFromEntIndex(slender);
	if (iBossIndex == -1) return Plugin_Stop;
	
	if (timer != g_hSlenderEntityThink[iBossIndex]) return Plugin_Stop;
	
	if (NPCGetFlags(iBossIndex) & SFF_MARKEDASFAKE) return Plugin_Stop;
	
	decl Float:flSlenderVelocity[3], Float:flMyPos[3], Float:flMyEyeAng[3];
	new Float:flBuffer[3];
	
	decl String:sSlenderProfile[SF2_MAX_PROFILE_NAME_LENGTH];
	NPCGetProfile(iBossIndex, sSlenderProfile, sizeof(sSlenderProfile));
	
	GetEntPropVector(slender, Prop_Data, "m_vecAbsVelocity", flSlenderVelocity);
	GetEntPropVector(slender, Prop_Data, "m_vecAbsOrigin", flMyPos);
	GetEntPropVector(slender, Prop_Data, "m_angAbsRotation", flMyEyeAng);
	AddVectors(flMyEyeAng, g_flSlenderEyeAngOffset[iBossIndex], flMyEyeAng);
	for (new i = 0; i < 3; i++) flMyEyeAng[i] = AngleNormalize(flMyEyeAng[i]);
	
	new iDifficulty = GetConVarInt(g_cvDifficulty);
	
	new Float:flVelocityRatio;
	new Float:flVelocityRatioWalk;
	
	new Float:flOriginalSpeed = NPCGetSpeed(iBossIndex, iDifficulty);
	new Float:flOriginalWalkSpeed = NPCChaserGetWalkSpeed(iBossIndex, iDifficulty);
	new Float:flMaxSpeed = NPCGetMaxSpeed(iBossIndex, iDifficulty);
	new Float:flMaxWalkSpeed = NPCChaserGetMaxWalkSpeed(iBossIndex, iDifficulty);
	
	new Float:flSpeed = flOriginalSpeed * NPCGetAnger(iBossIndex) * g_flRoundDifficultyModifier;
	if (flSpeed < flOriginalSpeed) flSpeed = flOriginalSpeed;
	if (flSpeed > flMaxSpeed) flSpeed = flMaxSpeed;
	
	new Float:flWalkSpeed = flOriginalWalkSpeed * NPCGetAnger(iBossIndex) * g_flRoundDifficultyModifier;
	if (flWalkSpeed < flOriginalWalkSpeed) flWalkSpeed = flOriginalWalkSpeed;
	if (flWalkSpeed > flMaxWalkSpeed) flWalkSpeed = flMaxWalkSpeed;
	
	if (PeopleCanSeeSlender(iBossIndex, _, false))
	{
		if (NPCHasAttribute(iBossIndex, "reduced speed on look"))
		{
			flSpeed *= NPCGetAttributeValue(iBossIndex, "reduced speed on look");
		}
		
		if (NPCHasAttribute(iBossIndex, "reduced walk speed on look"))
		{
			flWalkSpeed *= NPCGetAttributeValue(iBossIndex, "reduced walk speed on look");
		}
	}
	
	g_flSlenderCalculatedWalkSpeed[iBossIndex] = flWalkSpeed;
	g_flSlenderCalculatedSpeed[iBossIndex] = flSpeed;
	
	if (flOriginalSpeed <= 0.0) flVelocityRatio = 0.0;
	else flVelocityRatio = GetVectorLength(flSlenderVelocity) / flOriginalSpeed;
	
	if (flOriginalWalkSpeed <= 0.0) flVelocityRatioWalk = 0.0;
	else flVelocityRatioWalk = GetVectorLength(flSlenderVelocity) / flOriginalWalkSpeed;
	
	new Float:flAttackRange = NPCChaserGetAttackRange(iBossIndex, 0);
	new Float:flAttackFOV = NPCChaserGetAttackSpread(iBossIndex, 0);
	new Float:flAttackBeginRange = NPCChaserGetAttackBeginRange(iBossIndex, 0);
	new Float:flAttackBeginFOV = NPCChaserGetAttackBeginFOV(iBossIndex, 0);
	
	
	new iOldState = g_iSlenderState[iBossIndex];
	new iOldTarget = EntRefToEntIndex(g_iSlenderTarget[iBossIndex]);
	
	new iBestNewTarget = INVALID_ENT_REFERENCE;
	new Float:flSearchRange = NPCGetSearchRadius(iBossIndex);
	new Float:flBestNewTargetDist = flSearchRange;
	new iState = iOldState;
	
	new bool:bPlayerInFOV[MAXPLAYERS + 1];
	new bool:bPlayerNear[MAXPLAYERS + 1];
	new Float:flPlayerDists[MAXPLAYERS + 1];
	new bool:bPlayerVisible[MAXPLAYERS + 1];
	
	new bool:bAttackEliminated = bool:(NPCGetFlags(iBossIndex) & SFF_ATTACKWAITERS);
	new bool:bStunEnabled = NPCChaserIsStunEnabled(iBossIndex);
	
	decl Float:flSlenderMins[3], Float:flSlenderMaxs[3];
	GetEntPropVector(slender, Prop_Send, "m_vecMins", flSlenderMins);
	GetEntPropVector(slender, Prop_Send, "m_vecMaxs", flSlenderMaxs);
	
	decl Float:flTraceMins[3], Float:flTraceMaxs[3];
	flTraceMins[0] = flSlenderMins[0];
	flTraceMins[1] = flSlenderMins[1];
	flTraceMins[2] = 0.0;
	flTraceMaxs[0] = flSlenderMaxs[0];
	flTraceMaxs[1] = flSlenderMaxs[1];
	flTraceMaxs[2] = 0.0;
	
	// Gather data about the players around me and get the best new target, in case my old target is invalidated.
	for (new i = 1; i <= MaxClients; i++)
	{
		if (!IsTargetValidForSlender(i, bAttackEliminated)) continue;
		
		decl Float:flTraceStartPos[3], Float:flTraceEndPos[3];
		NPCGetEyePosition(iBossIndex, flTraceStartPos);
		GetClientEyePosition(i, flTraceEndPos);
		
		new Handle:hTrace = TR_TraceHullFilterEx(flTraceStartPos,
			flTraceEndPos,
			flTraceMins,
			flTraceMaxs,
			MASK_NPCSOLID,
			TraceRayBossVisibility,
			slender);
		
		new bool:bIsVisible = !TR_DidHit(hTrace);
		new iTraceHitEntity = TR_GetEntityIndex(hTrace);
		CloseHandle(hTrace);
		
		if (!bIsVisible && iTraceHitEntity == i) bIsVisible = true;
		
		bPlayerVisible[i] = bIsVisible;
		
		// Near radius check.
		if (bIsVisible &&
			GetVectorDistance(flTraceStartPos, flTraceEndPos) <= NPCChaserGetWakeRadius(iBossIndex))
		{
			bPlayerNear[i] = true;
		}
		
		// FOV check.
		SubtractVectors(flTraceEndPos, flTraceStartPos, flBuffer);
		GetVectorAngles(flBuffer, flBuffer);
		
		if (FloatAbs(AngleDiff(flMyEyeAng[1], flBuffer[1])) <= (NPCGetFOV(iBossIndex) * 0.5))
		{
			bPlayerInFOV[i] = true;
		}
		
		new Float:flDist;
		new Float:flPriorityValue = g_iPageMax > 0 ? (float(g_iPlayerPageCount[i]) / float(g_iPageMax)) : 0.0;
		
		if (TF2_GetPlayerClass(i) == TFClass_Medic) flPriorityValue += 0.72;
		
		flDist = GetVectorDistance(flTraceStartPos, flTraceEndPos);
		flPlayerDists[i] = flDist;
		
		if ((bPlayerNear[i] && iState != STATE_CHASE && iState != STATE_ALERT) || (bIsVisible && bPlayerInFOV[i]))
		{
			decl Float:flTargetPos[3];
			GetClientAbsOrigin(i, flTargetPos);
			
			if (flDist <= flSearchRange)
			{
				// Subtract distance to increase priority.
				flDist -= (flDist * flPriorityValue);
				
				if (flDist < flBestNewTargetDist)
				{
					iBestNewTarget = i;
					flBestNewTargetDist = flDist;
					g_iSlenderInterruptConditions[iBossIndex] |= COND_SAWENEMY;
				}
				
				g_flSlenderLastFoundPlayer[iBossIndex][i] = GetGameTime();
				g_flSlenderLastFoundPlayerPos[iBossIndex][i][0] = flTargetPos[0];
				g_flSlenderLastFoundPlayerPos[iBossIndex][i][1] = flTargetPos[1];
				g_flSlenderLastFoundPlayerPos[iBossIndex][i][2] = flTargetPos[2];
			}
		}
	}
	
	new bool:bInFlashlight = false;
	
	// Check to see if someone is facing at us with flashlight on. Only if I'm facing them too. BLINDNESS!
	for (new i = 1; i <= MaxClients; i++)
	{
		if (!IsTargetValidForSlender(i, bAttackEliminated)) continue;
	
		if (!IsClientUsingFlashlight(i) || !bPlayerInFOV[i]) continue;
		
		decl Float:flTraceStartPos[3], Float:flTraceEndPos[3];
		GetClientEyePosition(i, flTraceStartPos);
		NPCGetEyePosition(iBossIndex, flTraceEndPos);
		
		if (GetVectorDistance(flTraceStartPos, flTraceEndPos) <= SF2_FLASHLIGHT_LENGTH)
		{
			decl Float:flEyeAng[3], Float:flRequiredAng[3];
			GetClientEyeAngles(i, flEyeAng);
			SubtractVectors(flTraceEndPos, flTraceStartPos, flRequiredAng);
			GetVectorAngles(flRequiredAng, flRequiredAng);
			
			if ((FloatAbs(AngleDiff(flEyeAng[0], flRequiredAng[0])) + FloatAbs(AngleDiff(flEyeAng[1], flRequiredAng[1]))) <= 45.0)
			{
				new Handle:hTrace = TR_TraceRayFilterEx(flTraceStartPos,
					flTraceEndPos,
					MASK_PLAYERSOLID,
					RayType_EndPoint,
					TraceRayBossVisibility,
					slender);
					
				new bool:bDidHit = TR_DidHit(hTrace);
				CloseHandle(hTrace);
				
				if (!bDidHit)
				{
					bInFlashlight = true;
					break;
				}
			}
		}
	}
	
	// Damage us if we're in a flashlight.
	if (bInFlashlight)
	{
		if (bStunEnabled)
		{
			if (NPCChaserIsStunByFlashlightEnabled(iBossIndex))
			{
				if (NPCChaserGetStunHealth(iBossIndex) > 0)
				{
					NPCChaserAddStunHealth(iBossIndex, -NPCChaserGetStunFlashlightDamage(iBossIndex));
				}
			}
		}
	}
	
	// Process the target that we should have.
	new iTarget = iOldTarget;
	
	/*
	if (IsValidEdict(iBestNewTarget))
	{
		iTarget = iBestNewTarget;
		g_iSlenderTarget[iBossIndex] = EntIndexToEntRef(iBestNewTarget);
	}
	*/
	
	if (iTarget && iTarget != INVALID_ENT_REFERENCE)
	{
		if (!IsTargetValidForSlender(iTarget, bAttackEliminated))
		{
			// Clear our target; he's not valid anymore.
			iOldTarget = iTarget;
			iTarget = INVALID_ENT_REFERENCE;
			g_iSlenderTarget[iBossIndex] = INVALID_ENT_REFERENCE;
		}
	}
	else
	{
		// Clear our target; he's not valid anymore.
		iOldTarget = iTarget;
		iTarget = INVALID_ENT_REFERENCE;
		g_iSlenderTarget[iBossIndex] = INVALID_ENT_REFERENCE;
	}
	
	new iInterruptConditions = g_iSlenderInterruptConditions[iBossIndex];
	new bool:bQueueForNewPath = false;
	
	// Process which state we should be in.
	switch (iState)
	{
		case STATE_IDLE, STATE_WANDER:
		{
			if (iState == STATE_WANDER)
			{
				if (GetArraySize(g_hSlenderPath[iBossIndex]) <= 0)
				{
					iState = STATE_IDLE;
				}
			}
			else
			{
				if (GetGameTime() >= g_flSlenderNextWanderPos[iBossIndex] && GetRandomFloat(0.0, 1.0) <= 0.25)
				{
					iState = STATE_WANDER;
				}
			}
			if (g_iSpecialRoundType == SPECIALROUND_BEACON || g_iSpecialRoundType2 == SPECIALROUND_BEACON)
			{
				if(!g_bSlenderInBacon[iBossIndex])
				{
					iState = STATE_ALERT;
					g_bSlenderInBacon[iBossIndex] = true;
				}
			}
			if (iInterruptConditions & COND_SAWENEMY)
			{
				// I saw someone over here. Automatically put me into alert mode.
				iState = STATE_ALERT;
			}
			else if (iInterruptConditions & COND_HEARDSUSPICIOUSSOUND)
			{
				// Sound counts:
				// +1 will be added if it hears a footstep.
				// +2 will be added if the footstep is someone sprinting.
				// +5 will be added if the sound is from a player's weapon hitting an object.
				// +10 will be added if a voice command is heard.
				//
				// Sound counts will be reset after the boss hears a sound after a certain amount of time.
				// The purpose of sound counts is to induce boss focusing on sounds suspicious entities are making.
				
				new iCount = 0;
				if (iInterruptConditions & COND_HEARDFOOTSTEP) iCount += 1;
				if (iInterruptConditions & COND_HEARDFOOTSTEPLOUD) iCount += 2;
				if (iInterruptConditions & COND_HEARDWEAPON) iCount += 5;
				if (iInterruptConditions & COND_HEARDVOICE) iCount += 10;
				
				new bool:bDiscardMasterPos = bool:(GetGameTime() >= g_flSlenderTargetSoundDiscardMasterPosTime[iBossIndex]);
				
				if (GetVectorDistance(g_flSlenderTargetSoundTempPos[iBossIndex], g_flSlenderTargetSoundMasterPos[iBossIndex]) <= GetProfileFloat(sSlenderProfile, "search_sound_pos_dist_tolerance", 512.0) ||
					bDiscardMasterPos)
				{
					if (bDiscardMasterPos) g_iSlenderTargetSoundCount[iBossIndex] = 0;
					
					g_flSlenderTargetSoundDiscardMasterPosTime[iBossIndex] = GetGameTime() + GetProfileFloat(sSlenderProfile, "search_sound_pos_discard_time", 2.0);
					g_flSlenderTargetSoundMasterPos[iBossIndex][0] = g_flSlenderTargetSoundTempPos[iBossIndex][0];
					g_flSlenderTargetSoundMasterPos[iBossIndex][1] = g_flSlenderTargetSoundTempPos[iBossIndex][1];
					g_flSlenderTargetSoundMasterPos[iBossIndex][2] = g_flSlenderTargetSoundTempPos[iBossIndex][2];
					g_iSlenderTargetSoundCount[iBossIndex] += iCount;
				}
				
				if (g_iSlenderTargetSoundCount[iBossIndex] >= GetProfileNum(sSlenderProfile, "search_sound_count_until_alert", 4))
				{
					// Someone's making some noise over there! Time to investigate.
					g_bSlenderInvestigatingSound[iBossIndex] = true; // This is just so that our sound position would be the goal position.
					iState = STATE_ALERT;
				}
			}
		}
		case STATE_ALERT:
		{
			if (GetArraySize(g_hSlenderPath[iBossIndex]) <= 0)
			{
				// Fully navigated through our path.
				iState = STATE_IDLE;
			}
			else if (GetGameTime() >= g_flSlenderTimeUntilIdle[iBossIndex])
			{
				iState = STATE_IDLE;
			}
			else if (IsValidClient(iBestNewTarget))
			{
				if (GetGameTime() >= g_flSlenderTimeUntilChase[iBossIndex] || bPlayerNear[iBestNewTarget])
				{
					decl Float:flTraceStartPos[3], Float:flTraceEndPos[3];
					NPCGetEyePosition(iBossIndex, flTraceStartPos);
					
					if (IsValidClient(iBestNewTarget)) GetClientEyePosition(iBestNewTarget, flTraceEndPos);
					else
					{
						decl Float:flTargetMins[3], Float:flTargetMaxs[3];
						GetEntPropVector(iBestNewTarget, Prop_Send, "m_vecMins", flTargetMins);
						GetEntPropVector(iBestNewTarget, Prop_Send, "m_vecMaxs", flTargetMaxs);
						GetEntPropVector(iBestNewTarget, Prop_Data, "m_vecAbsOrigin", flTraceEndPos);
						for (new i = 0; i < 3; i++) flTraceEndPos[i] += ((flTargetMins[i] + flTargetMaxs[i]) / 2.0);
					}
					
					new Handle:hTrace = TR_TraceHullFilterEx(flTraceStartPos,
						flTraceEndPos,
						flTraceMins,
						flTraceMaxs,
						MASK_NPCSOLID,
						TraceRayBossVisibility,
						slender);
						
					new bool:bIsVisible = !TR_DidHit(hTrace);
					new iTraceHitEntity = TR_GetEntityIndex(hTrace);
					CloseHandle(hTrace);
					
					if (!bIsVisible && iTraceHitEntity == iBestNewTarget) bIsVisible = true;
					
					if ((bPlayerNear[iBestNewTarget] || bPlayerInFOV[iBestNewTarget]) && bPlayerVisible[iBestNewTarget])
					{
						// AHAHAHAH! I GOT YOU NOW!
						iTarget = iBestNewTarget;
						g_iSlenderTarget[iBossIndex] = EntIndexToEntRef(iBestNewTarget);
						iState = STATE_CHASE;
					}
				}
			}
			else
			{
				if (iInterruptConditions & COND_SAWENEMY)
				{
					if (IsValidClient(iBestNewTarget))
					{
						g_flSlenderGoalPos[iBossIndex][0] = g_flSlenderLastFoundPlayerPos[iBossIndex][iBestNewTarget][0];
						g_flSlenderGoalPos[iBossIndex][1] = g_flSlenderLastFoundPlayerPos[iBossIndex][iBestNewTarget][1];
						g_flSlenderGoalPos[iBossIndex][2] = g_flSlenderLastFoundPlayerPos[iBossIndex][iBestNewTarget][2];
						
						bQueueForNewPath = true;
					}
				}
				else if (iInterruptConditions & COND_HEARDSUSPICIOUSSOUND)
				{
					new bool:bDiscardMasterPos = bool:(GetGameTime() >= g_flSlenderTargetSoundDiscardMasterPosTime[iBossIndex]);
					
					if (GetVectorDistance(g_flSlenderTargetSoundTempPos[iBossIndex], g_flSlenderTargetSoundMasterPos[iBossIndex]) <= GetProfileFloat(sSlenderProfile, "search_sound_pos_dist_tolerance", 512.0) ||
						bDiscardMasterPos)
					{
						g_flSlenderTargetSoundDiscardMasterPosTime[iBossIndex] = GetGameTime() + GetProfileFloat(sSlenderProfile, "search_sound_pos_discard_time", 2.0);
						g_flSlenderTargetSoundMasterPos[iBossIndex][0] = g_flSlenderTargetSoundTempPos[iBossIndex][0];
						g_flSlenderTargetSoundMasterPos[iBossIndex][1] = g_flSlenderTargetSoundTempPos[iBossIndex][1];
						g_flSlenderTargetSoundMasterPos[iBossIndex][2] = g_flSlenderTargetSoundTempPos[iBossIndex][2];
						
						// We have to manually set the goal position here because the goal position will not be changed due to no change in state.
						g_flSlenderGoalPos[iBossIndex][0] = g_flSlenderTargetSoundMasterPos[iBossIndex][0];
						g_flSlenderGoalPos[iBossIndex][1] = g_flSlenderTargetSoundMasterPos[iBossIndex][1];
						g_flSlenderGoalPos[iBossIndex][2] = g_flSlenderTargetSoundMasterPos[iBossIndex][2];
						
						g_bSlenderInvestigatingSound[iBossIndex] = true;
						
						bQueueForNewPath = true;
					}
				}
				
				new bool:bBlockingProp = false;
				
				if (NPCGetFlags(iBossIndex) & SFF_ATTACKPROPS)
				{
					new prop = -1;
					while ((prop = FindEntityByClassname(prop, "prop_physics")) != -1)
					{
						if (NPCAttackValidateTarget(iBossIndex, prop, flAttackRange, flAttackFOV))
						{
							if(NPCPropPhysicsAttack(iBossIndex, prop))
							{
								bBlockingProp = true;
								break;
							}
						}
					}
					
					if (!bBlockingProp)
					{
						prop = -1;
						while ((prop = FindEntityByClassname(prop, "prop_dynamic")) != -1)
						{
							if (GetEntProp(prop, Prop_Data, "m_iHealth") > 0)
							{
								if (NPCAttackValidateTarget(iBossIndex, prop, flAttackRange, flAttackFOV))
								{
									if(NPCPropPhysicsAttack(iBossIndex, prop))
									{
										bBlockingProp = true;
										break;
									}
								}
							}
						}
					}
				}
				
				if (bBlockingProp)
				{
					//PrintToChatAll("A prop is blocking me let's attack it");
					iState = STATE_ATTACK;
				}
			}
		}
		case STATE_CHASE, STATE_ATTACK, STATE_STUN:
		{
			if (iState == STATE_CHASE)
			{
				if (IsValidEdict(iTarget))
				{
					decl Float:flTraceStartPos[3], Float:flTraceEndPos[3];
					NPCGetEyePosition(iBossIndex, flTraceStartPos);
					
					if (IsValidClient(iTarget))
					{
						GetClientEyePosition(iTarget, flTraceEndPos);
					}
					else
					{
						decl Float:flTargetMins[3], Float:flTargetMaxs[3];
						GetEntPropVector(iTarget, Prop_Send, "m_vecMins", flTargetMins);
						GetEntPropVector(iTarget, Prop_Send, "m_vecMaxs", flTargetMaxs);
						GetEntPropVector(iTarget, Prop_Data, "m_vecAbsOrigin", flTraceEndPos);
						for (new i = 0; i < 3; i++) flTraceEndPos[i] += ((flTargetMins[i] + flTargetMaxs[i]) / 2.0);
					}
					
					new bool:bIsDeathPosVisible = false;
					
					if (g_bSlenderChaseDeathPosition[iBossIndex])
					{
						new Handle:hTrace = TR_TraceRayFilterEx(flTraceStartPos,
							g_flSlenderChaseDeathPosition[iBossIndex],
							MASK_NPCSOLID,
							RayType_EndPoint,
							TraceRayBossVisibility,
							slender);
						bIsDeathPosVisible = !TR_DidHit(hTrace);
						CloseHandle(hTrace);
					}
					
					if (!bPlayerVisible[iTarget])
					{
						if (GetArraySize(g_hSlenderPath[iBossIndex]) == 0)
						{
							iState = STATE_IDLE;
						}
						else if (GetGameTime() >= g_flSlenderTimeUntilAlert[iBossIndex])
						{
							iState = STATE_ALERT;
						}
						else if (bIsDeathPosVisible)
						{
							iState = STATE_IDLE;
						}
						else if( iState == STATE_CHASE )
						{
							new bool:bBlockingProp = false;
							
							if (NPCGetFlags(iBossIndex) & SFF_ATTACKPROPS)
							{
								new prop = -1;
								while ((prop = FindEntityByClassname(prop, "prop_physics")) != -1)
								{
									if (NPCAttackValidateTarget(iBossIndex, prop, flAttackRange, flAttackFOV))
									{
										if(NPCPropPhysicsAttack(iBossIndex, prop))
										{
											bBlockingProp = true;
											break;
										}
									}
								}
								
								if (!bBlockingProp)
								{
									prop = -1;
									while ((prop = FindEntityByClassname(prop, "prop_dynamic")) != -1)
									{
										if (GetEntProp(prop, Prop_Data, "m_iHealth") > 0)
										{
											if (NPCAttackValidateTarget(iBossIndex, prop, flAttackRange, flAttackFOV))
											{
												if(NPCPropPhysicsAttack(iBossIndex, prop))
												{
													bBlockingProp = true;
													break;
												}
											}
										}
									}
								}
							}
							
							if (bBlockingProp)
							{
								//PrintToChatAll("A prop is blocking me let's attack it");
								iState = STATE_ATTACK;
							}
						}
						else if (iInterruptConditions & COND_CHASETARGETINVALIDATED)
						{
							if (!g_bSlenderChaseDeathPosition[iBossIndex])
							{
								g_bSlenderChaseDeathPosition[iBossIndex] = true;
							}
						}
					}
					else
					{
						g_bSlenderChaseDeathPosition[iBossIndex] = false;	// We're not chasing a dead player after all! Reset.
					
						decl Float:flAttackDirection[3];
						GetClientAbsOrigin(iTarget, g_flSlenderGoalPos[iBossIndex]);
						SubtractVectors(g_flSlenderGoalPos[iBossIndex], flMyPos, flAttackDirection);
						GetVectorAngles(flAttackDirection, flAttackDirection);
						
						if (GetVectorDistance(g_flSlenderGoalPos[iBossIndex], flMyPos) <= flAttackBeginRange &&
							(FloatAbs(AngleDiff(flAttackDirection[0], flMyEyeAng[0])) + FloatAbs(AngleDiff(flAttackDirection[1], flMyEyeAng[1]))) <= flAttackBeginFOV / 2.0)
						{
							// ENOUGH TALK! HAVE AT YOU!
							iState = STATE_ATTACK;
						}
						else
						{
							new bool:bBlockingProp = false;
							
							if (NPCGetFlags(iBossIndex) & SFF_ATTACKPROPS)
							{
								new prop = -1;
								while ((prop = FindEntityByClassname(prop, "prop_physics")) != -1)
								{
									if (NPCAttackValidateTarget(iBossIndex, prop, flAttackRange, flAttackFOV))
									{
										if(NPCPropPhysicsAttack(iBossIndex, prop))
										{
											bBlockingProp = true;
											break;
										}
									}
								}
								
								if (!bBlockingProp)
								{
									prop = -1;
									while ((prop = FindEntityByClassname(prop, "prop_dynamic")) != -1)
									{
										if (GetEntProp(prop, Prop_Data, "m_iHealth") > 0)
										{
											if (NPCAttackValidateTarget(iBossIndex, prop, flAttackRange, flAttackFOV))
											{
												if(NPCPropPhysicsAttack(iBossIndex, prop))
												{
													bBlockingProp = true;
													break;
												}
											}
										}
									}
								}
							}
							
							if (bBlockingProp)
							{
								//PrintToChatAll("A prop is blocking me let's attack it");
								iState = STATE_ATTACK;
							}
							else if (GetGameTime() >= g_flSlenderNextPathTime[iBossIndex])
							{
								g_flSlenderNextPathTime[iBossIndex] = GetGameTime() + 0.33;
								bQueueForNewPath = true;
							}
						}
					}
				}
				else
				{
					// Even if the target isn't valid anymore, see if I still have some ways to go on my current path,
					// because I shouldn't actually know that the target has died until I see it.
					if (GetArraySize(g_hSlenderPath[iBossIndex]) == 0)
					{
						iState = STATE_IDLE;
					}
				}
			}
			else if (iState == STATE_ATTACK)
			{
				if (!g_bSlenderAttacking[iBossIndex])
				{
					if (IsValidClient(iTarget))
					{
						g_bSlenderChaseDeathPosition[iBossIndex] = false;
						
						// Chase him again!
						iState = STATE_CHASE;
					}
					else
					{
						// Target isn't valid anymore. We killed him, Mac!
						iState = STATE_ALERT;
					}
				}
			}
			else if (iState == STATE_STUN)
			{
				if (GetGameTime() >= g_flSlenderTimeUntilRecover[iBossIndex])
				{
					NPCChaserSetStunHealth(iBossIndex, NPCChaserGetStunInitialHealth(iBossIndex));
					
					if (IsValidClient(iTarget))
					{
						// Chase him again!
						iState = STATE_CHASE;
					}
					else
					{
						// WHAT DA FUUUUUUUUUUUQ. TARGET ISN'T VALID. AUSDHASUIHD
						iState = STATE_ALERT;
					}
				}
			}
		}
	}
	new bool:bDoChasePersistencyInit = false;
	
	if (iState != STATE_STUN)
	{
		if (bStunEnabled)
		{
			if (NPCChaserGetStunHealth(iBossIndex) <= 0)
			{
				if (iState != STATE_CHASE && iState != STATE_ATTACK)
				{
					// Sometimes players can stun the boss while it's not in chase mode. If that happens, we
					// need to set the persistency value to the chase initial value.
					bDoChasePersistencyInit = true;
				}
				iState = STATE_STUN;
			}
		}
	}
	
	// Finally, set our new state.
	g_iSlenderState[iBossIndex] = iState;
	
	decl String:sAnimation[64];
	new iModel = EntRefToEntIndex(g_iSlenderModel[iBossIndex]);
	
	new Float:flPlaybackRateWalk = g_flSlenderWalkAnimationPlaybackRate[iBossIndex];
	new Float:flPlaybackRateRun = g_flSlenderRunAnimationPlaybackRate[iBossIndex];
	new Float:flPlaybackRateIdle = g_flSlenderIdleAnimationPlaybackRate[iBossIndex];
	
	if (iOldState != iState)
	{
		switch (iState)
		{
			case STATE_IDLE, STATE_WANDER:
			{
				g_iSlenderTarget[iBossIndex] = INVALID_ENT_REFERENCE;
				g_flSlenderTimeUntilIdle[iBossIndex] = -1.0;
				g_flSlenderTimeUntilAlert[iBossIndex] = -1.0;
				g_flSlenderTimeUntilChase[iBossIndex] = -1.0;
				g_bSlenderChaseDeathPosition[iBossIndex] = false;
				
				if (iOldState != STATE_IDLE && iOldState != STATE_WANDER)
				{
					g_iSlenderTargetSoundCount[iBossIndex] = 0;
					g_bSlenderInvestigatingSound[iBossIndex] = false;
					g_flSlenderTargetSoundDiscardMasterPosTime[iBossIndex] = -1.0;
					
					g_flSlenderTimeUntilKill[iBossIndex] = GetGameTime() + GetProfileFloat(sSlenderProfile, "idle_lifetime", 10.0);
				}
				
				if (iState == STATE_WANDER)
				{
					// Force new wander position.
					g_flSlenderNextWanderPos[iBossIndex] = -1.0;
				}
				
				// Animation handling.
				if (iModel && iModel != INVALID_ENT_REFERENCE)
				{
					if (iState == STATE_WANDER && (NPCGetFlags(iBossIndex) & SFF_WANDERMOVE))
					{
						if (GetProfileString(sSlenderProfile, "animation_walk", sAnimation, sizeof(sAnimation)))
						{
							EntitySetAnimation(iModel, sAnimation, _, flVelocityRatio * flPlaybackRateWalk);
						}
					}
					else
					{
						if (GetProfileString(sSlenderProfile, "animation_idle", sAnimation, sizeof(sAnimation)))
						{
							EntitySetAnimation(iModel, sAnimation, _, flPlaybackRateIdle);
						}
					}
				}
			}
			
			case STATE_ALERT:
			{
				g_bSlenderChaseDeathPosition[iBossIndex] = false;
				
				// Set our goal position.
				if (g_bSlenderInvestigatingSound[iBossIndex])
				{
					g_flSlenderGoalPos[iBossIndex][0] = g_flSlenderTargetSoundMasterPos[iBossIndex][0];
					g_flSlenderGoalPos[iBossIndex][1] = g_flSlenderTargetSoundMasterPos[iBossIndex][1];
					g_flSlenderGoalPos[iBossIndex][2] = g_flSlenderTargetSoundMasterPos[iBossIndex][2];
				}
				
				g_flSlenderTimeUntilIdle[iBossIndex] = GetGameTime() + GetProfileFloat(sSlenderProfile, "search_alert_duration", 5.0);
				g_flSlenderTimeUntilAlert[iBossIndex] = -1.0;
				g_flSlenderTimeUntilChase[iBossIndex] = GetGameTime() + GetProfileFloat(sSlenderProfile, "search_alert_gracetime", 0.5);
				
				bQueueForNewPath = true;
				
				// Animation handling.
				if (iModel && iModel != INVALID_ENT_REFERENCE)
				{
					if (GetProfileString(sSlenderProfile, "animation_walk", sAnimation, sizeof(sAnimation)))
					{
						EntitySetAnimation(iModel, sAnimation, _, flVelocityRatio * flPlaybackRateWalk);
					}
				}
			}
			case STATE_CHASE, STATE_ATTACK, STATE_STUN:
			{
				g_bSlenderInvestigatingSound[iBossIndex] = false;
				g_iSlenderTargetSoundCount[iBossIndex] = 0;
				
				if (iOldState != STATE_ATTACK && iOldState != STATE_CHASE && iOldState != STATE_STUN)
				{
					g_flSlenderTimeUntilIdle[iBossIndex] = -1.0;
					g_flSlenderTimeUntilAlert[iBossIndex] = GetGameTime() + GetProfileFloat(sSlenderProfile, "search_chase_duration", 10.0);
					g_flSlenderTimeUntilChase[iBossIndex] = -1.0;
					
					new Float:flPersistencyTime = GetProfileFloat(sSlenderProfile, "search_chase_persistency_time_init", 5.0);
					if (flPersistencyTime >= 0.0)
					{
						g_flSlenderTimeUntilNoPersistence[iBossIndex] = GetGameTime() + flPersistencyTime;
					}
				}
				
				if (iState == STATE_ATTACK)
				{
					g_bSlenderAttacking[iBossIndex] = true;
					g_hSlenderAttackTimer[iBossIndex] = CreateTimer(NPCChaserGetAttackDamageDelay(iBossIndex, 0), Timer_SlenderChaseBossAttack, EntIndexToEntRef(slender), TIMER_FLAG_NO_MAPCHANGE);
					
					new Float:flPersistencyTime = GetProfileFloat(sSlenderProfile, "search_chase_persistency_time_init_attack", -1.0);
					if (flPersistencyTime >= 0.0)
					{
						g_flSlenderTimeUntilNoPersistence[iBossIndex] = GetGameTime() + flPersistencyTime;
					}
					
					flPersistencyTime = GetProfileFloat(sSlenderProfile, "search_chase_persistency_time_add_attack", 2.0);
					if (flPersistencyTime >= 0.0)
					{
						if (g_flSlenderTimeUntilNoPersistence[iBossIndex] < GetGameTime()) g_flSlenderTimeUntilNoPersistence[iBossIndex] = GetGameTime();
						g_flSlenderTimeUntilNoPersistence[iBossIndex] += flPersistencyTime;
					}
					
					SlenderPerformVoice(iBossIndex, "sound_attackenemy");
				}
				else if (iState == STATE_STUN)
				{
					if (g_bSlenderAttacking[iBossIndex])
					{
						// Cancel attacking.
						g_bSlenderAttacking[iBossIndex] = false;
						g_hSlenderAttackTimer[iBossIndex] = INVALID_HANDLE;
					}
					
					if (!bDoChasePersistencyInit)
					{
						new Float:flPersistencyTime = GetProfileFloat(sSlenderProfile, "search_chase_persistency_time_init_stun", -1.0);
						if (flPersistencyTime >= 0.0)
						{
							g_flSlenderTimeUntilNoPersistence[iBossIndex] = GetGameTime() + flPersistencyTime;
						}
						
						flPersistencyTime = GetProfileFloat(sSlenderProfile, "search_chase_persistency_time_add_stun", 2.0);
						if (flPersistencyTime >= 0.0)
						{
							if (g_flSlenderTimeUntilNoPersistence[iBossIndex] < GetGameTime()) g_flSlenderTimeUntilNoPersistence[iBossIndex] = GetGameTime();
							g_flSlenderTimeUntilNoPersistence[iBossIndex] += flPersistencyTime;
						}
					}
					else
					{
						new Float:flPersistencyTime = GetProfileFloat(sSlenderProfile, "search_chase_persistency_time_init", 5.0);
						if (flPersistencyTime >= 0.0)
						{
							g_flSlenderTimeUntilNoPersistence[iBossIndex] = GetGameTime() + flPersistencyTime;
						}
					}
					
					g_flSlenderTimeUntilRecover[iBossIndex] = GetGameTime() + NPCChaserGetStunDuration(iBossIndex);
					
					// Sound handling. Ignore time check.
					SlenderPerformVoice(iBossIndex, "sound_stun");
				}
				else
				{
					if (iOldState != STATE_ATTACK)
					{
						// Sound handling.
						SlenderPerformVoice(iBossIndex, "sound_chaseenemyinitial");
					}
				}
				
				// Animation handling.
				if (iModel && iModel != INVALID_ENT_REFERENCE)
				{
					if (iState == STATE_CHASE)
					{
						if (GetProfileString(sSlenderProfile, "animation_run", sAnimation, sizeof(sAnimation)))
						{
							EntitySetAnimation(iModel, sAnimation, _, flVelocityRatio * flPlaybackRateRun);
						}
					}
					else if (iState == STATE_ATTACK)
					{
						if (GetProfileString(sSlenderProfile, "animation_attack", sAnimation, sizeof(sAnimation)))
						{
							EntitySetAnimation(iModel, sAnimation, _, GetProfileFloat(sSlenderProfile, "animation_attack_playbackrate", 1.0));
						}
					}
					else if (iState == STATE_STUN)
					{
						if (GetProfileString(sSlenderProfile, "animation_stun", sAnimation, sizeof(sAnimation)))
						{
							EntitySetAnimation(iModel, sAnimation, _, GetProfileFloat(sSlenderProfile, "animation_stun_playbackrate", 1.0));
						}
					}
				}
			}
		}
		
		// Call our forward.
		Call_StartForward(fOnBossChangeState);
		Call_PushCell(iBossIndex);
		Call_PushCell(iOldState);
		Call_PushCell(iState);
		Call_Finish();
	}
	
	switch (iState)
	{
		case STATE_IDLE:
		{
			// Animation playback speed handling.
			if (iModel && iModel != INVALID_ENT_REFERENCE)
			{
				SetVariantFloat(flPlaybackRateIdle);
				AcceptEntityInput(iModel, "SetPlaybackRate");
			}
		}
		case STATE_WANDER, STATE_ALERT, STATE_CHASE, STATE_ATTACK:
		{
			// These deal with movement, therefore we need to set our 
			// destination first. That is, if we don't have one. (nav mesh only)
			
			if (iState == STATE_WANDER)
			{
				if (GetGameTime() >= g_flSlenderNextWanderPos[iBossIndex])
				{
					new Float:flMin = GetProfileFloat(sSlenderProfile, "search_wander_time_min", 4.0);
					new Float:flMax = GetProfileFloat(sSlenderProfile, "search_wander_time_max", 6.5);
					g_flSlenderNextWanderPos[iBossIndex] = GetGameTime() + GetRandomFloat(flMin, flMax);
					
					if (NPCGetFlags(iBossIndex) & SFF_WANDERMOVE)
					{
						// We're allowed to move in wander mode. Get a new wandering position and create a path to follow.
						// If the position can't be reached, then just get to the closest area that we can get.
						new Float:flWanderRangeMin = GetProfileFloat(sSlenderProfile, "search_wander_range_min", 400.0);
						new Float:flWanderRangeMax = GetProfileFloat(sSlenderProfile, "search_wander_range_max", 1024.0);
						new Float:flWanderRange = GetRandomFloat(flWanderRangeMin, flWanderRangeMax);
						
						decl Float:flWanderPos[3];
						flWanderPos[0] = 0.0;
						flWanderPos[1] = GetRandomFloat(0.0, 360.0);
						flWanderPos[2] = 0.0;
						
						GetAngleVectors(flWanderPos, flWanderPos, NULL_VECTOR, NULL_VECTOR);
						NormalizeVector(flWanderPos, flWanderPos);
						ScaleVector(flWanderPos, flWanderRange);
						AddVectors(flWanderPos, flMyPos, flWanderPos);
						
						g_flSlenderGoalPos[iBossIndex][0] = flWanderPos[0];
						g_flSlenderGoalPos[iBossIndex][1] = flWanderPos[1];
						g_flSlenderGoalPos[iBossIndex][2] = flWanderPos[2];
						
						bQueueForNewPath = true;
						g_flSlenderNextPathTime[iBossIndex] = -1.0; // We're not going to wander around too much, so no need for a time constraint.
					}
				}
			}
			else if (iState == STATE_ALERT)
			{
				if (iInterruptConditions & COND_SAWENEMY)
				{
					if (IsValidEntity(iBestNewTarget))
					{
						if ((bPlayerInFOV[iBestNewTarget] || bPlayerNear[iBestNewTarget]) && bPlayerVisible[iBestNewTarget])
						{
							// Constantly update my path if I see him.
							if (GetGameTime() >= g_flSlenderNextPathTime[iBossIndex])
							{
								GetEntPropVector(iBestNewTarget, Prop_Data, "m_vecAbsOrigin", g_flSlenderGoalPos[iBossIndex]);
								bQueueForNewPath = true;
								g_flSlenderNextPathTime[iBossIndex] = GetGameTime() + 0.33;
							}
						}
					}
				}
			}
			else if (iState == STATE_CHASE || iState == STATE_ATTACK)
			{
				if (IsValidEntity(iBestNewTarget))
				{
					iOldTarget = iTarget;
					iTarget = iBestNewTarget;
					g_iSlenderTarget[iBossIndex] = EntIndexToEntRef(iBestNewTarget);
				}
				
				if (iTarget != INVALID_ENT_REFERENCE)
				{
					if (iOldTarget != iTarget)
					{
						// Brand new target! We need a path, and we need to reset our persistency, if needed.
						new Float:flPersistencyTime = GetProfileFloat(sSlenderProfile, "search_chase_persistency_time_init_newtarget", -1.0);
						if (flPersistencyTime >= 0.0)
						{
							g_flSlenderTimeUntilNoPersistence[iBossIndex] = GetGameTime() + flPersistencyTime;
						}
						
						flPersistencyTime = GetProfileFloat(sSlenderProfile, "search_chase_persistency_time_add_newtarget", 2.0);
						if (flPersistencyTime >= 0.0)
						{
							if (g_flSlenderTimeUntilNoPersistence[iBossIndex] < GetGameTime()) g_flSlenderTimeUntilNoPersistence[iBossIndex] = GetGameTime();
							g_flSlenderTimeUntilNoPersistence[iBossIndex] += flPersistencyTime;
						}
					
						GetEntPropVector(iTarget, Prop_Data, "m_vecAbsOrigin", g_flSlenderGoalPos[iBossIndex]);
						bQueueForNewPath = true; // Brand new target! We need a new path!
					}
					else if ((bPlayerInFOV[iTarget] && bPlayerVisible[iTarget]) || GetGameTime() < g_flSlenderTimeUntilNoPersistence[iBossIndex])
					{
						// Constantly update my path if I see him or if I'm still being persistent.
						if (GetGameTime() >= g_flSlenderNextPathTime[iBossIndex])
						{
							GetEntPropVector(iTarget, Prop_Data, "m_vecAbsOrigin", g_flSlenderGoalPos[iBossIndex]);
							bQueueForNewPath = true;
							g_flSlenderNextPathTime[iBossIndex] = GetGameTime() + 0.33;
						}
					}
				}
			}
			
			if (NavMesh_Exists())
			{
				// So by now we should have calculated our master goal position.
				// Now we use that to create a path.
				
				if (bQueueForNewPath)
				{
					ClearArray(g_hSlenderPath[iBossIndex]);
					
					new iCurrentAreaIndex = NavMesh_GetNearestArea(flMyPos);
					if (iCurrentAreaIndex != -1)
					{
						new iGoalAreaIndex = NavMesh_GetNearestArea(g_flSlenderGoalPos[iBossIndex]);
						if (iGoalAreaIndex != -1)
						{
							decl Float:flCenter[3], Float:flCenterPortal[3], Float:flClosestPoint[3];
							new iClosestAreaIndex = 0;
							
							new bool:bPathSuccess = NavMesh_BuildPath(iCurrentAreaIndex,
								iGoalAreaIndex,
								g_flSlenderGoalPos[iBossIndex],
								SlenderChaseBossShortestPathCost,
								RoundToFloor(NPCChaserGetStepSize(iBossIndex)),
								iClosestAreaIndex);
								
							new iTempAreaIndex = iClosestAreaIndex;
							new iTempParentAreaIndex = NavMeshArea_GetParent(iTempAreaIndex);
							new iNavDirection;
							new Float:flHalfWidth;
							
							if (bPathSuccess)
							{
								// Path successful? Insert the goal position into our list.
								new iIndex = PushArrayCell(g_hSlenderPath[iBossIndex], g_flSlenderGoalPos[iBossIndex][0]);
								SetArrayCell(g_hSlenderPath[iBossIndex], iIndex, g_flSlenderGoalPos[iBossIndex][1], 1);
								SetArrayCell(g_hSlenderPath[iBossIndex], iIndex, g_flSlenderGoalPos[iBossIndex][2], 2);
							}
							
							while (iTempParentAreaIndex != -1)
							{
								// Build a path of waypoints along the nav mesh for our AI to follow.
								// Path order is first come, first served, so when we got our waypoint list,
								// we have to reverse it so that the starting waypoint would be in front.
								
								NavMeshArea_GetCenter(iTempParentAreaIndex, flCenter);
								iNavDirection = NavMeshArea_ComputeDirection(iTempAreaIndex, flCenter);
								NavMeshArea_ComputePortal(iTempAreaIndex, iTempParentAreaIndex, iNavDirection, flCenterPortal, flHalfWidth);
								NavMeshArea_ComputeClosestPointInPortal(iTempAreaIndex, iTempParentAreaIndex, iNavDirection, flCenterPortal, flClosestPoint);
								
								flClosestPoint[2] = NavMeshArea_GetZ(iTempAreaIndex, flClosestPoint);
								
								new iIndex = PushArrayCell(g_hSlenderPath[iBossIndex], flClosestPoint[0]);
								SetArrayCell(g_hSlenderPath[iBossIndex], iIndex, flClosestPoint[1], 1);
								SetArrayCell(g_hSlenderPath[iBossIndex], iIndex, flClosestPoint[2], 2);
								
								iTempAreaIndex = iTempParentAreaIndex;
								iTempParentAreaIndex = NavMeshArea_GetParent(iTempAreaIndex);
							}
							
							// Set our goal position to the start node (hopefully there's something in the array).
							if (GetArraySize(g_hSlenderPath[iBossIndex]) > 0)
							{
								new iPosIndex = GetArraySize(g_hSlenderPath[iBossIndex]) - 1;
								
								g_flSlenderGoalPos[iBossIndex][0] = Float:GetArrayCell(g_hSlenderPath[iBossIndex], iPosIndex, 0);
								g_flSlenderGoalPos[iBossIndex][1] = Float:GetArrayCell(g_hSlenderPath[iBossIndex], iPosIndex, 1);
								g_flSlenderGoalPos[iBossIndex][2] = Float:GetArrayCell(g_hSlenderPath[iBossIndex], iPosIndex, 2);
							}
						}
						else
						{
							PrintToServer("SF2: Failed to create new path for boss %d: destination is not on nav mesh!", iBossIndex);
						}
					}
					else
					{
						PrintToServer("SF2: Failed to create new path for boss %d: boss is not on nav mesh!", iBossIndex);
					}
				}
			}
			else
			{
				// The nav mesh doesn't exist? Well, that sucks.
				ClearArray(g_hSlenderPath[iBossIndex]);
			}
			
			if (iState == STATE_CHASE || iState == STATE_ATTACK)
			{
				if (IsValidClient(iTarget))
				{
#if defined DEBUG
					SendDebugMessageToPlayer(iTarget, DEBUG_BOSS_CHASE, 1, "g_flSlenderTimeUntilAlert[%d]: %f\ng_flSlenderTimeUntilNoPersistence[%d]: %f", iBossIndex, g_flSlenderTimeUntilAlert[iBossIndex] - GetGameTime(), iBossIndex, g_flSlenderTimeUntilNoPersistence[iBossIndex] - GetGameTime());
#endif
				
					if (bPlayerInFOV[iTarget] && bPlayerVisible[iTarget])
					{
						new Float:flDistRatio = flPlayerDists[iTarget] / NPCGetSearchRadius(iBossIndex);
						
						new Float:flChaseDurationTimeAddMin = GetProfileFloat(sSlenderProfile, "search_chase_duration_add_visible_min", 0.025);
						new Float:flChaseDurationTimeAddMax = GetProfileFloat(sSlenderProfile, "search_chase_duration_add_visible_max", 0.2);
						
						new Float:flChaseDurationAdd = flChaseDurationTimeAddMax - ((flChaseDurationTimeAddMax - flChaseDurationTimeAddMin) * flDistRatio);
						
						if (flChaseDurationAdd > 0.0)
						{
							g_flSlenderTimeUntilAlert[iBossIndex] += flChaseDurationAdd;
							if (g_flSlenderTimeUntilAlert[iBossIndex] > (GetGameTime() + GetProfileFloat(sSlenderProfile, "search_chase_duration")))
							{
								g_flSlenderTimeUntilAlert[iBossIndex] = GetGameTime() + GetProfileFloat(sSlenderProfile, "search_chase_duration");
							}
						}
						
						new Float:flPersistencyTimeAddMin = GetProfileFloat(sSlenderProfile, "search_chase_persistency_time_add_visible_min", 0.05);
						new Float:flPersistencyTimeAddMax = GetProfileFloat(sSlenderProfile, "search_chase_persistency_time_add_visible_max", 0.15);
						
						new Float:flPersistencyTimeAdd = flPersistencyTimeAddMax - ((flPersistencyTimeAddMax - flPersistencyTimeAddMin) * flDistRatio);
						
						if (flPersistencyTimeAdd > 0.0)
						{
							if (g_flSlenderTimeUntilNoPersistence[iBossIndex] < GetGameTime()) g_flSlenderTimeUntilNoPersistence[iBossIndex] = GetGameTime();
						
							g_flSlenderTimeUntilNoPersistence[iBossIndex] += flPersistencyTimeAdd;
							if (g_flSlenderTimeUntilNoPersistence[iBossIndex] > (GetGameTime() + GetProfileFloat(sSlenderProfile, "search_chase_duration")))
							{
								g_flSlenderTimeUntilNoPersistence[iBossIndex] = GetGameTime() + GetProfileFloat(sSlenderProfile, "search_chase_duration");
							}
						}
					}
				}
			}
			
			// Process through our path waypoints.
			if (GetArraySize(g_hSlenderPath[iBossIndex]) > 0)
			{
				decl Float:flHitNormal[3];
				decl Float:flNodePos[3];
				
				new Float:flNodeToleranceDist = g_flSlenderPathNodeTolerance[iBossIndex];
				new bool:bGotNewPoint = false;
				
				for (new iNodeIndex = 0, iNodeCount = GetArraySize(g_hSlenderPath[iBossIndex]); iNodeIndex < iNodeCount; iNodeIndex++)
				{
					flNodePos[0] = Float:GetArrayCell(g_hSlenderPath[iBossIndex], iNodeIndex, 0);
					flNodePos[1] = Float:GetArrayCell(g_hSlenderPath[iBossIndex], iNodeIndex, 1);
					flNodePos[2] = Float:GetArrayCell(g_hSlenderPath[iBossIndex], iNodeIndex, 2);
					
					new Handle:hTrace = TR_TraceHullFilterEx(flMyPos,
						flNodePos, 
						flSlenderMins, 
						flSlenderMaxs, 
						MASK_NPCSOLID, 
						TraceRayDontHitCharactersOrEntity, 
						slender);
						
					new bool:bDidHit = TR_DidHit(hTrace);
					TR_GetPlaneNormal(hTrace, flHitNormal);
					CloseHandle(hTrace);
					GetVectorAngles(flHitNormal, flHitNormal);
					for (new i = 0; i < 3; i++) flHitNormal[i] = AngleNormalize(flHitNormal[i]);
					
					// First check if we can see the point.
					if (!bDidHit || ((flHitNormal[0] >= 0.0 && flHitNormal[0] > 45.0) || (flHitNormal[0] < 0.0 && flHitNormal[0] < -45.0)))
					{
						new bool:bNearNode = false;
						
						// See if we're already near enough.
						new Float:flDist = GetVectorDistance(flNodePos, flMyPos);
						if (flDist < flNodeToleranceDist) bNearNode = true;
						
						if (!bNearNode)
						{
							new bool:bOutside = false;
						
							// Then, predict if we're going to pass over the point on the next think.
							decl Float:flTestPos[3];
							NormalizeVector(flSlenderVelocity, flTestPos);
							ScaleVector(flTestPos, GetVectorLength(flSlenderVelocity) * BOSS_THINKRATE);
							AddVectors(flMyPos, flTestPos, flTestPos);
							
							decl Float:flP[3], Float:flS[3];
							SubtractVectors(flNodePos, flMyPos, flP);
							SubtractVectors(flTestPos, flMyPos, flS);
							
							new Float:flSP = GetVectorDotProduct(flP, flS);
							if (flSP <= 0.0) bOutside = true;
							
							new Float:flPP = GetVectorDotProduct(flS, flS);
							
							if (!bOutside)
							{
								if (flPP <= flSP) bOutside = true;
							}
							
							if (!bOutside)
							{
								decl Float:flD[3];
								ScaleVector(flS, (flSP / flPP));
								SubtractVectors(flP, flS, flD);
							
								flDist = GetVectorLength(flD);
								if (flDist < flNodeToleranceDist)
								{
									bNearNode = true;
								}
							}
						}
						
						if (bNearNode)
						{
							// Shave off this node and set our goal position to the next one.
						
							ResizeArray(g_hSlenderPath[iBossIndex], iNodeIndex);
							
							if (GetArraySize(g_hSlenderPath[iBossIndex]) > 0)
							{
								new iPosIndex = GetArraySize(g_hSlenderPath[iBossIndex]) - 1;
								
								g_flSlenderGoalPos[iBossIndex][0] = Float:GetArrayCell(g_hSlenderPath[iBossIndex], iPosIndex, 0);
								g_flSlenderGoalPos[iBossIndex][1] = Float:GetArrayCell(g_hSlenderPath[iBossIndex], iPosIndex, 1);
								g_flSlenderGoalPos[iBossIndex][2] = Float:GetArrayCell(g_hSlenderPath[iBossIndex], iPosIndex, 2);
							}
							
							bGotNewPoint = true;
							break;
						}
					}
				}
				
				if (!bGotNewPoint)
				{
					// Try to see if we can look ahead.
					
					decl Float:flMyEyePos[3];
					NPCGetEyePosition(iBossIndex, flMyEyePos);
					
					new Float:flNodeLookAheadDist = g_flSlenderPathNodeLookAhead[iBossIndex];
					if (flNodeLookAheadDist > 0.0)
					{
						new iNodeCount = GetArraySize(g_hSlenderPath[iBossIndex]);
						if (iNodeCount)
						{
							decl Float:flInitDir[3];
							flInitDir[0] = Float:GetArrayCell(g_hSlenderPath[iBossIndex], iNodeCount - 1, 0);
							flInitDir[1] = Float:GetArrayCell(g_hSlenderPath[iBossIndex], iNodeCount - 1, 1);
							flInitDir[2] = Float:GetArrayCell(g_hSlenderPath[iBossIndex], iNodeCount - 1, 2);
							
							SubtractVectors(flInitDir, flMyPos, flInitDir);
							NormalizeVector(flInitDir, flInitDir);
							
							decl Float:flPrevDir[3];
							flPrevDir[0] = flInitDir[0];
							flPrevDir[1] = flInitDir[1];
							flPrevDir[2] = flInitDir[2];
							
							NormalizeVector(flPrevDir, flPrevDir);
							
							decl Float:flPrevNodePos[3];
							
							new iStartPointIndex = iNodeCount - 1;
							new Float:flRangeSoFar = 0.0;
							
							new iLookAheadPointIndex;
							for (iLookAheadPointIndex = iStartPointIndex; iLookAheadPointIndex >= 0; iLookAheadPointIndex--)
							{
								flNodePos[0] = Float:GetArrayCell(g_hSlenderPath[iBossIndex], iLookAheadPointIndex, 0);
								flNodePos[1] = Float:GetArrayCell(g_hSlenderPath[iBossIndex], iLookAheadPointIndex, 1);
								flNodePos[2] = Float:GetArrayCell(g_hSlenderPath[iBossIndex], iLookAheadPointIndex, 2);
							
								decl Float:flDir[3];
								if (iLookAheadPointIndex == iStartPointIndex)
								{
									SubtractVectors(flNodePos, flMyPos, flDir);
									NormalizeVector(flDir, flDir);
								}
								else
								{
									flPrevNodePos[0] = Float:GetArrayCell(g_hSlenderPath[iBossIndex], iLookAheadPointIndex + 1, 0);
									flPrevNodePos[1] = Float:GetArrayCell(g_hSlenderPath[iBossIndex], iLookAheadPointIndex + 1, 1);
									flPrevNodePos[2] = Float:GetArrayCell(g_hSlenderPath[iBossIndex], iLookAheadPointIndex + 1, 2);
								
									SubtractVectors(flNodePos, flPrevNodePos, flDir);
									NormalizeVector(flDir, flDir);
								}
								
								if (GetVectorDotProduct(flDir, flInitDir) < 0.0)
								{
									break;
								}
								
								if (GetVectorDotProduct(flDir, flPrevDir) < 0.5)
								{
									break;
								}
								
								flPrevDir[0] = flDir[0];
								flPrevDir[1] = flDir[1];
								flPrevDir[2] = flDir[2];
								
								decl Float:flProbe[3];
								flProbe[0] = flNodePos[0];
								flProbe[1] = flNodePos[1];
								flProbe[2] = flNodePos[2] + HalfHumanHeight;
								
								if (!IsWalkableTraceLineClear(flMyEyePos, flProbe, WALK_THRU_BREAKABLES))
								{
									break;
								}
								
								if (iLookAheadPointIndex == iStartPointIndex)
								{
									flRangeSoFar += GetVectorDistance(flMyPos, flNodePos);
								}
								else
								{
									flRangeSoFar += GetVectorDistance(flNodePos, flPrevNodePos);
								}
								
								if (flRangeSoFar >= flNodeLookAheadDist)
								{
									break;
								}
							}
							
							// Shave off all unnecessary nodes and keep the one that is within
							// our viewsight.
							
							ResizeArray(g_hSlenderPath[iBossIndex], iLookAheadPointIndex + 1);
							
							if (GetArraySize(g_hSlenderPath[iBossIndex]) > 0)
							{
								new iPosIndex = GetArraySize(g_hSlenderPath[iBossIndex]) - 1;
								
								g_flSlenderGoalPos[iBossIndex][0] = Float:GetArrayCell(g_hSlenderPath[iBossIndex], iPosIndex, 0);
								g_flSlenderGoalPos[iBossIndex][1] = Float:GetArrayCell(g_hSlenderPath[iBossIndex], iPosIndex, 1);
								g_flSlenderGoalPos[iBossIndex][2] = Float:GetArrayCell(g_hSlenderPath[iBossIndex], iPosIndex, 2);
							}
							
							bGotNewPoint = true;
						}
					}
				}
			}
			
			if (iState != STATE_ATTACK && iState != STATE_STUN)
			{
				// Animation playback speed handling.
				if (iModel && iModel != INVALID_ENT_REFERENCE)
				{
					if (iState == STATE_WANDER && !(NPCGetFlags(iBossIndex) & SFF_WANDERMOVE))
					{
						SetVariantFloat(flPlaybackRateIdle);
						AcceptEntityInput(iModel, "SetPlaybackRate");
					}
					else
					{
						SetVariantFloat(iState == STATE_CHASE ? (flVelocityRatio * flPlaybackRateRun) : (flVelocityRatioWalk * flPlaybackRateWalk));
						AcceptEntityInput(iModel, "SetPlaybackRate");
					}
				}
			}
		}
	}
	
	// Sound handling.
	if (GetGameTime() >= g_flSlenderNextVoiceSound[iBossIndex])
	{
		if (iState == STATE_IDLE || iState == STATE_WANDER)
		{
			SlenderPerformVoice(iBossIndex, "sound_idle");
		}
		else if (iState == STATE_ALERT)
		{
			SlenderPerformVoice(iBossIndex, "sound_alertofenemy");
		}
		else if (iState == STATE_CHASE || iState == STATE_ATTACK)
		{
			SlenderPerformVoice(iBossIndex, "sound_chasingenemy");
		}
	}
	
	// Reset our interrupt conditions.
	g_iSlenderInterruptConditions[iBossIndex] = 0;
	
	return Plugin_Continue;
}

SlenderChaseBossProcessMovement(iBossIndex)
{
	new iBoss = NPCGetEntIndex(iBossIndex);
	new iState = g_iSlenderState[iBossIndex];
	
	// Constantly set the monster_generic's NPC state to idle to prevent
	// velocity confliction.
	
	SetEntProp(iBoss, Prop_Data, "m_NPCState", 0);
	
	new Float:flWalkSpeed = g_flSlenderCalculatedWalkSpeed[iBossIndex];
	new Float:flSpeed = g_flSlenderCalculatedSpeed[iBossIndex];
	
	new Float:flMyPos[3], Float:flMyEyeAng[3], Float:flMyVelocity[3];
	
	decl String:sSlenderProfile[SF2_MAX_PROFILE_NAME_LENGTH];
	NPCGetProfile(iBossIndex, sSlenderProfile, sizeof(sSlenderProfile));
	
	GetEntPropVector(iBoss, Prop_Data, "m_vecAbsOrigin", flMyPos);
	GetEntPropVector(iBoss, Prop_Data, "m_angAbsRotation", flMyEyeAng);
	GetEntPropVector(iBoss, Prop_Data, "m_vecAbsVelocity", flMyVelocity);
	
	decl Float:flBossMins[3], Float:flBossMaxs[3];
	GetEntPropVector(iBoss, Prop_Send, "m_vecMins", flBossMins);
	GetEntPropVector(iBoss, Prop_Send, "m_vecMaxs", flBossMaxs);
	
	decl Float:flTraceMins[3], Float:flTraceMaxs[3];
	flTraceMins[0] = flBossMins[0];
	flTraceMins[1] = flBossMins[1];
	flTraceMins[2] = 0.0;
	flTraceMaxs[0] = flBossMaxs[0];
	flTraceMaxs[1] = flBossMaxs[1];
	flTraceMaxs[2] = 0.0;
	
	// By now we should have our preferable goal position. Initiate
	// reflex adjustments.
	
	g_bSlenderFeelerReflexAdjustment[iBossIndex] = false;
	
	{
		decl Float:flMoveDir[3];
		NormalizeVector(flMyVelocity, flMoveDir);
		flMoveDir[2] = 0.0;
		
		decl Float:flLat[3];
		flLat[0] = -flMoveDir[1];
		flLat[1] = flMoveDir[0];
		flLat[2] = 0.0;
	
		new Float:flFeelerOffset = 25.0;
		new Float:flFeelerLengthRun = 50.0;
		new Float:flFeelerLengthWalk = 30.0;
		new Float:flFeelerHeight = StepHeight + 0.1;
		
		new Float:flFeelerLength = iState == STATE_CHASE ? flFeelerLengthRun : flFeelerLengthWalk;
		
		// Get the ground height and normal.
		new Handle:hTrace = TR_TraceRayFilterEx(flMyPos, Float:{ 0.0, 0.0, 90.0 }, MASK_NPCSOLID, RayType_Infinite, TraceFilterWalkableEntities);
		decl Float:flTraceEndPos[3];
		decl Float:flTraceNormal[3];
		TR_GetEndPosition(flTraceEndPos, hTrace);
		TR_GetPlaneNormal(hTrace, flTraceNormal);
		new bool:bTraceHit = TR_DidHit(hTrace);
		CloseHandle(hTrace);
		
		if (bTraceHit)
		{
			//new Float:flGroundHeight = GetVectorDistance(flMyPos, flTraceEndPos);
			NormalizeVector(flTraceNormal, flTraceNormal);
			GetVectorCrossProduct(flLat, flTraceNormal, flMoveDir);
			GetVectorCrossProduct(flMoveDir, flTraceNormal, flLat);
			
			decl Float:flFeet[3];
			flFeet[0] = flMyPos[0];
			flFeet[1] = flMyPos[1];
			flFeet[2] = flMyPos[2] + flFeelerHeight;
			
			decl Float:flTo[3];
			decl Float:flFrom[3];
			for (new i = 0; i < 3; i++)
			{
				flFrom[i] = flFeet[i] + (flFeelerOffset * flLat[i]);
				flTo[i] = flFrom[i] + (flFeelerLength * flMoveDir[i]);
			}
			
			new bool:bLeftClear = IsWalkableTraceLineClear(flFrom, flTo, WALK_THRU_DOORS | WALK_THRU_BREAKABLES);
			
			for (new i = 0; i < 3; i++)
			{
				flFrom[i] = flFeet[i] - (flFeelerOffset * flLat[i]);
				flTo[i] = flFrom[i] + (flFeelerLength * flMoveDir[i]);
			}
			
			new bool:bRightClear = IsWalkableTraceLineClear(flFrom, flTo, WALK_THRU_DOORS | WALK_THRU_BREAKABLES);
			
			new Float:flAvoidRange = 300.0;
			
			if (!bRightClear)
			{
				if (bLeftClear)
				{
					g_bSlenderFeelerReflexAdjustment[iBossIndex] = true;
					
					for (new i = 0; i < 3; i++)
					{
						g_flSlenderFeelerReflexAdjustmentPos[iBossIndex][i] = g_flSlenderGoalPos[iBossIndex][i] + (flAvoidRange * flLat[i]);
					}
				}
			}
			else if (!bLeftClear)
			{
				g_bSlenderFeelerReflexAdjustment[iBossIndex] = true;
				
				for (new i = 0; i < 3; i++)
				{
					g_flSlenderFeelerReflexAdjustmentPos[iBossIndex][i] = g_flSlenderGoalPos[iBossIndex][i] - (flAvoidRange * flLat[i]);
				}
			}
		}
	}
	
	new Float:flGoalPosition[3];
	if (g_bSlenderFeelerReflexAdjustment[iBossIndex])
	{
		for (new i = 0; i < 3; i++)
		{
			flGoalPosition[i] = g_flSlenderFeelerReflexAdjustmentPos[iBossIndex][i];
		}
	}
	else
	{
		for (new i = 0; i < 3; i++)
		{
			flGoalPosition[i] = g_flSlenderGoalPos[iBossIndex][i];
		}
	}
	
	// Process our desired velocity.
	new Float:flDesiredVelocity[3];
	switch (iState)
	{
		case STATE_WANDER:
		{
			if (NPCGetFlags(iBossIndex) & SFF_WANDERMOVE)
			{
				SubtractVectors(flGoalPosition, flMyPos, flDesiredVelocity);
				flDesiredVelocity[2] = 0.0;
				NormalizeVector(flDesiredVelocity, flDesiredVelocity);
				ScaleVector(flDesiredVelocity, flWalkSpeed);
			}
		}
		case STATE_ALERT:
		{
			SubtractVectors(flGoalPosition, flMyPos, flDesiredVelocity);
			flDesiredVelocity[2] = 0.0;
			NormalizeVector(flDesiredVelocity, flDesiredVelocity);
			ScaleVector(flDesiredVelocity, flWalkSpeed);
		}
		case STATE_CHASE:
		{
			SubtractVectors(flGoalPosition, flMyPos, flDesiredVelocity);
			flDesiredVelocity[2] = 0.0;
			NormalizeVector(flDesiredVelocity, flDesiredVelocity);
			ScaleVector(flDesiredVelocity, flSpeed);
		}
	}
	
	// Check if we're on the ground.
	new bool:bSlenderOnGround = bool:(GetEntityFlags(iBoss) & FL_ONGROUND);
	
	decl Float:flTraceEndPos[3];
	new Handle:hTrace;
	
	// Determine speed behavior.
	if (bSlenderOnGround)
	{
		// Don't change the speed behavior.
	}
	else
	{
		flDesiredVelocity[2] = 0.0;
		NormalizeVector(flDesiredVelocity, flDesiredVelocity);
		ScaleVector(flDesiredVelocity, NPCChaserGetAirSpeed(iBossIndex, GetConVarInt(g_cvDifficulty)));
	}
	
	new bool:bSlenderTeleportedOnStep = false;
	new Float:flSlenderStepSize = NPCChaserGetStepSize(iBossIndex);
	
	// Check our stepsize in case we need to elevate ourselves a step.
	if (bSlenderOnGround && GetVectorLength(flDesiredVelocity) > 0.0)
	{
		if (flSlenderStepSize > 0.0)
		{
			decl Float:flTraceDirection[3], Float:flObstaclePos[3], Float:flObstacleNormal[3];
			NormalizeVector(flDesiredVelocity, flTraceDirection);
			AddVectors(flMyPos, flTraceDirection, flTraceEndPos);
			
			// Tracehull in front of us to check if there's a very small obstacle blocking our way.
			hTrace = TR_TraceHullFilterEx(flMyPos, 
				flTraceEndPos,
				flBossMins,
				flBossMaxs,
				MASK_NPCSOLID,
				TraceRayDontHitEntity,
				iBoss);
				
			new bool:bSlenderHitObstacle = TR_DidHit(hTrace);
			TR_GetEndPosition(flObstaclePos, hTrace);
			TR_GetPlaneNormal(hTrace, flObstacleNormal);
			CloseHandle(hTrace);
			
			if (bSlenderHitObstacle &&
				FloatAbs(flObstacleNormal[2]) == 0.0)
			{
				decl Float:flTraceStartPos[3];
				flTraceStartPos[0] = flObstaclePos[0];
				flTraceStartPos[1] = flObstaclePos[1];
				
				decl Float:flTraceFreePos[3];
				
				new Float:flTraceCheckZ = 0.0;
				
				// This does a crapload of traces along the wall. Very nasty and expensive to do...
				while (flTraceCheckZ <= flSlenderStepSize)
				{
					flTraceCheckZ += 1.0;
					flTraceStartPos[2] = flObstaclePos[2] + flTraceCheckZ;
					
					AddVectors(flTraceStartPos, flTraceDirection, flTraceEndPos);
					
					hTrace = TR_TraceHullFilterEx(flTraceStartPos, 
						flTraceEndPos,
						flTraceMins,
						flTraceMaxs,
						MASK_NPCSOLID,
						TraceRayDontHitEntity,
						iBoss);
						
					bSlenderHitObstacle = TR_DidHit(hTrace);
					TR_GetEndPosition(flTraceFreePos, hTrace);
					CloseHandle(hTrace);
					
					if (!bSlenderHitObstacle)
					{
						// Potential space to step on? See if we can fit!
						if (!IsSpaceOccupiedNPC(flTraceFreePos,
							flBossMins,
							flBossMaxs,
							iBoss))
						{
							// Yes we can! Break the loop and teleport to this pos.
							bSlenderTeleportedOnStep = true;
							TeleportEntity(iBoss, flTraceFreePos, NULL_VECTOR, NULL_VECTOR);
							break;
						}
					}
				}
			}
			/*
			else if (!bSlenderHitObstacle)
			{
				decl Float:flTraceStartPos[3];
				flTraceStartPos[0] = flObstaclePos[0];
				flTraceStartPos[1] = flObstaclePos[1];
				
				decl Float:flTraceFreePos[3];
				
				new Float:flTraceCheckZ = 0.0;
				
				// This does a crapload of traces along the wall. Very nasty and expensive to do...
				while (flTraceCheckZ <= flSlenderStepSize)
				{
					flTraceCheckZ += 1.0;
					flTraceStartPos[2] = flObstaclePos[2] - flTraceCheckZ;
					
					AddVectors(flTraceStartPos, flTraceDirection, flTraceEndPos);
					
					hTrace = TR_TraceHullFilterEx(flTraceStartPos, 
						flTraceEndPos,
						flTraceMins,
						flTraceMaxs,
						MASK_NPCSOLID,
						TraceRayDontHitEntity,
						iBoss);
						
					bSlenderHitObstacle = TR_DidHit(hTrace);
					TR_GetEndPosition(flTraceFreePos, hTrace);
					CloseHandle(hTrace);
					
					if (bSlenderHitObstacle)
					{
						// Potential space to step on? See if we can fit!
						if (!IsSpaceOccupiedNPC(flTraceFreePos,
							flBossMins,
							flBossMaxs,
							iBoss))
						{
							// Yes we can! Break the loop and teleport to this pos.
							bSlenderTeleportedOnStep = true;
							TeleportEntity(iBoss, flTraceFreePos, NULL_VECTOR, NULL_VECTOR);
							break;
						}
					}
				}
			}
			*/
		}
	}
	
	// Apply acceleration vectors.
	new Float:flMoveVelocity[3];
	new Float:flFrameTime = GetTickInterval();
	decl Float:flAcceleration[3];
	SubtractVectors(flDesiredVelocity, flMyVelocity, flAcceleration);
	NormalizeVector(flAcceleration, flAcceleration);
	ScaleVector(flAcceleration, g_flSlenderAcceleration[iBossIndex] * flFrameTime);
	
	AddVectors(flMyVelocity, flAcceleration, flMoveVelocity);
	
	new Float:flSlenderJumpSpeed = g_flSlenderJumpSpeed[iBossIndex];
	new bool:bSlenderShouldJump = false;
	
	decl Float:angJumpReach[3]; 
	
	// Check if we need to jump over a wall or something.
	if (!bSlenderShouldJump && bSlenderOnGround && !bSlenderTeleportedOnStep && flSlenderJumpSpeed > 0.0 && GetVectorLength(flDesiredVelocity) > 0.0 &&
		GetGameTime() >= g_flSlenderNextJump[iBossIndex])
	{
		new Float:flZDiff = (flGoalPosition[2] - flMyPos[2]);
		
		if (flZDiff > flSlenderStepSize)
		{
			// Our path has a jump thingy to it. Calculate the jump height needed to reach it and how far away we should start
			// checking on when to jump.
			
			decl Float:vecDir[3], Float:vecDesiredDir[3];
			GetVectorAngles(flMyVelocity, vecDir);
			SubtractVectors(flGoalPosition, flMyPos, vecDesiredDir);
			GetVectorAngles(vecDesiredDir, vecDesiredDir);
			
			if ((FloatAbs(AngleDiff(vecDir[0], vecDesiredDir[0])) + FloatAbs(AngleDiff(vecDir[1], vecDesiredDir[1]))) >= 45.0)
			{
				// Assuming we are actually capable of making the jump, find out WHEN we have to jump,
				// based on 2D distance between our position and the target point, and our current horizontal 
				// velocity.
				
				decl Float:vecMyPos2D[3], Float:vecGoalPos2D[3];
				vecMyPos2D[0] = flMyPos[0];
				vecMyPos2D[1] = flMyPos[1];
				vecMyPos2D[2] = 0.0;
				vecGoalPos2D[0] = flGoalPosition[0];
				vecGoalPos2D[1] = flGoalPosition[1];
				vecGoalPos2D[2] = 0.0;
				
				new Float:fl2DDist = GetVectorDistance(vecMyPos2D, vecGoalPos2D);
				
				new Float:flNotImaginary = Pow(flSlenderJumpSpeed, 4.0) - (g_flGravity * (g_flGravity * Pow(fl2DDist, 2.0)) + (2.0 * flZDiff * Pow(flSlenderJumpSpeed, 2.0)));
				if (flNotImaginary >= 0.0)
				{
					// We can reach it.
					new Float:flNotInfinite = g_flGravity * fl2DDist;
					if (flNotInfinite > 0.0)
					{
						SubtractVectors(vecGoalPos2D, vecMyPos2D, angJumpReach);
						GetVectorAngles(angJumpReach, angJumpReach);
						angJumpReach[0] = -RadToDeg(ArcTangent((Pow(flSlenderJumpSpeed, 2.0) + SquareRoot(flNotImaginary)) / flNotInfinite));
						bSlenderShouldJump = true;
					}
				}
			}
		}
	}
	
	if (bSlenderOnGround && bSlenderShouldJump)
	{
		g_flSlenderNextJump[iBossIndex] = GetGameTime() + GetProfileFloat(sSlenderProfile, "jump_cooldown", 2.0);
		
		decl Float:vecJump[3];
		GetAngleVectors(angJumpReach, vecJump, NULL_VECTOR, NULL_VECTOR);
		NormalizeVector(vecJump, vecJump);
		ScaleVector(vecJump, flSlenderJumpSpeed);
		AddVectors(flMoveVelocity, vecJump, flMoveVelocity);
	}
	else 
	{
		// We are in no position to defy gravity.
		flMoveVelocity[2] = flMyVelocity[2];
	}
	
	decl Float:flMoveAng[3];
	new bool:bChangeAngles = false;
	
	// Process angles.
	if (iState != STATE_ATTACK && iState != STATE_STUN)
	{
		if (NPCHasAttribute(iBossIndex, "always look at target"))
		{
			new iTarget = EntRefToEntIndex(g_iSlenderTarget[iBossIndex]);
			
			if (iTarget && iTarget != INVALID_ENT_REFERENCE)
			{
				decl Float:flTargetPos[3];
				GetEntPropVector(iTarget, Prop_Data, "m_vecAbsOrigin", flTargetPos);
				SubtractVectors(flTargetPos, flMyPos, flMoveAng);
				GetVectorAngles(flMoveAng, flMoveAng);
			}
			else
			{
				SubtractVectors(flGoalPosition, flMyPos, flMoveAng);
				GetVectorAngles(flMoveAng, flMoveAng);
			}
		}
		else
		{
			SubtractVectors(flGoalPosition, flMyPos, flMoveAng);
			GetVectorAngles(flMoveAng, flMoveAng);
		}
		
		new Float:flTurnRate = NPCGetTurnRate(iBossIndex);
		if (iState == STATE_CHASE) flTurnRate *= 2.0;
		
		flMoveAng[0] = 0.0;
		flMoveAng[2] = 0.0;
		flMoveAng[1] = ApproachAngle(flMoveAng[1], flMyEyeAng[1], flTurnRate * flFrameTime);
		
		bChangeAngles = true;
	}
	
	TeleportEntity(iBoss, NULL_VECTOR, bChangeAngles ? flMoveAng : NULL_VECTOR, flMoveVelocity);
}

// Shortest-path cost function for NavMesh_BuildPath.
public SlenderChaseBossShortestPathCost(iAreaIndex, iFromAreaIndex, iLadderIndex, any:iStepSize)
{
	if (iFromAreaIndex == -1)
	{
		return 0;
	}
	else
	{
		new iDist;
		decl Float:flAreaCenter[3], Float:flFromAreaCenter[3];
		NavMeshArea_GetCenter(iAreaIndex, flAreaCenter);
		NavMeshArea_GetCenter(iFromAreaIndex, flFromAreaCenter);
		
		if (iLadderIndex != -1)
		{
			iDist = RoundFloat(NavMeshLadder_GetLength(iLadderIndex));
		}
		else
		{
			iDist = RoundFloat(GetVectorDistance(flAreaCenter, flFromAreaCenter));
		}
		
		new iCost = iDist + NavMeshArea_GetCostSoFar(iFromAreaIndex);
		
		new iAreaFlags = NavMeshArea_GetFlags(iAreaIndex);
		if (iAreaFlags & NAV_MESH_CROUCH) iCost += 20;
		if (iAreaFlags & NAV_MESH_JUMP) iCost += (5 * iDist);
		
		if ((flAreaCenter[2] - flFromAreaCenter[2]) > iStepSize) iCost += iStepSize;
		
		return iCost;
	}
}

public Action:Timer_SlenderChaseBossAttack(Handle:timer, any:entref)
{
	if (!g_bEnabled) return;

	new slender = EntRefToEntIndex(entref);
	if (!slender || slender == INVALID_ENT_REFERENCE) return;
	
	new iBossIndex = NPCGetFromEntIndex(slender);
	if (iBossIndex == -1) return;
	
	if (timer != g_hSlenderAttackTimer[iBossIndex]) return;
	
	if (NPCGetFlags(iBossIndex) & SFF_FAKE)
	{
		SlenderMarkAsFake(iBossIndex);
		return;
	}
	
	decl String:sProfile[SF2_MAX_PROFILE_NAME_LENGTH];
	NPCGetProfile(iBossIndex, sProfile, sizeof(sProfile));
	
	new bool:bAttackEliminated = bool:(NPCGetFlags(iBossIndex) & SFF_ATTACKWAITERS);
	
	new Float:flDamage = NPCChaserGetAttackDamage(iBossIndex, 0);
	new Float:flDamageVsProps = NPCChaserGetAttackDamageVsProps(iBossIndex, 0);
	new iDamageType = NPCChaserGetAttackDamageType(iBossIndex, 0);
	
	// Damage all players within range.
	decl Float:flMyEyePos[3], Float:flMyEyeAng[3];
	NPCGetEyePosition(iBossIndex, flMyEyePos);
	GetEntPropVector(slender, Prop_Data, "m_angAbsRotation", flMyEyeAng);
	AddVectors(g_flSlenderEyePosOffset[iBossIndex], flMyEyeAng, flMyEyeAng);
	for (new i = 0; i < 3; i++) flMyEyeAng[i] = AngleNormalize(flMyEyeAng[i]);
	
	decl Float:flViewPunch[3];
	GetProfileVector(sProfile, "attack_punchvel", flViewPunch);
	
	decl Float:flTargetDist;
	decl Handle:hTrace;
	
	new Float:flAttackRange = NPCChaserGetAttackRange(iBossIndex, 0);
	new Float:flAttackFOV = NPCChaserGetAttackSpread(iBossIndex, 0);
	new Float:flAttackDamageForce = NPCChaserGetAttackDamageForce(iBossIndex, 0);
	
	new bool:bHit = false;
	
	{
		new prop = -1;
		while ((prop = FindEntityByClassname(prop, "prop_physics")) != -1)
		{
			if (NPCAttackValidateTarget(iBossIndex, prop, flAttackRange, flAttackFOV))
			{
				bHit = true;
				SDKHooks_TakeDamage(prop, slender, slender, flDamageVsProps, iDamageType, _, _, flMyEyePos);
				new Float:SpreadVel = 1800.0;
				new Float:VertVel = 1300.0;
				new Float:vel[3];
				GetAngleVectors(flMyEyeAng, vel, NULL_VECTOR, NULL_VECTOR);
				ScaleVector(vel,SpreadVel);
				vel[2] = ((GetURandomFloat() + 0.1) * VertVel) * ((GetURandomFloat() + 0.1) * 2);
				TeleportEntity(prop, NULL_VECTOR, NULL_VECTOR, vel);
			}
		}
		
		prop = -1;
		while ((prop = FindEntityByClassname(prop, "prop_dynamic")) != -1)
		{
			if (GetEntProp(prop, Prop_Data, "m_iHealth") > 0)
			{
				if (NPCAttackValidateTarget(iBossIndex, prop, flAttackRange, flAttackFOV))
				{
					bHit = true;
					SDKHooks_TakeDamage(prop, slender, slender, flDamageVsProps, iDamageType, _, _, flMyEyePos);
				}
			}
		}
	}
	
	for (new i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i) || !IsPlayerAlive(i) || IsClientInGhostMode(i)) continue;
		
		if (!bAttackEliminated && g_bPlayerEliminated[i]) continue;
		
		decl Float:flTargetPos[3];
		GetClientEyePosition(i, flTargetPos);
		
		hTrace = TR_TraceRayFilterEx(flMyEyePos,
			flTargetPos,
			MASK_NPCSOLID,
			RayType_EndPoint,
			TraceRayDontHitEntity,
			slender);
		
		new bool:bTraceDidHit = TR_DidHit(hTrace);
		new iTraceHitEntity = TR_GetEntityIndex(hTrace);
		CloseHandle(hTrace);
		
		if (bTraceDidHit && iTraceHitEntity != i)
		{
			decl Float:flTargetMins[3], Float:flTargetMaxs[3];
			GetEntPropVector(i, Prop_Send, "m_vecMins", flTargetMins);
			GetEntPropVector(i, Prop_Send, "m_vecMaxs", flTargetMaxs);
			GetClientAbsOrigin(i, flTargetPos);
			for (new i2 = 0; i2 < 3; i2++) flTargetPos[i2] += ((flTargetMins[i2] + flTargetMaxs[i2]) / 2.0);
			
			hTrace = TR_TraceRayFilterEx(flMyEyePos,
				flTargetPos,
				MASK_NPCSOLID,
				RayType_EndPoint,
				TraceRayDontHitEntity,
				slender);
				
			bTraceDidHit = TR_DidHit(hTrace);
			iTraceHitEntity = TR_GetEntityIndex(hTrace);
			CloseHandle(hTrace);
		}
		
		if (!bTraceDidHit || iTraceHitEntity == i)
		{
			flTargetDist = GetVectorDistance(flTargetPos, flMyEyePos);
			
			if (flTargetDist <= flAttackRange)
			{
				decl Float:flDirection[3];
				SubtractVectors(flTargetPos, flMyEyePos, flDirection);
				GetVectorAngles(flDirection, flDirection);
				
				if (FloatAbs(AngleDiff(flDirection[1], flMyEyeAng[1])) <= flAttackFOV)
				{
					bHit = true;
					GetAngleVectors(flDirection, flDirection, NULL_VECTOR, NULL_VECTOR);
					NormalizeVector(flDirection, flDirection);
					ScaleVector(flDirection, flAttackDamageForce);
					
					Call_StartForward(fOnClientDamagedByBoss);
					Call_PushCell(i);
					Call_PushCell(iBossIndex);
					Call_PushCell(slender);
					Call_PushFloat(flDamage);
					Call_PushCell(iDamageType);
					Call_Finish();
					
					SDKHooks_TakeDamage(i, slender, slender, flDamage, iDamageType, _, flDirection, flMyEyePos);
					ClientViewPunch(i, flViewPunch);
					
					if (NPCHasAttribute(iBossIndex, "bleed player on hit"))
					{
						new Float:flDuration = NPCGetAttributeValue(iBossIndex, "bleed player on hit");
						if (flDuration > 0.0)
						{
							TF2_MakeBleed(i, slender, flDuration);
						}
					}
					
					// Add stress
					new Float:flStressScalar = flDamage / 125.0;
					if (flStressScalar > 1.0) flStressScalar = 1.0;
					ClientAddStress(i, 0.33 * flStressScalar);
				}
			}
		}
	}
	
	decl String:sSoundPath[PLATFORM_MAX_PATH];
	
	if (bHit)
	{
		// Fling it.
		new phys = CreateEntityByName("env_physexplosion");
		if (phys != -1)
		{
			TeleportEntity(phys, flMyEyePos, NULL_VECTOR, NULL_VECTOR);
			DispatchKeyValue(phys, "spawnflags", "1");
			DispatchKeyValueFloat(phys, "radius", flAttackRange);
			DispatchKeyValueFloat(phys, "magnitude", flAttackDamageForce);
			DispatchSpawn(phys);
			ActivateEntity(phys);
			AcceptEntityInput(phys, "Explode");
			AcceptEntityInput(phys, "Kill");
		}
		
		GetRandomStringFromProfile(sProfile, "sound_hitenemy", sSoundPath, sizeof(sSoundPath));
		if (sSoundPath[0]) EmitSoundToAll(sSoundPath, slender, SNDCHAN_AUTO, SNDLEVEL_SCREAMING);
	}
	else
	{
		GetRandomStringFromProfile(sProfile, "sound_missenemy", sSoundPath, sizeof(sSoundPath));
		if (sSoundPath[0]) EmitSoundToAll(sSoundPath, slender, SNDCHAN_AUTO, SNDLEVEL_SCREAMING);
	}
	
	g_hSlenderAttackTimer[iBossIndex] = CreateTimer(GetProfileFloat(sProfile, "attack_endafter"), Timer_SlenderChaseBossAttackEnd, entref, TIMER_FLAG_NO_MAPCHANGE);
}

static NPCAttackValidateTarget(iBossIndex, iTarget, Float:flAttackRange, Float:flAttackFOV)
{
	new iBoss = NPCGetEntIndex(iBossIndex);
	
	decl Float:flMyEyePos[3], Float:flMyEyeAng[3];
	NPCGetEyePosition(iBossIndex, flMyEyePos);
	if(iTarget>64)//We asume it's a prop
		flMyEyePos[2]+=30.0;
	GetEntPropVector(iBoss, Prop_Data, "m_angAbsRotation", flMyEyeAng);
	AddVectors(g_flSlenderEyeAngOffset[iBossIndex], flMyEyeAng, flMyEyeAng);
	for (new i = 0; i < 3; i++) flMyEyeAng[i] = AngleNormalize(flMyEyeAng[i]);
	
	decl Float:flTargetPos[3], Float:flTargetMins[3], Float:flTargetMaxs[3];
	GetEntPropVector(iTarget, Prop_Data, "m_vecAbsOrigin", flTargetPos);
	GetEntPropVector(iTarget, Prop_Send, "m_vecMins", flTargetMins);
	GetEntPropVector(iTarget, Prop_Send, "m_vecMaxs", flTargetMaxs);
	
	for (new i = 0; i < 3; i++)
	{
		flTargetPos[i] += (flTargetMins[i] + flTargetMaxs[i]) / 2.0;
	}
	
	new Float:flTargetDist = GetVectorDistance(flTargetPos, flMyEyePos);
	if (flTargetDist <= flAttackRange)
	{
		decl Float:flDirection[3];
		SubtractVectors(g_flSlenderGoalPos[iBossIndex], flMyEyePos, flDirection);
		GetVectorAngles(flDirection, flDirection);
		
		if (FloatAbs(AngleDiff(flDirection[1], flMyEyeAng[1])) <= flAttackFOV / 2.0)
		{
			new Handle:hTrace = TR_TraceRayFilterEx(flMyEyePos,
				flTargetPos,
				MASK_NPCSOLID,
				RayType_EndPoint,
				TraceRayDontHitEntity,
				iBoss);
				
			new bool:bTraceDidHit = TR_DidHit(hTrace);
			new iTraceHitEntity = TR_GetEntityIndex(hTrace);
			CloseHandle(hTrace);
			
			if (!bTraceDidHit || iTraceHitEntity == iTarget)
			{
				return true;
			}
		}
	}
	
	return false;
}
static NPCPropPhysicsAttack(iBossIndex, prop)
{
	decl String:buffer[PLATFORM_MAX_PATH], String:sProfile[SF2_MAX_PROFILE_NAME_LENGTH], String:model[SF2_MAX_PROFILE_NAME_LENGTH], String:key[64];
	NPCGetProfile(iBossIndex, sProfile, sizeof(sProfile));
	KvRewind(g_hConfig);
	KvJumpToKey(g_hConfig, sProfile);
	if(!IsValidEntity(prop))return false;
	GetEntPropString(prop, Prop_Data, "m_ModelName", model, sizeof(model));
	if (!KvJumpToKey(g_hConfig, "attack_props_physics_models")) return true;
	new bool:bFound=false;
	for(new i=1; ; i++)
	{
		IntToString(i, key, sizeof(key));
		KvGetString(g_hConfig, key, buffer, PLATFORM_MAX_PATH);
		if(!buffer[0])
		{
			break;
		}
		if(StrEqual(buffer,model))
		{
			bFound = true;
			break;
		}
	}
	return bFound;
}
public Action:Timer_SlenderChaseBossAttackEnd(Handle:timer, any:entref)
{
	if (!g_bEnabled) return;

	new slender = EntRefToEntIndex(entref);
	if (!slender || slender == INVALID_ENT_REFERENCE) return;
	
	new iBossIndex = NPCGetFromEntIndex(slender);
	if (iBossIndex == -1) return;
	
	if (timer != g_hSlenderAttackTimer[iBossIndex]) return;
	
	g_bSlenderAttacking[iBossIndex] = false;
	g_hSlenderAttackTimer[iBossIndex] = INVALID_HANDLE;
}