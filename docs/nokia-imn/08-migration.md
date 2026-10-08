Source: installation_manual_linux.pdf, chapter 8, page 64.

# 8. Migrating From Other Systems

If you are migrating from another system the following features can help you setup TNMS.

## 8.1. Automatic Adoption of Paths

TNMS can automatically adopt new paths, changes in paths and path deletions. This option is meant to help new TNMS customers in the two following scenarios:

- **Migration** from another Network Management System (NMS). Checking this option allows an automatic bulk adoption of all the paths in the network.
- **Parallel operation** with other systems.

Before fully migrating, you can choose to have TNMS work in parallel with the previous system. To do so, by checking this option, TNMS is able to adopt any change made by the other system, either it is the creation, change or deletion of a path.

To activate this feature go to **Main** > **Administration** > **System Preferences** and, in the **Optical Manager** > **Discovery** section, check **Auto-adopt NW changes done by external NMS**.

A delay must also be defined to avoid the adoption of unnecessary intermediate and inconsistent states, which would increase overall system load without any benefit. The delay is also required to maintain managed paths consistent in TNMS.
