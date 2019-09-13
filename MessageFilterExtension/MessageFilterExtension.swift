//
//  MessageFilterExtension.swift
//  SMSFilterExtension
//
//  Created by Rafeeq Ebrahim on 02/01/19.
//  Copyright © 2019 Rafeeq Ebrahim. All rights reserved.
//

import IdentityLookup
import CoreData
import os.log

final class MessageFilterExtension: ILMessageFilterExtension {
    let managedContext = CoreDataStorage.mainQueueContext()
    /*var blacklist = ["+918095222235", "29473569", "H,HSEJOY", "AX-URCLAP", "AD-URCLAP", "AX-URBNCL", "46473569", "HP-HSEJOY", "AX-HSEJOY", "IM-HSEJOY", "AD-SAKRAH", "AX-SAKRAH", "AD-TTSAVE", "AD-MAKAAN"]
    var spamList = ["off", "%", "sale"]*/
    
    var blackList = [String]()
    var spamList = [String]()
    
    deinit {
        os_log("Message filter removed")
    }
    
    override init() {
        os_log("Init filter extension")
    }
    
    func getBlacklist() {
        self.managedContext.performAndWait{ () -> Void in
            let senderFetch: NSFetchRequest<Sender> = Sender.fetchRequest()
            
            do {
                let results = try managedContext.fetch(senderFetch)
                
                for sender in results {
                    blackList.append(sender.name!.lowercased())
                }
            }
            catch let error as NSError {
                print("Fetch error: \(error) description: \(error.userInfo)")
            }
        }
    }
    
    func getSpamList() {
        self.managedContext.performAndWait{ () -> Void in
            let spamFetch: NSFetchRequest<SpamText> = SpamText.fetchRequest()
            
            do {
                let results = try managedContext.fetch(spamFetch)
                
                for spam in results {
                    spamList.append(spam.text!.lowercased())
                }
            }
            catch let error as NSError {
                print("Fetch error: \(error) description: \(error.userInfo)")
            }
        }
    }
}

extension MessageFilterExtension: ILMessageFilterQueryHandling {
    
    func handle(_ queryRequest: ILMessageFilterQueryRequest, context: ILMessageFilterExtensionContext, completion: @escaping (ILMessageFilterQueryResponse) -> Void) {
        // First, check whether to filter using offline data (if possible).
        let offlineAction = self.offlineAction(for: queryRequest)
        
        switch offlineAction {
        case .allow, .filter:
            // Based on offline data, we know this message should either be Allowed or Filtered. Send response immediately.
            let response = ILMessageFilterQueryResponse()
            response.action = offlineAction
            
            completion(response)
            
        case .none:
            // Based on offline data, we do not know whether this message should be Allowed or Filtered. Defer to network.
            // Note: Deferring requests to network requires the extension target's Info.plist to contain a key with a URL to use. See documentation for details.
            context.deferQueryRequestToNetwork() { (networkResponse, error) in
                let response = ILMessageFilterQueryResponse()
                response.action = .none
                
                if let networkResponse = networkResponse {
                    // If we received a network response, parse it to determine an action to return in our response.
                    response.action = self.action(for: networkResponse)
                } else {
                    NSLog("Error deferring query request to network: \(String(describing: error))")
                }
                
                completion(response)
            }
        }
    }
    
    private func offlineAction(for queryRequest: ILMessageFilterQueryRequest) -> ILMessageFilterAction {
        getBlacklist()
        getSpamList()
        
        guard let messageBody = queryRequest.messageBody?.lowercased() else { return .none }
        
        //os_log("messageBody %s", messageBody)
        
        for spam in spamList {
            if (messageBody.contains(spam)) {
                return .filter
            }
        }
        
        guard let messageSender = queryRequest.sender?.lowercased() else { return .none }
        
        for sender in blackList {
            //os_log("sender %s", sender)
            
            if (messageSender == sender) {
                return .filter
            }
            
            if (sender.first == "*") {
                let range = NSRange(location: 0, length: messageSender.utf16.count)
                
                if let regex = try? NSRegularExpression(pattern: "[a-z]" + sender, options: .caseInsensitive) {
            
                    if (regex.firstMatch(in: messageSender, options: [], range: range) != nil) {
                        os_log("Matched regex")
                        return .filter
                    }
                }
                
            }
        }
        return .allow
    }
    
    private func action(for networkResponse: ILNetworkResponse) -> ILMessageFilterAction {
        // Replace with logic to parse the HTTP response and data payload of `networkResponse` to return an action.
        return .none
    }
    
}
