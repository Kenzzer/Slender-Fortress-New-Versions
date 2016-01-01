#if defined _sf2_pvp_included
 #endinput
#endif
#define _sf2_pvp_included


#define SF2_PVP_SPAWN_SOUND "items/spawn_item.wav"

new Handle:g_cvPvPArenaLeaveTime;
new Handle:g_cvPvPArenaPlayerCollisions;

static const String:g_sPvPProjectileClasses[][] = 
{
	"tf_projectile_rocket", 
	"tf_projectile_sentryrocket", 
	"tf_projectile_arrow", 
	"tf_projectile_stun_ball",
	"tf_projectile_ball_ornament",
	"tf_projectile_cleaver",
	"tf_projectile_energy_ball",
	"tf_projectile_energy_ring",
	"tf_projectile_flare",
	"tf_projectile_healing_bolt",
	"tf_projectile_jar",
	"tf_projectile_jar_milk",
	"tf_projectile_pipe",
	"tf_projectile_pipe_remote",
	"tf_projectile_syringe"
};

static bool:g_bPlayerInPvP[MAXPLAYERS + 1];
static Handle:g_hPlayerPvPTimer[MAXPLAYERS + 1];
static Handle:g_hPlayerPvPRespawnTimer[MAXPLAYERS + 1];
static g_iPlayerPvPTimerCount[MAXPLAYERS + 1];
static bool:g_bPlayerInPvPTrigger[MAXPLAYERS + 1];

static Handle:g_hPvPFlameEntities;

enum
{
	PvPFlameEntData_EntRef = 0,
	PvPFlameEntData_LastHitEntRef,
	PvPFlameEntData_MaxStats
};

public PvP_Initialize()
{
	g_cvPvPArenaLeaveTime = CreateConVar("sf2_player_pvparena_leavetime", "3");
	g_cvPvPArenaPlayerCollisions = CreateConVar("sf2_player_pvparena_collisions", "1");
	
	g_hPvPFlameEntities = CreateArray(PvPFlameEntData_MaxStats);
}

public PvP_SetupMenus()
{
	g_hMenuSettingsPvP = CreateMenu(Menu_SettingsPvP);
	SetMenuTitle(g_hMenuSettingsPvP, "%t%t\n \n", "SF2 Prefix", "SF2 Settings PvP Menu Title");
	AddMenuItem(g_hMenuSettingsPvP, "0", "Toggle automatic spawning");
	SetMenuExitBackButton(g_hMenuSettingsPvP, true);
}

public PvP_OnMapStart()
{
	ClearArray(g_hPvPFlameEntities);
}

public PvP_Precache()
{
	PrecacheSound2(SF2_PVP_SPAWN_SOUND);
}

public PvP_OnClientPutInServer(client)
{
	PvP_ForceResetPlayerPvPData(client);
}

public PvP_OnClientDisconnect(client)
{
	PvP_SetPlayerPvPState(client, false, false, false);
}

