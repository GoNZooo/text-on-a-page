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
         posts/get/id
         posts/insert
         posts/remove/id
         posts/remove/tag
         post-date->string
         posts/edit/full/id
         posts/edit/tags/id
         posts/edit/body/id
         posts/edit/title/id
         )

(define db-conn
  (virtual-connection
   (connection-pool
    (lambda ()
      (postgresql-connect #:server db-location
                          #:database db-name
                          #:user db-user
                          #:password db-password)))))

(define/contract (vector-post->post vp)
  ((or/c vector? boolean?) . -> . (or/c post? boolean?))

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
                            0 0 #f 2))]
    [_ #f]))

(define/contract (posts/get #:database-connection [dbc db-conn])
  (() (#:database-connection connection?) . ->* . (listof post?))

  (map vector-post->post
       (query-rows dbc
                   "SELECT * FROM post;")))

(define/contract (posts/get/tag tag #:database-connection [dbc db-conn])
  ((string?)
   (#:database-connection connection?) . ->* . (listof post?))

  (map vector-post->post
       (query-rows dbc
                   "SELECT * FROM post WHERE tags && ARRAY[$1];"
                   tag)))

(define/contract (posts/get/id id #:database-connection
                               [dbc db-conn])
  ((real?) (#:database-connection
            connection?) . ->* . (or/c post? boolean?))

  (vector-post->post (query-maybe-row dbc
                                      "SELECT * FROM post WHERE id = $1;"
                                      id)))

(define/contract (posts/insert ip #:database-connection
                               [dbc db-conn])
  ((post?) (#:database-connection
            connection?) . ->* . void?)

  (query-exec dbc
              "INSERT INTO post (tags, title, body) VALUES ($1, $2, $3);"
              (list->pg-array (post-tags ip))
              (post-title ip)
              (post-body ip)))

(define/contract (posts/remove/id id #:database-connection
                                  [dbc db-conn])
  ((real?)  (#:database-connection
             connection?) . ->* . void?)

  (query-exec dbc
              "DELETE FROM post WHERE id = $1;"
              id))

(define/contract (posts/remove/tag tag #:database-connection
                                   [dbc db-conn])
  ((string?) (#:database-connection connection?) . ->* . void?)

  (query-exec dbc
              "DELETE FROM post WHERE tag = $1;"
              tag))

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

(define/contract (posts/edit/full/id id tags title body #:database-connection
                                     [dbc db-conn])
  ((real? (listof string?) string? string?)
   (#:database-connection connection?) . ->* . void?)

  (query-exec dbc
              "UPDATE post SET tags = $1, title = $2, body = $3 WHERE id = $4;"
              (list->pg-array tags)
              title
              body
              id))

(define/contract (posts/edit/title/id id title #:database-connection
                                      [dbc db-conn])
  ((real? string?)
   (#:database-connection connection?) . ->* . void?)

  (query-exec dbc
              "UPDATE post SET title = $1 WHERE id = $2;"
              title
              id))

(define/contract (posts/edit/body/id id body #:database-connection
                                     [dbc db-conn])
  ((real? string?)
   (#:database-connection connection?) . ->* . void?)

  (query-exec dbc
              "UPDATE post SET body = $1 WHERE id = $2;"
              body
              id))

(define/contract (posts/edit/tags/id id tags #:database-connection
                                     [dbc db-conn])
  ((real? (listof string?))
   (#:database-connection connection?) . ->* . void?)

  (query-exec dbc
              "UPDATE post SET tags = $1 WHERE id = $2;"
              tags
              id))

(module+ main
  (require racket/pretty)
  (for-each
   posts/remove/id
   '(6)))
