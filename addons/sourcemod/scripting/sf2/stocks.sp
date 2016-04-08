#if defined _sf2_stocks_included
 #endinput
#endif
#define _sf2_stocks_included


#define SF2_FLASHLIGHT_WIDTH 512.0 // How wide the player's Flashlight should be in world units.
#define SF2_FLASHLIGHT_LENGTH 1024.0 // How far the player's Flashlight can reach in world units.
#define SF2_FLASHLIGHT_BRIGHTNESS 0 // Intensity of the players' Flashlight.
#define SF2_FLASHLIGHT_DRAIN_RATE 0.65 // How long (in seconds) each bar on the player's Flashlight meter lasts.
#define SF2_FLASHLIGHT_RECHARGE_RATE 0.68 // How long (in seconds) it takes each bar on the player's Flashlight meter to recharge.
#define SF2_FLASHLIGHT_FLICKERAT 0.25 // The percentage of the Flashlight battery where the Flashlight will start to blink.
#define SF2_FLASHLIGHT_ENABLEAT 0.3 // The percentage of the Flashlight battery where the Flashlight will be able to be used again (if the player shortens out the Flashlight from excessive use).
#define SF2_FLASHLIGHT_COOLDOWN 0.4 // How much time players have to wait before being able to switch their flashlight on again after turning it off.

// Hud Element hiding flags (possibly outdated)
#define	HIDEHUD_WEAPONSELECTION		( 1<<0 )	// Hide ammo count & weapon selection
#define	HIDEHUD_FLASHLIGHT			( 1<<1 )
#define	HIDEHUD_ALL					( 1<<2 )
#define HIDEHUD_HEALTH				( 1<<3 )	// Hide health & armor / suit battery
#define HIDEHUD_PLAYERDEAD			( 1<<4 )	// Hide when local player's dead
#define HIDEHUD_NEEDSUIT			( 1<<5 )	// Hide when the local player doesn't have the HEV suit
#define HIDEHUD_MISCSTATUS			( 1<<6 )	// Hide miscellaneous status elements (trains, pickup history, death notices, etc)
#define HIDEHUD_CHAT				( 1<<7 )	// Hide all communication elements (saytext, voice icon, etc)
#define	HIDEHUD_CROSSHAIR			( 1<<8 )	// Hide crosshairs
#define	HIDEHUD_VEHICLE_CROSSHAIR	( 1<<9 )	// Hide vehicle crosshair
#define HIDEHUD_INVEHICLE			( 1<<10 )
#define HIDEHUD_BONUS_PROGRESS		( 1<<11 )	// Hide bonus progress display (for bonus map challenges)

#define FFADE_IN            0x0001        // Just here so we don't pass 0 into the function
#define FFADE_OUT           0x0002        // Fade out (not in)
#define FFADE_MODULATE      0x0004        // Modulate (don't blend)
#define FFADE_STAYOUT       0x0008        // ignores the duration, stays faded out until new ScreenFade message received
#define FFADE_PURGE         0x0010        // Purges all other fades, replacing them with this one

#define SF_FADE_IN				0x0001		// Fade in, not out
#define SF_FADE_MODULATE		0x0002		// Modulate, don't blend
#define SF_FADE_ONLYONE			0x0004
#define SF_FADE_STAYOUT			0x0008

#define MAX_BUTTONS 26

#define FSOLID_CUSTOMRAYTEST 0x0001
#define FSOLID_CUSTOMBOXTEST 0x0002
#define FSOLID_NOT_SOLID 0x0004
#define FSOLID_TRIGGER 0x0008

#define COLLISION_GROUP_DEBRIS 1
#define COLLISION_GROUP_PLAYER 5

#define EFL_FORCE_CHECK_TRANSMIT (1 << 7)

#define vec3_origin { 0.0, 0.0, 0.0 }

//My pull request for this cond is accepted I define it there until sourcemod release a new version.
TFCond TFCond_SpawnOutline = view_as<TFCond>(114);

