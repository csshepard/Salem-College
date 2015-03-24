PROGRAM_NAME='_DSP_Biamp'
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 07/03/2014  AT: 15:04:28        *)
(***********************************************************)



DEFINE_CONSTANT

INTEGER MIC_MUTE 		= 69
INTEGER PROG_MUTE 		= 26

INTEGER TOGGLE	= 3


SLONG VOL_MIN			= 550  
SLONG VOL_MAX			= 1030
INTEGER VOL_INCREMENT		= 20

INTEGER nMUTE_BTNS[] = {PROG_MUTE, MIC_MUTE}

INTEGER VOLUME_CONTROL_CHANS[4][3] =  // [1] Unit #; [2] instance ID; [3] channel
{
    {1,31,3},  // room a
    {1,31,2},  // room b
    {1,31,1},  // room c
    {1,31,4}   // incoming telco
}

INTEGER MIC_CONTROL_CHANS[3][3] = // [1] Unit #; [2] instance ID; [3] channel
{
    {1,34,3},  // room a
    {1,34,2},  // room b
    {1,34,1}   // room c
}


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
VOLATILE SLONG nCalcVol
VOLATILE INTEGER nJudgePriority
VOLATILE SLONG nTelcoVolLvl	= 850;
VOLATILE INTEGER nPhonePresetBtns[] = {2001,2002,2003}
VOLATILE INTEGER blnHold
PERSISTENT CHAR cPhonePresets[3][25]





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


