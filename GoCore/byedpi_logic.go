package GoCore

import (
	"bytes"
	"github.com/google/gopacket"
	"github.com/google/gopacket/layers"
)

// HandlePacket принимает сырой пакет, применяет логику ByeByeDPI и возвращает
// один или несколько пакетов для отправки.
// gomobile bind не поддерживает слайсы слайсов [][]byte, поэтому мы вернем один
// большой слайс, где пакеты разделены специальным маркером.
// Проще для начала вернуть только один пакет.
func HandlePacket(packetData []byte) []byte {
	packet := gopacket.NewPacket(packetData, layers.LayerTypeIPv4, gopacket.Default)

	// Ищем TCP слой
	if tcpLayer := packet.Layer(layers.LayerTypeTCP); tcpLayer != nil {
		tcp, _ := tcpLayer.(*layers.TCP)

		// Проверяем, что это пакет на порт 80 (HTTP)
		if tcp.DstPort == 80 {
			appLayer := packet.ApplicationLayer()
			if appLayer != nil {
				payload := appLayer.Payload()

				// Это очень упрощенная логика для примера.
				// Ищем заголовок "Host:" и меняем его на "hOSt:"
				if bytes.Contains(payload, []byte("Host:")) {
					newPayload := bytes.Replace(payload, []byte("Host:"), []byte("hOSt:"), 1)

					// Теперь нужно пересобрать пакет с новым payload.
					// Это требует пересчета контрольных сумм TCP/IP.
					// gopacket.SerializeLayers это делает автоматически.
					ipLayer := packet.Layer(layers.LayerTypeIPv4).(*layers.IPv4)

					// Настраиваем опции для сериализации
					opts := gopacket.SerializeOptions{
						FixLengths:       true,
						ComputeChecksums: true,
					}
					
					// Создаем буфер для нового пакета
					newPacketBuffer := gopacket.NewSerializeBuffer()

					// Сериализуем слои в новый пакет
					err := gopacket.SerializeLayers(newPacketBuffer, opts,
						ipLayer,
						tcp,
						gopacket.Payload(newPayload),
					)
					if err == nil {
						// Если все успешно, возвращаем байты нового пакета
						return newPacketBuffer.Bytes()
					}
				}
			}
		}
	}

	// Если пакет не был изменен, возвращаем его как есть.
	return packetData
}
