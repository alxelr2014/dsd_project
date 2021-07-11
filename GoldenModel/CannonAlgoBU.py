import numpy as np
import math
import random
from  FpArithmetic import FpArithmetic

class ProcessingUnit:
    def __init__(self, k):
        self.k = k

    def mult(self, matrix_a, matrix_b):
        new_matrix_a = self.append(matrix_a)
        new_matrix_b = self.append(matrix_b)
        extra_rows = self.k - np.shape(matrix_a)[0]
        extra_cols = self.k - np.shape(matrix_b)[1]
        return self.remove(np.dot(new_matrix_a, new_matrix_b), extra_rows, extra_cols)

    def append(self, matrix_a):
        num_rows = np.shape(matrix_a)[0]
        num_cols = np.shape(matrix_a)[1]
        extra_rows = self.k - num_rows
        extra_cols = self.k - num_cols
        res_matrix = matrix_a
        if extra_rows > 0:
            zeros = np.zeros((extra_rows, num_cols))
            res_matrix = np.concatenate((res_matrix, zeros), axis=0)
        if extra_cols > 0:
            zeros = np.zeros((self.k, extra_cols))
            res_matrix = np.concatenate((res_matrix, zeros), axis=1)
        return res_matrix

    def remove(self, matrix_c, extra_row, extra_col):
        last_row = self.k - extra_row
        last_col = self.k - extra_col
        return matrix_c[0:last_row, 0: last_col]

    def test(self):
        m = random.randint(1, self.k)
        r = random.randint(1, self.k)
        n = random.randint(1, self.k)

        a_matrix = np.random.randint(1, 10, (m, r))
        b_matrix = np.random.randint(1, 10, (r, n))
        c_matrix = self.mult(a_matrix, b_matrix)
        d_matrix = np.dot(a_matrix, b_matrix)
        print(m, " ", r, " ", n)
        print("A: \n" + str(a_matrix) + "\nB: \n" + str(b_matrix) +
              "\nC: \n" + str(c_matrix) + "\nD: \n" + str(d_matrix))
        return verify(c_matrix, d_matrix)


def matrix_mult (matrix_a ,matrix_b):
    rows_a , cols_a = np.shape(matrix_a)
    rows_b , cols_b = np.shape(matrix_b)
    matrix_res = np.zeros((rows_a,cols_b))
    if cols_a != rows_b :
        return
    for __i in range(rows_a):
        for _j in range(cols_b):
            for _k in range(rows_b):
                return
                # matrix_res[__i][_j] =


def verify(c_matrix, d_matrix):
    is_the_same = np.sum(
        np.array([np.sum(d_matrix == c_matrix, axis=0)]), axis=1)[0]
    m, n = np.shape(c_matrix)[0], np.shape(c_matrix)[1]
    # print(is_the_same == m * n)
    return is_the_same == m * n


def submatrix(matrix_a, ranges):
    return matrix_a[ranges[0][0]: ranges[0][1], ranges[1][0]: ranges[1][1]]


class CannonBotUp:
    def __init__(self, m, r, n, p, k):
        self.m = m  # num rows of A
        self.n = n  # num cols of B
        self.r = r  # num cols of A = num rows of B
        self.p = p  # num processors
        self.k = k  # square submatrix size
        self.matrix_a = np.random.randint(1, 10, (m, r))
        self.matrix_b = np.random.randint(1, 10, (r, n))
        self.matrix_c = np.zeros((m, n))
        self.processors = [ProcessingUnit(k) for _j in range(p)]

    def index(self, i, j, row, col):
        row_range = i * self.k, min((i + 1) * self.k, row)
        col_range = j * self.k, min((j + 1) * self.k, col)
        return row_range, col_range

    def main_algo(self):
        for _p in range(self.p):
            for _i in range(math.ceil(self.m / self.k)):
                for _j in range(math.ceil(self.n / self.k)):
                    if (_i + _j) % self.p == _p:
                        for _k in range(math.ceil(self.r / self.k)):
                            a_range = self.index(_i, _k, self.m, self.r)
                            b_range = self.index(_k, _j, self.r, self.n)
                            c_range = self.index(_i, _j, self.m, self.n)
                            a_sub = submatrix(self.matrix_a, a_range)
                            b_sub = submatrix(self.matrix_b, b_range)
                            self.matrix_c[c_range[0][0]: c_range[0][1], c_range[1][0]
                                : c_range[1][1]] += self.processors[_p].mult(a_sub, b_sub)

    def test(self):
        self.main_algo()
        matrix_d = np.dot(self.matrix_a, self.matrix_b)
        # print("m = ", self.m, " r = ", self.r, " n = ",
        #       self.n, " p = ", self.p, " k = ", self.k)
        # print("A: \n" + str(self.matrix_a) + "\nB: \n" + str(self.matrix_b) +
        #       "\nC: \n" + str(self.matrix_c) + "\nD: \n" + str(matrix_d))
        return verify(self.matrix_c, matrix_d)


fp = FpArithmetic(executable_path="C:/Users/emadz/Desktop/School/Books/Semester IV/Digital System Design/Project/GoldenModel/chromedriver.exe")

lo, hi = int("0x00800000",16), int("0x7f7fffff",16)
print(lo," ", hi)
p_hi, k_hi = 10, 10
num_test = 10
flag = True
for _i in range(num_test):

    num_rows_A = random.randint(lo, hi)
    num_cols_A = random.randint(lo, hi)
    num_cols_B = random.randint(lo, hi)
    num_processors = random.randint(lo, p_hi)
    size_submatrix = random.randint(lo, k_hi)

    flag = flag and CannonBotUp(num_rows_A, num_cols_A, num_cols_B,
                                num_processors, size_submatrix).test()

print(flag)
# ProcessingUnit(5).test()
