;; Inter-reality Exchange Rate Contract

(define-map exchange-rates
  { from-currency: (string-ascii 10), to-currency: (string-ascii 10) }
  { rate: uint, last-updated: uint }
)

(define-data-var admin principal tx-sender)

(define-public (set-exchange-rate (from-currency (string-ascii 10)) (to-currency (string-ascii 10)) (rate uint))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u403))
    (ok (map-set exchange-rates
      { from-currency: from-currency, to-currency: to-currency }
      { rate: rate, last-updated: block-height }
    ))
  )
)

(define-read-only (get-exchange-rate (from-currency (string-ascii 10)) (to-currency (string-ascii 10)))
  (map-get? exchange-rates { from-currency: from-currency, to-currency: to-currency })
)

(define-public (convert-value (amount uint) (from-currency (string-ascii 10)) (to-currency (string-ascii 10)))
  (match (map-get? exchange-rates { from-currency: from-currency, to-currency: to-currency })
    rate-data (ok (/ (* amount (get rate rate-data)) u100000000))
    (err u404)
  )
)

(define-public (set-admin (new-admin principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u403))
    (ok (var-set admin new-admin))
  )
)

