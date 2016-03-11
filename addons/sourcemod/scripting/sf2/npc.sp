#if defined _sf2_npc_included
 #endinput
#endif
#define _sf2_npc_included

#define SF2_BOSS_PAGE_CALCULATION 0.3
#define SF2_BOSS_COPY_SPAWN_MIN_DISTANCE 1850.0 // The default minimum distance boss copies can spawn from each other.

#define SF2_BOSS_ATTACK_MELEE 0

static int g_iNPCGlobalUniqueID = 0;

static int g_iNPCUniqueID[MAX_BOSSES] = { -1, ... };
static char g_strSlenderProfile[MAX_BOSSES][SF2_MAX_PROFILE_NAME_LENGTH];
static int g_iNPCProfileIndex[MAX_BOSSES] = { -1, ... };
static int g_iNPCUniqueProfileIndex[MAX_BOSSES] = { -1, ... };
static int g_iNPCType[MAX_BOSSES] = { SF2BossType_Unknown, ... };
static int g_iNPCFlags[MAX_BOSSES] = { 0, ... };
static float g_flNPCModelScale[MAX_BOSSES] = { 1.0, ... };

static float g_flNPCFieldOfView[MAX_BOSSES] = { 0.0, ... };
static float g_flNPCTurnRate[MAX_BOSSES] = { 0.0, ... };

static int g_iSlender[MAX_BOSSES] = { INVALID_ENT_REFERENCE, ... };
static int g_iSlenderHitboxOwner[2049] = { INVALID_ENT_REFERENCE, ... };

static float g_flNPCSpeed[MAX_BOSSES][Difficulty_Max];
static float g_flNPCMaxSpeed[MAX_BOSSES][Difficulty_Max];

static float g_flNPCScareRadius[MAX_BOSSES];
static float g_flNPCScareCooldown[MAX_BOSSES];

static int g_iNPCTeleportType[MAX_BOSSES] = { -1, ... };

static float g_flNPCAnger[MAX_BOSSES] = { 1.0, ... };
static float g_flNPCAngerAddOnPageGrab[MAX_BOSSES] = { 0.0, ... };
static float g_flNPCAngerAddOnPageGrabTimeDiff[MAX_BOSSES] = { 0.0, ... };

static float g_flNPCSearchRadius[MAX_BOSSES] = { 0.0, ... };
static float g_flNPCInstantKillRadius[MAX_BOSSES] = { 0.0, ... };

static bool g_bNPCDeathCamEnabled[MAX_BOSSES] = { false, ... };

static int g_iNPCEnemy[MAX_BOSSES] = { INVALID_ENT_REFERENCE, ... };

static Handle hTimerMusic = INVALID_HANDLE;//Planning to add a bosses array on.
static char sCurrentMusicTrack[PLATFORM_MAX_PATH];


const SF2NPC_BaseNPC SF2_INVALID_NPC = view_as<SF2NPC_BaseNPC>(-1);

methodmap SF2NPC_BaseNPC
{
	property int Index
	{
		public get() { return view_as<int>(this); }
	}
	
	property int Type
	{
		public get() { return NPCGetType(this.Index); }
	}
	
	property int ProfileIndex
	{
		public get() { return NPCGetProfileIndex(this.Index); }
	}
	
	property int UniqueProfileIndex
	{
		public get() { return NPCGetUniqueProfileIndex(this.Index); }
	}
	
	property int EntRef
	{
		public get() { return NPCGetEntRef(this.Index); }
	}
	
	property int EntIndex
	{
		public get() { return NPCGetEntIndex(this.Index); }
	}
	
	property int Flags
	{
		public get() { return NPCGetFlags(this.Index); }
		public set(int flags)
		{
			NPCSetFlags(this.Index, flags);
		}
	}
	
	property float ModelScale
	{
		public get() { return NPCGetModelScale(this.Index); }
	}
	
	property float TurnRate
	{
		public get() { return NPCGetTurnRate(this.Index); }
	}
	
	property float FOV
	{
		public get() { return NPCGetFOV(this.Index); }
	}
	
	property float Anger
	{
		public get() { return NPCGetAnger(this.Index); }
		public set(float amount) { NPCSetAnger(this.Index, amount); }
	}
	
	property float AngerAddOnPageGrab
	{
		public get() { return NPCGetAngerAddOnPageGrab(this.Index); }
	}
	
	property float AngerAddOnPageGrabTimeDiff
	{
		public get() { return NPCGetAngerAddOnPageGrabTimeDiff(this.Index); }
	}
	
	property float SearchRadius
	{
		public get() { return NPCGetSearchRadius(this.Index); }
	}
	
	property float ScareRadius
	{
		public get() { return NPCGetScareRadius(this.Index); }
	}
	
	property float ScareCooldown
	{
		public get() { return NPCGetScareCooldown(this.Index); }
	}
	
	property float InstantKillRadius
	{
		public get() { return NPCGetInstantKillRadius(this.Index); }
	}
	
	property int TeleportType
	{
		public get() { return NPCGetTeleportType(this.Index); }
	}
	
	property int Enemy
	{
		public get() { return NPCGetEnemy(this.Index); }
		public set(int entIndex) { NPCSetEnemy(this.Index, entIndex); }
	}
	
	property bool DeathCamEnabled
	{
		public get() { return NPCHasDeathCamEnabled(this.Index); }
		public set(bool state) { NPCSetDeathCamEnabled(this.Index, state); }
	}
	
	public SF2NPC_BaseNPC(int index)
	{
		return SF2NPC_BaseNPC:index;
	}
	
	public void UnSpawn()
	{
		RemoveSlender(this.Index);
	}
	
	public void Remove()
	{
		NPCRemove(this.Index);
	}
	
	public bool IsValid()
	{
		return NPCIsValid(this.Index);
	}
	
	public void GetProfile(char[] buffer, int bufferlen) 
	{
		NPCGetProfile(this.Index, buffer, bufferlen);
	}
	
	public void SetProfile(const char[] profileName)
	{
		NPCSetProfile(this.Index, profileName);
	}
	
	public float GetSpeed(int difficulty)
	{
		return NPCGetSpeed(this.Index, difficulty);
	}
	
	public float GetMaxSpeed(int difficulty)
	{
		return NPCGetMaxSpeed(this.Index, difficulty);
	}
	
	public void GetEyePosition(float buffer[3], const float defaultValue[3] = { 0.0, 0.0, 0.0 })
	{
		NPCGetEyePosition(this.Index, buffer, defaultValue);
	}
	
	public void GetEyePositionOffset(float buffer[3])
	{
		NPCGetEyePositionOffset(this.Index, buffer);
	}
	
	public void AddAnger(float amount)
	{
		NPCAddAnger(this.Index, amount);
	}
	
	public bool HasAttribute(const char[] attributeName)
	{
		return NPCHasAttribute(this.Index, attributeName);
	}
	
	public float GetAttributeValue(const char[] attributeName, float defaultValue = 0.0)
	{
		return NPCGetAttributeValue(this.Index, attributeName, defaultValue);
	}
}


bool NPCHasDeathCamEnabled(int iNPCIndex)
{
	return g_bNPCDeathCamEnabled[iNPCIndex];
}

void NPCSetDeathCamEnabled(int iNPCIndex, bool state)
{
	g_bNPCDeathCamEnabled[iNPCIndex] = state;
}

public void NPCInitialize()
{
	NPCChaserInitialize();
}

public void NPCOnConfigsExecuted()
{
	g_iNPCGlobalUniqueID = 0;
}

bool NPCIsValid(int iNPCIndex)
{
	return view_as<bool>(iNPCIndex >= 0 && iNPCIndex < MAX_BOSSES && NPCGetUniqueID(iNPCIndex) != -1);
}

int NPCGetUniqueID(int iNPCIndex)
{
	return g_iNPCUniqueID[iNPCIndex];
}

int NPCGetFromUniqueID(int iNPCUniqueID)
{
	if (iNPCUniqueID == -1) return -1;
	
	for (int i = 0; i < MAX_BOSSES; i++)
	{
		if (NPCGetUniqueID(i) == iNPCUniqueID)
		{
			return i;
		}
	}
	
	return -1;
}

int NPCGetEntRef(int iNPCIndex)
{
	return g_iSlender[iNPCIndex];
}

int NPCGetEntIndex(int iNPCIndex)
{
	return EntRefToEntIndex(NPCGetEntRef(iNPCIndex));
}

int NPCGetFromEntIndex(int entity)
{
	if (!entity || !IsValidEntity(entity)) return -1;
	
	for (int i = 0; i < MAX_BOSSES; i++)
	{
		if (NPCGetEntIndex(i) == entity)
		{
			return i;
		}
	}
	
	return -1;
}

int NPCGetCount()
{
	int iCount;
	for (int i = 0; i < MAX_BOSSES; i++)
	{
		if (NPCGetUniqueID(i) == -1) continue;
		if (NPCGetFlags(i) & SFF_FAKE) continue;
		
		iCount++;
	}
	
	return iCount;
}

int NPCGetProfileIndex(int iNPCIndex)
{
	return g_iNPCProfileIndex[iNPCIndex];
}

int NPCGetUniqueProfileIndex(int iNPCIndex)
{
	return g_iNPCUniqueProfileIndex[iNPCIndex];
}

bool NPCGetProfile(int iNPCIndex, char[] buffer,int bufferlen)
{
	strcopy(buffer, bufferlen, g_strSlenderProfile[iNPCIndex]);
	return true;
}

int NPCSetProfile(int iNPCIndex, const char[] sProfile)
{
	strcopy(g_strSlenderProfile[iNPCIndex], sizeof(g_strSlenderProfile[]), sProfile);
}

int NPCRemove(int iNPCIndex)
{
	if (!NPCIsValid(iNPCIndex)) return;
	
	RemoveProfile(iNPCIndex);
}
void NPCStopMusic()
{
	//Stop the music timer
	if(hTimerMusic != INVALID_HANDLE)
	{
		CloseHandle(hTimerMusic);
		hTimerMusic = INVALID_HANDLE;
	}
	//Stop the music for all players.
	for(int i = 1;i<=MaxClients;i++)
	{
		if(IsValidClient(i))
		{
			StopSound(i, MUSIC_CHAN, sCurrentMusicTrack);
		}
	}
}
stock bool MusicActive()
{
	if(hTimerMusic!=INVALID_HANDLE)
		return true;
	return false;
}
stock void GetBossMusic(char[] buffer,int bufferlen)
{
	strcopy(buffer,bufferlen,sCurrentMusicTrack);
}
public Action BossMusic(Handle timer,any iBossIndex)
{
	if(iBossIndex > -1)
	{
		char sProfile[SF2_MAX_PROFILE_NAME_LENGTH];
		NPCGetProfile(iBossIndex, sProfile, sizeof(sProfile));
		float time = GetProfileFloat(sProfile,"sound_music_loop",0.0);
		if(time > 0.0)
		{
			for(int i = 1;i<=MaxClients;i++)
			{
				if(IsValidClient(i))
				{
					StopSound(i, MUSIC_CHAN, sCurrentMusicTrack);
				}
			}
			hTimerMusic = CreateTimer(time,BossMusic,iBossIndex);
			return Plugin_Continue;
		}
	}
	hTimerMusic = INVALID_HANDLE;
	NPCStopMusic();
	return Plugin_Continue;
}
void NPCRemoveAll()
{
	for (int i = 0; i < MAX_BOSSES; i++)
	{
		NPCRemove(i);
	}
}

int NPCGetType(int iNPCIndex)
{
	return g_iNPCType[iNPCIndex];
}

int NPCGetFlags(int iNPCIndex)
{
	return g_iNPCFlags[iNPCIndex];
}

void NPCSetFlags(int iNPCIndex,int iFlags)
{
	g_iNPCFlags[iNPCIndex] = iFlags;
}

float NPCGetModelScale(int iNPCIndex)
{
	return g_flNPCModelScale[iNPCIndex];
}

float NPCGetSpeed(int iNPCIndex,int iDifficulty)
{
	return g_flNPCSpeed[iNPCIndex][iDifficulty];
}

float NPCGetMaxSpeed(int iNPCIndex,int iDifficulty)
{
	return g_flNPCMaxSpeed[iNPCIndex][iDifficulty];
}

float NPCGetTurnRate(int iNPCIndex)
{
	return g_flNPCTurnRate[iNPCIndex];
}

float NPCGetFOV(int iNPCIndex)
{
	return g_flNPCFieldOfView[iNPCIndex];
}

float NPCGetAnger(int iNPCIndex)
{
	return g_flNPCAnger[iNPCIndex];
}

void NPCSetAnger(int iNPCIndex, float flAnger)
{
	g_flNPCAnger[iNPCIndex] = flAnger;
}

void NPCAddAnger(int iNPCIndex, float flAmount)
{
	g_flNPCAnger[iNPCIndex] += flAmount;
}

float NPCGetAngerAddOnPageGrab(int iNPCIndex)
{
	return g_flNPCAngerAddOnPageGrab[iNPCIndex];
}

float NPCGetAngerAddOnPageGrabTimeDiff(int iNPCIndex)
{
	return g_flNPCAngerAddOnPageGrabTimeDiff[iNPCIndex];
}

float NPCGetEyePositionOffset(int iNPCIndex, float buffer[3])
{
	buffer[0] = g_flSlenderEyePosOffset[iNPCIndex][0];
	buffer[1] = g_flSlenderEyePosOffset[iNPCIndex][1];
	buffer[2] = g_flSlenderEyePosOffset[iNPCIndex][2];
}

float NPCGetSearchRadius(int iNPCIndex)
{
	return g_flNPCSearchRadius[iNPCIndex];
}

float NPCGetScareRadius(int iNPCIndex)
{
	return g_flNPCScareRadius[iNPCIndex];
}

float NPCGetScareCooldown(int iNPCIndex)
{
	return g_flNPCScareCooldown[iNPCIndex];
}

float NPCGetInstantKillRadius(int iNPCIndex)
{
	return g_flNPCInstantKillRadius[iNPCIndex];
}

int NPCGetTeleportType(int iNPCIndex)
{
	return g_iNPCTeleportType[iNPCIndex];
}

int NPCGetEnemy(int iNPCIndex)
{
	return g_iNPCEnemy[iNPCIndex];
}

void NPCSetEnemy(int iNPCIndex,int ent)
{
	g_iNPCEnemy[iNPCIndex] = IsValidEntity(ent) ? EntIndexToEntRef(ent) : INVALID_ENT_REFERENCE;
}

/**
 *	Returns the boss's eye position (eye pos offset + absorigin).
 */
bool NPCGetEyePosition(int iNPCIndex, float buffer[3], const float flDefaultValue[3]={ 0.0, 0.0, 0.0 })
{
	buffer[0] = flDefaultValue[0];
	buffer[1] = flDefaultValue[1];
	buffer[2] = flDefaultValue[2];
	
	if (!NPCIsValid(iNPCIndex)) return false;
	
	int iNPC = NPCGetEntIndex(iNPCIndex);
	if (!iNPC || iNPC == INVALID_ENT_REFERENCE) return false;
	
	// @TODO: Replace SlenderGetAbsOrigin with GetEntPropVector
	float flPos[3], flEyePosOffset[3];
	SlenderGetAbsOrigin(iNPCIndex, flPos);
	NPCGetEyePositionOffset(iNPCIndex, flEyePosOffset);
	
	AddVectors(flPos, flEyePosOffset, buffer);
	return true;
}

bool NPCHasAttribute(int iNPCIndex, const char[] sAttribute)
{
	if (NPCGetUniqueID(iNPCIndex) == -1) return false;
	
	char sProfile[SF2_MAX_PROFILE_NAME_LENGTH];
	NPCGetProfile(iNPCIndex, sProfile, sizeof(sProfile));
	
	KvRewind(g_hConfig);
	KvJumpToKey(g_hConfig, sProfile);
	
	if (!KvJumpToKey(g_hConfig, "attributes")) return false;
	
	return KvJumpToKey(g_hConfig, sAttribute);
}

float NPCGetAttributeValue(int iNPCIndex, const char[] sAttribute, float flDefaultValue=0.0)
{
	if (!NPCHasAttribute(iNPCIndex, sAttribute)) return flDefaultValue;
	return KvGetFloat(g_hConfig, "value", flDefaultValue);
}

