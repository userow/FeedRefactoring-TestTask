/*:
 # Refactoring task
 - - -
 Here's programming case: this code is used for displaying feed on screen. Feed is displayed in table which consists of two sections. Based on conditions, we can have this situations:\
*First section*
 - If user enabled location:
     - if current city is determined from current location, in first section we should show city cell
 - ![current city](currentCityCell.png)
     - if current city is not determined we should show no city cell
     - ![no city found](noCityCell.png)
 - If user disabled location we should show no location enabled cell in first section
 - ![no location enabled](noLocationCell.png)
 
 
 *Second section*
 - If user has added social services - we should display social service cell for each service
 - ![social service](socialServiceCell.png)
 - If user has added friends - we should display friend cell for each friend
 - ![friend](friendCell.png)
 - If user has added neither social services nor friends we should display no social services added cell
 - ![no social services](noSocialServicesCell.png)
 
 *Your task for this case is to make changes to displayed feed easier. Also need to get rid of index calculations inside view controller.*
 */


// PaulV:

//TODO: 1 - create CellFactory
//TODO: ??? cell Factory ??? should create data source for HomeTVC Or, move responsibility to some Service ?
//TODO: transfer var-s to context - WRONG !  var-s changes are casued by checkCurrentUserState
//TODO: instantiate HomeVC with context

//TODO: ??? create TableAdapter - transfer TableDelegate and TableDataSource to Adapter
//TODO: ?? all data related - to Data Service ??


/*
 Should move all state-related logic out of TVC.
 TVC should only have list of DataItems.
 */


import UIKit

final class City {
    var name = ""
}

final class User {
    var addedSocialServices: [String] = []
    
    var name: String = ""
    
    var friends: [User] = []
    
    static func currentUser() -> User {
        return User()
    }
}

final class DataStorage {
    static var shared = DataStorage()

    var currentCity: City?
    var isLocationServiceEnabled: Bool = false
}

class HomeViewController: UITableViewController {
    
    let dataService = HomeService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 10.0, *) {
            tableView.refreshControl = innerRefreshControl
        } else {
            tableView.addSubview(innerRefreshControl)
        }
        
        innerRefreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
        
    }
    
    //done: TVC refresh - pull services refresh ( dataService.refreshData(); tableVew.reloadData() )
    //done: FUUUU%! I should implement table updtes due to state changes. BUT - hmmm...
    private let innerRefreshControl = UIRefreshControl()
    
    //done: put in pull to refresh ?
    @objc private func refreshData(_ sender: Any)  {
        dataService.refreshData()
        tableView.reloadData()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //HEEEERRRRREEEEESSSSYYY!!! But don't know where to move it. Probably to TVC refresh ?
//        checkCurrentUserState()

        if section == 0 {
            return 1
        } else if section == 1 {
            return dataService.socialData().count
        }
        
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let currentSection = indexPath.section

        if currentSection == 0 {
            return HomeCellFactory.getHomeCell(type: dataService.locationData())
        } else if currentSection == 1 {
            return HomeCellFactory.getHomeCell(type: dataService.socialData()[indexPath.row])
        }
        
        return UITableViewCell()
    }
}

/// HomeCellTypeEnum
enum HomeCellType {
    case noLocationCell
    case noCityCell
    case cityCell(city: City)
    
    case noSocialServicesAddedCell
    case socialServiceCell(service: String)
    case friendCell(friend: User)
}

//TODO: 1 - create cellFactory ???
// MARK: - Cell Factory

class HomeCellFactory
{
    /// generates a cell by CellType and fills it with data
    ///
    /// - Parameter type: CellType
    /// - Returns: TVC
    class func getHomeCell(type: HomeCellType) -> UITableViewCell {
        
        switch type {
        case .noLocationCell:
            return UITableViewCell()
        case .cityCell(let city):
            let cell = UITableViewCell()
            cell.textLabel?.text = city.name
            return cell
        case .noCityCell:
            return UITableViewCell()
            
            //??? Separate into two ?!
        case .socialServiceCell(let service):
            let cell = UITableViewCell()
            cell.textLabel?.text = service
            return cell
        case .noSocialServicesAddedCell:
            return UITableViewCell()
        case .friendCell(let friend):
            let cell = UITableViewCell()
            cell.textLabel?.text = friend.name
            return cell
        }
    }
}


//// MARK: - TVC Adapter - NOPE, will use service.
//
//import UIKit
//
//protocol HomeViewAdapterOutput {
//}
//
//final class HomeTableViewAdapter: NSObject {
//
//    // MARK: - Constants
//
//    private let output: HomeViewAdapterOutput
//
//    // MARK: - Properties
//
//    private var location: HomeCellFactory.HomeCellType
//
//    /// for second section
//    private var items: [HomeCellFactory.HomeCellType]
//
//    private (set) var tableView: UITableView {
//        didSet {
////            tableView.register(UINib(nibName: <#CellName#>, bundle: nil), forCellReuseIdentifier: <#CellName#>)
//        }
//    }
//
//    // MARK: - Initialization and deinitialization
//
//    init(output: HomeViewAdapterOutput) {
//        self.output = output
//    }
//
//    // MARK: - Internal helpers
//
//    func set(tableView: UITableView) {
//        self.tableView = tableView
//    }
//
//    func configure(with items: [HomeCellFactory.HomeCellType]) {
//        self.items = items
//    }
//
//}
//
//
//// MARK: - UITableViewDataSource
//
//extension HomeTableViewAdapter: UITableViewDataSource {
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return items.count
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = UITableViewCell()
//        return cell
//    }
//}
//
//
//// MARK: - UITableViewDelegate
//
//extension HomeTableViewAdapter: UITableViewDelegate {
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
//    }
//}


final class HomeService {
    private var dataStorage: DataStorage
    private var user: User
    
    private var location: HomeCellType = .noCityCell
    private var socials: [HomeCellType] = [ .noSocialServicesAddedCell ]
    
    
    // MARK: - Initialization and deinitialization
    
    init(locationData: DataStorage = DataStorage.shared, user: User = User.currentUser()) {
        self.dataStorage = locationData
        self.user = user
        
        self.refreshData()
    }
    
    //public refresh
    func refreshData() {
        self.location = getLocationData()
        self.socials = getSocialData()
    }
    
    private func getLocationData() -> HomeCellType {
        if !dataStorage.isLocationServiceEnabled {
            return .noLocationCell
        }
        
        guard let city = dataStorage.currentCity else {
            return .noCityCell
        }
        
        return .cityCell(city: city)
    }
    
    /// refreshes social data - socials and user's friends
    private func getSocialData() -> [HomeCellType] {
        
        if user.addedSocialServices.count == 0 && user.friends.count == 0 {
            return [.noSocialServicesAddedCell]
        }
        var localSocialData: [HomeCellType] = []
        
        user.addedSocialServices.forEach { social in
            localSocialData.append(.socialServiceCell(service: social))
        }
        
        user.friends.forEach { (friend) in
            localSocialData.append(.friendCell(friend: friend))
        }
        
        return localSocialData
    }
    
    /// public immutable location
    func locationData() -> HomeCellType {
        let loc = self.location
        return loc
    }
    
    /// public immutable socialData
    func socialData() -> [HomeCellType] {
        let soc = self.socials
        return soc
    }
}
