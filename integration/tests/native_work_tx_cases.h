/* Included only by the offline harness with the REAL root cgminer.c. */
#include "integration/native_work_tx.h"
static unsigned dt_packets, dt_vectors, dt_roundtrips, dt_assertions;
#define DT_CHECK(x) do { ++dt_assertions; if (!(x)) { \
    fprintf(stderr, "native-work-tx FAIL %d: %s\n", __LINE__, #x); exit(1); \
} } while (0)

static void dt_packet_cases(void)
{
    unsigned layout_index, id, i;
    for (layout_index = 0; layout_index < 2; ++layout_index) {
        enum dizzass_tx86_layout layout = layout_index ?
            DIZZASS_TX86_NONCE_PREFIX : DIZZASS_TX86_HEADER_REVERSED;
        struct work *w = dn_work(), before = *w;
        uint32_t allocation_count = total_work;
        for (id = 0; id < 128; ++id) {
            unsigned char guarded[92], expected[86];
            memset(guarded, 0xa5, sizeof(guarded));
            DT_CHECK(dizzass_native_work_tx86(w, layout, id, guarded+3, 86) == 0);
            DT_CHECK(dizzass_work_tx86_encode(w->data, 80, layout, id, expected, 86) == 0);
            DT_CHECK(!memcmp(guarded+3, expected, 86));
            DT_CHECK(guarded[3] == 0x55 && guarded[4] == 0xaa &&
                     guarded[5] == 0x20 && guarded[6] == id);
            for (i = 0; i < 3; ++i)
                DT_CHECK(guarded[i] == 0xa5 && guarded[89+i] == 0xa5);
            DT_CHECK(!memcmp(w, &before, sizeof(*w)) && total_work == allocation_count);
            DT_CHECK(!strcmp(w->job_id,"offline-fixture-job"));
            DT_CHECK(!strcmp(w->nonce1,"00112233") && !strcmp(w->ntime,"495fab29"));
            DT_CHECK(!strcmp(w->coinbase,"offline-owned-string"));
            ++dt_packets;
        }
        free_work(w);
    }
}

static void dt_guards(void)
{
    struct work *w = dn_work(), before = *w;
    unsigned char out[86], saved[86], zero_nonce[86], changed_nonce[86];
    unsigned cap;
    memset(saved, 0xa5, sizeof(saved));
    for (cap = 0; cap < 86; ++cap) {
        memcpy(out,saved,86);
        DT_CHECK(dizzass_native_work_tx86(w,DIZZASS_TX86_HEADER_REVERSED,1,out,cap) == DIZZASS_TX86_NO_SPACE);
        DT_CHECK(!memcmp(out,saved,86));
    }
    DT_CHECK(dizzass_native_work_tx86(NULL,DIZZASS_TX86_HEADER_REVERSED,1,out,86) == DIZZASS_TX86_INVALID);
    DT_CHECK(dizzass_native_work_tx86(w,DIZZASS_TX86_HEADER_REVERSED,128,out,86) == DIZZASS_TX86_INVALID);
    DT_CHECK(dizzass_native_work_tx86(w,DIZZASS_TX86_HEADER_REVERSED,UINT32_MAX,out,86) == DIZZASS_TX86_INVALID);
    DT_CHECK(dizzass_native_work_tx86(w,(enum dizzass_tx86_layout)1,1,out,86) == DIZZASS_TX86_UNSUPPORTED);
    DT_CHECK(dizzass_native_work_tx86(w,DIZZASS_TX86_HEADER_REVERSED,1,NULL,86) == DIZZASS_TX86_INVALID);
    DT_CHECK(!memcmp(out,saved,86) && !memcmp(w,&before,sizeof(*w)));
    for (cap = 0; cap < 2; ++cap) {
        enum dizzass_tx86_layout layout = cap ? DIZZASS_TX86_NONCE_PREFIX : DIZZASS_TX86_HEADER_REVERSED;
        memset(w->data+76,0,4);
        DT_CHECK(dizzass_native_work_tx86(w,layout,19,zero_nonce,86) == 0);
        memset(w->data+76,0xff,4);
        DT_CHECK(dizzass_native_work_tx86(w,layout,19,changed_nonce,86) == 0);
        DT_CHECK(!memcmp(zero_nonce,changed_nonce,86));
    }
    DT_CHECK(dizzass_tx86_crc16((const uint8_t *)"123456789",9,0xffff) == 0x29b1);
    DT_CHECK(dizzass_tx86_crc16(NULL,0,0x1234) == 0x1234);
    free_work(w);
}

static void dt_historical_roundtrip(void)
{
    unsigned index, i;
    for (index = 0; index < 2; ++index) {
        enum dizzass_tx86_layout layout = index ? DIZZASS_TX86_NONCE_PREFIX : DIZZASS_TX86_HEADER_REVERSED;
        struct work *w = dn_work(), *back = copy_work_noffset(w,0);
        unsigned char packet[86], body[80];
        DT_CHECK(dizzass_native_work_tx86(w,layout,17,packet,sizeof(packet)) == 0);
        /* Test-only inverse of the proven permutation, NOT an ASIC reply or
         * a device emulator. Restore the known nonce solely for core hashing. */
        for (i=0;i<80;++i) body[i]=packet[83-i];
        DT_CHECK(!memcmp(body+(index ? 4 : 0),w->data,76));
        DT_CHECK(!memcmp(body+(index ? 0 : 76),"\0\0\0\0",4));
        memset(back->data,0,sizeof(back->data));
        memcpy(back->data,body+(index ? 4 : 0),76);
        DT_CHECK(test_nonce(back,dn_le(fixture_words+76)));
        DT_CHECK(!memcmp(back->hash,fixture_hash,32));
        DT_CHECK(fulltest(back->hash,back->target));
        free_work(back); free_work(w); ++dt_roundtrips;
    }
}

static void dt_native_vectors(void)
{
    unsigned i,j;
    for (i=0;i<64;++i) {
        struct work *w=dn_work(), before;
        unsigned char packet[86];
        enum dizzass_tx86_layout layout=i&1 ? DIZZASS_TX86_NONCE_PREFIX : DIZZASS_TX86_HEADER_REVERSED;
        unsigned id=(i*31u)&127u;
        for (j=0;j<80;++j) w->data[j]=(unsigned char)dn_random();
        before=*w;
        DT_CHECK(dizzass_native_work_tx86(w,layout,id,packet,86) == 0);
        DT_CHECK(!memcmp(w,&before,sizeof(*w)));
        printf("TX86_NATIVE %u %u ",(unsigned)layout,id);
        dn_hex(w->data,80); printf(" "); dn_hex(packet,86); printf("\n");
        free_work(w); ++dt_vectors;
    }
}
static void dt_all(void)
{
    dt_packet_cases(); dt_guards(); dt_historical_roundtrip(); dt_native_vectors();
    printf("NATIVE_WORK_TX_PASS packets=%u vectors=%u roundtrips=%u assertions=%u\n",
        dt_packets,dt_vectors,dt_roundtrips,dt_assertions);
}
