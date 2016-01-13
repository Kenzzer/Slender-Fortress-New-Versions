#if defined _sf2_logging_included
 #endinput
#endif
#define _sf2_logging_included

static String:g_strLogFilePath[512] = "";

InitializeLogging()
{
	decl String:sDateSuffix[256];
	FormatTime(sDateSuffix, sizeof(sDateSuffix), "sf2-%Y-%m-%d.log", GetTime());
	
	BuildPath(Path_SM, g_strLogFilePath, sizeof(g_strLogFilePath), "logs/%s", sDateSuffix);
	
	decl String:sMap[64];
	GetCurrentMap(sMap, sizeof(sMap));
	
	LogSF2Message("-------- Mapchange to %s -------", sMap);
}

stock LogSF2Message(const String:sMessage[], any:...)
{
	decl String:sLogMessage[1024], String:sTemp[1024];
	VFormat(sTemp, sizeof(sTemp), sMessage, 2);
	Format(sLogMessage, sizeof(sLogMessage), "%s", sTemp);
	LogToFile(g_strLogFilePath, sLogMessage);
}