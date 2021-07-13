import numpy as np
import math
import random
from  FpArithmetic import FpArithmetic


class ProcessingUnit:
    def __init__(self, k ,fp):
        self.k = k
        self.fp = fp

    def mult(self, matrix_a, matrix_b):
        new_matrix_a = self.append(matrix_a)
        new_matrix_b = self.append(matrix_b)
        extra_rows = self.k - np.shape(matrix_a)[0]
        extra_cols = self.k - np.shape(matrix_b)[1]
        return self.remove(self.matrix_mult(new_matrix_a, new_matrix_b), extra_rows, extra_cols)

    def append(self, matrix_a):
        num_rows = np.shape(matrix_a)[0]
        num_cols = np.shape(matrix_a)[1]
        extra_rows = self.k - (num_rows % self.k)
        extra_cols = self.k -( num_cols % self.k)
        res_matrix = matrix_a
        if extra_rows < self.k:
            zeros = np.zeros((extra_rows, num_cols))
            res_matrix = np.concatenate((res_matrix, zeros), axis=0)
        if extra_cols < self.k:
            zeros = np.zeros((num_rows +( extra_rows % self.k), extra_cols))
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

    def matrix_mult (self, matrix_a ,matrix_b):
        rows_a , cols_a = np.shape(matrix_a)
        rows_b , cols_b = np.shape(matrix_b)
        matrix_res = np.zeros((rows_a,cols_b))
        if cols_a != rows_b :
            return
        for _i in range(rows_a):
            for _j in range(cols_b):
                for _k in range(rows_b):
                    fp_prod_res = self.fp.times_fp(int(matrix_a[_i][_k]) , int(matrix_b[_k][_j]))
                    fp_sum_res = self.fp.sum_fp(int(matrix_res[_i][_j]),  int(fp_prod_res))
                    # print(_i , " " , _j , " " , _k, " : " , fp_prod_res , " " , fp_sum_res)
                    matrix_res[_i][_j] = fp_sum_res
        return matrix_res

    def matrix_add(self, matrix_a, matrix_b):
        rows_a , cols_a = np.shape(matrix_a)
        rows_b , cols_b = np.shape(matrix_b)
        matrix_res = np.zeros((rows_a,cols_a))
        if cols_a != cols_b or rows_a != rows_b:
            return
        for _i in range(rows_a):
            for _j in range(cols_a):
                fp_sum_res =  self.fp.sum_fp(int(matrix_b[_i][_j]),  int(matrix_a[_i][_j]))
                matrix_res[_i][_j] = fp_sum_res
        return matrix_res


def verify(c_matrix, d_matrix):
    is_the_same = np.sum(
        np.array([np.sum(d_matrix == c_matrix, axis=0)]), axis=1)[0]
    m, n = np.shape(c_matrix)[0], np.shape(c_matrix)[1]
    # print(is_the_same == m * n)
    return is_the_same == m * n


def submatrix(matrix_a, ranges):
    return matrix_a[ranges[0][0]: ranges[0][1], ranges[1][0]: ranges[1][1]]


class CannonBotUp:
    def __init__(self, m, r, n, p, k , lo ,hi , fp):
        self.m = m  # num rows of A
        self.n = n  # num cols of B
        self.r = r  # num cols of A = num rows of B
        self.p = p  # num processors
        self.k = k  # square sub matrix size
        self.matrix_a = np.random.randint(lo, hi, (m, r))
        self.matrix_b = np.random.randint(lo, hi, (r, n))
        self.matrix_c = np.zeros((m, n))
        self.processors = [ProcessingUnit(k, fp) for _j in range(p)]
        self.matrix_a = self.processors[0].append(self.matrix_a)
        self.matrix_b = self.processors[0].append(self.matrix_b)
        self.matrix_c = self.processors[0].append(self.matrix_c)
        self.m += (self.k - (self.m % self.k ) ) %self.k
        self.n +=(self.k - (self.n % self.k ) ) %self.k
        self.r += (self.k - (self.r % self.k ) ) %self.k

    def index(self, i, j, row, col):
        row_range = i * self.k, min((i + 1) * self.k, row)
        col_range = j * self.k, min((j + 1) * self.k, col)
        return row_range, col_range

    def range_addition(self,c_range, _p, a_sub , b_sub):
        res_matrix = self.processors[_p].mult(a_sub, b_sub)
        for _i in range (c_range[0][1] - c_range[0][0]):
            for _j in range(c_range[1][1] - c_range[1][0]):
                self.matrix_c[_i + c_range[0][0]][_j + c_range[1][0]] = \
                    self.processors[_p].fp.sum_fp(int(self.matrix_c[_i + c_range[0][0]][_j + c_range[1][0]]),  int(res_matrix[_i][_j]))

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
                            self.range_addition(c_range,_p,a_sub,b_sub)

    def partition (self, iden):
        if iden == 0 : # matrix a
            result = []
            for _i in range(math.ceil(self.m / self.k)):
                for _k in range(math.ceil(self.r / self.k)):
                    a_range = self.index(_i, _k, self.m, self.r)
                    result.append(submatrix(self.matrix_a, a_range))
            return result
        if iden == 1:  #matrix b
            result = []
            for _i in range(math.ceil(self.r / self.k)):
                for _k in range(math.ceil(self.n / self.k)):
                    b_range = self.index(_i, _k, self.r, self.n)
                    result.append(submatrix(self.matrix_b, b_range))
            return result
        else:
            result = []
            for _i in range(math.ceil(self.m / self.k)):
                for _k in range(math.ceil(self.n / self.k)):
                    c_range = self.index(_i, _k, self.m, self.r)
                    result.append(submatrix(self.matrix_c, c_range))
            return result

    def test(self):
        # self.main_algo()
        matrix_d = self.processors[0].matrix_mult(self.matrix_a, self.matrix_b)
        print("m = ", self.m, " r = ", self.r, " n = ",
              self.n, " p = ", self.p, " k = ", self.k)

        print(self.matrix_a)

        print("A:" )
        for _i in range(self.m):
            for _j in range(self.r):
                print( hex(int(self.matrix_a[_i][_j])), end = " " )
            print()

        print("B:" )
        for _i in range(self.r):
            for _j in range(self.n):
                print(hex(int(self.matrix_b[_i][_j])), end =" ")
            print()

        print("C:" )
        for _i in range(self.m):
            for _j in range(self.n):
                print(hex(int(self.matrix_c[_i][_j])), end =" ")
            print()

        print("D:" )
        for _i in range(self.m):
            for _j in range(self.n):
                print(hex(int(matrix_d[_i][_j])), end = " ")
            print()
        self.matrix_c = matrix_d
        return verify(self.matrix_c, matrix_d)

"""
fp1 = FpArithmetic(executable_path="C:/Users/emadz/Desktop/School/Books/Semester IV/Digital System Design/Project/GoldenModel/chromedriver.exe")
lo, hi = 1,6
fp_lo, fp_hi = int("0x38D1B717", 16), int("0x43FA0000", 16)
p_hi, k_hi = 1, 1
num_test = 1
flag = True
for i in range(num_test):

    num_rows_A = random.randint(lo, hi)
    num_cols_A = random.randint(lo, hi)
    num_cols_B = random.randint(lo, hi)
    num_processors = random.randint(lo, p_hi)
    size_submatrix = random.randint(lo, k_hi)

    flag = flag and CannonBotUp(num_rows_A, num_cols_A, num_cols_B,
                                num_processors, size_submatrix,fp_lo , fp_hi, fp1).test()

print(flag)
fp1.close()
# ProcessingUnit(5).test()"""
