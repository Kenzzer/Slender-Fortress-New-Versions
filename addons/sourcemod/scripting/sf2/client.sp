#if defined _sf2_client_included
 #endinput
#endif
#define _sf2_client_included

#define GHOST_MODEL "models/props_halloween/ghost_no_hat.mdl"
#define SF2_OVERLAY_DEFAULT "overlays/slender/newcamerahud_3"
#define SF2_OVERLAY_DEFAULT_NO_FILMGRAIN "overlays/slender/nofilmgrain"
#define SF2_OVERLAY_GHOST "overlays/slender/ghostcamera"

#define SF2_FLASHLIGHT_WIDTH 512.0 // How wide the player's Flashlight should be in world units.
#define SF2_FLASHLIGHT_LENGTH 1024.0 // How far the player's Flashlight can reach in world units.
#define SF2_FLASHLIGHT_BRIGHTNESS 0 // Intensity of the players' Flashlight.
#define SF2_FLASHLIGHT_DRAIN_RATE 0.65 // How long (in seconds) each bar on the player's Flashlight meter lasts.
#define SF2_FLASHLIGHT_RECHARGE_RATE 0.68 // How long (in seconds) it takes each bar on the player's Flashlight meter to recharge.
#define SF2_FLASHLIGHT_FLICKERAT 0.25 // The percentage of the Flashlight battery where the Flashlight will start to blink.
#define SF2_FLASHLIGHT_ENABLEAT 0.3 // The percentage of the Flashlight battery where the Flashlight will be able to be used again (if the player shortens out the Flashlight from excessive use).
#define SF2_FLASHLIGHT_COOLDOWN 0.4 // How much time players have to wait before being able to switch their flashlight on again after turning it off.

#define SF2_ULTRAVISION_WIDTH 800.0
#define SF2_ULTRAVISION_LENGTH 800.0
#define SF2_ULTRAVISION_BRIGHTNESS -4 // Intensity of Ultravision.
#define SF2_ULTRAVISION_CONE 180.0

#define SF2_PLAYER_BREATH_COOLDOWN_MIN 0.8
#define SF2_PLAYER_BREATH_COOLDOWN_MAX 2.0

new String:g_strPlayerBreathSounds[][] = 
{
	"slender/fastbreath1.wav"
};

static String:g_strPlayerLagCompensationWeapons[][] = 
{
	"tf_weapon_sniperrifle",
	"tf_weapon_sniperrifle_decap",
	"tf_weapon_sniperrifle_classic"
};

// Deathcam data.
static g_iPlayerDeathCamBoss[MAXPLAYERS + 1] = { -1, ... };
static bool:g_bPlayerDeathCam[MAXPLAYERS + 1] = { false, ... };
static bool:g_bPlayerDeathCamShowOverlay[MAXPLAYERS + 1] = { false, ... };
static g_iPlayerDeathCamEnt[MAXPLAYERS + 1] = { INVALID_ENT_REFERENCE, ... };
static g_iPlayerDeathCamEnt2[MAXPLAYERS + 1] = { INVALID_ENT_REFERENCE, ... };
static Handle:g_hPlayerDeathCamTimer[MAXPLAYERS + 1] = { INVALID_HANDLE, ... };

// Flashlight data.
static bool:g_bPlayerFlashlight[MAXPLAYERS + 1] = { false, ... };
static bool:g_bPlayerFlashlightBroken[MAXPLAYERS + 1] = { false, ... };
static g_iPlayerFlashlightEnt[MAXPLAYERS + 1] = { INVALID_ENT_REFERENCE, ... };
static g_iPlayerFlashlightEntAng[MAXPLAYERS + 1] = { INVALID_ENT_REFERENCE, ... };
static Float:g_flPlayerFlashlightBatteryLife[MAXPLAYERS + 1] = { 1.0, ... };
static Handle:g_hPlayerFlashlightBatteryTimer[MAXPLAYERS + 1] = { INVALID_HANDLE, ... };
static Float:g_flPlayerFlashlightNextInputTime[MAXPLAYERS + 1] = { -1.0, ... };

// Ultravision data.
static bool:g_bPlayerUltravision[MAXPLAYERS + 1] = { false, ... };
static g_iPlayerUltravisionEnt[MAXPLAYERS + 1] = { INVALID_ENT_REFERENCE, ... };

// Sprint data.
static bool:g_bPlayerSprint[MAXPLAYERS + 1] = { false, ... };
static g_iPlayerSprintPoints[MAXPLAYERS + 1] = { 100, ... };
static Handle:g_hPlayerSprintTimer[MAXPLAYERS + 1] = { INVALID_HANDLE, ... };

// Blink data.
static Handle:g_hPlayerBlinkTimer[MAXPLAYERS + 1] = { INVALID_HANDLE, ... };
static bool:g_bPlayerBlink[MAXPLAYERS + 1] = { false, ... };
static Float:g_flPlayerBlinkMeter[MAXPLAYERS + 1] = { 0.0, ... };
static g_iPlayerBlinkCount[MAXPLAYERS + 1] = { 0, ... };

// Breathing data.
static bool:g_bPlayerBreath[MAXPLAYERS + 1] = { false, ... };
static Handle:g_hPlayerBreathTimer[MAXPLAYERS + 1] = { INVALID_HANDLE, ... };

// Interactive glow data.
static g_iPlayerInteractiveGlowEntity[MAXPLAYERS + 1] = { INVALID_ENT_REFERENCE, ... };
static g_iPlayerInteractiveGlowTargetEntity[MAXPLAYERS + 1] = { INVALID_ENT_REFERENCE, ... };

// Constant glow data.
static g_iPlayerConstantGlowEntity[MAXPLAYERS + 1] = { INVALID_ENT_REFERENCE, ... };
static bool:g_bPlayerConstantGlowEnabled[MAXPLAYERS + 1] = { false, ... };

// Jumpscare data.
static g_iPlayerJumpScareBoss[MAXPLAYERS + 1] = { -1, ... };
static Float:g_flPlayerJumpScareLifeTime[MAXPLAYERS + 1] = { -1.0, ... };

static Float:g_flPlayerScareBoostEndTime[MAXPLAYERS + 1] = { -1.0, ... };

// Anti-camping data.
static g_iPlayerCampingStrikes[MAXPLAYERS + 1] = { 0, ... };
static Handle:g_hPlayerCampingTimer[MAXPLAYERS + 1] = { INVALID_HANDLE, ... };
static Float:g_flPlayerCampingLastPosition[MAXPLAYERS + 1][3];
static bool:g_bPlayerCampingFirstTime[MAXPLAYERS + 1] = { true, ... };

// Frame data
static g_iClientMaxFrameDeathAnim[MAXPLAYERS + 1];
static g_iClientFrame[MAXPLAYERS + 1];

//Proxy model
new String:g_sClientProxyModel[MAXPLAYERS + 1][MAX_NAME_LENGTH];

//	==========================================================
//	GENERAL CLIENT HOOK FUNCTIONS
//	==========================================================

#define SF2_PLAYER_VIEWBOB_TIMER 10.0
#define SF2_PLAYER_VIEWBOB_SCALE_X 0.05
#define SF2_PLAYER_VIEWBOB_SCALE_Y 0.0
#define SF2_PLAYER_VIEWBOB_SCALE_Z 0.0


public MRESReturn:Hook_ClientWantsLagCompensationOnEntity(this, Handle:hReturn, Handle:hParams)
{
	if (!g_bEnabled || IsFakeClient(this)) return MRES_Ignored;
	
	DHookSetReturn(hReturn, true);
	return MRES_Supercede;
}

Float:ClientGetScareBoostEndTime(client)
{
	return g_flPlayerScareBoostEndTime[client];
}

ClientSetScareBoostEndTime(client, Float:time)
{
	g_flPlayerScareBoostEndTime[client] = time;
}

public Hook_ClientPreThink(client)
{
	if (!g_bEnabled) return;
	
	ClientProcessViewAngles(client);
	ClientProcessVisibility(client);
	ClientProcessStaticShake(client);
	ClientProcessFlashlightAngles(client);
	ClientProcessInteractiveGlow(client);
	
	if (IsClientInGhostMode(client))
	{
		SetEntPropFloat(client, Prop_Send, "m_flNextAttack", GetGameTime() + 2.0);
		SetEntPropFloat(client, Prop_Send, "m_flMaxspeed", 520.0);
	}
	else if (!g_bPlayerEliminated[client] || g_bPlayerProxy[client])
	{
		if (!IsRoundEnding() && !IsRoundInWarmup() && !DidClientEscape(client))
		{
			new iRoundState = _:GameRules_GetRoundState();
		
			// No double jumping for players in play.
			SetEntProp(client, Prop_Send, "m_iAirDash", 99999);
		
			if (!g_bPlayerProxy[client])
			{
				if (iRoundState == 4)
				{
					new bool:bDanger = false;
					
					if (!bDanger)
					{
						decl iState;
						decl iBossTarget;
						
						for (new i = 0; i < MAX_BOSSES; i++)
						{
							if (NPCGetUniqueID(i) == -1) continue;
							
							if (NPCGetType(i) == SF2BossType_Chaser)
							{
								iBossTarget = EntRefToEntIndex(g_iSlenderTarget[i]);
								iState = g_iSlenderState[i];
								
								if ((iState == STATE_CHASE || iState == STATE_ATTACK || iState == STATE_STUN) &&
									((iBossTarget && iBossTarget != INVALID_ENT_REFERENCE && (iBossTarget == client || ClientGetDistanceFromEntity(client, iBossTarget) < 512.0)) || NPCGetDistanceFromEntity(i, client) < 512.0 || PlayerCanSeeSlender(client, i, false)))
								{
									bDanger = true;
									ClientSetScareBoostEndTime(client, GetGameTime() + 5.0);
									
									// Induce client stress levels.
									new Float:flUnComfortZoneDist = 512.0;
									new Float:flStressScalar = (flUnComfortZoneDist / NPCGetDistanceFromEntity(i, client));
									ClientAddStress(client, 0.025 * flStressScalar);
									
									break;
								}
							}
						}
					}
					
					if (g_flPlayerStaticAmount[client] > 0.4) bDanger = true;
					if (GetGameTime() < ClientGetScareBoostEndTime(client)) bDanger = true;
					
					if (!bDanger)
					{
						decl iState;
						for (new i = 0; i < MAX_BOSSES; i++)
						{
							if (NPCGetUniqueID(i) == -1) continue;
							
							if (NPCGetType(i) == SF2BossType_Chaser)
							{
								if (iState == STATE_ALERT)
								{
									if (PlayerCanSeeSlender(client, i))
									{
										bDanger = true;
										ClientSetScareBoostEndTime(client, GetGameTime() + 5.0);
									}
								}
							}
						}
					}
					
					if (!bDanger)
					{
						new Float:flCurTime = GetGameTime();
						new Float:flScareSprintDuration = 3.0;
						if (TF2_GetPlayerClass(client) == TFClass_DemoMan) flScareSprintDuration *= 1.667;
						
						for (new i = 0; i < MAX_BOSSES; i++)
						{
							if (NPCGetUniqueID(i) == -1) continue;
							
							if ((flCurTime - g_flPlayerScareLastTime[client][i]) <= flScareSprintDuration)
							{
								bDanger = true;
								break;
							}
						}
					}
					
					new Float:flWalkSpeed = ClientGetDefaultWalkSpeed(client);
					new Float:flSprintSpeed = ClientGetDefaultSprintSpeed(client);
					
					// Check for weapon speed changes.
					new iWeapon = INVALID_ENT_REFERENCE;
					
					for (new iSlot = 0; iSlot <= 5; iSlot++)
					{
						iWeapon = GetPlayerWeaponSlot(client, iSlot);
						if (!iWeapon || iWeapon == INVALID_ENT_REFERENCE) continue;
						
						new iItemDef = GetEntProp(iWeapon, Prop_Send, "m_iItemDefinitionIndex");
						switch (iItemDef)
						{
							case 239: // Gloves of Running Urgently
							{
								if (GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon") == iWeapon)
								{
									flSprintSpeed += (flSprintSpeed * 0.1);
								}
							}
							case 775: // Escape Plan
							{
								new Float:flHealth = float(GetEntProp(client, Prop_Send, "m_iHealth"));
								new Float:flMaxHealth = float(SDKCall(g_hSDKGetMaxHealth, client));
								new Float:flPercentage = flHealth / flMaxHealth;
								
								if (flPercentage < 0.805 && flPercentage >= 0.605) flSprintSpeed += (flSprintSpeed * 0.05);
								else if (flPercentage < 0.605 && flPercentage >= 0.405) flSprintSpeed += (flSprintSpeed * 0.1);
								else if (flPercentage < 0.405 && flPercentage >= 0.205) flSprintSpeed += (flSprintSpeed * 0.15);
								else if (flPercentage < 0.205) flSprintSpeed += (flSprintSpeed * 0.2);
							}
						}
					}
					
					// Speed buff?
					if (TF2_IsPlayerInCondition(client, TFCond_SpeedBuffAlly))
					{
						flWalkSpeed += (flWalkSpeed * 0.08);
						flSprintSpeed += (flSprintSpeed * 0.08);
					}
					
					if (bDanger)
					{
						flWalkSpeed *= 1.33;
						flSprintSpeed *= 1.33;
						
						if (!g_bPlayerHints[client][PlayerHint_Sprint])
						{
							ClientShowHint(client, PlayerHint_Sprint);
						}
					}
					
					new Float:flSprintSpeedSubtract = ((flSprintSpeed - flWalkSpeed) * 0.5);
					flSprintSpeedSubtract -= flSprintSpeedSubtract * (g_iPlayerSprintPoints[client] != 0 ? (float(g_iPlayerSprintPoints[client]) / 100.0) : 0.0);
					flSprintSpeed -= flSprintSpeedSubtract;
					
					if (IsClientSprinting(client)) 
					{
						SetEntPropFloat(client, Prop_Send, "m_flMaxspeed", flSprintSpeed);
					}
					else 
					{
						SetEntPropFloat(client, Prop_Send, "m_flMaxspeed", flWalkSpeed);
					}
					
					if (ClientCanBreath(client) && !g_bPlayerBreath[client])
					{
						ClientStartBreathing(client);
					}
				}
			}
			else
			{
				new TFClassType:iClass = TF2_GetPlayerClass(client);
				new bool:bSpeedup = TF2_IsPlayerInCondition(client, TFCond_SpeedBuffAlly);
			
				switch (iClass)
				{
					case TFClass_Scout:
					{
						if (iRoundState == 4)
						{
							if (bSpeedup) SetEntPropFloat(client, Prop_Send, "m_flMaxspeed", 405.0);
							else SetEntPropFloat(client, Prop_Send, "m_flMaxspeed", 300.0);
						}
					}
					case TFClass_Medic:
					{
						if (iRoundState == 4)
						{
							if (bSpeedup) SetEntPropFloat(client, Prop_Send, "m_flMaxspeed", 385.0);
							else SetEntPropFloat(client, Prop_Send, "m_flMaxspeed", 300.0);
						}
					}
				}
			}
		}
	}
	
	// Calculate player stress levels.
	if (GetGameTime() >= g_flPlayerStressNextUpdateTime[client])
	{
		//new Float:flPagePercent = g_iPageMax != 0 ? float(g_iPageCount) / float(g_iPageMax) : 0.0;
		//new Float:flPageCountPercent = g_iPageMax != 0? float(g_iPlayerPageCount[client]) / float(g_iPageMax) : 0.0;
		
		g_flPlayerStressNextUpdateTime[client] = GetGameTime() + 0.33;
		ClientAddStress(client, -0.01);
		
#if defined DEBUG
		SendDebugMessageToPlayer(client, DEBUG_PLAYER_STRESS, 1, "g_flPlayerStress[%d]: %0.1f", client, g_flPlayerStress[client]);
#endif
	}
	
	// Process screen shake, if enabled.
	if (g_bPlayerShakeEnabled)
	{
		new bool:bDoShake = false;
		
		if (IsPlayerAlive(client))
		{
			new iStaticMaster = NPCGetFromUniqueID(g_iPlayerStaticMaster[client]);
			if (iStaticMaster != -1 && NPCGetFlags(iStaticMaster) & SFF_HASVIEWSHAKE)
			{
				bDoShake = true;
			}
		}
		
		if (bDoShake)
		{
			new Float:flPercent = g_flPlayerStaticAmount[client];
			
			new Float:flAmplitudeMax = GetConVarFloat(g_cvPlayerShakeAmplitudeMax);
			new Float:flAmplitude = flAmplitudeMax * flPercent;
			
			new Float:flFrequencyMax = GetConVarFloat(g_cvPlayerShakeFrequencyMax);
			new Float:flFrequency = flFrequencyMax * flPercent;
			
			UTIL_ScreenShake(client, flAmplitude, 0.5, flFrequency);
		}
	}
}

public Action:Hook_ClientSetTransmit(client, other)
{
	if (!g_bEnabled) return Plugin_Continue;
	
	if (other != client)
	{
		if (IsClientInGhostMode(client) && !IsClientInGhostMode(other)) return Plugin_Handled;
		
		if (!IsRoundEnding())
		{
			// SPECIAL ROUND: Singleplayer
			if (g_bSpecialRound && g_iSpecialRoundType == SPECIALROUND_SINGLEPLAYER)
			{
				if (!g_bPlayerEliminated[client] && !g_bPlayerEliminated[other] && !DidClientEscape(other)) return Plugin_Handled; 
			}
			
			// pvp
			if (IsClientInPvP(client) && IsClientInPvP(other)) 
			{
				if (TF2_IsPlayerInCondition(client, TFCond_Cloaked) &&
					!TF2_IsPlayerInCondition(client, TFCond_CloakFlicker) &&
					!TF2_IsPlayerInCondition(client, TFCond_Jarated) &&
					!TF2_IsPlayerInCondition(client, TFCond_Milked) &&
					!TF2_IsPlayerInCondition(client, TFCond_OnFire) &&
					(GetGameTime() > GetEntPropFloat(client, Prop_Send, "m_flInvisChangeCompleteTime")))
				{
					return Plugin_Handled;
				}
			}
		}
	}
	
	return Plugin_Continue;
}

public Action:TF2_CalcIsAttackCritical(client, weapon, String:sWeaponName[], &bool:result)
{
	if (!g_bEnabled) return Plugin_Continue;
	
	if ((IsRoundInWarmup() || IsClientInPvP(client)) && !IsRoundEnding())
	{
		if (!GetConVarBool(g_cvPlayerFakeLagCompensation))
		{
			new bool:bNeedsManualDamage = false;
			
			// Fake lag compensation isn't enabled; check to see if we need to deal damage manually.
			for (new i = 0; i < sizeof(g_strPlayerLagCompensationWeapons); i++)
			{
				if (StrEqual(sWeaponName, g_strPlayerLagCompensationWeapons[i], false))
				{
					bNeedsManualDamage = true;
					break;
				}
			}
			
			if (bNeedsManualDamage)
			{
				decl Float:flStartPos[3], Float:flEyeAng[3];
				GetClientEyePosition(client, flStartPos);
				GetClientEyeAngles(client, flEyeAng);
				
				new Handle:hTrace = TR_TraceRayFilterEx(flStartPos, flEyeAng, MASK_SHOT, RayType_Infinite, TraceRayDontHitEntity, client);
				new iHitEntity = TR_GetEntityIndex(hTrace);
				new iHitGroup = TR_GetHitGroup(hTrace);
				CloseHandle(hTrace);
				
				if (IsValidClient(iHitEntity))
				{
					if (GetClientTeam(iHitEntity) == GetClientTeam(client))
					{
						if (IsRoundInWarmup() || IsClientInPvP(iHitEntity))
						{
							new Float:flChargedDamage = GetEntPropFloat(weapon, Prop_Send, "m_flChargedDamage");
							if (flChargedDamage < 50.0) flChargedDamage = 50.0;
							new iDamageType = DMG_BULLET;
							
							if (IsClientCritBoosted(client))
							{
								result = true;
								iDamageType |= DMG_ACID;
							}
							else if (iHitGroup == 1)
							{
								if (StrEqual(sWeaponName, "tf_weapon_sniperrifle_classic", false))
								{
									if (flChargedDamage >= 150.0)
									{
										result = true;
										iDamageType |= DMG_ACID;
									}
								}
								else
								{
									if (TF2_IsPlayerInCondition(client, TFCond_Zoomed))
									{
										result = true;
										iDamageType |= DMG_ACID;
									}
								}
							}
							
							SDKHooks_TakeDamage(iHitEntity, client, client, flChargedDamage, iDamageType);
							return Plugin_Changed;
						}
					}
				}
			}
		}
	}
	
	return Plugin_Continue;
}

public Action:Hook_ClientOnTakeDamage(victim, &attacker, &inflictor, &Float:damage, &damagetype, &weapon, Float:damageForce[3], Float:damagePosition[3], damagecustom)
{
	if (!g_bEnabled) return Plugin_Continue;
	
	if (IsRoundInWarmup()) return Plugin_Continue;
	if(IsValidClient(attacker) && IsValidClient(victim) && IsClientInPvP(victim) && GetClientTeam(victim) == _:TFTeam_Red && GetClientTeam(attacker) == _:TFTeam_Red)
	{
		damage = 0.0;
		return Plugin_Changed;
	}
	if (attacker != victim && IsValidClient(attacker))
	{
		if (!IsRoundEnding())
		{
			if (IsClientInPvP(victim) && IsClientInPvP(attacker))
			{
				if (attacker == inflictor)
				{
					if (IsValidEdict(weapon))
					{
						decl String:sWeaponClass[64];
						GetEdictClassname(weapon, sWeaponClass, sizeof(sWeaponClass));
						
						// Backstab check!
						if ((StrEqual(sWeaponClass, "tf_weapon_knife", false) || (TF2_GetPlayerClass(attacker) == TFClass_Spy && StrEqual(sWeaponClass, "saxxy", false))) &&
							(damagecustom != TF_CUSTOM_TAUNT_FENCING))
						{
							decl Float:flMyPos[3], Float:flHisPos[3], Float:flMyDirection[3];
							GetClientAbsOrigin(victim, flMyPos);
							GetClientAbsOrigin(attacker, flHisPos);
							GetClientEyeAngles(victim, flMyDirection);
							GetAngleVectors(flMyDirection, flMyDirection, NULL_VECTOR, NULL_VECTOR);
							NormalizeVector(flMyDirection, flMyDirection);
							ScaleVector(flMyDirection, 32.0);
							AddVectors(flMyDirection, flMyPos, flMyDirection);
							
							decl Float:p[3], Float:s[3];
							MakeVectorFromPoints(flMyPos, flHisPos, p);
							MakeVectorFromPoints(flMyPos, flMyDirection, s);
							if (GetVectorDotProduct(p, s) <= 0.0)
							{
								damage = float(GetEntProp(victim, Prop_Send, "m_iHealth")) * 2.0;
								
								new Handle:hCvar = FindConVar("tf_weapon_criticals");
								if (hCvar != INVALID_HANDLE && GetConVarBool(hCvar)) damagetype |= DMG_ACID;
								return Plugin_Changed;
							}
						}
					}
				}
			}
			else if (g_bPlayerProxy[victim] || g_bPlayerProxy[attacker])
			{
				if (g_bPlayerEliminated[attacker] == g_bPlayerEliminated[victim])
				{
					damage = 0.0;
					return Plugin_Changed;
				}
				
				if (g_bPlayerProxy[attacker])
				{
					decl String:sProfile[SF2_MAX_PROFILE_NAME_LENGTH];
					new iMaxHealth = SDKCall(g_hSDKGetMaxHealth, victim);
					new iMaster = NPCGetFromUniqueID(g_iPlayerProxyMaster[attacker]);
					NPCGetProfile(iMaster, sProfile, sizeof(sProfile));
					if (iMaster != -1 && sProfile[0])
					{
						if (damagecustom == TF_CUSTOM_TAUNT_GRAND_SLAM ||
							damagecustom == TF_CUSTOM_TAUNT_FENCING ||
							damagecustom == TF_CUSTOM_TAUNT_ARROW_STAB ||
							damagecustom == TF_CUSTOM_TAUNT_GRENADE ||
							damagecustom == TF_CUSTOM_TAUNT_BARBARIAN_SWING ||
							damagecustom == TF_CUSTOM_TAUNT_ENGINEER_ARM ||
							damagecustom == TF_CUSTOM_TAUNT_ARMAGEDDON)
						{
							if (damage >= float(iMaxHealth)) damage = float(iMaxHealth) * 0.5;
							else damage = 0.0;
						}
						else if (damagecustom == TF_CUSTOM_BACKSTAB) // Modify backstab damage.
						{
							damage = float(iMaxHealth) * GetProfileFloat(sProfile, "proxies_damage_scale_vs_enemy_backstab", 0.25);
							if (damagetype & DMG_ACID) damage /= 2.0;
						}
					
						g_iPlayerProxyControl[attacker] += GetProfileNum(sProfile, "proxies_controlgain_hitenemy");
						if (g_iPlayerProxyControl[attacker] > 100)
						{
							g_iPlayerProxyControl[attacker] = 100;
						}
						
						damage *= GetProfileFloat(sProfile, "proxies_damage_scale_vs_enemy", 1.0);
					}
					
					return Plugin_Changed;
				}
				else if (g_bPlayerProxy[victim])
				{
					decl String:sProfile[SF2_MAX_PROFILE_NAME_LENGTH];
					new iMaster = NPCGetFromUniqueID(g_iPlayerProxyMaster[victim]);
					NPCGetProfile(iMaster, sProfile, sizeof(sProfile));
					if (iMaster != -1 && sProfile[0])
					{
						g_iPlayerProxyControl[attacker] += GetProfileNum(sProfile, "proxies_controlgain_hitbyenemy");
						if (g_iPlayerProxyControl[attacker] > 100)
						{
							g_iPlayerProxyControl[attacker] = 100;
						}
						
						damage *= GetProfileFloat(sProfile, "proxies_damage_scale_vs_self", 1.0);
					}
					if(TF2_IsPlayerInCondition(victim, TFCond:87))
					{
						damage=0.0;
						return Plugin_Changed;
					}
					if( damage * ( damagetype & DMG_CRIT ? 3.0 : 1.0 ) >= float(GetClientHealth(victim)) && !TF2_IsPlayerInCondition(victim, TFCond:87))//The proxy is about to die
					{
						decl String:sClassName[64];
						decl String:sSectionName[64];
						decl String:sBuffer[PLATFORM_MAX_PATH];
						TF2_GetClassName(TF2_GetPlayerClass(victim), sClassName, sizeof(sClassName));
		
						Format(sSectionName, sizeof(sSectionName), "proxies_death_anim_%s", sClassName);
						if ((GetProfileString(sProfile, sSectionName, sBuffer, sizeof(sBuffer)) && sBuffer[0]) ||
						(GetProfileString(sProfile, "proxies_death_anim_all", sBuffer, sizeof(sBuffer)) && sBuffer[0]))
						{
							Format(sSectionName, sizeof(sSectionName), "proxies_death_anim_frames_%s", sClassName);
							g_iClientMaxFrameDeathAnim[victim]=GetProfileNum(sProfile, sSectionName, 0);
							if(g_iClientMaxFrameDeathAnim[victim]==0)
								g_iClientMaxFrameDeathAnim[victim]=GetProfileNum(sProfile, "proxies_death_anim_frames_all", 0);
							if(g_iClientMaxFrameDeathAnim[victim]>0)
							{
								// Cancel out any other taunts.
								if(TF2_IsPlayerInCondition(victim, TFCond_Taunting)) TF2_RemoveCondition(victim, TFCond_Taunting);
								//The model has a death anim play it.
								ClientSDK_PlaySpecificSequence(victim,sBuffer);
								g_iClientFrame[victim]=0;
								RequestFrame(ProxyDeathAnimation,victim);
								TF2_AddCondition(victim, TFCond:87, 5.0);
								//Prevent death, and show the damage to the attacker.
								TF2_AddCondition(victim, TFCond:70, 0.5);
								return Plugin_Changed;
							}
						}
						//the player has no death anim leave him die.
					}
					return Plugin_Changed;
				}
			}
			else
			{
				damage = 0.0;
				return Plugin_Changed;
			}
		}
		else
		{
			if (g_bPlayerEliminated[attacker] == g_bPlayerEliminated[victim])
			{
				damage = 0.0;
				return Plugin_Changed;
			}
		}
		
		if (IsClientInGhostMode(victim))
		{
			damage = 0.0;
			return Plugin_Changed;
		}
	}
	
	return Plugin_Continue;
}

public Action:Hook_TEFireBullets(const String:te_name[], const Players[], numClients, Float:delay)
{
	if (!g_bEnabled) return Plugin_Continue;
	
	new client = TE_ReadNum("m_iPlayer") + 1;
	if (IsValidClient(client))
	{
		if (GetConVarBool(g_cvPlayerFakeLagCompensation))
		{
			if ((IsRoundInWarmup() || IsClientInPvP(client)))
			{
				ClientEnableFakeLagCompensation(client);
			}
		}
	}
	
	return Plugin_Continue;
}

ClientResetStatic(client)
{
	g_iPlayerStaticMaster[client] = -1;
	g_hPlayerStaticTimer[client] = INVALID_HANDLE;
	g_flPlayerStaticIncreaseRate[client] = 0.0;
	g_flPlayerStaticDecreaseRate[client] = 0.0;
	g_hPlayerLastStaticTimer[client] = INVALID_HANDLE;
	g_flPlayerLastStaticTime[client] = 0.0;
	g_flPlayerLastStaticVolume[client] = 0.0;
	g_bPlayerInStaticShake[client] = false;
	g_iPlayerStaticShakeMaster[client] = -1;
	g_flPlayerStaticShakeMinVolume[client] = 0.0;
	g_flPlayerStaticShakeMaxVolume[client] = 0.0;
	g_flPlayerStaticAmount[client] = 0.0;
	
	if (IsClientInGame(client))
	{
		if (g_strPlayerStaticSound[client][0]) StopSound(client, SNDCHAN_STATIC, g_strPlayerStaticSound[client]);
		if (g_strPlayerLastStaticSound[client][0]) StopSound(client, SNDCHAN_STATIC, g_strPlayerLastStaticSound[client]);
		if (g_strPlayerStaticShakeSound[client][0]) StopSound(client, SNDCHAN_STATIC, g_strPlayerStaticShakeSound[client]);
	}
	
	strcopy(g_strPlayerStaticSound[client], sizeof(g_strPlayerStaticSound[]), "");
	strcopy(g_strPlayerLastStaticSound[client], sizeof(g_strPlayerLastStaticSound[]), "");
	strcopy(g_strPlayerStaticShakeSound[client], sizeof(g_strPlayerStaticShakeSound[]), "");
}

ClientResetHints(client)
{
#if defined DEBUG
	if (GetConVarInt(g_cvDebugDetail) > 2) DebugMessage("START ClientResetHints(%d)", client);
#endif

	for (new i = 0; i < PlayerHint_MaxNum; i++)
	{
		g_bPlayerHints[client][i] = false;
	}
	
#if defined DEBUG
	if (GetConVarInt(g_cvDebugDetail) > 2) DebugMessage("END ClientResetHints(%d)", client);
#endif
}

ClientShowHint(client, iHint)
{
	g_bPlayerHints[client][iHint] = true;
	
	switch (iHint)
	{
		case PlayerHint_Sprint: PrintHintText(client, "%T", "SF2 Hint Sprint", client);
		case PlayerHint_Flashlight: PrintHintText(client, "%T", "SF2 Hint Flashlight", client);
		case PlayerHint_Blink: PrintHintText(client, "%T", "SF2 Hint Blink", client);
		case PlayerHint_MainMenu: PrintHintText(client, "%T", "SF2 Hint Main Menu", client);
	}
}

bool:DidClientEscape(client)
{
	return g_bPlayerEscaped[client];
}

ClientEscape(client)
{
	if (DidClientEscape(client)) return;

#if defined DEBUG
	if (GetConVarInt(g_cvDebugDetail) > 1) DebugMessage("START ClientEscape(%d)", client);
#endif
	
	g_bPlayerEscaped[client] = true;
	
	ClientResetBreathing(client);
	ClientResetSprint(client);
	ClientResetFlashlight(client);
	ClientDeactivateUltravision(client);
	ClientDisableConstantGlow(client);
	
	// Speed recalculation. Props to the creators of FF2/VSH for this snippet.
	TF2_AddCondition(client, TFCond_SpeedBuffAlly, 0.001);
	
	HandlePlayerHUD(client);
	
	decl String:sName[MAX_NAME_LENGTH];
	GetClientName(client, sName, sizeof(sName));
	CPrintToChatAll("%t", "SF2 Player Escaped", sName);
	
	CheckRoundWinConditions();
	
	Call_StartForward(fOnClientEscape);
	Call_PushCell(client);
	Call_Finish();
	
#if defined DEBUG
	if (GetConVarInt(g_cvDebugDetail) > 1) DebugMessage("END ClientEscape(%d)", client);
#endif
}

public Action:Timer_TeleportPlayerToEscapePoint(Handle:timer, any:userid)
{
	new client = GetClientOfUserId(userid);
	if (client <= 0) return;
	
	if (!DidClientEscape(client)) return;
	
	if (IsPlayerAlive(client))
	{
		TeleportClientToEscapePoint(client);
	}
}

stock Float:ClientGetDistanceFromEntity(client, entity)
{
	decl Float:flStartPos[3], Float:flEndPos[3];
	GetClientAbsOrigin(client, flStartPos);
	GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", flEndPos);
	return GetVectorDistance(flStartPos, flEndPos);
}

ClientEnableFakeLagCompensation(client)
{
	if (!IsValidClient(client) || !IsPlayerAlive(client) || g_bPlayerLagCompensation[client]) return;
	
	// Can only enable lag compensation if we're in either of these two teams only.
	new iMyTeam = GetClientTeam(client);
	if (iMyTeam != _:TFTeam_Red && iMyTeam != _:TFTeam_Blue) return;
	
	// Can only enable lag compensation if there are other active teammates around. This is to prevent spontaneous round restarting.
	new iCount;
	for (new i = 1; i <= MaxClients; i++)
	{
		if (i == client) continue;
		
		if (IsValidClient(i) && IsPlayerAlive(i))
		{
			new iTeam = GetClientTeam(i);
			if ((iTeam == _:TFTeam_Red || iTeam == _:TFTeam_Blue) && iTeam == iMyTeam)
			{
				iCount++;
			}
		}
	}
	
	if (!iCount) return;
	
	// Can only enable lag compensation only for specific weapons.
	new iActiveWeapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	if (!IsValidEdict(iActiveWeapon)) return;
	
	decl String:sClassName[64];
	GetEdictClassname(iActiveWeapon, sClassName, sizeof(sClassName));
	
	new bool:bCompensate = false;
	for (new i = 0; i < sizeof(g_strPlayerLagCompensationWeapons); i++)
	{
		if (StrEqual(sClassName, g_strPlayerLagCompensationWeapons[i], false))
		{
			bCompensate = true;
			break;
		}
	}
	
	if (!bCompensate) return;
	
	g_bPlayerLagCompensation[client] = true;
	g_iPlayerLagCompensationTeam[client] = iMyTeam;
	SetEntProp(client, Prop_Send, "m_iTeamNum", 0);
}

ClientDisableFakeLagCompensation(client)
{
	if (!g_bPlayerLagCompensation[client]) return;
	
	SetEntProp(client, Prop_Send, "m_iTeamNum", g_iPlayerLagCompensationTeam[client]);
	g_bPlayerLagCompensation[client] = false;
	g_iPlayerLagCompensationTeam[client] = -1;
}

//	==========================================================
//	FLASHLIGHT / ULTRAVISION FUNCTIONS
//	==========================================================

bool:IsClientUsingFlashlight(client)
{
	return g_bPlayerFlashlight[client];
}

Float:ClientGetFlashlightBatteryLife(client)
{
	return g_flPlayerFlashlightBatteryLife[client];
}

ClientSetFlashlightBatteryLife(client, Float:flPercent)
{
	g_flPlayerFlashlightBatteryLife[client] = flPercent;
}

/**
 *	Called in Hook_ClientPreThink, this makes sure the flashlight is oriented correctly on the player.
 */
static ClientProcessFlashlightAngles(client)
{
	if (!IsClientInGame(client)) return;
	
	if (IsPlayerAlive(client))
	{
		decl fl, Float:eyeAng[3], Float:ang2[3];
		
		if (IsClientUsingFlashlight(client))
		{
			fl = EntRefToEntIndex(g_iPlayerFlashlightEnt[client]);
			if (fl && fl != INVALID_ENT_REFERENCE)
			{
				TeleportEntity(fl, NULL_VECTOR, Float:{ 0.0, 0.0, 0.0 }, NULL_VECTOR);
			}
			
			fl = EntRefToEntIndex(g_iPlayerFlashlightEntAng[client]);
			if (fl && fl != INVALID_ENT_REFERENCE)
			{
				GetClientEyeAngles(client, eyeAng);
				GetClientAbsAngles(client, ang2);
				SubtractVectors(eyeAng, ang2, eyeAng);
				TeleportEntity(fl, NULL_VECTOR, eyeAng, NULL_VECTOR);
			}
		}
	}
}

/**
 *	Handles whether or not the player's flashlight should be "flickering", a sign of a dying flashlight battery.
 */
static ClientHandleFlashlightFlickerState(client)
{
	if (!IsClientInGame(client) || !IsPlayerAlive(client)) return;
	
	if (IsClientUsingFlashlight(client))
	{
		new bool:bFlicker = bool:(ClientGetFlashlightBatteryLife(client) <= SF2_FLASHLIGHT_FLICKERAT);
	
		new fl = EntRefToEntIndex(g_iPlayerFlashlightEnt[client]);
		if (fl && fl != INVALID_ENT_REFERENCE)
		{
			if (bFlicker)
			{
				SetEntProp(fl, Prop_Data, "m_LightStyle", 10);
			}
			else
			{
				SetEntProp(fl, Prop_Data, "m_LightStyle", 0);
			}
		}
		
		fl = EntRefToEntIndex(g_iPlayerFlashlightEntAng[client]);
		if (fl && fl != INVALID_ENT_REFERENCE)
		{
			if (bFlicker) 
			{
				SetEntityRenderFx(fl, RenderFx:13);
			}
			else 
			{
				SetEntityRenderFx(fl, RenderFx:0);
			}
		}
	}
}

bool:IsClientFlashlightBroken(client)
{
	return g_bPlayerFlashlightBroken[client];
}

Float:ClientGetFlashlightNextInputTime(client)
{
	return g_flPlayerFlashlightNextInputTime[client];
}

/**
 *	Breaks the player's flashlight. Nothing else.
 */
ClientBreakFlashlight(client)
{
	if (IsClientFlashlightBroken(client)) return;
	
	g_bPlayerFlashlightBroken[client] = true;
	
	ClientSetFlashlightBatteryLife(client, 0.0);
	ClientTurnOffFlashlight(client);
	
	ClientAddStress(client, 0.2);
	
	EmitSoundToAll(FLASHLIGHT_BREAKSOUND, client, SNDCHAN_STATIC, SNDLEVEL_DRYER);
	
	Call_StartForward(fOnClientBreakFlashlight);
	Call_PushCell(client);
	Call_Finish();
}

/**
 *	Resets everything of the player's flashlight.
 */
ClientResetFlashlight(client)
{
#if defined DEBUG
	if (GetConVarInt(g_cvDebugDetail) > 2) DebugMessage("START ClientResetFlashlight(%d)", client);
#endif
	
	ClientTurnOffFlashlight(client);
	ClientSetFlashlightBatteryLife(client, 1.0);
	g_bPlayerFlashlightBroken[client] = false;
	g_hPlayerFlashlightBatteryTimer[client] = INVALID_HANDLE;
	g_flPlayerFlashlightNextInputTime[client] = -1.0;
	
#if defined DEBUG
	if (GetConVarInt(g_cvDebugDetail) > 2) DebugMessage("END ClientResetFlashlight(%d)", client);
#endif
}

public Action:Hook_FlashlightSetTransmit(ent, other)
{
	if (!g_bEnabled) return Plugin_Continue;
	
	if (EntRefToEntIndex(g_iPlayerFlashlightEnt[other]) != ent) return Plugin_Handled;
	
	// We've already checked for flashlight ownership in the last statement. So we can do just this.
	if (g_iPlayerPreferences[other][PlayerPreference_ProjectedFlashlight]) return Plugin_Handled;
	
	return Plugin_Continue;
}

public Action:Hook_Flashlight2SetTransmit(ent, other)
{
	if (!g_bEnabled) return Plugin_Continue;

	if (EntRefToEntIndex(g_iPlayerFlashlightEntAng[other]) == ent) return Plugin_Handled;
	return Plugin_Continue;
}

public Hook_FlashlightEndSpawnPost(ent)
{
	if (!g_bEnabled) return;

	SDKHook(ent, SDKHook_SetTransmit, Hook_FlashlightEndSetTransmit);
	SDKUnhook(ent, SDKHook_SpawnPost, Hook_FlashlightEndSpawnPost);
}

public Action:Hook_FlashlightBeamSetTransmit(ent, other)
{
	if (!g_bEnabled) return Plugin_Continue;

	new iOwner = -1;
	new iSpotlight = -1;
	while ((iSpotlight = FindEntityByClassname(iSpotlight, "point_spotlight")) != -1)
	{
		if (GetEntPropEnt(ent, Prop_Data, "m_hOwnerEntity") == iSpotlight)
		{
			iOwner = iSpotlight;
			break;
		}
	}
	
	if (iOwner == -1) return Plugin_Continue;
	
	new iClient = -1;
	for (new i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i)) continue;
		
		if (EntRefToEntIndex(g_iPlayerFlashlightEntAng[i]) == iOwner)
		{
			iClient = i;
			break;
		}
	}
	
	if (iClient == -1) return Plugin_Continue;
	
	if (iClient == other)
	{
		if (!GetEntProp(iClient, Prop_Send, "m_nForceTauntCam") || !GetEntProp(iClient, Prop_Send, "m_iObserverMode"))
		{
			return Plugin_Handled;
		}
	}
	else
	{
		if (g_bSpecialRound && g_iSpecialRoundType == SPECIALROUND_SINGLEPLAYER)
		{
			return Plugin_Handled;
		}
	}
	
	return Plugin_Continue;
}

