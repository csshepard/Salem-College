PROGRAM_NAME='_GenericSystemFunctions'
(***********************************************************)
(*  FILE CREATED ON: 07/08/2013  AT: 11:22:10              *)
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 09/02/2014  AT: 08:18:59        *)
(***********************************************************)

DEFINE_CONSTANT



/////// Status Popups ///////
INTEGER tlStatusPopups	= 20	// timeline for rotating the status popups on the toolbar
LONG	tlStatusPopups_Array[] = {3000,3000,3000,3000}


CHAR cStatusPopupNames[4][25] =
{
    'Status_SystemPower',
    'Status_DisplayPower',
    'Status_VTC',
    'Status_Phone'
}




(***********************************************************)
(*       MUTUALLY EXCLUSIVE DEFINITIONS GO BELOW           *)
(***********************************************************)
DEFINE_MUTUALLY_EXCLUSIVE
([dvRelay,1],[dvRelay,2])



DEFINE_FUNCTION fnCombineDivide() 
{
    STACK_VAR INTEGER x
    
    SEND_STRING dvSWITCHER, "'1.'";  // recall global preset 1
    
    IF(blnSysPow[ROOM_A] || blnSysPow[ROOM_B] || blnSysPow[ROOM_C])
    {
	SEND_COMMAND dvTP_Op_Main_401, "'^SHO-3000,1'";
	WAIT 600 SEND_COMMAND dvTP_Op_Main_401, "'^SHO-3000,0'";	

	SEND_COMMAND dvaTP_Main_01, "'^SHO-3000,1'";
	WAIT 600 SEND_COMMAND dvaTP_Main_01, "'^SHO-3000,0'";	

    }
    ELSE
    {
	SEND_COMMAND dvTP_Op_Main_401, "'^SHO-3000,1'";
	WAIT 50 SEND_COMMAND dvTP_Op_Main_401, "'^SHO-3000,0'";	    

	SEND_COMMAND dvaTP_Main_01, "'^SHO-3000,1'";
	WAIT 50 SEND_COMMAND dvaTP_Main_01, "'^SHO-3000,0'";	    

    }
    
    
    SELECT
    {
	ACTIVE(blnCombined[PARTITION_AB] && blnCombined[PARTITION_BC]):  // all 3 rooms
	{
	    IF(blnSysPow[ROOM_A] || blnSysPow[ROOM_B] || blnSysPow[ROOM_C]) // at least one room powered on, sync all to C
	    {
		SEND_COMMAND dvaTP_Main_01, "'@PPN-Wait'";
		WAIT 600 SEND_COMMAND dvaTP_Main_01, "'PPOF-Wait'";
		
		SEND_COMMAND dvaTP_Switcher_03, "'PAGE-Main'";
		fnMonitor(ROOM_A,'OFF');
		fnProjector(ROOM_B,'OFF');
		fnProjector(ROOM_C,'OFF');
		fnProjector(ROOM_B2,'ON');
		
		blnSysPow[ROOM_A] = TRUE;
		blnSysPow[ROOM_B] = TRUE;
		blnSysPow[ROOM_C] = TRUE;
		
		nRoutingPair[ROOM_A][1] = 0;
		nRoutingPair[ROOM_B][1] = 0;
		
		FOR(x=1;x<=CONFIG_SWITCHER_NUMBER_OUTPUTS;x++)
		{
		    fnMTX(0,x,'V');
		    fnMTX(0,x,'A');
		}
		
	    }
	    ELSE
	    {
		SEND_COMMAND dvaTP_Main_01, "'@PPN-Wait'";
		WAIT 50 SEND_COMMAND dvaTP_Main_01, "'PPOF-Wait'";	    
	    }
	    
	    SEND_STRING dvDSP, "'RECALL 0 PRESET 1002',$0A";
	    fnMicMute(ROOM_A,blnMicMute[ROOM_C]);
	    fnMicMute(ROOM_B,blnMicMute[ROOM_C]);
	    fnAudioMute(ROOM_A,blnProgramMute[ROOM_C]);
	    fnAudioMute(ROOM_B,blnProgramMute[ROOM_C]);
	    fnAudioVolLvl(ROOM_A,nProgramVolLvl[ROOM_C]);
	    fnAudioVolLvl(ROOM_B,nProgramVolLvl[ROOM_C]);

	    SEND_COMMAND dvaTP_Switcher_03, "'^SHO-', ITOA(nVidOutputBtns[1]), ',0'";  // hide all outputs except long-throw projector
	    SEND_COMMAND dvaTP_Switcher_03, "'^SHO-', ITOA(nVidOutputBtns[2]), ',0'";
	    SEND_COMMAND dvaTP_Switcher_03, "'^SHO-', ITOA(nVidOutputBtns[3]), ',0'";
	    SEND_COMMAND dvaTP_Switcher_03, "'^SHO-', ITOA(nVidOutputBtns[4]), ',1'";
	    
	    SEND_COMMAND dvaTP_Switcher_03, "'^SHO-', ITOA(nVidRouteTxtBtns[1]), ',0'";  // hide all outputs except long-throw projector
	    SEND_COMMAND dvaTP_Switcher_03, "'^SHO-', ITOA(nVidRouteTxtBtns[2]), ',0'";
	    SEND_COMMAND dvaTP_Switcher_03, "'^SHO-', ITOA(nVidRouteTxtBtns[3]), ',0'";
	    SEND_COMMAND dvaTP_Switcher_03, "'^SHO-', ITOA(nVidRouteTxtBtns[4]), ',1'";


	    SEND_COMMAND dvaTP_Switcher_03, "'^SHO-', ITOA(nVidInputBtns[1]), ',1'";  // show/hide available inputs (particularly important for startup laptop selection page)
	    SEND_COMMAND dvaTP_Switcher_03, "'^SHO-', ITOA(nVidInputBtns[2]), ',1'";
	    SEND_COMMAND dvaTP_Switcher_03, "'^SHO-', ITOA(nVidInputBtns[3]), ',1'";
	    SEND_COMMAND dvaTP_Switcher_03, "'^SHO-', ITOA(nVidInputBtns[4]), ',1'";
	    SEND_COMMAND dvaTP_Switcher_03, "'^SHO-', ITOA(nVidInputBtns[5]), ',1'";
	    SEND_COMMAND dvaTP_Switcher_03, "'^SHO-', ITOA(nVidInputBtns[6]), ',1'";
	    SEND_COMMAND dvaTP_Switcher_03, "'^SHO-', ITOA(nVidInputBtns[7]), ',1'";
	    SEND_COMMAND dvaTP_Switcher_03, "'^SHO-', ITOA(nVidInputBtns[8]), ',1'";
	}                                                                
	ACTIVE(blnCombined[PARTITION_AB] && !blnCombined[PARTITION_BC])://	 A/B combined, C separate
	{                                           
	    IF(blnSysPow[ROOM_A] || blnSysPow[ROOM_B]) // sync any rooms that are on
	    {
		SEND_COMMAND dvaTP_Main_01[ROOM_A], "'@PPN-Wait'";
		WAIT 600 SEND_COMMAND dvaTP_Main_01[ROOM_A], "'PPOF-Wait'";
		SEND_COMMAND dvaTP_Main_01[ROOM_B], "'@PPN-Wait'";
		WAIT 600 SEND_COMMAND dvaTP_Main_01[ROOM_B], "'PPOF-Wait'";

		SEND_COMMAND dvaTP_Switcher_03[ROOM_A], "'PAGE-Main'";
		SEND_COMMAND dvaTP_Switcher_03[ROOM_B], "'PAGE-Main'";
		fnMonitor(ROOM_A,'ON');
		fnProjector(ROOM_B,'ON');
		fnProjector(ROOM_B2,'OFF');
		
		fnMTX(nSwitcherTrack[ROOM_A],ROOM_B,'V');  // sync A source over to B
		fnMTX(nSwitcherTrack[ROOM_A],ROOM_B,'A');
		
		fnMTX(0,ao_4,'A');  // break route to secondary
		fnMTX(0,ao_3,'A');  // break route to C
		
		nRoutingPair[ROOM_B][1] = 0;
	    
    		blnSysPow[ROOM_A] = TRUE;
		blnSysPow[ROOM_B] = TRUE;
	    }
	    ELSE
	    {
		SEND_COMMAND dvaTP_Main_01[ROOM_A], "'@PPN-Wait'";
		WAIT 50 SEND_COMMAND dvaTP_Main_01[ROOM_A], "'PPOF-Wait'";
		SEND_COMMAND dvaTP_Main_01[ROOM_B], "'@PPN-Wait'";
		WAIT 50 SEND_COMMAND dvaTP_Main_01[ROOM_B], "'PPOF-Wait'";	    
	    }

	    SEND_STRING dvDSP, "'RECALL 0 PRESET 1003',$0A";
	    fnMicMute(ROOM_B,blnMicMute[ROOM_A]);
	    fnAudioMute(ROOM_B,blnProgramMute[ROOM_A]);
	    fnAudioVolLvl(ROOM_B,nProgramVolLvl[ROOM_A]);

	    SEND_COMMAND dvaTP_Switcher_03[ROOM_A], "'^SHO-', ITOA(nVidOutputBtns[1]), ',1'";  // show/hide valid outputs
	    SEND_COMMAND dvaTP_Switcher_03[ROOM_A], "'^SHO-', ITOA(nVidOutputBtns[2]), ',1'";
	    SEND_COMMAND dvaTP_Switcher_03[ROOM_A], "'^SHO-', ITOA(nVidOutputBtns[3]), ',0'";
	    SEND_COMMAND dvaTP_Switcher_03[ROOM_A], "'^SHO-', ITOA(nVidOutputBtns[4]), ',0'";
	    SEND_COMMAND dvaTP_Switcher_03[ROOM_A], "'^SHO-', ITOA(nVidRouteTxtBtns[1]), ',1'";  // show/hide valid outputs
	    SEND_COMMAND dvaTP_Switcher_03[ROOM_A], "'^SHO-', ITOA(nVidRouteTxtBtns[2]), ',1'";
	    SEND_COMMAND dvaTP_Switcher_03[ROOM_A], "'^SHO-', ITOA(nVidRouteTxtBtns[3]), ',0'";
	    SEND_COMMAND dvaTP_Switcher_03[ROOM_A], "'^SHO-', ITOA(nVidRouteTxtBtns[4]), ',0'";
	    
	    SEND_COMMAND dvaTP_Switcher_03[ROOM_B], "'^SHO-', ITOA(nVidOutputBtns[1]), ',1'";  // show/hide valid outputs
	    SEND_COMMAND dvaTP_Switcher_03[ROOM_B], "'^SHO-', ITOA(nVidOutputBtns[2]), ',1'";
	    SEND_COMMAND dvaTP_Switcher_03[ROOM_B], "'^SHO-', ITOA(nVidOutputBtns[3]), ',0'";
	    SEND_COMMAND dvaTP_Switcher_03[ROOM_B], "'^SHO-', ITOA(nVidOutputBtns[4]), ',0'";
	    SEND_COMMAND dvaTP_Switcher_03[ROOM_B], "'^SHO-', ITOA(nVidRouteTxtBtns[1]), ',1'";  // show/hide valid outputs
	    SEND_COMMAND dvaTP_Switcher_03[ROOM_B], "'^SHO-', ITOA(nVidRouteTxtBtns[2]), ',1'";
	    SEND_COMMAND dvaTP_Switcher_03[ROOM_B], "'^SHO-', ITOA(nVidRouteTxtBtns[3]), ',0'";
	    SEND_COMMAND dvaTP_Switcher_03[ROOM_B], "'^SHO-', ITOA(nVidRouteTxtBtns[4]), ',0'";

	    SEND_COMMAND dvaTP_Switcher_03[ROOM_C], "'^SHO-', ITOA(nVidOutputBtns[1]), ',0'";  // show/hide valid outputs
	    SEND_COMMAND dvaTP_Switcher_03[ROOM_C], "'^SHO-', ITOA(nVidOutputBtns[2]), ',0'";
	    SEND_COMMAND dvaTP_Switcher_03[ROOM_C], "'^SHO-', ITOA(nVidOutputBtns[3]), ',1'";
	    SEND_COMMAND dvaTP_Switcher_03[ROOM_C], "'^SHO-', ITOA(nVidOutputBtns[4]), ',0'";
	    SEND_COMMAND dvaTP_Switcher_03[ROOM_C], "'^SHO-', ITOA(nVidRouteTxtBtns[1]), ',0'";  // show/hide valid outputs
	    SEND_COMMAND dvaTP_Switcher_03[ROOM_C], "'^SHO-', ITOA(nVidRouteTxtBtns[2]), ',0'";
	    SEND_COMMAND dvaTP_Switcher_03[ROOM_C], "'^SHO-', ITOA(nVidRouteTxtBtns[3]), ',1'";
	    SEND_COMMAND dvaTP_Switcher_03[ROOM_C], "'^SHO-', ITOA(nVidRouteTxtBtns[4]), ',0'";
	    
	    SEND_COMMAND dvaTP_Switcher_03[ROOM_A], "'^SHO-', ITOA(nVidInputBtns[1]), ',0'";  // show/hide available inputs (particularly important for startup laptop selection page)
	    SEND_COMMAND dvaTP_Switcher_03[ROOM_A], "'^SHO-', ITOA(nVidInputBtns[2]), ',0'";
	    SEND_COMMAND dvaTP_Switcher_03[ROOM_A], "'^SHO-', ITOA(nVidInputBtns[3]), ',1'";
	    SEND_COMMAND dvaTP_Switcher_03[ROOM_A], "'^SHO-', ITOA(nVidInputBtns[4]), ',1'";
	    SEND_COMMAND dvaTP_Switcher_03[ROOM_A], "'^SHO-', ITOA(nVidInputBtns[5]), ',1'";
	    SEND_COMMAND dvaTP_Switcher_03[ROOM_A], "'^SHO-', ITOA(nVidInputBtns[6]), ',1'";
	    SEND_COMMAND dvaTP_Switcher_03[ROOM_A], "'^SHO-', ITOA(nVidInputBtns[7]), ',1'";
	    SEND_COMMAND dvaTP_Switcher_03[ROOM_A], "'^SHO-', ITOA(nVidInputBtns[8]), ',0'";

	    SEND_COMMAND dvaTP_Switcher_03[ROOM_B], "'^SHO-', ITOA(nVidInputBtns[1]), ',0'";  // show/hide available inputs (particularly important for startup laptop selection page)
	    SEND_COMMAND dvaTP_Switcher_03[ROOM_B], "'^SHO-', ITOA(nVidInputBtns[2]), ',0'";
	    SEND_COMMAND dvaTP_Switcher_03[ROOM_B], "'^SHO-', ITOA(nVidInputBtns[3]), ',1'";
	    SEND_COMMAND dvaTP_Switcher_03[ROOM_B], "'^SHO-', ITOA(nVidInputBtns[4]), ',1'";
	    SEND_COMMAND dvaTP_Switcher_03[ROOM_B], "'^SHO-', ITOA(nVidInputBtns[5]), ',1'";
	    SEND_COMMAND dvaTP_Switcher_03[ROOM_B], "'^SHO-', ITOA(nVidInputBtns[6]), ',1'";
	    SEND_COMMAND dvaTP_Switcher_03[ROOM_B], "'^SHO-', ITOA(nVidInputBtns[7]), ',1'";
	    SEND_COMMAND dvaTP_Switcher_03[ROOM_B], "'^SHO-', ITOA(nVidInputBtns[8]), ',0'";
	    
	    SEND_COMMAND dvaTP_Switcher_03[ROOM_C], "'^SHO-', ITOA(nVidInputBtns[1]), ',1'";  // show/hide available inputs (particularly important for startup laptop selection page)
	    SEND_COMMAND dvaTP_Switcher_03[ROOM_C], "'^SHO-', ITOA(nVidInputBtns[2]), ',1'";
	    SEND_COMMAND dvaTP_Switcher_03[ROOM_C], "'^SHO-', ITOA(nVidInputBtns[3]), ',0'";
	    SEND_COMMAND dvaTP_Switcher_03[ROOM_C], "'^SHO-', ITOA(nVidInputBtns[4]), ',0'";
	    SEND_COMMAND dvaTP_Switcher_03[ROOM_C], "'^SHO-', ITOA(nVidInputBtns[5]), ',0'";
	    SEND_COMMAND dvaTP_Switcher_03[ROOM_C], "'^SHO-', ITOA(nVidInputBtns[6]), ',0'";
	    SEND_COMMAND dvaTP_Switcher_03[ROOM_C], "'^SHO-', ITOA(nVidInputBtns[7]), ',0'";
	    SEND_COMMAND dvaTP_Switcher_03[ROOM_C], "'^SHO-', ITOA(nVidInputBtns[8]), ',1'";

	}                                           
	ACTIVE(!blnCombined[PARTITION_AB] && blnCombined[PARTITION_BC])://	 B/C combined, A separate
	{                                           
	    IF(blnSysPow[ROOM_B] || blnSysPow[ROOM_C]) // sync any rooms that are on
	    {
		SEND_COMMAND dvaTP_Main_01[ROOM_C], "'@PPN-Wait'";
		WAIT 600 SEND_COMMAND dvaTP_Main_01[ROOM_C], "'PPOF-Wait'";
		SEND_COMMAND dvaTP_Main_01[ROOM_B], "'@PPN-Wait'";
		WAIT 600 SEND_COMMAND dvaTP_Main_01[ROOM_B], "'PPOF-Wait'";


		SEND_COMMAND dvaTP_Switcher_03[ROOM_C], "'PAGE-Main'";
		SEND_COMMAND dvaTP_Switcher_03[ROOM_B], "'PAGE-Main'";
		fnProjector(ROOM_C,'OFF');
		fnProjector(ROOM_B,'OFF');
		fnProjector(ROOM_B2,'ON');
		
		fnMTX(nSwitcherTrack[ROOM_C],vo_4,'V');  // sync C source over to B2
		fnMTX(nSwitcherTrack[ROOM_C],ao_4,'A');
		fnMTX(0,ao_1,'A');  // break audio to A
		nRoutingPair[ROOM_B][1] = 0;
		
		blnSysPow[ROOM_B] = TRUE;
		blnSysPow[ROOM_C] = TRUE;
		
	    }
	    ELSE
	    {
		SEND_COMMAND dvaTP_Main_01[ROOM_C], "'@PPN-Wait'";
		WAIT 50 SEND_COMMAND dvaTP_Main_01[ROOM_C], "'PPOF-Wait'";
		SEND_COMMAND dvaTP_Main_01[ROOM_B], "'@PPN-Wait'";
		WAIT 50 SEND_COMMAND dvaTP_Main_01[ROOM_B], "'PPOF-Wait'";	    
	    }

	    SEND_STRING dvDSP, "'RECALL 0 PRESET 1004',$0A";
	    fnMicMute(ROOM_C,blnMicMute[ROOM_B]);
	    fnAudioMute(ROOM_C,blnProgramMute[ROOM_B]);
	    fnAudioVolLvl(ROOM_C,nProgramVolLvl[ROOM_B]);
	    
	    SEND_COMMAND dvaTP_Switcher_03[ROOM_A], "'^SHO-', ITOA(nVidOutputBtns[1]), ',1'";  // show/hide valid outputs
	    SEND_COMMAND dvaTP_Switcher_03[ROOM_A], "'^SHO-', ITOA(nVidOutputBtns[2]), ',0'";
	    SEND_COMMAND dvaTP_Switcher_03[ROOM_A], "'^SHO-', ITOA(nVidOutputBtns[3]), ',0'";
	    SEND_COMMAND dvaTP_Switcher_03[ROOM_A], "'^SHO-', ITOA(nVidOutputBtns[4]), ',0'";
	    SEND_COMMAND dvaTP_Switcher_03[ROOM_A], "'^SHO-', ITOA(nVidRouteTxtBtns[1]), ',1'";  // show/hide valid outputs
	    SEND_COMMAND dvaTP_Switcher_03[ROOM_A], "'^SHO-', ITOA(nVidRouteTxtBtns[2]), ',0'";
	    SEND_COMMAND dvaTP_Switcher_03[ROOM_A], "'^SHO-', ITOA(nVidRouteTxtBtns[3]), ',0'";
	    SEND_COMMAND dvaTP_Switcher_03[ROOM_A], "'^SHO-', ITOA(nVidRouteTxtBtns[4]), ',0'";
	    
	    SEND_COMMAND dvaTP_Switcher_03[ROOM_B], "'^SHO-', ITOA(nVidOutputBtns[1]), ',0'";  // show/hide valid outputs
	    SEND_COMMAND dvaTP_Switcher_03[ROOM_B], "'^SHO-', ITOA(nVidOutputBtns[2]), ',0'";
	    SEND_COMMAND dvaTP_Switcher_03[ROOM_B], "'^SHO-', ITOA(nVidOutputBtns[3]), ',0'";
	    SEND_COMMAND dvaTP_Switcher_03[ROOM_B], "'^SHO-', ITOA(nVidOutputBtns[4]), ',1'";
	    SEND_COMMAND dvaTP_Switcher_03[ROOM_B], "'^SHO-', ITOA(nVidRouteTxtBtns[1]), ',0'";  // show/hide valid outputs
	    SEND_COMMAND dvaTP_Switcher_03[ROOM_B], "'^SHO-', ITOA(nVidRouteTxtBtns[2]), ',0'";
	    SEND_COMMAND dvaTP_Switcher_03[ROOM_B], "'^SHO-', ITOA(nVidRouteTxtBtns[3]), ',0'";
	    SEND_COMMAND dvaTP_Switcher_03[ROOM_B], "'^SHO-', ITOA(nVidRouteTxtBtns[4]), ',1'";

	    SEND_COMMAND dvaTP_Switcher_03[ROOM_C], "'^SHO-', ITOA(nVidOutputBtns[1]), ',0'";  // show/hide valid outputs
	    SEND_COMMAND dvaTP_Switcher_03[ROOM_C], "'^SHO-', ITOA(nVidOutputBtns[2]), ',0'";
	    SEND_COMMAND dvaTP_Switcher_03[ROOM_C], "'^SHO-', ITOA(nVidOutputBtns[3]), ',0'";
	    SEND_COMMAND dvaTP_Switcher_03[ROOM_C], "'^SHO-', ITOA(nVidOutputBtns[4]), ',1'";
	    SEND_COMMAND dvaTP_Switcher_03[ROOM_C], "'^SHO-', ITOA(nVidRouteTxtBtns[1]), ',0'";  // show/hide valid outputs
	    SEND_COMMAND dvaTP_Switcher_03[ROOM_C], "'^SHO-', ITOA(nVidRouteTxtBtns[2]), ',0'";
	    SEND_COMMAND dvaTP_Switcher_03[ROOM_C], "'^SHO-', ITOA(nVidRouteTxtBtns[3]), ',0'";
	    SEND_COMMAND dvaTP_Switcher_03[ROOM_C], "'^SHO-', ITOA(nVidRouteTxtBtns[4]), ',1'";

	    SEND_COMMAND dvaTP_Switcher_03[ROOM_A], "'^SHO-', ITOA(nVidInputBtns[1]), ',0'";  // show/hide available inputs (particularly important for startup laptop selection page)
	    SEND_COMMAND dvaTP_Switcher_03[ROOM_A], "'^SHO-', ITOA(nVidInputBtns[2]), ',0'";
	    SEND_COMMAND dvaTP_Switcher_03[ROOM_A], "'^SHO-', ITOA(nVidInputBtns[3]), ',0'";
	    SEND_COMMAND dvaTP_Switcher_03[ROOM_A], "'^SHO-', ITOA(nVidInputBtns[4]), ',0'";
	    SEND_COMMAND dvaTP_Switcher_03[ROOM_A], "'^SHO-', ITOA(nVidInputBtns[5]), ',1'";
	    SEND_COMMAND dvaTP_Switcher_03[ROOM_A], "'^SHO-', ITOA(nVidInputBtns[6]), ',1'";
	    SEND_COMMAND dvaTP_Switcher_03[ROOM_A], "'^SHO-', ITOA(nVidInputBtns[7]), ',0'";
	    SEND_COMMAND dvaTP_Switcher_03[ROOM_A], "'^SHO-', ITOA(nVidInputBtns[8]), ',0'";

	    SEND_COMMAND dvaTP_Switcher_03[ROOM_B], "'^SHO-', ITOA(nVidInputBtns[1]), ',1'";  // show/hide available inputs (particularly important for startup laptop selection page)
	    SEND_COMMAND dvaTP_Switcher_03[ROOM_B], "'^SHO-', ITOA(nVidInputBtns[2]), ',1'";
	    SEND_COMMAND dvaTP_Switcher_03[ROOM_B], "'^SHO-', ITOA(nVidInputBtns[3]), ',1'";
	    SEND_COMMAND dvaTP_Switcher_03[ROOM_B], "'^SHO-', ITOA(nVidInputBtns[4]), ',1'";
	    SEND_COMMAND dvaTP_Switcher_03[ROOM_B], "'^SHO-', ITOA(nVidInputBtns[5]), ',0'";
	    SEND_COMMAND dvaTP_Switcher_03[ROOM_B], "'^SHO-', ITOA(nVidInputBtns[6]), ',0'";
	    SEND_COMMAND dvaTP_Switcher_03[ROOM_B], "'^SHO-', ITOA(nVidInputBtns[7]), ',1'";
	    SEND_COMMAND dvaTP_Switcher_03[ROOM_B], "'^SHO-', ITOA(nVidInputBtns[8]), ',1'";
	    
	    SEND_COMMAND dvaTP_Switcher_03[ROOM_C], "'^SHO-', ITOA(nVidInputBtns[1]), ',1'";  // show/hide available inputs (particularly important for startup laptop selection page)
	    SEND_COMMAND dvaTP_Switcher_03[ROOM_C], "'^SHO-', ITOA(nVidInputBtns[2]), ',1'";
	    SEND_COMMAND dvaTP_Switcher_03[ROOM_C], "'^SHO-', ITOA(nVidInputBtns[3]), ',1'";
	    SEND_COMMAND dvaTP_Switcher_03[ROOM_C], "'^SHO-', ITOA(nVidInputBtns[4]), ',1'";
	    SEND_COMMAND dvaTP_Switcher_03[ROOM_C], "'^SHO-', ITOA(nVidInputBtns[5]), ',0'";
	    SEND_COMMAND dvaTP_Switcher_03[ROOM_C], "'^SHO-', ITOA(nVidInputBtns[6]), ',0'";
	    SEND_COMMAND dvaTP_Switcher_03[ROOM_C], "'^SHO-', ITOA(nVidInputBtns[7]), ',1'";
	    SEND_COMMAND dvaTP_Switcher_03[ROOM_C], "'^SHO-', ITOA(nVidInputBtns[8]), ',1'";

	}                                        
	ACTIVE(1):  // all rooms divided
	{
	    fnProjector(ROOM_B2,'OFF')  // long-throw proj off in this mode
	    
	    IF(blnSysPow[ROOM_A] || blnSysPow[ROOM_B] || blnSysPow[ROOM_C])
	    {
		IF(blnSysPow[ROOM_A]) 
		{
		    fnMonitor(1,'ON');
		    SEND_COMMAND dvaTP_Main_01[ROOM_A], "'@PPN-Wait'";
		    WAIT 600 SEND_COMMAND dvaTP_Main_01[ROOM_A], "'PPOF-Wait'";
		}
		IF(blnSysPow[ROOM_B]) 
		{
		    fnProjector(ROOM_B,'ON');
		    SEND_COMMAND dvaTP_Main_01[ROOM_B], "'@PPN-Wait'";
		    WAIT 600 SEND_COMMAND dvaTP_Main_01[ROOM_B], "'PPOF-Wait'";
		    
		}
		IF(blnSysPow[ROOM_C]) 
		{
		    SEND_COMMAND dvaTP_Main_01[ROOM_C], "'@PPN-Wait'";
		    WAIT 600 SEND_COMMAND dvaTP_Main_01[ROOM_C], "'PPOF-Wait'";
		    fnProjector(ROOM_C,'ON');
		}
		SEND_COMMAND dvaTP_Main_01, "'^SHO-3000,1'";
		WAIT 600 SEND_COMMAND dvaTP_Main_01, "'^SHO-3000,0'";
		
	    }
	    ELSE
	    {
		    SEND_COMMAND dvaTP_Main_01, "'@PPN-Wait'";
		    WAIT 50 SEND_COMMAND dvaTP_Main_01, "'PPOF-Wait'";
		    SEND_COMMAND dvaTP_Main_01, "'^SHO-3000,1'";
		    WAIT 50 SEND_COMMAND dvaTP_Main_01, "'^SHO-3000,0'";	    
	    }
	    
	    SEND_STRING dvDSP, "'RECALL 0 PRESET 1001',$0A";
	    
	    SEND_COMMAND dvaTP_Switcher_03[ROOM_A], "'^SHO-', ITOA(nVidOutputBtns[1]), ',1'";  // show/hide valid outputs
	    SEND_COMMAND dvaTP_Switcher_03[ROOM_A], "'^SHO-', ITOA(nVidOutputBtns[2]), ',0'";
	    SEND_COMMAND dvaTP_Switcher_03[ROOM_A], "'^SHO-', ITOA(nVidOutputBtns[3]), ',0'";
	    SEND_COMMAND dvaTP_Switcher_03[ROOM_A], "'^SHO-', ITOA(nVidOutputBtns[4]), ',0'";
	    SEND_COMMAND dvaTP_Switcher_03[ROOM_A], "'^SHO-', ITOA(nVidRouteTxtBtns[1]), ',1'";  // show/hide valid outputs
	    SEND_COMMAND dvaTP_Switcher_03[ROOM_A], "'^SHO-', ITOA(nVidRouteTxtBtns[2]), ',0'";
	    SEND_COMMAND dvaTP_Switcher_03[ROOM_A], "'^SHO-', ITOA(nVidRouteTxtBtns[3]), ',0'";
	    SEND_COMMAND dvaTP_Switcher_03[ROOM_A], "'^SHO-', ITOA(nVidRouteTxtBtns[4]), ',0'";
	    
	    SEND_COMMAND dvaTP_Switcher_03[ROOM_B], "'^SHO-', ITOA(nVidOutputBtns[1]), ',0'";  // show/hide valid outputs
	    SEND_COMMAND dvaTP_Switcher_03[ROOM_B], "'^SHO-', ITOA(nVidOutputBtns[2]), ',1'";
	    SEND_COMMAND dvaTP_Switcher_03[ROOM_B], "'^SHO-', ITOA(nVidOutputBtns[3]), ',0'";
	    SEND_COMMAND dvaTP_Switcher_03[ROOM_B], "'^SHO-', ITOA(nVidOutputBtns[4]), ',0'";
	    SEND_COMMAND dvaTP_Switcher_03[ROOM_B], "'^SHO-', ITOA(nVidRouteTxtBtns[1]), ',0'";  // show/hide valid outputs
	    SEND_COMMAND dvaTP_Switcher_03[ROOM_B], "'^SHO-', ITOA(nVidRouteTxtBtns[2]), ',1'";
	    SEND_COMMAND dvaTP_Switcher_03[ROOM_B], "'^SHO-', ITOA(nVidRouteTxtBtns[3]), ',0'";
	    SEND_COMMAND dvaTP_Switcher_03[ROOM_B], "'^SHO-', ITOA(nVidRouteTxtBtns[4]), ',0'";

	    SEND_COMMAND dvaTP_Switcher_03[ROOM_C], "'^SHO-', ITOA(nVidOutputBtns[1]), ',0'";  // show/hide valid outputs
	    SEND_COMMAND dvaTP_Switcher_03[ROOM_C], "'^SHO-', ITOA(nVidOutputBtns[2]), ',0'";
	    SEND_COMMAND dvaTP_Switcher_03[ROOM_C], "'^SHO-', ITOA(nVidOutputBtns[3]), ',1'";
	    SEND_COMMAND dvaTP_Switcher_03[ROOM_C], "'^SHO-', ITOA(nVidOutputBtns[4]), ',0'";
	    SEND_COMMAND dvaTP_Switcher_03[ROOM_C], "'^SHO-', ITOA(nVidRouteTxtBtns[1]), ',0'";  // show/hide valid outputs
	    SEND_COMMAND dvaTP_Switcher_03[ROOM_C], "'^SHO-', ITOA(nVidRouteTxtBtns[2]), ',0'";
	    SEND_COMMAND dvaTP_Switcher_03[ROOM_C], "'^SHO-', ITOA(nVidRouteTxtBtns[3]), ',1'";
	    SEND_COMMAND dvaTP_Switcher_03[ROOM_C], "'^SHO-', ITOA(nVidRouteTxtBtns[4]), ',0'";

	    SEND_COMMAND dvaTP_Switcher_03[ROOM_A], "'^SHO-', ITOA(nVidInputBtns[1]), ',0'";  // show/hide available inputs (particularly important for startup laptop selection page)
	    SEND_COMMAND dvaTP_Switcher_03[ROOM_A], "'^SHO-', ITOA(nVidInputBtns[2]), ',0'";
	    SEND_COMMAND dvaTP_Switcher_03[ROOM_A], "'^SHO-', ITOA(nVidInputBtns[3]), ',0'";
	    SEND_COMMAND dvaTP_Switcher_03[ROOM_A], "'^SHO-', ITOA(nVidInputBtns[4]), ',0'";
	    SEND_COMMAND dvaTP_Switcher_03[ROOM_A], "'^SHO-', ITOA(nVidInputBtns[5]), ',1'";
	    SEND_COMMAND dvaTP_Switcher_03[ROOM_A], "'^SHO-', ITOA(nVidInputBtns[6]), ',1'";
	    SEND_COMMAND dvaTP_Switcher_03[ROOM_A], "'^SHO-', ITOA(nVidInputBtns[7]), ',0'";
	    SEND_COMMAND dvaTP_Switcher_03[ROOM_A], "'^SHO-', ITOA(nVidInputBtns[8]), ',0'";

	    SEND_COMMAND dvaTP_Switcher_03[ROOM_B], "'^SHO-', ITOA(nVidInputBtns[1]), ',0'";  // show/hide available inputs (particularly important for startup laptop selection page)
	    SEND_COMMAND dvaTP_Switcher_03[ROOM_B], "'^SHO-', ITOA(nVidInputBtns[2]), ',0'";
	    SEND_COMMAND dvaTP_Switcher_03[ROOM_B], "'^SHO-', ITOA(nVidInputBtns[3]), ',1'";
	    SEND_COMMAND dvaTP_Switcher_03[ROOM_B], "'^SHO-', ITOA(nVidInputBtns[4]), ',1'";
	    SEND_COMMAND dvaTP_Switcher_03[ROOM_B], "'^SHO-', ITOA(nVidInputBtns[5]), ',0'";
	    SEND_COMMAND dvaTP_Switcher_03[ROOM_B], "'^SHO-', ITOA(nVidInputBtns[6]), ',0'";
	    SEND_COMMAND dvaTP_Switcher_03[ROOM_B], "'^SHO-', ITOA(nVidInputBtns[7]), ',1'";
	    SEND_COMMAND dvaTP_Switcher_03[ROOM_B], "'^SHO-', ITOA(nVidInputBtns[8]), ',0'";
	    
	    SEND_COMMAND dvaTP_Switcher_03[ROOM_C], "'^SHO-', ITOA(nVidInputBtns[1]), ',1'";  // show/hide available inputs (particularly important for startup laptop selection page)
	    SEND_COMMAND dvaTP_Switcher_03[ROOM_C], "'^SHO-', ITOA(nVidInputBtns[2]), ',1'";
	    SEND_COMMAND dvaTP_Switcher_03[ROOM_C], "'^SHO-', ITOA(nVidInputBtns[3]), ',0'";
	    SEND_COMMAND dvaTP_Switcher_03[ROOM_C], "'^SHO-', ITOA(nVidInputBtns[4]), ',0'";
	    SEND_COMMAND dvaTP_Switcher_03[ROOM_C], "'^SHO-', ITOA(nVidInputBtns[5]), ',0'";
	    SEND_COMMAND dvaTP_Switcher_03[ROOM_C], "'^SHO-', ITOA(nVidInputBtns[6]), ',0'";
	    SEND_COMMAND dvaTP_Switcher_03[ROOM_C], "'^SHO-', ITOA(nVidInputBtns[7]), ',0'";
	    SEND_COMMAND dvaTP_Switcher_03[ROOM_C], "'^SHO-', ITOA(nVidInputBtns[8]), ',1'";

	}
	
    }

}




