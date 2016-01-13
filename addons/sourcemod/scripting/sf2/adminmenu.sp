#if defined _sf2_adminmenu_included
 #endinput
#endif
#define _sf2_adminmenu_included

static Handle:g_hTopMenu = INVALID_HANDLE;
static g_iPlayerAdminMenuTargetUserId[MAXPLAYERS + 1] = { -1, ... };

SetupAdminMenu()
{
	/* Account for late loading */
	new Handle:hTopMenu = INVALID_HANDLE;
	if (LibraryExists("adminmenu") && ((hTopMenu = GetAdminTopMenu()) != INVALID_HANDLE))
	{
		OnAdminMenuReady(hTopMenu);
	}
}


public OnAdminMenuReady(Handle:hTopMenu)
{
	if (hTopMenu == g_hTopMenu) return;
	
	g_hTopMenu = hTopMenu;
	
	new TopMenuObject:hServerCommands = FindTopMenuCategory(hTopMenu, ADMINMENU_SERVERCOMMANDS);
	if (hServerCommands != INVALID_TOPMENUOBJECT)
	{
		AddToTopMenu(hTopMenu, "sf2_boss_admin_main", TopMenuObject_Item, AdminTopMenu_BossMain, hServerCommands, "sm_sf2_add_boss", ADMFLAG_SLAY);
	}
	
	new TopMenuObject:hPlayerCommands = FindTopMenuCategory(hTopMenu, ADMINMENU_PLAYERCOMMANDS);
	if (hPlayerCommands != INVALID_TOPMENUOBJECT)
	{
		AddToTopMenu(hTopMenu, "sf2_player_setplaystate", TopMenuObject_Item, AdminTopMenu_PlayerSetPlayState, hPlayerCommands, "sm_sf2_setplaystate", ADMFLAG_SLAY);
		AddToTopMenu(hTopMenu, "sf2_player_force_proxy", TopMenuObject_Item, AdminTopMenu_PlayerForceProxy, hPlayerCommands, "sm_sf2_force_proxy", ADMFLAG_SLAY);
	}
}

static DisplayPlayerForceProxyAdminMenu(client)
{
	new Handle:hMenu = CreateMenu(AdminMenu_PlayerForceProxy);
	SetMenuTitle(hMenu, "%t%T\n \n", "SF2 Prefix", "SF2 Admin Menu Player Force Proxy", client);
	AddTargetsToMenu(hMenu, client);
	SetMenuExitBackButton(hMenu, true);
	DisplayMenu(hMenu, client, MENU_TIME_FOREVER);
}

public AdminTopMenu_PlayerForceProxy(Handle:topmenu, TopMenuAction:action, TopMenuObject:object_id, param, String:buffer[], maxlength)
{
	if (action == TopMenuAction_DisplayOption)
	{
		Format(buffer, maxlength, "%t%T", "SF2 Prefix", "SF2 Admin Menu Player Force Proxy", param);
	}
	else if (action == TopMenuAction_SelectOption)
	{
		DisplayPlayerForceProxyAdminMenu(param);
	}
}

public AdminMenu_PlayerForceProxy(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
	else if (action == MenuAction_Cancel)
	{
		if (param2 == MenuCancel_ExitBack && g_hTopMenu != INVALID_HANDLE)
		{
			DisplayTopMenu(g_hTopMenu, param1, TopMenuPosition_LastCategory);
		}
	}
	else if (action == MenuAction_Select)
	{
		decl String:sUserId[64];
		GetMenuItem(menu, param2, sUserId, sizeof(sUserId));
		
		new client = GetClientOfUserId(StringToInt(sUserId));
		if (client <= 0)
		{
			CPrintToChat(param1, "%t%T", "SF2 Prefix", "SF2 Player Does Not Exist", param1);
			DisplayPlayerForceProxyAdminMenu(param1);
		}
		else
		{
			g_iPlayerAdminMenuTargetUserId[param1] = StringToInt(sUserId);
		
			decl String:sName[MAX_NAME_LENGTH];
			GetClientName(client, sName, sizeof(sName));
			
			new Handle:hMenu = CreateMenu(AdminMenu_PlayerForceProxyBoss);
			if (!AddBossTargetsToMenu(hMenu))
			{
				CloseHandle(hMenu);
				DisplayTopMenu(g_hTopMenu, param1, TopMenuPosition_LastCategory);
				CPrintToChat(param1, "%t%T", "SF2 Prefix", "SF2 No Active Bosses", param1);
			}
			else
			{
				SetMenuTitle(hMenu, "%t%T\n \n", "SF2 Prefix", "SF2 Admin Menu Player Force Proxy Boss", param1, sName);
				SetMenuExitBackButton(hMenu, true);
				DisplayMenu(hMenu, param1, MENU_TIME_FOREVER);
			}
		}
	}
}

