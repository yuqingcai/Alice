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
#include <algorithm>
#include <cfloat>
#include <stdio.h>
#include <sys/time.h>

using namespace std;

static long timestamp_ms()
{
    struct timeval te;
    gettimeofday(&te, NULL);
    long ms = te.tv_sec * 1000LL + te.tv_usec / 1000;
    return ms;
}

// red:     0 - 255
// green:   0 - 255
// blue:    0 - 255
// alpha:   0 - 100
void rgb2hsb(int red, int green, int blue, int* hue, int* saturation, int* brightness) {
    float r = float(red) / 255.0;
    float g = float(green) / 255.0;
    float b = float(blue) / 255.0;
    
    float cmax = max({r, g, b});
    float cmin = min({r, g, b});
    float delta = cmax - cmin;
    
    float h = 0.0;
    if (delta < FLT_EPSILON) {
        h = 0.0;
    }
    else {
        if (fabs(cmax - r) < FLT_EPSILON) {
            h = fmod(60.0 * ((g - b) / delta) + 360.0, 360.0);
        }
        else if (fabs(cmax - g) < FLT_EPSILON) {
            h = fmod(60.0 * ((b - r) / delta) + 120, 360.0);
        }
        else if (fabs(cmax - b) < FLT_EPSILON) {
            h = fmod(60.0 * ((r - g) / delta) + 240.0, 360.0);
        }
    }
    
    float s = 0.0;
    if (cmax < FLT_EPSILON) {
        s = 0.0;
    }
    else {
        s = delta / cmax;
    }
    
    b = cmax;
        
    // hue:         0 - 360
    // saturation:  0 - 100
    // brightness:  0 - 100
    // alpha:       0 - 100
    *hue = int(h+0.5);
    if (*hue < 0) {
        *hue = 0;
    }
    else if (*hue > 360) {
        *hue = 360;
    }
    
    *saturation = int(s*100.0+0.5);
    if (*saturation < 0) {
        *saturation = 0;
    }
    else if (*saturation > 100) {
        *saturation = 100;
    }
    
    *brightness = int(b*100.0+0.5);
    if (*brightness < 0) {
        *brightness = 0;
    }
    else if (*brightness > 100) {
        *brightness = 100;
    }
}

// hue:             0 - 360
// saturation:      0 - 100
// brightness:      0 - 100
// alpha:           0 - 100
static void hsb2rgb(int hue, int saturation, int brightness, int* red, int* green, int* blue) {
    if (hue > 360 || hue < 0 || saturation > 100 || saturation < 0 || brightness > 100 || brightness < 0) {
        *red = 0;
        *green = 0;
        *blue = 0;
        return;
    }
    
    float h = float(hue);
    float s = float(saturation)/100.0;
    float v = float(brightness)/100.0;
    
    float C = s * v;
    float X = C * (1 - abs(fmod(h / 60.0, 2) - 1));
    float m = v - C;
    float r = 0.0;
    float g = 0.0;
    float b = 0.0;
    
    if (h >= 0 && h < 60) {
        r = C;
        g = X;
        b = 0;
    }
    else if (h >= 60 && h < 120) {
        r = X;
        g = C;
        b = 0;
    }
    else if (h >= 120 && h < 180) {
        r = 0;
        g = C;
        b = X;
    }
    else if (h >= 180 && h < 240) {
        r = 0;
        g = X;
        b = C;
    }
    else if (h >= 240 && h < 300) {
        r = X;
        g = 0;
        b = C;
    }
    else {
        r = C;
        g = 0;
        b = X;
    }
    
    *red = int((r + m) * 255.0 + 0.5);
    *green = int((g + m) * 255.0 + 0.5);
    *blue = int((b + m) * 255.0 + 0.5);
}

struct DominantColor* DominantColorByFrequenceFromBitmapBuffer(const unsigned char *ptr, unsigned int bytesPerRow, unsigned int colorCount, unsigned int offsetX, unsigned int offsetY, unsigned int sampleWidth, unsigned int sampleHeight, unsigned int redOrder, unsigned int greenOrder, unsigned int blueOrder, unsigned int alphaOrder)
{
    long m0 = timestamp_ms();
    vector<array<int, 3>> data;
        
    for (int y = 0; y < sampleHeight; y ++) {
        for (int x = 0; x < sampleWidth; x ++) {
            const unsigned char* rgba = &ptr[(offsetY + y)*bytesPerRow + (offsetX + x)*4];
            int r = rgba[redOrder];
            int g = rgba[greenOrder];
            int b = rgba[blueOrder];
            data.push_back({(int)r, (int)g, (int)b});
        }
    }
    
