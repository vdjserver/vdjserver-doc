.. _CommunityDataPortal:

=======================
Community Data Portal
=======================

Publicly Share Data
-------------------

If you used VDJServer for immune repertoire analysis, your data and
analysis files are already available within VDJServer, and you can skip
directly to Step 3 below to publicly share your project. It is not
necessary to have performed analysis on VDJServer in order to publicly
share your data. Create an account at https://vdjserver.org to get
started.

1. Create Project
    Click on the Add Project button to create a new project and give the
    project a name. To help users identify your project, use a descriptive
    name such as the title of your study publication. After the project is
    created, go to the Metadata Entry page and fill out the Project / Study
    Metadata with a long study description (e.g. abstract of paper), PI and
    contact information, grant information, publication identifiers (e.g.
    Pubmed ID), and the BioProject ID. Click the Save Project Metadata
    button to save your changes. It isn’t necessary to enter metadata for
    the other sections.

2. Upload Files into Project
    From the Upload and Browse Project Data page, click on the Upload button
    and select files from your local computer, from Dropbox, or from a URL
    (ftp/http), to be uploaded; multiple files can be selected. Click the
    Start button to start uploading.

3. Publish Project
    On the Project Settings page, copy/paste the VDJServer UUID. This is a
    long identifier with numbers, letters and dashes that uniquely
    identifies your project. Provide this UUID in the Data Availability
    section of your publication so users can directly search and find your
    project. Finally, click the Project Actions button and select Publish
    Project. This will initiate publishing, and you will receive an email
    when the project is publicly available. Changes cannot be directly made
    to a published project, but as the project owner you can unpublish the
    project at any time to correct information or files. On the Community
    Data page, find your project and go to the Project Settings page. Click
    the Project Actions button and select Unpublish Project; you will
    receive an email when the project has been unpublished. Make the
    necessary corrections to your project then publish it to make it
    publicly available again.

Publish AIRR-seq Study in the AIRR Data Commons
-----------------------------------------------

Publishing your AIRR-seq study in the ADC with VDJServer is not a
completely automated process; there are a number of manual validation
steps that need to be performed. Furthermore, loading the data into the
repository database can take hours, days or even a week depending upon
the size of the data; therefore, the load process is initiated by a
VDJServer administrator. The basic requirements include:

1. Study metadata in AIRR Repertoire format.
    Validation scripts are run to verify the metadata is valid and
    complete. If the study metadata has been provided in VDJServer’s
    Metadata Entry page, that metadata can be automatically converted
    into the AIRR Repertoire format.

2. Rearrangement (annotated sequence) data in AIRR TSV format.
    If your rearrangement data is not in the AIRR TSV format, it may
    need to be converted or run through the IgBLAST tool on VDJServer.
    Validation scripts are run to verify that the annotations are valid
    and complete.

3. VDJServer administrator loads the study into VDJServer’s repository.
    Contact VDJServer (vdjserver@utsouthwestern.edu) to initiate publishing
    your study.

Data Charges for Repository Copies
----------------------------------

VDJServer offers the ability to provide a complete copy of the data repository
to the customer. This can be a quicker option to acquire large quantities of data versus
downloading through the portal. As this requires additional time and resources by
VDJServer personnel, we need to impose a data charge for cost recovery. The
following options are available:

1. (Price: $2000 USD) Upload data to an Amazon S3 bucket. 
    We will upload either to a customer-provided bucket or create a new
    bucket and provide access. In the case that we create the bucket, it
    will only be accessible for a pre-determined amount of time
    (typically one month), so the customer is required to move the data
    into their own bucket.

2. (Price: $2000 USD) FEDEX/UPS a hard disk drive with the data to the customer.
    We purchase a standard SATA hard drive but can use a customer-provided SATA hard drive if desired.
    The hard drive becomes the customer's property and does not need to be returned.

3. (Price: $3000 USD) Both options 1 and 2.
    We will upload data to an Amazon S3 bucket and provide the customer with a hard disk drive.

4. Yearly update for options 1, 2 or 3.
    The same price as the requested option.
    A repository copy is sent automatically to the customer every year.

Please contact VDJServer (vdjserver@utsouthwestern.edu) to initiate an order. Other data
delivery options can be provided as well as training services about the data and data formats.
Payment is processed through an invoice sent by UT Southwestern Medical Center.

.. toctree::
   :maxdepth: 1
