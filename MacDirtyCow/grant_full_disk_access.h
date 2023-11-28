//
//  grant_full_disk_access.h
//  AltStore
//
//  Created by June P on 2023/11/28.
//  Copyright © 2023 SideStore. All rights reserved.
//

#ifndef grant_full_disk_access_h
#define grant_full_disk_access_h
@import Foundation;

/// Uses CVE-2022-46689 to grant the current app read/write access outside the sandbox.
void grant_full_disk_access(void (^_Nonnull completion)(NSError* _Nullable));
bool patch_installd(void);
#endif /* grant_full_disk_access_h */
