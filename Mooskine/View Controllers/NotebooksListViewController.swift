//
//  NotebooksListViewController.swift
//  Mooskine
//
//  Created by Josh Svatek on 2017-05-31.
//  Copyright © 2017 Udacity. All rights reserved.
//

import UIKit
import CoreData

class NotebooksListViewController: UIViewController, UITableViewDataSource {
    /// A table view that displays a list of notebooks
    @IBOutlet weak var tableView: UITableView!

    /// The `Notebook` objects being presented
    var notebooks: [Notebook] = []
    
    var dataController:DataController! 

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.titleView = UIImageView(image: #imageLiteral(resourceName: "toolbar-cow"))
        navigationItem.rightBarButtonItem = editButtonItem
        
        //create fetch request to fetch data we want from the persistence store
        let fetchRequest:NSFetchRequest<Notebook> = Notebook.fetchRequest()
        //sort the data by creationDate in descending order.
        let sortDescriptor = NSSortDescriptor(key:"creationDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        //use if let to make sure only if the fetch was successful, then we store the result to the notebooks array.
        if let result = try? dataController.viewContext.fetch(fetchRequest){
            notebooks = result
            tableView.reloadData()
        }
        updateEditButtonState()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: false)
            tableView.reloadRows(at: [indexPath], with: .fade)
        }
    }

    // -------------------------------------------------------------------------
    // MARK: - Actions

    @IBAction func addTapped(sender: Any) {
        presentNewNotebookAlert()
    }

    // -------------------------------------------------------------------------
    // MARK: - Editing

    /// Display an alert prompting the user to name a new notebook. Calls
    /// `addNotebook(name:)`.
    func presentNewNotebookAlert() {
        let alert = UIAlertController(title: "New Notebook", message: "Enter a name for this notebook", preferredStyle: .alert)

        // Create actions
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let saveAction = UIAlertAction(title: "Save", style: .default) { [weak self] action in
            if let name = alert.textFields?.first?.text {
                self?.addNotebook(name: name)
            }
        }
        saveAction.isEnabled = false

        // Add a text field
        alert.addTextField { textField in
            textField.placeholder = "Name"
            NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: textField, queue: .main) { notif in
                if let text = textField.text, !text.isEmpty {
                    saveAction.isEnabled = true
                } else {
                    saveAction.isEnabled = false
                }
            }
        }

        alert.addAction(cancelAction)
        alert.addAction(saveAction)
        present(alert, animated: true, completion: nil)
    }

    /// Adds a new notebook to the end of the `notebooks` array
    func addNotebook(name: String) {
        //These are how to instantiate a notebook with a non-CoreData approach.
        //        let notebook = Notebook(name: name)
        //        notebooks.append(notebook)
       //         tableView.insertRows(at: [IndexPath(row: numberOfNotebooks - 1, section: 0)], with: .fade)
        
        //Below is the Core Data approach:
        //instantiate a notebook associated with the dataControler's context.
        let notebook = Notebook(context: dataController.viewContext)
        notebook.name = name
        notebook.creationDate = Date() //set as now.
        try? dataController.viewContext.save()  //save the new notebook into the data controller.
        notebooks.insert(notebook, at: 0)  //insert at position 0, instead of append.
        tableView.insertRows(at: [IndexPath(row:0, section: 0)], with: .fade) //display this in a new row
        updateEditButtonState()
    }

    /// Deletes the notebook at the specified index path
    func deleteNotebook(at indexPath: IndexPath) {
        //add the three lines below to execute the deletion from the persistent store as well.
        let notebookToDelete = notebook(at: indexPath)
        dataController.viewContext.delete(notebookToDelete) //delete the selected notebook from persistent store
        try? dataController.viewContext.save() //save the change to persistent store
        
        //the code below is the same whether it's core data or not.
        notebooks.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .fade)
        if numberOfNotebooks == 0 {
            setEditing(false, animated: true)
        }
        updateEditButtonState()
    }

    func updateEditButtonState() {
        navigationItem.rightBarButtonItem?.isEnabled = numberOfNotebooks > 0
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.setEditing(editing, animated: animated)
    }

    // -------------------------------------------------------------------------
    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfNotebooks
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let aNotebook = notebook(at: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: NotebookCell.defaultReuseIdentifier, for: indexPath) as! NotebookCell

        // Configure cell
        cell.nameLabel.text = aNotebook.name
        
        if let count = aNotebook.notes?.count{
            let pageString = count == 1 ? "page" : "pages"
            cell.pageCountLabel.text = "\(count) \(pageString)"
        }
        return cell
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete: deleteNotebook(at: indexPath)
        default: () // Unsupported
        }
    }

    // Helper

    var numberOfNotebooks: Int { return notebooks.count }

    func notebook(at indexPath: IndexPath) -> Notebook {
        return notebooks[indexPath.row]
    }

    // -------------------------------------------------------------------------
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // If this is a NotesListViewController, we'll configure its `Notebook`
        if let vc = segue.destination as? NotesListViewController {
            if let indexPath = tableView.indexPathForSelectedRow {
                vc.notebook = notebook(at: indexPath)
                vc.dataController = dataController
            }
        }
    }
}
