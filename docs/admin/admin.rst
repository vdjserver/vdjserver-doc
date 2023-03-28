.. _AdministrationGuide:

********************
Administration Guide
********************

.. contents:: Table of Contents
   :depth: 2
   :local:
   :backlinks: none

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

VM Setup
^^^^^^^^

We try to avoid customizing the VMs when possible to reduce maintenance and allow
for services to be more easily migrated from on VM to another. More details about
each is provided in their own individual section below.

* docker, for VDJServer programs
* nginx, for SSL certificates and proxy
* nfs, for mounting Corral disk

Docker
^^^^^^

We use docker exclusively for running the VDJServer server programs on the VMs. Standard
installation docker for CentOS: https://docs.docker.com/engine/install/centos/

Be sure to enable docker with systemctl so that it gets started on reboot::

 systemctl enable docker
 systemctl enable containerd

Also add the vdj user and any others to the docker group::

 usermod -aG docker vdj
 usermod -aG docker another_user

nginx and SSL Security
^^^^^^^^^^^^^^^^^^^^^^

SSL security is handled at the system level versus in each server
process. Specifically, a system `nginx` is installed as a proxy to
accept https requests and reroutes them to a local port or to a port on
another VM. Incoming non-secure http requests are redirected to https,
but proxied requests going to server processes are sent over http. Though proxied
requests to other VMs could be changed to https for additional security.
The config file `/etc/nginx/nginx.conf` should be kept simple, if possible,
to route all locations to a single port. A second `nginx` which runs as
part of the `docker-compose` and is http, can then handle the routing of
specific locations to specific services. This allows flexibility in
deployment without having to continually modify the system config file::

 yum install nginx

After you have nginx configured properly, make sure to enable the service
with systemctl so that it gets started on reboot::

 systemctl start nginx
 systemctl enable nginx

It's probably best not to try to create the configuration from scratch but
copy from an existing nginx configuration.
The current setup is to have one section for redirecting http to https
as shown here for the vdj-dev VM::

    server {
        listen         80;
        server_name    vdj-dev.tacc.utexas.edu www.vdj-dev.tacc.utexas.edu;
        return         301 https://vdj-dev.tacc.utexas.edu$request_uri;
    }

and another section to route the https request to the local nginx port within
the docker containers. Note that we've had to add a number of custom headers
to responses for security purposes::

    server {
        listen       443 ssl;
        server_name  vdj-dev.tacc.utexas.edu;

        #root /var/www/html/vdjserver-backbone/live-site;                                                                                                                                

        #ssl                  on;                                                                                                                                                        
        ssl_certificate      /etc/pki/tls/certs/vdj-dev.tacc.utexas.edu.cer;
        ssl_certificate_key  /etc/pki/tls/private/vdj-dev.tacc.utexas.edu.key;

        ssl_session_timeout  5m;

        ssl_protocols TLSv1.2;
        ssl_ciphers  EECDH+AESGCM:EDH+AESGCM:AES256+EECDH:AES256+EDH;
        ssl_prefer_server_ciphers   on;
        ssl_dhparam /etc/ssl/certs/dhparam.pem;

        if ($host ~ /^www\./) {
            rewrite ^(.*) https://vdj-dev.tacc.utexas.edu$1 permanent;
        }

        # Deny all attempts to access hidden files                                                                                                                                       
        # such as .htaccess, .htpasswd, .DS_Store (Mac).                                                                                                                                 
        location ~ /\. {
          deny all;
        }

        # route everything to local nginx in the VDJServer docker container
        location / {
            proxy_pass http://127.0.0.1:8080;                                                                                                                                           
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
            proxy_read_timeout 86400;
            # additional security headers required by TACC                                                                                                                               
            add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
            add_header X-Frame-Options SAMEORIGIN always;
            add_header X-Content-Type-Options nosniff always;
            add_header Content-Security-Policy "default-src https: wss: 'self' 'unsafe-inline' 'unsafe-eval'" always;
            add_header X-XSS-Protection "1" always;
            add_header Referrer-Policy "strict-origin-when-cross-origin" always;
            add_header Permissions-Policy "geolocation=(self)" always;
        }

    }

