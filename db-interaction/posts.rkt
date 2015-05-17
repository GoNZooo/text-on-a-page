#lang racket/base

(require racket/contract
         racket/match

         db/base
         db/postgresql
         db/util/postgresql

         "post-struct.rkt"
         "credentials.rkt")

(provide db-conn
         posts/get
         posts/get/tag
         posts/insert
         post-date->string)

(define db-conn
  (virtual-connection
    (connection-pool
      (lambda ()
        (postgresql-connect #:server db-location
                            #:database db-name
                            #:user db-user
                            #:password db-password)))))

(define/contract (vector-post->post vp)
    (vector? . -> . post?)

    (match vp
      [(vector id tags title body timestamp)
       (post id
             (pg-array->list tags)
             title body (date (sql-timestamp-second timestamp)
                              (sql-timestamp-minute timestamp)
                              (sql-timestamp-hour timestamp)
                              (sql-timestamp-day timestamp)
                              (sql-timestamp-month timestamp)
                              (sql-timestamp-year timestamp)
                              0 0 #f 2))]))

(define/contract (posts/get)
  (-> (listof post?))

  (map vector-post->post
       (query-rows db-conn
                   "SELECT * FROM post;")))

(define/contract (posts/get/tag tag)
  (string? . -> . (listof post?))
  
  (map vector-post->post
       (query-rows db-conn
                   "SELECT * FROM post WHERE tags && ARRAY[$1];"
                   tag)))

(define/contract (posts/insert ip)
  (post? . -> . void?)

  (query-exec db-conn
              "INSERT INTO post (tags, title, body) VALUES ($1, $2, $3);"
              (list->pg-array (post-tags ip))
              (post-title ip)
              (post-body ip)))

(define/contract (post-date->string d)
  (date? . -> . string?)

  (define (pad x)
    (if (< x 10)
      (format "0~a" x)
      x))
  
  (format "~a-~a-~a ~a:~a"
          (date-year d)
          (pad (date-month d))
          (pad (date-day d))
          (pad (date-hour d))
          (pad (date-minute d))))

(module+ main
  (require racket/pretty)
  ;(posts/insert (post 0 '("mania" "craze") "This is crazy!" "The body is smaaaaaall" #f)))
  (pretty-print (posts/get)))
  ;(pretty-print (posts/get/tag "random"))
  ;(pretty-print (posts/get/tag "excitement")))