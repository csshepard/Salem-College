PROGRAM_NAME='_Roomxxxx_Config'
(***********************************************************)
(*  FILE CREATED ON: 05/22/2013  AT: 14:41:37              *)
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 07/08/2014  AT: 13:47:36        *)
(***********************************************************)



(***********************************************************)
//  Define the various components of the system by
//  commenting/un-commenting the definitions below. Then,
//  go below that to define the #'s and other information
//  for each config item
(***********************************************************)

//#DEFINE CONFIG_RMS
#DEFINE CONFIG_AUTO_SHUTDOWN
#DEFINE CONFIG_SWITCHER
#DEFINE CONFIG_DSP
#DEFINE CONFIG_PHONE
#DEFINE CONFIG_MACROS
//#DEFINE CONFIG_VTC
#DEFINE CONFIG_DVD
//#DEFINE CONFIG_CAM
//#DEFINE CONFIG_DOC_CAM
//#DEFINE CONFIG_CABLE_TV
#DEFINE CONFIG_PROJECTOR
#DEFINE CONFIG_LED_DISPLAY	
//#DEFINE CONFIG_SMART_BOARD
//#DEFINE CONFIG_LIGHTS
//#DEFINE CONFIG_SHADES


DEFINE_DEVICE

dvRelay	= 5001:8:0
dvIOs	= 5001:17:0


DEFINE_CONSTANT


INTEGER ROOM_A		= 1;
INTEGER ROOM_B		= 2;
INTEGER ROOM_C		= 3;
INTEGER OPERATOR	= 4;
INTEGER ROOM_B2		= 1;

INTEGER PARTITION_AB		= 1;
INTEGER PARTITION_BC		= 2;
INTEGER BTN_PARTITION_AB	= 5;
INTEGER BTN_PARTITION_BC	= 6;
INTEGER nPartitionBtns[]	= {BTN_PARTITION_AB, BTN_PARTITION_BC};

INTEGER DEFAULT_VOL_LVL		= 790

// General room stuff
CHAR RoomName[3][25]	= 
{
    'Meeting Room A',
    'Meeting Room B',
    'Meeting Room C'
}
CHAR RoomType[] 	= 'Divide/Combine Meeting Room';

// Basic Symbols
CHAR CR[]	= $0D
CHAR LF[]	= $0A
CHAR STX[]	= $02
CHAR ETX[]	= $03


// Some basic SNAPI channels for control
PWR_ON		= 27
PWR_OFF		= 28
PWR_TOG		= 9
PWR_FB		= 255
INTEGER nPwrBtns[] =
{
    PWR_ON,
    PWR_OFF
}

VOL_UP		= 24
VOL_DOWN	= 25
VOL_MUTE_FB	= 199
VOL_MUTE_TOG	= 26

INPUT_TOG	= 196

PTZ_TILT_UP	= 132
PTZ_TILT_DOWN	= 133
PTZ_PAN_LEFT	= 134
PTZ_PAN_RIGHT	= 135
PTZ_ZOOM_IN	= 159
PTZ_ZOOM_OUT	= 158
CAM_FOCUS_IN	= 160
CAM_FOCUS_OUT	= 161
CAM_AUTO_FOC	= 162
CAM_IRIS_OPEN	= 174
CAM_IRIS_CLOSE	= 175
CAM_AUTO_IRIS	= 163

TRANSPORT_PLAY	= 1
TRANSPORT_STOP	= 2
TRANSPORT_PAUSE	= 3
TRANSPORT_NEXT	= 4
TRANSPORT_PREV	= 5
TRANSPORT_FFWD	= 6
TRANSPORT_REW	= 7
TRANSPORT_REC	= 8

NAV_MENU	= 44
NAV_UP		= 45
NAV_DOWN	= 46
NAV_LEFT	= 47
NAV_RIGHT	= 48
NAV_SELECT	= 49



//////////////////////////////
//////////// RMS /////////////
//////////////////////////////
#IF_DEFINED CONFIG_RMS


#END_IF


//////////////////////////////
//////////// MACROS //////////
//////////////////////////////
#IF_DEFINED CONFIG_MACROS
    #IF_NOT_DEFINED CONFIG_SWITCHER
	#DEFINE CONFIG_SWITCHER
    #END_IF

    INTEGER CONFIG_MACROS_NUMBER_OF_MACROS	= 2;
#END_IF


