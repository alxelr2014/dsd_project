import random
import numpy as np
import math

class CannonTopDown:
	def __init__(self, m, r , n , sqrt_p):
		self.sqrt_p = sqrt_p
		self.p = sqrt_p** 2
		self.m = m
		self.r = r
		self.n = n
		self.a_matrix = np.random.randint(1, 10, (m, r))
		self.b_matrix = np.random.randint(1, 10, (r, n))
		self.c_matrix = np.zeros((m, n))

	def index(self, i, row=0, col=0):
		if row != 0:
			return i * self.sqrt_p, min((i + 1) * self.sqrt_p, row)
		if col != 0:
			return i * self.sqrt_p, min((i + 1) * self.sqrt_p, col)

	def p_block_mult(self, i, j, k):
		row_index_A = self.index(i, row=self.m)
		col_index_A = self.index((i + j + k) % self.sqrt_p, col=self.r)
		row_index_B = self.index((i + j + k) % self.sqrt_p, row=self.r)
		col_index_B = self.index(j, col=self.n)
		new_A = self.a_matrix[row_index_A[0]: row_index_A[1], col_index_A[0]: col_index_A[1]]
		new_B = self.b_matrix[row_index_B[0]: row_index_B[1], col_index_B[0]: col_index_B[1]]
		return np.dot(new_A, new_B) # matrix multiplication

	def main_algorithm(self):
		for _i in range(math.ceil(self.m / self.sqrt_p)):
			for _j in range(math.ceil(self.n / self.sqrt_p)):
				for _k in range(self.sqrt_p):
					row_index = self.index(_i, row=self.m)
					col_index = self.index(_j, col=self.n)
					self.c_matrix[row_index[0]: row_index[1], col_index[0]:col_index[1]] += self.p_block_mult(_i, _j, _k)
					print(col_index)
					print(row_index)
					print()
		self.verification()

	def verification(self):
		D = np.dot(self.a_matrix, self.b_matrix)
		is_the_same = np.sum(np.array([np.sum(D == self.c_matrix, axis=0)]), axis=1)[0]
		print(is_the_same == self.m * self.n)
		print(self.c_matrix)
		print(D)
low = 1
high = 15
CannonTopDown(4,4,4,2).main_algorithm()