bool SlenderCanRemove(int iBossIndex)
{
	if (NPCGetUniqueID(iBossIndex) == -1) return false;
	
	if (PeopleCanSeeSlender(iBossIndex, _, false)) return false;
	
	char sProfile[SF2_MAX_PROFILE_NAME_LENGTH];
	NPCGetProfile(iBossIndex, sProfile, sizeof(sProfile));
	
	int iTeleportType = GetProfileNum(sProfile, "teleport_type");
	
	switch (iTeleportType)
	{
		case 0:
		{
			if (GetProfileNum(sProfile, "static_on_radius"))
			{
				float flSlenderPos[3], flBuffer[3];
				SlenderGetAbsOrigin(iBossIndex, flSlenderPos);
			
				for (int i = 1; i <= MaxClients; i++)
				{
					if (!IsClientInGame(i) || 
						!IsPlayerAlive(i) || 
						g_bPlayerEliminated[i] || 
						IsClientInGhostMode(i) || 
						IsClientInDeathCam(i)) continue;
					
					if (!IsPointVisibleToPlayer(i, flSlenderPos, false, false)) continue;
					
					GetClientAbsOrigin(i, flBuffer);
					if (GetVectorDistance(flBuffer, flSlenderPos) <= GetProfileFloat(sProfile, "static_radius"))
					{
						return false;
					}
				}
			}
		}
		case 1:
		{
			if (PeopleCanSeeSlender(iBossIndex, _, SlenderUsesBlink(iBossIndex)) || PeopleCanSeeSlender(iBossIndex, false, false))
			{
				return false;
			}
		}
		case 2:
		{
			int iState = g_iSlenderState[iBossIndex];
			if (iState == STATE_IDLE || iState == STATE_WANDER)
			{
				if (GetGameTime() < g_flSlenderTimeUntilKill[iBossIndex])
				{
					return false;
				}
			}
			else
			{
				return false;
			}
		}
	}
	
	return true;
}

bool SlenderGetAbsOrigin(int iBossIndex, float buffer[3], const float flDefaultValue[3]={ 0.0, 0.0, 0.0 })
{
	for (int i = 0; i < 3; i++) buffer[i] = flDefaultValue[i];
	
	if (iBossIndex < 0 || NPCGetUniqueID(iBossIndex) == -1) return false;
	
	int slender = NPCGetEntIndex(iBossIndex);
	if (!slender || slender == INVALID_ENT_REFERENCE) return false;
	
	char sProfile[SF2_MAX_PROFILE_NAME_LENGTH];
	NPCGetProfile(iBossIndex, sProfile, sizeof(sProfile));
	
	float flPos[3], flOffset[3];
	GetEntPropVector(slender, Prop_Data, "m_vecAbsOrigin", flPos);
	GetProfileVector(sProfile, "pos_offset", flOffset, flDefaultValue);
	SubtractVectors(flPos, flOffset, buffer);
	
	return true;
}

bool SlenderGetEyePosition(int iBossIndex, float buffer[3], const float flDefaultValue[3]={ 0.0, 0.0, 0.0 })
{
	return NPCGetEyePosition(iBossIndex, buffer, flDefaultValue);
}

bool SelectProfile(SF2NPC_BaseNPC Npc, const char[] sProfile,int iAdditionalBossFlags=0,SF2NPC_BaseNPC NpcCopyMaster=view_as<SF2NPC_BaseNPC>(SF2_INVALID_NPC), bool bSpawnCompanions=true, bool bPlaySpawnSound=true)
{
	if (!IsProfileValid(sProfile))
	{
		if(!NpcCopyMaster.IsValid())
		{
			LogSF2Message("Could not select profile for boss %d: profile %s is invalid!", Npc.Index, sProfile);
			return false;
		}
		/*else//Wait my copy master is valid but not my profil wut????
		{
			char sNewProfile[SF2_MAX_PROFILE_NAME_LENGTH];
			NpcCopyMaster.GetProfile(sNewProfile,sizeof(sNewProfile));
			//Add me again
			SelectProfile(Npc, sNewProfile, iAdditionalBossFlags, NpcCopyMaster, bSpawnCompanions, bPlaySpawnSound);
		}*/
	}
	
	Npc.Remove();
	
	int iProfileIndex = GetBossProfileIndexFromName(sProfile);
	int iUniqueProfileIndex = GetBossProfileUniqueProfileIndex(iProfileIndex);
	
	Npc.SetProfile(sProfile);
	
	int iBossType = GetBossProfileType(iProfileIndex);
	
	g_iNPCProfileIndex[Npc.Index] = iProfileIndex;
	g_iNPCUniqueProfileIndex[Npc.Index] = iUniqueProfileIndex;
	g_iNPCUniqueID[Npc.Index] = g_iNPCGlobalUniqueID++;
	g_iNPCType[Npc.Index] = iBossType;
	
	g_flNPCModelScale[Npc.Index] = GetBossProfileModelScale(iProfileIndex);
	
	NPCSetFlags(Npc.Index, GetBossProfileFlags(iProfileIndex) | iAdditionalBossFlags);
	
	GetBossProfileEyePositionOffset(iProfileIndex, g_flSlenderEyePosOffset[Npc.Index]);
	GetBossProfileEyeAngleOffset(iProfileIndex, g_flSlenderEyeAngOffset[Npc.Index]);
	
	GetProfileVector(sProfile, "mins", g_flSlenderDetectMins[Npc.Index]);
	GetProfileVector(sProfile, "maxs", g_flSlenderDetectMaxs[Npc.Index]);
	
	//	NPCSetAnger(Npc.Index, GetBossProfileAngerStart(iProfileIndex));
	Npc.Anger = GetBossProfileAngerStart(iProfileIndex);
	
	g_flNPCAngerAddOnPageGrab[Npc.Index] = GetBossProfileAngerAddOnPageGrab(iProfileIndex);
	g_flNPCAngerAddOnPageGrabTimeDiff[Npc.Index] = GetBossProfileAngerPageGrabTimeDiff(iProfileIndex);
	
	g_iSlenderCopyMaster[Npc.Index] = -1;
	g_iSlenderHealth[Npc.Index] = GetProfileNum(sProfile, "health", 900);
	
	for (int iDifficulty = 0; iDifficulty < Difficulty_Max; iDifficulty++)
	{
		g_flNPCSpeed[Npc.Index][iDifficulty] = GetBossProfileSpeed(iProfileIndex, iDifficulty);
		g_flNPCMaxSpeed[Npc.Index][iDifficulty] = GetBossProfileMaxSpeed(iProfileIndex, iDifficulty);
	}
	
	g_flNPCTurnRate[Npc.Index] = GetBossProfileTurnRate(iProfileIndex);
	g_flNPCFieldOfView[Npc.Index] = GetBossProfileFOV(iProfileIndex);
	
	g_flNPCSearchRadius[Npc.Index] = GetBossProfileSearchRadius(iProfileIndex);
	
	g_flNPCScareRadius[Npc.Index] = GetBossProfileScareRadius(iProfileIndex);
	g_flNPCScareCooldown[Npc.Index] = GetBossProfileScareCooldown(iProfileIndex);
	
	g_flNPCInstantKillRadius[Npc.Index] = GetBossProfileInstantKillRadius(iProfileIndex);
	
	g_iNPCTeleportType[Npc.Index] = GetBossProfileTeleportType(iProfileIndex);
	
	g_iNPCEnemy[Npc.Index] = INVALID_ENT_REFERENCE;
	
	// Deathcam values.
	Npc.DeathCamEnabled = view_as<bool>(GetProfileNum(sProfile, "death_cam"));
	
	g_flSlenderAcceleration[Npc.Index] = GetProfileFloat(sProfile, "acceleration", 150.0);
	g_hSlenderFakeTimer[Npc.Index] = INVALID_HANDLE;
	g_hSlenderEntityThink[Npc.Index] = INVALID_HANDLE;
	g_hSlenderAttackTimer[Npc.Index] = INVALID_HANDLE;
	g_flSlenderNextTeleportTime[Npc.Index] = GetGameTime();
	g_flSlenderLastKill[Npc.Index] = GetGameTime();
	g_flSlenderTimeUntilKill[Npc.Index] = -1.0;
	g_flSlenderNextJumpScare[Npc.Index] = -1.0;
	g_flSlenderTimeUntilNextProxy[Npc.Index] = -1.0;
	g_flSlenderTeleportMinRange[Npc.Index] = GetProfileFloat(sProfile, "teleport_range_min", 325.0);
	g_flSlenderTeleportMaxRange[Npc.Index] = GetProfileFloat(sProfile, "teleport_range_max", 1024.0);
	g_flSlenderStaticRadius[Npc.Index] = GetProfileFloat(sProfile, "static_radius");
	g_flSlenderIdleAnimationPlaybackRate[Npc.Index] = GetProfileFloat(sProfile, "animation_idle_playbackrate", 1.0);
	g_flSlenderWalkAnimationPlaybackRate[Npc.Index] = GetProfileFloat(sProfile, "animation_walk_playbackrate", 1.0);
	g_flSlenderRunAnimationPlaybackRate[Npc.Index] = GetProfileFloat(sProfile, "animation_run_playbackrate", 1.0);
	g_flSlenderJumpSpeed[Npc.Index] = GetProfileFloat(sProfile, "jump_speed", 512.0);
	g_flSlenderPathNodeTolerance[Npc.Index] = GetProfileFloat(sProfile, "search_node_dist_tolerance", 32.0);
	g_flSlenderPathNodeLookAhead[Npc.Index] = GetProfileFloat(sProfile, "search_node_dist_lookahead", 512.0);
	g_flSlenderProxyTeleportMinRange[Npc.Index] = GetProfileFloat(sProfile, "proxies_teleport_range_min");
	g_flSlenderProxyTeleportMaxRange[Npc.Index] = GetProfileFloat(sProfile, "proxies_teleport_range_max");
	
	for (int i = 1; i <= MaxClients; i++)
	{
		g_flPlayerLastChaseBossEncounterTime[i][Npc.Index] = -1.0;
		g_flSlenderTeleportPlayersRestTime[Npc.Index][i] = -1.0;
	}
	
	g_iSlenderTeleportTarget[Npc.Index] = INVALID_ENT_REFERENCE;
	g_flSlenderTeleportMaxTargetStress[Npc.Index] = 9999.0;
	g_flSlenderTeleportMaxTargetTime[Npc.Index] = -1.0;
	g_flSlenderNextTeleportTime[Npc.Index] = -1.0;
	g_flSlenderTeleportTargetTime[Npc.Index] = -1.0;
	
	g_hSlenderThink[Npc.Index] = CreateTimer(0.1, Timer_SlenderTeleportThink, Npc, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
	
	SlenderRemoveTargetMemory(Npc.Index);
	
	switch (iBossType)
	{
		case SF2BossType_Chaser:
		{
			NPCChaserOnSelectProfile(Npc.Index);
			
			SlenderCreateTargetMemory(Npc.Index);
		}
	}
	
	if (NpcCopyMaster.IsValid())
	{
		g_iSlenderCopyMaster[Npc.Index] = NpcCopyMaster.Index;
		g_flSlenderNextJumpScare[Npc.Index] = g_flSlenderNextJumpScare[NpcCopyMaster.Index];
		
		Npc.Anger = NpcCopyMaster.Anger;
	}
	else
	{
		if (bPlaySpawnSound)
		{
			char sBuffer[PLATFORM_MAX_PATH];
			GetRandomStringFromProfile(sProfile, "sound_spawn_all", sBuffer, sizeof(sBuffer));
			if (sBuffer[0]) EmitSoundToAll(sBuffer, _, SNDCHAN_STATIC, SNDLEVEL_HELICOPTER);
		}
		if(hTimerMusic==INVALID_HANDLE)
		{
			float time = GetProfileFloat(sProfile,"sound_music_loop",0.0);
			if(time > 0.0)
			{
				GetRandomStringFromProfile(sProfile,"sound_music",sCurrentMusicTrack,sizeof(sCurrentMusicTrack));
				hTimerMusic = CreateTimer(time,BossMusic,Npc.Index);
				for(int client = 1;client <=MaxClients;client ++)
				{
					if(IsValidClient(client) && !g_bPlayerEliminated[client])
					{
						StopSound(client, MUSIC_CHAN, sCurrentMusicTrack);
						ClientMusicStart(client, sCurrentMusicTrack, _, MUSIC_PAGE_VOLUME,true);
						ClientUpdateMusicSystem(client);
					}
				}
			}
		}
		if (bSpawnCompanions)
		{
			KvRewind(g_hConfig);
			KvJumpToKey(g_hConfig, sProfile);
			
			char sCompProfile[SF2_MAX_PROFILE_NAME_LENGTH];
			Handle hCompanions = CreateArray(SF2_MAX_PROFILE_NAME_LENGTH);
			
			if (KvJumpToKey(g_hConfig, "companions"))
			{
				char sNum[32];
				
				for (int i = 1;;i++)
				{
					IntToString(i, sNum, sizeof(sNum));
					KvGetString(g_hConfig, sNum, sCompProfile, sizeof(sCompProfile));
					if (!sCompProfile[0]) break;
					
					PushArrayString(hCompanions, sCompProfile);
				}
			}
			
			for (int i = 0, iSize = GetArraySize(hCompanions); i < iSize; i++)
			{
				GetArrayString(hCompanions, i, sCompProfile, sizeof(sCompProfile));
				AddProfile(sCompProfile, _, _, false, false);
			}
			
			CloseHandle(hCompanions);
		}
	}
	
	Call_StartForward(fOnBossAdded);
	Call_PushCell(Npc.Index);
	Call_Finish();
	
	return true;
}
//SF2NPC_BaseNPC NpcCopyMaster=view_as<SF2NPC_BaseNPC>(SF2_INVALID_NPC) <= Bug?
SF2NPC_BaseNPC AddProfile(const char[] strName,int iAdditionalBossFlags=0,SF2NPC_BaseNPC NpcCopyMaster=view_as<SF2NPC_BaseNPC>(SF2_INVALID_NPC), bool bSpawnCompanions=true, bool bPlaySpawnSound=true)
{
	for (int i = 0; i < MAX_BOSSES; i++)
	{
		SF2NPC_BaseNPC Npc = view_as<SF2NPC_BaseNPC>(i);
		if (!Npc.IsValid())
		{
			if (SelectProfile(Npc, strName, iAdditionalBossFlags, NpcCopyMaster, bSpawnCompanions, bPlaySpawnSound))
			{
				return Npc;
			}
			
			break;
		}
	}
	
	return SF2_INVALID_NPC;
}

void RemoveProfile(int iBossIndex)
{
	RemoveSlender(iBossIndex);
	
	// Call our forward.
	Call_StartForward(fOnBossRemoved);
	Call_PushCell(iBossIndex);
	Call_Finish();
	
	char sProfile[SF2_MAX_PROFILE_NAME_LENGTH];
	NPCGetProfile(iBossIndex, sProfile, sizeof(sProfile));
	
	NPCChaserOnRemoveProfile(iBossIndex);
	
	// Remove all possible sounds, for emergencies.
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i)) continue;
		
		// Remove chase music.
		if (g_iPlayerChaseMusicMaster[i] == iBossIndex)
		{
			ClientStopAllSlenderSounds(i, sProfile, "sound_chase", SNDCHAN_AUTO);
		}
	}
	
	// Clean up on the clients.
	for (int i = 1; i <= MaxClients; i++)
	{
		g_flSlenderLastFoundPlayer[iBossIndex][i] = -1.0;
		g_flPlayerLastChaseBossEncounterTime[i][iBossIndex] = -1.0;
		g_flSlenderTeleportPlayersRestTime[iBossIndex][i] = -1.0;
		
		for (int i2 = 0; i2 < 3; i2++)
		{
			g_flSlenderLastFoundPlayerPos[iBossIndex][i][i2] = 0.0;
		}
		
		if (IsClientInGame(i))
		{
			if (NPCGetUniqueID(iBossIndex) == g_iPlayerStaticMaster[i])
			{
				g_iPlayerStaticMaster[i] = -1;
				
				// No one is the static master.
				g_hPlayerStaticTimer[i] = CreateTimer(g_flPlayerStaticDecreaseRate[i], 
					Timer_ClientDecreaseStatic, 
					GetClientUserId(i), 
					TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
					
				TriggerTimer(g_hPlayerStaticTimer[i], true);
			}
		}
	}
	
	g_iNPCTeleportType[iBossIndex] = -1;
	g_iSlenderTeleportTarget[iBossIndex] = INVALID_ENT_REFERENCE;
	g_flSlenderTeleportMaxTargetStress[iBossIndex] = 9999.0;
	g_flSlenderTeleportMaxTargetTime[iBossIndex] = -1.0;
	g_flSlenderNextTeleportTime[iBossIndex] = -1.0;
	g_flSlenderTeleportTargetTime[iBossIndex] = -1.0;
	g_flSlenderTimeUntilKill[iBossIndex] = -1.0;
	
	// Remove all copies associated with me.
	for (int i = 0; i < MAX_BOSSES; i++)
	{
		if (i == iBossIndex || NPCGetUniqueID(i) == -1) continue;
		
		if (g_iSlenderCopyMaster[i] == iBossIndex)
		{
			LogMessage("Removed boss index %d because it is a copy of boss index %d", i, iBossIndex);
			NPCRemove(i);
		}
	}
	
	NPCSetProfile(iBossIndex, "");
	g_iNPCType[iBossIndex] = -1;
	g_iNPCProfileIndex[iBossIndex] = -1;
	g_iNPCUniqueProfileIndex[iBossIndex] = -1;
	
	NPCSetFlags(iBossIndex, 0);
	
	NPCSetAnger(iBossIndex, 1.0);
	
	g_flNPCFieldOfView[iBossIndex] = 0.0;
	
	g_iNPCEnemy[iBossIndex] = INVALID_ENT_REFERENCE;
	
	NPCSetDeathCamEnabled(iBossIndex, false);
	
	g_iSlenderCopyMaster[iBossIndex] = -1;
	g_iNPCUniqueID[iBossIndex] = -1;
	g_iSlender[iBossIndex] = INVALID_ENT_REFERENCE;
	g_hSlenderAttackTimer[iBossIndex] = INVALID_HANDLE;
	g_hSlenderThink[iBossIndex] = INVALID_HANDLE;
	g_hSlenderEntityThink[iBossIndex] = INVALID_HANDLE;
	
	g_hSlenderFakeTimer[iBossIndex] = INVALID_HANDLE;
	g_flSlenderLastKill[iBossIndex] = -1.0;
	g_iSlenderState[iBossIndex] = STATE_IDLE;
	g_iSlenderTarget[iBossIndex] = INVALID_ENT_REFERENCE;
	g_iSlenderModel[iBossIndex] = INVALID_ENT_REFERENCE;
	g_flSlenderAcceleration[iBossIndex] = 0.0;
	g_flSlenderTimeUntilNextProxy[iBossIndex] = -1.0;
	g_flNPCSearchRadius[iBossIndex] = 0.0;
	g_flNPCInstantKillRadius[iBossIndex] = 0.0;
	g_flNPCScareRadius[iBossIndex] = 0.0;
	g_flSlenderProxyTeleportMinRange[iBossIndex] = 0.0;
	g_flSlenderProxyTeleportMaxRange[iBossIndex] = 0.0;
	
	for (int i = 0; i < 3; i++)
	{
		g_flSlenderDetectMins[iBossIndex][i] = 0.0;
		g_flSlenderDetectMaxs[iBossIndex][i] = 0.0;
		g_flSlenderEyePosOffset[iBossIndex][i] = 0.0;
	}
	
	SlenderRemoveTargetMemory(iBossIndex);
}

