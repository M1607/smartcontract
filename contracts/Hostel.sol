// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.5.16 <0.9.0;

//Main contract
contract Hostel {

//Variables where smart contract will store payable
//address
address payable tenant;
address payable landlord;

//Public variables where smart contract will store
//integer values
uint public no_of_rooms =0;
uint public no_of_agreement =0;
uint public no_of_rent =0;

//Structure to store details of each Hostel Room
struct Room {
    uint roomid;
    uint agreementid;
    string roomname;
    string roomaddress;
    uint rent_per_month;
    uint securityDeposit;
    uint timestamp;
    bool vacant;
    address payable landlord;
    address payable currentTenant;
}

//Maps Room structure with a uint (named: roomid)
mapping(uint => Room) public Room_by_No;

//Structure for each Rental Agreement and mapped with a
//uint (named: agreementid). This will store details that
//pertain to the room agreement.
struct RoomAgreement {
    uint roomid;
    uint agreementid;
    string Roomname;
    string RoomAddress;
    uint rent_per_month;
    uint securityDeposit;
    uint lockInPeriod;
    uint timestamp;
    address payable tenantAddress;
    address payable landlordAddress;
}

//Maps RoomAgreement strucutre with unit (named: agreementid)
mapping (uint => RoomAgreement) public RoomAgreement_by_No;

//Structure for Rent payments
struct Rent {
    uint rentno;
    uint roomid;
    uint agreementid;
    string Roomname;
    string RoomAddress;
    uint rent_per_month;
    uint timestamp;
    address payable tenantAddress;
    address payable landlordAddress;
}

//Map Rent strucutre with uint
mapping(uint => Rent) public Rent_by_No;

//Modifiers that help verify items before running a function
//Checks if the message sender is a lanlord
modifier onlyLandLord(uint _index) {
    require(msg.sender == Room_by_No[_index].landlord, "Only landlord can access this");
    _;
}
//Checks if message sender is anyone but the landlord
modifier notLandLord (uint _index) {
    require(msg.sender != Room_by_No[_index].landlord, "Only Tenant can access this");
    _;
}
//Checks if the room is vacant
modifier OnlyWhileVacant(uint _index) {
    require(Room_by_No[_index].vacant == true, "Room is currently occupied.");
    _;
}
//Checks if tenant has enough Ether to pay rent
modifier enoughRent(uint _index) {
    require(msg.value >= uint(Room_by_No[_index].rent_per_month), "Not enough Ether in your wallet");
    _;
}
//Checks if the tenant has enough Ether to pay
//one-time security depsoity and one month's rent in
//rent in advance
modifier enoughAgreementfee(uint _index) {
    require(msg.value >= uint(uint(Room_by_No[_index].rent_per_month) +
    uint(Room_by_No[_index].securityDeposit)), "Not enough Ether in your wallet");
    _;
}   
//Checks if tenant's address is same as one who signed
//the rental agreement
modifier sameTenant(uint _index) {
    require(msg.sender == Room_by_No[_index].currentTenant, "No previous agreement found with you & landlord");
    _;
}
//Checks if there time left for agreement to end
modifier AgreementTimesLeft(uint _index) {
    uint _AgreementNo = Room_by_No[_index].agreementid;
    uint time = RoomAgreement_by_No[_AgreementNo].timestamp +
    RoomAgreement_by_No[_AgreementNo].lockInPeriod;
    require(block.timestamp < time, "Agreement already Ended");
    _;
}
//Checks if 365 days has passed after last agreement was created
modifier AgreementTimesUp(uint _index) {
    uint _AgreementNo = Room_by_No[_index].agreementid;
    uint time = RoomAgreement_by_No[_AgreementNo].timestamp +
    RoomAgreement_by_No[_AgreementNo].lockInPeriod;
    require(block.timestamp > time, "Time is left for contract to end");
    _;
}
//Checks if 30 days has passed since last rental payment
modifier RentTimesUp(uint _index) {
    uint time = Room_by_No[_index].timestamp + 30 days;
    require(block.timestamp >= time, "Time left to pay Rent");
    _;
}

//Function that is used to add rooms
function addRoom(string memory _roomname, string memory _roomaddress,
uint _rentcost, uint _securitydeposit) public {
    require(msg.sender != address(0));
    no_of_rooms ++;
    bool _vacancy = true;
    Room_by_No[no_of_rooms] = Room(no_of_rooms,0,_roomname,_roomaddress,_rentcost,_securitydeposit,0,_vacancy, payable(msg.sender), payable(address(0)));
}

//Function to sign the rental agreement for hostel room
//between the landlord and tenant
//This function will only execute if the user is Tenant
//This function will only execute if user has enough Ether
function signAgreement(uint _index) public payable notLandLord(_index) enoughAgreementfee(_index) OnlyWhileVacant(_index) {
    require(msg.sender != address(0), "Invalid Address");
    address payable _landlord = Room_by_No[_index].landlord;
    uint totalfee = Room_by_No[_index].rent_per_month + Room_by_No[_index].securityDeposit;
    _landlord.transfer(totalfee);
    no_of_agreement++;
    Room_by_No[_index].currentTenant = payable(msg.sender);
    Room_by_No[_index].vacant = false;
    Room_by_No[_index].timestamp = block.timestamp;
    Room_by_No[_index].agreementid = no_of_agreement;

RoomAgreement_by_No[no_of_agreement]=RoomAgreement(_index,no_of_agreement,Room_by_No[_index].roomname,Room_by_No[_index].roomaddress,Room_by_No[_index].rent_per_month,Room_by_No[_index].securityDeposit,365
days,block.timestamp,payable(msg.sender),_landlord);
    no_of_rent++;
    Rent_by_No[no_of_rent] =
Rent(no_of_rent,_index,no_of_agreement,Room_by_No[_index].roomname,Room_by_No[_index].roomaddress,Room_by_No[_index].rent_per_month,block.timestamp,payable(msg.sender),_landlord);
}

//Function that the tenant will use to pay monthly rent to landlord
//Fucntion will only execute if user's address and previous
//tenant's address are the same
//Function will only execute if tenant paid his/her rent a month ago
//Function will only execute if the user has enough Eth
function payRent(uint _index) public payable sameTenant(_index)
RentTimesUp(_index) enoughRent(_index){
    require(msg.sender != address(0));
    address payable _landlord = Room_by_No[_index].landlord;
    uint _rent = Room_by_No[_index].rent_per_month;
    _landlord.transfer(_rent);
    Room_by_No[_index].currentTenant = payable(msg.sender);
    Room_by_No[_index].vacant = false;
    no_of_rent++;
    Rent_by_No[no_of_rent] =
Rent(no_of_rent,_index,Room_by_No[_index].agreementid,Room_by_No[_index].roomname,Room_by_No[_index].roomaddress,_rent,block.timestamp,payable(msg.sender),Room_by_No[_index].landlord);
}

//Function landlord uses to mark that the agreement completed
//Function will only execute if user's address and landlord's address are the same
//Function will only execute if tenant had signed agreement more than a year ago
function agreementCompleted(uint _index) public payable
onlyLandLord(_index) AgreementTimesUp(_index){
    require(msg.sender != address(0));
    require(Room_by_No[_index].vacant == false, "Room is currently Occupied.");
    Room_by_No[_index].vacant = true;
    address payable _Tenant = Room_by_No[_index].currentTenant;
    uint _securitydeposit = Room_by_No[_index].securityDeposit;
    _Tenant.transfer(_securitydeposit);
}

//Function that landlord uses to terminate an agreement
//Function will only execute if user's address and landlord's addres are the same
//Function will only execute if tenant had sigend agreement less than a year ago
function agreementTerminated(uint _index) public onlyLandLord(_index)
AgreementTimesLeft(_index){
    require(msg.sender != address(0));
    Room_by_No[_index].vacant = true;
}

}

