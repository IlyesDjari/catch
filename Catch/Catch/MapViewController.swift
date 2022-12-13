//
//  MapViewController.swift
//  Catch
//
//  Created by Ilyes Djari on 29/11/2022.
//

import UIKit
import GoogleMaps
import CoreLocation
import PopupDialog

class MapViewController: UIViewController, GMSMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var gameScoreView: UIView!
    @IBOutlet weak var diamondScoreView: UIView!
    @IBOutlet weak var butterflyScoreView: UIView!
    @IBOutlet weak var featherScoreView: UIView!
    @IBOutlet weak var diamondScoreLabel: UILabel!
    @IBOutlet weak var butterflyScoreLabel: UILabel!
    @IBOutlet weak var featherScoreLabel: UILabel!
    @IBOutlet weak var mapView: GMSMapView!
    
    var storedpokemon : [StoredPokemon] = []
    var amountOfCoins : [Diamonds] = []
    var yourPokemons: [Pokemon]?
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    @IBAction func openPokedex(_ sender: Any) {
        self.performSegue(withIdentifier: "pokedexSegue", sender: sender)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let pokeDex = segue.destination as! ViewController
        pokeDex.storedpokemon = storedpokemon
        pokeDex.diamond = diamond1Score
    }
    
    
    var locationManager = CLLocationManager()
    var userLocation = CLLocation()
    var bearingAngle = 270.0
    var angleOfView = 65.0
    var zoomLevel:Float = 18
    var capitolLat = 38.889815
    var capitolLon = -77.005900
    var userMarker = GMSMarker()
    let userMarkerimageView = UIImageView(image: UIImage.gifImageWithName("player"))
    public var diamond1Score : Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpScoreView()
        initializeMap()
        getDataFromContext()
        getCoins()
    }
    

    func setMapTheme(theme: String) {
    if theme == "Day" {
    do {
    if let styleURL = Bundle.main.url(forResource: "DayStyle", withExtension: "json") {
    mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
    } else {
    NSLog("Unable to find DayStyle.json")
    }
    } catch {
    NSLog("One or more of the map styles failed to load. \(error)")
    }
    } else if theme == "Evening" {
    do {
    if let styleURL = Bundle.main.url(forResource: "EveningStyle", withExtension: "json") {
    mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
    } else {
    NSLog("Unable to find EveningStyle.json")
    }
    } catch {
    NSLog("One or more of the map styles failed to load. \(error)")
    }
    } else {
    do {
    if let styleURL = Bundle.main.url(forResource: "NightStyle", withExtension: "json") {
    mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
    } else {
    NSLog("Unable to find NightStyle.json")
    }
    } catch {
    NSLog("One or more of the map styles failed to load. \(error)")
    }
    }
    }
    
    func centerMapAtUserLocation() {
    let locationObj = locationManager.location
    let coord = locationObj?.coordinate
    let lattitude = coord?.latitude
    let longitude = coord?.longitude
    userMarkerimageView.frame = CGRect(x: 0, y: 0, width: 40, height: 70)
    let camera: GMSCameraPosition = GMSCameraPosition.camera(withLatitude: lattitude ?? capitolLat, longitude: longitude ?? capitolLon, zoom: zoomLevel, bearing: bearingAngle, viewingAngle: angleOfView)
    self.mapView.animate(to: camera)
    }
    
    func checkUserPermission() {
    
    let manager = CLLocationManager()
    locationManager.delegate = self
    if CLLocationManager.locationServicesEnabled() {
    switch (manager.authorizationStatus) {
    case .notDetermined:
    perform(#selector(presentNotDeterminedPopup), with: nil, afterDelay: 0)
    case .restricted, .denied:
    perform(#selector(presentDeniedPopup), with: nil, afterDelay: 0)
    case .authorizedAlways, .authorizedWhenInUse:
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
    self.locationManager.startUpdatingLocation()
    locationManager.startUpdatingHeading()
    centerMapAtUserLocation()
    addMarkers()
    @unknown default:
        fatalError()
    }
    } else {
    perform(#selector(presentDeniedPopup), with: nil, afterDelay: 0)
    }
    }
    
    @objc private func presentNotDeterminedPopup() {
    let title = "Allow Location"
    let message = "Allow location to discover and collect diamonds near you."
    let image = UIImage(named: "userLocation-cover")
    let popup = PopupDialog(title: title, message: message, image: image)
    let skipButton = CancelButton(title: "Skip for now") {
    self.dismiss(animated: true, completion: nil)
    }
    let okButton = DefaultButton(title: "Okay") {
    self.locationManager.requestWhenInUseAuthorization()
    }
    popup.addButtons([skipButton, okButton])
    self.present(popup, animated: true, completion: nil)
    }
    
    @objc private func presentDeniedPopup() {
    let title = "Allow Location"
    let message = "Allow location to discover and collect diamonds near you on Catch. Open setting and allow location when in use."
    let image = UIImage(named: "userLocation-cover")
    let popup = PopupDialog(title: title, message: message, image: image)
    let skipButton = CancelButton(title: "Skip for now") {
    }
    let settingsButton = DefaultButton(title: "Open Settings", dismissOnTap: false) {
    guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
    return
    }
    if UIApplication.shared.canOpenURL(settingsUrl) {
    UIApplication.shared.open(settingsUrl, options: [:], completionHandler: nil)
    }
    }
    popup.addButtons([skipButton, settingsButton])
    self.present(popup, animated: true, completion: nil)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    switch status {
    case .notDetermined:
    perform(#selector(presentNotDeterminedPopup), with: nil, afterDelay: 0)
    case .restricted, .denied:
    perform(#selector(presentDeniedPopup), with: nil, afterDelay: 0)
    case .authorizedAlways, .authorizedWhenInUse:
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
    self.locationManager.startUpdatingLocation()
    locationManager.startUpdatingHeading()
    self.centerMapAtUserLocation()
    @unknown default:
        fatalError()
    }
    }

    func initializeMap() {
    self.mapView.delegate = self
    let camera = GMSCameraPosition.camera(withLatitude: capitolLat, longitude: capitolLon, zoom: zoomLevel, bearing: bearingAngle,
    viewingAngle: angleOfView)
    self.mapView.camera = camera
    let hour = Calendar.current.component(.hour, from: Date())
    switch hour {
    case 7..<15 : setMapTheme(theme: "Day")
    case 15..<18 : setMapTheme(theme: "Evening")
    default: setMapTheme(theme: "Night")
    }
    self.mapView.settings.tiltGestures = false
    self.mapView.settings.rotateGestures = false
    self.mapView.settings.zoomGestures = false
    self.mapView.settings.compassButton = true
    mapView.settings.allowScrollGesturesDuringRotateOrZoom = true
    mapView.settings.indoorPicker = false
    self.mapView.settings.scrollGestures = false
    checkUserPermission()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    userLocation = locations.last ?? CLLocation(latitude: capitolLat, longitude: capitolLon)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
    let camera: GMSCameraPosition = GMSCameraPosition.camera(withLatitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude, zoom: zoomLevel, bearing: bearingAngle, viewingAngle: angleOfView)
    self.mapView.animate(to: camera)
    mapView.animate(toBearing: newHeading.magneticHeading)
    userMarker.map = nil
    userMarker.position = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
    userMarker.iconView = userMarkerimageView
    userMarker.groundAnchor = CGPoint(x: 0.5, y: 1.0)
    userMarker.map = mapView
    }
    
    func distanceInMeters(marker: GMSMarker) -> CLLocationDistance {
    let markerLocation = CLLocation(latitude: marker.position.latitude , longitude: marker.position.longitude)
    let metres = locationManager.location?.distance(from: markerLocation)
    return Double(metres ?? -1)
    }
    
    func addMarkers() {
            
        let diamond1Gif = UIImage.gifImageWithName("diamond1")
        let diamond1GifView = UIImageView(image: diamond1Gif)
        diamond1GifView.frame = CGRect(x: 0, y: 0, width: 70, height: 70)
        
        let locationObj = locationManager.location
        let coord = locationObj?.coordinate
        let lattitude = coord?.latitude
        let longitude = coord?.longitude
            
        for i in 0...75 {

            let radius : Double = 1000
            let radiusInDegrees: Double = radius / 111000
            let u : Double = Double(arc4random_uniform(100)) / 100.0
            let v : Double = Double(arc4random_uniform(100)) / 100.0
            let w : Double = radiusInDegrees * u.squareRoot()
            let t : Double = 2 * Double.pi * v
            let x : Double = w * cos(t)
            let y : Double = w * sin(t)
            let new_x : Double = x / cos(lattitude! * .pi / 180 )
            let processedLat = new_x + lattitude!
            let processedLng = y + longitude!
            
                var marker:  GMSMarker?
                let position = CLLocationCoordinate2D(latitude: processedLat, longitude: processedLng)
                marker = GMSMarker(position: position)
                marker?.title = "Distance Left: \(round(100*distanceInMeters(marker: marker!))/100) miles"
                marker?.map = mapView
                marker?.iconView = diamond1GifView            
            }
        }
    
    
        func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
            
            let distance = round(100*distanceInMeters(marker: marker))/100
            print(distance)
            if distance < 20 {
                let title = "Added to collection"
                let message = "Marker added to your collection"
                let popup = PopupDialog(title: title, message: message)
                let okButton = DefaultButton(title: "Yayyy!") {
                    self.diamond1Score = self.diamond1Score + 1
                    self.saveCoins(diamond1score: self.diamond1Score)
                    marker.map = nil
                }
                popup.addButton(okButton)
                self.present(popup, animated: true, completion: nil)
            } else {
                let title = "Too Far!"
                let message = "You're too far from this diamond, \(distance)M. Get closer!"
                
                let popup = PopupDialog(title: title, message: message)
                let okButton = DefaultButton(title: "Ok") {
                    
                }
                popup.addButton(okButton)
                self.present(popup, animated: true, completion: nil)
            }
            
            return true
            
        }
        
        func setUpScoreView() {
            self.view.bringSubviewToFront(gameScoreView)
            gameScoreView.layer.cornerRadius = 10
            gameScoreView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
            
            diamondScoreView.layer.cornerRadius = 25
            butterflyScoreView.layer.cornerRadius = 25
            diamondScoreView.layer.masksToBounds = true
            butterflyScoreView.layer.masksToBounds = true
        }
    
    
    
    
    
    
    
    

    
    
    private func getDataFromContext()  {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        do {
            storedpokemon = try context.fetch(StoredPokemon.fetchRequest())
        } catch {
            print("Fetching Failed")
        }
        
        if storedpokemon.count == 0 {
            Task {
                await getPokemon()
            }
        } else {
            yourPokemons = []
            for pokemons in storedpokemon {
                let pokemonInfo = Pokemon(id: Int(bitPattern: pokemons.id), name: pokemons.name!, sprites: Pokemon.Sprites.init(frontDefault: "you"))
                yourPokemons?.append(pokemonInfo)
            }
        }

    }
    
    private func getCoins() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        do {
            amountOfCoins = try context.fetch(Diamonds.fetchRequest())
        } catch {
            print("Fetching Failed")
        }
        diamond1Score = amountOfCoins.count
        self.diamondScoreLabel.text = "\(self.diamond1Score)"
        
    }
    
    
    @objc private func getPokemon() async  -> Void {
        await Webservice.getDataFromWebservice { pokemonInfo in
            self.yourPokemons = pokemonInfo
                self.saveData()
        }
    }
    
    func saveCoins(diamond1score: Int) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let coin = Diamonds(context: context)
        coin.coins = Int64(diamond1score)
        self.diamondScoreLabel.text = "\(self.diamond1Score)"
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
    }
    
    func saveData() {
        for fullInventory in self.yourPokemons! {
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            let poke = StoredPokemon(context: context)
            poke.name = fullInventory.name
            poke.frontDefault = fullInventory.sprites.frontDefault
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
        }
    }
    
}