Whenever you change nginx.conf, you need to reload it in the running service::

 nginx -s reload

With V1, all of the components (nginx, web, api) fit on one VM, but in V2 we
add the data repository (repository), which should have its own VM, and there may
be additional services added later.

Tapis V2 Auth Server
^^^^^^^^^^^^^^^^^^^^

The Tapis V2 Auth server for VDJServer (vdj-auth)

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
To mount the disk, the VM needs the NFS software. We don't enable any of the
systemd services because we only want the NFS client and not run an NFS server::

 sudo yum install nfs-utils

Create the mount folder and set its permission::

 sudo mkdir /vdjZ
 sudo chown vdj /vdjZ
 sudo chgrp G-803419 /vdjZ
 sudo chmod a+rw /vdjZ

An entry needs to be put into the system `/etc/fstab` so that it is mounted on VM start::

 129.114.52.166:/corral/main/projects/vdjZ   /vdjZ   nfs   rw,proto=tcp,nfsvers=3,nosuid,rsize=1024768,wsize=1024768,intr 0 0

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

SSL Certificate for vdjserver.org
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Once a year, about a month before the expiration date, UTSW's SysOps will send an email
indicated the vdjserver.org certificate will expire. Installing a new certificate involves
these main steps:

+ Submit a TACC request for certificate renewal.
+ TACC generates a certificate signing request (CSR) and private key for vdjserver.org
+ Submit a UTSW ServiceDesk request with the CSR
+ Pay for the new certificate
+ Install the new certificate into vdjserver.org

Because TACC controls the vdjserver.org domain, they have to generate the certificate
renewal. Generally, after getting TACC to respond to the certificate renewal request,
they can be put on the same email chain as a UTSW person, and together they work through
the steps of generating a new certificate.

Sometimes TACC will install the certificate for us, but in case they just give us
the files, then we can install them. There are two files needed, a private key file
and the certificate file. When installing, make copies of the existing certificates files
and be careful not to accidentally overwrite or delete them. The private key file
is put in the `/etc/pki/tls/private` directory, and the certificate file is put in
the `/etc/pki/tls/certs` directory. In both cases, there is a `backup`
subdirectory to put backup copies, e.g., with these commands where `YEAR` is the active
year for the certificate.

+ ssh to vdjserver.org and become root
+ cd /etc/pki/tls/certs
+ copy certificate file to vdjserver.org.cer.YEAR
+ cp vdjserver.org.cer.YEAR backup
+ cd /etc/pki/tls/private
+ copy private key file to vdjserver.org.key.YEAR
+ cp vdjserver.org.key.YEAR backup

If there are multiple files in the directory, and it is not clear which are the
current files, look in the nginx config file, `/etc/nginx/nginx.conf`, and
`ssl_certificate` and `ssl_certificate_key` will have the full path to the files.

If you copy the new files over the old files then there is no need to modify the
nginx config file, but I suggest using a `YEAR` prefix to keep the files separate.
This helps accidentally overwriting a file.

+ edit /etc/nginx/nginx.conf and set `ssl_certificate` and `ssl_certificate_key` to
  the absolute paths to the certificate and private key files.
+ restart nginx with `systemctl restart nginx`
+ check nginx is running and no errors with `systemctl status nginx`

Verify that the new certificate is installed by going to vdjserver.org from your
browser. You may need to refresh and/or clear your cache. Check the certificate
and verify it has a new expiration date.

Note that these instructions only apply to the vdjserver.org production machine. The vdj-staging,
vdj-dev, and other VMs are in the tacc.utexas.edu domain. If the certificate expires
for any of them, submit a TACC request and they will update.

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
