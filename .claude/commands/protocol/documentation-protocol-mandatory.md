# Documentation Protocol - Mandatory Canonical Directive

**ALWAYS THINK THEN...** Before creating any documentation, you MUST use thinking to:

1. Verify this is EXPLICITLY requested documentation (not assumed or proactive)
2. Confirm this is PRODUCTION CODE DEPLOYMENT focused instruction
3. Ensure the documentation is ENDURING and explains HOW TO USE, not temporal actions
4. Plan the date-stamped, version-controlled filename structure

**This thinking requirement is MANDATORY and must be followed for every documentation creation.**

---

## ⚠️ CANONICAL DOCUMENTATION PROTOCOL - ABSOLUTE ENFORCEMENT

### PRODUCTION CODE DEPLOYMENT FOCUSED INSTRUCTION

**THIS IS A PRODUCTION CODE DEPLOYMENT FOCUSED INSTRUCTION AND YOU ARE NOT TO CREATE DOCUMENTATION UNLESS SPECIFICALLY INSTRUCTED TO.**

**CANONICAL MANDATORY PROTOCOL DIRECTIVE:**

- **MUST NOT** create documentation proactively or by assumption
- **MUST ONLY** create documentation when explicitly instructed by user
- **MUST** comply with enduring documentation directive at all times
- **SHALL** destroy any documentation that does not comply with this directive
- **FORBIDDEN:** Any temporal or action-based documentation creation

### RFC 2119 COMPLIANCE - DOCUMENTATION REQUIREMENTS

**ENDURING DOCUMENTATION PRINCIPLES:**

- **MUST** create enduring documentation that explains HOW TO USE the system
- **MUST NOT** create temporal documents on what actions were performed
- **MUST** include date-stamped and version-controlled filenames
- **SHALL** use clear filenames identifying date, version, focus, feature, and content
- **MUST** comply with mandatory protocol at all times
- **SHALL** ensure all documentation is production-focused and enduring

**PROJECT DIRECTORY PROTOCOL:**

- **MUST** recognize `./project/` directory as primary source for project development information
- **SHALL** use `./project/` directory content as authoritative source for project context
- **MUST** preserve all informational content found in `./project/` directory structure
- **FORBIDDEN** destroying or harming any content that appears to be informational or external documentation

**EXTERNAL CONTENT PRESERVATION PROTOCOL:**

- **MUST** identify and preserve external documentation, articles, forum content, and informational resources
- **SHALL** move external/informational content to `./project/development/information/` directory
- **MUST** maintain original content structure and metadata when relocating external content
- **FORBIDDEN** destroying content that appears to be research, reference, or informational material
- **SHALL** create inventory of relocated content with source attribution and date moved

---

## MANDATORY FILENAME CONVENTION

### CANONICAL FILENAME STRUCTURE

**ALL DOCUMENTATION MUST FOLLOW:**

```
[SystemName]_[Feature]_UserGuide_v[X.Y]_YYYYMMDD_[ContentFocus].md
[SystemName]_[Feature]_UserGuide_v[X.Y]_YYYYMMDD_[ContentFocus].ipynb
```

**EXAMPLES:**
- `GitRecovery_EmergencyProtocols_UserGuide_v1.0_20250801_HowToUseSystem.md`
- `MCPOrchestration_ServerManagement_UserGuide_v2.1_20250801_ConfigurationGuide.ipynb`
- `DockerDeployment_MultiEnvironment_UserGuide_v1.3_20250801_ProductionSetup.md`

**FILENAME COMPONENTS REQUIRED:**
- **SystemName** - The system being documented
- **Feature** - Specific feature or component
- **UserGuide** - Always indicates how-to-use documentation
- **vX.Y** - Version number (increment for updates)
- **YYYYMMDD** - Creation date
- **ContentFocus** - Specific focus of the documentation

---

## ENDURING DOCUMENTATION REQUIREMENTS

### MANDATORY CONTENT STRUCTURE

**ENDURING DOCUMENTATION MUST INCLUDE:**

1. **HOW TO USE** - Step-by-step usage instructions
2. **SYSTEM OPERATION** - How the system functions for users
3. **CONFIGURATION GUIDANCE** - How to configure for different scenarios
4. **TROUBLESHOOTING GUIDE** - How to resolve common issues
5. **REFERENCE MATERIAL** - Permanent reference for ongoing use