DEFINE_FUNCTION fnSysPow(INTEGER nWhichRoom, INTEGER blnPowerAction)
{
    STACK_VAR INTEGER x

    IF(blnPowerAction)  // on
    {
	// show/hide display power icons on user panel setup page
	// Using full DPS addresses since some of these devices aren't defined on panels in rooms they're not associated with
	// panel A
	SEND_COMMAND 10001:11:0, "'^SHO-255,1'";
	SEND_COMMAND 10001:18:0, "'^SHO-255,0'";
	SEND_COMMAND 10001:25:0, "'^SHO-255,0'";
	
	// panel B
	SEND_COMMAND 10002:11:0, "'^SHO-255,0'";
	SEND_COMMAND 10002:18:0, "'^SHO-255,1'";
	SEND_COMMAND 10002:25:0, "'^SHO-255,0'";

	// panel C
	SEND_COMMAND 10003:11:0, "'^SHO-255,0'";
	SEND_COMMAND 10003:18:0, "'^SHO-255,0'";
	SEND_COMMAND 10003:25:0, "'^SHO-255,1'";
	
	ON[dvRelay,1] // pwr sequencer ON

	WAIT 100 SEND_STRING dvSwitcher, "'1.'";  //recall global preset 1
	
	SELECT
	{
	    ACTIVE(!blnCombined[PARTITION_AB] && !blnCombined[PARTITION_BC]): // all 3 rooms separate
	    {
		SEND_COMMAND dvaTP_MAIN_01[nWhichRoom], "'@PPN-Wait'";
		
		SWITCH(nWhichRoom)
		{
		    CASE ROOM_A: 
		    {
			fnMonitor(1,'ON');
			WAIT 200 
			{
			    blnSysPow[ROOM_A] = TRUE;
			    SEND_COMMAND dvaTP_MAIN_01[ROOM_A], "'PPOF-Wait'";
			    SEND_COMMAND dvaTP_MAIN_01[ROOM_A], "'PAGE-Main'";
			}
		    }
		    CASE ROOM_B: 
		    {
			fnProjector(ROOM_B,'ON');
			WAIT 600 
			{
			    blnSysPow[ROOM_B] = TRUE;
			    SEND_COMMAND dvaTP_MAIN_01[ROOM_B], "'PPOF-Wait'";
			    SEND_COMMAND dvaTP_MAIN_01[ROOM_B], "'PAGE-Main'";
			}
		    }
		    CASE ROOM_C: 
		    {
			fnProjector(ROOM_C,'ON');
			WAIT 600 
			{
			    blnSysPow[ROOM_C] = TRUE;
			    SEND_COMMAND dvaTP_MAIN_01[ROOM_C], "'PPOF-Wait'";
			    SEND_COMMAND dvaTP_MAIN_01[ROOM_C], "'PAGE-Main'";
			}
		    }
		}
		
		fnAudioMute(nWhichRoom,FALSE);  
		fnAudioVolLvl(nWhichRoom,DEFAULT_VOL_LVL);
		
		fnMicMute(nWhichRoom,FALSE);  
	    }
	    ACTIVE(blnCombined[PARTITION_AB] && blnCombined[PARTITION_BC]): // all 3 rooms combined
	    {
		SEND_COMMAND dvaTP_MAIN_01, "'@PPN-Wait'";
		
		fnMonitor(ROOM_A,'OFF');
		fnProjector(ROOM_B,'OFF');
		fnProjector(ROOM_C,'OFF');
		fnProjector(ROOM_B2,'ON');  // use 2nd projector in B to shoot on C wall
		
		fnAudioMute(ROOM_A,FALSE);  
		fnAudioVolLvl(ROOM_A,DEFAULT_VOL_LVL);
		
		fnMicMute(ROOM_A,FALSE);  
		fnMicMute(ROOM_B,FALSE);  
		fnMicMute(ROOM_C,FALSE);  
		
		
		WAIT 600
		{
		    blnSysPow[ROOM_A] = TRUE;
		    blnSysPow[ROOM_B] = TRUE;
		    blnSysPow[ROOM_C] = TRUE;
		    SEND_COMMAND dvaTP_MAIN_01, "'PPOF-Wait'";
		    SEND_COMMAND dvaTP_MAIN_01, "'PAGE-Main'";
		}            
	    }
	    ACTIVE(blnCombined[PARTITION_AB] && !blnCombined[PARTITION_BC]): // rooms A/B combined, C separate
	    {
		IF(nWhichRoom == ROOM_A || nWhichRoom == ROOM_B)
		{
		    SEND_COMMAND dvaTP_MAIN_01[ROOM_A], "'@PPN-Wait'";
		    SEND_COMMAND dvaTP_MAIN_01[ROOM_B], "'@PPN-Wait'";
		    
		    fnMonitor(ROOM_A,'ON');
		    fnProjector(ROOM_B,'ON');
		    fnProjector(ROOM_B2,'OFF'); // turn off second proj in B
		    
		    fnAudioMute(ROOM_A,FALSE);  
		    fnAudioMute(ROOM_B,FALSE);  
		    fnAudioVolLvl(ROOM_A,DEFAULT_VOL_LVL);
		    fnAudioVolLvl(ROOM_B,DEFAULT_VOL_LVL);
		    
		    fnMicMute(ROOM_A,FALSE);  
		    fnMicMute(ROOM_B,FALSE);  
		    
		    WAIT 600
		    {
			blnSysPow[ROOM_A] = TRUE;
			blnSysPow[ROOM_B] = TRUE;
			SEND_COMMAND dvaTP_MAIN_01[ROOM_A], "'PPOF-Wait'";
			SEND_COMMAND dvaTP_MAIN_01[ROOM_B], "'PPOF-Wait'";
			SEND_COMMAND dvaTP_MAIN_01[ROOM_A], "'PAGE-Main'";
			SEND_COMMAND dvaTP_MAIN_01[ROOM_B], "'PAGE-Main'";

		    }            
		    
		}
		ELSE  // room C
		{
		    SEND_COMMAND dvaTP_MAIN_01[ROOM_C], "'@PPN-Wait'";
		    
		    fnProjector(ROOM_C,'ON');
		    fnProjector(ROOM_B2,'OFF'); // turn off second proj in B
		    
		    fnAudioMute(ROOM_C,FALSE);  
		    fnAudioVolLvl(ROOM_C,DEFAULT_VOL_LVL);
		    fnMicMute(ROOM_C,FALSE);  
		    
		    WAIT 600 
		    {
			blnSysPow[ROOM_C] = TRUE;
			SEND_COMMAND dvaTP_MAIN_01[ROOM_C], "'PPOF-Wait'";
			SEND_COMMAND dvaTP_MAIN_01[ROOM_C], "'PAGE-Main'";
		    }
		}
	    }
	    ACTIVE(!blnCombined[PARTITION_AB] && blnCombined[PARTITION_BC]): // rooms B/C combined, A separate
	    {
		IF(nWhichRoom == ROOM_C || nWhichRoom == ROOM_B)
		{
		    SEND_COMMAND dvaTP_MAIN_01[ROOM_C], "'@PPN-Wait'";
		    SEND_COMMAND dvaTP_MAIN_01[ROOM_B], "'@PPN-Wait'";
		    
		    fnProjector(ROOM_B,'OFF');
		    fnProjector(ROOM_C,'OFF');
		    fnProjector(ROOM_B2,'ON'); // turn off second proj in B
		    
		    fnAudioMute(ROOM_C,FALSE);  
		    fnAudioMute(ROOM_B,FALSE);  
		    fnAudioVolLvl(ROOM_C,DEFAULT_VOL_LVL);
		    fnAudioVolLvl(ROOM_B,DEFAULT_VOL_LVL);
		    
		    fnMicMute(ROOM_C,FALSE);  
		    fnMicMute(ROOM_B,FALSE);  
		    
		    WAIT 600
		    {
			blnSysPow[ROOM_C] = TRUE;
			blnSysPow[ROOM_B] = TRUE;
			SEND_COMMAND dvaTP_MAIN_01[ROOM_C], "'PPOF-Wait'";
			SEND_COMMAND dvaTP_MAIN_01[ROOM_B], "'PPOF-Wait'";
			SEND_COMMAND dvaTP_MAIN_01[ROOM_C], "'PAGE-Main'";
			SEND_COMMAND dvaTP_MAIN_01[ROOM_B], "'PAGE-Main'";
			
		    }            
		    
		}
		ELSE  // room A
		{
		    SEND_COMMAND dvaTP_MAIN_01[ROOM_A], "'@PPN-Wait'";
		    
		    fnMonitor(ROOM_A,'ON');
		    
		    fnAudioMute(ROOM_A,FALSE);  
		    fnAudioVolLvl(ROOM_A,DEFAULT_VOL_LVL);
		    fnMicMute(ROOM_A,FALSE);  
		    
		    WAIT 200 
		    {
			blnSysPow[ROOM_A] = TRUE;
			SEND_COMMAND dvaTP_MAIN_01[ROOM_A], "'PPOF-Wait'";
			SEND_COMMAND dvaTP_MAIN_01[ROOM_A], "'PAGE-Main'";			
		    }
		}
	    }	    
	}
    }
    
    ELSE  // off
    {
	SELECT
	{
	    ACTIVE(!blnCombined[PARTITION_AB] && !blnCombined[PARTITION_BC]): // all 3 rooms separate
	    {
		SEND_COMMAND dvaTP_MAIN_01[nWhichRoom], "'@PPN-Wait'";
		
		SWITCH(nWhichRoom)  // have to break these out manually due to the wait time and possibility of multiple rooms using this function at one time
		{
		    CASE ROOM_A:
		    {
			fnMonitor(ROOM_A,'OFF');
			fnAudioMute(ROOM_A,TRUE);
			fnMicMute(ROOM_A,TRUE);
			fnMTX(0,ao_PGM[ROOM_A],'A');
			
			WAIT 200
			{
			    blnSysPow[ROOM_A] = FALSE;
			    
			    SEND_COMMAND dvaTP_MAIN_01[ROOM_A], "'@PPX'";
			    SEND_COMMAND dvaTP_MAIN_01[ROOM_A], "'PAGE-Welcome'";
			}            
		    }
		    CASE ROOM_B:
		    {
			fnProjector(ROOM_B2,'OFF');  // shouldn't be on anyway, but just in case
			fnProjector(ROOM_B,'OFF');

			fnAudioMute(ROOM_B,TRUE);
			fnMicMute(ROOM_B,TRUE);
			fnMTX(0,ao_PGM[ROOM_B],'A');
			
			WAIT 600
			{
			    blnSysPow[ROOM_B] = FALSE;
			    
			    SEND_COMMAND dvaTP_MAIN_01[ROOM_B], "'@PPX'";
			    SEND_COMMAND dvaTP_MAIN_01[ROOM_B], "'PAGE-Welcome'";
			}            
		    
		    }
		    CASE ROOM_C:
		    {
			fnProjector(ROOM_C,'OFF');
		    
			fnAudioMute(ROOM_C,TRUE);
			fnMicMute(ROOM_C,TRUE);
			fnMTX(0,ao_PGM[ROOM_C],'A');
			
			WAIT 600
			{
			    blnSysPow[ROOM_C] = FALSE;
			    
			    SEND_COMMAND dvaTP_MAIN_01[ROOM_C], "'@PPX'";
			    SEND_COMMAND dvaTP_MAIN_01[ROOM_C], "'PAGE-Welcome'";
			}            

		    }
		}
	    }

	    ACTIVE(blnCombined[PARTITION_AB] && blnCombined[PARTITION_BC]): // all 3 rooms combined
	    {
		SEND_COMMAND dvaTP_MAIN_01, "'@PPN-Wait'";
		
		fnMonitor(ROOM_A,'OFF');
		fnProjector(ROOM_B,'OFF');
		fnProjector(ROOM_C,'OFF');
		fnProjector(ROOM_B2,'OFF');
		
		fnAudioMute(ROOM_A,TRUE);  
		fnAudioMute(ROOM_B,TRUE);  
		fnAudioMute(ROOM_C,TRUE);  

		fnMicMute(ROOM_A,TRUE);  
		fnMicMute(ROOM_B,TRUE);  
		fnMicMute(ROOM_C,TRUE);  
		
		// clear routes
		FOR(x=1;x<=CONFIG_SWITCHER_NUMBER_OUTPUTS;x++)
		{
		    fnMTX(0,x,'V');  // clear video
		    fnMTX(0,ao_PGM[x],'A');  // clear audio
		}
		
		WAIT 600
		{
		    //PULSE[dvRelay,2];  // pwr seq OFF
		    blnSysPow[ROOM_A] = FALSE;
		    blnSysPow[ROOM_B] = FALSE;
		    blnSysPow[ROOM_C] = FALSE;
		    
		    SEND_COMMAND dvaTP_MAIN_01, "'@PPX'";
		    SEND_COMMAND dvaTP_MAIN_01, "'PAGE-Welcome'";


		    blnCombined[1] = FALSE;
		    blnCombined[2] = FALSE;
		    blnCombined_Temp[1] = FALSE;
		    blnCombined_Temp[2] = FALSE;
		    fnCombineDivide();
		}            
	    }
	    ACTIVE(blnCombined[PARTITION_AB] && !blnCombined[PARTITION_BC]): // rooms A/B combined, C separate
	    {
		IF(nWhichRoom == ROOM_A || nWhichRoom == ROOM_B)
		{
		    SEND_COMMAND dvaTP_MAIN_01[ROOM_A], "'@PPN-Wait'";
		    SEND_COMMAND dvaTP_MAIN_01[ROOM_B], "'@PPN-Wait'";

		    fnMonitor(ROOM_A,'OFF');
		    fnProjector(ROOM_B,'OFF');
		    fnProjector(ROOM_B2,'OFF');
		    
		    fnAudioMute(ROOM_A,TRUE);  
		    fnAudioMute(ROOM_B,TRUE);  
    
		    fnMicMute(ROOM_A,TRUE);  
		    fnMicMute(ROOM_B,TRUE);  
		    
		    // clear routes
		    fnMTX(0,1,'V');  // clear video
		    fnMTX(0,2,'V');  // clear video
		    fnMTX(0,4,'V');  // clear video
		    fnMTX(0,ao_PGM[ROOM_A],'A');  // clear audio
		    fnMTX(0,ao_PGM[ROOM_B],'A');  // clear audio
		    
		    WAIT 600
		    {
			blnSysPow[ROOM_A] = FALSE;
			blnSysPow[ROOM_B] = FALSE;
			
			SEND_COMMAND dvaTP_MAIN_01[ROOM_A], "'@PPX'";
			SEND_COMMAND dvaTP_MAIN_01[ROOM_A], "'PAGE-Welcome'";
			SEND_COMMAND dvaTP_MAIN_01[ROOM_B], "'@PPX'";
			SEND_COMMAND dvaTP_MAIN_01[ROOM_B], "'PAGE-Welcome'";
			

			blnCombined[1] = FALSE;
			blnCombined_Temp[1] = FALSE;
			fnCombineDivide();
		    }            
		    
		}
		ELSE  // room C
		{
		    SEND_COMMAND dvaTP_MAIN_01[ROOM_C], "'@PPN-Wait'";

		    fnProjector(ROOM_C,'OFF');
		    fnProjector(ROOM_B2,'OFF');
		    
		    fnAudioMute(ROOM_C,TRUE);  
		    fnMicMute(ROOM_C,TRUE);  
		    
		    // clear routes
		    fnMTX(0,3,'V');  // clear video
		    fnMTX(0,4,'V');  // clear video
		    fnMTX(0,ao_PGM[ROOM_C],'A');  // clear audio
		    
		    WAIT 600
		    {
			blnSysPow[ROOM_C] = FALSE;
			
			SEND_COMMAND dvaTP_MAIN_01[ROOM_C], "'@PPX'";
			SEND_COMMAND dvaTP_MAIN_01[ROOM_C], "'PAGE-Welcome'";

		    }            
		}
	    }
	    ACTIVE(!blnCombined[PARTITION_AB] && blnCombined[PARTITION_BC]): // rooms B/C combined, A separate
	    {
		IF(nWhichRoom == ROOM_C || nWhichRoom == ROOM_B)
		{
		    SEND_COMMAND dvaTP_MAIN_01[ROOM_C], "'@PPN-Wait'";
		    SEND_COMMAND dvaTP_MAIN_01[ROOM_B], "'@PPN-Wait'";

		    fnProjector(ROOM_B,'OFF');
		    fnProjector(ROOM_C,'OFF');
		    fnProjector(ROOM_B2,'OFF');
		    
		    fnAudioMute(ROOM_C,TRUE);  
		    fnAudioMute(ROOM_B,TRUE);  
    
		    fnMicMute(ROOM_C,TRUE);  
		    fnMicMute(ROOM_B,TRUE);  
		    
		    // clear routes
		    fnMTX(0,2,'V');  // clear video
		    fnMTX(0,3,'V');  // clear video
		    fnMTX(0,4,'V');  // clear video
		    fnMTX(0,ao_PGM[ROOM_C],'A');  // clear audio
		    fnMTX(0,ao_PGM[ROOM_B],'A');  // clear audio
		    
		    WAIT 600
		    {
			blnSysPow[ROOM_C] = FALSE;
			blnSysPow[ROOM_B] = FALSE;
			
			SEND_COMMAND dvaTP_MAIN_01[ROOM_C], "'@PPX'";
			SEND_COMMAND dvaTP_MAIN_01[ROOM_C], "'PAGE-Welcome'";
			SEND_COMMAND dvaTP_MAIN_01[ROOM_B], "'@PPX'";
			SEND_COMMAND dvaTP_MAIN_01[ROOM_B], "'PAGE-Welcome'";
			
			blnCombined_Temp[2] = FALSE;
			blnCombined[2] = FALSE;
			fnCombineDivide();

		    }            
		    
		}
		ELSE  // room A
		{
		    SEND_COMMAND dvaTP_MAIN_01[ROOM_A], "'@PPN-Wait'";

		    fnMonitor(1,'OFF');
		    
		    fnAudioMute(ROOM_C,TRUE);  
		    fnMicMute(ROOM_C,TRUE);  
		    
		    // clear routes
		    fnMTX(0,1,'V');  // clear video
		    fnMTX(0,ao_PGM[ROOM_A],'A');  // clear audio
		    
		    WAIT 200
		    {
			blnSysPow[ROOM_A] = FALSE;
			
			SEND_COMMAND dvaTP_MAIN_01[ROOM_A], "'@PPX'";
			SEND_COMMAND dvaTP_MAIN_01[ROOM_A], "'PAGE-Welcome'";

		    }            
		}
	    }	    
	} 

	WAIT 1250 // time needs to be more than the potential power-on time of a second room that may be occurring while one room powers down 
	{
	    IF(!blnSysPow[ROOM_A] && !blnSysPow[ROOM_B] && !blnSysPow[ROOM_C]) ON[dvRelay,2];  // pwr seq OFF
	}
    }
}




