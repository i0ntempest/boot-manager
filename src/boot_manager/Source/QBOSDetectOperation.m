//
//  QBOSDetectOperation.m
//  Boot Manager
//
//  Created by Jeremy Knope on 8/7/10.
//  Copyright (c) 2010 Ambrosia Software, Inc. All rights reserved.
//

#import "QBOSDetectOperation.h"
#import "QBVolume.h"

@implementation QBOSDetectOperation

+ (QBOSDetectOperation *)detectOperationWithVolume:(QBVolume *)aVolume
{
	return [[[self class] alloc] initWithVolume:aVolume];
}

- (id)initWithVolume:(QBVolume *)aVolume
{
	if((self = [super init]))
	{
		self.volume = aVolume;
	}
	return self;
}


- (void)main
{
	@autoreleasepool {
		NSFileManager *fileManager = [[NSFileManager alloc] init];
		NSString *osName = nil;
		NSString *osVersion = nil;
        NSString *osBuild = nil;
        NSString *osBootLoader = nil;
		BOOL legacy = YES;
        
		// macOS
		NSString *versionPath = [[[[self.volume.disk.volumePath stringByAppendingPathComponent:@"System"]
								   stringByAppendingPathComponent:@"Library"]
								  stringByAppendingPathComponent:@"CoreServices"]
								 stringByAppendingPathComponent:@"SystemVersion.plist"];
		NSString *serverVersionPath = [[[[self.volume.disk.volumePath stringByAppendingPathComponent:@"System"]
																   stringByAppendingPathComponent:@"Library"]
																  stringByAppendingPathComponent:@"CoreServices"]
																 stringByAppendingPathComponent:@"ServerVersion.plist"];
        
        // Winbugs
        NSString *winbugsLegacyPath = [[self.volume.disk.volumePath stringByAppendingPathComponent:@"Windows"]
                                         stringByAppendingPathComponent:@"System32"];
        NSString *winbugsDiscLegacyPath = [[self.volume.disk.volumePath stringByAppendingPathComponent:@"sources"]
                                                    stringByAppendingPathComponent:@"boot.wim"];
        NSString *winbugsDiscEfiPath = [[self.volume.disk.volumePath stringByAppendingPathComponent:@"efi"]
                                           stringByAppendingPathComponent:@"microsoft"];
        
        // Linux EFI
        NSString *fedoraEfiPath = [[self.volume.disk.volumePath stringByAppendingPathComponent:@"EFI"]
                                    stringByAppendingPathComponent:@"fedora"];
        NSString *manjaroEfiPath = [[self.volume.disk.volumePath stringByAppendingPathComponent:@"EFI"]
                                    stringByAppendingPathComponent:@"Manjaro"];
        NSString *ubuntuEfiPath = [[self.volume.disk.volumePath stringByAppendingPathComponent:@"EFI"]
                                    stringByAppendingPathComponent:@"ubuntu"];
        NSString *ubuntuEliloEfiPath = [[[self.volume.disk.volumePath stringByAppendingPathComponent:@"EFI"]
                                    stringByAppendingPathComponent:@"ubuntu"] stringByAppendingPathComponent:@"elilo.efi"];
        NSString *ubuntuGrubEfiPath = [[[self.volume.disk.volumePath stringByAppendingPathComponent:@"EFI"]
                                        stringByAppendingPathComponent:@"ubuntu"] stringByAppendingPathComponent:@"grubx64.efi"];
        NSString *debianEfiPath = [[self.volume.disk.volumePath stringByAppendingPathComponent:@"EFI"]
                                   stringByAppendingPathComponent:@"debian"];
        NSString *centosEfiPath = [[self.volume.disk.volumePath stringByAppendingPathComponent:@"EFI"]
                                   stringByAppendingPathComponent:@"centos"];
        NSString *slackwareEfiPath = [[self.volume.disk.volumePath stringByAppendingPathComponent:@"EFI"]
                                   stringByAppendingPathComponent:@"Slackware"];
        NSString *suseEfiPath = [[self.volume.disk.volumePath stringByAppendingPathComponent:@"EFI"]
                                   stringByAppendingPathComponent:@"SuSE"];
        
        // Linux BIOS
        NSString *linuxLegacyPath = [[self.volume.disk.volumePath stringByAppendingPathComponent:@"usr"]
                                 stringByAppendingPathComponent:@"bin"];
        NSString *linuxDiscLegacyPath = [[self.volume.disk.volumePath stringByAppendingPathComponent:@"isolinux"]
                                         stringByAppendingPathComponent:@"isolinux.bin"];
        
        // Bootloaders
        NSString *grubEfiPath = [[[self.volume.disk.volumePath stringByAppendingPathComponent:@"EFI"]
                                   stringByAppendingPathComponent:@"BOOT"] stringByAppendingPathComponent:@"grubx64.efi"];
        NSString *eliloEfiPath = [[[self.volume.disk.volumePath stringByAppendingPathComponent:@"EFI"]
                                   stringByAppendingPathComponent:@"elilo"] stringByAppendingPathComponent:@"elilo.efi"];
        NSString *nextloaderEfiPath = [[self.volume.disk.volumePath stringByAppendingPathComponent:@"loader"]
                                   stringByAppendingPathComponent:@"loader.efi"];
        
        BOOL isDir;
        
        /**
         * Winbugs detection
         */
		if([fileManager fileExistsAtPath:winbugsLegacyPath isDirectory:&isDir])
		{
			if(isDir)
			{
                osName = @"Windows"; // Winbugs
				legacy = YES;
			}
		}
        else if([fileManager fileExistsAtPath:winbugsDiscEfiPath isDirectory:&isDir])
        {
            if(isDir)
            {
                osName = @"Windows"; // Winbugs EFI Installation Environment
                
                if ([[self.volume.disk filesystem] isEqualToString:@"udf"] || [[self.volume.disk filesystem] isEqualToString:@"cd9660"]) {
                    legacy = YES;
                } else {
                    legacy = NO;
                }
            }
        }
        else if([fileManager fileExistsAtPath:winbugsDiscLegacyPath])
        {
            osName = @"Windows"; // Winbugs Legacy Installation Environment
            legacy = YES;
        }
        
        /**
         * macOS detection
         */
        else if([fileManager fileExistsAtPath:versionPath])
        {
            NSDictionary *version = [NSDictionary dictionaryWithContentsOfFile:versionPath];
            osName = @"macOS"; // macOS
            osVersion = [version objectForKey:@"ProductUserVisibleVersion"];
            osBuild = [version objectForKey:@"ProductBuildVersion"];
            legacy = NO;
        }
        else if([fileManager fileExistsAtPath:serverVersionPath])
        {
            NSDictionary *version = [NSDictionary dictionaryWithContentsOfFile:versionPath];
            osName = @"macOS Server %@/%@"; // macOS Server
            osVersion = [version objectForKey:@"ProductUserVisibleVersion"];
            osBuild = [version objectForKey:@"ProductBuildVersion"];
            legacy = NO;
        }

        /**
         * Linux EFI detection
         */
        else if([fileManager fileExistsAtPath:fedoraEfiPath isDirectory:&isDir])
        {
            if(isDir)
            {
                osName = @"Fedora"; // Linux Fedora
                legacy = NO;
            }
        }
        else if([fileManager fileExistsAtPath:manjaroEfiPath isDirectory:&isDir])
        {
            if(isDir)
            {
                osName = @"Manjaro"; // Linux Manjaro
                legacy = NO;
            }
        }
        else if([fileManager fileExistsAtPath:ubuntuEliloEfiPath])
        {
            osName = @"Ubuntu"; // Linux Ubuntu (ELILO)
            osBootLoader = @"/EFI/ubuntu/elilo.efi";
            legacy = NO;
        }
        else if([fileManager fileExistsAtPath:ubuntuGrubEfiPath])
        {
            osName = @"Ubuntu"; // Linux Ubuntu (GRUB)
            osBootLoader = @"/EFI/ubuntu/grubx64.efi";
            legacy = NO;
        }
        else if([fileManager fileExistsAtPath:ubuntuEfiPath isDirectory:&isDir])
        {
            if(isDir)
            {
                osName = @"Ubuntu"; // Linux Ubuntu
                legacy = NO;
            }
        }
        else if([fileManager fileExistsAtPath:debianEfiPath isDirectory:&isDir])
        {
            if(isDir)
            {
                osName = @"Debian"; // Linux Debian
                osBootLoader = @"/EFI/debian/grubx64.efi";
                legacy = NO;
            }
        }
        else if([fileManager fileExistsAtPath:centosEfiPath isDirectory:&isDir])
        {
            if(isDir)
            {
                osName = @"CentOS"; // Linux CentOS
                osBootLoader = @"/EFI/centos/shim.efi";
                legacy = NO;
            }
        }
        else if([fileManager fileExistsAtPath:slackwareEfiPath isDirectory:&isDir])
        {
            if(isDir)
            {
                osName = @"Slackware"; // Linux Slackware
                osBootLoader = @"/EFI/Slackware/elilo.efi";
                legacy = NO;
            }
        }
        else if([fileManager fileExistsAtPath:suseEfiPath isDirectory:&isDir])
        {
            if(isDir)
            {
                osName = @"Open Suse"; // Linux Open Suse
                osBootLoader = @"/EFI/SuSE/elilo.efi";
                legacy = NO;
            }
        }

        /**
         * Linux BIOS detection
         */
        else if([fileManager fileExistsAtPath:linuxLegacyPath])
        {
            osName = @"Linux"; // Generic Legacy Linux
            legacy = YES;
        }
        else if([fileManager fileExistsAtPath:linuxDiscLegacyPath])
        {
            osName = @"Linux"; // Generic Legacy Linux Installation Disc
            legacy = YES;
        }
        
        /**
         * Bootloaders detection
         */
        else if([fileManager fileExistsAtPath:grubEfiPath])
        {
            osName = @"GRUB"; // GRUB
            osBootLoader = @"/EFI/BOOT/grubx64.efi";
            legacy = NO;
        }
        else if([fileManager fileExistsAtPath:eliloEfiPath])
        {
            osName = @"ELILO"; // ELILO
            osBootLoader = @"/EFI/elilo/elilo.efi";
            legacy = NO;
        }
        else if([fileManager fileExistsAtPath:nextloaderEfiPath])
        {
            osName = @"Next Loader"; // Next Loader
            legacy = NO;
        }
		else
		{
			osName = nil;
		}
		
		// update volume object
		self.volume.systemName = osName;
		self.volume.legacyOS = legacy;
		self.volume.systemVersion = osVersion;
        self.volume.systemBuildNumber = osBuild;
        self.volume.systemBootLoader = osBootLoader;

	}
	
    id <QBOSDetectOperationDelegate>delegate = self.delegate;
	
    dispatch_async(dispatch_get_main_queue(), ^{
        if([delegate respondsToSelector:@selector(detectOperation:finishedScanningVolume:)])
        {
            [delegate detectOperation:self finishedScanningVolume:self.volume];
        }
    });
}

@end