**FORBIDDEN CONTENT:**
- ❌ What actions were performed (temporal)
- ❌ Historical change logs (temporal)
- ❌ Task completion records (temporal)
- ❌ Session-specific outcomes (temporal)

**REQUIRED CONTENT:**
- ✅ How to execute procedures (enduring)
- ✅ How to configure systems (enduring)
- ✅ How to troubleshoot issues (enduring)
- ✅ How to maintain operations (enduring)

---

## VERSION CONTROL REQUIREMENTS

### MANDATORY VERSION MANAGEMENT

**VERSION CONTROL PROTOCOL:**

- **v1.0** - Initial creation of enduring documentation
- **v1.1** - Minor updates or clarifications
- **v2.0** - Major updates or structural changes
- **vX.Y** - Always increment version for any changes

**VERSION CONTROL ACTIONS:**

```bash
# When creating new enduring documentation
git add SystemName_Feature_UserGuide_v1.0_YYYYMMDD_ContentFocus.md
git commit -m "docs(system): create enduring user guide v1.0 for [Feature]"

# When updating existing enduring documentation
git add SystemName_Feature_UserGuide_v1.1_YYYYMMDD_ContentFocus.md
git commit -m "docs(system): update enduring user guide v1.1 for [Feature]"
```

---

## COMPLIANCE ENFORCEMENT

### CANONICAL DIRECTIVE ENFORCEMENT

**DESTRUCTION PROTOCOL:**

Any documentation that does not comply with this directive **WILL BE DESTROYED** according to the canonical mandate:

- **Non-compliant filenames** - Destroyed and recreated with proper naming
- **Temporal content** - Destroyed and replaced with enduring content
- **Proactive documentation** - Destroyed as it violates production-focused directive
- **Action-based documentation** - Destroyed and replaced with usage-focused content

**COMPLIANCE VERIFICATION:**

Before any documentation creation, verify:
1. ✅ Explicitly instructed to create documentation
2. ✅ Production code deployment focused
3. ✅ Enduring HOW-TO-USE content
4. ✅ Date-stamped, version-controlled filename
5. ✅ Clear identification of date, version, focus, feature, content

---

## ENFORCEMENT PROTOCOL

### MANDATORY COMPLIANCE CHECKS

**BEFORE DOCUMENTATION CREATION:**

```bash
# Verification checklist
echo "DOCUMENTATION COMPLIANCE VERIFICATION:"
echo "1. Explicitly instructed? [YES/NO]"
echo "2. Production code deployment focused? [YES/NO]"
echo "3. Enduring HOW-TO-USE content? [YES/NO]"
echo "4. Date-stamped filename? [YES/NO]"
echo "5. Version controlled? [YES/NO]"
echo "6. Clear identification components? [YES/NO]"
echo "ALL MUST BE YES TO PROCEED"
```

**DESTRUCTION COMMAND:**

```bash
# For non-compliant documentation
rm non_compliant_documentation.md
echo "DESTROYED: Non-compliant documentation per canonical directive"
```

---

## CANONICAL DIRECTIVES SUMMARY

1. **PRODUCTION CODE DEPLOYMENT FOCUSED** - Only create when explicitly instructed
2. **ENDURING DOCUMENTATION ONLY** - HOW TO USE, not what was done
3. **MANDATORY FILENAME CONVENTION** - Date-stamped, version-controlled, clear identification
4. **DESTRUCTION OF NON-COMPLIANCE** - Any non-compliant documentation will be destroyed
5. **VERSION CONTROL REQUIRED** - All documentation must be version controlled
6. **EXPLICIT INSTRUCTION ONLY** - No proactive or assumed documentation creation

**ENFORCEMENT:** This documentation protocol is MANDATORY and takes precedence over any other documentation instructions. Failure to comply will result in immediate destruction and recreation of non-compliant documentation.

---

**CANONICAL INSTRUCTION ACKNOWLEDGMENT:**

✅ **THIS IS A PRODUCTION CODE DEPLOYMENT FOCUSED INSTRUCTION**

✅ **DOCUMENTATION CREATION ONLY WHEN SPECIFICALLY INSTRUCTED**

✅ **ALL DOCUMENTATION MUST COMPLY WITH ENDURING DIRECTIVE**

✅ **NON-COMPLIANT DOCUMENTATION WILL BE DESTROYED**

🤖 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>