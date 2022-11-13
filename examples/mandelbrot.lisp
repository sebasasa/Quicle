(defpackage :sketch (:use :cl))
(in-package :sketch )

(require "asdf")
(asdf:load-system "quicle")

; Esta dependnecia es innecesarioa, tenemos que aprender a ahcer bien los loops
; Para qeu podamos loopear los pixeles sin tener que hacer esto
; La propia funcion mandel NO hace uso de nada de esto
(ql:quickload "iterate")
(use-package :iterate)

; This should go to the library, to a file called utils
(defun maprange (value istart istop ostart ostop)
    (+ ostart (* 
        (- ostop ostart)
        (/ (- value istart) (- istop istart))
        )))

(defun mandel (cx cy maxiter)   
     (loop with c = (complex cx cy)
        for iteration from 0 below maxiter
        for z = c then (+ (* z z) c)
        while (< (abs z) 2)
        finally (if (= iteration maxiter)
            (return 0)
            ;Esta linea de aqui abajo podemos optimizarla un poco
            (return (- 255 (round (* 255 (/ (- maxiter iteration) maxiter)))))
            ))
)

; We could add here a method for quicle::setDraw once
(defvar width  350)
(defvar height 350)
(defun setup (cfg)
    (quicle::setWidth     cfg width)
    (quicle::setHeight    cfg height)
    (quicle::setTitle     cfg "Mandelbrot") 
    (quicle::setDelay     cfg 100)
    )

(defun draw (ctx) 
    (quicle::background ctx 0 0 0 255)
    (iter (for i from 0 to width)
        (iter (for j from 0 to height)
            (let ((tempcol (mandel 
                (maprange i 0 width (- 2)   1   ) 
                (maprange j 0 height (- 1.5) 1.5 ) 
                15)))
            (quicle::color  ctx tempcol tempcol tempcol 255)
            (quicle::pixel  ctx i j)
        ))
    ))


(defun main ()
    (quicle::run 
        #'setup 
        #'draw
        quicle::nomouse
        quicle::nokeys
        ))

(main)
