;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname HtDP_2e_Exercise_41) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
; Exercise 41. Finish the sample problem and get the program to run.
; That is, assuming that you have solved exercise 39, define the constants BACKGROUND and Y-CAR.
; Then assemble all the function definitions, including their tests.

; When your program runs to your satisfaction, add a tree to the scenery. We used
; (define tree
;   (underlay/xy (circle 10 "solid" "green")
;               9 15
;                (rectangle 2 20 "solid" "brown")))
;
; to create a tree-like shape.

; Also add a clause to the big-bang expression that stops the animation
; when the car has disappeared on the right side.

(require 2htdp/universe)
(require 2htdp/image)

; "PHYSICAL" CONSTANTS

(define WHEEL-RADIUS 30)                    ;this is the single point of control
(define WHEEL-DISTANCE (* WHEEL-RADIUS 2))
(define Y-CAR (* WHEEL-RADIUS 3))
(define ROAD-LENGTH (* 7 (* WHEEL-RADIUS 8)))
(define SCENE-HEIGHT (* WHEEL-RADIUS 5))


; GRAPHICAL CONSTANTS


(define WHEEL                                                         
  (circle WHEEL-RADIUS "solid" "black"))    
(define SPACE                             
  (rectangle WHEEL-DISTANCE (/ WHEEL-RADIUS 8) "solid" "white")) ;divided by 8 to make bottom more flush
(define BOTH-WHEELS                       
  (beside WHEEL SPACE WHEEL))

(define CHASSIS
  (above
   (rectangle (* WHEEL-DISTANCE 2) WHEEL-RADIUS "solid" "red")
   (rectangle (* WHEEL-DISTANCE 4) (* WHEEL-RADIUS 2) "solid" "red")))

; CAR is a computed constant comprised of WHEEL and CHASSIS
(define CAR
  (overlay/align/offset "middle" "bottom"
                        BOTH-WHEELS
                        0 (* WHEEL-RADIUS -1)
                        CHASSIS))

(define BACKGROUND
  (empty-scene ROAD-LENGTH SCENE-HEIGHT))

(define TREE
  (underlay/xy (circle WHEEL-RADIUS "solid" "green")
               (- WHEEL-RADIUS 1) (* WHEEL-RADIUS 1.5)
               (rectangle (/ WHEEL-RADIUS 5) (* WHEEL-RADIUS 2) "solid" "brown")))
; I re-wrote the code for tree given in text in terms of WHEEL-RADIUS so that
; tree scales with the point of control, WHEEL-RADIUS.

(define BACKGROUND-TREE
  (place-image TREE (* .75 ROAD-LENGTH) (- SCENE-HEIGHT (/ (image-height TREE) 2)) BACKGROUND))
; Given constant definition supplied by text, -32.5 to account for total height of TREE at 35 pixels
; and the fact that place-image calculates from center of image.
; Thus, you substract 17.5 from SCENE-HEIGHT since y axis increases
; positively as you go downward.

; A WorldState is a Number.
;; interpretation: the number of pixels between the left border of the scene
;; and the car.
; interpretation: the number of pixels between the e

; WISH LIST

;;;render  
; WorldState --> Image
; places the image of the car in the BACKGROUND 
; according to the given world state
(check-expect (render 50) (place-image CAR 50 Y-CAR BACKGROUND-TREE))
(check-expect (render 200) (place-image CAR 200 Y-CAR BACKGROUND-TREE))
(define (render ws)
  (place-image CAR ws Y-CAR BACKGROUND-TREE))

;    BACKGROUND)

;;;clock-tick-handler
; WorldState --> WorldState
; moves the car by 3 pixels for every clock tick
(check-expect (tock 20) 23)
(check-expect (tock 78) 81)
(define (tock ws)
  (+ ws 3))

;;;end?
; WorldState --> Boolean
; ends the world when CAR has travelled ROAD-LENGTH
(check-expect (last-world? 0) false);testing the extreme
(check-expect (last-world? 300) false);testing a middle point
(check-expect (last-world? (+ ROAD-LENGTH (* 4 WHEEL-DISTANCE))) true);testing for desired outcome
(define (last-world? ws)
 (> (tock ws) (+ ROAD-LENGTH (* 4 WHEEL-DISTANCE))))
; I needed to account for the fact that the place-image works from
; the center of the image. Therefore, I needed to take into account the
; fact that the car still needs to travel one half car length before it
; disappears completely off the right side of the scene.


;;;main
; WorldState --> WorldState
; launches the world with car on left side of background
(define (main ws)
  (big-bang ws
    [on-tick tock]
    [to-draw render]
    [stop-when last-world?]))