//////////////////////////////////
/////////// SWITCHER /////////////
//////////////////////////////
#IF_DEFINED CONFIG_SWITCHER

    // How many of everything // on primary switcher
    INTEGER CONFIG_SWITCHER_NUMBER_SWITCHERS		= 1;
    INTEGER CONFIG_SWITCHER_NUMBER_INPUTS		= 8;
    INTEGER CONFIG_SWITCHER_NUMBER_OUTPUTS		= 4;
    INTEGER CONFIG_SWITCHER_NUMBER_SOURCES		= 8;  /// number sources/destinations can be different from # of inputs/outputs;
    INTEGER CONFIG_SWITCHER_NUMBER_DESTINATIONS		= 4;   /// using these to drive the source/dest buttons and icon slots
    //INTEGER CONFIG_SWITCHER_SECONDARY_INPUTS[]		= {7,8}

    // What is it?
    CHAR CONFIG_SWITCHER_TYPE[CONFIG_SWITCHER_NUMBER_SWITCHERS][50]	=
    {
	'Extron'
    }

    // Values for passing to routing function indicating what type of destination
    INTEGER DISP_TYPE_PROJ	= 1;
    INTEGER DISP_TYPE_DISP	= 2;
    INTEGER DISP_TYPE_SMART	= 3;
    INTEGER DISP_TYPE_VTC	= 4;
    INTEGER DISP_TYPE_RECORD	= 5;
    INTEGER DISP_TYPE_FEED	= 6;

    INTEGER DISP_LEFT		= 1;
    INTEGER DISP_RIGHT		= 2;

    INTEGER VID_MUTE_BTN	= 100;


    // Source/destination constants (name these accordingly w/ what they are in each defined device section below)
    INTEGER vi_1	= 1;
    INTEGER vi_2	= 2;
    INTEGER vi_3	= 3;
    INTEGER vi_4	= 4;
    INTEGER vi_5	= 5;
    INTEGER vi_6	= 6;
    INTEGER vi_7	= 7;
    INTEGER vi_8	= 8;
    INTEGER vi_9	= 9;
    INTEGER vi_10	= 10;
    INTEGER vi_11	= 11;
    INTEGER vi_12	= 12;
    INTEGER vi_13	= 13;
    INTEGER vi_14	= 14;
    INTEGER vi_15	= 15;
    INTEGER vi_16	= 16;
    INTEGER vi_17	= 17;
    INTEGER vi_18	= 18;
    INTEGER vi_19	= 19;
    INTEGER vi_20	= 20;
    INTEGER vi_21	= 21;
    INTEGER vi_22	= 22;
    INTEGER vi_23	= 23;
    INTEGER vi_24	= 24;
    INTEGER vi_25	= 25;
    INTEGER vi_26	= 26;
    INTEGER vi_27	= 27;
    INTEGER vi_28	= 28;
    INTEGER vi_29	= 29;
    INTEGER vi_30	= 30;
    INTEGER vi_31	= 31;
    INTEGER vi_32	= 32;

    INTEGER vo_1	= 1;
    INTEGER vo_2	= 2;
    INTEGER vo_3	= 3;
    INTEGER vo_4	= 4;
    INTEGER vo_5	= 5;
    INTEGER vo_6	= 6;
    INTEGER vo_7	= 7;
    INTEGER vo_8	= 8;
    INTEGER vo_9	= 9;
    INTEGER vo_10	= 10;
    INTEGER vo_11	= 11;
    INTEGER vo_12	= 12;
    INTEGER vo_13	= 13;
    INTEGER vo_14	= 14;
    INTEGER vo_15	= 15;
    INTEGER vo_16	= 16;
    INTEGER vo_17	= 17;
    INTEGER vo_18	= 18;
    INTEGER vo_19	= 19;
    INTEGER vo_20	= 20;
    INTEGER vo_21	= 21;
    INTEGER vo_22	= 22;
    INTEGER vo_23	= 23;
    INTEGER vo_24	= 24;
    INTEGER vo_25	= 25;
    INTEGER vo_26	= 26;
    INTEGER vo_27	= 27;
    INTEGER vo_28	= 28;
    INTEGER vo_29	= 29;
    INTEGER vo_30	= 30;
    INTEGER vo_31	= 31;
    INTEGER vo_32	= 32;

    INTEGER ai_1	= 1;
    INTEGER ai_2	= 2;
    INTEGER ai_3	= 3;
    INTEGER ai_4	= 4;
    INTEGER ai_5	= 5;
    INTEGER ai_6	= 6;
    INTEGER ai_7	= 7;
    INTEGER ai_8	= 8;
    INTEGER ai_9	= 9;
    INTEGER ai_10	= 10;
    INTEGER ai_11	= 11;
    INTEGER ai_12	= 12;
    INTEGER ai_13	= 13;
    INTEGER ai_14	= 14;
    INTEGER ai_15	= 15;
    INTEGER ai_16	= 16;
    INTEGER ai_17	= 17;
    INTEGER ai_18	= 18;
    INTEGER ai_19	= 19;
    INTEGER ai_20	= 20;
    INTEGER ai_21	= 21;
    INTEGER ai_22	= 22;
    INTEGER ai_23	= 23;
    INTEGER ai_24	= 24;
    INTEGER ai_25	= 25;
    INTEGER ai_26	= 26;
    INTEGER ai_27	= 27;
    INTEGER ai_28	= 28;
    INTEGER ai_29	= 29;
    INTEGER ai_30	= 30;
    INTEGER ai_31	= 31;
    INTEGER ai_32	= 32;

    INTEGER ao_PGM[3]	= {1,2,3};	// [room A,B,C]
    //INTEGER ao_Rack	= 2;
    INTEGER ao_1	= 1;
    INTEGER ao_2	= 2;
    INTEGER ao_3	= 3;
    INTEGER ao_4	= 4;
    INTEGER ao_5	= 5;
    INTEGER ao_6	= 6;
    INTEGER ao_7	= 7;
    INTEGER ao_8	= 8;
    INTEGER ao_9	= 9;
    INTEGER ao_10	= 10;
    INTEGER ao_11	= 11;
    INTEGER ao_12	= 12;
    INTEGER ao_13	= 13;
    INTEGER ao_14	= 14;
    INTEGER ao_15	= 15;
    INTEGER ao_16	= 16;
    INTEGER ao_17	= 17;
    INTEGER ao_18	= 18;
    INTEGER ao_19	= 19;
    INTEGER ao_20	= 20;
    INTEGER ao_21	= 21;
    INTEGER ao_22	= 22;
    INTEGER ao_23	= 23;
    INTEGER ao_24	= 24;
    INTEGER ao_25	= 25;
    INTEGER ao_26	= 26;
    INTEGER ao_27	= 27;
    INTEGER ao_28	= 28;
    INTEGER ao_29	= 29;
    INTEGER ao_30	= 30;
    INTEGER ao_31	= 31;
    INTEGER ao_32	= 32;


    INTEGER SRC_ICON_SLOT_DESKTOP	= 2;
    INTEGER SRC_ICON_SLOT_LAPTOP	= 1;
    INTEGER SRC_ICON_SLOT_AUX		= 0;
    INTEGER SRC_ICON_SLOT_CAM		= 6;
    INTEGER SRC_ICON_SLOT_DOC_CAM	= 0;
    INTEGER SRC_ICON_SLOT_DVD		= 7;
    INTEGER SRC_ICON_SLOT_CATV		= 0;
    INTEGER SRC_ICON_SLOT_VTC		= 5;
    INTEGER SRC_ICON_SLOT_VGA		= 0;
    INTEGER SRC_ICON_SLOT_HDMI		= 0;
    INTEGER SRC_ICON_SLOT_COMPOSITE	= 0;
    INTEGER SRC_ICON_SLOT_FEED		= 0;

    INTEGER DST_ICON_SLOT_PROJ		= 4;
    INTEGER DST_ICON_SLOT_DISP		= 8;
    INTEGER DST_ICON_SLOT_VTC		= 0;
    INTEGER DST_ICON_SLOT_SMART		= 0;
    INTEGER DST_ICON_SLOT_FEED		= 0;
    INTEGER DST_ICON_SLOT_VIDWALL	= 12;

    // Structure containing info about the inputs/outputs in this file; make sure to populate it in DEFINE_START
#END_IF



//////////////////////////////////
////////////// DSP ///////////////
//////////////////////////////////
#IF_DEFINED CONFIG_DSP
    
#END_IF


//////////////////////////////////
////////////// VTC ///////////////
//////////////////////////////////
#IF_DEFINED CONFIG_VTC
    CHAR CONFIG_VTC_CODEC_MFR[]		= 'Polycom';
    CHAR CONFIG_VTC_CODEC_MODEL[]	= 'HDX';
    CHAR CONFIG_VTC_BAUD[]		= '38400';
#END_IF



//////////////////////////////////
////////////// DVD ///////////////
//////////////////////////////////
#IF_DEFINED CONFIG_DVD

#END_IF


//////////////////////////////////
////////////// CAMERA ////////////
//////////////////////////////////
#IF_DEFINED CONFIG_CAM
    INTEGER 	CONFIG_CAM_NUMBER_CAMS	= 3;
    CHAR	CONFIG_CAM_COMM_TYPE[]	= 'SERIAL';  // IR or SERIAL
#END_IF


//////////////////////////////////
////////////// DOC CAM ///////////
//////////////////////////////////
#IF_DEFINED CONFIG_DOC_CAM

#END_IF


//////////////////////////////////
////////////// CATV //////////////
//////////////////////////////////
#IF_DEFINED CONFIG_CABLE_TV
    INTEGER CONFIG_CABLE_TV_NUMBER_PRESETS	= 9;
#END_IF


//////////////////////////////////
////////////// PROJECTOR /////////
//////////////////////////////////
#IF_DEFINED CONFIG_PROJECTOR
    INTEGER CONFIG_PROJECTOR_NUMBER_PROJECTORS	= 3;

#END_IF


//////////////////////////////////
////////////// DISPLAYS //////////
//////////////////////////////////
#IF_DEFINED CONFIG_LED_DISPLAY
    INTEGER CONFIG_LED_DISPLAY_NUMBER_DISPLAYS	= 1;
    //INTEGER CONFIG_LED_DISPLAY_MIRROR_PROJ	= TRUE; // will they mirror their respective projectors?
#END_IF


//////////////////////////////////
////////////// SMART BOARD ///////
//////////////////////////////////
#IF_DEFINED CONFIG_SMART_BOARD

#END_IF


//////////////////////////////////
////////////// LIGHTS ////////////
//////////////////////////////////
#IF_DEFINED CONFIG_LIGHTS
    INTEGER CONFIG_LIGHTS_NUMBER_PRESETS	= 4;
    // Preset names defined in vars
#END_IF


//////////////////////////////////
////////////// SHADES ////////////
//////////////////////////////////
#IF_DEFINED CONFIG_SHADES
    INTEGER CONFIG_SHADES_NUMBER_PRESETS	= 5;
    //#DEFINE CONFIG_SHADES_IS_SHADES_MASTER	= TRUE;  // if this room is connected directly to the shade controller for its cluster, un-comment this definition
#END_IF



//////////////////////////////////
////////////// GLOBALS    ////////
//////////////////////////////////
DEFINE_VARIABLE

VOLATILE INTEGER blnSysPow[3]
VOLATILE INTEGER BIC	// button.input.channel
VOLATILE CHAR cBottomBar[10]
VOLATILE INTEGER nWhichRm	// which room generating event?
VOLATILE INTEGER blnCombined[2]	// room combined?  [1] = room a/b combined, [2] = room b/c combined (can be both...all 3 rooms)
VOLATILE INTEGER nCurrentRoomControl = ROOM_A // for the operator panel
VOLATILE INTEGER blnCombined_Temp[2]	// temporary tracking for modifications
VOLATILE INTEGER blnEditingConfig	// user is editing the room combine/divide status


//////////////////////////////////
////////////// STRUCTURES ////////
//////////////////////////////////

DEFINE_TYPE

