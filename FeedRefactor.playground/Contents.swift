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
import UIKit

final class City {
    var name = ""
}

final class User {
    var addedSocialServices: [String] = []
    
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
    
    var isLocationEnabled: Bool = false
    var hasFriends: Bool = false
    var hasAddedSocialServices: Bool = false
    var hasDeterminedCurrentCity: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkCurrentUserState()
    }
    
    func checkCurrentUserState() {
        isLocationEnabled = DataStorage.shared.isLocationServiceEnabled
        hasDeterminedCurrentCity = DataStorage.shared.currentCity != nil
        hasAddedSocialServices = User.currentUser().addedSocialServices.count > 0
        hasFriends = User.currentUser().friends.count > 0
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        checkCurrentUserState()

        if section == 0 {
            return 1
        } else {
            var cellsCount = 0

            if hasAddedSocialServices {
                cellsCount += User.currentUser().addedSocialServices.count
            }
            
            if hasFriends {
                cellsCount += User.currentUser().friends.count
            }
        }
        
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        checkCurrentUserState()
        let currentSection = indexPath.section
        
        if currentSection == 0 {
            if isLocationEnabled {
                if hasDeterminedCurrentCity {
                    return cityCell(city: DataStorage.shared.currentCity!)
                } else {
                    return noCityCell()
                }
            } else {
                return noLocationCell()
            }
        } else {
            let count = self.tableView(tableView, numberOfRowsInSection: currentSection)
            
            if count == 0 {
                return noSocialServicesAddedCell()
            } else {
                let currentRow = indexPath.row
                
                if hasAddedSocialServices && User.currentUser().addedSocialServices.count < currentRow {
                    let currentSocialService = User.currentUser().addedSocialServices[currentRow]
                    return socialServiceCell(service: currentSocialService)
                }
                
                if hasFriends {
                    let index = currentRow - User.currentUser().addedSocialServices.count
                    let friend = User.currentUser().friends[index]
                    return friendCell(friend: friend)
                }
            }
        }
        
        return UITableViewCell()
    }
    
    func noLocationCell() -> UITableViewCell {
        return UITableViewCell()
    }
    
    func cityCell(city: City) -> UITableViewCell {
        return UITableViewCell()
    }
    
    func noCityCell() -> UITableViewCell {
        return UITableViewCell()
    }
    
    func socialServiceCell(service: String) -> UITableViewCell {
        return UITableViewCell()
    }
    
    func noSocialServicesAddedCell() -> UITableViewCell {
        return UITableViewCell()
    }
    
    func friendCell(friend: User) -> UITableViewCell {
        return UITableViewCell()
    }
}
