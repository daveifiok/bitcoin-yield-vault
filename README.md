# BitcoinYield Vault

A secure yield-generating protocol for Bitcoin holders on the Stacks Layer 2 network.

## Overview

BitcoinYield Vault enables Bitcoin holders to deposit their assets into a managed yield-generating vault on Stacks L2. The protocol provides transparent yield rates, flexible deposit/withdrawal mechanisms, and comprehensive security controls to ensure maximum protection of user funds.

## Key Features

- **Secure Bitcoin Yield Generation**: Earn yield on Bitcoin deposits through Stacks Layer 2
- **Flexible Deposits/Withdrawals**: No lock-up periods with instant liquidity
- **Transparent Yield Calculation**: Real-time yield accrual based on configurable APY
- **Emergency Controls**: Multi-layered security with pause mechanisms and cooldown periods
- **Administrative Governance**: Owner-controlled parameters with operator delegation
- **Comprehensive Event Logging**: Full audit trail of all protocol interactions

## Architecture

```text
┌─────────────────────────────────────────────────────────────────┐
│                    BitcoinYield Vault Protocol                  │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐ │
│  │   User Layer    │  │  Admin Layer    │  │ Security Layer  │ │
│  │                 │  │                 │  │                 │ │
│  │ • deposit()     │  │ • set-yield-    │  │ • emergency-    │ │
│  │ • withdraw()    │  │   rate()        │  │   pause()       │ │
│  │ • claim-yield() │  │ • set-pool-     │  │ • emergency-    │ │
│  │                 │  │   parameters()  │  │   resume()      │ │
│  └─────────────────┘  │ • add-operator()│  │ • cooldown      │ │
│           │            │                 │  │   validation    │ │
│           │            └─────────────────┘  └─────────────────┘ │
│           │                       │                    │        │
│           └───────────────────────┼────────────────────┼────────┤
│                                   │                    │        │
│  ┌─────────────────────────────────────────────────────────────┐ │
│  │                    Core State Management                    │ │
│  │                                                             │ │
│  │ • User Deposits Mapping     • Yield Snapshots Mapping      │ │
│  │ • Event Logging System      • Pool Configuration Vars      │ │
│  │ • Security State Variables  • Operator Authorization       │ │
│  └─────────────────────────────────────────────────────────────┘ │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## Smart Contract Structure

### State Variables

- **Pool Management**: Total liquidity, pool status, and operational parameters
- **Security Controls**: Emergency pause state, cooldown periods, and access controls
- **Yield Configuration**: APY rates, calculation timestamps, and yield distribution tracking

### Data Structures

#### User Deposits

```clarity
{
  amount: uint,                    // Current deposit balance
  last-deposit-height: uint,       // Block height of last deposit
  accumulated-yield: uint,         // Unclaimed yield amount
  last-action-height: uint,        // Block height of last action
  total-deposits: uint,            // Lifetime deposit total
  total-withdrawals: uint          // Lifetime withdrawal total
}
```

#### Yield Snapshots

```clarity
{
  rate: uint,                      // Yield rate at snapshot time
  total-liquidity: uint,           // Pool liquidity at snapshot
  timestamp: uint                  // Block height timestamp
}
```

## Core Functions

### User Operations

#### `deposit(amount: uint)`

Deposits Bitcoin into the yield vault.

- **Requirements**: Pool must be active, amount above minimum deposit
- **Validations**: User deposit limits, pool capacity constraints
- **Effects**: Updates user position, accrues pending yield, logs deposit event

#### `withdraw(amount: uint)`

Withdraws Bitcoin from the vault.

- **Requirements**: Sufficient user balance, pool operational
- **Effects**: Updates user position, maintains yield accrual, logs withdrawal event

#### `claim-yield()`

Claims accumulated yield rewards.

- **Returns**: Amount of yield claimed
- **Effects**: Resets user accumulated yield, updates total yield paid

### Administrative Functions

#### `set-yield-rate(new-rate: uint)`

Updates the annual percentage yield (APY) for the vault.

- **Access**: Contract owner only
- **Constraints**: Maximum 100% APY (10000 basis points)
- **Effects**: Creates yield snapshot, logs rate change

#### `emergency-pause()` / `emergency-resume()`

Emergency controls for protocol security.

- **Access**: Contract owner only
- **Cooldown**: 24-hour minimum between pause and resume
- **Effects**: Halts all user operations during pause

#### `set-pool-parameters(min, max-per-user, max-pool)`

Configures deposit limits and pool capacity.

- **Access**: Contract owner only
- **Validations**: Logical parameter relationships maintained

## Security Features

### Multi-Layer Protection

1. **Owner Controls**: Critical functions restricted to contract deployer
2. **Emergency Systems**: Immediate pause capability with cooldown protection
3. **Parameter Validation**: Comprehensive input validation and boundary checks
4. **Event Logging**: Complete audit trail of all protocol interactions

### Risk Mitigation

- **Deposit Limits**: Per-user and total pool size constraints
- **Yield Rate Caps**: Maximum 100% APY to prevent exploitation
- **State Consistency**: Atomic operations with comprehensive error handling

## Configuration Parameters

| Parameter | Default Value | Description |
|-----------|---------------|-------------|
| `min-deposit` | 0.01 BTC (1M sats) | Minimum deposit amount |
| `max-deposit-per-user` | 10 BTC (1B sats) | Maximum per-user deposit |
| `max-pool-size` | 1000 BTC (100B sats) | Total pool capacity |
| `yield-rate` | 5% APY (500 basis points) | Annual yield rate |
| `emergency-cooldown-period` | 24 hours (144 blocks) | Minimum pause duration |

## Usage Examples

### Basic Deposit Flow

```clarity
;; Check pool status
(contract-call? .bitcoin-yield-vault get-pool-stats)

