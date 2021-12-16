.. _DeveloperGuide:

*****************
Developer's Guide
*****************

This developer's guide documents the design and implementation of the
VDJServer system with emphasis on the processes and data structures used
to implement the functionality. VDJServer contains numerous server-side
services designed to run 24/7 with minimal manual intervention that are
tightly integrated with the graphical user interface. This guide should
be consulted when source code is to be modified or enhanced, and should
be updated when new functionality is added to the system. Details about
deployment of VDJServer is available in the :ref:`Administration Guide
<AdministrationGuide>`.

VDJServer is managed by Dr Lindsay G. Cowell at UT Southwestern Medical
Center. Dr Scott Christley is the software development manager and is
responsible for day-to-day operations.

VDJServer Architecture
======================

VDJServer is a multi-tiered system for immune repertoire analysis and data
sharing providing:

#. An open suite of interoperable repertoire analysis tools that allows
   users to upload a set of sequences and pass them through a seamless
   workflow that executes all steps in an analysis.

#. Access to sophisticated analysis tools running in a high-performance
   computing (HPC) environment.

#. Interactive visualization capabilities for exploratory analysis.

#. A data management infrastructure for sharing data and querying the AIRR Data Commons.

#. A graphical user interface to facilitate use by experimental and
   clinical research groups that lack bioinformatics expertise.

The VDJServer system is composed of three core components consisting of
a graphical user interface (:ref:`VDJServer Web <VDJServerWeb>`), a secure API for performing
core functions (:ref:`VDJServer API <VDJServerAPI>`), and the Community Data Portal (CDP).
These core components contain additional sub-components and are tightly
integrated across the whole system. VDJServer is designed upon the Tapis APIS cloud platform,
which allows database implementation to be offloaded into the cloud
platform. This simplifies VDJServer’s architecture and provides the many
benefits of cloud computing, such as lower maintenance costs, quick and
flexible deployment, and dynamic scaling to accommodate user load. The
Tapis APIs are a collection of RESTful web services with user identity
management, file management, systems management, application deployment,
metadata database, events/notifications, and job execution as some of
their main functionality. VDJServer utilizes Docker for composing
services run on VMs provided by the Texas Advanced Computing Center
(TACC), which also provides resource allocation for running analysis
jobs on HPC.

.. _VDJServerWeb:

VDJServer Web
=============

Source code repository: https://bitbucket.org/vdjserver/vdjserver-web-backbone

VDJServer Web is a web-based graphical user interface. Specifically, a Javascript Single-Page
Application using Backbone models, Marionette views, and Bootstrap styling. Handlebars
is used for HTML templating. The design follows the Model-View-Controller pattern for the
complex pages; while for simpler pages, the controller is embedded in the Marionette view.

Here are the primary GUI sections and modules:

+ Home / Login
+ Navigation Bar
+ Documentation
+ Feedback
+ Account Creation
+ Project List
+ Project Views

  + Upload, download, and organize data files
  + Import subject and sample tables
  + Metadata entry, import, export
  + Generate Repertoires
  + Define Repertoire Groups
  + Perform Analysis Workflows
  + Visualize Analysis Results

+ Publish Study

+ VDJServer Administration

  + Users and Jobs
  + Data Repository

+ Community Data Portal

  + Query the AIRR Data Commons
  + Download study data
  + Create repertoire groups
  + Statistics and analysis visualizations
  + Comparative analysis with private data

Home / Login
------------

Navigation Bar
--------------

Documentation
-------------

Account Creation
----------------

VDJServer uses an email verification system combined with Google Recaptcha to avoid bots.
This means that the GUI needs to be used for account creation in order to generate the
Recaptcha response. However, verification just requires the correct code and could be
sent directly to the API, though there is a simple GUI screen for submission. The basic process:

#. Display account creation page. User enters information and clicks Create Account button.
   Some validation checks are performed in the browser, and errors are displayed if necessary.
   Valid form data is sent to ``/user`` API endpoint.
#. API saves user account and creates verification metadata item. Sends verification code
   email with the uuid for the verification metadata. The email contains a link
   to the ``/account/verify/{uuid}`` GUI page.
#. With successful response from API, redirect the user to the ``/account/pending`` where
   the user can enter the code manually. Entering the code sends the user to the same
   link in the email ``/account/verify/{uuid}``.
