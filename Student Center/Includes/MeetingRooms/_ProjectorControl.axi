PROGRAM_NAME='_DisplayControl'
(***********************************************************)
(*  FILE CREATED ON: 06/12/2013  AT: 12:49:55              *)
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 05/22/2014  AT: 15:23:23        *)
(***********************************************************)

DEFINE_VARIABLE

VOLATILE INTEGER blnProjPwr



DEFINE_FUNCTION fnProjector(INTEGER nWhichProj, CHAR cProjFunc[])
{
    SWITCH(cProjFunc)
    {
	CASE 'ON':
	{
	    PULSE[vdva_ALL_PROJ[nWhichProj],PWR_ON];
	    SEND_STRING dva_ALL_PROJ[nWhichProj], "$02,$00,$00,$00,$00,$02";
	    PULSE[dcScreenDn[nWhichProj]];
	}
	CASE 'OFF':
	{
	    PULSE[vdva_ALL_PROJ[nWhichProj],PWR_OFF];
	    SEND_STRING dva_ALL_PROJ[nWhichProj], "$02,$01,$00,$00,$00,$03";
	    SEND_STRING dva_ALL_PROJ[nWhichProj], "$02,$01,$00,$00,$00,$03";
	    PULSE[dcScreenUp[nWhichProj]];
	}
	CASE 'INPUT':
	{
	    PULSE[vdva_ALL_PROJ[nWhichProj],INPUT_TOG];		
	}
	CASE 'HDMI':
	{
	    SEND_STRING dva_ALL_PROJ[nWhichProj], "$02,$03,$00,$00,$02,$01,$1A,$22";
	}
	DEFAULT:
	{
	    SEND_COMMAND vdva_ALL_PROJ[nWhichProj], "cProjFunc";
	}
    }
}


DEFINE_START

DEFINE_MODULE 'NEC_NPPA600X_Comm_dr1_0_0' commProjB(vdvProjector_B,dvProjector_B);
DEFINE_MODULE 'NEC_NPPA600X_Comm_dr1_0_0' commProjB2(vdvProjector_B2,dvProjector_B2);
DEFINE_MODULE 'NEC_NPPA600X_Comm_dr1_0_0' commProjC(vdvProjector_C,dvProjector_C);



DEFINE_EVENT

DATA_EVENT[vdva_ALL_PROJ]
{
    COMMAND:
    {
	IF(REMOVE_STRING(DATA.TEXT, 'LAMPTIME-',1) == 'LAMPTIME-')
	{
	    IF(ATOI(DATA.TEXT) < 10000)  // this will avoid posting the weird numbers the module throws out when it can't read status from proj
	    {
		SWITCH(DATA.DEVICE)
		{
		    CASE vdvProjector_B2: SEND_COMMAND dvaTP_PRJ_B_19, "'^TXT-1000,0,', DATA.TEXT";
		    CASE vdvProjector_B:  SEND_COMMAND dvaTP_PRJ_B_18, "'^TXT-1000,0,', DATA.TEXT";
		    CASE vdvProjector_C:  SEND_COMMAND dvaTP_PRJ_C_18, "'^TXT-1000,0,', DATA.TEXT";
		}
	    }
	}
    }
}


BUTTON_EVENT[dvaTP_PRJ_B_18,PWR_FB]
{
    PUSH:
    {
	IF([vdvProjector_B,PWR_FB])
	{
	    fnProjector(ROOM_B,'OFF');
	}
	ELSE
	{
	    fnProjector(ROOM_B,'ON');
	}
    }
}


BUTTON_EVENT[dvaTP_PRJ_B_18,1]  // screen up
BUTTON_EVENT[dvaTP_PRJ_B_18,2]  // screen down
{
    PUSH: 
    {
	IF(BUTTON.INPUT.CHANNEL == 1) 	PULSE[dcScreenUp[ROOM_B]];
	ELSE				PULSE[dcScreenDn[ROOM_B]];
    }
}


BUTTON_EVENT[dvaTP_PRJ_B_19,PWR_FB]
{
    PUSH:
    {
	IF([vdvProjector_B2,PWR_FB])
	{
	    fnProjector(ROOM_B2,'OFF');
	}
	ELSE
	{
	    fnProjector(ROOM_B2,'ON');
	}
    }
}

BUTTON_EVENT[dvaTP_PRJ_B_19,1]  // screen up
BUTTON_EVENT[dvaTP_PRJ_B_19,2]  // screen down
{
    PUSH: 
    {
	IF(BUTTON.INPUT.CHANNEL == 1) 	PULSE[dcScreenUp[ROOM_B2]];
	ELSE				PULSE[dcScreenDn[ROOM_B2]];
    }
}



BUTTON_EVENT[dvaTP_PRJ_C_18,PWR_FB]
BUTTON_EVENT[10003:25:0,PWR_FB]
{
    PUSH:
    {
	IF([vdvProjector_C,PWR_FB])
	{
	    fnProjector(ROOM_C,'OFF');
	}
	ELSE
	{
	    fnProjector(ROOM_C,'ON');
	}
    }
}

BUTTON_EVENT[dvaTP_PRJ_C_18,1]  // screen up
BUTTON_EVENT[dvaTP_PRJ_C_18,2]  // screen down
{
    PUSH: 
    {
	IF(BUTTON.INPUT.CHANNEL == 1) 	PULSE[dcScreenUp[ROOM_C]];
	ELSE				PULSE[dcScreenDn[ROOM_C]];
    }
}




DEFINE_PROGRAM

WAIT 1200 SEND_COMMAND vdva_ALL_PROJ, "'?LAMPTIME'";

[dvaTP_PRJ_B_18,PWR_FB]		= [vdvProjector_B,PWR_FB];
[dvaTP_PRJ_B_19,PWR_FB]		= [vdvProjector_B2,PWR_FB];
[dvaTP_PRJ_C_18,PWR_FB]		= [vdvProjector_C,PWR_FB];
[10003:25:0,PWR_FB]		= [vdvProjector_C,PWR_FB];