DEFINE_START

blnCombined[1] = FALSE;
blnCombined[2] = FALSE;
blnCombined_Temp[1] = FALSE;
blnCombined_Temp[2] = FALSE;
fnCombineDivide();


SEND_STRING dvDSP, "'RECALL 0 PRESET 1001',$0A";

//TIMELINE_CREATE(tlStatusPopups,tlStatusPopups_Array,LENGTH_ARRAY(tlStatusPopups_Array),TIMELINE_RELATIVE,TIMELINE_REPEAT)




DEFINE_EVENT


BUTTON_EVENT[dvaTP_MAIN_01,0]
{
    PUSH:
    {
	nWhichRm = GET_LAST(dvaTP_MAIN_01);
    }
}



DATA_EVENT[dvaTP_MAIN_01]
{
    ONLINE:
    {
	SEND_COMMAND DATA.DEVICE, "'^TXT-1,0,', RoomName[GET_LAST(dvaTP_MAIN_01)]"
	
//	fnCombineDivide(1,blnCombined[PARTITION_AB]);
//	fnCombineDivide(2,blnCombined[PARTITION_BC]);
    }
}


BUTTON_EVENT[dvaTP_MAIN_01,255]  // power down
{
    PUSH:
    {
	fnSysPow(nWhichRm, FALSE);
    }
}


