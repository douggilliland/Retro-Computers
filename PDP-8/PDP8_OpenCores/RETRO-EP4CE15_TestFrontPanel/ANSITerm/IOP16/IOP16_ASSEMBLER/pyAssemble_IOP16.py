# IOP16 Assembler
#
# Input File Header
#	['LABEL', 'OPCODE', 'REG_LABEL', 'OFFSET_ADDR', 'COMMENT']
#
# Assembler opcodes
#	NOP - No operation
#	LRI - Load a register with an immediate value (byte)
#	IOW - Write a register to an I/O address
#	IOR - Read an I/O address to a register
#	ORI - OR a register with an immediate value
#	ARI - AND a register with an immediate value
#	JSR - Jump to a subroutine (single level only)
#	RTS - Return from subroutine
#	BEZ - Branch if equal to zero
#	BNZ - Branch if not equal to zero
#	JMP - Jump to an address
#

import csv
import string
import os
import sys
from sys import version_info

import time
from datetime import date

# Fix path below if imports fail
sys.path.append('C:\\Users\\HPz420\\Documents\\GitHub\\land-boards\\lb-Python-Code\\dgCommonModules\\TKDGCommon')

from dgProgDefaultsTk import *
from dgReadCSVtoListTk import *
from dgWriteListtoCSVTk import *

from tkinter import filedialog
from tkinter import *
from tkinter import messagebox

defaultPath = '.'

