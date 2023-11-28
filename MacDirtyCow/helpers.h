//
//  helpers.h
//  AltStore
//
//  Created by June P on 2023/11/28.
//  Copyright © 2023 SideStore. All rights reserved.
//

#ifndef helpers_h
#define helpers_h

char* get_temp_file_path(void);
void test_nsexpressions(void);
char* set_up_tmp_file(void);

void xpc_crasher(char* service_name);

#define ROUND_DOWN_PAGE(val) (val & ~(PAGE_SIZE - 1ULL))

#endif /* helpers_h */
