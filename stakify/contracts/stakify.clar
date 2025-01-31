;; Stakify Contract for yield optimization

;; Principal Variables
(define-data-var contract-owner principal tx-sender)
(define-data-var emergency-admin (optional principal) (some tx-sender))

;; Constants
(define-constant ERR-INSUFFICIENT-TOKENS (err u100))
(define-constant ERR-INSUFFICIENT-LIQUIDITY (err u101))
(define-constant ERR-NO-ACTIVE-POSITION (err u102))
(define-constant ERR-NUMERIC-OVERFLOW (err u103))
(define-constant ERR-INVALID-QUANTITY (err u104))
(define-constant ERR-INVALID-LEVERAGE-RATIO (err u105))
(define-constant ERR-SELF-LIQUIDATION-ATTEMPT (err u106))
(define-constant ERR-NOT-AUTHORIZED (err u401))
(define-constant ERR-CONTRACT-PAUSED (err u402))
(define-constant ERR-NO-REWARDS (err u501))
(define-constant ERR-REWARDS-ALREADY-CLAIMED (err u502))
(define-constant ERR-NOT-ADMIN (err u503))

;; Data Variables
(define-data-var contract-paused bool false)
(define-data-var rewards-per-block uint u100)
(define-data-var last-reward-block uint u0)
(define-data-var total-reward-points uint u0)

;; Data Maps
(define-map token-deposits principal uint)
(define-map token-liquidity principal uint)
(define-map stablecoin-liquidity principal uint)
(define-map leveraged-positions principal {quantity: uint, ratio: uint})
(define-map reward-points principal uint)

;; Private Functions
(define-private (is-admin)
  (match (var-get emergency-admin)
    admin (is-eq tx-sender admin)
    false))

;; Emergency Controls
(define-public (pause-contract)
  (begin
    (asserts! (is-admin) ERR-NOT-AUTHORIZED)
    (var-set contract-paused true)
    (ok true)))

(define-public (unpause-contract)
  (begin
    (asserts! (is-admin) ERR-NOT-AUTHORIZED)
    (var-set contract-paused false)
    (ok true)))

(define-public (change-emergency-admin (new-admin principal))
  (begin
    (asserts! (is-admin) ERR-NOT-AUTHORIZED)
    (var-set emergency-admin (some new-admin))
    (ok true)))

;; Reward System Functions
(define-read-only (get-pending-rewards (user principal))
  (let 
    ((user-points (default-to u0 (map-get? reward-points user)))
     (blocks-passed (- stacks-block-height (var-get last-reward-block)))
     (reward-rate (var-get rewards-per-block)))
    (if (> user-points u0)
      (/ (* user-points (* blocks-passed reward-rate)) (var-get total-reward-points))
      u0)))

(define-public (update-reward-rate (new-rate uint))
  (begin
    (asserts! (is-admin) ERR-NOT-AUTHORIZED)
    (var-set rewards-per-block new-rate)
    (ok new-rate)))

(define-public (claim-rewards)
  (begin
    (asserts! (not (var-get contract-paused)) ERR-CONTRACT-PAUSED)
    (let 
      ((pending-rewards (get-pending-rewards tx-sender))
       (user-points (default-to u0 (map-get? reward-points tx-sender))))
      (asserts! (> pending-rewards u0) ERR-NO-REWARDS)
      (var-set last-reward-block stacks-block-height)
      (map-set reward-points tx-sender u0)
      (var-set total-reward-points (- (var-get total-reward-points) user-points))
      (ok pending-rewards))))

(define-public (add-reward-points (points uint))
  (begin
    (asserts! (not (var-get contract-paused)) ERR-CONTRACT-PAUSED)
    (let 
      ((current-points (default-to u0 (map-get? reward-points tx-sender))))
      (map-set reward-points tx-sender (+ current-points points))
      (var-set total-reward-points (+ (var-get total-reward-points) points))
      (ok points))))

;; Staking and Yield section
(define-public (deposit-tokens (quantity uint))
  (begin
    (asserts! (not (var-get contract-paused)) ERR-CONTRACT-PAUSED)
    (let ((current-deposit (default-to u0 (map-get? token-deposits tx-sender))))
      (asserts! (< (+ current-deposit quantity) u340282366920938463463374607431768211455) ERR-NUMERIC-OVERFLOW)
      (map-set token-deposits tx-sender (+ current-deposit quantity))
      (try! (add-reward-points quantity))
      (ok quantity))))

(define-public (withdraw-tokens (quantity uint))
  (begin
    (asserts! (not (var-get contract-paused)) ERR-CONTRACT-PAUSED)
    (let ((current-deposit (default-to u0 (map-get? token-deposits tx-sender))))
      (asserts! (>= current-deposit quantity) ERR-INSUFFICIENT-TOKENS)
      (map-set token-deposits tx-sender (- current-deposit quantity))
      (try! (add-reward-points (- quantity)))
      (ok quantity))))

