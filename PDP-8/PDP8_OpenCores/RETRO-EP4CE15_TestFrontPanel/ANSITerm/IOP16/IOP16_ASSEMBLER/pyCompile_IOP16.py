# IOP16 Compiler
#
# Input File Header
#	['LABEL', 'COMMAND', 'I2C_ADDR', '23017_REG', 'VALUE', 'COMMENT']
#
# Macros
#	WI2C3_CONST	- Write a constant value to an MCP23017
#	RI2C3_REG	- Read a byte from an MCP23017 to a register
#	WI2C3_REG	- Wrie a register value to an MCP23017
#	HALT		- Jump to self
#
# Assembler pass-throughs
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

class CompileClass:
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
		inFileName = myCSVFileReadClass.getLastPathFileName()
		defaultPath = myCSVFileReadClass.getLastPath()
		defaultParmsClass.storeKeyValuePair('DEFAULT_PATH',defaultPath)
		if inList[0] != ['LABEL', 'COMMAND', 'I2C_ADDR', '23017_REG', 'VALUE', 'COMMENT']:
			print('header does not match expected values')
			print('header :',inList[0])
			assert False,'header does not match expected values'
		else:
			print('header ok')
		# print('inList',inList)
		outList = []
		# ['LABEL', 'COMMAND', 'I2C_ADDR', '23017_REG', 'VALUE', 'COMMENT']
		# ['WR001', 'WI2C3_CONST', '0X40', '0X00', '0XFF', 'SET IODIRA TO ALL_INS']
		# ['WR002', 'WI2C3_CONST', '0X40', '0X01', '0X00', 'SET IODIRB TO ALL_OUTS']
		# ['WR003', 'WI2C3_CONST', '0X40', '0X02', '0XFF', 'SET IPOLA TO INVERTED']
		# ['WR004', 'WI2C3_CONST', '0X40', '0X04', '0XFF', 'SET GPINTENA TO ENABLED']
		# ['WR005', 'WI2C3_CONST', '0X40', '0X05', '0X00', 'SET GPINTENB TO DISABLED']
		# ['WR006', 'WI2C3_CONST', '0X40', '0X06', '0X00', 'SET DEFVALA TO 0X00']
		# ['WR007', 'WI2C3_CONST', '0X40', '0X08', '0X00', 'SET INTCONA TO INTCON_PREVPIN']
		# ['WR008', 'WI2C3_CONST', '0X40', '0X0A', '0X04', 'SET IOCONA TO DISABLE SEQ']
		# ['WR009', 'WI2C3_CONST', '0X40', '0X0B', '0X04', 'SET IOCONB TO DISABLE SEQ']
		# ['WR010', 'WI2C3_CONST', '0X40', '0X0C', '0XFF', 'SET GPPUA TO PULLUPS']
		# ['WR011', 'WI2C3_CONST', '0X40', '0X15', '0X55', 'SET OLATB TO 0X55']
		for row in inList[1:]:
			# print(row)
			label = row[0]
			command = row[1]
			i2cAddr = row[2]
			mcpReg = row[3]
			mcpValue = row[4]
			comment = row[5]
			if command == 'WI2C3_CONST':
				# I2C_Ctrl = START
				outList.append([label,'IOW','0X09','0X05','ISSUE START COMMAND'])
				# I2C write command at slave address
				outList.append(['','LRI','0X00',i2cAddr,'LOAD I2C SLAVE ADDRESS TO CPU REG0'])
				outList.append(['','IOW','0X00','0X04','WRITE SLAVE ADDRESS TO CMD REG'])
				# WAIT TILL BUSY CLEARED
				outList.append([label + '_1','IOR','0X07','0X05','POLL I2C STATUS BUSY'])
				outList.append(['','ARI','0X07','0X01','MASK BUSY BIT'])
				outList.append(['','BNZ',label + '_1','','LOOP BACK IF STILL BUSY'])
				# WRITE I2C_Ctrl = IDLE = 0X00
				outList.append(['','IOW','0X08','0X05','ISSUE IDLE COMMAND'])
				# WRITE MCP REGISTER NUMBER TO I2C DATA REG
				outList.append(['','LRI','0X01',mcpReg,'LOAD MCP REGISTER NUMBER TO CPU REG1'])
				outList.append(['','IOW','0X01','0X04','WRITE MCP REGISTER TO MCP'])
				# WAIT TILL BUSY CLEARED
				outList.append([label + '_2','IOR','0X07','0X05','POLL I2C STATUS BUSY'])
				outList.append(['','ARI','0X07','0X01','MASK BUSY BIT'])
				outList.append(['','BNZ',label + '_2','','LOOP BACK IF STILL BUSY'])
				# WRITE I2C_Ctrl = STOP
				outList.append(['','LRI','0X01','0X03','STOP COMMAND VALUE'])
				outList.append(['','IOW','0X01','0X05','ISSUE STOP COMMAND'])
				# WRITE DATA VALUE TO MCP
				outList.append(['','LRI','0X01',mcpValue,'WRITE DATA TO REG'])
				outList.append(['','IOW','0X01','0X04','WRITE MCP REGISTER TO MCP'])
				# WAIT TILL BUSY CLEARED
				outList.append([label + '_3','IOR','0X07','0X05','POLL I2C STATUS BUSY'])
				outList.append(['','ARI','0X07','0X01','MASK BUSY BIT'])
				outList.append(['','BNZ',label + '_3','','LOOP BACK IF STILL BUSY'])
			elif command == 'RI2C3_REG':
				# FIX SLAVE ADDRESS FOR READS
				# print('i2cAddr',i2cAddr)
				lastChar = i2cAddr[len(i2cAddr)-1]
				# print('last char',lastChar)
				shortReg = i2cAddr[0:3]
				# print('shortReg',shortReg)
				if lastChar == '0':
					readI2CAddr = shortReg + '1'
				elif i2cAddr[len(i2cAddr)-1] == '2':
					readI2CAddr = shortReg + '3'
				elif i2cAddr[len(i2cAddr)-1] == '4':
					readI2CAddr = shortReg + '5'
				elif i2cAddr[len(i2cAddr)-1] == '6':
					readI2CAddr = shortReg + '7'
				elif i2cAddr[len(i2cAddr)-1] == '8':
					readI2CAddr = shortReg + '9'
				elif i2cAddr[len(i2cAddr)-1] == 'A':
					readI2CAddr = shortReg + 'B'
				elif i2cAddr[len(i2cAddr)-1] == 'C':
					readI2CAddr = shortReg + 'D'
				elif i2cAddr[len(i2cAddr)-1] == 'E':
					readI2CAddr = shortReg + 'F'
				# I2C_Ctrl = START
				outList.append([label,'IOW','0X09','0X05','ISSUE I2C START COMMAND'])
				# WRITE I2C SLAVE ADDRESS
				outList.append(['','LRI','0X00',i2cAddr,'LOAD I2C SLAVE ADDRESS TO CPU REG0'])
				outList.append(['','IOW','0X00','0X04','WRITE I2C SLAVE ADDRESS TO DATA REG'])
				# WAIT TILL BUSY CLEARED
				outList.append([label + '_1','IOR','0X07','0X05','POLL I2C STATUS BUSY'])
				outList.append(['','ARI','0X07','0X01','MASK BUSY BIT'])
				outList.append(['','BNZ',label + '_1','','LOOP BACK IF STILL BUSY'])
				# I2C_Ctrl = STOP
				outList.append(['','LRI','0X00','0X03','LOAD STOP COMMAND'])
				outList.append(['','IOW','0X00','0X05','ISSUE STOP COMMAND'])
				# WRITE MCP REGISTER NUMBER TO I2C DATA REG
				outList.append(['','LRI','0X00',mcpReg,'LOAD MCP REGISTER NUMBER TO CPU REG1'])
				outList.append(['','IOW','0X00','0X04','WRITE MCP REGISTER TO MCP'])
				# WAIT TILL BUSY CLEARED
				outList.append([label + '_2','IOR','0X07','0X05','POLL I2C STATUS BUSY'])
				outList.append(['','ARI','0X07','0X01','MASK BUSY BIT'])
				outList.append(['','BNZ',label + '_2','','LOOP BACK IF STILL BUSY'])
				# ISSUE START
				outList.append(['','IOW','0X09','0X05','ISSUE START COMMAND'])
				# I2C read command at slave address
				outList.append(['','LRI','0X00',readI2CAddr,'LOAD I2C READ SLAVE ADDRESS TO CPU REG0'])
				outList.append(['','IOW','0X00','0X04','WRITE SLAVE ADDRESS TO CMD REG'])
				# WAIT TILL BUSY CLEARED
				outList.append([label + '_3','IOR','0X07','0X05','POLL I2C STATUS BUSY'])
				outList.append(['','ARI','0X07','0X01','MASK BUSY BIT'])
				outList.append(['','BNZ',label + '_3','','LOOP BACK IF STILL BUSY'])
				# ISSUE IDLE
				outList.append(['','IOW','0X08','0X05','ISSUE IDLE COMMAND'])
				# Bogus write?
				outList.append(['','LRI','0X00','0X54','LOAD BOGUS WRITE'])
				outList.append(['','IOW','0X00','0X04','WRITE BOGUS'])
				# WAIT TILL BUSY CLEARED
				outList.append([label + '_4','IOR','0X07','0X05','POLL I2C STATUS BUSY'])
				outList.append(['','ARI','0X07','0X01','MASK BUSY BIT'])
				outList.append(['','BNZ',label + '_4','','LOOP BACK IF STILL BUSY'])
				# READ THE MCP REGISTER TO REGISTER
				outList.append(['','IOR','0X0' + mcpValue[-1],'0X04','READ MCP REGISTER TO REG'])
				# WAIT TILL BUSY CLEARED
				outList.append([label + '_5','IOR','0X07','0X05','POLL I2C STATUS BUSY'])
				outList.append(['','ARI','0X07','0X01','MASK BUSY BIT'])
				outList.append(['','BNZ',label + '_5','','LOOP BACK IF STILL BUSY'])
				# I2C_Ctrl = STOP
				outList.append(['','NOP','','',''])
				outList.append(['','LRI','0X00','0X03','STOP COMMAND'])
				outList.append(['','IOW','0X00','0X05','ISSUE STOP COMMAND'])
				outList.append(['','NOP','','',''])
			elif command == 'WI2C3_REG':
				if mcpValue[0].upper() != 'R':
					assert False,'need register nymber in mcpValue'
				# WRITE I2C_Ctrl = START (0X01)
				outList.append([label,'IOW','0X09','0X05','WRITE START'])
				# WRITE SLAVE ADDRESS TO DATA REG
				outList.append(['','LRI','0X00',i2cAddr,'LOAD I2C SLAVE ADDRESS TO CPU REG0'])
				outList.append(['','IOW','0X00','0X04','WRITE SLAVE ADDRESS TO CMD REG'])
				# WAIT TILL BUSY CLEARED
				outList.append([label + '_1','IOR','0X07','0X05','POLL I2C STATUS BUSY'])
				outList.append(['','ARI','0X07','0X01','MASK BUSY BIT'])
				outList.append(['','BNZ',label + '_1','','LOOP BACK IF STILL BUSY'])
				# WRITE I2C_Ctrl = IDLE = 0X00
				outList.append(['','IOW','0X08','0X05','ISSUE IDLE COMMAND'])
				# WRITE MCP REGISTER NUMBER TO I2C DATA REG
				outList.append(['','LRI','0X01',mcpReg,'LOAD MCP REGISTER NUMBER TO CPU REG1'])
				outList.append(['','IOW','0X01','0X04','WRITE REG1 TO MCP REGISTER'])
				# WAIT TILL BUSY CLEARED
				outList.append([label + '_2','IOR','0X07','0X05','POLL I2C STATUS BUSY'])
				outList.append(['','ARI','0X07','0X01','MASK BUSY BIT'])
				outList.append(['','BNZ',label + '_2','','LOOP BACK IF STILL BUSY'])
				# WRITE I2C_Ctrl = STOP
				outList.append(['','LRI','0X01','0X03','STOP COMMAND VALUE'])
				outList.append(['','IOW','0X01','0X05','ISSUE STOP COMMAND'])
				# WRITE REGISTER VALUE TO MCP
				outList.append(['','IOW','0X0' + mcpValue[1],'0X04','WRITE REG VALUE TO MCP'])
				# WAIT TILL BUSY CLEARED
				outList.append([label + '_3','IOR','0X07','0X05','POLL I2C STATUS BUSY'])
				outList.append(['','ARI','0X07','0X01','MASK BUSY BIT'])
				outList.append(['','BNZ',label + '_3','','LOOP BACK IF STILL BUSY'])
			elif command == 'HALT':
				outLine = []
				outLine.append('HALT')
				outLine.append('JMP')
				outLine.append('HALT')
				outLine.append('')
				outLine.append('LOOP FOREVER')
				outList.append(outLine)
			elif command == 'NOP':
				outList.append([label,command,i2cAddr,mcpReg,comment])
			elif command == 'LRI':
				outList.append([label,command,i2cAddr,mcpReg,comment])
			elif command == 'IOW':
				outList.append([label,command,i2cAddr,mcpReg,comment])
			elif command == 'IOR':
				outList.append([label,command,i2cAddr,mcpReg,comment])
			elif command == 'ORI':
				outList.append([label,command,i2cAddr,mcpReg,comment])
			elif command == 'ARI':
				outList.append([label,command,i2cAddr,mcpReg,comment])
			elif command == 'BEZ':
				outList.append([label,command,i2cAddr,mcpReg,comment])
			elif command == 'BNZ':
				outList.append([label,command,i2cAddr,mcpReg,comment])
			elif command == 'JMP':
				outList.append([label,command,i2cAddr,'',''])
			elif command == 'JSR':
				outList.append([label,command,i2cAddr,'',''])
			elif command == 'RTS':
				outList.append([label,command,i2cAddr,'',''])
			else:
				assert False,'bad command'
		# for row in outList:
			# print(row)
		outFileName = inFileName[0:-4] + '_out.csv'
		outHeader = ['LABEL', 'OPCODE', 'REG_LABEL', 'OFFSET_ADDR', 'COMMENT']
		outFileClass = WriteListtoCSV()
		outFileClass.writeOutList(outFileName, outHeader, outList)		
		errorDialog('Complete')
			
class Dashboard:
	def __init__(self):
		self.win = Tk()
		self.win.geometry("320x240")
		self.win.title("IOP16 Compiler")

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
	control = CompileClass()
	x = Dashboard()
	x.add_menu()
