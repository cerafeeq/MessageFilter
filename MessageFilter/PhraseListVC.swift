//
//  SpamTextListVC.swift
//  SMSFilter
//
//  Created by Rafeeq Ebrahim on 02/01/19.
//  Copyright © 2019 Rafeeq Ebrahim. All rights reserved.
//

import UIKit
import CoreData

class PhraseListVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //var coreDataStack: CoreDataStack!
    var managedContext: NSManagedObjectContext!
    
    @IBOutlet weak var phraseField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    var phrases: [String]!
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*let messageSender = "ad-urclap"
        let sender = "*-urclap"
        
        let range = NSRange(location: 0, length: messageSender.utf16.count)
        if let regex = try? NSRegularExpression(pattern: "[a-z]" + sender, options: .caseInsensitive) {
        
            if (regex.firstMatch(in: messageSender, options: [], range: range) != nil) {
                print("Regex match")
            }
        }*/
        

        //coreDataStack = CoreDataStack(modelName: "SMSFilter")
        managedContext = CoreDataStorage.mainQueueContext()
        
        phrases = [String]()
        
        self.managedContext.performAndWait{ () -> Void in
            let phraseFetch: NSFetchRequest<SpamText> = SpamText.fetchRequest()
            
            do {
                let results = try managedContext.fetch(phraseFetch)
                
                for phrase in results {
                    phrases.append(phrase.text!)
                }
            }
            catch let error as NSError {
                print("Fetch error: \(error) description: \(error.userInfo)")
            }
        }
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "DefaultCell")
        
        tableView.layer.borderWidth = 1.0
        tableView.layer.borderColor = UIColor.lightGray.cgColor
        
        self.dismissKeyboardOnTap()
        //self.showHideKeyboard()
    }
    
    @IBAction func tappedAdd(_ sender: Any) {
        let spamText = phraseField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if (spamText == "") {
            return
        }
        
        phrases.append(spamText)
        
        let newPhrase = SpamText(context: managedContext)
        newPhrase.text = spamText
        
        self.managedContext.performAndWait{ () -> Void in
            do {
                try managedContext.save()
            }
            catch let error as NSError {
                print("Fetch error: \(error) description: \(error.userInfo)")
            }
            
            phraseField.text = ""
            
            tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return phrases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DefaultCell", for: indexPath)
        cell.textLabel?.text = phrases[indexPath.row]
        
        return cell
    }

}
