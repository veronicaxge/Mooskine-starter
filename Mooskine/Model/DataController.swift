//
//  DataController.swift
//  Mooskine
//
//  Created by Ge on 6/8/19.
//  Copyright © 2019 Udacity. All rights reserved.
//

import Foundation
import CoreData

//set up a class to encapsulate the stack setup and its funcitonality.

class DataController{
    //1. create a persistent container instance.
    let persistentContainer: NSPersistentContainer
    
    //3. help us access the context
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    //end of 3.
    
    //add a background context for slow tasks
    var backgroundContext:NSManagedObjectContext!
    
    init(modelName:String){
        persistentContainer = NSPersistentContainer(name:modelName)
    }
    
    func configureContexts(){
        //instantiate backgroundContext
        backgroundContext = persistentContainer.newBackgroundContext()
        
        viewContext.automaticallyMergesChangesFromParent = true
        backgroundContext.automaticallyMergesChangesFromParent = true
        
        //if there's a conflict between background context and the store when merging, data on the background context will trump data on the store.
        backgroundContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        
        //if there's a conflict between view context and the store when merging, data on the store will trump data on the view context.
        viewContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
    }
    
    //2.use the persistent container to load the persistent store
    func load(completion:(() -> Void)? = nil) {
        persistentContainer.loadPersistentStores { (storeDescription, error) in
            guard error == nil else {
                //if there is error, show a fatal error.
                fatalError(error!.localizedDescription)
            }
            //after loading the store, perform the autosave, and also call the completion handler.
            self.autoSaveViewContext()
            
            self.configureContexts()
            completion?()
        }
    }
}

//set up auto save every 30 seconds to prevent losing data.
extension DataController{
    func autoSaveViewContext(interval: TimeInterval = 30){
        print("autosaving")
        //add a guard to prevent negative intervals.
        guard interval > 0 else {
            print("cannot set negative autosave interval")
            return
        }
        if viewContext.hasChanges {
            try? viewContext.save()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
            self.autoSaveViewContext(interval: interval)
        }
    }
}
