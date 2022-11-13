(defpackage :quicle (:use :cl))
(in-package :quicle)

(defun line (renderer x1 y1 x2 y2)
  (sdl2:render-draw-line renderer x1 y1 x2 y2) )

(defun background (renderer r g b a)
  (sdl2:set-render-draw-color renderer r g b a)
  (sdl2:render-clear renderer) )

(defun color(ctx r g b a)
  (sdl2:set-render-draw-color ctx r g b a) )

(defun rect (renderer x y w h)
  (sdl2:render-fill-rect renderer (sdl2:make-rect x y w h)))

(defun box (renderer x y w h)
  (sdl2:render-draw-rect renderer (sdl2:make-rect x y w h)))

(defun pixel (ctx x y) 
  (line ctx x y x y))