#IF_DEFINED CONFIG_SWITCHER
    STRUCTURE _sSwitcherInputs  	// index will be input # on the switcher
    {
	CHAR 	SourceName[25]		// Blu-Ray, VTC, PC, etc.
	CHAR	SignalFormat[25]	// HDMI, DVI, VGA, etc.
	INTEGER IconSlot		// Icon slot # associated in TP file
	CHAR	ControlPage[50]		// The control page on the panel for the device
	INTEGER USBSwitcher		// If the source is on a USB switcher, list input # here
	INTEGER HasSecondaryInputs	// If this input has another switcher's outputs feeding it (boolean)
	INTEGER HasAudio		// Does this source have audio associated?
	INTEGER BSSPreset		// If there's a BSS preset associated with this source (eg. VTC, which goes directly into DSP and not thru switcher)
	CHAR 	AudioPreset[50]
    }

    STRUCTURE _sSwitcherOutputs  	// index will be output # on the switcher
    {
	CHAR 	DestName[25]		// Left Projector, VTC, Smart Board, etc.
	CHAR	SignalFormat[25]	// HDMI, DVI, VGA, etc.
	INTEGER DestType		// Flag for Projector, SmartBoard, Display, or VTC
	INTEGER DestSide		// Which side of room (left/right), for mirroring projectors and monitors
	INTEGER IconSlot		// Icon slot associated in TP file
    }

    STRUCTURE _sSwitcherInfo		// This struct will house the info for whole switcher
    {
	CHAR Switcher_MFR[25]
	CHAR Switcher_Model[25]
	_sSwitcherInputs 	Inputs[CONFIG_SWITCHER_NUMBER_INPUTS]
	_sSwitcherOutputs	Outputs[CONFIG_SWITCHER_NUMBER_OUTPUTS]
    }

#END_IF


#IF_DEFINED CONFIG_MACROS
    STRUCTURE _sRoutingMacros
    {
	CHAR MacroName[50]
	CHAR MacroDesc[255]	// text description of the macro
	CHAR IconSlot[3]	// icon slot in TP file to update macro icon on panel
	INTEGER LightPreset	// What light preset will be recalled
	INTEGER ShadePreset	// What shade preset will be recalled
	INTEGER VideoRoutes[3][CONFIG_SWITCHER_NUMBER_OUTPUTS]  // video routes that will be made
	INTEGER AudioSource[3]	// Which audio source for program/playback
	CHAR ControlPage[50]
	CHAR AudioPreset[50]
    }

#END_IF

#IF_DEFINED CONFIG_CABLE_TV
    STRUCTURE _sCATVPresets
    {
	CHAR 	TVChannel[6]
	CHAR	TVChanName[25]
	INTEGER IconSlot
    }

#END_IF


//////////////////////////////////
////////////// AUTO SHUTDOWN /////
//////////////////////////////////
#IF_DEFINED CONFIG_AUTO_SHUTDOWN
    DEFINE_DEVICE
    dvTP_ASD_120	= 10001:20:0
    dvTP_ASD_220	= 10002:20:0
    dvTP_ASD_320	= 10003:20:0
    dvTP_ASD_420	= 10004:20:0
    vdvASD		= 33120:1:0

    DEFINE_VARIABLE
    DEV vdvaASD[] =
    {
	vdvASD
    }
    DEV dvaTP_ASD_20[]	=
    {
	dvTP_ASD_120,
	dvTP_ASD_220,
	dvTP_ASD_320,
	dvTP_ASD_420
    }


    DEFINE_START
    DEFINE_MODULE '_AutoShutdown_Module_v2' ASD(vdvASD,dvaTP_ASD_20)

    DEFINE_EVENT
    CHANNEL_EVENT[vdvaASD,1]
    {
	 OFF:	
	 {
	    blnCombined[PARTITION_AB] = FALSE;
	    blnCombined[PARTITION_BC] = FALSE;
	    blnCombined_Temp[PARTITION_AB] = FALSE;
	    blnCombined_Temp[PARTITION_BC] = FALSE;
	    fnCombineDivide();

	    fnSysPow(ROOM_A,FALSE);
	    fnSysPow(ROOM_B,FALSE);
	    fnSysPow(ROOM_C,FALSE);
	 }
    }
#END_IF



//////////////////////////////////
////////////// SWITCHER    ///////
//////////////////////////////////
#IF_DEFINED CONFIG_SWITCHER

    DEFINE_DEVICE
    dvSWITCHER			= 5001:3:0	// Extron DXP 84
    dvTP_Switcher_103		= 10001:3:0
    dvTP_Switcher_203		= 10002:3:0
    dvTP_Switcher_303		= 10003:3:0
    dvTP_Switcher_Op		= 10004:3:0  // operator panel

//    DEFINE_CONSTANT
//    vo_RoomPreview[2]	= {9,10};  // [classroom,lab]

    DEFINE_VARIABLE

    _sSwitcherInfo sSwitcherInfo[CONFIG_SWITCHER_NUMBER_SWITCHERS]
    VOLATILE INTEGER nSwitcherTrack[CONFIG_SWITCHER_NUMBER_OUTPUTS]
    VOLATILE INTEGER nCurrentAudioSrc[3]
    VOLATILE INTEGER nRoutingPair[4][2]
    VOLATILE INTEGER blnVideoMute[3]
    
    VOLATILE CHAR cSwt_IP[15]
    VOLATILE INTEGER nSwt_Port    
    VOLATILE INTEGER nSwtMethod    
    
    
    // things like camera and last video have some default routes
    //VOLATILE INTEGER nDefaultRoutes_Cam[CONFIG_SWITCHER_NUMBER_OUTPUTS]		= {2,4,6} 
    //VOLATILE INTEGER nDefaultRoutes_Program[CONFIG_SWITCHER_NUMBER_OUTPUTS] 	= {9}
    


    DEV dvaTP_Switcher_03[] =
    {
	dvTP_Switcher_103,
	dvTP_Switcher_203,
	dvTP_Switcher_303//,
	//dvTP_Switcher_Op
    }

    VOLATILE INTEGER nVidInputBtns[] =
    {
	101,102,103,104,105,106,107,108,
	109,110,111,112,113,114,115,116,
	117,118,119,120,121,122,123,124,
	125,126,127,128,129,130,131,132
    }

//    VOLATILE INTEGER nHDMISwtInputBtns[] =
//    {
//	2101,2102,2103,2104
//    }

    VOLATILE INTEGER nVidOutputBtns[] =
    {
	201,202,203,204,205,206,207,208,
	209,210,211,212,213,214,215,216,
	217,218,219,220,221,222,223,224,
	225,226,227,228,229,230,231,232
    }

    VOLATILE INTEGER nVidRouteTxtBtns[] =
    {
	1201,1202,1203,1204,1205,1206,1207,1208,
	1209,1210,1211,1212,1213,1214,1215,1216,
	1217,1218,1219,1220,1221,1222,1223,1224,
	1225,1226,1227,1228,1229,1230,1231,1232
    }

//    Will most likely just use the same source buttons for audio and video, then routing
//    occurs simply based on what type of destination selected.
//    VOLATILE INTEGER nAudInputBtns[] =
//    {
//	301,302,303,304,305,306,307,308,
//	309,310,311,312,313,314,315,316,
//	317,318,319,320,321,322,323,324,
//	325,326,327,328,329,330,331,332
//    }

    VOLATILE INTEGER nAudOutputBtns[] =
    {
	401,402,403,404,405,406,407,408,
	409,410,411,412,413,414,415,416,
	417,418,419,420,421,422,423,424,
	425,426,427,428,429,430,431,432
    }

    VOLATILE INTEGER nAudRouteTxtBtns[] =
    {
	1401,1402,1403,1404,1405,1406,1407,1408,
	1409,1410,1411,1412,1413,1414,1415,1416,
	1417,1418,1419,1420,1421,1422,1423,1424,
	1425,1426,1427,1428,1429,1430,1431,1432
    }

    DEFINE_START