DEFINE_FUNCTION fnAudioVolLvl(INTEGER nWhichRm, SLONG nLvl)
{
    //SEND_STRING dvDSP, "'SETLD 1 FDRLVL ',ID_CEILING_SPEAKERS,' 1 ',ITOA(nLvl),$0A"
    
    nProgramVolLvl[nWhichRm] = nLvl;
    nCalcVol = Scale_Range(nProgramVolLvl[nWhichRm],VOL_MIN,VOL_MAX,0,100);	
    SEND_COMMAND dvaTP_Audio_13[nWhichRm], "'^TXT-500,0,', ITOA(nCalcVol)";
    SEND_STRING dvDSP, "'SETLD ', ITOA(VOLUME_CONTROL_CHANS[nWhichRm][1]), ' FDRLVL ', ITOA(VOLUME_CONTROL_CHANS[nWhichRm][2]), ' ', ITOA(VOLUME_CONTROL_CHANS[nWhichRm][3]), ' ', ITOA(nLvl), $0A";  
    IF(nCurrentRoomControl == nWhichRm) SEND_COMMAND dvTP_Audio_Op, "'^TXT-500,0,', ITOA(nCalcVol)";    // operator panel
    
    SWITCH(nWhichRm)
    {
	CASE ROOM_A:
	{
	    IF(blnCombined[PARTITION_AB])  
	    {
		nProgramVolLvl[ROOM_B] = nLvl;
		SEND_STRING dvDSP, "'SETLD ', ITOA(VOLUME_CONTROL_CHANS[ROOM_B][1]), ' FDRLVL ', ITOA(VOLUME_CONTROL_CHANS[ROOM_B][2]), ' ', ITOA(VOLUME_CONTROL_CHANS[ROOM_B][3]), ' ', ITOA(nLvl), $0A";  
		SEND_COMMAND dvaTP_Audio_13[ROOM_B], "'^TXT-500,0,', ITOA(nCalcVol)";    
		IF(blnCombined[PARTITION_BC]) // all 3 combined
		{
		    nProgramVolLvl[ROOM_C] = nLvl;
		    SEND_COMMAND dvaTP_Audio_13[ROOM_C], "'^TXT-500,0,', ITOA(nCalcVol)";    
		    SEND_STRING dvDSP, "'SETLD ', ITOA(VOLUME_CONTROL_CHANS[ROOM_C][1]), ' FDRLVL ', ITOA(VOLUME_CONTROL_CHANS[ROOM_C][2]), ' ', ITOA(VOLUME_CONTROL_CHANS[ROOM_C][3]), ' ', ITOA(nLvl), $0A";  
		}
	    }
	}
	CASE ROOM_B:
	{
	    IF(blnCombined[PARTITION_AB]) 
	    {
		nProgramVolLvl[ROOM_A] = nLvl;
		SEND_STRING dvDSP, "'SETLD ', ITOA(VOLUME_CONTROL_CHANS[ROOM_A][1]), ' FDRLVL ', ITOA(VOLUME_CONTROL_CHANS[ROOM_A][2]), ' ', ITOA(VOLUME_CONTROL_CHANS[ROOM_A][3]), ' ', ITOA(nLvl), $0A";  
		SEND_COMMAND dvaTP_Audio_13[ROOM_A], "'^TXT-500,0,', ITOA(nCalcVol)";    
		//IF(blnCombined[PARTITION_BC]) SEND_COMMAND dvaTP_Audio_13[ROOM_C], "'^TXT-500,0,', ITOA(nCalcVol)";    
	    }
	    IF(blnCombined[PARTITION_BC]) 
	    {
		nProgramVolLvl[ROOM_C] = nLvl;
		SEND_STRING dvDSP, "'SETLD ', ITOA(VOLUME_CONTROL_CHANS[ROOM_C][1]), ' FDRLVL ', ITOA(VOLUME_CONTROL_CHANS[ROOM_C][2]), ' ', ITOA(VOLUME_CONTROL_CHANS[ROOM_C][3]), ' ', ITOA(nLvl), $0A";  
		SEND_COMMAND dvaTP_Audio_13[ROOM_C], "'^TXT-500,0,', ITOA(nCalcVol)";    
		//IF(blnCombined[PARTITION_BC]) SEND_COMMAND dvaTP_Audio_13[ROOM_C], "'^TXT-500,0,', ITOA(nCalcVol)";    
	    }

	}
	CASE ROOM_C:
	{
	    IF(blnCombined[PARTITION_BC])  
	    {
		nProgramVolLvl[ROOM_B] = nLvl;
		SEND_STRING dvDSP, "'SETLD ', ITOA(VOLUME_CONTROL_CHANS[ROOM_B][1]), ' FDRLVL ', ITOA(VOLUME_CONTROL_CHANS[ROOM_B][2]), ' ', ITOA(VOLUME_CONTROL_CHANS[ROOM_B][3]), ' ', ITOA(nLvl), $0A";  
		SEND_COMMAND dvaTP_Audio_13[ROOM_B], "'^TXT-500,0,', ITOA(nCalcVol)";    
		IF(blnCombined[PARTITION_AB]) // all 3 combined
		{
		    nProgramVolLvl[ROOM_A] = nLvl;
		    SEND_COMMAND dvaTP_Audio_13[ROOM_A], "'^TXT-500,0,', ITOA(nCalcVol)";    
		    SEND_STRING dvDSP, "'SETLD ', ITOA(VOLUME_CONTROL_CHANS[ROOM_A][1]), ' FDRLVL ', ITOA(VOLUME_CONTROL_CHANS[ROOM_A][2]), ' ', ITOA(VOLUME_CONTROL_CHANS[ROOM_A][3]), ' ', ITOA(nLvl), $0A";  
		}
	    }
	}

    }
}

//DEFINE_FUNCTION fnMicVolLvl(SLONG nLvl)  //////// PROBABLY NOT USING /// WILL RE-WRITE IF NECESSARY TO USE FOR THIS ROOM
//{
//    SEND_STRING dvDSP, "'SETLD 2 FDRLVL 15 1 ',ITOA(nLvl),$0A"
//    
//    nMicLvl = nLvl;
//    nCalcVol = Scale_Range(nMicLvl,VOL_MIN,VOL_MAX,0,100);	
//    SEND_COMMAND dvaTP_Audio_13, "'^TXT-502,0,', ITOA(nCalcVol)";    
//}


DEFINE_FUNCTION fnTelcoVolLvl(SLONG nLvl)
{
    SEND_STRING dvDSP, "'SETLD ', ITOA(VOLUME_CONTROL_CHANS[4][1]), ' FDRLVL ', ITOA(VOLUME_CONTROL_CHANS[4][2]),' ', ITOA(VOLUME_CONTROL_CHANS[4][3]),' ',ITOA(nLvl),$0A"
    
    nTelcoVolLvl = nLvl;
    nCalcVol = Scale_Range(nTelcoVolLvl,VOL_MIN,VOL_MAX,0,100);	
    SEND_COMMAND dvaTP_Audio_13, "'^TXT-501,0,', ITOA(nCalcVol)";    
    SEND_COMMAND dvTP_Audio_Op, "'^TXT-501,0,', ITOA(nCalcVol)";
}


