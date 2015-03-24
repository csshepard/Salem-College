PROGRAM_NAME='_RoutingMacros'
(***********************************************************)
(*  FILE CREATED ON: 06/12/2013  AT: 10:41:35              *)
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 07/03/2014  AT: 09:26:24        *)
(***********************************************************)


DEFINE_EVENT

BUTTON_EVENT[dvaTP_Macros_01,nMacrosBtns]
{
    PUSH:
    {
	LOCAL_VAR INTEGER x

	IF(!blnSysPow || blnAudioMode) 
	{
	    blnAudioMode = FALSE;
	    fnSysPow(TRUE);
	}

	
	blnPhoneControl = FALSE;
	SEND_COMMAND dvaTP_Macros_01, "'@PPN-Wait'";
	
	//fnMicMute(TRUE);

	nWhichMacro = GET_LAST(nMacrosBtns);

	WAIT_UNTIL(blnSysPow)
	{
	    FOR(x=1;x<=CONFIG_SWITCHER_NUMBER_OUTPUTS;x++)
	    {
		IF(sRoutingMacros[nWhichMacro].VideoRoutes[x])
		    fnMTX(sRoutingMacros[nWhichMacro].VideoRoutes[x],x,'V');
	    }

	    SEND_COMMAND dvaTP_Macros_01, "'@PPX'";
	    SEND_COMMAND dvaTP_Macros_01, "'PAGE-Main'";

	    SEND_COMMAND dvaTP_Macros_01, "'@PPN-', sRoutingMacros[nWhichMacro].ControlPage, ';Main'";


	    // set this for control page fb
	    nRoutingPair[1] = sRoutingMacros[nWhichMacro].AudioSource;

	}
    }
}








DEFINE_PROGRAM

////////////