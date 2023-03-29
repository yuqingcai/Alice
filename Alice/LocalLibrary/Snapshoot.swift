//
//  Snapshoot.swift
//  Alice
//
//  Created by Yu Qing Cai on 2022/12/19.
//

import UIKit

class Snapshoot : NSObject {
    var uuid: UUID
    var name: String
    var type: ColorSchemeGeneratorType
    var photo: UIImage?
    var thumbnail: UIImage?
    var schemes: Array<ColorScheme>?
    var activedSchemeIndex: Int?
    var activedColorIndex: Int?
    var photoSavePath: String?
    var thumbnailSavePath: String?
    var createDateTime: Date
    var modifiedDateTime: Date
    var colorComposeType: ColorComposeType?
    var keyColorIndex: Int?
    static let photoCopyType = "jpg"
    static let thumbnailCopyType = "jpg"
    
    init (generator: ColorSchemeGenerator, createDateTime: Date, modifiedDateTime: Date) {
        
        self.type = generator.getType()
        self.uuid = generator.getId()
        self.name = generator.getName()
        self.photo = generator.getPhoto()
        self.schemes = generator.getSchemes()
        self.activedSchemeIndex = generator.getActivedSchemeIndex()
        self.activedColorIndex = generator.getActivedColorIndex()
        self.thumbnail = generator.getThumbnail()
        self.photoSavePath = Snapshoot.getPhotoDirectory().appendingPathComponent(self.uuid.uuidString).appendingPathExtension(Snapshoot.photoCopyType).path
        self.thumbnailSavePath =  Snapshoot.getThumbnailDirectory().appendingPathComponent(self.uuid.uuidString).appendingPathExtension(Snapshoot.thumbnailCopyType).path
        self.createDateTime = createDateTime
        self.modifiedDateTime = modifiedDateTime
        self.colorComposeType = generator.getColorComposeType()
        self.keyColorIndex = generator.getKeyColorIndex()
        super.init()
    }
    
    init (uuid: UUID, type: ColorSchemeGeneratorType, photoSavePath: String?, thumbnailSavePath: String?, schemes: Array<ColorScheme>, activedSchemeIndex: Int?, activedColorIndex: Int?, createDateTime: Date, modifiedDateTime: Date, name: String, colorComposeType: ColorComposeType?, keyColorIndex: Int?) {
        
        self.type = type
        self.uuid = uuid
        self.name = name
        self.photo = nil
        self.schemes = schemes
        self.activedSchemeIndex = activedSchemeIndex
        self.thumbnail = nil
        self.photoSavePath = photoSavePath
        self.thumbnailSavePath = thumbnailSavePath
        self.createDateTime = createDateTime
        self.modifiedDateTime = modifiedDateTime
        self.activedColorIndex = activedColorIndex
        self.colorComposeType = colorComposeType
        self.keyColorIndex = keyColorIndex
        
        super.init()
        
        if let photoSavePath = self.photoSavePath, let image = UIImage(contentsOfFile: photoSavePath) {
            self.photo = image
        }
        
        if let thumbnailSavePath = self.thumbnailSavePath, let image = UIImage(contentsOfFile: thumbnailSavePath) {
            self.thumbnail = image
        }
    }
    
    static func getThumbnailDirectory() -> URL {
        let documentDirectory = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let directory = documentDirectory.appendingPathComponent("Thumbnails")
        if FileManager.default.fileExists(atPath: directory.path, isDirectory: nil) == false {
            do {
                try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
            } catch {
                print("create thumbnail directory error: \(error).")
            }
        }
        return directory
    }
    
    static func getPhotoDirectory() -> URL {
        let documentDirectory = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let directory = documentDirectory.appendingPathComponent("Photos")
        if FileManager.default.fileExists(atPath: directory.path, isDirectory: nil) == false {
            do {
                try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
            } catch {
                print("create photo directory error: \(error).")
            }
        }
        return directory
    }
    
    static func getShareTempDirectory() -> URL {
        let documentDirectory = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let directory = documentDirectory.appendingPathComponent("ShareTemp")
        if FileManager.default.fileExists(atPath: directory.path, isDirectory: nil) == false {
            do {
                try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
            } catch {
                print("create shareTemp directory error: \(error).")
            }
        }
        return directory
    }
    
