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
        let studentData = StudentInformationModel.studentLocation[indexPath.row]
        openWebsiteLink(urlString: studentData.mediaURL)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func openWebsiteLink(urlString: String?) {
        guard let urlString = urlString else {
            handleFailureAlert(title: "Failed to Open ", message: "No web address given.")
            return
        }
        
        let studentWebSite = URL(string: urlString)
        if let validURLString = studentWebSite {
            let validURL: Bool = UIApplication.shared.canOpenURL(validURLString)
            if validURL {
                UIApplication.shared.open(validURLString, options: [:], completionHandler: nil)
            } else {
                handleFailureAlert(title: "Failed to Open ", message: "Invalid web address.")
            }
        } else {
            handleFailureAlert(title: "Failed to Open ", message: "No web address given.")
        }
    }

}
