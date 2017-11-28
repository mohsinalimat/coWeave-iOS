//
//  Group+CoreDataClass.swift
//  coWeave
//
//  Created by Benoît Frisch on 15/11/2017.
//  Copyright © 2017 Benoît Frisch. All rights reserved.
//
//

import Foundation
import CoreData
import Zip


public class Group: NSManagedObject {
    
    func exportCoweaveURL() -> URL? {
        var folderName = "export/\(self.name!)_\(arc4random())/";
        for u in self.users! {
            let user = u as! User
            
            let documentsDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
            let userfolderName = "\(folderName)/\(user.name!)";
            let exportPath = documentsDirectory.appendingPathComponent(folderName)
            
            do {
                try FileManager.default.createDirectory(atPath: exportPath.path, withIntermediateDirectories: true, attributes: nil)
            } catch let error as NSError {
                NSLog("Unable to create directory \(error.debugDescription)")
            }
            
            for d in user.documents! {
                let doc = d as! Document
                doc.exportToFileURL(folder: userfolderName);
            }
        }
        
        let documentsDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        let exportPath = documentsDirectory.appendingPathComponent(folderName)
        
        do {
            let formatter = DateFormatter()
            // initially set the format based on your datepicker date
            formatter.dateFormat = "dd.MM.yyyy_HH:mm:ss"
            
            let zipFilePath = try Zip.quickZipFiles([exportPath], fileName: "\(self.name!)_\(formatter.string(from: NSDate() as Date))") // Zip
            
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
        return exportPath
    }

    
    func exportZipURL() -> URL? {
        var folderName = "export/\(self.name!)_\(arc4random())/";
        for u in self.users! {
            let user = u as! User
            
            let documentsDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
            let userfolderName = "\(folderName)/\(user.name!)";
            let exportPath = documentsDirectory.appendingPathComponent(folderName)
            
            do {
                try FileManager.default.createDirectory(atPath: exportPath.path, withIntermediateDirectories: true, attributes: nil)
            } catch let error as NSError {
                NSLog("Unable to create directory \(error.debugDescription)")
            }
            
            for d in user.documents! {
                let doc = d as! Document
                doc.exportZipURL(folder: userfolderName, zip: false);
            }
        }
        
        let documentsDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        let exportPath = documentsDirectory.appendingPathComponent(folderName)
        
        do {
            let formatter = DateFormatter()
            // initially set the format based on your datepicker date
            formatter.dateFormat = "dd.MM.yyyy_HH:mm:ss"
            
            let zipFilePath = try Zip.quickZipFiles([exportPath], fileName: "\(self.name!)_\(formatter.string(from: NSDate() as Date))") // Zip
            
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
        return exportPath
    }


}
