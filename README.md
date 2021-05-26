# The Fair Token Project Contracts

Something we don't see enough is transparency in smart contracts. We want to bring some change to that. Why? Skimming through the latest meme coin crazes, we see people apeing into coins that are obvious honeypots, have ridiculously high burn ratios, and contain other serious red flags. 

## Projekt Orange

##### 100% Liquidity Pool Lock | 0% Token Burn | Ownership to be Renounced | Anti Whale | Maximum Buys

1. This is the first FTP smart contract. Here is how it works. The supply will start with 100T (100,000,000,000,000). The maximum purchase is 0.5% of the total supply, or 500,000,000,000.

      * [Verify Supply](projektOrange.sol#L502) - You'll notice 10**12 in some places. This is for long decimal handling.
      * [Verify Maximum Purchase](projektOrange.sol#L510)

2. The total supply is going to be locked away in liquidity for people to buy. As you might notice this leaves nothing for devs. Instead of holding 5% (sometimes much higher) of the total supply, there is a small 2% fee attached to each transaction.

3. We use a maximum fee check to ensure the fee is never more than 2% of any transfer, as is the case when giving Uniswap liquidity. Since the maximum transaction is 0.5%, and the fee is 2%, the maximum fee can only be 10,000,000,000, or 0.01% of the total supply.

      * [Verify Maximum Fee](projektOrange.sol#L511)
      * [Verify Fee Calculation](projektOrange.sol#L590)
      * [Verify Fee Enforcement](projektOrange.sol#L593)

4. Another thing you want to look for in smart contracts is anything checking for owner status. This can sometimes be a red flag if the contract creator is trying to enforce special rules for the owner. However, there are some rules that actually do require owner checks. We conduct an owner check in the transfer function when looking at maximum transactions. This is required because the owner must be able to transfer the total supply of coins into uniswap for public trading.

      * [Verify Owner Check](projektOrange.sol#586)

## Telegram

We encourage people to have conversations with us in telegram. You can join us, discuss new contract ideas, and even influence future coin projects. See you there! https://t.me/fairtokenproject
