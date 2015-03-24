PROGRAM_NAME='_DisplayControl'
(***********************************************************)
(*  FILE CREATED ON: 06/12/2013  AT: 12:49:55              *)
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 07/03/2014  AT: 09:57:14        *)
(***********************************************************)

DEFINE_VARIABLE

VOLATILE INTEGER blnProjPwr



DEFINE_FUNCTION fnProjector(INTEGER nWhichProj, CHAR cProjFunc[])
{
    SWITCH(cProjFunc)
    {
	CASE 'ON':
	{
	    PULSE[dcScreenDn];
	    PULSE[dcProjLift_Dn];
	    WAIT 50
	    {
		PULSE[vdva_ALL_PROJ[nWhichProj],PWR_ON];
		SEND_STRING dva_ALL_PROJ[nWhichProj], "$02,$00,$00,$00,$00,$02";
	    }
	    
	}
	CASE 'OFF':
	{
	    PULSE[vdva_ALL_PROJ[nWhichProj],PWR_OFF];
	    SEND_STRING dva_ALL_PROJ[nWhichProj], "$02,$01,$00,$00,$00,$03";
	    PULSE[dcScreenUp];
	    WAIT 1200 PULSE[dcProjLift_Up];
	}
	CASE 'INPUT':
	{
	    PULSE[vdva_ALL_PROJ[nWhichProj],INPUT_TOG];		
	}
	CASE 'HDMI':
	{
	    SEND_COMMAND vdva_ALL_PROJ[nWhichProj], "'INPUT-HDMI,1'";
	    SEND_STRING dva_ALL_PROJ[nWhichProj], "$02,$03,$00,$00,$02,$01,$1A,$22";
	}
	DEFAULT:
	{
	    SEND_COMMAND vdva_ALL_PROJ[nWhichProj], "cProjFunc";
	}
    }
}


DEFINE_START

DEFINE_MODULE 'NEC_NPPA600X_Comm_dr1_0_0' commProj(vdvProjector,dvProjector);


DEFINE_EVENT

BUTTON_EVENT[dvaTP_PRJ_18,PWR_FB]
{
    PUSH:
    {
	//IF(blnProjPwr)
	IF([vdvProjector,PWR_FB])
	{
	    fnProjector(1,'OFF');
	}
	ELSE
	{
	    fnProjector(1,'ON');
	}
    }
}

BUTTON_EVENT[dvaTP_PRJ_18,1]  // screen up
BUTTON_EVENT[dvaTP_PRJ_18,2]  // screen down
{
    PUSH:
    {
	IF(BUTTON.INPUT.CHANNEL == 1) 	PULSE[dcScreenUp];
	ELSE				PULSE[dcScreenDn];
    }
}

BUTTON_EVENT[dvaTP_PRJ_18,3]  // lift up
BUTTON_EVENT[dvaTP_PRJ_18,4]  // lift down
{
    PUSH:
    {
	IF(BUTTON.INPUT.CHANNEL == 3) 	PULSE[dcProjLift_Up];
	ELSE				PULSE[dcProjLift_Dn];
    }
}


DEFINE_PROGRAM

//WAIT 300
//{
//    IF(![vdva_ALL_PROJ[1],199] || ![vdva_ALL_PROJ[2],199])
//    {
//	ON[vdva_ALL_PROJ,199];  // set vol mute on to prevent any audio passthru
//    }
//}

[dvaTP_PRJ_18,PWR_FB]		= [vdvProjector,PWR_FB];