public AdminMenu_PlayerForceProxyBoss(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
	else if (action == MenuAction_Cancel)
	{
		if (param2 == MenuCancel_ExitBack)
		{
			DisplayPlayerForceProxyAdminMenu(param1);
		}
	}
	else if (action == MenuAction_Select)
	{
		new client = GetClientOfUserId(g_iPlayerAdminMenuTargetUserId[param1]);
		if (client <= 0)
		{
			CPrintToChat(param1, "%t%T", "SF2 Prefix", "SF2 Player Does Not Exist", param1);
		}
		else
		{
			decl String:sID[64];
			GetMenuItem(menu, param2, sID, sizeof(sID));
			new iIndex = NPCGetFromUniqueID(StringToInt(sID));
			if (iIndex == -1)
			{
				CPrintToChat(param1, "%t%T", "SF2 Prefix", "SF2 Boss Does Not Exist", param1);
			}
			else
			{
				decl String:sProfile[SF2_MAX_PROFILE_NAME_LENGTH];
				NPCGetProfile(iIndex, sProfile, sizeof(sProfile));
			
				if (!bool:GetProfileNum(sProfile, "proxies", 0) ||
					g_iSlenderCopyMaster[iIndex] != -1)
				{
					CPrintToChat(param1, "%t%T", "SF2 Prefix", "SF2 Boss Not Allowed To Have Proxies", param1);
				}
				else if (!g_bPlayerEliminated[client])
				{
					CPrintToChat(param1, "%t%T", "SF2 Prefix", "SF2 Player In Game", param1);
				}
				else if (g_bPlayerProxy[param1])
				{
					CPrintToChat(param1, "%t%T", "SF2 Prefix", "SF2 Player Already A Proxy", param1);
				}
				else
				{
					FakeClientCommand(param1, "sm_sf2_force_proxy #%d %d", g_iPlayerAdminMenuTargetUserId[param1], iIndex);
				}
			}
		}
		
		DisplayPlayerForceProxyAdminMenu(param1);
	}
}

static DisplayPlayerSetPlayStateAdminMenu(client)
{
	new Handle:hMenu = CreateMenu(AdminMenu_PlayerSetPlayState);
	SetMenuTitle(hMenu, "%t%T\n \n", "SF2 Prefix", "SF2 Admin Menu Player Set Play State", client);
	AddTargetsToMenu(hMenu, client);
	SetMenuExitBackButton(hMenu, true);
	DisplayMenu(hMenu, client, MENU_TIME_FOREVER);
}

public AdminTopMenu_PlayerSetPlayState(Handle:topmenu, TopMenuAction:action, TopMenuObject:object_id, param, String:buffer[], maxlength)
{
	if (action == TopMenuAction_DisplayOption)
	{
		Format(buffer, maxlength, "%t%T", "SF2 Prefix", "SF2 Admin Menu Player Set Play State", param);
	}
	else if (action == TopMenuAction_SelectOption)
	{
		DisplayPlayerSetPlayStateAdminMenu(param);
	}
}