;; Make deposit
(contract-call? .bitcoin-yield-vault deposit u50000000) ;; 0.5 BTC

;; Check user position
(contract-call? .bitcoin-yield-vault get-user-position tx-sender)
```

### Yield Management

```clarity
;; Claim accumulated yield
(contract-call? .bitcoin-yield-vault claim-yield)

;; Withdraw principal
(contract-call? .bitcoin-yield-vault withdraw u25000000) ;; 0.25 BTC
```

## Error Codes

| Code | Constant | Description |
|------|----------|-------------|
| 100 | `err-owner-only` | Function restricted to contract owner |
| 101 | `err-not-found` | User deposit record not found |
| 102 | `err-unauthorized` | Insufficient permissions |
| 103 | `err-insufficient-balance` | Withdrawal exceeds user balance |
| 104 | `err-pool-inactive` | Pool is not accepting operations |
| 105 | `err-invalid-amount` | Invalid parameter amount |
| 106 | `err-pool-full` | Pool has reached capacity limit |
| 108 | `err-cooldown-active` | Emergency cooldown period active |
| 109 | `err-below-min-deposit` | Deposit below minimum threshold |
| 110 | `err-above-max-deposit` | Deposit exceeds user limit |
| 111 | `err-paused` | Protocol is emergency paused |

## Event Types

- `DEPOSIT`: User deposit operations
- `WITHDRAW`: User withdrawal operations  
- `CLAIM`: Yield claim operations
- `POOL_STATUS`: Pool activation status changes
- `EMERGENCY_PAUSE`: Emergency pause activations
- `EMERGENCY_RESUME`: Emergency pause deactivations
- `YIELD_RATE`: Yield rate updates
- `PARAMS_UPDATE`: Parameter configuration changes
- `ADD_OPERATOR` / `REMOVE_OPERATOR`: Operator management

## Development & Deployment

### Prerequisites

- Stacks blockchain development environment
- Clarity smart contract tooling
- Bitcoin testnet/mainnet access for testing

### Testing Strategy

1. **Unit Tests**: Individual function validation
2. **Integration Tests**: Multi-function interaction scenarios  
3. **Security Tests**: Edge cases and attack vector validation
4. **Load Tests**: Pool capacity and performance validation

### Deployment Checklist

- [ ] Verify all constants and initial parameters
- [ ] Confirm owner address configuration
- [ ] Validate yield calculation mathematics
- [ ] Test emergency procedures
- [ ] Audit event logging completeness

## Security Considerations

⚠️ **Important Security Notes**:

- Always verify pool status before deposits
- Monitor yield rates for unexpected changes  
- Understand emergency pause implications
- Validate all transaction parameters
- Keep private keys secure for administrative functions
