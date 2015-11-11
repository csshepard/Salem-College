PROGRAM_NAME='_DSP_Biamp'
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 10/16/2015  AT: 16:49:26        *)
(***********************************************************)



DEFINE_CONSTANT

INTEGER MIC_MUTE 		= 69
INTEGER PROG_MUTE 		= 26

INTEGER TOGGLE	= 3


SLONG VOL_MIN		= 560  
SLONG VOL_MAX			= 1020
INTEGER VOL_INCREMENT		= 20

//SLONG SSP_VOL_MIN	= -400  //Original Values
//SLONG SSP_VOL_MAX	= 0
//INTEGER SSP_VOL_INCREMENT = 20

SLONG SSP_VOL_MIN	= -1000  //Updated Values
SLONG SSP_VOL_MAX	= 0
INTEGER SSP_VOL_INCREMENT = 50

SLONG MIC_VOL_MIN	= 940
SLONG MIC_VOL_MAX	= 1060
INTEGER MIC_VOL_INCREMENT = 5


INTEGER nMUTE_BTNS[] = {PROG_MUTE, MIC_MUTE}

CHAR ID_CEILING_SPEAKERS[]	= '5'  

////////////////// TELCO //////////////////////
INTEGER nDialingBtns[] = 
{
     80,81,82,83,84,85,86,87,88,89,  // 0 - 9
     91,  // *
     92   // #
}

TC_DIAL		= 93
TC_HANGUP	= 94
TC_DIAL_BACK 	= 96
TC_DIAL_CLEAR	= 95
TC_FLASH	= 98

TC_ACCEPT 	= 60
TC_IGNORE	= 61

TC_DIALER_TXT	= 96


///////////////////////////////////////////////


DEFINE_TYPE

STRUCTURE _strVol
{
     SINTEGER Vol_Lvl		// store current vol
     SINTEGER Vol_Lvl_Temp  	// store when muted
     INTEGER Muted		// Boolean
}


DEFINE_VARIABLE

VOLATILE _strVol AudioStatus  
VOLATILE INTEGER nRoomAudioMute  // boolean - room audio mute
VOLATILE INTEGER nMicMute	// boolean - mic mute
VOLATILE CHAR cDialerString[50]
VOLATILE INTEGER nPhoneOffHook
VOLATILE SLONG nRoomVolLvl	= 50;
VOLATILE SLONG nCalcVol
VOLATILE INTEGER nJudgePriority
VOLATILE SLONG nMicLvl	= 1000;  // 0
VOLATILE SLONG nTelcoVolLvl	= 850;
VOLATILE INTEGER nOperatorMode
VOLATILE INTEGER nLobbyMute
VOLATILE INTEGER nPhonePresetBtns[] = {2001,2002,2003}
VOLATILE INTEGER blnHold
PERSISTENT CHAR cPhonePresets[3][25]

DEFINE_FUNCTION fnAudioVolLvl(SLONG nLvl)
{
    //SEND_STRING dvDSP, "'SETLD 1 FDRLVL ',ID_CEILING_SPEAKERS,' 1 ',ITOA(nLvl),$0A"
    //SEND_STRING dvSSP, "ITOA(nLvl),'V'";
    SEND_STRING dvSWITCHER, "$1B, 'd1*', ITOA(nLvl), 'grpm', $0D";
    
    nRoomVolLvl = nLvl;
    nCalcVol = Scale_Range(nRoomVolLvl,SSP_VOL_MIN,SSP_VOL_MAX,0,100);	
    SEND_COMMAND dvaTP_Audio_13, "'^TXT-500,0,', ITOA(nCalcVol)";    
}

DEFINE_FUNCTION fnSwitcherVolLvl(SLONG nLvl)
{
    SEND_STRING dvSWITCHER, "$1B, 'd1*', ITOA(nLvl), 'grpm', $0D";
}

