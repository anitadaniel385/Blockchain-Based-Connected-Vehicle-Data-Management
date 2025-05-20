;; Data Collection Contract
;; Gathers and stores vehicle information

(define-data-var contract-owner principal tx-sender)

;; Data structure for collected vehicle data
(define-map vehicle-data
  {
    vehicle-id: (string-ascii 17),
    timestamp: uint
  }
  {
    location: (tuple (latitude int) (longitude int)),
    speed: uint,
    fuel-level: uint,
    engine-status: (string-ascii 20),
    collected-by: principal
  }
)

;; Data collection events
(define-map data-collection-events
  { vehicle-id: (string-ascii 17) }
  { event-count: uint }
)

;; Public function to submit vehicle data
(define-public (submit-data
                (vehicle-id (string-ascii 17))
                (timestamp uint)
                (latitude int)
                (longitude int)
                (speed uint)
                (fuel-level uint)
                (engine-status (string-ascii 20)))
  (begin
    ;; Check if the vehicle exists by calling the verification contract
    (asserts! (is-valid-vehicle vehicle-id) (err u201))

    ;; Store the data
    (map-set vehicle-data
      {
        vehicle-id: vehicle-id,
        timestamp: timestamp
      }
      {
        location: (tuple (latitude latitude) (longitude longitude)),
        speed: speed,
        fuel-level: fuel-level,
        engine-status: engine-status,
        collected-by: tx-sender
      }
    )

    ;; Update event count
    (match (map-get? data-collection-events { vehicle-id: vehicle-id })
      existing-data
      (map-set data-collection-events
        { vehicle-id: vehicle-id }
        { event-count: (+ u1 (get event-count existing-data)) }
      )
      (map-set data-collection-events
        { vehicle-id: vehicle-id }
        { event-count: u1 }
      )
    )

    (ok true)
  )
)

;; Read-only function to get vehicle data
(define-read-only (get-data (vehicle-id (string-ascii 17)) (timestamp uint))
  (map-get? vehicle-data { vehicle-id: vehicle-id, timestamp: timestamp })
)

;; Read-only function to get data collection event count
(define-read-only (get-event-count (vehicle-id (string-ascii 17)))
  (match (map-get? data-collection-events { vehicle-id: vehicle-id })
    existing-data (ok (get event-count existing-data))
    (ok u0)
  )
)

;; Helper function to check if a vehicle is valid
;; In a real implementation, this would call the vehicle verification contract
(define-private (is-valid-vehicle (vehicle-id (string-ascii 17)))
  ;; Simplified validation for demo purposes
  ;; In production, this would call the verification contract
  true
)

;; Initialize contract
(define-private (set-contract-owner (owner principal))
  (var-set contract-owner owner)
)

(set-contract-owner tx-sender)