;; Liquidity Pool Management section
(define-public (provide-liquidity (token-quantity uint) (stablecoin-quantity uint))
  (begin
    (asserts! (not (var-get contract-paused)) ERR-CONTRACT-PAUSED)
    (let 
      ((current-token-liquidity (default-to u0 (map-get? token-liquidity tx-sender)))
       (current-stablecoin-liquidity (default-to u0 (map-get? stablecoin-liquidity tx-sender))))
      (asserts! (< (+ current-token-liquidity token-quantity) u340282366920938463463374607431768211455) ERR-NUMERIC-OVERFLOW)
      (asserts! (< (+ current-stablecoin-liquidity stablecoin-quantity) u340282366920938463463374607431768211455) ERR-NUMERIC-OVERFLOW)
      (map-set token-liquidity tx-sender (+ current-token-liquidity token-quantity))
      (map-set stablecoin-liquidity tx-sender (+ current-stablecoin-liquidity stablecoin-quantity))
      (try! (add-reward-points (+ token-quantity stablecoin-quantity)))
      (ok {tokens-added: token-quantity, stablecoins-added: stablecoin-quantity}))))

(define-public (withdraw-liquidity (token-shares uint) (stablecoin-shares uint))
  (begin
    (asserts! (not (var-get contract-paused)) ERR-CONTRACT-PAUSED)
    (let 
      ((current-token-liquidity (default-to u0 (map-get? token-liquidity tx-sender)))
       (current-stablecoin-liquidity (default-to u0 (map-get? stablecoin-liquidity tx-sender))))
      (asserts! (and (>= current-token-liquidity token-shares) 
                     (>= current-stablecoin-liquidity stablecoin-shares)) 
                ERR-INSUFFICIENT-LIQUIDITY)
      (map-set token-liquidity tx-sender (- current-token-liquidity token-shares))
      (map-set stablecoin-liquidity tx-sender (- current-stablecoin-liquidity stablecoin-shares))
      (try! (add-reward-points (- (+ token-shares stablecoin-shares))))
      (ok {tokens-removed: token-shares, stablecoins-removed: stablecoin-shares}))))

;; Token Trading with Leverage section
(define-public (create-leveraged-position (quantity uint) (leverage-ratio uint))
  (begin
    (asserts! (not (var-get contract-paused)) ERR-CONTRACT-PAUSED)
    (asserts! (> quantity u0) ERR-INVALID-QUANTITY)
    (asserts! (and (>= leverage-ratio u1) (<= leverage-ratio u100)) ERR-INVALID-LEVERAGE-RATIO)
    (map-set leveraged-positions tx-sender {quantity: quantity, ratio: leverage-ratio})
    (try! (add-reward-points (* quantity leverage-ratio)))
    (ok {quantity: quantity, ratio: leverage-ratio})))

(define-public (close-leveraged-position)
  (begin
    (asserts! (not (var-get contract-paused)) ERR-CONTRACT-PAUSED)
    (let ((position (unwrap! (map-get? leveraged-positions tx-sender) ERR-NO-ACTIVE-POSITION)))
      (map-delete leveraged-positions tx-sender)
      (try! (add-reward-points (- (* (get quantity position) (get ratio position)))))
      (ok position))))

(define-public (force-liquidation (user principal))
  (begin
    (asserts! (not (var-get contract-paused)) ERR-CONTRACT-PAUSED)
    (asserts! (not (is-eq tx-sender user)) ERR-SELF-LIQUIDATION-ATTEMPT)
    (let ((position (unwrap! (map-get? leveraged-positions user) ERR-NO-ACTIVE-POSITION)))
      (map-delete leveraged-positions user)
      (try! (add-reward-points (- (* (get quantity position) (get ratio position)))))
      (ok position))))

;; Read-only functions for querying state
(define-read-only (get-token-deposit (user principal))
  (default-to u0 (map-get? token-deposits user)))

(define-read-only (get-liquidity-position (user principal))
  {tokens: (default-to u0 (map-get? token-liquidity user)),
   stablecoins: (default-to u0 (map-get? stablecoin-liquidity user))})

(define-read-only (get-leveraged-position (user principal))
  (map-get? leveraged-positions user))

(define-read-only (get-contract-state)
  {paused: (var-get contract-paused),
   admin: (var-get emergency-admin),
   rewards-rate: (var-get rewards-per-block),
   total-rewards: (var-get total-reward-points),
   last-reward-block: (var-get last-reward-block)})