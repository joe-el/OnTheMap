//
//  TableTabViewController.swift
//  OnTheMap
//
//  Created by Kenneth Gutierrez on 5/13/22.
//

import Foundation
import UIKit

class TableTabViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
}

extension TableTabViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return StudentInformationModel.studentLocation.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StudentTableViewCell")!

        let students = StudentInformationModel.studentLocation[indexPath.row]
        
        // Previous method was deprecated, now I'm using content configuration to manage the cell’s properties:
        var contentConfig = cell.defaultContentConfiguration()

        // Set the first and last name, URL link associated with the student’s pin, and image
        contentConfig.text = "\(students.firstName) \(students.lastName)"
        contentConfig.secondaryText = students.mediaURL
        contentConfig.image = UIImage(named: "icon_pin")
        
        cell.contentConfiguration = contentConfig

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let studentData = StudentInformationModel.studentLocation[indexPath.row]
//
//        // Need to check if valid address is given or any at all-need a throw...
//        let studentWebSite = URL(string: studentData.mediaURL)!
//
//        UIApplication.shared.open(studentWebSite, options: [:], completionHandler: nil)
        
        do {
            try openWebsiteLink(indexPath: indexPath.row)
        } catch let error as NSError {
            handleFailureAlert(title: "Failed to Open ", message: error as! String)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func openWebsiteLink(indexPath: Int) throws {
        let studentData = StudentInformationModel.studentLocation[indexPath]
        
        // Need to check if valid address is given or any at all-need a throw...
        let studentWebSite = URL(string: studentData.mediaURL)!
        
        do {
            let _ = try UIApplication.shared.open(studentWebSite, options: [:], completionHandler: nil)
        } catch let error as NSError {
            handleFailureAlert(title: "Failed to Open ", message: error as! String)
        }
    }

}
