//
//  ViewController.swift
//  CoreData_DogWalk
//
//  Created by Alex Kolovatov on 07/07/2019.
//  Copyright © 2019 Alex Kolovatov. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    private let cellId = "cellId"
    private var currentDog: Dog?
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .medium
        return formatter
    }()
    
    var managedContext: NSManagedObjectContext!
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
        tableView.dataSource = self
        return tableView
    }()


    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        
        let dogName = "Fido"
        let dogFetch: NSFetchRequest<Dog> = Dog.fetchRequest()
        dogFetch.predicate = NSPredicate(format: "%K == %@", #keyPath(Dog.name), dogName)
        
        do {
            let results = try managedContext.fetch(dogFetch)
            if results.count > 0 {
                currentDog = results.first
            } else {
                currentDog = Dog(context: managedContext)
                currentDog?.name = dogName
                try managedContext.save()
            }
        } catch let error as NSError {
            print("Fetch error: \(error) description: \(error.userInfo)")
        }
    }

    private func setupViews() {
        view.addSubview(tableView)
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(handleAddButton))
        self.navigationItem.rightBarButtonItem = addButton
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        tableView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
    }

    @objc private func handleAddButton() {
        let walk = Walk(context: managedContext)
        walk.date = NSDate()
        
        /*
        if let dog = currentDog, let walks = dog.walks?.mutableCopy() as? NSMutableOrderedSet {
            walks.add(walk)
            dog.walks = walks
        }
         */
        currentDog?.addToWalks(walk)
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Save eror: \(error)")
        }
        
        tableView.reloadData()
    }
}

extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let walks = currentDog?.walks else { return 1 }
        return walks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        guard let walk = currentDog?.walks?[indexPath.row] as? Walk, let walkDate = walk.date as Date? else { return cell }
        cell.textLabel?.text = dateFormatter.string(from: walkDate)
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "List of walks"
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard let walkToRemove = currentDog?.walks?[indexPath.row] as? Walk, editingStyle == .delete else { return }
        
        managedContext.delete(walkToRemove)
        
        do {
            try managedContext.save()
            tableView.deleteRows(at: [indexPath], with: .automatic)
        } catch let error as NSError {
            print("Saving error: \(error), \(error.userInfo)")
        }
    }
}
