PROGRAM_NAME='_Switcher'
(***********************************************************)
(*  FILE CREATED ON: 06/11/2013  AT: 09:26:03              *)
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 05/13/2014  AT: 11:34:45        *)
(***********************************************************)


DEFINE_CONSTANT


INTEGER TL_TIMED_DISPLAY_SHUTDOWN	= 10
LONG TL_TIMED_DISPLAY_SHUTDOWN_ARRAY[]	= {10000}  // run every 10 seconds



DEFINE_VARIABLE

VOLATILE INTEGER blnHoldDest[3]
VOLATILE INTEGER blnPhoneControl[3]
VOLATILE INTEGER blnCamControl
VOLATILE INTEGER nDisplayShutdownTracker[CONFIG_SWITCHER_NUMBER_OUTPUTS]
VOLATILE INTEGER blnFirstRouteDone


(***********************************************************)
(*       MUTUALLY EXCLUSIVE DEFINITIONS GO BELOW           *)
(***********************************************************)
DEFINE_MUTUALLY_EXCLUSIVE
(blnPhoneControl[ROOM_A],blnPhoneControl[ROOM_B],blnPhoneControl[ROOM_C])



DEFINE_FUNCTION fnMTX(INTEGER nInput, INTEGER nOutput, CHAR cLvl[])  // cLvl = V for Video; A for Audio
{
    STACK_VAR INTEGER x

    IF(cLvl == 'V')  // if DVX, stick to "video switch," since audio always follows vid
    {
	nSwitcherTrack[nOutput] = nInput;
	SEND_STRING dvSWITCHER, "ITOA(nInput), '*', ITOA(nOutput), '&'";
	
	IF(nInput)	
	{
	    SEND_COMMAND dvaTP_Switcher_03, "'^TXT-', ITOA(nVidRouteTxtBtns[nOutput]), ',0,', UPPER_STRING(sSwitcherInfo[1].Inputs[nInput].SourceName)";
	    SEND_COMMAND dvTP_Switcher_Op, "'^TXT-', ITOA(nVidRouteTxtBtns[nOutput]), ',0,', UPPER_STRING(sSwitcherInfo[1].Inputs[nInput].SourceName)";
	}
	ELSE		
	{
	    SEND_COMMAND dvaTP_Switcher_03, "'^TXT-', ITOA(nVidRouteTxtBtns[nOutput]), ',0,NO SOURCE'";
	    SEND_COMMAND dvTP_Switcher_Op, "'^TXT-', ITOA(nVidRouteTxtBtns[nOutput]), ',0,NO SOURCE'";
	}
	

	// Turn on the display; if VTC, turn on presentation mode
//	IF(nInput)  // if input wasn't 0
//	{
//	    SWITCH(sSwitcherInfo[1].Outputs[nOutput].DestType)
//	    {
//		CASE DISP_TYPE_DISP:
//		{
//		    fnMonitor(1,'ON')
//		    fnMonitor(1,'HDMI')
//		}
//		CASE DISP_TYPE_PROJ:
//		{
//		    fnProjector(sSwitcherInfo[1].Outputs[nOutput].DestSide,'ON')
//		    fnProjector(sSwitcherInfo[1].Outputs[nOutput].DestSide,'HDMI')
//		}
//		CASE DISP_TYPE_VTC:
//		{
//		    #IF_DEFINED CONFIG_VTC
//			ON[vdvCODEC,1];  // start visual concert
//		    #END_IF
//		}
//	    }
//	}


    }
    
    
    IF(cLvl == 'A')
    {
	nCurrentAudioSrc[nWhichRm] = nInput;
	SEND_STRING dvSWITCHER, "ITOA(nInput), '*', ITOA(nOutput), '$'";
	
	
	IF(nInput)	
	{
	    SEND_COMMAND dvaTP_Switcher_03, "'^TXT-', ITOA(nAudRouteTxtBtns[nOutput]), ',0,', UPPER_STRING(sSwitcherInfo[1].Inputs[nInput].SourceName)";
	    SEND_COMMAND dvTP_Switcher_Op, "'^TXT-', ITOA(nAudRouteTxtBtns[nOutput]), ',0,', UPPER_STRING(sSwitcherInfo[1].Inputs[nInput].SourceName)";
	}
	ELSE
	{
	    SEND_COMMAND dvaTP_Switcher_03, "'^TXT-', ITOA(nAudRouteTxtBtns[nOutput]), ',0,NO SOURCE'";
	    SEND_COMMAND dvTP_Switcher_Op, "'^TXT-', ITOA(nAudRouteTxtBtns[nOutput]), ',0,NO SOURCE'";
	}
    }
}




DEFINE_START

//TIMELINE_CREATE(TL_TIMED_DISPLAY_SHUTDOWN,TL_TIMED_DISPLAY_SHUTDOWN_ARRAY,LENGTH_ARRAY(TL_TIMED_DISPLAY_SHUTDOWN_ARRAY),TIMELINE_ABSOLUTE,TIMELINE_REPEAT)






DEFINE_EVENT



BUTTON_EVENT[dvaTP_Switcher_03,0]
{
    PUSH:
    {
	nWhichRm = GET_LAST(dvaTP_Switcher_03);
    }
}



