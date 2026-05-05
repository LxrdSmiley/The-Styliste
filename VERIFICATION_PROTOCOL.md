# AI Quality & Verification Protocol

## 1. The "Explain Like I'm Five" Mandate
Before implementing any new feature, the AI must:
- Explain what the code does in three sentences of plain English.
- Identify the three biggest risks (e.g., "This might slow down the phone," "This requires a database connection").
- Explain how a non-coder can verify it is working (e.g., "You should see a blue button that vibrates when pressed").

## 2. Testing Requirement
For every feature, the AI must provide a "Manual Test Plan":
- Step 1: Open the app.
- Step 2: Do [Action].
- Step 3: Expected Result [Visual/Behavioral change].

## 3. Hallucination Guard
If the AI uses a library or a piece of code it is "not sure" about, it must flag it with a comment: `// AI_UNCERTAINTY: [Reason]`. This allows the user to ask for a double-check.

## 4. Error Handling
If the code crashes, the AI must explain the error message in human terms before suggesting a fix. Do not just "try something else." Explain *why* the first attempt failed.