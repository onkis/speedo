//
//  LocationSpeedProvider.swift
//  speedo
//
//  Thin Core Location wrapper that publishes the device's current ground speed.
//

import CoreLocation
import Observation

@Observable
final class LocationSpeedProvider: NSObject, CLLocationManagerDelegate {

    /// Latest GPS speed in meters/second. `nil` until the first fix arrives;
    /// `CLLocation` reports a negative value when speed is unavailable.
    var speedMetersPerSecond: Double?

    @ObservationIgnored private let manager = CLLocationManager()

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        manager.activityType = .automotiveNavigation
    }

    /// Requests permission; updates begin once authorization is granted.
    func start() {
        manager.requestWhenInUseAuthorization()
    }

    /// Test seam: drive the published value without a live GPS.
    func update(speed: Double?) {
        speedMetersPerSecond = speed
    }

    // MARK: - CLLocationManagerDelegate

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.startUpdatingLocation()
        default:
            manager.stopUpdatingLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        speedMetersPerSecond = locations.last?.speed
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Transient failures (e.g. no fix yet) are expected; keep the last value.
    }
}
