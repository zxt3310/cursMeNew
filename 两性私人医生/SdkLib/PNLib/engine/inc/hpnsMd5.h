/******************************************************************* 
* Copyright (c) 2010 by Hesine Technologies, Inc. 
* All rights reserved. 
* 
* This file is proprietary and confidential to Hesine Technologies. 
* No part of this file may be reproduced, stored, transmitted, 
* disclosed or used in any form or by any means other than as 
* expressly provided by the written permission from Jianhui Tao 
* 
* ****************************************************************/

#ifndef _hpns_md5_header_
#define _hpns_md5_header_

int hpnsAuthenticateMsg(UINT8 *pMsg, int msgLen, UINT8 *pAuth, UINT8 *pKey);
int hpnsBuildAuthHeader(UINT8 *pMsg, int msgLen, UINT8 *pAuth, UINT8 *pKey);

#endif
