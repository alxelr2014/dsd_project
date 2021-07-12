import random
import math
import numpy as np
from  CannonAlgoBU import CannonBotUp,ProcessingUnit
from FpArithmetic import FpArithmetic
def memory_init():
	a_row = 5
	b_row = 7
	b_col = 12
	num_processor = 1
	sub_matrix = 3
	con_lambda = math.ceil(a_row / sub_matrix)
	con_gamma = math.ceil(b_col / sub_matrix)
	con_mu = math.ceil(b_row / sub_matrix)
	con_theta = math.ceil( (con_lambda * con_gamma) / num_processor)

	fp = FpArithmetic(
		executable_path="C:/Users/emadz/Desktop/School/Books/Semester IV/Digital System Design/Project/GoldenModel/chromedriver.exe")
	lo, hi = int("0x10000000", 16), int("0x707fffff", 16)
	cannon = CannonBotUp(a_row, b_row, b_col,num_processor, sub_matrix ,lo ,hi, fp)
	config = format(con_theta, '02x') +  format(con_mu , '02x') +  format(con_gamma , '02x') +  format(con_lambda , '02x')
	status = "80000000"
	f = open(
		"C:/Users/emadz/Desktop/School/Books/Semester IV/Digital System Design/Project/Coprocessor/memory_tb_init.txt",
		"w")
	f.write(config + '\n')
	f.write(status + '\n')

	# print(cannon.partition(0))
	for _list in cannon.partition(0):
		for _sublist in _list:
			for _element in _sublist:
				f.write(format(int(_element), '08x') + '\n')
				print(format(int(_element), '08x'))
	for _list in cannon.partition(1):
		for _sublist in _list:
			for _element in _sublist:
				f.write(format(int(_element), '08x') + '\n')
				print(format(int(_element), '08x'))
	f.close()
	f = open(
		"C:/Users/emadz/Desktop/School/Books/Semester IV/Digital System Design/Project/Coprocessor/processor_tb_check.txt",
		"w")
	cannon.main_algo()
	print(cannon.matrix_c)
	for _list in cannon.partition(2):
		for _sublist in _list:
			for _element in _sublist:
				f.write(format(int(_element), '08x') + '\n')
				print(format(int(_element), '08x'))
	f.close()

	fp.close()
	print("Done")

def register_init():
	size = 6
	width = 32
	lo, hi = int("0x00800000",16), int("0x7f7fffff",16)
	f = open(
		"C:/Users/emadz/Desktop/School/Books/Semester IV/Digital System Design/Project/Coprocessor/register_tb_init.txt",
		"w")
	for _i in range(2*(size ** 2)):
			f.write(format(random.randint(lo, hi), 'x'))
			f.write('\n')
	for _i in range (size ** 2):
			f.write(format(0,'x'))
			f.write('\n')
	f.close()
	print("Done")


def block_mult():
	size = 3
	matrix_a = np.zeros((size,size))
	matrix_b = np.zeros((size,size))
	for _i in range(size):
		raw_input = input().split(" ")
		matrix_a[_i][:] = [int(_s, 16) for _s in raw_input]

	for _i in range(size):
		raw_input = input().split(" ")
		matrix_b[_i][:] = [int(_s, 16) for _s in raw_input]

	fp = FpArithmetic(
		executable_path="C:/Users/emadz/Desktop/School/Books/Semester IV/Digital System Design/Project/GoldenModel/chromedriver.exe")
	processor = ProcessingUnit(size,fp)
	matrix_c = processor.matrix_mult(matrix_a,matrix_b)

	for _i in range(size):
		for _j in range(size):
			print(format(int(matrix_c[_i][_j]),'08x') , end= " ")
		print()


def block_add():
	size = 3
	matrix_a = np.zeros((size, size))
	matrix_b = np.zeros((size, size))
	for _i in range(size):
		raw_input = input().split(" ")
		matrix_a[_i][:] = [int(_s, 16) for _s in raw_input]

	for _i in range(size):
		raw_input = input().split(" ")
		matrix_b[_i][:] = [int(_s, 16) for _s in raw_input]

	fp = FpArithmetic(
		executable_path="C:/Users/emadz/Desktop/School/Books/Semester IV/Digital System Design/Project/GoldenModel/chromedriver.exe")
	processor = ProcessingUnit(size, fp)
	matrix_c = processor.matrix_add(matrix_a, matrix_b)

	for _i in range(size):
		for _j in range(size):
			print(format(int(matrix_c[_i][_j]),'08x') , end= " ")
		print()
int_input = int(input())
if int_input == 0:
	block_add()
if int_input == 1:
	block_mult()