public AdminMenu_PlayerSetPlayState(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
	else if (action == MenuAction_Cancel)
	{
		if (param2 == MenuCancel_ExitBack && g_hTopMenu != INVALID_HANDLE)
		{
			DisplayTopMenu(g_hTopMenu, param1, TopMenuPosition_LastCategory);
		}
	}
	else if (action == MenuAction_Select)
	{
		decl String:sUserId[64];
		GetMenuItem(menu, param2, sUserId, sizeof(sUserId));
		new client = GetClientOfUserId(StringToInt(sUserId));
		if (client <= 0)
		{
			CPrintToChat(param1, "%t%T", "SF2 Prefix", "SF2 Player Does Not Exist", param1);
			DisplayPlayerSetPlayStateAdminMenu(param1);
		}
		else
		{
			decl String:sName[MAX_NAME_LENGTH];
			GetClientName(client, sName, sizeof(sName));
			
			new Handle:hMenu = CreateMenu(AdminMenu_PlayerSetPlayStateConfirm);
			SetMenuTitle(hMenu, "%t%T\n \n", "SF2 Prefix", "SF2 Admin Menu Player Set Play State Confirm", param1, sName);
			decl String:sBuffer[256];
			Format(sBuffer, sizeof(sBuffer), "%T", "SF2 In", param1);
			AddMenuItem(hMenu, sUserId, sBuffer);
			Format(sBuffer, sizeof(sBuffer), "%T", "SF2 Out", param1);
			AddMenuItem(hMenu, sUserId, sBuffer);
			SetMenuExitBackButton(hMenu, true);
			DisplayMenu(hMenu, param1, MENU_TIME_FOREVER);
		}
	}
}

public AdminMenu_PlayerSetPlayStateConfirm(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
	else if (action == MenuAction_Cancel)
	{
		if (param2 == MenuCancel_ExitBack)
		{
			DisplayPlayerSetPlayStateAdminMenu(param1);
		}
	}
	else if (action == MenuAction_Select)
	{
		decl String:sUserId[64];
		GetMenuItem(menu, param2, sUserId, sizeof(sUserId));
		new client = GetClientOfUserId(StringToInt(sUserId));
		if (client <= 0)
		{
			CPrintToChat(param1, "%t%T", "SF2 Prefix", "SF2 Player Does Not Exist", param1);
		}
		else
		{
			new iUserId = StringToInt(sUserId);
			switch (param2)
			{
				case 0: FakeClientCommand(param1, "sm_sf2_setplaystate #%d 1", iUserId);
				case 1: FakeClientCommand(param1, "sm_sf2_setplaystate #%d 0", iUserId);
			}
		}
		
		DisplayPlayerSetPlayStateAdminMenu(param1);
	}
}

static DisplayBossMainAdminMenu(client)
{
	new Handle:hMenu = CreateMenu(AdminMenu_BossMain);
	SetMenuTitle(hMenu, "%t%T\n \n", "SF2 Prefix", "SF2 Admin Menu Boss Main", client);
	
	decl String:sBuffer[512];
	Format(sBuffer, sizeof(sBuffer), "%T", "SF2 Admin Menu Add Boss", client);
	AddMenuItem(hMenu, "add_boss", sBuffer);
	Format(sBuffer, sizeof(sBuffer), "%T", "SF2 Admin Menu Add Fake Boss", client);
	AddMenuItem(hMenu, "add_boss_fake", sBuffer);
	Format(sBuffer, sizeof(sBuffer), "%T", "SF2 Admin Menu Remove Boss", client);
	AddMenuItem(hMenu, "remove_boss", sBuffer);
	Format(sBuffer, sizeof(sBuffer), "%T", "SF2 Admin Menu Spawn Boss", client);
	AddMenuItem(hMenu, "spawn_boss", sBuffer);
	Format(sBuffer, sizeof(sBuffer), "%T", "SF2 Admin Menu Boss Attack Waiters", client);
	AddMenuItem(hMenu, "boss_attack_waiters", sBuffer);
	Format(sBuffer, sizeof(sBuffer), "%T", "SF2 Admin Menu Boss Teleport", client);
	AddMenuItem(hMenu, "boss_no_teleport", sBuffer);
	Format(sBuffer, sizeof(sBuffer), "%T", "SF2 Admin Menu Override Boss", client);
	AddMenuItem(hMenu, "override_boss", sBuffer);
	
	
	SetMenuExitBackButton(hMenu, true);
	DisplayMenu(hMenu, client, MENU_TIME_FOREVER);
}

