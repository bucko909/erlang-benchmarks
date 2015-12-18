all:
	gcc -c -Wall -Werror -fpic bench_test1.c
	gcc -shared -o bench_test1.so bench_test1.o
	erlc uberpt.erl
	erlc repeat.erl
	erlc -pa . bench_test1.erl
