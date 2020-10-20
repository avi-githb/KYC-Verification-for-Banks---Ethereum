pragma solidity ^0.5.9;

contract KYCContract {
    address admin;

    /*
    Struct for a customer
     */
    struct Customer {
        string userName; //unique
        string data_hash; //unique
        uint256 rating;
        uint8 upvotes;
        address bank;
    }

    /*
    Struct for a Bank
     */
    struct Bank {
        string bankName;
        address ethAddress; //unique
        uint256 rating;
        uint8 kyc_count;
        string regNumber; //unique
    }

    /*
    Struct for a KYC Request
     */
    struct KYCRequest {
        string userName;
        string data_hash; //unique
        address bank;
        bool isAllowed;
    }

    /*
    Mapping a customer's username to the Customer struct
    We also keep an array of all keys of the mapping to be able to loop through them when required.
     */
    mapping(string => Customer) customers;
    string[] customerNames;

    /*
    Final customer list, mapping of customer's username to the customer Struct
    */
    mapping(string => Customer) final_customers;
    string[] final_customerNames;

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
    function addKycRequest(string memory _userName, string memory _customerData)
        public
        returns (uint8)
    {
        // Check that the user's KYC has not been done before, the Bank is a valid bank and it is allowed to perform KYC.

        //checking if the bank is a vaid Bank

        for (uint256 i = 0; i < bankAddresses.length; i++) {
            if (msg.sender == bankAddresses[i]) {
                //checking if the customer KYC request alreay exist
                require(
                    !(kycRequests[_customerData].bank == msg.sender),
                    "This user already has a KYC request with same data in process."
                );
                kycRequests[_customerData].data_hash = _customerData;
                kycRequests[_customerData].userName = _userName;
                kycRequests[_customerData].bank = msg.sender;

                //incrementing the kyc_count for the bank
                banks[msg.sender].kyc_count++;

                //checking if the BANK is a trusted bank to add KYC requests
                if (banks[msg.sender].rating <= 50) {
                    kycRequests[_customerData].isAllowed = false;
                } else {
                    kycRequests[_customerData].isAllowed = true;
                }
                customerDataList.push(_customerData);
                return 1;
            }
        }
        return 0; // 0 is returned in case of failure
    }

    /**
     * Add a new customer
     * @param {string} _userName Name of the customer to be added
     * @param {string} _hash Hash of the customer's ID submitted for KYC
     */
    function addCustomer(string memory _userName, string memory _customerData)
        public
        returns (uint8)
    {
        //checking if the bank is a vaid Bank
        for (uint256 i = 0; i < bankAddresses.length; i++) {
            if (msg.sender == bankAddresses[i]) {
                for (uint256 k = 0; k < customerDataList.length; k++) {
                    if (stringsEquals(customerDataList[k], _customerData)) {
                        require(
                            customers[_userName].bank == address(0),
                            "This customer is already present, modifyCustomer to edit the customer data"
                        );
                        require(
                            kycRequests[_customerData].isAllowed == true,
                            "isAllowed is false, bank is not trusted to perfrom the transaction"
                        );
                        customers[_userName].userName = _userName;
                        customers[_userName].data_hash = _customerData;
                        customers[_userName].bank = msg.sender;
                        customers[_userName].upvotes = 0;
                        customerNames.push(_userName);
                        return 1;
                    }
                }
            }
        }
        return 0; // 0 is returned in case of failure
    }

    /**
     * Remove KYC request
     * @param  {string} _userName Name of the customer
     * @return {uint8}         A 0 indicates failure, 1 indicates success
     */
    function removeKYCRequest(
        string memory _userName,
        string memory customerData
    ) public returns (uint8) {
        uint8 i = 0;
        //checking if the provided username and customer Data are mapped in kycRequests
        require(
            (stringsEquals(kycRequests[customerData].userName, _userName)),
            "Please enter valid UserName and Customer Data Hash"
        );

        //looping through customerDataList and then deleting the kycRequests and deleting the customer data hash from customerDataList array
        for (i = 0; i < customerDataList.length; i++) {
            if (stringsEquals(customerDataList[i], customerData)) {
                delete kycRequests[customerData];
                for (uint256 j = i + 1; j < customerDataList.length; j++) {
                    customerDataList[j - 1] = customerDataList[j];
                }
                customerDataList.length--;
                return 1;
            }
        }
        return 0; // 0 is returned if no request with the input username is found.
    }

    /**
     * Remove customer information
     * @param  {string} _userName Name of the customer
     * @return {uint8}         A 0 indicates failure, 1 indicates success
     */
    function removeCustomer(string memory _userName) public returns (uint8) {
        for (uint256 i = 0; i < customerNames.length; i++) {
            if (stringsEquals(customerNames[i], _userName)) {
                delete customers[_userName];
                for (uint256 j = i + 1; j < customerNames.length; j++) {
                    customerNames[j - 1] = customerNames[j];
                }
                customerNames.length--;
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
    function viewCustomer(string memory _userName, string memory password)
        public
        view
        returns (string memory)
    {
        //looping through customerNames to check if the _userName passes is valid
        for (uint256 i = 0; i < customerNames.length; i++) {
            if (stringsEquals(customerNames[i], _userName)) {
                //looping through passwordSet array, which is an string[] stores USERNAME's of user whose password is set
                //if password is set no changes are made to password, if not set then password is assigned a default value = '0'
                for (uint256 k = 0; k < passwordSet.length; k++) {
                    if (stringsEquals(passwordSet[k], _userName)) {
                        //no changes required
                        continue;
                    } else {
                        password = "0";
                    }
                }
            }
        }
        //passwordStore is a mapping of username=>password, if given username and password match we return customer data hash
        //else error is thrown informing user that password provided didn't match

        if (stringsEquals(passwordStore[_userName], password)) {
            return customers[_userName].data_hash;
        } else {
            return "password provided by the user didn't match";
        }
    }

    /**
     * Add upvote to provide ratings on customers
     * Add a new upvote from a bank
     * @param {public} _userName Name of the customer to be upvoted
     */
    function upvoteCustomer(string memory _userName) public returns (uint8) {
        for (uint256 i = 0; i < customerNames.length; i++) {
            if (stringsEquals(customerNames[i], _userName)) {
                require(
                    upvotes[_userName][msg.sender] == 0,
                    "This bank have already upvoted this customer"
                );
                upvotes[_userName][msg.sender] = 1; //storing the timestamp when vote was casted, not required though, additional
                customers[_userName].upvotes++;

                //updateing the rating of the customer
                customers[_userName].rating =
                    (customers[_userName].upvotes * 100) /
                    bankAddresses.length;

                if (customers[_userName].rating > 50) {
                    final_customers[_userName].userName = _userName;
                    final_customers[_userName].data_hash = customers[_userName]
                        .data_hash;
                    final_customers[_userName].rating = customers[_userName]
                        .rating;
                    final_customers[_userName].upvotes = customers[_userName]
                        .upvotes;
                    final_customers[_userName].bank = customers[_userName].bank;
                    final_customerNames.push(_userName);
                }

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
    function modifyCustomer(
        string memory _userName,
        string memory password,
        string memory _newcustomerData
    ) public returns (uint8) {
        for (uint256 i = 0; i < customerNames.length; i++) {
            if (stringsEquals(customerNames[i], _userName)) {
                for (uint256 k = 0; k < passwordSet.length; k++) {
                    if (stringsEquals(passwordSet[k], _userName)) {
                        continue;
                    } else {
                        password = "0";
                    }
                }

                if (stringsEquals(passwordStore[_userName], password)) {
                    customers[_userName].data_hash = _newcustomerData;
                    customers[_userName].bank = msg.sender;
                    for (uint8 j = 0; i < final_customerNames.length; j++) {
                        if (stringsEquals(final_customerNames[i], _userName)) {
                            delete final_customers[_userName];
                            customers[_userName].rating = 0;
                            customers[_userName].upvotes = 0;

                            for (
                                uint256 k = i + 1;
                                j < final_customerNames.length;
                                k++
                            ) {
                                final_customerNames[j -
                                    1] = final_customerNames[j];
                            }
                            final_customerNames.length--;
                        }
                    }
                    return 1;
                }
            }
        }
        return 0;
    }

    /*
get bank requests

Parameters : Unique bankAddress and Index which will rertun 1 of the yet to be validated requests.
Returns : Will rertun KYC_UnValidated[index]
*/
    //Array to count number of invalidated KYC requests and store its customer data hash.
    string[] KYC_UnValidatedCount;

    function getBankRequset(address bankAddress, uint256 index)
        public
        returns (
            string memory,
            string memory,
            address,
            bool
        )
    {
        //looping through bankAddresses array to check if the passed bankAddress is valid

        for (uint256 i = 0; i < bankAddresses.length; i++) {
            if (bankAddresses[i] == bankAddress) {
                //looping through customerDataList to find all the KYC requests initiated by the bank whose address is passed
                for (uint256 k = 0; k < customerDataList.length; k++) {
                    //kycRequests whose isAllowed value is False and bankAddress==bankAddress passed as Parameter
                    //store it in KYC_UnValidatedCount array.

                    if (
                        (kycRequests[customerDataList[k]].bank ==
                            bankAddress) &&
                        (kycRequests[customerDataList[k]].isAllowed == false)
                    ) {
                        KYC_UnValidatedCount.push(customerDataList[k]);
                    }
                }
            }
        }
        return (
            kycRequests[KYC_UnValidatedCount[index]].userName,
            kycRequests[KYC_UnValidatedCount[index]].data_hash,
            kycRequests[KYC_UnValidatedCount[index]].bank,
            kycRequests[KYC_UnValidatedCount[index]].isAllowed
        );
    }

    /*
Upvotes to provide rating on other banks
*/
    mapping(address => mapping(address => uint256)) upvotesBank;
    mapping(address => uint256) upvoteCount;

    function upvoteBank(address bankAddress) public returns (uint8) {
        for (uint256 i = 0; i < bankAddresses.length; i++) {
            if (msg.sender == bankAddresses[i]) {
                require(
                    upvotesBank[bankAddress][msg.sender] == 0,
                    "You have already upvoted this bank"
                );
                upvotesBank[bankAddress][msg.sender] = 1;
                upvoteCount[bankAddress]++;
                banks[bankAddress].rating =
                    (upvoteCount[bankAddress] * 100) /
                    bankAddresses.length;

                return 0;
            }
        }
        return 1;
    }

    /*
Get customer rating
*/

    function getCustomerRating(string memory userName)
        public
        view
        returns (uint256)
    {
        for (uint256 i = 0; i < customerNames.length; i++) {
            if (stringsEquals(customerNames[i], userName))
                return customers[userName].rating;
        }
    }

    /*
Get bank Rating
*/
    function getBankRating(address bankAddress) public view returns (uint256) {
        for (uint256 i = 0; i < bankAddresses.length; i++) {
            if (bankAddresses[i] == bankAddress) {
                return banks[bankAddress].rating;
            }
        }
    }

    /*
Retrieve access history for a resource
*/
    function retrieveHistory(string memory userName)
        public
        view
        returns (address)
    {
        for (uint256 i = 0; i < customerNames.length; i++) {
            if (stringsEquals(customerNames[i], userName)) {
                return customers[userName].bank;
            }
        }
    }

    /*
Set password
*/
    //mapping of username to passwordStore
    mapping(string => string) public passwordStore;
    string[] public passwordSet;

    function setPassword(string memory userName, string memory password)
        public
        returns (bool)
    {
        for (uint256 i = 0; i < customerNames.length; i++) {
            if (stringsEquals(customerNames[i], userName)) {
                passwordStore[userName] = password;
                passwordSet.push(userName);
                return true;
            }
        }
    }

    /*
Get Bank Details
*/
    function getBankDetail(address bankAddress)
        public
        view
        returns (
            string memory,
            address,
            uint256,
            uint8,
            string memory
        )
    {
        for (uint256 i = 0; i < bankAddresses.length; i++) {
            if (bankAddresses[i] == bankAddress) {
                return (
                    banks[bankAddress].bankName,
                    banks[bankAddress].ethAddress,
                    banks[bankAddress].rating,
                    banks[bankAddress].kyc_count,
                    banks[bankAddress].regNumber
                );
            }
        }
    }

    //add bank (bank can only be added by the admin (admin = person who is deploying
    //smart contract)
    //mapping to store bankRegistration => bank address
    mapping(string => address) bankRegStore;

    function addBank(
        string memory bankName,
        address bankAddress,
        string memory bankRegistration
    ) public returns (string memory) {
        require(msg.sender == admin, "You are not an admin");
        require(
            banks[bankAddress].ethAddress == address(0),
            "This bank is already added to the samrt contract"
        );

        require(
            bankRegStore[bankRegistration] == address(0),
            "This Registration number is already assocaited with another bank"
        );
        banks[bankAddress].bankName = bankName;
        banks[bankAddress].ethAddress = bankAddress;
        banks[bankAddress].rating = 0;
        banks[bankAddress].kyc_count = 0;
        banks[bankAddress].regNumber = bankRegistration;

        bankAddresses.push(bankAddress);
        bankRegStore[bankRegistration] = bankAddress;
        return "successful entry of bank to the contract";
    }

    //remove bank
    function removeBank(address bankAddress) public returns (string memory) {
        require(msg.sender == admin, "You are not an admin");
        for (uint256 i = 0; i < bankAddresses.length; i++) {
            if (bankAddresses[i] == bankAddress) {
                delete banks[bankAddress];

                for (uint256 j = i + 1; j < bankAddresses.length; j++) {
                    bankAddresses[j - 1] = bankAddresses[j];
                }
                bankAddresses.length--;
                return "successful removal of the bank from the contract.";
            }
        }

        return "The bank is already removed from the contract";
    }

    // if you are using string, you can use the following function to compare two strings
    // function to compare two string value
    // This is an internal fucntion to compare string values
    // @Params - String a and String b are passed as Parameters
    // @return - This function returns true if strings are matched and false if the strings are not matching
    function stringsEquals(string storage _a, string memory _b)
        internal
        view
        returns (bool)
    {
        bytes storage a = bytes(_a);
        bytes memory b = bytes(_b);
        if (a.length != b.length) return false;
        // @todo unroll this loop
        for (uint256 i = 0; i < a.length; i++) {
            if (a[i] != b[i]) return false;
        }
        return true;
    }
}
