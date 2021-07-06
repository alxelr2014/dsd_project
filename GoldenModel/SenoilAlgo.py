import  numpy as np

class PE:
	def __init__(self, n , j):
		self.a = 0
		self.bu = 0
		self.bm = 0
		self.bl = 0
		self.index = j
		self.c = np.zeros((n,1))

	def mult(self, k , boo):
		if boo is True:
			self.c[k][0] += self.a * self.bm
		else :
			self.c[k][0] += self.a + self.bl

	def shift_right_b(self, val ):
		temp = self.bu
		self.bu = val
		return temp

	def shift_right_a(self, val):
		temp = self.a
		self.a = val
		return temp

	def shift_down(self):
		temp = self.bm
		self.bm = self.bu
		self.bl = temp


class PE_Array:
	def __init__(self, a_matrix, b_matrix , n):
		self.n = n
		self.p_array = [PE(self.n, _i) for _i in range(self.n)]
		self.a_matrix = a_matrix
		self.b_matrix = b_matrix

	def shift_right(self,in_val_a , in_val_b):
		for pe in self.p_array:
			in_val_a = pe.shift_right_a(in_val_a)
			in_val_b = pe.shift_right_b(in_val_b)

	def operate(self):
		for _i in range(self.n):
			in_val = self.b_matrix[0][_i]
			self.shift_right(0,in_val)
			


		for _i in range(self.n , self.n **2 + self.n):
			in_val_a = self.a_matrix[(_i // self.n) - 1][_i % self.n]
			in_val_b = 0
			if _i <= self.n **2 :
				in_val_b = self.b_matrix[_i // self.n][_i % self.n]
			for pe in self.p_array:
				in_val_a = pe.shift_right_a(in_val_a)
				in_val_b = pe.shift_right_b(in_val_b)

			self.p_array[_i % self.n].shift_down()