#include <stdio.h>

// This is some C code I wrote for ass3.asm to gather my thoughts
// and test my algorithms before attempting to write them in
// assembly.

int lsb(int number);
int msb(int number, int lsb);
int bitCount(int number);

int main()
{
	int number;
	printf("Please enter a number: ");
	scanf("%d", &number);

	int least = lsb(number);
	printf("LSB: %d\n", least);
	printf("MSB: %d\n", msb(number, least));
	printf("Bit count: %d\n", bitCount(number));
}

int lsb(int number)
{
	int count = 0;
	while ((number & 1) == 0)
	{
		number = number >> 1;
		count++;
	}
	return count;
}

int msb(int number, int lsb)
{
	int count = lsb - 1;
	if (number == 0)
	{
		return count;
	}
	number = number >> lsb;
	while (number != 0)
	{
		number = number >> 1;
		count++;
	}
	return count;
}

int bitCount(int number)
{
	int count = 0;
	while (number != 0)
	{
		if (number & 1 == 1)
		{
			count++;
		}
		number = number >> 1;
	}
	return count;
}
