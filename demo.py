# message = "Hello Python world"
# print(message)

import ctypes

lib = ctypes.CDLL("bin/libcalc_shared.dll")

lib.add.argtypes = [ctypes.c_int, ctypes.c_int]
lib.add.restype = ctypes.c_int

result1 = lib.add(10,20)

print("调用C动态库add(10,20) == :", result1)
