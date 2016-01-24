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
static bool bDoubleRoulette=false;
static int doubleroulettecount=0;

void ReloadSpecialRounds()
{
	g_iSpecialRoundType2 = 0;
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
		SpecialRoundGetDescriptionHud(SPECIALROUND_DOUBLETROUBLE, sBuffer, sizeof(sBuffer));
		PushArrayString(g_hSpecialRoundCycleNames, sBuffer);
		
		SpecialRoundGetDescriptionHud(SPECIALROUND_DOUBLETROUBLE, sBuffer, sizeof(sBuffer));
		PushArrayString(g_hSpecialRoundCycleNames, sBuffer);
		
		SpecialRoundGetDescriptionHud(SPECIALROUND_SINGLEPLAYER, sBuffer, sizeof(sBuffer));
		PushArrayString(g_hSpecialRoundCycleNames, sBuffer);
		
		SpecialRoundGetDescriptionHud(SPECIALROUND_DOUBLEMAXPLAYERS, sBuffer, sizeof(sBuffer));
		PushArrayString(g_hSpecialRoundCycleNames, sBuffer);
		
		SpecialRoundGetDescriptionHud(SPECIALROUND_LIGHTSOUT, sBuffer, sizeof(sBuffer));
		PushArrayString(g_hSpecialRoundCycleNames, sBuffer);
		
		SpecialRoundGetDescriptionHud(SPECIALROUND_BEACON, sBuffer, sizeof(sBuffer));
		PushArrayString(g_hSpecialRoundCycleNames, sBuffer);
		
		SpecialRoundGetDescriptionHud(SPECIALROUND_DOOMBOX, sBuffer, sizeof(sBuffer));
		PushArrayString(g_hSpecialRoundCycleNames, sBuffer);
		
		SpecialRoundGetDescriptionHud(SPECIALROUND_NOGRACE, sBuffer, sizeof(sBuffer));
		PushArrayString(g_hSpecialRoundCycleNames, sBuffer);
		
		SpecialRoundGetDescriptionHud(SPECIALROUND_2DOUBLE, sBuffer, sizeof(sBuffer));
		PushArrayString(g_hSpecialRoundCycleNames, sBuffer);
		
		SpecialRoundGetDescriptionHud(SPECIALROUND_DOUBLEROULETTE, sBuffer, sizeof(sBuffer));
		PushArrayString(g_hSpecialRoundCycleNames, sBuffer);
		
		SpecialRoundGetDescriptionHud(SPECIALROUND_NIGHTVISION, sBuffer, sizeof(sBuffer));
		PushArrayString(g_hSpecialRoundCycleNames, sBuffer);
		
		SpecialRoundGetDescriptionHud(SPECIALROUND_INFINITEFLASHLIGHT, sBuffer, sizeof(sBuffer));
		PushArrayString(g_hSpecialRoundCycleNames, sBuffer);
		
		SpecialRoundGetDescriptionHud(SPECIALROUND_DREAMFAKEBOSSES, sBuffer, sizeof(sBuffer));
		PushArrayString(g_hSpecialRoundCycleNames, sBuffer);
		
		SpecialRoundGetDescriptionHud(SPECIALROUND_EYESONTHECLOACK, sBuffer, sizeof(sBuffer));
		PushArrayString(g_hSpecialRoundCycleNames, sBuffer);
		
		SpecialRoundGetDescriptionHud(SPECIALROUND_NOPAGEBONUS, sBuffer, sizeof(sBuffer));
		PushArrayString(g_hSpecialRoundCycleNames, sBuffer);
		
		
		
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
	
	GameTextTFMessage(sBuffer);
	
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
		if (Npc.IsValid()) continue;
		if (Npc.Flags & SFF_FAKE)
		{
			continue;
		}
		if(iFakeBossCount==3) break;
		Npc.GetProfile(sProfile, sizeof(sProfile));
		SF2NPC_BaseNPC NpcFake = AddProfile(sProfile, SFF_FAKE, Npc);
		if (NpcFake.IsValid())
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
	if(bDoubleRoulette)
	{
		g_iSpecialRoundType2 = g_iSpecialRoundType;
	}
	else
	{
		g_iSpecialRoundType2 = SPECIALROUND_MAXROUNDS;
		g_iSpecialRoundType = g_iSpecialRoundType2;
	}
	EmitSoundToAll(SR_MUSIC, _, MUSIC_CHAN);
	g_iSpecialRoundType = 0;
	g_iSpecialRoundCycleNum = 0;
	g_flSpecialRoundCycleEndTime = GetGameTime() + SR_CYCLELENGTH;
	g_hSpecialRoundTimer = CreateTimer(0.12, Timer_SpecialRoundCycle, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
}

void SpecialRoundCycleFinish()
{
	EmitSoundToAll(SR_SOUND_SELECT, _, SNDCHAN_AUTO);
	if(!bDoubleRoulette)
		g_iSpecialRoundType2 = 0;
	int iOverride = GetConVarInt(g_cvSpecialRoundOverride);
	if (iOverride >= 1 && iOverride < SPECIALROUND_MAXROUNDS)
	{
		g_iSpecialRoundType = iOverride;
	}
	else
	{
		Handle hEnabledRounds = CreateArray();
		
		if (GetArraySize(GetSelectableBossProfileList()) > 0)
		{
			PushArrayCell(hEnabledRounds, SPECIALROUND_DOUBLETROUBLE);
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
		if(!SF_SpecialRound(SPECIALROUND_INSANEDIFFICULTY) && !SF_SpecialRound(SPECIALROUND_DOUBLEMAXPLAYERS) && !SF_SpecialRound(SPECIALROUND_DOUBLETROUBLE) && !SF_SpecialRound(SPECIALROUND_2DOUBLE))
			PushArrayCell(hEnabledRounds, SPECIALROUND_INSANEDIFFICULTY);
		if(!SF_SpecialRound(SPECIALROUND_LIGHTSOUT) && !SF_SpecialRound(SPECIALROUND_INFINITEFLASHLIGHT) && !SF_SpecialRound(SPECIALROUND_NIGHTVISION))
			PushArrayCell(hEnabledRounds, SPECIALROUND_LIGHTSOUT);
			
		if(!SF_SpecialRound(SPECIALROUND_BEACON))
			PushArrayCell(hEnabledRounds, SPECIALROUND_BEACON);
			
		PushArrayCell(hEnabledRounds, SPECIALROUND_DOOMBOX);
		
		if(!SF_SpecialRound(SPECIALROUND_NOGRACE))
			PushArrayCell(hEnabledRounds, SPECIALROUND_NOGRACE);
			
		if(!SF_SpecialRound(SPECIALROUND_NIGHTVISION))
			PushArrayCell(hEnabledRounds, SPECIALROUND_NIGHTVISION);
			
		if(!bDoubleRoulette)
			PushArrayCell(hEnabledRounds, SPECIALROUND_DOUBLEROULETTE);
			
		if(!SF_SpecialRound(SPECIALROUND_INFINITEFLASHLIGHT) && !SF_SpecialRound(SPECIALROUND_LIGHTSOUT) && !SF_SpecialRound(SPECIALROUND_NIGHTVISION))
			PushArrayCell(hEnabledRounds, SPECIALROUND_INFINITEFLASHLIGHT);
			
		if(!SF_SpecialRound(SPECIALROUND_DREAMFAKEBOSSES))
			PushArrayCell(hEnabledRounds, SPECIALROUND_DREAMFAKEBOSSES);
			
		if(!SF_SpecialRound(SPECIALROUND_EYESONTHECLOACK))
			PushArrayCell(hEnabledRounds, SPECIALROUND_EYESONTHECLOACK);
		
		if(!SF_SpecialRound(SPECIALROUND_NOPAGEBONUS) && g_iPageMax > 2)
			PushArrayCell(hEnabledRounds, SPECIALROUND_NOPAGEBONUS);
			
		g_iSpecialRoundType = GetArrayCell(hEnabledRounds, GetRandomInt(0, GetArraySize(hEnabledRounds) - 1));
		
		CloseHandle(hEnabledRounds);
	}
	
	SetConVarInt(g_cvSpecialRoundOverride, -1);
	
	char sDescHud[64];
	SpecialRoundGetDescriptionHud(g_iSpecialRoundType, sDescHud, sizeof(sDescHud));
	
	char sIconHud[64];
	SpecialRoundGetIconHud(g_iSpecialRoundType, sIconHud, sizeof(sIconHud));
	
	char sDescChat[64];
	SpecialRoundGetDescriptionChat(g_iSpecialRoundType, sDescChat, sizeof(sDescChat));
	
	GameTextTFMessage(sDescHud, sIconHud);
	CPrintToChatAll("%t", "SF2 Special Round Announce Chat", sDescChat); // For those who are using minimized HUD...
	
	g_hSpecialRoundTimer = CreateTimer(SR_STARTDELAY, Timer_SpecialRoundStart, _, TIMER_FLAG_NO_MAPCHANGE);
}

void SpecialRoundStart()
{
	if (!g_bSpecialRound) return;
	if (g_iSpecialRoundType < 1 || g_iSpecialRoundType >= SPECIALROUND_MAXROUNDS) return;
	
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
	if(bDoubleRoulette)
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
		}
		case SPECIALROUND_INSANEDIFFICULTY:
		{
			SetConVarString(g_cvDifficulty, "3"); // Override difficulty to Insane.
		}
		case SPECIALROUND_NOGRACE:
		{
			SetConVarString(g_cvDifficulty, "2"); // Override difficulty to Hardcore.
			if(g_hRoundGraceTimer!=INVALID_HANDLE)
				TriggerTimer(g_hRoundGraceTimer);
		}
		case SPECIALROUND_SINGLEPLAYER:
		{
			for (int i = 1; i <= MaxClients; i++)
			{
				if (!IsClientInGame(i)) continue;
				
				ClientUpdateListeningFlags(i);
			}
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
		}
		case SPECIALROUND_DOUBLEROULETTE:
		{
			bDoubleRoulette=true;
		}
		case SPECIALROUND_DOUBLEMAXPLAYERS:
		{
			ForceInNextPlayersInQueue(GetConVarInt(g_cvMaxPlayers));
			SetConVarString(g_cvDifficulty, "3"); // Override difficulty to Insane.
		}
		case SPECIALROUND_LIGHTSOUT,SPECIALROUND_NIGHTVISION:
		{
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
		}
	}
	if(doubleroulettecount==2)
	{
		doubleroulettecount=0;
		bDoubleRoulette=false;
	}
	if(bDoubleRoulette)
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
	
	GameTextTFMessage(sDescHud, sIconHud);
	CPrintToChatAll("%t", "SF2 Special Round Announce Chat", sDescChat); // For those who are using minimized HUD...
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