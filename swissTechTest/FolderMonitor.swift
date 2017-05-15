//
//  FolderMonitor.swift
//  swissTechTest
//
//  Created by Dmitry Suvorov on 13/05/17.
//  Copyright © 2017 ip-suvorov. All rights reserved.
//

import Foundation

open class FolderMonitor {
    
    enum State {
        case on, off
    }
    
    fileprivate let source: DispatchSource
    fileprivate let descriptor: CInt
    fileprivate let qq: DispatchQueue = DispatchQueue.main
    fileprivate var state: State = .off
    
    // создаем мониторинг директории
    public init(url: URL, handler: DispatchWorkItem) {
        state = .off
        descriptor = open((url as NSURL).fileSystemRepresentation, O_EVTONLY)
        source = DispatchSource.makeFileSystemObjectSource(fileDescriptor: descriptor, eventMask: DispatchSource.FileSystemEvent.write, queue: qq) as! DispatchSource
        source.setEventHandler(handler: handler)
        start()
    }
    
    // если выключен, включаем
    open func start() {
        if state == .off {
            state = .on
            source.resume()
        }
    }
    
    //  выключаем, если включен
    open func stop() {
        if state == .on {
            state = .off
            source.suspend()
        }
    }
    
    deinit {
        close(descriptor)
        source.cancel()
    }
}
