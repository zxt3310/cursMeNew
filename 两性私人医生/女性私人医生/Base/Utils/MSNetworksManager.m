/*******************************************************************************
 * iPhone-Wireless Project : Stumbler                                          *
 * Copyright (C) 2007-2008 Pumpkin <pumpkingod@gmail.com>                      *
 * Copyright (C) 2007-2008 Lokkju <lokkju@gmail.com>                           *
 *******************************************************************************
 * $LastChangedDate:: 2008-01-30 05:02:23 +0800 (Wed, 30 Jan 2008)           $ *
 * $LastChangedBy:: lokkju                                                   $ *
 * $LastChangedRevision:: 140                                                $ *
 * $Id:: MSNetworksManager.m 140 2008-01-29 21:02:23Z lokkju                 $ *
 *******************************************************************************
 *  This program is free software: you can redistribute it and/or modify       *
 *  it under the terms of the GNU General Public License as published by       *
 *  the Free Software Foundation, either version 3 of the License, or          *
 *  (at your option) any later version.                                        *
 *                                                                             *
 *  This program is distributed in the hope that it will be useful,            *
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of             *
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the              *
 *  GNU General Public License for more details.                               *
 *                                                                             *
 *  You should have received a copy of the GNU General Public License          *
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.      *
 *******************************************************************************/

/* $HeadURL: http://iphone-wireless.googlecode.com/svn/trunk/Stumbler/MSNetworksManager.m $ */

#import "MSNetworksManager.h"
#import <SystemConfiguration/CaptiveNetwork.h>



static MSNetworksManager *NetworksManager;


@implementation WiFiData

- (NSString *)description
{
    return [NSString stringWithFormat:@"WiFiData SSID: %@ BSSID: %@", _SSID, _BSSID];
}

@end


@implementation MSNetworksManager

+ (MSNetworksManager *)sharedNetworksManager
{
	if (!NetworksManager)
		NetworksManager = [[MSNetworksManager alloc] init];
	return NetworksManager;
}

+ (NSNumber *)numberFromBSSID:(NSString *) bssid
{
	int x = 0;
	uint64_t longmac = 0;
	int MAC_LEN = 6;
	short unsigned int *bs_in = malloc(sizeof(short unsigned int) * MAC_LEN);
	if (sscanf([bssid cStringUsingEncoding: [NSString defaultCStringEncoding]],"%hX:%hX:%hX:%hX:%hX:%hX",&bs_in[0], &bs_in[1], &bs_in[2], &bs_in[3], &bs_in[4], &bs_in[5]) == MAC_LEN)
	{
		for (x = 0; x < MAC_LEN; x++)
     longmac |= (uint64_t) bs_in[x] << ((MAC_LEN - x - 1) * 8);
	} else {
		NSLog(@"WARN: invalid mac address! %@",self);
	}
	free(bs_in);
	return [NSNumber numberWithUnsignedLongLong:longmac];
}

- (NSDictionary *)networks
{
	// TODO: Implement joining of network types
	return networks;
}
- (NSDictionary *)networks:(int) type
{
	// TODO: Implement selecting of network types
	if(type != 0)
		NSLog(@"WARN: Non 80211 networks are not supported. %@",self);
	return networks;
}
- (NSDictionary *)network:(NSString *) aNetwork
{
	return [networks objectForKey: aNetwork];
}
- (id)init
{
	self = [super init];
    if (self) {
        NetworksManager = self;
        networks = [[NSMutableDictionary alloc] init];
        types = [NSArray arrayWithObjects:@"80211", @"Bluetooth", @"GSM", nil];
        autoScanInterval = 5; //seconds
        libHandle = dlopen("/System/Library/Frameworks/Preferences.framework/Preferences", RTLD_LAZY);
//        libHandle = dlopen("/System/Library/SystemConfiguration/WiFiManager.bundle/WiFiManager", RTLD_LAZY);
//        libHandle = dlopen("/System/Library/Frameworks/CoreWiFi.framework/CoreWiFi", RTLD_LAZY);
        if (!libHandle) {
            NSLog(@"load wifi lib failed.");
            return self;
        }
        
        open = dlsym(libHandle, "Apple80211Open");
        bind = dlsym(libHandle, "Apple80211BindToInterface");
        close = dlsym(libHandle, "Apple80211Close");
        scan = dlsym(libHandle, "Apple80211Scan");
        
        open(&airportHandle);
        bind(airportHandle, @"en0");
    }

	return self;
}
- (void)dealloc
{
	close(&airportHandle);
}
- (int)numberOfNetworks
{
	return [networks count];
}
- (int)numberOfNetworks:(int) type
{
	// TODO: Implement selecting of network types
	if(type != 0)
		NSLog(@"WARN: Non 80211 networks are not supported. %@",self);
	return [networks count];
}

