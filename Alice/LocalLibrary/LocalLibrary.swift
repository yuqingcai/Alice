//
//  Library.swift
//  Alice
//
//  Created by Yu Qing Cai on 2022/12/19.
//

import UIKit


enum LocalLibraryOrderType {
    case createDateDescending
    case createDateAscending
    case modifyDateDescending
    case modifyDateAscending
}

class LocalLibrary : NSObject {
    
    static let updateItemsNotification: Notification.Name = Notification.Name("updateItemsNotification")
    
    var snapshootIDs: Array<String>?
    var database: OpaquePointer?
    
    func openDatabase() ->Bool {
        if database != nil {
            return true
        }
        
        let databasePath = getDatabasePath()
                
        if sqlite3_open(databasePath.path, &database) == SQLITE_OK {
            validateTables()
            return true
        }
        else
        {
            print("Unable to open database at \(databasePath)")
        }
        
        return false
    }
    
    func closeDatabase() {
        sqlite3_close(database)
        database = nil
    }
    
    func validateTables() {
        let sql = """
        CREATE TABLE IF NOT EXISTS snap_shoot (
            id                  INTEGER     PRIMARY KEY AUTOINCREMENT   NOT NULL,
            uuid                TEXT                                    NOT NULL,
            name                TEXT                                    NOT NULL,
            type                TEXT                                    NOT NULL,
            descriptor          TEXT                                    NOT NULL,
            create_date_time    DATE                                    NOT NULL,
            modified_date_time  DATE                                    NOT NULL
        );
        """
        var message: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>?
        if (sqlite3_exec(database, sql, nil, nil, message) != SQLITE_OK) {
            sqlite3_free(message);
        }
    }
        
    func getDatabasePath() -> URL {
        let documentDirectory = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        return documentDirectory.appendingPathComponent("database.db")
    }
        
