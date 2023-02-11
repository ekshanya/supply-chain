pragma solidity 0.4.4;
import "./Track.sol";
contract Reputation
{
    Tracking track = Tracking(0xaE036c65C649172b43ef7156b009c6221B596B8b);
    address admin;
    mapping (address => Supplier) suppliers;
    address[] suppliersByAddress; 
    struct Supplier {
        string name;
        uint phoneNo;
        string cityState;
        string country;
        string goodsType;
        uint reputation;
    }
    function Reputation() {
        admin = msg.sender;
    }
    modifier onlyAdmin() {
        if (msg.sender != admin) throw;
        _;
    }

    function addSupplier(string _name, uint _phoneNo, string _cityState, string _country, string _goodsType) returns (bool success)
    {
    if (bytes(suppliers[msg.sender].name).length == 0 && bytes(_name).length != 0) {
        suppliers[msg.sender].name = _name;
        suppliers[msg.sender].phoneNo = _phoneNo;
        suppliers[msg.sender].cityState = _cityState;
        suppliers[msg.sender].country = _country;
        suppliers[msg.sender].goodsType = _goodsType;
        suppliers [msg. sender] .reputation = track.calculateReputation(msg.sender);
        suppliersByAddress.push(msg.sender);
        return true;
    }
    else {
        return false; 
    }
    }
    function removeSupplier(address _supplier) onlyAdmin returns (bool success) 
    {
        delete suppliers[_supplier];
        for (uint i = 0; i < suppliersByAddress.length; i++) 
        {
            if (suppliersByAddress[i] == _supplier)
             {
                for (uint index = i; index < suppliersByAddress.length- 1; index++) 
                {
                    suppliersByAddress[index] =suppliersByAddress[index + 1];
                }
                delete suppliersByAddress[suppliersByAddress.length-1];
            }
                suppliersByAddress.length--;
        }
    
    return true;
}

    function findSupplier(address _supplier) constant returns (string, uint, string, string, string,uint)
    {
    return (suppliers[_supplier].name,suppliers[_supplier].phoneNo,suppliers[_supplier].cityState,suppliers [_supplier].country,suppliers [_supplier].goodsType,suppliers [_supplier].reputation);
    }
    function allSuppliers() constant returns (address[]) {
        return suppliersByAddress;
    }
    function filterByGoodsType(string _goodsType) constant returns (address[])
     {
        address[] memory filteredGoods = new address [](suppliersByAddress.length);
        for (uint i = 0; i < suppliersByAddress.length; i++) 
        {
            if (sha3(suppliers[suppliersByAddress[i]].goodsType) == sha3(_goodsType))
             {
                filteredGoods[i] = suppliersByAddress[i];
            }
        }
    return filteredGoods;
    }

    function filterByReputation(uint _reputation) constant returns (address[]) {
        address[] memory filteredRep = new address [] (suppliersByAddress. length);
            for (uint i = 0; i < suppliersByAddress.length; i++) 
            {
                if (suppliers[suppliersByAddress[i]].reputation >= _reputation) 
                {
                    filteredRep[i] = suppliersByAddress[i];
                }
            }
        return filteredRep;
    }

    function checkReputation(address _supplier) constant returns(uint) {
        return track.calculateReputation(_supplier);
    }

    function updateReputations() onlyAdmin returns (bool success) {
        for (uint i = 0; i < suppliersByAddress.length; i++) 
        {
            suppliers[suppliersByAddress[i]].reputation = track.calculateReputation(suppliersByAddress[i]);
        }
        return true;
    }

}
