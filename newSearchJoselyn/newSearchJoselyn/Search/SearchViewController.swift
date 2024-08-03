//
//  ViewController.swift
//  newSearchJoselyn
//
//  Created by Joselyn Cordero on 02/08/24.
//

import UIKit
import CoreLocation


class SearchViewController: UIViewController {
    
    
    @IBOutlet weak var titleAirport: UILabel!
    @IBOutlet weak var finderLabel: UILabel!
    @IBOutlet weak var numberSelect: UILabel!
    @IBOutlet weak var latitudAndLon: UILabel!
    @IBOutlet weak var sliderSelector: UISlider!
    @IBOutlet weak var latLabel: UILabel!
    @IBOutlet weak var lenLabel: UILabel!
    private var apiModel: APIModel = APIModel()
    var manager: CLLocationManager?
    var kilometros = 0
    static var lat = 0.0
    static var long = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sliderSelector.minimumValue = 0
        sliderSelector.maximumValue = 500
        sliderSelector.value = 0
        numberSelect.text = String(Int(sliderSelector.value))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        manager = CLLocationManager()
        manager?.delegate = self
        manager?.desiredAccuracy = kCLLocationAccuracyBest
        manager?.requestWhenInUseAuthorization()
        manager?.startUpdatingLocation()
    }
    
    
    @IBAction func selectSlider(_ sender: UISlider) {
        let intValue = Int(sender.value.rounded())
        sender.value = Float(intValue)
        numberSelect.text = String(intValue)
        kilometros = intValue
    }
    
    
    @IBAction func searchAction(_ sender: Any) {
// Datos correctos
        print("Lad \(SearchViewController.lat)")
        print("Long \(SearchViewController.long)")
        let aviationService = APIModel()
        aviationService.searchAirports(latitude: SearchViewController.lat, longitude: SearchViewController.long, radius: kilometros)
        { result in
            switch result {
              case .success(let airports):
                  if airports.isEmpty {
                      // Mostrar alerta si no hay información
                      DispatchQueue.main.async {
                          self.showNoResultsAlert()
                      }
                  } else {
                      // Guarda los aeropuertos y navega a la vista de la lista
                      DispatchQueue.main.async {
                          AirportDataManager.shared.airports = airports
                          self.navigateToAirportTable()
                          print("😄 \(AirportDataManager.shared.airports)")
                      }
                  }
              case .failure(let error):
                  print("Error: \(error.localizedDescription)")
                  DispatchQueue.main.async {
                      self.showNoResultsAlert()
                  }
              }
        }
    }
    
    
    func navigateToAirportTable() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ListAirportViewController") as! ListAirportViewController
          present(vc, animated: true, completion: nil)
    }
    
    func showNoResultsAlert() {
            let alert = UIAlertController(title: "No Results", message: "No airports found within the specified radius. Please try a different radius.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
}

extension SearchViewController : CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let first = locations.first else {
            return
        }
        latLabel.text = "  Latitude: \(first.coordinate.latitude) "
        SearchViewController.lat = first.coordinate.latitude
        lenLabel.text = "  Longitude: \(first.coordinate.longitude) "
        SearchViewController.long = first.coordinate.longitude
    }
}
