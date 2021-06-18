## Projekt Green

This is the second FTP smart contract to be deployed to mainnet. We are excited to have found success with this token. A day after trading we held strong at 3x value.. peaking at 30x in the first day. This kind of dumping is normal in this market. Dumping happens because uniswap makes the first 70% almost completely the same price until exponentially rising. People begin making high returns very quickly, thus dumping.

Here's how we look at it. 30x gains in an hour are not normal in healthy conditions, but it is unavoidable with token launches unless you restrict selling, which we will never do. Therefore, coming into the 2nd day with 3x gains holding is a huge success.

##### 100% Liquidity Pool BURNED | 0% Token Burn | Anti Bot Countermeasures | Anti Whale | Maximum Buys

The core difference between $ORANGE and $GREEN is that Projekt Green implements some rudimentary realtime bot countermeasures. This was a great step towards a proof of concept for us, and more of this should be expected in the future.

At a high level, our realtime measures execute in 3 steps.

1. Flagging: When a purchase transaction executes within a block threshold of the previous purchase, flag buyer.

      * [See Flagging Code](../projektGreen.sol#L241)

2. Banning: When flags, or warnings, are greater than 2, ban address from selling. The implications are severe, and thus reversible.

      * [See Banning Code](../projektGreen.sol#L238)

3. Verifying: Check if seller is banned

      * [See Verification Code](../projektGreen.sol#L233)

Sell banning is reversible, but none of our real traders were accidentally banned during the launch of $GREEN. So reversal was never necessary.

## Community

We encourage people to have conversations with us in telegram. You can join us, discuss new contract ideas, and even influence future coin projects. See you there!
 
* [Telegram](https://t.me/fairtokenproject)
* [Twitter](https://twitter.com/token_project)
* [Website](https://fairtokenproject.com)
