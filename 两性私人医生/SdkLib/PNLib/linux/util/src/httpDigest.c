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

#include "Md5.h"
#include <string.h>
#include "httpDigest.h"


void CvtHex(IN HASH Bin, OUT HASHHEX Hex)
{
    unsigned short i;
    unsigned char j;

    for (i = 0; i < HASHLEN; i++) {
        j = (Bin[i] >> 4) & 0xf;
        if (j <= 9)
            Hex[i*2] = (j + '0');
         else
            Hex[i*2] = (j + 'a' - 10);
        j = Bin[i] & 0xf;
        if (j <= 9)
            Hex[i*2+1] = (j + '0');
         else
            Hex[i*2+1] = (j + 'a' - 10);
    };
    Hex[HASHHEXLEN] = '\0';
};

/* calculate H(A1) as per spec */
void DigestCalcHA1(
    IN char * pszAlg,
    IN char * pszUserName,
    IN char * pszRealm,
    IN char * pszPassword,
    IN char * pszNonce,
    IN char * pszCNonce,
    OUT HASHHEX SessionKey
    )
{
	mir_md5_state_t Md5Ctx;
	HASH HA1;

	md5_init(&Md5Ctx);
	md5_append(&Md5Ctx, pszUserName, strlen(pszUserName));
	md5_append(&Md5Ctx, ":", 1);
	md5_append(&Md5Ctx, pszRealm, strlen(pszRealm));
	md5_append(&Md5Ctx, ":", 1);
	md5_append(&Md5Ctx, pszPassword, strlen(pszPassword));
	md5_finish(&Md5Ctx, HA1);
	if (strcasecmp(pszAlg, "md5-sess") == 0) 
	{
		md5_init(&Md5Ctx);
		md5_append(&Md5Ctx, HA1, HASHLEN);
		md5_append(&Md5Ctx, ":", 1);
		md5_append(&Md5Ctx, pszNonce, strlen(pszNonce));
		md5_append(&Md5Ctx, ":", 1);
		md5_append(&Md5Ctx, pszCNonce, strlen(pszCNonce));
		md5_finish(&Md5Ctx, HA1);
	};

	CvtHex(HA1, SessionKey);
};
		  
/* calculate request-digest/response-digest as per HTTP Digest spec */
void DigestCalcResponse(
  IN HASHHEX HA1,			/* H(A1) */
  IN char * pszNonce,		/* nonce from server */
  IN char * pszNonceCount,	/* 8 hex digits */
  IN char * pszCNonce,		/* client nonce */
  IN char * pszQop, 		/* qop-value: "", "auth", "auth-int" */
  IN char * pszMethod,		/* method from the request */
  IN char * pszDigestUri,	/* requested URL */
  IN HASHHEX HEntity,		/* H(entity body) if qop="auth-int" */
  OUT HASHHEX Response		/* request-digest or response-digest */
  )
{
	mir_md5_state_t Md5Ctx;
	HASH HA2;
	HASH RespHash;
	 HASHHEX HA2Hex;

	// calculate H(A2)
	md5_init(&Md5Ctx);
	md5_append(&Md5Ctx, pszMethod, strlen(pszMethod));
	md5_append(&Md5Ctx, ":", 1);
	md5_append(&Md5Ctx, pszDigestUri, strlen(pszDigestUri));
	if (strcasecmp(pszQop, "auth-int") == 0)
	{
		md5_append(&Md5Ctx, ":", 1);
		md5_append(&Md5Ctx, HEntity, HASHHEXLEN);
	};
	md5_finish(&Md5Ctx, HA2);
	CvtHex(HA2, HA2Hex);

	// calculate response
	md5_init(&Md5Ctx);
	md5_append(&Md5Ctx, HA1, HASHHEXLEN);
	md5_append(&Md5Ctx, ":", 1);
	md5_append(&Md5Ctx, pszNonce, strlen(pszNonce));
	md5_append(&Md5Ctx, ":", 1);
	if (*pszQop) 
	{
		md5_append(&Md5Ctx, pszNonceCount, strlen(pszNonceCount));
		md5_append(&Md5Ctx, ":", 1);
		md5_append(&Md5Ctx, pszCNonce, strlen(pszCNonce));
		md5_append(&Md5Ctx, ":", 1);
		md5_append(&Md5Ctx, pszQop, strlen(pszQop));
		md5_append(&Md5Ctx, ":", 1);
	};
  	md5_append(&Md5Ctx, HA2Hex, HASHHEXLEN);
  	md5_finish(&Md5Ctx, RespHash);
  	CvtHex(RespHash, Response);
};
				


