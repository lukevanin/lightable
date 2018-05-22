//
//  Copyright © 2018 Luke Van In. All rights reserved.
//

import UIKit

//
//
//
class TestTableViewController: UITableViewController {
    
    var provider: Any?
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let data = [
            "🦊 fox",
            "🦇 bat",
            "🦍 ape",
            "🐷 pig",
            "🐮 cow",
            "🐶 dog",
            "🙀 cat",
            "🐀 rat",
            "🐗 hog",
            "🐞 bug",
            "🐝 bee",
            "🐜 ant",
            "🐔 hen",
            "🦉 owl",
            ]
        
        self.provider = TableListProvider(
            tableView: tableView,
            list: CollectionListProvider(data),
            factory: ClassTableCellFactory<UITableViewCell>(reuseIdentifier: "animal"),
            configure: { cell, item in
                cell.textLabel?.text = item
            }
        )
    }
}
