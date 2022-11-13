(defsystem #:quicle
  :description "A 'Creative Coding' library for Common Lisp insired by Processing. Built on top of cl-sdl2"
  :author "Sebastian Gudiño <sebastiancaracas1@gmail.com>"
  :license "MIT"
  :pathname "src"
  :depends-on (:sdl2 :cl-opengl)
  :components (
    (:file "core")
    (:file "config")
    (:file "drawing")
  )
)