# Stakify Smart Contract

Stakify is a decentralized finance (DeFi) smart contract written in Clarity that enables yield optimization through staking, liquidity provision, and leveraged trading functionalities.

## Features

### Token Staking and Yield Generation
- Deposit tokens into the protocol
- Withdraw tokens from staking positions
- Built-in overflow protection for token operations

### Liquidity Pool Management
- Provide liquidity with both tokens and stablecoins
- Withdraw liquidity positions
- Automatic balance tracking for liquidity providers

### Leveraged Trading
- Create leveraged positions with customizable ratios
- Close positions manually
- Liquidation mechanism for risk management
- Protection against self-liquidation

## Function Documentation

### Staking Functions
- `deposit-tokens(quantity: uint) => response`
  - Deposits the specified quantity of tokens into the protocol
  - Returns error if numeric overflow would occur

- `withdraw-tokens(quantity: uint) => response`
  - Withdraws the specified quantity of tokens from the protocol
  - Returns error if insufficient tokens are available

### Liquidity Functions
- `provide-liquidity(token-quantity: uint, stablecoin-quantity: uint) => response`
  - Adds liquidity to the pool in both tokens and stablecoins
  - Returns the amounts added to the pool

- `withdraw-liquidity(token-shares: uint, stablecoin-shares: uint) => response`
  - Removes liquidity from the pool
  - Returns the amounts withdrawn

### Leverage Trading Functions
- `create-leveraged-position(quantity: uint, leverage-ratio: uint) => response`
  - Creates a leveraged trading position
  - Leverage ratio must be between 1 and 100
  - Returns the created position details

- `close-leveraged-position() => response`
  - Closes an existing leveraged position
  - Returns the closed position details

- `force-liquidation(user: principal) => response`
  - Allows liquidation of other users' positions
  - Prevents self-liquidation attempts

### Read-Only Functions
- `get-token-deposit(user: principal) => uint`
  - Returns the user's current token deposit amount

- `get-liquidity-position(user: principal) => {tokens: uint, stablecoins: uint}`
  - Returns the user's current liquidity position

- `get-leveraged-position(user: principal) => optional {quantity: uint, ratio: uint}`
  - Returns details of user's leveraged position if it exists

## Error Codes

- `ERR-INSUFFICIENT-TOKENS (u100)`: Not enough tokens for the requested operation
- `ERR-INSUFFICIENT-LIQUIDITY (u101)`: Not enough liquidity for the requested operation
- `ERR-NO-ACTIVE-POSITION (u102)`: No leveraged position exists for the user
- `ERR-NUMERIC-OVERFLOW (u103)`: Operation would cause numeric overflow
- `ERR-INVALID-QUANTITY (u104)`: Invalid token quantity specified
- `ERR-INVALID-LEVERAGE-RATIO (u105)`: Leverage ratio outside allowed range
- `ERR-SELF-LIQUIDATION-ATTEMPT (u106)`: User attempted to liquidate their own position

## Data Storage

The contract uses the following data maps to track user positions:
- `token-deposits`: Tracks staked token amounts
- `token-liquidity`: Tracks token liquidity provided
- `stablecoin-liquidity`: Tracks stablecoin liquidity provided
- `leveraged-positions`: Tracks leveraged trading positions

## Security Considerations

1. The contract includes overflow protection for all numerical operations
2. Leveraged positions are protected against self-liquidation
3. All state-changing functions include appropriate balance checks
4. Leverage ratios are strictly bounded to prevent excessive risk

