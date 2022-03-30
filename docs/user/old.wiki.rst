This is content from the old wiki that still needs to be integrated.


*****


These are the known outstanding issues for specific releases of the VDJServer website.

== VDJServer Release 1.1.0 ==

* '''ISSUE:''' User is added to project but not able to access files or jobs.
** '''WORKAROUND:''' Even though we changed VDJServer to send email notifications for adding/removing users from a project, this issue is not completely resolved. An Agave permission bug is preventing users from uploading files, however users can download files and run jobs.

== VDJServer Release 1.0.3 ==

* '''ISSUE:''' User is added to project but not able to access files or jobs.
** '''WORKAROUND:''' For large projects with many files and/or jobs, it can take awhile to set the permissions on them for a new user. The current VDJServer design is somewhat misleading as it shows the user was added to the project, even though the process to set all of the permissions has not been completed yet. Give it some time (15-30 mins) to finish. In a future release, we will change VDJServer's design and send an email to let the user know they can access the project.

== VDJServer Release 1.0.0 ==

No known issues.

== VDJServer Release 0.11.0 ==

* '''ISSUE:''' View Analyses and Results screen does not show jobs.
** '''WORKAROUND:''' This seems to be an intermittent issue where sometimes it displays the jobs and sometimes it does not. Do a page refresh in your browser one or more times to get the jobs to display.

== VDJServer Release 0.10.0 ==

* '''ISSUE:''' Uploading large files using IE 11 on Windows 7 may give an arithmetic error.
** '''WORKAROUND:''' Try using a different browser such as Google Chrome.

* '''ISSUE:''' Firefox on Windows 7 does not display Start button for file uploads.
** '''WORKAROUND:''' Try using a different browser such as Google Chrome.

== VDJServer Release 0.9.0 ==

