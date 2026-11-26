# main: main.cpp ./src/mmath.cpp
# 	if not exist out mkdir out
# 	g++ -I ./inc  main.cpp ./src/mmath.cpp -o out/main

# ---

# cc = g++
# prom = bin/main
# inc = inc
# src = main.cpp src/mmath.cpp

# $(prom): $(src)
# 	if not exist bin mkdir bin
# 	$(cc) -I $(inc) $(src) -o $(prom)

# ---

# 基于windows环境，使用 mingw32-make，而不是 Make

CXX = g++
PROM = bin/main.exe
INC = inc

CCFLAGS = -Wall -I $(INC)

DEPS = $(wildcard $(INC)/*.h) # wildcard对其展开成实际的头文件列表，直接用 DEPS = $(INC)/*.h 则不会
OBJ = build/main.o build/mmath.o

# Make会先检查目标文件是否存在，然后再决定要不要执行
# 不加伪目标，如果存在 all文件，Make发现存在这个文件因此就不执行了
# .PHONY 告诉Make，all clean run都是动作名称，不是需要生成的文件，每次执行make clean都执行下面的命令

.PHONY: all clean run #伪目标 all clean run

# GNU Make默认会执行第一个普通目标，所以把all放前面，就不用每次指定目标。 所以Make 就相当于Make all
all: $(PROM) # Make all 或者 Make 

$(PROM): $(OBJ) # $^则是冒号后面所有的依赖文件，即$(OBJ)
	if not exist bin mkdir bin
	$(CXX) $^ -o $@

build/main.o: main.cpp $(DEPS) # 冒号后面是依赖文件，main.cpp是第一个依赖文件，$<就是main.cpp
	if not exist build mkdir build
	$(CXX) $(CCFLAGS) -c $< -o $@

build/mmath.o: src/mmath.cpp $(DEPS)
	if not exist build mkdir build
	$(CXX) $(CCFLAGS) -c $< -o $@

clean: # Make clean
	if exist build rmdir /s /q build
	if exist bin rmdir /s /q bin

run: $(PROM) # Make run
	.\$(PROM)