    func save(snapshoot: Snapshoot) {
        // save thumbnail
        if let thumbnailSavePath = snapshoot.thumbnailSavePath, let thumbnail = snapshoot.thumbnail {
            
            var thumbnailData: Data? = nil
            let pathExtension = (thumbnailSavePath as NSString).pathExtension
            
            if (pathExtension.caseInsensitiveCompare("png") == .orderedSame) {
                thumbnailData = snapshoot.thumbnail?.pngData()
            }
            else if (pathExtension.caseInsensitiveCompare("jpg") == .orderedSame ||
                     pathExtension.caseInsensitiveCompare("jpeg") == .orderedSame) {
                thumbnailData = thumbnail.jpegData(compressionQuality: 0.7)
            }
            
            //if FileManager.default.fileExists(atPath: thumbnailSavePath) == false {
                do {
                    try thumbnailData?.write(to: URL(fileURLWithPath: thumbnailSavePath))
                } catch {
                    print("save snapshoot thumbnail error: \(error).")
                    return
                }
            //}
        }
        
        // save photo
        if let photoSavePath = snapshoot.photoSavePath, let photo = snapshoot.photo {
            
            var photoData: Data? = nil
            let pathExtension = (photoSavePath as NSString).pathExtension
            
            if (pathExtension.caseInsensitiveCompare("png") == .orderedSame) {
                photoData = photo.pngData()
            }
            else if (pathExtension.caseInsensitiveCompare("jpg") == .orderedSame ||
                     pathExtension.caseInsensitiveCompare("jpeg") == .orderedSame) {
                photoData = photo.jpegData(compressionQuality: 0.7)
            }
            
            if FileManager.default.fileExists(atPath: photoSavePath) == false {
                do {
                    try photoData?.write(to: URL(fileURLWithPath: photoSavePath))
                } catch {
                    print("save snapshoot photo error: \(error).")
                    return
                }
            }
        }
        
        // create descriptor
        let descriptor = snapshoot.serialize()
        var existed = false
        var stmt: OpaquePointer?
        
        // detect snapshoot if existed
        var sql = "SELECT * FROM snap_shoot WHERE uuid='\(snapshoot.uuid.uuidString)';"
        if sqlite3_prepare_v2(database, sql, -1, &stmt, nil) != SQLITE_OK {
            print("\(sql) error")
            return
        }
        if (sqlite3_step(stmt) == SQLITE_ROW) {
            existed = true;
        }
        sqlite3_finalize(stmt);
        
        if existed == true {
            // update record
            let modifiedDateTimeString = Snapshoot.string(from: snapshoot.modifiedDateTime, format:nil)
            sql = "UPDATE snap_shoot set descriptor='\(descriptor)', modified_date_time='\(modifiedDateTimeString)', name='\(snapshoot.name)' WHERE uuid='\(snapshoot.uuid.uuidString)';"
            if sqlite3_prepare_v2(database, sql, -1, &stmt, nil) != SQLITE_OK {
                print("\(sql) error")
                return
            }
            
            if sqlite3_step(stmt) == SQLITE_DONE {
                sqlite3_finalize(stmt)
                stmt = nil
            }
        }
        else {
            // insert new snapshoot
            sql = "INSERT INTO snap_shoot (uuid, name, type, descriptor, create_date_time, modified_date_time) VALUES (?, ?, ?, ?, ?, ?);"
            if sqlite3_prepare_v2(database, sql, -1, &stmt, nil) != SQLITE_OK {
                print("\(sql) error")
                return
            }
            
            let type = ColorSchemeGeneratorTypeString(type: snapshoot.type)
            let createDateTimeString = Snapshoot.string(from: snapshoot.createDateTime, format:nil)
            let modifiedDateTimeString = Snapshoot.string(from: snapshoot.modifiedDateTime, format:nil)
            sqlite3_bind_text(stmt, 1, (snapshoot.uuid.uuidString as NSString).utf8String, -1, nil);
            sqlite3_bind_text(stmt, 2, (snapshoot.name as NSString).utf8String, -1, nil);
            sqlite3_bind_text(stmt, 3, (type as NSString).utf8String, -1, nil);
            sqlite3_bind_text(stmt, 4, (descriptor as NSString).utf8String, -1, nil);
            sqlite3_bind_text(stmt, 5, (createDateTimeString as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 6, (modifiedDateTimeString as NSString).utf8String, -1, nil)
            
            if sqlite3_step(stmt) == SQLITE_DONE {
                sqlite3_finalize(stmt)
                stmt = nil
            }
        }
        NotificationCenter.default.post(name: LocalLibrary.updateItemsNotification, object: self, userInfo: nil)
    }
    
    func recorded(snapshoot: Snapshoot) -> Bool {
        var existed = false
        var stmt: OpaquePointer?
        // detect snapshoot if existed
        let sql = "SELECT * FROM snap_shoot WHERE uuid='\(snapshoot.uuid.uuidString)';"
        if sqlite3_prepare_v2(database, sql, -1, &stmt, nil) != SQLITE_OK {
            print("\(sql) error")
            return false
        }
        if (sqlite3_step(stmt) == SQLITE_ROW) {
            existed = true;
        }
        sqlite3_finalize(stmt);
        return existed
    }
    
    private func delete(snapshoot: Snapshoot) -> Bool {
        
        if let photoSavePath = snapshoot.photoSavePath {
            if FileManager.default.fileExists(atPath: photoSavePath) {
                try? FileManager.default.removeItem(atPath: photoSavePath)
            }
        }
        
        if let thumbnailSavePath = snapshoot.thumbnailSavePath {
            if FileManager.default.fileExists(atPath: thumbnailSavePath) {
                try? FileManager.default.removeItem(atPath: thumbnailSavePath)
            }
        }
        
        let sql = "DELETE FROM snap_shoot WHERE uuid='\(snapshoot.uuid)';"
        var stmt:OpaquePointer?
        if sqlite3_prepare_v2(database, sql, -1, &stmt, nil) != SQLITE_OK {
            return false
        }
        
        if sqlite3_step(stmt) != SQLITE_DONE {
            sqlite3_finalize(stmt)
            return false
        }
        
        sqlite3_finalize(stmt)
                
        return true
    }
    
    func deleteItems(at items: Array<IndexPath>) -> Bool {
        
        var deleted: Array<Int> = []
        
        for indexPath in items {
            if let snapshoot = snapshoot(at: indexPath.item) {
                if (delete(snapshoot: snapshoot) == true) {
                    deleted.append(indexPath.item)
                }
            }
        }
        
        snapshootIDs?.remove(atOffsets: IndexSet(deleted))
        
        return true
    }
    
    func delete(at indexPath: IndexPath) -> Bool {
        guard let snapshoot = snapshoot(at: indexPath.item) else {
            return false
        }
        let ret = delete(snapshoot: snapshoot)
        snapshootIDs?.remove(at: indexPath.item)
        return ret
    }
    
    func numberOfSnapshootOrderByModifiedDateDescending() -> Int {
        snapshootIDs = []
        
        let sql = "SELECT uuid FROM snap_shoot ORDER BY modified_date_time DESC;"
        var stmt:OpaquePointer?
        
        if sqlite3_prepare_v2(database, sql, -1, &stmt, nil) != SQLITE_OK {
            return 0
        }
        
        repeat {
            if sqlite3_step(stmt) != SQLITE_ROW {
                break;
            }
            snapshootIDs?.append(String(cString: sqlite3_column_text(stmt, 0)))
        } while(true)
        sqlite3_finalize(stmt)
        
        return snapshootIDs?.count ?? 0
    }
    
    func numberOfSnapshootOrderByCreateDateDescending() -> Int {
        snapshootIDs = []
        
        let sql = "SELECT uuid FROM snap_shoot ORDER BY create_date_time DESC;"
        var stmt:OpaquePointer?
        
        if sqlite3_prepare_v2(database, sql, -1, &stmt, nil) != SQLITE_OK {
            return 0
        }
        
        repeat {
            if sqlite3_step(stmt) != SQLITE_ROW {
                break;
            }
            snapshootIDs?.append(String(cString: sqlite3_column_text(stmt, 0)))
        } while(true)
        sqlite3_finalize(stmt)
        
        return snapshootIDs?.count ?? 0
    }
    
    func numberOfSnapshootOrderByModifiedDateAscending() -> Int {
        snapshootIDs = []
        
        let sql = "SELECT uuid FROM snap_shoot ORDER BY modified_date_time ASC;"
        var stmt:OpaquePointer?
        
        if sqlite3_prepare_v2(database, sql, -1, &stmt, nil) != SQLITE_OK {
            return 0
        }
        
        repeat {
            if sqlite3_step(stmt) != SQLITE_ROW {
                break;
            }
            snapshootIDs?.append(String(cString: sqlite3_column_text(stmt, 0)))
        } while(true)
        sqlite3_finalize(stmt)
        
        return snapshootIDs?.count ?? 0
    }
    
    func numberOfSnapshootOrderByCreateDateAscending() -> Int {
        snapshootIDs = []
        
        let sql = "SELECT uuid FROM snap_shoot ORDER BY create_date_time ASC;"
        var stmt:OpaquePointer?
        
        if sqlite3_prepare_v2(database, sql, -1, &stmt, nil) != SQLITE_OK {
            return 0
        }
        
        repeat {
            if sqlite3_step(stmt) != SQLITE_ROW {
                break;
            }
            snapshootIDs?.append(String(cString: sqlite3_column_text(stmt, 0)))
        } while(true)
        sqlite3_finalize(stmt)
        
        return snapshootIDs?.count ?? 0
    }
    
    func snapshoot(at index: Int) -> Snapshoot? {
        guard let uuid = snapshootIDs?[index] else {
            return nil
        }
        
        let sql = "SELECT descriptor FROM snap_shoot WHERE uuid='\(uuid)';"
        var stmt: OpaquePointer?
        if sqlite3_prepare_v2(database, sql, -1, &stmt, nil) != SQLITE_OK {
            return nil
        }
        
        var descriptor:String? = nil
        repeat {
            if sqlite3_step(stmt) != SQLITE_ROW {
                break;
            }
            descriptor = String(cString: sqlite3_column_text(stmt, 0))
        } while(true)
        
        var snapshoot:Snapshoot? = nil
        if let descriptor = descriptor {
            snapshoot = Snapshoot.deserialize(descriptor: descriptor)
        }
        
        return snapshoot
    }
    
    func thumbnail(by snapshoot: Snapshoot) -> UIImage? {
        if let thumbnailLoadPath = snapshoot.thumbnailSavePath {
            let thumbnail: UIImage? = UIImage(contentsOfFile:thumbnailLoadPath)
            return thumbnail
        }
        return nil
    }
    
}
