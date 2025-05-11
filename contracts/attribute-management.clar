;; Attribute Management Contract
;; Handles identity claims updates

(define-data-var admin principal tx-sender)

;; Structure for identity attributes
(define-map identity-attributes
  { owner: principal, attr-name: (string-ascii 64) }
  { value: (string-utf8 256), issuer: principal, timestamp: uint })

;; Error codes
(define-constant err-not-admin (err u100))
(define-constant err-unauthorized (err u101))
(define-constant err-invalid-issuer (err u102))

;; Check if caller is admin
(define-private (is-admin)
  (is-eq tx-sender (var-get admin)))

;; Add or update an attribute
(define-public (set-attribute (owner principal) (attr-name (string-ascii 64)) (value (string-utf8 256)))
  (begin
    ;; Only the owner or an admin can set attributes
    (asserts! (or (is-eq tx-sender owner) (is-admin)) err-unauthorized)
    (ok (map-set identity-attributes
      { owner: owner, attr-name: attr-name }
      { value: value, issuer: tx-sender, timestamp: block-height }))))

;; Get an attribute
(define-read-only (get-attribute (owner principal) (attr-name (string-ascii 64)))
  (map-get? identity-attributes { owner: owner, attr-name: attr-name }))

;; Delete an attribute
(define-public (delete-attribute (owner principal) (attr-name (string-ascii 64)))
  (begin
    (asserts! (or (is-eq tx-sender owner) (is-admin)) err-unauthorized)
    (ok (map-delete identity-attributes { owner: owner, attr-name: attr-name }))))

;; Transfer admin rights
(define-public (transfer-admin (new-admin principal))
  (begin
    (asserts! (is-admin) err-not-admin)
    (ok (var-set admin new-admin))))
