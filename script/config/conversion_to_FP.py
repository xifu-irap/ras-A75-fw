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
conversion_to_FP.py

Created on Wed May  5 10:29:32 2021

@author: ATHENA_X-IFU

This script converts the addresses and the commands into a binary file to send to FPGA.
"""

import struct

def read(file):
    
    r"""

    This function reads the file.

    

    Parameters
    
    

    ----------

    file : file

        File to read



    Output

    ------

    cmd : list

        List of the value from the file, command to send to FPGA

    """

    a=open(file, "r")

    cmd = a.readlines()
    
    a.close()
    
    return cmd

def write_bin(file, cmd):
    
    r"""

    This function reads the file.

    

    Parameters
    
    

    ----------

    file : file

        File to read
        
    cmd : list

        List of the value from the file, command to send to FPGA


    Output

    ------

    
    See Also
    
    ------
    
    cmd_byte : list

        Command of 32 bits to send to FPGA split into 4 bytes

    """
    cmd_byte=[]

    for i in range(len(cmd)): #we get each line of command/address
        
        for j in range(4):
            cmd_byte.append(cmd[i][32-(j+1)*8:32-j*8]) #we add to the list each byte of the command of 32 bits
        
        for j in range(4):
            cmd_byte.append('00000000') #we add 32 bits of '0' by bytes
  
    print(cmd_byte)
    
    a = open(file, "wb") #open the file in binary write mode
    
    for i in range(len(cmd_byte)):
        
        a.write(struct.pack('H',int(cmd_byte[i],2))) #we write each bytes of the list in binary
   

file_dec = "../cmd_addr_9row4cluster.txt"
cmd= read(file_dec) # read the file
print(cmd)
 

file_bin ="file_to_FPGA_9row4cluster"
write_bin(file_bin,cmd) #write the binary file to send to FPGA





