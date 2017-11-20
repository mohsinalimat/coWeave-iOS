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


    func exportToFileURL() -> URL? {
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
        
        let contents: NSDictionary = [
            Keys.name.rawValue: name ?? "none",
            Keys.addedDate.rawValue: addedDate ?? "none",
            Keys.modifyDate.rawValue: modifyDate ?? "none",
            Keys.template.rawValue: template,
            Keys.user.rawValue: user?.name ?? "none",
            Keys.group.rawValue: user?.group ?? "none",
            Keys.pages.rawValue: pages
        ]
        
      
        // 4
        guard let path = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask).first else {
                return nil
        }
        
        // 5
        let saveFileURL = path.appendingPathComponent("/\(self.name!).coweave")
        contents.write(to: saveFileURL, atomically: true)
        return saveFileURL
    }
}
