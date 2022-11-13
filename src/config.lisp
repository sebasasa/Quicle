(defpackage :quicle (:use :cl))
(in-package :quicle)

; This  is my poor attempt at implementing an object to hold my  
; canvas  configurations.  I  desperately  need to improve this
; using the actual features of common lisp. But in the meantime
; It actually works quite nicely

(defvar width 600) 
(defvar height 600) 
(defvar title "Quicle")
(defvar delay 33)

(defun createConfig () (list
    width
    height
    title 
    delay))

(defun set-nth (l n value)
  (setf (nth n l) value)
  l )

(defun getWidth  (config) (nth 0 config))
(defun getHeight (config) (nth 1 config))
(defun getTitle  (config) (nth 2 config))
(defun getDelay  (config) (nth 3 config))

(defun setWidth  (config value) (set-nth config 0 value) config)
(defun setHeight (config value) (set-nth config 1 value) config)
(defun setTitle  (config value) (set-nth config 2 value) config)
(defun setDelay  (config value) (set-nth config 3 value) config)

;Delay is the time (in ms) we wait after rendering each frame
;It's usualy easier to thing about Framerate (Frames per second)
;So this funcition allow  us to set the delay by speciphying fps 

(defun setFramerate  (config value) (setDelay config (round (/ 1000 value))))
