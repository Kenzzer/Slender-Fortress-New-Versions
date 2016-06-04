#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <clientprefs>
#include <steamworks>
#include <tf2items>
#include <tf2attributes>
#include <dhooks>
#include <navmesh>
#include <nativevotes>

#include <tf2>
#include <tf2_stocks>
#include <morecolors>

#undef REQUIRE_PLUGIN
#include <adminmenu>
#tryinclude <store/store-tf2footprints>
#define REQUIRE_PLUGIN

#undef REQUIRE_EXTENSIONS
#tryinclude <steamtools>
#tryinclude <steamworks>
#tryinclude <sendproxy>
#define REQUIRE_EXTENSIONS

bool steamtools=false;
bool steamworks=false;
bool sendproxymanager=false;

//#define DEBUG

#include <sf2>
#pragma newdecls required

// If compiling with SM 1.7+, uncomment to compile and use SF2 methodmaps.
//#define METHODMAPS

#define PLUGIN_VERSION "0.3.2_1"
#define PLUGIN_VERSION_DISPLAY "0.3.2"

#define TFTeam_Spectator 1
#define TFTeam_Red 2
#define TFTeam_Blue 3
//#define TFTeam_Boss 5

#define EF_ITEM_BLINK 0x100


public Plugin myinfo = 
{
    name = "Slender Fortress",
    author	= "KitRifty, Benoist3012",
    description	= "Based on the game Slender: The Eight Pages.",
    version = PLUGIN_VERSION,
    url = "http://steamcommunity.com/groups/SlenderFortress"
}

#define FILE_RESTRICTEDWEAPONS "configs/sf2/restrictedweapons.cfg"

#define BOSS_THINKRATE 0.1 // doesn't really matter much since timers go at a minimum of 0.1 seconds anyways

#define CRIT_SOUND "player/crit_hit.wav"
#define CRIT_PARTICLENAME "crit_text"
#define MINICRIT_SOUND "player/crit_hit_mini.wav"
#define MINICRIT_PARTICLENAME "minicrit_text"
#define ZAP_SOUND "weapons/barret_arm_zap.wav"
#define ZAP_PARTICLENAME "dxhr_arm_muzzleflash"
#define FIREWORKSBLU_PARTICLENAME "utaunt_firework_teamcolor_blue"
#define FIREWORKSRED_PARTICLENAME "utaunt_firework_teamcolor_red"

#define PAGE_MODEL "models/slender/sheet.mdl"
#define PAGE_MODELSCALE 1.1

#define SF_KEYMODEL "models/demani_sf/key_australium.mdl"

#define FLASHLIGHT_CLICKSOUND "slender/newflashlight.wav"
#define FLASHLIGHT_BREAKSOUND "ambient/energy/spark6.wav"
#define FLASHLIGHT_NOSOUND "player/suit_denydevice.wav"
#define PAGE_GRABSOUND "slender/newgrabpage.wav"

#define MUSIC_CHAN SNDCHAN_AUTO
#define MUSIC_GOTPAGES1_SOUND "slender/newambience_1.wav"
#define MUSIC_GOTPAGES2_SOUND "slender/newambience_2.wav"
#define MUSIC_GOTPAGES3_SOUND "slender/newambience_3.wav"
#define MUSIC_GOTPAGES4_SOUND "slender/newambience_4.wav"
#define MUSIC_PAGE_VOLUME 1.0

#define SF2_INTRO_DEFAULT_MUSIC "slender/intro.mp3"

#define SF2_HUD_TEXT_COLOR_R 127
#define SF2_HUD_TEXT_COLOR_G 167
#define SF2_HUD_TEXT_COLOR_B 141
#define SF2_HUD_TEXT_COLOR_A 255

enum MuteMode
{
	MuteMode_Normal = 0,
	MuteMode_DontHearOtherTeam,
	MuteMode_DontHearOtherTeamIfNotProxy
};

//Update
bool g_bSeeUpdateMenu[MAXPLAYERS+1] = false;
//Command
bool g_bAdminNoPoints[MAXPLAYERS+1] = false;
//Snd_Restart anti-cheat
float g_fLastTimeSndRestart[MAXPLAYERS+1]; 

// Offsets.
int g_offsPlayerFOV = -1;
int g_offsPlayerDefaultFOV = -1;
int g_offsPlayerFogCtrl = -1;
int g_offsPlayerPunchAngle = -1;
int g_offsPlayerPunchAngleVel = -1;
int g_offsFogCtrlEnable = -1;
int g_offsFogCtrlEnd = -1;
int g_offsCollisionGroup = -1;

bool g_bEnabled;

Handle g_hConfig;
Handle g_hRestrictedWeaponsConfig;
Handle g_hSpecialRoundsConfig;

Handle g_hPageMusicRanges;

int g_iSlenderModel[MAX_BOSSES] = { INVALID_ENT_REFERENCE, ... };
int g_iSlenderPoseEnt[MAX_BOSSES] = { INVALID_ENT_REFERENCE, ... };
int g_iSlenderCopyMaster[MAX_BOSSES] = { -1, ... };
float g_flSlenderEyePosOffset[MAX_BOSSES][3];
float g_flSlenderEyeAngOffset[MAX_BOSSES][3];
float g_flSlenderDetectMins[MAX_BOSSES][3];
float g_flSlenderDetectMaxs[MAX_BOSSES][3];
Handle g_hSlenderThink[MAX_BOSSES];
Handle g_hSlenderEntityThink[MAX_BOSSES];
Handle g_hSlenderFakeTimer[MAX_BOSSES];
float g_flSlenderLastKill[MAX_BOSSES];
int g_iSlenderState[MAX_BOSSES];
int g_iSlenderHitbox[MAX_BOSSES];
int g_iSlenderTarget[MAX_BOSSES] = { INVALID_ENT_REFERENCE, ... };
float g_flSlenderAcceleration[MAX_BOSSES];
float g_flSlenderGoalPos[MAX_BOSSES][3];
float g_flSlenderStaticRadius[MAX_BOSSES];
float g_flSlenderChaseDeathPosition[MAX_BOSSES][3];
bool g_bSlenderChaseDeathPosition[MAX_BOSSES];
float g_flSlenderIdleAnimationPlaybackRate[MAX_BOSSES];
float g_flSlenderWalkAnimationPlaybackRate[MAX_BOSSES];
float g_flSlenderRunAnimationPlaybackRate[MAX_BOSSES];
float g_flSlenderJumpSpeed[MAX_BOSSES];
float g_flSlenderPathNodeTolerance[MAX_BOSSES];
float g_flSlenderPathNodeLookAhead[MAX_BOSSES];
bool g_bSlenderFeelerReflexAdjustment[MAX_BOSSES];
float g_flSlenderFeelerReflexAdjustmentPos[MAX_BOSSES][3];

int g_iSlenderTeleportTarget[MAX_BOSSES] = { INVALID_ENT_REFERENCE, ... };
bool g_bSlenderTeleportTargetIsCamping[MAX_BOSSES] = false;

float g_flSlenderNextTeleportTime[MAX_BOSSES] = { -1.0, ... };
float g_flSlenderTeleportTargetTime[MAX_BOSSES] = { -1.0, ... };
float g_flSlenderTeleportMinRange[MAX_BOSSES] = { -1.0, ... };
float g_flSlenderTeleportMaxRange[MAX_BOSSES] = { -1.0, ... };
float g_flSlenderTeleportMaxTargetTime[MAX_BOSSES] = { -1.0, ... };
float g_flSlenderTeleportMaxTargetStress[MAX_BOSSES] = { 0.0, ... };
float g_flSlenderTeleportPlayersRestTime[MAX_BOSSES][MAXPLAYERS + 1];

// For boss type 2
// General variables
int g_iSlenderHealth[MAX_BOSSES];
Handle g_hSlenderPath[MAX_BOSSES];
//int g_iGoalPath[MAX_BOSSES][2];
int g_iSlenderCurrentPathNode[MAX_BOSSES] = { -1, ... };
bool g_bSlenderAttacking[MAX_BOSSES];
Handle g_hSlenderAttackTimer[MAX_BOSSES];
float g_flSlenderNextJump[MAX_BOSSES] = { -1.0, ... };
int g_iSlenderInterruptConditions[MAX_BOSSES];
float g_flSlenderLastFoundPlayer[MAX_BOSSES][MAXPLAYERS + 1];
float g_flSlenderLastFoundPlayerPos[MAX_BOSSES][MAXPLAYERS + 1][3];
float g_flSlenderNextPathTime[MAX_BOSSES] = { -1.0, ... };
float g_flSlenderCalculatedWalkSpeed[MAX_BOSSES];
float g_flSlenderCalculatedSpeed[MAX_BOSSES];
float g_flSlenderCalculatedAirSpeed[MAX_BOSSES];
float g_flSlenderTimeUntilNoPersistence[MAX_BOSSES];

float g_flSlenderProxyTeleportMinRange[MAX_BOSSES];
float g_flSlenderProxyTeleportMaxRange[MAX_BOSSES];

// Sound variables
float g_flSlenderTargetSoundLastTime[MAX_BOSSES] = { -1.0, ... };
SoundType g_iSlenderTargetSoundType[MAX_BOSSES] = { SoundType_None, ... };
float g_flSlenderTargetSoundMasterPos[MAX_BOSSES][3]; // to determine hearing focus
float g_flSlenderTargetSoundTempPos[MAX_BOSSES][3];
float g_flSlenderTargetSoundDiscardMasterPosTime[MAX_BOSSES];
bool g_bSlenderInvestigatingSound[MAX_BOSSES];
int g_iSlenderTargetSoundCount[MAX_BOSSES];
float g_flSlenderLastHeardVoice[MAX_BOSSES];
float g_flSlenderLastHeardFootstep[MAX_BOSSES];
float g_flSlenderLastHeardWeapon[MAX_BOSSES];


float g_flSlenderNextJumpScare[MAX_BOSSES] = { -1.0, ... };
float g_flSlenderNextVoiceSound[MAX_BOSSES] = { -1.0, ... };
float g_flSlenderNextMoanSound[MAX_BOSSES] = { -1.0, ... };
float g_flSlenderNextWanderPos[MAX_BOSSES] = { -1.0, ... };


float g_flSlenderTimeUntilRecover[MAX_BOSSES] = { -1.0, ... };
float g_flSlenderTimeUntilAlert[MAX_BOSSES] = { -1.0, ... };
float g_flSlenderTimeUntilIdle[MAX_BOSSES] = { -1.0, ... };
float g_flSlenderTimeUntilChase[MAX_BOSSES] = { -1.0, ... };
float g_flSlenderTimeUntilKill[MAX_BOSSES] = { -1.0, ... };
float g_flSlenderTimeUntilNextProxy[MAX_BOSSES] = { -1.0, ... };

bool g_bSlenderInBacon[MAX_BOSSES];

//Healthbar
int g_ihealthBar;

// Page data.
int g_iPageCount;
int g_iPageMax;
float g_flPageFoundLastTime;
bool g_bPageRef;
char g_strPageRefModel[PLATFORM_MAX_PATH];
float g_flPageRefModelScale;

static Handle g_hPlayerIntroMusicTimer[MAXPLAYERS + 1] = { INVALID_HANDLE, ... };

// Seeing Mr. Slendy data.

float g_flLastVisibilityProcess[MAXPLAYERS + 1];
bool g_bPlayerSeesSlender[MAXPLAYERS + 1][MAX_BOSSES];
float g_flPlayerSeesSlenderLastTime[MAXPLAYERS + 1][MAX_BOSSES];

float g_flPlayerSightSoundNextTime[MAXPLAYERS + 1][MAX_BOSSES];

float g_flPlayerScareLastTime[MAXPLAYERS + 1][MAX_BOSSES];
float g_flPlayerScareNextTime[MAXPLAYERS + 1][MAX_BOSSES];
float g_flPlayerStaticAmount[MAXPLAYERS + 1];

float g_flPlayerLastChaseBossEncounterTime[MAXPLAYERS + 1][MAX_BOSSES];

// Player static data.
int g_iPlayerStaticMode[MAXPLAYERS + 1][MAX_BOSSES];
float g_flPlayerStaticIncreaseRate[MAXPLAYERS + 1];
float g_flPlayerStaticDecreaseRate[MAXPLAYERS + 1];
Handle g_hPlayerStaticTimer[MAXPLAYERS + 1];
int g_iPlayerStaticMaster[MAXPLAYERS + 1] = { -1, ... };
char g_strPlayerStaticSound[MAXPLAYERS + 1][PLATFORM_MAX_PATH];
char g_strPlayerLastStaticSound[MAXPLAYERS + 1][PLATFORM_MAX_PATH];
float g_flPlayerLastStaticTime[MAXPLAYERS + 1];
float g_flPlayerLastStaticVolume[MAXPLAYERS + 1];
Handle g_hPlayerLastStaticTimer[MAXPLAYERS + 1];

// Static shake data.
int g_iPlayerStaticShakeMaster[MAXPLAYERS + 1];
bool g_bPlayerInStaticShake[MAXPLAYERS + 1];
char g_strPlayerStaticShakeSound[MAXPLAYERS + 1][PLATFORM_MAX_PATH];
float g_flPlayerStaticShakeMinVolume[MAXPLAYERS + 1];
float g_flPlayerStaticShakeMaxVolume[MAXPLAYERS + 1];

// Fake lag compensation for FF.
bool g_bPlayerLagCompensation[MAXPLAYERS + 1];
int g_iPlayerLagCompensationTeam[MAXPLAYERS + 1];

// Hint data.
enum
{
	PlayerHint_Sprint = 0,
	PlayerHint_Flashlight,
	PlayerHint_MainMenu,
	PlayerHint_Blink,
	PlayerHint_MaxNum
};

enum PlayerPreferences
{
	bool:PlayerPreference_PvPAutoSpawn,
	MuteMode:PlayerPreference_MuteMode,
	bool:PlayerPreference_FilmGrain,
	bool:PlayerPreference_ShowHints,
	bool:PlayerPreference_EnableProxySelection,
	bool:PlayerPreference_ProjectedFlashlight,
	bool:PlayerPreference_GhostOverlay
};

bool g_bPlayerHints[MAXPLAYERS + 1][PlayerHint_MaxNum];
int g_iPlayerPreferences[MAXPLAYERS + 1][PlayerPreferences];

//Particle data.
enum
{
	CriticalHit = 0,
	MiniCritHit,
	ZapParticle,
	FireworksRED,
	FireworksBLU,
	MaxParticle,
};

int g_iParticle[MaxParticle] = -1;

// Player data.
bool g_bPlayerIsExitCamping[MAXPLAYERS + 1];
int g_iPlayerLastButtons[MAXPLAYERS + 1];
bool g_bPlayerChoseTeam[MAXPLAYERS + 1];
bool g_bPlayerEliminated[MAXPLAYERS + 1];
bool g_bPlayerEscaped[MAXPLAYERS + 1];
int g_iPlayerPageCount[MAXPLAYERS + 1];
int g_iPlayerQueuePoints[MAXPLAYERS + 1];
bool g_bPlayerPlaying[MAXPLAYERS + 1];
Handle g_hPlayerOverlayCheck[MAXPLAYERS + 1];

Handle g_hPlayerSwitchBlueTimer[MAXPLAYERS + 1];

// Player stress data.
float g_flPlayerStress[MAXPLAYERS + 1];
float g_flPlayerStressNextUpdateTime[MAXPLAYERS + 1];

// Proxy data.
bool g_bPlayerProxy[MAXPLAYERS + 1];
bool g_bPlayerProxyAvailable[MAXPLAYERS + 1];
Handle g_hPlayerProxyAvailableTimer[MAXPLAYERS + 1];
bool g_bPlayerProxyAvailableInForce[MAXPLAYERS + 1];
int g_iPlayerProxyAvailableCount[MAXPLAYERS + 1];
int g_iPlayerProxyMaster[MAXPLAYERS + 1];
int g_iPlayerProxyControl[MAXPLAYERS + 1];
Handle g_hPlayerProxyControlTimer[MAXPLAYERS + 1];
float g_flPlayerProxyControlRate[MAXPLAYERS + 1];
Handle g_flPlayerProxyVoiceTimer[MAXPLAYERS + 1];
int g_iPlayerProxyAskMaster[MAXPLAYERS + 1] = { -1, ... };
float g_iPlayerProxyAskPosition[MAXPLAYERS + 1][3];

int g_iPlayerDesiredFOV[MAXPLAYERS + 1];

Handle g_hPlayerPostWeaponsTimer[MAXPLAYERS + 1] = { INVALID_HANDLE, ... };

// Music system.
int g_iPlayerMusicFlags[MAXPLAYERS + 1];
char g_strPlayerMusic[MAXPLAYERS + 1][PLATFORM_MAX_PATH];
float g_flPlayerMusicVolume[MAXPLAYERS + 1];
float g_flPlayerMusicTargetVolume[MAXPLAYERS + 1];
Handle g_hPlayerMusicTimer[MAXPLAYERS + 1];
int g_iPlayerPageMusicMaster[MAXPLAYERS + 1];

// Chase music system, which apparently also uses the alert song system. And the idle sound system.
char g_strPlayerChaseMusic[MAXPLAYERS + 1][PLATFORM_MAX_PATH];
char g_strPlayerChaseMusicSee[MAXPLAYERS + 1][PLATFORM_MAX_PATH];
float g_flPlayerChaseMusicVolumes[MAXPLAYERS + 1][MAX_BOSSES];
float g_flPlayerChaseMusicSeeVolumes[MAXPLAYERS + 1][MAX_BOSSES];
Handle g_hPlayerChaseMusicTimer[MAXPLAYERS + 1][MAX_BOSSES];
Handle g_hPlayerChaseMusicSeeTimer[MAXPLAYERS + 1][MAX_BOSSES];
int g_iPlayerChaseMusicMaster[MAXPLAYERS + 1] = { -1, ... };
int g_iPlayerChaseMusicSeeMaster[MAXPLAYERS + 1] = { -1, ... };

char g_strPlayerAlertMusic[MAXPLAYERS + 1][PLATFORM_MAX_PATH];
float g_flPlayerAlertMusicVolumes[MAXPLAYERS + 1][MAX_BOSSES];
Handle g_hPlayerAlertMusicTimer[MAXPLAYERS + 1][MAX_BOSSES];
int g_iPlayerAlertMusicMaster[MAXPLAYERS + 1] = { -1, ... };


char g_strPlayer20DollarsMusic[MAXPLAYERS + 1][PLATFORM_MAX_PATH];
float g_flPlayer20DollarsMusicVolumes[MAXPLAYERS + 1][MAX_BOSSES];
Handle g_hPlayer20DollarsMusicTimer[MAXPLAYERS + 1][MAX_BOSSES];
int g_iPlayer20DollarsMusicMaster[MAXPLAYERS + 1] = { -1, ... };


SF2RoundState g_iRoundState = SF2RoundState_Invalid;
bool g_bRoundGrace = false;
float g_flRoundDifficultyModifier = DIFFICULTY_NORMAL;
bool g_bRoundInfiniteFlashlight = false;
bool g_bIsSurvivalMap = false;
bool g_bIsRaidMap = false;
bool g_bRoundInfiniteBlink = false;
bool g_bRoundInfiniteSprint = false;

Handle g_hRoundGraceTimer = INVALID_HANDLE;
static Handle g_hRoundTimer = INVALID_HANDLE;
static Handle g_hVoteTimer = INVALID_HANDLE;
static char g_strRoundBossProfile[SF2_MAX_PROFILE_NAME_LENGTH];

static int g_iRoundCount = 0;
static int g_iRoundEndCount = 0;
static int g_iRoundActiveCount = 0;
int g_iRoundTime = 0;
static int g_iTimeEscape = 0;
static int g_iRoundTimeLimit = 0;
static int g_iRoundEscapeTimeLimit = 0;
static int g_iRoundTimeGainFromPage = 0;
static bool g_bRoundHasEscapeObjective = false;

static int g_iRoundEscapePointEntity = INVALID_ENT_REFERENCE;

static int g_iRoundIntroFadeColor[4] = { 255, ... };
static float g_flRoundIntroFadeHoldTime;
static float g_flRoundIntroFadeDuration;
static Handle g_hRoundIntroTimer = INVALID_HANDLE;
static bool g_bRoundIntroTextDefault = true;
static Handle g_hRoundIntroTextTimer = INVALID_HANDLE;
static int g_iRoundIntroText;
static char g_strRoundIntroMusic[PLATFORM_MAX_PATH] = "";

static int g_iRoundWarmupRoundCount = 0;

static bool g_bRoundWaitingForPlayers = false;

// Special round variables.
bool g_bSpecialRound = false;
int g_iSpecialRoundType = 0;
int g_iSpecialRoundType2 = 0;

bool g_bSpecialRoundint = false;
bool g_bSpecialRoundContinuous = false;
int g_iSpecialRoundCount = 1;
bool g_bPlayerPlayedSpecialRound[MAXPLAYERS + 1] = { true, ... };

// int boss round variables.
static bool g_bNewBossRound = false;
static bool g_bNewBossRoundNew = false;
static bool g_bNewBossRoundContinuous = false;
static int g_iNewBossRoundCount = 1;

static bool g_bPlayerPlayedNewBossRound[MAXPLAYERS + 1] = { true, ... };
static char g_strintBossRoundProfile[64] = "";

static Handle g_hRoundMessagesTimer = INVALID_HANDLE;
static int g_iRoundMessagesNum = 0;

static Handle g_hBossCountUpdateTimer = INVALID_HANDLE;
static Handle g_hClientAverageUpdateTimer = INVALID_HANDLE;

// Server variables.
Handle g_cvVersion;
Handle g_cvEnabled;
Handle g_cvSlenderMapsOnly;
Handle g_cvPlayerViewbobEnabled;
Handle g_cvPlayerShakeEnabled;
Handle g_cvPlayerShakeFrequencyMax;
Handle g_cvPlayerShakeAmplitudeMax;
Handle g_cvGraceTime;
Handle g_cvAllChat;
Handle g_cv20Dollars;
Handle g_cvMaxPlayers;
Handle g_cvMaxPlayersOverride;
Handle g_cvCampingEnabled;
Handle g_cvCampingMaxStrikes;
Handle g_cvCampingStrikesWarn;
Handle g_cvExitCampingStrikes;
Handle g_cvCampingMinDistance;
Handle g_cvCampingNoStrikeSanity;
Handle g_cvCampingNoStrikeBossDistance;
Handle g_cvDifficulty;
Handle g_cvBossMain;
Handle g_cvBossProfileOverride;
Handle g_cvPlayerBlinkRate;
Handle g_cvPlayerBlinkHoldTime;
Handle g_cvSpecialRoundBehavior;
Handle g_cvSpecialRoundForce;
Handle g_cvSpecialRoundOverride;
Handle g_cvSpecialRoundInterval;
Handle g_cvNewBossRoundBehavior;
Handle g_cvNewBossRoundInterval;
Handle g_cvNewBossRoundForce;
Handle g_cvPlayerVoiceDistance;
Handle g_cvPlayerVoiceWallScale;
Handle g_cvUltravisionEnabled;
Handle g_cvUltravisionRadiusRed;
Handle g_cvUltravisionRadiusBlue;
Handle g_cvUltravisionBrightness;
Handle g_cvNightvisionRadius;
Handle g_cvNightvisionEnabled;
Handle g_cvGhostModeConnection;
Handle g_cvGhostModeConnectionCheck;
Handle g_cvGhostModeConnectionTolerance;
Handle g_cvIntroEnabled;
Handle g_cvIntroDefaultHoldTime;
Handle g_cvIntroDefaultFadeTime;
Handle g_cvTimeLimit;
Handle g_cvTimeLimitEscape;
Handle g_cvTimeGainFromPageGrab;
Handle g_cvWarmupRound;
Handle g_cvWarmupRoundNum;
Handle g_cvPlayerViewbobHurtEnabled;
Handle g_cvPlayerViewbobSprintEnabled;
Handle g_cvPlayerFakeLagCompensation;
Handle g_cvPlayerProxyWaitTime;
Handle g_cvPlayerProxyAsk;
Handle g_cvHalfZatoichiHealthGain;
Handle g_cvBlockSuicideDuringRound;
Handle g_cvRaidMap;
Handle g_cvSurvivalMap;
Handle g_cvTimeEscapeSurvival;

Handle g_cvPlayerInfiniteSprintOverride;
Handle g_cvPlayerInfiniteFlashlightOverride;
Handle g_cvPlayerInfiniteBlinkOverride;

Handle g_cvGravity;
float g_flGravity;

Handle g_cvMaxRounds;

bool g_b20Dollars;

bool g_bPlayerShakeEnabled;
bool g_bPlayerViewbobEnabled;
bool g_bPlayerViewbobHurtEnabled;
bool g_bPlayerViewbobSprintEnabled;

Handle g_hHudSync;
Handle g_hHudSync2;
Handle g_hRoundTimerSync;

Handle g_hCookie;

// Global forwards.
Handle fOnBossAdded;
Handle fOnBossSpawn;
Handle fOnBossChangeState;
Handle fOnBossRemoved;
Handle fOnPagesSpawned;
Handle fOnClientCollectPage;
Handle fOnClientBlink;
Handle fOnClientCaughtByBoss;
Handle fOnClientGiveQueuePoints;
Handle fOnClientActivateFlashlight;
Handle fOnClientDeactivateFlashlight;
Handle fOnClientBreakFlashlight;
Handle fOnClientEscape;
Handle fOnClientLooksAtBoss;
Handle fOnClientLooksAwayFromBoss;
Handle fOnClientStartDeathCam;
Handle fOnClientEndDeathCam;
Handle fOnClientGetDefaultWalkSpeed;
Handle fOnClientGetDefaultSprintSpeed;
Handle fOnClientTakeDamage;
Handle fOnClientSpawnedAsProxy;
Handle fOnClientDamagedByBoss;
Handle fOnGroupGiveQueuePoints;

Handle g_hSDKWeaponScattergun;
Handle g_hSDKWeaponPistolScout;
Handle g_hSDKWeaponBat;
Handle g_hSDKWeaponSniperRifle;
Handle g_hSDKWeaponSMG;
Handle g_hSDKWeaponKukri;
Handle g_hSDKWeaponRocketLauncher;
Handle g_hSDKWeaponShotgunSoldier;
Handle g_hSDKWeaponShovel;
Handle g_hSDKWeaponGrenadeLauncher;
Handle g_hSDKWeaponStickyLauncher;
Handle g_hSDKWeaponBottle;
Handle g_hSDKWeaponMinigun;
Handle g_hSDKWeaponShotgunHeavy;
Handle g_hSDKWeaponFists;
Handle g_hSDKWeaponSyringeGun;
Handle g_hSDKWeaponMedigun;
Handle g_hSDKWeaponBonesaw;
Handle g_hSDKWeaponFlamethrower;
Handle g_hSDKWeaponShotgunPyro;
Handle g_hSDKWeaponFireaxe;
Handle g_hSDKWeaponRevolver;
Handle g_hSDKWeaponKnife;
Handle g_hSDKWeaponInvis;
Handle g_hSDKWeaponShotgunPrimary;
Handle g_hSDKWeaponPistol;
Handle g_hSDKWeaponWrench;

Handle g_hSDKGetMaxHealth;
Handle g_hSDKWantsLagCompensationOnEntity;
Handle g_hSDKShouldTransmit;
Handle g_hSDKEquipWearable;
Handle g_hSDKPlaySpecificSequence;

#if defined DEBUG
#include "sf2/debug.sp"
#endif
#include "sf2/stocks.sp"
#include "sf2/logging.sp"
#include "sf2/profiles.sp"
#include "sf2/nav.sp"
#include "sf2/effects.sp"
#include "sf2/playergroups.sp"
#include "sf2/menus.sp"
#include "sf2/npc.sp"
#include "sf2/pvp.sp"
#include "sf2/client.sp"
#include "sf2/specialround.sp"
#include "sf2/adminmenu.sp"


#define SF2_PROJECTED_FLASHLIGHT_CONFIRM_SOUND "ui/item_acquired.wav"


//	==========================================================
//	GENERAL PLUGIN HOOK FUNCTIONS
//	==========================================================

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error,int err_max)
{
	RegPluginLibrary("sf2");
	
	fOnBossAdded = CreateGlobalForward("SF2_OnBossAdded", ET_Ignore, Param_Cell);
	fOnBossSpawn = CreateGlobalForward("SF2_OnBossSpawn", ET_Ignore, Param_Cell);
	fOnBossChangeState = CreateGlobalForward("SF2_OnBossChangeState", ET_Ignore, Param_Cell, Param_Cell, Param_Cell);
	fOnBossRemoved = CreateGlobalForward("SF2_OnBossRemoved", ET_Ignore, Param_Cell);
	fOnPagesSpawned = CreateGlobalForward("SF2_OnPagesSpawned", ET_Ignore);
	fOnClientCollectPage = CreateGlobalForward("SF2_OnClientCollectPage", ET_Ignore, Param_Cell, Param_Cell);
	fOnClientBlink = CreateGlobalForward("SF2_OnClientBlink", ET_Ignore, Param_Cell);
	fOnClientCaughtByBoss = CreateGlobalForward("SF2_OnClientCaughtByBoss", ET_Ignore, Param_Cell, Param_Cell);
	fOnClientGiveQueuePoints = CreateGlobalForward("SF2_OnClientGiveQueuePoints", ET_Hook, Param_Cell, Param_CellByRef);
	fOnClientActivateFlashlight = CreateGlobalForward("SF2_OnClientActivateFlashlight", ET_Ignore, Param_Cell);
	fOnClientDeactivateFlashlight = CreateGlobalForward("SF2_OnClientDeactivateFlashlight", ET_Ignore, Param_Cell);
	fOnClientBreakFlashlight = CreateGlobalForward("SF2_OnClientBreakFlashlight", ET_Ignore, Param_Cell);
	fOnClientEscape = CreateGlobalForward("SF2_OnClientEscape", ET_Ignore, Param_Cell);
	fOnClientLooksAtBoss = CreateGlobalForward("SF2_OnClientLooksAtBoss", ET_Ignore, Param_Cell, Param_Cell);
	fOnClientLooksAwayFromBoss = CreateGlobalForward("SF2_OnClientLooksAwayFromBoss", ET_Ignore, Param_Cell, Param_Cell);
	fOnClientStartDeathCam = CreateGlobalForward("SF2_OnClientStartDeathCam", ET_Ignore, Param_Cell, Param_Cell);
	fOnClientEndDeathCam = CreateGlobalForward("SF2_OnClientEndDeathCam", ET_Ignore, Param_Cell, Param_Cell);
	fOnClientGetDefaultWalkSpeed = CreateGlobalForward("SF2_OnClientGetDefaultWalkSpeed", ET_Hook, Param_Cell, Param_CellByRef);
	fOnClientGetDefaultSprintSpeed = CreateGlobalForward("SF2_OnClientGetDefaultSprintSpeed", ET_Hook, Param_Cell, Param_CellByRef);
	fOnClientTakeDamage = CreateGlobalForward("SF2_OnClientTakeDamage", ET_Hook, Param_Cell, Param_Cell, Param_FloatByRef);
	fOnClientSpawnedAsProxy = CreateGlobalForward("SF2_OnClientSpawnedAsProxy", ET_Ignore, Param_Cell);
	fOnClientDamagedByBoss = CreateGlobalForward("SF2_OnClientDamagedByBoss", ET_Ignore, Param_Cell, Param_Cell, Param_Cell, Param_Float, Param_Cell);
	fOnGroupGiveQueuePoints = CreateGlobalForward("SF2_OnGroupGiveQueuePoints", ET_Hook, Param_Cell, Param_CellByRef);
	
	CreateNative("SF2_IsRunning", Native_IsRunning);
	CreateNative("SF2_GetRoundState", Native_GetRoundState);
	CreateNative("SF2_GetCurrentDifficulty", Native_GetCurrentDifficulty);
	CreateNative("SF2_GetDifficultyModifier", Native_GetDifficultyModifier);
	CreateNative("SF2_IsClientEliminated", Native_IsClientEliminated);
	CreateNative("SF2_IsClientInGhostMode", Native_IsClientInGhostMode);
	CreateNative("SF2_IsClientProxy", Native_IsClientProxy);
	CreateNative("SF2_GetClientBlinkCount", Native_GetClientBlinkCount);
	CreateNative("SF2_GetClientProxyMaster", Native_GetClientProxyMaster);
	CreateNative("SF2_GetClientProxyControlAmount", Native_GetClientProxyControlAmount);
	CreateNative("SF2_GetClientProxyControlRate", Native_GetClientProxyControlRate);
	CreateNative("SF2_SetClientProxyMaster", Native_SetClientProxyMaster);
	CreateNative("SF2_SetClientProxyControlAmount", Native_SetClientProxyControlAmount);
	CreateNative("SF2_SetClientProxyControlRate", Native_SetClientProxyControlRate);
	CreateNative("SF2_IsClientLookingAtBoss", Native_IsClientLookingAtBoss);
	CreateNative("SF2_CollectAsPage", Native_CollectAsPage);
	CreateNative("SF2_GetMaxBossCount", Native_GetMaxBosses);
	CreateNative("SF2_EntIndexToBossIndex", Native_EntIndexToBossIndex);
	CreateNative("SF2_BossIndexToEntIndex", Native_BossIndexToEntIndex);
	CreateNative("SF2_BossIDToBossIndex", Native_BossIDToBossIndex);
	CreateNative("SF2_BossIndexToBossID", Native_BossIndexToBossID);
	CreateNative("SF2_GetBossName", Native_GetBossName);
	CreateNative("SF2_GetBossModelEntity", Native_GetBossModelEntity);
	CreateNative("SF2_GetBossTarget", Native_GetBossTarget);
	CreateNative("SF2_GetBossMaster", Native_GetBossMaster);
	CreateNative("SF2_GetBossState", Native_GetBossState);
	CreateNative("SF2_IsBossProfileValid", Native_IsBossProfileValid);
	CreateNative("SF2_GetBossProfileNum", Native_GetBossProfileNum);
	CreateNative("SF2_GetBossProfileFloat", Native_GetBossProfileFloat);
	CreateNative("SF2_GetBossProfileString", Native_GetBossProfileString);
	CreateNative("SF2_GetBossProfileVector", Native_GetBossProfileVector);
	CreateNative("SF2_GetRandomStringFromBossProfile", Native_GetRandomStringFromBossProfile);
	
	PvP_InitializeAPI();
	
	SpecialRoundInitializeAPI();
	
	#if defined _steamtools_included
	MarkNativeAsOptional("Steam_SetGameDescription");
	#endif
	#if defined _SteamWorks_Included
	MarkNativeAsOptional("SteamWorks_SetGameDescription");
	#endif
	
	return APLRes_Success;
}

