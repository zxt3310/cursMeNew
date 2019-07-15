/*******************************************************************
 *           Copyright (c) 2010 by Hesine Technologies, Inc.
 *                     All rights reserved.
 *
 *  This file is proprietary and confidential to Hesine Technologies. 
 *  No part of this file may be reproduced, stored, transmitted, 
 *  disclosed or used in any form or by any means other than as 
 *  expressly provided by the written permission from Jianhui Tao
 *
 * ****************************************************************/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <signal.h>
#include <netinet/in.h>
#include <errno.h>
#include <sys/time.h>
#include <time.h>

#include "Md5.h"

struct MD5_INTERFACE md5i;

static void md5_process(mir_md5_state_t *pms, const mir_md5_byte_t *data /*[64]*/)
{
	mir_md5_word_t
		a = pms->abcd[0], b = pms->abcd[1],
		c = pms->abcd[2], d = pms->abcd[3];
	mir_md5_word_t t;
	/* Define storage for little-endian or both types of CPUs. */
	mir_md5_word_t xbuf[16];
	const mir_md5_word_t *X;

	{
		/*
		* Determine dynamically whether this is a big-endian or
		* little-endian machine, since we can use a more efficient
		* algorithm on the latter.
		*/
		static const int w = 1;

		if (*((const mir_md5_byte_t *)&w)) /* dynamic little-endian */
		{
			/*
			* On little-endian machines, we can process properly aligned
			* data without copying it.
			*/
			if (!((data - (const mir_md5_byte_t *)0) & 3)) {
				/* data are properly aligned */
				X = (const mir_md5_word_t *)data;
			} else {
				/* not aligned */
				memcpy(xbuf, data, 64);
				X = xbuf;
			}
		}
		else      /* dynamic big-endian */
		{
			/*
			* On big-endian machines, we must arrange the bytes in the
			* right order.
			*/
			const mir_md5_byte_t *xp = data;
			int i;

			X = xbuf;    /* (dynamic only) */
			for (i = 0; i < 16; ++i, xp += 4)
				xbuf[i] = xp[0] + (xp[1] << 8) + (xp[2] << 16) + (xp[3] << 24);
		}
	}

#define ROTATE_LEFT(x, n) (((x) << (n)) | ((x) >> (32 - (n))))

	/* Round 1. */
	/* Let [abcd k s i] denote the operation
	a = b + ((a + F(b,c,d) + X[k] + T[i]) <<< s). */
#define F(x, y, z) (((x) & (y)) | (~(x) & (z)))
#define SET1(a, b, c, d, k, s, Ti)\
	t = a + F(b,c,d) + X[k] + Ti;\
	a = ROTATE_LEFT(t, s) + b
	/* Do the following 16 operations. */
	SET1(a, b, c, d,  0,  7,  T1);
	SET1(d, a, b, c,  1, 12,  T2);
	SET1(c, d, a, b,  2, 17,  T3);
	SET1(b, c, d, a,  3, 22,  T4);
	SET1(a, b, c, d,  4,  7,  T5);
	SET1(d, a, b, c,  5, 12,  T6);
	SET1(c, d, a, b,  6, 17,  T7);
	SET1(b, c, d, a,  7, 22,  T8);
	SET1(a, b, c, d,  8,  7,  T9);
	SET1(d, a, b, c,  9, 12, T10);
	SET1(c, d, a, b, 10, 17, T11);
	SET1(b, c, d, a, 11, 22, T12);
	SET1(a, b, c, d, 12,  7, T13);
	SET1(d, a, b, c, 13, 12, T14);
	SET1(c, d, a, b, 14, 17, T15);
	SET1(b, c, d, a, 15, 22, T16);

	/* Round 2. */
	/* Let [abcd k s i] denote the operation
	a = b + ((a + G(b,c,d) + X[k] + T[i]) <<< s). */
#define G(x, y, z) (((x) & (z)) | ((y) & ~(z)))
#define SET2(a, b, c, d, k, s, Ti)\
	t = a + G(b,c,d) + X[k] + Ti;\
	a = ROTATE_LEFT(t, s) + b
	/* Do the following 16 operations. */
	SET2(a, b, c, d,  1,  5, T17);
	SET2(d, a, b, c,  6,  9, T18);
	SET2(c, d, a, b, 11, 14, T19);
	SET2(b, c, d, a,  0, 20, T20);
	SET2(a, b, c, d,  5,  5, T21);
	SET2(d, a, b, c, 10,  9, T22);
	SET2(c, d, a, b, 15, 14, T23);
	SET2(b, c, d, a,  4, 20, T24);
	SET2(a, b, c, d,  9,  5, T25);
	SET2(d, a, b, c, 14,  9, T26);
	SET2(c, d, a, b,  3, 14, T27);
	SET2(b, c, d, a,  8, 20, T28);
	SET2(a, b, c, d, 13,  5, T29);
	SET2(d, a, b, c,  2,  9, T30);
	SET2(c, d, a, b,  7, 14, T31);
	SET2(b, c, d, a, 12, 20, T32);

	/* Round 3. */
	/* Let [abcd k s t] denote the operation
	a = b + ((a + H(b,c,d) + X[k] + T[i]) <<< s). */
#define H(x, y, z) ((x) ^ (y) ^ (z))
#define SET3(a, b, c, d, k, s, Ti)\
	t = a + H(b,c,d) + X[k] + Ti;\
	a = ROTATE_LEFT(t, s) + b
	/* Do the following 16 operations. */
	SET3(a, b, c, d,  5,  4, T33);
	SET3(d, a, b, c,  8, 11, T34);
	SET3(c, d, a, b, 11, 16, T35);
	SET3(b, c, d, a, 14, 23, T36);
	SET3(a, b, c, d,  1,  4, T37);
	SET3(d, a, b, c,  4, 11, T38);
	SET3(c, d, a, b,  7, 16, T39);
	SET3(b, c, d, a, 10, 23, T40);
	SET3(a, b, c, d, 13,  4, T41);
	SET3(d, a, b, c,  0, 11, T42);
	SET3(c, d, a, b,  3, 16, T43);
	SET3(b, c, d, a,  6, 23, T44);
	SET3(a, b, c, d,  9,  4, T45);
	SET3(d, a, b, c, 12, 11, T46);
	SET3(c, d, a, b, 15, 16, T47);
	SET3(b, c, d, a,  2, 23, T48);

	/* Round 4. */
	/* Let [abcd k s t] denote the operation
	a = b + ((a + I(b,c,d) + X[k] + T[i]) <<< s). */
#define I(x, y, z) ((y) ^ ((x) | ~(z)))
#define SET4(a, b, c, d, k, s, Ti)\
	t = a + I(b,c,d) + X[k] + Ti;\
	a = ROTATE_LEFT(t, s) + b
	/* Do the following 16 operations. */
	SET4(a, b, c, d,  0,  6, T49);
	SET4(d, a, b, c,  7, 10, T50);
	SET4(c, d, a, b, 14, 15, T51);
	SET4(b, c, d, a,  5, 21, T52);
	SET4(a, b, c, d, 12,  6, T53);
	SET4(d, a, b, c,  3, 10, T54);
	SET4(c, d, a, b, 10, 15, T55);
	SET4(b, c, d, a,  1, 21, T56);
	SET4(a, b, c, d,  8,  6, T57);
	SET4(d, a, b, c, 15, 10, T58);
	SET4(c, d, a, b,  6, 15, T59);
	SET4(b, c, d, a, 13, 21, T60);
	SET4(a, b, c, d,  4,  6, T61);
	SET4(d, a, b, c, 11, 10, T62);
	SET4(c, d, a, b,  2, 15, T63);
	SET4(b, c, d, a,  9, 21, T64);

	/* Then perform the following additions. (That is increment each
	of the four registers by the value it had before this block
	was started.) */
	pms->abcd[0] += a;
	pms->abcd[1] += b;
	pms->abcd[2] += c;
	pms->abcd[3] += d;
}

