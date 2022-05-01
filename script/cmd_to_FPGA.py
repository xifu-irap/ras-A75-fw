# -*- coding: utf-8 -*-
"""
Created on Fri May 21 14:20:41 2021

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
cmd_to_FPGA.py

Created on Wed May  5 10:29:32 2021

@author: ATHENA_X-IFU

Ce script permet de convertir les commandes de demande de lecture de registre au format binaire pour les envoyer au FPGA.
"""

import struct

def read(file):

    a=open(file, "r")

    cmd = a.readlines()
    
    a.close()
    
    return cmd

def write_bin(file, cmd_byte):

 
   """
   Cette fonction permet de convertir les commandes contenues dans le fichier et de les écrire dans le fichier binaire
   
       Parameters
    ----------
    file : file
        fichier dans lequel on écrit les commandes binaires
        
    cmd_byte : list
        commandes au format byte

    Returns
    -------
    
   """    

    a = open(file, "wb")
    
    for i in range(len(cmd_byte)):
        
        #byte = bin(int(cmd[i],2))
        
        a.write(struct.pack('H',int(cmd_byte[i],2)))
        
        
file_cmd = "config/HK_addr.txt"
cmd = read(file_cmd)


cmd_byte=[]
for i in range(len(cmd)):
    for j in range(4):
        cmd_byte.append(cmd[i][32-(j+1)*8:32-j*8])
print(cmd_byte)       

file_bin ="config/HK_addr_bin"
write_bin(file_bin,cmd_byte)