public void OnPluginStart()
{
	LoadTranslations("core.phrases");
	LoadTranslations("common.phrases");
	LoadTranslations("sf2.phrases");
	
	// Get offsets.
	g_offsPlayerFOV = FindSendPropInfo("CBasePlayer", "m_iFOV");
	if (g_offsPlayerFOV == -1) SetFailState("Couldn't find CBasePlayer offset for m_iFOV.");
	
	g_offsPlayerDefaultFOV = FindSendPropInfo("CBasePlayer", "m_iDefaultFOV");
	if (g_offsPlayerDefaultFOV == -1) SetFailState("Couldn't find CBasePlayer offset for m_iDefaultFOV.");
	
	g_offsPlayerFogCtrl = FindSendPropInfo("CBasePlayer", "m_PlayerFog.m_hCtrl");
	if (g_offsPlayerFogCtrl == -1) LogError("Couldn't find CBasePlayer offset for m_PlayerFog.m_hCtrl!");
	
	g_offsPlayerPunchAngle = FindSendPropInfo("CBasePlayer", "m_vecPunchAngle");
	if (g_offsPlayerPunchAngle == -1) LogError("Couldn't find CBasePlayer offset for m_vecPunchAngle!");
	
	g_offsPlayerPunchAngleVel = FindSendPropInfo("CBasePlayer", "m_vecPunchAngleVel");
	if (g_offsPlayerPunchAngleVel == -1) LogError("Couldn't find CBasePlayer offset for m_vecPunchAngleVel!");
	
	g_offsFogCtrlEnable = FindSendPropInfo("CFogController", "m_fog.enable");
	if (g_offsFogCtrlEnable == -1) LogError("Couldn't find CFogController offset for m_fog.enable!");
	
	g_offsFogCtrlEnd = FindSendPropInfo("CFogController", "m_fog.end");
	if (g_offsFogCtrlEnd == -1) LogError("Couldn't find CFogController offset for m_fog.end!");
	
	g_offsCollisionGroup = FindSendPropOffs("CBaseEntity", "m_CollisionGroup");
	if (g_offsCollisionGroup == -1)  LogError("Couldn't find CBaseEntity offset for m_CollisionGroup!");
	
	g_hPageMusicRanges = CreateArray(3);
	
	// Register console variables.
	g_cvVersion = CreateConVar("sf2_version", PLUGIN_VERSION, "The current version of Slender Fortress. DO NOT TOUCH!", FCVAR_SPONLY | FCVAR_NOTIFY | FCVAR_DONTRECORD);
	SetConVarString(g_cvVersion, PLUGIN_VERSION);
	
	g_cvEnabled = CreateConVar("sf2_enabled", "1", "Enable/Disable the Slender Fortress gamemode. This will take effect on map change.", FCVAR_NOTIFY | FCVAR_DONTRECORD);
	g_cvSlenderMapsOnly = CreateConVar("sf2_slendermapsonly", "1", "Only enable the Slender Fortress gamemode on map names prefixed with \"slender_\" or \"sf2_\".");
	
	g_cvGraceTime = CreateConVar("sf2_gracetime", "30.0");
	g_cvIntroEnabled = CreateConVar("sf2_intro_enabled", "1");
	g_cvIntroDefaultHoldTime = CreateConVar("sf2_intro_default_hold_time", "9.0");
	g_cvIntroDefaultFadeTime = CreateConVar("sf2_intro_default_fade_time", "1.0");
	
	g_cvBlockSuicideDuringRound = CreateConVar("sf2_block_suicide_during_round", "0");
	
	g_cvAllChat = CreateConVar("sf2_alltalk", "0");
	HookConVarChange(g_cvAllChat, OnConVarChanged);
	
	g_cvPlayerVoiceDistance = CreateConVar("sf2_player_voice_distance", "800.0", "The maximum distance RED can communicate in voice chat. Set to 0 if you want them to be heard at all times.", _, true, 0.0);
	g_cvPlayerVoiceWallScale = CreateConVar("sf2_player_voice_scale_blocked", "0.5", "The distance required to hear RED in voice chat will be multiplied by this amount if something is blocking them.");
	
	g_cvPlayerViewbobEnabled = CreateConVar("sf2_player_viewbob_enabled", "1", "Enable/Disable player viewbobbing.", _, true, 0.0, true, 1.0);
	HookConVarChange(g_cvPlayerViewbobEnabled, OnConVarChanged);
	g_cvPlayerViewbobHurtEnabled = CreateConVar("sf2_player_viewbob_hurt_enabled", "0", "Enable/Disable player view tilting when hurt.", _, true, 0.0, true, 1.0);
	HookConVarChange(g_cvPlayerViewbobHurtEnabled, OnConVarChanged);
	g_cvPlayerViewbobSprintEnabled = CreateConVar("sf2_player_viewbob_sprint_enabled", "0", "Enable/Disable player step viewbobbing when sprinting.", _, true, 0.0, true, 1.0);
	HookConVarChange(g_cvPlayerViewbobSprintEnabled, OnConVarChanged);
	g_cvGravity = FindConVar("sv_gravity");
	HookConVarChange(g_cvGravity, OnConVarChanged);
	
	g_cvPlayerFakeLagCompensation = CreateConVar("sf2_player_fakelagcompensation", "0", "(EXPERIMENTAL) Enable/Disable fake lag compensation for some hitscan weapons such as the Sniper Rifle.", _, true, 0.0, true, 1.0);
	
	g_cvPlayerShakeEnabled = CreateConVar("sf2_player_shake_enabled", "1", "Enable/Disable player view shake during boss encounters.", _, true, 0.0, true, 1.0);
	HookConVarChange(g_cvPlayerShakeEnabled, OnConVarChanged);
	g_cvPlayerShakeFrequencyMax = CreateConVar("sf2_player_shake_frequency_max", "255", "Maximum frequency value of the shake. Should be a value between 1-255.", _, true, 1.0, true, 255.0);
	g_cvPlayerShakeAmplitudeMax = CreateConVar("sf2_player_shake_amplitude_max", "5", "Maximum amplitude value of the shake. Should be a value between 1-16.", _, true, 1.0, true, 16.0);
	
	g_cvPlayerBlinkRate = CreateConVar("sf2_player_blink_rate", "0.33", "How long (in seconds) each bar on the player's Blink meter lasts.", _, true, 0.0);
	g_cvPlayerBlinkHoldTime = CreateConVar("sf2_player_blink_holdtime", "0.15", "How long (in seconds) a player will stay in Blink mode when he or she blinks.", _, true, 0.0);
	
	g_cvUltravisionEnabled = CreateConVar("sf2_player_ultravision_enabled", "1", "Enable/Disable player Ultravision. This helps players see in the dark when their Flashlight is off or unavailable.", _, true, 0.0, true, 1.0);
	g_cvUltravisionRadiusRed = CreateConVar("sf2_player_ultravision_radius_red", "512.0");
	g_cvUltravisionRadiusBlue = CreateConVar("sf2_player_ultravision_radius_blue", "800.0");
	g_cvNightvisionRadius = CreateConVar("sf2_player_nightvision_radius", "400.0");
	g_cvUltravisionBrightness = CreateConVar("sf2_player_ultravision_brightness", "-4");
	g_cvNightvisionEnabled = CreateConVar("sf2_player_flashlight_isnightvision", "0", "Enable/Disable flashlight replacement with nightvision",_, true, 0.0, true, 1.0);
	
	g_cvGhostModeConnection = CreateConVar("sf2_ghostmode_no_tolerance", "0", "If set on 1, it will instant kick out the client of the Ghost mode if the client has timed out.");
	g_cvGhostModeConnectionCheck = CreateConVar("sf2_ghostmode_check_connection", "1", "Checks a player's connection while in Ghost Mode. If the check fails, the client is booted out of Ghost Mode and the action and client's SteamID is logged in the main SF2 log.");
	g_cvGhostModeConnectionTolerance = CreateConVar("sf2_ghostmode_connection_tolerance", "5.0", "If sf2_ghostmode_check_connection is set to 1 and the client has timed out for at least this amount of time, the client will be booted out of Ghost Mode.");
	
	g_cv20Dollars = CreateConVar("sf2_20dollarmode", "0", "Enable/Disable $20 mode.", _, true, 0.0, true, 1.0);
	HookConVarChange(g_cv20Dollars, OnConVarChanged);
	
	g_cvMaxPlayers = CreateConVar("sf2_maxplayers", "5", "The maximum amount of players that can be in one round.", _, true, 1.0);
	HookConVarChange(g_cvMaxPlayers, OnConVarChanged);
	
	g_cvMaxPlayersOverride = CreateConVar("sf2_maxplayers_override", "-1", "Overrides the maximum amount of players that can be in one round.", _, true, -1.0);
	HookConVarChange(g_cvMaxPlayersOverride, OnConVarChanged);
	
	g_cvCampingEnabled = CreateConVar("sf2_anticamping_enabled", "1", "Enable/Disable anti-camping system for RED.", _, true, 0.0, true, 1.0);
	g_cvCampingMaxStrikes = CreateConVar("sf2_anticamping_maxstrikes", "4", "How many 5-second intervals players are allowed to stay in one spot before he/she is forced to suicide.", _, true, 0.0);
	g_cvCampingStrikesWarn = CreateConVar("sf2_anticamping_strikeswarn", "2", "The amount of strikes left where the player will be warned of camping.");
	g_cvExitCampingStrikes = CreateConVar("sf2_exit_anticamping_strikes", "3", "The amount of strikes left where the player will be set as exit camper.");
	g_cvCampingMinDistance = CreateConVar("sf2_anticamping_mindistance", "128.0", "Every 5 seconds the player has to be at least this far away from his last position 5 seconds ago or else he'll get a strike.");
	g_cvCampingNoStrikeSanity = CreateConVar("sf2_anticamping_no_strike_sanity", "0.1", "The camping system will NOT give any strikes under any circumstances if the players's Sanity is missing at least this much of his maximum Sanity (max is 1.0).");
	g_cvCampingNoStrikeBossDistance = CreateConVar("sf2_anticamping_no_strike_boss_distance", "512.0", "The camping system will NOT give any strikes under any circumstances if the player is this close to a boss (ignoring LOS).");
	g_cvBossMain = CreateConVar("sf2_boss_main", "slenderman", "The name of the main boss (its profile name, not its display name)");
	g_cvBossProfileOverride = CreateConVar("sf2_boss_profile_override", "", "Overrides which boss will be chosen next. Only applies to the first boss being chosen.");
	g_cvDifficulty = CreateConVar("sf2_difficulty", "1", "Difficulty of the game. 1 = Normal, 2 = Hard, 3 = Insane.", _, true, 1.0, true, 3.0);
	HookConVarChange(g_cvDifficulty, OnConVarChanged);
	
	g_cvSpecialRoundBehavior = CreateConVar("sf2_specialround_mode", "0", "0 = Special Round resets on next round, 1 = Special Round keeps going until all players have played (not counting spectators, recently joined players, and those who reset their queue points during the round)", _, true, 0.0, true, 1.0);
	g_cvSpecialRoundForce = CreateConVar("sf2_specialround_forceenable", "-1", "Sets whether a Special Round will occur on the next round or not.", _, true, -1.0, true, 1.0);
	g_cvSpecialRoundOverride = CreateConVar("sf2_specialround_forcetype", "-1", "Sets the type of Special Round that will be chosen on the next Special Round. Set to -1 to let the game choose.", _, true, -1.0);
	g_cvSpecialRoundInterval = CreateConVar("sf2_specialround_interval", "5", "If this many rounds are completed, the next round will be a Special Round.", _, true, 0.0);
	
	g_cvNewBossRoundBehavior = CreateConVar("sf2_newbossround_mode", "0", "0 = boss selection will return to normal after the boss round, 1 = the int boss will continue being the boss until all players in the server have played against it (not counting spectators, recently joined players, and those who reset their queue points during the round).", _, true, 0.0, true, 1.0);
	g_cvNewBossRoundInterval = CreateConVar("sf2_newbossround_interval", "3", "If this many rounds are completed, the next round's boss will be randomly chosen, but will not be the main boss.", _, true, 0.0);
	g_cvNewBossRoundForce = CreateConVar("sf2_newbossround_forceenable", "-1", "Sets whether a int boss will be chosen on the next round or not. Set to -1 to let the game choose.", _, true, -1.0, true, 1.0);
	
	g_cvTimeLimit = CreateConVar("sf2_timelimit_default", "300", "The time limit of the round. Maps can change the time limit.", _, true, 0.0);
	g_cvTimeLimitEscape = CreateConVar("sf2_timelimit_escape_default", "90", "The time limit to escape. Maps can change the time limit.", _, true, 0.0);
	g_cvTimeGainFromPageGrab = CreateConVar("sf2_time_gain_page_grab", "12", "The time gained from grabbing a page. Maps can change the time gain amount.");
	
	g_cvWarmupRound = CreateConVar("sf2_warmupround", "1", "Enables/disables Warmup Rounds after the \"Waiting for Players\" phase.", _, true, 0.0, true, 1.0);
	g_cvWarmupRoundNum = CreateConVar("sf2_warmupround_num", "1", "Sets the amount of Warmup Rounds that occur after the \"Waiting for Players\" phase.", _, true, 0.0);
	
	g_cvPlayerProxyWaitTime = CreateConVar("sf2_player_proxy_waittime", "35", "How long (in seconds) after a player was chosen to be a Proxy must the system wait before choosing him again.");
	g_cvPlayerProxyAsk = CreateConVar("sf2_player_proxy_ask", "0", "Set to 1 if the player can choose before becoming a Proxy, set to 0 to force.");
	
	g_cvHalfZatoichiHealthGain = CreateConVar("sf2_halfzatoichi_healthgain", "20", "How much health should be gained from killing a player with the Half-Zatoichi? Set to -1 for default behavior.");
	
	g_cvPlayerInfiniteSprintOverride = CreateConVar("sf2_player_infinite_sprint_override", "-1", "1 = infinite sprint, 0 = never have infinite sprint, -1 = let the game choose.", _, true, -1.0, true, 1.0);
	g_cvPlayerInfiniteFlashlightOverride = CreateConVar("sf2_player_infinite_flashlight_override", "-1", "1 = infinite flashlight, 0 = never have infinite flashlight, -1 = let the game choose.", _, true, -1.0, true, 1.0);
	g_cvPlayerInfiniteBlinkOverride = CreateConVar("sf2_player_infinite_blink_override", "-1", "1 = infinite blink, 0 = never have infinite blink, -1 = let the game choose.", _, true, -1.0, true, 1.0);
	
	g_cvRaidMap = CreateConVar("sf2_israidmap", "0", "Set to 1 if the map is a raid map.", _, true, 0.0, true, 1.0);
	
	g_cvSurvivalMap = CreateConVar("sf2_issurvivalmap", "0", "Set to 1 if the map is a survival map.", _, true, 0.0, true, 1.0);
	g_cvTimeEscapeSurvival = CreateConVar("sf2_survival_time_limit", "30", "when X secs left the mod will turn back the Survive! text to Escape! text", _, true, 0.0);
	
	g_cvMaxRounds = FindConVar("mp_maxrounds");
	
	g_hHudSync = CreateHudSynchronizer();
	g_hHudSync2 = CreateHudSynchronizer();
	g_hRoundTimerSync = CreateHudSynchronizer();
	g_hCookie = RegClientCookie("slender_cookie", "", CookieAccess_Private);
	
	// Register console commands.
	RegConsoleCmd("sm_sf2", Command_MainMenu);
	RegConsoleCmd("sm_sl", Command_MainMenu);
	RegConsoleCmd("sm_slender", Command_MainMenu);
	RegConsoleCmd("sm_slupdate", Command_Update);
	RegConsoleCmd("sm_slpack", Command_Pack);
	RegConsoleCmd("sm_sf2pack", Command_Pack);
	RegConsoleCmd("sm_slnext", Command_Next);
	RegConsoleCmd("sm_slgroup", Command_Group);
	RegConsoleCmd("sm_slgroupname", Command_GroupName);
	RegConsoleCmd("sm_slghost", Command_GhostMode);
	RegConsoleCmd("sm_slhelp", Command_Help);
	RegConsoleCmd("sm_slsettings", Command_Settings);
	RegConsoleCmd("sm_slcredits", Command_Credits);
	RegConsoleCmd("sm_flashlight", Command_ToggleFlashlight);
	RegConsoleCmd("+sprint", Command_SprintOn);
	RegConsoleCmd("-sprint", Command_SprintOff);
	
	
	RegAdminCmd("sm_sf2_bosspack_vote", DevCommand_BossPackVote, ADMFLAG_CHEATS);
	RegAdminCmd("sm_sf2_nopoints", Command_NoPoints, ADMFLAG_CHEATS);
	RegAdminCmd("sm_sf2_scare", Command_ClientPerformScare, ADMFLAG_SLAY);
	RegAdminCmd("sm_sf2_spawn_boss", Command_SpawnSlender, ADMFLAG_SLAY);
	RegAdminCmd("sm_sf2_add_boss", Command_AddSlender, ADMFLAG_SLAY);
	RegAdminCmd("sm_sf2_add_boss_fake", Command_AddSlenderFake, ADMFLAG_SLAY);
	RegAdminCmd("sm_sf2_remove_boss", Command_RemoveSlender, ADMFLAG_SLAY);
	RegAdminCmd("sm_sf2_getbossindexes", Command_GetBossIndexes, ADMFLAG_SLAY);
	RegAdminCmd("sm_sf2_setplaystate", Command_ForceState, ADMFLAG_SLAY);
	RegAdminCmd("sm_sf2_boss_attack_waiters", Command_SlenderAttackWaiters, ADMFLAG_SLAY);
	RegAdminCmd("sm_sf2_boss_no_teleport", Command_SlenderNoTeleport, ADMFLAG_SLAY);
	RegAdminCmd("sm_sf2_force_proxy", Command_ForceProxy, ADMFLAG_SLAY);
	//RegAdminCmd("sm_slnightfision", Command_NightVision, ADMFLAG_SLAY);
	RegAdminCmd("sm_sf2_force_escape", Command_ForceEscape, ADMFLAG_CHEATS);
	
	// Hook onto existing console commands.
	AddCommandListener(Hook_CommandBuild, "build");
	AddCommandListener(Hook_CommandSuicideAttempt, "kill");
	AddCommandListener(Hook_CommandSuicideAttempt, "explode");
	AddCommandListener(Hook_CommandSuicideAttempt, "joinclass");
	AddCommandListener(Hook_CommandSuicideAttempt, "join_class");
	AddCommandListener(Hook_CommandSuicideAttempt, "jointeam");
	AddCommandListener(Hook_CommandSuicideAttempt, "autoteam");
	AddCommandListener(Hook_CommandSuicideAttempt, "spectate");
	AddCommandListener(Hook_CommandVoiceMenu, "voicemenu");
	AddCommandListener(Hook_CommandSay, "say");
	AddCommandListener(Hook_CommandSayTeam, "say_team");
	AddCommandListener(Hook_CommandBuild, "build");
	// Hook events.
	HookEvent("teamplay_round_start", Event_RoundStart);
	HookEvent("teamplay_round_win", Event_RoundEnd);
	HookEvent("teamplay_win_panel", Event_WinPanel, EventHookMode_Pre);
	HookEvent("player_team", Event_DontBroadcastToClients, EventHookMode_Pre);
	HookEvent("player_team", Event_PlayerTeam);
	HookEvent("player_spawn", Event_PlayerSpawn);
	HookEvent("player_hurt", Event_PlayerHurt);
	HookEvent("npc_hurt", Event_HitBoxHurt);
	HookEvent("post_inventory_application", Event_PostInventoryApplication);
	HookEvent("item_found", Event_DontBroadcastToClients, EventHookMode_Pre);
	HookEvent("teamplay_teambalanced_player", Event_DontBroadcastToClients, EventHookMode_Pre);
	HookEvent("fish_notice", Event_PlayerDeathPre, EventHookMode_Pre);
	HookEvent("fish_notice__arm", Event_PlayerDeathPre, EventHookMode_Pre);
	HookEvent("player_death", Event_PlayerDeathPre, EventHookMode_Pre);
	HookEvent("player_death", Event_PlayerDeath);
	
	// Hook entities.
	HookEntityOutput("info_npc_spawn_destination", "OnUser1", NPCSpawn);
	HookEntityOutput("trigger_multiple", "OnStartTouch", Hook_TriggerOnStartTouch);
	HookEntityOutput("trigger_multiple", "OnEndTouch", Hook_TriggerOnEndTouch);
	
	// Hook usermessages.
	HookUserMessage(GetUserMessageId("VoiceSubtitle"), Hook_BlockUserMessage, true);
	//HookUserMessage(GetUserMessageId("TextMsg"), Hook_BlockUserMessage, true);
	
	// Hook sounds.
	AddNormalSoundHook(view_as<NormalSHook>(Hook_NormalSound));
	
	AddTempEntHook("Fire Bullets", Hook_TEFireBullets);
	
	steamtools = LibraryExists("SteamTools");
	
	steamworks = LibraryExists("SteamWorks");
	
	sendproxymanager = LibraryExists("sendproxy");
	
	InitializeBossProfiles();
	
	NPCInitialize();
	
	SetupMenus();
	
	SetupAdminMenu();
	
	SetupClassDefaultWeapons();
	
	SetupPlayerGroups();
	
	PvP_Initialize();
	
	// @TODO: When cvars are finalized, set this to true.
	AutoExecConfig(false);
#if defined DEBUG
	InitializeDebug();
#endif
}

public void OnAllPluginsLoaded()
{
	SetupHooks();
}

public void OnPluginEnd()
{
	StopPlugin();
}
public void OnLibraryAdded(const char[] name)
{
	
	if(!strcmp(name, "SteamTools", false))
	{
		steamtools = true;
	}
	
	if(!strcmp(name, "SteamWorks", false))
	{
		steamworks = true;
	}
	
	if(!strcmp(name, "sendproxy", false))
	{
		sendproxymanager = true;
	}
	
}
public void OnLibraryRemoved(const char[] name)
{
	
	if(!strcmp(name, "SteamTools", false))
	{
		steamtools = false;
	}
	
	if(!strcmp(name, "SteamWorks", false))
	{
		steamworks = false;
	}
	
	if(!strcmp(name, "sendproxy", false))
	{
		sendproxymanager = false;
	}
	
}
static void SetupHooks()
{
	// Check SDKHooks gamedata.
	Handle hConfig = LoadGameConfigFile("sdkhooks.games");
	if (hConfig == INVALID_HANDLE) SetFailState("Couldn't find SDKHooks gamedata!");
	
	StartPrepSDKCall(SDKCall_Entity);
	PrepSDKCall_SetFromConf(hConfig, SDKConf_Virtual, "GetMaxHealth");
	PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);
	if ((g_hSDKGetMaxHealth = EndPrepSDKCall()) == INVALID_HANDLE)
	{
		SetFailState("Failed to retrieve GetMaxHealth offset from SDKHooks gamedata!");
	}
	
	CloseHandle(hConfig);
	
	// Check our own gamedata.
	hConfig = LoadGameConfigFile("sf2");
	if (hConfig == INVALID_HANDLE) SetFailState("Could not find SF2 gamedata!");
	
	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf( hConfig, SDKConf_Virtual, "CTFPlayer::EquipWearable" );
	PrepSDKCall_AddParameter( SDKType_CBaseEntity, SDKPass_Pointer );
	g_hSDKEquipWearable = EndPrepSDKCall();
	if( g_hSDKEquipWearable == INVALID_HANDLE )//In case the signature is missing, look if the server has the tf2 randomizer's gamedata.
	{
		char strFilePath[PLATFORM_MAX_PATH];
		BuildPath( Path_SM, strFilePath, sizeof(strFilePath), "gamedata/tf2items.randomizer.txt" );
		if( FileExists( strFilePath ) )
		{
			Handle hGameConf = LoadGameConfigFile( "tf2items.randomizer" );
			if( hGameConf != INVALID_HANDLE )
			{
				StartPrepSDKCall(SDKCall_Player);
				PrepSDKCall_SetFromConf( hGameConf, SDKConf_Virtual, "CTFPlayer::EquipWearable" );
				PrepSDKCall_AddParameter( SDKType_CBaseEntity, SDKPass_Pointer );
				g_hSDKEquipWearable = EndPrepSDKCall();
				if( g_hSDKEquipWearable == INVALID_HANDLE )
				{
					// Old gamedata
					StartPrepSDKCall(SDKCall_Player);
					PrepSDKCall_SetFromConf( hGameConf, SDKConf_Virtual, "EquipWearable" );
					PrepSDKCall_AddParameter( SDKType_CBaseEntity, SDKPass_Pointer );
					g_hSDKEquipWearable = EndPrepSDKCall();
				}
			}
		}
	}
	if( g_hSDKEquipWearable == INVALID_HANDLE )
	{
		SetFailState("Failed to retrieve CTFPlayer::EquipWearable offset from SF2 gamedata!");
	}
	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(hConfig, SDKConf_Signature, "CTFPlayer::PlaySpecificSequence");
	PrepSDKCall_AddParameter(SDKType_String, SDKPass_Pointer);
	g_hSDKPlaySpecificSequence = EndPrepSDKCall();
	if(g_hSDKPlaySpecificSequence == INVALID_HANDLE)
	{
		SetFailState("Failed to retrieve CTFPlayer::PlaySpecificSequence signature from SF2 gamedata!");
	}
	
	int iOffset = GameConfGetOffset(hConfig, "CTFPlayer::WantsLagCompensationOnEntity"); 
	g_hSDKWantsLagCompensationOnEntity = DHookCreate(iOffset, HookType_Entity, ReturnType_Bool, ThisPointer_CBaseEntity, Hook_ClientWantsLagCompensationOnEntity); 
	if (g_hSDKWantsLagCompensationOnEntity == INVALID_HANDLE)
	{
		SetFailState("Failed to create hook CTFPlayer::WantsLagCompensationOnEntity offset from SF2 gamedata!");
	}
	
	DHookAddParam(g_hSDKWantsLagCompensationOnEntity, HookParamType_CBaseEntity);
	DHookAddParam(g_hSDKWantsLagCompensationOnEntity, HookParamType_ObjectPtr);
	DHookAddParam(g_hSDKWantsLagCompensationOnEntity, HookParamType_Unknown);
	
	iOffset = GameConfGetOffset(hConfig, "CBaseEntity::ShouldTransmit");
	g_hSDKShouldTransmit = DHookCreate(iOffset, HookType_Entity, ReturnType_Int, ThisPointer_CBaseEntity, Hook_EntityShouldTransmit);
	if (g_hSDKShouldTransmit == INVALID_HANDLE)
	{
		SetFailState("Failed to create hook CBaseEntity::ShouldTransmit offset from SF2 gamedata!");
	}
	
	DHookAddParam(g_hSDKShouldTransmit, HookParamType_ObjectPtr);
	
	CloseHandle(hConfig);
}

static void SetupClassDefaultWeapons()
{
	// Scout
	g_hSDKWeaponScattergun = PrepareItemHandle("tf_weapon_scattergun", 13, 0, 0, "");
	g_hSDKWeaponPistolScout = PrepareItemHandle("tf_weapon_pistol", 23, 0, 0, "");
	g_hSDKWeaponBat = PrepareItemHandle("tf_weapon_bat", 0, 0, 0, "");
	
	// Sniper
	g_hSDKWeaponSniperRifle = PrepareItemHandle("tf_weapon_sniperrifle", 14, 0, 0, "");
	g_hSDKWeaponSMG = PrepareItemHandle("tf_weapon_smg", 16, 0, 0, "");
	g_hSDKWeaponKukri = PrepareItemHandle("tf_weapon_club", 3, 0, 0, "");
	
	// Soldier
	g_hSDKWeaponRocketLauncher = PrepareItemHandle("tf_weapon_rocketlauncher", 18, 0, 0, "");
	g_hSDKWeaponShotgunSoldier = PrepareItemHandle("tf_weapon_shotgun", 10, 0, 0, "");
	g_hSDKWeaponShovel = PrepareItemHandle("tf_weapon_shovel", 6, 0, 0, "");
	
	// Demoman
	g_hSDKWeaponGrenadeLauncher = PrepareItemHandle("tf_weapon_grenadelauncher", 19, 0, 0, "");
	g_hSDKWeaponStickyLauncher = PrepareItemHandle("tf_weapon_pipebomblauncher", 20, 0, 0, "");
	g_hSDKWeaponBottle = PrepareItemHandle("tf_weapon_bottle", 1, 0, 0, "");
	
	// Heavy
	g_hSDKWeaponMinigun = PrepareItemHandle("tf_weapon_minigun", 15, 0, 0, "");
	g_hSDKWeaponShotgunHeavy = PrepareItemHandle("tf_weapon_shotgun", 11, 0, 0, "");
	g_hSDKWeaponFists = PrepareItemHandle("tf_weapon_fists", 5, 0, 0, "");
	
	// Medic
	g_hSDKWeaponSyringeGun = PrepareItemHandle("tf_weapon_syringegun_medic", 17, 0, 0, "");
	g_hSDKWeaponMedigun = PrepareItemHandle("tf_weapon_medigun", 29, 0, 0, "");
	g_hSDKWeaponBonesaw = PrepareItemHandle("tf_weapon_bonesaw", 8, 0, 0, "");
	
	// Pyro
	g_hSDKWeaponFlamethrower = PrepareItemHandle("tf_weapon_flamethrower", 21, 0, 0, "254 ; 4.0");
	g_hSDKWeaponShotgunPyro = PrepareItemHandle("tf_weapon_shotgun", 12, 0, 0, "");
	g_hSDKWeaponFireaxe = PrepareItemHandle("tf_weapon_fireaxe", 2, 0, 0, "");
	
	// Spy
	g_hSDKWeaponRevolver = PrepareItemHandle("tf_weapon_revolver", 24, 0, 0, "");
	g_hSDKWeaponKnife = PrepareItemHandle("tf_weapon_knife", 4, 0, 0, "");
	g_hSDKWeaponInvis = PrepareItemHandle("tf_weapon_invis", 297, 0, 0, "");
	
	// Engineer
	g_hSDKWeaponShotgunPrimary = PrepareItemHandle("tf_weapon_shotgun", 9, 0, 0, "");
	g_hSDKWeaponPistol = PrepareItemHandle("tf_weapon_pistol", 22, 0, 0, "");
	g_hSDKWeaponWrench = PrepareItemHandle("tf_weapon_wrench", 7, 0, 0, "");
}

public void OnMapStart()
{
	PvP_OnMapStart();
	FindHealthBar();
}

public void OnConfigsExecuted()
{
	if (!GetConVarBool(g_cvEnabled))
	{
		StopPlugin();
	}
	else
	{
		if (GetConVarBool(g_cvSlenderMapsOnly))
		{
			char sMap[256];
			GetCurrentMap(sMap, sizeof(sMap));
			
			if (!StrContains(sMap, "slender_", false) || !StrContains(sMap, "sf2_", false))
			{
				StartPlugin();
			}
			else
			{
				LogMessage("%s is not a Slender Fortress map. Plugin disabled!", sMap);
				StopPlugin();
			}
		}
		else
		{
			StartPlugin();
		}
	}
}