void SpawnSlender(SF2NPC_BaseNPC Npc, const float pos[3])
{
	char sProfile[SF2_MAX_PROFILE_NAME_LENGTH];
	Npc.UnSpawn();
	Npc.GetProfile(sProfile,sizeof(sProfile));
	
	float flTruePos[3];
	GetProfileVector(sProfile, "pos_offset", flTruePos);
	AddVectors(flTruePos, pos, flTruePos);
	
	int iBossIndex = Npc.Index;
	int iSlenderModel = SpawnSlenderModel(iBossIndex, flTruePos);
	if (iSlenderModel == -1) 
	{
		LogError("Could not spawn boss: model failed to spawn!");
		return;
	}
	
	char sBuffer[PLATFORM_MAX_PATH];
	
	g_iSlenderModel[iBossIndex] = EntIndexToEntRef(iSlenderModel);
	
	switch (NPCGetType(iBossIndex))
	{
		case SF2BossType_Creeper:
		{
			g_iSlender[iBossIndex] = g_iSlenderModel[iBossIndex];
			g_hSlenderEntityThink[iBossIndex] = CreateTimer(BOSS_THINKRATE, Timer_SlenderBlinkBossThink, g_iSlender[iBossIndex], TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
		}
		case SF2BossType_Chaser:
		{
			GetProfileString(sProfile, "model", sBuffer, sizeof(sBuffer));
			
			int iBoss = CreateEntityByName("monster_generic");
			SetEntityModel(iBoss, sBuffer);
			TeleportEntity(iBoss, flTruePos, NULL_VECTOR, NULL_VECTOR);
			DispatchSpawn(iBoss);
			ActivateEntity(iBoss);
			SetEntityRenderMode(iBoss, RENDER_TRANSCOLOR);
			SetEntityRenderColor(iBoss, 0, 0, 0, 1);
			SetVariantString("!activator");
			AcceptEntityInput(iSlenderModel, "SetParent", iBoss);
			AcceptEntityInput(iSlenderModel, "EnableShadow");
			SetEntProp(iSlenderModel, Prop_Send, "m_usSolidFlags", FSOLID_NOT_SOLID | FSOLID_TRIGGER);
			AcceptEntityInput(iBoss, "DisableShadow");
			SetEntPropFloat(iBoss, Prop_Data, "m_flFriction", 0.0);
			
			
			NPCChaserSetStunHealth(iBossIndex, NPCChaserGetStunInitialHealth(iBossIndex));
			
			// Reset stats.
			g_bSlenderInBacon[iBossIndex] = false;
			g_iSlender[iBossIndex] = EntIndexToEntRef(iBoss);
			g_iSlenderTarget[iBossIndex] = INVALID_ENT_REFERENCE;
			g_iSlenderState[iBossIndex] = STATE_IDLE;
			g_bSlenderAttacking[iBossIndex] = false;
			g_hSlenderAttackTimer[iBossIndex] = INVALID_HANDLE;
			g_flSlenderTargetSoundLastTime[iBossIndex] = -1.0;
			g_flSlenderTargetSoundDiscardMasterPosTime[iBossIndex] = -1.0;
			g_iSlenderTargetSoundType[iBossIndex] = SoundType_None;
			g_bSlenderInvestigatingSound[iBossIndex] = false;
			g_flSlenderLastHeardFootstep[iBossIndex] = GetGameTime();
			g_flSlenderLastHeardVoice[iBossIndex] = GetGameTime();
			g_flSlenderLastHeardWeapon[iBossIndex] = GetGameTime();
			g_flSlenderNextVoiceSound[iBossIndex] = GetGameTime();
			g_flSlenderNextMoanSound[iBossIndex] = GetGameTime();
			g_flSlenderNextWanderPos[iBossIndex] = GetGameTime() + 3.0;
			g_flSlenderTimeUntilKill[iBossIndex] = GetGameTime() + GetProfileFloat(sProfile, "idle_lifetime", 10.0);
			g_flSlenderTimeUntilRecover[iBossIndex] = -1.0;
			g_flSlenderTimeUntilAlert[iBossIndex] = -1.0;
			g_flSlenderTimeUntilIdle[iBossIndex] = -1.0;
			g_flSlenderTimeUntilChase[iBossIndex] = -1.0;
			g_flSlenderTimeUntilNoPersistence[iBossIndex] = -1.0;
			g_flSlenderNextJump[iBossIndex] = GetGameTime() + GetProfileFloat(sProfile, "jump_cooldown", 2.0);
			g_flSlenderNextPathTime[iBossIndex] = GetGameTime();
			g_hSlenderEntityThink[iBossIndex] = CreateTimer(BOSS_THINKRATE, Timer_SlenderChaseBossThink, EntIndexToEntRef(iBoss), TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
			g_iSlenderInterruptConditions[iBossIndex] = 0;
			g_bSlenderChaseDeathPosition[iBossIndex] = false;
			
			for (int i = 0; i < 3; i++)
			{
				g_flSlenderGoalPos[iBossIndex][i] = 0.0;
				g_flSlenderTargetSoundTempPos[iBossIndex][i] = 0.0;
				g_flSlenderTargetSoundMasterPos[iBossIndex][i] = 0.0;
				g_flSlenderChaseDeathPosition[iBossIndex][i] = 0.0;
			}
			
			for (int i = 1; i <= MaxClients; i++)
			{
				g_flSlenderLastFoundPlayer[iBossIndex][i] = -1.0;
				
				for (int i2 = 0; i2 < 3; i2++)
				{
					g_flSlenderLastFoundPlayerPos[iBossIndex][i][i2] = 0.0;
				}
			}
			
			SlenderClearTargetMemory(iBossIndex);
			
			if (GetProfileNum(sProfile, "stun_enabled"))
			{
				SetEntProp(iBoss, Prop_Data, "m_takedamage", 1);
			}
			
			SDKHook(iBoss, SDKHook_OnTakeDamage, Hook_SlenderOnTakeDamage);
			DHookEntity(g_hSDKShouldTransmit, true, iBoss);
			
			
			//Because base_boss is used by tank_boss in MvM, valve accidently made an update that allows LMAOBOX users to see the sf2 boss/mvm tank. (A sf2 fix is comming soon).
			g_iSlenderHitbox[iBossIndex] = CreateEntityByName("base_boss");
			
			SetEntityModel(g_iSlenderHitbox[iBossIndex], sBuffer);
			TeleportEntity(g_iSlenderHitbox[iBossIndex], flTruePos, NULL_VECTOR, NULL_VECTOR);
			DispatchKeyValue(g_iSlenderHitbox[iBossIndex],"health","30000");
			DispatchKeyValue(g_iSlenderHitbox[iBossIndex],"TeamNum","1");
			DispatchSpawn(g_iSlenderHitbox[iBossIndex]);
			ActivateEntity(g_iSlenderHitbox[iBossIndex]);
			SetEntityRenderMode(g_iSlenderHitbox[iBossIndex], RENDER_TRANSCOLOR);
			SetEntityRenderColor(g_iSlenderHitbox[iBossIndex], 0, 0, 0, 1);
			SetVariantString("!activator");
			//AcceptEntityInput(g_iSlenderHitbox[iBossIndex], "SetParent", iBoss);
			AcceptEntityInput(g_iSlenderHitbox[iBossIndex], "EnableShadow");
			AcceptEntityInput(g_iSlenderHitbox[iBossIndex], "DisableShadow");
			//SetEntProp(g_iSlenderHitbox[iBossIndex], Prop_Send,"moveparent",iBoss);
			//SetEntProp(g_iSlenderHitbox[iBossIndex], Prop_Send,"m_iParentAttachment",iBoss);
			//SetEntProp(g_iSlenderHitbox[iBossIndex], Prop_Send,"m_hOwnerEntity",iBoss);
			//Block base_boss's ai.
			SetEntProp(g_iSlenderHitbox[iBossIndex], Prop_Data,"m_nNextThinkTick",-1);
			g_iSlenderHitboxOwner[g_iSlenderHitbox[iBossIndex]]=iBoss;
			//PrintToChatAll("Slender spawn: %i",g_iSlenderHitbox[iBossIndex]);
			SDKHook(g_iSlenderHitbox[iBossIndex],  SDKHook_ShouldCollide, Hook_HitBoxShouldCollide);
			SDKHook(g_iSlenderHitbox[iBossIndex], SDKHook_OnTakeDamage, Hook_HitboxOnTakeDamage);
			//SDKHook(g_iSlenderHitbox[iBossIndex], SDKHook_OnTakeDamagePost, Hook_HitboxOnTakeDamagePost);
			
			float flModelScale = NPCGetModelScale(iBossIndex);
			Slender_HitboxScale(g_iSlenderHitbox[iBossIndex],flModelScale);
			
			//(Experimental)
			if (view_as<bool>(GetProfileNum(sProfile,"healthbar",0)))
			{
				//The boss spawned for the 1st time, block now its teleportation ability to prevent healthbar conflict.
				NPCSetFlags(iBossIndex,NPCGetFlags(iBossIndex)|SFF_NOTELEPORT);
				UpdateHealthBar(iBossIndex);
			}
		}
		/*
		default:
		{
			g_iSlender[iBossIndex] = g_iSlenderModel[iBossIndex];
			SDKHook(iSlenderModel, SDKHook_SetTransmit, Hook_SlenderSetTransmit);
		}
		*/
	}
	
	SDKHook(iSlenderModel, SDKHook_SetTransmit, Hook_SlenderModelSetTransmit);
	
	SlenderSpawnEffects(iBossIndex, EffectEvent_Constant);
	
	// Initialize our pose parameters, if needed.
	int iPose = EntRefToEntIndex(g_iSlenderPoseEnt[iBossIndex]);
	g_iSlenderPoseEnt[iBossIndex] = INVALID_ENT_REFERENCE;
	if (iPose && iPose != INVALID_ENT_REFERENCE)
	{
		AcceptEntityInput(iPose, "Kill");
	}
	
	char sPoseParameter[64];
	GetProfileString(sProfile, "pose_parameter", sPoseParameter, sizeof(sPoseParameter));
	if (sPoseParameter[0])
	{
		iPose = CreateEntityByName("point_posecontroller");
		if (iPose != -1)
		{
			// We got a pose parameter! We need a name!
			Format(sBuffer, sizeof(sBuffer), "s%dposepls", g_iSlenderModel[iBossIndex]);
			DispatchKeyValue(iSlenderModel, "targetname", sBuffer);
			
			DispatchKeyValue(iPose, "PropName", sBuffer);
			DispatchKeyValue(iPose, "PoseParameterName", sPoseParameter);
			DispatchKeyValueFloat(iPose, "PoseValue", GetProfileFloat(sProfile, "pose_parameter_max"));
			DispatchSpawn(iPose);
			SetVariantString(sPoseParameter);
			AcceptEntityInput(iPose, "SetPoseParameterName");
			SetVariantString("!activator");
			AcceptEntityInput(iPose, "SetParent", iSlenderModel);
			
			g_iSlenderPoseEnt[iBossIndex] = EntIndexToEntRef(iPose);
		}
	}
	
	// Call our forward.
	Call_StartForward(fOnBossSpawn);
	Call_PushCell(iBossIndex);
	Call_Finish();
}
void Slender_HitboxScale(int iHitbox,float flScale)
{
	SetEntPropFloat(iHitbox, Prop_Send, "m_flModelScale", flScale);

	float flMins[3];
	float flMaxs[3];
	
	/*GetEntPropVector(iHitbox, Prop_Send, "m_vecSpecifiedSurroundingMins", flMins);
	GetEntPropVector(iHitbox, Prop_Send, "m_vecSpecifiedSurroundingMaxs", flMaxs);
	
	ScaleVector(flMins, flScale);
	ScaleVector(flMaxs, flScale);
	
	SetEntPropVector(iHitbox, Prop_Send, "m_vecSpecifiedSurroundingMins", flMins);
	SetEntPropVector(iHitbox, Prop_Send, "m_vecSpecifiedSurroundingMaxs", flMaxs);
	
	GetEntPropVector(iHitbox, Prop_Send, "m_vecSpecifiedSurroundingMinsPreScaled", flMins);
	GetEntPropVector(iHitbox, Prop_Send, "m_vecSpecifiedSurroundingMaxsPreScaled", flMaxs);
	
	ScaleVector(flMins, flScale);
	ScaleVector(flMaxs, flScale);
	
	SetEntPropVector(iHitbox, Prop_Send, "m_vecSpecifiedSurroundingMinsPreScaled", flMins);
	SetEntPropVector(iHitbox, Prop_Send, "m_vecSpecifiedSurroundingMaxsPreScaled", flMaxs);*/
	
	GetEntPropVector(iHitbox, Prop_Data, "m_vecMins", flMins);
	GetEntPropVector(iHitbox, Prop_Data, "m_vecMaxs", flMaxs);
	
	ScaleVector(flMins, flScale);
	ScaleVector(flMaxs, flScale);
	
	SetEntPropVector(iHitbox, Prop_Data, "m_vecMins", flMins);
	SetEntPropVector(iHitbox, Prop_Data, "m_vecMaxs", flMaxs);
	
}
void RemoveSlender(int iBossIndex)
{
	char sProfile[SF2_MAX_PROFILE_NAME_LENGTH];
	NPCGetProfile(iBossIndex, sProfile, sizeof(sProfile));

	int iBoss = NPCGetEntIndex(iBossIndex);
	g_iSlender[iBossIndex] = INVALID_ENT_REFERENCE;
	
	if (iBoss && iBoss != INVALID_ENT_REFERENCE)
	{
		//Turn off all slender's effects in order to prevent some bugs.
		SlenderRemoveEffects(iBoss);
		// Stop all possible looping sounds.
		ClientStopAllSlenderSounds(iBoss, sProfile, "sound_move", SNDCHAN_AUTO);
		
		if (NPCGetFlags(iBossIndex) & SFF_HASSTATICLOOPLOCALSOUND)
		{
			char sLoopSound[PLATFORM_MAX_PATH];
			GetRandomStringFromProfile(sProfile, "sound_static_loop_local", sLoopSound, sizeof(sLoopSound), 1);
			
			if (sLoopSound[0])
			{
				StopSound(iBoss, SNDCHAN_STATIC, sLoopSound);
			}
		}
		
		AcceptEntityInput(iBoss, "Kill");
	}
	
	iBoss = g_iSlenderHitbox[iBossIndex];
	g_iSlenderHitbox[iBossIndex] = INVALID_ENT_REFERENCE;
	
	if (iBoss && iBoss != INVALID_ENT_REFERENCE && IsValidEntity(iBoss))
		AcceptEntityInput(iBoss, "Kill");
}

public Action Hook_SlenderOnTakeDamage(int slender,int &attacker,int &inflictor,float &damage,int &damagetype,int &weapon, float damageForce[3],float damagePosition[3],int damagecustom)
{
	if (!g_bEnabled) return Plugin_Continue;
	
	int iBossIndex = NPCGetFromEntIndex(slender);
	if (iBossIndex == -1) return Plugin_Continue;
	if(IsValidEntity(attacker) && IsValidEntity(g_iSlenderHitbox[iBossIndex]))
	{
		if(attacker <= MaxClients && !IsValidClient(attacker)) return Plugin_Continue;
		SDKHooks_TakeDamage(g_iSlenderHitbox[iBossIndex], attacker, attacker, damage, damagetype);
		Boss_HitBox_Damage(g_iSlenderHitbox[iBossIndex], attacker, damage, damagetype);
		SetVariantInt(30000);
		AcceptEntityInput(g_iSlenderHitbox[iBossIndex],"SetHealth");
	}
	damage = 0.0;
	return Plugin_Changed;
}
public Action Hook_HitboxOnTakeDamage(int hitbox,int &attacker,int &inflictor,float &damage,int &damagetype,int &weapon, float damageForce[3],float damagePosition[3],int damagecustom)
{
	if (!g_bEnabled) return Plugin_Continue;
	damage = Boss_HitBox_Damage(hitbox, attacker, damage, damagetype);
	SetVariantInt(30000);
	AcceptEntityInput(hitbox,"SetHealth");
	
	return Plugin_Changed;
}
float Boss_HitBox_Damage(int hitbox,int attacker,float damage,int damagetype)
{
	if(damage > 0.0)
	{
		int iBossIndex = NPCGetFromEntIndex(g_iSlenderHitboxOwner[hitbox]);
		if (iBossIndex == -1) return damage;
		if(IsValidClient(attacker) && g_bPlayerProxy[attacker])
			damage = 0.0;
		if (NPCGetType(iBossIndex) == SF2BossType_Chaser && damage > 0.0)
		{
			char sProfile[SF2_MAX_PROFILE_NAME_LENGTH];
			NPCGetProfile(iBossIndex, sProfile, sizeof(sProfile));
			
			if (NPCChaserIsStunEnabled(iBossIndex))
			{
				if (damagetype & DMG_ACID) damage *= 2.0; // 2x damage for critical hits.
				
				NPCChaserAddStunHealth(iBossIndex, -damage);
				
				//(Experimental)
				if (view_as<bool>(GetProfileNum(sProfile,"healthbar",0)))
				{
					UpdateHealthBar(iBossIndex);
				}
				
				if (damagetype & DMG_ACID) damage /= 2.0; // 2x damage for critical hits.
			}
			if ((damagetype & DMG_CRIT))
			{
				float flMyEyePos[3];
				SlenderGetAbsOrigin(iBossIndex, flMyEyePos);
				float flMyEyePosEx[3];
				GetEntPropVector(hitbox, Prop_Send, "m_vecMaxs", flMyEyePosEx);
				flMyEyePos[2]+=flMyEyePosEx[2];
				
				TE_SetupTFParticleEffect(g_iParticle[CriticalHit], flMyEyePos, flMyEyePos);
				TE_SendToAll();
				
				EmitSoundToAll(CRIT_SOUND, hitbox, SNDCHAN_AUTO, SNDLEVEL_SCREAMING);
			}
		}
	}
	//Under Alpha stage can cause server crash.
	/*if(damage > 0.0)
		SF2_ANTILMAOBOX_HitBoxDoDamage(iBossIndex, attacker, damage, damagetype);
	*/
	return damage;
}
void UpdateHealthBar(int iBossIndex)
{
	float fMaxHealth = NPCChaserGetStunInitialHealth(iBossIndex);
	float fHealth = NPCChaserGetStunHealth(iBossIndex);
	if (g_ihealthBar == -1)
	{
		return;
	}
	int healthPercent;
	SetEntProp(g_ihealthBar, Prop_Send, "m_iBossState", 0);
	healthPercent=RoundToCeil((fHealth/fMaxHealth)*float(255));
	if(healthPercent>255)
	{
		healthPercent=255;
	}
	else if(healthPercent<=0)
	{
		healthPercent=0;
	}
	SetEntProp(g_ihealthBar, Prop_Send, "m_iBossHealthPercentageByte", healthPercent);
}
public bool Hook_HitBoxShouldCollide(int slender,int collisiongroup,int contentsmask, bool originalResult)
{
#if defined DEBUG
	SendDebugMessageToPlayers(DEBUG_BOSS_HITBOX,0,"Hitbox: %i wants to collide with entity contentsmask: %i",slender,contentsmask);
#endif
	if ((contentsmask & CONTENTS_MONSTERCLIP) || (contentsmask & CONTENTS_PLAYERCLIP))
	{
		//CONTENTS_MOVEABLE seems to make the hitbox bullet proof
#if defined DEBUG
		SendDebugMessageToPlayers(DEBUG_BOSS_HITBOX,0,"npc or player");
#endif
		return false;
	}
	return originalResult;
}
public Action Hook_SlenderModelSetTransmit(int entity,int other)
{
	if (!g_bEnabled) return Plugin_Continue;

	int iBossIndex = -1;
	
	int entref = EntIndexToEntRef(entity);
	
	for (int i = 0; i < MAX_BOSSES; i++)
	{
		if (NPCGetUniqueID(i) == -1) continue;
		if (g_iSlenderModel[i] != entref) continue;
		
		iBossIndex = i;
		break;
	}
	
	if (iBossIndex == -1) return Plugin_Continue;
	
	if (!IsPlayerAlive(other) || IsClientInDeathCam(other)) return Plugin_Handled;
	return Plugin_Continue;
}

stock bool SlenderCanHearPlayer(int iBossIndex,int client, SoundType iSoundType)
{
	if (!IsValidClient(client) || !IsPlayerAlive(client)) return false;
	
	int iSlender = NPCGetEntIndex(iBossIndex);
	if (!iSlender || iSlender == INVALID_ENT_REFERENCE) return false;
	
	char sProfile[SF2_MAX_PROFILE_NAME_LENGTH];
	NPCGetProfile(iBossIndex, sProfile, sizeof(sProfile));
	
	float flHisPos[3], flMyPos[3];
	GetClientAbsOrigin(client, flHisPos);
	SlenderGetAbsOrigin(iBossIndex, flMyPos);
	
	float flHearRadius = GetProfileFloat(sProfile, "search_sound_range", 1024.0);
	if (flHearRadius <= 0.0) return false;
	
	float flDistance = GetVectorDistance(flHisPos, flMyPos);
	
	// Trace check.
	Handle hTrace = INVALID_HANDLE;
	bool bTraceHit = false;
	
	float flMyEyePos[3];
	SlenderGetEyePosition(iBossIndex, flMyEyePos);
	
	if (iSoundType == SoundType_Footstep)
	{
		if (!(GetEntityFlags(client) & FL_ONGROUND)) return false;
		
		if (GetEntProp(client, Prop_Send, "m_bDucking") || GetEntProp(client, Prop_Send, "m_bDucked")) flDistance *= 1.85;
		if (IsClientReallySprinting(client)) flDistance *= 0.66;
		
		hTrace = TR_TraceRayFilterEx(flMyPos, flHisPos, MASK_NPCSOLID, RayType_EndPoint, TraceRayDontHitCharactersOrEntity, iSlender);
		bTraceHit = TR_DidHit(hTrace);
		CloseHandle(hTrace);
	}
	else if (iSoundType == SoundType_Voice)
	{
		float flHisEyePos[3];
		GetClientEyePosition(client, flHisEyePos);
		
		hTrace = TR_TraceRayFilterEx(flMyEyePos, flHisEyePos, MASK_NPCSOLID, RayType_EndPoint, TraceRayDontHitCharactersOrEntity, iSlender);
		bTraceHit = TR_DidHit(hTrace);
		CloseHandle(hTrace);
		
		flDistance *= 0.5;
	}
	else if (iSoundType == SoundType_Weapon)
	{
		float flHisMins[3], flHisMaxs[3];
		GetEntPropVector(client, Prop_Send, "m_vecMins", flHisMins);
		GetEntPropVector(client, Prop_Send, "m_vecMaxs", flHisMaxs);
		
		float flMiddle[3];
		for (int i = 0; i < 2; i++) flMiddle[i] = (flHisMins[i] + flHisMaxs[i]) / 2.0;
		
		float flEndPos[3];
		GetClientAbsOrigin(client, flEndPos);
		AddVectors(flHisPos, flMiddle, flEndPos);
		
		hTrace = TR_TraceRayFilterEx(flMyEyePos, flEndPos, MASK_NPCSOLID, RayType_EndPoint, TraceRayDontHitCharactersOrEntity, iSlender);
		bTraceHit = TR_DidHit(hTrace);
		CloseHandle(hTrace);
		
		flDistance *= 0.66;
	}
	
	if (bTraceHit) flDistance *= 1.66;
	
	if (TF2_GetPlayerClass(client) == TFClass_Spy) flDistance *= 1.35;
	
	if (flDistance > flHearRadius) return false;
	
	return true;
}

stock int SlenderArrayIndexToEntIndex(int iBossIndex)
{
	return NPCGetEntIndex(iBossIndex);
}

stock bool SlenderOnlyLooksIfNotSeen(int iBossIndex)
{
	if (NPCGetType(iBossIndex) == SF2BossType_Creeper) return true;
	return false;
}

stock bool SlenderUsesBlink(int iBossIndex)
{
	if (NPCGetType(iBossIndex) == SF2BossType_Creeper) return true;
	return false;
}

stock bool SlenderKillsOnNear(int iBossIndex)
{
	if (NPCGetType(iBossIndex) == SF2BossType_Creeper) return false;
	return true;
}

stock void SlenderClearTargetMemory(int iBossIndex)
{
	if (iBossIndex == -1) return;
	
	g_iSlenderCurrentPathNode[iBossIndex] = -1;
	if (g_hSlenderPath[iBossIndex] == INVALID_HANDLE) return;
	
	ClearArray(g_hSlenderPath[iBossIndex]);
}

stock bool SlenderCreateTargetMemory(int iBossIndex)
{
	if (iBossIndex == -1) return false;
	
	g_iSlenderCurrentPathNode[iBossIndex] = -1;
	if (g_hSlenderPath[iBossIndex] != INVALID_HANDLE) return true;
	
	g_hSlenderPath[iBossIndex] = CreateArray(3);
	return true;
}

stock void SlenderRemoveTargetMemory(int iBossIndex)
{
	if (iBossIndex == -1) return;
	
	g_iSlenderCurrentPathNode[iBossIndex] = -1;
	
	if (g_hSlenderPath[iBossIndex] == INVALID_HANDLE) return;
	
	Handle hLocs = g_hSlenderPath[iBossIndex];
	g_hSlenderPath[iBossIndex] = INVALID_HANDLE;
	CloseHandle(hLocs);
}

void SlenderPerformVoice(int iBossIndex, const char[] sSectionName,int iIndex=-1)
{
	if (iBossIndex == -1) return;

	int slender = NPCGetEntIndex(iBossIndex);
	if (!slender || slender == INVALID_ENT_REFERENCE) return;
	
	char sProfile[SF2_MAX_PROFILE_NAME_LENGTH];
	NPCGetProfile(iBossIndex, sProfile, sizeof(sProfile));
	
	char sPath[PLATFORM_MAX_PATH];
	GetRandomStringFromProfile(sProfile, sSectionName, sPath, sizeof(sPath), iIndex);
	if (sPath[0])
	{
		char sBuffer[512];
		strcopy(sBuffer, sizeof(sBuffer), sSectionName);
		StrCat(sBuffer, sizeof(sBuffer), "_cooldown_min");
		float flCooldownMin = GetProfileFloat(sProfile, sBuffer, 1.5);
		strcopy(sBuffer, sizeof(sBuffer), sSectionName);
		StrCat(sBuffer, sizeof(sBuffer), "_cooldown_max");
		float flCooldownMax = GetProfileFloat(sProfile, sBuffer, 1.5);
		float flCooldown = GetRandomFloat(flCooldownMin, flCooldownMax);
		strcopy(sBuffer, sizeof(sBuffer), sSectionName);
		StrCat(sBuffer, sizeof(sBuffer), "_volume");
		float flVolume = GetProfileFloat(sProfile, sBuffer, 1.0);
		strcopy(sBuffer, sizeof(sBuffer), sSectionName);
		StrCat(sBuffer, sizeof(sBuffer), "_channel");
		int iChannel = GetProfileNum(sProfile, sBuffer, SNDCHAN_AUTO);
		strcopy(sBuffer, sizeof(sBuffer), sSectionName);
		StrCat(sBuffer, sizeof(sBuffer), "_level");
		int iLevel = GetProfileNum(sProfile, sBuffer, SNDLEVEL_SCREAMING);
		
		g_flSlenderNextVoiceSound[iBossIndex] = GetGameTime() + flCooldown;
		EmitSoundToAll(sPath, slender, iChannel, iLevel, _, flVolume);
	}
}

bool SlenderCalculateApproachToPlayer(int iBossIndex,int iBestPlayer, float buffer[3])
{
	if (!IsValidClient(iBestPlayer)) return false;
	
	int slender = NPCGetEntIndex(iBossIndex);
	if (!slender || slender == INVALID_ENT_REFERENCE) return false;
	
	char sProfile[SF2_MAX_PROFILE_NAME_LENGTH];
	NPCGetProfile(iBossIndex, sProfile, sizeof(sProfile));
	
	float flSlenderPos[3], flPos[3], flReferenceAng[3], hisEyeAng[3], tempDir[3], tempPos[3];
	GetClientEyePosition(iBestPlayer, flPos);
	
	GetEntPropVector(slender, Prop_Data, "m_angAbsRotation", hisEyeAng);
	AddVectors(hisEyeAng, g_flSlenderEyeAngOffset[iBossIndex], hisEyeAng);
	for (int i = 0; i < 3; i++) hisEyeAng[i] = AngleNormalize(hisEyeAng[i]);
	
	SlenderGetAbsOrigin(iBossIndex, flSlenderPos);
	
	SubtractVectors(flPos, flSlenderPos, flReferenceAng);
	GetVectorAngles(flReferenceAng, flReferenceAng);
	for (int i = 0; i < 3; i++) flReferenceAng[i] = AngleNormalize(flReferenceAng[i]);
	float flDist = GetProfileFloat(sProfile, "speed") * g_flRoundDifficultyModifier;
	if (flDist < GetProfileFloat(sProfile, "kill_radius")) flDist = GetProfileFloat(sProfile, "kill_radius") / 2.0;
	float flWithinFOV = 45.0;
	float flWithinFOVSide = 90.0;
	
	Handle hTrace
	int index;
	float flHitNormal[3], tempPos2[3], flBuffer[3], flBuffer2[3];
	Handle hArray = CreateArray(6);
	
	float flCheckAng[3];
	
	int iRange = 0;
	int iID = 1;
	
	for (float addAng = 0.0; addAng < 360.0; addAng += 7.5)
	{
		tempDir[0] = 0.0;
		tempDir[1] = AngleNormalize(hisEyeAng[1] + addAng);
		tempDir[2] = 0.0;
		
		GetAngleVectors(tempDir, tempDir, NULL_VECTOR, NULL_VECTOR);
		NormalizeVector(tempDir, tempDir);
		ScaleVector(tempDir, flDist);
		AddVectors(tempDir, flSlenderPos, tempPos);
		AddVectors(tempPos, g_flSlenderEyePosOffset[iBossIndex], tempPos);
		AddVectors(flSlenderPos, g_flSlenderEyePosOffset[iBossIndex], tempPos2);
		
		flBuffer[0] = g_flSlenderDetectMins[iBossIndex][0];
		flBuffer[1] = g_flSlenderDetectMins[iBossIndex][1];
		flBuffer[2] = 0.0;
		flBuffer2[0] = g_flSlenderDetectMaxs[iBossIndex][0];
		flBuffer2[1] = g_flSlenderDetectMaxs[iBossIndex][1];
		flBuffer2[2] = 0.0;
		
		// Get a good move position.
		hTrace = TR_TraceHullFilterEx(tempPos2, tempPos, flBuffer, flBuffer2, MASK_PLAYERSOLID_BRUSHONLY, TraceRayDontHitCharactersOrEntity, slender);
		TR_GetEndPosition(tempPos, hTrace);
		CloseHandle(hTrace);
		
		// Drop to the ground if we're above ground.
		hTrace = TR_TraceRayFilterEx(tempPos, view_as<float>({ 90.0, 0.0, 0.0 }), MASK_PLAYERSOLID_BRUSHONLY, RayType_Infinite, TraceRayDontHitCharactersOrEntity, slender);
		bool bHit = TR_DidHit(hTrace);
		TR_GetEndPosition(tempPos2, hTrace);
		CloseHandle(hTrace);
		
		// Then calculate from there.
		hTrace = TR_TraceHullFilterEx(tempPos, tempPos2, g_flSlenderDetectMins[iBossIndex], g_flSlenderDetectMaxs[iBossIndex], MASK_PLAYERSOLID_BRUSHONLY, TraceRayDontHitCharactersOrEntity, slender);
		TR_GetEndPosition(tempPos, hTrace);
		TR_GetPlaneNormal(hTrace, flHitNormal);
		CloseHandle(hTrace);
		SubtractVectors(tempPos, flSlenderPos, flCheckAng);
		GetVectorAngles(flCheckAng, flCheckAng);
		GetVectorAngles(flHitNormal, flHitNormal);
		for (int i = 0; i < 3; i++) 
		{
			flHitNormal[i] = AngleNormalize(flHitNormal[i]);
			flCheckAng[i] = AngleNormalize(flCheckAng[i]);
		}
		
		float diff = AngleDiff(flCheckAng[1], flReferenceAng[1]);
		
		bool bBackup = false;
		
		if (FloatAbs(diff) > flWithinFOV) bBackup = true;
		
		if (diff >= 0.0 && diff <= flWithinFOVSide) iRange = 1;
		else if (diff < 0.0 && diff >= -flWithinFOVSide) iRange = 2;
		else continue;
		
		if ((flHitNormal[0] >= 0.0 && flHitNormal[0] < 45.0)
			|| (flHitNormal[0] < 0.0 && flHitNormal[0] > -45.0)
			|| !bHit
			|| TR_PointOutsideWorld(tempPos)
			|| IsSpaceOccupiedNPC(tempPos, g_flSlenderDetectMins[iBossIndex], g_flSlenderDetectMaxs[iBossIndex], iBestPlayer))
		{
			continue;
		}
		
		// Check from top to bottom of me.
		
		if (!IsPointVisibleToPlayer(iBestPlayer, tempPos, false, false)) continue;
		
		AddVectors(tempPos, g_flSlenderEyePosOffset[iBossIndex], tempPos);
		
		if (!IsPointVisibleToPlayer(iBestPlayer, tempPos, false, false)) continue;
		
		SubtractVectors(tempPos, g_flSlenderEyePosOffset[iBossIndex], tempPos);
		
		//	Insert the vector into our array.
		index = PushArrayCell(hArray, iID);
		SetArrayCell(hArray, index, tempPos[0], 1);
		SetArrayCell(hArray, index, tempPos[1], 2);
		SetArrayCell(hArray, index, tempPos[2], 3);
		SetArrayCell(hArray, index, iRange, 4);
		SetArrayCell(hArray, index, bBackup, 5);
		
		iID++;
	}
	
	int size;
	if ((size = GetArraySize(hArray)) > 0)
	{
		float diff = AngleDiff(hisEyeAng[1], flReferenceAng[1]);
		if (diff >= 0.0) iRange = 1;
		else iRange = 2;
		
		bool bBackup = false;
		
		// Clean up any vectors that we don't need.
		Handle hArray2 = CloneArray(hArray);
		for (int i = 0; i < size; i++)
		{
			if (GetArrayCell(hArray2, i, 4) != iRange || view_as<bool>(GetArrayCell(hArray2, i, 5) != bBackup))
			{
				int iIndex = FindValueInArray(hArray, GetArrayCell(hArray2, i));
				if (iIndex != -1) RemoveFromArray(hArray, iIndex);
			}
		}
		
		CloseHandle(hArray2);
		
		size = GetArraySize(hArray);
		if (size)
		{
			index = GetRandomInt(0, size - 1);
			buffer[0] = view_as<float>(GetArrayCell(hArray, index, 1));
			buffer[1] = view_as<float>(GetArrayCell(hArray, index, 2));
			buffer[2] = view_as<float>(GetArrayCell(hArray, index, 3));
		}
		else
		{
			CloseHandle(hArray);
			return false;
		}
	}
	else
	{
		CloseHandle(hArray);
		return false;
	}
	
	CloseHandle(hArray);
	return true;
}

// This functor ensures that the proposed boss position is not too
// close to other players that are within the distance defined by
// flMinSearchDist.

// Returning false on the functor will immediately discard the proposed position.

public bool SlenderChaseBossPlaceFunctor(int iBossIndex, const float flActiveAreaCenterPos[3], const float flAreaPos[3], float flMinSearchDist, float flMaxSearchDist, bool bOriginalResult)
{
	if (FloatAbs(flActiveAreaCenterPos[2] - flAreaPos[2]) > 320.0)
	{
		return false;
	}
	
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i) ||
			!IsPlayerAlive(i) ||
			g_bPlayerEliminated[i] ||
			g_bPlayerEscaped[i]) continue;
		
		float flClientPos[3];
		GetClientAbsOrigin(i, flClientPos);
		
		if (GetVectorDistance(flClientPos, flAreaPos) < flMinSearchDist)
		{
			return false;
		}
	}
	
	return bOriginalResult;
}

