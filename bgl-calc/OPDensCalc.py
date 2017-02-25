# -*- coding: utf-8 -*-
"""
Created on Mon Feb 06 14:12:29 2017

@author: Ma'am Afzal
"""

# -*- coding: utf-8 -*-
"""
Created on Fri Feb 03 16:34:00 2017

@author: Ma'am Afzal
"""


import pandas as p
import math

    
def OPDensCalc(stabledur,heartrate,filename) :
    stable_dur=stabledur #if we are reading over the stable span of 30 s
    heart_rate=heartrate
    rows_per_sec=900
    rows_per_beat=(60/heart_rate)*rows_per_sec
    window_size=rows_per_beat #one beat
    #window_size=2
    offset=0
    window_boundary=rows_per_sec*stable_dur  #span of windows
    #window_boundary=5
    op_densdf=p.DataFrame()
    op_densdf=op_densdf.astype(float)
    for offset in xrange (offset,window_boundary-window_size,window_size):
        
        window_size+=offset
        results=p.read_csv(filename, skiprows=offset, nrows=window_size,usecols=[2,3,4,5],header=None,names=[ 'w1', 'w2','w3','noise'])  #returns panda dataframe [no.row *no of colums] # Prints "[[ 0.  0.]  [ 0.  0.]]"
        
        for column in results:
            #maxima is taken to be t+1, minima to be t 
            idmax=results[column].idxmax()   #id of row of maxima
            I_max=results.iloc[idmax][column]  #intensity of maxima
            noise_max=results.iloc[idmax]['noise'] #corresponding noise
            I_max=I_max-noise_max
            idmin=results[column].idxmin()
            I_min=results.iloc[idmin][column]
            noise_min=results.iloc[idmin]['noise']
            I_min=I_min-noise_min
            delta_I=I_max-I_min
            Optical_dens=math.log10(1+(delta_I/I_max))
            print (Optical_dens)
            data_elem= p.DataFrame({column:[Optical_dens ]},dtype=float) #another dataframe of calculated optical densities for each window in the stable duration corres each wavelength
            #print (data_elem)
            op_densdf=op_densdf.append(data_elem)
            
    del op_densdf['noise'] #delete noise column       
    #print(op_densdf.ix[:, op_densdf.columns != 'noise'])
    print(op_densdf)
    op_dens_means=op_densdf.mean(axis=0)
    print(op_dens_means)  


OPDensCalc(30,75,"data.csv")
