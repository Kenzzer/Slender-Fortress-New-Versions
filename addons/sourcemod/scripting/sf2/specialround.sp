#if defined _sf2_specialround_included
 #endinput
#endif
#define _sf2_specialround_included

#define SR_CYCLELENGTH 10.0
#define SR_STARTDELAY 1.25
#define SR_MUSIC "slender/specialround.mp3"
#define SR_SOUND_SELECT "slender/specialroundselect.mp3"

#define FILE_SPECIALROUNDS "configs/sf2/specialrounds.cfg"

static Handle g_hSpecialRoundCycleNames = INVALID_HANDLE;

static Handle g_hSpecialRoundTimer = INVALID_HANDLE;
static int g_iSpecialRoundCycleNum = 0;
static float g_flSpecialRoundCycleEndTime = -1.0;
static bool bSuprise = false;
static bool g_bStarted = false;
static int doubleroulettecount = 0;
static int g_iSpecialRoundType = 0;

void ReloadSpecialRounds()
{
	if (g_hSpecialRoundCycleNames == INVALID_HANDLE)
	{
		g_hSpecialRoundCycleNames = CreateArray(128);
	}
	
	ClearArray(g_hSpecialRoundCycleNames);

	if (g_hSpecialRoundsConfig != INVALID_HANDLE)
	{
		CloseHandle(g_hSpecialRoundsConfig);
		g_hSpecialRoundsConfig = INVALID_HANDLE;
	}
	
	char buffer[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, buffer, sizeof(buffer), FILE_SPECIALROUNDS);
	Handle kv = CreateKeyValues("root");
	if (!FileToKeyValues(kv, buffer))
	{
		CloseHandle(kv);
		LogError("Failed to load special rounds! File %s not found!", FILE_SPECIALROUNDS);
	}
	else
	{
		g_hSpecialRoundsConfig = kv;
		LogMessage("Loaded special rounds file!");
		
		// Load names for the cycle.
		char sBuffer[128];
		for (int iSpecialRound = SPECIALROUND_DOUBLETROUBLE; iSpecialRound < SPECIALROUND_MAXROUNDS; iSpecialRound++)
		{
			SpecialRoundGetDescriptionHud(iSpecialRound, sBuffer, sizeof(sBuffer));
			PushArrayString(g_hSpecialRoundCycleNames, sBuffer);
		}
		
		KvRewind(kv);
		if (KvJumpToKey(kv, "jokes"))
		{
			if (KvGotoFirstSubKey(kv, false))
			{
				do
				{
					KvGetString(kv, NULL_STRING, sBuffer, sizeof(sBuffer));
					if (strlen(sBuffer) > 0)
					{
						PushArrayString(g_hSpecialRoundCycleNames, sBuffer);
					}
				}
				while (KvGotoNextKey(kv, false));
			}
		}
		
		SortADTArray(g_hSpecialRoundCycleNames, Sort_Random, Sort_String);
	}
}

stock void SpecialRoundGetDescriptionHud(int iSpecialRound, char[] buffer,int bufferlen)
{
	strcopy(buffer, bufferlen, "");

	if (g_hSpecialRoundsConfig == INVALID_HANDLE) return;
	
	KvRewind(g_hSpecialRoundsConfig);
	char sSpecialRound[32];
	IntToString(iSpecialRound, sSpecialRound, sizeof(sSpecialRound));
	
	if (!KvJumpToKey(g_hSpecialRoundsConfig, sSpecialRound)) return;
	
	KvGetString(g_hSpecialRoundsConfig, "display_text_hud", buffer, bufferlen);
}

stock void SpecialRoundGetDescriptionChat(int iSpecialRound, char[] buffer,int bufferlen)
{
	strcopy(buffer, bufferlen, "");

	if (g_hSpecialRoundsConfig == INVALID_HANDLE) return;
	
	KvRewind(g_hSpecialRoundsConfig);
	char sSpecialRound[32];
	IntToString(iSpecialRound, sSpecialRound, sizeof(sSpecialRound));
	
	if (!KvJumpToKey(g_hSpecialRoundsConfig, sSpecialRound)) return;
	
	KvGetString(g_hSpecialRoundsConfig, "display_text_chat", buffer, bufferlen);
}

