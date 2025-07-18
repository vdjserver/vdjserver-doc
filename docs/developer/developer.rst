.. _DeveloperGuide:

*****************
Developer's Guide
*****************

.. contents:: Table of Contents
   :depth: 2
   :local:
   :backlinks: none

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
core functions (:ref:`VDJServer API <VDJServerAPI>`), and the Community Data Portal (:ref:`CDP <CommunityDataPortalDev>`).
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

.. _VDJServerSchema:

VDJServer Schema
================

Source code repository: https://bitbucket.org/vdjserver/vdjserver-schema

VDJServer Schema defines all objects utilized across the VDJServer services in
a central place. Similar to the AIRR Standards, VDJServer Schema objects are
defined using the OpenAPI V3 specification extensions to JSON schema.

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

Project Views
----------------

File Uploading
--------------

File uploading is a three step process:

#. Upload the file using Tapis Files API.

#. The Tapis API stages (copies) the file to the destination storage system.

#. Metadata entry is created and permissions are set.

VDJServer V1 used a webhook technique for the server to inform the web browser client when
the staging process by Tapis API was done; however this communication stream often did not
work and the UI would appear to be hung. Likewise, the metadata creation and permissions is
performed by a queue so it happens asynchronously with the client. For V2, rewrote the uploading
code so the browser actively waits and checks for all three steps to finish before it signals
that the file upload is complete.

Also, the upload code is put in the file controller object so that the views can be destroyed
and re-created without disturbing the upload process. This should allow the user limited
navigation to other screens and can still go back and check upload progress.

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
The ``vdj-tapis-js`` repository is a javascript package which provides a large set of functions
that encapsulate Tapis API requests that is shared across all services. Those services use
the ``vdj-tapis-js`` functions instead of directly calling Tapis, and this allows us to
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

Analysis Workflows
------------------

The V1 design had a number of limitations that made it challenging to maintain. In particular,
there was tight coupling between the GUI and the Tapis app definitions. Changes to parameters
needed to be performed in both places, and reproducibility would get lost as those apps were
modified and updated over time. This also introduced tight coupling between the apps themselves
as outputs became inputs for the next app in the workflow. Providing flexibility in these output/input
matchings, along with flexibility within the workflow, was challenging because there are
many possible combinations. This would grow more complex as more tools and features were added.
Furthermore, to reduce the amount of coupling, the Tapis apps were
written to be monolithic, performing many operations in a single job. With Tapis V3, there
is less ability to design large monolithic apps because apps must be containerized and
only a single container image can be used. This also prevents us from doing multi-node parallelism
with the ``launcher`` module as it cannot operate inside the singularity environment.

With the VDJServer V2 design, we introduce a number of changes to reduce tight coupling,
to increase flexibility, and to manage parallelism.

+ Declarative task workflow description that is agnostic to the Tapis app description. It is
  based upon the PROV provenance standard and is designed to easily generate a PROV model
  as the provenance for the workflow.

+ Task workflows can be validated to insure all files, apps, etc., are present and valid before
  attempting to run any jobs.

+ Task workflows can utilize any number of Tapis apps in series or in parallel. Task workflows
  are directed acyclic graphs that get translated into a set of Tapis jobs. Tapis V3 provides
  a workflow API but it is custom to the Tapis environment, and it is unclear if it is flexible
  enough for our requirements.

+ Output/input matching is more explicit and does not rely upon file names.

+ Analysis workflows are organized around repertoires and repertoire groups.

+ Tapis apps should be simpler as they do not have to manage multi-node parallelism.

One of the primary results of the V2 design is that many more Tapis jobs will get executed,
which requires that we better and robust management for those jobs. For example, a project
with 20 repertoires might have run one job to process those repertoires but now may require
multiple jobs as parallelism is handled outside of the Tapis app.

Workflow execution
^^^^^^^^^^^^^^^^^^

End point: ``/project/{project_uuid}/execute``

Submission of an ``AnalysisRequest`` containing the ``AnalysisDocument`` to be validated
and executed. The ``AnalysisDocument`` is composed of a ``TaskDocument`` and a ``ProvDocument``.
The ``TaskDocument`` describe the workflow tasks to be performed, while the ``ProvDocument``
will be filled out with provenance information as the tasks are performed. The ``AnalysisDocument``
is stored in the database with the Tapis Meta API.

ProvDocument and TaskDocument
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The PROV model provides a general provenance description that is agnostic to the objects
and activities being performed. This means that we need to enhance the model with additional
attributes to provide semantics for analysis workflows. It has three core objects:

+ ``agent``: The person or computational agent attributed to the activities. For VDJServer,
  this is either the user or the associated project depending upon the context.

