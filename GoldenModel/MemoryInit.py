import random
import math
import numpy as np
from CannonAlgoBU import CannonBotUp, ProcessingUnit
from FpArithmetic import FpArithmetic
import linecache

ABSOLUTE_PATH = "C:/Users/emadz/Desktop/School/Books/Semester IV/Digital System Design/Project/"
RELATIVE_PATH = "test/" # "GoldenModel/" #
def memory_init():
    a_row = 5
    b_row = 5
    b_col = 5
    num_processor = 1
    sub_matrix = 3
    con_lambda = math.ceil(a_row / sub_matrix)
    con_gamma = math.ceil(b_col / sub_matrix)
    con_mu = math.ceil(b_row / sub_matrix)
    con_theta = math.ceil((con_lambda * con_gamma) / num_processor)

    fp = FpArithmetic(
        executable_path= ABSOLUTE_PATH +  "GoldenModel/chromedriver.exe")
    lo, hi = int("0x38D1B717", 16), int("0x42C80000", 16)
    cannon = CannonBotUp(a_row, b_row, b_col,
                         num_processor, sub_matrix, lo, hi, fp)
    config = format(con_theta, '02x') + format(con_mu, '02x') + \
        format(con_gamma, '02x') + format(con_lambda, '02x')
    status = "80000000"
    print(cannon.test())

    f = open(
        ABSOLUTE_PATH + RELATIVE_PATH + "memory_tb_init.txt",
        "w")
    f.write(config + '\n')
    f.write(status + '\n')

    # print(cannon.partition(0))
    for _list in cannon.partition(0):
        for _sublist in _list:
            for _element in _sublist:
                f.write(format(int(_element), '08x') + '\n')
                # print(format(int(_element), '08x'))
    for _list in cannon.partition(1):
        for _sublist in _list:
            for _element in _sublist:
                f.write(format(int(_element), '08x') + '\n')
                # print(format(int(_element), '08x'))
    f.close()
    f = open(
        ABSOLUTE_PATH + RELATIVE_PATH + "processor_tb_check.txt",
        "w")
    cannon.main_algo()
    for _list in cannon.partition(2):
        for _sublist in _list:
            for _element in _sublist:
                f.write(format(int(_element), '08x') + '\n')
                # print(format(int(_element), '08x'))
    f.close()

    f = open(
        ABSOLUTE_PATH + RELATIVE_PATH + "mem_visual.txt",
        "w")

    for _list in cannon.partition(0):
        for _sublist in _list:
            for _element in _sublist:
                f.write(format(int(_element), '08x') + ' ')
                # print(format(int(_element), '08x'))
            f.write('\n')
        f.write('\n\n')
    f.write('\n\n')
    for _list in cannon.partition(1):
        for _sublist in _list:
            for _element in _sublist:
                f.write(format(int(_element), '08x') + ' ')
                # print(format(int(_element), '08x'))
            f.write('\n')
        f.write('\n\n')
    f.write('\n\n')
    for _list in cannon.partition(2):
        for _sublist in _list:
            for _element in _sublist:
                f.write(format(int(_element), '08x') + ' ')
                # print(format(int(_element), '08x'))
            f.write('\n')
        f.write('\n\n')
    f.write('\n\n')
    f.close()
    fp.close()

    print("Done")

def memory_check():
    memory_size = 256
    init_address = (2*(memory_size + 2)) //3 + 3
    rows = 7
    cols = 1
    size = 3
    num_blocks = math.ceil(rows / size) * math.ceil(cols / size)
    stop_line = num_blocks * size * size + 1
    for _i in range(1,stop_line):
        line_result = linecache.getline(ABSOLUTE_PATH + RELATIVE_PATH + "processor_tb_result.txt",init_address + _i)
        line_check = linecache.getline(ABSOLUTE_PATH + RELATIVE_PATH + "processor_tb_check.txt",_i)
        print(line_result.strip() , " " , line_check.strip())
        if line_result != line_check:
            print("DIFFERENT")

    print("SAME")

def register_init():
    size = 6
    width = 32
    lo, hi = int("0x00800000", 16), int("0x7f7fffff", 16)
    f = open(
        ABSOLUTE_PATH + RELATIVE_PATH + "register_tb_init.txt",
        "w")
    for _i in range(2*(size ** 2)):
        f.write(format(random.randint(lo, hi), 'x'))
        f.write('\n')
    for _i in range(size ** 2):
        f.write(format(0, 'x'))
        f.write('\n')
    f.close()
    print("Done")


def block_mult():
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
        executable_path=ABSOLUTE_PATH  + "GoldenModel/chromedriver.exe")
    processor = ProcessingUnit(size, fp)
    matrix_c = processor.matrix_mult(matrix_a, matrix_b)

    for _i in range(size):
        for _j in range(size):
            print(format(int(matrix_c[_i][_j]), '08x'), end=" ")
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
        executable_path=ABSOLUTE_PATH + "GoldenModel/chromedriver.exe")
    processor = ProcessingUnit(size, fp)
    matrix_c = processor.matrix_add(matrix_a, matrix_b)

    for _i in range(size):
        for _j in range(size):
            print(format(int(matrix_c[_i][_j]), '08x'), end=" ")
        print()


int_input = int(input())
if int_input == 0:
    block_add()
if int_input == 1:
    block_mult()
if int_input == 2:
    memory_init()
if int_input == 3:
    memory_check()