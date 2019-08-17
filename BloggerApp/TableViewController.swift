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
    var contentTotal: [String] = []
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
                   
              //      let titleOfBlog = itemDictionary["title"]! as! String
                    let content = itemDictionary["content"]! as!  String
             //       self.titleTotal.append(titleOfBlog)
                self.contentTotal.append(content)
                   
                    let coreTitle = itemDictionary["title"]!
                    let coreURL = itemDictionary["url"]!
                    
                    
               //  self.save(blogTitle: coreTitle as! String,blogURL: coreURL as! String)
                    
                }
                
            DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
            catch {
                
                    print ("Error in fetcing Data")
                
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
       
        // 1
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        // 2
        let entity =
            NSEntityDescription.entity(forEntityName: "Blogs",
                                       in: managedContext)!
        
        let blogs = NSManagedObject(entity: entity,
                                   insertInto: managedContext)
        
        // 3
        blogs.setValue(blogTitle, forKeyPath: "blogTitle")
        
        blogs.setValue(blogURL  , forKeyPath: "blogURL")
        
        // 4
        do {
            try managedContext.save()
           
            allBlogs.append(blogs)
           
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    //-----------------------------------------------
    
    
    func fetch() {
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        //2
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "Blogs")
        
        //3
        do {
            blogsFetch = try managedContext.fetch(fetchRequest)
            
            for locValues in blogsFetch {
                
                 titleF   = ((locValues.value(forKeyPath: "blogTitle"))! as? String)!
                
                urlF = ((locValues.value(forKeyPath: "blogURL"))! as? String)!
              
                self.titleFetchTotal.append(titleF)
                self.urlFetchTotal.append(urlF)
 
            }
            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        
    }
    

    //-----------------------------------------------
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      
      
        if segue.identifier == "toWebView",
            let destination = segue.destination as? WebViewController,
         
            let index = tableView.indexPathForSelectedRow?.row
            {
                 titleOne = titleFetchTotal[index]
                destination.bTitle = titleOne
                print("here",titleOne)
                destination.bTitle = titleOne
                //let contentOne = contentTotal[index]
               //destination.contentTotal = contentOne
                 
                   let initialUrl = urlFetchTotal[index]
                   let midUrl = "https" + initialUrl.dropFirst(4)
                

                
                destination.urlInitial = midUrl
               
            }
            
        }
        
    }

