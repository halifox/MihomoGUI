import Foundation
import Darwin

// Owns timeout and escalation timers for a single launched process.
public final class ProcessDeadline {
    private let lock = NSLock()
    private let process: Process
    private let group: pid_t?
    private let timer = DispatchSource.makeTimerSource(queue: .global(qos: .utility))
    private var escalation: DispatchWorkItem?
    private var expired = false
    private var invalidated = false

    public init(process: Process, timeout: TimeInterval, terminationGrace: TimeInterval = 5, expiresAt: DispatchTime? = nil) {
        self.process = process
        let pid = process.processIdentifier
        group = getpgid(pid) == pid ? pid : nil
        let localDeadline = DispatchTime.now() + timeout
        timer.schedule(deadline: expiresAt.map { min($0, localDeadline) } ?? localDeadline)
        timer.setEventHandler { [weak self] in
            guard let self else { return }
            self.lock.lock()
            defer { self.lock.unlock() }
            guard !self.invalidated, self.process.isRunning || self.group.map({ kill(-$0, 0) == 0 }) == true else { return }
            self.expired = true
            if let group = self.group { kill(-group, SIGTERM) } else { self.process.terminate() }
            let escalation = DispatchWorkItem { [weak self] in
                guard let self else { return }
                self.lock.lock()
                defer { self.lock.unlock() }
                guard !self.invalidated else { return }
                if let group = self.group { kill(-group, SIGKILL) }
                else if self.process.isRunning { kill(self.process.processIdentifier, SIGKILL) }
            }
            self.escalation = escalation
            DispatchQueue.global(qos: .utility).asyncAfter(deadline: .now() + terminationGrace, execute: escalation)
        }
        timer.resume()
    }

    public func invalidate() {
        lock.lock()
        if expired, let group { kill(-group, SIGKILL) }
        invalidated = true
        timer.cancel()
        escalation?.cancel()
        escalation = nil
        lock.unlock()
    }

    public func check() throws {
        lock.lock()
        let timedOut = expired
        lock.unlock()
        if timedOut { throw MihomoGUIError("子进程操作超时，已请求终止；有副作用的操作结果可能未知，请检查服务状态后重试") }
    }

    deinit { invalidate() }
}
