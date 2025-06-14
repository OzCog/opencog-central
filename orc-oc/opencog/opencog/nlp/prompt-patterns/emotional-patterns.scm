;
; Emotional Patterns for Empathy and Emotional Modeling
; =====================================================
;
; This module implements sophisticated emotional modeling patterns
; optimized for empathetic chatbot responses and emotional intelligence.
;

(use-modules (opencog)
             (opencog nlp)
             (opencog openpsi))

; ==============================================================
; EMOTIONAL STATE MODELING
; ==============================================================

; Core emotional states in the system
(define emotional-states
  (list (ConceptNode "joy")
        (ConceptNode "sadness") 
        (ConceptNode "anger")
        (ConceptNode "fear")
        (ConceptNode "surprise")
        (ConceptNode "disgust")
        (ConceptNode "trust")
        (ConceptNode "anticipation")))

; User emotional state tracking
(define user-emotional-state (ConceptNode "UserEmotionalState"))
(define bot-emotional-state (ConceptNode "BotEmotionalState"))

; Emotion detection from text input
(define (detect-emotional-tone text)
  (BindLink
    (VariableList
      (VariableNode "$emotion")
      (VariableNode "$intensity"))
    (AndLink
      (EvaluationLink
        (PredicateNode "text-contains-emotional-markers")
        (ListLink (ConceptNode text) (VariableNode "$emotion")))
      (EvaluationLink
        (PredicateNode "emotional-intensity")
        (ListLink (VariableNode "$emotion") (VariableNode "$intensity"))))
    (EvaluationLink
      (PredicateNode "detected-emotion")
      (ListLink 
        (ConceptNode text)
        (VariableNode "$emotion")
        (VariableNode "$intensity")))))

; Multi-modal emotion detection
(define (detect-multimodal-emotion text-emotion voice-emotion facial-emotion)
  (let ((weighted-emotions 
          (list (* 0.4 text-emotion)
                (* 0.3 voice-emotion)
                (* 0.3 facial-emotion))))
    (EvaluationLink
      (PredicateNode "multimodal-emotion")
      (ListLink
        (NumberNode (apply + weighted-emotions))
        (ConceptNode "combined-emotional-assessment")))))

; ==============================================================
; EMPATHY GENERATION PATTERNS
; ==============================================================

; Empathetic response pattern based on detected emotion
(define (generate-empathetic-response detected-emotion intensity context)
  (BindLink
    (VariableList
      (VariableNode "$empathy-template")
      (VariableNode "$response-modifier"))
    (AndLink
      (EvaluationLink
        (PredicateNode "empathy-template-for-emotion")
        (ListLink detected-emotion (VariableNode "$empathy-template")))
      (EvaluationLink
        (PredicateNode "intensity-modifier")
        (ListLink intensity (VariableNode "$response-modifier")))
      (EvaluationLink
        (PredicateNode "context-appropriate")
        (ListLink context (VariableNode "$empathy-template"))))
    (ExecutionLink
      (SchemaNode "generate-empathetic-utterance")
      (ListLink 
        (VariableNode "$empathy-template")
        (VariableNode "$response-modifier")
        context))))

; Emotional validation patterns
(define emotional-validation-templates
  (list
    ; For sadness
    (ImplicationLink
      (EvaluationLink
        (PredicateNode "user-emotion")
        (ListLink (ConceptNode "sadness")))
      (ExecutionLink
        (SchemaNode "express-validation")
        (ListLink 
          (ConceptNode "I can see that you're feeling sad")
          (ConceptNode "That sounds really difficult")
          (ConceptNode "Your feelings are completely valid"))))
    
    ; For anger
    (ImplicationLink
      (EvaluationLink
        (PredicateNode "user-emotion")
        (ListLink (ConceptNode "anger")))
      (ExecutionLink
        (SchemaNode "express-validation")
        (ListLink
          (ConceptNode "I can hear the frustration in your words")
          (ConceptNode "It's understandable that you'd feel angry about this")
          (ConceptNode "Your anger makes sense given the situation"))))
    
    ; For anxiety/fear
    (ImplicationLink
      (EvaluationLink
        (PredicateNode "user-emotion")
        (ListLink (ConceptNode "fear")))
      (ExecutionLink
        (SchemaNode "express-validation")
        (ListLink
          (ConceptNode "That sounds really scary")
          (ConceptNode "It's natural to feel anxious about this")
          (ConceptNode "Many people would feel the same way"))))))

; ==============================================================
; EMOTIONAL CONTAGION AND MIRRORING
; ==============================================================

; Emotional mirroring for rapport building
(define (mirror-user-emotion user-emotion intensity-level)
  (let ((mirrored-intensity (* intensity-level 0.7))) ; Bot shows slightly less intensity
    (StateLink bot-emotional-state
      (ListLink 
        user-emotion
        (NumberNode mirrored-intensity)
        (ConceptNode "mirrored-emotion")))
    (EvaluationLink
      (PredicateNode "emotional-mirroring-active")
      (ListLink user-emotion (NumberNode mirrored-intensity)))))

; Emotional regulation patterns
(define (regulate-bot-emotion current-emotion target-emotion transition-rate)
  (let ((current-intensity (get-emotion-intensity current-emotion))
        (target-intensity (get-emotion-intensity target-emotion))
        (adjustment (* transition-rate (- target-intensity current-intensity))))
    (set-emotion-intensity! current-emotion (+ current-intensity adjustment))
    (EvaluationLink
      (PredicateNode "emotion-regulated")
      (ListLink current-emotion (NumberNode adjustment)))))

