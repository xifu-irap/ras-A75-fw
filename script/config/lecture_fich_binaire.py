# -*- coding: utf-8 -*-
"""
Copyright (C) 2021-2030 Noémie ROLLAND, IRAP Toulouse.

This file is part of the ATHENA X-IFU DRE RAS.

ras-a75-fw is free software: you can redistribute it and/or modifyit under the terms of the GNU General Public 
License as published bythe Free Software Foundation, either version 3 of the License, or(at your option) any 
later version.

This program is distributed in the hope that it will be useful,but WITHOUT ANY WARRANTY; without even the 
implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See theGNU General Public License for 
more details.You should have received a copy of the GNU General Public Licensealong with this program.  

If not, see <https://www.gnu.org/licenses/>.

noemie.rolland@irap.omp.eu
lecture_fich_binaire.py

Created on Mon May 17 11:44:56 2021

@author: ATHENA_X-IFU
"""

import numpy as np

def dec2natbin(dec, n):

    r"""

    This function computes the natural binary value of a positive integer.

    

    Parameters
    
    

    ----------

    dec : number

        The decimal input integer to be converted

    n : number

        The number of bits of the output string



    Output

    ------

    bin_str : string

        The binary value in a string format



    Raises

    ------

    ValueError

        When n is too small to do the conversion



    See Also

    --------

    num : string to number conversion



    """

    bin_str = ''

    if dec >= 0:

        while n > 0:

            bin_str = str(dec % 2) + bin_str

            dec >>= 1

            n += -1

    if dec > 0:

        raise ValueError('Requested size is too small for this value')

    return bin_str


def read(file):
    
    r"""

    This function reads the output data directly from the xem3010.

    

    Parameters

    ----------

    file : 

        The file with the output values of the xem3010


    Output

    ------

    a : array

        Array with the decimal outputs of the xem3010


    """

    a = np.fromfile(file, dtype=np.uint16) #construct an array of data from the binary file

    print("Values from cmd: {0}".format(a))
    
    return a


def write(file, cmd):

    a = open(file, "w")
    
    for i in range(len(cmd)):
        
        a.write(str(cmd[i])+"\n")
        
        # print(cmd[i])
        
    a.close()
    
def read_output_pipeout(file):
    
    r"""

    This function reads the output data directly from the xem3010.

    

    Parameters

    ----------

    file : 

        The file with the output values of the xem3010


    Output

    ------

    a : array

        Array with the decimal outputs of the xem3010


    """

    a = np.fromfile(file, dtype=np.uint16) #construct an array of data from the binary file

    print("Values from FPGA: {0}".format(a))
    
    return a


# file_bin = "file_to_FPGA_9row4cluster"
# lecture = read(file_bin)

# write("file_to_FPGA_9row4cluster_dec.txt",lecture)

file_pipeout = "file_pipeout"

pipeout_sig_dec = read_output_pipeout(file_pipeout)
write("file_pipeout_dec.txt",pipeout_sig_dec)
pipeout_sig_bin = []
for i in range(len(pipeout_sig_dec)) :
    if pipeout_sig_dec[i] != 21760 :
        pipeout_sig_bin.append(dec2natbin(pipeout_sig_dec[i],13))
    

write("file_pipeout_bin.txt",pipeout_sig_bin)

file_HK = "HK"

pipeout_HK_dec = read_output_pipeout(file_HK)

pipeout_HK_bin = []
for i in range(len(pipeout_HK_dec)) :
     # if pipeout_sig_dec[i] != 0 :
    pipeout_HK_bin.append(dec2natbin(pipeout_HK_dec[i],32))
    
write("file_HK_dec.txt",pipeout_HK_dec)
write("file_HK_bin.txt",pipeout_HK_bin)

# file = "file_to_FPGA_9row4cluster"
# write("file_to_FPGA_9row4cluster_dec.txt",read_output_pipeout(file))





