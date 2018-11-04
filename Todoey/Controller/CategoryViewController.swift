//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Rockie Moch on 10/21/18.
//  Copyright © 2018 Rockie Moch. All rights reserved.
//

import UIKit
import CoreData


class CategoryViewController: UITableViewController {

    var categoryArray = [Category]()

    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategories()

    }

    //MARK: Tableview datasource methods
    //set # of rows
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray.count
    }

    //deque a cell at index
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        cell.textLabel?.text = categoryArray[indexPath.row].name
        //add a check mark when cell tapped
        return cell
    }


    //MARK: Data manipulation methods (saveData/loadData)
    //encode data
    func saveCategories() {
        do {
            try context.save()
        } catch {
            print("error saving category \(error)")
        }
        self.tableView.reloadData()
        
    }
    //decode data
    //takes a request, returns Item, default is fetchRequest
    //func loadCategories(with request: NSFetchRequest<Category> = Category.fetchRequest())
    func loadCategories() {
        let request: NSFetchRequest<Category> =  Category.fetchRequest()
        do {
            categoryArray = try context.fetch(request)
        } catch {
            print("errror fetching categories from context \(error)")
        }
        tableView.reloadData()
    }

    
    @IBAction func addButtonPressed(_ sender: Any) {
    
        //MARK: add new categories
        var textField = UITextField()
        let alert = UIAlertController(title: "Add Todoey Category", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Category", style: .default) { (action) in
            //this code runs when user clicks the add Category button
            
            let newCategory = Category(context: self.context)
            newCategory.name = textField.text!
            self.categoryArray.append(newCategory)
            //self.defaults.set(self.itemArray, forKey: "ToDoListArray")
            self.saveCategories()
        }
        alert.addTextField { (alertText) in
            alertText.placeholder = "add a category"
            textField = alertText
            
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)


    }
    
    
    //MARK: Tableview delegate methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //categoryArray[indexPath.row].done = !categoryArray[indexPath.row].done
        performSegue(withIdentifier: "gotoItems", sender: self)
        
        //to delete a row
        //        context.delete(itemArray[indexPath.row])
        //        itemArray.remove(at: indexPath.row)
        
   
        saveCategories()
        //animate the selection
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categoryArray[indexPath.row]
            
        }
        
    }

    
    

}