DEFINE_FUNCTION fnMicVolLvl(SLONG nLvl)
{
    SEND_STRING dvDSP, "'SETLD 2 FDRLVL 15 1 ',ITOA(nLvl),$0A"
    
    nMicLvl = nLvl;
    nCalcVol = Scale_Range(nMicLvl,VOL_MIN,VOL_MAX,0,100);	
    SEND_COMMAND dvaTP_Audio_13, "'^TXT-502,0,', ITOA(nCalcVol)";    
}


DEFINE_FUNCTION fnTelcoVolLvl(SLONG nLvl)
{
    SEND_STRING dvDSP, "'SETLD 2 FDRLVL 15 2 ',ITOA(nLvl),$0A"
    
    nTelcoVolLvl = nLvl;
    nCalcVol = Scale_Range(nTelcoVolLvl,VOL_MIN,VOL_MAX,0,100);	
    SEND_COMMAND dvaTP_Audio_13, "'^TXT-501,0,', ITOA(nCalcVol)";    
}

define_function slong Scale_Range(slong Num_In, slong Min_In, slong Max_In, slong Min_Out, slong Max_Out){
 stack_var
 slong Val_In
 slong Range_In
 slong Range_Out
 slong Whole_Num
 float Num_Out

 Val_In = Num_In                 // Get input value
 if(Val_In == Min_In)            // Handle endpoints
  Num_Out = Min_Out
 else if(Val_In == Max_In)
  Num_Out = Max_Out
 else{                            // Otherwise scale...
  Range_In = Max_In - Min_In      // Establish input range
  Range_Out = Max_Out - Min_Out   // Establish output range
  Val_In = Val_In - Min_In        // Remove input offset
  Num_Out = Val_In * Range_Out    // Multiply by output range
  Num_Out = Num_Out / Range_In    // Then divide by input range
  Num_Out = Num_Out + Min_Out     // Add in minimum output value
  Whole_Num = type_cast(Num_Out)  // Store the whole number only of the result
  if(((Num_Out - Whole_Num)* 100.0) >= 50.0)
   Num_Out++    // round up
 }
 return type_cast(Num_Out)
}

DEFINE_FUNCTION fnAudioMute(INTEGER nHow) // 0/FALSE = unmute; 1/TRUE = mute; 3 = toggle
{
     SWITCH(nHow)
     {
	  CASE FALSE:
	  {
	       nRoomAudioMute = FALSE;
	       SEND_STRING dvDSP, "'SETD 1 FDRMUTE ',ID_CEILING_SPEAKERS,' 1 0',$0A"
	       SEND_STRING dvSSP, "'0Z'";
	  }
	  CASE TRUE:
	  {
	       nRoomAudioMute = TRUE;
	       SEND_STRING dvDSP, "'SETD 1 FDRMUTE ',ID_CEILING_SPEAKERS,' 1 1',$0A"
	       SEND_STRING dvSSP, "'1Z'";

	  }
	  CASE TOGGLE:
	  {
	       nRoomAudioMute = !nRoomAudioMute;
	       fnAudioMute(nRoomAudioMute);
	  }
     }
}

DEFINE_FUNCTION fnMicMute(INTEGER nHow)  // 0/FALSE = unmute; 1/TRUE = mute; 3 = toggle
{
     SWITCH(nHow)
     {
	  CASE FALSE: 
	  {
	       nMicMute = FALSE
	       SEND_STRING dvDSP, "'SETD 2 FDRMUTE 15 1 0',$0A"
	  }
	  CASE TRUE:
	  {
	       nMicMute = TRUE
	       SEND_STRING dvDSP, "'SETD 2 FDRMUTE 15 1 1',$0A"
	  }
	  CASE TOGGLE:
	  {
	       nMicMute = !nMicMute;
	       fnMicMute(nMicMute);
	  }
     }
}

DEFINE_FUNCTION fnLobbyMute(INTEGER nHow)  // 0/FALSE = unmute; 1/TRUE = mute; 3 = toggle
{
     SWITCH(nHow)
     {
	  CASE FALSE: 
	  {
	       nLobbyMute = FALSE
	       SEND_STRING dvDSP, "'SETD 2 SMMUTEOUT 12 4 0',$0A"
	  }
	  CASE TRUE:
	  {
	       nLobbyMute = TRUE
	       SEND_STRING dvDSP, "'SETD 2 SMMUTEOUT 12 4 1',$0A"
	  }
	  CASE TOGGLE:
	  {
	       nLobbyMute = !nLobbyMute;
	       fnLobbyMute(nLobbyMute);
	  }
     }
}


