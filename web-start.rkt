#lang racket/base

(require web-server/servlet
         web-server/servlet-env
         web-server/templates
         web-server/dispatch
         web-server/page

         "db-interaction/posts.rkt")

(define/page (main-page posts)
  (response/full
    200 #"Okay"
    (current-seconds) TEXT/HTML-MIME-TYPE
    '()
    `(,(string->bytes/utf-8 (include-template "templates/main.html")))))

(define (request/blog request)
  (main-page request (posts/get)))

(define/page (ping-page)
  (response/full
    200 #"Okay"
    (current-seconds) TEXT/HTML-MIME-TYPE
    '()
    `(,(string->bytes/utf-8 "Pong!"))))

(define (request/ping request)
  (ping-page request))

(define-values (blog-dispatch blog-url)
  (dispatch-rules
    [("ping") request/ping]
    [("") request/blog]))

(serve/servlet blog-dispatch
               #:port 8081
               #:listen-ip #f
               #:servlet-regexp #rx""
               #:command-line? #t
               #:extra-files-paths `("static")
               #:servlet-current-directory "./"
               )