- (int)autoScanInterval
{
	return autoScanInterval;
}

- (WiFiData *)getWiFiHotSopt
{
    NSString *ssid = @"Not Found";
    NSString *macIp = @"Not Found";
    CFArrayRef myArray = CNCopySupportedInterfaces();
    if (myArray != nil) {
        CFDictionaryRef myDict = CNCopyCurrentNetworkInfo(CFArrayGetValueAtIndex(myArray, 0));
        if (myDict != nil) {
            NSDictionary *dict = (NSDictionary*)CFBridgingRelease(myDict);
            
            ssid = [dict valueForKey:@"SSID"];
            macIp = [dict valueForKey:@"BSSID"];
        }
    }

    NSLog(@"cur wifi ssid: %@", ssid);
    NSLog(@"cur wifi bssid: %@", macIp);
    NSLog(@"cur allwifi: %@", myArray);
    
    WiFiData *data = [[WiFiData alloc] init];
    data.SSID = ssid;
    data.BSSID = macIp;
    
    return data;
}

- (void)scan
{
	NSLog(@"Scanning...");
	scanning = true;
	[[NSNotificationCenter defaultCenter] postNotificationName:@"startedScanning" object:self];
	NSArray *scan_networks;
	NSDictionary *parameters = [[NSDictionary alloc] init];
	scan(airportHandle, &scan_networks, (__bridge void *)(parameters));
	int i;
	bool changed;
    
    NSLog(@"after wifi scan: %@, params: %@", scan_networks, parameters);

	for (i = 0; i < [scan_networks count]; i++) {
		if([networks objectForKey:[[scan_networks objectAtIndex: i] objectForKey:@"BSSID"]] != nil && ![[networks objectForKey:[[scan_networks objectAtIndex: i] objectForKey:@"BSSID"]] isEqualToDictionary:[scan_networks objectAtIndex: i]])
			changed = true;
		[networks setObject:[scan_networks objectAtIndex: i] forKey:[[scan_networks objectAtIndex: i] objectForKey:@"BSSID"]];
	}
	if(changed) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"NetworksUpdated" object:self];
	}
	scanning = false;
	[[NSNotificationCenter defaultCenter] postNotificationName:@"stoppedScanning" object:self];
	NSLog(@"Scan Finished...");
}
- (void)removeNetwork:(NSString *)aNetwork
{
	[networks removeObjectForKey:aNetwork];
}
- (void)removeAllNetworks
{
	[networks removeAllObjects];
}
- (void)removeAllNetworks:(int) type
{
	if(type != 0)
		NSLog(@"WARN: Non 80211 networks are not supported. %@",self);
	[networks removeAllObjects];
}
- (void)autoScan:(bool) bScan
{
	autoScanning = bScan;
	if(bScan) {
		[self scan];
		[NSTimer scheduledTimerWithTimeInterval:autoScanInterval target:self selector:@selector (scanSelector:) userInfo:nil repeats:NO];
	}
	NSLog(@"WARN: Automatic scanning not fully supported yet. %@",self);
}
- (bool)autoScan
{
	return autoScanning;
}
- (void)scanSelector:(id)param {
	if(autoScanning) {
		[self scan];
		[NSTimer scheduledTimerWithTimeInterval:autoScanInterval target:self selector:@selector (scanSelector:) userInfo:nil repeats:NO];
	}
}
- (void)setAutoScanInterval:(int) scanInterval
{
	autoScanInterval = scanInterval;
}

@end