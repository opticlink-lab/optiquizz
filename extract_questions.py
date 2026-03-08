#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Extract questions from Swift files to JSON. Run from web-app/scripts/."""

import re
import json
import os

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
WEB_APP = os.path.join(SCRIPT_DIR, '..')
DATA_DIR = os.path.join(WEB_APP, 'data')
# From web-app/scripts, opticlink app is ../../opticlink
for base in [os.path.join(SCRIPT_DIR, '..', '..', 'opticlink'),
             os.path.join(SCRIPT_DIR, '..', '..', '..', 'opticlink')]:
    OPTICLINK = os.path.abspath(base)
    if os.path.isfile(os.path.join(OPTICLINK, 'Question.swift')):
        break
else:
    OPTICLINK = None

def extract_answers(block, key='answers'):
    """Extract array from block: key: [ "a", "b", ... ] (key is 'answers' or 'options')"""
    start = block.find(key + ': [')
    if start == -1:
        return []
    start += len(key + ': [')
    depth = 1
    i = start
    answers = []
    in_string = False
    escape = False
    quote_char = None
    current = []
    while i < len(block) and depth > 0:
        c = block[i]
        if escape:
            if in_string:
                current.append(c)
            escape = False
            i += 1
            continue
        if c == '\\':
            escape = True
            i += 1
            continue
        if in_string:
            if c == quote_char:
                answers.append(''.join(current).replace('\\n', '\n'))
                current = []
                in_string = False
            else:
                current.append(c)
            i += 1
            continue
        if c == '"':
            in_string = True
            quote_char = c
            current = []
            i += 1
            continue
        if c == '[':
            depth += 1
        elif c == ']':
            depth -= 1
        i += 1
    return answers

def parse_question_block(block):
    """Parse Question( ) interior."""
    out = {}
    m = re.search(r'\btext:\s*"((?:[^"\\]|\\.)*)"', block, re.DOTALL)
    if m:
        out['text'] = m.group(1).replace('\\"', '"').replace('\\n', '\n')
    out['answers'] = extract_answers(block, 'answers')
    m = re.search(r'\bcorrectAnswerIndex:\s*(\d+)', block)
    out['correctAnswerIndex'] = int(m.group(1)) if m else 0
    m = re.search(r'\bdifficulty:\s*\.(facile|moyen|difficile)', block)
    if m:
        out['difficulty'] = m.group(1)
    m = re.search(r'\bexplanation:\s*"((?:[^"\\]|\\.)*)"', block, re.DOTALL)
    if m:
        out['explanation'] = m.group(1).replace('\\"', '"').replace('\\n', '\n')
    return out if out.get('text') and out.get('answers') else None

def parse_etso_block(block):
    """Parse ETSOTheoryQuestion( ) interior."""
    out = {}
    m = re.search(r'\bprompt:\s*"((?:[^"\\]|\\.)*)"', block, re.DOTALL)
    if m:
        out['prompt'] = m.group(1).replace('\\"', '"').replace('\\n', '\n')
    out['options'] = extract_answers(block, 'options')
    out['correctAnswerIndex'] = 0
    return out if out.get('prompt') and out.get('options') else None

def extract_swift_questions(path, marker='Question(', parser=parse_question_block):
    """Split by marker and parse each block. Marker is e.g. 'Question(' or 'ETSOTheoryQuestion('."""
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()
    # Split so we get blocks: "... ) , \n        Question( ..." -> take part after "Question(" until "),\n        Question(" or ")\n    ]"
    parts = content.split(marker)
    questions = []
    for i in range(1, len(parts)):
        block = parts[i]
        # End of this question: "        )," at start of line (same indent as Question)
        end = re.search(r'\n\s+\),\s*(?:\n|$)', block)
        if end:
            block = block[:end.start()]
        q = parser(block)
        if q:
            questions.append(q)
    return questions

def main():
    if not OPTICLINK:
        print('Question.swift not found')
        return
    os.makedirs(DATA_DIR, exist_ok=True)

    # PDM
    path = os.path.join(OPTICLINK, 'Question.swift')
    if os.path.isfile(path):
        questions = extract_swift_questions(path, 'Question(', parse_question_block)
        with open(os.path.join(DATA_DIR, 'pdm.json'), 'w', encoding='utf-8') as f:
            json.dump({'title': 'PDM – Questions', 'questions': questions}, f, ensure_ascii=False, indent=2)
        print('PDM:', len(questions), 'questions')

    # ETSO
    path = os.path.join(OPTICLINK, 'ETSO', 'ETSOHybridTheory.swift')
    if os.path.isfile(path):
        questions = extract_swift_questions(path, 'ETSOTheoryQuestion(', parse_etso_block)
        with open(os.path.join(DATA_DIR, 'etso.json'), 'w', encoding='utf-8') as f:
            json.dump({'title': 'ETSO – Étude des Systèmes Optiques', 'questions': questions}, f, ensure_ascii=False, indent=2)
        print('ETSO:', len(questions), 'questions')

    # Vision
    path = os.path.join(OPTICLINK, 'VisionAnalysisQuestions.swift')
    if os.path.isfile(path):
        questions = extract_swift_questions(path, 'Question(', parse_question_block)
        with open(os.path.join(DATA_DIR, 'vision.json'), 'w', encoding='utf-8') as f:
            json.dump({'title': 'Analyse de la vision', 'questions': questions}, f, ensure_ascii=False, indent=2)
        print('Vision:', len(questions), 'questions')

    # Optique
    path = os.path.join(OPTICLINK, 'GeometricOpticsQuestions.swift')
    if os.path.isfile(path):
        questions = extract_swift_questions(path, 'Question(', parse_question_block)
        with open(os.path.join(DATA_DIR, 'optique.json'), 'w', encoding='utf-8') as f:
            json.dump({'title': 'Optique géométrique', 'questions': questions}, f, ensure_ascii=False, indent=2)
        print('Optique:', len(questions), 'questions')

if __name__ == '__main__':
    main()
