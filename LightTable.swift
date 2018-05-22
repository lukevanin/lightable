//
//  Copyright © 2018 Luke Van In. All rights reserved.
//

import UIKit

//
//  Abstract collection where items are accessed by a two dimensional index path.
//
protocol ListProtocol {
    associatedtype Item
    var numberOfSections: Int { get }
    func numberOfItems(in section: Int) -> Int
    func item(at indexPath: IndexPath) -> Item
}

//
//  Abstract factory for instantiating UITableViewCells.
//
protocol TableCellFactoryProtocol {
    associatedtype Cell: UITableViewCell
    func register(in tableView: UITableView)
    func tableView(_ tableView: UITableView, dequeueReusableCellAt indexPath: IndexPath) -> Cell
}

//
//  Abstract factory for instantiating UICollectionViewCells.
//
protocol CollectionViewCellFactoryProtocol {
    associatedtype Cell: UICollectionViewCell
    func register(in collectionView: UICollectionView)
    func collectionView(_ collectionView: UICollectionView, dequeueReusableCellAt indexPath: IndexPath) -> Cell
}

//
//  Concrete factory for instantiating UITableViewCells defined as classes.
//  Note: Other concrete factories can be created for vending cells defined in nibs and storyboards, and also for
//  for vending collection view cells following the same pattern.
//
struct ClassTableCellFactory<T>: TableCellFactoryProtocol where T: UITableViewCell {
    
    typealias Cell = T
    let reuseIdentifier: String
    
    func register(in tableView: UITableView) {
        tableView.register(Cell.self, forCellReuseIdentifier: reuseIdentifier)
    }
    
    func tableView(_ tableView: UITableView, dequeueReusableCellAt indexPath: IndexPath) -> Cell {
        return tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! Cell
    }
}

//
//  Concrete list that adapts a one dimensional collection to be used by a list consumer.
//  Note: Other concrete list providers can be implemented for two dimensional data sets
//  (e.g. NSFetchedResultsController).
//
class CollectionListProvider<T>: ListProtocol {
    
    typealias Item = T
    
    private let count: Int
    private let itemAt: (Int) -> Item
    
    init<C>(_ collection: C) where C: Collection, C.Index == Int, C.Element == Item {
        self.count = collection.count
        self.itemAt = { collection[$0] }
    }
    
    var numberOfSections: Int {
        return 1
    }
    
    func numberOfItems(in section: Int) -> Int {
        return count
    }
    
    func item(at indexPath: IndexPath) -> Item {
        return itemAt(indexPath.row)
    }
}

//
//  Concrete implementation of UITableViewDataSource.
//  Note: This class also conforms to the UITableViewDelegate protocol as a convenience. It does not actually implement
//  any of the table view delegate methods. Override this class to implement UITableViewDelegate methods.
//
class TableListProvider<F, L>: NSObject, UITableViewDataSource, UITableViewDelegate where F: TableCellFactoryProtocol, L: ListProtocol {
    
    typealias List = L
    typealias Factory = F
    typealias Configure = (Factory.Cell, List.Item) -> Void

    var configure: Configure?

    private let list: List
    private let factory: Factory
    
    init(list: List, factory: Factory, configure: Configure? = nil) {
        self.list = list
        self.factory = factory
        self.configure = configure
    }
    
    func register(in tableView: UITableView) {
        factory.register(in: tableView)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return list.numberOfSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.numberOfItems(in: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = list.item(at: indexPath)
        let cell = factory.tableView(tableView, dequeueReusableCellAt: indexPath)
        configure?(cell, item)
        return cell
    }
}

extension TableListProvider {
    
    //
    //  Convenience initializer. Registers the cell factory with the table view, and sets the table view delegate
    //  and data source.
    //
    convenience init(tableView: UITableView, list: List, factory: Factory, configure: Configure? = nil) {
        self.init(list: list, factory: factory, configure: configure)
        register(in: tableView)
        tableView.dataSource = self
        tableView.delegate = self
    }
}
