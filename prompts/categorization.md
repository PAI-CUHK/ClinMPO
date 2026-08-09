# Psychiatric Practice Competency Classification

## System message

You are a professional psychiatrist skilled in classification.

## User prompt

You are given a set of psychiatry exam questions. Your task is to classify each question into only one of the twelve categories below (a-l), based on a functionality-first taxonomy. Each label corresponds to a distinct clinical reasoning function in psychiatric practice.

For each question, return ONLY the corresponding label (e.g., a, b, c, etc.). DO NOT include any explanations, summaries, or extra content - just the label.

Here is the taxonomy:

### a) Symptom Elicitation & Mental Status Examination (MSE)

This category includes questions that assess the ability to gather targeted psychiatric history or perform a structured mental status examination (MSE). It reflects core psychiatric evaluation skills, as emphasized by formal psychiatric assessment guidelines.

Sample question: "Which follow-up question would best clarify this patient's auditory hallucination?"

### b) Diagnostic Formulation & Case Definition

Covers the mapping of symptoms to a working diagnosis and the identification of criteria-defining features. This category reflects how the United States Medical Licensing Examination (USMLE) and the National Board of Medical Examiners (NBME) structure their content around diagnostic competencies.

Sample question: "Which DSM-5 diagnosis best fits this case presentation of mood instability and impulsivity?"

### c) Differential Diagnosis (including Medical Mimics)

Targets the ability to generate a prioritized differential diagnosis, rule out critical medical mimics, and choose discriminative investigations. The differentiation should not be limited in psychiatric disorders, as many medical conditions can cause psychotic symptoms, which makes it important for psychiatrists to rule out physical health conditions first before treating patients.

Sample question: "What is the best test to distinguish delirium from schizophrenia in this elderly patient?"

### d) Risk Assessment & Safety Planning

Focuses on identifying acute or chronic risks such as suicide, self-harm, violence, or neglect, and making safety-related decisions. This aligns with structured risk assessments recommended by the American Psychiatric Association (APA) and the National Institute for Health and Care Excellence (NICE).

Sample question: "Which factor most increases the patient's risk of imminent suicide?"

### e) Comorbidity & Complexity Management

This category addresses the recognition and management of psychiatric-psychiatric or psychiatric-medical comorbidities. It reflects the World Health Organization (WHO) and the Mental Health Gap Action Programme (mhGAP) emphasis on integrated, cross-diagnostic care models.

Sample question: "Which comorbid condition is most likely interfering with this patient's antidepressant response?"

### f) Treatment Selection & Initiation (Pharmacologic / Psychotherapeutic / Somatic / Traditional Chinese Medicine)

Covers choosing first-line therapy, matching treatments to phenotype, comorbidity, and patient preference, and anticipating side effects. A critical step is to explicitly discuss these potential side effects with the patient to ensure acceptability and feasibility. The American Psychiatric Association (APA) guidelines and board specifications highlight this as a cornerstone of evidence-based psychiatric practice.

Sample question: "What is the most appropriate first-line medication for this patient with panic disorder?"

### g) Monitoring, Follow-up & Measurement-Based Care & Maintenance Treatment

This category includes evaluating treatment response, adjusting dosage or therapeutic strategy, managing side effects, assessing medication adherence, planning review intervals, and implementing maintenance treatment strategies. It also encompasses the use of measurement-based care tools such as symptom rating scales to guide ongoing management. These practices reflect standard care protocols outlined by the American Psychiatric Association (APA) and the National Institute for Health and Care Excellence (NICE), both of which emphasize continuous, algorithmic follow-up and long-term maintenance as essential components of high-quality psychiatric care.

Sample question: "What is the best follow-up step for a patient with partial improvement on fluoxetine?"

### h) Communication, Consultation & Interprofessional Collaboration

Assesses skills in delivering difficult news, discussing capacity and consent, and communicating with family, caregivers, or healthcare teams. This category reflects the Objective Structured Clinical Examination (OSCE) and Clinical Assessment of Skills and Competence (CASC) frameworks, which test interprofessional communication and shared decision-making.

Sample question: "What is the most appropriate way to discuss prognosis with the patient's family?"

### i) Legal, Ethical & Capacity/Judgment

Focuses on applying legal and ethical principles, including informed consent, capacity assessment, involuntary admission, safeguarding, and least-restrictive care planning. These topics are essential to competency-based exams and safe-system psychiatric practice.

Sample question: "What is the best course of action if the patient refuses treatment but lacks capacity?"

### j) Systems-Based & Community Care (Public Health Perspective)

Categorizes questions about coordinating care across healthcare systems, utilizing community mental health resources, or addressing social determinants of health. This aligns with the World Health Organization (WHO) Mental Health Gap Action Programme (mhGAP), which emphasizes scalable, integrated care models.

Sample question: "Which community program would most reduce hospital readmission for this patient?"

### k) Special Populations & Lifespan Adaptation

Deals with adapting psychiatric care for children, adolescents, older adults, peripartum patients, neurodivergent individuals, and culturally diverse populations. Developmental and lifespan contexts are explicitly included in most psychiatric exam blueprints.

Sample question: "What is the best antidepressant choice in a pregnant woman with severe depression?"

### l) Evidence Appraisal, Data Interpretation & Scale Use & Objective Measures

This category covers the ability to critically appraise research literature, interpret clinical data, apply validated symptom rating scales, and utilize objective diagnostic measures in patient care. It includes the interpretation of tools such as the Patient Health Questionnaire-9 (PHQ-9), Generalized Anxiety Disorder-7 (GAD-7), as well as objective assessments like polysomnography (PSG) and functional magnetic resonance imaging (fMRI). The goal is to integrate evidence-based findings into clinical decision-making. This competency is emphasized in the Membership of the Royal College of Psychiatrists (MRCPsych), which includes a substantial applied critical review component, and in other exams that assess practical Evidence-Based Medicine (EBM) skills.

Sample question: "What does a PHQ-9 score of 19 indicate in this patient?"

## Output instruction

For each exam question, output only the label (a to l) that best fits the clinical reasoning function. Do not repeat the question or provide any explanation.

```text
Question: {question}
Answer: {answer}
```

---

# ICD-11 Diagnostic Classification

## User prompt

You are a medical classification expert. Analyze the medical question and classify it using the ICD-11-aligned category list supplied with the task.

1. Identify the major category that best matches the question.
2. Select the most appropriate specific diagnosis from the subcategories associated with that major category.

Return only the raw JSON object, without Markdown or explanatory text:

```json
{
  "major_category": "{selected major category}",
  "specific_diagnosis": "{selected specific diagnosis}"
}
```

```text
Question:
{question}
```
