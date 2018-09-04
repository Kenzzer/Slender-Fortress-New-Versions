Handle g_hSDKLookupSequence;
Handle g_hSDKAddGestureSequence;
Handle g_hSDKRemoveAllGestures;
Handle g_hSDKLookupPoseParameter;
Handle g_hSDKSetPoseParameter;

int g_ipStudioHdrOffset;

void CBaseAnimating_InitGameData(Handle hGameData)
{
	StartPrepSDKCall(SDKCall_Entity);
	PrepSDKCall_SetFromConf(hGameData, SDKConf_Signature, "CBaseAnimating::LookupSequence");
	PrepSDKCall_AddParameter(SDKType_String, SDKPass_Pointer);
	PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_ByValue);
	g_hSDKLookupSequence = EndPrepSDKCall();
	if (g_hSDKLookupSequence == INVALID_HANDLE) PrintToServer("Failed to retrieve CBaseAnimating::LookupSequence signature!");
	
	StartPrepSDKCall(SDKCall_Entity);
	PrepSDKCall_SetFromConf(hGameData, SDKConf_Signature, "CBaseAnimating::AddGestureSequence");
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_ByValue);
	PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_ByValue);
	g_hSDKAddGestureSequence = EndPrepSDKCall();
	//if (g_hSDKAddGestureSequence == INVALID_HANDLE) PrintToServer("Failed to retrieve CBaseAnimating::AddGestureSequence signature!");
	
	StartPrepSDKCall(SDKCall_Entity);
	PrepSDKCall_SetFromConf(hGameData, SDKConf_Signature, "CBaseAnimating::RemoveAllGestures");
	g_hSDKRemoveAllGestures = EndPrepSDKCall();
	//if (g_hSDKRemoveAllGestures == INVALID_HANDLE) PrintToServer("Failed to retrieve CBaseAnimating::RemoveAllGestures signature!");
	
	StartPrepSDKCall(SDKCall_Entity);
	PrepSDKCall_SetFromConf(hGameData, SDKConf_Signature, "CBaseAnimating::LookupPoseParameter");
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_ByValue);
	PrepSDKCall_AddParameter(SDKType_String, SDKPass_Pointer);
	PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_ByValue);
	g_hSDKLookupPoseParameter = EndPrepSDKCall();
	if (g_hSDKLookupPoseParameter == INVALID_HANDLE) PrintToServer("Failed to retrieve CBaseAnimating::LookupPoseParameter signature!");
	
	StartPrepSDKCall(SDKCall_Entity);
	PrepSDKCall_SetFromConf(hGameData, SDKConf_Signature, "CBaseAnimating::SetPoseParameter");
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_ByValue);
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_ByValue);
	PrepSDKCall_AddParameter(SDKType_Float, SDKPass_Plain);
	g_hSDKSetPoseParameter = EndPrepSDKCall();
	if (g_hSDKSetPoseParameter == INVALID_HANDLE) PrintToServer("Failed to retrieve CBaseAnimating::SetPoseParameter signature!");
	
	g_ipStudioHdrOffset = GameConfGetOffset(hGameData, "CBaseAnimating::m_pStudioHdr");
}

stock int CBaseAnimating_LookupSequence(int iEntity, const char[] sName)
{
	if (g_hSDKLookupSequence != INVALID_HANDLE)
	{
		return SDKCall(g_hSDKLookupSequence, iEntity, sName);
	}
	return -1;
}

stock void CBaseAnimating_AddGestureSequence(int iEntity, int iSequence, bool bAutoKill)
{
	if (g_hSDKAddGestureSequence != INVALID_HANDLE)
	{
		SDKCall(g_hSDKAddGestureSequence, iEntity, iSequence, bAutoKill);
	}
}

stock void CBaseAnimating_RemoveAllGestures(int iEntity)
{
	if (g_hSDKRemoveAllGestures != INVALID_HANDLE)
	{
		SDKCall(g_hSDKRemoveAllGestures, iEntity);
	}
}

stock Address CBaseAnimating_GetModelPtr(int iEntity)
{
	Address pStudioHdr = view_as<Address>(GetEntData(iEntity, g_ipStudioHdrOffset * 4));
	if (!IsValidAddress(pStudioHdr)) return Address_Null;
	return pStudioHdr;
}

stock int CBaseAnimating_LookupPoseParameter(int iEntity, Address pStudioHdr, const char[] sParamName)
{
	if (g_hSDKLookupPoseParameter != INVALID_HANDLE)
	{
		return SDKCall(g_hSDKLookupPoseParameter, iEntity, pStudioHdr, sParamName);
	}
	return -1;
}

stock void CBaseAnimating_SetPoseParameter(int iEntity, Address pStudioHdr, int iPoseParam, float flNewValue)
{
	if (g_hSDKLookupPoseParameter != INVALID_HANDLE)
	{
		SDKCall(g_hSDKSetPoseParameter, iEntity, pStudioHdr, iPoseParam, flNewValue);
	}
}
