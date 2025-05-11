;; Credential Revocation Contract
;; Manages invalidation of outdated claims

(define-data-var admin principal tx-sender)

;; Map of revoked credentials
(define-map revoked-credentials
  { credential-id: (string-ascii 64) }
  { revoked-by: principal, reason: (string-utf8 256), timestamp: uint })

;; Error codes
(define-constant err-not-admin (err u100))
(define-constant err-unauthorized (err u101))
(define-constant err-already-revoked (err u102))

;; Check if caller is admin
(define-private (is-admin)
  (is-eq tx-sender (var-get admin)))

;; Revoke a credential
(define-public (revoke-credential
                (credential-id (string-ascii 64))
                (reason (string-utf8 256)))
  (begin
    ;; Only admin can revoke credentials
    (asserts! (is-admin) err-unauthorized)
    (asserts! (is-none (map-get? revoked-credentials { credential-id: credential-id })) err-already-revoked)
    (ok (map-set revoked-credentials
      { credential-id: credential-id }
      { revoked-by: tx-sender, reason: reason, timestamp: block-height }))))

;; Check if a credential is revoked
(define-read-only (is-revoked (credential-id (string-ascii 64)))
  (is-some (map-get? revoked-credentials { credential-id: credential-id })))

;; Get revocation details
(define-read-only (get-revocation-details (credential-id (string-ascii 64)))
  (map-get? revoked-credentials { credential-id: credential-id }))

;; Transfer admin rights
(define-public (transfer-admin (new-admin principal))
  (begin
    (asserts! (is-admin) err-not-admin)
    (ok (var-set admin new-admin))))
