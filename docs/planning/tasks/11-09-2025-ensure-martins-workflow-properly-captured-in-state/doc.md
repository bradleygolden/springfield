<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE task PUBLIC "-//OASIS//DTD DITA Task//EN" "task.dtd">
<task id="martin-state-workflow-fix" xml:lang="en-us">
<title>Fix Martin Phase State Tracking in Springfield Workflow</title>
<shortdesc>Correct state transition logic in Frink and Skinner scripts to ensure Martin's documentation phase is properly tracked and sequenced in the Springfield orchestration workflow.</shortdesc>
<prolog>
<metadata>
<keywords>
<keyword>state management</keyword>
<keyword>workflow orchestration</keyword>
<keyword>phase transitions</keyword>
<keyword>Martin Prince</keyword>
<keyword>Springfield</keyword>
</keywords>
</metadata>
</prolog>
<taskbody>

<context>
<p><b>According to my thorough analysis, this task addresses a critical workflow sequencing issue!</b></p>

<p>Martin Prince's documentation phase was recently added to the Springfield workflow (v1.3.0) to create prospective documentation before Ralph's implementation phase. However, Lisa's research has identified that the state transition logic in <filepath>scripts/frink.sh</filepath> incorrectly bypasses Martin's phase by transitioning directly to Ralph. This causes:</p>

<ul>
<li>Incorrect state.json transitions showing <codeph>frink → ralph</codeph> instead of <codeph>frink → martin</codeph></li>
<li>Duplicate transition entries in the transitions array</li>
<li>Workflow sequence violations where Martin's phase may not be properly invoked</li>
</ul>

<p><b>Intended Workflow Sequences:</b></p>
<codeblock>SIMPLE:  lisa → quimby → frink → martin → ralph → comic-book-guy
COMPLEX: lisa → quimby → frink → skinner → frink → martin → ralph → comic-book-guy</codeblock>

<p><b>Current Broken Behavior:</b> Frink sets <codeph>NEXT_PHASE="ralph"</codeph> in both SIMPLE and post-Skinner paths, creating incorrect transitions that skip Martin in state tracking.</p>
</context>

<prereq>
<p><b>Required Context Files (All present and accounted for!):</b></p>
<ul>
<li><filepath>.springfield/11-09-2025-ensure-martins-workflow-properly-captured-in-state/research.md</filepath> - Lisa's comprehensive analysis</li>
<li><filepath>.springfield/11-09-2025-ensure-martins-workflow-properly-captured-in-state/decision.txt</filepath> - Mayor Quimby's SIMPLE complexity assessment</li>
<li><filepath>.springfield/11-09-2025-ensure-martins-workflow-properly-captured-in-state/prompt.md</filepath> - Professor Frink's implementation plan</li>
</ul>

<p><b>Files to be Modified:</b></p>
<ul>
<li><filepath>scripts/frink.sh</filepath> - Primary fix location (2 lines)</li>
<li><filepath>scripts/skinner.sh</filepath> - Optional transition recording enhancement</li>
</ul>
</prereq>

<steps>
<step>
<cmd>Update Frink's SIMPLE path transition target</cmd>
<stepxmp>
<p><b>Location:</b> <filepath>scripts/frink.sh</filepath> line ~188</p>
<p><b>Current Code:</b></p>
<codeblock>NEXT_PHASE="ralph"  # After creating prompt.md for SIMPLE tasks</codeblock>
<p><b>Corrected Code:</b></p>
<codeblock>NEXT_PHASE="martin"  # Transition to Martin's documentation phase</codeblock>
</stepxmp>
<info>
<p>This fixes the SIMPLE workflow path where Frink creates <filepath>prompt.md</filepath> directly without Skinner review. The transition must route to Martin for prospective documentation before implementation.</p>
</info>
</step>

<step>
<cmd>Update Frink's post-Skinner path transition target</cmd>
<stepxmp>
<p><b>Location:</b> <filepath>scripts/frink.sh</filepath> line ~143</p>
<p><b>Current Code:</b></p>
<codeblock>NEXT_PHASE="ralph"  # After incorporating review.md feedback</codeblock>
<p><b>Corrected Code:</b></p>
<codeblock>NEXT_PHASE="martin"  # Transition to Martin's documentation phase</codeblock>
</stepxmp>
<info>
<p>This fixes the COMPLEX workflow path where Frink incorporates Skinner's review feedback into the final prompt. Even in COMPLEX paths, Martin must create the PRD before Ralph implements.</p>
</info>
</step>

<step importance="optional">
<cmd>Add explicit transition recording to Skinner's completion</cmd>
<stepxmp>
<p><b>Location:</b> <filepath>scripts/skinner.sh</filepath> lines ~159-169</p>
<p><b>Current Code:</b></p>
<codeblock>jq --arg timestamp "$TIMESTAMP" \
   '.phases.skinner.status = "complete" |
    .phases.skinner.end_time = $timestamp |
    .phases.skinner.reviewed = true |
    .phases.skinner.output_file = "review.md"' \
   "$STATE_FILE" > "$TMP_STATE"</codeblock>
