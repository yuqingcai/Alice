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

struct RGBAWColor {
    int blue;
    int green;
    int red;
    int alpha;
    int weight;
};

struct DominantColor {
    unsigned int count;
    struct RGBAWColor* colors;
};

struct DominantColor* DominantColorFromBitmapBuffer(const unsigned char *ptr,
                                                    unsigned int bytesPerRow,
                                                    unsigned int colorCount,
                                                    unsigned int offsetX,
                                                    unsigned int offsetY,
                                                    unsigned int sampleWidth,
                                                    unsigned int sampleHeight,
                                                    unsigned int redOrder,
                                                    unsigned int greenOrder,
                                                    unsigned int blueOrder,
                                                    unsigned int alphaOrder);
void FreeDominantColor(struct DominantColor* dominant);

#ifdef __cplusplus
}
#endif


#endif /* DominantColor_h */
