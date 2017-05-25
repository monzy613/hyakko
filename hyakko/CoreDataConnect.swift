//
//  CoreDataConnect.swift
//  hyakko
//
//  Created by Monzy Zhang on 25/05/2017.
//  Copyright © 2017 MonzyZhang. All rights reserved.
//

import UIKit
import CoreData

let kEntityName = "AudioSaveInfo"

class CoreDataConnect {
    private static var instance: CoreDataConnect?
    private var context: NSManagedObjectContext {
        return (UIApplication.shared.delegate
            as! AppDelegate).persistentContainer.viewContext
    }

    static func shared() -> CoreDataConnect {
        if instance == nil {
            instance = CoreDataConnect()

        }
        return instance!
    }

    func save(displayName: String, saveDate: Date, fileName: String) {
        let audioSaveInfo =
            NSEntityDescription.insertNewObject(
                forEntityName: kEntityName, into: context)
                as! AudioSaveInfo
        audioSaveInfo.displayName = displayName
        audioSaveInfo.saveDate = saveDate as NSDate
        audioSaveInfo.fileName = fileName

        do {
            try context.save()
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }

    func fetchAudioList() -> [AudioSaveInfo] {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: kEntityName)

        do {
            let audioList = try context.fetch(request) as! [AudioSaveInfo]
            return audioList
        } catch {
            fatalError("\(error)")
        }
        return []
    }

    func remove(fileName: String) {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: kEntityName)
        request.predicate = nil
        request.predicate = NSPredicate(format: "fileName = \(fileName)")

        do {
            let results = try context.fetch(request) as! [AudioSaveInfo]

            for result in results {
                context.delete(result)
            }
            try context.save()
        } catch {
            fatalError("\(error)")
        }
    }
}