stock void SpecialRoundGetIconHud(int iSpecialRound, char[] buffer,int bufferlen)
{
	strcopy(buffer, bufferlen, "");

	if (g_hSpecialRoundsConfig == INVALID_HANDLE) return;
	
	KvRewind(g_hSpecialRoundsConfig);
	char sSpecialRound[32];
	IntToString(iSpecialRound, sSpecialRound, sizeof(sSpecialRound));
	
	if (!KvJumpToKey(g_hSpecialRoundsConfig, sSpecialRound)) return;
	
	KvGetString(g_hSpecialRoundsConfig, "display_icon_hud", buffer, bufferlen);
}

stock bool SpecialRoundCanBeSelected(int iSpecialRound)
{
	if (g_hSpecialRoundsConfig == INVALID_HANDLE) return false;
	
	KvRewind(g_hSpecialRoundsConfig);
	char sSpecialRound[32];
	IntToString(iSpecialRound, sSpecialRound, sizeof(sSpecialRound));
	
	if (!KvJumpToKey(g_hSpecialRoundsConfig, sSpecialRound)) return false;
	
	return view_as<bool>(KvGetNum(g_hSpecialRoundsConfig, "enabled", 1));
}

public Action Timer_SpecialRoundCycle(Handle timer)
{
	if (timer != g_hSpecialRoundTimer) return Plugin_Stop;
	
	if (GetGameTime() >= g_flSpecialRoundCycleEndTime)
	{
		SpecialRoundCycleFinish();
		return Plugin_Stop;
	}
	
	char sBuffer[128];
	GetArrayString(g_hSpecialRoundCycleNames, g_iSpecialRoundCycleNum, sBuffer, sizeof(sBuffer));
	
	if(!bSuprise)
		SpecialRoundGameText(sBuffer);
	
	g_iSpecialRoundCycleNum++;
	if (g_iSpecialRoundCycleNum >= GetArraySize(g_hSpecialRoundCycleNames))
	{
		g_iSpecialRoundCycleNum = 0;
	}
	
	return Plugin_Continue;
}

public Action Timer_SpecialRoundStart(Handle timer)
{
	if (timer != g_hSpecialRoundTimer) return;
	if (!g_bSpecialRound) return;
	
	SpecialRoundStart();
}
public Action Timer_SpecialRoundFakeBosses(Handle timer)
{
	if (!g_bSpecialRound) return Plugin_Stop;
	if (!SF_SpecialRound(SPECIALROUND_DREAMFAKEBOSSES)) return Plugin_Stop;
	char sProfile[SF2_MAX_PROFILE_NAME_LENGTH];
	int iFakeBossCount=0;
	for (int i = 0; i < MAX_BOSSES; i++)
	{
		if (NPCGetUniqueID(i) == -1) continue;
		if (NPCGetFlags(i) & SFF_FAKE)
			iFakeBossCount+=1;
	}
	//PrintToChatAll("Fake count: %i",iFakeBossCount);
	if(iFakeBossCount==3) return Plugin_Continue;
	for (int i = 0; i < MAX_BOSSES; i++)
	{
		SF2NPC_BaseNPC Npc = view_as<SF2NPC_BaseNPC>(i);
		if (!Npc.IsValid()) continue;
		if (Npc.Flags & SFF_FAKE)
		{
			continue;
		}
		//Harcoded max of 3 fake bosses
		if(iFakeBossCount==3) break;
		Npc.GetProfile(sProfile, sizeof(sProfile));
		SF2NPC_BaseNPC NpcFake = AddProfile(sProfile, SFF_FAKE, Npc);
		if (!NpcFake.IsValid())
		{
			LogError("Could not add fake boss for %d: No free slots!", i);
		}
		iFakeBossCount+=1;
	}
	//PrintToChatAll("Fake count: %i",iFakeBossCount);
	return Plugin_Continue;
}
	
/*
public Action Timer_SpecialRoundAttribute(Handle timer)
{
	if (timer != g_hSpecialRoundTimer) return Plugin_Stop;
	if (!g_bSpecialRound) return Plugin_Stop;
	
	int iCond = -1;
	
	switch (g_iSpecialRoundType)
	{
		case SPECIALROUND_DEFENSEBUFF: iCond = _:TFCond_DefenseBuffed;
		case SPECIALROUND_MARKEDFORDEATH: iCond = _:TFCond_MarkedForDeath;
	}
	
	if (iCond != -1)
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			if (!IsClientInGame(i) || !IsPlayerAlive(i) || g_bPlayerEliminated[i] || g_bPlayerGhostMode[i]) continue;
			
			TF2_AddCondition(i, view_as<TFCond>(iCond), 0.8);
		}
	}
	
	return Plugin_Continue;
}
*/

