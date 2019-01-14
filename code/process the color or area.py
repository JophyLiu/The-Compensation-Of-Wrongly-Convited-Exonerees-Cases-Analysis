# -*- coding: utf-8 -*-
"""
Created on Sun Apr  1 17:12:15 2018

@author: LIU
"""

import pandas as pd
import numpy as np


file=pd.read_excel('NRE_6210_S2018_V2.xls')
blue_state=pd.read_csv('blue.csv')
red_state=pd.read_csv('red.csv')


blue_state=blue_state['state']
red_state=red_state['state']

east=['Connecticut','Maine','Massachusetts','New Hampshire','Rhode Island','Vermont','New Jersey','New York','Pennsylvania']
west=['Arizona','Colorado','Idaho','Montana','Nevada','New Mexico','Utah','Wyoming','Alaska','California','Hawaii','Oregon','Washington']
south=['Delaware','District of Columbia','Florida','Georgia','Maryland','North Carolina''South Carolina','Virginia','West Virginia','Alabama','Kentucky','Mississippi','Tennessee','Arkansas','Louisiana','Oklahoma','Texas']
midwest=['Illinois','Indiana','Michigan','Ohio','Wisconsin','	Iowa','Kansas','Minnesota','Missouri','Nebraska','North Dakota','South Dakota']

red=[]
blue=[]

for i in range(0,23):
    blue.append(blue_state[i])

for i in range(0,31):
    red.append(red_state[i])
    

state=file['State']

for i in range(0,1901):
    if state[i] in east:
        state[i] ='east'
    elif state[i] in midwest:
        state[i] = 'midwest'
    elif state[i] in west:
        state[i] = 'west'
    else:
        state[i]= 'south'
        
        
for i in range(0,1901):
    if state[i] in red:
        state[i]='red'
    elif state[i] in blue:
        state[i]='blue'
        
file.to_csv('Area_1.csv',index=False)
file.to_excel('color_area_1.xls',index=False)

        

        
        


    
    
    