#. The ``/account/verify/{uuid}`` GUI page issues the request to the ``/user/verify/{uuid}`` API
   end point, and with successful response redirects the user to the login screen.

Feedback
--------

There are two feedback views: one for authentication users and another for anonymous users.
This design matches directly with the APIs two endpoints, and thus there are the two
backbone models of ``UserFeedback`` and ``PublicFeedback``, with ``feedback-user`` and ``feedback-public``
as the two marionette views. Each has a template html file. I did not change the design
in the refactor. The two views are very similar in appearance and function and they could
be merged together but not really necessary as they are both simple views. Access to the
appropriate feedback view is controlled by the link in the navigation bar.

Public Feedback
^^^^^^^^^^^^^^^

Public feedback does not require the person to be logged into a user account. It uses
Google Recaptcha to avoid bots. This link is provided in the Public navigation bar.

User Feedback
^^^^^^^^^^^^^

User feedback requires that the user is logged in with an active token. It does not require
Google Recaptcha. This link is provided in the Private navigation bar. The error case where
the token expires when sent to the API could be handled better.

Feedback API
^^^^^^^^^^^^

There are two feedback endpoints: one for authenticated users and another for anonymous
users. The ``Feedback`` object contains a simple string, while the ``PublicFeedback`` object
further contains a Recaptcha response and a user email. For authenticated users, the Tapis token
is used to retrieve the user's email.

+ /feedback

+ /feedback/public

Both are POST methods where a ``Feedback`` or ``PublicFeedback`` object is sent as the request
body for ``/feedback`` or ``/feedback/public`` endpoints, respectively. The ``/feedback`` endpoint
has ``user_authorization`` security while the public does not.


.. _VDJServerAPI:

VDJServer API
=============

Source code repository: https://bitbucket.org/vdjserver/vdjserver-web-api

The core API for VDJServer. It provides numerous capabilities with the endpoints
organized within core categories. These categories are tags on the endpoints in the
OpenAPI specification.

+ authentication: create and refresh authentication tokens
+ user: create/verify user account, change/reset password
+ project: create project, import/export metadata, publish/unpublish, load/unload into ADC
+ permission: manage user permissions on project data
+ feedback: public and user feedback
+ telemetry: system error reporting
+ ADC: query/cache of the AIRR Data Commons

Encapsulation of Tapis APIs
---------------------------

VDJServer uses the Tapis APIs extensively for most of the cloud-based infrastructure. The
VDJServer API is essentially an encapsulation of Tapis with VDJServer specific design and
functionality. For example, most VDJServer operations require multiple Tapis API requests,
such as creating metadata entries and setting permissions, so the VDJServer API bundles
them together, adds fault tolerance and error checking, and often executes them in queues
to be performed asynchronously and autonomously.

The V1 design only have VDJServer API, but V2 now has multiple services that access Tapis.
The ``tapis-vdj`` repository is a javascript package which provides a large set of functions
that encapsulate Tapis API requests that is shared across all services. Those services use
the ``tapis-vdj`` functions instead of directly calling Tapis, and this allows us to
provide consistent error handling. The exception to this is :ref:`VDJServer Web <VDJServerWeb>`
which uses Backbone models to communicate with Tapis. However, we try to avoid doing complex
operations in the GUI by putting them within the VDJServer API instead, and any operation
that requires admin authorization must also be done by the VDJServer API. Exceptions are simpler
"atomic" operations like updating metadata entries and file uploads which can be done with
standard user authorization.

Security schemes
----------------

The V1 design had a mix of schemes. All the basic authentication schemes
were eliminated and now the API supports strictly ``Bearer`` tokens,
which are Tapis tokens, so all endpoints are either public or they
require a valid token. Furthermore, V1 did checks for basic user
authorization and a second check for project authorization. The two
checks have been formalized in OpenAPI V3 as ``user_authorization`` and
``project_authorization`` schemes. As we only want a single security
scheme attached to each endpoint (so it works exclusively),
``project_authorization`` has to perform ``user_authorization`` as well.
There is an additional ``admin_authorization`` for the highest
authorization. All of the authorization code is contained in
``authController.js``.

ADC endpoints
^^^^^^^^^^^^^

ADC system repositories
-----------------------

End point: ``/adc/registry``

