;
; Dialogue Patterns for Supportive and Contextual Conversation
; ===========================================================
;
; This module implements advanced dialogue management patterns
; for maintaining coherent, supportive, and contextually appropriate
; conversations across multiple turns and topics.
;

(use-modules (opencog)
             (opencog nlp)
             (opencog openpsi))

; ==============================================================
; DIALOGUE STATE MANAGEMENT
; ==============================================================

; Dialogue state representation
(define dialogue-state (ConceptNode "DialogueState"))
(define current-topic (ConceptNode "CurrentTopic"))
(define dialogue-intent (ConceptNode "DialogueIntent"))
(define conversation-flow (ConceptNode "ConversationFlow"))

; Dialogue state transitions
(define (transition-dialogue-state current-state trigger new-state)
  (ImplicationLink
    (AndLink
      (EvaluationLink
        (PredicateNode "current-dialogue-state")
        (ListLink current-state))
      (EvaluationLink
        (PredicateNode "dialogue-trigger")
        (ListLink trigger)))
    (ExecutionLink
      (SchemaNode "update-dialogue-state")
      (ListLink new-state))))

; Common dialogue states
(define dialogue-states
  (list (ConceptNode "greeting")
        (ConceptNode "information-gathering")
        (ConceptNode "problem-solving")
        (ConceptNode "emotional-support")
        (ConceptNode "casual-conversation")
        (ConceptNode "closure")
        (ConceptNode "crisis-intervention")))

; ==============================================================
; SUPPORTIVE DIALOGUE PATTERNS
; ==============================================================

; Active listening pattern
(define (demonstrate-active-listening user-input)
  (let ((key-elements (extract-key-elements user-input))
        (emotional-content (extract-emotional-content user-input))
        (factual-content (extract-factual-content user-input)))
    (ExecutionLink
      (SchemaNode "active-listening-response")
      (ListLink
        (generate-reflection key-elements)
        (acknowledge-emotions emotional-content)
        (clarifying-questions factual-content)))))

; Reflection techniques
(define (generate-reflection key-elements)
  (BindLink
    (VariableList
      (VariableNode "$element")
      (VariableNode "$reflection-template"))
    (AndLink
      (MemberLink (VariableNode "$element") key-elements)
      (EvaluationLink
        (PredicateNode "reflection-template-for")
        (ListLink (VariableNode "$element") (VariableNode "$reflection-template"))))
    (ExecutionLink
      (SchemaNode "instantiate-reflection")
      (ListLink (VariableNode "$reflection-template") (VariableNode "$element")))))

; Validation and normalization patterns
(define supportive-validation-patterns
  (list
    ; Normalize difficult experiences
    (ImplicationLink
      (EvaluationLink
        (PredicateNode "user-expresses")
        (ListLink (ConceptNode "self-criticism")))
      (ExecutionLink
        (SchemaNode "normalize-experience")
        (ListLink 
          (ConceptNode "Many people go through similar experiences")
          (ConceptNode "What you're feeling is completely normal"))))
    
    ; Validate emotional experiences
    (ImplicationLink
      (EvaluationLink
        (PredicateNode "user-expresses")
        (ListLink (ConceptNode "emotional-struggle")))
      (ExecutionLink
        (SchemaNode "validate-emotions")
        (ListLink
          (ConceptNode "Your feelings are valid and important")
          (ConceptNode "It takes courage to share what you're going through"))))
    
    ; Encourage self-compassion
    (ImplicationLink
      (EvaluationLink
        (PredicateNode "user-expresses")
        (ListLink (ConceptNode "harsh-self-judgment")))
      (ExecutionLink
        (SchemaNode "encourage-self-compassion")
        (ListLink
          (ConceptNode "How would you talk to a good friend in this situation?")
          (ConceptNode "You deserve the same kindness you'd show others"))))))

; ==============================================================
; CONVERSATIONAL COHERENCE PATTERNS
; ==============================================================

