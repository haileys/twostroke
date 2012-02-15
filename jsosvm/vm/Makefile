CFLAGS=-m32 -Wall -Wextra -iquote inc -g -pg
LDFLAGS=-m32

all: disasm runner

disasm: src/image.o src/scope.o src/st.o src/value.o src/vm.o src/object.o

runner: src/image.o src/scope.o src/st.o src/value.o src/vm.o src/object.o

clean:
	rm -f src/*.o
	rm -f runner
	rm -f disasm