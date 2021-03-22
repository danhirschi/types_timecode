# types_timecode
tools for drop frame video timecode

---------------------------------------------
SMPTE video timecodes
---------------------------------------------

Video frames are numbered in the format hours:minutes:seconde:frames (01:00:23:04)

There are several frame rates possible.

Broadcast in the Americas uses a rate of about 29.97 frames per second (FPS), and with HDTV, an option to use 59.94 FPS.*

For timecode this is rounded up to 30 or 60 FPS to allow counting in frames.

If the frame rate is 30 (or 60) FPS, the time code will accurately reflect the real time elapsed.  

If the frame rate is 29.97 (or 59.94) FPS, the time code will will read less than the actual elapsed time.  When an hour has elapsed the timecode will read 00:59:56:12 (at 29.97 FPS). Or, conversely when the timecode reads 01:00:00:00, 1 hour, 3.5 seconds have elapsed.

This makes broadcasting to a schedule difficult (making sure a program will fit within a given time slot).

Drop frame time code was created to make the time code closer to actual elapsed time.

Numbers are dropped from the counting of frames.  The number of frames stays the same (107,892 per hour at 29.97 FPS), the labeling has changed.


Drop frame timecode skips frame numbers 0 and 1 of the first second of every minute, except when the number of minutes is divisible by ten.

(; is used before the frame element to denote drop frame time code)

A Sequence of four frames around 8 minutes.  (the frame label jumps from 00:07:59;29 to 00:08:00;02)

00:07:59;28
00:07:59;29
00:08:00;02
00:08:00;03


A Sequence of six frames around 10 minutes.  (these is no jump in the frame labels)
00:09:59;28
00:09:59;29
00:10:00;00
00:10:00;01
00:10:00;02
00:10:00;03

Timecode is used in edit decision lists (EDL) AsRun logs (documenting the time of broadcast elements in a playlist), 


Drop frame timecode is also defined for 59.94 FPS

00:07:59;58
00:07:59;59
00:08:00;04
00:08:00;05


00:09:59;58
00:09:59;59
00:10:00;00
00:10:00;01
00:10:00;02
00:10:00;03
00:10:00;04
00:10:00;05


---------------------------------------------
What this addon solves:
---------------------------------------------

Math can be a problem, requiring translating timecode to a frame number, doing any math (determining the length of a video segment, or finding in and out points), and converting back to timecode.  

Also, some software packages use real time to locate point within a video.  

This addon has functions to convert text timecode to a time vector, functions to convert timec code to frame number and back, a function to convert to actual time, and functions to formaat a J vector back to text.



---------------------------------------------
Text to timecode vector:
---------------------------------------------
This offers flexibility when parsing text sources.  

Edit Decision Lists (EDL) typically only have the timecode on each line.  Drop/Non-Drop Frame is often listed at the top.  ; for drop frame is not guaranteed
Some XML projects have the frame rate appended at the end.  ##:##:##:##@##.##
csv files for Dynamic Ad Insertion (DAI) often use time  ##:##:##:##.###

returned values are [hours], [minutes], [seconds], [frames], [frames per second, defaulting to 59.94], [drop frame flag, 1 or 0]   
   gettc '01:22:03:04'
1 22 3 4 59.94 0
   gettc '01:22:03:04@29.97'
1 22 3 4 29.97 0

   gettc '01:22:03;04'
1 22 3 4 59.94 1
   gettc '01:22:03;04@29.97'
1 22 3 4 29.97 1

if seconds include a decimal point, the return is [hours], [minutes], [seconds as floating point], [not used], [not used], [not used]
   gettc '01:22:03.040'
1 22 3.04 _ 0 0
   

---------------------------------------------
Converting to frame: 
---------------------------------------------
(only for drop frame timecode.  24 60 60 30 #. and 24 60 60 60 #. work for non-drop frame)

input is  [frames per second, defaulting to 59.94] dftc_to_frame [hours], [minutes], [seconds], [frames]
   59.94 dftc_to_frame 1 22 3 4 
295088
   29.94 dftc_to_frame 1 22 3 4 
147546

---------------------------------------------
Converting from frame:  
---------------------------------------------
(only for drop frame timecode.  24 60 60 30 #: and 24 60 60 60 #: work for non-drop frame)

input is  [frames per second, defaulting to 59.94] dftc_from_frame [frame number]
   59.94 dftc_from_frame 295088
1 22 3 4
   29.94 dftc_from_frame 147546
1 22 3 4

   fmt_dftc 59.94 dftc_from_frame 295088
01:22:03;04

In use:
---------------------------------------------

(add two 30-second elements)
   59.94 dftc_from_frame (59.94 dftc_to_frame 0 0 30 0) + 59.94 dftc_to_frame 0 0 30 0
0 1 0 4

(compute the length of an element that starts at 0 5 23 4 and ends at 0 7 12 4)
   59.94 dftc_from_frame (59.94 dftc_to_frame 0 7 12 4) - 59.94 dftc_to_frame 0 5 23 4 
0 1 48 56


---------------------------------------------
Converting to and from seconds:
---------------------------------------------

[frames per second, defaulting to 59.94] sec_from_frame [frame number]
[frames per second, defaulting to 59.94] sec_to_frame [time in seconds]


   0j5 ": sec_from_frame dftc_to_frame 0 1 30 0
90.02327

   0j5 ": sec_from_frame dftc_to_frame 0 3 0 4
180.04653
   0j5 ": sec_from_frame dftc_to_frame 0 2 59 59
180.02985
   0j5 ": sec_from_frame dftc_to_frame 0 2 59 58
180.01317
   0j5 ": sec_from_frame dftc_to_frame 0 2 59 57
179.99648

   dftc_from_frame sec_to_frame 180
0 2 59 57
   fmt_dftc dftc_from_frame sec_to_frame 180
00:02:59;57


---------------------------------------------
Converting to actual time:
---------------------------------------------

dftc_to_time [hours], [minutes], [seconds], [frames], [frames per second, defaulting to 59.94]

Rounds to nearest thousandth
dftc_to_time_r [hours], [minutes], [seconds], [frames], [frames per second, defaulting to 59.94]

   dftc_to_time 0 3 0 4
0 3 0.0465333
   dftc_to_time_r 0 3 0 4
0 3 0.047

   fmt_time dftc_to_time 0 3 0 4
00:03:00.047
   fmt_time dftc_to_time_r 0 3 0 4
00:03:00.047


---------------------------------------------
Formatting
---------------------------------------------

fmt_dftc    h m s f formatted for dropframe uses ;
fmt_tc      h m s f formatted for non-dropframe uses :
fmt_time    h m s.s formatted to thousandths




---------------------------------------------
* The actual frame rates are defined as 60 * 1000 / 1001 and 30 * 1000 / 1001.



