pragma solidity ^0.4.4;
contract Provenance {
    address admin;
    mapping (address => Producer) producers;
    mapping (string => Product) products;
    struct Producer {
    string name;
    uint phoneNo;
    string cityState;
    string country;
    bool certified;
}
struct Product {
    address producer;
    uint[] locationData; 
    uint timeStamp;
}

function Provenance() {
    admin = msg.sender;
}

modifier onlyAdmin() {
    if (msg.sender != admin) throw;
    _;
}


function addProducer(string _name, uint _phoneNo, string _cityState, string _country) public returns (bool success) {

    if (bytes(producers[msg.sender].name).length == 0 && bytes(_name).length != 0) {
        producers[msg.sender].name = _name;
        producers[msg.sender].phoneNo = _phoneNo;
        producers[msg.sender].cityState = _cityState;
        producers[msg.sender].country = _country;
        producers[msg.sender].certified = false;
        return true;
    }
    else {
        return false; 
    }
}

function removeProducer(address _producer) onlyAdmin public returns (bool success) {
    delete producers [_producer];
    return true;
}

function findProducer(address _producer) constant returns (string,uint, string, string, bool) {
    return (producers[_producer].name,producers[_producer].phoneNo, producers[_producer].cityState,producers[_producer].country, producers[_producer].certified);
}
function certifyProducer(address _producer) onlyAdmin public returns (bool success) {
    producers [_producer] .certified = true;
    return true;
}

function addProduct(string serialNo, uint[] _locationData) public returns (bool success) {
    if (products[serialNo].producer == 0X0 && bytes(serialNo).length != 0)
    {
        products[serialNo].producer = msg.sender;
        products[serialNo].locationData = _locationData;
        products[serialNo].timeStamp = block.timestamp;
        return true;
    }
    else {
        return false;
    }
}

function removeProduct(string serialNo) onlyAdmin public returns (bool success) {
    delete products [serialNo];
    return true;
}

function findProduct(string serialNo) constant returns (address,uint[], uint) {
    return (products[serialNo].producer,products [serialNo] .locationData, products[serialNo] .timeStamp);
}
}