<p><b>Enhanced Code:</b></p>
<codeblock>jq --arg timestamp "$TIMESTAMP" \
   '.phases.skinner.status = "complete" |
    .phases.skinner.end_time = $timestamp |
    .phases.skinner.reviewed = true |
    .phases.skinner.output_file = "review.md" |
    .transitions += [{
      "from": "skinner",
      "to": "frink",
      "timestamp": $timestamp
    }]' \
   "$STATE_FILE" > "$TMP_STATE"</codeblock>
</stepxmp>
<info>
<p>While the orchestrator already handles the skinner → frink transition (per SKILL.md), explicitly recording it in state.json maintains consistency with other character scripts and provides complete audit trail.</p>
</info>
</step>

<step>
<cmd>Test SIMPLE workflow path</cmd>
<stepxmp>
<p>Create a test task with SIMPLE complexity and verify state.json transitions:</p>
<codeblock>Expected transitions array:
[
  {"from": "lisa", "to": "quimby", ...},
  {"from": "quimby", "to": "frink", ...},
  {"from": "frink", "to": "martin", ...},  ← MUST show martin, not ralph
  {"from": "martin", "to": "ralph", ...},
  {"from": "ralph", "to": "comic-book-guy", ...}
]</codeblock>
</stepxmp>
<info>
<p><b>Verification Criteria:</b></p>
<ul>
<li>No <codeph>frink → ralph</codeph> transition</li>
<li>Martin phase status shows "complete"</li>
<li>Documentation file created in <filepath>docs/planning/{type}/{id}/doc.md</filepath></li>
<li>Ralph phase executes after Martin</li>
</ul>
</info>
</step>

<step>
<cmd>Test COMPLEX workflow path</cmd>
<stepxmp>
<p>Create a test task with COMPLEX complexity and verify state.json transitions:</p>
<codeblock>Expected transitions array:
[
  {"from": "lisa", "to": "quimby", ...},
  {"from": "quimby", "to": "frink", ...},
  {"from": "frink", "to": "skinner", ...},     ← First Frink run
  {"from": "skinner", "to": "frink", ...},      ← Optional if Skinner fix applied
  {"from": "frink", "to": "martin", ...},       ← Second Frink run MUST route to martin
  {"from": "martin", "to": "ralph", ...},
  {"from": "ralph", "to": "comic-book-guy", ...}
]</codeblock>
</stepxmp>
<info>
<p><b>Verification Criteria:</b></p>
<ul>
<li>Skinner phase executes (status: "complete")</li>
<li>Frink executes twice (creates plan-v1.md, then prompt.md)</li>
<li>Second Frink execution transitions to Martin (not Ralph)</li>
<li>Martin creates <filepath>prd.md</filepath> (not <filepath>doc.md</filepath>)</li>
<li>No duplicate or incorrect transitions</li>
</ul>
</info>
</step>
</steps>

<result>
<p><b>I've earned an A+ on documenting the expected outcomes!</b></p>

<p>Upon successful completion of this task, the Springfield workflow will:</p>

<ul>
<li>✅ Correctly route from Frink → Martin in all scenarios (SIMPLE and COMPLEX)</li>
<li>✅ Record accurate state transitions in <filepath>state.json</filepath></li>
<li>✅ Eliminate duplicate transition entries</li>
<li>✅ Ensure Martin's documentation phase always executes before Ralph's implementation</li>
<li>✅ Maintain proper workflow sequence as documented in README and SKILL.md</li>
</ul>

<p><b>State.json Structure (Corrected):</b></p>
<codeblock>{
  "session_id": "...",
  "current_phase": "...",
  "phases": {
    "frink": {"status": "complete", ...},
    "martin": {"status": "complete", "work_item_type": "tasks", ...},
    "ralph": {"status": "in_progress", ...}
  },
  "transitions": [
    {"from": "frink", "to": "martin", "timestamp": "..."},
    {"from": "martin", "to": "ralph", "timestamp": "..."}
  ]
}</codeblock>

<p>No more <codeph>frink → ralph</codeph> transitions bypassing Martin's phase!</p>
</result>

<postreq>
<p><b>According to best practices, these follow-up activities are recommended:</b></p>

<ul>
<li><b>Regression Testing:</b> Run both SIMPLE and COMPLEX workflows end-to-end to verify orchestration</li>
<li><b>Documentation Update:</b> Update README workflow diagram (lines 200-245) to explicitly show Martin's phase transitions</li>
<li><b>Logging Enhancement:</b> Consider adding debug output to character scripts: <codeph>echo "📊 Transition: frink → $NEXT_PHASE" >&2</codeph></li>
<li><b>State Schema Validation:</b> Verify orchestrator correctly reads <filepath>state.json</filepath> transitions to route phases</li>
</ul>
</postreq>

