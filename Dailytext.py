#DOCUMENATION
# https://github.com/ponty/pyscreenshot/tree/2.2
# This script grabs the daily text from JW.org and sends the screen grab to your last reply on google voice. 
# Python 3.9 required.

import os
import sys
import webbrowser
import pyscreenshot as DailyTextBox
import pyautogui
import time



## Screenshot within specific bounds of the website
webbrowser.open('https://www.wol.jw.org')
time.sleep(10)
SS = DailyTextBox.grab(bbox=(980, 256, 1579, 686))
SS.save('DailyGrab.png')
time.sleep(10)
webbrowser.open('https://voice.google.com')
time.sleep(10)

## Send that screenshot in an email blast / text

pyautogui.click(230,262)
time.sleep(3)
pyautogui.click(498,1008)
time.sleep(3)
pyautogui.click(498,1008)
time.sleep(3)
pyautogui.click(768,326)
time.sleep(3)
pyautogui.click(914,677)
time.sleep(3)
pyautogui.click(926,361)
time.sleep(3)
pyautogui.click(840,47)
time.sleep(3)
pyautogui.write("DAILY")
time.sleep(3)
pyautogui.click(314,122)
time.sleep(3)
pyautogui.click(796,507)
time.sleep(3)
pyautogui.click(515,857)
time.sleep(3)
pyautogui.click(1534,1014)
time.sleep(10)



# os.system("taskkill /im opera.exe /f") # Feel free to edit program to kill
