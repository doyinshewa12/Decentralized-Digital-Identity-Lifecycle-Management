;; Identity Provider Verification Contract
;; Validates credential issuers in the system

(define-data-var admin principal tx-sender)

;; Map of verified identity providers
(define-map verified-providers principal bool)

;; Error codes
(define-constant err-not-admin (err u100))
(define-constant err-already-verified (err u101))
(define-constant err-not-verified (err u102))

;; Check if caller is admin
(define-private (is-admin)
  (is-eq tx-sender (var-get admin)))

;; Register a new identity provider
(define-public (register-provider (provider principal))
  (begin
    (asserts! (is-admin) err-not-admin)
    (asserts! (is-none (map-get? verified-providers provider)) err-already-verified)
    (ok (map-set verified-providers provider true))))

;; Revoke an identity provider's verification
(define-public (revoke-provider (provider principal))
  (begin
    (asserts! (is-admin) err-not-admin)
    (asserts! (is-some (map-get? verified-providers provider)) err-not-verified)
    (ok (map-delete verified-providers provider))))

;; Check if a provider is verified
(define-read-only (is-verified-provider (provider principal))
  (default-to false (map-get? verified-providers provider)))

;; Transfer admin rights
(define-public (transfer-admin (new-admin principal))
  (begin
    (asserts! (is-admin) err-not-admin)
    (ok (var-set admin new-admin))))
