//
//  coWeaveStack.swift
//  coWeave
//
//  Created by Benoît Frisch on 16/11/2017.
//  Copyright © 2017 Benoît Frisch. All rights reserved.
//

import CoreData


func createcoWeaveContainer(completion: @escaping (NSPersistentContainer) -> ()) {
    let container = NSPersistentContainer(name: "coWeave")
    container.loadPersistentStores { _, error in
        guard error == nil else { fatalError("Failed to load store: \(String(describing: error))") }
        DispatchQueue.main.async { completion(container) }
    }
}


