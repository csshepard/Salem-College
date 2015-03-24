PROGRAM_NAME='_DisplayControl'
(***********************************************************)
(*  FILE CREATED ON: 06/12/2013  AT: 12:49:55              *)
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 03/10/2014  AT: 10:08:16        *)
(***********************************************************)


(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_VARIABLE

VOLATILE INTEGER blnDisplayPwr
VOLATILE INTEGER blnVidWallPwr


DEFINE_FUNCTION fnMonitor(INTEGER nWhichDisp, CHAR cMonFunc[])
{
    SWITCH(cMonFunc)
    {
	CASE 'ON': 	
	{
	    SEND_STRING dva_ALL_DISP[nWhichDisp], "$01,$30,$41,$30,$41,$30,$43,$02,$43,$32,$30,$33,$44,$36,$30,$30,$30,$31,$03,$73,$0D";	    
	}
	CASE 'OFF': 	
	{
	    SEND_STRING dva_ALL_DISP[nWhichDisp], "$01,$30,$41,$30,$41,$30,$43,$02,$43,$32,$30,$33,$44,$36,$30,$30,$30,$34,$03,$76,$0D";
	}
	CASE 'HDMI':	SEND_STRING dva_ALL_DISP[nWhichDisp], "$01,$30,$41,$30,$45,$30,$41,$02,$30,$30,$36,$30,$30,$30,$31,$31,$03,$72,$0D";
	DEFAULT:	SEND_COMMAND vdva_ALL_DISP[nWhichDisp], "cMonFunc";
    }
}



DEFINE_FUNCTION fnVidWall(CHAR cMonFunc[])
{
    SWITCH(cMonFunc)
    {
	CASE 'ON': 	SEND_STRING dvVidWall, "$01,$30,$2A,$30,$41,$30,$43,$02,$43,$32,$30,$33,$44,$36,$30,$30,$30,$31,$03,$18,$0D";
	CASE 'OFF': 	SEND_STRING dvVidWall, "$01,$30,$2A,$30,$41,$30,$43,$02,$43,$32,$30,$33,$44,$36,$30,$30,$30,$34,$03,$1D,$0D";
	CASE 'FULL':
	{
	    // set the 4 tv's to HDMI
	    SEND_STRING dvVidWall, "$01,$30,$41,$30,$45,$30,$41,$02,$30,$30,$36,$30,$30,$30,$30,$33,$03,$71,$0D";  // dvi - tv 1
	    WAIT 10 SEND_STRING dvVidWall, "$01,$30,$42,$30,$45,$30,$41,$02,$30,$30,$36,$30,$30,$30,$30,$33,$03,$72,$0D";  // dvi - tv 2
	    WAIT 20 SEND_STRING dvVidWall, "$01,$30,$43,$30,$45,$30,$41,$02,$30,$30,$36,$30,$30,$30,$30,$33,$03,$73,$0D";  // dvi - tv 3
	    WAIT 30 SEND_STRING dvVidWall, "$01,$30,$44,$30,$45,$30,$41,$02,$30,$30,$36,$30,$30,$30,$30,$33,$03,$74,$0D";  // dvi - tv 4
	    
	    WAIT 50 SEND_STRING dvVidWall, "$01,$30,$2A,$30,$45,$30,$41,$02,$30,$32,$44,$33,$30,$30,$30,$32,$03,$68,$0D";  // tile matrix on
	
	}
    }
}



DEFINE_START




DEFINE_EVENT

DATA_EVENT[dva_ALL_DISP]
{
    ONLINE: SEND_COMMAND DATA.DEVICE, "'SET BAUD 9600,N,8,1'"; 
}

BUTTON_EVENT[dvaTP_DISP_11,PWR_FB]
{
    PUSH:
    {
	IF(blnDisplayPwr)
	{
	    fnMonitor(1,'OFF');
	    fnMonitor(2,'OFF');
	    fnMonitor(3,'OFF');
	    fnMonitor(4,'OFF');
	    fnMonitor(5,'OFF');
	    blnDisplayPwr = FALSE;
	} 
	ELSE
	{
	    fnMonitor(1,'ON');
	    fnMonitor(2,'ON');
	    fnMonitor(3,'ON');
	    fnMonitor(4,'ON');
	    fnMonitor(5,'ON');
	    blnDisplayPwr = TRUE;
	} 
	
    }
}

BUTTON_EVENT[dvaTP_VidWall_22,PWR_FB]
{
    PUSH:
    {
	IF(blnVidWallPwr)
	{
	    fnVidWall('OFF');
	    blnVidWallPwr = FALSE;
	} 
	ELSE
	{
	    fnVidWall('ON');
	    WAIT 100 fnVidWall('FULL');
	    blnVidWallPwr = TRUE;
	} 
	
    }
}




DEFINE_PROGRAM

[dvaTP_DISP_11,PWR_FB]		= blnDisplayPwr;
[dvaTP_VidWall_22,PWR_FB]	= blnVidWallPwr;