// hull defines, mostly used for space checking.
float HULL_HUMAN_MINS[3] = { -13.0, -13.0, 0.0 }
float HULL_HUMAN_MAXS[3] = { 13.0, 13.0, 72.0 }

float HULL_TF2PLAYER_MINS[3] = { -24.5, -24.5, 0.0 }
float HULL_TF2PLAYER_MAXS[3] = { 24.5,  24.5, 83.0 }

//  ==========================================================
//	Map Functions
//  ==========================================================
stock bool SF_IsSurvivalMap()
{
	return view_as<bool>(g_bIsSurvivalMap || (GetConVarInt(g_cvSurvivalMap) == 1));
}
stock bool SF_IsRaidMap()
{
	return view_as<bool>(g_bIsRaidMap || (GetConVarInt(g_cvRaidMap) == 1));
}
//	==========================================================
//	ENTITY FUNCTIONS
//	==========================================================

stock bool IsEntityClassname(int iEnt, const char[] classname, bool bCaseSensitive=true)
{
	if (!IsValidEntity(iEnt)) return false;
	
	char sBuffer[256];
	GetEntityClassname(iEnt, sBuffer, sizeof(sBuffer));
	
	return StrEqual(sBuffer, classname, bCaseSensitive);
}

stock int FindEntityByTargetname(const char[] targetName, const char[] className, bool caseSensitive=true)
{
	int ent = -1;
	while ((ent = FindEntityByClassname(ent, className)) != -1)
	{
		char sName[64];
		GetEntPropString(ent, Prop_Data, "m_iName", sName, sizeof(sName));
		if (StrEqual(sName, targetName, caseSensitive))
		{
			return ent;
		}
	}
	
	return INVALID_ENT_REFERENCE;
}

stock float EntityDistanceFromEntity(int ent1,int ent2, bool bSquared=false)
{
	if (!IsValidEntity(ent1) || !IsValidEntity(ent2)) return -1.0;
	
	float flMyPos[3],flHisPos[3];
	GetEntPropVector(ent1, Prop_Data, "m_vecAbsOrigin", flMyPos);
	GetEntPropVector(ent2, Prop_Data, "m_vecAbsOrigin", flHisPos);
	return GetVectorDistance(flMyPos, flHisPos, bSquared);
}

stock void GetEntityOBBCenterPosition(int ent, float flBuffer)
{
	float flPos[3], flMins[3], flMaxs[3];
	GetEntPropVector(ent, Prop_Data, "m_vecAbsOrigin", flPos);
	GetEntPropVector(ent, Prop_Send, "m_vecMins", flMins);
	GetEntPropVector(ent, Prop_Send, "m_vecMaxs", flMaxs);
	
	for (new i = 0; i < 3; i++) flBuffer[i] = flPos[i] + ((flMins[i] + flMaxs[i]) / 2.0);
}

stock bool IsSpaceOccupied(const float pos[3], const float mins[3], const float maxs[3],int entity=-1,int &ref=-1)
{
	Handle hTrace = TR_TraceHullFilterEx(pos, pos, mins, maxs, MASK_VISIBLE, TraceRayDontHitEntity, entity);
	bool bHit = TR_DidHit(hTrace);
	ref = TR_GetEntityIndex(hTrace);
	CloseHandle(hTrace);
	return bHit;
}

stock bool IsSpaceOccupiedIgnorePlayers(const float pos[3], const float mins[3], const float maxs[3],int entity=-1,int &ref=-1)
{
	Handle hTrace = TR_TraceHullFilterEx(pos, pos, mins, maxs, MASK_VISIBLE, TraceRayDontHitPlayersOrEntity, entity);
	bool bHit = TR_DidHit(hTrace);
	ref = TR_GetEntityIndex(hTrace);
	CloseHandle(hTrace);
	return bHit;
}

