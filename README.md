# KYC-Verification-for-Banks---Ethereum
 Decentralized KYC Verification Process for Banks using Ethereum

- Origin of KYC

Know your Customer aka KYC originated as a standard to fight against the laundering of illicit money flowing from terrorism, organized crime and drug trafficking. The main process behind KYC is that government and enterprises need to track the customers for illegal and money laundering activities. Moreover, KYC also enables banks to better understand their customers and their financial dealings. This helps them manage their risks and make better decisions.

- Need for KYC

Taking in from the origin of KYC, we can state that there are four major sectors in banking where KYC is needed:

Customer Admittance: Making anonymous accounts as restricted entry into the banking system. In other words, no anonymous accounts are allowed. Preliminary information such as names, birth dates, addresses, contact numbers is to be collected to provide banking service.

Customer Identification: In the case of suspicious banking transactions through a customer, customer accounts can be tracked and flagged. Further, it can be sent to process under the bank head office for review.

Monitoring of Bank Activities: Suspicious and doubtful activities in any account can be zeroed in by the bank after understanding its customer base using KYC.

Risk Management: Now that bank has all the preliminary information and activity pattern, it can assess the risk and the likelihood of the customer being involved in illegal transactions.


- Solution using Blockchain

The blockchain is an immutable distributed ledger shared with everyone involved in the network. Every participant interacts with the blockchain using a public-private cryptographic key combination. Moreover, immutable record storage is provided, which is very hard to tamper.
Banks can utilize the feature set of Blockchain to reduce the difficulties faced by the traditional KYC process. A distributed ledger can be set up between all the banks, where one bank can upload the KYC of a customer and other banks can vote on the legitimacy of the customer details. KYC for the customers will be immutably stored on the blockchain and will be accessible to all the banks in the Blockchain.



This case study is divided into 3 parts to achieve the solution:
Project Structure:

- Phase 1:
Whenever a new customer enters into the ecosystem,a bank initiates a KYC request for the customer .

Once checked for veracity, the bank uploads the customer's data onto the blockchain using the smart contract.

Whenever any new data is needed to be appended, the ledger could enable encrypted updates to the ledger. Mining will make sure that the data gets confirmed over the Blockchain and distributed to all other banks.

The KYC data can be accessed by other banks in real-time as and when required.

Other Banks can vote on the KYC process done by a bank for a customer to state that they acknowledge the process and accept the customer details.


- Phase 2:
Admin functionalities are provided for the system, where an admin can track the actions such as upload or approval of KYC documents performed by banks.

Other Banks can vote on the KYC process done by a bank for a customer. If the rating/votes are above the standard range then it is taken as an accepted KYC and used by other banks too.

Banks also vote over the other banks to make sure that the banks are secure and not tampered for the KYC process. This identifies whether the bank is corrupted and uploading fake customer KYC. This rating will help us to judge the bank activities and remove the fraudulent bank from our network.

Admin can block any bank from doing a KYC, admin can also add new banks or remove untrusted banks from the smart contract.


- Phase 3:
In this phase, the smart contract will be deployed over a private network which is put up between various banks.

Banks can use the functionalities of Smart Contract over this private Ethereum network.

Banks need to have an account on the private network to interact with the Smart Contract.