DEFINE_FUNCTION fnAudioMute(INTEGER nWhichRm, INTEGER nHow) // 0/FALSE = unmute; 1/TRUE = mute; 3 = toggle
{
     SWITCH(nHow)
     {
	  CASE TRUE:
	  CASE FALSE:
	  {
	    blnProgramMute[nWhichRm] = nHow;
	    SEND_STRING dvDSP, "'SETD ', ITOA(VOLUME_CONTROL_CHANS[nWhichRm][1]),' FDRMUTE ', ITOA(VOLUME_CONTROL_CHANS[nWhichRm][2]),' ', ITOA(VOLUME_CONTROL_CHANS[nWhichRm][3]),' ', ITOA(nHow),$0A"
	  
	    SWITCH(nWhichRm)
	    {
		CASE ROOM_A:
		{
		    IF(blnCombined[PARTITION_AB]) 
		    {
			blnProgramMute[ROOM_B] = nHow;
			SEND_STRING dvDSP, "'SETD ', ITOA(VOLUME_CONTROL_CHANS[ROOM_B][1]),' FDRMUTE ', ITOA(VOLUME_CONTROL_CHANS[ROOM_B][2]),' ', ITOA(VOLUME_CONTROL_CHANS[ROOM_B][3]),' ', ITOA(nHow),$0A"
			IF(blnCombined[PARTITION_BC]) // all 3 combined
			{
			    blnProgramMute[ROOM_C] = nHow;
			    SEND_STRING dvDSP, "'SETD ', ITOA(VOLUME_CONTROL_CHANS[ROOM_C][1]),' FDRMUTE ', ITOA(VOLUME_CONTROL_CHANS[ROOM_C][2]),' ', ITOA(VOLUME_CONTROL_CHANS[ROOM_C][3]),' ', ITOA(nHow),$0A"
			}
		    }
		}
		CASE ROOM_B:
		{
		    IF(blnCombined[PARTITION_AB]) 
		    {
			blnProgramMute[ROOM_A] = nHow;
			SEND_STRING dvDSP, "'SETD ', ITOA(VOLUME_CONTROL_CHANS[ROOM_A][1]),' FDRMUTE ', ITOA(VOLUME_CONTROL_CHANS[ROOM_A][2]),' ', ITOA(VOLUME_CONTROL_CHANS[ROOM_A][3]),' ', ITOA(nHow),$0A"
		    }
		    IF(blnCombined[PARTITION_BC]) 
		    {
			blnProgramMute[ROOM_C] = nHow;
			SEND_STRING dvDSP, "'SETD ', ITOA(VOLUME_CONTROL_CHANS[ROOM_C][1]),' FDRMUTE ', ITOA(VOLUME_CONTROL_CHANS[ROOM_C][2]),' ', ITOA(VOLUME_CONTROL_CHANS[ROOM_C][3]),' ', ITOA(nHow),$0A"
		    }
	
		}
		CASE ROOM_C:
		{
		    IF(blnCombined[PARTITION_BC]) 
		    {
			blnProgramMute[ROOM_B] = nHow;
			SEND_STRING dvDSP, "'SETD ', ITOA(VOLUME_CONTROL_CHANS[ROOM_B][1]),' FDRMUTE ', ITOA(VOLUME_CONTROL_CHANS[ROOM_B][2]),' ', ITOA(VOLUME_CONTROL_CHANS[ROOM_B][3]),' ', ITOA(nHow),$0A"
			IF(blnCombined[PARTITION_AB]) // all 3 combined
			{
			    blnProgramMute[ROOM_A] = nHow;
			    SEND_STRING dvDSP, "'SETD ', ITOA(VOLUME_CONTROL_CHANS[ROOM_A][1]),' FDRMUTE ', ITOA(VOLUME_CONTROL_CHANS[ROOM_A][2]),' ', ITOA(VOLUME_CONTROL_CHANS[ROOM_A][3]),' ', ITOA(nHow),$0A"
			}
		    }
		}
	
	    }
	  
	  }
	  CASE TOGGLE:
	  {
	       blnProgramMute[nWhichRm] = !blnProgramMute[nWhichRm];
	       fnAudioMute(nWhichRm,blnProgramMute[nWhichRm]);
	  }
     }
}

