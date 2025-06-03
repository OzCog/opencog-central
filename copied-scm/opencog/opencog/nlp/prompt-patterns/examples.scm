;
; Examples and Usage Demonstrations for Cognitive Pattern Skeleton
; ================================================================
;
; This file provides practical examples of how to use the cognitive
; pattern encoding skeleton for implementing different chatbot behaviors.
;

(use-modules (opencog)
             (opencog nlp)
             (opencog nlp prompt-patterns))

; Load the cognitive pattern skeleton
(load "cognitive-skeleton.scm")

; ==============================================================
; EXAMPLE 1: EMPATHETIC CHATBOT INTERACTION
; ==============================================================

; Example: User expresses sadness about job loss
(define user-input-sad "I just lost my job and I'm feeling really devastated")

; Detect emotional state
(define detected-emotion 
  (detect-emotional-tone user-input-sad))

; Generate empathetic response
(define empathetic-response
  (generate-empathetic-response 
    (ConceptNode "sadness")
    (NumberNode 0.9)  ; high intensity
    (ConceptNode "job-loss-context")))

; Apply supportive validation
(define validation-response
  (provide-emotional-support (ConceptNode "sadness") 2)) ; Level 2: empathetic reflection

; Example output pattern:
; "I can hear how devastating this must be for you. Losing a job is one of life's 
;  most stressful experiences, and your feelings are completely valid. Can you 
;  tell me more about what this job meant to you?"

; ==============================================================
; EXAMPLE 2: PROBLEM-SOLVING DIALOGUE
; ==============================================================

; Example: User seeking help with relationship conflict
(define user-input-problem "I'm having constant arguments with my partner and don't know what to do")

; Process input and extract context
(define processed-input
  (process-text-input user-input-problem))

; Generate contextual questions for exploration
(define exploratory-questions
  (generate-contextual-questions 
    (ConceptNode "relationship-conflict")
    (ConceptNode "frustration")))

; Initiate collaborative problem-solving
(define problem-solving-approach
  (explore-problem-collaboratively 
    (ConceptNode "relationship-arguments")))

; Example output pattern:
; "It sounds like you're dealing with ongoing conflict in your relationship, 
;  which must be really exhausting. To help me understand better, can you tell me
;  what these arguments tend to be about? Are there any patterns you've noticed?"

; ==============================================================
; EXAMPLE 3: ROBOT CONTROL INTEGRATION
; ==============================================================

; Example: Embodied robot providing comfort
(define comfort-scenario
  (coordinate-verbal-physical-response
    (ConceptNode "I'm sorry you're going through this difficult time")
    (ListLink 
      (ConceptNode "gentle-forward-lean")
      (ConceptNode "concerned-facial-expression")
      (ConceptNode "open-hand-gesture"))
    (ConceptNode "synchronized-timing")))

; Generate contextual gestures for empathy
(define empathy-gestures
  (generate-contextual-gestures
    (ConceptNode "expressing-empathy")
    (ConceptNode "compassionate")
    (ConceptNode "close-personal-interaction")))

; Coordinate facial expressions with emotional state
(define facial-coordination
  (map (lambda (expression-rule)
         (cog-execute! expression-rule))
       facial-expression-mapping))

; ==============================================================
; EXAMPLE 4: ADAPTIVE LEARNING FROM INTERACTION
; ==============================================================

; Example: Learning from user feedback
(define learning-scenario
  (let ((user-input "I feel overwhelmed with work")
        (bot-response "Have you tried making a to-do list?")
        (user-feedback "That's not really helpful right now"))
    
    ; Learn from this interaction
    (learn-from-interaction user-input bot-response user-feedback)
    
    ; The system would adapt by:
    ; 1. Weakening the "suggest-productivity-tools" pattern for emotional distress
    ; 2. Strengthening "validate-feelings-first" patterns
    ; 3. Exploring alternative supportive responses
    
    ; Next time, the response might be:
    ; "That sounds really overwhelming. Before we think about solutions, 
    ;  can you tell me more about what's making work feel so intense right now?"
    ))

; ==============================================================
; EXAMPLE 5: NEURAL-SYMBOLIC INTEGRATION
; ==============================================================

; Example: Combining neural emotion detection with symbolic reasoning
(define neural-symbolic-example
  (let ((neural-emotion-score 0.85)  ; Neural network detected high sadness
        (symbolic-context-analysis (ConceptNode "recent-loss-indicators"))
        (confidence-weights (list 0.8 0.7)))
    
    ; Fuse neural and symbolic understanding
    (fuse-neural-symbolic
      (NumberNode neural-emotion-score)
      symbolic-context-analysis
      confidence-weights)
    
    ; Result: Combined understanding that user is experiencing grief
    ; with high confidence, leading to appropriate therapeutic responses
    ))

; ==============================================================
; EXAMPLE 6: RECURSIVE FEEDBACK AND IMPROVEMENT
; ==============================================================

; Example: Iterative response refinement
(define recursive-improvement-example
  (let ((initial-response "You should try to think more positively")
        (user-reaction "That doesn't help at all")
        (iteration-count 0))
    
    ; Apply recursive feedback
    (recursive-feedback initial-response user-reaction iteration-count)
    
    ; First iteration might produce:
    ; "I understand that's not helpful. What kind of support would be most useful to you right now?"
    
    ; If still negative feedback, second iteration:
    ; "I'm sorry, I'm not getting this right. Can you help me understand what you need from me?"
    ))