stock bool IsSpaceOccupiedPlayer(const float pos[3], const float mins[3], const float maxs[3],int entity=-1,int &ref=-1)
{
	Handle hTrace = TR_TraceHullFilterEx(pos, pos, mins, maxs, MASK_PLAYERSOLID, TraceRayDontHitEntity, entity);
	bool bHit = TR_DidHit(hTrace);
	ref = TR_GetEntityIndex(hTrace);
	CloseHandle(hTrace);
	return bHit;
}

stock bool IsSpaceOccupiedNPC(const float pos[3], const float mins[3], const float maxs[3],int entity=-1,int &ref=-1)
{
	Handle hTrace = TR_TraceHullFilterEx(pos, pos, mins, maxs, MASK_NPCSOLID, TraceRayDontHitEntity, entity);
	bool bHit = TR_DidHit(hTrace);
	ref = TR_GetEntityIndex(hTrace);
	CloseHandle(hTrace);
	return bHit;
}

stock void EntitySetAnimation(int iEntity, const char[] sAnimation, bool bDefaultAnimation=true, float flPlaybackRate=1.0)
{
	//The min and max playbackrate are -12/12
	if(flPlaybackRate<-12.0) flPlaybackRate=-12.0;
	if(flPlaybackRate>12.0) flPlaybackRate=12.0;
	// Set m_nSequence to 0 to fix an animation glitch with HL2/GMod models.
	SetEntProp(iEntity, Prop_Send, "m_nSequence", 0);
	
	if (bDefaultAnimation)
	{
		SetVariantString(sAnimation);
		AcceptEntityInput(iEntity, "SetDefaultAnimation");
	}
	else
	{
		SetVariantString("");
		AcceptEntityInput(iEntity, "SetDefaultAnimation");
	}
	
	SetVariantString(sAnimation);
	AcceptEntityInput(iEntity, "SetAnimation");
	SetVariantFloat(flPlaybackRate);
	AcceptEntityInput(iEntity, "SetPlaybackRate");
}

//	==========================================================
//	CLIENT ENTITY FUNCTIONS
//	==========================================================

//Credits to Linux_lover for this stock and signature.
stock void SDK_PlaySpecificSequence(int client, const char[] strSequence)
{
	if(g_hSDKPlaySpecificSequence != INVALID_HANDLE)
	{
#if defined DEBUG
		static bool once = true;
		if(once)
		{
			PrintToServer("(SDK_PlaySpecificSequence) Calling on player %N \"%s\"..", client, strSequence);
			once = false;
		}
#endif
		SDKCall(g_hSDKPlaySpecificSequence, client, strSequence);
	}
}
stock void SDK_EquipWearable(int client, int entity)
{
	if(g_hSDKEquipWearable != INVALID_HANDLE)
	{
		SDKCall( g_hSDKEquipWearable, client, entity );
	}
}
stock void KillClient(int client)
{
	ForcePlayerSuicide(client);
	SDKHooks_TakeDamage(client, 0, 0, 9001.0, 0x80 | DMG_PREVENT_PHYSICS_FORCE, _, view_as<float>({ 0.0, 0.0, 0.0 }));
	SetVariantInt(9001);
	AcceptEntityInput(client, "RemoveHealth");
}
stock bool IsClientCritBoosted(int client)
{
	if (TF2_IsPlayerInCondition(client, TFCond_Kritzkrieged) ||
		TF2_IsPlayerInCondition(client, TFCond_HalloweenCritCandy) ||
		TF2_IsPlayerInCondition(client, TFCond_CritCanteen) ||
		TF2_IsPlayerInCondition(client, TFCond_CritOnFirstBlood) ||
		TF2_IsPlayerInCondition(client, TFCond_CritOnWin) ||
		TF2_IsPlayerInCondition(client, TFCond_CritOnFlagCapture) ||
		TF2_IsPlayerInCondition(client, TFCond_CritOnKill) ||
		TF2_IsPlayerInCondition(client, TFCond_CritOnDamage) ||
		TF2_IsPlayerInCondition(client, TFCond_CritMmmph))
	{
		return true;
	}
	
	int iActiveWeapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	if (IsValidEdict(iActiveWeapon))
	{
		char sNetClass[64];
		GetEntityNetClass(iActiveWeapon, sNetClass, sizeof(sNetClass));
		
		if (StrEqual(sNetClass, "CTFFlameThrower"))
		{
			if (GetEntProp(iActiveWeapon, Prop_Send, "m_bCritFire")) return true;
		
			int iItemDef = GetEntProp(iActiveWeapon, Prop_Send, "m_iItemDefinitionIndex");
			if (iItemDef == 594 && TF2_IsPlayerInCondition(client, TFCond_CritMmmph)) return true;
		}
		else if (StrEqual(sNetClass, "CTFMinigun"))
		{
			if (GetEntProp(iActiveWeapon, Prop_Send, "m_bCritShot")) return true;
		}
	}
	
	return false;
}

