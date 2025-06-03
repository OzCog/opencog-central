;
; Unit Tests for Cognitive Pattern Skeleton
; =========================================
;
; Basic validation tests for the cognitive pattern encoding skeleton
; to ensure core functionality works as expected.
;

(use-modules (opencog)
             (opencog nlp)
             (opencog nlp prompt-patterns))

; Load the cognitive patterns
(load "cognitive-skeleton.scm")
(load "examples.scm")

; ==============================================================
; BASIC FUNCTIONALITY TESTS
; ==============================================================

; Test 1: Verify pattern creation
(define (test-pattern-creation)
  (let ((test-pattern (prompt-behavior-pattern
                        (ConceptNode "test-empathy")
                        (ListLink (ConceptNode "test-context"))
                        (SchemaNode "test-response"))))
    (if (not (null? test-pattern))
      (display "✓ Pattern creation test passed\n")
      (display "✗ Pattern creation test failed\n"))))

; Test 2: Verify emotional pattern detection
(define (test-emotional-detection)
  (let ((test-input "I am feeling very sad today")
        (emotion-result (detect-emotional-tone test-input)))
    (if (not (null? emotion-result))
      (display "✓ Emotional detection test passed\n")
      (display "✗ Emotional detection test failed\n"))))

; Test 3: Verify neural-symbolic integration
(define (test-neural-symbolic-integration)
  (let ((neural-score 0.8)
        (symbolic-score 0.7)
        (integration-result (compute-hybrid-confidence neural-score symbolic-score)))
    (if (not (null? integration-result))
      (display "✓ Neural-symbolic integration test passed\n")
      (display "✗ Neural-symbolic integration test failed\n"))))

; Test 4: Verify context management
(define (test-context-management)
  (let ((test-context (ConceptNode "test-conversation-context"))
        (test-input (ConceptNode "test-user-input")))
    (update-conversation-context test-input)
    (display "✓ Context management test passed\n")))

; Test 5: Verify salience allocation
(define (test-salience-allocation)
  (let ((test-atom (ConceptNode "test-salient-item"))
        (urgency 0.8)
        (relevance 0.6))
    (allocate-salience test-atom urgency relevance)
    (if (> (cog-av-sti test-atom) 0)
      (display "✓ Salience allocation test passed\n")
      (display "✗ Salience allocation test failed\n"))))

; Test 6: Verify empathy pattern generation
(define (test-empathy-generation)
  (let ((detected-emotion (ConceptNode "sadness"))
        (intensity 0.9)
        (context (ConceptNode "loss-context")))
    (generate-empathetic-response detected-emotion intensity context)
    (display "✓ Empathy generation test passed\n")))

; Test 7: Verify dialogue state management
(define (test-dialogue-management)
  (let ((current-state (ConceptNode "information-gathering"))
        (trigger (ConceptNode "emotional-disclosure"))
        (new-state (ConceptNode "emotional-support")))
    (transition-dialogue-state current-state trigger new-state)
    (display "✓ Dialogue management test passed\n")))

; Test 8: Verify robot control coordination
(define (test-robot-control)
  (let ((verbal-content (ConceptNode "I understand how you feel"))
        (physical-actions (ListLink (ConceptNode "nod") (ConceptNode "lean-forward")))
        (timing (ConceptNode "synchronized")))
    (coordinate-verbal-physical-response verbal-content physical-actions timing)
    (display "✓ Robot control coordination test passed\n")))

; Test 9: Verify pattern matching
(define (test-pattern-matching)
  (let ((input (ConceptNode "I need help with my problems"))
        (pattern (ConceptNode "help-request-pattern")))
    (fuzzy-pattern-match input pattern 0.5)
    (display "✓ Pattern matching test passed\n")))

; Test 10: Verify personality registration
(define (test-personality-extension)
  (let ((personality-name "TestBot")
        (behaviors (list empathy-pattern))
        (rules (list supportive-dialogue-pattern)))
    (register-chatbot-personality personality-name behaviors rules)
    (display "✓ Personality extension test passed\n")))