////////////////////////////////////////////////////////
///////////////////// VIDEO ROUTING ////////////////////
////////////////////////////////////////////////////////
///////////////////////// AND //////////////////////////
////////////////////////////////////////////////////////
///////////////////// AUDIO ROUTING ////////////////////
////////////////////////////////////////////////////////
BUTTON_EVENT[dvaTP_Switcher_03,nVidInputBtns]
BUTTON_EVENT[dvaTP_Switcher_03,nVidOutputBtns]
BUTTON_EVENT[dvaTP_Switcher_03,nAudOutputBtns]
{
    PUSH:
    {
	TO[BUTTON.INPUT];
	BIC = BUTTON.INPUT.CHANNEL;
	
	SELECT
	{
	    ACTIVE(blnCombined[PARTITION_AB] && blnCombined[PARTITION_BC]):  // all 3 rooms
	    {
		SEND_COMMAND dvaTP_Macros_01, "'@PPN-Room ABC Sources;Main'";
		blnPhoneControl[ROOM_A]	= FALSE;
		blnPhoneControl[ROOM_B]	= FALSE;
		blnPhoneControl[ROOM_C]	= FALSE;
	    }
	    ACTIVE(blnCombined[PARTITION_AB] && !blnCombined[PARTITION_BC]):  // A/B combined, C separate
	    {
		SEND_COMMAND dvaTP_Macros_01[ROOM_A], "'@PPN-Room AB Sources;Main'";
		SEND_COMMAND dvaTP_Macros_01[ROOM_B], "'@PPN-Room AB Sources;Main'";
		SEND_COMMAND dvaTP_Macros_01[ROOM_C], "'@PPN-Room C Sources;Main'";
		IF(BUTTON.INPUT.DEVICE == dvaTP_Switcher_03[ROOM_A] || BUTTON.INPUT.DEVICE == dvaTP_Switcher_03[ROOM_B])
		{
		    blnPhoneControl[ROOM_A] = FALSE;
		    blnPhoneControl[ROOM_B] = FALSE;
		}
		ELSE blnPhoneControl[ROOM_C] = FALSE;
	    }
	    ACTIVE(!blnCombined[PARTITION_AB] && blnCombined[PARTITION_BC]):  // B/C combined, A separate
	    {
		SEND_COMMAND dvaTP_Macros_01[ROOM_C], "'@PPN-Room BC Sources;Main'";
		SEND_COMMAND dvaTP_Macros_01[ROOM_B], "'@PPN-Room BC Sources;Main'";
		SEND_COMMAND dvaTP_Macros_01[ROOM_A], "'@PPN-Room A Sources;Main'";
		IF(BUTTON.INPUT.DEVICE == dvaTP_Switcher_03[ROOM_C] || BUTTON.INPUT.DEVICE == dvaTP_Switcher_03[ROOM_B])
		{
		    blnPhoneControl[ROOM_C] = FALSE;
		    blnPhoneControl[ROOM_B] = FALSE;
		}
		ELSE blnPhoneControl[ROOM_A] = FALSE;

	    }
	    ACTIVE(1):  // no rooms combined
	    {
		SEND_COMMAND dvaTP_Macros_01[ROOM_A], "'@PPN-Room A Sources;Main'";
		SEND_COMMAND dvaTP_Macros_01[ROOM_B], "'@PPN-Room B Sources;Main'";
		SEND_COMMAND dvaTP_Macros_01[ROOM_C], "'@PPN-Room C Sources;Main'";
		blnPhoneControl[nWhichRm] = FALSE;
	    }
	}
    }
    RELEASE:
    {
	STACK_VAR INTEGER x
	
	IF(!blnHoldDest[nWhichRm])
	{
	    IF(BIC < 200)  // regular video input button
	    {
		//nRoutingPair[nWhichRm][1] = GET_LAST(nVidInputBtns);

		SELECT
		{
		    ACTIVE(blnCombined[PARTITION_AB] && blnCombined[PARTITION_BC]):  // all 3
		    {
			nRoutingPair[ROOM_A][1] = 0; 
			nRoutingPair[ROOM_B][1] = 0; 
			nRoutingPair[ROOM_C][1] = GET_LAST(nVidInputBtns);
			SEND_COMMAND dvaTP_Switcher_03, "'@PPN-', sSwitcherInfo[1].Inputs[nRoutingPair[ROOM_C][1]].ControlPage, ';Main'";
		    
			nRoutingPair[ROOM_C][2] = vo_4;
			fnMTX(nRoutingPair[ROOM_C][1],nRoutingPair[ROOM_C][2],'V');

			fnMTX(nRoutingPair[ROOM_C][1],ao_PGM[ROOM_A],'A');
			fnMTX(nRoutingPair[ROOM_C][1],ao_PGM[ROOM_B],'A');
			fnMTX(nRoutingPair[ROOM_C][1],ao_PGM[ROOM_C],'A');
			fnProjector(ROOM_B2,'ON')
			fnProjector(ROOM_B2,'HDMI');
			fnMonitor(ROOM_A,'OFF');
			fnProjector(ROOM_B,'OFF');
			fnProjector(ROOM_C,'OFF');
			
			nRoutingPair[ROOM_C][2] = 0;
		    
		    }
		    ACTIVE(blnCombined[PARTITION_AB] && !blnCombined[PARTITION_BC]):  // A/B combined, C separate
		    {
			IF(BUTTON.INPUT.DEVICE == dvaTP_Switcher_03[ROOM_A] || BUTTON.INPUT.DEVICE == dvaTP_Switcher_03[ROOM_B])
			{
			    nRoutingPair[ROOM_A][1] = GET_LAST(nVidInputBtns); 
			    nRoutingPair[ROOM_B][1] = 0; 

			    SEND_COMMAND dvaTP_Switcher_03[ROOM_A], "'@PPN-', sSwitcherInfo[1].Inputs[nRoutingPair[ROOM_A][1]].ControlPage, ';Main'";
			    SEND_COMMAND dvaTP_Switcher_03[ROOM_B], "'@PPN-', sSwitcherInfo[1].Inputs[nRoutingPair[ROOM_A][1]].ControlPage, ';Main'";

			    fnMTX(nRoutingPair[ROOM_A][1],vo_1,'V');
			    fnMTX(nRoutingPair[ROOM_A][1],vo_2,'V');
			    
			    fnMTX(nRoutingPair[ROOM_A][1],ao_PGM[ROOM_A],'A');
			    fnMTX(nRoutingPair[ROOM_A][1],ao_PGM[ROOM_B],'A');			
			    fnMonitor(ROOM_A,'ON');
			    fnProjector(ROOM_B,'ON');
			    
			    nRoutingPair[ROOM_A][2] = 0;
			}
			ELSE
			{
			    nRoutingPair[ROOM_C][1] = GET_LAST(nVidInputBtns);
			    SEND_COMMAND dvaTP_Switcher_03[ROOM_C], "'@PPN-', sSwitcherInfo[1].Inputs[nRoutingPair[ROOM_C][1]].ControlPage, ';Main'";			

			    nRoutingPair[ROOM_C][2] = vo_3;
			    fnMTX(nRoutingPair[ROOM_C][1],nRoutingPair[ROOM_C][2],'V');

			    fnMTX(nRoutingPair[ROOM_C][1],ao_PGM[ROOM_C],'A');
			    fnProjector(ROOM_C,'ON');
			    
			    nRoutingPair[ROOM_C][2] = 0;
			}
		    }
		    ACTIVE(!blnCombined[PARTITION_AB] && blnCombined[PARTITION_BC]):  // B/C combined, A separate
		    {
			IF(BUTTON.INPUT.DEVICE == dvaTP_Switcher_03[ROOM_C] || BUTTON.INPUT.DEVICE == dvaTP_Switcher_03[ROOM_B])
			{
			    nRoutingPair[ROOM_C][1] = GET_LAST(nVidInputBtns); 
			    nRoutingPair[ROOM_B][1] = 0; 

			    SEND_COMMAND dvaTP_Switcher_03[ROOM_C], "'@PPN-', sSwitcherInfo[1].Inputs[nRoutingPair[ROOM_C][1]].ControlPage, ';Main'";
			    SEND_COMMAND dvaTP_Switcher_03[ROOM_B], "'@PPN-', sSwitcherInfo[1].Inputs[nRoutingPair[ROOM_C][1]].ControlPage, ';Main'";

			    nRoutingPair[ROOM_C][2] = vo_4;
			    fnMTX(nRoutingPair[ROOM_C][1],nRoutingPair[ROOM_C][2],'V');

			    fnMTX(nRoutingPair[ROOM_C][1],ao_PGM[ROOM_C],'A');
			    fnMTX(nRoutingPair[ROOM_C][1],ao_PGM[ROOM_B],'A');

			    fnProjector(ROOM_B2,'ON');
			    fnProjector(ROOM_B2,'HDMI');
			    fnProjector(ROOM_B,'OFF');
			    fnProjector(ROOM_C,'OFF');
			    
			    nRoutingPair[ROOM_C][2] = 0;

			}
			ELSE
			{
			    nRoutingPair[ROOM_A][1] = GET_LAST(nVidInputBtns);
			    SEND_COMMAND dvaTP_Switcher_03[ROOM_A], "'@PPN-', sSwitcherInfo[1].Inputs[nRoutingPair[ROOM_A][1]].ControlPage, ';Main'";			

			    nRoutingPair[ROOM_A][2] = vo_1;
			    fnMTX(nRoutingPair[ROOM_A][1],nRoutingPair[ROOM_A][2],'V');

			    fnMTX(nRoutingPair[ROOM_A][1],ao_PGM[ROOM_A],'A');
			    fnMonitor(ROOM_A,'ON');
			    
			    nRoutingPair[ROOM_A][2] = 0;
			
			}
		    }
		    ACTIVE(1):  // all separate
		    {
			nRoutingPair[nWhichRm][1] = GET_LAST(nVidInputBtns);
			SEND_COMMAND dvaTP_Switcher_03[nWhichRm], "'@PPN-', sSwitcherInfo[1].Inputs[nRoutingPair[nWhichRm][1]].ControlPage, ';Main'";

			nRoutingPair[nWhichRm][2] = nWhichRm;
			fnMTX(nRoutingPair[nWhichRm][1],nRoutingPair[nWhichRm][2],'V');
			
			fnMTX(nRoutingPair[nWhichRm][1],ao_PGM[nWhichRm],'A');
			IF(nWhichRm == ROOM_A)	fnMonitor(ROOM_A,'ON');
			ELSE			fnProjector(nWhichRm,'ON');
			
			nRoutingPair[nWhichRm][2] = 0;

		    }
	    
		}
	    }
	    ELSE IF(BIC > 200 && BIC < 300) //  video output button
	    {
//		nRoutingPair[nWhichRm][2] = GET_LAST(nVidOutputBtns);
//		fnMTX(nRoutingPair[nWhichRm][1],nRoutingPair[nWhichRm][2],'V');
		//fnMTX(nRoutingPair[nWhichRm][1],ao_PGM[nWhichRm],'A');
		
		SELECT
		{
		    ACTIVE(blnCombined[PARTITION_AB] && blnCombined[PARTITION_BC]):  // all 3 rooms combined
		    {
			nRoutingPair[ROOM_C][2] = GET_LAST(nVidOutputBtns);
			fnMTX(nRoutingPair[ROOM_C][1],nRoutingPair[ROOM_C][2],'V');

			fnMTX(nRoutingPair[ROOM_C][1],ao_PGM[ROOM_A],'A');
			fnMTX(nRoutingPair[ROOM_C][1],ao_PGM[ROOM_B],'A');
			fnMTX(nRoutingPair[ROOM_C][1],ao_PGM[ROOM_C],'A');
			fnProjector(ROOM_B2,'ON')
			fnProjector(ROOM_B2,'HDMI');
			fnMonitor(ROOM_A,'OFF');
			fnProjector(ROOM_B,'OFF');
			fnProjector(ROOM_C,'OFF');
			
			nRoutingPair[ROOM_C][2] = 0;
		    }
		    ACTIVE(blnCombined[PARTITION_AB] && !blnCombined[PARTITION_BC]):  // A/B combined, C separate
		    {
			IF(nWhichRm == ROOM_A || nWhichRm == ROOM_B)
			{
			    nRoutingPair[ROOM_A][2] = GET_LAST(nVidOutputBtns);
			    fnMTX(nRoutingPair[ROOM_A][1],nRoutingPair[ROOM_A][2],'V');
			    
			    fnMTX(nRoutingPair[ROOM_A][1],ao_PGM[ROOM_A],'A');
			    fnMTX(nRoutingPair[ROOM_A][1],ao_PGM[ROOM_B],'A');			
			    IF(nRoutingPair[ROOM_A][2] == vo_1) fnMonitor(ROOM_A,'ON');
			    IF(nRoutingPair[ROOM_A][2] == vo_2) fnProjector(ROOM_B,'ON');
			    
			    nRoutingPair[ROOM_A][2] = 0;
			}
			ELSE 
			{
			    nRoutingPair[ROOM_C][2] = GET_LAST(nVidOutputBtns);
			    fnMTX(nRoutingPair[ROOM_C][1],nRoutingPair[ROOM_C][2],'V');

			    fnMTX(nRoutingPair[ROOM_C][1],ao_PGM[ROOM_C],'A');
			    fnProjector(ROOM_C,'ON');
			    
			    nRoutingPair[ROOM_C][2] = 0;
			}
		    }
		    ACTIVE(!blnCombined[PARTITION_AB] && blnCombined[PARTITION_BC]):  // C/B combined, A separate
		    {
			IF(nWhichRm == ROOM_C || nWhichRm == ROOM_B)
			{
			    nRoutingPair[ROOM_C][2] = GET_LAST(nVidOutputBtns);
			    fnMTX(nRoutingPair[ROOM_C][1],nRoutingPair[ROOM_C][2],'V');

			    fnMTX(nRoutingPair[ROOM_C][1],ao_PGM[ROOM_C],'A');
			    fnMTX(nRoutingPair[ROOM_C][1],ao_PGM[ROOM_B],'A');

			    fnProjector(ROOM_B2,'ON');
			    fnProjector(ROOM_B2,'HDMI');
			    fnProjector(ROOM_B,'OFF');
			    fnProjector(ROOM_C,'OFF');
			    
			    nRoutingPair[ROOM_C][2] = 0;
			    
			}
			ELSE 
			{
			    nRoutingPair[ROOM_A][2] = GET_LAST(nVidOutputBtns);
			    fnMTX(nRoutingPair[ROOM_A][1],nRoutingPair[ROOM_A][2],'V');

			    fnMTX(nRoutingPair[ROOM_A][1],ao_PGM[ROOM_A],'A');
			    fnMonitor(ROOM_A,'ON');
			    
			    nRoutingPair[ROOM_A][2] = 0;
			}
		    }
		    ACTIVE(1):  // all rooms separate
		    {
			
			nRoutingPair[nWhichRm][2] = GET_LAST(nVidOutputBtns);
			fnMTX(nRoutingPair[nWhichRm][1],nRoutingPair[nWhichRm][2],'V');
			
			fnMTX(nRoutingPair[nWhichRm][1],ao_PGM[nWhichRm],'A');
			IF(nWhichRm == ROOM_A)	fnMonitor(ROOM_A,'ON');
			ELSE			fnProjector(nWhichRm,'ON');
			
			nRoutingPair[nWhichRm][2] = 0;
		    }

		}
		
		//nRoutingPair[nWhichRm][2] = 0;
	    }
	    ELSE IF(BIC > 400) //  audio output button
	    {
		nRoutingPair[nWhichRm][2] = GET_LAST(nAudOutputBtns);
		fnMTX(nRoutingPair[nWhichRm][1],ao_PGM[nWhichRm],'A');
	    }
	}
	blnHoldDest[nWhichRm] = FALSE;
    }
    HOLD[20]: // clear route to designated output
    {
	IF(BIC > 200 && BIC < 300) //  video output button
	{
	    blnHoldDest[nWhichRm] = TRUE;
	    nRoutingPair[nWhichRm][2] = GET_LAST(nVidOutputBtns);
	    fnMTX(0,nRoutingPair[nWhichRm][2],'V');
	    fnMTX(0,ao_PGM[nWhichRm],'A');

	    #IF_DEFINED CONFIG_VTC
		IF((BIC - 200) == vo_1)
		{
		    PULSE[vdvCODEC,2];  // stop visual concert
		}
	    #END_IF
	}
	ELSE IF(BIC > 400) //  audio output button
	{
	    blnHoldDest[nWhichRm] = TRUE;
	    nRoutingPair[nWhichRm][2] = GET_LAST(nAudOutputBtns);
	    fnMTX(0,nRoutingPair[nWhichRm][2],'A');
	}
    }
}







