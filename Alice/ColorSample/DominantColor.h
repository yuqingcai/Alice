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

struct RawColor {
    int blue;
    int green;
    int red;
    
    int hue;
    int saturation;
    int brightness;
    
    int alpha;
    int weight;
};

struct DominantColor {
    unsigned int count;
    struct RawColor* colors;
};

struct DominantColor* DominantColorByFrequenceFromBitmapBuffer(const unsigned char *ptr, unsigned int bytesPerRow, unsigned int colorCount, unsigned int offsetX, unsigned int offsetY, unsigned int sampleWidth, unsigned int sampleHeight, unsigned int redOrder, unsigned int greenOrder, unsigned int blueOrder, unsigned int alphaOrder);

struct DominantColor* DominantColorBySensitiveFromBitmapBuffer(const unsigned char *ptr, unsigned int bytesPerRow, unsigned int colorCount, unsigned int offsetX, unsigned int offsetY, unsigned int sampleWidth, unsigned int sampleHeight, unsigned int redOrder, unsigned int greenOrder, unsigned int blueOrder, unsigned int alphaOrder);
    
void FreeDominantColor(struct DominantColor* dominant);

#ifdef __cplusplus
}
#endif


#endif /* DominantColor_h */