DEFINE_FUNCTION fnMicMute(INTEGER nWhichRm, INTEGER nHow)  // 0/FALSE = unmute; 1/TRUE = mute; 3 = toggle
{
     SWITCH(nHow)
     {
	  CASE TRUE:
	  CASE FALSE:
	  {
	    blnMicMute[nWhichRm] = nHow;
	    SEND_STRING dvDSP, "'SETD ', ITOA(MIC_CONTROL_CHANS[nWhichRm][1]),' MBMUTE ', ITOA(MIC_CONTROL_CHANS[nWhichRm][2]),' ', ITOA(MIC_CONTROL_CHANS[nWhichRm][3]),' ', ITOA(nHow),$0A"
	  
	    SWITCH(nWhichRm)
	    {
		CASE ROOM_A:
		{
		    IF(blnCombined[PARTITION_AB]) 
		    {
			blnMicMute[ROOM_B] = nHow;
			SEND_STRING dvDSP, "'SETD ', ITOA(MIC_CONTROL_CHANS[ROOM_B][1]),' MBMUTE ', ITOA(MIC_CONTROL_CHANS[ROOM_B][2]),' ', ITOA(MIC_CONTROL_CHANS[ROOM_B][3]),' ', ITOA(nHow),$0A"
			IF(blnCombined[PARTITION_BC]) // all 3 combined
			{
			    blnMicMute[ROOM_C] = nHow;
			    SEND_STRING dvDSP, "'SETD ', ITOA(MIC_CONTROL_CHANS[ROOM_C][1]),' MBMUTE ', ITOA(MIC_CONTROL_CHANS[ROOM_C][2]),' ', ITOA(MIC_CONTROL_CHANS[ROOM_C][3]),' ', ITOA(nHow),$0A"
			}
		    }
		}
		CASE ROOM_B:
		{
		    IF(blnCombined[PARTITION_AB]) 
		    {
			blnMicMute[ROOM_A] = nHow;
			SEND_STRING dvDSP, "'SETD ', ITOA(MIC_CONTROL_CHANS[ROOM_A][1]),' MBMUTE ', ITOA(MIC_CONTROL_CHANS[ROOM_A][2]),' ', ITOA(MIC_CONTROL_CHANS[ROOM_A][3]),' ', ITOA(nHow),$0A"
		    }
		    IF(blnCombined[PARTITION_BC]) 
		    {
			blnMicMute[ROOM_C] = nHow;
			SEND_STRING dvDSP, "'SETD ', ITOA(MIC_CONTROL_CHANS[ROOM_C][1]),' MBMUTE ', ITOA(MIC_CONTROL_CHANS[ROOM_C][2]),' ', ITOA(MIC_CONTROL_CHANS[ROOM_C][3]),' ', ITOA(nHow),$0A"
		    }
	
		}
		CASE ROOM_C:
		{
		    IF(blnCombined[PARTITION_BC]) 
		    {
			blnMicMute[ROOM_B] = nHow;
			SEND_STRING dvDSP, "'SETD ', ITOA(MIC_CONTROL_CHANS[ROOM_B][1]),' MBMUTE ', ITOA(MIC_CONTROL_CHANS[ROOM_B][2]),' ', ITOA(MIC_CONTROL_CHANS[ROOM_B][3]),' ', ITOA(nHow),$0A"
			IF(blnCombined[PARTITION_AB]) // all 3 combined
			{
			    blnMicMute[ROOM_A] = nHow;
			    SEND_STRING dvDSP, "'SETD ', ITOA(MIC_CONTROL_CHANS[ROOM_A][1]),' MBMUTE ', ITOA(MIC_CONTROL_CHANS[ROOM_A][2]),' ', ITOA(MIC_CONTROL_CHANS[ROOM_A][3]),' ', ITOA(nHow),$0A"
			}
		    }
		}
	
	    }
	  
	  }
	  CASE TOGGLE:
	  {
	       blnMicMute[nWhichRm] = !blnMicMute[nWhichRm];
	       fnMicMute(nWhichRm, blnMicMute[nWhichRm]);
	  }
     }
}




