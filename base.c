#include <stdio.h>
#include <math.h>

double f(double x) {
    return x * x * x;
}

typedef double afunc(double);

double integral(afunc *f, double a, double b, double error, double n1, double n2) {   //range = [a, b]                       
    int n = 20;

    double h = (b - a) / n, In = 0, I2n = 0;
    for (int i = 0; i < n; i++)
        I2n += n1 + n2 * f(a + (i - 1)*h);
    I2n *= h;

    while ((fabs(In - I2n)) >= error) {
        n*= 2;
        In = I2n;
        h = (b - a) / n;
        I2n = 0;
        for (int i = 0; i < n; i++)
            I2n += n1 +  n2 * f(a + (i - 1)*h);
        I2n *= h;
    }
    return I2n;
}

int main(void) {
    double num1;                                                                      // a in function y = a + b * x^3
    double num2;                                                                      // b in function y = a + b * x^3
    double a;                                                                         // range [a, b]
    double b;                                                                         // range [a, b]
    double eps = 0.0001;                                                              //margin of error
    scanf("%lf %lf %lf %lf", &num1, &num2, &a, &b);
    double result = integral(f, a, b, eps, num1, num2);
    printf("%lf", result);
    return 0;
}