// As time passes on, we have to get more aggressive in order to successfully peak the target's
// stress level in the allotted duration we're given. Otherwise we'll be forced to place him
// in a rest period.

// Teleport progressively closer as time passes in attempt to increase the target's stress level.
// Maximum minimum range is capped by the boss's anger level.

stock float CalculateTeleportMinRange(int iBossIndex, float flInitialMinRange, float flTeleportMaxRange)
{
	float flTeleportTargetTimeLeft = g_flSlenderTeleportMaxTargetTime[iBossIndex] - GetGameTime();
	float flTeleportTargetTimeInitial = g_flSlenderTeleportMaxTargetTime[iBossIndex] - g_flSlenderTeleportTargetTime[iBossIndex];
	float flTeleportMinRange = flTeleportMaxRange - (1.0 - (flTeleportTargetTimeLeft / flTeleportTargetTimeInitial)) * (flTeleportMaxRange - flInitialMinRange);
	
	if (NPCGetAnger(iBossIndex) <= 1.0)
	{
		flTeleportMinRange += (g_flSlenderTeleportMinRange[iBossIndex] - flTeleportMaxRange) * Pow(NPCGetAnger(iBossIndex) - 1.0, 2.0 / g_flRoundDifficultyModifier);
	}
	
	if (flTeleportMinRange < flInitialMinRange) flTeleportMinRange = flInitialMinRange;
	if (flTeleportMinRange > flTeleportMaxRange) flTeleportMinRange = flTeleportMaxRange;
	
	return flTeleportMinRange;
}

