//
//  FiltersViewController.swift
//  Yelp
//
//  Created by Ngan, Naomi on 9/22/17.
//  Copyright © 2017 Timothy Lee. All rights reserved.
//

import UIKit

@objc protocol FiltersViewControllerDelegate {
    @objc optional func filtersViewController(filtersViewControllers:FiltersViewController, didUpdateFilters filters: [String:AnyObject])
}

class FiltersViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, FiltersViewControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    weak var delegate: FiltersViewControllerDelegate?
    
    fileprivate var filter: Filters = Filters.init()
    fileprivate var filtersHandler: (Filters) -> Void = { (filter) in }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
    }

    func prepare(filter: Filters?, filterHandler: @escaping (Filters) -> Void) {
        if let filter = filter {
            self.filter = filter
        }
        self.filtersHandler = filterHandler
    }
    
    @IBAction func onCancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func onSearchButton(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
        var filtersAdded = [String:AnyObject]()
        
        // Deals
        filtersAdded["deals"] = filter.hasDealSwitchState as AnyObject
        
        // Distance
        for (row, isSelected) in filter.distanceSwitchStates {
            if isSelected {
                filtersAdded["distance"] = filter.distances[row] as AnyObject
            }
        }

        // Sort
        filtersAdded["sort"] = 0 as AnyObject // default value
        for (row, isSelected) in filter.sortSwitchStates {
            if isSelected {
                filtersAdded["sort"] = row as AnyObject
            }
        }

        // Categories
        var selectedCategories = [String]()
        for (row, isSelected) in filter.categoriesSwitchStates {
            if isSelected {
                selectedCategories.append(filter.categories[row]["code"]!)
            }
        }
        if selectedCategories.count > 0 {
            filtersAdded["categories"] = selectedCategories as AnyObject
        }
        delegate?.filtersViewController?(filtersViewControllers: self, didUpdateFilters: filtersAdded)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 7
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0, 1, 3, 5:
            return 1
        case 2:
            return filter.showDistance ? filter.distances.count : 0
        case 4:
            return filter.showSorts ? filter.sorts.count : 0
        case 6:
            return filter.showCategories ? filter.categories.count : 0
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0, 1, 3, 5:
            return 40
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
            
        case 0:
            let dealCell = tableView.dequeueReusableCell(withIdentifier: "DealSwitchCell", for: indexPath) as! DealSwitchCell
            dealCell.dealSwitch.isOn = filter.hasDealSwitchState
            dealCell.switchHandler = { (isOn)  in
                self.filter.hasDealSwitchState = isOn
                self.tableView.reloadData()
            }
            return dealCell
            
        case 1:
            let distanceSwitchCell = tableView.dequeueReusableCell(withIdentifier: "DistanceSwitchCell", for: indexPath) as! DistanceSwitchCell
            distanceSwitchCell.distanceSwitch.isOn = filter.showDistance
            distanceSwitchCell.switchHandler = { (isOn)  in
                self.filter.showDistance = isOn
                self.tableView.reloadData()
            }
            
            return distanceSwitchCell
        case 2:
            let distanceCell = tableView.dequeueReusableCell(withIdentifier: "DistanceCell") as! DistanceCell
            distanceCell.distanceName.text = "\(filter.distances[indexPath.row]) miles"
            distanceCell.accessoryType = (filter.distanceSwitchStates[indexPath.row] ?? false) ? .checkmark : .none
            return distanceCell
        case 3:
            let sortSwitchCell = tableView.dequeueReusableCell(withIdentifier: "SortSwitchCell", for: indexPath) as! SortSwitchCell
            sortSwitchCell.sortSwitch.isOn = filter.showSorts
            sortSwitchCell.switchHandler = { (isOn)  in
                self.filter.showSorts = isOn
                self.tableView.reloadData()
            }
            
            return sortSwitchCell
        case 4:
            let sortCell = tableView.dequeueReusableCell(withIdentifier: "SortCell") as! SortCell
            sortCell.sortName.text = "\(filter.sorts[indexPath.row])"
            sortCell.accessoryType = (filter.sortSwitchStates[indexPath.row] ?? false) ? .checkmark : .none
            return sortCell
        case 5:
            let categorySwitchCell = tableView.dequeueReusableCell(withIdentifier: "CategorySwitchCell", for: indexPath) as! CategorySwitchCell
            categorySwitchCell.categorySwitch.isOn = filter.showCategories
            categorySwitchCell.switchHandler = { (isOn)  in
                self.filter.showCategories = isOn
                self.tableView.reloadData()
            }
            
            return categorySwitchCell
        case 6:
            let categoryCell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell") as! CategoryCell
            categoryCell.categoryName.text = filter.categories[indexPath.row]["name"]
            categoryCell.accessoryType = (filter.categoriesSwitchStates[indexPath.row] ?? false) ? .checkmark : .none
            return categoryCell

        default:
            return UITableViewCell()
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 2 { // Distance
            let distanceCell = tableView.cellForRow(at: indexPath) as! DistanceCell
            distanceCell.isSelected = false
            
            let isIncluded = distanceCell.accessoryType == .checkmark
            distanceCell.accessoryType = isIncluded ? .none : .checkmark
            
            // Uncheck everything else
            if !isIncluded {
                for (row, isSelected) in filter.distanceSwitchStates {
                    let rowNumber = row as Int!
                    if isSelected {
                        filter.distanceSwitchStates[rowNumber!] = false
                    }
                }
            }
            filter.distanceSwitchStates[indexPath.row] = !isIncluded
            self.tableView.reloadData()
            
        } else if indexPath.section == 4 { // Sort by
            let sortCell = tableView.cellForRow(at: indexPath) as! SortCell
            sortCell.isSelected = false
                
            let isIncluded = sortCell.accessoryType == .checkmark
            sortCell.accessoryType = isIncluded ? .none : .checkmark
            
            // Uncheck everything else
            if !isIncluded {
                for (row, isSelected) in filter.sortSwitchStates {
                    let rowNumber = row as Int!
                    if isSelected {
                        filter.sortSwitchStates[rowNumber!] = false
                    }
                }
            }
            filter.sortSwitchStates[indexPath.row] = !isIncluded
            self.tableView.reloadData()
        } else if indexPath.section == 6 { // Categories
            let categoryCell = tableView.cellForRow(at: indexPath) as! CategoryCell
            categoryCell.isSelected = false

            let isIncluded = categoryCell.accessoryType == .checkmark
            categoryCell.accessoryType = isIncluded ? .none : .checkmark
            filter.categoriesSwitchStates[indexPath.row] = !isIncluded
            
        }
    
    }
}
