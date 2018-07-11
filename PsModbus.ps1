function Send-ModbusRequest {
    Param ([String] $address, [int] $port, [array] $cmd)

    $tcpConnection = New-Object System.Net.Sockets.TcpClient($address, $port)
    $tcpStream = $tcpConnection.GetStream()

    $length = [bitconverter]::GetBytes([convert]::ToInt16($cmd.length + 1))
    [array]::reverse($length)


    $data = 0x00, 0xFF, # Transaction Identifier
        0x00, 0x00 # Protocol Identifier : 0 = Modbus

    $data = $data + $length + 0x00 + $cmd

    [byte[]] $buffer = @(0) * 30

    $tcpStream.Write($data,0,$data.length)
    $tcpStream.Flush()
    $size = $tcpStream.Read($buffer,0,$buffer.length)

    $result = @(0) * $size

    [array]::copy($buffer,$result,$size)

    $tcpConnection.Close()

    return $result
}

function Read-DiscreteInputs {
    Param ([String] $address, [int] $port, [uint16] $offset)

    $reference = [bitconverter]::GetBytes($offset)
    [array]::reverse($reference)

    [byte[]] $cmd = @(0x02)
    $cmd = $cmd + $reference + 0x00 + 0x01

    $response = Send-ModbusRequest $address $port $cmd

    if($response[7] -eq 0x2){
        $response[9]
    }
    else{
        "Error number " + $response[7]
    }
}

function Read-Coil {
    Param ([String] $address, [int] $port, [uint16] $offset)

    $reference = [bitconverter]::GetBytes($offset)
    [array]::reverse($reference)

    [byte[]] $cmd = @(0x01)
    $cmd = $cmd + $reference + 0x00 + 0x01

    $response = Send-ModbusRequest $address $port $cmd

    if($response[7] -eq 0x1){
        $response[9]
    }
    else{
        "Error number " + $response[7]
    }
}

function Write-SingleCoil {
    Param ([String] $address, [int] $port, [uint16] $offset, [bool] $status)

    if($status){
        [byte[]] $value = 0xff, 0x00
    }
    else{
        [byte[]] $value = 0x00, 0x00
    }

    $reference = [bitconverter]::GetBytes($offset)
    [array]::reverse($reference)

    [byte[]] $cmd = @(0x05)
    $cmd = $cmd + $reference + $value + 0x00 + 0x01

    $response = Send-ModbusRequest $address $port $cmd

    if($response[7] -eq 0x5){
        "Done"
    }
    else{
        "Error number " + $response[7]
    }
}