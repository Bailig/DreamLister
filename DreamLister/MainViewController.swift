//
//  MainViewController.swift
//  DreamLister
//
//  Created by Bailig Abhanar on 2017-04-03.
//  Copyright © 2017 Bailig Abhanar. All rights reserved.
//

import UIKit
import CoreData

class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segment: UISegmentedControl!

    var fetchedRequestController: NSFetchedResultsController<Item>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
//        generateTestItem()
        fetchItemFromDb()
    }
    
    // MARK: - actions
    @IBAction func segmentChanged(_ sender: Any) {
        fetchItemFromDb()
        tableView.reloadData()
    }
    
    // MARK: - table view
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ItemTableViewCell", for: indexPath) as? ItemTableViewCell else {
            print("Reusable Cell with identifier ItemTableViewCell field!")
            return UITableViewCell()
        }
        updateContentFor(itemTableViewCell: cell, indexPath: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = fetchedRequestController.sections else {
            print("There is not section fetched!")
            return 0
        }
        let sectionInfo = sections[section]
        return sectionInfo.numberOfObjects
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        guard let sections = fetchedRequestController.sections else {
            print("There is not section fetched!")
            return 0
        }
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "ItemDetailViewController" else {
            return
        }
        guard let destinationView = segue.destination as? ItemDetailViewController, let item = sender as? Item else {
            return
        }
        destinationView.selectedItem = item
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let objects = fetchedRequestController.fetchedObjects, objects.count > 0 {
            let item = objects[indexPath.row]
            performSegue(withIdentifier: "ItemDetailViewController", sender: item)
        }
    }
    
    // MARK: - fetch item
    func fetchItemFromDb(){
        
        // NSFetchRequest will be used to fetch Item
        let fetchRequest: NSFetchRequest<Item> = Item.fetchRequest()
        
        // NSSortDescriptor will be used for sort items when fetching
        let sortByTimestamp = NSSortDescriptor(key: "timestamp", ascending: false)
        let sortByPrice = NSSortDescriptor(key: "price", ascending: false)
//        let sortByTitle = NSSortDescriptor(key: "title", ascending: true)

        switch segment.selectedSegmentIndex {
        case 0:
            fetchRequest.sortDescriptors = [sortByTimestamp]
        case 1:
            fetchRequest.sortDescriptors = [sortByPrice]
//        case 2:
//            fetchRequest.sortDescriptors = [sortByTitle]
        default:
            break
        }
        
        
        // NSFetchedResultsController manage results returned from CoreData
        fetchedRequestController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedRequestController.delegate = self
        
        do {
            // perform fetch
            try fetchedRequestController.performFetch()
        } catch {
            print("Error encountered when performing fetch Item:\(error)")
        }
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let indexPath = newIndexPath {
                tableView.insertRows(at: [indexPath], with: .fade)
            }
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        case .update:
            if let indexPath = indexPath {
                let cell = tableView.cellForRow(at: indexPath) as! ItemTableViewCell
                updateContentFor(itemTableViewCell: cell, indexPath: indexPath)
            }
        case .move:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            if let indexPath = newIndexPath {
                tableView.insertRows(at: [indexPath], with: .fade)
            }
        }
    }
    
    
    // MARK: - helpers
    
    func updateContentFor(itemTableViewCell cell: ItemTableViewCell, indexPath: IndexPath) {
        let item = fetchedRequestController.object(at: indexPath)
        cell.updateContent(item: item)
    }
    
    func generateTestItem() {
        
        let item = Item(context: context)
        item.timestamp = NSDate()
        item.price = 599.99
        item.url = "http://www.bestbuy.ca/en-ca/product/lg-electronics-lg-27-4k-ultra-hd-60hz-14ms-ips-led-monitor-27ud68-w-aus-silver-white-27ud68-w-aus/10408486.aspx?"
    
        let item2 = Item(context: context)
        item2.timestamp = NSDate()
        item2.price = 556.52
        item2.url = "http://www.genericcomputer.com/prod_one.php?pid=11467"
    
        let item3 = Item(context: context)
        item3.timestamp = NSDate()
        item3.price = 81908.94
        item3.url = "https://markmotorsporsche.com/inventory/new/Porsche+Cayenne+Ottawa+Ontario+2017+Black+985629"
        applicationDelegate.saveContext()
    }
    
    
}