static void StartPlugin()
{
	if (g_bEnabled) return;
	
	g_bEnabled = true;
	
	InitializeLogging();
	
#if defined DEBUG
	InitializeDebugLogging();
#endif
	
	// Handle ConVars.
	Handle hCvar = FindConVar("mp_friendlyfire");
	if (hCvar != INVALID_HANDLE) SetConVarBool(hCvar, true);
	
	hCvar = FindConVar("mp_flashlight");
	if (hCvar != INVALID_HANDLE) SetConVarBool(hCvar, true);
	
	hCvar = FindConVar("mat_supportflashlight");
	if (hCvar != INVALID_HANDLE) SetConVarBool(hCvar, true);
	
	hCvar = FindConVar("mp_autoteambalance");
	if (hCvar != INVALID_HANDLE) SetConVarBool(hCvar, false);
	
	g_flGravity = GetConVarFloat(g_cvGravity);
	
	g_b20Dollars = GetConVarBool(g_cv20Dollars);
	
	g_bPlayerShakeEnabled = GetConVarBool(g_cvPlayerShakeEnabled);
	g_bPlayerViewbobEnabled = GetConVarBool(g_cvPlayerViewbobEnabled);
	g_bPlayerViewbobHurtEnabled = GetConVarBool(g_cvPlayerViewbobHurtEnabled);
	g_bPlayerViewbobSprintEnabled = GetConVarBool(g_cvPlayerViewbobSprintEnabled);
	
	char sBuffer[64];
	Format(sBuffer, sizeof(sBuffer), "Slender Fortress (%s)", PLUGIN_VERSION_DISPLAY);
	#if defined _SteamWorks_Included
	if(steamworks)
	{
		SteamWorks_SetGameDescription(sBuffer);
		steamtools=false;
	}
	#endif
	#if defined _steamtools_included
	if(steamtools)
	{
		Steam_SetGameDescription(sBuffer);
		steamworks=false;
	}
	#endif
	
	PrecacheStuff();
	
	// Reset special round.
	g_bSpecialRound = false;
	g_bSpecialRoundint = false;
	g_bSpecialRoundContinuous = false;
	g_iSpecialRoundCount = 1;
	g_iSpecialRoundType = 0;
	
	SpecialRoundReset();
	
	// Reset boss rounds.
	g_bNewBossRound = false;
	g_bNewBossRoundNew = false;
	g_bNewBossRoundContinuous = false;
	g_iNewBossRoundCount = 1;
	strcopy(g_strintBossRoundProfile, sizeof(g_strintBossRoundProfile), "");
	
	// Reset global round vars.
	g_iRoundCount = 0;
	g_iRoundEndCount = 0;
	g_iRoundActiveCount = 0;
	g_iRoundState = SF2RoundState_Invalid;
	g_hRoundMessagesTimer = CreateTimer(200.0, Timer_RoundMessages, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
	g_iRoundMessagesNum = 0;
	
	g_iRoundWarmupRoundCount = 0;
	
	g_hClientAverageUpdateTimer = CreateTimer(0.2, Timer_ClientAverageUpdate, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
	g_hBossCountUpdateTimer = CreateTimer(2.0, Timer_BossCountUpdate, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
	
	SetRoundState(SF2RoundState_Waiting);
	
	ReloadBossProfiles();
	ReloadRestrictedWeapons();
	ReloadSpecialRounds();
	
	NPCOnConfigsExecuted();
	
	InitializeBossPackVotes();
	SetupTimeLimitTimerForBossPackVote();
	
	// Late load compensation.
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i)) continue;
		OnClientPutInServer(i);
	}
}

static void PrecacheStuff()
{
	// Initialize particles.
	g_iParticle[CriticalHit] = PrecacheParticleSystem(CRIT_PARTICLENAME);
	g_iParticle[MiniCritHit] = PrecacheParticleSystem(MINICRIT_PARTICLENAME);
	g_iParticle[ZapParticle] = PrecacheParticleSystem(ZAP_PARTICLENAME);
	g_iParticle[FireworksRED] = PrecacheParticleSystem(FIREWORKSRED_PARTICLENAME);
	g_iParticle[FireworksBLU] = PrecacheParticleSystem(FIREWORKSBLU_PARTICLENAME);
	
	PrecacheSound2("ui/itemcrate_smash_ultrarare_short.wav");
	PrecacheSound2(MINICRIT_SOUND);
	PrecacheSound2(CRIT_SOUND);
	PrecacheSound2(ZAP_SOUND);
	
	// simple_bot;
	PrecacheModel("models/humans/group01/female_01.mdl", true); //<= Can someone tell me why this has to be precached?
	
	PrecacheModel(PAGE_MODEL, true);
	PrecacheModel(SF_KEYMODEL, true);
	PrecacheModel(GHOST_MODEL, true);
	
	PrecacheSound2(FLASHLIGHT_CLICKSOUND);
	PrecacheSound2(FLASHLIGHT_BREAKSOUND);
	PrecacheSound2(FLASHLIGHT_NOSOUND);
	PrecacheSound2(PAGE_GRABSOUND);
	
	PrecacheSound2(MUSIC_GOTPAGES1_SOUND);
	PrecacheSound2(MUSIC_GOTPAGES2_SOUND);
	PrecacheSound2(MUSIC_GOTPAGES3_SOUND);
	PrecacheSound2(MUSIC_GOTPAGES4_SOUND);
	
	PrecacheSound2(SF2_PROJECTED_FLASHLIGHT_CONFIRM_SOUND);
	
	for (int i = 0; i < sizeof(g_strPlayerBreathSounds); i++)
	{
		PrecacheSound2(g_strPlayerBreathSounds[i]);
	}
	
	// Special round.
	PrecacheSound2(SR_MUSIC);
	PrecacheSound2(SR_SOUND_SELECT);
	PrecacheSound2(SF2_INTRO_DEFAULT_MUSIC);
	
	PrecacheMaterial2(SF2_OVERLAY_DEFAULT);
	PrecacheMaterial2(SF2_OVERLAY_DEFAULT_NO_FILMGRAIN);
	PrecacheMaterial2(SF2_OVERLAY_GHOST);
	
	AddFileToDownloadsTable("models/slender/sheet.mdl");
	AddFileToDownloadsTable("models/slender/sheet.dx80.vtx");
	AddFileToDownloadsTable("models/slender/sheet.dx90.vtx");
	AddFileToDownloadsTable("models/slender/sheet.phy");
	AddFileToDownloadsTable("models/slender/sheet.sw.vtx");
	AddFileToDownloadsTable("models/slender/sheet.vvd");
	AddFileToDownloadsTable("models/slender/sheet.xbox.vtx");
	
	AddFileToDownloadsTable("models/demani_sf/key_australium.mdl");
	AddFileToDownloadsTable("models/demani_sf/key_australium.dx80.vtx");
	AddFileToDownloadsTable("models/demani_sf/key_australium.dx90.vtx");
	AddFileToDownloadsTable("models/demani_sf/key_australium.sw.vtx");
	AddFileToDownloadsTable("models/demani_sf/key_australium.vvd");
	
	AddFileToDownloadsTable("materials/models/demani_sf/key_australium.vmt");
	AddFileToDownloadsTable("materials/models/demani_sf/key_australium.vtf");
	AddFileToDownloadsTable("materials/models/demani_sf/key_australium_normal.vtf");
	
	AddFileToDownloadsTable("materials/models/Jason278/Slender/Sheets/Sheet_1.vtf");
	AddFileToDownloadsTable("materials/models/Jason278/Slender/Sheets/Sheet_1.vmt");
	AddFileToDownloadsTable("materials/models/Jason278/Slender/Sheets/Sheet_2.vtf");
	AddFileToDownloadsTable("materials/models/Jason278/Slender/Sheets/Sheet_2.vmt");
	AddFileToDownloadsTable("materials/models/Jason278/Slender/Sheets/Sheet_3.vtf");
	AddFileToDownloadsTable("materials/models/Jason278/Slender/Sheets/Sheet_3.vmt");
	AddFileToDownloadsTable("materials/models/Jason278/Slender/Sheets/Sheet_4.vtf");
	AddFileToDownloadsTable("materials/models/Jason278/Slender/Sheets/Sheet_4.vmt");
	AddFileToDownloadsTable("materials/models/Jason278/Slender/Sheets/Sheet_5.vtf");
	AddFileToDownloadsTable("materials/models/Jason278/Slender/Sheets/Sheet_5.vmt");
	AddFileToDownloadsTable("materials/models/Jason278/Slender/Sheets/Sheet_6.vtf");
	AddFileToDownloadsTable("materials/models/Jason278/Slender/Sheets/Sheet_6.vmt");
	AddFileToDownloadsTable("materials/models/Jason278/Slender/Sheets/Sheet_7.vtf");
	AddFileToDownloadsTable("materials/models/Jason278/Slender/Sheets/Sheet_7.vmt");
	AddFileToDownloadsTable("materials/models/Jason278/Slender/Sheets/Sheet_8.vtf");
	AddFileToDownloadsTable("materials/models/Jason278/Slender/Sheets/Sheet_8.vmt");
	
	// pvp
	PvP_Precache();
}

static void StopPlugin()
{
	if (!g_bEnabled) return;
	
	g_bEnabled = false;
	
	// Reset CVars.
	Handle hCvar = FindConVar("mp_friendlyfire");
	if (hCvar != INVALID_HANDLE) SetConVarBool(hCvar, false);
	
	hCvar = FindConVar("mp_flashlight");
	if (hCvar != INVALID_HANDLE) SetConVarBool(hCvar, false);
	
	hCvar = FindConVar("mat_supportflashlight");
	if (hCvar != INVALID_HANDLE) SetConVarBool(hCvar, false);
	
	// Cleanup bosses.
	NPCRemoveAll();
	
	// Cleanup clients.
	for (int i = 1; i <= MaxClients; i++)
	{
		ClientResetFlashlight(i);
		ClientDeactivateUltravision(i);
		ClientDisableConstantGlow(i);
		ClientRemoveInteractiveGlow(i);
	}
	
	BossProfilesOnMapEnd();
}

public void OnMapEnd()
{
	StopPlugin();
}

public void OnMapTimeLeftChanged()
{
	if (g_bEnabled)
	{
		SetupTimeLimitTimerForBossPackVote();
	}
}

public void TF2_OnConditionAdded(int iClient, TFCond cond)
{
	if (cond == TFCond_Taunting)
	{
		if (IsClientInGhostMode(iClient))
		{
			// Stop ghosties from taunting.
			TF2_RemoveCondition(iClient, TFCond_Taunting);
		}
	}
	if(cond==view_as<TFCond>(82))
	{
		if (g_bPlayerProxy[iClient])
		{
			//Stop proxies from using kart commands
			TF2_RemoveCondition(iClient, view_as<TFCond>(82));
		}
	}
}

public void OnGameFrame()
{
	if (!g_bEnabled) return;
	
	// Process through boss movement.
	for (int i = 0; i < MAX_BOSSES; i++)
	{
		if (NPCGetUniqueID(i) == -1) continue;
		
		int iBoss = NPCGetEntIndex(i);
		if (!iBoss || iBoss == INVALID_ENT_REFERENCE) continue;
		
		if (NPCGetFlags(i) & SFF_MARKEDASFAKE) continue;
		
		int iType = NPCGetType(i);
		
		switch (iType)
		{
			case SF2BossType_Static:
			{
				float myPos[3], hisPos[3];
				SlenderGetAbsOrigin(i, myPos);
				AddVectors(myPos, g_flSlenderEyePosOffset[i], myPos);
				
				int iBestPlayer = -1;
				float flBestDistance = 16384.0;
				float flTempDistance;
				
				for (int iClient = 1; iClient <= MaxClients; iClient++)
				{
					if (!IsClientInGame(iClient) || !IsPlayerAlive(iClient) || IsClientInGhostMode(iClient) || IsClientInDeathCam(iClient)) continue;
					if (!IsPointVisibleToPlayer(iClient, myPos, false, false)) continue;
					
					GetClientAbsOrigin(iClient, hisPos);
					
					flTempDistance = GetVectorDistance(myPos, hisPos);
					if (flTempDistance < flBestDistance)
					{
						iBestPlayer = iClient;
						flBestDistance = flTempDistance;
					}
				}
				
				if (iBestPlayer > 0)
				{
					SlenderGetAbsOrigin(i, myPos);
					GetClientAbsOrigin(iBestPlayer, hisPos);
					
					if (!SlenderOnlyLooksIfNotSeen(i) || !IsPointVisibleToAPlayer(myPos, false, SlenderUsesBlink(i)))
					{
						float flTurnRate = NPCGetTurnRate(i);
					
						if (flTurnRate > 0.0)
						{
							float flMyEyeAng[3], ang[3];
							GetEntPropVector(iBoss, Prop_Data, "m_angAbsRotation", flMyEyeAng);
							AddVectors(flMyEyeAng, g_flSlenderEyeAngOffset[i], flMyEyeAng);
							SubtractVectors(hisPos, myPos, ang);
							GetVectorAngles(ang, ang);
							ang[0] = 0.0;
							ang[1] += (AngleDiff(ang[1], flMyEyeAng[1]) >= 0.0 ? 1.0 : -1.0) * flTurnRate * GetTickInterval();
							ang[2] = 0.0;
							
							// Take care of angle offsets.
							AddVectors(ang, g_flSlenderEyePosOffset[i], ang);
							for (int i2 = 0; i2 < 3; i2++) ang[i2] = AngleNormalize(ang[i2]);
							
							DispatchKeyValueVector(iBoss, "angles", ang);
						}
					}
				}
			}
			case SF2BossType_Chaser:
			{
				SlenderChaseBossProcessMovement(i);
			}
		}
	}
	// Check if we can add some proxies.
	if (!g_bRoundGrace)
	{
		if (NavMesh_Exists())
		{
			Handle hProxyCandidates = CreateArray();
			
			char sProfile[SF2_MAX_PROFILE_NAME_LENGTH];
			
			for (int iBossIndex = 0; iBossIndex < MAX_BOSSES; iBossIndex++)
			{
				if (NPCGetUniqueID(iBossIndex) == -1) continue;
				
				if (!(NPCGetFlags(iBossIndex) & SFF_PROXIES)) continue;
				
				if (g_iSlenderCopyMaster[iBossIndex] != -1) continue; // Copies cannot generate proxies.
				
				if (GetGameTime() < g_flSlenderTimeUntilNextProxy[iBossIndex]) continue; // Proxy spawning hasn't cooled down yet.
				
				int iTeleportTarget = EntRefToEntIndex(g_iSlenderTeleportTarget[iBossIndex]);
				if (!iTeleportTarget || iTeleportTarget == INVALID_ENT_REFERENCE) continue; // No teleport target.
				
				NPCGetProfile(iBossIndex, sProfile, sizeof(sProfile));
				
				int iMaxProxies = GetProfileNum(sProfile, "proxies_max");
				int iNumActiveProxies = 0;
				
				for (int iClient = 1; iClient <= MaxClients; iClient++)
				{
					if (!IsClientInGame(iClient) || !g_bPlayerEliminated[iClient]) continue;
					if (!g_bPlayerProxy[iClient]) continue;
					
					if (NPCGetFromUniqueID(g_iPlayerProxyMaster[iClient]) == iBossIndex)
					{
						iNumActiveProxies++;
					}
				}
				if (iNumActiveProxies >= iMaxProxies) 
				{
#if defined DEBUG
					//SendDebugMessageToPlayers(DEBUG_BOSS_PROXIES, 0, "[PROXIES] Boss %d has too many active proxies!", iBossIndex);
					PrintToChatAll("[PROXIES] Boss %d has too many active proxies!", iBossIndex);
#endif
					continue;
				}
				
				float flSpawnChanceMin = GetProfileFloat(sProfile, "proxies_spawn_chance_min");
				float flSpawnChanceMax = GetProfileFloat(sProfile, "proxies_spawn_chance_max");
				float flSpawnChanceThreshold = GetProfileFloat(sProfile, "proxies_spawn_chance_threshold") * NPCGetAnger(iBossIndex);
				
				float flChance = GetRandomFloat(flSpawnChanceMin, flSpawnChanceMax);
				if (flChance > flSpawnChanceThreshold) 
				{
#if defined DEBUG
					SendDebugMessageToPlayers(DEBUG_BOSS_PROXIES, 0, "[PROXIES] Boss %d's chances weren't in his favor!", iBossIndex);
					PrintToChatAll("[PROXIES] Boss %d's chances weren't in his favor!", iBossIndex);
#endif
					continue;
				}
				
				int iAvailableProxies = iMaxProxies - iNumActiveProxies;
				
				int iSpawnNumMin = GetProfileNum(sProfile, "proxies_spawn_num_min");
				int iSpawnNumMax = GetProfileNum(sProfile, "proxies_spawn_num_max");
				
				int iSpawnNum = 0;
				
				// Get a list of people we can transform into a good Proxy.
				ClearArray(hProxyCandidates);
				
				for (int iClient = 1; iClient <= MaxClients; iClient++)
				{
					if (!IsClientInGame(iClient) || !g_bPlayerEliminated[iClient]) continue;
					if (g_bPlayerProxy[iClient]) continue;
					
					if (!g_iPlayerPreferences[iClient][PlayerPreference_EnableProxySelection])
					{
#if defined DEBUG
						SendDebugMessageToPlayer(iClient, DEBUG_BOSS_PROXIES, 0, "[PROXIES] You were rejected for being a proxy for boss %d because of your preferences.", iBossIndex);
						PrintToChatAll("[PROXIES] You were rejected for being a proxy for boss %d because of your preferences.", iBossIndex);
#endif
						continue;
					}
					
					if (!g_bPlayerProxyAvailable[iClient])
					{
#if defined DEBUG
						SendDebugMessageToPlayer(iClient, DEBUG_BOSS_PROXIES, 0, "[PROXIES] You were rejected for being a proxy for boss %d because of your cooldown.", iBossIndex);
#endif
						continue;
					}
					
					if (g_bPlayerProxyAvailableInForce[iClient])
					{
#if defined DEBUG
						SendDebugMessageToPlayer(iClient, DEBUG_BOSS_PROXIES, 0, "[PROXIES] You were rejected for being a proxy for boss %d because you're already being forced into a Proxy.", iBossIndex);
#endif
						continue;
					}
					
					if (!IsClientParticipating(iClient))
					{
#if defined DEBUG
						SendDebugMessageToPlayer(iClient, DEBUG_BOSS_PROXIES, 0, "[PROXIES] You were rejected for being a proxy for boss %d because you're not participating.", iBossIndex);
#endif
						continue;
					}
					
					PushArrayCell(hProxyCandidates, iClient);
					iSpawnNum++;
				}
				
				if (iSpawnNum >= iSpawnNumMax)
				{
					iSpawnNum = GetRandomInt(iSpawnNumMin, iSpawnNumMax);
				}
				else if (iSpawnNum >= iSpawnNumMin)
				{
					iSpawnNum = GetRandomInt(iSpawnNumMin, iSpawnNum);
				}
				
				if (iSpawnNum <= 0) 
				{
#if defined DEBUG
					SendDebugMessageToPlayers(DEBUG_BOSS_PROXIES, 0, "[PROXIES] Boss %d had a set spawn number of 0!", iBossIndex);
#endif
					continue;
				}
				bool bCooldown = false;
				// Randomize the array.
				SortADTArray(hProxyCandidates, Sort_Random, Sort_Integer);
				
				float flDestinationPos[3];
				
				for (int iNum = 0; iNum < iSpawnNum && iNum < iAvailableProxies; iNum++)
				{
					int iClient = GetArrayCell(hProxyCandidates, iNum);
					
					if(!SpawnProxy(iClient,iBossIndex,flDestinationPos))
					{
#if defined DEBUG
						SendDebugMessageToPlayers(DEBUG_BOSS_PROXIES, 0, "[PROXIES] Boss %d could not find any areas to place proxies (spawned %d)!", iBossIndex, iNum);
						PrintToChatAll("[PROXIES] Boss %d could not find any areas to place proxies (spawned %d)!", iBossIndex, iNum);
#endif
						break;
					}
					bCooldown = true;
					if (!GetConVarBool(g_cvPlayerProxyAsk))
					{
						ClientStartProxyForce(iClient, NPCGetUniqueID(iBossIndex), flDestinationPos);
					}
					else
					{
						DisplayProxyAskMenu(iClient, NPCGetUniqueID(iBossIndex), flDestinationPos);
					}
				}
				// Set the cooldown time!
				if(bCooldown)
				{
					float flSpawnCooldownMin = GetProfileFloat(sProfile, "proxies_spawn_cooldown_min");
					float flSpawnCooldownMax = GetProfileFloat(sProfile, "proxies_spawn_cooldown_max");
				
					g_flSlenderTimeUntilNextProxy[iBossIndex] = GetGameTime() + GetRandomFloat(flSpawnCooldownMin, flSpawnCooldownMax);
				}
				else
					g_flSlenderTimeUntilNextProxy[iBossIndex] = GetGameTime() + GetRandomFloat(3.0, 4.0);
				
#if defined DEBUG
				PrintToChatAll("[PROXIES] Boss %d finished proxy process!", iBossIndex);
#endif
			}
			
			CloseHandle(hProxyCandidates);
		}
	}
	
	PvP_OnGameFrame();
}

//	==========================================================
//	COMMANDS AND COMMAND HOOK FUNCTIONS
//	==========================================================

public Action Command_Help(int iClient,int args)
{
	if (!g_bEnabled) return Plugin_Continue;
	
	DisplayMenu(g_hMenuHelp, iClient, 30);
	return Plugin_Handled;
}

public Action Command_Settings(int iClient,int args)
{
	if (!g_bEnabled) return Plugin_Continue;
	
	DisplayMenu(g_hMenuSettings, iClient, 30);
	return Plugin_Handled;
}

public Action Command_Credits(int iClient,int args)
{
	if (!g_bEnabled) return Plugin_Continue;
	
	DisplayMenu(g_hMenuCredits, iClient, MENU_TIME_FOREVER);
	return Plugin_Handled;
}

public Action Command_ToggleFlashlight(int iClient,int args)
{
	if (!g_bEnabled) return Plugin_Continue;
	
	if (!IsClientInGame(iClient) || !IsPlayerAlive(iClient)) return Plugin_Handled;
	
	if (!IsRoundInWarmup() && !IsRoundInIntro() && !IsRoundEnding() && !DidClientEscape(iClient))
	{
		if (GetGameTime() >= ClientGetFlashlightNextInputTime(iClient))
		{
			ClientHandleFlashlight(iClient);
		}
	}
	
	return Plugin_Handled;
}

public Action Command_SprintOn(int iClient,int args)
{
	if (!g_bEnabled) return Plugin_Continue;
	
	if (IsPlayerAlive(iClient) && !g_bPlayerEliminated[iClient])
	{
		ClientHandleSprint(iClient, true);
	}
	
	return Plugin_Handled;
}

public Action Command_SprintOff(int iClient,int args)
{
	if (!g_bEnabled) return Plugin_Continue;
	
	if (IsPlayerAlive(iClient) && !g_bPlayerEliminated[iClient])
	{
		ClientHandleSprint(iClient, false);
	}
	
	return Plugin_Handled;
}

public Action DevCommand_BossPackVote(int iClient,int args)
{
	if (!g_bEnabled) return Plugin_Continue;
	InitiateBossPackVote(iClient);
	return Plugin_Handled;
}

public Action Command_NoPoints(int iClient,int args)
{
	if (!g_bEnabled) return Plugin_Continue;
	if(!g_bAdminNoPoints[iClient])
		g_bAdminNoPoints[iClient] = true;
	else
		g_bAdminNoPoints[iClient] = false;
	return Plugin_Handled;
}

public Action Command_MainMenu(int iClient,int args)
{
	if (!g_bEnabled) return Plugin_Continue;
	DisplayMenu(g_hMenuMain, iClient, 30);
	return Plugin_Handled;
}

public Action Command_Update(int iClient, int args)
{
	if (!g_bEnabled) return Plugin_Continue;
	DisplayMenu(g_hMenuUpdate, iClient, 30);
	return Plugin_Handled;
}

public Action Command_Next(int iClient,int args)
{
	if (!g_bEnabled) return Plugin_Continue;
	
	DisplayQueuePointsMenu(iClient);
	return Plugin_Handled;
}


public Action Command_Group(int iClient,int args)
{
	if (!g_bEnabled) return Plugin_Continue;
	
	DisplayGroupMainMenuToClient(iClient);
	return Plugin_Handled;
}

public Action Command_GroupName(int iClient,int args)
{
	if (!g_bEnabled) return Plugin_Continue;
	
	if (args < 1)
	{
		ReplyToCommand(iClient, "Usage: sm_slgroupname <name>");
		return Plugin_Handled;
	}
	
	int iGroupIndex = ClientGetPlayerGroup(iClient);
	if (!IsPlayerGroupActive(iGroupIndex))
	{
		CPrintToChat(iClient, "%T", "SF2 Group Does Not Exist", iClient);
		return Plugin_Handled;
	}
	
	if (GetPlayerGroupLeader(iGroupIndex) != iClient)
	{
		CPrintToChat(iClient, "%T", "SF2 Not Group Leader", iClient);
		return Plugin_Handled;
	}
	
	char sGroupName[SF2_MAX_PLAYER_GROUP_NAME_LENGTH];
	GetCmdArg(1, sGroupName, sizeof(sGroupName));
	if (!sGroupName[0])
	{
		CPrintToChat(iClient, "%T", "SF2 Invalid Group Name", iClient);
		return Plugin_Handled;
	}
	
	char sOldGroupName[SF2_MAX_PLAYER_GROUP_NAME_LENGTH];
	GetPlayerGroupName(iGroupIndex, sOldGroupName, sizeof(sOldGroupName));
	SetPlayerGroupName(iGroupIndex, sGroupName);
	
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsValidClient(i)) continue;
		if (ClientGetPlayerGroup(i) != iGroupIndex) continue;
		CPrintToChat(i, "%T", "SF2 Group Name Set", i, sOldGroupName, sGroupName);
	}
	
	return Plugin_Handled;
}
public Action Command_GhostMode(int iClient,int args)
{
	if (!g_bEnabled) return Plugin_Continue;

	if (IsRoundEnding() || IsRoundInWarmup() || !g_bPlayerEliminated[iClient] || !IsClientParticipating(iClient) || g_bPlayerProxy[iClient])
	{
		CPrintToChat(iClient, "{red}%T", "SF2 Ghost Mode Not Allowed", iClient);
		return Plugin_Handled;
	}
	if (!IsClientInGhostMode(iClient))
	{
		TF2_RespawnPlayer(iClient);
		ClientSetGhostModeState(iClient, true);
		HandlePlayerHUD(iClient);
	
		CPrintToChat(iClient, "{olive}%T", "SF2 Ghost Mode Enabled", iClient);
	}
	else
	{
		ClientSetGhostModeState(iClient, false);
		TF2_RespawnPlayer(iClient);
		
		CPrintToChat(iClient, "{olive}%T", "SF2 Ghost Mode Disabled", iClient);
	}
	return Plugin_Handled;
}

public Action Hook_CommandSay(int iClient, const char[] command,int argc)
{
	if (!g_bEnabled || GetConVarBool(g_cvAllChat)) return Plugin_Continue;
	
	if (!IsRoundEnding())
	{
		if (g_bPlayerEliminated[iClient])
		{
			if(!IsPlayerAlive(iClient) && GetClientTeam(iClient) == TFTeam_Red)
				return Plugin_Handled;
			char sMessage[256];
			GetCmdArgString(sMessage, sizeof(sMessage));
			FakeClientCommand(iClient, "say_team %s", sMessage);
			return Plugin_Handled;
		}
	}
	
	return Plugin_Continue;
}
public Action Hook_CommandSayTeam(int iClient, const char[] command,int argc)
{
	if (!g_bEnabled || GetConVarBool(g_cvAllChat)) return Plugin_Continue;
	
	if (!IsRoundEnding())
	{
		if (g_bPlayerEliminated[iClient])
		{
			if(!IsPlayerAlive(iClient) && GetClientTeam(iClient) == TFTeam_Red)
				return Plugin_Handled;
		}
	}
	
	return Plugin_Continue;
}
public Action Hook_CommandSuicideAttempt(int iClient, const char[] command,int argc)
{
	if (!g_bEnabled) return Plugin_Continue;
	if (IsClientInGhostMode(iClient)) return Plugin_Handled;
	
	if (IsRoundInIntro() && !g_bPlayerEliminated[iClient]) return Plugin_Handled;
	
	if (GetConVarBool(g_cvBlockSuicideDuringRound))
	{
		if (!g_bRoundGrace && !g_bPlayerEliminated[iClient] && !DidClientEscape(iClient))
		{
			return Plugin_Handled;
		}
	}
	
	return Plugin_Continue;
}

public Action Hook_CommandBlockInGhostMode(int iClient, const char[] command,int argc)
{
	if (!g_bEnabled) return Plugin_Continue;
	if (IsClientInGhostMode(iClient)) return Plugin_Handled;
	if (IsRoundInIntro() && !g_bPlayerEliminated[iClient]) return Plugin_Handled;
	
	return Plugin_Continue;
}

public Action Hook_CommandVoiceMenu(int iClient, const char[] command,int argc)
{
	if (!g_bEnabled) return Plugin_Continue;
	if (IsClientInGhostMode(iClient))
	{
		ClientGhostModeNextTarget(iClient);
		return Plugin_Handled;
	}
	
	if (g_bPlayerProxy[iClient])
	{
		int iMaster = NPCGetFromUniqueID(g_iPlayerProxyMaster[iClient]);
		if (iMaster != -1)
		{
			char sProfile[SF2_MAX_PROFILE_NAME_LENGTH];
			NPCGetProfile(iMaster, sProfile, sizeof(sProfile));
		
			if (!view_as<bool>(GetProfileNum(sProfile, "proxies_allownormalvoices", 1)))
			{
				return Plugin_Handled;
			}
		}
	}
	
	return Plugin_Continue;
}

public Action Command_ClientPerformScare(int iClient,int args)
{
	if (!g_bEnabled) return Plugin_Continue;

	if (args < 2)
	{
		ReplyToCommand(iClient, "Usage: sm_sf2_scare <name|#userid> <bossindex 0-%d>", MAX_BOSSES - 1);
		return Plugin_Handled;
	}
	
	char arg1[32], arg2[32];
	GetCmdArg(1, arg1, sizeof(arg1));
	GetCmdArg(2, arg2, sizeof(arg2));
	
	char target_name[MAX_TARGET_LENGTH];
	int target_list[MAXPLAYERS], target_count;
	bool tn_is_ml;
	
	if ((target_count = ProcessTargetString(
			arg1,
			iClient,
			target_list,
			MAXPLAYERS,
			COMMAND_FILTER_ALIVE,
			target_name,
			sizeof(target_name),
			tn_is_ml)) <= 0)
	{
		ReplyToTargetError(iClient, target_count);
		return Plugin_Handled;
	}
	
	for (int i = 0; i < target_count; i++)
	{
		int target = target_list[i];
		ClientPerformScare(target, StringToInt(arg2));
	}
	
	return Plugin_Handled;
}

public Action Command_SpawnSlender(int iClient,int args)
{
	if (!g_bEnabled) return Plugin_Continue;

	if (args == 0)
	{
		ReplyToCommand(iClient, "Usage: sm_sf2_spawn_boss <bossindex 0-%d>", MAX_BOSSES - 1);
		return Plugin_Handled;
	}
	
	char arg1[32];
	GetCmdArg(1, arg1, sizeof(arg1));
	
	SF2NPC_BaseNPC Npc = view_as<SF2NPC_BaseNPC>(StringToInt(arg1));
	if (NPCGetUniqueID(Npc.Index) == -1) return Plugin_Handled;
	
	float eyePos[3], eyeAng[3], endPos[3];
	GetClientEyePosition(iClient, eyePos);
	GetClientEyeAngles(iClient, eyeAng);
	
	Handle hTrace = TR_TraceRayFilterEx(eyePos, eyeAng, MASK_NPCSOLID, RayType_Infinite, TraceRayDontHitEntity, iClient);
	TR_GetEndPosition(endPos, hTrace);
	CloseHandle(hTrace);
	
	SpawnSlender(Npc, endPos);
	
	char sProfile[SF2_MAX_PROFILE_NAME_LENGTH];
	Npc.GetProfile(sProfile, sizeof(sProfile));
	
	CPrintToChat(iClient, "%t%T", "SF2 Prefix", "SF2 Spawned Boss", iClient);
	LogAction(iClient, -1, "%N spawned boss %d! (%s)", iClient, Npc.Index, sProfile);
	
	return Plugin_Handled;
}

public Action Command_RemoveSlender(int iClient,int args)
{
	if (!g_bEnabled) return Plugin_Continue;

	if (args == 0)
	{
		ReplyToCommand(iClient, "Usage: sm_sf2_remove_boss <bossindex 0-%d>", MAX_BOSSES - 1);
		return Plugin_Handled;
	}
	
	char arg1[32];
	GetCmdArg(1, arg1, sizeof(arg1));
	
	int iBossIndex = StringToInt(arg1);
	if (NPCGetUniqueID(iBossIndex) == -1) return Plugin_Handled;
	
	char sProfile[SF2_MAX_PROFILE_NAME_LENGTH];
	NPCGetProfile(iBossIndex, sProfile, sizeof(sProfile));
	
	NPCRemove(iBossIndex);
	
	CPrintToChat(iClient, "%t%T", "SF2 Prefix", "SF2 Removed Boss", iClient);
	LogAction(iClient, -1, "%N removed boss %d! (%s)", iClient, iBossIndex, sProfile);
	
	return Plugin_Handled;
}

