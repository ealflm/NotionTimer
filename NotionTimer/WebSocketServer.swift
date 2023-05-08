//
//  WebSocketServer.swift
//  NotionTimer
//
//  Created by Đào Phương Nam on 08/05/2023.
//

import NIOCore
import NIOPosix
import NIOHTTP1
import NIOWebSocket

protocol WebSocketServerDelegate: AnyObject {
    func didReceiveMessage(_ message: String)
}

private final class WebSocketHandler: ChannelInboundHandler {
    weak var delegate: WebSocketServerDelegate?
    
    typealias InboundIn = WebSocketFrame
    typealias OutboundOut = WebSocketFrame

    static var connectedClients = [ObjectIdentifier: Channel]()
    
    init(delegate: WebSocketServerDelegate?) {
        self.delegate = delegate
    }

    func handlerAdded(context: ChannelHandlerContext) {
        let id = ObjectIdentifier(context.channel)
        WebSocketHandler.connectedClients[id] = context.channel
        print("Client connected: \(id)")
    }

    func handlerRemoved(context: ChannelHandlerContext) {
        let id = ObjectIdentifier(context.channel)
        WebSocketHandler.connectedClients.removeValue(forKey: id)
        print("Client disconnected: \(id)")
    }

    public func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        let frame = self.unwrapInboundIn(data)
        var data = frame.unmaskedData
        let text = data.readString(length: data.readableBytes) ?? ""
        print("Received message: \(text)")
        delegate?.didReceiveMessage(text)
    }

    func broadcastMessage(_ message: String, server: WebSocketServer) {
        server.broadcastMessage(message)
    }

    public func channelReadComplete(context: ChannelHandlerContext) {
        context.flush()
    }
}


class WebSocketServer {
    var group: MultiThreadedEventLoopGroup?
    
    func broadcastMessage(_ message: String) {
        let frame = WebSocketFrame(fin: true, opcode: .text, data: ByteBuffer(string: message))
        for (_, channel) in WebSocketHandler.connectedClients {
            channel.writeAndFlush(frame, promise: nil)
        }
    }

    func startServer(host: String = "127.0.0.1", port: Int = 8080, delegate: WebSocketServerDelegate? = nil, completion: @escaping (Result<String, Error>) -> Void) {
        group = MultiThreadedEventLoopGroup(numberOfThreads: 1)

        let upgrader = NIOWebSocketServerUpgrader(shouldUpgrade: { (channel: Channel, head: HTTPRequestHead) in channel.eventLoop.makeSucceededFuture(HTTPHeaders()) },
                                                  upgradePipelineHandler: { (channel: Channel, _: HTTPRequestHead) in
                                                    channel.pipeline.addHandler(WebSocketHandler(delegate: delegate))
                                                  })

        let bootstrap = ServerBootstrap(group: group!)
            .serverChannelOption(ChannelOptions.backlog, value: 256)
            .serverChannelOption(ChannelOptions.socketOption(.so_reuseaddr), value: 1)
            .childChannelInitializer { channel in
                let config: NIOHTTPServerUpgradeConfiguration = (
                    upgraders: [upgrader],
                    completionHandler: { _ in }
                )
                return channel.pipeline.configureHTTPServerPipeline(withServerUpgrade: config)
            }
            .childChannelOption(ChannelOptions.socketOption(.so_reuseaddr), value: 1)

        defer {
            try! group?.syncShutdownGracefully()
        }

        enum BindTo {
            case ip(host: String, port: Int)
            case unixDomainSocket(path: String)
        }

        let bindTarget: BindTo = .ip(host: host, port: port)

        do {
            let channel = try { () -> Channel in
                switch bindTarget {
                case .ip(let host, let port):
                    return try bootstrap.bind(host: host, port: port).wait()
                case .unixDomainSocket(let path):
                    return try bootstrap.bind(unixDomainSocketPath: path).wait()
                }
            }()

            guard let localAddress = channel.localAddress else {
                fatalError("Address was unable to bind. Please check that the socket was not closed or that the address family was understood.")
            }
            completion(.success("Server started and listening on \(localAddress)"))

            try channel.closeFuture.wait()

            print("Server closed")
        } catch {
            print("Error starting the server: \(error)")
            completion(.failure(error))
        }
    }
}