We want to define a set of default ADC repositories that will automatically be queried
when a user goes to the CDP. We also want to support a user to alter that set by
turning on/off any of those default repositories as well as adding in their own. We use
the Tapis metadata to store this information. A design decision is if each individual
ADC repository should be in individual metadata entries, or should all the entries be
put within a single metadata entry. Given that we expect the set to be small,
the latter design of a single entry is simpler.

The set of default ADC repositories are stored in a singleton metadata entry. This entry
must be owned by the service account. Each repository has a name (``repository_name``)
that is the object key::

  name: adc_system_repositories
  value:
    adc: set of objects
      <repository_name>:
        title: string
        enable_cache: boolean
        server_host: string
        base_url: string
        supports_async: boolean
        async_host: string
        async_base_url: string
        disable: boolean

User override can only enable/disable the default repositories...

ADC staging/development repositories
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

While `adc_system_repositories` with the `adc` object provides the
default set of production ADC repositories, it is useful to be able to
test development and staging in isolation. Thus we have additional
objects in that singleton metadata, `staging` and `develop`, which can
contain a different set of entries with different settings. The
configuration file for the service sets the name of the entry to be
used::

  name: adc_system_repositories
  value:
    staging: set of objects
      <repository_name>:
        title: string
        enable_cache: boolean
        server_host: string
        base_url: string
        supports_async: boolean
        async_host: string
        async_base_url: string
        disable: boolean
    develop: set of objects
      <repository_name>:
        title: string
        enable_cache: boolean
        server_host: string
        base_url: string
        supports_async: boolean
        async_host: string
        async_base_url: string
        disable: boolean

ADC Load and Unload
-------------------

Loading and unloading studies from the :ref:`Community Data Portal
<CommunityDataPortal>` can be initiated with requests to the API. Both
API end points are protected by ``admin_authorization``. Note that loading
and unloading from the ADC is different from publishing and unpublishing
a study which can be done by a project user.

To avoid users potentially querying and downloading partial data sets
while data is being loaded, we employ a double-buffer scheme with one
set of Mongo collections (staging) for loading data, and another set of
Mongo collections (production) for public queries. Periodically, a new
database release is announced, which swaps the roles of staging and
production, and then the newly loaded studies are publicly available.
The Mongo collections have the same name but either a ``_0`` or ``_1``
suffix, e.g. ``rearrangement_0`` and ``rearrangement_1``. The particular
collections are defined with environment configuration parameters. For
example, these parameters define the ``_0`` collections for public query
while the ``_1`` collections are for loading::

  MONGODB_QUERY_COLLECTION=_0
  MONGODB_LOAD_COLLECTION=_1

There are a couple reasons for this design:

#. Loading is extremely slow (~20x slower) with indexes defined, in particular the very large
   ``junction_suffix`` index for CDR3 searches. The staging collections have this
   index deleted so loading is much faster.

#. Initially, Tapis did not support mass updating of database records so using a flag field
   to indicate currently loading data, and thus could be excluded from queries, would require
   some manual intervention, i.e. directly run update scripts on the database. Regardless,
   the slow loading with indexes likely prevents using this flag design anyways.

While this design doubles the size of the database and requires loading each twice, once
in each collection set, it has easy management and doesn't require modifying queries or
dropping indexes. As we expect new studies to be loaded for the foreseeable future, this
design is currently the most practical.

Load project into ADC
^^^^^^^^^^^^^^^^^^^^^

End point: ``/project/{project_uuid}/load``

Loading a study occurs in multiple phases:

#. Gather study data
#. Load repertoires
#. Load rearrangement data

There is a metadata entry for each project/study::

  name: projectLoad
  associationIds: [ "Project UUID" ]
  value:
    collection: string
    shouldLoad: boolean
    isLoaded: boolean
    repertoireMetadataLoaded: boolean
    rearrangementDataLoaded: boolean

and a metadata entry for the rearrangements in each repertoire::

  name: rearrangementLoad
  associationIds: [ "Project UUID" ]
  value:
    repertoire_id: string
    collection: string
    isLoaded: boolean
    load_set: integer

Unload project from ADC
^^^^^^^^^^^^^^^^^^^^^^^

End point: ``/project/{project_uuid}/unload``

Updating repertoire metadata for project in ADC
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

End point: ``/project/{project_uuid}/reload``