public Action Command_GetBossIndexes(int iClient,int args)
{
	if (!g_bEnabled) return Plugin_Continue;
	
	char sMessage[512];
	char sProfile[SF2_MAX_PROFILE_NAME_LENGTH];
	
	ClientCommand(iClient, "echo Active Boss Indexes:");
	ClientCommand(iClient, "echo ----------------------------");
	
	for (int i = 0; i < MAX_BOSSES; i++)
	{
		if (NPCGetUniqueID(i) == -1) continue;
		
		NPCGetProfile(i, sProfile, sizeof(sProfile));
		
		Format(sMessage, sizeof(sMessage), "%d - %s", i, sProfile);
		if (NPCGetFlags(i) & SFF_FAKE)
		{
			StrCat(sMessage, sizeof(sMessage), " (fake)");
		}
		
		if (g_iSlenderCopyMaster[i] != -1)
		{
			char sCat[64];
			Format(sCat, sizeof(sCat), " (copy of %d)", g_iSlenderCopyMaster[i]);
			StrCat(sMessage, sizeof(sMessage), sCat);
		}
		
		ClientCommand(iClient, "echo %s", sMessage);
	}
	
	ClientCommand(iClient, "echo ----------------------------");
	
	ReplyToCommand(iClient, "Printed active boss indexes to your console!");
	
	return Plugin_Handled;
}

public Action Command_SlenderAttackWaiters(int iClient,int args)
{
	if (!g_bEnabled) return Plugin_Continue;

	if (args < 2)
	{
		ReplyToCommand(iClient, "Usage: sm_sf2_boss_attack_waiters <bossindex 0-%d> <0/1>", MAX_BOSSES - 1);
		return Plugin_Handled;
	}
	
	char arg1[32];
	GetCmdArg(1, arg1, sizeof(arg1));
	
	int iBossIndex = StringToInt(arg1);
	if (NPCGetUniqueID(iBossIndex) == -1) return Plugin_Handled;
	
	char arg2[32];
	GetCmdArg(2, arg2, sizeof(arg2));
	
	int iBossFlags = NPCGetFlags(iBossIndex);
	
	bool bState = view_as<bool>(StringToInt(arg2));
	bool bOldState = view_as<bool>(iBossFlags & SFF_ATTACKWAITERS);
	
	char sProfile[SF2_MAX_PROFILE_NAME_LENGTH];
	NPCGetProfile(iBossIndex, sProfile, sizeof(sProfile));
	
	if (bState)
	{
		if (!bOldState)
		{
			NPCSetFlags(iBossIndex, iBossFlags | SFF_ATTACKWAITERS);
			CPrintToChat(iClient, "%t%T", "SF2 Prefix", "SF2 Boss Attack Waiters", iClient);
			LogAction(iClient, -1, "%N forced boss %d to attack waiters! (%s)", iClient, iBossIndex, sProfile);
		}
	}
	else
	{
		if (bOldState)
		{
			NPCSetFlags(iBossIndex, iBossFlags & ~SFF_ATTACKWAITERS);
			CPrintToChat(iClient, "%t%T", "SF2 Prefix", "SF2 Boss Do Not Attack Waiters", iClient);
			LogAction(iClient, -1, "%N forced boss %d to not attack waiters! (%s)", iClient, iBossIndex, sProfile);
		}
	}
	
	return Plugin_Handled;
}

public Action Command_SlenderNoTeleport(int iClient,int args)
{
	if (!g_bEnabled) return Plugin_Continue;

	if (args < 2)
	{
		ReplyToCommand(iClient, "Usage: sm_sf2_boss_no_teleport <bossindex 0-%d> <0/1>", MAX_BOSSES - 1);
		return Plugin_Handled;
	}
	
	char arg1[32];
	GetCmdArg(1, arg1, sizeof(arg1));
	
	int iBossIndex = StringToInt(arg1);
	if (NPCGetUniqueID(iBossIndex) == -1) return Plugin_Handled;
	
	char arg2[32];
	GetCmdArg(2, arg2, sizeof(arg2));
	
	int iBossFlags = NPCGetFlags(iBossIndex);
	
	bool bState = view_as<bool>(StringToInt(arg2));
	bool bOldState = view_as<bool>(iBossFlags & SFF_NOTELEPORT);
	
	char sProfile[SF2_MAX_PROFILE_NAME_LENGTH];
	NPCGetProfile(iBossIndex, sProfile, sizeof(sProfile));
	
	if (bState)
	{
		if (!bOldState)
		{
			NPCSetFlags(iBossIndex, iBossFlags | SFF_NOTELEPORT);
			CPrintToChat(iClient, "%t%T", "SF2 Prefix", "SF2 Boss Should Not Teleport", iClient);
			LogAction(iClient, -1, "%N disabled teleportation of boss %d! (%s)", iClient, iBossIndex, sProfile);
		}
	}
	else
	{
		if (bOldState)
		{
			NPCSetFlags(iBossIndex, iBossFlags & ~SFF_NOTELEPORT);
			CPrintToChat(iClient, "%t%T", "SF2 Prefix", "SF2 Boss Should Teleport", iClient);
			LogAction(iClient, -1, "%N enabled teleportation of boss %d! (%s)", iClient, iBossIndex, sProfile);
		}
	}
	
	return Plugin_Handled;
}

public Action Command_ForceProxy(int iClient,int args)
{
	if (!g_bEnabled) return Plugin_Continue;
	
	if (args < 1)
	{
		ReplyToCommand(iClient, "Usage: sm_sf2_force_proxy <name|#userid> <bossindex 0-%d>", MAX_BOSSES - 1);
		return Plugin_Handled;
	}
	
	if (IsRoundEnding() || IsRoundInWarmup())
	{
		CPrintToChat(iClient, "%t%T", "SF2 Prefix", "SF2 Cannot Use Command", iClient);
		return Plugin_Handled;
	}
	
	char arg1[32];
	GetCmdArg(1, arg1, sizeof(arg1));
	
	char target_name[MAX_TARGET_LENGTH];
	int target_list[MAXPLAYERS], target_count;
	bool tn_is_ml;
	
	if ((target_count = ProcessTargetString(
			arg1,
			iClient,
			target_list,
			MAXPLAYERS,
			0,
			target_name,
			sizeof(target_name),
			tn_is_ml)) <= 0)
	{
		ReplyToTargetError(iClient, target_count);
		return Plugin_Handled;
	}
	
	char arg2[32];
	GetCmdArg(2, arg2, sizeof(arg2));
	
	int iBossIndex = StringToInt(arg2);
	if (iBossIndex < 0 || iBossIndex >= MAX_BOSSES)
	{
		ReplyToCommand(iClient, "Boss index is out of range!");
		return Plugin_Handled;
	}
	else if (NPCGetUniqueID(iBossIndex) == -1)
	{
		ReplyToCommand(iClient, "Boss index is invalid! Boss index not active!");
		return Plugin_Handled;
	}
	
	for (int i = 0; i < target_count; i++)
	{
		int iTarget = target_list[i];
		
		char sName[MAX_NAME_LENGTH];
		GetClientName(iTarget, sName, sizeof(sName));
		
		if (!g_bPlayerEliminated[iTarget])
		{
			CPrintToChat(iClient, "%t%T", "SF2 Prefix", "SF2 Unable To Perform Action On Player In Round", iClient, sName);
			continue;
		}
		
		if (g_bPlayerProxy[iTarget]) continue;
		
		float flintPos[3];
		
		if (!SpawnProxy(iClient,iBossIndex,flintPos)) 
		{
			CPrintToChat(iClient, "%t%T", "SF2 Prefix", "SF2 Player No Place For Proxy", iClient, sName);
			continue;
		}
		
		ClientEnableProxy(iTarget, iBossIndex);
		TeleportEntity(iTarget, flintPos, NULL_VECTOR, view_as<float>({ 0.0, 0.0, 0.0 }));
		
		LogAction(iClient, iTarget, "%N forced %N to be a Proxy!", iClient, iTarget);
	}
	
	return Plugin_Handled;
}

public Action Command_ForceEscape(int iClient,int args)
{
	if (!g_bEnabled) return Plugin_Continue;

	if (args < 1)
	{
		ReplyToCommand(iClient, "Usage: sm_sf2_force_escape <name|#userid>");
		return Plugin_Handled;
	}
	
	char arg1[32];
	GetCmdArg(1, arg1, sizeof(arg1));
	
	char target_name[MAX_TARGET_LENGTH];
	int target_list[MAXPLAYERS], target_count;
	bool tn_is_ml;
	
	if ((target_count = ProcessTargetString(
			arg1,
			iClient,
			target_list,
			MAXPLAYERS,
			COMMAND_FILTER_ALIVE,
			target_name,
			sizeof(target_name),
			tn_is_ml)) <= 0)
	{
		ReplyToTargetError(iClient, target_count);
		return Plugin_Handled;
	}
	
	for (int i = 0; i < target_count; i++)
	{
		int target = target_list[i];
		if (!g_bPlayerEliminated[i] && !DidClientEscape(i))
		{
			ClientEscape(target);
			TeleportClientToEscapePoint(target);
			
			LogAction(iClient, target, "%N forced %N to escape!", iClient, target);
		}
	}
	
	return Plugin_Handled;
}

public Action Command_AddSlender(int iClient,int args)
{
	if (!g_bEnabled) return Plugin_Continue;

	if (args < 1)
	{
		ReplyToCommand(iClient, "Usage: sm_sf2_add_boss <name>");
		return Plugin_Handled;
	}
	
	char sProfile[SF2_MAX_PROFILE_NAME_LENGTH];
	GetCmdArg(1, sProfile, sizeof(sProfile));
	
	KvRewind(g_hConfig);
	if (!KvJumpToKey(g_hConfig, sProfile)) 
	{
		ReplyToCommand(iClient, "That boss does not exist!");
		return Plugin_Handled;
	}
	
	SF2NPC_BaseNPC Npc = AddProfile(sProfile);
	if (Npc.IsValid())
	{
		float eyePos[3], eyeAng[3], flPos[3];
		GetClientEyePosition(iClient, eyePos);
		GetClientEyeAngles(iClient, eyeAng);
		
		Handle hTrace = TR_TraceRayFilterEx(eyePos, eyeAng, MASK_NPCSOLID, RayType_Infinite, TraceRayDontHitEntity, iClient);
		TR_GetEndPosition(flPos, hTrace);
		CloseHandle(hTrace);
	
		SpawnSlender(Npc, flPos);
		
		LogAction(iClient, -1, "%N added a boss! (%s)", iClient, sProfile);
	}
	
	return Plugin_Handled;
}
public void NPCSpawn(const char[] output,int iEnt,int activator, float delay)
{
	if (!g_bEnabled) return;
	char targetName[255];
	GetEntPropString(iEnt, Prop_Data, "m_iName", targetName, sizeof(targetName));
	if (targetName[0])
	{
		if (!StrContains(targetName, "sf2_spawn_", false))
		{
			ReplaceString(targetName, sizeof(targetName), "sf2_spawn_", "", false);
			KvRewind(g_hConfig);
			if (!KvJumpToKey(g_hConfig, targetName)) 
			{
				PrintToServer("Entity: %i.That boss does not exist!",iEnt);
				return;
			}
			char sProfile[SF2_MAX_PROFILE_NAME_LENGTH];
			SF2NPC_BaseNPC Npc;
			for(int iNpc;iNpc<=MAX_BOSSES;iNpc++)
			{
				Npc = view_as<SF2NPC_BaseNPC>(iNpc);
				if(Npc.IsValid())
				{
					Npc.GetProfile(sProfile,sizeof(sProfile));
					if(StrEqual(sProfile,targetName))
					{
						Npc.UnSpawn();
						float flPos[3];
						GetEntPropVector(iEnt, Prop_Data, "m_vecOrigin", flPos);
						SpawnSlender(Npc, flPos);
						break;
					}
				}
			}
		}
	}
	return;
}

public Action Command_AddSlenderFake(int iClient,int args)
{
	if (!g_bEnabled) return Plugin_Continue;

	if (args < 1)
	{
		ReplyToCommand(iClient, "Usage: sm_sf2_add_boss_fake <name>");
		return Plugin_Handled;
	}
	
	char sProfile[SF2_MAX_PROFILE_NAME_LENGTH];
	GetCmdArg(1, sProfile, sizeof(sProfile));
	
	KvRewind(g_hConfig);
	if (!KvJumpToKey(g_hConfig, sProfile)) 
	{
		ReplyToCommand(iClient, "That boss does not exist!");
		return Plugin_Handled;
	}
	
	SF2NPC_BaseNPC Npc = AddProfile(sProfile, SFF_FAKE);
	if (Npc.IsValid())
	{
		float eyePos[3], eyeAng[3], flPos[3];
		GetClientEyePosition(iClient, eyePos);
		GetClientEyeAngles(iClient, eyeAng);
		
		Handle hTrace = TR_TraceRayFilterEx(eyePos, eyeAng, MASK_NPCSOLID, RayType_Infinite, TraceRayDontHitEntity, iClient);
		TR_GetEndPosition(flPos, hTrace);
		CloseHandle(hTrace);
	
		SpawnSlender(Npc, flPos);
		
		LogAction(iClient, -1, "%N added a fake boss! (%s)", iClient, sProfile);
	}
	
	return Plugin_Handled;
}

public Action Command_ForceState(int iClient,int args)
{
	if (!g_bEnabled) return Plugin_Continue;

	if (args < 2)
	{
		ReplyToCommand(iClient, "Usage: sm_sf2_setplaystate <name|#userid> <0/1>");
		return Plugin_Handled;
	}
	
	if (IsRoundEnding() || IsRoundInWarmup())
	{
		CPrintToChat(iClient, "%t%T", "SF2 Prefix", "SF2 Cannot Use Command", iClient);
		return Plugin_Handled;
	}
	
	char arg1[32];
	GetCmdArg(1, arg1, sizeof(arg1));
	
	char target_name[MAX_TARGET_LENGTH];
	int target_list[MAXPLAYERS], target_count;
	bool tn_is_ml;
	
	if ((target_count = ProcessTargetString(
			arg1,
			iClient,
			target_list,
			MAXPLAYERS,
			0,
			target_name,
			sizeof(target_name),
			tn_is_ml)) <= 0)
	{
		ReplyToTargetError(iClient, target_count);
		return Plugin_Handled;
	}
	
	char arg2[32];
	GetCmdArg(2, arg2, sizeof(arg2));
	
	int iState = StringToInt(arg2);
	
	char sName[MAX_NAME_LENGTH];
	
	for (int i = 0; i < target_count; i++)
	{
		int target = target_list[i];
		GetClientName(target, sName, sizeof(sName));
		
		if (iState && g_bPlayerEliminated[target])
		{
			SetClientPlayState(target, true);
			
			CPrintToChatAll("%t %N: %t", "SF2 Prefix", iClient, "SF2 Player Forced In Game", sName);
			LogAction(iClient, target, "%N forced %N into the game.", iClient, target);
		}
		else if (!iState && !g_bPlayerEliminated[target])
		{
			SetClientPlayState(target, false);
			
			CPrintToChatAll("%t %N: %t", "SF2 Prefix", iClient, "SF2 Player Forced Out Of Game", sName);
			LogAction(iClient, target, "%N took %N out of the game.", iClient, target);
		}
	}
	
	return Plugin_Handled;
}

public Action Hook_CommandBuild(int iClient, const char[] command,int argc)
{
	if (!g_bEnabled) return Plugin_Continue;
	if (!IsClientInPvP(iClient)) return Plugin_Handled;
	
	return Plugin_Continue;
}

public Action Timer_BossCountUpdate(Handle timer)
{
	if (timer != g_hBossCountUpdateTimer) return Plugin_Stop;
	
	if (!g_bEnabled) return Plugin_Stop;

	int iBossCount = NPCGetCount();
	int iBossPreferredCount;
	
	for (int i = 0; i < MAX_BOSSES; i++)
	{
		if (NPCGetUniqueID(i) == -1 ||
			g_iSlenderCopyMaster[i] != -1 ||
			(NPCGetFlags(i) & SFF_FAKE))
		{
			continue;
		}
		
		iBossPreferredCount++;
	}
	
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsValidClient(i) ||
			!IsPlayerAlive(i) ||
			g_bPlayerEliminated[i] ||
			IsClientInGhostMode(i) ||
			IsClientInDeathCam(i) ||
			DidClientEscape(i)) continue;
		
		// Check if we're near any bosses.
		int iClosest = -1;
		float flBestDist = SF2_BOSS_PAGE_CALCULATION;
		
		for (int iBoss = 0; iBoss < MAX_BOSSES; iBoss++)
		{
			if (NPCGetUniqueID(iBoss) == -1) continue;
			if (NPCGetEntIndex(iBoss) == INVALID_ENT_REFERENCE) continue;
			if (NPCGetFlags(iBoss) & SFF_FAKE) continue;
			
			float flDist = NPCGetDistanceFromEntity(iBoss, i);
			if (flDist < flBestDist)
			{
				iClosest = iBoss;
				flBestDist = flDist;
				break;
			}
		}
		
		if (iClosest != -1) continue;
		
		iClosest = -1;
		flBestDist = SF2_BOSS_PAGE_CALCULATION;
		
		for (int iClient = 1; iClient <= MaxClients; iClient++)
		{
			if (!IsValidClient(iClient) ||
				!IsPlayerAlive(iClient) ||
				g_bPlayerEliminated[iClient] ||
				IsClientInGhostMode(iClient) ||
				IsClientInDeathCam(iClient) ||
				DidClientEscape(iClient)) 
			{
				continue;
			}
			
			bool bwub = false;
			for (int iBoss = 0; iBoss < MAX_BOSSES; iBoss++)
			{
				if (NPCGetUniqueID(iBoss) == -1) continue;
				if (NPCGetFlags(iBoss) & SFF_FAKE) continue;
				
				if (g_iSlenderTarget[iBoss] == iClient)
				{
					bwub = true;
					break;
				}
			}
			
			if (!bwub) continue;
			
			float flDist = EntityDistanceFromEntity(i, iClient);
			if (flDist < flBestDist)
			{
				iClosest = iClient;
				flBestDist = flDist;
			}
		}
		
		if (!IsValidClient(iClosest))
		{
			// No one's close to this dude? DUDE! WE NEED ANOTHER BOSS!
			iBossPreferredCount++;
		}
	}
	
	int iDiff = iBossCount - iBossPreferredCount;
	if (iDiff)
	{	
		if (iDiff > 0)
		{
			int iCount = iDiff;
			// We need less bosses. Try and see if we can remove some.
			for (int i = 0; i < MAX_BOSSES; i++)
			{
				if (g_iSlenderCopyMaster[i] == -1) continue;
				if (PeopleCanSeeSlender(i, _, false)) continue;
				if (NPCGetFlags(i) & SFF_FAKE) continue;
				
				if (SlenderCanRemove(i))
				{
					NPCRemove(i);
					iCount--;
				}
				
				if (iCount <= 0)
				{
					break;
				}
			}
		}
		else
		{
			char sProfile[SF2_MAX_PROFILE_NAME_LENGTH];
		
			int iCount = RoundToFloor(FloatAbs(float(iDiff)));
			// Add int bosses (copy of the first boss).
			for (int i = 0; i < MAX_BOSSES && iCount > 0; i++)
			{
				SF2NPC_BaseNPC Npc = view_as<SF2NPC_BaseNPC>(i);
				if (!Npc.IsValid()) continue;
				if (g_iSlenderCopyMaster[Npc.Index] != -1) continue;
				if (!(Npc.Flags & SFF_COPIES)) continue;
				if (Npc.Flags & SFF_FAKE) continue;
				
				// Get the number of copies I already have and see if I can have more copies.
				int iCopyCount;
				for (int i2 = 0; i2 < MAX_BOSSES; i2++)
				{
					if (NPCGetUniqueID(i2) == -1) continue;
					if (g_iSlenderCopyMaster[i2] != i) continue;
					
					iCopyCount++;
				}
				
				Npc.GetProfile(sProfile, sizeof(sProfile));
				if (iCopyCount >= GetProfileNum(sProfile, "copy_max", 10)) 
				{
					continue;
				}
				SF2NPC_BaseNPC NpcCopy = AddProfile(sProfile, _, Npc);
				if (!NpcCopy.IsValid())
				{
					LogError("Could not add copy for %d: No free slots!", i);
				}
				
				iCount--;
			}
		}
	}
	return Plugin_Continue;
}

void ReloadRestrictedWeapons()
{
	if (g_hRestrictedWeaponsConfig != INVALID_HANDLE)
	{
		CloseHandle(g_hRestrictedWeaponsConfig);
		g_hRestrictedWeaponsConfig = INVALID_HANDLE;
	}
	
	char buffer[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, buffer, sizeof(buffer), FILE_RESTRICTEDWEAPONS);
	Handle kv = CreateKeyValues("root");
	if (!FileToKeyValues(kv, buffer))
	{
		CloseHandle(kv);
		LogError("Failed to load restricted weapons list! File not found!");
	}
	else
	{
		g_hRestrictedWeaponsConfig = kv;
		LogSF2Message("Reloaded restricted weapons configuration file successfully");
	}
}

public Action Timer_RoundMessages(Handle timer)
{
	if (!g_bEnabled) return Plugin_Stop;
	
	if (timer != g_hRoundMessagesTimer) return Plugin_Stop;
	
	switch (g_iRoundMessagesNum)
	{
		case 0: CPrintToChatAll("{powderblue}== {deepskyblue}Slender Fortress{powderblue} coded by {blue}Kit o' Rifty{powderblue}==\n== New versions by {blue}Benoist3012{powderblue}, current version {frozen}%s{powderblue}==", PLUGIN_VERSION_DISPLAY);
		case 1: CPrintToChatAll("%t", "SF2 Ad Message 1");
		case 2: CPrintToChatAll("%t", "SF2 Ad Message 2");
	}
	
	g_iRoundMessagesNum++;
	if (g_iRoundMessagesNum > 2) g_iRoundMessagesNum = 0;
	
	return Plugin_Continue;
}

public Action Timer_WelcomeMessage(Handle timer, any userid)
{
	int iClient = GetClientOfUserId(userid);
	if (iClient <= 0) return;
	
	CPrintToChat(iClient, "%T", "SF2 Welcome Message", iClient);
}

int GetMaxPlayersForRound()
{
	int iOverride = GetConVarInt(g_cvMaxPlayersOverride);
	if (iOverride != -1) return iOverride;
	return GetConVarInt(g_cvMaxPlayers);
}

public void OnConVarChanged(Handle cvar, const char[] oldValue, const char[] intValue)
{
	if (cvar == g_cvDifficulty)
	{
		switch (StringToInt(intValue))
		{
			case Difficulty_Easy: g_flRoundDifficultyModifier = DIFFICULTY_EASY;
			case Difficulty_Hard: g_flRoundDifficultyModifier = DIFFICULTY_HARD;
			case Difficulty_Insane: g_flRoundDifficultyModifier = DIFFICULTY_INSANE;
			default: g_flRoundDifficultyModifier = DIFFICULTY_NORMAL;
		}
	}
	else if (cvar == g_cvMaxPlayers || cvar == g_cvMaxPlayersOverride)
	{
		for (int i = 0; i < SF2_MAX_PLAYER_GROUPS; i++)
		{
			CheckPlayerGroup(i);
		}
	}
	else if (cvar == g_cvPlayerShakeEnabled)
	{
		g_bPlayerShakeEnabled = view_as<bool>(StringToInt(intValue));
	}
	else if (cvar == g_cvPlayerViewbobEnabled)
	{
		g_bPlayerViewbobEnabled = view_as<bool>(StringToInt(intValue));
	}
	else if (cvar == g_cvPlayerViewbobHurtEnabled)
	{
		g_bPlayerViewbobHurtEnabled = view_as<bool>(StringToInt(intValue));
	}
	else if (cvar == g_cvPlayerViewbobSprintEnabled)
	{
		g_bPlayerViewbobSprintEnabled = view_as<bool>(StringToInt(intValue));
	}
	else if (cvar == g_cvGravity)
	{
		g_flGravity = StringToFloat(intValue);
	}
	else if (cvar == g_cv20Dollars)
	{
		g_b20Dollars = view_as<bool>(StringToInt(intValue));
	}
	else if (cvar == g_cvAllChat)
	{
		if (g_bEnabled)
		{
			for (int i = 1; i <= MaxClients; i++)
			{
				ClientUpdateListeningFlags(i);
			}
		}
	}
}

//	==========================================================
//	IN-GAME AND ENTITY HOOK FUNCTIONS
//	==========================================================


public void OnEntityCreated(int ent, const char[] classname)
{
	if (!g_bEnabled) return;
	
	if (!IsValidEntity(ent) || ent <= 0) return;
	
	if (StrEqual(classname, "spotlight_end", false))
	{
		SDKHook(ent, SDKHook_SpawnPost, Hook_FlashlightEndSpawnPost);
	}
	else if (StrEqual(classname, "beam", false))
	{
		SDKHook(ent, SDKHook_SetTransmit, Hook_FlashlightBeamSetTransmit);
	}
	
	PvP_OnEntityCreated(ent, classname);
}
public void OnEntityDestroyed(int ent)
{
	if (!g_bEnabled) return;

	if (!IsValidEntity(ent) || ent <= 0) return;
	
	char sClassname[64];
	GetEntityClassname(ent, sClassname, sizeof(sClassname));
	
	if (StrEqual(sClassname, "light_dynamic", false))
	{
		AcceptEntityInput(ent, "TurnOff");
		
		int iEnd = INVALID_ENT_REFERENCE;
		while ((iEnd = FindEntityByClassname(iEnd, "spotlight_end")) != -1)
		{
			if (GetEntPropEnt(iEnd, Prop_Data, "m_hOwnerEntity") == ent)
			{
				AcceptEntityInput(iEnd, "Kill");
				break;
			}
		}
	}
	g_iSlenderHitboxOwner[ent]=-1;
	
	PvP_OnEntityDestroyed(ent, sClassname);
}

public Action Hook_BlockUserMessage(UserMsg msg_id, Handle bf, const int[] players,int playersNum, bool reliable, bool init) 
{
	if (!g_bEnabled) return Plugin_Continue;
	return Plugin_Handled;
}
/*public Action Hook_BlockUserMessageEx(UserMsg msg_id, BfRead msg, const int[] players, int playersNum, bool reliable, bool init)
{
	if (!g_bEnabled) return Plugin_Continue;
	char message[32];
	msg.ReadByte();
	msg.ReadString(message, sizeof(message));
	if(strcmp(message, "#TF_Name_Change") == 0)
	{
		return Plugin_Handled;
	}
	
	return Plugin_Continue;
}*/

public Action Hook_NormalSound(int clients[64], int &numClients, char sample[PLATFORM_MAX_PATH], int &entity, int &channel, float &volume, int &level, int &pitch, int &flags)
{
	if (!g_bEnabled) return Plugin_Continue;
	
	if (IsValidClient(entity))
	{
		if (IsClientInGhostMode(entity))
		{
			switch (channel)
			{
				case SNDCHAN_VOICE, SNDCHAN_WEAPON, SNDCHAN_ITEM, SNDCHAN_BODY: return Plugin_Handled;
			}
		}
		else if (g_bPlayerProxy[entity])
		{
			int iMaster = NPCGetFromUniqueID(g_iPlayerProxyMaster[entity]);
			if (iMaster != -1)
			{
				char sProfile[SF2_MAX_PROFILE_NAME_LENGTH];
				NPCGetProfile(iMaster, sProfile, sizeof(sProfile));
				
				switch (channel)
				{
					case SNDCHAN_VOICE:
					{
						if (!view_as<bool>(GetProfileNum(sProfile, "proxies_allownormalvoices", 1)))
						{
							return Plugin_Handled;
						}
					}
				}
			}
		}
		else if (!g_bPlayerEliminated[entity])
		{
			switch (channel)
			{
				case SNDCHAN_VOICE:
				{
					if (IsRoundInIntro()) return Plugin_Handled;
				
					for (int iBossIndex = 0; iBossIndex < MAX_BOSSES; iBossIndex++)
					{
						if (NPCGetUniqueID(iBossIndex) == -1) continue;
						
						if (SlenderCanHearPlayer(iBossIndex, entity, SoundType_Voice))
						{
							GetClientAbsOrigin(entity, g_flSlenderTargetSoundTempPos[iBossIndex]);
							g_iSlenderInterruptConditions[iBossIndex] |= COND_HEARDSUSPICIOUSSOUND;
							g_iSlenderInterruptConditions[iBossIndex] |= COND_HEARDVOICE;
						}
					}
				}
				case SNDCHAN_BODY:
				{
					if (!StrContains(sample, "player/footsteps", false) || StrContains(sample, "step", false) != -1)
					{
						if (GetConVarBool(g_cvPlayerViewbobSprintEnabled) && IsClientReallySprinting(entity))
						{
							// Viewpunch.
							float flPunchVelStep[3];
							
							float flVelocity[3];
							GetEntPropVector(entity, Prop_Data, "m_vecAbsVelocity", flVelocity);
							float flSpeed = GetVectorLength(flVelocity);
							
							flPunchVelStep[0] = flSpeed / 300.0;
							flPunchVelStep[1] = 0.0;
							flPunchVelStep[2] = 0.0;
							
							ClientViewPunch(entity, flPunchVelStep);
						}
						
						for (int iBossIndex = 0; iBossIndex < MAX_BOSSES; iBossIndex++)
						{
							if (NPCGetUniqueID(iBossIndex) == -1) continue;
							
							if (SlenderCanHearPlayer(iBossIndex, entity, SoundType_Footstep))
							{
								GetClientAbsOrigin(entity, g_flSlenderTargetSoundTempPos[iBossIndex]);
								g_iSlenderInterruptConditions[iBossIndex] |= COND_HEARDSUSPICIOUSSOUND;
								g_iSlenderInterruptConditions[iBossIndex] |= COND_HEARDFOOTSTEP;
								
								if (IsClientSprinting(entity) && !(GetEntProp(entity, Prop_Send, "m_bDucking") || GetEntProp(entity, Prop_Send, "m_bDucked")))
								{
									g_iSlenderInterruptConditions[iBossIndex] |= COND_HEARDFOOTSTEPLOUD;
								}
							}
						}
					}
				}
				case SNDCHAN_ITEM, SNDCHAN_WEAPON:
				{
					if (StrContains(sample, "impact", false) != -1 || StrContains(sample, "hit", false) != -1)
					{
						for (int iBossIndex = 0; iBossIndex < MAX_BOSSES; iBossIndex++)
						{
							if (NPCGetUniqueID(iBossIndex) == -1) continue;
							
							if (SlenderCanHearPlayer(iBossIndex, entity, SoundType_Weapon))
							{
								GetClientAbsOrigin(entity, g_flSlenderTargetSoundTempPos[iBossIndex]);
								g_iSlenderInterruptConditions[iBossIndex] |= COND_HEARDSUSPICIOUSSOUND;
								g_iSlenderInterruptConditions[iBossIndex] |= COND_HEARDWEAPON;
							}
						}
					}
				}
			}
		}
	}
	
	bool bModified = false;
	
	for (int i = 0; i < numClients; i++)
	{
		int iClient = clients[i];
		if (IsValidClient(iClient) && IsPlayerAlive(iClient) && !IsClientInGhostMode(iClient))
		{
			bool bCanHearSound = true;
			
			if (IsValidClient(entity) && entity != iClient)
			{
				if (!g_bPlayerEliminated[iClient])
				{
					if (g_bSpecialRound && g_iSpecialRoundType == SPECIALROUND_SINGLEPLAYER)
					{
						if (!g_bPlayerEliminated[entity] && !DidClientEscape(entity))
						{
							bCanHearSound = false;
						}
					}
				}
			}
			
			if (!bCanHearSound)
			{
				bModified = true;
				clients[i] = -1;
			}
		}
	}
	
	if (bModified) return Plugin_Changed;
	return Plugin_Continue;
}

public MRESReturn Hook_EntityShouldTransmit(int entity, Handle hReturn, Handle hParams)
{
	if (!g_bEnabled) return MRES_Ignored;
	
	if (IsValidClient(entity))
	{
		if (DoesClientHaveConstantGlow(entity))
		{
			DHookSetReturn(hReturn, FL_EDICT_ALWAYS); // Should always transmit, but our SetTransmit hook gets the final say.
			return MRES_Supercede;
		}
	}
	else
	{
		int iBossIndex = NPCGetFromEntIndex(entity);
		if (iBossIndex != -1)
		{
			DHookSetReturn(hReturn, FL_EDICT_ALWAYS); // Should always transmit, but our SetTransmit hook gets the final say.
			return MRES_Supercede;
		}
	}
	
	return MRES_Ignored;
}

public void Hook_TriggerOnStartTouch(const char[] output,int caller,int activator, float delay)
{
	if (!g_bEnabled) return;

	if (!IsValidEntity(caller)) return;
	
	char sName[64];
	GetEntPropString(caller, Prop_Data, "m_iName", sName, sizeof(sName));
	
	if (StrContains(sName, "sf2_escape_trigger", false) == 0)
	{
		if (IsRoundInEscapeObjective())
		{
			if (IsValidClient(activator) && IsPlayerAlive(activator) && !IsClientInDeathCam(activator) && !g_bPlayerEliminated[activator] && !DidClientEscape(activator))
			{
				ClientEscape(activator);
				TeleportClientToEscapePoint(activator);
			}
		}
	}
	//We have to disable hitbox's colisions in order to prevent some bugs.
	if(activator>MaxClients)
	{
		SF2NPC_BaseNPC Npc = view_as<SF2NPC_BaseNPC>(NPCGetFromEntIndex(activator));
		if(g_iSlenderHitboxOwner[activator] != -1)
		{
			Npc = view_as<SF2NPC_BaseNPC>(activator);
		}
		if(Npc.IsValid())//Turn off colisions.
		{
			SetEntData(g_iSlenderHitbox[Npc.Index], g_offsCollisionGroup, 2, 4, true);
		}
	}
	
	PvP_OnTriggerStartTouch(caller, activator);
}

