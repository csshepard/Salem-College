PROGRAM_NAME='_DisplayControl'
(***********************************************************)
(*  FILE CREATED ON: 06/12/2013  AT: 12:49:55              *)
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 07/01/2014  AT: 14:30:02        *)
(***********************************************************)


(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_VARIABLE

VOLATILE INTEGER blnDisplayPwr


DEFINE_FUNCTION fnMonitor(INTEGER nWhichDisp, CHAR cMonFunc[])
{
    SWITCH(cMonFunc)
    {
	CASE 'ON': 	
	{
	    //SEND_STRING dva_ALL_DISP[nWhichDisp], "$01,$30,$41,$30,$41,$30,$43,$02,$43,$32,$30,$33,$44,$36,$30,$30,$30,$31,$03,$73,$0D";	    
	    PULSE[vdvDisplay_A,PWR_ON];
	    WAIT 100 SEND_STRING dvDisplay_A, "$01,$30,$41,$30,$45,$30,$41,$02,$30,$30,$36,$30,$30,$30,$31,$31,$03,$72,$0D";  // hdmi
	}
	CASE 'OFF': 	
	{
	    //SEND_STRING dva_ALL_DISP[nWhichDisp], "$01,$30,$41,$30,$41,$30,$43,$02,$43,$32,$30,$33,$44,$36,$30,$30,$30,$34,$03,$76,$0D";
    	    PULSE[vdvDisplay_A,PWR_OFF];
	}
	CASE 'HDMI':	
	{
	    SEND_COMMAND vdvDisplay_A, "'INPUT-HDMI,1'";  // either the display is a piece of shit, or the module is, cuz it doesn't respond well to input changes
	    SEND_STRING dvDisplay_A, "$01,$30,$41,$30,$45,$30,$41,$02,$30,$30,$36,$30,$30,$30,$31,$31,$03,$72,$0D";  // hdmi
	}	    
	DEFAULT:	SEND_COMMAND vdva_ALL_DISP[nWhichDisp], "cMonFunc";
    }
}



DEFINE_START

DEFINE_MODULE 'NEC_P402_Comm_dr1_0_0' commDispA(vdvDisplay_A,dvDisplay_A);


DEFINE_EVENT

BUTTON_EVENT[dvaTP_DISP_11,PWR_FB]
{
    PUSH:
    {
	IF([vdvDisplay_A,PWR_FB])
	{
	    fnMonitor(ROOM_A,'OFF');
	} 
	ELSE
	{
	    fnMonitor(ROOM_A,'ON');
	} 
	
    }
}


DEFINE_PROGRAM

[dvaTP_DISP_11,PWR_FB]		= [vdvDisplay_A,PWR_FB];
