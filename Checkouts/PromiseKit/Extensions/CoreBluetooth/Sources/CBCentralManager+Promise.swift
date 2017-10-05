import CoreBluetooth
import Foundation
#if !COCOAPODS
import PromiseKit
#endif


private class CentralManager: CBCentralManager, CBCentralManagerDelegate {
  var retainCycle: CentralManager!
  let (promise, fulfill, _) = Promise<CBCentralManager>.pending()

  @objc fileprivate func centralManagerDidUpdateState(_ manager: CBCentralManager) {
    if manager.state != .unknown {
      fulfill(manager)
    }
  }
}

extension CBCentralManager {
  /// A promise that fulfills when the state of CoreBluetooth changes
  public class func state() -> Promise<CBCentralManager> {
    let manager = CentralManager(delegate: nil, queue: nil, options: [CBCentralManagerOptionShowPowerAlertKey: false])
    manager.delegate = manager
    manager.retainCycle = manager
    _ = manager.promise.always {
      manager.retainCycle = nil
    }
    return manager.promise
  }
}
