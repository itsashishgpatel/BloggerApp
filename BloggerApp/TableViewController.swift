//
//  TableViewController.swift
//  BloggerApp
//
//  Created by IMCS2 on 8/16/19.
//  Copyright © 2019 IMCS2. All rights reserved.
//

import UIKit
import CoreData

class TableViewController: UITableViewController {
    
    var allBlogs: [NSManagedObject] = []
    var blogsFetch: [NSManagedObject] = []
    var titleFetchTotal: [String] = []
    var urlFetchTotal: [String] = []
    var titleF:String = " "
    var urlF:String = " "
    var titleOne:String = " "
    var titleTotal: [String] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url =  URL(string:"https://www.googleapis.com/blogger/v3/blogs/2399953/posts?key=AIzaSyAtvNSoDMZxs7fwkHbmmjY1KaCr3Z0SIZU")
        
        let task = URLSession.shared.dataTask(with: url!) { (data ,response, error) in
            
            if let unWrappedData = data {
                
                do {
                    let jsonOutput = try JSONSerialization.jsonObject(with: unWrappedData, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary
                    
                    let items = jsonOutput?["items"] as? NSArray
                    
                    for item in items! {
                        
                        let itemDictionary = item as! NSDictionary
                        let coreTitle = itemDictionary["title"]!
                        let coreURL = itemDictionary["url"]!
                        
                        let flag = UserDefaults.standard.value(forKey: "firstTime") as? Bool
                        if   flag == nil
                        {
                            self.save(blogTitle: coreTitle as! String,blogURL: coreURL as! String)
                        }
                    }
                    UserDefaults.standard.set(true, forKey: "firstTime")
                    
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
                catch {
                    NSLog("Error in fetcing Data")
                }
            }
        }
        task.resume()
        
        fetch()
        self.tableView.reloadData()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return blogsFetch.count
    }    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let info = blogsFetch[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "BlogCell",
                                                 for: indexPath)
        cell.textLabel?.text =
            info.value(forKeyPath: "blogTitle") as? String
        
        return cell
    }
    
    func save(blogTitle: String,blogURL:String) {
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        let entity =
            NSEntityDescription.entity(forEntityName: "Blogs",
                                       in: managedContext)!
        
        let blogs = NSManagedObject(entity: entity,
                                    insertInto: managedContext)
        
        blogs.setValue(blogTitle, forKeyPath: "blogTitle")
        
        blogs.setValue(blogURL  , forKeyPath: "blogURL")
        
        do {
            try managedContext.save()
            
            allBlogs.append(blogs)
            
        } catch let error as NSError {
            NSLog("Could not save. \(error), \(error.userInfo)")
            
        }
    }
    
    func fetch() {
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "Blogs")
        
        do {
            blogsFetch = try managedContext.fetch(fetchRequest)
            
            for locValues in blogsFetch {
                titleF   = ((locValues.value(forKeyPath: "blogTitle"))! as? String)!
                urlF = ((locValues.value(forKeyPath: "blogURL"))! as? String)!
                self.titleFetchTotal.append(titleF)
                self.urlFetchTotal.append(urlF)
            }
            
        } catch let error as NSError {
            NSLog("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toWebView",
            let destination = segue.destination as? WebViewController,
            
            let index = tableView.indexPathForSelectedRow?.row
        {
            titleOne = titleFetchTotal[index]
            destination.bTitle = titleOne
            destination.bTitle = titleOne
            let initialUrl = urlFetchTotal[index]
            let midUrl = "https" + initialUrl.dropFirst(4)
            destination.urlInitial = midUrl
            
        }
        
    }
    
}