//    cSwt_IP	= '192.168.5.18';
//    nSwt_Port	= 23;
//    nSwtMethod	= IP_TCP
//
//    DEFINE_MODULE '_IP_Comm_Module' ipConnSwt(dvSWITCHER,cSwt_IP, nSwt_Port, nSwtMethod)
    


    DEFINE_EVENT
    DATA_EVENT[dvaTP_Switcher_03]
    {
	ONLINE:
	{
	    LOCAL_VAR INTEGER x

	    WAIT 100
	    {
		FOR(x=1;x<=CONFIG_SWITCHER_NUMBER_SOURCES;x++)
		{
		    // show/hide the source buttons
		    IF(LENGTH_STRING(sSwitcherInfo[1].Inputs[x].SourceName) && !sSwitcherInfo[1].Inputs[x].HasSecondaryInputs)
		    {
			SEND_COMMAND dvaTP_Switcher_03, "'^SHO-', ITOA(nVidInputBtns[x]), ',1'";  // show it
			SEND_COMMAND dvaTP_Switcher_03, "'^TXT-', ITOA(nVidInputBtns[x]), ',0,', UPPER_STRING(sSwitcherInfo[1].Inputs[x].SourceName)";  // send source name
			//SEND_COMMAND dvaTP_Switcher_03, "'^BMF-', ITOA(nVidInputBtns[x]), ',0,%I', ITOA(sSwitcherInfo[1].Inputs[x].IconSlot)";  // assign icon

			SEND_COMMAND dvTP_Switcher_Op, "'^SHO-', ITOA(nVidInputBtns[x]), ',1'";  // show it
			SEND_COMMAND dvTP_Switcher_Op, "'^TXT-', ITOA(nVidInputBtns[x]), ',0,', UPPER_STRING(sSwitcherInfo[1].Inputs[x].SourceName)";  // send source name
			//SEND_COMMAND dvTP_Switcher_Op, "'^BMF-', ITOA(nVidInputBtns[x]), ',0,%I', ITOA(sSwitcherInfo[1].Inputs[x].IconSlot)";  // assign icon

		    }
		    ELSE
		    {
			SEND_COMMAND dvaTP_Switcher_03, "'^SHO-', ITOA(nVidInputBtns[x]), ',0'";
			SEND_COMMAND dvTP_Switcher_Op, "'^SHO-', ITOA(nVidInputBtns[x]), ',0'";
		    }

//		    IF(CONFIG_SWITCHER_NUMBER_SWITCHERS == 2 && LENGTH_STRING(sSwitcherInfo[2].Inputs[x].SourceName))
//		    {
//			SEND_COMMAND dvaTP_Switcher_03, "'^SHO-', ITOA(nHDMISwtInputBtns[x]), ',1'";  // show it
//			SEND_COMMAND dvaTP_Switcher_03, "'^TXT-', ITOA(nHDMISwtInputBtns[x]), ',0,', sSwitcherInfo[2].Inputs[x].SourceName";  // send source name
//			SEND_COMMAND dvaTP_Switcher_03, "'^BMF-', ITOA(nHDMISwtInputBtns[x]), ',0,I%', ITOA(sSwitcherInfo[2].Inputs[x].IconSlot)";  // assign icon
//		    }
//		    ELSE
//			SEND_COMMAND dvaTP_Switcher_03, "'^SHO-', ITOA(nHDMISwtInputBtns[x]), ',0'";
		}

		// populate the destination buttons
		FOR(x=1; x<=CONFIG_SWITCHER_NUMBER_DESTINATIONS; x++)
		{
		    SEND_COMMAND dvTP_Switcher_Op, "'^TXT-', ITOA(nVidOutputBtns[x]), ',0,', sSwitcherInfo[1].Outputs[x].DestName";  // send source name
		    //SEND_COMMAND dvTP_Switcher_Op, "'^BMF-', ITOA(nVidOutputBtns[x]), ',0,%I', ITOA(sSwitcherInfo[1].Outputs[x].IconSlot)";  // assign icon

		    SEND_COMMAND dvaTP_Switcher_03, "'^TXT-', ITOA(nVidOutputBtns[x]), ',0,', sSwitcherInfo[1].Outputs[x].DestName";  // send source name
		    //SEND_COMMAND dvaTP_Switcher_03, "'^BMF-', ITOA(nVidOutputBtns[x]), ',0,%I', ITOA(sSwitcherInfo[1].Outputs[x].IconSlot)";  // assign icon

		}
	    }
	}
    }


#END_IF


//////////////////////////////////
////////////// MACROS      ///////
//////////////////////////////////

#IF_DEFINED CONFIG_MACROS
    DEFINE_DEVICE
    dvTP_Macros_101	= 10001:1:0
    dvTP_Macros_201	= 10002:1:0
    dvTP_Macros_301	= 10003:1:0

    DEFINE_VARIABLE

    DEV dvaTP_Macros_01[] =
    {
	dvTP_Macros_101,
	dvTP_Macros_201,
	dvTP_Macros_301
    }
    _sRoutingMacros sRoutingMacros[CONFIG_MACROS_NUMBER_OF_MACROS]
    VOLATILE INTEGER nWhichMacro[3]	// track the currently active/selected macro
    VOLATILE INTEGER nMacrosBtns[] =
    {
	101,102,103,104,105,106,107,108,109,110
    }
    VOLATILE INTEGER nMacroTitleBtns[] =
    {
	201,202,203,204,205,206,207,208,209,210
    }
    VOLATILE INTEGER nMacrosDescriptionBtns[] =
    {
	301,302,303,304,305,306,307,308,309,310
    }


    DEFINE_EVENT
    DATA_EVENT[dvaTP_Macros_01]
    {
	ONLINE:
	{
	    LOCAL_VAR INTEGER x

	    WAIT 100
	    {
		FOR(x=1;x<=CONFIG_MACROS_NUMBER_OF_MACROS;x++)
		{
		    // show/hide the source buttons
		    IF(LENGTH_STRING(sRoutingMacros[x].MacroName))
		    {
			SEND_COMMAND dvaTP_Macros_01, "'^SHO-', ITOA(nMacrosBtns[x]), ',1'";  // show it
			SEND_COMMAND dvaTP_Macros_01, "'^SHO-', ITOA(nMacroTitleBtns[x]), ',1'";  // show it
			SEND_COMMAND dvaTP_Macros_01, "'^SHO-', ITOA(nMacrosDescriptionBtns[x]), ',1'";  // show it
			SEND_COMMAND dvaTP_Macros_01, "'^TXT-', ITOA(nMacroTitleBtns[x]), ',0,', sRoutingMacros[x].MacroName";  // send macro name
			SEND_COMMAND dvaTP_Macros_01, "'^TXT-', ITOA(nMacrosDescriptionBtns[x]), ',0,', sRoutingMacros[x].MacroDesc";  // send description
			SEND_COMMAND dvaTP_Macros_01, "'^BMF-', ITOA(nMacrosBtns[x]), ',0,%I', ITOA(sRoutingMacros[x].IconSlot)";  // assign icon
		    }
		    ELSE
		    {
			SEND_COMMAND dvaTP_Macros_01, "'^SHO-', ITOA(nMacrosBtns[x]), ',0'";
			SEND_COMMAND dvaTP_Macros_01, "'^SHO-', ITOA(nMacrosDescriptionBtns[x]), ',0'";
			SEND_COMMAND dvaTP_Macros_01, "'^SHO-', ITOA(nMacroTitleBtns[x]), ',0'";
		    }
		}
	    }
	}
    }

#END_IF

//////////////////////////////////
////////////// DSP         ///////
//////////////////////////////////
#IF_DEFINED CONFIG_DSP

    DEFINE_DEVICE
    dvDSP		= 5001:2:0  // all 3 DSP's linked via Nexlink
    dvTP_Audio_113	= 10001:13:0
    dvTP_Audio_213	= 10002:13:0
    dvTP_Audio_313	= 10003:13:0
    dvTP_Audio_Op	= 10004:13:0
    vdvDSP		= 33013:1:0

    DEFINE_CONSTANT
    INTEGER TP_LEVEL_PRG_VOL		= 1
    INTEGER TP_BTN_PRG_MUTE		= 26
    INTEGER TP_BTN_MIC_MUTE_PODIUM	= 69
    INTEGER TP_BTN_MIC_MUTE_WIRELESS	= 169
    INTEGER TP_BTN_DO_NOT_DISTURB	= 200
    INTEGER MIC_PODIUM		= 1
    INTEGER MIC_WIRELESS 	= 2
    INTEGER TOGGLE		= 3
    CHAR cBiampUnitID[3]	=
    {
	'1',
	'2',
	'3'
    }

    DEFINE_VARIABLE
    DEV dvaTP_Audio_13[] =
    {
	dvTP_Audio_113,
	dvTP_Audio_213,
	dvTP_Audio_313
    }
    VOLATILE SLONG nProgramVolLvl[3] = {DEFAULT_VOL_LVL,DEFAULT_VOL_LVL,DEFAULT_VOL_LVL}
    VOLATILE INTEGER blnProgramMute[3]
    VOLATILE SLONG nMicLvl[3] = {DEFAULT_VOL_LVL,DEFAULT_VOL_LVL,DEFAULT_VOL_LVL}
    VOLATILE INTEGER blnMicMute[3]
    VOLATILE CHAR    cDSP_IP[15]
    VOLATILE INTEGER nDSP_Port
    VOLATILE INTEGER nDSPMethod
    VOLATILE INTEGER blnDND	// do not disturb


