#if defined _sf2_npc_chaser_included
 #endinput
#endif
#define _sf2_npc_chaser_included

static float g_flNPCStepSize[MAX_BOSSES];

static float g_flNPCWalkSpeed[MAX_BOSSES][Difficulty_Max];
static float g_flNPCAirSpeed[MAX_BOSSES][Difficulty_Max];

static float g_flNPCMaxWalkSpeed[MAX_BOSSES][Difficulty_Max];
static float g_flNPCMaxAirSpeed[MAX_BOSSES][Difficulty_Max];

static float g_flNPCWakeRadius[MAX_BOSSES];

static bool g_bNPCStunEnabled[MAX_BOSSES];
static float g_flNPCStunDuration[MAX_BOSSES];
static bool g_bNPCStunFlashlightEnabled[MAX_BOSSES];
static bool g_bNPCHasKeyDrop[MAX_BOSSES];
static float g_flNPCStunFlashlightDamage[MAX_BOSSES];
static float g_flNPCStunInitialHealth[MAX_BOSSES];
static float g_flNPCStunHealth[MAX_BOSSES];

static int g_iNPCState[MAX_BOSSES] = { -1, ... };
static int g_iNPCTeleporter[MAX_BOSSES][MAX_NPCTELEPORTER];
static int g_iNPCMovementActivity[MAX_BOSSES] = { -1, ... };
static int g_iGeneralDist;

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


