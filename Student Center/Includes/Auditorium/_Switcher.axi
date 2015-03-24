PROGRAM_NAME='_Switcher'
(***********************************************************)
(*  FILE CREATED ON: 06/11/2013  AT: 09:26:03              *)
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 07/03/2014  AT: 10:54:09        *)
(***********************************************************)


DEFINE_CONSTANT


INTEGER TL_TIMED_DISPLAY_SHUTDOWN	= 10
LONG TL_TIMED_DISPLAY_SHUTDOWN_ARRAY[]	= {10000}  // run every 10 seconds


INTEGER ANALOG 	= 8
INTEGER DIGITAL = 7
INTEGER TX_OUTPUT = 6



DEFINE_VARIABLE

VOLATILE INTEGER blnHoldDest
VOLATILE INTEGER blnTableInputSelect
VOLATILE INTEGER blnPhoneControl
VOLATILE INTEGER blnCamControl
VOLATILE INTEGER nDisplayShutdownTracker[CONFIG_SWITCHER_NUMBER_OUTPUTS]
VOLATILE INTEGER blnShowRoutes
VOLATILE INTEGER nInputSignalType	

(***********************************************************)
(*       MUTUALLY EXCLUSIVE DEFINITIONS GO BELOW           *)
(***********************************************************)
DEFINE_MUTUALLY_EXCLUSIVE
(blnCamControl,blnPhoneControl,blnTableInputSelect)



DEFINE_FUNCTION fnMTX(INTEGER nInput, INTEGER nOutput, CHAR cLvl[])  // cLvl = V for Video; A for Audio
{
    STACK_VAR INTEGER x

    IF(cLvl == 'V')  
    {
	// Switch source on surround sound processor
	IF(nInput == 2101 || nInput == 2102)	SEND_STRING dvSSP, "'1!'";  // dvd or booth hdmi
	ELSE					SEND_STRING dvSSP, "'5!'";  // standard program
	
	IF(nInput > 2100)  // source is on secondary switcher
	{
	    nSwitcherTrack[nOutput] = nInput;	    
	    SEND_STRING dvSWITCHER, "ITOA(CONFIG_SWITCHER_SECONDARY_INPUTS[1]), '!'"; // main switch
	    SEND_STRING dvSwitcher_2, "ITOA(nInput - 2100),'!'";
	    SEND_COMMAND dvaTP_Switcher_03, "'^TXT-', ITOA(nVidRouteTxtBtns[nOutput]), ',0,', UPPER_STRING(sSwitcherInfo[2].Inputs[nInput - 2100].SourceName)";	    
	}
	ELSE 
	{
	    nSwitcherTrack[nOutput] = nInput;
	    IF(nInput)
	    {
		SEND_STRING dvSWITCHER, "ITOA(nInput), '!'";
		SEND_COMMAND dvaTP_Switcher_03, "'^TXT-', ITOA(nVidRouteTxtBtns[nOutput]), ',0,', UPPER_STRING(sSwitcherInfo[1].Inputs[nInput].SourceName)";
	    }
	    ELSE 	
	    {
		SEND_STRING dvSWITCHER, "ITOA(nInput), '!'";
		SEND_COMMAND dvaTP_Switcher_03, "'^TXT-', ITOA(nVidRouteTxtBtns[nOutput]), ',0,NO SOURCE'";
	    }

	
	    // Turn on the display; if VTC, turn on presentation mode
	    IF(nInput)  // if input wasn't 0
	    {
		SWITCH(sSwitcherInfo[1].Outputs[nOutput].DestType)
		{
		    CASE DISP_TYPE_DISP:
		    {
			//fnMonitor(sSwitcherInfo[1].Outputs[nOutput].DestSide,'ON')
			//fnMonitor(sSwitcherInfo[1].Outputs[nOutput].DestSide,'HDMI')
		    }
		    CASE DISP_TYPE_PROJ:
		    {
			IF(!blnAudioMode)
			{
			    fnProjector(1,'ON');
			    fnProjector(1,'HDMI');
			}
		    }

		    CASE DISP_TYPE_VTC:
		    {
			#IF_DEFINED CONFIG_VTC
			    ON[vdvCODEC,1];  // start visual concert
			#END_IF
		    }
		}
	    }

	}


    }
    
    IF(cLvl == 'A')
    {
	nCurrentAudioSrc = nInput;
	
	// Switch source on surround sound processor
	IF(nInput == 2101 || nInput == 2102)	SEND_STRING dvSSP, "'1!'";  // dvd or booth hdmi
	ELSE					SEND_STRING dvSSP, "'5!'";  // standard program	
	
	IF(nInput > 2100)
	{
	    SEND_STRING dvSWITCHER, "ITOA(CONFIG_SWITCHER_SECONDARY_INPUTS[1]), '!'"; // main switch	
	    SEND_STRING dvSwitcher_2, "ITOA(nInput - 2100),'!'";
	    SEND_COMMAND dvaTP_Switcher_03, "'^TXT-', ITOA(nAudRouteTxtBtns[nOutput]), ',0,', UPPER_STRING(sSwitcherInfo[2].Inputs[nInput - 2100].SourceName)";	    
	    
	}
	ELSE
	{
	    SEND_STRING dvSWITCHER, "ITOA(nInput), '!'"; // main switch	
	    IF(nInput)	SEND_COMMAND dvaTP_Switcher_03, "'^TXT-', ITOA(nAudRouteTxtBtns[nOutput]), ',0,', UPPER_STRING(sSwitcherInfo[1].Inputs[nInput].SourceName)";
	    ELSE	SEND_COMMAND dvaTP_Switcher_03, "'^TXT-', ITOA(nAudRouteTxtBtns[nOutput]), ',0,NO SOURCE'";
	}
    }
}




