//
//  cq.h
//  DaVinci
//
//  Created by Yu Qing Cai on 2022/11/2.
//

#ifndef cq_h
#define cq_h

#include <stdio.h>
#include <stdlib.h>


unsigned int*
CQFilter(const unsigned char *ptr,
         int width,
         int height,
         int bytesPerRow,
         int colorCount);

#endif /* cq_h */