public AdminMenu_BossMain(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
	else if (action == MenuAction_Cancel)
	{
		if (param2 == MenuCancel_ExitBack && g_hTopMenu != INVALID_HANDLE)
		{
			DisplayTopMenu(g_hTopMenu, param1, TopMenuPosition_LastCategory);
		}
	}
	else if (action == MenuAction_Select)
	{
		decl String:sInfo[64];
		GetMenuItem(menu, param2, sInfo, sizeof(sInfo));
		if (StrEqual(sInfo, "add_boss"))
		{
			DisplayAddBossAdminMenu(param1);
		}
		else if (StrEqual(sInfo, "add_boss_fake"))
		{
			DisplayAddFakeBossAdminMenu(param1);
		}
		else if (StrEqual(sInfo, "remove_boss"))
		{
			DisplayRemoveBossAdminMenu(param1);
		}
		else if (StrEqual(sInfo, "spawn_boss"))
		{
			DisplaySpawnBossAdminMenu(param1);
		}
		else if (StrEqual(sInfo, "boss_attack_waiters"))
		{
			DisplayBossAttackWaitersAdminMenu(param1);
		}
		else if (StrEqual(sInfo, "boss_no_teleport"))
		{
			DisplayBossTeleportAdminMenu(param1);
		}
		else if (StrEqual(sInfo, "override_boss"))
		{
			DisplayOverrideBossAdminMenu(param1);
		}
	}
}

public AdminTopMenu_BossMain(Handle:topmenu, TopMenuAction:action, TopMenuObject:object_id, param, String:buffer[], maxlength)
{
	if (action == TopMenuAction_DisplayOption)
	{
		Format(buffer, maxlength, "%t%T", "SF2 Prefix", "SF2 Admin Menu Boss Main", param);
	}
	else if (action == TopMenuAction_SelectOption)
	{
		DisplayBossMainAdminMenu(param);
	}
}

static bool:DisplayAddBossAdminMenu(client)
{
	if (g_hConfig != INVALID_HANDLE)
	{
		KvRewind(g_hConfig);
		if (KvGotoFirstSubKey(g_hConfig))
		{
			new Handle:hMenu = CreateMenu(AdminMenu_AddBoss);
			SetMenuTitle(hMenu, "%t%T\n \n", "SF2 Prefix", "SF2 Admin Menu Add Boss", client);
			
			decl String:sProfile[SF2_MAX_PROFILE_NAME_LENGTH];
			decl String:sDisplayName[SF2_MAX_NAME_LENGTH];
			
			do
			{
				KvGetSectionName(g_hConfig, sProfile, sizeof(sProfile));
				KvGetString(g_hConfig, "name", sDisplayName, sizeof(sDisplayName));
				if (!sDisplayName[0]) strcopy(sDisplayName, sizeof(sDisplayName), sProfile);
				AddMenuItem(hMenu, sProfile, sDisplayName);
			}
			while (KvGotoNextKey(g_hConfig));
			
			SetMenuExitBackButton(hMenu, true);
			
			DisplayMenu(hMenu, client, MENU_TIME_FOREVER);
			
			return true;
		}
	}
	
	DisplayBossMainAdminMenu(client);
	return false;
}

public AdminMenu_AddBoss(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
	else if (action == MenuAction_Cancel)
	{
		if (param2 == MenuCancel_ExitBack)
		{
			DisplayBossMainAdminMenu(param1);
		}
	}
	else if (action == MenuAction_Select)
	{
		decl String:sProfile[SF2_MAX_PROFILE_NAME_LENGTH];
		GetMenuItem(menu, param2, sProfile, sizeof(sProfile));
		
		FakeClientCommand(param1, "sm_sf2_add_boss %s", sProfile);
		
		DisplayAddBossAdminMenu(param1);
	}
}