    static func getDocumentDirectory() -> URL {
        let documentDirectory = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        
        return documentDirectory
    }
    
        
    func serialize() -> String {
        var string = "{"
        
        string += "\"uuid\" : \"\(uuid.uuidString)\","
        string += "\"create_date_time\" : \"\(Snapshoot.string(from: createDateTime, format:nil))\","
        string += "\"modified_date_time\" : \"\(Snapshoot.string(from: modifiedDateTime, format:nil))\","
        string += "\"name\" : \"\(name)\","
        string += "\"type\" : \"\(ColorSchemeGeneratorTypeString(type: type))\","
        
        if type == .colorSample {
            
            if let activedSchemeIndex = activedSchemeIndex {
                string += String(format: "\"activedSchemeIndex\" : %d,", activedSchemeIndex)
            }
            
            if let keyColorIndex = keyColorIndex {
                string += String(format: "\"keyColoredIndex\" : %d,", keyColorIndex)
            }
            
            string = string.appending("\"schemes\" : [")
            
            if let schemes = schemes {
                for i in 0 ..< schemes.count {
                    let scheme = schemes[i]
                    string += "{"
                    
                    string += String(format: "\"frame\" : {\"x\" : %f, \"y\" : %f, \"width\" : %f, \"height\" : %f},", scheme.frame.origin.x, scheme.frame.origin.y, scheme.frame.size.width, scheme.frame.size.height)
                    
                    string += "\"items\" : ["
                    for j in 0 ..< scheme.items.count {
                        let item = scheme.items[j]
                        string += "{"
                        
                        if let red = item.red {
                            string += String(format: "\"red\" : %d,", red)
                        }
                        
                        if let green = item.green {
                            string += String(format: "\"green\" : %d,", green)
                        }
                        
                        if let blue = item.blue {
                            string += String(format: "\"blue\" : %d,", blue)
                        }
                        
                        if let hue = item.hue {
                            string += String(format: "\"hue\" : %d,", hue)
                        }
                        
                        if let saturation = item.saturation {
                            string += String(format: "\"saturation\" : %d,", saturation)
                        }
                        
                        if let brightness = item.brightness {
                            string += String(format: "\"brightness\" : %d,", brightness)
                        }
                        
                        if let alpha = item.alpha {
                            string += String(format: "\"alpha\" : %d,", alpha)
                        }
                        
                        if let weight = item.weight {
                            string += String(format: "\"weight\" : %d", weight)
                        }
                        
                        string += "}"
                        
                        if j < scheme.items.count - 1 {
                            string += ","
                        }
                    }
                    string += "]"
                    
                    string += "}"
                    if i < schemes.count - 1 {
                        string += ","
                    }
                }
            }
                        
            string += "]"
            
        }
        else if type == .colorCompose {
            
            if let activedSchemeIndex = activedSchemeIndex {
                string += String(format: "\"activedSchemeIndex\" : %d,", activedSchemeIndex)
            }
            
            if let activedColorIndex = activedColorIndex {
                string += String(format: "\"activedColorIndex\" : %d,", activedColorIndex)
            }
            
            var type = "unknow"
            if let colorComposeType = colorComposeType {
                type = ColorComposeTypeString(type: colorComposeType)
                string += "\"colorComposeType\": \"\(type)\","
            }
            
            if let keyColorIndex = keyColorIndex {
                string += String(format: "\"keyColoredIndex\" : %d,", keyColorIndex)
            }
            
            string = string.appending("\"schemes\" : [")
            
            if let schemes = schemes {
                for i in 0 ..< schemes.count {
                    let scheme = schemes[i]
                    string += "{"
                    
                    string += String(format: "\"frame\" : {\"x\" : %f, \"y\" : %f, \"width\" : %f, \"height\" : %f},", scheme.frame.origin.x, scheme.frame.origin.y, scheme.frame.size.width, scheme.frame.size.height)
                    
                    string += "\"items\" : ["
                    for j in 0 ..< scheme.items.count {
                        let item = scheme.items[j]
                        string += "{"
                        
                        if let red = item.red {
                            string += String(format: "\"red\" : %d,", red)
                        }
                        
                        if let green = item.green {
                            string += String(format: "\"green\" : %d,", green)
                        }
                        
                        if let blue = item.blue {
                            string += String(format: "\"blue\" : %d,", blue)
                        }
                        
                        if let hue = item.hue {
                            string += String(format: "\"hue\" : %d,", hue)
                        }
                        
                        if let saturation = item.saturation {
                            string += String(format: "\"saturation\" : %d,", saturation)
                        }
                        
                        if let brightness = item.brightness {
                            string += String(format: "\"brightness\" : %d,", brightness)
                        }
                        
                        if let alpha = item.alpha {
                            string += String(format: "\"alpha\" : %d,", alpha)
                        }
                        
                        if let weight = item.weight {
                            string += String(format: "\"weight\" : %d", weight)
                        }
                                                
                        string += "}"
                        
                        if j < scheme.items.count - 1 {
                            string += ","
                        }
                    }
                    string += "]"
                    
                    string += "}"
                    if i < schemes.count - 1 {
                        string += ","
                    }
                }
            }
                        
            string += "]"
        }
        
        string += "}"
        return string
    }
    
