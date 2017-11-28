//
//  Document+CoreDataClass.swift
//  coWeave
//
//  Created by Benoît Frisch on 15/11/2017.
//  Copyright © 2017 Benoît Frisch. All rights reserved.
//
//

import Foundation
import CoreData
import Zip

public class Document: NSManagedObject {
    
    
    // MARK: Keys
    fileprivate enum Keys: String {
        case addedDate = "addedDate"
        case modifyDate = "modifyDate"
        case name = "name"
        case template = "template"
        case firstPage = "firstPage"
        case lastPage = "lastPage"
        case pages = "pages"
        case user = "user"
        case group = "group"
        case image = "image"
        case next = "next"
        case previous = "previous"
        case audio = "audio"
        case number = "number"
        case title = "title"
        case document = "document"
        case page = "page"
        
    }


    func exportToFileURL(folder : String? = "coweaveExport") -> URL? {
        var pages : [NSDictionary] = []
        for p in self.pages! {
            let page = p as! Page
            let pageDic: NSDictionary = [
                Keys.number.rawValue: page.number,
                Keys.addedDate.rawValue: page.addedDate ?? "none",
                Keys.modifyDate.rawValue: page.modifyDate ?? "none",
                Keys.title.rawValue: page.title ?? "none",
                Keys.image.rawValue: page.image?.image ?? "none",
                Keys.audio.rawValue: page.audio ?? "none"
            ]
            
            pages.append(pageDic)
        }
        
        let formatter = DateFormatter()
        // initially set the format based on your datepicker date
        formatter.dateFormat = "dd.MM.yyyy_HH:mm:ss"
        
        var userString: String! = "none"
        var groupString: String! = "none"
        var fileName: String! = "\(self.name!)_\(formatter.string(from: NSDate() as Date))"
       
        if (user != nil) {
            userString = user!.name
            groupString = user!.group!.name
            fileName = "\(groupString!)_\(userString!)_\(self.name!)_\(formatter.string(from: NSDate() as Date))"
        }
        
        let contents: NSDictionary = [
            Keys.name.rawValue: name ?? "none",
            Keys.addedDate.rawValue: addedDate ?? "none",
            Keys.modifyDate.rawValue: modifyDate ?? "none",
            Keys.template.rawValue: template,
            Keys.user.rawValue: userString,
            Keys.group.rawValue: groupString,
            Keys.pages.rawValue: pages
        ]
        
        let documentsDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        let exportPath = documentsDirectory.appendingPathComponent(folder!)
        
        do {
            try FileManager.default.createDirectory(atPath: exportPath.path, withIntermediateDirectories: true, attributes: nil)
        } catch let error as NSError {
            NSLog("Unable to create directory \(error.debugDescription)")
        }
        
        // 5
        let saveFileURL = exportPath.appendingPathComponent("/\(fileName.trimmingCharacters(in: .whitespaces)).coweave")
        contents.write(to: saveFileURL, atomically: true)
        return saveFileURL
    }
    
    func exportZipURL(folder : String? = "zipExport", zip : Bool? = true) -> URL? {
        let formatter = DateFormatter()
        // initially set the format based on your datepicker date
        formatter.dateFormat = "dd.MM.yyyy_HH:mm:ss"
        
        var userString: String! = "none"
        var groupString: String! = "none"
        var fileName: String! = "\(self.name!)_\(formatter.string(from: NSDate() as Date))"
        
        if (user != nil) {
            userString = user!.name
            groupString = user!.group!.name
            fileName = "\(groupString!)_\(userString!)_\(self.name!)_\(formatter.string(from: NSDate() as Date))"
        }
        
        for p in self.pages! {
            let page = p as! Page
            
            let formatter = DateFormatter()
            // initially set the format based on your datepicker date
            formatter.dateFormat = "dd.MM.yyyy_HH:mm:ss"
            
            let documentsDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
            let folderName = "\(folder!)/\(fileName.trimmingCharacters(in: .whitespaces))/page\(page.number)";
            let exportPath = documentsDirectory.appendingPathComponent(folderName)
            
            do {
                try FileManager.default.createDirectory(atPath: exportPath.path, withIntermediateDirectories: true, attributes: nil)
            } catch let error as NSError {
                NSLog("Unable to create directory \(error.debugDescription)")
            }
            
            if (page.audio != nil) {
                let audioName = "\(folderName)/audio-page\(page.number).m4a"
                do {
                    try page.audio?.write(to: documentsDirectory.appendingPathComponent(audioName), options: .atomic)
                } catch {}
            }
            if (page.image != nil) {
                let imageName = "\(folderName)/photo-page\(page.number).png"
                do {
                    try page.image?.image!.write(to: documentsDirectory.appendingPathComponent(imageName), options: .atomic)
                } catch {}
            }
        }
        let documentsDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        let folderName = "\(folder!)/\(fileName.trimmingCharacters(in: .whitespaces))";
        let exportPath = documentsDirectory.appendingPathComponent(folderName)
        
        if (zip)! {
        do {
            let zipFilePath = try Zip.quickZipFiles([exportPath], fileName: fileName.trimmingCharacters(in: .whitespaces)) // Zip
            
            let fileManager = FileManager.default
            do {
                try fileManager.removeItem(atPath: folderName)
            }
            catch let error as NSError {
                print("Ooops! Something went wrong: \(error)")
            }
            return zipFilePath
            
        } catch {
            print("Something went wrong")
        }
        }
        return exportPath
    }
}
