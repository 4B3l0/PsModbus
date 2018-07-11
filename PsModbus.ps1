function Send-ModbusRequest {
    Param ([String] $address, [int] $port, [int] $cmd)

    $tcpConnection = New-Object System.Net.Sockets.TcpClient($address, $port)
    $tcpStream = $tcpConnection.GetStream()
    $reader = New-Object System.IO.StreamReader($tcpStream)
    $writer = New-Object System.IO.StreamWriter($tcpStream)
    $writer.AutoFlush = $true

    

    $reader.Close()
    $writer.Close()
    $tcpConnection.Close()
}