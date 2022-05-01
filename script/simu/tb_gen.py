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
tb_gen.py

Created on Mon Feb 22 14:00:36 2021

@author: ATHENA_X-IFU

This script writes the Test Bench file for the Vivado simulation according to the commands
"""

def read_cmd(file):
    
    r"""

    This function reads files.


    Parameters
    ----------

    file : file
        File to read

    Output
    ------

    cmd : list
        List with the value of the file


    """

    a=open(file, "r") #opening of the file in reading mode

    cmd = a.readlines() #read of the file
    
    print(cmd)
    
    a.close() #closure of the file
    
    return cmd


def write_cmd(file, cmd, nb_bit):
    
    r"""

    This function write the commands and the addresses in the test bench file for the vivado simulation.


    Parameters
    ----------

    file : file
        File to write
        
    cmd : list
        List with the value of the commands
        
    nb_bit : int
        Number of bit of a command    

    Output
    ------


    """

    a = open(file, "w") #opening of the file in writing mode
    
    for m in range(3):
            
            for l in range(4):
                
                a.write("pipeIn("+str(l)+"):= \"00000000\";\n")
                
            a.write ("WriteToPipeIn(x\"80\",pipeInSize);\n")
        
            a.write ("wait for 10 ns;\n\n")
            
    a.write("---------------------------------\n\n")
    
    
    for i in range(len(cmd)): #we get each line of command/address
        
        if i%2==0 :
            
            a.write("-- W : Register address : "+ str((i)*2) +"\n")
            
        if i%2!=0 :
            
            a.write("-- W : Register cmd : "+ str((i)*2-2) +"\n")
        
        
            
        a.write("pipeIn("+str(0)+"):= \""+str(cmd[i][nb_bit-8:nb_bit])+"\" ;\n") #we split each command into 4 bytes
        a.write("pipeIn("+str(1)+"):= \"00000000\";\n")
        a.write("pipeIn("+str(2)+"):= \""+str(cmd[i][nb_bit-16:nb_bit-8])+"\" ;\n")
        a.write("pipeIn("+str(3)+"):= \"00000000\";\n")
        
        a.write ("WriteToPipeIn(x\"80\",pipeInSize);\n") #Write to Pipe In
        
        a.write ("wait for 10 ns;\n\n")
        
        a.write("pipeIn("+str(0)+"):= \""+str(cmd[i][nb_bit-24:nb_bit-16])+"\" ;\n") #we split each command into 4 bytes
        a.write("pipeIn("+str(1)+"):= \"00000000\";\n")
        a.write("pipeIn("+str(2)+"):= \""+str(cmd[i][nb_bit-32:nb_bit-24])+"\" ;\n")
        a.write("pipeIn("+str(3)+"):= \"00000000\";\n")
        
        a.write ("WriteToPipeIn(x\"80\",pipeInSize);\n") #Write to Pipe In
        
        a.write ("wait for 10 ns;\n\n")
        
        a.write("-- Addition of 64 bits = '0'\n") #Addition of the '0' (2*32 bits)
        
        for m in range(2):
            
            for l in range(4):
                
                a.write("pipeIn("+str(l)+"):= \"00000000\";\n")
                
            a.write ("WriteToPipeIn(x\"80\",pipeInSize);\n")
        
            a.write ("wait for 10 ns;\n\n")
            
        a.write("---------------------------------\n\n")
    
    a.write ("wait for 250 ns;\n\n")
    
    a.write ("ReadFromPipeOut(x\"A0\", 3000);\n\n") #Read from pipeout
    
    register_read = 1

    while register_read != "0" :    
    
        register_read = input("Do you want to read a register ? 1:yes 0:no") #Ask the user if he wants to read a register
        
        print(register_read)
        
        if register_read == "1" :
            
            register = int(input("Which register do you want to read ?"))
            
            a.write("-- R : Register address : "+ str(register) +"\n")
               
            a.write("pipeIn("+str(0)+"):= \""+str(dec2natbin(register,8*4)[nb_bit-8:nb_bit])+"\" ;\n") #write the address of the register to read in 4 bytes
            a.write("pipeIn("+str(1)+"):= \"00000000\";\n")
            a.write("pipeIn("+str(2)+"):= \""+str(dec2natbin(register,8*4)[nb_bit-16:nb_bit-8])+"\" ;\n")
            a.write("pipeIn("+str(3)+"):= \"00000000\";\n")

            a.write ("WriteToPipeIn(x\"80\",pipeInSize);\n") #write to pipe in
            
            a.write ("wait for 10 ns;\n\n")
            
            a.write("pipeIn("+str(0)+"):= \""+str(dec2natbin(register,8*4)[nb_bit-24:nb_bit-16])+"\" ;\n") #write the address of the register to read in 4 bytes
            a.write("pipeIn("+str(1)+"):= \"00000000\";\n")
            a.write("pipeIn("+str(2)+"):= \""+str(dec2natbin(register,8*4)[nb_bit-32:nb_bit-24])+"\" ;\n")
            a.write("pipeIn("+str(3)+"):= \"00000000\";\n")

            a.write ("WriteToPipeIn(x\"80\",pipeInSize);\n") #write to pipe in
            
            a.write ("wait for 10 ns;\n\n")
            
            a.write("-- Addition of 64 bits = '0'\n")
            
            for m in range(2):
            
                for l in range(4):
                    
                    a.write("pipeIn("+str(l)+"):= \"00000000\";\n")
                    
                a.write ("WriteToPipeIn(x\"80\",pipeInSize);\n")
            
                a.write ("wait for 10 ns;\n\n")
                
            a.write("---------------------------------\n")
    
    
    a.write ("ReadFromPipeOut(x\"A1\", 3000);\n\n") #read from pipe out
    
    a.close()


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




cmd_file = "../cmd_addr_9row4cluster.txt"
cmd = read_cmd(cmd_file) # read the command/address file

nb_bit = 32

cmd_addr_file = "tb_cmd.txt"
write_cmd(cmd_addr_file, cmd, nb_bit) # write addresses and commands in a tb file

filenames = ['tb_beginning.txt', 'tb_cmd.txt', 'tb_end.txt']
with open('../../sim/tb/row_addressing_tb.vhd', 'w') as outfile:
    for fname in filenames: #concatenate the Test bench file
        with open(fname) as infile:
            outfile.write(infile.read()) 