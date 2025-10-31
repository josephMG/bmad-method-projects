# Rollback Procedures for BMad-FamilyExpenseTracker

This document outlines the procedures for rolling back changes in the `BMad-FamilyExpenseTracker` application in case of critical issues or failed deployments.

## 1. Principles of Rollback

*   **Minimize Downtime:** Rollback procedures should aim to restore a stable state as quickly as possible.
*   **Data Integrity:** Ensure that data integrity is maintained throughout the rollback process.
*   **Communication:** Clearly communicate rollback status and impact to stakeholders.

## 2. Application Rollback (Flutter Frontend)

In case of a critical issue with a new application deployment (e.g., a new version pushed to app stores):

1.  **Identify Stable Version:** Determine the last known stable version of the application. This should correspond to a tagged release in the Git repository.
2.  **Revert Codebase:**
    *   If the issue is identified before release, revert the problematic changes in the Git repository to the last stable commit.
    *   If the issue is identified after release, prepare a new release from the last stable commit.
3.  **Rebuild and Redeploy:**
    *   Rebuild the application from the stable codebase.
    *   Redeploy the stable version to the respective app stores (Google Play Store, Apple App Store). This process can take time due to app store review processes.
4.  **Communicate:** Inform users about the issue and the rollback, and when a fix is expected.

## 3. Data Rollback (Google Sheets Backend)

Rollback of data in Google Sheets is more complex due to its real-time nature and collaborative editing.

1.  **Identify Affected Sheets/Tabs:** Determine which `YYYY-MM` tabs or the `Category` tab have been affected by the problematic changes.
2.  **Google Sheets Version History:**
    *   Google Sheets maintains a version history. Access the version history for the affected spreadsheet.
    *   Identify a stable version of the sheet from before the problematic changes occurred.
    *   Restore the affected tabs from this stable version.
3.  **Backup Data:** Before any restoration, always create a backup copy of the current (problematic) state of the Google Sheet.
4.  **Communicate:** Inform users that a data rollback has occurred and any data entered during the problematic period might be lost. Advise them to refresh their application.

## 4. API/Service Rollback (Google Sheets API)

If a change to how the application interacts with the Google Sheets API causes issues:

1.  **Application Rollback:** First, perform an application rollback to a version that uses the previous, stable API interaction logic.
2.  **Monitor:** Monitor the application and Google Sheets for any lingering issues.

## 5. General Best Practices

*   **Frequent Backups:** Regularly back up critical data and configurations.
*   **Version Control:** All code changes must be under version control (Git) with clear commit messages and release tags.
*   **Staging Environments:** Test new features and deployments in staging environments before pushing to production.
*   **Monitoring and Alerting:** Implement monitoring for application performance and errors, with alerts for critical issues.
*   **Incident Response Plan:** Have a clear incident response plan in place for handling critical issues.