stock void ClientSwitchToWeaponSlot(int client,int iSlot)
{
	int iWeapon = GetPlayerWeaponSlot(client, iSlot);
	if (iWeapon == -1) return;
	
	// EquipPlayerWeapon(client, iWeapon); // doesn't work with TF2 that well.
	SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", iWeapon);
}

stock void ChangeClientTeamNoSuicide(int client,int team, bool bRespawn=true)
{
	if (!IsClientInGame(client)) return;
	
	if (GetClientTeam(client) != team)
	{
		SetEntProp(client, Prop_Send, "m_lifeState", 2);
		ChangeClientTeam(client, team);
		SetEntProp(client, Prop_Send, "m_lifeState", 0);
		if (bRespawn) TF2_RespawnPlayer(client);
	}
}

stock void UTIL_ScreenShake(int client, float amplitude, float duration, float frequency)
{
	Handle hBf = StartMessageOne("Shake", client);
	if (hBf != INVALID_HANDLE)
	{
		BfWriteByte(hBf, 0);
		BfWriteFloat(hBf, amplitude);
		BfWriteFloat(hBf, frequency);
		BfWriteFloat(hBf, duration);
		EndMessage();
	}
}

public void UTIL_ScreenFade(int client,int duration,int time,int flags,int r,int g,int b,int a)
{
	int clients[1];
	Handle bf;
	clients[0] = client;
	
	bf = StartMessage("Fade", clients, 1);
	BfWriteShort(bf, duration);
	BfWriteShort(bf, time);
	BfWriteShort(bf, flags);
	BfWriteByte(bf, r);
	BfWriteByte(bf, g);
	BfWriteByte(bf, b);
	BfWriteByte(bf, a);
	EndMessage();
}

stock bool IsValidClient(int client)
{
	return view_as<bool>((client > 0 && client <= MaxClients && IsClientInGame(client)));
}

//	==========================================================
//	TF2-SPECIFIC FUNCTIONS
//	==========================================================
stock bool IsTauntWep(int iWeapon)
{
	int Index = GetEntProp(iWeapon, Prop_Send, "m_iItemDefinitionIndex");
	if(Index==37 || Index==304 || Index==5 || Index==195 || Index==43 || Index==239 || Index==310 || Index==331 || Index==426 || Index==587 || Index==656 || Index==1084 || Index==1100)
		return true;
	return false;
}
stock void FindHealthBar()
{
	g_ihealthBar = FindEntityByClassname(-1, "monster_resource");
	
	if (g_ihealthBar == -1)
	{
		g_ihealthBar = CreateEntityByName("monster_resource");
		if (g_ihealthBar != -1)
		{
			DispatchSpawn(g_ihealthBar);
		}
	}
}
stock void ForceTeamWin(int team)
{
	int ent = FindEntityByClassname(-1, "team_control_point_master");
	if (ent == -1)
	{
		ent = CreateEntityByName("team_control_point_master");
		DispatchSpawn(ent);
		AcceptEntityInput(ent, "Enable");
	}
	
	SetVariantInt(team);
	AcceptEntityInput(ent, "SetWinner");
}