public void Hook_TriggerOnEndTouch(const char[] sOutput,int caller,int activator, float flDelay)
{
	if (!g_bEnabled) return;
	if(activator>MaxClients)
	{
		SF2NPC_BaseNPC Npc = view_as<SF2NPC_BaseNPC>(NPCGetFromEntIndex(activator));
		if(Npc.IsValid())//Turn colisions back.
			SetEntData(g_iSlenderHitbox[Npc.Index], g_offsCollisionGroup, 4, 4, true);
	}
}

public Action Hook_PageOnTakeDamage(int page,int &attacker,int &inflictor,float &damage,int &damagetype,int &weapon, float damageForce[3], float damagePosition[3],int damagecustom)
{
	if (!g_bEnabled) return Plugin_Continue;
	
	if (IsValidClient(attacker))
	{
		if (!g_bPlayerEliminated[attacker])
		{
			if (damagetype & 0x80) // 0x80 == melee damage
			{
				CollectPage(page, attacker);
			}
		}
	}
	
	return Plugin_Continue;
}

static void CollectPage(int page,int activator)
{
	if(SF_SpecialRound(SPECIALROUND_ESCAPETICKETS))
	{
		ClientEscape(activator);
		TeleportClientToEscapePoint(activator);
	}
	SetPageCount(g_iPageCount + 1);
	g_iPlayerPageCount[activator] += 1;
	EmitSoundToAll(PAGE_GRABSOUND, activator, SNDCHAN_ITEM, SNDLEVEL_SCREAMING);
	
	Call_StartForward(fOnClientCollectPage);
	Call_PushCell(page);
	Call_PushCell(activator);
	Call_Finish();

	// Gives points. Credit to the makers of VSH/FF2.
	Handle hEvent = CreateEvent("player_escort_score", true);
	SetEventInt(hEvent, "player", activator);
	SetEventInt(hEvent, "points", 1);
	FireEvent(hEvent);
	
	AcceptEntityInput(page, "FireUser1");
	AcceptEntityInput(page, "KillHierarchy");
}

//	==========================================================
//	GENERIC iClient HOOKS AND FUNCTIONS
//	==========================================================


public Action OnPlayerRunCmd(int iClient,int &buttons,int &impulse, float vel[3], float angles[3],int &weapon,int &subtype,int &cmdnum,int &tickcount,int &seed,int mouse[2])
{
	if (!g_bEnabled) return Plugin_Continue;
	
	ClientDisableFakeLagCompensation(iClient);
	
	// Check impulse (block spraying and built-in flashlight)
	switch (impulse)
	{
		case 100:
		{
			impulse = 0;
		}
		case 201:
		{
			if (IsClientInGhostMode(iClient))
			{
				impulse = 0;
			}
		}
	}
	
	for (int i = 0; i < MAX_BUTTONS; i++)
	{
		int button = (1 << i);
		
		if ((buttons & button))
		{
			if (!(g_iPlayerLastButtons[iClient] & button))
			{
				ClientOnButtonPress(iClient, button);
			}
			if(button==IN_ATTACK2)
			{
				if(!g_bPlayerEliminated[iClient])
				{
					g_iPlayerLastButtons[iClient] = buttons;
					int iWeaponActive = GetEntPropEnt(iClient, Prop_Send, "m_hActiveWeapon");
					if(iWeaponActive > MaxClients && IsTauntWep(iWeaponActive))
					{
						buttons &= ~IN_ATTACK2;	//Tough break update made players able to taunt with secondary attack.Disabled.
						//Actually we can only taunt with the ubersaw by pressing alt-fire.But valve will probably add in the future more weapons with this feature.
					}
					return Plugin_Changed;
				}
			}
		}
		else if ((g_iPlayerLastButtons[iClient] & button))
		{
			ClientOnButtonRelease(iClient, button);
		}
	}
	g_iPlayerLastButtons[iClient] = buttons;
	return Plugin_Continue;
}

public void OnClientCookiesCached(int iClient)
{
	if (!g_bEnabled) return;
	
	// Load our saved settings.
	char sCookie[64];
	GetClientCookie(iClient, g_hCookie, sCookie, sizeof(sCookie));
	
	g_iPlayerQueuePoints[iClient] = 0;
	
	g_iPlayerPreferences[iClient][PlayerPreference_ShowHints] = true;
	g_iPlayerPreferences[iClient][PlayerPreference_MuteMode] = MuteMode_Normal;
	g_iPlayerPreferences[iClient][PlayerPreference_FilmGrain] = true;
	g_iPlayerPreferences[iClient][PlayerPreference_EnableProxySelection] = true;
	g_iPlayerPreferences[iClient][PlayerPreference_GhostOverlay] = true;
	
	if (sCookie[0])
	{
		char s2[12][32];
		int count = ExplodeString(sCookie, " ; ", s2, 12, 32);
		
		if (count > 0)
			g_iPlayerQueuePoints[iClient] = StringToInt(s2[0]);
		if (count > 1)
			g_iPlayerPreferences[iClient][PlayerPreference_ShowHints] = view_as<bool>(StringToInt(s2[1]));
		if (count > 2)
			g_iPlayerPreferences[iClient][PlayerPreference_MuteMode] = view_as<MuteMode>(StringToInt(s2[2]));
		if (count > 3)
			g_iPlayerPreferences[iClient][PlayerPreference_FilmGrain] = view_as<bool>(StringToInt(s2[3]));
		if (count > 4)
			g_iPlayerPreferences[iClient][PlayerPreference_EnableProxySelection] = view_as<bool>(StringToInt(s2[4]));
		if (count > 5)
			g_iPlayerPreferences[iClient][PlayerPreference_GhostOverlay] = view_as<bool>(StringToInt(s2[5]));
	}
}

public void OnClientPutInServer(int iClient)
{
	if (!g_bEnabled) return;
	
#if defined DEBUG
	if (GetConVarInt(g_cvDebugDetail) > 0) DebugMessage("START OnClientPutInServer(%d)", iClient);
#endif
	
	ClientSetPlayerGroup(iClient, -1);
	
	g_bPlayerEscaped[iClient] = false;
	g_bPlayerEliminated[iClient] = true;
	g_bPlayerChoseTeam[iClient] = false;
	g_bPlayerPlayedSpecialRound[iClient] = true;
	g_bPlayerPlayedNewBossRound[iClient] = true;
	
	g_iPlayerPreferences[iClient][PlayerPreference_PvPAutoSpawn] = false;
	g_iPlayerPreferences[iClient][PlayerPreference_ProjectedFlashlight] = false;
	
	g_iPlayerPageCount[iClient] = 0;
	g_iPlayerDesiredFOV[iClient] = 90;
	
	SDKHook(iClient, SDKHook_PreThink, Hook_ClientPreThink);
	SDKHook(iClient, SDKHook_SetTransmit, Hook_ClientSetTransmit);
	SDKHook(iClient, SDKHook_TraceAttack, Hook_PvPPlayerTraceAttack);
	SDKHook(iClient, SDKHook_OnTakeDamage, Hook_ClientOnTakeDamage);
	
	DHookEntity(g_hSDKWantsLagCompensationOnEntity, true, iClient); 
	DHookEntity(g_hSDKShouldTransmit, true, iClient);
	
	for (int i = 0; i < SF2_MAX_PLAYER_GROUPS; i++)
	{
		if (!IsPlayerGroupActive(i)) continue;
		
		SetPlayerGroupInvitedPlayer(i, iClient, false);
		SetPlayerGroupInvitedPlayerCount(i, iClient, 0);
		SetPlayerGroupInvitedPlayerTime(i, iClient, 0.0);
	}
	
	ClientDisableFakeLagCompensation(iClient);
	
	ClientResetStatic(iClient);
	ClientResetSlenderStats(iClient);
	ClientResetCampingStats(iClient);
	ClientResetOverlay(iClient);
	ClientResetJumpScare(iClient);
	ClientUpdateListeningFlags(iClient);
	ClientUpdateMusicSystem(iClient);
	ClientChaseMusicReset(iClient);
	ClientChaseMusicSeeReset(iClient);
	ClientAlertMusicReset(iClient);
	Client20DollarsMusicReset(iClient);
	ClientMusicReset(iClient);
	ClientResetProxy(iClient);
	ClientResetHints(iClient);
	ClientResetScare(iClient);
	
	ClientResetDeathCam(iClient);
	ClientResetFlashlight(iClient);
	ClientDeactivateUltravision(iClient);
	ClientResetSprint(iClient);
	ClientResetBreathing(iClient);
	ClientResetBlink(iClient);
	ClientResetInteractiveGlow(iClient);
	ClientDisableConstantGlow(iClient);
	
	ClientSetScareBoostEndTime(iClient, -1.0);
	
	ClientStartProxyAvailableTimer(iClient);
	
	if (!IsFakeClient(iClient))
	{
		// See if the player is using the projected flashlight.
		QueryClientConVar(iClient, "mat_supportflashlight", OnClientGetProjectedFlashlightSetting);
		
		// Get desired FOV.
		QueryClientConVar(iClient, "fov_desired", OnClientGetDesiredFOV);
	}
	
	PvP_OnClientPutInServer(iClient);
	
#if defined DEBUG
	g_iPlayerDebugFlags[iClient] = 0;

	if (GetConVarInt(g_cvDebugDetail) > 0) DebugMessage("END OnClientPutInServer(%d)", iClient);
#endif
}

public void OnClientGetProjectedFlashlightSetting(QueryCookie cookie,int iClient, ConVarQueryResult result, const char[] cvarName, const char[] cvarValue)
{
	if (result != ConVarQuery_Okay) 
	{
		LogError("Warning: Player %N failed to query for ConVar mat_supportflashlight", iClient);
		return;
	}
	
	if (StringToInt(cvarValue))
	{
		char sAuth[64];
		GetClientAuthId(iClient,AuthId_Engine, sAuth, sizeof(sAuth));
		
		g_iPlayerPreferences[iClient][PlayerPreference_ProjectedFlashlight] = true;
		LogSF2Message("Player %N (%s) has mat_supportflashlight enabled, projected flashlight will be used", iClient, sAuth);
	}
}

public void OnClientGetDesiredFOV(QueryCookie cookie,int iClient, ConVarQueryResult result, const char[] cvarName, const char[] cvarValue)
{
	if (!IsValidClient(iClient)) return;
	
	g_iPlayerDesiredFOV[iClient] = StringToInt(cvarValue);
}

public void OnClientDisconnect(int iClient)
{
	if (!g_bEnabled) return;
	
#if defined DEBUG
	if (GetConVarInt(g_cvDebugDetail) > 0) DebugMessage("START OnClientDisconnect(%d)", iClient);
#endif
	g_bSeeUpdateMenu[iClient] = false;
	g_bPlayerEscaped[iClient] = false;
	g_bAdminNoPoints[iClient] = false;
	
	// Save and reset settings for the next iClient.
	ClientSaveCookies(iClient);
	ClientSetPlayerGroup(iClient, -1);
	
	// Reset variables.
	g_iPlayerPreferences[iClient][PlayerPreference_ShowHints] = true;
	g_iPlayerPreferences[iClient][PlayerPreference_MuteMode] = MuteMode_Normal;
	g_iPlayerPreferences[iClient][PlayerPreference_FilmGrain] = true;
	g_iPlayerPreferences[iClient][PlayerPreference_EnableProxySelection] = true;
	g_iPlayerPreferences[iClient][PlayerPreference_ProjectedFlashlight] = false;
	
	// Reset any iClient functions that may be still active.
	ClientResetOverlay(iClient);
	ClientResetFlashlight(iClient);
	ClientDeactivateUltravision(iClient);
	ClientSetGhostModeState(iClient, false);
	ClientResetInteractiveGlow(iClient);
	ClientDisableConstantGlow(iClient);
	
	ClientStopProxyForce(iClient);
	
	if (!IsRoundInWarmup())
	{
		if (g_bPlayerPlaying[iClient] && !g_bPlayerEliminated[iClient])
		{
			if (g_bRoundGrace)
			{
				// Force the next player in queue to take my place, if any.
				ForceInNextPlayersInQueue(1, true);
			}
			else
			{
				if (!IsRoundEnding()) 
				{
					CreateTimer(0.2, Timer_CheckRoundWinConditions, _, TIMER_FLAG_NO_MAPCHANGE);
				}
			}
		}
	}
	
	// Reset queue points global variable.
	g_iPlayerQueuePoints[iClient] = 0;
	
	PvP_OnClientDisconnect(iClient);
	
#if defined DEBUG
	if (GetConVarInt(g_cvDebugDetail) > 0) DebugMessage("END OnClientDisconnect(%d)", iClient);
#endif
}

public void OnClientDisconnect_Post(int iClient)
{
    g_iPlayerLastButtons[iClient] = 0;
}

public void TF2_OnWaitingForPlayersStart()
{
	g_bRoundWaitingForPlayers = true;
}

public void TF2_OnWaitingForPlayersEnd()
{
	g_bRoundWaitingForPlayers = false;
}

SF2RoundState GetRoundState()
{
	return g_iRoundState;
}

void SetRoundState(SF2RoundState iRoundState)
{
	if (g_iRoundState == iRoundState) return;
	
	PrintToServer("SetRoundState(%d)", iRoundState);
	
	SF2RoundState iOldRoundState = GetRoundState();
	g_iRoundState = iRoundState;
	
	// Cleanup from old roundstate if needed.
	switch (iOldRoundState)
	{
		case SF2RoundState_Waiting:
		{
		}
		case SF2RoundState_Intro:
		{
			g_hRoundIntroTimer = INVALID_HANDLE;
		}
		case SF2RoundState_Active:
		{
			g_bRoundGrace = false;
			g_hRoundGraceTimer = INVALID_HANDLE;
			g_hRoundTimer = INVALID_HANDLE;
		}
		case SF2RoundState_Escape:
		{
			g_hRoundTimer = INVALID_HANDLE;
		}
		case SF2RoundState_Outro:
		{
		}
	}
	
	switch (g_iRoundState)
	{
		case SF2RoundState_Waiting:
		{
		}
		case SF2RoundState_Intro:
		{
			g_hRoundIntroTimer = INVALID_HANDLE;
			g_iRoundIntroText = 0;
			g_bRoundIntroTextDefault = false;
			g_hRoundIntroTextTimer = CreateTimer(0.0, Timer_IntroTextSequence, _, TIMER_FLAG_NO_MAPCHANGE);
			TriggerTimer(g_hRoundIntroTextTimer);
			
			// Gather data on the intro parameters set by the map.
			float flHoldTime = g_flRoundIntroFadeHoldTime;
			g_hRoundIntroTimer = CreateTimer(flHoldTime, Timer_ActivateRoundFromIntro, _, TIMER_FLAG_NO_MAPCHANGE);
			
			// Trigger any intro logic entities, if any.
			int ent = -1;
			while ((ent = FindEntityByClassname(ent, "logic_relay")) != -1)
			{
				char sName[64];
				GetEntPropString(ent, Prop_Data, "m_iName", sName, sizeof(sName));
				if (StrEqual(sName, "sf2_intro_relay", false))
				{
					AcceptEntityInput(ent, "Trigger");
					break;
				}
			}
		}
		case SF2RoundState_Active:
		{
			// Start the grace period timer.
			g_bRoundGrace = true;
			g_hRoundGraceTimer = CreateTimer(GetConVarFloat(g_cvGraceTime), Timer_RoundGrace, _, TIMER_FLAG_NO_MAPCHANGE);
			
			CreateTimer(2.0, Timer_RoundStart, _, TIMER_FLAG_NO_MAPCHANGE);
			
			// Enable movement on players.
			for (int i = 1; i <= MaxClients; i++)
			{
				if (!IsClientInGame(i) || g_bPlayerEliminated[i]) continue;
				SetEntityFlags(i, GetEntityFlags(i) & ~FL_FROZEN);
				TF2Attrib_SetByDefIndex(i, 10, 7.0);
			}
			
			// Fade in.
			float flFadeTime = g_flRoundIntroFadeDuration;
			int iFadeFlags = SF_FADE_IN | FFADE_PURGE;
			
			for (int i = 1; i <= MaxClients; i++)
			{
				if (!IsClientInGame(i) || g_bPlayerEliminated[i]) continue;
				UTIL_ScreenFade(i, FixedUnsigned16(flFadeTime, 1 << 12), 0, iFadeFlags, g_iRoundIntroFadeColor[0], g_iRoundIntroFadeColor[1], g_iRoundIntroFadeColor[2], g_iRoundIntroFadeColor[3]);
			}
		}
		case SF2RoundState_Escape:
		{
			// Initialize the escape timer, if needed.
			if (g_iRoundEscapeTimeLimit > 0)
			{
				g_iRoundTime = g_iRoundEscapeTimeLimit;
				g_hRoundTimer = CreateTimer(1.0, Timer_RoundTimeEscape, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
			}
			else
			{
				g_hRoundTimer = INVALID_HANDLE;
			}
		
			char sName[32];
			int ent = -1;
			while ((ent = FindEntityByClassname(ent, "info_target")) != -1)
			{
				GetEntPropString(ent, Prop_Data, "m_iName", sName, sizeof(sName));
				if (StrEqual(sName, "sf2_logic_escape", false))
				{
					AcceptEntityInput(ent, "FireUser1");
					break;
				}
			}
		}
		case SF2RoundState_Outro:
		{
			if (!g_bRoundHasEscapeObjective)
			{
				// Teleport winning players to the escape point.
				for (int i = 1; i <= MaxClients; i++)
				{
					if (!IsClientInGame(i)) continue;
					
					if (!g_bPlayerEliminated[i])
					{
						TeleportClientToEscapePoint(i);
					}
				}
			}
			
			for (int i = 1; i <= MaxClients; i++)
			{
				if (!IsClientInGame(i)) continue;
				
				if (IsClientInGhostMode(i))
				{
					// Take the player out of ghost mode.
					ClientSetGhostModeState(i, false);	
					TF2_RespawnPlayer(i);
				}
				else if (g_bPlayerProxy[i])
				{
					TF2_RespawnPlayer(i);
				}
				
				if (!g_bPlayerEliminated[i])
				{
					// Give them back all their weapons so they can beat the crap out of the other team.
					TF2_RegeneratePlayer(i);
				}
				
				ClientUpdateListeningFlags(i);
			}
		}
	}
}

bool IsRoundInEscapeObjective()
{
	return view_as<bool>(GetRoundState() == SF2RoundState_Escape);
}

bool IsRoundInWarmup()
{
	return view_as<bool>(GetRoundState() == SF2RoundState_Waiting);
}

bool IsRoundInIntro()
{
	return view_as<bool>(GetRoundState() == SF2RoundState_Intro);
}

bool IsRoundEnding()
{
	return view_as<bool>(GetRoundState() == SF2RoundState_Outro);
}

bool IsInfiniteBlinkEnabled()
{
	return view_as<bool>(g_bRoundInfiniteBlink || (GetConVarInt(g_cvPlayerInfiniteBlinkOverride) == 1));
}

bool IsInfiniteSprintEnabled()
{
	return view_as<bool>(g_bRoundInfiniteSprint || (GetConVarInt(g_cvPlayerInfiniteSprintOverride) == 1));
}
#define SF2_PLAYER_HUD_BLINK_SYMBOL "B"
#define SF2_PLAYER_HUD_FLASHLIGHT_SYMBOL "ϟ"
#define SF2_PLAYER_HUD_BAR_SYMBOL "|"
#define SF2_PLAYER_HUD_BAR_MISSING_SYMBOL ""
#define SF2_PLAYER_HUD_INFINITY_SYMBOL "∞"
#define SF2_PLAYER_HUD_SPRINT_SYMBOL "»"

public Action Timer_ClientAverageUpdate(Handle timer)
{
	if (timer != g_hClientAverageUpdateTimer) return Plugin_Stop;
	
	if (!g_bEnabled) return Plugin_Stop;
	
	if (IsRoundInWarmup() || IsRoundEnding()) return Plugin_Continue;
	
	// First, process through HUD stuff.
	char buffer[256];
	
	static iHudColorHealthy[3] = { 150, 255, 150 };
	static iHudColorCritical[3] = { 255, 10, 10 };
	
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i)) continue;
		
		if (IsPlayerAlive(i) && !IsClientInDeathCam(i))
		{
			if (!g_bPlayerEliminated[i])
			{
				if (DidClientEscape(i)) continue;
				
				int iMaxBars = 12;
				int iBars;
				if(!SF_IsRaidMap())
				{
					iBars = RoundToCeil(float(iMaxBars) * ClientGetBlinkMeter(i));
					if (iBars > iMaxBars) iBars = iMaxBars;
					
					Format(buffer, sizeof(buffer), "%s  ", SF2_PLAYER_HUD_BLINK_SYMBOL);
					
					if (IsInfiniteBlinkEnabled())
					{
						StrCat(buffer, sizeof(buffer), SF2_PLAYER_HUD_INFINITY_SYMBOL);
					}
					else
					{
						for (int i2 = 0; i2 < iMaxBars; i2++) 
						{
							if (i2 < iBars)
							{
								StrCat(buffer, sizeof(buffer), SF2_PLAYER_HUD_BAR_SYMBOL);
							}
							else
							{
								StrCat(buffer, sizeof(buffer), SF2_PLAYER_HUD_BAR_MISSING_SYMBOL);
							}
						}
					}
				}
				if (!SF_SpecialRound(SPECIALROUND_LIGHTSOUT) && !SF_SpecialRound(SPECIALROUND_NIGHTVISION) && !GetConVarBool(g_cvNightvisionEnabled))
				{
					iBars = RoundToCeil(float(iMaxBars) * ClientGetFlashlightBatteryLife(i));
					if (iBars > iMaxBars) iBars = iMaxBars;
					
					char sBuffer2[64];
					Format(sBuffer2, sizeof(sBuffer2), "\n%s  ", SF2_PLAYER_HUD_FLASHLIGHT_SYMBOL);
					StrCat(buffer, sizeof(buffer), sBuffer2);
					
					if (IsInfiniteFlashlightEnabled())
					{
						StrCat(buffer, sizeof(buffer), SF2_PLAYER_HUD_INFINITY_SYMBOL);
					}
					else
					{
						for (int i2 = 0; i2 < iMaxBars; i2++) 
						{
							if (i2 < iBars)
							{
								StrCat(buffer, sizeof(buffer), SF2_PLAYER_HUD_BAR_SYMBOL);
							}
							else
							{
								StrCat(buffer, sizeof(buffer), SF2_PLAYER_HUD_BAR_MISSING_SYMBOL);
							}
						}
					}
				}
				
				iBars = RoundToCeil(float(iMaxBars) * (float(ClientGetSprintPoints(i)) / 100.0));
				if (iBars > iMaxBars) iBars = iMaxBars;
				
				char sBuffer2[64];
				Format(sBuffer2, sizeof(sBuffer2), "\n%s  ", SF2_PLAYER_HUD_SPRINT_SYMBOL);
				StrCat(buffer, sizeof(buffer), sBuffer2);
				
				if (IsInfiniteSprintEnabled())
				{
					StrCat(buffer, sizeof(buffer), SF2_PLAYER_HUD_INFINITY_SYMBOL);
				}
				else
				{
					for (int i2 = 0; i2 < iMaxBars; i2++) 
					{
						if (i2 < iBars)
						{
							StrCat(buffer, sizeof(buffer), SF2_PLAYER_HUD_BAR_SYMBOL);
						}
						else
						{
							StrCat(buffer, sizeof(buffer), SF2_PLAYER_HUD_BAR_MISSING_SYMBOL);
						}
					}
				}
				
				
				float flHealthRatio = float(GetEntProp(i, Prop_Send, "m_iHealth")) / float(SDKCall(g_hSDKGetMaxHealth, i));
				
				int iColor[3];
				for (int i2 = 0; i2 < 3; i2++)
				{
					iColor[i2] = RoundFloat(float(iHudColorHealthy[i2]) + (float(iHudColorCritical[i2] - iHudColorHealthy[i2]) * (1.0 - flHealthRatio)));
				}
				if(!SF_IsRaidMap())
				{
					SetHudTextParams(0.035, 0.83,
						0.3,
						iColor[0],
						iColor[1],
						iColor[2],
						40,
						_,
						1.0,
						0.07,
						0.5);
				}
				else
				{
					SetHudTextParams(0.035, 0.43,
						0.3,
						iColor[0],
						iColor[1],
						iColor[2],
						40,
						_,
						1.0,
						0.07,
						0.5);
				}
				ShowSyncHudText(i, g_hHudSync2, buffer);
				Format(buffer, sizeof(buffer), "");
			}
			else
			{
				if (g_bPlayerProxy[i])
				{
					int iMaxBars = 12;
					int iBars = RoundToCeil(float(iMaxBars) * (float(g_iPlayerProxyControl[i]) / 100.0));
					if (iBars > iMaxBars) iBars = iMaxBars;
					
					strcopy(buffer, sizeof(buffer), "CONTROL\n");
					
					for (int i2 = 0; i2 < iBars; i2++)
					{
						StrCat(buffer, sizeof(buffer), SF2_PLAYER_HUD_BAR_SYMBOL);
					}

					SetHudTextParams(-1.0, 0.83,
						0.3,
						SF2_HUD_TEXT_COLOR_R,
						SF2_HUD_TEXT_COLOR_G,
						SF2_HUD_TEXT_COLOR_B,
						40,
						_,
						1.0,
						0.07,
						0.5);
					ShowSyncHudText(i, g_hHudSync2, buffer);
				}
			}
		}
		ClientUpdateListeningFlags(i);
		ClientUpdateMusicSystem(i);
	}
	
	return Plugin_Continue;
}

stock bool IsClientParticipating(int iClient)
{
	if (!IsValidClient(iClient)) return false;
	
	if (view_as<bool>(GetEntProp(iClient, Prop_Send, "m_bIsCoaching"))) 
	{
		// Who would coach in this game?
		return false;
	}
	
	int iTeam = GetClientTeam(iClient);
	
	if (g_bPlayerLagCompensation[iClient]) 
	{
		iTeam = g_iPlayerLagCompensationTeam[iClient];
	}
	
	switch (iTeam)
	{
		case TFTeam_Unassigned, TFTeam_Spectator: return false;
	}
	
	if (view_as<int>(TF2_GetPlayerClass(iClient)) == 0)
	{
		// Player hasn't chosen a class? What.
		return false;
	}
	
	return true;
}

Handle GetQueueList()
{
	Handle hArray = CreateArray(3);
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientParticipating(i)) continue;
		if (IsPlayerGroupActive(ClientGetPlayerGroup(i))) continue;
		
		int index = PushArrayCell(hArray, i);
		SetArrayCell(hArray, index, g_iPlayerQueuePoints[i], 1);
		SetArrayCell(hArray, index, false, 2);
	}
	
	for (int i = 0; i < SF2_MAX_PLAYER_GROUPS; i++)
	{
		if (!IsPlayerGroupActive(i)) continue;
		int index = PushArrayCell(hArray, i);
		SetArrayCell(hArray, index, GetPlayerGroupQueuePoints(i), 1);
		SetArrayCell(hArray, index, true, 2);
	}
	
	if (GetArraySize(hArray)) SortADTArrayCustom(hArray, SortQueueList);
	return hArray;
}

void SetClientPlayState(int iClient, bool bState, bool bEnablePlay=true)
{
	if (bState)
	{
		if (!g_bPlayerEliminated[iClient]) return;
		
		g_bPlayerEliminated[iClient] = false;
		g_bPlayerPlaying[iClient] = bEnablePlay;
		g_hPlayerSwitchBlueTimer[iClient] = INVALID_HANDLE;
		
		ClientSetGhostModeState(iClient, false);
		
		PvP_SetPlayerPvPState(iClient, false, false, false);
		
		if (g_bSpecialRound) 
		{
			SetClientPlaySpecialRoundState(iClient, true);
		}
		
		if (g_bNewBossRound) 
		{
			SetClientPlayintBossRoundState(iClient, true);
		}
		
		if (TF2_GetPlayerClass(iClient) == view_as<TFClassType>(0))
		{
			// Player hasn't chosen a class for some reason. Choose one for him.
			TF2_SetPlayerClass(iClient, view_as<TFClassType>(GetRandomInt(1, 9)), true, true);
		}
		
		ChangeClientTeamNoSuicide(iClient, TFTeam_Red);
	}
	else
	{
		if (g_bPlayerEliminated[iClient]) return;
		
		g_bPlayerEliminated[iClient] = true;
		g_bPlayerPlaying[iClient] = false;
		
		ChangeClientTeamNoSuicide(iClient, TFTeam_Blue);
	}
}

bool DidClientPlayintBossRound(int iClient)
{
	return g_bPlayerPlayedNewBossRound[iClient];
}

void SetClientPlayintBossRoundState(int iClient, bool bState)
{
	g_bPlayerPlayedNewBossRound[iClient] = bState;
}

bool DidClientPlaySpecialRound(int iClient)
{
	return g_bPlayerPlayedNewBossRound[iClient];
}

void SetClientPlaySpecialRoundState(int iClient, bool bState)
{
	g_bPlayerPlayedSpecialRound[iClient] = bState;
}

void TeleportClientToEscapePoint(int iClient)
{
	if (!IsClientInGame(iClient)) return;
	
	int ent = EntRefToEntIndex(g_iRoundEscapePointEntity);
	if (ent && ent != -1)
	{
		float flPos[3], flAng[3];
		GetEntPropVector(ent, Prop_Data, "m_vecAbsOrigin", flPos);
		GetEntPropVector(ent, Prop_Data, "m_angAbsRotation", flAng);
		
		TeleportEntity(iClient, flPos, flAng, view_as<float>({ 0.0, 0.0, 0.0 }));
		AcceptEntityInput(ent, "FireUser1", iClient);
	}
}

void ForceInNextPlayersInQueue(int iAmount, bool bShowMessage=false)
{
	// Grab the next person in line, or the next group in line if space allows.
	int iAmountLeft = iAmount;
	Handle hPlayers = CreateArray();
	Handle hArray = GetQueueList();
	
	for (int i = 0, iSize = GetArraySize(hArray); i < iSize && iAmountLeft > 0; i++)
	{
		if (!GetArrayCell(hArray, i, 2))
		{
			int iClient = GetArrayCell(hArray, i);
			if (g_bPlayerPlaying[iClient] || !g_bPlayerEliminated[iClient] || !IsClientParticipating(iClient) || g_bAdminNoPoints[iClient]) continue;
			
			PushArrayCell(hPlayers, iClient);
			iAmountLeft-=1;
		}
		else
		{
			int iGroupIndex = GetArrayCell(hArray, i);
			if (!IsPlayerGroupActive(iGroupIndex)) continue;
			
			int iMemberCount = GetPlayerGroupMemberCount(iGroupIndex);
			if (iMemberCount <= iAmountLeft)
			{
				for (int iClient = 1; iClient <= MaxClients; iClient++)
				{
					if (!IsValidClient(iClient) || g_bPlayerPlaying[iClient] || !g_bPlayerEliminated[iClient] || !IsClientParticipating(iClient)) continue;
					if (ClientGetPlayerGroup(iClient) == iGroupIndex)
					{
						PushArrayCell(hPlayers, iClient);
					}
				}
				
				SetPlayerGroupPlaying(iGroupIndex, true);
				
				iAmountLeft -= iMemberCount;
			}
		}
	}
	
	CloseHandle(hArray);
	
	for (int i = 0, iSize = GetArraySize(hPlayers); i < iSize; i++)
	{
		int iClient = GetArrayCell(hPlayers, i);
		ClientSetQueuePoints(iClient, 0);
		SetClientPlayState(iClient, true);
		
		if (bShowMessage) CPrintToChat(iClient, "%T", "SF2 Force Play", iClient);
	}
	
	CloseHandle(hPlayers);
}

public int SortQueueList(int index1,int index2, Handle array, Handle hndl)
{
	int iQueuePoints1 = GetArrayCell(array, index1, 1);
	int iQueuePoints2 = GetArrayCell(array, index2, 1);
	
	if (iQueuePoints1 > iQueuePoints2) return -1;
	else if (iQueuePoints1 == iQueuePoints2) return 0;
	return 1;
}

//	==========================================================
//	GENERIC PAGE/BOSS HOOKS AND FUNCTIONS
//	==========================================================

public Action Hook_SlenderObjectSetTransmit(int ent,int other)
{
	if (!g_bEnabled) return Plugin_Continue;
	
	if (!IsPlayerAlive(other) || IsClientInDeathCam(other))
	{
		if (!IsValidEdict(GetEntPropEnt(other, Prop_Send, "m_hObserverTarget"))) return Plugin_Handled;
	}
	if (IsClientInGhostMode(other)) return Plugin_Handled;
	
	return Plugin_Continue;
}
public Action Hook_SlenderObjectSetTransmitEx(int ent,int other)
{
	if (!g_bEnabled) return Plugin_Continue;
	
	if (!IsPlayerAlive(other) || IsClientInDeathCam(other))
	{
		if (!IsValidEdict(GetEntPropEnt(other, Prop_Send, "m_hObserverTarget"))) return Plugin_Handled;
	}
	if (IsClientInGhostMode(other)) return Plugin_Handled;
	if (IsValidClient(other))
	{
		if(ClientGetDistanceFromEntity(other,ent)<=320)
			return Plugin_Handled;
	}
	
	return Plugin_Continue;
}