+ ``entity``: The things that the activities are operating upon such as
  repertoires, repertoire groups, files, data, etc.

+ ``activity``: Operations to perform on entities. For VDJServer, these are primarily Tapis apps
  but also support specialized operations like ADC queries.

The primary relations between these objects that VDJServer uses are:

+ <entity> ``wasAttributedTo`` <agent>: Ownership of entity by the agent.

+ <activity> ``wasAssociatedWith`` <agent>: Association of an activity with an agent.

+ <entity> ``used`` <activity>: Activity uses an entity, essentially a reference to an input
  to the activity.

+ <entity> ``wasGeneratedBy`` <activity>: Activity generated an entity, essentially a reference
  to an output produced by the activity.

+ <entity> ``wasDerivedFrom`` <entity> by <activity>: Entity derived from another entity, possibly by an
  activity though not required. For activities that process multiple inputs and produce multiple
  outputs, this relation provides explicit input/output matching that does not rely upon file names
  or other imprecise attributes.

These relations have additional attributes which are not described here. Also note that all of
the relations are past tense English, and thus indicate that the activities have already occurred.
For the ``TaskDocument``, we keep the same relations but transform them to present tense
English. This provides a nice duality with a simple description of a task workflow.

+ <entity> ``isAttributedTo`` <agent>

+ <activity> ``isAssociatedWith`` <agent>

+ <entity> ``uses`` <activity>

+ <entity> ``isGeneratedBy`` <activity>

+ <entity> ``isDerivedFrom`` <entity> by <activity>

Tapis Job Queues
^^^^^^^^^^^^^^^^

While the Tapis APIs handle the details of staging, submitting, monitoring, and archiving jobs
for the storage and execution systems, VDJServer needs to perform its own pre- and post-processing of jobs.
VDJServer also needs to detect when jobs fail due to insufficient runtime versus other errors
so those jobs can be re-scheduled with longer runtime. There are a number of ``bull`` queues
that manage the various processes. They are designed to be reentrant which, in the single-threaded
environment of Javascript node, means that it can be interrupted, and a new execution can be
safely restarted. Note that we expect VDJServer to only be running one server process, so we
do not expect the processes to be running concurrently on multiple machines.
Interrupts include bringing the server down, network outages, Tapis APIs
outages, and so forth. The key to reentrancy is maintaining state as the process progresses
so the code can determine the last operations that were performed. Also, any operations that
are re-performed upon the new execution should not produce inconsistent states, e.g. double
counting, and should avoid inefficiencies like re-running jobs that were already submitted
or ran correctly. Here are the ``bull`` queues that manage Tapis jobs:

+ trigger

+ check

+ create

+ job

+ finish

+ clear


ADC endpoints
-------------

ADC system repositories
^^^^^^^^^^^^^^^^^^^^^^^

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
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Loading and unloading studies from the :ref:`Community Data Portal
<CommunityDataPortalDev>` can be initiated with requests to the API. Both
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

.. _CommunityDataPortalDev:

Community Data Portal
=====================

The Community Data Portal is VDJServer's data sharing infrastructure. It
consists of a data repository for the AIRR Data Commons and a graphical
user interface to query and download data from the AIRR Data Commons. The backend API
components are integrated into the VDJServer Repository (`vdjserver-repository`_) while
the GUI is included within :ref:`VDJServer Web <VDJServerWeb>`.
The infrastructure is comprised of a number of sub-components:

+ A Mongo database, which is hosted and managed by TACC, to store the AIRR-seq data.

+ The :ref:`VDJServer ADC API <VDJServer_ADC_API>` which implements the ADC API for querying the AIRR Data Commons.

+ The :ref:`VDJServer ADC ASYNC API <VDJServer_ASYNC_API>` which implements the extension API for asynchronous query of the AIRR Data Commons.

+ The :ref:`VDJServer STATS API <VDJServer_STATS_API>` which implements the iReceptorPlus API for statistics.

+ The graphical user interface for querying and downloading from the AIRR Data Commons is integrated into :ref:`VDJServer Web <VDJServerWeb>`.

+ The ADC Download Cache and the functions for loading/unloading studies is currently implemented in the :ref:`VDJServer API <VDJServerAPI>`.

.. _`vdjserver-repository`:
   https://bitbucket.org/vdjserver/vdjserver-repository

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

Source code repository: https://bitbucket.org/vdjserver/stats-api-js-tapis

