//
//  ColorSchemeGenerator.swift
//  Alice
//
//  Created by Yu Qing Cai on 2023/1/21.
//

import UIKit

enum ColorSchemeGeneratorType {
    case colorSample
    case colorCompose
    case unknow
}

let StringColorSample = "Color Sample"
let StringColorCompose = "Color Compose"
let StringAnalogous = "Analogous"
let StringMonochromatic = "Monochromatic"
let StringTriad = "Triad"
let StringComplementary = "Complementary"
let StringSquare = "Square"
let StringSplitComplementary = "Split Complementary"
let StringCustom = "Custom"
let StringUnknow = "Unknow"

func ColorSchemeGeneratorTypeString(type: ColorSchemeGeneratorType) -> String {
    switch (type) {
    case .colorSample:
        return StringColorSample
    case .colorCompose:
        return StringColorCompose
    case .unknow:
        return StringUnknow
    }
}

func ColorSchemeGeneratorTypeFrom(typeString: String?) -> ColorSchemeGeneratorType {
    guard let typeString = typeString else {
        return .unknow
    }
    
    if typeString.caseInsensitiveCompare(StringColorSample) == .orderedSame {
        return .colorSample
    }
    else if typeString.caseInsensitiveCompare(StringColorCompose) == .orderedSame {
        return .colorCompose
    }
    return .unknow
}

enum ColorComposeType {
    case analogous
    case monochromatic
    case triad
    case complementary
    case square
    case splitComplementary
    case custom
    case unknow
}

func ColorComposeTypeString(type: ColorComposeType?) -> String {
    guard let type = type else {
        return StringUnknow
    }
    
    switch (type) {
    case .analogous:
        return StringAnalogous
    case .monochromatic:
        return StringMonochromatic
    case .triad:
        return StringTriad
    case .complementary:
        return StringComplementary
    case .square:
        return StringSquare
    case .splitComplementary:
        return StringSplitComplementary
    case .custom:
        return StringCustom
    case .unknow:
        return StringUnknow
    }
}

func ColorComposeTypeFrom(typeString: String) -> ColorComposeType {
    if typeString.caseInsensitiveCompare(StringAnalogous) == .orderedSame {
        return .analogous
    }
    else if typeString.caseInsensitiveCompare(StringMonochromatic) == .orderedSame {
        return .monochromatic
    }
    else if typeString.caseInsensitiveCompare(StringTriad) == .orderedSame {
        return .triad
    }
    else if typeString.caseInsensitiveCompare(StringComplementary) == .orderedSame {
        return .complementary
    }
    else if typeString.caseInsensitiveCompare(StringSquare) == .orderedSame {
        return .square
    }
    else if typeString.caseInsensitiveCompare(StringSplitComplementary) == .orderedSame {
        return .splitComplementary
    }
    else if typeString.caseInsensitiveCompare(StringCustom) == .orderedSame {
        return .custom
    }
    return .unknow
}

protocol ColorSchemeGenerator {
    func set(name: String?)
    func getName() -> String
    func getType() -> ColorSchemeGeneratorType
    func getId() -> UUID
    func set(photo: UIImage)
    func getPhoto() -> UIImage?
    func updateScheme(colorCount: Int, frame: CGRect, index: Int)
    func setScheme(frame: CGRect, index: Int)
    func setScheme(colorCount: Int, index: Int)
    func removeScheme(index: Int)
    func sample(colorCount: Int, frame: CGRect)
    func getThumbnail() -> UIImage?
    func getSchemes() -> Array<ColorScheme>?
    func getPortraitScheme() -> ColorScheme?
    func getActivedSchemeIndex() -> Int?
    func setActivedSchemeIndex(_ index: Int)
    func getActivedColorIndex() -> Int?
    func setActivedColorIndex(_ index: Int)
    func getKeyColorIndex() -> Int?
    func setKeyColorIndex(_ index: Int)
    func getExtensionSchemes() -> Array<ColorScheme>?
    func snapshoot() -> Snapshoot?
    func restore(by snapshoot: Snapshoot)
    func clear()
    func getColorComposeType() -> ColorComposeType?
    func setColorComposeType(type: ColorComposeType)
    func getPortrait() -> PortraitView?
    func getHues() -> Array<CGFloat>?
    func set(selector: Int, hue: Int32?, saturation: Int32?, brightness: Int32?)
    
}
