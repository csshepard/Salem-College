PROGRAM_NAME='_RoutingMacros'
(***********************************************************)
(*  FILE CREATED ON: 06/12/2013  AT: 10:41:35              *)
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 05/22/2014  AT: 16:15:23        *)
(***********************************************************)


(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_VARIABLE

VOLATILE INTEGER nPCSelected[3]
VOLATILE INTEGER nPCSelectBtns[] = {1101,1102,1103,1104,1105}

(***********************************************************)
(*                  THE EVENTS GO BELOW                    *)
(***********************************************************)
DEFINE_EVENT


BUTTON_EVENT[dvaTP_Macros_01,0]
{
    PUSH: nWhichRm = GET_LAST(dvaTP_Macros_01);
}


BUTTON_EVENT[dvaTP_Macros_01[ROOM_A],nMacrosBtns]
{
    PUSH:
    {
	LOCAL_VAR INTEGER x
	
	nWhichMacro[ROOM_A] = GET_LAST(nMacrosBtns);
	nPCSelected[ROOM_A] = 0;
	
	fnSysPow(ROOM_A,TRUE);  // will trigger multiple rooms power if combined
	    
	blnPhoneControl[ROOM_A] = FALSE;  // clear phone fb	
	SEND_COMMAND dvaTP_Macros_01[ROOM_A], "'@PPN-Wait'";
	fnMicMute(ROOM_A,TRUE);  // mute mics
	
	WAIT_UNTIL(blnSysPow[ROOM_A])	// handle page flips and src selection vars
	{
	    FOR(x=1;x<=CONFIG_SWITCHER_NUMBER_OUTPUTS;x++)
	    {
		IF(sRoutingMacros[nWhichMacro[ROOM_A]].VideoRoutes[ROOM_A][x])
		    fnMTX(sRoutingMacros[nWhichMacro[ROOM_A]].VideoRoutes[ROOM_A][x],x,'V');
	    }
	    
	    fnMTX(sRoutingMacros[nWhichMacro[ROOM_A]].AudioSource[ROOM_A],ao_PGM[ROOM_A],'A');

	    SEND_COMMAND dvaTP_Macros_01[ROOM_A], "'@PPX'";
	    SEND_COMMAND dvaTP_Macros_01[ROOM_A], "'PAGE-Main'";
	    SEND_COMMAND dvaTP_Macros_01[ROOM_A], "'@PPN-', sSwitcherInfo[1].Inputs[sRoutingMacros[nWhichMacro[ROOM_A]].AudioSource[ROOM_A]].ControlPage, ';Main'";
	    SEND_COMMAND dvaTP_Macros_01[ROOM_A], "'@PPN-Room A Sources;Main'";

	    // set this for control page fb
	    nRoutingPair[ROOM_A][1] = sRoutingMacros[nWhichMacro[ROOM_A]].AudioSource[ROOM_A];	    
	}

	
	IF(blnCombined[PARTITION_AB])  // Room A/B combined, we can sync everything up
	{
	    fnMTX(0,ao_PGM[ROOM_B],'A');	
	    blnPhoneControl[ROOM_B] = FALSE;	    
	    SEND_COMMAND dvaTP_Macros_01[ROOM_B], "'@PPN-Wait'";
    	    fnMicMute(ROOM_B,TRUE);

	    WAIT_UNTIL(blnSysPow[ROOM_B])
	    {
		// perform routing to room B to match A
		FOR(x=1;x<=CONFIG_SWITCHER_NUMBER_OUTPUTS;x++)
		{
		    IF(sRoutingMacros[nWhichMacro[ROOM_A]].VideoRoutes[ROOM_A][x])
			fnMTX(sRoutingMacros[nWhichMacro[ROOM_A]].VideoRoutes[ROOM_A][x],vo_2,'V');
		}
		fnMTX(sRoutingMacros[nWhichMacro[ROOM_A]].AudioSource[ROOM_A],ao_PGM[ROOM_B],'A');

		SEND_COMMAND dvaTP_Macros_01[ROOM_B], "'@PPX'";
		SEND_COMMAND dvaTP_Macros_01[ROOM_B], "'PAGE-Main'";
		SEND_COMMAND dvaTP_Macros_01[ROOM_B], "'@PPN-', sSwitcherInfo[1].Inputs[sRoutingMacros[nWhichMacro[ROOM_A]].AudioSource[ROOM_A]].ControlPage, ';Main'";
		
		SEND_COMMAND dvaTP_Macros_01[ROOM_A], "'PPOF-Room A Sources'";  // will close any popups in the group that may be up
		SEND_COMMAND dvaTP_Macros_01[ROOM_B], "'PPOF-Room A Sources'";
		SEND_COMMAND dvaTP_Macros_01[ROOM_A], "'@PPN-Room AB Sources;Main'";
		SEND_COMMAND dvaTP_Macros_01[ROOM_B], "'@PPN-Room AB Sources;Main'";

		// set this for control page fb
		nRoutingPair[ROOM_B][1] = sRoutingMacros[nWhichMacro[ROOM_A]].AudioSource[ROOM_A];	    
	    }


	    IF(blnCombined[PARTITION_BC])   // room A/B/C all combined, now sync room C to A/B
	    {
		fnMTX(0,ao_PGM[ROOM_C],'A');
		blnPhoneControl[ROOM_C] = FALSE;
		SEND_COMMAND dvaTP_Macros_01[ROOM_C], "'@PPN-Wait'";
		fnMicMute(ROOM_C,TRUE);
		
		WAIT_UNTIL(blnSysPow[ROOM_C])
		{
		    // perform routing to match C to A/B
		    FOR(x=1;x<=CONFIG_SWITCHER_NUMBER_OUTPUTS;x++)
		    {
			IF(sRoutingMacros[nWhichMacro[ROOM_A]].VideoRoutes[ROOM_A][x])
			    fnMTX(sRoutingMacros[nWhichMacro[ROOM_A]].VideoRoutes[ROOM_A][x],4,'V');  // send to long throw projector
		    }
		    fnMTX(sRoutingMacros[nWhichMacro[ROOM_A]].AudioSource[ROOM_A],ao_PGM[ROOM_C],'A');

		    SEND_COMMAND dvaTP_Macros_01[ROOM_C], "'@PPX'";
		    SEND_COMMAND dvaTP_Macros_01[ROOM_C], "'PAGE-Main'";
		    SEND_COMMAND dvaTP_Macros_01[ROOM_C], "'@PPN-', sSwitcherInfo[1].Inputs[sRoutingMacros[nWhichMacro[ROOM_A]].AudioSource[ROOM_A]].ControlPage, ';Main'";
	
		    SEND_COMMAND dvaTP_Macros_01[ROOM_A], "'PPOF-Room A Sources'";  // will close all popups in group
    		    SEND_COMMAND dvaTP_Macros_01[ROOM_B], "'PPOF-Room A Sources'";
		    SEND_COMMAND dvaTP_Macros_01[ROOM_C], "'PPOF-Room A Sources'";

		    SEND_COMMAND dvaTP_Macros_01[ROOM_A], "'@PPN-Room ABC Sources;Main'";
		    SEND_COMMAND dvaTP_Macros_01[ROOM_B], "'@PPN-Room ABC Sources;Main'";
		    SEND_COMMAND dvaTP_Macros_01[ROOM_C], "'@PPN-Room ABC Sources;Main'";
	
		    // set this for control page fb
		    nRoutingPair[ROOM_C][1] = sRoutingMacros[nWhichMacro[ROOM_A]].AudioSource[ROOM_A];	    
		}
		
		
		fnMonitor(ROOM_A,'OFF');
		fnProjector(ROOM_B,'OFF');
		fnProjector(ROOM_B2,'ON');
		fnProjector(ROOM_C,'OFF');
	    }
	}
    }
}




BUTTON_EVENT[dvaTP_Macros_01[ROOM_B],nMacrosBtns]
{
    PUSH:
    {
	LOCAL_VAR INTEGER x
	
	nWhichMacro[ROOM_B] = GET_LAST(nMacrosBtns);
	nPCSelected[ROOM_B] = 0;
	
	fnSysPow(ROOM_B,TRUE);  // will trigger multiple rooms power if combined
	    
	fnMTX(0,ao_PGM[ROOM_B],'A');  // clear current audio	
	blnPhoneControl[ROOM_B] = FALSE;  // clear phone fb	
	SEND_COMMAND dvaTP_Macros_01[ROOM_B], "'@PPN-Wait'";
	fnMicMute(ROOM_B,TRUE);  // mute mics
	
	WAIT_UNTIL(blnSysPow[ROOM_B])	// handle page flips and src selection vars
	{
	    FOR(x=1;x<=CONFIG_SWITCHER_NUMBER_OUTPUTS;x++)
	    {
		IF(sRoutingMacros[nWhichMacro[ROOM_B]].VideoRoutes[ROOM_B][x])
		    fnMTX(sRoutingMacros[nWhichMacro[ROOM_B]].VideoRoutes[ROOM_B][x],x,'V');
	    }
	    
	    fnMTX(sRoutingMacros[nWhichMacro[ROOM_B]].AudioSource[ROOM_B],ao_PGM[ROOM_B],'A');

	    SEND_COMMAND dvaTP_Macros_01[ROOM_B], "'@PPX'";
	    SEND_COMMAND dvaTP_Macros_01[ROOM_B], "'PAGE-Main'";
	    SEND_COMMAND dvaTP_Macros_01[ROOM_B], "'@PPN-', sSwitcherInfo[1].Inputs[sRoutingMacros[nWhichMacro[ROOM_B]].AudioSource[ROOM_B]].ControlPage, ';Main'";
	    SEND_COMMAND dvaTP_Macros_01[ROOM_B], "'@PPN-Room B Sources;Main'";

	    // set this for control page fb
	    nRoutingPair[ROOM_B][1] = sRoutingMacros[nWhichMacro[ROOM_B]].AudioSource[ROOM_B];	    
	}
	
	IF(blnCombined[PARTITION_AB] && !blnCombined[PARTITION_BC])  // Room A/B combined, we can sync everything up
	{
	    fnMTX(0,ao_PGM[ROOM_A],'A');	
	    blnPhoneControl[ROOM_A] = FALSE;	    
	    SEND_COMMAND dvaTP_Macros_01[ROOM_A], "'@PPN-Wait'";
    	    fnMicMute(ROOM_A,TRUE);

	    WAIT_UNTIL(blnSysPow[ROOM_A])
	    {
		// perform routing to room A to match B
		FOR(x=1;x<=CONFIG_SWITCHER_NUMBER_OUTPUTS;x++)
		{
		    IF(sRoutingMacros[nWhichMacro[ROOM_B]].VideoRoutes[ROOM_B][x])
			fnMTX(sRoutingMacros[nWhichMacro[ROOM_B]].VideoRoutes[ROOM_B][x],vo_1,'V');
		}
		fnMTX(sRoutingMacros[nWhichMacro[ROOM_B]].AudioSource[ROOM_B],ao_PGM[ROOM_A],'A');

		SEND_COMMAND dvaTP_Macros_01[ROOM_A], "'@PPX'";
		SEND_COMMAND dvaTP_Macros_01[ROOM_A], "'PAGE-Main'";
		SEND_COMMAND dvaTP_Macros_01[ROOM_A], "'@PPN-', sSwitcherInfo[1].Inputs[sRoutingMacros[nWhichMacro[ROOM_B]].AudioSource[ROOM_B]].ControlPage, ';Main'";
		
		SEND_COMMAND dvaTP_Macros_01[ROOM_A], "'PPOF-Room A Sources'";  // will close any popups in the group that may be up
		SEND_COMMAND dvaTP_Macros_01[ROOM_B], "'PPOF-Room A Sources'";
		SEND_COMMAND dvaTP_Macros_01[ROOM_A], "'@PPN-Room AB Sources;Main'";
		SEND_COMMAND dvaTP_Macros_01[ROOM_B], "'@PPN-Room AB Sources;Main'";

		// set this for control page fb
		nRoutingPair[ROOM_A][1] = sRoutingMacros[nWhichMacro[ROOM_B]].AudioSource[ROOM_B];	    
	    }

	}

	IF(!blnCombined[PARTITION_AB] && blnCombined[PARTITION_BC])  // Room B/C combined, we can sync everything up - broken out since B can be combined on either side
	{
	    fnMTX(0,ao_PGM[ROOM_C],'A');	
	    blnPhoneControl[ROOM_C] = FALSE;	    
	    SEND_COMMAND dvaTP_Macros_01[ROOM_C], "'@PPN-Wait'";
    	    fnMicMute(ROOM_C,TRUE);

	    WAIT_UNTIL(blnSysPow[ROOM_C])
	    {
		// perform routing to room A to match B
		FOR(x=1;x<=CONFIG_SWITCHER_NUMBER_OUTPUTS;x++)
		{
		    IF(sRoutingMacros[nWhichMacro[ROOM_B]].VideoRoutes[ROOM_B][x])
			fnMTX(sRoutingMacros[nWhichMacro[ROOM_B]].VideoRoutes[ROOM_B][x],vo_4,'V');  // send to long-throw projector
		}
		fnMTX(sRoutingMacros[nWhichMacro[ROOM_B]].AudioSource[ROOM_B],ao_PGM[ROOM_C],'A');

		SEND_COMMAND dvaTP_Macros_01[ROOM_C], "'@PPX'";
		SEND_COMMAND dvaTP_Macros_01[ROOM_C], "'PAGE-Main'";
		SEND_COMMAND dvaTP_Macros_01[ROOM_C], "'@PPN-', sSwitcherInfo[1].Inputs[sRoutingMacros[nWhichMacro[ROOM_B]].AudioSource[ROOM_B]].ControlPage, ';Main'";
		
		SEND_COMMAND dvaTP_Macros_01[ROOM_C], "'PPOF-Room A Sources'";  // will close any popups in the group that may be up
		SEND_COMMAND dvaTP_Macros_01[ROOM_B], "'PPOF-Room A Sources'";
		SEND_COMMAND dvaTP_Macros_01[ROOM_C], "'@PPN-Room BC Sources;Main'";
		SEND_COMMAND dvaTP_Macros_01[ROOM_B], "'@PPN-Room BC Sources;Main'";

		// set this for control page fb
		nRoutingPair[ROOM_C][1] = sRoutingMacros[nWhichMacro[ROOM_B]].AudioSource[ROOM_B];	    
	    }

	    
    	    fnProjector(ROOM_B,'OFF');
	    fnProjector(ROOM_B2,'ON');
	    fnProjector(ROOM_C,'OFF');

	}

	IF(blnCombined[PARTITION_BC] && blnCombined[PARTITION_AB])   // room A/B/C combined - this had to be broken out since Room B could be combined on either side
	{
	    fnMTX(0,ao_PGM[ROOM_A],'A');
	    fnMTX(0,ao_PGM[ROOM_B],'A');
	    fnMTX(0,ao_PGM[ROOM_C],'A');
	    blnPhoneControl[ROOM_A] = FALSE;
	    blnPhoneControl[ROOM_B] = FALSE;
	    blnPhoneControl[ROOM_C] = FALSE;
	    SEND_COMMAND dvaTP_Macros_01, "'@PPN-Wait'";
	    fnMicMute(ROOM_A,TRUE);
	    fnMicMute(ROOM_B,TRUE);
	    fnMicMute(ROOM_C,TRUE);
	    
	    WAIT_UNTIL(blnSysPow[ROOM_A] && blnSysPow[ROOM_B] && blnSysPow[ROOM_C])
	    {
		// perform routing to match C to A/B
		FOR(x=1;x<=CONFIG_SWITCHER_NUMBER_OUTPUTS;x++)
		{
		    IF(sRoutingMacros[nWhichMacro[ROOM_B]].VideoRoutes[ROOM_B][x])
			fnMTX(sRoutingMacros[nWhichMacro[ROOM_B]].VideoRoutes[ROOM_B][x],vo_4,'V');  // send to long throw projector
		}
		fnMTX(sRoutingMacros[nWhichMacro[ROOM_B]].AudioSource[ROOM_B],ao_PGM[ROOM_B],'A');
		fnMTX(sRoutingMacros[nWhichMacro[ROOM_B]].AudioSource[ROOM_B],ao_PGM[ROOM_A],'A');
		fnMTX(sRoutingMacros[nWhichMacro[ROOM_B]].AudioSource[ROOM_B],ao_PGM[ROOM_C],'A');

		SEND_COMMAND dvaTP_Macros_01, "'@PPX'";
		SEND_COMMAND dvaTP_Macros_01, "'PAGE-Main'";
		SEND_COMMAND dvaTP_Macros_01, "'@PPN-', sSwitcherInfo[1].Inputs[sRoutingMacros[nWhichMacro[ROOM_B]].AudioSource[ROOM_B]].ControlPage, ';Main'";
    
		SEND_COMMAND dvaTP_Macros_01, "'PPOF-Room A Sources'";  // will close all popups in group
		SEND_COMMAND dvaTP_Macros_01, "'PPOF-Room A Sources'";
		SEND_COMMAND dvaTP_Macros_01, "'PPOF-Room A Sources'";

		SEND_COMMAND dvaTP_Macros_01, "'@PPN-Room ABC Sources;Main'";
		SEND_COMMAND dvaTP_Macros_01, "'@PPN-Room ABC Sources;Main'";
		SEND_COMMAND dvaTP_Macros_01, "'@PPN-Room ABC Sources;Main'";
    
		// set this for control page fb
		nRoutingPair[ROOM_B][1] = sRoutingMacros[nWhichMacro[ROOM_B]].AudioSource[ROOM_B];	    
	    }
	    
	    
	    fnMonitor(ROOM_A,'OFF');
	    fnProjector(ROOM_B,'OFF');
	    fnProjector(ROOM_B2,'ON');
	    fnProjector(ROOM_C,'OFF');
	}	
    }
}



BUTTON_EVENT[dvaTP_Macros_01[ROOM_C],nMacrosBtns]
{
    PUSH:
    {
	LOCAL_VAR INTEGER x
	
	nWhichMacro[ROOM_C] = GET_LAST(nMacrosBtns);
	nPCSelected[ROOM_C] = 0;
	
	fnSysPow(ROOM_C,TRUE);  // will trigger multiple rooms power if combined
	    
	fnMTX(0,ao_PGM[ROOM_C],'A');  // clear current audio	
	blnPhoneControl[ROOM_C] = FALSE;  // clear phone fb	
	SEND_COMMAND dvaTP_Macros_01[ROOM_C], "'@PPN-Wait'";
	fnMicMute(ROOM_C,TRUE);  // mute mics
	
	WAIT_UNTIL(blnSysPow[ROOM_C])	// handle page flips and src selection vars
	{
	    FOR(x=1;x<=CONFIG_SWITCHER_NUMBER_OUTPUTS;x++)
	    {
		IF(sRoutingMacros[nWhichMacro[ROOM_C]].VideoRoutes[ROOM_C][x])
		    fnMTX(sRoutingMacros[nWhichMacro[ROOM_C]].VideoRoutes[ROOM_C][x],x,'V');
	    }
	    
	    fnMTX(sRoutingMacros[nWhichMacro[ROOM_C]].AudioSource[ROOM_C],ao_PGM[ROOM_C],'A');
	

	    SEND_COMMAND dvaTP_Macros_01[ROOM_C], "'@PPX'";
	    SEND_COMMAND dvaTP_Macros_01[ROOM_C], "'PAGE-Main'";
	    SEND_COMMAND dvaTP_Macros_01[ROOM_C], "'@PPN-', sSwitcherInfo[1].Inputs[sRoutingMacros[nWhichMacro[ROOM_C]].AudioSource[ROOM_C]].ControlPage, ';Main'";
	    SEND_COMMAND dvaTP_Macros_01[ROOM_C], "'@PPN-Room C Sources;Main'";

	    // set this for control page fb
	    nRoutingPair[ROOM_C][1] = sRoutingMacros[nWhichMacro[ROOM_C]].AudioSource[ROOM_C];	    
	}

	
	IF(blnCombined[PARTITION_BC])  // Room B/C combined, we can sync everything up
	{
	    fnMTX(0,ao_PGM[ROOM_B],'A');	
	    blnPhoneControl[ROOM_B] = FALSE;	    
	    SEND_COMMAND dvaTP_Macros_01[ROOM_B], "'@PPN-Wait'";
    	    fnMicMute(ROOM_B,TRUE);

	    WAIT_UNTIL(blnSysPow[ROOM_B])
	    {
		// perform routing to room B to match C
		FOR(x=1;x<=CONFIG_SWITCHER_NUMBER_OUTPUTS;x++)
		{
		    IF(sRoutingMacros[nWhichMacro[ROOM_C]].VideoRoutes[ROOM_C][x])
			fnMTX(sRoutingMacros[nWhichMacro[ROOM_C]].VideoRoutes[ROOM_C][x],vo_4,'V');
		}
		fnMTX(sRoutingMacros[nWhichMacro[ROOM_C]].AudioSource[ROOM_C],ao_PGM[ROOM_B],'A');

		SEND_COMMAND dvaTP_Macros_01[ROOM_B], "'@PPX'";
		SEND_COMMAND dvaTP_Macros_01[ROOM_B], "'PAGE-Main'";
		SEND_COMMAND dvaTP_Macros_01[ROOM_B], "'@PPN-', sSwitcherInfo[1].Inputs[sRoutingMacros[nWhichMacro[ROOM_C]].AudioSource[ROOM_C]].ControlPage, ';Main'";
		
		SEND_COMMAND dvaTP_Macros_01[ROOM_C], "'PPOF-Room A Sources'";  // will close any popups in the group that may be up
		SEND_COMMAND dvaTP_Macros_01[ROOM_B], "'PPOF-Room A Sources'";
		SEND_COMMAND dvaTP_Macros_01[ROOM_C], "'@PPN-Room BC Sources;Main'";
		SEND_COMMAND dvaTP_Macros_01[ROOM_B], "'@PPN-Room BC Sources;Main'";

		// set this for control page fb
		nRoutingPair[ROOM_B][1] = sRoutingMacros[nWhichMacro[ROOM_C]].AudioSource[ROOM_C];	    
	    }


	    IF(blnCombined[PARTITION_AB])   // room A/B/C all combined, now sync room A to B/C
	    {
		fnMTX(0,ao_PGM[ROOM_A],'A');
		blnPhoneControl[ROOM_A] = FALSE;
		SEND_COMMAND dvaTP_Macros_01[ROOM_A], "'@PPN-Wait'";
		fnMicMute(ROOM_A,TRUE);
		
		WAIT_UNTIL(blnSysPow[ROOM_A])
		{
		    // perform routing to match A to B/C
		    FOR(x=1;x<=CONFIG_SWITCHER_NUMBER_OUTPUTS;x++)
		    {
			IF(sRoutingMacros[nWhichMacro[ROOM_C]].VideoRoutes[ROOM_C][x])
			    fnMTX(sRoutingMacros[nWhichMacro[ROOM_C]].VideoRoutes[ROOM_C][x],vo_4,'V');  // send to long throw projector
		    }
		    fnMTX(sRoutingMacros[nWhichMacro[ROOM_C]].AudioSource[ROOM_C],ao_PGM[ROOM_A],'A');

		    SEND_COMMAND dvaTP_Macros_01, "'@PPX'";
		    SEND_COMMAND dvaTP_Macros_01, "'PAGE-Main'";
		    SEND_COMMAND dvaTP_Macros_01, "'@PPN-', sSwitcherInfo[1].Inputs[sRoutingMacros[nWhichMacro[ROOM_C]].AudioSource[ROOM_C]].ControlPage, ';Main'";
	
		    SEND_COMMAND dvaTP_Macros_01, "'PPOF-Room A Sources'";  // will close all popups in group
    		    SEND_COMMAND dvaTP_Macros_01, "'PPOF-Room A Sources'";
		    SEND_COMMAND dvaTP_Macros_01, "'PPOF-Room A Sources'";

		    SEND_COMMAND dvaTP_Macros_01, "'@PPN-Room ABC Sources;Main'";
		    SEND_COMMAND dvaTP_Macros_01, "'@PPN-Room ABC Sources;Main'";
		    SEND_COMMAND dvaTP_Macros_01, "'@PPN-Room ABC Sources;Main'";
	
		    // set this for control page fb
		    nRoutingPair[ROOM_A][1] = sRoutingMacros[nWhichMacro[ROOM_C]].AudioSource[ROOM_C];	    
		}
		
		
		fnMonitor(ROOM_A,'OFF');
		fnProjector(ROOM_B,'OFF');
		fnProjector(ROOM_B2,'ON');
		fnProjector(ROOM_C,'OFF');
	    }
	}
    }
}


/////////////////////////////////////
/////// PC SELECTION MACRO //////////
/////////////////////////////////////
BUTTON_EVENT[dvaTP_Main_01,nPCSelectBtns]
{
    PUSH:
    {
	STACK_VAR INTEGER x
	FOR(x=1;x<=4;x++) 
	    sRoutingMacros[1].VideoRoutes[nWhichRm][x] = 0;
	    
	nPCSelected[nWhichRm] = GET_LAST(nPCSelectBtns);
	    
	SELECT
	{
	    ACTIVE(blnCombined[PARTITION_AB] && blnCombined[PARTITION_BC]):  // all 3 rooms combined
	    {
		sRoutingMacros[1].VideoRoutes[nWhichRm][vo_4] = nPCSelected[nWhichRm];
	    }
	    ACTIVE(!blnCombined[PARTITION_AB] && !blnCombined[PARTITION_BC]):  // all 3 rooms separate
	    {
		sRoutingMacros[1].VideoRoutes[nWhichRm][nWhichRm] = nPCSelected[nWhichRm];
	    }
	    ACTIVE(blnCombined[PARTITION_AB] && !blnCombined[PARTITION_BC]):  // A/B combined, C separate
	    {
		IF(nWhichRm == ROOM_A || nWhichRm == ROOM_B) 	
		{
		    sRoutingMacros[1].VideoRoutes[nWhichRm][vo_1] = nPCSelected[nWhichRm];
		    sRoutingMacros[1].VideoRoutes[nWhichRm][vo_2] = nPCSelected[nWhichRm];
		}
		ELSE						
		{
		    sRoutingMacros[1].VideoRoutes[ROOM_C][vo_3] = nPCSelected[nWhichRm];
		}

	    }
	    ACTIVE(!blnCombined[PARTITION_AB] && blnCombined[PARTITION_BC]):  // B/C combined, A separate
	    {
		IF(nWhichRm == ROOM_C || nWhichRm == ROOM_B) 	
		    sRoutingMacros[1].VideoRoutes[nWhichRm][vo_4] = nPCSelected[nWhichRm];
		ELSE						
		    sRoutingMacros[1].VideoRoutes[ROOM_A][vo_1] = nPCSelected[nWhichRm];
	    }
	}
	sRoutingMacros[1].AudioSource[nWhichRm] 	= nPCSelected[nWhichRm];
    }
}

	

DEFINE_PROGRAM

[dvaTP_Main_01[ROOM_A],nPCSelectBtns[1]]	= (nPCSelected[ROOM_A] == 1);
[dvaTP_Main_01[ROOM_A],nPCSelectBtns[2]]	= (nPCSelected[ROOM_A] == 2);
[dvaTP_Main_01[ROOM_A],nPCSelectBtns[3]]	= (nPCSelected[ROOM_A] == 3);
[dvaTP_Main_01[ROOM_A],nPCSelectBtns[4]]	= (nPCSelected[ROOM_A] == 4);
[dvaTP_Main_01[ROOM_A],nPCSelectBtns[5]]	= (nPCSelected[ROOM_A] == 5);

[dvaTP_Main_01[ROOM_B],nPCSelectBtns[1]]	= (nPCSelected[ROOM_B] == 1);
[dvaTP_Main_01[ROOM_B],nPCSelectBtns[2]]	= (nPCSelected[ROOM_B] == 2);
[dvaTP_Main_01[ROOM_B],nPCSelectBtns[3]]	= (nPCSelected[ROOM_B] == 3);
[dvaTP_Main_01[ROOM_B],nPCSelectBtns[4]]	= (nPCSelected[ROOM_B] == 4);
[dvaTP_Main_01[ROOM_B],nPCSelectBtns[5]]	= (nPCSelected[ROOM_B] == 5);

[dvaTP_Main_01[ROOM_C],nPCSelectBtns[1]]	= (nPCSelected[ROOM_C] == 1);
[dvaTP_Main_01[ROOM_C],nPCSelectBtns[2]]	= (nPCSelected[ROOM_C] == 2);
[dvaTP_Main_01[ROOM_C],nPCSelectBtns[3]]	= (nPCSelected[ROOM_C] == 3);
[dvaTP_Main_01[ROOM_C],nPCSelectBtns[4]]	= (nPCSelected[ROOM_C] == 4);
[dvaTP_Main_01[ROOM_C],nPCSelectBtns[5]]	= (nPCSelected[ROOM_C] == 5);