//    DEFINE_START

//    cDSP_IP	= '192.168.5.17';
//    nDSP_Port	= 52774;
//    nDSPMethod	= IP_TCP
//
//    DEFINE_MODULE '_IP_Comm_Module' ipConnDSP(dvDSP,cDSP_IP, nDSP_Port, nDSPMethod)



#END_IF




//////////////////////////////////
////////////// VTC         ///////
//////////////////////////////////
#IF_DEFINED CONFIG_VTC

    DEFINE_DEVICE
    dvTP_VTC_121	= 10001:21:0
    dvCODEC		= 5001:4:0

    vdvCODEC		= 41021:1:0
//    vdvCODEC2		= 41021:2:0
//    vdvCODEC3		= 41021:3:0
//    vdvCODEC4		= 41021:4:0
//    vdvCODEC5		= 41021:5:0
//    vdvCODEC6		= 41021:6:0
//    vdvCODEC7		= 41021:7:0
//    vdvCODEC8		= 41021:8:0
//    vdvCODEC9		= 41021:9:0
//    vdvCODEC10		= 41021:10:0
//    vdvCODEC11		= 41021:11:0


    DEFINE_CONSTANT
    INTEGER vi_VTC_1			= vi_8
    INTEGER vi_VTC_2			= vi_9
    INTEGER vo_VTC1			= vo_6  // cam
    INTEGER vo_VTC2			= vo_7  // content
    INTEGER PRESENTATION_MODE_FB 	= 309

    DEFINE_VARIABLE
    DEV dvaTP_VTC_21[] =
    {
	dvTP_VTC_121
    }

//    DEV vdvCODEC[]	=
//    {
//
//	vdvCODEC1,
//	vdvCODEC2,
//	vdvCODEC3,
//	vdvCODEC4,
//	vdvCODEC5,
//	vdvCODEC6,
//	vdvCODEC7,
//	vdvCODEC8,
//	vdvCODEC9,
//	vdvCODEC10,
//	vdvCODEC11
//    }


#END_IF


//////////////////////////////////
////////////// DVD/Blu-Ray ///////
//////////////////////////////////
#IF_DEFINED CONFIG_DVD

    DEFINE_DEVICE
    dvDVD_A		= 5001:9:0
    dvDVD_B		= 5001:10:0
    dvDVD_C		= 5001:11:0
    dvTP_DVD_115	= 10001:15:0
    dvTP_DVD_215	= 10002:15:0
    dvTP_DVD_315	= 10003:15:0
    dvTP_DVD_415	= 10004:15:0
    dvTP_DVD_116	= 10001:16:0
    dvTP_DVD_216	= 10002:16:0
    dvTP_DVD_316	= 10003:16:0
    dvTP_DVD_416	= 10004:16:0
    dvTP_DVD_117	= 10001:17:0
    dvTP_DVD_217	= 10002:17:0
    dvTP_DVD_317	= 10003:17:0
    dvTP_DVD_417	= 10004:17:0


    DEFINE_VARIABLE
    DEV dvaTP_DVD_15[] =
    {
	dvTP_DVD_115,
	dvTP_DVD_215,
	dvTP_DVD_315,
	dvTP_DVD_415
    }
    DEV dvaTP_DVD_16[] =
    {
	dvTP_DVD_116,
	dvTP_DVD_216,
	dvTP_DVD_316,
	dvTP_DVD_416
    }
    DEV dvaTP_DVD_17[] =
    {
	dvTP_DVD_117,
	dvTP_DVD_217,
	dvTP_DVD_317,
	dvTP_DVD_417
    }
    
    DEV dvaALL_DVD[]	= 
    {
	dvDVD_A,
	dvDVD_B,
	dvDVD_C
    }

    VOLATILE INTEGER nDVDTransportBtns[] =
    {
	TRANSPORT_PLAY,
	TRANSPORT_STOP,
	TRANSPORT_PAUSE,
	TRANSPORT_NEXT,
	TRANSPORT_PREV,
	TRANSPORT_FFWD,
	TRANSPORT_REW,
	TRANSPORT_REC
    }

#END_IF


//////////////////////////////////
////////////// CAMERA ////////////
//////////////////////////////////
#IF_DEFINED CONFIG_CAM
    DEFINE_DEVICE
    dvCAM1		= 5001:5:0
    dvCAM2		= 5001:6:0
    dvCAM3		= 5001:7:0
    dvTP_CAM_109	= 10001:9:0
    dvTP_CAM_209	= 10002:9:0

    DEFINE_CONSTANT
    //INTEGER viCAM	= vi_1


    /// What switcher input?
    CAM_1	= 9
    CAM_2	= 10
    CAM_3	= 11
	          
    INTEGER nCamInputs[] =
    {
	 CAM_1, 
	 CAM_2,
	 CAM_3
    }



    DEFINE_VARIABLE
    DEV dvaTP_CAM_09[] =
    {
	dvTP_CAM_109,
	dvTP_CAM_209
    }
    VOLATILE INTEGER nWhichCam[2]	= {1,3}	// [classroom, lab]
    VOLATILE INTEGER nWhichCamPreset
    VOLATILE INTEGER nCamPTZBtns[] =
    {
	PTZ_TILT_UP,
	PTZ_TILT_DOWN,
	PTZ_PAN_LEFT,
	PTZ_PAN_RIGHT,
	PTZ_ZOOM_IN,
	PTZ_ZOOM_OUT,
	CAM_FOCUS_IN,
	CAM_FOCUS_OUT,
	CAM_AUTO_FOC
    }
    VOLATILE INTEGER nCamPresetBtns[] =
    {
	401,402,403,404,405,406,407,408,409,410,411,412
    }

    DEV dvAllCams[CONFIG_CAM_NUMBER_CAMS] =
    {
	dvCAM1,
	dvCAM2,
	dvCAM3
    }


#END_IF



//////////////////////////////////
////////////// DOC CAM ///////////
//////////////////////////////////
#IF_DEFINED CONFIG_DOC_CAM
//    DEFINE_DEVICE
//    dvDocCam		= 5001:1:0
//    dvTP_DocCam_106	= 10001:6:0
//    vdvDocCam		= 41006:1:0
//
//    DEFINE_CONSTANT
//    //INTEGER viDOC_CAM		= vi_1
//    DOC_CAM_BTN_LIGHT_UP	= 198
//    DOC_CAM_BTN_LIGHT_LO	= 197
//
//    DEFINE_VARIABLE
//    DEV dvaTP_DocCam_06[] =
//    {
//	dvTP_DocCam_106
//    }
//
//    VOLATILE INTEGER nDocCamBtns[] =
//    {
//	PTZ_ZOOM_IN,
//	PTZ_ZOOM_OUT,
//	CAM_FOCUS_IN,
//	CAM_FOCUS_OUT,
//	CAM_IRIS_OPEN,
//	CAM_IRIS_CLOSE
//    }

#END_IF