public Action Timer_SlenderBlinkBossThink(Handle timer, any entref)
{
	int slender = EntRefToEntIndex(entref);
	if (!slender || slender == INVALID_ENT_REFERENCE) return Plugin_Stop;
	
	int iBossIndex = NPCGetFromEntIndex(slender);
	if (iBossIndex == -1) return Plugin_Stop;
	
	if (timer != g_hSlenderEntityThink[iBossIndex]) return Plugin_Stop;
	
	char sProfile[SF2_MAX_PROFILE_NAME_LENGTH];
	NPCGetProfile(iBossIndex, sProfile, sizeof(sProfile));
	
	if (NPCGetType(iBossIndex) == SF2BossType_Creeper)
	{
		bool bMove = false;
		
		if ((GetGameTime() - g_flSlenderLastKill[iBossIndex]) >= GetProfileFloat(sProfile, "kill_cooldown"))
		{
			if (PeopleCanSeeSlender(iBossIndex, false, false) && !PeopleCanSeeSlender(iBossIndex, true, SlenderUsesBlink(iBossIndex)))
			{
				int iBestPlayer = -1;
				Handle hArray = CreateArray();
				
				for (int i = 1; i <= MaxClients; i++)
				{
					if (!IsClientInGame(i) || !IsPlayerAlive(i) || IsClientInDeathCam(i) || g_bPlayerEliminated[i] || DidClientEscape(i) || IsClientInGhostMode(i) || !PlayerCanSeeSlender(i, iBossIndex, false, false)) continue;
					PushArrayCell(hArray, i);
				}
				
				if (GetArraySize(hArray))
				{
					float flSlenderPos[3];
					SlenderGetAbsOrigin(iBossIndex, flSlenderPos);
					
					float flTempPos[3];
					int iTempPlayer = -1;
					float flTempDist = 16384.0;
					for (int i = 0; i < GetArraySize(hArray); i++)
					{
						int iClient = GetArrayCell(hArray, i);
						GetClientAbsOrigin(iClient, flTempPos);
						if (GetVectorDistance(flTempPos, flSlenderPos) < flTempDist)
						{
							iTempPlayer = iClient;
							flTempDist = GetVectorDistance(flTempPos, flSlenderPos);
						}
					}
					
					iBestPlayer = iTempPlayer;
				}
				
				CloseHandle(hArray);
				
				float buffer[3];
				if (iBestPlayer != -1 && SlenderCalculateApproachToPlayer(iBossIndex, iBestPlayer, buffer))
				{
					bMove = true;
					
					float flAng[3], flBuffer[3];
					float flSlenderPos[3], flPos[3];
					GetEntPropVector(slender, Prop_Data, "m_vecAbsOrigin", flSlenderPos);
					GetClientAbsOrigin(iBestPlayer, flPos);
					SubtractVectors(flPos, buffer, flAng);
					GetVectorAngles(flAng, flAng);
					
					// Take care of angle offsets.
					AddVectors(flAng, g_flSlenderEyeAngOffset[iBossIndex], flAng);
					for (int i = 0; i < 3; i++) flAng[i] = AngleNormalize(flAng[i]);
					
					flAng[0] = 0.0;
					
					// Take care of position offsets.
					GetProfileVector(sProfile, "pos_offset", flBuffer);
					AddVectors(buffer, flBuffer, buffer);

					DispatchKeyValueVector(slender, "origin", buffer);
					DispatchKeyValueVector(slender, "angles", flAng);
					
					float flMaxRange = GetProfileFloat(sProfile, "teleport_range_max");
					float flDist = GetVectorDistance(buffer, flPos);
					
					char sBuffer[PLATFORM_MAX_PATH];
					
					if (flDist < (flMaxRange * 0.33)) 
					{
						GetProfileString(sProfile, "model_closedist", sBuffer, sizeof(sBuffer));
					}
					else if (flDist < (flMaxRange * 0.66)) 
					{
						GetProfileString(sProfile, "model_averagedist", sBuffer, sizeof(sBuffer));
					}
					else 
					{
						GetProfileString(sProfile, "model", sBuffer, sizeof(sBuffer));
					}
					
					// Fallback if error.
					if (!sBuffer[0]) GetProfileString(sProfile, "model", sBuffer, sizeof(sBuffer));
					
					SetEntProp(slender, Prop_Send, "m_nModelIndex", PrecacheModel(sBuffer));
					
					if (flDist <= NPCGetInstantKillRadius(iBossIndex))
					{
						if (NPCGetFlags(iBossIndex) & SFF_FAKE)
						{
							SlenderMarkAsFake(iBossIndex);
							return Plugin_Stop;
						}
						else
						{
							g_flSlenderLastKill[iBossIndex] = GetGameTime();
							ClientStartDeathCam(iBestPlayer, iBossIndex, buffer);
						}
					}
				}
			}
		}
		
		if (bMove)
		{
			char sBuffer[PLATFORM_MAX_PATH];
			GetRandomStringFromProfile(sProfile, "sound_move_single", sBuffer, sizeof(sBuffer));
			if (sBuffer[0]) EmitSoundToAll(sBuffer, slender, SNDCHAN_AUTO, SNDLEVEL_SCREAMING);
			
			GetRandomStringFromProfile(sProfile, "sound_move", sBuffer, sizeof(sBuffer), 1);
			if (sBuffer[0]) EmitSoundToAll(sBuffer, slender, SNDCHAN_AUTO, SNDLEVEL_SCREAMING, SND_CHANGEVOL);
		}
		else
		{
			char sBuffer[PLATFORM_MAX_PATH];
			GetRandomStringFromProfile(sProfile, "sound_move", sBuffer, sizeof(sBuffer), 1);
			if (sBuffer[0]) StopSound(slender, SNDCHAN_AUTO, sBuffer);
		}
	}
	
	return Plugin_Continue;
}


void SlenderOnClientStressUpdate(int iClient)
{
	float flStress = g_flPlayerStress[iClient];
	
	char sProfile[SF2_MAX_PROFILE_NAME_LENGTH];
	
	for (int iBossIndex = 0; iBossIndex < MAX_BOSSES; iBossIndex++)
	{	
		if (NPCGetUniqueID(iBossIndex) == -1) continue;
		
		int iBossFlags = NPCGetFlags(iBossIndex);
		if (iBossFlags & SFF_MARKEDASFAKE ||
			iBossFlags & SFF_NOTELEPORT)
		{
			continue;
		}
		
		NPCGetProfile(iBossIndex, sProfile, sizeof(sProfile));
		
		int iTeleportTarget = EntRefToEntIndex(g_iSlenderTeleportTarget[iBossIndex]);
		if (iTeleportTarget && iTeleportTarget != INVALID_ENT_REFERENCE)
		{
			if (g_bPlayerEliminated[iTeleportTarget] ||
				DidClientEscape(iTeleportTarget) ||
				flStress >= g_flSlenderTeleportMaxTargetStress[iBossIndex] ||
				GetGameTime() >= g_flSlenderTeleportMaxTargetTime[iBossIndex])
			{
				// Queue for a int target and mark the old target in the rest period.
				float flRestPeriod = GetProfileFloat(sProfile, "teleport_target_rest_period", 15.0);
				flRestPeriod = (flRestPeriod * GetRandomFloat(0.92, 1.08)) / (NPCGetAnger(iBossIndex) * g_flRoundDifficultyModifier);
				
				g_iSlenderTeleportTarget[iBossIndex] = INVALID_ENT_REFERENCE;
				g_flSlenderTeleportPlayersRestTime[iBossIndex][iTeleportTarget] = GetGameTime() + flRestPeriod;
				g_flSlenderTeleportMaxTargetStress[iBossIndex] = 9999.0;
				g_flSlenderTeleportMaxTargetTime[iBossIndex] = -1.0;
				g_flSlenderTeleportTargetTime[iBossIndex] = -1.0;
				
#if defined DEBUG
				SendDebugMessageToPlayers(DEBUG_BOSS_TELEPORTATION, 0, "Teleport for boss %d: lost target, putting at rest period", iBossIndex);
#endif
			}
		}
		else if (!g_bRoundGrace)
		{
			bool bRaidTeleport = view_as<bool>(GetProfileNum(sProfile, "experimental_raid_teleport", 0));
			int iPreferredTeleportTarget = INVALID_ENT_REFERENCE;
			
			float flTargetStressMin = GetProfileFloat(sProfile, "teleport_target_stress_min", 0.2);
			float flTargetStressMax = GetProfileFloat(sProfile, "teleport_target_stress_max", 0.9);
			
			float flTargetStress = flTargetStressMax - ((flTargetStressMax - flTargetStressMin) / (g_flRoundDifficultyModifier * NPCGetAnger(iBossIndex)));
			
			float flPreferredTeleportTargetStress = flTargetStress;
			
			Handle hArrayRaidTargets = CreateArray();
			
			for (int i = 1; i <= MaxClients; i++)
			{
				if (!IsClientInGame(i) ||
					!IsPlayerAlive(i) ||
					g_bPlayerEliminated[i] ||
					IsClientInGhostMode(i) ||
					DidClientEscape(i))
				{
					continue;
				}
				if(bRaidTeleport)
				{
					if (g_flSlenderTeleportPlayersRestTime[iBossIndex][i] <= GetGameTime())
					{
						PushArrayCell(hArrayRaidTargets, i);
					}
				}
				if (g_flPlayerStress[i] < flPreferredTeleportTargetStress)
				{
					if (g_flSlenderTeleportPlayersRestTime[iBossIndex][i] <= GetGameTime())
					{
						iPreferredTeleportTarget = i;
						flPreferredTeleportTargetStress = g_flPlayerStress[i];
					}
				}
				if (g_bPlayerIsExitCamping[i])
				{
					if((iTeleportTarget != INVALID_ENT_REFERENCE && g_bPlayerEliminated[iTeleportTarget]) || (iTeleportTarget != INVALID_ENT_REFERENCE && !g_bPlayerIsExitCamping[iTeleportTarget]))
					{
						iPreferredTeleportTarget = i;
						break;
					}
				}
			}
			if(bRaidTeleport)
			{
				if(GetArraySize(hArrayRaidTargets)>0)
				{
					iPreferredTeleportTarget = GetArrayCell(hArrayRaidTargets,GetRandomInt(0, GetArraySize(hArrayRaidTargets) - 1));
				}
			}
			CloseHandle(hArrayRaidTargets);
			if (iPreferredTeleportTarget && iPreferredTeleportTarget != INVALID_ENT_REFERENCE)
			{
				// Set our preferred target to the int guy.
				float flTargetDuration = GetProfileFloat(sProfile, "teleport_target_persistency_period", 13.0);
				float flDeviation = GetRandomFloat(0.92, 1.08);
				flTargetDuration = Pow(flDeviation * flTargetDuration, ((g_flRoundDifficultyModifier * (NPCGetAnger(iBossIndex) - 1.0)) / 2.0)) + ((flDeviation * flTargetDuration) - 1.0);
				
				g_iSlenderTeleportTarget[iBossIndex] = EntIndexToEntRef(iPreferredTeleportTarget);
				g_flSlenderTeleportPlayersRestTime[iBossIndex][iPreferredTeleportTarget] = -1.0;
				g_flSlenderTeleportMaxTargetTime[iBossIndex] = GetGameTime() + flTargetDuration;
				g_flSlenderTeleportTargetTime[iBossIndex] = GetGameTime();
				g_flSlenderTeleportMaxTargetStress[iBossIndex] = flTargetStress;
				if(g_bPlayerIsExitCamping[iPreferredTeleportTarget])
				{
					g_bSlenderTeleportTargetIsCamping[iBossIndex]=true;
				}
				else
					g_bSlenderTeleportTargetIsCamping[iBossIndex]=false;
				
				iTeleportTarget = iPreferredTeleportTarget;
				
#if defined DEBUG
				SendDebugMessageToPlayers(DEBUG_BOSS_TELEPORTATION, 0, "Teleport for boss %d: got int target %N", iBossIndex, iPreferredTeleportTarget);
#endif
			}
		}
	}
}

static int GetPageMusicRanges()
{
	ClearArray(g_hPageMusicRanges);
	
	char sName[64];
	
	int ent = -1;
	while ((ent = FindEntityByClassname(ent, "ambient_generic")) != -1)
	{
		GetEntPropString(ent, Prop_Data, "m_iName", sName, sizeof(sName));
		
		if (sName[0] && !StrContains(sName, "sf2_page_music_", false))
		{
			ReplaceString(sName, sizeof(sName), "sf2_page_music_", "", false);
			
			char sPageRanges[2][32];
			ExplodeString(sName, "-", sPageRanges, 2, 32);
			
			int iIndex = PushArrayCell(g_hPageMusicRanges, EntIndexToEntRef(ent));
			if (iIndex != -1)
			{
				int iMin = StringToInt(sPageRanges[0]);
				int iMax = StringToInt(sPageRanges[1]);
				
#if defined DEBUG
				DebugMessage("Page range found: entity %d, iMin = %d, iMax = %d", ent, iMin, iMax);
#endif
				SetArrayCell(g_hPageMusicRanges, iIndex, iMin, 1);
				SetArrayCell(g_hPageMusicRanges, iIndex, iMax, 2);
			}
		}
	}
	
	// precache
	if (GetArraySize(g_hPageMusicRanges) > 0)
	{
		char sPath[PLATFORM_MAX_PATH];
		
		for (int i = 0; i < GetArraySize(g_hPageMusicRanges); i++)
		{
			ent = EntRefToEntIndex(GetArrayCell(g_hPageMusicRanges, i));
			if (!ent || ent == INVALID_ENT_REFERENCE) continue;
			
			GetEntPropString(ent, Prop_Data, "m_iszSound", sPath, sizeof(sPath));
			if (sPath[0])
			{
				PrecacheSound(sPath);
			}
		}
	}
	
	LogSF2Message("Loaded page music ranges successfully!");
}
void SetPageCount(int iNum)
{
	if (iNum > g_iPageMax) iNum = g_iPageMax;
	
	int iOldPageCount = g_iPageCount;
	g_iPageCount = iNum;
	
	if (g_iPageCount != iOldPageCount)
	{
		if (g_iPageCount > iOldPageCount)
		{
			if (g_hRoundGraceTimer != INVALID_HANDLE) 
			{
				TriggerTimer(g_hRoundGraceTimer);
			}
			if(!SF_SpecialRound(SPECIALROUND_NOPAGEBONUS))
				g_iRoundTime += g_iRoundTimeGainFromPage;
			if (g_iRoundTime > g_iRoundTimeLimit) g_iRoundTime = g_iRoundTimeLimit;
			
			// Increase anger on selected bosses.
			for (int i = 0; i < MAX_BOSSES; i++)
			{
				if (NPCGetUniqueID(i) == -1) continue;
				
				float flPageDiff = NPCGetAngerAddOnPageGrabTimeDiff(i);
				if (flPageDiff >= 0.0)
				{
					int iDiff = g_iPageCount - iOldPageCount;
					if ((GetGameTime() - g_flPageFoundLastTime) < flPageDiff)
					{
						NPCAddAnger(i, NPCGetAngerAddOnPageGrab(i) * float(iDiff));
					}
				}
			}
			
			g_flPageFoundLastTime = GetGameTime();
		}
		
		// Notify logic entities.
		char sTargetName[64];
		char sFindTargetName[64];
		Format(sFindTargetName, sizeof(sFindTargetName), "sf2_onpagecount_%d", g_iPageCount);
		
		int ent = -1;
		while ((ent = FindEntityByClassname(ent, "logic_relay")) != -1)
		{
			GetEntPropString(ent, Prop_Data, "m_iName", sTargetName, sizeof(sTargetName));
			if (sTargetName[0] && StrEqual(sTargetName, sFindTargetName, false))
			{
				AcceptEntityInput(ent, "Trigger");
				break;
			}
		}
	
		int iClients[MAXPLAYERS + 1] = { -1, ... };
		int iClientsNum = 0;
		
		for (int i = 1; i <= MaxClients; i++)
		{
			if (!IsClientInGame(i)) continue;
			if (!g_bPlayerEliminated[i] || IsClientInGhostMode(i))
			{
				if (g_iPageCount)
				{
					iClients[iClientsNum] = i;
					iClientsNum++;
				}
			}
		}
		
		if (g_iPageCount > 0 && g_bRoundHasEscapeObjective && g_iPageCount == g_iPageMax)
		{
			// Escape initialized!
			SetRoundState(SF2RoundState_Escape);
			
			if (iClientsNum)
			{
				int iGameTextEscape = GetTextEntity("sf2_escape_message", false);
				if (iGameTextEscape != -1)
				{
					// Custom escape message.
					char sMessage[512];
					GetEntPropString(iGameTextEscape, Prop_Data, "m_iszMessage", sMessage, sizeof(sMessage));
					ShowHudTextUsingTextEntity(iClients, iClientsNum, iGameTextEscape, g_hHudSync, sMessage);
				}
				else
				{
					// Default escape message.
					for (int i = 0; i < iClientsNum; i++)
					{
						int iClient = iClients[i];
						ClientShowMainMessage(iClient, "%d/%d\n%T", g_iPageCount, g_iPageMax, "SF2 Default Escape Message", i);
					}
				}
			}
			
			if (SF_SpecialRound(SPECIALROUND_LASTRESORT))
			{
				char sBuffer[SF2_MAX_PROFILE_NAME_LENGTH];
				Handle hSelectableBosses = GetSelectableBossProfileList();
				if (GetArraySize(hSelectableBosses) > 0)
				{
					GetArrayString(hSelectableBosses, GetRandomInt(0, GetArraySize(hSelectableBosses) - 1), sBuffer, sizeof(sBuffer));
					AddProfile(sBuffer);
				}
			}
		}
		else
		{
			if (iClientsNum)
			{
				int iGameTextPage = GetTextEntity("sf2_page_message", false);
				if (iGameTextPage != -1)
				{
					// Custom page message.
					char sMessage[512];
					GetEntPropString(iGameTextPage, Prop_Data, "m_iszMessage", sMessage, sizeof(sMessage));
					ShowHudTextUsingTextEntity(iClients, iClientsNum, iGameTextPage, g_hHudSync, sMessage, g_iPageCount, g_iPageMax);
				}
				else
				{
					// Default page message.
					for (int i = 0; i < iClientsNum; i++)
					{
						int iClient = iClients[i];
						ClientShowMainMessage(iClient, "%d/%d", g_iPageCount, g_iPageMax);
					}
				}
			}
		}
		
		CreateTimer(0.2, Timer_CheckRoundWinConditions, _, TIMER_FLAG_NO_MAPCHANGE);
	}
}

int GetTextEntity(const char[] sTargetName, bool bCaseSensitive=true)
{
	// Try to see if we can use a custom message instead of the default.
	char targetName[64];
	int ent = -1;
	while ((ent = FindEntityByClassname(ent, "game_text")) != -1)
	{
		GetEntPropString(ent, Prop_Data, "m_iName", targetName, sizeof(targetName));
		if (targetName[0])
		{
			if (StrEqual(targetName, sTargetName, bCaseSensitive))
			{
				return ent;
			}
		}
	}
	
	return -1;
}

void ShowHudTextUsingTextEntity(const int[] iClients,int iClientsNum,int iGameText, Handle hHudSync, const char[] sMessage, ...)
{
	if (!sMessage[0]) return;
	if (!IsValidEntity(iGameText)) return;
	
	char sTrueMessage[512];
	VFormat(sTrueMessage, sizeof(sTrueMessage), sMessage, 6);
	
	float flX = GetEntPropFloat(iGameText, Prop_Data, "m_textParms.x");
	float flY = GetEntPropFloat(iGameText, Prop_Data, "m_textParms.y");
	int iEffect = GetEntProp(iGameText, Prop_Data, "m_textParms.effect");
	float flFadeInTime = GetEntPropFloat(iGameText, Prop_Data, "m_textParms.fadeinTime");
	float flFadeOutTime = GetEntPropFloat(iGameText, Prop_Data, "m_textParms.fadeoutTime");
	float flHoldTime = GetEntPropFloat(iGameText, Prop_Data, "m_textParms.holdTime");
	float flFxTime = GetEntPropFloat(iGameText, Prop_Data, "m_textParms.fxTime");
	
	int Color1[4] = { 255, 255, 255, 255 };
	int Color2[4] = { 255, 255, 255, 255 };
	
	int iParmsOffset = FindDataMapOffs(iGameText, "m_textParms");
	if (iParmsOffset != -1)
	{
		// hudtextparms_s m_textParms
		
		Color1[0] = GetEntData(iGameText, iParmsOffset + 12, 1);
		Color1[1] = GetEntData(iGameText, iParmsOffset + 13, 1);
		Color1[2] = GetEntData(iGameText, iParmsOffset + 14, 1);
		Color1[3] = GetEntData(iGameText, iParmsOffset + 15, 1);
		
		Color2[0] = GetEntData(iGameText, iParmsOffset + 16, 1);
		Color2[1] = GetEntData(iGameText, iParmsOffset + 17, 1);
		Color2[2] = GetEntData(iGameText, iParmsOffset + 18, 1);
		Color2[3] = GetEntData(iGameText, iParmsOffset + 19, 1);
	}
	
	SetHudTextParamsEx(flX, flY, flHoldTime, Color1, Color2, iEffect, flFxTime, flFadeInTime, flFadeOutTime);
	
	for (int i = 0; i < iClientsNum; i++)
	{
		int iClient = iClients[i];
		if (!IsValidClient(iClient) || IsFakeClient(iClient)) continue;
		
		ShowSyncHudText(iClient, hHudSync, sTrueMessage);
	}
}

//	==========================================================
//	EVENT HOOKS
//	==========================================================

public Action Event_RoundStart(Handle event, const char[] name, bool dB)
{
	if (!g_bEnabled) return;
	
#if defined DEBUG
	if (GetConVarInt(g_cvDebugDetail) > 0) DebugMessage("EVENT START: Event_RoundStart");
#endif
	
	// Reset some global variables.
	g_iRoundCount++;
	g_hRoundTimer = INVALID_HANDLE;
	
	SetRoundState(SF2RoundState_Invalid);
	
	SetPageCount(0);
	g_iPageMax = 0;
	g_flPageFoundLastTime = GetGameTime();
	
	g_hVoteTimer = INVALID_HANDLE;
	//Stop the music if needed.
	NPCStopMusic();
	// Remove all bosses from the game.
	NPCRemoveAll();
	
	// Refresh groups.
	for (int i = 0; i < SF2_MAX_PLAYER_GROUPS; i++)
	{
		SetPlayerGroupPlaying(i, false);
		CheckPlayerGroup(i);
	}
	
	// Refresh players.
	for (int i = 1; i <= MaxClients; i++)
	{
		ClientSetGhostModeState(i, false);
		
		g_bPlayerPlaying[i] = false;
		g_bPlayerEliminated[i] = true;
		g_bPlayerEscaped[i] = false;
	}
	g_iSpecialRoundType = -1;
	g_iSpecialRoundType2 = -1;
	// Calculate the new round state.
	if (g_bRoundWaitingForPlayers)
	{
		SetRoundState(SF2RoundState_Waiting);
	}
	else if (GetConVarBool(g_cvWarmupRound) && g_iRoundWarmupRoundCount < GetConVarInt(g_cvWarmupRoundNum))
	{
		g_iRoundWarmupRoundCount++;
		
		SetRoundState(SF2RoundState_Waiting);
		
		ServerCommand("mp_restartgame 15");
		PrintCenterTextAll("Round restarting in 15 seconds");
	}
	else
	{
		g_iRoundActiveCount++;
		
		InitializeNewGame();
	}
	
	PvP_OnRoundStart();
#if defined DEBUG
	if (GetConVarInt(g_cvDebugDetail) > 0) DebugMessage("EVENT END: Event_RoundStart");
#endif
}
public Action Event_WinPanel(Event event, const char[] name, bool dontBroadcast)
{
	if(!g_bEnabled) return Plugin_Continue;
	
	char cappers[7];
	int i=0;
	for(int iClient;iClient<=MaxClients;iClient++)
	{
		if(IsValidClient(iClient) && DidClientEscape(iClient) && i<7)
		{
			cappers[i] = iClient;
			event.SetString("cappers", cappers);
			i+=1;
		}
	}
	return Plugin_Continue;
}

public Action Event_RoundEnd(Handle event, const char[] name, bool dB)
{
	if (!g_bEnabled) return;
	
#if defined DEBUG
	if (GetConVarInt(g_cvDebugDetail) > 0) DebugMessage("EVENT START: Event_RoundEnd");
#endif
	SpecialRound_RoundEnd();
	
	SetRoundState(SF2RoundState_Outro);
	
	DistributeQueuePointsToPlayers();
	
	g_iRoundEndCount++;	
	CheckRoundLimitForBossPackVote(g_iRoundEndCount);
	
#if defined DEBUG
	if (GetConVarInt(g_cvDebugDetail) > 0) DebugMessage("EVENT END: Event_RoundEnd");
#endif
}

static void DistributeQueuePointsToPlayers()
{
	// Give away queue points.
	int iDefaultAmount = 5;
	int iAmount = iDefaultAmount;
	int iAmount2 = iAmount;
	Action iAction = Plugin_Continue;
	
	for (int i = 0; i < SF2_MAX_PLAYER_GROUPS; i++)
	{
		if (!IsPlayerGroupActive(i)) continue;
		
		if (IsPlayerGroupPlaying(i))
		{
			SetPlayerGroupQueuePoints(i, 0);
		}
		else
		{
			iAmount = iDefaultAmount;
			iAmount2 = iAmount;
			iAction = Plugin_Continue;
			
			Call_StartForward(fOnGroupGiveQueuePoints);
			Call_PushCell(i);
			Call_PushCellRef(iAmount2);
			Call_Finish(iAction);
			
			if (iAction == Plugin_Changed) iAmount = iAmount2;
			
			SetPlayerGroupQueuePoints(i, GetPlayerGroupQueuePoints(i) + iAmount);
		
			for (int iClient = 1; iClient <= MaxClients; iClient++)
			{
				if (!IsValidClient(iClient)) continue;
				if (ClientGetPlayerGroup(iClient) == i)
				{
					CPrintToChat(iClient, "%T", "SF2 Give Group Queue Points", iClient, iAmount);
				}
			}
		}
	}
	
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i)) continue;
		if (g_bAdminNoPoints[i]) continue;
		if (g_bPlayerPlaying[i]) 
		{
			ClientSetQueuePoints(i, 0);
		}
		else
		{
			if (!IsClientParticipating(i))
			{
				CPrintToChat(i, "%T", "SF2 No Queue Points To Spectator", i);
			}
			else
			{
				iAmount = iDefaultAmount;
				iAmount2 = iAmount;
				iAction = Plugin_Continue;
				
				Call_StartForward(fOnClientGiveQueuePoints);
				Call_PushCell(i);
				Call_PushCellRef(iAmount2);
				Call_Finish(iAction);
				
				if (iAction == Plugin_Changed) iAmount = iAmount2;
				
				ClientSetQueuePoints(i, g_iPlayerQueuePoints[i] + iAmount);
				CPrintToChat(i, "%T", "SF2 Give Queue Points", i, iAmount);
			}
		}	
	}
}

public Action Event_PlayerTeamPre(Handle event, const char[] name, bool dB)
{
	if (!g_bEnabled) return Plugin_Continue;

#if defined DEBUG
	if (GetConVarInt(g_cvDebugDetail) > 1) DebugMessage("EVENT START: Event_PlayerTeamPre");
#endif
	
	int iClient = GetClientOfUserId(GetEventInt(event, "userid"));
	if (iClient > 0)
	{
		if (GetEventInt(event, "team") > 1 || GetEventInt(event, "oldteam") > 1) SetEventBroadcast(event, true);
	}
	
#if defined DEBUG
	if (GetConVarInt(g_cvDebugDetail) > 1) DebugMessage("EVENT END: Event_PlayerTeamPre");
#endif
	
	return Plugin_Continue;
}

public Action Event_PlayerTeam(Handle event, const char[] name, bool dB)
{
	if (!g_bEnabled) return;
	
#if defined DEBUG
	if (GetConVarInt(g_cvDebugDetail) > 0) DebugMessage("EVENT START: Event_PlayerTeam");
#endif
	
	int iClient = GetClientOfUserId(GetEventInt(event, "userid"));
	if (iClient > 0)
	{
		int iintTeam = GetEventInt(event, "team");
		if (iintTeam <= TFTeam_Spectator)
		{
			if (g_bRoundGrace)
			{
				if (g_bPlayerPlaying[iClient] && !g_bPlayerEliminated[iClient])
				{
					ForceInNextPlayersInQueue(1, true);
				}
			}
			
			// You're not playing anymore.
			if (g_bPlayerPlaying[iClient])
			{
				ClientSetQueuePoints(iClient, 0);
			}
			
			g_bPlayerPlaying[iClient] = false;
			g_bPlayerEliminated[iClient] = true;
			g_bPlayerEscaped[iClient] = false;
			
			ClientSetGhostModeState(iClient, false);
			
			if (!view_as<bool>(GetEntProp(iClient, Prop_Send, "m_bIsCoaching")))
			{
				// This is to prevent player spawn spam when someone is coaching. Who coaches in SF2, anyway?
				TF2_RespawnPlayer(iClient);
			}
			
			// Special round.
			if (g_bSpecialRound) g_bPlayerPlayedSpecialRound[iClient] = true;
			
			// Boss round.
			if (g_bNewBossRound) g_bPlayerPlayedNewBossRound[iClient] = true;
		}
		else
		{
			if (!g_bPlayerChoseTeam[iClient])
			{
				g_bPlayerChoseTeam[iClient] = true;
				
				if (g_iPlayerPreferences[iClient][PlayerPreference_ProjectedFlashlight])
				{
					EmitSoundToClient(iClient, SF2_PROJECTED_FLASHLIGHT_CONFIRM_SOUND);
					CPrintToChat(iClient, "%T", "SF2 Projected Flashlight", iClient);
				}
				else
				{
					CPrintToChat(iClient, "%T", "SF2 Normal Flashlight", iClient);
				}
				
				CreateTimer(5.0, Timer_WelcomeMessage, GetClientUserId(iClient), TIMER_FLAG_NO_MAPCHANGE);
			}
		}
	}
	
	// Check groups.
	if (!IsRoundEnding())
	{
		for (int i = 0; i < SF2_MAX_PLAYER_GROUPS; i++)
		{
			if (!IsPlayerGroupActive(i)) continue;
			CheckPlayerGroup(i);
		}
	}
	
#if defined DEBUG
	if (GetConVarInt(g_cvDebugDetail) > 0) DebugMessage("EVENT END: Event_PlayerTeam");
#endif

}

/**
 *	Sets the player to the correct team if needed. Returns true if a change was necessary, false if no change occurred.
 */
static bool HandlePlayerTeam(int iClient, bool bRespawn=true)
{
	if (!IsClientInGame(iClient) || !IsClientParticipating(iClient)) return false;
	
	if (!g_bPlayerEliminated[iClient])
	{
		if (GetClientTeam(iClient) != TFTeam_Red)
		{
			if (bRespawn)
			{
				TF2_RemoveCondition(iClient, view_as<TFCond>(82));
				ChangeClientTeamNoSuicide(iClient, TFTeam_Red);
			}
			else
				ChangeClientTeam(iClient, TFTeam_Red);
				
			return true;
		}
	}
	else
	{
		if (GetClientTeam(iClient) != TFTeam_Blue)
		{
			if (bRespawn)
			{
				TF2_RemoveCondition(iClient, view_as<TFCond>(82));
				ChangeClientTeamNoSuicide(iClient, TFTeam_Blue);
			}
			else
				ChangeClientTeam(iClient, TFTeam_Blue);
				
			return true;
		}
	}
	
	return false;
}

static void HandlePlayerIntroState(int iClient)
{
	if (!IsClientInGame(iClient) || !IsPlayerAlive(iClient) || !IsClientParticipating(iClient)) return;
	
	if (!IsRoundInIntro()) return;
	
#if defined DEBUG
	if (GetConVarInt(g_cvDebugDetail) > 2) DebugMessage("START HandlePlayerIntroState(%d)", iClient);
#endif
	
	// Disable movement on player.
	SetEntityFlags(iClient, GetEntityFlags(iClient) | FL_FROZEN);
	
	float flDelay = 0.0;
	if (!IsFakeClient(iClient))
	{
		flDelay = GetClientLatency(iClient, NetFlow_Outgoing);
	}
	
	CreateTimer(flDelay * 4.0, Timer_IntroBlackOut, GetClientUserId(iClient), TIMER_FLAG_NO_MAPCHANGE);
	
#if defined DEBUG
	if (GetConVarInt(g_cvDebugDetail) > 2) DebugMessage("END HandlePlayerIntroState(%d)", iClient);
#endif
}

