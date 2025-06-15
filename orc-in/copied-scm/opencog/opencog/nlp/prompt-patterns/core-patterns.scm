;
; Core Patterns for Prompt-Driven Chatbot Behaviors
; =================================================
;
; This module contains the fundamental cognitive patterns that form
; the foundation for all prompt-driven chatbot behaviors in OpenCog.
;

(use-modules (opencog)
             (opencog nlp)
             (opencog openpsi))

; ==============================================================
; INPUT PROCESSING PATTERNS
; ==============================================================

; Multi-modal input processing pattern
(define (process-multimodal-input text-input audio-input visual-input)
  (let ((processed-text (process-text-input text-input))
        (processed-audio (process-audio-input audio-input))
        (processed-visual (process-visual-input visual-input)))
    (EvaluationLink
      (PredicateNode "multimodal-input-processed")
      (ListLink
        processed-text
        processed-audio
        processed-visual))))

; Text input processing with semantic parsing
(define (process-text-input text)
  (let ((parsed-text (nlp-parse text))
        (semantic-features (extract-semantic-features text))
        (emotional-tone (detect-emotional-tone text)))
    (EvaluationLink
      (PredicateNode "text-processed")
      (ListLink
        (ConceptNode text)
        parsed-text
        semantic-features
        emotional-tone))))

; Extract semantic features from text
(define (extract-semantic-features text)
  (BindLink
    (VariableList
      (VariableNode "$word")
      (VariableNode "$concept"))
    (AndLink
      (EvaluationLink
        (PredicateNode "word-in-text")
        (ListLink (VariableNode "$word") (ConceptNode text)))
      (EvaluationLink
        (PredicateNode "word-concept-mapping")
        (ListLink (VariableNode "$word") (VariableNode "$concept"))))
    (EvaluationLink
      (PredicateNode "semantic-feature")
      (ListLink (ConceptNode text) (VariableNode "$concept")))))

; ==============================================================
; CONTEXT MANAGEMENT PATTERNS
; ==============================================================

; Dynamic context window management
(define conversation-history (ConceptNode "ConversationHistory"))
(define context-window-size 10)

(define (update-conversation-context new-input)
  (let ((current-context (cog-chase-link 'StateLink 'ListLink conversation-history)))
    (if (> (length current-context) context-window-size)
      ; Remove oldest context item
      (let ((updated-context (drop current-context 1)))
        (StateLink conversation-history
          (ListLink (append updated-context (list new-input)))))
      ; Add new input to context
      (StateLink conversation-history
        (ListLink (append current-context (list new-input)))))))

; Context relevance scoring
(define (score-context-relevance context-item current-input)
  (let ((semantic-similarity (compute-semantic-similarity context-item current-input))
        (temporal-decay (compute-temporal-decay context-item))
        (importance-weight (get-importance-weight context-item)))
    (* semantic-similarity temporal-decay importance-weight)))

; ==============================================================
; RESPONSE GENERATION CORE PATTERNS
; ==============================================================

; Adaptive response generation framework
(define (generate-adaptive-response input-analysis context personality-profile)
  (let ((response-candidates (generate-response-candidates input-analysis context))
        (personality-filter (apply-personality-filter personality-profile))
        (coherence-check (ensure-conversational-coherence context)))
    (select-best-response 
      (filter personality-filter response-candidates)
      coherence-check)))

; Response candidate generation
(define (generate-response-candidates input-analysis context)
  (BindLink
    (VariableList
      (VariableNode "$template")
      (VariableNode "$fill-pattern"))
    (AndLink
      (EvaluationLink
        (PredicateNode "response-template-matches")
        (ListLink (VariableNode "$template") input-analysis))
      (EvaluationLink
        (PredicateNode "context-supports")
        (ListLink (VariableNode "$template") context))
      (EvaluationLink
        (PredicateNode "template-fill-pattern")
        (ListLink (VariableNode "$template") (VariableNode "$fill-pattern"))))
    (ExecutionLink
      (SchemaNode "instantiate-response")
      (ListLink (VariableNode "$template") (VariableNode "$fill-pattern")))))

; ==============================================================
; LEARNING AND ADAPTATION PATTERNS
; ==============================================================

; Experience-based pattern learning
(define (learn-from-interaction user-input bot-response user-feedback)
  (let ((interaction-pattern (create-interaction-pattern user-input bot-response))
        (feedback-score (quantify-feedback user-feedback)))
    (if (> feedback-score 0.7)
      ; Positive feedback - strengthen pattern
      (strengthen-pattern interaction-pattern feedback-score)
      ; Negative feedback - weaken pattern and explore alternatives
      (begin
        (weaken-pattern interaction-pattern feedback-score)
        (explore-alternative-patterns user-input)))))

; Pattern strength adjustment
(define (strengthen-pattern pattern strength-delta)
  (let ((current-strength (get-pattern-strength pattern)))
    (set-pattern-strength! pattern (+ current-strength strength-delta))
    (allocate-salience pattern (+ current-strength strength-delta) 0.8)))

(define (weaken-pattern pattern weakness-delta)
  (let ((current-strength (get-pattern-strength pattern)))
    (set-pattern-strength! pattern (max 0.1 (- current-strength weakness-delta)))
    (allocate-salience pattern (max 0.1 (- current-strength weakness-delta)) 0.6)))

; ==============================================================
; ATTENTION AND SALIENCE PATTERNS
; ==============================================================

; Dynamic attention allocation
(define attention-atoms (ConceptNode "AttentionAtoms"))

(define (focus-attention atom-list attention-budget)
  (let ((sorted-atoms (sort-by-salience atom-list))
        (allocated-budget 0))
    (map (lambda (atom)
           (let ((atom-salience (cog-av-sti atom))
                 (allocation-amount (min (* attention-budget 0.1) 
                                       (- attention-budget allocated-budget))))
             (when (> allocation-amount 0)
               (cog-inc-av-sti! atom allocation-amount)
               (set! allocated-budget (+ allocated-budget allocation-amount)))))
         sorted-atoms)))

; Salience decay mechanism
(define (apply-salience-decay decay-rate)
  (map (lambda (atom)
         (let ((current-sti (cog-av-sti atom)))
           (cog-set-av-sti! atom (* current-sti (- 1 decay-rate)))))
       (cog-get-atoms 'Atom)))

; ==============================================================
; UTILITY FUNCTIONS
; ==============================================================

; Compute semantic similarity between two concepts
(define (compute-semantic-similarity concept1 concept2)
  ; Placeholder implementation - would use vector embeddings in practice
  (if (equal? concept1 concept2) 1.0 0.5))

; Temporal decay function
(define (compute-temporal-decay context-item)
  (let ((time-since-creation (get-time-since-creation context-item)))
    (exp (- (* 0.1 time-since-creation)))))

; Get importance weight for context item
(define (get-importance-weight context-item)
  (cog-av-sti context-item))

; Quantify user feedback
(define (quantify-feedback feedback)
  (cond
    ((string-contains feedback "good") 0.8)
    ((string-contains feedback "bad") 0.2)
    ((string-contains feedback "perfect") 1.0)
    ((string-contains feedback "terrible") 0.0)
    (else 0.5)))

; Export core functions
(export process-multimodal-input
        process-text-input
        extract-semantic-features
        update-conversation-context
        score-context-relevance
        generate-adaptive-response
        generate-response-candidates
        learn-from-interaction
        strengthen-pattern
        weaken-pattern
        focus-attention
        apply-salience-decay)