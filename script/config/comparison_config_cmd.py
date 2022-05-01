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

Created on Tue Jun  8 16:07:09 2021

@author: ATHENA_X-IFU

This script manages the comparison between the cmd file and the results from the pipeout.
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


def write(file, cmd):

    a = open(file, "w")
    
    for i in range(len(cmd)):
        
        a.write(str(cmd[i])+"\n")
        
        # print(cmd[i])
        
    a.close()



def read_file(file):

    a=open(file, "r")

    b = a.readlines()

    a.close()
    
    return b

def tab_seq_xfreq(cmd, nb_ligne, nb_bit, freq_multip):
    
   """
   Cette fonction permet de créer un tableau où chaque ligne correspond à un pixel.
   Chaque bit de la séquence est répété pour atteindre une résolution suffisante.
   
       Parameters
    ----------
    cmd : list
        liste des séquences de chaque pixel
        
    nb_ligne : int
        valeur du nombre de ligne ( = nombre de pixel)
        
    nb_bit : int
        valeur du nombre de bit ( = nombre de pixel)

    Returns
    -------
    array_seq_xfreq : array
        tableau où chaque bit de la séquence est répété
    
   """
    
   array_seq_xfreq = np.empty([nb_ligne,freq_multip*nb_bit],  dtype=np.dtype('int')) #construction d'un tableau de 800 lignes de 40 entiers

   for i in range(nb_ligne): #on parcourt les lignes du fichier de commandes
    
        for j in range(nb_bit): #on parcourt chaque caractère de la ligne
       
            array_seq_xfreq[i][nb_bit*freq_multip-freq_multip*(j+1):nb_bit*freq_multip-freq_multip*j]=cmd[4+i][39-j] #chaque bit de la séquence est répété "freq_multip" fois
                
   return(array_seq_xfreq)  

def overlap_addition(array_seq_xfreq, REV, freq_multip):
    
    """
    Cette fonction permet d'ajouter les potentiels chevauchements 

    Parameters
    ----------
    array_seq_xfreq : array
        tableau où chaque bit de la séquence est répété
        
    REV : int
        valeur du chevauchement (= nombre de coup d'horloge à 100Mhz de chevauchement de 2 pixels)

    freq_multip : int
        nombre répétition de chaque bit de la séquence de départ                             
    
    Returns
    -------
    array_seq_xfreq_ov : array
        tableau où chaque bit de la séquence de cmd est répété
        un éventuel chevauchement entre 2 pixels est ajouté

    """
    
    for i in range(nb_ligne): #on parcourt les lignes
    
        for j in range(0, nb_bit*freq_multip, freq_multip): #on parcourt les bits par pas de "freq_multip" (les bits entre chaque pas sont égaux au bits de début de pas)
            
            if array_seq_xfreq[i][j] == 1 : #on cherche le moment où le pixel est actif (bit à 1)
            
                if REV >= 0 :
                
                    if j==0 : #cas particulier lorsque la séquence se trouve au début du tableau (on ne peut pas mettre en index[-x:y] il faut mettre que des positifs ou que des négatifs)
                        
                        array_seq_xfreq[i][nb_bit*freq_multip-REV:nb_bit*freq_multip]=1 #dans le cas particulier on met à 1 les deux derniers bits du tableau
                    
                    else:  #cas général
                    
                        array_seq_xfreq[i][j-REV:j]=1 #les "REV" bits après la séquence initiale sont mis à 1
                        
                else :
                    
                    array_seq_xfreq[i][j:j-REV]=0 #les "REV" bits à la fin de la séquence initiale sont mis à 0
                
    return(array_seq_xfreq)


def retourne_cmd(array_seq_xfreq_ov, nb_ligne, nb_bit, freq_multip):
       
    r"""

    Cette fonction permet de réarranger l'odre de la séquence pour pouvoir comparer directement les valeurs aux commandes de départ.

    Parameters

    ----------

    array_seq_xfreq_ov : array

        tableau où chaque bit de la séquence de cmd est répété
        un éventuel chevauchement entre 2 pixels est ajouté

    nb_ligne : int
        valeur du nombre de ligne ( = nombre de pixel)
        
    nb_bit : int
        valeur du nombre de bit ( = nombre de pixel)
        
    freq_multip : int
        nombre répétition de chaque bit de la séquence de départ  

    Output

    ------

    cmd_ret : array

        array_seq_xfreq_ov réarrangé pour être dans le bon ordre


    """
    
    cmd_ret = np.empty([freq_multip*nb_bit,nb_ligne],  dtype=np.dtype('int'))
    
    for j in range(nb_ligne) :
        
        for i in range(nb_bit*freq_multip) :
            
            cmd_ret[nb_bit*freq_multip-1-i][12-j] = array_seq_xfreq_ov[j][i]
    
    return cmd_ret


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



