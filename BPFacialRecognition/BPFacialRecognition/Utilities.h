//
//  Utilities.h
//  BPFacialRecognition
//
//  Created by Robby Cohen on 2/17/14.
//  Copyright (c) 2014 BP. All rights reserved.
//

#ifndef BPFacialRecognition_Utilities_h
#define BPFacialRecognition_Utilities_h
#include <errno.h>
#include <Accelerate/Accelerate.h>

extern void check_alloc_error(int code);
extern void vDSP_vadd(
                      const float *__vDSP_A,
                      vDSP_Stride  __vDSP_IA,
                      const float *__vDSP_B,
                      vDSP_Stride  __vDSP_IB,
                      float       *__vDSP_C,
                      vDSP_Stride  __vDSP_IC,
                      vDSP_Length  __vDSP_N);


#endif
