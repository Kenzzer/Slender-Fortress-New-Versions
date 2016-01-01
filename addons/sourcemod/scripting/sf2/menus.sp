#if defined _sf2_menus
 #endinput
#endif

#define _sf2_menus

new Handle:g_hMenuMain;
new Handle:g_hMenuVoteDifficulty;
new Handle:g_hMenuGhostMode;
new Handle:g_hMenuHelp;
new Handle:g_hMenuHelpObjective;
new Handle:g_hMenuHelpObjective2;
new Handle:g_hMenuHelpCommands;
new Handle:g_hMenuHelpGhostMode;
new Handle:g_hMenuHelpSprinting;
new Handle:g_hMenuHelpControls;
new Handle:g_hMenuHelpClassInfo;
new Handle:g_hMenuSettings;
new Handle:g_hMenuCredits;
new Handle:g_hMenuCredits2;

#include "sf2/playergroups/menus.sp"
#include "sf2/pvp/menus.sp"

SetupMenus()
{
	decl String:buffer[512];
	
	// Create menus.
	g_hMenuMain = CreateMenu(Menu_Main);
	SetMenuTitle(g_hMenuMain, "%t%t\n \n", "SF2 Prefix", "SF2 Main Menu Title");
	Format(buffer, sizeof(buffer), "%t (!slhelp)", "SF2 Help Menu Title");
	AddMenuItem(g_hMenuMain, "0", buffer);
	Format(buffer, sizeof(buffer), "%t (!slnext)", "SF2 Queue Menu Title");
	AddMenuItem(g_hMenuMain, "0", buffer);
	Format(buffer, sizeof(buffer), "%t (!slgroup)", "SF2 Group Main Menu Title");
	AddMenuItem(g_hMenuMain, "0", buffer);
	Format(buffer, sizeof(buffer), "%t (!slghost)", "SF2 Ghost Mode Menu Title");
	AddMenuItem(g_hMenuMain, "0", buffer);
	Format(buffer, sizeof(buffer), "%t (!slsettings)", "SF2 Settings Menu Title");
	AddMenuItem(g_hMenuMain, "0", buffer);
	strcopy(buffer, sizeof(buffer), "Credits (!slcredits)");
	AddMenuItem(g_hMenuMain, "0", buffer);
	
	g_hMenuVoteDifficulty = CreateMenu(Menu_VoteDifficulty);
	SetMenuTitle(g_hMenuVoteDifficulty, "%t%t\n \n", "SF2 Prefix", "SF2 Difficulty Vote Menu Title");
	Format(buffer, sizeof(buffer), "%t", "SF2 Normal Difficulty");
	AddMenuItem(g_hMenuVoteDifficulty, "1", buffer);
	Format(buffer, sizeof(buffer), "%t", "SF2 Hard Difficulty");
	AddMenuItem(g_hMenuVoteDifficulty, "2", buffer);
	Format(buffer, sizeof(buffer), "%t", "SF2 Insane Difficulty");
	AddMenuItem(g_hMenuVoteDifficulty, "3", buffer);
	
	g_hMenuGhostMode = CreateMenu(Menu_GhostMode);
	SetMenuTitle(g_hMenuGhostMode, "%t%t\n \n", "SF2 Prefix", "SF2 Ghost Mode Menu Title");
	Format(buffer, sizeof(buffer), "Enable");
	AddMenuItem(g_hMenuGhostMode, "0", buffer);
	Format(buffer, sizeof(buffer), "Disable");
	AddMenuItem(g_hMenuGhostMode, "1", buffer);
	
	g_hMenuHelp = CreateMenu(Menu_Help);
	SetMenuTitle(g_hMenuHelp, "%t%t\n \n", "SF2 Prefix", "SF2 Help Menu Title");
	Format(buffer, sizeof(buffer), "%t", "SF2 Help Objective Menu Title");
	AddMenuItem(g_hMenuHelp, "0", buffer);
	Format(buffer, sizeof(buffer), "%t", "SF2 Help Commands Menu Title");
	AddMenuItem(g_hMenuHelp, "1", buffer);
	Format(buffer, sizeof(buffer), "%t", "SF2 Help Class Info Menu Title");
	AddMenuItem(g_hMenuHelp, "2", buffer);
	Format(buffer, sizeof(buffer), "%t", "SF2 Help Ghost Mode Menu Title");
	AddMenuItem(g_hMenuHelp, "3", buffer);
	Format(buffer, sizeof(buffer), "%t", "SF2 Help Sprinting And Stamina Menu Title");
	AddMenuItem(g_hMenuHelp, "4", buffer);
	Format(buffer, sizeof(buffer), "%t", "SF2 Help Controls Menu Title");
	AddMenuItem(g_hMenuHelp, "5", buffer);
	SetMenuExitBackButton(g_hMenuHelp, true);
	
	g_hMenuHelpObjective = CreateMenu(Menu_HelpObjective);
	SetMenuTitle(g_hMenuHelpObjective, "%t%t\n \n%t\n \n", "SF2 Prefix", "SF2 Help Objective Menu Title", "SF2 Help Objective Description");
	AddMenuItem(g_hMenuHelpObjective, "0", "Next");
	AddMenuItem(g_hMenuHelpObjective, "1", "Back");
	
	g_hMenuHelpObjective2 = CreateMenu(Menu_HelpObjective2);
	SetMenuTitle(g_hMenuHelpObjective2, "%t%t\n \n%t\n \n", "SF2 Prefix", "SF2 Help Objective Menu Title", "SF2 Help Objective Description 2");
	AddMenuItem(g_hMenuHelpObjective2, "0", "Back");
	
	g_hMenuHelpCommands = CreateMenu(Menu_BackButtonOnly);
	SetMenuTitle(g_hMenuHelpCommands, "%t%t\n \n%t\n \n", "SF2 Prefix", "SF2 Help Commands Menu Title", "SF2 Help Commands Description");
	AddMenuItem(g_hMenuHelpCommands, "0", "Back");
	
	g_hMenuHelpGhostMode = CreateMenu(Menu_BackButtonOnly);
	SetMenuTitle(g_hMenuHelpGhostMode, "%t%t\n \n%t\n \n", "SF2 Prefix", "SF2 Help Ghost Mode Menu Title", "SF2 Help Ghost Mode Description");
	AddMenuItem(g_hMenuHelpGhostMode, "0", "Back");
	
	g_hMenuHelpSprinting = CreateMenu(Menu_BackButtonOnly);
	SetMenuTitle(g_hMenuHelpSprinting, "%t%t\n \n%t\n \n", "SF2 Prefix", "SF2 Help Sprinting And Stamina Menu Title", "SF2 Help Sprinting And Stamina Description");
	AddMenuItem(g_hMenuHelpSprinting, "0", "Back");
	
	g_hMenuHelpControls = CreateMenu(Menu_BackButtonOnly);
	SetMenuTitle(g_hMenuHelpControls, "%t%t\n \n%t\n \n", "SF2 Prefix", "SF2 Help Controls Menu Title", "SF2 Help Controls Description");
	AddMenuItem(g_hMenuHelpControls, "0", "Back");
	
	g_hMenuHelpClassInfo = CreateMenu(Menu_ClassInfo);
	SetMenuTitle(g_hMenuHelpClassInfo, "%t%t\n \n%t\n \n", "SF2 Prefix", "SF2 Help Class Info Menu Title", "SF2 Help Class Info Description");
	Format(buffer, sizeof(buffer), "%t", "SF2 Help Scout Class Info Menu Title");
	AddMenuItem(g_hMenuHelpClassInfo, "Scout", buffer);
	Format(buffer, sizeof(buffer), "%t", "SF2 Help Sniper Class Info Menu Title");
	AddMenuItem(g_hMenuHelpClassInfo, "Sniper", buffer);
	Format(buffer, sizeof(buffer), "%t", "SF2 Help Soldier Class Info Menu Title");
	AddMenuItem(g_hMenuHelpClassInfo, "Soldier", buffer);
	Format(buffer, sizeof(buffer), "%t", "SF2 Help Demoman Class Info Menu Title");
	AddMenuItem(g_hMenuHelpClassInfo, "Demoman", buffer);
	Format(buffer, sizeof(buffer), "%t", "SF2 Help Heavy Class Info Menu Title");
	AddMenuItem(g_hMenuHelpClassInfo, "Heavy", buffer);
	Format(buffer, sizeof(buffer), "%t", "SF2 Help Medic Class Info Menu Title");
	AddMenuItem(g_hMenuHelpClassInfo, "Medic", buffer);
	Format(buffer, sizeof(buffer), "%t", "SF2 Help Pyro Class Info Menu Title");
	AddMenuItem(g_hMenuHelpClassInfo, "Pyro", buffer);
	Format(buffer, sizeof(buffer), "%t", "SF2 Help Spy Class Info Menu Title");
	AddMenuItem(g_hMenuHelpClassInfo, "Spy", buffer);
	Format(buffer, sizeof(buffer), "%t", "SF2 Help Engineer Class Info Menu Title");
	AddMenuItem(g_hMenuHelpClassInfo, "Engineer", buffer);
	SetMenuExitBackButton(g_hMenuHelpClassInfo, true);
	
	g_hMenuSettings = CreateMenu(Menu_Settings);
	SetMenuTitle(g_hMenuSettings, "%t%t\n \n", "SF2 Prefix", "SF2 Settings Menu Title");
	Format(buffer, sizeof(buffer), "%t", "SF2 Settings PvP Menu Title");
	AddMenuItem(g_hMenuSettings, "0", buffer);
	Format(buffer, sizeof(buffer), "%t", "SF2 Settings Hints Menu Title");
	AddMenuItem(g_hMenuSettings, "0", buffer);
	Format(buffer, sizeof(buffer), "%t", "SF2 Settings Mute Mode Menu Title");
	AddMenuItem(g_hMenuSettings, "0", buffer);
	Format(buffer, sizeof(buffer), "%t", "SF2 Settings Film Grain Menu Title");
	AddMenuItem(g_hMenuSettings, "0", buffer);
	Format(buffer, sizeof(buffer), "%t", "SF2 Settings Proxy Menu Title");
	AddMenuItem(g_hMenuSettings, "0", buffer);
	Format(buffer, sizeof(buffer), "%t", "SF2 Settings Ghost Overlay Menu Title");
	AddMenuItem(g_hMenuSettings, "0", buffer);
	SetMenuExitBackButton(g_hMenuSettings, true);
	
	g_hMenuCredits = CreateMenu(Menu_Credits);
	
	Format(buffer, sizeof(buffer), "%tCredits\n \n", "SF2 Prefix");
	StrCat(buffer, sizeof(buffer), "Coder: Kit o' Rifty\n");
	StrCat(buffer, sizeof(buffer), "Version: ");
	StrCat(buffer, sizeof(buffer), PLUGIN_VERSION);
	StrCat(buffer, sizeof(buffer), "\n \n");
	StrCat(buffer, sizeof(buffer), "Mark J. Hadley (AgentParsec) - The creator of the Slender game!\n");
	StrCat(buffer, sizeof(buffer), "Mark Steen - Composing the intro music");
	StrCat(buffer, sizeof(buffer), "Mammoth Mogul - for being a GREAT test subject\n");
	StrCat(buffer, sizeof(buffer), "Egosins - for offering to host this publicly\n");
	StrCat(buffer, sizeof(buffer), "Somberguy - suggestions and support\n");
	StrCat(buffer, sizeof(buffer), "Omi-Box - materials, maps, current Slender Man model, and more!\n");
	StrCat(buffer, sizeof(buffer), "Narry Gewman - imported first Slender Man model\n");
	StrCat(buffer, sizeof(buffer), "Simply Delicious - for the awesome camera overlay!\n");
	StrCat(buffer, sizeof(buffer), "Jason278 - Page models");
	StrCat(buffer, sizeof(buffer), "\n \n");
	
	SetMenuTitle(g_hMenuCredits, buffer);
	AddMenuItem(g_hMenuCredits, "0", "Next");
	AddMenuItem(g_hMenuCredits, "1", "Back");
	
	g_hMenuCredits2 = CreateMenu(Menu_Credits2);
	
	Format(buffer, sizeof(buffer), "%tCredits\n \n", "SF2 Prefix");
	StrCat(buffer, sizeof(buffer), "And to all the peeps who alpha-tested this thing!\n \n");
	StrCat(buffer, sizeof(buffer), "Tofu\n");
	StrCat(buffer, sizeof(buffer), "Ace-Dashie\n");
	StrCat(buffer, sizeof(buffer), "Hobbes\n");
	StrCat(buffer, sizeof(buffer), "Diskein\n");
	StrCat(buffer, sizeof(buffer), "111112oo\n");
	StrCat(buffer, sizeof(buffer), "Incoheriant Chipmunk\n");
	StrCat(buffer, sizeof(buffer), "Shrow\n");
	StrCat(buffer, sizeof(buffer), "Liquid Vita\n");
	StrCat(buffer, sizeof(buffer), "Pinkle D Lies\n");
	StrCat(buffer, sizeof(buffer), "Ultimatefry\n \n");
	
	SetMenuTitle(g_hMenuCredits2, buffer);
	AddMenuItem(g_hMenuCredits2, "0", "Back");
	
	PvP_SetupMenus();
}