We expect that updating the repertoire metadata will occur occasionally such as adding
publications, updating contact information, correcting typos and errors. In these situations,
the repertoire metadata needs to re-loaded but the rearrangement data does not change, so
we do not want to unload the whole study but only force the repertoire metadata to be
re-loaded. We can trigger this by setting appropriate flags, specifically:

#. Change ``repertoireMetadataLoaded`` in the ``projectLoad`` metadata entry to ``false``.
#. Change ``isLoaded`` in the ``projectLoad`` metadata entry to ``false``.

When the trigger queue periodically checks for projects to be loaded, it will see that the
project needs to be loaded and re-load the repertoire metadata. Furthermore, the process
will set ``adc_update_date`` to the current date/time of the load.

While this updates the data repository, it does not update any cache entries. In
particular, the ADC download cache needs to be updated with the new repertoire metadata.
Similarly, the rearrangement data has not changed so we do not want to completely delete
the cache. Instead, we can trigger the update with a setting, specifically:

#. Change ``is_cached`` in the ``adc_cache_study`` metadata entry to ``false``.
#. Change ``archive_file`` in the ``adc_cache_study`` metadata entry to ``null``.

When the trigger queue periodically checks for studies to be cache, it
will see the updated entry, generate a new repertoire metadata file, and
generate a new study archive file. The postit is tricky because we would
like to keep the same postit entry for historical information about
downloads. However, there's the rare possibility that the new repertoire
metadata increases the size and the archive file gets split, or
vice-versa where the size is smaller and is not split. Therefore, we
will let it automatically create new postits. When we do reporting, we
will need to go through historical postit records to get accurate
counts. There is still the issue that a user may have the CDP website
loaded in their browser from earlier and click download study during
this re-generation time. There is the chance that the user will download
a partially generated archive file. Handling this properly is
complicated so we will hope the situation is rare, while re-generation
is quick, so the user can just download again after a short period of
time.

As a simple safety check, the end point requires the UUID for the metadata load
record to be specified with the request.

Loading an additional data processing
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Not yet designed and implemented.

ADC Download Cache
------------------

While the ADC ASYNC API allows for better scheduling of large queries, it is still
very time consuming to extract the data for large studies from the database. The download
cache will provide a pre-packaged archive of the repertoires and rearrangements (and possibly
other data) for a complete study, so it can be immediately downloaded.

Initially the cache is for the VDJServer repository and the CDP GUI, but it may be extended
to cache studies from other repositories.

The list of capabilities include:

+ API end point to manually initiate the above queue process.

  + /adc/cache: enable, disable or trigger cache process

+ API end point to enable/disable/delete metadata entries for study/repertoire.
+ GUI admin screen for administration of the cache.

The caching process will be triggered on a periodic basis using a `Bull` queue setting. The
time period is a system configuration variable.
The caching process can be enabled, disabled or triggered with ``/adc/cache`` endpoint.
When the cache process is disabled, the process will be paused at the next queue checkpoint.
Likewise, enabling the process will allow the process to run at the next periodic trigger.
The process can be immediately started with a trigger operation.
A singleton metadata entry stores the current state::

  name: adc_cache
  value:
    enable_cache: boolean

We use Tapis metadata entries to record cache information for each study and for each
repertoire. The repertoire entry is actually for the rearrangement data for that repertoire,
as that data can be quite large for individual repertoires. This should also allow for
optimizing the Stats API which operates on individual repertoires. Each cached file has
an unlimited public postit created for it for download convenience.

There is a metadata entry for each study::

  name: adc_cache_study
  value:
    repository_id: string
    study_id: string
    should_cache: boolean
    is_cached: boolean
    archive_file: string
    download_url: string

and a metadata entry for each repertoire::

  name: adc_cache_repertoire
  value:
    repository_id: string
    study_id: string
    repertoire_id: string
    should_cache: boolean
    is_cached: boolean
    archive_file: string
    download_url: string

This `adc_cache_repertoire` entry will be expanded to handle more than rearrangements when
new object types are required, such as clones. We avoid having entries for each object type
as that's likely too fine-grained. That expansion depends somewhat on how `DataProcessing`
gets re-designed.

It's not completely clear how we should handle multiple data processings. The `data_processing_id` field needs
to be added, but do we have an metadata entry for each or keep a list in `adc_cache_repertoire`.