stock void GameTextTFMessage(const char[] message, const char[] icon="")
{
	int ent = CreateEntityByName("game_text_tf");
	DispatchKeyValue(ent, "message", message);
	DispatchKeyValue(ent, "display_to_team", "0");
	DispatchKeyValue(ent, "icon", icon);
	DispatchSpawn(ent);
	AcceptEntityInput(ent, "Display");
	AcceptEntityInput(ent, "Kill");
}

stock int BuildAnnotationBitString(const int[] clients,int iMaxClients)
{
	int iBitString = 1;
	for (int i = 0; i < maxClients; i++)
	{
		int client = clients[i];
		if (!IsClientInGame(client) || !IsPlayerAlive(client)) continue;
	
		iBitString |= RoundFloat(Pow(2.0, float(client)));
	}
	
	return iBitString;
}

stock void SpawnAnnotation(int client,int entity, const float pos[3], const char[] message, float lifetime)
{
	Handle event = CreateEvent("show_annotation", true);
	if (event != INVALID_HANDLE)
	{
		new bitstring = BuildAnnotationBitString(id, pos, type, team);
		if (bitstring > 1)
		{
			pos[2] -= 35.0;
			SetEventFloat(event, "worldPosX", pos[0]);
			SetEventFloat(event, "worldPosY", pos[1]);
			SetEventFloat(event, "worldPosZ", pos[2]);
			SetEventFloat(event, "lifetime", lifetime);
			SetEventInt(event, "id", id);
			SetEventString(event, "text", message);
			SetEventInt(event, "visibilityBitfield", bitstring);
			FireEvent(event);
			KillTimer(event);
		}
		
	}
}

stock float TF2_GetClassBaseSpeed(TFClassType class)
{
	switch (class)
	{
		case TFClass_Scout:
		{
			return 400.0;
		}
		case TFClass_Soldier:
		{
			return 240.0;
		}
		case TFClass_Pyro:
		{
			return 300.0;
		}
		case TFClass_DemoMan:
		{
			return 280.0;
		}
		case TFClass_Heavy:
		{
			return 230.0;
		}
		case TFClass_Engineer:
		{
			return 300.0;
		}
		case TFClass_Medic:
		{
			return 320.0;
		}
		case TFClass_Sniper:
		{
			return 300.0;
		}
		case TFClass_Spy:
		{
			return 300.0;
		}
	}
	
	return 0.0;
}

stock Handle PrepareItemHandle(char[] classname,int index,int level,int quality, char[] att)
{
	Handle hItem = TF2Items_CreateItem(OVERRIDE_ALL | FORCE_GENERATION);
	TF2Items_SetClassname(hItem, classname);
	TF2Items_SetItemIndex(hItem, index);
	TF2Items_SetLevel(hItem, level);
	TF2Items_SetQuality(hItem, quality);
	
	// Set attributes.
	char atts[32][32];
	int count = ExplodeString(att, " ; ", atts, 32, 32);
	if (count > 1)
	{
		TF2Items_SetNumAttributes(hItem, count / 2);
		int i2 = 0;
		for (int i = 0; i < count; i+= 2)
		{
			TF2Items_SetAttribute(hItem, i2, StringToInt(atts[i]), StringToFloat(atts[i+1]));
			i2++;
		}
	}
	else
	{
		TF2Items_SetNumAttributes(hItem, 0);
	}
	
	return hItem;
}
stock void SpecialRoundGameText(const char[] strMessage, const char strIcon[]="")
{
	int iEntity = CreateEntityByName("game_text_tf");
	DispatchKeyValue(iEntity,"message", strMessage);
	DispatchKeyValue(iEntity,"display_to_team", "0");
	DispatchKeyValue(iEntity,"icon", strIcon);
	DispatchKeyValue(iEntity,"targetname", "game_text1");
	DispatchKeyValue(iEntity,"background", "0");
	DispatchSpawn(iEntity);
	AcceptEntityInput(iEntity, "Display", iEntity, iEntity);
	CreateTimer(2.0, Timer_KillEntity, EntIndexToEntRef(iEntity));
}
// Removes wearables such as botkillers from weapons.
stock void TF2_RemoveWeaponSlotAndWearables(int client,int iSlot)
{
	int iWeapon = GetPlayerWeaponSlot(client, iSlot);
	if (!IsValidEntity(iWeapon)) return;
	
	int iWearable = INVALID_ENT_REFERENCE;
	while ((iWearable = FindEntityByClassname(iWearable, "tf_wearable")) != -1)
	{
		int iWeaponAssociated = GetEntPropEnt(iWearable, Prop_Send, "m_hWeaponAssociatedWith");
		if (iWeaponAssociated == iWeapon)
		{
			AcceptEntityInput(iWearable, "Kill");
		}
	}
	
	iWearable = INVALID_ENT_REFERENCE;
	while ((iWearable = FindEntityByClassname(iWearable, "tf_wearable_vm")) != -1)
	{
		int iWeaponAssociated = GetEntPropEnt(iWearable, Prop_Send, "m_hWeaponAssociatedWith");
		if (iWeaponAssociated == iWeapon)
		{
			AcceptEntityInput(iWearable, "Kill");
		}
	}
	
	TF2_RemoveWeaponSlot(client, iSlot);
}