VDJServer implementation of the iReceptor+ Statistics API.
The ``stats-api-js-tapis`` repository is a git submodule
in the VDJServer Repository (`vdjserver-repository`_) and is
integrated with the other services using Docker compose. The STATS API has three main
subcomponents including the :ref:`Query API <VDJServer_STATS_QUERY_API>`,
an :ref:`Administration API <VDJServer_STATS_ADMIN_API>`,
and the :ref:`Statistics Cache <VDJServer_STATS_CACHE>`. An administration GUI
is included within :ref:`VDJServer Web <VDJServerWeb>`.

.. _`vdjserver-repository`:
   https://bitbucket.org/vdjserver/vdjserver-repository

.. _VDJServer_STATS_QUERY_API:

Query API
---------

The query API is defined by the
`iReceptor+ specification <https://github.com/ireceptor-plus/specifications/blob/master/stats-api.yaml>`_.
The ``specifications`` repository is brought into ``stats-api-js-tapis`` as a git submodule so
that versioning can be controlled. The queries are processed in ``statsController.js``

.. _VDJServer_STATS_ADMIN_API:

Administration API
------------------

The Administration API is defined in a separate YAML file in ``stats-api-js-tapis`` then integrated
with the Query API when the service starts. The purpose of the Administration API is primarily
to manage the Statistics Cache. It is composed of some public end points to query cache entries
but all others require admin authorization. The end points reside under the ``/irplus/v1/stats``
base URL.

+ ``/cache``: Query the global Statistics Cache settings (GET). Enable, disable or trigger the Statistics Cache (POST).

+ ``/cache/study``: Query study cache entries (GET).

+ ``/cache/study/{cache_uuid}``: Enable/disable caching or reload database for a specific study (POST). Delete the
  cache for the study including files and database records (DELETE).

+ ``/cache/repertoire/{repertoire_id}``: Enable/disable caching for a specific repertoire (POST). Delete the
  cache for the study including files and database records (DELETE).

+ ``/cache/notify/{cache_uuid}``: Job notification (POST). This receives notifications from statistics jobs as
  their status changes and is not normally called by the admin user.

.. _VDJServer_STATS_CACHE:

Statistics Cache
----------------

To quickly respond to requests for statistics, we cache them. This should only be
for VDJServer ADC data, as other ADC repositories should implement the Statistics API
for themselves.

The caching process is triggered on a periodic basis using a `Bull` queue setting. The
time period is a system configuration variable.
The caching process can be enabled, disabled or triggered with ``/stats/cache`` endpoint.
When the cache process is disabled, the process will be paused at the next queue checkpoint.
Likewise, enabling the process will allow the process to run at the next periodic trigger.
The process can be immediately started with a trigger operation.
A singleton metadata entry stores the current state::

  name: statistics_cache
  value:
    enable_cache: boolean

This metadata entry controls global behavior, is primarily intended for the production
service, and should not be used to control development or staging services.
Each individual service also needs the ``STATS_API_ENABLE_CACHE`` environment
configuration variable set to `true`. This environment variable should be used to control
individual services. Be careful of having multiple services generating statistics and
writing them to the database. There is also a per repository setting in the list of ADC
repositories, and currently only VDJServer is enabled. The statistics cache environment variables:

+ ``STATS_API_PORT=8025``: Default port for service
+ ``STATS_API_ENABLE_CACHE=false``: Enable/disable statistics cache queues for this service.
  The service will still respond to API requests.
+ ``STATS_MAX_JOBS=10``: Maximum concurrent statistics jobs.
+ ``STATS_TIME_MULTIPLIER=8``: Multiplicative increase of a statistic job's run time when
  it fails due to a ``TIMEOUT`` error.
+ ``STATS_TAPIS_APP=irplus-statistics-stampede2-0.1u6``: Name of the Tapis statistic app.
  Currently there is an app defined for Stampede2 and Lonestar6.
+ ``STATS_TAPIS_QUEUE=skx-normal``: Name of execution system queue to use for job submission.
+ ``STATS_TAPIS_APP=irplus-statistics-ls6-0.1u2`` (Alternative): Lonestar 6 app.
+ ``STATS_TAPIS_QUEUE=normal`` (Alternative): Lonestar 6 queue.

The Statistics Cache currently has limited support for the double-buffering scheme used
by the main ADC repository. There are two collections in the database, ``statistics_0``
and ``statistics_1``, so that the statistics can be kept separately, but the metadata
cache entries do not currently support this double-buffering. Future work will add this
support but is dependent upon the ADC Download Cache.

We use Tapis metadata entries to record cache information for each
study and repertoire. The repertoire entry is actually for the rearrangement/clone
data for that repertoire. This service relies upon the ADC Download
Cache, and it uses that download cached data for calculating statistics.

