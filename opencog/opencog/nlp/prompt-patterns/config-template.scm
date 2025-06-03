;
; Configuration Template for Cognitive Pattern Skeleton
; ====================================================
;
; This file provides customizable parameters for the cognitive pattern
; encoding skeleton. Copy and modify these settings to customize behavior
; for your specific chatbot implementation.
;

; ==============================================================
; NEURAL-SYMBOLIC INTEGRATION CONFIGURATION
; ==============================================================

; Neural network confidence weighting (0.0 to 1.0)
(define neural-weight 0.6)

; Symbolic reasoning confidence weighting (0.0 to 1.0) 
(define symbolic-weight 0.4)

; Confidence threshold for accepting responses (0.0 to 1.0)
(define confidence-threshold 0.7)

; Fusion strategy selection criteria
(define fusion-thresholds
  (list
    (cons "neural-dominant" 0.8)    ; Use when neural confidence > 0.8
    (cons "symbolic-dominant" 0.8)  ; Use when symbolic confidence > 0.8
    (cons "balanced" 0.7)           ; Use when both > 0.7
    (cons "conservative" 0.5)))     ; Use when both < 0.5

; ==============================================================
; EMOTIONAL MODELING CONFIGURATION
; ==============================================================

; Emotion detection sensitivity (0.0 to 1.0)
(define emotion-sensitivity 0.7)

; Empathy response intensity multiplier (0.0 to 2.0)
(define empathy-intensity-multiplier 0.8)

; Emotional mirroring intensity (0.0 to 1.0)
(define emotional-mirroring-factor 0.7)

; Emotional memory retention (number of interactions)
(define emotional-memory-window 50)

; Supported emotional states (extend as needed)
(define supported-emotions
  (list "joy" "sadness" "anger" "fear" "surprise" "disgust" 
        "trust" "anticipation" "anxiety" "excitement" "contentment"))

; ==============================================================
; DIALOGUE MANAGEMENT CONFIGURATION
; ==============================================================

; Conversation context window size (number of turns)
(define context-window-size 10)

; Topic coherence threshold (0.0 to 1.0)
(define topic-coherence-threshold 0.6)

; Active listening response probability (0.0 to 1.0)
(define active-listening-probability 0.8)

; Maximum question depth for Socratic questioning (1-5)
(define max-socratic-depth 3)

; Conversation repair sensitivity (0.0 to 1.0)
(define repair-sensitivity 0.5)

; ==============================================================
; LEARNING AND ADAPTATION CONFIGURATION
; ==============================================================

; Learning rate for pattern adaptation (0.0 to 1.0)
(define pattern-learning-rate 0.1)

; Experience significance threshold for memory consolidation (0.0 to 1.0)
(define significance-threshold 0.7)

; Pattern strength adjustment increment (0.0 to 1.0)
(define strength-adjustment-delta 0.1)

; Maximum number of recursive feedback iterations
(define max-feedback-iterations 3)

; Pattern matching fuzziness threshold (0.0 to 1.0)
(define fuzziness-threshold 0.5)

; ==============================================================
; ATTENTION AND SALIENCE CONFIGURATION
; ==============================================================

; Base attention budget (total available attention units)
(define attention-budget 100)

; Salience decay rate per cycle (0.0 to 1.0)
(define salience-decay-rate 0.05)

; Urgency weight in salience calculation (0.0 to 1.0)
(define urgency-weight 0.6)

; Relevance weight in salience calculation (0.0 to 1.0)
(define relevance-weight 0.4)

; Minimum salience threshold (below this, atoms are ignored)
(define min-salience-threshold 0.1)

; ==============================================================
; ROBOT CONTROL CONFIGURATION
; ==============================================================

; Gesture synchronization delay (seconds)
(define gesture-sync-delay 0.2)

; Facial expression intensity multiplier (0.0 to 2.0)
(define facial-expression-intensity 0.8)

; Voice-gesture coordination tightness (0.0 to 1.0)
(define voice-gesture-coordination 0.9)

; Physical response appropriateness threshold (0.0 to 1.0)
(define physical-response-threshold 0.6)

; ==============================================================
; PERSONALITY CONFIGURATION TEMPLATES
; ==============================================================

; Empathetic Counselor Personality
(define empathetic-counselor-config
  (list
    (cons "empathy-level" 0.9)
    (cons "directiveness" 0.3)
    (cons "emotional-support" 0.9)
    (cons "problem-solving-focus" 0.7)
    (cons "mindfulness-integration" 0.8)))

