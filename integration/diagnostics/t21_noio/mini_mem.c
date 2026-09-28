/* SPDX-License-Identifier: GPL-3.0-only
 * Freestanding diagnostic runtime only. No allocation, I/O or miner state. */
#include <stddef.h>
void *memcpy(void *restrict dst, const void *restrict src, size_t n)
{
    unsigned char *d=dst; const unsigned char *s=src;
    for (size_t i=0;i<n;++i) d[i]=s[i];
    return dst;
}
void *memset(void *dst, int byte, size_t n)
{
    unsigned char *d=dst;
    for (size_t i=0;i<n;++i) d[i]=(unsigned char)byte;
    return dst;
}
int memcmp(const void *a, const void *b, size_t n)
{
    const unsigned char *x=a, *y=b;
    for(size_t i=0;i<n;++i) if(x[i]!=y[i]) return (int)x[i]-(int)y[i];
    return 0;
}
#if defined(__arm__)
void __aeabi_memcpy(void *d,const void *s,size_t n) { (void)memcpy(d,s,n); }
void __aeabi_memcpy4(void *d,const void *s,size_t n) { (void)memcpy(d,s,n); }
void __aeabi_memcpy8(void *d,const void *s,size_t n) { (void)memcpy(d,s,n); }
void __aeabi_memclr(void *d,size_t n) { (void)memset(d,0,n); }
void __aeabi_memclr4(void *d,size_t n) { (void)memset(d,0,n); }
void __aeabi_memclr8(void *d,size_t n) { (void)memset(d,0,n); }
void __aeabi_memset(void *d,size_t n,int c) { (void)memset(d,c,n); }
void __aeabi_memset4(void *d,size_t n,int c) { (void)memset(d,c,n); }
void __aeabi_memset8(void *d,size_t n,int c) { (void)memset(d,c,n); }
#endif
