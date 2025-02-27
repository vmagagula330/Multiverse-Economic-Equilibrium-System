;; Cross-universal Trade Agreement Contract

(define-map trade-agreements
  { agreement-id: uint }
  {
    party1: principal,
    party2: principal,
    terms: (string-utf8 500),
    status: (string-ascii 20)
  }
)

(define-data-var next-agreement-id uint u0)

(define-public (create-agreement (party2 principal) (terms (string-utf8 500)))
  (let
    ((agreement-id (var-get next-agreement-id)))
    (var-set next-agreement-id (+ agreement-id u1))
    (ok (map-set trade-agreements
      { agreement-id: agreement-id }
      {
        party1: tx-sender,
        party2: party2,
        terms: terms,
        status: "pending"
      }
    ))
  )
)

(define-public (accept-agreement (agreement-id uint))
  (match (map-get? trade-agreements { agreement-id: agreement-id })
    agreement
      (begin
        (asserts! (is-eq (get party2 agreement) tx-sender) (err u403))
        (ok (map-set trade-agreements
          { agreement-id: agreement-id }
          (merge agreement { status: "active" })
        )))
    (err u404)
  )
)

(define-public (terminate-agreement (agreement-id uint))
  (match (map-get? trade-agreements { agreement-id: agreement-id })
    agreement
      (begin
        (asserts! (or (is-eq (get party1 agreement) tx-sender) (is-eq (get party2 agreement) tx-sender)) (err u403))
        (ok (map-set trade-agreements
          { agreement-id: agreement-id }
          (merge agreement { status: "terminated" })
        )))
    (err u404)
  )
)

(define-read-only (get-agreement (agreement-id uint))
  (map-get? trade-agreements { agreement-id: agreement-id })
)

