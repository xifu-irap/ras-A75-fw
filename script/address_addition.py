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
address_addition.py

Created on Tue May 18 15:10:50 2021

@author: ATHENA_X-IFU

Cette fonction permet d'ajouter chaque adresse correspondante à la commande, on retrouve l'addresse du registre puis 32 bits de commande.

le fichier se construit de la façon suivante :
addr
data
addr
data
...

Pour la bonne construction du fichier il faut que les commandes soient dans l'ordre dans le fichier de départ pour que chaque commande soit attribuée à la bonne adresse

"""
#import numpy as np


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


def read_cmd(file):

    
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



def write_cmd(file, cmd, nb_bit):
    
    r"""

    This function writes addresses and commands in a file.

    

    Parameters
    
    

    ----------

    file : file

        File to write
        
        
    cmd : file

        List with the command to send to FPGA
        
    
    nb_bit : int
        
        Number of bit of each address and command


    Output

    ------
    
    """

    a = open(file, "w")
    
    for i in range(4):
        
        a.write(dec2natbin(i*4+1, nb_bit)+"\n") #writing the address
        a.write(cmd[i])#writing the command
            
    for j in range(13):
                
    # The sequences of the rows are on 40 its => we split it into one command of 32 bits and one of 8 bits with (32-8=24) 24 bits of '0' to obtain a command on 32 bits
       
        a.write(dec2natbin(16 + j*8 + 1, nb_bit)+"\n") #writing the address
        a.write(cmd[4 + j][8:40]+"\n") #writing the command
                
        a.write(dec2natbin(16 + j*8 + 4 + 1, nb_bit)+"\n")#writing the address
        a.write('000000000000000000000000'+cmd[4 + j][:8]+"\n") #writing the command
                 
    a.write(dec2natbin((4+13*2)*4 + 1, nb_bit)+"\n") #writing the address
    a.write(cmd[13+4]+"\n") #writing the command   

    a.close()     
                


nb_bit = 32

cmd_file = "cmd_9row4cluster.txt"
cmd = read_cmd(cmd_file)

cmd_addr_file = "cmd_addr_9row4cluster.txt"
write_cmd(cmd_addr_file, cmd, nb_bit)
