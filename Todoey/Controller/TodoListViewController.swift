//
//  ViewController.swift
//  Todoey
//
//  Created by Rockie Moch on 9/22/18.
//  Copyright © 2018 Rockie Moch. All rights reserved.
//

import UIKit
import CoreData


class TodoListViewController: UITableViewController {

    var itemArray = [Item]()
    var selectedCategory : Category? {
        didSet {
            loadData()
        }
    }
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
//        searchBar.delegate = self
        
        // Do any additional setup after loading the view, typically from a nib.
        
        
    }
    //methods that the table view delegate must provide
    //set # of rows
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count 
    }
    
    //deque a cell at index
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoItemCell", for: indexPath)
        cell.textLabel?.text = itemArray[indexPath.row].title
        //add a check mark when cell tapped
        cell.accessoryType = (itemArray[indexPath.row].done) ? .checkmark : .none
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        
        //to delete a row
//        context.delete(itemArray[indexPath.row])
//        itemArray.remove(at: indexPath.row)

        
        saveData()
       //animate the selection
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    //add button
    @IBAction func addButtonPress(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add Todoey Item", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add item", style: .default) { (action) in
            //this code runs when user clicks the add item button
            
            let newItem = Item(context: self.context)
            newItem.title = textField.text!
            newItem.done = false
            newItem.parent = self.selectedCategory
            self.itemArray.append(newItem)
            //self.defaults.set(self.itemArray, forKey: "ToDoListArray")
            self.saveData()
        }
        alert.addTextField { (alertText) in
            alertText.placeholder = "add an item"
            textField = alertText
            
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    //encode data
    func saveData() {
        do {
            try context.save()
        } catch {
            print("error saving context \(error) as Any")
        }
        self.tableView.reloadData()
        
    }
    //decode data
    //takes a request, returns Item, default is fetchRequest
    func loadData(with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil) {
        let categoryPredicate = NSPredicate(format: "parent.name MATCHES %@", selectedCategory!.name!)

        if let newPredicate = predicate {
          request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, newPredicate])
        }
        else {
            request.predicate = categoryPredicate

        }
        
        do {
            itemArray = try context.fetch(request)
        } catch {
            print("errror fetching data from context \(error)")
        }
        tableView.reloadData()
    }
    
}

//search bar functions
extension TodoListViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
      
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        loadData(with: request, predicate: predicate)
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadData()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder() //dismiss the kbd view
                
            }
            self.tableView.reloadData()

        }
    }

}
