CFLAGS=-m32 -Wall -Wextra -iquote inc -g

all: runner

runner: src/image.o src/scope.o src/st.o src/value.o src/vm.o

clean:
	rm -f src/*.o
	rm -f runner