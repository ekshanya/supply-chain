pragma solidity 0.4.4;
contract Tracking {
    address admin;
    uint[] contractLocation; 
    uint contractLeadTime; 
    uint contractPayment; 
    mapping (string => Shipment) shipments;
    mapping (address => uint) balances;
    mapping (address => uint) totalShipped; 
    mapping (address => uint) successShipped; 
    struct Shipment {
        string item;
        uint quantity;
        uint[] locationData;
        uint timeStamp;
        address sender;
    }

    event Success(string _message, string trackingNo, uint[] _locationData, uint _timeStamp, address _sender);
    event Payment(string _message, address _from, address _to,uint _amount); 
    event Failure(string _message);
    function Tracking(uint _initialTokenSupply) {
        admin = msg.sender;
        balances[admin] = _initialTokenSupply; 
    }

    modifier onlyAdmin() {
        if (msg.sender!=admin) throw;
        _;
    }
    function sendToken(address _from, address _to, uint _amount) returns (bool success) {
        if (balances[_from] < _amount) {
            Failure("Insufficient funds to send payment");
            return false;
        }
        balances[_from] -= _amount;
        balances[_to] += _amount;
        Payment("Payment sent", _from, _to, _amount);
        return true;
    }

    function getBalance(address _account) constant returns (uint _balance) {
        return balances[_account];
    }

    function recoverToken(address _from, uint _amount) onlyAdmin returns (bool success) {
        if (balances[_from] < _amount) {
            Failure("Insufficient funds for recovery");
            return false;
        }
        balances[_from] -= _amount;
        balances[msg.sender] += _amount;
        Payment("Funds recovered", _from, msg.sender, _amount);
        return true;
    }
    function setContractParameters(uint[] _location, uint _leadTime, uint _payment) onlyAdmin returns (bool success) {
        contractLocation = _location; 
        contractLeadTime = _leadTime; 
        contractPayment = _payment; 
        return true;
    }
    function sendShipment(string trackingNo, string _item, uint _quantity, uint[] _locationData) returns (bool success) {
        shipments[trackingNo].item = _item;
        shipments[trackingNo].quantity = _quantity;
        shipments[trackingNo].locationData = _locationData;
        shipments[trackingNo].timeStamp = block.timestamp;
        shipments[trackingNo].sender = msg.sender;
        totalShipped[msg.sender] += 1;
        Success('Item shipped', trackingNo, _locationData,
        block.timestamp, msg.sender);
        return true;
    }
    function receiveShipment(string trackingNo, string _item, uint _quantity, uint[] _locationData) returns (bool success) {
        if (sha3(shipments[trackingNo].item) == sha3(_item) && shipments[trackingNo].quantity == _quantity) {
            successShipped[shipments[trackingNo].sender] += 1;
            Success('Item received', trackingNo, _locationData,block.timestamp, msg.sender);
        if (block.timestamp <= shipments[trackingNo].timeStamp+contractLeadTime && _locationData[0] == contractLocation[0] && _locationData[1] == contractLocation[1]) {
            sendToken(admin, shipments[trackingNo].sender, contractPayment);
        }
        else {  
            Failure("Payment not triggered as criteria not met");
        }
        return true;
        }
          else {
            Failure("Error in item/quantity");
            return false;
        }
    }
    function deleteShipment(string trackingNo) onlyAdmin returns (bool success) {
        delete shipments[trackingNo];
return true;
}

function checkShipment(string trackingNo) constant returns (string, uint, uint[], uint, address) {
    return (shipments[trackingNo].item,
    shipments[trackingNo].quantity, shipments[trackingNo].locationData,
    shipments[trackingNo].timeStamp, shipments[trackingNo].sender);
}

function checkSuccess(address _sender) constant returns (uint, uint) {
    return (successShipped[_sender], totalShipped[_sender]);
}
function calculateReputation(address _sender) constant returns (uint) {
    if (totalShipped[_sender]!=0) {
    return (100 * successShipped[_sender]/totalShipped[_sender]);
}
else {
return 0;
}
}
}
