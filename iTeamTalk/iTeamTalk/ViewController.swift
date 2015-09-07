//
//  ViewController.swift
//  iTeamTalk
//
//  Created by Bjoern Rasmussen on 3-09-15.
//  Copyright (c) 2015 BearWare.dk. All rights reserved.
//

import UIKit

class ViewController: UIViewController,
    UITableViewDataSource, NSXMLParserDelegate {

    @IBOutlet weak var serverTableView: UITableView!
    @IBOutlet weak var appnameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        serverTableView.dataSource = self
        let version = String.fromCString(TT_GetVersion())!
        appnameLabel.text = AppInfo.APPTITLE + " " + version
        
        // get xml-list of public server
        var parser = NSXMLParser(contentsOfURL: NSURL(string: AppInfo.URL_FREESERVER))!
        parser.delegate = self
        parser.parse()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return servers.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cellIdentifier = "ServerTableCell"
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! ServerTableCell
        
        let server = servers[indexPath.item]
        cell.connectBtn.tag = indexPath.item
        cell.nameLabel.text = server.name
        cell.ipaddrLabel.text = server.ipaddr
        
        return cell
    }

    
    @IBAction func connectToServer(sender: UIButton) {
        
    }

    // Properties of a TeamTalk server to connect to
    struct Server {
        var name = ""
        var ipaddr = ""
        var tcpport = 10333
        var udpport = 10333
        var username = ""
        var password = ""
        var channel = ""
        var chanpasswd = ""
    }
    
    var servers = [Server]()
    
    var currentServer = Server()
    var elementStack = [String]()
    
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [NSObject : AnyObject]) {
        
        self.elementStack.append(elementName)
        if elementName == "host" {
            currentServer = Server()
        }
    }
    
    func parser(parser: NSXMLParser, foundCharacters string: String?) {
        
        if string == nil { return }
        
        switch elementStack.last! {
        case "name" :
            currentServer.name = string!
        case "address" :
            currentServer.ipaddr = string!
        case "tcpport" :
            let v : String = string!
            currentServer.tcpport = v.toInt()!
        case "udpport" :
            let v : String = string!
            currentServer.udpport = v.toInt()!
        case "username" :
            currentServer.username = string!
        case "password" :
            if find(elementStack, "auth") != nil {
                currentServer.password = string!
            }
            else if find(elementStack, "join") != nil {
                currentServer.chanpasswd = string!
            }
        default :
            println("Unknown tag " + self.elementStack.last!)
        }
    }
    
    func parser(parser: NSXMLParser, didEndElement elementName: String,
        namespaceURI: String?, qualifiedName qName: String?) {
            
            self.elementStack.removeLast()
            if elementName == "host" {
                servers.append(currentServer)
            }
    }

}
