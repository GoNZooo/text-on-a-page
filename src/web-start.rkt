#lang racket/base

(require web-server/servlet
         web-server/servlet-env
         web-server/templates
         web-server/dispatch
         web-server/page

         "db-interaction/post-struct.rkt"
         "db-interaction/posts.rkt"
         "formatting-helpers.rkt")

(define/page (main-page shown-posts)
  (response/full
   200 #"Okay"
   (current-seconds) TEXT/HTML-MIME-TYPE
   '()
   `(,(string->bytes/utf-8 (include-template "templates/main.html")))))

(define/page (view-page/id shown-posts)
  (response/full
   200 #"Okay"
   (current-seconds) TEXT/HTML-MIME-TYPE
   '()
   `(,(string->bytes/utf-8 (include-template "templates/view_id.html")))))

(define/page (view-page/tag tag shown-posts)
  (response/full
   200 #"Okay"
   (current-seconds) TEXT/HTML-MIME-TYPE
   '()
   `(,(string->bytes/utf-8 (include-template "templates/view_tag.html")))))

(define/page (not-found-page)
  (response/full
   200 #"Okay"
   (current-seconds) TEXT/HTML-MIME-TYPE
   '()
   `(,(string->bytes/utf-8 (include-template "templates/not_found.html")))))

(define (request/main request)
  (main-page request (sort (posts/get)
                           >
                           #:key post-id)))

(define (request/view/id request id)
  (define shown-post (posts/get/id id))

  (if (equal? shown-post #f)
      (not-found-page request)
      (view-page/id request `(,shown-post))))

(define (request/view/tag request tag)
  (define shown-posts (reverse (posts/get/tag tag)))

  (if (null? shown-posts)
      (not-found-page request)
      (view-page/tag request tag shown-posts)))

(define/page (ping-page [arg ""])
  (response/full
   200 #"Okay"
   (current-seconds) TEXT/HTML-MIME-TYPE
   '()
   `(,(string->bytes/utf-8 (format "Pong! ~a!" arg)))))

(define (request/ping request [arg ""])
  (ping-page request (url->string (request-uri request))))

(define-values (text-dispatch text-url)
  (dispatch-rules
   [("ping") request/ping]
   [("text" "") request/main]
   [("text" "view" (integer-arg)) request/view/id]
   [("text" "view" (string-arg)) request/view/tag]
   [else request/ping]))

(serve/servlet text-dispatch
               #:port 8081
               #:listen-ip #f
               #:servlet-regexp #rx""
               #:command-line? #t
               #:extra-files-paths `("static")
               #:servlet-current-directory "./"
               )

