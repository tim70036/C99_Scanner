./scanner test0_1.c > fuck.out ;    diff -s fuck.out test0_1.out
./scanner test0_2.c > fuck.out ;    diff -s fuck.out test0_2.out
./scanner pragma_source_off.c > fuck.out ;    diff -s fuck.out pragma_source_off.out
./scanner pragma_source_off_1.c > fuck.out ;    diff -s fuck.out pragma_source_off_1.out
./scanner pragma_token_off.c > fuck.out ;    diff -s fuck.out pragma_token_off.out
./scanner test0_1_error.c 1>trivial.out  2>fuck.out ; diff -s fuck.out test0_1_error.out
