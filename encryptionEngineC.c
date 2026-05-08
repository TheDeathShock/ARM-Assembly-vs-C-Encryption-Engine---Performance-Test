#include <stdint.h>

uint8_t message[4] = { 'A', 'M', 'E', 'R' };
uint8_t encryptedMessage[4];

uint32_t key = 34534234;

void encrypt(uint8_t *messageAddr, uint32_t *keyAddr, uint8_t *outputAddr, uint32_t length)
{
    uint8_t keyByte = *((uint8_t *)keyAddr);

    for (uint32_t i = 0; i < length; i++)
    {
        outputAddr[i] = messageAddr[i] ^ keyByte;
    }
}

int main(void)
{
    encrypt(message, &key, encryptedMessage, 4);

    while (1)
    {
    }
}