public Action Timer_SlenderTeleportThink(Handle timer, any iBossIndex)
{
	if (iBossIndex == -1) return Plugin_Stop;
	if (timer != g_hSlenderThink[iBossIndex]) return Plugin_Stop;
	
	if (NPCGetFlags(iBossIndex) & SFF_NOTELEPORT) return Plugin_Continue;
	
	// Check to see if anyone's looking at me before doing anything.
	if (PeopleCanSeeSlender(iBossIndex, _, false))
	{
		return Plugin_Continue;
	}
	
	if (NPCGetTeleportType(iBossIndex) == 2)
	{
		int iBoss = NPCGetEntIndex(iBossIndex);
		if (iBoss && iBoss != INVALID_ENT_REFERENCE)
		{
			if (NPCGetType(iBossIndex) == SF2BossType_Chaser)
			{
				// Check to see if it's a good time to teleport away.
				int iState = g_iSlenderState[iBossIndex];
				if (iState == STATE_IDLE || iState == STATE_WANDER)
				{
					if (GetGameTime() < g_flSlenderTimeUntilKill[iBossIndex])
					{
						return Plugin_Continue;
					}
				}
			}
		}
	}
	
	char sProfile[SF2_MAX_PROFILE_NAME_LENGTH];
	NPCGetProfile(iBossIndex, sProfile, sizeof(sProfile));
	
	if (!g_bRoundGrace)
	{
		if (GetGameTime() >= g_flSlenderNextTeleportTime[iBossIndex])
		{
			float flTeleportTime = GetRandomFloat(GetProfileFloat(sProfile, "teleport_time_min", 5.0), GetProfileFloat(sProfile, "teleport_time_max", 9.0));
			g_flSlenderNextTeleportTime[iBossIndex] = GetGameTime() + flTeleportTime;
			
			int iTeleportTarget = EntRefToEntIndex(g_iSlenderTeleportTarget[iBossIndex]);
			
			if (!iTeleportTarget || iTeleportTarget == INVALID_ENT_REFERENCE)
			{
				// We don't have any good targets. Remove myself for now.
				if (SlenderCanRemove(iBossIndex)) RemoveSlender(iBossIndex);
				
#if defined DEBUG
				SendDebugMessageToPlayers(DEBUG_BOSS_TELEPORTATION, 0, "Teleport for boss %d: no good target, removing...", iBossIndex);
#endif
			}
			else
			{
				float flTeleportMinRange = CalculateTeleportMinRange(iBossIndex, g_flSlenderTeleportMinRange[iBossIndex], g_flSlenderTeleportMaxRange[iBossIndex]);
				int iTeleportAreaIndex = -1;
				float flTeleportPos[3];
				
				// Search surrounding nav areas around target.
				if (NavMesh_Exists())
				{
					float flTargetPos[3];
					GetClientAbsOrigin(iTeleportTarget, flTargetPos);
					
					int iTargetAreaIndex = NavMesh_GetNearestArea(flTargetPos);
					if (iTargetAreaIndex != -1)
					{
						bool bShouldBeBehindObstruction = false;
						if (NPCGetTeleportType(iBossIndex) == 2)
						{
							bShouldBeBehindObstruction = true;
						}
						
						// Search outwards until travel distance is at maximum range.
						Handle hAreaArray = CreateArray(2);
						Handle hAreas = CreateStack();
						NavMesh_CollectSurroundingAreas(hAreas, iTargetAreaIndex, g_flSlenderTeleportMaxRange[iBossIndex]);
						
						{
							int iPoppedAreas;
						
							while (!IsStackEmpty(hAreas))
							{
								int iAreaIndex = -1;
								PopStackCell(hAreas, iAreaIndex);
								
								// Check flags.
								if (NavMeshArea_GetFlags(iAreaIndex) & NAV_MESH_NO_HOSTAGES)
								{
									// Don't spawn/teleport at areas marked with the "NO HOSTAGES" flag.
									continue;
								}
								
								int iIndex = PushArrayCell(hAreaArray, iAreaIndex);
								SetArrayCell(hAreaArray, iIndex, float(NavMeshArea_GetCostSoFar(iAreaIndex)), 1);
								iPoppedAreas++;
							}
							
#if defined DEBUG
							SendDebugMessageToPlayers(DEBUG_BOSS_TELEPORTATION, 0, "Teleport for boss %d: collected %d areas", iBossIndex, iPoppedAreas);
#endif
							
							CloseHandle(hAreas);
						}
						
						Handle hAreaArrayClose = CreateArray(4);
						Handle hAreaArrayAverage = CreateArray(4);
						Handle hAreaArrayFar = CreateArray(4);
						
						for (int i = 1; i <= 3; i++)
						{
							float flRangeSectionMin = flTeleportMinRange + (g_flSlenderTeleportMaxRange[iBossIndex] - flTeleportMinRange) * (float(i - 1) / 3.0);
							float flRangeSectionMax = flTeleportMinRange + (g_flSlenderTeleportMaxRange[iBossIndex] - flTeleportMinRange) * (float(i) / 3.0);
							
							for (int i2 = 0, iSize = GetArraySize(hAreaArray); i2 < iSize; i2++)
							{
								int iAreaIndex = GetArrayCell(hAreaArray, i2);
								
								float flAreaSpawnPoint[3];
								NavMeshArea_GetCenter(iAreaIndex, flAreaSpawnPoint);
								
								int iBoss = NPCGetEntIndex(iBossIndex);
								
								// Check space. First raise to HalfHumanHeight * 2, then trace downwards to get ground level.
								{
									float flTraceStartPos[3];
									flTraceStartPos[0] = flAreaSpawnPoint[0];
									flTraceStartPos[1] = flAreaSpawnPoint[1];
									flTraceStartPos[2] = flAreaSpawnPoint[2] + (HalfHumanHeight * 2.0);
									
									float flTraceMins[3];
									flTraceMins[0] = g_flSlenderDetectMins[iBossIndex][0];
									flTraceMins[1] = g_flSlenderDetectMins[iBossIndex][1];
									flTraceMins[2] = 0.0;
									
									
									float flTraceMaxs[3];
									flTraceMaxs[0] = g_flSlenderDetectMaxs[iBossIndex][0];
									flTraceMaxs[1] = g_flSlenderDetectMaxs[iBossIndex][1];
									flTraceMaxs[2] = 0.0;
									
									Handle hTrace = TR_TraceHullFilterEx(flTraceStartPos,
										flAreaSpawnPoint,
										flTraceMins,
										flTraceMaxs,
										MASK_NPCSOLID,
										TraceRayDontHitEntity,
										iBoss);
									
									float flTraceHitPos[3];
									TR_GetEndPosition(flTraceHitPos, hTrace);
									flTraceHitPos[2] += 1.0;
									CloseHandle(hTrace);
									
									if (IsSpaceOccupiedNPC(flTraceHitPos,
										g_flSlenderDetectMins[iBossIndex],
										g_flSlenderDetectMaxs[iBossIndex],
										iBoss))
									{
										continue;
									}
									
									if (NPCGetType(iBossIndex) == SF2BossType_Chaser)
									{
										if (IsSpaceOccupiedNPC(flTraceHitPos,
											HULL_HUMAN_MINS,
											HULL_HUMAN_MAXS,
											iBoss))
										{
											// Can't let an NPC spawn here; too little space. If we let it spawn here it will be non solid!
											continue;
										}
									}
									
									flAreaSpawnPoint[0] = flTraceHitPos[0];
									flAreaSpawnPoint[1] = flTraceHitPos[1];
									flAreaSpawnPoint[2] = flTraceHitPos[2];
								}
								
								// Check visibility.
								if (IsPointVisibleToAPlayer(flAreaSpawnPoint, !bShouldBeBehindObstruction, false)) continue;
								
								AddVectors(flAreaSpawnPoint, g_flSlenderEyePosOffset[iBossIndex], flAreaSpawnPoint);
								
								if (IsPointVisibleToAPlayer(flAreaSpawnPoint, !bShouldBeBehindObstruction, false)) continue;
								
								SubtractVectors(flAreaSpawnPoint, g_flSlenderEyePosOffset[iBossIndex], flAreaSpawnPoint);
								
								bool bTooNear = false;
								
								// Check minimum range with players.
								for (int iClient = 1; iClient <= MaxClients; iClient++)
								{
									if (!IsClientInGame(iClient) ||
										!IsPlayerAlive(iClient) ||
										g_bPlayerEliminated[iClient] ||
										IsClientInGhostMode(iClient) || 
										DidClientEscape(iClient))
									{
										continue;
									}
									
									float flTempPos[3];
									GetClientAbsOrigin(iClient, flTempPos);
									
									if (GetVectorDistance(flAreaSpawnPoint, flTempPos) <= g_flSlenderTeleportMinRange[iBossIndex])
									{
										bTooNear = true;
										break;
									}
								}
								
								if (bTooNear) continue;	// This area is not compatible.
								
								// Check minimum range with boss copies (if supported).
								if (NPCGetFlags(iBossIndex) & SFF_COPIES)
								{
									float flMinDistBetweenBosses = GetProfileFloat(sProfile, "copy_teleport_dist_from_others", 800.0);
									
									for (int iBossCheck = 0; iBossCheck < MAX_BOSSES; iBossCheck++)
									{
										if (iBossCheck == iBossIndex ||
											NPCGetUniqueID(iBossCheck) == -1 ||
											(g_iSlenderCopyMaster[iBossIndex] != iBossCheck && g_iSlenderCopyMaster[iBossIndex] != g_iSlenderCopyMaster[iBossCheck]))
										{
											continue;
										}
										
										int iBossEnt = NPCGetEntIndex(iBossCheck);
										if (!iBossEnt || iBossEnt == INVALID_ENT_REFERENCE) continue;
										
										float flTempPos[3];
										SlenderGetAbsOrigin(iBossCheck, flTempPos);
										
										if (GetVectorDistance(flAreaSpawnPoint, flTempPos) <= flMinDistBetweenBosses)
										{
											bTooNear = true;
											break;
										}
									}
								}
								
								if (bTooNear) continue;	// This area is not compatible.
								
								// Check travel distance and put in the appropriate arrays.
								float flDist = view_as<float>(GetArrayCell(hAreaArray, i2, 1));
								if (flDist > flRangeSectionMin && flDist < flRangeSectionMax)
								{
									int iIndex = -1;
									Handle hTargetAreaArray = INVALID_HANDLE;
									
									switch (i)
									{
										case 1: 
										{
											iIndex = PushArrayCell(hAreaArrayClose, iAreaIndex);
											hTargetAreaArray = hAreaArrayClose;
										}
										case 2: 
										{
											iIndex = PushArrayCell(hAreaArrayAverage, iAreaIndex);
											hTargetAreaArray = hAreaArrayAverage;
										}
										case 3: 
										{
											iIndex = PushArrayCell(hAreaArrayFar, iAreaIndex);
											hTargetAreaArray = hAreaArrayFar;
										}
									}
									
									if (hTargetAreaArray != INVALID_HANDLE && iIndex != -1)
									{
										SetArrayCell(hTargetAreaArray, iIndex, flAreaSpawnPoint[0], 1);
										SetArrayCell(hTargetAreaArray, iIndex, flAreaSpawnPoint[1], 2);
										SetArrayCell(hTargetAreaArray, iIndex, flAreaSpawnPoint[2], 3);
									}
								}
							}
						}
						
						CloseHandle(hAreaArray);
						
#if defined DEBUG
						SendDebugMessageToPlayers(DEBUG_BOSS_TELEPORTATION, 0, "Teleport for boss %d: collected %d close areas, %d average areas, %d far areas", iBossIndex, GetArraySize(hAreaArrayClose),
							GetArraySize(hAreaArrayAverage),
							GetArraySize(hAreaArrayFar));
#endif
						
						int iArrayIndex = -1;
						
						if (GetArraySize(hAreaArrayClose))
						{
							iArrayIndex = GetRandomInt(0, GetArraySize(hAreaArrayClose) - 1);
							iTeleportAreaIndex = GetArrayCell(hAreaArrayClose, iArrayIndex);
							flTeleportPos[0] = view_as<float>(GetArrayCell(hAreaArrayClose, iArrayIndex, 1));
							flTeleportPos[1] = view_as<float>(GetArrayCell(hAreaArrayClose, iArrayIndex, 2));
							flTeleportPos[2] = view_as<float>(GetArrayCell(hAreaArrayClose, iArrayIndex, 3));
						}
						else if (GetArraySize(hAreaArrayAverage))
						{
							iArrayIndex = GetRandomInt(0, GetArraySize(hAreaArrayAverage) - 1);
							iTeleportAreaIndex = GetArrayCell(hAreaArrayAverage, iArrayIndex);
							flTeleportPos[0] = view_as<float>(GetArrayCell(hAreaArrayAverage, iArrayIndex, 1));
							flTeleportPos[1] = view_as<float>(GetArrayCell(hAreaArrayAverage, iArrayIndex, 2));
							flTeleportPos[2] = view_as<float>(GetArrayCell(hAreaArrayAverage, iArrayIndex, 3));
						}
						else if (GetArraySize(hAreaArrayFar))
						{
							iArrayIndex = GetRandomInt(0, GetArraySize(hAreaArrayFar) - 1);
							iTeleportAreaIndex = GetArrayCell(hAreaArrayFar, iArrayIndex);
							flTeleportPos[0] = view_as<float>(GetArrayCell(hAreaArrayFar, iArrayIndex, 1));
							flTeleportPos[1] = view_as<float>(GetArrayCell(hAreaArrayFar, iArrayIndex, 2));
							flTeleportPos[2] = view_as<float>(GetArrayCell(hAreaArrayFar, iArrayIndex, 3));
						}
						
						CloseHandle(hAreaArrayClose);
						CloseHandle(hAreaArrayAverage);
						CloseHandle(hAreaArrayFar);
					}
					else
					{
#if defined DEBUG
						SendDebugMessageToPlayers(DEBUG_BOSS_TELEPORTATION, 0, "Teleport for boss %d: failed because target is not on nav mesh!", iBossIndex);
#endif
					}
				}
				else
				{
#if defined DEBUG
					SendDebugMessageToPlayers(DEBUG_BOSS_TELEPORTATION, 0, "Teleport for boss %d: failed because of lack of nav mesh!", iBossIndex);
#endif
				}
				
				if (iTeleportAreaIndex == -1)
				{
					// We don't have any good areas. Remove myself for now.
					if (SlenderCanRemove(iBossIndex)) RemoveSlender(iBossIndex);
				}
				else
				{
					SpawnSlender(iBossIndex, flTeleportPos);
					
					if (NPCGetFlags(iBossIndex) & SFF_HASJUMPSCARE)
					{
						bool bDidJumpScare = false;
						
						for (int i = 1; i <= MaxClients; i++)
						{
							if (!IsClientInGame(i) || !IsPlayerAlive(i) || g_bPlayerEliminated[i] || IsClientInGhostMode(i)) continue;
							
							if (PlayerCanSeeSlender(i, iBossIndex, false))
							{
								if ((NPCGetDistanceFromEntity(iBossIndex, i) <= GetProfileFloat(sProfile, "jumpscare_distance") &&
									GetGameTime() >= g_flSlenderNextJumpScare[iBossIndex]) ||
									PlayerCanSeeSlender(i, iBossIndex))
								{
									bDidJumpScare = true;
								
									float flJumpScareDuration = GetProfileFloat(sProfile, "jumpscare_duration");
									ClientDoJumpScare(i, iBossIndex, flJumpScareDuration);
								}
							}
						}
						
						if (bDidJumpScare)
						{
							g_flSlenderNextJumpScare[iBossIndex] = GetGameTime() + GetProfileFloat(sProfile, "jumpscare_cooldown");
						}
					}
				}
			}
		}
		else
		{
#if defined DEBUG
			SendDebugMessageToPlayers(DEBUG_BOSS_TELEPORTATION, 0, "Teleport for boss %d: failed because of teleport time (curtime: %f, teletime: %f)", iBossIndex, GetGameTime(), g_flSlenderNextTeleportTime[iBossIndex]);
#endif
		}
	}
	
	return Plugin_Continue;
}