DEFINE_FUNCTION fnOperatorMode(INTEGER nOpCmd)
{
    nOperatorMode = nOpCmd;
    IF(nOpCmd) 	SEND_STRING dvDSP, "'RECALL 0 PRESET 1002',$0A";
    ELSE	SEND_STRING dvDSP, "'RECALL 0 PRESET 1003',$0A";
    nLobbyMute = TRUE
    SEND_STRING dvDSP, "'SETD 2 SMMUTEOUT 12 4 1',$0A"
}



DEFINE_EVENT


DATA_EVENT[dvDSP]
{
     ONLINE: SEND_COMMAND DATA.DEVICE, "'SET BAUD 38400,N,8,1'";
     STRING:
     {
	SELECT
	{
	    ACTIVE(FIND_STRING(DATA.TEXT,'TIHOOKSTATE 18 0',1)): nPhoneOffHook = TRUE;
	    ACTIVE(FIND_STRING(DATA.TEXT,'TIHOOKSTATE 18 1',1)): nPhoneOffHook = FALSE;
	    ACTIVE(FIND_STRING(DATA.TEXT,"'LGCMTRSTATE 40 1 1'",1)):	
	    {
		SEND_COMMAND dvaTP_Audio_13, "'@PPN-_PhoneCall'";
		SEND_COMMAND dvaTP_Audio_13, "'ADBEEP'";
	    }	    
	    ACTIVE(FIND_STRING(DATA.TEXT,"'LGCMTRSTATE 40 1 0'",1)): SEND_COMMAND dvaTP_Audio_13, "'PPOF-_PhoneCall'";	  
	}
	  
     }
}

DATA_EVENT[dvSSP]
{
    ONLINE: SEND_COMMAND DATA.DEVICE, "'SET BAUD 38400,N,8,1'";
}


BUTTON_EVENT[dvaTP_Audio_13,24]  // room vol + 
BUTTON_EVENT[dvaTP_Audio_13,25]  // room vol - 
{
    PUSH:
    {
	IF(BUTTON.INPUT.CHANNEL == 24)
	{
	    IF(nRoomVolLvl < SSP_VOL_MAX)
		nRoomVolLvl = nRoomVolLvl + SSP_VOL_INCREMENT;
	}
	ELSE
	{
	    IF(nRoomVolLvl > SSP_VOL_MIN)
		nRoomVolLvl = nRoomVolLvl - SSP_VOL_INCREMENT;
	
	}
	
	fnAudioVolLvl(nRoomVolLvl);
	
    }    
    HOLD[3,REPEAT]:
    {
	IF(BUTTON.INPUT.CHANNEL == 24)
	{
	    IF(nRoomVolLvl < SSP_VOL_MAX)
		nRoomVolLvl = nRoomVolLvl + SSP_VOL_INCREMENT;
	}
	ELSE
	{
	    IF(nRoomVolLvl > SSP_VOL_MIN)
		nRoomVolLvl = nRoomVolLvl - SSP_VOL_INCREMENT;
	
	}
	
	fnAudioVolLvl(nRoomVolLvl);
    }
}


BUTTON_EVENT[dvaTP_Audio_13,PROG_MUTE]
{
     PUSH: fnAudioMute(TOGGLE);
}