public Action:Hook_FlashlightEndSetTransmit(ent, other)
{
	if (!g_bEnabled) return Plugin_Continue;

	new iOwner = -1;
	new iSpotlight = -1;
	while ((iSpotlight = FindEntityByClassname(iSpotlight, "point_spotlight")) != -1)
	{
		if (GetEntPropEnt(ent, Prop_Data, "m_hOwnerEntity") == iSpotlight)
		{
			iOwner = iSpotlight;
			break;
		}
	}
	
	if (iOwner == -1) return Plugin_Continue;
	
	new iClient = -1;
	for (new i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i)) continue;
		
		if (EntRefToEntIndex(g_iPlayerFlashlightEntAng[i]) == iOwner)
		{
			iClient = i;
			break;
		}
	}
	
	if (iClient == -1) return Plugin_Continue;
	
	if (iClient == other)
	{
		if (!GetEntProp(iClient, Prop_Send, "m_nForceTauntCam") || !GetEntProp(iClient, Prop_Send, "m_iObserverMode"))
		{
			return Plugin_Handled;
		}
	}
	else
	{
		if (g_bSpecialRound && g_iSpecialRoundType == SPECIALROUND_SINGLEPLAYER)
		{
			return Plugin_Handled;
		}
	}
	
	return Plugin_Continue;
}

public Action:Timer_DrainFlashlight(Handle:timer, any:userid)
{
	new client = GetClientOfUserId(userid);
	if (client <= 0) return Plugin_Stop;
	
	if (timer != g_hPlayerFlashlightBatteryTimer[client]) return Plugin_Stop;
	
	if (!IsInfiniteFlashlightEnabled())
	{
		ClientSetFlashlightBatteryLife(client, ClientGetFlashlightBatteryLife(client) - 0.01);
	}
	
	if (ClientGetFlashlightBatteryLife(client) <= 0.0)
	{
		// Break the player's flashlight, but also start recharging.
		ClientBreakFlashlight(client);
		ClientStartRechargingFlashlightBattery(client);
		ClientActivateUltravision(client);
		return Plugin_Stop;
	}
	else
	{
		ClientHandleFlashlightFlickerState(client);
	}
	
	return Plugin_Continue;
}

public Action:Timer_RechargeFlashlight(Handle:timer, any:userid)
{
	new client = GetClientOfUserId(userid);
	if (client <= 0) return Plugin_Stop;
	
	if (timer != g_hPlayerFlashlightBatteryTimer[client]) return Plugin_Stop;
	
	ClientSetFlashlightBatteryLife(client, ClientGetFlashlightBatteryLife(client) + 0.01);
	
	if (IsClientFlashlightBroken(client) && ClientGetFlashlightBatteryLife(client) >= SF2_FLASHLIGHT_ENABLEAT)
	{
		// Repair the flashlight.
		g_bPlayerFlashlightBroken[client] = false;
	}
	
	if (ClientGetFlashlightBatteryLife(client) >= 1.0)
	{
		// I am fully charged!
		ClientSetFlashlightBatteryLife(client, 1.0);
		g_hPlayerFlashlightBatteryTimer[client] = INVALID_HANDLE;
		
		return Plugin_Stop;
	}
	
	return Plugin_Continue;
}

/**
 *	Turns on the player's flashlight. Nothing else.
 */
ClientTurnOnFlashlight(client)
{
	if (!IsClientInGame(client) || !IsPlayerAlive(client)) return;
	
	if (IsClientUsingFlashlight(client)) return;
	
	g_bPlayerFlashlight[client] = true;
	
	decl Float:flEyePos[3];
	GetClientEyePosition(client, flEyePos);
	
	if (g_iPlayerPreferences[client][PlayerPreference_ProjectedFlashlight])
	{
		// If the player is using the projected flashlight, just set effect flags.
		new iEffects = GetEntProp(client, Prop_Send, "m_fEffects");
		if (!(iEffects & (1 << 2)))
		{
			SetEntProp(client, Prop_Send, "m_fEffects", iEffects | (1 << 2));
		}
	}
	else
	{
		// Spawn the light which only the user will see.
		new ent = CreateEntityByName("light_dynamic");
		if (ent != -1)
		{
			TeleportEntity(ent, flEyePos, NULL_VECTOR, NULL_VECTOR);
			DispatchKeyValue(ent, "targetname", "WUBADUBDUBMOTHERBUCKERS");
			DispatchKeyValue(ent, "rendercolor", "255 255 255");
			SetVariantFloat(SF2_FLASHLIGHT_WIDTH);
			AcceptEntityInput(ent, "spotlight_radius");
			SetVariantFloat(SF2_FLASHLIGHT_LENGTH);
			AcceptEntityInput(ent, "distance");
			SetVariantInt(SF2_FLASHLIGHT_BRIGHTNESS);
			AcceptEntityInput(ent, "brightness");
			
			// Convert WU to inches.
			new Float:cone = 55.0;
			cone *= 0.75;
			
			SetVariantInt(RoundToFloor(cone));
			AcceptEntityInput(ent, "_inner_cone");
			SetVariantInt(RoundToFloor(cone));
			AcceptEntityInput(ent, "_cone");
			DispatchSpawn(ent);
			ActivateEntity(ent);
			SetVariantString("!activator");
			AcceptEntityInput(ent, "SetParent", client);
			AcceptEntityInput(ent, "TurnOn");
			
			g_iPlayerFlashlightEnt[client] = EntIndexToEntRef(ent);
			
			SDKHook(ent, SDKHook_SetTransmit, Hook_FlashlightSetTransmit);
		}
	}
	
	// Spawn the light that only everyone else will see.
	new ent = CreateEntityByName("point_spotlight");
	if (ent != -1)
	{
		TeleportEntity(ent, flEyePos, NULL_VECTOR, NULL_VECTOR);
		
		decl String:sBuffer[256];
		FloatToString(SF2_FLASHLIGHT_LENGTH, sBuffer, sizeof(sBuffer));
		DispatchKeyValue(ent, "spotlightlength", sBuffer);
		FloatToString(SF2_FLASHLIGHT_WIDTH, sBuffer, sizeof(sBuffer));
		DispatchKeyValue(ent, "spotlightwidth", sBuffer);
		DispatchKeyValue(ent, "rendercolor", "255 255 255");
		DispatchSpawn(ent);
		ActivateEntity(ent);
		SetVariantString("!activator");
		AcceptEntityInput(ent, "SetParent", client);
		AcceptEntityInput(ent, "LightOn");
		
		g_iPlayerFlashlightEntAng[client] = EntIndexToEntRef(ent);
	}
	
	Call_StartForward(fOnClientActivateFlashlight);
	Call_PushCell(client);
	Call_Finish();
}

/**
 *	Turns off the player's flashlight. Nothing else.
 */
ClientTurnOffFlashlight(client)
{
	if (!IsClientUsingFlashlight(client)) return;
	
	g_bPlayerFlashlight[client] = false;
	g_hPlayerFlashlightBatteryTimer[client] = INVALID_HANDLE;
	
	// Remove user-only light.
	new ent = EntRefToEntIndex(g_iPlayerFlashlightEnt[client]);
	if (ent && ent != INVALID_ENT_REFERENCE) 
	{
		AcceptEntityInput(ent, "TurnOff");
		AcceptEntityInput(ent, "Kill");
	}
	
	// Remove everyone-else-only light.
	ent = EntRefToEntIndex(g_iPlayerFlashlightEntAng[client]);
	if (ent && ent != INVALID_ENT_REFERENCE) 
	{
		AcceptEntityInput(ent, "LightOff");
		CreateTimer(0.1, Timer_KillEntity, g_iPlayerFlashlightEntAng[client], TIMER_FLAG_NO_MAPCHANGE);
	}
	
	g_iPlayerFlashlightEnt[client] = INVALID_ENT_REFERENCE;
	g_iPlayerFlashlightEntAng[client] = INVALID_ENT_REFERENCE;
	
	if (IsClientInGame(client))
	{
		if (g_iPlayerPreferences[client][PlayerPreference_ProjectedFlashlight])
		{
			new iEffects = GetEntProp(client, Prop_Send, "m_fEffects");
			if (iEffects & (1 << 2))
			{
				SetEntProp(client, Prop_Send, "m_fEffects", iEffects &= ~(1 << 2));
			}
		}
	}
	
	Call_StartForward(fOnClientDeactivateFlashlight);
	Call_PushCell(client);
	Call_Finish();
}

