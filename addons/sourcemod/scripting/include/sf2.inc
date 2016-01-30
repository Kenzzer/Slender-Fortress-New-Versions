#if defined _sf2_included
 #endinput
#endif
#define _sf2_included

// Some defines.
#define SF2_MAX_PROFILE_NAME_LENGTH 64
#define SF2_MAX_NAME_LENGTH 32

#define MAX_BOSSES 32
#define MAX_NODES -1

// Difficulty modifiers.
#define DIFFICULTY_EASY 0.75
#define DIFFICULTY_NORMAL 1.0
#define DIFFICULTY_HARD 2.0
#define DIFFICULTY_INSANE 3.5

// Music system flags.
#define MUSICF_PAGES1PERCENT (1 << 0)
#define MUSICF_PAGES25PERCENT (1 << 1)
#define MUSICF_PAGES50PERCENT (1 << 2)
#define MUSICF_PAGES75PERCENT (1 << 3)
#define MUSICF_DEATH (1 << 4)
#define MUSICF_CHASE (1 << 5)
#define MUSICF_CHASEVISIBLE (1 << 6)
#define MUSICF_ALERT (1 << 7)
#define MUSICF_20DOLLARS (1 << 8)

// Special round enumerations.
enum
{
	SPECIALROUND_DOUBLETROUBLE = 1,
	SPECIALROUND_INSANEDIFFICULTY,
	SPECIALROUND_SINGLEPLAYER,
	SPECIALROUND_DOUBLEMAXPLAYERS,
	SPECIALROUND_LIGHTSOUT,
	SPECIALROUND_BEACON,
	SPECIALROUND_DOOMBOX,
	SPECIALROUND_NOGRACE,
	SPECIALROUND_2DOUBLE,
	SPECIALROUND_DOUBLEROULETTE,
	SPECIALROUND_NIGHTVISION,
	SPECIALROUND_INFINITEFLASHLIGHT,
	SPECIALROUND_DREAMFAKEBOSSES,
	SPECIALROUND_EYESONTHECLOACK,
	SPECIALROUND_NOPAGEBONUS,
	SPECIALROUND_MAXROUNDS
};

// Boss state enumerations.
enum
{
	STATE_IDLE = 0,
	STATE_WANDER,
	STATE_ALERT,
	STATE_CHASE,
	STATE_ATTACK,
	STATE_STUN
};

enum SoundType
{
	SoundType_None = 0,
	SoundType_Footstep,
	SoundType_Voice,
	SoundType_Weapon
};

enum
{
	Difficulty_Easy = 0,
	Difficulty_Normal,
	Difficulty_Hard,
	Difficulty_Insane,
	Difficulty_Max
};

enum
{
	Static_None = 0,
	Static_Increase,
	Static_Decrease
};

enum
{
	SF2BossType_Unknown = -1,
	SF2BossType_Static = 0,
	SF2BossType_Creeper,
	SF2BossType_Chaser,
	SF2BossType_AdvancedChaser,
	SF2BossType_MaxTypes
};

enum SF2RoundState
{
	SF2RoundState_Invalid = -1,
	SF2RoundState_Waiting = 0,		// waiting for players
	SF2RoundState_Intro,				// if intro is enabled, intro stage for RED
	SF2RoundState_Active,			// round is running for RED
	SF2RoundState_Escape,			// escape stage for RED
	SF2RoundState_Outro				// round win for a team, next round coming soon
};

// Boss flags.
#define SFF_SPAWNONCE (1 << 0)
#define SFF_NOTELEPORT (1 << 1)
#define SFF_FAKE (1 << 2)
#define SFF_MARKEDASFAKE (1 << 3)
#define SFF_ATTACKWAITERS (1 << 4)
#define SFF_HASSTATICSHAKE (1 << 5)
#define SFF_STATICONLOOK (1 << 6)
#define SFF_STATICONRADIUS (1 << 7)
#define SFF_PROXIES (1 << 8)
#define SFF_WANDERMOVE (1 << 9)
#define SFF_HASJUMPSCARE (1 << 10)
#define SFF_HASSIGHTSOUNDS (1 << 11)
#define SFF_HASSTATICLOOPLOCALSOUND (1 << 12)
#define SFF_HASVIEWSHAKE (1 << 13)
#define SFF_COPIES (1 << 14)
#define SFF_ATTACKPROPS (1 << 15)

// Interrup conditions.
#define COND_HEARDSUSPICIOUSSOUND (1 << 0)
#define COND_HEARDFOOTSTEP (1 << 1)
#define COND_HEARDFOOTSTEPLOUD (1 << 2)
#define COND_HEARDWEAPON (1 << 3)
#define COND_HEARDVOICE (1 << 4)
#define COND_CHASETARGETINVALIDATED (1 << 5)
#define COND_SAWENEMY (1 << 5)


forward void SF2_OnBossAdded(int iBossIndex);

forward void SF2_OnBossSpawn(int iBossIndex);

forward void SF2_OnBossChangeState(int iBossIndex,int iOldState,int iNewState);

forward void SF2_OnBossRemoved(int iBossIndex);

forward void SF2_OnPagesSpawned();

forward void SF2_OnClientCollectPage(int pageEnt,int client);

forward void SF2_OnClientBlinked(int client);

forward void SF2_OnClientCaughtByBoss(int client,int iBossIndex);

forward Action SF2_OnClientGiveQueuePoints(int client,int &iAddAmount);

forward void SF2_OnClientActivateFlashlight(int client);

forward void SF2_OnClientDeactivateFlashlight(int client);

forward void SF2_OnClientBreakFlashlight(int client);

forward void SF2_OnClientEscape(int client);

