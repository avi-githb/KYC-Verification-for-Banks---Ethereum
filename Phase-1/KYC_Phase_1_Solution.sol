pragma solidity ^0.5.9;

contract kyc {

  
    address admin;
    
    /*
    Struct for a customer
     */
    struct Customer {
        string userName;   //unique
        string data_hash;  //unique
        uint8 upvotes;
        address bank;
    }

    /*
    Struct for a Bank
     */
    struct Bank {
        address ethAddress;   //unique  
        string bankName;
        string regNumber;       //unique   
    }

    /*
    Struct for a KYC Request
     */
    struct KYCRequest {
        string userName;     
        string data_hash;  //unique
        address bank;
    }

    /*
    Mapping a customer's username to the Customer struct
    We also keep an array of all keys of the mapping to be able to loop through them when required.
     */
    mapping(string => Customer) customers;
    string[] customerNames;

    /*
    Mapping a bank's address to the Bank Struct
    We also keep an array of all keys of the mapping to be able to loop through them when required.
     */
    mapping(address => Bank) banks;
    address[] bankAddresses;

    /*
    Mapping a customer's Data Hash to KYC request captured for that customer.
    This mapping is used to keep track of every kycRequest initiated for every customer by a bank.
     */
    mapping(string => KYCRequest) kycRequests;
    string[] customerDataList;

    /*
    Mapping a customer's user name with a bank's address
    This mapping is used to keep track of every upvote given by a bank to a customer
     */
    mapping(string => mapping(address => uint256)) upvotes;

    /**
     * Constructor of the contract.
     * We save the contract's admin as the account which deployed this contract.
     */
    constructor() public {
        admin = msg.sender;
    }

    /**
     * Record a new KYC request on behalf of a customer
     * The sender of message call is the bank itself
     * @param  {string} _userName The name of the customer for whom KYC is to be done
     * @param  {address} _bankEthAddress The ethAddress of the bank issuing this request
     * @return {bool}        True if this function execution was successful
     */
    function addKycRequest(string memory _userName, string memory _customerData) public returns (uint8) {
        // Check that the user's KYC has not been done before, the Bank is a valid bank and it is allowed to perform KYC.
        require(kycRequests[_customerData].bank == address(0), "This user already has a KYC request with same data in process.");
        //bytes memory uname = new bytes(bytes(_userName));
        // Save the timestamp for this KYC request.
        kycRequests[_customerData].data_hash = _customerData;
        kycRequests[_customerData].userName = _userName;
        kycRequests[_customerData].bank = msg.sender;
        customerDataList.push(_customerData);
        return 1;
    }

    /**
     * Add a new customer
     * @param {string} _userName Name of the customer to be added
     * @param {string} _hash Hash of the customer's ID submitted for KYC
     */
    function addCustomer(string memory _userName, string memory _customerData) public returns (uint8) {
        require(customers[_userName].bank == address(0), "This customer is already present, please call modifyCustomer to edit the customer data");
        customers[_userName].userName = _userName;
        customers[_userName].data_hash = _customerData;
        customers[_userName].bank = msg.sender;
        customers[_userName].upvotes = 0;
        customerNames.push(_userName);
        return 1;
    }

    /**
     * Remove KYC request
     * @param  {string} _userName Name of the customer
     * @return {uint8}         A 0 indicates failure, 1 indicates success
     */
    function removeKYCRequest(string memory _userName) public returns (uint8) {
        uint8 i=0;
        for (uint256 i = 0; i< customerDataList.length; i++) {
            if (stringsEquals(kycRequests[customerDataList[i]].userName,_userName)) {
                delete kycRequests[customerDataList[i]];
                for(uint j = i+1;j < customerDataList.length;j++) 
                { 
                    customerDataList[j-1] = customerDataList[j];
                }
                customerDataList.length --;
                i=1;
            }
        }
        return i; // 0 is returned if no request with the input username is found.
    }

    /**
     * Remove customer information
     * @param  {string} _userName Name of the customer
     * @return {uint8}         A 0 indicates failure, 1 indicates success
     */
    function removeCustomer(string memory _userName) public returns (uint8) {
            for(uint i = 0;i < customerNames.length;i++) 
            { 
                if(stringsEquals(customerNames[i],_userName))
                {
                    delete customers[_userName];
                    for(uint j = i+1;j < customerNames.length;j++) 
                    {
                        customerNames[j-1] = customerNames[j];
                    }
                    customerNames.length--;
                    return 1;
                }
                
            }
            return 0;
    }

    /**
     * Edit customer information
     * @param  {public} _userName Name of the customer
     * @param  {public} _hash New hash of the updated ID provided by the customer
     * @return {uint8}         A 0 indicates failure, 1 indicates success
     */
    function modifyCustomer(string memory _userName, string memory _newcustomerData) public returns (uint8) {
        for(uint i = 0;i < customerNames.length;i++) 
            { 
                if(stringsEquals(customerNames[i],_userName))
                {
                    customers[_userName].data_hash = _newcustomerData;
                    return 1;
                }
            
            }
            return 0;
    }

    /**
     * View customer information
     * @param  {public} _userName Name of the customer
     * @return {Customer}         The customer struct as an object
     */
    function viewCustomer(string memory _userName) public view returns (string memory, string memory, uint8, address) {
        return (customers[_userName].userName, customers[_userName].data_hash, customers[_userName].upvotes, customers[_userName].bank);
    }

    /**
     * Add a new upvote from a bank
     * @param {public} _userName Name of the customer to be upvoted
     */
    function Upvote(string memory _userName) public returns (uint8) {
        for(uint i = 0;i < customerNames.length;i++) 
            { 
                if(stringsEquals(customerNames[i],_userName))
                {
                    customers[_userName].upvotes++;
                    upvotes[_userName][msg.sender] = now;//storing the timestamp when vote was casted, not required though, additional
                    return 1;
                }
            
            }
            return 0;
        
    }

// if you are using string, you can use the following function to compare two strings
// function to compare two string value
// This is an internal fucntion to compare string values
// @Params - String a and String b are passed as Parameters
// @return - This function returns true if strings are matched and false if the strings are not matching
    function stringsEquals(string storage _a, string memory _b) internal view returns (bool) {
        bytes storage a = bytes(_a);
        bytes memory b = bytes(_b); 
        if (a.length != b.length)
            return false;
        // @todo unroll this loop
        for (uint i = 0; i < a.length; i ++)
        {
            if (a[i] != b[i])
                return false;
        }
        return true;
    }

}