public PvP_OnGameFrame()
{
	// Process through PvP projectiles.
	for (new i = 0; i < sizeof(g_sPvPProjectileClasses); i++)
	{
		new ent = -1;
		while ((ent = FindEntityByClassname(ent, g_sPvPProjectileClasses[i])) != -1)
		{
			new iThrowerOffset = FindDataMapOffs(ent, "m_hThrower");
			new bool:bChangeProjectileTeam = false;
			
			new iOwnerEntity = GetEntPropEnt(ent, Prop_Data, "m_hOwnerEntity");
			if (IsValidClient(iOwnerEntity) && IsClientInPvP(iOwnerEntity) && GetClientTeam(iOwnerEntity) != _:TFTeam_Red)
			{
				bChangeProjectileTeam = true;
			}
			else if (iThrowerOffset != -1)
			{
				iOwnerEntity = GetEntDataEnt2(ent, iThrowerOffset);
				if (IsValidClient(iOwnerEntity) && IsClientInPvP(iOwnerEntity) && GetClientTeam(iOwnerEntity) != _:TFTeam_Red)
				{
					bChangeProjectileTeam = true;
				}
			}
			
			if (bChangeProjectileTeam)
			{
				SetEntProp(ent, Prop_Data, "m_iInitialTeamNum", 0);
				SetEntProp(ent, Prop_Send, "m_iTeamNum", 0);
			}
		}
	}

	// Process through PvP flame entities.
	{
		static Float:flMins[3] = { -6.0, ... };
		static Float:flMaxs[3] = { 6.0, ... };
		
		decl Float:flOrigin[3];
		
		new Handle:hTrace = INVALID_HANDLE;
		new ent = -1;
		new iOwnerEntity = INVALID_ENT_REFERENCE; 
		new iHitEntity = INVALID_ENT_REFERENCE;
		
		while ((ent = FindEntityByClassname(ent, "tf_flame")) != -1)
		{
			iOwnerEntity = GetEntPropEnt(ent, Prop_Data, "m_hOwnerEntity");
			
			if (IsValidEdict(iOwnerEntity))
			{
				// tf_flame's initial owner SHOULD be the flamethrower that it originates from.
				// If not, then something's completely bogus.
				
				iOwnerEntity = GetEntPropEnt(iOwnerEntity, Prop_Data, "m_hOwnerEntity");
			}
			
			if (IsValidClient(iOwnerEntity) && (IsRoundInWarmup() || IsClientInPvP(iOwnerEntity)))
			{
				GetEntPropVector(ent, Prop_Data, "m_vecAbsOrigin", flOrigin);
				
				hTrace = TR_TraceHullFilterEx(flOrigin, flOrigin, flMins, flMaxs, MASK_PLAYERSOLID, TraceRayDontHitEntity, iOwnerEntity);
				iHitEntity = TR_GetEntityIndex(hTrace);
				CloseHandle(hTrace);
				
				if (IsValidEntity(iHitEntity))
				{
					new entref = EntIndexToEntRef(ent);
					
					new iIndex = FindValueInArray(g_hPvPFlameEntities, entref);
					if (iIndex != -1)
					{
						new iLastHitEnt = EntRefToEntIndex(GetArrayCell(g_hPvPFlameEntities, iIndex, PvPFlameEntData_LastHitEntRef));
					
						if (iHitEntity != iLastHitEnt)
						{
							SetArrayCell(g_hPvPFlameEntities, iIndex, EntIndexToEntRef(iHitEntity), PvPFlameEntData_LastHitEntRef);
							PvP_OnFlameEntityStartTouchPost(ent, iHitEntity);
						}
					}
				}
			}
		}
	}
}

public PvP_OnEntityCreated(ent, const String:sClassname[])
{
	if (StrEqual(sClassname, "tf_flame", false))
	{
		new iIndex = PushArrayCell(g_hPvPFlameEntities, EntIndexToEntRef(ent));
		if (iIndex != -1)
		{
			SetArrayCell(g_hPvPFlameEntities, iIndex, INVALID_ENT_REFERENCE, PvPFlameEntData_LastHitEntRef);
		}
	}
	else
	{
		for (new i = 0; i < sizeof(g_sPvPProjectileClasses); i++)
		{
			if (StrEqual(sClassname, g_sPvPProjectileClasses[i], false))
			{
				SDKHook(ent, SDKHook_Spawn, Hook_PvPProjectileSpawn);
				SDKHook(ent, SDKHook_SpawnPost, Hook_PvPProjectileSpawnPost);
				break;
			}
		}
	}
}

public PvP_OnEntityDestroyed(ent, const String:sClassname[])
{
	if (StrEqual(sClassname, "tf_flame", false))
	{
		new entref = EntIndexToEntRef(ent);
		new iIndex = FindValueInArray(g_hPvPFlameEntities, entref);
		if (iIndex != -1)
		{
			RemoveFromArray(g_hPvPFlameEntities, iIndex);
		}
	}
}

public Action:Hook_PvPProjectileSpawn(ent)
{
	decl String:sClass[64];
	GetEntityClassname(ent, sClass, sizeof(sClass));
	
	new iThrowerOffset = FindDataMapOffs(ent, "m_hThrower");
	new iOwnerEntity = GetEntPropEnt(ent, Prop_Data, "m_hOwnerEntity");
	
	if (iOwnerEntity == -1 && iThrowerOffset != -1)
	{
		iOwnerEntity = GetEntDataEnt2(ent, iThrowerOffset);
	}
	
	if (IsValidClient(iOwnerEntity))
	{
		if (IsClientInPvP(iOwnerEntity))
		{
			SetEntProp(ent, Prop_Data, "m_iInitialTeamNum", 0);
			SetEntProp(ent, Prop_Send, "m_iTeamNum", 0);
		}
	}

	return Plugin_Continue;
}