forward void SF2_OnClientLooksAtBoss(int client,int iBossIndex);

forward void SF2_OnClientLooksAwayFromBoss(int client,int iBossIndex);

forward void SF2_OnClientStartDeathCam(int client,int iBossIndex);

forward void SF2_OnClientEndDeathCam(int client,int iBossIndex);

forward Action SF2_OnClientGetDefaultWalkSpeed(int client, float &flDefault);

forward Action SF2_OnClientGetDefaultSprintSpeed(int client, float &flDefault);

forward Action SF2_OnGroupGiveQueuePoints(int iGroupIndex, int &iAddAmount);

forward void SF2_OnClientDamagedByBoss(int client,int iBossIndex,int inflictor, float flDamage,int iDamageType);

forward void SF2_OnClientSpawnedAsProxy(int client);


/**
 * Returns a bool about the gamemode's state.
 *
 * @return				True if the gamemode is running, false if not.
 */
native bool SF2_IsRunning();

/**
 * Returns the current state of the round.
 *
 * @return				Current state or the round.
 */
native int SF2_GetRoundState();

/**
 * Returns the current difficulty of the round.
 *
 * @return				Integer of the difficulty.
 */
native int SF2_GetCurrentDifficulty();

/**
 * Returns the current difficulty of the round.
 *
 * @param iDifficulty	Difficulty number.
 * @return				Modifier float value of the indicated difficulty number.
 */
native float SF2_GetDifficultyModifier(int iDifficulty);

/**
 * Returns a bool indicating whether or not a special round is currently running.
 *
 * @return				True if a special round is running, false if not.
 */
native bool SF2_IsSpecialRoundRunning();

/**
 * Returns the type of special round that is running.
 *
 * @return				Special round type.
 */
native int SF2_GetSpecialRoundType();

/**
 * Returns a bool about the client's elimination state.
 *
 * @param client		Client index.
 * @return				True if the player is eliminated, false if not.
 */
native bool SF2_IsClientEliminated(int client);

/**
 * Returns a bool about the client's ghost mode state.
 *
 * @param client		Client index.
 * @return				True if the player is in Ghost Mode, false if not.
 */
native bool SF2_IsClientInGhostMode(int client);

/**
 * Returns a bool if the client is in a Player vs. Player zone or not.
 *
 * @param client		Client index.
 * @return				True if the player is in a PvP zone, false if not.
 */
native bool SF2_IsClientInPvP(int client);

/**
 * Tells whether if the client is a Proxy or not.
 *
 * @param client		Client index.
 * @return				True if the player is a Proxy, false if not.
 */
native bool SF2_IsClientProxy(int client);

/**
 * Tells whether or not the client is looking at the boss.
 *
 * @param client		Client index.
 * @param iBossIndex	Boss index.
 * @return				True if the player is a Proxy, false if not.
 */
native bool SF2_IsClientLookingAtBoss(int client,int iBossIndex);

/**
 * Gives the amount of times the client has blinked in one life. This count will reset upon spawn.
 *
 * @param client		Client index.
 * @return				Number of times the client has blinked in one life.
 */
native int SF2_GetClientBlinkCount(int client);

/**
 * If the client is a Proxy, then this returns the boss index that the client is associated with.
 *
 * @param client		Client index.
 * @return				If the client is a proxy, then this will return a boss index, -1 if not.
 */
native int SF2_GetClientProxyMaster(int client);

/**
 * If the client is a Proxy, then this returns the amount of Control points the client has left.
 *
 * @param client		Client index.
 * @return				If the client is a proxy, then this will return the amount of Control Points out of 100, else 0.
 */
native int SF2_GetClientProxyControlAmount(int client);

/**
 * If the client is a Proxy, then this returns the rate which each Control point will drain for the client.
 *
 * @param client		Client index.
 * @return				If the client is a proxy, then this will return a boss index, -1 if not.
 */
native float SF2_GetClientProxyControlRate(int client);

native void SF2_SetClientProxyMaster(int client,int iBossIndex);

native void SF2_SetClientProxyControlAmount(int client,int iAmount);

native void SF2_SetClientProxyControlRate(int client, float flAmount);

native void SF2_CollectAsPage(int pageEnt,int client);

native int SF2_GetMaxBossCount();

native int SF2_EntIndexToBossIndex(int iEntIndex);

native int SF2_BossIndexToEntIndex(int iBossIndex);

native int SF2_BossIDToBossIndex(int iBossID);

native int SF2_BossIndexToBossID(int iBossID);

native void SF2_GetBossName(int iBossIndex, char[] sBuffer,int iBufferLen);

native int SF2_GetBossModelEntity(int iBossIndex);

native int SF2_GetBossTarget(int iBossIndex);

native int SF2_GetBossMaster(int iBossIndex);

native int SF2_GetBossState(int iBossIndex);

native bool SF2_IsBossProfileValid(const char[] sProfile);

native int SF2_GetBossProfileNum(const char[] sProfile, const char[] sKey , int iDefaultValue=0);

native float SF2_GetBossProfileFloat(const char[] sProfile, const char[] sKey , float flDefaultValue=0.0);

native bool SF2_GetBossProfileString(const char[] sProfile, const char[] sKey , char[] sBuffer,int iBufferLen, const char sDefaultValue[]="");

native bool SF2_GetBossProfileVector(const char[] sProfile, const char[] sKey , float flBuffer[3], const float flDefaultValue[3]=NULL_VECTOR);

native bool SF2_GetRandomStringFromBossProfile(const char[] sProfile, const char[] sKey , char[] sBuffer,int iBufferLen,int iIndex=-1);

public SharedPlugin __pl_sf2 = 
{
	name = "sf2",
	file = "sf2.smx",
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif
};