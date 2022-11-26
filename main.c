#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <time.h>

extern int64_t timespecDiff(struct timespec timeA, struct timespec timeB);

double f(double x) {
    return x * x * x;
}

typedef double afunc(double);

double integral(afunc *f, double a, double b, double error, double n1, double n2) {   //range = [a, b]                       
    int n = 20;

    double h = (b - a) / n, In = 0, I2n = 0;
    for (int i = 0; i < n; i++)
        I2n += n1 + n2 * f(a + (i - 1) * h);
    I2n *= h;

    while ((fabs(In - I2n)) >= error) {
        n*= 2;
        In = I2n;
        h = (b - a) / n;
        I2n = 0;
        for (int i = 0; i < n; i++)
            I2n += n1 +  n2 * f(a + (i - 1) * h);
        I2n *= h;
    }
    return I2n;
}

int main(int argc, char** argv) {
    char* arg1;
    char* arg2;
    char* arg3;
    struct timespec start;
    struct timespec end;
    int64_t elapsed_ns;

    if (argc == 4) {
        arg1 = argv[1];
        arg2 = argv[2];
        arg3 = argv[3];                                 //"generator" or "input"
        srand(time(NULL));
    } else {                                            // exit with error
        printf("Error! Try again, please.");
        return 1;
    }

    double num1;                                        // a in function y = a + b * x^3
    double num2;                                        // b in function y = a + b * x^3
    double a;                                           // range [a, b]
    double b;                                           // range [a, b]
    double eps = 0.0001;                                // margin of error
    double result;
    FILE* input = fopen(arg1, "rw+");
    if (strcmp(arg3, "generator") == 0) {
        double limit_min = -100;                        // -100 can be replaced by a smaller number for a larger range
        double limit_max = 100;                         // 100 can be replaced by a bigger number for a larger range
        double limit_diff = limit_max - limit_min;
        srand(time(NULL));
        double x1 = limit_min + ((double)rand() / RAND_MAX) * limit_diff;
        srand(time(NULL));
        double x2 = limit_min + ((double)rand() / RAND_MAX) * limit_diff;
        srand(time(NULL));
        double x3 = limit_min + ((double)rand() / RAND_MAX) * limit_diff;
        srand(time(NULL));
        double x4 = x3 + ((double)rand() / RAND_MAX) * (limit_max - x3);
        fprintf(input, "%lf %lf %lf %lf", x1, x2, x3, x4);
    }
    if (input) {
        fscanf(input, "%lf %lf %lf %lf", &num1, &num2, &a, &b);
        fclose(input);
    } else {
        printf("Error! Try again, please.");
        return 1;
    }

    clock_gettime(CLOCK_MONOTONIC, &start);
    result = integral(f, a, b, eps, num1, num2);
    clock_gettime(CLOCK_MONOTONIC, &end);
    elapsed_ns = timespecDiff(end, start);
    printf("Elapsed: %ld ns", elapsed_ns);

    FILE* output = fopen(arg2, "w+");
    fprintf(output, "%lf", result);
    fclose(output);
    return 0;
}