/*
// Deprecated.
// This is just to calculate the new place, not do time checks.
// Distance will be determined by the progression of the game and the
// manually set values determined by flMinSearchDist and flMaxSearchDist,
// which are float values that are (or should be) defined in the boss's
// config file.
// The place chosen should be out of (possible) sight of the players,
// but should be within the AAS radius, the center being flActiveAreaCenterPos.
// The game will try to find a place that is of flMinSearchDist first, but
// if it can't, then it will try to find places that are a bit farther.
// If the whole function fails, no place is given and the boss will not
// be able to spawn.
bool SlenderChaseBossCalculateNewPlace(int iBossIndex, const float flActiveAreaCenterPos[3], float flMinSearchDist, float flMaxSearchDist, Function iFunctor, float flBuffer[3])
{
	Handle hAreas = NavMesh_GetAreas();
	if (hAreas == INVALID_HANDLE) return false;
	
	int iBestAreaIndex = -1;
	float flBestAreaDist = -1.0;
	
	float flAreaCenterPos[3];
	for (int i = 0, iSize = GetArraySize(hAreas); i < iSize; i++)
	{
		NavMeshArea_GetCenter(i, flAreaCenterPos);
		
		float flDist = GetVectorDistance(flActiveAreaCenterPos, flAreaCenterPos);
		if (flDist < flMinSearchDist || flDist > flMaxSearchDist) continue;
		
		if (IsPointVisibleToAPlayer(flAreaCenterPos, false, false)) continue;
		
		float flTestPos[3];
		for (int i2 = 0; i2 < 3; i2++) flTestPos[i2] = flAreaCenterPos[i2] + g_flSlenderEyePosOffset[iBossIndex][i2];
		
		if (IsPointVisibleToAPlayer(flTestPos, false, false)) continue;
		
		if (iFunctor != INVALID_FUNCTION)
		{
			bool bResult = true;
			
			Call_StartFunction(INVALID_HANDLE, iFunctor);
			Call_PushCell(iBossIndex);
			Call_PushArray(flActiveAreaCenterPos, 3);
			Call_PushArray(flAreaCenterPos, 3);
			Call_PushFloat(flMinSearchDist);
			Call_PushFloat(flMaxSearchDist);
			Call_PushCell(bResult);
			Call_Finish(bResult);
			
			if (!bResult) continue;
		}
		
		if (flBestAreaDist < 0.0 || flDist < flBestAreaDist)
		{
			iBestAreaIndex = i;
			flBestAreaDist = flDist;
		}
	}
	
	if (iBestAreaIndex == -1) return false;
	
	NavMeshArea_GetCenter(iBestAreaIndex, flBuffer);
	return true;
}
*/