DEFINE_START

//TIMELINE_CREATE(TL_TIMED_DISPLAY_SHUTDOWN,TL_TIMED_DISPLAY_SHUTDOWN_ARRAY,LENGTH_ARRAY(TL_TIMED_DISPLAY_SHUTDOWN_ARRAY),TIMELINE_ABSOLUTE,TIMELINE_REPEAT)






DEFINE_EVENT


////////////////////////////////////////////////////////
///////////////////// VIDEO ROUTING ////////////////////
////////////////////////////////////////////////////////
///////////////////////// AND //////////////////////////
////////////////////////////////////////////////////////
///////////////////// AUDIO ROUTING ////////////////////
////////////////////////////////////////////////////////
BUTTON_EVENT[dvaTP_Switcher_03,nVidInputBtns]
BUTTON_EVENT[dvaTP_Switcher_03,nHDMISwtInputBtns]
BUTTON_EVENT[dvaTP_Switcher_03,nVidOutputBtns]
BUTTON_EVENT[dvaTP_Switcher_03,nAudOutputBtns]
{
    PUSH:
    {
	TO[BUTTON.INPUT];
	BIC = BUTTON.INPUT.CHANNEL;
	blnCamControl = FALSE;
	blnPhoneControl = FALSE;
	blnTableInputSelect = FALSE;
    }
    RELEASE:
    {
	STACK_VAR INTEGER x
	
	IF(!blnHoldDest)
	{
	    IF(BIC < 200)  // regular video input button
	    {
		nRoutingPair[1] = GET_LAST(nVidInputBtns);
		SEND_COMMAND dvaTP_Switcher_03, "'PPOF-_dev_Template'";  // call an unused page in the same group; to close all popups in the current group
		SEND_COMMAND dvaTP_Switcher_03, "'@PPN-', sSwitcherInfo[1].Inputs[nRoutingPair[1]].ControlPage, ';Main'";
		
		IF(nRoutingPair[1] >= vi_4 || nRoutingPair[1] == vi_1)  // this is for home page macros, assign a laptop input to be the one that comes up when macro 1 triggered
		{
		    sRoutingMacros[1].VideoRoutes[vo_1]	= nRoutingPair[1];	// can use the source (vi) and dest (vo) constants here
		    sRoutingMacros[1].AudioSource	= nRoutingPair[1];
		}
	
		nRoutingPair[2] = vo_Proj;
		IF(nRoutingPair[1] && nRoutingPair[2])
		{
		    fnMTX(nRoutingPair[1],nRoutingPair[2],'V');
		    fnMTX(nRoutingPair[1],ao_PGM,'A');
		}

		nRoutingPair[2] = 0;
	
	    }
	    ELSE IF(BIC > 2100)  // secondary switcher video inputs
	    {
		nRoutingPair[1] = BIC;
		SEND_COMMAND dvaTP_Switcher_03, "'PPOF-_dev_Template'";  // call an unused page in the same group; to close all popups in the current group
		SEND_COMMAND dvaTP_Switcher_03, "'@PPN-', sSwitcherInfo[2].Inputs[nRoutingPair[1] - 2100].ControlPage, ';Main'";
		
		IF(nRoutingPair[1] == 2101)  // this is for home page macros, assign a laptop input to be the one that comes up when macro 1 triggered
		{
		    sRoutingMacros[1].VideoRoutes[vo_1]	= nRoutingPair[1];	// can use the source (vi) and dest (vo) constants here
		    sRoutingMacros[1].AudioSource	= nRoutingPair[1];
		}

		nRoutingPair[2] = vo_Proj;
		IF(nRoutingPair[1] && nRoutingPair[2])
		{
		    fnMTX(nRoutingPair[1],nRoutingPair[2],'V');
		    fnMTX(nRoutingPair[1],ao_PGM,'A');
		}

		nRoutingPair[2] = 0;

	    }
	    ELSE IF(BIC > 200 && BIC < 300) //  video output button
	    {
		nRoutingPair[2] = GET_LAST(nVidOutputBtns);
		IF(nRoutingPair[1] && nRoutingPair[2])
		{
		    fnMTX(nRoutingPair[1],nRoutingPair[2],'V');
		    fnMTX(nRoutingPair[1],ao_PGM,'A');
		}

		nRoutingPair[2] = 0;
	    }
	    ELSE IF(BIC > 400) //  audio output button
	    {
		nRoutingPair[2] = GET_LAST(nAudOutputBtns);
		IF(nOpRoutingPair[1] && nRoutingPair[2])
		{
		    fnMTX(nOpRoutingPair[1],nRoutingPair[2],'A');
		}
		nRoutingPair[2] = 0;
	    }
	}
	blnHoldDest = FALSE;
    }
    HOLD[20]: // clear route to designated output
    {
	IF(BIC > 200 && BIC < 300) //  video output button
	{
	    blnHoldDest = TRUE;
	    nRoutingPair[2] = GET_LAST(nVidOutputBtns);
	    fnMTX(0,nRoutingPair[2],'V');
	    fnMTX(0,nRoutingPair[2],'A');
	    #IF_DEFINED CONFIG_VTC
//		IF((BIC - 200) == vo_4)
//		{
		    PULSE[vdvCODEC,2];  // stop visual concert
//		}
	    #END_IF
	}
	ELSE IF(BIC > 400) //  audio output button
	{
	    blnHoldDest = TRUE;
	    nRoutingPair[2] = GET_LAST(nAudOutputBtns);
	    fnMTX(0,nRoutingPair[2],'A');
	}
    }
}