//////////////////////////////////
////////////// CABLE TV //////////
//////////////////////////////////
#IF_DEFINED CONFIG_CABLE_TV
    DEFINE_DEVICE
    dvCATV		= 0:3:0
    dvTP_CATV_116	= 10001:16:0

    vdvCATV		= 31016:1:0

    DEFINE_CONSTANT
    INTEGER viCATV				= vi_3
    INTEGER CONFIG_CABLE_TV_NUMBER_TUNERS	= 1

    DEFINE_VARIABLE
    _sCATVPresets sCATVPresets[CONFIG_CABLE_TV_NUMBER_PRESETS]
    VOLATILE CHAR 	cCTV_IP[15]
    VOLATILE INTEGER 	nCTV_Port
    VOLATILE INTEGER 	nCTVMethod

    DEV dvaTP_CATV_16[] =
    {
	dvTP_CATV_116
    }

    INTEGER nTVPresetBtns[] =
    {
	301,302,303,304,305,306,307,308,309,310
    }

    INTEGER nTVPresetEditBtns[] =
    {
	1301,1302,1303,1304,1305,1306,1307,1308,1309,1310
    }

    DEFINE_START
    cCTV_IP	= '10.40.252.24';
    nCTV_Port	= 23;
    nCTVMethod  = IP_TCP;

    DEFINE_MODULE '_IP_Comm_Module' IP_CTV(dvCATV,cCTV_IP, nCTV_Port, nCTVMethod)

    DEFINE_EVENT

    DATA_EVENT[dvaTP_CATV_16]
    {
	ONLINE:
	{
	    LOCAL_VAR INTEGER x
	    WAIT 80
	    {
		FOR(x=1; x<=CONFIG_CABLE_TV_NUMBER_PRESETS; x++)
		{
		    SEND_COMMAND dvaTP_CATV_16, "'^BMF-', ITOA(nTVPresetBtns[x]), ',0,I%', ITOA(sCATVPresets[x].IconSlot)";
		    SEND_COMMAND dvaTP_CATV_16, "'^BMF-', ITOA(nTVPresetEditBtns[x]), ',0,I%', ITOA(sCATVPresets[x].IconSlot)";
		}
	    }
	}
    }

#END_IF



//////////////////////////////////
////////// PROJECTORS ////////////
//////////////////////////////////
#IF_DEFINED CONFIG_PROJECTOR
    DEFINE_DEVICE
    dvProjector_B	= 5001:4:0
    dvProjector_C	= 5001:5:0
    dvProjector_B2	= 5001:1:0
    dvTP_PRJ_B_218	= 10002:18:0
    dvTP_PRJ_B_418	= 10004:18:0
    dvTP_PRJ_B2_219	= 10002:19:0
    dvTP_PRJ_B2_419	= 10004:19:0
    dvTP_PRJ_C_318	= 10003:18:0
    dvTP_PRJ_C_418	= 10004:25:0

    vdvProjector_B	= 41218:1:0
    vdvProjector_B2	= 41219:1:0
    vdvProjector_C	= 41318:1:0

    DEFINE_CONSTANT
    INTEGER voPROJ_B	= vo_1
    INTEGER voPROJ_B2	= vo_4
    INTEGER voPROJ_C	= vo_2
    INTEGER LEFT_PROJ	= 1	// position in dev array + constant for identifying display in functions
    INTEGER RIGHT_PROJ	= 2

    DEFINE_VARIABLE
    
    DEFINE_VARIABLE

//    VOLATILE CHAR    cProj_IP[2][15]
//    VOLATILE INTEGER nProj_Port[2]
//    VOLATILE INTEGER nProjMethod[2]

    
    DEV dvaTP_PRJ_B_18[] =
    {
	dvTP_PRJ_B_218,
	dvTP_PRJ_B_418
    }
    DEV dvaTP_PRJ_B_19[] =
    {
	dvTP_PRJ_B2_219,
	dvTP_PRJ_B2_419
    }
    DEV dvaTP_PRJ_C_18[] =
    {
	dvTP_PRJ_C_318,
	dvTP_PRJ_C_418
    }

    // putting Projector B2 in the first slot of arrays so B/C constants match up to array positions
    DEV dva_ALL_PROJ[CONFIG_PROJECTOR_NUMBER_PROJECTORS]		=
    {
	dvProjector_B2,
	dvProjector_B,
	dvProjector_C
    }
    DEV vdva_ALL_PROJ[CONFIG_PROJECTOR_NUMBER_PROJECTORS]	=
    {
	vdvProjector_B2,
	vdvProjector_B,
	vdvProjector_C
    }
    DEVCHAN dcScreenUp[]	=
    {
	{dvRelay,8},	// B secondary (large screen for when B/C combined)
	{dvRelay,4},	// B Main
	{dvRelay,6}	// C 
    }
    DEVCHAN dcScreenDn[]	=
    {
	{dvRelay,7},	// B Secondary
	{dvRelay,3},	// B Main
	{dvRelay,5}	// C 
    }

//    DEFINE_START
//    cProj_IP[1]		= '192.168.5.7';
//    nProj_Port[1]	= 2017;
//    nProjMethod[1]	= IP_TCP
//    cProj_IP[2]		= '192.168.5.7';
//    nProj_Port[2]	= 2018;
//    nProjMethod[2]	= IP_TCP
//
//
//    DEFINE_MODULE '_IP_Comm_Module' ipConnProjL(dvProjector_L,cProj_IP[1], nProj_Port[1], nProjMethod[1])
//    DEFINE_MODULE '_IP_Comm_Module' ipConnProjR(dvProjector_R,cProj_IP[2], nProj_Port[2], nProjMethod[2])


#END_IF



//////////////////////////////////
////////// LED DISPLAYS //////////
//////////////////////////////////
#IF_DEFINED CONFIG_LED_DISPLAY
    DEFINE_DEVICE
    dvDisplay_A		 	= 5001:6:0
    dvTP_Displays_111		= 10001:11:0
    dvTP_Displays_411		= 10004:11:0
    
    vdvDisplay_A		= 41011:1:0

    DEFINE_CONSTANT
    INTEGER voDISP_A	= vo_3

    INTEGER LEFT_DISP	= 1	// position in dev array + constant for identifying display in functions
    INTEGER RIGHT_DISP	= 2




    DEFINE_VARIABLE


    DEV vdva_ALL_DISP[CONFIG_LED_DISPLAY_NUMBER_DISPLAYS]	=
    {
	vdvDisplay_A
    }

    DEV dva_ALL_DISP[CONFIG_LED_DISPLAY_NUMBER_DISPLAYS]	=
    {
	dvDisplay_A
    }

    DEV dvaTP_DISP_11[] =
    {
	dvTP_Displays_111,
	dvTP_Displays_411
    }



//    DEFINE_START
//    cConfDisp_IP	= '192.168.5.18';
//    nConfDisp_Port	= 2036;
//    nConfDispMethod	= IP_TCP
//
//    cVidWall_IP		= '192.168.5.18';
//    nVidWall_Port	= 2033;
//    nVidWallMethod	= IP_TCP
//
//    DEFINE_MODULE '_IP_Comm_Module' ipConnDSP(dvDisplay_Confidence,cConfDisp_IP, nConfDisp_Port, nConfDispMethod)
//    DEFINE_MODULE '_IP_Comm_Module' ipConnDSP(dvVidWall,cVidWall_IP, nVidWall_Port, nVidWallMethod)



#END_IF



//////////////////////////////////
////////// SMART BOARD ///////////
//////////////////////////////////
#IF_DEFINED CONFIG_SMART_BOARD
    DEFINE_DEVICE
    dvSmartBoard	= 5001:2:0
    dvTP_Smart_110	= 10001:10:0
    vdvSmartBoard	= 41010:1:0

    DEFINE_CONSTANT
    INTEGER voSMART	= vo_2

    DEFINE_VARIABLE
    DEV dvaTP_Smart_10[] =
    {
	dvTP_Smart_110
    }


#END_IF


