//
//  WebViewBasePattern.swift
//  Alice
//
//  Created by Yu Qing Cai on 2023/4/13.
//

import UIKit

class WebViewBasePattern: NSObject {
    static let sharedInstance = WebViewBasePattern()
    private let patternFolder = "ColorPattern"
    
    private override init() {
        super.init()
        copyResourceToDocument()
    }
    
    func getPatternDirectory() -> URL? {
        guard let documentDirectory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true) else {
            return nil
        }
                
        let directory = documentDirectory.appendingPathComponent(patternFolder)
        if FileManager.default.fileExists(atPath: directory.path, isDirectory: nil) == false {
            do {
                try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
            } catch {
                print("create thumbnail directory error: \(error).")
            }
        }
        return directory
    }
    
    func copyResourceToDocument() {
        guard let patternDirectory = getPatternDirectory() else {
            return
        }
        
        let resourceFolders = [
            "images"
        ]
        
        for folder in resourceFolders {
            let source = Bundle.main.bundleURL.appendingPathComponent(patternFolder).appendingPathComponent(folder)
            let target = patternDirectory.appendingPathComponent(folder)
                    
            if FileManager.default.fileExists(atPath: target.path) {
                try? FileManager.default.removeItem(atPath: target.path)
            }
            
            try? FileManager.default.copyItem(atPath: source.path, toPath: target.path)
        }
        
    }
    
    func style(name: String, items: [String : String]) -> URL? {
        guard let templateURL = Bundle.main.url(forResource: name, withExtension: "css", subdirectory: "\(patternFolder)/template/css"), let data = try? Data(contentsOf: templateURL) else {
            return nil
        }
                    
        var targetString = String(decoding: data, as: UTF8.self)
            
        for item in items {
            let regex = "\\{\\{\\s*"+item.key+"\\s*\\}\\}"
            targetString = targetString.replacingOccurrences(of: regex, with: item.value, options: [.regularExpression])
        }
        
        return saveCSS(targetString, with: name)
    }
    
    private func saveCSS(_ content: String, with name: String) -> URL? {
        guard let savePath = getPatternDirectory()?.appendingPathComponent("\(name).css") else {
            return nil
        }
        
        do {
            let data = content.data(using: .utf8)
            try data?.write(to: savePath)
        } catch {
            print("save snapshoot thumbnail error: \(error).")
            return nil
        }
        return savePath
    }
    
    func generate(name: String, styleURLs: Array<URL>) -> URL? {
        guard let templateURL = Bundle.main.url(forResource: name, withExtension: "html", subdirectory: "\(patternFolder)/template/html"), let data = try? Data(contentsOf: templateURL) else {
            return nil
        }
        
        var targetString = String(decoding: data, as: UTF8.self)
        
        var styleLinksString = ""
        for url in styleURLs {
            styleLinksString += "<link rel=\"stylesheet\" type=\"text/css\" href=\"\(url.path)\" />\n"
        }
        
        let regex = "\\{\\{\\s*style-sheet-links\\s*\\}\\}"
        targetString = targetString.replacingOccurrences(of: regex, with: styleLinksString, options: [.regularExpression])
        
        return saveHtml(targetString, with: name)
    }
    
    private func saveHtml(_ content: String, with name: String) -> URL? {
        guard let savePath = getPatternDirectory()?.appendingPathComponent("\(name).html") else {
            return nil
        }
        
        do {
            let data = content.data(using: .utf8)
            try data?.write(to: savePath)
        } catch {
            print("save snapshoot thumbnail error: \(error).")
            return nil
        }
        return savePath
    }
    
}
