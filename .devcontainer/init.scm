;; Shepherd configuration for OpenCog packaging and development services
;; This file should be placed in ~/.config/shepherd/init.scm

(use-modules (shepherd service))

;; OpenCog build service
(simple-service 'opencog-build
                (lambda ()
                  (make-forkexec-constructor
                   `("guix" "build" "/workspace/.devcontainer/opencog.scm")
                   #:directory "/workspace"
                   #:log-file "/tmp/opencog-build.log"))
                (lambda ()
                  (make-kill-destructor)))

;; OpenCog test service  
(simple-service 'opencog-test
                (lambda ()
                  (make-forkexec-constructor
                   `("guix" "environment" "--ad-hoc" 
                     "/workspace/.devcontainer/opencog.scm" "--"
                     "make" "test")
                   #:directory "/workspace"
                   #:log-file "/tmp/opencog-test.log"))
                (lambda ()
                  (make-kill-destructor)))

;; OpenCog development environment service
(simple-service 'opencog-env
                (lambda ()
                  (make-forkexec-constructor
                   `("guix" "environment" "--ad-hoc"
                     "/workspace/.devcontainer/opencog.scm" 
                     "bash" "--" "-c" "echo 'OpenCog development environment ready'")
                   #:directory "/workspace"
                   #:log-file "/tmp/opencog-env.log"))
                (lambda ()
                  (make-kill-destructor)))

;; Guix daemon service (if not already running)
(simple-service 'guix-daemon
                (lambda ()
                  (make-forkexec-constructor
                   `("guix-daemon" "--build-users-group=guixbuild")
                   #:log-file "/tmp/guix-daemon.log"))
                (lambda ()
                  (make-kill-destructor)))

;; Service to pull latest Guix packages
(simple-service 'guix-pull
                (lambda ()
                  (make-forkexec-constructor
                   `("guix" "pull")
                   #:directory "/workspace"
                   #:log-file "/tmp/guix-pull.log"))
                (lambda ()
                  (make-kill-destructor)))

;; Start the essential services by default
(register-services opencog-build opencog-test opencog-env guix-pull)

;; Start services that should run automatically
(start-service guix-pull)