; ==============================================================
; EMOTIONAL MEMORY AND LEARNING
; ==============================================================

; Store emotional interactions for learning
(define emotional-memory (ConceptNode "EmotionalMemory"))

(define (store-emotional-interaction user-input detected-emotion bot-response user-feedback)
  (let ((interaction-pattern
          (ListLink
            user-input
            detected-emotion
            bot-response
            user-feedback
            (ConceptNode (number->string (current-time))))))
    (MemberLink interaction-pattern emotional-memory)
    (evaluate-emotional-response-effectiveness bot-response user-feedback)))

; Learn emotional response patterns
(define (learn-emotional-patterns)
  (BindLink
    (VariableList
      (VariableNode "$emotion")
      (VariableNode "$response")
      (VariableNode "$feedback"))
    (AndLink
      (MemberLink
        (ListLink 
          (VariableNode "$input")
          (VariableNode "$emotion")
          (VariableNode "$response")
          (VariableNode "$feedback")
          (VariableNode "$timestamp"))
        emotional-memory)
      (EvaluationLink
        (PredicateNode "positive-feedback")
        (VariableNode "$feedback")))
    (EvaluationLink
      (PredicateNode "effective-emotional-pattern")
      (ListLink (VariableNode "$emotion") (VariableNode "$response")))))

; ==============================================================
; EMOTIONAL SUPPORT STRATEGIES
; ==============================================================

; Progressive emotional support strategy
(define (provide-emotional-support emotional-state support-level)
  (cond
    ; Level 1: Acknowledgment and validation
    ((= support-level 1)
     (ExecutionLink
       (SchemaNode "acknowledge-emotion")
       (ListLink emotional-state)))
    
    ; Level 2: Empathetic reflection
    ((= support-level 2)
     (ExecutionLink
       (SchemaNode "reflect-emotion")
       (ListLink emotional-state (ConceptNode "empathetic-reflection"))))
    
    ; Level 3: Supportive guidance
    ((= support-level 3)
     (ExecutionLink
       (SchemaNode "offer-support")
       (ListLink emotional-state (ConceptNode "guided-support"))))
    
    ; Level 4: Coping strategies
    ((= support-level 4)
     (ExecutionLink
       (SchemaNode "suggest-coping-strategies")
       (ListLink emotional-state)))))

; Mindfulness-based emotional regulation
(define (suggest-mindfulness-practice emotional-state)
  (cond
    ((equal? emotional-state (ConceptNode "anxiety"))
     (ConceptNode "Try taking three deep breaths. Breathe in for 4 counts, hold for 4, and breathe out for 6."))
    ((equal? emotional-state (ConceptNode "anger"))
     (ConceptNode "Let's take a moment to notice what you're feeling in your body. Where do you feel the anger?"))
    ((equal? emotional-state (ConceptNode "sadness"))
     (ConceptNode "It's okay to sit with this feeling. Can you notice any other sensations you're experiencing right now?"))
    (else
     (ConceptNode "Let's take a moment to pause and notice what you're experiencing right now, without judgment."))))

; ==============================================================
; EMOTIONAL INTELLIGENCE METRICS
; ==============================================================

; Measure emotional response appropriateness
(define (measure-emotional-appropriateness bot-emotion user-emotion context)
  (let ((emotion-match-score (compute-emotion-compatibility bot-emotion user-emotion))
        (context-appropriateness (assess-emotional-context-fit bot-emotion context))
        (timing-score (evaluate-emotional-timing bot-emotion)))
    (EvaluationLink
      (PredicateNode "emotional-appropriateness")
      (ListLink
        (NumberNode emotion-match-score)
        (NumberNode context-appropriateness)
        (NumberNode timing-score)
        (NumberNode (* 0.4 emotion-match-score 0.3 context-appropriateness 0.3 timing-score))))))

; ==============================================================
; UTILITY FUNCTIONS
; ==============================================================

; Get emotion intensity from emotional state
(define (get-emotion-intensity emotion)
  (let ((emotion-link (cog-chase-link 'StateLink 'ListLink emotion)))
    (if (not (null? emotion-link))
      (cog-name (cadr emotion-link))
      0.5))) ; Default intensity

; Set emotion intensity
(define (set-emotion-intensity! emotion intensity)
  (StateLink emotion (NumberNode intensity)))

; Evaluate emotional response effectiveness
(define (evaluate-emotional-response-effectiveness response feedback)
  (cond
    ((string-contains (cog-name feedback) "helpful") 0.9)
    ((string-contains (cog-name feedback) "understanding") 0.8)
    ((string-contains (cog-name feedback) "cold") 0.2)
    ((string-contains (cog-name feedback) "inappropriate") 0.1)
    (else 0.5)))

; Compute emotion compatibility score
(define (compute-emotion-compatibility bot-emotion user-emotion)
  ; Simplified compatibility matrix - in practice would be more sophisticated
  (cond
    ((and (equal? bot-emotion (ConceptNode "empathy"))
          (member user-emotion (list (ConceptNode "sadness") (ConceptNode "fear"))))
     0.9)
    ((and (equal? bot-emotion (ConceptNode "calm"))
          (equal? user-emotion (ConceptNode "anger")))
     0.8)
    ((equal? bot-emotion user-emotion) 0.7)
    (else 0.5)))

; Export emotional functions
(export detect-emotional-tone
        detect-multimodal-emotion
        generate-empathetic-response
        emotional-validation-templates
        mirror-user-emotion
        regulate-bot-emotion
        store-emotional-interaction
        learn-emotional-patterns
        provide-emotional-support
        suggest-mindfulness-practice
        measure-emotional-appropriateness)