public Menu_Main(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction_Select)
	{
		switch (param2)
		{
			case 0: DisplayMenu(g_hMenuHelp, param1, 30);
			case 1: DisplayQueuePointsMenu(param1);
			case 2:	DisplayGroupMainMenuToClient(param1);
			case 3: DisplayMenu(g_hMenuGhostMode, param1, 30);
			case 4: DisplayMenu(g_hMenuSettings, param1, 30);
			case 5: DisplayMenu(g_hMenuCredits, param1, MENU_TIME_FOREVER);
		}
	}
}

public Menu_VoteDifficulty(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction_VoteEnd)
	{
		decl String:sInfo[64], String:sDisplay[256], String:sColor[32];
		GetMenuItem(menu, param1, sInfo, sizeof(sInfo), _, sDisplay, sizeof(sDisplay));
		
		if (IsSpecialRoundRunning() && (g_iSpecialRoundType == SPECIALROUND_INSANEDIFFICULTY || g_iSpecialRoundType == SPECIALROUND_DOUBLEMAXPLAYERS || g_iSpecialRoundType == SPECIALROUND_2DOUBLE))
		{
			SetConVarInt(g_cvDifficulty, Difficulty_Insane);
		}
		else if (IsSpecialRoundRunning() && g_iSpecialRoundType == SPECIALROUND_NOGRACE)
		{
			SetConVarInt(g_cvDifficulty, Difficulty_Hard);
		}
		else
		{
			SetConVarString(g_cvDifficulty, sInfo);
		}
		
		new iDifficulty = GetConVarInt(g_cvDifficulty);
		switch (iDifficulty)
		{
			case Difficulty_Easy:
			{
				Format(sDisplay, sizeof(sDisplay), "%t", "SF2 Easy Difficulty");
				strcopy(sColor, sizeof(sColor), "{green}");
			}
			case Difficulty_Hard:
			{
				Format(sDisplay, sizeof(sDisplay), "%t", "SF2 Hard Difficulty");
				strcopy(sColor, sizeof(sColor), "{orange}");
			}
			case Difficulty_Insane:
			{
				Format(sDisplay, sizeof(sDisplay), "%t", "SF2 Insane Difficulty");
				strcopy(sColor, sizeof(sColor), "{red}");
			}
			default:
			{
				Format(sDisplay, sizeof(sDisplay), "%t", "SF2 Normal Difficulty");
				strcopy(sColor, sizeof(sColor), "{yellow}");
			}
		}
		
		CPrintToChatAll("%t %s%s", "SF2 Difficulty Vote Finished", sColor, sDisplay);
	}
}

