# Stakify Smart Contract

## Overview

Stakify is a yield optimization smart contract built on the Stacks blockchain. It provides a platform for users to stake tokens, manage liquidity, engage in leveraged trading, and earn rewards. The contract is designed with safety and flexibility in mind, incorporating emergency controls and a robust reward system.

## Features

1. **Token Staking**: Users can deposit and withdraw tokens.
2. **Liquidity Pool Management**: Provides functionality to add and remove liquidity.
3. **Leveraged Trading**: Allows users to create and manage leveraged positions.
4. **Reward System**: Implements a point-based reward system with claiming functionality.
5. **Emergency Controls**: Includes contract pause/unpause and admin management features.

## Contract Functions

### Emergency Controls

- `pause-contract()`: Pauses the contract operations.
- `unpause-contract()`: Resumes the contract operations.
- `change-emergency-admin(new-admin: principal)`: Changes the emergency admin.

### Reward System

- `get-pending-rewards(user: principal)`: Calculates pending rewards for a user.
- `update-reward-rate(new-rate: uint)`: Updates the reward rate.
- `claim-rewards()`: Allows users to claim their accumulated rewards.
- `add-reward-points(points: uint)`: Adds reward points to a user's account.

### Staking and Yield

- `deposit-tokens(quantity: uint)`: Deposits tokens into the contract.
- `withdraw-tokens(quantity: uint)`: Withdraws tokens from the contract.

### Liquidity Pool Management

- `provide-liquidity(token-quantity: uint, stablecoin-quantity: uint)`: Adds liquidity to the pool.
- `withdraw-liquidity(token-shares: uint, stablecoin-shares: uint)`: Removes liquidity from the pool.

### Leveraged Trading

- `create-leveraged-position(quantity: uint, leverage-ratio: uint)`: Creates a leveraged position.
- `close-leveraged-position()`: Closes the user's leveraged position.
- `force-liquidation(user: principal)`: Allows forced liquidation of a user's position.

### Read-Only Functions

- `get-token-deposit(user: principal)`: Returns the token deposit of a user.
- `get-liquidity-position(user: principal)`: Returns the liquidity position of a user.
- `get-leveraged-position(user: principal)`: Returns the leveraged position of a user.
- `get-contract-state()`: Returns the current state of the contract.

## Error Codes

- `ERR-INSUFFICIENT-TOKENS (u100)`: Insufficient tokens for the operation.
- `ERR-INSUFFICIENT-LIQUIDITY (u101)`: Insufficient liquidity for the operation.
- `ERR-NO-ACTIVE-POSITION (u102)`: No active position found.
- `ERR-NUMERIC-OVERFLOW (u103)`: Numeric overflow detected.
- `ERR-INVALID-QUANTITY (u104)`: Invalid quantity provided.
- `ERR-INVALID-LEVERAGE-RATIO (u105)`: Invalid leverage ratio.
- `ERR-SELF-LIQUIDATION-ATTEMPT (u106)`: Attempt to self-liquidate.
- `ERR-NOT-AUTHORIZED (u401)`: Unauthorized access.
- `ERR-CONTRACT-PAUSED (u402)`: Contract is paused.
- `ERR-NO-REWARDS (u501)`: No rewards available.
- `ERR-REWARDS-ALREADY-CLAIMED (u502)`: Rewards already claimed.
- `ERR-NOT-ADMIN (u503)`: Not an admin.
- `ERR-INVALID-ADMIN (u504)`: Invalid admin address.
- `ERR-INVALID-REWARD-RATE (u505)`: Invalid reward rate.
- `ERR-INVALID-REWARD-POINTS (u506)`: Invalid reward points.

## Security Considerations

1. The contract includes emergency controls to pause operations if needed.
2. Input validation is implemented to prevent overflow and invalid data.
3. Access control is enforced for admin-only functions.
4. The contract uses safe math operations to prevent underflows and overflows.

## Deployment

To deploy this contract:

1. Ensure you have the Stacks CLI installed and configured.
2. Deploy the contract using the Stacks CLI:
