(define-module (opencog-package)
  #:use-module (guix packages)
  #:use-module (guix git-download)
  #:use-module (guix build-system gnu)
  #:use-module (guix build-system cmake)
  #:use-module (guix licenses)
  #:use-module (gnu packages base)
  #:use-module (gnu packages cmake)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages guile)
  #:use-module (gnu packages boost)
  #:use-module (gnu packages python)
  #:use-module (gnu packages cython)
  #:use-module (gnu packages serialization)
  #:use-module (gnu packages databases)
  #:use-module (gnu packages networking))

(define-public opencog-central
  (package
    (name "opencog-central")
    (version "latest-git")
    (source (git-checkout
             (url "https://github.com/OzCog/opencog-central.git")
             (commit "HEAD")))
    (build-system cmake-build-system)
    (arguments
     `(#:configure-flags
       '("-DCMAKE_BUILD_TYPE=Release"
         "-DPYTHON_EXECUTABLE=/usr/bin/python3"
         "-DGUILE_INCLUDE_DIR=/usr/include/guile/3.0"
         "-DGUILE_LIBRARIES=/usr/lib/x86_64-linux-gnu/libguile-3.0.so")
       #:tests? #f)) ; Disable tests for now
    (native-inputs
     (list cmake pkg-config))
    (inputs
     (list guile-3.0
           boost
           python
           python-cython
           cpprest
           postgresql))
    (synopsis "OpenCog Central - Comprehensive Cognitive Architecture")
    (description 
     "OpenCog Central is a comprehensive cognitive architecture implementing 
artificial general intelligence through neural-symbolic integration and 
hypergraph-based knowledge representation. It includes the AtomSpace 
hypergraph knowledge representation system, PLN (Probabilistic Logic Network) 
for uncertain reasoning, and various cognitive components for learning, 
sensory-motor interaction, and adaptive behavior.")
    (home-page "https://github.com/OzCog/opencog-central")
    (license agpl3+)))

opencog-central