DEFINE_EVENT

DATA_EVENT[dvaTP_Audio_13]
DATA_EVENT[dvTP_Audio_Op]
{
    ONLINE:
    {
	STACK_VAR INTEGER x	
	FOR(x=1;x<=LENGTH_ARRAY(cPhonePresets);x++)
	    SEND_COMMAND DATA.DEVICE, "'^TXT-', ITOA(nPhonePresetBtns[x]), ',0,', cPhonePresets[x]";
    }
}

DATA_EVENT[dvDSP]
{
     ONLINE: SEND_COMMAND DATA.DEVICE, "'SET BAUD 38400,N,8,1'";
     STRING:
     {
	SELECT
	{
	    ACTIVE(FIND_STRING(DATA.TEXT,'TIHOOKSTATE 24 0',1)): nPhoneOffHook = TRUE;
	    ACTIVE(FIND_STRING(DATA.TEXT,'TIHOOKSTATE 24 1',1)): nPhoneOffHook = FALSE;
	    ACTIVE(FIND_STRING(DATA.TEXT,"'LGCMTRSTATE 33 1 1'",1)):	
	    {
		SEND_COMMAND dvaTP_Audio_13[ROOM_C], "'@PPN-_PhoneCall'";
		SEND_COMMAND dvaTP_Audio_13[ROOM_C], "'ADBEEP'";
		SEND_COMMAND dvTP_Audio_Op, "'@PPN-_PhoneCall'";
		SEND_COMMAND dvTP_Audio_Op, "'ADBEEP'";
		
		IF(blnCombined[PARTITION_BC]) 
		{
		    SEND_COMMAND dvaTP_Audio_13[ROOM_B], "'@PPN-_PhoneCall'";
		    SEND_COMMAND dvaTP_Audio_13[ROOM_B], "'ADBEEP'";
		    
		    IF(blnCombined[PARTITION_AB])
		    {
			SEND_COMMAND dvaTP_Audio_13[ROOM_A], "'@PPN-_PhoneCall'";
			SEND_COMMAND dvaTP_Audio_13[ROOM_A], "'ADBEEP'";
		    }
		}
		
	    }	    
	    ACTIVE(FIND_STRING(DATA.TEXT,"'LGCMTRSTATE 33 1 0'",1)): 
	    {
		SEND_COMMAND dvaTP_Audio_13, "'PPOF-_PhoneCall'";	  
		SEND_COMMAND dvTP_Audio_Op, "'PPOF-_PhoneCall'";	  
	    }
	}
	  
     }
}

BUTTON_EVENT[dvaTP_Audio_13,0]
{
    PUSH: nWhichRm = GET_LAST(dvaTP_Audio_13);
}



BUTTON_EVENT[dvaTP_Audio_13,24]  // room vol + 
BUTTON_EVENT[dvaTP_Audio_13,25]  // room vol - 
{
    PUSH:
    {
	IF(BUTTON.INPUT.CHANNEL == 24)
	{
	    IF(nProgramVolLvl[nWhichRm] < VOL_MAX)
		nProgramVolLvl[nWhichRm] = nProgramVolLvl[nWhichRm] + VOL_INCREMENT;
	}
	ELSE
	{
	    IF(nProgramVolLvl[nWhichRm] > VOL_MIN)
		nProgramVolLvl[nWhichRm] = nProgramVolLvl[nWhichRm] - VOL_INCREMENT;
	
	}
	
	fnAudioVolLvl(nWhichRm,nProgramVolLvl[nWhichRm]);
	
    }    
    HOLD[3,REPEAT]:
    {
	IF(BUTTON.INPUT.CHANNEL == 24)
	{
	    IF(nProgramVolLvl[nWhichRm] < VOL_MAX)
		nProgramVolLvl[nWhichRm] = nProgramVolLvl[nWhichRm] + VOL_INCREMENT;
	}
	ELSE
	{
	    IF(nProgramVolLvl[nWhichRm] > VOL_MIN)
		nProgramVolLvl[nWhichRm] = nProgramVolLvl[nWhichRm] - VOL_INCREMENT;
	
	}
	
	fnAudioVolLvl(nWhichRm,nProgramVolLvl[nWhichRm]);
    }
}