; Professional Assistant Personality  
(define professional-assistant-config
  (list
    (cons "empathy-level" 0.6)
    (cons "directiveness" 0.8)
    (cons "emotional-support" 0.5)
    (cons "problem-solving-focus" 0.9)
    (cons "efficiency-focus" 0.9)))

; Mindfulness Guide Personality
(define mindfulness-guide-config
  (list
    (cons "empathy-level" 0.8)
    (cons "directiveness" 0.4)
    (cons "emotional-support" 0.8)
    (cons "present-moment-focus" 0.9)
    (cons "self-compassion-emphasis" 0.9)))

; Educational Tutor Personality
(define educational-tutor-config
  (list
    (cons "empathy-level" 0.7)
    (cons "directiveness" 0.6)
    (cons "encouragement-level" 0.9)
    (cons "scaffolding-approach" 0.8)
    (cons "metacognitive-emphasis" 0.8)))

; ==============================================================
; CRISIS INTERVENTION CONFIGURATION
; ==============================================================

; Crisis detection keywords (extend as needed)
(define crisis-keywords
  (list "suicide" "kill myself" "end it all" "hurt myself" 
        "can't go on" "want to die" "hopeless" "worthless"))

; Crisis response urgency multiplier (> 1.0)
(define crisis-urgency-multiplier 5.0)

; Crisis intervention escalation threshold
(define crisis-escalation-threshold 0.9)

; Emergency contact integration (true/false)
(define emergency-contact-enabled #t)

; ==============================================================
; PERFORMANCE AND OPTIMIZATION CONFIGURATION
; ==============================================================

; Maximum processing time per response (seconds)
(define max-response-time 2.0)

; Memory cleanup frequency (number of interactions)
(define memory-cleanup-frequency 100)

; Pattern cache size (number of patterns)
(define pattern-cache-size 1000)

; Parallel processing enabled (true/false)
(define parallel-processing-enabled #t)

; Debug logging level (0=none, 1=basic, 2=detailed, 3=verbose)
(define debug-level 1)

; ==============================================================
; EXTENSION CONFIGURATION
; ==============================================================

; Custom behavior modules to load (list of file paths)
(define custom-behavior-modules
  (list))

; Custom personality profiles directory
(define personality-profiles-directory "personalities/")

; Plugin directories for external extensions
(define plugin-directories
  (list "plugins/" "extensions/"))

; API integration endpoints (for external services)
(define api-endpoints
  (list
    (cons "emotion-service" "http://localhost:8080/emotion")
    (cons "knowledge-base" "http://localhost:8081/kb")
    (cons "speech-synthesis" "http://localhost:8082/tts")))

; ==============================================================
; UTILITY FUNCTIONS FOR CONFIGURATION
; ==============================================================

; Function to load custom configuration
(define (load-custom-config config-file)
  (if (file-exists? config-file)
    (load config-file)
    (display (string-append "Warning: Configuration file " config-file " not found.\n"))))

; Function to validate configuration values
(define (validate-config)
  (let ((errors '()))
    (if (not (and (>= neural-weight 0.0) (<= neural-weight 1.0)))
      (set! errors (cons "neural-weight must be between 0.0 and 1.0" errors)))
    (if (not (and (>= symbolic-weight 0.0) (<= symbolic-weight 1.0)))
      (set! errors (cons "symbolic-weight must be between 0.0 and 1.0" errors)))
    (if (not (= (+ neural-weight symbolic-weight) 1.0))
      (set! errors (cons "neural-weight + symbolic-weight should equal 1.0" errors)))
    (if (null? errors)
      (display "✓ Configuration validation passed\n")
      (begin
        (display "✗ Configuration validation failed:\n")
        (map (lambda (error) (display (string-append "  - " error "\n"))) errors)))))

; Function to display current configuration
(define (show-config)
  (display "=== Current Cognitive Pattern Configuration ===\n")
  (display (string-append "Neural weight: " (number->string neural-weight) "\n"))
  (display (string-append "Symbolic weight: " (number->string symbolic-weight) "\n"))
  (display (string-append "Confidence threshold: " (number->string confidence-threshold) "\n"))
  (display (string-append "Emotion sensitivity: " (number->string emotion-sensitivity) "\n"))
  (display (string-append "Context window size: " (number->string context-window-size) "\n"))
  (display (string-append "Learning rate: " (number->string pattern-learning-rate) "\n"))
  (display (string-append "Debug level: " (number->string debug-level) "\n"))
  (display "==========================================\n"))

; Export configuration functions
(export load-custom-config
        validate-config
        show-config)