public Menu_GhostMode(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction_Select)
	{
		if (IsRoundEnding() ||
			IsRoundInWarmup() ||
			!g_bPlayerEliminated[param1] ||
			!IsClientParticipating(param1) ||
			g_bPlayerProxy[param1])
		{
			CPrintToChat(param1, "{red}%T", "SF2 Ghost Mode Not Allowed", param1);
		}
		else
		{
			switch (param2)
			{
				case 0:
				{
					if (IsClientInGhostMode(param1)) CPrintToChat(param1, "{red}%T", "SF2 Ghost Mode Enabled Already", param1);
					else
					{
						TF2_RespawnPlayer(param1);
						ClientSetGhostModeState(param1, true);
						HandlePlayerHUD(param1);
						
						CPrintToChat(param1, "{olive}%T", "SF2 Ghost Mode Enabled", param1);
					}
				}
				case 1:
				{
					if (!IsClientInGhostMode(param1)) CPrintToChat(param1, "{red}%T", "SF2 Ghost Mode Disabled Already", param1);
					else
					{
						ClientSetGhostModeState(param1, false);
						TF2_RespawnPlayer(param1);
						
						CPrintToChat(param1, "{olive}%T", "SF2 Ghost Mode Disabled", param1);
					}
				}
			}
		}
	}
}