Managing and populating the cache is done with both the VDJServer Web API and GUI. Access
is strictly for the service account. The basic design is that a queue process will periodically
run in the Web API that:

#. Queries all studies/repertoires in the ADC.
#. Checks that studies/repertoires have metadata entries and creates them if necessary.
#. Queries metadata entries and initiates caching the data.

Caching is done for one study/repertoire at this time until we decide upon level of concurrency
that we want to support. We use a set of Bull queues to handle the progression of tasks:

+ triggerQueue: Enforces single job, triggers cache update if no job is running
+ submitQueue: Queries ADC and creates/updates metadata cache entries for studies and repertoires,
  and then gets next entry to be cached and submits job
+ cacheQueue: Performs ADC query and download
+ finishQueue: Performs any clean and re-triggers the process

`ADCDownloadQueueManager.triggerDownloadCache` is the initialization routine that turn on
the queue. It also submits a periodic (TODO: config) job to the triggerQueue.

.. _CommunityDataPortal:

Community Data Portal
=====================

The Community Data Portal is VDJServer's data sharing infrastructure. It
consists of a data repository for the AIRR Data Commons and a graphical
user interface to query and download data from the AIRR Data Commons. The
infrastructure comprises of a number of sub-components:

+ A Mongo database, which is hosted and managed by TACC, to store the AIRR-seq data.

+ The :ref:`VDJServer ADC API <VDJServer_ADC_API>` which implements the ADC API for querying the AIRR Data Commons.

+ The :ref:`VDJServer ADC ASYNC API <VDJServer_ASYNC_API>` which implements the extension API for asynchronous query of the AIRR Data Commons.

+ The :ref:`VDJServer STATS API <VDJServer_STATS_API>` which implements the iReceptorPlus API for statistics.

+ The graphical user interface for querying and downloading from the AIRR Data Commons is integrated into :ref:`VDJServer Web <VDJServerWeb>`.

+ The 

.. _VDJServer_ADC_API:

VDJServer ADC API
=================

VDJServer implementation of the AIRR Data Commons API V1.

.. _VDJServer_ASYNC_API:

VDJServer ADC ASYNC API
=======================

This API encapsulates the Tapis LRQ API which has restricted access and provides additional
functionality beyond the LRQ API. A metadata V1 entry ``{"name":"async_query"}`` is created to hold LRQ information
and any additional information. The metadata UUID is returned as the async API query identifier.

.. _VDJServer_STATS_API:

VDJServer STATS API
===================

VDJServer implementation of the iReceptor+ Statistics API.

Statistics Cache
----------------

To quickly respond to requests for statistics, we cache them. This should only be
for VDJServer ADC data, as other ADC repositories should implement the Statistics API
for themselves.

The list of capabilities include:

+ API end point to manually initiate the above queue process.

  + /stats/cache: enable, disable or trigger cache process

+ API end point to enable/disable/delete metadata entries for study/repertoire.
+ GUI admin screen for administration of the cache.

The caching process will be triggered on a periodic basis using a `Bull` queue setting. The
time period is a system configuration variable.
The caching process can be enabled, disabled or triggered with ``/stats/cache`` endpoint.
When the cache process is disabled, the process will be paused at the next queue checkpoint.
Likewise, enabling the process will allow the process to run at the next periodic trigger.
The process can be immediately started with a trigger operation.
A singleton metadata entry stores the current state::

  name: statistics_cache
  value:
    enable_cache: boolean

While this metadata entry controls global behavior, an individual service also needs the
`STATS_API_ENABLE_CACHE` environment configuration variable set to `true`.

We use Tapis metadata entries to record cache information for each
repertoire. The repertoire entry is actually for the rearrangement/clone
data for that repertoire. This service relies upon the ADC Download
Cache, and it uses that cached data for calculating statistics.

Currently, the plan is to also store the actual statistics data in Tapis metadata entries.
The number of entries is on the order of the number of repertoires, and presumably that data
will not get so large as to exceed the data size limits.

There is metadata entry for the each repertoire::

  name: statistics_cache_data
  value:
    repository_id: string
    study_id: string
    repertoire_id: string
    should_cache: boolean
    is_cached: boolean
    rearrangement_statistics: object
    clone_statistics: object

Generating the statistics involves running a Tapis job.

.. toctree::
   :maxdepth: 1