//////////////////////////////////
////////////// LIGHTS ////////////
//////////////////////////////////
#IF_DEFINED CONFIG_LIGHTS
    DEFINE_DEVICE
    dvLIGHTS		= 5001:6:0
    dvTP_Lights_117	= 10001:17:0

    DEFINE_VARIABLE
    DEV dvaTP_Lights_17[] =
    {
	dvTP_Lights_117
    }
    VOLATILE INTEGER nWhichLightPreset
    VOLATILE CHAR cLightPresetNames[CONFIG_LIGHTS_NUMBER_PRESETS][25]	=
    {
	'Scene 1',
	'Scene 2',
	'Scene 3',
	'Scene 4'
    }
    VOLATILE INTEGER nLightPresetBtns[] =
    {
	101,102,103,104,105,106,107,108,109,110
    }

    VOLATILE CHAR cLightPresetStrings[CONFIG_LIGHTS_NUMBER_PRESETS][25] =
    {
	{$A5,$06,$85,$01,$DF,$F8},  // scene 1
	{$A5,$06,$85,$02,$DF,$FB},  // scene 2
	{$A5,$06,$85,$03,$DF,$FA},  // scene 3
	{$A5,$06,$85,$04,$DF,$FD}   // scene 4
    }

    DEFINE_EVENT

    DATA_EVENT[dvaTP_Lights_17]
    {
	ONLINE:
	{
	    LOCAL_VAR INTEGER x

	    WAIT 100
	    {
		FOR(x=1;x<=LENGTH_ARRAY(nLightPresetBtns);x++)
		    SEND_COMMAND dvaTP_Lights_17, "'^TXT-', ITOA(nLightPresetBtns[x]), ',0,', cLightPresetNames[x]";
	    }
	}
    }

    DATA_EVENT[dvLIGHTS]
    {
	ONLINE:
	{
	    SEND_COMMAND DATA.DEVICE, "'SET BAUD 115200,N,8,1'";
	}
    }

#END_IF



//////////////////////////////////
////////////// SHADES ////////////
//////////////////////////////////
#IF_DEFINED CONFIG_SHADES
    DEFINE_DEVICE
    dvShades		= 5001:5:151
    dvTP_Shades_105	= 10001:5:0
    //vdvShades		= 41005:1:151

    DEFINE_VARIABLE
    DEV dvaTP_Shades_05[] =
    {
	dvTP_Shades_105
    }

    VOLATILE CHAR cShadesDevID[10]	= '155000'

    VOLATILE INTEGER nWhichShadePreset
    VOLATILE CHAR cShadePresetNames[CONFIG_SHADES_NUMBER_PRESETS][25]	=
    {
	'Open',
	'25%',
	'50%',
	'75%',
	'Closed'
    }

    VOLATILE CHAR cShadePresetStrings[CONFIG_SHADES_NUMBER_PRESETS][25] =
    {
	{$AB,$F1,$FF,$15,$50,$00,$FF,$FF,$FF,$EF,$FF,$FF,$08,$EA},  //open
	{$AB,$F1,$FF,$15,$50,$00,$FF,$FF,$FF,$EF,$BF,$FF,$08,$AA},  // 25
	{$AB,$F1,$FF,$15,$50,$00,$FF,$FF,$FF,$EF,$80,$FF,$08,$6B},  // 50
	{$AB,$F1,$FF,$15,$50,$00,$FF,$FF,$FF,$EF,$40,$FF,$08,$2B},  // 75
	{$AB,$F1,$FF,$15,$50,$00,$FF,$FF,$FF,$EF,$00,$FF,$07,$EB}  // closed
    }

    VOLATILE INTEGER nShadePresetBtns[] =
    {
	101,102,103,104,105,106,107,108,109,110
    }

    DEFINE_EVENT
    DATA_EVENT[dvaTP_Shades_05]
    {
	ONLINE:
	{
	    LOCAL_VAR INTEGER x

	    WAIT 100
	    {
		FOR(x=1;x<=LENGTH_ARRAY(nShadePresetBtns);x++)
		    SEND_COMMAND dvaTP_Shades_05, "'^TXT-', ITOA(nShadePresetBtns[x]), ',0,', cShadePresetNames[x]";
	    }
	}
    }

#END_IF

//////////////////////////////////////////////////////////////////////////////////
//////////////                     INCLUDES  		 /////////////////////////
//////////////////////////////////////////////////////////////////////////////////

//#IF_DEFINED CONFIG_RMS
//    #INCLUDE '_RMS_Main';
//#END_IF
#IF_DEFINED CONFIG_SWITCHER
    #INCLUDE '_Switcher';
#END_IF
#IF_DEFINED CONFIG_DSP
    #INCLUDE '_DSP_Biamp';
#END_IF
#IF_DEFINED CONFIG_MACROS
    #INCLUDE '_RoutingMacros';
#END_IF
#IF_DEFINED CONFIG_VTC
    #INCLUDE '_VTCControl';
#END_IF
//#IF_DEFINED CONFIG_PHONE
//    #INCLUDE '_PhoneControl';
//#END_IF
#IF_DEFINED CONFIG_DVD
    #INCLUDE '_DVDControl';
#END_IF
#IF_DEFINED CONFIG_CAM
    #INCLUDE '_CamControl';
#END_IF
#IF_DEFINED CONFIG_DOC_CAM
    //#INCLUDE '_DocCamControl';
#END_IF
#IF_DEFINED CONFIG_CABLE_TV
    #INCLUDE '_CATVPresets';
    #INCLUDE '_CATVControl';
#END_IF
#IF_DEFINED CONFIG_PROJECTOR
    #INCLUDE '_ProjectorControl';
#END_IF
#IF_DEFINED CONFIG_LED_DISPLAY
    #INCLUDE '_DisplayControl';
#END_IF
#IF_DEFINED CONFIG_SMART_BOARD
    INCLUDE '_SmartBoard';
#END_IF
#IF_DEFINED CONFIG_LIGHTS
    INCLUDE '_Lights';
#END_IF
#IF_DEFINED CONFIG_SHADES
    INCLUDE '_Shades';
#END_IF



///  GENERIC SYSTEM STUFF ///
#INCLUDE '_GenericSystemFunctions';

/// OPERATOR CONTROLS ///
#INCLUDE '_OperatorPanel';


//////////////////////////////////////////////////////////////////////////////////
//////////////                     START 'ER UP		 /////////////////////////
//////////////////////////////////////////////////////////////////////////////////
DEFINE_START

//////////////////////////////
///////// SWITCHER ///////////
//////////////////////////////
#IF_DEFINED CONFIG_SWITCHER
  #WARN 'CONFIG MSG - MAKE SURE YOU HAVE POPULATED THE SWITCHER STRUCTURE';

    // Info
    sSwitcherInfo[1].Switcher_MFR				= 'Extron';
    sSwitcherInfo[1].Switcher_Model				= 'DXP 84';

    // Inputs
    sSwitcherInfo[1].Inputs[1].SourceName			= 'Floorbox 1 (C)';	
    sSwitcherInfo[1].Inputs[1].IconSlot				= SRC_ICON_SLOT_LAPTOP;
    sSwitcherInfo[1].Inputs[1].ControlPage			= 'Laptop';
    sSwitcherInfo[1].Inputs[1].HasAudio				= 1; 
    
    sSwitcherInfo[1].Inputs[2].SourceName			= 'Floorbox 2 (C)';
    sSwitcherInfo[1].Inputs[2].IconSlot				= SRC_ICON_SLOT_LAPTOP;
    sSwitcherInfo[1].Inputs[2].ControlPage			= 'Laptop';
    sSwitcherInfo[1].Inputs[2].HasAudio				= 2; 
    
    sSwitcherInfo[1].Inputs[3].SourceName			= 'Floorbox 3 (B)';
    sSwitcherInfo[1].Inputs[3].IconSlot				= SRC_ICON_SLOT_DESKTOP;
    sSwitcherInfo[1].Inputs[3].ControlPage			= 'Laptop';
    sSwitcherInfo[1].Inputs[3].HasAudio				= 3; 
    
    sSwitcherInfo[1].Inputs[4].SourceName			= 'Floorbox 4 (B)';
    sSwitcherInfo[1].Inputs[4].IconSlot				= SRC_ICON_SLOT_LAPTOP;
    sSwitcherInfo[1].Inputs[4].ControlPage			= 'Laptop';
    sSwitcherInfo[1].Inputs[4].HasAudio				= 4; 
    
    sSwitcherInfo[1].Inputs[5].SourceName			= 'Floorbox 5 (A)';
    sSwitcherInfo[1].Inputs[5].IconSlot				= SRC_ICON_SLOT_LAPTOP;    
    sSwitcherInfo[1].Inputs[5].ControlPage			= 'Laptop';
    sSwitcherInfo[1].Inputs[5].HasAudio				= 5; 


    sSwitcherInfo[1].Inputs[6].SourceName			= 'DVD A';	
    sSwitcherInfo[1].Inputs[6].IconSlot				= SRC_ICON_SLOT_DVD;
    sSwitcherInfo[1].Inputs[6].ControlPage			= 'DVD A';
    sSwitcherInfo[1].Inputs[6].HasAudio				= 6; 
    
    sSwitcherInfo[1].Inputs[7].SourceName			= 'DVD B';	
    sSwitcherInfo[1].Inputs[7].IconSlot				= SRC_ICON_SLOT_DVD;
    sSwitcherInfo[1].Inputs[7].ControlPage			= 'DVD B';
    sSwitcherInfo[1].Inputs[7].HasAudio				= 7; 

    sSwitcherInfo[1].Inputs[8].SourceName			= 'DVD C';	
    sSwitcherInfo[1].Inputs[8].IconSlot				= SRC_ICON_SLOT_DVD;
    sSwitcherInfo[1].Inputs[8].ControlPage			= 'DVD C';
    sSwitcherInfo[1].Inputs[8].HasAudio				= 8; 



    // Outputs

    sSwitcherInfo[1].Outputs[3].DestName	= 'Projector C';
    sSwitcherInfo[1].Outputs[3].IconSlot	= DST_ICON_SLOT_PROJ;
    sSwitcherInfo[1].Outputs[3].DestType	= DISP_TYPE_PROJ;
    sSwitcherInfo[1].Outputs[3].DestSide	= ROOM_C;

    sSwitcherInfo[1].Outputs[2].DestName	= 'Projector B';
    sSwitcherInfo[1].Outputs[2].IconSlot	= DST_ICON_SLOT_PROJ;
    sSwitcherInfo[1].Outputs[2].DestType	= DISP_TYPE_PROJ;
    sSwitcherInfo[1].Outputs[2].DestSide	= ROOM_B;

    sSwitcherInfo[1].Outputs[1].DestName	= 'Display A';
    sSwitcherInfo[1].Outputs[1].IconSlot	= DST_ICON_SLOT_DISP;
    sSwitcherInfo[1].Outputs[1].DestType	= DISP_TYPE_DISP;
    sSwitcherInfo[1].Outputs[1].DestSide	= ROOM_A;

    sSwitcherInfo[1].Outputs[4].DestName	= 'Projector B2';
    sSwitcherInfo[1].Outputs[4].IconSlot	= DST_ICON_SLOT_PROJ;
    sSwitcherInfo[1].Outputs[4].DestType	= DISP_TYPE_PROJ;
    sSwitcherInfo[1].Outputs[4].DestSide	= ROOM_B2;


