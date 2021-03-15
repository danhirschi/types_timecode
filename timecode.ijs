NB. init

coclass 'timecode'
NB. timecode - tools to convert video drop frame timecode and perform math 
NB. https://en.wikipedia.org/wiki/SMPTE_timecode#Drop-frame_timecode

NB. contributed by Dan Hirschi 2021


NB. -------------------------------------------------------------------------------------------------
NB. is a given frame a valid drop frame value
NB. x can be 29, 29.97, 59, or 59.94 with a default of 59.  
NB. y can be vector of 4 or a matrix of 4 rows

validdf=: 3 : 0  
59 validdf y
:
yy=. 4{. " 1 y,0 0$0
, -. (0 ~: 10 | 1{ " 1 yy) *. (0 = 2{ " 1 yy) *. ((i. (4 2 0) {~ 59 29 i. <. x) e.~ 3{ " 1 yy)
)

NB. -------------------------------------------------------------------------------------------------
NB. matrix of valid frames and corresponding frame value
NB. only 10 minutes need be computed (pattern repeats)

DFMAT59=: (] ,. [: <"0 [: i. #) < " 1 (] #~ 59 validdf ]) (60 60 60 60 #: ])  i.10*60*60
DFMAT29=: (] ,. [: <"0 [: i. #) < " 1 (] #~ 29 validdf ]) (60 60 60 30 #: ])  i.10*60*30

NB. allows 59 to be used instead of 59.94 (expressed as a rational number)	
FRAMERATES=: (] ,.~ <.) (30 * 1000r1001), (60 * 1000r1001), 30 60

FRAMERATESALT=: (] ,.~ <.) 29.97 59.94 30 60

NB. -------------------------------------------------------------------------------------------------

dftc_to_frame=: 3 : 0
59 dftc_to_frame y
:
r=. ''
if. -. x validdf y do. r return. end.
dfmat=. ; (59 29 i. <. x) { (<DFMAT59) , <DFMAT29
thr=. {. y
tmn=. 1 { y
tmp=. < _4{. (10 | tmn),  _2{. y
tfr1=. > 1{ dfmat {~ tmp i.~ 0{ " 1 dfmat
tfr2=. ((tmn <.@% 10) + 6 * thr) * # dfmat
tfr1 + tfr2
)

NB. -------------------------------------------------------------------------------------------------

dftc_from_frame=: 3 : 0
59 dftc_from_frame y
:
dfmat=. ; (59 29 i. <. x) { (<DFMAT59) , <DFMAT29
tmp10=. y <.@% # dfmat
tmpfr=. <y |~ # dfmat
t1=. 4 {. 60 60 #: 10 * tmp10
t2=. > 0{ dfmat {~ tmpfr i.~ 1{ " 1 dfmat
t1 + t2
)

NB. -------------------------------------------------------------------------------------------------
NB. input is ##:##:##:## with ; for drop frame and optional trailing @##.##   or ##:##:##.#######
NB. return is h m s f rate df

gettc=: 3 : 0
rt=. '59.94'
if. -. *./ '0123456789;:.@' e.~ y do. '' return. end.
if. '@' e.  y do. 'y rt'=. <;._1 '@', y end.
(4 {.!._ ([: (] ".;._2~ ';:' e.~ ]) ':' ,~ ]) y), (-. '.' e. y) * (". rt), ';' e. y
)

NB. -------------------------------------------------------------------------------------------------
NB. change frame nummber to seconds (useful for ffmpeg)

sec_from_frame=: 3 : 0
59 sec_from_frame y
:
(x:^:_1) y % (({. " 1 FRAMERATES) i. <. x) { {: " 1 FRAMERATES
)

NB. -------------------------------------------------------------------------------------------------
NB. change seconds to frame nummber

sec_to_frame=: 3 : 0
59 sec_to_frame y
:
<. (x:^:_1) y * (({. " 1 FRAMERATES) i. <. x) { {: " 1 FRAMERATES
)

NB. -------------------------------------------------------------------------------------------------
NB. change frame number to h m s.s (useful for some edit csv files)
NB. input is h m s f framerate(59 default)

dftc_to_time=: 3 : 0 
60 60 60 #: ({.!.59 ] 4}. y) sec_from_frame ({.!.59 ] 4}. y) dftc_to_frame 4 {. y
)


NB. -------------------------------------------------------------------------------------------------
NB. change frame number to h m s.s (useful for some edit csv files)   rounding to nearest thousandth
NB. input is h m s f framerate(59 default)

dftc_to_time_r=: 3 : 0 
60 60 60 #: ({.!.59 ] 4}. y) (1000 %~ [: (<.) 0.5 + 1000 * ]) sec_from_frame ({.!.59 ] 4}. y) dftc_to_frame 4 {. y
)


NB. -------------------------------------------------------------------------------------------------
NB. convert time code vector to text for output

NB. drop frame format hh:mm:ss;ff
fmt_dftc=: [: , 'q<:>r<0>3.0,q<:>r<0>3.0,q<;>r<0>3.0,r<0>2.0' 8!:2 ]

NB. non-drop frame format hh:mm:ss:ff
fmt_tc=: [: , 'q<:>r<0>3.0,q<:>r<0>3.0,q<:>r<0>3.0,r<0>2.0' 8!:2 ]

NB. as real time, frames converted to thousands of a second hh:mm:ss.sss  
fmt_time=: [: , 'q<:>r<0>3.0,q<:>r<0>3.0,r<0>6.3' 8!:2 ]



NB. zdefs

dftc_to_frame_z_=: dftc_to_frame_timecode_
dftc_from_frame_z_=: dftc_from_frame_timecode_
gettc_z_=: gettc_timecode_
sec_from_frame_z_=: sec_from_frame_timecode_
sec_to_frame_z_=: sec_to_frame_timecode_
dftc_to_time_z_=: dftc_to_time_timecode_
dftc_to_time_r_z_=: dftc_to_time_r_timecode_

fmt_dftc_z_=: fmt_dftc_timecode_
fmt_tc_z_=: fmt_tc_timecode_
fmt_time_z_=: fmt_time_timecode_

