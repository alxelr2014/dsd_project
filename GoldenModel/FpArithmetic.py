from selenium import webdriver
from selenium.webdriver.common.keys import Keys


class FpArithmetic:
    def __init__(self, executable_path):
        self.__driver = webdriver.Chrome(executable_path=executable_path)
        self.__driver.get("http://weitz.de/ieee/")
        self.__input1 = self.__driver.find_element_by_id('in1')
        self.__input2 = self.__driver.find_element_by_id('in2')
        self.__input3 = self.__driver.find_element_by_id('in3')
        self.__out1 = self.__driver.find_element_by_id('binOut1')
        self.__out2 = self.__driver.find_element_by_id('binOut2')
        self.__out3 = self.__driver.find_element_by_id('binOut3')
        self.__plus = self.__driver.find_element_by_id('plusButton')
        self.__times = self.__driver.find_element_by_id('timesButton')

    def times_fp(self, a, b):
        self.__input1.send_keys(Keys.BACKSPACE)
        self.__input1.send_keys(Keys.BACKSPACE)
        self.__input1.send_keys(Keys.BACKSPACE)
        self.__input1.send_keys(str(a))
        self.__input2.send_keys(Keys.BACKSPACE)
        self.__input2.send_keys(Keys.BACKSPACE)
        self.__input2.send_keys(Keys.BACKSPACE)
        self.__input2.send_keys(str(b))
        self.__times.send_keys(Keys.ENTER)
        output = self.__input3.get_property('value')
        return output

    def sum_fp(self, a, b):
        self.__input1.send_keys(Keys.BACKSPACE)
        self.__input1.send_keys(Keys.BACKSPACE)
        self.__input1.send_keys(Keys.BACKSPACE)
        self.__input1.send_keys(str(a))
        self.__input2.send_keys(Keys.BACKSPACE)
        self.__input2.send_keys(Keys.BACKSPACE)
        self.__input2.send_keys(Keys.BACKSPACE)
        self.__input2.send_keys(str(b))
        self.__plus.send_keys(Keys.ENTER)
        output = self.__input3.get_property('value')
        return output

    def bin_to_fp(self, a):
        self.__input1.send_keys(Keys.BACKSPACE)
        self.__input1.send_keys(Keys.BACKSPACE)
        self.__input1.send_keys(Keys.BACKSPACE)
        self.__input1.send_keys(str(a))
        self.__input1.send_keys(Keys.RETURN)
        output = self.__out1.text
        return output[2:len(output)]

    def close(self):
        self.__driver.close()


fp = FpArithmetic(executable_path="C:/Users/emadz/Desktop/School/Books/Semester IV/Digital System Design/Project/GoldenModel/chromedriver.exe")
test = fp.times_fp(4.32, 6.37)
print(test)
print(fp.bin_to_fp(test))
fp.close()