public Menu_Help(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction_Select)
	{
		switch (param2)
		{
			case 0: DisplayMenu(g_hMenuHelpObjective, param1, 30);
			case 1: DisplayMenu(g_hMenuHelpCommands, param1, 30);
			case 2: DisplayMenu(g_hMenuHelpClassInfo, param1, 30);
			case 3: DisplayMenu(g_hMenuHelpGhostMode, param1, 30);
			case 4: DisplayMenu(g_hMenuHelpSprinting, param1, 30);
			case 5: DisplayMenu(g_hMenuHelpControls, param1, 30);
		}
	}
	else if (action == MenuAction_Cancel)
	{
		if (param2 == MenuCancel_ExitBack)
		{
			DisplayMenu(g_hMenuMain, param1, 30);
		}
	}
}

public Menu_HelpObjective(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction_Select)
	{
		switch (param2)
		{
			case 0: DisplayMenu(g_hMenuHelpObjective2, param1, 30);
			case 1: DisplayMenu(g_hMenuHelp, param1, 30);
		}
	}
}

public Menu_HelpObjective2(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction_Select)
	{
		switch (param2)
		{
			case 0: DisplayMenu(g_hMenuHelpObjective, param1, 30);
		}
	}
}

public Menu_BackButtonOnly(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction_Select)
	{
		switch (param2)
		{
			case 0: DisplayMenu(g_hMenuHelp, param1, 30);
		}
	}
}

