# So! About this...

This repo is *pretty lame*.
It's just a simple generic proyect i made using the `sketch` common lisp library, which is

> Common Lisp environment for the creation of electronic art, visual design, game prototyping, game making, computer graphics, exploration of human-computer interaction and more.

You can read a lot more in the official repo [here](https://github.com/vydd/sketch)

## Motivation

Common Lisp is a phenomenal programing language, but the ecosystem is kinda...  ***hostile***.....

So yeah, I made this so that whenever I want to make a new project I just clone this one and forget about the anoying setup

Getting this to work initially was a major pain since the CL enviroment is initialy very hard to traverse

## Let's get started

So, i've only tested this on MacOS and geting in to run was torture, but assuming you are starting from scratch just run these commands and you should be good to go.

For starters, there are MANY common lisp interpreters, but in MacOS the only one that works correcly (Due to an aparent error on `cl-sdl2`) is Clozure Common List (CCL). So to get this proyect started we have to install CCL

```bash
brew install clozure-cl
```

And for that matter, you need to use `rlwrap ccl64` to start the thing, otherwise the repl is an absolute pain since the arrows dont work

I you want to create an alias for that that, that would be pretty cool

Next let's make estra sure you have everithing required to run SDL by runing these commands

```bash
brew install sdl2
brew install sdl2_image
brew install sdl_ttf
brew install sdl2_ttf
```

Good, now we need to install quicklisp. Official installation instructions [here](https://www.quicklisp.org/beta/), but you can just run these commands:

```bash
curl -O https://beta.quicklisp.org/quicklisp.lisp
rlwrap ccl64 --load quicklisp.lisp
```

This will open the Common Lisp repl, in which you should do this:

```lisp
(quicklisp-quickstart:install)
(ql:add-to-init-file)
(ql:quickload "quicklisp-slime-helper")
(ql:update-dist "quicklisp")
(ql:update-client)
```

Now, dont close the REPL, we are going to perform a test to see if we are ready to use the library

```lisp
(ql:quickload :sketch-examples)
(make-instance 'sketch-examples:sinewave)
```

You should be seeing a working example!

### Didn't work?

If you are not seeing one try closing the repl, then opening it again and placing this:

```lisp
(ql:quickload "cffi")
(push #p"/usr/local/lib" cffi:*foreign-library-directories*)
```

Then try the commands again. If that's still not working, you will have to deal with the pain all over again
Sorry dude.

## Ok, what now?

Everything is now installed! If you want to make a minimal working example create a `main.lsp` file and write this

```lisp
(ql:quickload :sketch)

(defpackage #:myPack (:use :cl :sketch))
(in-package #:myPack)

(defsketch mySketch ())
(make-instance 'mySketch)

(defsketch mySketch ()
  (dotimes (i 10)
    (rect (* i 40) (* i 40) 40 40)))
```

You can proceed to run it with:

```bash
ccl64 --load main.lsp 
```

And there we go! Keep in mind tho that if when te program finished the REPL remains running, i'm currently unaware of a workarround for that.

## What about compilation and distribution?

I managed to compile the script into an image using this:

```lisp
(save-application "image" :init-file "./main.lsp")
```

which you can launch with

```lisp
ccl64 -I ./image
```

The thing is that, it leaves the command promp of lisp open, and you have to quit with

```lisp
(ccl:quit)
```

But you probabbly don't really care about that, what you probably want to do is create an executable

```lisp
(ccl:save-application "main" :init-file "./main.lsp" :prepend-kernel t) 
```

And to be done with the repl you could make this a single line "build" command

```bash
ccl64 --eval '(ccl:save-application "main" :init-file "./main.lsp" :prepend-kernel t) ' 
```


now you cna just run `./main` and your progrma runs!
One catch, you need to force close it by hand
I'm currently looking for  workarround for that

## That wasn't very hard at all!

As a whole these instructions don't seem hard at all, they are really straight foward. But do keep in mind that i had to learn ALL of these the hard way. I really can stress enough how much of a multi-day pain it was to set this whole thing up.

Anyways. It's done now, so have fun.

## Well f*** me then!

Aparently sketch has a few very big issues. The most important one is that, it doenst fucking close
So let's rewrite this whole thing to instead use SDL and maybe eventually turn it into something more useful
Like an actual Creative Coding library that can compete with the likes of p5js.

The good part is that everything should still be working, try this:

```lisp
(ql:quickload :sdl2/examples)
(sdl2-examples:basic-test)
```

If you see a red triangle you are good to go.

So now make a new, way chunkier main.lisp and write this:

```lisp
(ql:quickload "sdl2")
(require :sdl2)
(require :cl-opengl)

(defun main ()
  "The kitchen sink."
  (sdl2:with-init (:everything)
    (format t "Using SDL Library Version: ~D.~D.~D~%"
            sdl2-ffi:+sdl-major-version+
            sdl2-ffi:+sdl-minor-version+
            sdl2-ffi:+sdl-patchlevel+)
    (finish-output)

    (sdl2:with-window (win :flags '(:shown :opengl))
      (sdl2:with-gl-context (gl-context win)
        (let ((controllers ())
              (haptic ()))

          ;; basic window/gl setup
          (format t "Setting up window/gl.~%")
          (finish-output)
          (sdl2:gl-make-current win gl-context)
          (gl:viewport 0 0 800 600)
          (gl:matrix-mode :projection)
          (gl:ortho -2 2 -2 2 -2 2)
          (gl:matrix-mode :modelview)
          (gl:load-identity)
          (gl:clear-color 0.0 0.0 1.0 1.0)
          (gl:clear :color-buffer)

          (format t "Opening game controllers.~%")
          (finish-output)
          ;; open any game controllers
          (loop :for i :upto (- (sdl2:joystick-count) 1)
                :do (when (sdl2:game-controller-p i)
                      (format t "Found gamecontroller: ~a~%"
                              (sdl2:game-controller-name-for-index i))
                      (let* ((gc (sdl2:game-controller-open i))
                             (joy (sdl2:game-controller-get-joystick gc)))
                        (setf controllers (acons i gc controllers))
                        (when (sdl2:joystick-is-haptic-p joy)
                          (let ((h (sdl2:haptic-open-from-joystick joy)))
                            (setf haptic (acons i h haptic))
                            (sdl2:rumble-init h))))))

          ;; main loop
          (format t "Beginning main loop.~%")
          (finish-output)
          (sdl2:with-event-loop (:method :poll)
            (:keydown (:keysym keysym)
                      (let ((scancode (sdl2:scancode-value keysym))
                            (sym (sdl2:sym-value keysym))
                            (mod-value (sdl2:mod-value keysym)))
                        (cond
                          ((sdl2:scancode= scancode :scancode-w) (format t "~a~%" "WALK"))
                          ((sdl2:scancode= scancode :scancode-s) (sdl2:show-cursor))
                          ((sdl2:scancode= scancode :scancode-h) (sdl2:hide-cursor)))
                        (format t "Key sym: ~a, code: ~a, mod: ~a~%"
                                sym
                                scancode
                                mod-value)))

            (:keyup (:keysym keysym)
                    (when (sdl2:scancode= (sdl2:scancode-value keysym) :scancode-escape)
                      (sdl2:push-event :quit)))

            (:mousemotion (:x x :y y :xrel xrel :yrel yrel :state state)
                          (format t "Mouse motion abs(rel): ~a (~a), ~a (~a)~%Mouse state: ~a~%"
                                  x xrel y yrel state))

            (:controlleraxismotion
             (:which controller-id :axis axis-id :value value)
             (format t "Controller axis motion: Controller: ~a, Axis: ~a, Value: ~a~%"
                     controller-id axis-id value))

            (:controllerbuttondown (:which controller-id)
                                   (let ((h (cdr (assoc controller-id haptic))))
                                     (when h
                                       (sdl2:rumble-play h 1.0 100))))

            (:idle ()
                   (gl:clear :color-buffer)
                   (gl:begin :triangles)
                   (gl:color 1.0 0.0 0.0)
                   (gl:vertex 0.0 1.0)
                   (gl:vertex -1.0 -1.0)
                   (gl:vertex 1.0 -1.0)
                   (gl:end)
                   (gl:flush)
                   (sdl2:gl-swap-window win))

            (:quit () (progn
                ()
                (ccl:quit)
            )))

          (format t "Closing opened game controllers.~%")
          (finish-output)
          ;; close any game controllers that were opened as well as any haptics
          (loop :for (i . controller) :in controllers
                :do (sdl2:game-controller-close controller)
                    (sdl2:haptic-close (cdr (assoc i haptic)))))))))
(main)
```

And there you go! You can tell that with that last line we are calling the main function direcly, we'll get back to that later.

But anyways, now, how do we run this bad boy? Try this:

```bash
ccl64 -l main.lisp
```

And how could I compile it to a `./main` executable?

```bash
ccl64 --eval '(ccl:save-application "main" :init-file "./main.lisp" :prepend-kernel t) ' 
```

And now when you run `./main`, it works like a charm! And closes perfectly

So we've got

```bash
#Run
ccl64 --eval "./main.lisp" 

#Compile
ccl64 --eval '(ccl:save-application "main" :init-file "./main.lisp" :prepend-kernel t) ' 

#Compile and Run
ccl64 --eval '(ccl:save-application "main" :init-file "./main.lisp" :prepend-kernel t) '  && ./main  
```

So yeah! Finally we hace something pretty nice!

And after that i structured the proyect even better so that i can also make my own library module. Which makes the entire process of writting the actual code a LOOOOT easier

Now i don't have to worry at all about SDL itself. Everything just works and it's abstracted away. We basicaly have a function called setup and a function called draw, and both of tem get passed to a function called run. Run will first create a configuration object with the default configuration values, and pass that as an argument to setup. Setup will then modify that configuration object with functions from quicle to set the paramters as desiered. Then, it will setup the screen and start the mainloop. Finaly, on every iteration of the mainloop, the function draw will be called. The function draw is givien the drawing contexts as an argument. So that it can paint onto it on every loop iteration. This loop will continue untill the program is terminated.

To organize this proyect, tho, i moved everything to a folder called src. So the commands have to be changed acordingly:

```bash
#Run
ccl64 --eval "./src/main.lisp" 
```

Compilation aparently would not work because, despite the program beign already compiled, this fucking thing is still looking for quicle.lisp in the wrong place. I'm pretty sure that will only change when i properly set up ASDF. which is not going to happen yet. So currently i'm only able to run. Nop, not even. Looks like i need to compile direcly on the src folder, which is absolutely awful, but idk. Use this

```bash
ccl64 --eval '(ccl:save-application "temp" :init-file "./main.lisp" :prepend-kernel t) ' && ./temp && rm ./temp      
```

# Oops. a library now

I changed the entire project structure to use ASDF and i now have the library working!
I changed the location of things so that our "Game" is actually the exampel
The library is not compatible with SBCL and CCL64. In both of them you can go direcly to the example folder, start the interpreter and do "(load sketch.lisp)" and be done with it. In any case this is very very close to beign ready to deploy to GitHub. And after that point our focus would be to make example an actual example. Make another exampel (Maybe on is a game, hte other is mandelbrot) then make those examples part of the package (And runable) á la (cl-sdl2) then learn how we could compile one of those examples to an executable that does not depend

```bash
rlwrap ccl64 -l sketch.lisp 
```

```bash
rlwrap sbcl --load sketch.lisp    
```

It's also important to add a way to handle input from the mouse nad the keyboard

Anyways, as of now, on compilation, and i will make sence out of all this mess at some point. Surely i will

I wish to implement something in sketch that has to do with the cursor and i will concider this an absolute success. I i could just detect keystrokes and mouse i would be static 

Mejora todo un poco
Mejora la forma en la que estamos manejando las teclas (Inspirate en processing)
Mejora la documentaicion
Funcion para dibujar circulos:

https://stackoverflow.com/questions/38334081/howto-draw-circles-arcs-and-vector-graphics-in-sdl

## TODO

[ ] - Reformat this whole file so that it's no longer a documentation of my trial an errors, but instead a easy to read walktrough.
[ ] - Add a makefile
[ ] - Add more useful functions to the current library (We'll probably need to extend the ctx object to, aditionally to the inclution of the render, it also includes the transformation matrix and so on)
[ ] - Add error handling so that you dont go into the debugger on production
[ ] - Make use of the Common Lisp type system for better security and ease of use.
[ ] - Add the hability to handle user input.