* '''ISSUE:''' Batch uploading of files. When a large number of files are uploaded, it is possible that not all files will be uploaded. This is being tracked as [https://agaveapi.atlassian.net/browse/AD-303 Agave issue 303].
** '''WORKAROUND:''' Check the count of the number of files in your project view. If any files in the batch did not get uploaded, you can re-upload those individual files.

* '''ISSUE:''' File appears to upload properly but it does not show up in the project view. After a file is uploaded, there are a number of additional steps performed by VDJServer before the file is accessible. Sometimes an error occurs during these steps. This can occur for upload of local files, Dropbox uploads and URL uploads. This is being tracked as [https://agaveapi.atlassian.net/browse/AD-304 Agave issue 304].
** '''WORKAROUND:''' Re-upload the file.

* '''ISSUE:''' After uploading a file, the file size is incorrect. This issue is related to [https://agaveapi.atlassian.net/browse/AD-304 Agave issue 304].
** '''WORKAROUND:''' No workaround. If you want to verify however, you can download your file and check that the size of the downloaded file is the expected size.

* '''ISSUE:''' Uploading large files using IE 11 on Windows 7 may give an arithmetic error.
** '''WORKAROUND:''' Try using a different browser such as Google Chrome.


*****


VDJServer incorporates a number of software tools. Here is the list of that software, the version being used and links for additional information.

== VDJServer Release 1.1.0 ==

* vdj_pipe version 0.1.7
** [https://bitbucket.org/vdjserver/vdj_pipe Source Repository]
** [https://hub.docker.com/r/vdjserver/vdj_pipe Docker image]
** Agave apps: vdj_pipe-ls5-0.1.7u7, vdj_pipe-stampede2-0.1.7u2, vdj_pipe-small-0.1.7u3

* pRESTO version 0.5.7
** [https://bitbucket.org/kleinstein/presto/ Source Repository]
** Agave apps: presto-ls5-0.5u4, presto-stampede2-0.5u1, presto-small-0.5u3

* IgBlast version 1.8.0
** [http://www.ncbi.nlm.nih.gov/igblast/faq.html#standalone Source Code]
** Agave apps: igblast-ls5-1.8u3, igblast-stampede2-1.8u3

* VDJML version 1.0.0
** [https://bitbucket.org/vdjserver/vdjml Source Repository]
** Agave apps: igblast-ls5-1.8u3, igblast-stampede2-1.8u3

* RepSum version 1.0.1
** [https://bitbucket.org/vdjserver/repertoire-summarization Source Repository]
** Agave apps: igblast-ls5-1.4u3, igblast-stampede-1.4u3, repcalc-ls5-1.0u3, repcalc-stampede-1.0u3

* Change-O version 0.3.12
** [https://bitbucket.org/kleinstein/changeo/ Source Repository]
** Agave apps: repcalc-ls5-1.0, repcalc-stampede2-1.0

* Change-O (changeset: 453:446d2032f41f, based upon version 0.4.0)
** [https://bitbucket.org/kleinstein/changeo/ Source Repository]
** Agave apps: igblast-ls5-1.4u3, igblast-stampede-1.4u3, repcalc-ls5-1.0u3, repcalc-stampede-1.0u3

* Alakazam version 0.2.5
** [https://bitbucket.org/kleinstein/alakazam/ Source Repository]
** Agave apps: repcalc-ls5-1.0u3, repcalc-stampede-1.0u3

* Shazam 0.1.4
** [https://bitbucket.org/kleinstein/shazam/ Source Repository]
** Agave apps: repcalc-ls5-1.0u3, repcalc-stampede-1.0u3

* Web Application version 1.1.0
** [https://bitbucket.org/vdjserver/vdjserver-web Source Repository]

== VDJServer Release 1.0.3 ==

* vdj_pipe version 0.1.7
** [https://bitbucket.org/vdjserver/vdj_pipe Source Repository]
** [https://hub.docker.com/r/vdjserver/vdj_pipe Docker image]
** Agave apps: vdj_pipe-ls5-0.1.7u7, vdj_pipe-stampede-0.1.7u3, vdj_pipe-small-0.1.7u3

* pRESTO version 0.5.2
** [https://bitbucket.org/kleinstein/presto/ Source Repository]
** Agave apps: presto-ls5-0.5u3, presto-small-0.5u3

* IgBlast version 1.4.0
** [http://www.ncbi.nlm.nih.gov/igblast/faq.html#standalone Source Code]
** Agave apps: igblast-ls5-1.4u3, igblast-stampede-1.4u3

* VDJML version 1.0.0
** [https://bitbucket.org/vdjserver/vdjml Source Repository]
** Agave apps: igblast-ls5-1.4u3, igblast-stampede-1.4u3

* RepSum version 1.0.1
** [https://bitbucket.org/vdjserver/repertoire-summarization Source Repository]
** Agave apps: igblast-ls5-1.4u3, igblast-stampede-1.4u3, repcalc-ls5-1.0u3, repcalc-stampede-1.0u3

* Change-O (changeset: 453:446d2032f41f, based upon version 0.3.3)
** [https://bitbucket.org/kleinstein/changeo/ Source Repository]
** Agave apps: igblast-ls5-1.4u3, igblast-stampede-1.4u3, repcalc-ls5-1.0u3, repcalc-stampede-1.0u3

* Alakazam version 0.2.5
** [https://bitbucket.org/kleinstein/alakazam/ Source Repository]
** Agave apps: repcalc-ls5-1.0u3, repcalc-stampede-1.0u3

* Shazam 0.1.4
** [https://bitbucket.org/kleinstein/shazam/ Source Repository]
** Agave apps: repcalc-ls5-1.0u3, repcalc-stampede-1.0u3

* Web Application version 1.0.3
** [https://bitbucket.org/vdjserver/vdjserver-web Source Repository]

== VDJServer Release 1.0.0 ==

* vdj_pipe version 0.1.6
** [https://bitbucket.org/vdjserver/vdj_pipe Source Repository]
** [https://hub.docker.com/r/vdjserver/vdj_pipe Docker image]
** Agave apps: vdj_pipe-0.1.6u9, vdj_pipe-stampede-0.1.6u6, vdj_pipe-small-0.1.6u10

* pRESTO version 0.5.2
** [https://bitbucket.org/kleinstein/presto/ Source Repository]
** Agave apps: presto-ls5-0.5.2u7, presto-small-0.5.2u5

* IgBlast version 1.4.0
** [http://www.ncbi.nlm.nih.gov/igblast/faq.html#standalone Source Code]
** Agave apps: igblast-ls5-1.4.0u16, igblast-stampede-1.4.0u10

* VDJML version 1.0.0
** [https://bitbucket.org/vdjserver/vdjml Source Repository]
** Agave apps: igblast-ls5-1.4.0u16, igblast-stampede-1.4.0u10

* RepSum version 1.0.0
** [https://bitbucket.org/vdjserver/repertoire-summarization Source Repository]
** Agave apps: igblast-ls5-1.4.0u16, igblast-stampede-1.4.0u10, repcalc-ls5-1.0.0u4, repcalc-stampede-1.0.0u3

* Change-O (changeset: 453:446d2032f41f, based upon version 0.3.3)
** [https://bitbucket.org/kleinstein/changeo/ Source Repository]
** Agave apps: igblast-ls5-1.4.0u16, igblast-stampede-1.4.0u10, repcalc-ls5-1.0.0u4, repcalc-stampede-1.0.0u3

* Alakazam version 0.2.5
** [https://bitbucket.org/kleinstein/alakazam/ Source Repository]
** Agave apps: repcalc-ls5-1.0.0u4, repcalc-stampede-1.0.0u3

* Shazam 0.1.4
** [https://bitbucket.org/kleinstein/shazam/ Source Repository]
** Agave apps: repcalc-ls5-1.0.0u4, repcalc-stampede-1.0.0u3

* Web Application version 1.0.0
** [https://bitbucket.org/vdjserver/vdjserver-web Source Repository]

== VDJServer Release 0.11.0 ==

* vdj_pipe version 0.1.6
** [https://bitbucket.org/vdjserver/vdj_pipe Source Repository]
** [https://hub.docker.com/r/vdjserver/vdj_pipe Docker image]
** Agave apps: vdj_pipe-0.1.6u5, vdj_pipe-stampede-0.1.6u3, vdj_pipe-small-0.1.6u6

* pRESTO version 0.5.2
** [https://bitbucket.org/kleinstein/presto/ Source Repository]
** Agave apps: presto-ls5-0.5.2u3, presto-small-0.5.2u1

* IgBlast version 1.4.0
** [http://www.ncbi.nlm.nih.gov/igblast/faq.html#standalone Source Code]
** Agave apps: igblast-ls5-1.4.0u10, igblast-stampede-1.4.0u8

* VDJML version 1.0.0
** [https://bitbucket.org/vdjserver/vdjml Source Repository]
** Agave apps: igblast-ls5-1.4.0u10, igblast-stampede-1.4.0u8

* rep_char version 0.95.0
** [https://bitbucket.org/vdjserver/repertoire-summarization Source Repository]
** Agave apps: igblast-ls5-1.4.0u10, igblast-stampede-1.4.0u8

* Web Application version 0.11.0
** [https://bitbucket.org/vdjserver/vdjserver-web Source Repository]

== VDJServer Release 0.10.0 ==

* vdj_pipe version 0.1.6
** [https://bitbucket.org/vdjserver/vdj_pipe Source Repository]
** [https://hub.docker.com/r/vdjserver/vdj_pipe Docker image]
** Agave apps: vdj_pipe-0.1.6u5, vdj_pipe-stampede-0.1.6u3, vdj_pipe-small-0.1.6u6

* IgBlast version 1.4.0
** [http://www.ncbi.nlm.nih.gov/igblast/faq.html#standalone Source Code]
** Agave apps: igblast-ls5-1.4.0u9, igblast-stampede-1.4.0u6

* VDJML version 0.1.4
** [https://bitbucket.org/vdjserver/vdjml Source Repository]
** Agave apps: igblast-ls5-1.4.0u9, igblast-stampede-1.4.0u6

* rep_char version 0.95.0
** [https://bitbucket.org/vdjserver/repertoire-summarization Source Repository]
** Agave apps: igblast-ls5-1.4.0u9, igblast-stampede-1.4.0u6

* Web Application version 0.10.0
** [https://bitbucket.org/vdjserver/vdjserver-web Source Repository]

== VDJServer Release 0.9.0 ==

* vdj_pipe version 0.1.6
** [https://bitbucket.org/vdjserver/vdj_pipe Source Repository]
** [https://hub.docker.com/r/vdjserver/vdj_pipe Docker image]
** Agave apps: vdj_pipe-0.1.6u4, vdj_pipe-stampede-0.1.6u2, vdj_pipe-small-0.1.6u5

* IgBlast version 1.4.0
** [http://www.ncbi.nlm.nih.gov/igblast/faq.html#standalone Source Code]
** Agave apps: igblast-ls5-1.4.0u4, igblast-stampede-1.4.0u2

* VDJML version 0.1.4
** [https://bitbucket.org/vdjserver/vdjml Source Repository]
** Agave apps: igblast-ls5-1.4.0u4, igblast-stampede-1.4.0u2

* rep_char version 0.94.0
** [https://bitbucket.org/vdjserver/repertoire-summarization Source Repository]
** Agave apps: igblast-ls5-1.4.0u4, igblast-stampede-1.4.0u2

* Web Application version 0.9.0
** [https://bitbucket.org/vdjserver/vdjserver-web Source Repository]


*****


VDJServer incorporates germline data for use by IgBlast and other tools. Additional processing is performed on this data to create a VDJ DB which is used by repertoire-summarization and other analysis tools. VDJML files will reference these databases with a specific version number.

== Version 10_05_2016 ==

This version is identical to 07_11_2014 except an internal file, hierarchy_data.pkl, which is a python pickle file containing gene hierarchy data was modified for the new RepSum.

== Version 07_11_2014 ==
