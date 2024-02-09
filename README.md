#  Maine Maps

This project uses the ArcGIS Maps SDK for Swift (https://developers.arcgis.com/swift/)
Using the app you can view the online map and also download offline map areas for viewing without an internet connect
The project uses CoreData and SwiftUI to store and display maps

<p float="middle">
    <img src="/Screenshots/predownload.png" width="45%">
    <img src="/Screenshots/fullscreenMaine.png" width="45%">
    <img src="/Screenshots/postdownload.png" width="45%">
    <img src="/Screenshots/fullscreenBangor.png" width="45%">
</p>

## TO USE:
1. Open the project locally  

    a. Clone the project or download zip file and unzip 
    ```sh
    git clone git@github.com:angelak1/MaineMaps.git
    ```
    
    b. Open **MaineMaps.xcodeproj** in Xcode
    
2. Add API key to **MaineMapsApp.swift**   
    a. Create a free ArcGIS Developer Account [https://developers.arcgis.com/sign-up/](https://developers.arcgis.com/sign-up/) and Sign In   
    b. Go to [https://developers.arcgis.com/api-keys/](https://developers.arcgis.com/api-keys/) and tap the **+ New API Key** Button   
    c. Add a title for the API Key and tap the **Create API Key** Button   
    d. Copy your newly created API Key   
    e. Open **MaineMapsApp.swift**   
    f. Add your API Key to this line: 
    ```sh
    ArcGISEnvironment.apiKey = APIKey("exampleAPIKey")
    ```
    g. Build and run the app
    
### Bonus:
You can modify the app to display different map areas of your choosing by following these steps:   

1. Create your own offline map areas by following the ArcGIS documentation: [https://developers.arcgis.com/swift/offline-maps-scenes-and-data/tutorials/create-an-offline-map-area/](https://developers.arcgis.com/swift/offline-maps-scenes-and-data/tutorials/create-an-offline-map-area/)
2. Copy the id from the url of the **Item Details** page  
3. Open **MapsViewModel.swift** and modify the following lines with your map id
```sh
extension PortalItem  {
    static func mainMap() -> PortalItem {
        PortalItem(portal: .arcGISOnline(connection: .anonymous), id: PortalItem.ID("your map id")!)
    }
}
```
4. Build and run the app