void SpecialRoundCycleStart()
{
	if (!g_bSpecialRound) return;
	if(g_bStarted) return;
	
	g_bStarted = true;
	EmitSoundToAll(SR_MUSIC, _, MUSIC_CHAN);
	g_iSpecialRoundType = 0;
	g_iSpecialRoundCycleNum = 0;
	g_flSpecialRoundCycleEndTime = GetGameTime() + SR_CYCLELENGTH;
	g_hSpecialRoundTimer = CreateTimer(0.12, Timer_SpecialRoundCycle, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
}

void SpecialRoundCycleFinish()
{
	EmitSoundToAll(SR_SOUND_SELECT, _, SNDCHAN_AUTO);
	int iOverride = GetConVarInt(g_cvSpecialRoundOverride);
	if (iOverride >= 1 && iOverride < SPECIALROUND_MAXROUNDS)
	{
		g_iSpecialRoundType = iOverride;
	}
	else
	{
		int iPlayers;
		for (int iClient = 1; iClient <= MaxClients; iClient++)
		{
			if (IsValidClient(iClient) && !g_bPlayerEliminated[iClient])
				iPlayers++;
		}
		Handle hEnabledRounds = CreateArray();
		
		if (GetArraySize(GetSelectableBossProfileList()) > 0)
		{
			PushArrayCell(hEnabledRounds, SPECIALROUND_DOUBLETROUBLE);
			PushArrayCell(hEnabledRounds, SPECIALROUND_DOOMBOX);
		}
		
		if (GetActivePlayerCount() <= GetConVarInt(g_cvMaxPlayers) * 2)
		{
			PushArrayCell(hEnabledRounds, SPECIALROUND_DOUBLEMAXPLAYERS);
		}
		if (GetArraySize(GetSelectableBossProfileList()) > 0 && GetActivePlayerCount() <= GetConVarInt(g_cvMaxPlayers) * 2)
		{
			PushArrayCell(hEnabledRounds, SPECIALROUND_2DOUBLE);
		}
		/*
		if (GetActivePlayerCount() > 1)
		{
			PushArrayCell(hEnabledRounds, SPECIALROUND_SINGLEPLAYER);
		}
		*/
		if (!SF_SpecialRound(SPECIALROUND_INSANEDIFFICULTY) && !SF_SpecialRound(SPECIALROUND_DOUBLEMAXPLAYERS) && !SF_SpecialRound(SPECIALROUND_DOUBLETROUBLE) && !SF_SpecialRound(SPECIALROUND_2DOUBLE))
			PushArrayCell(hEnabledRounds, SPECIALROUND_INSANEDIFFICULTY);
		if (!SF_SpecialRound(SPECIALROUND_LIGHTSOUT) && !SF_SpecialRound(SPECIALROUND_INFINITEFLASHLIGHT) && !SF_SpecialRound(SPECIALROUND_NIGHTVISION) && !SF_SpecialRound(SPECIALROUND_NOULTRAVISION))
			PushArrayCell(hEnabledRounds, SPECIALROUND_LIGHTSOUT);
			
		if (!SF_SpecialRound(SPECIALROUND_BEACON))
			PushArrayCell(hEnabledRounds, SPECIALROUND_BEACON);
		
		if (!SF_SpecialRound(SPECIALROUND_NOGRACE) && !SF_SpecialRound(SPECIALROUND_REVOLUTION) && GetRoundState() != SF2RoundState_Intro)
			PushArrayCell(hEnabledRounds, SPECIALROUND_NOGRACE);
			
		if (!SF_SpecialRound(SPECIALROUND_NIGHTVISION) && !GetConVarBool(g_cvNightvisionEnabled) && !SF_SpecialRound(SPECIALROUND_INFINITEFLASHLIGHT) && !SF_SpecialRound(SPECIALROUND_NOULTRAVISION))
			PushArrayCell(hEnabledRounds, SPECIALROUND_NIGHTVISION);
			
		/*if (!SF_SpecialRound(SPECIALROUND_DOUBLEROULETTE))
			PushArrayCell(hEnabledRounds, SPECIALROUND_DOUBLEROULETTE);*/
			
		if (!SF_SpecialRound(SPECIALROUND_INFINITEFLASHLIGHT) && !SF_SpecialRound(SPECIALROUND_LIGHTSOUT) && !SF_SpecialRound(SPECIALROUND_NIGHTVISION) && !SF_SpecialRound(SPECIALROUND_NOULTRAVISION) && !GetConVarBool(g_cvNightvisionEnabled))
			PushArrayCell(hEnabledRounds, SPECIALROUND_INFINITEFLASHLIGHT);
			
		if (!SF_SpecialRound(SPECIALROUND_DREAMFAKEBOSSES))
			PushArrayCell(hEnabledRounds, SPECIALROUND_DREAMFAKEBOSSES);
			
		if (!SF_SpecialRound(SPECIALROUND_EYESONTHECLOACK))
			PushArrayCell(hEnabledRounds, SPECIALROUND_EYESONTHECLOACK);
		
		if (!SF_SpecialRound(SPECIALROUND_NOPAGEBONUS) && g_iPageMax > 2)
			PushArrayCell(hEnabledRounds, SPECIALROUND_NOPAGEBONUS);

		//Disabled
		/*if(g_iPageMax > 2 && !SF_SpecialRound(SPECIALROUND_DUCKS))
			PushArrayCell(hEnabledRounds, SPECIALROUND_DUCKS);*/
		
		if (!SF_SpecialRound(SPECIALROUND_1UP) && !SF_SpecialRound(SPECIALROUND_REVOLUTION))
			PushArrayCell(hEnabledRounds, SPECIALROUND_1UP);
		
		if (g_iPageMax > 2 && !SF_SpecialRound(SPECIALROUND_NOULTRAVISION) && !SF_SpecialRound(SPECIALROUND_LIGHTSOUT) && !SF_SpecialRound(SPECIALROUND_NIGHTVISION))
			PushArrayCell(hEnabledRounds, SPECIALROUND_NOULTRAVISION);
		
		if (!bSuprise && !SF_SpecialRound(SPECIALROUND_DOUBLEROULETTE))
			PushArrayCell(hEnabledRounds, SPECIALROUND_SUPRISE);
		
		if (!SF_SpecialRound(SPECIALROUND_LASTRESORT))
			PushArrayCell(hEnabledRounds, SPECIALROUND_LASTRESORT);
		
		if (!SF_SpecialRound(SPECIALROUND_ESCAPETICKETS) && g_iPageMax > 4)
			PushArrayCell(hEnabledRounds, SPECIALROUND_ESCAPETICKETS);
		
		if (!SF_SpecialRound(SPECIALROUND_REVOLUTION))
			PushArrayCell(hEnabledRounds, SPECIALROUND_REVOLUTION);
		
		if (!SF_SpecialRound(SPECIALROUND_DISTORTION) && iPlayers >= 4)
			PushArrayCell(hEnabledRounds, SPECIALROUND_DISTORTION);
		
		if (!SF_SpecialRound(SPECIALROUND_MULTIEFFECT))
			PushArrayCell(hEnabledRounds, SPECIALROUND_MULTIEFFECT);
			
		g_iSpecialRoundType = GetArrayCell(hEnabledRounds, GetRandomInt(0, GetArraySize(hEnabledRounds) - 1));
		
		CloseHandle(hEnabledRounds);
	}
	SetConVarInt(g_cvSpecialRoundOverride, -1);
	
	if(!bSuprise)
	{
		char sDescHud[64];
		SpecialRoundGetDescriptionHud(g_iSpecialRoundType, sDescHud, sizeof(sDescHud));
			
		char sIconHud[64];
		SpecialRoundGetIconHud(g_iSpecialRoundType, sIconHud, sizeof(sIconHud));
			
		char sDescChat[64];
		SpecialRoundGetDescriptionChat(g_iSpecialRoundType, sDescChat, sizeof(sDescChat));
			
		SpecialRoundGameText(sDescHud, sIconHud);
		CPrintToChatAll("%t", "SF2 Special Round Announce Chat", sDescChat); // For those who are using minimized HUD...
	}
		
	g_hSpecialRoundTimer = CreateTimer(SR_STARTDELAY, Timer_SpecialRoundStart, _, TIMER_FLAG_NO_MAPCHANGE);
}

void SpecialRoundStart()
{
	if (!g_bSpecialRound) return;
	if (g_iSpecialRoundType < 1 || g_iSpecialRoundType >= SPECIALROUND_MAXROUNDS) return;
	g_bStarted = false;
	// What to do with the timer...
	switch (g_iSpecialRoundType)
	{
		/*
		case SPECIALROUND_DEFENSEBUFF, SPECIALROUND_MARKEDFORDEATH:
		{
			g_hSpecialRoundTimer = CreateTimer(0.5, Timer_SpecialRoundAttribute, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
		}
		*/
		default:
		{
			g_hSpecialRoundTimer = INVALID_HANDLE;
		}
	}
	if(SF_SpecialRound(SPECIALROUND_DOUBLEROULETTE))
		doubleroulettecount += 1;
	switch (g_iSpecialRoundType)
	{
		case SPECIALROUND_DOUBLETROUBLE:
		{
			char sBuffer[SF2_MAX_PROFILE_NAME_LENGTH];
			Handle hSelectableBosses = GetSelectableBossProfileList();
			
			if (GetArraySize(hSelectableBosses) > 0)
			{
				GetArrayString(hSelectableBosses, GetRandomInt(0, GetArraySize(hSelectableBosses) - 1), sBuffer, sizeof(sBuffer));
				AddProfile(sBuffer);
			}
			SF_AddSpecialRound(SPECIALROUND_DOUBLETROUBLE);
		}
		case SPECIALROUND_DOOMBOX:
		{
			char sBuffer[SF2_MAX_PROFILE_NAME_LENGTH];
			Handle hSelectableBosses = GetSelectableBossProfileList();
			
			if (GetArraySize(hSelectableBosses) > 0)
			{
				GetArrayString(hSelectableBosses, GetRandomInt(0, GetArraySize(hSelectableBosses) - 1), sBuffer, sizeof(sBuffer));
				AddProfile(sBuffer,_,_,_,false);
				GetArrayString(hSelectableBosses, GetRandomInt(0, GetArraySize(hSelectableBosses) - 1), sBuffer, sizeof(sBuffer));
				AddProfile(sBuffer,_,_,_,false);
			}
			SF_AddSpecialRound(SPECIALROUND_DOOMBOX);
		}
		case SPECIALROUND_INSANEDIFFICULTY:
		{
			SetConVarString(g_cvDifficulty, "3"); // Override difficulty to Insane.
			SF_AddSpecialRound(SPECIALROUND_INSANEDIFFICULTY);
		}
		case SPECIALROUND_NOGRACE:
		{
			SetConVarString(g_cvDifficulty, "2"); // Override difficulty to Hardcore.
			if(g_hRoundGraceTimer!=INVALID_HANDLE)
				TriggerTimer(g_hRoundGraceTimer);
			SF_AddSpecialRound(SPECIALROUND_NOGRACE);
		}
		case SPECIALROUND_SINGLEPLAYER:
		{
			for (int i = 1; i <= MaxClients; i++)
			{
				if (!IsClientInGame(i)) continue;
				
				ClientUpdateListeningFlags(i);
			}
			SF_AddSpecialRound(SPECIALROUND_SINGLEPLAYER);
		}
		case SPECIALROUND_2DOUBLE:
		{
			ForceInNextPlayersInQueue(GetConVarInt(g_cvMaxPlayers));
			SetConVarString(g_cvDifficulty, "3"); // Override difficulty to Insane.
			char sBuffer[SF2_MAX_PROFILE_NAME_LENGTH];
			Handle hSelectableBosses = GetSelectableBossProfileList();
			if (GetArraySize(hSelectableBosses) > 0)
			{
				GetArrayString(hSelectableBosses, GetRandomInt(0, GetArraySize(hSelectableBosses) - 1), sBuffer, sizeof(sBuffer));
				AddProfile(sBuffer);
			}
			SF_AddSpecialRound(SPECIALROUND_2DOUBLE);
		}
		case SPECIALROUND_DOUBLEROULETTE:
		{
			SF_AddSpecialRound(SPECIALROUND_DOUBLEROULETTE);
		}
		case SPECIALROUND_SUPRISE:
		{
			bSuprise=true;
			SpecialRoundCycleStart();
		}
		case SPECIALROUND_DOUBLEMAXPLAYERS:
		{
			ForceInNextPlayersInQueue(GetConVarInt(g_cvMaxPlayers));
			SetConVarString(g_cvDifficulty, "3"); // Override difficulty to Insane.
			SF_AddSpecialRound(SPECIALROUND_DOUBLEMAXPLAYERS);
		}
		case SPECIALROUND_LIGHTSOUT,SPECIALROUND_NIGHTVISION:
		{
			if (g_iSpecialRoundType == SPECIALROUND_LIGHTSOUT)
				SF_AddSpecialRound(SPECIALROUND_LIGHTSOUT);
			else if (g_iSpecialRoundType == SPECIALROUND_NIGHTVISION)
				SF_AddSpecialRound(SPECIALROUND_NIGHTVISION);
			for (int i = 1; i <= MaxClients; i++)
			{
				if (!IsClientInGame(i)) continue;
				
				if (!g_bPlayerEliminated[i])
				{
					ClientDeactivateUltravision(i);
					ClientResetFlashlight(i);
					ClientActivateUltravision(i);
				}
			}
		}
		case SPECIALROUND_DREAMFAKEBOSSES:
		{
			CreateTimer(2.0,Timer_SpecialRoundFakeBosses,_,TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
			SF_AddSpecialRound(SPECIALROUND_DREAMFAKEBOSSES);
		}
		case SPECIALROUND_EYESONTHECLOACK:
		{
			SF_AddSpecialRound(SPECIALROUND_EYESONTHECLOACK);
		}
		case SPECIALROUND_NOPAGEBONUS:
		{
			SF_AddSpecialRound(SPECIALROUND_NOPAGEBONUS);
		}
		case SPECIALROUND_1UP:
		{
			for (int i = 1; i <= MaxClients; i++)
			{
				if (!IsClientInGame(i)) continue;
				
				if (!g_bPlayerEliminated[i])
				{
					TF2_AddCondition(i,TFCond_PreventDeath,-1.0);
				}
			}
			SF_AddSpecialRound(SPECIALROUND_1UP);
		}
		case SPECIALROUND_NOULTRAVISION:
		{
			for (int i = 1; i <= MaxClients; i++)
			{
				if (!IsClientInGame(i)) continue;
				
				if (!g_bPlayerEliminated[i])
				{
					ClientDeactivateUltravision(i);
				}
			}
			SF_AddSpecialRound(SPECIALROUND_NOULTRAVISION);
		}
		case SPECIALROUND_DUCKS:
		{
			PrecacheModel("models/workshop/player/items/pyro/eotl_ducky/eotl_bonus_duck.mdl");
			float vecPos[3], vecAng[3];
			char targetName[64];
			int i;
			int iPage = MaxClients+1;
			while((iPage = FindEntityByClassname(iPage, "prop_dynamic_override")) > MaxClients)
			{
				GetEntPropString(iPage, Prop_Data, "m_iName", targetName, sizeof(targetName));
				if(StrEqual(targetName, "sf2_page_ex"))
				{
					AcceptEntityInput(iPage, "Kill");
				}
				PrintToChatAll("Name:%s",targetName);
				if(!StrEqual(targetName, "sf2_page_ex") && StrContains(targetName, "sf2_page_", false) != -1)
				{
					PrintToChatAll("found");
					ReplaceString(targetName, sizeof(targetName), "sf2_page_", "");
					i = StringToInt(targetName);
					GetEntPropVector(iPage, Prop_Data, "m_vecAbsOrigin", vecPos);
					GetEntPropVector(iPage, Prop_Data, "m_angAbsRotation", vecAng);
					char pageName[50];
					int page = CreateEntityByName("prop_dynamic_override");
					if (page != -1)
					{
						TeleportEntity(page, vecPos, vecAng, NULL_VECTOR);
						Format(pageName,50,"sf2_page_%i",i);
						DispatchKeyValue(page, "targetname", pageName);
							
						SetEntityModel(page, "models/workshop/player/items/pyro/eotl_ducky/eotl_bonus_duck.mdl");
							
						DispatchKeyValue(page, "solid", "2");
						DispatchSpawn(page);
						ActivateEntity(page);
						SetVariantInt(i);
						AcceptEntityInput(page, "Skin");
						AcceptEntityInput(page, "EnableCollision");
							
						SetEntPropFloat(page, Prop_Send, "m_flModelScale", 1.0);
							
						SetEntProp(page, Prop_Send, "m_fEffects", EF_ITEM_BLINK);
						
						SDKHook(page, SDKHook_OnTakeDamage, Hook_PageOnTakeDamage);
						SDKHook(page, SDKHook_SetTransmit, Hook_SlenderObjectSetTransmit);
					}
					int page2 = CreateEntityByName("prop_dynamic_override");
					if (page2 != -1)
					{
						TeleportEntity(page2, vecPos, vecAng, NULL_VECTOR);
						DispatchKeyValue(page2, "targetname", "sf2_page_ex");
							
						SetEntityModel(page2, "models/workshop/player/items/pyro/eotl_ducky/eotl_bonus_duck.mdl");
							
						DispatchKeyValue(page2, "solid", "0");
						DispatchKeyValue(page2, "parentname", pageName);
						DispatchSpawn(page2);
						ActivateEntity(page2);
						SetVariantInt(i);
						AcceptEntityInput(page2, "Skin");
						AcceptEntityInput(page2, "DisableCollision");
						SetVariantString(pageName);
						AcceptEntityInput(page2, "SetParent");
							
						SetEntPropFloat(page2, Prop_Send, "m_flModelScale", 1.0);
							
						SDKHook(page2, SDKHook_SetTransmit, Hook_SlenderObjectSetTransmitEx);
					}
					AcceptEntityInput(iPage, "Kill");
				}
			}
			SF_AddSpecialRound(SPECIALROUND_DUCKS);
		}
		case SPECIALROUND_REVOLUTION:
		{
			SF_AddSpecialRound(SPECIALROUND_REVOLUTION);
			g_iSpecialRoundTime = 0;
		}
		case SPECIALROUND_ESCAPETICKETS:
		{
			SF_AddSpecialRound(SPECIALROUND_ESCAPETICKETS);
		}
		case SPECIALROUND_DISTORTION:
		{
			SF_AddSpecialRound(SPECIALROUND_DISTORTION);
		}
		case SPECIALROUND_MULTIEFFECT:
		{
			SF_AddSpecialRound(SPECIALROUND_MULTIEFFECT);
		}
	}
	if(doubleroulettecount==2)
	{
		doubleroulettecount=0;
		SF_RemoveSpecialRound(SPECIALROUND_DOUBLEROULETTE);
	}
	if(SF_SpecialRound(SPECIALROUND_DOUBLEROULETTE))
		SpecialRoundCycleStart();
}

public Action Timer_DisplaySpecialRound(Handle timer)
{
	char sDescHud[64];
	SpecialRoundGetDescriptionHud(g_iSpecialRoundType, sDescHud, sizeof(sDescHud));
	
	char sIconHud[64];
	SpecialRoundGetIconHud(g_iSpecialRoundType, sIconHud, sizeof(sIconHud));
	
	char sDescChat[64];
	SpecialRoundGetDescriptionChat(g_iSpecialRoundType, sDescChat, sizeof(sDescChat));
	
	SpecialRoundGameText(sDescHud, sIconHud);
	CPrintToChatAll("%t", "SF2 Special Round Announce Chat", sDescChat); // For those who are using minimized HUD...
}
void SpecialRound_RoundEnd()
{
	bSuprise = false;
	g_bStarted = false;
	SF_RemoveAllSpecialRound();
}
void SpecialRoundReset()
{
	g_iSpecialRoundType = 0;
	g_hSpecialRoundTimer = INVALID_HANDLE;
	g_iSpecialRoundCycleNum = 0;
	g_flSpecialRoundCycleEndTime = -1.0;
}

bool IsSpecialRoundRunning()
{
	return g_bSpecialRound;
}

public void SpecialRoundInitializeAPI()
{
	CreateNative("SF2_IsSpecialRoundRunning", Native_IsSpecialRoundRunning);
	CreateNative("SF2_GetSpecialRoundType", Native_GetSpecialRoundType);
}

public int Native_IsSpecialRoundRunning(Handle plugin,int numParams)
{
	return view_as<bool>(g_bSpecialRound);
}

public int Native_GetSpecialRoundType(Handle plugin,int numParams)
{
	return g_iSpecialRoundType;
}