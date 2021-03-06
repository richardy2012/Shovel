;; Copyright (c) 2012, Miron Brezuleanu
;; All rights reserved.

;; Redistribution and use in source and binary forms, with or without
;; modification, are permitted provided that the following conditions are met:
;;     * Redistributions of source code must retain the above copyright
;;       notice, this list of conditions and the following disclaimer.
;;     * Redistributions in binary form must reproduce the above copyright
;;       notice, this list of conditions and the following disclaimer in the
;;       documentation and/or other materials provided with the distribution.

;; THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
;; ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
;; WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
;; DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
;; DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
;; (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
;; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
;; ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
;; (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
;; SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

(in-package #:shovel-tests)

(def-suite :shovel-tests)

(in-suite :shovel-tests)

(test test-constants
  (is (= 1 (shovel:naked-run-code (list "1"))))
  (is (string= "a" (shovel:naked-run-code (list "'a'"))))
  (is (= 1.23 (shovel:naked-run-code (list "1.23")))))

(test some-operators
  (is (= 2 (shovel:naked-run-code (list "1 + 1")))))

(test complex
  (is (equalp #(1 2 3 3 4 5)
              (shovel:naked-run-code
               (list (shovel:stdlib)
                     "stdlib.sort(array(3, 1, 2, 5, 4, 3), fn (a, b) a < b)")))))

(test tokenizer-error-message
  (is (string= (with-output-to-string (str)
                 (let ((*standard-output* str))
                   (shovel:run-code
                    (list (shovel:stdlib)
                          (shovel:make-source-file :name "test.sho"
                                                   :contents "
var g = fn x x + 2
var f = fn x g(x) + 2
f('1")))))
               "Shovel error in file 'test.sho' at end of file: Expected an end quote, but reached the end of file.

"))
  (is (string= (with-output-to-string (str)
                 (let ((*standard-output* str))
                   (shovel:run-code
                    (list (shovel:stdlib)
                          (shovel:make-source-file :name "test.sho"
                                                   :contents "
var g = fn #x x + 2
var f = fn x g(x) + 2
f('1')")))))
               "Shovel error in file 'test.sho' at line 2, column 12: Unexpected character '#'.
file 'test.sho' line 2: var g = fn #x x + 2
file 'test.sho' line 2:            ^

")))

(test parser-error-message
  (is (string= (with-output-to-string (str)
                 (let ((*standard-output* str))
                   (shovel:run-code
                    (list (shovel:stdlib)
                          (shovel:make-source-file :name "test.sho"
                                                   :contents "
b(]
")))))
               "Shovel error in file 'test.sho' at line 2, column 3: Unexpected token ']'.
file 'test.sho' line 2: b(]
file 'test.sho' line 2:   ^

"))
  (is (string= (with-output-to-string (str)
                 (let ((*standard-output* str))
                   (shovel:run-code
                    (list (shovel:stdlib)
                          (shovel:make-source-file :name "test.sho"
                                                   :contents "
var a = fn [x] 1
")))))
               "Shovel error in file 'test.sho' at line 2, column 12: Expected a identifier, but got '['.
file 'test.sho' line 2: var a = fn [x] 1
file 'test.sho' line 2:            ^

"))
  (is (string= (with-output-to-string (str)
                 (let ((*standard-output* str))
                   (shovel:run-code
                    (list (shovel:stdlib)
                          (shovel:make-source-file :name "test.sho"
                                                   :contents "
var fn = 1
")))))
               "Shovel error in file 'test.sho' at line 2, column 5: Expected a identifier, but got 'fn'.
file 'test.sho' line 2: var fn = 1
file 'test.sho' line 2:     ^^

"))
  (is (string= (with-output-to-string (str)
                 (let ((*standard-output* str))
                   (shovel:run-code
                    (list (shovel:stdlib)
                          (shovel:make-source-file :name "test.sho"
                                                   :contents "
var slice = 1
")))))
               "Shovel error in file 'test.sho' at line 2, column 5: Name 'slice' is reserved for a primitive.
file 'test.sho' line 2: var slice = 1
file 'test.sho' line 2:     ^^^^^

")))

(test code-generator-error-message
  (is (string= (with-output-to-string (str)
                 (let ((*standard-output* str))
                   (shovel:run-code
                    (list (shovel:stdlib)
                          (shovel:make-source-file :name "test.sho"
                                                   :contents "
var a = 1
var a = 2")))))
               "Shovel error in file 'test.sho' at line 3, column 5: Variable 'a' is already defined in this frame in file '\"test.sho\"', at line 2, column 5.
file 'test.sho' line 3: var a = 2
file 'test.sho' line 3:     ^

"))
  (is (string= (with-output-to-string (str)
                 (let ((*standard-output* str))
                   (shovel:run-code
                    (list (shovel:stdlib)
                          (shovel:make-source-file :name "test.sho"
                                                   :contents "
b = 3
")))))
               "Shovel error in file 'test.sho' at line 2, column 1: Undefined variable 'b'.
file 'test.sho' line 2: b = 3
file 'test.sho' line 2: ^^^^^

"))
  (is (string= (with-output-to-string (str)
                 (let ((*standard-output* str))
                   (shovel:run-code
                    (list (shovel:stdlib)
                          (shovel:make-source-file :name "test.sho"
                                                   :contents "
b + 1
")))))
               "Shovel error in file 'test.sho' at line 2, column 1: Undefined variable 'b'.
file 'test.sho' line 2: b + 1
file 'test.sho' line 2: ^

")))

(test vm-error-message
  (is (string= (process (with-output-to-string (str)
                          (let ((*standard-output* str))
                            (shovel:run-code
                             (list (shovel:stdlib)
                                   (shovel:make-source-file :name "test.sho"
                                                            :contents "
var g = fn x x + 2
var f = fn x g(x) + 2
f('1')"))))))
               "Shovel error in file 'test.sho' at line 2, column 14: Arguments must have the same type (numbers or strings or arrays).

Current stack trace:
file 'test.sho' line 2: var g = fn x x + 2
file 'test.sho' line 2:              ^^^^^
file 'test.sho' line 3: var f = fn x g(x) + 2
file 'test.sho' line 3:              ^^^^
file 'test.sho' line 4: f('1')
file 'test.sho' line 4: ^^^^^^

Current environment:

Frame starts at:
file 'test.sho' line 2: var g = fn x x + 2
file 'test.sho' line 2:            ^
Frame variables are:
x = \"1\"

Frame starts at:
file 'stdlib.sho' line 2: var stdlib = { [...content snipped...]
file 'stdlib.sho' line 2: ^^^^^^^^^^^^^^
Frame variables are:
stdlib = hash
g = [...callable...]
f = [...callable...]



")))

(test code-printer
  (is (string= (with-output-to-string (str)
                 (let ((*standard-output* str))
                   (shovel:print-code (list "var a = 1
var b = 2
var c = fn (x, y) x + y"))))
               "    VM-VERSION 1

    VM-SOURCES-MD5 352CC9384F33B7778F01A32F66438B39

    VM-BYTECODE-MD5 ?

    FILE-NAME <unspecified-1>

    ; file '<unspecified-1>' line 1: var a = 1 [...content snipped...]
    ; file '<unspecified-1>' line 1: ^^^^^^^^^
    NEW-FRAME a, b, c

    ; file '<unspecified-1>' line 1: var a = 1
    ; file '<unspecified-1>' line 1:         ^
    CONST 1

    ; file '<unspecified-1>' line 1: var a = 1
    ; file '<unspecified-1>' line 1: ^^^^^^^^^
    LSET 0, 0

    POP

    ; file '<unspecified-1>' line 2: var b = 2
    ; file '<unspecified-1>' line 2:         ^
    CONST 2

    ; file '<unspecified-1>' line 2: var b = 2
    ; file '<unspecified-1>' line 2: ^^^^^^^^^
    LSET 0, 1

    POP

    JUMP L2

    ; file '<unspecified-1>' line 3: var c = fn (x, y) x + y
    ; file '<unspecified-1>' line 3:         ^^^^^^^^^^^^^^^
FN1:

    ; file '<unspecified-1>' line 3: var c = fn (x, y) x + y
    ; file '<unspecified-1>' line 3:             ^^^^
    NEW-FRAME x, y

    ARGS 2

    ; file '<unspecified-1>' line 3: var c = fn (x, y) x + y
    ; file '<unspecified-1>' line 3:                   ^
    LGET 0, 0

    ; file '<unspecified-1>' line 3: var c = fn (x, y) x + y
    ; file '<unspecified-1>' line 3:                       ^
    LGET 0, 1

    ; file '<unspecified-1>' line 3: var c = fn (x, y) x + y
    ; file '<unspecified-1>' line 3:                     ^
    PRIM0 +

    ; file '<unspecified-1>' line 3: var c = fn (x, y) x + y
    ; file '<unspecified-1>' line 3:                   ^^^^^
    CALLJ 2

L2:
    FN FN1, 2

    ; file '<unspecified-1>' line 3: var c = fn (x, y) x + y
    ; file '<unspecified-1>' line 3: ^^^^^^^^^^^^^^^^^^^^^^^
    LSET 0, 2

    DROP-FRAME

NIL
")))

(test bytecode-serializer
  (let* ((instructions (shovel:get-bytecode (list (shovel:stdlib))))
         (serialized-instructions (shovel:serialize-bytecode instructions))
         (deserialized-instructions (shovel:deserialize-bytecode
                                     serialized-instructions)))
    (is (equalp instructions deserialized-instructions))))

(defun test-serializer (program user-primitives)
  (let* ((sources (list (shovel:stdlib)
                        program))
         (bytecode (shovel:get-bytecode sources)))
    (multiple-value-bind (first-run vm)
        (run-vm
         bytecode
         :sources sources
         :user-primitives user-primitives)
      (declare (ignore first-run))
      (let* ((bytes (serialize-vm-state vm))
             (second-run (run-vm
                          bytecode
                          :sources sources
                          :user-primitives user-primitives
                          :state bytes)))
        second-run))))

(test vm-serializer-1
  (let (flag)
    (labels ((halt ()
               (cond ((not flag)
                      (setf flag t)
                      (values :null :nap-and-retry-on-wake-up))
                     (t "It works!"))))
      (let* ((my-program "@halt()")
             (user-primitives (list (list "halt" #'halt 0))))
        (is (string= (test-serializer my-program user-primitives) "It works!"))))))

(test vm-serializer-2
  (let (flag)
    (labels ((halt (a b c)
               (cond ((not flag)
                      (setf flag t)
                      (values :null :nap))
                     (t (+ a b c)))))
      (let* ((my-program "
var a = 1
var b = 2
var c = 3
var d = fn () {
  @halt(a, b, c)
}
d()
c = 4
@halt(a, b, c)
")
             (user-primitives (list (list "halt" #'halt 3))))
        (is (= (test-serializer my-program user-primitives) 7))))))

(test vm-serializer-3
  (let (flag)
    (labels ((halt (name age)
               (cond ((not flag)
                      (setf flag t)
                      (values :null :nap-and-retry-on-wake-up))
                     (t (format nil "~a is ~d years old." name age)))))
      (let* ((my-program "
var person = fn (name, age) {
  var this = hash('name', name, 'age', age)
  this.print = fn () { @halt(this.name, this.age) }
  this
}
var makeFamily = fn () {
  var names = array('John', 'Jane', 'Andrew')
  var ages = array(22, 23, 2)
  var makePerson = fn (x) {
    person(names[x], ages[x]).print()
  }
  array(makePerson(0), makePerson(1), makePerson(2))
}
var family = makeFamily()
")
             (user-primitives (list (list "halt" #'halt 2))))
        (is (equalp (test-serializer my-program user-primitives)
                    #("John is 22 years old."
                      "Jane is 23 years old."
                      "Andrew is 2 years old.")))))))

(defun process (str)
  (let* ((lines (split-sequence:split-sequence #\newline str))
         (processed-lines (mapcar
                           (lambda (line)
                             (if (alexandria:starts-with-subseq "stdlib = hash"
                                                                line)
                                 "stdlib = hash"
                                 line)) lines)))
    (format nil "~{~a~^~%~}" processed-lines)))

(test array-boundaries
  (is (string= (process (with-output-to-string (str)
                          (let ((*standard-output* str))
                            (shovel:run-code
                             (list (shovel:stdlib)
                                   (shovel:make-source-file :name "test.sho"
                                                            :contents "
var a = arrayN(10)
a[10] = 1
"))))))
               "Shovel error in file 'test.sho' at line 3, column 1: Invalid 0-based index (10 for an array with 10 elements).

Current stack trace:
file 'test.sho' line 3: a[10] = 1
file 'test.sho' line 3: ^^^^^^^^^

Current environment:

Frame starts at:
file 'stdlib.sho' line 2: var stdlib = { [...content snipped...]
file 'stdlib.sho' line 2: ^^^^^^^^^^^^^^
Frame variables are:
stdlib = hash
a = array(null, null, null, null, null, null, null, null, null, null)



"))
  (is (string= (process (with-output-to-string (str)
                          (let ((*standard-output* str))
                            (shovel:run-code
                             (list (shovel:stdlib)
                                   (shovel:make-source-file :name "test.sho"
                                                            :contents "
var a = arrayN(10)
a[-1] = 1
"))))))
               "Shovel error in file 'test.sho' at line 3, column 1: Index less than 0.

Current stack trace:
file 'test.sho' line 3: a[-1] = 1
file 'test.sho' line 3: ^^^^^^^^^

Current environment:

Frame starts at:
file 'stdlib.sho' line 2: var stdlib = { [...content snipped...]
file 'stdlib.sho' line 2: ^^^^^^^^^^^^^^
Frame variables are:
stdlib = hash
a = array(null, null, null, null, null, null, null, null, null, null)



")))

(test array-push
  (is (string= (with-output-to-string (str)
                 (let ((*standard-output* str))
                   (shovel:run-code
                    (list (shovel:stdlib)
                          (shovel:make-source-file :name "test.sho"
                                                   :contents "
var a = array()
push(a, 1)
push(a, 2)
push(a, 3)
a
")))))
               "#(1 2 3)
"))
  (is (string= (process (with-output-to-string (str)
                          (let ((*standard-output* str))
                            (shovel:run-code
                             (list (shovel:stdlib)
                                   (shovel:make-source-file :name "test.sho"
                                                            :contents "
var a = 1
push(a, 1)
"))))))
               "Shovel error in file 'test.sho' at line 3, column 1: First argument must be a vector.

Current stack trace:
file 'test.sho' line 3: push(a, 1)
file 'test.sho' line 3: ^^^^^^^^^^

Current environment:

Frame starts at:
file 'stdlib.sho' line 2: var stdlib = {
file 'stdlib.sho' line 2: ^^^^^^^^^
Frame variables are:
stdlib = hash
a = 1



")))

(test array-pop
  (is (string= (with-output-to-string (str)
                 (let ((*standard-output* str))
                   (shovel:run-code
                    (list (shovel:stdlib)
                          (shovel:make-source-file :name "test.sho"
                                                   :contents "
var a = array(1, 2, 3)
pop(a)
")))))
               "3
"))
  (is (string= (with-output-to-string (str)
                 (let ((*standard-output* str))
                   (shovel:run-code
                    (list (shovel:stdlib)
                          (shovel:make-source-file :name "test.sho"
                                                   :contents "
var a = array(1, 2, 3)
pop(a)
pop(a)
")))))
               "2
"))

  (is (string= (process (with-output-to-string (str)
                          (let ((*standard-output* str))
                            (shovel:run-code
                             (list (shovel:stdlib)
                                   (shovel:make-source-file :name "test.sho"
                                                            :contents "
var a = array()
pop(a)
"))))))
               "Shovel error in file 'test.sho' at line 3, column 1: Can't pop from an empty array.

Current stack trace:
file 'test.sho' line 3: pop(a)
file 'test.sho' line 3: ^^^^^^

Current environment:

Frame starts at:
file 'stdlib.sho' line 2: var stdlib = { [...content snipped...]
file 'stdlib.sho' line 2: ^^^^^^^^^^^^^^
Frame variables are:
stdlib = hash
a = array()



")))

(test vm-serialization-and-push-pop-arrays
  (let (flag)
    (labels ((halt (a)
               (cond ((not flag)
                      (setf flag t)
                      (values :null :nap))
                     (t a))))
      (let* ((my-program "
var a = array(10, 20, 30)
@halt(a)
push(a, 40)
pop(a)
pop(a)
@halt(a)
")
             (user-primitives (list (list "halt" #'halt 1))))
        (is (equalp (test-serializer my-program user-primitives)
                    #(10 20)))))))

(test comparison
  (is (= 1 (shovel:naked-run-code (list "var a = true if a == true 1 else 2"))))
  (is (= 2 (shovel:naked-run-code (list "var a = false if a == true 1 else 2"))))
  (is (= 1 (shovel:naked-run-code (list "var a = null if a == null 1 else 2"))))
  (is (= 2 (shovel:naked-run-code (list "var a = null if a != null 1 else 2"))))
  (is (= 2 (shovel:naked-run-code (list "var a = 3 if a == null 1 else 2"))))
  (is (string= (with-output-to-string (str)
                 (let ((*standard-output* str))
                   (shovel:run-code (list "var a = 30 if a == true 1 else 2"))))
               "Shovel error in file '<unspecified-1>' at line 1, column 15: At least one of the arguments must be null or they must have the same type (numbers, strings, booleans, hashes or arrays).

Current stack trace:
file '<unspecified-1>' line 1: var a = 30 if a == true 1 else 2
file '<unspecified-1>' line 1:               ^^^^^^^^^

Current environment:

Frame starts at:
file '<unspecified-1>' line 1: var a = 30 if a == true 1 else 2
file '<unspecified-1>' line 1: ^^^^^^^^^^
Frame variables are:
a = 30



"))
  (is (= 1 (shovel:naked-run-code (list "
var a = array(1)
var b = a
if a == b 1 else 2"))))
  (is (= 2 (shovel:naked-run-code (list "
var a = array(1)
var b = array(1)
if a == b 1 else 2"))))
  (is (= 1 (shovel:naked-run-code (list "
var a = hash('a', 1)
var b = a
if a == b 1 else 2"))))
  (is (= 2 (shovel:naked-run-code (list "
var a = hash('a', 1)
var b = hash('a', 1)
if a == b 1 else 2")))))

(test string-upper-lower
  (is (string= "john" (shovel:naked-run-code (list "lower('John')"))))
  (is (string= "JOHN" (shovel:naked-run-code (list "upper('John')")))))

(test string-accesses-are-strings
  (is (string= "tt" (shovel:naked-run-code (list "var a = 'test' a[0] + a[3]"))))
  (is (string= "tt" (shovel:naked-run-code
                     (list "var a = 'test' slice(a, 0, 1) + slice(a, 3, 4)"))))
  (is (= 5 (shovel:naked-run-code
            (list "var a = array(1, 2, 3, 4) a[0] + a[3]")))))

(test broken-vm-state-match
  (let (flag)
    (labels ((halt (a)
               (cond ((not flag)
                      (setf flag t)
                      (values :null :nap-and-retry-on-wake-up))
                     (t a))))
      (let* ((my-program-1 "var a = 10 @halt(a)")
             (my-program-2 "var b = 10 @halt(b)")
             (user-primitives (list (list "halt" #'halt 1))))
        (let* ((sources-1 (list (shovel:stdlib) my-program-1))
               (sources-2 (list (shovel:stdlib) my-program-2))
               (bytecode-1 (shovel:get-bytecode sources-1))
               (bytecode-2 (shovel:get-bytecode sources-2)))
          (multiple-value-bind (first-run vm)
              (run-vm
               bytecode-1
               :sources sources-1
               :user-primitives user-primitives)
            (declare (ignore first-run))
            (multiple-value-bind (value error)
                (ignore-errors
                  (let* ((bytes (serialize-vm-state vm))
                         (second-run (run-vm
                                      bytecode-2
                                      :sources sources-2
                                      :user-primitives user-primitives
                                      :state bytes)))
                    second-run))
              (declare (ignore value))
              (is (eql 'shovel:shovel-vm-match-error
                       (type-of error)))
              (is (string=
                   "VM bytecode MD5 and serialized VM bytecode MD5 do not match."
                   (shovel:error-message error))))))))))

(defun mess-with (bytes)
  (if (= 0 (aref bytes 10))
      (setf (aref bytes 10) 1)
      (setf (aref bytes 10) 0)))

(test bytecode-serializer-checksum-failure
  (let* ((instructions (shovel:get-bytecode (list (shovel:stdlib))))
         (serialized-instructions (shovel:serialize-bytecode instructions)))
    (mess-with serialized-instructions)
    (signals shovel:shovel-broken-checksum
      (shovel:deserialize-bytecode serialized-instructions))))

(test bytecode-serializer-version-failure
  (let* ((instructions (shovel:get-bytecode (list (shovel:stdlib))))
         (serialized-instructions
          (let ((*version* (1+ *version*)))
            (shovel:serialize-bytecode instructions))))
    (signals shovel:shovel-version-too-large
      (shovel:deserialize-bytecode serialized-instructions))))

(test vm-state-serializer-checksum-failure
  (let (flag)
    (labels ((halt (a)
               (cond ((not flag)
                      (setf flag t)
                      (values :null :nap-and-retry-on-wake-up))
                     (t a))))
      (let* ((my-program "var a = 10 @halt(a)")
             (user-primitives (list (list "halt" #'halt 1))))
        (let* ((sources (list (shovel:stdlib) my-program))
               (bytecode (shovel:get-bytecode sources)))
          (multiple-value-bind (first-run vm)
              (run-vm
               bytecode
               :sources sources
               :user-primitives user-primitives)
            (declare (ignore first-run))
            (let ((bytes (serialize-vm-state vm)))
              (mess-with bytes)
              (signals shovel:shovel-broken-checksum
                (shovel-vm::deserialize-vm-state vm bytes)))))))))

(test vm-state-serializer-version-failure
  (let (flag)
    (labels ((halt (a)
               (cond ((not flag)
                      (setf flag t)
                      (values :null :nap-and-retry-on-wake-up))
                     (t a))))
      (let* ((my-program "var a = 10 @halt(a)")
             (user-primitives (list (list "halt" #'halt 1))))
        (let* ((sources (list (shovel:stdlib) my-program))
               (bytecode (shovel:get-bytecode sources)))
          (multiple-value-bind (first-run vm)
              (run-vm
               bytecode
               :sources sources
               :user-primitives user-primitives)
            (declare (ignore first-run))
            (let ((bytes (let ((*version* (1+ *version*)))
                           (serialize-vm-state vm))))
              (signals shovel:shovel-version-too-large
                (shovel-vm::deserialize-vm-state vm bytes)))))))))

(test non-local-exit-1
  (is (= (shovel:naked-run-code (list "
var h = fn x x + 2
var g = fn x h(x) + 2
var f = fn x block 'f' g(x) + 2
f(1)
"))
         7))
  (is (= 10 (shovel:naked-run-code (list "
var h = fn x return 'f' 10
var g = fn x h(x) + 2
var f = fn x block 'f' g(x) + 2
f(1)
"))))
  (is (string= (with-output-to-string (str)
                 (let ((*standard-output* str))
                   (shovel:run-code (list "
var h = fn x return 'g' 10
var g = fn x h(x) + 2
var f = fn x block 'f' g(x) + 2
f(1)
"))))
               "Shovel error in file '<unspecified-1>' at line 2, column 14: Cannot find block 'g'.

Current stack trace:
file '<unspecified-1>' line 2: var h = fn x return 'g' 10
file '<unspecified-1>' line 2:              ^^^^^^^^^^^^^
file '<unspecified-1>' line 3: var g = fn x h(x) + 2
file '<unspecified-1>' line 3:              ^^^^
file '<unspecified-1>' line 4: var f = fn x block 'f' g(x) + 2
file '<unspecified-1>' line 4:                        ^^^^
file '<unspecified-1>' line 5: f(1)
file '<unspecified-1>' line 5: ^^^^

Current environment:

Frame starts at:
file '<unspecified-1>' line 2: var h = fn x return 'g' 10
file '<unspecified-1>' line 2:            ^
Frame variables are:
x = 1

Frame starts at:
file '<unspecified-1>' line 2: var h = fn x return 'g' 10 [...content snipped...]
file '<unspecified-1>' line 2: ^^^^^^^^^^^^^^^^^^^^^^^^^^
Frame variables are:
h = [...callable...]
g = [...callable...]
f = [...callable...]



"))
  (is (string= (with-output-to-string (str)
                 (let ((*standard-output* str))
                   (shovel:run-code (list "block 1 2"))))
               "Shovel error in file '<unspecified-1>' at line 1, column 1: The name of a block must be a string.

Current stack trace:
file '<unspecified-1>' line 1: block 1 2
file '<unspecified-1>' line 1: ^^^^^^^^^

Current environment:



"))
  (is (string= (with-output-to-string (str)
                 (let ((*standard-output* str))
                   (shovel:run-code (list "block 'a' return 1 3"))))
               "Shovel error in file '<unspecified-1>' at line 1, column 11: The name of a block must be a string.

Current stack trace:
file '<unspecified-1>' line 1: block 'a' return 1 3
file '<unspecified-1>' line 1:           ^^^^^^^^^^

Current environment:



")))

(test vm-serializer-and-non-local-exits
  (let (flag)
    (labels ((halt ()
               (cond ((not flag)
                      (setf flag t)
                      (values :null :nap-and-retry-on-wake-up))
                     (t "ole!"))))
      (let* ((my-program "block 'f' @halt()")
             (user-primitives (list (list "halt" #'halt 0))))
        (is (string= "ole!" (test-serializer my-program user-primitives)))))))

(test stdlib-block-name-generation
  (is (equalp (shovel:naked-run-code (list (shovel:stdlib)
                                           "
array(stdlib.getBlockName(), stdlib.getPrefixedBlockName('myBlock'))"))
              #("block_1" "myBlock_2"))))

(test stdlib-exceptions
  (is (= (shovel:naked-run-code (list (shovel:stdlib)
                                      "
stdlib.try(fn () 10, fn (error) null)
"))
         10))
  (is (= (shovel:naked-run-code (list (shovel:stdlib)
                                      "
stdlib.try(fn () stdlib.throw(3), fn (error) error + 1)
"))
         4))
  (is (string= (shovel:naked-run-code (list (shovel:stdlib)
                                            "
stdlib.try(fn () {
  stdlib.try(fn () stdlib.throw(3), fn (error) 'ole')
}, fn (error) error + 1)
"))
               "ole"))
  (is (= (shovel:naked-run-code (list (shovel:stdlib)
                                      "
stdlib.try(fn () {
  stdlib.try(fn () stdlib.throw(3), fn (error) stdlib.throw(10))
}, fn (error) error + 1)
"))
         11)))

(test context
  (is (string= (shovel:naked-run-code (list "
var a = 20
var h = fn () context.stack
var g = fn x h() + string(x)
var f = fn x g(x) + string(x)
f(a)
"))
               "file '<unspecified-1>' line 3: var h = fn () context.stack
file '<unspecified-1>' line 3:               ^^^^^^^
file '<unspecified-1>' line 4: var g = fn x h() + string(x)
file '<unspecified-1>' line 4:              ^^^
file '<unspecified-1>' line 5: var f = fn x g(x) + string(x)
file '<unspecified-1>' line 5:              ^^^^
file '<unspecified-1>' line 6: f(a)
file '<unspecified-1>' line 6: ^^^^
2020"))
  (is (string= (shovel:naked-run-code (list "
var a = 20
var h = fn () context.environment
var g = fn x h() + string(x)
var f = fn x g(x) + string(x)
f(a)
"))
               "Frame starts at:
file '<unspecified-1>' line 2: var a = 20 [...content snipped...]
file '<unspecified-1>' line 2: ^^^^^^^^^^
Frame variables are:
a = 20
h = [...callable...]
g = [...callable...]
f = [...callable...]

2020"))
  (is (string= (shovel:naked-run-code (list "
var a = 20
var f = fn x {
  var g = fn x {
    var h = fn () context.environment
    h() + string(x)
  }
  g(x) + string(x)
}
f(a)
"))
               "Frame starts at:
file '<unspecified-1>' line 5:     var h = fn () context.environment
file '<unspecified-1>' line 5:     ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Frame variables are:
h = [...callable...]

Frame starts at:
file '<unspecified-1>' line 4:   var g = fn x {
file '<unspecified-1>' line 4:              ^
Frame variables are:
x = 20

Frame starts at:
file '<unspecified-1>' line 4:   var g = fn x { [...content snipped...]
file '<unspecified-1>' line 4:   ^^^^^^^^^^^^^^
Frame variables are:
g = [...callable...]

Frame starts at:
file '<unspecified-1>' line 3: var f = fn x {
file '<unspecified-1>' line 3:            ^
Frame variables are:
x = 20

Frame starts at:
file '<unspecified-1>' line 2: var a = 20 [...content snipped...]
file '<unspecified-1>' line 2: ^^^^^^^^^^
Frame variables are:
a = 20
f = [...callable...]

2020")))

(test short-circuiting-logical-operators
  (is (eq :true (shovel:naked-run-code (list "true || '1' == 2"))))
  (is (eq :false (shovel:naked-run-code (list "false && '1' == 2"))))

  (is (eq :true (shovel:naked-run-code (list "true || false"))))
  (is (eq :true (shovel:naked-run-code (list "true || true"))))
  (is (eq :true (shovel:naked-run-code (list "false || true"))))
  (is (eq :false (shovel:naked-run-code (list "false || false"))))

  (is (eq :false (shovel:naked-run-code (list "true && false"))))
  (is (eq :true (shovel:naked-run-code (list "true && true"))))
  (is (eq :false (shovel:naked-run-code (list "false && true"))))
  (is (eq :false (shovel:naked-run-code (list "false && false")))))

(test stringifying-circular-data-structures
  (is (string= (shovel:naked-run-code (list "
var a = array(1, 2)
a[1] = a
stringRepresentation(a)"))
               "array(1, [...loop...])")))

(test vm-total-ticks-quota
  (labels ((run-with-total-ticks-quota (quota)
             (let* ((sources (list (shovel:stdlib)
                                   "
var result = 0
stdlib.repeat(10, fn () {
  var a = array(1, 2, 3, 4, 5)
  result = stdlib.reduceFromLeft(a, 0, fn (acc, item) acc + item)
})
result
"))
                    (bytecode (shovel:get-bytecode sources)))
               (multiple-value-bind (result vm)
                   (shovel:run-vm bytecode
                                  :sources sources
                                  :total-ticks-quota quota)
                 (values result (shovel-vm::vm-executed-ticks vm))))))
    (multiple-value-bind (result ticks)
        (run-with-total-ticks-quota 10000)
      (is (= 15 result))
      (is (= 3594 ticks)))
    (signals shovel:shovel-total-ticks-quota-exceeded
      (run-with-total-ticks-quota 3580))))

(test vm-nap-quota
  (labels ((run-with-until-nap-ticks-quota (quota &optional vm)
             (let* ((sources (list (shovel:stdlib)
                                   "
var result = 0
stdlib.repeat(10, fn () {
  var a = array(1, 2, 3, 4, 5)
  result = stdlib.reduceFromLeft(a, 0, fn (acc, item) acc + item)
})
result
"))
                    (bytecode (shovel:get-bytecode sources)))
               (multiple-value-bind (result vm)
                   (shovel:run-vm bytecode
                                  :sources sources
                                  :until-next-nap-ticks-quota quota
                                  :vm vm)
                 (values result (shovel-vm::vm-executed-ticks vm) vm)))))
    (multiple-value-bind (result ticks vm)
        (run-with-until-nap-ticks-quota 1000)
      (is (= 2 result))
      (is (= 1000 ticks))
      (is (shovel-vm::vm-should-take-a-nap vm))
      (shovel:wake-up-vm vm)
      (multiple-value-bind (result2 ticks2 vm)
          (run-with-until-nap-ticks-quota 1000 vm)
        (declare (ignore result2 vm))
        (is (= 2000 ticks2))))))

(test vm-user-defined-primitive-ticks-quota
  (labels ((udp (ticks)
             (shovel:increment-ticks ticks))
           (run-with-total-ticks-quota (quota)
             (let* ((sources (list "@udp(100) 1"))
                    (bytecode (shovel:get-bytecode sources)))
               (multiple-value-bind (result vm)
                   (shovel:run-vm bytecode
                                  :sources sources
                                  :total-ticks-quota quota
                                  :user-primitives (list (list "udp" #'udp 1)))
                 (values result (shovel-vm::vm-executed-ticks vm))))))
    (signals shovel:shovel-total-ticks-quota-exceeded
      (run-with-total-ticks-quota 100))))

(test vm-cells-quota
  (let* ((sources (list "var a = arrayN(100)"))
         (bytecode (shovel:get-bytecode sources)))
    (multiple-value-bind (result vm)
        (shovel:run-vm bytecode :sources sources)
      (declare (ignore result))
      (is (= 106 (shovel-vm::vm-used-cells vm)))))
  (let* ((sources (list (shovel:stdlib)
                        "
stdlib.repeat(1000, fn() {
  var a = arrayN(100)
})
"))
         (bytecode (shovel:get-bytecode sources)))
    (multiple-value-bind (result vm)
        (shovel:run-vm bytecode
                       :sources sources
                       :cells-quota 900)
      (declare (ignore result))
      (is (= 741 (shovel-vm::vm-used-cells vm))))
    (signals shovel:shovel-cell-quota-exceeded
      (shovel:run-vm bytecode
                     :sources sources
                     :cells-quota 300))))

(test vm-user-defined-primitive-cells-quota
  (labels ((udp (cells)
             (shovel:increment-cells cells)
             :null)
           (udp1 (n)
             (shovel:increment-cells (1+ n))
             (make-array n :initial-element :null)))
    (is (= 3 (let* ((sources (list "@udp(100) 1"))
                    (bytecode (shovel:get-bytecode sources)))
               (multiple-value-bind (result vm)
                   (shovel:run-vm bytecode
                                  :sources sources
                                  :cells-quota 100
                                  :user-primitives (list (list "udp" #'udp 1)))
                 (declare (ignore result))
                 (shovel-vm::vm-used-cells vm)))))
    (signals shovel:shovel-cell-quota-exceeded
      (let* ((sources (list "var a = @udp1(100)"))
             (bytecode (shovel:get-bytecode sources)))
        (multiple-value-bind (result vm)
            (shovel:run-vm bytecode
                           :sources sources
                           :cells-quota 100
                           :user-primitives (list (list "udp1" #'udp1 1)))
          (declare (ignore result))
          (shovel:vm-used-cells vm))))))

(test vm-cells-quota-herald-cell-increment
  (signals shovel:shovel-cell-quota-exceeded
    (let* ((sources (list "arrayN(100)"))
           (bytecode (shovel:get-bytecode sources)))
      (multiple-value-bind (result vm)
          (shovel:run-vm bytecode
                         :sources sources
                         :cells-quota 100)
        (declare (ignore result))
        (shovel:vm-used-cells vm)))))

(test vm-statistics
  (let* ((sources (list (shovel:stdlib)
                        "
stdlib.repeat(1000, fn() {
  var a = arrayN(100)
})
@halt()
"))
         (bytecode (shovel:get-bytecode sources)))
    (multiple-value-bind (result vm)
        (shovel:run-vm bytecode :sources sources
                       :user-primitives (list (list "halt"
                                                    (lambda ()
                                                      (values :null :nap-and-retry-on-wake-up))
                                                    0)))
      (declare (ignore result))
      (is (= 31171 (shovel:vm-used-ticks vm)))
      (is (= 328 (shovel:vm-used-cells vm))))))

(test vm-serializer-with-env-frames
  (let* ((sources (list "var name = @readLine() name + 1
"))
         (udps (list (list "readLine" (let ((attempt 0))
                                        (lambda ()
                                          (incf attempt)
                                          (if (= 1 attempt)
                                              (values :null :nap-and-retry-on-wake-up)
                                              "John"))))))
         (bytecode (shovel:get-bytecode sources)))
    (multiple-value-bind (result vm)
        (shovel:run-vm bytecode :sources sources :user-primitives udps)
      (declare (ignore result))
      (let ((state (shovel:serialize-vm-state vm)))
        (multiple-value-bind (result error)
            (ignore-errors (shovel:run-vm bytecode
                                          :sources sources
                                          :state state
                                          :user-primitives udps))
          (declare (ignore result))
          (is (string= (with-output-to-string (str)
                         (print-object error str))
                       "Shovel error in file '<unspecified-1>' at line 1, column 24: Arguments must have the same type (numbers or strings or arrays).

Current stack trace:
file '<unspecified-1>' line 1: var name = @readLine() name + 1
file '<unspecified-1>' line 1:                        ^^^^^^^^

Current environment:

Frame starts at:
file '<unspecified-1>' line 1: var name = @readLine() name + 1
file '<unspecified-1>' line 1: ^^^^^^^^^^^^^^^^^^^^^^
Frame variables are:
name = \"John\"


")))))))

(test key-not-found
  (is (eq :true (shovel:naked-run-code (list "var a = hash() a['a'] == null")))))

(test type-predicates
  (is (eq :true (shovel:naked-run-code (list "isInteger(1)"))))
  (is (eq :false (shovel:naked-run-code (list "isInteger(1.5)"))))
  (is (eq :true (shovel:naked-run-code (list "isNumber(1.5)"))))
  (is (eq :false (shovel:naked-run-code (list "isNumber('test')"))))
  (is (eq :true (shovel:naked-run-code (list "isNumber(1.5) && !isInteger(1.5)"))))
  (is (eq :false (shovel:naked-run-code (list "!isNumber(1.5) || isInteger(1.5)"))))
  (is (eq :true (shovel:naked-run-code (list "isCallable(fn () 1)"))))
  (is (eq :false (shovel:naked-run-code (list "isCallable(1)"))))
  (is (eq :true (shovel:naked-run-code (list "isString('test')"))))
  (is (eq :false (shovel:naked-run-code (list "isString(10)"))))
  (is (eq :true (shovel:naked-run-code (list "isBool(1 == 2)"))))
  (is (eq :false (shovel:naked-run-code (list "isBool(1)"))))
  (is (eq :true (shovel:naked-run-code (list "isArray(array(1, 2))"))))
  (is (eq :false (shovel:naked-run-code (list "isArray(1)"))))
  (is (eq :true (shovel:naked-run-code (list "isHash(hash('a', 2))"))))
  (is (eq :false (shovel:naked-run-code (list "isHash(1)")))))

(defun print-to-string (&rest sources)
  (with-output-to-string (str)
    (let ((*standard-output* str))
      (shovel:print-code sources))))

(test empties
  (is (string= (print-to-string) "    VM-VERSION 1

    VM-SOURCES-MD5 D41D8CD98F00B204E9800998ECF8427E

    VM-BYTECODE-MD5 ?

    CONST NULL

NIL
"))
  (is (string= (print-to-string "") "    VM-VERSION 1

    VM-SOURCES-MD5 D41D8CD98F00B204E9800998ECF8427E

    VM-BYTECODE-MD5 ?

    FILE-NAME <unspecified-1>

    CONST NULL

NIL
"))
  (is (string= (print-to-string "" "")
               "    VM-VERSION 1

    VM-SOURCES-MD5 D41D8CD98F00B204E9800998ECF8427E

    VM-BYTECODE-MD5 ?

    FILE-NAME <unspecified-1>

    FILE-NAME <unspecified-2>

    CONST NULL

NIL
"))
  (is (string= (print-to-string "{}")
               "    VM-VERSION 1

    VM-SOURCES-MD5 99914B932BD37A50B983C5E7C90AE93B

    VM-BYTECODE-MD5 ?

    FILE-NAME <unspecified-1>

    CONST NULL

NIL
"))
  (is (string= (print-to-string "{}{}")
               "    VM-VERSION 1

    VM-SOURCES-MD5 C53F4EBE9B2A50BC2B52FD88A5D503E1

    VM-BYTECODE-MD5 ?

    FILE-NAME <unspecified-1>

    CONST NULL

    POP

    CONST NULL

NIL
"))
  (is (string= (print-to-string "{{}}")
               "    VM-VERSION 1

    VM-SOURCES-MD5 3F7A56499D58DE719351A6D324A76BBD

    VM-BYTECODE-MD5 ?

    FILE-NAME <unspecified-1>

    CONST NULL

NIL
"))
  (is (string= (print-to-string "{{}}{{{}}}")
               "    VM-VERSION 1

    VM-SOURCES-MD5 66F99E017EE16ED7E471D3B4830ADF02

    VM-BYTECODE-MD5 ?

    FILE-NAME <unspecified-1>

    CONST NULL

    POP

    CONST NULL

NIL
"))
  (is (string= (print-to-string "1" "")
               "    VM-VERSION 1

    VM-SOURCES-MD5 C4CA4238A0B923820DCC509A6F75849B

    VM-BYTECODE-MD5 ?

    FILE-NAME <unspecified-1>

    ; file '<unspecified-1>' line 1: 1
    ; file '<unspecified-1>' line 1: ^
    CONST 1

    FILE-NAME <unspecified-2>

NIL
"))
  (is (string= (print-to-string "1" "2")
               "    VM-VERSION 1

    VM-SOURCES-MD5 C20AD4D76FE97759AA27A0C99BFF6710

    VM-BYTECODE-MD5 ?

    FILE-NAME <unspecified-1>

    FILE-NAME <unspecified-2>

    ; file '<unspecified-2>' line 1: 2
    ; file '<unspecified-2>' line 1: ^
    CONST 2

NIL
"))
  (is (string= (print-to-string "" "2")
               "    VM-VERSION 1

    VM-SOURCES-MD5 C81E728D9D4C2F636F067F89CC14862C

    VM-BYTECODE-MD5 ?

    FILE-NAME <unspecified-1>

    FILE-NAME <unspecified-2>

    ; file '<unspecified-2>' line 1: 2
    ; file '<unspecified-2>' line 1: ^
    CONST 2

NIL
")))

(defun run-tests ()
  (let ((*print-circle* t))
    (fiveam:run! :shovel-tests)))