BUTTON_EVENT[dvaTP_Audio_13,224]  // mic vol +   (1060)
BUTTON_EVENT[dvaTP_Audio_13,225]  // mic vol -   (940)
{
    PUSH:
    {
	IF(BUTTON.INPUT.CHANNEL == 224)
	{
	    IF(nMicLvl < MIC_VOL_MAX)
		nMicLvl = nMicLvl + MIC_VOL_INCREMENT;
	}
	ELSE
	{
	    IF(nMicLvl > MIC_VOL_MIN)
		nMicLvl = nMicLvl - MIC_VOL_INCREMENT;
	
	}
	
	fnMicVolLvl(nMicLvl);
	
    }    
    HOLD[3,REPEAT]:
    {
	IF(BUTTON.INPUT.CHANNEL == 224)
	{
	    IF(nMicLvl < MIC_VOL_MAX)
		nMicLvl = nMicLvl + MIC_VOL_INCREMENT;
	}
	ELSE
	{
	    IF(nMicLvl > MIC_VOL_MIN)
		nMicLvl = nMicLvl - MIC_VOL_INCREMENT;
	
	}
	
	fnMicVolLvl(nMicLvl);
    }
}





BUTTON_EVENT[dvaTP_Audio_13,MIC_MUTE]
{
     PUSH: fnMicMute(TOGGLE);
}



////////////// TELCO //////////////////////


BUTTON_EVENT[dvaTP_Audio_13,124]  // telco rx vol + 
BUTTON_EVENT[dvaTP_Audio_13,125]  // teclo vol - 
{
    PUSH:
    {
	IF(BUTTON.INPUT.CHANNEL == 124)
	{
	    IF(nTelcoVolLvl < VOL_MAX)
		nTelcoVolLvl = nTelcoVolLvl + VOL_INCREMENT;
	}
	ELSE
	{
	    IF(nTelcoVolLvl > VOL_MIN)
		nTelcoVolLvl = nTelcoVolLvl - VOL_INCREMENT;
	
	}
	
	fnTelcoVolLvl(nTelcoVolLvl);
	
    }    
    HOLD[3,REPEAT]:
    {
	IF(BUTTON.INPUT.CHANNEL == 124)
	{
	    IF(nTelcoVolLvl < VOL_MAX)
		nTelcoVolLvl = nTelcoVolLvl + VOL_INCREMENT;
	}
	ELSE
	{
	    IF(nTelcoVolLvl > VOL_MIN)
		nTelcoVolLvl = nTelcoVolLvl - VOL_INCREMENT;
	
	}
	
	fnTelcoVolLvl(nTelcoVolLvl);
    }
}

BUTTON_EVENT[dvaTP_Audio_13,nDialingBtns]
{
     PUSH:
     {
	  IF(nPhoneOffHook)
	  {
	       SWITCH(BUTTON.INPUT.CHANNEL)
	       {
		    CASE 91: SEND_STRING dvDSP, "'DIAL 1 TIPHONENUM 18 *',$0A";
		    CASE 92: SEND_STRING dvDSP, "'DIAL 1 TIPHONENUM 18 #',$0A";
		    DEFAULT: SEND_STRING dvDSP, "'DIAL 1 TIPHONENUM 18 ',ITOA(BUTTON.INPUT.CHANNEL-80),$0A";
	       }
	  }
	  ELSE
	  {
	       SWITCH(BUTTON.INPUT.CHANNEL)
	       {
		    CASE 91: cDialerString = "cDialerString, '*'";
		    CASE 92: cDialerString = "cDialerString, '#'";
		    DEFAULT: cDialerString = "cDialerString, ITOA(BUTTON.INPUT.CHANNEL - 80)"
	       }
	  }
     }
     RELEASE:
     {
	  IF(!nPhoneOffHook) SEND_COMMAND dvaTP_Audio_13, "'^TXT-', ITOA(TC_DIALER_TXT), ',0,', cDialerString";
     }
}

BUTTON_EVENT[dvaTP_Audio_13,TC_DIAL_BACK]
BUTTON_EVENT[dvaTP_Audio_13,TC_DIAL_CLEAR]
{
     PUSH:
     {
	  IF(BUTTON.INPUT.CHANNEL == TC_DIAL_BACK && LENGTH_STRING(cDialerString)) SET_LENGTH_STRING(cDialerString, (LENGTH_STRING(cDialerString)-1));
	  ELSE cDialerString = '';
     }
     RELEASE:
     {
	  SEND_COMMAND dvaTP_Audio_13, "'^TXT-', ITOA(TC_DIALER_TXT), ',0,', cDialerString";
     }
}

