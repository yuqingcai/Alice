//
//  DominantColor.c
//  Alice
//
//  Created by Yu Qing Cai on 2022/11/8.
//

#include <vector>
#include <set>
#include <string>
#include <iostream>
#include <cmath>
#include <sstream>
#include <iomanip>
#include "DominantColor.h"
#include "dkm.hpp"

struct DominantColor*
DominantColorFromBitmapBuffer(const unsigned char *ptr,
                              unsigned int bytesPerRow,
                              unsigned int colorCount,
                              unsigned int offsetX,
                              unsigned int offsetY,
                              unsigned int sampleWidth,
                              unsigned int sampleHeight)
{
    std::vector<std::array<int, 3>> data;
    
    for (int y = 0; y < sampleHeight; y ++) {
        for (int x = 0; x < sampleWidth; x ++) {
            const unsigned char* rgba = &ptr[(offsetY + y)*bytesPerRow + (offsetX + x)*4];
            
            unsigned char r = rgba[0];
            unsigned char g = rgba[1];
            unsigned char b = rgba[2];
            
            data.push_back({(int)r, (int)g, (int)b});
        }
    }
    
//
//    for (int y = 0; y < bitmapHeight; y ++) {
//        for (int x = 0; x < bitmapWidth; x++) {
//            const unsigned char* rgba = &ptr[y * bytesPerRow + x*4];
//
//            unsigned char r = rgba[0];
//            unsigned char g = rgba[1];
//            unsigned char b = rgba[2];
//
//            data.push_back({(int)r, (int)g, (int)b});
//        }
//    }
    
    auto cluster_data = dkm::kmeans_lloyd(data, colorCount);
    auto means = std::get<0>(cluster_data);
    
    auto labels = std::get<1>(cluster_data);
    std::vector<unsigned int>weights(means.size(), 0);
        
    for (auto iter = labels.begin(); iter != labels.end(); iter++) {
        for (int i = 0; i < means.size(); i ++) {
            if (*iter == i) {
                weights[i] ++;
                break;
            }
        }
    }
        
    struct DominantColor* dominant = (struct DominantColor*)malloc(sizeof(struct DominantColor));
    dominant->count = (unsigned int)means.size();
    dominant->colors = (struct RgbawColor*)malloc(sizeof(struct RgbawColor)*means.size());
        
    for (int i = 0; i < means.size(); i ++) {
        const auto& mean = means[i];
        dominant->colors[i].blue = (unsigned char)(mean[0]);
        dominant->colors[i].green = (unsigned char)(mean[1]);
        dominant->colors[i].red = (unsigned char)(mean[2]);
        dominant->colors[i].alpha = (unsigned char)(255);
        dominant->colors[i].weight = weights[i];
    }

    return dominant;
}

void FreeDominantColor(struct DominantColor* dominant)
{
    if (dominant) {
        if (dominant->colors)
            free(dominant->colors);
        free(dominant);
    }
}
