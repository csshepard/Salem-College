PROGRAM_NAME='_DVDControl'
(***********************************************************)
(*  FILE CREATED ON: 06/18/2013  AT: 17:08:45              *)
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 04/23/2014  AT: 16:16:20        *)
(***********************************************************)


DEFINE_VARIABLE

///X CH MODE
INTEGER nXCHM = 0
/// SET PULSE TIME
INTEGER nPulseTime = 3



DEFINE_START

DEFINE_MODULE '_IR_Module' IRDev1(dvDVD_A,dvaTP_DVD_15,nXCHM,nPulseTime)
DEFINE_MODULE '_IR_Module' IRDev2(dvDVD_B,dvaTP_DVD_16,nXCHM,nPulseTime)
DEFINE_MODULE '_IR_Module' IRDev3(dvDVD_C,dvaTP_DVD_17,nXCHM,nPulseTime)

