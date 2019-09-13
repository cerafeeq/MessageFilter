//
//  SenderBlacklistVC.swift
//  SMSFilter
//
//  Created by Rafeeq Ebrahim on 02/01/19.
//  Copyright © 2019 Rafeeq Ebrahim. All rights reserved.
//

import UIKit
import CoreData

class SenderListVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var senderField: UITextField!
    var senders: [String]!
    
    var managedContext: NSManagedObjectContext!

    @IBOutlet weak var tableView: UITableView!
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        managedContext = CoreDataStorage.mainQueueContext()
        
        senders = [String]();
        
        self.managedContext.performAndWait{ () -> Void in
            let senderFetch: NSFetchRequest<Sender> = Sender.fetchRequest()
            
            do {
                let results = try managedContext.fetch(senderFetch)
                
                for sender in results {
                    senders.append(sender.name!)
                }
            }
            catch let error as NSError {
                print("Fetch error: \(error) description: \(error.userInfo)")
            }
        }
        
        senderField.autocapitalizationType = .allCharacters
        senderField.autocorrectionType = .no
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "DefaultCell")
        
        tableView.layer.borderWidth = 1.0
        tableView.layer.borderColor = UIColor.lightGray.cgColor
        
        self.dismissKeyboardOnTap()
    }
    
    @IBAction func tappedAdd(_ sender: Any) {
        let senderName = senderField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if (senderName == "") {
            return
        }
        
        senders.append(senderName)
        
        let newSender = Sender(context: managedContext)
        newSender.name = senderName
        
        self.managedContext.performAndWait{ () -> Void in
            do {
                try managedContext.save()
            }
            catch let error as NSError {
                print("Fetch error: \(error) description: \(error.userInfo)")
            }
        
            senderField.text = ""
            
            tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return senders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DefaultCell", for: indexPath)
        cell.textLabel?.text = senders[indexPath.row]
        
        return cell
    }

}
