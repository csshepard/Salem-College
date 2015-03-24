PROGRAM_NAME='_OperatorPanel'
(***********************************************************)
(*  FILE CREATED ON: 03/28/2014  AT: 15:30:26              *)
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 05/09/2014  AT: 14:00:48        *)
(***********************************************************)

//DEFINE_DEVICE

//dvTP_Op_Main_401 = 10004:1:0
//dvTP_Audio_Op	= 10004:13:0
//dvTP_Switcher_Op		= 10004:3:0  // operator panel
//dvTP_DVD_415	= 10004:15:0
//dvTP_DVD_416	= 10004:16:0
//dvTP_DVD_417	= 10004:17:0


(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_CONSTANT

INTEGER TXT_ROOM_CONTROLLING	= 2;  // txt box indicating which room(s) I'm controlling



(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_VARIABLE

VOLATILE INTEGER nOpModeBtns[] = {1,2,3,4}  // div/combine, source routing, room control, setup
VOLATILE INTEGER nCurrentOpMode	// which of the above am I doing...
VOLATILE INTEGER nRoomControlBtns[] = {1001,1002,1003}  // a,b,c (or whatever it's combined with)
VOLATILE INTEGER blnHolding

VOLATILE CHAR cRoomNames[3] = {'A','B','C'}

#IF_NOT_DEFINED nCurrentRoomControl
    VOLATILE INTEGER nCurrentRoomControl
#END_IF


(***********************************************************)
(*                  THE EVENTS GO BELOW                    *)
(***********************************************************)
DEFINE_EVENT


BUTTON_EVENT[dvTP_Op_Main_401,nOpModeBtns]
{
    PUSH:
    {
	nCurrentOpMode = GET_LAST(nOpModeBtns);
    }
}



//////////////////////////////////
////// ROUTING & DEVICES /////////
//////////////////////////////////

BUTTON_EVENT[dvTP_Switcher_Op,nVidInputBtns]
BUTTON_EVENT[dvTP_Switcher_Op,nVidOutputBtns]
{
    PUSH:
    {
	TO[BUTTON.INPUT]
	IF(BUTTON.INPUT.CHANNEL < 200)  // vid input
	{
	    nRoutingPair[OPERATOR][1] = GET_LAST(nVidInputBtns);
	}
	ELSE  // vid output
	{
	    nRoutingPair[OPERATOR][2] = GET_LAST(nVidOutputBtns);
	}
    }
    RELEASE:
    {
	IF(!blnHolding)
	{
	    IF(nRoutingPair[OPERATOR][1] && nRoutingPair[OPERATOR][2])
	    {
		SEND_STRING dvSWITCHER, "ITOA(nRoutingPair[OPERATOR][1]), '*', ITOA(nRoutingPair[OPERATOR][2]), '&'"
		
		SWITCH(nRoutingPair[OPERATOR][2])
		{
		    CASE 1: fnMonitor(1,'ON');
		    CASE 2: fnProjector(ROOM_B,'ON');
		    CASE 3: fnProjector(ROOM_C,'ON');
		    CASE 4: fnProjector(ROOM_B2,'ON');
		}
		
		SWITCH(nRoutingPair[OPERATOR][1])
		{
		    CASE vi_1:
		    CASE vi_6: SEND_STRING dvSWITCHER, "ITOA(nRoutingPair[OPERATOR][1]), '*', ITOA(ao_PGM[ROOM_A]), '$'";
		    CASE vi_2:
		    CASE vi_3:
		    CASE vi_7: SEND_STRING dvSWITCHER, "ITOA(nRoutingPair[OPERATOR][1]), '*', ITOA(ao_PGM[ROOM_B]), '$'";
		    CASE vi_4:
		    CASE vi_5:
		    CASE vi_8: SEND_STRING dvSWITCHER, "ITOA(nRoutingPair[OPERATOR][1]), '*', ITOA(ao_PGM[ROOM_C]), '$'";
		}
		
		SEND_COMMAND dvaTP_Switcher_03, "'^TXT-', ITOA(nVidRouteTxtBtns[nRoutingPair[OPERATOR][2]]), ',0,', UPPER_STRING(sSwitcherInfo[1].Inputs[nRoutingPair[OPERATOR][1]].SourceName)";
		SEND_COMMAND dvTP_Switcher_Op, "'^TXT-', ITOA(nVidRouteTxtBtns[nRoutingPair[OPERATOR][2]]), ',0,', UPPER_STRING(sSwitcherInfo[1].Inputs[nRoutingPair[OPERATOR][1]].SourceName)";
	    }
	}
	nRoutingPair[OPERATOR][2] = 0;
	blnHolding = FALSE;
    }
    HOLD[20]:  // unroute
    {
	IF(BUTTON.INPUT.CHANNEL > 200)
	{
	    blnHolding = TRUE;
	    SEND_STRING dvSWITCHER, "ITOA(0), '*', ITOA(nRoutingPair[OPERATOR][2]), '&'"
	    
	    SWITCH(nRoutingPair[OPERATOR][2])
	    {
		CASE vo_1: SEND_STRING dvSWITCHER, "ITOA(0), '*', ITOA(ao_PGM[ROOM_A]), '$'";
		CASE vo_2:
		CASE vo_4: SEND_STRING dvSWITCHER, "ITOA(0), '*', ITOA(ao_PGM[ROOM_B]), '$'";
		CASE vo_3: SEND_STRING dvSWITCHER, "ITOA(0), '*', ITOA(ao_PGM[ROOM_C]), '$'";
	    }
	    
	    SEND_COMMAND dvaTP_Switcher_03, "'^TXT-', ITOA(nVidRouteTxtBtns[nRoutingPair[OPERATOR][2]]), ',0,NO SOURCE'";
	    SEND_COMMAND dvTP_Switcher_Op, "'^TXT-', ITOA(nVidRouteTxtBtns[nRoutingPair[OPERATOR][2]]), ',0,NO SOURCE'";
	}
    }
}




//////////////////////////////////
////////// ROOM CONTROLS /////////
//////////////////////////////////

BUTTON_EVENT[dvTP_Op_Main_401,nRoomControlBtns]
{
    PUSH:
    {
	nCurrentRoomControl = GET_LAST(nRoomControlBtns);
	SEND_COMMAND dvTP_Op_Main_401, "'^TXT-2,0,', cRoomNames[nCurrentRoomControl]";  // Currently controlling
	SEND_COMMAND dvTP_Audio_Op, "'^TXT-500,0,', ITOA(Scale_Range(nProgramVolLvl[nCurrentRoomControl],VOL_MIN,VOL_MAX,0,100))"; // Vol % to panel
	
	// Handle phone control button
	IF(nCurrentRoomControl == ROOM_C || (nCurrentRoomControl == ROOM_B && blnCombined[PARTITION_BC]) || (nCurrentRoomControl == ROOM_A && blnCombined[PARTITION_AB] && blnCombined[PARTITION_BC])) 
	    SEND_COMMAND dvTP_Switcher_Op, "'^SHO-1002,1'";
	ELSE 
	    SEND_COMMAND dvTP_Switcher_Op, "'^SHO-1002,0'";
    }
}

// DVD for current room
// DVD actions being taken care of by IR module taking TP array, of which this panel is included for these devices
BUTTON_EVENT[dvTP_Switcher_Op,1001]  
{
    PUSH: SEND_COMMAND dvTP_Switcher_Op, "'@PPN-DVD ', cRoomNames[nCurrentRoomControl], ';Main'";
}



BUTTON_EVENT[dvTP_Audio_Op,24]  // room vol + 
BUTTON_EVENT[dvTP_Audio_Op,25]  // room vol - 
{
    PUSH:
    {
	IF(BUTTON.INPUT.CHANNEL == 24)
	{
	    IF(nProgramVolLvl[nCurrentRoomControl] < VOL_MAX)
		nProgramVolLvl[nCurrentRoomControl] = nProgramVolLvl[nCurrentRoomControl] + VOL_INCREMENT;
	}
	ELSE
	{
	    IF(nProgramVolLvl[nCurrentRoomControl] > VOL_MIN)
		nProgramVolLvl[nCurrentRoomControl] = nProgramVolLvl[nCurrentRoomControl] - VOL_INCREMENT;
	
	}
	
	fnAudioVolLvl(nCurrentRoomControl,nProgramVolLvl[nCurrentRoomControl]);
    }    
    HOLD[3,REPEAT]:
    {
	IF(BUTTON.INPUT.CHANNEL == 24)
	{
	    IF(nProgramVolLvl[nCurrentRoomControl] < VOL_MAX)
		nProgramVolLvl[nCurrentRoomControl] = nProgramVolLvl[nCurrentRoomControl] + VOL_INCREMENT;
	}
	ELSE
	{
	    IF(nProgramVolLvl[nCurrentRoomControl] > VOL_MIN)
		nProgramVolLvl[nCurrentRoomControl] = nProgramVolLvl[nCurrentRoomControl] - VOL_INCREMENT;
	
	}
	
	fnAudioVolLvl(nCurrentRoomControl,nProgramVolLvl[nCurrentRoomControl]);
    }
}


BUTTON_EVENT[dvTP_Audio_Op,PROG_MUTE]
{
     PUSH: fnAudioMute(nCurrentRoomControl,TOGGLE);
}

BUTTON_EVENT[dvTP_Audio_Op,MIC_MUTE]
{
     PUSH: fnMicMute(nCurrentRoomControl,TOGGLE);
}




////// Power

BUTTON_EVENT[dvTP_Op_Main_401,PWR_FB]  // power on or off selected room
{
    PUSH: 
    {
	IF(blnSysPow[nCurrentRoomControl])	SEND_COMMAND dvTP_Op_Main_401, "'@PPN-Power Down'";
	ELSE					SEND_COMMAND dvTP_Op_Main_401, "'@PPN-Power Up'";
    }	
}

BUTTON_EVENT[dvTP_Op_Main_401,1255]  // power on or off selected room
{
    PUSH: fnSysPow(nCurrentRoomControl,!blnSysPow[nCurrentRoomControl]);
}







(***********************************************************)
(*            THE ACTUAL PROGRAM GOES BELOW                *)
(***********************************************************)
DEFINE_PROGRAM

// Operator panel modes
[dvTP_Op_Main_401,nOpModeBtns[1]] 	= (nCurrentOpMode == 1);
[dvTP_Op_Main_401,nOpModeBtns[2]] 	= (nCurrentOpMode == 2);
[dvTP_Op_Main_401,nOpModeBtns[3]] 	= (nCurrentOpMode == 3);
[dvTP_Op_Main_401,nOpModeBtns[4]] 	= (nCurrentOpMode == 4);

// Operator currently controlling stuff...
[dvTP_Op_Main_401,nRoomControlBtns[1]] 	= (nCurrentRoomControl == 1);
[dvTP_Op_Main_401,nRoomControlBtns[2]] 	= (nCurrentRoomControl == 2);
[dvTP_Op_Main_401,nRoomControlBtns[3]] 	= (nCurrentRoomControl == 3);
[dvTP_Op_Main_401,PWR_FB]		= blnSysPow[nCurrentRoomControl];


// Routing
[dvTP_Switcher_Op,nVidInputBtns[1]]	= (nRoutingPair[OPERATOR][1] == vi_1);
[dvTP_Switcher_Op,nVidInputBtns[2]]	= (nRoutingPair[OPERATOR][1] == vi_2);
[dvTP_Switcher_Op,nVidInputBtns[3]]	= (nRoutingPair[OPERATOR][1] == vi_3);
[dvTP_Switcher_Op,nVidInputBtns[4]]	= (nRoutingPair[OPERATOR][1] == vi_4);
[dvTP_Switcher_Op,nVidInputBtns[5]]	= (nRoutingPair[OPERATOR][1] == vi_5);
[dvTP_Switcher_Op,nVidInputBtns[6]]	= (nRoutingPair[OPERATOR][1] == vi_6);
[dvTP_Switcher_Op,nVidInputBtns[7]]	= (nRoutingPair[OPERATOR][1] == vi_7);
[dvTP_Switcher_Op,nVidInputBtns[8]]	= (nRoutingPair[OPERATOR][1] == vi_8);
[dvTP_Switcher_Op,nVidInputBtns[9]]	= (nRoutingPair[OPERATOR][1] == vi_9);
[dvTP_Switcher_Op,nVidInputBtns[10]]	= (nRoutingPair[OPERATOR][1] == vi_10);
[dvTP_Switcher_Op,nVidInputBtns[11]]	= (nRoutingPair[OPERATOR][1] == vi_11);
[dvTP_Switcher_Op,nVidInputBtns[12]]	= (nRoutingPair[OPERATOR][1] == vi_12);
[dvTP_Switcher_Op,nVidInputBtns[13]]	= (nRoutingPair[OPERATOR][1] == vi_13);
[dvTP_Switcher_Op,nVidInputBtns[14]]	= (nRoutingPair[OPERATOR][1] == vi_14);
[dvTP_Switcher_Op,nVidInputBtns[15]]	= (nRoutingPair[OPERATOR][1] == vi_15);
[dvTP_Switcher_Op,nVidInputBtns[16]]	= (nRoutingPair[OPERATOR][1] == vi_16);
[dvTP_Switcher_Op,nVidInputBtns[17]]	= (nRoutingPair[OPERATOR][1] == vi_17);
[dvTP_Switcher_Op,nVidInputBtns[18]]	= (nRoutingPair[OPERATOR][1] == vi_18);
[dvTP_Switcher_Op,nVidInputBtns[19]]	= (nRoutingPair[OPERATOR][1] == vi_19);
[dvTP_Switcher_Op,nVidInputBtns[20]]	= (nRoutingPair[OPERATOR][1] == vi_20);
[dvTP_Switcher_Op,nVidInputBtns[21]]	= (nRoutingPair[OPERATOR][1] == vi_21);
[dvTP_Switcher_Op,nVidInputBtns[22]]	= (nRoutingPair[OPERATOR][1] == vi_22);
[dvTP_Switcher_Op,nVidInputBtns[23]]	= (nRoutingPair[OPERATOR][1] == vi_23);
[dvTP_Switcher_Op,nVidInputBtns[24]]	= (nRoutingPair[OPERATOR][1] == vi_24);
[dvTP_Switcher_Op,nVidInputBtns[25]]	= (nRoutingPair[OPERATOR][1] == vi_25);
[dvTP_Switcher_Op,nVidInputBtns[26]]	= (nRoutingPair[OPERATOR][1] == vi_26);
[dvTP_Switcher_Op,nVidInputBtns[27]]	= (nRoutingPair[OPERATOR][1] == vi_27);
[dvTP_Switcher_Op,nVidInputBtns[28]]	= (nRoutingPair[OPERATOR][1] == vi_28);
[dvTP_Switcher_Op,nVidInputBtns[29]]	= (nRoutingPair[OPERATOR][1] == vi_29);
[dvTP_Switcher_Op,nVidInputBtns[30]]	= (nRoutingPair[OPERATOR][1] == vi_30);
[dvTP_Switcher_Op,nVidInputBtns[31]]	= (nRoutingPair[OPERATOR][1] == vi_31);
[dvTP_Switcher_Op,nVidInputBtns[32]]	= (nRoutingPair[OPERATOR][1] == vi_32);