    auto cluster = dkm::kmeans_lloyd(data, colorCount);
    auto means = get<0>(cluster);
    auto labels = get<1>(cluster);
    vector<unsigned int> weights(means.size(), 0);
    
    for (auto iter = labels.begin(); iter != labels.end(); iter ++) {
        for (int i = 0; i < means.size(); i ++) {
            if (*iter == i) {
                weights[i] ++;
                break;
            }
        }
    }
    fprintf(stdout, "data count: %lu\n", data.size());
    fprintf(stdout, "labels count: %lu\n", labels.size());
    
    struct DominantColor* dominant = (struct DominantColor*)malloc(sizeof(struct DominantColor));
    dominant->count = (unsigned int)means.size();
    dominant->colors = (struct RawColor*)malloc(sizeof(struct RawColor)*means.size());
        
    for (int i = 0; i < means.size(); i ++) {
        const auto& mean = means[i];
        dominant->colors[i].blue = (int)(mean[2]);
        dominant->colors[i].green = (int)(mean[1]);
        dominant->colors[i].red = (int)(mean[0]);
        dominant->colors[i].alpha = (int)(100);
        dominant->colors[i].weight = weights[i];
    }
    
    long m1 = timestamp_ms();
    fprintf(stdout, "frequence sample cost: %lu ms\n", m1 - m0);
    
    return dominant;
}


struct DominantColor* DominantColorBySensitiveFromBitmapBuffer(const unsigned char *ptr, unsigned int bytesPerRow, unsigned int colorCount, unsigned int offsetX, unsigned int offsetY, unsigned int sampleWidth, unsigned int sampleHeight, unsigned int redOrder, unsigned int greenOrder, unsigned int blueOrder, unsigned int alphaOrder)
{
    long m0 = timestamp_ms();
    vector<array<int, 3>> data;
    
    for (int y = 0; y < sampleHeight; y ++) {
        for (int x = 0; x < sampleWidth; x ++) {
            const unsigned char* rgba = &ptr[(offsetY + y)*bytesPerRow + (offsetX + x)*4];
            int r = rgba[redOrder];
            int g = rgba[greenOrder];
            int b = rgba[blueOrder];
            int hue = 0;
            int saturation = 0;
            int brightness = 0;
            rgb2hsb(r, g, b, &hue, &saturation, &brightness);
            data.push_back({hue, saturation, brightness});
        }
    }
    
    auto cluster = dkm::kmeans_lloyd(data, colorCount);
    auto means = get<0>(cluster);
    auto labels = get<1>(cluster);
    
    vector<vector<int>> clusterIndex(means.size());
    for (int i = 0; i < labels.size(); i ++) {
        clusterIndex[labels[i]].push_back(i);
    }

    vector<int> maxSensitive(clusterIndex.size(), 0);
    for (int i = 0; i < clusterIndex.size(); i ++) {
        auto indexes = clusterIndex[i];
        
        maxSensitive[i] = -1;
        if (indexes.size() > 0) {
            maxSensitive[i] = indexes[0];
            for (int j = 0; j < indexes.size(); j ++) {
                auto hsb0 = data[maxSensitive[i]];
                auto hsb1 = data[indexes[j]];

                if ((hsb1[1] * hsb1[2]) > (hsb0[1]*hsb0[2])) {
                    maxSensitive[i] = j;
                }
            }
        }
    }
        
    struct DominantColor* dominant = (struct DominantColor*)malloc(sizeof(struct DominantColor));
    dominant->count = colorCount;
    dominant->colors = (struct RawColor*)malloc(sizeof(struct RawColor)*colorCount);
    
    for (int i = 0; i < colorCount; i ++) {
        int r = 0, g = 0, b = 0;
        
        if (maxSensitive[i] != -1) {
            auto hsb = data[maxSensitive[i]];
            hsb2rgb(hsb[0], hsb[1], hsb[2], &r, &g, &b);
        }
        
//        const auto& mean = means[i];
//        hsb2rgb(mean[0], mean[1], mean[2], &r, &g, &b);
        dominant->colors[i].red = r;
        dominant->colors[i].green = g;
        dominant->colors[i].blue = b;
        dominant->colors[i].alpha = (int)(100);
        dominant->colors[i].weight = 100;
    }
    
    long m1 = timestamp_ms();
    fprintf(stdout, "saturation sample cost: %lu ms\n", m1 - m0);
    
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