// Phone
BUTTON_EVENT[dvaTP_Switcher_03,1002]
{
    PUSH:
    {
	SELECT
	{
	    ACTIVE(blnCombined[PARTITION_AB] && blnCombined[PARTITION_BC]):  // all 3
	    {
		ON[blnPhoneControl[ROOM_A]];
		ON[blnPhoneControl[ROOM_B]];
		ON[blnPhoneControl[ROOM_C]];
		
		nRoutingPair[ROOM_A][1] = 0;
		nRoutingPair[ROOM_B][1] = 0;
		nRoutingPair[ROOM_C][1] = 0;
	    }
	    ACTIVE(blnCombined[PARTITION_AB] && !blnCombined[PARTITION_BC]):  
	    {
		IF(BUTTON.INPUT.DEVICE == dvaTP_Switcher_03[ROOM_A] || BUTTON.INPUT.DEVICE == dvaTP_Switcher_03[ROOM_B])
		{
		    SEND_COMMAND dvaTP_Switcher_03[ROOM_A], "'@PPN-Phone;Main'";
		    SEND_COMMAND dvaTP_Switcher_03[ROOM_B], "'@PPN-Phone;Main'";
		    nRoutingPair[ROOM_A][1] = 0;
		    nRoutingPair[ROOM_B][1] = 0;
		    ON[blnPhoneControl[ROOM_A]];
		    ON[blnPhoneControl[ROOM_B]];
		}
		ELSE
		{
		    SEND_COMMAND dvaTP_Switcher_03[ROOM_C], "'@PPN-Phone;Main'";		
		    nRoutingPair[ROOM_C][1] = 0;
		    ON[blnPhoneControl[ROOM_C]];
		}
	    }
	    ACTIVE(!blnCombined[PARTITION_AB] && blnCombined[PARTITION_BC]):  
	    {
		IF(BUTTON.INPUT.DEVICE == dvaTP_Switcher_03[ROOM_C] || BUTTON.INPUT.DEVICE == dvaTP_Switcher_03[ROOM_B])
		{
		    SEND_COMMAND dvaTP_Switcher_03[ROOM_C], "'@PPN-Phone;Main'";
		    SEND_COMMAND dvaTP_Switcher_03[ROOM_B], "'@PPN-Phone;Main'";
		    nRoutingPair[ROOM_C][1] = 0;
		    nRoutingPair[ROOM_B][1] = 0;
		    ON[blnPhoneControl[ROOM_B]];
		    ON[blnPhoneControl[ROOM_C]];
		}
		ELSE
		{
		    SEND_COMMAND dvaTP_Switcher_03[ROOM_A], "'@PPN-Phone;Main'";		
		    nRoutingPair[ROOM_A][1] = 0;
		    ON[blnPhoneControl[ROOM_A]];
		}
	    }
	    ACTIVE(1):
	    {
		ON[blnPhoneControl[GET_LAST(dvaTP_Switcher_03)]];
		nRoutingPair[GET_LAST(dvaTP_Switcher_03)][1] = 0;
	    }
	}
	
    }
}






DEFINE_PROGRAM

[dvaTP_Switcher_03,1002]			= blnPhoneControl;