public Menu_Credits(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction_Select)
	{
		switch (param2)
		{
			case 0: DisplayMenu(g_hMenuCredits2, param1, MENU_TIME_FOREVER);
			case 1: DisplayMenu(g_hMenuMain, param1, 30);
		}
	}
}

public Menu_ClassInfo(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction_Cancel)
	{
		if (param2 == MenuCancel_ExitBack)
		{
			DisplayMenu(g_hMenuMain, param1, 30);
		}
	}
	else if (action == MenuAction_Select)
	{
		decl String:sInfo[64];
		GetMenuItem(menu, param2, sInfo, sizeof(sInfo));
		
		new Handle:hMenu = CreateMenu(Menu_ClassInfoBackOnly);
		
		decl String:sTitle[64], String:sDescription[64];
		Format(sTitle, sizeof(sTitle), "SF2 Help %s Class Info Menu Title", sInfo);
		Format(sDescription, sizeof(sDescription), "SF2 Help %s Class Info Description", sInfo);
		
		SetMenuTitle(hMenu, "%t%t\n \n%t\n \n", "SF2 Prefix", sTitle, sDescription);
		AddMenuItem(hMenu, "0", "Back");
		DisplayMenu(hMenu, param1, 30);
	}
}

public Menu_ClassInfoBackOnly(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
	else if (action == MenuAction_Select)
	{
		DisplayMenu(g_hMenuHelpClassInfo, param1, 30);
	}
}

public Menu_Settings(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction_Select)
	{
		switch (param2)
		{
			case 0: DisplayMenu(g_hMenuSettingsPvP, param1, 30);
			case 1:
			{
				decl String:sBuffer[512];
				Format(sBuffer, sizeof(sBuffer), "%T\n \n", "SF2 Settings Hints Menu Title", param1);
				
				new Handle:hPanel = CreatePanel();
				SetPanelTitle(hPanel, sBuffer);
				
				Format(sBuffer, sizeof(sBuffer), "%T", "Yes", param1);
				DrawPanelItem(hPanel, sBuffer);
				Format(sBuffer, sizeof(sBuffer), "%T", "No", param1);
				DrawPanelItem(hPanel, sBuffer);
				
				SendPanelToClient(hPanel, param1, Panel_SettingsHints, 30);
				CloseHandle(hPanel);
			}
			case 2:
			{
				decl String:sBuffer[512];
				Format(sBuffer, sizeof(sBuffer), "%T\n \n", "SF2 Settings Mute Mode Menu Title", param1);
				
				new Handle:hPanel = CreatePanel();
				SetPanelTitle(hPanel, sBuffer);
				
				DrawPanelItem(hPanel, "Normal");
				DrawPanelItem(hPanel, "Mute opposing team");
				DrawPanelItem(hPanel, "Mute opposing team except when I'm a proxy");
				
				SendPanelToClient(hPanel, param1, Panel_SettingsMuteMode, 30);
				CloseHandle(hPanel);
			}
			case 3:
			{
				decl String:sBuffer[512];
				Format(sBuffer, sizeof(sBuffer), "%T\n \n", "SF2 Settings Film Grain Menu Title", param1);
				
				new Handle:hPanel = CreatePanel();
				SetPanelTitle(hPanel, sBuffer);
				
				Format(sBuffer, sizeof(sBuffer), "%T", "Yes", param1);
				DrawPanelItem(hPanel, sBuffer);
				Format(sBuffer, sizeof(sBuffer), "%T", "No", param1);
				DrawPanelItem(hPanel, sBuffer);
				
				SendPanelToClient(hPanel, param1, Panel_SettingsFilmGrain, 30);
				CloseHandle(hPanel);
			}
			case 4:
			{
				decl String:sBuffer[512];
				Format(sBuffer, sizeof(sBuffer), "%T\n \n", "SF2 Settings Proxy Menu Title", param1);
				
				new Handle:hPanel = CreatePanel();
				SetPanelTitle(hPanel, sBuffer);
				
				Format(sBuffer, sizeof(sBuffer), "%T", "Yes", param1);
				DrawPanelItem(hPanel, sBuffer);
				Format(sBuffer, sizeof(sBuffer), "%T", "No", param1);
				DrawPanelItem(hPanel, sBuffer);
				
				SendPanelToClient(hPanel, param1, Panel_SettingsProxy, 30);
				CloseHandle(hPanel);
			}
			case 5:
			{
				decl String:sBuffer[512];
				Format(sBuffer, sizeof(sBuffer), "%T\n \n", "SF2 Settings Ghost Overlay Menu Title", param1);
				
				new Handle:hPanel = CreatePanel();
				SetPanelTitle(hPanel, sBuffer);
				
				Format(sBuffer, sizeof(sBuffer), "%T", "Yes", param1);
				DrawPanelItem(hPanel, sBuffer);
				Format(sBuffer, sizeof(sBuffer), "%T", "No", param1);
				DrawPanelItem(hPanel, sBuffer);
				
				SendPanelToClient(hPanel, param1, Panel_SettingsGhostOverlay, 30);
				CloseHandle(hPanel);
			}
		}
	}
	else if (action == MenuAction_Cancel)
	{
		if (param2 == MenuCancel_ExitBack)
		{
			DisplayMenu(g_hMenuMain, param1, 30);
		}
	}
}

