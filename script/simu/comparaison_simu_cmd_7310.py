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
comparaison_simu_cmd_7310.py

Created on Tue Jan 26 15:13:07 2021

@author: ATHENA_X-IFU


Script de comparaison entre le fichier en sortie du FPGA et le fichier de commande utilisé pour 
l'entrée du FPGA.
Test de vérification de correspondance entre ces deux fichiers pour vérifier que le FPGA se comporte 
correctement et sort les bons signaux.

ATTENTION : LA LECTURE DANS LE TEMPS ET LES INDEXS SONT DANS DES SENS INVERSES
TEMPS : <--
INDEX : -->
LES DERNIERS BITS DES SEQUENCES SE TROUVENT DONC EN DEBUT DE TABLEAU

V1 : Cette version ne gère que le changement de format du fichier de commande
Chaque bit de séquence est exprimé 20 fois, on ajoute un éventuel chevauchement et on fait la 
transposée pour que chaque ligne soit un instant t et chaque bit un pixel.

V2 : La fréquence de chaque bit doit être un paramètre.

V3 : L'ajout des valeurs de chevauchement ne fonctionne que dans un cas particulier. Changement du 
script pour que cela fonctionne dans chaque cas.
"""

import numpy as np

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
       
            array_seq_xfreq[i][freq_multip*j:freq_multip*(j+1)]=cmd[4+i][j] #chaque bit de la séquence est répété "freq_multip" fois
                
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
                    
                    array_seq_xfreq[i][j:j-REV]=0 #les "REV" bits après la séquence initiale sont mis à 1
                
    return(array_seq_xfreq)


def results_seq_search(nb_ligne, nb_bit, freq_multip, simu):

    """
    Cette fonction permet de construire la matrice avec les séquences de sortie utiles 

    Parameters
    ----------
    nb_ligne : int
        nombre de ligne
        
    nb_bit : int
        nombre de bit

    freq_multip : int
        nombre répétition de chaque bit de la séquence de départ  

    simu : list
        liste avec les séquences de sortie de simulation                        
    
    Returns
    -------
    results : array
        tableau avec les séquences utiles de la simulation

    """    

    i=0
    while i>=0:
        if simu[i]=='0000000000000\n':
            i+=1
        else :
            indice = i #on cherche l'indice à partir du quel on peut trouver la séquence utile
            i = -1
    # print(indice)

    results = np.empty([nb_bit*freq_multip,nb_ligne],  dtype=np.dtype('int'))

    for i in range(800):
    
        for j in range (13):

                results[i][j] = simu[indice + i][j] #on construit la matrice avec la séquence utile
                
    return(results)


def comparison_cmd_results(array_seq_xfreq_ov, results, nb_ligne, nb_bit, freq_multip):
    
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
    
    for i in range(nb_bit*freq_multip):
        
        for j in range(nb_ligne):
            
            compare = (results[i][(nb_ligne-1)-j]==array_seq_xfreq_ov[j][(nb_bit*freq_multip-1)-i]) & compare
            
                
        return compare 
            
    






""" 
Paramètres 
"""
freq_multip = 20 #nombre de répétition de chaque bit de la séquence de départ 
nb_ligne = 13
nb_bit = 40 


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

REV = 2
array_seq_xfreq_ov = overlap_addition(array_seq_xfreq,REV, freq_multip)
print('tableau commande avec overlap :',array_seq_xfreq_ov)


"""
Lecture du fichier de résultats
"""
simu_results = "sim_results.txt"
simu= read_file(simu_results)
# print(simu)


"""
Obtention des résultats exploitables
"""
results = results_seq_search(nb_ligne, nb_bit, freq_multip, simu)
print('resultats exploitables de simu :', results)

"""
Comparaison commandes et résultats de simulation
"""
comparison = comparison_cmd_results(array_seq_xfreq_ov, results, nb_ligne, nb_bit, freq_multip)
print('resultat de comparaison :', comparison)