///// Divide / Combine ///////
BUTTON_EVENT[dvaTP_Main_01,nPartitionBtns]
BUTTON_EVENT[dvTP_Op_Main_401,nPartitionBtns]
{
    PUSH: 
    {
	blnEditingConfig = TRUE;
	blnCombined_Temp[GET_LAST(nPartitionBtns)] = !blnCombined_Temp[GET_LAST(nPartitionBtns)];
    }
}

BUTTON_EVENT[dvaTP_Main_01,7]	// continue
BUTTON_EVENT[dvTP_Op_Main_401,7]  
{
    PUSH:
    {
	blnCombined[1] = blnCombined_Temp[1];
	blnCombined[2] = blnCombined_Temp[2];
	fnCombineDivide();
	blnEditingConfig = FALSE;
    }
}

BUTTON_EVENT[dvaTP_Main_01,8]	// cancel
BUTTON_EVENT[dvTP_Op_Main_401,8]  
{
    PUSH:
    {
	blnCombined_Temp[1] = blnCombined[1];
	blnCombined_Temp[2] = blnCombined[2];
	blnEditingConfig = FALSE;
    }
}





/////////////// Rotating Status Popups ///////////////
timeline_event[tlStatusPopups]
{
    if(timeline.sequence == 1) 	send_command dvaTP_Main_01, "'PPOF-', cStatusPopupNames[length_array(cStatusPopupNames)]";
    else			send_command dvaTP_Main_01, "'PPOF-', cStatusPopupNames[timeline.sequence - 1]";
    
    send_command dvaTP_Main_01, "'@PPN-', cStatusPopupNames[timeline.sequence], ';Main'";
}