static bool:DisplayAddFakeBossAdminMenu(client)
{
	if (g_hConfig != INVALID_HANDLE)
	{
		KvRewind(g_hConfig);
		if (KvGotoFirstSubKey(g_hConfig))
		{
			new Handle:hMenu = CreateMenu(AdminMenu_AddFakeBoss);
			SetMenuTitle(hMenu, "%t%T\n \n", "SF2 Prefix", "SF2 Admin Menu Add Fake Boss", client);
			
			decl String:sProfile[SF2_MAX_PROFILE_NAME_LENGTH];
			decl String:sDisplayName[SF2_MAX_NAME_LENGTH];
			
			do
			{
				KvGetSectionName(g_hConfig, sProfile, sizeof(sProfile));
				KvGetString(g_hConfig, "name", sDisplayName, sizeof(sDisplayName));
				if (!sDisplayName[0]) strcopy(sDisplayName, sizeof(sDisplayName), sProfile);
				AddMenuItem(hMenu, sProfile, sDisplayName);
			}
			while (KvGotoNextKey(g_hConfig));
			
			SetMenuExitBackButton(hMenu, true);
			
			DisplayMenu(hMenu, client, MENU_TIME_FOREVER);
			
			return true;
		}
	}
	
	DisplayBossMainAdminMenu(client);
	return false;
}

public AdminMenu_AddFakeBoss(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
	else if (action == MenuAction_Cancel)
	{
		if (param2 == MenuCancel_ExitBack)
		{
			DisplayBossMainAdminMenu(param1);
		}
	}
	else if (action == MenuAction_Select)
	{
		decl String:sProfile[SF2_MAX_PROFILE_NAME_LENGTH];
		GetMenuItem(menu, param2, sProfile, sizeof(sProfile));
		
		FakeClientCommand(param1, "sm_sf2_add_boss_fake %s", sProfile);
		
		DisplayAddFakeBossAdminMenu(param1);
	}
}

static AddBossTargetsToMenu(Handle:hMenu)
{
	if (g_hConfig == INVALID_HANDLE) return 0;
	
	KvRewind(g_hConfig);
	if (!KvGotoFirstSubKey(g_hConfig)) return 0;
	
	decl String:sBuffer[512];
	decl String:sDisplay[512], String:sInfo[64];
	
	decl String:sProfile[SF2_MAX_PROFILE_NAME_LENGTH];
	new iCount;
	
	for (new i = 0; i < MAX_BOSSES; i++)
	{
		new iUniqueID = NPCGetUniqueID(i);
		if (iUniqueID == -1) continue;
		
		NPCGetProfile(i, sProfile, sizeof(sProfile));
		
		GetProfileString(sProfile, "name", sBuffer, sizeof(sBuffer));
		if (strlen(sBuffer) == 0) strcopy(sBuffer, sizeof(sBuffer), sProfile);
		
		Format(sDisplay, sizeof(sDisplay), "%d - %s", i, sBuffer);
		if (g_iSlenderCopyMaster[i] != -1)
		{
			Format(sBuffer, sizeof(sBuffer), " (copy of boss %d)", g_iSlenderCopyMaster[i]);
			StrCat(sDisplay, sizeof(sDisplay), sBuffer);
		}
		
		if (NPCGetFlags(i) & SFF_FAKE)
		{
			StrCat(sDisplay, sizeof(sDisplay), " (fake)");
		}
		
		IntToString(iUniqueID, sInfo, sizeof(sInfo));
		
		AddMenuItem(hMenu, sInfo, sDisplay);
		iCount++;
	}
	
	return iCount;
}

static bool:DisplayRemoveBossAdminMenu(client)
{
	if (g_hConfig != INVALID_HANDLE)
	{
		KvRewind(g_hConfig);
		if (KvGotoFirstSubKey(g_hConfig))
		{
			new Handle:hMenu = CreateMenu(AdminMenu_RemoveBoss);
			if (!AddBossTargetsToMenu(hMenu))
			{
				CloseHandle(hMenu);
				CPrintToChat(client, "%t%T", "SF2 Prefix", "SF2 No Active Bosses", client);
			}
			else
			{
				SetMenuTitle(hMenu, "%t%T\n \n", "SF2 Prefix", "SF2 Admin Menu Remove Boss", client);
				SetMenuExitBackButton(hMenu, true);
				DisplayMenu(hMenu, client, MENU_TIME_FOREVER);
				return true;
			}
		}
	}
	
	DisplayBossMainAdminMenu(client);
	return false;
}