stock void TE_SetupTFParticleEffect(int iParticleSystemIndex, const float flOrigin[3], const float flStart[3]=NULL_VECTOR,int iAttachType=0,int iEntIndex=-1,int iAttachmentPointIndex=0, bool bControlPoint1=false, const float flControlPoint1Offset[3]=NULL_VECTOR)
{
	TE_Start("TFParticleEffect");
	TE_WriteFloat("m_vecOrigin[0]", flOrigin[0]);
	TE_WriteFloat("m_vecOrigin[1]", flOrigin[1]);
	TE_WriteFloat("m_vecOrigin[2]", flOrigin[2]);
	TE_WriteFloat("m_vecStart[0]", flStart[0]);
	TE_WriteFloat("m_vecStart[1]", flStart[1]);
	TE_WriteFloat("m_vecStart[2]", flStart[2]);
	TE_WriteNum("m_iParticleSystemIndex", iParticleSystemIndex);
	TE_WriteNum("m_iAttachType", iAttachType);
	TE_WriteNum("entindex", iEntIndex);
	TE_WriteNum("m_iAttachmentPointIndex", iAttachmentPointIndex);
	TE_WriteNum("m_bControlPoint1", bControlPoint1);
	TE_WriteFloat("m_ControlPoint1.m_vecOffset[0]", flControlPoint1Offset[0]);
	TE_WriteFloat("m_ControlPoint1.m_vecOffset[1]", flControlPoint1Offset[1]);
	TE_WriteFloat("m_ControlPoint1.m_vecOffset[2]", flControlPoint1Offset[2]);
}

//	==========================================================
//	FLOAT FUNCTIONS
//	==========================================================

/**
 *	Converts a given timestamp into hours, minutes, and seconds.
 */
stock void FloatToTimeHMS(float time,int &h=0,int &m=0,int &s=0)
{
	s = RoundFloat(time);
	h = s / 3600;
	s -= h * 3600;
	m = s / 60;
	s = s % 60;
}

stock int FixedUnsigned16(float value,int scale)
{
	int iOutput;
	
	iOutput = RoundToFloor(value * float(scale));
	
	if (iOutput < 0)
	{
		iOutput = 0;
	}
	
	if (iOutput > 0xFFFF)
	{
		iOutput = 0xFFFF;
	}
	
	return iOutput;
}

stock float FloatMin(float a, float b)
{
	if (a < b) return a;
	return b;
}

stock float FloatMax(float a, float b)
{
	if (a > b) return a;
	return b;
}

//	==========================================================
//	VECTOR FUNCTIONS
//	==========================================================

