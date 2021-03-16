# Packaging instructions

These instructions detail the steps necessary to create a new package version and release it.

## Prerequisites

A commit with modified sfdx-project.json file.

The following fields should be updated:

| Field         | From                      | To                             |
| ------------- | ------------------------- | ------------------------------ |
| versionName   | 1.3.0                     | 1.4.0                          |
| versionNumber | 1.3.0.0                   | 1.4.0.0                        |
| ancestorId    | id of parent, i.e. v1.2.0 | id of new parent, i.e. v1.3.0. |

If there has been a change in the SalesForce api version in any of the classes, due to changes requiring a higher api version, make sure to update the **_sourceApiVersion_** field with the new version.

If a new dependency has been added, update the **_dependencies_** property accordingly.

**The commit should be reviewed and approved before continuing with the packaging steps**

## Packaging steps

To create a package _version_, i.e. to create a new installation url the following command is used:

```sh
sfdx force:package:version:create --package "Advanced Pricing Integration" --wait 20 --installationkeybypass --codecoverage
```

| Parameter               | Description                                             |
| ----------------------- | ------------------------------------------------------- |
| --wait                  | number of minutes to wait for the version to be created |
| --installationkeybypass | skip package installation key requirement               |
| --codecoverage          | compute code coverage                                   |

**Without the codecoverage parameter it will not be possible to promote the created version to the released state. Additionally, there is a minimum code coverage requirement of 75%.**

When you are ready to release the version, use force:package:version:promote

```sh
sfdx force:package:version:promote --package "Advanced Pricing Integration@1.4.0-0"
```

## Post packaging steps

After packaging is done, the sfdx cli will update the sfdx-project.json property **_packageAliases_** with a new package alias.

Create a new commit with this information.