#END_IF



//////////////////////////////
///////// MACROS   ///////////
//////////////////////////////
#IF_DEFINED CONFIG_MACROS
  #WARN 'CONFIG MSG - MAKE SURE YOU HAVE POPULATED THE MACROS STRUCTURE';

// VideoRoutes[1][x] = Classroom routes for macro 1; VideoRoutes[2][x] = lab routes


	sRoutingMacros[1].MacroName		= 'Presentation';
	sRoutingMacros[1].MacroDesc		= 'The PC input of your choosing will be routed to the display(s), and the associated audio will be heard in the room.';
	sRoutingMacros[1].IconSlot		= 0;
	sRoutingMacros[1].VideoRoutes[1][vo_1]	= vi_5;	// can use the source (vi) and dest (vo) constants here
	sRoutingMacros[1].VideoRoutes[1][vo_2]	= 0;
	sRoutingMacros[1].VideoRoutes[1][vo_3]	= 0;	// can use the source (vi) and dest (vo) constants here
	sRoutingMacros[1].VideoRoutes[1][vo_4]	= 0;
	sRoutingMacros[1].VideoRoutes[2][vo_1]	= 0;	// can use the source (vi) and dest (vo) constants here
	sRoutingMacros[1].VideoRoutes[2][vo_2]	= 0;
	sRoutingMacros[1].VideoRoutes[2][vo_3]	= 0;	// can use the source (vi) and dest (vo) constants here
	sRoutingMacros[1].VideoRoutes[2][vo_4]	= 0;
	sRoutingMacros[1].VideoRoutes[3][vo_1]	= 0;	// can use the source (vi) and dest (vo) constants here
	sRoutingMacros[1].VideoRoutes[3][vo_2]	= 0;
	sRoutingMacros[1].VideoRoutes[3][vo_3]	= 0;	// can use the source (vi) and dest (vo) constants here
	sRoutingMacros[1].VideoRoutes[3][vo_4]	= 0;

	sRoutingMacros[1].AudioSource[1]	= ai_5;
	sRoutingMacros[1].AudioSource[2]	= 0;
	sRoutingMacros[1].AudioSource[3]	= 0;


	sRoutingMacros[2].MacroName		= 'DVD';
	sRoutingMacros[2].MacroDesc		= 'The DVD player will be routed to the display(s) and DVD audio will be heard in the room.';
	sRoutingMacros[2].IconSlot		= 0;
	sRoutingMacros[2].VideoRoutes[1][vo_1]	= vi_6;	// can use the source (vi) and dest (vo) constants here
	sRoutingMacros[2].VideoRoutes[1][vo_2]	= 0;
	sRoutingMacros[2].VideoRoutes[1][vo_3]	= 0;	// can use the source (vi) and dest (vo) constants here
	sRoutingMacros[2].VideoRoutes[1][vo_4]	= 0;
	sRoutingMacros[2].VideoRoutes[2][vo_1]	= 0;	// can use the source (vi) and dest (vo) constants here
	sRoutingMacros[2].VideoRoutes[2][vo_2]	= vi_7;
	sRoutingMacros[2].VideoRoutes[2][vo_3]	= 0;	// can use the source (vi) and dest (vo) constants here
	sRoutingMacros[2].VideoRoutes[2][vo_4]	= 0;
	sRoutingMacros[2].VideoRoutes[3][vo_1]	= 0;	// can use the source (vi) and dest (vo) constants here
	sRoutingMacros[2].VideoRoutes[3][vo_2]	= 0;
	sRoutingMacros[2].VideoRoutes[3][vo_3]	= vi_8;	// can use the source (vi) and dest (vo) constants here
	sRoutingMacros[2].VideoRoutes[3][vo_4]	= 0;

	sRoutingMacros[2].AudioSource[1] 	= ai_6;
	sRoutingMacros[2].AudioSource[2] 	= ai_7;
	sRoutingMacros[2].AudioSource[3] 	= ai_8;
	//sRoutingMacros[2].AudioPreset		= 'Clear All'


#END_IF





//////////////////////////////
///////// CATV PRESETS ///////
//////////////////////////////
#IF_DEFINED CONFIG_CABLE_TV
    #WARN 'CONFIG MSG - MAKE SURE YOU HAVE POPULATED THE TV CHANNEL STRUCTURE';

    sCATVPresets[1].TVChannel	= '36-1';
    sCATVPresets[1].TVChanName	= 'ABC';
    sCATVPresets[1].IconSlot	= 301;
    sCATVPresets[2].TVChannel	= '48-2';
    sCATVPresets[2].TVChanName	= 'Bloomberg';
    sCATVPresets[2].IconSlot	= 302;
    sCATVPresets[3].TVChannel	= '36-2';
    sCATVPresets[3].TVChanName	= 'CBS';
    sCATVPresets[3].IconSlot	= 303;
    sCATVPresets[4].TVChannel	= '48-3';
    sCATVPresets[4].TVChanName	= 'CNBC';
    sCATVPresets[4].IconSlot	= 304;
    sCATVPresets[5].TVChannel	= '41-1';
    sCATVPresets[5].TVChanName	= 'ESPN';
    sCATVPresets[5].IconSlot	= 305;
    sCATVPresets[6].TVChannel	= '50-1';
    sCATVPresets[6].TVChanName	= 'Fox News';
    sCATVPresets[6].IconSlot	= 306;
    sCATVPresets[7].TVChannel	= '37-1';
    sCATVPresets[7].TVChanName	= 'Fox';
    sCATVPresets[7].IconSlot	= 307;
    sCATVPresets[8].TVChannel	= '50-3';
    sCATVPresets[8].TVChanName	= 'MSNBC';
    sCATVPresets[8].IconSlot	= 308;
    sCATVPresets[9].TVChannel	= '37-2';
    sCATVPresets[9].TVChanName	= 'NBC';
    sCATVPresets[9].IconSlot	= 309;


#END_IF