/**
 *	Copies a vector into another vector.
 */
stock void CopyVector(const float flCopy[3], float flDest[3])
{
	flDest[0] = flCopy[0];
	flDest[1] = flCopy[1];
	flDest[2] = flCopy[2];
}

stock void LerpVectors(const float fA[3] , const float fB[3], float fC[3], float t)
{
    if (t < 0.0) t = 0.0;
    if (t > 1.0) t = 1.0;
    
    fC[0] = fA[0] + (fB[0] - fA[0]) * t;
    fC[1] = fA[1] + (fB[1] - fA[1]) * t;
    fC[2] = fA[2] + (fB[2] - fA[2]) * t;
}

/**
 *	Translates and re-orients a given offset vector into world space, given a world position and angle.
 */
stock void VectorTransform(const float offset[3], const float worldpos[3], const float ang[3], float buffer[3])
{
	float fwd[3],right[3], up[3];
	GetAngleVectors(ang, fwd, right, up);
	
	NormalizeVector(fwd, fwd);
	NormalizeVector(right, right);
	NormalizeVector(up, up);
	
	ScaleVector(right, offset[1]);
	ScaleVector(fwd, offset[0]);
	ScaleVector(up, offset[2]);
	
	buffer[0] = worldpos[0] + right[0] + fwd[0] + up[0];
	buffer[1] = worldpos[1] + right[1] + fwd[1] + up[1];
	buffer[2] = worldpos[2] + right[2] + fwd[2] + up[2];
}

//	==========================================================
//	ANGLE FUNCTIONS
//	==========================================================

stock float ApproachAngle(float target, float value, float speed)
{
	float delta = AngleDiff(value, target);
	
	if (speed < 0.0) speed = -speed;
	
	if (delta > speed) value += speed;
	else if (delta < -speed) value -= speed;
	else value = target;
	
	return AngleNormalize(value);
}

stock float AngleNormalize(float angle)
{
	while (angle > 180.0) angle -= 360.0;
	while (angle < -180.0) angle += 360.0;
	return angle;
}

stock float AngleDiff(float firstAngle, float secondAngle)
{
	float diff = secondAngle - firstAngle;
	return AngleNormalize(diff);
}

//	==========================================================
//	PRECACHING FUNCTIONS
//	==========================================================

stock void PrecacheSound2(const char[] path)
{
	PrecacheSound(path, true);
	char buffer[PLATFORM_MAX_PATH];
	Format(buffer, sizeof(buffer), "sound/%s", path);
	AddFileToDownloadsTable(buffer);
}

stock void PrecacheMaterial2(const char[] path)
{
	char buffer[PLATFORM_MAX_PATH];
	Format(buffer, sizeof(buffer), "materials/%s.vmt", path);
	AddFileToDownloadsTable(buffer);
	Format(buffer, sizeof(buffer), "materials/%s.vtf", path);
	AddFileToDownloadsTable(buffer);
}

stock int PrecacheParticleSystem(const char[] particleSystem)
{
	static int particleEffectNames = INVALID_STRING_TABLE;

	if (particleEffectNames == INVALID_STRING_TABLE) {
		if ((particleEffectNames = FindStringTable("ParticleEffectNames")) == INVALID_STRING_TABLE) {
			return INVALID_STRING_INDEX;
		}
	}

	int index = FindStringIndex2(particleEffectNames, particleSystem);
	if (index == INVALID_STRING_INDEX) {
		int numStrings = GetStringTableNumStrings(particleEffectNames);
		if (numStrings >= GetStringTableMaxStrings(particleEffectNames)) {
			return INVALID_STRING_INDEX;
		}
		
		AddToStringTable(particleEffectNames, particleSystem);
		index = numStrings;
	}
	
	return index;
}