public Hook_PvPProjectileSpawnPost(ent)
{
	decl String:sClass[64];
	GetEntityClassname(ent, sClass, sizeof(sClass));
	
	new iThrowerOffset = FindDataMapOffs(ent, "m_hThrower");
	new iOwnerEntity = GetEntPropEnt(ent, Prop_Data, "m_hOwnerEntity");
	
	if (iOwnerEntity == -1 && iThrowerOffset != -1)
	{
		iOwnerEntity = GetEntDataEnt2(ent, iThrowerOffset);
	}
	
	if (IsValidClient(iOwnerEntity))
	{
		if (IsClientInPvP(iOwnerEntity))
		{
			SetEntProp(ent, Prop_Data, "m_iInitialTeamNum", 0);
			SetEntProp(ent, Prop_Send, "m_iTeamNum", 0);
		}
	}
}

public PvP_OnPlayerSpawn(client)
{
	PvP_SetPlayerPvPState(client, false, false, false);

	if (IsPlayerAlive(client) && IsClientParticipating(client))
	{
		if (!IsClientInGhostMode(client) && !g_bPlayerProxy[client])
		{
			if (g_bPlayerEliminated[client] || g_bPlayerEscaped[client])
			{
				new bool:bAutoSpawn = g_iPlayerPreferences[client][PlayerPreference_PvPAutoSpawn];
				
				if (bAutoSpawn)
				{
					g_hPlayerPvPRespawnTimer[client] = CreateTimer(0.12, Timer_TeleportPlayerToPvP, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
				}
			}
			else
			{
				g_hPlayerPvPRespawnTimer[client] = INVALID_HANDLE;
			}
		}
	}
}

public PvP_OnPlayerDeath(client, bool:bFake)
{
	if (!bFake)
	{
		if (!IsClientInGhostMode(client) && !g_bPlayerProxy[client])
		{
			new bool:bAutoSpawn = g_iPlayerPreferences[client][PlayerPreference_PvPAutoSpawn];
			
			if (bAutoSpawn)
			{
				if (g_bPlayerEliminated[client] || g_bPlayerEscaped[client])
				{
					if (!IsRoundEnding())
					{
						g_hPlayerPvPRespawnTimer[client] = CreateTimer(0.3, Timer_RespawnPlayer, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
					}
				}
			}
		}
	}
}

public PvP_OnClientGhostModeEnable(client)
{
	g_hPlayerPvPRespawnTimer[client] = INVALID_HANDLE;
}

public PvP_OnClientPutInPlay(client)
{
	g_hPlayerPvPRespawnTimer[client] = INVALID_HANDLE;
}

public bool:Hook_ClientPvPShouldCollide(ent, collisiongroup, contentsmask, bool:originalResult)
{
	if (!g_bEnabled) return originalResult;
	return true;
}

public PvP_OnTriggerStartTouch(trigger, other)
{
	decl String:sName[64];
	GetEntPropString(trigger, Prop_Data, "m_iName", sName, sizeof(sName));
	
	if (StrContains(sName, "sf2_pvp_trigger", false) == 0)
	{
		if (IsValidClient(other) && IsPlayerAlive(other))
		{
			g_bPlayerInPvPTrigger[other] = true;
			
			if (IsClientInPvP(other))
			{
				// Player left and came back again, but is still in PvP mode.
				g_iPlayerPvPTimerCount[other] = 0;
				g_hPlayerPvPTimer[other] = INVALID_HANDLE;
			}
			else
			{
				PvP_SetPlayerPvPState(other, true);
			}
		}
	}
}

public PvP_OnTriggerEndTouch(trigger, other)
{
	decl String:sName[64];
	GetEntPropString(trigger, Prop_Data, "m_iName", sName, sizeof(sName));
	
	if (StrContains(sName, "sf2_pvp_trigger", false) == 0)
	{
		if (IsValidClient(other))
		{
			g_bPlayerInPvPTrigger[other] = false;
			
			if (IsClientInPvP(other))
			{
				g_iPlayerPvPTimerCount[other] = GetConVarInt(g_cvPvPArenaLeaveTime);
				g_hPlayerPvPTimer[other] = CreateTimer(1.0, Timer_PlayerPvPLeaveCountdown, GetClientUserId(other), TIMER_FLAG_NO_MAPCHANGE | TIMER_REPEAT);
			}
		}
	}
}

/**
 *	Enables/Disables PvP mode on the player.
 */
PvP_SetPlayerPvPState(client, bool:bStatus, bool:bRemoveProjectiles=true, bool:bRegenerate=true)
{
	if (!IsValidClient(client)) return;
	
	new bool:bOldInPvP = g_bPlayerInPvP[client];
	if (bStatus == bOldInPvP) return; // no change
	
	g_bPlayerInPvP[client] = bStatus;
	g_hPlayerPvPTimer[client] = INVALID_HANDLE;
	g_hPlayerPvPRespawnTimer[client] = INVALID_HANDLE;
	g_iPlayerPvPTimerCount[client] = 0;
	
	if (bRemoveProjectiles)
	{
		// Remove previous projectiles.
		PvP_RemovePlayerProjectiles(client);
	}
	
	if (bRegenerate)
	{
		// Regenerate player but keep health the same.
		new iHealth = GetEntProp(client, Prop_Send, "m_iHealth");
		TF2_RegeneratePlayer(client);
		SetEntProp(client, Prop_Data, "m_iHealth", iHealth);
		SetEntProp(client, Prop_Send, "m_iHealth", iHealth);
	}
	
	if (bStatus && GetConVarBool(g_cvPvPArenaPlayerCollisions))
	{
		SDKHook(client, SDKHook_ShouldCollide, Hook_ClientPvPShouldCollide);
	}
	else
	{
		SDKUnhook(client, SDKHook_ShouldCollide, Hook_ClientPvPShouldCollide);
	}
}

static PvP_OnFlameEntityStartTouchPost(flame, other)
{
	if (IsValidClient(other))
	{
		if ((IsRoundInWarmup() || IsClientInPvP(other)) && !IsRoundEnding())
		{
			new iFlamethrower = GetEntPropEnt(flame, Prop_Data, "m_hOwnerEntity");
			if (IsValidEdict(iFlamethrower))
			{
				new iOwnerEntity = GetEntPropEnt(iFlamethrower, Prop_Data, "m_hOwnerEntity");
				if (iOwnerEntity != other && IsValidClient(iOwnerEntity))
				{
					if (IsRoundInWarmup() || IsClientInPvP(iOwnerEntity))
					{
						if (GetClientTeam(other) == GetClientTeam(iOwnerEntity) && GetClientTeam(iOwnerEntity) != _:TFTeam_Red)
						{
							TF2_IgnitePlayer(other, iOwnerEntity);
							SDKHooks_TakeDamage(other, iOwnerEntity, iOwnerEntity, 7.0, IsClientCritBoosted(iOwnerEntity) ? (DMG_BURN | DMG_PREVENT_PHYSICS_FORCE | DMG_ACID) : DMG_BURN | DMG_PREVENT_PHYSICS_FORCE); 
						}
					}
				}
			}
		}
	}
}

/**
 *	Forcibly resets global vars of the player relating to PvP. Ignores checking.
 */
PvP_ForceResetPlayerPvPData(client)
{
	g_bPlayerInPvP[client] = false;
	g_hPlayerPvPTimer[client] = INVALID_HANDLE;
	g_iPlayerPvPTimerCount[client] = 0;
	g_hPlayerPvPRespawnTimer[client] = INVALID_HANDLE;
}

static PvP_RemovePlayerProjectiles(client)
{
	for (new i = 0; i < sizeof(g_sPvPProjectileClasses); i++)
	{
		new ent = -1;
		while ((ent = FindEntityByClassname(ent, g_sPvPProjectileClasses[i])) != -1)
		{
			new iThrowerOffset = FindDataMapOffs(ent, "m_hThrower");
			new bool:bMine = false;
		
			new iOwnerEntity = GetEntPropEnt(ent, Prop_Data, "m_hOwnerEntity");
			if (iOwnerEntity == client)
			{
				bMine = true;
			}
			else if (iThrowerOffset != -1)
			{
				iOwnerEntity = GetEntDataEnt2(ent, iThrowerOffset);
				if (iOwnerEntity == client)
				{
					bMine = true;
				}
			}
			
			if (bMine) AcceptEntityInput(ent, "Kill");
		}
	}
}

public Action:Timer_TeleportPlayerToPvP(Handle:timer, any:userid)
{
	new client = GetClientOfUserId(userid);
	if (client <= 0) return;
	
	if (timer != g_hPlayerPvPRespawnTimer[client]) return;
	g_hPlayerPvPRespawnTimer[client] = INVALID_HANDLE;
	
	new Handle:hSpawnPointList = CreateArray();
	
	new ent = -1;
	while ((ent = FindEntityByClassname(ent, "info_target")) != -1)
	{
		decl String:sName[32];
		GetEntPropString(ent, Prop_Data, "m_iName", sName, sizeof(sName));
		if (!StrContains(sName, "sf2_pvp_spawnpoint", false))
		{
			PushArrayCell(hSpawnPointList, ent);
		}
	}
	
	decl Float:flMins[3], Float:flMaxs[3];
	GetEntPropVector(client, Prop_Send, "m_vecMins", flMins);
	GetEntPropVector(client, Prop_Send, "m_vecMaxs", flMaxs);
	
	new Handle:hClearSpawnPointList = CloneArray(hSpawnPointList);
	for (new i = 0; i < GetArraySize(hSpawnPointList); i++)
	{
		new iEnt = GetArrayCell(hSpawnPointList, i);
		
		decl Float:flMyPos[3];
		GetEntPropVector(iEnt, Prop_Data, "m_vecAbsOrigin", flMyPos);
		
		if (IsSpaceOccupiedPlayer(flMyPos, flMins, flMaxs, client))
		{
			new iIndex = FindValueInArray(hClearSpawnPointList, iEnt);
			if (iIndex != -1)
			{
				RemoveFromArray(hClearSpawnPointList, iIndex);
			}
		}
	}
	
	new iNum;
	if ((iNum = GetArraySize(hClearSpawnPointList)) > 0)
	{
		ent = GetArrayCell(hClearSpawnPointList, GetRandomInt(0, iNum - 1));
	}
	else if ((iNum = GetArraySize(hSpawnPointList)) > 0)
	{
		ent = GetArrayCell(hSpawnPointList, GetRandomInt(0, iNum - 1));
	}
	
	if (iNum > 0)
	{
		decl Float:flPos[3], Float:flAng[3];
		GetEntPropVector(ent, Prop_Data, "m_vecAbsOrigin", flPos);
		GetEntPropVector(ent, Prop_Data, "m_angAbsRotation", flAng);
		TeleportEntity(client, flPos, flAng, Float:{ 0.0, 0.0, 0.0 });
		
		EmitAmbientSound(SF2_PVP_SPAWN_SOUND, flPos, _, SNDLEVEL_NORMAL, _, 1.0);
	}
	
	CloseHandle(hSpawnPointList);
	CloseHandle(hClearSpawnPointList);
}

public Action:Timer_PlayerPvPLeaveCountdown(Handle:timer, any:userid)
{
	new client = GetClientOfUserId(userid);
	if (client <= 0) return Plugin_Stop;
	
	if (timer != g_hPlayerPvPTimer[client]) return Plugin_Stop;
	
	if (!IsClientInPvP(client)) return Plugin_Stop;
	
	if (g_iPlayerPvPTimerCount[client] <= 0)
	{
		PvP_SetPlayerPvPState(client, false);
		return Plugin_Stop;
	}
	
	g_iPlayerPvPTimerCount[client]--;
	
	//if (!g_bPlayerProxyAvailableInForce[client])
	{
		SetHudTextParams(-1.0, 0.75, 
			1.0,
			255, 255, 255, 255,
			_,
			_,
			0.25, 1.25);
		
		ShowSyncHudText(client, g_hHudSync, "%T", "SF2 Exiting PvP Arena", client, g_iPlayerPvPTimerCount[client]);
	}
	
	return Plugin_Continue;
}
bool:IsClientInPvP(client)
{
	return g_bPlayerInPvP[client];
}


// API

public PvP_InitializeAPI()
{
	CreateNative("SF2_IsClientInPvP", Native_IsClientInPvP);
}

public Native_IsClientInPvP(Handle:plugin, numParams)
{
	return IsClientInPvP(GetNativeCell(1));
}