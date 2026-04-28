import NetworkExtension
// Импортируем наш скомпилированный Go-модуль.
// Название GoCore будет соответствовать названию модуля в .xcframework
import GoCore

class PacketTunnelProvider: NEPacketTunnelProvider {

    override func startTunnel(options: [String : NSObject]?, completionHandler: @escaping (Error?) -> Void) {
        // Настраиваем туннель. Мы будем обрабатывать сырые IP-пакеты.
        let tunnelNetworkSettings = NEPacketTunnelNetworkSettings(tunnelRemoteAddress: "8.8.8.8") // Адрес может быть любым, он не используется.
        
        // Указываем, что мы будем перехватывать весь IPv4-трафик
        let ipv4Settings = NEIPv4Settings(addresses: ["192.168.100.1"], subnetMasks: ["255.255.255.0"])
        ipv4Settings.includedRoutes = [NEIPv4Route.default()]
        tunnelNetworkSettings.ipv4Settings = ipv4Settings
        
        // Устанавливаем настройки туннеля
        setTunnelNetworkSettings(tunnelNetworkSettings) { error in
            if let error = error {
                completionHandler(error)
                return
            }
            completionHandler(nil)
            // Начинаем читать пакеты после успешной установки настроек
            self.readPackets()
        }
    }
    
    override func stopTunnel(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        completionHandler()
    }
    
    // Функция для чтения пакетов из системы
    private func readPackets() {
        packetFlow.readPackets { (packets: [Data], protocols: [NSNumber]) in
            
            var packetsToWrite: [Data] = []
            
            for packetData in packets {
                // Преобразуем Data в [UInt8] и передаем в нашу Go-функцию
                let processedPacketData = GoCoreHandlePacket(packetData)
                
                // Добавляем обработанный пакет в массив для записи
                packetsToWrite.append(processedPacketData)
            }
            
            // Записываем обработанные пакеты обратно в сеть
            self.packetFlow.writePackets(packetsToWrite, withProtocols: protocols)
            
            // Рекурсивно вызываем себя, чтобы продолжать читать пакеты
            self.readPackets()
        }
    }
}