/*bool SlenderCalculateNewPlace(int iBossIndex, float buffer[3], bool bIgnoreCopies=false, bool bProxy=false,int iProxyPlayer=-1,int &iBestPlayer=-1, Handle hAreaArray=INVALID_HANDLE)
{
	char sProfile[SF2_MAX_PROFILE_NAME_LENGTH];
	NPCGetProfile(iBossIndex, sProfile, sizeof(sProfile));

	float flPercent = 0.0;
	if (g_iPageMax > 0)
	{
		flPercent = (float(g_iPageCount) / float(g_iPageMax)) * g_flRoundDifficultyModifier * NPCGetAnger(iBossIndex);
	}
	
#if defined DEBUG
	int iArraySize, iArraySize2;
#endif
	
	if (!IsValidClient(iBestPlayer))
	{
		// 	Pick a player to appear to.
		Handle hArray = CreateArray();
		
		for (int i = 1; i <= MaxClients; i++)
		{
			if (!IsClientInGame(i) || 
				!IsPlayerAlive(i) || 
				IsClientInDeathCam(i) || 
				g_bPlayerEliminated[i] || 
				g_bPlayerEscaped[i]) continue;
			
			if (NPCGetFromUniqueID(g_iSlenderCopyMaster[iBossIndex]) != -1 && !bIgnoreCopies)
			{
				bool bwub = false;
			
				// No? Then check if players around him are targeted by a boss already (not me).
				for (int iBossPlayer = 1; iBossPlayer <= MaxClients; iBossPlayer++)
				{
					if (i == iBossPlayer) continue;
				
					if (!IsClientInGame(iBossPlayer) || 
						!IsPlayerAlive(iBossPlayer) || 
						IsClientInDeathCam(iBossPlayer) || 
						g_bPlayerEliminated[iBossPlayer] || 
						g_bPlayerEscaped[iBossPlayer]) continue;
					
					// Get the boss that's targeting this player, if any.
					for (int iBoss = 0; iBoss < MAX_BOSSES; iBoss++)
					{
						if (iBossIndex == iBoss || NPCGetUniqueID(iBoss) == -1) continue;
						
						if (EntRefToEntIndex(g_iSlenderTarget[iBoss]) == iBossPlayer)
						{
							// Are we near this player?
							if (EntityDistanceFromEntity(iBossPlayer, i) < SF2_BOSS_COPY_SPAWN_MIN_DISTANCE)
							{
								bwub = true;
								break;
							}
						}
					}
				}
				
				if (bwub) continue;
			}
			
			PushArrayCell(hArray, i);
		}
		
#if defined DEBUG
		iArraySize = GetArraySize(hArray);
		iArraySize2 = iArraySize;
#endif
		
		if (GetArraySize(hArray))
		{
			if (g_iSlenderCopyMaster[iBossIndex] == -1 ||
				GetProfileNum(sProfile, "copy_calculatepagecount", 0))
			{
				int tempBestPageCount = -1;
				
				Handle hTempArray = CloneArray(hArray);
				for (int i = 0; i < GetArraySize(hTempArray); i++)
				{
					int iClient = GetArrayCell(hTempArray, i);
					if (g_iPlayerPageCount[iClient] > tempBestPageCount)
					{
						tempBestPageCount = g_iPlayerPageCount[iClient];
					}
				}
				
				for (int i = 0; i < GetArraySize(hTempArray); i++)
				{
					int iClient = GetArrayCell(hTempArray, i);
					if ((float(g_iPlayerPageCount[iClient]) / float(tempBestPageCount)) < SF2_BOSS_PAGE_CALCULATION)
					{
						int index = FindValueInArray(hArray, iClient);
						if (index != -1) RemoveFromArray(hArray, index);
					}
				}
				
				CloseHandle(hTempArray);
			}
			
#if defined DEBUG
			iArraySize2 = GetArraySize(hArray);
#endif
		}
		
		if (GetArraySize(hArray))
		{
			iBestPlayer = GetArrayCell(hArray, GetRandomInt(0, GetArraySize(hArray) - 1));
		}
	
		CloseHandle(hArray);
	}
	
#if defined DEBUG
	if (GetConVarBool(g_cvDebugBosses)) PrintToChatAll("SlenderCalculateNewPlace(%d): array size 1 = %d, array size 2 = %d", iBossIndex, iArraySize, iArraySize2);
#endif
	
	if (iBestPlayer <= 0) 
	{
#if defined DEBUG
		if (GetConVarBool(g_cvDebugBosses)) PrintToChatAll("SlenderCalculateNewPlace(%d) failed: no ibestPlayer!", iBossIndex);
#endif
		return false;
	}
	
	//	Determine the distance we can appear from the player.
	float flPercentFar = 0.75 * (1.0 - flPercent);
	float flPercentAverage = 0.6 * (1.0 - flPercent);
	//float flPercentClose = 1.0 - flPercentFar - flPercentAverage;
	
	float flUpperBoundFar = flPercentFar;
	float flUpperBoundAverage = flPercentFar + flPercentAverage;
	//float flUpperBoundClose = 1.0;
	
	int iRange = 1;
	float flChance = GetRandomFloat(0.0, 1.0);
	float flMaxRangeN = GetProfileFloat(sProfile, "teleport_range_max");
	float flMinRangeN = GetProfileFloat(sProfile, "teleport_range_min");
	
	bool bVisiblePls = false;
	bool bBeCreepy = false;
	
	if (!bProxy)
	{
		// Are we gonna teleport in front of a player this time?
		if (GetProfileNum(sProfile, "teleport_ignorevis_enable"))
		{
			if (GetRandomFloat(0.0, 1.0) < GetProfileFloat(sProfile, "teleport_ignorevis_chance") * NPCGetAnger(iBossIndex) * g_flRoundDifficultyModifier)
			{
				bVisiblePls = true;
			}
			
			if (GetRandomFloat(0.0, 1.0) < GetProfileFloat(sProfile, "teleport_creepy_chance", 0.33))
			{
				bBeCreepy = true;
			}
		}
	}
	
	float flMaxRange = flMaxRangeN;
	float flMinRange = flMinRangeN;
	
	if (bVisiblePls)
	{
		flMaxRange = GetProfileFloat(sProfile, "teleport_ignorevis_range_max", flMaxRangeN);
		flMinRange = GetProfileFloat(sProfile, "teleport_ignorevis_range_min", flMinRangeN);
	}
	
	// Get distances.
	float flDistanceFar = GetRandomFloat(flMaxRange * 0.75, flMaxRange);
	if (flDistanceFar < flMinRange) flDistanceFar = flMinRange;
	float flDistanceAverage = GetRandomFloat(flMaxRange * 0.33, flMaxRange * 0.75);
	if (flDistanceAverage < flMinRange) flDistanceAverage = flMinRange;
	float flDistanceClose = GetRandomFloat(0.0, flMaxRange * 0.33);
	if (flDistanceClose < flMinRange) flDistanceClose = flMinRange;
	
	if (flChance >= 0.0 && flChance < flUpperBoundFar) iRange = 1;
	else if (flChance >= flUpperBoundFar && flChance < flUpperBoundAverage) iRange = 2;
	else if (flChance >= flUpperBoundAverage) iRange = 3;
	
	// 	Get a circle of positions around the player that we can appear in.
	
	// Create arrays first.
	Handle hArrayFar = CreateArray(3);
	Handle hArrayAverage = CreateArray(3);
	Handle hArrayClose = CreateArray(3);
	
	// Set up our distances array.
	float flDistances[3];
	flDistances[0] = flDistanceFar;
	flDistances[1] = flDistanceAverage;
	flDistances[2] = flDistanceClose;
	
	float hisEyePos[3], hisEyeAng[3], tempPos[3], tempDir[3], flBuffer[3], flBuffer2[3], flBuffer3[3];
	GetClientEyePosition(iBestPlayer, hisEyePos);
	GetClientEyeAngles(iBestPlayer, hisEyeAng);
	
	Handle hTrace,
	float flHitNormal[3];
	int index;
	Handle hArray;
	
	float flTargetMins[3], flTargetMaxs[3];
	if (!bProxy)
	{
		for (int i = 0; i < 3; i++)
		{
			flTargetMins[i] = g_flSlenderDetectMins[iBossIndex][i];
			flTargetMaxs[i] = g_flSlenderDetectMaxs[iBossIndex][i];
		}
	}
	else
	{
		GetEntPropVector(iProxyPlayer, Prop_Send, "m_vecMins", flTargetMins);
		GetEntPropVector(iProxyPlayer, Prop_Send, "m_vecMaxs", flTargetMaxs);
	}
	
	for (int i = 0; i < iRange; i++)
	{
		for (float addAng = 0.0; addAng < 360.0; addAng += 1.5)
		{
			tempDir[0] = 0.0;
			tempDir[1] = hisEyeAng[1] + addAng;
			tempDir[2] = 0.0;
			
			GetAngleVectors(tempDir, tempDir, NULL_VECTOR, NULL_VECTOR);
			NormalizeVector(tempDir, tempDir);
			ScaleVector(tempDir, flDistances[i]);
			AddVectors(tempDir, hisEyePos, tempPos);
			
			// Drop to the ground if we're above ground using a TraceHull so IsSpaceOccupiedNPC can return true on something.
			hTrace = TR_TraceRayFilterEx(tempPos,view_as<float>({ 90.0, 0.0, 0.0 }), MASK_NPCSOLID, RayType_Infinite, TraceRayDontHitCharactersOrEntity, iBestPlayer);
			TR_GetEndPosition(flBuffer, hTrace);
			CloseHandle(hTrace);
			
			flBuffer2[0] = flTargetMins[0];
			flBuffer2[1] = flTargetMins[1];
			flBuffer2[2] = -flTargetMaxs[2];
			flBuffer3[0] = flTargetMaxs[0];
			flBuffer3[1] = flTargetMaxs[1];
			flBuffer3[2] = -flTargetMins[0];
			if (GetVectorDistance(tempPos, flBuffer) >= 300.0) continue;
			//PrintToChatAll("Dist: %0.0f",GetVectorDistance(tempPos, flBuffer));
			
			// Drop dowwwwwn.
			hTrace = TR_TraceHullFilterEx(tempPos, flBuffer, flBuffer2, flBuffer3, MASK_NPCSOLID, TraceRayDontHitCharactersOrEntity, iBestPlayer);
			TR_GetEndPosition(tempPos, hTrace);
			TR_GetPlaneNormal(hTrace, flHitNormal);
			CloseHandle(hTrace);
			
			GetVectorAngles(flHitNormal, flHitNormal);
			for (int i2 = 0; i2 < 3; i2++) flHitNormal[i2] = AngleNormalize(flHitNormal[i2]);
			
			//tempPos[2] -= g_flSlenderDetectMaxs[iBossIndex][2];
			//PrintToChatAll("Temp pos are: %0.0f, %0.0f, %0.0f",tempPos[0],tempPos[1],tempPos[2]);
			
			if (TR_PointOutsideWorld(tempPos))
			{
				//PrintToChatAll("The point is outside of the world");
				continue;
			}
			if((IsSpaceOccupiedNPC(tempPos, flTargetMins, flTargetMaxs, NPCGetEntIndex(iBossIndex))))
			{
				//PrintToChatAll("A NPC is standing on this pos");
				continue;
			}
			if((bProxy && IsSpaceOccupiedPlayer(tempPos, flTargetMins, flTargetMaxs, iProxyPlayer)))
			{
				//PrintToChatAll("A player is standing on this pos");
				continue
			}
			if((flHitNormal[0] >= 0.0 && flHitNormal[0] < 45.0) || (flHitNormal[0] < 0.0 && flHitNormal[0] > -45.0))
			{
				//PrintToChatAll("Bad angles");
				continue;
			}
			
			// Check if this position isn't too close to anyone else.
			bool bTooClose = false;
			
			for (int i2 = 1; i2 <= MaxClients; i2++)
			{
				if (!IsClientInGame(i2) || !IsPlayerAlive(i2) || g_bPlayerEliminated[i2] || IsClientInGhostMode(i2)) continue;
				GetClientAbsOrigin(i2, flBuffer);
				if (GetVectorDistance(flBuffer, tempPos) < flMinRange)
				{
					bTooClose = true;
					//PrintToChatAll("Too close from a player.");
					break;
				}
			}
			
			// Check if this position is too close to a boss.
			if (!bTooClose)
			{
				decl iSlender;
				for (int i2 = 0; i2 < MAX_BOSSES; i2++)
				{
					if (i2 == iBossIndex) continue;
					if (NPCGetUniqueID(i2) == -1) continue;
					
					// If I'm a main boss, only check the distance between my copies and me.
					if (g_iSlenderCopyMaster[iBossIndex] == -1)
					{
						if (g_iSlenderCopyMaster[i2] != iBossIndex) continue;
					}
					// If I'm a copy, just check with my other copy friends and my main boss.
					else
					{
						int iMyMaster = g_iSlenderCopyMaster[iBossIndex];
						if (g_iSlenderCopyMaster[i2] != iMyMaster || i2 != iMyMaster) continue;
					}
					
					iSlender = NPCGetEntIndex(i2);
					if (!iSlender || iSlender == INVALID_ENT_REFERENCE) continue;
					
					SlenderGetAbsOrigin(i2, flBuffer);
					if (GetVectorDistance(flBuffer, tempPos) < GetProfileFloat(sProfile, "teleport_dist_from_other_copies", 800.0))
					{
						bTooClose = true;
						//PrintToChatAll("Too close from a copie.");
						break;
					}
				}
			}
			
			if (bTooClose) continue;
			
			// Check from top to bottom of me.
			
			bool bCheckBlink = bool:GetProfileNum(sProfile, "teleport_use_blink");
			
			// Check if my copy master or my fellow copies could see this position.
			bool bDontAddPosition = false;
			int iCopyMaster = NPCGetFromUniqueID(g_iSlenderCopyMaster[iBossIndex]);
			
			float flCopyCheckPositions[6];
			for (int i2 = 0; i2 < 3; i2++) flCopyCheckPositions[i2] = tempPos[i2];
			for (int i2 = 3; i2 < 6; i2++) flCopyCheckPositions[i2] = tempPos[i2 - 3] + g_flSlenderEyePosOffset[iBossIndex][i2 - 3];
			
			for (int i2 = 0; i2 < 2; i2++)
			{
				float flCopyCheckPos[3];
				for (int i3 = 0; i3 < 3; i3++) flCopyCheckPos[i3] = flCopyCheckPositions[i3 + (3 * i2)];
				
				// Check the conditions first.
				if (bVisiblePls)
				{
					if (!IsPointVisibleToAPlayer(flCopyCheckPos, _, bCheckBlink) &&
						!IsPointVisibleToPlayer(iBestPlayer, flCopyCheckPos, _, bCheckBlink))
					{
						//PrintToChatAll("This point is visible to a player.");
						bDontAddPosition = true;
						break;
					}
				}
				else if (bBeCreepy)
				{
					if (!IsPointVisibleToAPlayer(flCopyCheckPos, _, bCheckBlink) &&
						IsPointVisibleToAPlayer(flCopyCheckPos, false, bCheckBlink) &&
						IsPointVisibleToPlayer(iBestPlayer, flCopyCheckPos, false, bCheckBlink))
					{
						// Do nothing.
					}
					else
					{
						continue;
					}
				}
				else
				{
					if (IsPointVisibleToAPlayer(flCopyCheckPos, _, bCheckBlink))
					{
						bDontAddPosition = true;
						//PrintToChatAll("This point is visible to a player.");
						break;
					}
				}
				
				for (int i3 = 0; i3 < MAX_BOSSES; i3++)
				{
					if (i3 == iBossIndex) continue;
					if (NPCGetUniqueID(i3) == -1) continue;
					
					int iBoss = NPCGetEntIndex(i3);
					if (!iBoss || iBoss == INVALID_ENT_REFERENCE) continue;
					
					if (i3 == iCopyMaster || 
						(iCopyMaster != -1 && NPCGetFromUniqueID(g_iSlenderCopyMaster[i3]) == iCopyMaster))
					{
					}
					else continue;
					float flCopyPos[3];
					SlenderGetEyePosition(i3, flCopyPos);
					hTrace = TR_TraceRayFilterEx(flCopyPos,
						flCopyCheckPos,
						CONTENTS_SOLID | CONTENTS_MOVEABLE | CONTENTS_MIST,
						RayType_EndPoint,
						TraceRayBossVisibility,
						iBoss);	
					bDontAddPosition = !TR_DidHit(hTrace);
					CloseHandle(hTrace);
					
					if (!bDontAddPosition)
					{
						float flCopyMins[3], flCopyMaxs[3];
						GetEntPropVector(iBoss, Prop_Data, "m_vecAbsOrigin", flCopyPos);
						GetEntPropVector(iBoss, Prop_Send, "m_vecMins", flCopyMins);
						GetEntPropVector(iBoss, Prop_Send, "m_vecMaxs", flCopyMaxs);
						
						for (int i4 = 0; i4 < 3; i4++) flCopyPos[i4] += ((flCopyMins[i4] + flCopyMaxs[i4]) / 2.0);
						
						hTrace = TR_TraceRayFilterEx(flCopyPos,
							flCopyCheckPos,
							CONTENTS_SOLID | CONTENTS_MOVEABLE | CONTENTS_MIST,
							RayType_EndPoint,
							TraceRayBossVisibility,
							iBoss);
						
						bDontAddPosition = !TR_DidHit(hTrace);
						CloseHandle(hTrace);
					}
					
					if (bDontAddPosition) break;
				}
				
				if (bDontAddPosition) break;
			}
			
			if (bDontAddPosition) continue;
			
			// Insert the vector into our array. Choose which one, first.
			// We're just using hArray as a variable to store the correct array, not the array itself. All arrays will be closed at the end.
			if (i == 0) hArray = hArrayFar;
			else if (i == 1) hArray = hArrayAverage;
			else if (i == 2) hArray = hArrayClose;
			
			if(hAreaArray!=INVALID_HANDLE)
			{
				bool bFound=false;
				int iTargetAreaIndex2 = NavMesh_GetNearestArea(tempPos);
				for (int i2 = 0, iSize = GetArraySize(hAreaArray); i2 < iSize; i2++)
				{
					int iAreaIndex = GetArrayCell(hAreaArray, i2);
					if(iAreaIndex==iTargetAreaIndex2)
					{
						bFound = true;
						break;
					}
				}
				if(!bFound) continue;
			}
			index = PushArrayCell(hArray, tempPos[0]);
			SetArrayCell(hArray, index, tempPos[1], 1);
			SetArrayCell(hArray, index, tempPos[2], 2);
			//PrintToChatAll("it's a valid point");
		}
	}
	
	int size;
	if ((size = GetArraySize(hArrayClose)) > 0)
	{
		index = GetRandomInt(0, size - 1);
		buffer[0] = view_as<float>(GetArrayCell(hArrayClose, index));
		buffer[1] = view_as<float>(GetArrayCell(hArrayClose, index, 1));
		buffer[2] = view_as<float>(GetArrayCell(hArrayClose, index, 2));
	}
	else if ((size = GetArraySize(hArrayAverage)) > 0)
	{
		index = GetRandomInt(0, size - 1);
		buffer[0] = view_as<float>(GetArrayCell(hArrayAverage, index));
		buffer[1] = view_as<float>(GetArrayCell(hArrayAverage, index, 1));
		buffer[2] = view_as<float>(GetArrayCell(hArrayAverage, index, 2));
	}
	else if ((size = GetArraySize(hArrayFar)) > 0)
	{
		index = GetRandomInt(0, size - 1);
		buffer[0] = view_as<float>(GetArrayCell(hArrayFar, index));
		buffer[1] = view_as<float>(GetArrayCell(hArrayFar, index, 1));
		buffer[2] = view_as<float>(GetArrayCell(hArrayFar, index, 2));
	}
	else
	{
		CloseHandle(hArrayClose);
		CloseHandle(hArrayAverage);
		CloseHandle(hArrayFar);
		
#if defined DEBUG
		if (GetConVarBool(g_cvDebugBosses)) PrintToChatAll("SlenderCalculateNewPlace(%d) failed: no locations available", iBossIndex);
#endif
		
		return false;
	}
	
	CloseHandle(hArrayClose);
	CloseHandle(hArrayAverage);
	CloseHandle(hArrayFar);
	return true;
}*/

bool SlenderMarkAsFake(int iBossIndex)
{
	int iBossFlags = NPCGetFlags(iBossIndex);
	if (iBossFlags & SFF_MARKEDASFAKE) return false;
	
	int slender = NPCGetEntIndex(iBossIndex);
	int iSlenderModel = EntRefToEntIndex(g_iSlenderModel[iBossIndex]);
	g_iSlender[iBossIndex] = INVALID_ENT_REFERENCE;
	g_iSlenderModel[iBossIndex] = INVALID_ENT_REFERENCE;
	
	NPCSetFlags(iBossIndex, iBossFlags | SFF_MARKEDASFAKE);
	
	g_hSlenderFakeTimer[iBossIndex] = CreateTimer(3.0, Timer_SlenderMarkedAsFake, iBossIndex, TIMER_FLAG_NO_MAPCHANGE);
	
	if (slender && slender != INVALID_ENT_REFERENCE)
	{
		CreateTimer(2.0, Timer_KillEntity, EntIndexToEntRef(slender), TIMER_FLAG_NO_MAPCHANGE);
	
		int iFlags = GetEntProp(slender, Prop_Send, "m_usSolidFlags");
		if (!(iFlags & 0x0004)) iFlags |= 0x0004; // 	FSOLID_NOT_SOLID
		if (!(iFlags & 0x0008)) iFlags |= 0x0008; // 	FSOLID_TRIGGER
		SetEntProp(slender, Prop_Send, "m_usSolidFlags", iFlags);
	}
	
	if (iSlenderModel && iSlenderModel != INVALID_ENT_REFERENCE)
	{
		SetVariantFloat(0.0);
		AcceptEntityInput(iSlenderModel, "SetPlaybackRate");
		SetEntityRenderFx(iSlenderModel, RENDERFX_FADE_FAST);
	}
	
	return true;
}

public Action Timer_SlenderMarkedAsFake(Handle timer, any data)
{
	if (timer != g_hSlenderFakeTimer[data]) return;
	
	NPCRemove(data);
}

