//
//  ViewController.swift
//  Map
//
//  Created by Ángel González on 20/06/25.
//

import UIKit
import MapKit

class ViewController: UIViewController, LocationManagerDelegate, MKMapViewDelegate {
    
    func obtieneUbicacion(_ coord: CLLocation) {
        theMap.centerCoordinate = coord.coordinate
        settearRegion()
        //CLLocationCoordinate2D(latitude:19.331953, longitude: -99.18823)
    }

    var theMap:MKMapView!
    var locationManager:LocationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        theMap = MKMapView()
        theMap.frame = view.bounds
        view.addSubview(theMap)
        theMap.showsUserLocation = true
        locationManager = LocationManager()
        //locationManager.delegate = self
        theMap.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DataManager().getLocations { array in
            if let coordenadas = array {
                DispatchQueue.main.async {
                    for coord in coordenadas {
                        self.ponerMarca(coord, titulo: "Batman was Here!")
                    }
                    self.theMap.showAnnotations(self.theMap.annotations, animated: true)
                    // mostrar un área sobre el mapa
                    let theArea = MKPolygon(coordinates:coordenadas, count:coordenadas.count)
                    self.theMap.addOverlay(theArea)
                }
            }
        }
    }
    
    func settearRegion() {
        // la región del mapa se refiere al nivel de zoom
        let theRegion = MKCoordinateRegion(center:theMap.centerCoordinate, latitudinalMeters: 100, longitudinalMeters:100)
        theMap.setRegion(theRegion, animated:true)
        
        ponerMarca(theMap.centerCoordinate, titulo:"Usted está aquí!")
        // punto 2
        let punto2 = CLLocationCoordinate2D(latitude: 19.3032555, longitude: -99.1522551)
        ponerMarca(punto2, titulo:"Estadio Azteca")
        
        // trazamos una línea:
        let theLine = MKPolyline(coordinates:[theMap.centerCoordinate, punto2], count:2)
        theMap.addOverlay(theLine)
    }

    func ponerMarca(_ coord: CLLocationCoordinate2D, titulo:String) {
        let thePin = MKPointAnnotation()
        thePin.coordinate = coord
        thePin.title = titulo
        theMap.addAnnotation(thePin)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            // no le cambiamos la vista al pin que marca la ubicación del usuario
            return nil
        }
        
        let idf = "BatmanPin"
        var pinView:MKAnnotationView
        if let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier:idf) {
            pinView = annotationView
        }
        else {
            pinView = MKAnnotationView(annotation:annotation, reuseIdentifier:idf)
        }
        pinView.image = UIImage(named: "batman")
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let trazo = MKOverlayRenderer()
        if let linea = overlay as?  MKPolyline {
            let trazoL = MKPolylineRenderer(overlay: linea)
            trazoL.strokeColor = .red
            trazoL.lineWidth = 2.0
            return trazoL
        }
        else if let poly = overlay as? MKPolygon {
            let trazoP = MKPolygonRenderer(overlay: poly)
            trazoP.strokeColor = .purple
            trazoP.lineWidth = 2.0
            trazoP.fillColor = .purple.withAlphaComponent(0.5)
            return trazoP
        }
        return trazo
    }
}