; Topic tracking and coherence maintenance
(define (maintain-topic-coherence user-input current-topics)
  (let ((input-topics (extract-topics user-input))
        (topic-similarity (compute-topic-similarity input-topics current-topics))
        (coherence-threshold 0.6))
    (if (> topic-similarity coherence-threshold)
      ; Continue current topic thread
      (ExecutionLink
        (SchemaNode "continue-topic-thread")
        (ListLink current-topics input-topics))
      ; Gracefully transition to new topic
      (ExecutionLink
        (SchemaNode "transition-topic")
        (ListLink current-topics input-topics)))))

; Conversational bridging patterns
(define (create-conversational-bridge old-topic new-topic)
  (BindLink
    (VariableList
      (VariableNode "$bridge-phrase")
      (VariableNode "$transition-type"))
    (AndLink
      (EvaluationLink
        (PredicateNode "topic-relationship")
        (ListLink old-topic new-topic (VariableNode "$transition-type")))
      (EvaluationLink
        (PredicateNode "bridge-phrase-for-transition")
        (ListLink (VariableNode "$transition-type") (VariableNode "$bridge-phrase"))))
    (ExecutionLink
      (SchemaNode "generate-topic-bridge")
      (ListLink old-topic new-topic (VariableNode "$bridge-phrase")))))

; ==============================================================
; QUESTION GENERATION PATTERNS
; ==============================================================

; Socratic questioning for deeper exploration
(define (generate-socratic-questions topic depth-level)
  (cond
    ; Surface level - clarification
    ((= depth-level 1)
     (list "Can you tell me more about that?"
           "What was that experience like for you?"
           "How did that make you feel?"))
    
    ; Mid level - exploration
    ((= depth-level 2)
     (list "What do you think might be contributing to this situation?"
           "Have you noticed any patterns in how this affects you?"
           "What would it look like if things were different?"))
    
    ; Deep level - insight
    ((= depth-level 3)
     (list "What would you say to someone else in your situation?"
           "What have you learned about yourself through this experience?"
           "How might this challenge be an opportunity for growth?"))))

; Context-sensitive question generation
(define (generate-contextual-questions context emotional-state)
  (BindLink
    (VariableList
      (VariableNode "$question-template")
      (VariableNode "$context-factor"))
    (AndLink
      (EvaluationLink
        (PredicateNode "question-appropriate-for-context")
        (ListLink context (VariableNode "$question-template")))
      (EvaluationLink
        (PredicateNode "question-sensitive-to-emotion")
        (ListLink emotional-state (VariableNode "$question-template")))
      (EvaluationLink
        (PredicateNode "context-factor")
        (ListLink context (VariableNode "$context-factor"))))
    (ExecutionLink
      (SchemaNode "instantiate-contextual-question")
      (ListLink (VariableNode "$question-template") (VariableNode "$context-factor")))))

; ==============================================================
; COLLABORATIVE PROBLEM-SOLVING PATTERNS
; ==============================================================

; Structured problem exploration
(define (explore-problem-collaboratively problem-description)
  (let ((problem-elements (decompose-problem problem-description))
        (available-resources (identify-resources))
        (potential-solutions (brainstorm-solutions problem-elements)))
    (ExecutionLink
      (SchemaNode "collaborative-problem-solving")
      (ListLink
        problem-elements
        available-resources
        potential-solutions))))

; Solution co-creation patterns
(define (co-create-solutions problem user-preferences user-constraints)
  (BindLink
    (VariableList
      (VariableNode "$solution-approach")
      (VariableNode "$implementation-step"))
    (AndLink
      (EvaluationLink
        (PredicateNode "solution-addresses-problem")
        (ListLink (VariableNode "$solution-approach") problem))
      (EvaluationLink
        (PredicateNode "aligns-with-preferences")
        (ListLink (VariableNode "$solution-approach") user-preferences))
      (EvaluationLink
        (PredicateNode "respects-constraints")
        (ListLink (VariableNode "$solution-approach") user-constraints))
      (EvaluationLink
        (PredicateNode "implementation-step-for")
        (ListLink (VariableNode "$solution-approach") (VariableNode "$implementation-step"))))
    (ExecutionLink
      (SchemaNode "propose-collaborative-solution")
      (ListLink (VariableNode "$solution-approach") (VariableNode "$implementation-step")))))

; ==============================================================
; CONVERSATIONAL REPAIR PATTERNS
; ==============================================================