stock int SpawnSlenderModel(int iBossIndex, const float pos[3])
{
	if (NPCGetUniqueID(iBossIndex) == -1)
	{
		LogError("Could not spawn boss model: boss does not exist!");
		return -1;
	}
	
	int iProfileIndex = NPCGetProfileIndex(iBossIndex);
	
	char buffer[PLATFORM_MAX_PATH], sProfile[SF2_MAX_PROFILE_NAME_LENGTH];
	NPCGetProfile(iBossIndex, sProfile, sizeof(sProfile));
	
	GetProfileString(sProfile, "model", buffer, sizeof(buffer));
	int prop = GetProfileNum(sProfile,"attack_props",0);
	if (!(NPCGetFlags(iBossIndex) & SFF_ATTACKPROPS))
	{
		if(prop==1)
		{
			g_iNPCFlags[iBossIndex] |= SFF_ATTACKPROPS;
			//NPCSetFlags(iBossIndex,g_iNPCFlags[iBossIndex]);
		}
	}
	if (!buffer[0])
	{
		LogError("Could not spawn boss model: model is invalid!");
		return -1;
	}
	float flModelScale = NPCGetModelScale(iBossIndex);
	if (flModelScale <= 0.0)
	{
		LogError("Could not spawn boss model: model scale is less than or equal to 0.0!");
		return -1;
	}
	
	int iSlenderModel = CreateEntityByName("prop_dynamic_override");
	if (iSlenderModel != -1)
	{
		SetEntityModel(iSlenderModel, buffer);
		
		TeleportEntity(iSlenderModel, pos, NULL_VECTOR, NULL_VECTOR);
		DispatchSpawn(iSlenderModel);
		ActivateEntity(iSlenderModel);
		
		SetEntProp(iSlenderModel, Prop_Send, "m_nSkin", GetBossProfileSkin(iProfileIndex));
		SetEntProp(iSlenderModel, Prop_Send, "m_nBody", GetBossProfileBodyGroups(iProfileIndex));
		
		GetProfileString(sProfile, "animation_idle", buffer, sizeof(buffer));
		if (buffer[0])
		{
			SetVariantString(buffer);
			AcceptEntityInput(iSlenderModel, "SetDefaultAnimation");
			SetVariantString(buffer);
			AcceptEntityInput(iSlenderModel, "SetAnimation");
			AcceptEntityInput(iSlenderModel, "DisableCollision");
		}
		
		SetVariantFloat(GetProfileFloat(sProfile, "animation_idle_playbackrate", 1.0));
		AcceptEntityInput(iSlenderModel, "SetPlaybackRate");
		
		SetEntPropFloat(iSlenderModel, Prop_Send, "m_flModelScale", flModelScale);
		
		// Create special effects.
		SetEntityRenderMode(iSlenderModel, view_as<RenderMode>(GetProfileNum(sProfile, "effect_rendermode", view_as<int>(RENDER_NORMAL))));
		SetEntityRenderFx(iSlenderModel, view_as<RenderFx>(GetProfileNum(sProfile, "effect_renderfx", view_as<int>(RENDERFX_NONE))));
		
		int iColor[4];
		GetProfileColor(sProfile, "effect_rendercolor", iColor[0], iColor[1], iColor[2], iColor[3]);
		SetEntityRenderColor(iSlenderModel, iColor[0], iColor[1], iColor[2], iColor[3]);
		
		KvRewind(g_hConfig);
		/*if (KvJumpToKey(g_hConfig, sProfile) && 
			KvJumpToKey(g_hConfig, "effects") &&
			KvGotoFirstSubKey(g_hConfig))
		{
			do
			{
				
			}
			while KvGotoNextKey(g_hConfig);
		}*/
		//Beginning of the code for boss's glow
		/*int iEntFlags = GetEntityFlags( iEntity );
		if(iEntFlags & FL_EDICT_ALWAYS)
			SetEntityFlags( iEntity, iEntFlags&~FL_EDICT_ALWAYS );*/
	}
	
	return iSlenderModel;
}

stock bool PlayerCanSeeSlender(int client,int iBossIndex, bool bCheckFOV=true, bool bCheckBlink=false, bool bCheckEliminated=true)
{
	return IsNPCVisibleToPlayer(iBossIndex, client, bCheckFOV, bCheckBlink, bCheckEliminated);
}

stock bool PeopleCanSeeSlender(int iBossIndex, bool bCheckFOV=true, bool bCheckBlink=false)
{
	return IsNPCVisibleToAPlayer(iBossIndex, bCheckFOV, bCheckBlink);
}

// TODO: bCheckBlink and bCheckEliminated should NOT be function arguments!
bool IsNPCVisibleToPlayer(int iNPCIndex,int client, bool bCheckFOV=true, bool bCheckBlink=false, bool bCheckEliminated=true)
{
	if (!NPCIsValid(iNPCIndex)) return false;
	
	int iNPC = NPCGetEntIndex(iNPCIndex);
	if (iNPC && iNPC != INVALID_ENT_REFERENCE)
	{
		float flEyePos[3];
		NPCGetEyePosition(iNPCIndex, flEyePos);
		return IsPointVisibleToPlayer(client, flEyePos, bCheckFOV, bCheckBlink, bCheckEliminated);
	}
	
	return false;
}

// TODO: bCheckBlink and bCheckEliminated should NOT be function arguments!
bool IsNPCVisibleToAPlayer(int iNPCIndex, bool bCheckFOV=true, bool bCheckBlink=false, bool bCheckEliminated=true)
{
	for (int client = 1; client <= MaxClients; client++)
	{
		if (IsNPCVisibleToPlayer(iNPCIndex, client, bCheckFOV, bCheckBlink, bCheckEliminated))
		{
			return true;
		}
	}
	
	return false;
}

float NPCGetDistanceFromPoint(int iNPCIndex, const float flPoint[3], bool bSquared=false)
{
	int iNPC = NPCGetEntIndex(iNPCIndex);
	if (iNPC && iNPC != INVALID_ENT_REFERENCE)
	{
		float flPos[3];
		SlenderGetAbsOrigin(iNPCIndex, flPos);
		
		return GetVectorDistance(flPos, flPoint, bSquared);
	}
	
	return -1.0;
}

float NPCGetDistanceFromEntity(int iNPCIndex,int ent, bool bSquared=false)
{
	if (!IsValidEntity(ent)) return -1.0;
	
	float flPos[3];
	GetEntPropVector(ent, Prop_Data, "m_vecAbsOrigin", flPos);
	
	return NPCGetDistanceFromPoint(iNPCIndex, flPos, bSquared);
}

public bool TraceRayBossVisibility(int entity,int mask, any data)
{
	if (entity == data || IsValidClient(entity)) return false;
	
	int iBossIndex = NPCGetFromEntIndex(entity);
	if (entity <= MAX_BOSSES) return false;
	if (iBossIndex != -1) return false;
	
	if (IsValidEdict(entity))
	{
		char sClass[64];
		GetEntityNetClass(entity, sClass, sizeof(sClass));
		
		if (StrEqual(sClass, "CTFAmmoPack")) return false;
		if (StrEqual(sClass, "CTFBaseBoss")) return false;
	}
	
	return true;
}

public bool TraceRayDontHitCharacters(int entity,int mask, any data)
{
	if (entity > 0 && entity <= MaxClients) return false;
	
	int iBossIndex = NPCGetFromEntIndex(entity);
	if (iBossIndex != -1) return false;
	if (IsValidEdict(entity))
	{
		char sClass[64];
		GetEntityNetClass(entity, sClass, sizeof(sClass));
		if (StrEqual(sClass, "CTFBaseBoss")) return false;
	}
	
	return true;
}

public bool TraceRayDontHitCharactersOrEntity(int entity,int mask, any data)
{
	if (entity == data) return false;

	if (entity > 0 && entity <= MaxClients) return false;
	int iBossIndex = NPCGetFromEntIndex(entity);
	if (iBossIndex != -1) return false;
	if (IsValidEdict(entity))
	{
		char sClass[64];
		GetEntityNetClass(entity, sClass, sizeof(sClass));
		if (StrEqual(sClass, "CTFBaseBoss")) return false;
	}
	
	return true;
}
stock bool SpawnProxy(int client,int iBossIndex,float flTeleportPos[3])
{
	if (iBossIndex == -1) return false;
	char sProfile[SF2_MAX_PROFILE_NAME_LENGTH];
	NPCGetProfile(iBossIndex, sProfile, sizeof(sProfile));
	
	if (!g_bRoundGrace)
	{	
		int iTeleportTarget = EntRefToEntIndex(g_iSlenderTeleportTarget[iBossIndex]);
		int iTeleportAreaIndex = -1;
		if (!iTeleportTarget || iTeleportTarget == INVALID_ENT_REFERENCE)
			return false;
		else
		{
			float flTeleportMinRange = CalculateTeleportMinRange(iBossIndex, GetProfileFloat(sProfile,"proxies_teleport_range_min",500.0), GetProfileFloat(sProfile,"proxies_teleport_range_min",3200.0));
		
			// Search surrounding nav areas around target.
			if (NavMesh_Exists())
			{
				float flTargetPos[3];
				GetClientAbsOrigin(iTeleportTarget, flTargetPos);
				
				int iTargetAreaIndex = NavMesh_GetNearestArea(flTargetPos);
				if (iTargetAreaIndex != -1)
				{
					
					// Search outwards until travel distance is at maximum range.
					Handle hAreaArray = CreateArray(2);
					Handle hAreas = CreateStack();
					NavMesh_CollectSurroundingAreas(hAreas, iTargetAreaIndex, g_flSlenderTeleportMaxRange[iBossIndex]);
					{
						int iPoppedAreas;
						
						while (!IsStackEmpty(hAreas))
						{
							int iAreaIndex = -1;
							PopStackCell(hAreas, iAreaIndex);
							
							// Check flags.
							if (NavMeshArea_GetFlags(iAreaIndex) & NAV_MESH_NO_HOSTAGES)
							{
								// Don't spawn/teleport at areas marked with the "NO HOSTAGES" flag.
								continue;
							}
							
							int iIndex = PushArrayCell(hAreaArray, iAreaIndex);
							SetArrayCell(hAreaArray, iIndex, float(NavMeshArea_GetCostSoFar(iAreaIndex)), 1);
							iPoppedAreas++;
						}
#if defined DEBUG
						SendDebugMessageToPlayers(DEBUG_BOSS_TELEPORTATION, 0, "Teleport for boss %d: collected %d areas", iBossIndex, iPoppedAreas);
#endif
						
						CloseHandle(hAreas);
					}
					
					Handle hAreaArrayClose = CreateArray(4);
					Handle hAreaArrayAverage = CreateArray(4);
					Handle hAreaArrayFar = CreateArray(4);
					
					for (int i = 1; i <= 3; i++)
					{
						float flRangeSectionMin = flTeleportMinRange + (GetProfileFloat(sProfile,"proxies_teleport_range_max",3200.0) - flTeleportMinRange) * (float(i - 1) / 3.0);
						float flRangeSectionMax = flTeleportMinRange + (GetProfileFloat(sProfile,"proxies_teleport_range_max",3200.0) - flTeleportMinRange) * (float(i) / 3.0);
						
						for (int i2 = 0, iSize = GetArraySize(hAreaArray); i2 < iSize; i2++)
						{
							int iAreaIndex = GetArrayCell(hAreaArray, i2);
							
							float flAreaSpawnPoint[3];
							NavMeshArea_GetCenter(iAreaIndex, flAreaSpawnPoint);
							
							int iBoss = NPCGetEntIndex(iBossIndex);
						
							// Check space. First raise to HalfHumanHeight * 2, then trace downwards to get ground level.
							float flTraceStartPos[3];
							flTraceStartPos[0] = flAreaSpawnPoint[0];
							flTraceStartPos[1] = flAreaSpawnPoint[1];
							flTraceStartPos[2] = flAreaSpawnPoint[2] + (HalfHumanHeight * 2.0);
						
							float flTraceMins[3];
							flTraceMins[0] = HULL_TF2PLAYER_MINS[0];
							flTraceMins[1] = HULL_TF2PLAYER_MINS[1];
							flTraceMins[2] = 0.0;
						
							
							float flTraceMaxs[3];
							flTraceMaxs[0] = HULL_TF2PLAYER_MAXS[0];
							flTraceMaxs[1] = HULL_TF2PLAYER_MAXS[1];
							flTraceMaxs[2] = 0.0;
							
							Handle hTrace = TR_TraceHullFilterEx(flTraceStartPos,
							flAreaSpawnPoint,
							flTraceMins,
							flTraceMaxs,
							MASK_NPCSOLID,
							TraceRayDontHitEntity,
							iBoss);
							
							float flTraceHitPos[3];
							TR_GetEndPosition(flTraceHitPos, hTrace);
							flTraceHitPos[2] += 1.0;
							CloseHandle(hTrace);
							
							if (TR_PointOutsideWorld(flTraceHitPos))
							{
								continue;
							}
							if(IsSpaceOccupiedPlayer(flTraceHitPos, HULL_TF2PLAYER_MINS, HULL_TF2PLAYER_MAXS, client))
							{
								flTraceHitPos[2] +=5.0;
								if(IsSpaceOccupiedPlayer(flTraceHitPos, HULL_TF2PLAYER_MINS, HULL_TF2PLAYER_MAXS, client))
									continue;
							}
							if (IsSpaceOccupiedNPC(flTraceHitPos,
							HULL_TF2PLAYER_MINS,
							HULL_TF2PLAYER_MAXS,
							iBoss))
							{
								continue;
							}
						
							flAreaSpawnPoint[0] = flTraceHitPos[0];
							flAreaSpawnPoint[1] = flTraceHitPos[1];
							flAreaSpawnPoint[2] = flTraceHitPos[2];
							// Check visibility.
							if (IsPointVisibleToAPlayer(flAreaSpawnPoint, false, false)) continue;
							
							bool bTooNear = false;
							
							// Check minimum range with players.
							for (int iClient = 1; iClient <= MaxClients; iClient++)
							{
								if (!IsClientInGame(iClient) ||
									!IsPlayerAlive(iClient) ||
									g_bPlayerEliminated[iClient] ||
									IsClientInGhostMode(iClient) || 
									DidClientEscape(iClient))
								{
									continue;
								}
								
								float flTempPos[3];
								GetClientAbsOrigin(iClient, flTempPos);
								
								if (GetVectorDistance(flAreaSpawnPoint, flTempPos) <=  GetProfileFloat(sProfile,"proxies_teleport_range_min",500.0))
								{
									bTooNear = true;
									break;
								}
							}
							
							if (bTooNear) continue;	// This area is not compatible.
							
							// Check travel distance and put in the appropriate arrays.
							float flDist = view_as<float>(GetArrayCell(hAreaArray, i2, 1));
							if (flDist > flRangeSectionMin && flDist < flRangeSectionMax)
							{
								int iIndex = -1;
								Handle hTargetAreaArray = INVALID_HANDLE;
								
								switch (i)
								{
									case 1: 
									{
										iIndex = PushArrayCell(hAreaArrayClose, iAreaIndex);
										hTargetAreaArray = hAreaArrayClose;
									}
									case 2: 
									{
										iIndex = PushArrayCell(hAreaArrayAverage, iAreaIndex);
										hTargetAreaArray = hAreaArrayAverage;
									}
									case 3: 
									{
										iIndex = PushArrayCell(hAreaArrayFar, iAreaIndex);
										hTargetAreaArray = hAreaArrayFar;
									}
								}
								
								if (hTargetAreaArray != INVALID_HANDLE && iIndex != -1)
								{
									SetArrayCell(hTargetAreaArray, iIndex, flAreaSpawnPoint[0], 1);
									SetArrayCell(hTargetAreaArray, iIndex, flAreaSpawnPoint[1], 2);
									SetArrayCell(hTargetAreaArray, iIndex, flAreaSpawnPoint[2], 3);
								}
							}
						}
					}
			
					CloseHandle(hAreaArray);
				
					int iArrayIndex = -1;
				
					if (GetArraySize(hAreaArrayClose))
					{
						iArrayIndex = GetRandomInt(0, GetArraySize(hAreaArrayClose) - 1);
						iTeleportAreaIndex = GetArrayCell(hAreaArrayClose, iArrayIndex);
						flTeleportPos[0] = view_as<float>(GetArrayCell(hAreaArrayClose, iArrayIndex, 1));
						flTeleportPos[1] = view_as<float>(GetArrayCell(hAreaArrayClose, iArrayIndex, 2));
						flTeleportPos[2] = view_as<float>(GetArrayCell(hAreaArrayClose, iArrayIndex, 3));
					}
					else if (GetArraySize(hAreaArrayAverage))
					{
						iArrayIndex = GetRandomInt(0, GetArraySize(hAreaArrayAverage) - 1);
						iTeleportAreaIndex = GetArrayCell(hAreaArrayAverage, iArrayIndex);
						flTeleportPos[0] = view_as<float>(GetArrayCell(hAreaArrayAverage, iArrayIndex, 1));
						flTeleportPos[1] = view_as<float>(GetArrayCell(hAreaArrayAverage, iArrayIndex, 2));
						flTeleportPos[2] = view_as<float>(GetArrayCell(hAreaArrayAverage, iArrayIndex, 3));
					}
					else if (GetArraySize(hAreaArrayFar))
					{
						iArrayIndex = GetRandomInt(0, GetArraySize(hAreaArrayFar) - 1);
						iTeleportAreaIndex = GetArrayCell(hAreaArrayFar, iArrayIndex);
						flTeleportPos[0] = view_as<float>(GetArrayCell(hAreaArrayFar, iArrayIndex, 1));
						flTeleportPos[1] = view_as<float>(GetArrayCell(hAreaArrayFar, iArrayIndex, 2));
						flTeleportPos[2] = view_as<float>(GetArrayCell(hAreaArrayFar, iArrayIndex, 3));
					}
					CloseHandle(hAreaArrayClose);
					CloseHandle(hAreaArrayAverage);
					CloseHandle(hAreaArrayFar);
				}
			}
		}
		if(iTeleportAreaIndex == -1)
		{
			return false;
		}
	}
	return true;
}
#include "sf2/npc/npc_chaser.sp"