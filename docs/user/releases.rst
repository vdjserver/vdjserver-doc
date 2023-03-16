.. _ReleaseAnnouncements:

===============================
Release Announcements
===============================

.. _VDJServerReleaseAnnouncements:

**********************************************
VDJServer Web Analysis Portal
**********************************************

We are pleased to announce a new release of VDJServer analysis portal, VDJServer
Community Data Portal, and associated immune repertoire analysis tools.

We are in the transition from V1 to V2.

VDJServer Community Data Portal V2 (Beta)
=========================================

This release was made available for public use on May 19th, 2022.

VDJServer Release 1.1.3
=======================

This release was made available for public use on November 10th, 2020.

+ **Bug Fixes**

  + Agave date format change for jobs.

+ **Other Notes**

  + Acknowledgement of European Union’s Horizon 2020 Research and Innovation Program (#825821) and VDJServer
    as a partner in the iReceptor+ Consortium.

VDJServer Release 1.1.2
=======================

This release was made available for public use on September 13th, 2019.

+ **Application Upgrades**

  + IgBlast has been upgraded to version 1.14.0.

+ **Bug Fixes**

  + Fix date display for jobs.

VDJServer Release 1.1.1
=======================

This release was made available for public use on June 28th, 2019.

+ **New Functionality**

  + Preliminary Macaque IGH germline set for IgBlast related to publication in `PLoS Pathogens <https://pubmed.ncbi.nlm.nih.gov/32866207/>`_.

+ **Application Upgrades**

  + Updated to support Lonestar5 upgrade.
  + CDR3 Distribution calculations added to RepCalc.
  + Lineage reconstruction added to RepCalc.

+ **Bug Fixes**

  + Numerous small fixes.

VDJServer Release 1.1.0
=======================

This release was made available for public use on May 4th, 2018.

+ **New Functionality**

  + Email notifications. VDJServer will now send you email when jobs finish, when users are added/removed from projects, and when projects are published and unpublished. You can change email notifications in your profile.
  + MiAIRR V1 metadata entry. Among the project views is a new metadata entry screen that allows entry of study, subject, diagnosis, sample, cell processing and nucleic acid processing metadata. Metadata can be manually entered on the screen, imported from a file, and exported to file. All required data elements comply with the MiAIRR V1 standard.
  + Sample groups. Also on the new metadata entry screen is the ability to define sample groups for repertoire characterization and comparison performed by RepCalc.
  + IgBlast application now produces an `AIRR TSV rearrangement annotation file <http://docs.airr-community.org/en/latest/datarep/rearrangements.html>`_ along with VDJML, ChangeO TSV and RepSum TSV.
  + Job Actions Menu. Each job on the View Analyses and Results screen has a menu of actions including Rename Job, Archive Job, Show Job History and others.
  + Initial prototype of VDJServer's community data. There is now a `COMMUNITY DATA <https://vdjserver.org/community>`_ link which can be accessed from the VDJServer login page or from the project screen. You do not need to login or have an account with VDJServer to view the public community data. Download raw and processed data, and visualize analyses and results for all public projects.
  + Community data projects. Users can publish and make public their own projects.

+ **New Documentation**

  + We've documented a `basic analysis workflow <https://vdjserver.org/docs/QuickStart/VDJServer_Release1.1_Basic_Analysis_Workflow.pdf>`_ for VDJServer.

+ **Application Upgrades**

  + IgBlast has been upgraded to version 1.8.0.
  + The Stampede supercomputer has been decommissioned at TACC. All applications have been ported to the new Stampede2 supercomputer. By default, Lonestar5 is the primary machine for running applications but VDJServer uses Stampede2 when Lonestar5 is undergoing maintenance.
  + VDJServer now uses Corral as its backend data storage at TACC. This provides peta-scale storage for the future.
  + IgBlast and RepCalc applications have been enhanced for more parallelism to support larger data sets.

+ **Bug Fixes**

  + Numerous small fixes.
  + Make project deletion a soft delete in case it needs to be recovered.

VDJServer Release 1.0.3
=======================

This release was made available for public use on April 25, 2017.

+ **New Functionality**

  + New RepCalc version 1.0.1. This version includes new analysis functionality for comparison of shared/unique CDR3 sequences between files, samples and sample groups. The calculations can be performed for just the CDR3 sequence (nucleotide or amino acid) or in combination with the V gene or VJ gene. Additional combinations will be added in the future. RepCalc also now performs gene segment combination calculations, include VJ and VDJ combinations, and can compare usage between files, samples and sample groups.
  + All server applications have been upgraded to support running jobs with a very large number of files. Previously, an internal limit for the Agave API prevented running jobs with more than approximately 30 files. We have implemented a secondary mechanism that bypasses this limit, and we've successfully tested running jobs with over 500 files.
  + The job submission screen for VDJPipe has been simplified.
  + CDR3 Length Histogram chart has been added for nucleotide sequence, as just the amino acid sequence chart was available before. This analysis is available from the RepCalc application.

+ **New Documentation**

  + We've added a main `documentation page <https://vdjserver.org/docs/index.html>`_ for VDJServer.
  + `QuickStart <https://vdjserver.org/docs/QuickStart/Quickstart_Vdjserver_Release1.0.pdf>`_ guide is now available! This guide provides a short, basic description for performing a complete analysis workflow on VDJServer.

+ **Bug Fixes**

  + New VDJPipe version 0.1.7. This version fixes some bugs related to collapsing duplicate sequences and carrying forward the duplication count for downstream analysis.
  + Internet Explorer errors when displaying VDJPipe or pRESTO charts have been fixed.
  + We've increased the security of our server side API.
  + Some passwords with special symbols were not being accepted, this has corrected.

+ **Other Notes**

  + We've moved to a different versioning scheme for Agave applications. Previously the version number matched the exact version of the tool, e.g. 1.4.0 for IgBlast 1.4.0. This has been changed so the Agave application just has the major and minor version numbers, e.g. 1.4 for IgBlast 1.4.0 or 1.0 for RepCalc 1.0.1. The "third" number in the standard versioning scheme is the release number for minor improvements that don't break compatibility, and there is no need to increment the Agave version for these release.

VDJServer Release 1.0.1
=======================

This release was made available for public use on January 26, 2017.

+ **Bug Fixes**

  + JavaScript errors on some web pages for Microsoft Explorer on Windows have been fixed.
  + Recent update to the LoneStar5 supercomputer required an update to the RepCalc application.

VDJServer Release 1.0.0
=======================

This release was made available for public use on January 18, 2017. After much development, this marks the first official release of VDJServer! With this release, users can:

+ Create projects.
+ Upload files to projects.
+ Share projects with other users.
+ Define study, subject, sample and sample group metadata.
+ Conduct de-multiplexing, quality filtering, and other pre-processing operations using either VDJPipe or pRESTO.
+ Visualize pre- and post-processing statistics with a series of interactive charts including nucleotide composition, GC% histogram, sequence length histogram, mean quality histogram, and quality scores,
+ Run IgBlast for V(D)J assignment.
+ Obtain basic V(D)J assignment data and summary in VDJML, RepSum's TSV, and Change-O TSV formats.
+ Perform repertoire and comparative analysis such as clonality, gene segment usage, CDR3 patterns, diversity measures, somatic mutation patterns, B cell lineage trees, and quantification of selection pressure. Analyses are performed by RepCalc, Change-O, Alakazam and Shazam tools.
+ Download analysis results in TAB-separated format.
+ Visualize repertoire analysis with a set of interactive charts that allows samples and sample groups to be dynamically included, providing ad-hoc comparison of samples and sample groups.

VDJServer Release 0.11.0
========================

This release was made available for public use on August 25, 2016.

+ **New Functionality**

  + The pRESTO tool is now available. Much of the pRESTO functionality is available in a workflow supporting single-end and paired-end reads, length and quality filtering, barcoding, unique molecular identifiers (UMI), forward and reverse primers, and collapsing of unique sequences. VDJPipe is also automatically run during the worfklow to provide pre- and post-filtering statistics with corresponding chart visualizations.
  + Execution levels are automatically determined for jobs. Previously jobs that ran on the Lonestar5 or Stampede supercomputer had their execution time set to 48 hours, which could cause the jobs to sit in the queue for awhile before being run. Now this time is optimized based upon the size of the input. Small and medium size jobs have more appropriate execution times defined, which allow most jobs to be run immediately. Users should notice jobs starting and finishing much quicker than before.
  + VDJML Version 1.0.0 has been released and is integrated with VDJServer.

+ **Bug Fixes**

  + Use paginated requests for retrieving data from Agave. For some projects with a large number of files (>100), sometimes not all files would appear. This has been resolved so now any number of files are supported.
  + Resolved some bugs with the vdj-api server process.
  + Fixed a duplicate file checking issue.

+ **Other Notes**

  + We have written an extensive integration test suite that exercises all major functional and integration points in VDJServer. This will help increase the reliability of VDJServer.
  + We have performed some reorganization of the Docker images for VDJServer. This facilitates running more development tests. We also upgraded to newer versions.

VDJServer Release 0.10.0
=========================

This release was made available for public use on June 9, 2016.

+ **New Functionallity**

  + VDJPipe now supports paired-end read processing.
  + There is now a new project page for associating paired-end read files with each other.
  + IgBLAST application compresses output VDJML and TSV files.

+ **Bug Fixes**

  + Resolved a number of outstanding issues with file uploading. 
  + Cleaned up some internal error messages with IgBLAST application.
  + Better manage expired tokens in the web-app.
  + Fixed bugs for detection of CYS and PHE/TRP by rep_char (`issue #24 <https://bitbucket.org/vdjserver/repertoire-summarization/issues/24>`_).

== VDJServer Release 0.9.0 ==

This release was made available for public use on March 23, 2016.

.. _RepositoryReleaseAnnouncements:

**********************************************
VDJServer Repository for the AIRR Data Commons
**********************************************

We are pleased to announce a new release of the VDJServer Repository,
an AIRR-compliant data repository in the AIRR Data Commons.

December 2022
=============

This release updates all of the Repertoire metadata to the AIRR v1.4 standard.

December 2021
=============

This release adds fourteen studies including eleven 10X Genomics single
cell studies and five COVID-related studies. It also contains a large
study from the Human Vaccines Project with roughly one billion TCR rearrangements.

Statistics:

+ 39 studies
+ 3408 repertoires
+ ~2.5 billion rearrangements

February 2021
=============

This release contains the seven COVID-related studies from Adaptive's ImmuneCODE
which have been re-processed through VDJServer's pipeline.

Statistics:

+ 25 studies
+ 2949 repertoires
+ ~1.4 billion rearrangements

.. toctree::
   :maxdepth: 1
