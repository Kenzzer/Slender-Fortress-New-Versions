#if defined _sf2_pvp_included
 #endinput
#endif
#define _sf2_pvp_included


#define SF2_PVP_SPAWN_SOUND "items/spawn_item.wav"

#define TRIGGER_CLIENTS (1 << 0)
#define TRIGGER_NPCS (1 << 1)
#define TRIGGER_PUSHABLES (1 << 2)
#define TRIGGER_PHYSICS_OBJECTS (1 << 3)
#define TRIGGER_ALLY_NPCS (1 << 4)
#define TRIGGER_CLIENTS_VEHICLES (1 << 5)
#define TRIGGER_EVERYTHING_NOT_DEBRIS (1 << 6)
#define TRIGGER_CLIENTS_NOT_VEHICLES (1 << 7)
#define TRIGGER_PHYSICS_DEBRIS (1 << 8)
#define TRIGGER_NPCS_VEHICLES (1 << 9)
#define TRIGGER_NOT_BOTS (1 << 10)

Handle g_cvPvPArenaLeaveTime;
Handle g_cvPvPArenaPlayerCollisions;
Handle g_cvPvPArenaProjectileZap;

static const char g_sPvPProjectileClasses[][] = 
{
	"tf_projectile_rocket", 
	"tf_projectile_sentryrocket",
	"tf_projectile_stun_ball",
	"tf_projectile_ball_ornament",
	"tf_projectile_cleaver",
	"tf_projectile_energy_ball",
	"tf_projectile_flare",
	"tf_projectile_jar",
	"tf_projectile_jar_milk",
	"tf_projectile_pipe",
	"tf_projectile_pipe_remote",
	"tf_projectile_throwable_breadmonster",
	"tf_projectile_throwable_brick",
	"tf_projectile_throwable",
	//Don't change
	"tf_projectile_arrow",
	"tf_projectile_healing_bolt",
	"tf_projectile_energy_ring",
	"tf_projectile_syringe"
};
static const char g_sPvPProjectileClassesNoTouch[][] = 
{
	"tf_projectile_stun_ball",
	"tf_projectile_ball_ornament",
	"tf_projectile_pipe"
};

static bool g_bPlayerInPvP[MAXPLAYERS + 1];
static Handle g_hPlayerPvPTimer[MAXPLAYERS + 1];
static Handle g_hPlayerPvPRespawnTimer[MAXPLAYERS + 1];
static int g_iPlayerPvPTimerCount[MAXPLAYERS + 1];
static bool g_bPlayerInPvPTrigger[MAXPLAYERS + 1];

static Handle g_hPvPFlameEntities;

enum
{
	PvPFlameEntData_EntRef = 0,
	PvPFlameEntData_LastHitEntRef,
	PvPFlameEntData_MaxStats
};

public void PvP_Initialize()
{
	g_cvPvPArenaLeaveTime = CreateConVar("sf2_player_pvparena_leavetime", "3");
	g_cvPvPArenaPlayerCollisions = CreateConVar("sf2_player_pvparena_collisions", "1");
	g_cvPvPArenaProjectileZap = CreateConVar("sf2_pvp_projectile_removal", "0", "This is an experimental code! It could make your server crash, if you get any crash disable this cvar");
	
	g_hPvPFlameEntities = CreateArray(PvPFlameEntData_MaxStats);
}

public void PvP_SetupMenus()
{
	g_hMenuSettingsPvP = CreateMenu(Menu_SettingsPvP);
	SetMenuTitle(g_hMenuSettingsPvP, "%t%t\n \n", "SF2 Prefix", "SF2 Settings PvP Menu Title");
	AddMenuItem(g_hMenuSettingsPvP, "0", "Toggle automatic spawning");
	SetMenuExitBackButton(g_hMenuSettingsPvP, true);
}

