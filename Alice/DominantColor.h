//
//  DominantColor.h
//  Alice
//
//  Created by Yu Qing Cai on 2022/11/8.
//

#ifndef DominantColor_h
#define DominantColor_h


#ifdef __cplusplus
extern "C" {
#endif

struct RgbawColor {
    unsigned char blue;
    unsigned char green;
    unsigned char red;
    unsigned char alpha;
    unsigned int weight;
};

struct DominantColor {
    unsigned int count;
    struct RgbawColor* colors;
};

struct DominantColor*
DominantColorFromBitmapBuffer(const unsigned char *ptr,
                              unsigned int bytesPerRow,
                              unsigned int colorCount,
                              unsigned int offsetX,
                              unsigned int offsetY,
                              unsigned int sampleWidth,
                              unsigned int sampleHeight);
void FreeDominantColor(struct DominantColor* dominant);

#ifdef __cplusplus
}
#endif


#endif /* DominantColor_h */
