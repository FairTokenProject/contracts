## Projekt Gold

This is the third FTP smart contract to be deployed to mainnet. It is the first coin ever to use FTPAntiBot, a public developer library for ERC-20 contracts. Under the guard of FTPAntiBot, Projekt Gold experienced a near perfect launch. Within minutes several pump and dump bots were banned. No snipers ever got away, and several less noticeable bots were captured. At the time of writing, Gold's top holder is a verified banned bot, and several other top 10 holders are as well.

GOLD was supported by 2 other angel investors as well. So when reading the contract, you will notice some experimental investor functions. 3% of transaction taxes go to these investors. 2% is left to the developers. It is likely some of these funds will be allocated toward marketing for FTPAntiBot, Fair Token Project, and GOLD and GREEN.

##### FTPAntiBot | 100% Liquidity Pool Lock | 0% Token Burn | Anti Bot Countermeasures | Anti Whale | Maximum Buys

The core difference between $GREEN and $GOLD is that $GOLD uses FTPAntiBot, a real-time transaction-level security measure against bots.

For integration highlights, see the code references below:

1. Importing the FTPAntiBot Library

      * [See Import Code](../projektGold.sol#L124)

2. Manual Assignment of FTPAntiBot Library

      * This is done for versioning FTPAntiBot. Ownership renouncement not recommended.
      * [See Assignment Code](../projektGold.sol#L507)

3. Asking FTPAntiBot if Transactors Are Bots

      * [See Verification Code](../projektGold.sol#L293)
      
4. Handling FTPAntiBot Response

      * [See Handler Code](../projektGold.sol#L319)

## Community

We encourage people to have conversations with us in telegram. You can join us, discuss new contract ideas, and even influence future coin projects. See you there!
 
* [Telegram](https://t.me/fairtokenproject)
* [Twitter](https://twitter.com/token_project)
* [Website](https://fairtokenproject.com)
