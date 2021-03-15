

NB. -------------------------------------------------------------------------------------------------
NB. convert time code vector to text for output

NB. drop frame format hh:mm:ss;ff
fmt_dftc=: [: , 'q<:>r<0>3.0,q<:>r<0>3.0,q<;>r<0>3.0,r<0>2.0' 8!:2 ]

NB. non-drop frame format hh:mm:ss:ff
fmt_tc=: [: , 'q<:>r<0>3.0,q<:>r<0>3.0,q<:>r<0>3.0,r<0>2.0' 8!:2 ]

NB. as real time, frames converted to thousands of a second hh:mm:ss.sss  
fmt_time=: [: , 'q<:>r<0>3.0,q<:>r<0>3.0,r<0>6.3' 8!:2 ]



