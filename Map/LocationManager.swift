//
//  LocationManager.swift
//  GPSAndMap
//
//  Created by Ángel González on 20/06/25.
//

import Foundation
import CoreLocation

@objc protocol LocationManagerDelegate:NSObjectProtocol {
    
    func obtieneUbicacion(_ coord: CLLocation)
    
    @objc optional func obtieneDireccion(_ direc:String)
    
}

class LocationManager : NSObject, CLLocationManagerDelegate {
    
    var manager = CLLocationManager()
    var info : String = ""
    var coord: CLLocationCoordinate2D!
    var delegate: LocationManagerDelegate?
    
    override init () {
        super.init()
        manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
    }
    
    func getInfo (_ coord: CLLocation) {
        CLGeocoder().reverseGeocodeLocation(coord) { lugares, error in
            if error == nil {
                if let lugar = lugares?.first {
                    let thoroughfare = (lugar.thoroughfare ?? "")
                    let subThoroughfare = (lugar.subThoroughfare ?? "")
                    let locality = (lugar.locality ?? "")
                    let subLocality = (lugar.subLocality ?? "")
                    let administrativeArea = (lugar.administrativeArea ?? "")
                    let subAdministrativeArea = (lugar.subAdministrativeArea ?? "")
                    let postalCode = (lugar.postalCode ?? "")
                    let country = (lugar.country ?? "")
                    self.info = "Dirección: \(thoroughfare) \(subThoroughfare) \(locality) \(subLocality) \(administrativeArea) \(subAdministrativeArea) \(postalCode) \(country)"
                    if self.delegate != nil {
                        // si existe el delegado, no hay seguridad de que implemente el metodo, por eso validamos
                        if self.delegate!.responds(to:Selector(("obtieneDireccion"))) {
                            self.delegate?.obtieneDireccion?(self.info)
                        }
                    }
                }
            }
            else {
                self.info = "Usted está en lat:\(coord.coordinate.latitude), lon:\(coord.coordinate.longitude)"
            }
            if self.delegate != nil {
                self.delegate?.obtieneUbicacion(coord)
            }
        }
    }
    
    // CLLocationManagerDelegate methods
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print ("no se obtienen lecturas de GPS... y ahora que?")
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedAlways ||
            manager.authorizationStatus == .authorizedWhenInUse {
                // Para hacer un tracking de la ubicación del usuario
                // manager.startUpdatingLocation()
                // cuando terminamos de utilizar las lecturas GPS
                // manager.stopUpdatingLocation()
                
                // Si solo necesitamos una lectura
                manager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            getInfo(location)
        }
    }
}
