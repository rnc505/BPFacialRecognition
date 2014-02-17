//
//  Utilities.c
//  BPFacialRecognition
//
//  Created by Robby Cohen on 2/17/14.
//  Copyright (c) 2014 BP. All rights reserved.
//

#include <stdlib.h>
#include <stdio.h>
#include "Utilities.h"
void check_alloc_error(int code) {
    if(code != 0) {
        switch (code) {
            case EINVAL:
//                @"The alignment argument was not a power of two, or was not a multiple of sizeof(void *)."
                exit(-1);
                break;
                
            case ENOMEM:
//                NSLog(@"There was insufficient memory to fulfill the allocation request.");
                exit(-1);
                break;
            default:
                break;
        }
    }
}