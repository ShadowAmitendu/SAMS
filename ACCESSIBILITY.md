# Accessibility

Accessibility is an important part of SAMS (Smart Attendance Management System). We want students, faculty members, administrators, and contributors to be able to use and contribute to the project without unnecessary barriers.

This document explains our accessibility priorities, expectations for contributors, supported environments, known limitations, and how to report accessibility issues.

We aim to make SAMS usable by people with different abilities, devices, and interaction preferences.

## Priorities

Our goal is to provide an accessible and consistent experience across the application.

We prioritize the following areas:

- **Keyboard Navigation:** All essential features should be usable without requiring a mouse.
- **Screen Reader Support:** Interface elements should have meaningful labels and descriptions.
- **Visual Accessibility:** Maintain readable typography, sufficient color contrast, and visible focus indicators.
- **Forms and Validation:** Provide clear instructions, understandable error messages, and properly labelled input fields.
- **Responsive Design:** Ensure the application remains usable across desktop computers, tablets, and mobile devices.
- **QR Code Accessibility:** Provide an alternative attendance verification method for users who cannot scan QR codes.
- **Content Clarity:** Use simple language, consistent terminology, and understandable navigation.

We aim to work toward WCAG 2.2 Level AA accessibility. This is an aspirational development goal, not a verified compliance claim.

## Contributor expectations

All contributors are encouraged to consider accessibility when developing or modifying user-facing functionality.

Please follow these guidelines:

- Use semantic HTML elements wherever appropriate.
- Provide accessible names and labels for interactive elements.
- Ensure keyboard navigation and visible focus states.
- Maintain sufficient contrast between text and background colors.
- Avoid communicating important information through color alone.
- Provide alternative text for meaningful images.
- Ensure forms include appropriate labels and understandable validation messages.
- Avoid introducing unnecessary accessibility barriers.
- Update relevant documentation when accessibility-related functionality changes.

For user-facing changes, contributors should:

- Test keyboard navigation where applicable.
- Check the behavior of modified forms and interactive components.
- Include screenshots or descriptions of relevant interface changes in pull requests.
- Mention any known accessibility limitations.

## Reporting accessibility issues

If you encounter an accessibility barrier while using SAMS, please report it through the repository's GitHub Issues section.

When submitting a report, include as much of the following information as possible:

- The affected page, feature, or task.
- A description of the accessibility barrier.
- What you expected to happen and what actually happened.
- Your browser and operating system.
- The assistive technology being used, if applicable.
- Steps to reproduce the issue.

Screenshots and screen recordings are welcome but optional.

You do not need to disclose a disability or provide personal medical information to report an accessibility issue.

For security vulnerabilities, please follow the separate reporting process described in [SECURITY.md](SECURITY.md).

### Severity

Accessibility issues may be prioritized according to their impact on users.

| Severity | Description |
| -------- | ----------- |
| Critical | A major accessibility barrier prevents users from completing an essential task. |
| High | An important feature is difficult or inaccessible for certain users. |
| Medium | A usability barrier affects part of the application but has a possible workaround. |
| Low | A minor accessibility or usability improvement is needed. |

Maintainers may review and adjust the severity of reported issues during triage.

### How we respond

Project maintainers will review accessibility reports and assess their impact.

We aim to:

- Acknowledge reported issues within a reasonable timeframe.
- Investigate the reported behavior.
- Provide updates when meaningful progress is made.
- Identify possible workarounds where available.
- Address accessibility barriers according to their severity and development priorities.
- Encourage reporters to verify fixes when possible.

Resolution timelines may vary depending on the complexity of the issue and available development resources.

## Ownership and maintenance

Accessibility is a shared responsibility among project maintainers and contributors.

The project maintainer is responsible for:

- Reviewing accessibility-related issues.
- Considering accessibility during feature development.
- Reviewing accessibility considerations in pull requests.
- Maintaining this document as the project evolves.
- Encouraging continuous accessibility improvements.

This document will be reviewed periodically and updated as the project develops.

## Supported environments

SAMS is being developed with the intention of supporting commonly used computing environments.

The intended environments include:

- Desktop computers and laptops.
- Tablets and mobile devices.
- Modern web browsers.
- Keyboard and mouse navigation.
- Touch-based interaction.
- Compatible assistive technologies, including screen readers.

Specific browser versions, assistive technology combinations, and accessibility support levels will be documented as they are tested.

No untested environment or assistive technology combination is currently guaranteed to be fully supported.

## Known limitations

SAMS is currently under development, and its accessibility has not yet undergone a comprehensive evaluation.

Potential areas requiring further testing include:

- Screen reader compatibility.
- Keyboard accessibility across all application modules.
- Color contrast and visual presentation.
- QR code scanning alternatives.
- Accessibility of dynamically updated attendance information.
- Mobile accessibility and responsive interactions.

Known accessibility barriers will be documented and tracked through GitHub Issues as they are identified.

## Feedback and improvements

We welcome accessibility suggestions, feedback, and contributions from students, faculty members, developers, and other users.

If you have suggestions for improving this document or the application's accessibility practices, please open a GitHub Issue or submit a Pull Request.

We believe accessibility is an ongoing process, and we are committed to improving SAMS as development progresses.

---

**SAMS – Smart Attendance Management System**

*Making academic attendance management accessible, inclusive, and reliable.*