public void PvP_OnMapStart()
{
	ClearArray(g_hPvPFlameEntities);
	int iEnt = -1;
	while ((iEnt = FindEntityByClassname(iEnt, "trigger_multiple")) != -1)
	{
		if(IsValidEntity(iEnt))
		{
			char strName[50];
			GetEntPropString(iEnt, Prop_Data, "m_iName", strName, sizeof(strName));
			if(strcmp(strName, "sf2_pvp_trigger") == 0)
			{
				//StartTouch seems to be unreliable if a player is teleported/spawns in the trigger
				//SDKHook( iEnt, SDKHook_StartTouch, PvP_OnTriggerStartTouch );
				//But end touch works fine.
				SDKHook( iEnt, SDKHook_EndTouch, PvP_OnTriggerEndTouch );
				SDKHook( iEnt, SDKHook_StartTouch, PvP_OnTriggerStartTouchEx );
			}
		}
	}
}
public void PvP_OnRoundStart()
{
	int iEnt = -1;
	while ((iEnt = FindEntityByClassname(iEnt, "trigger_multiple")) != -1)
	{
		if(IsValidEntity(iEnt))
		{
			char strName[50];
			GetEntPropString(iEnt, Prop_Data, "m_iName", strName, sizeof(strName));
			if(strcmp(strName, "sf2_pvp_trigger") == 0)
			{
				//Add physics object flag, so we can zap projectiles!
				int flags = GetEntProp(iEnt, Prop_Data, "m_spawnflags");
				flags |= TRIGGER_PHYSICS_OBJECTS;
				flags |= TRIGGER_PHYSICS_DEBRIS;
				SetEntProp(iEnt, Prop_Data, "m_spawnflags", flags);
				SDKHook( iEnt, SDKHook_EndTouch, PvP_OnTriggerEndTouch );
				SDKHook( iEnt, SDKHook_StartTouch, PvP_OnTriggerStartTouchEx );
			}
		}
	}
}
public void PvP_Precache()
{
	PrecacheSound2(SF2_PVP_SPAWN_SOUND);
}

public void PvP_OnClientPutInServer(int client)
{
	PvP_ForceResetPlayerPvPData(client);
}

public void PvP_OnClientDisconnect(int client)
{
	PvP_SetPlayerPvPState(client, false, false, false);
}

