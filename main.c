#include "stdio.h"
#include "stdlib.h"
#include "time.h"

int main(int argc, char const *argv[])
{
    int arrCount = 10000000; //10_000_000
    int* arr = 0;
    long sum = 0;
    clock_t startTime;
    clock_t endTime;
    double totalTime;

    if (argc >= 2)
    {
        arrCount =atoi(argv[1]);
        printf("adding 0 to %i\n",arrCount);
    }
    
    arr = malloc(arrCount * sizeof(int));

    for (int i = 1; i <= arrCount; i++)
    {
        arr[i] = i;
    }
    startTime = clock();
    for (int i = 0; i < arrCount; i++)
    {
        sum = sum + arr[i];
    }
    printf("sum:%ld\n", sum);
    endTime = clock();

    totalTime = (endTime - startTime) / CLOCKS_PER_SEC;

    printf("first:%i\nlast:%i\ntime:%f\n",arr[0], arr[arrCount], totalTime);
    
    return 0;
}