def comparison_cmd_results(cmd_ret, signals, nb_ligne, nb_bit, freq_multip):
    
    """
    Cette fonction permet de comparer les séquences envoyées en commande et les séquences en sortie de simulation 

    Parameters
    ----------
    array_seq_xfreq_ov : array
        tableau où chaque bit de la séquence de cmd est répété
        un éventuel chevauchement entre 2 pixels est ajouté 
    
    results : array
        tableau avec les séquences utiles de la simulation  
    
    nb_ligne : int
        nombre de ligne
        
    nb_bit : int
        nombre de bit

    freq_multip : int
        nombre répétition de chaque bit de la séquence de départ                  
    
    Returns
    -------
    compare : boolean
        résultat de comparaison entre les commandes et les résultats de simulation

    """     

    compare = True
    
    #test_sig = True
    
    for l in signals :
            
        if l != signals[0] :
            
            indice_signals = signals.index(l)
            
            break
    
    array_signals = np.empty([511,nb_ligne],  dtype=np.dtype('int'))   

    for i in range(511):
        
        for j in range(13) :
            
            array_signals[i][j] = signals[i][j]
    
    print('Array signal :', array_signals)
    
    for i in range(len(cmd_ret)) :
                
        if (array_signals[indice_signals]==cmd_ret[i]).all() :
            
            indice_cmd = i
            
            break

                
                
    
    print(indice_signals,indice_cmd)
    
    i = 0
    
    while compare == True :
        
        if i+indice_signals < 512 and i+indice_cmd < freq_multip * nb_bit  :
            
            compare = (array_signals[i+indice_signals]==cmd_ret[i+indice_cmd]).all() & compare
            
            i += 1
            
        elif i+indice_signals >= 512 and i+indice_cmd < freq_multip * nb_bit :
            
            for j in range(indice_signals):
                
                compare = (array_signals[j]==cmd_ret[i+indice_cmd]).all() & compare
                
                i += 1
                
        elif i+indice_signals < 511 and i+indice_cmd >= freq_multip * nb_bit  :
            
            for j in range(indice_cmd):
                
                if i+indice_signals < 511 :
                    
                    compare = (array_signals[i+indice_signals]==cmd_ret[j]).all() & compare
                    
                    if compare == False :
                        
                        erreur = cmd_ret[j]
                        
                        code_erreur = j
                        
                        print('pas ok', i+indice_signals, array_signals[i+indice_signals], erreur, code_erreur)
            
                        return compare
                        
                    else :
        
                        i += 1
                
        else :
            
            print('ok ', i)
            
            return(compare)
                
            
    print('pas ok', i+indice_signals)
            
    return compare
    
""" 
Paramètres  à saisir par l'utilisateur
"""
freq_row = 5 #exprimée en MHz
freq_multip = int(100/freq_row) #nombre de répétition de chaque bit de la séquence de départ 
nb_ligne = 13
nb_bit = 36 #lg séquence 
REV = 2


"""
Lecture du fichier de commande
"""
cmd_file = "../cmd_9row4cluster.txt"
cmd = read_file(cmd_file)
#print(cmd)


"""
Multiplication de l'apparition de chaque bit de la séquence
"""                
array_seq_xfreq = tab_seq_xfreq(cmd, nb_ligne, nb_bit, freq_multip)
#print(array_seq_xfreq)   


"""
Ajout du chevauchement
"""
array_seq_xfreq_ov = overlap_addition(array_seq_xfreq,REV, freq_multip)
#print('tableau commande avec overlap :',array_seq_xfreq_ov)


"""
Changement d'organisation de la matrice de commande
"""
cmd_ret = retourne_cmd(array_seq_xfreq_ov, nb_ligne, nb_bit, freq_multip)
print('commande retournées :', cmd_ret)


"""
Lecture du fichier de résultats en sortie du pipeout
"""
file_pipeout = "file_pipeout"

pipeout_sig_dec = read_output_pipeout(file_pipeout)
write("file_pipeout_dec.txt",pipeout_sig_dec)
pipeout_sig_bin = []
for i in range(len(pipeout_sig_dec)) :
    if pipeout_sig_dec[i] != 21760 :
        pipeout_sig_bin.append(dec2natbin(pipeout_sig_dec[i],13))
    

write("file_pipeout_bin.txt",pipeout_sig_bin)


sig_results = "file_pipeout_bin.txt"
signals= read_file(sig_results)
#print(signals)


"""
Comparaison commandes et résultats de simulation
"""
comparison = comparison_cmd_results(cmd_ret, signals, nb_ligne, nb_bit, freq_multip)
print('resultat de comparaison :', comparison)
