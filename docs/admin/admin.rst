.. _AdministrationGuide:

********************
Administration Guide
********************

This guide describes the deployment of the VDJServer services on
computing resources provided by Texas Advanced Computing Center,
The University of Texas at Austin. VDJServer is managed by
Dr Lindsay G. Cowell at UT Southwestern Medical Center. Dr Scott Christley
is the software development manager and is responsible for day-to-day operations.

If you log on to this computer system, you acknowledge your awareness
and acceptance of the UT Austin Acceptable Use Policy. The
University will prosecute violators to the full extent of the law.

TACC Usage Policies: https://portal.tacc.utexas.edu/tacc-usage-policy

Service Deployment
-----------------------

There are currently three primary deployments of VDJServer: development, staging
and production. Each resides on its own VM at TACC:
vdj-dev.tacc.utexas.edu (development), vdj-staging.tacc.utexas.edu
(staging), vdj-prod.tacc.utexas.edu (production). vdj-prod is the same
as https://vdjserver.org. These are full public deployments in that Google Recaptcha,
emails, and other system services should be accessible and functional.

These VMs cannot be accessed by ssh outside of TACC, so you first
need to ssh to a public TACC machine such as ls5.tacc.utexas.edu or
stampede2.tacc.utexas.edu. Furthermore, they all require 2-factor authentication
with the TACC Token app. The publicly accessible ports are 80, 443 and
8443; the first two being the standard http/https ports while 8443 is
for testing on vdj-dev. SSL Security as explained below is configured
on each of the deployment VMs.

Other VMs include:

+ vdj-rep-01: data.vdjserver.org Tapis storage system, production ADC
+ vdj-rep-02: staging ADC
+ vdj-rep-03: V2 API
+ vdj-rep-04: open

SSL Security
^^^^^^^^^^^^

SSL security is handled at the system level versus in each server
process. Specifically, a system `nginx` is installed as a proxy to
accept https requests and reroutes them to a local port or to a port on
another VM. Incoming non-secure http requests are redirected to https,
but proxied requests went to server processes are sent over http. The
config file `/etc/nginx/nginx.conf` should be kept simple, if possible,
to route all locations to a single port. A second `nginx` which runs as
part of the `docker-compose` and is http, can then handle the routing of
specific locations to specific services. This allows flexibility in
deployment without having to continually modify the system config file.

With V1, all of the components (nginx, web, api) fit on one VM, but in V2 we
add the data repository (repository), which should have its own VM. There are
additional APIs from iReceptor+

VDJServer Production
^^^^^^^^^^^^^^^^^^^^

This is the production deployment of VDJServer. Care should be taken in making any
changes to minimize disruption to users.

VDJServer Staging
^^^^^^^^^^^^^^^^^^^^

This is the staging deployment of VDJServer. 

VDJServer Development
^^^^^^^^^^^^^^^^^^^^^

This deployment is meant to support the development process. While a significant amount of
development can be done on a local machine, there are number of functions that require the
deployment environment to work properly. Some of these include:

* Google captcha.
* Notifications from Tapis.
* Access to TACC restricted resources.

Additional VMs
^^^^^^^^^^^^^^

There are four additional VMs that can be used for running API services.

* vdj-rep-01: This is the current production machine for VDJServer ADC API. It is also
  the Tapis storage system `data.vdjserver.org`, which is actually a proxy to access the
  Corral project storage mounted at `/vdjZ`.
* vdj-rep-02: This is the current staging machine for VDJServer ADC API and for iR+ APIs.
* vdj-rep-03: This is the current staging machine for VDJServer API V2.
* vdj-rep-04: This is currently open.

API Ports
^^^^^^^^^

VDJServer V1 only had the single API process, but V2 has introduced additional services. To
avoid conflict, we try to use unique ports for each service. To complicate matters, most
services run within docker containers and internal ports can be exposed differently, but we
try to use the same port number for both.

* 8080: nginx https proxy.
* 8080: VDJServer API V1, `/api/v1`.
* 8020: VDJServer ADC API, `/airr/v1`.
* 8021: VDJServer ADC Async API, `/airr/async/v1`.
* 8025: VDJServer iR+ Stats API, `/irplus/stats/v1`.
* 8027: VDJServer iR+ Analysis API, `/irplus/analysis/v1`.

Corral Disk
^^^^^^^^^^^

Some API services requires direct access to the Corral project disks so that it can
access files more efficiently versus going through the Tapis API.
TACC needs to enable NFS mount for any VM that will access.
To mount the disk, the VM needs the `nfs-client` software::

 sudo yum install nfs-client

Create the mount folder and set its permission::

 sudo mkdir /vdjZ
 sudo chown vdj /vdjZ
 sudo chgrp G-803419 /vdjZ
 sudo chmod a+rw /vdjZ

An entry needs to be put into the system `/etc/fstab` so that it is mounted on VM start.

 c3-dtn02.corral.tacc.utexas.edu:/gpfs/corral3/repl/projects/vdjZ	/vdjZ	nfs          rw,proto=tcp,nfsvers=3,nosuid,rsize=1024768,wsize=1024768,intr      0 0

Note that only the vdj account is allowed to write the project disk, even root is
not allowed. This means you need to switch to the vdj account if you want to work
with the files at the command line. Also, API service programs must change their
group and user in order to access.

Processes and Checklists
------------------------

Start/Stop Services
^^^^^^^^^^^^^^^^^^^

