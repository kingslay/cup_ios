//
//  CBCentralManager+Rx.swift
//  RxBluetooth
//
//  Created by Junior B. on 22/09/15.
//  Copyright © 2015 SideEffects. All rights reserved.
//

import Foundation
import CoreBluetooth
import RxSwift
import RxCocoa

/// Proxy Object for CBCentralManagerDelegate
class RxCBCentralManagerDelegateProxy: DelegateProxy, CBCentralManagerDelegate, DelegateProxyType {
    
    class func currentDelegateFor(object: AnyObject) -> AnyObject? {
        let locationManager: CBCentralManager = object as! CBCentralManager
        return locationManager.delegate
    }
    
    class func setCurrentDelegate(delegate: AnyObject?, toObject object: AnyObject) {
        let locationManager: CBCentralManager = object as! CBCentralManager
        locationManager.delegate = delegate as? CBCentralManagerDelegate
    }
    
    internal func centralManagerDidUpdateState(central: CBCentralManager) {
      interceptedSelector("centralManagerDidUpdateState:", withArguments: [central])
    }
}

extension CBCentralManager {
    
    /**
    Reactive wrapper for `delegate`.
    
    For more information take a look at `DelegateProxyType` protocol documentation.
    */
    public var rx_delegate: DelegateProxy {
        return proxyForObject(RxCBCentralManagerDelegateProxy.self,self)
    }
    
    // MARK: Responding to CB Central Manager
    
    /**
    Reactive wrapper for `delegate` message.
    */
    public var rx_didUpdateState: Observable<CBCentralManager> {
        return rx_delegate.observe("centralManagerDidUpdateState:")
            .map { a in
                return a[0] as! CBCentralManager
        }
    }
    
    /**
    Reactive wrapper for `delegate` message.
    */
    public var rx_willRestoreState: Observable<[String : AnyObject]> {
        return rx_delegate.observe("centralManager:willRestoreState:")
            .map { a in
                return a[1] as! [String : AnyObject]
        }
    }
    
    /**
    Reactive wrapper for `delegate` message.
    */
    public var rx_didDiscoverPeripheral: Observable<(CBCentralManager, CBPeripheral, [String : AnyObject], NSNumber)> {
        return rx_delegate.observe("centralManager:didDiscoverPeripheral:advertisementData:RSSI:")
            .map { a in
                return (a[0] as! CBCentralManager, a[1] as! CBPeripheral, a[2] as! [String : AnyObject], a[3] as! NSNumber)
        }
    }
    
    /**
    Reactive wrapper for `delegate` message.
    */
    public var rx_didConnectPeripheral: Observable<CBPeripheral> {
        return rx_delegate.observe("centralManager:didConnectPeripheral:")
            .map { a in
                return a[1] as! CBPeripheral
        }
    }
    
    /**
    Reactive wrapper for `delegate` message.
    */
    public var rx_didFailToConnectPeripheral: Observable<(CBPeripheral, NSError?)> {
        return rx_delegate.observe("centralManager:didFailToConnectPeripheral:error:")
            .map { a in
                return (a[1] as! CBPeripheral, a[2] as? NSError)
        }
    }
    
    /**
    Reactive wrapper for `delegate` message.
    */
    public var rx_didDisconnectPeripheral: Observable<(CBPeripheral, NSError?)> {
        return rx_delegate.observe("centralManager:didDisconnectPeripheral:error:")
            .map { a in
                return (a[1] as! CBPeripheral, a[2] as? NSError)
        }
    }
    
}