public AdminMenu_RemoveBoss(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
	else if (action == MenuAction_Cancel)
	{
		if (param2 == MenuCancel_ExitBack)
		{
			DisplayBossMainAdminMenu(param1);
		}
	}
	else if (action == MenuAction_Select)
	{
		decl String:sID[64];
		GetMenuItem(menu, param2, sID, sizeof(sID));
		new iIndex = NPCGetFromUniqueID(StringToInt(sID));
		if (iIndex == -1)
		{
			CPrintToChat(param1, "%t%T", "SF2 Prefix", "SF2 Boss Does Not Exist", param1);
		}
		else
		{
			FakeClientCommand(param1, "sm_sf2_remove_boss %d", iIndex);
		}
		
		DisplayRemoveBossAdminMenu(param1);
	}
}

static bool:DisplaySpawnBossAdminMenu(client)
{
	if (g_hConfig != INVALID_HANDLE)
	{
		KvRewind(g_hConfig);
		if (KvGotoFirstSubKey(g_hConfig))
		{
			new Handle:hMenu = CreateMenu(AdminMenu_SpawnBoss);
			if (!AddBossTargetsToMenu(hMenu))
			{
				CloseHandle(hMenu);
				CPrintToChat(client, "%t%T", "SF2 Prefix", "SF2 No Active Bosses", client);
			}
			else
			{
				SetMenuTitle(hMenu, "%t%T\n \n", "SF2 Prefix", "SF2 Admin Menu Spawn Boss", client);
				SetMenuExitBackButton(hMenu, true);
				DisplayMenu(hMenu, client, MENU_TIME_FOREVER);
				return true;
			}
		}
	}
	
	DisplayBossMainAdminMenu(client);
	return false;
}

public AdminMenu_SpawnBoss(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
	else if (action == MenuAction_Cancel)
	{
		if (param2 == MenuCancel_ExitBack)
		{
			DisplayBossMainAdminMenu(param1);
		}
	}
	else if (action == MenuAction_Select)
	{
		decl String:sID[64];
		GetMenuItem(menu, param2, sID, sizeof(sID));
		new iIndex = NPCGetFromUniqueID(StringToInt(sID));
		if (iIndex == -1)
		{
			CPrintToChat(param1, "%t%T", "SF2 Prefix", "SF2 Boss Does Not Exist", param1);
		}
		else
		{
			FakeClientCommand(param1, "sm_sf2_spawn_boss %d", iIndex);
		}
		
		DisplaySpawnBossAdminMenu(param1);
	}
}

static bool:DisplayBossAttackWaitersAdminMenu(client)
{
	if (g_hConfig != INVALID_HANDLE)
	{
		KvRewind(g_hConfig);
		if (KvGotoFirstSubKey(g_hConfig))
		{
			new Handle:hMenu = CreateMenu(AdminMenu_BossAttackWaiters);
			if (!AddBossTargetsToMenu(hMenu))
			{
				CloseHandle(hMenu);
				CPrintToChat(client, "%t%T", "SF2 Prefix", "SF2 No Active Bosses", client);
			}
			else
			{
				SetMenuTitle(hMenu, "%t%T\n \n", "SF2 Prefix", "SF2 Admin Menu Boss Attack Waiters", client);
				SetMenuExitBackButton(hMenu, true);
				DisplayMenu(hMenu, client, MENU_TIME_FOREVER);
				return true;
			}
		}
	}
	
	DisplayBossMainAdminMenu(client);
	return false;
}

public AdminMenu_BossAttackWaiters(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
	else if (action == MenuAction_Cancel)
	{
		if (param2 == MenuCancel_ExitBack)
		{
			DisplayBossMainAdminMenu(param1);
		}
	}
	else if (action == MenuAction_Select)
	{
		decl String:sID[64];
		GetMenuItem(menu, param2, sID, sizeof(sID));
		new iIndex = NPCGetFromUniqueID(StringToInt(sID));
		if (iIndex == -1)
		{
			CPrintToChat(param1, "%t%T", "SF2 Prefix", "SF2 Boss Does Not Exist", param1);
			DisplayBossAttackWaitersAdminMenu(param1);
		}
		else
		{
			decl String:sProfile[SF2_MAX_PROFILE_NAME_LENGTH];
			NPCGetProfile(iIndex, sProfile, sizeof(sProfile));
		
			decl String:sName[SF2_MAX_NAME_LENGTH];
			GetProfileString(sProfile, "name", sName, sizeof(sName));
			if (!sName[0]) strcopy(sName, sizeof(sName), sProfile);
			
			new Handle:hMenu = CreateMenu(AdminMenu_BossAttackWaitersConfirm);
			SetMenuTitle(hMenu, "%t%T\n \n", "SF2 Prefix", "SF2 Admin Menu Boss Attack Waiters Confirm", param1, sName);
			decl String:sBuffer[256];
			Format(sBuffer, sizeof(sBuffer), "%T", "Yes", param1);
			AddMenuItem(hMenu, sID, sBuffer);
			Format(sBuffer, sizeof(sBuffer), "%T", "No", param1);
			AddMenuItem(hMenu, sID, sBuffer);
			SetMenuExitBackButton(hMenu, true);
			DisplayMenu(hMenu, param1, MENU_TIME_FOREVER);
		}
	}
}