public Panel_SettingsFilmGrain(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction_Select)
	{
		switch (param2)
		{
			case 1:
			{
				g_iPlayerPreferences[param1][PlayerPreference_FilmGrain] = true;
				ClientSaveCookies(param1);
				CPrintToChat(param1, "%T", "SF2 Enabled Film Grain", param1);
			}
			case 2:
			{
				g_iPlayerPreferences[param1][PlayerPreference_FilmGrain] = false;
				ClientSaveCookies(param1);
				CPrintToChat(param1, "%T", "SF2 Disabled Film Grain", param1);
			}
		}
		
		DisplayMenu(g_hMenuSettings, param1, 30);
	}
}

public Panel_SettingsHints(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction_Select)
	{
		switch (param2)
		{
			case 1:
			{
				g_iPlayerPreferences[param1][PlayerPreference_ShowHints] = true;
				ClientSaveCookies(param1);
				CPrintToChat(param1, "%T", "SF2 Enabled Hints", param1);
			}
			case 2:
			{
				g_iPlayerPreferences[param1][PlayerPreference_ShowHints] = false;
				ClientSaveCookies(param1);
				CPrintToChat(param1, "%T", "SF2 Disabled Hints", param1);
			}
		}
		
		DisplayMenu(g_hMenuSettings, param1, 30);
	}
}

public Panel_SettingsProxy(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction_Select)
	{
		switch (param2)
		{
			case 1:
			{
				g_iPlayerPreferences[param1][PlayerPreference_EnableProxySelection] = true;
				ClientSaveCookies(param1);
				CPrintToChat(param1, "%T", "SF2 Enabled Proxy", param1);
			}
			case 2:
			{
				g_iPlayerPreferences[param1][PlayerPreference_EnableProxySelection] = false;
				ClientSaveCookies(param1);
				CPrintToChat(param1, "%T", "SF2 Disabled Proxy", param1);
			}
		}
		
		DisplayMenu(g_hMenuSettings, param1, 30);
	}
}

public Panel_SettingsGhostOverlay(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction_Select)
	{
		switch (param2)
		{
			case 1:
			{
				g_iPlayerPreferences[param1][PlayerPreference_GhostOverlay] = true;
				ClientSaveCookies(param1);
				CPrintToChat(param1, "%T", "SF2 Enabled Ghost Overlay", param1);
			}
			case 2:
			{
				g_iPlayerPreferences[param1][PlayerPreference_GhostOverlay] = false;
				ClientSaveCookies(param1);
				CPrintToChat(param1, "%T", "SF2 Disabled Ghost Overlay", param1);
			}
		}
		
		DisplayMenu(g_hMenuSettings, param1, 30);
	}
}

