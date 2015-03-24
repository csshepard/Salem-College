PROGRAM_NAME='_DVDControl'
(***********************************************************)
(*  FILE CREATED ON: 06/18/2013  AT: 17:08:45              *)
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 06/18/2013  AT: 17:11:34        *)
(***********************************************************)


DEFINE_VARIABLE

///X CH MODE
INTEGER nXCHM = 0
/// SET PULSE TIME
INTEGER nPulseTime = 3


DEFINE_START

  
DEFINE_MODULE '_IR_Module' IRDev1(dvDVD,dvaTP_DVD_15,nXCHM,nPulseTime)