    static func string(from date:Date, format:String?) -> String {
        let formatter = DateFormatter()
        if format == nil {
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        }
        else {
            formatter.dateFormat = format
        }
        let string = formatter.string(from: date)
        return string
    }
    
    static func dateTime(from string:String, format:String?) -> Date? {
        let formatter = DateFormatter()
        if format == nil {
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        }
        else {
            formatter.dateFormat = format
        }
        let date = formatter.date(from: string)
        return date
    }
    
    static func deserialize(descriptor: String) -> Snapshoot? {
        var uuid: UUID? = nil
        var type: ColorSchemeGeneratorType? = nil
        var snapshoot: Snapshoot? = nil
        var createDateTime: Date? = nil
        var modifiedDateTime: Date? = nil
        var name: String? = nil
        
        guard let object = cJSON_Parse(descriptor) else {
            let error = cJSON_GetErrorPtr();
            if error != nil {
                print(String(format:"Error: %s", error!));
            }
            return nil;
        }
        
        if let uuidItem = cJSON_GetObjectItemCaseSensitive(object, "uuid") {
            uuid = UUID(uuidString: String(cString:uuidItem.pointee.valuestring))
        }
        
        if let nameItem = cJSON_GetObjectItemCaseSensitive(object, "name") {
            name = String(cString:nameItem.pointee.valuestring)
        }
        
        if let createDateTimeItem = cJSON_GetObjectItemCaseSensitive(object, "create_date_time") {
            createDateTime = Snapshoot.dateTime(from: String(cString:createDateTimeItem.pointee.valuestring), format: nil)
        }
        
        if let modifiedDateTimeItem = cJSON_GetObjectItemCaseSensitive(object, "modified_date_time") {
            modifiedDateTime = Snapshoot.dateTime(from: String(cString:modifiedDateTimeItem.pointee.valuestring), format: nil)
        }
                
        if let typeItem = cJSON_GetObjectItemCaseSensitive(object, "type") {
            let str = String(cString: typeItem.pointee.valuestring)
            type = ColorSchemeGeneratorTypeFrom(typeString: str)
        }
        
        if type == .colorSample {
            
            var schemes: Array<ColorScheme> = []
            var activedSchemeIndex: Int? = nil
            var keyColorIndex: Int? = nil
            
            if let schemesItem = cJSON_GetObjectItemCaseSensitive(object, "schemes") {
                var schemeItem: UnsafeMutablePointer<cJSON>? = schemesItem.pointee.child
                while (schemeItem != nil) {
                    let frameItem = cJSON_GetObjectItemCaseSensitive(schemeItem, "frame")
                    let x = cJSON_GetObjectItemCaseSensitive(frameItem, "x").pointee.valuedouble
                    let y = cJSON_GetObjectItemCaseSensitive(frameItem, "y").pointee.valuedouble
                    let width = cJSON_GetObjectItemCaseSensitive(frameItem, "width").pointee.valuedouble
                    let height = cJSON_GetObjectItemCaseSensitive(frameItem, "height").pointee.valuedouble
                    
                    let frame = CGRect(x: x, y: y, width: width, height: height) // frame
                    var items: Array<ColorItem> = []
                    
                    if let itemsItem = cJSON_GetObjectItemCaseSensitive(schemeItem, "items") {
                        var itemItem:UnsafeMutablePointer<cJSON>? = itemsItem.pointee.child
                        while (itemItem != nil) {
                            var red: Int32?
                            if (cJSON_GetObjectItemCaseSensitive(itemItem, "red") != nil) {
                                red = cJSON_GetObjectItemCaseSensitive(itemItem, "red").pointee.valueint
                            }
                            
                            var green: Int32?
                            if (cJSON_GetObjectItemCaseSensitive(itemItem, "green") != nil) {
                                green = cJSON_GetObjectItemCaseSensitive(itemItem, "green").pointee.valueint
                            }
                            
                            var blue: Int32?
                            if (cJSON_GetObjectItemCaseSensitive(itemItem, "blue") != nil) {
                                blue = cJSON_GetObjectItemCaseSensitive(itemItem, "blue").pointee.valueint
                            }
                            
                            var hue: Int32? = nil
                            if (cJSON_GetObjectItemCaseSensitive(itemItem, "hue") != nil) {
                                hue = cJSON_GetObjectItemCaseSensitive(itemItem, "hue").pointee.valueint
                            }
                            
                            var saturation: Int32? = nil
                            if (cJSON_GetObjectItemCaseSensitive(itemItem, "saturation") != nil) {
                                saturation = cJSON_GetObjectItemCaseSensitive(itemItem, "saturation").pointee.valueint
                            }
                            
                            var brightness: Int32? = nil
                            if (cJSON_GetObjectItemCaseSensitive(itemItem, "brightness") != nil) {
                                brightness = cJSON_GetObjectItemCaseSensitive(itemItem, "brightness").pointee.valueint
                            }
                            
                            var alpha: Int32? = nil
                            if (cJSON_GetObjectItemCaseSensitive(itemItem, "alpha") != nil) {
                                alpha = cJSON_GetObjectItemCaseSensitive(itemItem, "alpha").pointee.valueint
                            }
                            
                            var weight: Int32? = nil
                            if (cJSON_GetObjectItemCaseSensitive(itemItem, "weight") != nil) {
                                weight = cJSON_GetObjectItemCaseSensitive(itemItem, "weight").pointee.valueint
                            }
                            
                            if let red = red, let green = green, let blue = blue, let alpha = alpha, let weight = weight {
                                let colorItem = ColorItem(red: red, green: green, blue: blue, alpha: alpha, weight: weight)
                                items.append(colorItem)
                            }
                            itemItem = itemItem?.pointee.next
                        }
                    }
                    schemes.append(ColorScheme(frame: frame, items: items))
                    schemeItem = schemeItem?.pointee.next
                }
                                
                if let activedSchemeIndexItem = cJSON_GetObjectItemCaseSensitive(object, "activedSchemeIndex") {
                    activedSchemeIndex = Int(activedSchemeIndexItem.pointee.valueint)
                }
                
                if let keyColorIndexItem = cJSON_GetObjectItemCaseSensitive(object, "keyColorIndex") {
                    keyColorIndex = Int(keyColorIndexItem.pointee.valueint)
                }
                
                if let uuid = uuid, let type = type, let createDateTime = createDateTime, let modifiedDateTime = modifiedDateTime, let name = name {
                    let photoSavePath =  Snapshoot.getPhotoDirectory().appendingPathComponent(uuid.uuidString).appendingPathExtension(Snapshoot.photoCopyType)
                    let thumbnailSavePath =  Snapshoot.getThumbnailDirectory().appendingPathComponent(uuid.uuidString).appendingPathExtension(Snapshoot.thumbnailCopyType)
                    
                    snapshoot = Snapshoot(uuid: uuid, type: type, photoSavePath: photoSavePath.path, thumbnailSavePath: thumbnailSavePath.path, schemes: schemes, activedSchemeIndex: activedSchemeIndex, activedColorIndex: nil, createDateTime: createDateTime, modifiedDateTime: modifiedDateTime, name: name, colorComposeType: nil, keyColorIndex: keyColorIndex)
                }
            }
            
        }
        else if type == .colorCompose {
            var schemes: Array<ColorScheme> = []
            var activedSchemeIndex: Int? = nil
            var activedColorIndex: Int? = nil
            var colorComposeType: ColorComposeType? = nil
            var keyColorIndex: Int? = nil
            
            if let schemesItem = cJSON_GetObjectItemCaseSensitive(object, "schemes") {
                var schemeItem: UnsafeMutablePointer<cJSON>? = schemesItem.pointee.child
                while (schemeItem != nil) {
                    let frameItem = cJSON_GetObjectItemCaseSensitive(schemeItem, "frame")
                    let x = cJSON_GetObjectItemCaseSensitive(frameItem, "x").pointee.valuedouble
                    let y = cJSON_GetObjectItemCaseSensitive(frameItem, "y").pointee.valuedouble
                    let width = cJSON_GetObjectItemCaseSensitive(frameItem, "width").pointee.valuedouble
                    let height = cJSON_GetObjectItemCaseSensitive(frameItem, "height").pointee.valuedouble
                    
                    let frame = CGRect(x: x, y: y, width: width, height: height) // frame
                    var items: Array<ColorItem> = []
                    
                    if let itemsItem = cJSON_GetObjectItemCaseSensitive(schemeItem, "items") {
                        
                        var itemItem:UnsafeMutablePointer<cJSON>? = itemsItem.pointee.child
                        
                        while (itemItem != nil) {
                            var red: Int32?
                            if (cJSON_GetObjectItemCaseSensitive(itemItem, "red") != nil) {
                                red = cJSON_GetObjectItemCaseSensitive(itemItem, "red").pointee.valueint
                            }
                            
                            var green: Int32?
                            if (cJSON_GetObjectItemCaseSensitive(itemItem, "green") != nil) {
                                green = cJSON_GetObjectItemCaseSensitive(itemItem, "green").pointee.valueint
                            }
                            
                            var blue: Int32?
                            if (cJSON_GetObjectItemCaseSensitive(itemItem, "blue") != nil) {
                                blue = cJSON_GetObjectItemCaseSensitive(itemItem, "blue").pointee.valueint
                            }
                            
                            var hue: Int32? = nil
                            if (cJSON_GetObjectItemCaseSensitive(itemItem, "hue") != nil) {
                                hue = cJSON_GetObjectItemCaseSensitive(itemItem, "hue").pointee.valueint
                            }
                            
                            var saturation: Int32? = nil
                            if (cJSON_GetObjectItemCaseSensitive(itemItem, "saturation") != nil) {
                                saturation = cJSON_GetObjectItemCaseSensitive(itemItem, "saturation").pointee.valueint
                            }
                            
                            var brightness: Int32? = nil
                            if (cJSON_GetObjectItemCaseSensitive(itemItem, "brightness") != nil) {
                                brightness = cJSON_GetObjectItemCaseSensitive(itemItem, "brightness").pointee.valueint
                            }
                            
                            var alpha: Int32? = nil
                            if (cJSON_GetObjectItemCaseSensitive(itemItem, "alpha") != nil) {
                                alpha = cJSON_GetObjectItemCaseSensitive(itemItem, "alpha").pointee.valueint
                            }
                            
                            var weight: Int32? = nil
                            if (cJSON_GetObjectItemCaseSensitive(itemItem, "weight") != nil) {
                                weight = cJSON_GetObjectItemCaseSensitive(itemItem, "weight").pointee.valueint
                            }
                            
                            if let hue = hue, let saturation = saturation, let brightness = brightness, let alpha = alpha, let weight = weight {
                                let colorItem = ColorItem(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha, weight: weight)
                                items.append(colorItem)
                            }
                            itemItem = itemItem?.pointee.next
                        }
                    }
                    schemes.append(ColorScheme(frame: frame, items: items))
                    schemeItem = schemeItem?.pointee.next
                }
                
                if let activedSchemeIndexItem = cJSON_GetObjectItemCaseSensitive(object, "activedSchemeIndex") {
                    activedSchemeIndex = Int(activedSchemeIndexItem.pointee.valueint)
                }
                
                if let activedColorIndexItem = cJSON_GetObjectItemCaseSensitive(object, "activedColorIndex") {
                    activedColorIndex = Int(activedColorIndexItem.pointee.valueint)
                }
                
                if let colorComposeTypeItem = cJSON_GetObjectItemCaseSensitive(object, "colorComposeType") {
                    let typeString = String(cString: colorComposeTypeItem.pointee.valuestring)
                    colorComposeType = ColorComposeTypeFrom(typeString: typeString)
                }
                
                if let keyColorIndexItem = cJSON_GetObjectItemCaseSensitive(object, "keyColorIndex") {
                    keyColorIndex = Int(keyColorIndexItem.pointee.valueint)
                }
                
                if let uuid = uuid, let type = type, let createDateTime = createDateTime, let modifiedDateTime = modifiedDateTime, let name = name, let colorComposeType = colorComposeType {
                    let thumbnailSavePath =  Snapshoot.getThumbnailDirectory().appendingPathComponent(uuid.uuidString).appendingPathExtension(Snapshoot.thumbnailCopyType)
                    snapshoot = Snapshoot(uuid: uuid, type: type, photoSavePath: nil, thumbnailSavePath: thumbnailSavePath.path, schemes: schemes, activedSchemeIndex: activedSchemeIndex, activedColorIndex: activedColorIndex, createDateTime: createDateTime, modifiedDateTime: modifiedDateTime, name: name, colorComposeType: colorComposeType, keyColorIndex: keyColorIndex)
                }
            }
        }
        
        cJSON_Delete(object);
        
        return snapshoot
    }
    
    static func removeAllSharedTempFiles() {
        let urls = FileManager.default.enumerator(at: Snapshoot.getShareTempDirectory(), includingPropertiesForKeys: nil)
        while let url = urls?.nextObject() {
            do {
                try FileManager.default.removeItem(at: url as! URL)
            } catch {
                print(error)
            }
        }
    }
}
