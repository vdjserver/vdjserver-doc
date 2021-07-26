*****************
Developer's Guide
*****************

VDJServer Architecture
======================

VDJServer Web
=============

VDJServer Web is a web-based graphical user interface. Specifically, a Javascript Single-Page
Application using Backbone models, Marionette views, and Bootstrap styling. Handlebars
is used for HTML templating. The design follows the Model-View-Controller pattern for the
complex pages; while for simpler pages, the controller is embedded in the Marionette view.
Here are the primary GUI sections and modules:

+ Home / Login
+ Navigation Bar
+ Community Data Portal
+ Documentation
+ Feedback
+ Create Account
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


VDJServer Web APIs
------------------

VDJServer API
-------------

The core API for VDJServer. It provides numerous capabilities with the endpoints
organized within core categories. These categories are tags on the endpoints in the
OpenAPI specification.

+ authentication: create and refresh authentication tokens
+ user: create/verify user account, change/reset password
+ project: create project, import/export metadata, load/unload into ADC
+ permission: manage user permissions on project data
+ feedback: public and user feedback
+ telemetry: system error reporting
+ ADC: query/cache of the AIRR Data Commons

Security schemes
----------------

The V1 design had a mix of schemes. I eliminated all the basic authentication schemes and
support strictly ``Bearer`` tokens, which are Tapis tokens, so all endpoints are either
public or they require a valid token. Furthermore, V1 did checks for
basic user authorization and a second check for project authorization. The two checks
have been formalized in OpenAPI V3 as ``user_authorization`` and ``project_authorization``
schemes. As we only want a single security scheme attached to each endpoint (so it work
exclusively), ``project_authorization`` has to perform ``user_authorization`` as well. There
are stubs for additional schemes, such as admin, but I have not had to use more yet. All
of the authorization code is contained in ``authController.js``.

ADC endpoints
^^^^^^^^^^^^^

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

VDJServer ADC ASYNC API
-----------------------

This API encapsulates the Tapis LRQ API which has restricted access and provides additional
functionality beyond the LRQ API. A metadata V1 entry ``{"name":"async_query"}`` is created to hold LRQ information
and any additional information. The metadata UUID is returned as the async API query identifier.

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

There is metadata entry for the each study::

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


.. toctree::
   :maxdepth: 1
