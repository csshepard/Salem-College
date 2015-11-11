PROGRAM_NAME='_GenericSystemFunctions'
(***********************************************************)
(*  FILE CREATED ON: 07/08/2013  AT: 11:22:10              *)
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 10/16/2015  AT: 16:49:26        *)
(***********************************************************)

DEFINE_CONSTANT



///// Status Popups ///////
INTEGER tlStatusPopups	= 20	// timeline for rotating the status popups on the toolbar
LONG	tlStatusPopups_Array[] = {3000,3000,3000}


CHAR cStatusPopupNames[3][25] =
{
    'Status_SystemPower',
    'Status_DisplayPower1',
    'Status_Phone'
}

////////////////////////////



DEFINE_FUNCTION fnSysPow(INTEGER blnPowerAction)
{
    STACK_VAR INTEGER x

    IF(blnPowerAction)  // on
    {
	SEND_COMMAND dvaTP_MAIN_01, "'@PPN-Wait'";

	PULSE[dcPwr_On];

	fnMicMute(FALSE);
	fnAudioMute(FALSE);
	fnAudioVolLvl(-300);  // SSP
	//fnSwitcherVolLvl(-500) // IN-1608
	fnTelcoVolLvl(800);  // Biamp
	fnMicVolLvl(1000);  // Biamp
	fnLobbyMute(TRUE);
	fnOperatorMode(FALSE);

	
	IF(blnAudioMode) 
	{
	    TIMELINE_PAUSE(tlStatusPopups);
	    fnProjector(1,'OFF');
	    
	    WAIT 50
	    {
		SEND_COMMAND dvaTP_MAIN_01, "'@PPX'";
		SEND_COMMAND dvaTP_MAIN_01, "'PAGE-Main'";
		SEND_COMMAND dvaTP_MAIN_01, "'^SHO-3001,1'";  // audio only banner on main page
	    }
	    
	}
	ELSE
	{
	    fnProjector(1,'ON');
	    SEND_COMMAND dvaTP_MAIN_01, "'^SHO-3001,0'";  // audio only banner on main page
	    TIMELINE_RESTART(tlStatusPopups);

	    WAIT 600
	    {
		blnSysPow = TRUE;	
		fnProjector(1,'HDMI');
	    }
	}
	

	
    }
    ELSE  // off
    {
	blnAudioMode = FALSE;
	
	PULSE[dcPwr_Off];
	
	PULSE[dvDVD,2];
	PULSE[dvDVD,2];
	SEND_STRING dvSSP, "'5!'";  // standard program
	
	// reinit flags
	SEND_COMMAND dvaTP_Macros_01, "'^TXT-1000,0,'";
	blnPhoneControl = FALSE;
	
	SEND_STRING dvDSP, "'SETD 1 TIHOOKSTATE 18 1', $0A";  // hang up phone
	
	SEND_COMMAND dvaTP_MAIN_01, "'@PPX'";
	SEND_COMMAND dvaTP_MAIN_01, "'@PPN-Wait'";

	fnAudioMute(TRUE);
	fnMicMute(TRUE);
	fnProjector(1,'OFF');

	// clear routes
	FOR(x=1;x<=CONFIG_SWITCHER_NUMBER_OUTPUTS;x++)
	{
	    fnMTX(0,x,'V');  // clear video
	}
	
	fnMTX(0,ao_PGM,'A');
	
	WAIT 1200
	{
	    
	    blnSysPow = FALSE;

	    //fnProjector(1,'OFF');

	    fnAudioMute(TRUE);

	    SEND_COMMAND dvaTP_MAIN_01, "'@PPX'";
	    SEND_COMMAND dvaTP_MAIN_01, "'PAGE-Welcome'";
	}

    }
}




DEFINE_START

TIMELINE_CREATE(tlStatusPopups,tlStatusPopups_Array,LENGTH_ARRAY(tlStatusPopups_Array),TIMELINE_RELATIVE,TIMELINE_REPEAT)
//TIMELINE_CREATE(tlSwitcherReset,tlSwitcherReset_Array,LENGTH_ARRAY(tlSwitcherReset_Array),TIMELINE_ABSOLUTE,TIMELINE_REPEAT)

WAIT 200 
{
    SEND_COMMAND dvaTP_Main_01, "'PAGE-Welcome'";
    blnSysPow = FALSE;
    PULSE[dcPwr_Off];
}


DEFINE_EVENT


DATA_EVENT[dvaTP_MAIN_01]
{
    ONLINE:
    {
	SEND_COMMAND dvaTP_MAIN_01, "'^TXT-1,0,', RoomName"
    }
}


BUTTON_EVENT[dvaTP_MAIN_01,255]  // power down
{
    PUSH:
    {
	fnSysPow(FALSE);
    }
}


CHANNEL_EVENT[dvIOs,1]
{
    ON: fnSysPow(FALSE);
}

BUTTON_EVENT[dvaTP_MAIN_01,3001] // Power on w/ audio-only mode
{
    PUSH: 
    {
	blnAudioMode = TRUE;
	fnSysPow(TRUE);
    }
}


/////////////// Status Popups ///////////////
TIMELINE_EVENT[tlStatusPopups]
{
    IF(TIMELINE.SEQUENCE == 1) 	SEND_COMMAND dvaTP_Main_01, "'PPOF-', cStatusPopupNames[LENGTH_ARRAY(cStatusPopupNames)]";
    ELSE			SEND_COMMAND dvaTP_Main_01, "'PPOF-', cStatusPopupNames[TIMELINE.SEQUENCE - 1]";
    
    SEND_COMMAND dvaTP_Main_01, "'@PPN-', cStatusPopupNames[TIMELINE.SEQUENCE], ';Main'";


}


(***********************************************************)
(*            THE ACTUAL PROGRAM GOES BELOW                *)
(***********************************************************)
DEFINE_PROGRAM

[dvaTP_Main_01,PWR_FB]	= blnSysPow;