public void PvP_OnGameFrame()
{
	// Process through PvP projectiles.
	for (int i = 0; i < sizeof(g_sPvPProjectileClasses); i++)
	{
		int ent = -1;
		while ((ent = FindEntityByClassname(ent, g_sPvPProjectileClasses[i])) != -1)
		{
			int iThrowerOffset = FindDataMapOffs(ent, "m_hThrower");
			bool bChangeProjectileTeam = false;
			
			int iOwnerEntity = GetEntPropEnt(ent, Prop_Data, "m_hOwnerEntity");
			if (IsValidClient(iOwnerEntity) && IsClientInPvP(iOwnerEntity) && GetClientTeam(iOwnerEntity) != TFTeam_Red)
			{
				bChangeProjectileTeam = true;
			}
			else if (iThrowerOffset != -1)
			{
				iOwnerEntity = GetEntDataEnt2(ent, iThrowerOffset);
				if (IsValidClient(iOwnerEntity) && IsClientInPvP(iOwnerEntity) && GetClientTeam(iOwnerEntity) != TFTeam_Red)
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
		static float flMins[3] = { -6.0, ... };
		static float flMaxs[3] = { 6.0, ... };
		
		float flOrigin[3];
		
		Handle hTrace = INVALID_HANDLE;
		int ent = -1;
		int iOwnerEntity = INVALID_ENT_REFERENCE; 
		int iHitEntity = INVALID_ENT_REFERENCE;
		
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
					int entref = EntIndexToEntRef(ent);
					
					int iIndex = FindValueInArray(g_hPvPFlameEntities, entref);
					if (iIndex != -1)
					{
						int iLastHitEnt = EntRefToEntIndex(GetArrayCell(g_hPvPFlameEntities, iIndex, PvPFlameEntData_LastHitEntRef));
					
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

public void PvP_OnEntityCreated(int ent, const char[] sClassname)
{
#if defined DEBUG
	SendDebugMessageToPlayers(DEBUG_ENTITIES,0,"\x083EFF3EFF+ %i(%s)",ent,sClassname);
#endif
	if (StrEqual(sClassname, "tf_flame", false))
	{
		int iIndex = PushArrayCell(g_hPvPFlameEntities, EntIndexToEntRef(ent));
		if (iIndex != -1)
		{
			SetArrayCell(g_hPvPFlameEntities, iIndex, INVALID_ENT_REFERENCE, PvPFlameEntData_LastHitEntRef);
		}
	}
	else
	{
		for (int i = 0; i < sizeof(g_sPvPProjectileClasses); i++)
		{
			if (StrEqual(sClassname, g_sPvPProjectileClasses[i], false))
			{
				SDKHook(ent, SDKHook_Spawn, Hook_PvPProjectileSpawn);
				SDKHook(ent, SDKHook_SpawnPost, Hook_PvPProjectileSpawnPost);
				break;
			}
			if (StrEqual(sClassname, g_sPvPProjectileClassesNoTouch[i], false))
			{
				SDKHook(ent, SDKHook_Touch, Hook_PvPProjectile_OnTouch);
				break;
			}
		}
	}
}
public void PvP_OnEntityDestroyed(int ent, const char[] sClassname)
{
#if defined DEBUG
	SendDebugMessageToPlayers(DEBUG_ENTITIES,0,"\x08FF4040FF- %i(%s)",ent,sClassname);
#endif
	if (StrEqual(sClassname, "tf_flame", false))
	{
		int entref = EntIndexToEntRef(ent);
		int iIndex = FindValueInArray(g_hPvPFlameEntities, entref);
		if (iIndex != -1)
		{
			RemoveFromArray(g_hPvPFlameEntities, iIndex);
		}
	}
}
public Action Hook_PvPProjectile_OnTouch(int iProjectile, int iClient)
{
	// Check if the projectile hit a player outside of pvp area
	// Without cannon balls can bounce players which should not happen because they are outside of pvp.
	if(IsValidClient(iClient) && !IsClientInPvP(iClient))
	{
		return Plugin_Handled;
	}

	return Plugin_Continue;
}
public Action Hook_PvPProjectileSpawn(int ent)
{
	char sClass[64];
	GetEntityClassname(ent, sClass, sizeof(sClass));
	
	int iThrowerOffset = FindDataMapOffs(ent, "m_hThrower");
	int iOwnerEntity = GetEntPropEnt(ent, Prop_Data, "m_hOwnerEntity");
	
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

public void Hook_PvPProjectileSpawnPost(int ent)
{
	char sClass[64];
	GetEntityClassname(ent, sClass, sizeof(sClass));
	
	int iThrowerOffset = FindDataMapOffs(ent, "m_hThrower");
	int iOwnerEntity = GetEntPropEnt(ent, Prop_Data, "m_hOwnerEntity");
	
	if (iOwnerEntity == -1 && iThrowerOffset != -1)
	{
		iOwnerEntity = GetEntDataEnt2(ent, iThrowerOffset);
	}
	
	if (IsValidClient(iOwnerEntity))
	{
		if (IsClientInPvP(iOwnerEntity))
		{
			if(GetConVarBool(g_cvPvPArenaProjectileZap))
			{
				CreateTimer(0.1,PvP_EntitySpawnPost,ent);
				SetEntProp(ent, Prop_Data, "m_usSolidFlags", 1);
			}
			if(g_hPlayerPvPTimer[iOwnerEntity]==INVALID_HANDLE)
			{
				SetEntProp(ent, Prop_Data, "m_iInitialTeamNum", 0);
				SetEntProp(ent, Prop_Send, "m_iTeamNum", 0);
			}
			else
			{
				//Client is not in pvp, remove the projectile
				if(GetConVarBool(g_cvPvPArenaProjectileZap))
					PvP_ZapProjectile(ent,false);
			}
		}
	}
}
public Action PvP_EntitySpawnPost(Handle timer,any ent)
{
	if(IsValidEntity(ent))
	{
		if(GetEntProp(ent, Prop_Data, "m_usSolidFlags")!=0)
			PvP_ZapProjectile(ent,false);
	}
}
public void PvP_OnPlayerSpawn(int client)
{
	PvP_SetPlayerPvPState(client, false, false, false);

	if (IsPlayerAlive(client) && IsClientParticipating(client))
	{
		if (!IsClientInGhostMode(client) && !g_bPlayerProxy[client])
		{
			if (g_bPlayerEliminated[client] || g_bPlayerEscaped[client])
			{
				bool bAutoSpawn = g_iPlayerPreferences[client][PlayerPreference_PvPAutoSpawn];
				
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
void PvP_ZapProjectile(int iProjectile,bool bEffects=true)
{
	//Add zap effects
	if(bEffects)
	{
		float flPos[3];
		GetEntPropVector(iProjectile, Prop_Send, "m_vecOrigin", flPos);
		//Spawn the particle.
		TE_SetupTFParticleEffect(g_iParticle[ZapParticle], flPos, flPos);
		TE_SendToAll();
		//Play zap sound.
		EmitSoundToAll(ZAP_SOUND, iProjectile, SNDCHAN_AUTO, SNDLEVEL_SCREAMING);
		SetEntityRenderMode(iProjectile, RENDER_TRANSCOLOR);
		SetEntityRenderColor(iProjectile, 0, 0, 0, 1);
	}
	AcceptEntityInput(iProjectile,"Kill");
}
public void PvP_OnPlayerDeath(int client, bool bFake)
{
	if (!bFake)
	{
		if (!IsClientInGhostMode(client) && !g_bPlayerProxy[client])
		{
			bool bAutoSpawn = g_iPlayerPreferences[client][PlayerPreference_PvPAutoSpawn];
			
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

public void PvP_OnClientGhostModeEnable(int client)
{
	g_hPlayerPvPRespawnTimer[client] = INVALID_HANDLE;
}

public void PvP_OnClientPutInPlay(int client)
{
	g_hPlayerPvPRespawnTimer[client] = INVALID_HANDLE;
}

public bool Hook_ClientPvPShouldCollide(int ent,int collisiongroup,int contentsmask, bool originalResult)
{
	if (!g_bEnabled) return originalResult;
	return true;
}

public void PvP_OnTriggerStartTouch(int trigger,int iOther)
{
	char sName[64];
	GetEntPropString(trigger, Prop_Data, "m_iName", sName, sizeof(sName));
	
	if (StrContains(sName, "sf2_pvp_trigger", false) == 0)
	{
		if (IsValidClient(iOther) && IsPlayerAlive(iOther))
		{
			g_bPlayerInPvPTrigger[iOther] = true;
			
			if (IsClientInPvP(iOther))
			{
				// Player left and came back again, but is still in PvP mode.
				g_iPlayerPvPTimerCount[iOther] = 0;
				g_hPlayerPvPTimer[iOther] = INVALID_HANDLE;
			}
			else
			{
				PvP_SetPlayerPvPState(iOther, true);
			}
		}
	}
}
public Action PvP_OnTriggerStartTouchEx(int trigger,int iOther)
{
	if(GetConVarBool(g_cvPvPArenaProjectileZap))
	{
		//(Experimental)
		if (iOther>MaxClients && IsValidEntity(iOther))
		{
			//Get entity's classname.
			char sClassname[50];
			GetEntityClassname(iOther,sClassname,sizeof(sClassname));
			for (int i = 0; i < sizeof(g_sPvPProjectileClasses); i++)
			{
				if (StrEqual(sClassname, g_sPvPProjectileClasses[i], false))
				{
					SetEntProp(iOther, Prop_Data, "m_usSolidFlags", 0);
				}
			}
		}
	}
}
public Action PvP_OnTriggerEndTouch(int trigger,int iOther)
{
	if (IsValidClient(iOther))
	{
		g_bPlayerInPvPTrigger[iOther] = false;
		
		if (IsClientInPvP(iOther))
		{
			g_iPlayerPvPTimerCount[iOther] = GetConVarInt(g_cvPvPArenaLeaveTime);
			g_hPlayerPvPTimer[iOther] = CreateTimer(1.0, Timer_PlayerPvPLeaveCountdown, GetClientUserId(iOther), TIMER_FLAG_NO_MAPCHANGE | TIMER_REPEAT);
		}
	}
	if(GetConVarBool(g_cvPvPArenaProjectileZap))
	{
		//A projectile went off pvp area. (Experimental)
		if (iOther>MaxClients && IsValidEntity(iOther))
		{
			//Get entity's classname.
			char sClassname[50];
			GetEntityClassname(iOther,sClassname,sizeof(sClassname));
			for (int i = 0; i < (sizeof(g_sPvPProjectileClasses)-4); i++)
			{
				if (StrEqual(sClassname, g_sPvPProjectileClasses[i], false))
				{
					//Yup it's a projectile zap it!
					//But we have to wait to prevent some bugs.
					CreateTimer(0.1,EntityStillAlive,iOther);
				}
			}
		}
	}
}
public Action EntityStillAlive(Handle timer, any iEnt)
{
	if(IsValidEntity(iEnt))
	{
		PvP_ZapProjectile(iEnt);
	}
}
/**
 *	Enables/Disables PvP mode on the player.
 */
void PvP_SetPlayerPvPState(int client, bool bStatus, bool bRemoveProjectiles=true, bool bRegenerate=true)
{
	if (!IsValidClient(client)) return;
	
	bool bOldInPvP = g_bPlayerInPvP[client];
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
		int iHealth = GetEntProp(client, Prop_Send, "m_iHealth");
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

static void PvP_OnFlameEntityStartTouchPost(int flame,int iOther)
{
	if (IsValidClient(iOther))
	{
		if ((IsRoundInWarmup() || IsClientInPvP(iOther)) && !IsRoundEnding())
		{
			int iFlamethrower = GetEntPropEnt(flame, Prop_Data, "m_hOwnerEntity");
			if (IsValidEdict(iFlamethrower))
			{
				int iOwnerEntity = GetEntPropEnt(iFlamethrower, Prop_Data, "m_hOwnerEntity");
				if (iOwnerEntity != iOther && IsValidClient(iOwnerEntity))
				{
					if (IsRoundInWarmup() || IsClientInPvP(iOwnerEntity))
					{
						if (GetClientTeam(iOther) == GetClientTeam(iOwnerEntity) && GetClientTeam(iOwnerEntity) != TFTeam_Red)
						{
							TF2_IgnitePlayer(iOther, iOwnerEntity);
							SDKHooks_TakeDamage(iOther, iOwnerEntity, iOwnerEntity, 7.0, IsClientCritBoosted(iOwnerEntity) ? (DMG_BURN | DMG_PREVENT_PHYSICS_FORCE | DMG_ACID) : DMG_BURN | DMG_PREVENT_PHYSICS_FORCE); 
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
void PvP_ForceResetPlayerPvPData(int client)
{
	g_bPlayerInPvP[client] = false;
	g_hPlayerPvPTimer[client] = INVALID_HANDLE;
	g_iPlayerPvPTimerCount[client] = 0;
	g_hPlayerPvPRespawnTimer[client] = INVALID_HANDLE;
}

static void PvP_RemovePlayerProjectiles(int client)
{
	for (int i = 0; i < sizeof(g_sPvPProjectileClasses); i++)
	{
		int ent = -1;
		while ((ent = FindEntityByClassname(ent, g_sPvPProjectileClasses[i])) != -1)
		{
			int iThrowerOffset = FindDataMapOffs(ent, "m_hThrower");
			bool bMine = false;
		
			int iOwnerEntity = GetEntPropEnt(ent, Prop_Data, "m_hOwnerEntity");
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

public Action Timer_TeleportPlayerToPvP(Handle timer, any userid)
{
	int client = GetClientOfUserId(userid);
	if (client <= 0) return;
	
	if (timer != g_hPlayerPvPRespawnTimer[client]) return;
	g_hPlayerPvPRespawnTimer[client] = INVALID_HANDLE;
	
	Handle hSpawnPointList = CreateArray();
	
	int ent = -1;
	while ((ent = FindEntityByClassname(ent, "info_target")) != -1)
	{
		char sName[32];
		GetEntPropString(ent, Prop_Data, "m_iName", sName, sizeof(sName));
		if (!StrContains(sName, "sf2_pvp_spawnpoint", false))
		{
			PushArrayCell(hSpawnPointList, ent);
		}
	}
	
	float flMins[3], flMaxs[3];
	GetEntPropVector(client, Prop_Send, "m_vecMins", flMins);
	GetEntPropVector(client, Prop_Send, "m_vecMaxs", flMaxs);
	
	Handle hClearSpawnPointList = CloneArray(hSpawnPointList);
	for (int i = 0; i < GetArraySize(hSpawnPointList); i++)
	{
		int iEnt = GetArrayCell(hSpawnPointList, i);
		
		float flMyPos[3];
		GetEntPropVector(iEnt, Prop_Data, "m_vecAbsOrigin", flMyPos);
		
		if (IsSpaceOccupiedPlayer(flMyPos, flMins, flMaxs, client))
		{
			int iIndex = FindValueInArray(hClearSpawnPointList, iEnt);
			if (iIndex != -1)
			{
				RemoveFromArray(hClearSpawnPointList, iIndex);
			}
		}
	}
	
	int iNum;
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
		float flPos[3], flAng[3];
		GetEntPropVector(ent, Prop_Data, "m_vecAbsOrigin", flPos);
		GetEntPropVector(ent, Prop_Data, "m_angAbsRotation", flAng);
		TeleportEntity(client, flPos, flAng, view_as<float>({ 0.0, 0.0, 0.0 }));
		
		EmitAmbientSound(SF2_PVP_SPAWN_SOUND, flPos, _, SNDLEVEL_NORMAL, _, 1.0);
	}
	
	CloseHandle(hSpawnPointList);
	CloseHandle(hClearSpawnPointList);
}

public Action Timer_PlayerPvPLeaveCountdown(Handle timer, any userid)
{
	int client = GetClientOfUserId(userid);
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
bool IsClientInPvP(int client)
{
	return g_bPlayerInPvP[client];
}


// API

public void PvP_InitializeAPI()
{
	CreateNative("SF2_IsClientInPvP", Native_IsClientInPvP);
}

public int Native_IsClientInPvP(Handle plugin,int numParams)
{
	return view_as<bool>(IsClientInPvP(GetNativeCell(1)));
}