public AdminMenu_BossAttackWaitersConfirm(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
	else if (action == MenuAction_Cancel)
	{
		if (param2 == MenuCancel_ExitBack)
		{
			DisplayBossAttackWaitersAdminMenu(param1);
		}
	}
	else if (action == MenuAction_Select)
	{
		decl String:sID[64];
		GetMenuItem(menu, param2, sID, sizeof(sID));
		new iIndex = NPCGetFromUniqueID(StringToInt(sID));
		if (iIndex == -1)
		{
			CPrintToChat(param1, "%t%T", "SF2 Prefix", "SF2 Boss Does Not Exist", param1);
		}
		else
		{
			switch (param2)
			{
				case 0: FakeClientCommand(param1, "sm_sf2_boss_attack_waiters %d 1", iIndex);
				case 1: FakeClientCommand(param1, "sm_sf2_boss_attack_waiters %d 0", iIndex);
			}
		}
		
		DisplayBossAttackWaitersAdminMenu(param1);
	}
}

static bool:DisplayBossTeleportAdminMenu(client)
{
	if (g_hConfig != INVALID_HANDLE)
	{
		KvRewind(g_hConfig);
		if (KvGotoFirstSubKey(g_hConfig))
		{
			new Handle:hMenu = CreateMenu(AdminMenu_BossTeleport);
			if (!AddBossTargetsToMenu(hMenu))
			{
				CloseHandle(hMenu);
				CPrintToChat(client, "%t%T", "SF2 Prefix", "SF2 No Active Bosses", client);
			}
			else
			{
				SetMenuTitle(hMenu, "%t%T\n \n", "SF2 Prefix", "SF2 Admin Menu Boss Teleport", client);
				SetMenuExitBackButton(hMenu, true);
				DisplayMenu(hMenu, client, MENU_TIME_FOREVER);
				return true;
			}
		}
	}
	
	DisplayBossMainAdminMenu(client);
	return false;
}

public AdminMenu_BossTeleport(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
	else if (action == MenuAction_Cancel)
	{
		if (param2 == MenuCancel_ExitBack)
		{
			DisplayBossMainAdminMenu(param1);
		}
	}
	else if (action == MenuAction_Select)
	{
		decl String:sID[64];
		GetMenuItem(menu, param2, sID, sizeof(sID));
		new iIndex = NPCGetFromUniqueID(StringToInt(sID));
		if (iIndex == -1)
		{
			CPrintToChat(param1, "%t%T", "SF2 Prefix", "SF2 Boss Does Not Exist", param1);
			DisplayBossTeleportAdminMenu(param1);
		}
		else
		{
			decl String:sProfile[SF2_MAX_PROFILE_NAME_LENGTH];
			NPCGetProfile(iIndex, sProfile, sizeof(sProfile));
		
			decl String:sName[SF2_MAX_NAME_LENGTH];
			GetProfileString(sProfile, "name", sName, sizeof(sName));
			if (!sName[0]) strcopy(sName, sizeof(sName), sProfile);
			
			new Handle:hMenu = CreateMenu(AdminMenu_BossTeleportConfirm);
			SetMenuTitle(hMenu, "%t%T\n \n", "SF2 Prefix", "SF2 Admin Menu Boss Teleport Confirm", param1, sName);
			decl String:sBuffer[256];
			Format(sBuffer, sizeof(sBuffer), "%T", "Yes", param1);
			AddMenuItem(hMenu, sID, sBuffer);
			Format(sBuffer, sizeof(sBuffer), "%T", "No", param1);
			AddMenuItem(hMenu, sID, sBuffer);
			SetMenuExitBackButton(hMenu, true);
			DisplayMenu(hMenu, param1, MENU_TIME_FOREVER);
		}
	}
}