const SF2NPC_Chaser SF2_INVALID_NPC_CHASER = view_as<SF2NPC_Chaser>(-1);


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
		public set(float amount) { NPCChaserSetStunInitialHealth(this.Index, amount); }
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
	
	public int GetTeleporter(int iTeleporterNumber)
	{
		return NPCChaserGetTeleporter(this.Index,iTeleporterNumber);
	}
	
	public void SetTeleporter(int iTeleporterNumber,int iEntity)
	{
		NPCChaserSetTeleporter(this.Index,iTeleporterNumber,iEntity);
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

public void NPCChaserSetTeleporter(int iBossIndex, int iTeleporterNumber, int iEntity)
{
	g_iNPCTeleporter[iBossIndex][iTeleporterNumber] = iEntity;
}

public int NPCChaserGetTeleporter(int iBossIndex, int iTeleporterNumber)
{
	return g_iNPCTeleporter[iBossIndex][iTeleporterNumber];
}

public void NPCChaserInitialize()
{
	for (int iNPCIndex = 0; iNPCIndex < MAX_BOSSES; iNPCIndex++)
	{
		NPCChaserResetValues(iNPCIndex);
	}
}

float NPCChaserGetWalkSpeed(int iNPCIndex,int iDifficulty)
{
	return g_flNPCWalkSpeed[iNPCIndex][iDifficulty];
}

void NPCChaserSetWalkSpeed(int iNPCIndex, int iDifficulty, float flAmount)
{
	g_flNPCWalkSpeed[iNPCIndex][iDifficulty] = flAmount;
}

float NPCChaserGetAirSpeed(int iNPCIndex,int iDifficulty)
{
	return g_flNPCAirSpeed[iNPCIndex][iDifficulty];
}

void NPCChaserSetAirSpeed(int iNPCIndex, int iDifficulty, float flAmount)
{
	g_flNPCAirSpeed[iNPCIndex][iDifficulty] = flAmount;
}

float NPCChaserGetMaxWalkSpeed(int iNPCIndex,int iDifficulty)
{
	return g_flNPCMaxWalkSpeed[iNPCIndex][iDifficulty];
}

void NPCChaserSetMaxWalkSpeed(int iNPCIndex, int iDifficulty, float flAmount)
{
	g_flNPCMaxWalkSpeed[iNPCIndex][iDifficulty] = flAmount;
}

float NPCChaserGetMaxAirSpeed(int iNPCIndex,int iDifficulty)
{
	return g_flNPCMaxAirSpeed[iNPCIndex][iDifficulty];
}

void NPCChaserSetMaxAirSpeed(int iNPCIndex, int iDifficulty, float flAmount)
{
	g_flNPCMaxAirSpeed[iNPCIndex][iDifficulty] = flAmount;
}

float NPCChaserGetWakeRadius(int iNPCIndex)
{
	return g_flNPCWakeRadius[iNPCIndex];
}

float NPCChaserGetStepSize(int iNPCIndex)
{
	return g_flNPCStepSize[iNPCIndex];
}

int NPCChaserGetAttackType(int iNPCIndex,int iAttackIndex)
{
	return g_NPCBaseAttacks[iNPCIndex][iAttackIndex][SF2NPCChaser_BaseAttackType];
}

float NPCChaserGetAttackDamage(int iNPCIndex,int iAttackIndex)
{
	return g_NPCBaseAttacks[iNPCIndex][iAttackIndex][SF2NPCChaser_BaseAttackDamage];
}

float NPCChaserGetAttackDamageVsProps(int iNPCIndex,int iAttackIndex)
{
	return g_NPCBaseAttacks[iNPCIndex][iAttackIndex][SF2NPCChaser_BaseAttackDamageVsProps];
}

float NPCChaserGetAttackDamageForce(int iNPCIndex,int iAttackIndex)
{
	return g_NPCBaseAttacks[iNPCIndex][iAttackIndex][SF2NPCChaser_BaseAttackDamageForce];
}

int NPCChaserGetAttackDamageType(int iNPCIndex,int iAttackIndex)
{
	return g_NPCBaseAttacks[iNPCIndex][iAttackIndex][SF2NPCChaser_BaseAttackDamageType];
}

float NPCChaserGetAttackDamageDelay(int iNPCIndex,int iAttackIndex)
{
	return g_NPCBaseAttacks[iNPCIndex][iAttackIndex][SF2NPCChaser_BaseAttackDamageDelay];
}

float NPCChaserGetAttackRange(int iNPCIndex,int iAttackIndex)
{
	return g_NPCBaseAttacks[iNPCIndex][iAttackIndex][SF2NPCChaser_BaseAttackRange];
}

float NPCChaserGetAttackDuration(int iNPCIndex,int iAttackIndex)
{
	return g_NPCBaseAttacks[iNPCIndex][iAttackIndex][SF2NPCChaser_BaseAttackDuration];
}

float NPCChaserGetAttackSpread(int iNPCIndex,int iAttackIndex)
{
	return g_NPCBaseAttacks[iNPCIndex][iAttackIndex][SF2NPCChaser_BaseAttackSpread];
}

float NPCChaserGetAttackBeginRange(int iNPCIndex,int iAttackIndex)
{
	return g_NPCBaseAttacks[iNPCIndex][iAttackIndex][SF2NPCChaser_BaseAttackBeginRange];
}

float NPCChaserGetAttackBeginFOV(int iNPCIndex,int iAttackIndex)
{
	return g_NPCBaseAttacks[iNPCIndex][iAttackIndex][SF2NPCChaser_BaseAttackBeginFOV];
}

bool NPCChaserIsStunEnabled(int iNPCIndex)
{
	return g_bNPCStunEnabled[iNPCIndex];
}

bool NPCChaserIsStunByFlashlightEnabled(int iNPCIndex)
{
	return g_bNPCStunFlashlightEnabled[iNPCIndex];
}

bool NPCChaseHasKeyDrop(int iNPCIndex)
{
	return g_bNPCHasKeyDrop[iNPCIndex];
}

float NPCChaserGetStunFlashlightDamage(int iNPCIndex)
{
	return g_flNPCStunFlashlightDamage[iNPCIndex];
}

float NPCChaserGetStunDuration(int iNPCIndex)
{
	return g_flNPCStunDuration[iNPCIndex];
}

float NPCChaserGetStunHealth(int iNPCIndex)
{
	return g_flNPCStunHealth[iNPCIndex];
}

void NPCChaserSetStunHealth(int iNPCIndex, float flAmount)
{
	g_flNPCStunHealth[iNPCIndex] = flAmount;
}

void NPCChaserSetStunInitialHealth(int iNPCIndex, float flAmount)
{
	g_flNPCStunInitialHealth[iNPCIndex] = flAmount;
}

void NPCChaserAddStunHealth(int iNPCIndex, float flAmount)
{
	NPCChaserSetStunHealth(iNPCIndex, NPCChaserGetStunHealth(iNPCIndex) + flAmount);
#if defined DEBUG
	SendDebugMessageToPlayers(DEBUG_BOSS_STUN,0,"Boss %i, new amount: %0.0f",iNPCIndex,NPCChaserGetStunHealth(iNPCIndex));
#endif
}

float NPCChaserGetStunInitialHealth(int iNPCIndex)
{
	return g_flNPCStunInitialHealth[iNPCIndex];
}

int NPCChaserGetState(int iNPCIndex)
{
	return g_iNPCState[iNPCIndex];
}

void NPCChaserSetState(int iNPCIndex,int iState)
{
	g_iNPCState[iNPCIndex] = iState;
}

int NPCChaserGetMovementActivity(int iNPCIndex)
{
	return g_iNPCMovementActivity[iNPCIndex];
}

int NPCChaserSetMovementActivity(int iNPCIndex,int iMovementActivity)
{
	g_iNPCMovementActivity[iNPCIndex] = iMovementActivity;
}

int NPCChaserOnSelectProfile(int iNPCIndex)
{
	int iUniqueProfileIndex = NPCGetUniqueProfileIndex(iNPCIndex);

	g_flNPCWakeRadius[iNPCIndex] = GetChaserProfileWakeRadius(iUniqueProfileIndex);
	g_flNPCStepSize[iNPCIndex] = GetChaserProfileStepSize(iUniqueProfileIndex);
	
	for (int iDifficulty = 0; iDifficulty < Difficulty_Max; iDifficulty++)
	{
		g_flNPCWalkSpeed[iNPCIndex][iDifficulty] = GetChaserProfileWalkSpeed(iUniqueProfileIndex, iDifficulty);
		g_flNPCAirSpeed[iNPCIndex][iDifficulty] = GetChaserProfileAirSpeed(iUniqueProfileIndex, iDifficulty);
		
		g_flNPCMaxWalkSpeed[iNPCIndex][iDifficulty] = GetChaserProfileMaxWalkSpeed(iUniqueProfileIndex, iDifficulty);
		g_flNPCMaxAirSpeed[iNPCIndex][iDifficulty] = GetChaserProfileMaxAirSpeed(iUniqueProfileIndex, iDifficulty);
	}
	
	// Get attack data.
	for (int i = 0; i < GetChaserProfileAttackCount(iUniqueProfileIndex); i++)
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
	
	//Get Key Data
	g_bNPCHasKeyDrop[iNPCIndex] = GetChaserProfileKeyDrop(iUniqueProfileIndex);
	
	float fStunHealthPerPlayer = GetChaserProfileStunHealthPerPlayer(iUniqueProfileIndex);
	int count;
	for(int iClient;iClient<=MaxClients;iClient++)
		if(IsValidClient(iClient) && g_bPlayerEliminated[iClient])
			count++;
	fStunHealthPerPlayer *= float(count);
	g_flNPCStunInitialHealth[iNPCIndex] += fStunHealthPerPlayer;
	
	NPCChaserSetStunHealth(iNPCIndex, NPCChaserGetStunInitialHealth(iNPCIndex));
}

void NPCChaserOnRemoveProfile(int iNPCIndex)
{
	NPCChaserResetValues(iNPCIndex);
}

/**
 *	Resets all global variables on a specified NPC. Usually this should be done last upon removing a boss from the game.
 */
static void NPCChaserResetValues(int iNPCIndex)
{
	g_flNPCWakeRadius[iNPCIndex] = 0.0;
	g_flNPCStepSize[iNPCIndex] = 0.0;
	
	for (int iDifficulty = 0; iDifficulty < Difficulty_Max; iDifficulty++)
	{
		g_flNPCWalkSpeed[iNPCIndex][iDifficulty] = 0.0;
		g_flNPCAirSpeed[iNPCIndex][iDifficulty] = 0.0;
		
		g_flNPCMaxWalkSpeed[iNPCIndex][iDifficulty] = 0.0;
		g_flNPCMaxAirSpeed[iNPCIndex][iDifficulty] = 0.0;
	}
	
	// Clear attack data.
	for (int i = 0; i < SF2_CHASER_BOSS_MAX_ATTACKS; i++)
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

stock bool IsTargetValidForSlender(int iTarget, bool bIncludeEliminated=false)
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

public Action Timer_SlenderChaseBossThink(Handle timer, any entref)
{
	if (!g_bEnabled) return Plugin_Stop;

	int slender = EntRefToEntIndex(entref);
	if (!slender || slender == INVALID_ENT_REFERENCE) return Plugin_Stop;
	
	int iBossIndex = NPCGetFromEntIndex(slender);
	if (iBossIndex == -1) return Plugin_Stop;
	
	if (timer != g_hSlenderEntityThink[iBossIndex]) return Plugin_Stop;
	
	if (NPCGetFlags(iBossIndex) & SFF_MARKEDASFAKE) return Plugin_Stop;
	
	float flSlenderVelocity[3], flMyPos[3], flMyEyeAng[3];
	float flBuffer[3];
	
	char sSlenderProfile[SF2_MAX_PROFILE_NAME_LENGTH];
	NPCGetProfile(iBossIndex, sSlenderProfile, sizeof(sSlenderProfile));
	
	GetEntPropVector(slender, Prop_Data, "m_vecAbsVelocity", flSlenderVelocity);
	GetEntPropVector(slender, Prop_Data, "m_vecAbsOrigin", flMyPos);
	GetEntPropVector(slender, Prop_Data, "m_angAbsRotation", flMyEyeAng);
	AddVectors(flMyEyeAng, g_flSlenderEyeAngOffset[iBossIndex], flMyEyeAng);
	for (int i = 0; i < 3; i++) flMyEyeAng[i] = AngleNormalize(flMyEyeAng[i]);
	
	int iDifficulty = GetConVarInt(g_cvDifficulty);
	
	float flVelocityRatio;
	float flVelocityRatioWalk;
	
	float flOriginalSpeed = NPCGetSpeed(iBossIndex, iDifficulty);
	float flOriginalWalkSpeed = NPCChaserGetWalkSpeed(iBossIndex, iDifficulty);
	float flOriginalAirSpeed = NPCChaserGetAirSpeed(iBossIndex, iDifficulty);
	float flMaxSpeed = NPCGetMaxSpeed(iBossIndex, iDifficulty);
	float flMaxWalkSpeed = NPCChaserGetMaxWalkSpeed(iBossIndex, iDifficulty);
	float flMaxAirSpeed = NPCChaserGetMaxAirSpeed(iBossIndex, iDifficulty);
	
	float flSpeed = flOriginalSpeed * NPCGetAnger(iBossIndex) * g_flRoundDifficultyModifier;
	if (flSpeed < flOriginalSpeed) flSpeed = flOriginalSpeed;
	if (flSpeed > flMaxSpeed) flSpeed = flMaxSpeed;
	
	float flWalkSpeed = flOriginalWalkSpeed * NPCGetAnger(iBossIndex) * g_flRoundDifficultyModifier;
	if (flWalkSpeed < flOriginalWalkSpeed) flWalkSpeed = flOriginalWalkSpeed;
	if (flWalkSpeed > flMaxWalkSpeed) flWalkSpeed = flMaxWalkSpeed;
	
	float flAirSpeed = flOriginalAirSpeed * NPCGetAnger(iBossIndex) * g_flRoundDifficultyModifier;
	if (flAirSpeed < flOriginalAirSpeed) flAirSpeed = flOriginalAirSpeed;
	if (flAirSpeed > flMaxAirSpeed) flAirSpeed = flMaxAirSpeed;
	
	//It seems change air speed on difficulty level is a bad idea
	flAirSpeed = NPCChaserGetAirSpeed(iBossIndex, iDifficulty);
	
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
		
		if (NPCHasAttribute(iBossIndex, "reduced air speed on look"))
		{
			flAirSpeed *= NPCGetAttributeValue(iBossIndex, "reduced air speed on look");
		}
	}
	
	g_flSlenderCalculatedWalkSpeed[iBossIndex] = flWalkSpeed;
	g_flSlenderCalculatedSpeed[iBossIndex] = flSpeed;
	g_flSlenderCalculatedAirSpeed[iBossIndex] = flAirSpeed;
	
	if (flOriginalSpeed <= 0.0) flVelocityRatio = 0.0;
	else flVelocityRatio = GetVectorLength(flSlenderVelocity) / flOriginalSpeed;
	
	if (flOriginalWalkSpeed <= 0.0) flVelocityRatioWalk = 0.0;
	else flVelocityRatioWalk = GetVectorLength(flSlenderVelocity) / flOriginalWalkSpeed;
	
	float flAttackRange = NPCChaserGetAttackRange(iBossIndex, 0);
	float flAttackFOV = NPCChaserGetAttackSpread(iBossIndex, 0);
	float flAttackBeginRange = NPCChaserGetAttackBeginRange(iBossIndex, 0);
	float flAttackBeginFOV = NPCChaserGetAttackBeginFOV(iBossIndex, 0);
	
	
	int iOldState = g_iSlenderState[iBossIndex];
	int iOldTarget = EntRefToEntIndex(g_iSlenderTarget[iBossIndex]);
	
	int iBestNewTarget = INVALID_ENT_REFERENCE;
	float flSearchRange = NPCGetSearchRadius(iBossIndex);
	float flBestNewTargetDist = flSearchRange;
	int iState = iOldState;
	
	bool bPlayerInFOV[MAXPLAYERS + 1];
	bool bPlayerNear[MAXPLAYERS + 1];
	float flPlayerDists[MAXPLAYERS + 1];
	bool bPlayerVisible[MAXPLAYERS + 1];
	
	bool bAttackEliminated = view_as<bool>(NPCGetFlags(iBossIndex) & SFF_ATTACKWAITERS);
	bool bStunEnabled = NPCChaserIsStunEnabled(iBossIndex);
	
	float flSlenderMins[3], flSlenderMaxs[3];
	GetEntPropVector(slender, Prop_Send, "m_vecMins", flSlenderMins);
	GetEntPropVector(slender, Prop_Send, "m_vecMaxs", flSlenderMaxs);
	
	float flTraceMins[3], flTraceMaxs[3];
	flTraceMins[0] = flSlenderMins[0];
	flTraceMins[1] = flSlenderMins[1];
	flTraceMins[2] = 0.0;
	flTraceMaxs[0] = flSlenderMaxs[0];
	flTraceMaxs[1] = flSlenderMaxs[1];
	flTraceMaxs[2] = 0.0;
	
	// Gather data about the players around me and get the best new target, in case my old target is invalidated.
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsTargetValidForSlender(i, bAttackEliminated)) continue;
		
		float flTraceStartPos[3], flTraceEndPos[3];
		NPCGetEyePosition(iBossIndex, flTraceStartPos);
		GetClientEyePosition(i, flTraceEndPos);
		
		Handle hTrace = TR_TraceHullFilterEx(flTraceStartPos,
			flTraceEndPos,
			flTraceMins,
			flTraceMaxs,
			MASK_NPCSOLID,
			TraceRayBossVisibility,
			slender);
		
		bool bIsVisible = !TR_DidHit(hTrace);
		int iTraceHitEntity = TR_GetEntityIndex(hTrace);
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
		
		float flDist;
		float flPriorityValue = g_iPageMax > 0 ? (float(g_iPlayerPageCount[i]) / float(g_iPageMax)) : 0.0;
		
		if (TF2_GetPlayerClass(i) == TFClass_Medic) flPriorityValue += 0.72;
		
		flDist = GetVectorDistance(flTraceStartPos, flTraceEndPos);
		flPlayerDists[i] = flDist;
		
		if ((bPlayerNear[i] && iState != STATE_CHASE && iState != STATE_ALERT) || (bIsVisible && bPlayerInFOV[i]))
		{
			float flTargetPos[3];
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
	
	bool bInFlashlight = false;
	
	// Check to see if someone is facing at us with flashlight on. Only if I'm facing them too. BLINDNESS!
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsTargetValidForSlender(i, bAttackEliminated)) continue;
	
		if (!IsClientUsingFlashlight(i) || !bPlayerInFOV[i]) continue;
		
		float flTraceStartPos[3], flTraceEndPos[3];
		GetClientEyePosition(i, flTraceStartPos);
		NPCGetEyePosition(iBossIndex, flTraceEndPos);
		
		if (GetVectorDistance(flTraceStartPos, flTraceEndPos) <= SF2_FLASHLIGHT_LENGTH)
		{
			float flEyeAng[3], flRequiredAng[3];
			GetClientEyeAngles(i, flEyeAng);
			SubtractVectors(flTraceEndPos, flTraceStartPos, flRequiredAng);
			GetVectorAngles(flRequiredAng, flRequiredAng);
			
			if ((FloatAbs(AngleDiff(flEyeAng[0], flRequiredAng[0])) + FloatAbs(AngleDiff(flEyeAng[1], flRequiredAng[1]))) <= 45.0)
			{
				Handle hTrace = TR_TraceRayFilterEx(flTraceStartPos,
					flTraceEndPos,
					MASK_PLAYERSOLID,
					RayType_EndPoint,
					TraceRayBossVisibility,
					slender);
					
				bool bDidHit = TR_DidHit(hTrace);
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
	int iTarget = iOldTarget;
	
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
	
	int iInterruptConditions = g_iSlenderInterruptConditions[iBossIndex];
	bool bQueueForNewPath = false;
	bool bDoChasePersistencyInit = false;
	bool bCamper = false;
	if(iState != STATE_CHASE && g_bSlenderTeleportTargetIsCamping[iBossIndex] && EntRefToEntIndex(g_iSlenderTeleportTarget[iBossIndex]) != INVALID_ENT_REFERENCE)
	{
		int iCamper=EntRefToEntIndex(g_iSlenderTeleportTarget[iBossIndex]);
		if(!g_bPlayerEliminated[iCamper])
		{
			iTarget = iCamper;
			g_iSlenderTarget[iBossIndex] = EntIndexToEntRef(iCamper);
			iState=STATE_CHASE;
			bDoChasePersistencyInit = true;
			bCamper=true;
		}
		g_bSlenderTeleportTargetIsCamping[iBossIndex]=false;
	}
	if(SF_IsRaidMap() && !g_bSlenderGiveUp[iBossIndex])
	{
		if(!IsValidClient(iTarget) || (IsValidClient(iTarget) && g_bPlayerEliminated[iTarget]))
		{
			if(iState != STATE_CHASE && iState != STATE_ATTACK && iState != STATE_STUN)
			{
				Handle hArrayRaidTargets = CreateArray();
					
				for (int i = 1; i <= MaxClients; i++)
				{
					if (!IsClientInGame(i) ||
						!IsPlayerAlive(i) ||
						g_bPlayerEliminated[i] ||
						IsClientInGhostMode(i) ||
						DidClientEscape(i))
					{
						continue;
					}
					PushArrayCell(hArrayRaidTargets, i);
				}
				if(GetArraySize(hArrayRaidTargets)>0)
				{
					int iRaidTarget = GetArrayCell(hArrayRaidTargets,GetRandomInt(0, GetArraySize(hArrayRaidTargets) - 1));
					if(IsValidClient(iRaidTarget) && !g_bPlayerEliminated[iRaidTarget])
					{
						iBestNewTarget = iRaidTarget;
						g_flSlenderTimeUntilNoPersistence[iBossIndex] = GetGameTime() + GetProfileFloat(sSlenderProfile, "search_chase_duration");
						iState = STATE_CHASE;
						iTarget = iBestNewTarget;
					}
				}
				
				CloseHandle(hArrayRaidTargets);
			}
		}
		
	}
	if(IsValidClient(iTarget) && g_bPlayerIsExitCamping[iTarget])
		bCamper=true;
	//We should never give up, but sometimes it happens.
	if(g_bSlenderGiveUp[iBossIndex])
	{
		//Damit our target is unreachable for some unexplained reasons, haaaaaaaaaaaa!
		iState = STATE_IDLE;
		//Because raid maps force our state in chase mode, leave give up on true. Why? Because the server will try to calculate a path for an unreachable target..
		if(!SF_IsRaidMap())
			g_bSlenderGiveUp[iBossIndex] = false;
	}
	// Process which state we should be in.
	switch (iState)
	{
		case STATE_IDLE, STATE_WANDER:
		{
			for (int i = 0;i < MAX_NPCTELEPORTER;i++)
			{
				if (NPCChaserGetTeleporter(iBossIndex,i) != INVALID_ENT_REFERENCE)
					NPCChaserSetTeleporter(iBossIndex,i,INVALID_ENT_REFERENCE);
			}
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
			if (SF_SpecialRound(SPECIALROUND_BEACON))
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
				
				int iCount = 0;
				if (iInterruptConditions & COND_HEARDFOOTSTEP) iCount += 1;
				if (iInterruptConditions & COND_HEARDFOOTSTEPLOUD) iCount += 2;
				if (iInterruptConditions & COND_HEARDWEAPON) iCount += 5;
				if (iInterruptConditions & COND_HEARDVOICE) iCount += 10;
				
				bool bDiscardMasterPos = view_as<bool>(GetGameTime() >= g_flSlenderTargetSoundDiscardMasterPosTime[iBossIndex]);
				
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
					float flTraceStartPos[3], flTraceEndPos[3];
					NPCGetEyePosition(iBossIndex, flTraceStartPos);
					
					if (IsValidClient(iBestNewTarget)) GetClientEyePosition(iBestNewTarget, flTraceEndPos);
					else
					{
						float flTargetMins[3], flTargetMaxs[3];
						GetEntPropVector(iBestNewTarget, Prop_Send, "m_vecMins", flTargetMins);
						GetEntPropVector(iBestNewTarget, Prop_Send, "m_vecMaxs", flTargetMaxs);
						GetEntPropVector(iBestNewTarget, Prop_Data, "m_vecAbsOrigin", flTraceEndPos);
						for (int i = 0; i < 3; i++) flTraceEndPos[i] += ((flTargetMins[i] + flTargetMaxs[i]) / 2.0);
					}
					
					Handle hTrace = TR_TraceHullFilterEx(flTraceStartPos,
						flTraceEndPos,
						flTraceMins,
						flTraceMaxs,
						MASK_NPCSOLID,
						TraceRayBossVisibility,
						slender);
						
					bool bIsVisible = !TR_DidHit(hTrace);
					int iTraceHitEntity = TR_GetEntityIndex(hTrace);
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
					bool bDiscardMasterPos = view_as<bool>(GetGameTime() >= g_flSlenderTargetSoundDiscardMasterPosTime[iBossIndex]);
					
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
				
				bool bBlockingProp = false;
				
				if (NPCGetFlags(iBossIndex) & SFF_ATTACKPROPS)
				{
					bBlockingProp = NPC_CanAttackProps(iBossIndex,flAttackRange,flAttackFOV);
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
					float flTraceStartPos[3], flTraceEndPos[3];
					NPCGetEyePosition(iBossIndex, flTraceStartPos);
					
					if (IsValidClient(iTarget))
					{
						GetClientEyePosition(iTarget, flTraceEndPos);
					}
					else
					{
						float flTargetMins[3], flTargetMaxs[3];
						GetEntPropVector(iTarget, Prop_Send, "m_vecMins", flTargetMins);
						GetEntPropVector(iTarget, Prop_Send, "m_vecMaxs", flTargetMaxs);
						GetEntPropVector(iTarget, Prop_Data, "m_vecAbsOrigin", flTraceEndPos);
						for (int i = 0; i < 3; i++) flTraceEndPos[i] += ((flTargetMins[i] + flTargetMaxs[i]) / 2.0);
					}
					
					bool bIsDeathPosVisible = false;
					
					if (g_bSlenderChaseDeathPosition[iBossIndex])
					{
						Handle hTrace = TR_TraceRayFilterEx(flTraceStartPos,
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
							bool bBlockingProp = false;
							
							if (NPCGetFlags(iBossIndex) & SFF_ATTACKPROPS)
							{
								bBlockingProp = NPC_CanAttackProps(iBossIndex,flAttackRange,flAttackFOV);
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
					
						float flAttackDirection[3];
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
							bool bBlockingProp = false;
							
							if (NPCGetFlags(iBossIndex) & SFF_ATTACKPROPS)
							{
								bBlockingProp = NPC_CanAttackProps(iBossIndex,flAttackRange,flAttackFOV);
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
						g_bSlenderGiveUp[iBossIndex] = false;
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
				if (NPCChaseHasKeyDrop(iBossIndex))
				{
					NPC_DropKey(iBossIndex);
				}
			}
		}
	}
	if (bCamper && iState != STATE_ATTACK && !g_bSlenderGiveUp[iBossIndex])
	{
		bDoChasePersistencyInit = true;
		iState = STATE_CHASE;
	}
	//In Raid maps the boss should always attack the target. 
	if (SF_IsRaidMap() && iState != STATE_ATTACK && iState != STATE_STUN && IsValidClient(iTarget) && !g_bSlenderGiveUp[iBossIndex])
	{
		g_flSlenderTimeUntilNoPersistence[iBossIndex] = GetGameTime() + GetProfileFloat(sSlenderProfile, "search_chase_duration");
		iState = STATE_CHASE;
	}
	// Finally, set our new state.
	g_iSlenderState[iBossIndex] = iState;
	
	char sAnimation[64];
	int iModel = EntRefToEntIndex(g_iSlenderModel[iBossIndex]);
	
	float flPlaybackRateWalk = g_flSlenderWalkAnimationPlaybackRate[iBossIndex];
	float flPlaybackRateRun = g_flSlenderRunAnimationPlaybackRate[iBossIndex];
	float flPlaybackRateIdle = g_flSlenderIdleAnimationPlaybackRate[iBossIndex];
	
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
				g_bSlenderGiveUp[iBossIndex] = false;
				
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
					
					float flPersistencyTime = GetProfileFloat(sSlenderProfile, "search_chase_persistency_time_init", 5.0);
					if (flPersistencyTime >= 0.0)
					{
						g_flSlenderTimeUntilNoPersistence[iBossIndex] = GetGameTime() + flPersistencyTime;
					}
				}
				
				if (iState == STATE_ATTACK)
				{
					g_bSlenderAttacking[iBossIndex] = true;
					g_hSlenderAttackTimer[iBossIndex] = CreateTimer(NPCChaserGetAttackDamageDelay(iBossIndex, 0), Timer_SlenderChaseBossAttack, EntIndexToEntRef(slender), TIMER_FLAG_NO_MAPCHANGE);
					
					float flPersistencyTime = GetProfileFloat(sSlenderProfile, "search_chase_persistency_time_init_attack", -1.0);
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
						float flPersistencyTime = GetProfileFloat(sSlenderProfile, "search_chase_persistency_time_init_stun", -1.0);
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
						float flPersistencyTime = GetProfileFloat(sSlenderProfile, "search_chase_persistency_time_init", 5.0);
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
		NPCChaserSetState(iBossIndex, iState);
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
					float flMin = GetProfileFloat(sSlenderProfile, "search_wander_time_min", 4.0);
					float flMax = GetProfileFloat(sSlenderProfile, "search_wander_time_max", 6.5);
					g_flSlenderNextWanderPos[iBossIndex] = GetGameTime() + GetRandomFloat(flMin, flMax);
					
					if (NPCGetFlags(iBossIndex) & SFF_WANDERMOVE)
					{
						// We're allowed to move in wander mode. Get a new wandering position and create a path to follow.
						// If the position can't be reached, then just get to the closest area that we can get.
						float flWanderRangeMin = GetProfileFloat(sSlenderProfile, "search_wander_range_min", 400.0);
						float flWanderRangeMax = GetProfileFloat(sSlenderProfile, "search_wander_range_max", 1024.0);
						float flWanderRange = GetRandomFloat(flWanderRangeMin, flWanderRangeMax);
						
						float flWanderPos[3];
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
						float flPersistencyTime = GetProfileFloat(sSlenderProfile, "search_chase_persistency_time_init_newtarget", -1.0);
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
				if (NPCChaserGetTeleporter(iBossIndex,0) != INVALID_ENT_REFERENCE)
				{
					int iTeleporter = EntRefToEntIndex(NPCChaserGetTeleporter(iBossIndex,0));
					if (IsValidEntity(iTeleporter))
						GetEntPropVector(iTeleporter, Prop_Data, "m_vecAbsOrigin", g_flSlenderGoalPos[iBossIndex]);
				}
			}
			
			if (NavMesh_Exists())
			{
				// So by now we should have calculated our master goal position.
				// Now we use that to create a path.
				
				if (bQueueForNewPath)
				{
					ClearArray(g_hSlenderPath[iBossIndex]);
					
					int iCurrentAreaIndex = NavMesh_GetNearestArea(flMyPos);
					if (iCurrentAreaIndex != -1)
					{
						int iGoalAreaIndex = NavMesh_GetNearestArea(g_flSlenderGoalPos[iBossIndex]);
						if (iGoalAreaIndex != -1)
						{
							float flCenter[3], flCenterPortal[3], flClosestPoint[3];
							int iClosestAreaIndex = 0;
							
							g_iGeneralDist = 0;
							
							bool bPathSuccess = NavMesh_BuildPath(iCurrentAreaIndex,
							iGoalAreaIndex,
							g_flSlenderGoalPos[iBossIndex],
							SlenderChaseBossShortestPathCost,
							RoundToFloor(NPCChaserGetStepSize(iBossIndex)),
							iClosestAreaIndex);
							
							//Disabled until futher improvements.
							/*if(bPathSuccess)
							{
								//Our shortest path was a sucess, let's see if the safe one works.
								bool bSafePathSuccess = NavMesh_BuildPath(iCurrentAreaIndex,
								iGoalAreaIndex,
								g_flSlenderGoalPos[iBossIndex],
								SlenderChaseBossShortestPathCost,
								RoundToFloor(NPCChaserGetStepSize(iBossIndex)),
								iClosestAreaIndex,
								(g_iGeneralDist*2.5),
								NPCChaserGetStepSize(iBossIndex)*2.0);
								
								if(!bSafePathSuccess)
								{
									//No safe path, use the shortest path.
									bPathSuccess = NavMesh_BuildPath(iCurrentAreaIndex,
									iGoalAreaIndex,
									g_flSlenderGoalPos[iBossIndex],
									SlenderChaseBossShortestPathCost,
									RoundToFloor(NPCChaserGetStepSize(iBossIndex)),
									iClosestAreaIndex);
								}
							}*/
							
							int iTempAreaIndex = iClosestAreaIndex;
							int iTempParentAreaIndex = NavMeshArea_GetParent(iTempAreaIndex);
							int iNavDirection;
							float flHalfWidth;
							
							if (bPathSuccess)
							{
								// Path successful? Insert the goal position into our list.
								int iIndex = PushArrayCell(g_hSlenderPath[iBossIndex], g_flSlenderGoalPos[iBossIndex][0]);
								SetArrayCell(g_hSlenderPath[iBossIndex], iIndex, g_flSlenderGoalPos[iBossIndex][1], 1);
								SetArrayCell(g_hSlenderPath[iBossIndex], iIndex, g_flSlenderGoalPos[iBossIndex][2], 2);
							}
							else//This check is made to prevent expensive calculations for the server.
							{
								//Sometimes the path fails, for multiple reasons.
								float flStartPos[3];
								NavMeshArea_GetCenter(iCurrentAreaIndex, flStartPos);
								//If we are close of the goal position but we failed, let's see if player is not in a unreachable area.
								if((FloatAbs(g_flSlenderGoalPos[iBossIndex][0] - flStartPos[0])) <= 200.0 && (FloatAbs(g_flSlenderGoalPos[iBossIndex][1] - flStartPos[1])) <= 200.0)
								{
									float jumpDist = g_flSlenderGoalPos[iBossIndex][2] - flStartPos[2];
									//Jump speed and jump dist are not the same thing I know, but if the speed is under the jump dist, then we have no chance to reach this place.
									if(jumpDist > (g_flSlenderJumpSpeed[iBossIndex]+20.0))
									{
										//We can't jump there, give up...
										g_bSlenderGiveUp[iBossIndex] = true;
									}
								}
								//Some maps have non-npcs teleporters like citadel let's see if we are on the same nav area
								//I think this connected check should be done before the calculation.
								if(!NavMeshArea_IsConnected(iCurrentAreaIndex, iGoalAreaIndex) && NPCChaserGetTeleporter(iBossIndex,0) == INVALID_ENT_REFERENCE)
								{
									//Nope we aren't, give up...
									//PrintToChatAll("Wait come back!");
									g_bSlenderGiveUp[iBossIndex] = true;
								}
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
								
								int iIndex = PushArrayCell(g_hSlenderPath[iBossIndex], flClosestPoint[0]);
								SetArrayCell(g_hSlenderPath[iBossIndex], iIndex, flClosestPoint[1], 1);
								SetArrayCell(g_hSlenderPath[iBossIndex], iIndex, flClosestPoint[2], 2);
								
								iTempAreaIndex = iTempParentAreaIndex;
								iTempParentAreaIndex = NavMeshArea_GetParent(iTempAreaIndex);
							}
							
							// Set our goal position to the start node (hopefully there's something in the array).
							if (GetArraySize(g_hSlenderPath[iBossIndex]) > 0)
							{
								int iPosIndex = GetArraySize(g_hSlenderPath[iBossIndex]) - 1;
								
								g_flSlenderGoalPos[iBossIndex][0] = view_as<float>(GetArrayCell(g_hSlenderPath[iBossIndex], iPosIndex, 0));
								g_flSlenderGoalPos[iBossIndex][1] = view_as<float>(GetArrayCell(g_hSlenderPath[iBossIndex], iPosIndex, 1));
								g_flSlenderGoalPos[iBossIndex][2] = view_as<float>(GetArrayCell(g_hSlenderPath[iBossIndex], iPosIndex, 2));
							}
#if defined DEBUG
							iTempAreaIndex = iClosestAreaIndex;
							iTempParentAreaIndex = NavMeshArea_GetParent(iTempAreaIndex);
							
							Handle hPositions = CreateArray(3);
							
							PushArrayArray(hPositions, g_flSlenderGoalPos[iBossIndex], 3);
							
							while (iTempParentAreaIndex != -1)
							{
								float flTempAreaCenter[3], flParentAreaCenter[3];
								NavMeshArea_GetCenter(iTempAreaIndex, flTempAreaCenter);
								NavMeshArea_GetCenter(iTempParentAreaIndex, flParentAreaCenter);
								
								iNavDirection = NavMeshArea_ComputeDirection(iTempAreaIndex, flParentAreaCenter);
								NavMeshArea_ComputePortal(iTempAreaIndex, iTempParentAreaIndex, iNavDirection, flCenterPortal, flHalfWidth);
								NavMeshArea_ComputeClosestPointInPortal(iTempAreaIndex, iTempParentAreaIndex, iNavDirection, flCenterPortal, flClosestPoint);
								
								flClosestPoint[2] = NavMeshArea_GetZ(iTempAreaIndex, flClosestPoint);
								
								PushArrayArray(hPositions, flClosestPoint, 3);
								
								iTempAreaIndex = iTempParentAreaIndex;
								iTempParentAreaIndex = NavMeshArea_GetParent(iTempAreaIndex);
							}
							int iColor[4] = { 0, 255, 0, 255 };
							float flStartPos[3];
							NavMeshArea_GetCenter(iCurrentAreaIndex, flStartPos);
							PushArrayArray(hPositions, flStartPos, 3);
							
							for (int i = GetArraySize(hPositions) - 1; i > 0; i--)
							{
								float flFromPos[3], flToPos[3];
								GetArrayArray(hPositions, i, flFromPos, 3);
								GetArrayArray(hPositions, i - 1, flToPos, 3);
								
								TE_SetupBeamPoints(flFromPos,
									flToPos,
									g_iPathLaserModelIndex,
									g_iPathLaserModelIndex,
									0,
									30,
									5.0,
									5.0,
									5.0,
									5, 
									0.0,
									iColor,
									30);
									
								TE_SendToAll();
							}
							CloseHandle(hPositions);
#endif
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
						float flDistRatio = flPlayerDists[iTarget] / NPCGetSearchRadius(iBossIndex);
						
						float flChaseDurationTimeAddMin = GetProfileFloat(sSlenderProfile, "search_chase_duration_add_visible_min", 0.025);
						float flChaseDurationTimeAddMax = GetProfileFloat(sSlenderProfile, "search_chase_duration_add_visible_max", 0.2);
						
						float flChaseDurationAdd = flChaseDurationTimeAddMax - ((flChaseDurationTimeAddMax - flChaseDurationTimeAddMin) * flDistRatio);
						
						if (flChaseDurationAdd > 0.0)
						{
							g_flSlenderTimeUntilAlert[iBossIndex] += flChaseDurationAdd;
							if (g_flSlenderTimeUntilAlert[iBossIndex] > (GetGameTime() + GetProfileFloat(sSlenderProfile, "search_chase_duration")))
							{
								g_flSlenderTimeUntilAlert[iBossIndex] = GetGameTime() + GetProfileFloat(sSlenderProfile, "search_chase_duration");
							}
						}
						
						float flPersistencyTimeAddMin = GetProfileFloat(sSlenderProfile, "search_chase_persistency_time_add_visible_min", 0.05);
						float flPersistencyTimeAddMax = GetProfileFloat(sSlenderProfile, "search_chase_persistency_time_add_visible_max", 0.15);
						
						float flPersistencyTimeAdd = flPersistencyTimeAddMax - ((flPersistencyTimeAddMax - flPersistencyTimeAddMin) * flDistRatio);
						
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
				float flHitNormal[3];
				float flNodePos[3];
				
				float flNodeToleranceDist = g_flSlenderPathNodeTolerance[iBossIndex];
				bool bGotNewPoint = false;
				
				for (int iNodeIndex = 0, iNodeCount = GetArraySize(g_hSlenderPath[iBossIndex]); iNodeIndex < iNodeCount; iNodeIndex++)
				{
					flNodePos[0] = view_as<float>(GetArrayCell(g_hSlenderPath[iBossIndex], iNodeIndex, 0));
					flNodePos[1] = view_as<float>(GetArrayCell(g_hSlenderPath[iBossIndex], iNodeIndex, 1));
					flNodePos[2] = view_as<float>(GetArrayCell(g_hSlenderPath[iBossIndex], iNodeIndex, 2));
					
					Handle hTrace = TR_TraceHullFilterEx(flMyPos,
						flNodePos, 
						flSlenderMins, 
						flSlenderMaxs, 
						MASK_NPCSOLID, 
						TraceRayDontHitCharactersOrEntity, 
						slender);
						
					bool bDidHit = TR_DidHit(hTrace);
					TR_GetPlaneNormal(hTrace, flHitNormal);
					CloseHandle(hTrace);
					GetVectorAngles(flHitNormal, flHitNormal);
					for (int i = 0; i < 3; i++) flHitNormal[i] = AngleNormalize(flHitNormal[i]);
					
					// First check if we can see the point.
					if (!bDidHit || ((flHitNormal[0] >= 0.0 && flHitNormal[0] > 45.0) || (flHitNormal[0] < 0.0 && flHitNormal[0] < -45.0)))
					{
						bool bNearNode = false;
						
						// See if we're already near enough.
						float flDist = GetVectorDistance(flNodePos, flMyPos);
						if (flDist < flNodeToleranceDist) bNearNode = true;
						
						if (!bNearNode)
						{
							bool bOutside = false;
						
							// Then, predict if we're going to pass over the point on the next think.
							float flTestPos[3];
							NormalizeVector(flSlenderVelocity, flTestPos);
							ScaleVector(flTestPos, GetVectorLength(flSlenderVelocity) * BOSS_THINKRATE);
							AddVectors(flMyPos, flTestPos, flTestPos);
							
							float flP[3], flS[3];
							SubtractVectors(flNodePos, flMyPos, flP);
							SubtractVectors(flTestPos, flMyPos, flS);
							
							float flSP = GetVectorDotProduct(flP, flS);
							if (flSP <= 0.0) bOutside = true;
							
							float flPP = GetVectorDotProduct(flS, flS);
							
							if (!bOutside)
							{
								if (flPP <= flSP) bOutside = true;
							}
							
							if (!bOutside)
							{
								float flD[3];
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
								int iPosIndex = GetArraySize(g_hSlenderPath[iBossIndex]) - 1;
								
								g_flSlenderGoalPos[iBossIndex][0] = view_as<float>(GetArrayCell(g_hSlenderPath[iBossIndex], iPosIndex, 0));
								g_flSlenderGoalPos[iBossIndex][1] = view_as<float>(GetArrayCell(g_hSlenderPath[iBossIndex], iPosIndex, 1));
								g_flSlenderGoalPos[iBossIndex][2] = view_as<float>(GetArrayCell(g_hSlenderPath[iBossIndex], iPosIndex, 2));
							}
							
							bGotNewPoint = true;
							break;
						}
					}
				}
				
				if (!bGotNewPoint)
				{
					// Try to see if we can look ahead.
					
					float flMyEyePos[3];
					NPCGetEyePosition(iBossIndex, flMyEyePos);
					
					float flNodeLookAheadDist = g_flSlenderPathNodeLookAhead[iBossIndex];
					if (flNodeLookAheadDist > 0.0)
					{
						int iNodeCount = GetArraySize(g_hSlenderPath[iBossIndex]);
						if (iNodeCount)
						{
							float flInitDir[3];
							flInitDir[0] = view_as<float>(GetArrayCell(g_hSlenderPath[iBossIndex], iNodeCount - 1, 0));
							flInitDir[1] = view_as<float>(GetArrayCell(g_hSlenderPath[iBossIndex], iNodeCount - 1, 1));
							flInitDir[2] = view_as<float>(GetArrayCell(g_hSlenderPath[iBossIndex], iNodeCount - 1, 2));
							
							SubtractVectors(flInitDir, flMyPos, flInitDir);
							NormalizeVector(flInitDir, flInitDir);
							
							float flPrevDir[3];
							flPrevDir[0] = flInitDir[0];
							flPrevDir[1] = flInitDir[1];
							flPrevDir[2] = flInitDir[2];
							
							NormalizeVector(flPrevDir, flPrevDir);
							
							float flPrevNodePos[3];
							
							int iStartPointIndex = iNodeCount - 1;
							float flRangeSoFar = 0.0;
							
							int iLookAheadPointIndex;
							for (iLookAheadPointIndex = iStartPointIndex; iLookAheadPointIndex >= 0; iLookAheadPointIndex--)
							{
								flNodePos[0] = view_as<float>(GetArrayCell(g_hSlenderPath[iBossIndex], iLookAheadPointIndex, 0));
								flNodePos[1] = view_as<float>(GetArrayCell(g_hSlenderPath[iBossIndex], iLookAheadPointIndex, 1));
								flNodePos[2] = view_as<float>(GetArrayCell(g_hSlenderPath[iBossIndex], iLookAheadPointIndex, 2));
							
								float flDir[3];
								if (iLookAheadPointIndex == iStartPointIndex)
								{
									SubtractVectors(flNodePos, flMyPos, flDir);
									NormalizeVector(flDir, flDir);
								}
								else
								{
									flPrevNodePos[0] = view_as<float>(GetArrayCell(g_hSlenderPath[iBossIndex], iLookAheadPointIndex + 1, 0));
									flPrevNodePos[1] = view_as<float>(GetArrayCell(g_hSlenderPath[iBossIndex], iLookAheadPointIndex + 1, 1));
									flPrevNodePos[2] = view_as<float>(GetArrayCell(g_hSlenderPath[iBossIndex], iLookAheadPointIndex + 1, 2));
								
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
								
								float flProbe[3];
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
								int iPosIndex = GetArraySize(g_hSlenderPath[iBossIndex]) - 1;
								
								g_flSlenderGoalPos[iBossIndex][0] = view_as<float>(GetArrayCell(g_hSlenderPath[iBossIndex], iPosIndex, 0));
								g_flSlenderGoalPos[iBossIndex][1] = view_as<float>(GetArrayCell(g_hSlenderPath[iBossIndex], iPosIndex, 1));
								g_flSlenderGoalPos[iBossIndex][2] = view_as<float>(GetArrayCell(g_hSlenderPath[iBossIndex], iPosIndex, 2));
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

void SlenderChaseBossProcessMovement(int iBossIndex)
{
	int iBoss = NPCGetEntIndex(iBossIndex);
	int iState = g_iSlenderState[iBossIndex];
	
	// Constantly set the monster_generic's NPC state to idle to prevent
	// velocity confliction.
	
	SetEntProp(iBoss, Prop_Data, "m_NPCState", 0);
	
	float flWalkSpeed = g_flSlenderCalculatedWalkSpeed[iBossIndex];
	float flSpeed = g_flSlenderCalculatedSpeed[iBossIndex];
	float flAirSpeed = g_flSlenderCalculatedAirSpeed[iBossIndex];
	
	float flMyPos[3], flMyEyeAng[3], flMyVelocity[3];
	
	char sSlenderProfile[SF2_MAX_PROFILE_NAME_LENGTH];
	NPCGetProfile(iBossIndex, sSlenderProfile, sizeof(sSlenderProfile));
	
	GetEntPropVector(iBoss, Prop_Data, "m_vecAbsOrigin", flMyPos);
	GetEntPropVector(iBoss, Prop_Data, "m_angAbsRotation", flMyEyeAng);
	GetEntPropVector(iBoss, Prop_Data, "m_vecAbsVelocity", flMyVelocity);
	
	float flBossMins[3], flBossMaxs[3];
	GetEntPropVector(iBoss, Prop_Send, "m_vecMins", flBossMins);
	GetEntPropVector(iBoss, Prop_Send, "m_vecMaxs", flBossMaxs);
	
	float flTraceMins[3], flTraceMaxs[3];
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
		float flMoveDir[3];
		NormalizeVector(flMyVelocity, flMoveDir);
		flMoveDir[2] = 0.0;
		
		float flLat[3];
		flLat[0] = -flMoveDir[1];
		flLat[1] = flMoveDir[0];
		flLat[2] = 0.0;
	
		float flFeelerOffset = 25.0;
		float flFeelerLengthRun = 50.0;
		float flFeelerLengthWalk = 30.0;
		float flFeelerHeight = StepHeight + 0.1;
		
		float flFeelerLength = iState == STATE_CHASE ? flFeelerLengthRun : flFeelerLengthWalk;
		
		// Get the ground height and normal.
		Handle hTrace = TR_TraceRayFilterEx(flMyPos, view_as<float>({ 0.0, 0.0, 90.0 }), MASK_NPCSOLID, RayType_Infinite, TraceFilterWalkableEntities);
		float flTraceEndPos[3];
		float flTraceNormal[3];
		TR_GetEndPosition(flTraceEndPos, hTrace);
		TR_GetPlaneNormal(hTrace, flTraceNormal);
		bool bTraceHit = TR_DidHit(hTrace);
		CloseHandle(hTrace);
		
		if (bTraceHit)
		{
			//float flGroundHeight = GetVectorDistance(flMyPos, flTraceEndPos);
			NormalizeVector(flTraceNormal, flTraceNormal);
			GetVectorCrossProduct(flLat, flTraceNormal, flMoveDir);
			GetVectorCrossProduct(flMoveDir, flTraceNormal, flLat);
			
			float flFeet[3];
			flFeet[0] = flMyPos[0];
			flFeet[1] = flMyPos[1];
			flFeet[2] = flMyPos[2] + flFeelerHeight;
			
			float flTo[3];
			float flFrom[3];
			for (int i = 0; i < 3; i++)
			{
				flFrom[i] = flFeet[i] + (flFeelerOffset * flLat[i]);
				flTo[i] = flFrom[i] + (flFeelerLength * flMoveDir[i]);
			}
			
			bool bLeftClear = IsWalkableTraceLineClear(flFrom, flTo, WALK_THRU_DOORS | WALK_THRU_BREAKABLES);
			
			for (int i = 0; i < 3; i++)
			{
				flFrom[i] = flFeet[i] - (flFeelerOffset * flLat[i]);
				flTo[i] = flFrom[i] + (flFeelerLength * flMoveDir[i]);
			}
			
			bool bRightClear = IsWalkableTraceLineClear(flFrom, flTo, WALK_THRU_DOORS | WALK_THRU_BREAKABLES);
			
			float flAvoidRange = 300.0;
			
			if (!bRightClear)
			{
				if (bLeftClear)
				{
					g_bSlenderFeelerReflexAdjustment[iBossIndex] = true;
					
					for (int i = 0; i < 3; i++)
					{
						g_flSlenderFeelerReflexAdjustmentPos[iBossIndex][i] = g_flSlenderGoalPos[iBossIndex][i] + (flAvoidRange * flLat[i]);
					}
				}
			}
			else if (!bLeftClear)
			{
				g_bSlenderFeelerReflexAdjustment[iBossIndex] = true;
				
				for (int i = 0; i < 3; i++)
				{
					g_flSlenderFeelerReflexAdjustmentPos[iBossIndex][i] = g_flSlenderGoalPos[iBossIndex][i] - (flAvoidRange * flLat[i]);
				}
			}
		}
	}
	
	float flGoalPosition[3];
	if (g_bSlenderFeelerReflexAdjustment[iBossIndex])
	{
		for (int i = 0; i < 3; i++)
		{
			flGoalPosition[i] = g_flSlenderFeelerReflexAdjustmentPos[iBossIndex][i];
		}
	}
	else
	{
		for (int i = 0; i < 3; i++)
		{
			flGoalPosition[i] = g_flSlenderGoalPos[iBossIndex][i];
		}
	}
	
	// Process our desired velocity.
	float flDesiredVelocity[3];
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
	bool bSlenderOnGround = view_as<bool>(GetEntityFlags(iBoss) & FL_ONGROUND);
	
	float flTraceEndPos[3];
	Handle hTrace;
	bool bCanJump = true;
	int iTargetAreaIndex = NavMesh_GetNearestArea(flMyPos);
	if (iTargetAreaIndex != -1)
	{
		if (NavMeshArea_GetFlags(iTargetAreaIndex) & NAV_MESH_NO_JUMP)
		{
			bCanJump = false;
		}
	}
	
	// Determine speed behavior.
	if (bSlenderOnGround)
	{
		// Don't change the speed behavior.
	}
	else
	{
		flDesiredVelocity[2] = 0.0;
		NormalizeVector(flDesiredVelocity, flDesiredVelocity);
		ScaleVector(flDesiredVelocity, flAirSpeed);
	}
	
	bool bSlenderTeleportedOnStep = false;
	float flSlenderStepSize = NPCChaserGetStepSize(iBossIndex);
	
	// Check our stepsize in case we need to elevate ourselves a step.
	if (bSlenderOnGround && GetVectorLength(flDesiredVelocity) > 0.0)
	{
		if (flSlenderStepSize > 0.0)
		{
			float flTraceDirection[3], flObstaclePos[3], flObstacleNormal[3];
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
				
			bool bSlenderHitObstacle = TR_DidHit(hTrace);
			TR_GetEndPosition(flObstaclePos, hTrace);
			TR_GetPlaneNormal(hTrace, flObstacleNormal);
			CloseHandle(hTrace);
			
			if (bSlenderHitObstacle &&
				FloatAbs(flObstacleNormal[2]) == 0.0)
			{
				float flTraceStartPos[3];
				flTraceStartPos[0] = flObstaclePos[0];
				flTraceStartPos[1] = flObstaclePos[1];
				
				float flTraceFreePos[3];
				
				float flTraceCheckZ = 0.0;
				
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
				float flTraceStartPos[3];
				flTraceStartPos[0] = flObstaclePos[0];
				flTraceStartPos[1] = flObstaclePos[1];
				
				float flTraceFreePos[3];
				
				float flTraceCheckZ = 0.0;
				
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
	float flMoveVelocity[3];
	float flFrameTime = GetTickInterval();
	float flAcceleration[3];
	SubtractVectors(flDesiredVelocity, flMyVelocity, flAcceleration);
	NormalizeVector(flAcceleration, flAcceleration);
	ScaleVector(flAcceleration, g_flSlenderAcceleration[iBossIndex] * flFrameTime);
	
	AddVectors(flMyVelocity, flAcceleration, flMoveVelocity);
	
	float flSlenderJumpSpeed = g_flSlenderJumpSpeed[iBossIndex];
	bool bSlenderShouldJump = false;
	
	float angJumpReach[3]; 
	
	// Check if we need to jump over a wall or something.
	if (!bSlenderShouldJump && bSlenderOnGround && !bSlenderTeleportedOnStep && flSlenderJumpSpeed > 0.0 && GetVectorLength(flDesiredVelocity) > 0.0 &&
		GetGameTime() >= g_flSlenderNextJump[iBossIndex])
	{
		float flZDiff = (flGoalPosition[2] - flMyPos[2]);
		
		if (flZDiff > flSlenderStepSize)
		{
			// Our path has a jump thingy to it. Calculate the jump height needed to reach it and how far away we should start
			// checking on when to jump.
			
			float vecDir[3], vecDesiredDir[3];
			GetVectorAngles(flMyVelocity, vecDir);
			SubtractVectors(flGoalPosition, flMyPos, vecDesiredDir);
			GetVectorAngles(vecDesiredDir, vecDesiredDir);
			
			if ((FloatAbs(AngleDiff(vecDir[0], vecDesiredDir[0])) + FloatAbs(AngleDiff(vecDir[1], vecDesiredDir[1]))) >= 45.0)
			{
				// Assuming we are actually capable of making the jump, find out WHEN we have to jump,
				// based on 2D distance between our position and the target point, and our current horizontal 
				// velocity.
				
				float vecMyPos2D[3], vecGoalPos2D[3];
				vecMyPos2D[0] = flMyPos[0];
				vecMyPos2D[1] = flMyPos[1];
				vecMyPos2D[2] = 0.0;
				vecGoalPos2D[0] = flGoalPosition[0];
				vecGoalPos2D[1] = flGoalPosition[1];
				vecGoalPos2D[2] = 0.0;
				
				float fl2DDist = GetVectorDistance(vecMyPos2D, vecGoalPos2D);
				
				float flNotImaginary = Pow(flSlenderJumpSpeed, 4.0) - (g_flGravity * (g_flGravity * Pow(fl2DDist, 2.0)) + (2.0 * flZDiff * Pow(flSlenderJumpSpeed, 2.0)));
				if (flNotImaginary >= 0.0)
				{
					// We can reach it.
					float flNotInfinite = g_flGravity * fl2DDist;
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
	
	if (bSlenderOnGround && bSlenderShouldJump && flMyPos[2]<flGoalPosition[2] && bCanJump)
	{
		g_flSlenderNextJump[iBossIndex] = GetGameTime() + GetProfileFloat(sSlenderProfile, "jump_cooldown", 2.0);
		
		float vecJump[3];
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
	
	float flMoveAng[3];
	bool bChangeAngles = false;
	
	// Process angles.
	if (iState != STATE_ATTACK && iState != STATE_STUN)
	{
		if (NPCHasAttribute(iBossIndex, "always look at target"))
		{
			int iTarget = EntRefToEntIndex(g_iSlenderTarget[iBossIndex]);
			
			if (iTarget && iTarget != INVALID_ENT_REFERENCE)
			{
				float flTargetPos[3];
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
		
		float flTurnRate = NPCGetTurnRate(iBossIndex);
		if (iState == STATE_CHASE) flTurnRate *= 2.0;
		
		flMoveAng[0] = 0.0;
		flMoveAng[2] = 0.0;
		flMoveAng[1] = ApproachAngle(flMoveAng[1], flMyEyeAng[1], flTurnRate * flFrameTime);
		
		bChangeAngles = true;
	}
	TeleportEntity(iBoss, NULL_VECTOR, bChangeAngles ? flMoveAng : NULL_VECTOR, flMoveVelocity);
	if(g_iSlenderHitbox[iBossIndex]>MaxClients && IsValidEntity(g_iSlenderHitbox[iBossIndex]))
	{
		//SetEntProp(g_iSlenderHitbox[iBossIndex], Prop_Send,"moveparent",iBoss);
		//SetEntProp(g_iSlenderHitbox[iBossIndex], Prop_Send,"m_iParentAttachment",iBoss);
	}
}

// Shortest-path cost function for NavMesh_BuildPath.
public int SlenderChaseBossShortestPathCost(int iAreaIndex,int iFromAreaIndex,int iLadderIndex, any iStepSize)
{
	if (iFromAreaIndex == -1)
	{
		return 0;
	}
	else
	{
		int iDist;
		float flAreaCenter[3], flFromAreaCenter[3];
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
		
		int iCost = iDist + NavMeshArea_GetCostSoFar(iFromAreaIndex);
		
		int iAreaFlags = NavMeshArea_GetFlags(iAreaIndex);
		if (iAreaFlags & NAV_MESH_CROUCH) iCost += 20;
		if (iAreaFlags & NAV_MESH_JUMP) iCost += (5 * iDist);
		
		if ((flAreaCenter[2] - flFromAreaCenter[2]) > iStepSize) iCost += iStepSize;
		
		g_iGeneralDist += iDist;
		
		return iCost;
	}
}

public Action Timer_SlenderChaseBossAttack(Handle timer, any entref)
{
	if (!g_bEnabled) return;

	int slender = EntRefToEntIndex(entref);
	if (!slender || slender == INVALID_ENT_REFERENCE) return;
	
	int iBossIndex = NPCGetFromEntIndex(slender);
	if (iBossIndex == -1) return;
	
	if (timer != g_hSlenderAttackTimer[iBossIndex]) return;
	
	if (NPCGetFlags(iBossIndex) & SFF_FAKE)
	{
		SlenderMarkAsFake(iBossIndex);
		return;
	}
	
	char sProfile[SF2_MAX_PROFILE_NAME_LENGTH];
	NPCGetProfile(iBossIndex, sProfile, sizeof(sProfile));
	
	bool bAttackEliminated = view_as<bool>(NPCGetFlags(iBossIndex) & SFF_ATTACKWAITERS);
	
	float flDamage = NPCChaserGetAttackDamage(iBossIndex, 0);
	float flDamageVsProps = NPCChaserGetAttackDamageVsProps(iBossIndex, 0);
	int iDamageType = NPCChaserGetAttackDamageType(iBossIndex, 0);
	
	// Damage all players within range.
	float flMyEyePos[3], flMyEyeAng[3];
	NPCGetEyePosition(iBossIndex, flMyEyePos);
	GetEntPropVector(slender, Prop_Data, "m_angAbsRotation", flMyEyeAng);
	AddVectors(g_flSlenderEyePosOffset[iBossIndex], flMyEyeAng, flMyEyeAng);
	for (int i = 0; i < 3; i++) flMyEyeAng[i] = AngleNormalize(flMyEyeAng[i]);
	
	float flViewPunch[3];
	GetProfileVector(sProfile, "attack_punchvel", flViewPunch);
	
	float flTargetDist;
	Handle hTrace;
	
	float flAttackRange = NPCChaserGetAttackRange(iBossIndex, 0);
	float flAttackFOV = NPCChaserGetAttackSpread(iBossIndex, 0);
	float flAttackDamageForce = NPCChaserGetAttackDamageForce(iBossIndex, 0);
	
	bool bHit = false;
	
	{
		int prop = -1;
		while ((prop = FindEntityByClassname(prop, "prop_physics")) > MaxClients)
		{
			if (NPCAttackValidateTarget(iBossIndex, prop, flAttackRange, flAttackFOV))
			{
				bHit = true;
				SDKHooks_TakeDamage(prop, slender, slender, flDamageVsProps, iDamageType, _, _, flMyEyePos);
				float SpreadVel = 1800.0;
				float VertVel = 1300.0;
				float vel[3];
				GetAngleVectors(flMyEyeAng, vel, NULL_VECTOR, NULL_VECTOR);
				ScaleVector(vel,SpreadVel);
				vel[2] = ((GetURandomFloat() + 0.1) * VertVel) * ((GetURandomFloat() + 0.1) * 2);
				TeleportEntity(prop, NULL_VECTOR, NULL_VECTOR, vel);
			}
		}
		
		prop = -1;
		while ((prop = FindEntityByClassname(prop, "prop_dynamic")) > MaxClients)
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
		prop = -1;
		while ((prop = FindEntityByClassname(prop, "obj_sentrygun")) > MaxClients)
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
		prop = -1;
		while ((prop = FindEntityByClassname(prop, "obj_teleporter")) > MaxClients)
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
		prop = -1;
		while ((prop = FindEntityByClassname(prop, "obj_dispenser")) > MaxClients)
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
	
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i) || !IsPlayerAlive(i) || IsClientInGhostMode(i)) continue;
		
		if (!bAttackEliminated && g_bPlayerEliminated[i]) continue;
		
		float flTargetPos[3];
		GetClientEyePosition(i, flTargetPos);
		
		hTrace = TR_TraceRayFilterEx(flMyEyePos,
			flTargetPos,
			MASK_NPCSOLID,
			RayType_EndPoint,
			TraceRayDontHitEntity,
			slender);
		
		bool bTraceDidHit = TR_DidHit(hTrace);
		int iTraceHitEntity = TR_GetEntityIndex(hTrace);
		CloseHandle(hTrace);
		
		if (bTraceDidHit && iTraceHitEntity != i)
		{
			float flTargetMins[3], flTargetMaxs[3];
			GetEntPropVector(i, Prop_Send, "m_vecMins", flTargetMins);
			GetEntPropVector(i, Prop_Send, "m_vecMaxs", flTargetMaxs);
			GetClientAbsOrigin(i, flTargetPos);
			for (int i2 = 0; i2 < 3; i2++) flTargetPos[i2] += ((flTargetMins[i2] + flTargetMaxs[i2]) / 2.0);
			
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
				float flDirection[3];
				SubtractVectors(flTargetPos, flMyEyePos, flDirection);
				GetVectorAngles(flDirection, flDirection);
				
				if (FloatAbs(AngleDiff(flDirection[1], flMyEyeAng[1])) <= flAttackFOV)
				{
					bHit = true;
					GetAngleVectors(flDirection, flDirection, NULL_VECTOR, NULL_VECTOR);
					NormalizeVector(flDirection, flDirection);
					ScaleVector(flDirection, flAttackDamageForce);
					
					if (SF_SpecialRound(SPECIALROUND_MULTIEFFECT))
					{
						int iEffect = GetRandomInt(0, 5);
						switch (iEffect)
						{
							case 1:
							{
								TF2_MakeBleed(i, i, 3.0);
							}
							case 2:
							{
								TF2_IgnitePlayer(i, i);
							}
							case 3:
							{
								TF2_AddCondition(i, TFCond_Jarated, 3.0);
							}
							case 4:
							{
								TF2_AddCondition(i, TFCond_CritMmmph, 2.0);
							}
							case 5:
							{
								int iEffectRare = GetRandomInt(1, 30);
								switch (iEffectRare)
								{
									case 1,14,25,30:
									{
										int iNewHealth = GetEntProp(i, Prop_Send, "m_iHealth")+view_as<int>(flDamage);
										if (iNewHealth > 450) iNewHealth = 450;
										TF2_AddCondition(i, TFCond_MegaHeal, 2.0);
										SetEntProp(i, Prop_Send, "m_iHealth", iNewHealth);
										flDamage = 0.0;
									}
									case 7,27:
									{
										//It's over 9000!
										flDamage = 9001.0;
									}
									case 5,16,18,22,23,26:
									{
										ScaleVector(flDirection, 1200.0);
									}
								}
							}
						}
					}
					
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
						float flDuration = NPCGetAttributeValue(iBossIndex, "bleed player on hit");
						if (flDuration > 0.0)
						{
							TF2_MakeBleed(i, slender, flDuration);
						}
					}
					
					// Add stress
					float flStressScalar = flDamage / 125.0;
					if (flStressScalar > 1.0) flStressScalar = 1.0;
					ClientAddStress(i, 0.33 * flStressScalar);
				}
			}
		}
	}
	
	char sSoundPath[PLATFORM_MAX_PATH];
	
	if (bHit)
	{
		// Fling it.
		int phys = CreateEntityByName("env_physexplosion");
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

static bool NPCAttackValidateTarget(int iBossIndex,int iTarget, float flAttackRange, float flAttackFOV)
{
	int iBoss = NPCGetEntIndex(iBossIndex);
	
	float flMyEyePos[3], flMyEyeAng[3];
	NPCGetEyePosition(iBossIndex, flMyEyePos);
	if(iTarget>MaxClients)
	{
		//float flVecMaxs[3];
		flMyEyePos[2]+=30.0;
		//GetEntPropVector(g_iSlenderHitbox[iBossIndex], Prop_Data, "m_vecMaxs", flVecMaxs);
	}
	GetEntPropVector(iBoss, Prop_Data, "m_angAbsRotation", flMyEyeAng);
	AddVectors(g_flSlenderEyeAngOffset[iBossIndex], flMyEyeAng, flMyEyeAng);
	for (int i = 0; i < 3; i++) flMyEyeAng[i] = AngleNormalize(flMyEyeAng[i]);
	
	float flTargetPos[3], flTargetMins[3], flTargetMaxs[3];
	GetEntPropVector(iTarget, Prop_Data, "m_vecAbsOrigin", flTargetPos);
	GetEntPropVector(iTarget, Prop_Send, "m_vecMins", flTargetMins);
	GetEntPropVector(iTarget, Prop_Send, "m_vecMaxs", flTargetMaxs);
	
	for (int i = 0; i < 3; i++)
	{
		flTargetPos[i] += (flTargetMins[i] + flTargetMaxs[i]) / 2.0;
	}
	
	float flTargetDist = GetVectorDistance(flTargetPos, flMyEyePos);
	if (flTargetDist <= flAttackRange)
	{
		float flDirection[3];
		SubtractVectors(g_flSlenderGoalPos[iBossIndex], flMyEyePos, flDirection);
		GetVectorAngles(flDirection, flDirection);
		
		if (FloatAbs(AngleDiff(flDirection[1], flMyEyeAng[1])) <= flAttackFOV / 2.0)
		{
			Handle hTrace = TR_TraceRayFilterEx(flMyEyePos,
				flTargetPos,
				MASK_NPCSOLID,
				RayType_EndPoint,
				TraceRayDontHitEntity,
				iBoss);
				
			bool bTraceDidHit = TR_DidHit(hTrace);
			int iTraceHitEntity = TR_GetEntityIndex(hTrace);
			CloseHandle(hTrace);
			
			if (!bTraceDidHit || iTraceHitEntity == iTarget)
			{
				return true;
			}
		}
	}
	
	return false;
}
static bool NPCPropPhysicsAttack(int iBossIndex,int prop)
{
	char buffer[PLATFORM_MAX_PATH], sProfile[SF2_MAX_PROFILE_NAME_LENGTH], model[SF2_MAX_PROFILE_NAME_LENGTH], key[64];
	NPCGetProfile(iBossIndex, sProfile, sizeof(sProfile));
	KvRewind(g_hConfig);
	KvJumpToKey(g_hConfig, sProfile);
	if(!IsValidEntity(prop))return false;
	GetEntPropString(prop, Prop_Data, "m_ModelName", model, sizeof(model));
	if (!KvJumpToKey(g_hConfig, "attack_props_physics_models")) return true;
	bool bFound=false;
	for(int i=1; ; i++)
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
stock void NPC_DropKey(int iBossIndex)
{
	char buffer[PLATFORM_MAX_PATH], sProfile[SF2_MAX_PROFILE_NAME_LENGTH];
	NPCGetProfile(iBossIndex, sProfile, sizeof(sProfile));
	KvRewind(g_hConfig);
	KvJumpToKey(g_hConfig, sProfile);
	KvGetString(g_hConfig, "key_trigger", buffer, PLATFORM_MAX_PATH);
	if(!StrEqual(buffer,""))
	{
		float flMyPos[3], flVel[3];
		int iBoss = NPCGetEntIndex(iBossIndex);
		GetEntPropVector(iBoss, Prop_Data, "m_vecAbsOrigin", flMyPos);
		Format(buffer,PLATFORM_MAX_PATH,"sf2_key_%s",buffer);
		
		int TouchBox = CreateEntityByName("tf_halloween_pickup");
		//To do: allow the cfg maker to change the model.
		DispatchKeyValue(TouchBox,"targetname", buffer);
		DispatchKeyValue(TouchBox,"powerup_model", SF_KEYMODEL);
		DispatchKeyValue(TouchBox,"modelscale", "2.0");
		DispatchKeyValue(TouchBox,"pickup_sound","ui/itemcrate_smash_ultrarare_short.wav");
		DispatchKeyValue(TouchBox,"pickup_particle","utaunt_firework_teamcolor_red");
		DispatchKeyValue(TouchBox,"TeamNum","0");
		TeleportEntity(TouchBox, flMyPos, NULL_VECTOR, NULL_VECTOR);
		SetEntityModel(TouchBox,SF_KEYMODEL);
		SetEntProp(TouchBox, Prop_Data, "m_iEFlags", 12845056);
		DispatchSpawn(TouchBox);
		ActivateEntity(TouchBox);
		SetEntityModel(TouchBox,SF_KEYMODEL);
		
		int Key = CreateEntityByName("tf_halloween_pickup");
		//To do: allow the cfg maker to change the model.
		DispatchKeyValue(Key,"targetname", buffer);
		DispatchKeyValue(Key,"powerup_model", PAGE_MODEL);
		DispatchKeyValue(Key,"modelscale", "2.0");
		DispatchKeyValue(Key,"pickup_sound","ui/itemcrate_smash_ultrarare_short.wav");
		DispatchKeyValue(Key,"pickup_particle","utaunt_firework_teamcolor_red");
		DispatchKeyValue(Key,"TeamNum","0");
		TeleportEntity(Key, flMyPos, NULL_VECTOR, NULL_VECTOR);
		SetEntityModel(Key,PAGE_MODEL);
		SetEntProp(Key, Prop_Data, "m_iEFlags", 12845056);
		DispatchSpawn(Key);
		ActivateEntity(Key);
		
		SetEntityRenderMode(Key, RENDER_TRANSCOLOR);
		SetEntityRenderColor(Key, 0, 0, 0, 1);
		
		int glow = CreateEntityByName("tf_taunt_prop");
		//To do: allow the cfg maker to change the model.
		DispatchKeyValue(glow,"targetname", buffer);
		DispatchKeyValue(glow,"model", SF_KEYMODEL);
		TeleportEntity(glow, flMyPos, NULL_VECTOR, NULL_VECTOR);
		DispatchSpawn(glow);
		ActivateEntity(glow);
		SetEntityModel(glow,SF_KEYMODEL);
		
		SetEntProp(glow, Prop_Send, "m_bGlowEnabled", 1);
		SetEntPropFloat(glow, Prop_Send, "m_flModelScale", 2.0);
		SetEntityRenderMode(glow, RENDER_TRANSCOLOR);
		SetEntityRenderColor(glow, 0, 0, 0, 1);
		
		SetVariantString("!activator");
		AcceptEntityInput(TouchBox, "SetParent", Key);
		
		SetVariantString("!activator");
		AcceptEntityInput(glow, "SetParent", Key);
		
		SetEntityModel(Key,PAGE_MODEL);
		SetEntityMoveType(Key, MOVETYPE_FLYGRAVITY);
		
		HookSingleEntityOutput(TouchBox,"OnRedPickup",KeyTrigger);
		
		flVel[0] = GetRandomFloat(-300.0, 300.0);
		flVel[1] = GetRandomFloat(-300.0, 300.0);
		flVel[2] = GetRandomFloat(700.0, 900.0);
		
		SetEntProp(Key, Prop_Data, "m_iEFlags", 12845056);
		
		TeleportEntity(Key, flMyPos, NULL_VECTOR, flVel);
		SetEntPropFloat(Key, Prop_Send, "m_flModelScale", 2.0);
		SetEntProp(Key, Prop_Data, "m_iEFlags", 12845056);
		SetEntProp(Key, Prop_Data, "m_MoveCollide", 1);
		
		SDKHook(Key, SDKHook_SetTransmit, Hook_KeySetTransmit);
		SDKHook(glow, SDKHook_SetTransmit, Hook_KeySetTransmit);
		SDKHook(TouchBox, SDKHook_SetTransmit, Hook_KeySetTransmit);
		
		//The key can be stuck somewhere to prevent that, make an auto collect.
		float flTimeLeft = float(g_iRoundTime);
		if(flTimeLeft>60.0)
			flTimeLeft=30.0;
		else
			flTimeLeft=flTimeLeft-20.0;
		CreateTimer(flTimeLeft, CollectKey, EntIndexToEntRef(TouchBox));
	}
}
public void KeyTrigger(const char[] output, int caller, int activator, float delay)
{
	TriggerKey(caller);
}
public Action Hook_KeySetTransmit(int entity,int other)
{
	if(!IsValidClient(other)) return Plugin_Continue;
	
	if(g_bPlayerEliminated[other] && IsClientInGhostMode(other)) return Plugin_Continue;
	
	if(!g_bPlayerEliminated[other]) return Plugin_Continue;
	
	return Plugin_Handled;
}
public Action CollectKey(Handle timer, any entref)
{
	int ent = EntRefToEntIndex(entref);
	if (ent == INVALID_ENT_REFERENCE) return;
	char sClass[64];
	GetEntityNetClass(ent, sClass, sizeof(sClass));
	if (!StrEqual(sClass, "CHalloweenPickup")) return;
	
	TriggerKey(ent);
	return;
}
	
	
stock void TriggerKey(int caller)
{
	char targetName[PLATFORM_MAX_PATH];
	GetEntPropString(caller, Prop_Data, "m_iName", targetName, sizeof(targetName));
	
	int	ent = -1;
	while ((ent = FindEntityByClassname(ent, "tf_halloween_pickup")) != -1)
	{
		char sName[64];
		GetEntPropString(ent, Prop_Data, "m_iName", sName, sizeof(sName));
		if (StrEqual(sName, targetName, false))
		{
			AcceptEntityInput(ent,"KillHierarchy");
		}
	}
	
	ReplaceString(targetName, sizeof(targetName), "sf2_key_", "", false);
	float flMyPos[3];
	GetEntPropVector(caller, Prop_Data, "m_vecAbsOrigin", flMyPos);
	TE_SetupTFParticleEffect(g_iParticle[FireworksRED], flMyPos, flMyPos);
	TE_SendToAll();
	TE_SetupTFParticleEffect(g_iParticle[FireworksBLU], flMyPos, flMyPos);
	TE_SendToAll();
	ent = -1;
	while ((ent = FindEntityByClassname(ent, "logic_relay")) != -1)
	{
		char sName[64];
		GetEntPropString(ent, Prop_Data, "m_iName", sName, sizeof(sName));
		if (StrEqual(sName, targetName, false))
		{
			AcceptEntityInput(ent,"Trigger");
		}
	}
	ent = -1;
	while ((ent = FindEntityByClassname(ent, "func_door")) != -1)
	{
		char sName[64];
		GetEntPropString(ent, Prop_Data, "m_iName", sName, sizeof(sName));
		if (StrEqual(sName, targetName, false))
		{
			AcceptEntityInput(ent,"Open");
		}
	}
	AcceptEntityInput(caller,"Kill");
	EmitSoundToAll("ui/itemcrate_smash_ultrarare_short.wav", caller, SNDCHAN_AUTO, SNDLEVEL_SCREAMING);
}
stock bool NPC_CanAttackProps(int iBossIndex,float flAttackRange,float flAttackFOV)
{
	int prop = -1;
	bool bBlockingProp = false;
	while ((prop = FindEntityByClassname(prop, "prop_physics")) > MaxClients)
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
		while ((prop = FindEntityByClassname(prop, "prop_dynamic")) > MaxClients)
		{
			if(GetEntProp(prop,Prop_Data,"m_iHealth") > 0)
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
		if (!bBlockingProp)
		{
			prop = -1;
			while ((prop = FindEntityByClassname(prop, "obj_dispenser")) > MaxClients)
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
				while ((prop = FindEntityByClassname(prop, "obj_sentrygun")) > MaxClients)
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
					while ((prop = FindEntityByClassname(prop, "obj_teleporter")) > MaxClients)
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
	}
	return bBlockingProp;
}
public Action Timer_SlenderChaseBossAttackEnd(Handle timer, any entref)
{
	if (!g_bEnabled) return;

	int slender = EntRefToEntIndex(entref);
	if (!slender || slender == INVALID_ENT_REFERENCE) return;
	
	int iBossIndex = NPCGetFromEntIndex(slender);
	if (iBossIndex == -1) return;
	
	if (timer != g_hSlenderAttackTimer[iBossIndex]) return;
	
	g_bSlenderAttacking[iBossIndex] = false;
	g_hSlenderAttackTimer[iBossIndex] = INVALID_HANDLE;
}