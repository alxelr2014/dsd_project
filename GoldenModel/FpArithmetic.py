from selenium import webdriver
from selenium.webdriver.common.keys import Keys
from ieee754_converter import IEEE754


class FpArithmetic:
    def __init__(self):
        pass
        # self.__driver = webdriver.Chrome(executable_path=executable_path)
        # self.__driver.get("http://weitz.de/ieee/")
        # self.__input1 = self.__driver.find_element_by_id('in1')
        # self.__input2 = self.__driver.find_element_by_id('in2')
        # self.__input3 = self.__driver.find_element_by_id('in3')
        # self.__out1 = self.__driver.find_element_by_id('binOut1')
        # self.__out2 = self.__driver.find_element_by_id('binOut2')
        # self.__out3 = self.__driver.find_element_by_id('binOut3')
        # self.__hexOut1 = self.__driver.find_element_by_id('hexOut1')
        # self.__hexOut2 = self.__driver.find_element_by_id('hexOut2')
        # self.__hexOut3 = self.__driver.find_element_by_id('hexOut3')
        # self.__plus = self.__driver.find_element_by_id('plusButton')
        # self.__times = self.__driver.find_element_by_id('timesButton')
        # self.button32 = self.__driver.find_element_by_id('sizeButton32')
        # self.button32.send_keys(Keys.RETURN)

    def times_fp(self, a, b):
        return IEEE754(a * b)
        # self.clear_text(self.__input1)
        # self.__input1.send_keys(hex(a))
        # self.clear_text(self.__input2)
        # self.__input2.send_keys(hex(b))
        # self.__times.send_keys(Keys.ENTER)
        # output = self.__hexOut3.text[2:len(self.__hexOut3.text)]
        # return self.hex_to_int(output)

    def sum_fp(self, a, b):
        return IEEE754(a + b)

        # self.clear_text(self.__input1)
        # self.__input1.send_keys(hex(a))
        # self.clear_text(self.__input2)
        # self.__input2.send_keys(hex(b))
        # self.__plus.send_keys(Keys.ENTER)
        # output = self.__hexOut3.text[2:len(self.__hexOut3.text)]
        # return self.hex_to_int(output)

    # def fp_to_hex(self, a):
    #     self.clear_text(self.__input1)
    #     self.__input1.send_keys(hex(a))
    #     self.__input1.send_keys(Keys.RETURN)
    #     output = self.__hexOut1.text[2:len(self.__hexOut1.text)]
    #     return self.hex_to_int(output)

    # def hex_to_int(self,a):
    #     return int(a,16)

    # def clear_text(self, element):
    #     length = len(element.get_attribute('value'))
    #     element.send_keys(length * Keys.BACKSPACE)


    # def close(self):
    #     self.__driver.close()

'''
fp = FpArithmetic(executable_path="C:/Users/emadz/Desktop/School/Books/Semester IV/Digital System Design/Project/GoldenModel/chromedriver.exe")
print(hex(1083535524))
test = fp.sum_fp(1138298061,1083535524)
print(test)
fp.close()'''

