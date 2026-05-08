#include <stdint.h>

uint8_t encryptedMessage[4];   // You should enter the encrypted message value
uint8_t decryptedMessage[4];    

uint32_t key = 34534234;

void decrypt(uint8_t *encryptedAddr, uint32_t *keyAddr, uint8_t *outputAddr, uint32_t length)
{
    uint8_t keyByte = *((uint8_t *)keyAddr);

    for (uint32_t i = 0; i < length; i++)
    {
        outputAddr[i] = encryptedAddr[i] ^ keyByte;
    }
}

int main(void)
{
    decrypt(encryptedMessage, &key, decryptedMessage, 4);

    while (1)
    {
    }
}