ClientStartRechargingFlashlightBattery(client)
{
	g_hPlayerFlashlightBatteryTimer[client] = CreateTimer(SF2_FLASHLIGHT_RECHARGE_RATE, Timer_RechargeFlashlight, GetClientUserId(client), TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
}

ClientStartDrainingFlashlightBattery(client)
{
	new Float:flDrainRate = SF2_FLASHLIGHT_DRAIN_RATE;
	if (TF2_GetPlayerClass(client) == TFClass_Engineer) 
	{
		// Engineers have a 33% longer battery life, basically.
		// TODO: Make this value customizable via cvar.
		flDrainRate *= 1.33;
	}
	
	g_hPlayerFlashlightBatteryTimer[client] = CreateTimer(flDrainRate, Timer_DrainFlashlight, GetClientUserId(client), TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
}

ClientHandleFlashlight(client)
{
	if (!IsValidClient(client) || !IsPlayerAlive(client)) return;
	
	if (IsClientUsingFlashlight(client)) 
	{
		ClientTurnOffFlashlight(client);
		ClientStartRechargingFlashlightBattery(client);
		ClientActivateUltravision(client);
		
		g_flPlayerFlashlightNextInputTime[client] = GetGameTime() + SF2_FLASHLIGHT_COOLDOWN;
		
		EmitSoundToAll(FLASHLIGHT_CLICKSOUND, client, SNDCHAN_STATIC, SNDLEVEL_DRYER);
	}
	else
	{
		// Only players in the "game" can use the flashlight.
		if (!g_bPlayerEliminated[client])
		{
			new bool:bCanUseFlashlight = true;
			if (g_bSpecialRound && (SF_SpecialRound(SPECIALROUND_LIGHTSOUT) || SF_SpecialRound(SPECIALROUND_NIGHTVISION))) 
			{
				// Unequip the flashlight please.
				bCanUseFlashlight = false;
			}
			
			if (!IsClientFlashlightBroken(client) && bCanUseFlashlight)
			{
				ClientTurnOnFlashlight(client);
				ClientStartDrainingFlashlightBattery(client);
				ClientDeactivateUltravision(client);
				
				g_flPlayerFlashlightNextInputTime[client] = GetGameTime();
				
				EmitSoundToAll(FLASHLIGHT_CLICKSOUND, client, SNDCHAN_STATIC, SNDLEVEL_DRYER);
			}
			else
			{
				EmitSoundToClient(client, FLASHLIGHT_NOSOUND, _, SNDCHAN_ITEM, SNDLEVEL_NONE);
			}
		}
	}
}

bool:IsClientUsingUltravision(client)
{
	return g_bPlayerUltravision[client];
}

ClientActivateUltravision(client)
{
	if (!IsClientInGame(client) || IsClientUsingUltravision(client)) return;
	
#if defined DEBUG
	if (GetConVarInt(g_cvDebugDetail) > 2) DebugMessage("START ClientActivateUltravision(%d)", client);
#endif
	
	g_bPlayerUltravision[client] = true;
	
	new ent = CreateEntityByName("light_dynamic");
	if (ent != -1)
	{
		decl Float:flEyePos[3];
		GetClientEyePosition(client, flEyePos);
		
		TeleportEntity(ent, flEyePos, Float:{ 90.0, 0.0, 0.0 }, NULL_VECTOR);
		if(!SF_SpecialRound(SPECIALROUND_NIGHTVISION))
			DispatchKeyValue(ent, "rendercolor", "0 200 255");
		else
			DispatchKeyValue(ent, "rendercolor", "110 255 100");
		
		new Float:flRadius = 0.0;
		if (g_bPlayerEliminated[client])
		{
			flRadius = GetConVarFloat(g_cvUltravisionRadiusBlue);
		}
		else
		{
			flRadius = GetConVarFloat(g_cvUltravisionRadiusRed);
		}
		if(SF_SpecialRound(SPECIALROUND_NIGHTVISION) && !g_bPlayerEliminated[client])
			flRadius = GetConVarFloat(g_cvNightvisionRadius); //To-do make a cvar for this.//Done
		
		SetVariantFloat(flRadius);
		AcceptEntityInput(ent, "spotlight_radius");
		SetVariantFloat(flRadius);
		AcceptEntityInput(ent, "distance");
		
		SetVariantInt(-15); // Start dark, then fade in via the Timer_UltravisionFadeInEffect timer func.
		AcceptEntityInput(ent, "brightness");
		if(SF_SpecialRound(SPECIALROUND_NIGHTVISION) && !g_bPlayerEliminated[client])
		{
			SetVariantInt(4);
			AcceptEntityInput(ent, "brightness");
		}
		
		// Convert WU to inches.
		new Float:cone = SF2_ULTRAVISION_CONE;
		cone *= 0.75;
		
		SetVariantInt(RoundToFloor(cone));
		AcceptEntityInput(ent, "_inner_cone");
		SetVariantInt(0);
		AcceptEntityInput(ent, "_cone");
		DispatchSpawn(ent);
		ActivateEntity(ent);
		SetVariantString("!activator");
		AcceptEntityInput(ent, "SetParent", client);
		AcceptEntityInput(ent, "TurnOn");
		SetEntityRenderFx(ent, RENDERFX_SOLID_SLOW);
		SetEntityRenderColor(ent, 100, 200, 255, 255);
		if(SF_SpecialRound(SPECIALROUND_NIGHTVISION) && !g_bPlayerEliminated[client])
			SetEntityRenderColor(ent, 110, 255, 100, 255);
		
		g_iPlayerUltravisionEnt[client] = EntIndexToEntRef(ent);
		
		SDKHook(ent, SDKHook_SetTransmit, Hook_UltravisionSetTransmit);
		
		// Fade in effect.
		CreateTimer(0.0, Timer_UltravisionFadeInEffect, g_iPlayerUltravisionEnt[client], TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
	}

#if defined DEBUG
	if (GetConVarInt(g_cvDebugDetail) > 2) DebugMessage("END ClientActivateUltravision(%d)", client);
#endif
}

public Action:Timer_UltravisionFadeInEffect(Handle:timer, any:entref)
{
	new ent = EntRefToEntIndex(entref);
	if (!ent || ent == INVALID_ENT_REFERENCE) return Plugin_Stop;
	
	new iBrightness = GetEntProp(ent, Prop_Send, "m_Exponent");
	if (iBrightness >= GetConVarInt(g_cvUltravisionBrightness)) return Plugin_Stop;
	
	iBrightness++;
	SetVariantInt(iBrightness);
	AcceptEntityInput(ent, "brightness");
	
	return Plugin_Continue;
}

ClientDeactivateUltravision(client)
{
	if (!IsClientUsingUltravision(client)) return;
	
	g_bPlayerUltravision[client] = false;
	
	new ent = EntRefToEntIndex(g_iPlayerUltravisionEnt[client]);
	if (ent != INVALID_ENT_REFERENCE)
	{
		AcceptEntityInput(ent, "TurnOff");
		AcceptEntityInput(ent, "Kill");
	}
	
	g_iPlayerUltravisionEnt[client] = INVALID_ENT_REFERENCE;
}

public Action:Hook_UltravisionSetTransmit(ent, other)
{
	if (!g_bEnabled) return Plugin_Continue;

	if (!GetConVarBool(g_cvUltravisionEnabled) || EntRefToEntIndex(g_iPlayerUltravisionEnt[other]) != ent || !IsPlayerAlive(other)) return Plugin_Handled;
	return Plugin_Continue;
}

static Float:ClientGetDefaultWalkSpeed(client)
{
	new Float:flReturn = 190.0;
	new Float:flReturn2 = flReturn;
	new Action:iAction = Plugin_Continue;
	new TFClassType:iClass = TF2_GetPlayerClass(client);
	
	switch (iClass)
	{
		case TFClass_Scout: flReturn = 190.0;
		case TFClass_Sniper: flReturn = 190.0;
		case TFClass_Soldier: flReturn = 190.0;
		case TFClass_DemoMan: flReturn = 190.0;
		case TFClass_Heavy: flReturn = 190.0;
		case TFClass_Medic: flReturn = 190.0;
		case TFClass_Pyro: flReturn = 190.0;
		case TFClass_Spy: flReturn = 190.0;
		case TFClass_Engineer: flReturn = 190.0;
	}
	
	// Call our forward.
	Call_StartForward(fOnClientGetDefaultWalkSpeed);
	Call_PushCell(client);
	Call_PushCellRef(flReturn2);
	Call_Finish(iAction);
	
	if (iAction == Plugin_Changed) flReturn = flReturn2;
	
	return flReturn;
}

static Float:ClientGetDefaultSprintSpeed(client)
{
	new Float:flReturn = 300.0;
	new Float:flReturn2 = flReturn;
	new Action:iAction = Plugin_Continue;
	new TFClassType:iClass = TF2_GetPlayerClass(client);
	
	switch (iClass)
	{
		case TFClass_Scout: flReturn = 300.0;
		case TFClass_Sniper: flReturn = 300.0;
		case TFClass_Soldier: flReturn = 275.0;
		case TFClass_DemoMan: flReturn = 285.0;
		case TFClass_Heavy: flReturn = 270.0;
		case TFClass_Medic: flReturn = 300.0;
		case TFClass_Pyro: flReturn = 300.0;
		case TFClass_Spy: flReturn = 300.0;
		case TFClass_Engineer: flReturn = 300.0;
	}
	
	// Call our forward.
	Call_StartForward(fOnClientGetDefaultSprintSpeed);
	Call_PushCell(client);
	Call_PushCellRef(flReturn2);
	Call_Finish(iAction);
	
	if (iAction == Plugin_Changed) flReturn = flReturn2;
	
	return flReturn;
}

// Static shaking should only affect the x, y portion of the player's view, not roll.
// This is purely for cosmetic effect.

ClientProcessStaticShake(client)
{
	if (!IsClientInGame(client) || !IsPlayerAlive(client)) return;
	
	new bool:bOldStaticShake = g_bPlayerInStaticShake[client];
	new iOldStaticShakeMaster = NPCGetFromUniqueID(g_iPlayerStaticShakeMaster[client]);
	new iNewStaticShakeMaster = -1;
	new Float:flNewStaticShakeMasterAnger = -1.0;
	
	new Float:flOldPunchAng[3], Float:flOldPunchAngVel[3];
	GetEntDataVector(client, g_offsPlayerPunchAngle, flOldPunchAng);
	GetEntDataVector(client, g_offsPlayerPunchAngleVel, flOldPunchAngVel);
	
	new Float:flNewPunchAng[3], Float:flNewPunchAngVel[3];
	
	for (new i = 0; i < 3; i++)
	{
		flNewPunchAng[i] = flOldPunchAng[i];
		flNewPunchAngVel[i] = flOldPunchAngVel[i];
	}
	
	for (new i = 0; i < MAX_BOSSES; i++)
	{
		if (NPCGetUniqueID(i) == -1) continue;
		
		if (g_iPlayerStaticMode[client][i] != Static_Increase) continue;
		if (!(NPCGetFlags(i) & SFF_HASSTATICSHAKE)) continue;
		
		if (NPCGetAnger(i) > flNewStaticShakeMasterAnger)
		{
			new iMaster = NPCGetFromUniqueID(g_iSlenderCopyMaster[i]);
			if (iMaster == -1) iMaster = i;
			
			iNewStaticShakeMaster = iMaster;
			flNewStaticShakeMasterAnger = NPCGetAnger(iMaster);
		}
	}
	
	if (iNewStaticShakeMaster != -1)
	{
		g_iPlayerStaticShakeMaster[client] = NPCGetUniqueID(iNewStaticShakeMaster);
		
		if (iNewStaticShakeMaster != iOldStaticShakeMaster)
		{
			decl String:sProfile[SF2_MAX_PROFILE_NAME_LENGTH];
			NPCGetProfile(iNewStaticShakeMaster, sProfile, sizeof(sProfile));
		
			if (g_strPlayerStaticShakeSound[client][0])
			{
				StopSound(client, SNDCHAN_STATIC, g_strPlayerStaticShakeSound[client]);
			}
			
			g_flPlayerStaticShakeMinVolume[client] = GetProfileFloat(sProfile, "sound_static_shake_local_volume_min", 0.0);
			g_flPlayerStaticShakeMaxVolume[client] = GetProfileFloat(sProfile, "sound_static_shake_local_volume_max", 1.0);
			
			decl String:sStaticSound[PLATFORM_MAX_PATH];
			GetRandomStringFromProfile(sProfile, "sound_static_shake_local", sStaticSound, sizeof(sStaticSound));
			if (sStaticSound[0])
			{
				strcopy(g_strPlayerStaticShakeSound[client], sizeof(g_strPlayerStaticShakeSound[]), sStaticSound);
			}
			else
			{
				strcopy(g_strPlayerStaticShakeSound[client], sizeof(g_strPlayerStaticShakeSound[]), "");
			}
		}
	}
	
	if (g_bPlayerInStaticShake[client])
	{
		if (g_flPlayerStaticAmount[client] <= 0.0)
		{
			g_bPlayerInStaticShake[client] = false;
		}
	}
	else
	{
		if (iNewStaticShakeMaster != -1)
		{
			g_bPlayerInStaticShake[client] = true;
		}
	}
	
	if (g_bPlayerInStaticShake[client] && !bOldStaticShake)
	{	
		for (new i = 0; i < 2; i++)
		{
			flNewPunchAng[i] = 0.0;
			flNewPunchAngVel[i] = 0.0;
		}
		
		SetEntDataVector(client, g_offsPlayerPunchAngle, flNewPunchAng, true);
		SetEntDataVector(client, g_offsPlayerPunchAngleVel, flNewPunchAngVel, true);
	}
	else if (!g_bPlayerInStaticShake[client] && bOldStaticShake)
	{
		for (new i = 0; i < 2; i++)
		{
			flNewPunchAng[i] = 0.0;
			flNewPunchAngVel[i] = 0.0;
		}
	
		g_iPlayerStaticShakeMaster[client] = -1;
		
		if (g_strPlayerStaticShakeSound[client][0])
		{
			StopSound(client, SNDCHAN_STATIC, g_strPlayerStaticShakeSound[client]);
		}
		
		strcopy(g_strPlayerStaticShakeSound[client], sizeof(g_strPlayerStaticShakeSound[]), "");
		
		g_flPlayerStaticShakeMinVolume[client] = 0.0;
		g_flPlayerStaticShakeMaxVolume[client] = 0.0;
		
		SetEntDataVector(client, g_offsPlayerPunchAngle, flNewPunchAng, true);
		SetEntDataVector(client, g_offsPlayerPunchAngleVel, flNewPunchAngVel, true);
	}
	
	if (g_bPlayerInStaticShake[client])
	{
		if (g_strPlayerStaticShakeSound[client][0])
		{
			new Float:flVolume = g_flPlayerStaticAmount[client];
			if (GetRandomFloat(0.0, 1.0) <= 0.35)
			{
				flVolume = 0.0;
			}
			else
			{
				if (flVolume < g_flPlayerStaticShakeMinVolume[client])
				{
					flVolume = g_flPlayerStaticShakeMinVolume[client];
				}
				
				if (flVolume > g_flPlayerStaticShakeMaxVolume[client])
				{
					flVolume = g_flPlayerStaticShakeMaxVolume[client];
				}
			}
			
			EmitSoundToClient(client, g_strPlayerStaticShakeSound[client], _, SNDCHAN_STATIC, SNDLEVEL_NONE, SND_CHANGEVOL | SND_STOP, flVolume);
		}
		
		// Spazz our view all over the place.
		for (new i = 0; i < 2; i++) flNewPunchAng[i] = AngleNormalize(GetRandomFloat(0.0, 360.0));
		NormalizeVector(flNewPunchAng, flNewPunchAng);
		
		new Float:flAngVelocityScalar = 5.0 * g_flPlayerStaticAmount[client];
		if (flAngVelocityScalar < 1.0) flAngVelocityScalar = 1.0;
		ScaleVector(flNewPunchAng, flAngVelocityScalar);
		
		for (new i = 0; i < 2; i++) flNewPunchAngVel[i] = 0.0;
		
		SetEntDataVector(client, g_offsPlayerPunchAngle, flNewPunchAng, true);
		SetEntDataVector(client, g_offsPlayerPunchAngleVel, flNewPunchAngVel, true);
	}
}

ClientProcessVisibility(client)
{
	if (!IsClientInGame(client) || !IsPlayerAlive(client)) return;
	
	new String:sProfile[SF2_MAX_PROFILE_NAME_LENGTH];
	
	new bool:bWasSeeingSlender[MAX_BOSSES];
	new iOldStaticMode[MAX_BOSSES];
	
	decl Float:flSlenderPos[3];
	decl Float:flSlenderEyePos[3];
	decl Float:flSlenderOBBCenterPos[3];
	
	decl Float:flMyPos[3];
	GetClientAbsOrigin(client, flMyPos);
	
	for (new i = 0; i < MAX_BOSSES; i++)
	{
		bWasSeeingSlender[i] = g_bPlayerSeesSlender[client][i];
		iOldStaticMode[i] = g_iPlayerStaticMode[client][i];
		g_bPlayerSeesSlender[client][i] = false;
		g_iPlayerStaticMode[client][i] = Static_None;
		
		if (NPCGetUniqueID(i) == -1) continue;
		
		NPCGetProfile(i, sProfile, sizeof(sProfile));
		
		new iBoss = NPCGetEntIndex(i);
		
		if (iBoss && iBoss != INVALID_ENT_REFERENCE)
		{
			SlenderGetAbsOrigin(i, flSlenderPos);
			NPCGetEyePosition(i, flSlenderEyePos);
			
			decl Float:flSlenderMins[3], Float:flSlenderMaxs[3];
			GetEntPropVector(iBoss, Prop_Send, "m_vecMins", flSlenderMins);
			GetEntPropVector(iBoss, Prop_Send, "m_vecMaxs", flSlenderMaxs);
			
			for (new i2 = 0; i2 < 3; i2++) flSlenderOBBCenterPos[i2] = flSlenderPos[i2] + ((flSlenderMins[i2] + flSlenderMaxs[i2]) / 2.0);
		}
		
		if (IsClientInGhostMode(client))
		{
		}
		else if (!IsClientInDeathCam(client))
		{
			if (iBoss && iBoss != INVALID_ENT_REFERENCE)
			{
				new iCopyMaster = NPCGetFromUniqueID(g_iSlenderCopyMaster[i]);
				
				if (!IsPointVisibleToPlayer(client, flSlenderEyePos, true, SlenderUsesBlink(i)))
				{
					g_bPlayerSeesSlender[client][i] = IsPointVisibleToPlayer(client, flSlenderOBBCenterPos, true, SlenderUsesBlink(i));
				}
				else
				{
					g_bPlayerSeesSlender[client][i] = true;
				}
				
				if ((GetGameTime() - g_flPlayerSeesSlenderLastTime[client][i]) > GetProfileFloat(sProfile, "static_on_look_gracetime", 1.0) ||
					(iOldStaticMode[i] == Static_Increase && g_flPlayerStaticAmount[client] > 0.1))
				{
					if ((NPCGetFlags(i) & SFF_STATICONLOOK) && 
						g_bPlayerSeesSlender[client][i])
					{
						if (iCopyMaster != -1)
						{
							g_iPlayerStaticMode[client][iCopyMaster] = Static_Increase;
						}
						else
						{
							g_iPlayerStaticMode[client][i] = Static_Increase;
						}
					}
					else if ((NPCGetFlags(i) & SFF_STATICONRADIUS) && 
						GetVectorDistance(flMyPos, flSlenderPos) <= g_flSlenderStaticRadius[i])
					{
						new bool:bNoObstacles = IsPointVisibleToPlayer(client, flSlenderEyePos, false, false);
						if (!bNoObstacles) bNoObstacles = IsPointVisibleToPlayer(client, flSlenderOBBCenterPos, false, false);
						
						if (bNoObstacles)
						{
							if (iCopyMaster != -1)
							{
								g_iPlayerStaticMode[client][iCopyMaster] = Static_Increase;
							}
							else
							{
								g_iPlayerStaticMode[client][i] = Static_Increase;
							}
						}
					}
				}
				
				// Process death cam sequence conditions
				if (SlenderKillsOnNear(i))
				{
					if (g_flPlayerStaticAmount[client] >= 1.0 ||
						GetVectorDistance(flMyPos, flSlenderPos) <= NPCGetInstantKillRadius(i))
					{
						new bool:bKillPlayer = true;
						if (g_flPlayerStaticAmount[client] < 1.0)
						{
							bKillPlayer = IsPointVisibleToPlayer(client, flSlenderEyePos, false, SlenderUsesBlink(i));
						}
						
						if (!bKillPlayer) bKillPlayer = IsPointVisibleToPlayer(client, flSlenderOBBCenterPos, false, SlenderUsesBlink(i));
						
						if (bKillPlayer)
						{
							g_flSlenderLastKill[i] = GetGameTime();
							
							if (g_flPlayerStaticAmount[client] >= 1.0)
							{
								ClientStartDeathCam(client, NPCGetFromUniqueID(g_iPlayerStaticMaster[client]), flSlenderPos);
							}
							else
							{
								ClientStartDeathCam(client, i, flSlenderPos);
							}
						}
					}
				}
			}
		}
		
		new iMaster = NPCGetFromUniqueID(g_iSlenderCopyMaster[i]);
		if (iMaster == -1) iMaster = i;
		
		// Boss visiblity.
		if (g_bPlayerSeesSlender[client][i] && !bWasSeeingSlender[i])
		{
			g_flPlayerSeesSlenderLastTime[client][iMaster] = GetGameTime();
			
			if (GetGameTime() >= g_flPlayerScareNextTime[client][iMaster])
			{
				if (GetVectorDistance(flMyPos, flSlenderPos) <= NPCGetScareRadius(i))
				{
					ClientPerformScare(client, iMaster);
					
					if (NPCHasAttribute(iMaster, "ignite player on scare"))
					{
						new Float:flValue = NPCGetAttributeValue(iMaster, "ignite player on scare");
						if (flValue > 0.0) TF2_IgnitePlayer(client, client);
					}
				}
				else
				{
					g_flPlayerScareNextTime[client][iMaster] = GetGameTime() + GetProfileFloat(sProfile, "scare_cooldown");
				}
			}
			
			if (NPCGetType(i) == SF2BossType_Static)
			{
				if (NPCGetFlags(i) & SFF_FAKE)
				{
					SlenderMarkAsFake(i);
					return;
				}
			}
			
			Call_StartForward(fOnClientLooksAtBoss);
			Call_PushCell(client);
			Call_PushCell(i);
			Call_Finish();
		}
		else if (!g_bPlayerSeesSlender[client][i] && bWasSeeingSlender[i])
		{
			g_flPlayerScareLastTime[client][iMaster] = GetGameTime();
			
			Call_StartForward(fOnClientLooksAwayFromBoss);
			Call_PushCell(client);
			Call_PushCell(i);
			Call_Finish();
		}
		
		if (g_bPlayerSeesSlender[client][i])
		{
			if (GetGameTime() >= g_flPlayerSightSoundNextTime[client][iMaster])
			{
				ClientPerformSightSound(client, i);
			}
		}
		
		if (g_iPlayerStaticMode[client][i] == Static_Increase &&
			iOldStaticMode[i] != Static_Increase)
		{
			if (NPCGetFlags(i) & SFF_HASSTATICLOOPLOCALSOUND)
			{
				decl String:sLoopSound[PLATFORM_MAX_PATH];
				GetRandomStringFromProfile(sProfile, "sound_static_loop_local", sLoopSound, sizeof(sLoopSound), 1);
				
				if (sLoopSound[0])
				{
					EmitSoundToClient(client, sLoopSound, iBoss, SNDCHAN_STATIC, GetProfileNum(sProfile, "sound_static_loop_local_level", SNDLEVEL_NORMAL), SND_CHANGEVOL, 1.0);
					ClientAddStress(client, 0.03);
				}
				else
				{
					LogError("Warning! Boss %s supports static loop local sounds, but was given a blank sound path!", sProfile);
				}
			}
		}
		else if (g_iPlayerStaticMode[client][i] != Static_Increase &&
			iOldStaticMode[i] == Static_Increase)
		{
			if (NPCGetFlags(i) & SFF_HASSTATICLOOPLOCALSOUND)
			{
				if (iBoss && iBoss != INVALID_ENT_REFERENCE)
				{
					decl String:sLoopSound[PLATFORM_MAX_PATH];
					GetRandomStringFromProfile(sProfile, "sound_static_loop_local", sLoopSound, sizeof(sLoopSound), 1);
					
					if (sLoopSound[0])
					{
						EmitSoundToClient(client, sLoopSound, iBoss, SNDCHAN_STATIC, _, SND_CHANGEVOL | SND_STOP, 0.0);
					}
				}
			}
		}
	}
	
	// Initialize static timers.
	new iBossLastStatic = NPCGetFromUniqueID(g_iPlayerStaticMaster[client]);
	new iBossNewStatic = -1;
	if (iBossLastStatic != -1 && g_iPlayerStaticMode[client][iBossLastStatic] == Static_Increase)
	{
		iBossNewStatic = iBossLastStatic;
	}
	
	for (new i = 0; i < MAX_BOSSES; i++)
	{
		new iStaticMode = g_iPlayerStaticMode[client][i];
		
		// Determine new static rates.
		if (iStaticMode != Static_Increase) continue;
		
		if (iBossLastStatic == -1 || 
			g_iPlayerStaticMode[client][iBossLastStatic] != Static_Increase || 
			NPCGetAnger(i) > NPCGetAnger(iBossLastStatic))
		{
			iBossNewStatic = i;
		}
	}
	
	if (iBossNewStatic != -1)
	{
		new iCopyMaster = NPCGetFromUniqueID(g_iSlenderCopyMaster[iBossNewStatic]);
		if (iCopyMaster != -1)
		{
			iBossNewStatic = iCopyMaster;
			g_iPlayerStaticMaster[client] = NPCGetUniqueID(iCopyMaster);
		}
		else
		{
			g_iPlayerStaticMaster[client] = NPCGetUniqueID(iBossNewStatic);
		}
	}
	else
	{
		g_iPlayerStaticMaster[client] = -1;
	}
	
	if (iBossNewStatic != iBossLastStatic)
	{
		if (!StrEqual(g_strPlayerLastStaticSound[client], g_strPlayerStaticSound[client], false))
		{
			// Stop last-last static sound entirely.
			if (g_strPlayerLastStaticSound[client][0])
			{
				StopSound(client, SNDCHAN_STATIC, g_strPlayerLastStaticSound[client]);
			}
		}
		
		// Move everything down towards the last arrays.
		if (g_strPlayerStaticSound[client][0])
		{
			strcopy(g_strPlayerLastStaticSound[client], sizeof(g_strPlayerLastStaticSound[]), g_strPlayerStaticSound[client]);
		}
		
		if (iBossNewStatic == -1)
		{
			// No one is the static master.
			g_hPlayerStaticTimer[client] = CreateTimer(g_flPlayerStaticDecreaseRate[client], 
				Timer_ClientDecreaseStatic, 
				GetClientUserId(client), 
				TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
				
			TriggerTimer(g_hPlayerStaticTimer[client], true);
		}
		else
		{
			NPCGetProfile(iBossNewStatic, sProfile, sizeof(sProfile));
		
			strcopy(g_strPlayerStaticSound[client], sizeof(g_strPlayerStaticSound[]), "");
			
			new String:sStaticSound[PLATFORM_MAX_PATH];
			GetRandomStringFromProfile(sProfile, "sound_static", sStaticSound, sizeof(sStaticSound), 1);
			
			if (sStaticSound[0]) 
			{
				strcopy(g_strPlayerStaticSound[client], sizeof(g_strPlayerStaticSound[]), sStaticSound);
			}
			
			// Cross-fade out the static sounds.
			g_flPlayerLastStaticVolume[client] = g_flPlayerStaticAmount[client];
			g_flPlayerLastStaticTime[client] = GetGameTime();
			
			g_hPlayerLastStaticTimer[client] = CreateTimer(0.0, 
				Timer_ClientFadeOutLastStaticSound, 
				GetClientUserId(client), 
				TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
			
			TriggerTimer(g_hPlayerLastStaticTimer[client], true);
			
			// Start up our own static timer.
			new Float:flStaticIncreaseRate = GetProfileFloat(sProfile, "static_rate") / g_flRoundDifficultyModifier;
			new Float:flStaticDecreaseRate = GetProfileFloat(sProfile, "static_rate_decay");
			
			g_flPlayerStaticIncreaseRate[client] = flStaticIncreaseRate;
			g_flPlayerStaticDecreaseRate[client] = flStaticDecreaseRate;
			
			g_hPlayerStaticTimer[client] = CreateTimer(flStaticIncreaseRate, 
				Timer_ClientIncreaseStatic, 
				GetClientUserId(client), 
				TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
			
			TriggerTimer(g_hPlayerStaticTimer[client], true);
		}
	}
}

ClientProcessViewAngles(client)
{
	if ((!g_bPlayerEliminated[client] || g_bPlayerProxy[client]) && 
		!DidClientEscape(client))
	{
		// Process view bobbing, if enabled.
		// This code is based on the code in this page: https://developer.valvesoftware.com/wiki/Camera_Bob
		// Many thanks to whomever created it in the first place.
		
		if (IsPlayerAlive(client))
		{
			if (g_bPlayerViewbobEnabled)
			{
				new Float:flPunchVel[3];
			
				if (!g_bPlayerViewbobSprintEnabled || !IsClientReallySprinting(client))
				{
					if (GetEntityFlags(client) & FL_ONGROUND)
					{
						decl Float:flVelocity[3];
						GetEntPropVector(client, Prop_Data, "m_vecAbsVelocity", flVelocity);
						new Float:flSpeed = GetVectorLength(flVelocity);
						
						new Float:flPunchIdle[3];
						
						if (flSpeed > 0.0)
						{
							if (flSpeed >= 60.0)
							{
								flPunchIdle[0] = Sine(GetGameTime() * SF2_PLAYER_VIEWBOB_TIMER) * flSpeed * SF2_PLAYER_VIEWBOB_SCALE_X / 400.0;
								flPunchIdle[1] = Sine(2.0 * GetGameTime() * SF2_PLAYER_VIEWBOB_TIMER) * flSpeed * SF2_PLAYER_VIEWBOB_SCALE_Y / 400.0;
								flPunchIdle[2] = Sine(1.6 * GetGameTime() * SF2_PLAYER_VIEWBOB_TIMER) * flSpeed * SF2_PLAYER_VIEWBOB_SCALE_Z / 400.0;
								
								AddVectors(flPunchVel, flPunchIdle, flPunchVel);
							}
							
							// Calculate roll.
							decl Float:flForward[3], Float:flVelocityDirection[3];
							GetClientEyeAngles(client, flForward);
							GetVectorAngles(flVelocity, flVelocityDirection);
							
							new Float:flYawDiff = AngleDiff(flForward[1], flVelocityDirection[1]);
							if (FloatAbs(flYawDiff) > 90.0) flYawDiff = AngleDiff(flForward[1] + 180.0, flVelocityDirection[1]) * -1.0;
							
							new Float:flWalkSpeed = ClientGetDefaultWalkSpeed(client);
							new Float:flRollScalar = flSpeed / flWalkSpeed;
							if (flRollScalar > 1.0) flRollScalar = 1.0;
							
							new Float:flRollScale = (flYawDiff / 90.0) * 0.25 * flRollScalar;
							flPunchIdle[0] = 0.0;
							flPunchIdle[1] = 0.0;
							flPunchIdle[2] = flRollScale * -1.0;
							
							AddVectors(flPunchVel, flPunchIdle, flPunchVel);
						}
						
						/*
						if (flSpeed < 60.0) 
						{
							flPunchIdle[0] = FloatAbs(Cosine(GetGameTime() * 1.25) * 0.047);
							flPunchIdle[1] = Sine(GetGameTime() * 1.25) * 0.075;
							flPunchIdle[2] = 0.0;
							
							AddVectors(flPunchVel, flPunchIdle, flPunchVel);
						}
						*/
					}
				}
				
				if (g_bPlayerViewbobHurtEnabled)
				{
					// Shake screen the more the player is hurt.
					new Float:flHealth = float(GetEntProp(client, Prop_Send, "m_iHealth"));
					new Float:flMaxHealth = float(SDKCall(g_hSDKGetMaxHealth, client));
					
					decl Float:flPunchVelHurt[3];
					flPunchVelHurt[0] = Sine(1.22 * GetGameTime()) * 48.5 * ((flMaxHealth - flHealth) / (flMaxHealth * 0.75)) / flMaxHealth;
					flPunchVelHurt[1] = Sine(2.12 * GetGameTime()) * 80.0 * ((flMaxHealth - flHealth) / (flMaxHealth * 0.75)) / flMaxHealth;
					flPunchVelHurt[2] = Sine(0.5 * GetGameTime()) * 36.0 * ((flMaxHealth - flHealth) / (flMaxHealth * 0.75)) / flMaxHealth;
					
					AddVectors(flPunchVel, flPunchVelHurt, flPunchVel);
				}
				
				ClientViewPunch(client, flPunchVel);
			}
		}
	}
}

public Action:Timer_ClientIncreaseStatic(Handle:timer, any:userid)
{
	new client = GetClientOfUserId(userid);
	if (client <= 0) return Plugin_Stop;
	
	if (timer != g_hPlayerStaticTimer[client]) return Plugin_Stop;
	
	g_flPlayerStaticAmount[client] += 0.05;
	if (g_flPlayerStaticAmount[client] > 1.0) g_flPlayerStaticAmount[client] = 1.0;
	
	if (g_strPlayerStaticSound[client][0])
	{
		EmitSoundToClient(client, g_strPlayerStaticSound[client], _, SNDCHAN_STATIC, SNDLEVEL_NONE, SND_CHANGEVOL, g_flPlayerStaticAmount[client]);
		
		if (g_flPlayerStaticAmount[client] >= 0.5) ClientAddStress(client, 0.03);
		else
		{
			ClientAddStress(client, 0.02);
		}
	}
	
	return Plugin_Continue;
}

public Action:Timer_ClientDecreaseStatic(Handle:timer, any:userid)
{
	new client = GetClientOfUserId(userid);
	if (client <= 0) return Plugin_Stop;
	
	if (timer != g_hPlayerStaticTimer[client]) return Plugin_Stop;
	
	g_flPlayerStaticAmount[client] -= 0.05;
	if (g_flPlayerStaticAmount[client] < 0.0) g_flPlayerStaticAmount[client] = 0.0;
	
	if (g_strPlayerLastStaticSound[client][0])
	{
		new Float:flVolume = g_flPlayerStaticAmount[client];
		if (flVolume > 0.0)
		{
			EmitSoundToClient(client, g_strPlayerLastStaticSound[client], _, SNDCHAN_STATIC, SNDLEVEL_NONE, SND_CHANGEVOL, flVolume);
		}
	}
	
	if (g_flPlayerStaticAmount[client] <= 0.0)
	{
		// I've done my job; no point to keep on doing it.
		StopSound(client, SNDCHAN_STATIC, g_strPlayerLastStaticSound[client]);
		g_hPlayerStaticTimer[client] = INVALID_HANDLE;
		return Plugin_Stop;
	}
	
	return Plugin_Continue;
}

public Action:Timer_ClientFadeOutLastStaticSound(Handle:timer, any:userid)
{
	new client = GetClientOfUserId(userid);
	if (client <= 0) return Plugin_Stop;
	
	if (timer != g_hPlayerLastStaticTimer[client]) return Plugin_Stop;
	
	if (StrEqual(g_strPlayerLastStaticSound[client], g_strPlayerStaticSound[client], false)) 
	{
		// Wait, the player's current static sound is the same one we're stopping. Abort!
		g_hPlayerLastStaticTimer[client] = INVALID_HANDLE;
		return Plugin_Stop;
	}
	
	if (g_strPlayerLastStaticSound[client][0])
	{
		new Float:flDiff = (GetGameTime() - g_flPlayerLastStaticTime[client]) / 1.0;
		if (flDiff > 1.0) flDiff = 1.0;
		
		new Float:flVolume = g_flPlayerLastStaticVolume[client] - flDiff;
		if (flVolume < 0.0) flVolume = 0.0;
		
		if (flVolume <= 0.0)
		{
			// I've done my job; no point to keep on doing it.
			StopSound(client, SNDCHAN_STATIC, g_strPlayerLastStaticSound[client]);
			g_hPlayerLastStaticTimer[client] = INVALID_HANDLE;
			return Plugin_Stop;
		}
		else
		{
			EmitSoundToClient(client, g_strPlayerLastStaticSound[client], _, SNDCHAN_STATIC, SNDLEVEL_NONE, SND_CHANGEVOL, flVolume);
		}
	}
	else
	{
		// I've done my job; no point to keep on doing it.
		g_hPlayerLastStaticTimer[client] = INVALID_HANDLE;
		return Plugin_Stop;
	}
	
	return Plugin_Continue;
}

//	==========================================================
//	INTERACTIVE GLOW FUNCTIONS
//	==========================================================

static ClientProcessInteractiveGlow(client)
{
	if (!IsClientInGame(client) || !IsPlayerAlive(client) || (g_bPlayerEliminated[client] && !g_bPlayerProxy[client]) || IsClientInGhostMode(client)) return;
	
	new iOldLookEntity = EntRefToEntIndex(g_iPlayerInteractiveGlowTargetEntity[client]);
	
	decl Float:flStartPos[3], Float:flMyEyeAng[3];
	GetClientEyePosition(client, flStartPos);
	GetClientEyeAngles(client, flMyEyeAng);
	
	new Handle:hTrace = TR_TraceRayFilterEx(flStartPos, flMyEyeAng, MASK_VISIBLE, RayType_Infinite, TraceRayDontHitPlayers, -1);
	new iEnt = TR_GetEntityIndex(hTrace);
	CloseHandle(hTrace);
	
	if (IsValidEntity(iEnt))
	{
		g_iPlayerInteractiveGlowTargetEntity[client] = EntRefToEntIndex(iEnt);
	}
	else
	{
		g_iPlayerInteractiveGlowTargetEntity[client] = INVALID_ENT_REFERENCE;
	}
	
	if (iEnt != iOldLookEntity)
	{
		ClientRemoveInteractiveGlow(client);
		
		if (IsEntityClassname(iEnt, "prop_dynamic", false))
		{
			decl String:sTargetName[64];
			GetEntPropString(iEnt, Prop_Data, "m_iName", sTargetName, sizeof(sTargetName));
			
			if (StrContains(sTargetName, "sf2_page", false) == 0 || StrContains(sTargetName, "sf2_interact", false) == 0)
			{
				ClientCreateInteractiveGlow(client, iEnt);
			}
		}
	}
}

ClientResetInteractiveGlow(client)
{
	ClientRemoveInteractiveGlow(client);
	g_iPlayerInteractiveGlowTargetEntity[client] = INVALID_ENT_REFERENCE;
}

/**
 *	Removes the player's current interactive glow entity.
 */
ClientRemoveInteractiveGlow(client)
{
#if defined DEBUG
	if (GetConVarInt(g_cvDebugDetail) > 2) DebugMessage("START ClientRemoveInteractiveGlow(%d)", client);
#endif

	new ent = EntRefToEntIndex(g_iPlayerInteractiveGlowEntity[client]);
	if (ent && ent != INVALID_ENT_REFERENCE)
	{
		AcceptEntityInput(ent, "Kill");
	}
	
	g_iPlayerInteractiveGlowEntity[client] = INVALID_ENT_REFERENCE;
	
#if defined DEBUG
	if (GetConVarInt(g_cvDebugDetail) > 2) DebugMessage("END ClientRemoveInteractiveGlow(%d)", client);
#endif
}

/**
 *	Creates an interactive glow for an entity to show to a player.
 */
bool:ClientCreateInteractiveGlow(client, iEnt, const String:sAttachment[]="")
{
	ClientRemoveInteractiveGlow(client);
	
	if (!IsClientInGame(client)) return false;
	
	if (!iEnt || !IsValidEdict(iEnt)) return false;
	
#if defined DEBUG
	if (GetConVarInt(g_cvDebugDetail) > 2) DebugMessage("START ClientCreateInteractiveGlow(%d)", client);
#endif
	
	decl String:sBuffer[PLATFORM_MAX_PATH];
	GetEntPropString(iEnt, Prop_Data, "m_ModelName", sBuffer, sizeof(sBuffer));
	
	if (strlen(sBuffer) == 0) 
	{
		return false;
	}
	
	new ent = CreateEntityByName("tf_taunt_prop");
	if (ent != -1)
	{
		g_iPlayerInteractiveGlowEntity[client] = EntIndexToEntRef(ent);
		
		new Float:flModelScale = GetEntPropFloat(iEnt, Prop_Send, "m_flModelScale");
		
		SetEntityModel(ent, sBuffer);
		DispatchSpawn(ent);
		ActivateEntity(ent);
		SetEntityRenderMode(ent, RENDER_TRANSCOLOR);
		SetEntityRenderColor(ent, 0, 0, 0, 0);
		SetEntProp(ent, Prop_Send, "m_bGlowEnabled", 1);
		SetEntPropFloat(ent, Prop_Send, "m_flModelScale", flModelScale);
		
		new iFlags = GetEntProp(ent, Prop_Send, "m_fEffects");
		SetEntProp(ent, Prop_Send, "m_fEffects", iFlags | (1 << 0));
		
		SetVariantString("!activator");
		AcceptEntityInput(ent, "SetParent", iEnt);
		
		if (sAttachment[0])
		{
			SetVariantString(sAttachment);
			AcceptEntityInput(ent, "SetParentAttachment");
		}
		
		SDKHook(ent, SDKHook_SetTransmit, Hook_InterativeGlowSetTransmit);
		
#if defined DEBUG
		if (GetConVarInt(g_cvDebugDetail) > 2) DebugMessage("END ClientCreateInteractiveGlow(%d) -> true", client);
#endif
		
		return true;
	}
	
#if defined DEBUG
	if (GetConVarInt(g_cvDebugDetail) > 2) DebugMessage("END ClientCreateInteractiveGlow(%d) -> false", client);
#endif
	
	return false;
}

public Action:Hook_InterativeGlowSetTransmit(ent, other)
{
	if (!g_bEnabled) return Plugin_Continue;

	if (EntRefToEntIndex(g_iPlayerInteractiveGlowEntity[other]) != ent) return Plugin_Handled;
	
	return Plugin_Continue;
}

//	==========================================================
//	BREATHING FUNCTIONS
//	==========================================================

ClientResetBreathing(client)
{
	g_bPlayerBreath[client] = false;
	g_hPlayerBreathTimer[client] = INVALID_HANDLE;
}

Float:ClientCalculateBreathingCooldown(client)
{
	new Float:flAverage = 0.0;
	new iAverageNum = 0;
	
	// Sprinting only, for now.
	flAverage += (SF2_PLAYER_BREATH_COOLDOWN_MAX * 6.7765 * Pow((float(g_iPlayerSprintPoints[client]) / 100.0), 1.65));
	iAverageNum++;
	
	flAverage /= float(iAverageNum)
	
	if (flAverage < SF2_PLAYER_BREATH_COOLDOWN_MIN) flAverage = SF2_PLAYER_BREATH_COOLDOWN_MIN;
	
	return flAverage;
}

ClientStartBreathing(client)
{
	g_bPlayerBreath[client] = true;
	g_hPlayerBreathTimer[client] = CreateTimer(ClientCalculateBreathingCooldown(client), Timer_ClientBreath, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
}

ClientStopBreathing(client)
{
	g_bPlayerBreath[client] = false;
	g_hPlayerBreathTimer[client] = INVALID_HANDLE;
}

bool:ClientCanBreath(client)
{
	return bool:(ClientCalculateBreathingCooldown(client) < SF2_PLAYER_BREATH_COOLDOWN_MAX);
}

public Action:Timer_ClientBreath(Handle:timer, any:userid)
{
	new client = GetClientOfUserId(userid);
	if (client <= 0) return;
	
	if (timer != g_hPlayerBreathTimer[client]) return;
	
	if (!g_bPlayerBreath[client]) return;
	
	if (ClientCanBreath(client))
	{
		EmitSoundToAll(g_strPlayerBreathSounds[GetRandomInt(0, sizeof(g_strPlayerBreathSounds) - 1)], client, SNDCHAN_AUTO, SNDLEVEL_SCREAMING);
		
		ClientStartBreathing(client);
		return;
	}
	
	ClientStopBreathing(client);
}

//	==========================================================
//	SPRINTING FUNCTIONS
//	==========================================================

bool:IsClientSprinting(client)
{
	return g_bPlayerSprint[client];
}

ClientGetSprintPoints(client)
{
	return g_iPlayerSprintPoints[client];
}

ClientResetSprint(client)
{
#if defined DEBUG
	if (GetConVarInt(g_cvDebugDetail) > 2) DebugMessage("START ClientResetSprint(%d)", client);
#endif

	g_bPlayerSprint[client] = false;
	g_iPlayerSprintPoints[client] = 100;
	g_hPlayerSprintTimer[client] = INVALID_HANDLE;
	
	if (IsValidClient(client))
	{
		SDKUnhook(client, SDKHook_PreThink, Hook_ClientSprintingPreThink);
		SDKUnhook(client, SDKHook_PreThink, Hook_ClientRechargeSprintPreThink);
		
		ClientSetFOV(client, g_iPlayerDesiredFOV[client]);
	}
	
#if defined DEBUG
	if (GetConVarInt(g_cvDebugDetail) > 2) DebugMessage("END ClientResetSprint(%d)", client);
#endif
}

ClientStartSprint(client)
{
	if (IsClientSprinting(client)) return;
	
	g_bPlayerSprint[client] = true;
	g_hPlayerSprintTimer[client] = INVALID_HANDLE;
	ClientSprintTimer(client);
	TriggerTimer(g_hPlayerSprintTimer[client], true);
	
	SDKHook(client, SDKHook_PreThink, Hook_ClientSprintingPreThink);
	SDKUnhook(client, SDKHook_PreThink, Hook_ClientRechargeSprintPreThink);
}

static ClientSprintTimer(client, bool:bRecharge=false)
{
	new Float:flRate = 0.28;
	if (bRecharge) flRate = 0.8;
	
	decl Float:flVelocity[3];
	GetEntPropVector(client, Prop_Data, "m_vecAbsVelocity", flVelocity);
	
	if (bRecharge)
	{
		if (!(GetEntityFlags(client) & FL_ONGROUND)) flRate *= 0.75;
		else if (GetVectorLength(flVelocity) == 0.0)
		{
			if (GetEntProp(client, Prop_Send, "m_bDucked")) flRate *= 0.66;
			else flRate *= 0.75;
		}
	}
	else
	{
		if (TF2_GetPlayerClass(client) == TFClass_Scout) flRate *= 1.15;
	}
	
	if (bRecharge) g_hPlayerSprintTimer[client] = CreateTimer(flRate, Timer_ClientRechargeSprint, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
	else g_hPlayerSprintTimer[client] = CreateTimer(flRate, Timer_ClientSprinting, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
}

ClientStopSprint(client)
{
	if (!IsClientSprinting(client)) return;
	g_bPlayerSprint[client] = false;
	g_hPlayerSprintTimer[client] = INVALID_HANDLE;
	ClientSprintTimer(client, true);
	
	SDKHook(client, SDKHook_PreThink, Hook_ClientRechargeSprintPreThink);
	SDKUnhook(client, SDKHook_PreThink, Hook_ClientSprintingPreThink);
}

bool:IsClientReallySprinting(client)
{
	if (!IsClientSprinting(client)) return false;
	if (!(GetEntityFlags(client) & FL_ONGROUND)) return false;
	
	decl Float:flVelocity[3];
	GetEntPropVector(client, Prop_Data, "m_vecAbsVelocity", flVelocity);
	if (GetVectorLength(flVelocity) < 30.0) return false;
	
	return true;
}

public Action:Timer_ClientSprinting(Handle:timer, any:userid)
{
	new client = GetClientOfUserId(userid);
	if (client <= 0) return;
	
	if (timer != g_hPlayerSprintTimer[client]) return;
	
	if (!IsClientSprinting(client)) return;
	
	if (g_iPlayerSprintPoints[client] <= 0)
	{
		ClientStopSprint(client);
		g_iPlayerSprintPoints[client] = 0;
		return;
	}
	
	if (IsClientReallySprinting(client)) 
	{
		new iOverride = GetConVarInt(g_cvPlayerInfiniteSprintOverride);
		if ((!g_bRoundInfiniteSprint && iOverride != 1) || iOverride == 0)
		{
			g_iPlayerSprintPoints[client]--;
		}
	}
	
	ClientSprintTimer(client);
}

public Hook_ClientSprintingPreThink(client)
{
	if (!IsClientReallySprinting(client))
	{
		SDKUnhook(client, SDKHook_PreThink, Hook_ClientSprintingPreThink);
		SDKHook(client, SDKHook_PreThink, Hook_ClientRechargeSprintPreThink);
		return;
	}
	
	new iFOV = GetEntData(client, g_offsPlayerDefaultFOV);
	
	new iTargetFOV = g_iPlayerDesiredFOV[client] + 10;
	
	if (iFOV < iTargetFOV)
	{
		new iDiff = RoundFloat(FloatAbs(float(iFOV - iTargetFOV)));
		if (iDiff >= 1)
		{
			ClientSetFOV(client, iFOV + 1);
		}
		else
		{
			ClientSetFOV(client, iTargetFOV);
		}
	}
	else if (iFOV >= iTargetFOV)
	{
		ClientSetFOV(client, iTargetFOV);
		//SDKUnhook(client, SDKHook_PreThink, Hook_ClientSprintingPreThink);
	}
}

public Hook_ClientRechargeSprintPreThink(client)
{
	if (IsClientReallySprinting(client))
	{
		SDKUnhook(client, SDKHook_PreThink, Hook_ClientRechargeSprintPreThink);
		SDKHook(client, SDKHook_PreThink, Hook_ClientSprintingPreThink);
		return;
	}
	
	new iFOV = GetEntData(client, g_offsPlayerDefaultFOV);
	if (iFOV > g_iPlayerDesiredFOV[client])
	{
		new iDiff = RoundFloat(FloatAbs(float(iFOV - g_iPlayerDesiredFOV[client])));
		if (iDiff >= 1)
		{
			ClientSetFOV(client, iFOV - 1);
		}
		else
		{
			ClientSetFOV(client, g_iPlayerDesiredFOV[client]);
		}
	}
	else if (iFOV <= g_iPlayerDesiredFOV[client])
	{
		ClientSetFOV(client, g_iPlayerDesiredFOV[client]);
	}
}

public Action:Timer_ClientRechargeSprint(Handle:timer, any:userid)
{
	new client = GetClientOfUserId(userid);
	if (client <= 0) return;
	
	if (timer != g_hPlayerSprintTimer[client]) return;
	
	if (IsClientSprinting(client)) 
	{
		g_hPlayerSprintTimer[client] = INVALID_HANDLE;
		return;
	}
	
	if (g_iPlayerSprintPoints[client] >= 100)
	{
		g_iPlayerSprintPoints[client] = 100;
		g_hPlayerSprintTimer[client] = INVALID_HANDLE;
		return;
	}
	if (g_iPlayerSprintPoints[client] > 7)
	{
		TF2Attrib_SetByName(client, "increased jump height", 1.0);
	}
	
	g_iPlayerSprintPoints[client]++;
	ClientSprintTimer(client, true);
}

//	==========================================================
//	PROXY / GHOST AND GLOW FUNCTIONS
//	==========================================================

ClientResetProxy(client, bool:bResetFull=true)
{
#if defined DEBUG
	if (GetConVarInt(g_cvDebugDetail) > 2) DebugMessage("START ClientResetProxy(%d)", client);
#endif

	new iOldMaster = NPCGetFromUniqueID(g_iPlayerProxyMaster[client]);
	new String:sOldProfileName[SF2_MAX_PROFILE_NAME_LENGTH];
	if (iOldMaster >= 0)
	{
		NPCGetProfile(iOldMaster, sOldProfileName, sizeof(sOldProfileName));
	}
	
	new bool:bOldProxy = g_bPlayerProxy[client];
	if (bResetFull) 
	{
		g_bPlayerProxy[client] = false;
		g_iPlayerProxyMaster[client] = -1;
	}
	
	g_iPlayerProxyControl[client] = 0;
	g_hPlayerProxyControlTimer[client] = INVALID_HANDLE;
	g_flPlayerProxyControlRate[client] = 0.0;
	g_flPlayerProxyVoiceTimer[client] = INVALID_HANDLE;
	
	if (IsClientInGame(client))
	{
		if (bOldProxy)
		{
			ClientStartProxyAvailableTimer(client);
		
			if (bResetFull)
			{
				SetVariantString("");
				AcceptEntityInput(client, "SetCustomModel");
			}
			
			if (sOldProfileName[0])
			{
				ClientStopAllSlenderSounds(client, sOldProfileName, "sound_proxy_spawn", GetProfileNum(sOldProfileName, "sound_proxy_spawn_channel", SNDCHAN_AUTO));
				ClientStopAllSlenderSounds(client, sOldProfileName, "sound_proxy_hurt", GetProfileNum(sOldProfileName, "sound_proxy_hurt_channel", SNDCHAN_AUTO));
			}
		}
	}
	
#if defined DEBUG
	if (GetConVarInt(g_cvDebugDetail) > 2) DebugMessage("END ClientResetProxy(%d)", client);
#endif
}

ClientStartProxyAvailableTimer(client)
{
	g_bPlayerProxyAvailable[client] = false;
	g_hPlayerProxyAvailableTimer[client] = CreateTimer(GetConVarFloat(g_cvPlayerProxyWaitTime), Timer_ClientProxyAvailable, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
}

ClientStartProxyForce(client, iSlenderID, const Float:flPos[3])
{
#if defined DEBUG
	if (GetConVarInt(g_cvDebugDetail) > 2) DebugMessage("START ClientStartProxyForce(%d, %d, flPos)", client, iSlenderID);
#endif

	g_iPlayerProxyAskMaster[client] = iSlenderID;
	for (new i = 0; i < 3; i++) g_iPlayerProxyAskPosition[client][i] = flPos[i];

	g_iPlayerProxyAvailableCount[client] = 0;
	g_bPlayerProxyAvailableInForce[client] = true;
	g_hPlayerProxyAvailableTimer[client] = CreateTimer(1.0, Timer_ClientForceProxy, GetClientUserId(client), TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
	TriggerTimer(g_hPlayerProxyAvailableTimer[client], true);
	
#if defined DEBUG
	if (GetConVarInt(g_cvDebugDetail) > 2) DebugMessage("END ClientStartProxyForce(%d, %d, flPos)", client, iSlenderID);
#endif
}

ClientStopProxyForce(client)
{
	g_iPlayerProxyAvailableCount[client] = 0;
	g_bPlayerProxyAvailableInForce[client] = false;
	g_hPlayerProxyAvailableTimer[client] = INVALID_HANDLE;
}

public Action:Timer_ClientForceProxy(Handle:timer, any:userid)
{
	new client = GetClientOfUserId(userid);
	if (client <= 0) return Plugin_Stop;
	
	if (timer != g_hPlayerProxyAvailableTimer[client]) return Plugin_Stop;
	
	if (!IsRoundEnding())
	{
		new iBossIndex = NPCGetFromUniqueID(g_iPlayerProxyAskMaster[client]);
		if (iBossIndex != -1)
		{
			decl String:sProfile[SF2_MAX_PROFILE_NAME_LENGTH];
			NPCGetProfile(iBossIndex, sProfile, sizeof(sProfile));
		
			new iMaxProxies = GetProfileNum(sProfile, "proxies_max");
			new iNumProxies = 0;
			
			for (new iClient = 1; iClient <= MaxClients; iClient++)
			{
				if (!IsClientInGame(iClient) || !g_bPlayerEliminated[iClient]) continue;
				if (!g_bPlayerProxy[iClient]) continue;
				if (NPCGetFromUniqueID(g_iPlayerProxyMaster[iClient]) != iBossIndex) continue;
				
				iNumProxies++;
			}
			
			if (iNumProxies < iMaxProxies)
			{
				if (g_iPlayerProxyAvailableCount[client] > 0)
				{
					g_iPlayerProxyAvailableCount[client]--;
					
					SetHudTextParams(-1.0, 0.25, 
						1.0,
						255, 255, 255, 255,
						_,
						_,
						0.25, 1.25);
					
					ShowSyncHudText(client, g_hHudSync, "%T", "SF2 Proxy Force Message", client, g_iPlayerProxyAvailableCount[client]);
					
					return Plugin_Continue;
				}
				else
				{
					ClientEnableProxy(client, iBossIndex);
					TeleportEntity(client, g_iPlayerProxyAskPosition[client], NULL_VECTOR, Float:{ 0.0, 0.0, 0.0 });
				}
			}
			else
			{
				PrintToChat(client, "%T", "SF2 Too Many Proxies", client);
			}
		}
	}
	
	ClientStopProxyForce(client);
	return Plugin_Stop;
}

DisplayProxyAskMenu(client, iAskMaster, const Float:flPos[3])
{
	decl String:sBuffer[512];
	new Handle:hMenu = CreateMenu(Menu_ProxyAsk);
	SetMenuTitle(hMenu, "%T\n \n%T\n \n", "SF2 Proxy Ask Menu Title", client, "SF2 Proxy Ask Menu Description", client);
	
	Format(sBuffer, sizeof(sBuffer), "%T", "Yes", client);
	AddMenuItem(hMenu, "1", sBuffer);
	Format(sBuffer, sizeof(sBuffer), "%T", "No", client);
	AddMenuItem(hMenu, "0", sBuffer);
	
	g_iPlayerProxyAskMaster[client] = iAskMaster;
	for (new i = 0; i < 3; i++) g_iPlayerProxyAskPosition[client][i] = flPos[i];
	DisplayMenu(hMenu, client, 15);
}

public Menu_ProxyAsk(Handle:menu, MenuAction:action, param1, param2)
{
	switch (action)
	{
		case MenuAction_End: CloseHandle(menu);
		case MenuAction_Select:
		{
			if (!IsRoundEnding())
			{
				new iBossIndex = NPCGetFromUniqueID(g_iPlayerProxyAskMaster[param1]);
				if (iBossIndex != -1)
				{
					decl String:sProfile[SF2_MAX_PROFILE_NAME_LENGTH];
					NPCGetProfile(iBossIndex, sProfile, sizeof(sProfile));
				
					new iMaxProxies = GetProfileNum(sProfile, "proxies_max");
					new iNumProxies;
				
					for (new iClient = 1; iClient <= MaxClients; iClient++)
					{
						if (!IsClientInGame(iClient) || !g_bPlayerEliminated[iClient]) continue;
						if (!g_bPlayerProxy[iClient]) continue;
						if (NPCGetFromUniqueID(g_iPlayerProxyMaster[iClient]) != iBossIndex) continue;
						
						iNumProxies++;
					}
					
					if (iNumProxies < iMaxProxies)
					{
						if (param2 == 0)
						{
							if(!IsPointVisibleToAPlayer(g_iPlayerProxyAskPosition[param1], _, false))
							{
								ClientEnableProxy(param1, iBossIndex);
								/*decl String:sName[64];
								new ent = -1;
								while ((ent = FindEntityByClassname(ent, "info_target")) != -1)
								{
									GetEntPropString(ent, Prop_Data, "m_iName", sName, sizeof(sName));
									if (StrEqual(sName, "sf2_proxy_spawn_point", false))
									{
										GetEntPropVector(ent, Prop_Data, "m_vecAbsOrigin", g_iPlayerProxyAskPosition[param1]);
										break;
									}
								}*/
								TeleportEntity(param1, g_iPlayerProxyAskPosition[param1], NULL_VECTOR, Float:{ 0.0, 0.0, 0.0 });
							}
							else
							{
								CPrintToChat(param1, "%T", "SF2 Too Much Time", param1);
							}
						}
						else
						{
							ClientStartProxyAvailableTimer(param1);
						}
					}
					else
					{
						PrintToChat(param1, "%T", "SF2 Too Many Proxies", param1);
					}
				}
			}
		}
	}
}

public Action:Timer_ClientProxyAvailable(Handle:timer, any:userid)
{
	new client = GetClientOfUserId(userid);
	if (client <= 0) return;
	
	if (timer != g_hPlayerProxyAvailableTimer[client]) return;
	
	g_bPlayerProxyAvailable[client] = true;
	g_hPlayerProxyAvailableTimer[client] = INVALID_HANDLE;
}

ClientEnableProxy(client, iBossIndex)
{
	if (NPCGetUniqueID(iBossIndex) == -1) return;
	if (!(NPCGetFlags(iBossIndex) & SFF_PROXIES)) return;
	if (g_bPlayerProxy[client]) return;
	
	TF2_RemoveCondition(client, TFCond:82);
	
	decl String:sProfile[SF2_MAX_PROFILE_NAME_LENGTH];
	NPCGetProfile(iBossIndex, sProfile, sizeof(sProfile));
	
	PvP_SetPlayerPvPState(client, false, false, false);
	
	ClientSetGhostModeState(client, false);
	
	ClientStopProxyForce(client);
	
	ChangeClientTeamNoSuicide(client, _:TFTeam_Blue);
	if (!IsPlayerAlive(client)) TF2_RespawnPlayer(client);
	// Speed recalculation. Props to the creators of FF2/VSH for this snippet.
	TF2_AddCondition(client, TFCond_SpeedBuffAlly, 0.001);
	
	g_bPlayerProxy[client] = true;
	g_iPlayerProxyMaster[client] = NPCGetUniqueID(iBossIndex);
	g_iPlayerProxyControl[client] = 100;
	g_flPlayerProxyControlRate[client] = GetProfileFloat(sProfile, "proxies_controldrainrate");
	g_hPlayerProxyControlTimer[client] = CreateTimer(g_flPlayerProxyControlRate[client], Timer_ClientProxyControl, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
	g_bPlayerProxyAvailable[client] = false;
	g_hPlayerProxyAvailableTimer[client] = INVALID_HANDLE;
	
	decl String:sAllowedClasses[512];
	GetProfileString(sProfile, "proxies_classes", sAllowedClasses, sizeof(sAllowedClasses));
	
	decl String:sClassName[64];
	TF2_GetClassName(TF2_GetPlayerClass(client), sClassName, sizeof(sClassName));
	if (sAllowedClasses[0] && sClassName[0] && StrContains(sAllowedClasses, sClassName, false) == -1)
	{
		// Pick the first class that's allowed.
		new String:sAllowedClassesList[32][32];
		new iClassCount = ExplodeString(sAllowedClasses, " ", sAllowedClassesList, 32, 32);
		if (iClassCount)
		{
			TF2_SetPlayerClass(client, TF2_GetClass(sAllowedClassesList[0]), _, false);
			
			new iMaxHealth = GetEntProp(client, Prop_Send, "m_iHealth");
			TF2_RegeneratePlayer(client);
			SetEntProp(client, Prop_Data, "m_iHealth", iMaxHealth);
			SetEntProp(client, Prop_Send, "m_iHealth", iMaxHealth);
		}
	}
	
	UTIL_ScreenFade(client, 200, 1, FFADE_IN, 255, 255, 255, 100);
	PrecacheSound("weapons/teleporter_send.wav");
	EmitSoundToClient(client, "weapons/teleporter_send.wav", _, SNDCHAN_STATIC);
	
	ClientActivateUltravision(client);
	
	CreateTimer(0.33, Timer_ApplyCustomModel, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
	
	Call_StartForward(fOnClientSpawnedAsProxy);
	Call_PushCell(client);
	Call_Finish();
}
//RequestFrame//
public ProxyDeathAnimation(any:client)
{
	if(g_iClientFrame[client]>=g_iClientMaxFrameDeathAnim[client])
	{
		g_iClientFrame[client]=-1;
		KillClient(client);
	}
	else
	{
		g_iClientFrame[client]+=1;
		RequestFrame(ProxyDeathAnimation,client);
	}
}
	
public Action:Timer_ClientProxyControl(Handle:timer, any:userid)
{
	new client = GetClientOfUserId(userid);
	if (client <= 0) return;
	
	if (timer != g_hPlayerProxyControlTimer[client]) return;
	
	g_iPlayerProxyControl[client]--;
	if (g_iPlayerProxyControl[client] <= 0)
	{
		// ForcePlayerSuicide isn't really dependable, since the player doesn't suicide until several seconds after spawning has passed.
		SDKHooks_TakeDamage(client, client, client, 9001.0, DMG_PREVENT_PHYSICS_FORCE, _, Float:{ 0.0, 0.0, 0.0 });
		return;
	}
	
	g_hPlayerProxyControlTimer[client] = CreateTimer(g_flPlayerProxyControlRate[client], Timer_ClientProxyControl, userid, TIMER_FLAG_NO_MAPCHANGE);
}

bool:DoesClientHaveConstantGlow(client)
{
	return g_bPlayerConstantGlowEnabled[client];
}

ClientDisableConstantGlow(client)
{
	if (!DoesClientHaveConstantGlow(client)) return;
	
#if defined DEBUG
	if (GetConVarInt(g_cvDebugDetail) > 2) DebugMessage("START ClientDisableConstantGlow(%d)", client);
#endif
	
	g_bPlayerConstantGlowEnabled[client] = false;
	
	new iGlow = EntRefToEntIndex(g_iPlayerConstantGlowEntity[client]);
	if (iGlow && iGlow != INVALID_ENT_REFERENCE) AcceptEntityInput(iGlow, "Kill");
	
	g_iPlayerConstantGlowEntity[client] = INVALID_ENT_REFERENCE;
	
#if defined DEBUG
	if (GetConVarInt(g_cvDebugDetail) > 2) DebugMessage("END ClientDisableConstantGlow(%d)", client);
#endif
}
public Action:DelayClientGlow(Handle:timer,any:client)
{
	//To-Do change this bad code.
	if(IsValidClient(client))
	{
		ClientDisableConstantGlow(client);
		if (!DidClientEscape(client))
		{
			ClientEnableConstantGlow(client, "head");
		}
	}
}
bool:ClientEnableConstantGlow(client, const String:sAttachment[]="")
{
	if (DoesClientHaveConstantGlow(client)) return true;
	
#if defined DEBUG
	if (GetConVarInt(g_cvDebugDetail) > 2) DebugMessage("START ClientEnableConstantGlow(%d)", client);
#endif
	
	decl String:sModel[PLATFORM_MAX_PATH];
	GetEntPropString(client, Prop_Data, "m_ModelName", sModel, sizeof(sModel));
	
	if (strlen(sModel) == 0) 
	{
		// For some reason the model couldn't be found, so no.
		
#if defined DEBUG
		if (GetConVarInt(g_cvDebugDetail) > 2) DebugMessage("END ClientEnableConstantGlow(%d) -> false (no model specified)", client);
#endif
		
		return false;
	}
	
	new iGlow = CreateEntityByName("tf_taunt_prop");
	if (iGlow != -1)
	{
#if defined DEBUG
		if (GetConVarInt(g_cvDebugDetail) > 2) DebugMessage("tf_taunt_prop -> created");
#endif
	
		g_bPlayerConstantGlowEnabled[client] = true;
		g_iPlayerConstantGlowEntity[client] = EntIndexToEntRef(iGlow);
		
		new Float:flModelScale = GetEntPropFloat(client, Prop_Send, "m_flModelScale");
		
#if defined DEBUG
		if (GetConVarInt(g_cvDebugDetail) > 2) 
		{
			DebugMessage("tf_taunt_prop -> get model and model scale (%s, %f, player class: %d)", sModel, flModelScale, TF2_GetPlayerClass(client));
		}
#endif
		
		SetEntityModel(iGlow, sModel);
		DispatchSpawn(iGlow);
		ActivateEntity(iGlow);
		SetEntityRenderMode(iGlow, RENDER_TRANSCOLOR);
		SetEntityRenderColor(iGlow, 0, 0, 0, 0);
		SetEntProp(iGlow, Prop_Send, "m_bGlowEnabled", 1);
		SetEntPropFloat(iGlow, Prop_Send, "m_flModelScale", flModelScale);
		
#if defined DEBUG
		if (GetConVarInt(g_cvDebugDetail) > 2) DebugMessage("tf_taunt_prop -> set model and model scale");
#endif
		
		// Set effect flags.
		new iFlags = GetEntProp(iGlow, Prop_Send, "m_fEffects");
		SetEntProp(iGlow, Prop_Send, "m_fEffects", iFlags | (1 << 0)); // EF_BONEMERGE
		
#if defined DEBUG
		if (GetConVarInt(g_cvDebugDetail) > 2) DebugMessage("tf_taunt_prop -> set bonemerge flags");
#endif
		
		SetVariantString("!activator");
		AcceptEntityInput(iGlow, "SetParent", client);
		
#if defined DEBUG
		if (GetConVarInt(g_cvDebugDetail) > 2) DebugMessage("tf_taunt_prop -> set parent to client");
#endif
		
		if (sAttachment[0])
		{
			SetVariantString(sAttachment);
			AcceptEntityInput(iGlow, "SetParentAttachment");
		}
		
#if defined DEBUG
		if (GetConVarInt(g_cvDebugDetail) > 2) DebugMessage("tf_taunt_prop -> set parent attachment to %s", sAttachment);
#endif
		
		SDKHook(iGlow, SDKHook_SetTransmit, Hook_ConstantGlowSetTransmit);
		
#if defined DEBUG
		if (GetConVarInt(g_cvDebugDetail) > 2) DebugMessage("END ClientEnableConstantGlow(%d) -> true", client);
#endif
		
		return true;
	}
	
#if defined DEBUG
	if (GetConVarInt(g_cvDebugDetail) > 2) DebugMessage("END ClientEnableConstantGlow(%d) -> false", client);
#endif
	
	return false;
}

ClientResetJumpScare(client)
{
#if defined DEBUG
	if (GetConVarInt(g_cvDebugDetail) > 2) DebugMessage("START ClientResetJumpScare(%d)", client);
#endif

	g_iPlayerJumpScareBoss[client] = -1;
	g_flPlayerJumpScareLifeTime[client] = -1.0;
	
#if defined DEBUG
	if (GetConVarInt(g_cvDebugDetail) > 2) DebugMessage("END ClientResetJumpScare(%d)", client);
#endif
}

ClientDoJumpScare(client, iBossIndex, Float:flLifeTime)
{
	g_iPlayerJumpScareBoss[client] = NPCGetUniqueID(iBossIndex);
	g_flPlayerJumpScareLifeTime[client] = GetGameTime() + flLifeTime;
	
	decl String:sProfile[SF2_MAX_PROFILE_NAME_LENGTH];
	NPCGetProfile(iBossIndex, sProfile, sizeof(sProfile));
	
	decl String:sBuffer[PLATFORM_MAX_PATH];
	GetRandomStringFromProfile(sProfile, "sound_jumpscare", sBuffer, sizeof(sBuffer), 1);
	
	if (strlen(sBuffer) > 0)
	{
		EmitSoundToClient(client, sBuffer, _, MUSIC_CHAN);
	}
}

 /**
  *	Handles sprinting upon player input.
  */
ClientHandleSprint(client, bool:bSprint)
{
	if (!IsPlayerAlive(client) || 
		g_bPlayerEliminated[client] || 
		DidClientEscape(client) || 
		g_bPlayerProxy[client] || 
		IsClientInGhostMode(client)) return;
	
	if (bSprint)
	{
		if (g_iPlayerSprintPoints[client] > 0)
		{
			ClientStartSprint(client);
		}
		else
		{
			EmitSoundToClient(client, FLASHLIGHT_NOSOUND, _, SNDCHAN_ITEM, SNDLEVEL_NONE);
		}
	}
	else
	{
		if (IsClientSprinting(client))
		{
			ClientStopSprint(client);
		}
	}
}

ClientOnButtonPress(client, button)
{
	switch (button)
	{
		case IN_ATTACK2:
		{
			if (IsPlayerAlive(client))
			{
				if (!IsRoundInWarmup() &&
					!IsRoundInIntro() &&
					!IsRoundEnding() && 
					!DidClientEscape(client))
				{
					if (GetGameTime() >= ClientGetFlashlightNextInputTime(client))
					{
						ClientHandleFlashlight(client);
					}
				}
			}
		}
		case IN_ATTACK3:
		{
			ClientHandleSprint(client, true);
		}
		case IN_RELOAD:
		{
			if (IsPlayerAlive(client))
			{
				if (!g_bPlayerEliminated[client])
				{
					if (!IsRoundEnding() && 
						!IsRoundInWarmup() &&
						!IsRoundInIntro() &&
						!DidClientEscape(client))
					{
						ClientBlink(client);
					}
				}
			}
		}
		case IN_JUMP:
		{
			if (IsPlayerAlive(client) && !(GetEntityFlags(client) & FL_FROZEN))
			{
				if (!bool:GetEntProp(client, Prop_Send, "m_bDucked") && 
					(GetEntityFlags(client) & FL_ONGROUND) &&
					GetEntProp(client, Prop_Send, "m_nWaterLevel") < 2)
				{
					ClientOnJump(client);
				}
			}
		}
	}
}

ClientOnButtonRelease(client, button)
{
	switch (button)
	{
		case IN_ATTACK3:
		{
			ClientHandleSprint(client, false);
		}
	}
}

ClientOnJump(client)
{
	if (!g_bPlayerEliminated[client])
	{
		if (!IsRoundEnding() && !IsRoundInWarmup() && !DidClientEscape(client))
		{
			new iOverride = GetConVarInt(g_cvPlayerInfiniteSprintOverride);
			if ((!g_bRoundInfiniteSprint && iOverride != 1) || iOverride == 0)
			{
				if(g_iPlayerSprintPoints[client] > 10)
				{
					g_iPlayerSprintPoints[client] -= 7;
					if (g_iPlayerSprintPoints[client] < 0) g_iPlayerSprintPoints[client] = 0;
					if (g_iPlayerSprintPoints[client] < 7) TF2Attrib_SetByName(client, "increased jump height", 0.0);
				}
			}
			
			if (!IsClientSprinting(client))
			{
				if (g_hPlayerSprintTimer[client] == INVALID_HANDLE)
				{
					// If the player hasn't sprinted recently, force us to regenerate the stamina.
					ClientSprintTimer(client, true);
				}
			}
		}
	}
}

//	==========================================================
//	DEATH CAM FUNCTIONS
//	==========================================================

bool:IsClientInDeathCam(client)
{
	return g_bPlayerDeathCam[client];
}

public Action:Hook_DeathCamSetTransmit(slender, other)
{
	if (!g_bEnabled) return Plugin_Continue;

	if (EntRefToEntIndex(g_iPlayerDeathCamEnt2[other]) != slender) return Plugin_Handled;
	return Plugin_Continue;
}

ClientResetDeathCam(client)
{
	if (!IsClientInDeathCam(client)) return; // no really need to reset if it wasn't set.
	
#if defined DEBUG
	if (GetConVarInt(g_cvDebugDetail) > 2) DebugMessage("START ClientResetDeathCam(%d)", client);
#endif
	
	new iDeathCamBoss = NPCGetFromUniqueID(g_iPlayerDeathCamBoss[client]);
	
	g_iPlayerDeathCamBoss[client] = -1;
	g_bPlayerDeathCam[client] = false;
	g_bPlayerDeathCamShowOverlay[client] = false;
	g_hPlayerDeathCamTimer[client] = INVALID_HANDLE;
	
	new ent = EntRefToEntIndex(g_iPlayerDeathCamEnt[client]);
	if (ent && ent != INVALID_ENT_REFERENCE)
	{
		AcceptEntityInput(ent, "Disable");
		AcceptEntityInput(ent, "Kill");
	}
	
	ent = EntRefToEntIndex(g_iPlayerDeathCamEnt2[client]);
	if (ent && ent != INVALID_ENT_REFERENCE)
	{
		AcceptEntityInput(ent, "Kill");
	}
	
	g_iPlayerDeathCamEnt[client] = INVALID_ENT_REFERENCE;
	g_iPlayerDeathCamEnt2[client] = INVALID_ENT_REFERENCE;
	
	if (IsClientInGame(client))
	{
		SetClientViewEntity(client, client);
	}
	
	Call_StartForward(fOnClientEndDeathCam);
	Call_PushCell(client);
	Call_PushCell(iDeathCamBoss);
	Call_Finish();
	
#if defined DEBUG
	if (GetConVarInt(g_cvDebugDetail) > 2) DebugMessage("END ClientResetDeathCam(%d)", client);
#endif
}

ClientStartDeathCam(client, iBossIndex, const Float:vecLookPos[3])
{
	if (IsClientInDeathCam(client)) return;
	if (!NPCIsValid(iBossIndex)) return;
	
	decl String:buffer[PLATFORM_MAX_PATH];
	
	decl String:sProfile[SF2_MAX_PROFILE_NAME_LENGTH];
	NPCGetProfile(iBossIndex, sProfile, sizeof(sProfile));
	
	if (GetProfileNum(sProfile, "death_cam_play_scare_sound"))
	{
		GetRandomStringFromProfile(sProfile, "sound_scare_player", buffer, sizeof(buffer));
		if (buffer[0]) EmitSoundToClient(client, buffer, _, MUSIC_CHAN, SNDLEVEL_NONE);
	}
	
	GetRandomStringFromProfile(sProfile, "sound_player_deathcam", buffer, sizeof(buffer));
	if (strlen(buffer) > 0) 
	{
		EmitSoundToClient(client, buffer, _, MUSIC_CHAN, SNDLEVEL_NONE);
	}
	else
	{
		// Legacy support for "sound_player_death"
		GetRandomStringFromProfile(sProfile, "sound_player_death", buffer, sizeof(buffer));
		if (strlen(buffer) > 0)
		{
			EmitSoundToClient(client, buffer, _, MUSIC_CHAN, SNDLEVEL_NONE);
		}
	}
	
	GetRandomStringFromProfile(sProfile, "sound_player_deathcam_all", buffer, sizeof(buffer));
	if (strlen(buffer) > 0) 
	{
		EmitSoundToAll(buffer, _, MUSIC_CHAN, SNDLEVEL_NONE);
	}
	else
	{
		// Legacy support for "sound_player_death_all"
		GetRandomStringFromProfile(sProfile, "sound_player_death_all", buffer, sizeof(buffer));
		if (strlen(buffer) > 0) 
		{
			EmitSoundToAll(buffer, _, MUSIC_CHAN, SNDLEVEL_NONE);
		}
	}
	
	// Call our forward.
	Call_StartForward(fOnClientCaughtByBoss);
	Call_PushCell(client);
	Call_PushCell(iBossIndex);
	Call_Finish();
	
	if (!NPCHasDeathCamEnabled(iBossIndex))
	{
		SetEntProp(client, Prop_Data, "m_takedamage", 2); // We do this because the point_viewcontrol changes our lifestate.
		
		// TODO: Add more attributes!
		if (NPCHasAttribute(iBossIndex, "ignite player on death"))
		{
			new Float:flValue = NPCGetAttributeValue(iBossIndex, "ignite player on death");
			if (flValue > 0.0) TF2_IgnitePlayer(client, client);
		}
		
		SDKHooks_TakeDamage(client, 0, 0, 9001.0, 0x80 | DMG_PREVENT_PHYSICS_FORCE, _, Float:{ 0.0, 0.0, 0.0 });
		ForcePlayerSuicide(client);//Sometimes SDKHooks_TakeDamage doesn't work (probably because of point_viewcontrol), the player still alive and result in a endless round.
		SetVariantInt(9001);//Maybe it doesn't work like SDKHooks_TakeDamage, maybe not. Tbh I don't want to test this one.
		AcceptEntityInput(client, "RemoveHealth");
		return;
	}
	
	g_iPlayerDeathCamBoss[client] = NPCGetUniqueID(iBossIndex);
	g_bPlayerDeathCam[client] = true;
	g_bPlayerDeathCamShowOverlay[client] = false;
	
	decl Float:eyePos[3], Float:eyeAng[3], Float:vecAng[3];
	GetClientEyePosition(client, eyePos);
	GetClientEyeAngles(client, eyeAng);
	SubtractVectors(eyePos, vecLookPos, vecAng);
	GetVectorAngles(vecAng, vecAng);
	vecAng[0] = 0.0;
	vecAng[2] = 0.0;
	
	// Create fake model.
	new slender = SpawnSlenderModel(iBossIndex, vecLookPos);
	TeleportEntity(slender, vecLookPos, vecAng, NULL_VECTOR);
	g_iPlayerDeathCamEnt2[client] = EntIndexToEntRef(slender);
	SDKHook(slender, SDKHook_SetTransmit, Hook_DeathCamSetTransmit);
	
	// Create camera look point.
	decl String:sName[64];
	Format(sName, sizeof(sName), "sf2_boss_%d", EntIndexToEntRef(slender));
	
	decl Float:flOffsetPos[3];
	new target = CreateEntityByName("info_target");
	GetProfileVector(sProfile, "death_cam_pos", flOffsetPos);
	AddVectors(vecLookPos, flOffsetPos, flOffsetPos);
	TeleportEntity(target, flOffsetPos, NULL_VECTOR, NULL_VECTOR);
	DispatchKeyValue(target, "targetname", sName);
	SetVariantString("!activator");
	AcceptEntityInput(target, "SetParent", slender);
	
	// Create the camera itself.
	new camera = CreateEntityByName("point_viewcontrol");
	TeleportEntity(camera, eyePos, eyeAng, NULL_VECTOR);
	DispatchKeyValue(camera, "spawnflags", "12");
	DispatchKeyValue(camera, "target", sName);
	DispatchSpawn(camera);
	AcceptEntityInput(camera, "Enable", client);
	g_iPlayerDeathCamEnt[client] = EntIndexToEntRef(camera);
	
	if (GetProfileNum(sProfile, "death_cam_overlay") && GetProfileFloat(sProfile, "death_cam_time_overlay_start") >= 0.0)
	{
		g_hPlayerDeathCamTimer[client] = CreateTimer(GetProfileFloat(sProfile, "death_cam_time_overlay_start"), Timer_ClientResetDeathCam1, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
	}
	else
	{
		g_hPlayerDeathCamTimer[client] = CreateTimer(GetProfileFloat(sProfile, "death_cam_time_death"), Timer_ClientResetDeathCamEnd, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
	}
	
	TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, Float:{ 0.0, 0.0, 0.0 });
	
	Call_StartForward(fOnClientStartDeathCam);
	Call_PushCell(client);
	Call_PushCell(iBossIndex);
	Call_Finish();
}

public Action:Timer_ClientResetDeathCam1(Handle:timer, any:userid)
{
	new client = GetClientOfUserId(userid);
	if (client <= 0) return;
	
	if (timer != g_hPlayerDeathCamTimer[client]) return;
	
	new iDeathCamBoss = NPCGetFromUniqueID(g_iPlayerDeathCamBoss[client]);
	
	decl String:sProfile[SF2_MAX_PROFILE_NAME_LENGTH];
	NPCGetProfile(iDeathCamBoss, sProfile, sizeof(sProfile));
	
	g_bPlayerDeathCamShowOverlay[client] = true;
	g_hPlayerDeathCamTimer[client] = CreateTimer(GetProfileFloat(sProfile, "death_cam_time_death"), Timer_ClientResetDeathCamEnd, userid, TIMER_FLAG_NO_MAPCHANGE);
}

public Action:Timer_ClientResetDeathCamEnd(Handle:timer, any:userid)
{
	new client = GetClientOfUserId(userid);
	if (client <= 0) return;
	
	if (timer != g_hPlayerDeathCamTimer[client]) return;
	
	SetEntProp(client, Prop_Data, "m_takedamage", 2); // We do this because the point_viewcontrol entity changes our damage state.
	
	new iDeathCamBoss = NPCGetFromUniqueID(g_iPlayerDeathCamBoss[client]);
	if (iDeathCamBoss != -1)
	{
		if (NPCHasAttribute(iDeathCamBoss, "ignite player on death"))
		{
			new Float:flValue = NPCGetAttributeValue(iDeathCamBoss, "ignite player on death");
			if (flValue > 0.0) TF2_IgnitePlayer(client, client);
		}
		if (!(NPCGetFlags(iDeathCamBoss) & SFF_FAKE))
		{
			SDKHooks_TakeDamage(client, 0, 0, 9001.0, 0x80 | DMG_PREVENT_PHYSICS_FORCE, _, Float:{ 0.0, 0.0, 0.0 });
			ForcePlayerSuicide(client);//Sometimes SDKHooks_TakeDamage doesn't work (probably because of point_viewcontrol), the player still alive and result in a endless round.
			SetVariantInt(9001);//Maybe it doesn't work like SDKHooks_TakeDamage, maybe not. Tbh I don't want to test this one.
			AcceptEntityInput(client, "RemoveHealth");
		}
		else
			SlenderMarkAsFake(iDeathCamBoss);	
	}
	else//The boss is invalid? But the player got a death cam?
	{
		//Then kill him anyways.
		SDKHooks_TakeDamage(client, 0, 0, 9001.0, 0x80 | DMG_PREVENT_PHYSICS_FORCE, _, Float:{ 0.0, 0.0, 0.0 });
		ForcePlayerSuicide(client);
		SetVariantInt(9001);
	}
	ClientResetDeathCam(client);
}

//	==========================================================
//	GHOST MODE FUNCTIONS
//	==========================================================

static bool:g_bPlayerGhostMode[MAXPLAYERS + 1] = { false, ... };
static g_iPlayerGhostModeTarget[MAXPLAYERS + 1] = { INVALID_ENT_REFERENCE, ... };
static Handle:g_hPlayerGhostModeConnectionCheckTimer[MAXPLAYERS + 1] = { INVALID_HANDLE, ... };
static Float:g_flPlayerGhostModeConnectionTimeOutTime[MAXPLAYERS + 1] = { -1.0, ... };
static Float:g_flPlayerGhostModeConnectionBootTime[MAXPLAYERS + 1] = { -1.0, ... };

/**
 *	Enables/Disables ghost mode on the player.
 */
ClientSetGhostModeState(client, bool:bState)
{
	if (bState == g_bPlayerGhostMode[client]) return;
	
	if (bState && !IsClientInGame(client)) return;
	
	g_bPlayerGhostMode[client] = bState;
	g_iPlayerGhostModeTarget[client] = INVALID_ENT_REFERENCE;
	
	if (bState)
	{
		ClientHandleGhostMode(client, true);
		
		if (GetConVarBool(g_cvGhostModeConnectionCheck))
		{
			g_hPlayerGhostModeConnectionCheckTimer[client] = CreateTimer(0.0, Timer_GhostModeConnectionCheck, GetClientUserId(client), TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
			g_flPlayerGhostModeConnectionTimeOutTime[client] = -1.0;
			g_flPlayerGhostModeConnectionBootTime[client] = -1.0;
		}
		
		PvP_OnClientGhostModeEnable(client);
	}
	else
	{
		g_hPlayerGhostModeConnectionCheckTimer[client] = INVALID_HANDLE;
		g_flPlayerGhostModeConnectionTimeOutTime[client] = -1.0;
		g_flPlayerGhostModeConnectionBootTime[client] = -1.0;
	
		if (IsClientInGame(client))
		{
			TF2_RemoveCondition(client, TFCond_HalloweenGhostMode);
			SetEntProp(client, Prop_Send, "m_CollisionGroup", COLLISION_GROUP_PLAYER);
		}
	}
}

public Action:Timer_GhostModeConnectionCheck(Handle:timer, any:userid)
{
	new client = GetClientOfUserId(userid);
	if (client <= 0) return Plugin_Stop;
	
	if (timer != g_hPlayerGhostModeConnectionCheckTimer[client]) return Plugin_Stop;
	
	if (!IsFakeClient(client) && IsClientTimingOut(client))
	{
		new Float:bootTime = g_flPlayerGhostModeConnectionBootTime[client];
		new bool:Check = GetConVarBool(g_cvGhostModeConnection);
		if (bootTime < 0.0 && !Check)
		{
			bootTime = GetGameTime() + GetConVarFloat(g_cvGhostModeConnectionTolerance);
			g_flPlayerGhostModeConnectionBootTime[client] = bootTime;
			g_flPlayerGhostModeConnectionTimeOutTime[client] = GetGameTime();
		}
		
		if (GetGameTime() >= bootTime || Check)
		{
			ClientSetGhostModeState(client, false);
			TF2_RespawnPlayer(client);
			
			decl String:authString[128];
			GetClientAuthString(client, authString, sizeof(authString));
			
			LogSF2Message("Removed %N (%s) from ghost mode due to timing out for %f seconds", client, authString, GetConVarFloat(g_cvGhostModeConnectionTolerance));
			
			new Float:timeOutTime = g_flPlayerGhostModeConnectionTimeOutTime[client];
			CPrintToChat(client, "\x08FF4040FF%T", "SF2 Ghost Mode Bad Connection", client, RoundFloat(bootTime - timeOutTime));
			
			return Plugin_Stop;
		}
	}
	else
	{
		// Player regained connection; reset.
		g_flPlayerGhostModeConnectionBootTime[client] = -1.0;
	}
	
	return Plugin_Continue;
}

/**
 *	Makes sure that the player is a ghost when ghost mode is activated.
 */
ClientHandleGhostMode(client, bool:bForceSpawn=false)
{
	if (!IsClientInGhostMode(client)) return;
	
#if defined DEBUG
	if (GetConVarInt(g_cvDebugDetail) > 2) DebugMessage("START ClientHandleGhostMode(%d, %d)", client, bForceSpawn);
#endif
	
	if (!TF2_IsPlayerInCondition(client, TFCond_HalloweenGhostMode) || bForceSpawn)
	{
		TF2_AddCondition(client, TFCond_HalloweenGhostMode, -1.0);
		SetEntProp(client, Prop_Send, "m_CollisionGroup", COLLISION_GROUP_DEBRIS);
		
		// Set first observer target.
		ClientGhostModeNextTarget(client);
		ClientActivateUltravision(client);
	}
	
#if defined DEBUG
	if (GetConVarInt(g_cvDebugDetail) > 2) DebugMessage("END ClientHandleGhostMode(%d, %d)", client, bForceSpawn);
#endif
}

ClientGhostModeNextTarget(client)
{
#if defined DEBUG
	if (GetConVarInt(g_cvDebugDetail) > 2) DebugMessage("START ClientGhostModeNextTarget(%d)", client);
#endif

	new iLastTarget = EntRefToEntIndex(g_iPlayerGhostModeTarget[client]);
	new iNextTarget = -1;
	new iFirstTarget = -1;
	for (new i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && (!g_bPlayerEliminated[i] || g_bPlayerProxy[i]) && !IsClientInGhostMode(i) && !DidClientEscape(i) && IsPlayerAlive(i))
		{
			if (iFirstTarget == -1) iFirstTarget = i;
			if (i > iLastTarget) 
			{
				iNextTarget = i;
				break;
			}
		}
	}
	
	new iTarget = -1;
	if (IsValidClient(iNextTarget)) iTarget = iNextTarget;
	else iTarget = iFirstTarget;
	
	if (IsValidClient(iTarget))
	{
		g_iPlayerGhostModeTarget[client] = EntIndexToEntRef(iTarget);
		
		decl Float:flPos[3], Float:flAng[3], Float:flVelocity[3];
		GetClientAbsOrigin(iTarget, flPos);
		GetClientEyeAngles(iTarget, flAng);
		GetEntPropVector(iTarget, Prop_Data, "m_vecAbsVelocity", flVelocity);
		TeleportEntity(client, flPos, flAng, flVelocity);
	}
	
#if defined DEBUG
	if (GetConVarInt(g_cvDebugDetail) > 2) DebugMessage("END ClientGhostModeNextTarget(%d)", client);
#endif
}

bool:IsClientInGhostMode(client)
{
	return g_bPlayerGhostMode[client];
}

//	==========================================================
//	SCARE FUNCTIONS
//	==========================================================

ClientPerformScare(client, iBossIndex)
{
	if (NPCGetUniqueID(iBossIndex) == -1)
	{
		LogError("Could not perform scare on client %d: boss does not exist!", client);
		return;
	}
	
	decl String:sProfile[SF2_MAX_PROFILE_NAME_LENGTH];
	NPCGetProfile(iBossIndex, sProfile, sizeof(sProfile));
	
	g_flPlayerScareLastTime[client][iBossIndex] = GetGameTime();
	g_flPlayerScareNextTime[client][iBossIndex] = GetGameTime() + NPCGetScareCooldown(iBossIndex);
	
	// See how much Sanity should be drained from a scare.
	new Float:flStaticAmount = GetProfileFloat(sProfile, "scare_static_amount", 0.0);
	g_flPlayerStaticAmount[client] += flStaticAmount;
	if (g_flPlayerStaticAmount[client] > 1.0) g_flPlayerStaticAmount[client] = 1.0;
	
	decl String:sScareSound[PLATFORM_MAX_PATH];
	GetRandomStringFromProfile(sProfile, "sound_scare_player", sScareSound, sizeof(sScareSound));
	
	if (sScareSound[0])
	{
		EmitSoundToClient(client, sScareSound, _, MUSIC_CHAN, SNDLEVEL_NONE);
		
		if (NPCGetFlags(iBossIndex) & SFF_HASSIGHTSOUNDS)
		{
			new Float:flCooldownMin = GetProfileFloat(sProfile, "sound_sight_cooldown_min", 8.0);
			new Float:flCooldownMax = GetProfileFloat(sProfile, "sound_sight_cooldown_max", 14.0);
			
			g_flPlayerSightSoundNextTime[client][iBossIndex] = GetGameTime() + GetRandomFloat(flCooldownMin, flCooldownMax);
		}
		
		if (g_flPlayerStress[client] > 0.4)
		{
			ClientAddStress(client, 0.4);
		}
		else
		{
			ClientAddStress(client, 0.66);
		}
	}
	else
	{
		if (g_flPlayerStress[client] > 0.4)
		{
			ClientAddStress(client, 0.3);
		}
		else
		{
			ClientAddStress(client, 0.45);
		}
	}
}

ClientPerformSightSound(client, iBossIndex)
{
	if (NPCGetUniqueID(iBossIndex) == -1)
	{
		LogError("Could not perform sight sound on client %d: boss does not exist!", client);
		return;
	}
	
	if (!(NPCGetFlags(iBossIndex) & SFF_HASSIGHTSOUNDS)) return;
	
	new iMaster = NPCGetFromUniqueID(g_iSlenderCopyMaster[iBossIndex]);
	if (iMaster == -1) iMaster = iBossIndex;
	
	decl String:sProfile[SF2_MAX_PROFILE_NAME_LENGTH];
	NPCGetProfile(iBossIndex, sProfile, sizeof(sProfile));
	
	decl String:sSightSound[PLATFORM_MAX_PATH];
	GetRandomStringFromProfile(sProfile, "sound_sight", sSightSound, sizeof(sSightSound));
	
	if (sSightSound[0])
	{
		EmitSoundToClient(client, sSightSound, _, MUSIC_CHAN, SNDLEVEL_NONE);
		
		new Float:flCooldownMin = GetProfileFloat(sProfile, "sound_sight_cooldown_min", 8.0);
		new Float:flCooldownMax = GetProfileFloat(sProfile, "sound_sight_cooldown_max", 14.0);
		
		g_flPlayerSightSoundNextTime[client][iMaster] = GetGameTime() + GetRandomFloat(flCooldownMin, flCooldownMax);
		
		decl Float:flBossPos[3], Float:flMyPos[3];
		new iBoss = NPCGetEntIndex(iBossIndex);
		GetClientAbsOrigin(client, flMyPos);
		GetEntPropVector(iBoss, Prop_Data, "m_vecAbsOrigin", flBossPos);
		new Float:flDistUnComfortZone = 400.0;
		new Float:flBossDist = GetVectorDistance(flMyPos, flBossPos);
		
		new Float:flStressScalar = 1.0 + (flDistUnComfortZone / flBossDist);
		
		ClientAddStress(client, 0.1 * flStressScalar);
	}
	else
	{
		LogError("Warning! %s supports sight sounds, but was given a blank sound!", sProfile);
	}
}

ClientResetScare(client)
{
#if defined DEBUG
	if (GetConVarInt(g_cvDebugDetail) > 2) DebugMessage("START ClientResetScare(%d)", client);
#endif

	for (new i = 0; i < MAX_BOSSES; i++)
	{
		g_flPlayerScareNextTime[client][i] = -1.0;
		g_flPlayerScareLastTime[client][i] = -1.0;
	}
	
#if defined DEBUG
	if (GetConVarInt(g_cvDebugDetail) > 2) DebugMessage("END ClientResetScare(%d)", client);
#endif
}

//	==========================================================
//	ANTI-CAMPING FUNCTIONS
//	==========================================================

stock ClientResetCampingStats(client)
{
#if defined DEBUG
	if (GetConVarInt(g_cvDebugDetail) > 2) DebugMessage("START ClientResetCampingStats(%d)", client);
#endif

	g_iPlayerCampingStrikes[client] = 0;
	g_hPlayerCampingTimer[client] = INVALID_HANDLE;
	g_bPlayerCampingFirstTime[client] = true;
	g_flPlayerCampingLastPosition[client][0] = 0.0;
	g_flPlayerCampingLastPosition[client][1] = 0.0;
	g_flPlayerCampingLastPosition[client][2] = 0.0;
	
#if defined DEBUG
	if (GetConVarInt(g_cvDebugDetail) > 2) DebugMessage("END ClientResetCampingStats(%d)", client);
#endif
}

ClientStartCampingTimer(client)
{
	g_hPlayerCampingTimer[client] = CreateTimer(5.0, Timer_ClientCheckCamp, GetClientUserId(client), TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
}

public Action:Timer_ClientCheckCamp(Handle:timer, any:userid)
{
	if (IsRoundInWarmup()) return Plugin_Stop;

	new client = GetClientOfUserId(userid);
	if (client <= 0) return Plugin_Stop;
	
	if (timer != g_hPlayerCampingTimer[client]) return Plugin_Stop;
	
	if (IsRoundEnding() || !IsPlayerAlive(client) || g_bPlayerEliminated[client] || DidClientEscape(client)) return Plugin_Stop;
	
	if (!g_bPlayerCampingFirstTime[client])
	{
		decl Float:flPos[3], Float:flMaxs[3], Float:flMins[3];
		GetClientAbsOrigin(client, flPos);
		GetEntPropVector(client, Prop_Send, "m_vecMins", flMins);
		GetEntPropVector(client, Prop_Send, "m_vecMaxs", flMaxs);
		
		// Only do something if the player is NOT stuck.
		new Float:flDistFromLastPosition = GetVectorDistance(g_flPlayerCampingLastPosition[client], flPos);
		new Float:flDistFromClosestBoss = 9999999.0;
		new iClosestBoss = -1;
		
		for (new i = 0; i < MAX_BOSSES; i++)
		{
			if (NPCGetUniqueID(i) == -1) continue;
			
			new iSlender = NPCGetEntIndex(i);
			if (!iSlender || iSlender == INVALID_ENT_REFERENCE) continue;
			
			decl Float:flSlenderPos[3];
			SlenderGetAbsOrigin(i, flSlenderPos);
			
			new Float:flDist = GetVectorDistance(flSlenderPos, flPos);
			if (flDist < flDistFromClosestBoss)
			{
				iClosestBoss = i;
				flDistFromClosestBoss = flDist;
			}
		}
		
		if (GetConVarBool(g_cvCampingEnabled) && 
			!g_bRoundGrace && 
			!IsSpaceOccupiedIgnorePlayers(flPos, flMins, flMaxs, client) && 
			g_flPlayerStaticAmount[client] <= GetConVarFloat(g_cvCampingNoStrikeSanity) && 
			(iClosestBoss == -1 || flDistFromClosestBoss >= GetConVarFloat(g_cvCampingNoStrikeBossDistance)) &&
			flDistFromLastPosition <= GetConVarFloat(g_cvCampingMinDistance))
		{
			g_iPlayerCampingStrikes[client]++;
			if (g_iPlayerCampingStrikes[client] < GetConVarInt(g_cvCampingMaxStrikes))
			{
				if (g_iPlayerCampingStrikes[client] >= GetConVarInt(g_cvCampingStrikesWarn))
				{
					CPrintToChat(client, "{red}%T", "SF2 Camping System Warning", client, (GetConVarInt(g_cvCampingMaxStrikes) - g_iPlayerCampingStrikes[client]) * 5);
				}
			}
			else
			{
				g_iPlayerCampingStrikes[client] = 0;
				ClientStartDeathCam(client, 0, flPos);
			}
		}
		else
		{
			// Forgiveness.
			if (g_iPlayerCampingStrikes[client] > 0) g_iPlayerCampingStrikes[client]--;
		}
		
		g_flPlayerCampingLastPosition[client][0] = flPos[0];
		g_flPlayerCampingLastPosition[client][1] = flPos[1];
		g_flPlayerCampingLastPosition[client][2] = flPos[2];
	}
	else
	{
		g_bPlayerCampingFirstTime[client] = false;
	}
	
	return Plugin_Continue;
}

//	==========================================================
//	BLINK FUNCTIONS
//	==========================================================

bool:IsClientBlinking(client)
{
	return g_bPlayerBlink[client];
}

Float:ClientGetBlinkMeter(client)
{
	return g_flPlayerBlinkMeter[client];
}

ClientGetBlinkCount(client)
{
	return g_iPlayerBlinkCount[client];
}

/**
 *	Resets all data on blinking.
 */
ClientResetBlink(client)
{
	g_hPlayerBlinkTimer[client] = INVALID_HANDLE;
	g_bPlayerBlink[client] = false;
	g_flPlayerBlinkMeter[client] = 1.0;
	g_iPlayerBlinkCount[client] = 0;
}

/**
 *	Sets the player into a blinking state and blinds the player
 */
ClientBlink(client)
{
	if (IsRoundInWarmup() || DidClientEscape(client)) return;
	
	if (IsClientBlinking(client)) return;
	
	g_bPlayerBlink[client] = true;
	g_iPlayerBlinkCount[client]++;
	g_flPlayerBlinkMeter[client] = 0.0;
	g_hPlayerBlinkTimer[client] = CreateTimer(GetConVarFloat(g_cvPlayerBlinkHoldTime), Timer_BlinkTimer2, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
	
	UTIL_ScreenFade(client, 100, RoundToFloor(GetConVarFloat(g_cvPlayerBlinkHoldTime) * 1000.0), FFADE_IN, 0, 0, 0, 255);
	
	Call_StartForward(fOnClientBlink);
	Call_PushCell(client);
	Call_Finish();
}

/**
 *	Unsets the player from the blinking state.
 */
ClientUnblink(client)
{
	if (!IsClientBlinking(client)) return;
	
	g_bPlayerBlink[client] = false;
	g_hPlayerBlinkTimer[client] = INVALID_HANDLE;
	g_flPlayerBlinkMeter[client] = 1.0;
}

ClientStartDrainingBlinkMeter(client)
{
	g_hPlayerBlinkTimer[client] = CreateTimer(ClientGetBlinkRate(client), Timer_BlinkTimer, GetClientUserId(client), TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
}

public Action:Timer_BlinkTimer(Handle:timer, any:userid)
{
	if (IsRoundInWarmup()) return Plugin_Stop;

	new client = GetClientOfUserId(userid);
	if (client <= 0) return Plugin_Stop;
	
	if (timer != g_hPlayerBlinkTimer[client]) return Plugin_Stop;
	
	if (IsPlayerAlive(client) && !IsClientInDeathCam(client) && !g_bPlayerEliminated[client] && !IsClientInGhostMode(client) && !IsRoundEnding())
	{
		new iOverride = GetConVarInt(g_cvPlayerInfiniteBlinkOverride);
		if ((!g_bRoundInfiniteBlink && iOverride != 1) || iOverride == 0)
		{
			g_flPlayerBlinkMeter[client] -= 0.05;
		}
		
		if (g_flPlayerBlinkMeter[client] <= 0.0)
		{
			ClientBlink(client);
			return Plugin_Stop;
		}
	}
	
	return Plugin_Continue;
}

public Action:Timer_BlinkTimer2(Handle:timer, any:userid)
{
	new client = GetClientOfUserId(userid);
	if (client <= 0) return;
	
	if (timer != g_hPlayerBlinkTimer[client]) return;
	
	ClientUnblink(client);
	ClientStartDrainingBlinkMeter(client);
}

Float:ClientGetBlinkRate(client)
{
	new Float:flValue = GetConVarFloat(g_cvPlayerBlinkRate);
	if (GetEntProp(client, Prop_Send, "m_nWaterLevel") >= 3) 
	{
		// Being underwater makes you blink faster, obviously.
		flValue *= 0.75;
	}
	
	decl String:sProfile[SF2_MAX_PROFILE_NAME_LENGTH];
	
	for (new i = 0; i < MAX_BOSSES; i++)
	{
		if (NPCGetUniqueID(i) == -1) continue;
		
		NPCGetProfile(i, sProfile, sizeof(sProfile));
		
		if (g_bPlayerSeesSlender[client][i]) 
		{
			flValue *= GetProfileFloat(sProfile, "blink_look_rate_multiply", 1.0);
		}
		
		else if (g_iPlayerStaticMode[client][i] == Static_Increase)
		{
			flValue *= GetProfileFloat(sProfile, "blink_static_rate_multiply", 1.0);
		}
	}
	
	if (TF2_GetPlayerClass(client) == TFClass_Sniper) flValue *= 1.4;
	
	if (IsClientUsingFlashlight(client))
	{
		decl Float:startPos[3], Float:endPos[3], Float:flDirection[3];
		new Float:flLength = SF2_FLASHLIGHT_LENGTH;
		GetClientEyePosition(client, startPos);
		GetClientEyePosition(client, endPos);
		GetClientEyeAngles(client, flDirection);
		GetAngleVectors(flDirection, flDirection, NULL_VECTOR, NULL_VECTOR);
		NormalizeVector(flDirection, flDirection);
		ScaleVector(flDirection, flLength);
		AddVectors(endPos, flDirection, endPos);
		new Handle:hTrace = TR_TraceRayFilterEx(startPos, endPos, MASK_VISIBLE, RayType_EndPoint, TraceRayDontHitCharactersOrEntity, client);
		TR_GetEndPosition(endPos, hTrace);
		new bool:bHit = TR_DidHit(hTrace);
		CloseHandle(hTrace);
		
		if (bHit)
		{
			new Float:flPercent = (GetVectorDistance(startPos, endPos) / flLength);
			flPercent *= 3.5;
			if (flPercent > 1.0) flPercent = 1.0;
			flValue *= flPercent;
		}
	}
	
	return flValue;
}

//	==========================================================
//	SCREEN OVERLAY FUNCTIONS
//	==========================================================

ClientAddStress(client, Float:flStressAmount)
{
	g_flPlayerStress[client] += flStressAmount;
	if (g_flPlayerStress[client] < 0.0) g_flPlayerStress[client] = 0.0;
	if (g_flPlayerStress[client] > 1.0) g_flPlayerStress[client] = 1.0;
	
	//PrintCenterText(client, "g_flPlayerStress[%d] = %f", client, g_flPlayerStress[client]);
	
	SlenderOnClientStressUpdate(client);
}

stock ClientResetOverlay(client)
{
#if defined DEBUG
	if (GetConVarInt(g_cvDebugDetail) > 2) DebugMessage("START ClientResetOverlay(%d)", client);
#endif
	
	g_hPlayerOverlayCheck[client] = INVALID_HANDLE;
	
	if (IsClientInGame(client))
	{
		ClientCommand(client, "r_screenoverlay \"\"");
	}
	
#if defined DEBUG
	if (GetConVarInt(g_cvDebugDetail) > 2) DebugMessage("END ClientResetOverlay(%d)", client);
#endif
}

public Action:Timer_PlayerOverlayCheck(Handle:timer, any:userid)
{
	new client = GetClientOfUserId(userid);
	if (client <= 0) return Plugin_Stop;
	
	if (timer != g_hPlayerOverlayCheck[client]) return Plugin_Stop;
	
	if (IsRoundInWarmup()) return Plugin_Continue;
	
	new iDeathCamBoss = NPCGetFromUniqueID(g_iPlayerDeathCamBoss[client]);
	new iJumpScareBoss = NPCGetFromUniqueID(g_iPlayerJumpScareBoss[client]);
	
	decl String:sProfile[SF2_MAX_PROFILE_NAME_LENGTH];
	decl String:sMaterial[PLATFORM_MAX_PATH];
	
	if (IsClientInDeathCam(client) && iDeathCamBoss != -1 && g_bPlayerDeathCamShowOverlay[client])
	{
		NPCGetProfile(iDeathCamBoss, sProfile, sizeof(sProfile));
		GetRandomStringFromProfile(sProfile, "overlay_player_death", sMaterial, sizeof(sMaterial), 1);
	}
	else if (iJumpScareBoss != -1 && GetGameTime() <= g_flPlayerJumpScareLifeTime[client])
	{
		NPCGetProfile(iJumpScareBoss, sProfile, sizeof(sProfile));
		GetRandomStringFromProfile(sProfile, "overlay_jumpscare", sMaterial, sizeof(sMaterial), 1);
	}
	else if (IsClientInGhostMode(client))
	{
		strcopy(sMaterial, sizeof(sMaterial), SF2_OVERLAY_GHOST);
	}
	else if (IsRoundInWarmup() || g_bPlayerEliminated[client] || DidClientEscape(client) && !IsClientInGhostMode(client))
	{
		return Plugin_Continue;
	}
	else
	{
		if (!g_iPlayerPreferences[client][PlayerPreference_FilmGrain])
			strcopy(sMaterial, sizeof(sMaterial), SF2_OVERLAY_DEFAULT_NO_FILMGRAIN);
		else
			strcopy(sMaterial, sizeof(sMaterial), SF2_OVERLAY_DEFAULT);
	}
	
	ClientCommand(client, "r_screenoverlay %s", sMaterial);
	return Plugin_Continue;
}

//	==========================================================
//	MUSIC SYSTEM FUNCTIONS
//	==========================================================

stock ClientUpdateMusicSystem(client, bool:bInitialize=false)
{
	new iOldPageMusicMaster = EntRefToEntIndex(g_iPlayerPageMusicMaster[client]);
	new iOldMusicFlags = g_iPlayerMusicFlags[client];
	new iChasingBoss = -1;
	new iChasingSeeBoss = -1;
	new iAlertBoss = -1;
	new i20DollarsBoss = -1;
	
	if (IsRoundEnding() || !IsClientInGame(client) || IsFakeClient(client) || DidClientEscape(client) || (g_bPlayerEliminated[client] && !IsClientInGhostMode(client) && !g_bPlayerProxy[client])) 
	{
		g_iPlayerMusicFlags[client] = 0;
		g_iPlayerPageMusicMaster[client] = INVALID_ENT_REFERENCE;
		if(MusicActive())//A boss is overriding the music.
		{
			decl String:sPath[PLATFORM_MAX_PATH];
			GetBossMusic(sPath,sizeof(sPath));
			StopSound(client, MUSIC_CHAN, sPath);
		}
	}
	else
	{
		new bool:bPlayMusicOnEscape = true;
		decl String:sName[64];
		new ent = -1;
		while ((ent = FindEntityByClassname(ent, "info_target")) != -1)
		{
			GetEntPropString(ent, Prop_Data, "m_iName", sName, sizeof(sName));
			if (StrEqual(sName, "sf2_escape_custommusic", false))
			{
				bPlayMusicOnEscape = false;
				break;
			}
		}
		
		// Page music first.
		new iPageRange = 0;
		
		if (GetArraySize(g_hPageMusicRanges) > 0) // Map has its own defined page music?
		{
			for (new i = 0, iSize = GetArraySize(g_hPageMusicRanges); i < iSize; i++)
			{
				ent = EntRefToEntIndex(GetArrayCell(g_hPageMusicRanges, i));
				if (!ent || ent == INVALID_ENT_REFERENCE) continue;
				
				new iMin = GetArrayCell(g_hPageMusicRanges, i, 1);
				new iMax = GetArrayCell(g_hPageMusicRanges, i, 2);
				
				if (g_iPageCount >= iMin && g_iPageCount <= iMax)
				{
					g_iPlayerPageMusicMaster[client] = GetArrayCell(g_hPageMusicRanges, i);
					break;
				}
			}
		}
		else // Nope. Use old system instead.
		{
			g_iPlayerPageMusicMaster[client] = INVALID_ENT_REFERENCE;
		
			new Float:flPercent = g_iPageMax > 0 ? (float(g_iPageCount) / float(g_iPageMax)) : 0.0;
			if (flPercent > 0.0 && flPercent <= 0.25) iPageRange = 1;
			else if (flPercent > 0.25 && flPercent <= 0.5) iPageRange = 2;
			else if (flPercent > 0.5 && flPercent <= 0.75) iPageRange = 3;
			else if (flPercent > 0.75) iPageRange = 4;
			
			if (iPageRange == 1) ClientAddMusicFlag(client, MUSICF_PAGES1PERCENT);
			else if (iPageRange == 2) ClientAddMusicFlag(client, MUSICF_PAGES25PERCENT);
			else if (iPageRange == 3) ClientAddMusicFlag(client, MUSICF_PAGES50PERCENT);
			else if (iPageRange == 4) ClientAddMusicFlag(client, MUSICF_PAGES75PERCENT);
		}
		
		if (iPageRange != 1) ClientRemoveMusicFlag(client, MUSICF_PAGES1PERCENT);
		if (iPageRange != 2) ClientRemoveMusicFlag(client, MUSICF_PAGES25PERCENT);
		if (iPageRange != 3) ClientRemoveMusicFlag(client, MUSICF_PAGES50PERCENT);
		if (iPageRange != 4) ClientRemoveMusicFlag(client, MUSICF_PAGES75PERCENT);
		
		if (IsRoundInEscapeObjective() && !bPlayMusicOnEscape) 
		{
			ClientRemoveMusicFlag(client, MUSICF_PAGES75PERCENT);
			g_iPlayerPageMusicMaster[client] = INVALID_ENT_REFERENCE;
		}
		
		new iOldChasingBoss = g_iPlayerChaseMusicMaster[client];
		new iOldChasingSeeBoss = g_iPlayerChaseMusicSeeMaster[client];
		new iOldAlertBoss = g_iPlayerAlertMusicMaster[client];
		new iOld20DollarsBoss = g_iPlayer20DollarsMusicMaster[client];
		
		new Float:flAnger = -1.0;
		new Float:flSeeAnger = -1.0;
		new Float:flAlertAnger = -1.0;
		new Float:fl20DollarsAnger = -1.0;
		
		decl Float:flBuffer[3], Float:flBuffer2[3], Float:flBuffer3[3];
		
		decl String:sProfile[SF2_MAX_PROFILE_NAME_LENGTH];
		
		for (new i = 0; i < MAX_BOSSES; i++)
		{
			if (NPCGetUniqueID(i) == -1) continue;
			
			if (NPCGetEntIndex(i) == INVALID_ENT_REFERENCE) continue;
			
			NPCGetProfile(i, sProfile, sizeof(sProfile));
			
			new iBossType = NPCGetType(i);
			
			switch (iBossType)
			{
				case SF2BossType_Chaser:
				{
					GetClientAbsOrigin(client, flBuffer);
					SlenderGetAbsOrigin(i, flBuffer3);
					
					new iTarget = EntRefToEntIndex(g_iSlenderTarget[i]);
					if (iTarget != -1)
					{
						GetEntPropVector(iTarget, Prop_Data, "m_vecAbsOrigin", flBuffer2);
						
						if ((g_iSlenderState[i] == STATE_CHASE || g_iSlenderState[i] == STATE_ATTACK || g_iSlenderState[i] == STATE_STUN) &&
							!(NPCGetFlags(i) & SFF_MARKEDASFAKE) && 
							(iTarget == client || GetVectorDistance(flBuffer, flBuffer2) <= 850.0 || GetVectorDistance(flBuffer, flBuffer3) <= 850.0 || GetVectorDistance(flBuffer, g_flSlenderGoalPos[i]) <= 850.0))
						{
							decl String:sPath[PLATFORM_MAX_PATH];
							GetRandomStringFromProfile(sProfile, "sound_chase_music", sPath, sizeof(sPath), 1);
							if (sPath[0])
							{
								if (NPCGetAnger(i) > flAnger)
								{
									flAnger = NPCGetAnger(i);
									iChasingBoss = i;
								}
							}
							
							if ((g_iSlenderState[i] == STATE_CHASE || g_iSlenderState[i] == STATE_ATTACK) &&
								PlayerCanSeeSlender(client, i, false))
							{
								if (iOldChasingSeeBoss == -1 || !PlayerCanSeeSlender(client, iOldChasingSeeBoss, false) || (NPCGetAnger(i) > flSeeAnger))
								{
									GetRandomStringFromProfile(sProfile, "sound_chase_visible", sPath, sizeof(sPath), 1);
									
									if (sPath[0])
									{
										flSeeAnger = NPCGetAnger(i);
										iChasingSeeBoss = i;
									}
								}
								
								if (g_b20Dollars)
								{
									if (iOld20DollarsBoss == -1 || !PlayerCanSeeSlender(client, iOld20DollarsBoss, false) || (NPCGetAnger(i) > fl20DollarsAnger))
									{
										GetRandomStringFromProfile(sProfile, "sound_20dollars_music", sPath, sizeof(sPath), 1);
										
										if (sPath[0])
										{
											fl20DollarsAnger = NPCGetAnger(i);
											i20DollarsBoss = i;
										}
									}
								}
							}
						}
					}
					
					if (g_iSlenderState[i] == STATE_ALERT)
					{
						decl String:sPath[PLATFORM_MAX_PATH];
						GetRandomStringFromProfile(sProfile, "sound_alert_music", sPath, sizeof(sPath), 1);
						if (!sPath[0]) continue;
					
						if (!(NPCGetFlags(i) & SFF_MARKEDASFAKE))
						{
							if (GetVectorDistance(flBuffer, flBuffer3) <= 850.0 || GetVectorDistance(flBuffer, g_flSlenderGoalPos[i]) <= 850.0)
							{
								if (NPCGetAnger(i) > flAlertAnger)
								{
									flAlertAnger = NPCGetAnger(i);
									iAlertBoss = i;
								}
							}
						}
					}
				}
			}
		}
		
		if (iChasingBoss != iOldChasingBoss)
		{
			if (iChasingBoss != -1)
			{
				ClientAddMusicFlag(client, MUSICF_CHASE);
			}
			else
			{
				ClientRemoveMusicFlag(client, MUSICF_CHASE);
			}
		}
		
		if (iChasingSeeBoss != iOldChasingSeeBoss)
		{
			if (iChasingSeeBoss != -1)
			{
				ClientAddMusicFlag(client, MUSICF_CHASEVISIBLE);
			}
			else
			{
				ClientRemoveMusicFlag(client, MUSICF_CHASEVISIBLE);
			}
		}
		
		if (iAlertBoss != iOldAlertBoss)
		{
			if (iAlertBoss != -1)
			{
				ClientAddMusicFlag(client, MUSICF_ALERT);
			}
			else
			{
				ClientRemoveMusicFlag(client, MUSICF_ALERT);
			}
		}
		
		if (i20DollarsBoss != iOld20DollarsBoss)
		{
			if (i20DollarsBoss != -1)
			{
				ClientAddMusicFlag(client, MUSICF_20DOLLARS);
			}
			else
			{
				ClientRemoveMusicFlag(client, MUSICF_20DOLLARS);
			}
		}
	}
	
	if (IsValidClient(client))
	{
		new bool:bWasChase = ClientHasMusicFlag2(iOldMusicFlags, MUSICF_CHASE);
		new bool:bChase = ClientHasMusicFlag(client, MUSICF_CHASE);
		new bool:bWasChaseSee = ClientHasMusicFlag2(iOldMusicFlags, MUSICF_CHASEVISIBLE);
		new bool:bChaseSee = ClientHasMusicFlag(client, MUSICF_CHASEVISIBLE);
		new bool:bAlert = ClientHasMusicFlag(client, MUSICF_ALERT);
		new bool:bWasAlert = ClientHasMusicFlag2(iOldMusicFlags, MUSICF_ALERT);
		new bool:b20Dollars = ClientHasMusicFlag(client, MUSICF_20DOLLARS);
		new bool:bWas20Dollars = ClientHasMusicFlag2(iOldMusicFlags, MUSICF_20DOLLARS);
		decl String:sPath[PLATFORM_MAX_PATH];
		if (IsRoundEnding() || !IsClientInGame(client) || IsFakeClient(client) || DidClientEscape(client) || (g_bPlayerEliminated[client] && !IsClientInGhostMode(client) && !g_bPlayerProxy[client])) 
		{
		}
		else if(MusicActive())//A boss is overriding the music.
		{
			GetBossMusic(sPath,sizeof(sPath));
			ClientMusicStart(client, sPath, _, MUSIC_PAGE_VOLUME);
			return;
		}
		// Custom system.
		if (GetArraySize(g_hPageMusicRanges) > 0) 
		{
		
			new iMaster = EntRefToEntIndex(g_iPlayerPageMusicMaster[client]);
			if (iMaster != INVALID_ENT_REFERENCE)
			{
				for (new i = 0, iSize = GetArraySize(g_hPageMusicRanges); i < iSize; i++)
				{
					new ent = EntRefToEntIndex(GetArrayCell(g_hPageMusicRanges, i));
					if (!ent || ent == INVALID_ENT_REFERENCE) continue;
					
					GetEntPropString(ent, Prop_Data, "m_iszSound", sPath, sizeof(sPath));
					
					if (ent == iMaster && 
						(iOldPageMusicMaster != iMaster || iOldPageMusicMaster == INVALID_ENT_REFERENCE))
					{
						if (!sPath[0])
						{
							LogError("Could not play music of page range %d-%d: no sound path specified!", GetArrayCell(g_hPageMusicRanges, i, 1), GetArrayCell(g_hPageMusicRanges, i, 2));
						}
						else
						{
							ClientMusicStart(client, sPath, _, MUSIC_PAGE_VOLUME, bChase || bAlert);
						}
						
						if (iOldPageMusicMaster && iOldPageMusicMaster != INVALID_ENT_REFERENCE)
						{
							GetEntPropString(iOldPageMusicMaster, Prop_Data, "m_iszSound", sPath, sizeof(sPath));
							if (sPath[0])
							{
								StopSound(client, MUSIC_CHAN, sPath);
							}
						}
					}
				}
			}
			else
			{
				if (iOldPageMusicMaster && iOldPageMusicMaster != INVALID_ENT_REFERENCE)
				{
					GetEntPropString(iOldPageMusicMaster, Prop_Data, "m_iszSound", sPath, sizeof(sPath));
					if (sPath[0])
					{
						StopSound(client, MUSIC_CHAN, sPath);
					}
				}
			}
		}
		
		// Old system.
		if ((bInitialize || ClientHasMusicFlag2(iOldMusicFlags, MUSICF_PAGES1PERCENT)) && !ClientHasMusicFlag(client, MUSICF_PAGES1PERCENT))
		{
			StopSound(client, MUSIC_CHAN, MUSIC_GOTPAGES1_SOUND);
		}
		else if ((bInitialize || !ClientHasMusicFlag2(iOldMusicFlags, MUSICF_PAGES1PERCENT)) && ClientHasMusicFlag(client, MUSICF_PAGES1PERCENT))
		{
			ClientMusicStart(client, MUSIC_GOTPAGES1_SOUND, _, MUSIC_PAGE_VOLUME, bChase || bAlert);
		}
		
		if ((bInitialize || ClientHasMusicFlag2(iOldMusicFlags, MUSICF_PAGES25PERCENT)) && !ClientHasMusicFlag(client, MUSICF_PAGES25PERCENT))
		{
			StopSound(client, MUSIC_CHAN, MUSIC_GOTPAGES2_SOUND);
		}
		else if ((bInitialize || !ClientHasMusicFlag2(iOldMusicFlags, MUSICF_PAGES25PERCENT)) && ClientHasMusicFlag(client, MUSICF_PAGES25PERCENT))
		{
			ClientMusicStart(client, MUSIC_GOTPAGES2_SOUND, _, MUSIC_PAGE_VOLUME, bChase || bAlert);
		}
		
		if ((bInitialize || ClientHasMusicFlag2(iOldMusicFlags, MUSICF_PAGES50PERCENT)) && !ClientHasMusicFlag(client, MUSICF_PAGES50PERCENT))
		{
			StopSound(client, MUSIC_CHAN, MUSIC_GOTPAGES3_SOUND);
		}
		else if ((bInitialize || !ClientHasMusicFlag2(iOldMusicFlags, MUSICF_PAGES50PERCENT)) && ClientHasMusicFlag(client, MUSICF_PAGES50PERCENT))
		{
			ClientMusicStart(client, MUSIC_GOTPAGES3_SOUND, _, MUSIC_PAGE_VOLUME, bChase || bAlert);
		}
		
		if ((bInitialize || ClientHasMusicFlag2(iOldMusicFlags, MUSICF_PAGES75PERCENT)) && !ClientHasMusicFlag(client, MUSICF_PAGES75PERCENT))
		{
			StopSound(client, MUSIC_CHAN, MUSIC_GOTPAGES4_SOUND);
		}
		else if ((bInitialize || !ClientHasMusicFlag2(iOldMusicFlags, MUSICF_PAGES75PERCENT)) && ClientHasMusicFlag(client, MUSICF_PAGES75PERCENT))
		{
			ClientMusicStart(client, MUSIC_GOTPAGES4_SOUND, _, MUSIC_PAGE_VOLUME, bChase || bAlert);
		}
		
		new iMainMusicState = 0;
		
		if (bAlert != bWasAlert || iAlertBoss != g_iPlayerAlertMusicMaster[client])
		{
			if (bAlert && !bChase)
			{
				ClientAlertMusicStart(client, iAlertBoss);
				if (!bWasAlert) iMainMusicState = -1;
			}
			else
			{
				ClientAlertMusicStop(client, g_iPlayerAlertMusicMaster[client]);
				if (!bChase && bWasAlert) iMainMusicState = 1;
			}
		}
		
		if (bChase != bWasChase || iChasingBoss != g_iPlayerChaseMusicMaster[client])
		{
			if (bChase)
			{
				ClientMusicChaseStart(client, iChasingBoss);
				
				if (!bWasChase)
				{
					iMainMusicState = -1;
					
					if (bAlert)
					{
						ClientAlertMusicStop(client, g_iPlayerAlertMusicMaster[client]);
					}
				}
			}
			else
			{
				ClientMusicChaseStop(client, g_iPlayerChaseMusicMaster[client]);
				if (bWasChase)
				{
					if (bAlert)
					{
						ClientAlertMusicStart(client, iAlertBoss);
					}
					else
					{
						iMainMusicState = 1;
					}
				}
			}
		}
		
		if (bChaseSee != bWasChaseSee || iChasingSeeBoss != g_iPlayerChaseMusicSeeMaster[client])
		{
			if (bChaseSee)
			{
				ClientMusicChaseSeeStart(client, iChasingSeeBoss);
			}
			else
			{
				ClientMusicChaseSeeStop(client, g_iPlayerChaseMusicSeeMaster[client]);
			}
		}
		
		if (b20Dollars != bWas20Dollars || i20DollarsBoss != g_iPlayer20DollarsMusicMaster[client])
		{
			if (b20Dollars)
			{
				Client20DollarsMusicStart(client, i20DollarsBoss);
			}
			else
			{
				Client20DollarsMusicStop(client, g_iPlayer20DollarsMusicMaster[client]);
			}
		}
		
		if (iMainMusicState == 1)
		{
			ClientMusicStart(client, g_strPlayerMusic[client], _, MUSIC_PAGE_VOLUME, bChase || bAlert);
		}
		else if (iMainMusicState == -1)
		{
			ClientMusicStop(client);
		}
		
		if (bChase || bAlert)
		{
			new iBossToUse = -1;
			if (bChase)
			{
				iBossToUse = iChasingBoss;
			}
			else
			{
				iBossToUse = iAlertBoss;
			}
			
			if (iBossToUse != -1)
			{
				// We got some alert/chase music going on! The player's excitement will no doubt go up!
				// Excitement, though, really depends on how close the boss is in relation to the
				// player.
				
				new Float:flBossDist = NPCGetDistanceFromEntity(iBossToUse, client);
				new Float:flScalar = flBossDist / 700.0
				if (flScalar > 1.0) flScalar = 1.0;
				new Float:flStressAdd = 0.1 * (1.0 - flScalar);
				
				ClientAddStress(client, flStressAdd);
			}
		}
	}
}

stock ClientMusicReset(client)
{
	new String:sOldMusic[PLATFORM_MAX_PATH];
	strcopy(sOldMusic, sizeof(sOldMusic), g_strPlayerMusic[client]);
	strcopy(g_strPlayerMusic[client], sizeof(g_strPlayerMusic[]), "");
	if (IsValidClient(client) && sOldMusic[0]) StopSound(client, MUSIC_CHAN, sOldMusic);
	
	g_iPlayerMusicFlags[client] = 0;
	g_flPlayerMusicVolume[client] = 0.0;
	g_flPlayerMusicTargetVolume[client] = 0.0;
	g_hPlayerMusicTimer[client] = INVALID_HANDLE;
	g_iPlayerPageMusicMaster[client] = INVALID_ENT_REFERENCE;
}

stock ClientMusicStart(client, const String:sNewMusic[], Float:flVolume=-1.0, Float:flTargetVolume=-1.0, bool:bCopyOnly=false)
{
	if (!IsValidClient(client)) return;
	if (!sNewMusic[0]) return;
	
	new String:sOldMusic[PLATFORM_MAX_PATH];
	strcopy(sOldMusic, sizeof(sOldMusic), g_strPlayerMusic[client]);
	
	if (!StrEqual(sOldMusic, sNewMusic, false))
	{
		if (sOldMusic[0]) StopSound(client, MUSIC_CHAN, sOldMusic);
	}
	strcopy(g_strPlayerMusic[client], sizeof(g_strPlayerMusic[]), sNewMusic);
	if(MusicActive())//A boss is overriding the music.
		GetBossMusic(g_strPlayerMusic[client],sizeof(g_strPlayerMusic[]));
	if (flVolume >= 0.0) g_flPlayerMusicVolume[client] = flVolume;
	if (flTargetVolume >= 0.0) g_flPlayerMusicTargetVolume[client] = flTargetVolume;
	
	if (!bCopyOnly)
	{
		new bool:bPlayMusicOnEscape = false;
		decl String:sName[64];
		new ent = -1;
		while ((ent = FindEntityByClassname(ent, "info_target")) != -1)
		{
			GetEntPropString(ent, Prop_Data, "m_iName", sName, sizeof(sName));
			if (StrEqual(sName, "sf2_escape_custommusic", false))
			{
				bPlayMusicOnEscape = true;
				break;
			}
		}
		if(g_iPageCount < g_iPageMax)
		{
			g_hPlayerMusicTimer[client] = CreateTimer(0.01, Timer_PlayerFadeInMusic, GetClientUserId(client), TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
			TriggerTimer(g_hPlayerMusicTimer[client], true);
		}
		if(!bPlayMusicOnEscape)
		{
			g_hPlayerMusicTimer[client] = CreateTimer(0.01, Timer_PlayerFadeInMusic, GetClientUserId(client), TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
			TriggerTimer(g_hPlayerMusicTimer[client], true);
		}
	}
	else
	{
		g_hPlayerMusicTimer[client] = INVALID_HANDLE;
	}
}

stock ClientMusicStop(client)
{
	g_hPlayerMusicTimer[client] = CreateTimer(0.01, Timer_PlayerFadeOutMusic, GetClientUserId(client), TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
	TriggerTimer(g_hPlayerMusicTimer[client], true);
}

stock Client20DollarsMusicReset(client)
{
	new String:sOldMusic[PLATFORM_MAX_PATH];
	strcopy(sOldMusic, sizeof(sOldMusic), g_strPlayer20DollarsMusic[client]);
	strcopy(g_strPlayer20DollarsMusic[client], sizeof(g_strPlayer20DollarsMusic[]), "");
	if (IsValidClient(client) && sOldMusic[0]) StopSound(client, MUSIC_CHAN, sOldMusic);
	
	g_iPlayer20DollarsMusicMaster[client] = -1;
	
	decl String:sProfile[SF2_MAX_PROFILE_NAME_LENGTH];
	
	for (new i = 0; i < MAX_BOSSES; i++)
	{
		g_hPlayer20DollarsMusicTimer[client][i] = INVALID_HANDLE;
		g_flPlayer20DollarsMusicVolumes[client][i] = 0.0;
		
		if (NPCGetUniqueID(i) != -1)
		{
			if (IsValidClient(client))
			{
				NPCGetProfile(i, sProfile, sizeof(sProfile));
			
				GetRandomStringFromProfile(sProfile, "sound_20dollars_music", sOldMusic, sizeof(sOldMusic), 1);
				if (sOldMusic[0]) StopSound(client, MUSIC_CHAN, sOldMusic);
			}
		}
	}
}

stock Client20DollarsMusicStart(client, iBossIndex)
{
	if (!IsValidClient(client)) return;
	
	new iOldMaster = g_iPlayer20DollarsMusicMaster[client];
	if (iOldMaster == iBossIndex) return;
	
	decl String:sProfile[SF2_MAX_PROFILE_NAME_LENGTH];
	NPCGetProfile(iBossIndex, sProfile, sizeof(sProfile));
	
	new String:sBuffer[PLATFORM_MAX_PATH];
	GetRandomStringFromProfile(sProfile, "sound_20dollars_music", sBuffer, sizeof(sBuffer), 1);
	
	if (!sBuffer[0]) return;
	
	g_iPlayer20DollarsMusicMaster[client] = iBossIndex;
	strcopy(g_strPlayer20DollarsMusic[client], sizeof(g_strPlayer20DollarsMusic[]), sBuffer);
	g_hPlayer20DollarsMusicTimer[client][iBossIndex] = CreateTimer(0.01, Timer_PlayerFadeIn20DollarsMusic, GetClientUserId(client), TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
	TriggerTimer(g_hPlayer20DollarsMusicTimer[client][iBossIndex], true);
	
	if (iOldMaster != -1)
	{
		ClientAlertMusicStop(client, iOldMaster);
	}
}

stock Client20DollarsMusicStop(client, iBossIndex)
{
	if (!IsValidClient(client)) return;
	if (iBossIndex == -1) return;
	
	if (iBossIndex == g_iPlayer20DollarsMusicMaster[client])
	{
		g_iPlayer20DollarsMusicMaster[client] = -1;
		strcopy(g_strPlayer20DollarsMusic[client], sizeof(g_strPlayer20DollarsMusic[]), "");
	}
	
	g_hPlayer20DollarsMusicTimer[client][iBossIndex] = CreateTimer(0.01, Timer_PlayerFadeOut20DollarsMusic, GetClientUserId(client), TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
	TriggerTimer(g_hPlayer20DollarsMusicTimer[client][iBossIndex], true);
}

stock ClientAlertMusicReset(client)
{
	new String:sOldMusic[PLATFORM_MAX_PATH];
	strcopy(sOldMusic, sizeof(sOldMusic), g_strPlayerAlertMusic[client]);
	strcopy(g_strPlayerAlertMusic[client], sizeof(g_strPlayerAlertMusic[]), "");
	if (IsValidClient(client) && sOldMusic[0]) StopSound(client, MUSIC_CHAN, sOldMusic);
	
	g_iPlayerAlertMusicMaster[client] = -1;
	
	decl String:sProfile[SF2_MAX_PROFILE_NAME_LENGTH];
	
	for (new i = 0; i < MAX_BOSSES; i++)
	{
		g_hPlayerAlertMusicTimer[client][i] = INVALID_HANDLE;
		g_flPlayerAlertMusicVolumes[client][i] = 0.0;
		
		if (NPCGetUniqueID(i) != -1)
		{
			if (IsValidClient(client))
			{
				NPCGetProfile(i, sProfile, sizeof(sProfile));
			
				GetRandomStringFromProfile(sProfile, "sound_alert_music", sOldMusic, sizeof(sOldMusic), 1);
				if (sOldMusic[0]) StopSound(client, MUSIC_CHAN, sOldMusic);
			}
		}
	}
}

stock ClientAlertMusicStart(client, iBossIndex)
{
	if (!IsValidClient(client)) return;
	
	new iOldMaster = g_iPlayerAlertMusicMaster[client];
	if (iOldMaster == iBossIndex) return;
	
	decl String:sProfile[SF2_MAX_PROFILE_NAME_LENGTH];
	NPCGetProfile(iBossIndex, sProfile, sizeof(sProfile));
	
	new String:sBuffer[PLATFORM_MAX_PATH];
	GetRandomStringFromProfile(sProfile, "sound_alert_music", sBuffer, sizeof(sBuffer), 1);
	
	if (!sBuffer[0]) return;
	
	g_iPlayerAlertMusicMaster[client] = iBossIndex;
	strcopy(g_strPlayerAlertMusic[client], sizeof(g_strPlayerAlertMusic[]), sBuffer);
	g_hPlayerAlertMusicTimer[client][iBossIndex] = CreateTimer(0.01, Timer_PlayerFadeInAlertMusic, GetClientUserId(client), TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
	TriggerTimer(g_hPlayerAlertMusicTimer[client][iBossIndex], true);
	
	if (iOldMaster != -1)
	{
		ClientAlertMusicStop(client, iOldMaster);
	}
}

stock ClientAlertMusicStop(client, iBossIndex)
{
	if (!IsValidClient(client)) return;
	if (iBossIndex == -1) return;
	
	if (iBossIndex == g_iPlayerAlertMusicMaster[client])
	{
		g_iPlayerAlertMusicMaster[client] = -1;
		strcopy(g_strPlayerAlertMusic[client], sizeof(g_strPlayerAlertMusic[]), "");
	}
	
	g_hPlayerAlertMusicTimer[client][iBossIndex] = CreateTimer(0.01, Timer_PlayerFadeOutAlertMusic, GetClientUserId(client), TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
	TriggerTimer(g_hPlayerAlertMusicTimer[client][iBossIndex], true);
}

stock ClientChaseMusicReset(client)
{
	new String:sOldMusic[PLATFORM_MAX_PATH];
	strcopy(sOldMusic, sizeof(sOldMusic), g_strPlayerChaseMusic[client]);
	strcopy(g_strPlayerChaseMusic[client], sizeof(g_strPlayerChaseMusic[]), "");
	if (IsValidClient(client) && sOldMusic[0]) StopSound(client, MUSIC_CHAN, sOldMusic);
	
	g_iPlayerChaseMusicMaster[client] = -1;
	
	decl String:sProfile[SF2_MAX_PROFILE_NAME_LENGTH];
	
	for (new i = 0; i < MAX_BOSSES; i++)
	{
		g_hPlayerChaseMusicTimer[client][i] = INVALID_HANDLE;
		g_flPlayerChaseMusicVolumes[client][i] = 0.0;
		
		if (NPCGetUniqueID(i) != -1)
		{
			if (IsValidClient(client))
			{
				NPCGetProfile(i, sProfile, sizeof(sProfile));
				
				GetRandomStringFromProfile(sProfile, "sound_chase_music", sOldMusic, sizeof(sOldMusic), 1);
				if (sOldMusic[0]) StopSound(client, MUSIC_CHAN, sOldMusic);
			}
		}
	}
}

stock ClientMusicChaseStart(client, iBossIndex)
{
	if (!IsValidClient(client)) return;
	
	new iOldMaster = g_iPlayerChaseMusicMaster[client];
	if (iOldMaster == iBossIndex) return;
	
	decl String:sProfile[SF2_MAX_PROFILE_NAME_LENGTH];
	NPCGetProfile(iBossIndex, sProfile, sizeof(sProfile));
	
	decl String:sBuffer[PLATFORM_MAX_PATH];
	GetRandomStringFromProfile(sProfile, "sound_chase_music", sBuffer, sizeof(sBuffer), 1);
	
	if (!sBuffer[0]) return;
	
	g_iPlayerChaseMusicMaster[client] = iBossIndex;
	strcopy(g_strPlayerChaseMusic[client], sizeof(g_strPlayerChaseMusic[]), sBuffer);
	if(MusicActive())//A boss is overriding the music.
		GetBossMusic(g_strPlayerChaseMusic[client],sizeof(g_strPlayerChaseMusic[]));
	g_hPlayerChaseMusicTimer[client][iBossIndex] = CreateTimer(0.01, Timer_PlayerFadeInChaseMusic, GetClientUserId(client), TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
	TriggerTimer(g_hPlayerChaseMusicTimer[client][iBossIndex], true);
	
	if (iOldMaster != -1)
	{
		ClientMusicChaseStop(client, iOldMaster);
	}
}

stock ClientMusicChaseStop(client, iBossIndex)
{
	if (!IsClientInGame(client)) return;
	if (iBossIndex == -1) return;
	
	if (iBossIndex == g_iPlayerChaseMusicMaster[client])
	{
		g_iPlayerChaseMusicMaster[client] = -1;
		strcopy(g_strPlayerChaseMusic[client], sizeof(g_strPlayerChaseMusic[]), "");
	}
	
	g_hPlayerChaseMusicTimer[client][iBossIndex] = CreateTimer(0.01, Timer_PlayerFadeOutChaseMusic, GetClientUserId(client), TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
	TriggerTimer(g_hPlayerChaseMusicTimer[client][iBossIndex], true);
}

stock ClientChaseMusicSeeReset(client)
{
	new String:sOldMusic[PLATFORM_MAX_PATH];
	strcopy(sOldMusic, sizeof(sOldMusic), g_strPlayerChaseMusicSee[client]);
	strcopy(g_strPlayerChaseMusicSee[client], sizeof(g_strPlayerChaseMusicSee[]), "");
	if (IsClientInGame(client) && sOldMusic[0]) StopSound(client, MUSIC_CHAN, sOldMusic);
	
	g_iPlayerChaseMusicSeeMaster[client] = -1;
	
	decl String:sProfile[SF2_MAX_PROFILE_NAME_LENGTH];
	
	for (new i = 0; i < MAX_BOSSES; i++)
	{
		g_hPlayerChaseMusicSeeTimer[client][i] = INVALID_HANDLE;
		g_flPlayerChaseMusicSeeVolumes[client][i] = 0.0;
		
		if (NPCGetUniqueID(i) != -1)
		{
			if (IsClientInGame(client))
			{
				NPCGetProfile(i, sProfile, sizeof(sProfile));
			
				GetRandomStringFromProfile(sProfile, "sound_chase_visible", sOldMusic, sizeof(sOldMusic), 1);
				if (sOldMusic[0]) StopSound(client, MUSIC_CHAN, sOldMusic);
			}
		}
	}
}

stock ClientMusicChaseSeeStart(client, iBossIndex)
{
	if (!IsClientInGame(client)) return;
	
	new iOldMaster = g_iPlayerChaseMusicSeeMaster[client];
	if (iOldMaster == iBossIndex) return;
	
	decl String:sProfile[SF2_MAX_PROFILE_NAME_LENGTH];
	NPCGetProfile(iBossIndex, sProfile, sizeof(sProfile));
	
	new String:sBuffer[PLATFORM_MAX_PATH];
	GetRandomStringFromProfile(sProfile, "sound_chase_visible", sBuffer, sizeof(sBuffer), 1);
	if (!sBuffer[0]) return;
	
	g_iPlayerChaseMusicSeeMaster[client] = iBossIndex;
	strcopy(g_strPlayerChaseMusicSee[client], sizeof(g_strPlayerChaseMusicSee[]), sBuffer);
	g_hPlayerChaseMusicSeeTimer[client][iBossIndex] = CreateTimer(0.01, Timer_PlayerFadeInChaseMusicSee, GetClientUserId(client), TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
	TriggerTimer(g_hPlayerChaseMusicSeeTimer[client][iBossIndex], true);
	
	if (iOldMaster != -1)
	{
		ClientMusicChaseSeeStop(client, iOldMaster);
	}
}

stock ClientMusicChaseSeeStop(client, iBossIndex)
{
	if (!IsClientInGame(client)) return;
	if (iBossIndex == -1) return;
	
	if (iBossIndex == g_iPlayerChaseMusicSeeMaster[client])
	{
		g_iPlayerChaseMusicSeeMaster[client] = -1;
		strcopy(g_strPlayerChaseMusicSee[client], sizeof(g_strPlayerChaseMusicSee[]), "");
	}
	
	g_hPlayerChaseMusicSeeTimer[client][iBossIndex] = CreateTimer(0.01, Timer_PlayerFadeOutChaseMusicSee, GetClientUserId(client), TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
	TriggerTimer(g_hPlayerChaseMusicSeeTimer[client][iBossIndex], true);
}

public Action:Timer_PlayerFadeInMusic(Handle:timer, any:userid)
{
	new client = GetClientOfUserId(userid);
	if (client <= 0) return Plugin_Stop;
	
	if (timer != g_hPlayerMusicTimer[client]) return Plugin_Stop;
	
	g_flPlayerMusicVolume[client] += 0.07;
	if (g_flPlayerMusicVolume[client] > g_flPlayerMusicTargetVolume[client]) g_flPlayerMusicVolume[client] = g_flPlayerMusicTargetVolume[client];
	
	if (g_strPlayerMusic[client][0]) EmitSoundToClient(client, g_strPlayerMusic[client], _, MUSIC_CHAN, SNDLEVEL_NONE, SND_CHANGEVOL, g_flPlayerMusicVolume[client]);

	if (g_flPlayerMusicVolume[client] >= g_flPlayerMusicTargetVolume[client])
	{
		g_hPlayerMusicTimer[client] = INVALID_HANDLE;
		return Plugin_Stop;
	}
	
	return Plugin_Continue;
}

public Action:Timer_PlayerFadeOutMusic(Handle:timer, any:userid)
{
	new client = GetClientOfUserId(userid);
	if (client <= 0) return Plugin_Stop;

	if (timer != g_hPlayerMusicTimer[client]) return Plugin_Stop;

	g_flPlayerMusicVolume[client] -= 0.07;
	if (g_flPlayerMusicVolume[client] < 0.0) g_flPlayerMusicVolume[client] = 0.0;

	if (g_strPlayerMusic[client][0]) EmitSoundToClient(client, g_strPlayerMusic[client], _, MUSIC_CHAN, SNDLEVEL_NONE, SND_CHANGEVOL, g_flPlayerMusicVolume[client]);

	if (g_flPlayerMusicVolume[client] <= 0.0)
	{
		g_hPlayerMusicTimer[client] = INVALID_HANDLE;
		return Plugin_Stop;
	}
	
	return Plugin_Continue;
}

public Action:Timer_PlayerFadeIn20DollarsMusic(Handle:timer, any:userid)
{
	new client = GetClientOfUserId(userid);
	if (client <= 0) return Plugin_Stop;
	
	new iBossIndex = -1;
	for (new i = 0; i < MAX_BOSSES; i++)
	{
		if (g_hPlayer20DollarsMusicTimer[client][i] == timer)
		{
			iBossIndex = i;
			break;
		}
	}
	
	if (iBossIndex == -1) return Plugin_Stop;
	
	g_flPlayer20DollarsMusicVolumes[client][iBossIndex] += 0.07;
	if (g_flPlayer20DollarsMusicVolumes[client][iBossIndex] > 1.0) g_flPlayer20DollarsMusicVolumes[client][iBossIndex] = 1.0;

	if (g_strPlayer20DollarsMusic[client][0]) EmitSoundToClient(client, g_strPlayer20DollarsMusic[client], _, MUSIC_CHAN, _, SND_CHANGEVOL, g_flPlayer20DollarsMusicVolumes[client][iBossIndex]);
	
	if (g_flPlayer20DollarsMusicVolumes[client][iBossIndex] >= 1.0)
	{
		g_hPlayer20DollarsMusicTimer[client][iBossIndex] = INVALID_HANDLE;
		return Plugin_Stop;
	}
	
	return Plugin_Continue;
}

public Action:Timer_PlayerFadeOut20DollarsMusic(Handle:timer, any:userid)
{
	new client = GetClientOfUserId(userid);
	if (client <= 0) return Plugin_Stop;

	new iBossIndex = -1;
	for (new i = 0; i < MAX_BOSSES; i++)
	{
		if (g_hPlayer20DollarsMusicTimer[client][i] == timer)
		{
			iBossIndex = i;
			break;
		}
	}
	
	if (iBossIndex == -1) return Plugin_Stop;
	
	decl String:sProfile[SF2_MAX_PROFILE_NAME_LENGTH];
	NPCGetProfile(iBossIndex, sProfile, sizeof(sProfile));
	
	decl String:sBuffer[PLATFORM_MAX_PATH];
	GetRandomStringFromProfile(sProfile, "sound_20dollars_music", sBuffer, sizeof(sBuffer), 1);
	
	if (StrEqual(sBuffer, g_strPlayer20DollarsMusic[client], false))
	{
		g_hPlayer20DollarsMusicTimer[client][iBossIndex] = INVALID_HANDLE;
		return Plugin_Stop;
	}
	
	g_flPlayer20DollarsMusicVolumes[client][iBossIndex] -= 0.07;
	if (g_flPlayer20DollarsMusicVolumes[client][iBossIndex] < 0.0) g_flPlayer20DollarsMusicVolumes[client][iBossIndex] = 0.0;

	if (sBuffer[0]) EmitSoundToClient(client, sBuffer, _, MUSIC_CHAN, _, SND_CHANGEVOL, g_flPlayer20DollarsMusicVolumes[client][iBossIndex]);
	
	if (g_flPlayer20DollarsMusicVolumes[client][iBossIndex] <= 0.0)
	{
		g_hPlayer20DollarsMusicTimer[client][iBossIndex] = INVALID_HANDLE;
		return Plugin_Stop;
	}
	
	return Plugin_Continue;
}

public Action:Timer_PlayerFadeInAlertMusic(Handle:timer, any:userid)
{
	new client = GetClientOfUserId(userid);
	if (client <= 0) return Plugin_Stop;

	new iBossIndex = -1;
	for (new i = 0; i < MAX_BOSSES; i++)
	{
		if (g_hPlayerAlertMusicTimer[client][i] == timer)
		{
			iBossIndex = i;
			break;
		}
	}
	
	if (iBossIndex == -1) return Plugin_Stop;
	
	g_flPlayerAlertMusicVolumes[client][iBossIndex] += 0.07;
	if (g_flPlayerAlertMusicVolumes[client][iBossIndex] > 1.0) g_flPlayerAlertMusicVolumes[client][iBossIndex] = 1.0;

	if (g_strPlayerAlertMusic[client][0]) EmitSoundToClient(client, g_strPlayerAlertMusic[client], _, MUSIC_CHAN, _, SND_CHANGEVOL, g_flPlayerAlertMusicVolumes[client][iBossIndex]);
	
	if (g_flPlayerAlertMusicVolumes[client][iBossIndex] >= 1.0)
	{
		g_hPlayerAlertMusicTimer[client][iBossIndex] = INVALID_HANDLE;
		return Plugin_Stop;
	}
	
	return Plugin_Continue;
}

public Action:Timer_PlayerFadeOutAlertMusic(Handle:timer, any:userid)
{
	new client = GetClientOfUserId(userid);
	if (client <= 0) return Plugin_Stop;

	new iBossIndex = -1;
	for (new i = 0; i < MAX_BOSSES; i++)
	{
		if (g_hPlayerAlertMusicTimer[client][i] == timer)
		{
			iBossIndex = i;
			break;
		}
	}
	
	if (iBossIndex == -1) return Plugin_Stop;
	
	decl String:sProfile[SF2_MAX_PROFILE_NAME_LENGTH];
	NPCGetProfile(iBossIndex, sProfile, sizeof(sProfile));
	
	decl String:sBuffer[PLATFORM_MAX_PATH];
	GetRandomStringFromProfile(sProfile, "sound_alert_music", sBuffer, sizeof(sBuffer), 1);

	if (StrEqual(sBuffer, g_strPlayerAlertMusic[client], false))
	{
		g_hPlayerAlertMusicTimer[client][iBossIndex] = INVALID_HANDLE;
		return Plugin_Stop;
	}
	
	g_flPlayerAlertMusicVolumes[client][iBossIndex] -= 0.07;
	if (g_flPlayerAlertMusicVolumes[client][iBossIndex] < 0.0) g_flPlayerAlertMusicVolumes[client][iBossIndex] = 0.0;

	if (sBuffer[0]) EmitSoundToClient(client, sBuffer, _, MUSIC_CHAN, _, SND_CHANGEVOL, g_flPlayerAlertMusicVolumes[client][iBossIndex]);
	
	if (g_flPlayerAlertMusicVolumes[client][iBossIndex] <= 0.0)
	{
		g_hPlayerAlertMusicTimer[client][iBossIndex] = INVALID_HANDLE;
		return Plugin_Stop;
	}
	
	return Plugin_Continue;
}

public Action:Timer_PlayerFadeInChaseMusic(Handle:timer, any:userid)
{
	new client = GetClientOfUserId(userid);
	if (client <= 0) return Plugin_Stop;

	new iBossIndex = -1;
	for (new i = 0; i < MAX_BOSSES; i++)
	{
		if (g_hPlayerChaseMusicTimer[client][i] == timer)
		{
			iBossIndex = i;
			break;
		}
	}
	
	if (iBossIndex == -1) return Plugin_Stop;
	
	g_flPlayerChaseMusicVolumes[client][iBossIndex] += 0.07;
	if (g_flPlayerChaseMusicVolumes[client][iBossIndex] > 1.0) g_flPlayerChaseMusicVolumes[client][iBossIndex] = 1.0;

	if (g_strPlayerChaseMusic[client][0]) EmitSoundToClient(client, g_strPlayerChaseMusic[client], _, MUSIC_CHAN, _, SND_CHANGEVOL, g_flPlayerChaseMusicVolumes[client][iBossIndex]);
	
	if (g_flPlayerChaseMusicVolumes[client][iBossIndex] >= 1.0)
	{
		g_hPlayerChaseMusicTimer[client][iBossIndex] = INVALID_HANDLE;
		return Plugin_Stop;
	}
	
	return Plugin_Continue;
}

public Action:Timer_PlayerFadeInChaseMusicSee(Handle:timer, any:userid)
{
	new client = GetClientOfUserId(userid);
	if (client <= 0) return Plugin_Stop;

	new iBossIndex = -1;
	for (new i = 0; i < MAX_BOSSES; i++)
	{
		if (g_hPlayerChaseMusicSeeTimer[client][i] == timer)
		{
			iBossIndex = i;
			break;
		}
	}
	
	if (iBossIndex == -1) return Plugin_Stop;
	
	g_flPlayerChaseMusicSeeVolumes[client][iBossIndex] += 0.07;
	if (g_flPlayerChaseMusicSeeVolumes[client][iBossIndex] > 1.0) g_flPlayerChaseMusicSeeVolumes[client][iBossIndex] = 1.0;

	if (g_strPlayerChaseMusicSee[client][0]) EmitSoundToClient(client, g_strPlayerChaseMusicSee[client], _, MUSIC_CHAN, _, SND_CHANGEVOL, g_flPlayerChaseMusicSeeVolumes[client][iBossIndex]);
	
	if (g_flPlayerChaseMusicSeeVolumes[client][iBossIndex] >= 1.0)
	{
		g_hPlayerChaseMusicSeeTimer[client][iBossIndex] = INVALID_HANDLE;
		return Plugin_Stop;
	}
	
	return Plugin_Continue;
}

public Action:Timer_PlayerFadeOutChaseMusic(Handle:timer, any:userid)
{
	new client = GetClientOfUserId(userid);
	if (client <= 0) return Plugin_Stop;

	new iBossIndex = -1;
	for (new i = 0; i < MAX_BOSSES; i++)
	{
		if (g_hPlayerChaseMusicTimer[client][i] == timer)
		{
			iBossIndex = i;
			break;
		}
	}
	
	if (iBossIndex == -1) return Plugin_Stop;
	
	decl String:sProfile[SF2_MAX_PROFILE_NAME_LENGTH];
	NPCGetProfile(iBossIndex, sProfile, sizeof(sProfile));
	
	decl String:sBuffer[PLATFORM_MAX_PATH];
	GetRandomStringFromProfile(sProfile, "sound_chase_music", sBuffer, sizeof(sBuffer), 1);

	if (StrEqual(sBuffer, g_strPlayerChaseMusic[client], false))
	{
		g_hPlayerChaseMusicTimer[client][iBossIndex] = INVALID_HANDLE;
		return Plugin_Stop;
	}
	
	g_flPlayerChaseMusicVolumes[client][iBossIndex] -= 0.07;
	if (g_flPlayerChaseMusicVolumes[client][iBossIndex] < 0.0) g_flPlayerChaseMusicVolumes[client][iBossIndex] = 0.0;

	if (sBuffer[0]) EmitSoundToClient(client, sBuffer, _, MUSIC_CHAN, _, SND_CHANGEVOL, g_flPlayerChaseMusicVolumes[client][iBossIndex]);
	
	if (g_flPlayerChaseMusicVolumes[client][iBossIndex] <= 0.0)
	{
		g_hPlayerChaseMusicTimer[client][iBossIndex] = INVALID_HANDLE;
		return Plugin_Stop;
	}
	
	return Plugin_Continue;
}

public Action:Timer_PlayerFadeOutChaseMusicSee(Handle:timer, any:userid)
{
	new client = GetClientOfUserId(userid);
	if (client <= 0) return Plugin_Stop;

	new iBossIndex = -1;
	for (new i = 0; i < MAX_BOSSES; i++)
	{
		if (g_hPlayerChaseMusicSeeTimer[client][i] == timer)
		{
			iBossIndex = i;
			break;
		}
	}
	
	if (iBossIndex == -1) return Plugin_Stop;
	
	decl String:sProfile[SF2_MAX_PROFILE_NAME_LENGTH];
	NPCGetProfile(iBossIndex, sProfile, sizeof(sProfile));
	
	decl String:sBuffer[PLATFORM_MAX_PATH];
	GetRandomStringFromProfile(sProfile, "sound_chase_visible", sBuffer, sizeof(sBuffer), 1);

	if (StrEqual(sBuffer, g_strPlayerChaseMusicSee[client], false))
	{
		g_hPlayerChaseMusicSeeTimer[client][iBossIndex] = INVALID_HANDLE;
		return Plugin_Stop;
	}
	
	g_flPlayerChaseMusicSeeVolumes[client][iBossIndex] -= 0.07;
	if (g_flPlayerChaseMusicSeeVolumes[client][iBossIndex] < 0.0) g_flPlayerChaseMusicSeeVolumes[client][iBossIndex] = 0.0;

	if (sBuffer[0]) EmitSoundToClient(client, sBuffer, _, MUSIC_CHAN, _, SND_CHANGEVOL, g_flPlayerChaseMusicSeeVolumes[client][iBossIndex]);
	
	if (g_flPlayerChaseMusicSeeVolumes[client][iBossIndex] <= 0.0)
	{
		g_hPlayerChaseMusicSeeTimer[client][iBossIndex] = INVALID_HANDLE;
		return Plugin_Stop;
	}
	
	return Plugin_Continue;
}

stock bool:ClientHasMusicFlag(client, iFlag)
{
	return bool:(g_iPlayerMusicFlags[client] & iFlag);
}

stock bool:ClientHasMusicFlag2(iValue, iFlag)
{
	return bool:(iValue & iFlag);
}

stock ClientAddMusicFlag(client, iFlag)
{
	if (!ClientHasMusicFlag(client, iFlag)) g_iPlayerMusicFlags[client] |= iFlag;
}

stock ClientRemoveMusicFlag(client, iFlag)
{
	if (ClientHasMusicFlag(client, iFlag)) g_iPlayerMusicFlags[client] &= ~iFlag;
}

//	==========================================================
//	MISC FUNCTIONS
//	==========================================================

// This could be used for entities as well.
stock ClientStopAllSlenderSounds(client, const String:profileName[], const String:sectionName[], iChannel)
{
	if (!client || !IsValidEntity(client)) return;
	
	if (!IsProfileValid(profileName)) return;
	
	decl String:buffer[PLATFORM_MAX_PATH];
	
	KvRewind(g_hConfig);
	if (KvJumpToKey(g_hConfig, profileName))
	{
		decl String:s[32];
		
		if (KvJumpToKey(g_hConfig, sectionName))
		{
			for (new i2 = 1;; i2++)
			{
				IntToString(i2, s, sizeof(s));
				KvGetString(g_hConfig, s, buffer, sizeof(buffer));
				if (!buffer[0]) break;
				
				StopSound(client, iChannel, buffer);
			}
		}
	}
}

stock ClientUpdateListeningFlags(client, bool:bReset=false)
{
	if (!IsClientInGame(client)) return;
	
	for (new i = 1; i <= MaxClients; i++)
	{
		if (i == client || !IsClientInGame(i)) continue;
		
		if (bReset || IsRoundEnding() || GetConVarBool(g_cvAllChat))
		{
			SetListenOverride(client, i, Listen_Default);
			continue;
		}
		
		new MuteMode:iMuteMode = g_iPlayerPreferences[client][PlayerPreference_MuteMode];
		
		if (g_bPlayerEliminated[client])
		{
			if (!g_bPlayerEliminated[i])
			{
				if (iMuteMode == MuteMode_DontHearOtherTeam)
				{
					SetListenOverride(client, i, Listen_No);
				}
				else if (iMuteMode == MuteMode_DontHearOtherTeamIfNotProxy && !g_bPlayerProxy[client])
				{
					SetListenOverride(client, i, Listen_No);
				}
				else
				{
					SetListenOverride(client, i, Listen_Default);
				}
			}
			else
			{
				SetListenOverride(client, i, Listen_Default);
			}
		}
		else
		{
			if (!g_bPlayerEliminated[i])
			{
				if (g_bSpecialRound && g_iSpecialRoundType == SPECIALROUND_SINGLEPLAYER)
				{
					if (DidClientEscape(i))
					{
						if (!DidClientEscape(client))
						{
							SetListenOverride(client, i, Listen_No);
						}
						else
						{
							SetListenOverride(client, i, Listen_Default);
						}
					}
					else
					{
						if (!DidClientEscape(client))
						{
							SetListenOverride(client, i, Listen_No);
						}
						else
						{
							SetListenOverride(client, i, Listen_Default);
						}
					}
				}
				else
				{
					new bool:bCanHear = false;
					if (GetConVarFloat(g_cvPlayerVoiceDistance) <= 0.0) bCanHear = true;
					
					if (!bCanHear)
					{
						decl Float:flMyPos[3], Float:flHisPos[3];
						GetClientEyePosition(client, flMyPos);
						GetClientEyePosition(i, flHisPos);
						
						new Float:flDist = GetVectorDistance(flMyPos, flHisPos);
						
						if (GetConVarFloat(g_cvPlayerVoiceWallScale) > 0.0)
						{
							new Handle:hTrace = TR_TraceRayFilterEx(flMyPos, flHisPos, MASK_SOLID_BRUSHONLY, RayType_EndPoint, TraceRayDontHitCharacters);
							new bool:bDidHit = TR_DidHit(hTrace);
							CloseHandle(hTrace);
							
							if (bDidHit)
							{
								flDist *= GetConVarFloat(g_cvPlayerVoiceWallScale);
							}
						}
						
						if (flDist <= GetConVarFloat(g_cvPlayerVoiceDistance))
						{
							bCanHear = true;
						}
					}
					
					if (bCanHear)
					{
						if (IsClientInGhostMode(i) != IsClientInGhostMode(client) &&
							DidClientEscape(i) != DidClientEscape(client))
						{
							bCanHear = false;
						}
					}
					
					if (bCanHear)
					{
						SetListenOverride(client, i, Listen_Default);
					}
					else
					{
						SetListenOverride(client, i, Listen_No);
					}
				}
			}
			else
			{
				SetListenOverride(client, i, Listen_No);
			}
		}
	}
}

stock ClientShowMainMessage(client, const String:sMessage[], any:...)
{
	decl String:message[512];
	VFormat(message, sizeof(message), sMessage, 3);
	
	SetHudTextParams(-1.0, 0.4,
		5.0,
		255,
		255,
		255,
		200,
		2,
		1.0,
		0.07,
		2.0);
	ShowSyncHudText(client, g_hHudSync, message);
}

stock ClientResetSlenderStats(client)
{
#if defined DEBUG
	if (GetConVarInt(g_cvDebugDetail) > 2) DebugMessage("START ClientResetSlenderStats(%d)", client);
#endif
	
	g_flPlayerStress[client] = 0.0;
	g_flPlayerStressNextUpdateTime[client] = -1.0;
	
	for (new i = 0; i < MAX_BOSSES; i++)
	{
		g_bPlayerSeesSlender[client][i] = false;
		g_flPlayerSeesSlenderLastTime[client][i] = -1.0;
		g_flPlayerSightSoundNextTime[client][i] = -1.0;
	}
	
#if defined DEBUG
	if (GetConVarInt(g_cvDebugDetail) > 2) DebugMessage("END ClientResetSlenderStats(%d)", client);
#endif
}

bool:ClientSetQueuePoints(client, iAmount)
{
	if (!IsClientConnected(client) || !AreClientCookiesCached(client)) return false;
	g_iPlayerQueuePoints[client] = iAmount;
	ClientSaveCookies(client);
	return true;
}

ClientSaveCookies(client)
{
	if (!IsClientConnected(client) || !AreClientCookiesCached(client)) return;
	
	// Save and reset our queue points.
	decl String:s[64];
	Format(s, sizeof(s), "%d ; %d ; %d ; %d ; %d ; %d", g_iPlayerQueuePoints[client], 
		g_iPlayerPreferences[client][PlayerPreference_ShowHints], 
		g_iPlayerPreferences[client][PlayerPreference_MuteMode], 
		g_iPlayerPreferences[client][PlayerPreference_FilmGrain],
		g_iPlayerPreferences[client][PlayerPreference_EnableProxySelection],
		g_iPlayerPreferences[client][PlayerPreference_GhostOverlay]);
		
	SetClientCookie(client, g_hCookie, s);
}

stock ClientViewPunch(client, const Float:angleOffset[3])
{
	if (g_offsPlayerPunchAngleVel == -1) return;
	
	decl Float:flOffset[3];
	for (new i = 0; i < 3; i++) flOffset[i] = angleOffset[i];
	ScaleVector(flOffset, 20.0);
	
	/*
	if (!IsFakeClient(client))
	{
		// Latency compensation.
		new Float:flLatency = GetClientLatency(client, NetFlow_Outgoing);
		new Float:flLatencyCalcDiff = 60.0 * Pow(flLatency, 2.0);
		
		for (new i = 0; i < 3; i++) flOffset[i] += (flOffset[i] * flLatencyCalcDiff);
	}
	*/
	
	decl Float:flAngleVel[3];
	GetEntDataVector(client, g_offsPlayerPunchAngleVel, flAngleVel);
	AddVectors(flAngleVel, flOffset, flOffset);
	SetEntDataVector(client, g_offsPlayerPunchAngleVel, flOffset, true);
}

public Action:Hook_ConstantGlowSetTransmit(ent, other)
{
	if (!g_bEnabled) return Plugin_Continue;
	
	new iOwner = -1;
	for (new i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i)) continue;
		if (EntRefToEntIndex(g_iPlayerConstantGlowEntity[i]) == ent)
		{
			iOwner = i;
			break;
		}
	}
	
	if (iOwner != -1)
	{
		if (!IsPlayerAlive(iOwner) || g_bPlayerEliminated[iOwner]) return Plugin_Handled;
		if (!IsPlayerAlive(other) || (!g_bPlayerProxy[other] && !IsClientInGhostMode(other))) return Plugin_Handled;
	}
	
	return Plugin_Continue;
}

stock ClientSetFOV(client, iFOV)
{
	SetEntData(client, g_offsPlayerFOV, iFOV);
	SetEntData(client, g_offsPlayerDefaultFOV, iFOV);
}

stock TF2_GetClassName(TFClassType:iClass, String:sBuffer[], sBufferLen)
{
	switch (iClass)
	{
		case TFClass_Scout: strcopy(sBuffer, sBufferLen, "scout");
		case TFClass_Sniper: strcopy(sBuffer, sBufferLen, "sniper");
		case TFClass_Soldier: strcopy(sBuffer, sBufferLen, "soldier");
		case TFClass_DemoMan: strcopy(sBuffer, sBufferLen, "demoman");
		case TFClass_Heavy: strcopy(sBuffer, sBufferLen, "heavyweapons");
		case TFClass_Medic: strcopy(sBuffer, sBufferLen, "medic");
		case TFClass_Pyro: strcopy(sBuffer, sBufferLen, "pyro");
		case TFClass_Spy: strcopy(sBuffer, sBufferLen, "spy");
		case TFClass_Engineer: strcopy(sBuffer, sBufferLen, "engineer");
		default: strcopy(sBuffer, sBufferLen, "");
	}
}

#define EF_DIMLIGHT (1 << 2)

stock ClientSDKFlashlightTurnOn(client)
{
	if (!IsValidClient(client)) return;
	
	new iEffects = GetEntProp(client, Prop_Send, "m_fEffects");
	if (iEffects & EF_DIMLIGHT) return;

	iEffects |= EF_DIMLIGHT;
	
	SetEntProp(client, Prop_Send, "m_fEffects", iEffects);
}

stock ClientSDKFlashlightTurnOff(client)
{
	if (!IsValidClient(client)) return;
	
	new iEffects = GetEntProp(client, Prop_Send, "m_fEffects");
	if (!(iEffects & EF_DIMLIGHT)) return;

	iEffects &= ~EF_DIMLIGHT;
	
	SetEntProp(client, Prop_Send, "m_fEffects", iEffects);
}

stock bool:IsPointVisibleToAPlayer(const Float:pos[3], bool:bCheckFOV=true, bool:bCheckBlink=false)
{
	for (new i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i)) continue;
		if (IsPointVisibleToPlayer(i, pos, bCheckFOV, bCheckBlink)) return true;
	}
	
	return false;
}

stock bool:IsPointVisibleToPlayer(client, const Float:pos[3], bool:bCheckFOV=true, bool:bCheckBlink=false, bool:bCheckEliminated=true)
{
	if (!IsValidClient(client) || !IsPlayerAlive(client) || IsClientInGhostMode(client)) return false;
	
	if (bCheckEliminated && g_bPlayerEliminated[client]) return false;
	
	if (bCheckBlink && IsClientBlinking(client)) return false;
	
	decl Float:eyePos[3];
	GetClientEyePosition(client, eyePos);
	
	// Check fog, if we can.
	if (g_offsPlayerFogCtrl != -1 && g_offsFogCtrlEnable != -1 && g_offsFogCtrlEnd != -1)
	{
		new iFogEntity = GetEntDataEnt2(client, g_offsPlayerFogCtrl);
		if (IsValidEdict(iFogEntity))
		{
			if (GetEntData(iFogEntity, g_offsFogCtrlEnable) &&
				GetVectorDistance(eyePos, pos) >= GetEntDataFloat(iFogEntity, g_offsFogCtrlEnd)) 
			{
				return false;
			}
		}
	}
	
	new Handle:hTrace = TR_TraceRayFilterEx(eyePos, pos, CONTENTS_SOLID | CONTENTS_MOVEABLE | CONTENTS_MIST, RayType_EndPoint, TraceRayDontHitCharactersOrEntity, client);
	new bool:bHit = TR_DidHit(hTrace);
	CloseHandle(hTrace);
	
	if (bHit) return false;
	
	if (bCheckFOV)
	{
		decl Float:eyeAng[3], Float:reqVisibleAng[3];
		GetClientEyeAngles(client, eyeAng);
		
		new Float:flFOV = float(g_iPlayerDesiredFOV[client]);
		SubtractVectors(pos, eyePos, reqVisibleAng);
		GetVectorAngles(reqVisibleAng, reqVisibleAng);
		
		new Float:difference = FloatAbs(AngleDiff(eyeAng[0], reqVisibleAng[0])) + FloatAbs(AngleDiff(eyeAng[1], reqVisibleAng[1]));
		if (difference > ((flFOV * 0.5) + 10.0)) return false;
	}
	
	return true;
}

public Action:Timer_ClientPostWeapons(Handle:timer, any:userid)
{
	new client = GetClientOfUserId(userid);
	if (client <= 0) return;
	
	if (!IsPlayerAlive(client)) return;
	
	if (timer != g_hPlayerPostWeaponsTimer[client]) return;
	
#if defined DEBUG
	if (GetConVarInt(g_cvDebugDetail) > 0) 
	{
		DebugMessage("START Timer_ClientPostWeapons(%d)", client);
	}
	
	new iOldWeaponItemIndexes[6] = { -1, ... };
	new iNewWeaponItemIndexes[6] = { -1, ... };
	
	for (new i = 0; i <= 5; i++)
	{
		new iWeapon = GetPlayerWeaponSlot(client, i);
		if (!IsValidEdict(iWeapon)) continue;
		
		iOldWeaponItemIndexes[i] = GetEntProp(iWeapon, Prop_Send, "m_iItemDefinitionIndex");
	}
	
#endif
	
	new bool:bRemoveWeapons = true;
	new bool:bRestrictWeapons = true;
	
	if (IsRoundEnding())
	{
		if (!g_bPlayerEliminated[client]) 
		{
			bRemoveWeapons = false;
			bRestrictWeapons = false;
		}
	}
	
	// pvp
	if (IsClientInPvP(client)) 
	{
		bRemoveWeapons = false;
		bRestrictWeapons = false;
	}
	
	if (IsRoundInWarmup()) 
	{
		bRemoveWeapons = false;
		bRestrictWeapons = false;
	}
	
	if (IsClientInGhostMode(client)) 
	{
		bRemoveWeapons = true;
	}
	
	if (bRemoveWeapons)
	{
		for (new i = 0; i <= 5; i++)
		{
			if (i == TFWeaponSlot_Melee && !IsClientInGhostMode(client)) continue;
			TF2_RemoveWeaponSlotAndWearables(client, i);
		}
		
		new ent = -1;
		while ((ent = FindEntityByClassname(ent, "tf_weapon_builder")) != -1)
		{
			if (GetEntPropEnt(ent, Prop_Send, "m_hOwnerEntity") == client)
			{
				AcceptEntityInput(ent, "Kill");
			}
		}
		
		ent = -1;
		while ((ent = FindEntityByClassname(ent, "tf_wearable_demoshield")) != -1)
		{
			if (GetEntPropEnt(ent, Prop_Send, "m_hOwnerEntity") == client)
			{
				AcceptEntityInput(ent, "Kill");
			}
		}
		
		ClientSwitchToWeaponSlot(client, TFWeaponSlot_Melee);
	}
	
	if (bRestrictWeapons)
	{
		new iHealth = GetEntProp(client, Prop_Send, "m_iHealth");
		
		if (g_hRestrictedWeaponsConfig != INVALID_HANDLE)
		{
			new TFClassType:iPlayerClass = TF2_GetPlayerClass(client);
			new Handle:hItem = INVALID_HANDLE;
			
			new iWeapon = INVALID_ENT_REFERENCE;
			for (new iSlot = 0; iSlot <= 5; iSlot++)
			{
				iWeapon = GetPlayerWeaponSlot(client, iSlot);
				
				if (IsValidEdict(iWeapon))
				{
					if (IsWeaponRestricted(iPlayerClass, GetEntProp(iWeapon, Prop_Send, "m_iItemDefinitionIndex")))
					{
						hItem = INVALID_HANDLE;
						TF2_RemoveWeaponSlotAndWearables(client, iSlot);
						
						switch (iSlot)
						{
							case TFWeaponSlot_Primary:
							{
								switch (iPlayerClass)
								{
									case TFClass_Scout: hItem = g_hSDKWeaponScattergun;
									case TFClass_Sniper: hItem = g_hSDKWeaponSniperRifle;
									case TFClass_Soldier: hItem = g_hSDKWeaponRocketLauncher;
									case TFClass_DemoMan: hItem = g_hSDKWeaponGrenadeLauncher;
									case TFClass_Heavy: hItem = g_hSDKWeaponMinigun;
									case TFClass_Medic: hItem = g_hSDKWeaponSyringeGun;
									case TFClass_Pyro: hItem = g_hSDKWeaponFlamethrower;
									case TFClass_Spy: hItem = g_hSDKWeaponRevolver;
									case TFClass_Engineer: hItem = g_hSDKWeaponShotgunPrimary;
								}
							}
							case TFWeaponSlot_Secondary:
							{
								switch (iPlayerClass)
								{
									case TFClass_Scout: hItem = g_hSDKWeaponPistolScout;
									case TFClass_Sniper: hItem = g_hSDKWeaponSMG;
									case TFClass_Soldier: hItem = g_hSDKWeaponShotgunSoldier;
									case TFClass_DemoMan: hItem = g_hSDKWeaponStickyLauncher;
									case TFClass_Heavy: hItem = g_hSDKWeaponShotgunHeavy;
									case TFClass_Medic: hItem = g_hSDKWeaponMedigun;
									case TFClass_Pyro: hItem = g_hSDKWeaponShotgunPyro;
									case TFClass_Engineer: hItem = g_hSDKWeaponPistol;
								}
							}
							case TFWeaponSlot_Melee:
							{
								switch (iPlayerClass)
								{
									case TFClass_Scout: hItem = g_hSDKWeaponBat;
									case TFClass_Sniper: hItem = g_hSDKWeaponKukri;
									case TFClass_Soldier: hItem = g_hSDKWeaponShovel;
									case TFClass_DemoMan: hItem = g_hSDKWeaponBottle;
									case TFClass_Heavy: hItem = g_hSDKWeaponFists;
									case TFClass_Medic: hItem = g_hSDKWeaponBonesaw;
									case TFClass_Pyro: hItem = g_hSDKWeaponFireaxe;
									case TFClass_Spy: hItem = g_hSDKWeaponKnife;
									case TFClass_Engineer: hItem = g_hSDKWeaponWrench;
								}
							}
							case 4:
							{
								switch (iPlayerClass)
								{
									case TFClass_Spy: hItem = g_hSDKWeaponInvis;
								}
							}
						}
						
						if (hItem != INVALID_HANDLE)
						{
							new iNewWeapon = TF2Items_GiveNamedItem(client, hItem);
							if (IsValidEntity(iNewWeapon)) 
							{
								EquipPlayerWeapon(client, iNewWeapon);
							}
						}
					}
				}
			}
		}
		
		// Fixes the Pretty Boy's Pocket Pistol glitch.
		new iMaxHealth = SDKCall(g_hSDKGetMaxHealth, client);
		if (iHealth > iMaxHealth)
		{
			SetEntProp(client, Prop_Data, "m_iHealth", iMaxHealth);
			SetEntProp(client, Prop_Send, "m_iHealth", iMaxHealth);
		}
	}
	
	// Change stats on some weapons.
	if (!g_bPlayerEliminated[client] || g_bPlayerProxy[client])
	{
		new iWeapon = INVALID_ENT_REFERENCE;
		decl Handle:hWeapon;
		for (new iSlot = 0; iSlot <= 5; iSlot++)
		{
			iWeapon = GetPlayerWeaponSlot(client, iSlot);
			if (!iWeapon || iWeapon == INVALID_ENT_REFERENCE) continue;
			
			new iItemDef = GetEntProp(iWeapon, Prop_Send, "m_iItemDefinitionIndex");
			switch (iItemDef)
			{
				case 214: // Powerjack
				{
					TF2_RemoveWeaponSlot(client, iSlot);
					
					hWeapon = PrepareItemHandle("tf_weapon_fireaxe", 214, 0, 0, "180 ; 20.0 ; 206 ; 1.33");
					new iEnt = TF2Items_GiveNamedItem(client, hWeapon);
					CloseHandle(hWeapon);
					EquipPlayerWeapon(client, iEnt);
				}
			}
		}
	}
	if (DidClientEscape(client) && IsClientInPvP(client))
	{
		new iWeapon = INVALID_ENT_REFERENCE;
		decl Handle:hWeapon;
		for (new iSlot = 0; iSlot <= 5; iSlot++)
		{
			iWeapon = GetPlayerWeaponSlot(client, iSlot);
			if (!iWeapon || iWeapon == INVALID_ENT_REFERENCE) continue;
			
			new iItemDef = GetEntProp(iWeapon, Prop_Send, "m_iItemDefinitionIndex");
			switch (iItemDef)
			{
				case 589: // Eureka Effect
				{
					TF2_RemoveWeaponSlot(client, iSlot);
					
					hWeapon = PrepareItemHandle("tf_weapon_wrench", 589, 0, 0, "93 ; 0.5 ; 732 ; 0.5");
					new iEnt = TF2Items_GiveNamedItem(client, hWeapon);
					CloseHandle(hWeapon);
					EquipPlayerWeapon(client, iEnt);
				}
			}
		}
	}
	// Remove all hats.
	if (IsClientInGhostMode(client))
	{
		new ent = -1;
		while ((ent = FindEntityByClassname(ent, "tf_wearable")) != -1)
		{
			if (GetEntPropEnt(ent, Prop_Send, "m_hOwnerEntity") == client)
			{
				AcceptEntityInput(ent, "Kill");
			}
		}
	}
	
#if defined DEBUG
	for (new i = 0; i <= 5; i++)
	{
		new iWeapon = GetPlayerWeaponSlot(client, i);
		if (!IsValidEdict(iWeapon)) continue;
		
		iNewWeaponItemIndexes[i] = GetEntProp(iWeapon, Prop_Send, "m_iItemDefinitionIndex");
	}

	if (GetConVarInt(g_cvDebugDetail) > 0) 
	{
		for (new i = 0; i <= 5; i++)
		{
			DebugMessage("-> slot %d: %d (old: %d)", i, iNewWeaponItemIndexes[i], iOldWeaponItemIndexes[i]);
		}
	
		DebugMessage("END Timer_ClientPostWeapons(%d) -> remove = %d, restrict = %d", client, bRemoveWeapons, bRestrictWeapons);
	}
#endif
}

public Action:Timer_ApplyCustomModel(Handle:timer, any:userid)
{
	new client = GetClientOfUserId(userid);
	if (client <= 0) return;
	
	new iMaster = NPCGetFromUniqueID(g_iPlayerProxyMaster[client]);
	
	if (g_bPlayerProxy[client] && iMaster != -1)
	{
		decl String:sProfile[SF2_MAX_PROFILE_NAME_LENGTH];
		NPCGetProfile(iMaster, sProfile, sizeof(sProfile));
		
		// Set custom model, if any.
		decl String:sBuffer[PLATFORM_MAX_PATH];
		decl String:sSectionName[64];
		
		TF2_RegeneratePlayer(client);
		
		decl String:sClassName[64];
		TF2_GetClassName(TF2_GetPlayerClass(client), sClassName, sizeof(sClassName));
		
		Format(sSectionName, sizeof(sSectionName), "mod_proxy_%s", sClassName);
		if ((GetRandomStringFromProfile(sProfile, sSectionName, sBuffer, sizeof(sBuffer)) && sBuffer[0]) ||
			(GetRandomStringFromProfile(sProfile, "mod_proxy_all", sBuffer, sizeof(sBuffer)) && sBuffer[0]))
		{
			SetVariantString(sBuffer);
			AcceptEntityInput(client, "SetCustomModel");
			SetEntProp(client, Prop_Send, "m_bUseClassAnimations", true);
			Format(g_sClientProxyModel[client],sizeof(g_sClientProxyModel[]),sBuffer);
			//Prevent plugins like Model manager to override proxy model.
			CreateTimer(0.5,ClientCheckProxyModel,client,TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
		}
		new ent = -1;
		while ((ent = FindEntityByClassname(ent, "tf_wearable")) != -1)
		{
			if (GetEntPropEnt(ent, Prop_Send, "m_hOwnerEntity") == client)
			{
				AcceptEntityInput(ent, "Kill");
			}
		}
		if (IsPlayerAlive(client))
		{
			// Play any sounds, if any.
			if (GetRandomStringFromProfile(sProfile, "sound_proxy_spawn", sBuffer, sizeof(sBuffer)) && sBuffer[0])
			{
				new iChannel = GetProfileNum(sProfile, "sound_proxy_spawn_channel", SNDCHAN_AUTO);
				new iLevel = GetProfileNum(sProfile, "sound_proxy_spawn_level", SNDLEVEL_NORMAL);
				new iFlags = GetProfileNum(sProfile, "sound_proxy_spawn_flags", SND_NOFLAGS);
				new Float:flVolume = GetProfileFloat(sProfile, "sound_proxy_spawn_volume", SNDVOL_NORMAL);
				new iPitch = GetProfileNum(sProfile, "sound_proxy_spawn_pitch", SNDPITCH_NORMAL);
				
				EmitSoundToAll(sBuffer, client, iChannel, iLevel, iFlags, flVolume, iPitch);
			}
			new bool:Zombie = bool:GetProfileNum(sProfile, "proxies_zombie", 0);
			if(Zombie)
			{
				new value = GetConVarInt(FindConVar("tf_forced_holiday"));
				if(value != 9 && value != 2)
					SetConVarInt(FindConVar("tf_forced_holiday"),9);//Full-Moon
				new index;
				new TFClassType:iClass = TF2_GetPlayerClass( client );
				switch(iClass)
				{
					case TFClass_Scout: index = 5617;
					case TFClass_Soldier: index = 5618;
					case TFClass_Pyro: index = 5624;
					case TFClass_DemoMan: index = 5620;
					case TFClass_Engineer: index = 5621;
					case TFClass_Heavy: index = 5619;
					case TFClass_Medic: index = 5622;
					case TFClass_Sniper: index = 5625;
					case TFClass_Spy: index = 5623;
				}
				new Handle:ZombieSoul = PrepareItemHandle("tf_wearable", index, 100, 7,"448 ; 1.0 ; 450 ; 1");
				new entity = TF2Items_GiveNamedItem(client, ZombieSoul);
				CloseHandle(ZombieSoul);
				if( IsValidEdict( entity ) )
				{
					if( g_hSDKEquipWearable != INVALID_HANDLE )
					{
						SDKCall( g_hSDKEquipWearable, client, entity );
					}
				}
				if(TF2_GetPlayerClass(client) == TFClass_Spy)
					SetEntProp(client, Prop_Send, "m_nForcedSkin", 23);
				else
					SetEntProp(client, Prop_Send, "m_nForcedSkin", 5);
			}	
		}
	}
}
public Action:ClientCheckProxyModel(Handle:timer, any:userid)
{
	new client = GetClientOfUserId(userid);
	if(!IsValidClient(client)) return Plugin_Stop;
	if(!IsPlayerAlive(client)) return Plugin_Stop;
	if(!g_bPlayerProxy[client]) return Plugin_Stop;
	
	decl String:sModel[PLATFORM_MAX_PATH];
	GetEntPropString(client, Prop_Data, "m_ModelName", sModel, sizeof(sModel));
	if (!StrEqual(sModel,g_sClientProxyModel[client]))
	{
		SetVariantString(g_sClientProxyModel[client]);
		AcceptEntityInput(client, "SetCustomModel");
		SetEntProp(client, Prop_Send, "m_bUseClassAnimations", true);
	}
	return Plugin_Continue;
}
bool:IsWeaponRestricted(TFClassType:iClass, iItemDef)
{
	if (g_hRestrictedWeaponsConfig == INVALID_HANDLE) return false;
	
	new bool:bReturn = false;
	
	decl String:sItemDef[32];
	IntToString(iItemDef, sItemDef, sizeof(sItemDef));
	
	KvRewind(g_hRestrictedWeaponsConfig);
	new bool:bProxyBoss = false;
	for (new i = 0; i < MAX_BOSSES; i++)
	{
		if (NPCGetUniqueID(i) == -1) continue;
		if (NPCGetFlags(i) & SFF_PROXIES)
		{
			bProxyBoss = true;
			break;
		}
	}
	if (KvJumpToKey(g_hRestrictedWeaponsConfig, "all"))
	{
		bReturn = bool:KvGetNum(g_hRestrictedWeaponsConfig, sItemDef);
		if(bProxyBoss)
		{
			new bProxyRestricted = KvGetNum(g_hRestrictedWeaponsConfig, sItemDef, bReturn);
			if(bProxyRestricted==2)
				bReturn=true;
		}
	}
	
	new bool:bFoundSection = false;
	KvRewind(g_hRestrictedWeaponsConfig);
	
	switch (iClass)
	{
		case TFClass_Scout: bFoundSection = KvJumpToKey(g_hRestrictedWeaponsConfig, "scout");
		case TFClass_Soldier: bFoundSection = KvJumpToKey(g_hRestrictedWeaponsConfig, "soldier");
		case TFClass_Sniper: bFoundSection = KvJumpToKey(g_hRestrictedWeaponsConfig, "sniper");
		case TFClass_DemoMan: bFoundSection = KvJumpToKey(g_hRestrictedWeaponsConfig, "demoman");
		case TFClass_Heavy: 
		{
			bFoundSection = KvJumpToKey(g_hRestrictedWeaponsConfig, "heavy");
		
			if (!bFoundSection)
			{
				KvRewind(g_hRestrictedWeaponsConfig);
				bFoundSection = KvJumpToKey(g_hRestrictedWeaponsConfig, "heavyweapons");
			}
		}
		case TFClass_Medic: bFoundSection = KvJumpToKey(g_hRestrictedWeaponsConfig, "medic");
		case TFClass_Spy: bFoundSection = KvJumpToKey(g_hRestrictedWeaponsConfig, "spy");
		case TFClass_Pyro: bFoundSection = KvJumpToKey(g_hRestrictedWeaponsConfig, "pyro");
		case TFClass_Engineer: bFoundSection = KvJumpToKey(g_hRestrictedWeaponsConfig, "engineer");
	}
	
	if (bFoundSection)
	{
		if(bProxyBoss)
		{
			new bProxyRestricted = KvGetNum(g_hRestrictedWeaponsConfig, sItemDef, bReturn);
			if(bProxyRestricted==2)
				bReturn=true;
		}
		bReturn = bool:KvGetNum(g_hRestrictedWeaponsConfig, sItemDef, bReturn);
	}
	
	return bReturn;
}

public Action:Timer_RespawnPlayer(Handle:timer, any:userid)
{
	new client = GetClientOfUserId(userid);
	if (client <= 0) return;
	
	if (IsPlayerAlive(client)) return;
	
	TF2_RespawnPlayer(client);
}