BUTTON_EVENT[dvaTP_Switcher_03,1002]
{
    PUSH:
    {
	ON[blnPhoneControl];
	nRoutingPair[1] = 0;
    }
}







////////////////////////////////////////////////////////
//////// Show/Hide Routes on Routing Page //////////////
////////////////////////////////////////////////////////

BUTTON_EVENT[dvaTP_Switcher_03,1500]
{
    PUSH:
    {
	STACK_VAR INTEGER x
	blnShowRoutes = !blnShowRoutes;
	
	IF(blnShowRoutes)
	{
	    FOR(x=1;x<=CONFIG_SWITCHER_NUMBER_OUTPUTS;x++)
		SEND_COMMAND dvaTP_Switcher_03, "'^SHO-', ITOA(nVidRouteTxtBtns[x]), ',1'";
	}
	ELSE
	{
	    FOR(x=1;x<=CONFIG_SWITCHER_NUMBER_OUTPUTS;x++)
		SEND_COMMAND dvaTP_Switcher_03, "'^SHO-', ITOA(nVidRouteTxtBtns[x]), ',0'";	
	}
    }
}


////////////////////////////////////////////////////////
///////////////////// Video Mutes //////////////////////
////////////////////////////////////////////////////////
//
//BUTTON_EVENT[dvaTP_Switcher_03,VID_MUTE_BTN]
//{
//    PUSH:
//    {
//	blnVideoMute = !blnVideoMute
//	IF(blnVideoMute)
//	{
//	    SEND_COMMAND dvAllSwitcherPorts, "'VIDOUT_MUTE-ENABLE'";
//	}
//	ELSE
//	{
//	    SEND_COMMAND dvAllSwitcherPorts, "'VIDOUT_MUTE-DISABLE'";
//	}
//    }
//}



/////////////////////////////////////////////////////
////////////  DISPLAY SHUTDOWN TIMELINE /////////////
/////////////////////////////////////////////////////
//	This timeline will monitor the switcher		
//	tracking array. Any display without a
//	source for 5 minutes will be shut off
/////////////////////////////////////////////////////
//
//TIMELINE_EVENT[TL_TIMED_DISPLAY_SHUTDOWN]
//{
//    STACK_VAR INTEGER x
//    
//    FOR(x=1;x<=MAX_LENGTH_ARRAY(nDisplayShutdownTracker);x++)
//    {
//	IF(!nSwitcherTrack[1][x])	nDisplayShutdownTracker[x]++;
//	ELSE				nDisplayShutdownTracker[x] = 0;
//	
//	IF(nDisplayShutdownTracker[x] > 30)  // 5 minutes in 10 second increments
//	{
//	    SWITCH(x)
//	    {
//		CASE 1:  
//		{
//		    fnProjector(LEFT_PROJ,'OFF');
//		    fnMonitor(LEFT_DISP,'OFF');
//		}
//		CASE 2:  fnSmartProjector('OFF');
//		CASE 3:  
//		{
//		    fnProjector(RIGHT_PROJ,'OFF');
//		    fnMonitor(RIGHT_DISP,'OFF');
//		}
//		
//	    }
//	    nDisplayShutdownTracker[x] = 0;
//	}
//    }
//}
//
//




