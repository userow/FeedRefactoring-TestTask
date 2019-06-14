# FeedRefactoring-TestTask

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
