//
//  ItemDetailViewController.swift
//  DreamLister
//
//  Created by Bailig Abhanar on 2017-04-04.
//  Copyright © 2017 Bailig Abhanar. All rights reserved.
//

import UIKit
import CoreData

class ItemDetailViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    // MARK: - outlet
    @IBOutlet weak var storeAndTypePickerView: UIPickerView!
    @IBOutlet weak var titleTextField: CustomTextField!
    @IBOutlet weak var priceTextField: CustomTextField!
    @IBOutlet weak var detailTextField: CustomTextField!
    @IBOutlet weak var thumbnailImageBtn: UIButton!
    
    // MARK: - data
    var stores = [Store]()
    var itemTypes = [ItemType]()
    var selectedItem: Item?
    var imagePickerController: UIImagePickerController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set back bar button title to empty string
        if let topItem = self.navigationController?.navigationBar.topItem {
            topItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        }
        
        imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        
//        generateTestStores()
//        generateTestItemTypes()
        
        fetchStoresFromDb()
        fetchItemTypesFromDb()
        
        loadSelectedItem()
    }

    
    // MARK: - actions
    @IBAction func saveItemBtnPressed(_ sender: Any) {
        
        // if selectedItem is nil create a new Item to db
        let item = selectedItem ?? Item(context: context)
        
        
        item.timestamp = NSDate()
        if let price = priceTextField.text {
            item.price = Double(price)!
        }
        
        if let detail = detailTextField.text, let title = titleTextField.text, let image = thumbnailImageBtn.image(for: .normal) {
            let itemDetail = ItemDetail(context: context)
            itemDetail.detail = detail
            itemDetail.title = title
            itemDetail.image = image
            item.toItemDetail = itemDetail
            item.toItemDetail?.toItemType = itemTypes[storeAndTypePickerView.selectedRow(inComponent: 1)]
        }
        
        item.toStore = stores[storeAndTypePickerView.selectedRow(inComponent: 0)]
        
        applicationDelegate.saveContext()
        
        // go beck to table view
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func trachBtnPressed(_ sender: Any) {
        guard let item = selectedItem else { return }
        
        // delete item from db
        context.delete(item)
        applicationDelegate.saveContext()
        
        // go beck to table view
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func thumbnailImageBtnPressed(_ sender: Any) {
        present(imagePickerController, animated: true, completion: nil)
    }
    
    // MARK: - image picker view
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else { return }
        
        thumbnailImageBtn.setImage(image, for: .normal)
        imagePickerController.dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: - store and type picker view
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch component {
        case 0:
            return stores[row].name
        case 1:
            return itemTypes[row].type
        default:
            break
        }
        return ""
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0:
            return stores.count
        case 1:
            return itemTypes.count
        default:
            break
        }
        return 0
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // update when selected
    }
    
    
    // MARK: - fetch data
    func fetchStoresFromDb() {
        let fetchRequiest: NSFetchRequest<Store> = Store.fetchRequest()
        
        do {
            stores = try context.fetch(fetchRequiest)
        } catch {
            print("Error encountered when performing fetch Store:\(error)")
        }
    }
    
    func fetchItemTypesFromDb(){
        let fetchRequiest: NSFetchRequest<ItemType> = ItemType.fetchRequest()
        
        do {
            itemTypes = try context.fetch(fetchRequiest)
        } catch {
            print("Error encountered when performing fetch ItemType:\(error)")
        }
    }
    
    // MARK: - helpers
    func generateTestStores() {
        let store = Store(context: context)
        store.name = "Best Buy"
        let store2 = Store(context: context)
        store2.name = "Generic Technology"
        let store3 = Store(context: context)
        store3.name = "Porsche"
        applicationDelegate.saveContext()
    }
    
    func generateTestItemTypes() {
        let itemType = ItemType(context: context)
        itemType.type = "Electronics"
        let itemType2 = ItemType(context: context)
        itemType2.type = "Clothing & Accessories"
        let itemType3 = ItemType(context: context)
        itemType3.type = "Games"
        applicationDelegate.saveContext()
        
    }
    
    func loadSelectedItem() {
        if let item = selectedItem {
            titleTextField.text = item.toItemDetail?.title
            priceTextField.text = "\(item.price)"
            detailTextField.text = item.toItemDetail?.detail
            
            if let image = item.toItemDetail?.image as? UIImage {
                thumbnailImageBtn.setImage(image, for: .normal)
            }
            
            for storeFromDb in stores where storeFromDb.name == item.toStore?.name {
                storeAndTypePickerView.selectRow(stores.index(of: storeFromDb)!, inComponent: 0, animated: false)
            }
            for itemTypeFromDb in itemTypes where itemTypeFromDb.type == item.toItemDetail?.toItemType?.type {
                storeAndTypePickerView.selectRow(itemTypes.index(of: itemTypeFromDb)!, inComponent: 1, animated: false)
            }
        }
    }
    
}