void HandlePlayerHUD(int iClient)
{
	if(SF_IsRaidMap())
		return;
	if (IsRoundInWarmup() || IsClientInGhostMode(iClient))
	{
		SetEntProp(iClient, Prop_Send, "m_iHideHUD", 0);
	}
	else
	{
		if (!g_bPlayerEliminated[iClient])
		{
			if (!DidClientEscape(iClient))
			{
				// Player is in the game; disable normal HUD.
				SetEntProp(iClient, Prop_Send, "m_iHideHUD", HIDEHUD_CROSSHAIR | HIDEHUD_HEALTH);
			}
			else
			{
				// Player isn't in the game; enable normal HUD behavior.
				SetEntProp(iClient, Prop_Send, "m_iHideHUD", 0);
			}
		}
		else
		{
			if (g_bPlayerProxy[iClient])
			{
				// Player is in the game; disable normal HUD.
				SetEntProp(iClient, Prop_Send, "m_iHideHUD", HIDEHUD_CROSSHAIR | HIDEHUD_HEALTH);
			}
			else
			{
				// Player isn't in the game; enable normal HUD behavior.
				SetEntProp(iClient, Prop_Send, "m_iHideHUD", 0);
			}
		}
	}
}

public Action Event_PlayerSpawn(Handle event, const char[] name, bool dB)
{
	if (!g_bEnabled) return;
	
	int iClient = GetClientOfUserId(GetEventInt(event, "userid"));
	if (iClient <= 0) return;
#if defined DEBUG
	PrintToChatAll("(SPAWN) Spawn event called.");
	if (GetConVarInt(g_cvDebugDetail) > 0) DebugMessage("EVENT START: Event_PlayerSpawn(%d)", iClient);
#endif
	
	if(GetClientTeam(iClient) > 1)
	{
		g_flLastVisibilityProcess[iClient]=GetGameTime();
		if(!g_bSeeUpdateMenu[iClient])
		{
			g_bSeeUpdateMenu[iClient] = true;
			DisplayMenu(g_hMenuUpdate, iClient, 30);
		}
	}
	if (!IsClientParticipating(iClient))
	{
		TF2Attrib_SetByName(iClient, "increased jump height", 1.0);
		TF2Attrib_RemoveByDefIndex(iClient, 10);
		
		ClientSetGhostModeState(iClient, false);
		g_iPlayerPageCount[iClient] = 0;
		ClientDisableFakeLagCompensation(iClient);
	
		ClientResetStatic(iClient);
		ClientResetSlenderStats(iClient);
		ClientResetCampingStats(iClient);
		ClientResetOverlay(iClient);
		ClientResetJumpScare(iClient);
		ClientUpdateListeningFlags(iClient);
		ClientUpdateMusicSystem(iClient);
		ClientChaseMusicReset(iClient);
		ClientChaseMusicSeeReset(iClient);
		ClientAlertMusicReset(iClient);
		Client20DollarsMusicReset(iClient);
		ClientMusicReset(iClient);
		ClientResetProxy(iClient);
		ClientResetHints(iClient);
		ClientResetScare(iClient);
		
		ClientResetDeathCam(iClient);
		ClientResetFlashlight(iClient);
		ClientDeactivateUltravision(iClient);
		ClientResetSprint(iClient);
		ClientResetBreathing(iClient);
		ClientResetBlink(iClient);
		ClientResetInteractiveGlow(iClient);
		ClientDisableConstantGlow(iClient);
		
		ClientHandleGhostMode(iClient);
	}
	
	g_hPlayerPostWeaponsTimer[iClient] = INVALID_HANDLE;
	
	if (IsPlayerAlive(iClient) && IsClientParticipating(iClient))
	{
		if(MusicActive())//A boss is overriding the music.
		{
			char sPath[PLATFORM_MAX_PATH];
			GetBossMusic(sPath,sizeof(sPath));
			StopSound(iClient, MUSIC_CHAN, sPath);
		}
		g_fLastTimeSndRestart[iClient] = GetGameTime();
		TF2_RemoveCondition(iClient, view_as<TFCond>(82));
		TF2_RemoveCondition(iClient, TFCond_SpawnOutline);
		if (HandlePlayerTeam(iClient))
		{
#if defined DEBUG
		if (GetConVarInt(g_cvDebugDetail) > 0) DebugMessage("iClient->HandlePlayerTeam()");
#endif
		}
		else
		{
			g_iPlayerPageCount[iClient] = 0;
			
			ClientDisableFakeLagCompensation(iClient);
			
			ClientResetStatic(iClient);
			ClientResetSlenderStats(iClient);
			ClientResetCampingStats(iClient);
			ClientResetOverlay(iClient);
			ClientResetJumpScare(iClient);
			ClientUpdateListeningFlags(iClient);
			ClientUpdateMusicSystem(iClient);
			ClientChaseMusicReset(iClient);
			ClientChaseMusicSeeReset(iClient);
			ClientAlertMusicReset(iClient);
			Client20DollarsMusicReset(iClient);
			ClientMusicReset(iClient);
			ClientResetProxy(iClient);
			ClientResetHints(iClient);
			ClientResetScare(iClient);
			
			ClientResetDeathCam(iClient);
			ClientResetFlashlight(iClient);
			ClientDeactivateUltravision(iClient);
			ClientResetSprint(iClient);
			ClientResetBreathing(iClient);
			ClientResetBlink(iClient);
			ClientResetInteractiveGlow(iClient);
			ClientDisableConstantGlow(iClient);
			
			ClientHandleGhostMode(iClient);
			
			TF2Attrib_SetByName(iClient, "increased jump height", 1.0);
			
			if (!g_bPlayerEliminated[iClient])
			{
				if(SF_IsRaidMap() && g_bRoundGrace)
					TF2Attrib_SetByDefIndex(iClient, 10, 7.0);
				else
					TF2Attrib_RemoveByDefIndex(iClient, 10);
		
				ClientStartDrainingBlinkMeter(iClient);
				ClientSetScareBoostEndTime(iClient, -1.0);
				
				ClientStartCampingTimer(iClient);
				
				HandlePlayerIntroState(iClient);
				
				// screen overlay timer
				if(!SF_IsRaidMap())
				{
					g_hPlayerOverlayCheck[iClient] = CreateTimer(0.0, Timer_PlayerOverlayCheck, GetClientUserId(iClient), TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
					TriggerTimer(g_hPlayerOverlayCheck[iClient], true);
				}
				if (DidClientEscape(iClient))
				{
					CreateTimer(0.1, Timer_TeleportPlayerToEscapePoint, GetClientUserId(iClient), TIMER_FLAG_NO_MAPCHANGE);
				}
				else
				{
					ClientEnableConstantGlow(iClient, "head");
					CreateTimer(0.5,DelayClientGlow,iClient);//It's a very very bad thing thing but the only safe way to change the model if the player got a custom one
					ClientActivateUltravision(iClient);
				}
				if(SF_SpecialRound(SPECIALROUND_1UP))
				{
					TF2_AddCondition(iClient,TFCond_PreventDeath,-1.0);
				}
			}
			else
			{
				g_hPlayerOverlayCheck[iClient] = INVALID_HANDLE;
			}
			
			g_hPlayerPostWeaponsTimer[iClient] = CreateTimer(0.1, Timer_ClientPostWeapons, GetClientUserId(iClient), TIMER_FLAG_NO_MAPCHANGE);
			
			HandlePlayerHUD(iClient);
		}
	}
	
	PvP_OnPlayerSpawn(iClient);
	
#if defined DEBUG
	if (GetConVarInt(g_cvDebugDetail) > 0) DebugMessage("EVENT END: Event_PlayerSpawn(%d)", iClient);
#endif
}

public Action Timer_IntroBlackOut(Handle timer, any userid)
{
	int iClient = GetClientOfUserId(userid);
	if (iClient <= 0) return;
	
	if (!IsRoundInIntro()) return;
	
	if (!IsPlayerAlive(iClient) || g_bPlayerEliminated[iClient]) return;
	
	// Black out the player's screen.
	int iFadeFlags = FFADE_OUT | FFADE_STAYOUT | FFADE_PURGE;
	UTIL_ScreenFade(iClient, 0, FixedUnsigned16(90.0, 1 << 12), iFadeFlags, g_iRoundIntroFadeColor[0], g_iRoundIntroFadeColor[1], g_iRoundIntroFadeColor[2], g_iRoundIntroFadeColor[3]);
}

public Action Event_PostInventoryApplication(Handle event, const char[] name, bool dB)
{
	if (!g_bEnabled) return;
	
#if defined DEBUG
	if (GetConVarInt(g_cvDebugDetail) > 0) DebugMessage("EVENT START: Event_PostInventoryApplication");
#endif
	
	int iClient = GetClientOfUserId(GetEventInt(event, "userid"));
	if (iClient > 0)
	{
		g_hPlayerPostWeaponsTimer[iClient] = CreateTimer(0.1, Timer_ClientPostWeapons, GetClientUserId(iClient), TIMER_FLAG_NO_MAPCHANGE);
	}
	
#if defined DEBUG
	if (GetConVarInt(g_cvDebugDetail) > 0) DebugMessage("EVENT END: Event_PostInventoryApplication");
#endif
}
public Action Event_DontBroadcastToClients(Handle event, const char[] name, bool dB)
{
	if (!g_bEnabled) return Plugin_Continue;
	if (IsRoundInWarmup()) return Plugin_Continue;
	
	SetEventBroadcast(event, true);
	return Plugin_Continue;
}

public Action Event_PlayerDeathPre(Handle event, const char[] name, bool dB)
{
	if (!g_bEnabled) return Plugin_Continue;
	
#if defined DEBUG
	if (GetConVarInt(g_cvDebugDetail) > 1) DebugMessage("EVENT START: Event_PlayerDeathPre");
#endif
	
	if (!IsRoundInWarmup())
	{
		int iClient = GetClientOfUserId(GetEventInt(event, "userid"));
		if (iClient > 0)
		{
			if (!IsRoundEnding())
			{
				if (g_bRoundGrace || g_bPlayerEliminated[iClient] || IsClientInGhostMode(iClient))
				{
					SetEventBroadcast(event, true);
				}
			}
		}
	}
	
#if defined DEBUG
	if (GetConVarInt(g_cvDebugDetail) > 1) DebugMessage("EVENT END: Event_PlayerDeathPre");
#endif
	
	return Plugin_Continue;
}

public Action Event_PlayerHurt(Handle event, const char[] name, bool dB)
{
	if (!g_bEnabled) return;
	
	int iClient = GetClientOfUserId(GetEventInt(event, "userid"));
	if (iClient <= 0) return;
	
#if defined DEBUG
	if (GetConVarInt(g_cvDebugDetail) > 0) DebugMessage("EVENT START: Event_PlayerHurt");
#endif
	
	ClientDisableFakeLagCompensation(iClient);
	
	int attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
	if (attacker > 0)
	{
		if (g_bPlayerProxy[attacker])
		{
			g_iPlayerProxyControl[attacker] = 100;
		}
	}
	
	// Play any sounds, if any.
	if (g_bPlayerProxy[iClient])
	{
		int iProxyMaster = NPCGetFromUniqueID(g_iPlayerProxyMaster[iClient]);
		if (iProxyMaster != -1)
		{
			char sProfile[SF2_MAX_PROFILE_NAME_LENGTH];
			NPCGetProfile(iProxyMaster, sProfile, sizeof(sProfile));
		
			char sBuffer[PLATFORM_MAX_PATH];
			if (GetRandomStringFromProfile(sProfile, "sound_proxy_hurt", sBuffer, sizeof(sBuffer)) && sBuffer[0])
			{
				int iChannel = GetProfileNum(sProfile, "sound_proxy_hurt_channel", SNDCHAN_AUTO);
				int iLevel = GetProfileNum(sProfile, "sound_proxy_hurt_level", SNDLEVEL_NORMAL);
				int iFlags = GetProfileNum(sProfile, "sound_proxy_hurt_flags", SND_NOFLAGS);
				float flVolume = GetProfileFloat(sProfile, "sound_proxy_hurt_volume", SNDVOL_NORMAL);
				int iPitch = GetProfileNum(sProfile, "sound_proxy_hurt_pitch", SNDPITCH_NORMAL);
				
				EmitSoundToAll(sBuffer, iClient, iChannel, iLevel, iFlags, flVolume, iPitch);
			}
		}
	}
	
#if defined DEBUG
	if (GetConVarInt(g_cvDebugDetail) > 0) DebugMessage("EVENT END: Event_PlayerHurt");
#endif
}

public Action Event_PlayerDeath(Handle event, const char[] name, bool dB)
{
	if (!g_bEnabled) return;
	
	int iClient = GetClientOfUserId(GetEventInt(event, "userid"));
	if (iClient <= 0) return;
	
#if defined DEBUG
	if (GetConVarInt(g_cvDebugDetail) > 0) DebugMessage("EVENT START: Event_PlayerDeath(%d)", iClient);
#endif
	
	bool bFake = view_as<bool>(GetEventInt(event, "death_flags") & TF_DEATHFLAG_DEADRINGER);
	int inflictor = GetEventInt(event, "inflictor_entindex");
	
#if defined DEBUG
	if (GetConVarInt(g_cvDebugDetail) > 0) DebugMessage("inflictor = %d", inflictor);
#endif
	
	if (!bFake)
	{
		ClientDisableFakeLagCompensation(iClient);
		
		ClientResetStatic(iClient);
		ClientResetSlenderStats(iClient);
		ClientResetCampingStats(iClient);
		ClientResetOverlay(iClient);
		ClientResetJumpScare(iClient);
		ClientResetInteractiveGlow(iClient);
		ClientDisableConstantGlow(iClient);
		ClientChaseMusicReset(iClient);
		ClientChaseMusicSeeReset(iClient);
		ClientAlertMusicReset(iClient);
		Client20DollarsMusicReset(iClient);
		ClientMusicReset(iClient);
		
		ClientResetFlashlight(iClient);
		ClientDeactivateUltravision(iClient);
		ClientResetSprint(iClient);
		ClientResetBreathing(iClient);
		ClientResetBlink(iClient);
		ClientResetDeathCam(iClient);
		
		ClientUpdateMusicSystem(iClient);
		
		PvP_SetPlayerPvPState(iClient, false, false, false);
		
		if (IsRoundInWarmup())
		{
			CreateTimer(0.3, Timer_RespawnPlayer, GetClientUserId(iClient), TIMER_FLAG_NO_MAPCHANGE);
		}
		else
		{
			if (!g_bPlayerEliminated[iClient])
			{
				if (IsRoundInIntro() || g_bRoundGrace || DidClientEscape(iClient))
				{
					CreateTimer(0.3, Timer_RespawnPlayer, GetClientUserId(iClient), TIMER_FLAG_NO_MAPCHANGE);
				}
				else
				{
					g_bPlayerEliminated[iClient] = true;
					g_bPlayerEscaped[iClient] = false;
					g_hPlayerSwitchBlueTimer[iClient] = CreateTimer(0.5, Timer_PlayerSwitchToBlue, GetClientUserId(iClient), TIMER_FLAG_NO_MAPCHANGE);
				}
			}
			else
			{
			}
			
			{
				// If this player was killed by a boss, play a sound.
				int npcIndex = NPCGetFromEntIndex(inflictor);
				if (npcIndex != -1)
				{
					char npcProfile[SF2_MAX_PROFILE_NAME_LENGTH], buffer[PLATFORM_MAX_PATH];
					NPCGetProfile(npcIndex, npcProfile, sizeof(npcProfile));
					
					if (GetRandomStringFromProfile(npcProfile, "sound_attack_killed_all", buffer, sizeof(buffer)) && strlen(buffer) > 0)
					{
						if (!g_bPlayerEliminated[iClient])
						{
							EmitSoundToAll(buffer, _, MUSIC_CHAN, SNDLEVEL_HELICOPTER);
						}
					}
					
					SlenderPerformVoice(npcIndex, "sound_attack_killed");
				}
			}
			
			CreateTimer(0.2, Timer_CheckRoundWinConditions, _, TIMER_FLAG_NO_MAPCHANGE);
			
			// Notify to other bosses that this player has died.
			for (int i = 0; i < MAX_BOSSES; i++)
			{
				if (NPCGetUniqueID(i) == -1) continue;
				
				if (EntRefToEntIndex(g_iSlenderTarget[i]) == iClient)
				{
					g_iSlenderInterruptConditions[i] |= COND_CHASETARGETINVALIDATED;
					GetClientAbsOrigin(iClient, g_flSlenderChaseDeathPosition[i]);
				}
			}
		}
		
		if (g_bPlayerProxy[iClient])
		{
			// We're a proxy, so play some sounds.
		
			int iProxyMaster = NPCGetFromUniqueID(g_iPlayerProxyMaster[iClient]);
			if (iProxyMaster != -1)
			{
				char sProfile[SF2_MAX_PROFILE_NAME_LENGTH];
				NPCGetProfile(iProxyMaster, sProfile, sizeof(sProfile));
				
				char sBuffer[PLATFORM_MAX_PATH];
				if (GetRandomStringFromProfile(sProfile, "sound_proxy_death", sBuffer, sizeof(sBuffer)) && sBuffer[0])
				{
					int iChannel = GetProfileNum(sProfile, "sound_proxy_death_channel", SNDCHAN_AUTO);
					int iLevel = GetProfileNum(sProfile, "sound_proxy_death_level", SNDLEVEL_NORMAL);
					int iFlags = GetProfileNum(sProfile, "sound_proxy_death_flags", SND_NOFLAGS);
					float flVolume = GetProfileFloat(sProfile, "sound_proxy_death_volume", SNDVOL_NORMAL);
					int iPitch = GetProfileNum(sProfile, "sound_proxy_death_pitch", SNDPITCH_NORMAL);
					
					EmitSoundToAll(sBuffer, iClient, iChannel, iLevel, iFlags, flVolume, iPitch);
				}
			}
		}
		
		ClientResetProxy(iClient, false);
		ClientUpdateListeningFlags(iClient);
		
		// Half-Zatoichi nerf code.
		int iKatanaHealthGain = GetConVarInt(g_cvHalfZatoichiHealthGain);
		if (iKatanaHealthGain >= 0)
		{
			int iAttacker = GetClientOfUserId(GetEventInt(event, "attacker"));
			if (iAttacker > 0)
			{
				if (!IsClientInPvP(iAttacker) && (!g_bPlayerEliminated[iAttacker] || g_bPlayerProxy[iAttacker]))
				{
					char sWeapon[64];
					GetEventString(event, "weapon", sWeapon, sizeof(sWeapon));
					
					if (StrEqual(sWeapon, "demokatana"))
					{
						int iAttackerPreHealth = GetEntProp(iAttacker, Prop_Send, "m_iHealth");
						Handle hPack = CreateDataPack();
						WritePackCell(hPack, GetClientUserId(iAttacker));
						WritePackCell(hPack, iAttackerPreHealth + iKatanaHealthGain);
						
						CreateTimer(0.0, Timer_SetPlayerHealth, hPack, TIMER_FLAG_NO_MAPCHANGE);
					}
				}
			}
		}
		
		g_hPlayerPostWeaponsTimer[iClient] = INVALID_HANDLE;
	}
	
	PvP_OnPlayerDeath(iClient, bFake);
	
#if defined DEBUG
	if (GetConVarInt(g_cvDebugDetail) > 0) DebugMessage("EVENT END: Event_PlayerDeath(%d)", iClient);
#endif
}

public Action Timer_SetPlayerHealth(Handle timer, any data)
{
	Handle hPack = view_as<Handle>(data);
	ResetPack(hPack);
	int iAttacker = GetClientOfUserId(ReadPackCell(hPack));
	int iHealth = ReadPackCell(hPack);
	CloseHandle(hPack);
	
	if (iAttacker <= 0) return;
	
	SetEntProp(iAttacker, Prop_Data, "m_iHealth", iHealth);
	SetEntProp(iAttacker, Prop_Send, "m_iHealth", iHealth);
}

public Action Timer_PlayerSwitchToBlue(Handle timer, any userid)
{
	int iClient = GetClientOfUserId(userid);
	if (iClient <= 0) return;
	
	if (timer != g_hPlayerSwitchBlueTimer[iClient]) return;
	
	ChangeClientTeam(iClient, TFTeam_Blue);
}

public Action Timer_RoundStart(Handle timer)
{
	if (g_iPageMax > 0)
	{
		Handle hArrayClients = CreateArray();
		int iClients[MAXPLAYERS + 1];
		int iClientsNum = 0;
		
		int iGameText = GetTextEntity("sf2_intro_message", false);
		
		for (int i = 1; i <= MaxClients; i++)
		{
			if (!IsClientInGame(i) || IsFakeClient(i) || g_bPlayerEliminated[i]) continue;
			
			if (iGameText == -1)
			{
				if (g_iPageMax > 1)
				{
					ClientShowMainMessage(i, "%T", "SF2 Default Intro Message Plural", i, g_iPageMax);
				}
				else
				{
					ClientShowMainMessage(i, "%T", "SF2 Default Intro Message Singular", i, g_iPageMax);
				}
			}
			
			PushArrayCell(hArrayClients, GetClientUserId(i));
			iClients[iClientsNum] = i;
			iClientsNum++;
		}
		
		// Show difficulty menu.
		if (iClientsNum)
		{
			// Automatically set it to Normal.
			SetConVarInt(g_cvDifficulty, Difficulty_Normal);
			
			g_hVoteTimer = CreateTimer(1.0, Timer_VoteDifficulty, hArrayClients, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
			TriggerTimer(g_hVoteTimer, true);
			
			if (iGameText != -1)
			{
				char sMessage[512];
				GetEntPropString(iGameText, Prop_Data, "m_iszMessage", sMessage, sizeof(sMessage));
				
				ShowHudTextUsingTextEntity(iClients, iClientsNum, iGameText, g_hHudSync, sMessage);
			}
		}
		else
		{
			CloseHandle(hArrayClients);
		}
	}
}

public Action Timer_CheckRoundWinConditions(Handle timer)
{
	CheckRoundWinConditions();
}

public Action Timer_RoundGrace(Handle timer)
{
	if (timer != g_hRoundGraceTimer) return;
	
	g_bRoundGrace = false;
	g_hRoundGraceTimer = INVALID_HANDLE;
	
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientParticipating(i)) g_bPlayerEliminated[i] = true;
		if(!g_bPlayerEliminated[i])
		{
			if(SF_IsRaidMap())
				TF2Attrib_RemoveByDefIndex(i, 10);
		}
	}
	
	// Initialize the main round timer.
	if (g_iRoundTimeLimit > 0)
	{
		// Set round time.
		g_iRoundTime = g_iRoundTimeLimit;
		g_hRoundTimer = CreateTimer(1.0, Timer_RoundTime, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
	}
	else
	{
		// Infinite round time.
		g_hRoundTimer = INVALID_HANDLE;
	}
	
	CPrintToChatAll("{olive}%t", "SF2 Grace Period End");
}

public Action Timer_RoundTime(Handle timer)
{
	if (timer != g_hRoundTimer) return Plugin_Stop;
	
	if (g_iRoundTime <= 0)
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			if (!IsClientInGame(i) || !IsPlayerAlive(i) || g_bPlayerEliminated[i] || IsClientInGhostMode(i)) continue;
			
			KillClient(i)
		}
		
		return Plugin_Stop;
	}
	if(bRevolution)
	{
		for (int i = 1; i <= 40; i++)
		{
			if(g_iRoundTime==(60*i))
			{
				SpecialRoundCycleStart();
			}
		}
	}
	g_iRoundTime--;
	
	int hours, minutes, seconds;
	FloatToTimeHMS(float(g_iRoundTime), hours, minutes, seconds);
	
	SetHudTextParams(-1.0, 0.1, 
		1.0,
		SF2_HUD_TEXT_COLOR_R, SF2_HUD_TEXT_COLOR_G, SF2_HUD_TEXT_COLOR_B, SF2_HUD_TEXT_COLOR_A,
		_,
		_,
		1.5, 1.5);
	
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i) || IsFakeClient(i) || (g_bPlayerEliminated[i] && !IsClientInGhostMode(i))) continue;
		if(SF_SpecialRound(SPECIALROUND_EYESONTHECLOACK))
			ShowSyncHudText(i, g_hRoundTimerSync, "%d/%d\n??/??", g_iPageCount, g_iPageMax);
		else
			ShowSyncHudText(i, g_hRoundTimerSync, "%d/%d\n%d:%02d", g_iPageCount, g_iPageMax, minutes, seconds);
	}
	
	return Plugin_Continue;
}

public Action Timer_RoundTimeEscape(Handle timer)
{
	if (timer != g_hRoundTimer) return Plugin_Stop;
	
	if (g_iRoundTime <= 0)
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			if (!IsClientInGame(i) || !IsPlayerAlive(i) || g_bPlayerEliminated[i] || IsClientInGhostMode(i) || DidClientEscape(i)) continue;
			
			float flBuffer[3];
			GetClientAbsOrigin(i, flBuffer);
			ClientStartDeathCam(i, 0, flBuffer);
			KillClient(i);
		}
		
		return Plugin_Stop;
	}
	
	int hours, minutes, seconds;
	FloatToTimeHMS(float(g_iRoundTime), hours, minutes, seconds);
	
	SetHudTextParams(-1.0, 0.1, 
		1.0,
		SF2_HUD_TEXT_COLOR_R, 
		SF2_HUD_TEXT_COLOR_G, 
		SF2_HUD_TEXT_COLOR_B, 
		SF2_HUD_TEXT_COLOR_A,
		_,
		_,
		1.5, 1.5);
	
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i) || IsFakeClient(i) || (g_bPlayerEliminated[i] && !IsClientInGhostMode(i))) continue;
		if(SF_IsSurvivalMap() && g_iRoundTime > g_iTimeEscape)
		{
			if(SF_SpecialRound(SPECIALROUND_EYESONTHECLOACK))
				ShowSyncHudText(i, g_hRoundTimerSync, "%T\n??/??", "SF2 Default Survive Message", i);
			else
				ShowSyncHudText(i, g_hRoundTimerSync, "%T\n%d:%02d", "SF2 Default Survive Message", i, minutes, seconds);
		}
		else
		{
			if(SF_SpecialRound(SPECIALROUND_EYESONTHECLOACK))
				ShowSyncHudText(i, g_hRoundTimerSync, "%T\n??/??", "SF2 Default Escape Message", i);
			else
				ShowSyncHudText(i, g_hRoundTimerSync, "%T\n%d:%02d", "SF2 Default Escape Message", i, minutes, seconds);
		}
	}
	
	g_iRoundTime--;
	
	return Plugin_Continue;
}

public Action Timer_VoteDifficulty(Handle timer, any data)
{
	Handle hArrayClients = view_as<Handle>(data);
	
	if (timer != g_hVoteTimer || IsRoundEnding()) 
	{
		CloseHandle(hArrayClients);
		return Plugin_Stop;
	}
	
	if (IsVoteInProgress()) return Plugin_Continue; // There's another vote in progess. Wait.
	
	int iClients[MAXPLAYERS + 1] = { -1, ... };
	int iClientsNum;
	for (int i = 0, iSize = GetArraySize(hArrayClients); i < iSize; i++)
	{
		int iClient = GetClientOfUserId(GetArrayCell(hArrayClients, i));
		if (iClient <= 0) continue;
		
		iClients[iClientsNum] = iClient;
		iClientsNum++;
	}
	
	CloseHandle(hArrayClients);
	
	VoteMenu(g_hMenuVoteDifficulty, iClients, iClientsNum, 15);
	
	return Plugin_Stop;
}

