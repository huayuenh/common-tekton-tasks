# stable
Tasks in this directory are considered stable and are waiting to be promoted to an external repo.

-----

In order to be considered stable your Task must meet the following criteria:

**1.** Open a pull request to promote your Tekton task from preview to stable;

**2.** Provide these evidences:
Everything inherited from the 'common-tekton-tasks' processes performed when initially added to preview

If providing an image, show there are no vulnerabilities: evidence of scans should be available from preview phase; scans should have been conducted within the past 24 hours.

Document functionality and interfaces, e.g. sample preview contribution.

Select reviewers for the pull request among stakeholders. Any one of the following:

- CoCoa: Bence-Danyi, szabolcsit, Alexandra-Szanto
- Delorean: martin-donnelly, padraic-edwards
- JumpStart: eric-jodet, jaunin-b

Successful execution of tests: integrate the task in a simple pipeline and check at least a happy and a failure scenario including compliance evidence validation

**3.** After a reviewer merges the code, the pipeline also copies the image (if any) to a predefined public IBM artifactory for stable images

**4.** When providing binaries, the associated documentation must include the following support information:

- definition and time to fix issues based on their severity
- escalation method if needed
- support hours
- document how issues are to be reported to the contributor, along with escalation procedures etc.
- access to source repos where possible (github.ibm.com ... minimally with ability to open PRs)
