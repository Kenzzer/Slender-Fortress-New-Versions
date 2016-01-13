#if defined _sf2_debug_included
 #endinput
#endif
#define _sf2_debug_included

#if !defined DEBUG
 #endinput
#endif

#define DEBUG_BOSS_TELEPORTATION (1 << 0)
#define DEBUG_BOSS_CHASE (1 << 1)
#define DEBUG_PLAYER_STRESS (1 << 2)
#define DEBUG_PLAYER_ACTION_SLOT (1 << 3)
#define DEBUG_BOSS_PROXIES (1 << 4)

new g_iPlayerDebugFlags[MAXPLAYERS + 1] = { 0, ... };

static String:g_strDebugLogFilePath[512] = "";

new Handle:g_cvDebugDetail = INVALID_HANDLE;
new Handle:g_cvDebugBosses = INVALID_HANDLE;

InitializeDebug()
{
	g_cvDebugDetail = CreateConVar("sf2_debug_detail", "0", "0 = off, 1 = debug only large, expensive functions, 2 = debug more events, 3 = debug client functions");
	g_cvDebugBosses = CreateConVar("sf2_debug_bosses", "0");
	
	RegAdminCmd("sm_sf2_debug_boss_teleport", Command_DebugBossTeleport, ADMFLAG_CHEATS);
	RegAdminCmd("sm_sf2_debug_boss_chase", Command_DebugBossChase, ADMFLAG_CHEATS);
	RegAdminCmd("sm_sf2_debug_player_stress", Command_DebugPlayerStress, ADMFLAG_CHEATS);
	RegAdminCmd("sm_sf2_debug_boss_proxies", Command_DebugBossProxies, ADMFLAG_CHEATS);
}

InitializeDebugLogging()
{
	decl String:sDateSuffix[256];
	FormatTime(sDateSuffix, sizeof(sDateSuffix), "sf2-debug-%Y-%m-%d.log", GetTime());
	
	BuildPath(Path_SM, g_strDebugLogFilePath, sizeof(g_strDebugLogFilePath), "logs/%s", sDateSuffix);
	
	decl String:sMap[64];
	GetCurrentMap(sMap, sizeof(sMap));
	
	DebugMessage("-------- Mapchange to %s -------", sMap);
}

stock DebugMessage(const String:sMessage[], any:...)
{
	decl String:sDebugMessage[1024], String:sTemp[1024];
	VFormat(sTemp, sizeof(sTemp), sMessage, 2);
	Format(sDebugMessage, sizeof(sDebugMessage), "%s", sTemp);
	//LogMessage(sDebugMessage);
	LogToFile(g_strDebugLogFilePath, sDebugMessage);
}

stock SendDebugMessageToPlayer(client, iDebugFlags, iType, const String:sMessage[], any:...)
{
	if (!IsClientInGame(client) || IsFakeClient(client)) return;

	decl String:sMsg[1024];
	VFormat(sMsg, sizeof(sMsg), sMessage, 5);
	
	if (g_iPlayerDebugFlags[client] & iDebugFlags)
	{
		switch (iType)
		{
			case 0: CPrintToChat(client, sMsg);
			case 1: PrintCenterText(client, sMsg);
			case 2: PrintHintText(client, sMsg);
		}
	}
}

stock SendDebugMessageToPlayers(iDebugFlags, iType, const String:sMessage[], any:...)
{
	decl String:sMsg[1024];
	VFormat(sMsg, sizeof(sMsg), sMessage, 4);

	for (new i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i) || IsFakeClient(i)) continue;
		
		if (g_iPlayerDebugFlags[i] & iDebugFlags)
		{
			switch (iType)
			{
				case 0: CPrintToChat(i, sMsg);
				case 1: PrintCenterText(i, sMsg);
				case 2: PrintHintText(i, sMsg);
			}
		}
	}
}

public Action:Command_DebugBossTeleport(client, args)
{
	new bool:bInMode = bool:(g_iPlayerDebugFlags[client] & DEBUG_BOSS_TELEPORTATION);
	if (!bInMode)
	{
		g_iPlayerDebugFlags[client] |= DEBUG_BOSS_TELEPORTATION;
		PrintToChat(client, "Enabled debugging boss teleportation.");
	}
	else
	{
		g_iPlayerDebugFlags[client] &= ~DEBUG_BOSS_TELEPORTATION;
		PrintToChat(client, "Disabled debugging boss teleportation.");
	}
	
	return Plugin_Handled;
}

public Action:Command_DebugBossChase(client, args)
{
	new bool:bInMode = bool:(g_iPlayerDebugFlags[client] & DEBUG_BOSS_CHASE);
	if (!bInMode)
	{
		g_iPlayerDebugFlags[client] |= DEBUG_BOSS_CHASE;
		PrintToChat(client, "Enabled debugging boss chasing.");
	}
	else
	{
		g_iPlayerDebugFlags[client] &= ~DEBUG_BOSS_CHASE;
		PrintToChat(client, "Disabled debugging boss chasing.");
	}
	
	return Plugin_Handled;
}

public Action:Command_DebugPlayerStress(client, args)
{
	new bool:bInMode = bool:(g_iPlayerDebugFlags[client] & DEBUG_PLAYER_STRESS);
	if (!bInMode)
	{
		g_iPlayerDebugFlags[client] |= DEBUG_PLAYER_STRESS;
		PrintToChat(client, "Enabled debugging player stress.");
	}
	else
	{
		g_iPlayerDebugFlags[client] &= ~DEBUG_PLAYER_STRESS;
		PrintToChat(client, "Disabled debugging player stress.");
	}
	
	return Plugin_Handled;
}

public Action:Command_DebugBossProxies(client, args)
{
	new bool:bInMode = bool:(g_iPlayerDebugFlags[client] & DEBUG_BOSS_PROXIES);
	if (!bInMode)
	{
		g_iPlayerDebugFlags[client] |= DEBUG_BOSS_PROXIES;
		PrintToChat(client, "Enabled debugging boss proxies.");
	}
	else
	{
		g_iPlayerDebugFlags[client] &= ~DEBUG_BOSS_PROXIES;
		PrintToChat(client, "Disabled debugging boss proxies.");
	}
	
	return Plugin_Handled;
}