Maintenance Mode
^^^^^^^^^^^^^^^^

VDJServer may need to be put in maintenance mode for a number of reasons. Putting VDJServer
in maintenance mode displays a message on the home page and prevents users from login, as well
as other functionality from the home page like creating an account or password reset.

* TACC or Tapis is experiencing issues that prevent VDJServer from working properly.
* VDJServer itself has an issue that prevents it from working properly.
* VDJServer is going through a significant upgrade.

The `environment-config.js` configuration file has a simple mechanism to enable maintenance
mode and display a maintenance message:

1. Login to vdj-prod and become root
2. Go to directory which holds the active `environment-config.js`, this is typically
   `/var/www/docker/vdjserver-web/vdjserver-web-backbone/docker/environment-config/run`
3. Make a backup: `cp environment-config.js environment-config.js.bak`
4. Open `environment-config.js` in an editor such as emacs
5. Change `maintenance` value to `true`
6. Change `maintenanceMessage` to the message to be displayed on the home page.
7. Save the file. Changes are active immediately.
8. Load https://vdjserver.org to verify maintenance mode and the display message.

Disabling maintenance mode can be done by replacing `environment-config.js` with the
backup file, or editing it directly:

1. Change `maintenance` value to `false`
2. Save the file. Changes are active immediately.
3. Load https://vdjserver.org and verify you can login.

These instructions are for the production website. If necessary, put the staging and
development deployments in maintenance mode, or shutdown the services to prevent access.

This maintenance mode only applies to the VDJServer GUI. Other VDJServer services like
the Web API and the ADC repository will still be active. These services have to be shutdown
if access needs to be disabled.

SSL Certificate
^^^^^^^^^^^^^^^

The VDJServer SSL certificate is managed through a combination of UTSW IR and
TACC. Every 1 or 2 years it needs to be renewed. The basic process:

1. UTSW IR sends an email indicating that the certificate needs to be renewed. Create
   an IR support ticket to start the process.
2. Create a TACC issue in the user portal for the certificate renewal.
3. When TACC responds, typically get the IR and TACC personnel together on the same email chain.
4. TACC issues a certificate request.
5. IR gets the certificate signed and sends to TACC.
6. TACC installs the certificate.
7. UTSW IR needs an account number for the cost.

VDJServer Users Mailing List
----------------------------

We utilize UTSW's mailing list service, running GNU mailman, to manage VDJServer's user
mailing list. Currently, the process is not automated and new users must be manually
added to the mailing list. Automating is difficult as the mailing list administration
can only be accessed on UTSW's internal network, which is not accessible from the TACC
VMs running the VDJServer code. There are two essential tasks: 1) generate list of new
user accounts, and 2) add new emails to the mailing list.

The email account for the mailing list is `vdjserver-users@lists.utsouthwestern.edu`

The script to list user accounts is part of the `vdjserver-repair` repository. Here is
the steps to generate a list of new user accounts

1. Login into TACC (stampede2, etc.) and become vdj.
2. `source vdjserver.env` to setup environment.
3. Go to $WORK directory, then `cd ../common/vdjserver-repair`
4. `module load python3`
5. `python3 list_all_users.py`
6. To keep historical records, the `users` subdirectory contains dated files with
   the list of all users, e.g. `agave_users_Jul_13_2021.txt`, `agave_users_Jul_6_2020.txt`,
   and so on. Also, there is a file with the last user added, e.g. `last_user_Jul_13_2021.txt`,
   `last_user_Jul_6_2020.txt`, and so on. Run the script again and send the output to a
   file with the current date.
7. `python3 list_all_users.py >users/agave_users_MON_DAY_YEAR.txt`
8. `cd users`
9. Now you need to extract just the new users created since the last time. Open the
   `agave_users_MON_DAY_YEAR.txt` file in an editor, search for the user account for
   the last user added from the previous time period, then copy/paste the rows and save
   into file `users_to_subscribe.txt`. Also, put the last user in the list into a new
   file with the current data, `last_user_MON_DAY_YEAR.txt`.
10. Finally, extract just the email address from `users_to_subscribe.txt`.
11. `awk '{print $2}' users_to_subscribe.txt`
12. You can copy/paste that list of emails into the mailing list administration website
    as described below. There is no need to worry about removing duplicate emails because
    the mailing list will automatically filter those out.
13. Lastly, add, commit and push the new files with `git` to the repository so the information
    is saved.

Administration of the VDJServer mailing list requires being on the UTSW internal network.
Also, the website is not secure (http versus https) and some browser will automatically try
to switch to https. This can usually be overcome by opening a private (in cognito) browser
window.

1. Open a private (in cognito) browser window.
2. Go to `http://lists.utsouthwestern.edu/mailman/listinfo/vdjserver-users`
3. At the bottom of the screen is a link to the VDJServer-users administrative interface:
   `http://lists.utsouthwestern.edu/mailman/admin/vdjserver-users`
4. Authenticate with the admin password.
5. From the configuration categories, click `Membership Management...` then click
   `Mass Subscription`.
6. There is a text box labeled `Enter one address per line below`, copy/paste the list of
   emails into that text box, and click the `Submit Your Changes` button to mass subscribe
   all the emails. The result page should list the emails successfully subscribed, and
   any duplicates will be automatically filtered out. Emails will also to the mailing list
   owners indicating that the emails have been successfully subscribed.

.. toctree::
   :maxdepth: 1
