import random


def memory_init():
	num_blocks = 10
	block_size = 4
	width = 32
	maximum = 2 ** width - 1
	f = open(
		"C:/Users/emadz/Desktop/School/Books/Semester IV/Digital System Design/Project/Coprocessor/memory_tb_init.txt",
		"w")
	for _i in range(num_blocks):
		for _j in range(block_size):
			f.write(format(random.randint(0, maximum), 'x'))
			f.write('\n')
	f.close()
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

register_init()