DEFINE_PROGRAM

[dvaTP_Switcher_03,VID_MUTE_BTN]	= blnVideoMute;

[dvaTP_Switcher_03,1002]		= blnPhoneControl;

[dvaTP_Switcher_03,1500]		= blnShowRoutes;

[dvaTP_Switcher_03,nVidInputBtns[1]]	= (nRoutingPair[1] == 1);
[dvaTP_Switcher_03,nVidInputBtns[2]]	= (nRoutingPair[1] == 2);
[dvaTP_Switcher_03,nVidInputBtns[3]]	= (nRoutingPair[1] == 3);
[dvaTP_Switcher_03,nVidInputBtns[4]]	= (nRoutingPair[1] == 4);
[dvaTP_Switcher_03,nVidInputBtns[5]]	= (nRoutingPair[1] == 5);
[dvaTP_Switcher_03,nVidInputBtns[6]]	= (nRoutingPair[1] == 6);
[dvaTP_Switcher_03,nVidInputBtns[7]]	= (nRoutingPair[1] == 7);
[dvaTP_Switcher_03,nVidInputBtns[8]]	= (nRoutingPair[1] == 8);
[dvaTP_Switcher_03,nVidInputBtns[9]]	= (nRoutingPair[1] == 9);
[dvaTP_Switcher_03,nVidInputBtns[10]]	= (nRoutingPair[1] == 10);
[dvaTP_Switcher_03,nVidInputBtns[11]]	= (nRoutingPair[1] == 11);
[dvaTP_Switcher_03,nVidInputBtns[12]]	= (nRoutingPair[1] == 12);
[dvaTP_Switcher_03,nVidInputBtns[13]]	= (nRoutingPair[1] == 13);
[dvaTP_Switcher_03,nVidInputBtns[14]]	= (nRoutingPair[1] == 14);
[dvaTP_Switcher_03,nVidInputBtns[15]]	= (nRoutingPair[1] == 15);
[dvaTP_Switcher_03,nVidInputBtns[16]]	= (nRoutingPair[1] == 16);
[dvaTP_Switcher_03,nVidInputBtns[17]]	= (nRoutingPair[1] == 17);
[dvaTP_Switcher_03,nVidInputBtns[18]]	= (nRoutingPair[1] == 18);
[dvaTP_Switcher_03,nVidInputBtns[19]]	= (nRoutingPair[1] == 19);
[dvaTP_Switcher_03,nVidInputBtns[20]]	= (nRoutingPair[1] == 20);
[dvaTP_Switcher_03,nVidInputBtns[21]]	= (nRoutingPair[1] == 21);
[dvaTP_Switcher_03,nVidInputBtns[22]]	= (nRoutingPair[1] == 22);
[dvaTP_Switcher_03,nVidInputBtns[23]]	= (nRoutingPair[1] == 23);
[dvaTP_Switcher_03,nVidInputBtns[24]]	= (nRoutingPair[1] == 24);
[dvaTP_Switcher_03,nVidInputBtns[25]]	= (nRoutingPair[1] == 25);
[dvaTP_Switcher_03,nVidInputBtns[26]]	= (nRoutingPair[1] == 26);
[dvaTP_Switcher_03,nVidInputBtns[27]]	= (nRoutingPair[1] == 27);
[dvaTP_Switcher_03,nVidInputBtns[28]]	= (nRoutingPair[1] == 28);
[dvaTP_Switcher_03,nVidInputBtns[29]]	= (nRoutingPair[1] == 29);
[dvaTP_Switcher_03,nVidInputBtns[30]]	= (nRoutingPair[1] == 30);
[dvaTP_Switcher_03,nVidInputBtns[31]]	= (nRoutingPair[1] == 31);
[dvaTP_Switcher_03,nVidInputBtns[32]]	= (nRoutingPair[1] == 32);

// Secondary Switcher Inputs
[dvaTP_Switcher_03,nHDMISwtInputBtns[1]]	= (nRoutingPair[1] == 2101);
[dvaTP_Switcher_03,nHDMISwtInputBtns[2]]	= (nRoutingPair[1] == 2102);
[dvaTP_Switcher_03,nHDMISwtInputBtns[3]]	= (nRoutingPair[1] == 2103);
[dvaTP_Switcher_03,nHDMISwtInputBtns[4]]	= (nRoutingPair[1] == 2104);