/////////////////////


(***********************************************************)
(*            THE ACTUAL PROGRAM GOES BELOW                *)
(***********************************************************)
DEFINE_PROGRAM

[dvaTP_Main_01[ROOM_A],PWR_FB]	= blnSysPow[ROOM_A];
[dvaTP_Main_01[ROOM_B],PWR_FB]	= blnSysPow[ROOM_B];
[dvaTP_Main_01[ROOM_C],PWR_FB]	= blnSysPow[ROOM_C];


IF(blnEditingConfig)
{
    [dvaTP_Main_01,BTN_PARTITION_AB]	= blnCombined_Temp[PARTITION_AB];
    [dvaTP_Main_01,BTN_PARTITION_BC]	= blnCombined_Temp[PARTITION_BC];
    [dvTP_Op_Main_401,BTN_PARTITION_AB]	= blnCombined_Temp[PARTITION_AB];
    [dvTP_Op_Main_401,BTN_PARTITION_BC]	= blnCombined_Temp[PARTITION_BC];
}
ELSE
{
    [dvaTP_Main_01,BTN_PARTITION_AB]	= blnCombined[PARTITION_AB];
    [dvaTP_Main_01,BTN_PARTITION_BC]	= blnCombined[PARTITION_BC];
    [dvTP_Op_Main_401,BTN_PARTITION_AB]	= blnCombined[PARTITION_AB];
    [dvTP_Op_Main_401,BTN_PARTITION_BC]	= blnCombined[PARTITION_BC];
}