class ControlClass:
	"""Methods to read tindie or Kickstarter files and write out USPS and PayPal lists.
	"""
	def doConvert(self):
		"""The code that calls the other code
		"""
		global defaultPath
		defaultParmsClass = HandleDefault()
		defaultParmsClass.initDefaults()
		defaultPath = defaultParmsClass.getKeyVal('DEFAULT_PATH')
		# print '(doConvert): defaultPath',defaultPath
		myCSVFileReadClass = ReadCSVtoList()	# instantiate the class
		myCSVFileReadClass.setVerboseMode(False)	# turn on verbose mode until all is working 
		myCSVFileReadClass.setUseSnifferFlag(True)
		doneReading = False
		inList = myCSVFileReadClass.findOpenReadCSV(defaultPath,'Select ASM (CSV) File')	# read in TSV into list
		if inList == []:
			errorDialog("doConvert): No file selected")
			return
		defaultPath = myCSVFileReadClass.getLastPath()
		defaultParmsClass.storeKeyValuePair('DEFAULT_PATH',defaultPath)
		if inList[0] != ['LABEL', 'OPCODE', 'REG_LABEL', 'OFFSET_ADDR', 'COMMENT']:
			print('header does not match expected values')
			print('header :',inList[0])
			assert False,'header does not match expected values'
		else:
			print('header ok')
		inFileName = myCSVFileReadClass.getLastPathFileName()
		progCounter = 0
		labelsList = {}
		for row in inList[1:]:
			if row[0] != '':
				labelsList[row[0]] = progCounter
			progCounter += 1
		# print('labelsList',labelsList)
		program = []
		progCounter = 0
		for row in inList[1:]:
			# print(row)
			row[1] = row[1].upper()
			if row[1] != '':
				if row[1] == 'NOP':
					vecStr = '0x0000'				
					program.append(vecStr)
				elif row[1] == 'LRI':
					vecStr = '0x2'
					vecStr += row[2][-1]
					vecStr += row[3][-2:]
					program.append(vecStr)
				elif row[1] == 'IOR':
					vecStr = '0x6'
					vecStr += row[2][-1]
					vecStr += row[3][-2:]
					program.append(vecStr)
				elif row[1] == 'IOW':
					vecStr = '0x7'
					vecStr += row[2][-1]
					vecStr += row[3][-2:]
					program.append(vecStr)
				elif row[1] == 'ARI':
					vecStr = '0x8'
					vecStr += row[2][-1]
					vecStr += row[3][-2:]
					program.append(vecStr)
				elif row[1] == 'ORI':
					vecStr = '0x9'
					vecStr += row[2][-1]
					vecStr += row[3][-2:]
					program.append(vecStr)
				elif row[1] == 'BEZ':
					vecStr = '0xC'
					distance = labelsList[row[2]] - progCounter
					distance = labelsList[row[2]] - progCounter
					distStr = self.calcOffsetString(distance)
					vecStr += distStr
					program.append(vecStr)
				elif row[1] == 'BNZ':
					vecStr = '0xD'
					distance = labelsList[row[2]] - progCounter
					distStr = self.calcOffsetString(distance)
					vecStr += distStr
					program.append(vecStr)
				elif row[1] == 'JMP':
					vecStr = '0xE'
					distance = labelsList[row[2]]
					distStr = self.calcOffsetString(distance)
					vecStr += distStr
					program.append(vecStr)
				elif row[1] == 'JSR':
					vecStr = '0xA'
					distance = labelsList[row[2]]
					distStr = self.calcOffsetString(distance)
					vecStr += distStr
					program.append(vecStr)
				elif row[1] == 'RTS':
					vecStr = '0xB000'
					program.append(vecStr) 
				else:
					print('bad instr', row)
					assert False,'bad instr'
				progCounter += 1
		# print('program',program)
		annotatedSource = []
		progOffset = 0
		for rowOffset in range(len(inList)-1):
			# print(inList[rowOffset])
			annRow = []
			annRow.append(inList[rowOffset+1][0])
			if inList[rowOffset+1][1] != '':
				annRow.append(program[progOffset])
				progOffset += 1
			else:
				annRow.append('')
			annRow.append(inList[rowOffset+1][1])
			annRow.append(inList[rowOffset+1][2])
			annRow.append(inList[rowOffset+1][3])
			annRow.append(inList[rowOffset+1][4])
			#print(annRow)
			annotatedSource.append(annRow)		
		print('inFileName',inFileName)
		self.outStuff(inFileName,annotatedSource)
		errorDialog("Complete")
		
	def calcOffsetString(self,distanceInt):
		dresultStr = ''
		if distanceInt < 0:
			distanceInt = (distanceInt ^ 4095) + 1
		distStr = hex(distanceInt).upper()
		if distStr[0] == '-':	# -0xffe
			if len(distStr) == 6:
				return distStr[3:]
			elif len(distStr) == 5:
				return '0' + distStr[3:]
			elif len(distStr) == 4:
				return '00' + distStr[3:]
		else:	#0x000
			if len(distStr) == 5:
				return distStr[2:]
			elif len(distStr) == 4:
				return '0' + distStr[2:]
			elif len(distStr) == 3:
				return '00' + distStr[2:]
		# print('distance =',distStr)
		return distStr
	
	def outStuff(self,inFileName,sourceFile):
		"""
		[['LABEL', 'OPCODE', 'VAL4', 'VAL8', 'COMMENT'], ['INIT', 'NOP', '', '', ''], ['', 'LRI', '0X00', '0X01', 'LOAD START CMD'], ['', 'LRI', '0X01', '0X40', 'LOAD SLAVE ADDR<<1, WRITE'], ['', 'LRI', '0X02', '0X00', 'LOAD IDLE CMD'], ['', 'LRI', '0X03', '0X00', 'LOAD IODIRA REGISTER_OFFSET'], ['', 'LRI', '0X04', '0XFF', 'LOAD IODIRA_ALL_INS'], ['', 'IOW', '0X00', '0X00', 'ISSUE START CMD'], ['', 'IOW', '0X01', '0X00', 'ISSUE SLAVE ADDR<<1, WRITE'], ['', 'IOW', '0X02', '0X00', 'ISSUE IDLE CMD'], ['', 'IOW', '0X03', '0X00', 'ISSUE IODIRA REGISTER_OFFSET'], ['', 'IOW', '0X04', '0X00', 'ISSUE IODIRA_ALL_INS'], ['LDST000', 'IOR', '0X05', '0X00', 'READ STATUS'], ['', 'ARI', '0X05', '0X01', 'BUSY BIT'], ['', 'BNZ', '', 'LDST000', 'LOOP UNTIL NOT BUSY'], ['SELF', 'JMP', 'SELF', '', '']]
		"""
		outFilePathName = inFileName[0:-4] + '.mif'
		print('outFilePathName',outFilePathName)
		# for row in sourceFile:
			# print(row)
		outList = []
		outStr = '-- File: ' + outFilePathName
		outList.append(outStr)
		outList.append('-- Generated by pyAssemble_IOP16.py')
		outList.append('-- ')
		outLen = 0
		for row in sourceFile:
			if row[1] != '':
				outLen += 1
		outStr = 'DEPTH = '+ str(outLen) + ';'
		outList.append(outStr)
		outList.append('WIDTH = 16;')
		outList.append('ADDRESS_RADIX = DEC;')
		outList.append('DATA_RADIX = HEX;')
		outList.append('CONTENT BEGIN')
		lineCount = 0
		addrCount = 0
		outStr = ''
		# print('outList',outList)
