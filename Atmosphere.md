# Getting Started With Atmosphere 

## Creating a Cyverse Atmosphere Account

1. Go to https://user.cyverse.org and register as a new user.
2. You must use the e-mail provided to Lisa for this workshop or your account may not be approved.
3. Once your account is activated, go to https://user.cyverse.org/dashboard and find Atmosphere under "Available Services" and click "Request Access"
4. The application will ask for the workshop name (Kew HybSeq Workshop) and Instructor name (Matt Johnson)

## Starting an Instance

Login to https://atmo.cyverse.org

The instance will take approximately 15 minutes to be fully active.


## Logging into the Instance

Click on the instance in your Dashboard and verify that it is currently active. 

Under IP Address, click "copy" to copy the IP address to your clipboard.

#### MACOSX

Open the Terminal application, which is located in the Utilities folder inside Applications.

Enter the command:

`ssh username@127.0.0.1`

Where `username` is your Cyverse username, and `127.0.0.1` is the instance IP address. Press enter and you will be prompted your Cyverse password. Enter your password and press enter.

The first time you login you may be asked to verify the identity of the server. Type `yes` to continue.


#### Windows

Download and install PuTTY (http://www.putty.org/), an SSH client for Windows. 

Open PuTTY and open a new connection by pasting the IP address under HostName and selecting SSH. Use your Cyverse username and password.

The first time you connect, PuTTY will ask you to verify the identify of the server. Click yes.

More information about using PuTTY can be found here: https://mediatemple.net/community/products/dv/204404604/using-ssh-in-putty-


## Access to Workshop Data

## GUI Access via VNC

The Atmosphere instance also has GUI access, which we will use to access programs with a graphical interface. You can access the server through the Web Desktop by clicking the link on the right column of instance page. However, this interface is slow, and we recommend access through a standalone program. 

Download and install VNC Viewer via https://www.realvnc.com/download/viewer/

Open the application and start a new connection from the File menu. You must connect to port 1 to access the desktop remotely. Therefore if your IP address is `127.0.0.1` you need to enter `127.0.0.1:1`. Use your Cyverse account username and password. 

Once you have connected, you should see a screen like this:

<img src=images/vnc_desktop.png width="500">

You can now access your instance as if it were any other graphical operating system. Several phylogenetics programs have been installed; check "Other" in the Applications menu.


## SFTP Access via Cyberduck

If you wish to transfer your own files to and from your instance, the easiest way is with a graphical SFTP client. We recommend Cyberduck (https://cyberduck.io)

Download and install Cyberduck and start a new SFTP connection with your Cyverse username, password, and instance IP address. 