public AdminMenu_BossTeleportConfirm(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
	else if (action == MenuAction_Cancel)
	{
		if (param2 == MenuCancel_ExitBack)
		{
			DisplayBossTeleportAdminMenu(param1);
		}
	}
	else if (action == MenuAction_Select)
	{
		decl String:sID[64];
		GetMenuItem(menu, param2, sID, sizeof(sID));
		new iIndex = NPCGetFromUniqueID(StringToInt(sID));
		if (iIndex == -1)
		{
			CPrintToChat(param1, "%t%T", "SF2 Prefix", "SF2 Boss Does Not Exist", param1);
		}
		else
		{
			switch (param2)
			{
				case 0: FakeClientCommand(param1, "sm_sf2_boss_no_teleport %d 0", iIndex);
				case 1: FakeClientCommand(param1, "sm_sf2_boss_no_teleport %d 1", iIndex);
			}
		}
		
		DisplayBossTeleportAdminMenu(param1);
	}
}

static bool:DisplayOverrideBossAdminMenu(client)
{
	if (g_hConfig != INVALID_HANDLE)
	{
		KvRewind(g_hConfig);
		if (KvGotoFirstSubKey(g_hConfig))
		{
			new Handle:hMenu = CreateMenu(AdminMenu_OverrideBoss);
			
			decl String:sProfile[SF2_MAX_PROFILE_NAME_LENGTH];
			decl String:sDisplayName[SF2_MAX_NAME_LENGTH];
			
			do
			{
				KvGetSectionName(g_hConfig, sProfile, sizeof(sProfile));
				KvGetString(g_hConfig, "name", sDisplayName, sizeof(sDisplayName));
				if (!sDisplayName[0]) strcopy(sDisplayName, sizeof(sDisplayName), sProfile);
				AddMenuItem(hMenu, sProfile, sDisplayName);
			}
			while (KvGotoNextKey(g_hConfig));
			
			SetMenuExitBackButton(hMenu, true);
			
			new String:sProfileOverride[SF2_MAX_PROFILE_NAME_LENGTH], String:sProfileDisplayName[SF2_MAX_PROFILE_NAME_LENGTH];
			GetConVarString(g_cvBossProfileOverride, sProfileOverride, sizeof(sProfileOverride));
			
			if (strlen(sProfileOverride) > 0 && IsProfileValid(sProfileOverride))
			{
				GetProfileString(sProfileOverride, "name", sProfileDisplayName, sizeof(sProfileDisplayName));
				
				if (strlen(sProfileDisplayName) == 0)
					strcopy(sProfileDisplayName, sizeof(sProfileDisplayName), sProfileOverride)
			}
			else
				strcopy(sProfileDisplayName, sizeof(sProfileDisplayName), "---");
			
			SetMenuTitle(hMenu, "%t%T\n%T\n \n", "SF2 Prefix", "SF2 Admin Menu Override Boss", client, "SF2 Admin Menu Current Boss Override", client, sProfileDisplayName);
			
			DisplayMenu(hMenu, client, MENU_TIME_FOREVER);
			
			return true;
		}
	}
	
	DisplayBossMainAdminMenu(client);
	return false;
}

public AdminMenu_OverrideBoss(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
	else if (action == MenuAction_Cancel)
	{
		if (param2 == MenuCancel_ExitBack)
		{
			DisplayBossMainAdminMenu(param1);
		}
	}
	else if (action == MenuAction_Select)
	{
		decl String:sProfile[SF2_MAX_PROFILE_NAME_LENGTH];
		GetMenuItem(menu, param2, sProfile, sizeof(sProfile));
		
		FakeClientCommand(param1, "sm_cvar sf2_boss_profile_override %s", sProfile);
		
		DisplayOverrideBossAdminMenu(param1);
	}
}