public Panel_SettingsMuteMode(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction_Select)
	{
		switch (param2)
		{
			case 1:
			{
				g_iPlayerPreferences[param1][PlayerPreference_MuteMode] = MuteMode_Normal;
				ClientUpdateListeningFlags(param1);
				ClientSaveCookies(param1);
				CPrintToChat(param1, "{lightgreen}Mute mode set to normal.");
			}
			case 2:
			{
				g_iPlayerPreferences[param1][PlayerPreference_MuteMode] = MuteMode_DontHearOtherTeam;
				ClientUpdateListeningFlags(param1);
				ClientSaveCookies(param1);
				CPrintToChat(param1, "{lightgreen}Muted opposing team.");
			}
			case 3:
			{
				g_iPlayerPreferences[param1][PlayerPreference_MuteMode] = MuteMode_DontHearOtherTeamIfNotProxy;
				ClientUpdateListeningFlags(param1);
				ClientSaveCookies(param1);
				CPrintToChat(param1, "{lightgreen}Muted opposing team, but settings will be automatically set to normal if you're a proxy.");
			}
		}
		
		DisplayMenu(g_hMenuSettings, param1, 30);
	}
}

public Menu_Credits2(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction_Select)
	{
		switch (param2)
		{
			case 0: DisplayMenu(g_hMenuCredits, param1, MENU_TIME_FOREVER);
		}
	}
}