BUTTON_EVENT[dvaTP_Audio_13,TC_DIAL]	
{
     PUSH:
     {
	IF(LENGTH_STRING(cDialerString))	
	{
	    SEND_STRING dvDSP, "'SETD 1 TIHOOKSTATE 18 0', $0A";
	    WAIT 2 SEND_STRING dvDSP, "'DIAL 1 TIPHONENUM 18 ', cDialerString, $0A";
	}
	ELSE SEND_STRING dvDSP, "'SETD 1 TIHOOKSTATE 18 0', $0A";
     }
}

BUTTON_EVENT[dvaTP_Audio_13,TC_HANGUP]
{
     PUSH: SEND_STRING dvDSP, "'SETD 1 TIHOOKSTATE 18 1', $0A";
}


BUTTON_EVENT[dvaTP_Audio_13,TC_ACCEPT]	// answer
{
     PUSH: 
     {
	SEND_STRING dvDSP, "'SETD 1 TIHOOKSTATE 18 0', $0A";
	SEND_COMMAND dvaTP_Audio_13, "'@PPX'";
	SEND_COMMAND dvaTP_Audio_13, "'PAGE-Main'";
	SEND_COMMAND dvaTP_Audio_13, "'@PPN-Phone;Main'";
	fnMicMute(FALSE);
     }
}


BUTTON_EVENT[dvaTP_Audio_13,TC_IGNORE]  // Ignore
{
     PUSH:
     {
	  SEND_STRING dvDSP, "'SETD 1 TIHOOKSTATE 18 0', $0A";
	  WAIT 2 SEND_STRING dvDSP, "'SETD 1 TIHOOKSTATE 18 1', $0A";
 
    }
}


BUTTON_EVENT[dvaTP_Audio_13,nPhonePresetBtns]
{
    HOLD[30]:
    {
	blnHold = TRUE;
	cPhonePresets[GET_LAST(nPhonePresetBtns)] = cDialerString;
	SEND_COMMAND dvaTP_Audio_13, "'^TXT-', ITOA(nPhonePresetBtns[GET_LAST(nPhonePresetBtns)]), ',0,', cPhonePresets[GET_LAST(nPhonePresetBtns)]";
    }
    RELEASE:
    {
	IF(!blnHold)
	{
	    cDialerString = cPhonePresets[GET_LAST(nPhonePresetBtns)];
	    SEND_COMMAND dvaTP_Audio_13, "'^TXT-', ITOA(TC_DIALER_TXT), ',0,', cDialerString";
	    SEND_STRING dvDSP, "'SETD 1 TIHOOKSTATE 18 0', $0A";
	    WAIT 2 SEND_STRING dvDSP, "'DIAL 1 TIPHONENUM 18 ', cDialerString, $0A";
	}
	blnHold = FALSE;
    }
}

///////////////////////////////////////////

// OPERATOR CONTROLS //

BUTTON_EVENT[dvaTP_Audio_13,3000] // operator mode
{
    PUSH:
    {
	nOperatorMode = !nOperatorMode;
	fnOperatorMode(nOperatorMode);
    }
}

BUTTON_EVENT[dvaTP_Audio_13,3001] // lobby mute
{
    PUSH: fnLobbyMute(TOGGLE);
}


DEFINE_PROGRAM

WAIT 20 SEND_STRING dvDSP, "'GETD 1 LGCMTRSTATE 40 1',$0A";  // is it ringing?
//WAIT 50 SEND_STRING dvDSP, "'get phone_ring "Phone 1 In"',$0D";

[dvaTP_Audio_13,1000]		= nPhoneOffHook;
[dvaTP_Audio_13,PROG_MUTE] 	= nRoomAudioMute;
[dvaTP_Audio_13,MIC_MUTE]  	= nMicMute;
[dvaTP_Audio_13,3001]	  	= !nLobbyMute;
[dvaTP_Audio_13,3000]	  	= nOperatorMode;