stock int FindStringIndex2(int tableidx, const char[] str)
{
	char buf[1024];
	
	int numStrings = GetStringTableNumStrings(tableidx);
	for (int i=0; i < numStrings; i++) {
		ReadStringTable(tableidx, i, buf, sizeof(buf));
		
		if (StrEqual(buf, str)) {
			return i;
		}
	}
	
	return INVALID_STRING_INDEX;
}

stock void InsertNodesAroundPoint(Handle hArray, const float flOrigin[3], float flDist, float flAddAng, Function iCallback=INVALID_FUNCTION, any data=-1)
{
	float flDirection[3];
	float flPos[3];
	
	for (float flAng = 0.0; flAng < 360.0; flAng += flAddAng)
	{
		flDirection[0] = 0.0;
		flDirection[1] = flAng;
		flDirection[2] = 0.0;
		
		GetAngleVectors(flDirection, flDirection, NULL_VECTOR, NULL_VECTOR);
		NormalizeVector(flDirection, flDirection);
		ScaleVector(flDirection, flDist);
		AddVectors(flDirection, flOrigin, flPos);
		
		float flPos2[3];
		for (int i = 0; i < 2; i++) flPos2[i] = flPos[i];
		
		if (iCallback != INVALID_FUNCTION)
		{
			Action iAction = Plugin_Continue;
			
			Call_StartFunction(INVALID_HANDLE, iCallback);
			Call_PushArray(flOrigin, 3);
			Call_PushArrayEx(flPos2, 3, SM_PARAM_COPYBACK);
			Call_PushCell(data);
			Call_Finish(iAction);
			
			if (iAction == Plugin_Stop || iAction == Plugin_Handled) continue;
			else if (iAction == Plugin_Changed)
			{
				for (int i = 0; i < 2; i++) flPos[i] = flPos2[i];
			}
		}
		
		PushArrayArray(hArray, flPos, 3);
	}
}

//	==========================================================
//	TRACE FUNCTIONS
//	==========================================================

public bool TraceRayDontHitEntity(int entity,int mask,any data)
{
	if (entity == data) return false;
	if (IsValidEdict(entity))
	{
		char sClass[64];
		GetEntityNetClass(entity, sClass, sizeof(sClass));
		if (StrEqual(sClass, "CTFBaseBoss")) return false;
	}
	return true;
}

public bool TraceRayDontHitPlayers(int entity,int mask, any data)
{
	if (entity > 0 && entity <= MaxClients) return false;
	if (IsValidEdict(entity))
	{
		char sClass[64];
		GetEntityNetClass(entity, sClass, sizeof(sClass));
		if (StrEqual(sClass, "CTFBaseBoss")) return false;
	}
	return true;
}

public bool TraceRayDontHitPlayersOrEntity(int entity,int mask,any data)
{
	if (entity == data) return false;
	if (entity > 0 && entity <= MaxClients) return false;
	if (IsValidEdict(entity))
	{
		char sClass[64];
		GetEntityNetClass(entity, sClass, sizeof(sClass));
		if (StrEqual(sClass, "CTFBaseBoss")) return false;
	}
	
	return true;
}

//	==========================================================
//	TIMER/CALLBACK FUNCTIONS
//	==========================================================

public Action Timer_KillEntity(Handle timer, any entref)
{
	int ent = EntRefToEntIndex(entref);
	if (ent == INVALID_ENT_REFERENCE) return;
	
	AcceptEntityInput(ent, "Kill");
}

//	==========================================================
//	SPECIAL ROUND FUCNTIONS
//	==========================================================
stock bool IsInfiniteFlashlightEnabled()
{
	return view_as<bool>(g_bRoundInfiniteFlashlight || (GetConVarInt(g_cvPlayerInfiniteFlashlightOverride) == 1) || SF_SpecialRound(SPECIALROUND_INFINITEFLASHLIGHT));
}
stock bool SF_SpecialRound(int specialround)
{
	if(!g_bSpecialRound)
		return false;
	if(specialround==g_iSpecialRoundType)
		return true;
	if(specialround==g_iSpecialRoundType2)
		return true;
	return false;
}