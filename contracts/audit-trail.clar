;; Audit Trail Contract
;; Records identity lifecycle events

(define-data-var admin principal tx-sender)

;; Structure for audit events
(define-map audit-events
  { event-id: uint }
  { owner: principal,
    event-type: (string-ascii 64),
    data: (string-utf8 256),
    timestamp: uint })

;; Counter for event IDs
(define-data-var event-counter uint u0)

;; Error codes
(define-constant err-not-admin (err u100))
(define-constant err-unauthorized (err u101))

;; Check if caller is admin
(define-private (is-admin)
  (is-eq tx-sender (var-get admin)))

;; Record an audit event
(define-public (record-event
                (owner principal)
                (event-type (string-ascii 64))
                (data (string-utf8 256)))
  (let ((event-id (var-get event-counter)))
    ;; Only the owner or an admin can record events
    (asserts! (or (is-eq tx-sender owner) (is-admin)) err-unauthorized)

    ;; Increment the event counter
    (var-set event-counter (+ event-id u1))

    ;; Record the event
    (ok (map-set audit-events
      { event-id: event-id }
      { owner: owner,
        event-type: event-type,
        data: data,
        timestamp: block-height }))))

;; Get an audit event
(define-read-only (get-event (event-id uint))
  (map-get? audit-events { event-id: event-id }))

;; Get the current event counter
(define-read-only (get-event-count)
  (var-get event-counter))

;; Transfer admin rights
(define-public (transfer-admin (new-admin principal))
  (begin
    (asserts! (is-admin) err-not-admin)
    (ok (var-set admin new-admin))))
