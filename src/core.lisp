(defpackage :quicle (:use :cl))
(in-package :quicle)

; I'm not sure whather this is 
; requiered here or not, but i 
; think  i'll  rather leave it 
; there just in case ↓

(ql:quickload "sdl2")
(require :sdl2)
(require :cl-opengl)


; Here we define the setup functions 
; to  actually create the canvas and
; start the mainloop


(defun fullquit ()
  #+sbcl    (sb-ext:quit)
  #+ccl     (ccl:quit)
  ; #+clisp   (ext:exit)
)

(defun closeOnEsc (keysym) 
  (when (sdl2:scancode= (sdl2:scancode-value keysym) :scancode-escape)
             (sdl2:push-event :quit))
)



(defun mouseDown (state) (if (= state 1) T NIL))

(defparameter nomouse (lambda (ctx mx my state) nil))
(defparameter nokeys (lambda (ctx key) nil))

(defun mainloop (config drawFunc mouseFunc keyFunc)
  (sdl2:with-init (:everything)
    (sdl2:with-window (win :title (getTitle config) :w (getWidth config) :h (getHeight config) :flags '(:shown))
      (sdl2:with-renderer (renderer win :flags '(:accelerated))
        (sdl2:with-event-loop (:method :poll)
          
          (:keyup (:keysym keysym)
             (closeOnEsc keysym)
             (funcall keyFunc renderer keysym)
             )
        
          (:idle ()
            (funcall drawFunc renderer)
            (sdl2:render-present renderer)
	          (sdl2:delay (getDelay config))
            )


          (:mousemotion (:x x :y y :xrel xrel :yrel yrel :state state)
            (funcall mouseFunc renderer x y state)
            )

      
          (:quit () 
            (format t "Terminating quicle sketch window...")
            (fullquit)
            )

          )))))

(defun run (setupFunc drawFunc mouseFunc keyFunc)
  ;This is the function that actually runs the main loop
  ;SBCL has problems on MacOS. Son on that compiler the actual initialization is a little diferent
  ;You can read a little bit more about that in the docuemntation for (cl-sdl2)
  #-sbcl (quicle::mainloop (funcall setupFunc (quicle::createConfig)) drawFunc mouseFunc keyFunc) 
  #+sbcl (sdl2:make-this-thread-main (lambda () 
      (quicle::mainloop (funcall setupFunc (quicle::createConfig)) drawFunc mouseFunc keyFunc) 
      ))
    )