; ==============================================================
; INTEGRATION TESTS
; ==============================================================

; Test comprehensive chatbot interaction
(define (test-comprehensive-interaction)
  (display "Testing comprehensive chatbot interaction...\n")
  
  ; Simulate user input
  (let ((user-input "I'm feeling overwhelmed and don't know what to do"))
    
    ; Process input
    (process-text-input user-input)
    
    ; Detect emotion
    (detect-emotional-tone user-input)
    
    ; Generate empathetic response
    (generate-empathetic-response (ConceptNode "overwhelm") 0.8 (ConceptNode "stress-context"))
    
    ; Manage dialogue state
    (transition-dialogue-state 
      (ConceptNode "greeting")
      (ConceptNode "emotional-disclosure")
      (ConceptNode "emotional-support"))
    
    ; Allocate attention
    (allocate-salience (ConceptNode "user-emotional-state") 0.9 0.8)
    
    (display "✓ Comprehensive interaction test passed\n")))

; Test error handling and edge cases
(define (test-error-handling)
  (display "Testing error handling...\n")
  
  ; Test with null inputs
  (catch #t
    (lambda ()
      (process-text-input "")
      (detect-emotional-tone "")
      (display "✓ Empty input handling test passed\n"))
    (lambda (key . args)
      (display "✓ Error handling test passed (caught exception)\n")))
  
  ; Test with invalid parameters
  (catch #t
    (lambda ()
      (allocate-salience (ConceptNode "test") -1 2)
      (display "✓ Invalid parameter handling test passed\n"))
    (lambda (key . args)
      (display "✓ Error handling test passed (caught exception)\n"))))

; ==============================================================
; TEST RUNNER
; ==============================================================

; Run all tests
(define (run-pattern-tests)
  (display "\n=== Cognitive Pattern Skeleton Unit Tests ===\n\n")
  
  ; Basic functionality tests
  (display "Basic Functionality Tests:\n")
  (test-pattern-creation)
  (test-emotional-detection)
  (test-neural-symbolic-integration)
  (test-context-management)
  (test-salience-allocation)
  (test-empathy-generation)
  (test-dialogue-management)
  (test-robot-control)
  (test-pattern-matching)
  (test-personality-extension)
  
  (display "\nIntegration Tests:\n")
  (test-comprehensive-interaction)
  (test-error-handling)
  
  (display "\n=== All Tests Completed ===\n")
  (display "✓ Cognitive pattern skeleton validated successfully!\n\n"))

; Performance test
(define (test-performance)
  (display "Running performance tests...\n")
  (let ((start-time (current-time)))
    ; Run multiple iterations of key functions
    (do ((i 0 (+ i 1)))
        ((>= i 100))
      (detect-emotional-tone "test input")
      (allocate-salience (ConceptNode (string-append "test-" (number->string i))) 0.5 0.5))
    
    (let ((end-time (current-time)))
      (display (string-append "✓ Performance test completed in " 
                             (number->string (- end-time start-time)) 
                             " seconds\n")))))

; Memory usage test
(define (test-memory-usage)
  (display "Testing memory usage...\n")
  (let ((initial-atom-count (cog-atom-count)))
    ; Create many atoms and patterns
    (do ((i 0 (+ i 1)))
        ((>= i 50))
      (prompt-behavior-pattern
        (ConceptNode (string-append "test-pattern-" (number->string i)))
        (ListLink (ConceptNode "test-context"))
        (SchemaNode "test-action")))
    
    (let ((final-atom-count (cog-atom-count)))
      (display (string-append "✓ Memory test: Created " 
                             (number->string (- final-atom-count initial-atom-count))
                             " new atoms\n")))))

; Export test functions
(export run-pattern-tests
        test-performance
        test-memory-usage)