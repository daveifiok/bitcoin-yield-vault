;; Title: BitcoinYield Vault
;; Summary: A secure yield-generating protocol for Bitcoin holders on Stacks
;; Description: This smart contract enables Bitcoin holders to deposit their assets
;; into a managed yield-generating vault on the Stacks Layer 2 network. The protocol
;; provides transparent yield rates, flexible deposit/withdrawal mechanisms, and
;; comprehensive security controls to ensure maximum protection of user funds.
;; Author: StacksLabs

;; Constants

(define-constant contract-owner tx-sender)
(define-constant blocks-per-year u52560) ;; Assuming ~10 min block time
(define-constant basis-points-denominator u10000)
(define-constant emergency-cooldown-period u144) ;; 24 hours in blocks

;; Error Codes

(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-unauthorized (err u102))
(define-constant err-insufficient-balance (err u103))
(define-constant err-pool-inactive (err u104))
(define-constant err-invalid-amount (err u105))
(define-constant err-pool-full (err u106))
(define-constant err-invalid-bool (err u107))
(define-constant err-cooldown-active (err u108))
(define-constant err-below-min-deposit (err u109))
(define-constant err-above-max-deposit (err u110))
(define-constant err-paused (err u111))
(define-constant err-event-error (err u112))

;; State Variables

(define-data-var total-liquidity uint u0)
(define-data-var pool-active bool true)
(define-data-var emergency-paused bool false)
(define-data-var min-deposit uint u1000000) ;; 0.01 BTC in sats
(define-data-var max-deposit-per-user uint u1000000000) ;; 10 BTC in sats
(define-data-var max-pool-size uint u100000000000) ;; 1000 BTC in sats
(define-data-var yield-rate uint u500) ;; 5% APY in basis points
(define-data-var last-yield-calculation uint stacks-block-height)
(define-data-var total-yield-paid uint u0)
(define-data-var last-emergency-action uint u0)

;; Data Maps

(define-map user-deposits
  principal
  {
    amount: uint,
    last-deposit-height: uint,
    accumulated-yield: uint,
    last-action-height: uint,
    total-deposits: uint,
    total-withdrawals: uint,
  }
)

(define-map yield-snapshots
  uint ;; block height
  {
    rate: uint,
    total-liquidity: uint,
    timestamp: uint,
  }
)

(define-map authorized-operators
  principal
  bool
)

;; Events

(define-data-var event-counter uint u0)

(define-map events
  uint
  {
    event-type: (string-ascii 20),
    user: principal,
    amount: uint,
    stacks-block-height: uint,
  }
)

;; Private Functions

(define-private (log-event
    (event-type (string-ascii 20))
    (user principal)
    (amount uint)
  )
  (begin
    (map-set events (var-get event-counter) {
      event-type: event-type,
      user: user,
      amount: amount,
      stacks-block-height: stacks-block-height,
    })
    (var-set event-counter (+ (var-get event-counter) u1))
    true
  )
)