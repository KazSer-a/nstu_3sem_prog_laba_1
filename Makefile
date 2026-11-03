CXX = g++
CXXFLAGS = -std=c++17 -Wall -Wextra -Iinclude
SRC = main.cpp $(wildcard src/*.cpp)

all: dbms

dbms: $(SRC) $(wildcard include/*.h)
	$(CXX) $(CXXFLAGS) $(SRC) -o dbms

clean:
	rm -f dbms dbms.exe

.PHONY: all clean