WAIT 10
{
    SELECT
    {
	ACTIVE(blnCombined[PARTITION_AB] && blnCombined[PARTITION_BC]):  // all 3 combined
	{
	    [dvaTP_Switcher_03,nVidInputBtns[1]]	= (nRoutingPair[ROOM_A][1] == 1 || nRoutingPair[ROOM_B][1] == 1 ||   nRoutingPair[ROOM_C][1] == 1);
	    [dvaTP_Switcher_03,nVidInputBtns[2]]	= (nRoutingPair[ROOM_A][1] == 2 || nRoutingPair[ROOM_B][1] == 2 ||   nRoutingPair[ROOM_C][1] == 2);
	    [dvaTP_Switcher_03,nVidInputBtns[3]]	= (nRoutingPair[ROOM_A][1] == 3 || nRoutingPair[ROOM_B][1] == 3 ||   nRoutingPair[ROOM_C][1] == 3);
	    [dvaTP_Switcher_03,nVidInputBtns[4]]	= (nRoutingPair[ROOM_A][1] == 4 || nRoutingPair[ROOM_B][1] == 4 ||   nRoutingPair[ROOM_C][1] == 4);
	    [dvaTP_Switcher_03,nVidInputBtns[5]]	= (nRoutingPair[ROOM_A][1] == 5 || nRoutingPair[ROOM_B][1] == 5 ||   nRoutingPair[ROOM_C][1] == 5);
	    [dvaTP_Switcher_03,nVidInputBtns[6]]	= (nRoutingPair[ROOM_A][1] == 6 || nRoutingPair[ROOM_B][1] == 6 ||   nRoutingPair[ROOM_C][1] == 6);
	    [dvaTP_Switcher_03,nVidInputBtns[7]]	= (nRoutingPair[ROOM_A][1] == 7 || nRoutingPair[ROOM_B][1] == 7 ||   nRoutingPair[ROOM_C][1] == 7);
	    [dvaTP_Switcher_03,nVidInputBtns[8]]	= (nRoutingPair[ROOM_A][1] == 8 || nRoutingPair[ROOM_B][1] == 8 ||   nRoutingPair[ROOM_C][1] == 8);
	    [dvaTP_Switcher_03,nVidInputBtns[9]]	= (nRoutingPair[ROOM_A][1] == 9 || nRoutingPair[ROOM_B][1] == 9 ||   nRoutingPair[ROOM_C][1] == 9);
	    [dvaTP_Switcher_03,nVidInputBtns[10]]	= (nRoutingPair[ROOM_A][1] == 10 || nRoutingPair[ROOM_B][1] == 10 || nRoutingPair[ROOM_C][1] == 10);
	    [dvaTP_Switcher_03,nVidInputBtns[11]]	= (nRoutingPair[ROOM_A][1] == 11 || nRoutingPair[ROOM_B][1] == 11 || nRoutingPair[ROOM_C][1] == 11);
	    [dvaTP_Switcher_03,nVidInputBtns[12]]	= (nRoutingPair[ROOM_A][1] == 12 || nRoutingPair[ROOM_B][1] == 12 || nRoutingPair[ROOM_C][1] == 12);
	    [dvaTP_Switcher_03,nVidInputBtns[13]]	= (nRoutingPair[ROOM_A][1] == 13 || nRoutingPair[ROOM_B][1] == 13 || nRoutingPair[ROOM_C][1] == 13);
	    [dvaTP_Switcher_03,nVidInputBtns[14]]	= (nRoutingPair[ROOM_A][1] == 14 || nRoutingPair[ROOM_B][1] == 14 || nRoutingPair[ROOM_C][1] == 14);
	    [dvaTP_Switcher_03,nVidInputBtns[15]]	= (nRoutingPair[ROOM_A][1] == 15 || nRoutingPair[ROOM_B][1] == 15 || nRoutingPair[ROOM_C][1] == 15);
	    [dvaTP_Switcher_03,nVidInputBtns[16]]	= (nRoutingPair[ROOM_A][1] == 16 || nRoutingPair[ROOM_B][1] == 16 || nRoutingPair[ROOM_C][1] == 16);
	    [dvaTP_Switcher_03,nVidInputBtns[17]]	= (nRoutingPair[ROOM_A][1] == 17 || nRoutingPair[ROOM_B][1] == 17 || nRoutingPair[ROOM_C][1] == 17);
	    [dvaTP_Switcher_03,nVidInputBtns[18]]	= (nRoutingPair[ROOM_A][1] == 18 || nRoutingPair[ROOM_B][1] == 18 || nRoutingPair[ROOM_C][1] == 18);
	    [dvaTP_Switcher_03,nVidInputBtns[19]]	= (nRoutingPair[ROOM_A][1] == 19 || nRoutingPair[ROOM_B][1] == 19 || nRoutingPair[ROOM_C][1] == 19);
	    [dvaTP_Switcher_03,nVidInputBtns[20]]	= (nRoutingPair[ROOM_A][1] == 20 || nRoutingPair[ROOM_B][1] == 20 || nRoutingPair[ROOM_C][1] == 20);
	    [dvaTP_Switcher_03,nVidInputBtns[21]]	= (nRoutingPair[ROOM_A][1] == 21 || nRoutingPair[ROOM_B][1] == 21 || nRoutingPair[ROOM_C][1] == 21);
	    [dvaTP_Switcher_03,nVidInputBtns[22]]	= (nRoutingPair[ROOM_A][1] == 22 || nRoutingPair[ROOM_B][1] == 22 || nRoutingPair[ROOM_C][1] == 22);
	    [dvaTP_Switcher_03,nVidInputBtns[23]]	= (nRoutingPair[ROOM_A][1] == 23 || nRoutingPair[ROOM_B][1] == 23 || nRoutingPair[ROOM_C][1] == 23);
	    [dvaTP_Switcher_03,nVidInputBtns[24]]	= (nRoutingPair[ROOM_A][1] == 24 || nRoutingPair[ROOM_B][1] == 24 || nRoutingPair[ROOM_C][1] == 24);
	    [dvaTP_Switcher_03,nVidInputBtns[25]]	= (nRoutingPair[ROOM_A][1] == 25 || nRoutingPair[ROOM_B][1] == 25 || nRoutingPair[ROOM_C][1] == 25);
	    [dvaTP_Switcher_03,nVidInputBtns[26]]	= (nRoutingPair[ROOM_A][1] == 26 || nRoutingPair[ROOM_B][1] == 26 || nRoutingPair[ROOM_C][1] == 26);
	    [dvaTP_Switcher_03,nVidInputBtns[27]]	= (nRoutingPair[ROOM_A][1] == 27 || nRoutingPair[ROOM_B][1] == 27 || nRoutingPair[ROOM_C][1] == 27);
	    [dvaTP_Switcher_03,nVidInputBtns[28]]	= (nRoutingPair[ROOM_A][1] == 28 || nRoutingPair[ROOM_B][1] == 28 || nRoutingPair[ROOM_C][1] == 28);
	    [dvaTP_Switcher_03,nVidInputBtns[29]]	= (nRoutingPair[ROOM_A][1] == 29 || nRoutingPair[ROOM_B][1] == 29 || nRoutingPair[ROOM_C][1] == 29);
	    [dvaTP_Switcher_03,nVidInputBtns[30]]	= (nRoutingPair[ROOM_A][1] == 30 || nRoutingPair[ROOM_B][1] == 30 || nRoutingPair[ROOM_C][1] == 30);
	    [dvaTP_Switcher_03,nVidInputBtns[31]]	= (nRoutingPair[ROOM_A][1] == 31 || nRoutingPair[ROOM_B][1] == 31 || nRoutingPair[ROOM_C][1] == 31);
	    [dvaTP_Switcher_03,nVidInputBtns[32]]	= (nRoutingPair[ROOM_A][1] == 32 || nRoutingPair[ROOM_B][1] == 32 || nRoutingPair[ROOM_C][1] == 32);
	}
	ACTIVE(blnCombined[PARTITION_AB] && !blnCombined[PARTITION_BC]):  // only A/B combined
	{
	    [dvaTP_Switcher_03[1],nVidInputBtns[1]]	= (nRoutingPair[ROOM_A][1] == 1 || nRoutingPair[ROOM_B][1] == 1);
	    [dvaTP_Switcher_03[1],nVidInputBtns[2]]	= (nRoutingPair[ROOM_A][1] == 2 || nRoutingPair[ROOM_B][1] == 2);
	    [dvaTP_Switcher_03[1],nVidInputBtns[3]]	= (nRoutingPair[ROOM_A][1] == 3 || nRoutingPair[ROOM_B][1] == 3);
	    [dvaTP_Switcher_03[1],nVidInputBtns[4]]	= (nRoutingPair[ROOM_A][1] == 4 || nRoutingPair[ROOM_B][1] == 4);
	    [dvaTP_Switcher_03[1],nVidInputBtns[5]]	= (nRoutingPair[ROOM_A][1] == 5 || nRoutingPair[ROOM_B][1] == 5);
	    [dvaTP_Switcher_03[1],nVidInputBtns[6]]	= (nRoutingPair[ROOM_A][1] == 6 || nRoutingPair[ROOM_B][1] == 6);
	    [dvaTP_Switcher_03[1],nVidInputBtns[7]]	= (nRoutingPair[ROOM_A][1] == 7 || nRoutingPair[ROOM_B][1] == 7);
	    [dvaTP_Switcher_03[1],nVidInputBtns[8]]	= (nRoutingPair[ROOM_A][1] == 8 || nRoutingPair[ROOM_B][1] == 8);
	    [dvaTP_Switcher_03[1],nVidInputBtns[9]]	= (nRoutingPair[ROOM_A][1] == 9 || nRoutingPair[ROOM_B][1] == 9);
	    [dvaTP_Switcher_03[1],nVidInputBtns[10]]	= (nRoutingPair[ROOM_A][1] == 10 || nRoutingPair[ROOM_B][1] == 10);
	    [dvaTP_Switcher_03[1],nVidInputBtns[11]]	= (nRoutingPair[ROOM_A][1] == 11 || nRoutingPair[ROOM_B][1] == 11);
	    [dvaTP_Switcher_03[1],nVidInputBtns[12]]	= (nRoutingPair[ROOM_A][1] == 12 || nRoutingPair[ROOM_B][1] == 12);
	    [dvaTP_Switcher_03[1],nVidInputBtns[13]]	= (nRoutingPair[ROOM_A][1] == 13 || nRoutingPair[ROOM_B][1] == 13);
	    [dvaTP_Switcher_03[1],nVidInputBtns[14]]	= (nRoutingPair[ROOM_A][1] == 14 || nRoutingPair[ROOM_B][1] == 14);
	    [dvaTP_Switcher_03[1],nVidInputBtns[15]]	= (nRoutingPair[ROOM_A][1] == 15 || nRoutingPair[ROOM_B][1] == 15);
	    [dvaTP_Switcher_03[1],nVidInputBtns[16]]	= (nRoutingPair[ROOM_A][1] == 16 || nRoutingPair[ROOM_B][1] == 16);
	    [dvaTP_Switcher_03[1],nVidInputBtns[17]]	= (nRoutingPair[ROOM_A][1] == 17 || nRoutingPair[ROOM_B][1] == 17);
	    [dvaTP_Switcher_03[1],nVidInputBtns[18]]	= (nRoutingPair[ROOM_A][1] == 18 || nRoutingPair[ROOM_B][1] == 18);
	    [dvaTP_Switcher_03[1],nVidInputBtns[19]]	= (nRoutingPair[ROOM_A][1] == 19 || nRoutingPair[ROOM_B][1] == 19);
	    [dvaTP_Switcher_03[1],nVidInputBtns[20]]	= (nRoutingPair[ROOM_A][1] == 20 || nRoutingPair[ROOM_B][1] == 20);
	    [dvaTP_Switcher_03[1],nVidInputBtns[21]]	= (nRoutingPair[ROOM_A][1] == 21 || nRoutingPair[ROOM_B][1] == 21);
	    [dvaTP_Switcher_03[1],nVidInputBtns[22]]	= (nRoutingPair[ROOM_A][1] == 22 || nRoutingPair[ROOM_B][1] == 22);
	    [dvaTP_Switcher_03[1],nVidInputBtns[23]]	= (nRoutingPair[ROOM_A][1] == 23 || nRoutingPair[ROOM_B][1] == 23);
	    [dvaTP_Switcher_03[1],nVidInputBtns[24]]	= (nRoutingPair[ROOM_A][1] == 24 || nRoutingPair[ROOM_B][1] == 24);
	    [dvaTP_Switcher_03[1],nVidInputBtns[25]]	= (nRoutingPair[ROOM_A][1] == 25 || nRoutingPair[ROOM_B][1] == 25);
	    [dvaTP_Switcher_03[1],nVidInputBtns[26]]	= (nRoutingPair[ROOM_A][1] == 26 || nRoutingPair[ROOM_B][1] == 26);
	    [dvaTP_Switcher_03[1],nVidInputBtns[27]]	= (nRoutingPair[ROOM_A][1] == 27 || nRoutingPair[ROOM_B][1] == 27);
	    [dvaTP_Switcher_03[1],nVidInputBtns[28]]	= (nRoutingPair[ROOM_A][1] == 28 || nRoutingPair[ROOM_B][1] == 28);
	    [dvaTP_Switcher_03[1],nVidInputBtns[29]]	= (nRoutingPair[ROOM_A][1] == 29 || nRoutingPair[ROOM_B][1] == 29);
	    [dvaTP_Switcher_03[1],nVidInputBtns[30]]	= (nRoutingPair[ROOM_A][1] == 30 || nRoutingPair[ROOM_B][1] == 30);
	    [dvaTP_Switcher_03[1],nVidInputBtns[31]]	= (nRoutingPair[ROOM_A][1] == 31 || nRoutingPair[ROOM_B][1] == 31);
	    [dvaTP_Switcher_03[1],nVidInputBtns[32]]	= (nRoutingPair[ROOM_A][1] == 32 || nRoutingPair[ROOM_B][1] == 32);
	
	    [dvaTP_Switcher_03[2],nVidInputBtns[1]]	= (nRoutingPair[ROOM_A][1] == 1 || nRoutingPair[ROOM_B][1] == 1);
	    [dvaTP_Switcher_03[2],nVidInputBtns[2]]	= (nRoutingPair[ROOM_A][1] == 2 || nRoutingPair[ROOM_B][1] == 2);
	    [dvaTP_Switcher_03[2],nVidInputBtns[3]]	= (nRoutingPair[ROOM_A][1] == 3 || nRoutingPair[ROOM_B][1] == 3);
	    [dvaTP_Switcher_03[2],nVidInputBtns[4]]	= (nRoutingPair[ROOM_A][1] == 4 || nRoutingPair[ROOM_B][1] == 4);
	    [dvaTP_Switcher_03[2],nVidInputBtns[5]]	= (nRoutingPair[ROOM_A][1] == 5 || nRoutingPair[ROOM_B][1] == 5);
	    [dvaTP_Switcher_03[2],nVidInputBtns[6]]	= (nRoutingPair[ROOM_A][1] == 6 || nRoutingPair[ROOM_B][1] == 6);
	    [dvaTP_Switcher_03[2],nVidInputBtns[7]]	= (nRoutingPair[ROOM_A][1] == 7 || nRoutingPair[ROOM_B][1] == 7);
	    [dvaTP_Switcher_03[2],nVidInputBtns[8]]	= (nRoutingPair[ROOM_A][1] == 8 || nRoutingPair[ROOM_B][1] == 8);
	    [dvaTP_Switcher_03[2],nVidInputBtns[9]]	= (nRoutingPair[ROOM_A][1] == 9 || nRoutingPair[ROOM_B][1] == 9);
	    [dvaTP_Switcher_03[2],nVidInputBtns[10]]	= (nRoutingPair[ROOM_A][1] == 10 || nRoutingPair[ROOM_B][1] == 10);
	    [dvaTP_Switcher_03[2],nVidInputBtns[11]]	= (nRoutingPair[ROOM_A][1] == 11 || nRoutingPair[ROOM_B][1] == 11);
	    [dvaTP_Switcher_03[2],nVidInputBtns[12]]	= (nRoutingPair[ROOM_A][1] == 12 || nRoutingPair[ROOM_B][1] == 12);
	    [dvaTP_Switcher_03[2],nVidInputBtns[13]]	= (nRoutingPair[ROOM_A][1] == 13 || nRoutingPair[ROOM_B][1] == 13);
	    [dvaTP_Switcher_03[2],nVidInputBtns[14]]	= (nRoutingPair[ROOM_A][1] == 14 || nRoutingPair[ROOM_B][1] == 14);
	    [dvaTP_Switcher_03[2],nVidInputBtns[15]]	= (nRoutingPair[ROOM_A][1] == 15 || nRoutingPair[ROOM_B][1] == 15);
	    [dvaTP_Switcher_03[2],nVidInputBtns[16]]	= (nRoutingPair[ROOM_A][1] == 16 || nRoutingPair[ROOM_B][1] == 16);
	    [dvaTP_Switcher_03[2],nVidInputBtns[17]]	= (nRoutingPair[ROOM_A][1] == 17 || nRoutingPair[ROOM_B][1] == 17);
	    [dvaTP_Switcher_03[2],nVidInputBtns[18]]	= (nRoutingPair[ROOM_A][1] == 18 || nRoutingPair[ROOM_B][1] == 18);
	    [dvaTP_Switcher_03[2],nVidInputBtns[19]]	= (nRoutingPair[ROOM_A][1] == 19 || nRoutingPair[ROOM_B][1] == 19);
	    [dvaTP_Switcher_03[2],nVidInputBtns[20]]	= (nRoutingPair[ROOM_A][1] == 20 || nRoutingPair[ROOM_B][1] == 20);
	    [dvaTP_Switcher_03[2],nVidInputBtns[21]]	= (nRoutingPair[ROOM_A][1] == 21 || nRoutingPair[ROOM_B][1] == 21);
	    [dvaTP_Switcher_03[2],nVidInputBtns[22]]	= (nRoutingPair[ROOM_A][1] == 22 || nRoutingPair[ROOM_B][1] == 22);
	    [dvaTP_Switcher_03[2],nVidInputBtns[23]]	= (nRoutingPair[ROOM_A][1] == 23 || nRoutingPair[ROOM_B][1] == 23);
	    [dvaTP_Switcher_03[2],nVidInputBtns[24]]	= (nRoutingPair[ROOM_A][1] == 24 || nRoutingPair[ROOM_B][1] == 24);
	    [dvaTP_Switcher_03[2],nVidInputBtns[25]]	= (nRoutingPair[ROOM_A][1] == 25 || nRoutingPair[ROOM_B][1] == 25);
	    [dvaTP_Switcher_03[2],nVidInputBtns[26]]	= (nRoutingPair[ROOM_A][1] == 26 || nRoutingPair[ROOM_B][1] == 26);
	    [dvaTP_Switcher_03[2],nVidInputBtns[27]]	= (nRoutingPair[ROOM_A][1] == 27 || nRoutingPair[ROOM_B][1] == 27);
	    [dvaTP_Switcher_03[2],nVidInputBtns[28]]	= (nRoutingPair[ROOM_A][1] == 28 || nRoutingPair[ROOM_B][1] == 28);
	    [dvaTP_Switcher_03[2],nVidInputBtns[29]]	= (nRoutingPair[ROOM_A][1] == 29 || nRoutingPair[ROOM_B][1] == 29);
	    [dvaTP_Switcher_03[2],nVidInputBtns[30]]	= (nRoutingPair[ROOM_A][1] == 30 || nRoutingPair[ROOM_B][1] == 30);
	    [dvaTP_Switcher_03[2],nVidInputBtns[31]]	= (nRoutingPair[ROOM_A][1] == 31 || nRoutingPair[ROOM_B][1] == 31);
	    [dvaTP_Switcher_03[2],nVidInputBtns[32]]	= (nRoutingPair[ROOM_A][1] == 32 || nRoutingPair[ROOM_B][1] == 32);	

	    [dvaTP_Switcher_03[3],nVidInputBtns[1]]	= (nRoutingPair[ROOM_C][1] == 1);
	    [dvaTP_Switcher_03[3],nVidInputBtns[2]]	= (nRoutingPair[ROOM_C][1] == 2);
	    [dvaTP_Switcher_03[3],nVidInputBtns[3]]	= (nRoutingPair[ROOM_C][1] == 3);
	    [dvaTP_Switcher_03[3],nVidInputBtns[4]]	= (nRoutingPair[ROOM_C][1] == 4);
	    [dvaTP_Switcher_03[3],nVidInputBtns[5]]	= (nRoutingPair[ROOM_C][1] == 5);
	    [dvaTP_Switcher_03[3],nVidInputBtns[6]]	= (nRoutingPair[ROOM_C][1] == 6);
	    [dvaTP_Switcher_03[3],nVidInputBtns[7]]	= (nRoutingPair[ROOM_C][1] == 7);
	    [dvaTP_Switcher_03[3],nVidInputBtns[8]]	= (nRoutingPair[ROOM_C][1] == 8);
	    [dvaTP_Switcher_03[3],nVidInputBtns[9]]	= (nRoutingPair[ROOM_C][1] == 9);
	    [dvaTP_Switcher_03[3],nVidInputBtns[10]]	= (nRoutingPair[ROOM_C][1] == 10);
	    [dvaTP_Switcher_03[3],nVidInputBtns[11]]	= (nRoutingPair[ROOM_C][1] == 11);
	    [dvaTP_Switcher_03[3],nVidInputBtns[12]]	= (nRoutingPair[ROOM_C][1] == 12);
	    [dvaTP_Switcher_03[3],nVidInputBtns[13]]	= (nRoutingPair[ROOM_C][1] == 13);
	    [dvaTP_Switcher_03[3],nVidInputBtns[14]]	= (nRoutingPair[ROOM_C][1] == 14);
	    [dvaTP_Switcher_03[3],nVidInputBtns[15]]	= (nRoutingPair[ROOM_C][1] == 15);
	    [dvaTP_Switcher_03[3],nVidInputBtns[16]]	= (nRoutingPair[ROOM_C][1] == 16);
	    [dvaTP_Switcher_03[3],nVidInputBtns[17]]	= (nRoutingPair[ROOM_C][1] == 17);
	    [dvaTP_Switcher_03[3],nVidInputBtns[18]]	= (nRoutingPair[ROOM_C][1] == 18);
	    [dvaTP_Switcher_03[3],nVidInputBtns[19]]	= (nRoutingPair[ROOM_C][1] == 19);
	    [dvaTP_Switcher_03[3],nVidInputBtns[20]]	= (nRoutingPair[ROOM_C][1] == 20);
	    [dvaTP_Switcher_03[3],nVidInputBtns[21]]	= (nRoutingPair[ROOM_C][1] == 21);
	    [dvaTP_Switcher_03[3],nVidInputBtns[22]]	= (nRoutingPair[ROOM_C][1] == 22);
	    [dvaTP_Switcher_03[3],nVidInputBtns[23]]	= (nRoutingPair[ROOM_C][1] == 23);
	    [dvaTP_Switcher_03[3],nVidInputBtns[24]]	= (nRoutingPair[ROOM_C][1] == 24);
	    [dvaTP_Switcher_03[3],nVidInputBtns[25]]	= (nRoutingPair[ROOM_C][1] == 25);
	    [dvaTP_Switcher_03[3],nVidInputBtns[26]]	= (nRoutingPair[ROOM_C][1] == 26);
	    [dvaTP_Switcher_03[3],nVidInputBtns[27]]	= (nRoutingPair[ROOM_C][1] == 27);
	    [dvaTP_Switcher_03[3],nVidInputBtns[28]]	= (nRoutingPair[ROOM_C][1] == 28);
	    [dvaTP_Switcher_03[3],nVidInputBtns[29]]	= (nRoutingPair[ROOM_C][1] == 29);
	    [dvaTP_Switcher_03[3],nVidInputBtns[30]]	= (nRoutingPair[ROOM_C][1] == 30);
	    [dvaTP_Switcher_03[3],nVidInputBtns[31]]	= (nRoutingPair[ROOM_C][1] == 31);
	    [dvaTP_Switcher_03[3],nVidInputBtns[32]]	= (nRoutingPair[ROOM_C][1] == 32);	

	}
	ACTIVE(!blnCombined[PARTITION_AB] && blnCombined[PARTITION_BC]):  // only B/C combined
	{
	    [dvaTP_Switcher_03[3],nVidInputBtns[1]]	= (nRoutingPair[ROOM_C][1] == 1 || nRoutingPair[ROOM_B][1] == 1);
	    [dvaTP_Switcher_03[3],nVidInputBtns[2]]	= (nRoutingPair[ROOM_C][1] == 2 || nRoutingPair[ROOM_B][1] == 2);
	    [dvaTP_Switcher_03[3],nVidInputBtns[3]]	= (nRoutingPair[ROOM_C][1] == 3 || nRoutingPair[ROOM_B][1] == 3);
	    [dvaTP_Switcher_03[3],nVidInputBtns[4]]	= (nRoutingPair[ROOM_C][1] == 4 || nRoutingPair[ROOM_B][1] == 4);
	    [dvaTP_Switcher_03[3],nVidInputBtns[5]]	= (nRoutingPair[ROOM_C][1] == 5 || nRoutingPair[ROOM_B][1] == 5);
	    [dvaTP_Switcher_03[3],nVidInputBtns[6]]	= (nRoutingPair[ROOM_C][1] == 6 || nRoutingPair[ROOM_B][1] == 6);
	    [dvaTP_Switcher_03[3],nVidInputBtns[7]]	= (nRoutingPair[ROOM_C][1] == 7 || nRoutingPair[ROOM_B][1] == 7);
	    [dvaTP_Switcher_03[3],nVidInputBtns[8]]	= (nRoutingPair[ROOM_C][1] == 8 || nRoutingPair[ROOM_B][1] == 8);
	    [dvaTP_Switcher_03[3],nVidInputBtns[9]]	= (nRoutingPair[ROOM_C][1] == 9 || nRoutingPair[ROOM_B][1] == 9);
	    [dvaTP_Switcher_03[3],nVidInputBtns[10]]	= (nRoutingPair[ROOM_C][1] == 10 || nRoutingPair[ROOM_B][1] == 10);
	    [dvaTP_Switcher_03[3],nVidInputBtns[11]]	= (nRoutingPair[ROOM_C][1] == 11 || nRoutingPair[ROOM_B][1] == 11);
	    [dvaTP_Switcher_03[3],nVidInputBtns[12]]	= (nRoutingPair[ROOM_C][1] == 12 || nRoutingPair[ROOM_B][1] == 12);
	    [dvaTP_Switcher_03[3],nVidInputBtns[13]]	= (nRoutingPair[ROOM_C][1] == 13 || nRoutingPair[ROOM_B][1] == 13);
	    [dvaTP_Switcher_03[3],nVidInputBtns[14]]	= (nRoutingPair[ROOM_C][1] == 14 || nRoutingPair[ROOM_B][1] == 14);
	    [dvaTP_Switcher_03[3],nVidInputBtns[15]]	= (nRoutingPair[ROOM_C][1] == 15 || nRoutingPair[ROOM_B][1] == 15);
	    [dvaTP_Switcher_03[3],nVidInputBtns[16]]	= (nRoutingPair[ROOM_C][1] == 16 || nRoutingPair[ROOM_B][1] == 16);
	    [dvaTP_Switcher_03[3],nVidInputBtns[17]]	= (nRoutingPair[ROOM_C][1] == 17 || nRoutingPair[ROOM_B][1] == 17);
	    [dvaTP_Switcher_03[3],nVidInputBtns[18]]	= (nRoutingPair[ROOM_C][1] == 18 || nRoutingPair[ROOM_B][1] == 18);
	    [dvaTP_Switcher_03[3],nVidInputBtns[19]]	= (nRoutingPair[ROOM_C][1] == 19 || nRoutingPair[ROOM_B][1] == 19);
	    [dvaTP_Switcher_03[3],nVidInputBtns[20]]	= (nRoutingPair[ROOM_C][1] == 20 || nRoutingPair[ROOM_B][1] == 20);
	    [dvaTP_Switcher_03[3],nVidInputBtns[21]]	= (nRoutingPair[ROOM_C][1] == 21 || nRoutingPair[ROOM_B][1] == 21);
	    [dvaTP_Switcher_03[3],nVidInputBtns[22]]	= (nRoutingPair[ROOM_C][1] == 22 || nRoutingPair[ROOM_B][1] == 22);
	    [dvaTP_Switcher_03[3],nVidInputBtns[23]]	= (nRoutingPair[ROOM_C][1] == 23 || nRoutingPair[ROOM_B][1] == 23);
	    [dvaTP_Switcher_03[3],nVidInputBtns[24]]	= (nRoutingPair[ROOM_C][1] == 24 || nRoutingPair[ROOM_B][1] == 24);
	    [dvaTP_Switcher_03[3],nVidInputBtns[25]]	= (nRoutingPair[ROOM_C][1] == 25 || nRoutingPair[ROOM_B][1] == 25);
	    [dvaTP_Switcher_03[3],nVidInputBtns[26]]	= (nRoutingPair[ROOM_C][1] == 26 || nRoutingPair[ROOM_B][1] == 26);
	    [dvaTP_Switcher_03[3],nVidInputBtns[27]]	= (nRoutingPair[ROOM_C][1] == 27 || nRoutingPair[ROOM_B][1] == 27);
	    [dvaTP_Switcher_03[3],nVidInputBtns[28]]	= (nRoutingPair[ROOM_C][1] == 28 || nRoutingPair[ROOM_B][1] == 28);
	    [dvaTP_Switcher_03[3],nVidInputBtns[29]]	= (nRoutingPair[ROOM_C][1] == 29 || nRoutingPair[ROOM_B][1] == 29);
	    [dvaTP_Switcher_03[3],nVidInputBtns[30]]	= (nRoutingPair[ROOM_C][1] == 30 || nRoutingPair[ROOM_B][1] == 30);
	    [dvaTP_Switcher_03[3],nVidInputBtns[31]]	= (nRoutingPair[ROOM_C][1] == 31 || nRoutingPair[ROOM_B][1] == 31);
	    [dvaTP_Switcher_03[3],nVidInputBtns[32]]	= (nRoutingPair[ROOM_C][1] == 32 || nRoutingPair[ROOM_B][1] == 32);
	
	    [dvaTP_Switcher_03[2],nVidInputBtns[1]]	= (nRoutingPair[ROOM_C][1] == 1 || nRoutingPair[ROOM_B][1] == 1);
	    [dvaTP_Switcher_03[2],nVidInputBtns[2]]	= (nRoutingPair[ROOM_C][1] == 2 || nRoutingPair[ROOM_B][1] == 2);
	    [dvaTP_Switcher_03[2],nVidInputBtns[3]]	= (nRoutingPair[ROOM_C][1] == 3 || nRoutingPair[ROOM_B][1] == 3);
	    [dvaTP_Switcher_03[2],nVidInputBtns[4]]	= (nRoutingPair[ROOM_C][1] == 4 || nRoutingPair[ROOM_B][1] == 4);
	    [dvaTP_Switcher_03[2],nVidInputBtns[5]]	= (nRoutingPair[ROOM_C][1] == 5 || nRoutingPair[ROOM_B][1] == 5);
	    [dvaTP_Switcher_03[2],nVidInputBtns[6]]	= (nRoutingPair[ROOM_C][1] == 6 || nRoutingPair[ROOM_B][1] == 6);
	    [dvaTP_Switcher_03[2],nVidInputBtns[7]]	= (nRoutingPair[ROOM_C][1] == 7 || nRoutingPair[ROOM_B][1] == 7);
	    [dvaTP_Switcher_03[2],nVidInputBtns[8]]	= (nRoutingPair[ROOM_C][1] == 8 || nRoutingPair[ROOM_B][1] == 8);
	    [dvaTP_Switcher_03[2],nVidInputBtns[9]]	= (nRoutingPair[ROOM_C][1] == 9 || nRoutingPair[ROOM_B][1] == 9);
	    [dvaTP_Switcher_03[2],nVidInputBtns[10]]	= (nRoutingPair[ROOM_C][1] == 10 || nRoutingPair[ROOM_B][1] == 10);
	    [dvaTP_Switcher_03[2],nVidInputBtns[11]]	= (nRoutingPair[ROOM_C][1] == 11 || nRoutingPair[ROOM_B][1] == 11);
	    [dvaTP_Switcher_03[2],nVidInputBtns[12]]	= (nRoutingPair[ROOM_C][1] == 12 || nRoutingPair[ROOM_B][1] == 12);
	    [dvaTP_Switcher_03[2],nVidInputBtns[13]]	= (nRoutingPair[ROOM_C][1] == 13 || nRoutingPair[ROOM_B][1] == 13);
	    [dvaTP_Switcher_03[2],nVidInputBtns[14]]	= (nRoutingPair[ROOM_C][1] == 14 || nRoutingPair[ROOM_B][1] == 14);
	    [dvaTP_Switcher_03[2],nVidInputBtns[15]]	= (nRoutingPair[ROOM_C][1] == 15 || nRoutingPair[ROOM_B][1] == 15);
	    [dvaTP_Switcher_03[2],nVidInputBtns[16]]	= (nRoutingPair[ROOM_C][1] == 16 || nRoutingPair[ROOM_B][1] == 16);
	    [dvaTP_Switcher_03[2],nVidInputBtns[17]]	= (nRoutingPair[ROOM_C][1] == 17 || nRoutingPair[ROOM_B][1] == 17);
	    [dvaTP_Switcher_03[2],nVidInputBtns[18]]	= (nRoutingPair[ROOM_C][1] == 18 || nRoutingPair[ROOM_B][1] == 18);
	    [dvaTP_Switcher_03[2],nVidInputBtns[19]]	= (nRoutingPair[ROOM_C][1] == 19 || nRoutingPair[ROOM_B][1] == 19);
	    [dvaTP_Switcher_03[2],nVidInputBtns[20]]	= (nRoutingPair[ROOM_C][1] == 20 || nRoutingPair[ROOM_B][1] == 20);
	    [dvaTP_Switcher_03[2],nVidInputBtns[21]]	= (nRoutingPair[ROOM_C][1] == 21 || nRoutingPair[ROOM_B][1] == 21);
	    [dvaTP_Switcher_03[2],nVidInputBtns[22]]	= (nRoutingPair[ROOM_C][1] == 22 || nRoutingPair[ROOM_B][1] == 22);
	    [dvaTP_Switcher_03[2],nVidInputBtns[23]]	= (nRoutingPair[ROOM_C][1] == 23 || nRoutingPair[ROOM_B][1] == 23);
	    [dvaTP_Switcher_03[2],nVidInputBtns[24]]	= (nRoutingPair[ROOM_C][1] == 24 || nRoutingPair[ROOM_B][1] == 24);
	    [dvaTP_Switcher_03[2],nVidInputBtns[25]]	= (nRoutingPair[ROOM_C][1] == 25 || nRoutingPair[ROOM_B][1] == 25);
	    [dvaTP_Switcher_03[2],nVidInputBtns[26]]	= (nRoutingPair[ROOM_C][1] == 26 || nRoutingPair[ROOM_B][1] == 26);
	    [dvaTP_Switcher_03[2],nVidInputBtns[27]]	= (nRoutingPair[ROOM_C][1] == 27 || nRoutingPair[ROOM_B][1] == 27);
	    [dvaTP_Switcher_03[2],nVidInputBtns[28]]	= (nRoutingPair[ROOM_C][1] == 28 || nRoutingPair[ROOM_B][1] == 28);
	    [dvaTP_Switcher_03[2],nVidInputBtns[29]]	= (nRoutingPair[ROOM_C][1] == 29 || nRoutingPair[ROOM_B][1] == 29);
	    [dvaTP_Switcher_03[2],nVidInputBtns[30]]	= (nRoutingPair[ROOM_C][1] == 30 || nRoutingPair[ROOM_B][1] == 30);
	    [dvaTP_Switcher_03[2],nVidInputBtns[31]]	= (nRoutingPair[ROOM_C][1] == 31 || nRoutingPair[ROOM_B][1] == 31);
	    [dvaTP_Switcher_03[2],nVidInputBtns[32]]	= (nRoutingPair[ROOM_C][1] == 32 || nRoutingPair[ROOM_B][1] == 32);
	
	    [dvaTP_Switcher_03[1],nVidInputBtns[1]]	= (nRoutingPair[ROOM_A][1] == 1);
	    [dvaTP_Switcher_03[1],nVidInputBtns[2]]	= (nRoutingPair[ROOM_A][1] == 2);
	    [dvaTP_Switcher_03[1],nVidInputBtns[3]]	= (nRoutingPair[ROOM_A][1] == 3);
	    [dvaTP_Switcher_03[1],nVidInputBtns[4]]	= (nRoutingPair[ROOM_A][1] == 4);
	    [dvaTP_Switcher_03[1],nVidInputBtns[5]]	= (nRoutingPair[ROOM_A][1] == 5);
	    [dvaTP_Switcher_03[1],nVidInputBtns[6]]	= (nRoutingPair[ROOM_A][1] == 6);
	    [dvaTP_Switcher_03[1],nVidInputBtns[7]]	= (nRoutingPair[ROOM_A][1] == 7);
	    [dvaTP_Switcher_03[1],nVidInputBtns[8]]	= (nRoutingPair[ROOM_A][1] == 8);
	    [dvaTP_Switcher_03[1],nVidInputBtns[9]]	= (nRoutingPair[ROOM_A][1] == 9);
	    [dvaTP_Switcher_03[1],nVidInputBtns[10]]	= (nRoutingPair[ROOM_A][1] == 10);
	    [dvaTP_Switcher_03[1],nVidInputBtns[11]]	= (nRoutingPair[ROOM_A][1] == 11);
	    [dvaTP_Switcher_03[1],nVidInputBtns[12]]	= (nRoutingPair[ROOM_A][1] == 12);
	    [dvaTP_Switcher_03[1],nVidInputBtns[13]]	= (nRoutingPair[ROOM_A][1] == 13);
	    [dvaTP_Switcher_03[1],nVidInputBtns[14]]	= (nRoutingPair[ROOM_A][1] == 14);
	    [dvaTP_Switcher_03[1],nVidInputBtns[15]]	= (nRoutingPair[ROOM_A][1] == 15);
	    [dvaTP_Switcher_03[1],nVidInputBtns[16]]	= (nRoutingPair[ROOM_A][1] == 16);
	    [dvaTP_Switcher_03[1],nVidInputBtns[17]]	= (nRoutingPair[ROOM_A][1] == 17);
	    [dvaTP_Switcher_03[1],nVidInputBtns[18]]	= (nRoutingPair[ROOM_A][1] == 18);
	    [dvaTP_Switcher_03[1],nVidInputBtns[19]]	= (nRoutingPair[ROOM_A][1] == 19);
	    [dvaTP_Switcher_03[1],nVidInputBtns[20]]	= (nRoutingPair[ROOM_A][1] == 20);
	    [dvaTP_Switcher_03[1],nVidInputBtns[21]]	= (nRoutingPair[ROOM_A][1] == 21);
	    [dvaTP_Switcher_03[1],nVidInputBtns[22]]	= (nRoutingPair[ROOM_A][1] == 22);
	    [dvaTP_Switcher_03[1],nVidInputBtns[23]]	= (nRoutingPair[ROOM_A][1] == 23);
	    [dvaTP_Switcher_03[1],nVidInputBtns[24]]	= (nRoutingPair[ROOM_A][1] == 24);
	    [dvaTP_Switcher_03[1],nVidInputBtns[25]]	= (nRoutingPair[ROOM_A][1] == 25);
	    [dvaTP_Switcher_03[1],nVidInputBtns[26]]	= (nRoutingPair[ROOM_A][1] == 26);
	    [dvaTP_Switcher_03[1],nVidInputBtns[27]]	= (nRoutingPair[ROOM_A][1] == 27);
	    [dvaTP_Switcher_03[1],nVidInputBtns[28]]	= (nRoutingPair[ROOM_A][1] == 28);
	    [dvaTP_Switcher_03[1],nVidInputBtns[29]]	= (nRoutingPair[ROOM_A][1] == 29);
	    [dvaTP_Switcher_03[1],nVidInputBtns[30]]	= (nRoutingPair[ROOM_A][1] == 30);
	    [dvaTP_Switcher_03[1],nVidInputBtns[31]]	= (nRoutingPair[ROOM_A][1] == 31);
	    [dvaTP_Switcher_03[1],nVidInputBtns[32]]	= (nRoutingPair[ROOM_A][1] == 32);	

	}
	ACTIVE(!blnCombined[PARTITION_AB] && !blnCombined[PARTITION_BC]):  // all 3 separate
	{
	    [dvaTP_Switcher_03[3],nVidInputBtns[1]]	= (nRoutingPair[ROOM_C][1] == 1);
	    [dvaTP_Switcher_03[3],nVidInputBtns[2]]	= (nRoutingPair[ROOM_C][1] == 2);
	    [dvaTP_Switcher_03[3],nVidInputBtns[3]]	= (nRoutingPair[ROOM_C][1] == 3);
	    [dvaTP_Switcher_03[3],nVidInputBtns[4]]	= (nRoutingPair[ROOM_C][1] == 4);
	    [dvaTP_Switcher_03[3],nVidInputBtns[5]]	= (nRoutingPair[ROOM_C][1] == 5);
	    [dvaTP_Switcher_03[3],nVidInputBtns[6]]	= (nRoutingPair[ROOM_C][1] == 6);
	    [dvaTP_Switcher_03[3],nVidInputBtns[7]]	= (nRoutingPair[ROOM_C][1] == 7);
	    [dvaTP_Switcher_03[3],nVidInputBtns[8]]	= (nRoutingPair[ROOM_C][1] == 8);
	    [dvaTP_Switcher_03[3],nVidInputBtns[9]]	= (nRoutingPair[ROOM_C][1] == 9);
	    [dvaTP_Switcher_03[3],nVidInputBtns[10]]	= (nRoutingPair[ROOM_C][1] == 10);
	    [dvaTP_Switcher_03[3],nVidInputBtns[11]]	= (nRoutingPair[ROOM_C][1] == 11);
	    [dvaTP_Switcher_03[3],nVidInputBtns[12]]	= (nRoutingPair[ROOM_C][1] == 12);
	    [dvaTP_Switcher_03[3],nVidInputBtns[13]]	= (nRoutingPair[ROOM_C][1] == 13);
	    [dvaTP_Switcher_03[3],nVidInputBtns[14]]	= (nRoutingPair[ROOM_C][1] == 14);
	    [dvaTP_Switcher_03[3],nVidInputBtns[15]]	= (nRoutingPair[ROOM_C][1] == 15);
	    [dvaTP_Switcher_03[3],nVidInputBtns[16]]	= (nRoutingPair[ROOM_C][1] == 16);
	    [dvaTP_Switcher_03[3],nVidInputBtns[17]]	= (nRoutingPair[ROOM_C][1] == 17);
	    [dvaTP_Switcher_03[3],nVidInputBtns[18]]	= (nRoutingPair[ROOM_C][1] == 18);
	    [dvaTP_Switcher_03[3],nVidInputBtns[19]]	= (nRoutingPair[ROOM_C][1] == 19);
	    [dvaTP_Switcher_03[3],nVidInputBtns[20]]	= (nRoutingPair[ROOM_C][1] == 20);
	    [dvaTP_Switcher_03[3],nVidInputBtns[21]]	= (nRoutingPair[ROOM_C][1] == 21);
	    [dvaTP_Switcher_03[3],nVidInputBtns[22]]	= (nRoutingPair[ROOM_C][1] == 22);
	    [dvaTP_Switcher_03[3],nVidInputBtns[23]]	= (nRoutingPair[ROOM_C][1] == 23);
	    [dvaTP_Switcher_03[3],nVidInputBtns[24]]	= (nRoutingPair[ROOM_C][1] == 24);
	    [dvaTP_Switcher_03[3],nVidInputBtns[25]]	= (nRoutingPair[ROOM_C][1] == 25);
	    [dvaTP_Switcher_03[3],nVidInputBtns[26]]	= (nRoutingPair[ROOM_C][1] == 26);
	    [dvaTP_Switcher_03[3],nVidInputBtns[27]]	= (nRoutingPair[ROOM_C][1] == 27);
	    [dvaTP_Switcher_03[3],nVidInputBtns[28]]	= (nRoutingPair[ROOM_C][1] == 28);
	    [dvaTP_Switcher_03[3],nVidInputBtns[29]]	= (nRoutingPair[ROOM_C][1] == 29);
	    [dvaTP_Switcher_03[3],nVidInputBtns[30]]	= (nRoutingPair[ROOM_C][1] == 30);
	    [dvaTP_Switcher_03[3],nVidInputBtns[31]]	= (nRoutingPair[ROOM_C][1] == 31);
	    [dvaTP_Switcher_03[3],nVidInputBtns[32]]	= (nRoutingPair[ROOM_C][1] == 32);
	
	    [dvaTP_Switcher_03[2],nVidInputBtns[1]]	= (nRoutingPair[ROOM_B][1] == 1);
	    [dvaTP_Switcher_03[2],nVidInputBtns[2]]	= (nRoutingPair[ROOM_B][1] == 2);
	    [dvaTP_Switcher_03[2],nVidInputBtns[3]]	= (nRoutingPair[ROOM_B][1] == 3);
	    [dvaTP_Switcher_03[2],nVidInputBtns[4]]	= (nRoutingPair[ROOM_B][1] == 4);
	    [dvaTP_Switcher_03[2],nVidInputBtns[5]]	= (nRoutingPair[ROOM_B][1] == 5);
	    [dvaTP_Switcher_03[2],nVidInputBtns[6]]	= (nRoutingPair[ROOM_B][1] == 6);
	    [dvaTP_Switcher_03[2],nVidInputBtns[7]]	= (nRoutingPair[ROOM_B][1] == 7);
	    [dvaTP_Switcher_03[2],nVidInputBtns[8]]	= (nRoutingPair[ROOM_B][1] == 8);
	    [dvaTP_Switcher_03[2],nVidInputBtns[9]]	= (nRoutingPair[ROOM_B][1] == 9);
	    [dvaTP_Switcher_03[2],nVidInputBtns[10]]	= (nRoutingPair[ROOM_B][1] == 10);
	    [dvaTP_Switcher_03[2],nVidInputBtns[11]]	= (nRoutingPair[ROOM_B][1] == 11);
	    [dvaTP_Switcher_03[2],nVidInputBtns[12]]	= (nRoutingPair[ROOM_B][1] == 12);
	    [dvaTP_Switcher_03[2],nVidInputBtns[13]]	= (nRoutingPair[ROOM_B][1] == 13);
	    [dvaTP_Switcher_03[2],nVidInputBtns[14]]	= (nRoutingPair[ROOM_B][1] == 14);
	    [dvaTP_Switcher_03[2],nVidInputBtns[15]]	= (nRoutingPair[ROOM_B][1] == 15);
	    [dvaTP_Switcher_03[2],nVidInputBtns[16]]	= (nRoutingPair[ROOM_B][1] == 16);
	    [dvaTP_Switcher_03[2],nVidInputBtns[17]]	= (nRoutingPair[ROOM_B][1] == 17);
	    [dvaTP_Switcher_03[2],nVidInputBtns[18]]	= (nRoutingPair[ROOM_B][1] == 18);
	    [dvaTP_Switcher_03[2],nVidInputBtns[19]]	= (nRoutingPair[ROOM_B][1] == 19);
	    [dvaTP_Switcher_03[2],nVidInputBtns[20]]	= (nRoutingPair[ROOM_B][1] == 20);
	    [dvaTP_Switcher_03[2],nVidInputBtns[21]]	= (nRoutingPair[ROOM_B][1] == 21);
	    [dvaTP_Switcher_03[2],nVidInputBtns[22]]	= (nRoutingPair[ROOM_B][1] == 22);
	    [dvaTP_Switcher_03[2],nVidInputBtns[23]]	= (nRoutingPair[ROOM_B][1] == 23);
	    [dvaTP_Switcher_03[2],nVidInputBtns[24]]	= (nRoutingPair[ROOM_B][1] == 24);
	    [dvaTP_Switcher_03[2],nVidInputBtns[25]]	= (nRoutingPair[ROOM_B][1] == 25);
	    [dvaTP_Switcher_03[2],nVidInputBtns[26]]	= (nRoutingPair[ROOM_B][1] == 26);
	    [dvaTP_Switcher_03[2],nVidInputBtns[27]]	= (nRoutingPair[ROOM_B][1] == 27);
	    [dvaTP_Switcher_03[2],nVidInputBtns[28]]	= (nRoutingPair[ROOM_B][1] == 28);
	    [dvaTP_Switcher_03[2],nVidInputBtns[29]]	= (nRoutingPair[ROOM_B][1] == 29);
	    [dvaTP_Switcher_03[2],nVidInputBtns[30]]	= (nRoutingPair[ROOM_B][1] == 30);
	    [dvaTP_Switcher_03[2],nVidInputBtns[31]]	= (nRoutingPair[ROOM_B][1] == 31);
	    [dvaTP_Switcher_03[2],nVidInputBtns[32]]	= (nRoutingPair[ROOM_B][1] == 32);
	
	    [dvaTP_Switcher_03[1],nVidInputBtns[1]]	= (nRoutingPair[ROOM_A][1] == 1);
	    [dvaTP_Switcher_03[1],nVidInputBtns[2]]	= (nRoutingPair[ROOM_A][1] == 2);
	    [dvaTP_Switcher_03[1],nVidInputBtns[3]]	= (nRoutingPair[ROOM_A][1] == 3);
	    [dvaTP_Switcher_03[1],nVidInputBtns[4]]	= (nRoutingPair[ROOM_A][1] == 4);
	    [dvaTP_Switcher_03[1],nVidInputBtns[5]]	= (nRoutingPair[ROOM_A][1] == 5);
	    [dvaTP_Switcher_03[1],nVidInputBtns[6]]	= (nRoutingPair[ROOM_A][1] == 6);
	    [dvaTP_Switcher_03[1],nVidInputBtns[7]]	= (nRoutingPair[ROOM_A][1] == 7);
	    [dvaTP_Switcher_03[1],nVidInputBtns[8]]	= (nRoutingPair[ROOM_A][1] == 8);
	    [dvaTP_Switcher_03[1],nVidInputBtns[9]]	= (nRoutingPair[ROOM_A][1] == 9);
	    [dvaTP_Switcher_03[1],nVidInputBtns[10]]	= (nRoutingPair[ROOM_A][1] == 10);
	    [dvaTP_Switcher_03[1],nVidInputBtns[11]]	= (nRoutingPair[ROOM_A][1] == 11);
	    [dvaTP_Switcher_03[1],nVidInputBtns[12]]	= (nRoutingPair[ROOM_A][1] == 12);
	    [dvaTP_Switcher_03[1],nVidInputBtns[13]]	= (nRoutingPair[ROOM_A][1] == 13);
	    [dvaTP_Switcher_03[1],nVidInputBtns[14]]	= (nRoutingPair[ROOM_A][1] == 14);
	    [dvaTP_Switcher_03[1],nVidInputBtns[15]]	= (nRoutingPair[ROOM_A][1] == 15);
	    [dvaTP_Switcher_03[1],nVidInputBtns[16]]	= (nRoutingPair[ROOM_A][1] == 16);
	    [dvaTP_Switcher_03[1],nVidInputBtns[17]]	= (nRoutingPair[ROOM_A][1] == 17);
	    [dvaTP_Switcher_03[1],nVidInputBtns[18]]	= (nRoutingPair[ROOM_A][1] == 18);
	    [dvaTP_Switcher_03[1],nVidInputBtns[19]]	= (nRoutingPair[ROOM_A][1] == 19);
	    [dvaTP_Switcher_03[1],nVidInputBtns[20]]	= (nRoutingPair[ROOM_A][1] == 20);
	    [dvaTP_Switcher_03[1],nVidInputBtns[21]]	= (nRoutingPair[ROOM_A][1] == 21);
	    [dvaTP_Switcher_03[1],nVidInputBtns[22]]	= (nRoutingPair[ROOM_A][1] == 22);
	    [dvaTP_Switcher_03[1],nVidInputBtns[23]]	= (nRoutingPair[ROOM_A][1] == 23);
	    [dvaTP_Switcher_03[1],nVidInputBtns[24]]	= (nRoutingPair[ROOM_A][1] == 24);
	    [dvaTP_Switcher_03[1],nVidInputBtns[25]]	= (nRoutingPair[ROOM_A][1] == 25);
	    [dvaTP_Switcher_03[1],nVidInputBtns[26]]	= (nRoutingPair[ROOM_A][1] == 26);
	    [dvaTP_Switcher_03[1],nVidInputBtns[27]]	= (nRoutingPair[ROOM_A][1] == 27);
	    [dvaTP_Switcher_03[1],nVidInputBtns[28]]	= (nRoutingPair[ROOM_A][1] == 28);
	    [dvaTP_Switcher_03[1],nVidInputBtns[29]]	= (nRoutingPair[ROOM_A][1] == 29);
	    [dvaTP_Switcher_03[1],nVidInputBtns[30]]	= (nRoutingPair[ROOM_A][1] == 30);
	    [dvaTP_Switcher_03[1],nVidInputBtns[31]]	= (nRoutingPair[ROOM_A][1] == 31);
	    [dvaTP_Switcher_03[1],nVidInputBtns[32]]	= (nRoutingPair[ROOM_A][1] == 32);	

	}

    }
}