static void InitializeMapEntities()
{
#if defined DEBUG
	if (GetConVarInt(g_cvDebugDetail) > 0) DebugMessage("START InitializeMapEntities()");
#endif
	
	g_bRoundInfiniteFlashlight = false;
	g_bIsSurvivalMap = false;
	g_bIsRaidMap = false;
	g_bRoundInfiniteBlink = false;
	g_bRoundInfiniteSprint = false;
	g_bRoundHasEscapeObjective = false;
	
	g_iRoundTimeLimit = GetConVarInt(g_cvTimeLimit);
	g_iRoundEscapeTimeLimit = GetConVarInt(g_cvTimeLimitEscape);
	g_iTimeEscape = GetConVarInt(g_cvTimeEscapeSurvival);
	g_iRoundTimeGainFromPage = GetConVarInt(g_cvTimeGainFromPageGrab);
	
	char targetName[64];
	int ent = -1;
	while ((ent = FindEntityByClassname(ent, "info_target")) != -1)
	{
		GetEntPropString(ent, Prop_Data, "m_iName", targetName, sizeof(targetName));
		if (targetName[0])
		{
			if (!StrContains(targetName, "sf2_maxpages_", false))
			{
				ReplaceString(targetName, sizeof(targetName), "sf2_maxpages_", "", false);
				g_iPageMax = StringToInt(targetName);
			}
			else if (!StrContains(targetName, "sf2_logic_escape", false))
			{
				g_bRoundHasEscapeObjective = true;
			}
			else if (!StrContains(targetName, "sf2_infiniteflashlight", false))
			{
				g_bRoundInfiniteFlashlight = true;
			}
			else if (!StrContains(targetName, "sf2_infiniteblink", false))
			{
				g_bRoundInfiniteBlink = true;
			}
			else if (!StrContains(targetName, "sf2_infinitesprint", false))
			{
				g_bRoundInfiniteSprint = true;
			}
			else if (!StrContains(targetName, "sf2_time_limit_", false))
			{
				ReplaceString(targetName, sizeof(targetName), "sf2_time_limit_", "", false);
				g_iRoundTimeLimit = StringToInt(targetName);
				
				LogSF2Message("Found sf2_time_limit entity, set time limit to %d", g_iRoundTimeLimit);
			}
			else if (!StrContains(targetName, "sf2_escape_time_limit_", false))
			{
				ReplaceString(targetName, sizeof(targetName), "sf2_escape_time_limit_", "", false);
				g_iRoundEscapeTimeLimit = StringToInt(targetName);
				
				LogSF2Message("Found sf2_escape_time_limit entity, set escape time limit to %d", g_iRoundEscapeTimeLimit);
			}
			else if (!StrContains(targetName, "sf2_time_gain_from_page_", false))
			{
				ReplaceString(targetName, sizeof(targetName), "sf2_time_gain_from_page_", "", false);
				g_iRoundTimeGainFromPage = StringToInt(targetName);
				
				LogSF2Message("Found sf2_time_gain_from_page entity, set time gain to %d", g_iRoundTimeGainFromPage);
			}
			else if (g_iRoundActiveCount == 1 && (!StrContains(targetName, "sf2_maxplayers_", false)))
			{
				ReplaceString(targetName, sizeof(targetName), "sf2_maxplayers_", "", false);
				SetConVarInt(g_cvMaxPlayers, StringToInt(targetName));
				
				LogSF2Message("Found sf2_maxplayers entity, set maxplayers to %d", StringToInt(targetName));
			}
			else if (!StrContains(targetName, "sf2_boss_override_", false))
			{
				ReplaceString(targetName, sizeof(targetName), "sf2_boss_override_", "", false);
				SetConVarString(g_cvBossProfileOverride, targetName);
				
				LogSF2Message("Found sf2_boss_override entity, set boss profile override to %s", targetName);
			}
			else if (!StrContains(targetName, "sf2_survival_map", false))
			{
				g_bIsSurvivalMap = true;
			}
			else if (!StrContains(targetName, "sf2_raid_map", false))
			{
				g_bIsRaidMap = true;
			}
			else if (!StrContains(targetName, "sf2_survival_time_limit_", false))
			{
				ReplaceString(targetName, sizeof(targetName), "sf2_survival_time_limit_", "", false);
				g_iTimeEscape = StringToInt(targetName);
				
				LogSF2Message("Found sf2_survival_time_limit_ entity, set survival time limit to %d", g_iTimeEscape);
			}
		}
	}
	
	SpawnPages();
	
#if defined DEBUG
	if (GetConVarInt(g_cvDebugDetail) > 0) DebugMessage("END InitializeMapEntities()");
#endif
}
void SpawnPages()
{
	g_bPageRef = false;
	strcopy(g_strPageRefModel, sizeof(g_strPageRefModel),"");
	g_flPageRefModelScale = 1.0;
	
	Handle hArray = CreateArray(2);
	Handle hPageTrie = CreateTrie();
	
	char targetName[64];
	int ent = -1;
	while ((ent = FindEntityByClassname(ent, "info_target")) != -1)
	{
		GetEntPropString(ent, Prop_Data, "m_iName", targetName, sizeof(targetName));
		if (targetName[0])
		{
			if (!StrContains(targetName, "sf2_page_spawnpoint", false))
			{
				if (!StrContains(targetName, "sf2_page_spawnpoint_", false))
				{
					ReplaceString(targetName, sizeof(targetName), "sf2_page_spawnpoint_", "", false);
					if (targetName[0])
					{
						Handle hButtStallion = INVALID_HANDLE;
						if (!GetTrieValue(hPageTrie, targetName, hButtStallion))
						{
							hButtStallion = CreateArray();
							SetTrieValue(hPageTrie, targetName, hButtStallion);
						}
						
						int iIndex = FindValueInArray(hArray, hButtStallion);
						if (iIndex == -1)
						{
							iIndex = PushArrayCell(hArray, hButtStallion);
						}
						
						PushArrayCell(hButtStallion, ent);
						SetArrayCell(hArray, iIndex, true, 1);
					}
					else
					{
						int iIndex = PushArrayCell(hArray, ent);
						SetArrayCell(hArray, iIndex, false, 1);
					}
				}
				else
				{
					int iIndex = PushArrayCell(hArray, ent);
					SetArrayCell(hArray, iIndex, false, 1);
				}
			}
		}
	}
	
	// Get a reference entity, if any.
				
	ent = -1;
	while ((ent = FindEntityByClassname(ent, "prop_dynamic")) != -1)
	{
		if (g_bPageRef) break;
	
		GetEntPropString(ent, Prop_Data, "m_iName", targetName, sizeof(targetName));
		if (targetName[0])
		{
			if (StrEqual(targetName, "sf2_page_model", false))
			{
				g_bPageRef = true;
				GetEntPropString(ent, Prop_Data, "m_ModelName", g_strPageRefModel, sizeof(g_strPageRefModel));
				g_flPageRefModelScale = 1.0;
			}
		}
	}
	
	int iPageCount = GetArraySize(hArray);
	if (iPageCount)
	{
		SortADTArray(hArray, Sort_Random, Sort_Integer);
		
		float vecPos[3], vecAng[3], vecDir[3];
		int page;
		ent = -1;
		
		for (int i = 0; i < iPageCount && (i + 1) <= g_iPageMax; i++)
		{
			if (view_as<bool>(GetArrayCell(hArray, i, 1)))
			{
				Handle hButtStallion = view_as<Handle>(GetArrayCell(hArray, i));
				ent = GetArrayCell(hButtStallion, GetRandomInt(0, GetArraySize(hButtStallion) - 1));
			}
			else
			{
				ent = GetArrayCell(hArray, i);
			}
			
			GetEntPropVector(ent, Prop_Data, "m_vecAbsOrigin", vecPos);
			GetEntPropVector(ent, Prop_Data, "m_angAbsRotation", vecAng);
			GetAngleVectors(vecAng, vecDir, NULL_VECTOR, NULL_VECTOR);
			NormalizeVector(vecDir, vecDir);
			ScaleVector(vecDir, 1.0);
			
			char pageName[50];
			page = CreateEntityByName("prop_dynamic_override");
			if (page != -1)
			{
				TeleportEntity(page, vecPos, vecAng, NULL_VECTOR);
				Format(pageName,50,"sf2_page_%i",i);
				DispatchKeyValue(page, "targetname", pageName);
				
				if (g_bPageRef)
				{
					SetEntityModel(page, g_strPageRefModel);
				}
				else
				{
					SetEntityModel(page, PAGE_MODEL);
				}
				
				DispatchKeyValue(page, "solid", "2");
				DispatchKeyValue(page, "fademindist", "300");
				DispatchKeyValue(page, "fademaxdist", "400");
				DispatchSpawn(page);
				ActivateEntity(page);
				SetVariantInt(i);
				AcceptEntityInput(page, "Skin");
				AcceptEntityInput(page, "EnableCollision");
				
				if (g_bPageRef)
				{
					SetEntPropFloat(page, Prop_Send, "m_flModelScale", g_flPageRefModelScale);
				}
				else
				{
					SetEntPropFloat(page, Prop_Send, "m_flModelScale", PAGE_MODELSCALE);
				}
				SetEntProp(page, Prop_Send, "m_fEffects", EF_ITEM_BLINK);
				
				SDKHook(page, SDKHook_OnTakeDamage, Hook_PageOnTakeDamage);
				SDKHook(page, SDKHook_SetTransmit, Hook_SlenderObjectSetTransmit);
			}
			int page2 = CreateEntityByName("prop_dynamic_override");
			if (page2 != -1)
			{
				TeleportEntity(page2, vecPos, vecAng, NULL_VECTOR);
				DispatchKeyValue(page2, "targetname", "sf2_page_ex");
				
				if (g_bPageRef)
				{
					SetEntityModel(page2, g_strPageRefModel);
				}
				else
				{
					SetEntityModel(page2, PAGE_MODEL);
				}
				
				DispatchKeyValue(page2, "solid", "0");
				DispatchKeyValue(page2, "parentname", pageName);
				DispatchSpawn(page2);
				ActivateEntity(page2);
				SetVariantInt(i);
				AcceptEntityInput(page2, "Skin");
				AcceptEntityInput(page2, "DisableCollision");
				SetVariantString(pageName);
				AcceptEntityInput(page2, "SetParent");
				
				if (g_bPageRef)
				{
					SetEntPropFloat(page2, Prop_Send, "m_flModelScale", (g_flPageRefModelScale-0.05));
				}
				else
				{
					SetEntPropFloat(page2, Prop_Send, "m_flModelScale", (PAGE_MODELSCALE-0.05));
				}
				SDKHook(page2, SDKHook_SetTransmit, Hook_SlenderObjectSetTransmitEx);
			}
		}
		
		// Safely remove all handles.
		for (int i = 0, iSize = GetArraySize(hArray); i < iSize; i++)
		{
			if (view_as<bool>(GetArrayCell(hArray, i, 1)))
			{
				CloseHandle(view_as<Handle>(GetArrayCell(hArray, i)));
			}
		}
	
		Call_StartForward(fOnPagesSpawned);
		Call_Finish();
	}
	
	CloseHandle(hPageTrie);
	CloseHandle(hArray);
}
static bool HandleSpecialRoundState()
{
#if defined DEBUG
	if (GetConVarInt(g_cvDebugDetail) > 0) DebugMessage("START HandleSpecialRoundState()");
#endif
	
	bool bOld = g_bSpecialRound;
	bool bContinuousOld = g_bSpecialRoundContinuous;
	g_bSpecialRound = false;
	g_bSpecialRoundint = false;
	g_bSpecialRoundContinuous = false;
	
	bool bForceNew = false;
	
	if (bOld)
	{
		if (bContinuousOld)
		{
			// Check if there are players who haven't played the special round yet.
			for (int i = 1; i <= MaxClients; i++)
			{
				if (!IsClientInGame(i) || !IsClientParticipating(i))
				{
					g_bPlayerPlayedSpecialRound[i] = true;
					continue;
				}
				
				if (!g_bPlayerPlayedSpecialRound[i])
				{
					// Someone didn't get to play this yet. Continue the special round.
					g_bSpecialRound = true;
					g_bSpecialRoundContinuous = true;
					break;
				}
			}
		}
	}
	
	int iRoundInterval = GetConVarInt(g_cvSpecialRoundInterval);
	
	if (iRoundInterval > 0 && g_iSpecialRoundCount >= iRoundInterval)
	{
		g_bSpecialRound = true;
		bForceNew = true;
	}
	
	// Do special round force override and reset it.
	if (GetConVarInt(g_cvSpecialRoundForce) >= 0)
	{
		g_bSpecialRound = GetConVarBool(g_cvSpecialRoundForce);
		SetConVarInt(g_cvSpecialRoundForce, -1);
	}
	
	if (g_bSpecialRound)
	{
		if (bForceNew || !bOld || !bContinuousOld)
		{
			g_bSpecialRoundint = true;
		}
		
		if (g_bSpecialRoundint)
		{
			if (GetConVarInt(g_cvSpecialRoundBehavior) == 1)
			{
				g_bSpecialRoundContinuous = true;
			}
			else
			{
				// int special round, but it's not continuous.
				g_bSpecialRoundContinuous = false;
			}
		}
	}
	else
	{
		g_bSpecialRoundContinuous = false;
	}
	
#if defined DEBUG
	if (GetConVarInt(g_cvDebugDetail) > 0) DebugMessage("END HandleSpecialRoundState() -> g_bSpecialRound = %d (count = %d, int = %d, continuous = %d)", g_bSpecialRound, g_iSpecialRoundCount, g_bSpecialRoundint, g_bSpecialRoundContinuous);
#endif
}

bool IsintBossRoundRunning()
{
	return g_bNewBossRound;
}

/**
 *	Returns an array which contains all the profile names valid to be chosen for a int boss round.
 */
static Handle GetintBossRoundProfileList()
{
	Handle hBossList = CloneArray(GetSelectableBossProfileList());
	
	if (GetArraySize(hBossList) > 0)
	{
		char sMainBoss[SF2_MAX_PROFILE_NAME_LENGTH];
		GetConVarString(g_cvBossMain, sMainBoss, sizeof(sMainBoss));
		
		int index = FindStringInArray(hBossList, sMainBoss);
		if (index != -1)
		{
			// Main boss exists; remove him from the list.
			RemoveFromArray(hBossList, index);
		}
		else
		{
			// Main boss doesn't exist; remove the first boss from the list.
			RemoveFromArray(hBossList, 0);
		}
	}
	
	return hBossList;
}

static void HandleintBossRoundState()
{
#if defined DEBUG
	if (GetConVarInt(g_cvDebugDetail) > 0) DebugMessage("START HandleintBossRoundState()");
#endif
	
	bool bOld = g_bNewBossRound;
	bool bContinuousOld = g_bNewBossRoundContinuous;
	g_bNewBossRound = false;
	g_bNewBossRoundNew = false;
	g_bNewBossRoundContinuous = false;
	
	bool bForceNew = false;
	
	if (bOld)
	{
		if (bContinuousOld)
		{
			// Check if there are players who haven't played the boss round yet.
			for (int i = 1; i <= MaxClients; i++)
			{
				if (!IsClientInGame(i) || !IsClientParticipating(i))
				{
					g_bPlayerPlayedNewBossRound[i] = true;
					continue;
				}
				
				if (!g_bPlayerPlayedNewBossRound[i])
				{
					// Someone didn't get to play this yet. Continue the boss round.
					g_bNewBossRound = true;
					g_bNewBossRoundContinuous = true;
					break;
				}
			}
		}
	}
	
	// Don't force a int special round while a continuous round is going on.
	if (!g_bNewBossRoundContinuous)
	{
		int iRoundInterval = GetConVarInt(g_cvNewBossRoundInterval);
		
		if (/*iRoundInterval > 0 &&*/ iRoundInterval <= 0 || g_iNewBossRoundCount >= iRoundInterval)
		{
			g_bNewBossRound = true;
			bForceNew = true;
		}
	}
	
	// Do boss round force override and reset it.
	if (GetConVarInt(g_cvNewBossRoundForce) >= 0)
	{
		g_bNewBossRound = GetConVarBool(g_cvNewBossRoundForce);
		SetConVarInt(g_cvNewBossRoundForce, -1);
	}
	
	// Check if we have enough bosses.
	if (g_bNewBossRound)
	{
		Handle hBossList = GetintBossRoundProfileList();
	
		if (GetArraySize(hBossList) < 1)
		{
			g_bNewBossRound = false; // Not enough bosses.
		}
		
		CloseHandle(hBossList);
	}
	
	if (g_bNewBossRound)
	{
		if (bForceNew || !bOld || !bContinuousOld)
		{
			g_bNewBossRoundNew = true;
		}
		
		if (g_bNewBossRoundNew)
		{
			if (GetConVarInt(g_cvNewBossRoundBehavior) == 1)
			{
				g_bNewBossRoundContinuous = true;
			}
			else
			{
				// int "int boss round", but it's not continuous.
				g_bNewBossRoundContinuous = false;
			}
		}
	}
	else
	{
		g_bNewBossRoundContinuous = false;
	}
	
#if defined DEBUG
	if (GetConVarInt(g_cvDebugDetail) > 0) DebugMessage("END HandleintBossRoundState() -> g_bNewBossRound = %d (count = %d, int = %d, continuous = %d)", g_bNewBossRound, g_iNewBossRoundCount, g_bNewBossRoundNew, g_bNewBossRoundContinuous);
#endif
}

/**
 *	Returns the amount of players that are in game and currently not eliminated.
 */
int GetActivePlayerCount()
{
	int count = 0;

	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i) || !IsClientParticipating(i)) continue;
		
		if (!g_bPlayerEliminated[i])
		{
			count++;
		}
	}
	
	return count;
}

static void SelectStartingBossesForRound()
{
#if defined DEBUG
	if (GetConVarInt(g_cvDebugDetail) > 0) DebugMessage("START SelectStartingBossesForRound()");
#endif

	Handle hSelectableBossList = GetSelectableBossProfileList();

	// Select which boss profile to use.
	char sProfileOverride[SF2_MAX_PROFILE_NAME_LENGTH];
	GetConVarString(g_cvBossProfileOverride, sProfileOverride, sizeof(sProfileOverride));
	
	if (strlen(sProfileOverride) > 0 && IsProfileValid(sProfileOverride))
	{
		// Pick the overridden boss.
		strcopy(g_strRoundBossProfile, sizeof(g_strRoundBossProfile), sProfileOverride);
		SetConVarString(g_cvBossProfileOverride, "");
	}
	else if (g_bNewBossRound)
	{
		if (g_bNewBossRoundNew)
		{
			Handle hBossList = GetintBossRoundProfileList();
		
			GetArrayString(hBossList, GetRandomInt(0, GetArraySize(hBossList) - 1), g_strintBossRoundProfile, sizeof(g_strintBossRoundProfile));
		
			CloseHandle(hBossList);
		}
		
		strcopy(g_strRoundBossProfile, sizeof(g_strRoundBossProfile), g_strintBossRoundProfile);
	}
	else
	{
		char sProfile[SF2_MAX_PROFILE_NAME_LENGTH];
		GetConVarString(g_cvBossMain, sProfile, sizeof(sProfile));
		
		if (strlen(sProfile) > 0 && IsProfileValid(sProfile))
		{
			strcopy(g_strRoundBossProfile, sizeof(g_strRoundBossProfile), sProfile);
		}
		else
		{
			if (GetArraySize(hSelectableBossList) > 0)
			{
				// Pick the first boss in our array if the main boss doesn't exist.
				GetArrayString(hSelectableBossList, 0, g_strRoundBossProfile, sizeof(g_strRoundBossProfile));
			}
			else
			{
				// No bosses to pick. What?
				strcopy(g_strRoundBossProfile, sizeof(g_strRoundBossProfile), "");
			}
		}
	}
	
#if defined DEBUG
	if (GetConVarInt(g_cvDebugDetail) > 0) DebugMessage("END SelectStartingBossesForRound() -> boss: %s", g_strRoundBossProfile);
#endif
}

static void GetRoundIntroParameters()
{
	g_iRoundIntroFadeColor[0] = 0;
	g_iRoundIntroFadeColor[1] = 0;
	g_iRoundIntroFadeColor[2] = 0;
	g_iRoundIntroFadeColor[3] = 255;
	
	g_flRoundIntroFadeHoldTime = GetConVarFloat(g_cvIntroDefaultHoldTime);
	g_flRoundIntroFadeDuration = GetConVarFloat(g_cvIntroDefaultFadeTime);
	
	int ent = -1;
	while ((ent = FindEntityByClassname(ent, "env_fade")) != -1)
	{
		char sName[32];
		GetEntPropString(ent, Prop_Data, "m_iName", sName, sizeof(sName));
		if (StrEqual(sName, "sf2_intro_fade", false))
		{
			int iColorOffset = FindSendPropOffs("CBaseEntity", "m_clrRender");
			if (iColorOffset != -1)
			{
				g_iRoundIntroFadeColor[0] = GetEntData(ent, iColorOffset, 1);
				g_iRoundIntroFadeColor[1] = GetEntData(ent, iColorOffset + 1, 1);
				g_iRoundIntroFadeColor[2] = GetEntData(ent, iColorOffset + 2, 1);
				g_iRoundIntroFadeColor[3] = GetEntData(ent, iColorOffset + 3, 1);
			}
			
			g_flRoundIntroFadeHoldTime = GetEntPropFloat(ent, Prop_Data, "m_HoldTime");
			g_flRoundIntroFadeDuration = GetEntPropFloat(ent, Prop_Data, "m_Duration");
			
			break;
		}
	}
	
	// Get the intro music.
	strcopy(g_strRoundIntroMusic, sizeof(g_strRoundIntroMusic), SF2_INTRO_DEFAULT_MUSIC);
	
	ent = -1;
	while ((ent = FindEntityByClassname(ent, "ambient_generic")) != -1)
	{
		char sName[64];
		GetEntPropString(ent, Prop_Data, "m_iName", sName, sizeof(sName));
		
		if (StrEqual(sName, "sf2_intro_music", false))
		{
			char sSongPath[PLATFORM_MAX_PATH];
			GetEntPropString(ent, Prop_Data, "m_iszSound", sSongPath, sizeof(sSongPath));
			
			if (strlen(sSongPath) == 0)
			{
				LogError("Found sf2_intro_music entity, but it has no sound path specified! Default intro music will be used instead.");
			}
			else
			{
				strcopy(g_strRoundIntroMusic, sizeof(g_strRoundIntroMusic), sSongPath);
			}
			
			break;
		}
	}
}

static void GetRoundEscapeParameters()
{
	g_iRoundEscapePointEntity = INVALID_ENT_REFERENCE;
	
	char sName[64];
	int ent = -1;
	while ((ent = FindEntityByClassname(ent, "info_target")) != -1)
	{
		GetEntPropString(ent, Prop_Data, "m_iName", sName, sizeof(sName));
		if (!StrContains(sName, "sf2_escape_spawnpoint", false))
		{
			g_iRoundEscapePointEntity = EntIndexToEntRef(ent);
			break;
		}
	}
}

void InitializeNewGame()
{
#if defined DEBUG
	if (GetConVarInt(g_cvDebugDetail) > 0) DebugMessage("START InitializeNewGame()");
#endif
	GetRoundIntroParameters();
	GetRoundEscapeParameters();
	
	// Choose round state.
	if (GetConVarBool(g_cvIntroEnabled))
	{
		// Set the round state to the intro stage.
		SetRoundState(SF2RoundState_Intro);
	}
	else
	{
		SetRoundState(SF2RoundState_Active);
		SF2_RefreshRestrictions();
	}
	
	if (g_iRoundActiveCount == 1)
	{
		SetConVarString(g_cvBossProfileOverride, "");
	}
	
	HandleSpecialRoundState();
	
	// Was a new special round initialized?
	if (g_bSpecialRound)
	{
		if (g_bSpecialRoundint)
		{
			// Reset round count.
			g_iSpecialRoundCount = 1;
			
			if (g_bSpecialRoundContinuous)
			{
				// It's the start of a continuous special round.
			
				// Initialize all players' values.
				for (int i = 1; i <= MaxClients; i++)
				{
					if (!IsClientInGame(i) || !IsClientParticipating(i))
					{
						g_bPlayerPlayedSpecialRound[i] = true;
						continue;
					}
					
					g_bPlayerPlayedSpecialRound[i] = false;
				}
			}
			
			SpecialRoundCycleStart();
		}
		else
		{
			SpecialRoundStart();
			
			if (g_bSpecialRoundContinuous)
			{
				// Display the current special round going on to late players.
				CreateTimer(3.0, Timer_DisplaySpecialRound, _, TIMER_FLAG_NO_MAPCHANGE);
			}
		}
	}
	else
	{
		g_iSpecialRoundCount++;
	
		SpecialRoundReset();
	}
	
	// Determine boss round state.
	HandleintBossRoundState();
	
	if (g_bNewBossRound)
	{
		if (g_bNewBossRoundNew)
		{
			// Reset round count;
			g_iNewBossRoundCount = 1;
			
			if (g_bNewBossRoundContinuous)
			{
				// It's the start of a continuous "new boss round".
			
				// Initialize all players' values.
				for (int i = 1; i <= MaxClients; i++)
				{
					if (!IsClientInGame(i) || !IsClientParticipating(i))
					{
						g_bPlayerPlayedNewBossRound[i] = true;
						continue;
					}
					
					g_bPlayerPlayedNewBossRound[i] = false;
				}
			}
		}
	}
	else
	{
		g_iNewBossRoundCount++;
	}
	
	InitializeMapEntities();
	
	// Initialize pages and entities.
	GetPageMusicRanges();
	
	SelectStartingBossesForRound();
	
	ForceInNextPlayersInQueue(GetMaxPlayersForRound());
	
	// Respawn all players, if needed.
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientParticipating(i))
		{
			if (!HandlePlayerTeam(i))
			{
				if (!g_bPlayerEliminated[i])
				{
					// Players currently in the "game" still have to be respawned.
					TF2_RespawnPlayer(i);
				}
			}
		}
	}
	
	if (GetRoundState() == SF2RoundState_Intro)
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			if (!IsClientInGame(i)) continue;
			
			if (!g_bPlayerEliminated[i])
			{
				if (!IsFakeClient(i))
				{
					// Currently in intro state, play intro music.
					g_hPlayerIntroMusicTimer[i] = CreateTimer(0.5, Timer_PlayIntroMusicToPlayer, GetClientUserId(i), TIMER_FLAG_NO_MAPCHANGE);
				}
				else
				{
					g_hPlayerIntroMusicTimer[i] = INVALID_HANDLE;
				}
			}
			else
			{
				g_hPlayerIntroMusicTimer[i] = INVALID_HANDLE;
			}
		}
	}
	else
	{
		// Spawn the boss!
		SelectProfile(view_as<SF2NPC_BaseNPC>(0), g_strRoundBossProfile);
	}
	
#if defined DEBUG
	if (GetConVarInt(g_cvDebugDetail) > 0) DebugMessage("END InitializeNewGame()");
#endif
}

public Action Timer_PlayIntroMusicToPlayer(Handle timer, any userid)
{
	int iClient = GetClientOfUserId(userid);
	if (iClient <= 0) return;
	
	if (timer != g_hPlayerIntroMusicTimer[iClient]) return;
	
	g_hPlayerIntroMusicTimer[iClient] = INVALID_HANDLE;
	
	EmitSoundToClient(iClient, g_strRoundIntroMusic, _, MUSIC_CHAN, SNDLEVEL_NONE);
}

public Action Timer_IntroTextSequence(Handle timer)
{
	if (!g_bEnabled) return;
	if (g_hRoundIntroTextTimer != timer) return;
	
	float flDuration = 0.0;
	
	if (g_iRoundIntroText != 0)
	{
		bool bFoundGameText = false;
		
		int iClients[MAXPLAYERS + 1];
		int iClientsNum;
		
		for (int i = 1; i <= MaxClients; i++)
		{
			if (!IsClientInGame(i) || g_bPlayerEliminated[i]) continue;
			
			iClients[iClientsNum] = i;
			iClientsNum++;
		}
		
		if (!g_bRoundIntroTextDefault)
		{
			char sTargetname[64];
			Format(sTargetname, sizeof(sTargetname), "sf2_intro_text_%d", g_iRoundIntroText);
		
			int iGameText = FindEntityByTargetname(sTargetname, "game_text");
			if (iGameText && iGameText != INVALID_ENT_REFERENCE)
			{
				bFoundGameText = true;
				flDuration = GetEntPropFloat(iGameText, Prop_Data, "m_textParms.fadeinTime") + GetEntPropFloat(iGameText, Prop_Data, "m_textParms.fadeoutTime") + GetEntPropFloat(iGameText, Prop_Data, "m_textParms.holdTime");
				
				char sMessage[512];
				GetEntPropString(iGameText, Prop_Data, "m_iszMessage", sMessage, sizeof(sMessage));
				ShowHudTextUsingTextEntity(iClients, iClientsNum, iGameText, g_hHudSync, sMessage);
			}
		}
		else
		{
			if (g_iRoundIntroText == 2)
			{
				bFoundGameText = false;
				
				char sMessage[64];
				GetCurrentMap(sMessage, sizeof(sMessage));
				
				for (int i = 0; i < iClientsNum; i++)
				{
					ClientShowMainMessage(iClients[i], sMessage, 1);
				}
			}
		}
		
		if (g_iRoundIntroText == 1 && !bFoundGameText)
		{
			// Use default intro sequence. Eugh.
			g_bRoundIntroTextDefault = true;
			flDuration = GetConVarFloat(g_cvIntroDefaultHoldTime) / 2.0;
			
			for (int i = 0; i < iClientsNum; i++)
			{
				EmitSoundToClient(iClients[i], SF2_INTRO_DEFAULT_MUSIC, _, MUSIC_CHAN, SNDLEVEL_NONE);
			}
		}
		else
		{
			if (!bFoundGameText) return; // done with sequence; don't check anymore.
		}
	}
	
	g_iRoundIntroText++;
	g_hRoundIntroTextTimer = CreateTimer(flDuration, Timer_IntroTextSequence, _, TIMER_FLAG_NO_MAPCHANGE);
}

public Action Timer_ActivateRoundFromIntro(Handle timer)
{
	if (!g_bEnabled) return;
	if (g_hRoundIntroTimer != timer) return;
	
	// Obviously we don't want to spawn the boss when g_strRoundBossProfile isn't set yet.
	SetRoundState(SF2RoundState_Active);
	SF2_RefreshRestrictions();
	
	
	// Spawn the boss!
	SelectProfile(view_as<SF2NPC_BaseNPC>(0), g_strRoundBossProfile);
}

void CheckRoundWinConditions()
{
	if (IsRoundInWarmup() || IsRoundEnding()) return;
	
	int iTotalCount = 0;
	int iAliveCount = 0;
	int iEscapedCount = 0;
	
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i)) continue;
		iTotalCount++;
		if (!g_bPlayerEliminated[i] && !IsClientInDeathCam(i)) 
		{
			iAliveCount++;
			if (DidClientEscape(i)) iEscapedCount++;
		}
	}
	
	if (iAliveCount == 0)
	{
		ForceTeamWin(TFTeam_Blue);
	}
	else
	{
		if (g_bRoundHasEscapeObjective)
		{
			if (iEscapedCount == iAliveCount)
			{
				ForceTeamWin(TFTeam_Red);
			}
		}
		else
		{
			if (g_iPageMax > 0 && g_iPageCount == g_iPageMax)
			{
				ForceTeamWin(TFTeam_Red);
			}
		}
	}
}

//	==========================================================
//	API
//	==========================================================

public int Native_IsRunning(Handle plugin,int numParams)
{
	return view_as<bool>(g_bEnabled);
}

public int Native_GetRoundState(Handle plugin,int numParams)
{
	return view_as<int>(g_iRoundState);
}

public int Native_GetCurrentDifficulty(Handle plugin,int numParams)
{
	return GetConVarInt(g_cvDifficulty);
}

public int Native_GetDifficultyModifier(Handle plugin,int numParams)
{
	int iDifficulty = GetNativeCell(1);
	if (iDifficulty < Difficulty_Easy || iDifficulty >= Difficulty_Max)
	{
		LogError("Difficulty parameter can only be from %d to %d!", Difficulty_Easy, Difficulty_Max - 1);
		return 1;
	}
	
	switch (iDifficulty)
	{
		case Difficulty_Easy: return view_as<int>(DIFFICULTY_EASY);
		case Difficulty_Hard: return view_as<int>(DIFFICULTY_HARD);
		case Difficulty_Insane: return view_as<int>(DIFFICULTY_INSANE);
	}
	
	return view_as<int>(DIFFICULTY_NORMAL);
}

public int Native_IsClientEliminated(Handle plugin,int numParams)
{
	return view_as<bool>(g_bPlayerEliminated[GetNativeCell(1)]);
}

public int Native_IsClientInGhostMode(Handle plugin,int numParams)
{
	return IsClientInGhostMode(GetNativeCell(1));
}

public int Native_IsClientProxy(Handle plugin,int numParams)
{
	return view_as<bool>(g_bPlayerProxy[GetNativeCell(1)]);
}

public int Native_GetClientBlinkCount(Handle plugin,int numParams)
{
	return ClientGetBlinkCount(GetNativeCell(1));
}

public int Native_GetClientProxyMaster(Handle plugin,int numParams)
{
	return NPCGetFromUniqueID(g_iPlayerProxyMaster[GetNativeCell(1)]);
}

public int Native_GetClientProxyControlAmount(Handle plugin,int numParams)
{
	return g_iPlayerProxyControl[GetNativeCell(1)];
}

public int Native_GetClientProxyControlRate(Handle plugin,int numParams)
{
	return view_as<int>(g_flPlayerProxyControlRate[GetNativeCell(1)]);
}

public int Native_SetClientProxyMaster(Handle plugin,int numParams)
{
	g_iPlayerProxyMaster[GetNativeCell(1)] = NPCGetUniqueID(GetNativeCell(2));
}

public int Native_SetClientProxyControlAmount(Handle plugin,int numParams)
{
	g_iPlayerProxyControl[GetNativeCell(1)] = GetNativeCell(2);
}

public int Native_SetClientProxyControlRate(Handle plugin,int numParams)
{
	g_flPlayerProxyControlRate[GetNativeCell(1)] = view_as<float>(GetNativeCell(2));
}

public int Native_IsClientLookingAtBoss(Handle plugin,int numParams)
{
	return view_as<bool>(g_bPlayerSeesSlender[GetNativeCell(1)][GetNativeCell(2)]);
}

public int Native_CollectAsPage(Handle plugin,int numParams)
{
	CollectPage(GetNativeCell(1), GetNativeCell(2));
}

public int Native_GetMaxBosses(Handle plugin,int numParams)
{
	return MAX_BOSSES;
}

public int Native_EntIndexToBossIndex(Handle plugin,int numParams)
{
	return NPCGetFromEntIndex(GetNativeCell(1));
}

public int Native_BossIndexToEntIndex(Handle plugin,int numParams)
{
	return NPCGetEntIndex(GetNativeCell(1));
}

public int Native_BossIDToBossIndex(Handle plugin,int numParams)
{
	return NPCGetFromUniqueID(GetNativeCell(1));
}

public int Native_BossIndexToBossID(Handle plugin,int numParams)
{
	return NPCGetUniqueID(GetNativeCell(1));
}

public int Native_GetBossName(Handle plugin,int numParams)
{
	char sProfile[SF2_MAX_PROFILE_NAME_LENGTH];
	NPCGetProfile(GetNativeCell(1), sProfile, sizeof(sProfile));
	
	SetNativeString(2, sProfile, GetNativeCell(3));
}

public int Native_GetBossModelEntity(Handle plugin,int numParams)
{
	return EntRefToEntIndex(g_iSlenderModel[GetNativeCell(1)]);
}

public int Native_GetBossTarget(Handle plugin,int numParams)
{
	return EntRefToEntIndex(g_iSlenderTarget[GetNativeCell(1)]);
}

public int Native_GetBossMaster(Handle plugin,int numParams)
{
	return g_iSlenderCopyMaster[GetNativeCell(1)];
}

public int Native_GetBossState(Handle plugin,int numParams)
{
	return g_iSlenderState[GetNativeCell(1)];
}

public int Native_IsBossProfileValid(Handle plugin,int numParams)
{
	char sProfile[SF2_MAX_PROFILE_NAME_LENGTH];
	GetNativeString(1, sProfile, SF2_MAX_PROFILE_NAME_LENGTH);
	
	return IsProfileValid(sProfile);
}

public int Native_GetBossProfileNum(Handle plugin,int numParams)
{
	char sProfile[SF2_MAX_PROFILE_NAME_LENGTH];
	GetNativeString(1, sProfile, SF2_MAX_PROFILE_NAME_LENGTH);
	
	char sKeyValue[256];
	GetNativeString(2, sKeyValue, sizeof(sKeyValue));
	
	return GetProfileNum(sProfile, sKeyValue, GetNativeCell(3));
}

public int Native_GetBossProfileFloat(Handle plugin,int numParams)
{
	char sProfile[SF2_MAX_PROFILE_NAME_LENGTH];
	GetNativeString(1, sProfile, SF2_MAX_PROFILE_NAME_LENGTH);

	char sKeyValue[256];
	GetNativeString(2, sKeyValue, sizeof(sKeyValue));
	
	return view_as<int>(GetProfileFloat(sProfile, sKeyValue, view_as<float>(GetNativeCell(3))));
}

public int Native_GetBossProfileString(Handle plugin,int numParams)
{
	char sProfile[SF2_MAX_PROFILE_NAME_LENGTH];
	GetNativeString(1, sProfile, SF2_MAX_PROFILE_NAME_LENGTH);

	char sKeyValue[256];
	GetNativeString(2, sKeyValue, sizeof(sKeyValue));
	
	int iResultLen = GetNativeCell(4);
	char[] sResult = new char[iResultLen];
	
	char sDefaultValue[512];
	GetNativeString(5, sDefaultValue, sizeof(sDefaultValue));
	
	bool bSuccess = GetProfileString(sProfile, sKeyValue, sResult, iResultLen, sDefaultValue);
	
	SetNativeString(3, sResult, iResultLen);
	return bSuccess;
}

public int Native_GetBossProfileVector(Handle plugin,int numParams)
{
	char sProfile[SF2_MAX_PROFILE_NAME_LENGTH];
	GetNativeString(1, sProfile, SF2_MAX_PROFILE_NAME_LENGTH);

	char sKeyValue[256];
	GetNativeString(2, sKeyValue, sizeof(sKeyValue));
	
	float flResult[3];
	float flDefaultValue[3];
	GetNativeArray(4, flDefaultValue, 3);
	
	bool bSuccess = GetProfileVector(sProfile, sKeyValue, flResult, flDefaultValue);
	
	SetNativeArray(3, flResult, 3);
	return bSuccess;
}

public int Native_GetRandomStringFromBossProfile(Handle plugin,int numParams)
{
	char sProfile[SF2_MAX_PROFILE_NAME_LENGTH];
	GetNativeString(1, sProfile, SF2_MAX_PROFILE_NAME_LENGTH);

	char sKeyValue[256];
	GetNativeString(2, sKeyValue, sizeof(sKeyValue));
	
	int iBufferLen = GetNativeCell(4);
	char[] sBuffer = new char[iBufferLen];
	
	int iIndex = GetNativeCell(5);
	
	bool bSuccess = GetRandomStringFromProfile(sProfile, sKeyValue, sBuffer, iBufferLen, iIndex);
	SetNativeString(3, sBuffer, iBufferLen);
	return bSuccess;
}