; Misunderstanding detection and repair
(define (detect-conversational-breakdown user-input bot-response user-reaction)
  (let ((confusion-indicators (detect-confusion-signals user-reaction))
        (misalignment-score (assess-response-alignment bot-response user-input))
        (repair-needed (or confusion-indicators (< misalignment-score 0.5))))
    (if repair-needed
      (ExecutionLink
        (SchemaNode "initiate-conversational-repair")
        (ListLink user-input bot-response user-reaction))
      (ConceptNode "no-repair-needed"))))

; Repair strategies
(define conversational-repair-strategies
  (list
    ; Clarification request
    (ImplicationLink
      (EvaluationLink
        (PredicateNode "repair-type")
        (ListLink (ConceptNode "misunderstanding")))
      (ExecutionLink
        (SchemaNode "request-clarification")
        (ListLink 
          (ConceptNode "I want to make sure I understand you correctly")
          (ConceptNode "Could you help me understand what you meant by..."))))
    
    ; Acknowledgment of confusion
    (ImplicationLink
      (EvaluationLink
        (PredicateNode "repair-type")
        (ListLink (ConceptNode "bot-confusion")))
      (ExecutionLink
        (SchemaNode "acknowledge-confusion")
        (ListLink
          (ConceptNode "I'm not sure I followed that completely")
          (ConceptNode "Could you explain that in a different way?"))))
    
    ; Reframe and check
    (ImplicationLink
      (EvaluationLink
        (PredicateNode "repair-type")
        (ListLink (ConceptNode "misalignment")))
      (ExecutionLink
        (SchemaNode "reframe-and-check")
        (ListLink
          (ConceptNode "Let me see if I understand what you're saying")
          (ConceptNode "Is that capturing what you meant?"))))))

; ==============================================================
; CLOSURE AND TRANSITION PATTERNS
; ==============================================================

; Conversation closure with emotional check-in
(define (create-supportive-closure conversation-summary)
  (ExecutionLink
    (SchemaNode "supportive-closure")
    (ListLink
      (summarize-key-insights conversation-summary)
      (acknowledge-user-sharing)
      (offer-continued-support)
      (provide-emotional-check-in))))

; Transition to different support modalities
(define (suggest-additional-support user-needs support-preferences)
  (BindLink
    (VariableList
      (VariableNode "$support-type")
      (VariableNode "$support-resource"))
    (AndLink
      (EvaluationLink
        (PredicateNode "support-type-addresses-need")
        (ListLink (VariableNode "$support-type") user-needs))
      (EvaluationLink
        (PredicateNode "aligns-with-preferences")
        (ListLink (VariableNode "$support-type") support-preferences))
      (EvaluationLink
        (PredicateNode "available-resource")
        (ListLink (VariableNode "$support-type") (VariableNode "$support-resource"))))
    (ExecutionLink
      (SchemaNode "suggest-support-resource")
      (ListLink (VariableNode "$support-type") (VariableNode "$support-resource")))))

; ==============================================================
; UTILITY FUNCTIONS
; ==============================================================

; Extract key elements from user input
(define (extract-key-elements input)
  (map ConceptNode
    (filter (lambda (word) (> (string-length word) 3))
      (string-split (cog-name input) #\space))))

; Extract emotional content
(define (extract-emotional-content input)
  (filter (lambda (word)
    (member word '("feel" "feeling" "emotions" "sad" "happy" "angry" "scared")))
    (string-split (cog-name input) #\space)))

; Compute topic similarity
(define (compute-topic-similarity topics1 topics2)
  (let ((intersection-size (length (lset-intersection equal? topics1 topics2)))
        (union-size (length (lset-union equal? topics1 topics2))))
    (if (> union-size 0)
      (/ intersection-size union-size)
      0)))

; Export dialogue functions
(export transition-dialogue-state
        demonstrate-active-listening
        generate-reflection
        supportive-validation-patterns
        maintain-topic-coherence
        create-conversational-bridge
        generate-socratic-questions
        generate-contextual-questions
        explore-problem-collaboratively
        co-create-solutions
        detect-conversational-breakdown
        conversational-repair-strategies
        create-supportive-closure
        suggest-additional-support)