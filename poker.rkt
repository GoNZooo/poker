#lang racket/base

(require racket/place
         racket/match
         racket/contract
         racket/string
         racket/port
         net/url

         gonz/loops

         "structs.rkt")

(provide poke*)

(define/contract (read-pokees [filename "pokees.data"])
  (() (string?) . ->* . (listof pokee?))

  (define (make-pokee i)
    (match i
      [`(pokee ,name ,url) (pokee name url)]
      [_ (pokee "INVALID NAME" "INVALID URL")]))

  (map make-pokee (call-with-input-file filename read)))

(define/contract (poke p parent)
  (pokee? thread? . -> . thread?)

  (thread
    (lambda ()

      (define start-time (current-milliseconds))
      (define data
        (call/input-url (string->url (pokee-url p))
                        get-pure-port
                        port->string))

      (thread-send parent
                   (pokeresult (pokee-name p)
                               (string-length data)
                               (- (current-milliseconds)
                                  start-time))))))

(define/contract (poke* pokees parent)
  ((listof pokee?) thread? . -> . thread?)
  
  (thread
    (lambda ()

      (define (get-all-messages child-pool)
        (define (forward-message child)
          (thread-send parent (thread-receive)))
        (map forward-message child-pool)) 

      (define ct (current-thread))
      (define children
        (map (lambda (p)
               (poke p ct))
             pokees))

      (get-all-messages children))))

(define (display-results)
  (define (display-result pr)
    (printf "~a ~a ~a~n"
            (pokeresult-name pr)
            (pokeresult-bytes-read pr)
            (pokeresult-duration pr)))

  (define ct (current-thread))

  (define poke-thread
    (poke* (read-pokees) ct))

  (while (thread-running? poke-thread)
         (display-result (thread-receive))))

(module+ main
  (display-results))
