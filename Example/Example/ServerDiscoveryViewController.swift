//
//  ServerDiscoveryViewController.swift
//  Example
//
//  Created by Seth Faxon on 8/31/17.
//  Copyright © 2017 Filmic. All rights reserved.
//

import UIKit
import SMBClient

class ServerDiscoveryViewController: UIViewController {

    let biosNameService = NetBIOSNameService()

    @IBOutlet weak var tableView: UITableView!

    var servers: [NetBIOSNameServiceEntry] = [] {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        self.tableView.delegate = self
        self.tableView.dataSource = self

        biosNameService.delegate = self
        biosNameService.startDiscovery(withTimeout: 3000)

        self.title = "Servers"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? FilesTableViewController {
            dest.session = sender as? SMBSession
            dest.path = "/"
        }
    }

}

extension ServerDiscoveryViewController: NetBIOSNameServiceDelegate {
    func added(entry: NetBIOSNameServiceEntry) {
        print("ServerDiscoveryViewController added: \(entry)")
        self.servers.append(entry)
    }
    func removed(entry: NetBIOSNameServiceEntry) {
        print("ServerDiscoveryViewController removed - \(entry)")
        self.servers = self.servers.filter { $0 != entry }
    }
}

extension ServerDiscoveryViewController: UITableViewDelegate {

}

extension ServerDiscoveryViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.servers.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let server = self.servers[indexPath.row]
        cell.textLabel?.text = server.name

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let svr = self.servers[indexPath.row]

        let sess = SMBSession()
        sess.hostName = svr.name
        sess.ipAddress = svr.ipAddressString

        let vc = UIStoryboard.volumeListViewController(session: sess)
//        let vc = UIStoryboard.fileTableViewController(session: sess, title: "Shares")
        self.navigationController?.pushViewController(vc, animated: true)

        // self.performSegue(withIdentifier: "showFiles", sender: sess)
    }
}