BUTTON_EVENT[dvaTP_Audio_13,PROG_MUTE]
{
     PUSH: fnAudioMute(nWhichRm,TOGGLE);
}



BUTTON_EVENT[dvaTP_Audio_13,MIC_MUTE]
{
     PUSH: fnMicMute(nWhichRm,TOGGLE);
}



////////////// TELCO //////////////////////


BUTTON_EVENT[dvaTP_Audio_13,124]  // telco rx vol + 
BUTTON_EVENT[dvaTP_Audio_13,125]  // teclo vol - 
BUTTON_EVENT[dvTP_Audio_Op,124]
BUTTON_EVENT[dvTP_Audio_Op,125]
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
BUTTON_EVENT[dvTP_Audio_Op,nDialingBtns]
{
     PUSH:
     {
	  IF(nPhoneOffHook)
	  {
	       SWITCH(BUTTON.INPUT.CHANNEL)
	       {
		    CASE 91: SEND_STRING dvDSP, "'DIAL 1 TIPHONENUM 24 *',$0A";
		    CASE 92: SEND_STRING dvDSP, "'DIAL 1 TIPHONENUM 24 #',$0A";
		    DEFAULT: SEND_STRING dvDSP, "'DIAL 1 TIPHONENUM 24 ',ITOA(BUTTON.INPUT.CHANNEL-80),$0A";
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
	  IF(!nPhoneOffHook) 
	  {
	    SEND_COMMAND dvaTP_Audio_13, "'^TXT-', ITOA(TC_DIALER_TXT), ',0,', cDialerString";
	    SEND_COMMAND dvTP_Audio_Op, "'^TXT-', ITOA(TC_DIALER_TXT), ',0,', cDialerString";
	  }
     }
}

BUTTON_EVENT[dvaTP_Audio_13,TC_DIAL_BACK]
BUTTON_EVENT[dvaTP_Audio_13,TC_DIAL_CLEAR]
BUTTON_EVENT[dvTP_Audio_Op,TC_DIAL_BACK]
BUTTON_EVENT[dvTP_Audio_Op,TC_DIAL_CLEAR]

{
     PUSH:
     {
	  IF(BUTTON.INPUT.CHANNEL == TC_DIAL_BACK && LENGTH_STRING(cDialerString)) SET_LENGTH_STRING(cDialerString, (LENGTH_STRING(cDialerString)-1));
	  ELSE cDialerString = '';
     }
     RELEASE:
     {
	  SEND_COMMAND dvaTP_Audio_13, "'^TXT-', ITOA(TC_DIALER_TXT), ',0,', cDialerString";
	  SEND_COMMAND dvTP_Audio_Op, "'^TXT-', ITOA(TC_DIALER_TXT), ',0,', cDialerString";
     }
}

BUTTON_EVENT[dvaTP_Audio_13,TC_DIAL]	
BUTTON_EVENT[dvTP_Audio_Op,TC_DIAL]
{
     PUSH:
     {
	IF(LENGTH_STRING(cDialerString))	
	{
	    SEND_STRING dvDSP, "'SETD 1 TIHOOKSTATE 24 0', $0A";
	    WAIT 2 SEND_STRING dvDSP, "'DIAL 1 TIPHONENUM 24 ', cDialerString, $0A";
	}
	ELSE SEND_STRING dvDSP, "'SETD 1 TIHOOKSTATE 24 0', $0A";
     }
}

BUTTON_EVENT[dvaTP_Audio_13,TC_HANGUP]
BUTTON_EVENT[dvTP_Audio_Op,TC_HANGUP]
{
     PUSH: SEND_STRING dvDSP, "'SETD 1 TIHOOKSTATE 24 1', $0A";
}


BUTTON_EVENT[dvaTP_Audio_13,TC_ACCEPT]	// answer
BUTTON_EVENT[dvTP_Audio_Op,TC_ACCEPT]	// answer
{
     PUSH: 
     {
	SEND_STRING dvDSP, "'SETD 1 TIHOOKSTATE 24 0', $0A";
	SEND_COMMAND dvaTP_Audio_13, "'@PPX'";
	SEND_COMMAND dvaTP_Audio_13, "'PAGE-Main'";
	SEND_COMMAND dvaTP_Audio_13, "'@PPN-Phone;Main'";

	SEND_COMMAND dvTP_Audio_Op, "'@PPX'";
	SEND_COMMAND dvTP_Audio_Op, "'PAGE-Main'";
	SEND_COMMAND dvTP_Audio_Op, "'@PPN-Room Control;Main'";
	SEND_COMMAND dvTP_Audio_Op, "'@PPN-Phone;Main'";

	fnMicMute(nWhichRm,FALSE);
     }
}


BUTTON_EVENT[dvaTP_Audio_13,TC_IGNORE]  // Ignore
BUTTON_EVENT[dvTP_Audio_Op,TC_IGNORE]  // Ignore
{
     PUSH:
     {
	  SEND_STRING dvDSP, "'SETD 1 TIHOOKSTATE 24 0', $0A";
	  WAIT 2 SEND_STRING dvDSP, "'SETD 1 TIHOOKSTATE 24 1', $0A";
 
    }
}


BUTTON_EVENT[dvaTP_Audio_13,nPhonePresetBtns]
BUTTON_EVENT[dvTP_Audio_Op,nPhonePresetBtns]
{
    HOLD[30]:
    {
	blnHold = TRUE;
	cPhonePresets[GET_LAST(nPhonePresetBtns)] = cDialerString;
	SEND_COMMAND dvaTP_Audio_13, "'^TXT-', ITOA(nPhonePresetBtns[GET_LAST(nPhonePresetBtns)]), ',0,', cPhonePresets[GET_LAST(nPhonePresetBtns)]";
	SEND_COMMAND dvTP_Audio_Op, "'^TXT-', ITOA(nPhonePresetBtns[GET_LAST(nPhonePresetBtns)]), ',0,', cPhonePresets[GET_LAST(nPhonePresetBtns)]";
    }
    RELEASE:
    {
	IF(!blnHold)
	{
	    cDialerString = cPhonePresets[GET_LAST(nPhonePresetBtns)];
	    SEND_COMMAND dvaTP_Audio_13, "'^TXT-', ITOA(TC_DIALER_TXT), ',0,', cDialerString";
	    SEND_COMMAND dvTP_Audio_Op, "'^TXT-', ITOA(TC_DIALER_TXT), ',0,', cDialerString";
	    SEND_STRING dvDSP, "'SETD 1 TIHOOKSTATE 24 0', $0A";
	    WAIT 2 SEND_STRING dvDSP, "'DIAL 1 TIPHONENUM 24 ', cDialerString, $0A";
	}
	blnHold = FALSE;
    }
}


DEFINE_PROGRAM

WAIT 20 SEND_STRING dvDSP, "'GETD 1 LGCMTRSTATE 33 1',$0A";  // is it ringing?
//WAIT 50 SEND_STRING dvDSP, "'get phone_ring "Phone 1 In"',$0D";

[dvaTP_Audio_13,1000]			= nPhoneOffHook;
[dvTP_Audio_Op,1000]			= nPhoneOffHook;
[dvaTP_Audio_13[ROOM_A],PROG_MUTE] 	= blnProgramMute[ROOM_A];
[dvaTP_Audio_13[ROOM_B],PROG_MUTE] 	= blnProgramMute[ROOM_B];
[dvaTP_Audio_13[ROOM_C],PROG_MUTE] 	= blnProgramMute[ROOM_C];
[dvTP_Audio_Op,PROG_MUTE]		= blnProgramMute[nCurrentRoomControl];
[dvaTP_Audio_13[ROOM_A],MIC_MUTE] 	= blnMicMute[ROOM_A];
[dvaTP_Audio_13[ROOM_B],MIC_MUTE] 	= blnMicMute[ROOM_B];
[dvaTP_Audio_13[ROOM_C],MIC_MUTE] 	= blnMicMute[ROOM_C];
[dvTP_Audio_Op,MIC_MUTE]		= blnMicMute[nCurrentRoomControl];

