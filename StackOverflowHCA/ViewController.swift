//
//  ViewController.swift
//  StackOverflowHCA
//
//  Created by Reid Weber on 2/11/21.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var validTableViewData: [Item] = []
    
    override func viewDidLoad() {
        tableView.delegate = self
        tableView.dataSource = self
        super.viewDidLoad()
        getAPIData()
        // Do any additional setup after loading the view.
    }
    
    func getAPIData() {
        // get featured questions in descending order
        let apiString = "https://api.stackexchange.com/2.2/questions/featured?order=desc&sort=activity&site=stackoverflow"

        if let url = URL(string: apiString) {
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let data = data {
                    do {
                        let jsonData = try JSONDecoder().decode(Response.self, from: data)
                        for item in jsonData.items {
                            if self.isQuestionValid(item: item) {
                                self.validTableViewData.append(item)
                            }
                        }
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                        print(jsonData)
                    } catch let error {
                        print(error)
                    }
                }
            }.resume()
        }
    }
    
    func isQuestionValid(item: Item) -> Bool {
        if item.is_answered ?? false, item.answer_count ?? 0 > 1 {
            return true
        }
        return false
    }
    
    struct Response: Codable {
        let items: [Item]
    }

    struct Item: Codable {
        let title: String
        let answer_count: Int?
        let is_answered: Bool?
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return validTableViewData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "QuestionTableViewCell", for: indexPath) as! QuestionTableViewCell
        cell.titleLabel.text = validTableViewData[indexPath.row].title
        cell.contentView.bounds.size.height = cell.titleLabel.bounds.size.height
        return cell
    }

}