; ==============================================================
; EXAMPLE 7: EXTENSIBLE CHATBOT PERSONALITY
; ==============================================================

; Example: Creating a mindfulness-focused chatbot personality
(define mindfulness-chatbot
  (register-chatbot-personality
    "MindfulnessBot"
    (list
      ; Behavior patterns
      (prompt-behavior-pattern
        (ConceptNode "mindfulness-guidance")
        (ListLink (ConceptNode "stress-detected"))
        (SchemaNode "suggest-mindfulness-practice"))
      
      (prompt-behavior-pattern
        (ConceptNode "present-moment-awareness")
        (ListLink (ConceptNode "rumination-detected"))
        (SchemaNode "guide-to-present-moment")))
    
    (list
      ; Interaction rules
      (ImplicationLink
        (EvaluationLink
          (PredicateNode "user-emotion")
          (ListLink (ConceptNode "anxiety")))
        (ExecutionLink
          (SchemaNode "breathing-exercise")
          (ListLink (ConceptNode "4-7-8-breath")))))))

; ==============================================================
; EXAMPLE 8: CROSS-MODAL INTEGRATION
; ==============================================================

; Example: Processing multimodal input (text + voice tone + facial expression)
(define multimodal-integration-example
  (let ((text-input "I'm fine")
        (voice-tone-analysis (ConceptNode "sad-prosody"))
        (facial-expression (ConceptNode "downcast-eyes")))
    
    ; Process all modalities
    (process-multimodal-input
      text-input
      voice-tone-analysis
      facial-expression)
    
    ; Detect incongruence between verbal and non-verbal
    (cross-modal-integration)
    
    ; Result: Understanding that user is not actually "fine" 
    ; despite their words, leading to gentle probing:
    ; "I hear you saying you're fine, but I'm sensing there might be 
    ;  more going on. Sometimes it's hard to put feelings into words."
    ))

; ==============================================================
; EXAMPLE 9: CONTEXT-AWARE CONVERSATION MANAGEMENT
; ==============================================================

; Example: Managing conversation flow with topic transitions
(define conversation-management-example
  (let ((conversation-history 
          (list (ConceptNode "discussed-work-stress")
                (ConceptNode "talked-about-family")
                (ConceptNode "mentioned-health-concerns")))
        (new-user-input "I had a good day today"))
    
    ; Update conversation context
    (update-conversation-context new-user-input)
    
    ; Maintain topic coherence while acknowledging positive shift
    (maintain-topic-coherence new-user-input conversation-history)
    
    ; Example response:
    ; "That's wonderful to hear! It sounds like despite all the challenges 
    ;  we've been talking about with work and family, you were able to have 
    ;  a good day. What made today feel different?"
    ))

; ==============================================================
; EXAMPLE 10: SALIENCE ALLOCATION DEMONSTRATION
; ==============================================================

; Example: Dynamic attention allocation based on user urgency
(define salience-allocation-example
  (let ((urgent-safety-concern (ConceptNode "mentioned-self-harm"))
        (casual-question (ConceptNode "asked-about-weather"))
        (emotional-disclosure (ConceptNode "shared-trauma-memory")))
    
    ; Allocate salience based on urgency and importance
    (allocate-salience urgent-safety-concern 1.0 0.9)  ; Highest priority
    (allocate-salience emotional-disclosure 0.7 0.8)   ; High priority
    (allocate-salience casual-question 0.1 0.2)        ; Lowest priority
    
    ; System focuses attention and resources accordingly
    ; Safety concerns get immediate priority and specialized responses
    ))

; ==============================================================
; UTILITY FUNCTIONS FOR EXAMPLES
; ==============================================================

; Helper function to demonstrate pattern usage
(define (demonstrate-pattern pattern-name input)
  (display (string-append "Demonstrating: " pattern-name "\n"))
  (display (string-append "Input: " (cog-name input) "\n"))
  (display "Processing...\n")
  ; Pattern processing would happen here
  (display "Pattern demonstration complete.\n\n"))

; Function to run all examples
(define (run-all-examples)
  (display "=== Cognitive Pattern Skeleton Examples ===\n\n")
  (demonstrate-pattern "Empathetic Response" user-input-sad)
  (demonstrate-pattern "Problem-Solving Dialogue" user-input-problem)
  (demonstrate-pattern "Robot Control Integration" comfort-scenario)
  (demonstrate-pattern "Adaptive Learning" learning-scenario)
  (demonstrate-pattern "Neural-Symbolic Integration" neural-symbolic-example)
  (demonstrate-pattern "Recursive Improvement" recursive-improvement-example)
  (demonstrate-pattern "Extensible Personality" mindfulness-chatbot)
  (demonstrate-pattern "Multimodal Integration" multimodal-integration-example)
  (demonstrate-pattern "Conversation Management" conversation-management-example)
  (demonstrate-pattern "Salience Allocation" salience-allocation-example)
  (display "All examples completed successfully!\n"))

; Export example functions
(export run-all-examples
        demonstrate-pattern
        empathetic-response
        problem-solving-approach
        comfort-scenario
        learning-scenario
        neural-symbolic-example
        recursive-improvement-example
        mindfulness-chatbot
        multimodal-integration-example
        conversation-management-example
        salience-allocation-example)