There is a metadata entry for each study::

  name: statistics_cache_study
  value:
    repository_id: string
    study_id: string
    download_cache_id: string
    should_cache: boolean
    is_cached: boolean

There is a metadata entry for each repertoire::

  name: statistics_cache_repertoire
  value:
    repository_id: string
    study_id: string
    repertoire_id: string
    should_cache: boolean
    is_cached: boolean
    download_cache_id: string
    statistics_job_id: string

All of the queues are defined in ``cache-queue.js``. The top-level trigger function called by
the service is ``CacheQueue.triggerCache`` which checks if the statistics cache is enabled,
and if yes, submits a repetitive job to ``triggerQueue`` and to ``checkQueue``. The full
set of queues include:

+ ``triggerQueue``: Top level queue for the statistics cache that is run periodically.
  Checks if the cache is enabled, and if yes, submits job to ``createQueue``.
+ ``createQueue``: Gets the list of ADC repositories and determines which ones have the
  statistics cache enabled. For each enabled repository, get the list of studies that
  have been cached in the ADC Download Cache and create statistics cache metadata entries
  for each study and its repertoires if needed.
+ ``checkQueue``: Top level poll queue for the statistics cache that is run periodically.
  It checks if any statistics jobs have been submitted or need to be submitted and submits
  to the ``jobQueue`` if necessary.
+ ``jobQueue``: Gathers statistics cache metadata entries for repertoires that need statistics
  jobs to be run and submits them to Tapis.
+ ``finishQueue``: Either called directly or when a job notification is received from Tapis.
  Checks if the job has finished successfully, deletes any previous statistics data from the
  database, puts the new statistics data into the database, and
  updates the cache metadata entries. If the job failed, tries to determine if it is due to
  a TIMEOUT error and increases the run time for new job submission. If the job failed due
  to an unknown reason, turns off caching for the repertoire and posts an error.
+ ``clearQueue``: Called when an API request is received to delete the statistics cache for
  either a whole study or a single repertoire. Deletes the data from the database, deletes
  the job data, and deletes the cache metadata entries. By default, with the statistics cache
  enabled, the cache metadata entries and statistics data will be regenerated on the next ``triggerQueue``.
+ ``reloadQueue``: Called when an API request is received to reload the statistics cache
  for a study. The cache metadata entries have there ``is_cached`` set to ``false``, but because
  they still have a ``statistics_job_id``, the next ``checkQueue`` will act like they are
  finished jobs and call ``finishQueue``, which will reload the statistics data into the database.

The statistics data will get stored in VDJServer's ADC database. It is expected
that the statistics for all repertoires will be commonly requested, so that
will provide the quickest retrieval. An example statistics object for a repertoire is
around 150KB.

Generating the statistics involves running a Tapis job. This statistics app
is currently defined in the iReceptor tapis repository. It runs the appropriate
commands to generate the statistics for a single repertoire then generates an
output JSON file that matches the response structure for the Stats API. The default
run time for statistics jobs is one hour, but that is not sufficient for large
repertoires. The statistics cache attempts to detect when a job fails due to a ``TIMEOUT``
error and resubmits with a new time multiplied by ``STATS_TIME_MULTIPLIER``. Currently,
with our largest repertoires, the statistics jobs have not needed more than eight
hours of run time.

Unfortunately, the response structure of the API for statistics data is not well optimized
for database queries. Always returning ~3000 * 150KB from the database is slow, especially
as we never need all of the statistics, only a subset for the specific end point.
Therefore, when inserting the statistics data into the database, we re-organize
it so only specific statistics can be returned with projection fields for the query.
The re-organized object looks like this, where each statistic name is a key in the document::

    {
        "repertoire": {
            "repertoire_id": "684559928821354986-242ac113-0001-012",
            "data_processing_id": null,
            "sample_processing_id": null
        },
        "rearrangement_count": {
            "statistic_name": "rearrangement_count",
            "total": 5232174,
            "data": [
                {
                "key": "rearrangement_count",
                "count": 5232174
                }
            ]
        },
        "duplicate_count": {
            "statistic_name": "duplicate_count",
            "total": 5232174,
            "data": [
                {
                "key": "duplicate_count",
                "count": 5232174
                }
            ]
        }, ...
    }

While the rearrangement statistics are fairly well defined, the clone
statistics have not been. It is unclear if the clone data will be able
to be stored in the metadata entry like with the rearrangements
statistics. If we decide to have statistics on each clone, this can get
very large, as the largest repertoires might have millions of clones. Once
we start storing clone data into the ADC, we will gain a better understanding
of the scale.

.. toctree::
   :maxdepth: 1