void md5_init(mir_md5_state_t *pms)
{
	pms->count[0] = pms->count[1] = 0;
	pms->abcd[0] = 0x67452301;
	pms->abcd[1] = /*0xefcdab89*/ T_MASK ^ 0x10325476;
	pms->abcd[2] = /*0x98badcfe*/ T_MASK ^ 0x67452301;
	pms->abcd[3] = 0x10325476;
}

void md5_append(mir_md5_state_t *pms, const mir_md5_byte_t *data, int nbytes)
{
	const mir_md5_byte_t *p = data;
	int left = nbytes;
	int offset = (pms->count[0] >> 3) & 63;
	mir_md5_word_t nbits = (mir_md5_word_t)(nbytes << 3);

	if (nbytes <= 0)
		return;

	/* Update the message length. */
	pms->count[1] += nbytes >> 29;
	pms->count[0] += nbits;
	if (pms->count[0] < nbits)
		pms->count[1]++;

	/* Process an initial partial block. */
	if (offset) {
		int copy = (offset + nbytes > 64 ? 64 - offset : nbytes);

		memcpy(pms->buf + offset, p, copy);
		if (offset + copy < 64)
			return;
		p += copy;
		left -= copy;
		md5_process(pms, pms->buf);
	}

	/* Process full blocks. */
	for (; left >= 64; p += 64, left -= 64)
		md5_process(pms, p);

	/* Process a final partial block. */
	if (left)
		memcpy(pms->buf, p, left);
}

void md5_finish(mir_md5_state_t *pms, mir_md5_byte_t digest[16])
{
	static const mir_md5_byte_t pad[64] = {
		0x80, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	};
	mir_md5_byte_t data[8];
	int i;

	/* Save the length before padding. */
	for (i = 0; i < 8; ++i)
		data[i] = (mir_md5_byte_t)(pms->count[i >> 2] >> ((i & 3) << 3));
	/* Pad to 56 bytes mod 64. */
	md5_append(pms, pad, ((55 - (pms->count[0] >> 3)) & 63) + 1);
	/* Append the length. */
	md5_append(pms, data, 8);
	for (i = 0; i < 16; ++i)
		digest[i] = (mir_md5_byte_t)(pms->abcd[i >> 2] >> ((i & 3) << 3));
}

void md5_hash_string(const mir_md5_byte_t *data, int len, mir_md5_byte_t digest[16])
{
	mir_md5_state_t state;
	md5_init(&state);
	md5_append(&state, data, len);
	md5_finish(&state, digest);
}

