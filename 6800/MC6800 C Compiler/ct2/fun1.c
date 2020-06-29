extern int fun1();
extern int fun2();
extern int fun3();

int (*routines[])() = {
        fun1,
        fun2,
        fun3
    };