#		assert False,'stop'
		for row in sourceFile:
			if row[1] != '':
				if lineCount == 0:
					outStr += str(addrCount)
					outStr += ': '
				outStr += row[1][2:]
				if lineCount < 7:
					outStr += ' '
				lineCount += 1
				addrCount += 1	
				if lineCount == 8:
					lineCount = 0
					outStr += ';'
					outList.append(outStr)
					outStr = ''
		if outStr != '':
			outStr = outStr[0:-1]
			outStr += ';'
			outList.append(outStr)
		
		outList.append('END;')
		# for line in outList:
			# print(line)

		F = open(outFilePathName, 'w')
		for row in outList:
			F.writelines(row+'\n')
		F.close()
		
		outFilePathName = outFilePathName[0:-4] + '.lst'
		F = open(outFilePathName, 'w')
		address = 0
		for row in sourceFile:
			hexAddr = hex(address)
			hexAddr = hexAddr[2:]
			if len(hexAddr) == 1:
				outStr = '00' + hexAddr + '\t'
			elif len(hexAddr) == 2:
				outStr = '0' + hexAddr + '\t'
			else:
				outStr = hexAddr + '\t'
			cellOff = 0
			ioRd = False
			ioWr = False
			for cell in row:
				if cell == '':
					outStr += '\t\t'
				else:
					if cellOff == 2:
						if cell == 'IOR':
							ioRd = True
						if cell == 'IOW':
							ioWr = True
					if cellOff == 3:
						if cell[0:2] == '0X':
							if cell[3:] == '8':
								outStr += '#0x00' + '\t'
							elif cell[3:] == '9':
								outStr += '#0x01' + '\t'
							elif cell[3:] == '9':
								outStr += '#0xFF' + '\t'
							else:
								outStr += 'Reg' + cell[3:] + '\t'
						else:
							outStr += cell + '\t'
					elif cellOff == 4:
						if not (ioRd or ioWr):
							outStr += cell + '\t'
						else:
							# if cell == '0X04':
								# outStr += 'I2C_DAT' + '\t'
							# elif (cell == '0X05') and ioRd:
								# outStr += 'I2C_STA' + '\t'
							# elif (cell == '0X05') and ioWr:
								# outStr += 'I2C_CTL' + '\t'
							# elif (cell == '0X00') and ioWr:
								# outStr += 'LEDS0' + '\t'
							# elif (cell == '0X01') and ioWr:
								# outStr += 'LEDS1' + '\t'
							# elif (cell == '0X02') and ioWr:
								# outStr += 'LEDS2' + '\t'
							# elif (cell == '0X02') and ioWr:
								# outStr += 'LEDS3' + '\t'
							# else:
								# outStr += 'TBDIO' + '\t'
							outStr += 'IO_' + cell[2:] + '\t'
					else:
						outStr += cell + '\t'
				cellOff += 1
			outStr += '\n'
			F.writelines(outStr)
			address += 1
		F.close()
			
class Dashboard:
	def __init__(self):
		self.win = Tk()
		self.win.geometry("320x240")
		self.win.title("IOP16 Assembler")

	def add_menu(self):
		self.mainmenu = Menu(self.win)
		self.win.config(menu=self.mainmenu)

		self.filemenu = Menu(self.mainmenu, tearoff=0)
		self.mainmenu.add_cascade(label="File",menu=self.filemenu)

		self.filemenu.add_command(label="Open asm file",command=control.doConvert)
		self.filemenu.add_separator()
		self.filemenu.add_command(label="Exit",command=self.win.quit)

		self.win.mainloop()
		
if __name__ == "__main__":
	if version_info.major != 3:
		errorDialog("Requires Python 3")
	control = ControlClass()
	x = Dashboard()
	x.add_menu()
