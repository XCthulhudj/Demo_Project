# import ctypes

# lib = ctypes.CDLL("bin/libcalc_shared.dll")

# lib.add.argtypes = [ctypes.c_int, ctypes.c_int]
# lib.add.restype = ctypes.c_int

# result1 = lib.add(10,20)

# print("调用C动态库add(10,20) == :", result1)

from tools.name_function import get_formatted_name

print("Enter 'q' at any time to quit.")
while True:
    first = input("\nPlease give me a first name: ")
    if first == 'q':
        break
    last = input("Please give me a last name: ")
    if last == 'q':
        break

    formatted_name = get_formatted_name(first, last)
    print("\tNeatly formatted name: " + formatted_name + '.')
    
