(defpackage :sketch (:use :cl))
(in-package :sketch )

(require "asdf")
(asdf:load-system "quicle")



(defun setup (cfg)
  (quicle::setWidth     cfg 600)
  (quicle::setHeight    cfg 600)
  (quicle::setFramerate cfg 30)
  (quicle::setTitle     cfg "Program Window Hello") 
  )

(defvar cursorPositionX 0)
(defvar cursorPositionY 0)

(defvar boxPositionX 100)
(defvar boxPositionY 445)

(defun moveright () (setf boxPositionX (+ boxPositionX 10)))
(defun moveleft  () (setf boxPositionX (- boxPositionX 10)))
(defun moveup    () (setf boxPositionY (- boxPositionY 10)))
(defun movedown  () (setf boxPositionY (+ boxPositionY 10)))

(defun draw (ctx) 
  (quicle::background ctx 0 0 0 255)


  ; Render cursor
  (quicle::color  ctx 0 255 0 255)
  (quicle::box    ctx (- cursorPositionX 10) (- cursorPositionY 10) 10 10)

  (quicle::color      ctx 255 0 0 255)
  (quicle::line       ctx 20 20 20 100)
  (quicle::line       ctx 300 20 300 100)
  (quicle::box        ctx 445 400 35 35)
  (quicle::color      ctx 0 0 255 255)
  (quicle::rect       ctx boxPositionX boxPositionY 35 35)    
  (quicle::color      ctx 255 255 255 255)
  (quicle::pixel      ctx (random 600) (random 600))
  (quicle::pixel      ctx (random 600) (random 600))
  (quicle::pixel      ctx (random 600) (random 600))
  (quicle::pixel      ctx (random 600) (random 600))
  )


(defun mouse (ctx mx my mstate)
    (setf cursorPositionX mx)
    (setf cursorPositionY my)
)


; Definitivamente tenemos que hacer "Hice cursor" un flag del objecto config
(defun keys (ctx keysym)
  (let (
    (scancode  (sdl2:scancode-value keysym))
    (sym       (sdl2:sym-value      keysym))
    (mod-value (sdl2:mod-value      keysym))
    )
    (cond
      ((sdl2:scancode= scancode :scancode-w) (moveup   ) )
      ((sdl2:scancode= scancode :scancode-a) (moveleft ) )
      ((sdl2:scancode= scancode :scancode-s) (movedown ) )
      ((sdl2:scancode= scancode :scancode-d) (moveright) )

      ((sdl2:scancode= scancode :scancode-h) (sdl2:hide-cursor)))

    (format t "Key sym: ~a, code: ~a, mod: ~a~%"
            sym
            scancode
            mod-value))
)

(defun main ()
  (quicle::run #'setup #'draw #'mouse #'keys)
)



(main)