DisplayQueuePointsMenu(client)
{
	new Handle:menu = CreateMenu(Menu_QueuePoints);
	new Handle:hQueueList = GetQueueList();
	
	decl String:sBuffer[256];
	
	if (GetArraySize(hQueueList))
	{
		Format(sBuffer, sizeof(sBuffer), "%T\n \n", "SF2 Reset Queue Points Option", client, g_iPlayerQueuePoints[client]);
		AddMenuItem(menu, "ponyponypony", sBuffer);
		
		decl iIndex, String:sGroupName[SF2_MAX_PLAYER_GROUP_NAME_LENGTH];
		decl String:sInfo[256];
		
		for (new i = 0, iSize = GetArraySize(hQueueList); i < iSize; i++)
		{
			if (!GetArrayCell(hQueueList, i, 2))
			{
				iIndex = GetArrayCell(hQueueList, i);
				
				Format(sBuffer, sizeof(sBuffer), "%N - %d", iIndex, g_iPlayerQueuePoints[iIndex]);
				Format(sInfo, sizeof(sInfo), "player_%d", GetClientUserId(iIndex));
				AddMenuItem(menu, sInfo, sBuffer, g_bPlayerPlaying[iIndex] ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
			}
			else
			{
				iIndex = GetArrayCell(hQueueList, i);
				if (GetPlayerGroupMemberCount(iIndex) > 1)
				{
					GetPlayerGroupName(iIndex, sGroupName, sizeof(sGroupName));
					
					Format(sBuffer, sizeof(sBuffer), "[GROUP] %s - %d", sGroupName, GetPlayerGroupQueuePoints(iIndex));
					Format(sInfo, sizeof(sInfo), "group_%d", iIndex);
					AddMenuItem(menu, sInfo, sBuffer, IsPlayerGroupPlaying(iIndex) ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
				}
				else
				{
					for (new iClient = 1; iClient <= MaxClients; iClient++)
					{
						if (!IsValidClient(iClient)) continue;
						if (ClientGetPlayerGroup(iClient) == iIndex)
						{
							Format(sBuffer, sizeof(sBuffer), "%N - %d", iClient, g_iPlayerQueuePoints[iClient]);
							Format(sInfo, sizeof(sInfo), "player_%d", GetClientUserId(iClient));
							AddMenuItem(menu, "player", sBuffer, g_bPlayerPlaying[iClient] ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
							break;
						}
					}
				}
			}
		}
	}
	
	CloseHandle(hQueueList);
	
	SetMenuTitle(menu, "%t%T\n \n", "SF2 Prefix", "SF2 Queue Menu Title", client);
	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

DisplayViewGroupMembersQueueMenu(client, iGroupIndex)
{
	if (!IsPlayerGroupActive(iGroupIndex))
	{
		// The group isn't valid anymore. Take him back to the main menu.
		DisplayQueuePointsMenu(client);
		CPrintToChat(client, "%T", "SF2 Group Does Not Exist", client);
		return;
	}
	
	new Handle:hPlayers = CreateArray();
	for (new i = 1; i <= MaxClients; i++)
	{
		if (!IsValidClient(i)) continue;
		
		new iTempGroup = ClientGetPlayerGroup(i);
		if (!IsPlayerGroupActive(iTempGroup) || iTempGroup != iGroupIndex) continue;
		
		PushArrayCell(hPlayers, i);
	}
	
	new iPlayerCount = GetArraySize(hPlayers);
	if (iPlayerCount)
	{
		decl String:sGroupName[SF2_MAX_PLAYER_GROUP_NAME_LENGTH];
		GetPlayerGroupName(iGroupIndex, sGroupName, sizeof(sGroupName));
		
		new Handle:hMenu = CreateMenu(Menu_ViewGroupMembersQueue);
		SetMenuTitle(hMenu, "%t%T (%s)\n \n", "SF2 Prefix", "SF2 View Group Members Menu Title", client, sGroupName);
		
		decl String:sUserId[32];
		decl String:sName[MAX_NAME_LENGTH * 2];
		
		for (new i = 0; i < iPlayerCount; i++)
		{
			new iClient = GetArrayCell(hPlayers, i);
			IntToString(GetClientUserId(iClient), sUserId, sizeof(sUserId));
			GetClientName(iClient, sName, sizeof(sName));
			if (GetPlayerGroupLeader(iGroupIndex) == iClient) StrCat(sName, sizeof(sName), " (LEADER)");
			
			AddMenuItem(hMenu, sUserId, sName);
		}
		
		SetMenuExitBackButton(hMenu, true);
		DisplayMenu(hMenu, client, MENU_TIME_FOREVER);
	}
	else
	{
		// No players!
		DisplayQueuePointsMenu(client);
	}
	
	CloseHandle(hPlayers);
}

public Menu_ViewGroupMembersQueue(Handle:menu, MenuAction:action, param1, param2)
{
	switch (action)
	{
		case MenuAction_End: CloseHandle(menu);
		case MenuAction_Select: DisplayQueuePointsMenu(param1);
		case MenuAction_Cancel:
		{
			if (param2 == MenuCancel_ExitBack) DisplayQueuePointsMenu(param1);
		}
	}
}

DisplayResetQueuePointsMenu(client)
{
	decl String:buffer[256];

	new Handle:menu = CreateMenu(Menu_ResetQueuePoints);
	Format(buffer, sizeof(buffer), "%T", "Yes", client);
	AddMenuItem(menu, "0", buffer);
	Format(buffer, sizeof(buffer), "%T", "No", client);
	AddMenuItem(menu, "1", buffer);
	SetMenuTitle(menu, "%T\n \n", "SF2 Should Reset Queue Points", client);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public Menu_QueuePoints(Handle:menu, MenuAction:action, param1, param2)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			new String:sInfo[64];
			GetMenuItem(menu, param2, sInfo, sizeof(sInfo));
			
			if (StrEqual(sInfo, "ponyponypony")) DisplayResetQueuePointsMenu(param1);
			else if (!StrContains(sInfo, "player_"))
			{
			}
			else if (!StrContains(sInfo, "group_"))
			{
				decl String:sIndex[64];
				strcopy(sIndex, sizeof(sIndex), sInfo);
				ReplaceString(sIndex, sizeof(sIndex), "group_", "");
				DisplayViewGroupMembersQueueMenu(param1, StringToInt(sIndex));
			}
		}
		case MenuAction_Cancel:
		{
			if (param2 == MenuCancel_ExitBack)
			{
				DisplayMenu(g_hMenuMain, param1, 30);
			}
		}
		case MenuAction_End: CloseHandle(menu);
	}
}

public Menu_ResetQueuePoints(Handle:menu, MenuAction:action, param1, param2)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0:
				{
					ClientSetQueuePoints(param1, 0);
					CPrintToChat(param1, "{olive}%T", "SF2 Queue Points Reset", param1);
					
					// Special round.
					if (IsSpecialRoundRunning()) 
					{
						SetClientPlaySpecialRoundState(param1, true);
					}
					
					// new boss round
					if (IsNewBossRoundRunning()) 
					{
						// If the player resets the queue points ignore them when checking for players that haven't played the new boss yet, if applicable.
						SetClientPlayNewBossRoundState(param1, true);
					}
				}
			}
			
			DisplayQueuePointsMenu(param1);
		}
		
		case MenuAction_End: CloseHandle(menu);
	}
}