WAIT 30
{
    SELECT
    {
	ACTIVE(blnCombined[PARTITION_AB] && blnCombined[PARTITION_BC]):  // all 3 rooms
	{
	    SEND_COMMAND dvaTP_Main_01, "'@PPN-Room ABC Sources;Main'";
	}
	ACTIVE(blnCombined[PARTITION_AB] && !blnCombined[PARTITION_BC]):  // A/B combined, C separate
	{
	    SEND_COMMAND dvaTP_Main_01[ROOM_A], "'@PPN-Room AB Sources;Main'";
	    SEND_COMMAND dvaTP_Main_01[ROOM_B], "'@PPN-Room AB Sources;Main'";
	    SEND_COMMAND dvaTP_Main_01[ROOM_C], "'@PPN-Room C Sources;Main'";
	}
	ACTIVE(!blnCombined[PARTITION_AB] && blnCombined[PARTITION_BC]):  // B/C combined, A separate
	{
	    SEND_COMMAND dvaTP_Main_01[ROOM_C], "'@PPN-Room BC Sources;Main'";
	    SEND_COMMAND dvaTP_Main_01[ROOM_B], "'@PPN-Room BC Sources;Main'";
	    SEND_COMMAND dvaTP_Main_01[ROOM_A], "'@PPN-Room A Sources;Main'";
	}
	ACTIVE(1):  // no rooms combined
	{
	    SEND_COMMAND dvaTP_Main_01[ROOM_A], "'@PPN-Room A Sources;Main'";
	    SEND_COMMAND dvaTP_Main_01[ROOM_B], "'@PPN-Room B Sources;Main'";
	    SEND_COMMAND dvaTP_Main_01[ROOM_C], "'@PPN-Room C Sources;Main'";
	
	}
    }
}