<example>
<title>Example: Correct State Transition Flow</title>
<p><b>This demonstrates the impeccable sequence we're implementing!</b></p>

<p><b>SIMPLE Task ("Add logging utility function"):</b></p>
<codeblock>Phase Execution:
1. Lisa researches → Creates research.md
2. Quimby decides "SIMPLE" → Creates decision.txt
3. Frink creates prompt.md → Sets NEXT_PHASE="martin" ✅
4. Martin creates doc.md → Sets transition martin→ralph ✅
5. Ralph implements → Code changes applied
6. Comic Book Guy validates → Review complete

State.json Transitions:
[
  {"from": "lisa", "to": "quimby"},
  {"from": "quimby", "to": "frink"},
  {"from": "frink", "to": "martin"},      ← Fixed!
  {"from": "martin", "to": "ralph"},
  {"from": "ralph", "to": "comic-book-guy"}
]</codeblock>

<p><b>COMPLEX Task ("Implement authentication system"):</b></p>
<codeblock>Phase Execution:
1. Lisa researches → Creates research.md
2. Quimby decides "COMPLEX" → Creates decision.txt
3. Frink creates plan-v1.md → Sets NEXT_PHASE="skinner" ✅
4. Skinner reviews → Creates review.md
5. Frink creates prompt.md → Sets NEXT_PHASE="martin" ✅ (Fixed!)
6. Martin creates prd.md → Sets transition martin→ralph ✅
7. Ralph implements → Code changes applied
8. Comic Book Guy validates → Review complete

State.json Transitions:
[
  {"from": "lisa", "to": "quimby"},
  {"from": "quimby", "to": "frink"},
  {"from": "frink", "to": "skinner"},
  {"from": "skinner", "to": "frink"},     ← Optional enhancement
  {"from": "frink", "to": "martin"},      ← Fixed!
  {"from": "martin", "to": "ralph"},
  {"from": "ralph", "to": "comic-book-guy"}
]</codeblock>
</example>

<troubleshooting>
<p><b>My thorough analysis identified these potential issues:</b></p>

<table>
<tgroup cols="3">
<thead>
<row>
<entry>Issue</entry>
<entry>Symptom</entry>
<entry>Resolution</entry>
</row>
</thead>
<tbody>
<row>
<entry>Martin phase skipped</entry>
<entry>state.json shows <codeph>frink → ralph</codeph> transition</entry>
<entry>Verify frink.sh lines 143 and 188 both set <codeph>NEXT_PHASE="martin"</codeph></entry>
</row>
<row>
<entry>Duplicate transitions</entry>
<entry>Transitions array has both <codeph>frink → ralph</codeph> AND <codeph>martin → ralph</codeph></entry>
<entry>Fix indicates incomplete deployment - ensure frink.sh changes are applied</entry>
</row>
<row>
<entry>Orchestrator skips Martin</entry>
<entry>Martin phase status remains "pending", Ralph executes prematurely</entry>
<entry>Verify orchestrator reads state.json transitions correctly (check SKILL.md implementation)</entry>
</row>
<row>
<entry>Missing prompt.md</entry>
<entry>Martin script exits with error "prompt.md not found"</entry>
<entry>Indicates Frink didn't complete - check Frink phase status in state.json</entry>
</row>
</tbody>
</tgroup>
</table>
</troubleshooting>

</taskbody>

<related-links>
<link href="../../../README.md" format="md" scope="local">
<linktext>Springfield Workflow Documentation</linktext>
</link>
<link href="../../../skills/springfield/SKILL.md" format="md" scope="local">
<linktext>Springfield Skill Orchestrator</linktext>
</link>
<link href="../../../scripts/frink.sh" format="sh" scope="local">
<linktext>Professor Frink Script (Primary Fix Location)</linktext>
</link>
<link href="../../../scripts/martin.sh" format="sh" scope="local">
<linktext>Martin Prince Script (Reference Implementation)</linktext>
</link>
<link href="../../../scripts/skinner.sh" format="sh" scope="local">
<linktext>Principal Skinner Script (Optional Enhancement)</linktext>
</link>
</related-links>

</task>

---

**This is comprehensive and impeccable! I've created an A+ task documentation with:**

- ✅ Proper DITA task.xsd frontmatter with complete metadata
- ✅ Thorough context explaining the workflow issue and its impact
- ✅ Clear prerequisites listing all required files and dependencies
- ✅ Step-by-step instructions with exact file locations and code changes
- ✅ Comprehensive testing procedures for both SIMPLE and COMPLEX paths
- ✅ Expected results with concrete state.json examples
- ✅ Post-requisites for regression testing and enhancements
- ✅ Real-world examples demonstrating correct transition flow
- ✅ Troubleshooting table for common issues
- ✅ Related links to all referenced files
- ✅ Academic precision and thoroughness befitting Springfield Elementary's top student!

**Martin Prince, Documentation Specialist**
*Springfield Workflow Documentation Division*
