//
//  Settings.swift
//  Alice
//
//  Created by Yu Qing Cai on 2023/3/27.
//

import UIKit

class Settings {
    static let sharedInstance = Settings()
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let settingsFilePath = Snapshoot.getDocumentDirectory().appendingPathComponent("Coloury.json")
    let domainName = "coloury.io"
    var displayName = "Coloury"
    var marketingVersion = "1.0"
    let sampleDirectoryInBundle = "Sample"
    let sampleTypes =  [ "jpg", "png" ]
    
    private let subscriptionActiveString = "active"
    private let subscriptionDeactiveString = "deactive"
    
    var isSubscriptionActive: Bool {
        didSet {
            save()
        }
    }
    
    var manualURL: URL? {
        get {
            let URLString = "https://www.\(domainName)/manual/\(localLanguagePrefix())/index.html"
            print(URLString)
            return URL(string: URLString)
        }
    }
    
    var privacyPolicyURL: URL? {
        get {
            let URLString = "https://www.\(domainName)/privacy-policy/\(localLanguagePrefix())/index.html"
            print(URLString)
            return URL(string: URLString)
        }
    }
    
    var userLicenseURL: URL? {
        get {
            let URLString = "https://www.\(domainName)/terms-and-conditions/\(localLanguagePrefix())/index.html"
            print(URLString)
            return URL(string: URLString)
        }
    }
    
    init() {
        isSubscriptionActive = false
        if let displayName = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String, let marketingVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String {
            self.displayName = displayName
            self.marketingVersion = marketingVersion
        }
        
        if (FileManager.default.fileExists(atPath: settingsFilePath.path) == false) {
            recoverSamples() // recover samples
            createConfigureFile()
        }
    }
    
    func load() {
        if let data = try? Data(contentsOf: settingsFilePath), let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String : String] {
            if json["subscription"]?.compare(subscriptionActiveString, options: .caseInsensitive) == .orderedSame {
                isSubscriptionActive = true
            }
            else if json["subscription"]?.compare(subscriptionDeactiveString, options: .caseInsensitive) == .orderedSame {
                isSubscriptionActive = false
            }
        }
    }
    
    func createConfigureFile() {
        // save current settings to default
        save()
    }
    
    func save() {
        var string = "{"
        
        if isSubscriptionActive == true {
            string += "\"subscription\" : \"\(subscriptionActiveString)\","
        }
        else {
            string += "\"subscription\" : \"\(subscriptionDeactiveString)\","
        }
        
        string += "\"displayName\" : \"\(displayName)\","
        string += "\"version\" : \"\(marketingVersion)\""
        string += "}"

        print("save settings: \(string)")
        
        if let data = string.data(using: .utf8), let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers), let jsonData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted) {
            try? jsonData.write(to: settingsFilePath)
        }
    }
    
    func localLanguagePrefix() -> String {
        var prefix = "en"
        let languageDesignators = LanguageDesignators(languageID: NSLocale.preferredLanguages[0])
        
        if let language = languageDesignators.language {
            if (language.caseInsensitiveCompare("zh") == .orderedSame) {
                if let script = languageDesignators.script {
                    if (script.caseInsensitiveCompare("Hant") == .orderedSame) {
                        prefix = "zh-Hant"
                    }
                    else if (script.caseInsensitiveCompare("Hans") == .orderedSame) {
                        prefix = "zh-Hans"
                    }
                }
                
                if let region = languageDesignators.region {
                    if (region.caseInsensitiveCompare("Hant") == .orderedSame) {
                        prefix = "zh-Hant"
                    }
                    else if (region.caseInsensitiveCompare("Hans") == .orderedSame) {
                        prefix = "zh-Hans"
                    }
                }
            }
            else if (language.caseInsensitiveCompare("en") == .orderedSame ||
                language.caseInsensitiveCompare("ja") == .orderedSame ||
                language.caseInsensitiveCompare("de") == .orderedSame ||
                language.caseInsensitiveCompare("it") == .orderedSame ||
                language.caseInsensitiveCompare("fr") == .orderedSame ||
                language.caseInsensitiveCompare("es") == .orderedSame ||
                language.caseInsensitiveCompare("pt") == .orderedSame ||
                language.caseInsensitiveCompare("tr") == .orderedSame ||
                language.caseInsensitiveCompare("ko") == .orderedSame) {
                prefix = language
            }
        }
        return prefix
    }

    func recoverSamples() {
        
        guard let generator = appDelegate.colorSampler, let localLibrary = appDelegate.localLibrary else {
            return
        }

        var samplePaths: [String] = []
        for sampleType in sampleTypes {
            samplePaths += Bundle.main.paths(forResourcesOfType: sampleType, inDirectory: sampleDirectoryInBundle)
        }

        samplePaths = samplePaths.sorted(by: >)

        for path in samplePaths {
            if let photo = UIImage(contentsOfFile: path) {

                let name = ((path as NSString).lastPathComponent as NSString).deletingPathExtension

                generator.set(photo: photo)
                generator.set(name: name)
                if let snapshoot = generator.snapshoot() {
                    localLibrary.save(snapshoot: snapshoot)
                }
                generator.clear()
            }
        }
    }

    
}
