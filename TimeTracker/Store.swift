//
//  Store.swift
//  TimeTracker
//
//  Created by Sam Ritchie on 19/01/2016.
//  Copyright © 2016 Realm Inc. All rights reserved.
//

import Foundation
import RealmSwift

class Project: Object {
    dynamic var id: String = NSUUID().UUIDString
    dynamic var name: String = ""
    let activities = List<Activity>()
    
    override class func primaryKey() -> String { return "id" }
}

class Activity: Object {
    dynamic var startDate: NSDate?
    dynamic var endDate: NSDate?
}

extension Project {
    var elapsedTime: NSTimeInterval {
        return activities.reduce(0) { time, activity in
            guard let start = activity.startDate,
                let end = activity.endDate else { return time }
            return time + end.timeIntervalSinceDate(start)
        }
    }
    
    var currentActivity: Activity? {
        return activities.filter("endDate == nil").first
    }
}

// MARK: Application/View state
extension Realm {
    var projects: Results<Project> {
        return objects(Project.self)
    }
}

// MARK: Actions
extension Realm {
    func addProject(name: String) {
        do {
            try write {
                let project = Project()
                project.name = name
                add(project)
            }
        } catch {
            print("Add Project action failed: \(error)")
        }
   }
    
    func deleteProject(project: Project) {
        do {
            try write {
                delete(project.activities)
                delete(project)
            }
        } catch {
            print("Delete Project action failed: \(error)")
        }
    }
    
    func startActivity(project: Project, startDate: NSDate) {
        do {
            try write {
                let act = Activity()
                act.startDate = startDate
                project.activities.append(act)
            }
        } catch {
            print("Start Activity action failed: \(error)")
        }
    }
    
    func endActivity(project: Project, endDate: NSDate) {
        guard let activity = project.currentActivity else { return }
        
        do {
            try write {
                activity.endDate = endDate
            }
        } catch {
            print("End Activity action failed: \(error)")
        }
     }

}

let store = try! Realm()