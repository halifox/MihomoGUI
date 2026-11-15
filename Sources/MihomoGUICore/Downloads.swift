import Foundation
import Darwin

// Subscription and GEO downloads share streaming limits, cancellation and temporary-file ownership.
public func downloadLimited(_ request: URLRequest, maximumBytes: Int, directory: URL = FileManager.default.temporaryDirectory) async throws -> (URL, HTTPURLResponse) {
    try Task.checkCancellation()
    guard maximumBytes > 0 else { throw MihomoGUIError("下载大小限制无效") }
    let operation = try LimitedDownload(maximumBytes: maximumBytes, directory: directory)
    let result = try await withTaskCancellationHandler {
        try await withCheckedThrowingContinuation { operation.start(request, continuation: $0) }
    } onCancel: {
        operation.cancel()
    }
    do { try Task.checkCancellation() }
    catch { try? FileManager.default.removeItem(at: result.0); throw error }
    return result
}

// The lock protects every mutable field and all file access, including cancellation callbacks.
private final class LimitedDownload: NSObject, URLSessionDataDelegate, @unchecked Sendable {
    typealias Outcome = Result<(URL, HTTPURLResponse), Error>
    private let lock = NSLock()
    private let maximumBytes: Int
    private let url: URL
    private let file: FileHandle
    private var received = 0
    private var response: HTTPURLResponse?
    private var session: URLSession?
    private var continuation: CheckedContinuation<(URL, HTTPURLResponse), Error>?
    private var outcome: Outcome?

    init(maximumBytes: Int, directory: URL) throws {
        self.maximumBytes = maximumBytes
        url = directory.appendingPathComponent("MihomoGUI-download-" + UUID().uuidString)
        let descriptor = open(url.path, O_WRONLY | O_CREAT | O_EXCL | O_NOFOLLOW, 0o600)
        guard descriptor >= 0 else { throw MihomoGUIError("无法创建下载临时文件") }
        file = FileHandle(fileDescriptor: descriptor, closeOnDealloc: true)
        super.init()
    }

    func start(_ request: URLRequest, continuation: CheckedContinuation<(URL, HTTPURLResponse), Error>) {
        lock.lock()
        if let outcome {
            lock.unlock()
            continuation.resume(with: outcome)
            return
        }
        self.continuation = continuation
        let configuration = URLSessionConfiguration.ephemeral
        configuration.timeoutIntervalForResource = 90
        configuration.urlCache = nil
        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        self.session = session
        let task = session.dataTask(with: request)
        lock.unlock()
        task.resume()
    }

    func cancel() { finish(.failure(CancellationError())) }

    private func finish(_ result: Outcome) {
        lock.lock()
        guard outcome == nil else { lock.unlock(); return }
        var result = result
        do { try file.close() }
        catch { result = .failure(MihomoGUIError("下载临时文件关闭失败")) }
        if case .failure = result { try? FileManager.default.removeItem(at: url) }
        outcome = result
        let pending = continuation
        continuation = nil
        let session = session
        self.session = nil
        lock.unlock()
        session?.invalidateAndCancel()
        pending?.resume(with: result)
    }

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse,
                    completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            completionHandler(.cancel)
            finish(.failure(MihomoGUIError("下载失败（HTTP \((response as? HTTPURLResponse)?.statusCode ?? 0)）")))
            return
        }
        guard response.expectedContentLength <= Int64(maximumBytes) else {
            completionHandler(.cancel)
            finish(.failure(MihomoGUIError("下载超过大小限制（\(maximumBytes) 字节）")))
            return
        }
        lock.lock()
        self.response = http
        let active = outcome == nil
        lock.unlock()
        completionHandler(active ? .allow : .cancel)
    }

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        lock.lock()
        guard outcome == nil else { lock.unlock(); return }
        guard data.count <= maximumBytes - received else {
            lock.unlock()
            finish(.failure(MihomoGUIError("下载超过大小限制（\(maximumBytes) 字节）")))
            return
        }
        do {
            try file.write(contentsOf: data)
            received += data.count
            lock.unlock()
        } catch {
            lock.unlock()
            finish(.failure(MihomoGUIError("下载临时文件写入失败")))
        }
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error {
            finish(.failure(MihomoGUIError("下载网络连接失败（\((error as NSError).code)）")))
            return
        }
        lock.lock()
        let response = response
        let size = received
        lock.unlock()
        guard let response, size > 0 else { finish(.failure(MihomoGUIError("下载内容为空或响应无效"))); return }
        finish(.success((url, response)))
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse,
                    newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
        if task.originalRequest?.url?.scheme == "https", request.url?.scheme != "https" {
            completionHandler(nil)
            finish(.failure(MihomoGUIError("下载不允许从 HTTPS 重定向到非 HTTPS 地址")))
        } else { completionHandler(request) }
    }
}
