//
//  International.swift
//  Alice
//
//  Created by Yu Qing Cai on 2023/2/20.
//

import Foundation

class LanguageDesignators: NSObject {
    var language: String? = nil
    var script: String? = nil
    var region: String? = nil
    
    init(languageID: String) {
        
        language = nil
        script = nil
        region = nil
                
        // Apple language ID format: [language]-[script]-[region]
        //
        //  zh-Hans-HK
        //  |  |    |
        //  |  |    + region
        //  |  |
        //  |  + script
        //  |
        //  + language
        //
        guard let regex = try? NSRegularExpression(pattern: "(\\w+)-(\\w+)-(\\w+)") else {
            super.init()
            return
        }
        
        var results = regex.matches(in: languageID, range: NSRange(languageID.startIndex..., in: languageID))
        if (results.count != 0) {
            let result = results[0]
                // language
            var range = result.range(at: 1)
            var startIndex = languageID.index(languageID.startIndex, offsetBy: range.location)
            var endIndex = languageID.index(languageID.startIndex, offsetBy: range.location+range.length)
            language = String(languageID[startIndex..<endIndex])
            
                // script
            range = result.range(at: 2)
            startIndex = languageID.index(languageID.startIndex, offsetBy: range.location)
            endIndex = languageID.index(languageID.startIndex, offsetBy: range.location+range.length)
            script = String(languageID[startIndex..<endIndex])
            
                // region
            range = result.range(at: 3)
            startIndex = languageID.index(languageID.startIndex, offsetBy: range.location)
            endIndex = languageID.index(languageID.startIndex, offsetBy: range.location+range.length)
            region = String(languageID[startIndex..<endIndex])
            
            super.init()
            return
        }
        
        // Apple language ID format: [language]-[region]
        //
        //  en-us
        //  |  |
        //  |  + region
        //  |
        //  + language
        //
        guard let regex = try? NSRegularExpression(pattern: "(\\w+)-(\\w+)") else {
            super.init()
            return
        }
        
        results = regex.matches(in: languageID, range: NSRange(languageID.startIndex..., in: languageID))
        if (results.count != 0) {
            let result = results[0]
            // language
            var range = result.range(at: 1)
            var startIndex = languageID.index(languageID.startIndex, offsetBy: range.location)
            var endIndex = languageID.index(languageID.startIndex, offsetBy: range.location+range.length)
            language = String(languageID[startIndex..<endIndex])
            
            // region
            range = result.range(at: 2)
            startIndex = languageID.index(languageID.startIndex, offsetBy: range.location)
            endIndex = languageID.index(languageID.startIndex, offsetBy: range.location+range.length)
            region = String(languageID[startIndex..<endIndex])
            super.init()
            return
        }
        
        super.init()
        return
    }
}

func languageString(_ languageID: String) -> String {
    var language = "English"
    
    let designators = LanguageDesignators(languageID: languageID)
    
    if let languageDesignator = designators.language, let scriptDesignator = designators.script {
        // Chinese
        if (languageDesignator.caseInsensitiveCompare("zh") == .orderedSame) {
            if (scriptDesignator.caseInsensitiveCompare("Hans") == .orderedSame) {
                language = "ChineseSimplified"
            }
            else if (scriptDesignator.caseInsensitiveCompare("Hant") == .orderedSame) {
                language = "ChineseTraditional"
            }
        }
        else if (languageDesignator.caseInsensitiveCompare("en") == .orderedSame) {
            language = "English"
        }
        else if (languageDesignator.caseInsensitiveCompare("ja") == .orderedSame) {
            language = "Japanese"
        }
        else if (languageDesignator.caseInsensitiveCompare("de") == .orderedSame) {
            language = "German"
        }
        else if (languageDesignator.caseInsensitiveCompare("it") == .orderedSame) {
            language = "Italian"
        }
        else if (languageDesignator.caseInsensitiveCompare("fr") == .orderedSame) {
            language = "French"
        }
        else if (languageDesignator.caseInsensitiveCompare("es") == .orderedSame) {
            language = "Spanish"
        }
        else if (languageDesignator.caseInsensitiveCompare("pt") == .orderedSame) {
            language = "Portuguese"
        }
        else if (languageDesignator.caseInsensitiveCompare("tr") == .orderedSame) {
            language = "Turkish"
        }
        else if (languageDesignator.caseInsensitiveCompare("ko") == .orderedSame) {
            language = "Korean"
        }
    }
    else {
        let startIndex = languageID.index(languageID.startIndex, offsetBy: 0)
        let endIndex = languageID.index(languageID.startIndex, offsetBy: 2)
        let languageDesignator = String(languageID[startIndex..<endIndex])
        
        if (languageDesignator.caseInsensitiveCompare("zh") == .orderedSame) {
            language = "ChineseTraditional"
        }
        else if (languageDesignator.caseInsensitiveCompare("en") == .orderedSame) {
            language = "English"
        }
        else if (languageDesignator.caseInsensitiveCompare("ja") == .orderedSame) {
            language = "Japanese"
        }
        else if (languageDesignator.caseInsensitiveCompare("de") == .orderedSame) {
            language = "German"
        }
        else if (languageDesignator.caseInsensitiveCompare("it") == .orderedSame) {
            language = "Italian"
        }
        else if (languageDesignator.caseInsensitiveCompare("fr") == .orderedSame) {
            language = "French"
        }
        else if (languageDesignator.caseInsensitiveCompare("es") == .orderedSame) {
            language = "Spanish"
        }
        else if (languageDesignator.caseInsensitiveCompare("pt") == .orderedSame) {
            language = "Portuguese"
        }
        else if (languageDesignator.caseInsensitiveCompare("tr") == .orderedSame) {
            language = "Turkish"
        }
        else if (languageDesignator.caseInsensitiveCompare("ko") == .orderedSame) {
            language = "Korean"
        }
    }
    
    return language
    
}
